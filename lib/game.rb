require 'yaml'
# Class for handling game decicions
class Game
  attr_reader :guesses, :word, :masked_word, :game_over, :letters_guessed

  # Starts a new game, or loads a saved game
  def initialize
    @guesses = 0
    @word = random_word
    @masked_word = word_mask(@word)
    @game_over = false
    @letters_guessed = []
  end

  # Fetches a random word from the dictionary file
  def random_word
    dictionary = File.readlines('5desk.txt')
    wordchoice = rand(0..61_405)
    dictionary.each_with_index { |word, index| return word.chomp.downcase if index == wordchoice }
  end

  # Covers up a new word for display
  def word_mask(word)
    mask = ''
    mask.rjust(word.length, '-')
  end

  # Updates display when user inputs the correct letter
  def update(input)
    @word.split('').each_with_index do |letter, index|
      next unless letter == input

      word_array = @masked_word.split('')
      word_array[index] = letter
      @masked_word = word_array.join
    end
  end

  # Checks for correct input, and advances the game
  def game_turn(input)
    @letters_guessed << input
    if @word.include?(input)
      update(input)
    else
      @guesses += 1
    end
    game_end if @guesses == 10 || @masked_word == @word
  end

  # Sets game state to over
  def game_end
    @game_over = true
  end
end

# Class for controlling flow of the game
class GameTree
  # Function to get things started
  def self.start
    puts 'Hello! Welcome to Hangman! Type \'load\' to load a game, or enter to start a new game!'
    input = gets.chomp
    if input == 'load'
      save_select
    else
      new_game
    end
  end

  # Function for starting a new game
  def self.new_game
  @game = Game.new
  choice
  end

  # Function for controlling game flow
  def self.choice
    if @game.game_over
      terminate_game
    else
      puts @game.masked_word
      puts "The letters you've guessed so far are\n#{@game.letters_guessed}\nYou have #{10 - @game.guesses} guesses left!"
      puts 'Enter a letter to play, or enter "save/load" to save or load your game!'
      input = gets.chomp.downcase
      save_game if input == 'save'
      save_select if input == 'load'
      if input =~ /^[a-z]$/ && !@game.letters_guessed.include?(input)
        @game.game_turn(input)
      else
        puts 'Invalid input! Please enter an unused letter, or "save/load"'
      end
      choice
    end
  end

  # Function for saving the game
  def self.save_game
    Dir.mkdir('saves') unless Dir.exist?('saves')
    puts 'What would you like to name your save game?'
    filename = "saves/#{gets.chomp}"
    filename = "saves/hangman_#{@game.masked_word}.txt" if filename == 'saves/'
    File.open(filename, 'w') do |file|
      file.puts YAML.dump(@game)
    end
    puts "Game saved as #{filename}"
    terminate_game
  end

  # Function called to select which game to load
  def self.save_select
    puts 'Enter the number of the game you would like to load!'
    Dir.children('saves').each_with_index { |save, index| puts "#{index + 1}: #{save.delete('.txt')}" }
    save_file_index = (gets.chomp.to_i - 1)
    load_game(save_file_index)
  end

  # Function for loading the game
  def self.load_game(save_file_index)
    Dir.children('saves').each_with_index do |save, index|
      next unless index == save_file_index

      File.open("saves/#{save}", 'r') do |file|
        @game = YAML.safe_load(file, [Game])
        choice
      end
    end
  end

  # Called when the game is over, checks game state and gives feedback to player
  def self.terminate_game
    puts 'You win! congratulations!!' if @game.masked_word == @game.word
    puts "You lose, the word was #{@game.word}\nI\'m sorry, give it another try!\n" if @game.guesses == 10
    puts 'Would you like to play again? enter "y" if you do!'
    input = gets.chomp.downcase
    GameTree.start if input == 'y'
    puts 'Thanks for playing!'
  end
end

GameTree.start
