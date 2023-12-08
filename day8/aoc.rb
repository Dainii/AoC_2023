# frozen_string_literal: true

file_data = File.readlines('day8/real_input.txt')

instructions = file_data.first

map = {}

file_data.drop(2).each do |mouvement|
  destinations = mouvement[/\((.+)\)/, 1].sub(',', '').split
  map[mouvement.split.first.to_sym] = [destinations.first.to_sym, destinations.last.to_sym]
end

# puts map

position = :AAA
steps = 0

until position == :ZZZ
  instructions.chars.each do |instruction|
    next unless %w[L R].include?(instruction)

    # puts "From position #{position} with instruction #{instruction}"
    position = if instruction == 'R'
                 map[position].last
               elsif instruction == 'L'
                 map[position].first
               end
    steps += 1
    # puts "To position #{position}"

    break if position == :ZZZ
  end
end

# Part 1 - 16043
puts "Part 1: #{steps} steps"

## Part 2
file_data = File.readlines('day8/real_input.txt')

instructions = file_data.first

map = {}
steps = 0

file_data.drop(2).each do |mouvement|
  destinations = mouvement[/\((.+)\)/, 1].sub(',', '').split
  map[mouvement.split.first] = [destinations.first, destinations.last]
end

paths = {}

map.each_key do |path|
  paths[path] = path if path.chars.last == 'A'
end

puts paths

def all_arrived(paths)
  arrived = true

  paths.each_key do |path|
    return false if paths[path].chars.last != 'Z'
  end

  arrived
end

# until all_arrived(paths)
#   instructions.chars.each do |instruction|
#     next unless %w[L R].include?(instruction)
# 
#     # puts "Instruction #{instruction}"
# 
#     # puts("Round #{steps} ---")
#     paths.each_key do |path|
#       # puts "From position #{paths[path]} with instruction #{instruction}"
#       paths[path] = if instruction == 'R'
#                       map[paths[path]].last
#                     elsif instruction == 'L'
#                       map[paths[path]].first
#                     end
#       # puts "To position #{paths[path]}"
#     end
#     steps += 1
#     # puts("---")
#     break if all_arrived(paths)
#   end
# end

# Part 2:
# puts "Part 2: #{steps} steps"

count = []

# better version
paths.each_key do |path|
  steps = 0

  until paths[path].chars.last == 'Z'
    instructions.chars.each do |instruction|
      next unless %w[L R].include?(instruction)

      # puts "From position #{paths[path]} with instruction #{instruction}"
      paths[path] = if instruction == 'R'
                      map[paths[path]].last
                    elsif instruction == 'L'
                      map[paths[path]].first
                    end

      steps += 1
      break if paths[path].chars.last == 'Z'
    end
  end

  count << steps
end

puts count

# Part 2: 15_726_453_850_399
# 3_293_782_158_771_276 too high
puts "Part 2: #{count.reduce(1, :lcm)} steps"
