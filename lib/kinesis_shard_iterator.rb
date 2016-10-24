# This class will get the intial kinesis shard iterator
#

require 'json'
require_relative 'aws_auth_header'
require 'pp'


class KinesisShardIterator

  def initialize(iterator_type, value = nil)
    valid_iterator_types = %w{  AT_SEQUENCE_NUMBER AFTER_SEQUENCE_NUMBER AT_TIMESTAMP TRIM_HORIZON LATEST }
    raise ArgumentError.new("Invalid iterator type") unless iterator_type.in?(valid_iterator_types)
    @iterator_type = iterator_type
    @iterator_value = value
    @endpoint = 'https://kinesis.eu-west-1.amazonaws.com/'
    @canonical_uri = '/'
    @body_hash = construct_body_hash
  end

  def get_iterator
    payload = @body_hash.to_json
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

  private

  def construct_body_hash
    body_hash = {
      'StreamName' => 'cccd_claims_local',
      'ShardId' => 'shardId-000000000000',
      'ShardIteratorType' =>  @iterator_type
    }
    case @iterator_type
    when 'AT_SEQUENCE_NUMBER', 'AFTER_SEQUENCE_NUMBER'
      body_hash['StartingSequenceNumber'] = @iterator_value.to_s
    when 'AT_TIMESTAMP'
      body_hash['Timestamp'] = @iterator_value.to_f
    end
    body_hash
  end
end




# puts ">>>>>>>>>>>>>> TRIM_HORIZON #{__FILE__}:#{__LINE__} <<<<<<<<<<<<<<<<<\n"
# KinesisShardIterator.new('TRIM_HORIZON').get_iterator
#
# t = Time.utc(2016, 10, 22, 9, 01, 2.87343)
# puts ">>>>>>>>>>>>>> AT_TIMESTAMP #{t.strftime('%Y-%m-%d %H:%M:%S.%L')} #{__FILE__}:#{__LINE__} <<<<<<<<<<<<<<<<<\n"
# KinesisShardIterator.new('AT_TIMESTAMP', t).get_iterator
#
#
# sequence_num = 49566887783586287221770895561829939289901549249001160706
# puts ">>>>>>>>>>>>>> AT_SEQUENCE_NUMBER  #{sequence_num} #{__FILE__}:#{__LINE__} <<<<<<<<<<<<<<<<<\n"
# KinesisShardIterator.new('AT_SEQUENCE_NUMBER', sequence_num).get_iterator
#
# puts ">>>>>>>>>>>>>> AFTER_SEQUENCE_NUMBER  #{sequence_num} #{__FILE__}:#{__LINE__} <<<<<<<<<<<<<<<<<\n"
# KinesisShardIterator.new('AFTER_SEQUENCE_NUMBER', sequence_num).get_iterator
#
#
# puts ">>>>>>>>>>>>>> LATEST #{__FILE__}:#{__LINE__} <<<<<<<<<<<<<<<<<\n"
# KinesisShardIterator.new('LATEST').get_iterator