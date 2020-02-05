# https://hub.docker.com/r/broadinstitute/gatk
FROM broadinstitute/gatk
MAINTAINER Matthew Wyczalkowski <m.wyczalkowski@wustl.edu>

WORKDIR /opt

RUN apt-get update && apt-get install -y \
    git \
    python \
    python-dev \
    python-pip \
    vim-tiny

# Various Python packages
RUN pip install \
    pyvcf \
    pysam \
    numpy \
    pytest

COPY . /opt/MergeFilterVCF
