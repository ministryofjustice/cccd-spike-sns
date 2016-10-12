require 'spec_helper'
require_relative '../lib/aws_credential'

describe 'AwsCredential' do

  let(:ac) { AwsCredential.new(File.join(File.dirname(__FILE__), 'data', 'creds')) }

  describe 'secret' do
    it 'returns secret for default section' do
      expect(ac.secret('default')).to eq 'MY_DEFAULT_SECRET+'
    end

    it 'returns nil if no such section' do
      expect(ac.secret('xxx')).to be_nil
    end
  end

  describe 'access_key' do
    it 'returns secret for cccd section' do
      expect(ac.access_key('cccd')).to eq 'MY_CCCD_AWS_ACCESS_KEY'
    end

    it 'returns nil if no such section' do
      expect(ac.access_key('xxx')).to be_nil
    end
  end



end