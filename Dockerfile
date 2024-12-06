# build
COPY . ./ 
RUN npm run build

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

# Ensure the correct paths are being copied from the builder image
COPY --from=builder /app/public .
COPY --from=builder /app/build ./dist  # Ensure we are copying from 'build' directory
COPY --from=builder /app/node_modules ./node_modules
