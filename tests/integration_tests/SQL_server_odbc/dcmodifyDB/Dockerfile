
# Pull debian 10 image needed for SQL server drivers
FROM ubuntu:xenial
# Install system dependencies for R
RUN apt-get update -qq && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
    apt-transport-https \
    build-essential \
    curl \
    gfortran \
    libatlas-base-dev \
    libbz2-dev \
    libcairo2 \
    libcurl4-openssl-dev \
    libicu-dev \
    liblzma-dev \
    libpango-1.0-0 \
    libpangocairo-1.0-0 \
    libpcre3-dev \
    libtcl8.6 \
    libtiff5 \
    libtk8.6 \
    libx11-6 \
    libxt6 \
    locales \
    tzdata \
    zlib1g-dev\
    wget

# Install system dependencies for the tidyverse R packages
RUN apt-get install -y \
    make \
libcurl4-openssl-dev \
libssl-dev \ 
pandoc \ 
libxml2-dev \
    wget

ARG R_VERSION=4.1.2
RUN wget https://cdn.rstudio.com/r/ubuntu-1604/pkgs/r-${R_VERSION}_1_amd64.deb
RUN apt-get install -y gdebi-core
RUN gdebi -n  r-${R_VERSION}_1_amd64.deb



# create and copy code to start running the tests
RUN mkdir /code
COPY tests/integration_tests/sql_server_odbc/dcmodifyDB/* /code/.
# create and copy directory for package code
RUN mkdir -p /code/package/R
COPY R /code/package/R

COPY DESCRIPTION /code/package/.
COPY NAMESPACE /code/package/.

RUN mkdir /code/tests
COPY tests/integration_tests/container_tests/* /code/tests/.






WORKDIR /code

RUN apt-get update
# Installing odbc requirements for postgres, -y is needed due to the nature of apt-get!
RUN apt-get -y install unixodbc-dev odbc-postgresql unixodbc postgresql-client


# Installing Rpostgres requirements, -y is neede due to the nature of apt-get!
RUN apt-get -y install libpq-dev libssl-dev 

# Installing devtools requirements
# required by subpackage curl
RUN apt-get -y install libcurl4-openssl-dev

# required by subpackage xml2
RUN apt-get -y install libxml2-dev

RUN apt update && apt upgrade -y
RUN apt-get install gnupg -y
RUN apt-get install curl -y



RUN curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add -

#Download appropriate package for the OS version
#Choose only ONE of the following, corresponding to your OS version

RUN curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add -
RUN curl https://packages.microsoft.com/config/ubuntu/16.04/prod.list > /etc/apt/sources.list.d/mssql-release.list

RUN apt-get update
RUN ACCEPT_EULA=Y apt-get -y install msodbcsql 
# optional: for bcp and sqlcmd
RUN ACCEPT_EULA=Y apt-get -y install mssql-tools 
RUN echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bashrc
RUN . ~/.bashrc
# optional: for unixODBC development headers
RUN apt-get -y install unixodbc-dev





RUN //opt/R/4.1.2/bin/Rscript --no-save requirements.R 

