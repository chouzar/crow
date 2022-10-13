import crow/player.{Player}
import crow/coordinate.{Coordinate}
import gleam/map.{Map}

pub opaque type Facing {
  Facing(Map(Player, Coordinate))
}

pub fn new() -> Facing {
  Facing(map.new())
}

pub fn add(facing: Facing, player: Player, direction: Coordinate) -> Facing {
  let Facing(m) = facing
  Facing(map.insert(m, player, direction))
}

pub fn get(facing: Facing, player: Player) -> Coordinate {
  let Facing(m) = facing
  assert Ok(direction) = map.get(m, player)
  direction
}
