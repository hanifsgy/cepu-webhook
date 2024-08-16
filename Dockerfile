FROM --platform=linux/amd64 public.ecr.aws/docker/library/swift:5.9.1-amazonlinux2 as builder
ARG TARGET_NAME

RUN yum -y install git jq tar zip openssl-devel
WORKDIR /build-lambda
RUN mkdir -p /Sources/$TARGET_NAME/
ADD /Sources/ ./Sources/
COPY Package.swift .
RUN cd /build-lambda && swift package clean && swift build -c release

# Copy Swift runtime libraries
RUN mkdir -p /lambda-package/lib
RUN cp /usr/lib/swift/linux/*.so /lambda-package/lib/
RUN cp /build-lambda/.build/release/$TARGET_NAME /lambda-package/

# image deplpoyed to AWS Lambda with your compiled executable
FROM public.ecr.aws/lambda/provided:al2-x86_64
ARG TARGET_NAME

RUN mkdir -p /var/task/lib/
COPY --from=builder /lambda-package/lib/ /var/task/lib/
COPY --from=builder /lambda-package/$TARGET_NAME /var/task/bootstrap

RUN chmod 755 /var/task/bootstrap
WORKDIR /var/task
CMD ["/var/task/bootstrap"]