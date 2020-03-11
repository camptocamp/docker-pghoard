FROM postgres:10
MAINTAINER Camptocamp <docker@camptocamp.com>

# pghoard release 2.1.0: 9c682141bdc2fd98d6fbd60c4ff7cd0811536d53
ENV DEBIAN_FRONTEND=noninteractive \
  HOME=/home/postgres \
  CONFD_VERSION=0.14.0 \
  PGHOARD_VERSION=14d082d \
  PGHOARD_BASEBACKUP_COUNT=1 \
  PGHOARD_BASEBACKUP_INTERVAL_HOURS=24 \
  PGHOARD_BASEBACKUP_HOUR=2 \
  PGHOARD_BASEBACKUP_MINUTE=20 \
  PGHOARD_LOG_LEVEL=INFO \
  PGHOARD_STATSD_PORT=8125 \
  PGHOARD_STATSD_FORMAT=telegraf \
  WAITFORIT_VERSION=54d1f0bfeb6557adf8a3204455389d0901652242 \
  WAITFORIT_SHA=3f3790f899f53d1a10947f0b992b122a358ffa34997d8c0fe126a02bba806917 \
  PG_PORT=5432 \
  REPLICATION_SLOT_NAME=pghoard

RUN apt-get update \
  && apt-get -y --no-install-suggests --no-install-recommends install \
     gcc \
     g++ \
     git \
     make \
     libffi-dev \
     curl \
     ca-certificates \
     rsync \
     libsnappy-dev \
     libssl-dev \
     python3 \
     python3-setuptools \
     python3-dev \
     libpq-dev \
     jq \
     locales-all \
  && curl -sSL https://bootstrap.pypa.io/get-pip.py | python3 \
  && pip3 install \
     git+https://github.com/camptocamp/pghoard.git@${PGHOARD_VERSION} \
     idna awscli boto python-keystoneclient python-swiftclient \
  && rm -fr /home/postgres/.cache \
  && apt-get -y remove gcc python2.7 \
  && apt-get -y autoremove \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

RUN curl -L -o /usr/local/bin/confd https://github.com/kelseyhightower/confd/releases/download/v${CONFD_VERSION}/confd-${CONFD_VERSION}-linux-amd64 \
  && chmod +x /usr/local/bin/confd

# Install wait-for-it (restoration)
RUN curl -L -o /usr/local/bin/wait-for-it.sh https://raw.githubusercontent.com/vishnubob/wait-for-it/${WAITFORIT_VERSION}/wait-for-it.sh \
  && chmod +x /usr/local/bin/wait-for-it.sh && [ $(sha256sum /usr/local/bin/wait-for-it.sh | cut -f1 -d' ') = ${WAITFORIT_SHA} ]

# pghoard 1.6.0 check for the existence of PG_VERSION in pg_data_directory...
RUN mkdir -p /home/postgres/restore && \
  echo $PG_MAJOR > /home/postgres/restore/PG_VERSION && \
  chgrp -R 0 /home/postgres && \
  chmod -R g=u /home/postgres && \
  mkdir /etc/pghoard

COPY conf.d /etc/confd/conf.d
COPY templates /etc/confd/templates

COPY /*.sh /
WORKDIR /home/postgres

VOLUME [ "/home/postgres/pghoard", "/var/lib/pghoard" ]

EXPOSE 16000
ENTRYPOINT ["/docker-entrypoint.sh"]
