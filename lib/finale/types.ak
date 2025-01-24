use aiken/crypto.{VerificationKeyHash}
use cardano/assets.{PolicyId}

pub type Series {
  finished_games: Int,
  kills: List<Int>,
  pkhs: List<VerificationKeyHash>,
  distribute_pkhs: List<VerificationKeyHash>,
  policies: List<PolicyId>,
}

pub type Redeemer {
  StoreGame
  Distribute
}

pub type State {
  Lobby
  Running
  Cheated
  Finished
  Aborted
}

pub type Packet {
  to: Int,
  from: Int,
  ephemeral_key: VerificationKeyHash,
  kills: List<Int>,
  state: State,
  data: ByteArray,
}
