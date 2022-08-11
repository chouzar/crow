import gleam/list
import gleam/set

pub type Player(id) {
  Player(id: id)
}

pub fn players(players: List(Player(id))) -> List(Player(id)) {
  players
  |> set.from_list()
  |> set.to_list()
}

pub fn rotate(players: List(Player(id))) -> List(Player(id)) {
  let [player, ..players] = players

  players
  |> list.reverse()
  |> list.prepend(player)
  |> list.reverse()
}

pub fn current(players: List(Player(id))) -> Player(id) {
  let [player, ..] = players
  player
}
