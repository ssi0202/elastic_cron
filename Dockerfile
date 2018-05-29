FROM ubuntu:16.04
MAINTAINER justin@hasecuritysolutions.com

# Alias, DNS or IP of Elasticsearch host to be queried by Elastalert. Set in default Elasticsearch configuration file.
ENV ELASTICSEARCH_HOST elasticsearch
# Port Elasticsearch runs on
ENV ELASTICSEARCH_PORT 9200
# Folder where Elasticsearch index templates are stored
ENV ELASTICSEARCH_INDEX_TEMPLATES /opt/elastic_stack/elasticsearch/index_templates/
# Folder with OPTIONAL sample data to load. File format is indexname.json
# You may use index-DATEFORMAT if you like, but these may end up getting purged
ENV SAMPLE_INDEX_FOLDER /opt/elastic_stack/elasticsearch/sample_indices/
# Alias, DNS or IP of Logstash host. Used for ingesting sample indices
ENV LOGSTASH_HOST logstash
# Port Elasticsearch runs on
ENV LOGSTASH_JSON_PORT 60000

# Create the log file to be able to run tail
RUN touch /var/log/cron.log \
    && apt-get update \
    && apt-get -y install cron python-pip curl wget apt-transport-https netcat \
    && pip install elasticsearch-curator \
    && pip install requests-aws4auth \
    && useradd -ms /bin/bash elastic-cron \
    && touch /etc/cron.d/elastic-cron \
    && mkdir /home/elastic-cron/logs \
    && curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - \
    && curl -o /etc/apt/sources.list.d/microsoft.list https://packages.microsoft.com/config/ubuntu/16.04/prod.list \
    && apt-get update \
    && apt-get install -y powershell
COPY ./entrypoint.sh /opt/
RUN chmod +x /opt/entrypoint.sh

# Run the command on container startup
CMD /bin/bash /opt/entrypoint.sh
