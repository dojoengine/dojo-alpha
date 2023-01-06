// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts for Cairo v0.6.0 (introspection/erc165/library.cairo)

%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.math import assert_not_equal
from starkware.cairo.common.bool import TRUE

// ERC165
const IERC165_ID = 0x01ffc9a7;
const INVALID_ID = 0xffffffff;

@storage_var
func ERC165_supported_interfaces(interface_id: felt) -> (is_supported: felt) {
}

@contract_interface
namespace IERC165 {
    func supports_interface(
        interface_id: felt
    ) -> (success: felt) {
    }
}

namespace ERC165 {
    func supports_interface{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        interface_id: felt
    ) -> (success: felt) {
        if (interface_id == IERC165_ID) {
            return (success=TRUE);
        }
        // Checks interface registry
        let (is_supported) = ERC165_supported_interfaces.read(interface_id);
        return (success=is_supported);
    }

    func register_interface{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        interface_id: felt
    ) {
        with_attr error_message("ERC165: invalid interface id") {
            assert_not_equal(interface_id, INVALID_ID);
        }
        ERC165_supported_interfaces.write(interface_id, TRUE);
        return ();
    }
}
