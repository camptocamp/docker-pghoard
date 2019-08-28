FROM postgres:10
MAINTAINER Camptocamp <docker@camptocamp.com>

# pghoard release 2.1.0: 9c682141bdc2fd98d6fbd60c4ff7cd0811536d53
ENV DEBIAN_FRONTEND=noninteractive \
  HOME=/home/postgres \
  CONFD_VERSION=0.14.0 \
  PGHOARD_VERSION=9c682141bdc2fd98d6fbd60c4ff7cd0811536d53 \
  PGHOARD_BASEBACKUP_COUNT=1 \
  PGHOARD_BASEBACKUP_INTERVAL_HOURS=24 \
  PGHOARD_LOG_LEVEL=INFO \
  PGHOARD_STATSD_PORT=8125 \
  PGHOARD_STATSD_FORMAT=telegraf \
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
  && curl -sSL https://bootstrap.pypa.io/get-pip.py | python3 \
  && pip3 install \
     git+https://github.com/aiven/pghoard.git@${PGHOARD_VERSION} \
     idna awscli boto python-keystoneclient python-swiftclient \
  && rm -fr /home/postgres/.cache \
  && apt-get -y remove gcc python2.7 \
  && apt-get -y autoremove \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

RUN curl -L -o /usr/local/bin/confd https://github.com/kelseyhightower/confd/releases/download/v${CONFD_VERSION}/confd-${CONFD_VERSION}-linux-amd64 \
  && chmod +x /usr/local/bin/confd

# Install Gosu
ENV GOSU_VERSION 1.9
RUN set -x \
    && apt-get update && apt-get install -y --no-install-recommends ca-certificates wget && rm -rf /var/lib/apt/lists/* \
    && dpkgArch="$(dpkg --print-architecture | awk -F- '{ print $NF }')" \
    && wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch" \
    && wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch.asc" \
    && export GNUPGHOME="$(mktemp -d)" \
    && gpg --keyserver keyserver.ubuntu.com --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 \
    && gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu \
    && pkill -9 gpg-agent \
    && pkill -9 dirmngr \
    && rm -r "$GNUPGHOME" /usr/local/bin/gosu.asc \
    && chmod +x /usr/local/bin/gosu \
    && gosu nobody true \
    && rm -rf /var/lib/apt/lists/*

# pghoard 1.6.0 check for the existence of PG_VERSION in pg_data_directory...
RUN mkdir -p /home/postgres/restore && \
  echo $PG_MAJOR > /home/postgres/restore/PG_VERSION && \
  chgrp -R 0 /home/postgres && \
  chmod -R g=u /home/postgres

COPY conf.d /etc/confd/conf.d
COPY templates /etc/confd/templates

COPY /*.sh /
WORKDIR /home/postgres

VOLUME [ "/home/postgres/pghoard", "/var/lib/pghoard" ]

EXPOSE 16000
ENTRYPOINT ["/docker-entrypoint.sh"]
