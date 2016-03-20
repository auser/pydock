#!/bin/bash -ex

USER_UID=${USER_UID:-2000}
USER_LOGIN=${USER:-compute}
USER_FULL_NAME="${USER_FULL_NAME:-Compute container user}"
USER_DIR="/home/${USER_LOGIN}"
PASSWORD=${PASSWORD:-itsginger}

JDIR="${USER_DIR}/.jupyter"
CONF_FILE="${JDIR}/jupyter_notebook_config.py"
NOTEBOOK_DIR="${USER_DIR}/notebooks"
PASSWORD_FILE=${JDIR}/.pass

##### Working stuff

mkdir -p -m 700 ${USER_DIR}
mkdir -p -m 700 ${JDIR}/security
mkdir -p -m 700 ${NOTEBOOK_DIR}

echo "Creating user ${USER_LOGIN} (${USER_UID}:${USER_GID})..."
id -u $USER_LOGIN &>/dev/null || adduser --disabled-password \
        --home "${USER_DIR}" \
        --uid "${USER_UID}" \
        --gecos "${USER_FULL_NAME},,," "${USER_LOGIN}" >/dev/null
adduser "${USER_LOGIN}" compute-users

chown -R $USER_LOGIN:compute-users $USER_DIR

IPY_DIR=$(ipython locate)
USER_IPY_DIR=$(su -c "ipython locate" $USER_LOGIN)

ls -la $IPY_DIR
cp -R $IPY_DIR/* $USER_IPY_DIR
cd "${USER_DIR}"

## Create the config
# SSL cert
# openssl req -new -newkey rsa:2048 -days 2652 -nodes -x509 -subj "//CN=ipython.ari.io" -keyout ${JDIR}/security/ssl_${USER_LOGIN}.pem -out ${JDIR}/security/ssl_${USER_LOGIN}.pem

echo $PASSWORD > $PASSWORD_FILE

cat<<EOF | sudo tee ${CONF_FILE}
import os
os.environ['SHELL'] = '/bin/bash'
os.environ['PYTHONPATH'] = '${PYTHONPATH}:${NOTEBOOK_DIR}'

c = get_config()
c.NotebookApp.ip = '0.0.0.0'
c.NotebookApp.port = 8888
c.NotebookApp.port_retries = 249
c.NotebookApp.enable_mathjax = True
c.NotebookApp.open_browser = False
# c.NotebookApp.certfile = u'${JDIR}/security/ssl_${USER_LOGIN}.pem'

from IPython.lib import passwd
with open('${PASSWORD_FILE}', 'r') as fp:
    p = fp.read().strip()
c.NotebookApp.password = passwd(p)

## Include the normal things
c.InteractiveShellApp.exec_lines = [
  '%matplotlib inline',
  '%load_ext autoreload',
  '%autoreload 2',
]

c.InteractiveShell.autoindent = True
c.InteractiveShell.colors = 'LightBG'
c.InteractiveShell.confirm_exit = False
c.InteractiveShell.deep_reload = True
c.InteractiveShell.editor = 'nano'
c.InteractiveShell.xmode = 'Context'

# c.IPKernelApp.pylab = 'inline'
c.InteractiveShellApp.matplotlib = 'inline'
c.NotebookApp.notebook_dir = os.path.expanduser('~/notebooks/')
EOF

chown -R $USER_LOGIN $(dirname $(ipython locate profile))

# jupyter
SUDO="sudo"
HOME="${USER_DIR}" $SUDO -E -u "${USER_LOGIN}" ${CMD:-/bin/bash --login -c "jupyter notebook --config=${CONF_FILE} --ip='*' --no-browser > jupyter.log 2>&1"}
