%lang starknet

from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.math import assert_not_zero

from contracts.constants.Constants import ECS_TYPE
from contracts.world.IWorld import IWorld
from contracts.world.registerable import Registerable

@storage_var
func Component_state(entity_id: felt, part_idx: felt) -> (part: felt) {
}

namespace Component {
    func initialize{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        world_address: felt, component_id: felt
    ) {
        Registerable.initialize(world_address);
        IWorld.register(world_address, component_id, ECS_TYPE.COMPONENT);
        return ();
    }

    func write_inner{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        entity_id: felt, idx: felt, data_len: felt, data: felt*
    ) {
        if (idx == data_len) {
            return ();
        }

        Component_state.write(entity_id, idx + 1, data[0]);
        return write_inner(entity_id, idx + 1, data_len, data + 1);
    }

    func set{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        entity_id: felt, data_len: felt, data: felt*
    ) {
        alloc_locals;

        let world_address = assert_world_address();
        // authorize

        Component_state.write(entity_id, 0, data_len);
        write_inner(entity_id, 0, data_len, data);

        IWorld.register_component_value_set(world_address, entity_id, 'id', data_len, data);

        return ();
    }

    func read_inner{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        entity_id: felt, idx: felt, data_len: felt, data: felt*
    ) -> (data_len: felt, data: felt*) {
        if (idx == data_len) {
            return (data_len, data);
        }

        let (part) = Component_state.read(entity_id, idx + 1);
        assert data[idx] = part;

        return read_inner(entity_id, idx + 1, data_len, data);
    }

    func get{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(entity_id: felt) -> (
        data_len: felt, data: felt*
    ) {
        let (data: felt*) = alloc();
        let (data_len) = Component_state.read(entity_id, 0);
        return read_inner(entity_id, 0, data_len, data);
    }

    func assert_world_address{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> felt {
        let (existing_world_address) = Registerable.get_world_address();
        with_attr error_message("Component: world address not set") {
            assert_not_zero(existing_world_address);
        }
        return existing_world_address;
    }
}
