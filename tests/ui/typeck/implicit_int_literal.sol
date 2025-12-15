//@compile-flags: -Ztypeck
function f() {
    // === Non-negative literals to uint ===
    // Value must fit in the unsigned range [0, 2^N - 1]
    uint8 u8_max = 255;
    uint8 u8_overflow = 256; //~ ERROR: mismatched types
    uint16 u16_max = 65535;
    uint16 u16_overflow = 65536; //~ ERROR: mismatched types
    uint32 u32_max = 4294967295;
    uint256 u256_max = 115792089237316195423570985008687907853269984665640564039457584007913129639935;

    // === Non-negative literals to int ===
    // Due to TypeSize storing ceil(bit_len/8), literals are grouped by byte size.
    // int_literal[N] can safely coerce to int types with more than N bytes.
    // This is conservative: e.g., 127 is int_literal[1] and can't coerce to int8,
    // even though 127 fits in int8's range [-128, 127].
    
    // int_literal[1] (0-255) -> int16+ works
    int16 i16_from_small = 127;
    int16 i16_from_255 = 255;
    
    // int_literal[2] (256-65535) -> int32+ works
    int32 i32_from_256 = 256;
    int32 i32_from_65535 = 65535;
    
    // Overflow cases
    int16 i16_overflow = 65536; //~ ERROR: mismatched types

    // === Zero and small values ===
    // Zero and 1 are int_literal[1], so they work with uint8+ and int16+
    uint8 zero_u8 = 0;
    uint256 zero_u256 = 0;
    uint8 one_u8 = 1;
    uint256 one_u256 = 1;
    
    int16 zero_i16 = 0;
    int256 zero_i256 = 0;
    int16 one_i16 = 1;
    int256 one_i256 = 1;
}
