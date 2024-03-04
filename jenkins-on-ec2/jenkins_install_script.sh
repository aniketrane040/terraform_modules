#!/bin/bash
yum update -y
sed -i 's/^PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
sed -i 's/^PermitRootLogin .*/PermitRootLogin yes/' /etc/ssh/sshd_config
echo 'arane ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers
yum install -y java-1.8.0-openjdk-devel
wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key
yum install -y jenkins
systemctl start jenkins
systemctl enable jenkins
