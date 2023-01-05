// MIT License

%lang starknet

@contract_interface
namespace IWorld {
    func register_component_value_set(entity: felt, component: felt, data_len: felt, data: felt*) {
    }
    func get_address_by_id(ecs_address: felt) -> (address: felt) {
    }
    func register(id: felt, ecs_type: felt) {
    }

    func execute(system_guid: felt, entity: felt, data_len: felt, data: felt*) {
    }
}
