# Project Tracker

Work in progress tasks & To-Do's

- [x] setup repositories ([app](https://github.com/kelzenberg/devops-app) & [infra](https://github.com/kelzenberg/devops-app-infra))
- [x] setup Minikube & components
- [ ] _**WIP**_ create Makefile to bootstrap local k8s
- [ ] _**WIP**_ configure Minikube's k8s via config files
- [ ] use `minikube ip` IPs dynamically in k8s config files
- [ ] _**WIP**_ use ghcr.io as image registry within minikube
- [ ]
- [ ]
- [ ] Environments:
  - [ ] Staging
  - [ ] Production
    - [x] manual review/release required for `production` env release
- [x] CI is only triggered through a change in the VCS
- [x] create min. 3 Github actions in CI/CD workflow
  - [x] build (Node)
  - [x] test (Node)
  - [x] build-and-push (Docker & GHCR)
- [x] fix Github workflow tokens
- [x] at least one service (e.g. VCS, Monitoring) other than the app has to be provisioned by yourself  
       --> Database
- [ ] create new Github token for local agent
- [ ] register Github local agent
- [ ] inject `API_KEY_*` into deployment
- [ ]
- [ ] relevant services (VCS, CI/CD, App, Monitoring) accessible via FQDN
- [ ] exposed services served via HTTPS
- [ ] application must run 100% redundant (replica: 2+)
- [ ] zero-downtime deployment strategy
- [ ]
- [ ]
- [ ] cleanup READMEs
