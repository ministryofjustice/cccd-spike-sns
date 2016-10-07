require 'aws-sdk'
require 'ap'
require 'pp'
require 'json'

class SqsPoller

  def initialize
    @poller = Aws::SQS::QueuePoller.new('https://sqs.eu-west-1.amazonaws.com/016649511486/cccd-claims')
  end


  def run
    @poller.poll do |message|
      puts ">>>>>>>>>>>>>> MESSAGE #{__FILE__}:#{__LINE__} <<<<<<<<<<<<<<<<<\n"
      hash = JSON.parse(message.body)
      puts "message: #{hash['Message']}"
      puts "internal message id: #{hash['MessageId']}"
      puts "  "
    end
  end
end



SqsPoller.new.run