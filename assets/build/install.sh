#! /usr/bin/bash -x

# Environment
VIRTUALENV=$(which virtualenv)
PIP="${TENDENCI_VIRTUALENV}/bin/pip"
DJANGO_ADMIN="${TENDENCI_VIRTUALENV}/bin/django-admin"
TENDENCI_TEMPLATE="https://github.com/tendenci/tendenci-project-template/archive/master.zip"

# Execute a command as TENDENCI_USER
function exec_as_tendenci()
{
    if [[ "$(whoami)" == "${TENDENCI_USER}" ]]; then
        "$@"
    else
        sudo -HEu "${TENDENCI_USER}" "$@"
    fi
}

# Check directories and create them if necessary
function check_dirs()
{
    for dir in $TENDENCI_INSTALL_DIR $TENDENCI_DATA_DIR\
        $TENDENCI_LOG_DIR $TENDENCI_RUNTIME_DIR;
do
    [ -d "$dir" ] || mkdir "$dir"
    chown "$TENDENCI_USER:" "$dir"
done
}

# Check user to run the application, create it if not done yet
function check_user()
{
    if ! grep -i "^$TENDENCI_USER" /etc/passwd; then
        adduser --disabled-login --gecos "Tendenci" "${TENDENCI_USER}"
        passwd -d "${TENDENCI_USER}"
        chown -R "${TENDENCI_USER}:" "${TENDENCI_HOME}"
    fi

    chmod u+x "${TENDENCI_RUNTIME_DIR}/entrypoint.sh"
# # Set environment (fixes runtime issues with virtualenv)
# cat >> "${TENDENCI_HOME}"/.bashrc <<EOF
# [[ -f ~/runtime/env-defaults ]] && source ~/runtime/env-defaults
# PATH=\${TENDENCI_VIRTUALENV}/bin:/usr/local/sbin:/usr/local/bin:\$PATH
# EOF
}

function install_jpeg_9
{
    DEBIAN_FRONTEND=noninteractive apt-get install -y curl
    curl -O http://www.ijg.org/files/jpegsrc.v9.tar.gz \
        && tar -xvzf jpegsrc.v9.tar.gz \
        && cd jpeg-9 \
        && ./configure \
        && make \
        && make install \
        && cd .. \
        && rm -r jpeg-9 jpegsrc.v9.tar.gz
    DEBIAN_FRONTEND=noninteractive apt-get -y autoremove curl \
        && rm -rf /var/lib/apt/lists/*
}

function install_python_elements()
{
    # Creating virtualenv and installing Django
    # shellcheck source=/dev/null
    exec_as_tendenci "$VIRTUALENV" "$TENDENCI_VIRTUALENV"
    # shellcheck source=/dev/null
    exec_as_tendenci "$PIP" install "Django>=1.8,<1.9"

    # Installing tendenci
    # shellcheck source=/dev/null
    cd "$TENDENCI_INSTALL_DIR" || exit 1
    exec_as_tendenci "$DJANGO_ADMIN" startproject --template="$TENDENCI_TEMPLATE" "$APP_NAME"
    cd "$APP_NAME" || exit 1
    exec_as_tendenci pip install -r requirements/dev.txt
}

check_user
check_dirs
install_jpeg_9
install_python_elements
