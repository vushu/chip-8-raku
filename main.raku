use lib 'lib';
use Chip8;

sub MAIN() {
    my $chip8 = Chip8.new;
    say "chip 8 running";
    say $chip8.memory.elems;

}

