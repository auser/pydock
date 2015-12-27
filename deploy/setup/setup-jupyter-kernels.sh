#!/bin/bash -e

function setup_jupyter() {
	  _python=$1
	  _name=$2
    _opencv_name=$3

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
    source activate ${_python}
    conda install -y notebook ipykernel jupyter ipyparallel \
          hdf5 numpy scipy h5py scikit-image scikit-learn \
          pandas matplotlib seaborn
    pip install keras

    conda install -y -c https://conda.anaconda.org/menpo ${_opencv_name}

	  jupyter kernelspec install "${_spec_dir}"
	  rm -r "${_ktmp}"
}

setup_jupyter py2 "Python2 with OpenCV" opencv
setup_jupyter py3 "Python3 with OpenCV3" opencv3
