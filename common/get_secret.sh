#!/bin/bash

get_secret() {
    az keyvault secret show --vault-name $1 --name $2 | jq --raw-output ".value"
}