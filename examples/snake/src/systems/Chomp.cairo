%lang starknet

from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.math_cmp import is_le
from starkware.cairo.common.math import unsigned_div_rem
from starkware.cairo.common.hash import hash2
from starkware.starknet.common.syscalls import get_block_timestamp

from contracts.interfaces import IWorld
from contracts.system import System
from contracts.libraries.erc165 import ERC165
from contracts.libraries.registerable import Registerable

from src.systems.Move import MAP_SIZE
from src.components.Consumable import IConsumable, Consumable, ID as ConsumableID
from src.components.Position import IPosition, Position, ID as PositionID

const ID = 'system.Chomp';

@contract_interface
namespace IMove {
    func initialize(world_address: felt, calldata_len: felt, calldata: felt*) {
    }

    func execute(entity_id: felt) {
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
    entity_id: felt
) {
    alloc_locals;

    let position_address = Registerable.lookup(PositionID);
    let (_, current_position) = IPosition.get(position_address, entity_id);

    let interval_address = Registerable.lookup(ConsumableID);
    let (_, current_consumable) = IConsumable.get(interval_address, entity_id);
    let (current_epoch) = IConsumable.epoch(interval_address, entity_id);

    let (rand) = hash2{hash_ptr=pedersen_ptr}(entity_id, current_epoch);

    let (_, x) = unsigned_div_rem(MAP_SIZE, rand);
    let (_, y) = unsigned_div_rem(MAP_SIZE, rand);

    // check valid
    assert current_position.x = x;
    assert current_position.y = y;

    let (now) = get_block_timestamp();
    let next_consumable: Consumable* = alloc();
    assert next_consumable.start = current_consumable.start;
    assert next_consumable.duration = current_consumable.duration;
    assert next_consumable.offset = (now - current_consumable.start) - current_epoch * current_consumable.duration;
    IConsumable.set(interval_address, entity_id, 1, next_consumable);

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
