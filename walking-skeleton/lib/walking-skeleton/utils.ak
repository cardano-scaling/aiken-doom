use aiken/hash.{Blake2b_224, Hash}
use aiken/list
use aiken/transaction/credential.{
  PaymentCredential, VerificationKey, VerificationKeyCredential,
}
use walking_skeleton/types/cmd.{Cmd}
use walking_skeleton/types/game_state.{Dead, GameData, Live, Player, Reborn}

pub fn is_signed_by_admin(
  signatures: List<Hash<Blake2b_224, VerificationKey>>,
  admin: PaymentCredential,
) -> Bool {
  expect VerificationKeyCredential(payment_credential) = admin
  list.has(signatures, payment_credential)
}

pub fn is_legal_state_transition(
  old_state: GameData,
  new_state: GameData,
  cmd: Cmd,
) -> Bool {
  let GameData {
    is_over: old_is_over,
    admin: old_admin,
    owner: old_owner,
    player: old_player,
    ..
  } = old_state
  let GameData { admin: new_admin, owner: new_owner, player: new_player, .. } =
    new_state

  if old_is_over || old_admin != new_admin || old_owner != new_owner {
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
