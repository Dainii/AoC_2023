# frozen_string_literal: true

file_data = File.read('day15/real_input.txt')

results_sum = 0
file_data.gsub("\n", '').split(',').each do |sequence|
  # puts "Sequence #{sequence}"

  current_value = 0

  sequence.chars.each do |char|
    current_value += char.ord
    current_value *= 17
    current_value = current_value % 256
  end

  # puts "Result #{current_value}"
  # puts '---'

  results_sum += current_value
end

# Part 1 - 517551
puts "Part 1: #{results_sum}"
