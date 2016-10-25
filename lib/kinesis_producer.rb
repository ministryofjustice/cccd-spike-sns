# API docs:
#
# http://docs.aws.amazon.com/kinesis/latest/APIReference/API_Operations.html


require 'json'
require 'securerandom'
require_relative 'aws_auth_header'


class KinesisProducer

  def initialize
    @endpoint = 'https://kinesis.eu-west-1.amazonaws.com/'
    @canonical_uri = '/'
  end

  def run
    payload = generate_payload
    puts ">>>>>>>>>>>>>> PAYLOAD #{__FILE__}:#{__LINE__} <<<<<<<<<<<<<<<<<\n"
    puts payload

    aws_auth_header = AwsAuthHeader.new('kinesis', 'eu-west-1', 'POST', @canonical_uri, '', payload.to_json)
    uri = URI(@endpoint)
    begin
      headers = {
        'Authorization' => aws_auth_header.header,
        'x-amz-Date' => aws_auth_header.amazondate,
        'Host' => aws_auth_header.host,
        'Content-Type' => 'application/x-amz-json-1.1',
        'X-Amz-Target' => 'Kinesis_20131202.PutRecord',
        'Content-Length' => payload.to_json.size.to_s

      }
      puts ">>>>>>>>>>>>>> headers #{__FILE__}:#{__LINE__} <<<<<<<<<<<<<<<<<\n"
      ap headers

      response = RestClient.post(uri.to_s, payload.to_json, headers)
      response_hash = JSON.parse(response.body)
      puts ">>>>>>>>>>>>>> RESPONSE HASH #{__FILE__}:#{__LINE__} <<<<<<<<<<<<<<<<<\n"
      ap response_hash
    rescue => e
      puts "ERROR!!  #{e.class}"
      puts e.response
      raise e
    end
  end



  private

  def generate_data_record
    "RECORD #{SecureRandom.uuid} CREATED AT #{Time.now.strftime('%Y-%m-%d %H:%M:%S.%L')}"
  end

  def partition_key
    '666'
  end

  def generate_payload
    data_record = generate_data_record
    puts ">>>>>>>>>>>>>> DATA RECORD #{__FILE__}:#{__LINE__} <<<<<<<<<<<<<<<<<\n"
    puts data_record
    {
      'Data' => CGI.escape(Base64.strict_encode64(data_record)),
      'PartitionKey'=> partition_key,
      'StreamName' => 'cccd_claims_local'
    }
  end

end

KinesisProducer.new.run