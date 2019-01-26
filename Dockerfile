#  scp ~/source/dockerfiles/xoa/* root@10.8.0.1:/root/xoa/; ssh root@10.8.0.1 'cd ~/xoa; docker build -t xoacomm:latest ./'

# root@10.8.0.1 'docker run -i -t xoacomm:latest /bin/bash'

# https://xen-orchestra.com/docs/from_the_sources.html

# [INFO] Default user: "admin@admin.net" with password "admin"

# del debian con node 8
FROM node:8-jessie

# instala las dependencias
RUN apt-get update
RUN apt-get install -y build-essential redis-server libpng-dev git python-minimal lvm2 

# limpia la porquería
RUN apt-get autoremove -qq && apt-get clean && rm -rf /usr/share/doc /usr/share/man /var/log/* /tmp/*

# crea el directorio donde loguea redis
RUN mkdir /var/log/redis/
RUN chmod a+wrx -R /var/log/redis

# clona el repositorio de git
RUN git clone -b master http://github.com/vatesfr/xen-orchestra

# compila la aplicación
RUN cd xen-orchestra && yarn && yarn build

# mete el xo-server.toml en el directorio del xoa
COPY xo-server.toml xen-orchestra/packages/xo-server/.xo-server.toml

# los puertos
EXPOSE 80
EXPOSE 443

# arranca!
WORKDIR /xen-orchestra/packages/xo-server/
ENTRYPOINT ["/bin/bash", "-c"]
CMD ["service redis-server start && yarn start"]