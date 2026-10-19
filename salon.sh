#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"
MAIN_MENU() {
  if [[ $1 ]]
  then 
    echo -e "\n$1"
  else
    echo -e "Welcome to My Salon, how can I help you?\n"
  fi

  echo -e "1) cut\n2) color\n3) perm\n4) style\n5) trim"
  read SERVICE_ID_SELECTED
  
  if [[ ! $SERVICE_ID_SELECTED =~ ^[1-5]$ ]]
  then
    MAIN_MENU "I could not find that service. What would you like today?"
  else 
    SERVICE_MENU $SERVICE_ID_SELECTED
  fi
}

SERVICE_MENU() {
  # get the service based on the argument given
  SERVICE_CHOSEN=$($PSQL "SELECT name FROM services WHERE service_id = $1;")
  # ask for the phone number
  echo -e "\nWhat's your phone number?"
  read CUSTOMER_PHONE
  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE';")
  # if the given phone number is not in the database, 
  if [[ -z $CUSTOMER_NAME ]]
  then
    echo -e "\nI don't have a record for that phone number, what's your name?"
    # ask for his/her name 
    read CUSTOMER_NAME
    # and then insert those information in the customers table
    $PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME');" > /dev/null
  fi
  CUSTOMER_NAME_FORMATTED=$(echo "$CUSTOMER_NAME" | sed 's/^[[:space:]]*//')
  # ask for the time for the appointment
  echo -e "\nWhat time would you like your$SERVICE_CHOSEN, $CUSTOMER_NAME_FORMATTED?"
  read SERVICE_TIME
  $PSQL "INSERT INTO appointments(service_id, customer_id, time) VALUES($1, (SELECT customer_id FROM customers WHERE name = '$CUSTOMER_NAME_FORMATTED'), '$SERVICE_TIME');" > /dev/null
  echo -e "\nI have put you down for a$SERVICE_CHOSEN at $SERVICE_TIME, $CUSTOMER_NAME_FORMATTED."
} 

MAIN_MENU
