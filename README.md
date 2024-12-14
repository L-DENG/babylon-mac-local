# babylon Mac 环境本地网络启动


## 1.依赖安装 

- 安装依赖的工具最小集合到你系统 brew
```
HOMEBREW_NO_AUTO_UPDATE=1 brew install jq yq sha3sum go-task, supervisor, gvm
gvm install go1.23.3
gvm use go1.23.3
```

### 2.项目启动
- 下载 babylon-mac-local 项目
```
git clone git@github.com:dapplink-labs/babylon-mac-local.git
```

- 拉取依赖项目
```
git submodule update --init --recursive
```

- 构建项目

```
task buildAll
```

- 初始化配置
```
task init-network-conf
```

- 启动整个项目
```
task upAll
```
