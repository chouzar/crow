import crow/coordinate.{Coordinate}
import crow/piece
import crow
import gleam/bit_string
import gleam/list
import gleam/set
import gleam/io

// Example unicode board
//   _ _ _ _ _ _ _ _
// 8 ♜ ♞ ♝ ♛ ♚ ♝ ♞ ♜|
// 7 ♟ ♟ ♟ ♟ ♟ ♟ ♟ ♟︎|
// 6         ⚐      |
// 5         ☠      |
// 4                |
// 3                |
// 2 ♙ ♙ ♙ ♙ ♙ ♙ ♙ ♙|
// 1 ♖ ♘ ♗ ♕ ♔ ♗ ♘ ♖|
//   A B C D E F G H 
//   1 2 3 4 5 6 7 8 

pub fn pawn_twice_path_test() {
  // Assert that pawn can move 2 spaces on 1st line
  //   _ _ _ _ _ _ _ _
  // 8                |
  // 7                |
  // 6                |
  // 5                |
  // 4                |
  // 3     ⚐          |
  // 2     ⚐          |
  // 1     ♙          |
  //   A B C D E F G H 

  let move =
    crow.new()
    |> crow.players("bone", "charcoal")
    |> crow.deploy("C1", "bone", piece.Pawn)
    |> crow.get_position("C1")

  assert_path(move.path, ["C2", "C3"])
  assert_path(move.captures, [])

  // Assert that pawn can move 2 spaces on 2nd line
  //   _ _ _ _ _ _ _ _
  // 8                |
  // 7                |
  // 6                |
  // 5                |
  // 4     ⚐          |
  // 3     ⚐          |
  // 2     ♙          |
  // 1                |
  //   A B C D E F G H 
  //
  let move =
    crow.new()
    |> crow.players("bone", "charcoal")
    |> crow.deploy("C2", "bone", piece.Pawn)
    |> crow.get_position("C2")

  assert_path(move.path, ["C3", "C4"])
  assert_path(move.captures, [])

  // Assert that pawn can move 2 spaces on 8th line
  //   _ _ _ _ _ _ _ _
  // 8           ♟    |
  // 7           ⚐    |
  // 6           ⚐    |
  // 5                |
  // 4                |
  // 3                |
  // 2                |
  // 1                |
  //   A B C D E F G H 
  //
  let move =
    crow.new()
    |> crow.players("bone", "charcoal")
    |> crow.deploy("F8", "charcoal", piece.Pawn)
    |> crow.get_position("F8")

  assert_path(move.path, ["F7", "F6"])
  assert_path(move.captures, [])

  // Assert that pawn can move 2 spaces on 7th line
  //   _ _ _ _ _ _ _ _
  // 8                |
  // 7           ♟    |
  // 6           ⚐    |
  // 5           ⚐    |
  // 4                |
  // 3                |
  // 2                |
  // 1                |
  //   A B C D E F G H 
  //
  let move =
    crow.new()
    |> crow.players("bone", "charcoal")
    |> crow.deploy("F7", "charcoal", piece.Pawn)
    |> crow.get_position("F7")

  assert_path(move.path, ["F6", "F5"])
  assert_path(move.captures, [])
}

pub fn pawn_path_test() {
  // Assert that pawn can move 1 space on any other line
  //   _ _ _ _ _ _ _ _
  // 8                |
  // 7                |
  // 6                |
  // 5     ⚐          |
  // 4     ♙          |
  // 3                |
  // 2                |
  // 1                |
  //   A B C D E F G H 
  //
  let move =
    crow.new()
    |> crow.players("bone", "charcoal")
    |> crow.deploy("C4", "bone", piece.Pawn)
    |> crow.get_position("C4")

  assert_path(move.path, ["C5"])
  assert_path(move.captures, [])

  // Assert that pawn can move 1 space on any other line
  //   _ _ _ _ _ _ _ _
  // 8                |
  // 7                |
  // 6                |
  // 5           ♟    |
  // 4           ⚐    |
  // 3                |
  // 2                |
  // 1                |
  //   A B C D E F G H 
  //
  let move =
    crow.new()
    |> crow.players("bone", "charcoal")
    |> crow.deploy("F5", "charcoal", piece.Pawn)
    |> crow.get_position("F5")

  assert_path(move.path, ["F4"])
  assert_path(move.captures, [])
}

