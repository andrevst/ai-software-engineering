# DevOps Prompts

Self-contained agent prompt templates for Platform Engineering, SRE, and DevOps tasks.

Each prompt is a brief — copy it into Claude Code, fill in the bracketed `[PLACEHOLDER]` or `REPLACE` values for your platform, and run.

## Prompts

| File | When to use | Recommended model |
|------|------------|-------------------|
| [tf-review.md](./tf-review.md) | Before every Terraform change (Atlantis PR) | `claude-sonnet-4-6` |
| [argocd-app-onboard.md](./argocd-app-onboard.md) | Adding a new component to a GitOps-managed cluster | `claude-sonnet-4-6` |
| [adr-write.md](./adr-write.md) | Recording a new infrastructure or architecture decision | `claude-opus-4-8` |
| [eks-access-entry.md](./eks-access-entry.md) | Adding, modifying, or removing human cluster access | `claude-haiku-4-5` |
| [otlp-onboard.md](./otlp-onboard.md) | Onboarding a new team to a central observability platform | `claude-opus-4-8` |
| [helm-chart-upgrade.md](./helm-chart-upgrade.md) | Bumping a Helm chart version on a GitOps platform | `claude-sonnet-4-6` |
| [aws-privatelink-consumer.md](./aws-privatelink-consumer.md) | Connecting a product account to a PrivateLink endpoint | `claude-sonnet-4-6` |
| [finops-cost-review.md](./finops-cost-review.md) | Monthly FinOps review, per-tenant cost attribution | `claude-sonnet-4-6` |

## How to adapt a prompt to your platform

Every prompt has a "platform context" section at the bottom (or a list of questions to ask). Replace those placeholders before running:

1. Fill in your cluster names, account IDs, and repo paths.
2. Add a one-paragraph platform description at the top if the agent needs context the codebase doesn't provide.
3. Copy the adapted prompt into `.claude/commands/<name>.md` in your project repo to make it a `/project:<name>` slash command.

## Blast-radius guidance

| Prompt | Risk level | Always confirm before? |
|--------|-----------|----------------------|
| tf-review | Read-only review | No |
| argocd-app-onboard | Medium (new workload) | Yes — confirm namespace and IRSA scope |
| adr-write | Documentation only | No |
| eks-access-entry | Medium (cluster access) | Yes — confirm tier and environment |
| otlp-onboard | Low (new data source) | No |
| helm-chart-upgrade | Medium (in-cluster change) | Yes — confirm CRD status |
| aws-privatelink-consumer | Low (Terraform stub only) | No |
| finops-cost-review | Read-only analysis | No |
