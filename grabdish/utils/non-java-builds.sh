#!/bin/bash
# Copyright (c) 2021 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

# Fail on error
set -e

BUILDS="inventory-python inventory-nodejs inventory-dotnet inventory-go inventory-helidon-se order-mongodb-kafka inventory-postgres-kafka inventory-springboot"
# we provision a repos for db-log-exporter but don't build it yet/currently
REPOS="inventory-python inventory-nodejs inventory-dotnet inventory-go inventory-helidon-se order-mongodb-kafka inventory-postgres-kafka inventory-springboot db-log-exporter"

# Provision Repos
while ! state_done NON_JAVA_REPOS; do
  for b in REPOS; do
    oci artifacts container repository create --compartment-id "$(state_get COMPARTMENT_OCID)" --display-name "$(state_get RUN_NAME)/$b" --is-public true
  done
  state_set_done NON_JAVA_REPOS
done


# Wait for docker login
while ! state_done DOCKER_REGISTRY; do
  echo "Waiting for Docker Registry"
  sleep 5
done


# Wait for java builds
while ! state_done JAVA_BUILDS; do
  echo "Waiting for Java Builds"
  sleep 10
done


# Build  the images
while ! state_done NON_JAVA_BUILDS; do
  for b in $BUILDS; do
    cd $GRABDISH_HOME/$b
    time ./build.sh &>> $GRABDISH_LOG/build-$b.log &
  done
  wait
  state_set_done NON_JAVA_BUILDS
done
