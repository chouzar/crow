import crow/coordinate.{Coordinate}

// · No Move
pub const hold = Coordinate(0, 0)

// ↑ Up projection
pub const up = Coordinate(0, 1)

// → Right projection
pub const right = Coordinate(1, 0)

// ↓ Down projection
pub const down = Coordinate(0, -1)

// ← Left projection
pub const left = Coordinate(-1, 0)

// ↗ Top Right projection
pub const top_right = Coordinate(1, 1)

// ↘ Bottom Right projection
pub const bottom_right = Coordinate(1, -1)

// ↙ Bottom Left projection
pub const bottom_left = Coordinate(-1, -1)

// ↖ Top Left projection
pub const top_left = Coordinate(-1, 1)

// ↑→ Top Right jump
// ↑  
pub const top_right_jump = Coordinate(1, 2)

//  ↑ Right Top jump
// →→ 
pub const right_top_jump = Coordinate(2, 1)

// →→ Right Bottom jump
//  ↓ 
pub const top_bottom_jump = Coordinate(2, -1)

// ↓  Bottom Right jump
// ↓→ 
pub const bottom_right_jump = Coordinate(1, -2)

//  ↓ Bottom Left jump
// ←↓ 
pub const bottom_left_jump = Coordinate(-1, -2)

// ←← Left Bottom jump
// ↓ 
pub const left_bottom_jump = Coordinate(-2, -1)

// ↑
// ←← Left Top jump
pub const left_top_jump = Coordinate(-2, 1)

// ←↑
//  ↑ Top Left jump
pub const top_left_jump = Coordinate(-1, 2)
