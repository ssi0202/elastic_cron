#!/bin/bash
until $(curl -s --output /dev/null --silent --head --fail http://$ELASTICSEARCH_HOST:$ELASTICSEARCH_PORT); do echo "Waiting for Elasticsearch to be online"; sleep 5; done

if [ -d "$ELASTICSEARCH_INDEX_TEMPLATES" ]; then
  cd $ELASTICSEARCH_INDEX_TEMPLATES
  for template in *.json
  do
    NAME=$(echo $template | cut -d"." -f1)
    EXISTS=$(curl -s -I "$ELASTICSEARCH_HOST:$ELASTICSEARCH_PORT/_template/$NAME" -H 'Content-Type: application/json' | head -n1)
    if [[ $EXISTS == *"404"* ]]; then
      curl -s -X PUT "$ELASTICSEARCH_HOST:$ELASTICSEARCH_PORT/_template/$NAME" -H 'Content-Type: application/json' -d @$template
    fi
    if [[ $EXISTS == *"200"* ]]; then
      ES_VERSION=$(curl -s -X GET "$ELASTICSEARCH_HOST:$ELASTICSEARCH_PORT/_template/$NAME?filter_path=*.version" -H 'Content-Type: application/json' | sed 's/[^0-9]*//g')
      FILE_VERSION=$(cat $template | grep '"version": ' | sed 's/[^0-9]*//g')
      if [[ "$ES_VERSION" != "$FILE_VERSION" ]]; then
        echo "Template version of $NAME does not match - Updating"
        curl -s -X PUT "$ELASTICSEARCH_HOST:$ELASTICSEARCH_PORT/_template/$NAME" -H 'Content-Type: application/json' -d @$template
      fi
    fi
  done
fi

if [ -d "$SAMPLE_INDEX_FOLDER" ]; then
  cd $SAMPLE_INDEX_FOLDER
  for logs in *.json
  do
    NAME=$(echo $logs | cut -d"." -f1)
    EXISTS=$(curl -s -I "$ELASTICSEARCH_HOST:$ELASTICSEARCH_PORT/$NAME" -H 'Content-Type: application/json')
    if [[ $EXISTS == *"404"* ]]; then
      echo "Index $NAME does not exist. Creating..."
      nc logstash 60000 -q1 < $logs
    fi
    if [[ $EXISTS == *"200"* ]]; then
      echo "Index $NAME already exists"
    fi
  done
fi

chown root:root /etc/cron.d/*
chmod 0755 /etc/cron.d/*
chown -R elastic-cron:elastic-cron /home/elastic-cron/logs
/usr/sbin/cron -f
