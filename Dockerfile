FROM alpine:latest

RUN apk --update --no-cache add git --upgrade bash

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
