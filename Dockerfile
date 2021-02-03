FROM python:3.9-alpine

RUN apk add --no-cache --update bash curl jq

COPY bin/* /usr/local/bin/
COPY lib/* /usr/local/lib/
