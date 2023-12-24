# frozen_string_literal: true

def get_all_neighbors(y, x, max_y, max_x, file_data)
  neighbor = {}

  if x.zero?
    neighbor["#{y}:#{x + 1}"] = 1 if file_data[y][x + 1].match?(/(\.|>|<|\^|v|X)/)
  elsif x == max_x
    neighbor["#{y}:#{x - 1}"] = 1 if file_data[y][x - 1].match?(/(\.|>|<|\^|v|X)/)
  else
    neighbor["#{y}:#{x + 1}"] = 1 if file_data[y][x + 1].match?(/(\.|>|<|\^|v|X)/)
    neighbor["#{y}:#{x - 1}"] = 1 if file_data[y][x - 1].match?(/(\.|>|<|\^|v|X)/)
  end

  if y.zero?
    neighbor["#{y + 1}:#{x}"] = 1 if file_data[y + 1][x].match?(/(\.|>|<|\^|v|X)/)
  elsif y == max_y
    neighbor["#{y - 1}:#{x}"] = 1 if file_data[y - 1][x].match?(/(\.|>|<|\^|v|X)/)
  else
    neighbor["#{y + 1}:#{x}"] = 1 if file_data[y + 1][x].match?(/(\.|>|<|\^|v|X)/)
    neighbor["#{y - 1}:#{x}"] = 1 if file_data[y - 1][x].match?(/(\.|>|<|\^|v|X)/)
  end

  neighbor
end

class Route
  attr_accessor :location, :last_location, :path, :status, :direction, :force_direction

  def initialize(params = {})
    @location = params[:location] || '0:0'
    @last_location = params[:last_location] || nil
    @path = params[:path] || []
    @status = :walking
    @force_direction = nil
    @direction = params[:direction] || nil
  end

  def to_s
    "Route is at #{@location} in #{@status} status"
  end

  def taken_path(map)
    new_map = map.dup
    @path.each do |point|
      point = point.split(':')
      new_map[point.first.to_i][point.last.to_i] = 'O'
    end
    new_map
  end

  def sort_neighbors(neighbors)
    sorted_neighbors = {}
    self_coord = @location.split(':')

    neighbors.each do |neighbor|
      neighbor_coord = neighbor.split(':')

      sorted_neighbors[neighbor] = :up if neighbor_coord.first.to_i < self_coord.first.to_i
      sorted_neighbors[neighbor] = :down if neighbor_coord.first.to_i > self_coord.first.to_i
      sorted_neighbors[neighbor] = :right if neighbor_coord.last.to_i > self_coord.last.to_i
      sorted_neighbors[neighbor] = :left if neighbor_coord.last.to_i < self_coord.last.to_i
    end

    sorted_neighbors
  end

  def find_valid_neighbor(neighbors)
    valid_neighbors = sort_neighbors(neighbors)
    return valid_neighbors unless @force_direction

    neighbors = nil

    case @force_direction
    when :up
      neighbors = valid_neighbors.select { |_k, v| v == :up }
    when :down
      neighbors = valid_neighbors.select { |_k, v| v == :down }
    when :right
      neighbors = valid_neighbors.select { |_k, v| v == :right }
    when :left
      neighbors = valid_neighbors.select { |_k, v| v == :left }
    end

    if neighbors.empty?
      @force_direction = nil
      valid_neighbors
    else
      neighbors
    end
  end

  def get_force_direction(map, point)
    point = point.split(':')

    case map[point.first.to_i][point.last.to_i]
    when '<'
      :left
    when '>'
      :right
    when '^'
      :up
    when 'v'
      :down
    end
  end

  def opposed_direction(force_direction, direction)
    opposed_directions = {
      left: :right,
      right: :left,
      up: :down,
      down: :up
    }

    opposed_directions[force_direction] == direction
  end

  def step_forward(graph, routes, map)
    # puts "Route at location: #{@location} with direction #{@direction} force direction #{@force_direction || 'none'}"

    # Comment this for part 2
    # if @force_direction && opposed_direction(@force_direction, @direction)
    #   @status = :stuck
    #   return
    # end

    neighbors = graph[@location].keys
    neighbors.delete(@last_location)
    valid_neighbors = find_valid_neighbor(neighbors)
    # puts "Valid neighbors: #{valid_neighbors}"

    valid_neighbors.each_key.with_index do |key, index|
      if @path.include?(key)
        @status = :stuck
      elsif index.zero?
        @last_location = @location
        @location = key
        @path << key
        @direction = valid_neighbors[key]
        @force_direction = get_force_direction(map, key)
      else
        new_path = @path.dup
        new_path.delete(valid_neighbors.keys.first)
        new_path << key
        params = {
          location: key,
          last_location: @last_location.dup,
          path: new_path,
          direction: valid_neighbors[key],
          force_direction: get_force_direction(map, key)
        }
        routes << Route.new(params)
      end
    end
  end
end

file_data = File.readlines('day23/real_input.txt')
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

# puts 'Empty map'
# map.each { |l| puts l }

routes = []
new_routes = []
new_routes << Route.new({ location: s_location })
max_route_length = 0

until new_routes.empty?
  routes = new_routes
  new_routes = []

  routes.each do |route|
    while route.status == :walking
      route.step_forward(graph, new_routes, map)
      route.status = :arrived if route.location == x_location
      # puts route
      # sleep(0.5)
    end

    # puts "Route is #{route.status}"
    if route.status == :arrived && route.path.length > max_route_length
      max_route_length = route.path.length
      puts max_route_length
    end
  end
end

# Part 1 - 2438
# max_path_route = routes.max_by { |r| r.path.length }
puts "Part 1: #{max_route_length}"

# Part 2 - comment lines 123-126
# 5674 too low
# 5806 too low
# 5986 too low
