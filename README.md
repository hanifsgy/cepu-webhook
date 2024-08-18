# Xcode Cloud Webhook, App Store Connect API Demo

The goals in this repository are:
- to build a lambda function, that can be triggered by Xcode Cloud webhook
- to use App Store Connect API, to read the build information
- invoke Gitlab CI/CD API, to trigger a build   

## Requirements
- Swift 5.10 (on local Xcode 15.4)
- Swift 5.7 (on AWS Lambda), since the AWS Lambda Runtime for Swift requires this version
- Docker 
- AWS CLI
- Gitlab CI/CD

## Local Development

- to build on Docker image local
```sh
docker build -t cepu-webhook .
```
- to run local lambda server

```sh
swift run --env LOCAL_LAMBDA_SERVER_ENABLED=true
```

- to test the lambda functions, using RIE [link](https://github.com/aws/aws-lambda-runtime-interface-emulator#test-an-image-with-rie-included-in-the-image)

- Invoke the lambda function, with the JSON files as an input 

```sh
curl -X POST "http://localhost:9000/2015-03-31/functions/function/invocations" -d @input.json
```

the Input JSON, for lambda function can be found in [link](https://docs.aws.amazon.com/lambda/latest/dg/services-apigateway.html#apigateway-example-event). You may need to modified the input JSON, and add the `body` field for example. The `body` field is the JSON body of the request from Xcode Cloud. References: [link](https://github.com/aws/aws-lambda-runtime-interface-emulator#test-an-image-with-rie-included-in-the-image)

## Deployment

- Build the docker image 
```sh 
docker build -t cepu-webhook:latest .  
```

- Create container 
```sh
docker create --name lambda-container cepu-webhook:latest
```

- Copy the bootstrap file from container to local
```sh
docker cp lambda-container:/var/task/bootstrap ./bootstrap
```

- Zip the bootstrap file
```sh
zip -j cepu-webhook.zip bootstrap
``` 

- Clean the container 
```sh
docker rm lambda-container
```

- Updating lambda function deployment
```sh
aws lambda update-function-code --function-name cepu-webhook --zip-file fileb://cepu-webhook.zip --region ap-southeast-1
```


## Good References
- https://github.com/swift-server/swift-aws-lambda-runtime 
- https://fabianfett.dev/getting-started-with-swift-aws-lambda-runtime 
- https://github.com/aws/aws-lambda-runtime-interface-emulator 
- https://developer.apple.com/documentation/appstoreconnectapi/read_xcode_cloud_artifact_information
- https://github.com/apple/appstoreconnect-swift-sdk    