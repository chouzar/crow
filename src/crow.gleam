import crow/coordinate.{Coordinate}
import crow/player.{Player}
import crow/piece.{Piece}
import crow/players
import crow/round
import crow/board
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
  Gamestate(players: players.Players, round: round.Round, board: board.Board)
}

pub fn new() -> Gamestate {
  Gamestate(players: players.new(), round: round.new(), board: board.new())
}

pub fn players(state: Gamestate, p1: String, p2: String) -> Gamestate {
  let p1 = Player(p1)
  let p2 = Player(p2)

  let players =
    state.players
    |> players.add(p1, upwards)
    |> players.add(p2, downwards)

  Gamestate(..state, players: players)
}

pub fn deploy(
  state: Gamestate,
  position: String,
  player: String,
  piece: Piece,
) -> Gamestate {
  let position = parse_position(position)
  let player = parse_player(player)

  let facing =
    state.players
    |> players.get_facing(player)

  let board =
    state.board
    |> board.deploy(position, player, facing, piece)

  Gamestate(..state, board: board)
}

pub fn move(
  state: Gamestate,
  from_position: String,
  to_position: String,
) -> Gamestate {
  let from = parse_position(from_position)
  let to = parse_position(to_position)

  let board =
    state.board
    |> board.move(from, to)

  Gamestate(..state, board: board)
}

pub fn next(state: Gamestate) -> Gamestate {
  let players =
    state.players
    |> players.rotate()

  let round =
    state.round
    |> round.next()

  Gamestate(..state, players: players, round: round)
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

pub fn get_turn(state: Gamestate) -> Int {
  round.get_turn(state.round)
}

pub fn get_players(state: Gamestate) -> List(String) {
  state.players
  |> players.get_players()
  |> list.map(fn(player) { player.id })
}

pub fn get_current_player(state: Gamestate) -> String {
  let Player(id) = players.get_current(state.players)
  id
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
