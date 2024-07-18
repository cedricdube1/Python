from typing import List
from datagate.components import IProcessor
from datagate.components.utils import mapper
import json

class ProducerProcessor(IProcessor):
    def __init__(self,
        **connection_args):
        super().__init__()

    # Create a metric to track time spent and requests made.   
 
    def my_transformation_func(self, record: dict) -> dict:
        data = dict(
                EventPayloadRecordID=record['EventPayloadRecordID'],
                EventPayloadID=record['EventPayloadID'],
                EventPayloadGenerated=record['EventPayloadGenerated'],
                Payload=json.loads(str(record['EventPayloadJSONString']))
                )
        return data

    def process(self, record_list: list) -> List[dict]:
        return mapper(func=self.my_transformation_func, iterable=record_list)   

    def getConfirmedDate(self, record:dict) -> str:
        #All values in the dict for ProduceEventConfirmed should be the same,
        #Taking first one and saving into a variable
        ConfirmedDate: str = record[0]['ProduceEventConfirmed']

        return ConfirmedDate
        