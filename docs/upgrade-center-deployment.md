# Enable Upgrade Center for Bold Reports

The **Upgrade Center** is an optional feature that enables in-application upgrade management for Bold Reports. Once deployed, it allows administrators to check for new releases and trigger upgrades directly from the Bold Reports administration panel — without manual intervention on the cluster.

> **Note:** Bold Reports uses the shared Bold Upgrade Center application configured in `BoldReports` deployment mode. The Playwright validation image is resolved from the release information API and is not configured in the Helm values file.

## Sections

- [Deploy Upgrade Center using kubectl](#deploy-upgrade-center-using-kubectl)
- [Deploy Upgrade Center using Helm](#deploy-upgrade-center-using-helm)
- [Access the Upgrade Center from Bold Reports](#access-the-upgrade-center-from-bold-reports)

## Deploy Upgrade Center using kubectl

### Step 1 — Download the Upgrade Center manifests

Download the following YAML files for Upgrade Center deployment:

| File | Description |
|------|-------------|
| [`bold-upgrade-center.yaml`](https://raw.githubusercontent.com/boldreports/bold-reports-kubernetes/master/deploy/bold-upgrade-center/bold-upgrade-center.yaml) | ServiceAccount, RBAC Role/RoleBinding, ConfigMap, Deployment, and Service for the Upgrade Center |
| [`bold-upgrade-center-playwright-secret.yaml`](https://raw.githubusercontent.com/boldreports/bold-reports-kubernetes/master/deploy/bold-upgrade-center/bold-upgrade-center-playwright-secret.yaml) | Secret containing the Bold Reports admin credentials used by the Playwright automation runner |
| [`ingressroute-upgrade-center.yaml`](https://raw.githubusercontent.com/boldreports/bold-reports-kubernetes/master/deploy/bold-upgrade-center/ingressroute-upgrade-center.yaml) | Traefik Middleware and IngressRoute to expose the Upgrade Center endpoint |

> **Note:** The Upgrade Center Deployment mounts the same persistent volume claim used by Bold Reports (`bold-fileserver-claim`). If the volume claim in your cluster is named differently, update the `claimName` under `volumes` in `bold-upgrade-center.yaml` before applying it.

### Step 2 — Configure admin credentials

> **RBAC scope:** The Upgrade Center RBAC is namespace-scoped. The manifest creates a `Role` and `RoleBinding` in the same namespace where Bold Reports is deployed, and it does not require cluster-wide `ClusterRole` access. Apply the manifest in the Bold Reports namespace so the Upgrade Center can manage only the Bold Reports resources in that namespace.

Open `bold-upgrade-center-playwright-secret.yaml` and replace the placeholder values with your Bold Reports administrator credentials:

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: bold-upgrade-center-playwright
  namespace: bold-services
type: Opaque
stringData:
  BOLD_ADMIN_USERNAME: "<your-admin-email>"
  BOLD_ADMIN_PASSWORD: "<your-admin-password>"
```

> **Note:** These credentials must match the administrator account configured during Bold Reports' initial setup. The Playwright runner uses them to automate the upgrade workflow on your behalf.

### Step 3 — Configure the Ingress route

Open `ingressroute-upgrade-center.yaml` and update the hostname and TLS secret to match your Bold Reports deployment:

```yaml
- kind: Rule
  match: Host(`<your-domain.com>`) && PathPrefix(`/upgrade-center`)
```

Replace `<your-domain.com>` with your actual application domain (e.g., `reports.example.com`).

If your deployment uses **HTTPS**, ensure the `tls.secretName` matches the TLS secret used by your existing Bold Reports IngressRoute:

```yaml
tls:
  secretName: bold-tls   # Replace with your TLS secret name if different
```

> **Note:** This manifest is specific to Traefik. If your Bold Reports deployment uses a different ingress (for example, nginx or Istio), expose the `bold-upgrade-center` service on the `/upgrade-center` path using your ingress configuration instead, and skip this file.

### Step 4 — Apply the manifests

Run the following commands in the namespace where Bold Reports is deployed (default: `bold-services`):

```sh
kubectl apply -f bold-upgrade-center-playwright-secret.yaml
```

```sh
kubectl apply -f bold-upgrade-center.yaml
```

```sh
kubectl apply -f ingressroute-upgrade-center.yaml
```

### Step 5 — Verify the deployment

Confirm that the Upgrade Center pod is running:

```sh
kubectl get pods -n bold-services -l app.kubernetes.io/name=bold-upgrade-center
```

### Step 6 — Access the Upgrade Center

See [Access the Upgrade Center from Bold Reports](#access-the-upgrade-center-from-bold-reports) below.

## Deploy Upgrade Center using Helm

#### Get Repo Info

1. Add the Bold Reports helm repository

    ```console
    helm repo add boldreports https://boldreports.github.io/boldreports-server-in-kubernetes
    helm repo update
    ```

2. View charts in repo

    ```console
    helm search repo boldreports

    NAME                       CHART VERSION   APP VERSION   DESCRIPTION
    boldreports/boldreports    14.1.18         14.1.18       Make bolder business decisions with complete repo...
    ```

#### Install Chart

You can either:

* Use a latest `values.yaml` file downloaded from the Bold Reports repository for a fresh deployment.
* Use the existing `values.yaml` file from your current deployment and update it with the Upgrade Center configuration.

Download the appropriate `values.yaml` file based on your Kubernetes platform:

* For `GKE` please download the values.yaml file [here](https://raw.githubusercontent.com/boldreports/bold-reports-kubernetes/master/helm/custom-values/gke-values.yaml).
* For `EKS` please download the values.yaml file [here](https://raw.githubusercontent.com/boldreports/bold-reports-kubernetes/master/helm/custom-values/eks-values.yaml).
* For `AKS` please download the values.yaml file [here](https://raw.githubusercontent.com/boldreports/bold-reports-kubernetes/master/helm/custom-values/aks-values.yaml).
* For `ACK` please download the values.yaml file [here](https://raw.githubusercontent.com/boldreports/bold-reports-kubernetes/master/helm/custom-values/ack-values.yaml).

> **Note:** Upgrade Center can be enabled during the initial Bold Reports deployment or added to an existing one. Simply set `upgradeCenter.enabled: true` in your values file before running `helm install` or `helm upgrade`.

> **StorageClass requirement:** Upgrade Center creates a temporary shared volume for validation state used by the Playwright validation jobs. The Kubernetes cluster must have a working default StorageClass and the matching CSI driver installed. If no default StorageClass is available, the validation pod can remain in `Pending` state while waiting for the shared volume.

### Step 1 — Enable Upgrade Center in values.yaml

> **RBAC scope:** The Helm chart deploys namespace-scoped RBAC for the Upgrade Center by using a `Role` and `RoleBinding` in the release namespace. It does not require cluster-wide `ClusterRole` access.

Open your cluster overlay file (for example, `helm/custom-values/aks-values.yaml`) and set `upgradeCenter.enabled` to `true`:

```yaml
upgradeCenter:
  enabled: true
```

### Step 2 — Configure admin credentials

The Upgrade Center uses administrator credentials to authenticate the Playwright runner during pre-upgrade validation.

> **Note:** If you have already configured `rootUserDetails.email` and `rootUserDetails.password` in your values file, those credentials are used automatically. Skip this step if that is the case.

If `rootUserDetails` is not set, provide the credentials explicitly under `upgradeCenter.secret`:

```yaml
upgradeCenter:
  enabled: true
  secret:
    adminUsername: "<your-admin-email>"
    adminPassword: "<your-admin-password>"
```

#### Environment variables reference

| Parameter | Description | Default |
|-----------|-------------|---------|
| `upgradeCenter.enabled` | Set to `true` to deploy and enable the Upgrade Center service. | `false` |
| `upgradeCenter.secret.adminUsername` | Bold Reports administrator username. Used only when `rootUserDetails.email` is not provided. | `""` |
| `upgradeCenter.secret.adminPassword` | Bold Reports administrator password. Used only when `rootUserDetails.password` is not provided. | `""` |
| `upgradeCenter.resources.requests.cpu` | CPU request for Upgrade Center pods. | `250m` |
| `upgradeCenter.resources.requests.memory` | Memory request for Upgrade Center pods. | `512Mi` |
| `upgradeCenter.resources.limits.cpu` | CPU limit for Upgrade Center pods. | `1` |
| `upgradeCenter.resources.limits.memory` | Memory limit for Upgrade Center pods. | `1536Mi` |

### Step 3 — Apply the Helm upgrade

Run the `helm upgrade` command with your updated values file. Replace the placeholder values with those matching your deployment:

```sh
helm upgrade --install boldreports boldreports/boldreports \
  --namespace bold-services \
  -f values.yaml
```

### Step 4 — Verify the deployment

Check that all Upgrade Center pods are running:

```sh
kubectl get pods -n bold-services -l app.kubernetes.io/name=bold-upgrade-center
```

You should see the pod in `Running` state:

```
NAME                                         READY   STATUS    RESTARTS   AGE
bold-upgrade-center-xxxxxxxxx-xxxxx   1/1     Running   0          1m
```

Verify the service is created:

```sh
kubectl get svc bold-upgrade-center -n bold-services
```

## Access the Upgrade Center from Bold Reports

Once all services are running and the ingress is active:

1. Open your browser and navigate to your Bold Reports administration page:

   ```
   https://<your-domain>/ums/administration
   ```

2. In the top-right corner of the page, click the **question mark (?)** icon.

3. You will see an option — **Check for Upgrades**. Click it to open the Upgrade Center.

    ![Check-Updates](/docs/images/check-for-updates.png)

4. The Upgrade Center will display the currently installed version and any available upgrades. You can initiate an upgrade directly from this interface.

    ![Upgrade](/docs/images/upgrade-details.png)

    ![confirm-upgrade](/docs/images/start-upgrade.png)

## See also

- **[Bold Reports Documentation](https://help.boldreports.com/enterprise-reporting/)** — Learn more about deploying and upgrading Bold Reports.