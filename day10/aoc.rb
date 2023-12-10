# frozen_string_literal: true

class Pipe
  attr_accessor :coord_x, :coord_y, :type, :connected_pipes, :completed

  def initialize(coord_y, coord_x, type, neighbor_pipe = nil)
    @coord_x = coord_x
    @coord_y = coord_y
    @type = type
    @connected_pipes = initialize_connected_pipes
    connect_neighbor_pipe(neighbor_pipe) if neighbor_pipe
    @completed = false
  end

  def initialize_connected_pipes
    pipes = {}

    case @type
    when 'F'
      pipes[:east] = nil
      pipes[:south] = nil
    when '-'
      pipes[:east] = nil
      pipes[:west] = nil
    when '7'
      pipes[:south] = nil
      pipes[:west] = nil
    when '|'
      pipes[:north] = nil
      pipes[:south] = nil
    when 'J'
      pipes[:north] = nil
      pipes[:west] = nil
    when 'L'
      pipes[:north] = nil
      pipes[:east] = nil
    end

    pipes
  end

  def connect_neighbor_pipe(neighbor_pipe)
    @connected_pipes[neighbor_pipe[:location]] = neighbor_pipe[:pipe]
  end

  def coordonates_by_location(location)
    case location
    when :north
      [@coord_y - 1, @coord_x]
    when :south
      [@coord_y + 1, @coord_x]
    when :east
      [@coord_y, @coord_x + 1]
    when :west
      [@coord_y, @coord_x - 1]
    end
  end

  def reverse_location(location)
    match_location = {
      north: :south,
      sourth: :north,
      east: :west,
      west: :east
    }
    match_location[location]
  end

  def find_connected_pipes(diagram, loop)
    @connected_pipes.each_key do |neighbor|
      next if @connected_pipes[neighbor]

      coordonates = coordonates_by_location(neighbor)

      unless (pipe = loop.select { |p| p.coord_y == coordonates.first && p.coord_x == coordonates.last }.first)
        pipe = Pipe.new(
          coordonates.first,
          coordonates.last,
          diagram[coordonates.first][coordonates.last],
          { location: reverse_location(neighbor), pipe: self }
        )
        loop << pipe
        # pipe.find_connected_pipes(diagram, loop)
      end

      @connected_pipes[neighbor] = pipe
    end

    @completed = true if @connected_pipes.each_key { |n| @connected_pipes[n] }
  end
end

# Is pipe2 at orientation of S
def connected_pipes?(orientation, pipe2)
  case orientation
  when :east
    return false unless ['F', '-', 'L'].include?(pipe2)

    true
  when :west
    return false unless ['-', '7', 'J'].include?(pipe2)

    true
  when :north
    return false unless ['|', '7', 'F'].include?(pipe2)

    true
  when :south
    return false unless ['|', 'L', 'J'].include?(pipe2)

    true
  end
end

def find_s_type(s_coordonates, diagram)
  neighbors = []

  if s_coordonates.last <= diagram[s_coordonates.first].length - 1 && connected_pipes?(
    :east,
    diagram[s_coordonates.first][s_coordonates.last + 1]
  )
    neighbors << :east
  end

  if !s_coordonates.last.zero? && connected_pipes?(
    :west,
    diagram[s_coordonates.first][s_coordonates.last - 1]
  )
    neighbors << :west
  end

  if s_coordonates.last <= diagram.length - 1 && connected_pipes?(
    :south,
    diagram[s_coordonates.first + 1][s_coordonates.last]
  )
    neighbors << :south
  end

  if !s_coordonates.first.zero? && connected_pipes?(
    :north,
    diagram[s_coordonates.first - 1][s_coordonates.last]
  )
    neighbors << :north
  end

  # puts "Neighbors: #{neighbors}"

  return 'F' if neighbors.all? { |n| %i[south east].include?(n) }
  return '-' if neighbors.all? { |n| %i[west east].include?(n) }
  return '7' if neighbors.all? { |n| %i[west south].include?(n) }
  return '|' if neighbors.all? { |n| %i[north south].include?(n) }
  return 'J' if neighbors.all? { |n| %i[north west].include?(n) }
  return 'L' if neighbors.all? { |n| %i[north east].include?(n) }
end

file_data = File.readlines('day10/real_input.txt')

# Create the 2D array
diagram = []

s_coordonates = []

file_data.each_with_index do |line, y|
  diagram[y] = []

  line.chars.each_with_index do |char, x|
    next if char == "\n"

    diagram[y][x] = char
    s_coordonates = [y, x] if char == 'S'
  end
end

# puts 'Diagram:'
# diagram.each do |line|
#   puts line.to_s
# end

loop = []

s_type = find_s_type(s_coordonates, diagram)
puts "S is a #{s_type}"

loop << Pipe.new(s_coordonates.first, s_coordonates.last, s_type)

loop.first.find_connected_pipes(diagram, loop)

while loop.select { |p| p.completed == false }.count.positive?
  loop.select { |p| p.completed == false }.each do |pipe|
    pipe.find_connected_pipes(diagram, loop)
  end
end

loop.each do |pipe|
  # puts "Pipe type #{pipe.type}"

  pipe.connected_pipes.delete(nil)
  pipe.connected_pipes.each_key do |location|
    next unless pipe.connected_pipes[location]

    # puts "Pipe #{location} type #{pipe.connected_pipes[location].type} connected at #{pipe.connected_pipes[location].coord_y}:#{pipe.connected_pipes[location].coord_x}"
  end
  # puts "---"
end

# Part 1: 6856
puts "Number of step: #{loop.length / 2}"
