# Start with Ubuntu base image
# FROM ubuntu:14.04
FROM kaixhin/cuda:latest

# Only do this once at the beginning

RUN apt-get update

# [ Caffe ]
# From first half of https://github.com/Kaixhin/dockerfiles/blob/master/digits/Dockerfile

# Install git, bc and dependencies
RUN apt-get install -y \
  git \
  bc \
  cmake \
  libgflags-dev \
  libgoogle-glog-dev \
  libopencv-dev \
  libleveldb-dev \
  libsnappy-dev \
  liblmdb-dev \
  libhdf5-serial-dev \
  libprotobuf-dev \
  protobuf-compiler \
  libatlas-base-dev \
  python-dev \
  python-pip \
  python-numpy \
  gfortran

# Install boost
RUN apt-get install -y --no-install-recommends libboost-all-dev

# Clone NVIDIA Caffe repo and move into it
RUN cd /usr/local/ && git clone --branch caffe-0.14 https://github.com/NVIDIA/caffe.git && cd caffe && \
# Install python dependencies
  cat python/requirements.txt | xargs -n1 pip install && \
# Make and move into build directory
  mkdir build && cd build && \
# CMake
  cmake .. && \
# Make
  make -j"$(nproc)"
# Set CAFFE_HOME
ENV CAFFE_HOME /usr/local/caffe
ENV PYTHONPATH /usr/local/caffe/python:$PYTHONPATH

# [ Theano ]

# Install build-essential, git, python-dev, pip and other dependencies
RUN apt-get install -y \
  build-essential \
  git \
  python-dev \
  libopenblas-dev \ 
  python-pip \
  python-nose \
  python-numpy \
  python-scipy

# Install bleeding-edge Theano
RUN pip install --upgrade --no-deps git+git://github.com/Theano/Theano.git

# [ Lasagne ]

# Install bleeding-edge Lasagne
RUN pip install --upgrade https://github.com/Lasagne/Lasagne/archive/master.zip

# [ Keras ]

# Install dependencies
RUN apt-get install -y \
  libhdf5-dev \
  python-h5py \
  python-yaml

# Upgrade six
RUN pip install --upgrade six

# Clone Keras repo and move into it
RUN cd /usr/local && git clone https://github.com/fchollet/keras.git && cd keras && \
  # Install
  python setup.py install

# Set ~/keras as working directory
# WORKDIR /usr/local/keras

# [ Torch ]

# Install curl and dependencies for iTorch
RUN apt-get install -y \
  curl \
  ipython3 \
  python-zmq \
	software-properties-common

# Run Torch7 installation scripts
RUN curl -sk https://raw.githubusercontent.com/torch/ezinstall/master/install-deps | bash
RUN git clone https://github.com/torch/distro.git /usr/local/torch --recursive
RUN cd /usr/local/torch; ./install.sh

# Set /usr/local/torch as working directory
# WORKDIR /usr/local/torch

# Export environment variables manually
ENV LUA_PATH='/usr/local/.luarocks/share/lua/5.1/?.lua;/usr/local/.luarocks/share/lua/5.1/?/init.lua;/usr/local/torch/install/share/lua/5.1/?.lua;/usr/local/torch/install/share/lua/5.1/?/init.lua;./?.lua;/usr/local/torch/install/share/luajit-2.1.0-alpha/?.lua;/usr/local/share/lua/5.1/?.lua;/usr/local/share/lua/5.1/?/init.lua' \
  LUA_CPATH='/usr/local/.luarocks/lib/lua/5.1/?.so;/usr/local/torch/install/lib/lua/5.1/?.so;./?.so;/usr/local/lib/lua/5.1/?.so;/usr/local/lib/lua/5.1/loadall.so' \
  PATH=/usr/local/torch/install/bin:$PATH \
  LD_LIBRARY_PATH=/usr/local/torch/install/lib:/usr/local/include:$LD_LIBRARY_PATH \
  DYLD_LIBRARY_PATH=/usr/local/torch/install/lib:$DYLD_LIBRARY_PATH

RUN luarocks install loadcaffe
RUN cd /usr/local/torch && torch-activate && \
    luarocks install lzmq && \
    luarocks install penlight && \
    luarocks install luafilesystem

# TODO: Move this above
RUN apt-get install -yq libssl-dev libsslcommon2-dev

