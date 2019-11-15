ARG terraform_version=light
FROM hashicorp/terraform:$terraform_version

ENTRYPOINT [ "/bin/sh", "-c" ]

# Need git and ssh for terraform init from jenkins
RUN apk --no-cache add --update \
    git \
    openssh
