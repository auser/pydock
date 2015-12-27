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

RUN apt-get install -yq gfortran qt5-default

ADD system-conf /
RUN chown -R root:root /etc/sudoers.d && \
    chmod 0440 /etc/sudoers.d/*

ENV USER_GID compute-users
ENV PYENV_ROOT /usr/local/pyenv

RUN addgroup $USER_GID

# Install miniconda to /miniconda
RUN curl -LO http://repo.continuum.io/miniconda/Miniconda-latest-Linux-x86_64.sh
RUN bash Miniconda-latest-Linux-x86_64.sh -p /miniconda -b
RUN rm Miniconda-latest-Linux-x86_64.sh

ENV PATH /miniconda/bin:${PATH}
ENV CONDA_EXEC conda
ENV PIP_EXEC pip

ADD setup /tmp/setup

RUN $CONDA_EXEC update -y conda
RUN $CONDA_EXEC create -y -n py2 python=2*
RUN $CONDA_EXEC create -y -n py3 python=3*

RUN /tmp/setup/setup-jupyter-kernels.sh

RUN /bin/bash -c "source activate py3"

# RUN $CONDA_EXEC install -y ipython jupyter ipyparallel \
#                    Cython hdf5 numpy scipy \
#                    h5py scikit-image scikit-learn \
#                    pandas matplotlib seaborn

# RUN $PIP_EXEC install keras
# RUN $CONDA_EXEC install -y -c https://conda.anaconda.org/menpo opencv

EXPOSE 8888

ADD entry.sh /opt/compute-container/entry.sh
RUN chmod u+x /opt/compute-container/entry.sh
CMD /opt/compute-container/entry.sh

