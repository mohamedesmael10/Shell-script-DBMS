#!/bin/bash
function Database_connected() {
    db_name=$1
    typeset -i filler_length
    filler_length=(20-${#db_name})
    echo -n "| $(tput setaf 3)<$1 "
    for ((counter = 0; counter < filler_length; counter++)); do echo -n "-"; done
    echo " Connected>$(tput setaf 2) |"
    # EX: | <TestDB ----- Connected> |

}
function execute_sql() {
    sql_line=${entry//;/ }
    table_name=$(echo "$sql_line" | awk '{print $3}')
    if [[ ! -f "$table_name" ]]; then echo "Error : Invalid Table Name or Invalid Selection (-_-;)・・・ " ; return; fi

    select_column=$(echo "$sql_line" | awk '{print $1}')
    select_column_field=$(awk -F'|' 'BEGIN{found=0} {if(NR==1){for(i=1;i<=NF;i++){if($i=="'$select_column'")found=i}}} END{print found}' "$table_name")
    if [[ $select_column_field == 0 ]] && [[ $select_column != "*" ]]; then echo "Error : Invalid Selected Column Name (-_-;)・・・" && return; fi

    if [[ "$sql_line" =~ WHERE ]]; then
        where_column=$(echo "$sql_line" | awk '{print $5}')
        where_column_field=$(awk -F'|' 'BEGIN{found=0} {if(NR==1){for(i=1;i<=NF;i++){if($i=="'$where_column'")found=i}}} END{print found}' "$table_name")
        if [[ $where_column_field == 0 ]]; then echo "Error : Invalid Where Column Name (-_-;)・・・"; return; fi

        where_operator=$(echo "$sql_line" | awk '{print $4}')
        where_value=$(echo "$sql_line" | awk '{print $6}')
        where_value_exist=$(awk -F'|' 'BEGIN{found=0} {if(NR!=1){if($"'$where_column_field'"=="'$where_value'")found=1}} END{print found}' "$table_name")
        if [[ $where_value_exist == 0 ]]; then echo "Warning : The Where Value does not exist in the Table (-_-;)・・・ "; fi

        if [[ $select_column == "*" ]]; then
            awk -v were_value="$where_value" -F'|' '{if(NR!=1){if($"'$where_column_field'" '$where_operator' were_value){print $0}}}' "$table_name"
        else
            awk -v were_value="$where_value" -F'|' '{if(NR!=1){if($'"$where_column_field"' '$where_operator' were_value){print $'"$select_column_field"'}}}' "$table_name"
        fi
    else
        if [[ $select_column == "*" ]]; then
            cat "$table_name"
        else
            awk 'BEGIN{FS="|"}{print $'"$select_column_field"'}' "$table_name"
        fi
    fi
}

    clear
    db_name=$1
    while true; do
    tput setaf 2 
    cat <<EOF
     	╔═══════════════════════════╗
    	║ $db_name Connected        ║
     	╚═══════════════════════════╝
        ╔══════════════════════════════════════════════════════════════════════════════╗
        ║    e.g. SELECT *; FROM table_name;                                           ║
        ║    SELECT column; FROM table_name;                                           ║
        ║    SELECT column ; FROM table_name ; WHERE column[==,<,>,>=,<=]value ;       ║
        ║    SELECT * ; FROM table_name ; WHERE column[==,<,>,>=,<=]value ;            ║
        ║    SELECT column; FROM table_name;                                           ║
        ║    SELECT *; FROM table_name;                                                ║
        ╚══════════════════════════════════════════════════════════════════════════════╝
     	╔═══════════════════════════╗
    	║ 1 - Back to Database Menu ║
     	║ 2 - Back to Main Menu     ║
     	╚═══════════════════════════╝
EOF

    tput setaf 5
    read -p "$(tput setaf 5)Enter SQL Statement : " Select
    case $Select in
    1) 
    echo "You selected Back to Database Menu "
    exit ;;
    2) 
    echo "You selected Back to Main Menu "
    exit 2 ;;
    *) execute_sql ;;
         
    esac
done