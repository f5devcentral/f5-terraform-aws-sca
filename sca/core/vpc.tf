locals {
  subnets = flatten([
    for subnet_id, subnet in var.subnets : [
      for az in range(var.vpcs[subnet.vpc].num_availability_zones) : {
        name : subnet_id
        vpc : subnet.vpc
        vpc_id : aws_vpc.sca[subnet.vpc].id
        cidr : cidrsubnet(var.vpcs[subnet.vpc].cidr_block, 8, subnet.netnum + az)
        availability_zone       = data.aws_availability_zones.available.names[az]
        map_public_ip_on_launch = subnet.map_public_ip_on_launch
        internet_gw_route       = subnet.internet_gw_route
        nat_gateway             = subnet.nat_gateway
      }
    ]
  ])
}

# find availability zones
data "aws_availability_zones" "available" {
  state = "available"
}

# Create the SCA AWS Virtual Private Clouds
resource "aws_vpc" "sca" {
  for_each = {
    for id, vpc in var.vpcs :
    id => vpc
  }

  cidr_block           = each.value.cidr_block
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(
    local.tags,
    {
      Name = format("%s_%s_%s", var.project, each.key, local.postfix)
    }
  )
}

# Create the VPC Subnets
resource "aws_subnet" "sca" {
  for_each = {
    for subnet in local.subnets : format("%s:%s", subnet.name, subnet.availability_zone) => subnet
  }

  cidr_block              = each.value.cidr
  vpc_id                  = each.value.vpc_id
  availability_zone       = each.value.availability_zone
  map_public_ip_on_launch = each.value.map_public_ip_on_launch

  tags = merge(
    local.tags,
    {
      Name = format("%s_%s_%s", var.project, each.key, local.postfix)
    }
  )
}

# Create the Internet Gateway
resource "aws_internet_gateway" "sca" {
  for_each = {
    for id, vpc in var.vpcs : id => vpc
    if(vpc.internet_gateway == true)
  }
  vpc_id = aws_vpc.sca[each.key].id

  tags = merge(
    local.tags,
    {
      Name = format("%s_%s_igw_%s", var.project, each.key, local.postfix)
    }
  )
}

# Create Internet Gateway Route
resource "aws_route_table" "sca" {
  for_each = {
    for id, vpc in var.vpcs : id => vpc
    if(vpc.internet_gateway == true)
  }
  vpc_id = aws_vpc.sca[each.key].id

  tags = merge(
    local.tags,
    {
      Name = format("%s_%s_igw_route_%s", var.project, each.key, local.postfix)
    }
  )
}

# Associate Subnets with Internet Gateway Route
resource "aws_route_table_association" "sca" {
  for_each = {
    for subnet in local.subnets : format("%s:%s", subnet.name, subnet.availability_zone) => subnet
    if(subnet.internet_gw_route == true)
  }
  route_table_id = aws_route_table.sca[each.value.vpc].id
  subnet_id      = aws_subnet.sca[each.key].id
}

# Create NAT Gateway Elastic IP
resource "aws_eip" "sca" {
  for_each = {
    for subnet in local.subnets : format("%s:%s", subnet.name, subnet.availability_zone) => subnet
    if(subnet.nat_gateway == true)
  }

  tags = merge(
    local.tags,
    {
      Name = format("%s_%s_nat_gw_eip_%s", var.project, each.key, local.postfix)
    }
  )
}

# Create NAT Gateway
resource "aws_nat_gateway" "sec-gw" {
  for_each = {
    for subnet in local.subnets : format("%s:%s", subnet.name, subnet.availability_zone) => subnet
    if(subnet.nat_gateway == true)
  }

  allocation_id = aws_eip.sca[each.key].id
  subnet_id     = aws_subnet.sca[each.key].id

  tags = merge(
    local.tags,
    {
      Name = format("%s_%s_nat_gw_%s", var.project, each.key, local.postfix)
    }
  )
}
