use starknet::{
    core::types::{BlockId, CallFunction, FieldElement},
    macros::{felt, selector},
    providers::{Provider, SequencerGatewayProvider},
};
use tonic::{transport::Server, Request, Response, Status};

use hello_world::greeter_server::{Greeter, GreeterServer};
use hello_world::{ExecuteRequest, ExecuteResponse};

pub mod hello_world {
    tonic::include_proto!("helloworld"); // The string specified here must match the proto package name
}

#[derive(Debug, Default)]
pub struct MyGreeter {}

#[tonic::async_trait]
impl Greeter for MyGreeter {
    async fn execute(
        &self,
        request: Request<ExecuteRequest>,
    ) -> Result<Response<ExecuteResponse>, Status> {
        let inner_request = request.into_inner().clone();

        let devnet_provider = SequencerGatewayProvider::starknet_nile_localhost();

        let testnet_provider = SequencerGatewayProvider::starknet_nile_localhost();

        let call_data = vec![
            FieldElement::from_hex_be(&inner_request.system_guid).unwrap(),
            FieldElement::from_hex_be(&inner_request.entity).unwrap(),
            FieldElement::from_hex_be(&inner_request.data_len).unwrap(),
            // data
        ];

        let dev_call_result = devnet_provider
            .call_contract(
                CallFunction {
                    contract_address: FieldElement::from_hex_be(&inner_request.system_guid)
                        .unwrap(),
                    entry_point_selector: selector!("execute"),
                    calldata: (*call_data).to_vec(),
                },
                BlockId::Latest,
            )
            .await
            .expect("failed to call contract");

        let call_result = testnet_provider
            .call_contract(
                CallFunction {
                    contract_address: FieldElement::from_hex_be(&inner_request.system_guid)
                        .unwrap(),
                    entry_point_selector: selector!("execute"),
                    calldata: (*call_data).to_vec(),
                },
                BlockId::Latest,
            )
            .await
            .expect("failed to call contract");

        dbg!(dev_call_result);

        dbg!(call_result);

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
