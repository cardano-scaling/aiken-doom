// subset of ticcmd_t defined at d_ticcmd.h:32
pub type Cmd {
  //*2048 for move
  forward_move: Int,
  //*2048 for move
  side_move: Int,
  // <<16 for angle delta
  angle_turn: Int,
  chat_char: ByteArray,
  buttons: ByteArray,
  buttons2: ByteArray,
  consistancy: ByteArray,
  inventory: Int,
  lookfly: ByteArray,
  arti: ByteArray,
}

pub type Redeemer {
  Admin
  Player(List<Cmd>)
}
