# frozen_string_literal: true

class Hole
  attr_accessor :y, :x, :rgb

  def initialize(params = {})
    @y = params.fetch(:y)
    @x = params.fetch(:x)
    @rgb = params.fetch(:rgb)
  end
end

file_data = File.readlines('day18/real_input.txt')

dig_plan = []
vertices = []

x = 0
y = 0

file_data.each do |line|
  line = line.split
  case line[0]
  when 'R'
    line[1].to_i.times do
      x += 1
      dig_plan << Hole.new(x:, y:, rgb: line[2])
    end
  when 'D'
    line[1].to_i.times do
      y += 1
      dig_plan << Hole.new(x:, y:, rgb: line[2])
    end
  when 'L'
    line[1].to_i.times do
      x -= 1
      dig_plan << Hole.new(x:, y:, rgb: line[2])
    end
  when 'U'
    line[1].to_i.times do
      y -= 1
      dig_plan << Hole.new(x:, y:, rgb: line[2])
    end
  end

  vertices << Hole.new(x:, y:, rgb: line[2])
end

# dig_plan.each do |trench|
#   trench_line = ''
#   trench.each do |hole|
#     trench_line += hole ? '#' : '.'
#   end
#   puts trench_line
# end

sum_vertices = 0
perimeter = 0

# area of a irregular polygon
# A = 0.5 * |(x1*y2 - x2*y1) + (x2*y3 - x3*y2) + ... + (xn*y1 - x1*yn)|
vertices.each_with_index do |vertice, index|
  # puts "Vertice y=#{vertice.y} x=#{vertice.x}"
  sum_vertices += if index < vertices.length - 1
                    (vertice.x * vertices[index + 1].y) - (vertices[index + 1].x * vertice.y)
                  else
                    (vertice.x * vertices[0].y) - (vertices[0].x * vertice.y)
                  end

  perimeter += if index < vertices.length - 1
                 (vertices[index + 1].x - vertice.x).abs + (vertices[index + 1].y - vertice.y).abs
               else
                 (vertices[0].x - vertice.x).abs + (vertices[0].y - vertice.y).abs
               end

  # puts "sum vertices : #{sum_vertices}"
end

area = 0.5 * sum_vertices.abs
puts "Area: #{area}"
puts "Perimeter: #{perimeter}"

# Part 1: 40745
puts "Real area = #{area + (perimeter / 2) + 1}"
