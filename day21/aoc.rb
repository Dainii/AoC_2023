# frozen_string_literal: true

def get_all_neighbors(y, x, max_y, max_x, file_data)
  neighbor = {}

  if x.zero?
    neighbor["#{y}:#{x + 1}"] = 1 if file_data[y][x + 1].match?(/(\.|S)/)
  elsif x == max_x
    neighbor["#{y}:#{x - 1}"] = 1 if file_data[y][x - 1].match?(/(\.|S)/)
  else
    neighbor["#{y}:#{x + 1}"] = 1 if file_data[y][x + 1].match?(/(\.|S)/)
    neighbor["#{y}:#{x - 1}"] = 1 if file_data[y][x - 1].match?(/(\.|S)/)
  end

  if y.zero?
    neighbor["#{y + 1}:#{x}"] = 1 if file_data[y + 1][x].match?(/(\.|S)/)
  elsif y == max_y
    neighbor["#{y - 1}:#{x}"] = 1 if file_data[y - 1][x].match?(/(\.|S)/)
  else
    neighbor["#{y + 1}:#{x}"] = 1 if file_data[y + 1][x].match?(/(\.|S)/)
    neighbor["#{y - 1}:#{x}"] = 1 if file_data[y - 1][x].match?(/(\.|S)/)
  end

  neighbor
end

def dijkstra(graph, start)
  # Create a hash to store the shortest distance from the start node to every other node
  distances = {}
  # A hash to keep track of visited nodes
  visited = {}
  # Extract all the node keys from the graph
  nodes = graph.keys

  # Initially, set every node's shortest distance as infinity
  nodes.each do |node|
    distances[node] = Float::INFINITY
  end
  # The distance from the start node to itself is always 0
  distances[start] = 0

  # Loop through until all nodes are visited
  until nodes.empty?
    min_node = nil

    # Iterate through each node
    nodes.each do |node|
      # Select the node with the smallest known distance
      if (min_node.nil? || distances[node] < distances[min_node]) && !(visited[node])
        # Ensure the node hasn't been visited yet
        min_node = node
      end
    end

    # If the shortest distance to the closest node is infinity, other nodes are unreachable. Break the loop.
    break if distances[min_node] == Float::INFINITY

    # For each neighboring node of the current node
    graph[min_node].each do |neighbor, value|
      # puts "from #{min_node} to #{neighbor}"
      # Calculate tentative distance to the neighboring node
      alt = distances[min_node] + value
      # If this newly computed distance is shorter than the previously known one, update the shortest distance for the neighbor
      distances[neighbor] = alt if alt < distances[neighbor]
    end

    # Mark the node as visited
    visited[min_node] = true
    # Remove the node from the list of unvisited nodes
    nodes.delete(min_node)
  end

  # Return the shortest distances from the starting node to all other nodes
  distances
end

file_data = File.readlines('day21/real_input.txt')
STEPS = 64
max_y = file_data.length - 1
graph = {}
s_location = ''

file_data.each_with_index do |line, y|
  max_x = file_data[y].chars.reject { |c| c == "\n" }.length - 1
  line.chars.reject { |c| c == "\n" }.each_with_index do |char, x|
    next if char == '#'

    s_location = "#{y}:#{x}" if char == 'S'

    graph["#{y}:#{x}"] = get_all_neighbors(y, x, max_y, max_x, file_data)
  end
end

garden_spots = dijkstra(graph, s_location).select { |_k, v| v < STEPS + 1 }.reject { |_k, v| v.odd? }
# puts garden_spots

# Part 1 - 3709
puts "Part 1: #{garden_spots.length}"

# Part 2
file_data_copy = File.read('day21/real_input.txt').sub('S', '.').split("\n")

# create a 3*3 map
map = []
y_margin = 0

file_data.each_with_index do |line, y|
  map[y] = line.chars.reject { |l| l == "\n" }.join.sub('S', '.') * 5
end

y_margin += file_data.length
file_data.each_with_index do |line, y|
  map[y_margin + y] = line.chars.reject { |l| l == "\n" }.join.sub('S', '.') * 5
end

y_margin += file_data.length
file_data.each_with_index do |line, y|
  map[y_margin + y] = (line.chars.reject { |l| l == "\n" }.join.sub('S', '.') * 2) +
                      line.chars.reject { |l| l == "\n" }.join +
                      (line.chars.reject { |l| l == "\n" }.join.sub('S', '.') * 2)
end

y_margin += file_data.length
file_data.each_with_index do |line, y|
  map[y_margin + y] = line.chars.reject { |l| l == "\n" }.join.sub('S', '.') * 5
end

y_margin += file_data.length
file_data.each_with_index do |line, y|
  map[y_margin + y] = line.chars.reject { |l| l == "\n" }.join.sub('S', '.') * 5
end

STEPS_P2 = 25
max_y = map.length - 1
graph = {}
s_location = ''

graph = {}
map.each_with_index do |line, y|
  max_x = map[y].chars.reject { |c| c == "\n" }.length - 1
  line.chars.reject { |c| c == "\n" }.each_with_index do |char, x|
    next if char == '#'

    s_location = "#{y}:#{x}" if char == 'S'

    graph["#{y}:#{x}"] = get_all_neighbors(y, x, max_y, max_x, map)
  end
end

garden_spots = dijkstra(graph, s_location).select { |_k, v| v < STEPS_P2 + 1 }.reject { |_k, v| v.even? }
# puts garden_spots

garden_spots.select { |_k, v| v == STEPS_P2 }.each do |k, _v|
  y = k.split(':')[0].to_i
  x = k.split(':')[1].to_i

  map[y][x] = 'X'
end

map.each do |line|
  puts line
end

# Part 2 -
puts "Part 2: #{garden_spots.length}"
