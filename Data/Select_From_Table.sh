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
    local sql_line=$1
    local db_name=$2

    # Remove SQL keywords and split into parts
    local parts=($(echo "$sql_line" | sed -e 's/SELECT//g' -e 's/FROM//g' -e 's/WHERE//g' | tr ';' ' '))

    # Get table name and check if it exists
    local table_name=${parts[1]}
    if [ ! -f "$table_name" ]; then
        echo "Error: Invalid Table Name or Invalid Selection (-_-;)・・・"
        return
    fi

    # Get selected column and check if it exists
    local select_column=${parts[0]}
    local select_column_field=$(awk -F'|' 'NR==1{for(i=1;i<=NF;i++){if($i=="'$select_column'")print i}}' "$table_name")
    if [ -z "$select_column_field" ] && [ "$select_column" != "*" ]; then
        echo "Error: Invalid Selected Column Name (-_-;)・・・"
        return
    fi

    # Perform query
    if [ ${#parts[@]} -eq 2 ]; then
        if [ "$select_column" == "*" ]; then
            cat "$table_name"
        else
            awk -v col=$select_column_field 'BEGIN{FS="|"}{print $col}' "$table_name"
        fi
    else
        # Get where operator and check if it's valid
        local where_operator=$(echo "${parts[2]}" | sed -e 's/[a-zA-Z]*//g' -e 's/[0-9]*//g' -e 's/ //g')
        if ! [[ "$where_operator" =~ ^(==|>|<|>=|<=)$ ]]; then
            echo "Error: Invalid Where Operator (-_-;)・・・"
            return
        fi

        # Get where column and check if it exists
        local where_column=$(echo "${parts[2]}" | awk -F"$where_operator" '{print $1}')
        local where_column_field=$(awk -F'|' 'NR==1{for(i=1;i<=NF;i++){if($i=="'$where_column'")print i}}' "$table_name")
        if [ -z "$where_column_field" ]; then
            echo "Error: Invalid Where Column Name (-_-;)・・・"
            return
        fi

        # Get where value
        local where_value=$(echo "${parts[2]}" | awk -F"$where_operator" '{print $2}')

        # Perform query with where clause
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
    *) execute_sql_select ;;
         
    esac
done