pub fn pawn_block_test() {
  // Assert that pawn can be blocked 
  //   _ _ _ _ _ _ _ _
  // 8                |
  // 7                |
  // 6                |
  // 5     ♞          |
  // 4     ♙          |
  // 3                |
  // 2                |
  // 1                |
  //   A B C D E F G H 
  //
  let move =
    crow.new()
    |> crow.players("bone", "charcoal")
    |> crow.deploy("C4", "bone", piece.Pawn)
    |> crow.deploy("C5", "bone", piece.Knight)
    |> crow.get_position("C4")

  assert_path(move.path, [])
  assert_path(move.captures, [])

  // Assert that pawn can be blocked 
  //   _ _ _ _ _ _ _ _
  // 8                |
  // 7                |
  // 6                |
  // 5           ♟    |
  // 4           ♘    |
  // 3                |
  // 2                |
  // 1                |
  //   A B C D E F G H 
  //
  let move =
    crow.new()
    |> crow.players("bone", "charcoal")
    |> crow.deploy("F5", "charcoal", piece.Pawn)
    |> crow.deploy("F4", "bone", piece.Knight)
    |> crow.get_position("F5")

  assert_path(move.path, [])
  assert_path(move.captures, [])

  // Assert that pawn can attack 
  //   _ _ _ _ _ _ _ _
  // 8                |
  // 7                |
  // 6                |
  // 5   ♘ ⚐ ♘        |
  // 4     ♙          |
  // 3                |
  // 2                |
  // 1                |
  //   A B C D E F G H 
  //
  let move =
    crow.new()
    |> crow.players("bone", "charcoal")
    |> crow.deploy("C4", "bone", piece.Pawn)
    |> crow.deploy("B5", "bone", piece.Knight)
    |> crow.deploy("D5", "bone", piece.Knight)
    |> crow.get_position("C4")

  assert_path(move.path, ["C5"])
  assert_path(move.captures, [])

  // Assert that pawn can attack 
  //   _ _ _ _ _ _ _ _
  // 8                |
  // 7                |
  // 6                |
  // 5           ♟    |
  // 4         ♞ ⚐ ♞  |
  // 3                |
  // 2                |
  // 1                |
  //   A B C D E F G H 
  //
  let move =
    crow.new()
    |> crow.players("bone", "charcoal")
    |> crow.deploy("F5", "charcoal", piece.Pawn)
    |> crow.deploy("E4", "charcoal", piece.Knight)
    |> crow.deploy("G4", "charcoal", piece.Knight)
    |> crow.get_position("F5")

  assert_path(move.path, ["F4"])
  assert_path(move.captures, [])
}

pub fn pawn_attack_test() {
  // Assert that pawn can attack 
  //   _ _ _ _ _ _ _ _
  // 8                |
  // 7                |
  // 6                |
  // 5   ☠ ⚐ ☠        |
  // 4     ♙          |
  // 3                |
  // 2                |
  // 1                |
  //   A B C D E F G H 
  //
  let move =
    crow.new()
    |> crow.players("bone", "charcoal")
    |> crow.deploy("C4", "bone", piece.Pawn)
    |> crow.deploy("B5", "charcoal", piece.Knight)
    |> crow.deploy("D5", "charcoal", piece.Knight)
    |> crow.get_position("C4")

  assert_path(move.path, ["B5", "C5", "D5"])
  assert_path(move.captures, ["B5", "D5"])

  // Assert that pawn can attack 
  //   _ _ _ _ _ _ _ _
  // 8                |
  // 7                |
  // 6                |
  // 5           ♟    |
  // 4         ☠ ⚐ ☠  |
  // 3                |
  // 2                |
  // 1                |
  //   A B C D E F G H 
  //
  let move =
    crow.new()
    |> crow.players("bone", "charcoal")
    |> crow.deploy("F5", "charcoal", piece.Pawn)
    |> crow.deploy("E4", "bone", piece.Knight)
    |> crow.deploy("G4", "bone", piece.Knight)
    |> crow.get_position("F5")

  assert_path(move.path, ["E4", "F4", "G4"])
  assert_path(move.captures, ["E4", "G4"])
}

pub fn rook_path_test() {
  // Assert that rook can move to all directions
  //   _ _ _ _ _ _ _ _
  // 8       ⚐        |
  // 7       ⚐        |
  // 6       ⚐        |
  // 5       ⚐        |
  // 4 ⚐ ⚐ ⚐ ♖ ⚐ ⚐ ⚐ ⚐|
  // 3       ⚐        |
  // 2       ⚐        |
  // 1       ⚐        |
  //   A B C D E F G H 
  //
  let move =
    crow.new()
    |> crow.players("bone", "charcoal")
    |> crow.deploy("D4", "bone", piece.Rook)
    |> crow.get_position("D4")

  assert_path(
    move.path,
    [
      "D5", "D6", "D7", "D8", "E4", "F4", "G4", "H4", "D3", "D2", "D1", "C4",
      "B4", "A4",
    ],
  )
  assert_path(move.captures, [])
}

