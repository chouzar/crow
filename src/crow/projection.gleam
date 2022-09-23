// TODO:
// An easier way to model projection would be by modelling with a state machine.
//
// Where the states are:  
//   * Continue 
//   * Stop 
// 
// And the Trace struct would be used as some kind of "memory". 
//
// NOTE: One way of doing this is by using gleam's "eval" library.

// TODO:
// Maybe the Trace and Continuation types could be merged, this would let us
// have a single function to pass by at the project function, letting us 
// update the trace, continue or stop in the same place.

//import eval.{Eval}

// TODO: Refactor

import crow/coordinate.{Coordinate}
import crow/rule.{Rule}
import crow/trace.{Trace}

pub type Projection(stop_reason) {
  Projection(trace: Trace, reason: stop_reason)
}

pub opaque type Stop(reason) {
  Next(reason)
  Stop(reason)
}

pub fn continue(trace: Trace) -> Result(Trace, Stop(r)) {
  Ok(trace)
}

pub fn next(reason: r) -> Result(Trace, Stop(r)) {
  Error(Next(reason))
}

pub fn stop(reason: r) -> Result(Trace, Stop(r)) {
  Error(Stop(reason))
}

pub fn project(
  from: Coordinate,
  trajectory: Coordinate,
  rule: Rule(Trace, Stop(reason)),
) -> Projection(reason) {
  let trace = trace.new(from, trajectory)
  project_as(trace, rule)
}

fn project_as(
  current_trace: Trace,
  rule: Rule(Trace, Stop(reason)),
) -> Projection(reason) {
  let next_trace = trace.next(current_trace)

  case rule.apply(next_trace, rule) {
    Ok(_) -> project_as(next_trace, rule)
    Error(Next(reason)) -> Projection(next_trace, reason)
    Error(Stop(reason)) -> Projection(current_trace, reason)
  }
}
