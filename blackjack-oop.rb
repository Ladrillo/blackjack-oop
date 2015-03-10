# encoding: UTF-8
require 'pry'

class Game
  attr_accessor :state, :brain, :player, :dealer

  def initialize    
    @brain = Brain.new
    @player = Player.new
    @dealer = Dealer.new
  end

  def play_game
    loop do
      @state = State.new
      greeting
      player_name    
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

  def logo
  '
   ______ _            _    _            _    
   | ___ \ |          | |  (_)          | |   
   | |_/ / | __ _  ___| | ___  __ _  ___| | __
   | ___ \ |/ _` |/ __| |/ / |/ _` |/ __| |/ /
   | |_/ / | (_| | (__|   <| | (_| | (__|   < 
   \____/|_|\__,_|\___|_|\_\ |\__,_|\___|_|\_\
                          _/ |Tealeaf rocks!!!                
                         |__/ '
  end

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

class Dealer
end

class Brain
end

class State
  attr_accessor
    :deck, 
    :player_name, 
    :dealer_bank, 
    :player_bank,
    :player_bank_initial,
    :bet,
    :player_points,
    :dealer_points,
    :player_hand,
    :dealer_hand

  def initialize(
    deck = [], 
    player_name = '', 
    dealer_bank = 50000, 
    player_bank = 0,
    player_bank_initial = 0,
    bet = 0,
    player_points = 0,
    dealer_points = 0,
    player_hand = [],
    dealer_hand = [])

    @deck = deck
    @player_name = player_name
    @dealer_bank = dealer_bank
    @player_bank = player_bank
    @player_bank_initial = player_bank_initial
    @bet = bet
    @player_points = player_points
    @dealer_points = dealer_points
    @player_hand = player_hand
    @dealer_hand = dealer_hand
  end
end

game = Game.new.play_game         
binding.pry