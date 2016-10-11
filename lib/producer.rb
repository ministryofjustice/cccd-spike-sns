require 'aws-sdk'
require 'ap'
require 'pp'

class Producer

  def initialize
    # picks up credentials from ~/.aws/credentials file
    @sns = Aws::SNS::Client.new(region: 'eu-west-1')
  end

  def send
    resp = @sns.publish({
                            target_arn: "arn:aws:sns:eu-west-1:016649511486:cccd-claims",
                            message: "This is our message created by Producer.rb at #{Time.now}",
                            subject: "Message of #{Time.now}",
                          })
    puts ">>>>>>>>>>>>>> response #{__FILE__}:#{__LINE__} <<<<<<<<<<<<<<<<<\n"
    pp resp
  end
end


Producer.new.send

