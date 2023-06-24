# run this file using "docker buildx bake"

variable "TAG" {
    # This should be overridden on command line to be the
    # specific plex media server binary to download into the image
    default = "1.32.4.7195-7c8f9d3b6"
}
variable "IMAGE" {
    default = "plexinc/pms-docker"
}

group "default" {
    targets = ["plexmediaserver-versioned", "plexmediaserver-autoupdate"]
}

target "plexmediaserver-versioned" {
    # This target builds targets that downloald and pre-install the
    # the plex media server binary in the container. This image
    # has two tags, the version itself, and assuming this is that latest
    # also tags it with :latest.
    output = ["type=registry"]
    context = ".."
    platforms = ["linux/386", "linux/amd64", "linux/arm64", "linux/arm/v7"]
    tags = ["${IMAGE}:${TAG}", "${IMAGE}:latest"]
    args = {
        TAG = "${TAG}"
    }
}
target "plexmediaserver-autoupdate" {
    # This target build a download and pre-install a configuration of the
    # container automatically downloads and installs the server at runtime
    # and automatically checks for updates once a day.
    output = ["type=registry"]
    context = ".."
    platforms = ["linux/386", "linux/amd64", "linux/arm64", "linux/arm/v7"]
    tags = ["${IMAGE}:autoupdate"]
    args = {
        TAG = "autoupdate"
    }
}
