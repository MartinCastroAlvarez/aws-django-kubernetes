#!/bin/bash
echo "Running migrations"
python3 manage.py migrate --noinput
if [ "$?" != "0" ]
then
    echo "Failed to run migrations"
    exit 1
fi

echo "Collecting static content"
python3 manage.py collectstatic --noinput

echo "Starting gunicorn service"
gunicorn \
    --bind "0.0.0.0:8000" \
    --workers 3 \
    --threads 6 \
    --timeout 120 \
    --worker-class "gevent" \
    djangokubernetesproject.wsgi
if [ "$?" != "0" ]
then
    echo "Failed to start gunicorn service"
    exit 1
fi
