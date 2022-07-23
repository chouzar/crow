import crow/coordinate as coor
import crow/player
import crow/piece
import crow/grid
import crow/turn

type Player =
  player.Player(String)

type Piece =
  piece.Piece(String)

type Board =
  grid.Grid(Piece)

pub type GameState {
  GameState(players: List(Player), board: Board, turn: turn.Turn)
}

pub fn start() -> GameState {
  assert Ok(state) = setup()
  state
}

pub fn next(state: GameState) -> GameState {
  let board = move(state.board, coor.Coordinate(6, 1), coor.Coordinate(7, 3))
  GameState(..state, board: board)
}

// TODO: Come up with good system for interfacing with modules.
pub fn move(
  in board: Board,
  from from: coor.Coordinate,
  to to: coor.Coordinate,
) -> Board {
  piece.move(board, from, to)
}

fn setup() -> Result(GameState, grid.Error) {
  try board = grid.new(8, 8)

  let azure = player.new("Azure")

  try board = grid.set(board, coor.new(1, 2), piece.Piece(piece.Pawn, azure))
  try board = grid.set(board, coor.new(2, 2), piece.Piece(piece.Pawn, azure))
  try board = grid.set(board, coor.new(3, 2), piece.Piece(piece.Pawn, azure))
  try board = grid.set(board, coor.new(4, 2), piece.Piece(piece.Pawn, azure))
  try board = grid.set(board, coor.new(5, 2), piece.Piece(piece.Pawn, azure))
  try board = grid.set(board, coor.new(6, 2), piece.Piece(piece.Pawn, azure))
  try board = grid.set(board, coor.new(7, 2), piece.Piece(piece.Pawn, azure))
  try board = grid.set(board, coor.new(8, 2), piece.Piece(piece.Pawn, azure))
  try board = grid.set(board, coor.new(1, 1), piece.Piece(piece.Rook, azure))
  try board = grid.set(board, coor.new(8, 1), piece.Piece(piece.Rook, azure))
  try board = grid.set(board, coor.new(2, 1), piece.Piece(piece.Bishop, azure))
  try board = grid.set(board, coor.new(7, 1), piece.Piece(piece.Bishop, azure))
  try board = grid.set(board, coor.new(3, 1), piece.Piece(piece.Knight, azure))
  try board = grid.set(board, coor.new(6, 1), piece.Piece(piece.Knight, azure))
  try board = grid.set(board, coor.new(4, 1), piece.Piece(piece.King, azure))
  try board = grid.set(board, coor.new(5, 1), piece.Piece(piece.Queen, azure))

  let ivory = player.new("Ivory")

  try board = grid.set(board, coor.new(1, 7), piece.Piece(piece.Pawn, ivory))
  try board = grid.set(board, coor.new(2, 7), piece.Piece(piece.Pawn, ivory))
  try board = grid.set(board, coor.new(3, 7), piece.Piece(piece.Pawn, ivory))
  try board = grid.set(board, coor.new(4, 7), piece.Piece(piece.Pawn, ivory))
  try board = grid.set(board, coor.new(5, 7), piece.Piece(piece.Pawn, ivory))
  try board = grid.set(board, coor.new(6, 7), piece.Piece(piece.Pawn, ivory))
  try board = grid.set(board, coor.new(7, 7), piece.Piece(piece.Pawn, ivory))
  try board = grid.set(board, coor.new(8, 7), piece.Piece(piece.Pawn, ivory))
  try board = grid.set(board, coor.new(1, 8), piece.Piece(piece.Rook, ivory))
  try board = grid.set(board, coor.new(8, 8), piece.Piece(piece.Rook, ivory))
  try board = grid.set(board, coor.new(2, 8), piece.Piece(piece.Bishop, ivory))
  try board = grid.set(board, coor.new(7, 8), piece.Piece(piece.Bishop, ivory))
  try board = grid.set(board, coor.new(3, 8), piece.Piece(piece.Knight, ivory))
  try board = grid.set(board, coor.new(6, 8), piece.Piece(piece.Knight, ivory))
  try board = grid.set(board, coor.new(4, 8), piece.Piece(piece.King, ivory))
  try board = grid.set(board, coor.new(5, 8), piece.Piece(piece.Queen, ivory))

  Ok(GameState(
    players: player.players([azure, ivory]),
    board: board,
    turn: turn.start(),
  ))
}
