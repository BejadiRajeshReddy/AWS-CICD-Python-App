# 🚀 End-to-End CI/CD Pipeline for Python Flask App using AWS CodePipeline

This project demonstrates a **complete end-to-end CI/CD pipeline** for a **Dockerized Python Flask application** using **AWS native services**.

The pipeline is divided into **two clear phases**:

* **CI (Continuous Integration)** – Build & push Docker image
* **CD (Continuous Deployment)** – Deploy image to EC2

---

## 🧱 Tech Stack

* Python (Flask)
* Docker
* GitHub
* AWS CodePipeline
* AWS CodeBuild
* AWS CodeDeploy
* AWS EC2 (Ubuntu)
* AWS SSM Parameter Store
* Docker Hub

---

## 🏗 High-Level Architecture

```
GitHub
   ↓
AWS CodePipeline
   ↓
AWS CodeBuild (CI)
   ↓
Docker Hub
   ↓
AWS CodeDeploy (CD)
   ↓
EC2 Instance (Docker Runtime)
```

---

## 📂 Project Structure

```
AWS-CICD-Python-App/
├── app.py
├── requirements.txt
├── Dockerfile
├── buildspec.yml        # CI instructions
├── appspec.yml          # CD instructions
├── scripts/
│   └── start_container.sh
└── README.md
```

---

# 🧩 STEP 1: Application Code

## Flask Application (`app.py`)

```python
from flask import Flask

app = Flask(__name__)

@app.route("/")
def home():
    return "Hello from AWS CI/CD Pipeline 🚀"

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
```

---

## Docker Configuration (`Dockerfile`)

```dockerfile
FROM python:3.10-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

EXPOSE 5000

CMD ["python", "app.py"]
```

---

# 🔁 STEP 2: Continuous Integration (CI)

### CI is responsible for:

* Building Docker image
* Pushing image to Docker Hub

---

## CI Tool: AWS CodeBuild (Triggered by CodePipeline)

### `buildspec.yml`

```yaml
version: 0.2

env:
  variables:
    IMAGE_NAME: simple-python-flask-app
    IMAGE_TAG: latest

phases:
  pre_build:
    commands:
      - echo "Logging in to Docker Hub"
      - echo "$DOCKERHUB_PASSWORD" | docker login -u "$DOCKERHUB_USERNAME" --password-stdin

  build:
    commands:
      - echo "Building Docker image"
      - docker build -t $DOCKERHUB_USERNAME/$IMAGE_NAME:$IMAGE_TAG .

  post_build:
    commands:
      - echo "Pushing image to Docker Hub"
      - docker push $DOCKERHUB_USERNAME/$IMAGE_NAME:$IMAGE_TAG
```

---

## 🔐 CI Secrets Management (SSM Parameter Store)

Docker Hub credentials are stored securely in **AWS SSM Parameter Store**.

| Parameter Name        | Type         |
| --------------------- | ------------ |
| `/dockerhub/username` | String       |
| `/dockerhub/password` | SecureString |

### CodeBuild Environment Variables

| Name               | Type            | Value                 |
| ------------------ | --------------- | --------------------- |
| DOCKERHUB_USERNAME | Parameter Store | `/dockerhub/username` |
| DOCKERHUB_PASSWORD | Parameter Store | `/dockerhub/password` |

---
## 🟩 STEP 1: IAM Role for AWS CodePipeline

### 🔹 Role Name

```
AWSCodePipelineServiceRole
```

### 🔹 How to Create

1. Go to **IAM → Roles → Create role**
2. Trusted entity → **AWS service**
3. Service → **CodePipeline**
4. Click **Next**

### 🔹 Permissions

Attach managed policy:

```
AWSCodePipelineFullAccess
```

### 🔹 Purpose

- Pulls source from GitHub
- Triggers CodeBuild
- Triggers CodeDeploy

---

## 🟦 STEP 2: IAM Role for AWS CodeBuild (CI Role)

### 🔹 Role Name

```
codebuild-PythonApp-service-role
```

### 🔹 How to Create

1. IAM → Roles → Create role
2. Trusted entity → **AWS service**
3. Service → **CodeBuild**
4. Click **Next**

---

