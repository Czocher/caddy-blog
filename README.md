# Caddy-blog

This Dockerfile is meant to be a basis for a [Caddy](https://caddyserver.com) + [Hugo](https://gohugo.io/) + [git](https://caddyserver.com/docs/http.git) + [AsciiDoctor](https://asciidoctor.org) service on [Alpine Linux](https://alpinelinux.org/).
The main use case is for static Hugo blogs using AsciiDoc instead of Markdown and being dynamically updated from a git repository.
Caddy telemetry is disabled.

Installed plugins:
* [git](https://caddyserver.com/docs/http.git)
* [hugo](https://caddyserver.com/docs/http.hugo)
* [filemanager](https://caddyserver.com/docs/http.filemanager)
* [cors](https://caddyserver.com/docs/http.cors)
* [realip](https://caddyserver.com/docs/http.realip)
* [expires](https://caddyserver.com/docs/http.expires)
* [cache](https://caddyserver.com/docs/http.cache)

## Build arguments

This image defines the following build arguments for adaptation purposes:
* version - the version of Caddy to download eg. 0.11.0
* plugins - a space-separated list of Caddy plugins to be installed in the container
* packages - a space-separated list of Alpine packages to be installed in the container

### Example use case

```sh
docker build --build-arg version="0.11.0" --build-arg plugins="git hugo" --build-arg packages="hugo" github.com/czocher/caddy-blog.git
```

## Environmental variables

This image defines the following environmental variables for run time configuration:

* ACME - a boolean variable indicating the acceptance of the [Let's Encrypt](https://letsencrypt.org/) certificate agreement
* CADDYPATH - the path where the loaded certificates should be stored inside the container

> Remember to properly setup both the CADDYPATH and the volume mount point not to hit Let's Encrypt certificate refresh limit on container restart.

### Example use case

```sh
docker run -d -v $(pwd)/Caddyfile:/etc/Caddyfile -v $(pwd)/certs:/etc/certs/ -e "ACME=true" -e "CADDYPATH=/etc/certs" -p 80:80 -p 443:443 czocher1/caddy-blog
```

## Default Caddyfile

This image contains a default Caddyfile:

```
0.0.0.0

browse

log stdout

errors stdout
```

## Paths in container

* Caddyfile: /etc/Caddyfile
* Sites root: /srv/
* Certificate storage: /etc/certs/

# Acknowledgements

This image was based on [abiosoft/caddy-docker](https://github.com/abiosoft/caddy-docker/) image.
