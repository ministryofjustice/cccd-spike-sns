require 'ap'
require 'openssl'
require 'digest'
require 'rest-client'
require 'time'
require 'json'
require 'active_support'
require 'active_support/core_ext'


class HttpConsumer

  def initialize
    @aws_access_key_id, @aws_secret_access_key = get_credentials
    @endpoint = 'https://sqs.eu-west-1.amazonaws.com/016649511486/cccd-claims'
    @query_string = 'Action=ReceiveMessage&Version=2012-11-05'
    @utc_now = Time.now.utc
    @amazondate = @utc_now.strftime('%Y%m%dT%H%M%SZ')
    @date_stamp = @utc_now.strftime('%Y%m%d')
    @host = 'sqs.eu-west-1.amazonaws.com'
  end


  def get_messages
    get_message

  end




  def get_message
    uri = URI("#{@endpoint}?#{@query_string}")
    begin
      response = RestClient.get(uri.to_s, {'Authorization' => authorization_header, 'x-amz-date' => @amazondate, 'Host' => @host })
      decode_message(response.body)
    rescue RestClient::Unauthorized => e
      puts ">>>>>>>>>>>>>> ERROR #{e} #{__FILE__}:#{__LINE__} <<<<<<<<<<<<<<<<<\n"
      puts e.response
    end

  end

  private


  def decode_message(body)
    hash = Hash.from_xml(body)
    ap hash
  end

  def authorization_header
    @canonical_headers = "host:#{@host}\nx-amz-date:#{@amazondate}\n"
    @canonical_uri = '/016649511486/cccd-claims'
    @signed_headers = 'host;x-amz-date'
    @payload_hash = Digest::SHA256.hexdigest ''
    @canonical_request = "GET\n#{@canonical_uri}\n#{@query_string}\n#{@canonical_headers}\n#{@signed_headers}\n#{@payload_hash}"
    @algorithm = 'AWS4-HMAC-SHA256'
    @credential_scope = "#{@date_stamp}/eu-west-1/sqs/aws4_request"
    @string_to_sign = "#{@algorithm}\n#{@amazondate}\n#{@credential_scope}\n#{Digest::SHA256.hexdigest(@canonical_request)}"
    @signing_key = getSignatureKey(@aws_secret_access_key, @date_stamp, 'eu-west-1', 'sqs')
    @signature = OpenSSL::HMAC.hexdigest('sha256', @signing_key, @string_to_sign)

    "#{@algorithm} Credential=#{@aws_access_key_id}/#{@credential_scope}, SignedHeaders=#{@signed_headers}, Signature=#{@signature}"
  end



  def getSignatureKey key, dateStamp, regionName, serviceName
    kDate    = OpenSSL::HMAC.digest('sha256', "AWS4" + key, dateStamp)
    kRegion  = OpenSSL::HMAC.digest('sha256', kDate, regionName)
    kService = OpenSSL::HMAC.digest('sha256', kRegion, serviceName)
    kSigning = OpenSSL::HMAC.digest('sha256', kService, "aws4_request")

    kSigning
  end

  def get_credentials
    default_seen = false
    aws_access_key_id = nil
    aws_secret_access_key = nil
    fp = File.open("#{ENV['HOME']}/.aws/credentials", 'r')
    lines = fp.readlines
    lines.each do |line|
      if line =~ /\[default\]/
        default_seen = true
        next
      end
      if line =~ /aws_access_key_id/ && default_seen
        line =~ /aws_access_key_id\s*=\s*(\S+)/
        aws_access_key_id = $1
        next
      end
      if line =~ /aws_secret_access_key/ && default_seen
        line =~ /aws_secret_access_key\s*=\s*(\S+)/
        aws_secret_access_key = $1
        next
      end
    end
    [aws_access_key_id, aws_secret_access_key]
  end
end



c = HttpConsumer.new

c.get_messages