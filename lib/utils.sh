#!/bin/bash

export CODE_BASE=/Users/guoshijiang/babylonWorkSpace/babylon-mac-local  # 需要修改成你的 babylon mac local 的地址

export ETC_DIR=/conf

export ABS_ETC_DIR=${CODE_BASE}/${ETC_DIR}


export BITCOIN_NETWORK=regtest
export BITCOIN_RPC_PORT=$(yq eval '.services.bitcoindsim.ports.rpc' ${CODE_BASE}/conf/baseconfig.yaml)
export BITCOIN_DATA=${CODE_BASE}/testnets/bitcoin
export BITCOIN_CONF=${CODE_BASE}/testnets/bitcoin/bitcoin.conf
export RPC_USER=rpcuser
export RPC_PASS=rpcpass
export ZMQ_SEQUENCE_PORT=$(yq eval '.services.bitcoindsim.ports.zmq_sequence_port' ${CODE_BASE}/conf/baseconfig.yaml)
export ZMQ_RAWBLOCK_PORT=$(yq eval '.services.bitcoindsim.ports.zmq_rawblock_port' ${CODE_BASE}/conf/baseconfig.yaml)
export ZMQ_RAWTR_PORT=$(yq eval '.services.bitcoindsim.ports.zmq_rawtr_port' ${CODE_BASE}/conf/baseconfig.yaml)
export RPC_PORT=18443
export RPC_USER=rpcuser
export RPC_PASS=rpcpass
export WALLET_NAME=default
export WALLET_PASS=walletpass
export BTCSTAKER_WALLET_NAME=btcstaker
export BTCSTAKER_WALLET_ADDR_COUNT=3
export GENERATE_INTERVAL_SECS=10

export BABYLON_HOME=${CODE_BASE}/testnets/babylondhome/node1/babylond
export BABYLON_NODE_RPC="http://127.0.0.1:26667"
export RELAYER_CONF_DIR=${CODE_BASE}/testnets/ibcsimbcd/data/relayer
export CONSUMER_CONF=${CODE_BASE}/testnets/ibcsimbcd/data/bcd
export UPDATE_CLIENTS_INTERVAL=20s

export CONSUMER_CHAIN_ID="bcd-test"
export CHAINID="bcd-test"
export CHAINDIR=${CODE_BASE}/testnets/ibcsimbcd/data/bcd
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
export BABYLON_KEY="babylon-key"
export BABYLON_CHAIN_ID="chain-test"
export CONSUMER_KEY="bcd-key"
export CONSUMER_CHAIN_ID="bcd-test"

export SUPERVISORD_INI=${ABS_ETC_DIR}/supervisord/supervisord.ini


