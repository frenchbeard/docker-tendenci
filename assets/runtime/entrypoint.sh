#! /bin/bash

# Automatically expand variables
set -e

# Retrieve functions
# shellcheck source=/dev/null
source ${TENDENCI_RUNTIME_DIR}/functions.sh

# Debug setup
[[ $DEBUG == true ]] && set -x

case ${1} in
    app:init|app:start|app:reset)

    setup_database_connection

    case ${1} in
        app:start)
            initial_setup
            run
            ;;
        app:init)
            initial_setup
            ;;
        app:reset)
            initial_setup
            reset_setup
            ;;
    esac
    ;;

    app:help)
        echo "Available options:"
        echo " app:start    - Starts the tendenci server (default)."
        echo " app:init     - Initializes the tendenci server (e.g. create databases, migrate necessary data), but don't start it."
        echo " app:reset    - Resets to an \"empty\" tendenci."
        echo " app:help     - Displays this help."
        echo " [command]    - Executes the specified command. e.g. bash."
        ;;
    *)
        exec "$@"
        ;;
esac
