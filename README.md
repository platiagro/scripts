# PlatIAgro Scripts

This repo contains many scripts used by the PlatIAgro team.

## How to run a script

Navigate to `scripts/src`, choose a script, and run it with the following command:

```shell
# Syntax: sh {SCRIPT_NAME}.sh
# Example:
sh enable_cors.sh
```

> **Warning:** Some scripts can create folders or need to be located in a specific folder.

## Available Scripts

All scripts are documented below.

### enable_cors.sh

- **Name:** enable_cors.sh
- **Description:** Enables CORS in all kubernetes deployments.

Examples:

```shell
sh enable_cors.sh
```

### update_container.sh

- **Name:** update_container.sh
- **Description:** Updates container image and tag of given pod.
- **Params**: `pod` `tag`

Examples:

```shell
# It is possible to use another tag as long it exists on DockerHub
sh update_container.sh web-ui DEVELOP
sh update_container.sh projects DEVELOP
```

### reinstall_reset.sh

- **Name:** reinstall_reset.sh
- **Description:** Reinstalls the PlatIAgro platform resetting all configs and deleting existing data.
- **Params**: `installation_mode` (platiagro, platiagro-auth, platiagro-gpu, platiagro-gpu-auth)
- **Warning**: It clones the `platiagro/manifests` repository from GitHub with git in the current working directory.

```shell
# It's recommended to copy the script to another folder before running it
cp reinstall_reset.sh ../..
```

Examples:

```shell
# Installation for CPUs and WITHOUT login
sh reinstall_reset.sh platiagro
```

```shell
# Installation for CPUs and WITH login
sh reinstall_reset.sh platiagro-auth
```

```shell
# Installation for GPUs and WITHOUT login
sh reinstall_reset.sh platiagro-gpu
```

```shell
# Installation for GPUs and WITH login
sh reinstall_reset.sh platiagro-gpu-auth
```

### reinstall_soft.sh

- **Name:** reinstall_soft.sh
- **Description:** Pulls several images from the platiagro DockerHub and updates all corresponding kubernetes pods.

Examples:

```shell
sh reinstall_soft.sh
```

## Contribution

You can add, remove or modify scripts of this repository. All contributions are made by creating PRs to the `master` branch. Make sure to update the [Available Scripts](#available-scripts) on every PR to maintain the documentation up to date.
