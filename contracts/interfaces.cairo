// MIT License

%lang starknet

@contract_interface
namespace IWorld {
    func lookup(key: felt) -> (value: felt) {
    }
    func register(cls_hash: felt, calldata_len: felt, calldata: felt*) -> (address: felt) {
    }
    func spawn(components_len: felt, components: felt*) -> (id: felt) {
    }
    func register_component_value_set(entity: felt, component: felt, data_len: felt, data: felt*) {
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

    func grant_writer(address: felt) {
    }

    func revoke_writer(address: felt) {
    }

    func renounce_writer(address: felt) {
    }

    func transfer_admin(new_admin: felt) {
    }

    func is_writer(address: felt) -> (authorized: felt) {
    }

    func is_admin(address: felt) -> (authorized: felt) {
    }

    func admin() -> (admin: felt) {
    }
}

@contract_interface
namespace ISystem {
    func initialize(world_address: felt, calldata_len: felt, calldata: felt*) {
    }

    func id() -> (id: felt) {
    }
}
