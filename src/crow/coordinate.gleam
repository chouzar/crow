pub type Coordinate {
  Coordinate(x: Int, y: Int)
}

pub fn new(x: Int, y: Int) -> Coordinate {
  Coordinate(x, y)
}

pub fn add(m: Coordinate, n: Coordinate) -> Coordinate {
  let Coordinate(x: xa, y: ya) = m
  let Coordinate(x: xb, y: yb) = n

  Coordinate(x: xa + xb, y: ya + yb)
}

pub fn equal(coordinate_a: Coordinate, coordinate_b: Coordinate) -> Bool {
  let Coordinate(x: xa, y: ya) = coordinate_a
  let Coordinate(x: xb, y: yb) = coordinate_b

  xa == xb && ya == yb
}
