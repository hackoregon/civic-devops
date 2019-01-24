#!/usr/bin/bash

# 
# script must be run after initializing proper environment and permissions by using
# sudo su -
# 

# Place all logs in directory this script is run from
LOGDIR=${PWD}

# command line tools
# Note: not yet clear what purpose these packages serve for this script
#
echo "Running Yum install of git, lynx, procps-ng, shadow-utils."
yum install -y \
git \
lynx \
procps-ng \
shadow-utils > ${LOGDIR}/yum-install.log1 2>&1
if [ $? -ne 0 ]; then
  echo "Yum install failed, check ${LOGDIR}/yum-install.log1"
  exit 1
else
  echo "Yum install of git, lynx, procps-ng, shadow-utils successful."
fi

echo "Cleaning Yum and removing cache."
yum clean all >> ${LOGDIR}/yum-install.log1 2>&1
rm -rf /var/cache/yum

# PostGIS build dependencies
# Note: https://trac.osgeo.org/postgis/wiki/UsersWikiPostGIS24Debian9src indicates json-c-devel and libxml2-dev are required
#       and PROJ and GDAL are indicated as well (which explains their inclusion as source)
#       Can't see why the rest of these packages are necessary for PostGIS
#
echo "Running Yum update to update OS."
yum update -y > ${LOGDIR}/yum-update.log 2>&1
if [ $? -ne 0 ]; then
  echo "Yum update of OS failed, check ${LOGDIR}/yum-update.log"
  exit 1
else
  echo "Yum update of OS successful."
fi

echo "Running Yum install of PostGIS build dependencies."
yum install -y \
    boost-devel \
    gcc \
    gcc-c++ \
    gettext \
    gettext-devel \
    gmp-devel \
    json-c-devel \
    libxml2 \
    libxml2-devel \
    python-devel \
    libpcap \
    libpcap-devel \
    libnet \
    libnet-devel \
    pcre \
    pcre-devel \
    libtool \
    make \
    libyaml \
    libyaml-devel \
    binutils \
    zlib \
    zlib-devel \
    file-devel \
    postgresql \
    postgresql-devel \
    postgresql-contrib \
    geoip \
    geoip-devel \
    graphviz \
    graphviz-devel \
    libtiff-devel \
    libjpeg-devel \
    libzip-devel \
    freetype-devel \
    lcms2-devel \
    libwebp-devel \
    tcl-devel \
    tk-devel \
    mpfr-devel > ${LOGDIR}/yum-install.log2 2>&1
if [ $? -ne 0 ]; then
  echo "Yum install of PostGIS dependencies failed, check ${LOGDIR}/yum-install.log2"
  exit 1
else
  echo "Yum install of PostGIS build dependencies successful."
fi

echo "Cleaning Yum and removing cache."   
yum clean all >> ${LOGDIR}/yum-install.log2 2>&1
rm -rf /var/cache/yum

# setup for builds
echo "Setting environment for builds."
export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig
echo "/usr/local/lib" > /etc/ld.so.conf.d/usr_local_lib.conf

echo "Create and change directory to /usr/local/src"
mkdir -p /usr/local/src/
cd /usr/local/src/

# source installs
# CMAKE required for CGAL
#
CMAKE_MAJOR_VERSION="3.10"
CMAKE_VERSION="${CMAKE_MAJOR_VERSION}.2"

echo "Fetching and building CMAKE Version ${CMAKE_VERSION} for support of CGAL"
wget -q https://cmake.org/files/v${CMAKE_MAJOR_VERSION}/cmake-${CMAKE_VERSION}-Linux-x86_64.sh > ${LOGDIR}/cmake.log 2>&1
if [ $? -ne 0 ]; then
  echo "Fetch of CMAKE version ${CMAKE_VERSION} failed, check ${LOGDIR}/cmake.log"
  exit 1
else
  echo "Fetch of CMAKE successful."
fi

