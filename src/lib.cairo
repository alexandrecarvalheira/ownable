use starknet::{ContractAddress, get_caller_address};


#[starket::interface]
trait Idata<T> {
    fn get_data(self: @T) -> felt252;
    fn set_data(ref self: T, new_value: felt252);
}

#[starket::interface]
trait OwnableTrait<T> {
    fn transfer_onwership(ref self: T, new_owner: ContractAddress);
    fn owner(self: @T) -> ContractAddress;
}

#[starknet::contract]
mod ownable {
    use starknet::{ContractAddress, get_caller_address};
    use super::Idata;
    use super::OwnableTrait;

    #[storage]
    struct Storage {
        owner: ContractAddress,
        data: felt252,
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        OwnershipTransferred: OwnershipTransferred,
    }

    #[derive(Drop, starknet::Event)]
    struct OwnershipTransferred {
        #[key]
        prev_owner: ContractAddress,
        #[key]
        new_owner: ContractAddress,
    }

    #[constructor]
    fn constructor(ref self: ContractState, owner: ContractAddress) {
        self.owner.write(owner);
    }

    #[external(v0)]
    impl OwnableDataImpl of Idata<ContractState> {
        fn get_data(self: @ContractState) -> felt252 {
            self.data.read()
        }
        fn set_data(ref self: ContractState, new_value: felt252) {
            self.only_owner();
            self.data.write(new_value);
        }
    }

    #[external(v0)]
    impl OwnableTraitImpl of OwnableTrait<ContractState> {
        fn transfer_onwership(ref self: ContractState, new_owner: ContractAddress) {
            self.only_owner();
            let prev_owner = self.owner.read();
            self.owner.write(new_owner);
            self.emit(OwnershipTransferred { prev_owner, new_owner });
        }
        fn owner(self: @ContractState) -> ContractAddress {
            self.owner.read()
        }
    }


    #[generate_trait]
    impl Private of PrivateTrait {
        fn only_owner(self: @ContractState) {
            let caller = get_caller_address();
            assert(caller == self.owner.read(), 'Caller is not owner');
        }
    }
}
