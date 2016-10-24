#!/usr/bin/env bash



aws kinesis put-record --stream-name cccd_claims_local --data "DATA RECORD FROM CLI" --partition-key 666

aws kinesis get-shard-iterator --stream-name cccd_claims_local --shard-id shardId-000000000000 --shard-iterator-type TRIM_HORIZON

aws kinesis get-shard-iterator --stream-name cccd_claims_local --shard-id shardId-000000000000 --shard-iterator-type AT_SEQUENCE_NUMBER --starting-sequence-number 49566887783586287221770895561829939289901549249001160706

aws kinesis get-shard-iterator --stream-name cccd_claims_local --shard-id shardId-000000000000 --shard-iterator-type AT_TIMESTAMP --timestamp 0

aws kinesis get-records --shard-iterator "AAAAAAAAAAHcq5EUVKd/Sy8rKwIDFhKSF8tRy/S2fcoaQMBP6dsCJQ9/nmuwfGiicu+YWVshE65505b7Y+jpxnNkfINy3/kVTzYIgjwl0snPuXSGZovN5JSm2+yGQRqRn2MGbIVZJv+lEpXI10VfjNrr2B/+FsNTAprTSI91Gz3kSCRiA1GS1WPCtzeyO4CY4Y5vuSIgZ7FYmIPQG9IQrddB446W0yTl"