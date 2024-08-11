// subset of ticcmd_t defined at d_ticcmd.h:32
pub type Cmd {
  //*2048 for move
  forward_move: Int,
  //*2048 for move
  side_move: Int,
  // <<16 for angle delta
  angle_turn: Int,
  chat_char: Int,
  buttons: Int,
  buttons2: Int,
  consistancy: Int,
  inventory: Int,
  lookfly: Int,
  arti: Int,
}

pub type Redeemer {
  Admin
  Player(List<Cmd>)
}