function init_config() {
  echo "start init network config..."

  mkdir -p ${CODE_BASE}/testnets/babylondhome

  # 初始化 babylon 节点
  ${CODE_BASE}/babylon/build/babylond testnet init-files --v 2 -o ${CODE_BASE}/testnets/babylondhome \
  --starting-ip-address 127.0.0.1 --keyring-backend=test \
  --chain-id chain-test --epoch-interval 10 \
  --btc-finalization-timeout 2 --btc-confirmation-depth 1 \
  --minimum-gas-prices 0.000006ubbn \
  --btc-base-header 0100000000000000000000000000000000000000000000000000000000000000000000003ba3edfd7a7b12b27ac72c3e67768f617fc81bc3888a51323a9fb8aa4b1e5e4adae5494dffff7f2002000000 \
  --btc-network regtest --additional-sender-account \
  --slashing-pk-script "76a914010101010101010101010101010101010101010188ab" \
  --slashing-rate 0.1 \
  --min-commission-rate 0.05 \
  --covenant-quorum 1 \
  --covenant-pks "2d4ccbe538f846a750d82a77cd742895e51afcf23d86d05004a356b783902748"

  # 创建各个服务的目录
  mkdir -p ${CODE_BASE}/testnets/bitcoin
  mkdir -p ${CODE_BASE}/testnets/bitcoin
  mkdir -p ${CODE_BASE}/testnets/vigilante
  mkdir -p ${CODE_BASE}/testnets/vigilante/config
  mkdir -p ${CODE_BASE}/testnets/btcstaker
  mkdir -p ${CODE_BASE}/testnets/finalityprovider
  mkdir -p ${CODE_BASE}/testnets/consumerfp
  mkdir -p ${CODE_BASE}/testnets/eotsmanager
  mkdir -p ${CODE_BASE}/testnets/consumereotsmanager
  mkdir -p ${CODE_BASE}/testnets/covenantemulator
  mkdir -p ${CODE_BASE}/testnets/logs
  mkdir -p $CHAINDIR/$CHAINID

  # 拷贝文件到相应的目录,reporter, submitter, monitor 和 bstracker 角色
  cp ${CODE_BASE}/conf/vigilante.yml ${CODE_BASE}/testnets/vigilante/vigilante.yml
  cp ${CODE_BASE}/conf/submitter.yml ${CODE_BASE}/testnets/vigilante/submitter.yml
  cp ${CODE_BASE}/conf/monitor.yml ${CODE_BASE}/testnets/vigilante/monitor.yml
  cp ${CODE_BASE}/testnets/babylondhome/node0/babylond/config/genesis.json ${CODE_BASE}/testnets/vigilante/config/
  cp ${CODE_BASE}/conf/bstracker.yml ${CODE_BASE}/testnets/vigilante/bstracker.yml

  # eots
  cp ${CODE_BASE}/conf/eotsd.conf ${CODE_BASE}/testnets/eotsmanager/eotsd.conf
  cp ${CODE_BASE}/conf/consumereotsd.conf ${CODE_BASE}/testnets/consumereotsmanager/consumereotsd.conf

  # fpd
  cp ${CODE_BASE}/conf/fpd.conf ${CODE_BASE}/testnets/finalityprovider/fpd.conf
  cp ${CODE_BASE}/conf/consumerfpd.conf ${CODE_BASE}/testnets/consumerfp/consumerfpd.conf

  # btc staker
  cp ${CODE_BASE}/conf/stakerd.conf ${CODE_BASE}/testnets/btcstaker/stakerd.conf

  # covd
  cp ${CODE_BASE}/conf/covd.conf ${CODE_BASE}/testnets/covenantemulator/covd.conf
  cp -R ${CODE_BASE}/conf/covenant-keyring ${CODE_BASE}/testnets/covenantemulator/keyring-test
  cp -R ${CODE_BASE}/conf/fp-keyring ${CODE_BASE}/testnets/finalityprovider/keyring-test
  cp -R ${CODE_BASE}/conf/fp-keyring ${CODE_BASE}/testnets/consumerfp/keyring-test

  # 复制 wasm 合约
  cp -R  ${CODE_BASE}/babylon-sdk/tests/testdata/babylon_contract.wasm ${CODE_BASE}/testnets/ibcsimbcd/babylon_contract.wasm
  cp -R  ${CODE_BASE}/babylon-sdk/tests/testdata/btc_finality.wasm ${CODE_BASE}/testnets/ibcsimbcd/btc_finality.wasm
  cp -R  ${CODE_BASE}/babylon-sdk/tests/testdata/btc_staking.wasm ${CODE_BASE}/testnets/ibcsimbcd/btc_staking.wasm

  # 修改文件名字
  mv ${CODE_BASE}/testnets/consumereotsmanager/consumereotsd.conf ${CODE_BASE}/testnets/consumereotsmanager/eotsd.conf
  mv ${CODE_BASE}/testnets/consumerfp/consumerfpd.conf ${CODE_BASE}/testnets/consumerfp/fpd.conf

  # 修改目录配置
  echo "Change settings in config files..."
  chmod -R 777 ${CODE_BASE}/testnets
  sed -i '' "s/127.0.0.2:26656/127.0.0.1:26666/g" ${CODE_BASE}/testnets/babylondhome/node0/babylond/config/config.toml
  sed -i '' "s/0.0.0.0:26657/0.0.0.0:26667/g" ${CODE_BASE}/testnets/babylondhome/node1/babylond/config/config.toml
  sed -i '' "s/0.0.0.0:26656/0.0.0.0:26666/g" ${CODE_BASE}/testnets/babylondhome/node1/babylond/config/config.toml
  sed -i '' "s/26660/26670/g" ${CODE_BASE}/testnets/babylondhome/node1/babylond/config/config.toml
  find "${CODE_BASE}/testnets" -type f -name "*.yml" -exec sed -i '' "s/\/Users\/guoshijiang/\/Users\/guoshijiang\/babylonWorkSpace\/babylon-mac-local/g" {} +
  find "${CODE_BASE}/testnets" -type f -name "*.conf" -exec sed -i '' "s/\/Users\/guoshijiang/\/Users\/guoshijiang\/babylonWorkSpace\/babylon-mac-local/g" {} +

  # bitcoin conf
  echo "Start create bitcoin data directory and initialize bitcoin configuration file"
  echo "BITCOIN_NETWORK: $BITCOIN_NETWORK"
  echo "BITCOIN_RPC_PORT: $BITCOIN_RPC_PORT"
  echo "BITCOIN_DATA: $BITCOIN_DATA"
  echo "BITCOIN_CONF: $BITCOIN_CONF"
  if [[ -z "$BITCOIN_NETWORK" ]]; then
    BITCOIN_NETWORK="regtest"
  fi

  if [[ -z "$BITCOIN_RPC_PORT" ]]; then
    BITCOIN_RPC_PORT="18443"
  fi

  if [[ "$BITCOIN_NETWORK" != "regtest" && "$BITCOIN_NETWORK" != "signet" ]]; then
    echo "Unsupported network: $BITCOIN_NETWORK"
    exit 1
  fi
mkdir -p "$BITCOIN_DATA"
cat <<EOF > "$BITCOIN_CONF"
# Enable ${BITCOIN_NETWORK} mode.
${BITCOIN_NETWORK}=1

# Accept command line and JSON-RPC commands
server=1

# RPC user and password.
rpcuser=$RPC_USER
rpcpassword=$RPC_PASS
rpcbind=127.0.0.1
rpcallowip=127.0.0.1

# ZMQ notification options.
# Enable publish hash block and tx sequence
zmqpubsequence=tcp://*:$ZMQ_SEQUENCE_PORT
# Enable publishing of raw block hex.
zmqpubrawblock=tcp://*:$ZMQ_RAWBLOCK_PORT
# Enable publishing of raw transaction.
zmqpubrawtx=tcp://*:$ZMQ_RAWTR_PORT

debug=1
txindex=1
deprecatedrpc=create_bdb

# Fallback fee
fallbackfee=0.00001

# Allow all IPs to access the RPC server.
[${BITCOIN_NETWORK}]
rpcbind=0.0.0.0
rpcallowip=0.0.0.0/0
EOF
  echo "End create bitcoin data directory and initialize bitcoin configuration file"

  echo "Start ibcsim bcd conf"

  if ! command -v $BINARY &>/dev/null; then
  	echo "$BINARY could not be found"
  	exit
  fi

  echo "Creating $BINARY instance: home=$CHAINDIR | chain-id=$CHAINID | p2p=:$P2PPORT | rpc=:$RPCPORT | profiling=:$PROFPORT | grpc=:$GRPCPORT"

  # Build genesis file incl account for passed address
  coins="100000000000$DENOM,100000000000$BASEDENOM"
  delegate="100000000000$DENOM"

  $BINARY --home $CHAINDIR/$CHAINID --chain-id $CHAINID init $CHAINID
  echo "Finish step 1"
  sleep 1
  $BINARY --home $CHAINDIR/$CHAINID keys add validator $KEYRING --output json > $CHAINDIR/$CHAINID/validator_seed.json 2>&1

  echo "Finish step 2"
  sleep 1
  $BINARY --home $CHAINDIR/$CHAINID keys add user $KEYRING --output json  > $CHAINDIR/$CHAINID/key_seed.json 2>&1

  echo "Finish step 3"
  sleep 1
  $BINARY --home $CHAINDIR/$CHAINID genesis add-genesis-account $($BINARY --home $CHAINDIR/$CHAINID keys $KEYRING show user -a) $coins

  echo "Finish step 4"
  sleep 1
  $BINARY --home $CHAINDIR/$CHAINID genesis add-genesis-account $($BINARY --home $CHAINDIR/$CHAINID keys $KEYRING show validator -a) $coins

  echo "Finish step 5"
  sleep 1
  $BINARY --home $CHAINDIR/$CHAINID genesis gentx validator $delegate $KEYRING --chain-id $CHAINID

  echo "Finish step 6"
  sleep 1
  $BINARY --home $CHAINDIR/$CHAINID genesis collect-gentxs

  echo "Finish step 7"
  sleep 1
  # Set proper defaults and change ports
  echo "Change settings in config.toml and genesis.json files..."
  sed -i '' "s/127.0.0.1:26657/0.0.0.0:$RPCPORT/g" ${CODE_BASE}/testnets/ibcsimbcd/data/bcd/bcd-test/config/config.toml
  sed -i '' "s/0.0.0.0:26656/0.0.0.0:$P2PPORT/g" ${CODE_BASE}/testnets/ibcsimbcd/data/bcd/bcd-test/config/config.toml
  sed -i '' "s/localhost:6060/localhost:$PROFPORT/g" ${CODE_BASE}/testnets/ibcsimbcd/data/bcd/bcd-test/config/config.toml
  sed -i '' "s/timeout_commit = \"5s\"/timeout_commit = \"1s\"/g" ${CODE_BASE}/testnets/ibcsimbcd/data/bcd/bcd-test/config/config.toml
  sed -i '' "s/max_body_bytes = 1000000/max_body_bytes = 1000000000/g" ${CODE_BASE}/testnets/ibcsimbcd/data/bcd/bcd-test/config/config.toml
  sed -i '' "s/minimum-gas-prices = \"\"/minimum-gas-prices = \"0.00001ustake\"/g" ${CODE_BASE}/testnets/ibcsimbcd/data/bcd/bcd-test/config/app.toml
  sed -i '' "s/timeout_propose = \"3s\"/timeout_propose = \"1s\"/g" ${CODE_BASE}/testnets/ibcsimbcd/data/bcd/bcd-test/config/config.toml
  sed -i '' "s/index_all_keys = false/index_all_keys = true/g" ${CODE_BASE}/testnets/ibcsimbcd/data/bcd/bcd-test/config/config.toml
  sed -i '' "s/0.0.0.0:1317/0.0.0.0:1318/g" ${CODE_BASE}/testnets/ibcsimbcd/data/bcd/bcd-test/config/app.toml # ensure port is not conflicted with Babylon
  sed -i '' "s/\"bond_denom\": \"stake\"/\"bond_denom\": \"$DENOM\"/g" ${CODE_BASE}/testnets/ibcsimbcd/data/bcd/bcd-test/config/genesis.json

  echo "sed all file successfully"

  # update contract address in genesis
  babylonContractAddr=bbnc14hj2tavq8fpesdwxxcu44rty3hh90vhujrvcmstl4zr3txmfvw9syx25zf
  btcStakingContractAddr=bbnc1nc5tatafv6eyq7llkr2gv50ff9e22mnf70qgjlv737ktmt4eswrqgn0kq0

  sed -i '' "s/\"babylon_contract_address\": \"\"/\"babylon_contract_address\": \"$babylonContractAddr\"/g" "$CHAINDIR/$CHAINID/config/genesis.json"
  sed -i '' "s/\"btc_staking_contract_address\": \"\"/\"btc_staking_contract_address\": \"$btcStakingContractAddr\"/g" "$CHAINDIR/$CHAINID/config/genesis.json"
  echo "End ibcsim bcd conf"

  echo "end init network config..."
}


