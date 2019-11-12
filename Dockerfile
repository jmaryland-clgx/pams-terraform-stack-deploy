FROM ubuntu:18.04

RUN apt-get update \
    && apt-get upgrade -y \
    && rm -rf /var/lib/apt/lists/*

COPY --from=hashicorp/terraform:0.11.14 /bin/terraform /bin/terraform
RUN terraform version
