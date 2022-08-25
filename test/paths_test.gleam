import gleam/io
import gleam/list
import gleam/queue.{Queue}
import gleam/set.{Set}
import gleam/map.{Map}
import gleam/result
import gleam/option.{None, Option, Some}
import crow/coordinate.{Coordinate}
import crow/players.{Player}
import crow/piece.{Bishop, King, Knight, Pawn, Queen, Rook}
import crow/space.{Inverse, Normal, Space}
import crow/move
import crow/grid.{Grid, Limits}
import chess.{End, GameState, Playing, Setup}

// Example unicode board
//   _ _ _ _ _ _ _ _
// 8 ♜ ♞ ♝ ♛ ♚ ♝ ♞ ♜|
// 7 ♟ ♟ ♟ ♟ ♟ ♟ ♟ ♟︎|
// 6         ⚐      |
// 5         ☠      |
// 4                |
// 3                |
// 2 ♙ ♙ ♙ ♙ ♙ ♙ ♙ ♙|
// 1 ♖ ♘ ♗ ♕ ♔ ♗ ♘ ♖|
//   1 2 3 4 5 6 7 8 

pub fn pawn_twice_path_test() {
  let p1 = Player("Bone")

  // Assert that pawn can move 2 spaces on 1st line
  //   _ _ _ _ _ _ _ _
  // 8                |
  // 7                |
  // 6                |
  // 5                |
  // 4                |
  // 3     ⚐          |
  // 2     ⚐          |
  // 1     ♙          |
  //   1 2 3 4 5 6 7 8 
  //
  assert Ok(board) =
    grid.new(8, 8)
    |> result.then(chess.set(_, 3, 1, p1, Pawn, Normal))

  let path = move.project(board, Coordinate(3, 1))
  assert True = set.contains(path, Coordinate(3, 2))
  assert True = set.contains(path, Coordinate(3, 3))
  assert 2 = set.size(path)

  // Assert that pawn can move 2 spaces on 2nd line
  //   _ _ _ _ _ _ _ _
  // 8                |
  // 7                |
  // 6                |
  // 5                |
  // 4     ⚐          |
  // 3     ⚐          |
  // 2     ♙          |
  // 1                |
  //   1 2 3 4 5 6 7 8 
  //
  assert Ok(board) =
    grid.new(8, 8)
    |> result.then(chess.set(_, 3, 2, p1, Pawn, Normal))

  let path = move.project(board, Coordinate(3, 2))
  assert True = set.contains(path, Coordinate(3, 3))
  assert True = set.contains(path, Coordinate(3, 4))
  assert 2 = set.size(path)

  // Assert that pawn can move 2 spaces on 8th line
  //   _ _ _ _ _ _ _ _
  // 8           ♟    |
  // 7           ⚐    |
  // 6           ⚐    |
  // 5                |
  // 4                |
  // 3                |
  // 2                |
  // 1                |
  //   1 2 3 4 5 6 7 8 
  //
  assert Ok(board) =
    grid.new(8, 8)
    |> result.then(chess.set(_, 6, 8, p1, Pawn, Inverse))

  let path = move.project(board, Coordinate(6, 8))
  assert True = set.contains(path, Coordinate(6, 7))
  assert True = set.contains(path, Coordinate(6, 6))
  assert 2 = set.size(path)

  // Assert that pawn can move 2 spaces on 7th line
  //   _ _ _ _ _ _ _ _
  // 8                |
  // 7           ♟    |
  // 6           ⚐    |
  // 5           ⚐    |
  // 4                |
  // 3                |
  // 2                |
  // 1                |
  //   1 2 3 4 5 6 7 8 
  //
  assert Ok(board) =
    grid.new(8, 8)
    |> result.then(chess.set(_, 6, 7, p1, Pawn, Inverse))

  let path = move.project(board, Coordinate(6, 7))
  assert True = set.contains(path, Coordinate(6, 6))
  assert True = set.contains(path, Coordinate(6, 5))
  assert 2 = set.size(path)
}

