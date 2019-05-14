# Final Project: Quiz Application with Microservices
# Date: 14-May-2019
# Authors:
#	A01371872 Gerardo Galván
#	A01377503 Ian Neumann
# 	A01371779 Andrés de Lago

require 'Faraday'
require 'singleton'

# The questions microservice endpoint url
QUESTIONS_ENDPOINT = 'https://cxi64jj0b0.execute-api.us-east-2.amazonaws.com/default/quiz_questions'
# The questions microservice api key
QUESTIONS_KEY = 'jVv5JUY3R958HMEa27LWK4fDzHvBUKYx8hXHTRUK'

# The score microservice endpoint url
SCORE_ENDPOINT = 'https://t32wtpon7k.execute-api.us-east-2.amazonaws.com/default/quiz_score'
# The score microservice api key
SCORE_KEY = 'YtB1AtYNz3bU0fSEhI2q1lmECbdoZng22ZYeCs15'

# The sms microservice endpoint url
SMS_ENDPOINT = 'https://pibdr9ji00.execute-api.us-east-2.amazonaws.com/default/quiz_sms'
# The sms microservice api key
SMS_KEY = 'jCI1WzYUnM7LxjbmjoF5HaC1Gz4gsfVN1T2VpC9C'

# The +API+ is an implementation of the Singleton
# pattern. It allows convenient access to our microservices.
class API
    include Singleton

    # Creates a new API object.
    #
    # Returns:: The new API object.
    def initialize
        @questions_conn = Faraday.new :url => QUESTIONS_ENDPOINT
        @score_conn = Faraday.new :url => SCORE_ENDPOINT
        @sms_conn = Faraday.new :url => SMS_ENDPOINT
    end

    # Performs a get request with parameters on a given connection object
    # using a given api key header.
    #
    # Parameter::
    #   conn:: The connection object to use.
    #   key:: The key sring to use as the +x-api-key+ header.
    #   params:: Query parameters to send.
    #
    # Returns:: The request's response's body as a dictionary.
    def get_from conn, key, params = { }
        res = conn.get do | req |
            req.headers['x-api-key'] = key
            req.params = params
        end
        JSON.parse res.body
    end

    # Performs a post request with a given body on a given connection object
    # using a given api key header.
    #
    # Parameter::
    #   conn:: The connection object to use.
    #   key:: The key sring to use as the +x-api-key+ header.
    #   body:: Request body to send.
    #
    # Returns:: The request's response's body as a dictionary.
    def post_to conn, key, body = { }
        res = conn.post do | req |
            req.headers['x-api-key'] = key
            req.body = body
        end
        JSON.parse res.body
    end


    # Gets a given number of random questions from the question microservice.
    #
    # Parameter::
    #   number:: The quantity of questions to get.
    #
    # Returns:: An array of questions.
    def get_questions number = 5
        self.get_from @questions_conn, QUESTIONS_KEY, { count: number }
    end

    # Gets the game's scoreboard from the scores microservice.
    #
    # Returns:: An array of scores.
    def get_scores
        self.get_from @score_conn, SCORE_KEY
    end

    # Posts a name, score pair to the scores microservice.
    #
    # Returns:: The microservice's response.
    def post_score initials, score = 0
        self.post_to @score_conn, SCORE_KEY, JSON.generate({ initials: initials, score: score })
    end

    # Posts an sms requesr to the sms microservice.
    # Parameter::
    #   phoneNumber:: The phone number to send stuff to.
    #   message:: The message sring to send.
    #
    # Returns:: The microservice's response.
    def post_sms phoneNumber, message
        self.post_to @sms_conn, SMS_KEY, JSON.generate({ phoneNumber: phoneNumber, message: message })
    end

end
