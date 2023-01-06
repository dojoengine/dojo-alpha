// this is a client to test the proxy server.

use std::vec;

use hello_world::greeter_client::GreeterClient;
use hello_world::ExecuteRequest;
use starknet::core::crypto::ecdsa_sign;
use starknet::core::types::FieldElement;

pub mod hello_world {
    tonic::include_proto!("proxy");
}

// Account #0 - NOTE: This is just devnet account, not a real one
const ADDRESS: &str = "0x605d49242d6d1476d93f2282900e05ec3120f796b03f238bd8a339005363d49";
// const PUBLIC: &str = "0x2a4433c15f014f4b8db9ae3eb8ba85a089ac22fdcc0c38e534dc8a2c471572f";
const PRIVATE: &str = "0x6d1fa9062223bccdb8db99ff53b8d820";

const NONCE: &str = "1";
const MAX_FEE: &str = "1";

const TESTNET_ETH_ADDRESS: &str =
    "0x49D36570D4E46F48E99674BD3FCC84644DDD6B96F7C741B1562B82F9E004DC7";

const SELECTOR: &str = "transfer";

const ADDRESS_2: &str = "0x6e65ff327121a4fdfacc538bf5b8abef39015aad7777a0295063a1fc66829a7";

// testing transfer on testnet

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    let mut client = GreeterClient::connect("http://[::1]:50051").await?;

    let signature = ecdsa_sign(
        &FieldElement::from_hex_be(PRIVATE).unwrap(),
        &FieldElement::from_hex_be(
            "06fea80189363a786037ed3e7ba546dad0ef7de49fccae0e31eb658b7dd4ea76",
        )
        .unwrap(),
    )
    .unwrap();

    let request = tonic::Request::new(ExecuteRequest {
        max_fee: MAX_FEE.into(),
        signature: vec![signature.r.to_string(), signature.s.to_string()],
        nonce: NONCE.into(),
        sender_address: ADDRESS.into(),
        calldata: vec![
            TESTNET_ETH_ADDRESS.into(),
            SELECTOR.into(),
            ADDRESS_2.into(),
            "1000000000000000".into(),
            "0".into(),
        ],
    });

    let response = client.execute(request).await?;

    println!("RESPONSE={:?}", response);

    Ok(())
}
