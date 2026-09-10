# Security Design — Fleet Management System

## 1. IAM Roles (No Access Keys in Code)
- EC2 instances use an IAM Instance Profile (`tobeynd-ec2-role`)
- No AWS access keys are stored in code or on instances
- Permissions granted via attached IAM policies only

## 2. Least Privilege Principle
- EC2 role has only `AmazonSSMManagedInstanceCore` (for SSM) 
  plus a custom policy allowing read-only access to `/fleet-app/*` 
  parameters ONLY — not all of Parameter Store
- KMS decrypt permission scoped to secret retrieval

## 3. Restricted SSH Access
- No port 22 (SSH) ingress rule on any security group
- All administrative access via AWS Systems Manager Session Manager
- SSM access is IAM-authenticated and logged in CloudTrail

## 4. Network Segmentation
- EC2 instances and RDS are in PRIVATE subnets (no public IPs)
- Only the ALB is public-facing
- Security group chain: Internet → ALB (443/80) → EC2 (3002) → RDS (5432)
- Each tier only accepts traffic from the tier above it

## 5. Encryption
- RDS storage encrypted at rest (storage_encrypted = true)
- Parameter Store secrets stored as SecureString (KMS-encrypted)
- RDS connections use SSL

## 6. Secrets Management
- Database credentials stored in AWS Systems Manager Parameter Store
- No hardcoded secrets in Terraform state (marked sensitive) or code
- terraform.tfvars excluded from version control via .gitignore

## 7. Terraform State Security
**Known Risk:** `terraform.tfstate` stores the RDS password in plaintext locally.
**Recommended Fix:** Migrate to an S3 backend with SSE encryption and DynamoDB state locking:
```hcl
terraform {
  backend "s3" {
    bucket         = "your-tfstate-bucket"
    key            = "fleet-app/dev/terraform.tfstate"
    region         = "af-south-1"
    encrypt        = true
    dynamodb_table = "terraform-lock"
  }
}
```

## 8. CloudWatch Logs
- Application logs streamed to `/tobeynd/fleet-app` log group via the `awslogs` Docker log driver
- Retention set to 7 days
- Logs capture application stdout/stderr and are used for incident detection and debugging

## 9. ALB Access Logs
**Current State:** ALB access logs are disabled.
**Recommended for Production:** Enable access logs to an S3 bucket to capture all incoming requests for audit and forensic purposes.

## 10. HTTPS / TLS
**Known Limitation:** The ALB listener currently operates on HTTP (port 80) only — no TLS termination.
**Recommended Fix:** Request a certificate via AWS Certificate Manager (ACM) and add an HTTPS listener on port 443 with an HTTP → HTTPS redirect on port 80.

## 11. Blue/Green Deployment Model
- Deployments use a blue/green model via two target groups (`tobeynd-tg-blue`, `tobeynd-tg-green`)
- The active target group is controlled by the `active_target_group` Terraform variable
- Switching traffic requires only a `terraform apply` with the updated variable — no downtime
- The inactive group acts as a rollback target if the new deployment fails

## 12. Docker Image Trust
**Known Risk:** The Docker image is pulled from public Docker Hub (`tobeynd/fleet-management:latest`) on every instance boot, which introduces supply chain risk.
**Recommended Fix:** Push the image to a private AWS ECR repository and pull from there, ensuring image scanning and access control via IAM.

## 13. CloudWatch Alarms
- CPU high alarm (`tobeynd_cpu_high`): triggers scale-out at ≥70% CPU over 2 x 2-minute periods
- CPU low alarm (`tobeynd_cpu_low`): triggers scale-in at ≤30% CPU over 2 x 2-minute periods
- Alarms are linked to ASG scaling policies and serve as part of availability and operational security monitoring
