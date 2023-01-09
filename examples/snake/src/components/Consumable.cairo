%lang starknet

from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.segments import relocate_segment
from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.lang.compiler.lib.registers import get_fp_and_pc
from starkware.starknet.common.syscalls import get_block_timestamp
from starkware.cairo.common.math import unsigned_div_rem

from contracts.component import Component
from contracts.libraries.erc165 import ERC165
from contracts.libraries.writable import Writable

const ID = 'component.Consumable';

struct Consumable {
    start: felt,
    duration: felt,
    offset: felt,
}

@contract_interface
namespace IConsumable {
    func initialize(world_address: felt, calldata_len: felt, calldata: felt*) {
    }

    func set(entity_id: felt, consumable_len: felt, consumable: Consumable*) {
    }

    func get(entity_id: felt) -> (consumable_len: felt, consumable: Consumable*) {
    }

    func epoch(entity_id: felt) -> (epoch: felt) {
    }
}

@external
func initialize{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    world_address: felt, calldata_len: felt, calldata: felt*
) {
    Component.initialize(world_address);
    return ();
}

@external
func set{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    entity_id: felt, consumable_len: felt, consumable: Consumable*
) {
    Component.set(entity_id, Consumable.SIZE, cast(consumable, felt*));
    return ();
}

@view
func get{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(entity_id: felt) -> (consumable_len: felt, consumable: Consumable*) {
    let (data_len, data) = Component.get(entity_id);
    let consumable: Consumable* = alloc();

    if (data_len == 0) {
        assert consumable.start = 0;
        assert consumable.duration = 0;
        assert consumable.offset = 0;
        return (consumable_len=1, consumable=consumable);
    }

    assert consumable.start = data[0];
    assert consumable.duration = data[1];
    assert consumable.offset = data[2];
    return (consumable_len=1, consumable=consumable);
}

// TODO: Update to handle reseting consumable duration when consumed.
@view
func epoch{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(entity_id: felt) -> (epoch: felt) {
    let (consumable_len, p) = get(entity_id);
    let (now) = get_block_timestamp();
    let elapsed = now - p.start + p.offset;
    let (epoch, _) = unsigned_div_rem(elapsed, p.duration);
    return (epoch=epoch);
}

@view
func id{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (id: felt) {
    return (id=ID);
}

@view
func supports_interface{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(interface_id: felt) -> (success: felt) {
    return ERC165.supports_interface(interface_id);
}

@external
func grant_writer{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(address: felt) {
    return Writable.grant_writer(address);
}

@external
func revoke_writer{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(address: felt) {
    return Writable.revoke_writer(address);
}

@external
func renounce_writer{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(address: felt) {
    return Writable.renounce_writer(address);
}

@external
func transfer_admin{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(new_admin: felt) {
    return Writable.transfer_admin(new_admin);
}

@view
func is_writer{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(address: felt) -> (authorized: felt) {
    return Writable.is_writer(address);
}

@view
func is_admin{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(address: felt) -> (authorized: felt) {
    return Writable.is_admin(address);
}

@view
func admin{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (admin: felt) {
    return Writable.admin();
}