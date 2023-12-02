# frozen_string_literal: true

file_data = File.readlines('day2/real_input.txt')

cubes_limit = { red: 12, green: 13, blue: 14 }

valid_games = %i[]
power_sum = 0

file_data.each do |game|
  game_id = game[/^Game ([^:]*)/, 1]
  rounds = game.gsub(/^Game [0-9]+:/, '').split(';')

  valid_rounds = true

  color_max = { red: 0, green: 0, blue: 0 }

  rounds.each do |round|
    round.split(',').each do |color|
      roll = color.split
      valid_rounds = false if roll.first.to_i > cubes_limit[roll.last.to_sym]
      color_max[roll.last.to_sym] = roll.first.to_i if roll.first.to_i > color_max[roll.last.to_sym]
    end
  end

  power_sum += (color_max[:red] * color_max[:green] * color_max[:blue])

  valid_games << game_id.to_i if valid_rounds
end

# Part 1
total = 0
valid_games.each { |i| total += i }
puts "Part 1: #{total}"

# Part 2
puts "Part 2: #{power_sum}"
