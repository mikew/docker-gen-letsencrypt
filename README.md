# docker-gen-letsencrypt

Watches Docker containers and creates a nginx reverse-proxy
configuration with certificates from [Let's Encrypt](https://letsencrypt.org/).

A drop-in replacement for [jwilder/nginx-proxy](https://github.com/jwilder/nginx-proxy).

## Usage

### Virtual Hosts

Containers with the `VIRTUAL_HOST` environment variable set will be
included in the generated configuration.

### Ports

Set the `VIRTUAL_PORT` environment variable to specify which port to
use. When absent, it will default to `80`, or the only port exposed by
the container.

### Certificates

Set the `CERT_NAME` environment variable to specify the name of the
certificate to be used. When absent it will default to the value of
`VIRTUAL_HOST`. If the key cannot be found in `/etc/nginx/certs/` then
SSL will be disabled for the container.

### Basic Authentication

Default to the value of `VIRTUAL_HOST`. If the file cannot be found in
`/etc/nginx/htpasswd/` then basic auth will be disabled for the container.

### CORS

Set the `CORS_ENABLED` environment variable to add CORS headers. There
are a few other environment variables you can set for further tuning:

Variable Name | Default
---|---
`CORS_ORIGIN` | `*`
`CORS_METHODS` | `GET`
`CORS_HEADERS` | `Access-Control-Request-Headers,Authorization,DNT,X-CustomHeader,Keep-Alive,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type,Accept-Encoding`

### Additional Configuration

If you would like to add aditional configuration to the generated
reverse-proxy configuration, you have some options:

- Add `/etc/nginx/vhost.d/${VIRTUAL_HOST}` to modify the `server` block
- Add `/etc/nginx/vhost.d/${VIRTUAL_HOST}_location` to modify the `location` block
- Add `/etc/nginx/vhost.d/default` to modify the `server` block
- Add `/etc/nginx/vhost.d/default_location` to modify the `location` block

## Configuration

Most of the configuration is done in your containers, as described
above. There are only a few settings for docker-gen-letsencrypt:

Variable Name | Notes
---|---
`LETSENCRYPT_EMAIL` | **Required.** Set this to your email.
`LETSENCRYPT_DOMAIN` | **Required.** Set this to your domain for a wildcard certificate to be generated.
`LETSENCRYPT_DNSAPI` | **Required.** Set this to a dnsapi provider in acme.sh
`NGINX_CONTAINER` | **Required.** Set this to the name of nginx container to be reloaded when the configuration changes.
`DEFAULT_SERVER` | Set this to the `VIRTUAL_HOST` of a container and the default server will be flagged in the generated configuration.

## Docker Compose

```yaml
main:
  image: mikewhy/docker-gen-letsencrypt
  environment:
    - LETSENCRYPT_EMAIL=your@email.com
    - LETSENCRYPT_DOMAIN=example.com
    - LETSENCRYPT_DNSAPI=dns_aws
    - NGINX_CONTAINER=docker-gen-letsencrypt_nginx_1
  volumes:
    - /var/run/docker.sock:/var/run/docker.sock:ro
  volumes_from:
    - nginxdata

nginx:
  image: nginx:alpine
  ports:
    - "80:80"
    - "443:443"
  volumes:
    - ./persistent/logs:/var/log/nginx
  volumes_from:
    - nginxdata

nginxdata:
  image: alpine
  command: "true"
  volumes:
    - ./persistent/conf.d:/etc/nginx/conf.d
    - ./persistent/vhost.d:/etc/nginx/vhost.d
    - ./persistent/certs:/etc/nginx/certs
    - ./persistent/htpasswd:/etc/nginx/htpasswd
    - ./persistent/html:/usr/share/nginx/html
```