function init_relayer() {
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
            rpc-addr: http://localhost:36657
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
  echo "CONSUMER_MEMO is ${CONSUMER_MEMO}"
  rly --home $RELAYER_CONF_DIR keys restore bcd $CONSUMER_KEY "$CONSUMER_MEMO"

  echo "Inserting the babylond key"
  BABYLON_MEMO=$(cat $BABYLON_HOME/key_seed.json | jq .secret | tr -d '"')
  echo "BABYLON_MEMO is ${BABYLON_MEMO}"
  rly --home $RELAYER_CONF_DIR keys restore babylon $BABYLON_KEY "$BABYLON_MEMO"

  sleep 10
}

function start_relayer() {
    CONTRACT_ADDRESS=$(bcd query wasm list-contract-by-code 1 | grep bbnc | cut -d' ' -f2)
    CONTRACT_PORT="wasm.$CONTRACT_ADDRESS"
    echo "bcd started. Status of bcd node:"
    bcd status
    echo "Contract port: $CONTRACT_PORT"

    echo "Creating an IBC light clients, connection, and channel between the two CZs"
    rly --home $RELAYER_CONF_DIR tx link bcd --src-port zoneconcierge --dst-port $CONTRACT_PORT --order ordered --version zoneconcierge-1
    echo "Created IBC channel successfully!"

    sleep 10

    echo "Start the IBC relayer"
    rly --home $RELAYER_CONF_DIR start bcd --debug-addr "" --flush-interval 30s
}


