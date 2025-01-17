# AWS terraform sandbox
My persona sandbox to play around with aws and terraform.

Run the following command to deploy:
```
terraform apply -auto-approveterraform apply -auto-approve
```

Before it you must have a valid [aws config](https://docs.aws.amazon.com/cli/latest/reference/configure/)
## Read articles
- [Article](https://geekrodion.medium.com/deploying-spa-on-aws-with-terraform-358ba2aeaf9b)
- [How To: Mass S3 Object Creation with Terraform](https://chrisdecairos.ca/s3-objects-terraform/)
- [Terraform and CORS-Enabled AWS API Gateway](https://medium.com/@MrPonath/terraform-and-aws-api-gateway-a137ee48a8ac)
- [Why is the method response of an API gateway different when being created using terraform?
](https://stackoverflow.com/questions/56071536/why-is-the-method-response-of-an-api-gateway-different-when-being-created-using)
- [AWS - Build serverless web app lambda apigateway s3 dynamodb cognito](https://aws.amazon.com/getting-started/hands-on/build-serverless-web-app-lambda-apigateway-s3-dynamodb-cognito/module-3/)
- [aws-cognito-terraform-tutorial](https://johncodeinaire.com/aws-cognito-terraform-tutorial/)
- [Deploying using openApi 3.0 and terraform](https://medium.com/dazn-tech/deploying-aws-api-gateway-with-iam-auth-using-openapi-3-0-and-terraform-27fda7e7cf2a)

## Known issues
- Cognito is not sending code verification. Go to the cognito website and confirm manually.

- When authentication added to the post endpoint cors fails [link](https://forums.aws.amazon.com/thread.jspa?threadID=213844)