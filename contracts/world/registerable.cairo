%lang starknet

from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.starknet.common.syscalls import get_caller_address, get_contract_address

from contracts.world.IWorld import IWorld

//
// WORLD LIBRARY------------
//
// Import into Systems and Components to init the World.
// Contains helper Auth functions for the World.

@storage_var
func Registerable_world_address() -> (address: felt) {
}

namespace Registerable {
    // set world
    func initialize{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        world_address: felt
    ) {
        let (existing_world_address) = Registerable_world_address.read();
        with_attr error_message("Registerable: already initialized") {
            assert existing_world_address = 0;
        }

        Registerable_world_address.write(world_address);
        return ();
    }

    func get_world_address{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (
        address: felt
    ) {
        return Registerable_world_address.read();
    }

    // @notice: assert caller is world
    func assert_caller_is_world{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() {
        let caller_address = get_caller_address();
        let world_address = Registerable_world_address.read();

        assert caller_address = world_address;

        return Registerable_world_address.read();
    }

    // @notice: register component/system in the world
    func register{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        id: felt, ecs_type: felt
    ) {
        let (world_addr) = get_world_address();
        IWorld.register(world_addr, id, ecs_type);
        return ();
    }

    func get_address_by_id{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        id: felt
    ) -> felt {
        let (world_address) = get_world_address();
        let (component_address) = IWorld.get_address_by_id(world_address, id);
        return (component_address);
    }
}
