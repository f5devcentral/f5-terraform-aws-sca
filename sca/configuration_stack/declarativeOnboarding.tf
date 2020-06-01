locals {
  external_bigip_az1 = flatten([
    for environment, bigips in var.bigip_map.value : [
      for key, bigip in bigips : {
        id : key
        subnets : {
          for subnet, data in bigip : data.attachment[0].device_index => {
            private_ip : data.private_ip,
            private_dns_name : data.private_dns_name
          }
        }
      }
    ] if(environment == "external_az1")
  ])
}
locals {
  external_bigip_az2 = flatten([
    for environment, bigips in var.bigip_map.value : [
      for key, bigip in bigips : {
        id : key
        subnets : {
          for subnet, data in bigip : data.attachment[0].device_index => {
            private_ip : data.private_ip,
            private_dns_name : data.private_dns_name
          }
        }
      }
    ] if(environment == "external_az2")
  ])
}
locals {
  ips_bigips = flatten([
    for environment, bigips in var.bigip_map.value : [
      for key, bigip in bigips : {
        id : key
        subnets : {
          for subnet, data in bigip : data.attachment[0].device_index => {
            private_ip : data.private_ip,
            private_dns_name : data.private_dns_name
          }
        }
      }
    ] if(environment == "ips")
  ])
}
locals {
  internal_bigips = flatten([
    for environment, bigips in var.bigip_map.value : [
      for key, bigip in bigips : {
        id : key
        subnets : {
          for subnet, data in bigip : data.attachment[0].device_index => {
            private_ip : data.private_ip,
            private_dns_name : data.private_dns_name
          }
        }
      }
    ] if(environment == "internal")
  ])
}

#retrieve secret from AWS to use in DO
data "aws_secretsmanager_secret_version" "secret" {
  secret_id = var.secrets_manager_name.value
}

data "template_file" "ext_bigip_az1_do_json" {
  template = file("${path.module}/templates/declarativeOnboarding/externalClusterPayg.json")

  vars = {
    #Uncomment the following line for BYOL
    #local_sku	    = "${var.license1}"
    host1	        = local.external_bigip_az1[0].subnets.0.private_ip
    host2	        = local.external_bigip_az2[0].subnets.0.private_ip
    local_host      = local.external_bigip_az1[0].subnets.0.private_dns_name
    local_selfip    = local.external_bigip_az1[0].subnets.1.private_ip
    local_selfip2   = local.external_bigip_az1[0].subnets.2.private_ip
    local_selfip3   = local.external_bigip_az1[0].subnets.3.private_ip
    remote_host	    = local.external_bigip_az2[0].subnets.0.private_dns_name
    remote_selfip   = local.external_bigip_az2[0].subnets.2.private_ip
    gateway	        = var.ext0_gateway
    dns_server	    = var.dns_server
    ntp_server	    = var.ntp_server
    timezone	    = var.timezone
    admin_user      = var.uname
    admin_password  = data.aws_secretsmanager_secret_version.secret.secret_string
  }
}

data "template_file" "ext_bigip_az2_do_json" {
  template = file("${path.module}/templates/declarativeOnboarding/externalClusterPayg.json")

  vars = {
    #Uncomment the following line for BYOL
    #local_sku	    = "${var.license1}"
    host1	        = local.external_bigip_az1[0].subnets.0.private_ip
    host2	        = local.external_bigip_az2[0].subnets.0.private_ip
    local_host      = local.external_bigip_az2[0].subnets.0.private_dns_name
    local_selfip    = local.external_bigip_az2[0].subnets.1.private_ip
    local_selfip2   = local.external_bigip_az2[0].subnets.2.private_ip
    local_selfip3   = local.external_bigip_az2[0].subnets.3.private_ip
    remote_host	    = local.external_bigip_az1[0].subnets.0.private_dns_name
    remote_selfip   = local.external_bigip_az1[0].subnets.2.private_ip
    gateway	        = var.ext0_gateway
    dns_server	    = var.dns_server
    ntp_server	    = var.ntp_server
    timezone	    = var.timezone
    admin_user      = var.uname
    admin_password  = data.aws_secretsmanager_secret_version.secret.secret_string
  }
}
data "template_file" "ips_bigip_az1_do_json" {
  template = file("${path.module}/templates/declarativeOnboarding/externalClusterPayg.json")

  vars = {
    #Uncomment the following line for BYOL
    #local_sku	    = "${var.license1}"
    host1	        = local.ips_bigips[0].subnets.0.private_ip
    host2	        = local.ips_bigips[1].subnets.0.private_ip
    local_host      = local.ips_bigips[0].subnets.0.private_dns_name
    local_selfip    = local.ips_bigips[0].subnets.1.private_ip
    local_selfip2   = local.ips_bigips[0].subnets.2.private_ip
    local_selfip3   = local.ips_bigips[0].subnets.3.private_ip
    remote_host	    = local.ips_bigips[1].subnets.0.private_dns_name
    remote_selfip   = local.ips_bigips[1].subnets.2.private_ip
    gateway	        = var.ips0_gateway
    dns_server	    = var.dns_server
    ntp_server	    = var.ntp_server
    timezone	    = var.timezone
    admin_user      = var.uname
    admin_password  = data.aws_secretsmanager_secret_version.secret.secret_string
  }
}

