import crow/player.{Player}
import crow/round/turn.{Turn}
import crow/round/sequence.{Sequence}
import crow/round/phase.{Phase}

pub opaque type Round {
  Round(turn: Turn, sequence: Sequence, phase: Phase)
}

pub fn new() -> Round {
  Round(turn: turn.new(), sequence: sequence.new(), phase: phase.new())
}

pub fn next(round: Round) -> Round {
  let Round(turn, sequence, phase) = round
  Round(
    turn: turn.next(turn),
    sequence: sequence.rotate(sequence),
    phase: phase.next(phase),
  )
}

pub fn add_player(round: Round, player: Player) -> Round {
  let Round(sequence: seq, ..) = round
  let sequence = sequence.add(seq, player)
  Round(..round, sequence: sequence)
}

pub fn current_player(round: Round) -> Player {
  let Round(sequence: seq, ..) = round
  sequence.current(seq)
}
