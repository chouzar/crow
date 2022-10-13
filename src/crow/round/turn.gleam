pub opaque type Turn {
  Turn(n: Int)
}

pub fn new() -> Turn {
  Turn(0)
}

pub fn next(t: Turn) -> Turn {
  Turn(t.n + 1)
}

pub fn get_turn(turn: Turn) -> Int {
  turn.n
}
