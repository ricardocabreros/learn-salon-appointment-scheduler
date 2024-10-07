#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~ Olympus Spa and Salon ~~~\n"

SERVICE_MENU() {

  # display the salon's services
  ALL_SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id");

  echo -e "\nHere are our services:\n"
  echo "$ALL_SERVICES" | while read SERVICE_ID BAR SERVICE_NAME
  do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done
  
  # pick a service
  echo -e "\nWhat service do you need?"
  read SERVICE_ID_SELECTED

  SELECTED_SERVICE=$($PSQL "SELECT service_id FROM services WHERE service_id = '$SERVICE_ID_SELECTED'")
  # if input is not a valid number
  if [[ -z $SELECTED_SERVICE  ]]
  then
    # back to salon menu
    SERVICE_MENU "That is not a valid input."
  else
    # get customer info
    echo -e "\nPlease enter your phone number, dear customer."
    read CUSTOMER_PHONE
    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
    # if customer does not exist in database
    if [[ -z $CUSTOMER_NAME ]]
    then
      # Entering new customer info in database
      echo -e "\nOh, a new customer! Please give us your name."
      read CUSTOMER_NAME
      INSERT_CUSTOMER_INFO_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
    fi

    # enter time of the appointment
    echo -e "\nPlease enter a time of appointment for the service."
    read SERVICE_TIME

    # get customer_id
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
    
    # insert a new appointment info in the database
    INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

    # get appointment info
    APPOINTMENT_INFO=$($PSQL "SELECT services.name AS service_name, time FROM appointments INNER JOIN customers USING(customer_id) INNER JOIN services USING(service_id) WHERE customer_id = $CUSTOMER_ID AND service_id = $SERVICE_ID_SELECTED AND time = '$SERVICE_TIME'")

    echo -e "\nI have put you down for a $(echo $APPOINTMENT_INFO | sed 's/ *|.*//') at $(echo $APPOINTMENT_INFO | sed 's/.*| *//'), $CUSTOMER_NAME."
  fi

  EXIT
}

EXIT() {
  echo -e "\nThank you. Please do come back!\n"
}

SERVICE_MENU

