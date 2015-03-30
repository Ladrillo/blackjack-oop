# encoding: UTF-8
require 'pry'

class Game
  attr_accessor :state, :brain, :player, :dealer

  def initialize    
    @brain = Brain.new
    @player = Player.new
    @dealer = Dealer.new
    @state = State.new
  end

  def play_game
    display_logo
    greeting
    player.gives_name(state)
    loop do
      reset_state
      player.empties_pockets(state) 
      loop do
        display_logo       
        player.places_bet(state)
        dealer.deal_first(state)
        update_points

        if brain.any_blackjacks?(state)
          display_logo
          display_table(false)
          direct_win
        else
          display_logo
          display_table(true)
          player_hits_or_stands
          dealer_hits_or_stands unless Brain.new.bust?(state.player_hand)
          display_logo
          display_table(false)
          non_direct_win
        end

        break unless bet_again?
        break unless state.player_bank > 0
        break unless state.dealer_bank > 0
      end
      display_logo
      display_goodbye_message
      break unless play_again?      
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
                          _/ |Fullstack A. Rocks!!!                
                         |__/ '
  end

  def display_logo
    system 'clear'
    puts logo
  end

  def greeting
    puts "\n" * 3 + " Welcome to the table!"
    puts " Blackjack pays 3 to 2."
    puts " Dealer must draw on 16 and stand on all 17's."
    puts "\n"
  end

  def display_table(hidden)  
    puts "\n Dealer:"
    if hidden
      display_hand_hidden(state.dealer_hand)
      puts " ?"
    else
      display_hand(state.dealer_hand)    
      puts " #{state.dealer_points}"
    end
    puts "\n #{state.player_name}:"
    display_hand(state.player_hand)
    puts " #{state.player_points}"    
  end

  def display_hand(hand)
    segments = []
    hand.each { |card| segments << card.face_up.call }
    ['','','','','','',''].zip(*segments).each do |joined_segments| 
      puts joined_segments.inject { |a,b| a+b }
    end  
  end

  def display_hand_hidden(hand)
    segments = []
    segments << hand[0].face_down.call
    hand[1..-1].each { |card| segments << card.face_up.call }
    ['','','','','','',''].zip(*segments).each do |joined_segments| 
      puts joined_segments.inject { |a,b| a+b }
    end  
  end

  def reset_state
    name = state.player_name
    self.state = State.new
    state.player_name = name
  end

  def update_points
    state.player_points = Brain.new.points(state.player_hand)
    state.dealer_points = Brain.new.points(state.dealer_hand)
  end

  def update_for_win
    if state.player_points == 21
      state.player_bank += 3 * state.bet / 2
      state.dealer_bank -= 3 * state.bet / 2
    else
      state.player_bank += state.bet
      state.dealer_bank -= state.bet
    end
  end

  def update_for_loss
    state.player_bank -= state.bet
    state.dealer_bank += state.bet
  end

  def reset_stats
    state.deck = Deck.new
    state.bet = 0,
    state.player_hand.clear
    state.dealer_hand.clear
  end

  def direct_win
    if state.player_points == 21 && state.dealer_points == 21
      puts "\n Push!"
      reset_stats
    elsif state.player_points == 21
      puts "\n Blackjack! You win!"    
      update_for_win
      reset_stats    
    elsif state.dealer_points == 21
      puts "\n Blackjack! The Dealer wins!"    
      update_for_loss
      reset_stats
    end
  end

  def non_direct_win
    if brain.bust?(state.player_hand)
      puts "\n You bust! The Dealer wins!"
      update_for_loss
      reset_stats
    elsif brain.bust?(state.dealer_hand)
      puts "\n The dealer busts! You win!"
      update_for_win
      reset_stats
    elsif state.player_points > state.dealer_points
      puts "\n You win!"    
      update_for_win
      reset_stats
    elsif state.player_points < state.dealer_points
      puts "\n The Dealer wins!"    
      update_for_loss
      reset_stats
    else
      puts "\n Push!" 
      reset_stats
    end
  end

  def hit_player
    dealer.deal_player(state)
    update_points
    display_logo
    display_table(true)
  end 

  def hit_dealer
    dealer.deal_dealer(state)
    update_points
    display_logo
    display_table(true)
  end 

  def player_hits_or_stands
    loop do
      begin
        puts "\n Hit or Stay? (h/s)" 
        option = gets.chomp.downcase
      end while option != 'h' && option != 's'
      hit_player if option == 'h'
      break if option == 's' || Brain.new.bust?(state.player_hand)
    end
  end                                                       

  def dealer_hits_or_stands
    loop do
      hit_dealer
      break if Brain.new.bust?(state.dealer_hand) || (state.dealer_points > 16)
    end unless (state.dealer_points > 16)
  end

  def play_again?
    puts "\n Play again? (y/n)" 
    option = gets.chomp.downcase
    option == 'y'                                                                                                   
  end

  def bet_again?
    puts "\n Bet again? (y/n)" 
    option = gets.chomp.downcase
    option == 'y' 
  end

  def display_goodbye_message
    if state.dealer_bank == 0
      puts "\n" * 3 + " You broke the bank! Congratulations!!!"
      puts " Except there's no way they're letting you leave with all that dough..."
      puts " The story probably ends with your corpse buried somewhere in the desert!"
    elsif state.player_bank == 0
      puts "\n" * 3 + " You don't have any money left!"
      puts " Think of all the nice things"
      puts " you could've bought with the dough..."
      puts " Like some flowers for a loved one!"
    elsif state.player_bank == state.player_bank_initial
      puts "\n" * 3 + " You did the right thing."
      puts " The house always wins..."
    elsif state.player_bank > 0 && (state.player_bank < state.player_bank_initial)
      puts "\n" * 3 + " You just pissed away #{state.player_bank_initial - state.player_bank} dollars!"
      puts " And your Grandma thought you were"
      puts " sooo brilliant." 
    elsif state.player_bank > state.player_bank_initial
      puts "\n" * 3 + " So you won #{state.player_bank - state.player_bank_initial} dollars."
      puts " You probably think you're smart!"
      puts " Congratulations..."
    end
  end
