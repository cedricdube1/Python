import os
import json
import time
import logging
from components.pipelines.pipeline import Pipeline
from components.connectors.stores.sqlraptor import SQLServerProc
from components.connectors.streams.kafkaraptor import KafkaProducer
from components.processors.processor import ProducerProcessor
from datagate.components.utils import GracefulTerminator
from apscheduler.schedulers.background import BackgroundScheduler
from apscheduler.executors.pool import ThreadPoolExecutor, ProcessPoolExecutor
from apscheduler.events import (
    EVENT_JOB_EXECUTED,
    EVENT_JOB_ERROR,
    EVENT_JOB_ADDED,
    EVENT_JOB_SUBMITTED,
    EVENT_JOB_REMOVED,
    EVENT_JOB_MISSED
)
from datetime import datetime 

new_env = os.environ.copy()

def starter():
    
    #Kafka Configuration Variables
    KAFKA_CONFIG = json.loads(new_env['Kafka_Config'])
    KAFKA_SERVER = KAFKA_CONFIG["kafka_server"]
    KAFKA_TOPIC = KAFKA_CONFIG["kafka_topic"]

    #Kafka Credentials
    KAFKA_USERNAME = new_env['KAFKA_USERNAME']
    KAFKA_PASSWORD = new_env['KAFKA_PASSWORD']

    CERT_LOCATION = os.path.dirname(os.path.abspath(__file__)).replace('\\','/')+'/cert/fsca.pem'
    #CERT_LOCATION = os.path.dirname(os.path.abspath(__file__)).replace('\\','/')+'/usr/local/share/ca-certificates/fsca.pem'
 
    #SQLServer Configuration Variables
    SQLSERVER_CONFIG = json.loads(new_env['SQLServer_Config'])
    SQL_SERVER = SQLSERVER_CONFIG["sql_server"]
    SQL_DATABASE = SQLSERVER_CONFIG["sql_database"]
    SQL_SCHEMA = SQLSERVER_CONFIG["sql_schema"]
    SQL_READ_BATCHSIZE = SQLSERVER_CONFIG["sql_read_batchsize"]
    TOPIC_NAME = SQLSERVER_CONFIG["topic_name"]

    #SQL Credentials
    SQL_USERNAME = new_env['SQL_USERNAME']
    SQL_PASSWORD = new_env['SQL_PASSWORD']

    #Setup TimeWindow
    TIMED_WINDOW = int(new_env['timed_window'])
    
    source = SQLServerProc(server = SQL_SERVER, 
                            database = SQL_DATABASE,
                            schema = SQL_SCHEMA,
                            username = SQL_USERNAME,
                            password = SQL_PASSWORD,
                            read_batchsize = SQL_READ_BATCHSIZE,
                            topic_name=TOPIC_NAME)

    target = KafkaProducer(bootstrap_server = KAFKA_SERVER,
                            sasl_username = KAFKA_USERNAME,
                            sasl_password = KAFKA_PASSWORD,
                            ssl_ca_location = CERT_LOCATION,
                            topic = KAFKA_TOPIC)

    processor = ProducerProcessor()

    #Pipeline
    pipeline = Pipeline(
                    source = source,  
                    processor = processor, 
                    target=target,
                    logging_level=LEVEL,
                    timed_window=TIMED_WINDOW
                )
                
    #Run
    main_logger.warning("Run Started at :{}".format(datetime.now().strftime("%d-%b-%Y %H:%M:%S.%f")))
    pipeline.run()
    main_logger.warning("Run Stopped at :{}".format(datetime.now().strftime("%d-%b-%Y %H:%M:%S.%f")))    
    main_logger.warning('*' * 80)

if __name__ == "__main__":
        
    #Set Logging Level
    LOGGING_LEVEL = new_env['Logging_Level']

    LEVEL = logging.DEBUG
    if LOGGING_LEVEL.lower() == 'debug':
        LEVEL=logging.DEBUG
    elif LOGGING_LEVEL.lower() == 'info':
        LEVEL=logging.INFO
    elif LOGGING_LEVEL.lower() == 'error':
        LEVEL=logging.ERROR
    elif LOGGING_LEVEL.lower() == 'critical':
        LEVEL=logging.CRITICAL
    elif LOGGING_LEVEL.lower() == 'warning':
        LEVEL=logging.WARNING
    else:
        LEVEL=logging.ERROR

    logging.basicConfig(level=LEVEL, format='%(asctime)s - %(name)s - %(levelname)s - %(message)s')
    main_logger = logging.getLogger('Main_Logger')
    main_logger.setLevel(LEVEL)

    main_logger.debug("Application Started.")
    
    #Setup schedule
    Schedule_interval = int(new_env['Schedule_interval'])
    scheduler = BackgroundScheduler()

    exe = {
            'default': ThreadPoolExecutor(2),
            'processpool': ProcessPoolExecutor(2)
        }

    scheduler.configure(timezone="utc", executors=exe)
    scheduler.add_job(starter, 'interval', seconds=Schedule_interval)

    terminator = GracefulTerminator()

    def  err_listener (event):  
        if  event.exception:  
            main_logger.error( 'Error!{}'.format(event.exception))  
            terminator.kill = True
            scheduler.shutdown(wait=False)
        else :  
            main_logger.debug( 'Missed Job!')  

    scheduler.add_listener (err_listener, EVENT_JOB_ERROR | EVENT_JOB_MISSED)  

    #Start schedule
    scheduler.start()

    try:
        # This is here to simulate application activity (which keeps the main thread alive).
        while not terminator.kill:
            time.sleep(60)
    except (KeyboardInterrupt, SystemExit):
        # Not strictly necessary if daemonic mode is enabled but should be done if possible
        terminator.kill = True
        scheduler.shutdown()
