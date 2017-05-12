# reference: https://github.com/ZZROTDesign/alpine-caddy
FROM alpine:3.5
MAINTAINER Zongzhi Bai <dolphineor@gmail.com>

ENV PYTHON_VERSION=2.7.13-r0
ENV PY2_PIP_VERSION=9.0.0-r1
ENV SUPERVISOR_VERSION=3.3.1

# Setup TimeZone
RUN apk update && apk --no-cache add ca-certificates tzdata vim && \
    ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    echo "Asia/Shanghai" > /etc/timezone

# Install Supervisor
RUN apk --no-cache add -u python=$PYTHON_VERSION py2-pip=$PY2_PIP_VERSION
RUN pip install supervisor==$SUPERVISOR_VERSION

# Install Caddy Server
RUN apk --no-cache add --virtual devs tar curl
RUN curl "https://caddyserver.com/download/linux/amd64?plugins=dns,http.cors,http.jwt,http.proxyprotocol,http.realip" \
    | tar --no-same-owner -C /usr/bin/ -xz caddy

RUN apk del devs
RUN mkdir -p /var/log/supervisor && \
    mkdir -p /var/log/caddy && \
    mkdir -p /var/log/squirrel

ADD ./dist/squirrel-server /usr/local/bin/
ADD ./docker/Caddyfile /etc/caddy/Caddyfile
ADD ./docker/supervisord.conf /etc/supervisor/supervisord.conf

EXPOSE 80

ENTRYPOINT ["supervisord", "-n", "-c", "/etc/supervisor/supervisord.conf"]
