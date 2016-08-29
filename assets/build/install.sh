#! /usr/bin/bash -x

# Environment
VIRTUALENV=$(which virtualenv)
PIP=$(which pip)
DJANGO_TEMPLATE="https://github.com/tendenci/tendenci-project-template/archive/master.zip"

# Check directories and create them if necessary
function check_dirs()
{
    for dir in $TENDENCI_INSTALL_DIR $TENDENCI_DATA_DIR\
        $TENDENCI_LOG_DIR;
do
    [ -d "$dir" ] || mkdir "$dir"
    chown "$TENDENCI_USER:" "$dir"
done
}

# Check user to run the application, create it if not done yet
function check_user()
{
    if ! grep -i "^$TENDENCI_USER" /etc/passwd; then
        useradd -b "$TENDENCI_HOME" -U "$TENDENCI_HOME" "$TENDENCI_USER"
    fi
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
    DEBIAN_FRONTEND=noninteractive apt-get autoremove curl \
        && rm -rf /var/lib/apt/lists/*

}

function install_python_elements()
{
    # Creating virtualenv and installing Django
    # shellcheck source=/dev/null
    $VIRTUALENV "$TENDENCI_VIRTUALENV"
    # shellcheck source=/dev/null
    source "$TENDENCI_VIRTUALENV/bin/activate"
    $PIP install "Django>=1.8,<1.9"

    # Installing tendenci
    # shellcheck source=/dev/null
    cd "$TENDENCI_INSTALL_DIR" \
        && django-admin.py startproject --template="$DJANGO_TEMPLATE" "$APP_NAME" \
        && cd "$APP_NAME" \
        && $PIP install -r requirements/dev.txt
}

check_user
check_dirs
install_jpeg_9
install_python_elements
