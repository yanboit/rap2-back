# BUILDING
FROM --platform=linux/arm64 node:lts-alpine AS builder

LABEL maintainer="chibing.fy@alibaba-inc.com"

WORKDIR /app

# cache dependencies
COPY package.json ./ 

# 安装缺失的 Babel 插件
RUN npm install typescript@latest --save-dev
RUN npm install request-promise-native
RUN npm install @types/request-promise-native --save-dev

# 安装依赖
RUN npm install typescript -g && \
    npm install

# 拷贝源代码并构建
COPY . ./ 
RUN npm run build

# 添加调试命令：列出构建后的目录
RUN ls -la /app/dist  # 输出 dist 目录内容

# RUNNING
FROM --platform=linux/arm64 node:lts-alpine

LABEL maintainer="chibing.fy@alibaba-inc.com"

# Ensure pandoc is available and suitable for ARM architecture
RUN wget https://github.com/jgm/pandoc/releases/download/3.5/pandoc-3.5-linux-arm64.tar.gz && \
    tar -xf pandoc-3.5-linux-arm64.tar.gz && \
    cp pandoc-3.5/bin/* /usr/bin/ && \
    pandoc -v && \
    rm -rf pandoc-3.5-linux-arm64.tar.gz pandoc-3.5

WORKDIR /app

# 列出 /app 目录的内容，确认 dist 目录是否存在
RUN ls -la /app  # 输出 /app 目录内容

# 复制构建产物到运行环境
COPY --from=builder /app/public .  # 如果 public 目录存在
COPY --from=builder /app/dist .  # 使用 dist 目录
COPY --from=builder /app/node_modules ./node_modules
