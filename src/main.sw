contract;

abi MultiSig {
    #[payable, storage(read,write)]
    fn deposit();


}

impl MultiSig for Contract {
    #[payable, storage(read,write)]
    fn deposit(){
        
    }
    
}
