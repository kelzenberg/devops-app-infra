# devops-app-infra

**_Infrastructure as Code for the life cycle of [devops-app](https://github.com/kelzenberg/devops-app)._**

For the concept of this infrastructure, see [Concept.md](./Concept.md).

## Prerequisites

**Clone this repository** and follow the steps below.  
Every command in here is being run from the repo-root path.

### Required Software

- **Hypervisor**: [VirtualBox v6.1.42](https://www.virtualbox.org/wiki/Download_Old_Builds_6_1)  
  <sub>(Note: Higher versions seem to be incompatible with Minikube v1.29.0 on MacOS 11.7.4)</sub>
  ```sh
  # `brew install --cask virtualbox` downloads the latest VB version.
  # `brew install --cask virtualbox@v6.1.42` is unavailable via brew.
  # Either run a previous version of the cask file or download v6.1.42 manually.
  ```
- **Kubernetes Command Line Tool**: [kubectl v1.25.4](https://kubernetes.io/docs/tasks/tools/)
  ```sh
  brew install kubectl
  ```
- **Local Kubernetes**: [Minikube v1.29.0](https://minikube.sigs.k8s.io/docs/start/)
  ```sh
  brew install minikube
  ```
- **Development Certificates**: [mkcert v1.4.4](https://github.com/FiloSottile/mkcert)
  ```sh
  brew install mkcert
  ```
- **YAML processor**: [yq v4.31.2](https://github.com/mikefarah/yq)
  ```sh
  brew install yq
  ```
- **(Optional) Kubernetes Terminal UI**: [k9s v0.27.3](https://k9scli.io/topics/install/)
  ```sh
  brew install k9s
  ```

### Secrets, Tokens & more

> Only required to do once!

- Add a Personal Access Token (classic) called `Minikube - ghcr.io Registry Access` in [GitHub settings](https://github.com/settings/tokens) with permissions to:  
  ☑️ `read:packages` _Download packages from GitHub Package Registry_
  - Store the token securely, we'll need it later
- Add a Personal Access Token (classic) called `GitHub Actions - Read private Repos` in [GitHub settings](https://github.com/settings/tokens) with permissions to:  
  ☑️ `Repo` _Full control of private repositories_
  - Store the token securely, we'll need it later
- Configure your Actions settings in your app repository (here [devops-app](https://github.com/kelzenberg/devops-app/settings/actions)) under **Settings/Actions/General** to:
  - **Actions permissions:** _Allow all actions and reusable workflows_
  - **Workflow permissions:** _Read and write permissions_
    - ☑️ _Allow GitHub Actions to create and approve pull requests_
- Add a **New repository secret** in your Action secrets in your app repository (here [devops-app](https://github.com/kelzenberg/devops-app/settings/secrets/actions)) under **Settings/Secrets and variables/Actions** with:
  - **Name:** `INFRA_REPO_TOKEN`
  - **Secrets:** Pass in the value of the `GitHub Actions - Read private Repos` **Token** from earlier

## GitHub Self-hosted Runner

The self-hosted runner is executing workflows locally wherever you install it.  
In this example, the workflows executing on the local runner are targeting the Minikube Kubernetes cluster on the same machine.

### Install the Runner

> Only required to do once!

1. Add a **New self-hosted runner** in your app repository (here [devops-app](https://github.com/kelzenberg/devops-app/settings/actions/runners)) under **Settings/Actions/Runners**
2. Choose `Runner image` and `Architecture`
3. Copy the release version from the URL in the `Download` section:
   ```sh
   https://github.com/actions/runner/releases/download/v2.302.1/actions-runner-osx-x64-2.302.1.tar.gz
   # v2.302.1
   ```
   - Remove the `v`
   - Write down the version (here `2.302.1`), we'll need it later
4. Copy the hash after the `echo` in the `Download` section:
   ```sh
   echo "cc061fc4ae62afcbfab1e18f1b2a7fc283295ca3459345f31a719d36480a8361  actions-runner-osx-x64-2.302.1.tar.gz" | shasum -a 256 -c
   # cc061fc4ae62afcbfab1e18f1b2a7fc283295ca3459345f31a719d36480a8361
   ```
   - Write down the hash, we'll need it later
5. Copy the token after the `--token` in the `Configure` section:
   ```sh
   ./config.sh --url https://github.com/kelzenberg/devops-app --token HELLOIAMASECRETTOKENFORRUNNERS
   # HELLOIAMASECRETTOKENFORRUNNERS
   ```
   - Store the token securely, we'll need it later
6. Run this make command with `Version`, `Hash` and `Token` from before to install the runner
   ```sh
   make runner-install RUNNER_VERSION=2.302.1  RUNNER_HASH=cc061fc4ae62afcbfab1e18f1b2a7fc283295ca3459345f31a719d36480a8361 RUNNER_TOKEN=HELLOIAMASECRETTOKENFORRUNNERS
   ```
7. It should download the required files and start the self-hosted runner configurator.

### Configure the Runner

> Only required to do once!

Follow the configurator like this:

```sh
$ Enter the name of the runner group to add this runner to: [press Enter for Default]
# Enter
$ Enter the name of runner: [press Enter for My-Computer]
DevOps-My-Computer
$ Enter any additional labels (ex. label-1,label-2): [press Enter to skip]
# Enter
$ Enter name of work folder: [press Enter for _work]
# Enter
```

Your GitHub self-hosted runner is now configured.  
Restart the procedure with `make runner-remove` and `make runner-install` if something went wrong.

### Starting the Runner & Listen for Jobs

**_In a separate terminal_** start the runner with `make runner-start`.  
Keep the terminal open as long as desired.

## Minikube

In this example, Minikube sets up a local Kubernetes cluster via the installed VirtualBox driver. Other drivers like `docker` are available. This repository focuses on the default `virtualbox` driver though.

### Initialization

> Only required to do once!

**Note:** It might be troublesome to run Container or VM Managers (e.g. Docker Desktop) in parallel to Minikube via VirtualBox. It is advised to shutdown those other managers when working with Minikube.

1. Init Minikube with:
   ```sh
   make init
   ```
2. During the injections of certificates,  
   input of `kube-system/mkcert` is needed, like so:

   ```sh
   $ minikube addons configure ingress
   -- Enter custom cert (format is "namespace/secret"): kube-system/mkcert
   # kube-system/mkcert

   # Optional, in case of a re-init:
   A custom cert for ingress has already been set. Do you want overwrite it? [y/n]: y
   # y
   ```

3. During the registration with Container Registries, there are a couple of questions which registries should be enabled.  
   **ONLY enable the Docker registry**, like so:

   ```sh
     Do you want to enable AWS Elastic Container Registry? [y/n]: n
     # n
     Do you want to enable Google Container Registry? [y/n]: n
     # n
     Do you want to enable Docker Registry? [y/n]: y
     # y
     -- Enter docker registry server url: ghcr.io
     # ghcr.io
     -- Enter docker registry username: kelzenberg
     # kelzenberg
     -- Enter docker registry password:
     # "Minikube - ghcr.io Registry Access" token value
     Do you want to enable Azure Container Registry? [y/n]: n
     # n
   ```

   For the _docker registry password_ pass in the value of the `Minikube - ghcr.io Registry Access` **Token** from earlier.

4. Minikube is now configured and running.  
   Confirm it with:

   ```sh
   $ minikube status && kubectl cluster-info
    minikube
    type: Control Plane
    host: Running
    kubelet: Running
    apiserver: Running
    kubeconfig: Configured

    Kubernetes control plane is running at https://192.168.59.105:8443
    CoreDNS is running at https://192.168.59.105:8443/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy
   ```

### Setting K8s cluster up

(Optional) If Minikube was not yet started...

```sh
make start
```

#### Monitoring & Tunneling

- **_In a separate terminal_** start the Minikube tunnel with `make tunnel` and enter the system user _password_ if asked. This allows the host system to access Kubernetes' services.

  Keep the terminal open as long as access to the cluster resources is needed (e.g. resolving FQDNs via browser or deploying via GitHub runner).

- **_In another separate terminal_** start the Minikube dashboard with `make dashboard` and wait until a website opens. On the top left, select a namespace to monitor.

  Keep the terminal open as long as desired.

- (Optional) If `K9s` is installed the cluster can be inspected via a Terminal-GUI with more interactive options than the Kubernetes dashboard.

#### Preparation for Continous Deployment

1. Before the runner CD-workflows can rollout new images to the local K8s cluster, we need to apply our config files once for both environments (`staging` and `production`) with:

   ```sh
   make staging
   ```

   and

   ```sh
   make production
   ```

   **Note:** Depending on the local internet speed Kubernetes will take some time to download and deploy all necessary images.

   If `ErrImagePull` or `ImagePullBackOff` errors appear within the pods, it could mean that the `Minikube - ghcr.io Registry Access` token was passed incorrectly in earlier or the GitHub Container Registry (ghcr.io) reached the allowed pull-limits for the registered account (step Initialization.3 ).

2. If the minikube tunnel is running, the deployed [devops-app](https://github.com/kelzenberg/devops-app) can be reached via its own FQDNs:

   - **Staging**: `https://dev.${minikube-ip}.nip.io`
   - **Production**: `https://app.${minikube-ip}.nip.io`

   Run `minikube ip` to get the cluster IP and insert it in the URLs above.  
   Example: [`https://dev.192.168.59.105.nip.io`](https://dev.192.168.59.105.nip.io)

#### Additional Makefile commands

If some Kubernetes resources need to be removed again, there are a few make targets available to do so:

- `clean-staging` removes all resources in `staging` namespace
- `clean-production` removes all resources in `production` namespace
- `clean-all` does both of the above AND removes the namespaces and certificates

The `make deploy-app-staging` and `make deploy-app-production` targets are only being used in the deploy-workflow which the GitHub self-hosted runner is executing.

### Deploying new images

If everything is set up, the GitHub workflows in the [devops-app repository](https://github.com/kelzenberg/devops-app/tree/master/.github/workflows) should be able to deploy to the local Kubernetes cluster.

#### Requirements for a successful deployment

- Internet connection on the local machine
- Minikube is running
- Minikube tunnel is running
- Kubernetes cluster is running
- GitHub self-hosted runner is running
