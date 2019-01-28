#  scp ~/source/dockerfiles/xoa/* root@10.8.0.1:/root/xoa/; ssh root@10.8.0.1 'cd ~/xoa; docker build -t xoacomm:latest ./'

# root@10.8.0.1 'docker run -i -t xoacomm:latest /bin/bash'

# https://xen-orchestra.com/docs/from_the_sources.html

# [INFO] Default user: "admin@admin.net" with password "admin"

# el nodejs versión 8 con debian jessie
FROM node:8-jessie

# instala las dependencias
RUN apt-get update
RUN apt-get install -y build-essential redis-server libpng-dev git python-minimal lvm2 

# clona el repositorio de git con el código fuente
RUN git clone -b master http://github.com/vatesfr/xen-orchestra

# compila la aplicación (instala las librerías de npm)
RUN cd xen-orchestra && yarn && yarn build


# TODO borrar lo innecesario de node_packages usando find
#      por ejemplo los directorios test/ me sobran todos
# RUN find xen-orchestra/ -type d -iname test

# TODO, esto no está probado
# eliminar las herramientas de compilación, pesan con cojone
RUN apt-get remove -y build-essential

# limpia la porquería
RUN apt-get autoremove -qq && apt-get clean

# elimina directorios grandes que tienen cosas prescindibles
RUN rm -rf /var/lib/apt/lists/* /usr/share/doc /usr/share/man /var/log/* /tmp/* /var/cache/apt/archives/*

# vuelve a crear el directorio donde se loguea redis, si no, no pinchará
RUN mkdir /var/log/redis/
RUN chmod a+wrx -R /var/log/redis

# mete el xo-server.toml en el directorio del xoa
# el fichero no puede llamarse .xo-server.toml localmente, porque docker se marea con la ruta
COPY xo-server.toml xen-orchestra/packages/xo-server/.xo-server.toml

# los puertos
EXPOSE 80
EXPOSE 443

# exporta los datos de xo-server pa que se salven
VOLUME ["/var/lib/xo-server/data"]

# arranca!
WORKDIR /xen-orchestra/packages/xo-server/
ENTRYPOINT ["/bin/bash", "-c"]
CMD ["service redis-server start && yarn start"]