data "template_file" "ips_bigip_az2_do_json" {
  template = file("${path.module}/templates/declarativeOnboarding/externalClusterPayg.json")

  vars = {
    #Uncomment the following line for BYOL
    #local_sku	    = "${var.license1}"
    host1	        = local.ips_bigips[0].subnets.0.private_ip
    host2	        = local.ips_bigips[1].subnets.0.private_ip
    local_host      = local.ips_bigips[1].subnets.0.private_dns_name
    local_selfip    = local.ips_bigips[1].subnets.1.private_ip
    local_selfip2   = local.ips_bigips[1].subnets.2.private_ip
    local_selfip3   = local.ips_bigips[1].subnets.3.private_ip
    remote_host	    = local.ips_bigips[0].subnets.0.private_dns_name
    remote_selfip   = local.ips_bigips[0].subnets.2.private_ip
    gateway	        = var.ips1_gateway
    dns_server	    = var.dns_server
    ntp_server	    = var.ntp_server
    timezone	    = var.timezone
    admin_user      = var.uname
    admin_password  = data.aws_secretsmanager_secret_version.secret.secret_string
  }
}
data "template_file" "internal_bigip_az1_do_json" {
  template = file("${path.module}/templates/declarativeOnboarding/externalClusterPayg.json")

  vars = {
    #Uncomment the following line for BYOL
    #local_sku	    = "${var.license1}"
    host1	        = local.internal_bigips[0].subnets.0.private_ip
    host2	        = local.internal_bigips[1].subnets.0.private_ip
    local_host      = local.internal_bigips[0].subnets.0.private_dns_name
    local_selfip    = local.internal_bigips[0].subnets.1.private_ip
    local_selfip2   = local.internal_bigips[0].subnets.2.private_ip
    local_selfip3   = local.internal_bigips[0].subnets.3.private_ip
    remote_host	    = local.internal_bigips[1].subnets.0.private_dns_name
    remote_selfip   = local.internal_bigips[1].subnets.2.private_ip
    gateway	        = var.int0_gateway
    dns_server	    = var.dns_server
    ntp_server	    = var.ntp_server
    timezone	    = var.timezone
    admin_user      = var.uname
    admin_password  = data.aws_secretsmanager_secret_version.secret.secret_string
  }
}

