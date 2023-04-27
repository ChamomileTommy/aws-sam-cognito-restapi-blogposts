echo Generate Access Token for User In UserPool
echo -----------------------------------------
echo Enter the UserPoolId for the generated Cognito User Pool:
read USER_POOL_ID
echo Enter the CLIENT-ID:
read CLIENT_ID
echo Enter the email address for the user you want to create:
read USER_EMAIL_ADDRESS
echo Enter the temporary password for the user \(will be forced to change\):
read -s USER_TEMP_PASSWORD
echo -----------------------------------------

# create user in UserPool
aws cognito-idp admin-create-user --user-pool-id $USER_POOL_ID --username $USER_EMAIL_ADDRESS --temporary-password $USER_TEMP_PASSWORD --user-attributes Name=email,Value=$USER_EMAIL_ADDRESS Name=email_verified,Value=True
# generate session for user
aws cognito-idp initiate-auth --auth-flow USER_PASSWORD_AUTH --auth-parameters "USERNAME=$USER_EMAIL_ADDRESS,PASSWORD=$USER_TEMP_PASSWORD" --client-id $CLIENT_ID --query "Session" --output text > session.txt
# get session from session.txt to generate access token for user (this access token will be add to Authorization of Postman)
aws cognito-idp admin-respond-to-auth-challenge --user-pool-id $USER_POOL_ID --client-id $CLIENT_ID --challenge-responses "USERNAME=$USER_EMAIL_ADDRESS,NEW_PASSWORD=$USER_TEMP_PASSWORD" --challenge-name NEW_PASSWORD_REQUIRED --session $(cat session.txt) > accessToken.txt

# add user to DynamoDB (when testing api, checking user exist or not )
# SCRIPT_PATH=$(dirname -- "$(readlink -f "${BASH_SOURCE}")")
# USER_ACCOUNT_ITEM=$(<$SCRIPT_PATH/dynamo-data/user_account/default-user.json)
# USER_ACCOUNT_ITEM=${USER_ACCOUNT_ITEM//$'\n'/}
# aws dynamodb put-item --table-name AWS_USER_ACCOUNT --item "${USER_ACCOUNT_ITEM/USER_NAME/$USER_EMAIL_ADDRESS}"

echo Generate Access Token successfully ./script/accessToken.txt