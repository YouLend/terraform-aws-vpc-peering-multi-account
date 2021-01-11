variable "accepter_aws_assume_role_arn" {
  description = "Accepter AWS Assume Role ARN"
  type        = string
}

variable "accepter_region" {
  type        = string
  description = "Accepter AWS region"
}

variable "accepter_vpc_id" {
  type        = string
  description = "Accepter VPC ID filter"
  default     = ""
}

variable "accepter_vpc_tags" {
  type        = map(string)
  description = "Accepter VPC Tags filter"
  default     = {}
}

variable "accepter_allow_remote_vpc_dns_resolution" {
  default     = "true"
  description = "Allow accepter VPC to resolve public DNS hostnames to private IP addresses when queried from instances in the requester VPC"
}

# Accepter's credentials
provider "aws" {
  alias   = "accepter"
}
#
#provider "aws" {
#  alias   = "accepter"
#  region  = var.accepter_region
#  version = "~> 3.0"
#  assume_role {
#    role_arn = var.accepter_aws_assume_role_arn
#  }
#}

output "submodule_arn" {
  value = var.accepter_aws_assume_role_arn
}

locals {
  accepter_attributes = concat(var.attributes, ["accepter"])
  accepter_tags = merge(
    var.tags,
    {
      "Side" = "accepter"
    },
  )
}

module "accepter" {
  source     = "git::https://github.com/cloudposse/terraform-null-label.git?ref=master"
  enabled    = var.enabled
  namespace  = var.namespace
  name       = var.name
  stage      = var.stage
  delimiter  = var.delimiter
  attributes = local.accepter_attributes
  tags       = local.accepter_tags
}

data "aws_caller_identity" "accepter" {
  provider = aws.accepter
}

data "aws_region" "accepter" {
    provider = aws.accepter
}

# Lookup accepter's VPC so that we can reference the CIDR
data "aws_vpc" "accepter" {
  provider = aws.accepter
  id       = var.accepter_vpc_id
  tags     = var.accepter_vpc_tags
}

# Lookup accepter subnets
data "aws_subnet_ids" "accepter" {
  provider = aws.accepter
  vpc_id   = local.accepter_vpc_id
}

locals {
  accepter_subnet_ids       = distinct(sort(flatten(data.aws_subnet_ids.accepter.ids)))
  accepter_subnet_ids_count = length(local.accepter_subnet_ids)
  accepter_vpc_id           = data.aws_vpc.accepter.id
  accepter_account_id       = data.aws_caller_identity.accepter.account_id
  accepter_region           = data.aws_region.accepter.name
}

# Lookup accepter route tables
data "aws_route_tables" "accepter" {
  provider = aws.accepter
  vpc_id   = local.accepter_vpc_id
}

locals {
  accepter_aws_route_table_ids = distinct(sort(data.aws_route_tables.accepter.ids))
  accepter_aws_route_table_ids_count     = length(local.accepter_aws_route_table_ids)
  accepter_cidr_block_associations       = flatten(data.aws_vpc.accepter.cidr_block_associations)
  accepter_cidr_block_associations_count = length(local.accepter_cidr_block_associations)
}

# Create routes from accepter to requester
resource "aws_route" "accepter" {
  count    = local.accepter_aws_route_table_ids_count * local.requester_cidr_block_associations_count
  provider = aws.accepter
  route_table_id = element(
    local.accepter_aws_route_table_ids,
    ceil(count.index / local.requester_cidr_block_associations_count),
  )
  destination_cidr_block    = local.requester_cidr_block_associations[count.index % local.requester_cidr_block_associations_count]["cidr_block"]
  vpc_peering_connection_id =  aws_vpc_peering_connection.requester.id
  depends_on = [
    data.aws_route_tables.accepter,
    aws_vpc_peering_connection_accepter.accepter,
    aws_vpc_peering_connection.requester,
  ]
}




# Accepter's side of the connection.
resource "aws_vpc_peering_connection_accepter" "accepter" {
  provider                  = aws.accepter
  vpc_peering_connection_id = aws_vpc_peering_connection.requester.id
  auto_accept               = var.auto_accept
  tags                      = module.accepter.tags
  
/* accepter {
    allow_remote_vpc_dns_resolution = var.accepter_allow_remote_vpc_dns_resolution
  }  */
}

resource "null_resource" "accepter_awaiter" {
    triggers = {
        trigger = uuid()
    }
    provisioner "local-exec" {
        command = "sleep 5"
        #interpreter = ["PowerShell", "-Command"]
    }
      depends_on = [aws_vpc_peering_connection_accepter.accepter]
}

resource "aws_vpc_peering_connection_options" "accepter" {
  provider                  = aws.accepter
  vpc_peering_connection_id = aws_vpc_peering_connection.requester.id

  accepter {
    allow_remote_vpc_dns_resolution = var.accepter_allow_remote_vpc_dns_resolution
  }
  depends_on = [null_resource.accepter_awaiter]
}  

output "accepter_connection_id" {
  value       = aws_vpc_peering_connection_accepter.accepter.id
  description = "Accepter VPC peering connection ID"
}

output "accepter_accept_status" {
  value = aws_vpc_peering_connection_accepter.accepter.accept_status
  description = "Accepter VPC peering connection request status"
}

