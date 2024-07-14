# How to Run Tests Locally

Ensure you have NodeJs installed on your system
Then run the command:

```bash 
  npm run test
```

# How to Run the Application Locally Using Docker

Ensure you are at the root of the repository
Ensure you have Docker daemon running
Then run the commands below:
```bash 
  docker build -t prismajs .
```

```bash 
  docker run -p 3000:3000 prismajs
```
The application is now up and running on port 3000. 
You can test this by entering localhost:3000 in your browser.

# To Deploy the Application

Ensure you have Terraform installed on your system.  
Confirm you are at the root of the repository.  

Then run:  
```bash 
    cd terraform
    terraform init
    terraform plan
    terraform apply -auto-approve
```
