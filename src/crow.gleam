// TODO: Recover gamestate file here

//pub type MoveError {
//  NoPath
//  OutOfBounds
//  Blocked
//  NoPiece
//}
//
//pub fn move(
//  in board: Board,
//  from from: Position,
//  to to: Position,
//) -> Result(Board, MoveError) {
//  try Nil = check_bounds(at: from, in: board)
//  try Nil = check_bounds(at: to, in: board)
//  try Nil = check_piece(at: from, in: board)
//  try Nil = check_move(from: from, to: to, in: board)
//  Ok(update(at: from, to: to, in: board))
//}
//

import gleam/io

pub fn main() {
  io.println("Hello from gleam!")
}
