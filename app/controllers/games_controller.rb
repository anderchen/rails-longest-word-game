require 'open-uri'
require 'json'

class GamesController < ApplicationController
  def index
    reset_session
    session[:total_score] = 0
  end

  def new
    consonants = %w(B C D F G H J K L M N P Q R S T V X Z).sample(5)
    vowels = %W(A E I O U).sample(5)

    @array_random_letters = (consonants + vowels).shuffle

    @start_time = Time.now
  end

  def score
    @word = params[:word]
    @array_random_letters = params[:array_random_letters]
    @start_time = Time.parse(params[:start_time])
    @end_time = Time.now

    @result = { score: @array_random_letters.split.length / (@end_time - @start_time), time: (@end_time - @start_time), message: "" }

    if check_word_exist(@word) == false
      @result = { message: "Sorry but #{@word.upcase} does not seem to be a valid English word", score: 0 }
    elsif check_letter_grid(@word, @array_random_letters) == false
      @result = { message: "Sorry but #{@word.upcase} can't be built out of #{@array_random_letters}", score: 0 }
    else
      @result[:message] = "Congratulations! #{@word.upcase} is a valid english word!"
    end
    session[:total_score] += @result[:score]
  end

  private

  def check_letter_grid(word, array_random_letters)
    count = 0
    word.upcase.split('').each do |letter|
      if array_random_letters.split.include? letter
        array_random_letters.split.delete_at(array_random_letters.index(letter))
        count += 1
      end
    end
    return word.length == count
  end

  def check_word_exist(word)
    url = "https://wagon-dictionary.herokuapp.com/#{@word}"
    user_serialized = open(url).read
    @user = JSON.parse(user_serialized)

    @user['found'] == true
  end
end
