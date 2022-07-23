// PRESENTATION - Gleam is expressive
//
// Gleam is fairly simple and in some ways syntax is less expressive than what
// can be found in erlang or elixir: 
//
// * Lack of literals
// * Lack of branching options
// * Lack of macro system
// * No behaviour or protocol system
//
// But is just as capable of modelling most problem domains:
//
// * "Open" domain through types public types
// * Constained set of operations through opaque types
//   * Api might be "flexible", next = gamestate -> next -> gamestate
//   * Api might be "precise", next = gamestate -> gamestate
//
// May or not require assertion checks when depending on Result types
//   * Result types can be composed together
//   * But composition can also be achieved with pipes
//   * Or a custom mechanism to apply types or functions
//
// We may add to this type through Generics.

pub opaque type Turn {
  Turn(stage: Stage, n: Int)
}

pub type Stage {
  Start
  Playing
  End
}

pub fn start() -> Turn {
  Turn(stage: Start, n: 0)
}

pub fn next(turn: Turn) -> Turn {
  Turn(stage: Playing, n: turn.n + 1)
}

pub fn end(turn: Turn) -> Turn {
  Turn(..turn, stage: End)
}
