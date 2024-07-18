import copy
import time
import logging
from typing import Optional, Union
from datagate.components import IProcessor, IPipeline
from datagate.components.connectors.stores import IStore
from datagate.components.connectors.streams import IStreamConsumer, IStreamProducer

class Pipeline(IPipeline):
    def __init__(
            self, 
            source: Union[IStreamConsumer, IStore],
            target: Union[IStreamProducer, IStore],
            processor: Optional[IProcessor] = None,
            read_args: Optional[dict] = None,
            write_args: Optional[dict] = None,
            timed_window: float = None,
            logging_level = logging.ERROR           
        ) -> None:
        super().__init__(source, target, processor)
        self.logger = logging.getLogger(__name__)
        self.logger.setLevel(logging_level)
        self.write_args = write_args
        self.read_args = read_args
        self.timed_window = timed_window

    def run(self) -> None:

        messages: list = None
        written_records: list = []

        #Source pipeline data
        messages = self.source.read()
        
        run_start_time = time.time()
        while len(messages) > 0 and (time.time() - run_start_time) < self.timed_window:
            try:
            
                if len(messages) > 0:
                   
                    if isinstance(self.source, IStreamConsumer):
                        records: list = [m.value for m in messages]
                    elif isinstance(self.source, IStore):
                        records: list = messages

                    #messages = None #Clearing out the records as variable isnt used any more
                                    
                    processed_records: list = None           

                    #Process records
                    if self.processor is not None:
                        processed_records = copy.copy(records)
                        confirmedDate = self.processor.getConfirmedDate(processed_records)
                        processed_records = self.processor.process(processed_records)

                    records = None #Clearing out the records as variable isnt used any more
                    
                    
                    
                    #Send processed records to target stream
                    if self.target is not None and processed_records is not None:
                        start_time = time.time()
                        written_records: list = self.target.write(processed_records)
                        self.logger.warning("KAFKA write time: {}".format(time.time()-start_time))
                        self.logger.warning("Records written to target: {}".format(len(processed_records)))
                        self.logger.debug("Records written to target: {}".format(len(processed_records)))

                    processed_records = None
                    
                    endTime = time.time()
                    self.logger.debug("Send to Kafka: {}".format(endTime-start_time))

                    #return records, processed_records
                    if len(messages) == len(written_records):
                        messages = []
                else:
                    pass
                #self.logger.debug("Pipeline run ending.")

            except Exception as error:
                self.logger.error("An error occured during the pipeline: {}".format(error))
                raise error
                
        #once the loop is complete, update produced msgs to sql                
        if len(written_records)> 0 and confirmedDate is not None:
            start_time = time.time()
                    
            #Commit records in source                
            #self.source.json_confirm(record_list=written_records, ConfirmedDate = confirmedDate)
            self.source.confirm(record_list=written_records, ConfirmedDate = confirmedDate)
            self.logger.warning("Messages confirmed: {}".format(len(written_records)))
            self.logger.debug("Messages confirmed: {}".format(len(written_records)))
            
            written_records = None #Clearing out the records as variable isnt used any more

            endTime = time.time()
            self.logger.debug("SQL Confirm: {}".format(endTime-start_time))
        else:
            self.logger.debug("Nothing to write")

    def stop(self) -> None:
        if isinstance(self.source, IStreamConsumer):
            self.source.close()    
        self.logger.debug("Pipeline stopped")