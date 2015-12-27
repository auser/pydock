#!/bin/bash -e

USER_UID=${USER_UID:-2000}
USER_LOGIN=${USER:-compute}
USER_FULL_NAME="${USER_FULL_NAME:-Compute container user}"
USER_DIR="/home/${USER_LOGIN}"
PASSWORD=${PASSWORD:-itsginger}

IPYTHON_DIR="${USER_DIR}/.ipython"
CONF_FILE="${IPYTHON_DIR}/ipython_notebook_config.py"
NOTEBOOK_DIR="${USER_DIR}/notebooks"
PASSWORD_FILE=${IPYTHON_DIR}/.pass

##### Working stuff

mkdir -p -m 700 ${USER_DIR}
mkdir -p -m 700 ${IPYTHON_DIR}/security
mkdir -p -m 700 ${NOTEBOOK_DIR}

echo "Creating user ${USER_LOGIN} (${USER_UID}:${USER_GID})..."
adduser --disabled-password \
        --home "${USER_DIR}" \
        --uid "${USER_UID}" \
        --gecos "${USER_FULL_NAME},,," "${USER_LOGIN}" >/dev/null
adduser "${USER_LOGIN}" compute-users 

cd "${USER_DIR}"
chown -R $USER_LOGIN:compute-users $USER_DIR

## Create the config
# SSL cert
# openssl req -new -newkey rsa:2048 -days 2652 -nodes -x509 -subj "//CN=ipython.ari.io" -keyout ${IPYTHON_DIR}/security/ssl_${USER_LOGIN}.pem -out ${IPYTHON_DIR}/security/ssl_${USER_LOGIN}.pem

echo $PASSWORD > $PASSWORD_FILE

cat<<EOF | sudo tee ${CONF_FILE}
c = get_config()
c.NotebookApp.ip = '0.0.0.0'
c.NotebookApp.port = 8888
c.NotebookApp.port_retries = 249
c.NotebookApp.enable_mathjax = True
c.NotebookApp.open_browser = False
# c.NotebookApp.certfile = u'${IPYTHON_DIR}/security/ssl_${USER_LOGIN}.pem'
c.NotebookApp.ipython_dir = u'${IPYTHON_DIR}'

from IPython.lib import passwd
with open('${PASSWORD_FILE}', 'r') as fp:
    p = fp.read().strip()
c.NotebookApp.password = passwd(p)
c.IPKernelApp.pylab = 'inline'
c.NotebookManager.notebook_dir = u'${NOTEBOOK_DIR}'
EOF

SUDO="sudo"
IPYTHONDIR=${IPYTHON_DIR} HOME="${USER_DIR}" $SUDO -E -u "${USER_LOGIN}" ${CMD:-/bin/bash --login -c "jupyter notebook --config=${CONF_FILE}"}
