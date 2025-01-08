use aiken/crypto.{VerificationKeyHash}
use cardano/assets.{AssetName}

pub type Series {
  finished_games: Int,
  kills: List<Int>,
  pkhs: List<VerificationKeyHash>,
  nft_names: List<AssetName>,
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

pub type Game {
  to: Int,
  from: Int,
  ephemeral_key: VerificationKeyHash,
  kills: List<Int>,
  state: State,
  data: ByteArray,
}
