#!/bin/bash
#
# Initial setup script for compute machine

# Log commands & exit on error
set -xe

OPENCV_VER=3.0.0
OPENCV_CONTRIB_VER="${OPENCV_VER}"
OPENCV_INSTALL_PREFIX="/opt/opencv"
PYENV_ROOT=${PYENV_ROOT:-$HOME/.pyenv}
PYENV_SHIMS=$PYENV_ROOT/shims
PATH=$PATH:$PYENV_ROOT/bin

sudo -H $PYENV_SHIMS/pip install --upgrade pip

function setup_jupyter() {
	_python=$1
	_name=$2

	_ktmp=$(mktemp --tmpdir=/tmp -d kernelspecs-XXXXXXX)
	_spec_dir="${_ktmp}/$(basename ${_python})"
	echo "Setting up Jupyter for ${_python} in ${_spec_dir}"
	mkdir -p "${_spec_dir}"
	cat >"${_spec_dir}/kernel.json" <<EOI
{
	"language": "python",
	"display_name": "${_name}",
	"argv": [
		"${_python}", "-m", "ipykernel", "-f", "{connection_file}"
	]
}
EOI
	$PYENV_SHIMS/jupyter kernelspec install "${_spec_dir}"
	rm -r "${_ktmp}"
}

function install_opencv() {
	echo "Installing OpenCV..."

	# Create download directory
	OPENCV_WORKDIR="$(mktemp -d --tmpdir opencv-compile.XXXXXX)"
	cd "${OPENCV_WORKDIR}"

	# Download and extract OpenCV and OpenCV contrib modules
	echo "Dowloading and extracting OpenCV..."
	curl -L https://github.com/Itseez/opencv/archive/${OPENCV_VER}.tar.gz | tar xz
	curl -L https://github.com/Itseez/opencv_contrib/archive/${OPENCV_CONTRIB_VER}.tar.gz | tar xz

	echo "Compiling OpenCV..."
	OPENCV_CONTRIB_MODULES=${OPENCV_WORKDIR}/opencv_contrib-${OPENCV_CONTRIB_VER}/modules

	cd opencv-${OPENCV_VER}
	mkdir release; cd release
	cmake -DCMAKE_BUILD_TYPE=Release \
		-DCMAKE_INSTALL_PREFIX=${OPENCV_INSTALL_PREFIX} \
		-DOPENCV_EXTRA_MODULES_PATH=${OPENCV_CONTRIB_MODULES} \
    -DBUILD_NEW_PYTHON_SUPPORT=ON -DWITH_V4L=ON \
    -DINSTALL_PYTHON_EXAMPLES=ON \
    -DWITH_QT=ON -DWITH_OPENGL=ON \
		..

	make -j8 && make install

	# Add OpenCV to profile
	cat >>/etc/profile.d/opencv.sh <<EOI
export OPENCV_PREFIX="${OPENCV_INSTALL_PREFIX}"
export PATH="\${OPENCV_PREFIX}/bin:\${PATH}"
export LD_LIBRARY_PATH="\${OPENCV_PREFIX}/lib:\${LD_LIBRARY_PATH}"
export PKG_CONFIG_PATH="\${OPENCV_PREFIX}/lib/pkgconfig:\${PKG_CONFIG_PATH}"
for _pp in "\${OPENCV_PREFIX}"/lib/python*/dist-packages; do
	export PYTHONPATH="\${_pp}:\${PYTHONPATH}"
done
EOI

	rm -r "${OPENCV_WORKDIR}"
}

function install_pip_packages() {
    INSTALL="$PYENV_SHIMS/conda install -y"
    PIP_INSTALL="$PYENV_SHIMS/pip install"

    $PYENV_SHIMS/conda create -n py3 python=3*
    $PYENV_SHIMS/conda create -n py2 python=2*

    $INSTALL ipython jupyter ipyparallel
    $INSTALL Cython hdf5
    $INSTALL numpy scipy
    $INSTALL h5py
    $INSTALL scikit-image scikit-learn
    $INSTALL pandas matplotlib seaborn
    $PIP_INSTALL keras
}

# install_pip_packages
setup_jupyter python "Python"
install_opencv
