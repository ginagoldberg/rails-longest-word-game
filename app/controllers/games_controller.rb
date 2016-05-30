require 'open-uri'
require 'json'
# require 'awesome_print'

class GamesController < ApplicationController
  def game
    @grid = generate_grid(10)
  end

  def score
    @start_time = params[:start_time]
    @end_time = Time.now
    @user_word = params[:user_input]
    @grid = params[:grid].split("")
    @results = run_game(@user_word, @grid, @start_time, @end_time)
    # @score = calc_score(@user_word, @results[:time])
  end


  private

  def generate_grid(grid_size)
    vowels = %w(A E I O U Y)
    alphabet = ('A'..'Z').to_a

    random_grid = []

    (grid_size - 1).times { random_grid << alphabet.sample }
    random_grid << vowels.sample
  end



  def check_grid(user_input, grid_letters)

    letters_to_check = user_input.upcase.chars

    input = true
    letters_to_check.each do |letter|
      input = false if !grid_letters.include?(letter)
    end
  end


  def check_dic(attempt)
    api_url = "http://api.wordreference.com/0.8/80143/json/enfr/#{attempt}"

    open(api_url) do |dic_text|
      dic_words = JSON.parse(dic_text.read)
      if dic_words['term0'].nil?
        return false
      else
        translation = dic_words['term0']['PrincipalTranslations']['0']['FirstTranslation']['term']
      end
    end
  end


  def calc_score(word, elapsed_time)
    (word.length * 12 ) / elapsed_time
  end

  def run_game(attempt, grid, start_time, end_time)
    if check_grid(attempt, grid) == false
      @error = "This word does not use the letters in the provided grid"
    else
      checking = check_dic(attempt)
      if checking  == false
        return result =
        {
          time:0,
          translation:"not a word",
          score: 0
        }

      else
        elapsed_time = end_time - Time.parse(start_time)
        result = {
          time: elapsed_time,
          translation: checking,
          score: calc_score(attempt, elapsed_time),
        }
      end

    end
  end
end
