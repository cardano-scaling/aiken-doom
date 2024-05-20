// These are magic numbers from DOOM source code. There, they are used for bitwise operations, so we have to convert to arithmetic operations
pub const frac_bits: Int = 65536 // 2^16 for fixed point shift (FRACBITS in DOOM)
pub const angle_to_fine_shift: Int = 524288 // 2^19 for fixed point shift (ANGLETOFINESHIFT in DOOM)
pub const angle_90: Int = 1073741824

