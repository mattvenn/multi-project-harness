import cocotb
from cocotb.clock import Clock
from cocotb.triggers import FallingEdge, RisingEdge, ClockCycles, with_timeout

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
