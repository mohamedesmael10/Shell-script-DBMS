#!/bin/bash
echo -n "Enter the Database name : "
read db_name

create_database() {
    local db_name=$1
    local db_path="DBMS/$db_name"

    # Check if the database already exists
    if [ -d "$db_path" ]; then
        echo "The database '$db_name' already exists! (-_-;)・・・"
        exit 1
    fi

    # Create the database directory
    mkdir -p "$db_path" 2>>error.log
    if [ $? -eq 0 ]; then
        echo "Welcome! Your database '$db_name' is ready! (╯✧▽✧)╯"
    else
        echo "Ops.. Try again! (-_-;)・・・"
        exit 1
    fi
}

create_database "$db_name"