### 🔹 Attach Managed Policies

Attach:

```
CloudWatchLogsFullAccess
AmazonS3ReadOnlyAccess
```

---

### 🔹 Add Inline Policy (SSM Access – REQUIRED)

This allows CodeBuild to read Docker Hub credentials.

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ssm:GetParameter",
        "ssm:GetParameters",
        "ssm:GetParametersByPath"
      ],
      "Resource": "arn:aws:ssm:*:*:parameter/dockerhub/*"
    }
  ]
}
```

### 🔹 Why this role is needed

- Reads secrets from **SSM Parameter Store**
- Logs into **Docker Hub**
- Builds Docker image
- Pushes image to Docker Hub

---

## 🟨 STEP 3: IAM Role for AWS CodeDeploy (Service Role)

### 🔹 Role Name

```
CodeDeployServiceRole
```

### 🔹 How to Create

1. IAM → Roles → Create role
2. Trusted entity → **AWS service**
3. Service → **CodeDeploy**
4. Click **Next**

---

### 🔹 Attach Managed Policy

```
AWSCodeDeployRole
```

### 🔹 Purpose

- Identifies EC2 instances using tags
- Executes deployment lifecycle hooks
- Coordinates deployments

---

## 🟧 STEP 4: IAM Role for EC2 Instance

### 🔹 Role Name

```
EC2-CodeDeploy-Role
```

### 🔹 How to Create

1. IAM → Roles → Create role
2. Trusted entity → **AWS service**
3. Service → **EC2**
4. Click **Next**

---

### 🔹 Attach Managed Policy

```
AmazonEC2RoleforAWSCodeDeploy
```

### 🔹 Attach Role to EC2

1. Go to **EC2 → Instances**
2. Select instance
3. Actions → Security → Modify IAM role
4. Attach:

```
EC2-CodeDeploy-Role
```

### 🔹 Purpose

- Allows CodeDeploy agent to:
    - Communicate with AWS
    - Download artifacts
    - Report deployment status


---

### ✅ CI Result

After CI completes successfully:

* Docker image is available in **Docker Hub**
* Image tag: `latest`

---

# 🚀 STEP 3: Continuous Deployment (CD)

### CD is responsible for:

* Pulling Docker image
* Running container on EC2
* Replacing old container with new one

---

## Deployment Target

* **EC2 Ubuntu instance**
* Docker installed
* CodeDeploy Agent running
* Tagged for deployment

---

## 🐳 Docker Installation on EC2 (Ubuntu)

```bash
sudo apt update -y
sudo apt install docker.io -y
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker ubuntu
newgrp docker
```

---

## 🧩 CodeDeploy Agent Installation (Ubuntu)

```bash
sudo apt update -y
sudo apt install ruby-full wget -y
cd /home/ubuntu

wget https://aws-codedeploy-us-east-2.s3.us-east-2.amazonaws.com/latest/install
chmod +x install
sudo ./install auto

sudo systemctl start codedeploy-agent
sudo systemctl status codedeploy-agent
```

---

## 📄 CodeDeploy Configuration (`appspec.yml`)

```yaml
version: 0.0
os: linux

files:
  - source: /
    destination: /home/ubuntu/flask-app

hooks:
  ApplicationStart:
    - location: scripts/start_container.sh
      timeout: 300
      runas: ubuntu
```

---

## ▶️ Deployment Script (`start_container.sh`)

```bash
#!/bin/bash

docker stop flask-app || true
docker rm flask-app || true

docker pull rajeshreddy0/simple-python-flask-app:latest || exit 1

docker run -d --name flask-app -p 5000:5000 rajeshreddy0/simple-python-flask-app:latest


```

---

## 🔄 STEP 4: AWS CodePipeline (Orchestration)

### Pipeline Stages

1. **Source**

   * GitHub (auto trigger on push)

2. **Build**

   * AWS CodeBuild (CI)

3. **Deploy**

   * AWS CodeDeploy (CD)

---

## 🌐 Application Access

```
http://<EC2-PUBLIC-IP>:5000
```
![alt text](<Screenshot 2025-12-19 124249.png>)

![alt text](<Screenshot 2025-12-19 205918.png>)