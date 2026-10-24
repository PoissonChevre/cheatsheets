# AWS CLI — Cheat Sheet

Manage Amazon Web Services from the terminal with the `aws` command (CLI v2).

---

## Install & Configure

```bash
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o awscliv2.zip
unzip awscliv2.zip && sudo ./aws/install  # Install CLI v2
sudo ./aws/install --update  # Update existing install
aws configure  # Set access key, secret, region, output (default profile)
aws configure --profile lab  # Create a named profile
aws configure sso  # Login with IAM Identity Center (recommended over access keys)
aws sts get-caller-identity  # Who am I? (account, user/role ARN)
export AWS_PROFILE=lab AWS_REGION=eu-west-3  # Use profile and region for this shell
```

**Files:**
```
~/.aws/config       # Profiles, regions, SSO settings
~/.aws/credentials  # Access keys (never commit!)
```

## Output & Queries

```bash
aws ec2 describe-instances --output table  # Output as table (also: json, text, yaml)
aws ec2 describe-instances --query "Reservations[].Instances[].[InstanceId,State.Name,PublicIpAddress]" \
  --output table  # Filter with JMESPath
aws ec2 describe-instances --filters "Name=instance-state-name,Values=running"  # Server-side filter
aws ec2 describe-regions --query "Regions[].RegionName" --output text  # List regions
```

## EC2 (Virtual Machines)

```bash
aws ec2 create-key-pair --key-name lab-key --query KeyMaterial --output text > lab-key.pem
chmod 400 lab-key.pem  # SSH key pair
aws ec2 run-instances \
  --image-id resolve:ssm:/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64 \
  --instance-type t3.micro --key-name lab-key --security-group-ids sg-xxxx \
  --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=web1}]'  # Launch latest Amazon Linux
aws ec2 stop-instances --instance-ids i-xxxx  # Stop (EBS still billed)
aws ec2 start-instances --instance-ids i-xxxx  # Start
aws ec2 terminate-instances --instance-ids i-xxxx  # Delete instance
ssh -i lab-key.pem ec2-user@<public-ip>  # Connect (ubuntu@ for Ubuntu AMIs)
aws ssm start-session --target i-xxxx  # Shell without SSH/open port (needs SSM plugin + IAM role)
```

## Networking (VPC)

```bash
aws ec2 describe-vpcs --output table  # List VPCs (one default VPC per region)
aws ec2 create-vpc --cidr-block 10.20.0.0/16  # Create VPC
aws ec2 create-subnet --vpc-id vpc-xxxx --cidr-block 10.20.1.0/24 --availability-zone eu-west-3a
aws ec2 create-security-group --group-name web-sg --description "web" --vpc-id vpc-xxxx
aws ec2 authorize-security-group-ingress --group-id sg-xxxx --protocol tcp --port 22 \
  --cidr $(curl -s ifconfig.me)/32  # Allow SSH from my IP
# Security group = stateful, allow rules only (instance level)
# Network ACL     = stateless, allow + deny (subnet level)
```

## S3 (Object Storage)

```bash
aws s3 ls  # List buckets
aws s3 mb s3://my-lab-$RANDOM  # Create bucket (globally unique name)
aws s3 cp file.txt s3://bucket/  # Upload
aws s3 cp s3://bucket/file.txt .  # Download
aws s3 sync ./site s3://bucket/site --delete  # Sync folder (mirror)
aws s3 ls s3://bucket --recursive --human-readable  # List objects
aws s3 presign s3://bucket/file.txt --expires-in 3600  # Temporary download URL (1h)
aws s3 rb s3://bucket --force  # Delete bucket and its content
aws s3api put-bucket-versioning --bucket bucket --versioning-configuration Status=Enabled
```

## IAM

```bash
aws iam list-users --output table  # List users
aws iam create-user --user-name dev1  # Create user
aws iam attach-user-policy --user-name dev1 \
  --policy-arn arn:aws:iam::aws:policy/ReadOnlyAccess  # Attach managed policy
aws iam list-attached-user-policies --user-name dev1  # Show user's policies
aws iam list-roles --query "Roles[].RoleName" --output text  # List roles
```

## CloudFormation (IaC)

```bash
aws cloudformation deploy --template-file stack.yaml --stack-name lab \
  --parameter-overrides Env=dev --capabilities CAPABILITY_IAM  # Create or update stack
aws cloudformation describe-stacks --stack-name lab --query "Stacks[0].Outputs"  # Outputs
aws cloudformation delete-stack --stack-name lab  # Delete stack and its resources
```

## Monitoring & Cost

```bash
aws logs tail /aws/lambda/my-func --follow  # Stream CloudWatch logs
aws cloudtrail lookup-events --max-results 10  # Recent API activity (who did what)
aws ce get-cost-and-usage --time-period Start=2026-10-01,End=2026-10-16 \
  --granularity MONTHLY --metrics UnblendedCost  # Month-to-date cost
```

## Azure ↔ AWS

```
Subscription         → Account              Management Group → Organizations OU
Entra ID / RBAC      → IAM Identity Center / IAM policies
Resource Group       → (Tags / CloudFormation stack)
VM / VMSS            → EC2 / Auto Scaling Group
Managed Disk         → EBS                  Blob Storage → S3
Azure Files          → EFS / FSx            VNet → VPC
NSG                  → Security Group (+ NACL)
Load Balancer        → NLB                  App Gateway → ALB
Bastion              → SSM Session Manager
AKS / ACI / ACR      → EKS / ECS Fargate / ECR
Functions            → Lambda               Key Vault → Secrets Manager / KMS
Monitor / Activity Log → CloudWatch / CloudTrail
ARM / Bicep          → CloudFormation       Azure DNS → Route 53
Azure Policy         → SCP / AWS Config     Backup / ASR → AWS Backup / Elastic DR
```

## Troubleshooting

```bash
# "Unable to locate credentials" → run aws configure / aws sso login, or check AWS_PROFILE
# "UnauthorizedOperation" / "AccessDenied" → missing IAM permission
# Resource not found → wrong region (check AWS_REGION / --region)
aws sso login --profile lab  # Refresh expired SSO session
aws ec2 describe-instances --debug  # Full HTTP trace
```

---

## Pitfalls

- Never use the root account daily: IAM Identity Center (SSO) or roles, no long-lived access keys in code.
- Check who you are before changing things: `aws sts get-caller-identity`.
- "Resource not found" is often the wrong region: add `--region` or check the profile.
- A stopped EC2 instance still costs: EBS volumes and Elastic IPs are billed. Terminate what you don't use.
- Security groups are stateful (allow only); network ACLs are stateless (allow + deny, both directions).
- `aws s3 rm --recursive` has no undo unless bucket versioning is on.
- `--query` filters on your side, `--filters` on the AWS side (faster on big accounts).
- Set a budget alarm on day one, even on the free tier.

---

## References

- [AWS CLI v2 documentation](https://docs.aws.amazon.com/cli/latest/userguide/)
- [AWS CLI command reference](https://awscli.amazonaws.com/v2/documentation/api/latest/index.html)
- [Filtering output with --query](https://docs.aws.amazon.com/cli/latest/userguide/cli-usage-filter.html)
