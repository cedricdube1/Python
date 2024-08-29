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
            #logging_level = logging.ERROR           
        ) -> None:
        super().__init__(source, target, processor)
        self.logger = logging.getLogger(__name__)
        #self.logger.setLevel(logging_level)
    
    def run(self) -> None:
        # GET lastest Timestamp
        last_processed = self.target.read()

        # GET API CAll to get data
        data = self.source.read(last_processed) 
        try:
            if len(data) > 0:
                # tranform Data
                processed_data = self.processor.process(data)    

                #Write records to SQL
                self.target.write(processed_data) 

                # Update config with last processed date
                self.target.update(processed_data)               
                                     
            else:                 
                self.logger.warning("No Records to write to sql")   
                
        except Exception as error:
            self.logger.error("An error occured during the pipeline: {}".format(error))
            raise error

    def stop(self) -> None:
        pass     

