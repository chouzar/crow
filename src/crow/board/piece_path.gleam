// TODO: Could build a higher level DSL for managing constraints that takes direction into account.
import crow/coordinate.{Coordinate}
import crow/board/grid.{Grid, NoContent}
import crow/player.{Player}
import crow/board/rule.{Rule}
import crow/piece.{Bishop, King, Knight, Pawn, Queen, Rook}
import crow/board/check.{Check}
import crow/board/path.{Blocked, Path, Trace}
import crow/board/direction as dir
import gleam/int
import gleam/order.{Eq, Gt, Lt}

pub type MoveLimit {
  Continuous
  Limited(n: Int)
}

pub fn path(board: Grid(Check), from: Coordinate) -> List(Path) {
  assert Ok(check) = grid.retrieve(in: board, at: from)

  case check.piece {
    Pawn -> pawn(board, from, check)
    Rook -> rook(board, from, check)
    Bishop -> bishop(board, from, check)
    Knight -> knight(board, from, check)
    Queen -> queen(board, from, check)
    King -> king(board, from, check)
  }
}

fn pawn(board: Grid(Check), from: Coordinate, check: Check) -> List(Path) {
  let Check(player: Player(set), facing_direction: direction, ..) = check

  // Transform logic is quite harcoded, matix inversion would work better 
  let n = case direction, from {
    Coordinate(1, 1), Coordinate(_, 1) -> 2
    Coordinate(1, 1), Coordinate(_, 2) -> 2
    Coordinate(1, -1), Coordinate(_, 8) -> 2
    Coordinate(1, -1), Coordinate(_, 7) -> 2
    _, Coordinate(_, _) -> 1
  }

  let constraints =
    in_steps(Limited(n))
    |> rule.then(in_bounds(board))
    |> rule.then(is_blocked_by_friendly(board, set))
    |> rule.then(is_blocked_by_rival(board, set))

  let capture_constaints =
    in_steps(Limited(1))
    |> rule.then(in_bounds(board))
    |> rule.then(is_blocked_by_friendly(board, set))
    |> rule.then(capture_pawn(board, set))

  let transform = fn(coor) { coordinate.multiply(coor, direction) }

  [
    path.new(from, transform(dir.up), constraints),
    path.new(from, transform(dir.top_right), capture_constaints),
    path.new(from, transform(dir.top_left), capture_constaints),
  ]
}

fn rook(board: Grid(Check), from: Coordinate, check: Check) -> List(Path) {
  let Check(player: Player(set), ..) = check

  let constraints =
    in_steps(Continuous)
    |> rule.then(in_bounds(board))
    |> rule.then(is_blocked_by_friendly(board, set))
    |> rule.then(capture(board, set))

  [
    path.new(from, dir.up, constraints),
    path.new(from, dir.right, constraints),
    path.new(from, dir.down, constraints),
    path.new(from, dir.left, constraints),
  ]
}

fn bishop(board: Grid(Check), from: Coordinate, check: Check) -> List(Path) {
  let Check(player: Player(set), ..) = check

  let constraints =
    in_steps(Continuous)
    |> rule.then(in_bounds(board))
    |> rule.then(is_blocked_by_friendly(board, set))
    |> rule.then(capture(board, set))

  [
    path.new(from, dir.top_right, constraints),
    path.new(from, dir.bottom_right, constraints),
    path.new(from, dir.bottom_left, constraints),
    path.new(from, dir.top_left, constraints),
  ]
}

fn knight(board: Grid(Check), from: Coordinate, check: Check) -> List(Path) {
  let Check(player: Player(set), ..) = check

  let constraints =
    in_steps(Limited(1))
    |> rule.then(in_bounds(board))
    |> rule.then(is_blocked_by_friendly(board, set))
    |> rule.then(capture(board, set))

  [
    path.new(from, dir.top_right_jump, constraints),
    path.new(from, dir.right_top_jump, constraints),
    path.new(from, dir.top_bottom_jump, constraints),
    path.new(from, dir.bottom_right_jump, constraints),
    path.new(from, dir.bottom_left_jump, constraints),
    path.new(from, dir.left_bottom_jump, constraints),
    path.new(from, dir.left_top_jump, constraints),
    path.new(from, dir.top_left_jump, constraints),
  ]
}

