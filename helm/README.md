# Deploy Bold Reports using Helm

This chart installs [Bold Reports](https://www.boldreports.com/) on Kubernetes. You can create Kubernetes cluster on either cloud or on-premise infrastructure. Please follow the below documentation for Bold Reports deployment in a specific cloud and on-premise environments.
    
## Deployment prerequisites

* [Install Helm](https://helm.sh/docs/intro/install/) to deploy Bold Reports using Helm.
* [Install kubectl](https://kubernetes.io/docs/tasks/tools/#kubectl)
* [File Storage](docs/pre-requisites.md#file-storage)
* [Create and connect a cluster](docs/pre-requisites.md#create-a-cluster)
* [Load Balancing](docs/pre-requisites.md#load-balancing)

> **Note:** Note the [Ingress IP address](docs/pre-requisites.md#get-ingress-ip) to use it while crafting values.yaml when installing Bold Reports with helm chart.

## Get Repo Info

1. Add the Bold Reports helm repository

```console
helm repo add boldreports https://boldreports.github.io/boldreports-server-in-kubernetes
helm repo update
```

2. View charts in repo

```console
helm search repo boldreports

NAME            CHART VERSION   APP VERSION     DESCRIPTION
boldreports/boldreports   14.1.18           14.1.18         Make bolder business decisions with complete reporting solutions...
```

_See [helm repo](https://helm.sh/docs/helm/helm_repo/) for command documentation._

## Install Chart

For Helm chart, you'll need to craft a `values.yaml`.

* For `EKS` please download the values.yaml file [here](https://raw.githubusercontent.com/boldreports/bold-reports-kubernetes/master/helm/custom-values/eks-values.yaml).
* For `AKS` please download the values.yaml file [here](https://raw.githubusercontent.com/boldreports/bold-reports-kubernetes/master/helm/custom-values/aks-values.yaml).
* For `GKE` please download the values.yaml file [here](https://raw.githubusercontent.com/boldreports/bold-reports-kubernetes/master/helm/custom-values/gke-values.yaml).
* For `ACK` please download the values.yaml file [here](https://raw.githubusercontent.com/boldreports/bold-reports-kubernetes/master/helm/custom-values/ack-values.yaml)

<br/>

<table>
    <tr>
      <td>
       <b>Name</b>
      </td>
      <td>
       <b>Description</b>
      </td>
    </tr>
    <tr>
      <td>
       namespace
      </td>
      <td>
       The namespace in which the Bold Reports resources will be dpleoyed in the kubernetes cluster.<br/>
       The default namespace is <i>bold-services</i>
      </td>
    </tr>
    <tr>
      <td>
       appBaseUrl *
      </td>
      <td>
       Domain or <a href='docs/pre-requisites.md#get-ingress-ip'>Ingress IP address</a> with http/https protocol. Follow the <a href='docs/configuration.md#ssl-termination'>SSL Termination</a> to configure SSL certificate for https protocol after deploying Bold Reports in your cluster.
      </td>
    </tr>
    <tr>
      <td>
       optionalLibs
      </td>
      <td>
       These are the client libraries used in Bold Reports by default.<br/>
       '<i>mysql,oracle,postgresql,snowflake</i>'<br/>
       Please refer to <a href='docs/configuration.md#client-libraries'>Optional Client Libraries</a> section to know more.
      </td>
    </tr>
    <tr>
      <td>
       clusterProvider
      </td>
      <td>
       The type of kubernetes cluster provider you are using.<br/>
       The recommended values are '<i>eks,aks,gke</i>'
      </td>
    </tr>
    <tr>
      <td>
       persistentVolume *
      </td>
      <td>
       Please refer to <a href='docs/configuration.md#persistent-volume'>this</a> section to know more on how to set Persistant Volumes for Bold Reports.
      </td>
    </tr>
    <tr>
      <td>
       loadBalancer
      </td>
      <td>
       Currently we have provided support for Nginx and Istio as Load Balancers in Bold Reports. Please refer to <a href='docs/configuration.md#load-balancing'>this</a> section for configuring Load balancer for Bold Reports.
      </td>
    </tr>
    <tr>
      <td>
       autoscaling
      </td>
      <td>
       By default autoscaling is enabled in Bold Reports. Please refer to <a href='docs/configuration.md#auto-scaling'>this</a> section to configure autoscaling in Bold Reports.
      </td>
    </tr>
    <tr>
      <td>
       tolerationEnable: false<br />
       tolerations:
       </td>
      <td>
       Tolerations allow the pods to be scheduled into nodes with matching taints. Set this to true if you use tolerations in your cluster. If you need more than one toleration, you can add multiple tolerations below.
      </td>
    </tr>
    <tr>
      <td>
       nodeAffinityEnable: false<br />
       nodeAffinity:
      </td>
      <td>
       Node affinity ensures that the pods are scheduled into nodes with matching labels. Set this to true if you use node affinity in your cluster.
      </td>
    </tr>
    <tr>
      <td>
         podAffinityEnable: false
      </td>
      <td>
        Pod affinity ensures that the pods are scheduled into nodes with matching pods. Set this to true if you use pod affinity in your cluster
      </td>
    </tr>
    <tr>
      <td>
         podAntiAffinityEnable: false
      </td>
      <td>
        Pod anti-affinity ensures that the pods are not scheduled into nodes with matching pods. Set this to true if you use pod anti-affinity in your cluster.
      </td>
    </tr>
    <tr>
      <td>
        upgradeCenter.enabled
      </td>
      <td>
        Set to <code>true</code> to deploy and enable the Upgrade Center service for Bold Reports. Default is <code>false</code>.<br /><br />
        For full configuration options (credentials, resources, and validation settings), refer to the <a href="../docs/upgrade-center-deployment.md#deploy-upgrade-center-using-helm">Upgrade Center configuration guide</a>.
      </td>
    </tr>
</table>
<br/>

> **Note:** Items marked with `*` are mandatory fields in values.yaml

## Environment variables for configuring Storage in backend
The following environment variables are optional. If not provided, Bold Reports will use the default configured values.

### OCI Storage Configuration

To use OCI storage, set `ociStorage.enabled: true`.

<table>
    <tr>
      <td>
       <b>Name</b>
      </td>
      <td>
       <b>Description</b>
      </td>
    </tr>
    <tr>
      <td>
       ociStorage.enabled
      </td>
      <td>
       Enable OCI storage backend. Set to <code>true</code> to use OCI storage.
      </td>
    </tr>
    <tr>
      <td>
       ociStorage.accessKey
      </td>
      <td>
       OCI access key for authentication (e.g., your OCI user access key).
      </td>
    </tr>
    <tr>
      <td>
       ociStorage.bucketName
      </td>
      <td>
       Name of the OCI bucket to use for storage.
      </td>
    </tr>
    <tr>
      <td>
       ociStorage.namespace
      </td>
      <td>
       OCI namespace (tenant OCID or namespace name).
      </td>
    </tr>
    <tr>
      <td>
       ociStorage.region
      </td>
      <td>
       OCI region where the bucket is located (e.g., us-ashburn-1).
      </td>
    </tr>
    <tr>
      <td>
       ociStorage.rootFolderName
      </td>
      <td>
       Root folder path within the bucket for storing data.
      </td>
    </tr>
    <tr>
      <td>
       ociStorage.secretKey
      </td>
      <td>
       OCI secret key for authentication (e.g., your OCI user secret key).
      </td>
    </tr>
    <tr>
      <td>
       ociStorage.storageType
      </td>
      <td>
       Type of OCI storage. Default value is <code>4</code>.
      </td>
    </tr>
</table>
<br/>

Run the following command to delpoy Bold Reports in your cluster.

```console
helm install [RELEASE_NAME] boldreports/boldreports -f [Crafted values.yaml file]
```
Ex:  `helm install boldreports boldreports/boldreports -f my-values.yaml`

Refer [here](docs/configuration.md) for advanced configuration including SSL termination, optional client libraries, etc.

_See [helm install](https://helm.sh/docs/helm/helm_install/) for command documentation._

## Environment variables for configuring Upgrade Center

The following environment variables are used to configure the Upgrade Center service for Bold Reports. Set `upgradeCenter.enabled: true` to deploy the service. For full deployment steps and configuration details, refer to the [Upgrade Center configuration guide](../docs/upgrade-center-deployment.md#deploy-upgrade-center-using-helm).

<table>
    <tr>
      <td>
       <b>Name</b>
      </td>
      <td>
       <b>Description</b>
      </td>
    </tr>
    <tr>
      <td>
       upgradeCenter.enabled
      </td>
      <td>
       Set to <code>true</code> to deploy and enable the Upgrade Center service for Bold Reports. Default is <code>false</code>.
      </td>
    </tr>
    <tr>
      <td>
       upgradeCenter.resources.requests.cpu
      </td>
      <td>
       CPU request for Upgrade Center pods. Default is <code>250m</code>.
      </td>
    </tr>
    <tr>
      <td>
       upgradeCenter.resources.requests.memory
      </td>
      <td>
       Memory request for Upgrade Center pods. Default is <code>512Mi</code>.
      </td>
    </tr>
    <tr>
      <td>
       upgradeCenter.resources.limits.cpu
      </td>
      <td>
       CPU limit for Upgrade Center pods. Default is <code>1</code>.
      </td>
    </tr>
    <tr>
      <td>
       upgradeCenter.resources.limits.memory
      </td>
      <td>
       Memory limit for Upgrade Center pods. Default is <code>1536Mi</code>.
      </td>
    </tr>
    <tr>
      <td>
       upgradeCenter.secret.adminUsername
      </td>
      <td>
       Root user administrator username for Upgrade Center authentication. If not provided, the username from <code>rootUserDetails.email</code> will be used. This field is optional if <code>rootUserDetails</code> is already configured.
      </td>
    </tr>
    <tr>
      <td>
       upgradeCenter.secret.adminPassword
      </td>
      <td>
       Root user administrator password for Upgrade Center authentication. If not provided, the password from <code>rootUserDetails.password</code> will be used. This field is optional if <code>rootUserDetails</code> is already configured.
      </td>
    </tr>
</table>
<br/>

> **StorageClass requirement:** Upgrade Center creates a temporary shared volume for validation state. The Kubernetes cluster must have a working default StorageClass and the matching CSI driver installed. If the default StorageClass cannot provision a volume, the validation pod remains in `Pending` state.

<br/>

## Upgrade

Run the following command to get the latest version of Bold Reports helm chart.

```console
helm repo update
```

Run the below command to apply changes in your Bold Reports release or upgrading Bold Reports to latest version.

```console
helm upgrade [RELEASE_NAME] boldreports/boldreports -f [Crafted values.yaml file]
```

Ex:  `helm upgrade boldreports boldreports/boldreports -f my-values.yaml`

**Troubleshooting: repo 404 when running `helm repo update`**

If you see an error like:

```
Hang tight while we grab the latest from your chart repositories...
...Unable to get an update from the "boldreports" chart repository (https://boldreports.github.io/bold-reports-kubernetes):
        failed to fetch https://boldreports.github.io/bold-reports-kubernetes/index.yaml : 404 Not Found
```

remove and re-add the repository (this fixes a stale/incorrect repo entry), then update:

```console
helm repo remove boldreports
helm repo add boldreports https://boldreports.github.io/boldreports-server-in-kubernetes
helm repo update
```

## Uninstall Chart

```console
helm uninstall [RELEASE_NAME]
```
Ex:  `helm uninstall boldreports`

This removes all the Kubernetes components associated with the chart and deletes the release.

_See [helm uninstall](https://helm.sh/docs/helm/helm_uninstall/) for command documentation._

## Application Startup

Configure the Bold Reports On-Premise application startup to use the application. Please refer the following link for more details on configuring the application startup.
    
https://help.boldreports.com/enterprise-reporting/administrator-guide/application-startup/

## Accessing Upgrade Center

If you have enabled the Upgrade Center service (`upgradeCenter.enabled: true`), you can access it using the following URL:

```
https://<your-domain>/upgrade-center
```

**Requirements:**
- The Upgrade Center must be enabled in your values.yaml configuration
- You must be logged in with root administrator credentials
- The Bold Reports application must be running and accessible
- Proper network connectivity to the Upgrade Center ingress path

**Disable Upgrade Center:**

To disable the Upgrade Center service, set `upgradeCenter.enabled: false` in your values.yaml and run:

```console
helm upgrade [RELEASE_NAME] boldreports/boldreports -f [Crafted values.yaml file]
```

This will remove the Upgrade Center deployment, service, and ingress routes from your cluster.
