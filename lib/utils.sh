#!/bin/bash

export CODE_BASE=/Users/guoshijiang/babylonWorkSpace/babylon-mac-local  # 需要修改成你的 babylon mac local 的地址

export ETC_DIR=/conf

export ABS_ETC_DIR=${CODE_BASE}/${ETC_DIR}

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
  mkdir -p ${CODE_BASE}/testnets/btcstaker
  mkdir -p ${CODE_BASE}/testnets/finalityprovider
  mkdir -p ${CODE_BASE}/testnets/consumerfp
  mkdir -p ${CODE_BASE}/testnets/eotsmanager
  mkdir -p ${CODE_BASE}/testnets/consumereotsmanager
  mkdir -p ${CODE_BASE}/testnets/covenantemulator

  # 拷贝文件到相应的目录,reporter, submitter, monitor 和 bstracker 角色
  cp ${CODE_BASE}/conf/vigilante.yml ${CODE_BASE}/testnets/vigilante/vigilante.yml
  cp ${CODE_BASE}/conf/submitter.yml ${CODE_BASE}/testnets/vigilante/submitter.yml
  cp ${CODE_BASE}/conf/monitor.yml ${CODE_BASE}/testnets/vigilante/monitor.yml
  cp ${CODE_BASE}/conf/bstracker.yml ${CODE_BASE}/testnets/vigilante/bstracker.yml

  # bitcoin
  cp ${CODE_BASE}/conf/bitcoin.conf ${CODE_BASE}/testnets/bitcoin/bitcoin.conf

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


  # 修改目录配置
  echo "Change settings in config files..."
  chmod -R 777 ${CODE_BASE}/testnets
  sed -i '' "s/127.0.0.2:26656/127.0.0.1:26666/g" ${CODE_BASE}/testnets/babylondhome/node0/babylond/config/config.toml
  sed -i '' "s/0.0.0.0:26657/0.0.0.0:26667/g" ${CODE_BASE}/testnets/babylondhome/node1/babylond/config/config.toml
  sed -i '' "s/0.0.0.0:26656/0.0.0.0:26666/g" ${CODE_BASE}/testnets/babylondhome/node1/babylond/config/config.toml
  sed -i '' "s/26660/26670/g" ${CODE_BASE}/testnets/babylondhome/node1/babylond/config/config.toml
  find "${CODE_BASE}/testnets" -type f -name "*.yml" -exec sed -i '' "s/\/Users\/guoshijiang/\/Users\/guoshijiang\/babylonWorkSpace\/babylon-mac-local/g" {} +
  find "${CODE_BASE}/testnets" -type f -name "*.conf" -exec sed -i '' "s/\/Users\/guoshijiang/\/Users\/guoshijiang\/babylonWorkSpace\/babylon-mac-local/g" {} +

  echo "end init network config..."
}
