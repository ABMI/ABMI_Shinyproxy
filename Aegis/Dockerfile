FROM openanalytics/r-base

LABEL maintainer "Tobias Verbeke <tobias.verbeke@openanalytics.eu>"

# system libraries of general use
RUN apt-get update && apt-get install -y \
    sudo \
    pandoc \
    pandoc-citeproc \
    libcurl4-gnutls-dev \
    libcairo2-dev \
    libxt-dev \
    libssl-dev \
    libssh2-1-dev \
    libssl1.0.0

# system library dependency for the euler app
RUN apt-get update && apt-get install -y \
    libmpfr-dev

# basic shiny functionality
RUN R -e "install.packages(c('shiny', 'rmarkdown'), repos='https://cloud.r-project.org/')"

# install dependencies of the euler app
RUN R -e "install.packages('Rmpfr', repos='https://cloud.r-project.org/')"

RUN apt-get update && \
    apt-get install -y openjdk-8-jdk
RUN mv /usr/lib/jvm/java-8-openjdk-amd64 /usr/lib/jvm/default-java
RUN R -e "install.packages('rJava', dependencies = TRUE, repos='https://cran.rstudio.com/')"

RUN apt-get update
RUN apt-get install -y \
	build-essential \ 
	libcurl4-gnutls-dev \
	libxml2-dev libssl-dev
	
RUN R -e "install.packages('devtools')"
RUN R CMD javareconf
RUN R -e "devtools::install_github('ohdsi/DatabaseConnector')"

RUN R -e "install.packages(c('DCluster','maps','mapdata','mapproj','leaflet','ggmap','dplyr','sqldf','shiny','bindrcpp','pkgconfig','shinyjs','shinydashboard','maptools','SpatialEpi','lubridate','rgdal','gpclib','rgeos','RColorBrewer','DT','leafpop'))"
RUN R -e "devtools::install_github('cran/raster', ref='2.6-7')"
RUN R -e "devtools::install_github('abmi/aegis', ref='master')"
RUN apt-get install -y libgdal-dev gdal-bin libproj-dev proj-data proj-bin libgeos-dev
RUN apt-get install -y libudunits2-dev
RUN R -e "install.packages('DCluster')"
RUN R -e "install.packages('SpatialEpi')"
RUN R -e "install.packages('rgdal')"
RUN R -e "install.packages('rgeos')"
RUN R -e "install.packages('leafpop')"


# copy the app to the image
RUN mkdir /root/aegis
COPY aegis /root/aegis

COPY Rprofile.site /usr/lib/R/etc/

EXPOSE 3838

CMD ["R", "-e", "shiny::runApp('/root/aegis')"]
