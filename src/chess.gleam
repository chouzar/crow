// Runtime
// TODO: Later, there should be a function for a session that is being filled with players.
// TODO: For a GUI system, there should be a way to compose comands by tracking player's input.
// TODO: Should a transcript of the game be stored? How long?
//
// Logic
// TODO: Work on message fields for errors and warnings.
// TODO: Booleans are unnecessary for the check field, could be represented by a list of coordinates.
// TODO: Optimize some of the data-structures to cache information being retrieved over and over.
// TODO: Chess move decoder/encoder.
// TODO: Much much detailed an clearer messages on errors.
// TODO: Check would be an interesting feature for all pieces, not only for king. 
// TODO: Posibly step rules now need to carry the whole gamestate
// Then that info could be stored on Space instead of Gamestate.
//
import gleam/list
import gleam/queue.{Queue}
import gleam/set.{Set}
import gleam/map.{Map}
import gleam/result
import gleam/option.{None, Option, Some}
import crow/coordinate.{Coordinate}
import crow/players.{Player}
import crow/piece.{Bishop, King, Knight, Pawn, Queen, Rook}
import crow/space.{Inverse, Normal, Space}
import crow/move
import crow/grid.{Grid}

pub type Stage {
  Setup
  Playing
  End
}

pub type GameState {
  GameState(
    players: Queue(Player),
    board: Grid(Space),
    stage: Stage,
    //transform: Map(Player, Coordinate),
    turn: Int,
    check: Map(Player, List(Coordinate)),
    mate: Option(Player),
    message: String,
  )
}

pub type MoveError {
  NoPath
  EmptySpace
}

