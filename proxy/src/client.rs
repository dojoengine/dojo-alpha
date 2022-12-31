use hello_world::greeter_client::GreeterClient;
use hello_world::ExecuteRequest;

pub mod hello_world {
    tonic::include_proto!("helloworld");
}

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    let mut client = GreeterClient::connect("http://[::1]:50051").await?;

    let request = tonic::Request::new(ExecuteRequest {
        system_guid: "world.system.example".into(),
        entity: "1234".into(),
        data_len: 0,
        data: vec![],
    });

    let response = client.execute(request).await?;

    println!("RESPONSE={:?}", response);

    Ok(())
}
