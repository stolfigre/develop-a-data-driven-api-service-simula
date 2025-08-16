#!/bin/bash

# Set API endpoint and port
API_ENDPOINT="http://localhost:8080"
API_PORT="8080"

# Set data files
DATA_FILE_USERS="users.json"
DATA_FILE_ORDERS="orders.json"

# Start API service simulator
echo "Starting API service simulator on port $API_PORT..."

# Start API server
python -m http.server $API_PORT &

# Load data into memory
USERS=$(jq -r '.[] | @uri' $DATA_FILE_USERS)
ORDERS=$(jq -r '.[] | @uri' $DATA_FILE_ORDERS)

# Define API endpoints
api_endpoints() {
  local endpoint=$1
  local response=$2

  echo "API Endpoint: $endpoint"
  echo "Response: $response"
  echo ""
}

# Define API simulator functions
get_users() {
  api_endpoints "/users" "$USERS"
}

get_orders() {
  api_endpoints "/orders" "$ORDERS"
}

get_user() {
  local user_id=$1
  local user=$(echo "$USERS" | jq -r ".[] | select(.id==$user_id) | @uri")
  api_endpoints "/users/$user_id" "$user"
}

get_order() {
  local order_id=$1
  local order=$(echo "$ORDERS" | jq -r ".[] | select(.id==$order_id) | @uri")
  api_endpoints "/orders/$order_id" "$order"
}

# Handle API requests
while true
do
  read -r request
  case $request in
    "GET /users HTTP/1.1")
      get_users
      ;;
    "GET /orders HTTP/1.1")
      get_orders
      ;;
    "GET /users/* HTTP/1.1")
      get_user ${request##*/}
      ;;
    "GET /orders/* HTTP/1.1")
      get_order ${request##*/}
      ;;
    *)
      echo "Error: Invalid request"
      ;;
  esac
done