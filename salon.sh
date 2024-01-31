#!/bin/bash


PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"

echo "Welcome to My Salon, how can I help you?"


MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  # get service name
  SERVICES=$($PSQL "SELECT service_id, name FROM services;")

  #display services
  echo "$SERVICES" | while read SERVICE_ID BAR NAME
  do
    echo "$SERVICE_ID) $NAME"
  done 

  # select a service
  read SERVICE_ID_SELECTED
  SERVICE_AVAILABLE=$($PSQL "SELECT service_id, name FROM services WHERE service_id = $SERVICE_ID_SELECTED")

  # check SERVICE_AVAILABLE RESULT
  if [[ -z $SERVICE_AVAILABLE ]]
  then 
  MAIN_MENU "I could not find that service. What would you like today?"
  else CUSTOMER_INFO
  fi

}

CUSTOMER_INFO() {
# name of service
SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")

# insert customer phone number
echo "What is your phone number?"
read CUSTOMER_PHONE
PHONE_EXIST=$($PSQL "SELECT phone FROM customers WHERE phone = '$CUSTOMER_PHONE'")
# select customer_id
CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
# if phone doesnt exist
if [[ -z $PHONE_EXIST ]]
then
# input customer name
echo "Phone number does not exist, what is your name?"
read CUSTOMER_NAME

# enter time
echo "What time would you like your$SERVICE_NAME, $CUSTOMER_NAME?"
read SERVICE_TIME

# insert phone and name to customers table
INSERT_PHONE_NAME=$($PSQL "INSERT INTO customers(phone, name) VALUES ('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")

# select customer_id
CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")

#insert data to appointments tabel
INSERT_TO_APPOINTMENTS=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES ('$CUSTOMER_ID', '$SERVICE_ID_SELECTED', '$SERVICE_TIME')")
echo "I have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."

else
CUSTOMER_NAME_EXIST=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
echo "What time would you like your$SERVICE_NAME,$CUSTOMER_NAME_EXIST?"
read SERVICE_TIME
INSERT_TO_APPOINTMENTS=$($PSQL "INSERT INTO appointments (customer_id, service_id, time) VALUES ('$CUSTOMER_ID', '$SERVICE_ID_SELECTED', '$SERVICE_TIME')")
echo "I have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME_EXIST."
fi

}
MAIN_MENU