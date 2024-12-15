#!/usr/bin/env sh

export CODE_BASE=/Users/guoshijiang/babylonWorkSpace/babylon-mac-local
export BABYLON_HOME=${CODE_BASE}/testnets/babylondhome/node1/babylond
export BABYLON_NODE_RPC="http://127.0.0.1:26657"
export RELAYER_CONF_DIR=${CODE_BASE}/testnetstestnets/ibcsimbcd/data
export CONSUMER_CONF=${CODE_BASE}/testnets/ibcsimbcd/bcddata
export UPDATE_CLIENTS_INTERVAL=20s

export CONSUMER_CHAIN_ID="bcd-test"
export CHAINID="bcd-test"
export CHAINDIR=${CODE_BASE}/testnets/ibcsimbcd/bcddata
export RPCPORT=$(yq eval '.services.ibcsim-bcd.ports.rpc' ${CODE_BASE}/conf/baseconfig.yaml)
export P2PPORT=$(yq eval '.services.ibcsim-bcd.ports.p2p' ${CODE_BASE}/conf/baseconfig.yaml)
export PROFPORT=$(yq eval '.services.ibcsim-bcd.ports.prof' ${CODE_BASE}/conf/baseconfig.yaml)
export GRPCPORT=$(yq eval '.services.ibcsim-bcd.ports.grpc' ${CODE_BASE}/conf/baseconfig.yaml)
export BABYLON_CONTRACT_CODE_DIR=${CODE_BASE}/babylon-sdk/tests/testdata/babylon_contract.wasm
export BTCSTAKING_CONTRACT_CODE_DIR=${CODE_BASE}/babylon-sdk/tests/testdata/btc_staking.wasm
export INSTANTIATING_CFG='{"network": "regtest", "babylon_tag": "01020304", "btc_confirmation_depth": 1, "checkpoint_finalization_timeout": 2, "notify_cosmos_zone": false,"btc_staking_code_id": 2,"consumer_name": "Test Consumer","consumer_description": "Test Consumer Description"}'
export BINARY=bcd
export DENOM=stake
export BASEDENOM=ustake
export KEYRING=--keyring-backend="test"
export SILENT=1


# 0. Define configuration
BABYLON_KEY="babylon-key"
BABYLON_CHAIN_ID="chain-test"
CONSUMER_KEY="bcd-key"
CONSUMER_CHAIN_ID="bcd-test"

# 1. Create a bcd testnet with Babylon contract
/Users/guoshijiang/babylonWorkSpace/babylon-mac-local/lib/ibcsim-bcd/setup-bcd.sh $CONSUMER_CHAIN_ID $CONSUMER_CONF 36657 36656 16060 19090 ./babylon_contract.wasm ./btc_staking.wasm '{
    "network": "regtest",
    "babylon_tag": "01020304",
    "btc_confirmation_depth": 1,
    "checkpoint_finalization_timeout": 2,
    "notify_cosmos_zone": false,
    "btc_staking_code_id": 2,
    "consumer_name": "Test Consumer",
    "consumer_description": "Test Consumer Description"
}'

sleep 10

CONTRACT_ADDRESS=$(bcd query wasm list-contract-by-code 1 | grep bbnc | cut -d' ' -f2)
CONTRACT_PORT="wasm.$CONTRACT_ADDRESS"
echo "bcd started. Status of bcd node:"
bcd status
echo "Contract port: $CONTRACT_PORT"

# 2. Set up the relayer
mkdir -p $RELAYER_CONF_DIR
rly --home $RELAYER_CONF_DIR config init
RELAYER_CONF=$RELAYER_CONF_DIR/config/config.yaml

cat <<EOT >$RELAYER_CONF
global:
    api-listen-addr: :5183
    timeout: 20s
    memo: ""
    light-cache-size: 10
chains:
    babylon:
        type: cosmos
        value:
            key: $BABYLON_KEY
            chain-id: $BABYLON_CHAIN_ID
            rpc-addr: $BABYLON_NODE_RPC
            account-prefix: bbn
            keyring-backend: test
            gas-adjustment: 1.5
            gas-prices: 0.002ubbn
            min-gas-amount: 1
            debug: true
            timeout: 10s
            output-format: json
            sign-mode: direct
            extra-codecs: []
    bcd:
        type: cosmos
        value:
            key: $CONSUMER_KEY
            chain-id: $CONSUMER_CHAIN_ID
            rpc-addr: http://localhost:26657
            account-prefix: bbnc
            keyring-backend: test
            gas-adjustment: 1.5
            gas-prices: 0.002ustake
            min-gas-amount: 1
            debug: true
            timeout: 10s
            output-format: json
            sign-mode: direct
            extra-codecs: []     
paths:
    bcd:
        src:
            chain-id: $BABYLON_CHAIN_ID
        dst:
            chain-id: $CONSUMER_CHAIN_ID
EOT

echo "Inserting the consumer key"
CONSUMER_MEMO=$(cat $CONSUMER_CONF/$CONSUMER_CHAIN_ID/key_seed.json | jq .mnemonic | tr -d '"')
rly --home $RELAYER_CONF_DIR keys restore bcd $CONSUMER_KEY "$CONSUMER_MEMO"

echo "Inserting the babylond key"
BABYLON_MEMO=$(cat $BABYLON_HOME/key_seed.json | jq .secret | tr -d '"')
rly --home $RELAYER_CONF_DIR keys restore babylon $BABYLON_KEY "$BABYLON_MEMO"

sleep 10

# 3. Start relayer
echo "Creating an IBC light clients, connection, and channel between the two CZs"
rly --home $RELAYER_CONF_DIR tx link bcd --src-port zoneconcierge --dst-port $CONTRACT_PORT --order ordered --version zoneconcierge-1
echo "Created IBC channel successfully!"

sleep 10

echo "Start the IBC relayer"
rly --home $RELAYER_CONF_DIR start bcd --debug-addr "" --flush-interval 30s
