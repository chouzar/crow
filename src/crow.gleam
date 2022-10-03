
// Runtime
// TODO: Later, there should be a function for a session that is being filled with players.
// TODO: For a GUI system, there should be a way to compose comands by tracking player's input.
// TODO: Should a transcript of the game be stored? How long?
//
// Logic
// TODO: Work on message fields for errors and warnings.
// TODO: Booleans are unnecessary for the check field, could be represented by a list of coordinates.
// TODO: Optimize some of the data-structures to cache information being retrieved over and over.
// TODO: Chess move decoder/encoder.
// TODO: Much much detailed an clearer messages on errors.
// TODO: Check would be an interesting feature for all pieces, not only for king. 
// TODO: Posibly step rules now need to carry the whole gamestate
// Then that info could be stored on Space instead of Gamestate.
//

import crow/coordinate.{Coordinate}
import crow/player.{Player}
import crow/piece.{Piece}
import crow/round.{Round}
import crow/board.{Board}
import gleam/bit_string
import gleam/option
import gleam/list
import gleam/map.{Map}
import gleam/set

// De un tablero me gustaría obtener la siguiente información:
// * Un set de coordenadas jugador A
// * Un set de coordenadas jugador B 
// * Reyes de jugador A | B
// * Limites del tablero
// * El jugador actual
// * La pieza actual 
// * La dirección actual
// * La coordenada actual

/// This module is meant ot be an easy to use interface that make use of subsystems:
///
/// * Board state
/// * Player's round 
/// * The turns phases
/// subsystems
const upwards = Coordinate(1, 1)

const downwards = Coordinate(1, -1)

pub type Gamestate {
  Gamestate(round: Round, board: Board)
}

pub fn new() -> Gamestate {
  Gamestate(round: round.new(), board: board.new())
}

pub fn players(state: Gamestate, p1: String, p2: String) -> Gamestate {
  let p1 = Player(p1)
  let p2 = Player(p2)

  let round =
    state.round
    |> round.add_player(p1)
    |> round.add_player(p2)

  let board =
    state.board
    |> board.set_facing(p1, upwards)
    |> board.set_facing(p2, downwards)

  Gamestate(round: round, board: board)
}

pub fn deploy(
  state: Gamestate,
  position: String,
  player: String,
  piece: Piece,
) -> Gamestate {
  let position = parse_position(position)
  let player = parse_player(player)

  let board =
    state.board
    |> board.deploy(position, player, piece)

  Gamestate(..state, board: board)
}

pub type Check {
  Check(
    player: Player,
    piece: Piece,
    path: List(Coordinate),
    captures: List(Coordinate),
  )
}

pub fn get_positions(state: Gamestate) -> Map(Coordinate, Check) {
  state.board
  |> board.all()
  |> map.map_values(fn(_, check) { to_move(check) })
}

pub fn get_position(state: Gamestate, position: String) -> Check {
  let position = parse_position(position)

  state.board
  |> board.get(position)
  |> to_move()
}

fn to_move(check) {
  let player = check.player

  let piece = check.piece

  let path =
    check.paths
    |> list.map(fn(path) { path.positions })
    |> list.flatten()
    |> set.from_list()
    |> set.to_list()

  let captures =
    check.paths
    |> list.map(fn(path) { path.capture })
    |> option.values()

  Check(player, piece, path, captures)
}

fn parse_player(player: String) -> Player {
  Player(player)
}

fn parse_position(position: String) -> Coordinate {
  let <<file:utf8_codepoint, rank:utf8_codepoint>> =
    bit_string.from_string(position)

  Coordinate(parse_file(file), parse_rank(rank))
}

fn parse_file(file: UtfCodepoint) -> Int {
  case <<file:utf8_codepoint>> {
    <<"A":utf8>> -> 1
    <<"B":utf8>> -> 2
    <<"C":utf8>> -> 3
    <<"D":utf8>> -> 4
    <<"E":utf8>> -> 5
    <<"F":utf8>> -> 6
    <<"G":utf8>> -> 7
    <<"H":utf8>> -> 8
    <<"1":utf8>> -> 1
    <<"2":utf8>> -> 2
    <<"3":utf8>> -> 3
    <<"4":utf8>> -> 4
    <<"5":utf8>> -> 5
    <<"6":utf8>> -> 6
    <<"7":utf8>> -> 7
    <<"8":utf8>> -> 8
  }
}

fn parse_rank(rank: UtfCodepoint) -> Int {
  case <<rank:utf8_codepoint>> {
    <<"1":utf8>> -> 1
    <<"2":utf8>> -> 2
    <<"3":utf8>> -> 3
    <<"4":utf8>> -> 4
    <<"5":utf8>> -> 5
    <<"6":utf8>> -> 6
    <<"7":utf8>> -> 7
    <<"8":utf8>> -> 8
  }
}
