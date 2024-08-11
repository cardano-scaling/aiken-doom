// subset of ticcmd_t defined at d_ticcmd.h:32
pub type Cmd {
  forward_move: Int,
  //*2048 for move
  side_move: Int,
  //*2048 for move
  angle_turn: Int,
  // <<16 for angle delta
  button: List<Button>,
}

// subset of button actions defined at d_event.h:84
pub type Button {
  Attack
  Use
}

pub type Redeemer {
  Admin
  Player(List<Cmd>)
}
