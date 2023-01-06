%lang starknet
from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.cairo_builtins import HashBuiltin

from src.systems.Move import IMove
from src.components.Position import IPosition, Position

@external
func __setup__{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() {
    alloc_locals;

    // Deploy contracts
    local world_address: felt;
    %{
        context.world_address = deploy_contract("../../contracts/world/World.cairo", []).contract_address
        ids.world_address = context.world_address
    %}

    local move_address: felt;
    %{ 
        context.move_address = deploy_contract("./src/systems/Move.cairo", []).contract_address
        ids.move_address = context.move_address
    %}
    IMove.initialize(move_address, world_address);

    local position_address: felt;
    %{ 
        context.position_address = deploy_contract("./src/components/Position.cairo", []).contract_address
        ids.position_address = context.position_address
    %}
    IMove.initialize(position_address, world_address);

    return ();
}

@external
func test_move{syscall_ptr: felt*, range_check_ptr, pedersen_ptr: HashBuiltin*}() {
    alloc_locals;

    local move_address;
    %{ ids.move_address = context.move_address %}

    local position_address;
    %{ ids.position_address = context.position_address %}

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
