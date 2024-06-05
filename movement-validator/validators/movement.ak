use aiken/list
use aiken/transaction.{InlineDatum, Output, ScriptContext, Transaction}
use movement_validator/constants.{angle_90, frac_bits}
use movement_validator/types.{Datum, ForwardMove, Redeemer, SideMove}
use movement_validator/utils.{thrust}

validator {
  fn spend(datum: Datum, redeemer: Redeemer, ctx: ScriptContext) -> Bool {
    let ScriptContext { transaction, .. } = ctx
    let Transaction { outputs, .. } = transaction
    let Redeemer { cmd, output_idx } = redeemer
    let Datum { momentum_x, momentum_y, momentum_z, angle, z, floor_z } = datum

    expect z <= floor_z
    expect Some(output) = list.at(outputs, output_idx)
    let Output { datum: output_datum, .. } = output
    expect InlineDatum(dat) = output_datum
    expect new_datum: Datum = dat
    let Datum {
      momentum_x: new_momentum_x,
      momentum_y: new_momentum_y,
      momentum_z: new_momentum_z,
      angle: new_angle,
      z: new_z,
      floor_z: new_floor_z,
    } = new_datum

    when cmd is {
      ForwardMove { value, angle_turn } -> {
        expect new_angle == angle + angle_turn * frac_bits
        let thrust = thrust(momentum_x, momentum_y, new_angle, value)

        new_momentum_x == thrust.1st && new_momentum_y == thrust.2nd && new_momentum_z == momentum_z && new_z == z && new_floor_z == floor_z
      }
      SideMove { value, angle_turn } -> {
        expect new_angle == angle + angle_turn * frac_bits
        let thrust = thrust(momentum_x, momentum_y, angle - angle_90, value)

        new_momentum_x == thrust.1st && new_momentum_y == thrust.2nd && new_momentum_z == momentum_z && new_angle == angle && new_z == z && new_floor_z == floor_z
      }
    }
  }
}
