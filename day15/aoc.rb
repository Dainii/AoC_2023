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

def find_box_from_label(label)
  current_value = 0
  label.chars.each do |char|
    current_value += char.ord
    current_value *= 17
    current_value = current_value % 256
  end
  current_value
end

boxes = {}
256.times do |box|
  boxes[box] = []
end

file_data.gsub("\n", '').split(',').each do |sequence|
  sequence = sequence.split(/(=|-)/)
  label = sequence[0]
  operation = sequence[1]
  focal = operation == '=' ? sequence[2] : nil

  box = find_box_from_label(label)

  # puts "Sequence #{sequence.join} -> label #{label} -> box #{box}"

  case operation
  when '-'
    boxes[box] = boxes[box].reject { |l| l[:label] == label }
  when '='
    if (existing_lens = boxes[box].select { |l| l[:label] == label }.first)
      existing_lens[:focal] = focal
    else
      boxes[box] << { label:, focal: }
    end
  end

  # puts "after #{sequence.join}"
  # boxes.each_key do |box_id|
  #   next if boxes[box_id].empty?
  #
  #   puts "Box #{box_id}: #{boxes[box_id]}"
  # end
end

total_power = 0
boxes.each_key do |box|
  box_value = box + 1
  boxes[box].each_with_index do |len, index|
    slot_value = index + 1
    total_power += (box_value * slot_value * len[:focal].to_i)
  end
end

# Part 2 - 286097
puts "Part 2: #{total_power}"
