class GamesController < ApplicationController
  require 'open-uri'
  require 'json'
  def new
    @grid = (0...10).map { ('a'..'z').to_a[rand(26)] }
    @start_time = Time.now
  end

  def score
    @attempt = params[:word]
    @end_time = Time.now
    result = run_game(@attempt, @grid, @start_time, @end_time)
    @time_elapsed = result[:time]
    @user_score = result[:score]
    @message = result[:message]
  end

  def valid_word(attempt, grid)
    guess = attempt.upcase.chars.sort
    sample = grid.sort
    regex = Regexp.new ".*#{guess.join('.*')}"
    sample.join.match?(regex)
  end

  def run_game(attempt, grid, start_time, end_time)
  # TODO: runs the game and return detailed hash of result (with `:score`, `:message` and `:time` keys)
    url = "https://wagon-dictionary.herokuapp.com/#{attempt}"
    user_serialized = URI.open(url).read
    user = JSON.parse(user_serialized)
    # attempt.upcase.chars.sort.join == grid.sort.join
    if valid_word(attempt, grid) && user['found'] == true
      { score: 100 - (end_time - start_time) + attempt.length, message: "well done", time: end_time - start_time }
    elsif user['found'] == false
      { score: 0, message: "not an english word", time: end_time - start_time }
    elsif !valid_word(attempt, grid)
      { score: 0, message: "not in the grid", time: end_time - start_time }
    end
  end
end
