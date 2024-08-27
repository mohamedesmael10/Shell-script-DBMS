#!/bin/bash
function Database_connected() {
    db_name=$1
    typeset -i filler_length
    filler_length=$((54 - ${#db_name}))
    echo -n "| $(tput setaf 3)<$db_name "
    for ((counter = 0; counter < filler_length; counter++)); do echo -n "-"; done
    echo " Connected>$(tput setaf 2) |"
}

function create_table() {
    # Check if the SQL statement starts with CREATE TABLE
    if ! [[ "$entry" =~ ^[[:space:]]*CREATE[[:space:]]+TABLE ]]; then
        echo "Invalid SQL Statement"
        return
    fi
    
    # Remove SQL specific words and extract table name and columns
    sql_line=$(echo "$entry" | sed -e 's/CREATE[[:space:]]*TABLE[[:space:]]*//' -e 's/[[:space:]]*;$//')
    table_name=$(echo "$sql_line" | awk -F'(' '{gsub(/^[ \t]+|[ \t]+$/, "",$1);print $1}')
    
    # Check if the table already exists
    if [[ -f "$table_name" ]]; then
        echo "Error: Table Name Exists"
        return
    fi
    
    # Create table files
    touch "$table_name" 2>>../../error.log || { echo "Failed to create table file"; return; }
    touch ".$table_name" 2>>../../error.log || { echo "Failed to create table metadata file"; return; }
    
    # Clean up column definitions
    sql_line=$(echo "$sql_line" | awk -F'(' '{print $2}' | awk -F')' '{ gsub(/^[ \t]+|[ \t]+$/, "",$1); print $1}')
    
    # Get the number of columns
    table_columns_number=$(echo "$sql_line" | awk -F',' 'END{print NF}')
    
    has_pk=0
    table_fields=""
    table_headers=""
    
    # Check for invalid data types or more than one primary key
    for ((i = 1; i <= $table_columns_number; i++)); do
        column_definition=$(echo "$sql_line" | awk -F',' '{print $'$i'}')
        column_name=$(echo "$column_definition" | awk '{print $1}')
        data_type=$(echo "$column_definition" | awk '{print $2}')
        primary_key=$(echo "$column_definition" | awk '{print $3}')
        
        if [[ "$data_type" != "txt" && "$data_type" != "int" ]]; then
            echo "Error: Invalid Data Type in Column ['$i']"
            return
        fi
        
        if [[ "$primary_key" == "pk" ]]; then
            if ((has_pk == 0)); then
                has_pk=1
            else
                echo "Error: More Than One Primary Key"
                return
            fi
        fi
        
        table_headers="${table_headers}|${column_name}"
        
        if [[ "$primary_key" == "pk" ]]; then
            table_fields="${table_fields}${column_name}|${data_type}|${primary_key}"
        else
            table_fields="${table_fields}${column_name}|${data_type}"
        fi
        
        echo "$table_fields" >> ".$table_name" 2>>../../error.log || { echo "Failed to write table fields"; return; }
    done
    
    echo "${table_headers:1}" >> "$table_name"
    echo "Created Successfully"
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
