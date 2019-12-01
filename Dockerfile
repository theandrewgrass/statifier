# start from the rocker/r-ver image
FROM rocker/r-ver

# install the linux libraries needed for plumber
RUN apt-get update -qq && apt-get install -y \
  libssl-dev \
  libcurl4-gnutls-dev

# install necessary packages
RUN R -e "install.packages('plumber')"
RUN R -e "install.packages('jsonlite')"
RUN R -e "install.packages('crayon')"
RUN R -e "install.packages('glue')"

# copy everything from the current directory into the container
COPY / /

CMD ["./start.sh"]