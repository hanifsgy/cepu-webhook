# Build image
FROM --platform=linux/amd64 swift:5.7-amazonlinux2 as builder
ARG TARGET_NAME=cepu-webhook

WORKDIR /build-lambda

# Install necessary dependencies
RUN yum -y install \
    git \
    jq \
    tar \
    zip \
    openssl-devel

# Copy Swift package manifest
COPY Package.swift .

# Copy source code
COPY Sources/ Sources/

# Build the Lambda function with static linking
RUN swift build --product "${TARGET_NAME}" -c release -Xswiftc -static-stdlib

# Copy Swift runtime libraries
RUN mkdir -p /lambda-package/lib
RUN cp /usr/lib/swift/linux/*.so /lambda-package/lib/

# Copy built executable
RUN cp /build-lambda/.build/release/$TARGET_NAME /lambda-package/bootstrap

# Runtime image
FROM --platform=linux/arm64 public.ecr.aws/lambda/provided:al2-arm64
ARG TARGET_NAME=cepu-webhook

# Copy Swift runtime libraries and bootstrap executable
COPY --from=builder /lambda-package/lib/* /var/task/lib/
COPY --from=builder /lambda-package/bootstrap /var/task/

# Set permissions and working directory
RUN chmod 755 /var/task/bootstrap
WORKDIR /var/task

# Set the CMD to your handler
CMD ["bootstrap"]