# Final Project: Quiz Application with Microservices
# Date: 14-May-2019
# Authors:
#	A01371872 Gerardo Galván
#	A01377503 Ian Neumann
# 	A01371779 Andrés de Lago

require 'Faraday'
require 'singleton'


QUESTIONS_ENDPOINT = 'https://cxi64jj0b0.execute-api.us-east-2.amazonaws.com/default/quiz_questions'
QUESTIONS_KEY = 'jVv5JUY3R958HMEa27LWK4fDzHvBUKYx8hXHTRUK'

SCORE_ENDPOINT = 'https://t32wtpon7k.execute-api.us-east-2.amazonaws.com/default/quiz_score'
SCORE_KEY = 'YtB1AtYNz3bU0fSEhI2q1lmECbdoZng22ZYeCs15'

SMS_ENDPOINT = 'https://t32wtpon7k.execute-api.us-east-2.amazonaws.com/default/quiz_score'
SMS_KEY = 'jCI1WzYUnM7LxjbmjoF5HaC1Gz4gsfVN1T2VpC9C'

class API
    include Singleton

    def initialize
        @questions_conn = Faraday.new :url => QUESTIONS_ENDPOINT
        @score_conn = Faraday.new :url => SCORE_ENDPOINT
        @sms_conn = Faraday.new :url => SMS_ENDPOINT
    end

    def get_from conn, key, params = { }
        res = conn.get do | req |
            req.headers['x-api-key'] = key
            req.params = params
        end
        JSON.parse res.body
    end

    def post_to conn, key, body = { }
        res = conn.post do | req |
            req.headers['x-api-key'] = key
            req.body = body
        end
        JSON.parse res.body
    end


    def get_questions number = 5
        self.get_from @questions_conn, QUESTIONS_KEY, { count: number }
    end

    def get_scores
        self.get_from @score_conn, SCORE_KEY
    end

    def post_score initials, score = 0
        self.post_to @score_conn, SCORE_KEY, JSON.generate({ initials: initials, score: score })
    end

    def post_sms phoneNumber, message
        self.post_to @sms_conn, SMS_KEY, JSON.generate({ phoneNumber: phoneNumber, message: message })
    end

end
