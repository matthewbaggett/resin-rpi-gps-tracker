FROM gone/php-arm:cli
RUN apt-get -qq update && \
    apt-get -yq install --no-install-recommends \
        build-essential \
        php-dev \
        php-redis \
        redis-server \
        gpsd \
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

RUN rm -Rf /app/gps && /app/sync \
 && git clone git@github.com:matthewbaggett/rpi-docker-gps-logger.git /app/gps \
 && git clone git@github.com:goneio/redis-sync.git /app/sync

RUN mkdir /etc/service/redis \
 && cp /app/run.redis.sh /etc/service/redis/run \
 && sed -i "s/dir.*/dir \/data\/redis/g" /etc/redis/redis.conf \
 && cat /etc/redis/redis.conf | grep "dir " \
 && mkdir /etc/service/gpsd \
 && cp /app/run.gpsd.sh /etc/service/gpsd/run \
 && cp -R /app/gps/logger/.docker/service/* /etc/service \
 && cp -R /app/sync/.docker/service/* /etc/service \
 && ls -lah /etc/service \
 && chmod +x /etc/service/*/run \
 && chmod +x /app/gps/logger/*.php \
 && chmod +x /app/sync/*.php \
 && sed -i "s/\/app/\/app\/gps\/logger/g" /etc/service/push-to-redis/run \
 && sed -i "s/\/app/\/app\/sync/g" /etc/service/sync/run \
 && cd /app/gps/logger && composer install && cd - \
 && cd /app/sync && composer install && cd -

