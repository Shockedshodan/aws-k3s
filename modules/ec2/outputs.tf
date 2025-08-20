output "instance_id" {
  value       = module.ec2.id
  description = "EC2 instance ID"
}
output "ec2_sg_id"   { value = aws_security_group.ec2.id }