#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ Welcome to Akira Salon Shop ~~~~~\n"

MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  echo -e "\nHow may I help you today?\n"
  SERVICE_SELECTION=$($PSQL "SELECT * FROM services")
  echo "$SERVICE_SELECTION" | while read SERVICE_ID BAR SERVICE_NAME
  do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done

  read SERVICE_ID_SELECTED

  case $SERVICE_ID_SELECTED in
    1) APPOINTMENT_MENU ;;
    2) APPOINTMENT_MENU ;;
    3) APPOINTMENT_MENU ;;
    *) MAIN_MENU "I could not find that service." ;;
  esac

}

APPOINTMENT_MENU() {
  #SERVICE_AVAILABLE=$($PSQL "SELECT service_id,name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
  #if [[ -z $SERVICE_AVAILABLE ]]
  #then
    #send to main menu
  #  MAIN_MENU "I could not find that service."
  #fi

  echo -e "\nWhat's your phone number?"
  read CUSTOMER_PHONE

  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")

  if [[ -z $CUSTOMER_NAME ]]
  then
    #get customer's name
    echo -e "\nI don't have a record for that phone number, what's your name?"
    read CUSTOMER_NAME

    # add customer to database
    #SERVICE_AVAILABLE=$($PSQL "SELECT service_id,name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
    ADD_NEW_CUSTOMER=$($PSQL "INSERT INTO customers(name,phone) VALUES('$CUSTOMER_NAME','$CUSTOMER_PHONE')")
  fi

  SERVICE_SELECTION=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
  SERVICE_SELECTION_FORMATTED=$(echo $SERVICE_SELECTION | sed 's/^ *//g')
  #CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
  CUSTOMER_NAME_FORMATTED=$(echo $CUSTOMER_NAME | sed 's/^ *//g')
  echo -e "\nWhat time would you like your $SERVICE_SELECTION_FORMATTED, $CUSTOMER_NAME_FORMATTED?"
  read SERVICE_TIME

  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
  #SERVICE_ID=$($PSQL "SELECT service_id FROM services WHERE service_id = $SERVICE_ID_SELECTED")
  INSERT_SERVICE_TIME=$($PSQL "INSERT INTO appointments(time, customer_id, service_id) VALUES('$SERVICE_TIME', $CUSTOMER_ID, $SERVICE_ID_SELECTED)")
  GET_SERVICE_TIME=$($PSQL "SELECT time FROM appointments INNER JOIN customers USING (customer_id) WHERE time = '$SERVICE_TIME'")
  GET_SERVICE_TIME_FORMATTED=$(echo $GET_SERVICE_TIME | sed 's/^ *//g')
  echo -e "\nI have put you down for a $SERVICE_SELECTION_FORMATTED at $GET_SERVICE_TIME_FORMATTED, $CUSTOMER_NAME_FORMATTED."

}

EXIT() {
  echo -e "/nThank you for stopping in."
}

MAIN_MENU
