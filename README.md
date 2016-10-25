# cccd-spike-sns
Spike to test producing and consuming messages through AWS  SNS and SQS



## Disadvantages of Kinesis over SNS/SQS

* No native Ruby or Python SDK - have to run a daemon which does the translation to Java
 
* Have to manage shards ourselves - know what the shard ids are to pick up from

* Have to manage the sequence number ourselves, or the time, in order to know from where to start

* Have to manage "fast forwarding" until we get to records.  
