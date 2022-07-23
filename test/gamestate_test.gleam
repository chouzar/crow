//import crow/gamestate.{
//  Azure, Ended, GameState, InProgress, Ivory, NotStarted, Turn,
//}
//
//pub fn new_test() {
//  assert GameState(stage: NotStarted, player: Azure, turn: Turn(0)) =
//    gamestate.new()
//}
//
//pub fn start_test() {
//  assert GameState(stage: InProgress, player: Azure, turn: Turn(1)) =
//    gamestate.new()
//    |> gamestate.start()
//}
//
//pub fn next_test() {
//  assert GameState(stage: InProgress, player: Ivory, turn: Turn(4)) =
//    gamestate.new()
//    |> gamestate.start()
//    |> gamestate.next()
//    |> gamestate.next()
//    |> gamestate.next()
//}
//
//pub fn end_test() {
//  assert GameState(stage: Ended, player: Azure, turn: Turn(1)) =
//    gamestate.new()
//    |> gamestate.start()
//    |> gamestate.end()
//}
//
