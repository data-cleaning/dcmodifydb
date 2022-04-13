# Pull specific digest of R for now

FROM r-base:latest

# create and copy code to start running the tests
RUN mkdir /code
COPY tests/integration_tests/postgres12_ssl/dcmodifyDB/* /code/.
# create and copy directory for package code
RUN mkdir -p /code/package/R
COPY R /code/package/R

COPY DESCRIPTION /code/package/.
COPY NAMESPACE /code/package/.

RUN mkdir /code/tests
COPY tests/integration_tests/container_tests/* /code/tests/.






WORKDIR /code

RUN apt-get update
# Installing odbc requirements, -y is needed due to the nature of apt-get!
RUN apt-get -y install unixodbc-dev odbc-postgresql unixodbc postgresql-client


# Installing Rpostgres requirements, -y is neede due to the nature of apt-get!
RUN apt-get -y install libpq-dev libssl-dev 

# Installing devtools requirements
# required by subpackage curl
RUN apt-get -y install libcurl4-openssl-dev

# required by subpackage xml2
RUN apt-get -y install libxml2-dev


RUN Rscript --no-save requirements.R 
#CMD ["Rscript", "--no-save", "basic_run.R"]
