#! /usr/bin/bash

function setup_keys()
{
    SECRET_KEY=${SECRET_KEY:-$(mcookie)}
    SITE_SETTINGS_KEY=${SITE_SETTINGS_KEY:-$(mcookie)}
    sed -i "s|SECRET_KEY='.*'$|SECRET_KEY='$SECRET_KEY'|" \
        "$TENDENCI_INSTALL_DIR/$APP_NAME/conf/local_settings.py"
    sed -i "s|SITE_SETTINGS_KEY='.*'$|SITE_SETTINGS_KEY='$SITE_SETTINGS_KEY'|" \
        "$TENDENCI_INSTALL_DIR/$APP_NAME/conf/local_settings.py"
}

function setup_db
{
    sed -i "s|'NAME': '.*',$|'NAME': '${DB_NAME:-tendenci}'" \
        "$TENDENCI_INSTALL_DIR/$APP_NAME/conf/local_settings.py"
    sed -i "s|'HOST': '.*',$|'HOST': '${DB_HOST:-localhost}'" \
        "$TENDENCI_INSTALL_DIR/$APP_NAME/conf/local_settings.py"
    sed -i "s|'USER': '.*',$|'USER': '${DB_USER:-tendenci}'" \
        "$TENDENCI_INSTALL_DIR/$APP_NAME/conf/local_settings.py"
    sed -i "s|'PASSWORD': '.*',$|'PASSWORD': '${DB_PASS:-password}'" \
        "$TENDENCI_INSTALL_DIR/$APP_NAME/conf/local_settings.py"
    sed -i "s|'PORT': '.*',$|'PORT': '${DB_PORT:-5432}'" \
        "$TENDENCI_INSTALL_DIR/$APP_NAME/conf/local_settings.py"
}

function superuser
{
    cd "$TENDENCI_INSTALL_DIR/$APP_NAME" \
        && echo "from django.contrib.auth.models import User;" \
        "User.objects.create_superuser('${ADMIN_USER:-admin}', \
        '${ADMIN_MAIL:-admin@example.com}', '${ADMIN_PASS:-password}')" | \
        python manage.py shell
}

function initial_setup
{
    [ -f "$TENDENCI_HOME/first_run" ] && return
    setup_keys
    cd "$TENDENCI_INSTALL_DIR/$APP_NAME" \
        && bash -x migrate_initials.sh \
        && python deploy.py \
        && python manage.py load_base_defaults \
        && python manage.py load_npo_defaults
    superuser
    touch "$TENDENCI_HOME/first_run"
}

function run
{
    cd "$TENDENCI_INSTALL_DIR/$APP_NAME" \
        && exec su - "$TENDENCI_USER" -c "$@"
}

setup_db
initial_setup
run "$@"
