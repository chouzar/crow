import crow/coordinate.{Coordinate}

pub fn add_test() {
  assert Coordinate(x: 10, y: 10) =
    coordinate.add(Coordinate(x: 3, y: 7), Coordinate(x: 7, y: 3))

  assert Coordinate(x: 4, y: -4) =
    coordinate.add(Coordinate(x: -3, y: -7), Coordinate(x: 7, y: 3))

  assert Coordinate(x: 48, y: 24) =
    coordinate.add(Coordinate(x: 36, y: 87), Coordinate(x: 12, y: -63))
}

pub fn equal_test() {
  assert True = coordinate.equal(Coordinate(1, 1), Coordinate(1, 1))
  assert False = coordinate.equal(Coordinate(1, 1), Coordinate(1, 0))
  assert False = coordinate.equal(Coordinate(1, 1), Coordinate(0, 1))
  assert False = coordinate.equal(Coordinate(1, 0), Coordinate(1, 1))
  assert False = coordinate.equal(Coordinate(0, 1), Coordinate(1, 1))
}
