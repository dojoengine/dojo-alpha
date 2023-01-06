// MIT License

%lang starknet

@contract_interface
namespace IWorld {
    func register_component_value_set(entity: felt, component: felt, data_len: felt, data: felt*) {
    }
    func lookup(key: felt) -> (value: felt) {
    }
    func register(cls_hash: felt, calldata_len: felt, calldata: felt*) {
    }
    func execute(system_guid: felt, entity: felt, data_len: felt, data: felt*) {
    }
}

@contract_interface
namespace IInitializable {
    func initialize(world_address: felt, calldata_len: felt, calldata: felt*) {
    }
}

@contract_interface
namespace IComponent {
    func initialize(world_address: felt, calldata_len: felt, calldata: felt*) {
    }

    func id() -> (id: felt) {
    }

    func set(id: felt, data_len: felt, data: felt*) {
    }

    func get(entity_id: felt) -> (data_len: felt, data: felt*) {
    }

    func register() {
    }
}

@contract_interface
namespace ISystem {
    func initialize(world_address: felt, calldata_len: felt, calldata: felt*) {
    }

    func id() -> (id: felt) {
    }
}
