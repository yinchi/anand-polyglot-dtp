# Aliases for connecting to various services in the anand-dtp-docker setup

pg() {
    # Connect to PostgreSQL database using pgcli
    source $HOME/anand-dtp-docker/.env
    pgcli "postgresql://${PGUSER}:${PGPASSWORD}@localhost:${PGPORT:-5432}/${PGDATABASE}" "$@"
}

neo4j() {
    # Connect to Neo4j database using cypher-shell
    source $HOME/anand-dtp-docker/.env
    docker exec -it neo4j cypher-shell -u neo4j -p ${NEO4J_PASSWORD} -d neo4j "$@"
}

influx() {
    # Connect to InfluxDB using influx CLI
    docker exec -it influx influx "$@"
}

influx_config() {
    # Set up InfluxDB configuration, note this calls influx() as defined above,
    # thus `docker exec...`
    source $HOME/anand-dtp-docker/.env
    influx config create --config-name dtp --host-url http://localhost:${INFLUX_PORT:-8086} \
        --org ${INFLUX_ORG} --token ${INFLUX_TOKEN} || true
    influx config set --config-name dtp --active
}

mqtt_sub() {
    # Subscribe to MQTT topic using mosquitto_sub
    source $HOME/anand-dtp-docker/.env
    mosquitto_sub -h localhost -p ${MQTT_PORT:-1883} "$@"
}

mqtt_pub() {
    # Publish to MQTT topic using mosquitto_pub
    source $HOME/anand-dtp-docker/.env
    mosquitto_pub -h localhost -p ${MQTT_PORT:-1883} "$@"
}
