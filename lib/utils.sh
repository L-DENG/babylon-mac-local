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
  echo "end init network config..."
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
