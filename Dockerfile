FROM resin/rpi-raspbian
MAINTAINER matthew@baggett.me

# Let's start with some basic stuff.
RUN apt-get update -qq && apt-get install -qqy \
    apt-transport-https \
    ca-certificates \
    curl \
    lxc \
    iptables \
    nano
    
# Install Docker from Docker Inc. repositories.
COPY ./docker /usr/bin/rce
RUN chmod u+x /usr/bin/rce

# Install the magic wrapper.
ADD ./wrapdocker /usr/local/bin/wraprce
RUN chmod +x /usr/local/bin/wraprce

# Install Docker Compose
RUN echo "deb https://packagecloud.io/Hypriot/Schatzkiste/debian/ jessie main" | tee /etc/apt/sources.list.d/hypriot.list
RUN apt-get update -qq && apt-get install -qqy docker-compose

RUN echo "#!/bin/bash\nDOCKER_HOST=unix:///var/run/rce.sock /usr/local/bin/docker-compose $@" > /usr/bin/docker-compose
RUN chmod +x /usr/bin/docker-compose

RUN mkdir /app
COPY ./docker-compose.yml /app/docker-compose.yml
WORKDIR /app

# Define additional metadata for our image.
VOLUME /var/lib/rce
CMD ["wraprce"]
