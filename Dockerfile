FROM alpine:3.6

ENV INTERVAL_IN_HOURS=12

RUN apk update && apk add \
      bash \
      curl \
      python \
      py-pip && \
      pip install --upgrade pip awscli

ADD https://bin.equinox.io/c/ekMN3bCZFUn/forego-stable-linux-amd64.tgz /forego.tgz
RUN cd /usr/local/bin && tar xfz /forego.tgz && chmod +x /usr/local/bin/forego && rm /forego.tgz

WORKDIR /opt

RUN echo $'#!/bin/bash\n\
\n\
set -e \n\
while true; do\n\
  aws s3 sync $DATA_FOLDER/ s3://$S3_BUCKET/ \n\
  sleep $(( 60*60*INTERVAL_IN_HOURS ))\n\
done' > s3.sh && chmod +x s3.sh

RUN echo 's3: /opt/s3.sh' >> Procfile

CMD [ "forego", "start" ]