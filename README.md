

firstly run the script to create both terraform state bucket (`compromise-state`) 
and a bucket to host access logs for all other buckets(`compromise-logs). 
Given terraform does not accept variables on its state setup, these buckets names are hardcoded on creation script.
To run the script:
```shell script
sh ./modules/bucket/support-buckets.sh
```
## init the projet
to initialise this project use the command:
```shell script
terraform init --backend-config=backend.tfvars
```
otherwise fails due to missing profile/region on the backend section 
