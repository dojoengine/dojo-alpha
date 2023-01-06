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

// Emitted when a new entity is spawned.
@event
func EntitySpawn(id: felt, components_len: felt, components: felt*) {
}

// --------------------------------
// Storage
// --------------------------------

@storage_var
func Registry_entity_count() -> (value: felt) {
}

@storage_var
func Registry_entities(id: felt, idx: felt) -> (part: felt) {
}

@storage_var
func Registry_storage(key: felt) -> (value: felt) {
}

// --------------------------------
// Functions
// --------------------------------

namespace Registry {
    // @notice: Registers a the component or system
    // @param: address - the address of the the component or system
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

        Registry_entities.write(entity_id, idx + 1, components[0]);
        return write_entity_inner(entity_id, idx + 1, components_len, components + 1);
    }

    func spawn{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        components_len: felt, components: felt*
    ) -> (
        id: felt
    ) {
        alloc_locals;

        // Provision globally unique entity id.
        let (id) = Registry_entity_count.read();
        Registry_entity_count.write(id + 1);

        // Store entities components.
        Registry_entities.write(id, 0, components_len);
        write_entity_inner(id, 0, components_len, components);

        return (id=id);
    }

    func extend_entity{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        id: felt, components_len: felt, components: felt*
    ) {
        alloc_locals;

        let (existing_entity) = Registry_entities.read(id);
        with_attr error_message("Registry: entity doesnt exists") {
            assert_not_zero(existing_entity);
        }

        // TODO: extend entities components

        return ();
    }

    // @notice: Returns an entity if it exists
    func lookup_entity{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(id: felt) -> (
        value: felt
    ) {
        let (value) = Registry_entities.read(key);
        return (value=value);
    }

    // --------------------------------
    // Getters
    // --------------------------------

    // @notice: Returns the address -> id or id -> address mapping of an entry
    // @param: key - address or id of the entry
    func get{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(key: felt) -> (
        value: felt
    ) {
        let (value) = Registry_storage.read(key);
        return (value=value);
    }
}
