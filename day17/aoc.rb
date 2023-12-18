# frozen_string_literal: true

def get_all_neighbors(y, x, max_y, max_x, file_data, depth)
  neighbor = {}
  cost = 0

  if x.zero?
    (1..depth).each do |d|
      next unless file_data[y][x + d]

      cost += file_data[y][x + d].to_i
      neighbor["#{y}:#{x + d}"] = [cost, d]
    end
  elsif x == max_x
    (1..depth).each do |d|
      next unless file_data[y][x - d]

      cost += file_data[y][x - d].to_i
      neighbor["#{y}:#{x - d}"] = [cost, d]
    end
  else
    (1..depth).each do |d|
      next if (x + d) > max_x

      cost += file_data[y][x + d].to_i
      neighbor["#{y}:#{x + d}"] = [cost, d]
    end

    cost = 0
    (1..depth).each do |d|
      next if (x - d).negative?

      cost += file_data[y][x - d].to_i
      neighbor["#{y}:#{x - d}"] = [cost, d]
    end
  end

  cost = 0
  if y.zero?
    (1..depth).each do |d|
      next unless file_data[y + d]

      cost += file_data[y + d][x].to_i
      neighbor["#{y + d}:#{x}"] = [cost, d]
    end
  elsif y == max_y
    (1..depth).each do |d|
      next unless file_data[y - d]

      cost += file_data[y - d][x].to_i
      neighbor["#{y - d}:#{x}"] = [cost, d]
    end
  else
    (1..depth).each do |d|
      next if (y + d) > max_y

      cost += file_data[y + d][x].to_i
      neighbor["#{y + d}:#{x}"] = [cost, d]
    end

    cost = 0
    (1..depth).each do |d|
      next if (y - d).negative?

      cost += file_data[y - d][x].to_i
      neighbor["#{y - d}:#{x}"] = [cost, d]
    end
  end

  neighbor
end

def get_neighbor_direction(node, neighbor)
  node = node.split(':')
  neighbor = neighbor.split(':')

  return :up if !node[0].to_i.zero? && neighbor[0].to_i < node[0].to_i
  return :down if neighbor[0].to_i > node[0].to_i
  return :right if neighbor[1].to_i > node[1].to_i
  return :left if !node[1].to_i.zero? && neighbor[1].to_i < node[1].to_i

  nil
end

def dijkstra(graph, start)
  # Create a hash to store the shortest distance from the start node to every other node
  distances = {}
  # A hash to keep track of visited nodes
  visited = {}
  # Get a list of direction used for each nodes
  directions = {}
  directions_count = {}
  # Extract all the node keys from the graph
  nodes = graph.keys

  # Initially, set every node's shortest distance as infinity
  nodes.each do |node|
    distances[node] = Float::INFINITY
    directions_count[node] = 0
  end
  # The distance from the start node to itself is always 0
  distances[start] = 0
  directions[start] = nil

  # Reverse direction
  reverse_direction = {
    up: :down,
    down: :up,
    right: :left,
    left: :rigth
  }

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
      # Calculate tentative distance to the neighboring node
      alt = distances[min_node] + value[0]
      alt_direction = get_neighbor_direction(min_node, neighbor)

      if directions[min_node] == alt_direction
        next if directions_count[min_node] > 2
        next if directions_count[min_node] + value[1] > 3
      end

      # If this newly computed distance is shorter than the previously known one, update the shortest distance for the neighbor
      # puts neighbor
      next unless alt < distances[neighbor]

      distances[neighbor] = alt
      directions[neighbor] = alt_direction
      directions_count[neighbor] = if directions[min_node] == alt_direction
                                     directions_count[min_node] + value[1]
                                   else
                                     value[1]
                                   end
    end

    # Mark the node as visited
    visited[min_node] = true
    # Remove the node from the list of unvisited nodes
    nodes.delete(min_node)
  end

  # puts directions
  # puts directions_count

  # Return the shortest distances from the starting node to all other nodes
  distances
end

file_data = File.readlines('day17/real_input.txt')
max_y = file_data.length - 1
graph = {}

file_data.each_with_index do |line, y|
  max_x = file_data[y].chars.reject { |c| c == "\n" }.length - 1
  line.chars.reject { |c| c == "\n" }.each_with_index do |_char, x|
    graph["#{y}:#{x}"] = get_all_neighbors(y, x, max_y, max_x, file_data, 3)
  end
end

# puts graph

# Test the function with node 'A' as the starting point
path_cost = dijkstra(graph, '0:0')
# puts path_cost
cost_to_last_node = path_cost["#{max_y}:#{file_data[max_y].length - 1}"]

# Part 1
# 1025 - too high
# 922 - too low
# 973 - too high
puts "Part 1: #{cost_to_last_node - 2}"
