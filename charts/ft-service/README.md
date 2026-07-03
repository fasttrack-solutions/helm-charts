# ft-service

Generic FastTrack service Helm library. Owns the shared Kubernetes workload skeleton — Deployment, Service, HTTPRoute, KEDA ScaledObject, ServiceAccount/IRSA, CronJob, NetworkPolicy — so each microservice only needs a thin `values.yaml` of overrides and one-line template stubs.

## Consuming this chart

Each microservice keeps its own `deployments/helm/<svc>/` application chart in its own repo. That chart declares `ft-service` as a dependency and the service CI publishes it independently.

**`Chart.yaml`** in the consuming service repo:

```yaml
apiVersion: v2
name: my-service
type: application
version: 1.0.0
dependencies:
  - name: ft-service
    version: "1.x"
    repository: "https://fasttrack-solutions.github.io/helm-charts"
```

**`templates/deployment.yaml`** (and all other skeleton templates):

```
{{ include "ft-service.deployment" . }}
```

**`values.yaml`** — only what differs from defaults:

```yaml
deployment:
  image:
    repository: 745106446559.dkr.ecr.eu-west-1.amazonaws.com/my-service
  resources:
    requests:
      cpu: "50m"
      memory: "128Mi"

service:
  ports:
    - { name: http, port: 80, targetPort: 3000 }

serviceAccount:
  create: true
  roleArn: ""   # Terraform-provisioned IAM role ARN
```

The only hard requirement is `deployment.image.repository`. Everything else has an inline default.

## Available templates

| Include | Renders |
|---|---|
| `ft-service.deployment` | `apps/v1 Deployment` |
| `ft-service.service` | `v1 Service` (multi-port, Ambassador passthrough) |
| `ft-service.serviceaccount` | `v1 ServiceAccount` with optional IRSA annotation |
| `ft-service.httproute` | `gateway.networking.k8s.io/v1 HTTPRoute` (double-gated) |
| `ft-service.scaledobject` | `keda.sh/v1alpha1 ScaledObject` |
| `ft-service.configmap` | `v1 ConfigMap` (flat literal data) |
| `ft-service.secret` | `v1 Secret` (Vault `<path:…>` passthrough) |
| `ft-service.cronjob` | `batch/v1 CronJob` |
| `ft-service.networkpolicy` | `networking.k8s.io/v1 NetworkPolicy` (egress allowlist) |
| `ft-service.extraManifests` | Arbitrary objects (escape hatch) |

## Verify locally

```bash
helm repo add fasttrack https://fasttrack-solutions.github.io/helm-charts
helm dependency build deployments/helm/<svc>
helm template <svc> deployments/helm/<svc>
```
