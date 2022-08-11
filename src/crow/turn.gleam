
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
