%lang starknet

from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.math_cmp import is_le

from contracts.interfaces import IWorld
from contracts.system import System
from contracts.libraries.erc165 import ERC165
from contracts.libraries.registerable import Registerable

from src.components.Position import IPosition, Position, ID as PositionID

const ID = 'system.Move';

const MAP_SIZE = 100;

@contract_interface
namespace IMove {
    func initialize(world_address: felt, calldata_len: felt, calldata: felt*) {
    }

    func execute(entity_id: felt, next_position_len: felt, next_position: Position*) {
    }
}

@external
func initialize{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    world_address: felt, calldata_len: felt, calldata: felt*
) {
    System.initialize(world_address);
    return ();
}

// single function that executes the move system
@external
func execute{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    entity_id: felt, next_position_len: felt, next_position: Position*
) {
    alloc_locals;

    let position_address = Registerable.lookup(PositionID);
    let (_, current_position) = IPosition.get(position_address, entity_id);

    // check valid
    assert_valid_move(1, current_position, 1, next_position);

    // set data
    IPosition.set(position_address, entity_id, next_position_len, next_position);
    return ();
}

@view
func assert_valid_move{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    current_position_len: felt, current_position: Position*, next_position_len: felt, next_position: Position*
) {
    alloc_locals;

    // assert in map
    let less_than_x = is_le(MAP_SIZE, next_position.x);
    let less_than_y = is_le(MAP_SIZE, next_position.y);
    assert less_than_x + less_than_y = 0;

    // assert only one step
    let one_step_x = abs_diff(current_position.x, next_position.x);
    let one_step_y = abs_diff(current_position.y, next_position.y);
    assert one_step_x + one_step_y = 1;

    return ();
}

@view
func id{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (id: felt) {
    return (id=ID);
}

@view
func supports_interface{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(interface_id: felt) -> (success: felt) {
    return ERC165.supports_interface(interface_id);
}

func abs_diff{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    a: felt, b: felt
) -> felt {
    // assert in map
    let less = is_le(b, a);

    if (less == 1) {
        return (a - b);
    } else {
        return (b - a);
    }
}
