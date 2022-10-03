import gleam/queue.{Queue}
import gleam/option.{None, Option, Some}
import gleam/dynamic.{Dynamic}
import gleam/erlang/process.{Pid, Subject}
import gleam/otp/actor.{Continue, Next, StartError, Stop}

type Session(state) {
  Session(name: String, players: Queue(String), state: Option(state))
}

pub type Message(state) {
  Join(String)
  Set(state)
  Close
  GetPlayers(Subject(List(String)))
  GetGame(Subject(Option(state)))
}

pub fn start(name: String) -> Result(Subject(Message(state)), StartError) {
  actor.start(new(name), handle)
}

pub fn start_link(name: String) -> Result(Pid, Dynamic) {
  new(name)
  |> actor.start(handle)
  |> actor.to_erlang_start_result()
}

fn handle(
  message: Message(state),
  session: Session(state),
) -> Next(Session(state)) {
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
      actor.send(caller, session.state)
      Continue(session)
    }
  }
}

pub fn join(subject: Subject(Message(state)), name: String) -> Nil {
  actor.send(subject, Join(name))
}

pub fn update(subject: Subject(Message(state)), state: state) -> Nil {
  actor.send(subject, Set(state))
}

pub fn close(subject: Subject(Message(state))) -> Nil {
  actor.send(subject, Close)
}

pub fn get_players(subject: Subject(Message(state))) -> List(String) {
  actor.call(subject, fn(caller) { GetPlayers(caller) }, 100)
}

pub fn get_game(subject: Subject(Message(state))) -> Option(state) {
  actor.call(subject, fn(caller) { GetGame(caller) }, 100)
}

fn new(name: String) -> Session(state) {
  Session(name, queue.new(), None)
}

fn add(session: Session(state), player: String) -> Session(state) {
  let players = queue.push_front(session.players, player)
  Session(..session, players: players)
}

fn set(session: Session(state), state: state) -> Session(state) {
  Session(..session, state: Some(state))
}
