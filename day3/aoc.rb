# frozen_string_literal: true

file_data = File.readlines('day3/real_input.txt')

sum_of_all_part = 0
symbol_list = %w[+ - / * # @ $ % = &]
number_list = []

def adjacent_symbol?(line, position, length, array)
  symbols = %r{(\+|-|/|\*|\#|@|\$|%|=|&)}

  position_minus_1 = position.zero? ? 0 : position - 1

  # same line before
  return true if symbols.match?(array[line][position_minus_1])

  # same line after
  return true if symbols.match?(array[line][position + length])

  # line above
  unless line.zero?
    (position_minus_1..position + length).each do |p|
      return true if symbols.match?(array[line - 1][p])
    end
  end

  # line under
  unless line == array.length - 1
    (position_minus_1..position + length).each do |p|
      return true if symbols.match?(array[line + 1][p])
    end
  end

  false
end

def parse_line(line, number_list, line_number)
  number = line.split('.').reject(&:empty?).first
  number_index = line.index(number)

  number_list << {
    number: number,
    line: line_number,
    position: number_index
  }

  new_line = line.sub(number, '.' * number.length)

  parse_line(new_line, number_list, line_number) unless new_line.split('.').reject(&:empty?).first.to_i.zero?
end

file_data.each_with_index do |line, index|
  line_without_symbols = line.scan(/./).map { |x| symbol_list.include?(x) ? '.' : x }.join

  unless line_without_symbols.split('.').reject(&:empty?).first.to_i.zero?
    parse_line(line_without_symbols, number_list, index)
  end
end

number_list.each do |n|
  sum_of_all_part += n[:number].to_i if adjacent_symbol?(n[:line], n[:position], n[:number].length, file_data)
end

# Test answer 4361
# Real answer 519444
puts "Part 1: #{sum_of_all_part}"

star_list = []

def parse_star_line(line, star_list, line_number)
  star_index = line.index('*')

  star_list << {
    line: line_number,
    position: star_index
  }

  new_line = line.sub('*', '.')

  parse_star_line(new_line, star_list, line_number) if new_line.index('*')
end

def analyze_line?(array, position, line)
  number_count = 0
  is_left_a_number = false
  is_center_a_number = false
  is_right_a_number = false

  is_left_a_number = true if !position.zero? && /[0-9]/.match?(array[line][position - 1])
  is_center_a_number = true if /[0-9]/.match?(array[line][position])
  is_right_a_number = true if /[0-9]/.match?(array[line][position + 1])

  if is_left_a_number && !is_center_a_number && is_right_a_number
    2
  elsif !is_left_a_number && !is_center_a_number && !is_right_a_number
    0
  else
    1
  end
end

def has_two_adjacent_numbers?(star, array)
  adjacent_numbers = 0

  star_position = star[:position]
  star_line = star[:line]
  star[:adjacent_numbers] = []

  star_position_minus_one = star_position.zero? ? 0 : star_position - 1

  # left side
  if /[0-9]/.match?(array[star_line][star_position_minus_one])
    star[:adjacent_numbers] << :left
    adjacent_numbers += 1
  end

  # right side
  if /[0-9]/.match?(array[star_line][star_position + 1])
    star[:adjacent_numbers] << :right
    adjacent_numbers += 1
  end

  # above
  above_numbers = analyze_line?(array, star_position, star_line - 1) unless star_line.zero?
  unless above_numbers.zero?
    adjacent_numbers += above_numbers
    star[:adjacent_numbers] << :above
  end

  # under
  under_numbers = analyze_line?(array, star_position, star_line + 1)
  unless under_numbers.zero?
    adjacent_numbers += under_numbers
    star[:adjacent_numbers] << :under
  end

  adjacent_numbers == 2
end

def find_left_star(star, number_list)
  number = nil

  position = star[:position] - 1

  until number
    number = number_list.select { |n| n[:line] == star[:line] && n[:position] == position }.first
    position -= 1
  end

  number
end

def find_right_star(star, number_list)
  number = nil

  position = star[:position] + 1

  until number
    number = number_list.select { |n| n[:line] == star[:line] && n[:position] == position }.first
    position -= 1
  end

  number
end

def find_above_star(star, number_list)
  numbers = []

  position = star[:position]
  line = star[:line] - 1

  # if there is only on symbol, both numbers are above
  if star[:adjacent_numbers].length == 1
    # The first one is on the top right
    numbers << number_list.select { |n| n[:line] == line && n[:position] == position + 1 }.first

    # The second one cannot be in the middle, so start top left
    until numbers.length == 2
      number = number_list.select { |n| n[:line] == line && n[:position] == position - 1 }.first
      numbers << number if number
      position -= 1
    end
  else
    until numbers.length == 1
      number = number_list.select { |n| n[:line] == line && n[:position] == position + 1 }.first
      numbers << number if number
      position -= 1
    end
  end

  numbers
end

def find_under_star(star, number_list)
  numbers = []

  position = star[:position]
  line = star[:line] + 1

  # if there is only on symbol, both numbers are under
  if star[:adjacent_numbers].length == 1
    # The first one is on the bottom right
    numbers << number_list.select { |n| n[:line] == line && n[:position] == position + 1 }.first

    # The second one cannot be in the middle, so start bottom left
    until numbers.length == 2
      number = number_list.select { |n| n[:line] == line && n[:position] == position - 1 }.first
      numbers << number if number
      position -= 1
    end
  else
    until numbers.length == 1
      number = number_list.select { |n| n[:line] == line && n[:position] == position + 1 }.first
      numbers << number if number
      position -= 1
    end
  end

  numbers
end

def find_star_adjacent_numbers(star, number_list)
  adjacent_numbers = []

  star[:adjacent_numbers].each do |n|
    case n
    when :left
      adjacent_numbers << find_left_star(star, number_list)
    when :right
      adjacent_numbers << find_right_star(star, number_list)
    when :above
      adjacent_numbers.concat(find_above_star(star, number_list))
    when :under
      adjacent_numbers.concat(find_under_star(star, number_list))
    end
  end

  adjacent_numbers
end

file_data.each_with_index do |line, index|
  line_with_only_stars = line.scan(/./).map { |x| x == '*' ? '*' : '.' }.join

  parse_star_line(line_with_only_stars, star_list, index) if line_with_only_stars.index('*')
end

gear_ratio_sum = 0

star_list.each do |star|
  next unless has_two_adjacent_numbers?(star, file_data)

  puts star
  adjacent_numbers = find_star_adjacent_numbers(star, number_list)
  puts adjacent_numbers

  gear_ratio_sum += (adjacent_numbers.first[:number].to_i * adjacent_numbers.last[:number].to_i)
end

# Test answer 467835
# Real answer 74528807
# 49612915 too low
# 76388517 too high
puts "Part 2: #{gear_ratio_sum}"
