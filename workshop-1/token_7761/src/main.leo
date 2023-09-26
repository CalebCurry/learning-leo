// The 'token_7761' program.
program token_7761.aleo {
    record Token {
        owner: address,
        balance: u32,
    }

    // Define a mint transition that takes a balance and returns a token
    transition mint(receiver: address, balance: u32) -> Token {
        assert_eq(self.caller, aleo1c55rzshzjm6xqdaz3xqsd6fj2ysqkhdl8y6xsn29a48vyvgzj58qrg6pwd);
        return Token {
            owner: receiver,
            balance: balance,
        };
    }

    transition transfer(receiver: address, amount: u32, input: Token) -> (Token, Token){
        let balance: u32 = input.balance - amount;
            let recipient: Token = Token {
            owner: receiver,
            balance: amount,
        };

        let sender: Token  = Token {
            owner: self.caller,
            balance
        };

        return (recipient, sender);
    }
}
