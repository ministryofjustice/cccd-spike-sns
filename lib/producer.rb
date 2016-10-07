require 'aws-sdk'
require 'ap'
require 'pp'

class Producer

  def initialize
    # put credentials in env vars AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY
    # @sns = Aws::SNS::Client.new(region: 'eu-west-1', credentials: Aws::Credentials.new('AKIAIOWLSZF6I6VDV4WQ', 'mDyTGbCsPLXZvSLwFK7lRvdbp2WmQQMO4igr3pPw'))
    @sns = Aws::SNS::Client.new(region: 'eu-west-1')
  end

  def send
    resp = @sns.publish({
                            target_arn: "arn:aws:sns:eu-west-1:016649511486:cccd-claims",
                            message: "This is our message created by Producer.rb at #{Time.now}",
                            subject: "Message of #{Time.now}",
                            # message_structure: "messageStructure",
                            # message_attributes: {
                            #   "String" => {
                            #     data_type: "String data type",
                            #     string_value: "String",
                            #     binary_value: "data",
                            #   },
                            # },
                          })
    puts ">>>>>>>>>>>>>> response #{__FILE__}:#{__LINE__} <<<<<<<<<<<<<<<<<\n"
    pp resp
  end
end


Producer.new.send

