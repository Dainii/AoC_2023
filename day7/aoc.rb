# frozen_string_literal: true

card_power_order = %w[A K Q J T 9 8 7 6 5 4 3 2]
hand_type_order = {
  five_of_a_kind: 1,
  four_of_a_kind: 2,
  full_house: 3,
  three_of_a_kind: 4,
  two_pair: 5,
  one_pair: 6,
  high_card: 7
}

class Hand
  attr_accessor :cards, :bid, :type, :type_order, :cards_order

  def initialize(cards, bid, hand_type_order)
    @cards = cards.scan(/\w/)
    @bid = bid.to_i
    @type = find_type
    @type_order = hand_type_order[@type]
    @cards_order = []
    calculate_card_order
  end

  def five_of_a_kind?
    return true if @cards.count('J') == 5
    return @cards.reject { |c| c == 'J' }.uniq.count == 1 if @cards.include?('J')

    @cards.uniq.count == 1
  end

  def four_of_a_kind?
    if @cards.include?('J')
      @cards.reject { |c| c == 'J' }.uniq.each do |card|
        return true if @cards.count(card) + @cards.count('J') == 4
      end
    else
      return false unless @cards.uniq.count == 2

      @cards.uniq.each do |card|
        return true if @cards.count(card) == 4
      end
    end

    false
  end

  def full_house?
    return @cards.reject { |c| c == 'J' }.uniq.count == 2 if @cards.include?('J')

    @cards.uniq.count == 2
  end

  def three_of_a_kind?
    if @cards.include?('J')
      @cards.reject { |c| c == 'J' }.uniq.each do |card|
        return true if @cards.count(card) + @cards.count('J') == 3
      end
    else
      return false unless @cards.uniq.count == 3

      @cards.uniq.each do |card|
        return true if @cards.count(card) == 3
      end
    end

    false
  end

  def two_pair?
    pair_count = 0

    return false if @cards.include?('J')

    return false unless @cards.uniq.count == 3

    @cards.uniq.each do |card|
      pair_count += 1 if @cards.count(card) == 2
    end

    pair_count == 2
  end

  def one_pair?
    if @cards.include?('J')
      @cards.reject { |c| c == 'J' }.uniq.each do |card|
        return true if @cards.count(card) + @cards.count('J') == 2
      end
    else
      return false unless @cards.uniq.count == 4

      @cards.uniq.each do |card|
        return true if @cards.count(card) == 2
      end
    end

    false
  end

  def find_type
    return :five_of_a_kind if five_of_a_kind?
    return :four_of_a_kind if four_of_a_kind?
    return :full_house if full_house?
    return :three_of_a_kind if three_of_a_kind?
    return :two_pair if two_pair?
    return :one_pair if one_pair?

    :high_card
  end

  def find_card_order(card)
    case card
    when 'A'
      1
    when 'K'
      2
    when 'Q'
      3
    when 'J'
      13
    when 'T'
      4
    else
      14 - card.to_i
    end
  end

  def calculate_card_order
    @cards.each do |card|
      @cards_order << find_card_order(card)
    end
  end
end

file_data = File.readlines('day7/real_input.txt')

hands = []
file_data.each do |line|
  line = line.split
  hands << Hand.new(line.first, line.last, hand_type_order)
end

hands = hands.sort_by do |hand|
  [
    hand.type_order,
    hand.cards_order[0],
    hand.cards_order[1],
    hand.cards_order[2],
    hand.cards_order[3],
    hand.cards_order[4]
  ]
end

total_winnings = 0
hands.reverse.each_with_index do |hand, index|
  puts "Hand with cards #{hand.cards} is type #{hand.type} with rank #{index + 1} and bid #{hand.bid}"
  total_winnings += ((index + 1) * hand.bid)
end

# Part 1
# 252317412 too high
# 248683088 too high
# 248978906 too high
# 248422077 right answer
# puts "Part 1: #{total_winnings}"

# Part 2
# 250433427 too high
# 250351700 too high
# 250251872 too high
# 249817836 right answer
puts "Part 2: #{total_winnings}"
