#!/bin/bash
function Database_connected(){
    local db_name=$1
    local filler_length=$((${#db_name} < 54 ? 54 - ${#db_name} : 0))
    echo -n "| $(tput setaf 3)<$1 "
    for ((i = 0; i < filler_length; i++)); do echo -n "-"; done
    echo " Connected>$(tput setaf 2) |"
    # EX: | <TestDB ----- Connected> |
}


function execute_sql_delete(){
    sql_line=${entry^^} # convert to uppercase
    sql_line=${sql_line//DELETE/} # remove DELETE
    sql_line=${sql_line//FROM/} # remove FROM
    sql_line=${sql_line//WHERE/} # remove WHERE

    local fields_no=$(echo "$sql_line" | awk -F';' 'END{print NF}')
    local table_name=$(echo "$sql_line" | awk -F';' '{gsub(/^[ \t]+|[ \t]+$/, "",$1);print $1}')

    if [[ ! -f "$table_name" ]]; then
        echo "Error : Invalid Table Name"
        return
    fi

    if ((fields_no == 2)); then
        awk -i inplace -F'|' '{if(NR==1){print $0}}' "$table_name"
        return
    fi

    local where_operator=$(echo "$sql_line" | awk -F';' '{print $2}' | sed -e 's/[a-zA-Z]*//g' -e 's/[0-9]*//g' -e's/ //g')
    if ! [[ "$where_operator" =~ ^(==|>|<|>=|<=)$ ]]; then
        echo "Error : Invalid Where Operator"
        return
    fi

    local where_column=$(echo "$sql_line" | awk -F';' '{print $2}' | awk -F"$where_operator" '{gsub(/^[ \t]+|[ \t]+$/, "",$1);print $1}')
    local where_column_field=$(awk -F'|' 'BEGIN{found=0} {if(NR==1){for(i=1;i<=NF;i++){if($i=="'$where_column'")found=i}}} END{print found}' "$table_name")
    if ((where_column_field == 0)); then
        echo "Error : Invalid Where Column Name"
        return
    fi

    local where_value=$(echo "$sql_line" | awk -F';' '{print $2}' | awk -F"$where_operator" '{gsub(/^[ \t]+|[ \t]+$/, "",$2);print $2}')
    local where_value_exist=$(awk -F'|' 'BEGIN{found=0} {if(NR!=1){if($"'$where_column_field'"=="'$where_value'")found=1}} END{print found}' "$table_name")
    if ((where_value_exist == 0)); then
        echo "Warning : The Where Value does not exist in the Table "
    fi

    awk -v where_value="$where_value" -i inplace -F'|' '{if(!($'$where_column_field' '$where_operator' where_value)){print $0}}' "$table_name"
    echo "Deleted Successfully"

}

clear
db_name=$1
while true; do
    tput setaf 2
    cat <<EOF
     	╔═══════════════════════════╗
    	║ $db_name Connected        ║
     	╚═══════════════════════════╝
        ╔══════════════════════════════════════════════════════════════════════╗
        ║    e.g. DELETE FROM table_name WHERE column[==,<,>,>=,<=]value;      ║
        ║    DELETE FROM table_name;                                           ║                                                              
        ╚══════════════════════════════════════════════════════════════════════╝
     	╔═══════════════════════════╗
    	║ 1 - Back to Database Menu ║
     	║ 2 - Back to Main Menu     ║
     	╚═══════════════════════════╝
EOF

    tput setaf 5
    read -p "$(tput setaf 5)Enter SQL Delete Statement : " Select
    case $Select in
    1) 
    echo "You selected Back to Database Menu "
    exit ;;
    2) 
    echo "You selected Back to Main Menu "
    exit 2 ;;
    *) execute_sql_delete"$Select" ;;
    esac
done