#!/bin/bash

#
# db-import.sh - Script for importing an MSSQL database using sqlpackage
#
# Copyright (C) 2024 Maikel Enrique Pernia Matos
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.


RED='\e[31m'
BLUE='\e[34m'
GREEN='\e[32m'
YELLOW='\e[33m'
RESET='\e[0m'
LIGHT='\e[1m'
UNDERLINE='\e[4m'
RED_BG_WHITE='\e[41;97m'

HOST=127.0.0.1
PORT=1433
USER=sa
PASSWD=password
DATABASE=
FILENAME=


function show_help()
{
    printf "${BLUE}${LIGHT}Usage: db-import.sh ${RESET}${BLUE}[${UNDERLINE}options${RESET}${BLUE}]${RESET}\n"
    printf "${BLUE}Options:${RESET}\n"
    printf "${BLUE}${LIGHT} -f|--file, The filepath to import ${RESET}\n"
    printf "${BLUE}${LIGHT} -d|--database, Database name to import${RESET}\n"
    printf "${BLUE}${LIGHT} -h|--help, Display help for the list command${RESET}\n"
    return 0
}

function abort()
{
    show_help
    printf "\n"
    exit 1
}


function import_database() 
{
    printf "${GREEN}Importing to database '${DATABASE}' "
    printf "on server '${HOST}', port: '${PORT}'.${RESET}\n"

    sqlpackage \
        /Action:Import \
        /SourceFile:"${FILENAME}" \
        /TargetConnectionString:"Server=tcp:${HOST},${PORT};Database=${DATABASE};User ID=${USER};Password=${PASSWD};Encrypt=False;TrustServerCertificate=True"

    if [ $? -eq 0 ]; then
        echo "${GREEN}The import to database '${DATABASE}' completed successfully.${RESET}\n"
    else
        echo "${RED_BG_WHITE}An error occurred while importing database '${YELLOW}${DATABASE}${RESET}'.${RESET}\n"
        exit 1
    fi
}

if [[ "${1}" == "" ]];then
    abort
fi

while [[ $# -gt 0 ]]; do
    case "${1}" in
        -f|--file)
            shift
            FILENAME="${1}"
            ;;
        -d|--database)
            shift
            DATABASE="${1}"
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            printf "${RED_BG_WHITE}Unknown option or invalid argument: ${YELLOW}$1${RESET}\n"
            exit 1
            ;;
    esac
    shift
done

if [ -z "${FILENAME}" ] || [ -z "${DATABASE}" ]; then
  abort
fi

import_database

printf "${GREEN}Bye!${RESET}\n"


