# toolbox

A small, general-purpose container image for temporary Kubernetes pods used for
debugging, migrations, and administrative commands.

The image is based on the official Debian 13 slim image. Debian provides the
shell, build, network, process, TLS, SSH, PostgreSQL, and editor utilities. Mise
provides pinned versions of Go, Node.js, kubectl, grpcurl, Temporal, and yq. Base
images are pinned by digest so every commit builds reproducibly.

Notable commands include:

- Runtimes: `go`, `node`, `npm`
- Kubernetes and RPC: `kubectl`, `temporal`, `grpcurl`
- PostgreSQL: `pgcli`, `psql`, `pg_dump`, `pg_restore`
- Network and DNS: `curl`, `wget`, `dig`, `host`, `nslookup`, `ip`, `ss`,
  `ping`, `nc`, `mtr`, `socat`, `tcpdump`
- Process debugging: `ps`, `top`, `watch`, `lsof`, `strace`
- Data and editing: `jq`, `yq`, `neovim`

## Use

Start an interactive temporary pod:

```sh
kubectl run toolbox \
  --rm --stdin --tty \
  --restart=Never \
  --image=ghcr.io/gfx-labs/toolbox:latest
```

Build and test locally:

```sh
make test
```

Override the local image name with `make build IMAGE=example/toolbox:dev`.

## Base image updates

Dependabot checks the Dockerfile each weekday. When Debian publishes a new
compatible image or refreshes the `13-slim` digest, Dependabot opens a pull
request. CI validates that pull request, and merging it publishes updated
`linux/amd64` and `linux/arm64` images to GHCR.

To refresh the digest manually:

```sh
make update-base-image
make test
```

To move to another Debian release or tag:

```sh
make update-base-image BASE_IMAGE=debian:14-slim
make test
```

Mise-managed tools are pinned in `image-tools.toml`. Its nonstandard name keeps
Mise from loading the image toolchain automatically on developer machines.
Refresh tools within their current supported release lines with:

```sh
make update-tools
make test
```

The updater follows Go 1.x, Node 24 LTS, kubectl 1.36, grpcurl 1.x, Temporal
1.x, and yq 4.x. Change those release policies in `scripts/update-tools` when a
planned major or Kubernetes minor upgrade is desired.

## Published tags

- `latest` tracks the `main` branch.
- `sha-<commit>` identifies an immutable source revision.
- Pushing a Git tag such as `v2026.8.0` publishes the same image tag.
