// TODO: This module is just turn sequence functionality for players

import gleam/queue.{Queue}

pub type Player {
  Player(id: String)
}

pub fn new(players: List(Player)) -> Queue(Player) {
  queue.from_list(players)
}

pub fn rotate(players: Queue(Player)) -> Queue(Player) {
  assert Ok(#(player, player_queue)) = queue.pop_front(players)
  queue.push_back(player_queue, player)
}

pub fn current(players: Queue(Player)) -> Player {
  assert Ok(#(player, _)) = queue.pop_front(players)
  player
}
