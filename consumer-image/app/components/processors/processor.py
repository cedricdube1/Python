import logging
from typing import List, Union, Dict
from datagate.components import IProcessor
from datagate.components.utils import mapper
import json
import time
from datetime import datetime

class ConsumerProcessor(IProcessor):
    def __init__(self,**connection_args)-> None:
        super().__init__()
        self.logger = logging.getLogger(__name__)

        self.consumer_topic: str = None
        self.key_type: str = None

        for key, value in connection_args.items():
            setattr(self, key, value)

        if self.consumer_topic is None: raise TypeError("No topic provided. Please provide a topic.")
        if self.key_type is None: raise TypeError("No Message_Key_Type provided. Please provide a Message_Key_Type.")


    # Create a metric to track time spent and requests made. 
    # used for JSON message keys  
    def my_transformation_func(self, record: list) -> dict:
        
        data = ()
        try:
            
            msgValue = json.dumps(json.loads(record['messageValue'].decode("utf-8")))

            msgKey = json.loads(record['messageKey'].decode("utf-8"))
            
            data = dict(
                EventMessageID=msgKey['MessageId'],
                EventTimeStamp=msgKey['UtcDateTimeStamp'],
                EventJSONValue=json.loads(msgValue.replace("'","''"))
                )
            #self.logger.debug("Event value: {}".format(json.loads(msgValue.replace("'","''"))))
        except Exception as transformation_error:
            self.logger.error("An error occured during the ConsumerProcessor:my_transformation_func : {}".format(transformation_error))
            raise transformation_error
        finally:
            return data
        
    # Create a metric to track time spent and requests made. 
    # used for String message keys  
    def my_transformation_string_func(self, record: list) -> dict:
        
        data = ()
        try:
            
            msgValue = json.dumps(json.loads(record['messageValue'].decode("utf-8")))

            msgKey = record['messageKey'].decode("utf-8")
            
            data = dict(
                EventMessageID=msgKey,
                EventTimeStamp=datetime.now().strftime('%Y/%m/%d %H:%M:%S.%f') ,
                EventJSONValue=json.loads(msgValue.replace("'","''"))
                )
            #self.logger.debug("Event value: {}".format(json.loads(msgValue.replace("'","''"))))
        except Exception as transformation_error:
            self.logger.error("An error occured during the ConsumerProcessor:my_transformation_string_func : {}".format(transformation_error))
            raise transformation_error
        finally:
            return data

    def process(self, record_list: list) -> List[dict]:
        if self.key_type == 'json':
            mapped = mapper(func=self.my_transformation_func, iterable=record_list)
        elif self.key_type == 'string':
            mapped = mapper(func=self.my_transformation_string_func, iterable=record_list)
        else:
            self.logger.error("Incorrect Message Key Type provided. Please use string or json")
            self.logger.debug(self.key_type)

        self.logger.info("Records processed: {}".format(len(mapped)))
        return mapped