pub fn pawn_path_test() {
  let p1 = Player("Bone")

  // Assert that pawn can move 1 space on any other line
  //   _ _ _ _ _ _ _ _
  // 8                |
  // 7                |
  // 6                |
  // 5     ⚐          |
  // 4     ♙          |
  // 3                |
  // 2                |
  // 1                |
  //   1 2 3 4 5 6 7 8 
  //
  assert Ok(board) =
    grid.new(8, 8)
    |> result.then(chess.set(_, 3, 4, p1, Pawn, Normal))

  let path = move.project(board, Coordinate(3, 4))
  assert True = set.contains(path, Coordinate(3, 5))
  assert 1 = set.size(path)

  // Assert that pawn can move 1 space on any other line
  //   _ _ _ _ _ _ _ _
  // 8                |
  // 7                |
  // 6                |
  // 5           ♟    |
  // 4           ⚐    |
  // 3                |
  // 2                |
  // 1                |
  //   1 2 3 4 5 6 7 8 
  //
  assert Ok(board) =
    grid.new(8, 8)
    |> result.then(chess.set(_, 6, 5, p1, Pawn, Inverse))

  let path = move.project(board, Coordinate(6, 5))
  assert True = set.contains(path, Coordinate(6, 4))
  assert 1 = set.size(path)
}

pub fn pawn_block_test() {
  let p1 = Player("Bone")
  let p2 = Player("Rock")

  // Assert that pawn can be blocked 
  //   _ _ _ _ _ _ _ _
  // 8                |
  // 7                |
  // 6                |
  // 5     ♞          |
  // 4     ♙          |
  // 3                |
  // 2                |
  // 1                |
  //   1 2 3 4 5 6 7 8 
  //
  assert Ok(board) =
    grid.new(8, 8)
    |> result.then(chess.set(_, 3, 4, p1, Pawn, Normal))
    |> result.then(chess.set(_, 3, 5, p2, Knight, Normal))

  let path = move.project(board, Coordinate(3, 4))
  assert False = set.contains(path, Coordinate(3, 5))
  assert 0 = set.size(path)

  // Assert that pawn can be blocked 
  //   _ _ _ _ _ _ _ _
  // 8                |
  // 7                |
  // 6                |
  // 5           ♟    |
  // 4           ♘    |
  // 3                |
  // 2                |
  // 1                |
  //   1 2 3 4 5 6 7 8 
  //
  assert Ok(board) =
    grid.new(8, 8)
    |> result.then(chess.set(_, 6, 5, p1, Pawn, Inverse))
    |> result.then(chess.set(_, 6, 4, p2, Knight, Normal))

  let path = move.project(board, Coordinate(6, 5))
  assert False = set.contains(path, Coordinate(6, 4))
  assert 0 = set.size(path)
}

pub fn pawn_attack_test() {
  let p1 = Player("Bone")
  let p2 = Player("Rock")

  // Assert that pawn can attack 
  //   _ _ _ _ _ _ _ _
  // 8                |
  // 7                |
  // 6                |
  // 5   ☠ ⚐ ☠        |
  // 4     ♙          |
  // 3                |
  // 2                |
  // 1                |
  //   1 2 3 4 5 6 7 8 
  //
  assert Ok(board) =
    grid.new(8, 8)
    |> result.then(chess.set(_, 3, 4, p1, Pawn, Normal))
    |> result.then(chess.set(_, 2, 5, p2, Knight, Normal))
    |> result.then(chess.set(_, 4, 5, p2, Knight, Normal))

  let path = move.project(board, Coordinate(3, 4))
  assert True = set.contains(path, Coordinate(2, 5))
  assert True = set.contains(path, Coordinate(4, 5))
  assert 3 = set.size(path)

  // Assert that pawn can attack 
  //   _ _ _ _ _ _ _ _
  // 8                |
  // 7                |
  // 6                |
  // 5           ♟    |
  // 4         ☠ ⚐ ☠  |
  // 3                |
  // 2                |
  // 1                |
  //   1 2 3 4 5 6 7 8 
  //
  assert Ok(board) =
    grid.new(8, 8)
    |> result.then(chess.set(_, 6, 5, p1, Pawn, Inverse))
    |> result.then(chess.set(_, 5, 4, p2, Knight, Normal))
    |> result.then(chess.set(_, 7, 4, p2, Knight, Normal))

  let path = move.project(board, Coordinate(6, 5))
  assert True = set.contains(path, Coordinate(5, 4))
  assert True = set.contains(path, Coordinate(7, 4))
  assert 3 = set.size(path)
}

