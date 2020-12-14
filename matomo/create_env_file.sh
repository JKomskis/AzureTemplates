#!/bin/bash

source common/get_secret.sh

set -v

output_file="matomo/.env"
rm -f $output_file

echo MYSQL_ROOT_PASSWORD=$(get_secret jkomskis-matomo-kv mysql-root-password) >> $output_file
echo MYSQL_DATABASE=$(get_secret jkomskis-matomo-kv mysql-database) >> $output_file
echo MYSQL_USER=$(get_secret jkomskis-matomo-kv mysql-user) >> $output_file
echo MYSQL_PASSWORD=$(get_secret jkomskis-matomo-kv mysql-password) >> $output_file
