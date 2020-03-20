#!/bin/bash

sha=0
previous_sha=0

update_sha()
{
    sha=`ls -lR . | sha1sum`
}

build () {
    ## Build/make commands here
    echo
    echo "--> Monitor: Files changed, Building..."
    echo "--> Monitor: Monitoring filesystem... (Press enter to force a build/update)"
    make test
}

changed () {
    echo "--> Monitor: Files changed, Building..."
    build
    previous_sha=$sha
}

compare () {
    update_sha
    if [[ $sha != $previous_sha ]] ; then changed; fi
}

run () {
    while true; do

        compare

        read -s -t 1 && (
            echo "--> Monitor: Forced Update..."
            build
        )

    done
}

echo "--> Monitor: Init..."
echo "--> Monitor: Monitoring filesystem... (Press enter to force a build/update)"
run
