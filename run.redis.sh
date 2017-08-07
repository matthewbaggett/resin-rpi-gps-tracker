#!/bin/bash
[ -d /data/redis ] || mkdir /data/redis
redis-server /etc/redis/redis.conf
