import gleam/queue.{Queue}
import gleam/option.{None, Option, Some}
import gleam/dynamic.{Dynamic}
import gleam/erlang/process.{Pid, Subject}
import gleam/otp/actor.{Continue, Next, StartError, Stop}
import chess.{GameState}

type Session {
  Session(name: String, players: Queue(String), game: Option(GameState))
}

pub type Message {
  Join(String)
  Set(GameState)
  Close
  GetPlayers(Subject(List(String)))
  GetGame(Subject(Option(GameState)))
}

pub fn start(name: String) -> Result(Subject(Message), StartError) {
  actor.start(new(name), handle)
}

pub fn start_link(name: String) -> Result(Pid, Dynamic) {
  new(name)
  |> actor.start(handle)
  |> actor.to_erlang_start_result()
}

fn handle(message: Message, session: Session) -> Next(Session) {
  case message {
    // Asynchronous Messages
    Join(name) -> Continue(add(session, name))
    Set(game) -> Continue(set(session, game))
    Close -> Stop(process.Normal)

    // Synchronous Messages
    GetPlayers(caller) -> {
      actor.send(caller, queue.to_list(session.players))
      Continue(session)
    }
    GetGame(caller) -> {
      actor.send(caller, session.game)
      Continue(session)
    }
  }
}

pub fn join(subject: Subject(Message), name: String) -> Nil {
  actor.send(subject, Join(name))
}

pub fn update(subject: Subject(Message), game: GameState) -> Nil {
  actor.send(subject, Set(game))
}

pub fn close(subject: Subject(Message)) -> Nil {
  actor.send(subject, Close)
}

pub fn get_players(subject: Subject(Message)) -> List(String) {
  actor.call(subject, fn(caller) { GetPlayers(caller) }, 100)
}

pub fn get_game(subject: Subject(Message)) -> Option(GameState) {
  actor.call(subject, fn(caller) { GetGame(caller) }, 100)
}

fn new(name: String) -> Session {
  Session(name, queue.new(), None)
}

fn add(session: Session, player: String) -> Session {
  let players = queue.push_front(session.players, player)
  Session(..session, players: players)
}

fn set(session: Session, game: GameState) -> Session {
  Session(..session, game: Some(game))
}