echo "Building CMAKE"
chmod +x cmake-${CMAKE_VERSION}-Linux-x86_64.sh >> ${LOGDIR}/cmake.log 2>&1
./cmake-${CMAKE_VERSION}-Linux-x86_64.sh --prefix=/usr/local --exclude-subdir --skip-license >> ${LOGDIR}/cmake.log 2>&1
if [ $? -ne 0 ]; then
  echo "Build of CMAKE failed, check ${LOGDIR}/cmake.log"
  exit 1
else
  echo "Build of CMAKE successful."
fi

# ? Why is this necessary for PostGIS?
CGAL_VERSION="4.11.1"

echo "Fetching and building CGAL Version ${CGAL_VERSION}"
wget -q https://github.com/CGAL/cgal/archive/releases/CGAL-${CGAL_VERSION}.tar.gz > ${LOGDIR}/cgal.log 2>&1
if [ $? -ne 0 ]; then
  echo "Fetch of CGAL CGAL-${CGAL_VERSION}.tar.gz failed, check ${LOGDIR}/cgal.log"
  exit 1
else
  echo "Fetch of CGAL successful."
fi

echo "Unpacking CGAL-${CGAL_VERSION}.tar.gz"
tar xf CGAL-${CGAL_VERSION}.tar.gz >> ${LOGDIR}/cgal.log 2>&1
if [ $? -ne 0 ]; then
  echo "Unpack of CGAL failed, check ${LOGDIR}/cgal.log"
  exit 1
else
  echo "Unpack of CGAL successful."
fi

echo "Change directory to cgal-releases-CGAL-${CGAL_VERSION}"
cd cgal-releases-CGAL-${CGAL_VERSION} 

echo "Running CMAKE on cgal-releases-CGAL-${CGAL_VERSION}"
cmake . >> ${LOGDIR}/cgal.log 2>&1
if [ $? -ne 0 ]; then
  echo "Running CMAKE on CGAL failed, check ${LOGDIR}/cgal.log"
  exit 1
else
  echo "Running CMAKE on CGAL successful."
fi

echo "Running MAKE on CGAL"
make >> ${LOGDIR}/cgal.log 2>&1
if [ $? -ne 0 ]; then
  echo "Build of CGAL failed, check ${LOGDIR}/cgal.log"
  exit 1
else
  echo "Build of CGAL successful."
fi

echo "Installing CGAL"
make install >> ${LOGDIR}/cgal.log 2>&1
if [ $? -ne 0 ]; then
  echo "Install of CGAL failed, check ${LOGDIR}/cgal.log"
  exit 1
else
  echo "Install of CGAL successful."
fi

echo "Updating LDCONFIG"
ldconfig

cd /usr/local/src/

# ? Why is this necessary for PostGIS?
PROTOBUF_VERSION="3.5.1"

echo "Fetching and building PROTOBUF Version ${PROTOBUF_VERSION}"
wget -q https://github.com/google/protobuf/releases/download/v${PROTOBUF_VERSION}/protobuf-cpp-${PROTOBUF_VERSION}.tar.gz > ${LOGDIR}/protobuf.log 2>&1
if [ $? -ne 0 ]; then
  echo "Fetch of protobuf-cpp-${PROTOBUF_VERSION}.tar.gz failed, check ${LOGDIR}/protobuf.log"
  exit 1
else
  echo "Fetch of PROTOBUF successful."
fi

echo "Unpacking protobuf-cpp-${PROTOBUF_VERSION}.tar.gz"
tar xf protobuf-cpp-${PROTOBUF_VERSION}.tar.gz >> ${LOGDIR}/protobuf.log 2>&1
if [ $? -ne 0 ]; then
  echo "Unpack of PRTOTOBUF failed, check ${LOGDIR}/protobuf.log"
  exit 1
else
  echo "Unpack of protobuf successful."
fi

echo "Changing directory to protobuf-${PROTOBUF_VERSION}"
cd /usr/local/src/protobuf-${PROTOBUF_VERSION}

echo "Configuring PROTOBUF"
./configure > ${LOGDIR}/protobuf.configure 2>&1 
if [ $? -ne 0 ]; then
  echo "Configure of PROTOBUF failed, check ${LOGDIR}/protobuf.configure"
  exit 1
else
  echo "Configure of protobuf successful."
fi

