require 'ap'
require 'openssl'
require 'digest'
require 'rest-client'
require 'time'


class HttpConsumer

  def initialize(utc_time)
    get_credentials
    # @endpoint = 'https://sqs.eu-west-1.amazonaws.com/016649511486/cccd-claims'
    @endpoint = 'https://ec2.eu-west-1.amazonaws.com'
    @utc_now = Time.parse(utc_time)
    @amazondate = @utc_now.strftime('%Y%m%dT%H%M%SZ')
    @date_stamp = @utc_now.strftime('%Y%m%d')
    @host = 'ec2.eu-west-1.amazonaws.com'
    @canonical_headers = "host:#{@host}\nx-amz-date:#{@amazondate}\n"

    @canonical_uri = '/'
    @query_string = 'Action=DescribeRegions&Version=2013-10-15'
    @signed_headers = 'host;x-amz-date'

    @payload_hash = Digest::SHA256.hexdigest ''
    puts ">>>>>>>>>>>>>> PAYLOAD HASH #{__FILE__}:#{__LINE__} <<<<<<<<<<<<<<<<<\n"
    puts @payload_hash

    @canonical_request = "GET\n#{@canonical_uri}\n#{@query_string}\n#{@canonical_headers}\n#{@signed_headers}\n#{@payload_hash}"
    puts ">>>>>>>>>>>>>> CANONICAL REQUEST #{__FILE__}:#{__LINE__} <<<<<<<<<<<<<<<<<\n"
    puts @canonical_request

    @algorithm = 'AWS4-HMAC-SHA256'
    @credential_scope = "#{@date_stamp}/eu-west-1/ec2/aws4_request"

    @string_to_sign = "#{@algorithm}\n#{@amazondate}\n#{@credential_scope}\n#{Digest::SHA256.hexdigest(@canonical_request)}"
    @signing_key = getSignatureKey(@aws_secret_access_key, @date_stamp, 'eu-west-1', 'ec2')
    @signature = OpenSSL::HMAC.hexdigest('sha256', @signing_key, @string_to_sign)

    @authorization_header = "#{@algorithm} Credential=#{@aws_access_key_id}/#{@credential_scope}, SignedHeaders=#{@signed_headers}, Signature=#{@signature}"
  end

  def hexprint(string)
    res = ''
    string.each_byte{ |b| res << sprintf(" %02x", b) }
    puts res
  end

  def get
    uri = URI("#{@endpoint}?#{@query_string}")
    begin
      response = RestClient.get(uri.to_s, {'Authorization' => @authorization_header, 'x-amz-date' => @amazondate, 'Host' => @host })
      puts response.body
    rescue RestClient::Unauthorized => e
      puts ">>>>>>>>>>>>>> ERROR #{e} #{__FILE__}:#{__LINE__} <<<<<<<<<<<<<<<<<\n"
      puts e.response
    end
    
  end




  private
  def sig
    getSignatureKey(@aws_access_key_id, @datestamp, 'eu-west-1', 'ec2')
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
    fp = File.open("#{ENV['HOME']}/.aws/credentials", 'r')
    lines = fp.readlines
    lines.each do |line|
      if line =~ /\[default\]/
        default_seen = true
        next
      end
      if line =~ /aws_access_key_id/ && default_seen
        line =~ /aws_access_key_id\s*=\s*(\S+)/
        @aws_access_key_id = $1
        next
      end
      if line =~ /aws_secret_access_key/ && default_seen
        line =~ /aws_secret_access_key\s*=\s*(\S+)/
        @aws_secret_access_key = $1
        next
      end

    end
  end



end

puts ARGV.first
c = HttpConsumer.new(ARGV.first)

c.get