import gleam/result
import crow/coordinate.{Coordinate}
import crow/player.{Player}
import crow/piece.{Bishop, King, Knight, Pawn, Piece, Queen, Rook}
import crow/grid.{Grid}

type Board =
  Grid(Piece(String))

pub type Stage {
  Start
  Playing
  End
}

pub type GameState {
  GameState(
    players: List(Player(String)),
    stage: Stage,
    board: Board,
    turn: Int,
  )
}

pub fn start() -> GameState {
  // TODO: Later, there should be a function for a session that is being filled with players.
  let player_a = "azure"
  let player_b = "ivory"

  GameState(
    players: player.players([Player(player_a), Player(player_b)]),
    stage: Start,
    board: setup_board(player_a, player_b),
    turn: 0,
  )
}

pub fn next(state: GameState) -> GameState {
  // Calculate projections for all pieces: 
  // * Just a map of coordinates (piece) and its projections.
  //
  // Calculate Check:
  // * Get a set of all projected spaces for the current opposing player.
  // * Check if current player's king position intersects.
  // * ...
  //
  // Calculate Mate:
  // * ...
  //
  // Make move or end game: 
  // * ...
  //
  // Next move or End game: 
  // * ...
  //

  GameState(..state, turn: state.turn + 1, stage: Playing)
}

fn setup_board(player_a: String, player_b: String) -> Board {
  assert Ok(board) = grid.new(8, 8)

  assert Ok(board) =
    Ok(board)
    |> result.then(grid.set(_, Coordinate(1, 2), Piece(Pawn, player_a)))
    |> result.then(grid.set(_, Coordinate(2, 2), Piece(Pawn, player_a)))
    |> result.then(grid.set(_, Coordinate(3, 2), Piece(Pawn, player_a)))
    |> result.then(grid.set(_, Coordinate(4, 2), Piece(Pawn, player_a)))
    |> result.then(grid.set(_, Coordinate(5, 2), Piece(Pawn, player_a)))
    |> result.then(grid.set(_, Coordinate(6, 2), Piece(Pawn, player_a)))
    |> result.then(grid.set(_, Coordinate(7, 2), Piece(Pawn, player_a)))
    |> result.then(grid.set(_, Coordinate(8, 2), Piece(Pawn, player_a)))
    |> result.then(grid.set(_, Coordinate(1, 1), Piece(Rook, player_a)))
    |> result.then(grid.set(_, Coordinate(2, 1), Piece(Bishop, player_a)))
    |> result.then(grid.set(_, Coordinate(3, 1), Piece(Knight, player_a)))
    |> result.then(grid.set(_, Coordinate(4, 1), Piece(King, player_a)))
    |> result.then(grid.set(_, Coordinate(5, 1), Piece(Queen, player_a)))
    |> result.then(grid.set(_, Coordinate(6, 1), Piece(Knight, player_a)))
    |> result.then(grid.set(_, Coordinate(7, 1), Piece(Bishop, player_a)))
    |> result.then(grid.set(_, Coordinate(8, 1), Piece(Rook, player_a)))

  assert Ok(board) =
    Ok(board)
    |> result.then(grid.set(_, Coordinate(1, 7), Piece(Pawn, player_b)))
    |> result.then(grid.set(_, Coordinate(2, 7), Piece(Pawn, player_b)))
    |> result.then(grid.set(_, Coordinate(3, 7), Piece(Pawn, player_b)))
    |> result.then(grid.set(_, Coordinate(4, 7), Piece(Pawn, player_b)))
    |> result.then(grid.set(_, Coordinate(5, 7), Piece(Pawn, player_b)))
    |> result.then(grid.set(_, Coordinate(6, 7), Piece(Pawn, player_b)))
    |> result.then(grid.set(_, Coordinate(7, 7), Piece(Pawn, player_b)))
    |> result.then(grid.set(_, Coordinate(8, 7), Piece(Pawn, player_b)))
    |> result.then(grid.set(_, Coordinate(1, 8), Piece(Rook, player_b)))
    |> result.then(grid.set(_, Coordinate(2, 8), Piece(Bishop, player_b)))
    |> result.then(grid.set(_, Coordinate(3, 8), Piece(Knight, player_b)))
    |> result.then(grid.set(_, Coordinate(4, 8), Piece(King, player_b)))
    |> result.then(grid.set(_, Coordinate(5, 8), Piece(Queen, player_b)))
    |> result.then(grid.set(_, Coordinate(6, 8), Piece(Knight, player_b)))
    |> result.then(grid.set(_, Coordinate(7, 8), Piece(Bishop, player_b)))
    |> result.then(grid.set(_, Coordinate(8, 8), Piece(Rook, player_b)))

  board
}
