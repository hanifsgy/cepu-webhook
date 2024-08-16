# Xcode Cloud Webhook 

## Requirements
- Swift 5.10 (on local Xcode 15.4)
- Swift 5.7 (on AWS Lambda), since the AWS Lambda Runtime for Swift requires this version

## Usage
- 

## Deployment

### Local Development

to build on docker local
docker build -t cepu-webhook .

```sh
➜  webhook-xcode-cloud git:(master) ✗ docker create --name temp_container cepu-webhook:latest 
WARNING: The requested image's platform (linux/amd64) does not match the detected host platform (linux/arm64/v8) and no specific platform was requested
b2437821c412a1ad7ddc04d7e5c7eccdf940333f484985c5731e895acf48bb0b
➜  webhook-xcode-cloud git:(master) ✗ docker cp temp_container:/var/task/bootstrap ./bootstrap
➜  webhook-xcode-cloud git:(master) ✗ docker rm temp_container                                
temp_container
➜  webhook-xcode-cloud git:(master) ✗ zip -j function.zip bootstrap                           
updating: bootstrap (deflated 66%)
➜  webhook-xcode-cloud git:(master) ✗ rm bootstrap                                            
➜  webhook-xcode-cloud git:(master) ✗                                                                               
```

for updating lambda function deployment
aws lambda update-function-code --function-name cepu-webhook --zip-file fileb://function.zip --region ap-southeast-1
