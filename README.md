# Node.js Application Deployment with Docker and AWS Elastic Beanstalk

## Prerequisites
Before proceeding, ensure you have the following installed:

- **Docker**: To build and run the application locally.
- **AWS CLI**: For interacting with AWS services.
- **Terraform**: For infrastructure automation.
- **Git**: To manage source control.
- **GitHub Actions**: For CI/CD pipeline automation.

## Local Testing
To build and run the application locally using Docker:

```sh
# Build the Docker image
docker build -t my-nodejs-app .

# Run the container
docker run -p 3000:3000 my-nodejs-app
```

## Deployment to AWS Elastic Beanstalk
### 1. Create an AWS Account and IAM User
You need an **AWS account** and **IAM credentials** (Access Key and Secret Access Key) with the necessary permissions.

### 2. Configure AWS Credentials Locally
Set up AWS credentials using the AWS CLI:

```sh
aws configure
```

Follow the prompts to enter your **AWS Access Key**, **Secret Access Key**, **Region**, and **Output Format**.

<!-- ### 3. Assign Required Permissions
To allow AWS Elastic Beanstalk to manage deployments, attach the following policies to the IAM role:

```sh
aws iam attach-role-policy --role-name elastic_beanstalk_role \
  --policy-arn arn:aws:iam::aws:policy/AWSElasticBeanstalkFullAccess

aws iam attach-role-policy --role-name elastic_beanstalk_role \
  --policy-arn arn:aws:iam::aws:policy/AWSElasticBeanstalkManagedUpdatesCustomerRolePolicy

aws iam attach-role-policy --role-name elastic_beanstalk_role \
  --policy-arn arn:aws:iam::aws:policy/AWSElasticBeanstalkService

aws iam attach-role-policy --role-name elastic_beanstalk_role \
  --policy-arn arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess
``` -->

### 3. Add Secrets to GitHub Repository
To store AWS credentials securely in GitHub Actions, follow these steps:

1. Go to your GitHub repository.
2. Navigate to **Settings** > **Secrets and variables** > **Actions**.
3. Click **New repository secret**.
4. Add the following secrets:
   - `AWS_ACCESS_KEY_ID`
   - `AWS_SECRET_ACCESS_KEY`
   - `AWS_REGION`
   - `AWS_ACCOUNT_ID`
   - `EB_APP_NAME`
   - `EB_ENV_NAME`
5. Save each secret and ensure they match your AWS credentials.

### 4. Deploy Infrastructure Using Terraform
To automate the Elastic Beanstalk environment creation, initialize and apply Terraform:

```sh
terraform init
terraform apply -auto-approve
```

This will provision the required AWS resources for Elastic Beanstalk.

### 5. Commit and Push Changes to GitHub
After making changes, push the code to the repository to trigger the GitHub Actions CI/CD pipeline:

```sh
git add .
git commit -m "Deploying Node.js app to AWS Elastic Beanstalk"
git push origin main
```

## Continuous Deployment with GitHub Actions
A GitHub Actions workflow is configured to:

- Build and push the Docker image to **Amazon ECR**.
- Deploy the application to **Elastic Beanstalk**.
- Automate the deployment process.

The workflow is triggered every time changes are pushed to the **main** branch.

## Monitoring and Logs
To check the status of your Elastic Beanstalk environment:

```sh
eb status
```

To view logs:

```sh
eb logs
```

## Cleanup
To delete the Elastic Beanstalk environment and associated AWS resources:

```sh
eb terminate
terraform destroy -auto-approve
```

---

This `README.md` provides a structured and professional guide to deploying your Node.js application using Docker and AWS Elastic Beanstalk. 🚀

