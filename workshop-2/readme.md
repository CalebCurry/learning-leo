## Learning Leo

This workshop will focus on the leo programming language.
Leo is a high level language that is compiled to Aleo instructions, which is serialized to AVM bytecode. This bytecode is deployed on chain and is visible by anyone. AVM is executed by the Aleo virtual machine by users of the smart contract. 

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

We are using `Mapping::get_or_use` which takes 3 arguments. The first is the mapping, the second is the key to search for, and the third is a default value if not found. 

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

## Trying Our Example

We can execute this locally by first acquiring a wallet address. You can do this by retrieving it from the `.env` file or generating a new one with 

```
leo account new
```

Now, mint a record:

```
leo run mint_private aleo104ekeaps2995cqyqt9hgjlnpgnxtxuc2elcj6uchpnw0gsvv3vpqd45z4f 10u64
```

We can mint publicly with:

```
leo run mint_public aleo104ekeaps2995cqyqt9hgjlnpgnxtxuc2elcj6uchpnw0gsvv3vpqd45z4f 10u64
```

## Structs and Records

Both structs and records allow you to define your own data structure. The primary difference in purpose between them is that records are stored privately on chain. If you need to group data together for organization in your code, you can use a struct. If instead you need to store private data on-chain, use a record. 

The syntax is fairly similar, too, but an additional requirement is that **a `record` must have an owner**. 

