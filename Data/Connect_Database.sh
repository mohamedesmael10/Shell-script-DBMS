#! /bin/bash
read -p "Enter Database name: " name
cd Data/$name 2>> error.log && echo "Database <$name> Selected Successfully" && (  ../../menu.sh "$name" ; cd ../.. ) || echo "Database $name Not Found"