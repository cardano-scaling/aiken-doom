use movement_validator/constants.{angle_to_fine_shift}

pub fn thrust(
  momentum_x: Int,
  momentum_y: Int,
  angle: Int,
  move: Int,
) -> (Int, Int) {
  let angle = angle / angle_to_fine_shift

  (momentum_x + cosine(angle) * move, momentum_y + sine(angle) * move)
}

// Figure out how to do trig calculations here
fn cosine(_angle: Int) -> Int {
  1
}

fn sine(_angle: Int) -> Int {
  1
}
