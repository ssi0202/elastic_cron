FROM ubuntu:latest
MAINTAINER justin@hasecuritysolutions.com


# Create the log file to be able to run tail
RUN touch /var/log/cron.log

#Install Cron
RUN apt-get update
RUN apt-get -y install cron python-pip
RUN pip install elasticsearch-curator
RUN pip install requests-aws4auth

# Create low privilege user
RUN useradd -ms /bin/bash elastic-cron
# Add crontab file in the cron directory
#COPY crontab /etc/cron.d/elastic-cron
RUN touch /etc/cron.d/elastic-cron

# Give execution rights on the cron job
RUN chmod 0755 /etc/cron.d/elastic-cron

RUN mkdir /home/elastic-cron/logs

# Run the command on container startup
CMD chown root:root /etc/cron.d/elastic-cron && chmod 0755 /etc/cron.d/elastic-cron && chown -R elastic-cron:elastic-cron /home/elastic-cron/logs && /usr/sbin/cron -f
