from datetime import datetime 
import os
import json
import time
import logging
from components.pipelines.pipeline import Pipeline
from components.connectors.stores.sqlraptor import SQLServerProc
from components.connectors.streams.kafkaraptor import KafkaConsumer
from components.processors.processor import ConsumerProcessor
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

new_env = os.environ.copy()

def starter():

    #Kafka Configuration Variables
    KAFKA_CONFIG = json.loads(new_env['Kafka_Config'])
    KAFKA_SERVER = KAFKA_CONFIG["kafka_server"]
    KAFKA_GROUP = KAFKA_CONFIG["kafka_groupid"]
    KAFKA_TOPIC = KAFKA_CONFIG["kafka_topic"]
    KAFKA_POLL_TIMEOUT = KAFKA_CONFIG["poll_timeout_s"] #timeout is in seconds
    KAFKA_POLL_RETRY = KAFKA_CONFIG["poll_retry"] #the amount of times consumer polls, and retries if there is no message

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

    #SQLServer Configuration Variables
    SQLSERVER_CONFIG_MONITOR = json.loads(new_env['SQLServer_Config_Monitoring'])
    SQL_SERVER_MONITOR = SQLSERVER_CONFIG_MONITOR["sql_server"]
    SQL_DATABASE_MONITOR = SQLSERVER_CONFIG_MONITOR["sql_database"]
    SQL_SCHEMA_MONITOR = SQLSERVER_CONFIG_MONITOR["sql_schema"]
    
    #SQL Credentials
    SQL_USERNAME_MONITOR = new_env['SQL_USERNAME_MONITOR']
    SQL_PASSWORD_MONITOR = new_env['SQL_PASSWORD_MONITOR']

    #Setup TimeWindow
    TIMED_WINDOW = int(new_env['timed_window'])

    MSG_KEY_TYPE = str(new_env['Message_Key_Type'])
    if MSG_KEY_TYPE.lower() == 'none':
        MSG_KEY_TYPE = 'json'
    elif MSG_KEY_TYPE == '':
        MSG_KEY_TYPE = 'json'
    else:
        MSG_KEY_TYPE = new_env['Message_Key_Type'].lower()

    READ_ARGS = {"topic":KAFKA_TOPIC , 
                 "timed_window" : TIMED_WINDOW,
                 "read_batch_size" : SQL_READ_BATCHSIZE, 
                 "SQL_SERVER_MONITOR" : SQL_SERVER_MONITOR, 
                 "SQL_DATABASE_MONITOR": SQL_DATABASE_MONITOR,
                 "SQL_SCHEMA_MONITOR" : SQL_SCHEMA_MONITOR,
                 "SQL_USERNAME_MONITOR" : SQL_USERNAME_MONITOR,
                 "SQL_PASSWORD_MONITOR" : SQL_PASSWORD_MONITOR}

    source = KafkaConsumer(bootstrap_server = KAFKA_SERVER,
                            sasl_username = KAFKA_USERNAME,
                            sasl_password = KAFKA_PASSWORD,
                            ssl_ca_location = CERT_LOCATION,
                            topic = KAFKA_TOPIC,
                            group_id = KAFKA_GROUP,
                            poll_timeout_s = KAFKA_POLL_TIMEOUT, 
                            timed_window = TIMED_WINDOW,
                            poll_retry = KAFKA_POLL_RETRY)
                            
    target = SQLServerProc(server = SQL_SERVER, 
                            database = SQL_DATABASE,
                            schema = SQL_SCHEMA,
                            username = SQL_USERNAME,
                            password = SQL_PASSWORD,
                            read_batchsize = SQL_READ_BATCHSIZE,
                            topic_name=TOPIC_NAME)

    processor = ConsumerProcessor(consumer_topic = KAFKA_TOPIC,
                                  key_type = MSG_KEY_TYPE)

    #Pipeline
    pipeline = Pipeline(
                    source = source,  
                    processor = processor, 
                    target=target,
                    timed_window=TIMED_WINDOW,
                    read_args = READ_ARGS
                )
    #Run
    main_logger.warning("Run Started at :{}".format(datetime.now().strftime("%d-%b-%Y %H:%M:%S.%f")))
    pipeline.run()

    df = source.getLagConsumerGroup()

    target.LagWatcherInsert(df, READ_ARGS)

    pipeline.stop()
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
        LEVEL=logging.debug

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
    scheduler.configure(executors=exe,)
    scheduler.add_job(starter, 'interval', seconds=Schedule_interval)

    terminator = GracefulTerminator()

    def  err_listener (event):  
        if  event.exception:  
            main_logger.exception( 'Error!')  
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