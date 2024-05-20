// This is a subset of the `mobj_t` type from DOOM including just the required data for a movement validator MVP
pub type Datum {
    momentum_x: Int,
    momentum_y: Int,
    momentum_z: Int,
    angle: Int,
    z: Int,
    floor_z: Int,
}

// This is a subset of the `ticcmd_t` type from DOOM including just the required data for a movement validator MVP
pub type Redeemer {
    output_idx: Int,
    cmd: Command,
}

pub type Command {
    ForwardMove { value: Int, angle_turn: Int}
    SideMove { value: Int, angle_turn: Int}
    
} 
