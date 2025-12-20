#!/bin/bash

docker stop flask-app || true
docker rm flask-app || true

docker pull rajeshreddy0/simple-python-flask-app:latest 

docker run -d --name flask-app -p 5000:5000 rajeshreddy0/simple-python-flask-app:latest
