# SSKAI 
## Simple shoddy k3s aws infra

Very simple implementation of 1 ec2 node with k3s running on it behind ALB and NLB for management. 
Two methods - GET accessible from WAN. PUT/POST only from inside EC2 node network.


Repo rollouts everything in one go due to time restrictions.

### Pre-requisites
- AWS terraform user created with an access to creating EC2, IAM, SG, VPC, S3. Easiest way is to give an admin rights to it if you run freetier
- Authorize tf-user as a separate profile
- Terraform >=v1.12

### How to run


### How to destroy

#### phase 1: remove k8s things first
`terraform destroy -target=module.k8s-httpbin`

#### phase 2: destroy the rest
`terraform destroy`



### What inside
- EC2+2ALB(int/ext), NLB(ssh/kubeapi), SSM enabled, S3+DynamoDB(commented out)
