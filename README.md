# K8s cluster configuration


[![Lint](https://github.com/clayman-micro/vega/actions/workflows/main.yml/badge.svg)](https://github.com/clayman-micro/vega/actions/workflows/main.yml)


## Configure cluster

### Setup storage

```shell

-> ansible-playbook -i inventory playbooks/cluster/storage.yml

```

Get list of attached block devices on worker nodes

```shell

-> kubectl get bd -n openebs

```

#### Create cStore storage pools

You will need to create a Kubernetes custom resource called CStorPoolCluster, specifying the details of the nodes and the devices on those nodes that must be used to setup cStor pools. You can start by copying the following Sample CSPC yaml into a file named `cspc.yaml` and modifying it with details from your cluster.

```yaml
apiVersion: cstor.openebs.io/v1
kind: CStorPoolCluster
metadata:
 name: cstor-disk-pool
 namespace: openebs
spec:
 pools:
   - nodeSelector:
       kubernetes.io/hostname: "worker-node-1"
     dataRaidGroups:
       - blockDevices:
           - blockDeviceName: "blockdevice-10ad9f484c299597ed1e126d7b857967"
     poolConfig:
       dataRaidGroupType: "stripe"
```

We have named the configuration YAML file as cspc.yaml. Execute the following command for CSPC creation,

```shell

-> kubectl apply -f cspc.yml

```

To verify the status of created CSPC, execute:


```shell

-> kubectl get cspc -n openebs

```

Check if the pool instances report their status as ONLINE using the below command:

```shell

-> kubectl get cspi -n openebs

```

#### Creating cStor storage classes#

Create a YAML spec file cstor-csi-disk.yaml using the template given below. Update the pool, replica count and other policies. By using this sample configuration YAML, a StorageClass will be created with 3 OpenEBS cStor replicas and will configure themselves on the pool instances.

```yaml
kind: StorageClass
apiVersion: storage.k8s.io/v1
metadata:
  name: cstor-csi-disk
provisioner: cstor.csi.openebs.io
allowVolumeExpansion: true
parameters:
  cas-type: cstor
  # cstorPoolCluster should have the name of the CSPC
  cstorPoolCluster: cstor-disk-pool
  # replicaCount should be <= no. of CSPI created in the selected CSPC
  replicaCount: "3"
```

To deploy the YAML, execute:

```shell

-> kubectl apply -f cstor-csi-disk.yaml

```

To verify, execute:

```shell

-> kubectl get sc

```
