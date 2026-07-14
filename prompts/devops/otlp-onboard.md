Generate a source account onboarding guide for a product team connecting to this platform's OTLP ingest endpoint.

Ask the user for:
- Source runtime: ECS Fargate, ECS on EC2, bare EC2, or other EKS cluster
- Signals to send: metrics, logs, traces (any combination)
- Existing log setup: Elasticsearch, CloudWatch, or none
- Team name or service namespace (used as the tenant identifier)

Then generate a concise, step-by-step guide with the following sections:

1. Prerequisites
   - PrivateLink interface endpoint creation in the source account VPC (provide the Terraform stub with placeholder endpoint service name REPLACE).
   - Security group rule: outbound TCP 4317 (OTLP gRPC) and 4318 (OTLP HTTP) to the endpoint ENI.

2. IAM policy for the source task/instance role
   - Least-privilege. Only the permissions needed for sigv4 signing to the NLB endpoint.
   - No S3 permissions, no secrets access (those belong to the platform account).

3. ADOT collector configuration
   - ECS: task definition JSON snippet for the ADOT sidecar.
   - EC2: systemd unit snippet for the ADOT daemon.
   - Other EKS: DaemonSet manifest snippet.
   - Required resource attributes: service.name, service.namespace (set to the team's namespace), deployment.environment, plus trace_id via SDK propagation if tracing.
   - Exporter endpoint: the PrivateLink private DNS name (REPLACE until provisioned).

4. OTel SDK setup (language-agnostic)
   - How to set the required resource attributes at SDK initialization.
   - How to configure the OTLP exporter endpoint.

5. Validation
   - How to confirm telemetry arrives and is routed to the correct tenant (query the OTel gateway logs; check Grafana with the team's tenant filter).

Platform context for accuracy:
- The OTel gateway inside the cluster derives X-Scope-OrgID from service.namespace + deployment.environment. Apps cannot self-assign a tenant.
- Auth is IAM sigv4 via the ADOT collector's awssigv4 extension. No static credentials.
- The PrivateLink endpoint service is in the platform account (not yet in Terraform; the NLB ARN is needed first).

Follow writting-style.md: active voice, no em dashes, no buzzwords, US English. Placeholders use REPLACE or 000000000000.
