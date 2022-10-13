import crow/coordinate.{Coordinate}
import crow/player.{Player}
import crow/players/facing.{Facing}
import gleam/int
import gleam/list
import gleam/map.{Map}

pub opaque type Players {
  Players(player_set: Map(Int, Player), sequence: List(Int), facing: Facing)
}

pub fn new() -> Players {
  Players(player_set: map.new(), sequence: [], facing: facing.new())
}

pub fn add(players: Players, player: Player, direction: Coordinate) -> Players {
  let Players(player_set: player_set, sequence: player_seq, facing: player_fac) =
    players
  let order = map.size(player_set) + 1
  let player_set = map.insert(player_set, order, player)
  let player_seq = [order, ..player_seq]
  let player_fac = facing.add(player_fac, player, direction)
  Players(player_set: player_set, sequence: player_seq, facing: player_fac)
}

pub fn rotate(players: Players) -> Players {
  let Players(sequence: player_seq, ..) = players
  let [first, ..rest] = player_seq
  let player_seq = list.append(rest, [first])
  Players(..players, sequence: player_seq)
}

pub fn get_players(players: Players) -> List(Player) {
  let Players(player_set: player_set, ..) = players

  player_set
  |> map.to_list()
  |> list.sort(fn(a, b) { int.compare(a.0, b.0) })
  |> list.map(fn(record) { record.1 })
}

pub fn get_player(players: Players, at: Int) -> Player {
  let Players(player_set: player_set, ..) = players
  assert Ok(player) = map.get(player_set, at)
  player
}

pub fn get_current(players: Players) -> Player {
  let Players(player_set: player_set, sequence: player_seq, ..) = players
  let [first, ..] = player_seq
  assert Ok(player) = map.get(player_set, first)
  player
}

pub fn get_facing(players: Players, player: Player) -> Coordinate {
  let Players(facing: player_fac, ..) = players
  facing.get(player_fac, player)
}
