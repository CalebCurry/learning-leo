## Aleo APIs and SDK

[SnarkOS](https://github.com/AleoHQ/snarkOS) is the software used to run Aleo nodes. An Aleo node exposes an API to retrieve information about the network from the node.

The hardware requirements are fairly high, so an example node is available at `vm.aleo.org/api/`.

## Example API Usage

To get started, you can make an API request through the browser by visiting a path like:

https://vm.aleo.org/api/testnet3/latest/height

This example will retrieve the current height of the chain.

You can view a list of possible API endpoints in the [API documentation](https://developer.aleo.org/testnet/getting_started/overview).

Another example would be retrieving block information:

https://vm.aleo.org/api/testnet3/block/700

## Node Example

You can build software around this API. I will show a quick example with Node.

`npm install axios`

Start an interactive Node session with `node`.

```
const axios = require('axios');
const heightResponse = await axios.get('https://vm.aleo.org/api/testnet3/latest/height');
heightResponse.data
```

## Rust Example

I used extensions `rust` and `better toml`.

```
cargo new example
cd example
cargo add reqwest
```

```
use reqwest;

fn main() {
    let block = reqwest::blocking::get("https://vm.aleo.org/api/testnet3/latest/height")
    .unwrap().text().unwrap();
    println!("{block:?}");
}
```

Then run with `cargo run`.

## Rust SDK

The Rust SDK wraps this API with easy to use methods.

` cargo add aleo-rust snarkvm-console`

```
use aleo_rust::AleoAPIClient;
use snarkvm_console::network::Testnet3;

fn main() {
    let api_client = AleoAPIClient::<Testnet3>::testnet3();
    let block = api_client.latest_height().unwrap();
    println!("block: {block:?}");
}
```

Let's do some other cool stuff.

## Creating an Account

`cargo add rand`

```
use rand::thread_rng;

fn main() {
    let api_client = AleoAPIClient::<Testnet3>::testnet3();
    let mut rng = thread_rng();
    let private_key = PrivateKey::<Testnet3>::new(&mut rng).unwrap().to_string();
    println!("{private_key:?}");
}
```

## Aleo ProgramManager

`ProgramManager` and `RecordFinder` give us easy ways to create programs on Aleo. These examples are with Rust and then we will see some with WASM.

---

---

---

---

---

---

---

---

---

---

---

---

---

---

---

---

---

---

install rust and wasm-pack
https://rustwasm.github.io/wasm-pack/installer/

> "Rust compiles easily to WebAssembly but creating the glue code necessary to use compiled WebAssembly binaries from other languages such as JavaScript is a challenging task. wasm-bindgen is a tool that simplifies this process by auto-generating JavaScript bindings to Rust code that has been compiled into WebAssembly."

This basically just means a thin JavaScript wrapper to interact with our Rust app.