pub fn rook_attack_test() {
  // Assert that rook can move and capture
  //   _ _ _ _ _ _ _ _
  // 8       ♟        |
  // 7       ♟        |
  // 6       ☠        |
  // 5       ⚐        |
  // 4 ☠ ⚐ ⚐ ♖ ⚐ ⚐ ☠  |
  // 3       ☠        |
  // 2                |
  // 1                |
  //   A B C D E F G H 
  //
  let move =
    crow.new()
    |> crow.players("bone", "charcoal")
    |> crow.deploy("D4", "bone", piece.Rook)
    |> crow.deploy("D6", "charcoal", piece.Pawn)
    |> crow.deploy("D7", "charcoal", piece.Pawn)
    |> crow.deploy("D8", "charcoal", piece.Pawn)
    |> crow.deploy("G4", "charcoal", piece.Pawn)
    |> crow.deploy("D3", "charcoal", piece.Pawn)
    |> crow.deploy("A4", "charcoal", piece.Pawn)
    |> crow.get_position("D4")

  assert_path(move.path, ["D5", "D6", "E4", "F4", "G4", "D3", "C4", "B4", "A4"])
  assert_path(move.captures, ["D6", "G4", "D3", "A4"])
}

pub fn knight_path_test() {
  // Assert that knight can move to all directions
  //   _ _ _ _ _ _ _ _
  // 8                |
  // 7                |
  // 6     ⚐   ⚐      |
  // 5   ⚐       ⚐    |
  // 4       ♘        |
  // 3   ⚐       ⚐    |
  // 2     ⚐   ⚐      |
  // 1                |
  //   A B C D E F G H 
  //
  let move =
    crow.new()
    |> crow.players("bone", "charcoal")
    |> crow.deploy("D4", "bone", piece.Knight)
    |> crow.get_position("D4")

  assert_path(move.path, ["E6", "F5", "F3", "E2", "C2", "B3", "B5", "C6"])
  assert_path(move.captures, [])
}

pub fn knight_attack_test() {
  // Assert that knight can capture and be blocked by board limits
  //   _ _ _ _ _ _ _ _
  // 8                |
  // 7                |
  // 6                |
  // 5                |
  // 4 ⚐   ☠          |
  // 3       ☠        |
  // 2   ♘            |
  // 1       ⚐        | 
  //   A B C D E F G H 
  //
  let move =
    crow.new()
    |> crow.players("bone", "charcoal")
    |> crow.deploy("B2", "bone", piece.Knight)
    |> crow.deploy("A4", "charcoal", piece.Pawn)
    |> crow.deploy("C4", "charcoal", piece.Pawn)
    |> crow.deploy("D3", "charcoal", piece.Pawn)
    |> crow.deploy("D1", "charcoal", piece.Pawn)
    |> crow.get_position("B2")

  assert_path(move.path, ["A4", "C4", "D3", "D1"])
  assert_path(move.captures, ["A4", "C4", "D3", "D1"])
}

pub fn bishop_path_test() {
  // Assert that bishop can move to all directions
  //   _ _ _ _ _ _ _ _
  // 8               ⚐|
  // 7 ⚐           ⚐  |
  // 6   ⚐       ⚐    |
  // 5     ⚐   ⚐      |
  // 4       ♗        |
  // 3     ⚐   ⚐      |
  // 2   ⚐       ⚐    |
  // 1 ⚐           ⚐  |
  //   A B C D E F G H 
  //
  let move =
    crow.new()
    |> crow.players("bone", "charcoal")
    |> crow.deploy("D4", "bone", piece.Bishop)
    |> crow.get_position("D4")

  assert_path(
    move.path,
    [
      "E5", "F6", "G7", "H8", "E3", "F2", "G1", "C3", "B2", "A1", "C5", "B6",
      "A7",
    ],
  )
  assert_path(move.captures, [])
}

pub fn bishop_attack_test() {
  // Assert that bishop can capture
  //   _ _ _ _ _ _ _ _
  // 8               ♟|
  // 7 ☠           ♟  |
  // 6   ⚐       ☠    |
  // 5     ⚐   ⚐      |
  // 4       ♗        |
  // 3     ☠   ⚐      |
  // 2           ☠    |
  // 1                |
  //   A B C D E F G H 
  //
  let move =
    crow.new()
    |> crow.players("bone", "charcoal")
    |> crow.deploy("D4", "bone", piece.Bishop)
    |> crow.deploy("F6", "charcoal", piece.Pawn)
    |> crow.deploy("G7", "charcoal", piece.Pawn)
    |> crow.deploy("H8", "charcoal", piece.Pawn)
    |> crow.deploy("F2", "charcoal", piece.Pawn)
    |> crow.deploy("C3", "charcoal", piece.Pawn)
    |> crow.deploy("A7", "charcoal", piece.Pawn)
    |> crow.get_position("D4")

  assert_path(move.path, ["E5", "F6", "E3", "F2", "C3", "C5", "B6", "A7"])
  assert_path(move.captures, ["F6", "F2", "C3", "A7"])
}

