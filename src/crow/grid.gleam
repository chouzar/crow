import gleam/map.{Map}
import crow/coordinate.{Coordinate}

pub opaque type Grid(content) {
  Grid(limits: Limits, positions: Map(Coordinate, content))
}

pub type Limits {
  Limits(x: Coordinate, y: Coordinate)
}

pub type Error {
  NegativeInitialization
  OutOfBounds
  NoContent
}

pub fn new(x: Int, y: Int) -> Result(Grid(h), Error) {
  case x, y {
    x, y if x > 0 && y > 0 -> {
      let limits = Limits(x: Coordinate(x: 1, y: 1), y: Coordinate(x: x, y: y))
      Ok(Grid(limits: limits, positions: map.new()))
    }

    _, _ -> Error(NegativeInitialization)
  }
}

pub fn set(
  in grid: Grid(h),
  at position: Coordinate,
  value value: h,
) -> Result(Grid(h), Error) {
  try position = in_bounds(grid, position)
  let positions = map.insert(grid.positions, position, value)
  Ok(Grid(..grid, positions: positions))
}

pub fn retrieve(in grid: Grid(h), at position: Coordinate) -> Result(h, Error) {
  try position = in_bounds(grid, position)

  case map.get(grid.positions, position) {
    Ok(content) -> Ok(content)
    Error(Nil) -> Error(NoContent)
  }
}

pub fn update(
  in grid: Grid(h),
  at from: Coordinate,
  to to: Coordinate,
) -> Result(Grid(h), Error) {
  try content = retrieve(grid, from)
  let grid = delete(grid, from)
  try grid = set(grid, to, content)
  Ok(grid)
}

fn delete(in grid: Grid(h), at position: Coordinate) -> Grid(h) {
  let positions = map.delete(grid.positions, position)
  Grid(..grid, positions: positions)
}

pub fn in_bounds(
  in grid: Grid(h),
  at position: Coordinate,
) -> Result(Coordinate, Error) {
  let Grid(limits: limits, ..) = grid
  let in_x = limits.x.x <= position.x && limits.y.x >= position.x
  let in_y = limits.x.y <= position.y && limits.y.y >= position.y

  case in_x && in_y {
    True -> Ok(position)
    False -> Error(OutOfBounds)
  }
}
