
## REQUISITOS PREVIOS ********************************************************##
# Crear directorio para instalación, cada nuevo paquete se instala en este directorio.
mkdir cartodb-inst
chmod +w cartodb-inst
chmod +x cartodb-inst
cd cartodb-inst
# Configurar UTF-8
sudo locale-gen en_US.UTF-8
sudo update-locale LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8
# Instalación de Paquetes precios necesarios
sudo apt-get install autoconf binutils-doc bison build-essential flex
# Instalación de GIT
sudo apt-get install git
# Se sugiere instalar esta herramienta
sudo apt-get install python-software-properties
##****************************************************************************##

##  PostgreSQL ***************************************************************##
# Añadir repositorios (PostgreSQL)
sudo add-apt-repository ppa:cartodb/postgresql-9.3 && sudo apt-get update
# Instalación de los paquetes de clientes de PostgreSQL
sudo apt-get install libpq5 \
                     libpq-dev \
                     postgresql-client-9.3 \
                     postgresql-client-common
# Instalación de los paquetes del servidor de PostgreSQL
sudo apt-get install postgresql-9.3 \
                     postgresql-contrib-9.3 \
                     postgresql-server-dev-9.3 \
                     postgresql-plpython-9.3
# Hay que añadir el acceso sin password.
sudo vim /etc/postgresql/9.3/main/pg_hba.conf
# Para ello se tiene que añadir dichas lineas al archivo:
# Nótese que deben añadirse en el hueco que el fichero te facilita,
# sino causará error.
#local   all             postgres                                trust
#local   all             all                                     trust
#host    all             all             127.0.0.1/32            trust
# Para que haga efecto, se reinicia el servicio
sudo service postgresql restart
# Creación de usuarios que usa cartodb
sudo createuser publicuser --no-createrole --no-createdb --no-superuser -U postgres
sudo createuser tileuser --no-createrole --no-createdb --no-superuser -U postgres
# Instalación de la extensión de CartoDB postgresql.
git clone https://github.com/CartoDB/cartodb-postgresql.git
cd cartodb-postgresql
git checkout <LATEST cartodb-postgresql tag>
sudo make all install
##****************************************************************************##

## Dependencias-GIS **********************************************************##
# Añadir repositorios
sudo add-apt-repository ppa:cartodb/gis && sudo apt-get update
# Instalar Proj
sudo apt-get install proj proj-bin proj-data libproj-dev
# Instalar JSON
sudo apt-get install libjson0 libjson0-dev python-simplejson
# Instalar GEOS
sudo apt-get install libgeos-c1v5 libgeos-dev
# Instalar GDAL
sudo apt-get install gdal-bin libgdal1-dev libgdal-dev
sudo apt-get install ogr2ogr2-static-bin
##****************************************************************************##

## PostGIS *******************************************************************##
# Instalar PostGIS
sudo apt-get install libxml2-dev
sudo apt-get install liblwgeom-2.1.8 postgis postgresql-9.3-postgis-2.2 postgresql-9.3-postgis-scripts
# Inicializar la base de datos postgis y crear el template.
sudo createdb -T template0 -O postgres -U postgres -E UTF8 template_postgis
sudo createlang plpgsql -U postgres -d template_postgis
psql -U postgres template_postgis -c 'CREATE EXTENSION postgis;CREATE EXTENSION postgis_topology;'
sudo ldconfig
# Verificacion de la instalación y la base de datos.
sudo PGUSER=postgres make installcheck
# *NOTA* aunque dé que alguna consulta tiene error, no debe pasar nada.
# Restauramos el servicio de postgresql
sudo service postgresql restart
##****************************************************************************##

## Redis *********************************************************************##
# Añadir repositorios
sudo add-apt-repository ppa:cartodb/redis && sudo apt-get update
# Instalar Redis
sudo apt-get install redis-server
##

## NodeJS
# Añadir repositorios
sudo add-apt-repository ppa:cartodb/nodejs-010 && sudo apt-get update
# Instalar node.js
sudo apt-get install nodejs
# Comprobación de vesrsiones: NoddeJS=0.10.26; npm=2.14.16+
nodejs -v
npm -v
# Si npm es inferior, hay que actualizqar!
sudo npm update -g
# Si se comprueba otra vez, la versión debe ser la buena.
##****************************************************************************##

