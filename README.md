# Cairo DOJO

- [x] Cairo 0.10 ECS System
- [x] Dockerised Devnet
- [ ] Rust testing client
- [ ] Proxy server to relay client requests to networks
- [ ] Bevy game client example
- [ ] Cairo 1 ECS system

## Cairo ECS

Develop Cairo with:

```
// Create StarkNet env then
source ~/cairo_venv/bin/activate
```

Deploy demo contracts by updating the `protostar.toml` profile that you want to deploy to {testnet, testnet2, devnet}. You will need to locally define the `account-address` field to the address you want to deploy from and the `private-key-path` to the file where you will write the private key of the account address you choose.

Then run
```
./scripts/deploy.sh <profile>
```

It will default to the profile `devnet` if none is passed into the script.

## Apibara + Devnet

```
docker-compose up
```

## Proxy

You will need rust installed. Then run the docker then these commands:

```
// Starts server and connects to devnet
cargo run --bin helloworld-server

// Test client to ping server. This just exists for testing
cargo run --bin helloworld-client
```

# Theory

## What's an Entity-Component-System (ECS)?

An ECS system is a way of organizing and managing the architecture of a game or application. ECS stands for "_Entity-Component-System_", and it is a design pattern that is often used in game development to create reusable and modular code.

In an ECS system, entities are the objects that exist in the game or application, components are the data that defines their attributes and behavior, and systems are the logic that operates on the entities and components to make the game or application work.

ECS systems are known for their flexibility and scalability, which makes them well-suited for large, complex projects.

### High level princibles of an ECS

- Entities are defined by their components, not their behavior
- Components should be small and focused
- Systems operate on entities through their components
- Data should be stored in components, not systems
- Entities and components should be created and destroyed dynamically

# Why put an ECS on-chain?

The benefits of using an entity component system (ECS) in a blockchain application are mainly related to improved flexibility and composability.

Using ECS can help improve flexibility by allowing developers to easily add, remove, or modify the data and behavior of entities without having to make changes to the underlying blockchain infrastructure. This makes it easier to adapt the application to changing requirements or to integrate new features over time.

Additionally, ECS can help improve composability by allowing developers to distribute the data and behavior of entities across different worlds and applications.

# But why do we REALLY care about putting stuff on-chain anyways?

Blockchain's characteristics lie in composability and [hardness](https://stark.mirror.xyz/n2UpRqwdf7yjuiPKVICPpGoUNeDhlWxGqjulrlpyYi0). Stuff put on-chain can be reused permissionlessly, anything running or stored has to obey clearly defined rules. This means we can write completely novel types of apps: not only games but entire _worlds_ with their rulesets and physics. Blockchains allow a whole new range of affordances never leveraged before (see Gubsheep's [on-chain gaming thesis](https://gubsheep.substack.com/p/the-strongest-crypto-gaming-thesis) and aaaaaaa's [thoughts on on-chain gaming](https://dialectic.ch/editorial/thoughts-on-chain-gaming)).

An ECS is an abstraction that allows us to build up composable worlds easily and truly leverage what the blockchain can do. Build your own world, interact with others, negotiate metaphysics, and endlessly recompose.

It's a permissionless, infinite sandbox that never runs out of sand.

# Are there any on-chain ECS?

The chads at [Lattice.xyz](https://lattice.xyz/) have built an ECS in Solidity called [MUD](https://mud.dev/).

Videos

- Lattice keynote at DEVCON 2022: https://www.youtube.com/watch?v=P9UTCLCz-iA
- Intro to MUD: https://www.youtube.com/watch?v=j-_Zf8o5Wlo
- minecraft built on Optimism using mud: https://www.youtube.com/watch?v=mv3jA4USZtg

Since StarkNet has a lot of gaming projects, let's see if we can build an ECS system in Cairo.

![ecs](/ECS.png)

# Overall roadmap

- Wait for cairo 1.0 to be released to actually start coding everything but jam about designs as fast as possible on current Cairo version
- We need an easy way to spin up permissioned devnets to actually test out composability. We build on top of Shard Lab's https://github.com/Shard-Labs/starknet-devnet
- Need an indexing system to stream events, we'll use Ceccon's Apibara https://www.apibara.com/. Repo for devnet + apibara here: https://gist.github.com/fracek/a087ebf776aaa29aa40717abd259a084
- See if we can integrate Jun's work on DIP (Full-Rust Web3 application toolkit focus on, ECS based event-driven development): https://github.com/diptools/dip
- After all is said and built we'll need ECS to run on application-specific rollups or L3s. Slush is an excellent candidate: https://github.com/slushsdk/slush/releases/tag/v0.2.0

# Resources

- [What's an ECS?](https://github.com/SanderMertens/ecs-faq)
- [loaf's figma explanation](https://www.figma.com/file/qAjxTZc6tRonazjfsv9GZa/ECS?node-id=0%3A1&t=frLQWE5fVjIvblII-0)
- [MUD github repo](https://github.com/latticexyz/mudbasics#mudbasics)
- [Autonomous worlds blogpost by Ludens](https://0xparc.org/blog/autonomous-worlds)
- [are.na collection of links on autonomous worlds / on-chain realities](https://www.are.na/sylve-chevet/on-chain-realities-and-autonomous-worlds)

# Wanna contribute?

Reach out to [@lordofafew](https://twitter.com/lordofafew) and [@sylvechv](https://twitter.com/sylvechv) on Twitter
