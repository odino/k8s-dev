#!/bin/bash

# dev $command
arg=$1
command="cmd_$1"

# Run a bunch of checks to make sure
# everything is installed.
cmd_check(){
    skaffold >/dev/null 2>&1 || { echo >&2 "skaffold not installed correctly."; exit 1; }
    yq --help >/dev/null 2>&1 || { echo >&2 "yq not installed correctly."; exit 1; }

    echo "All good!"
}

# List all the available commands
# inside this script.
cmd_help(){
    printf "List of all available commands:\n\n"
    declare -F | grep cmd | awk '{print $3}' | cut -c 5- | awk '{print " * " $0}' | awk 'length($0)>4'
}
cmd_h(){
    cmd_help
}

# Boot the app through skaffold.
cmd_up(){
    skaffold dev
}

# This will drop you inside the container.
# We use bash, if available, else "sh"
cmd_in(){
    app=$(get_app_name)
    kubectl exec -ti deploy/$app -- sh -c "command -v bash && bash || sh"
}

# This will execute a comand inside the container.
cmd_exec(){
    app=$(get_app_name)
    kubectl exec -ti deploy/$app $@
}
cmd_x(){
    cmd_exec $@
}

# This will try to execute tests inside the app,
# based on the platform we detect.
cmd_test(){
    test_command='echo unable to infer test command'

    # If a Go main file is found, let's run all
    # go tests recursively
    if cat main.go > /dev/null 2>&1; then
        test_command="go test ./... -v"
    fi

    # If this seems to be a python project,
    # let's try pytest
    if cat requirements.txt > /dev/null 2>&1; then
        test_command="pytest"
    fi

    # If we have a Makefile, we might have a "make test"
    # command available
    if cat Makefile | grep test > /dev/null 2>&1; then
        test_command="make test"
    fi

    # NodeJS? Let's rely on the package.json and NPM
    if cat package.json > /dev/null 2>&1; then
        test_command="npm test"
    fi

    app=$(get_app_name)
    kubectl exec -ti deploy/$app -- $test_command
}
cmd_t(){
    cmd_test $@
}

# Read the app name based on the image we
# build inside the skaffold.yaml
get_app_name(){
  echo $(yq read skaffold.yaml build.artifacts.0.image)
}

# Main function: if a command has been passed,
# check if it's available, and execute it. If
# the command is not available, we print the
# default help.
main(){
    declare -f $command > /dev/null

    if [ $? -eq 0 ]
    then
        $command $@
    else
        printf "'$arg' is not a recognized command.\n\n"
        cmd_help
        exit 1
    fi
}

shift
main $@