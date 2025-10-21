# C to Rust 转译工具 Docker 镜像
# 基于 Ubuntu 24.04

FROM ubuntu:24.04

# 设置工作目录
WORKDIR /workspace

# 避免交互式提示
ENV DEBIAN_FRONTEND=noninteractive

# 更新包列表并安装基础依赖
RUN apt-get update && apt-get install -y \
    build-essential \
    clang \
    llvm \
    libclang-dev \
    curl \
    git \
    pkg-config \
    libfuse-dev \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# 安装 Rust
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"

# 安装常用的 Rust 工具
RUN cargo install cargo-edit cargo-watch

# 复制转译工具源代码（根据实际情况调整）
# COPY src/ /workspace/src/
# COPY Cargo.toml /workspace/

# 构建转译工具
# RUN cargo build --release

# 复制待转译的C项目
# COPY translate_chibicc/ /workspace/translate_chibicc/
# COPY translate_littlefs_fuse/ /workspace/translate_littlefs_fuse/

# 创建输出目录
RUN mkdir -p /workspace/output

# 设置默认命令
CMD ["/bin/bash"]

# 元数据
LABEL maintainer="vivo蓝河操作系统创新赛参赛队伍"
LABEL description="C to Rust 自动转译工具"
LABEL version="1.0"
