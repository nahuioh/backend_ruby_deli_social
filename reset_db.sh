#!/bin/bash

# Borrar y recrear la base de datos
rm -f /usr/src/app/db/development.sqlite3

# Ejecutar las migraciones
bundle exec rails db:migrate

# Iniciar el servidor Rails
bundle exec rails server -b 0.0.0.0
