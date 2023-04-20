#!/usr/bin/env bash
set -eo pipefail

IMAGE_PULL_SECRET=$(vault kv get -field=DOCKER_CONFIG_JSON kv/github)
GHCR_TOKEN=$(vault kv get -field=READ_WRITE_TOKEN kv/github)
VAULT_ADDR=https://vault.eng.aserto.com
vault login --no-print --method=github


# trap ctrl-c and call ctrl_c()
trap cleanup INT


function cleanup() {
  echo '... Cleaning up (errors ok) ...'
  helm delete aserto1 || true
  #kill $(ps|grep kubectl|grep port-forward|awk '{print $1}') || true
}

cleanup
sleep 5

echo ... Deploying helm chart ...
helm install aserto1 aserto --set global.sidecar.ghcrToken="$GHCR_TOKEN",imagePullSecret="$IMAGE_PULL_SECRET"

echo ... Waiting for services to become ready ...
POSTGRES_POD_NAME=$(kubectl get pods --namespace default -l "app.kubernetes.io/name=postgresql,app.kubernetes.io/instance=aserto1" -o jsonpath="{.items[0].metadata.name}")
kubectl wait pods -n default $POSTGRES_POD_NAME --for condition=Ready --timeout=120s

AUTHORIZER_POD_NAME=$(kubectl get pods --namespace default -l "app.kubernetes.io/name=aserto-authorizer,app.kubernetes.io/instance=aserto1" -o jsonpath="{.items[0].metadata.name}")
kubectl wait pods -n default $AUTHORIZER_POD_NAME --for condition=Ready --timeout=120s

DIRECTORY_POD_NAME=$(kubectl get pods --namespace default -l "app.kubernetes.io/name=aserto-directory,app.kubernetes.io/instance=aserto1" -o jsonpath="{.items[0].metadata.name}")
kubectl wait pods -n default $DIRECTORY_POD_NAME --for condition=Ready --timeout=120s

CONSOLE_POD_NAME=$(kubectl get pods --namespace default -l "app.kubernetes.io/name=aserto-console,app.kubernetes.io/instance=aserto1" -o jsonpath="{.items[0].metadata.name}")
kubectl wait pods -n default $CONSOLE_POD_NAME --for condition=Ready --timeout=120s

NGINX_POD_NAME=$(kubectl get pods --namespace default -l "app.kubernetes.io/name=proxy,app.kubernetes.io/instance=aserto1" -o jsonpath="{.items[0].metadata.name}")
kubectl wait pods -n default $NGINX_POD_NAME --for condition=Ready --timeout=120s

kubectl --namespace default port-forward $DIRECTORY_POD_NAME 9393:8383 &
kubectl --namespace default port-forward $DIRECTORY_POD_NAME 9292:8282 &
kubectl --namespace default port-forward $AUTHORIZER_POD_NAME 8383:8383 &
kubectl --namespace default port-forward $AUTHORIZER_POD_NAME 8282:8282 &
#kubectl --namespace default port-forward $CONSOLE_POD_NAME 8080:8080 &
kubectl --namespace default port-forward $NGINX_POD_NAME 8080:8080 &


sleep 5
echo ... Creating directory tenant ...
grpcurl --insecure -H "authorization: basic c96fe48da0735cf77fdba50134f52c43" \
-d '{"tenant": {"id": "07f3e43c-a734-11ed-a7a0-002270b772a6", "name": "test"}}' \
localhost:9292 aserto.directory.store.v2.Store.CreateTenant


echo
echo '*** Console is listening on http://localhost:8080 ***'
echo '*** Press Control-C to shutdown ***'
echo
wait