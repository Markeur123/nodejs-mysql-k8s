#!/usr/bin/env bash

cd dev
npm init -y
npm install mysql http
docker build -t nodejsapp-dev .
docker tag nodejsapp-dev:latest markeur/nodejs-dev:latest
docker login
docker push markeur/nodejs-dev:latest
cd ../prod
npm init -y
npm install mysql http
docker build -t nodejsapp-prod .
docker tag nodejsapp-prod:latest markeur/nodejs-prod:latest
docker push markeur/nodejs-prod:latest
cd ..
minikube start
kubectl create namespace dev
kubectl create namespace prod
helm repo add stable https://charts.helm.sh/stable
helm install mysql-dev -n dev --set mysqlUser=dbdevuser,mysqlPassword=password,mysqlDatabase=dbdev stable/mysql
helm install mysql-prod -n prod --set mysqlUser=dbproduser,mysqlPassword=password,mysqlDatabase=dbprod stable/mysql
helm install nodejs-dev ./nodejs -n dev --values ./nodejs/nodejs-dev-values.yaml
helm install nodejs-prod ./nodejs -n prod --values ./nodejs/nodejs-prod-values.yaml
ssh -i ~/.minikube/machines/minikube/id_rsa docker@$(minikube ip) -fNT -L \*:30000:0.0.0.0:30000
ssh -i ~/.minikube/machines/minikube/id_rsa docker@$(minikube ip) -fNT -L \*:30001:0.0.0.0:30001
