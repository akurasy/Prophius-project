# Prophius Project

This project, comprise of an EKS cluster and RDS MySQL Database deployed on AWS incorporated with AWS networking best practices and security practices when deploying this. The project performs the entire process using Terraform to automate the process of creating the resources. 

![Alt text](./readmeimg/image.png)

The image above is a perfect representation of the architecture and process I used when deploying the architecture. The application is a simple CRUD application written in JAVA. The CRUD activities is being performed on the MySQL database. 

The concept of the application, involves replicas of kubernetes pods holding the java backend application. Terraform creates a secret manager with a key-value pair object of the database username, password and endpoint  the service account created by kubernetes sill read the values of the secret manager and then pass it as environment variable to the pods that will be created in the cluster.

This ensures safe handling of the secrets values to the pods without exposing it either in the terraform code, or in the kubernetes cluster.

To deploy this application, ensure that you have the requirements in the table below installed on the host machine before deploying the application.

| ------------- | ------------- |
| AWS CLI Configured  | :heavy_check_mark:  |
| Docker Installed  | :heavy_check_mark:  |
| Terraform Installed | :heavy_check_mark: |
| Java Installed | :heavy_check_mark: |
| Maven Installed| :heavy_check_mark: |

Update your server and create a working directory. Pls note we will be deploying this application on ubuntu server

```
sudo apt update -y
mkdir Project
cd Project
```

Initialize git in the working directory and clone the repo. for

```
git init
git clone https://github.com/akurasy/Prophius-project.git
cd Prophius-project
``` 


Initialize terraform in the terraform working directory

```
cd terraform
terraform init
```

Apply Terraform code

```
terraform apply -auto-approve

#The previous command will create the eks cluster and the msql database. Next is to push an image to the ECR repository created. The url is in the terraform outputs
```


Install Docker and make ubuntu user docker owner. pls note this docker installation is for Ubuntu server 

```
sudo apt update
sudo apt install -y apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
echo "deb [arch=arm64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker ubuntu
sudo su - ubuntu

# Build the Java Application
```
 mvn install -q -Dmaven.test.skip=true
```

# build the image
docker build -t prophius-project-image .
```


Authenticate Docker to your ECR repository: run the command below

```
# aws ecr get-login-password --region <your-region> | docker login --username AWS --password-stdin <your-account-id>.dkr.ecr.<your-region>.amazonaws.com

aws ecr get-login-password --region us-west-2 | docker login --username AWS --password-stdin 166937434313.dkr.ecr.us-west-1.amazonaws.com

# Pls edit with desired aws region and account ID.s
```


Tag your docker image

```
#docker tag <your-image-name> <your-account-id>.dkr.ecr.<your-region>.amazonaws.com/<your-ecr-repository>:<your-tag>

docker tag prophius-project-image 166937434313.dkr.ecr.us-west-2.amazonaws.com/Prophius-Project-image:latest
```


Push the built docker image to amazon ECR. Pls note this ECR has been created with terraform

```
# docker push <your-account-id>.dkr.ecr.<your-region>.amazonaws.com/<your-ecr-repository>:<your-tag>

docker push 166937434313.dkr.ecr.us-west-2.amazonaws.com/Prophius-Project-image:latest
```


Configure kubectl 

```
aws eks --region us-west-2 update-kubeconfig --name Prophious-Project
```


Apply the applications configuration and pods

```

# Before you apply the application, Pls edit the deployment yaml file (sprinboot.yaml) to the appropriate image name. # Under the spec parameters for the pod, edit the image which is a child of containers to the appropriate image name copied from the ECR repository.
Also ensure to add the AWS account ID in the `service-account.yml` file to enable the OIDC connection for the EkS pods to connect to secrets manager and get secrets values from there.

#goto AWS console, under ecr and copy the image name
#edit the springboot.yaml file and under the spec for the pod, goto containers and paste the image name, then run the command below:
```

```
kubectl apply -f .
```

The kubenetes archtecture creates a service account and configures a service provider created by terraform. This is needed for the pods to safely get the database password and username from the secret manager.



Browse the deployed application by copying the url of the eks land balancer and browse on your local machine. ensure ingress rule is enable for port 80 which uses http protocol.


```
kubectl get all -o wide

# This command gives all information about the cluster and you can copy the load balancer url and browse on your local machine.
```

For cleanup to destroy all created infrastructure, run the following commands
 
```
terraform destroy -auto-approve
kubectl delete -f .
```
