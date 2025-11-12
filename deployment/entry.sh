#!/bin/sh

# Set default ports if not provided
export PORT=${PORT:-3000}
export API_PORT=${API_PORT:-4000}
export DASHBOARD_PORT=${DASHBOARD_PORT:-5000}

echo "Using ports - Main: $PORT, API: $API_PORT, Dashboard: $DASHBOARD_PORT"

echo "Starting Prisma migrations..."
npx prisma migrate deploy
echo "Prisma migrations completed."

sh replace-variables.sh &&

# Replace nginx.conf placeholders with actual ports
envsubst '${PORT} ${API_PORT} ${DASHBOARD_PORT}' < /etc/nginx/nginx.conf > /etc/nginx/nginx.conf.tmp
mv /etc/nginx/nginx.conf.tmp /etc/nginx/nginx.conf

echo "Starting Nginx on port $PORT..."
nginx &

echo "Starting the API server on port $API_PORT..."
PORT=$API_PORT node packages/api/app.js &
echo "API server started in the background."

echo "Starting the Dashboard on port $DASHBOARD_PORT..."
cd packages/dashboard
PORT=$DASHBOARD_PORT npx next start -p $DASHBOARD_PORT -H 0.0.0.0
echo "Dashboard started."
