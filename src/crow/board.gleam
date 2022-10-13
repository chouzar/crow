import crow/coordinate.{Coordinate}
import crow/player.{Player}
import crow/piece.{Piece}
import crow/board/grid.{Grid}
import crow/board/piece_path
import crow/board/check.{Check}
import gleam/result
import gleam/map.{Map}

pub opaque type Board {
  Board(grid: Grid(Check))
}

pub fn new() -> Board {
  assert Ok(grid) = grid.new(8, 8)
  Board(grid: grid)
}

pub fn deploy(
  board: Board,
  position: Coordinate,
  player: Player,
  facing: Coordinate,
  piece: Piece,
) -> Board {
  let check = check.new(player, piece, facing)

  assert Ok(grid) =
    board.grid
    |> grid.set(at: position, value: check)
    |> result.map(trace_paths)

  Board(grid: grid)
}

pub fn move(board: Board, from: Coordinate, to: Coordinate) -> Board {
  assert Ok(grid) =
    board.grid
    |> grid.update(at: from, to: to)
    |> result.map(trace_paths)

  Board(grid: grid)
}

pub fn all(board: Board) -> Map(Coordinate, Check) {
  board.grid.positions
}

pub fn get(board: Board, position: Coordinate) -> Check {
  assert Ok(check) = grid.retrieve(board.grid, position)
  check
}

// How to send the facing? Through piece_path.path function or injected through space?
// The same would happen to the other params in Check
fn trace_paths(grid: Grid(Check)) -> Grid(Check) {
  grid.map(
    grid,
    fn(coor, space) { Check(..space, paths: piece_path.path(grid, coor)) },
  )
}
