FROM centos:latest

# Set this environment variable to True to set timezone on container start.
ENV SET_CONTAINER_TIMEZONE False
# Default container timezone as found under the directory /usr/share/zoneinfo/.
ENV CONTAINER_TIMEZONE America/Chicago
# Directory holding configuration for Curator
ENV CONFIG_DIR /etc/curator
# Curator configuration file path in configuration directory.
ENV CURATOR_CONFIG ${CONFIG_DIR}/config.yml
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
RUN yum -y update
RUN yum -y install crontabs
RUN curl "https://bootstrap.pypa.io/get-pip.py" -o "get-pip.py"
RUN python get-pip.py
RUN pip install elasticsearch-curator==5.5.1
RUN pip install boto3==1.4.8
RUN pip install requests-aws4auth
RUN pip install cryptography
RUN yum clean all
RUN rm -rf /var/cache/yum
    
RUN touch /var/log/cron.log
RUN chmod 766 /var/log/cron.log
USER cron
STOPSIGNAL SIGTERM

CMD cron && tail -f /var/log/cron.log
