import cocotb
from cocotb.clock import Clock
from cocotb.triggers import FallingEdge, RisingEdge, ClockCycles, with_timeout, Timer
from cocotb.result import ReturnValue
from collections import namedtuple

NUMBER_OF_PROJECTS = 2

ADDR_PROJECT = 0x30000000
ADDR_WS2812  = 0x30000100
ADDR_7SEG    = 0x30000200

async def wishbone_write(dut, address, data):
    assert dut.wbs_ack_o == 0
    await RisingEdge(dut.wb_clk_i)
    dut.wbs_stb_i   <= 1
    dut.wbs_cyc_i   <= 1
    dut.wbs_we_i    <= 1        # write
    dut.wbs_sel_i   <= 0b1111   # select all bytes,      // which byte to read/write
    dut.wbs_dat_i   <= data
    dut.wbs_adr_i   <= address

    await with_timeout (RisingEdge(dut.wbs_ack_o), 100, 'us')
    await with_timeout (FallingEdge(dut.wbs_ack_o), 100, 'us')

    dut.wbs_cyc_i   <= 0
    dut.wbs_stb_i   <= 0
    dut.wbs_sel_i   <= 0
    dut.wbs_dat_i   <= 0
    dut.wbs_adr_i   <= 0

async def wishbone_read(dut, address):
    assert dut.wbs_ack_o == 0
    await RisingEdge(dut.wb_clk_i)
    dut.wbs_stb_i   <= 1
    dut.wbs_cyc_i   <= 1
    dut.wbs_we_i    <= 0        # read
    dut.wbs_sel_i   <= 0b1111   # select all bytes,      // which byte to read/write
    dut.wbs_adr_i   <= address

    await with_timeout (RisingEdge(dut.wbs_ack_o), 100, 'us')

    # grab data
    data = dut.wbs_dat_o

    await with_timeout (FallingEdge(dut.wbs_ack_o), 100, 'us')

    dut.wbs_cyc_i   <= 0
    dut.wbs_stb_i   <= 0
    dut.wbs_sel_i   <= 0
    dut.wbs_dat_i   <= 0
    dut.wbs_adr_i   <= 0

    return data

# reset
async def reset(dut):
    dut.wbs_cyc_i   <= 0
    dut.wbs_stb_i   <= 0
    dut.wbs_sel_i   <= 0
    dut.wbs_dat_i   <= 0
    dut.wbs_adr_i   <= 0

    dut.wb_rst_i <= 1;
    await ClockCycles(dut.wb_clk_i, 5)
    dut.wb_rst_i <= 0;
    await ClockCycles(dut.wb_clk_i, 5)

# bit-bang SPI data exchange
async def spix(dut, sig, v):
    tick = 7
    snd = v
    sig.ss <= False
    await ClockCycles(dut.wb_clk_i, tick)
    rcv = 0
    for i in range(16):
        sig.mosi <= (v >> 15)
        sig.sck <= True
        await ClockCycles(dut.wb_clk_i, tick)
        rcv = (rcv << 1) | sig.miso.value
        sig.sck <= False
        v <<= 1
        await ClockCycles(dut.wb_clk_i, tick)
    await ClockCycles(dut.wb_clk_i, tick)
    sig.ss <= True
    dut._log.info("SPI: snd %4.4x rcv %4.4x", snd, rcv)
    return rcv

@cocotb.test()
async def test_wb_access(dut):
    clock = Clock(dut.wb_clk_i, 10, units="us")
    cocotb.fork(clock.start())
    
    await reset(dut)

    for project_number in range(NUMBER_OF_PROJECTS):
        # activate design 1
        await wishbone_write(dut, ADDR_PROJECT, project_number)
        assert dut.active_project == project_number

        # check active design
        active_project = await wishbone_read(dut, ADDR_PROJECT)
        assert active_project == project_number 