pub fn setup(p1: String, p2: String) -> GameState {
  assert Ok(board) = grid.new(8, 8)

  let state =
    GameState(
      players: players.new([Player(p1), Player(p2)]),
      board: board,
      stage: Setup,
      turn: 0,
      check: map.from_list([#(Player(p1), []), #(Player(p2), [])]),
      mate: None,
      message: "",
    )

  state
  |> setup_pieces()
}

pub fn start(state: GameState) -> GameState {
  GameState(..state, stage: Playing)
  |> calculate_paths()
  |> add_turn()
}

pub fn next(
  state: GameState,
  from from: Coordinate,
  to to: Coordinate,
) -> GameState {
  case move(state, from, to) {
    Ok(state) ->
      // TODO: Do this in a wrapper fashion
      GameState(..state, players: players.rotate(state.players), stage: Playing)
      |> calculate_paths()
      |> add_turn()
      |> check()
      |> mate()

    Error(_error) -> GameState(..state, message: "Error")
  }
}

fn move(
  state: GameState,
  from: Coordinate,
  to: Coordinate,
) -> Result(GameState, MoveError) {
  let GameState(board: board, players: players, ..) = state
  let Grid(positions: positions, ..) = board
  let [current, _opposing] = queue.to_list(players)

  let current_player_board: Map(Coordinate, Space) =
    map.filter(positions, fn(_coordinate, space) { space.player == current })

  let result: Result(Grid(Space), MoveError) = case map.get(
    current_player_board,
    from,
  ) {
    Ok(Space(path: path, ..)) ->
      case set.contains(path, to) {
        True -> {
          assert Ok(board) = grid.update(board, from, to)
          Ok(board)
        }
        False -> Error(NoPath)
      }
    Error(Nil) -> Error(EmptySpace)
  }

  case result {
    Ok(board) -> Ok(GameState(..state, board: board))
    Error(error) -> Error(error)
  }
}

fn setup_pieces(state: GameState) -> GameState {
  let GameState(board: board, players: players, ..) = state
  let [p1, p2] = queue.to_list(players)

  assert Ok(board) =
    Ok(board)
    |> result.then(set(_, 1, 2, p1, Pawn, Normal))
    |> result.then(set(_, 2, 2, p1, Pawn, Normal))
    |> result.then(set(_, 3, 2, p1, Pawn, Normal))
    |> result.then(set(_, 4, 2, p1, Pawn, Normal))
    |> result.then(set(_, 5, 2, p1, Pawn, Normal))
    |> result.then(set(_, 6, 2, p1, Pawn, Normal))
    |> result.then(set(_, 7, 2, p1, Pawn, Normal))
    |> result.then(set(_, 8, 2, p1, Pawn, Normal))
    |> result.then(set(_, 1, 1, p1, Rook, Normal))
    |> result.then(set(_, 2, 1, p1, Knight, Normal))
    |> result.then(set(_, 3, 1, p1, Bishop, Normal))
    |> result.then(set(_, 4, 1, p1, Queen, Normal))
    |> result.then(set(_, 5, 1, p1, King, Normal))
    |> result.then(set(_, 6, 1, p1, Bishop, Normal))
    |> result.then(set(_, 7, 1, p1, Knight, Normal))
    |> result.then(set(_, 8, 1, p1, Rook, Normal))

  assert Ok(board) =
    Ok(board)
    |> result.then(set(_, 1, 7, p2, Pawn, Inverse))
    |> result.then(set(_, 2, 7, p2, Pawn, Inverse))
    |> result.then(set(_, 3, 7, p2, Pawn, Inverse))
    |> result.then(set(_, 4, 7, p2, Pawn, Inverse))
    |> result.then(set(_, 5, 7, p2, Pawn, Inverse))
    |> result.then(set(_, 6, 7, p2, Pawn, Inverse))
    |> result.then(set(_, 7, 7, p2, Pawn, Inverse))
    |> result.then(set(_, 8, 7, p2, Pawn, Inverse))
    |> result.then(set(_, 1, 8, p2, Rook, Normal))
    |> result.then(set(_, 2, 8, p2, Knight, Normal))
    |> result.then(set(_, 3, 8, p2, Bishop, Normal))
    |> result.then(set(_, 4, 8, p2, Queen, Normal))
    |> result.then(set(_, 5, 8, p2, King, Normal))
    |> result.then(set(_, 6, 8, p2, Bishop, Normal))
    |> result.then(set(_, 7, 8, p2, Knight, Normal))
    |> result.then(set(_, 8, 8, p2, Rook, Normal))

  GameState(..state, board: board)
}

pub fn set(board, x, y, player, piece, transform) {
  let space =
    Space(path: set.new(), player: player, piece: piece, transform: transform)

  grid.set(board, Coordinate(x, y), space)
}

fn calculate_paths(state: GameState) -> GameState {
  let GameState(board: board, ..) = state

  let board =
    grid.map(
      board,
      fn(coordinate, space) {
        Space(..space, path: move.project(board, coordinate))
      },
    )

  GameState(..state, board: board)
}

fn add_turn(state: GameState) -> GameState {
  GameState(..state, turn: state.turn + 1)
}

fn check(state: GameState) -> GameState {
  let GameState(board: board, players: players, ..) = state
  let Grid(positions: positions, ..) = board
  let [current, opposing] = queue.to_list(players)

  let current_player_board: Map(Coordinate, Space) =
    map.filter(positions, fn(_coordinate, space) { space.player == current })

  let opposing_player_board: Map(Coordinate, Space) =
    map.filter(positions, fn(_coordinate, space) { space.player == opposing })

  let current_player_kings: Set(Coordinate) =
    current_player_board
    |> map.filter(fn(_coordinate, space) { space.piece == King })
    |> map.keys()
    |> set.from_list()

  let opposing_player_paths: Set(Coordinate) =
    opposing_player_board
    |> map.map_values(fn(_, space) { space.path })
    |> map.values()
    |> list.fold(set.new(), set.union)

  let checks =
    set.intersection(current_player_kings, opposing_player_paths)
    |> set.to_list()

  GameState(..state, check: map.insert(state.check, current, checks))
}

fn mate(state: GameState) -> GameState {
  let GameState(board: board, players: players, ..) = state
  let Grid(positions: positions, ..) = board
  let [current, opposing] = queue.to_list(players)

  let current_player_board: Map(Coordinate, Space) =
    map.filter(positions, fn(_coordinate, space) { space.player == current })

  let current_player_kings: Int =
    current_player_board
    |> map.filter(fn(_coordinate, space) { space.piece == King })
    |> map.keys()
    |> list.length()

  case current_player_kings {
    0 -> GameState(..state, stage: End, mate: Some(opposing))
    _ -> state
  }
}
