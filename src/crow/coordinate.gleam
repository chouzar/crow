pub type Coordinate {
  Coordinate(x: Int, y: Int)
}

pub fn equal(coordinate_a: Coordinate, coordinate_b: Coordinate) -> Bool {
  let Coordinate(x: xa, y: ya) = coordinate_a
  let Coordinate(x: xb, y: yb) = coordinate_b

  xa == xb && ya == yb
}

pub fn add(m: Coordinate, n: Coordinate) -> Coordinate {
  let Coordinate(x: xa, y: ya) = m
  let Coordinate(x: xb, y: yb) = n

  Coordinate(x: xa + xb, y: ya + yb)
}

pub fn substract(m: Coordinate, n: Coordinate) -> Coordinate {
  let Coordinate(x: xa, y: ya) = m
  let Coordinate(x: xb, y: yb) = n

  Coordinate(x: xa - xb, y: ya - yb)
}

pub fn multiply(m: Coordinate, n: Coordinate) -> Coordinate {
  Coordinate(x: m.x * n.x, y: m.y * n.y)
}
