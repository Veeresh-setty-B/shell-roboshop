#!/bin/bash

USERID=$(id -u)
LOGFOLDER="/var/log/script"
LOGFILE="$LOGFOLDER/$0"
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
SCRIPT_DIR=$PWD
MONGODB_HOST=mongodb.veereshsetty.online
set -e
trap 'echo "There is an error in $LINENO, Command: $BASH_COMMAND"' ERR

if [ $USERID -ne 0 ]; then
echo "Run the command with root user" | tee -a $LOGFILE
exit 1
fi

VALIDATE(){
if [ $1 -ne 0 ]; then
echo "$2: Failure"
else
echo "$2: Success" | tee -a $LOGFILE
fi
}