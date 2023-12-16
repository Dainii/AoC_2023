# frozen_string_literal: true

class Beam
  attr_accessor :direction, :col, :row, :out, :loop_count

  def initialize(params = {})
    @direction = params.fetch(:direction, :east)
    @col = params.fetch(:col, 0)
    @row = params.fetch(:row, 0)
    @out = false
    @loop_count = 0
  end

  def move(layout, beams, energized_tiles)
    max_row = layout[@row].length - 1
    max_col = layout.length - 1

    # move one tile in the correct direction
    case @direction
    when :east
      if @col == max_col
        @out = true
      else
        @col += 1
      end
    when :west
      if @col.zero?
        @out = true
      else
        @col -= 1
      end
    when :north
      if @row.zero?
        @out = true
      else
        @row -= 1
      end
    when :south
      if @row == max_row
        @out = true
      else
        @row += 1
      end
    end

    # If the case is already visited, consider it out too
    @loop_count = energized_tiles.include?([@row, @col]) ? @loop_count + 1 : 0
    @out = true if @loop_count > 10

    return if @out

    # Determine the new direction
    case layout[@row][@col]
    when '-'
      if @direction == :north || @direction == :south
        @direction = :east
        beams << Beam.new(direction: :west, col: @col, row: @row)
      end
    when '|'
      if @direction == :east || @direction == :west
        @direction = :north
        beams << Beam.new(direction: :south, col: @col, row: @row)
      end
    when '/'
      slash_matrix = {
        east: :north,
        north: :east,
        west: :south,
        south: :west
      }
      @direction = slash_matrix[@direction]
    when '\\'
      backslash_matrix = {
        east: :south,
        south: :east,
        west: :north,
        north: :west
      }
      @direction = backslash_matrix[@direction]
    end

    [@row, @col]
  end
end

file_data = File.readlines('day16/test_input.txt')

layout = []
file_data.each_with_index do |line, index|
  layout[index] = line.chars.reject { |c| c == "\n" }
end

# Create the first beam
beams = []
energized_tiles = []

beams << Beam.new(col: -1)

while beams.reject(&:out).count.positive?
  # 40.times do
  beams.each do |beam|
    next if beam.out

    energized_tiles << beam.move(layout, beams, energized_tiles)
  end
end

beams.each do |beam|
  # puts "beam at #{beam.row}:#{beam.col}, direction #{beam.direction} is out ? #{beam.out}"
end

# Part 1
# 7473 - too high
# 7472 - correct answer
puts "nbr of energized tiles: #{energized_tiles.uniq.count - 1}"
