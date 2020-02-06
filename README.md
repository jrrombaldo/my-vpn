# MyVPN
This project consists of running the OpenVPN from [jrromb/openvpn-as](https://hub.docker.com/repository/docker/jrromb/openvpn-as) on a AWS account, using terraform. The main focus is to abstract the technolgy, making it the most  user-friendly possible. 
This  gives you a complete AWS infrastructure with ready-to-use OpenVPN server, and  **works perfectly with the AWS free tier :)**, which means a free private VPN service.


### Requirements:
To successfully execute this project, you'll need the following:
1. A fully working AWS CLI with a profile configured. [Further details here](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-configure.html)
2. Have terraform installed, [details here](https://learn.hashicorp.com/terraform/getting-started/install.html)
3. Generate an SSH key, in case you need to connect on the server later on. Execute the following command on MAC/Linux. `ssh-keygen -t rsa -b 4096 -C "my-vpn" -f "~/.ssh/my-vpn.pub"`, on Windows it varies according to the SSH tool you use.
4. update the terraform.tfvars file, adding your VPN details, such as the OpenVPN user password.

Once requirements are met,  run the commands on this section and you are ready to go.
```
terraform init
terraform apply -auto-approve
```
Once completed, it outputs the VPN IP address like in the following example:
```
Apply complete! 

Outputs:

vpn_addr = [
  "123.123.123.123",
]
```
The VPN is ready to be used, access the output server IP address (if unsure, you can always check on the AWS console as well.)
```
https://<123.123.123.123>:8443
```