echo "Building PROTOBUF"
make >> ${LOGDIR}/protobuf.log 2>&1
if [ $? -ne 0 ]; then
  echo "Build of PROTOBUF failed, check ${LOGDIR}/protobuf.log"
  exit 1
else
  echo "Build of PROTOBUF successful."
fi

echo "Installing PROTOBUF"
make install >> ${LOGDIR}/protobuf.log 2>&1
if [ $? -ne 0 ]; then
  echo "Install of PROTOBUF failed, check ${LOGDIR}/protobuf.log"
  exit 1
else
  echo "Install of PROTOBUF successful."
fi

echo "Updating LDCONFIG"
ldconfig

cd /usr/local/src/

# ? Why is this necessary for PostGIS?
PROTOBUF_C_VERSION="1.3.0"

echo "Fetching and building PROTOBUF-C version ${PROTOBUF_C_VERSION}"
wget -q https://github.com/protobuf-c/protobuf-c/releases/download/v${PROTOBUF_C_VERSION}/protobuf-c-${PROTOBUF_C_VERSION}.tar.gz > ${LOGDIR}/protobuf-c.log 2>&1
if [ $? -ne 0 ]; then
  echo "Fetch of protobuf-c-${PROTOBUF_C_VERSION}.tar.gz failed, check ${LOGDIR}/protobuf-c.log"
  exit 1
else
  echo "Fetch of PROTOBUF-C successful."
fi

echo "Unpacking protobuf-c-${PROTOBUF_C_VERSION}.tar.gz"
tar xf protobuf-c-${PROTOBUF_C_VERSION}.tar.gz >> ${LOGDIR}/protobuf-c.log 2>&1
if [ $? -ne 0 ]; then
  echo "Unpack of PROTOBUF-C failed, check protobuf-c.log"
  exit 1
else
  echo "Unpack of PROTOBUF-C successful."
fi

echo "Changing directory to protobuf-c-${PROTOBUF_C_VERSION}"
cd /usr/local/src/protobuf-c-${PROTOBUF_C_VERSION}

echo "Configuring PROTOBUF-C"
./configure > ${LOGDIR}/protobuf-c.configure 2>&1
if [ $? -ne 0 ]; then
  echo "Configure of PROTOBUF-C failed, check ${LOGDIR}/protobuf-c.configure"
  exit 1
else
  echo "Configure of PROTOBUF-C successful."
fi

echo "Building PROTOBUF-C"
make >> ${LOGDIR}/protobuf-c.log 2>&1
if [ $? -ne 0 ]; then
  echo "Build of PROTOBUF-C failed, check ${LOGDIR}/protobuf-c.log"
  exit 1
else
  echo "Build of PROTOBUF-C successful."
fi

echo "Installing PROTOBUF-C"
make install >> ${LOGDIR}/protobuf-c.log 2>&1
if [ $? -ne 0 ]; then
  echo "Install of PROTOBUF-C failed, check ${LOGDIR}/protobuf-c.log"
  exit 1
else
  echo "Install of PROTOBUF-C successful."
fi

echo "Updating LDCONFIG"
ldconfig

cd /usr/local/src/

# ? Why is this necessary for PostGIS?
GEOS_VERSION="3.6.2"

echo "Fetching and building GEOS version ${GEOS_VERSION}"
wget -q http://download.osgeo.org/geos/geos-${GEOS_VERSION}.tar.bz2 > ${LOGDIR}/geos.log 2>&1
if [ $? -ne 0 ]; then
  echo "Fetch of geos-${GEOS_VERSION}.tar.bz2 failed, check ${LOGDIR}/geos.log"
  exit 1
else
  echo "Fetch of GEOS successful."
fi

echo "Unpacking geos-${GEOS_VERSION}.tar.bz2"
tar xf geos-${GEOS_VERSION}.tar.bz2 >> ${LOGDIR}/geos.log 2>&1
if [ $? -ne 0 ]; then
  echo "Unpack of GEOS failed, check geos.log"
  exit 1
else
  echo "Unpack of GEOS successful."
fi

