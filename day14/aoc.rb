# frozen_string_literal: true

file_data = File.readlines('day14/real_input.txt')

platform = []

file_data.each_with_index do |line, index|
  platform[index] = line
end

# Platform start
# puts 'Platform before rolling north'
# platform.each do |line|
#   puts line
# end

# Roll all rocks north
changes = true

while changes
  changes = false

  platform.each_with_index do |line, index|
    next if index.zero?

    line.chars.each_with_index do |char, char_index|
      next unless char == 'O' && platform[index - 1][char_index] == '.'

      platform[index - 1][char_index] = 'O'
      platform[index][char_index] = '.'
      changes = true
    end
  end
end

# Platform rolled up north
# puts 'Platform after rolling north'
# platform.each do |line|
#   puts line
# end

# Part 1 - 105461
total_load = 0
platform.each_with_index { |l, i| total_load += l.count('O') * (platform.length - i) }
puts "Part 1: #{total_load}"
