#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

MAIN_MENU() {
SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")

	if [[ $1 ]]
	then
		echo -e "\n$1"
	fi
	
	# Services menu options
	echo Welcome to Code N Cuts Salon, how can I help you?
	echo "$SERVICES" | while read SERVICE_ID BAR SERVICE_NAME
	do
		echo "$SERVICE_ID) $SERVICE_NAME"
	done
	
	# service input
	read SERVICE_ID_SELECTED
	SERVICE_ID=$($PSQL "SELECT service_id FROM services WHERE service_id=$SERVICE_ID_SELECTED")
	
	# if no service matches input
	if [[ -z $SERVICE_ID ]]
	then
		MAIN_MENU "I could not find that service. What would you like today?"
	else
		# get phone number
		echo -e "\nWhat's your phone number?"
		read CUSTOMER_PHONE
		CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
		
		# if not found
		if [[ -z $CUSTOMER_NAME ]]
		then
			# get customer name
			echo -e "\nI don't have a record for that phone number, what's your name?"
			read CUSTOMER_NAME
			
			# insert new customer
			INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
		fi
		
		# get service name
		SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_ID=$SERVICE_ID")
		
		# get time
		echo -e "\nWhat time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
		read SERVICE_TIME
		
		# get customer id
		CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
		
		# insert appointment
		INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(time, customer_id, service_id) VALUES('$SERVICE_TIME', $CUSTOMER_ID, $SERVICE_ID_SELECTED)")
		
		# confirmation message
		echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
		
	fi
}

# call Main Menu function
MAIN_MENU
