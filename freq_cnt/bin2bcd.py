from math import ceil
from nmigen import Signal, Module, Elaboratable
from nmigen.cli import main


class Bin2bcd(Elaboratable):
    def __init__(self, N_BITS=8):
        self.N_BITS = N_BITS
        self.N_DIGITS = len(str(2**N_BITS - 1))
        # self.N_DIGITS = ceil(self.N_BITS / 3)

        self.trig_in = Signal()  # pulse to start conversion of bin_in
        self.bin_in = Signal(N_BITS)

        self.trig_out = Signal()  # pulses when bcd_out is valid
        self.bcd_out = Signal(self.N_DIGITS * 4)  # 4 bits / digit

    def ports(self):
        return [self.bin_in, self.trig_in, self.trig_out, self.bcd_out]

    def elaborate(self, platform):
        ''' https://en.wikipedia.org/wiki/Double_dabble '''
        m = Module()

        count = Signal(8, reset=self.N_BITS * 2)
        scratch = Signal(self.N_BITS + self.N_DIGITS * 4)
        scratch_bcd = scratch[self.N_BITS:]

        is_running = Signal()
        is_running_ = Signal()
        m.d.sync += is_running_.eq(is_running)

        m.d.comb += [
            is_running.eq(count < self.N_BITS * 2),
            self.trig_out.eq(~is_running & is_running_),
            self.bcd_out.eq(scratch_bcd)
        ]

        with m.If(is_running):
            m.d.sync += count.eq(count + 1)

            with m.If(count[0] == 0):
                for d in range(self.N_DIGITS):
                    digit = scratch_bcd[d * 4: (d + 1) * 4]
                    with m.If(digit >= 5):
                        m.d.sync += digit.eq(digit + 3)
            with m.Else():
                m.d.sync += scratch.eq(scratch << 1)

        with m.Else():
            with m.If(self.trig_in):
                m.d.sync += scratch.eq(self.bin_in)
                m.d.sync += count.eq(0)

        return m


if __name__ == "__main__":
    fn = __file__[:-3]
    b2b = Bin2bcd(8)
    # main(b2b, ports=b2b.ports())

    from nmigen.back import verilog
    with open(fn + '.v', 'w') as f:
        f.write(verilog.convert(b2b, ports=b2b.ports()))

    from nmigen.back.pysim import Simulator
    sim = Simulator(b2b)
    sim.add_clock(1 / 25e6)

    def tb_sync():
        yield
        yield b2b.bin_in.eq(0xF3)
        yield b2b.trig_in.eq(1)
        yield
        yield b2b.trig_in.eq(0)

        for i in range(128):
            yield

    sim.add_sync_process(tb_sync)

    with sim.write_vcd(fn + '.vcd'):
        sim.run()
