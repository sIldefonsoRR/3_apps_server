#!/bin/bash
set -e

# Run Gunicorn for each Django project
gunicorn --chdir api api.wsgi:application --bind 127.0.0.1:8001 & 
gunicorn --chdir public_site public_site.wsgi:application --bind 127.0.0.1:8002 & 
gunicorn --chdir private_site private_site.wsgi:application --bind 127.0.0.1:8003 & 

# Start nginx in foreground
nginx -g 'daemon off;'
