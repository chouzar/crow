pub opaque type Phase {
  MoveOrDeploy
  PlayCard
  BuyCard
}

pub fn new() -> Phase {
  MoveOrDeploy
}

pub fn next(phase: Phase) -> Phase {
  case phase {
    MoveOrDeploy -> PlayCard
    PlayCard -> BuyCard
    BuyCard -> MoveOrDeploy
  }
}
