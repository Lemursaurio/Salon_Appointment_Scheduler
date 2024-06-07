#! /bin/bash
PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c"

MAIN_MENU() {  
  if [[ $1 ]]
  then
    echo -e "\n$1"
  else
    echo -e "\n~~~Salon Service~~~\n"
    echo -e "Welcome to My Salon, how can I help you?\n"
  fi

  LIST_OF_SERVICES=$($PSQL "SELECT * FROM services ORDER BY service_id")
  echo "$LIST_OF_SERVICES" | while read SERVICE_ID BAR NAME
  do
    echo -e "$SERVICE_ID) $NAME"
  done 
  read SERVICE_ID_SELECTED
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")

  if [[ -z $SERVICE_NAME ]]
  then
    MAIN_MENU "I could not find that service. What would you like today?\n"
  else
    APPOINTMENT_CREATION $SERVICE_ID
  fi 
}

APPOINTMENT_CREATION() {
  CUSTOMER_ID=$1

  echo -e "\nEnter your number: "
  read CUSTOMER_PHONE

  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'") 

  if [[ -z $CUSTOMER_ID ]]
  then
    echo -e "\nEnter your name: "
    read CUSTOMER_NAME
    INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
    if [[ $INSERT_CUSTOMER_RESULT == 'INSERT 0 1' ]]
    then
      echo -e "\nNew customer entered."
      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'") 
    else
      MAIN_MENU "ERROR, returning to menu.\n"
    fi
  fi

  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE customer_id=$CUSTOMER_ID") 

  echo -e "\nEnter the service time: "
  read SERVICE_TIME

  INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
  echo -e "\nI have put you down for a $(echo $SERVICE_NAME | sed 's/^ //g') at $SERVICE_TIME, $(echo $CUSTOMER_NAME | sed 's/^ //g')."

}

MAIN_MENU