// TODO: Maybe using the result module would be enough here.
pub opaque type Rule(t, error) {
  Rule(apply: fn(t) -> Result(t, error))
}

pub fn new(rule: fn(t) -> Result(t, error)) -> Rule(t, error) {
  Rule(rule)
}

pub fn then(rule: Rule(t, e), then_do: Rule(t, e)) -> Rule(t, e) {
  Rule(fn(data: t) -> Result(t, e) {
    case rule.apply(data) {
      Ok(new_data) -> then_do.apply(new_data)
      Error(e) -> Error(e)
    }
  })
}

pub fn apply(data: t, rule: Rule(t, e)) -> Result(t, e) {
  rule.apply(data)
}
