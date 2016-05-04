## Ubuntu1204 ominbus base image

https://hub.docker.com/r/onazar/ubuntu1204-omnibus-base-builder/

## Usage

First, create empty `Dockerfile` for your omnibus-project.

for `*.deb`, `Dockerfile.ubuntu1204`.

```
FROM onazar/ubuntu1204-omnibus-base-builder
MAINTAINER you
```

## Build once to execute ONBUILD

```
## DEB
$ docker build -t omnibus_project-ubuntu1204 -f Dockerfile.ubuntu1204 .
```

## Run to create package!

Run with passing your project name via env `OMNIBUS_PROJECT`.

```
## DEB
$ docker run -e OMNIBUS_PROJECT=${PROJECT_NAME} -v pkg:/home/omnibus/omnibus-project/pkg omnibus_project-ubuntu1204
```

Packages will be created in `./pkg/` directory.
!!! You must have already created pkg dir in your omnibus-project root at localhost.

