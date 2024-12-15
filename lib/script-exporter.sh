#!/usr/bin/env bash

export CODE_BASE="$(dirname $( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P ))"
export BASE_CONFIG=${CODE_BASE}/conf/baseconfig.yaml

export ETC_DIR=$(yq .params.etcDir   ${BASE_CONFIG})
export TMP_DIR=$(yq .params.tmpDir   ${BASE_CONFIG})
export ENVS_DIR=$(yq .params.envsDir ${BASE_CONFIG})
export LOGS_DIR=$(yq .params.logsDir ${BASE_CONFIG})
export DATA_DIR=$(yq .params.dataDir ${BASE_CONFIG})


export ABS_ETC_DIR=${CODE_BASE}/${ETC_DIR}
export ABS_TMP_DIR=${CODE_BASE}/${TMP_DIR}
export ABS_ENVS_DIR=${CODE_BASE}/${ENVS_DIR}
export ABS_LOGS_DIR=${CODE_BASE}/${LOGS_DIR}
export ABS_DATA_DIR=${CODE_BASE}/${DATA_DIR}


export SUPERVISORD_INI=${ABS_ETC_DIR}/supervisord/supervisord.ini
export PATH=${ABS_BIN_DIR}:${PATH}
export METRIC_PREFIX=script_exporter


export HDR_CONTENT_TYPE_JSON="Content-Type: application/json"


