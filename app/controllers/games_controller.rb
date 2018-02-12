require 'open-uri'
require 'json'

class GamesController < ApplicationController
  def new
    def generate_grid(grid_size)
      # TODO: generate random grid of letters
      array = (1..grid_size).to_a
      new_array = array.map do
        ("A".."Z").to_a.sample
      end
      return new_array
    end
    @letters = generate_grid(10)
  end

  def score
    if session[:score].nil?
        session[:score] = 0
    end
    @input = params[:input]
    letters = params[:letters].split(" ")

    def create_hash_counter(array)
      hash_result = {}
      array.each do |word|
        if hash_result.key?(word.downcase)
          hash_result[word.downcase] += 1
        else
          hash_result[word.downcase] = 1
        end
      end
      return hash_result
    end

    def inside_grid?(attempt, grid)
      attempt_array = attempt.upcase.split("")
      condition = create_hash_counter(attempt_array).all? do |key, value|
        create_hash_counter(grid).key?(key) && (value <= create_hash_counter(grid)[key])
      end
      return condition
    end

    def english_word?(attempt)
      url = "https://wagon-dictionary.herokuapp.com/#{attempt}"
      jokes_serialised = open(url).read
      hash_english_word = JSON.parse(jokes_serialised)
      return hash_english_word["found"]
    end

    test = english_word?(@input)

    if !inside_grid?(@input,letters)
      @output = "Sorry but #{@input} can't be built out with #{params[:letters]}"
    elsif !english_word?(@input)
      @output = "Sorry but #{@input} does not seem to be an english word"
    else
      @output = "Congratulations! #{@input} is a valid English word"
      @score = @input.length
      session[:score] += @score
    end
  end
end
