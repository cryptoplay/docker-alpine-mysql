FROM alpine:edge
MAINTAINER CryptoPlay <docker@cryptoplay.tk>

WORKDIR /app
VOLUME /app

COPY run.sh /run.sh

RUN apk --update add mysql mysql-client && \
    rm -f /var/cache/apk/*

COPY my.cnf /etc/mysql/my.cnf

EXPOSE 3306

CMD ["/run.sh"]
