## Builder
FROM golang:1.11-alpine as builder

ARG version="0.11.0"
ARG plugins="git hugo filemanager cors realip expires cache"

RUN apk add --no-cache git gcc musl-dev

# Clone Caddy
RUN git clone https://github.com/mholt/caddy -b "v${version}" /go/src/github.com/mholt/caddy && cd /go/src/github.com/mholt/caddy && git checkout -b "v${version}"

# Get and configure the plugin helper
RUN GOOS=linux GOARCH=amd64 go get -v github.com/abiosoft/caddyplug/caddyplug
RUN alias caddyplug='GOOS=linux GOARCH=amd64 caddyplug'

# Disable telemetry
RUN sed -i 's/var EnableTelemetry = true/var EnableTelemetry = false/g' /go/src/github.com/mholt/caddy/caddy/caddymain/run.go

# Enable plugins
RUN for plugin in $(echo ${plugins}); do \
      go get -v $(caddyplug package $plugin); \
      printf "package caddyhttp\nimport _ \"$(caddyplug package $plugin)\"" > /go/src/github.com/mholt/caddy/caddyhttp/$plugin.go ; \
    done

# Clone stuff required for the build
RUN git clone https://github.com/caddyserver/builds /go/src/github.com/caddyserver/builds

# Get the wrapper parent
RUN go get -v github.com/abiosoft/parent

# Compile
RUN cd /go/src/github.com/mholt/caddy/caddy && GOOS=linux GOARCH=amd64 go run build.go -goos=$GOOS -goarch=$GOARCH -goarm=$GOARM

# Copy the static binary
RUN mkdir -p /install && mv /go/src/github.com/mholt/caddy/caddy/caddy /install

## Final stage
FROM alpine:3.8
LABEL maintainer "Paweł Jan Czochański <czochanski@gmail.com>"

# Let's Encrypt Agreement
ENV ACME="false"

# Cert location
ENV CADDYPATH="/etc/certs"

# Additional packages
ARG packages="git hugo asciidoctor"

RUN apk add --no-cache openssh-client ${packages}

# Install caddy
COPY --from=builder /install/caddy /usr/bin/caddy

# Validate the install
RUN /usr/bin/caddy -version
RUN /usr/bin/caddy -plugins

EXPOSE 80 443 2015
VOLUME /srv /etc/certs
WORKDIR /srv

COPY Caddyfile /etc/Caddyfile
COPY index.html /srv/index.html

# Install process wrapper
COPY --from=builder /go/bin/parent /bin/parent

ENTRYPOINT ["/bin/parent", "caddy"]
CMD ["--conf", "/etc/Caddyfile", "--log", "stdout", "--agree=$ACME"]
