unit class Chip8;
use Chip8::CPU;

method run($rom) {
    my $file = open $rom, :bin, :r;
    my $contents = $file.slurp;
    $file.close;
    my $cpu = CPU.new();
    $cpu.load-sprites-into-memory;
    $cpu.load-program-into-memory($contents);
    $cpu.emulate;
}