#!/bin/sh

echo $0

exit 0

# instala todo
apt-get update
apt-get install -y build-essential redis-server libpng-dev git python-minimal lvm2 

# compila la aplicación (instala las librerías de npm)
git clone -b master http://github.com/vatesfr/xen-orchestra
cd xen-orchestra
yarn
yarn build

# eliminar las herramientas de compilación, pesan con cojone
apt-get purge -y --auto-remove build-essential make gcc
apt-get autoremove -qq

# elimina la caché de apt
apt-get clean

# elimina directorios innecesarios para adelgazar aún más el contenedor
rm -rf /var/lib/apt/lists/* /usr/share/doc /usr/share/man /var/log/* /tmp/* /var/cache/apt/archives/* && \

# vuelve a crear el directorio donde loguea redis
mkdir /var/log/redis/ && chmod a+wrx -R /var/log/redis