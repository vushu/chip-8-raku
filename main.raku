use lib 'lib';
use Chip8;

sub MAIN($rom) {
    my $chip8 = Chip8.new;
    $chip8.run($rom);

}

