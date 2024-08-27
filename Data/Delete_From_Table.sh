#!/bin/bash

function Database_connected() {
    db_name=$1
    filler_length=$((54 - ${#db_name}))
    echo -n "| $(tput setaf 3)<$db_name "
    printf "%${filler_length}s" | tr ' ' '-'
    echo " Connected>$(tput setaf 2) |"
}

function execute_sql_delete() {
    # remove SQL specific words
    sql_line=$(echo "$entry" | sed -e 's/DELETE//g' -e 's/FROM//g' -e 's/WHERE//g' | sed -e 's/delete//g' -e 's/from//g' -e 's/where//g')

    # get fields. No
    fields_no=$(echo "$sql_line" | awk -F';' 'END{print NF}')

    # get table and check its existence
    table_name=$(echo "$sql_line" | awk -F';' '{gsub(/^[ \t]+|[ \t]+$/, "",$1);print $1}')
    if [[ ! -f "$table_name" ]]; then echo "Error : Invalid Table Name" ; return; fi

    if ((fields_no == 2)); then
        awk -F'|' '{if(NR==1){print $0}}' "$table_name" > temp && mv temp "$table_name"
        return
    else
        # get and check the where operator
        where_operator=$(echo "$sql_line" | awk -F';' '{print $2}' | sed -e 's/[a-zA-Z]*//g' -e 's/[0-9]*//g' -e 's/ //g')
        if ! [[ "$where_operator" =~ ^(==|>|<|>=|<=)$ ]] ; then echo "Error : Invalid Where Operator"; return; fi

        # get the column in the WHERE condition and check its existence
        where_column=$(echo "$sql_line" | awk -F';' '{print $2}' | awk -F''$where_operator'' '{gsub(/^[ \t]+|[ \t]+$/, "",$1);print $1}')
        where_column_field=$(awk -F'|' 'BEGIN{found=0} {if(NR==1){for(i=1;i<=NF;i++){if($i=="'$where_column'")found=i}}} END{print found}' "$table_name")
        if ((where_column_field == 0)); then echo "Error : Invalid Where Column Name"; return; fi

        # get the value in the WHERE condition and check its existence
        where_value=$(echo "$sql_line" | awk -F';' '{print $2}' | awk -F''$where_operator'' '{gsub(/^[ \t]+|[ \t]+$/, "",$2);print $2}')
        where_value_exist=$(awk -F'|' 'BEGIN{found=0} {if(NR!=1){if($"'$where_column_field'"=="'$where_value'")found=1}} END{print found}' "$table_name")
        if ((where_value_exist == 0)); then echo "Warning : The Where Value does not exist in the Table "; fi

        # Delete the records
        awk -v were_value="$where_value" -F'|' '{if(!($'$where_column_field'  '$where_operator' were_value)){print $0}}' "$table_name" > temp && mv temp "$table_name"
    fi
    echo "Deleted Successfully"
}

clear
db_name=$1
while true; do
    tput setaf 2 # Change font color to green
    Database_connected "$db_name"

    cat <<EOF

        ╔══════════════════════════════════════════════════════════════════════╗
        ║    e.g. DELETE FROM table_name ; WHERE column[==,<,>,>=,<=]value;    ║
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
    *) execute_sql_delete  ;;
    esac
done
