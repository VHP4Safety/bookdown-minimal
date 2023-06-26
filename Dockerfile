## RStudio Server Docker base image
FROM rocker/r-ver:4.2.1

## Set env
ENV S6_VERSION=v2.1.0.2
ENV RSTUDIO_VERSION=daily
ENV DEFAULT_USER=rstudio
ENV PANDOC_VERSION=default
ENV PATH=/usr/lib/rstudio-server/bin:$PATH

## install scripts for RStudio
RUN /rocker_scripts/install_rstudio.sh
RUN /rocker_scripts/install_pandoc.sh

## port for local webbrowser
EXPOSE 8787

CMD ["/init"]

## to share the volume on the host
WORKDIR /home/rstudio

## copy repo contents to shared host folder
COPY --chown=rstudio:rstudio . /home/rstudio/

ENV DEBIAN_FRONTEND=noninteractive
## install systemd depends
RUN apt update && apt install -y \
  make \
  zlib1g-dev \
  libcurl4-openssl-dev \
  libssl-dev \
  libfontconfig1-dev \
  libfreetype6-dev \
  libfribidi-dev \
  libharfbuzz-dev \
  libjpeg-dev \
  libpng-dev \
  libtiff-dev \
  libicu-dev \
  pandoc \
  libxml2-dev \
  git \
  libgit2-dev \
&& rm -rf /var/lib/apt/lists/*

# RUN git clone https://github.com/VHP4Safety/OPPBKmodelR

## install pak for faster R package install_rstudio
RUN Rscript -e "options(repos = c(CRAN = 'https://cran.r-project.org'));install.packages(c('pak'), dependencies = TRUE)"

## install extra R packages
RUN Rscript -e "options(repos = c(CRAN = 'https://cran.r-project.org'));pak::pak(c('tidyverse', 'devtools'), dependencies = TRUE)"
## install Bioconductor base
RUN Rscript -e "options(repos = c(CRAN = 'https://cran.r-project.org')); BiocManager::install(ask=FALSE)"

## install {XPloreAOP} R package
RUN Rscript -e "options(repos = c(CRAN = 'https://cran.r-project.org'));devtools::install('.', dependencies=TRUE, build_vignettes=TRUE, repos = BiocManager::repositories())"

