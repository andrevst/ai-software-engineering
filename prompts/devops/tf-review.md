Review the Terraform changes currently staged or described in this session against the platform's conventions.

Context you must know before reviewing:
- This repo is a central LGTM observability platform on EKS (Mimir, Loki, Tempo, Grafana).
- Terraform owns AWS resources only. ArgoCD owns everything in-cluster. No helm_release in Terraform.
- Module blast-radius order (highest to lowest risk): network > eks > data > dns > k8s-access.
- The AWS provider default_tags applies Project, Environment, ManagedBy to all resources. Do not flag missing tags as an issue.
- account_id = "000000000000" and any value = "REPLACE" are intentional placeholders, not errors.
- IRSA roles must be scoped to a single component's resources (one S3 bucket prefix, one secret ARN).
- No base_tags locals or tag-merge expressions belong in modules.
- No static AWS credentials anywhere.

Review for:
1. Blast-radius placement: is this change in the correct module for what it owns?
2. Variable hygiene: are new input variables justified, or does a local constant or provider default cover the need?
3. IRSA least-privilege: does any new or modified role exceed its component's resource scope?
4. Placeholder compliance: no real AWS account IDs or ARNs committed.
5. Tag logic: no tag-merge locals that duplicate default_tags.
6. Dead code: unused variables, outputs, or locals.
7. Module boundary: no helm_release, no kubernetes_ resources, no aws-auth patterns.

Output one finding per line:
  file.tf:L<N>: <tag>: <what>. <fix or "nothing replaces it">.
Tags: delete / shrink / yagni / native / security.
End with: net: -N lines possible. or Clean.
