# https://xen-orchestra.com/docs/from_the_sources.html

# [INFO] Default user: "admin@admin.net" with password "admin"

# el nodejs versión 8 con debian jessie
FROM node:8-jessie

# quién soy
LABEL Description="Xen Orchestra in Docker" Vendor="ChipojoSoft" Version="0.5"

# instala las dependencias
RUN apt-get update && \
    apt-get install -y build-essential redis-server libpng-dev git python-minimal lvm2 

# - clona el repositorio de git con el código fuente
# - compila la aplicación (instala las librerías de npm)
RUN git clone -b master http://github.com/vatesfr/xen-orchestra && \
    cd xen-orchestra && yarn && yarn build

# bajando de peso
# - eliminar las herramientas de compilación, pesan con cojone
# - limpia la caché de APT
# - elimina directorios que son innecesarios
# - vuelve a crear el directorio donde se loguea redis
RUN apt-get purge -y --auto-remove build-essential make gcc &&\
    apt-get autoremove -qq && apt-get clean && \
    rm -rf /var/lib/apt/lists/* /usr/share/doc /usr/share/man /var/log/* /tmp/* /var/cache/apt/archives/* && \
    mkdir /var/log/redis/ && chmod a+wrx -R /var/log/redis

# mete el xo-server.toml en el directorio del xoa
# el fichero no puede llamarse .xo-server.toml localmente, porque docker se marea con la ruta
COPY xo-server.toml xen-orchestra/packages/xo-server/.xo-server.toml

# abre el 80
EXPOSE 80

# exporta los datos de xo-server pa que se salven
VOLUME /var/lib/xo-server/data

# arranca!
WORKDIR /xen-orchestra/packages/xo-server/
ENTRYPOINT ["/bin/bash", "-c"]
CMD ["service redis-server start && yarn start"]