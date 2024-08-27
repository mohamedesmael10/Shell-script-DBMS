#!/bin/bash

# Prompt the user to enter the database name
read -p "Enter Database Name: " name

# Check if the directory for the database exists
if [ -d "DBMS/$name" ]; then
    # Confirm if the user wants to delete the database
    read -p "Are you sure you want to delete '$name'? (Y/N): " choice
    case $choice in
        [yY]|[yY][eE][sS])
            rm -r "DBMS/$name" && echo "$name deleted successfully" || echo "Failed to delete $name"
            ;;
        [nN]|[nN][oO])
            echo "Operation canceled"
            ;;
        *)
            echo "Invalid option. Please enter Y or N."
            ;;
    esac
else
    echo "Database '$name' does not exist."
fi
