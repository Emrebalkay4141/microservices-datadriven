#!/bin/bash
## Copyright (c) 2021 Oracle and/or its affiliates.
## Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl/


SCRIPT_DIR=$(dirname $0)

export DOCKER_REGISTRY="$(state_get DOCKER_REGISTRY)"
export ORDER_PDB_NAME="$(state_get ORDER_DB_NAME)"
export OCI_REGION="$(state_get OCI_REGION)"
export VAULT_SECRET_OCID=""

echo create supplier-helidon-se OAM Component and ApplicationConfiguration
export CURRENTTIME=$( date '+%F_%H:%M:%S' )
echo CURRENTTIME is $CURRENTTIME  ...this will be appended to generated deployment yaml

cp supplier-helidon-se-comp.yaml supplier-helidon-se-comp-$CURRENTTIME.yaml

#may hit sed incompat issue with mac
sed -i "s|%DOCKER_REGISTRY%|${DOCKER_REGISTRY}|g" supplier-helidon-se-comp-$CURRENTTIME.yaml
sed -i "s|%ORDER_PDB_NAME%|${ORDER_PDB_NAME}|g" supplier-helidon-se-comp-${CURRENTTIME}.yaml
sed -i "s|%OCI_REGION%|${OCI_REGION}|g" supplier-helidon-se-comp-${CURRENTTIME}.yaml
sed -i "s|%VAULT_SECRET_OCID%|${VAULT_SECRET_OCID}|g" supplier-helidon-se-comp-${CURRENTTIME}.yaml

if [ -z "$1" ]; then
    kubectl apply -f $SCRIPT_DIR/supplier-helidon-se-comp-$CURRENTTIME.yaml
    kubectl apply -f $SCRIPT_DIR/supplier-helidon-se-app.yaml
else
    kubectl apply -f <(istioctl kube-inject -f $SCRIPT_DIR/supplier-helidon-se-comp-$CURRENTTIME.yaml) -n msdataworkshop
fi