pub fn queen_path_test() {
  // Assert that queen can move to all directions
  //   _ _ _ _ _ _ _ _
  // 8       ⚐       ⚐|
  // 7 ⚐     ⚐     ⚐  |
  // 6   ⚐   ⚐   ⚐    |
  // 5     ⚐ ⚐ ⚐      |
  // 4 ⚐ ⚐ ⚐ ♕ ⚐ ⚐ ⚐ ⚐|
  // 3     ⚐ ⚐ ⚐      |
  // 2   ⚐   ⚐   ⚐    |
  // 1 ⚐     ⚐     ⚐  |
  //   A B C D E F G H 
  //
  let move =
    crow.new()
    |> crow.players("bone", "charcoal")
    |> crow.deploy("D4", "bone", piece.Queen)
    |> crow.get_position("D4")

  assert_path(
    move.path,
    [
      "D5", "D6", "D7", "D8", "E5", "F6", "G7", "H8", "E4", "F4", "G4", "H4",
      "E3", "F2", "G1", "D3", "D2", "D1", "C3", "B2", "A1", "C4", "B4", "A4",
      "C5", "B6", "A7",
    ],
  )
  assert_path(move.captures, [])
}

pub fn queen_attack_test() {
  // Assert that queen can capture in all directions
  //   _ _ _ _ _ _ _ _
  // 8       ☠       ♟|
  // 7       ⚐     ☠  |
  // 6   ☠   ⚐   ⚐    |
  // 5     ⚐ ⚐ ⚐      |
  // 4     ☠ ♕ ⚐ ☠ ♟  |
  // 3     ⚐ ⚐ ☠      |
  // 2   ⚐   ⚐        |
  // 1 ⚐     ⚐        |
  //   A B C D E F G H 
  //
  let move =
    crow.new()
    |> crow.players("bone", "charcoal")
    |> crow.deploy("D4", "bone", piece.Queen)
    |> crow.deploy("D8", "charcoal", piece.Pawn)
    |> crow.deploy("G7", "charcoal", piece.Pawn)
    |> crow.deploy("H8", "charcoal", piece.Pawn)
    |> crow.deploy("F4", "charcoal", piece.Pawn)
    |> crow.deploy("G4", "charcoal", piece.Pawn)
    |> crow.deploy("E3", "charcoal", piece.Pawn)
    |> crow.deploy("C4", "charcoal", piece.Pawn)
    |> crow.deploy("B6", "charcoal", piece.Pawn)
    |> crow.get_position("D4")

  assert_path(
    move.path,
    [
      "D5", "D6", "D7", "D8", "E5", "F6", "G7", "E4", "F4", "E3", "D3", "D2",
      "D1", "C3", "B2", "A1", "C4", "C5", "B6",
    ],
  )
  assert_path(move.captures, ["D8", "G7", "F4", "E3", "C4", "B6"])
}

pub fn king_path_test() {
  // Assert that king can move to all directions
  //   _ _ _ _ _ _ _ _
  // 8                |
  // 7                |
  // 6                |
  // 5     ⚐ ⚐ ⚐      |
  // 4     ⚐ ♕ ⚐      |
  // 3     ⚐ ⚐ ⚐      |
  // 2                |
  // 1                |
  //   A B C D E F G H 
  //
  let move =
    crow.new()
    |> crow.players("bone", "charcoal")
    |> crow.deploy("D4", "bone", piece.King)
    |> crow.get_position("D4")

  assert_path(move.path, ["D5", "E5", "E4", "E3", "D3", "C3", "C4", "C5"])
  assert_path(move.captures, [])
}

pub fn king_attack_test() {
  // Assert that king can capture and be blocked by board limits
  //   _ _ _ _ _ _ _ _
  // 8                |
  // 7                |
  // 6                |
  // 5                |
  // 4                |
  // 3                |
  // 2 ☠ ⚐            |
  // 1 ♕ ☠ ♟          |
  //   A B C D E F G H 
  //
  let move =
    crow.new()
    |> crow.players("bone", "charcoal")
    |> crow.deploy("A1", "bone", piece.King)
    |> crow.deploy("A2", "charcoal", piece.Pawn)
    |> crow.deploy("B1", "charcoal", piece.Pawn)
    |> crow.deploy("C1", "charcoal", piece.Pawn)
    |> crow.get_position("A1")

  assert_path(move.path, ["A2", "B2", "B1"])
  assert_path(move.captures, ["A2", "B1"])
}

// Test helpers

fn assert_path(path: List(Coordinate), positions: List(String)) -> Bool {
  let path = set.from_list(path)

  positions
  |> list.map(coor)
  |> list.each(fn(position) {
    io.debug(position)
    assert True = set.contains(path, position)
  })

  assert True = list.length(positions) == set.size(path)
}

fn coor(position: String) -> Coordinate {
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
