#!/bin/bash

export CODE_BASE=/Users/guoshijiang/babylonWorkSpace/babylon-mac-local  # 需要修改成你的 babylon mac local 的地址
export ETC_DIR=/conf

export ABS_ETC_DIR=${CODE_BASE}/${ETC_DIR}

export BITCOIN_NETWORK=regtest
export BITCOIN_RPC_PORT=18443
export BITCOIN_DATA=${CODE_BASE}/testnets/bitcoin
export BITCOIN_CONF=${CODE_BASE}/testnets/bitcoin/bitcoin.conf
export RPC_USER=rpcuser
export RPC_PASS=rpcpass
export ZMQ_SEQUENCE_PORT=29000
export ZMQ_RAWBLOCK_PORT=29001
export ZMQ_RAWTR_PORT=29002
export WALLET_NAME=staker
export WALLET_PASS=123456
export BTCSTAKER_WALLET_NAME=btcstaker

export BABYLON_HOME=${CODE_BASE}/testnets/babylondhome/node1/babylond
export BABYLON_NODE_RPC="http://127.0.0.1:26657"
export RELAYER_CONF_DIR=${CODE_BASE}/testnetstestnets/ibcsimbcd/data
export CONSUMER_CONF=${CODE_BASE}/testnets/ibcsimbcd/bcddata
export UPDATE_CLIENTS_INTERVAL=20s

export CONSUMER_CHAIN_ID="bcd-test"
export CHAINID="bcd-test"
export CHAINDIR=${CODE_BASE}/testnets/ibcsimbcd/bcddata
export RPCPORT=26657
export P2PPORT=26656
export PROFPORT=6060
export GRPCPORT=9090
export BABYLON_CONTRACT_CODE_DIR=/Users/guoshijiang/babylonWorkSpace/babylon-integration-deployment/relayers/babylon-sdk/tests/testdata/babylon_contract.wasm
export BTCSTAKING_CONTRACT_CODE_DIR=/Users/guoshijiang/babylonWorkSpace/babylon-integration-deployment/relayers/babylon-sdk/tests/testdata/btc_staking.wasm
export INSTANTIATING_CFG='{"network": "regtest", "babylon_tag": "01020304", "btc_confirmation_depth": 1, "checkpoint_finalization_timeout": 2, "notify_cosmos_zone": false,"btc_staking_code_id": 2,"consumer_name": "Test Consumer","consumer_description": "Test Consumer Description"}'
export BINARY=bcd
export DENOM=stake
export BASEDENOM=ustake
export KEYRING=--keyring-backend="test"
export SILENT=1


export SUPERVISORD_INI=${ABS_ETC_DIR}/supervisord/supervisord.ini


function go_version_select() {
    echo "go version select..."
    gvm use go1.23.3
    echo "go version select end..."
}

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
  mkdir -p ${CODE_BASE}/testnets/btcstaker
  mkdir -p ${CODE_BASE}/testnets/finalityprovider
  mkdir -p ${CODE_BASE}/testnets/consumerfp
  mkdir -p ${CODE_BASE}/testnets/eotsmanager
  mkdir -p ${CODE_BASE}/testnets/consumereotsmanager
  mkdir -p ${CODE_BASE}/testnets/covenantemulator

  # 拷贝文件到相应的目录
  # reporter, submitter, monitor 和 bstracker 角色
  cp ${CODE_BASE}/conf/vigilante.yml ${CODE_BASE}/testnets/vigilante/vigilante.yml
  cp ${CODE_BASE}/conf/submitter.yml ${CODE_BASE}/testnets/vigilante/submitter.yml
  cp ${CODE_BASE}/conf/monitor.yml ${CODE_BASE}/testnets/vigilante/monitor.yml
  cp ${CODE_BASE}/conf/bstracker.yml ${CODE_BASE}/testnets/vigilante/bstracker.yml

  # bitcoin
  cp ${CODE_BASE}/conf/bitcoin.conf ${CODE_BASE}/testnets/bitcoin/bitcoin.conf

  # eots
  cp ${CODE_BASE}/conf/eotsd.conf ${CODE_BASE}/testnets/eotsmanager/eotsd.conf
  cp ${CODE_BASE}/conf/consumereotsd.conf ${CODE_BASE}/testnets/consumereotsmanager/consumereotsd.conf

  # fp
  cp ${CODE_BASE}/conf/fpd.conf ${CODE_BASE}/testnets/finalityprovider/fpd.conf
  cp ${CODE_BASE}/conf/consumerfpd.conf ${CODE_BASE}/testnets/consumerfp/consumerfpd.conf

  # btc staker
  cp ${CODE_BASE}/conf/stakerd.conf ${CODE_BASE}/testnets/btcstaker/stakerd.conf

  # covd
  cp ${CODE_BASE}/conf/covd.conf ${CODE_BASE}/testnets/covenantemulator/covd.conf
  cp -R ${CODE_BASE}/conf/covenant-keyring ${CODE_BASE}/testnets/covenantemulator/keyring-test


  # 修改目录配置
  echo "Change settings in config files..."
  chmod -R 777 ${CODE_BASE}/testnets
  sed -i '' "s#\"127.0.0.2:26656\"#\"127.0.0.1:26666\"#g" ${CODE_BASE}/testnets/babylondhome/node0/babylond/config/config.toml
  sed -i '' "s#\"tcp://0.0.0.0:26657\"#\"tcp://0.0.0.0:26667\"#g" ${CODE_BASE}/testnets/babylondhome/node1/babylond/config/config.toml
  sed -i '' "s#\"tcp://0.0.0.0:26656\"#\"tcp://0.0.0.0:26666\"#g" ${CODE_BASE}/testnets/babylondhome/node1/babylond/config/config.toml
  sed -i '' "s#\"26660\"#\"26670\"#g" ${CODE_BASE}/testnets/babylondhome/node1/babylond/config/config.toml
  find "${CODE_BASE}/testnets" -type f -name "*.yml" -exec sed -i '' "s#\"/Users/guoshijiang\"#\"${CODE_BASE}\"#g" {} +
  find "${CODE_BASE}/testnets" -type f -name "*.conf" -exec sed -i '' "s#\"/Users/guoshijiang\"#\"${CODE_BASE}\"#g" {} +


  echo "end init network config..."
}