@cocotb.test()
# 7 segment
async def test_project_0(dut):
    clock = Clock(dut.wb_clk_i, 10, units="us")
    cocotb.fork(clock.start())
    
    await reset(dut)

    # activate design 0
    project_number = 0
    await wishbone_write(dut, ADDR_PROJECT, project_number)
    assert dut.active_project == project_number

    # use a gpio as a clock
    io_clock = Clock(dut.io_in[0], 10, units="us") 
    clk_gen = cocotb.fork(io_clock.start())

    # use external gpio as reset
    dut.io_in[1] <= 1
    await ClockCycles(dut.wb_clk_i, 5)
    dut.io_in[1] <= 0

    # update compare to 10 - will also reset the counter
    await wishbone_write(dut, ADDR_7SEG, 10)

    # wait some cycles
    await ClockCycles(dut.wb_clk_i, 50)
    assert dut.proj_0.digit == 4
    await ClockCycles(dut.wb_clk_i, 1)
    assert dut.proj_0.digit == 5

@cocotb.test()
# ws2812
async def test_project_1(dut):
    clock = Clock(dut.wb_clk_i, 10, units="us")
    cocotb.fork(clock.start())
    
    await reset(dut)

    # activate design 1
    project_number = 1
    await wishbone_write(dut, ADDR_PROJECT, project_number)
    assert dut.active_project == project_number

    # use a gpio as a clock
    io_clock = Clock(dut.io_in[0], 10, units="us") 
    clk_gen = cocotb.fork(io_clock.start())

    # use external gpio as reset
    dut.io_in[1] <= 1
    await ClockCycles(dut.wb_clk_i, 5)
    dut.io_in[1] <= 0

    # setup a colour for some leds
    led_num = 7
    r = 255
    g = 10
    b = 100
    await wishbone_write(dut, ADDR_WS2812, (led_num << 24) + (r << 16) + (g << 8) + b)

    # wait some cycles
    await ClockCycles(dut.wb_clk_i, 500)

@cocotb.test()
# vga_clk
async def test_project_2(dut):
    clock = Clock(dut.wb_clk_i, 10, units="us")
    cocotb.fork(clock.start())
    
    await reset(dut)

    # activate design 2
    project_number = 2
    await wishbone_write(dut, ADDR_PROJECT, project_number)
    assert dut.active_project == project_number

    # use a gpio as a clock
    io_clock = Clock(dut.io_in[0], 10, units="us") 
    clk_gen = cocotb.fork(io_clock.start())

    # use external gpio as reset
    dut.io_in[1] <= 1
    await ClockCycles(dut.wb_clk_i, 5)
    dut.io_in[1] <= 0

    # wait some cycles
    await ClockCycles(dut.wb_clk_i, 600*800)

@cocotb.test()
# spinet
async def test_project_3(dut):
    clock = Clock(dut.wb_clk_i, 10, units="us")
    cocotb.fork(clock.start())
    
    await reset(dut)

    # activate design 3
    project_number = 3
    await wishbone_write(dut, 0x00FF00FF, project_number)
    assert dut.active_project == project_number

    # use a gpio as a clock
    io_clock = Clock(dut.io_in[0], 10, units="us") 
    clk_gen = cocotb.fork(io_clock.start())

    # use external gpio as reset
    dut.io_in[1] <= 1
    await ClockCycles(dut.wb_clk_i, 5)
    dut.io_in[1] <= 0
    await ClockCycles(dut.wb_clk_i, 5)

    # group SPI & ready signals for net nodes 0, 1
    SPIsigs = namedtuple('SPIsigs', 'miso mosi ss sck txrdy rxrdy')
    spi0 = SPIsigs(miso=dut.io_out[8], mosi=dut.io_in[2], ss=dut.io_in[6],
                      sck=dut.io_in[4], txrdy=dut.io_out[10], rxrdy=dut.io_out[12])
    spi1 = SPIsigs(miso=dut.io_out[9], mosi=dut.io_in[3], ss=dut.io_in[7],
                      sck=dut.io_in[5], txrdy=dut.io_out[11], rxrdy=dut.io_out[13])

    assert spi0.txrdy.value and spi1.txrdy.value
    assert (not spi0.rxrdy.value) and (not spi1.rxrdy.value)

    # node 0 sends one byte to node 1
    data = ord('B')
    ctl = 0x80 | (0<<0) | (1<<3)
    await spix(dut, spi0, (ctl<<8) | data)

    # node 1 waits for the byte and receives it
    #await RisingEdge(spi1.rxrdy)
    await ClockCycles(dut.wb_clk_i, 10)
    assert spi1.rxrdy.value
    rcv = await spix(dut, spi1, 0)

    # check data and sender address
    assert (rcv & 0xFF) == data and ((rcv>>8) & 0x7) == 0
