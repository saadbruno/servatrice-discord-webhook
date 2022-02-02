FROM alpine:3.7
RUN apk add --no-cache bash curl
RUN apk add --no-cache --upgrade grep

WORKDIR /app

COPY servatrice-discord-webhook.sh .
COPY ./lang ./lang

CMD ["bash", "-c", "WEBHOOK_URL=$WEBHOOK_URL SERVERLOG=./logs LANGUAGE=$LANGUAGE FOOTER=$FOOTER ./servatrice-discord-webhook.sh $WEBHOOK_URL"]