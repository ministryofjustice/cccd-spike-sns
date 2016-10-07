require 'aws-sdk'
require 'ap'
require 'pp'
require 'json'

class SqsConsumer

  def initialize
    @client = Aws::SQS::Client.new()
    @q_url = 'https://sqs.eu-west-1.amazonaws.com/016649511486/cccd-claims'
  end


  def get
    5.times do
      consume
    end

    puts ">>>>>>>>>>>>>> STARTING THE SECOND LOOP #{__FILE__}:#{__LINE__} <<<<<<<<<<<<<<<<<\n"
    5.times do
      consume
    end
  end


  private
  def consume
    puts ">>>>>>>>>>>>>> receive_messages #{__FILE__}:#{__LINE__} <<<<<<<<<<<<<<<<<\n"
    response = @client.receive_message(queue_url: @q_url, max_number_of_messages: 10)
    puts "No. of messages: #{response.messages.size}"
    response.messages.each do |message|
      puts "message_id: #{message.message_id}"
      hash = JSON.parse(message.body)
      puts "message: #{hash['Message']}"
      puts "internal message id: #{hash['MessageId']}"
      puts "receipt_handle: #{message.receipt_handle}"
      puts "  "
      @client.delete_message(queue_url: @q_url, receipt_handle: message.receipt_handle)
    end
  end



end

SqsConsumer.new.get