#!/bin/bash

create_database() {
    db_name=$1
    db_path="DBMS/$db_name"

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
        echo "Oops.. Try again! (-_-;)・・・"
        exit 1
    fi
}

# Prompt the user for the database name
read -p "Enter the name of the database to create: " db_name

# Call the function to create the database
create_database "$db_name"
