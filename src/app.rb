# Final Project: Quiz Application with Microservices
# Date: 14-May-2019
# Authors:
#	A01371872 Gerardo Galván
#	A01377503 Ian Neumann
# 	A01371779 Andrés de Lago

require 'sinatra'
require 'json'

require 'models/api'
require 'models/quiz'

enable :sessions
api = API.instance

get '/' do
	puts('get')
	erb :home
end

post '/play' do
	quiz = nil

	if session[:quiz] then
		quiz = Quiz.new( JSON.load( session[:quiz].to_s ) )
	else
		quiz = Quiz.new({
			user_name: params['name'],
			questions: api.get_questions(params['quetion_number'])
		})
		session[:quiz] = quiz.to_json
	end


	if params['answer']
		answer = params['answer']
		quiz.answer_question answer
		session[:quiz] = quiz.to_json
	end

	redirect '/done' if quiz.done

	@question = quiz.current_question
	erb :game
end

get '/done' do
	if not session[:quiz] then
		return erb :not_found
	end

	@quiz = Quiz.new( JSON.load( session[:quiz].to_s ) )

	api.post_score @quiz.user_name, @quiz.score

	@scores = api.get_scores

	erb :done
end


post '/done' do
	if not session[:quiz] or not params['phone_number'] then
		return erb :not_found
	end

	quiz = session[:quiz]
	api.post_sms params['phone_number'], "Your Design Patterns Score was #{ quiz.score }"

	sesion.delete(:quiz)
	redirect '/'
end