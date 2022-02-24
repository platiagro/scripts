# PlatIAgro Scripts

This repo contains many scripts used by the PlatIAgro team.

## How to run a script

Navigate to `scripts/src`, choose a script, and run it with the following command:

```shell
# Syntax: sh {SCRIPT_NAME}.sh
# Example:
sh enable_cors.sh
```

## Available Scripts

Find a useful script in the table below:

| Script Name    | What it does                                   | How to run        |
| -------------- | ---------------------------------------------- | ----------------- |
| enable_cors.sh | Enable the CORS in all kubernetes deployments. | sh enable_cors.sh |
| reinstall.sh   | Reinstall the PlatIAgro platform from scratch. | sh reinstall.sh   |
| update_container.sh   | Updates container image and tag of given pod. | sh update_container.sh pod tag   |


## How to update container image using the script

```shell
# Syntax: sh {SCRIPT_NAME}.sh
# Example:
sh update_container.sh projects DEVELOP
# or
sh update_container.sh web-ui DEVELOP
# It is possible to use another tag as long it exists on dockerhub
sh update_container.sh projects 0.3.0-SNAPSHOT
```
## Contribution

You can add, remove or modify scripts of this repository. All contributions are made by creating PRs to the `master` branch. Make sure to update the [Available Scripts](#available-scripts) on every PR to maintain the documentation up to date.
