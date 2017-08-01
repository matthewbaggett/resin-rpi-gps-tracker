FROM gone/php-arm:cli
RUN apt-get -qq update && \
    apt-get -yq install --no-install-recommends \
        build-essential \
        php-dev \
        php-redis \
        redis-server \
        libhiredis-dev && \
    cd /tmp && \
    git clone https://github.com/nrk/phpiredis.git && \
    cd phpiredis && \
    phpize && \
    ./configure --enable-phpiredis && \
    make && \
    make install && \
    echo "extension=phpiredis.so" > /etc/php/7.0/cli/php.ini && \
    cd - && \
    apt remove -y build-essential && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY gps/logger/. /app/logger
COPY gps/sync/. /app/sync

RUN git clone https://github.com/matthewbaggett/rpi-docker-gps-logger.git /app/gps

COPY . /app

RUN mkdir /etc/service/redis \
 && cp /app/run.redis.sh /etc/service/redis/run \
 && cp /app/gps/logger/.docker/service /etc/service \
 && cp /app/gps/sync/.docker/service /etc/service \
 && chmod +x /etc/service/*/run \
 && chmod +x /app/*.php

RUN sed -i "s/\/app/\/app\/logger/g" /etc/service/push-to-redis/run
RUN sed -i "s/\/app/\/app\/sync/g" /etc/service/sync/run