pub fn rook_path_test() {
  let p1 = Player("Bone")

  // Assert that rook can move to all directions
  //   _ _ _ _ _ _ _ _
  // 8       ⚐        |
  // 7       ⚐        |
  // 6       ⚐        |
  // 5       ⚐        |
  // 4 ⚐ ⚐ ⚐ ♖ ⚐ ⚐ ⚐ ⚐|
  // 3       ⚐        |
  // 2       ⚐        |
  // 1       ⚐        |
  //   1 2 3 4 5 6 7 8 
  //
  assert Ok(board) =
    grid.new(8, 8)
    |> result.then(chess.set(_, 4, 4, p1, Rook, Normal))

  let path = move.project(board, Coordinate(4, 4))

  // ↑ Up path
  assert True = set.contains(path, Coordinate(4, 5))
  assert True = set.contains(path, Coordinate(4, 6))
  assert True = set.contains(path, Coordinate(4, 7))
  assert True = set.contains(path, Coordinate(4, 8))

  // → Right path
  assert True = set.contains(path, Coordinate(5, 4))
  assert True = set.contains(path, Coordinate(6, 4))
  assert True = set.contains(path, Coordinate(7, 4))
  assert True = set.contains(path, Coordinate(8, 4))

  // ↓ Down path
  assert True = set.contains(path, Coordinate(4, 3))
  assert True = set.contains(path, Coordinate(4, 2))
  assert True = set.contains(path, Coordinate(4, 1))

  // ← Left path
  assert True = set.contains(path, Coordinate(3, 4))
  assert True = set.contains(path, Coordinate(2, 4))
  assert True = set.contains(path, Coordinate(1, 4))

  assert 14 = set.size(path)
}

pub fn rook_attack_test() {
  let p1 = Player("Bone")
  let p2 = Player("Rock")

  // Assert that rook can move and capture
  //   _ _ _ _ _ _ _ _
  // 8       ♟        |
  // 7       ♟        |
  // 6       ☠        |
  // 5       ⚐        |
  // 4 ☠ ⚐ ⚐ ♖ ⚐ ⚐ ☠  |
  // 3       ☠        |
  // 2                |
  // 1                |
  //   1 2 3 4 5 6 7 8 
  //
  assert Ok(board) =
    grid.new(8, 8)
    |> result.then(chess.set(_, 4, 4, p1, Rook, Normal))
    |> result.then(chess.set(_, 4, 6, p2, Pawn, Normal))
    |> result.then(chess.set(_, 4, 7, p2, Pawn, Normal))
    |> result.then(chess.set(_, 4, 8, p2, Pawn, Normal))
    |> result.then(chess.set(_, 7, 4, p2, Pawn, Normal))
    |> result.then(chess.set(_, 4, 3, p2, Pawn, Normal))
    |> result.then(chess.set(_, 1, 4, p2, Pawn, Normal))

  let path = move.project(board, Coordinate(4, 4))

  // ↑ Up path
  assert True = set.contains(path, Coordinate(4, 5))
  assert True = set.contains(path, Coordinate(4, 6))
  assert False = set.contains(path, Coordinate(4, 7))
  assert False = set.contains(path, Coordinate(4, 8))

  // → Right path
  assert True = set.contains(path, Coordinate(5, 4))
  assert True = set.contains(path, Coordinate(6, 4))
  assert True = set.contains(path, Coordinate(7, 4))
  assert False = set.contains(path, Coordinate(8, 4))

  // ↓ Down path
  assert True = set.contains(path, Coordinate(4, 3))
  assert False = set.contains(path, Coordinate(4, 2))
  assert False = set.contains(path, Coordinate(4, 1))

  // ← Left path
  assert True = set.contains(path, Coordinate(3, 4))
  assert True = set.contains(path, Coordinate(2, 4))
  assert True = set.contains(path, Coordinate(1, 4))

  assert 9 = set.size(path)
}

