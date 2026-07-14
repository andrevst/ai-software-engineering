# Helm Chart Component Upgrade

Upgrade the Helm chart version for a component on a GitOps-managed platform.

## Ask the user for

- Component name (e.g., mimir, loki, tempo, grafana, karpenter, external-secrets)
- Current `targetRevision` (found in the ArgoCD Application manifest)
- Target version to upgrade to
- GitOps Application manifest path (e.g., `gitops/apps/nonproduction/<name>.yaml`)
- Helm values override file path if it exists (e.g., `gitops/values/nonproduction/<name>.yaml`)

## Steps

1. Read the component's changelog between the current and target versions.
   - Focus on: breaking changes in values schema (renamed keys, removed options, new required fields), CRD additions or removals, deprecated fields removed.

2. Update `targetRevision` in the Application manifest.

3. Update the values override file if any values changed in the new version.
   - Only change values that are affected by the version bump.
   - Do not touch values unrelated to the upgrade.

4. Flag any CRD changes.
   - Mimir and Tempo occasionally add or rename CRDs between minor versions.
   - CRD updates must be applied manually before ArgoCD syncs the chart — ArgoCD does not manage CRDs by default.

## Output

- The updated Application manifest diff.
- The updated values override diff (if any values changed).
- A bullet list of breaking changes from the changelog that require operator action before or after the upgrade.
- A note if CRDs must be applied manually, with the `kubectl apply` command.
- A note on whether a rollback strategy is available (Helm history, ArgoCD rollback).

## Validation before merging

- Confirm the new `targetRevision` exists in the chart repository's published releases.
- Confirm any CRD changes are documented in the output.
- Run `helm template` dry-run locally if chart access is available.
- Confirm no values were changed that are not affected by the version bump.

## Platform context (fill in for your platform)

- GitOps tool: ArgoCD / Flux / other
- Target cluster name (ArgoCD `destination.name`): REPLACE
- Namespace: REPLACE
- Chart repository URL: REPLACE
