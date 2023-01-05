use std::vec;

use hello_world::greeter_client::GreeterClient;
use hello_world::ExecuteRequest;

pub mod hello_world {
    tonic::include_proto!("helloworld");
}

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    let mut client = GreeterClient::connect("http://[::1]:50051").await?;

    let request = tonic::Request::new(ExecuteRequest {
        max_fee: "world.system.example".into(),
        signature: vec!["world.system.example".into(), "world.system.example".into()],
        nonce: "0x1234".into(),
        sender_address: "0x1234".into(),
        calldata: vec!["world.system.example".into(), "world.system.example".into()],
    });

    let response = client.execute(request).await?;

    println!("RESPONSE={:?}", response);

    Ok(())
}
