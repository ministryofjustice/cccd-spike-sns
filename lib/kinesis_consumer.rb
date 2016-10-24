require 'json'
# require_relative 'aws_auth_header'
require_relative 'kinesis_shard_iterator'

class KinesisConsumer

  def initialize
    @endpoint = 'https://kinesis.eu-west-1.amazonaws.com/'
    @canonical_uri = '/'
    @shard_iterator = KinesisShardIterator.new('TRIM_HORIZON').get_iterator
    @payload = {
      'ShardIterator' => @shard_iterator,
      'Limit' => 25
    }
  end


  def run
    response_body_hash = fast_forward_until_records_found
    puts ">>>>>>>>>>>>>> RESPONSE BODY HASH - FIRST RECORD #{__FILE__}:#{__LINE__} <<<<<<<<<<<<<<<<<\n"
    pp response_body_hash

    while true do
      publish_records(response_body_hash['Records'])
      @payload['ShardIterator'] = response_body_hash['NextShardIterator']
      response_body_hash = get_records
      puts ">>>>>>>>>>>>>> XXXXXXXXXXXXX #{__FILE__}:#{__LINE__} <<<<<<<<<<<<<<<<<\n"
      pp response_body_hash

      if response_body_hash['MillisBehindLatest'] == 0 && response_body_hash['Records'].empty?
        puts ">>>>>>>>>>>>>> UPTO DATE - SLEEPING 30 #{__FILE__}:#{__LINE__} <<<<<<<<<<<<<<<<<\n"
        sleep 30
      end
    end
  end

  private

  def publish_records(records)
    puts ">>>>>>>>>>>>>> NUMBER OF RECORDS: #{records.size} #{__FILE__}:#{__LINE__} <<<<<<<<<<<<<<<<<\n"
    records.each do |record|
      puts Base64.strict_decode64(record['Data'])
    end
  end


  def fast_forward_until_records_found
    response_body_hash = get_records
    puts ">>>>>>>>>>>>>> RESPONSE BODY HASH FAST FORWARD - INITIAL READ #{__FILE__}:#{__LINE__} <<<<<<<<<<<<<<<<<\n"
    pp response_body_hash
    while response_body_hash['MillisBehindLatest'] > 0 && response_body_hash['Records'].empty?
      @payload['ShardIterator'] = response_body_hash['NextShardIterator']
      response_body_hash = get_records
      # puts ">>>>>>>>>>>>>> RESPONSE BODY HASH #{__FILE__}:#{__LINE__} <<<<<<<<<<<<<<<<<\n"
      # pp response_body_hash
    end
    puts ">>>>>>>>>>>>>> END OF FAST FORWARD #{__FILE__}:#{__LINE__} <<<<<<<<<<<<<<<<<\n"
    response_body_hash
  end


  def get_records
    json_payload = @payload.to_json
    aws_auth_header = AwsAuthHeader.new('kinesis', 'eu-west-1', 'POST', @canonical_uri, '', json_payload)
    uri = URI(@endpoint)
    begin
      headers = {
        'Authorization' => aws_auth_header.header,
        'x-amz-Date' => aws_auth_header.amazondate,
        'Host' => aws_auth_header.host,
        'Content-Type' => 'application/x-amz-json-1.1',
        'X-Amz-Target' => 'Kinesis_20131202.GetRecords',
        'Content-Length' => json_payload.size.to_s

      }
      # puts ">>>>>>>>>>>>>> headers #{__FILE__}:#{__LINE__} <<<<<<<<<<<<<<<<<\n"
      # ap headers

      response = RestClient.post(uri.to_s, json_payload, headers)
      JSON.parse(response.body)
    rescue => e
      puts "ERROR!!  #{e.class}"
      puts e.response
      raise e
    end
  end
end

KinesisConsumer.new.run
