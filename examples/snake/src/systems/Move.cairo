%lang starknet

from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.math_cmp import is_le

from contracts.constants.Constants import ECS_TYPE

from contracts.world.registerable import Registerable
from contracts.world.IWorld import IWorld

from src.components.Position import IPosition, Position, ID as PositionID

const ID = 'snake.system.Move';

const MAP_SIZE = 100;

@contract_interface
namespace IMove {
    func initialize(world_address: felt) {
    }

    func execute(entity_id: felt, next_position_len: felt, next_position: Position*) {
    }
}

@external
func initialize{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    world_address: felt
) {
    Registerable.initialize(world_address);
    Registerable.register(ID, ECS_TYPE.SYSTEM);
    return ();
}

// single function that executes the move system
@external
func execute{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    entity_id: felt, next_position_len: felt, next_position: Position*
) {
    alloc_locals;
    // TODO: Assert Caller is World / Admin / Approved System
    // World.assert_caller_is_world();

    let position_address = Registerable.get_address_by_id(PositionID);
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
