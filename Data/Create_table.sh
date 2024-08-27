#!/bin/bash

# Function to display the database connection message
function Database_connected() {
    db_name=$1
    filler_length=$((54 - ${#db_name}))
    echo -n "| $(tput setaf 3)<$db_name "
    for ((counter = 0; counter < filler_length; counter++)); do 
        echo -n "-"; 
    done
    echo " Connected>$(tput setaf 2) |"
}

# Function to create a table with validation checks
function create_table() {
    # Check if the SQL statement is a valid CREATE TABLE statement
    if ! [[ "$entry" =~ ^(CREATE|create)\ TABLE ]]; then 
        echo "Invalid SQL Statement (-_-;)・・・"
        return
    fi
    
    # Extract table name and check its existence
    table_name=$(echo "$entry" | sed -e 's/CREATE TABLE //I' | awk -F'(' '{gsub(/^[ \t]+|[ \t]+$/, "",$1);print $1}')
    if [[ -f "$table_name" ]]; then
        echo "Error: Table Name Exists (-_-;)・・・"
        return
    fi

    # Create table files
    touch "$table_name" ".$table_name" 2>>../../error.log || { echo "Failed"; return; }

    # Extract columns and clean them
    sql_line=$(echo "$entry" | awk -F'(' '{print $2}' | awk -F')' '{gsub(/^[ \t]+|[ \t]+$/, "",$1); print $1}')
    table_columns_number=$(echo "$sql_line" | awk -F',' '{print NF}')

    has_pk=0
    table_headers=""
    
    # Check for invalid data type or multiple primary keys
    for ((i = 1; i <= table_columns_number; i++)); do
        column_details=$(echo "$sql_line" | awk -F',' -v col=$i '{print $col}' | awk '{$1=$1};1')
        column_name=$(echo "$column_details" | awk '{print $1}')
        data_type=$(echo "$column_details" | awk '{print $2}')
        primary_key=$(echo "$column_details" | awk '{print $3}')

        if [[ "$data_type" != "txt" && "$data_type" != "int" ]]; then
            echo "Error: Invalid Data Type in Column (-_-;)・・・'$i'"
            return
        fi

        if [[ "$primary_key" == "pk" ]]; then
            if (( has_pk == 0 )); then
                has_pk=1
            else
                echo "Error: More Than One Primary Key (-_-;)・・・"
                return
            fi
        fi

        table_headers+="$column_name|$data_type|$primary_key "
        echo "$column_name|$data_type|$primary_key" >>".$table_name" 2>>../../error.log || { echo "Failed"; return; }
    done

    echo "$table_headers" | sed 's/ / | /g' >>"$table_name"
    echo "Table '$table_name' created successfully (╯✧▽✧)╯"
}

clear
db_name=$1

while true; do
    tput setaf 2 # Change font color to Green
    Database_connected "$db_name" 

    cat <<EOF

        ╔══════════════════════════════════════════════════════════════════════╗
        ║                                                                      ║
        ║  e.g. CREATE TABLE table_name (column1 int pk , column2 txt , . . )  ║        
        ║                                                                      ║               
        ╚══════════════════════════════════════════════════════════════════════╝
        
     	╔═══════════════════════════╗
    	║ 1 - Back to Database Menu ║
     	║ 2 - Back to Main Menu     ║
     	╚═══════════════════════════╝

EOF

    tput setaf 5 # Change font color to purple
    read -p "$(tput setaf 5)Enter SQL CREATE Statement : " entry
    case $entry in
        1) 
            echo "You selected Back to Database Menu"
            exit ;;
        2) 
            echo "You selected Back to Main Menu"
            exit 2 ;;
        *) 
            create_table ;;
    esac
done
