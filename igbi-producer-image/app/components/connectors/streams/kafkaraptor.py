import json
import uuid
from datetime import datetime
import logging
from typing import Dict, List, Optional
from confluent_kafka import Producer, KafkaException,KafkaError, TopicPartition, Message
from datagate.components.connectors.streams import  IStreamProducer
import time

class KafkaProducer(IStreamProducer):
    def __init__(
        self, 
        **connection_args
    ) -> None:
        super().__init__() 
        self.logger = logging.getLogger(__name__)

        self.bootstrap_server : str = None
        self.security_protocol : str = 'sasl_ssl'
        self.sasl_mechanism: str = 'SCRAM-SHA-256'
        self.sasl_username: str = None
        self.sasl_password: str = None
        self.ssl_ca_location: str = None
        self.topic: str = None
        #self.batch_size: str = None

        for key, value in connection_args.items():
            setattr(self, key, value)

        Config = {
            'bootstrap.servers': self.bootstrap_server,
            'security.protocol': self.security_protocol,
            'sasl.mechanism': self.sasl_mechanism,
            'sasl.username': self.sasl_username,
            'sasl.password': self.sasl_password,
            'ssl.ca.location': self.ssl_ca_location,
            'socket.keepalive.enable': True,
            'message.send.max.retries': 3,
            'metadata.max.age.ms': 60000,
            'batch.num.messages': '1000',
            'linger.ms': '1000',
            'partitioner':'consistent_random'
             }

        self.add_cb(Config)

        self.producer = Producer(Config)

    def error_cb(self,error):
        if error is not None:
            self.logger.error('Reading from topic error: {}'.format(error))
            raise KafkaException("Kafka Error: {}".format(KafkaException))

    def add_cb(self, Config):
        "Internal method to add callbacks"
        Config.update({'error_cb' : self.error_cb})

    def delivery_report(self, err, msg):  
        if err is not None:       
            self.logger.error('Delivery failed for user record {}: {}'.format(msg.key(), err))
            raise Exception("Kafka Error: Delivery failed")
    
    def getKey(self):
        utc_datetime = datetime.utcnow().strftime("%Y-%m-%d %H:%M:%S.%f")
#        utc_datetime = utc_datetime.strftime("%Y-%m-%d %H:%M:%S.%f")
        uid = uuid.uuid4()
        uid = str(uid)
        keyValue = dict(
                        MessageId = uid,
                        UtcDateTimeStamp = utc_datetime
                        )               
        return keyValue            

    def write(self, record_list: List[dict]) -> list:   
        
       
        response_list = []
        for record in record_list:
            already_processed = False
            keyValue = self.getKey()
            key = json.dumps(keyValue) 
            payload = json.dumps(record["Payload"])

            while True:
                try:
                    self.producer.poll(timeout=0)
                    self.producer.produce(self.topic, payload, key, callback = self.delivery_report)
                    if already_processed == False:
                        processed = ({
                                    'EPID': record["EventPayloadID"],
                                    'EPRID': record["EventPayloadRecordID"], 
                                    'EPG':record["EventPayloadGenerated"], 
                                    'PEMID': keyValue["MessageId"]
                                    }) #used for json_confirm & dt_confirm
                        response_list.append(processed)
                        already_processed = True

                    break
                except BufferError as buffer_error:
                    self.logger.error("Queue is full, waiting for space : {}".format(buffer_error))
                    time.sleep(2)
                except Exception as ex:
                    raise Exception("Error writing to Kafka: {}".format(ex))
        
        self.producer.flush()
        return response_list

    def flush(self):
        self.producer.flush()