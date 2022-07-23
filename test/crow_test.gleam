import gleeunit
//import gleam/map
//import crow.{
//  Bishop, Blocked, Board, Coordinate, Limits, NoPath, NoPiece, OutOfBounds, Piece,
//}
//import crow/setup
//
pub fn main() {
  gleeunit.main()
}
//
//pub fn move_test() {
//  // Board setup
//  // 
//  // 8 ⛚ ⛚ ⛚ ⛚ ⛚ ⛚ ⛚ ⛚
//  // 7 ⛚ ⛚ ⛚ ⛚ ♟ ⛚ ⛚ ⛚
//  // 6 ⛚ ♟ ⛚ ⛿ ⛚ ⛚ ⛚ ⛚
//  // 5 ⛚ ⛚ ♗ ⛚ ⛚ ⛚ ⛚ ⛚
//  // 4 ⛚ ⛿ ⛚ ⛿ ⛚ ⛚ ⛚ ⛚︎
//  // 3 ⛿ ⛚ ⛚ ⛚ ⛿ ⛚ ⛚ ⛚︎
//  // 2 ⛚ ⛚ ⛚ ⛚ ⛚ ⛿ ⛚ ⛚
//  // 1 ⛚ ⛚ ⛚ ⛚ ⛚ ⛚ ♟ ⛚︎
//  //   1  2  3  4  5  6  7  8
//  let board =
//    Board(
//      ..setup.squared_board(8),
//      positions: map.from_list([
//        #(Coordinate(7, 1), setup.pawn()),
//        #(Coordinate(2, 6), setup.pawn()),
//        #(Coordinate(5, 7), setup.pawn()),
//        #(Coordinate(3, 5), setup.bishop()),
//      ]),
//    )
//
//  // Assert that piece can move and that the board positions are updated
//  assert Ok(Board(positions: positions, ..)) =
//    crow.move(board, from: Coordinate(3, 5), to: Coordinate(5, 3))
//
//  assert Ok(Piece(class: Bishop, ..)) = map.get(positions, Coordinate(5, 3))
//  assert Error(Nil) = map.get(positions, Coordinate(3, 4))
//
//  // Assert that piece can not move
//  assert Error(OutOfBounds) =
//    crow.move(board, from: Coordinate(3, 5), to: Coordinate(4, 9))
//  assert Error(NoPiece) =
//    crow.move(board, from: Coordinate(1, 1), to: Coordinate(2, 2))
//  assert Error(NoPath) =
//    crow.move(board, from: Coordinate(3, 5), to: Coordinate(5, 5))
//  assert Error(Blocked) =
//    crow.move(board, from: Coordinate(3, 5), to: Coordinate(5, 7))
//}
//
//pub fn is_in_bounds_test() {
//  let limits = Limits(x: Coordinate(x: 1, y: 1), y: Coordinate(x: 8, y: 8))
//
//  assert True = crow.is_in_bounds(limits, Coordinate(x: 1, y: 1))
//  assert True = crow.is_in_bounds(limits, Coordinate(x: 8, y: 8))
//  assert True = crow.is_in_bounds(limits, Coordinate(x: 4, y: 3))
//  assert True = crow.is_in_bounds(limits, Coordinate(x: 3, y: 4))
//  assert False = crow.is_in_bounds(limits, Coordinate(x: 0, y: 1))
//  assert False = crow.is_in_bounds(limits, Coordinate(x: 9, y: 8))
//  assert False = crow.is_in_bounds(limits, Coordinate(x: 1, y: 0))
//  assert False = crow.is_in_bounds(limits, Coordinate(x: 8, y: 9))
//}
//
//pub fn add_coordinates_test() {
//  assert Coordinate(x: 10, y: 10) =
//    crow.add_coordinates(Coordinate(x: 3, y: 7), Coordinate(x: 7, y: 3))
//
//  assert Coordinate(x: 4, y: -4) =
//    crow.add_coordinates(Coordinate(x: -3, y: -7), Coordinate(x: 7, y: 3))
//
//  assert Coordinate(x: 48, y: 24) =
//    crow.add_coordinates(Coordinate(x: 36, y: 87), Coordinate(x: 12, y: -63))
//}
//
//pub fn clamp_coordinate_test() {
//  let limits = Limits(x: Coordinate(x: 1, y: 1), y: Coordinate(x: 8, y: 8))
//
//  assert Coordinate(1, 1) = crow.clamp_coordinate(Coordinate(-10, -10), limits)
//  assert Coordinate(8, 8) = crow.clamp_coordinate(Coordinate(10, 10), limits)
//  assert Coordinate(3, 7) = crow.clamp_coordinate(Coordinate(3, 7), limits)
//}
//
//pub fn equal_test() {
//  assert True = crow.equal(Coordinate(1, 1), Coordinate(1, 1))
//  assert False = crow.equal(Coordinate(1, 1), Coordinate(1, 0))
//  assert False = crow.equal(Coordinate(1, 1), Coordinate(0, 1))
//  assert False = crow.equal(Coordinate(1, 0), Coordinate(1, 1))
//  assert False = crow.equal(Coordinate(0, 1), Coordinate(1, 1))
//}
