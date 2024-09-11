use aiken/collection/list
use cardano/transaction.{InlineDatum, Output}
use referee_script/types.{GameData}

pub fn get_new_state(
  ix: Int,
  outputs: List<Output>,
  spent_utxo: Output,
) -> GameData {
  let script_address = spent_utxo.address
  expect Some(new_utxo) = list.at(outputs, ix)
  let Output { address: new_address, datum, .. } = new_utxo
  expect new_address == script_address
  expect InlineDatum(data) = datum
  expect game_data: GameData = data

  game_data
}

// This is brute force O(n*m), but it's fine for small lists
pub fn is_subset(subset: List<a>, superset: List<a>) -> Bool {
  list.all(subset, fn(x) { list.has(superset, x) })
}