echo "Changing directory to geos-${GEOS_VERSION}"
cd /usr/local/src/geos-${GEOS_VERSION}

echo "Configuring GEOS"
./configure > ${LOGDIR}/geos.configure 2>&1
if [ $? -ne 0 ]; then
  echo "Configure of GEOS failed, check ${LOGDIR}/geos.configure"
  exit 1
else
  echo "Configure of GEOS successful."
fi

echo "Building GEOS"
make >> ${LOGDIR}/geos.log 2>&1
if [ $? -ne 0 ]; then
  echo "Build of GEOS failed, check ${LOGDIR}/geos.log"
  exit 1
else
  echo "Build of GEOS successful."
fi

echo "Installing GEOS"
make install >> ${LOGDIR}/geos.log 2>&1
if [ $? -ne 0 ]; then
  echo "Install of GEOS failed, check ${LOGDIR}/geos.log"
  exit 1
else
  echo "Install of GEOS successful."
fi

echo "Updating LDCONFIG"
ldconfig

cd /usr/local/src/

# PROJ required for PostGIS
PROJ_VERSION="4.9.3"
DATUMGRID_VERSION="1.6"

echo "Fetching and building PROJ version ${PROJ_VERSION} and DATUMGRID version ${DATUMGRID_VERSION}"
wget -q http://download.osgeo.org/proj/proj-${PROJ_VERSION}.tar.gz > ${LOGDIR}/proj.log 2>&1
if [ $? -ne 0 ]; then
  echo "Fetch of proj-${PROJ_VERSION}.tar.gz failed, check ${LOGDIR}/proj.log"
  exit 1
else
  echo "Fetch of PROJ successful."
fi

echo "Unpacking proj-${PROJ_VERSION}.tar.gz"
tar xf proj-${PROJ_VERSION}.tar.gz >> ${LOGDIR}/proj.log 2>&1
if [ $? -ne 0 ]; then
  echo "Unpack of PROJ failed, check ${LOGDIR}/proj.log"
  exit 1
else
  echo "Unpack of PROJ successful."
fi

echo "Fetching proj-datumgrid-${DATUMGRID_VERSION}.zip"
wget -q http://download.osgeo.org/proj/proj-datumgrid-${DATUMGRID_VERSION}.zip > ${LOGDIR}/datumgrid.log 2>&1
if [ $? -ne 0 ]; then
  echo "Fetch of proj-datumgrid-${DATUMGRID_VERSION}.zip failed, check ${LOGDIR}/datumgrid.log"
  exit 1
else
  echo "Fetch of PROJ-DATUMGRID successful."
fi

echo "Changing directory to proj-${PROJ_VERSION} "
cd /usr/local/src/proj-${PROJ_VERSION}

echo "Configuring PROJ"
./configure > ${LOGDIR}/proj.configure 2>&1
if [ $? -ne 0 ]; then
  echo "Configure of PROJ failed, check ${LOGDIR}/proj.configure"
  exit 1
else
  echo "Configure of PROJ successful."
fi

echo "Building PROJ"
make >> ${LOGDIR}/proj.log 2>&1
if [ $? -ne 0 ]; then
  echo "Build of PROJ failed, check ${LOGDIR}/proj.log"
  exit 1
else
  echo "Build of PROJ successful."
fi

echo "Installing PROJ"
make install  >> ${LOGDIR}/proj.log 2>&1
if [ $? -ne 0 ]; then
  echo "Install of PROJ failed, check ${LOGDIR}/proj.log"
  exit 1
else
  echo "Install of PROJ successful."
fi

echo "Updating LDCONFIG"
ldconfig

echo "Changing directory to /usr/local/share/proj/"
cd /usr/local/share/proj/

echo "Unpacking proj-datumgrid-${DATUMGRID_VERSION}.zip"
unzip /usr/local/src/proj-datumgrid-${DATUMGRID_VERSION}.zip >> ${LOGDIR}/datumgrid.log 2>&1
if [ $? -ne 0 ]; then
  echo "Unpack of PROJ-DATUMGRID failed, check ${LOGDIR}/datumgrid.log"
  exit 1
else
  echo "Unpack of PROJ-DATUMGRID successful."
