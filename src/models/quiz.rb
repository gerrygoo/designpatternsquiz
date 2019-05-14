# Final Project: Quiz Application with Microservices
# Date: 14-May-2019
# Authors:
#	A01371872 Gerardo Galván
#	A01377503 Ian Neumann
# 	A01371779 Andrés de Lago

require 'json'

class Quiz
    def initialize data = { }
        with_defaults = {
            user_name: data["user_name"] || data[:user_name] || 'no_name',
            questions: data["questions"] || data[:questions] || [ ],
            progress: data["progress"] || data[:progress] || 0,
            score: data["score"] || data[:progress] ||  0
        }
        @data = with_defaults
    end


    def user_name
        @data[:user_name]
    end

    def questions
        @data[:questions]
    end

    def progress
        @data[:progress]
    end

    def score
        @data[:score]
    end

    def done
        @data[:progress] >= @data[:questions].length
    end


    def current_question
        raise 'quiz: current_question: no question available' if ( self.done or @data[:questions].empty? )
        @data[:questions][@data[:progress]]
    end

    def answer_question answer
        correct_answer = self.current_question["answer"]
        was_answer_correct = answer == correct_answer
        @data[:progress] += 1
        @data[:score] += 1 if was_answer_correct
        was_answer_correct
    end


    def to_s
        self.to_json
    end

    def to_json
        @data.to_json
    end
end