# SQL-API*********************************************************************##
# Descarga la API de git
git clone git://github.com/CartoDB/CartoDB-SQL-API.git
cd CartoDB-SQL-API
git checkout master
# Instalar dependencias npm
npm install
# Crear configuración, se copia el example.
cp config/environments/development.js.example config/environments/development.js
# Arrancar Servicio: (Comprobación de que todo ha ido bien)
node app.js development
##****************************************************************************##

## MAPS API*******************************************************************##
# Descargar la API de GIT
git clone git://github.com/CartoDB/Windshaft-cartodb.git
cd Windshaft-cartodb
git checkout master
# Instalacion de este paquete, ya que el npm install falla (Cairo)
sudo apt-get install libpango1.0-dev
# Instalar dependencias npm
npm install
# Crear configuración, se copia el example.
cp config/environments/development.js.example config/environments/development.js
# Arrancar Servicio: (Comprobación de que todo ha ido bien)
node app.js development
##****************************************************************************##

## Ruby **********************************************************************##
# Descarga de "ruby-install"
wget -O ruby-install-0.5.0.tar.gz https://github.com/postmodern/ruby-install/archive/v0.5.0.tar.gz
tar -xzvf ruby-install-0.5.0.tar.gz
cd ruby-install-0.5.0/
sudo make install
# Instalar dependencias ruby
sudo apt-get install libreadline6-dev openssl
# Instalar Ruby 2.2.3
sudo ruby-install ruby 2.2.3
# Añadir variable de entorno (Se aconseja añadira también al bashrc)
export PATH=$PATH:/opt/rubies/ruby-2.2.3/bin
# Instalar rvmsudo, para ejecutar bien el gem
sudo apt-get install ruby-rvm
# Instalar Bundle - Paquete para manegar dependencias ruby
rvmsudo gem install bundler
# Instalar Compass
rvmsudo gem install compass
##****************************************************************************##

## Editor ********************************************************************##
# Descargar Editor
git clone --recursive https://github.com/CartoDB/cartodb.git
cd cartodb
# Instalr pip
sudo wget  -O /tmp/get-pip.py https://bootstrap.pypa.io/get-pip.py
sudo python /tmp/get-pip.py
# Instalar dependencias python
sudo apt-get install python-all-dev
# Añadir variables entorno (Esto aun así podría fallar)
export CPLUS_INCLUDE_PATH=/usr/include/gdal
export C_INCLUDE_PATH=/usr/include/gdal
export PATH=$PATH:/usr/include/gdal
# Instalar dependencias
sudo apt-get install imagemagick unp zip
RAILS_ENV=development bundle install
npm install
sudo pip install --no-use-wheel -r python_requirements.txt
# Añadir grunt al PATH también
export PATH=$PATH:$PWD/node_modules/grunt-cli/bin
# Instalar gemas necesarias
bundle install
# Precompilar y arrancar.
bundle exec grunt --environment development
# Crear archivos de configuracion
cp config/app_config.yml.sample config/app_config.yml
cp config/database.yml.sample config/database.yml
# Inicializar la base de datos de metadatos.
RAILS_ENV=development bundle exec rake db:migrate
RAILS_ENV=development bundle exec rake db:setup
# Si no funciona, ejecutar bundle exec rake db:migrate
# Crear admin user, si no funciona se elimina el RAILS_ENV = development
RAILS_ENV=development bundle exec rake db:setup_user
# inicializar servidor redis, para bakcground añadir &
redis-server &
# En otra consola, ya que el servidor estaría corriendo...
# Añadir el editor HTTP server
RAILS_ENV=development bundle exec rails server
# En otra consola, arrancar el script resque
RAILS_ENV=development bundle exec ./script/resque
##****************************************************************************##

## CREACIÓN DE ENTORNO Y USUARIO, AÑADIR A HOSTS LA IP ***********************##RE
cd cartodb
export SUBDOMAIN=development
# Add entries to /etc/hosts needed in development
echo "127.0.0.1 ${SUBDOMAIN}.localhost.lan" | sudo tee -a /etc/hosts
# Create a development user
sh script/create_dev_user ${SUBDOMAIN}
# Te pide que ingreses usuario - password - etc
##****************************************************************************##

## NOTAS FINALES
## DESACTIVAR FIREWALL EN MÁQUINA VIRTUAL!
# sudo service ufw stop
## En máquina real:
# Añadir al /etc/hosts
# 127.0.0.1 development.localhost.lan
##

# FIN!
