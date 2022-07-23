import gleam/int
import gleam/list
import gleam/set
import gleam/order.{Eq, Gt, Lt}
import crow/grid.{Grid, NoContent}
import crow/player.{Player}
import crow/coordinate.{Coordinate}
import crow/rule.{Rule}
import crow/trace.{Trace}
import crow/projection.{Projection, Stop}
import crow/direction as dir

// TODO: Possibly player needs to live outside
pub type Piece(player) {
  Piece(class: Class, player: Player(player))
}

pub type Class {
  Pawn
  Rook
  Bishop
  Knight
  Queen
  King
}

pub type MoveLimit {
  Continuous
  Limited(n: Int)
}

pub type Blocked {
  FriendlyPiece
  RivalPiece
  OutOfBounds
  StepLimit
  Capture
}

pub fn move(
  in board: Grid(Piece(player)),
  from from: Coordinate,
  to to: Coordinate,
) -> Grid(Piece(player)) {
  let projections = project(board, from)

  let available_moves =
    projections
    |> list.map(fn(p) { trace.get_path(p.trace) })
    |> list.flatten()
    |> set.from_list()

  case set.contains(available_moves, to) {
    True -> {
      assert Ok(board) = grid.update(board, from, to)
      board
    }

    False -> board
  }
}

pub fn project(
  board: Grid(Piece(player)),
  from: Coordinate,
) -> List(Projection(Blocked)) {
  assert Ok(piece) = grid.retrieve(in: board, at: from)

  case piece {
    Piece(Pawn, player) -> project_pawn(board, from, player)
    Piece(Rook, player) -> project_rook(board, from, player)
    Piece(Bishop, player) -> project_bishop(board, from, player)
    Piece(Knight, player) -> project_knight(board, from, player)
    Piece(Queen, player) -> project_queen(board, from, player)
    Piece(King, player) -> project_king(board, from, player)
  }
}

pub fn project_pawn(
  board: Grid(Piece(player)),
  from: Coordinate,
  player: Player(player),
) -> List(Projection(Blocked)) {
  let n = case from {
    Coordinate(_, 1) | Coordinate(_, 2) -> 2

    Coordinate(_, _) -> 1
  }

  let constaints =
    in_steps(Limited(n))
    |> rule.then(in_bounds(board))
    |> rule.then(is_blocked_by_friendly(board, player))
    |> rule.then(is_blocked_by_rival(board, player))

  let capture_constaints =
    in_steps(Limited(1))
    |> rule.then(in_bounds(board))
    |> rule.then(is_blocked_by_friendly(board, player))
    |> rule.then(capture(board, player))

  [
    projection.project(from, dir.up, constaints),
    projection.project(from, dir.top_right, capture_constaints),
    projection.project(from, dir.top_left, capture_constaints),
  ]
}

pub fn project_rook_test(
  board: Grid(Piece(player)),
  from: Coordinate,
  player: Player(player),
) -> List(Projection(Blocked)) {
  let constraints =
    in_steps(Continuous)
    |> rule.then(in_bounds(board))
    |> rule.then(is_blocked_by_friendly(board, player))
    |> rule.then(capture(board, player))

  [
    projection.project(from, dir.up, constraints),
    projection.project(from, dir.right, constraints),
    projection.project(from, dir.down, constraints),
    projection.project(from, dir.left, constraints),
  ]
}

pub fn project_rook(
  board: Grid(Piece(player)),
  from: Coordinate,
  player: Player(player),
) -> List(Projection(Blocked)) {
  let constraints =
    in_steps(Continuous)
    |> rule.then(in_bounds(board))
    |> rule.then(is_blocked_by_friendly(board, player))
    |> rule.then(capture(board, player))

  [
    projection.project(from, dir.up, constraints),
    projection.project(from, dir.right, constraints),
    projection.project(from, dir.down, constraints),
    projection.project(from, dir.left, constraints),
  ]
}

pub fn project_bishop(
  board: Grid(Piece(player)),
  from: Coordinate,
  player: Player(player),
) -> List(Projection(Blocked)) {
  let constraints =
    in_steps(Continuous)
    |> rule.then(in_bounds(board))
    |> rule.then(is_blocked_by_friendly(board, player))
    |> rule.then(capture(board, player))

  [
    projection.project(from, dir.top_right, constraints),
    projection.project(from, dir.bottom_right, constraints),
    projection.project(from, dir.bottom_left, constraints),
    projection.project(from, dir.top_left, constraints),
  ]
}

