#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=salon --no-align --tuples-only -c"

#welcome message
echo -e "\n~~~~~ MY SALON ~~~~~\n"
echo -e "Welcome to My Salon, how can I help you?\n"

MAIN_MENU () {
  #display error messages
  if [[ $1 ]]
  then
    echo -e "$1"
  fi
  
  #list salon services
  SERVICES=$($PSQL "SELECT * FROM services")
  echo "$SERVICES" | sed 's/|/) /'

  #take user input
  read SERVICE_ID_SELECTED

  #check if input is a number
  if [[ $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
    #get service_id
    SERVICE_ID=$($PSQL "SELECT service_id FROM services WHERE service_id=$SERVICE_ID_SELECTED")

    #if not found
    if [[ -z $SERVICE_ID ]]
    then
      #return to main menu
      MAIN_MENU "\nI could not find that service. What would you like today?"

    #if found
    else
      #call appointement function
      MAKE_APPOINTEMENT

    fi
    
  else
    #if the input is not a number
    MAIN_MENU "\nI could not find that service. What would you like today?"
  fi
}

MAKE_APPOINTEMENT () {
  #ask for phone number
  echo -e "\nWhat's your phone number?"
  read CUSTOMER_PHONE

  #get customer id from the database
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")

  #if not found
  if [[ -z $CUSTOMER_ID ]]
  then
    #ask for customer name
    echo -e "\nI don't have a record for that phone number, what's your name?"
    read CUSTOMER_NAME

    #insert new customer to the data base
    INSERT_NEW_CUSTOMER=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")

    #get customer id
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")

  fi

  #ask for appointement time
  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE customer_id='$CUSTOMER_ID'")
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID")
  echo -e "\nWhat time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
  read SERVICE_TIME

  #insert customer's appointement to the database
  INSERT_APPOINTEMENT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID, '$SERVICE_TIME')")
  echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."

}

MAIN_MENU