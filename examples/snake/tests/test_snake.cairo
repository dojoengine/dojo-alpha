%lang starknet
from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.cairo_builtins import HashBuiltin

from contracts.interfaces import IWorld
from src.systems.Move import IMove, ID as MoveID
from src.components.Position import IPosition, Position, ID as PositionID

@external
func __setup__{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() {
    alloc_locals;

    // Deploy contracts
    local world_address: felt;
    local move_class_hash: felt;
    local position_class_hash: felt;
    %{
        context.world_address = deploy_contract("../../contracts/World.cairo", []).contract_address
        ids.world_address = context.world_address

        context.move_class_hash = declare("./src/systems/Move.cairo").class_hash
        ids.move_class_hash = context.move_class_hash

        context.position_class_hash = declare("./src/components/Position.cairo").class_hash
        ids.position_class_hash = context.position_class_hash
    %}

    let (empty_calldata) = alloc();
    IWorld.register(world_address, position_class_hash, 0, empty_calldata);
    IWorld.register(world_address, move_class_hash, 0, empty_calldata);

    return ();
}

@external
func test_move{syscall_ptr: felt*, range_check_ptr, pedersen_ptr: HashBuiltin*}() {
    alloc_locals;

    local world_address;
    %{ ids.world_address = context.world_address %}

    let (position_address) = IWorld.lookup(world_address, PositionID);
    let (move_address) = IWorld.lookup(world_address, MoveID);

    let entity_id = 420;
    let (_, current_position) = IPosition.get(position_address, entity_id);

    assert current_position.x = 0;
    assert current_position.y = 0;

    let next_position: Position* = alloc();
    assert next_position.x = 1;
    assert next_position.y = 0;

    IMove.execute(move_address, entity_id, 1, next_position);

    let (_, updated_position) = IPosition.get(position_address, entity_id);
    assert updated_position.x = 1;
    assert updated_position.y = 0;

    return ();
}
