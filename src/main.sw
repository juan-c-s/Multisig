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
    context::*,
    };
struct Transaction{
    tokenId: ContractId,
    to:Identity,
    amount : u64,
    time : u64,
    description:str[300],
    approvals:u64,
    totalVotes:u64,
}
impl Transaction {
    pub fn new(tokenId : ContractId,to: Identity, amount: u64, time: u64, description:str[300],approvals:u64 ,totalVotes:u64) -> Self {
        Self {tokenId,to,amount,time,description,approvals,totalVotes}
    }
}
storage{
    users : StorageMap<b256,bool> = StorageMap{},
    transactions: StorageMap<b256,Transaction> = StorageMap{},
    threshold:u64 = 0,
    initialized:bool = false,
    voters: StorageMap<(b256,b256),bool> = StorageMap{},//map[(transactionHash, UserAddress)]
    totalUsers:u64 = 0,

}

enum Error{
    ExampleError :(),
    NotInitialized:(),
    AlreadyInitialized:(),
    NotValidThreshold:(),
    UserNotFound:(),
    NotEnoughFunds:(),
    ProposalFinished:(),
}
abi MultiSig {
    #[payable, storage(read,write)]
    fn deposit();
    #[storage(read,write)]
    fn proposal(tokenId : ContractId,to: Identity, amount: u64, description:str[300]);
    #[storage(read,write)]
    fn vote(transaction : b256, approve : bool);
     #[storage(read,write)]
    fn constructor(threshold:u64);
}

impl MultiSig for Contract {
    #[storage(read,write),payable]
    fn deposit(){
        require(storage.initialized,Error::NotInitialized);
        //TODO definir Errores
        // require(initialized,)
        let sender: Identity = msg_sender().unwrap();
        let sender = match sender{
            Identity::Address(address) =>address.value,
            Identity::ContractId(con) =>con.value,
        };
        if !storage.users.get(sender).unwrap(){
            storage.users.insert(sender,true);
        }
        else {
            storage.totalUsers+=1;
        }
    }
    #[storage(read,write)]
    fn constructor(threshold: u64){
        require(!(storage.initialized),Error::AlreadyInitialized);
        require(threshold<2, Error:: NotValidThreshold);
        storage.initialized = true;
        storage.threshold = threshold;
    }
    #[storage(read,write)]
    fn proposal(tokenId : ContractId,to: Identity, amount: u64, description:str[300] ){
        let sender: Identity = msg_sender().unwrap();
        let sender = match sender{
            Identity::Address(address) =>address.value,
            Identity::ContractId(con) =>con.value,
        };
        //asegurarse que el usuario ha invertido
        require(storage.users.get(sender).unwrap(),Error::UserNotFound);
        let time = timestamp();
        let object = Transaction::new(tokenId,to,amount,time,description,0,0);
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
        //asegurarse que usuario exista
        require(storage.users.get(sender).unwrap(),Error::UserNotFound);
        let mut trans = storage.transactions.get(transaction).unwrap();
        require(trans.time > timestamp(),Error::ProposalFinished);
        if(approve){
            trans.approvals = trans.approvals + 1;
        }
        trans.totalVotes +=1;
        storage.voters.insert((transaction,sender),true);
        // log(storage.voters.len());

        if trans.totalVotes > storage.totalUsers / 10 && trans.approvals >= trans.totalVotes/storage.threshold  {
            log(this_balance(trans.tokenId));
            require(this_balance(trans.tokenId)>=trans.amount,Error::NotEnoughFunds);
            transfer(trans.amount,trans.tokenId,trans.to);
            trans.time = timestamp()
        }
    }

    // fn invertir()
    // {
    //     //require(votacion>=50%)
    //     //require()
    // }
    
}
