use aiken/collection/list
use cardano/address.{VerificationKey}
use cardano/transaction.{Input, OutputReference, Transaction}
use referee_script/types.{AddPlayer, GameData, Lobby, Redeemer}
use referee_script/utils.{get_new_state, is_subset}

validator referee_script(max_players: Int) {
  spend(
    maybe_datum: Option<GameData>,
    redeemer: Redeemer,
    utxo: OutputReference,
    self: Transaction,
  ) {
    expect Some(old_state) = maybe_datum
    let Transaction { outputs, inputs, extra_signatories, .. } = self
    let Redeemer { new_state_index, action } = redeemer
    expect Some(spent_input) = transaction.find_input(inputs, utxo)
    let Input { output: spent_output, .. } = spent_input
    let new_state = get_new_state(new_state_index, outputs, spent_output)
    when action is {
      AddPlayer -> {
        let GameData {
          players: old_players,
          winner: old_winner,
          state: old_state,
          referee: old_referee,
        } = old_state
        let GameData {
          players: new_players,
          winner: new_winner,
          state: new_state,
          referee: new_referee,
        } = new_state
        let added_players = list.difference(old_players, new_players)
        and {
          old_state == Lobby,
          list.length(new_players) <= max_players,
          is_subset(old_players, new_players),
          list.all(
            added_players,
            fn(player) {
              expect VerificationKey(cred) = player
              list.has(extra_signatories, cred)
            },
          ),
          and {
            old_winner == new_winner,
            old_state == new_state,
            old_referee == new_referee,
          },
        }
      }

      _ -> todo
    }
  }

  else(_) {
    fail @"unsupported purpose"
  }
}
