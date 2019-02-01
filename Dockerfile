# https://xen-orchestra.com/docs/from_the_sources.html

# [INFO] Default user: "admin@admin.net" with password "admin"

# el nodejs versión 8 con debian jessie
FROM node:8-jessie

# quién soy
LABEL Description="Xen Orchestra in Docker" Vendor="ChipojoSoft" Version="0.5"

# ejecuta el script que instala todo
COPY install.sh /opt/
RUN /bin/sh /opt/install.sh && rm /opt/install.sh

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