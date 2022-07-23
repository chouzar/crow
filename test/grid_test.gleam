import crow/coordinate.{Coordinate}
import crow/grid.{NegativeInitialization, NoContent, OutOfBounds}

pub fn new_test() {
  assert Ok(_) = grid.new(3, 3)
  assert Error(NegativeInitialization) = grid.new(0, 1)
  assert Error(NegativeInitialization) = grid.new(1, -1)
}

pub fn set_test() {
  assert Ok(grid) = grid.new(3, 3)

  assert Ok(grid) = grid.set(grid, Coordinate(1, 2), "X")
  assert Error(OutOfBounds) = grid.set(grid, Coordinate(0, 4), "X")
}

pub fn retrieve_test() {
  assert Ok(grid) = grid.new(3, 3)

  assert Ok(grid) = grid.set(grid, Coordinate(1, 2), "X")
  assert Ok(grid) = grid.set(grid, Coordinate(2, 3), "Y")
  assert Ok(grid) = grid.set(grid, Coordinate(3, 1), "Z")

  assert Ok("X") = grid.retrieve(grid, Coordinate(1, 2))
  assert Ok("Y") = grid.retrieve(grid, Coordinate(2, 3))
  assert Ok("Z") = grid.retrieve(grid, Coordinate(3, 1))
  assert Error(NoContent) = grid.retrieve(grid, Coordinate(3, 3))
  assert Error(OutOfBounds) = grid.retrieve(grid, Coordinate(0, 4))
}

pub fn update_test() {
  assert Ok(grid) = grid.new(3, 3)
  assert Ok(grid) = grid.set(grid, Coordinate(1, 2), "X")

  assert Ok(grid) = grid.update(grid, Coordinate(1, 2), Coordinate(2, 3))
  assert Ok(grid) = grid.update(grid, Coordinate(2, 3), Coordinate(3, 1))
  assert Error(OutOfBounds) =
    grid.update(grid, Coordinate(3, 1), Coordinate(4, 0))
  assert Error(NoContent) =
    grid.update(grid, Coordinate(1, 3), Coordinate(1, 2))
}

pub fn in_bounds_test() {
  assert Ok(grid) = grid.new(3, 3)

  assert Ok(Coordinate(1, 1)) = grid.in_bounds(grid, Coordinate(1, 1))
  assert Error(OutOfBounds) = grid.in_bounds(grid, Coordinate(0, 1))
  assert Error(OutOfBounds) = grid.in_bounds(grid, Coordinate(1, 4))
}
