require 'ap'
require 'openssl'
require 'digest'
require 'rest-client'
require 'time'
require 'json'
require 'active_support'
require 'active_support/core_ext'
require 'cgi'
require_relative 'aws_auth_header'

class HttpProducer

  def initialize
    @endpoint = 'https://sqs.eu-west-1.amazonaws.com/016649511486/cccd-claim-responses'
    @canonical_uri = '/016649511486/cccd-claim-responses'
  end

  def post_message
    payload = form_params
    puts ">>>>>>>>>>>>>> payload #{__FILE__}:#{__LINE__} <<<<<<<<<<<<<<<<<\n"
    puts payload


    aws_auth_header = AwsAuthHeader.new('sqs', 'eu-west-1', 'POST', @canonical_uri, '', payload)
    uri = URI(@endpoint)
    begin
      headers = {
        'Authorization' => aws_auth_header.header,
        'x-amz-date' => aws_auth_header.amazondate,
        'Host' => aws_auth_header.host,
        'Content-Type' => 'application/x-www-form-urlencoded'
      }

      puts ">>>>>>>>>>>>>> headers #{__FILE__}:#{__LINE__} <<<<<<<<<<<<<<<<<\n"
      ap headers


      response = RestClient.post(uri.to_s, payload, headers)
      puts response.body
    rescue RestClient::Unauthorized, RestClient::Forbidden => e
      puts "ERROR!!  #{e.class}"
      puts e.response
    end

  end

  private

  def form_params
    params = "Action=SendMessage&MessageBody=#{message_payload}&Version=2012-11-05"
    URI.escape(params)
  end

  def message_payload
    {
      claim_response: {
        claim_id: Time.now.to_i,
        result: 'invalid',
        message: 'No such claim with id 25'
      }
    }.to_xml
  end
end


HttpProducer.new.post_message
