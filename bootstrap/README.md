# Initial Setup
1. Run userroles.sh and grab the token
2. Place the token in the terraform.tfvars secret file
3. Configure backups 
4. Run containerimages.sh script to download desired base image templates
5. Run keys.sh to add pem keys to the server for ssh access. Used in some resource provisioner steps to modify cluster directly.
6. Run terraform/main.tf to deploy services and modules