RUN pwd && ls -l /usr/include | grep ssl
RUN cd /usr/local/torch && torch-activate && \
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

RUN echo "#!/bin/bash\nexport PATH=\$PATH:/usr/local/torch:/usr/local/torch/install/bin\n/usr/local/torch/install/bin/torch-activate" > /etc/profile.d/torch.sh && \
    chmod u+x /etc/profile.d/torch.sh

RUN cd /usr/local/torch && git clone https://github.com/facebook/iTorch.git
# CMD ["/usr/bin/luarocks make"]
RUN cd /usr/local/torch/iTorch && torch-activate && \
    env "PATH=$PATH" /usr/local/torch/install/bin/luarocks make
## END torch

# [ Chainer ]

RUN apt-get install -y \
  ccache \
  curl \
  g++ \
  gfortran \
  git \
  libhdf5-dev
ENV PATH /usr/lib/ccache:$PATH
RUN apt-get install -y \
  python-pip \
  python-dev
# RUN pip install numpy==1.10.2 # more recent version already installed above
RUN pip install chainer

# [ gensim, sklearn ]

RUN pip install \
  gensim \
  sklearn \
  skflow \
  ipython jupyter ipyparallel \
  Cython \
  numpy scipy h5py \
  scikit-image scikit-learn \
  pandas matplotlib seaborn

# [ TensorFlow ]

RUN apt-get update && apt-get install -y \
  curl \
  libfreetype6-dev \
  libpng12-dev \
  libzmq3-dev \
  pkg-config \
  python-numpy \
  python-pip \
  python-scipy

RUN pip install \
  https://storage.googleapis.com/tensorflow/linux/cpu/tensorflow-0.6.0-cp27-none-linux_x86_64.whl

# [ IPython / Jupyter]

RUN pip install \
  pexpect \
  simplegeneric \
  jupyter

ADD setup/jupyter/python2 /tmp/jupyter/python2
RUN jupyter kernelspec install /tmp/jupyter
# [ Prepare the matplotlib font cache ]

# RUN python -c "import matplotlib.pyplot"

# [ MxNet ]
# Clone MXNet repo and move into it
RUN cd /usr/local/src && git clone --recursive https://github.com/dmlc/mxnet && cd mxnet && \
# Copy config.mk
  cp make/config.mk config.mk && \
# Set OpenBLAS
  sed -i 's/USE_BLAS = atlas/USE_BLAS = openblas/g' config.mk && \
# Set CUDA flag
  sed -i 's/USE_CUDA = 0/USE_CUDA = 1/g' config.mk && \
  sed -i 's/USE_CUDA_PATH = NONE/USE_CUDA_PATH = \/usr\/local\/cuda/g' config.mk && \
# Set cuDNN flag
# TODO: Change when cuDNN v4 supported
  sed -i 's/USE_CUDNN = 0/USE_CUDNN = 0/g' config.mk && \
# Make 
  make -j"$(nproc)"

RUN cd /usr/local/src/mxnet/python && python setup.py install
# Add R to apt sources
RUN echo "deb http://cran.rstudio.com/bin/linux/ubuntu trusty/" >> /etc/apt/sources.list
# Install latest version of R
RUN apt-get update && apt-get install -y --force-yes r-base

# [ pyOSC ]

# the version on pip is older than this version on GitHub
RUN pip install git+git://github.com/ptone/pyosc.git

ADD setup/install_opencv.sh /tmp/install_opencv.sh
RUN curl -sf -o /usr/local/src/ffmpeg-snapshot.tar.bz2 -L http://ffmpeg.org/releases/ffmpeg-snapshot.tar.bz2
RUN /tmp/install_opencv.sh

ADD system-conf /
RUN chown -R root:root /etc/sudoers.d && \
    chmod 0440 /etc/sudoers.d/*

RUN apt-get clean autoclean
RUN apt-get autoremove -y
RUN rm -rf /var/lib/apt/lists/*

# Cleanup
EXPOSE 8888

VOLUME /home/compute
VOLUME /home/compute/notebooks

ENV USER_GID compute-users
RUN addgroup $USER_GID

ADD entry.sh /opt/compute-container/entry.sh
RUN chmod u+x /opt/compute-container/entry.sh
CMD /opt/compute-container/entry.sh
