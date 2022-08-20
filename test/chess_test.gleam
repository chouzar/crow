import gleam/list
import gleam/queue.{Queue}
import gleam/set.{Set}
import gleam/map.{Map}
import gleam/result
import gleam/option.{None, Option, Some}
import gleam/io
import crow/coordinate.{Coordinate}
import crow/players.{Player}
import crow/piece.{Bishop, King, Knight, Pawn, Queen, Rook}
import crow/space.{Space}
import crow/move
import crow/grid.{Grid, Limits}
import chess.{End, GameState, Playing, Setup}

pub fn setup_test() {
  // Check initial gamestage
  assert GameState(stage: Setup, turn: 0, board: board, ..) =
    chess.setup("Bone", "Rock")

  // Check that grid is 8 by 8 
  assert Grid(
    limits: Limits(Coordinate(x: 1, y: 1), Coordinate(x: 8, y: 8)),
    positions: positions,
  ) = board

  // Check pieces on board
  assert 32 = map.size(positions)
}

pub fn start_test() {
  // Check gamestate on start
  assert GameState(stage: Playing, turn: 1, ..) =
    chess.setup("Bone", "Rock")
    |> chess.start()
}

pub fn play_test() {
  //https://www.chess.com/games/view/13459415
  chess.setup("Bone", "Rock")
  |> chess.start()
  |> next("Bone", Pawn, at: #(4, 2), to: #(4, 4))
  |> next("Rock", Pawn, at: #(4, 7), to: #(4, 5))
  //|> next("Bone", Pawn, at: #(3, 2), to: #(3, 4))
  //|> next("Rock", Pawn, at: #(3, 7), to: #(3, 6))
}

// Wraps chess.next function into a wrapper that asserts moves
fn next(state, player, piece, at from, to to) -> GameState {
  let state = chess.next(state, from: Coordinate(4, 2), to: Coordinate(4, 4))

  assert Error(Nil) = map.get(state.board.positions, Coordinate(from.0, from.1))
  assert Ok(space) = map.get(state.board.positions, Coordinate(to.0, to.1))

  assert True = space.player == Player(player)
  assert True = space.piece == piece

  state
}
