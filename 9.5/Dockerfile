FROM postgres:9.5
MAINTAINER Camptocamp <docker@camptocamp.com>

ENV DEBIAN_FRONTEND=noninteractive \
  CONFD_VERSION=0.12.0-alpha3 \
  PGHOARD_VERSION=f38b187 \
  PGHOARD_BASEBACKUP_COUNT=1 \
  PGHOARD_BASEBACKUP_INTERVAL_HOURS=24 \
  PGHOARD_LOG_LEVEL=INFO \
  PGHOARD_STATSD_PORT=8125 \
  PGHOARD_STATSD_FORMAT=telegraf

RUN apt-get update \
  && apt-get -y --no-install-suggests --no-install-recommends install \
     gcc \
     g++ \
     git \
     make \
     libffi-dev \
     curl \
     rsync \
     libsnappy-dev \
     python3-setuptools \
     python3-dev \
     python3-pip \
     libpq-dev \
  && pip3 install \
     git+https://github.com/psycopg/psycopg2.git@2a4d602 \
     git+https://github.com/ohmu/pghoard.git@${PGHOARD_VERSION} \
     awscli boto python-keystoneclient python-swiftclient \
  && apt-get -y remove gcc python2.7 \
  && apt-get -y autoremove \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

RUN curl -L -o /usr/local/bin/confd https://github.com/kelseyhightower/confd/releases/download/v${CONFD_VERSION}/confd-${CONFD_VERSION}-linux-amd64 \
  && chmod +x /usr/local/bin/confd

COPY conf.d /etc/confd/conf.d
COPY templates /etc/confd/templates
 
RUN mkdir -p /home/postgres/restore && chown -R postgres /home/postgres
COPY /docker-entrypoint.sh /
USER postgres
WORKDIR /home/postgres

ENTRYPOINT ["/docker-entrypoint.sh"]
