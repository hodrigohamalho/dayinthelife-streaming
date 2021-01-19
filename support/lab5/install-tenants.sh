# CREATE TENANTS
# GET THE MASTER ACCESS TOKEN AND URL
NUM_USERS=3
MASTER_ACCESS_TOKEN=b79705efcdc77e8d06e8512ec7bcb78b
ROUTE=$(oc get route console -n openshift-console | awk -F ' ' '{print $2}' | awk '{if(NR>1)print}')
ROUTE=$(echo ${route#*.})
MASTER_URL=https://master.$ROUTE
TENANT_PASSWORD=redhat

for i in $(seq 1 $NUM_USERS);
do 
    TENANT_NAME=user$i

    curl -X POST \
    "${MASTER_URL}/master/api/providers.xml" \
    -d "access_token=${MASTER_ACCESS_TOKEN}" \
    -d "org_name=${TENANT_NAME}" \
    -d "username=${TENANT_NAME}" \
    --data-urlencode "email=${TENANT_NAME}@redhat.com" \
    -d "password=${TENANT_PASSWORD}" > tmp.xml

    ACCOUNT_ID=$(xmllint --xpath "string(//signup/account/id)" tmp.xml)
    USER_ID=$(xmllint --xpath "string(//signup/account/users/user[1]/id)" tmp.xml)

    curl -X PUT \
    "${MASTER_URL}/admin/api/accounts/${ACCOUNT_ID}/users/${USER_ID}/activate.xml" \
    -d "access_token=${MASTER_ACCESS_TOKEN}"
done