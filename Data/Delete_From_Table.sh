#!/bin/bash

# Display connected database line with styling
function Database_connected() {
    db_name=$1
    filler_length=$((54 - ${#db_name}))
    echo -n "| $(tput setaf 3)<$db_name "
    printf "%${filler_length}s" | tr ' ' '-'
    echo " Connected>$(tput setaf 2) |"
}

# Delete records from table with SQL-like syntax and validation
function execute_sql_delete {
    # Normalize and split SQL-like statement
    sql_line=$(echo "$1" | sed -E 's/DELETE|FROM|WHERE//Ig' | awk '{gsub(/^[ \t]+|[ \t]+$/, ""); print}')
    
    # Split the line into table name and where clause
    table_name=$(echo "$sql_line" | awk -F';' '{print $1}' | xargs)
    where_clause=$(echo "$sql_line" | awk -F';' '{print $2}' | xargs)

    # Validate table name
    if [[ ! -f "$table_name" ]]; then echo "Error: Invalid Table Name"; return; fi

    # Handle DELETE without WHERE clause
    if [[ -z "$where_clause" ]]; then
        awk -F'|' 'NR==1' "$table_name" > temp && mv temp "$table_name"
        echo "All records deleted successfully, except the header."
        return
    fi

    # Extract where operator and validate
    where_operator=$(echo "$where_clause" | sed -E 's/[a-zA-Z0-9 ]//g')
    if ! [[ "$where_operator" =~ ^(==|>|<|>=|<=)$ ]]; then echo "Error: Invalid Where Operator"; return; fi

    # Extract and validate where column
    where_column=$(echo "$where_clause" | cut -d"$where_operator" -f1 | xargs)
    where_column_field=$(awk -F'|' 'NR==1 {for(i=1; i<=NF; i++) if($i=="'$where_column'") print i}' "$table_name")
    if [[ -z "$where_column_field" ]]; then echo "Error: Invalid Where Column Name"; return; fi

    # Extract and validate where value
    where_value=$(echo "$where_clause" | cut -d"$where_operator" -f2 | xargs)
    where_value_exist=$(awk -F'|' -v col="$where_column_field" '$col=="'$where_value'"{found=1} END{print found+0}' "$table_name")
    if ((where_value_exist == 0)); then echo "Warning: The Where Value does not exist in the Table"; fi

    # Perform deletion
    awk -v op="$where_operator" -v val="$where_value" -F'|' 'NR==1 || !($'$where_column_field' op val)' "$table_name" > temp && mv temp "$table_name"
    echo "Deleted Successfully"
}

clear
db_name=$1
while true; do
    tput setaf 2 # Change font color to green
    Database_connected "$db_name"

    cat <<EOF

        ╔══════════════════════════════════════════════════════════════════════╗
        ║    e.g. DELETE FROM table_name WHERE column[==,<,>,>=,<=]value;      ║
        ║    DELETE FROM table_name;                                           ║        
        ║                                                                      ║               
        ╚══════════════════════════════════════════════════════════════════════╝
        
     	╔═══════════════════════════╗
    	║ 1 - Back to Database Menu ║
     	║ 2 - Back to Main Menu     ║
     	╚═══════════════════════════╝

EOF

    tput setaf 5
    read -p "$(tput setaf 5)Enter SQL Delete Statement : " entry
    case $entry in
    1) 
    echo "You selected Back to Database Menu"
    exit ;;
    2) 
    echo "You selected Back to Main Menu"
    exit 2 ;;
    *) execute_sql_delete "$entry" ;;
    esac
done