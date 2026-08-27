# syntax=docker/dockerfile:1

FROM jdxcode/mise:2026.8.3@sha256:92dbc3f2573926d8974e4641ad8449f16c323130b9f41c39aff19b7b2f500ef6 AS tools

COPY image-tools.toml /mise/config.toml

RUN --mount=type=cache,target=/mise/cache,sharing=locked \
    mise install --yes \
    && mkdir /toolbox-bin \
    && mise exec -- bash -Eeuo pipefail -c \
        'for command in corepack go gofmt grpcurl kubectl node npm npx temporal yq; do \
          target="$(command -v "${command}")"; \
          printf "#!/bin/sh\nexec %q \"\$@\"\n" "${target}" > "/toolbox-bin/${command}"; \
          chmod +x "/toolbox-bin/${command}"; \
        done'

FROM debian:13-slim@sha256:d7e12182ce18b85b93007c1dedf31f2d29e01ccf3182cc4017c709b6259bc132 AS os

RUN DEBIAN_FRONTEND=noninteractive apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends --yes \
        build-essential \
        ca-certificates \
        curl \
        dnsutils \
        git \
        iproute2 \
        iputils-ping \
        jq \
        less \
        lsof \
        mtr-tiny \
        netcat-openbsd \
        neovim \
        openssh-client \
        openssl \
        pgcli \
        postgresql-client \
        procps \
        psmisc \
        socat \
        strace \
        tcpdump \
        wget \
        xz-utils \
    && rm -rf /var/lib/apt/lists/*

COPY --from=tools /mise/installs /mise/installs
COPY --from=tools /toolbox-bin /usr/local/bin

WORKDIR /workspace

CMD ["/bin/bash"]
