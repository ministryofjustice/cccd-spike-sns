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


class HttpConsumer

  def initialize
    @endpoint = 'https://sqs.eu-west-1.amazonaws.com/016649511486/cccd-claims'
    @canonical_uri = '/016649511486/cccd-claims'
  end

  def get_messages
    message_hash = get_message
    while !message_hash.nil?
      puts ">>>>>>>>>>>>>> MESSAGE HASH #{__FILE__}:#{__LINE__} <<<<<<<<<<<<<<<<<\n"
      ap message_hash
      delete_message(message_hash['Message']['ReceiptHandle'])
      message_hash = get_message
    end
    puts "No more messages"
  end


  def get_message
    query_string = 'Action=ReceiveMessage&Version=2012-11-05'
    uri = URI("#{@endpoint}?#{query_string}")
    begin
      aws_auth_header = AwsAuthHeader.new('GET', @canonical_uri, query_string, '')
      response = RestClient.get(uri.to_s, {'Authorization' => aws_auth_header.header, 'x-amz-date' => aws_auth_header.amazondate, 'Host' => aws_auth_header.host })
      hasherize_message(response.body)
    rescue RestClient::Unauthorized, RestClient::Forbidden => e
      puts "ERROR!!  #{e.class}"
      puts e.response
    end
  end

  def delete_message(receipt_handle)
    puts "DELETING MESSAGE WITH THE FOLLOWINF RECEIPT HANDLE"
    puts receipt_handle

    query_string = "Action=DeleteMessage&ReceiptHandle=#{CGI.escape(receipt_handle)}&Version=2012-11-05"
    uri = URI("#{@endpoint}?#{query_string}")
    begin
      auth_header = AwsAuthHeader.new('GET', @canonical_uri, query_string, '')
      response = RestClient.get(uri.to_s, {'Authorization' => auth_header.header, 'x-amz-date' => auth_header.amazondate, 'Host' => auth_header.host })
      puts response.body
    rescue RestClient::Unauthorized, RestClient::Forbidden => e
      puts "ERROR!!  #{e.class}"
      puts e.response
    end
  end

  private


  def hasherize_message(body)
    hash = Hash.from_xml(body)
    hash['ReceiveMessageResponse']['ReceiveMessageResult']
  end
end


c = HttpConsumer.new.get_messages
