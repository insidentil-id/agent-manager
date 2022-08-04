## Git Clone
git clone https://github.com/insidentil-id/agent-manager.git <br>
cd agent-manager <br>
cp .env.example .env <br>

## Docker Compose Up
docker compose up -d <br>

## Generate Password ELK
### 1) Change Elastic Password
docker-compose exec elasticsearch bin/elasticsearch-reset-password --batch --user elastic <br>
### 2) Change Logstash Password
docker-compose exec elasticsearch bin/elasticsearch-reset-password --batch --user logstash_internal <br>
### 3) Change Kibana Password
docker-compose exec elasticsearch bin/elasticsearch-reset-password --batch --user kibana_system <br>

Save result to .env file<br>
ELASTIC_PASSWORD='Result Output 1) Change Elastic Password'<br>
LOGSTASH_INTERNAL_PASSWORD='Result Output 2) Change Logstash Password'<br>
KIBANA_SYSTEM_PASSWORD='Result Output 3) Change Kibana Password'<br><br>

Example:<br>
ELASTIC_PASSWORD='jfsjgjrsiuu3pr3'<br>
LOGSTASH_INTERNAL_PASSWORD='98t3jajfafaiuf9'<br>
KIBANA_SYSTEM_PASSWORD='jaffawufa8afek'<br>