fn queen(board: Grid(Check), from: Coordinate, check: Check) -> List(Path) {
  let Check(player: Player(set), ..) = check

  let constraints =
    in_steps(Continuous)
    |> rule.then(in_bounds(board))
    |> rule.then(is_blocked_by_friendly(board, set))
    |> rule.then(capture(board, set))

  [
    path.new(from, dir.up, constraints),
    path.new(from, dir.right, constraints),
    path.new(from, dir.down, constraints),
    path.new(from, dir.left, constraints),
    path.new(from, dir.top_right, constraints),
    path.new(from, dir.bottom_right, constraints),
    path.new(from, dir.bottom_left, constraints),
    path.new(from, dir.top_left, constraints),
  ]
}

fn king(board: Grid(Check), from: Coordinate, check: Check) -> List(Path) {
  let Check(player: Player(set), ..) = check

  let constraints =
    in_steps(Limited(1))
    |> rule.then(in_bounds(board))
    |> rule.then(is_blocked_by_friendly(board, set))
    |> rule.then(capture(board, set))

  [
    path.new(from, dir.up, constraints),
    path.new(from, dir.right, constraints),
    path.new(from, dir.down, constraints),
    path.new(from, dir.left, constraints),
    path.new(from, dir.top_right, constraints),
    path.new(from, dir.bottom_right, constraints),
    path.new(from, dir.bottom_left, constraints),
    path.new(from, dir.top_left, constraints),
  ]
}

fn in_bounds(board: Grid(Check)) -> Rule(Trace, Blocked) {
  rule.new(fn(trace: Trace) {
    case grid.in_bounds(board, trace.position) {
      Ok(_) -> Ok(trace)
      Error(_) -> Error(path.OutOfBounds)
    }
  })
}

fn in_steps(move_limit: MoveLimit) -> Rule(Trace, Blocked) {
  rule.new(fn(trace: Trace) {
    case move_limit {
      Continuous -> Ok(trace)

      Limited(n: steps) ->
        case int.compare(steps, trace.step) {
          Gt -> Ok(trace)
          Eq -> Ok(trace)
          Lt -> Error(path.StepLimit)
        }
    }
  })
}

fn is_blocked_by_friendly(
  board: Grid(Check),
  friendly: String,
) -> Rule(Trace, Blocked) {
  rule.new(fn(trace: Trace) {
    case grid.retrieve(board, trace.position) {
      Ok(Check(player: Player(set), ..)) if set == friendly ->
        Error(path.FriendlyPiece)
      Ok(Check(..)) -> Ok(trace)
      Error(NoContent) -> Ok(trace)
    }
  })
}

fn is_blocked_by_rival(
  board: Grid(Check),
  friendly: String,
) -> Rule(Trace, Blocked) {
  rule.new(fn(trace: Trace) {
    case grid.retrieve(board, trace.position) {
      Ok(Check(player: Player(set), ..)) if set != friendly ->
        Error(path.RivalPiece)
      Ok(Check(..)) -> Ok(trace)
      Error(NoContent) -> Ok(trace)
    }
  })
}

fn capture_pawn(board: Grid(Check), friendly: String) -> Rule(Trace, Blocked) {
  rule.new(fn(trace: Trace) {
    case grid.retrieve(board, trace.position) {
      Ok(Check(player: Player(set), ..)) if set != friendly ->
        Error(path.Capture)
      Ok(Check(..)) -> Error(path.FriendlyPiece)
      Error(NoContent) -> Error(path.StepLimit)
    }
  })
}

fn capture(board: Grid(Check), friendly: String) -> Rule(Trace, Blocked) {
  rule.new(fn(trace: Trace) {
    case grid.retrieve(board, trace.position) {
      Ok(Check(player: Player(set), ..)) if set != friendly ->
        Error(path.Capture)
      Ok(Check(..)) -> Ok(trace)
      Error(NoContent) -> Ok(trace)
    }
  })
}
