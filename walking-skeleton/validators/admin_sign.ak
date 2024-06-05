use aiken/list
use aiken/transaction.{
  InlineDatum, Input, Output, ScriptContext, Spend, Transaction,
}
use aiken/transaction/credential.{VerificationKeyCredential}
use walking_skeleton/types/cmd.{Cmd}
use walking_skeleton/types/game_state.{GameData}
use walking_skeleton/utils.{is_legal_state_transition}

validator {
  fn spend(old_datum: GameData, cmd: Cmd, ctx: ScriptContext) -> Bool {
    let ScriptContext { transaction, purpose } = ctx
    let Transaction { extra_signatories, inputs, outputs, .. } = transaction

    expect Spend(out_ref) = purpose
    expect Some(script_input) = transaction.find_input(inputs, out_ref)
    let Input { output: input_output, .. } = script_input
    let Output { address: script_address, .. } = input_output
    expect Some(script_output) =
      list.find(outputs, fn(output) { output.address == script_address })
    let Output { datum: output_datum, .. } = script_output

    expect InlineDatum(data) = output_datum
    expect new_datum: GameData = data

    expect VerificationKeyCredential(payment_credential) = old_datum.admin
    and {
      is_legal_state_transition(old_datum, new_datum, cmd),
      list.has(extra_signatories, payment_credential),
    }
  }
}
