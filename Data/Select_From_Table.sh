#!/bin/bash
function Database_connected() {
    db_name=$1
    typeset -i filler_length
    filler_length=(20-${#db_name})
    echo -n "| $(tput setaf 3)<$1 "
    for ((counter = 0; counter < filler_length; counter++)); do echo -n "-"; done
    echo " Connected>$(tput setaf 2) |"
    # EX: | <TestDB ----- Connected> |

# Function to display the database menu
display_menu() {
    clear
    cat <<EOF
     	╔═══════════════════════════╗
    	║ $db_name Connected        ║
     	╚═══════════════════════════╝
      ╔═══════════════════════════════════════════════════════════════════════════════╗
      ║    e.g. SELECT *; FROM table_name;                                            ║
      ║    SELECT column; FROM table_name;                                            ║
      ║    SELECT column ; FROM table_name ; WHERE column[==,<,>,>=,<=]value ;        ║
      ║    SELECT * ; FROM table_name ; WHERE column[==,<,>,>=,<=]value ;             ║
      ║    SELECT column; FROM table_name;                                            ║
      ║    SELECT *; FROM table_name;                                                 ║
      ╚═══════════════════════════════════════════════════════════════════════════════╝
     	╔═══════════════════════════╗
    	║ 1 - Back to DB Menu       ║
     	║ 2 - Back to Main Menu     ║
     	╚═══════════════════════════╝
EOF
}

execute_sql() {
    sql_line=$(echo "$1" | sed -e 's/SELECT//g' -e 's/FROM//g' -e 's/WHERE//g' | sed -e 's/select//g' -e 's/from//g' -e 's/where//g')

    fields_no=$(echo "$sql_line" | awk -F';' 'END{print NF}')

    table_name=$(echo "$sql_line" | awk -F';' '{gsub(/^[ \t]+|[ \t]+$/, "",$2);print $2}')
    if [[ ! -f "$table_name" ]]; then
        echo "Error : Invalid Table Name"
        return
    fi

    select_column=$(echo "$sql_line" | awk -F';' '{gsub(/^[ \t]+|[ \t]+$/, "",$1);print $1}')
    select_column_field=$(awk -F'|' 'BEGIN{found=0} {if(NR==1){for(i=1;i<=NF;i++){if($i=="'$select_column'")found=i}}} END{print found}' "$table_name")
    if [[ $select_column_field == 0 ]] && [[ $select_column != "*" ]]; then
        echo "Error : Invalid Selected Column Name"
        return
    fi

    if ((fields_no == 3)); then
        if [ "$select_column" == "*" ]; then
            cat "$table_name"
        else
            awk 'BEGIN{FS="|"}{print $'"$select_column_field"' }' "$table_name"
        fi
        return
    else
        where_operator=$(echo "$sql_line" | awk -F';' '{print $3}' | sed -e 's/[a-zA-Z]*//g' -e 's/[0-9]*//g' -e's/ //g')
        if ! [[ "$where_operator" =~ ^(==|>|<|>=|<=)$ ]]; then

    }           