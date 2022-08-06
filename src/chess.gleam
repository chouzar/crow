import gleam/result
import crow/coordinate.{Coordinate}
import crow/player.{Player}
import crow/piece.{Bishop, King, Knight, Pawn, Piece, Queen, Rook}
import crow/grid
import crow/turn.{Turn}

type Board =
  grid.Grid(Piece(String))

pub type GameState {
  GameState(players: List(Player(String)), board: Board, turn: Turn)
}

pub fn start() -> GameState {
  setup()
}

pub fn next(state: GameState) -> GameState {
  let board = move(state.board, Coordinate(6, 1), Coordinate(7, 3))
  GameState(..state, board: board)
}

// TODO: Come up with good system for interfacing with modules.
pub fn move(in board: Board, from from: Coordinate, to to: Coordinate) -> Board {
  piece.move(board, from, to)
}

fn setup() -> GameState {
  assert Ok(board) = grid.new(8, 8)
  let azure = Player("Azure")
  let ivory = Player("Ivory")

  assert Ok(board) =
    Ok(board)
    |> result.then(grid.set(_, Coordinate(1, 2), Piece(Pawn, azure)))
    |> result.then(grid.set(_, Coordinate(2, 2), Piece(Pawn, azure)))
    |> result.then(grid.set(_, Coordinate(3, 2), Piece(Pawn, azure)))
    |> result.then(grid.set(_, Coordinate(4, 2), Piece(Pawn, azure)))
    |> result.then(grid.set(_, Coordinate(5, 2), Piece(Pawn, azure)))
    |> result.then(grid.set(_, Coordinate(6, 2), Piece(Pawn, azure)))
    |> result.then(grid.set(_, Coordinate(7, 2), Piece(Pawn, azure)))
    |> result.then(grid.set(_, Coordinate(8, 2), Piece(Pawn, azure)))
    |> result.then(grid.set(_, Coordinate(1, 1), Piece(Rook, azure)))
    |> result.then(grid.set(_, Coordinate(2, 1), Piece(Bishop, azure)))
    |> result.then(grid.set(_, Coordinate(3, 1), Piece(Knight, azure)))
    |> result.then(grid.set(_, Coordinate(4, 1), Piece(King, azure)))
    |> result.then(grid.set(_, Coordinate(5, 1), Piece(Queen, azure)))
    |> result.then(grid.set(_, Coordinate(6, 1), Piece(Knight, azure)))
    |> result.then(grid.set(_, Coordinate(7, 1), Piece(Bishop, azure)))
    |> result.then(grid.set(_, Coordinate(8, 1), Piece(Rook, azure)))

  assert Ok(board) =
    Ok(board)
    |> result.then(grid.set(_, Coordinate(1, 7), Piece(Pawn, ivory)))
    |> result.then(grid.set(_, Coordinate(2, 7), Piece(Pawn, ivory)))
    |> result.then(grid.set(_, Coordinate(3, 7), Piece(Pawn, ivory)))
    |> result.then(grid.set(_, Coordinate(4, 7), Piece(Pawn, ivory)))
    |> result.then(grid.set(_, Coordinate(5, 7), Piece(Pawn, ivory)))
    |> result.then(grid.set(_, Coordinate(6, 7), Piece(Pawn, ivory)))
    |> result.then(grid.set(_, Coordinate(7, 7), Piece(Pawn, ivory)))
    |> result.then(grid.set(_, Coordinate(8, 7), Piece(Pawn, ivory)))
    |> result.then(grid.set(_, Coordinate(1, 8), Piece(Rook, ivory)))
    |> result.then(grid.set(_, Coordinate(2, 8), Piece(Bishop, ivory)))
    |> result.then(grid.set(_, Coordinate(3, 8), Piece(Knight, ivory)))
    |> result.then(grid.set(_, Coordinate(4, 8), Piece(King, ivory)))
    |> result.then(grid.set(_, Coordinate(5, 8), Piece(Queen, ivory)))
    |> result.then(grid.set(_, Coordinate(6, 8), Piece(Knight, ivory)))
    |> result.then(grid.set(_, Coordinate(7, 8), Piece(Bishop, ivory)))
    |> result.then(grid.set(_, Coordinate(8, 8), Piece(Rook, ivory)))

  GameState(
    players: player.players([azure, ivory]),
    board: board,
    turn: turn.start(),
  )
}
