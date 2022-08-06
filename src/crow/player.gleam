import gleam/list
import gleam/set

pub type Player(id) {
  Player(id: id)
}

pub fn new(id: id) -> Player(id) {
  Player(id)
}

pub fn get_id(player: Player(id)) -> id {
  player.id
}

pub fn players(players: List(Player(id))) -> List(Player(id)) {
  players
  |> set.from_list()
  |> set.to_list()
}

pub fn next(players: List(Player(id))) -> List(Player(id)) {
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
