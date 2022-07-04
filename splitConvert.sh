#!/bin/bash

CURRENT_DIR=`pwd`

# COLORS
red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
blue='\033[0;34m'
magenta='\033[0;35m'
cyan='\033[0;36m'
# Clear the color after that
clear='\033[0m'

help()
{
   # print help menu
    echo "-----------------------------------------------------------------------------"
    echo "Split Convert takes a SQL file from SRC dialect->"
    echo "   splits file by LINE count into split dir"
    echo "   converts to TARGET SQL dialect into conv dir"
    echo ""
    echo "Syntax: ./splitConvert.sh -f <SQL_FILE> -l <SPLIT_LINES> -s <SRC> -t <TARGET>"
    echo "Options:"
    echo "  -h     Print this Help."
    echo "  -f     SQL input file."
    echo "  -l     Line count to split."
    echo "  -s     SOURCE dialect."
    echo "  -t     TARGET dialect."
    echo ""
    echo "Supported SRC dialects:"
    echo ""
    echo "NOTE -> sqlines is required on PATH"
    echo "-----------------------------------------------------------------------------"
}

print_error_banner(){
    echo ""
    echo "--------------------------------------------------"
    echo -e " ${red}ERROR${clear} : $1"
    echo "--------------------------------------------------"
}

print_info_banner(){
    echo -e " ${blue}INFO${clear} : $1"
}

check_dir()
{
    # check if split dir exists
    if [ ! -d "$CURRENT_DIR/split" ] || [ ! -d "$CURRENT_DIR/conv" ]; then
        print_info_banner "Creating directories"
        mkdir -pv ./{split,conv}
    # if exists and not empty - ask to delete
    elif [ $(ls -A "$CURRENT_DIR/split" | wc -l) -gt 0 ]; then
        print_info_banner "./split is NOT empty"
        while true; do
            echo ""
            read -p "DELETE dir ./split/? [y/n] " yn

            case $yn in
                [Yy]* ) rm -rfv ./split; break;;
                [Nn]* ) break;;
                * ) echo "Please answer yes or no.";;
            esac
        done
    else
        print_info_banner "./split is empty"
    fi

    if [ $(ls -A "$CURRENT_DIR/conv" | wc -l) -gt 0 ]; then
        print_info_banner "./conv is not empty"
        while true; do
            echo ""
            read -p "DELETE dir ./conv/? [y/n] " yn

            case $yn in
                [Yy]* ) rm -rfv ./conv; break;;
                [Nn]* ) break;;
                * ) echo "Please answer yes or no.";;
            esac
        done
    else
        print_info_banner "./conv is empty"
    fi

    #  now if we removed the split & conv dir ask to create it
    if [ ! -d "$CURRENT_DIR/split" ] || [ ! -d "$CURRENT_DIR/conv" ]; then
    while true; do
            echo ""
            read -p "CREATE directories split,conv? [y/n] " yn
            case $yn in
                [Yy]* ) mkdir -pv ./{split,conv}; break;;
                [Nn]* ) break;;
                * ) echo "Please answer yes or no.";;
            esac
        done
    fi
}

check_options()
{
    # check if options are set
    if [ -z "$SQL_FILE" ]; then
        print_error_banner "SQL_FILE is not set"
        exit 1
    fi
    if [ -z "$SPLIT_LINES" ]; then
        print_error_banner "SPLIT_LINES is not set"
        exit 1
    fi
    if [ -z "$SRC" ]; then
        print_error_banner "SRC is not set"
        exit 1
    fi
    if [ -z "$TARGET" ]; then
        print_error_banner "TARGET is not set"
        exit 1
    fi
}

check_source_dialect()
{
    # check if SRC dialect is supported
    case "$SRC" in
        mysql )
            SRC_DIALECT="mysql"
            ;;
        postgresql )
            SRC_DIALECT="postgresql"
            ;;
        sqlite )
            SRC_DIALECT="sqlite"
            ;;
        spark )
            SRC_DIALECT="spark"
            ;;
        db2 )
            SRC_DIALECT="db2"
            ;;
        sql )
            SRC_DIALECT="sql"
            ;;
        oracle )
            SRC_DIALECT="oracle"
            ;;
        mariadb )
            SRC_DIALECT="mariadb"
            ;;
        hive )
            SRC_DIALECT="hive"
            ;;
        * )
            print_error_banner "INVALID SOURCE | [mysql, postgresql, sqlite, spark, db2, sql, oracle, mariadb, hive]"
            exit 1
            ;;
    esac
}

check_target_dialect()
{
    case "$TARGET" in
        mysql )
            TARGET_DIALECT="mysql"
            ;;
        postgresql )
            TARGET_DIALECT="postgresql"
            ;;
        sqlite )
            TARGET_DIALECT="sqlite"
            ;;
        spark )
            TARGET_DIALECT="spark"
            ;;
        db2 )
            TARGET_DIALECT="db2"
            ;;
        sql )
            TARGET_DIALECT="sql"
            ;;
        oracle )
            TARGET_DIALECT="oracle"
            ;;
        mariadb )
            TARGET_DIALECT="mariadb"
            ;;
        hive )
            TARGET_DIALECT="hive"
            ;;
        * )
            print_error_banner "INVALID TARGET | [mysql, postgres, sqlite, spark, db2, sql, oracle, mariadb, hive]"
            exit 1
            ;;
    esac
}

call_split(){
    print_info_banner "Splitting file into $SPLIT_LINES lines"
    split -l $SPLIT_LINES $SQL_FILE ./split/
    print_info_banner "Splitting done"
}

call_sqlines(){
    print_info_banner "Converting files"
    sqlines -s=$SRC_DIALECT -t=$TARGET_DIALECT -in='./split/*' -out=./conv/
    echo ""
    print_info_banner "Converting done"
}

clean_split(){
    print_info_banner "Cleaning split dir"
    rm -rfv ./split/*
    print_info_banner "Cleaning done"
}

while getopts "f:l:s:t:" opt; do
    case $opt in
        f)
            SQL_FILE=$OPTARG
            if [ ! -f $SQL_FILE ]; then
                print_error_banner "SQL file not found : $SQL_FILE"
                exit 1
            fi
            ;;
        l)
            SPLIT_LINES=$OPTARG
            if [ ! $SPLIT_LINES -gt 0 ]; then
                print_error_banner "SPLIT_LINES must be greater than 0"
                exit 1
            fi
            ;;
        s)
            SRC=$OPTARG
            if ! check_source_dialect; then
                exit 1
            fi
            ;;
        t)
            TARGET=$OPTARG
            if ! check_target_dialect; then
                exit 1
            fi
            ;;
        h)
            help
            exit 0
            ;;
        \?)
            print_error_banner "Invalid option: -$OPTARG"
            help
            exit 1
            ;;
        :)
            print_error_banner "Option -$OPTARG requires an argument."
            help
            exit 1
            ;;
    esac
done

check_options
check_dir
call_split
call_sqlines
# clean_split

# TO DO -> check if folders are created before starting call_split - doesn;t check and assumes user say yes to create.
# script should be callable from anywhere to anywhere not just the current dir.