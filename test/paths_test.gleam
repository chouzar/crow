// TODO: Figure out an elegan way to test this thoroughly
// TODO: Match on the projected coordinates only, per piece or by all
// TODO: 3 scenarios per piece: Free | Blocked | Eat
//  // Check gamestate on start
//  assert GameState(stage: Playing, turn: 1, board: board, ..) =
//    chess.setup("Bone", "Charcoal")
//    |> chess.start()
//
// TODO: On trace we must be able to specify a transform in the direction
// TODO: Posibly step rules now need to carry the whole gamestate
// Check initial calculated paths
// 8 ♜ ♞ ♝ ♛ ♚ ♝ ♞ ♜
// 7 ♟ ♟ ♟ ♟ ♟ ♟ ♟ ♟︎
// 6 ⚐ ⚐ ⚐ ⚐ ⚐ ⚐ ⚐ ⚐
// 5 ⚐ ⚐ ⚐ ⚐ ⚐ ⚐ ⚐ ⚐
// 4 ⚐ ⚐ ⚐ ⚐ ⚐ ⚐ ⚐ ⚐
// 3 ⚐ ⚐ ⚐ ⚐ ⚐ ⚐ ⚐ ⚐
// 2 ♙ ♙ ♙ ♙ ♙ ♙ ♙ ♙
// 1 ♖ ♘ ♗ ♕ ♔ ♗ ♘ ♖
//   1 2 3 4 5 6 7 8 

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

pub fn pawn_path_test() {
  let p1 = Player("Bone")
  let p2 = Player("Rock")

  // Assert that pawn can move 2 spaces on 1st line
  assert Ok(board) =
    grid.new(8, 8)
    |> result.then(chess.set(_, 3, 1, p1, Pawn, fn(x) { x }))

  let path = move.project(board, Coordinate(3, 1))
  assert True = set.contains(path, Coordinate(3, 2))
  assert True = set.contains(path, Coordinate(3, 3))
  assert 2 = set.size(path)

  // Assert that pawn can move 2 spaces on 2st line
  assert Ok(board) =
    grid.new(8, 8)
    |> result.then(chess.set(_, 3, 2, p1, Pawn, fn(x) { x }))

  let path = move.project(board, Coordinate(3, 2))
  assert True = set.contains(path, Coordinate(3, 3))
  assert True = set.contains(path, Coordinate(3, 4))
  assert 2 = set.size(path)

  // Assert that pawn can move 1 space on a line
  assert Ok(board) =
    grid.new(8, 8)
    |> result.then(chess.set(_, 3, 4, p1, Pawn, fn(x) { x }))

  let path = move.project(board, Coordinate(3, 4))
  assert True = set.contains(path, Coordinate(3, 5))
  assert 1 = set.size(path)

  // Assert that pawn can be blocked or attack
  assert Ok(board) =
    grid.new(8, 8)
    |> result.then(chess.set(_, 3, 4, p1, Pawn, fn(x) { x }))
    |> result.then(chess.set(_, 2, 5, p2, Knight, fn(x) { x }))
    |> result.then(chess.set(_, 3, 5, p2, Knight, fn(x) { x }))
    |> result.then(chess.set(_, 4, 5, p2, Knight, fn(x) { x }))

  let path = move.project(board, Coordinate(3, 4))
  assert True = set.contains(path, Coordinate(2, 5))
  assert False = set.contains(path, Coordinate(3, 5))
  assert True = set.contains(path, Coordinate(4, 5))
  assert 3 = set.size(path)
  // TODO: Assert with the inverse.
  // TODO: Create a helper function to assert.
}

pub fn rook_path_test() {
  let p1 = Player("Bone")
  let p2 = Player("Rock")
  // Assert that rook can move to all directions
}
