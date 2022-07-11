FROM ubuntu:20.04

# Installing dependencies:
RUN apt-get update && apt-get install -y tzdata && apt install -y python3.8 python3-pip
RUN apt install python3-dev libpq-dev nginx -y
RUN pip install django gunicorn psycopg2

# Adding application code to the Docker image:
ADD djangokubernetesproject /app/djangokubernetesproject
ADD manage.py /app/manage.py

# Setting working directory.
WORKDIR /app
RUN ls -la

# Installing requirements
RUN pip install -r requirements.txt

# Exposing application on port 8000:
EXPOSE 8000

# Running migrations and starting gunicorn process:
COPY bin/entrypoint.sh entrypoint.sh
RUN chmod a+x entrypoint.sh
ENTRYPOINT ["./entrypoint.sh"]
