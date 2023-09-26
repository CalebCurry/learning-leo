
APPNAME="token_7761"
PRIVATEKEY="APrivateKey1zkp8CJ8Kco3EMJYDcUm1TTGqw9KU9GDxRxKZCHXWnW3tk5c"

RECORD="{
  owner: aleo1c55rzshzjm6xqdaz3xqsd6fj2ysqkhdl8y6xsn29a48vyvgzj58qrg6pwd.private,
  balance: 100u32.private,
  _nonce: 6078705006041847091314745908254701368890593599208630138779354117407843960967group.public
}"

RECORD_FEE="{
  owner: aleo1c55rzshzjm6xqdaz3xqsd6fj2ysqkhdl8y6xsn29a48vyvgzj58qrg6pwd.private,
  microcredits: 95329696u64.private,
  _nonce: 1651644717769509739489059217002418707717751241393400439399336449981599681299group.public
}"

snarkos developer execute "${APPNAME}.aleo" "transfer" "aleo1z40kp2arrupw473024vre435fk7mv6ulerw692qx7908g768zcrszkdc00" "10u32" "${RECORD}" --private-key "${PRIVATEKEY}" --query "https://vm.aleo.org/api" --broadcast "https://vm.aleo.org/api/testnet3/transaction/broadcast" --fee 1000000 --record "${RECORD_FEE}"

