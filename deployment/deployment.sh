#!/usr/bin/env bash 

##########################################
# author: purple-thistle
# goal: to deploy the flask app 
# 
##########################################


#check for sudo priviliges
check_privilliges() {
A=$(sudo -n -v 2>&1)
res=$(echo "$A" | grep -q password )
if [[ -z $A || -z $res ]]; then
    echo "can use sudo"
    return 0
else
    return 1    
fi    
}


#set package installer name
YUM_CMD=$(which yum)
APT_CMD=$(which apt)


if [[ -n $YUM_CMD ]]; then
    PACK_INST="yum"
elif [[ -n $APT_CMD ]]; then
    PACK_INST="apt"
else
    echo "package installer not defined"
    exit 1    
fi


#check if pip is installed 
PIP_CMD="$(which pip)"
if [[ -z $PIP_CMD ]]; then
    if [[ $(check_privilliges) ]]; then
        echo "installing pip"
        sudo $PACK_INST install python3-pip
    else
        echo "pip is not installed and you do not have priviliges to install it"
        exit 1
    fi    
fi

#check if postgresql is installed
PSQL_CMD=$(which psql)
if [[ -z $PSQL_CMD ]]; then
    if [[ $(check_privilliges) ]]; then
        echo "installing postgresql"
        sudo $PACK_INST install postgresql
    else
        echo "postgresql is not installed and you do not have priviliges to install it"
        exit 1
    fi    
fi

    
#create database and table
echo "Creating database."
read -p "Please enter database name: " db_name

createdb -h localhost -U postgres "$db_name"

psql -h localhost -U postgres learningflask -c "CREATE TABLE users (uid serial PRIMARY KEY,
        firstname VARCHAR(100) not null,
        lastname VARCHAR(1000) not null,
        email VARCHAR(120) not null unique,
        pwdhash VARCHAR(100) not null);"


#install virtual environment    
pip3 install pipenv

#install requirements from Pipfile
pipenv install

pipenv run python ../application/routes.py