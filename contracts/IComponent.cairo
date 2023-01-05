// MIT License

%lang starknet

@contract_interface
namespace IComponent {
    func set(id: felt, data_len: felt, data: felt*) {
    }

    func get(entity_id: felt) -> (data_len: felt, data: felt*) {
    }

    func register() {
    }
}
