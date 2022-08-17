// Chess board
//
// 8 ♜ ♞ ♝ ♛ ♚ ♝ ♞ ♜
// 7 ♟ ♟ ♟ ♟ ♟ ♟ ♟ ♟︎
// 6 
// 5 
// 4 
// 3 
// 2 ♙ ♙ ♙ ♙ ♙ ♙ ♙ ♙
// 1 ♖ ♘ ♗ ♕ ♔ ♗ ♘ ♖
//   1 2 3 4 5 6 7 8 
//

// 3 ⛿ ⛚ ⛚ ⛚  
// 2 ⛿ ⛚ ⛚ ⛚  
// 1 ⛿ ⛚ ⛚ ⛚ 
// 0 ☠ ⛚ ⛚ ⛚ 
//   0  1  2  3  

//// TODO: Only test for piece movements, we may disregard the projection 

//import crow/grid
//import crow/coordinate.{Coordinate}
//import crow/trace
//import crow/piece.{OutOfBounds}
//import crow/player
//
//pub fn project_rook_test() {
//  assert Ok(grid) = grid.new(8, 8)
//
//  // projects until reaching board bounds
//  // 
//  // 8 ⛚ ⛚ ⛚ ⛚ ⛿ ⛚ ⛚ ⛚ 
//  // 7 ⛚ ⛚ ⛚ ⛚ ⛿ ⛚ ⛚ ⛚ 
//  // 6 ⛚ ⛚ ⛚ ⛚ ⛿ ⛚ ⛚ ⛚ 
//  // 5 ⛚ ⛚ ⛚ ⛚ ⛿ ⛚ ⛚ ⛚ 
//  // 4 ⛿ ⛿ ⛿ ⛿ ♜ ⛿ ⛿ ⛿ 
//  // 3 ⛚ ⛚ ⛚ ⛚ ⛿ ⛚ ⛚ ⛚ 
//  // 2 ⛚ ⛚ ⛚ ⛚ ⛿ ⛚ ⛚ ⛚ 
//  // 1 ⛚ ⛚ ⛚ ⛚ ⛿ ⛚ ⛚ ⛚ 
//  //   1  2  3  4  5  6  7  8
//
//  assert [up, right, _, _] =
//    piece.project_rook(
//      grid,
//      Coordinate(5, 4),
//      Player("Azure")
//    )
//
//  // Some of this info is redundant for all coordinates, like from
//  // Path(from: Coordinate, open_moves: MapSet(Coordinate), trace: PieceTrace)
//  // PieceTrace {
//  //  Pawn(up: List(Coordinate), upper_right: List(Coordinate), upper_left: List(Coordinate))
//  //  Rook(up: List(Coordinate), right: List(Coordinate), down: List(Coordinate), left: List(Coordinate))
//  // }
//  assert OutOfBounds = up.reason
//  assert 4 = trace.get_step(up.trace)
//  assert Coordinate(5, 4) = trace.get_from(up.trace)
//  assert Coordinate(5, 8) = trace.get_position(up.trace)
//  assert [Coordinate(5, 8), Coordinate(5, 7), Coordinate(5, 6), Coordinate(5, 5)] = trace.get_path(up.trace)
//  
//  assert OutOfBounds = right.reason
//  assert 3 = trace.get_step(right.trace)
//  assert Coordinate(5, 4) = trace.get_from(right.trace)
//  assert Coordinate(8, 4) = trace.get_position(right.trace)
//  assert [Coordinate(8, 4), Coordinate(7, 4), Coordinate(6, 4)] = trace.get_path(right.trace)
//}

//pub fn project_test() {
//  assert Ok(grid) = grid.new(4, 4)
//
//  //   1  2  3  4  
//  // 1 ☠ ⛚ ⛚ ⛚  
//  // 2 ⛚ ⛿ ⛚ ⛚  
//  // 3 ⛚ ⛚ ⛿ ⛚ 
//  // 4 ⛚ ⛚ ⛚ ⛿  
//  let projection =
//    direction.project(
//      grid,
//      Coordinate(1, 1),
//      Move(Coordinate(1, 1), Continuous),
//    )
//
//  assert False = set.contains(projection, Coordinate(1, 1))
//  assert False = set.contains(projection, Coordinate(1, 2))
//  assert False = set.contains(projection, Coordinate(1, 3))
//  assert False = set.contains(projection, Coordinate(1, 4))
//  assert False = set.contains(projection, Coordinate(2, 1))
//  assert True = set.contains(projection, Coordinate(2, 2))
//  assert False = set.contains(projection, Coordinate(2, 3))
//  assert False = set.contains(projection, Coordinate(2, 4))
//  assert False = set.contains(projection, Coordinate(3, 1))
//  assert False = set.contains(projection, Coordinate(3, 2))
//  assert True = set.contains(projection, Coordinate(3, 3))
//  assert False = set.contains(projection, Coordinate(3, 4))
//  assert False = set.contains(projection, Coordinate(4, 1))
//  assert False = set.contains(projection, Coordinate(4, 2))
//  assert False = set.contains(projection, Coordinate(4, 3))
//  assert True = set.contains(projection, Coordinate(4, 4))
//
//  //   1  2  3  4  
//  // 1 ⛚ ⛚ ☠ ⛚  
//  // 2 ⛚ ⛚ ⛿ ⛚  
//  // 3 ⛚ ⛚ ⛿ ⛚ 
//  // 4 ⛚ ⛚ ⛚ ⛚ 
//  let projection =
//    direction.project(grid, Coordinate(3, 1), Move(Coordinate(0, 1), Steps(2)))
//
//  assert False = set.contains(projection, Coordinate(1, 1))
//  assert False = set.contains(projection, Coordinate(1, 2))
//  assert False = set.contains(projection, Coordinate(1, 3))
//  assert False = set.contains(projection, Coordinate(1, 4))
//  assert False = set.contains(projection, Coordinate(2, 1))
//  assert False = set.contains(projection, Coordinate(2, 2))
//  assert False = set.contains(projection, Coordinate(2, 3))
//  assert False = set.contains(projection, Coordinate(2, 4))
//  assert False = set.contains(projection, Coordinate(3, 1))
//  assert True = set.contains(projection, Coordinate(3, 2))
//  assert True = set.contains(projection, Coordinate(3, 3))
//  assert False = set.contains(projection, Coordinate(3, 4))
//  assert False = set.contains(projection, Coordinate(4, 1))
//  assert False = set.contains(projection, Coordinate(4, 2))
//  assert False = set.contains(projection, Coordinate(4, 3))
//  assert False = set.contains(projection, Coordinate(4, 4))
//}
//
//