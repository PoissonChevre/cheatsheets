# Terraform — Cheat Sheet

Infrastructure as Code tool for provisioning and managing cloud resources declaratively.

---

## Init & Providers

```hcl
terraform init  # Download providers and set up the backend

terraform init -upgrade  # Upgrade provider versions

terraform {
  required_version = ">= 1.0"  # Enforce Terraform version
  required_providers {
    aws = {
      source  = "hashicorp/aws"  # Provider namespace/type
      version = "~> 5.0"  # Version constraint
    }
  }
}

provider "aws" {
  region = "us-east-1"  # Configure AWS region
  # Other providers: azurerm, google, digitalocean, linode
}

provider "aws" {
  alias  = "eu"  # Provider alias for multiple regions
  region = "eu-west-1"
}
```

---

## Variables & Outputs

```hcl
variable "instance_type" {
  type        = string  # Type: string, number, bool, list, map, etc.
  description = "EC2 instance type"
  default     = "t2.micro"  # Optional default value
  sensitive   = false  # Hide from logs if true
}

variable "tags" {
  type = map(string)  # Map type for key-value pairs
  default = {
    Environment = "prod"
  }
}

variable "availability_zones" {
  type = list(string)  # List of strings
  default = ["us-east-1a", "us-east-1b"]
}

output "instance_id" {
  value       = aws_instance.web.id  # Export value for use
  description = "The instance ID"
  sensitive   = false  # Hide from logs if true
}

output "cluster_ips" {
  value = {
    for instance in aws_instance.web : instance.id => instance.private_ip
  }  # Output computed map
}
```

```bash
terraform apply -var="instance_type=t2.small"  # Override variable at CLI
terraform apply -var-file="prod.tfvars"  # Load from file
terraform output instance_id  # Display specific output value
```

---

## Resources & Data Sources

```hcl
resource "aws_instance" "web" {
  ami           = "ami-0c55b159cbfafe1f0"  # Amazon Machine Image ID
  instance_type = var.instance_type

  tags = {
    Name = "web-server"  # Resource tag
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true  # Get latest AMI
  owners      = ["099720109477"]  # Canonical owner

  filter {
    name   = "name"  # Filter by name
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
}

resource "aws_security_group" "web" {
  name = "web-sg"

  ingress {
    from_port   = 80  # Start of port range
    to_port     = 80  # End of port range
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow from anywhere
  }

  egress {
    from_port   = 0  # Allow all outbound
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
```

---

## State Management

```bash
terraform state list  # List all resources in state
terraform state show aws_instance.web  # Show specific resource state
terraform state rm aws_instance.web  # Remove resource from state
terraform refresh  # Sync state with infrastructure
terraform import aws_instance.web i-1234567890abcdef0  # Add an existing resource to the state (no creation)

terraform state pull > backup.tfstate  # Backup state file
terraform state push backup.tfstate  # Restore from backup
```

```hcl
terraform {
  backend "s3" {
    bucket         = "my-terraform-state"  # S3 bucket for state
    key            = "prod/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true  # Encrypt state file
    dynamodb_table = "terraform-locks"  # State locking table
  }
}
```

---

## Plan & Apply

```bash
terraform plan  # Preview infrastructure changes
terraform plan -out=tfplan  # Save plan to file
terraform apply tfplan  # Apply saved plan
terraform apply -auto-approve  # Skip approval prompt
terraform destroy  # Tear down infrastructure
terraform destroy -auto-approve  # Destroy without confirmation

terraform apply -replace="aws_instance.web"  # Force resource recreation

terraform apply -target=aws_instance.web  # One resource only (exceptions, not daily use)

terraform plan -destroy  # Show what would be destroyed
```

---

## Modules

```hcl
module "vpc" {
  source = "./modules/vpc"  # Local module path
  # source = "git::https://github.com/user/repo//modules/vpc"  # Git module
  # source = "hashicorp/vpc/aws"  # Registry module

  cidr_block = "10.0.0.0/16"  # Pass variables to module
  env        = "prod"
}

output "vpc_id" {
  value = module.vpc.vpc_id  # Reference module outputs
}
```

---

## Workspaces

```bash
terraform workspace list  # List all workspaces
terraform workspace new prod  # Create new workspace
terraform workspace select prod  # Switch to workspace
terraform workspace delete dev  # Delete workspace
terraform workspace show  # Show current workspace
```

```hcl
resource "aws_instance" "web" {
  instance_type = var.instance_type

  tags = {
    Environment = terraform.workspace  # Reference current workspace
  }
}
```

---

## Import & Destroy

```bash
terraform import aws_instance.example i-1234567890abcdef0  # Import existing resource
terraform state rm aws_instance.old  # Remove from state only
terraform destroy -target=aws_instance.web  # Destroy specific resource
terraform destroy  # Destroy all resources
```

```hcl
resource "aws_instance" "imported" {
  # After import, add configuration here
  # terraform state show aws_instance.imported to see current state
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"
}
```

---

## Pitfalls

- Never edit the state file by hand: `terraform state mv/rm`, `import`, `moved` blocks.
- The state contains secrets in clear: never commit it, use a remote backend with locking.
- Commit `.terraform.lock.hcl`, ignore `.terraform/` and `*.tfstate*`.
- Always read the plan: `-/+` means destroy and recreate.
- Renaming a resource in code = destroy + create, unless you add a `moved` block.
- `-target` and `-replace` are for exceptions, not daily use.
- Pin provider and module versions.
- `terraform destroy` removes everything in the workspace: check the workspace first.
