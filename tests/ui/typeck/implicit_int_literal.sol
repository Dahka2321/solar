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

    // === Negative literals to int ===
    // Negative literals can only coerce to signed int types.
    // Same conservative rule: int_literal[N] can only coerce to int types with > N bytes.
    // E.g., -1 is int_literal[1] negative, can only coerce to int16+, not int8.
    
    // int_literal[1] negative -> int16+ works
    int16 neg_1_i16 = -1;
    int16 neg_128_i16 = -128;
    int256 neg_1_i256 = -1;
    
    // int_literal[2] negative -> int32+ works  
    int32 neg_129_i32 = -129;
    int32 neg_32768_i32 = -32768;
    
    // Overflow cases: int_literal[1] negative cannot coerce to int8
    int8 neg_1_i8 = -1; //~ ERROR: mismatched types
    int8 neg_128_i8 = -128; //~ ERROR: mismatched types
    
    // Overflow: int_literal[2] negative cannot coerce to int16
    int16 neg_32768_i16 = -32768; //~ ERROR: mismatched types
    
    // Negative literals cannot coerce to unsigned types
    uint8 neg_to_uint8 = -1; //~ ERROR: mismatched types
    uint256 neg_to_uint256 = -42; //~ ERROR: mismatched types

    // === Edge cases: parenthesized and compound expressions ===
    // Parentheses don't change the semantics - still a negative literal
    int16 paren_neg = -(1);
    int16 double_paren_neg = -((1));
    
    // Double negation: negates a negative literal, result is non-negative
    // -(-1) = 1, which is int_literal[1] non-negative
    int16 double_neg = -(-1);
    
    // Negation of binary expressions - binary ops on int literals are now
    // evaluated during type checking to preserve the literal type
    int16 neg_binop = -(1 + 2);
    
    // More complex expressions with literals
    int16 complex_lit = -(2 * 3 + 1);
    int32 large_lit = -(256 + 1);  // Result is -257, int_literal[2]
}
