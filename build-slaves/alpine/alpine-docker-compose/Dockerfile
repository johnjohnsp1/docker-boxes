FROM inetsoftware/alpine-jenkins-base
LABEL maintainer contact@inetsoftware.de

# Tools
RUN apk add --update --no-cache docker py-pip \
    && pip install docker-compose

RUN apk add --update --no-cache nodejs \
    && npm install -g dockerfile-template
