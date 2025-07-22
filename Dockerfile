# ---------- Build Stage ----------
FROM alpine:latest AS build

LABEL version="3" description="OpenSSL Static Build with Alpine"

RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.tuna.tsinghua.edu.cn/g' /etc/apk/repositories \
    && apk update \
    && apk upgrade \
    && apk add --no-cache perl build-base

WORKDIR /opt/build

# 如果本地有 openssl 目录，直接复制；也可以用 git clone --depth=1 -b master https://github.com/openssl/openssl.git && cd openssl && git submodule update --init --recursive
COPY openssl openssl

WORKDIR /opt/build/openssl

RUN LDFLAGS="-Wl,-rpath -Wl,/opt/openssl/lib64" && \
    ./Configure no-shared no-dso no-tests no-module no-ssl2 no-ssl3 no-comp no-hw no-engine no-secure-memory --prefix=/opt/openssl --openssldir=/opt/openssl/ssl && \
    make -j"$(nproc)" && make install && \
    if [ -d /opt/openssl/lib64 ]; then ln -s /opt/openssl/lib64 /opt/openssl/lib; fi && \
    if [ -d /opt/openssl/lib ]; then ln -s /opt/openssl/lib /opt/openssl/lib64; fi

# ---------- Run Stage ----------
FROM alpine:latest AS run

LABEL version="3" description="Minimal OpenSSL Runtime with Alpine"

ENV TZ="Asia/Shanghai"
ENV PATH="/opt/openssl/bin:${PATH}"

WORKDIR /opt

# 复制编译好的 OpenSSL
COPY --from=build /opt/openssl /opt/openssl

# 安装必要运行环境
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.tuna.tsinghua.edu.cn/g' /etc/apk/repositories \
    && apk update \
    && apk add --no-cache ca-certificates \
    && update-ca-certificates

# 验证 OpenSSL 版本
CMD ["/bin/sh"]
