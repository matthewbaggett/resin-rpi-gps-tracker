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

#RUN git clone https://github.com/matthewbaggett/rpi-docker-gps-logger.git /app/gps

RUN mkdir /etc/service/redis \
 && cp /app/run.redis.sh /etc/service/redis/run \
 && cp -R /app/gps/logger/.docker/service /etc/service \
 && cp -R /app/gps/sync/.docker/service /etc/service \
 && chmod +x /etc/service/*/run \
 && chmod +x /app/gps/logger/*.php \
 && chmod +x /app/gps/sync/*.php \
 && sed -i "s/\/app/\/app\/gps\/logger/g" /etc/service/push-to-redis/run \
 && sed -i "s/\/app/\/app\/gps\/sync/g" /etc/service/sync/run

