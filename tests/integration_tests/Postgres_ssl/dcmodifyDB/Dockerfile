# Pull specific digest of R for now
FROM ubuntu:latest
FROM r-base:latest

RUN mkdir /code


COPY . /code/.
WORKDIR /code

RUN apt-get update
# Installing odbc requirements, -y is needed due to the nature of apt-get!
RUN apt-get -y install unixodbc-dev odbc-postgresql unixodbc

# Installing Rpostgres requirements, -y is neede due to the nature of apt-get!
RUN apt-get -y install libpq-dev libssl-dev 

# Installing devtools requirements
# required by subpackage curl
RUN apt-get -y install libcurl4-openssl-dev

# required by subpackage xml2
RUN apt-get -y install libxml2-dev


RUN Rscript --no-save requirements.R 
#CMD ["Rscript", "--no-save", "basic_run.R"]
