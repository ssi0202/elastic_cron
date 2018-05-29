FROM ubuntu:16.04
MAINTAINER justin@hasecuritysolutions.com

# Alias, DNS or IP of Elasticsearch host to be queried by Elastalert. Set in default Elasticsearch configuration file.
ENV ELASTICSEARCH_HOST elasticsearch
# Port Elasticsearch runs on
ENV ELASTICSEARCH_PORT 9200
# Folder where Elasticsearch index templates are stored
ENV ELASTICSEARCH_INDEX_TEMPLATES /opt/elasticsearch/index_templates/
# Folder with OPTIONAL sample data to load. File format is indexname.json
# You may use index-DATEFORMAT if you like, but these may end up getting purged
ENV SAMPLE_INDEX_FOLDER /opt/elasticsearch/sample_indices/

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
