//// Wraps chess.next function into a wrapper that asserts moves

//import gleam/map
//import crow/coordinate.{Coordinate}
//import crowround.{Player}
//import crowpiece.{Bishop, King, Knight, Pawn, Queen, Rook}
//import crow/board/grid.{Grid, Limits}
//import chess.{GameState, Playing, Setup}
//
//pub fn setup_test() {
//  // Check initial gamestage
//  assert GameState(stage: Setup, turn: 0, board: board, ..) =
//    chess.setup("Bone", "Rock")
//
//  // Check that grid is 8 by 8 
//  assert Grid(
//    limits: Limits(Coordinate(x: 1, y: 1), Coordinate(x: 8, y: 8)),
//    positions: positions,
//  ) = board
//
//  // Check pieces on board
//  assert 32 = map.size(positions)
//}
//
//pub fn start_test() {
//  assert GameState(stage: Playing, turn: 1, ..) =
//    chess.setup("Bone", "Rock")
//    |> chess.start()
//}
//
//pub fn play_test() {
//  // A game by Viswanathan Anand (Rock) and Levon Aronian (Bone)
//  // From: https://www.chess.com/games/view/13459415
//
//  let state =
//    chess.setup("Bone", "Rock")
//    |> chess.start()
//    |> next("Bone", Pawn, at: #(D, 2), to: #(D, 4))
//    |> next("Rock", Pawn, at: #(D, 7), to: #(D, 5))
//    |> next("Bone", Pawn, at: #(C, 2), to: #(C, 4))
//    |> next("Rock", Pawn, at: #(C, 7), to: #(C, 6))
//    |> next("Bone", Knight, at: #(G, 1), to: #(F, 3))
//    |> next("Rock", Knight, at: #(G, 8), to: #(F, 6))
//    |> next("Bone", Knight, at: #(B, 1), to: #(C, 3))
//    |> next("Rock", Pawn, at: #(E, 7), to: #(E, 6))
//    |> next("Bone", Pawn, at: #(E, 2), to: #(E, 3))
//    |> next("Rock", Knight, at: #(B, 8), to: #(D, 7))
//    |> next("Bone", Bishop, at: #(F, 1), to: #(D, 3))
//    |> next("Rock", Pawn, at: #(D, 5), to: #(C, 4))
//    |> next("Bone", Bishop, at: #(D, 3), to: #(C, 4))
//    |> next("Rock", Pawn, at: #(B, 7), to: #(B, 5))
//    |> next("Bone", Bishop, at: #(C, 4), to: #(D, 3))
//    |> next("Rock", Bishop, at: #(F, 8), to: #(D, 6))
//    // Next "Bone" move applies a castling, castling is not implemented
//    |> castle(#(E, 1), #(G, 1), #(H, 1), #(F, 1))
//    // Next "Rock" move applies a castling, castling is not implemented
//    |> castle(#(E, 8), #(G, 8), #(H, 8), #(F, 8))
//    |> next("Bone", Queen, at: #(D, 1), to: #(C, 2))
//    |> next("Rock", Bishop, at: #(C, 8), to: #(B, 7))
//    |> next("Bone", Pawn, at: #(A, 2), to: #(A, 3))
//    |> next("Rock", Rook, at: #(A, 8), to: #(C, 8))
//    |> next("Bone", Knight, at: #(F, 3), to: #(G, 5))
//    |> next("Rock", Pawn, at: #(C, 6), to: #(C, 5))
//    |> next("Bone", Knight, at: #(G, 5), to: #(H, 7))
//    |> next("Rock", Knight, at: #(F, 6), to: #(G, 4))
//    |> next("Bone", Pawn, at: #(F, 2), to: #(F, 4))
//    |> next("Rock", Pawn, at: #(C, 5), to: #(D, 4))
//    |> next("Bone", Pawn, at: #(E, 3), to: #(D, 4))
//    |> next("Rock", Bishop, at: #(D, 6), to: #(C, 5))
//    |> next("Bone", Bishop, at: #(D, 3), to: #(E, 2))
//    |> next("Rock", Knight, at: #(D, 7), to: #(E, 5))
//    |> next("Bone", Bishop, at: #(E, 2), to: #(G, 4))
//    |> next("Rock", Bishop, at: #(C, 5), to: #(D, 4))
//    |> next("Bone", King, at: #(G, 1), to: #(H, 1))
//    |> next("Rock", Knight, at: #(E, 5), to: #(G, 4))
//    |> next("Bone", Knight, at: #(H, 7), to: #(F, 8))
//    |> next("Rock", Pawn, at: #(F, 7), to: #(F, 5))
//    |> next("Bone", Knight, at: #(F, 8), to: #(G, 6))
//    |> next("Rock", Queen, at: #(D, 8), to: #(F, 6))
//    |> next("Bone", Pawn, at: #(H, 2), to: #(H, 3))
//    |> next("Rock", Queen, at: #(F, 6), to: #(G, 6))
//    |> next("Bone", Queen, at: #(C, 2), to: #(E, 2))
//    |> next("Rock", Queen, at: #(G, 6), to: #(H, 5))
//    |> next("Bone", Queen, at: #(E, 2), to: #(D, 3))
//    |> next("Rock", Bishop, at: #(D, 4), to: #(E, 3))
//
//  // Play ends in a draw won by points by Viswanathan Anand
//  // Check pieces on board
//  assert 22 = map.size(state.board.positions)
//}
//
//type Files {
//  A
//  B
//  C
//  D
//  E
//  F
//  G
//  H
//}
//
//fn next(state, player, piece, at from, to to) -> GameState {
//  let from = to_coordinate(from)
//  let to = to_coordinate(to)
//
//  let state = chess.next(state, from, to)
//
//  assert Error(Nil) = map.get(state.board.positions, from)
//  assert Ok(space) = map.get(state.board.positions, to)
//
//  assert True = check.player == Player(player)
//  assert True = check.piece == piece
//
//  state
//}
//
//fn castle(
//  state: GameState,
//  at_a: #(Files, Int),
//  to_a: #(Files, Int),
//  at_b: #(Files, Int),
//  to_b: #(Files, Int),
//) -> GameState {
//  let at_a = to_coordinate(at_a)
//  let to_a = to_coordinate(to_a)
//  let at_b = to_coordinate(at_b)
//  let to_b = to_coordinate(to_b)
//
//  let positions = state.board.positions
//
//  assert Ok(space_a) = map.get(positions, at_a)
//  assert Ok(space_b) = map.get(positions, at_b)
//
//  let positions =
//    positions
//    |> map.delete(at_a)
//    |> map.delete(at_b)
//    |> map.insert(to_a, space_a)
//    |> map.insert(to_b, space_b)
//
//  let board = Grid(..state.board, positions: positions)
//  GameState(..state, board: board)
//}
//
//fn to_coordinate(record: #(Files, Int)) -> Coordinate {
//  let rank = record.1
//
//  let file = case record.0 {
//    A -> 1
//    B -> 2
//    C -> 3
//    D -> 4
//    E -> 5
//    F -> 6
//    G -> 7
//    H -> 8
//  }
//
//  Coordinate(file, rank)
//}
//
