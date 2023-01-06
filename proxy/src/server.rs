use starknet::{
    core::{crypto::ecdsa_sign, types::FieldElement},
    providers::jsonrpc::{
        models::{BroadcastedInvokeTransaction, BroadcastedInvokeTransactionV1},
        HttpTransport, JsonRpcClient,
    },
};
use tonic::{transport::Server, Request, Response, Status};

use hello_world::greeter_server::{Greeter, GreeterServer};
use hello_world::{ExecuteRequest, ExecuteResponse};

use url::Url;

pub mod hello_world {
    tonic::include_proto!("helloworld"); // The string specified here must match the proto package name
}

// Account #0 - NOTE: This is just devnet account, not a real one
pub const ADDRESS: &str = "0x605d49242d6d1476d93f2282900e05ec3120f796b03f238bd8a339005363d49";
// const PUBLIC: &str = "0x2a4433c15f014f4b8db9ae3eb8ba85a089ac22fdcc0c38e534dc8a2c471572f";
const PRIVATE: &str = "0x6d1fa9062223bccdb8db99ff53b8d820";

const NONCE: &str = "1";
const MAX_FEE: &str = "1";

const TESTNET_ETH_ADDRESS: &str =
    "0x49D36570D4E46F48E99674BD3FCC84644DDD6B96F7C741B1562B82F9E004DC7";

const SELECTOR: &str = "transfer";

const ADDRESS_2: &str = "0x6e65ff327121a4fdfacc538bf5b8abef39015aad7777a0295063a1fc66829a7";

#[derive(Debug, Default)]
pub struct MyGreeter {}

fn create_jsonrpc_client() -> JsonRpcClient<HttpTransport> {
    JsonRpcClient::new(HttpTransport::new(
        Url::parse("http://127.0.0.1:5050/rpc").unwrap(),
    ))
}

#[tonic::async_trait]
impl Greeter for MyGreeter {
    async fn execute(
        &self,
        request: Request<ExecuteRequest>,
    ) -> Result<Response<ExecuteResponse>, Status> {
        let inner_request = request.into_inner();

        let signature = ecdsa_sign(
            &FieldElement::from_hex_be(PRIVATE).unwrap(),
            &FieldElement::from_hex_be(
                "06fea80189363a786037ed3e7ba546dad0ef7de49fccae0e31eb658b7dd4ea76",
            )
            .unwrap(),
        )
        .unwrap();

        let proxy_local_tx = &BroadcastedInvokeTransaction::V1(BroadcastedInvokeTransactionV1 {
            max_fee: FieldElement::ONE,
            signature: vec![signature.r, signature.s],
            nonce: FieldElement::from_hex_be(&inner_request.nonce).unwrap(),
            sender_address: FieldElement::from_hex_be(&inner_request.sender_address).unwrap(),
            calldata: vec![
                FieldElement::from_hex_be(TESTNET_ETH_ADDRESS).unwrap(),
                FieldElement::from_hex_be(SELECTOR).unwrap(),
                FieldElement::from_hex_be(ADDRESS_2).unwrap(),
                FieldElement::from_hex_be("1000000000000000").unwrap(),
                FieldElement::from_hex_be("0").unwrap(),
            ],
        });

        let rpc_client = create_jsonrpc_client();

        let proxy_tx = rpc_client
            .add_invoke_transaction(proxy_local_tx)
            .await
            .unwrap();

        // let starknet_tx = rpc_client
        //     .add_invoke_transaction(proxy_local_tx)
        //     .await
        //     .unwrap();

        dbg!(proxy_tx);

        // dbg!(starknet_tx);

        println!("Call indexer");

        let reply = hello_world::ExecuteResponse {
            success: true, // We must use .into_inner() as the fields of gRPC requests and responses are private
        };

        Ok(Response::new(reply)) // Send back our formatted greeting
    }
}

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    let addr = "[::1]:50051".parse()?;
    let greeter = MyGreeter::default();

    Server::builder()
        .add_service(GreeterServer::new(greeter))
        .serve(addr)
        .await?;

    Ok(())
}
