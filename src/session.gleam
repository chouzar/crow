import gleam/io
import gleam/queue.{Queue}
import gleam/option.{None, Option, Some}
import gleam/erlang/process
import gleam/otp/actor
import chess.{GameState}

pub type Session {
  Session(name: String, players: Queue(String), game: Option(GameState))
}

pub type Message {
  Join(String)
  Set(GameState)
  Close
  GetPlayers(process.Subject(List(String)))
  GetGame(process.Subject(GameState))
}

type Server =
  process.Subject(Message)

pub fn start(name: String) -> Result(Server, actor.StartError) {
  actor.start(new(name), handle)
}

fn handle(message: Message, session: Session) -> actor.Next(Session) {
  case message {
    Join(name) -> actor.Continue(add(session, name))
    Set(game) -> actor.Continue(set(session, game))
    Close -> actor.Stop(process.Normal)
    GetPlayers(subject) -> {
      actor.send(subject, queue.to_list(session.players))
      actor.Continue(session)
    }
    GetGame(subject) -> {
      assert Some(game) = session.game
      actor.send(subject, game)
      actor.Continue(session)
    }
  }
}

pub fn join(server: Server, name: String) -> Nil {
  actor.send(server, Join(name))
}

pub fn update(server: Server, game: GameState) -> Nil {
  actor.send(server, Set(game))
}

pub fn close(server: Server) -> Nil {
  actor.send(server, Close)
}

pub fn players(server: Server) -> List(String) {
  actor.call(server, fn(subject) { GetPlayers(subject) }, 100)
}

fn new(name: String) -> Session {
  Session(name, queue.new(), None)
}

fn add(session: Session, player: String) -> Session {
  let players = queue.push_back(session.players, player)
  Session(..session, players: players)
}

fn set(session: Session, game: GameState) -> Session {
  Session(..session, game: Some(game))
}
