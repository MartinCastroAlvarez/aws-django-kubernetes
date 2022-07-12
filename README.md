# Django Kubernetes
Django app running on AWS EKS

![wallpaper](./wallpaper.jpeg)

## Instructions

### Create a new cluster
```bash
./bin/setup.sh \
    --cluster "concntric-eks-app" \
    --profile "concntric" \
    --application "concntric-be-app" \
    --namespace "production" \
    --private-subnets "subnet-a61c09df,subnet-6d8cbb26" \
    --public-subnets "subnet-8de778a6,subnet-a408ecf9" \
    --node-group "concntric-ng" \
    --pem-file "ConcntricEKS"
```

### Create a new environment
```bash
./bin/create.sh \
    --cluster "concntric-eks-app" \
    --profile "concntric" \
    --application "concntric-be-app" \
    --namespace "production" 
```

### Deploy to AWS EKS
```bash
./bin/apply.sh \
    --cluster "concntric-eks-app" \
    --profile "concntric" \
    --application "concntric-be-app" \
    --namespace "production" \
    --tag "production"
```

### Push a new build to AWS ECR
```bash
./bin/push.sh \
    --cluster "concntric-eks-app" \
    --profile "concntric" \
    --application "concntric-be-app" \
    --namespace "production" \
    --tag "production"
```

### Run Docker container locally
```bash
./bin/run.sh \
    --cluster "concntric-eks-app" \
    --profile "concntric" \
    --application "concntric-be-app" \
    --namespace "production" \
    --tag "production"
```

### Check the status of the deployment
```bash
./bin/status.sh \
    --cluster "concntric-eks-app" \
    --profile "concntric" \
    --application "concntric-be-app" \
    --namespace "production"
```

### SSH into one of the pods
```bash
./bin/shell.sh \
    --cluster "concntric-eks-app" \
    --profile "concntric" \
    --application "concntric-be-app" \
    --namespace "production"
```

### Destroy an environment
```bash
./bin/destroy.sh \
    --cluster "concntric-eks-app" \
    --profile "concntric" \
    --application "concntric-be-app" \
    --namespace "production" 
```
