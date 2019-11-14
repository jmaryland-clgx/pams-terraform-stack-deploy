# cloudbees-jenkins-distribution is Debian based
FROM cloudbees/cloudbees-jenkins-distribution:latest

# Update base and install docker as root
USER root
RUN apt-get update \
    && apt-get upgrade -y \
    && rm -rf /var/lib/apt/lists/* \
    && curl -fsSL https://get.docker.com -o get-docker.sh \
    && sh get-docker.sh

# Reset user to default
USER cloudbees-jenkins-distribution
