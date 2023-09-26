
APPNAME="token_7761"
PRIVATEKEY="APrivateKey1zkp8CJ8Kco3EMJYDcUm1TTGqw9KU9GDxRxKZCHXWnW3tk5c"

RECORD="{
  owner: aleo1c55rzshzjm6xqdaz3xqsd6fj2ysqkhdl8y6xsn29a48vyvgzj58qrg6pwd.private,
  microcredits: 94327524u64.private,
  _nonce: 1671605428148761619686647832539490227087784791641636473048803152082935183402group.public
}"

snarkos developer deploy "${APPNAME}.aleo" --private-key "${PRIVATEKEY}" --query "https://vm.aleo.org/api" --path "./build/" --broadcast "https://vm.aleo.org/api/testnet3/transaction/broadcast" --fee 1000000 --record "${RECORD}"

