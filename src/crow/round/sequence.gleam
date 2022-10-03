import gleam/list
import crow/player.{Player}

pub opaque type Sequence {
  Sequence(List(Player))
}

pub fn new() -> Sequence {
  Sequence([])
}

pub fn add(sequence: Sequence, player: Player) -> Sequence {
  let Sequence(players) = sequence
  Sequence([player, ..players])
}

pub fn current(sequence: Sequence) -> Player {
  let Sequence([player, ..]) = sequence
  player
}

pub fn rotate(sequence: Sequence) -> Sequence {
  let Sequence([player, ..players]) = sequence
  Sequence(list.append(players, [player]))
}
