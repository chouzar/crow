// TODO: Move from directory

import gleam/set.{Set}
import crow/coordinate.{Coordinate}
import crow/players.{Player}
import crow/piece.{Piece}

pub type Space {
  Space(
    player: Player,
    piece: Piece,
    path: Set(Coordinate),
    transform: fn(Coordinate) -> Coordinate,
  )
}
