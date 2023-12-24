# frozen_string_literal: true

Point = Struct.new(:x, :y)

class Line
  attr_reader :a, :b, :x, :y, :vx, :vy

  def initialize(point1, point2, velocity)
    @a = (point1.y - point2.y).fdiv(point1.x - point2.x)
    @b = point1.y - (@a * point1.x)

    @x = point1.x
    @y = point1.y

    @vx = eval(velocity[0])
    @vy = eval(velocity[1])
  end

  def intersect(other)
    return nil if @a == other.a

    x = (other.b - @b).fdiv(@a - other.a)
    y = (@a * x) + @b
    Point.new(x, y)
  end

  def point_in_futur(point)
    x_in_futur = if @vx.positive?
                   point.x > @x
                 else
                   point.x < @x
                 end

    y_in_futur = if @vy.positive?
                   point.y > @y
                 else
                   point.y < @y
                 end

    x_in_futur && y_in_futur
  end

  def to_s
    "y = #{@a}x #{@b.positive? ? '+' : '-'} #{@b.abs}"
  end
end

file_data = File.readlines('day24/real_input.txt')

lines = []

file_data.each do |line|
  line = line.split('@')
  p1 = line.first.strip.split(',')
  p2 = line.last.strip.split(',')

  lines << Line.new(
    Point.new(p1[0].to_i, p1[1].to_i),
    Point.new(p1[0].to_i + eval(p2[0]), p1[1].to_i + eval(p2[1])),
    p2
  )
end

lines_count = lines.length - 1
MIN = 200_000_000_000_000.0
MAX = 400_000_000_000_000.0

possible_intersect = 0

lines.each_with_index do |line, index|
  next unless index < lines_count

  # puts "Line #{line}"

  (index + 1..lines_count).each do |id|
    # puts "Crossed with #{lines[id]}"
    intersect_point = line.intersect(lines[id])
    next unless intersect_point

    # puts "at #{intersect_point}"

    if (
      (MIN..MAX).include?(intersect_point.x) &&
      (MIN..MAX).include?(intersect_point.y) &&
      line.point_in_futur(intersect_point) &&
      lines[id].point_in_futur(intersect_point)
    )

      # puts 'I am in'
      possible_intersect += 1
    end
  end

  # puts ''
end

# Part 1 - 13892
puts "Part 1: #{possible_intersect}"
