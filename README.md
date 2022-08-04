## Docker Compose Up
docker compose up -d

## Generate Password ELK
docker-compose exec elasticsearch bin/elasticsearch-reset-password --batch --user elastic
docker-compose exec elasticsearch bin/elasticsearch-reset-password --batch --user logstash_internal
docker-compose exec elasticsearch bin/elasticsearch-reset-password --batch --user kibana_system

Save result to .env

