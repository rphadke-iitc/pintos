# Docker image for CS 450 pintos

FROM --platform=amd64 ubuntu:18.04
LABEL maintainer="Farshad Ghanei <fgh@iit.edu>"

# prerequisites
RUN apt update --fix-missing
RUN apt update --fix-missing && apt install -y apt-utils --fix-missing
RUN apt install --fix-missing -y gcc vim wget curl make build-essential libcunit1-dev libcunit1-doc libcunit1 wget python qemu xorg-dev libncurses5-dev gdb git


###############################################
# configuraion and setup for bochs and pintos #
###############################################
ENV PINTOSDIR /home/pintos
ENV DSTDIR /usr/local
ENV SRCDIR /home/source
RUN mkdir -p $SRCDIR
RUN mkdir -p $PINTOSDIR
RUN mkdir -p $DSTDIR/bin
ENV BXSHARE $DSTDIR/share/bochs
ENV PATH="${DSTDIR}/bin:${PATH}"

# Copies pintos from the reposity. These files will be replaced with user files when the container is run, but we need them for build.
# Something like: docker run --name pintos_container -v %cd%\pintos:/home/pintos/
WORKDIR $SRCDIR/
RUN git clone git://pintos-os.org/pintos-anon && cd pintos-anon && git checkout f685123e5f8e7c84648b2de810ba20e85b7d1504
RUN mv pintos-anon/* $PINTOSDIR
WORKDIR $SRCDIR/

WORKDIR $PINTOSDIR/src/misc/
RUN ./bochs-2.6.11-build.sh /usr/local

WORKDIR $PINTOSDIR/src/utils/
RUN sed -i "5i GDBMACROS=$PINTOSDIR/src/misc/gdb-macros" $PINTOSDIR/src/utils/pintos-gdb
RUN sed -i "s/$sim = \"bochs\" if \!defined $sim/$sim = \"qemu\" if \!defined $sim/" $PINTOSDIR/src/utils/pintos
RUN make
RUN cp backtrace pintos pintos-gdb pintos-mkdisk Pintos.pm pintos-set-cmdline squish-pty squish-unix $DSTDIR/bin

WORKDIR $PINTOSDIR




