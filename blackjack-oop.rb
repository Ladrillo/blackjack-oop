class Game
  attr_accessor :state, :brain, :player, :dealer

  def initialize
    @state = State.new
    @brain = Brain.new
    @player = Player.new
    @dealer = Dealer.new
  end

  def play_game
    greeting
    player_name
    loop do
      player_bank      
      player.place_bet
      dealer.deal_first
      if state.any_blackjacks?
        state.display_unhidden
        brain.process_direct_win
      else
        state.display_hidden
        player.hits_or_stands
        dealer.hits_or_stands unless state.player_busted?
        state.display_unhidden
        brain.process_non_direct_win
      end
      break unless player.play_again?
    end
  end

  private

  def greeting
    system 'clear'
    puts logo
    puts "\n" * 3 + " Welcome to the table!"
    puts " Blackjack pays 3 to 2."
    puts " Dealer must draw on 16 and stand on all 17's."
    puts "\n"
  end

  def player_name
    begin
      puts "\n What is your name, friend?"
      name = gets.chomp
    end while name == ''
    state.player_name = name
  end

  def player_bank
    begin
      puts "\n How much money do you have on you? (Max $1000)"
      total_funds = gets.chomp.to_i 
    end while total_funds <= 0 || total_funds > 1000
    state.player_bank_initial = total_funds
    state.player_bank = total_funds
  end
end


class Player
  attr_accessor :name

  def initialize
    @name = ''
  end
end


def initial_state_of_game
  system 'clear'
  puts logo
  puts "\n" * 3 + " Welcome to the table!"
  puts " Blackjack pays 3 to 2."
  puts " Dealer must draw on 16 and stand on all 17's."
  puts "\n"
  initial_state = blank_state
  player_name(initial_state)
  player_bank(initial_state)
  initial_state[:deck] = lambda { deck }
  initial_state
end