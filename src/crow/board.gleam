import crow/coordinate.{Coordinate}
import crow/player.{Player}
import crow/piece.{Piece}
import crow/board/grid.{Grid}
import crow/board/piece_path
import crow/board/check.{Check}
import crow/board/facing.{Facing}
import gleam/result
import gleam/map.{Map}

pub opaque type Board {
  Board(grid: Grid(Check), facing: Facing)
}

pub fn new() -> Board {
  assert Ok(grid) = grid.new(8, 8)
  Board(grid: grid, facing: facing.new())
}

pub fn deploy(
  board: Board,
  position: Coordinate,
  player: Player,
  piece: Piece,
) -> Board {
  let facing = facing.get(board.facing, player)

  let space = check.new(player, piece, facing)

  assert Ok(grid) =
    board.grid
    |> grid.set(at: position, value: space)
    |> result.map(trace_paths)

  Board(..board, grid: grid)
}

pub fn move(board: Board, from: Coordinate, to: Coordinate) -> Board {
  assert Ok(grid) =
    board.grid
    |> grid.update(at: from, to: to)
    |> result.map(trace_paths)

  Board(..board, grid: grid)
}

pub fn set_facing(board: Board, player: Player, direction: Coordinate) -> Board {
  let facing = facing.add(board.facing, player, direction)

  Board(..board, facing: facing)
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
