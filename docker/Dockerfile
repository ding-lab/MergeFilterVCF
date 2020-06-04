FROM broadinstitute/gatk3:3.8-1
MAINTAINER Matthew Wyczalkowski <m.wyczalkowski@wustl.edu>

WORKDIR /opt

# Getting Jesse backport errors: https://unix.stackexchange.com/questions/508724/failed-to-fetch-jessie-backports-repository
RUN echo "deb http://archive.debian.org/debian jessie-backports main" > /etc/apt/sources.list.d/jessie-backports.list
RUN echo "Acquire::Check-Valid-Until \"false\";" > /etc/apt/apt.conf.d/100disablechecks

RUN apt-get update && apt-get install -y \
    git \
    vim-tiny

#    cython \
#    python \
#    python-dev \
#    python-pip \

## Various Python packages
#RUN pip install \
#    pyvcf \
#    pysam \
#    numpy \
#    pytest

COPY . /opt/MergeFilterVCF
