#!/bin/bash
function Database_connected() {
    db_name=$1
    typeset -i filler_length
    filler_length=(59-${#db_name})
    echo -n "| $(tput setaf 3)<$1 "
    for ((counter = 0; counter < filler_length; counter++)); do echo -n "-"; done
    echo " Connected>$(tput setaf 2) |"
}

function sql_select() {
    #remove SQL specific words
    sql_line=$(echo "$entry" | sed -e 's/SELECT//g' -e 's/FROM//g' -e 's/WHERE//g' | sed -e 's/select//g' -e 's/from//g' -e 's/where//g')

    #get fields. No
    fields_no=$(echo "$sql_line" | awk -F';' 'END{print NF}')

    #get table and check its existance
    table_name=$(echo "$sql_line" | awk -F';' '{gsub(/^[ \t]+|[ \t]+$/, "",$2);print $2}')
    if [[ ! -f "$table_name" ]]; then echo "Error : Invalid Table Name (・_・;)" ; return; fi

    #get the selection column and check its existance
    select_column=$(echo "$sql_line" | awk -F';' '{gsub(/^[ \t]+|[ \t]+$/, "",$1);print $1}')
    select_column_field=$(awk -F'|' 'BEGIN{found=0} {if(NR==1){for(i=1;i<=NF;i++){if($i=="'$select_column'")found=i}}} END{print found}' "$table_name")
    if [[ $select_column_field == 0 ]]  && [[ $select_column != "*" ]]; then echo "Error : Invalid Selected Column Name (・_・;)" && return; fi

    if ((fields_no == 3)); then
        if [ "$select_column" == "*" ]; then cat "$table_name";
        else awk 'BEGIN{FS="|"}{print $'"$select_column_field"' }' "$table_name" ; fi
        return
    else
        #get and check the where operator
        where_operator=$(echo "$sql_line" | awk -F';' '{print $3}' | sed -e 's/[a-zA-Z]*//g' -e 's/[0-9]*//g' -e's/ //g')
        if ! [[ "$where_operator" =~ ^(==|>|<|>=|<=)$ ]] ; then echo "Error : Invalid Where Operator (・_・;)"; return; fi

        #get the column in the WHERE condition and check its existance
        where_column=$(echo "$sql_line" | awk -F';' '{print $3}' | awk -F''$where_operator'' '{gsub(/^[ \t]+|[ \t]+$/, "",$1);print $1}')
        where_column_field=$(awk -F'|' 'BEGIN{found=0} {if(NR==1){for(i=1;i<=NF;i++){if($i=="'$where_column'")found=i}}} END{print found}' "$table_name")
        if ((where_column_field == 0)); then echo "Error : Invalid Where Column Name (・_・;)"; return; fi

        # get the value in the WHERE condition and check its existance
        where_value=$(echo "$sql_line" | awk -F';' '{print $3}' | awk -F''$where_operator'' '{gsub(/^[ \t]+|[ \t]+$/, "",$2);print $2}')
        where_value_exist=$(awk -F'|' 'BEGIN{found=0} {if(NR!=1){if($"'$where_column_field'"=="'$where_value'")found=1}} END{print found}' "$table_name")
        if ((where_value_exist == 0)); then echo "Warning : The Where Value does not exist in the Table  (・_・;)"; fi

        if [ "$select_column" == "*" ]; then awk  -v were_value="$where_value" -F'|' '{if(NR!=1){if($"'$where_column_field'" '$where_operator' were_value){print $0}}}' "$table_name" ;
        else awk -v were_value="$where_value" -F'|' '{if(NR!=1){if($'$where_column_field'  '$where_operator' were_value){print $'"$select_column_field"'}}}' "$table_name" ;fi
        # echo "select $select_column from $table_name where $where_column $where_operator $where_value"
    fi
}

clear
db_name=$1
while true; do
    tput setaf 2 #change font color to Green
    
    Database_connected "$db_name"
    cat <<EOF

        ╔══════════════════════════════════════════════════════════════════════╗
        ║  e.g. SELECT *; FROM table_name;                                     ║
        ║  SELECT column; FROM table_name;                                     ║        
        ║  SELECT column ; FROM table_name ; WHERE column[==,<,>,>=,<=]value ; ║
        ║  SELECT * ; FROM table_name ; WHERE column[==,<,>,>=,<=]value        ║               
        ╚══════════════════════════════════════════════════════════════════════╝
        
     	╔═══════════════════════════╗
    	║ 1 - Back to Database Menu ║
     	║ 2 - Back to Main Menu     ║
     	╚═══════════════════════════╝

EOF

    tput setaf 5
    read -p "$(tput setaf 5)Enter SQL Select Statement : " entry
    case $entry in
    1) 
    echo "You selected Back to Database Menu"
    exit ;;
    2) 
    echo "You selected Back to Main Menu"
    exit 2 ;;
    *) sql_select ;;
    esac
done