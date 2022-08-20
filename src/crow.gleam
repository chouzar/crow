// PRESENTATION - Gleam is expressive
//
// Gleam is fairly simple and in some ways syntax is less expressive than what
// can be found in erlang or elixir: 
//
// * Lack of literals
// * Lack of branching options
// * Lack of macro system
// * No behaviour or protocol system
//
// But is just as capable of modelling most problem domains:
//
// * "Open" domain through types public types
// * Constained set of operations through opaque types
//   * Api might be "flexible", next = gamestate -> next -> gamestate
//   * Api might be "precise", next = gamestate -> gamestate
//
// May or not require assertion checks when depending on Result types
//   * Result types can be composed together
//   * But composition can also be achieved with pipes
//   * Or a custom mechanism to apply types or functions
//
// We may add to this type through Generics.

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
