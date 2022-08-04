## Git Clone
git clone https://github.com/insidentil-id/agent-manager.git <br>
cd agent-manager <br>
cp .env.example .env <br>

## Docker Compose Up
docker compose up -d <br>

## Generate Password ELK
docker-compose exec elasticsearch bin/elasticsearch-reset-password --batch --user elastic <br>
docker-compose exec elasticsearch bin/elasticsearch-reset-password --batch --user logstash_internal <br>
docker-compose exec elasticsearch bin/elasticsearch-reset-password --batch --user kibana_system <br>

Save result to .env file

