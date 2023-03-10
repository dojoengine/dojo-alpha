%lang starknet

from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.starknet.common.syscalls import get_caller_address
from starkware.cairo.common.bool import TRUE, FALSE
from starkware.cairo.common.math import assert_not_zero

// __Concepts__
// ecs_address: The ID of the entity in the ECS - This can be address or an id
// archetype: The archetype of the entity
// archetype_id: The ID of the entity in the archetype

// --------------------------------
// Events
// --------------------------------

// Emitted when a new component or system is registered.
@event
func RegistryRegister(address: felt, id: felt) {
}

// Emitted when a component is updated.
@event
func ComponentUpdate(id: felt, components_len: felt, components: felt*) {
}

// --------------------------------
// Storage
// --------------------------------

@storage_var
func Registry_entity_count() -> (value: felt) {
}

@storage_var
func Registry_entity_components(id: felt, idx: felt) -> (part: felt) {
}

@storage_var
func Registry_storage(key: felt) -> (value: felt) {
}

// --------------------------------
// Functions
// --------------------------------

namespace Registry {
    // @notice: Registers a component or system
    // @param: address - the address of the component or system
    // @param: id - a human readable id for the component or system
    // @param: archetype - the archetype of the entity
    func register{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        address: felt, id: felt
    ) {
        alloc_locals;
        
        let (existing_address) = Registry_storage.read(address);
        with_attr error_message("Registry: address already exists") {
            assert existing_address = FALSE;
        }

        let (existing_id) = Registry_storage.read(id);
        with_attr error_message("Registry: id already exists") {
            assert existing_id = FALSE;
        }

        Registry_storage.write(address, id);
        Registry_storage.write(id, address);

        RegistryRegister.emit(address, id);
        return ();
    }

    func write_entity_inner{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        entity_id: felt, idx: felt, components_len: felt, components: felt*
    ) {
        if (idx == components_len) {
            return ();
        }

        Registry_entity_components.write(entity_id, idx + 1, components[0]);
        return write_entity_inner(entity_id, idx + 1, components_len, components + 1);
    }

    func extend_entity{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        id: felt, components_len: felt, components: felt*
    ) {
        alloc_locals;

        let (existing_entity) = Registry_entity_components.read(id);
        with_attr error_message("Registry: entity doesnt exists") {
            assert_not_zero(existing_entity);
        }

        // TODO: extend entities components

        return ();
    }

    // --------------------------------
    // Getters
    // --------------------------------

    // @notice: Returns an entity if it exists
    func lookup_entity{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(id: felt) -> (
        value: felt
    ) {
        let (value) = Registry_entity_components.read(id);
        return (value=value);
    }

    // @notice: Returns the address -> id or id -> address mapping of an entry
    // @param: key - address or id of the entry
    func get{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(key: felt) -> (
        value: felt
    ) {
        let (value) = Registry_storage.read(key);
        return (value=value);
    }
}
