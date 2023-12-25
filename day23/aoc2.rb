# frozen_string_literal: true

def get_all_neighbors(y, x, max_y, max_x, file_data)
  neighbors = []

  if x.zero?
    neighbors << "#{y}:#{x + 1}" if file_data[y][x + 1].match?(/(\.|S|X)/)
  elsif x == max_x
    neighbors << "#{y}:#{x - 1}" if file_data[y][x - 1].match?(/(\.|S|X)/)
  else
    neighbors << "#{y}:#{x + 1}" if file_data[y][x + 1].match?(/(\.|S|X)/)
    neighbors << "#{y}:#{x - 1}" if file_data[y][x - 1].match?(/(\.|S|X)/)
  end

  if y.zero?
    neighbors << "#{y + 1}:#{x}" if file_data[y + 1][x].match?(/(\.|S|X)/)
  elsif y == max_y
    neighbors << "#{y - 1}:#{x}" if file_data[y - 1][x].match?(/(\.|S|X)/)
  else
    neighbors << "#{y + 1}:#{x}" if file_data[y + 1][x].match?(/(\.|S|X)/)
    neighbors << "#{y - 1}:#{x}" if file_data[y - 1][x].match?(/(\.|S|X)/)
  end

  neighbors
end

file_data = File.readlines('day23/test2_input.txt')
max_y = file_data.length - 1
graph = {}
map = []
s_location = nil
x_location = nil

file_data.each_with_index do |line, y|
  map[y] = line
  max_x = file_data[y].chars.reject { |c| c == "\n" }.length - 1
  line.chars.reject { |c| c == "\n" }.each_with_index do |char, x|
    next if char == '#'

    s_location = "#{y}:#{x}" if char == 'S'
    x_location = "#{y}:#{x}" if char == 'X'

    graph["#{y}:#{x}"] = get_all_neighbors(y, x, max_y, max_x, file_data)
  end
end

puts "S is at #{s_location}"
puts "X is at #{x_location}"
# puts graph

Path = Struct.new(:location, :steps, :graph, :status)

new_paths = []
new_paths << Path.new(location: s_location, steps: 0, graph:, status: :walking)
max_length = 0

until new_paths.empty?
  # 20.times do
  puts new_paths
  paths = new_paths.dup
  new_paths.clear

  paths.each do |path|
    puts 'Start path'
    # 50.times do
    while path.status == :walking
      puts "Path at #{path.location}"
      puts "with graph #{path.graph}"

      path.status = :arrived if path.location == x_location
      max_length = path.steps if path.status == :arrived && path.steps > max_length

      break unless path.status == :walking

      break if path.graph[path.location].empty?

      old_location = path.location.dup
      old_graph = {}
      old_graph.merge!(path.graph)
      # puts "Next steps #{next_steps.join(',')}"

      path.graph[path.location].each_with_index do |step, index|
        if index.zero?
          path.graph.delete(path.location)
          path.graph[step].delete(path.location)
          path.location = step
          path.steps += 1
        else
          new_graph = {}
          new_graph.merge!(old_graph.dup)
          new_graph.delete(old_location)
          new_graph[step].delete(old_location)
          puts path.graph
          new_paths << Path.new(location: step, steps: path.steps + 1, graph: new_graph, status: :walking)
        end
      end
    end

    puts ''
  end
end

# Part 2
puts "Part 2: #{max_length}"
