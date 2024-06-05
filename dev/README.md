# Dev Helper Scripts

Hey homelab enthusiast!

Unless you are enhancing these Dockerfile themselves, please ignore all the files here. In fact, your environment may be very different and these scripts may not work at all. These are just provided only as a reference/starting point so you don't have to start from scratch.

You might just consider extending the images here. i.e.

```
FROM plexinc/pms-docker:latest

RUN echo "Add your modifications here"
```

Otherwise, `dev.sh` will build all of the multi-platform docker images, for each platform it will build one that uses a specific version, and `autoupdate` version that doesn't bake the binary into the image, but rather downloads when container boots. Look inside the script for more info.

`docker-bake.hcl` is a buildx bake file that will build all platforms, using pre-installed binaries and `update` versions. This bake file will push to dockerhub. You can override the destination using the `dockerhub_image` variable in `dev.sh`.


### Examples

#### Prereqs:
- [docker](https://docs.docker.com/engine/install/)
- [buildx](https://github.com/docker/buildx)
- x86 based linux host

```sh
# sets up buildx for multi-arch builds
./dev.sh setup

# bake - build all and push to dockerhub
./dev.sh bake

# build  version-specific and autoupdate image for amd64
./dev.sh build amd64

# build everything
./dev.sh buildall

# launches version-specific container
./dev.sh debug amd64

# launches auto-update container
./dev.sh debug amd64 autoupdate
```
