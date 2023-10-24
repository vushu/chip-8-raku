unit class Keyboard;
use Raylib::Bindings;

has %.keys = 
    0x1 => KEY_ONE,
    0x2 => KEY_TWO,
    0x3 => KEY_THREE,
    0xC => KEY_FOUR,
    0x4 => KEY_Q,
    0x5 => KEY_W,
    0x6 => KEY_E,
    0x7 => KEY_A,
    0x8 => KEY_S,
    0x9 => KEY_D,
    0xE => KEY_F,
    0xA => KEY_Z,
    0x0 => KEY_X,
    0xB => KEY_C,
    0xF => KEY_V;

has %.reversed-keys;

method TWEAK {
    for %.keys.kv -> $key, $value {
        %.reversed-keys{$value} = $key;
    }
}
method is-key-pressed($key-code) {
    is-key-down(%.keys{$key-code});
}

method any-key-down() {
    my $pressed-key = get-key-pressed;
    %.reversed-keys{KeyboardKey($pressed-key)};

    # say "FOUND: " , $found-key;
    # is-key-down($found-key);
}