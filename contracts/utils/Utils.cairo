%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.registers import get_fp_and_pc
from contracts.components.location.Constants import ComponentStruct

namespace Utils {
    // Since we cannot send arbitrary data to the contract, we need to cast the struct to an array
    func component_struct_to_arr{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        value: ComponentStruct
    ) -> (arr_len: felt, arr: felt*) {
        let (__fp__, _) = get_fp_and_pc();
        return (ComponentStruct.SIZE, &value);
    }
    func arr_to_component_struct{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        arr_len: felt, arr: felt*
    ) -> ComponentStruct {
        assert arr_len = ComponentStruct.SIZE;

        let cs: ComponentStruct* = cast(arr, ComponentStruct*);
        return ([cs]);
    }
}
