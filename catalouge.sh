#!/bin/bash

USER=$(id -u)

if [ $USERID -ne 0]; then
echo "Run the command with root user" | tee -a $LOGFILE
else
exit 1
fi
set -e
trap 'echo "There is an error in $LINENO, Command: $BASH_COMMAND"' ERR

VALIDATE(){
if [ $1 -ne 0]; then
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

useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop

curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip 
cd /app 
unzip /tmp/catalogue.zip