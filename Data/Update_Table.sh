#!/bin/bash
function Database_connected(){
    local db_name=$1
    local filler_length=$((${#db_name} < 54 ? 54 - ${#db_name} : 0))
    echo -n "| $(tput setaf 3)<$1 "
    for ((i = 0; i < filler_length; i++)); do echo -n "-"; done
    echo " Connected>$(tput setaf 2) |"
    # EX: | <TestDB ----- Connected> |
}


execute_sql_check() {
  # Remove SQL specific words
  sql_line=${entry//UPDATE/}; sql_line=${sql_line//SET/}; sql_line=${sql_line//WHERE/}
  sql_line=${sql_line//update/}; sql_line=${sql_line//set/}; sql_line=${sql_line//where/}

  # Get table name
  table_name=$(echo "$sql_line" | awk -F';' '{print $1}' | tr -d '[:space:]')
  if [ ! -f "$table_name" ]; then echo "Error : Invalid Table Name"; return; fi

  # Get column names and values
  update_col_name=$(echo "$sql_line" | awk -F';' '{print $2}' | awk -F'=' '{print $1}' | tr -d '[:space:]')
  column_name=$(echo "$sql_line" | awk -F';' '{print $3}' | awk -F'=' '{print $1}' | tr -d '[:space:]')
  new_value=$(echo "$sql_line" | awk -F';' '{print $2}' | awk -F'=' '{print $2}' | tr -d '[:space:]')
  selected_record=$(echo "$sql_line" | awk -F';' '{print $3}' | awk -F'=' '{print $2}' | tr -d '[:space:]')

  # Check column existence and type
  col_info=$(awk -F'|' -v col_name="$update_col_name" 'NR==1{for(i=1;i<=NF;i++){if($i==col_name)print i","$2","$3}}' "$table_name")
  if [ -z "$col_info" ]; then echo "Error : Invalid Column Name"; return; fi
  field_no=$(echo "$col_info" | cut -d, -f1)
  col_data_type=$(echo "$col_info" | cut -d, -f2)
  is_pk=$(echo "$col_info" | cut -d, -f3)

  # Check value existence
  record_field=$(awk -F'|' -v selected_record="$selected_record" 'NR!=1{for(i=1;i<=NF;i++){if($i==selected_record)print i}}' "$table_name")
  if [ -z "$record_field" ]; then echo "Error : No Value Found"; return; fi

  # Validate new value with column type
  case $new_value in
    [a-zA-Z]*) if [ "$col_data_type" != "txt" ]; then echo "Error : Invalid Value Type"; return; fi ;;
    [0-9]*) if [ "$col_data_type" != "int" ]; then echo "Error : Invalid Value Type"; return; fi ;;
    *) exit 4 ;;
  esac

  # Check if updating PK column and new value exists
  if [ "$is_pk" == "pk" ]; then
    value_exist=$(awk -v new_value="$new_value" -F'|' 'NR!=1{for(i=1;i<=NF;i++){if($i==new_value)print 1}}' "$table_name")
    if [ "$value_exist" == 1 ]; then echo "Error : PK Value Exists"; return; fi
  fi

  # Update the selected record with the new value
  awk -v new_value="$new_value" -i inplace -F'|' '{OFS=FS}{if($'"$record_field"'=="'"$selected_record"'")$'"$field_no"'=new_value } print}' "$table_name" 2> ../../error.log
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
        ║    e.g. UPDATE table_name; SET column1=value1; WHERE column2=value2; ║                                                                    ║                                                              
        ╚══════════════════════════════════════════════════════════════════════╝
     	╔═══════════════════════════╗
    	║ 1 - Back to Database Menu ║
     	║ 2 - Back to Main Menu     ║
     	╚═══════════════════════════╝
EOF
    tput setaf 5 #change font color to blue
    read -p "$(tput setaf 5)Enter SQL UPDATE Statement : " Select
    case $Select in
    1) 
    echo "You selected Back to Database Menu "
    exit ;;
    2) 
    echo "You selected Back to Main Menu "
    exit 2 ;;
    *) execute_sql_check ;;
    esac
done

 