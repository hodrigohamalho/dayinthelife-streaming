# CREATE TENANTS
# GET THE MASTER ACCESS TOKEN AND URL
MASTER_URL=https://master.apps.cluster-latam-3b89.latam-3b89.sandbox994.opentlc.com
MASTER_ACCESS_TOKEN=840a6e9a91166deac38da94fba7fcb3ddad52018d4d0c9bfb2b83949b6de02cb
TENANT_PASSWORD=redhat

for i in {1..15};
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