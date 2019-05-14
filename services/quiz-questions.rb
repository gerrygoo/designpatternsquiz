# Final Project: Quiz Application with Microservices
# Date: 14-May-2019
# Authors:
#	  A01371872 Gerardo Galván
# 	A01377503 Ian Neumann
# 	A01371779 Andrés de Lago

require 'json'
require 'aws-sdk-dynamodb'
require 'securerandom'

# the dynamodb client
DYNAMODB = Aws::DynamoDB::Client.new
# the dynamodb table name
TABLE = 'quiz_questions'

# constructs and returns a response object given request info
def make_response(status, body)
  {
    statusCode: status,
    body: JSON.pretty_generate(body)
  }
end

# translates dynamo a item list into question results
def make_result_list(items)
  items.map {|item| {
    id: item['id'],
    question: item['question'],
    options: item['options'],
    answer: item['answer'].to_i  # Convert BigDecimal to Integer
  }}
end

# fetches questions from dynamo
def get_questions(count)
  clamped_count = count.to_i.clamp(1,10)
  items = DYNAMODB.scan(table_name: TABLE).items
  result = items.sample(clamped_count)
  make_result_list(result)
end

# handles a get event
def handle_get(event)
  query_params = event['queryStringParameters']
  if query_params
    count = query_params['count'] || 5
    make_response(200, get_questions(count))
  else
    make_response(200, get_questions(5))
  end
end

# parses a request body into json
def parse_body(str)
  begin
    data = JSON.parse(str)
    if data.key?('question') and data.key?('options') and data.key?('answer')
      data['id'] = SecureRandom.uuid
      data
    else
      nil
    end
  rescue JSON::ParserError
    nil
  end
end

# writes an event's body into dynamo
def store_item(event)
    data = parse_body(event['body'])
    if data
      DYNAMODB.put_item({
        table_name: TABLE,
        item: data
      })
      true
    else
      false
    end
end

# handles a post event
def handle_post
  make_response(201, {message: 'New question added!'})
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
  if method == 'GET'
    handle_get(event)
  elsif method == 'POST'
    result = store_item(event)
    if result
      handle_post
    else
      handle_bad_request
    end
  else
    handle_bad_method(method)
  end
end
