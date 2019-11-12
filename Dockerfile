FROM ubuntu:18.04

RUN apt-get update \
    && apt-get upgrade -y \
    # ssh needed for credential passthrough
    # git needed for terraform pull
    && apt-get install -y ssh git \
    && rm -rf /var/lib/apt/lists/*

COPY --from=hashicorp/terraform:0.11.14 /bin/terraform /bin/terraform
RUN terraform version
