use cardano/address.{PaymentCredential}

pub type GameData {
  referee: PaymentCredential,
  players: List<PaymentCredential>,
  state: State,
  winner: Option<PaymentCredential>,
  cheater: Option<PaymentCredential>,
}

pub type State {
  Lobby
  Running
  Cheated
  Finished
}

pub type Redeemer {
  new_state_index: Int,
  action: SpendAction,
}

pub type SpendAction {
  AddPlayer
  StartGame
  EndGame
  Collect
}
