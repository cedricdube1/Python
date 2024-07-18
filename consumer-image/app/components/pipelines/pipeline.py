import copy
import time
import logging
from typing import Optional, Union, Dict
from datagate.components import IProcessor, IPipeline
from datagate.components.connectors.stores import IStore
from datagate.components.connectors.streams import IStreamConsumer, IStreamProducer
import pandas as pd

class Pipeline(IPipeline):
    def __init__(
            self, 
            source: Union[IStreamConsumer, IStore],
            target: Union[IStreamProducer, IStore],
            processor: Optional[IProcessor] = None,
            read_args: Optional[dict] = None,
            write_args: Optional[dict] = None,
            timed_window: float = None
        ) -> None:
        super().__init__(source, target, processor)
        self.logger = logging.getLogger(__name__)
        #self.logger.setLevel(logging_level)
        self.write_args = write_args
        self.read_args = read_args
        self.timed_window = timed_window

    def run(self) -> None:
        successful: bool = False
        messages = []
        start_time = time.time()

        #Source pipeline data
        messages = self.source.read(self.read_args)
        
        while len(messages) > 0 and time.time() - start_time < self.timed_window:
            try:
                successful = False
                if len(messages) > 0:

                    self.logger.debug("No of Records read: {}".format(len(messages)))

                    if isinstance(self.source, IStreamConsumer):
                        records: list = [dict(messageValue=m.value(),messageKey=m.key(), messageOffset=m.offset()) for m in messages]
                    elif isinstance(self.source, IStore):
                        records: list = messages
                        messages = []

                    records_to_process: list = [dict]
                    processed_records: list = [dict]           

                    #Process records
                    if self.processor is not None:
                        records_to_process = copy.copy(records)
                        processed_records = self.processor.process(records_to_process)
                
                    #Send processed records to target stream
                    if self.target is not None and processed_records is not None:
                        successful = self.target.write(processed_records)
                        self.logger.debug("Records written to target: {}".format(len(processed_records)))
                
                    #Commit records in source   
                    if successful:
                        if isinstance(self.source, IStreamConsumer):
                            self.source.commit(messages)
                    else:
                        records = []
                        processed_records = []
                        
                    return records, processed_records
                    
                else:
                    pass
                
            except Exception as error:
                self.logger.error("An error occured during the pipeline: {}".format(error))
                raise error
        
        #df = self.source.getLagConsumerGroup()

        #self.target.LagWatcherInsert(df, self.read_args)

    def stop(self) -> None:
        if isinstance(self.source, IStreamConsumer):
            self.source.close()  