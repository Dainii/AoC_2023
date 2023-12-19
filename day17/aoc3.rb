# frozen_string_literal: true

def get_all_neighbors(y, x, max_y, max_x, file_data, depth, orientation)
  neighbor = {}
  cost = 0

  if orientation == :horizontal
    if x.zero?
      (1..depth).each do |d|
        next unless file_data[y][x + d]

        cost += file_data[y][x + d].to_i
        neighbor["#{y}:#{x + d}"] = cost
      end
    elsif x == max_x
      (1..depth).each do |d|
        next unless file_data[y][x - d]

        cost += file_data[y][x - d].to_i
        neighbor["#{y}:#{x - d}"] = cost
      end
    else
      (1..depth).each do |d|
        next if (x + d) > max_x

        cost += file_data[y][x + d].to_i
        neighbor["#{y}:#{x + d}"] = cost
      end

      cost = 0
      (1..depth).each do |d|
        next if (x - d).negative?

        cost += file_data[y][x - d].to_i
        neighbor["#{y}:#{x - d}"] = cost
      end
    end
  elsif orientation == :vertical
    cost = 0
    if y.zero?
      (1..depth).each do |d|
        next unless file_data[y + d]

        cost += file_data[y + d][x].to_i
        neighbor["#{y + d}:#{x}"] = cost
      end
    elsif y == max_y
      (1..depth).each do |d|
        next unless file_data[y - d]

        cost += file_data[y - d][x].to_i
        neighbor["#{y - d}:#{x}"] = cost
      end
    else
      (1..depth).each do |d|
        next if (y + d) > max_y

        cost += file_data[y + d][x].to_i
        neighbor["#{y + d}:#{x}"] = cost
      end

      cost = 0
      (1..depth).each do |d|
        next if (y - d).negative?

        cost += file_data[y - d][x].to_i
        neighbor["#{y - d}:#{x}"] = cost
      end
    end
  end

  neighbor
end

def dijkstra(graph_h, graph_v, start)
  # Create a hash to store the shortest distance from the start node to every other node
  distances = {}
  # A hash to keep track of visited nodes
  visited = {}
  # Extract all the node keys from the graph
  nodes = graph_h.keys

  # Initially, set every node's shortest distance as infinity
  nodes.each do |node|
    distances[node] = Float::INFINITY
  end
  # The distance from the start node to itself is always 0
  distances[start] = 0

  # Remember the start of the last line
  last_start = 0
  count = 0

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

    # Alternate graph_h and graph_v
    if min_node != start && min_node.split(':')[1] == '0'
      count = last_start.zero? ? 1 : 0
      last_start = count
    end

    graph = if min_node == start
              graph_v[start].merge(graph_h[start])
            else
              count.even? ? graph_v[min_node] : graph_h[min_node]
            end

    # For each neighboring node of the current node
    graph.each do |neighbor, value|
      # Calculate tentative distance to the neighboring node
      alt = distances[min_node] + value
      # If this newly computed distance is shorter than the previously known one, update the shortest distance for the neighbor
      distances[neighbor] = alt if alt < distances[neighbor]
    end

    # Mark the node as visited
    visited[min_node] = true
    # Remove the node from the list of unvisited nodes
    nodes.delete(min_node)

    # Increment counter
    count += 1
  end

  # Return the shortest distances from the starting node to all other nodes
  distances
end

file_data = File.readlines('day17/test_input.txt')
max_y = file_data.length - 1
graph_v = {}
graph_h = {}

file_data.each_with_index do |line, y|
  max_x = file_data[y].chars.reject { |c| c == "\n" }.length - 1
  line.chars.reject { |c| c == "\n" }.each_with_index do |_char, x|
    graph_h["#{y}:#{x}"] = get_all_neighbors(y, x, max_y, max_x, file_data, 3, :horizontal)
    graph_v["#{y}:#{x}"] = get_all_neighbors(y, x, max_y, max_x, file_data, 3, :vertical)
  end
end

# puts "Horizontal graph"
# puts graph_h

# puts "Vertical graph"
# puts graph_v

# Test the function with node 'A' as the starting point
path = dijkstra(graph_h, graph_v, '0:0')

puts path

# Part 1:
puts "Part 1: #{path['12:12']}"
