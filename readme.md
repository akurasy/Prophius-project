# Prophisous Project

This project, comprise of an EKS cluster and RDS MySQL Database deployed on AWS incorporated with AWS networking best practices and security practices when deploying this. The project performs the entire process using Terraform to automate the process of creating the resources. 

![Alt text](./readmeimg/image.png)

The image above is a perfect representation of the architecture and process I used when deploying the architecture. The application is a simple CRUD application written in JAVA. The CRUD activities is being performed on the MySQL database. 

To deploy this application, ensure that you have AWS CLI and Terraform installed on the host machine. Follow the steps below to deploy the application.

1. Navigate to the Terraform directory

```
cd terraform
```

2. Initialize terraform

```
terraform init
```

3. Apply Terraform code

```
terraform apply -auto-approve

#The previous command will create the eks cluster and the msql database. Next is to push an image to the ECR repository created. The url is in the terraform outputs
```


5. Install Docker and make ubuntu user docker owner. pls note this docker installation is for Ubuntu server 

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

# build the image
docker build -t <ecr-image> .
```

6. Configure kubectl 

```
aws eks --region us-west-2 update-kubeconfig --name Prophious-Project
```

Apply the applications configuration and pods

```
kubectl apply -f .
```

The kubenetes archtecture creates a service account and configures a service provider created by terraform. This is needed for the pods to safely get the database password and username from the secret manager.
