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
    #Chip-8 has 64x32 pixels
    $!cols = 64;
    $!rows = 32;
    # Window size
    $!width = $!scale * $!cols;
    $!height = $!scale * $!rows;

    # Display to be rendered
    @!display = [0 xx $!cols * $!rows];

    $!bg-color = Color.init(0,0,0, 0xFF);

    $!pixel-color = init-darkgreen;

}

method new($scale) {
    self.bless(:$scale);
}

method set-pixel($x, $y) {
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
            draw-rectangle($!scale.Int * $x-idx, $!scale.Int * $y-idx, $!scale.Int, $!scale.Int, $!pixel-color);
        }
    }

    draw-fps(10,10);
    end-drawing;
}
