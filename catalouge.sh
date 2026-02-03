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
echo "Run the command with root user" | tee -a $LOGFILE
else
exit 1
fi

VALIDATE(){
if [ $1 -ne 0 ]; then
echo "$2: Failure"
else
echo "$2: Success" | tee -a $LOGFILE
fi
}

dnf module disable nodejs -y
dnf module enable nodejs:20 -y
dnf install nodejs -y
VALIDATE $? "Installed node"

mkdir /app 