pub fn knight_path_test() {
  let p1 = Player("Bone")

  // Assert that knight can move to all directions
  //   _ _ _ _ _ _ _ _
  // 8                |
  // 7                |
  // 6     ⚐   ⚐      |
  // 5   ⚐       ⚐    |
  // 4       ♘        |
  // 3   ⚐       ⚐    |
  // 2     ⚐   ⚐      |
  // 1                |
  //   1 2 3 4 5 6 7 8 
  //
  assert Ok(board) =
    grid.new(8, 8)
    |> result.then(chess.set(_, 4, 4, p1, Knight, Normal))

  let path = move.project(board, Coordinate(4, 4))

  // ↑→ Top Right jump
  // ↑  
  assert True = set.contains(path, Coordinate(5, 6))

  //  ↑ Right Top jump
  // →→ 
  assert True = set.contains(path, Coordinate(6, 5))

  // →→ Right Bottom jump
  //  ↓ 
  assert True = set.contains(path, Coordinate(6, 3))

  // ↓  Bottom Right jump
  // ↓→ 
  assert True = set.contains(path, Coordinate(5, 2))

  //  ↓ Bottom Left jump
  // ←↓ 
  assert True = set.contains(path, Coordinate(3, 2))

  // ←← Left Bottom jump
  // ↓ 
  assert True = set.contains(path, Coordinate(2, 3))

  // ↑
  // ←← Left Top jump
  assert True = set.contains(path, Coordinate(2, 5))

  // ←↑
  //  ↑ Top Left jump
  assert True = set.contains(path, Coordinate(3, 6))

  assert 8 = set.size(path)
}

pub fn knight_attack_test() {
  let p1 = Player("Bone")
  let p2 = Player("Rock")

  // Assert that knight can capture and be blocked by board limits
  //   _ _ _ _ _ _ _ _
  // 8                |
  // 7                |
  // 6                |
  // 5                |
  // 4 ⚐   ☠          |
  // 3       ☠        |
  // 2   ♘            |
  // 1       ⚐        | 
  //   1 2 3 4 5 6 7 8 
  //
  assert Ok(board) =
    grid.new(8, 8)
    |> result.then(chess.set(_, 2, 2, p1, Knight, Normal))
    |> result.then(chess.set(_, 3, 4, p2, Pawn, Normal))
    |> result.then(chess.set(_, 4, 3, p2, Pawn, Normal))

  let path = move.project(board, Coordinate(2, 2))

  // ↑→ Top Right jump
  // ↑  
  assert True = set.contains(path, Coordinate(3, 4))

  //  ↑ Right Top jump
  // →→ 
  assert True = set.contains(path, Coordinate(4, 3))

  // →→ Right Bottom jump
  //  ↓ 
  assert True = set.contains(path, Coordinate(4, 1))

  // ↓  Bottom Right jump
  // ↓→ 
  assert False = set.contains(path, Coordinate(0, 3))

  //  ↓ Bottom Left jump
  // ←↓ 
  assert False = set.contains(path, Coordinate(0, 1))

  // ←← Left Bottom jump
  // ↓ 
  assert False = set.contains(path, Coordinate(1, 0))

  // ↑
  // ←← Left Top jump
  assert False = set.contains(path, Coordinate(0, 3))

  // ←↑
  //  ↑ Top Left jump
  assert True = set.contains(path, Coordinate(1, 4))

  assert 4 = set.size(path)
}

