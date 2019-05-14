# Final Project: Quiz Application with Microservices
# Date: 14-May-2019
# Authors:
#   Ariel Ortiz
#	  A01371872 Gerardo Galván
#	  A01377503 Ian Neumann
# 	A01371779 Andrés de Lago


require 'json'
require 'aws-sdk-dynamodb'

# handles a bad method event
DYNAMODB = Aws::DynamoDB::Client.new
# the dynamodb table name
TABLE = 'quiz_scores'

# constructs and returns a response object given request info
def make_response(status, body)
  {
    statusCode: status,
    body: JSON.pretty_generate(body)
  }
end

# sorts items by descending scores and ascending timestamp
def sort_items_by_descending_scores_and_ascending_timestamp(items)
  items.sort! {|a, b| a['timestamp'] <=> b['timestamp']}
  items.sort! {|a, b| b['score'] <=> a['score']}
end

# translates dynamo a item list into score results
def make_result_list(items)
  items.map {|item| {
    'initials': item['initials'],
    'timestamp': item['timestamp'],
    'score': item['score'].to_i # Convert BigDecimal to Integer
  }}
end

# fetches questions from dynamo
def get_scores
  items = DYNAMODB.scan(table_name: TABLE).items
  sort_items_by_descending_scores_and_ascending_timestamp(items)
  make_result_list(items)
end

# handles a get event
def handle_get(event)
  make_response(200, get_scores)
end

# parses a request body into json
def parse_body(str)
  begin
    data = JSON.parse(str)
    if data.key?('initials') and data.key?('score')
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
      data['timestamp'] = Time.now.to_s
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
  make_response(201, {message: 'New score added!'})
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
