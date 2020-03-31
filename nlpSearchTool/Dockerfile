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

RUN R -e "install.packages('shinyjs')"


# copy the app to the image
RUN mkdir /root/nlpsearchtool
COPY nlpsearchtool /root/nlpsearchtool

COPY Rprofile.site /usr/lib/R/etc/

EXPOSE 3838

CMD ["R", "-e", "shiny::runApp('/root/nlpsearchtool')"]
