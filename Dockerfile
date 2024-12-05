# BUILDING
FROM --platform=linux/arm64 node:lts-alpine AS builder

# base on work of llitfkitfk@gmail.com
LABEL maintainer="chibing.fy@alibaba-inc.com"

WORKDIR /app

# cache dependencies
COPY package.json ./ 

# install dependencies
RUN npm install typescript -g && 
    npm install

# tesst
RUN npm install typescript@4.1 --save-dev

# build
COPY . ./
RUN npm run build

# RUNNING
FROM --platform=linux/arm64 node:lts-alpine

# base on work of llitfkitfk@gmail.com
LABEL maintainer="chibing.fy@alibaba-inc.com"

# Ensure pandoc is available and suitable for ARM architecture
RUN wget https://github.com/jgm/pandoc/releases/download/2.7.3/pandoc-2.7.3-linux-arm64.tar.gz && \
    tar -xf pandoc-2.7.3-linux-arm64.tar.gz && \
    cp pandoc-2.7.3/bin/* /usr/bin/ && \
    pandoc -v && \
    rm -rf pandoc-2.7.3-linux-arm64.tar.gz pandoc-2.7.3

WORKDIR /app
COPY --from=builder /app/public .
COPY --from=builder /app/dist .
COPY --from=builder /app/node_modules ./node_modules