pub fn bishop_path_test() {
  let p1 = Player("Bone")

  // Assert that bishop can move to all directions
  //   _ _ _ _ _ _ _ _
  // 8               ⚐|
  // 7 ⚐           ⚐  |
  // 6   ⚐       ⚐    |
  // 5     ⚐   ⚐      |
  // 4       ♗        |
  // 3     ⚐   ⚐      |
  // 2   ⚐       ⚐    |
  // 1 ⚐           ⚐  |
  //   1 2 3 4 5 6 7 8 
  //
  assert Ok(board) =
    grid.new(8, 8)
    |> result.then(chess.set(_, 4, 4, p1, Bishop, Normal))

  let path = move.project(board, Coordinate(4, 4))

  // ↗ Top Right projection
  assert True = set.contains(path, Coordinate(5, 5))
  assert True = set.contains(path, Coordinate(6, 6))
  assert True = set.contains(path, Coordinate(7, 7))
  assert True = set.contains(path, Coordinate(8, 8))

  // ↘ Bottom Right projection
  assert True = set.contains(path, Coordinate(5, 3))
  assert True = set.contains(path, Coordinate(6, 2))
  assert True = set.contains(path, Coordinate(7, 1))

  // ↙ Bottom Left projection
  assert True = set.contains(path, Coordinate(3, 3))
  assert True = set.contains(path, Coordinate(2, 2))
  assert True = set.contains(path, Coordinate(1, 1))

  // ↖ Top Left projection
  assert True = set.contains(path, Coordinate(3, 5))
  assert True = set.contains(path, Coordinate(2, 6))
  assert True = set.contains(path, Coordinate(1, 7))

  assert 13 = set.size(path)
}

pub fn bishop_attack_test() {
  let p1 = Player("Bone")
  let p2 = Player("Rock")

  // Assert that bishop can capture
  //   _ _ _ _ _ _ _ _
  // 8               ♟|
  // 7 ☠           ♟  |
  // 6   ⚐       ☠    |
  // 5     ⚐   ⚐      |
  // 4       ♗        |
  // 3     ☠   ⚐      |
  // 2           ☠    |
  // 1                |
  //   1 2 3 4 5 6 7 8 
  //
  assert Ok(board) =
    grid.new(8, 8)
    |> result.then(chess.set(_, 4, 4, p1, Bishop, Normal))
    |> result.then(chess.set(_, 6, 6, p2, Pawn, Normal))
    |> result.then(chess.set(_, 7, 7, p2, Pawn, Normal))
    |> result.then(chess.set(_, 8, 8, p2, Pawn, Normal))
    |> result.then(chess.set(_, 6, 2, p2, Pawn, Normal))
    |> result.then(chess.set(_, 3, 3, p2, Pawn, Normal))
    |> result.then(chess.set(_, 1, 7, p2, Pawn, Normal))

  let path = move.project(board, Coordinate(4, 4))

  // ↗ Top Right projection
  assert True = set.contains(path, Coordinate(5, 5))
  assert True = set.contains(path, Coordinate(6, 6))
  assert False = set.contains(path, Coordinate(7, 7))
  assert False = set.contains(path, Coordinate(8, 8))

  // ↘ Bottom Right projection
  assert True = set.contains(path, Coordinate(5, 3))
  assert True = set.contains(path, Coordinate(6, 2))
  assert False = set.contains(path, Coordinate(7, 1))

  // ↙ Bottom Left projection
  assert True = set.contains(path, Coordinate(3, 3))
  assert False = set.contains(path, Coordinate(2, 2))
  assert False = set.contains(path, Coordinate(1, 1))

  // ↖ Top Left projection
  assert True = set.contains(path, Coordinate(3, 5))
  assert True = set.contains(path, Coordinate(2, 6))
  assert True = set.contains(path, Coordinate(1, 7))

  assert 8 = set.size(path)
}

