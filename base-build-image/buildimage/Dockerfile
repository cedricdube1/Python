FROM python:3.7-slim

COPY ./certs/*.crt /usr/local/share/ca-certificates/
COPY ./certs/*.pem /usr/local/share/ca-certificates/
RUN update-ca-certificates

RUN sed -i 's/DEFAULT@SECLEVEL=2/DEFAULT@SECLEVEL=1/g' /etc/ssl/openssl.cnf
RUN sed -i 's/MinProtocol = TLSv1.2/MinProtocol = TLSv1/g' /etc/ssl/openssl.cnf
RUN sed -i 's/DEFAULT@SECLEVEL=2/DEFAULT@SECLEVEL=1/g' /usr/lib/ssl/openssl.cnf
RUN sed -i 's/MinProtocol = TLSv1.2/MinProtocol = TLSv1/g' /usr/lib/ssl/openssl.cnf
 
RUN apt-get update
RUN apt-get install -y curl 
RUN apt-get install -y apt-transport-https 
RUN apt-get install -y gnupg2
RUN apt-get install -y unixodbc unixodbc-dev
RUN apt-get update

RUN curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add -
RUN curl https://packages.microsoft.com/config/debian/9/prod.list > /etc/apt/sources.list.d/mssql-release.list
RUN apt-get update


RUN ACCEPT_EULA=Y apt-get install -y msodbcsql17 
RUN ACCEPT_EULA=Y apt-get install -y mssql-tools  

ENV PATH=$PATH:/opt/mssql/bin
ENV PATH=$PATH:/opt/mssql-tools/bin

RUN apt-get install -y gcc
RUN apt-get install -y build-essential
RUN apt-get install -y libssl-dev
RUN apt-get install -y libffi-dev
RUN apt-get install -y python3-lxml
RUN apt-get install -y python3-dev
RUN apt-get install -y python3-pip

RUN apt-get update -yqq \
    && apt-get install -y --no-install-recommends openssl \
    && sed -i -E 's/(CipherString\s*=\s*DEFAULT@SECLEVEL=)2/\11/' /etc/ssl/openssl.cnf \
    && rm -rf /var/lib/apt/lists/*
    
ENV PIP_TRUSTED_HOST=mitdgcproget.mitdgc.local
ENV PIP_INDEX_URL=http://mitdgcproget.mitdgc.local/pypi/Python/simple
ENV PIP_EXTRA_INDEX_URL=http://mitdgcproget.mitdgc.local/pypi/mitdgc-pypi/simple


WORKDIR /buildimage 
COPY ["./buildimage", "./."]

RUN pip install -r ./requirements.txt