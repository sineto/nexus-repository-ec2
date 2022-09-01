# Nexus Repository

## Access Nexus dashboard

### 1. Dashboard

To access nexus dashboard, go to `http://<public-ip>:8081` and you be able to see the Nexus
homepage.

### 2. Get temporary password

In order to log in, use the default username `admin` and temporary password. And you can find the temporary password like:

```bash
## access nexus server remotely
ssh -i "~/.ssh/id_rsa.pub" ec2-user@<public-ip>

## get password
cat /opt/sonatype-work/nexus3/admin.password
```

# Docker registry

## 1. Define user and rule

- Create a new user: `Server Admin -> Users -> Create local user`
- Create a new rule: `Server Admin -> Roles -> Create Role`
  - Choose the rule `nx-reposiroty-view-docker-docker-hosted-*`
  - Attach the new rule to the user create before: `Server Admin -> Users -> Roles` and move the new
    user to `Granted`

## 2. Configure Docker registry endpoint

- Create a new Docker (hosted) repository: `Server Admin -> Repositories -> Create repository`
  - Configure **_Repository Connectors_**, check the `HTTP` options;
  - Set the `8083` port;
  - Configure **_Realms_**: `Server Admin -> Security -> Realms`
    - Active the option `Docker Bearer Token Realm`
- Configure your `insecure-repositories`. [See more](https://docs.docker.com/registry/insecure/).
