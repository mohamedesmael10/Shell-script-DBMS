#!/bin/bash

function db_connected {
    local db_name=$1
    local filler_length=$((${#db_name} < 54 ? 54 - ${#db_name} : 0))
    echo -n "| $(tput setaf 3)<$1 "
    for ((i = 0; i < filler_length; i++)); do echo -n "-"; done
    echo " Connected>$(tput setaf 2) |"
}

function delete_with_check {
    local table_name=$(echo "$1" | awk '{print $3}')
    local where_column=$(echo "$1" | awk '{print $5}')
    local where_operator=$(echo "$1" | awk '{print $4}')
    local where_value=$(echo "$1" | awk '{print $6}')

    if [[ ! -f "$table_name" ]]; then
        echo "Error : Invalid Table Name or Invalid Selection (-_-;)・・・"
        return
    fi

    if ! [[ "$where_operator" =~ ^(==|>|<|>=|<=)$ ]]; then
        echo "Error : Invalid Where Operator (-_-;)・・・"
        return
    fi

    local where_column_field=$(awk -F'|' 'BEGIN{found=0} {if(NR==1){for(i=1;i<=NF;i++){if($i=="'$where_column'")found=i}}} END{print found}' "$table_name")
    if ((where_column_field == 0)); then
        echo "Error : Invalid Where Column Name (-_-;)・・・"
        return
    fi

    local where_value_exist=$(awk -F'|' 'BEGIN{found=0} {if(NR!=1){if($"'$where_column_field'"=="'$where_value'")found=1}} END{print found}' "$table_name")
    if ((where_value_exist == 0)); then
        echo "Warning : The Where Value does not exist in the Table (-_-;)・・・ "
    fi

    awk -v were_value="$where_value" -i inplace -F'|' '{if(!($'$where_column_field'  '$where_operator' were_value)){print $0}}' "$table_name"
    echo "Deleted Successfully (╯✧▽✧)╯"
}

clear
db_name=$1
while true; do

    cat <<EOF
     	╔═══════════════════════════╗
    	║ $db_name Connected        ║
     	╚═══════════════════════════╝
        ╔══════════════════════════════════════════════════════════════════════╗
        ║    e.g. DELETE FROM table_name WHERE column[==,<,>,>=,<=]value;      ║
        ║    DELETE FROM table_name;                                           ║                                                                ║
        ╚══════════════════════════════════════════════════════════════════════╝
     	╔═══════════════════════════╗
    	║ 1 - Back to Database Menu ║
     	║ 2 - Back to Main Menu     ║
     	╚═══════════════════════════╝
EOF

    tput setaf 5
    read -p "$(tput setaf 5)Enter SQL Delete Statement : " Select
    case $Select in
    1) exit ;;
    2) exit 2 ;;
    *) delete_with_check "$Select" ;;
    esac
done