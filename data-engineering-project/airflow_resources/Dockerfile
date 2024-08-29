FROM artifactory.tools1-az1.digi.is/epea-docker-pull/apache/airflow:2.9.3

USER root

COPY ./certs/*.crt /usr/local/share/ca-certificates/
COPY ./certs/*.pem /usr/local/share/ca-certificates/

RUN update-ca-certificates

RUN sed -i 's/DEFAULT@SECLEVEL=2/DEFAULT@SECLEVEL=1/g' /etc/ssl/openssl.cnf
RUN sed -i 's/MinProtocol = TLSv1.2/MinProtocol = TLSv1/g' /etc/ssl/openssl.cnf
RUN sed -i 's/DEFAULT@SECLEVEL=2/DEFAULT@SECLEVEL=1/g' /usr/lib/ssl/openssl.cnf
RUN sed -i 's/MinProtocol = TLSv1.2/MinProtocol = TLSv1/g' /usr/lib/ssl/openssl.cnf

USER airflow

RUN pip install --trusted-host pypi.org --trusted-host files.pythonhosted.org --no-cache-dir "apache-airflow==${AIRFLOW_VERSION}" kafka_python==2.0.2 kafka-python-ng psycopg2-binary==2.9.9 pyspark==3.5.1 unidecode==1.3.8
RUN pip install --trusted-host pypi.org --trusted-host files.pythonhosted.org ndg-httpsclient
RUN pip install --trusted-host pypi.org --trusted-host files.pythonhosted.org pyopenssl
RUN pip install --trusted-host pypi.org --trusted-host files.pythonhosted.org pyasn1
