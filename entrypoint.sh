#!/bin/sh
set -e

echo "Installing dependencies..."
mix deps.get

if [ ! -d "assets/node_modules" ]; then
  echo "Installing Node.js dependencies..."
  cd assets && npm install && cd ..
fi

echo "Waiting for database..."
while ! pg_isready -h db -U postgres > /dev/null 2>&1; do
  sleep 1
done

echo "Creating database if it doesn't exist..."
mix ecto.create

echo "Running migrations..."
mix ecto.migrate

echo "Starting Phoenix server..."
exec mix phx.server