pub fn queen_path_test() {
  let p1 = Player("Bone")

  // Assert that queen can move to all directions
  //   _ _ _ _ _ _ _ _
  // 8       ⚐       ⚐|
  // 7 ⚐     ⚐     ⚐  |
  // 6   ⚐   ⚐   ⚐    |
  // 5     ⚐ ⚐ ⚐      |
  // 4 ⚐ ⚐ ⚐ ♕ ⚐ ⚐ ⚐ ⚐|
  // 3     ⚐ ⚐ ⚐      |
  // 2   ⚐   ⚐   ⚐    |
  // 1 ⚐     ⚐     ⚐  |
  //   1 2 3 4 5 6 7 8 
  //
  assert Ok(board) =
    grid.new(8, 8)
    |> result.then(chess.set(_, 4, 4, p1, Queen, Normal))

  let path = move.project(board, Coordinate(4, 4))

  // ↑ Up path
  assert True = set.contains(path, Coordinate(4, 5))
  assert True = set.contains(path, Coordinate(4, 6))
  assert True = set.contains(path, Coordinate(4, 7))
  assert True = set.contains(path, Coordinate(4, 8))

  // ↗ Top Right projection
  assert True = set.contains(path, Coordinate(5, 5))
  assert True = set.contains(path, Coordinate(6, 6))
  assert True = set.contains(path, Coordinate(7, 7))
  assert True = set.contains(path, Coordinate(8, 8))

  // → Right path
  assert True = set.contains(path, Coordinate(5, 4))
  assert True = set.contains(path, Coordinate(6, 4))
  assert True = set.contains(path, Coordinate(7, 4))
  assert True = set.contains(path, Coordinate(8, 4))

  // ↘ Bottom Right projection
  assert True = set.contains(path, Coordinate(5, 3))
  assert True = set.contains(path, Coordinate(6, 2))
  assert True = set.contains(path, Coordinate(7, 1))

  // ↓ Down path
  assert True = set.contains(path, Coordinate(4, 3))
  assert True = set.contains(path, Coordinate(4, 2))
  assert True = set.contains(path, Coordinate(4, 1))

  // ↙ Bottom Left projection
  assert True = set.contains(path, Coordinate(3, 3))
  assert True = set.contains(path, Coordinate(2, 2))
  assert True = set.contains(path, Coordinate(1, 1))

  // ← Left path
  assert True = set.contains(path, Coordinate(3, 4))
  assert True = set.contains(path, Coordinate(2, 4))
  assert True = set.contains(path, Coordinate(1, 4))

  // ↖ Top Left projection
  assert True = set.contains(path, Coordinate(3, 5))
  assert True = set.contains(path, Coordinate(2, 6))
  assert True = set.contains(path, Coordinate(1, 7))

  assert 27 = set.size(path)
}

pub fn queen_attack_test() {
  let p1 = Player("Bone")
  let p2 = Player("Rock")

  // Assert that queen can capture in all directions
  //   _ _ _ _ _ _ _ _
  // 8       ☠       ♟|
  // 7       ⚐     ☠  |
  // 6   ☠   ⚐   ⚐    |
  // 5     ⚐ ⚐ ⚐      |
  // 4     ☠ ♕ ⚐ ☠ ♟  |
  // 3     ⚐ ⚐ ☠      |
  // 2   ⚐   ⚐        |
  // 1 ⚐     ⚐        |
  //   1 2 3 4 5 6 7 8 
  //
  assert Ok(board) =
    grid.new(8, 8)
    |> result.then(chess.set(_, 4, 4, p1, Queen, Normal))
    |> result.then(chess.set(_, 4, 8, p2, Pawn, Normal))
    |> result.then(chess.set(_, 7, 7, p2, Pawn, Normal))
    |> result.then(chess.set(_, 8, 8, p2, Pawn, Normal))
    |> result.then(chess.set(_, 6, 4, p2, Pawn, Normal))
    |> result.then(chess.set(_, 7, 4, p2, Pawn, Normal))
    |> result.then(chess.set(_, 5, 3, p2, Pawn, Normal))
    |> result.then(chess.set(_, 3, 4, p2, Pawn, Normal))
    |> result.then(chess.set(_, 2, 6, p2, Pawn, Normal))

  let path = move.project(board, Coordinate(4, 4))

  // ↑ Up path
  assert True = set.contains(path, Coordinate(4, 5))
  assert True = set.contains(path, Coordinate(4, 6))
  assert True = set.contains(path, Coordinate(4, 7))
  assert True = set.contains(path, Coordinate(4, 8))

  // ↗ Top Right projection
  assert True = set.contains(path, Coordinate(5, 5))
  assert True = set.contains(path, Coordinate(6, 6))
  assert True = set.contains(path, Coordinate(7, 7))
  assert False = set.contains(path, Coordinate(8, 8))

  // → Right path
  assert True = set.contains(path, Coordinate(5, 4))
  assert True = set.contains(path, Coordinate(6, 4))
  assert False = set.contains(path, Coordinate(7, 4))
  assert False = set.contains(path, Coordinate(8, 4))

  // ↘ Bottom Right projection
  assert True = set.contains(path, Coordinate(5, 3))
  assert False = set.contains(path, Coordinate(6, 2))
  assert False = set.contains(path, Coordinate(7, 1))

  // ↓ Down path
  assert True = set.contains(path, Coordinate(4, 3))
  assert True = set.contains(path, Coordinate(4, 2))
  assert True = set.contains(path, Coordinate(4, 1))

  // ↙ Bottom Left projection
  assert True = set.contains(path, Coordinate(3, 3))
  assert True = set.contains(path, Coordinate(2, 2))
  assert True = set.contains(path, Coordinate(1, 1))

  // ← Left path
  assert True = set.contains(path, Coordinate(3, 4))
  assert False = set.contains(path, Coordinate(2, 4))
  assert False = set.contains(path, Coordinate(1, 4))

  // ↖ Top Left projection
  assert True = set.contains(path, Coordinate(3, 5))
  assert True = set.contains(path, Coordinate(2, 6))
  assert False = set.contains(path, Coordinate(1, 7))

  assert 19 = set.size(path)
}

