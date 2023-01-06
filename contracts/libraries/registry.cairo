%lang starknet

from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.starknet.common.syscalls import get_caller_address
from starkware.cairo.common.bool import TRUE, FALSE

// __Concepts__
// ecs_address: The ID of the entity in the ECS - This can be address or an id
// archetype: The archetype of the entity
// archetype_id: The ID of the entity in the archetype

// --------------------------------
// Events
// --------------------------------

// called when a new entity is registered
// different from the ComponentValueSet which is emitted on every statechange
@event
func RegistryRegister(address: felt, id: felt) {
}

// --------------------------------
// Storage
// --------------------------------

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
