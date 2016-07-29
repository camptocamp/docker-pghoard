FROM postgres:9.5
MAINTAINER Camptocamp <docker@camptocamp.com>

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update \
  && apt-get -y --no-install-suggests --no-install-recommends install \
     gcc \
     g++ \
     make \
     libffi-dev \
     curl \
     rsync \
     libsnappy-dev \
     python3-setuptools \
     python3-dev \
     python3-pip \
     libpq-dev \
  && pip3 install pghoard awscli boto python-keystoneclient python-swiftclient \
  && apt-get -y remove gcc python2.7 \
  && apt-get -y autoremove \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

RUN curl -L -o /usr/local/bin/confd https://github.com/kelseyhightower/confd/releases/download/v0.11.0/confd-0.11.0-linux-amd64 \
  && chmod +x /usr/local/bin/confd

COPY conf.d /etc/confd/conf.d
COPY templates /etc/confd/templates
 
RUN mkdir -p /home/postgres/restore && chown -R postgres /home/postgres
COPY /docker-entrypoint.sh /
USER postgres
WORKDIR /home/postgres

ENTRYPOINT ["/docker-entrypoint.sh"]
