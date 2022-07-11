#!/bin/bash
echo "Running migrations"
python3 manage.py migrate --noinput

echo "Starting gunicorn service"
gunicorn --bind 0.0.0.0:8000 --workers 3 djangokubernetesproject.wsgi
