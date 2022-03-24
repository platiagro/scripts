# PlatIAgro Scripts

This repo contains many scripts used by the PlatIAgro team.

## How to run a script

Navigate to `scripts/src`, choose a script, and run it with one of the following commands:

```shell
# Syntax: sh {SCRIPT_NAME}.sh
# Example:
sh enable_cors.sh
```

```shell
# Syntax: ./{SCRIPT_NAME}.sh
# Example:
./enable_cors.sh
```

> **WARNING:** Some scripts should be placed in a specific folder before executed.

## Available Scripts

All scripts are documented below.

### Enable or Disable CORS Errors

- **Script Name:** enable_cors.sh
- **Description:** Used to enable or disable CORS errors in all kubernetes deployments.
- **Read user input**: Yes

**Syntax:**

`enable_cors.sh $enable_cors`

**Params:**

| Name         | Type/Options |
| ------------ | ------------ |
| $enable_cors | 0 or 1       |

**Examples:**

Disable CORS errors

```shell
sh enable_cors.sh 1
```

Enable CORS errors

```shell
sh enable_cors.sh 0
```

---

### Update a Container Image

- **Name:** update_container.sh
- **Description:** Updates container image and tag of given pod.
- **Read user input**: Yes

**Syntax:**

`update_container.sh $pod $tag`

**Params:**

| Name | Type/Options |
| ---- | ------------ |
| $pod | String       |
| $tag | String       |

**Examples:**

It is possible to use another tag as long it exists on DockerHub.

```shell
sh update_container.sh web-ui DEVELOP
```

```shell
sh update_container.sh projects DEVELOP
```

---

### Reinstall the Platform

- **Name:** reinstall_reset.sh
- **Description:** Reinstalls the PlatIAgro platform resetting all configs and deleting existing data.
- **Read user input**: Yes

> **WARNING:** It clones the `platiagro/manifests`repository from GitHub in the current working directory. So it's recommended to copy this script to another folder before running.

**Syntax:**

`reinstall_reset.sh $installation_mode`

**Params:**

| Name               | Type/Options                                                 |
| ------------------ | ------------------------------------------------------------ |
| $installation_mode | platiagro, platiagro-auth, platiagro-gpu, platiagro-gpu-auth |

**Examples:**

Installation for **CPUs and WITHOUT login**

```shell
sh reinstall_reset.sh platiagro
```

Installation for **CPUs and WITH login**

```shell
sh reinstall_reset.sh platiagro-auth
```

Installation for **GPUs and WITHOUT login**

```shell
sh reinstall_reset.sh platiagro-gpu
```

Installation for **GPUs and WITH login**

```shell
sh reinstall_reset.sh platiagro-gpu-auth
```

---

### Minio Port Forward

- **Name:** minio_port_forward.sh
- **Description:** Forward the minio port.
- **Read user input**: No

**Examples:**

```shell
sh minio_port_forward.sh
```

---

### Mysql Port Forward

- **Name:** mysql_port_forward.sh
- **Description:** Forward the MySQL port.
- **Read user input**: No

**Examples:**

```shell
sh mysql_port_forward.sh
```

---

### Update Default Tasks

- **Name:** update_tasks.sh
- **Description:** Update the default tasks of the platform.
- **Read user input**: No

**Examples:**

```shell
sh update_tasks.sh
```

---

## Contribution

You can add, remove or modify scripts of this repository. All contributions are made by creating PRs to the `master` branch. Make sure to update the [Available Scripts](#available-scripts) on every PR to maintain the documentation up to date.
