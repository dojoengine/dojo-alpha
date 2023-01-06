%lang starknet

from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.starknet.common.syscalls import get_contract_address

from contracts.constants.Constants import ECS_TYPE

from contracts.utils.Utils import Utils

from contracts.world.IWorld import IWorld
from contracts.world.Library import World

// import ID
from contracts.components.location.Constants import ID, ComponentStruct

@storage_var
func component(entity: felt) -> (data: ComponentStruct) {
}

@constructor
func constructor{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    world_address: felt
) {
    World.set_world_address(world_address);
    register();
    return ();
}

// Set up the component within the World.
// TODO: Component cannot be called until registered
@external
func register{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() {
    // Set Component in World
    World.register(ID, ECS_TYPE.COMPONENT);
    return ();
}

@external
func set{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    entity: felt, data_len: felt, data: felt*
) {
    alloc_locals;
    // authorize
    // check init

    // cast data to struct so we can store it
    // we offset data by two so we only store new location
    let loc: ComponentStruct = Utils.arr_to_component_struct(2, data + 2);

    component.write(entity, loc);

    // call World with state update to trigger event
    let (world_address) = World.get_world_address();
    IWorld.register_component_value_set(world_address, entity, ID, data_len, data);

    return ();
}

// get Schema for component
@external
func get_schema{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (
    schema: ComponentStruct
) {
    return (schema=ComponentStruct(1, 2));
}

// get Schema for component
@view
func get_value{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(entity: felt) -> (
    data: ComponentStruct
) {
    return component.read(entity);
}
