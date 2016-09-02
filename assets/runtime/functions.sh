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

function setup_database_connection
{
    sed -i "s|'NAME': '.*',$|'NAME': '$DB_NAME'" \
        "$TENDENCI_INSTALL_DIR/$APP_NAME/conf/local_settings.py"
    sed -i "s|'HOST': '.*',$|'HOST': '$DB_HOST'" \
        "$TENDENCI_INSTALL_DIR/$APP_NAME/conf/local_settings.py"
    sed -i "s|'USER': '.*',$|'USER': '$DB_USER'" \
        "$TENDENCI_INSTALL_DIR/$APP_NAME/conf/local_settings.py"
    sed -i "s|'PASSWORD': '.*',$|'PASSWORD': '$DB_PASS'" \
        "$TENDENCI_INSTALL_DIR/$APP_NAME/conf/local_settings.py"
    sed -i "s|'PORT': '.*',$|'PORT': '$DB_PORT'" \
        "$TENDENCI_INSTALL_DIR/$APP_NAME/conf/local_settings.py"
}

function superuser
{
    cd "$TENDENCI_INSTALL_DIR/$APP_NAME" \
        && echo "from django.contrib.auth.models import User;" \
        "User.objects.create_superuser('$ADMIN_USER', \
        '$ADMIN_MAIL', '$ADMIN_PASS')" | \
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