An example of a struct can be seen in the [tic-tac-toe example](https://github.com/AleoHQ/workshop/blob/f1738a733bad682a92d3b65727bde0537ecc7585/tictactoe/src/main.leo#L9), where a struct is used to group data.

Let's go through this example by creating a new example project. Outside of our current project we will create a new project:

```
leo example tictactoe
cd tictactoe
. ./run.sh 
```

This will go through an example step by step of this game. 

## Transitions and Functions

We have seen transitions already which describe the external interface of your contract. These can take records as input and give records as outputs. When end-users interact with the deployed contract it will be by invoking various transitions. 

An example transition function in the tic tac toe example is  `make_move`:

```
transition make_move(player: u8, row: u8, col: u8, board: Board) -> (Board, u8) 
```
This takes the player (`1` or `2`), the row and column, as well as the current board. This will return a new board and a number indicating who won (0 if no one yet).

Functions work as they would in other programming languages. They identify some section of code by name and allow for parameters and return data (although they cannot return records). This can be useful for organizing your program. 

In this example, we invoke a function `check_for_win`:

```
function check_for_win(b: Board, p: u8) -> bool 
```

This takes a board and a player. It returns true or false if the player has won. This function returns a boolean, but you can return almost any type... The only thing is that you cannot return a record from a function. As a record is state stored on chain, you will use a transition function if you need to return a record. 

Structs are not the choice for storing state onchain, rather you should use a record as seen in the [battleship example](https://github.com/AleoHQ/workshop/blob/master/battleship/imports/board.leo#L10C22-L10C22) which also has a board but maintains the board state in a record. The tic tac toe example acts as a good first step to understanding Leo, but lacks features introduced in the battleship example. 

## Arrays

Arrays are available in Leo to allow you to easily store multiple values. We can learn the arry syntax while rewriting the tic tac toe example. 

```
struct Board {
    data: [[u8; 3]; 3]
}
```

This defines a board structure containing a 3x3 array. 

We can craft this within a call to `new`:

```
transition new() -> Board {
    return Board {
        data: 
        [[ 0u8, 0u8, 0u8 ],
        [ 0u8, 0u8, 0u8 ],
        [ 0u8, 0u8, 0u8 ]],
    };
}
```
Here is the starter code for the whole project using an array. Arrays are static in both size and cotent, so we have to do some extra work to use them as seen in `make_move`: 

```
program tictactoe.aleo {

 struct Board {
       data: [[u8; 3]; 3]
    }

    // Returns an empty board.
    transition new() -> Board {
        return Board {
            data: 
            [[ 0u8, 0u8, 0u8 ],
            [ 0u8, 0u8, 0u8 ],
            [ 0u8, 0u8, 0u8 ]],
        };
    }

function check_for_win(board: Board, p: u8) -> bool {
    let b: [[u8; 3]; 3] = board.data;
    return (b[0u8][0u8] == p && b[0u8][1u8] == p && b[0u8][2u8] == p) || // row 1
           (b[1u8][0u8] == p && b[1u8][1u8] == p && b[1u8][2u8] == p) || // row 2
           (b[2u8][0u8] == p && b[2u8][1u8] == p && b[2u8][2u8] == p) || // row 3
           (b[0u8][0u8] == p && b[1u8][0u8] == p && b[2u8][0u8] == p) || // column 1
           (b[0u8][1u8] == p && b[1u8][1u8] == p && b[2u8][1u8] == p) || // column 2
           (b[0u8][2u8] == p && b[1u8][2u8] == p && b[2u8][2u8] == p) || // column 3
           (b[0u8][0u8] == p && b[1u8][1u8] == p && b[2u8][2u8] == p) || // diagonal
           (b[0u8][2u8] == p && b[1u8][1u8] == p && b[2u8][0u8] == p);   // other diagonal
}
 
    //leo run make_move 1u8 2u8 3u8 " { data: [[1u8, 0u8, 0u8],[2u8, 2u8, 0u8],[1u8, 0u8, 0u8]]}"
    transition make_move(player: u8, row: u8, col: u8, board: Board) -> (Board, u8){   
        //Check that inputs are valid.
        assert(player == 1u8 || player == 2u8);
        assert(1u8 <= row && row <= 3u8);
        assert(1u8 <= col && col <= 3u8);
        let b: [[u8; 3]; 3] = board.data;
    
        let r1c1: u8 = b[0u8][0u8];
        let r1c2: u8 = b[0u8][1u8];
        let r1c3: u8 = b[0u8][2u8];
        let r2c1: u8 = b[1u8][0u8];
        let r2c2: u8 = b[1u8][1u8];
        let r2c3: u8 = b[1u8][2u8];
        let r3c1: u8 = b[2u8][0u8];
        let r3c2: u8 = b[2u8][1u8];
        let r3c3: u8 = b[2u8][2u8];

        if row == 1u8 && col == 1u8 && r1c1 == 0u8 {
            r1c1 = player;
        } else if row == 1u8 && col == 2u8 && r1c2 == 0u8  {
            r1c2 = player;
        } else if row == 1u8 && col == 3u8 && r1c3 == 0u8 {
            r1c3 = player;
        } else if row == 2u8 && col == 1u8 && r2c1 == 0u8 {
            r2c1 = player;
        } else if row == 2u8 && col == 2u8 && r2c2 == 0u8 {
            r2c2 = player;
        } else if row == 2u8 && col == 3u8 && r2c3 == 0u8 {
            r2c3 = player;
        } else if row == 3u8 && col == 1u8 && r3c1 == 0u8 {
            r3c1 = player;
        } else if row == 3u8 && col == 2u8 && r3c2 == 0u8 {
            r3c2 = player;
        } else if row == 3u8 && col == 3u8 && r3c3 == 0u8 {
            r3c3 = player;
        }

        let updated: Board = Board { data: 
        [[ r1c1, r1c2, r1c3 ],
        [ r2c1, r2c2, r2c3 ],
        [ r3c1, r3c2, r3c3 ],
        ]};

     // Check if the game is over.
        if check_for_win(updated, 1u8) {
            return (updated, 1u8);
        } else if check_for_win(updated, 2u8) {
            return (updated, 2u8);
        } else {
            return (updated, 0u8);
        }
    }
}
```

An example call would be:

```
leo run make_move 1u8 2u8 3u8 "{ data: [[1u8, 0u8, 0u8],[2u8, 2u8, 0u8],[1u8, 0u8, 0u8]]}"
```    