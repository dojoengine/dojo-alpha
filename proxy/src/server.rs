use starknet::{
    core::types::FieldElement,
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

        let proxy_local_tx = &BroadcastedInvokeTransaction::V1(BroadcastedInvokeTransactionV1 {
            max_fee: FieldElement::ONE,
            signature: vec![
                FieldElement::from_hex_be(
                    "156a781f12e8743bd07e20a4484154fd0baccee95d9ea791c121c916ad44ee0",
                )
                .unwrap(),
                FieldElement::from_hex_be(
                    "7228267473c670cbb86a644f8696973db978c51acde19431d3f1f8f100794c6",
                )
                .unwrap(),
            ],
            nonce: FieldElement::from_hex_be(&inner_request.nonce).unwrap(),
            sender_address: FieldElement::from_hex_be(&inner_request.sender_address).unwrap(),
            calldata: vec![FieldElement::from_hex_be("1").unwrap()],
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
