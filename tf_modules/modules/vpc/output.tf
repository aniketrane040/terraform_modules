output "subnet_id" {
  value = aws_subnet.selected.id
}

output "sg_group_id" {
  value = aws_security_group.my_sg.id
}