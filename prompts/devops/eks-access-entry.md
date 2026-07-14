Generate the Terraform change for a human cluster access modification in terraform/modules/k8s-access/.

Ask the user for:
- Action: ADD, MODIFY, or REMOVE
- Person's name or identifier (for the resource label)
- Their IAM Identity Center role ARN (format: arn:aws:iam::000000000000:role/AWSReservedSSO_<PermissionSet>_<id>). Use REPLACE if not yet known.
- Access tier: admin, engineer, or viewer
- Which environment(s): nonproduction, production, or both

Then generate the HCL diff only. No prose explanation around it.

Rules:
- The cluster uses EKS Access Entries in API mode (aws_eks_access_entry + aws_eks_access_policy_association). No aws-auth ConfigMap.
- admin tier: AmazonEKSClusterAdminPolicy
- engineer tier: AmazonEKSEditPolicy (add kubernetes_groups if namespace-scoped access is needed)
- viewer tier: AmazonEKSViewPolicy
- Keep the principal ARN as REPLACE if the real ARN was not provided.
- Match the resource naming pattern already in terraform/modules/k8s-access/main.tf.
- One aws_eks_access_entry and one aws_eks_access_policy_association per principal per environment.
- For REMOVE: output a commented-out block showing what to delete, not an empty file.

After the diff, output the validation command:
  terraform -chdir=terraform/environments/<env> plan -target=module.k8s_access

And note: this change goes through an Atlantis PR, not a direct apply.
