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

method set-pixel($x, $y) {
    # should try something else at some point
    my $new-x = $x;
    my $new-y = $y;
    if ($x >  $!cols) {
        $new-x = $x - $!cols;
    }
    elsif ($x < 0) {
        $new-x = $x + $!cols;
    }

    if ($y > $!rows) {
        $new-y = $y - $!rows;
    }
    elsif ($y < 0) {
        $new-y =  $y + $!rows;
    }

    my $pixel-loc = $new-x + $new-y * $!cols;
    say "pixel loc: ", $pixel-loc;
    @!display[$pixel-loc] +^= 1;
    say "OK ", $pixel-loc;
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
