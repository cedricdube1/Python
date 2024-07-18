import json
import uuid
import datetime
import logging
from typing import Dict, List, Optional
from confluent_kafka import Consumer, KafkaException,KafkaError, TopicPartition, Message
from datagate.components.connectors.streams import  IStreamConsumer
import time
import confluent_kafka
import pandas as pd

class KafkaConsumer(IStreamConsumer):

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
        self.group_id: str = None
        self.topic: str = None
        self.poll_timeout_s: int = 1
        self.timed_window: int = 1
        self.poll_retry: int = 0

        for key, value in connection_args.items():
            setattr(self, key, value)

        self.Config = {
            'bootstrap.servers': self.bootstrap_server,
            'group.id':self.group_id,
            'security.protocol': self.security_protocol,
            'sasl.mechanism': self.sasl_mechanism,
            'sasl.username': self.sasl_username,
            'sasl.password': self.sasl_password,
            'ssl.ca.location': self.ssl_ca_location,
            'session.timeout.ms': 6000,
            'auto.offset.reset' : 'earliest',
            'enable.auto.commit' : False
             }

        self.add_cb()
        self.kc = Consumer(self.Config)

        self.logger.debug("Kafka Consumer connector created.")

    def error_cb(self,error):
        if error is not None:
            self.logger.error('Reading from topic error: {}'.format(error))
            raise Exception("Kafka Error: Error reading from topic")
    
    def stats_cb(self, stats):
        if stats is not None:
            self.logger.debug('Reading from topic stats: {}', format(stats))

    def on_commit(self, error, partition):
        if error:
            self.logger.error("The following error occured during commit on partition {} : {}".format(partition, error))
            raise Exception("Kafka Error: Commit Error")

    def add_cb(self):
        "Internal method to add callbacks"
        self.Config.update({'error_cb' : self.error_cb})
        self.Config.update({'stats_cb' : self.stats_cb})
        self.Config.update({'on_commit' : self.on_commit})  

    def read(self, read_args: Dict[str, float]) -> List[dict]:
        read_batch_size =   read_args['read_batch_size']

        record_list = []
        poll_count = 0
        #self.kc.subscribe([self.topic], on_assign=self.on_assign)
        self.kc.subscribe([self.topic])
        start_time = time.time()
        try:
            while time.time() - start_time < self.timed_window and len(record_list)< read_batch_size and poll_count < self.poll_retry :
                msg = self.kc.poll(self.poll_timeout_s)
                if msg is None:
                    #increment poll count by 1
                    poll_count += 1 
                    self.logger.debug("No Kafka Message. Poll Count : {} of {}".format(poll_count, self.poll_retry))
                    continue
                elif not msg.error():
                    #reset poll count. poll retry only inaffect when consecutive 
                    poll_count = 0
                    record_list.append(msg)
                    
                else:
                    if msg.error().code() == KafkaError._PARTITION_EOF:
                            # End of partition event
                            self.logger.debug('%% %s [%d] reached end at offset %d\n' %
                                            (msg.topic(), msg.partition(),
                                            msg.offset()))
                    else:
                        self.logger.error("An error occurred while trying to poll: {}".format(msg.error))
                        raise KafkaException(msg.error())
                    
        except Exception as error:
            self.logger.error("An error occurred while trying to consume: {}".format(error))
            raise error
        finally:
            endTime = time.time()
            self.logger.warning("Kafka Poll time taken: {}".format(endTime-start_time))
            return record_list
    def store_offsets(self, message_list:List) -> None:
        """
        This method is to be used when you want to control when you want to commit records using a non-blocking call. 
        For instance, you may not want to commit offsets immediately after consuming them, but rather, commit them only once 
        you have fully processed them.

        Parameters
        ----------
        `message_list`: List[dict] 
            A list containing dictionaris 
        """
        [self.kc.store_offsets(record.message) for record in message_list]

    def commit(self, message_list:Optional[Message] = None) -> None:
                
        lst_offsets: List = self.getOffsetList(message_list)
        #self.logger.debug("Offset: {}".format(lst_offsets))

        self.kc.commit(offsets=lst_offsets)

    def close(self) -> None:
        self.kc.close()

    def flush(self):
        self.kc.flush()

    # return list of TopicPartition which represent the _next_ offset to consume
    def getOffsetList(self, messages):
        offsets = []
        for msg in messages:
            # Add one to the offset, otherwise we'll consume this message again.
            # That's just how Kafka works, you place the bookmark at the *next* message.
            offsets.append(TopicPartition(msg.topic(), msg.partition(), msg.offset()+1))

        return offsets


    def getLagConsumerGroup(self) -> pd.DataFrame:
        group_results = []

        #self.client_config["group.id"] = self.group_id
        group_results.append(self.listOffsets(self.Config, self.group_id, [self.topic]))

        df = pd.DataFrame(columns=["ConsumerGroup","Topic","Partition","Committed", "Lag"])

        df2 = pd.DataFrame(columns=["ConsumerGroup","Topic","Lag"])     
        df2[["Lag"]] = df2[["Lag"]].astype('int64')

        for r in group_results:
            if len(r):
                df = df.append(r,ignore_index=True)

        df[["Committed", "Lag"]] = df[["Committed", "Lag"]].astype('int64')
        df2 = df2.append(df.groupby(["ConsumerGroup","Topic"], as_index=False).agg({'Lag': "sum"}),ignore_index=True)           

        return df2

    def listOffsets(self,cfg, g, topics) -> List[dict]:

        consumer = Consumer(cfg)
        record_list = []

        for topic in topics:
            # Get the topic's partitions
            metadata = consumer.list_topics(topic, timeout=10)
            if metadata.topics[topic].error is not None:
                raise KafkaException(metadata.topics[topic].error)
            
            # Construct TopicPartition list of partitions to query
            partitions = [TopicPartition(topic, p) for p in metadata.topics[topic].partitions]
        
            # Query committed offsets for this group and the given partitions
            committed = consumer.committed(partitions, timeout=10)
            for partition in committed:
                # Get the partitions low and high watermark offsets.
                (lo, hi) = consumer.get_watermark_offsets(partition, timeout=10, cached=False)
                if partition.offset == confluent_kafka.OFFSET_INVALID:
                    offset = "-"
                else:
                    offset = "%d" % (partition.offset)
                if hi < 0:
                    lag = "no hwmark"  # Unlikely
                elif partition.offset < 0:
                    # No committed offset, show total message count as lag.
                    # The actual message count may be lower due to compaction
                    # and record deletions.
                    lag = "%d" % (hi - lo)
                else:
                    lag = "%d" % (hi - partition.offset)
                # print('ConsumerGroup:{}, offset:{}, lag:{}'.format(g.id,offset,lag))    
                if offset == '-':
                    offset = 0  
                if lag == '-':
                    lag = 0
                record_list.append({"ConsumerGroup":g,"Topic":partition.topic, "Partition":partition.partition ,"Committed":int(offset),"Lag":int(lag)})    
        
        consumer.close() 

        return record_list