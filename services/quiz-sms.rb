# Final Project: Quiz Application with Microservices
# Date: 14-May-2019
# Authors:
#	  A01371872 Gerardo Galván
# 	A01377503 Ian Neumann
# 	A01371779 Andrés de Lago

require 'json'
require 'aws-sdk'

# The sns client object
QUIZ_SNS = Aws::SNS::Client.new({
  region: "us-east-1"
})

# constructs and returns a response object given request info
def make_response(status, body)
  {
    statusCode: status,
    body: JSON.pretty_generate(body)
  }
end

# handles a get event
def handle_get(event)
  make_response(200, get_scores)
end

# parses a request body into json
def parse_body(str)
  begin
    data = JSON.parse(str)
    if data.key?('phoneNumber') and data.key?('message')
      data
    else
      nil
    end
  rescue JSON::ParserError
    nil
  end
end

# sends an sms given event's body params
def send_sms(event)
    data = parse_body(event['body'])
    if data
      QUIZ_SNS.publish(
        phone_number: data['phoneNumber'], # Replace with a valid mobile phone number
        message: data['message']
      )
      true
    else
      false
    end
end

# handles a get event
def handle_post
  make_response(201, {message: 'SMS sent!'})
end

# handles a bad request event
def handle_bad_request
  make_response(400, {message: 'Bad request (invalid input)'})
end

# handles a bad method event
def handle_bad_method(method)
  make_response(405, {message: "Method not supported: #{ method }"})
end

# the driver method for this lambda
def lambda_handler(event:, context:)
  method = event['httpMethod']
  if method == 'POST'
    result = send_sms(event)
    if result
      handle_post
    else
      handle_bad_request
    end
  else
    handle_bad_method(method)
  end
end
