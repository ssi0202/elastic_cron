FROM ubuntu:16.04
MAINTAINER justin@hasecuritysolutions.com

# Create the log file to be able to run tail
RUN touch /var/log/cron.log \
    && apt-get update \
    && apt-get -y install cron python-pip curl wget apt-transport-https \
    && pip install elasticsearch-curator \
    && pip install requests-aws4auth \
    && useradd -ms /bin/bash elastic-cron \
    && touch /etc/cron.d/elastic-cron \
    && mkdir /home/elastic-cron/logs \
    && curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - \
    && curl -o /etc/apt/sources.list.d/microsoft.list https://packages.microsoft.com/config/ubuntu/16.04/prod.list \
    && apt-get update \
    && apt-get install -y powershell

# Run the command on container startup
CMD chown root:root /etc/cron.d/* && chmod 0755 /etc/cron.d/* && chown -R elastic-cron:elastic-cron /home/elastic-cron/logs && /usr/sbin/cron -f
