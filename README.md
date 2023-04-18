# Helm chart for authorizer sidecar + directory

1. Install helm, minikube and start minikube
```
brew install minikube helm kubectl grpcurl

minikube start
```

2. Clone Aserto charts
````
git clone git@github.com:aserto-dev/charts
cd charts
````

3. Deploy helm chart to minikube (pass secrets to chart)
````
> ./start.sh
... Cleaning up (errors ok) ...
... Deploying helm chart ...
... Waiting for services to become ready ...
[...]
*** Console is listening on http://localhost:8080 ***
*** Press Control-C to shutdown ***
````

4. Observe pod creation with k9s

<img width="1240" alt="Screenshot 2023-02-08 at 10 17 53 AM" src="https://user-images.githubusercontent.com/3091714/217571657-3f4d5e3d-6b3c-4492-b3c8-b52237df7268.png">

5. Access console via http://localhost:8080

6. Control-C to undeploy
````
$ helm uninstall aserto1
release "aserto1" uninstalled