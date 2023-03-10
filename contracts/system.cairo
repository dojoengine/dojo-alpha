%lang starknet

from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.math import assert_not_zero

from contracts.interfaces import IComponent, IWorld
from contracts.libraries.registerable import Registerable
from contracts.libraries.erc165 import ERC165

// TODO: Compute system interface id
const INTERFACE_ID = 0xbeef;

namespace System {
    func initialize{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        world_address: felt
    ) {
        Registerable.initialize(world_address);
        ERC165.register_interface(INTERFACE_ID);
        return ();
    }

    func set_inner{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        entity_id: felt, components_len: felt, components: felt*, components_set_calldata_len: felt, components_set_calldata: felt*
    ) -> () {
        if (components_len == 0) {
            return ();
        }

        let component_address = components[0];
        let calldata_len = components_set_calldata[0];
        let calldata = components_set_calldata + 1;

        IComponent.set(component_address, calldata_len, calldata);

        return set_inner(entity_id, components_len - 1, components + 1, components_set_calldata_len - calldata_len - 1, components_set_calldata + calldata_len + 1);
    }

    func supports_interface{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        interface_id: felt
    ) -> (success: felt) {
        return ERC165.supports_interface(interface_id);
    }
}
