%lang starknet

from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.cairo_builtins import HashBuiltin

// import component
from contracts.components.IComponent import IComponent as ILocation

from contracts.world.Library import World

from contracts.world.IWorld import IWorld

from contracts.components.location.Constants import ID as LocationID

@constructor
func constructor{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    world_address: felt
) {
    World.set_world_address(world_address);
    return ();
}

// single function
@external
func execute{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    entity: felt, data_len: felt, data: felt*
) {
    alloc_locals;

    // add entities to the World
    // add component values which the entity has
    // store in lookup table to query what components the entity has
    return ();
}