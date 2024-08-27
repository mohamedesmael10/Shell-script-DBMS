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
function execute_sql_select() {
    # Remove SQL specific words
    sql_line=$(echo "$entry" | sed -e 's/SELECT//Ig' -e 's/FROM//Ig' -e 's/WHERE//Ig')

    # Get fields count
    fields_no=$(echo "$sql_line" | awk -F';' 'END{print NF}')

    # Get table name and check its existence
    table_name=$(echo "$sql_line" | awk -F';' '{gsub(/^[ \t]+|[ \t]+$/, "", $2); print $2}')
    if [[ ! -f "$table_name" ]]; then echo "Error: Invalid Table Name"; return; fi

    # Get the selection column and check its existence
    select_column=$(echo "$sql_line" | awk -F';' '{gsub(/^[ \t]+|[ \t]+$/, "", $1); print $1}')
    select_column_field=$(awk -F'|' 'NR==1{for(i=1;i<=NF;i++){if($i=="'$select_column'")print i}}' "$table_name")
    if [[ -z $select_column_field ]] && [[ $select_column != "*" ]]; then echo "Error: Invalid Selected Column Name"; return; fi

    if ((fields_no == 3)); then
        if [ "$select_column" == "*" ]; then
            cat "$table_name"
        else
            awk -v col=$select_column_field 'BEGIN{FS="|"}{print $col}' "$table_name"
        fi
        return
    else
        # Get and check the where operator
        where_operator=$(echo "$sql_line" | awk -F';' '{print $3}' | sed -e 's/[a-zA-Z]*//g' -e 's/[0-9]*//g' -e 's/ //g')
        if ! [[ "$where_operator" =~ ^(==|>|<|>=|<=)$ ]]; then echo "Error: Invalid Where Operator"; return; fi

        # Get the column in the WHERE condition and check its existence
        where_column=$(echo "$sql_line" | awk -F';' '{print $3}' | awk -F"$where_operator" '{gsub(/^[ \t]+|[ \t]+$/, "", $1); print $1}')
        where_column_field=$(awk -F'|' 'NR==1{for(i=1;i<=NF;i++){if($i=="'$where_column'")print i}}' "$table_name")
        if [[ -z $where_column_field ]]; then echo "Error: Invalid Where Column Name"; return; fi

        # Get the value in the WHERE condition
        where_value=$(echo "$sql_line" | awk -F';' '{print $3}' | awk -F"$where_operator" '{gsub(/^[ \t]+|[ \t]+$/, "", $2); print $2}')

        if [ "$select_column" == "*" ]; then
            awk -v col=$where_column_field -v op=$where_operator -v val=$where_value 'BEGIN{FS="|"}{if(NR!=1 && $col op val)print $0}' "$table_name"
        else
            awk -v col=$select_column_field -v wcol=$where_column_field -v op=$where_operator -v val=$where_value 'BEGIN{FS="|"}{if(NR!=1 && $wcol op val)print $col}' "$table_name"
        fi
    fi
}
    clear
    db_name=$1
    while true; do
    tput setaf 2 
    cat <<EOF
     	╔═══════════════════════════════════════════════╗
    	║ $db_name Connected                            ║
     	╚═══════════════════════════════════════════════╝
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
    *) execute_sql_select ;;
         
    esac
done