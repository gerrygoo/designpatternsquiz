# Final Project: Quiz Application with Microservices
# Date: 14-May-2019
# Authors:
#	A01371872 Gerardo Galván
#	A01377503 Ian Neumann
# 	A01371779 Andrés de Lago


require 'sinatra'
require 'Faraday'

QUERTIONS_ENDPOINT = 'https://cxi64jj0b0.execute-api.us-east-2.amazonaws.com/default/quiz_questions'
QUESTIONS_KEY = 'jVv5JUY3R958HMEa27LWK4fDzHvBUKYx8hXHTRUK'

get '/' do
	conn = Faraday.new( :url => QUERTIONS_ENDPOINT )
	res = conn.get do | req |
		req.headers['x-api-key'] = QUESTIONS_KEY
	end

	questions = res.body
	puts(questions)

	erb :home
end