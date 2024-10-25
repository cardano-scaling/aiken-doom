use aiken/collection/list
use cardano/address.{VerificationKey}
use cardano/transaction.{Input, OutputReference, Transaction}
use referee_script/types.{
  AddPlayer, Cheated, EndGame, Finished, GameData, Redeemer, Running,
  StartGame,
}
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
    let GameData {
      players: old_players,
      winner: old_winner,
      state: old_state,
      referee: old_referee,
      cheater: old_cheater,
    } = old_state
    let GameData {
      players: new_players,
      winner: new_winner,
      state: new_state,
      referee: new_referee,
      cheater: new_cheater,
    } = new_state

    when action is {
      AddPlayer -> {
        let added_players = list.difference(old_players, new_players)
        and {
          old_state == Running,
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
            old_cheater == new_cheater,
          },
        }
      }
      StartGame -> {
        expect VerificationKey(cred) = new_referee
        and {
          new_state == Running,
          old_winner == new_winner,
          old_players == new_players,
          old_referee == new_referee,
          old_cheater == new_cheater,
          list.has(extra_signatories, cred),
        }
      }
      EndGame -> {
        expect VerificationKey(cred) = new_referee

        and {
          old_state == Running,
          old_players == new_players,
          old_referee == new_referee,
          list.has(extra_signatories, cred),
          when new_winner is {
            None -> {
              expect Some(cheater) = new_cheater
              and {
                new_state == Cheated,
                new_winner == old_winner,
                list.has(new_players, cheater),
              }
            }
            Some(winner) -> and {
                new_state == Finished,
                new_cheater == old_cheater,
                list.has(new_players, winner),
              }
          },
        }
      }
    }
  }

  else(_) {
    fail @"unsupported purpose"
  }
}
