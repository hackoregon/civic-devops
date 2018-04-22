#! /bin/bash

# command line tools
# Note: not yet clear what purpose these packages serve for this script
sudo yum install -y \
git \
lynx \
procps-ng \
shadow-utils \
  && sudo yum clean all \
  && sudo rm -rf /var/cache/yum

# PostGIS build dependencies
# Note: https://trac.osgeo.org/postgis/wiki/UsersWikiPostGIS24Debian9src indicates json-c-devel and libxml2-dev are required
#       and PROJ and GDAL are indicated as well (which explains their inclusion as source)
#       Can't see why the rest of these packages are necessary for PostGIS
sudo yum update -y \
  && sudo yum install -y \
    boost-devel \
    gcc \
    gcc-c++ \
    gettext-devel \
    gmp-devel \
    json-c-devel \
    libxml2-devel \
    mpfr-devel \
  && sudo yum clean all \
  && sudo rm -rf /var/cache/yum

# setup for builds
PKG_CONFIG_PATH="/usr/local/lib/pkgconfig"
echo "/usr/local/lib" > /etc/ld.so.conf.d/usr_local_lib.conf \
  && mkdir -p /usr/local/src/
cd /usr/local/src/

# source installs
# CMAKE required for CGAL
CMAKE_MAJOR_VERSION="3.10"
CMAKE_VERSION="${CMAKE_MAJOR_VERSION}.2"
wget -q https://cmake.org/files/v${CMAKE_MAJOR_VERSION}/cmake-${CMAKE_VERSION}-Linux-x86_64.sh \
  && chmod +x cmake-${CMAKE_VERSION}-Linux-x86_64.sh \
  && ./cmake-${CMAKE_VERSION}-Linux-x86_64.sh --prefix=/usr/local --exclude-subdir --skip-license

# ? Why is this necessary for PostGIS?
CGAL_VERSION="4.11.1"
wget -q https://github.com/CGAL/cgal/archive/releases/CGAL-${CGAL_VERSION}.tar.gz \
  && tar xf CGAL-${CGAL_VERSION}.tar.gz \
  && cd cgal-releases-CGAL-${CGAL_VERSION} \
  && cmake . > ../cgal.cmake \
  && make \
  && sudo make install \
  && ldconfig

# ? Why is this necessary for PostGIS?
PROTOBUF_VERSION="3.5.1"
wget -q https://github.com/google/protobuf/releases/download/v${PROTOBUF_VERSION}/protobuf-cpp-${PROTOBUF_VERSION}.tar.gz \
  && tar xf protobuf-cpp-${PROTOBUF_VERSION}.tar.gz \
  && cd /usr/local/src/protobuf-${PROTOBUF_VERSION} \
  && ./configure > ../protobuf.configure \
  && make > /dev/null \
  && sudo make install > /dev/null \
  && ldconfig

# ? Why is this necessary for PostGIS?
PROTOBUF_C_VERSION="1.3.0"
wget -q https://github.com/protobuf-c/protobuf-c/releases/download/v${PROTOBUF_C_VERSION}/protobuf-c-${PROTOBUF_C_VERSION}.tar.gz \
  && tar xf protobuf-c-${PROTOBUF_C_VERSION}.tar.gz \
  && cd /usr/local/src/protobuf-c-${PROTOBUF_C_VERSION} \
  && ./configure > ../protobuf-c.configure \
  && make > /dev/null \
  && sudo make install > /dev/null \
  && ldconfig

# ? Why is this necessary for PostGIS?
GEOS_VERSION="3.6.2"
wget -q http://download.osgeo.org/geos/geos-${GEOS_VERSION}.tar.bz2 \
  && tar xf geos-${GEOS_VERSION}.tar.bz2 \
  && cd /usr/local/src/geos-${GEOS_VERSION} \
  && ./configure > ../geos.configure \
  && make > /dev/null \
  && sudo make install > /dev/null \
  && ldconfig

# PROJ required for PostGIS
PROJ_VERSION="4.9.3"
DATUMGRID_VERSION="1.6"
wget -q http://download.osgeo.org/proj/proj-${PROJ_VERSION}.tar.gz \
  && tar xf proj-${PROJ_VERSION}.tar.gz \
  && wget -q http://download.osgeo.org/proj/proj-datumgrid-${DATUMGRID_VERSION}.zip \
  && cd /usr/local/src/proj-${PROJ_VERSION} \
  && ./configure > ../proj.configure \
  && make > /dev/null \
  && sudo make install > /dev/null \
  && ldconfig \
  && cd /usr/local/share/proj/ \
  && unzip /usr/local/src/proj-datumgrid-${DATUMGRID_VERSION}.zip

# GDAL required for PostGIS
GDAL_VERSION="2.2.4"
wget -q http://download.osgeo.org/gdal/${GDAL_VERSION}/gdal-${GDAL_VERSION}.tar.gz \
  && tar xf gdal-${GDAL_VERSION}.tar.gz \
  && cd /usr/local/src/gdal-${GDAL_VERSION} \
  && ./configure > ../gdal.configure \
  && make > /dev/null \
  && sudo make install > /dev/null \
  && ldconfig

POSTGIS_VERSION="2.4.3"
wget -q https://download.osgeo.org/postgis/source/postgis-${POSTGIS_VERSION}.tar.gz \
  && tar xf postgis-${POSTGIS_VERSION}.tar.gz \
  && cd /usr/local/src/postgis-${POSTGIS_VERSION} \
  && ./configure > ../postgis.configure \
  && make > /dev/null \
  && sudo make install > /dev/null \
  && ldconfig

# ? Why is this necessary for PostGIS?
PGROUTING_VERSION="2.5.2"
yum install -y perl-Data-Dumper
# use of curl to add a prefix to the downloaded filename
curl -Ls https://github.com/pgRouting/pgrouting/archive/v${PGROUTING_VERSION}.tar.gz \
  > pgrouting-${PGROUTING_VERSION}.tar.gz \
  && tar xf pgrouting-${PGROUTING_VERSION}.tar.gz \
  && cd pgrouting-${PGROUTING_VERSION} \
  && mkdir build \
  && cd build \
  && cmake .. > ../../pgrouting.cmake \
  && make > ../../pgrouting.make \
  && sudo make install > /dev/null \
  && ldconfig
