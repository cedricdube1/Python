import copy
import json
import logging
import pytds
import time
from typing import Dict, Optional, Union, List
from datagate.components.connectors.stores import IStore
import pandas

class SQLServerProc(IStore):
    def __init__(
        self,
        **connection_args
    ):
        super().__init__()

        self.logger = logging.getLogger(__name__)

        self.server: str = None
        self.database: str = None
        self.username: Optional[str] = None
        self.password: Optional[str] = None
        self.driver: str = "ODBC Driver 17 for SQL Server"
        self.port: int = 1433
        self.config: str = None
        self.topic_name: str = None
        self.schema: str = None
        self.odbc_kwargs: Optional[Dict[str, Union[str, int]]] = None
        self.read_batchsize: int = None
        self.connection_name: str = 'python'
        self.auto_commit: bool = True

        for key, value in connection_args.items():
            setattr(self, key, value)

    def create_connection(self):
        return pytds.connect(
            dsn=self.server,
            database=self.database,
            user=self.username,
            password=self.password,
            port=self.port,
            autocommit=self.auto_commit,
            appname=self.connection_name,
            as_dict=True,
            use_tz=pytds.tz.utc
        )

    def write(self, record_list: List[dict]) -> bool:

        successful = False
        startTime = time.time()
        conn:any = None
        try:
            conn = self.create_connection()

            self.topic_sourceid = 1

            cursor = conn.cursor()

            #df = pandas.DataFrame(record_list)

            #qry = "EXEC [{schema}].[{topic}_PublishInsert_Batch_JSON] @JSONEvents = N'{json}';".format(
            #                                                                                schema=self.schema,
            #                                                                                topic=self.topic_name,
            #                                                                                json=df.to_json(orient="records"))
            #self.logger.debug(qry)                                                                                            
            #cursor.execute(qry)
            
            cursor.get_proc_outputs()

            # Create temp table
            qry = """CREATE TABLE #Temp (
                        EventMessageID UNIQUEIDENTIFIER NOT NULL,  
                        EventTimeStamp DATETIME2(7) NOT NULL,                                                         
                        EventJSONValue VARCHAR(4000) NOT NULL
                     );"""
            cursor.execute(qry)

            qry = """INSERT INTO #Temp (EventMessageID, EventTimeStamp, EventJSONValue,)
                     VALUES (%(EventMessageID)s, %(EventTimeStamp)s, %(EventJSONValue)s;"""
            cursor.fast_executemany = True
            cursor.executemany(qry, record_list)

            qry = """DECLARE @EventConfirmationList [dbo].[PublishEventVCS];
                     DECLARE @ProduceEventConfirmed DATETIME2 = '{confirmDate}';
                     INSERT INTO @EventConfirmationList (                    
                        EventPayloadID,
                        EventPayloadRecordID,
                       EventPayloadGenerated,
                        ProduceEventConfirmed,
                        ProduceEventMessageID
                     ) SELECT EventPayloadID,
                              EventPayloadRecordID,
                              EventPayloadGenerated,
                              @ProduceEventConfirmed, 
                              ProduceEventMessageID
                     FROM #Temp;
                     EXEC [{}].[{}PlayerAdjustment_PublishInsert_Batch] @ConfirmEvents = @EventConfirmationList;""".format(self.schema, self.topic_name)
            cursor.execute(qry)
            cursor.get_proc_outputs()

            endTime = time.time()
            self.logger.warning("SQL write total time taken: {}".format(endTime-startTime))

        except Exception as err:
            successful = False
            self.logger.error("Error during SQL write: {}".format(err))
            #self.logger.debug(json.dumps(record_list))
            raise err
        else:
            successful = True
        finally:
            if conn is not None:
                conn.close()
            self.logger.debug("SQL Successful value: {}".format(successful))
            return successful
                   
    def read(self):
        pass

    def delete(self):
        pass

    def confirm(self):
        pass

    def LagWatcherInsert(self, toSend: pandas.DataFrame, read_args: Dict[str, str]):

        monitoring_schema = read_args['SQL_SCHEMA_MONITOR']

        conn = pytds.connect(
            dsn= read_args['SQL_SERVER_MONITOR'],
            database=read_args['SQL_DATABASE_MONITOR'],
            user=read_args['SQL_USERNAME_MONITOR'],
            password=read_args['SQL_PASSWORD_MONITOR'],
            port=self.port,
            autocommit=True,
            appname= 'LagWatcher',
            as_dict=True,
            use_tz=pytds.tz.utc
        )

        try:
            record_list = list(toSend.itertuples(index=False,name=None))
            cursor = conn.cursor()
            qry = "EXEC {schema}.Process_ConsumerGroupLag @ConsumerGroup  = %s,@TopicName  = %s, @ConsumerLag = %s".format(schema = monitoring_schema)
            cursor.fast_executemany = True
            cursor.executemany(qry, record_list)
            cursor.get_proc_outputs()
        
        except Exception as err:
            conn.close()
            self.logger.error("Error during LagWatcherInsert: {}".format(err))
            raise err

        conn.close()