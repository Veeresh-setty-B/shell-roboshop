#!/bin/bash

USERID=$(id -u)
LOGS_FOLDER="/var/log/script"
LOGS_FILE="$LOGS_FOLDER/$0.txt"
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
SCRIPT_DIR=$PWD
MONGODB_HOST=mongodb.veereshsetty.online
set -e
trap 'echo "There is an error in $LINENO, Command: $BASH_COMMAND"' ERR

if [ $USERID -ne 0 ]; then
echo "Run the command with root user" | tee -a $LOGS_FILE
exit 1
fi

VALIDATE(){
if [ $1 -ne 0 ]; then
echo "$2: Failure"
else
echo "$2: Success" | tee -a $LOGS_FILE
fi
}
mkdir -p $LOGS_FOLDER

dnf module disable nodejs -y
dnf module enable nodejs:20 -y
dnf install nodejs -y
VALIDATE $? "Installed nodejs"

id roboshop &>>$LOGS_FILE
if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOGS_FILE
    VALIDATE $? "Creating system user"
else
    echo -e "Roboshop user already exist ... $Y SKIPPING $N"
fi

mkdir -p /app 

curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip 
cd /app 

rm -rf /app/*
VALIDATE $? "Removing existing code"
unzip /tmp/catalogue.zip

cd /app 
npm install &>>$LOGS_FILE
VALIDATE $? "Installed npm" 

cp $SCRIPT_DIR/catalogue.service /etc/systemd/system/catalogue.service
VALIDATE $? "Created systemctl service"

systemctl daemon-reload
systemctl enable catalogue &>>$LOGS_FILE
systemctl start catalogue
VALIDATE $? "Starting and enabling catalogue"

cp $SCRIPT_DIR/mongo.repo /etc/yum.repos.d/mongo.repo
dnf install mongodb-mongosh -y &>>$LOGS_FILE

if [ $INDEX -le 0 ]; then
    mongosh --host $MONGODB_HOST </app/db/master-data.js
    VALIDATE $? "Loading products"
else
    echo -e "Products already loaded ... $Y SKIPPING $N"
fi

systemctl restart catalogue
VALIDATE $? "Restarting catalogue"