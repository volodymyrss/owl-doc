#!/bin/bash

function generate() {
    echo

    D=$(pwd)

    function cleanup() {
         echo "cleaning up!"
         lodes=$(ps aux | awk '/LODE/ && !/grep/ {print $2}')
         [ "$lodes" != "" ] && {
             echo "found lode: $lodes"
             kill -9 $lodes
         }
        [ "$http_server_pid" != "" ] && kill -9 $http_server_pid
    }
    
    cleanup

    python -m http.server 8000 &
    http_server_pid=$!


    (cd ../LODE; mvn clean jetty:run > $D/lode.log 2>&1; )&

    trap 'cleanup' EXIT

    while true; do
        echo "waiting for lode..."
        tail -n 1 $D/lode.log
        tail -1 $D/lode.log | grep 'Starting scanner at interval' && break
        sleep 1
    done

    curl 'http://localhost:8080/lode/extract?url=http%3A%2F%2Flocalhost:8000%2Frdf.ttl&owlapi=true&imported=true&closure=true&reasoner=true&lang=en' > odaowl.html

    python make.py

    ls -l odaowl.html
    wc odaowl.html
}

$@