function deploy_babylon_contract() {
    # upload contract code
    echo "Uploading babylon contract code $BABYLON_CONTRACT_CODE_DIR..."
    $BINARY --home $CHAINDIR/$CHAINID tx wasm store "$BABYLON_CONTRACT_CODE_DIR" $KEYRING --from user --chain-id $CHAINID --gas 20000000000 --gas-prices 0.01ustake --node http://localhost:$RPCPORT -y
    sleep 10

    # upload contract code
    echo "Uploading btcstaking contract code $BTCSTAKING_CONTRACT_CODE_DIR..."
    $BINARY --home $CHAINDIR/$CHAINID tx wasm store "$BTCSTAKING_CONTRACT_CODE_DIR" $KEYRING --from user --chain-id $CHAINID --gas 20000000000 --gas-prices 0.01ustake --node http://localhost:$RPCPORT -y
    sleep 10

    # Echo the command with expanded variables
    echo "Instantiating contract with code $BABYLON_CONTRACT_CODE_DIR..."
    $BINARY --home $CHAINDIR/$CHAINID tx wasm instantiate 1 "$INSTANTIATING_CFG" --admin=$(bcd --home $CHAINDIR/$CHAINID keys show user --keyring-backend test -a) --label "v0.0.1" $KEYRING --from user --chain-id $CHAINID --gas 20000000000 --gas-prices 0.001ustake --node http://localhost:$RPCPORT -y --amount 100000stake
}