pub fn king_path_test() {
  let p1 = Player("Bone")

  // Assert that queen can move to all directions
  //   _ _ _ _ _ _ _ _
  // 8                |
  // 7                |
  // 6                |
  // 5     ⚐ ⚐ ⚐      |
  // 4     ⚐ ♕ ⚐      |
  // 3     ⚐ ⚐ ⚐      |
  // 2                |
  // 1                |
  //   1 2 3 4 5 6 7 8 
  //
  assert Ok(board) =
    grid.new(8, 8)
    |> result.then(chess.set(_, 4, 4, p1, King, Normal))

  let path = move.project(board, Coordinate(4, 4))

  // ↑ Up path
  assert True = set.contains(path, Coordinate(4, 5))

  // ↗ Top Right projection
  assert True = set.contains(path, Coordinate(5, 5))

  // → Right path
  assert True = set.contains(path, Coordinate(5, 4))

  // ↘ Bottom Right projection
  assert True = set.contains(path, Coordinate(5, 3))

  // ↓ Down path
  assert True = set.contains(path, Coordinate(4, 3))

  // ↙ Bottom Left projection
  assert True = set.contains(path, Coordinate(3, 3))

  // ← Left path
  assert True = set.contains(path, Coordinate(3, 4))

  // ↖ Top Left projection
  assert True = set.contains(path, Coordinate(3, 5))

  assert 8 = set.size(path)
}

pub fn king_attack_test() {
  let p1 = Player("Bone")
  let p2 = Player("Rock")

  // Assert that king can capture and be blocked by board limits
  //   _ _ _ _ _ _ _ _
  // 8                |
  // 7                |
  // 6                |
  // 5                |
  // 4                |
  // 3                |
  // 2 ☠ ⚐            |
  // 1 ♕ ☠ ♟          |
  //   1 2 3 4 5 6 7 8 
  //
  assert Ok(board) =
    grid.new(8, 8)
    |> result.then(chess.set(_, 1, 1, p1, King, Normal))
    |> result.then(chess.set(_, 1, 2, p2, Pawn, Normal))
    |> result.then(chess.set(_, 2, 1, p2, Pawn, Normal))
    |> result.then(chess.set(_, 3, 1, p2, Pawn, Normal))

  let path = move.project(board, Coordinate(1, 1))

  // ↑ Up path
  assert True = set.contains(path, Coordinate(1, 2))

  // ↗ Top Right projection
  assert True = set.contains(path, Coordinate(2, 2))

  // → Right path
  assert True = set.contains(path, Coordinate(2, 1))

  // ↘ Bottom Right projection
  assert False = set.contains(path, Coordinate(2, 0))

  // ↓ Down path
  assert False = set.contains(path, Coordinate(1, 0))

  // ↙ Bottom Left projection
  assert False = set.contains(path, Coordinate(0, 0))

  // ← Left path
  assert False = set.contains(path, Coordinate(0, 1))

  // ↖ Top Left projection
  assert False = set.contains(path, Coordinate(0, 2))

  assert 3 = set.size(path)
}
