use aiken/transaction/credential.{PaymentCredential}

pub type GameData {
  is_over: Bool,
  owner: PaymentCredential,
  admin: PaymentCredential,
  player: Player,
  monsters: List<MapObject>,
  leveltime: List<Int>,
  level: LevelId,
  teleporting: Bool,
}

// subset of player_t from d_player.h:78 (total_stats and level_stats are not in the original struct, but added for our needs)
pub type Player {
  player_state: PlayerState,
  map_object: MapObject,
  total_stats: Stats,
  level_stats: Stats,
  cheats: Int,
}

// another subset of player_t from d_player.h:78
pub type Stats {
  kill_count: Int,
  secret_count: Int,
  item_count: Int,
}

// subset of mobj_t from p_mobj.h:201
// health: max 200, min 0 (?)
pub type MapObject {
  position: Position,
  health: Int,
}

pub type Position {
  x: Int,
  y: Int,
  z: Int,
}

// comes from d_player.h:48
pub type PlayerState {
  Live
  Dead
  Reborn
}

// custom type using free floating values from DOOM
pub type LevelId {
  map: Int,
  skill: Int,
  episode: Int,
  demoplayback: Bool,
}
