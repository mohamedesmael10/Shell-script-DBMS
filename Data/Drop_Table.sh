#!/bin/bash

# Prompt the user to enter the table name
read -p "Enter Table Name to be Deleted: " name

# Check if the file corresponding to the table exists
if [ -f "$name" ]; then
    # Confirm with the user before deletion
    read -p "Are you sure you want to delete the table '$name'? (Y/N): " choice
    case $choice in
        [yY]|[yY][eE][sS]) rm $name .$name; echo "Table Deleted Successfully (╯✧▽✧)╯" ;;
        [nN]|[nN][oO])
            echo "Operation canceled (・_・;)"
            ;;
        *)
            echo "Invalid option. Please enter Y or N. (・_・;)"
            ;;
    esac
else
    echo "Table '$name' does not exist. (・_・;)"
fi
