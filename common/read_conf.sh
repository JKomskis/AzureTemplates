#!/bin/bash

declare -A config # init array

read_conf() {
    while read line
    do
        if echo $line | grep -F = &>/dev/null
        then
            varname=$(echo "$line" | cut -d '=' -f 1)
            config[$varname]=$(echo "$line" | cut -d '=' -f 2-)
        fi
    done < $1
}