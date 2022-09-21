// TODO: Could build a higher level DSL for managing constraints that takes direction into account.
// TODO: Projections should likely just return the final paths.
// TODO: Rules module might be discarded altogether in favor of Result or by merging it with projections.

// TODO: Refactor
import gleam/int
import gleam/list
import gleam/set.{Set}
import gleam/order.{Eq, Gt, Lt}
import crow/grid.{Grid, NoContent}
import crow/coordinate.{Coordinate}
import crow/piece.{Bishop, King, Knight, Pawn, Queen, Rook}
import crow/players.{Player}
import crow/space.{Inverse, Normal, Space}
import crow/rule.{Rule}
import crow/trace.{Trace}
import crow/projection.{Projection, Stop}
import crow/direction as dir

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

pub fn project(board: Grid(Space), from: Coordinate) -> Set(Coordinate) {
  assert Ok(space) = grid.retrieve(in: board, at: from)

  let projections = case space.piece {
    Pawn -> project_pawn(board, from, space)
    Rook -> project_rook(board, from, space)
    Bishop -> project_bishop(board, from, space)
    Knight -> project_knight(board, from, space)
    Queen -> project_queen(board, from, space)
    King -> project_king(board, from, space)
  }

  path(projections)
}

fn path(projections: List(Projection(Blocked))) -> Set(Coordinate) {
  projections
  |> list.map(fn(p) { trace.path(p.trace) })
  |> list.flatten()
  |> set.from_list()
}

fn project_pawn(
  board: Grid(Space),
  from: Coordinate,
  space: Space,
) -> List(Projection(Blocked)) {
  let Space(player: Player(set), transform: transform, ..) = space

  // Transform logic is quite harcoded, matix inversion would work better 
  let n = case transform, from {
    Normal, Coordinate(_, 1) -> 2
    Normal, Coordinate(_, 2) -> 2
    Inverse, Coordinate(_, 8) -> 2
    Inverse, Coordinate(_, 7) -> 2
    _, Coordinate(_, _) -> 1
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
    |> rule.then(capture_pawn(board, set))

  let transform = case transform {
    Normal -> fn(coordinate: Coordinate) { coordinate }
    Inverse -> fn(coordinate: Coordinate) {
      coordinate.multiply(coordinate, Coordinate(1, -1))
    }
  }

  [
    projection.project(from, transform(dir.up), constaints),
    projection.project(from, transform(dir.top_right), capture_constaints),
    projection.project(from, transform(dir.top_left), capture_constaints),
  ]
}

fn project_rook(
  board: Grid(Space),
  from: Coordinate,
  space: Space,
) -> List(Projection(Blocked)) {
  let Space(player: Player(set), ..) = space

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

fn project_bishop(
  board: Grid(Space),
  from: Coordinate,
  space: Space,
) -> List(Projection(Blocked)) {
  let Space(player: Player(set), ..) = space

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

fn project_knight(
  board: Grid(Space),
  from: Coordinate,
  space: Space,
) -> List(Projection(Blocked)) {
  let Space(player: Player(set), ..) = space

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

fn project_queen(
  board: Grid(Space),
  from: Coordinate,
  space: Space,
) -> List(Projection(Blocked)) {
  let Space(player: Player(set), ..) = space

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

fn project_king(
  board: Grid(Space),
  from: Coordinate,
  space: Space,
) -> List(Projection(Blocked)) {
  let Space(player: Player(set), ..) = space

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

fn in_bounds(board: Grid(Space)) -> Rule(Trace, Stop(Blocked)) {
  rule.new(fn(current_trace) {
    case grid.in_bounds(board, trace.position(current_trace)) {
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
        case int.compare(steps, trace.step(current_trace)) {
          Gt -> projection.continue(current_trace)
          Eq -> projection.continue(current_trace)
          Lt -> projection.stop(StepLimit)
        }
    }
  })
}

fn is_blocked_by_friendly(
  board: Grid(Space),
  friendly: String,
) -> Rule(Trace, Stop(Blocked)) {
  rule.new(fn(current_trace) {
    case grid.retrieve(board, trace.position(current_trace)) {
      Ok(Space(player: Player(set), ..)) if set == friendly ->
        projection.stop(FriendlyPiece)
      Ok(Space(..)) -> projection.continue(current_trace)
      Error(NoContent) -> projection.continue(current_trace)
    }
  })
}

fn is_blocked_by_rival(
  board: Grid(Space),
  friendly: String,
) -> Rule(Trace, Stop(Blocked)) {
  rule.new(fn(current_trace) {
    case grid.retrieve(board, trace.position(current_trace)) {
      Ok(Space(player: Player(set), ..)) if set != friendly ->
        projection.stop(RivalPiece)
      Ok(Space(..)) -> projection.continue(current_trace)
      Error(NoContent) -> projection.continue(current_trace)
    }
  })
}

fn capture_pawn(
  board: Grid(Space),
  friendly: String,
) -> Rule(Trace, Stop(Blocked)) {
  rule.new(fn(current_trace) {
    case grid.retrieve(board, trace.position(current_trace)) {
      Ok(Space(player: Player(set), ..)) if set != friendly ->
        projection.next(Capture)
      Ok(Space(..)) -> projection.stop(FriendlyPiece)
      Error(NoContent) -> projection.stop(StepLimit)
    }
  })
}

fn capture(board: Grid(Space), friendly: String) -> Rule(Trace, Stop(Blocked)) {
  rule.new(fn(current_trace) {
    case grid.retrieve(board, trace.position(current_trace)) {
      Ok(Space(player: Player(set), ..)) if set != friendly ->
        projection.next(Capture)
      Ok(Space(..)) -> projection.continue(current_trace)
      Error(NoContent) -> projection.continue(current_trace)
    }
  })
}
