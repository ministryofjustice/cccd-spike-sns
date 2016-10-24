require 'json'
# require_relative 'aws_auth_header'
require_relative 'kinesis_shard_iterator'

class KinesisConsumer

  def initialize
    @endpoint = 'https://kinesis.eu-west-1.amazonaws.com/'
    @canonical_uri = '/'
    @shard_iterator = KinesisShardIterator.new('TRIM_HORIZON').get_iterator
    @body_hash = {
      'ShardIterator' => @shard_iterator,
      'Limit' => 25
    }
  end


  def get_records
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
        'X-Amz-Target' => 'Kinesis_20131202.GetRecords',
        'Content-Length' => payload.size.to_s

      }
      # puts ">>>>>>>>>>>>>> headers #{__FILE__}:#{__LINE__} <<<<<<<<<<<<<<<<<\n"
      # ap headers

      response = RestClient.post(uri.to_s, payload, headers)
      response_hash = JSON.parse(response.body)
      puts ">>>>>>>>>>>>>> response #{__FILE__}:#{__LINE__} <<<<<<<<<<<<<<<<<\n"
      ap response_hash

      response_hash['Records'].each do |rec|
        rec['Decoded'] = Base64.decode64(rec['Data'])
      end
      puts ">>>>>>>>>>>>>> RESPONSE #{__FILE__}:#{__LINE__} <<<<<<<<<<<<<<<<<\n"
      ap response_hash
      response_hash
    rescue => e
      puts "ERROR!!  #{e.class}"
      puts e.response
      raise e
    end
  end
end

KinesisConsumer.new.get_records
