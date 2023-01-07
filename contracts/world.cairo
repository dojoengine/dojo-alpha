%lang starknet

from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.cairo_builtins import BitwiseBuiltin, HashBuiltin
from starkware.cairo.common.bool import TRUE, FALSE
from starkware.starknet.common.syscalls import get_caller_address, get_contract_address, deploy
from starkware.cairo.common.math import assert_not_zero

from contracts.interfaces import IComponent, IInitializable, ISystem
from contracts.libraries.registry import Registry
from contracts.libraries.erc165 import IERC165
from contracts.component import INTERFACE_ID as COMPONENT_INTERFACE_ID
from contracts.system import INTERFACE_ID as SYSTEM_INTERFACE_ID

// WORLD ------------
// The World is the entry point for all components and systems. You need to register your component or system
// with the world before you can use it. The world is responsible for calling the systems and passing the data
// to them. Systems and Components are registered via calls on their contracts.
// Systems, Components and Etnities all exist in the same table. They are differentiated by their Archetype.
// ------------------

//
// EVENTS ------------
//

// @notice: emitted when a component value is set
// @param: entity_id: the entity the component value is set on
// @param: component_address: the component address
// @param: data_len: the length of the data
// @param: data: the data
@event
func ComponentValueSet(entity_id: felt, component_address: felt, data_len: felt, data: felt*) {
}

//
// REGISTER ---------------
//

// @notice: General register function. This is called by the component or system to register itself with the world.
// @param: cls_hash: the address of the component / system
// @param: calldata_len: the length of the component / system initialization calldata
// @param: calldata: the component / system initialization calldata
// @returns: the address of the component / system contract
@external
func register{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    cls_hash: felt, calldata_len: felt, calldata: felt*
) -> (address: felt) {
    alloc_locals;

    let (world_address) = get_contract_address();
    let (address) = deploy(
        class_hash=cls_hash,
        contract_address_salt=0,
        constructor_calldata_size=calldata_len,
        constructor_calldata=calldata,
        deploy_from_zero=FALSE,
    );

    IInitializable.initialize(address, world_address, calldata_len, calldata);

    let (is_component) = IERC165.supports_interface(address, COMPONENT_INTERFACE_ID);
    if (is_component == TRUE) {
        let (caller_address) = get_caller_address();
        let (id) = IComponent.id(address);
        IComponent.transfer_admin(address, caller_address);
        Registry.register(address, id);
        return (address=address);
    }

    let (is_system) = IERC165.supports_interface(address, SYSTEM_INTERFACE_ID);
    if (is_system == TRUE) {
        let (id) = ISystem.id(address);
        Registry.register(address, id);
        return (address=address);
    }

    with_attr error_message("World: must be either a component or a system") {
        assert 1 = 0;
    }

    return (address=0);
}

// @notice: register a component value set
// @param: entity: the entity to set the value on
// @param: component: the component to set the value on
// @param: data_len: the length of the data
// @param: data: the data to set
@external
func after_component_set{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    entity_id: felt, data_len: felt, data: felt*
) {
    alloc_locals;

    let (caller_address) = get_caller_address();
    assert_registered(caller_address);

    // set 0 here for now - we could pass an address in the future to set an address for the entity
    // Registry.set(0, entity_id);
    ComponentValueSet.emit(entity_id, caller_address, data_len, data);
    return ();
}

//
// VIEWS ------------------------
//

// get address by id
@view
func lookup{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    key: felt
) -> (value: felt) {
    return Registry.get(key);
}


func assert_registered{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(key: felt) {
    let (value) = lookup(key);
    with_attr error_message("World: component / system not registered") {
        assert_not_zero(value);
    }
    return ();
}