#!/bin/bash
set -x

DOCKER_ORG=${DOCKER_ORG:=ansible}
DOCKER_FILE=${DOCKER_FILE:=Dockerfile.ubuntu_12.04}
DOCKER_ROOT=test/docker
ROLE_DIR=`basename $PWD`
DOCKER_IMAGE=`echo $DOCKER_FILE | sed -e 's/^Dockerfile\.//'`
DOCKER_CONTAINER="role_test"

cp $DOCKER_ROOT/$DOCKER_FILE ./Dockerfile
printf '[defaults]\nroles_path = ../:test/roles' > ansible.cfg

docker build -t $DOCKER_ORG/$DOCKER_IMAGE:latest .

docker stop $DOCKER_CONTAINER || true
docker rm $DOCKER_CONTAINER || true

# Use command line args in docker run, if any specified.
if [ $# -eq 0 ]; then
    set -- ansible-playbook -i localhost, test/main.yml --connection=local --sudo
fi

docker run --privileged=true --name $DOCKER_CONTAINER -v $PWD:/$ROLE_DIR -t -i $DOCKER_ORG/$DOCKER_IMAGE:latest sh -c 'cd '"$ROLE_DIR"' && '"$*"
