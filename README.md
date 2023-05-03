## Aserto Charts for Kubernetes

For more information, please refer to the charts section of Aserto [documentation](http://localhost:3000/docs/getting-started/self-hosted/helm-chart).

### Usage

[Helm](https://helm.sh) must be installed to use the charts.  Please refer to
Helm's [documentation](https://helm.sh/docs) to get started.

Once Helm has been set up correctly, add the repo as follows:

```
helm repo add aserto https://charts.aserto.com
```

If you had already added this repo earlier, run "helm repo update" to retrieve
the latest versions of the packages.  You can then run "helm search repo
aserto" to see the charts.

To install the self-hosted chart:

```
helm install my-aserto aserto/self-hosted
```

To uninstall the chart:

```
helm delete my-aserto
```
