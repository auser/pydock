FROM ubuntu

## https://github.com/rjw57/jupyter-container

# dependencies for Debian package).
RUN apt-get -yq update

RUN apt-get -yq install libgstreamer1.0-dev \
	libavcodec-dev libavformat-dev libswscale-dev libgtk2.0-dev \
	libgtkglext1-dev libgl1-mesa-dev libglu1-mesa-dev \
  libjasper-dev libavutil-dev libswscale-dev

RUN apt-get -yq install libjpeg-dev libpng-dev libtiff-dev libopenexr-dev libraw1394-dev libopencv-dev \
	libdc1394-22-dev libv4l-dev v4l-utils \
  zlib1g-dev liblapack-dev libtbb-dev

RUN apt-get -yq install libeigen3-dev ocl-icd-opencl-dev \
	ant default-jdk javahelper texlive-fonts-extra texlive-latex-extra

RUN apt-get -yq install build-essential cmake checkinstall \
    vim git bash-completion sudo

RUN apt-get -yq install texlive-latex-recommended latex-xcolor texlive-fonts-recommended \
	libgstreamer-plugins-base1.0-dev gstreamer1.0-libav libavresample-dev

RUN apt-get -yq install libavresample-dev llvm-dev llvm

RUN apt-get -yq install libsnappy-dev liblmdb-dev \
  libleveldb-dev libhdf5-dev libqt4-dev libgtk2.0-dev \
  libopencore-amrwb-dev libtheora-dev libvorbis-dev \
  libxvidcore-dev x264

RUN apt-get install -yq libssl-dev zlib1g-dev \
                libbz2-dev \
                libreadline-dev libsqlite3-dev libncurses5-dev

RUN apt-get install -yq gfortran

ADD system-conf /
RUN chown -R root:root /etc/sudoers.d && \
    chmod 0440 /etc/sudoers.d/*

ENV USER_GID compute-users
ENV MINICONDA_ROOT /usr/local/conda
# ENV PYENV_ROOT /usr/local/pyenv

RUN addgroup $USER_GID

RUN curl -LO http://repo.continuum.io/miniconda/Miniconda-latest-Linux-x86_64.sh
RUN bash Miniconda-latest-Linux-x86_64.sh -p $MINICONDA_ROOT -b
RUN rm Miniconda-latest-Linux-x86_64.sh
ENV PATH=$MINICONDA_ROOT/bin:${PATH}
RUN conda update -y conda

# PyENV
# RUN git clone git://github.com/yyuu/pyenv.git $PYENV_ROOT

# RUN chmod 777 $PYENV_ROOT
# ENV PYENV_EXEC $PYENV_ROOT/bin/pyenv

# ENV PYTHON_VERSION 2.7.10
# ENV PYTHON_VERSION miniconda3-3.18.3
#anaconda3-2.4.0

# RUN $PYENV_EXEC install $PYTHON_VERSION
# RUN $PYENV_EXEC global $PYTHON_VERSION
# RUN $PYENV_EXEC rehash

ADD setup /tmp/setup
RUN cd /tmp/setup && ./setup-system.sh && rm -r /tmp/setup

EXPOSE 8888

RUN ls -la $HOME

ADD entry.sh /opt/compute-container/entry.sh
RUN chmod u+x /opt/compute-container/entry.sh
CMD /opt/compute-container/entry.sh

