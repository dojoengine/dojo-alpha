The `World` contract exists primarily as a central entrypoint to an onchain world:
 - Manages component / system registry to simplify lookups.
 - Manages provisioning autoincremented entity ids.
 - Serves as event mux for all components and systems in the world.

The world exposes the following interface:

```
@contract_interface
namespace IWorld {
    // Register an entity or component.
    func register(cls_hash: felt, calldata_len: felt, calldata: felt*) {
    }
    // Lookup an entity, component, or system.
    func lookup(key: felt) -> (value: felt) {
    }
}
```

```
// Register the Position component with the world. Position stores the x and y coordinates of an entity.
IWorld.register(world_address, position_class_hash, 0, empty_calldata);

// Register the Move system with the world. Manages the 
IWorld.register(world_address, move_class_hash, 0, empty_calldata);
```