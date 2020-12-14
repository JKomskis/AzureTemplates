#!/bin/bash

# read config file
source common/read_conf.sh
read_conf "matomo/deployment/matomo.conf"

set -v

az account set \
    --subscription ${config[subscription]}

az group delete \
    --name matomo-rg \
    --yes