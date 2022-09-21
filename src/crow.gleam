import gleam/io
import gleam/erlang
import gleam/otp/actor
import session

pub fn main() {
  io.println("Hello from gleam!")

  erlang.start_arguments()
  |> io.debug()

  session.start("Test")
  |> actor.to_erlang_start_result()
  |> io.debug()

  assert Ok(server) = session.start("Hello")

  session.join(server, "Player 1")
  session.join(server, "Player 2")
  session.get_players(server)
}

pub external fn random_float() -> Float =
  "rand" "uniform"

// Elixir modules start with `Elixir.`
pub external fn inspect(a) -> a =
  "Elixir.IO" "inspect"
