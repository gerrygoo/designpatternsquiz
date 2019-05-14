# Final Project: Quiz Application with Microservices
# Date: 14-May-2019
# Authors:
#	A01371872 Gerardo Galván
#	A01377503 Ian Neumann
# 	A01371779 Andrés de Lago

require 'json'

# The +Quiz+ class is a 'data class' that models a quiz game.
class Quiz

    # Constructs a new Quiz object with either provided data or default data
    # the member data is ever-wrapped in an associative array for easy JSON
    # serialization
    #
    # Parameter::
    #   data:: The quiz data the new object will model.
    #
    # Returns:: A new quiz object.
    def initialize data = { }
        with_defaults = {
            user_name: data["user_name"] || data[:user_name] || 'no_name',
            questions: data["questions"] || data[:questions] || [ ],
            progress: data["progress"] || data[:progress] || 0,
            score: data["score"] || data[:progress] ||  0
        }
        @data = with_defaults
    end

    # Convenient accessor for the classes' data user_name field
    def user_name
        @data[:user_name]
    end

    # Convenient accessor for the classes' data questions field
    def questions
        @data[:questions]
    end

    # Convenient accessor for the classes' data progress field
    def progress
        @data[:progress]
    end

    # Convenient accessor for the classes' data score field
    def score
        @data[:score]
    end

    # Convenient accessor for the classes' data done field
    def done
        @data[:progress] >= @data[:questions].length
    end

    # Creates a new greeter object.
    #
    # Parameter::
    #
    # Returns:: The last not-solved question.
    #
    # Raises:: +Something+ if +self.done+ or there are not any questions.
    def current_question
        raise 'quiz: current_question: no question available' if ( self.done or @data[:questions].empty? )
        @data[:questions][@data[:progress]]
    end

    # Answers the current question.
    # Updates the quiz state.
    # Parameter::
    #   answer:: The answer to the question
    #
    # Returns:: True if the question was answered correctly, False otherwise.
    def answer_question answer
        correct_answer = self.current_question["answer"]
        was_answer_correct = "#{answer}" == "#{correct_answer}"
        @data[:progress] += 1
        @data[:score] += 1 if was_answer_correct
        puts 'onanswer', answer, correct_answer, was_answer_correct, @data[:score]
        was_answer_correct
    end

    # Computes the quiz' string representation.
    #
    # Returns:: the quiz' string representation.
    def to_s
        self.to_json
    end

    # Computes the quiz' JSON representation.
    #
    # Returns:: the quiz' JSON representation.
    def to_json
        @data.to_json
    end
end
