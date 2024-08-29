import os
import logging
import time
from datetime import datetime
import json
from pytz import utc
from components.pipelines.pipeline import Pipeline
from components.connectors.stores.sql import SQLServerProc
from components.connectors.streams.api import APICall
from components.transform.transform import Transform
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
    CERT_LOCATION = os.path.dirname(os.path.abspath(__file__)).replace('\\','/')+'/cert/fsca.pem'

    #SQLServer Configuration Variables
    SQLSERVER_CONFIG = json.loads(new_env['SQLServer_Config'])
    SQL_SERVER = SQLSERVER_CONFIG["sql_server"]
    SQL_DATABASE = SQLSERVER_CONFIG["sql_database"]
    SQL_SCHEMA = SQLSERVER_CONFIG["sql_schema"]
    SQL_TABLE = SQLSERVER_CONFIG["sql_table"]
    APP_ID = SQLSERVER_CONFIG["app_id"]
    API_REPORT = SQLSERVER_CONFIG["report"]


    #SQL Credentials
    SQL_USERNAME = new_env['SQL_USERNAME']
    SQL_PASSWORD = new_env['SQL_PASSWORD']

    #API token
    API_TOKEN = new_env['TOKEN']

    source = APICall(token = API_TOKEN,
                     appid= APP_ID,
                     apireport = API_REPORT
                     )
    
    target = SQLServerProc(server = SQL_SERVER, 
                            database = SQL_DATABASE,
                            schema = SQL_SCHEMA,
                            username = SQL_USERNAME,
                            password = SQL_PASSWORD,
                            table = SQL_TABLE,
                            report = API_REPORT,
                            appid2= APP_ID
                        )
    
    processor = Transform(apireport2 = API_REPORT)

    #Pipeline
    pipeline = Pipeline(
                    source = source,  
                    processor = processor, 
                    target=target,
                )
    
    #Run
    main_logger.warning("Run Started at :{}".format(datetime.now().strftime("%d-%b-%Y %H:%M:%S")))
    pipeline.run()

    pipeline.stop()
    main_logger.warning("Run Stopped at :{}".format(datetime.now().strftime("%d-%b-%Y %H:%M:%S")))    
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

    main_logger.warning("Application Started.")
    
    #Setup schedule
    Schedule_interval = int(new_env['Schedule_interval'])
    scheduler = BackgroundScheduler()
    exe = {
            'default': ThreadPoolExecutor(2),
            'processpool': ProcessPoolExecutor(2)
        }
    scheduler.configure(executors=exe, timezone=utc)
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