data "template_file" "internal_bigip_az2_do_json" {
  template = file("${path.module}/templates/declarativeOnboarding/externalClusterPayg.json")

  vars = {
    #Uncomment the following line for BYOL
    #local_sku	    = "${var.license1}"
    host1	        = local.internal_bigips[0].subnets.0.private_ip
    host2	        = local.internal_bigips[1].subnets.0.private_ip
    local_host      = local.internal_bigips[1].subnets.0.private_dns_name
    local_selfip    = local.internal_bigips[1].subnets.1.private_ip
    local_selfip2   = local.internal_bigips[1].subnets.2.private_ip
    local_selfip3   = local.internal_bigips[1].subnets.3.private_ip
    remote_host	    = local.internal_bigips[0].subnets.0.private_dns_name
    remote_selfip   = local.internal_bigips[0].subnets.2.private_ip
    gateway	        = var.int1_gateway
    dns_server	    = var.dns_server
    ntp_server	    = var.ntp_server
    timezone	    = var.timezone
    admin_user      = var.uname
    admin_password  = data.aws_secretsmanager_secret_version.secret.secret_string
  }
}
resource "local_file" "ext_bigip_az1_do_json" {
  content     = data.template_file.ext_bigip_az1_do_json.rendered
  filename    = "${path.module}/ext_bigip_az1_do_json.json"
}
resource "local_file" "ext_bigip_az2_do_json" {
  content     = data.template_file.ext_bigip_az2_do_json.rendered
  filename    = "${path.module}/ext_bigip_az2_do_json.json"
}
resource "local_file" "ips_bigip_az1_do_json" {
  content     = data.template_file.ips_bigip_az1_do_json.rendered
  filename    = "${path.module}/ips_bigip_az1_do_json.json"
}
resource "local_file" "ips_bigip_az2_do_json" {
  content     = data.template_file.ips_bigip_az2_do_json.rendered
  filename    = "${path.module}/ips_bigip_az2_do_json.json"
}
resource "local_file" "internal_bigip_az1_do_json" {
  content     = data.template_file.internal_bigip_az1_do_json.rendered
  filename    = "${path.module}/internal_bigip_az1_do_json.json"
}
resource "local_file" "internal_bigip_az2_do_json" {
  content     = data.template_file.internal_bigip_az2_do_json.rendered
  filename    = "${path.module}/internal_bigip_az2_do_json.json"
}

provider "bigip" {
  alias = "external_bigip_az1"
  address = "https://${var.bigip_mgmt_ips.value.external_az1[0]}"
  username = "admin"
  password = data.aws_secretsmanager_secret_version.secret.secret_string
}

provider "bigip" {
  alias = "external_bigip_az2"
  address = "https://${var.bigip_mgmt_ips.value.external_az2[0]}"
  username = "admin"
  password = data.aws_secretsmanager_secret_version.secret.secret_string
}

provider "bigip" {
  alias = "ips_bigip_az1"
  address = "https://${var.bigip_mgmt_ips.value.ips[0]}"
  username = "admin"
  password = data.aws_secretsmanager_secret_version.secret.secret_string
}

provider "bigip" {
  alias = "ips_bigip_az2"
  address = "https://${var.bigip_mgmt_ips.value.ips[1]}"
  username = "admin"
  password = data.aws_secretsmanager_secret_version.secret.secret_string
}

provider "bigip" {
  alias = "internal_bigip_az1"
  address = "https://${var.bigip_mgmt_ips.value.internal[0]}"
  username = "admin"
  password = data.aws_secretsmanager_secret_version.secret.secret_string
}

provider "bigip" {
  alias = "internal_bigip_az2"
  address = "https://${var.bigip_mgmt_ips.value.internal[1]}"
  username = "admin"
  password = data.aws_secretsmanager_secret_version.secret.secret_string
}

resource "bigip_do"  "external_bigip_az1" {
     provider = bigip.external_bigip_az1
     do_json =  data.template_file.ext_bigip_az1_do_json.rendered
     tenant_name = "external_bigip_az1"
 }

resource "bigip_do"  "external_bigip_az2" {
     provider = bigip.external_bigip_az2
     do_json =  data.template_file.ext_bigip_az2_do_json.rendered
     tenant_name = "external_bigip_az2"
 }

resource "bigip_do"  "ips_bigip_az1" {
     provider = bigip.ips_bigip_az1
     do_json =  data.template_file.ips_bigip_az1_do_json.rendered
     tenant_name = "ips_bigip_az1"
 }

resource "bigip_do"  "ips_bigip_az2" {
     provider = bigip.ips_bigip_az2
     do_json =  data.template_file.ips_bigip_az2_do_json.rendered
     tenant_name = "ips_bigip_az2"
 }

resource "bigip_do"  "internal_bigip_az1" {
     provider = bigip.internal_bigip_az1
     do_json =  data.template_file.internal_bigip_az1_do_json.rendered
     tenant_name = "internal_bigip_az1"
 }

resource "bigip_do"  "internal_bigip_az2" {
     provider = bigip.internal_bigip_az2
     do_json =  data.template_file.internal_bigip_az2_do_json.rendered
     tenant_name = "internal_bigip_az2"
 }
 

output external_bigips {
  value = var.bigip_mgmt_ips
}