pub fn project_knight(
  board: Grid(Piece(player)),
  from: Coordinate,
  player: Player(player),
) -> List(Projection(Blocked)) {
  let constraints =
    in_steps(Limited(1))
    |> rule.then(in_bounds(board))
    |> rule.then(is_blocked_by_friendly(board, player))
    |> rule.then(capture(board, player))

  [
    projection.project(from, dir.top_right_jump, constraints),
    projection.project(from, dir.right_top_jump, constraints),
    projection.project(from, dir.top_bottom_jump, constraints),
    projection.project(from, dir.bottom_right_jump, constraints),
    projection.project(from, dir.bottom_left_jump, constraints),
    projection.project(from, dir.left_bottom_jump, constraints),
    projection.project(from, dir.left_top_jump, constraints),
    projection.project(from, dir.top_left_jump, constraints),
  ]
}

pub fn project_queen(
  board: Grid(Piece(player)),
  from: Coordinate,
  player: Player(player),
) -> List(Projection(Blocked)) {
  let constraints =
    in_steps(Continuous)
    |> rule.then(in_bounds(board))
    |> rule.then(is_blocked_by_friendly(board, player))
    |> rule.then(capture(board, player))

  [
    projection.project(from, dir.up, constraints),
    projection.project(from, dir.right, constraints),
    projection.project(from, dir.down, constraints),
    projection.project(from, dir.left, constraints),
    projection.project(from, dir.top_right, constraints),
    projection.project(from, dir.bottom_right, constraints),
    projection.project(from, dir.bottom_left, constraints),
    projection.project(from, dir.top_left, constraints),
  ]
}

pub fn project_king(
  board: Grid(Piece(player)),
  from: Coordinate,
  player: Player(player),
) -> List(Projection(Blocked)) {
  let constraints =
    in_steps(Limited(1))
    |> rule.then(in_bounds(board))
    |> rule.then(is_blocked_by_friendly(board, player))
    |> rule.then(capture(board, player))

  [
    projection.project(from, dir.up, constraints),
    projection.project(from, dir.right, constraints),
    projection.project(from, dir.down, constraints),
    projection.project(from, dir.left, constraints),
    projection.project(from, dir.top_right, constraints),
    projection.project(from, dir.bottom_right, constraints),
    projection.project(from, dir.bottom_left, constraints),
    projection.project(from, dir.top_left, constraints),
  ]
}

fn in_bounds(board: Grid(Piece(player))) -> Rule(Trace, Stop(Blocked)) {
  rule.new(fn(current) {
    case grid.in_bounds(board, trace.get_position(current)) {
      Ok(_) -> projection.continue(current)
      Error(_) -> projection.stop(OutOfBounds)
    }
  })
}

fn in_steps(move_limit: MoveLimit) -> Rule(Trace, Stop(Blocked)) {
  rule.new(fn(current) {
    case move_limit {
      Continuous -> projection.continue(current)

      Limited(n: steps) ->
        case int.compare(steps, trace.get_step(current)) {
          Gt -> projection.continue(current)
          Eq -> projection.continue(current)
          Lt -> projection.stop(StepLimit)
        }
    }
  })
}

fn is_blocked_by_friendly(
  board: Grid(Piece(player)),
  player: Player(player),
) -> Rule(Trace, Stop(Blocked)) {
  rule.new(fn(current) {
    case grid.retrieve(board, trace.get_position(current)) {
      Ok(piece) ->
        case player.get_id(piece.player) == player.get_id(player) {
          False -> projection.continue(current)
          True -> projection.stop(FriendlyPiece)
        }

      Error(NoContent) -> projection.continue(current)
    }
  })
}

fn is_blocked_by_rival(
  board: Grid(Piece(player)),
  player: Player(player),
) -> Rule(Trace, Stop(Blocked)) {
  rule.new(fn(current) {
    case grid.retrieve(board, trace.get_position(current)) {
      Ok(piece) ->
        case player.get_id(piece.player) == player.get_id(player) {
          True -> projection.continue(current)
          False -> projection.stop(RivalPiece)
        }

      Error(NoContent) -> projection.continue(current)
    }
  })
}

fn capture(
  board: Grid(Piece(player)),
  player: Player(player),
) -> Rule(Trace, Stop(Blocked)) {
  rule.new(fn(current) {
    case grid.retrieve(board, trace.get_position(current)) {
      Ok(piece) ->
        case player.get_id(piece.player) == player.get_id(player) {
          True -> projection.continue(current)
          False -> projection.next(Capture)
        }

      Error(NoContent) -> projection.continue(current)
    }
  })
}
