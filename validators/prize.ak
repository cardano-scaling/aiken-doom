use aiken/collection/dict
use aiken/collection/list
use aiken/collection/pairs
use cardano/address.{Address, PaymentCredential, Script, VerificationKey}
use cardano/assets.{PolicyId}
use cardano/transaction.{Input, Output, OutputReference, Transaction}

validator prize(admin: PaymentCredential, utxo: OutputReference) {
  spend(
    _datum: Option<Data>,
    _redeemer: Data,
    output_reference: OutputReference,
    self: Transaction,
  ) {
    let Transaction { extra_signatories, inputs, .. } = self
    expect Some(input) = inputs |> transaction.find_input(output_reference)
    let Input { output, .. } = input
    let Output { address, .. } = output
    let Address { payment_credential, .. } = address
    expect Script(self_policy) = payment_credential
    expect VerificationKey(admin_kh) = admin

    list.has(extra_signatories, admin_kh) || list.any(
      inputs,
      fn(input) {
        list.any(
          input.output.value |> assets.policies(),
          fn(policy) { policy == self_policy },
        )
      },
    )
  }

  mint(_: Data, policy_id: PolicyId, self: Transaction) {
    let Transaction { inputs, mint, .. } = self
    let minted_assets = mint |> assets.tokens(policy_id) |> dict.to_pairs()
    list.any(inputs, fn(input) { input.output_reference == utxo }) && list.all(
      pairs.values(minted_assets),
      fn(count) { count == 1 },
    )
  }

  else(_) {
    fail
  }
}