function bitcoin_init() {
  if [[ "$BITCOIN_NETWORK" == "regtest" ]]; then
    echo "Creating a wallet..."
    bitcoin-cli -${BITCOIN_NETWORK} -rpcuser="$RPC_USER" -rpcpassword="$RPC_PASS" createwallet "$WALLET_NAME" false false "$WALLET_PASS" false false

    echo "Creating a wallet for btcstaker..."
    bitcoin-cli -${BITCOIN_NETWORK} -rpcuser="$RPC_USER" -rpcpassword="$RPC_PASS" createwallet "$BTCSTAKER_WALLET_NAME" false false "$WALLET_PASS" false false

    echo "Generating 110 blocks for the first coinbases to mature..."
    bitcoin-cli -regtest -rpcuser="$RPC_USER" -rpcpassword="$RPC_PASS" -rpcwallet="$WALLET_NAME" -generate 110

    echo "Creating $BTCSTAKER_WALLET_ADDR_COUNT addresses for btcstaker..."
    BTCSTAKER_ADDRS=()
    for i in `seq 0 1 $((BTCSTAKER_WALLET_ADDR_COUNT - 1))`
    do
      BTCSTAKER_ADDRS+=($(bitcoin-cli -regtest -rpcuser="$RPC_USER" -rpcpassword="$RPC_PASS" -rpcwallet="$BTCSTAKER_WALLET_NAME" getnewaddress))
    done

    # Generate a UTXO for each btc-staker address
    bitcoin-cli -regtest -rpcuser="$RPC_USER" -rpcpassword="$RPC_PASS" -rpcwallet="$WALLET_NAME" walletpassphrase "$WALLET_PASS" 1
    for addr in "${BTCSTAKER_ADDRS[@]}"
    do
      bitcoin-cli -regtest -rpcuser="$RPC_USER" -rpcpassword="$RPC_PASS" -rpcwallet="$WALLET_NAME" sendtoaddress "$addr" 10
    done

    # Allow some time for the wallet to catch up.
    sleep 5

    echo "Checking balance..."
    bitcoin-cli -regtest -rpcuser="$RPC_USER" -rpcpassword="$RPC_PASS" -rpcwallet="$WALLET_NAME" getbalance

    echo "Generating a block every ${GENERATE_INTERVAL_SECS} seconds."
    echo "Press [CTRL+C] to stop..."
    while true
    do
      bitcoin-cli -regtest -rpcuser="$RPC_USER" -rpcpassword="$RPC_PASS" -rpcwallet="$WALLET_NAME" -generate 1
      if [[ "$GENERATE_STAKER_WALLET" == "true" ]]; then
        echo "Periodically send funds to btcstaker addresses..."
        bitcoin-cli -regtest -rpcuser="$RPC_USER" -rpcpassword="$RPC_PASS" -rpcwallet="$WALLET_NAME" walletpassphrase "$WALLET_PASS" 10
        for addr in "${BTCSTAKER_ADDRS[@]}"
        do
          bitcoin-cli -regtest -rpcuser="$RPC_USER" -rpcpassword="$RPC_PASS" -rpcwallet="$WALLET_NAME" sendtoaddress "$addr" 10
        done
      fi
      sleep "${GENERATE_INTERVAL_SECS}"
    done
  elif [[ "$BITCOIN_NETWORK" == "signet" ]]; then
    # Check if the wallet database already exists.
    if [[ -d "$BITCOIN_DATA"/signet/wallets/"$BTCSTAKER_WALLET_NAME" ]]; then
      echo "Wallet already exists and removing it..."
      rm -rf "$BITCOIN_DATA"/signet/wallets/"$BTCSTAKER_WALLET_NAME"
    fi
    # Keep the container running
    echo "Bitcoind is running. Press CTRL+C to stop..."
    tail -f /dev/null
  fi
}
