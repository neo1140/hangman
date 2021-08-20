# Class for handling game decicions
class Game
  attr_reader :guesses, :word, :masked_word, :game_over

  # Starts a new game, or loads a saved game
  def initialize(word = '', guesses = 0, masked_word = '')
    @word = word
    @guesses = guesses
    @masked_word = masked_word
    @word = random_word if @word == ''
    @masked_word = word_mask(@word) if @masked_word == ''
    @game_over = false
    p @masked_word
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
    p @masked_word
  end

  # Checks for correct input, and advances the game
  def game_turn(input)
    p @masked_word
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

def save_game(game)
  Dir.mkdir('saves') unless Dir.exist?('saves')
  filename = "saves/hangman_#{game.masked_word}.txt"
  File.open(filename, 'w') do |file|
    file.puts "#{game.word}, #{game.guesses}, #{game.masked_word}"
  end
  puts 'game saved!'
  Dir.children('saves').each_with_index { |save, index| puts "#{index}: #{save}" }
  game.game_end
end

game = Game.new
until game.game_over
  input = gets.chomp
  if input == 'save'
    save_game(game)
  else
    game.game_turn(input)
    p game
  end
end
