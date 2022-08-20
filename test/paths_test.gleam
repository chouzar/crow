// TODO: Figure out an elegan way to test this thoroughly
// TODO: Match on the projected coordinates only, per piece or by all
// TODO: 3 scenarios per piece: Free | Blocked | Eat
//  // Check gamestate on start
//  assert GameState(stage: Playing, turn: 1, board: board, ..) =
//    chess.setup("Bone", "Charcoal")
//    |> chess.start()
//
//  // TODO: On trace we must be able to specify a transform in the direction
//  // TODO: Posibly step rules now need to carry the whole gamestate
//  // Check initial calculated paths
//  // 8 ♜ ♞ ♝ ♛ ♚ ♝ ♞ ♜
//  // 7 ♟ ♟ ♟ ♟ ♟ ♟ ♟ ♟︎
//  // 6 ⚐ ⚐ ⚐ ⚐ ⚐ ⚐ ⚐ ⚐
//  // 5 ⚐ ⚐ ⚐ ⚐ ⚐ ⚐ ⚐ ⚐
//  // 4 ⚐ ⚐ ⚐ ⚐ ⚐ ⚐ ⚐ ⚐
//  // 3 ⚐ ⚐ ⚐ ⚐ ⚐ ⚐ ⚐ ⚐
//  // 2 ♙ ♙ ♙ ♙ ♙ ♙ ♙ ♙
//  // 1 ♖ ♘ ♗ ♕ ♔ ♗ ♘ ♖
//  //   1 2 3 4 5 6 7 8 
//  let paths =
//    board.positions
//    |> map.map_values(fn(_coordinate, space) { space.path })
//    |> map.values()
//
//  let 32 =
//    paths
//    |> list.fold(set.new(), set.union)
//    |> io.debug()
//    |> set.take(keeping: range(#(1, 8), #(3, 6)))
//    |> set.size()
//
//fn range(rows, columns) -> List(Coordinate) {
//  let row_range = list.range(rows.0, rows.1)
//  let col_range = list.range(columns.0, columns.1)
//
//  list.map(row_range, fn(x) { list.map(col_range, fn(y) { Coordinate(x, y) }) })
//  |> list.flatten()
//}
