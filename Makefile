.PHONY: build test update-base-image update-tools

IMAGE ?= toolbox:dev

build:
	docker build --tag "$(IMAGE)" .

test: build
	docker run --rm "$(IMAGE)" /bin/bash -Eeuo pipefail -c \
		'curl --version \
		&& dig -v \
		&& go version \
		&& grpcurl -version \
		&& jq --version \
		&& kubectl version --client \
		&& nvim --version \
		&& node --version \
		&& npm --version \
		&& pgcli --version \
		&& psql --version \
		&& temporal --version \
		&& wget --version \
		&& yq --version \
		&& test -r /etc/ssl/certs/ca-certificates.crt'

update-base-image:
	./scripts/update-base-image $(if $(BASE_IMAGE),"$(BASE_IMAGE)",)

update-tools:
	./scripts/update-tools
