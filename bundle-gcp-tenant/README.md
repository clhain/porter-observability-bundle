# Example Porter Bundle

A basic example k8s deploy on GCP using terraform

## How to use

### Install Porter

See [Porter docs](https://porter.sh/install/) for more details

```bash
curl -L https://cdn.porter.sh/latest/install-linux.sh | bash
```

### Setup Google Cloud Service Account

A GCP service account is needed with the appropriate roles for GKE admin.

```bash
gcloud iam service-accounts create porter-deploy \
  --description="for porter deployments" \
  --display-name="porter-deploy"

gcloud iam service-accounts keys create ~/.config/gcloud-porter-deploy-private-key.json \
  --iam-account=porter-deploy@${GCP_PROJECT_ID}.iam.gserviceaccount.com

gcloud projects add-iam-policy-binding ${GCP_PROJECT_ID} \
  --member="serviceAccount:porter-deploy@${GCP_PROJECT_ID}.iam.gserviceaccount.com" \
  --role="roles/container.clusterAdmin"

gcloud projects add-iam-policy-binding ${GCP_PROJECT_ID} \
  --member="serviceAccount:porter-deploy@${GCP_PROJECT_ID}.iam.gserviceaccount.com" \
  --role="roles/iam.serviceAccountUser"

gcloud projects add-iam-policy-binding ${GCP_PROJECT_ID} \
  --member="serviceAccount:porter-deploy@${GCP_PROJECT_ID}.iam.gserviceaccount.com" \
  --role="roles/compute.instanceAdmin.v1"
```

### Create Porter Credentials

Generate a set of credentials to pass into porter.

```
porter credential generate gcp-gke --reference ghcr.io/bdegeeter/gcp-gke:v0.2.2
```

```
Generating new credential gcp-gke from bundle gcp-gke
==> 1 credentials required for bundle gcp-gke
? How would you like to set credential "gcloud-key-file"
  file path
? Enter the path that will be used to set credential "gcloud-key-file"
  $HOME/.config/gcloud-porter-deploy-private-key.json
```

### Install Bundle

```
porter install --reference ghcr.io/bdegeeter/gcp-gke:v0.2.2 --cred gcp-gke --param="gcp_project_id=${GCP_PROJECT_ID}"
```

### Uninstall Bundle

```
porter uninstall --reference ghcr.io/bdegeeter/gcp-gke:v0.2.2 --cred gcp-gke
```

## Porter Operator Integration

The [Porter operator](https://github.com/getporter/operator) is in early development.  Here's the basic steps needed 
to run this example via the Porter operator `Install` resource.

For this example we'll use the [kubernetes plugin for](https://github.com/getporter/kubernetes-plugins) secrets and storage.

Check https://github.com/getporter/operator for the latest instructions.

### Generate Operator Credentials

Update the porter client to use the k8s plugin for storage and secrets.

`$HOME/.porter/config.toml`
```
default-storage = "kubernetes-storage"
default-secrets = "kubernetes-secrets"

[[storage]]
name = "kubernetes-storage"
plugin = "kubernetes.storage"

[[secrets]]
name = "kubernetes-secrets"
plugin = "kubernetes.secret"
```

Create k8s secrets for the credentials
```
kubectl create secret generic -n default --from-file=credential=$HOME/.porter/config.toml porterops-config
kubectl create secret generic -n default --from-file=credential=$HOME/.kube/config porterops-kubeconfig
```

```
porter credentials generate porterops -r ghcr.io/getporter/porter-operator:canary
```
```
Generating new credential porterops from bundle porter-operator
==> 6 credentials required for bundle porter-operator
? How would you like to set credential "azure-client-id"
  specific value
? Enter the value that will be used to set credential "azure-client-id"

? How would you like to set credential "azure-client-secret"
  specific value
? Enter the value that will be used to set credential "azure-client-secret"

? How would you like to set credential "azure-storage-connection-string"
  specific value
? Enter the value that will be used to set credential "azure-storage-connection-string"

? How would you like to set credential "azure-tenant-id"
  specific value
? Enter the value that will be used to set credential "azure-tenant-id"

? How would you like to set credential "config.toml"
  secret
? Enter the secret that will be used to set credential "config.toml"
  porterops-config

? How would you like to set credential "kubeconfig"
  secret
? Enter the secret that will be used to set credential "kubeconfig"
  porterops-kubeconfig
```


### Install Porter operator

```
porter install porterops -c porterops -r ghcr.io/getporter/porter-operator:canary
```

Configure k8s default namespace for job execution
```
porter invoke porterops --action configure-namespace --param namespace=default -c porterops
```



### Create k8s secrets for bundle install

```
kubectl create secret generic -n default --from-file=credential=$HOME/.config/gcloud-porter-deploy-private-key.json gcloud-key-file
```

### Generate credentials for the bundle

Use the name of the secret just created

```
 porter credential generate gcp-gke --reference ghcr.io/bdegeeter/gcp-gke:v0.2.2
Generating new credential gcp-gke from bundle gcp-gke
==> 1 credentials required for bundle gcp-gke
? How would you like to set credential "gcloud-key-file"
  secret
? Enter the secret that will be used to set credential "gcloud-key-file"
  gcloud-key-file
```

### Create k8s Installation resource

`bundle-install.yaml`
```
apiVersion: porter.sh/v1
kind: Installation
metadata:
  name: gcp-gke
spec:
  reference: "ghcr.io/bdegeeter/gcp-gke:v0.2.2"
  action: "install"
  credentialSets:
   - gcp-gke
  parameters:
   gcp_project_id: <YOUR-GCP-PROJECT-ID> # required
```

```
kubectl apply -f bundle-install.yaml
```
```
kubectl logs -l installation=gcp-gke
```