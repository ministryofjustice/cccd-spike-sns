# This class will get the intial kinesis shard iterator
#

require 'json'
require_relative 'aws_auth_header'

class KinesisShardIterator

  def initialize(iterator_type)
    valid_iterator_types = %w{  AT_SEQUENCE_NUMBER AFTER_SEQUENCE_NUMBER AT_TIMESTAMP TRIM_HORIZON LATEST }
    raise ArgumentError.new("Invalid iterator type") unless iterator_type.in?(valid_iterator_types)

    @endpoint = 'https://kinesis.eu-west-1.amazonaws.com/'
    @canonical_uri = '/'
    @body_hash = {
        'StreamName' => 'cccd_claims_local',
        'ShardId' => 'shardId-000000000000',
        'ShardIteratorType' =>  iterator_type
    }
    end

  def get_iterator
    payload = @body_hash.to_json
    # puts ">>>>>>>>>>>>>> payload #{__FILE__}:#{__LINE__} <<<<<<<<<<<<<<<<<\n"
    # puts payload

    aws_auth_header = AwsAuthHeader.new('kinesis', 'eu-west-1', 'POST', @canonical_uri, '', payload)
    uri = URI(@endpoint)
    begin
      headers = {
        'Authorization' => aws_auth_header.header,
        'x-amz-Date' => aws_auth_header.amazondate,
        'Host' => aws_auth_header.host,
        'Content-Type' => 'application/x-amz-json-1.1',
        'X-Amz-Target' => 'Kinesis_20131202.GetShardIterator',
        'Content-Length' => payload.size.to_s

      }
      # puts ">>>>>>>>>>>>>> headers #{__FILE__}:#{__LINE__} <<<<<<<<<<<<<<<<<\n"
      # ap headers

      response = RestClient.post(uri.to_s, payload, headers)
      JSON.parse(response.body)['ShardIterator']
    rescue => e
      puts "ERROR!!  #{e.class}"
      puts e.response
      raise e
    end

  end


end

KinesisShardIterator.new('TRIM_HORIZON').get_iterator

