# FinOps Cost Attribution Review

Analyze the cost structure of a cloud platform and produce a FinOps summary.

## Ask the user for

- Platform type and cloud provider (e.g., LGTM on EKS, Next.js on Vercel + AWS RDS)
- Primary cost drivers to investigate (e.g., S3 buckets, EC2 node pools, RDS, NAT gateway, CDN)
- FinOps or cost tagging documentation path (e.g., `docs/FINOPS.md`)
- Whether per-tenant cost attribution is required

## Investigation steps

For each cost driver, determine:
1. Which Terraform resource or managed service configuration controls it.
2. The configuration knob available to reduce cost (retention policy, Spot vs On-Demand, instance size, caching, S3 lifecycle tier).
3. Whether per-tenant attribution is possible (tagging strategy, chargeback model).

## Standard areas to check for AWS platforms

- **S3**: bucket lifecycle policies (standard vs. IA vs. Glacier); verify S3 gateway endpoint is in place so S3 traffic does not route through NAT.
- **EC2 / node groups**: On-Demand vs. Spot split; Karpenter or Cluster Autoscaler consolidation policy; node pool sizing.
- **NAT gateway**: high cost if S3 or ECR traffic routes through NAT — confirm gateway endpoints cover them.
- **RDS / Aurora**: ACU min/max for Aurora Serverless; backup retention; Multi-AZ necessity.
- **Data transfer**: cross-AZ vs. same-AZ service communication; CDN cache hit rate.

## Output format

- Bullet list of top cost drivers ordered by estimated monthly impact.
- For each driver: the Terraform resource or config file that controls it, and the available reduction knob.
- Flag any missing cost controls (no per-tenant retention override, no compaction configured, no S3 lifecycle rule).
- One-line summary: estimated reduction range if all flagged items are addressed.

## Rules

- Cite specific file paths and resource names from the codebase.
- Do not recommend changes outside the repo's documented scope.
- Flag cost items as estimates unless exact billing data is available.
