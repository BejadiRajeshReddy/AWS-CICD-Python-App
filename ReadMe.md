Nice, this is a solid CI project 👍
Here’s a **clean, professional README.md** you can directly put in your GitHub repo.

You can copy–paste this as-is.

---

# 🚀 AWS CodeBuild CI Pipeline for Python Flask App (Docker Hub)

This project demonstrates how to implement a **Continuous Integration (CI) pipeline** for a **Python Flask application** using **AWS CodeBuild**, where the Docker image is built and pushed to **Docker Hub** automatically on every GitHub push.

---

## 🛠 Tech Stack

- **Python (Flask)**
- **Docker**
- **AWS CodeBuild**
- **AWS Systems Manager (SSM Parameter Store)**
- **GitHub**
- **Docker Hub**

---

## 📌 CI Architecture

```
GitHub → AWS CodeBuild → Docker Build → Docker Hub
```

---

## 📂 Project Structure

```
AWS-CICD-Python-App/
├── app.py
├── requirements.txt
├── Dockerfile
├── buildspec.yml
└── README.md
```

---

## 🧩 Application Overview

A simple Flask web application that returns a greeting message when accessed.

### Endpoint

```
GET /
```

### Response

```
Hello from Docker Hub CI 🚀
```

---

## 🐍 Flask App (`app.py`)

```python
from flask import Flask

app = Flask(__name__)

@app.route("/")
def home():
    return "Hello from Docker Hub CI 🚀"

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
```

---

## 📦 Dockerfile

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

## ⚙️ CI Configuration (`buildspec.yml`)

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
      - echo "Build completed successfully"
```

---

## 🔐 Secure Credentials (SSM Parameter Store)

Docker Hub credentials are stored securely using **AWS SSM Parameter Store**.

### Parameters Used

| Parameter Name        | Type         |
| --------------------- | ------------ |
| `/dockerhub/username` | String       |
| `/dockerhub/password` | SecureString |

---

## 🔑 CodeBuild Environment Variables

| Name                 | Type            | Value                 |
| -------------------- | --------------- | --------------------- |
| `DOCKERHUB_USERNAME` | Parameter Store | `/dockerhub/username` |
| `DOCKERHUB_PASSWORD` | Parameter Store | `/dockerhub/password` |

---

## 🧑‍💻 IAM Permissions (CodeBuild Role)

Required permissions for CodeBuild service role:

Give CodeBuild permission to read SSM parameters

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
      "Resource": "arn:aws:ssm:us-east-1:407688391841:parameter/*"
    }
  ]
}
```

### Steps to Attach

1. Navigate to **IAM → Roles**
2. Open `codebuild-PythonApp-service-role`
3. Click **Add inline policy** or give
4. Paste the JSON policy above
5. Save and confirm

This allows CodeBuild to retrieve Docker Hub credentials from SSM Parameter Store.

---

## 🔄 CI Workflow

1. Developer pushes code to GitHub
2. GitHub triggers AWS CodeBuild
3. CodeBuild:

   - Fetches source code
   - Retrieves secrets from SSM
   - Builds Docker image
   - Pushes image to Docker Hub

4. Build completes successfully ✅

---

## 📦 Docker Image

Docker Hub Repository:

```
docker.io/rajeshreddy0/simple-python-flask-app:latest
```

### Run Locally

```bash
docker pull rajeshreddy0/simple-python-flask-app:latest
docker run -p 5000:5000 rajeshreddy0/simple-python-flask-app
```

Access:

```
http://localhost:5000
```

---

<img width="1117" height="494" alt="image" src="https://github.com/user-attachments/assets/530838e2-d180-462d-aaf8-5f3534d6d520" />
<img width="1919" height="398" alt="Screenshot 2025-12-19 122920" src="https://github.com/user-attachments/assets/9da3d16a-9260-4f15-b163-ca57e046176a" />
<img width="1919" height="539" alt="Screenshot 2025-12-19 123000" src="https://github.com/user-attachments/assets/4de20558-59a4-4b4c-a53e-fa23e955a0bc" />
<img width="1144" height="663" alt="Screenshot 2025-12-19 123015" src="https://github.com/user-attachments/assets/7aacb336-2194-4af2-acea-d188582d6b95" />


---

## 👤 Author

**Rajesh Reddy Bejadi**
DevOps / Cloud Enthusiast ☁️🚀
