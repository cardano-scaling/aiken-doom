use aiken/list
use aiken/transaction.{ScriptContext, Transaction}
use aiken/transaction/credential.{VerificationKeyCredential}
use walking_skeleton/types.{GameData}

validator {
  fn spend(data: GameData, _redeemer: Data, ctx: ScriptContext) -> Bool {
    let ScriptContext { transaction, .. } = ctx
    let Transaction { extra_signatories, .. } = transaction

    expect VerificationKeyCredential(payment_credential) = data.admin

    list.has(extra_signatories, payment_credential)
  }
}
