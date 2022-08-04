## Docker Compose Up
docker compose up -d

## Generate Password ELK
docker-compose exec elasticsearch bin/elasticsearch-reset-password --batch --user elastic <br>
docker-compose exec elasticsearch bin/elasticsearch-reset-password --batch --user logstash_internal <br>
docker-compose exec elasticsearch bin/elasticsearch-reset-password --batch --user kibana_system <br>

Save result to .env

