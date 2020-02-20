# Patches

The patches are organized into 2 groups:

1. `components/` - component source patches.
2. `images/` - for the Dockerfiles.
3. `deployment/` - for the docker-compose/kubernetes deployment files.

## Components

One set of patches deal with setting ulimits. In my own attempt, the ulimit command succeeded only in the order soft-hard. This may be non-essential skipped.

Another set of patches (`crest`, `cassandra`) setup the right version of Cassandra to use. This is beacause the originally used versions were too old, not available anymore.

The patch for `infra` changes a sub-dependency version for a dependency to compile correctly. For `memcached`, the tests have been disabled in the compilation process as they failed for whatever reason.

The patch for `astaire` includes a hard dependency which for some reason is only marked as "recommends". Without this extra package, [this](https://github.com/Metaswitch/clearwater-docker/issues/80) issue occurs.

## Images

Primary change here is to disable certain Ubuntu 14.04 upgrades dues to non-availability and adding the packages and installing them locally instead of pulling them from a remote.

## Deployment

From version `1.17` of the kubernetes API, several CRDs have moved from extension/beta to the main api family.
