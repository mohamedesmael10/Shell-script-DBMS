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


function update_and_check() {
    (../../Update.sh "$1")
    result=$?
    if ((result == 1)); then
        echo "Error: Update failed. Check the logs."
    elif ((result == 2)); then 
        echo "Critical error: Exiting script."
        exit; fi
}

function select_and_check() {
    (../../Select_From_Table.sh "$1")
    result=$?
    if ((result == 1)); then
        echo "Error: Select failed. Check the logs."
    elif ((result == 2)); then 
        echo "Critical error: Exiting script."
        exit; fi
}
function delete_and_check() {
    (../../Delete_from.sh "$1")
    result=$?
    if ((result == 1)); then
        echo "Error: Delete failed. Check the logs."
    elif ((result == 2)); then 
        echo "Critical error: Exiting script."
        exit; fi
}
function insert_and_check() {
    (../../insert_into.sh "$1")
    result=$?
    if ((result == 1)); then
        echo "Error: Insertion failed. Check the logs."
    elif ((result == 2)); then 
        echo "Critical error: Exiting script."
        exit; fi
}
function create_and_check() {
    (../../create_table.sh "$1")
    result=$?
    if ((result == 1)); then
        echo "Error : Check the logs"
    elif ((result == 2)); then 
        echo "Critical error: Exiting script."
        exit; fi
}


clear
db_name=$1

while true; do
    tput setaf 2 
    echo "═══════════════════════════"
    Database_connected $db_name
   
    cat <<EOF
     	╔═══════════════════════════╗
    	║ 1 - Create Database       ║
     	║ 2 - List Databases        ║
     	║ 3 - Drop Database         ║
     	║ 4 - Insert into Table     ║
     	║ 5 - Select From Table     ║
        ║ 6 - Delete From Table     ║
        ║ 7 - Update Table          ║
        ║ 8 - Back to Main Menu     ║
     	╚═══════════════════════════╝
EOF
    tput setaf 4 #change font color to blue
    echo -n "$(tput setaf 3)ٍSelect : "
    read selection
    case $selection in
    1) 
        echo "You selected Create Database "
        create_and_check "$db_name" ;;
    2) 
        echo "You selected List Databases "
        ls ;;
    3)
        echo "You selected Drop Database "
        . ../../drop_tb.sh ;;
    4)
        echo "You selected Insert into Table  "
        insert_and_check "$db_name" ;;
    5)
        echo "You selected Select From Table "
        select_and_check "$db_name" ;;
    6)
        echo "You selected Delete From Table "
        delete_and_check "$db_name" ;;
    7)
        echo "You selected Update Table  "
        update_and_check "$db_name" ;;
    8)
        echo "You selected Back to Main Menu "
        exit ;;
    *) echo -e "\n Invalid Selection (-_-;)・・・ \n" ;;
    esac
done