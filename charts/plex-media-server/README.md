# plex-media-server

![Version: 1.3.0](https://img.shields.io/badge/Version-1.3.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 1.42.2](https://img.shields.io/badge/AppVersion-1.42.2-informational?style=flat-square)

**Homepage:** <https://www.plex.tv>

A Helm chart for deploying a PMS server to a Kubernetes cluster

While Plex is responsible for maintaining this Helm chart, we cannot provide support for troubleshooting related to its usage. For community assistance, please visit our [support forums](https://forums.plex.tv/).

### Installation via Helm

1. Add the Helm chart repo

```bash
helm repo add plex https://raw.githubusercontent.com/plexinc/pms-docker/gh-pages
```

2. Inspect & modify the default values (optional)

```bash
helm show values plex/plex-media-server > values.yaml
```

3. Install the chart

```bash
helm upgrade --install plex plex/plex-media-server --values values.yaml
```

[Additional details available here](https://www.plex.tv/blog/plex-pro-week-23-a-z-on-k8s-for-plex-media-server/)

### Sample init Container scripts

If you already have a different PMS server running elsewhere and wish to migrate it to be running in Kubernetes
the easiest way to do that is to import the existing PMS database through the use of a custom init script.

**Note: the init script must include a mechanism to exit early if the pms database already exists to prevent from overwriting its contents**

The following script is an example (using the default `alpine` init container) that will pull
a tar gziped file that contains the pms `Library` directory from some web server.

```sh
#!/bin/sh
echo "fetching pre-existing pms database to import..."

if [ -d "/config/Library" ]; then
  echo "PMS library already exists, exiting."
  exit 0
fi

apk --no-cache add curl
curl http://example.com/pms.tgz -o pms.tgz
tar -xvzf pms.tgz -C /config
rm pms.tgz

echo "Done."
```

This next example could be used if you don't have or can't host the existing pms database archive on a web server.
However, this one _does_ require that two commands are run manually once the init container starts up.

1. Manually copy the pms database into the pod: `kubectl cp pms.tgz <namespace>/<podname>:/pms.tgz.up -c <release name>-pms-chart-pms-init`
2. Once the file is uploaded copy rename it on the pod to the correct name that will be processed `kubectl exec -n <namespace> --stdin --tty <pod>  -c <release name>-pms-chart-pms-init h  -- mv /pms.tgz.up /pms.tgz`

The file is being uploaded with a temporary name so that the script does not start trying to unpack the database until it has finished uploading.

```sh
#!/bin/sh
echo "waiting for pre-existing pms database to uploaded..."

if [ -d "/config/Library" ]; then
  echo "PMS library already exists, exiting."
  exit 0
fi

# wait for the database archive to be manually copied to the server
while [ ! -f /pms.tgz ]; do sleep 2; done;

tar -xvzf /pms.tgz -C /config
rm pms.tgz

echo "Done."
```

## Contributing

Before contributing, please read the [Code of Conduct](../../CODE_OF_CONDUCT.md).

## License

[GNU GPLv3](./LICENSE)

## Source Code

* <https://github.com/plexinc/pms-docker>

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` |  |
| commonLabels | object | `{}` | Common Labels for all resources created by this chart. |
| dnsConfig | object | `{}` | Optional DNS configuration for the Pod |
| dnsPolicy | string | `""` | Specifies the Pod's DNS policy. Default is typically 'ClusterFirst'.    If 'hostNetwork: true' is used, you may need to set this to 'ClusterFirstWithHostNet'.    Allowed values are ClusterFirst, Default, None, or ClusterFirstWithHostNet. |
| extraContainers | list | `[]` |  |
| extraEnv | object | `{}` |  |
| extraInitContainers | object | `{}` |  |
| extraVolumeMounts | list | `[]` | Optionally specify additional volume mounts for the PMS and init containers. |
| extraVolumes | list | `[]` | Optionally specify additional volumes for the pod. |
| fullnameOverride | string | `""` |  |
| global.imageRegistry | string | `""` | Allow parent charts to override registry hostname |
| hostNetwork | bool | `false` | Set to true to run the Pod in the host's network namespace.    This may be required for specific networking setups or accessing local resources. |
| httpRoute.annotations | object | `{}` | Custom annotations to put on the HTTPRoute resource |
| httpRoute.enabled | bool | `false` | Specify if an HTTPRoute resource for the pms server should be created or not |
| httpRoute.hostnames | list | `[]` | Hostnames to match for the HTTPRoute |
| httpRoute.parentRefs | list | `[]` | Gateway API parent references (required when enabled) |
| image | object | `{"pullPolicy":"IfNotPresent","registry":"index.docker.io","repository":"plexinc/pms-docker","sha":"","tag":"1.42.2.10156-f737b826c"}` | The docker image information for the pms application |
| image.registry | string | `"index.docker.io"` | The public dockerhub registry |
| imagePullSecrets | list | `[]` |  |
| ingress.annotations | object | `{}` | Custom annotations to put on the ingress resource |
| ingress.enabled | bool | `false` | Specify if an ingress resource for the pms server should be created or not |
| ingress.ingressClassName | string | `"ingress-nginx"` | The ingress class that should be used |
| ingress.tls | list | `[]` | Optional TLS configuration to provide valid https connections using an existing SSL certificate |
| ingress.url | string | `""` | The url to use for the ingress reverse proxy to point at this pms instance |
| initContainer | object | `{"image":{"pullPolicy":"IfNotPresent","registry":"index.docker.io","repository":"alpine","sha":"","tag":"3.22"},"script":""}` | A basic image that will convert the configmap to a file in the rclone config volume this is ignored if rclone is not enabled |
| initContainer.image.registry | string | `"index.docker.io"` | The public dockerhub registry |
| initContainer.image.tag | string | `"3.22"` | If unset use latest |
| initContainer.script | string | `""` | A custom script that will be run in an init container to do any setup before the PMS service starts up This will be run every time the pod starts, make sure that some mechanism is included to prevent this from running more than once if it should only be run on the first startup. |
| nameOverride | string | `""` |  |
| nodeSelector | object | `{}` |  |
| pms.claimSecret.key | string | `""` |  |
| pms.claimSecret.name | string | `""` |  |
| pms.configExistingClaim | string | `""` | Name of an existing `PersistentVolumeClaim` for the PMS database NOTE: When set, 'configStorage' and 'storageClassName' are ignored. |
| pms.configStorage | string | `"2Gi"` | The volume size to provision for the PMS database |
| pms.gpu.nvidia.capabilities | string | `"compute,video,utility"` | Optional: NVIDIA driver capabilities. Available values are: `compute`, `compat32`, `graphics`, `utility`, `video`, `display`. See [NVIDIA docs](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/docker-specialized.html#driver-capabilities) |
| pms.gpu.nvidia.devices | string | `"all"` | Optional: NVIDIA GPU devices by index or UUID. Examples: "0,1", "GPU-uuid1,GPU-uuid2", or "all". See [NVIDIA docs](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/docker-specialized.html#gpu-enumeration) |
| pms.gpu.nvidia.enabled | bool | `false` |  |
| pms.livenessProbe | object | `{}` | Add kubernetes liveness probe to pms container. |
| pms.readinessProbe | object | `{}` | Add kubernetes readiness probe to pms container. |
| pms.resources | object | `{}` |  |
| pms.securityContext | object | `{}` | Security context for PMS pods |
| pms.shareProcessNamespace | bool | `false` | Enable process namespace sharing within the pod. |
| pms.storageClassName | string | `nil` | The storage class to use when provisioning the pms config volume this needs to be created manually, null will use the default |
| priorityClassName | string | `""` |  |
| rclone | object | `{"additionalArgs":[],"configSecret":"","enabled":false,"image":{"pullPolicy":"IfNotPresent","registry":"index.docker.io","repository":"rclone/rclone","sha":"","tag":"1.70.3"},"readOnly":true,"remotes":[],"resources":{}}` | The settings specific to rclone |
| rclone.additionalArgs | list | `[]` | Additional arguments to give to rclone when mounting the volume |
| rclone.configSecret | string | `""` | The name of the secret that contains the rclone configuration file. The rclone config key must be called `rclone.conf` in the secret  All keys in configSecret will be available in /etc/rclone/. This might be useful if other files are needed, such as a private key for sftp mode. |
| rclone.enabled | bool | `false` | If the rclone sidecar should be created |
| rclone.image | object | `{"pullPolicy":"IfNotPresent","registry":"index.docker.io","repository":"rclone/rclone","sha":"","tag":"1.70.3"}` | The rclone image that should be used |
| rclone.image.registry | string | `"index.docker.io"` | The public dockerhub registry |
| rclone.image.tag | string | `"1.70.3"` | If unset use latest |
| rclone.readOnly | bool | `true` | If the remote volumes should be mounted as read only |
| rclone.remotes | list | `[]` | The remote drive that should be mounted using rclone this must be in the form of `name:[/optional/path]` this remote will be mounted at `/data/name` in the PMS container |
| runtimeClassName | string | `""` | Specify your own runtime class name eg use gpu |
| service.annotations | object | `{}` | Optional extra annotations to add to the service resource |
| service.port | int | `32400` |  |
| service.type | string | `"ClusterIP"` |  |
| serviceAccount.annotations | object | `{}` | Annotations to add to the service account |
| serviceAccount.automountServiceAccountToken | bool | `false` | If the service account token should be auto mounted |
| serviceAccount.create | bool | `true` | Specifies whether a service account should be created |
| serviceAccount.name | string | `""` | The name of the service account to use. If not set and create is true, a name is generated using the fullname template |
| statefulSet.annotations | object | `{}` | Optional extra annotations to add to the service resource |
| statefulSet.podAnnotations | object | `{}` | Optional extra annotations to add to the pods in the statefulset |
| tolerations | list | `[]` |  |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.14.2](https://github.com/norwoodj/helm-docs/releases/v1.14.2)
