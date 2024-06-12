# plex-media-server Chart
===========

A Helm chart for deploying the Plex Personal Media Server(PMS) server.

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

## Configuration

The following table lists the configurable parameters of the Pms-chart chart and their default values.

| Parameter                | Description             | Default        |
| ------------------------ | ----------------------- | -------------- |
| `image.registry` | The registry that should be used to pull the image from | `"index.docker.io"` |
| `image.repository` | The docker repo that will be used for the PMS image | `"plexinc/pms-docker"` |
| `image.tag` | The tag to use | `"latest"` |
| `image.sha` | Optional SHA digest to specify a specific image rather than a specific tag | `""` |
| `image.pullPolicy` |  | `"IfNotPresent"` |
| `global.imageRegistry` | The image registry that should be used for all images, this will take precedence over the per image registry.  | `""` |
| `ingress.enabled` | If an ingress for the PMS port should be created. | `false` |
| `ingress.ingressClassName` |  | `"ingress-nginx"` |
| `ingress.url` | The url that will be used for the ingress, this should be manually configured as the app URL in PMS. | `""` |
| `ingress.annotations` | Extra annotations to add to the ingress.  | `{}` |
| `pms.storageClassName` | The storage class that will be used for the PMS configuration directory, if not specified the default will be used | `null` |
| `pms.configStorage` | The amount of storage space that is allocated to the config volume, this will probably need to be much higher if thumbnails are enabled.  | `"2Gi"` |
| `pms.resources` |  | `{}` |
| `initContainer.image.registry` | The registry that should be used to pull the image from | `"index.docker.io"` |
| `initContainer.image.repository` | The docker repo that will be used for the init image to run the setup scripts| `"alpine"` |
| `initContainer.image.tag` | The tag to use | `"3.18.0"` |
| `initContainer.image.sha` | Optional SHA digest to specify a specific image rather than a specific tag | `""` |
| `initContainer.image.pullPolicy` |  | `"IfNotPresent"` |
| `initContainer.script` | An optional script that will be run by the init container, it can be used on the first run to stop pms from starting when importing a pre-exiting database | `""` |
| `runtimeClassName` | Specify your own runtime class name eg use gpu | `""` |
| `rclone.enabled` | If rclone should be used to mount volumes | `false` |
| `rclone.image.registry` | The registry that should be used to pull the image from | `"index.docker.io"` |
| `rclone.image.repository` | The docker repo that will be used for the rclone container | `"rclone/rclone"` |
| `rclone.image.tag` | The version of rclone to use | `"1.62.2"` |
| `rclone.image.sha` | Optional SHA digest to specify a specific image rather than a specific tag | `""` |
| `rclone.image.pullPolicy` |  | `"IfNotPresent"` |
| `rclone.configSecret` | The name of the Kubernetes secret that contains the rclone config to use. This secret is not created by this chart  | `""` |
| `rclone.remotes` | A list of remotes to mount using rclone. In the format of `"<remote-name>:<remote-path>"`, the remote-name must be in the rclone config file and its also used to determine the mount path within the PMS container | `[]` |
| `rclone.readOnly` | If the rclone volumes should be mounted as readonly | `true` |
| `rclone.additionalArgs` | Optional additional arguments given to the rclone mount command | `[]` |
| `rclone.resources` |  | `{}` |
| `imagePullSecrets` |  | `[]` |
| `nameOverride` |  | `""` |
| `fullnameOverride` |  | `""` |
| `serviceAccount.create` |  | `true` |
| `serviceAccount.automountServiceAccountToken` |  | `false` |
| `serviceAccount.annotations` |  | `{}` |
| `serviceAccount.name` |  | `""` |
| `statefulSet.annotations` |  | `{}` |
| `service.type` |  | `"ClusterIP"` |
| `service.port` | The port number that will be used for exposing the PMS port from the service | `32400` |
| `service.annotations` |  | `{}` |
| `nodeSelector` |  | `{}` |
| `tolerations` |  | `[]` |
| `affinity` |  | `{}` |
| `priorityClassName` |  | `""` |
| `commonLabels` | Labels that will be added to all resources created by the chart  | `{}` |
| `extraEnv` | Environment variables that will be added to the PMS container | `{}` |
| `extraVolumeMounts` | Additional volume mount configuration blocks for the pms container | `[]` |
| `extraVolumes` | Extra volume configurations | `[]` |
| `extraContainers` | Extra contain configuration blocks that will be run alongside the PMS container _after_ the init container finishes | `[]` |

---
_Documentation generated by [Frigate](https://frigate.readthedocs.io)._
