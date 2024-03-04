#!/bin/bash
yum update -y
sed -i 's/^PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
sed -i 's/^PermitRootLogin .*/PermitRootLogin yes/' /etc/ssh/sshd_config
echo 'arane ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers
amazon-linux-extras install java-openjdk11
wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
yum upgrade
yum install jenkins -y
systemctl enable jenkins
systemctl start jenkins
