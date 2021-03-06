#!/bin/bash
set -euxo pipefail

##############################################################################
##
##  Travis CI test script
##
##############################################################################

mvn -q package

docker pull open-liberty

docker build -t system:1.0-SNAPSHOT system/.
docker build -t inventory:1.0-SNAPSHOT inventory/.

kubectl apply -f kubernetes.yaml

sleep 120

kubectl get pods

echo $(minikube ip)

curl http://`minikube ip`:31000/system/properties
curl http://`minikube ip`:32000/inventory/systems

mvn failsafe:integration-test -Ddockerfile.skip=true -Dcluster.ip=$(minikube ip)
mvn failsafe:verify

kubectl logs $(kubectl get pods -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}' | grep system)
kubectl logs $(kubectl get pods -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}' | grep inventory)
