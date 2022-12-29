#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c"
echo -e "\n~~~ Tom's Salon ~~~\n"

MAIN_MENU() {
  if [[ $1 ]]
  then
    echo "$1"
  fi
  echo -e "\nHow can i help you today?"
  SERVICES_AVAILABLE=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")
  echo -e "$SERVICES_AVAILABLE" | while read SVC_ID BAR SVC_NAME
  do
    echo -e "$SVC_ID) $SVC_NAME"
  done
  read SERVICE_ID_SELECTED
  SERVICE_SELECTION_RESULT=$($PSQL "SELECT service_id FROM services WHERE service_id = $SERVICE_ID_SELECTED")
  if [[ -z $SERVICE_SELECTION_RESULT ]]
  then
    MAIN_MENU "Invalid option, Please select a valid service."
  else
    echo -e "\nWhat is your phone number?"
    read CUSTOMER_PHONE
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
    if [[ -z $CUSTOMER_ID ]]
    then
      echo -e "\nWhats your name?"
      read CUSTOMER_NAME
      NEW_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
    fi
    echo -e "\nWhen would you like to schedule an appointment?"
    read SERVICE_TIME
    INSERT_NEW_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id,service_id,time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
    APPOINTMENT_ID=$($PSQL "SELECT appointment_id FROM appointments WHERE customer_id = '$CUSTOMER_ID' AND time = '$SERVICE_TIME'")
    CUSTOMER_APPOINTMENT=$($PSQL "SELECT c.name AS customer,s.name AS service,time FROM customers AS c INNER JOIN appointments AS a USING(customer_id) INNER JOIN services AS s USING(service_id) WHERE appointment_id = $APPOINTMENT_ID")
    echo $CUSTOMER_APPOINTMENT | while read NAME BAR SVC BAR TIME
    do
      echo -e "\nI have put you down for a $SVC at $TIME, $NAME."
    done


  fi
   
}

MAIN_MENU
