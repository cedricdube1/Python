FROM registry.digi.is/bi-platform-apps/base-build-image/master/buildimage:latest

ENV PYTHONUNBUFFERED 0
ENV SQL_USERNAME null
ENV SQL_PASSWORD null
ENV SQLServer_Config null
ENV Schedule_interval null
ENV Logging_Level null
ENV timed_window null
ENV token null
ENV app_id null
 
ENV PATH=$PATH:/opt/mssql/bin
ENV PATH=$PATH:/opt/mssql-tools/bin   

WORKDIR /app 
COPY ["./app", "./."]

RUN pip install -r ./requirements.txt
USER 1000
ENTRYPOINT ["python", "main.py"]