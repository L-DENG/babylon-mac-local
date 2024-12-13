#!/usr/bin/env bash

export CODE_BASE="$(dirname $( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P ))"
export GLOBAL_CONFIG=${CODE_BASE}/conf/config.yaml

export ACCOUNTS_YAML=${CODE_BASE}/conf/.accounts.yaml
export KEYS_YAML=${CODE_BASE}/conf/.keys.yaml
export ADDRESSES_YAML=${CODE_BASE}/conf/.addresses.yaml

export BIN_DIR=$(yq .params.binDir   ${GLOBAL_CONFIG})
export ETC_DIR=$(yq .params.etcDir   ${GLOBAL_CONFIG})
export TMP_DIR=$(yq .params.tmpDir   ${GLOBAL_CONFIG})
export ENVS_DIR=$(yq .params.envsDir ${GLOBAL_CONFIG})
export LOGS_DIR=$(yq .params.logsDir ${GLOBAL_CONFIG})
export DATA_DIR=$(yq .params.dataDir ${GLOBAL_CONFIG})

export ABS_BIN_DIR=${CODE_BASE}/${BIN_DIR}
export ABS_ETC_DIR=${CODE_BASE}/${ETC_DIR}
export ABS_TMP_DIR=${CODE_BASE}/${TMP_DIR}
export ABS_ENVS_DIR=${CODE_BASE}/${ENVS_DIR}
export ABS_LOGS_DIR=${CODE_BASE}/${LOGS_DIR}
export ABS_DATA_DIR=${CODE_BASE}/${DATA_DIR}

export DEPLOY_CONFIG_DIR=${CODE_BASE}/mantle-v2/.devnet

export SUPERVISORD_INI=${ABS_ETC_DIR}/supervisord/supervisord.ini

export DA_EXPERIMENT_CONFIG=${CODE_BASE}/mantle/datalayr/integration/data/experiment0/config.lock.yaml
export DA_V2_EXPERIMENT_CONFIG=${CODE_BASE}/mantle-v2/datalayr/integration/data/experiment0/config.lock.yaml

export PATH=${ABS_BIN_DIR}:${PATH}

export METRIC_PREFIX=script_exporter

export SH_YAML=${ABS_ETC_DIR}/script_exporter/script-exporter.sh.yaml

export HDR_CONTENT_TYPE_JSON="Content-Type: application/json"
