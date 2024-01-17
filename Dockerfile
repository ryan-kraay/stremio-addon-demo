ARG crystal_version=1.11.1

#
# Our Crystal Compiler
#
FROM crystallang/crystal:${crystal_version}-alpine AS crystal-builder

WORKDIR /app

# Install our necessary libraries
RUN apk add --no-cache \
      # TODO remove sqlite-dev from stremio-addon-devkit
      sqlite-dev lz4-dev

# Install the shards for caching
COPY shard.lock shard.yml ./
RUN shards install --ignore-crystal-version --skip-postinstall --skip-executables

# Add our Source Code
COPY . .

# Build and Test the application
RUN du -ah . | grep -v lib/ && \
    KEMAL_ENV=test crystal spec && \
    shards build --production --release --error-trace --static && \
    strip ./bin/* && \
    ls -lh ./bin/ && \
    mkdir -p /output/usr/local/bin && \
    cp -v ./bin/* /output/usr/local/bin/

#
# Our Application
#
FROM scratch

WORKDIR /
ENV PATH=$PATH:/usr/local/bin \
    KEMAL_ENV=production \
    PORT=9000

# Any SSL requests that our application makes, will need CA Certificates
COPY --from=crystal-builder /etc/ssl /etc/ssl

COPY --from=crystal-builder /output /

CMD ["/usr/local/bin/stremio-addon-demo"]
