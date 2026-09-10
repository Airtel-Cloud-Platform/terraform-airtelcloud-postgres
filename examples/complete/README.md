# Complete PostgreSQL Example

This example provisions a highly available PostgreSQL cluster using most module features.

## What This Example Shows

- High availability with a standby replica
- Backup schedule and protection plan
- Extensions and labels
- Resource timeouts

## Files

- `main.tf`: complete provider and module configuration
- `variables.tf`: provider credentials and cluster password

## How To Run

1. Go to this folder:

```bash
cd examples/complete
```

2. Initialize Terraform:

```bash
terraform init
```

3. Set required provider variables (API key/secret, organization, project, password).

4. Plan:

```bash
terraform plan
```

5. Apply:

```bash
terraform apply
```

6. Destroy when done:

```bash
terraform destroy
```

## Notes

- `protection_plan` should match a value from the protection-plans catalog.
- Adjust flavor, zone, CIDRs, and version to match your environment.
- Configuration changes force a new cluster.
