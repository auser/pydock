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
    vim git bash-completion sudo autoconf automake libtool wget

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

## Tesseract
RUN apt-get install -yq liblog4cplus-dev imagemagick
RUN apt-get install -yq tesseract-ocr libtesseract-dev libleptonica-dev

ENV USER_GID compute-users

RUN addgroup $USER_GID

# Install miniconda to /miniconda
RUN curl -LO http://repo.continuum.io/miniconda/Miniconda-latest-Linux-x86_64.sh
RUN bash Miniconda-latest-Linux-x86_64.sh -p /miniconda -b
RUN rm Miniconda-latest-Linux-x86_64.sh

ADD system-conf /
RUN chown -R root:root /etc/sudoers.d && \
    chmod 0440 /etc/sudoers.d/*

ENV PATH /miniconda/bin:${PATH}
ENV CONDA_EXEC conda
ENV PIP_EXEC pip

RUN $CONDA_EXEC update -y conda
RUN $CONDA_EXEC create -y -n py3 python=3*
RUN $CONDA_EXEC create -y -n py2 python=2*

ADD setup /tmp/setup
RUN /tmp/setup/setup-jupyter-kernels.sh

RUN chgrp compute-users -R /miniconda/envs
RUN /bin/bash -c "source activate py2"

# ADD ./requirements.txt /
# RUN pip install -r /requirements.txt && rm /requirements.txt

# RUN $CONDA_EXEC install -y ipython jupyter ipyparallel \
#                    Cython hdf5 numpy scipy \
#                    h5py scikit-image scikit-learn \
#                    pandas matplotlib seaborn

# RUN $PIP_EXEC install keras
# RUN $CONDA_EXEC install -y -c https://conda.anaconda.org/menpo opencv

## START Torch 
WORKDIR /usr/local/src
RUN apt-get install -y build-essential git libatlas-base-dev libopencv-dev python-opencv
RUN git clone --recursive https://github.com/dmlc/mxnet
RUN cd mxnet; make -j4

## Torch kernel
WORKDIR /usr/local/src
RUN sudo apt-get install -y libzmq3-dev \
             luarocks libssl-dev  cmake graphviz \
             libqtgui4:amd64

## From https://hub.docker.com/r/kaixhin/cuda-torch/~/dockerfile/
# Run Torch7 installation scripts
RUN curl -sk https://raw.githubusercontent.com/torch/ezinstall/master/install-deps | bash
RUN git clone https://github.com/torch/distro.git /usr/local/torch --recursive
RUN cd /usr/local/torch; ./install.sh

# Set ~/torch as working directory
WORKDIR /usr/local/torch

# Export environment variables manually
ENV LUA_PATH='/root/.luarocks/share/lua/5.1/?.lua;/root/.luarocks/share/lua/5.1/?/init.lua;/usr/local/torch/install/share/lua/5.1/?.lua;/usr/local/torch/install/share/lua/5.1/?/init.lua;./?.lua;/usr/local/torch/install/share/luajit-2.1.0-alpha/?.lua;/usr/local/share/lua/5.1/?.lua;/usr/local/share/lua/5.1/?/init.lua' \
  LUA_CPATH='/root/.luarocks/lib/lua/5.1/?.so;/usr/local/torch/install/lib/lua/5.1/?.so;./?.so;/usr/local/lib/lua/5.1/?.so;/usr/local/lib/lua/5.1/loadall.so' \
  PATH=/usr/local/torch/install/bin:$PATH \
  LD_LIBRARY_PATH=/usr/local/torch/install/lib:$LD_LIBRARY_PATH \
  DYLD_LIBRARY_PATH=/usr/local/torch/install/lib:$DYLD_LIBRARY_PATH

# CMD ["/usr/local/torch/install/bin/th"]

WORKDIR /usr/local/torch

RUN cd /usr/local/torch && torch-activate && \
    luarocks install lzmq && \
    luarocks install penlight && \
    luarocks install luafilesystem && \
    luarocks install luacrypto

#RUN /usr/bin/luarocks install qlua

RUN git clone https://github.com/torch/graph.git /usr/local/torch/graph

RUN cd /usr/local/torch/graph && torch-activate && \
    /usr/local/torch/install/bin/luarocks make rocks/graph-scm-1.rockspec

RUN git clone git://github.com/koraykv/torch-nngraph.git /usr/local/torch/nngraph
RUN cd /usr/local/torch/nngraph && torch-activate && \
    /usr/local/torch/install/bin/luarocks make

# RUN git clone https://github.com/torch/cunn.git /usr/local/torch/cunn
# RUN cd /usr/local/torch/cunn && torch-activate && \
#     /usr/local/torch/install/bin/luarocks make rocks/cunn-scm-1.rockspec

#RUN /usr/bin/luarocks install optim
#RUN /usr/bin/luarocks install nn
#RUN /usr/bin/luarocks install cltorch
#RUN /usr/bin/luarocks install clnn

RUN cd /usr/local/torch && torch-activate && \
    /usr/local/torch/install/bin/luarocks install qtlua && \
    /usr/local/torch/install/bin/luarocks install env
    # /usr/local/torch/install/bin/luarocks install images && \
    # /usr/local/torch/install/bin/luarocks install lua-cjson
    # /usr/local/torch/install/bin/luarocks install uuid

RUN echo "#!/bin/bash\nexport PATH=\$PATH:/usr/local/torch/install/bin\n/usr/local/torch/install/bin/torch-activate" > /etc/profile.d/torch.sh && \
    chmod u+x /etc/profile.d/torch.sh

RUN cd /usr/local/torch && git clone https://github.com/facebook/iTorch.git
# CMD ["/usr/bin/luarocks make"]
RUN cd /usr/local/torch/iTorch && torch-activate && \
    env "PATH=$PATH" /usr/local/torch/install/bin/luarocks make
## END torch

EXPOSE 8888

VOLUME /home/compute
VOLUME /home/compute/notebooks

ADD entry.sh /opt/compute-container/entry.sh
RUN chmod u+x /opt/compute-container/entry.sh
CMD /opt/compute-container/entry.sh
