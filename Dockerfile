FROM alpine

ENV DOCKER_GEN_VERSION=0.7.4
ENV SIMP_LE_VERSION=0.18.0

RUN apk add --update bash curl \
    && curl -L \
        https://github.com/jwilder/docker-gen/releases/download/$DOCKER_GEN_VERSION/docker-gen-linux-amd64-$DOCKER_GEN_VERSION.tar.gz \
        | tar -xzv -C /usr/local/bin \
    && apk add gcc git py3-pip py3-setuptools python3 libffi-dev musl-dev openssl openssl-dev python3-dev \
        && pip install git+git://github.com/zenhack/simp_le.git@$SIMP_LE_VERSION requests requests[security] \
        && apk del gcc git libffi-dev musl-dev openssl-dev python3-dev

ENV DEBUG=false
ENV DOCKER_HOST=unix:///var/run/docker.sock

VOLUME /output

COPY ./app /app
WORKDIR /app

ENTRYPOINT ["/app/entrypoint"]
