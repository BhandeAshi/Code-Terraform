#!/bin/bash

# Capture the RDS endpoint from Terraform output
rds=$(terraform output rds_endpoint)


# File in which you want to replace the placeholder
file_to_modify="ec2.tf"
rds="${rds#\"}"



# Placeholder to be replaced
# placeholder="$endpoint"
# sed -i 's/\endpoint/'"$rds_endpoint"'/g' script.tpl
# Replace the placeholder with the RDS endpoint using sed
# sed -i 's/endpoint/$RDS_ENDPOINT/' $file_to_modify
RDS_ENDPOINT=$(echo "$rds" | sed 's/:.*//')
sed -i "s/hrishi/$(echo $RDS_ENDPOINT | sed 's/\//\\&/g')/g" "$file_to_modify"

echo "$RDS_ENDPOINT"
