use walking_skeleton/types/cmd.{Cmd}
use walking_skeleton/types/game_state.{Dead, GameData, Live, Player, Reborn}

pub fn is_legal_state_transition(
  old_state: GameData,
  new_state: GameData,
  cmd: Cmd,
) -> Bool {
  let GameData {
    is_over: old_is_over,
    admin: old_admin,
    player: old_player,
    ..
  } = old_state
  let GameData { admin: new_admin, player: new_player, .. } = new_state

  if old_is_over || old_admin != new_admin {
    False
  } else {
    is_legal_player_transition(old_player, new_player, cmd)
  }
}

fn is_legal_player_transition(
  old_player: Player,
  new_player: Player,
  _cmd: Cmd,
) -> Bool {
  let Player { player_state: old_state, .. } = old_player
  let Player { player_state: new_state, .. } = new_player

  let is_legal_state_transition =
    when old_state is {
      Live ->
        when new_state is {
          Live -> True
          Dead -> True
          Reborn -> False
        }
      Dead ->
        when new_state is {
          Reborn -> True
          Dead -> True
          Live -> False
        }

      Reborn ->
        when new_state is {
          Reborn -> True
          Live -> True
          Dead -> False
        }
    }

  is_legal_state_transition
}
