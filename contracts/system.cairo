%lang starknet

from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.math import assert_not_zero

from contracts.interfaces import IWorld
from contracts.libraries.registerable import Registerable
from contracts.libraries.erc165 import ERC165

// TODO: Compute component interface id
const INTERFACE_ID = 0xbeef;

namespace System {
    func initialize{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        world_address: felt
    ) {
        Registerable.initialize(world_address);
        ERC165.register_interface(INTERFACE_ID);
        return ();
    }

    func supports_interface{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        interface_id: felt
    ) -> (success: felt) {
        return ERC165.supports_interface(interface_id);
    }
}
