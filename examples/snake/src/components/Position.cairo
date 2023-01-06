%lang starknet

from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.segments import relocate_segment
from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.lang.compiler.lib.registers import get_fp_and_pc

from contracts.component import Component
from contracts.libraries.erc165 import ERC165
from contracts.libraries.writable import Writable

const ID = 'component.Location';

struct Position {
    x: felt,
    y: felt,
}

@contract_interface
namespace IPosition {
    func initialize(world_address: felt, calldata_len: felt, calldata: felt*) {
    }

    func set(entity_id: felt, position_len: felt, position: Position*) {
    }

    func get(entity_id: felt) -> (position_len: felt, position: Position*) {
    }
}

@external
func initialize{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    world_address: felt, calldata_len: felt, calldata: felt*
) {
    Component.initialize(world_address);
    return ();
}

// TODO: Can we avoid passing by reference here? Then we wouldn't need to pass
// the length of the struct.
@external
func set{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    entity_id: felt, position_len: felt, position: Position*
) {
    // authorize

    Component.set(entity_id, Position.SIZE, cast(position, felt*));

    return ();
}

// get Schema for component
@external
func get_schema{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (
    schema: Position
) {
    return (schema=Position(1, 2));
}

// get Schema for component
@view
func get{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(entity_id: felt) -> (position_len: felt, position: Position*) {
    let (data_len, data) = Component.get(entity_id);
    let position: Position* = alloc();

    if (data_len == 0) {
        assert position.x = 0;
        assert position.y = 0;
        return (position_len=1, position=position);
    }

    assert position.x = data[0];
    assert position.y = data[1];
    return (position_len=1, position=position);
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