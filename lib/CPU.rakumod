unit class CPU;
use Renderer;
use Keyboard;
use Raylib::Bindings;

# Memory
has buf8 $.memory .= new(0 xx 4096);

# Registers
has buf8 $.v .= new(0 xx 16); # Register

# Timers
has $!delay-timer = 0;
has $!sound-timer = 0;

# Program counter. Stores the currently executing address.
# Program starts at posiston 0x200
has uint16 $!pc = 0x200;

# has uint16 $!sp = 0;
# Stores memory addresses
has uint16 $!i = 0; 

has buf16 $!stack .= new(0 xx 16);

has $!paused = False;

has $.speed = 10;

has Renderer $!renderer .= new(20);
has Keyboard $!keyboard .= new;

method load-sprites-into-memory() {
    # Array of hex values for each sprite. Each sprite is 5 bytes.
    # The technical reference provides us with each one of these values.
    my uint8 @sprites = ( 
        0xF0, 0x90, 0x90, 0x90, 0xF0, # 0
        0x20, 0x60, 0x20, 0x20, 0x70, # 1
        0xF0, 0x10, 0xF0, 0x80, 0xF0, # 2
        0xF0, 0x10, 0xF0, 0x10, 0xF0, # 3
        0x90, 0x90, 0xF0, 0x10, 0x10, # 4
        0xF0, 0x80, 0xF0, 0x10, 0xF0, # 5
        0xF0, 0x80, 0xF0, 0x90, 0xF0, # 6
        0xF0, 0x10, 0x20, 0x40, 0x40, # 7
        0xF0, 0x90, 0xF0, 0x90, 0xF0, # 8
        0xF0, 0x90, 0xF0, 0x10, 0xF0, # 9
        0xF0, 0x90, 0xF0, 0x90, 0x90, # A
        0xE0, 0x90, 0xE0, 0x90, 0xE0, # B
        0xF0, 0x80, 0x80, 0x80, 0xF0, # C
        0xE0, 0x90, 0x90, 0x90, 0xE0, # D
        0xF0, 0x80, 0xF0, 0x80, 0xF0, # E
        0xF0, 0x80, 0xF0, 0x80, 0x80  # F
    );

    for @sprites.kv -> $index, $item {
        # say $item.WHAT;
        $.memory[$index] = $item;
    }
}

method load-program-into-memory($program) {
    for $program.list.kv -> $index, $byte {
        $.memory[0x200 + $index] = $byte;
    }
}

method emulate {
    $!renderer.init;
    while (!window-should-close) {
        for 0..16 -> $_ {
            if !$!paused {
                my $opcode = $.memory[$!pc] +< 8 +| $.memory[$!pc + 1];
                self.execute-instruction($opcode);
            }
            else {
                say "Currently paused push any button";
                my $found = $!keyboard.any-key-down;
                if $found {
                    my $opcode = $.memory[$!pc] +< 8 +| $.memory[$!pc + 1];
                    my $x = ($opcode +& 0x0F00) +> 8;

                    # say "Unpausing! ", $found.WHAT;
                    $.v[$x] = $found.Int;
                    $!paused = False;
                }

            }
        }
        if (!$!paused) {
            self.update-timers;
        }

        $!renderer.render;
    }
    close-window;
}

method run-renderer {
    $!renderer.render;
}

