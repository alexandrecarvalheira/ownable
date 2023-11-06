#[starket::interface]
trait Idata<T> {
    fn get_data(self: @T) -> felt252;
    fn set_data(ref self: T, new_value: felt252);
}

#[starknet::contract]
mod ownable {
    use starknet::{ContractAddress, get_caller_address};
    use super::Idata;

    #[storage]
    struct Storage {
        owner: ContractAddress,
        data: felt252,
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
    #[generate_trait]
    impl Private of PrivateTrait {
        fn only_owner(self: @ContractState) {
            let caller = get_caller_address();
            assert(caller == self.owner.read(), 'Caller is not owner');
        }
    }
}
