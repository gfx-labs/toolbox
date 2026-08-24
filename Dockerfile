# syntax=docker/dockerfile:1

FROM jdxcode/mise:2026.8.10@sha256:f2d637d5e5189f7ec177b73bce5cd5db7e7b17a4f466f887c1b88ac2dd431129 AS tools

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

FROM debian:13-slim@sha256:3a39a0592364683e6bab97937b72cad5a8fa6dcbbee90edb3bb48c7f8e94f258 AS os

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
