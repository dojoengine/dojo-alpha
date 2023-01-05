%lang starknet

from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.cairo_builtins import BitwiseBuiltin, HashBuiltin
from starkware.cairo.common.bool import TRUE, FALSE
from starkware.starknet.common.syscalls import get_caller_address

from contracts.constants.Constants import Entity

from contracts.systems.RegisterSystem import RegisterSystem

from contracts.constants.Constants import ECS_TYPE

from contracts.utils.ISystem import ISystem

// WORLD ------------
// The World is the entry point for all components and systems. You need to register your component or system
// with the world before you can use it. The world is responsible for calling the systems and passing the data
// to them. Systems and Components are registered via calls on their contracts.
// Systems, Components and Etnities all exist in the same table. They are differentiated by their Archetype.
// ------------------

//
// EVENTS ------------
//

// @notice: emitted when a component value is set
// @param: entity: the entity the component value is set on
// @param: component_id: the component id
// @param: data_len: the length of the data
// @param: data: the data
@event
func ComponentValueSet(entity: felt, component_id: felt, data_len: felt, data: felt*) {
}

@constructor
func constructor{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() {
    // we setup initial Archetypes here
    RegisterSystem.register_archetype(ECS_TYPE.COMPONENT);
    RegisterSystem.register_archetype(ECS_TYPE.SYSTEM);
    return ();
}

//
// REGISTER ---------------
//

// @notice: General register function. This is called by the component or system to register itself with the world.
// @param: ecs_address: the address of the entity
// @param: guid: the guid of the component - This can be a String or a Hash
// @param: ecs_type: the type of the entity
@external
func register{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    guid: felt, ecs_type: felt
) {
    let (caller_address) = get_caller_address();
    RegisterSystem.register(caller_address, guid, ecs_type);
    return ();
}

// @notice: register a component value set
// @param: entity: the entity to set the value on
// @param: component: the component to set the value on
// @param: data_len: the length of the data
// @param: data: the data to set
@external
func register_component_value_set{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    entity_guid: felt, component_id: felt, data_len: felt, data: felt*
) {
    alloc_locals;
    // TODO: check Component is registered in world
    // Only can be called by Registered Component

    // set 0 here for now - we could pass an address in the future to set an address for the entity
    RegisterSystem.set(0, entity_guid);
    ComponentValueSet.emit(entity_guid, component_id, data_len, data);
    return ();
}

//
// EXECUTE ------------------------
// note: No systems are called directly. Everything is called via the World.
//

// @notice: execute a system. We use the system_guid to get the address of the system and then call it. This saves the client having to map addresses. They just register the guid.
// @param: system_guid: the guid of the system entity.
// @param: entity: the entity to execute the system on
// @param: data_len: the length of the data
// @param: data: the data to pass to the system
@external
func execute{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    system_guid: felt, entity: felt, data_len: felt, data: felt*
) {
    alloc_locals;

    // Check System is registered in world. Revert if not.
    let is_entity = RegisterSystem.is_entity(system_guid);
    assert is_entity = TRUE;

    let (system_address) = get_address_by_id(system_guid);

    // call Systems via the World
    // Auth Check on System

    // ?? Do we pass the caller here - This would allow auth on Systems.
    ISystem.execute(system_address, entity, data_len, data);
    return ();
}

//
// VIEWS ------------------------
//

// get address by id
@view
func get_address_by_id{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    guid: felt
) -> (address: felt) {
    let is_entity = RegisterSystem.is_entity(guid);
    assert is_entity = TRUE;

    let (entity: Entity) = RegisterSystem.get_by_id(guid);
    return (entity.ecs_address,);
}
