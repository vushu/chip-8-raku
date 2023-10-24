unit class Renderer;
use Raylib::Bindings;

has Int $!cols;
has Int $!rows;
has $!scale;
has $!width;
has $!height;
has @!display of UInt = [0 xx $!cols * $!rows];
has $!bg-color;
has $!pixel-color;
has $!pixel-width;

submethod BUILD (:$scale) {
    $!scale = $scale;
    $!cols = 64;
    $!rows = 32;
    say "Scale is: ", $!scale;
    say "Cols is: ", $!cols;
    $!width = $!scale * $!cols;
    $!height = $!scale * $!rows;

    say "Width: ", $!width;
    say "Height: ", $!height;
    @!display = [0 xx $!cols * $!rows];
    # @!display[0] = 1;
    # @!display[64] = 1;
    $!bg-color = Color.init(0,0,0, 0xFF);
    # $!pixel-color = Color.init(230, 41, 55, 255);
    $!pixel-color = init-darkgreen;
    $!pixel-width = $!width / $!cols;

}

method new($scale) {
    self.bless(:$scale);
}

method set-pixel(uint8 $x, uint8 $y) {
    # should try something else at some point
    if ($x >  $!cols) {
        $x -= $!cols;
    }
    elsif ($x < 0) {
        $x += $!cols;
    }

    if ($y > $!rows) {
        $y -= $!rows;
    }
    elsif ($y < 0) {
        $y += $!rows;
    }

    my $pixel-loc = $x + $y * $!cols;
    say "pixel ", $pixel-loc;
    @!display[$pixel-loc] +^= 1;
    return @!display[$pixel-loc] eq 0;
}

method clear {
    @!display = [0 xx $!cols * $!rows];
}

method init() {
    set-target-fps(60);
    init-window($!width, $!height, "Chip-8 in raku");
}

method render {
    begin-drawing;
    clear-background($!bg-color);
    for @!display.kv -> $index, $draw {
        if $draw {
            my $y-idx= ($index / $!cols).Int;
            my $x-idx= ($index % $!cols).Int;
            draw-rectangle($!scale.Int * $x-idx, $!scale.Int * $y-idx, $!pixel-width.Int, $!pixel-width.Int, $!pixel-color);
        }
    }

    draw-fps(10,10);
    end-drawing;
}
