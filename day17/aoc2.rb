# frozen_string_literal: true

class Path
  attr_accessor :y, :x, :trail, :cost, :loop, :direction

  def initialize(params = {})
    @y = params.fetch(:y)
    @x = params.fetch(:x)
    @trail = []
    @loop = false
    @cost = 0
    @direction = nil
  end

  def get_neighbor_direction(node, neighbor)
    return :up if !node[0].to_i.zero? && neighbor[0].to_i < node[0].to_i
    return :down if neighbor[0].to_i > node[0].to_i
    return :right if neighbor[1].to_i > node[1].to_i
    return :left if !node[1].to_i.zero? && neighbor[1].to_i < node[1].to_i

    nil
  end

  def neighbors(max_y, max_x)
    neighbors_list = []

    if @x.zero?
      neighbors_list << [@y, @x + 1]
    elsif @x == max_x
      neighbors_list << [@y, @x - 1]
    else
      neighbors_list << [@y, @x + 1]
      neighbors_list << [@y, @x - 1]
    end

    if @y.zero?
      neighbors_list << [@y + 1, @x]
    elsif @y == max_y
      neighbors_list << [@y - 1, @x]
    else
      neighbors_list << [@y + 1, @x]
      neighbors_list << [@y - 1, @x]
    end

    neighbors_list
  end

  def get_possible_positions(map, max_y, max_x)
    possible_paths = []
    neighbor_weight = {}

    neighbors(max_y, max_x).each do |neighbor|
      neighbor_weight["#{neighbor[0]}:#{neighbor[1]}"] = 0

      neighbor_weight["#{neighbor[0]}:#{neighbor[1]}"] += 1 if %i[
        right
        down
      ].include?(get_neighbor_direction([@y, @x], neighbor))
      neighbor_weight["#{neighbor[0]}:#{neighbor[1]}"] += 5 if %i[
        left
        up
      ].include?(get_neighbor_direction([@y, @x], neighbor))

      neighbor_weight["#{neighbor[0]}:#{neighbor[1]}"] += map[neighbor[0]][neighbor[1]].to_i
    end

    lower_weight = neighbor_weight.values.min
    neighbor_weight.select { |_k, v| v == lower_weight }.each_key do |key|
      key = key.split(':')
      possible_paths << { y: key[0].to_i, x: key[1].to_i }
    end

    possible_paths
  end

  def move(possible_paths, map, max_y, max_x)
    return if @y == max_y && @x == max_x

    next_possible_positions = get_possible_positions(map, max_y, max_x)

    alt_y = next_possible_positions[0][:y]
    alt_x = next_possible_positions[0][:x]

    @direction = get_neighbor_direction([@y, @x], [alt_y, alt_x])
    @y = alt_y
    @x = alt_x

    if @trail.include?(["#{@y}:#{@x}"])
      @loop = true
      return
    end

    @trail << ["#{@y}:#{@x}"]
    @cost += map[@y][@x].to_i

    return unless next_possible_positions.count > 1 && possible_paths.length < 5

    (1..next_possible_positions.length - 1).each do |path_id|
      new_path = Path.new(
        y: next_possible_positions[path_id][:y],
        x: next_possible_positions[path_id][:x]
      )
      new_path.cost = @cost + map[new_path.y][new_path.x].to_i
      new_path.trail = @trail + ["#{new_path.y}:#{new_path.x}"]
      new_path.direction = get_neighbor_direction([new_path.y, new_path.x], [alt_y, alt_x])

      possible_paths << new_path
    end
  end
end

file_data = File.readlines('day17/test_input.txt')

map = []
file_data.each_with_index do |line, index|
  map[index] = line.chars.reject { |c| c == "\n" }
end

max_y = map.length - 1
max_x = map[0].length - 1

possible_paths = []
possible_paths << Path.new(y: 0, x: 0)

while possible_paths.reject { |p| (p.y == max_y && p.x == max_x) || p.loop }.count.positive?
  possible_paths.each do |path|
    path.move(possible_paths, map, max_y, max_x)
  end
end

possible_paths.each do |path|
  puts "Path: #{path.trail.join(',')}"
  puts "Cost: #{path.cost}"
end
