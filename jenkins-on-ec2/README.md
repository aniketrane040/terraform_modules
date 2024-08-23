Once jenkins installed on ec2

## Access Jenkins
Open your web browser and access Jenkins by navigating to:\n
http://your_amazon_linux_instance_ip:8080\n
or\n
http://ec2_ip_dns:8080

Retrieve the password with the following command:
 
     sudo cat /var/lib/jenkins/secrets/initialAdminPassword
