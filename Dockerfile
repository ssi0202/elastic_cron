FROM ubuntu:latest
MAINTAINER justin@hasecuritysolutions.com

# Alias, DNS or IP of Elasticsearch host to be queried by Elastalert. Set in default Elasticsearch configuration file.
ENV ELASTICSEARCH_HOST elasticsearch
# Port on above Elasticsearch host. Set in default Elasticsearch configuration file.
ENV ELASTICSEARCH_PORT 9200
# Use TLS to connect to Elasticsearch (True or False)
ENV ELASTICSEARCH_TLS False
# Verify TLS
ENV ELASTICSEARCH_TLS_VERIFY True
# Use authentication to connect to Elasticsearch (True or False)
ENV ELASTICSEARCH_AUTH False
# Elasticsearch username if required
ENV ELASTALERT_USER elastic
# Elasticsearch password if required
ENV ELASTALERT_USER changeme

# based on bobrik/docker-curator docker image
RUN apt-get update
RUN apt-get dist-upgrade -y
RUN apt-get install python-pip
RUN pip install elasticsearch-curator
RUN pip install requests-aws4auth
ADD crontab /etc/cron.d/elastic-cron
RUN touch /var/log/cron.log
RUN useradd -ms /bin/bash cron
RUN chown cron:cron /var/log/cron.log
RUN chmod 0644 /var/log/cron.log
RUN apt autoremove -y
RUN apt clean -y
USER cron
STOPSIGNAL SIGTERM

CMD cron && tail -f /var/log/cron.log
