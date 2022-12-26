FROM alpine

ENV DOCKER_GEN_VERSION=0.9.2

RUN apk add --update \
    bash \
    wget \
    curl \
    sed \
    openssl \
    jq \
  && curl -L \
    https://github.com/jwilder/docker-gen/releases/download/$DOCKER_GEN_VERSION/docker-gen-alpine-linux-amd64-$DOCKER_GEN_VERSION.tar.gz \
    | tar -xzv -C /usr/local/bin \
  && mkdir -p /tmp/acme.sh \
  && curl -L \
    "https://github.com/acmesh-official/acme.sh/archive/master.tar.gz" \
    | tar -xzv -C /tmp/acme.sh --strip-components 1 \
  && cd /tmp/acme.sh || exit 1 \
  && ./acme.sh \
    --install \
    --nocron \
    --home /etc/acme.sh/home \
    --config-home /etc/acme.sh/config \
    --cert-home /etc/nginx/certs \
  && rm -rf /tmp/acme.sh

ENV DOCKER_HOST=unix:///var/run/docker.sock

VOLUME /output

COPY ./app /app
WORKDIR /app

ENTRYPOINT ["/app/entrypoint"]
