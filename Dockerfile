FROM centos:latest
MAINTAINER Justin Henderson justin@hasecuritysolutions.com

RUN touch /var/log/cron.log
RUN chmod 766 /var/log/cron.log
USER cron
STOPSIGNAL SIGTERM

CMD cron && tail -f /var/log/cron.log
