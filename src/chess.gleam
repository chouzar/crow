// Runtime
// TODO: Later, there should be a function for a session that is being filled with players.
// TODO: For a GUI system, there should be a way to compose comands by tracking player's input.
// TODO: Should a transcript of the game be stored? How long?
//
// Logic
// TODO: Work on message fields for errors and warnings.
// TODO: Booleans are unnecessary for the check field, could be represented by a list of coordinates.
// TODO: Optimize some of the data-structures to cache information being retrieved over and over.
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
import crow/space.{Space}
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
    stage: Stage,
    board: Grid(Space),
    turn: Int,
    check: Map(Player, Bool),
    mate: Option(Player),
    message: String,
  )
}

pub type MoveError {
  NoPath
  EmptySpace
}

pub fn setup(p1: String, p2: String) -> GameState {
  GameState(
    players: players.new([Player(p1), Player(p2)]),
    stage: Setup,
    board: setup_board(Player(p1), Player(p2)),
    turn: 0,
    check: map.from_list([#(Player(p1), False), #(Player(p2), False)]),
    mate: None,
    message: "",
  )
}

pub fn start(state: GameState) -> GameState {
  GameState(
    ..state,
    stage: Playing,
    board: calculate_paths(state.board),
    turn: next_turn(state.turn),
  )
}

pub fn next_move(
  state: GameState,
  from: Coordinate,
  to: Coordinate,
) -> GameState {
  case move(state, from, to) {
    Ok(state) ->
      state
      |> next()
      |> check()
      |> mate()

    Error(_) -> GameState(..state, message: "Error")
  }
}

pub fn move(
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

pub fn next(state: GameState) -> GameState {
  GameState(
    ..state,
    players: players.rotate(state.players),
    stage: Playing,
    board: calculate_paths(state.board),
    turn: next_turn(state.turn),
  )
}

fn setup_board(p1: Player, p2: Player) -> Grid(Space) {
  assert Ok(board) = grid.new(8, 8)

  let set = fn(board, coordinate, player, piece) {
    grid.set(
      board,
      coordinate,
      Space(player: player, path: set.new(), piece: piece),
    )
  }

  assert Ok(board) =
    Ok(board)
    |> result.then(set(_, Coordinate(1, 2), p1, Pawn))
    |> result.then(set(_, Coordinate(2, 2), p1, Pawn))
    |> result.then(set(_, Coordinate(3, 2), p1, Pawn))
    |> result.then(set(_, Coordinate(4, 2), p1, Pawn))
    |> result.then(set(_, Coordinate(5, 2), p1, Pawn))
    |> result.then(set(_, Coordinate(6, 2), p1, Pawn))
    |> result.then(set(_, Coordinate(7, 2), p1, Pawn))
    |> result.then(set(_, Coordinate(8, 2), p1, Pawn))
    |> result.then(set(_, Coordinate(1, 1), p1, Rook))
    |> result.then(set(_, Coordinate(2, 1), p1, Bishop))
    |> result.then(set(_, Coordinate(3, 1), p1, Knight))
    |> result.then(set(_, Coordinate(4, 1), p1, King))
    |> result.then(set(_, Coordinate(5, 1), p1, Queen))
    |> result.then(set(_, Coordinate(6, 1), p1, Knight))
    |> result.then(set(_, Coordinate(7, 1), p1, Bishop))
    |> result.then(set(_, Coordinate(8, 1), p1, Rook))

  assert Ok(board) =
    Ok(board)
    |> result.then(set(_, Coordinate(1, 7), p2, Pawn))
    |> result.then(set(_, Coordinate(2, 7), p2, Pawn))
    |> result.then(set(_, Coordinate(3, 7), p2, Pawn))
    |> result.then(set(_, Coordinate(4, 7), p2, Pawn))
    |> result.then(set(_, Coordinate(5, 7), p2, Pawn))
    |> result.then(set(_, Coordinate(6, 7), p2, Pawn))
    |> result.then(set(_, Coordinate(7, 7), p2, Pawn))
    |> result.then(set(_, Coordinate(8, 7), p2, Pawn))
    |> result.then(set(_, Coordinate(1, 8), p2, Rook))
    |> result.then(set(_, Coordinate(2, 8), p2, Bishop))
    |> result.then(set(_, Coordinate(3, 8), p2, Knight))
    |> result.then(set(_, Coordinate(4, 8), p2, King))
    |> result.then(set(_, Coordinate(5, 8), p2, Queen))
    |> result.then(set(_, Coordinate(6, 8), p2, Knight))
    |> result.then(set(_, Coordinate(7, 8), p2, Bishop))
    |> result.then(set(_, Coordinate(8, 8), p2, Rook))

  board
}

fn calculate_paths(board: Grid(Space)) -> Grid(Space) {
  grid.map(
    board,
    fn(coordinate, space) {
      Space(..space, path: move.project(board, coordinate))
    },
  )
}

fn next_turn(turn: Int) -> Int {
  turn + 1
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

  case set.intersection(current_player_kings, opposing_player_paths)
  |> set.size() {
    0 -> state
    _ -> GameState(..state, check: map.insert(state.check, current, True))
  }
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
