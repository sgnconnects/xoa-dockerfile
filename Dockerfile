FROM node:8-jessie
# el nodejs versión 8 con debian jessie


# docker build --force-rm --rm -t etecsaweb:latest ./

# [INFO] Default user: "admin@admin.net" with password "admin"


# https://xen-orchestra.com/docs/from_the_sources.html
RUN apt-get update && \
    apt-get install -y build-essential redis-server libpng-dev git python-minimal lvm2  && \
    git clone -b master http://github.com/vatesfr/xen-orchestra && \
    cd xen-orchestra && yarn && yarn build && \
    apt-get purge -y --auto-remove build-essential make gcc && \
    apt-get autoremove -qq && apt-get clean && \
    rm -rf /var/lib/apt/lists/* /usr/share/doc /usr/share/man /var/log/* /tmp/* /var/cache/apt/archives/* && \
    mkdir /var/log/redis/

# mete el xo-server.toml en el directorio del xoa
COPY xo-server.toml xen-orchestra/packages/xo-server/.xo-server.toml

# servidor web
EXPOSE 80

# los datos del xoa se pueden salvar afuera
# quizás quiera usar un xo-server.toml personalizado así que pa afuera también
VOLUME ["/var/lib/xo-server/data","/opt/xen-orchestra/packages/xo-server/.xo-server.toml"]

# arranca!
WORKDIR /opt/xen-orchestra/packages/xo-server/
ENTRYPOINT ["/bin/bash", "-c"]
CMD ["service redis-server start && yarn start"]