method execute-instruction($opcode) {
    $!pc += 2;

    my $x = ($opcode +& 0x0F00) +> 8;
    my $y = ($opcode +& 0x00F0) +> 4;

    given $opcode +& 0xF000 {
        say "0xF000";
        when 0x0000 {
            given $opcode {
                when 0x00E0 {
                    say "CLEARING";
                    $!renderer.clear;
                }
                when 0x00EE {
                    say "pop stack";
                    $!pc= $!stack.pop;
                }
            }
        }
        when 0x1000 { 
            # say "opcode 1 JP";
            say "0x1000";
            $!pc = ($opcode +& 0xFFF);
        }
        when 0x2000 { say "opcode 2";
            $!stack.push($!pc);
            $!pc = ($opcode +& 0xFFF);
        }
        when 0x3000 { 
            say "opcode 3 "; 
            if $.v[$x] eq ($opcode +& 0xFF) {
                $!pc += 2;
            }
        }
        when 0x4000 { 
            say "opcode 4"; 
            if $.v[$x] ne ($opcode +& 0xFF) {
                $!pc += 2;
            }
        }
        when 0x5000 { 
            say "opcode 5";
            if $.v[$x] eq $.v[$y] {
                $!pc += 2;
            }
        }
        when 0x6000 { 
            say "opcode 6";
            $.v[$x] = ($opcode +& 0xFF);
        }
        when 0x7000 { 
            say "opcode 7";
            $.v[$x] += ($opcode +& 0xFF);
        }
        when 0x8000 { 
            say "opcode 8";
            given $opcode +& 0xF {
                when 0x0 {
                    $.v[$x] = $.v[$y];
                }
                when 0x1 {
                    $.v[$x] +|= $.v[$y];
                }
                when 0x2 {
                    $.v[$x] +&= $.v[$y];
                }
                when 0x3 {
                    $.v[$x] +^= $.v[$y];
                }
                when 0x4 {
                    my $sum = $.v[$x] + $.v[$y];
                    $.v[0xF] = 0;
                    if $sum > 0xFF {
                        $.v[0xF] = 1;
                    }

                    # taking only the 8 lowest bits
                    # $.v[$x] = $sum +& 0xFF;
                    $.v[$x] = $sum;
                }
                when 0x5 {
                    $.v[0xF] = $.v[$x] > $.v[$y] ?? 1 !! 0;
                    $.v[$x] -= $.v[$y];
                }
                when 0x6 {
                    $.v[0xF] = $.v[$x] +& 0x1;
                    $.v[$x] +>= 1;
                }
                when 0x7 {
                    $.v[0xF] = $.v[$y] > $.v[$x] ?? 1 !! 0;
                    $.v[$x] = $.v[$y] - $.v[$x];

                }
                when 0xE {
                    $.v[0xF]  = $.v[$x] +& 0x80;
                    $.v[$x] +<= 1;
                }
            }
        }
        when 0x9000 { say "opcode 9";
            $!pc += 2 if $.v[$x] ne $.v[$y];
        }
        when 0xA000 { say "opcode A";
            $!i = ($opcode +& 0xFFF);
        }
        when 0xB000 { say "opcode B";
            $!pc = ($opcode +& 0xFFF) + $.v[0];
        }
        when 0xC000 { say "opcode C";
            my $rand = (0..255).rand;
            $.v[$x] = $rand +& ($opcode +& 0xFF);
        }
        when 0xD000 { say "opcode D DRAW STUFF";
            my $width = 8;
            my $height = ($opcode +& 0xF);

            $.v[0xF] = 0;
            for 0..$height-1 -> $row {
                my $sprite = $.memory[$!i + $row];
                for 0..$width-1 -> $col {

                    if ($sprite +& 0x80) > 0 {
                        # if set-pixep return 1, which means a pixel was erased 
                        # set VF to 1
                        if ($!renderer.set-pixel($.v[$x] + $col, $.v[$y] + $row)) {
                            $.v[0xF] = 1;
                        }
                    }
                    $sprite +<= 1;
                }
            }
        }
        when 0xE000 { 
            say "0xE000";
            given $opcode +& 0xFF {
                when 0x9E {
                    if $!keyboard.is-key-pressed($.v[$x]) {
                        $!pc += 2;
                    }
                }
                when 0xA1 { 
                    if !$!keyboard.is-key-pressed($.v[$x]) {
                        $!pc += 2;
                    }
                }
            }
        }
        when 0xF000 { 
            say "OPCode: F";
            given $opcode +& 0xFF {
                when 0x07 {
                    $.v[$x] = $!delay-timer;
                }
                when 0x0A {
                    $!paused = True;
                }
                when 0x15 {
                    $!delay-timer = $.v[$x];
                }
                when 0x18 {
                    $!sound-timer = $.v[$x];
                }
                when 0x1E {
                    $!i += $.v[$x];
                }
                when 0x29 {
                    $!i = $.v[$x] * 5;
                }
                when 0x33 {
                    say "0x33";
                    $.memory[$!i] = ($.v[$x] / 100).Int;

                    $.memory[$!i + 1] = (($.v[$x] % 100) / 10).Int;
                    $.memory[$!i + 2] = ($.v[$x] % 10).Int;

                }
                when 0x55 {
                    for 0..$x -> $register-index {
                        $.memory[$!i + $register-index] = $.v[$register-index];
                    }
                }
                when 0x65 {
                    for 0..$x -> $register-index {
                        $.v[$register-index] = $.memory[$!i + $register-index];
                    }

                }
            }
        }
        default { die "Unknown opcode $opcode"; }
    }
}

method update-timers {
    $!delay-timer -= 1 if $!delay-timer > 0;
    $!sound-timer -= 1 if $!sound-timer > 0;
}