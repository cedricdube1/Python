FROM registry.digi.is/bi-platform-apps/base-build-image/master/buildimage:latest

ENV PYTHONUNBUFFERED 0
ENV SQL_USERNAME null
ENV SQL_PASSWORD null
ENV KAFKA_USERNAME null
ENV KAFKA_PASSWORD null
ENV Kafka_Config null
ENV SEnt_Config null
ENV Read_Args null
ENV SQLServerProc_Config null
ENV Schedule_interval null
ENV Logging_Level null
 
ENV PATH=$PATH:/opt/mssql/bin
ENV PATH=$PATH:/opt/mssql-tools/bin   
    
WORKDIR /app 
COPY ["./app", "./."]

RUN pip install -r ./requirements.txt

USER 1000

ENTRYPOINT ["python", "main.py"]