fi

cd /usr/local/src/

# GDAL required for PostGIS
GDAL_VERSION="2.2.4"

echo ""
echo "Building of GDAL can take several hours, be patient!"
echo ""

echo "Fetching and building GDAL version ${GDAL_VERSION}"
wget -q http://download.osgeo.org/gdal/${GDAL_VERSION}/gdal-${GDAL_VERSION}.tar.gz > ${LOGDIR}/gdal.log 2>&1
if [ $? -ne 0 ]; then
  echo "Fetch of gdal-${GDAL_VERSION}.tar.gz failed, check ${LOGDIR}/gdal.log"
  exit 1
else
  echo "Fetch of GDAL successful."
fi

tar xf gdal-${GDAL_VERSION}.tar.gz >> ${LOGDIR}/gdal.log 2>&1
if [ $? -ne 0 ]; then
  echo "Unpack of GDAL failed, check gdal.log"
  exit 1
else
  echo "Unpack of GDAL successful."
fi

echo "Changing directory to gdal-${GDAL_VERSION}"
cd /usr/local/src/gdal-${GDAL_VERSION}

echo "Configuring GDAL"
./configure > ${LOGDIR}/gdal.configure 2>&1
if [ $? -ne 0 ]; then
  echo "Configure of GDAL failed, check ${LOGDIR}/gdal.configure"
  exit 1
else
  echo "Configure of GDAL successful."
fi

echo ""
echo "Building of GDAL can take several hours, be patient!"
echo ""

echo "Building GDAL"
make >> ${LOGDIR}/gdal.log 2>&1
if [ $? -ne 0 ]; then
  echo "Build of GDAL failed, check ${LOGDIR}/gdal.log"
  exit 1
else
  echo "Build of GDAL successful."
fi

echo "Installing GDAL"
make install >> ${LOGDIR}/gdal.log 2>&1
if [ $? -ne 0 ]; then
  echo "Install of GDAL failed, check ${LOGDIR}/gdal.log"
  exit 1
else
  echo "Install of GDAL successful."
fi

echo "Updating LDCONFIG"
ldconfig

cd /usr/local/src/

# POSTGIS
POSTGIS_VERSION="2.4.3"

echo "Fetching and building POSTGIS version ${POSTGIS_VERSION}"
wget -q https://download.osgeo.org/postgis/source/postgis-${POSTGIS_VERSION}.tar.gz > ${LOGDIR}/postgis 2>&1
if [ $? -ne 0 ]; then
  echo "Fetch of postgis-${POSTGIS_VERSION}.tar.gz failed, check ${LOGDIR}/postgis.log"
  exit 1
else
  echo "Fetch of POSTGIS successful."
fi

echo "Unpacking postgis-${POSTGIS_VERSION}.tar.gz"
tar xf postgis-${POSTGIS_VERSION}.tar.gz >> ${LOGDIR}/postgis 2>&1
if [ $? -ne 0 ]; then
  echo "Unpack of POSTGIS failed, check ${LOGDIR}/postgis.log"
  exit 1
else
  echo "Unpack of POSTGIS successful."
fi

echo "Changing directory to postgis-${POSTGIS_VERSION}"
cd /usr/local/src/postgis-${POSTGIS_VERSION}

echo "Configuring POSTGIS"
./configure > ${LOGDIR}/postgis.configure 2>&1
if [ $? -ne 0 ]; then
  echo "Configure of POSTGIS failed, check ../postgis.configure"
  exit 1
else
  echo "Configure of POSTGIS successful."
fi

echo "Building POSTGIS"
make >> ${LOGDIR}/postgis 2>&1
if [ $? -ne 0 ]; then
  echo "Build of POSTGIS failed, check ${LOGDIR}/postgis.log"
  exit 1
else
  echo "Build of POSTGIS successful."
fi

echo "Installing POSTGIS"
make install >> ${LOGDIR}/postgis 2>&1
if [ $? -ne 0 ]; then
  echo "Install of POSTGIS failed, check ${LOGDIR}/postgis.log"
  exit 1
else
  echo "Install of POSTGIS successful."
