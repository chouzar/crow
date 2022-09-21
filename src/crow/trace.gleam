// TODO: Refactor
import crow/coordinate.{Coordinate}

pub opaque type Trace {
  Trace(
    from: Coordinate,
    position: Coordinate,
    trajectory: Coordinate,
    step: Int,
    path: List(Coordinate),
  )
}

pub fn new(from: Coordinate, trajectory: Coordinate) -> Trace {
  Trace(from: from, position: from, trajectory: trajectory, step: 0, path: [])
}

pub fn next(trace: Trace) -> Trace {
  let next_position = coordinate.add(trace.position, trace.trajectory)

  Trace(
    ..trace,
    position: next_position,
    step: trace.step + 1,
    path: [next_position, ..trace.path],
  )
}

pub fn position(trace: Trace) -> Coordinate {
  trace.position
}

pub fn step(trace: Trace) -> Int {
  trace.step
}

pub fn path(trace: Trace) -> List(Coordinate) {
  trace.path
}
