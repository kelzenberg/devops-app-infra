# devops-app-infra

**_Infrastructure as Code for the life cycle of [devops-app](https://github.com/kelzenberg/devops-app)._**

For the concept of this infrastructure, see [Concept.md](./Concept.md).

## Requirements

- **Hypervisor**: [VirtualBox v6.1.38](https://www.virtualbox.org/wiki/Download_Old_Builds_6_1)  
  <sub>(higher versions seem to be incompatible with minikube on MacOS 11.7.2)</sub>
  ```sh
  brew install --cask virtualbox@6.1.38
  ```
- **Kubernets Command Line Tool**: kubectl
  ```sh
  brew install kubectl
  ```
- **Local Kubernets**: Minikube
  ```sh
  brew install minikube
  ```
  <!-- - **Kubernetes Package Manager**: Helm
    ```sh
    brew install helm
    ```
- **Declarative helm charts**: Helmfile
  ````sh
  brew install helmfile
  ``` -->
  ````
