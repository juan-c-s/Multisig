use fuels::{prelude::*, tx::ContractId};

#[tokio::test]
async fn can_get_contract_id() {
    // let (_instance, _id) = get_contract_instance().await;
    println!(
        " 🪙  Token contract id: {}",
        _instance.contract_id(),
    );
    // Now you have an instance of your contract you can use to test each function
    let treshold = _instance.get_threshold(3).get().await.unwrap();
    // assert_eq!(0, result.value);
}
