#!/bin/bash
function Database_connected(){
    local db_name=$1
    local filler_length=$((${#db_name} < 54 ? 54 - ${#db_name} : 0))
    echo -n "| $(tput setaf 3)<$1 "
    for ((i = 0; i < filler_length; i++)); do echo -n "-"; done
    echo " Connected>$(tput setaf 2) |"
    # EX: | <TestDB ----- Connected> |
}


function execute_sql_check(){
    sql_line=$(echo "$entry" | sed -e 's/UPDATE//I' -e 's/SET//I' -e 's/WHERE//I')
    sql_line=$(echo "$sql_line" | tr -s ' ')  # Normalize spaces

    # Extract the table name
    table_name=$(echo "$entry" | awk '{print $2}')
    if ! [ -f "$table_name" ]; then 
        echo "Error : Invalid Table Name"
        return
    fi

    # Extract and validate the column in the SET clause
    update_col_name=$(echo "$sql_line" | awk -F';' '{print $2}' | awk -F'=' '{gsub(/^[ \t]+|[ \t]+$/, "", $1); print $1}')
    field_no=$(awk -F'|' 'BEGIN{found=0} {if (NR==1){for(i=1;i<=NF;i++){if($i=="'$update_col_name'")found=i}}} END{print found}' "$table_name")
    col_data_type=$(awk -F'|' '{if ($1=="'$update_col_name'"){print $2}}' ".$table_name")
    is_pk=$(awk -F'|' '{if ($1=="'$update_col_name'"){print $3}}' ".$table_name")
    
    if ((field_no == 0)); then 
        echo "Error : Invalid Column Name"
        return
    fi

    # Extract and validate the column in the WHERE clause
    column_name=$(echo "$sql_line" | awk -F';' '{print $3}' | awk -F'=' '{gsub(/^[ \t]+|[ \t]+$/, "", $1); print $1}')
    found=$(awk -F'|' 'BEGIN{found=0} {if(NR==1){for(i=1;i<=NF;i++){if($i=="'$column_name'")found=1}}} END{print found}' "$table_name")
    if ((found == 0)); then 
        echo "Error : Invalid Column Name"
        return
    fi

    # Extract and validate the value in the WHERE clause
    selected_record=$(echo "$sql_line" | awk -F';' '{print $3}' | awk -F'=' '{gsub(/^[ \t]+|[ \t]+$/, "", $2); print $2}')
    record_field=$(awk -F'|' 'BEGIN{found=0} {if(NR!=1){for(i=1;i<=NF;i++){if($i=="'$selected_record'")found=i}}} END{print found}' "$table_name")
    if ((record_field == 0)); then 
        echo "Error : No Value Found"
        return
    fi

    # Validate the new value with the column type
    new_value=$(echo "$sql_line" | awk -F';' '{print $2}' | awk -F'=' '{gsub(/^[ \t]+|[ \t]+$/, "", $2); print $2}')
    case $new_value in
    [a-zA-Z]*) if [ "$col_data_type" != "txt" ]; then 
        echo "Error : Invalid Value Type"
        return
    fi ;;
    [0-9]*) if [ "$col_data_type" != "int" ]; then 
        echo "Error : Invalid Value Type"
        return
    fi ;;
    *) exit 4 ;;
    esac

    # Check if the update value is in the pk column and the new value exists
    if [ "$is_pk" == "pk" ]; then
        value_exist=$(awk -v new_value="$new_value" -F'|' 'BEGIN{found=0} {if(NR!=1){for(i=1;i<=NF;i++){if($"'$record_field'"==new_value)found=1}}} END{print found}' "$table_name")
        if ((value_exist == 1)); then 
            echo "Error : PK Value Exists"
            return
        fi
    fi

    # Update the selected record with the new value
    awk -v new_value="$new_value" -i inplace -F'|' '{OFS=FS}{if($"'$record_field'"=="'$selected_record'"){$"'$field_no'"=new_value } print}' "$table_name" 2> ../../error.log
    echo "Updated Successfully"
}


clear
db_name=$1
while true; do
    tput setaf 2 #change font color to Green
     #  ╔═════════════════════════════════╗
     #	║   ║
     #	╚═════════════════════════════════╝
    Database_connected "$db_name"
    cat <<EOF
       
       ╔══════════════════════════════════════════════════════════════════════╗
       ║ e.g. UPDATE table_name; SET column1=value1; WHERE column2=value2;    ║
       ╚══════════════════════════════════════════════════════════════════════╝                                                   
       
       
       ╔═══════════════════════════╗
       ║ 1 - Back to Database Menu ║
       ║ 2 - Back to Main Menu     ║
       ╚═══════════════════════════╝

EOF

    tput setaf 5 #change font color to blue
    read -p "$(tput setaf 5)Enter SQL UPDATE Statement : " entry
    case $entry in
    1) 
    echo "You selected Back to Database Menu "
    exit ;;
    2) 
    echo "You selected Back to Main Menu "
    exit 2 ;;
    *) execute_sql_check ;;
    esac
done

 