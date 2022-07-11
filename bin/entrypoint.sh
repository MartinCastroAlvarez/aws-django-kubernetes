#!/bin/bash
echo "Running migrations"
python3 manage.py migrate --noinput

echo "Collecting static content"
python3 manage.py collectstatic --noinput

echo "Starting gunicorn service"
gunicorn --bind 0.0.0.0:8000 --workers 3 --timeout 120 djangokubernetesproject.wsgi
