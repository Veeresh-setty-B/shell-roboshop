#!/bin/bash

USERID=$(id -u)
LOGFOLDER="/var/log/script"
LOGFILE="$LOGFOLDER/$0"
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

set -e
trap 'echo "There is an error in $LINENO, Command: $BASH_COMMAND"' ERR

if [ $USERID -ne 0 ]; then
    echo "$G Run the script with Root User$N" | tee -a $LOGFILE
    exit 1
fi

VALIDATE(){
    if [ $1 -ne 0 ]; then
    echo "$2 : $G Failure$N"  | tee -a $LOGFILE
    else
    echo "$2 : Success"
    fi
}
mkdir -p $LOGFOLDER
cp mango.repo /etc/yum.repos.d/mongo.repo

dnf install mongodb-org -y &>> $LOGFILE
VALIDATE $? "Installing Mangodb"

systemctl enable mongod 
systemctl start mongod 
VALIDATE $? "Mongo start"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf

systemctl restart mongod
VALIDATE $? "Restarted MongoDB"
