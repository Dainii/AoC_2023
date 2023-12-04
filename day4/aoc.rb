# frozen_string_literal: true

class Card
  attr_accessor :winning_numbers, :numbers, :card, :id, :count

  def initialize(card)
    @card = card
    @count = 1
    extract_id
    extract_winning_numbers
    extract_numbers
  end

  def extract_id
    @id = @card[/Card\s+([0-9]+):/, 1].to_i
  end

  def extract_winning_numbers
    @winning_numbers = @card[/Card\s+[0-9]+: ((\s?[0-9]{1,2} )+)|/, 1].split
  end

  def extract_numbers
    @numbers = @card[/(^[^\|]*)\|(.*)/, 2].split
  end

  def matching_numbers
    match = 0
    @numbers.each do |number|
      match += 1 if @winning_numbers.include?(number)
    end
    match
  end

  def points
    return 0 if matching_numbers.zero?
    return 1 if matching_numbers == 1

    1 * (2**(matching_numbers - 1))
  end

  def calculate_wins(cards)
    return if matching_numbers.zero?

    last_card_id = cards.last.id

    (1..count).each do |count|
      (1..matching_numbers).each do |number|
        next if id + number > last_card_id

        # C'est giga lent du coup :D
        cards.select { |c| c.id == id + number }.first.count += 1
      end
    end
  end
end

file_data = File.readlines('day4/real_input.txt')

total_card_points = 0
cards = []

file_data.each do |line|
  card = Card.new(line)

  # puts "Card #{card.id}: matching numbers: #{card.matching_numbers}"
  # puts "Card #{card.id}: points: #{card.points}"
  # puts "Card #{card.id}: number of numbers: #{card.numbers.length}"
  # puts "Card #{card.id}: number of winning numbers: #{card.winning_numbers.length}"

  total_card_points += card.points
  cards << card
end

# Part 1
# 847 - too low
# 15268 - good answer
puts "Part 1: #{total_card_points}"

cards.each do |card|
  card.calculate_wins(cards)
end

number_of_cards = 0

cards.each do |card|
  number_of_cards += 1 * card.count
end

# Part 2
# 6283755 - good answer
# Faudrait faire mieux que: ruby day4/aoc.rb  114.47s user 0.58s system 99% cpu 1:55.93 total
puts "Part 2: #{number_of_cards}"
