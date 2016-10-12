require 'ap'


class AwsCredential

  SECTION_HEADER_REGEX = /^\s*\[(\S+)\]\s*$/
  ACCESS_KEY_REGEX = /^\s*aws_access_key_id\s*=\s*(\S+)\s/
  ACCESS_SECRET_REGEX = /^\s*aws_secret_access_key\s*=\s*(\S+)\s/
  EXTRACT_VALUE_REGEX = /^.*=\s*(\S+)\s*/

  attr_reader :config

  def initialize(config_file = nil)
    @config = Hash.new( {} )
    file_name = config_file || "#{ENV['HOME']}/.aws/credentials"
    @lines = File.open(file_name).readlines
    @current_section = nil
    parse_config
  end

  def access_key(section = 'default')
    @config[section]['aws_access_key_id']
  end

  def secret(section = 'default')
    @config[section]['aws_secret_access_key']
  end

  private

  def parse_config
    @lines.each do |line|
      if section_header?(line)
        @current_section = extract_section(line)
        @config[@current_section] = {}
      end
      if access_key?(line)
        @config[@current_section]['aws_access_key_id'] = extract_value(line)
      end
      if access_secret?(line)
        @config[@current_section]['aws_secret_access_key'] = extract_value(line)
      end
    end
  end

  def access_key?(line)
    result = line =~ ACCESS_KEY_REGEX
    !result.nil?
  end

  def access_secret?(line)
    result = line =~ ACCESS_SECRET_REGEX
    !result.nil?
  end

  def extract_value(line)
    line =~ EXTRACT_VALUE_REGEX
    $1
  end

  def section_header?(line)
    result = line =~ SECTION_HEADER_REGEX
    !result.nil?
  end

  def extract_section(line)
    line =~ SECTION_HEADER_REGEX
    $1
  end

end

