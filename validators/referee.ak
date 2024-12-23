use aiken/collection/list
use cardano/address.{VerificationKey}
use cardano/transaction.{Input, OutputReference, Transaction}
use referee_script/types.{
  Aborted, AddPlayer, Cheated, Collect, EndGame, Finished, GameData, Lobby,
  Redeemer, Running, StartGame,
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
    let GameData {
      players: old_players,
      winner: old_winner,
      state: old_state,
      referee: old_referee,
      cheater: old_cheater,
      player_count: old_player_count,
      bot_count: old_bot_count,
    } = old_state

    when action is {
      AddPlayer -> {
        let new_state = get_new_state(new_state_index, outputs, spent_output)
        let GameData {
          players: new_players,
          winner: new_winner,
          state: new_state,
          referee: new_referee,
          cheater: new_cheater,
          player_count: new_player_count,
          bot_count: new_bot_count,
        } = new_state

        and {
          old_state == Lobby,
          list.length(new_players) <= max_players,
          is_subset(old_players, new_players),
          and {
            old_winner == new_winner,
            old_state == new_state,
            old_referee == new_referee,
            old_cheater == new_cheater,
            old_player_count == new_player_count,
            old_bot_count == new_bot_count,
          },
        }
      }
      StartGame -> {
        let new_state = get_new_state(new_state_index, outputs, spent_output)
        let GameData {
          players: new_players,
          winner: new_winner,
          state: new_state,
          referee: new_referee,
          cheater: new_cheater,
          player_count: new_player_count,
          bot_count: new_bot_count,
        } = new_state
        expect VerificationKey(cred) = new_referee

        and {
          old_state == Lobby,
          new_state == Running,
          old_players == new_players,
          old_referee == new_referee,
          old_winner == new_winner,
          old_cheater == new_cheater,
          old_player_count == new_player_count,
          old_bot_count == new_bot_count,
          list.has(extra_signatories, cred),
        }
      }

      EndGame -> {
        let new_state = get_new_state(new_state_index, outputs, spent_output)
        let GameData {
          players: new_players,
          winner: new_winner,
          state: new_state,
          referee: new_referee,
          cheater: new_cheater,
          player_count: new_player_count,
          bot_count: new_bot_count,
        } = new_state
        expect VerificationKey(cred) = new_referee

        and {
          old_players == new_players,
          old_referee == new_referee,
          old_player_count == new_player_count,
          old_bot_count == new_bot_count,
          list.has(extra_signatories, cred),
          when new_state is {
            Cheated -> {
              expect Some(cheater) = new_cheater
              expect None = new_winner
              and {
                old_state == Running,
                new_winner == old_winner,
                list.has(new_players, cheater),
              }
            }
            Finished -> {
              expect Some(winner) = new_winner
              expect None = old_cheater
              and {
                old_state == Running,
                new_cheater == old_cheater,
                list.has(new_players, winner),
              }
            }
            Aborted -> and {
                or {
                  old_state == Lobby,
                  old_state == Running,
                },
                new_winner == None,
                new_cheater == None,
                old_cheater == new_cheater,
                old_winner == new_winner,
              }

            _ -> fail @"invalid new state"
          },
        }
      }

      Collect -> {
        expect VerificationKey(cred) = old_referee
        and {
          or {
            old_state == Finished,
            old_state == Cheated,
            old_state == Aborted,
          },
          list.has(extra_signatories, cred),
        }
      }
    }
  }

  else(_) {
    fail @"unsupported purpose"
  }
}
