import cocotb
from cocotb.clock import Clock
from cocotb.triggers import FallingEdge, RisingEdge, ClockCycles

@cocotb.test()
async def test(dut):
    clock = Clock(dut.clk, 10, units="us")
    cocotb.fork(clock.start())
    dut.reset <= 0b1111;

    # outs should be unset
    assert not '1' in dut.gpio_out.value.binstr
    assert not '0' in dut.gpio_out.value.binstr

    await ClockCycles(dut.clk, 10)

    # take inst0 out of reset
    dut.reset <= 0b1110;

    # use a gpio as a clock
    gpio0_clock = Clock(dut.gpio_in[0], 10, units="us") 
    clk_gen = cocotb.fork(gpio0_clock.start())

    await ClockCycles(dut.clk, 500)

    clk_gen.kill()
    
    # all in reset
    dut.reset <= 0b1111;
    await FallingEdge(dut.clk)
    assert not '1' in dut.gpio_out.value.binstr
    assert not '0' in dut.gpio_out.value.binstr

    await ClockCycles(dut.clk, 100)

    # take inst1 out of reset
    dut.reset <= 0b1101;

    # use a gpio as a clock
    gpio1_clock = Clock(dut.gpio_in[1], 10, units="us") 
    clk_gen = cocotb.fork(gpio1_clock.start())

    await ClockCycles(dut.clk, 500)