fi

echo "Updating LDCONFIG"
ldconfig

cd /usr/local/src/

# ? Why is this necessary for PostGIS?
PGROUTING_VERSION="2.5.2"

echo "Installing perl-Data-Dumper"
yum install -y perl-Data-Dumper > ${LOGDIR}/data-dumper.log 2>&1
if [ $? -ne 0 ]; then
  echo "Install of perl-Data-Dumper failed, check ${LOGDIR}/data-dumper.log"
  exit 1
else
  echo "Install of perl-Data-Dumper successful."
fi

# use of curl to add a prefix to the downloaded filename if wget does not work
# curl -Ls https://github.com/pgRouting/pgrouting/archive/v${PGROUTING_VERSION}.tar.gz \
#   > pgrouting-${PGROUTING_VERSION}.tar.gz \

echo "Fecting and building PGROUTING version ${PGROUTING_VERSION}"
wget -q https://github.com/pgRouting/pgrouting/archive/v${PGROUTING_VERSION}.tar.gz > ${LOGDIR}/pgrouting.log 2>&1
if [ $? -ne 0 ]; then
  echo "Fetch of v${PGROUTING_VERSION}.tar.gz failed, check ${LOGDIR}/pgrouting.log"
  exit 1
else
  echo "Fetch of PGROUTING successful."
fi

echo "Renaming v${PGROUTING_VERSION}.tar.gz pgrouting-${PGROUTING_VERSION}.tar.gz"
mv v${PGROUTING_VERSION}.tar.gz pgrouting-${PGROUTING_VERSION}.tar.gz >> ${LOGDIR}/pgrouting.log 2>&1
if [ $? -ne 0 ]; then
  echo "Rename of v${PGROUTING_VERSION}.tar.gz failed, check ${LOGDIR}/pgrouting.log"
  exit 1
else
  echo "Rename to pgrouting-${PGROUTING_VERSION}.tar.gz successful."
fi

echo "Unpacking pgrouting-${PGROUTING_VERSION}.tar.gz"
tar xf pgrouting-${PGROUTING_VERSION}.tar.gz >> ${LOGDIR}/pgrouting.log 2>&1
if [ $? -ne 0 ]; then
  echo "Unpack of PGROUTING failed, check ${LOGDIR}/pgrouting.log"
  exit 1
else
  echo "Unpack of PGROUTING successful."
fi

echo "Change directory to pgrouting-${PGROUTING_VERSION}"
cd pgrouting-${PGROUTING_VERSION}


echo "Create and change to build directory"
mkdir build >> ${LOGDIR}/pgrouting.log 2>&1
cd build >> ${LOGDIR}/pgrouting.log 2>&1

echo "Run CMAKE on PGROUTING"
cmake .. >> ${LOGDIR}/pgrouting.log 2>&1
if [ $? -ne 0 ]; then
  echo "CMAKE of PGROUTING failed, check ${LOGDIR}/pgrouting.log"
  exit 1
else
  echo "CMAKE of PGROUTING successful."
fi

echo "Build PGROUTING"
make >> ${LOGDIR}/pgrouting.log 2>&1
if [ $? -ne 0 ]; then
  echo "Build of PGROUTING failed, check ${LOGDIR}/pgrouting.log"
  exit 1
else
  echo "Build of PGROUTING successful."
fi

echo "Installing PGROUTING"
make install >> ${LOGDIR}/pgrouting.log 2>&1
if [ $? -ne 0 ]; then
  echo "Install of PGROUTING failed, check ${LOGDIR}/pgrouting.log"
  exit 1
else
  echo "Install of PGROUTING successful."
fi

echo "Updating LDCONFIG"
ldconfig

cd /usr/local/src/

echo "Install of POSTGIS completed"
echo "Try one of these techniques to verify POSTGIS is working correctly:"
echo ""
echo "Yse the \dx command from POSTGRES prompt - once you've switched context to a specific database - to verify which extensions are enabled on that database"
echo "Try a query such as SELECT st_distance(st_makepoint(42.636002, -78.042527)::geography, st_makepoint(42.582562, -77.941819)::geography;"
