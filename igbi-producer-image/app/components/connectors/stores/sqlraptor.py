from datetime import datetime
import logging
import pytds
import time
import json
from typing import Dict, Optional, Union, List
from datagate.components.connectors.stores import IStore

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

    def write(self):
        pass

    def read(self) -> List[dict]:
        startTotal = time.time()
        conn = self.create_connection()
        conn.autocommit = True
        
        if conn._closed == True:
            #re connect to sql if connection is closed
            conn = self.reconnect_sql(conn)

        cursor = conn.cursor()
        qry = "EXEC  [{}].[{}_FetchUnpublishedEvents] @PublishBatchSize = %s;".format(self.schema,self.topic_name)
        cursor.execute(qry,(self.read_batchsize,))
        results = [] 

        results = cursor.fetchall()
        #for row in cursor.fetchall():
        #    results.append(dict(row))
        cursor.get_proc_outputs()
        conn.close()

        end = time.time()
        self.logger.warning("SQL read time: {}".format(end-startTotal))
        return results

    def delete(self):
        pass

    #def confirm(self, record_list: List[tuple], ConfirmedDate) -> None:
    def confirm(self, record_list: List[dict], ConfirmedDate) -> None:
        startTotal = time.time()
        conn = self.create_connection()

        if conn._closed == True:
            #re connect to sql if connection is closed
            conn = self.reconnect_sql(conn)

        cursor = conn.cursor()
        
        # Create temp table
        qry = """CREATE TABLE #Temp (
                    EventPayloadID INT NOT NULL,  
                    EventPayloadRecordID INT NOT NULL,                                                         
                    EventPayloadGenerated DATETIME2 NOT NULL,
                    ProduceEventMessageID UNIQUEIDENTIFIER NOT NULL
                 );"""
        cursor.execute(qry)

        #qry = """INSERT INTO #Temp (EventPayloadRecordID, EventPayloadID, EventPayloadGenerated, MessageID)
        #         SELECT %s, %s, %s, %s;"""
        qry = """INSERT INTO #Temp (EventPayloadID, EventPayloadRecordID, EventPayloadGenerated, ProduceEventMessageID)
                 VALUES (%(EPID)s, %(EPRID)s, %(EPG)s, %(PEMID)s);"""
        cursor.fast_executemany = True
        cursor.executemany(qry, record_list)

        qry = """DECLARE @EventConfirmationList [dbo].[ConfirmEvents];
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
                 EXEC [{}].[{}_ConfirmEventsPublished] @ConfirmEvents = @EventConfirmationList;""".format(self.schema, self.topic_name, confirmDate =ConfirmedDate)
        cursor.execute(qry)
        cursor.get_proc_outputs()

        conn.close()
        end = time.time()
        self.logger.warning("SQL write total time taken: {}".format(end-startTotal))

    def json_confirm(self, record_list: List[dict], ConfirmedDate) -> None:
        startTotal = time.time()
        conn = self.create_connection()
        
        json_object = json.dumps(record_list)

        if conn._closed == True:
            #re connect to sql if connection is closed
            conn = self.reconnect_sql(conn)

        cursor = conn.cursor()
        
        qry = """EXEC [{schema}].[{topic}_ConfirmEventsPublished_JSON] @JSON = N'{JSON}', @ProduceEventConfirmed = '{confirmDate}';""".format(schema=self.schema, topic=self.topic_name, JSON=json_object, confirmDate =ConfirmedDate)
        cursor.execute(qry)
        cursor.get_proc_outputs()
        
        json_object = None
        conn.close()

        end = time.time()
        self.logger.warning("SQL confirm time: {}".format(end-startTotal))

    def reconnect_sql(self, reconnect: pytds.Connection)-> pytds.Connection:
        reconnect_count = 1
        new_connection = reconnect
        while new_connection._closed == True and reconnect_count <=3:
            time.sleep(30)
            new_connection = self.create_connection()
            reconnect_count =+ 1

        if new_connection._closed == False:
             self.logger.debug("SQL reconnected successfully: {counts} attempts.".format(counts=reconnect_count))
        else:
            self.logger.debug("SQL reconnected unsuccessfully: {counts} attempts.".format(counts=reconnect_count))
            raise Exception("SQL Connection Error")
       
        return new_connection