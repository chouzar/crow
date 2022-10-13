import crow/round/turn.{Turn}
import crow/round/phase.{Phase}

pub opaque type Round {
  Round(turn: Turn, phase: Phase)
}

pub fn new() -> Round {
  Round(turn: turn.new(), phase: phase.new())
}

pub fn next(round: Round) -> Round {
  let Round(turn, phase) = round
  Round(turn: turn.next(turn), phase: phase.next(phase))
}

pub fn get_turn(round: Round) -> Int {
  let Round(turn: t, ..) = round
  turn.get_turn(t)
}
