use aiken/collection/dict
use aiken/collection/list
use aiken/crypto.{VerificationKeyHash}
use aiken/primitive/int
use cardano/address.{Address, PaymentCredential, VerificationKey}
use cardano/assets
use cardano/transaction.{
  InlineDatum, Input, Output, OutputReference, Transaction,
}
use finale/types.{Distribute, Finished, Packet, Redeemer, Series, StoreGame}
use finale/utils.{unique}

validator manager(admin: PaymentCredential) {
  spend(
    datum: Option<Series>,
    redeemer: Redeemer,
    utxo_ref: OutputReference,
    self: Transaction,
  ) {
    let Transaction { inputs, outputs, reference_inputs, extra_signatories, .. } =
      self
    expect Some(spent_input) = inputs |> transaction.find_input(utxo_ref)
    let Input { output: spent_output, .. } = spent_input
    expect Some(old_datum) = datum

    let Series {
      finished_games: old_games,
      kills: old_kills,
      pkhs: old_pkhs,
      distribute_pkhs: old_distribute_pkhs,
      policies: old_policies,
    } = old_datum

    expect VerificationKey(admin_kh) = admin

    when redeemer is {
      StoreGame -> {
        expect Some(new_output) =
          list.find(
            outputs,
            fn(output) { output.address == spent_output.address },
          )
        let Output { datum: output_datum, .. } = new_output
        expect InlineDatum(raw_datum) = output_datum
        expect new_datum: Series = raw_datum

        let Series {
          finished_games: new_games,
          kills: new_kills,
          pkhs: new_pkhs,
          distribute_pkhs: new_distribute_pkhs,
          policies: new_policies,
        } = new_datum

        expect old_games < 3 && old_games >= 0
        expect new_games == old_games + 1

        let kills =
          list.reduce(
            reference_inputs,
            [],
            fn(acc, input) {
              let Input { output, .. } = input
              let Output { datum, .. } = output

              expect InlineDatum(raw_datum) = datum
              expect game_list: List<Packet> = raw_datum
              expect Some(game) = list.at(game_list, 0)
              expect game.state == Finished
              expect list.is_empty(acc) || acc == game.kills
              game.kills
            },
          )

        expect
          new_kills == list.indexed_map(
            old_kills,
            fn(i, n) {
              expect Some(count) = list.at(kills, i)
              count + n
            },
          )

        and {
          list.has(extra_signatories, admin_kh),
          old_pkhs == new_pkhs,
          old_distribute_pkhs == new_distribute_pkhs,
          old_policies == new_policies,
        }
      }

      Distribute -> or {
          list.has(extra_signatories, admin_kh),
          old_games == 3 && when unique(old_kills) is {
            True -> {
              let pkh_kills =
                list.sort(
                  list.indexed_map(
                    old_distribute_pkhs,
                    fn(i, pkh) {
                      expect Some(kills) = list.at(old_kills, i)
                      (pkh, kills)
                    },
                  ),
                  fn(
                    left: (VerificationKeyHash, Int),
                    right: (VerificationKeyHash, Int),
                  ) {
                    int.compare(right.2nd, left.2nd)
                  },
                )

              list.for_each(
                outputs,
                fn(output) {
                  let Output { value, address, .. } = output
                  let value = assets.to_dict(value)
                  list.for_each(
                    old_policies,
                    fn(policy_id) {
                      when dict.get(value, policy_id) is {
                        Some(_) -> {
                          expect Some(index) =
                            list.index_of(old_policies, policy_id)
                          expect Some((distribute, _)) =
                            list.at(pkh_kills, index)

                          let Address { payment_credential, .. } = address
                          expect VerificationKey(pkh) = payment_credential
                          expect distribute == pkh
                        }
                        None -> Void
                      }
                    },
                  )
                },
              )

              True
            }
            False -> list.has(extra_signatories, admin_kh)
          },
        }
    }
  }

  else(_) {
    fail
  }
}
