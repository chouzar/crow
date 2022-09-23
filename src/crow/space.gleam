import gleam/set.{Set}
import crow/coordinate.{Coordinate}
import crow/players.{Player}
import crow/piece.{Piece}

// TODO: This can be implicit
pub type Transform {
  Normal
  Inverse
}

pub type Space {
  Space(
    player: Player,
    piece: Piece,
    path: Set(Coordinate),
    transform: Transform,
  )
}
