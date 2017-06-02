FROM alpine:3.6
MAINTAINER CryptoPlay <docker@cryptoplay.tk>

WORKDIR /app
VOLUME /app

COPY run.sh /run.sh

RUN echo 'http://dl-4.alpinelinux.org/alpine/edge/testing' >> /etc/apk/repositories\
    && apk update \
    && apk add --no-cache \
    mysql mysql-client && \
    rm -f /var/cache/apk/*

COPY my.cnf /etc/mysql/my.cnf

EXPOSE 3306

CMD ["/run.sh"]
