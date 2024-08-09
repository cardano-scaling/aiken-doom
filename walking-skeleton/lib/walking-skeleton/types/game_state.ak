use aiken/transaction/credential.{PaymentCredential}

pub type GameData {
  is_over: Bool,
  owner: PaymentCredential,
  admin: PaymentCredential,
  player: Player,
  monsters: List<MapObject>,
}

// subset of player_t from d_player.h:78
pub type Player {
  player_state: PlayerState,
  map_object: MapObject,
  kill_count: Int,
  secret_count: Int,
  item_count: Int,
}

// subset of mobj_t from p_mobj.h:201
pub type MapObject {
  position: Position,
  health: Int,
}

pub type Position {
  momentum_x: Int,
  momentum_y: Int,
  momentum_z: Int,
  angle: Int,
  z: Int,
  floor_z: Int,
}

// comes from d_player.h:48
pub type PlayerState {
  Live
  Dead
  Reborn
}
