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

The following table lists the configurable parameters of the Plex-media-server chart and their default values.

| Parameter                | Description             | Default        |
| ------------------------ | ----------------------- | -------------- |
| `image.registry` |  | `"index.docker.io"` |
| `image.repository` |  | `"plexinc/pms-docker"` |
| `image.tag` |  | `"latest"` |
| `image.sha` |  | `""` |
| `image.pullPolicy` |  | `"IfNotPresent"` |
| `global.imageRegistry` |  | `""` |
| `ingress.enabled` |  | `false` |
| `ingress.ingressClassName` |  | `"ingress-nginx"` |
| `ingress.url` |  | `""` |
| `ingress.annotations` |  | `{}` |
| `pms.storageClassName` |  | `null` |
| `pms.configStorage` |  | `"2Gi"` |
| `pms.configExistingClaim` |  | `""` |
| `pms.gpu.nvidia.enabled` |  | `false` |
| `pms.resources` |  | `{}` |
| `pms.livenessProbe` |  | `{}` |
| `pms.readinessProbe` |  | `{}` |
| `initContainer.image.registry` |  | `"index.docker.io"` |
| `initContainer.image.repository` |  | `"alpine"` |
| `initContainer.image.tag` |  | `"3.18.0"` |
| `initContainer.image.sha` |  | `""` |
| `initContainer.image.pullPolicy` |  | `"IfNotPresent"` |
| `initContainer.script` |  | `""` |
| `runtimeClassName` |  | `""` |
| `rclone.enabled` |  | `false` |
| `rclone.image.registry` |  | `"index.docker.io"` |
| `rclone.image.repository` |  | `"rclone/rclone"` |
| `rclone.image.tag` |  | `"1.62.2"` |
| `rclone.image.sha` |  | `""` |
| `rclone.image.pullPolicy` |  | `"IfNotPresent"` |
| `rclone.configSecret` |  | `""` |
| `rclone.remotes` |  | `[]` |
| `rclone.readOnly` |  | `true` |
| `rclone.additionalArgs` |  | `[]` |
| `rclone.resources` |  | `{}` |
| `imagePullSecrets` |  | `[]` |
| `nameOverride` |  | `""` |
| `fullnameOverride` |  | `""` |
| `serviceAccount.create` |  | `true` |
| `serviceAccount.automountServiceAccountToken` |  | `false` |
| `serviceAccount.annotations` |  | `{}` |
| `serviceAccount.name` |  | `""` |
| `statefulSet.annotations` |  | `{}` |
| `statefulSet.podAnnotations` |  | `{}` |
| `service.type` |  | `"ClusterIP"` |
| `service.port` |  | `32400` |
| `service.annotations` |  | `{}` |
| `nodeSelector` |  | `{}` |
| `tolerations` |  | `[]` |
| `affinity` |  | `{}` |
| `priorityClassName` |  | `""` |
| `commonLabels` |  | `{}` |
| `extraEnv` |  | `{}` |
| `extraVolumeMounts` |  | `[]` |
| `extraVolumes` |  | `[]` |
| `extraContainers` |  | `[]` |

---
_Documentation generated by [Frigate](https://frigate.readthedocs.io)._
