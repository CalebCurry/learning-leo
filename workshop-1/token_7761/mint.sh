
APPNAME="token_7761"
PRIVATEKEY="APrivateKey1zkp8CJ8Kco3EMJYDcUm1TTGqw9KU9GDxRxKZCHXWnW3tk5c"

RECORD="{
  owner: aleo1c55rzshzjm6xqdaz3xqsd6fj2ysqkhdl8y6xsn29a48vyvgzj58qrg6pwd.private,
  microcredits: 96331000u64.private,
  _nonce: 4084247695378709026790799152713310778292025127215315935128674001439542328320group.public
}"

snarkos developer execute "${APPNAME}.aleo" "mint" 100u32 --private-key "${PRIVATEKEY}" --query "https://vm.aleo.org/api" --broadcast "https://vm.aleo.org/api/testnet3/transaction/broadcast" --fee 1000000 --record "${RECORD}"

