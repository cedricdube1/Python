FROM artifactory.tools1-az1.digi.is/epea-docker-pull/bitnami/spark:3.5.1

WORKDIR /opt/bitnami/spark

RUN pip install --trusted-host pypi.org --trusted-host files.pythonhosted.org py4j kafka_python==2.0.2 psycopg2-binary==2.9.9 apache-airflow==2.9.3 pyspark==3.5.1 unidecode==1.3.8


COPY ./src/spark_pgsql/spark_streaming.py ./spark_streaming.py
COPY ./src/constants.py ./src/constants.py

ENV POSTGRES_DOCKER_USER=host.docker.internal
ARG POSTGRES_PASSWORD
ENV POSTGRES_PASSWORD=$POSTGRES_PASSWORD

