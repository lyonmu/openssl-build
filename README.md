# OpenSSL Docker 构建环境

这个仓库用于构建一个基于 Alpine Linux 的 OpenSSL Docker 镜像。项目通过多阶段构建在容器内编译 OpenSSL，并在运行阶段提供一个尽量精简的命令行环境，便于做版本验证、算法检查和交互式调试。

## 项目内容

- 顶层 `Dockerfile`：定义构建镜像和运行镜像
- `openssl/`：OpenSSL 源码子模块
- `README.md`：当前项目说明

当前仓库中的 OpenSSL 子模块版本信息来自 [`openssl/VERSION.dat`](./openssl/VERSION.dat)：

- 主版本：`4.0.0`
- 发布日期：`2026-04-14`

## 镜像特性

`Dockerfile` 里可以直接确认的构建特征如下：

- 使用 Alpine 作为构建和运行基础镜像
- 使用多阶段构建，最终镜像只携带安装后的 OpenSSL
- 构建阶段安装 `perl` 和 `build-base`
- 通过 `./Configure` 编译 OpenSSL
- 安装前缀为 `/opt/openssl`
- 运行时将 `/opt/openssl/bin` 加入 `PATH`
- 运行镜像默认安装 `ca-certificates`

当前配置使用了以下 OpenSSL 编译选项：

```bash
no-shared no-dso no-tests no-module no-ssl2 no-ssl3 no-comp no-hw no-engine no-secure-memory
```

这意味着最终镜像偏向“静态、精简、命令行使用”的构建方式，而不是一个带完整测试与动态模块能力的开发镜像。

## 前置要求

- 已安装 Docker
- 已拉取仓库
- 已初始化 `openssl` 子模块

如果是首次拉取仓库，先执行：

```bash
git submodule update --init --recursive
```

## 构建镜像

在仓库根目录执行：

```bash
docker build -f Dockerfile -t openssl:latest .
```

如果你想显式刷新子模块到仓库记录的提交，可以先执行：

```bash
git submodule sync --recursive
git submodule update --init --recursive
```

## 运行示例

查看 OpenSSL 版本：

```bash
docker run -it --rm openssl:latest openssl version -a
```

查看 Provider：

```bash
docker run -it --rm openssl:latest openssl list -providers
```

查看全部算法：

```bash
docker run -it --rm openssl:latest openssl list -all-algorithms
```

进入容器交互环境：

```bash
docker run -it --rm openssl:latest /bin/sh
```

进入容器后，OpenSSL 安装路径为：

```bash
/opt/openssl
```

常见可执行文件路径为：

```bash
/opt/openssl/bin/openssl
```

## 构建过程说明

构建阶段主要流程：

1. 基于 Alpine 安装编译依赖
2. 复制本地 `openssl/` 源码目录到镜像
3. 在容器中运行 `./Configure`
4. 执行 `make` 和 `make install`
5. 将安装结果复制到运行阶段镜像

运行阶段主要流程：

1. 基于 Alpine 创建最小运行环境
2. 拷贝 `/opt/openssl`
3. 安装系统 CA 证书
4. 默认进入 `/bin/sh`

## 注意事项

- 这个仓库依赖 `openssl/` 子模块；如果子模块未初始化，`docker build` 会失败
- `Dockerfile` 当前直接替换了 Alpine 软件源为清华镜像
- 镜像默认适合命令行验证和调试，不包含 OpenSSL 自带测试执行流程
- 由于使用 `no-shared`、`no-module` 等选项，运行行为与系统包形式的 OpenSSL 发行版并不完全相同

## 参考文档

- [Dockerfile](./Dockerfile)
- [OpenSSL 上游 README](./openssl/README.md)
- [OpenSSL 安装说明](./openssl/INSTALL.md)
- [OpenSSL QUIC 说明](./openssl/README-QUIC.md)
- [OpenSSL Providers 说明](./openssl/README-PROVIDERS.md)
