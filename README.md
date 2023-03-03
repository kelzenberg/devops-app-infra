# devops-app-infra

**_Infrastructure as Code for the life cycle of [devops-app](https://github.com/kelzenberg/devops-app)._**

For the concept of this infrastructure, see [Concept.md](./Concept.md).

## Prerequisites

**Clone this repository** and follow the steps below.

### Required Software

- **Hypervisor**: [VirtualBox v6.1.42](https://www.virtualbox.org/wiki/Download_Old_Builds_6_1)  
  <sub>(Note: Higher versions seem to be incompatible with Minikube v1.29.0 on MacOS 11.7.4)</sub>
  ```sh
  # `brew install --cask virtualbox` downloads the latest VB version.
  # `brew install --cask virtualbox@v6.1.42` is unavailable via brew.
  # Either run a previous version of the cask file or download v6.1.42 manually.
  ```
- **Kubernets Command Line Tool**: [kubectl v1.25.4](https://kubernetes.io/docs/tasks/tools/)
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

> Only required to do ONCE!

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

The self-hosted runners is executing workflows locally where you install it.  
In this example, the workflows executing on the local runner are targeting the Minikube Kubernetes cluster on the same machine.

### Install

> Only required to do ONCE!

1. Add a **New self-hosted runner** in your app repository (here [devops-app](https://github.com/kelzenberg/devops-app/settings/actions/runners)) under **Settings/Actions/Runners**
2. Choose `Runner image` and `Architecture`
3. Copy the release version from the URL in the `Download` section:
   ```sh
   https://github.com/actions/runner/releases/download/v2.302.1/actions-runner-osx-x64-2.302.1.tar.gz
   # v2.302.1
   ```
   - Remove the `v`
   - Write down the version (here `2.302.1`), we'll need it later
4. Copy the has after the `echo` in the `Download` section:
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
6. Run the Makefile with the runner **Version**, **Hash** and **Token** from before
   ```sh
   make runner-install RUNNER_VERSION=2.302.1  RUNNER_HASH=cc061fc4ae62afcbfab1e18f1b2a7fc283295ca3459345f31a719d36480a8361 RUNNER_TOKEN=HELLOIAMASECRETTOKENFORRUNNERS
   ```
7. It should download the required files and start the self-hosted runner configurator.

### Configure

> Only required to do ONCE!

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
