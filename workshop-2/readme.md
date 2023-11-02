## Learning Leo

This workshop will focus on the leo programming language.
Leo is a high level language that is compiled to Aleo instructions.

You can get your leo version with:

```leo --version```

You can update to the latest with:

```leo update```

You can start with an example project:

```
leo example token
cd token
```


The leo code will be found in `src/main.leo`. This is where you write your code. You will also find a `build/main.aleo` which shows the compiled leo code. You are not meant to edit the build files directly, so make sure you write your code in `main.leo`.

Everything is surrounded in a `program`. This is the name of your program and will need to be a unique value on-chain. 

```
program token.aleo {
    //...leo code
}
```

Because this must be unique, it is likely the case you will not be able to deploy with a program called `token`. 

# Private Data

Let's first talk about what makes Aleo special: the ability to make data private. 

## Records

The fundamental data structure to store private data is a `record`. You will see it defined as so:

```    
record token {
    owner: address,
    amount: u64,
}
```

## Private Mints

A mint in this context is creating new tokens. We do this within a `transition`. A transition is a function describing a change from one state to another and is how you describe functionality within the context of Aleo. 

```
transition mint_private(receiver: address, amount: u64) -> token {
    return token {
        owner: receiver,
        amount: amount,
    };
}

```

This is a function that has two arguments, the receiver and the amount to be minted. It returns a `token` record, which is created inside of the transition. 

We can transfer funds privately with the private transfer transition:

```
transition transfer_private(sender: token, receiver: address, amount: u64) -> (token, token) {
    let difference: u64 = sender.amount - amount;

    let remaining: token = token {
        owner: sender.owner,
        amount: difference,
    };

    let transferred: token = token {
        owner: receiver,
        amount: amount,
    };

    return (remaining, transferred);
}
```

This returns two records, the remainder sent back to the caller and the new record being sent to the receiver.

> A transition will take records as input to be destroyed and give records as output being created. Consider the case where you have 100 of a custom token and transfer 10 to someone, you will receive a change record of 90 and the recipient will receive a record of 10. 

# Public State
We also have the ability to store data publicly. This is not done with records (which are private), but mappings. This is a key-value pair between addresses and values.

The `address` type is built-in with Aleo, as is the numeric `u64`, so a public account balance is defined for all users like so:

```
mapping account: address => u64;
```
This is fundamentally different than a record which is owned by an individual. Instead, this mapping is shared for all addresses owning public tokens. 

Public transitions will be paired with a `finalize` named the same thing as the `transition`. 

## Public Mints

here is an example of a public mint:

```
transition transfer_public(public receiver: address, public amount: u64) {
    return then finalize(self.caller, receiver, amount);
}

finalize transfer_public(public sender: address, public receiver: address, public amount: u64) {

    let sender_amount: u64 = Mapping::get_or_use(account, sender, 0u64);
    Mapping::set(account, sender, sender_amount - amount);

    let receiver_amount: u64 = Mapping::get_or_use(account, receiver, 0u64);
    Mapping::set(account, receiver, receiver_amount + amount);
}
```
Finalize functions are executed by the nodes of the network.

In this case, the transition only invokes the finalize which subtracts `amount` from the sender and adds it to the receiver.

As interactions can involve both private and public state, the combination of a transition and a finalize function allows us to do things like transfer from private to public.

```
transition transfer_private_to_public(sender: token, public receiver: address, public amount: u64) -> token {
    let difference: u64 = sender.amount - amount;

    let remaining: token = token {
        owner: sender.owner,
        amount: difference,
    };

    return remaining then finalize(receiver, amount);
}

finalize transfer_private_to_public(public receiver: address, public amount: u64) {
    let current_amount: u64 = Mapping::get_or_use(account, receiver, 0u64);
    Mapping::set(account, receiver, current_amount + amount);
}
```
In the above example we calculate the remainder (change) privately within the transition, but increase the receivers balance publicly within the `finalize`. 
The finalize will not be executed if the zero knowledge proof of the `transition` fails to validate. Additionally, any change of state will be reverted if there are any failures during `finalize`. 