# devops-app-infra

**_Infrastructure as Code for the life cycle of [devops-app](https://github.com/kelzenberg/devops-app)._**

For the concept of this infrastructure, see [Concept.md](./Concept.md).

## Requirements

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
