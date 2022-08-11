// Session:
// TODO: Later, there should be a function for a session that is being filled with players.
// Fill up a game session with players
// Start a game
// Track input from players
// On end game, keep the game visible for a few days
//   Store a transcript or something on a DB

import gleam/list
import gleam/set.{Set}
import gleam/map.{Map}
import gleam/result
import crow/coordinate.{Coordinate}
import crow/player.{Player}
import crow/piece.{Bishop, Blocked, King, Knight, Pawn, Piece, Queen, Rook}
import crow/grid.{Grid}
import crow/projection.{Projection}

type Board =
  Grid(Piece(String))

pub type Stage {
  Setup
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

pub fn setup(player_a: String, player_b: String) -> GameState {
  GameState(
    players: player.players([Player(player_a), Player(player_b)]),
    stage: Setup,
    board: setup_board(player_a, player_b),
    turn: 0,
  )
}

// Board representations:
//
// alias Path = Set(Coordinate)
//
// Map(Player, Map(Coordinate, Piece))
//   - An initial representation of the board without derived paths
//
// List(#(Player, Coordinate, Piece, Path))
//   - The whole game state
//   - Might be a good idea to create a record 
//   - From this is easy to map/filter/reduce
//     - Derive occupied positiosn by player Map(Player, Path)
//     - Derive available moves for a player Map(Player, Coordinate)
//

pub fn next(state: GameState) -> GameState {
  let [Player(current_player), Player(opposing_player)] = state.players

  // Calculate projections for all pieces: 
  let paths: List(#(Coordinate, Piece(String), Set(Coordinate))) =
    state.board
    |> grid.map(fn(coordinate: Coordinate, piece: Piece(String)) {
      let path =
        state.board
        |> piece.project(coordinate)
        |> piece.path()

      #(coordinate, piece, path)
    })
    |> map.values()

  let opposing_paths: Set(Coordinate) =
    paths
    |> list.filter(fn(piece_path: #(Coordinate, Piece(String), Set(Coordinate))) {
      let piece = piece_path.1
      piece.set == opposing_player
    })
    |> list.map(fn(piece_path: #(Coordinate, Piece(String), Set(Coordinate))) {
      piece_path.2
    })
    |> list.fold(set.new(), fn(paths, path) { set.intersection(paths, path) })

  // * Just a map of coordinates (piece) and its projections.
  //
  // Calculate Check:
  // * Get a set of all projected spaces for the current opposing player.
  // * Check if current player's king position intersects.
  // * ...
  //
  // Calculate Mate:
  // * ...
  // * Be lazy and just eat the king
  //
  // Make move or end game: 
  // * ...
  //
  // Next move or End game: 
  // * ...
  //
  GameState(
    ..state,
    players: player.rotate(state.players),
    stage: Playing,
    turn: state.turn + 1,
  )
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
