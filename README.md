# Helm chart for authorizer sidecar + directory 

1. Install helm, minikube and start minikube
```
brew install helm
brew install minikube

minikube start
```

2. Clone Aserto charts
````
git clone git@github.com:aserto-dev/charts
cd charts
````

3. (temporary) Load secrets from vault
````
export IMAGE_PULL_SECRET=$(vault kv get -field=DOCKER_CONFIG_JSON kv/github)
export GHCR_TOKEN=$(vault kv get -field=READ_WRITE_TOKEN kv/github)
````

**Note:** Configuration values are stored in aserto/values.yaml which can be edited to customize, however take care not to commit sensitive credentials to github.


4. Deploy helm chart to minikube 
````
$ helm install aserto1 aserto --set imagePullSecret=$IMAGE_PULL_SECRET,ghcrToken=$GHCR_TOKEN
NAME: aserto1
LAST DEPLOYED: Wed Feb  8 09:36:31 2023
NAMESPACE: default
STATUS: deployed
REVISION: 1
NOTES:
````

5. Observe pod creation with k9s

<img width="1241" alt="Screenshot 2023-02-08 at 9 28 22 AM" src="https://user-images.githubusercontent.com/3091714/217565148-425cc63d-bf01-4d5d-b5dd-15649b68410f.png">



6. Connect to the authorizer by running these commands:
````
  export AUTHORIZER_POD_NAME=$(kubectl get pods --namespace default -l "app.kubernetes.io/name=aserto-authorizer,app.kubernetes.io/instance=foobar8" -o jsonpath="{.items[0].metadata.name}")

  #http
  kubectl --namespace default port-forward $AUTHORIZER_POD_NAME 8383:8383
  #grpc
  kubectl --namespace default port-forward $AUTHORIZER_POD_NAME 8282:8282
````

7. Connect to the directory by running these commands:
````
  export DIRECTORY_POD_NAME=$(kubectl get pods --namespace default -l "app.kubernetes.io/name=aserto-directory,app.kubernetes.io/instance=foobar8" -o jsonpath="{.items[0].metadata.name}")

  #http
  kubectl --namespace default port-forward $DIRECTORY_POD_NAME 8080:8383 &
  #grpc
  kubectl --namespace default port-forward $DIRECTORY_POD_NAME 8443:8282 &
````

8. (temporary) Create a directory tenant via grpc
````
$ grpcurl --insecure -H "authorization: basic c96fe48da0735cf77fdba50134f52c43" \
  -d '{"tenant": {"id": "07f3e43c-a734-11ed-a7a0-002270b772a6", "name": "test"}}' \
  localhost:8443 aserto.directory.store.v2.Store.CreateTenant

{
  "result": {
    "id": "07f3e43c-a734-11ed-a7a0-002270b772a6",
    "name": "test",
    "createdAt": "2023-02-08T14:21:52.844988042Z",
    "updatedAt": "2023-02-08T14:21:52.844988042Z"
  }
}
````

9. Undeploy when finished
````
$ helm uninstall aserto1
release "aserto1" uninstalled
