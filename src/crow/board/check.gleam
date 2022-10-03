import crow/coordinate.{Coordinate}
import crow/player.{Player}
import crow/board/path.{Path}
import crow/piece.{Piece}

pub type Check {
  Check(
    player: Player,
    piece: Piece,
    paths: List(Path),
    facing_direction: Coordinate,
  )
}

pub fn new(player: Player, piece: Piece, facing_direction: Coordinate) -> Check {
  Check(
    player: player,
    piece: piece,
    paths: [],
    facing_direction: facing_direction,
  )
}
