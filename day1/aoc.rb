# frozen_string_literal: true

file_data = File.readlines('day1/real_input.txt')

calibration_value_int = %i[]

# CF le talk de HelveticRuby, doit y avoir moyen de faire mieux
file_data.each do |line|
  calibration_value = nil

  line.each_char do |v|
    next if v.to_i.zero?

    calibration_value = v
    break
  end

  line.reverse.each_char do |v|
    next if v.to_i.zero?

    calibration_value += v
    break
  end

  calibration_value_int << calibration_value.to_i
end

# Part 1 - 54390
total = 0
calibration_value_int.each { |i| total += i }
puts "Part 1: #{total}"

calibration_value_int = %i[]
numbers = %w[one two three four five six seven eight nine]
number_value = {
  one: '1',
  two: '2',
  three: '3',
  four: '4',
  five: '5',
  six: '6',
  seven: '7',
  eight: '8',
  nine: '9'
}

def extract_word_index(number, line, candidates_list)
  candidates_list << { index: line.index(number), value: number }

  newline = line.sub(number, 'a' * number.length)

  extract_word_index(number, newline, candidates_list) if newline.include?(number)
end

total = 0

file_data.each do |line|
  calibration_value = ''
  candidates_list = []

  line.each_char.with_index do |v, i|
    next if v.to_i.zero?

    candidates_list << { index: i, value: v }
  end

  numbers.each do |number|
    next unless line.include?(number)

    extract_word_index(number, line, candidates_list)
  end

  candidates_list = candidates_list.sort_by { |candidate| candidate[:index] }

  [candidates_list.first[:value], candidates_list.last[:value]].each do |value|
    calibration_value += if value.to_i.zero?
                           number_value[value.to_sym]
                         else
                           value
                         end
  end

  total += calibration_value.to_i
end

# Part 2 - 54277
puts "Part 2: #{total}"
