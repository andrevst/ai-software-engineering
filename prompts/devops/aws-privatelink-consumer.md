# AWS PrivateLink Consumer Setup

Generate the Terraform configuration for a product AWS account to connect to a shared platform's PrivateLink endpoint service.

## Ask the user for

- Product AWS account ID (use `000000000000` if not yet known)
- Platform AWS account ID (use `000000000000` if not yet known)
- Product account VPC ID (use `REPLACE` if not yet known)
- Product account private subnet IDs (use `[REPLACE, REPLACE, REPLACE]` if not yet known)
- Endpoint service name (provided by the platform team after the NLB exists — use `REPLACE` until then)
- AWS region (use `REPLACE` if not yet determined)
- Ports to allow: specify protocol and port (e.g., 4317 for OTLP gRPC, 4318 for OTLP HTTP, 443 for HTTPS)
- Whether private DNS is enabled on the endpoint service

## Output

1. `aws_vpc_endpoint` resource for the interface endpoint in the product account VPC.
2. `aws_security_group` resource allowing outbound only on the required ports to the endpoint ENI.
3. Private DNS note: if private DNS is enabled on the endpoint service, confirm the product VPC has `enableDnsHostnames` and `enableDnsSupport` set to `true`. If not, output an `aws_route53_record` stub for the private DNS name.
4. One output: the endpoint's private DNS name, for use in client configuration.

## Rules

- Use placeholder values throughout — no real account IDs or ARNs in committed Terraform.
- `vpc_endpoint_type = "Interface"`.
- Security group: outbound only on the specified ports, no inbound rules needed on the product side.
- Follow the placeholder convention: `000000000000` for account IDs, `REPLACE` for resource identifiers that need operator input.

## Validation

- Confirm `vpc_endpoint_type = "Interface"`.
- Confirm the security group allows egress only on the specified ports.
- Confirm no real ARNs or account IDs appear in the output.
- After applying: test connectivity with `nc -zv <endpoint-dns> <port>` or `grpcurl` for OTLP gRPC.
