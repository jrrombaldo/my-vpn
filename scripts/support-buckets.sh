
# creates both terraform-state and access logs buckets. If don't already exists

set -xuo pipefail
trap 's=$?; echo "$0: Error on line "$LINENO": $BASH_COMMAND"; exit $s' ERR
IFS=$'\n\t'

echo $BUCKET_STATE
echo $BUCKET_LOGS
echo $REGION
echo $PROFILE

create_bucket() {
  BUCKET=$1
  ACL=$2

  echo "creating bucket $BUCKET_STATE"
  aws s3api create-bucket \
    --bucket $BUCKET \
    --region $REGION \
    --profile $PROFILE \
    --acl $ACL \
    --create-bucket-configuration LocationConstraint=eu-west-1

  echo "enable encryption on $BUCKET"
  aws s3api put-bucket-encryption \
    --bucket $BUCKET \
    --server-side-encryption-configuration='{"Rules":[{"ApplyServerSideEncryptionByDefault":{"SSEAlgorithm":"AES256"}}]}' \
    --profile $PROFILE 
}


bucket_exist() {
  BUCKET=$1
  echo "checking if $BUCKET exists"
  aws s3api head-bucket --bucket $BUCKET --profile $PROFILE >/dev/null 2>&1
}

if bucket_exist $BUCKET_STATE; then
  echo "$BUCKET_STATE already exists"
else
  echo "$BUCKET_STATE does not exist"
  create_bucket $BUCKET_STATE "private"
fi

if bucket_exist $BUCKET_LOGS; then
  echo "$BUCKET_LOGS already exists"
else
  echo "$BUCKET_LOGS does not exist"
  create_bucket $BUCKET_LOGS "log-delivery-write"
fi

