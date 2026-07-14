Generate the files needed to onboard a new component or add-on to this platform via ArgoCD.

Ask the user for any details not already provided:
- Component name (will become the ArgoCD Application name and filename)
- Helm chart repo URL
- Chart name and target version (verify it exists in the public chart repo)
- Target Kubernetes namespace
- Environment: nonproduction or production (default: nonproduction)
- Does it need AWS access? If yes, what does it read or write (S3 bucket, Secrets Manager path, Route53 zone)?
- Does it need secrets from Secrets Manager? If yes, what are the secret paths?

Then generate:

1. gitops/apps/<env>/<name>.yaml
   - destination.name must be the registered cluster name (obs-nonprod or obs-prod). Never server: https://kubernetes.default.svc.
   - syncPolicy.automated: prune: true, selfHeal: true.
   - syncOptions: [CreateNamespace=true, ServerSideApply=true].
   - Use source.chart + source.repoURL + source.targetRevision (not a Git path unless it is a raw manifest app).
   - Add helm.releaseName.
   - Only add valuesObject or valuesFrom if there are values that differ from the chart's documented defaults.

2. gitops/values/<env>/<name>.yaml (only if there are non-default values)
   - One key per overridden value. No chart-default values.

3. Terraform IRSA stub (only if AWS access is needed)
   - Add to terraform/modules/eks/irsa-addons.tf.
   - One role, scoped to the specific resource (one bucket ARN or one secret ARN).
   - Include the IAM policy document inline.

4. ExternalSecret manifest (only if Secrets Manager paths are needed)
   - Place at gitops/manifests/<env>/<name>-secrets.yaml or as a valuesFrom in the Application.
   - Reference the correct ClusterSecretStore (already configured on the cluster).

Reference gitops/apps/nonproduction/karpenter.yaml as the format model for the Application manifest.
Reference gitops/apps/nonproduction/external-secrets.yaml for the ExternalSecret pattern.

After generating, list the REPLACE placeholders the operator must fill in before applying.
