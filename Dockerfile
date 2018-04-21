FROM alpine:latest
MAINTAINER Justin Henderson justin@hasecuritysolutions.com

ENV APP_USER appuser

RUN adduser -g "Elastic Cron" -D elastic-cron

RUN touch /var/spool/cron/crontabs/elastic-cron
RUN chmod 0600 /var/spool/cron/crontabs/elastic-cron

ENTRYPOINT "crond"

CMD ["-f", "-d", "8"]
