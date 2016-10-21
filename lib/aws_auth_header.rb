require 'ap'
require 'openssl'
require 'digest'
require 'rest-client'
require 'time'
require 'json'
require 'active_support'
require 'active_support/core_ext'
require 'cgi'
require_relative 'aws_credential'


class AwsAuthHeader

  attr_reader :header, :amazondate, :host

  def initialize(service, region, http_method, canonical_uri, query_string, payload)
    @credentials = AwsCredential.new
    @utc_now = Time.now.utc
    @amazondate = @utc_now.strftime('%Y%m%dT%H%M%SZ')
    @date_stamp = @utc_now.strftime('%Y%m%d')
    @host = "#{service}.#{region}.amazonaws.com"
    @canonical_headers = "host:#{@host}\nx-amz-date:#{@amazondate}\n"

    signed_headers = 'host;x-amz-date'
    payload_hash = Digest::SHA256.hexdigest payload
    canonical_request = "#{http_method}\n#{canonical_uri}\n#{query_string}\n#{@canonical_headers}\n#{signed_headers}\n#{payload_hash}"

    puts ">>>>>>>>>>>>>> CANONICAL REQUEST #{__FILE__}:#{__LINE__} <<<<<<<<<<<<<<<<<\n"
    ap canonical_request


    algorithm = 'AWS4-HMAC-SHA256'
    credential_scope = "#{@date_stamp}/#{region}/#{service}/aws4_request"
    string_to_sign = "#{algorithm}\n#{@amazondate}\n#{credential_scope}\n#{Digest::SHA256.hexdigest(canonical_request)}"
    signing_key = getSignatureKey(@credentials.secret, @date_stamp, region, service)
    signature = OpenSSL::HMAC.hexdigest('sha256', signing_key, string_to_sign)
    @header = "#{algorithm} Credential=#{@credentials.access_key}/#{credential_scope}, SignedHeaders=#{signed_headers}, Signature=#{signature}"
  end

  private

  def getSignatureKey key, dateStamp, regionName, serviceName
    kDate    = OpenSSL::HMAC.digest('sha256', "AWS4" + key, dateStamp)
    kRegion  = OpenSSL::HMAC.digest('sha256', kDate, regionName)
    kService = OpenSSL::HMAC.digest('sha256', kRegion, serviceName)
    kSigning = OpenSSL::HMAC.digest('sha256', kService, "aws4_request")
    kSigning
  end

end