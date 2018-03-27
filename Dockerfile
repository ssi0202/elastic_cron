FROM alpine

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
RUN apk --no-cache add python py-setuptools py-pip gcc libffi py-cffi python-dev libffi-dev py-openssl musl-dev linux-headers openssl-dev libssl1.0 && \
    pip install elasticsearch-curator==5.5.0 && \
    pip install boto3==1.4.8 && \
    pip install requests-aws4auth==0.9 && \
    pip install cryptography==2.1.3 && \
    apk del py-pip gcc python-dev libffi-dev musl-dev linux-headers openssl-dev && \
    sed -i '/import sys/a urllib3.contrib.pyopenssl.inject_into_urllib3()' /usr/bin/curator && \
    sed -i '/import sys/a import urllib3.contrib.pyopenssl' /usr/bin/curator && \
    sed -i '/import sys/a import urllib3' /usr/bin/curator
    
RUN touch /var/log/cron.log
RUN chmod 766 /var/log/cron.log
USER cron
STOPSIGNAL SIGTERM

CMD cron && tail -f /var/log/cron.log
