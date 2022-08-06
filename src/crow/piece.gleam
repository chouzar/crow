import gleam/int
import gleam/list
import gleam/set
import gleam/order.{Eq, Gt, Lt}
import crow/grid.{Grid, NoContent}
import crow/coordinate.{Coordinate}
import crow/rule.{Rule}
import crow/trace.{Trace}
import crow/projection.{Projection, Stop}
import crow/direction as dir

pub type Piece(set) {
  Piece(class: Class, set: set)
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
  in board: Grid(Piece(set)),
  from from: Coordinate,
  to to: Coordinate,
) -> Grid(Piece(set)) {
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
  board: Grid(Piece(set)),
  from: Coordinate,
) -> List(Projection(Blocked)) {
  assert Ok(piece) = grid.retrieve(in: board, at: from)

  case piece {
    Piece(Pawn, set) -> project_pawn(board, from, set)
    Piece(Rook, set) -> project_rook(board, from, set)
    Piece(Bishop, set) -> project_bishop(board, from, set)
    Piece(Knight, set) -> project_knight(board, from, set)
    Piece(Queen, set) -> project_queen(board, from, set)
    Piece(King, set) -> project_king(board, from, set)
  }
}

pub fn project_pawn(
  board: Grid(Piece(set)),
  from: Coordinate,
  set: set,
) -> List(Projection(Blocked)) {
  let n = case from {
    Coordinate(_, 1) | Coordinate(_, 2) -> 2

    Coordinate(_, _) -> 1
  }

  let constaints =
    in_steps(Limited(n))
    |> rule.then(in_bounds(board))
    |> rule.then(is_blocked_by_friendly(board, set))
    |> rule.then(is_blocked_by_rival(board, set))

  let capture_constaints =
    in_steps(Limited(1))
    |> rule.then(in_bounds(board))
    |> rule.then(is_blocked_by_friendly(board, set))
    |> rule.then(capture(board, set))

  [
    projection.project(from, dir.up, constaints),
    projection.project(from, dir.top_right, capture_constaints),
    projection.project(from, dir.top_left, capture_constaints),
  ]
}

pub fn project_rook_test(
  board: Grid(Piece(set)),
  from: Coordinate,
  set: set,
) -> List(Projection(Blocked)) {
  let constraints =
    in_steps(Continuous)
    |> rule.then(in_bounds(board))
    |> rule.then(is_blocked_by_friendly(board, set))
    |> rule.then(capture(board, set))

  [
    projection.project(from, dir.up, constraints),
    projection.project(from, dir.right, constraints),
    projection.project(from, dir.down, constraints),
    projection.project(from, dir.left, constraints),
  ]
}

pub fn project_rook(
  board: Grid(Piece(set)),
  from: Coordinate,
  set: set,
) -> List(Projection(Blocked)) {
  let constraints =
    in_steps(Continuous)
    |> rule.then(in_bounds(board))
    |> rule.then(is_blocked_by_friendly(board, set))
    |> rule.then(capture(board, set))

  [
    projection.project(from, dir.up, constraints),
    projection.project(from, dir.right, constraints),
    projection.project(from, dir.down, constraints),
    projection.project(from, dir.left, constraints),
  ]
}

pub fn project_bishop(
  board: Grid(Piece(set)),
  from: Coordinate,
  set: set,
) -> List(Projection(Blocked)) {
  let constraints =
    in_steps(Continuous)
    |> rule.then(in_bounds(board))
    |> rule.then(is_blocked_by_friendly(board, set))
    |> rule.then(capture(board, set))

  [
    projection.project(from, dir.top_right, constraints),
    projection.project(from, dir.bottom_right, constraints),
    projection.project(from, dir.bottom_left, constraints),
    projection.project(from, dir.top_left, constraints),
  ]
}

pub fn project_knight(
  board: Grid(Piece(set)),
  from: Coordinate,
  set: set,
) -> List(Projection(Blocked)) {
  let constraints =
    in_steps(Limited(1))
    |> rule.then(in_bounds(board))
    |> rule.then(is_blocked_by_friendly(board, set))
    |> rule.then(capture(board, set))

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
  board: Grid(Piece(set)),
  from: Coordinate,
  set: set,
) -> List(Projection(Blocked)) {
  let constraints =
    in_steps(Continuous)
    |> rule.then(in_bounds(board))
    |> rule.then(is_blocked_by_friendly(board, set))
    |> rule.then(capture(board, set))

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
  board: Grid(Piece(set)),
  from: Coordinate,
  set: set,
) -> List(Projection(Blocked)) {
  let constraints =
    in_steps(Limited(1))
    |> rule.then(in_bounds(board))
    |> rule.then(is_blocked_by_friendly(board, set))
    |> rule.then(capture(board, set))

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

fn in_bounds(board: Grid(Piece(set))) -> Rule(Trace, Stop(Blocked)) {
  rule.new(fn(current_trace) {
    case grid.in_bounds(board, trace.get_position(current_trace)) {
      Ok(_) -> projection.continue(current_trace)
      Error(_) -> projection.stop(OutOfBounds)
    }
  })
}

fn in_steps(move_limit: MoveLimit) -> Rule(Trace, Stop(Blocked)) {
  rule.new(fn(current_trace) {
    case move_limit {
      Continuous -> projection.continue(current_trace)

      Limited(n: steps) ->
        case int.compare(steps, trace.get_step(current_trace)) {
          Gt -> projection.continue(current_trace)
          Eq -> projection.continue(current_trace)
          Lt -> projection.stop(StepLimit)
        }
    }
  })
}

fn is_blocked_by_friendly(
  board: Grid(Piece(set)),
  friendly: set,
) -> Rule(Trace, Stop(Blocked)) {
  rule.new(fn(current_trace) {
    case grid.retrieve(board, trace.get_position(current_trace)) {
      Ok(Piece(set: set, ..)) if set == friendly ->
        projection.stop(FriendlyPiece)
      Ok(Piece(..)) -> projection.continue(current_trace)
      Error(NoContent) -> projection.continue(current_trace)
    }
  })
}

fn is_blocked_by_rival(
  board: Grid(Piece(set)),
  friendly: set,
) -> Rule(Trace, Stop(Blocked)) {
  rule.new(fn(current_trace) {
    case grid.retrieve(board, trace.get_position(current_trace)) {
      Ok(Piece(set: set, ..)) if set != friendly -> projection.stop(RivalPiece)
      Ok(Piece(..)) -> projection.continue(current_trace)
      Error(NoContent) -> projection.continue(current_trace)
    }
  })
}

fn capture(board: Grid(Piece(set)), friendly: set) -> Rule(Trace, Stop(Blocked)) {
  rule.new(fn(current_trace) {
    case grid.retrieve(board, trace.get_position(current_trace)) {
      Ok(Piece(set: set, ..)) if set != friendly -> projection.next(Capture)
      Ok(Piece(..)) -> projection.continue(current_trace)
      Error(NoContent) -> projection.continue(current_trace)
    }
  })
}
