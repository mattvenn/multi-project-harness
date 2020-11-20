'''
Implements a frequency counter with UART output.

install nmigen and run

    $ python asic_freq.py generate

to generate asic_freq.v, which is instantiated in multi_project_harness.v

TODO make nmigen choose a better name than `top` for the top-level module
'''
from nmigen import Signal, Module, Elaboratable, Cat, C, ClockSignal, Memory
from nmigen.lib.coding import GrayDecoder, GrayEncoder
from nmigen.compat.fhdl.decorators import ClockDomainsRenamer
from nmigen.lib.cdc import FFSynchronizer
from nmigen.hdl.cd import ClockDomain
from bin2bcd import Bin2bcd


class UART(Elaboratable):
    def __init__(self, divisor, data_bits=8):
        """
        Parameters
        ----------
        divisor : int
            Set to ``round(clk-rate / baud-rate)``.
            E.g. ``12e6 / 115200`` = ``104``.
        """
        assert divisor >= 4

        self.data_bits = data_bits
        self.divisor = Signal(32, reset=divisor)

        self.tx_o = Signal()
        self.rx_i = Signal()

        self.tx_data = Signal(data_bits)
        self.tx_rdy = Signal()
        self.tx_ack = Signal()

        self.rx_data = Signal(data_bits)
        self.rx_err = Signal()
        self.rx_ovf = Signal()
        self.rx_rdy = Signal()
        self.rx_ack = Signal()

    def elaborate(self, platform):
        m = Module()

        tx_phase = Signal(32)
        tx_shreg = Signal(1 + self.data_bits + 1, reset=-1)
        tx_count = Signal(range(len(tx_shreg) + 1))

        m.d.comb += self.tx_o.eq(tx_shreg[0])
        with m.If(tx_count == 0):
            m.d.comb += self.tx_ack.eq(1)
            with m.If(self.tx_rdy):
                m.d.sync += [
                    tx_shreg.eq(Cat(C(0, 1), self.tx_data, C(1, 1))),
                    tx_count.eq(len(tx_shreg)),
                    tx_phase.eq(self.divisor - 1),
                ]
        with m.Else():
            with m.If(tx_phase != 0):
                m.d.sync += tx_phase.eq(tx_phase - 1)
            with m.Else():
                m.d.sync += [
                    tx_shreg.eq(Cat(tx_shreg[1:], C(1, 1))),
                    tx_count.eq(tx_count - 1),
                    tx_phase.eq(self.divisor - 1),
                ]

        rx_phase = Signal(32)
        rx_shreg = Signal(1 + self.data_bits + 1, reset=-1)
        rx_count = Signal(range(len(rx_shreg) + 1))

        m.d.comb += self.rx_data.eq(rx_shreg[1:-1])
        with m.If(rx_count == 0):
            m.d.comb += self.rx_err.eq(~(~rx_shreg[0] & rx_shreg[-1]))
            with m.If(~self.rx_i):
                with m.If(self.rx_ack | ~self.rx_rdy):
                    m.d.sync += [
                        self.rx_rdy.eq(0),
                        self.rx_ovf.eq(0),
                        rx_count.eq(len(rx_shreg)),
                        rx_phase.eq(self.divisor // 2),
                    ]
                with m.Else():
                    m.d.sync += self.rx_ovf.eq(1)
        with m.Else():
            with m.If(rx_phase != 0):
                m.d.sync += rx_phase.eq(rx_phase - 1)
            with m.Else():
                m.d.sync += [
                    rx_shreg.eq(Cat(rx_shreg[1:], self.rx_i)),
                    rx_count.eq(rx_count - 1),
                    rx_phase.eq(self.divisor - 1),
                ]
                with m.If(rx_count == 1):
                    m.d.sync += self.rx_rdy.eq(1)

        return m


class Counter(Elaboratable):
    def __init__(self, width):
        self.v = Signal(width, reset=2**width - 1)
        self.o = Signal()

    def elaborate(self, platform):
        m = Module()
        m.d.sync += self.v.eq(self.v + 1)
        m.d.comb += self.o.eq(self.v[-1])
        return m


class _Sampler(Elaboratable):
    def __init__(self, width):
        self.width = width
        self.i = Signal(width)

        # latched count for UART output (auto reset on latch)
        self.latch = Signal()
        self.o = Signal(32)

        # continuous count (never resets, for CPU readout)
        self.oc = Signal(32)

    def elaborate(self, platform):
        m = Module()

        inc = Signal(self.width)
        counter = Signal(32)

        # Use wrapping property of unsigned arithmeric to reset the counter at
        # each cycle. Doing it in fmeter clock domain would not be reliable.
        i_d = Signal(self.width)
        m.d.sync += i_d.eq(self.i)
        m.d.comb += inc.eq(self.i - i_d)

        with m.If(self.latch):
            m.d.sync += [
                self.o.eq(counter),
                counter.eq(0)
            ]
        with m.Else():
            m.d.sync += counter.eq(counter + inc)

        m.d.sync += self.oc.eq(self.oc + inc)

        return m


class FreqMeter(Elaboratable):
    '''
    This is a verbatim copy from Litex, moved to nmigen, Litex lacks tests,
    Let's hope to change that here
    '''

    def __init__(self, period, width=6, clk=None):
        # Signal under test (SUT)
        self.clk = Signal() if clk is None else clk

        # Number of counts per period
        self.value = Signal(32)
        self.value_valid = Signal()

        # Continuous count value
        self.oc = Signal(32)

        # Maximum SUT frequency = sys_clk frequency * 2**width
        self.width = width

        # Number of sys_clks to count the SUT
        self.period = Signal(32, reset=period)

    def elaborate(self, platform):
        m = Module()

        m.domains += ClockDomain("fmeter", reset_less=True)
        m.d.comb += ClockSignal("fmeter").eq(self.clk)

        # Period generation
        period_done = Signal()
        period_counter = Signal(32)
        m.d.comb += period_done.eq(period_counter >= self.period)
        m.d.sync += self.value_valid.eq(0)
        with m.If(period_done):
            m.d.sync += [
                period_counter.eq(0),
                self.value_valid.eq(1)
            ]
        with m.Else():
            m.d.sync += period_counter.eq(period_counter + 1)

        # --------------------------
        #  Frequency measurement
        # --------------------------
        # GrayEncoder is in its own clock-domain (fmeter) and counts clock
        # edges of the signal under test with a low number (`width`) of bits
        ev_cnt_ = Signal(self.width)
        m.d.fmeter += ev_cnt_.eq(ev_cnt_ + 1)
        event_counter = ClockDomainsRenamer("fmeter")(GrayEncoder(self.width))
        # GrayDecoder is used to reliably move the counting value to the
        # sys_clk domain
        gray_decoder = GrayDecoder(self.width)
        # every sys_clk cycle, _Sampler accumulates the count value into a high
        # resolution (32 bit) counting register
        # After a fixed amount of clock-cycles, the counting register is
        # latched for read-out and reset for the next count.
        sampler = _Sampler(self.width)
        m.submodules += event_counter, gray_decoder, sampler

        m.submodules += FFSynchronizer(event_counter.o, gray_decoder.i)
        m.d.comb += [
            event_counter.i.eq(ev_cnt_),
            sampler.latch.eq(period_done),
            sampler.i.eq(gray_decoder.o),
            self.value.eq(sampler.o),
            self.oc.eq(sampler.oc)
        ]
        return m


class ASICFreak(Elaboratable):
    def __init__(self, sys_clk_freq):
        '''
        sys_clk_freq is used to set UART to 115200 baud/s and
        1 Hz measurement rate on reset
        '''
        self.sys_clk_freq = int(sys_clk_freq)
        self.samplee = Signal()  # the signal under test
        self.oc = Signal(32)  # Continuous count output to CPU
        self.tx = Signal()  # UART output

        # For writing config registers
        # 0 = UART clock divider
        # 1 = Frequency counter update period [sys_clks]
        self.addr = Signal(4)
        self.strobe = Signal()
        self.value = Signal(32)

    def ports(self):
        return [
            self.samplee, self.oc, self.tx, self.addr, self.strobe, self.value
        ]

    def elaborate(self, platform):
        m = Module()

        m.submodules.uart = uart = UART(divisor=self.sys_clk_freq // 115200)
        m.submodules.f_meter = f_meter = FreqMeter(self.sys_clk_freq)
        m.submodules.b2bcd = b2bcd = Bin2bcd(len(f_meter.value))

        # Configuration register interface
        with m.If(self.strobe):
            with m.Switch(self.addr):
                with m.Case(0):
                    m.d.sync += uart.divisor.eq(self.value)
                with m.Case(1):
                    m.d.sync += f_meter.period.eq(self.value)

        # latch BCD formated frequency here for shifting it out over UART
        result = Signal(len(b2bcd.bcd_out))

        m.d.comb += [
            f_meter.clk.eq(self.samplee),
            # b2bcd.bin_in.eq(1234567895),
            b2bcd.bin_in.eq(f_meter.value),
            b2bcd.trig_in.eq(f_meter.value_valid)
        ]

        mem = Memory(width=7, depth=7, init=b'Freak!\n')
        m.submodules.mem_r = mem_r = mem.read_port()
        mem_addr = Signal(8)
        print_cnt = Signal(8)
        m.d.comb += mem_r.addr.eq(mem_addr)

        m.d.sync += uart.tx_rdy.eq(0)  # might be overridden in FSM

        with m.FSM():
            with m.State("INIT"):
                # Print initial text from memory
                with m.If(uart.tx_ack & ~uart.tx_rdy):
                    m.d.sync += [
                        uart.tx_data.eq(mem_r.data),
                        uart.tx_rdy.eq(1),
                        mem_addr.eq(mem_addr + 1)
                    ]
                with m.If(mem_addr >= mem.depth):
                    m.next = "MEAS"

            with m.State("MEAS"):
                # Latch result in BCD format
                with m.If(b2bcd.trig_out):
                    m.d.sync += [
                        result.eq(b2bcd.bcd_out),
                        print_cnt.eq(0)
                    ]
                    m.next = "PRINT"

            with m.State("PRINT"):
                # Print the 10 digits of the result
                with m.If(uart.tx_ack & ~uart.tx_rdy):
                    m.d.sync += [
                        uart.tx_data.eq(result[-4:] + ord('0')),
                        uart.tx_rdy.eq(1),
                        result.eq(result << 4),
                        print_cnt.eq(print_cnt + 1)
                    ]
                with m.If(print_cnt >= len(b2bcd.bcd_out) // 4):
                    m.next = "PRINT_EOL"

            with m.State("PRINT_EOL"):
                # Print \n
                with m.If(uart.tx_ack & ~uart.tx_rdy):
                    m.d.sync += [
                        uart.tx_rdy.eq(1),
                        uart.tx_data.eq(ord('\n'))
                    ]
                    m.next = "MEAS"

        m.d.comb += [
            self.tx.eq(uart.tx_o),
            uart.rx_i.eq(0)
        ]
        return m


if __name__ == "__main__":
    fn = __file__[:-3]

    import argparse

    parser = argparse.ArgumentParser()
    p_action = parser.add_subparsers(dest="action")
    p_action.add_parser("simulate")
    p_action.add_parser("generate")

    args = parser.parse_args()
    if args.action == "simulate":
        from nmigen.back.pysim import Simulator, Delay
        afr = ASICFreak(115200 * 4)
        sim = Simulator(afr)
        sim.add_clock(1 / 25e6)
        f_test = 40e6  # frequency of the test signal [Hz]

        def write_reg(adr, val):
            yield afr.addr.eq(adr)
            yield afr.value.eq(val)
            yield afr.strobe.eq(1)
            yield
            yield afr.strobe.eq(0)
            yield

        def tb_sync():
            yield from write_reg(0, 0x4)  # UART clock divider
            yield from write_reg(1, 0x100)  # Measurement period counter
            for i in range(128):
                yield

        def tb_async():
            while True:
                yield Delay(1 / f_test / 2)
                yield afr.samplee.eq(~afr.samplee)

        sim.add_sync_process(tb_sync)
        sim.add_process(tb_async)

        with sim.write_vcd(fn + ".vcd", fn + ".gtkw"):
            sim.run_until(100e-6)

    if args.action == "generate":
        from nmigen.back import verilog

        afr = ASICFreak(10e6)
        with open(fn + '.v', 'w') as f:
            f.write(verilog.convert(afr, ports=afr.ports()))
