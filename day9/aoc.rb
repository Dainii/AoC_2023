# frozen_string_literal: true

file_data = File.readlines('day9/real_input.txt')

all_next_values = 0
all_previous_values = 0

file_data.each do |history|
  history = history.split.map(&:to_i)

  steps = []
  steps << history

  until history.uniq.count == 1 && history.uniq.first.zero?
    # puts "History: #{history}"
    new_history = []
    history.each_with_index do |h, i|
      next if i >= history.length - 1

      new_history << (history[i + 1] - h)
    end
    history = new_history
    steps << history
  end

  # puts "Steps: #{steps}"

  next_value = 0
  steps.reverse.each_with_index do |_step, index|
    next if index >= steps.length - 1

    next_value += steps.reverse[index + 1].last
  end

  # puts "Next value #{next_value}"
  all_next_values += next_value

  previous_value = 0
  steps.reverse.each_with_index do |_step, index|
    next if index >= steps.length - 1

    previous_value = steps.reverse[index + 1].first - previous_value
    # puts "Previous value #{previous_value}"
  end

  all_previous_values += previous_value
end

# Part 1 - 1904165718
puts "Part 1: #{all_next_values}"

# Part 2 - 964
puts "Part 2: #{all_previous_values}"
