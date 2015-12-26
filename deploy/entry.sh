#!/bin/bash -ex

USER_UID=${USER_UID:-2000}
USER_LOGIN=${USER:-compute}
USER_FULL_NAME="${USER_FULL_NAME:-Compute container user}"
USER_HOME_DIR="/home/${USER_LOGIN}"

echo "Creating user ${USER_LOGIN} (${USER_UID}:${USER_GID})..."
adduser --disabled-password \
        --home "${USER_HOME_DIR}" \
        --uid "${USER_UID}" \
        --gecos "${USER_FULL_NAME},,," "${USER_LOGIN}"
adduser "${USER_LOGIN}" compute-users

HOME="${USER_HOME_DIR}" \
    sudo -E -u "${USER_LOGIN}" \
	  ${CMD:-/bin/bash --login \
                -c "jupyter notebook --no-browser --ip=0.0.0.0"}
