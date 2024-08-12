use aiken/cbor
use aiken/hash.{Blake2b_224, Hash}
use aiken/list
use aiken/math
use aiken/transaction/credential.{
  PaymentCredential, VerificationKey, VerificationKeyCredential,
}
use walking_skeleton/types/cmd.{Cmd}
use walking_skeleton/types/game_data.{GameData, MapObject, Player, Position}

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
  cmds: List<Cmd>,
  max_distance_diff: Int,
) -> Bool {
  let GameData {
    is_over: old_is_over,
    admin: old_admin,
    owner: old_owner,
    player: old_player,
    level: old_level,
    ..
  } = old_state
  let GameData {
    admin: new_admin,
    owner: new_owner,
    player: new_player,
    level: new_level,
    teleporting,
    ..
  } = new_state

  if old_is_over || old_admin != new_admin || old_owner != new_owner {
    False
  } else {
    is_legal_player_transition(
      old_player,
      new_player,
      max_distance_diff,
      list.length(cmds),
      teleporting || old_level != new_level,
    )
  }
}

fn is_legal_player_transition(
  old_player: Player,
  new_player: Player,
  max_distance_diff: Int,
  cmds_count: Int,
  teleporting: Bool,
) -> Bool {
  let Player { map_object: old_mobj, .. } = old_player
  let Player { map_object: mew_mobj, .. } = new_player

  teleporting || is_legal_mobj_transition(
    old_mobj,
    mew_mobj,
    max_distance_diff,
    cmds_count,
  )
}

fn is_legal_mobj_transition(
  old_mobj: MapObject,
  new_mobj: MapObject,
  max_distance_diff: Int,
  cmds_count: Int,
) -> Bool {
  let MapObject { position: old_position, .. } = old_mobj
  let MapObject { position: new_position, .. } = new_mobj

  let Position { x: old_x, y: old_y, .. } = old_position
  let Position { x: new_x, y: new_y, .. } = new_position

  let dx_squared = new_x - old_x |> math.pow(2)
  let dy_squared = new_y - old_y |> math.pow(2)

  expect Some(difference) = math.sqrt(dx_squared + dy_squared)

  trace cbor.diagnostic(difference)
  trace cbor.diagnostic(cmds_count * max_distance_diff)
  difference < cmds_count * max_distance_diff
}
