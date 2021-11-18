#FROM python:3.9-alpine

#RUN apk add --no-cache --update bash curl jq

#COPY bin/* /usr/local/bin/
#COPY lib/* /usr/local/lib/

FROM mambaorg/micromamba:0.17.0 

COPY --chown=micromamba:micromamba test-env.yaml /tmp/env.yaml

RUN micromamba install -y -n base -f /tmp/env.yaml && \
     micromamba clean --all --yes

#RUN chmod a+w /usr/local/tests
