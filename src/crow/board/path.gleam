// TODO:
// An more streamlined way to model projection would be by modelling with a state machine.
//
// Where the states are:  
//   * Continue 
//   * Stop(reason)
// 
// And the Trace struct would be used as some kind of "memory". 
//
// NOTE: One way of doing this is by using gleam's "eval" library.
import crow/coordinate.{Coordinate}
import crow/board/rule.{Rule}
import gleam/option.{None, Option, Some}
import gleam/list

pub type Blocked {
  FriendlyPiece
  RivalPiece
  OutOfBounds
  StepLimit
  Capture
}

pub type Path {
  Path(positions: List(Coordinate), capture: Option(Coordinate))
}

pub type Trace {
  Trace(
    position: Coordinate,
    direction: Coordinate,
    step: Int,
    path: List(Coordinate),
  )
}

pub fn new(
  from: Coordinate,
  trajectory: Coordinate,
  rule: Rule(Trace, Blocked),
) -> Path {
  Trace(position: from, direction: trajectory, step: 0, path: [])
  |> next()
  |> build(rule)
}

pub fn build(trace: Trace, rule: Rule(Trace, Blocked)) -> Path {
  case rule.apply(trace, rule) {
    Ok(trace) ->
      trace
      |> next()
      |> build(rule)

    Error(Capture) ->
      trace
      |> stop(Capture)

    Error(reason) ->
      trace
      |> back()
      |> stop(reason)
  }
}

fn next(trace: Trace) -> Trace {
  let next_position = coordinate.add(trace.position, trace.direction)

  Trace(
    ..trace,
    position: next_position,
    step: trace.step + 1,
    path: list.prepend(trace.path, next_position),
  )
}

fn back(trace: Trace) -> Trace {
  let prev_position = coordinate.substract(trace.position, trace.direction)

  Trace(
    ..trace,
    position: prev_position,
    step: trace.step - 1,
    path: list.drop(trace.path, 1),
  )
}

fn stop(trace: Trace, reason: Blocked) -> Path {
  // Retrieve trace path in order and remove starting position
  let positions =
    trace.path
    |> list.reverse()

  // Check if path is able to capture
  let capture = case reason {
    Capture -> Some(trace.position)
    _other -> None
  }

  // Build the path
  Path(positions, capture)
}
