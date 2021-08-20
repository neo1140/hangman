# Class for handling game decicions
class Game
  attr_reader :guesses, :word, :masked_word, :game_over

  def initialize(word='', guesses=0, masked_word='')
    @word = word
    @guesses = guesses
    @masked_word = masked_word
    @word = random_word if @word == ''
    @masked_word = word_mask(@word) if @masked_word == ''
    @game_over = false
    p @masked_word
  end

  def random_word
    dictionary = File.readlines('5desk.txt')
    wordchoice = rand(0..61405)
    dictionary.each_with_index { |word, index| return word.chomp.downcase if index == wordchoice }
  end

  def word_mask(word)
    mask = ''
    mask.rjust(word.length, '-')
  end

  def game_turn(input)
    p @masked_word
    if @word.include?(input)
      @word.split('').each_with_index do |letter, index|
        if letter == input
          word_array = @masked_word.split('')
          word_array[index] = letter
          @masked_word = word_array.join
        end
      end
      p @masked_word
    else
      @guesses += 1
    end
    game_end if @guesses == 10 || @masked_word == @word
  end

  def game_end
    @game_over = true
  end
end

def save_game(game)
  Dir.mkdir('saves') unless Dir.exist?('saves')
  filename = "saves/#{@word}.txt"
  File.open(filename, 'w') do |file|
    file.puts "#{game.word}, #{game.guesses}, #{game.masked_word}"
  end
  puts 'game saved!'
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
