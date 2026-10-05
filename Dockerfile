# syntax=docker/dockerfile:1

FROM jdxcode/mise:2026.10.0@sha256:5253aad873240675097e6229786dff87d54a9ac9d52917e42903de37511f74b3 AS tools

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
