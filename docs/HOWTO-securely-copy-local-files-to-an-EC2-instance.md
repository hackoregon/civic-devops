# Securely uploading a file to AWS EC2-hosted machine

Assume: you're using a *NIX shell (Mac, Linux or Windows 10's WSL)
Assume: you have the PEM file that was generated when launching the new instance (machine)
Assume: the PEM file (in this example) is named ec2.pem
Assume: you have copied the PEM file to your ~/.ssh directory
Assume: the EC2 machine's public DNS name (in this example) is ec2-12-34-567-890.us-west-2.compute.amazonaws.com
Assume: the target directory for the uploaded file is home (~)
Assume: the local file is stored as ~/uploads/4GBfile.txt
Assume: the file being copied is < 5GB in size

1. `chmod 400 ~/.ssh/ec2.pem`
2. `scp -i ~/.ssh/ec2.pem ~/uploads/4GBfile.txt ec2-user@ec2-12-34-567-890.us-west-2.compute.amazonaws.com:~`

See Also
https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/AccessingInstancesLinux.html