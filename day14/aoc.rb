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

# Platform for part 2
platform2 = []

file_data.each_with_index do |line, index|
  platform2[index] = line
end

(1..1_000_000_000).each do |_cycle|
  # puts "Cycle #{cycle}"

  changes = true
  # North
  while changes
    changes = false

    platform2.each_with_index do |line, index|
      next if index.zero?

      line.chars.each_with_index do |char, char_index|
        next unless char == 'O' && platform2[index - 1][char_index] == '.'

        platform2[index - 1][char_index] = 'O'
        platform2[index][char_index] = '.'
        changes = true
      end
    end
  end

  changes = true
  # West
  while changes
    changes = false

    platform2.each_with_index do |line, index|
      line.chars.each_with_index do |char, char_index|
        next if char_index.zero?
        next unless char == 'O' && line[char_index - 1] == '.'

        platform2[index][char_index - 1] = 'O'
        platform2[index][char_index] = '.'
        changes = true
      end
    end
  end

  changes = true
  # South
  while changes
    changes = false

    platform2.reverse.each_with_index do |line, index|
      next if index.zero?

      real_index = platform2.length - index - 1
      # puts "index #{index} -> real_index #{real_index}"

      line.chars.each_with_index do |char, char_index|
        next if char == "\n"

        # puts "real index #{real_index} char #{char} -> #{char_index}"
        next unless char == 'O' && platform2[real_index + 1][char_index] == '.'

        platform2[real_index + 1][char_index] = 'O'
        platform2[real_index][char_index] = '.'
        changes = true
      end
    end
  end

  changes = true
  # East
  while changes
    changes = false

    platform2.each_with_index do |line, index|
      line.chars.reverse.each_with_index do |char, char_index|
        next if char_index.zero?

        real_char_index = line.length - char_index - 1
        next unless char == 'O' && line[char_index - 1] == '.'

        platform2[index][real_char_index + 1] = 'O'
        platform2[index][real_char_index] = '.'
        changes = true
      end
    end
  end
end

# Part 2
total_load2 = 0
platform2.each_with_index { |l, i| total_load2 += l.count('O') * (platform2.length - i) }
puts "Part 2: #{total_load2}"
