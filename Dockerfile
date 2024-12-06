# BUILDING
FROM --platform=linux/arm64 node:lts-alpine AS builder

# base on work of llitfkitfk@gmail.com
LABEL maintainer="chibing.fy@alibaba-inc.com"

WORKDIR /app

# cache dependencies
COPY package.json ./ 

# 安装缺失的 Babel 插件
RUN npm install typescript@latest --save-dev

# 安装缺失的 Babel 插件1
RUN npm install request-promise-native

# 安装缺失的 Babel 插件2
RUN npm install @types/request-promise-native --save-dev

# install dependencies
RUN npm install typescript -g && \
    npm install

# build
COPY . ./ 
RUN npm run build

# og
RUN ls -la /app/dist

# RUNNING
FROM --platform=linux/arm64 node:lts-alpine

# base on work of llitfkitfk@gmail.com
LABEL maintainer="chibing.fy@alibaba-inc.com"

# Ensure pandoc is available and suitable for ARM architecture
RUN wget https://github.com/jgm/pandoc/releases/download/3.5/pandoc-3.5-linux-arm64.tar.gz && \
    tar -xf pandoc-3.5-linux-arm64.tar.gz && \
    cp pandoc-3.5/bin/* /usr/bin/ && \
    pandoc -v && \
    rm -rf pandoc-3.5-linux-arm64.tar.gz pandoc-3.5

WORKDIR /app
COPY --from=builder /app/public .
COPY --from=builder /app/dist .
COPY --from=builder /app/node_modules ./node_modules
