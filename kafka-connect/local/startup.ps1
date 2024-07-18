# Create Namespace
kubectl apply -f .\local\namespace.yaml
kubectl config set-context --current --namespace=igbi-kafka-connect

# Deploy Apps
kubectl apply -f .\local\apps

#POD_NAME=$(kubectl get pods -l app=confluent-kafka-connector -o jsonpath='{.items[0].metadata.name}')
#echo $POD_NAME
#kubectl cp scripts/delete-all-connectors.sh $POD_NAME:/tmp/delete-all-connectors.sh
#kubectl exec $POD_NAME -- /bin/sh /tmp/delete-all-connectors.sh


#kubectl exec --stdin --tty <pod-name> -- /bin/sh