end

                                                    
class Player
  def gives_name(state)
    begin
      puts "\n What is your name, friend?"
      name = gets.chomp
    end while name == ''
    state.player_name = name
  end

  def empties_pockets(state)
    begin
      puts "\n How much money do you have on you? (Max $1000)"
      total_funds = gets.chomp.to_i 
    end while total_funds <= 0 || total_funds > 1000
    state.player_bank_initial = total_funds
    state.player_bank = total_funds
  end

  def places_bet(state)
    begin
      puts "\n" * 3 + " You have #{state.player_bank} dollars left."
      puts " The Dealer has #{state.dealer_bank} dollars left."    
      puts "\n What is your bet for this hand, #{state.player_name}?"
      bet = gets.chomp.to_i
    end while bet <= 0 || bet > state.player_bank || bet > state.dealer_bank
    state.bet = bet
  end
end


class Dealer
  def deal_first(state)
    cards = state.deck.cards.call
    2.times do
      state.player_hand << cards.shift
      state.dealer_hand << cards.shift
    end
    state.deck.cards = lambda { cards }
  end

  def deal_player(state)
    cards = state.deck.cards.call
    state.player_hand << cards.shift
    state.deck.cards = lambda { cards }
  end

  def deal_dealer(state)
    cards = state.deck.cards.call
    state.dealer_hand << cards.shift
    state.deck.cards = lambda { cards }
  end
end


class Card
  attr_accessor :name, :suit, :rank, :value, :face_up, :face_down

  def initialize(name, suit, rank, value, face_up, face_down)
    @name = name
    @suit = suit
    @rank = rank
    @value = value
    @face_up = face_up
    @face_down = face_down
  end
end


class Deck
  attr_accessor :cards 

  def initialize
    cards = []
    suits.each do |suit| 
      ranks.each do |rank|
        cards << Card.new( 
          "#{rank} of #{suit}", 
          "#{suit}", 
          "#{rank}", 
          value("#{rank}"), 
          face_up("#{suit}", "#{rank}"), 
          face_down
          )
      end
    end
    cards.shuffle!.shuffle!.shuffle!
    @cards = lambda { cards }
  end

  private

  def suits
    ['Hearts', 'Diamonds', 'Clubs', 'Spades']
  end

  def ranks
    ['Ace', 'King', 'Queen', 'Jack', 
      '10', '9', '8', '7', '6', '5', '4', '3', '2']
  end

  def value(rank)
    case rank
      when 'Ace' then [1,11]
      when 'King' then [10]
      when 'Queen' then [10]
      when 'Jack' then [10]
      else [rank.to_i]
    end
  end

  def face_down
    lambda do
      [
        '  ________ ',
        ' |' + "".center(8) +'|',            
        ' |' + "?".center(8) + '|',
        ' |' + "".center(8) +'|',
        ' |' + "".center(8) +'|',
        ' |' + "?".center(8) + '|',       
        ' |________|'
      ] 
    end
  end

  def face_up(suit, rank)
    lambda do
      [
        '  ________ ',
        ' |' + "".center(8) +'|',            
        ' |' + "#{rank}".center(8) + '|',
        ' |' + "".center(8) +'|',
        ' |' + "".center(8) +'|',
        ' |' + "#{suit}".center(8) + '|',
        ' |________|'
      ]
    end 
  end
end


class Brain

  def points(hand)
    p_aces = points_aces(hand) 
    p_other = points_other_cards(hand)
    p_other + p_aces[1] > 21 ? p_other + p_aces[0] : p_other + p_aces[1]
  end

  def any_blackjacks?(state)
    points(state.player_hand) == 21 || 
    points(state.dealer_hand) == 21
  end

  def bust?(hand)
    points(hand) > 21
  end 

  private                                                       

  def aces(hand)
    aces = []
    hand.each { |card| aces << card if card.rank == 'Ace' }
    aces
  end

  def other_cards(hand)                                     
    other_cards = []
    hand.each { |card| other_cards << card if card.rank != 'Ace' }
    other_cards
  end 

  def points_aces(hand)  
    posibilities = []
    counter = 0
    while counter < aces(hand).size + 1
      posibilities << aces(hand).size + 10 * counter
      counter += 1
    end
    posibilities == [0] ? [0,0] : posibilities
  end

  def points_other_cards(hand)   
    points = 0                                  
    other_cards(hand).each { |card| points += 
      card.value[0] }
    points
  end
end

class State
  attr_accessor(:deck, :player_name, :dealer_bank, :player_bank, :player_bank_initial, :bet, :player_points, :dealer_points, :player_hand, :dealer_hand)

  def initialize(
    deck = Deck.new, 
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