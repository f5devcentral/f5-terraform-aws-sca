/* ## F5 Networks Secure Cloud Migration and Securty Zone Template for AWS ####################################################################################################################################################################################
Version 1.4
March 2020


This Template is provided as is and without warranty or support.  It is intended for demonstration or reference purposes. While all attempts are made to ensure it functions as desired it is not a supported by F5 Networks.  This template can be used 
to quickly deploy a Security VPC - aka DMZ, in-front of the your application VPC(S).  Additional VPCs can be added to the template by adding CIDR variables, VPC resource blocks, VPC specific route tables 
and TransitGateway edits. Limits to VPCs that can be added are =to the limits of transit gateway.

It is built to run in a region with three zones to use and will place services in 1a and 1c.  Modifications to other zones can be done.

F5 Application Services will be deployed into the security VPC but if one wished they could also be deployed inside of the Application VPCs. 

*/

###############################################################################################################################################################################################################################################################

#### Deploy Fargate Containers and Service Discovery Service ###################################################################################################################################################################################################
#  
#  This stack is for EXAMPLE only and deploys a KNOWN VULNERABLE APPLICATION.  DO NOT USE IN ENVIRONMENTS WHERE SECURITY IS A CONCERN!!!!!!
#  F5 can control ingress to Faregate services and leverage the DNS Name service to locate the items.  Note you will have to decrease the default time on the NODE (not pool) for DNS discovery to work efficiently.  You will need to use the DNS name 
#  juiceshop.my-project.local for your node.
#
#
################################################################################################################################################################################################################################################################

### Stack Default Variables 

variable aws_region {}
variable project {}
variable random_id {}
variable secrets_manager_name {}
variable iam_instance_profile_name {}
variable security_groups {}
variable vpcs {}
variable subnets {}
variable route_tables {}
variable transit_gateways {}
variable cidrs {}
variable subnet_cidrs {}
variable aws_cidr_ips {}


### JumpHost Variables

variable jump_ssh_key {
  description = "Predefined AWS SSH key used to access the sytem and create a user/password combination for RDP Access. The key must be in the same region that you are deploying to"
}

variable my_public_ip {
  description = "The Subnet or Source IP that you will connect from since RDP and SSH are open to external access. Use CIDR notation"
  type = string
}

