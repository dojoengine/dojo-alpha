%lang starknet

from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.math_cmp import is_le

from contracts.constants.Constants import ECS_TYPE

// world
from contracts.world.Library import World
from contracts.world.IWorld import IWorld

// import component
from contracts.components.IComponent import IComponent as ILocation
from contracts.components.location.Constants import (
    ID as LocationID,
    ComponentStruct as LocationStruct,
)
// from contracts.components.location.Location import ComponentStruct

// System specific imports
from contracts.systems.Constants import ID

const MAP_SIZE = 100;

@constructor
func constructor{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    world_address: felt
) {
    World.set_world_address(world_address);
    register();
    return ();
}

// single function that executes the move system
@external
func execute{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    entity: felt, data_len: felt, data: felt*
) {
    alloc_locals;
    // TODO: Assert Caller is World / Admin / Approved System
    // World.assert_caller_is_world();

    let component_address = World.get_address_by_id(LocationID);

    // check valid
    assert_in_map(data_len, data);

    // set data
    ILocation.set(component_address, entity, data_len, data);
    return ();
}

// Set up the system within the World.
// TODO: System cannot be called until this is setup
@external
func register{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() {
    // Set Component in World
    World.register(ID, ECS_TYPE.SYSTEM);
    return ();
}

@external
func assert_in_map{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    data_len: felt, data: felt*
) {
    alloc_locals;

    let old_location_x = data[0];
    let old_location_y = data[1];
    let new_location_x = data[2];
    let new_location_y = data[3];

    // assert in map
    let less_than_x = is_le(MAP_SIZE, new_location_x);
    let less_than_y = is_le(MAP_SIZE, new_location_y);

    assert less_than_x + less_than_y = 0;

    // assert only one step
    let one_step_x = absDiff(old_location_x, new_location_x);
    let one_step_y = absDiff(old_location_y, new_location_y);

    assert one_step_x + one_step_y = 1;

    return ();
}

func absDiff{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    a: felt, b: felt
) -> felt {
    // assert in map
    let less = is_le(b, a);

    if (less == 1) {
        return (a - b);
    } else {
        return (b - a);
    }
}
