#!/bin/bash
set -eu

swift build -c release
mkdir -p .build/lambda/cepu-webhook
cp .build/release/cepu-webhook .build/lambda/cepu-webhook/bootstrap
cd .build/lambda/cepu-webhook
zip -j lambda.zip bootstrap
cd ../../../

echo "Lambda package created at .build/lambda/cepu-webhook/lambda.zip"