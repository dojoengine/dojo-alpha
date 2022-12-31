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
        _request: Request<ExecuteRequest>, // Accept request of type HelloRequest
    ) -> Result<Response<ExecuteResponse>, Status> {
        // Return an instance of type HelloReply


        let reply = hello_world::ExecuteResponse {
            success: true, // We must use .into_inner() as the fields of gRPC requests and responses are private
        };


        // TODO: This is where we forward txs from the client to the devenet AND starknet

        // Placeholders as example

        let provider = SequencerGatewayProvider::starknet_nile_localhost();
        let tst_token_address =
            felt!("0x07394cbe418daa16e42b87ba67372d4ab4a5df0b05c6e554d158458ce245bc10");

        let call_result = provider
            .call_contract(
                CallFunction {
                    contract_address: tst_token_address,
                    entry_point_selector: selector!("balanceOf"),
                    calldata: vec![FieldElement::from_hex_be(
                        "0x0380F7644A98f9D9915dBAa0bbD4B3fe8671A46fBf9f9ab7A7B1DC3b7Ce9EC72",
                    )
                    .unwrap()],
                },
                BlockId::Latest,
            )
            .await
            .expect("failed to call contract");

        dbg!(call_result);

        println!("Call indexer");

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
