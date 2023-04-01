contract;

use std::{
    hash::{keccak256, sha256},
     logging::log,
     call_frames::*,
    contract_id::ContractId,
    revert::require,
    storage::*,
    token::*,
    block::*,
    storage::*,
    auth::*,
    vec::*,
    };
struct Transaction{
    tokenId: ContractId,
    to:Identity,
    amount : u64,
    time : u64,
    description:str[300],
    approvals:u64,
    // voters : Vec<b256>,
    // voters : Vec<b256>,
}
impl Transaction {
    pub fn new(tokenId : ContractId,to: Identity, amount: u64, time: u64, description:str[300],approvals:u64 ) -> Self {
        Self {tokenId,to,amount,time,description,approvals}
    }
}
storage{
    users : StorageVec<b256>  = StorageVec{},
    transactions: StorageMap<b256,Transaction> = StorageMap{},
    threshold:u64 = 0,
    initialized:bool = false,
    voters: StorageMap<(b256,b256),bool> = StorageMap{},//map[(transactionHash, UserAddress)]

}


abi MultiSig {
    #[payable, storage(read,write)]
    fn deposit();
    #[storage(read,write)]
    fn proposal(tokenId : ContractId,to: Identity, amount: u64, description:str[300]);
    #[storage(read,write)]
    fn vote(transaction : b256, approve : bool);
}

impl MultiSig for Contract {
    #[storage(read,write),payable]
    fn deposit(){
        //TODO definir Errores
        // require(initialized,)
        let sender: Identity = msg_sender().unwrap();
        let sender = match sender{
            Identity::Address(address) =>address.value,
            Identity::ContractId(con) =>con.value,
        };
        storage.users.push(sender);
    }

    #[storage(read,write)]
    fn proposal(tokenId : ContractId,to: Identity, amount: u64, description:str[300] ){
        let time = timestamp();
        let object = Transaction::new(tokenId,to,amount,time,description,0);
        let hash = keccak256(object);
        storage.transactions.insert(hash,object);
    }
    #[storage(read,write)]
    fn vote(transaction : b256, approve : bool){
        let sender: Identity = msg_sender().unwrap();
        let sender = match sender{
            Identity::Address(address) =>address.value,
            Identity::ContractId(con) =>con.value,
        };
        let mut trans = storage.transactions.get(transaction).unwrap();
        if(approve){
            trans.approvals = trans.approvals+ 1;
        }
        storage.voters.insert((transaction,sender),true);
    }

    // fn invertir()
    // {
    //     //require(votacion>=50%)
    //     //require()
    // }
    
}
