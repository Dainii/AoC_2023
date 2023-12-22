# frozen_string_literal: false

class Numeric
  ALPH = ('a'..'z').to_a

  def alph
    return '' if self < 1

    s = ''
    q = self
    loop do
      q, r = (q - 1).divmod(26)
      s.prepend(ALPH[r])
      break if q.zero?
    end
    s
  end
end

class SandCube
  attr_accessor :id, :x, :y, :z, :length, :dept, :height, :dependencies, :chain

  def initialize(id, info)
    @id = id

    coord = info[0].split(',')
    size = info[1].split(',')

    @x = coord[0].to_i
    @y = coord[1].to_i
    @z = coord[2].to_i

    @length = size[0].to_i - coord[0].to_i
    @dept = size[1].to_i - coord[1].to_i
    @height = size[2].to_i - coord[2].to_i

    @dependencies = []
  end

  def dependencies_alpha
    return 'the ground' if @dependencies.empty?

    @dependencies.map { |d| (d + 1).alph.upcase }.join(', ')
  end

  def alpha_id
    (@id + 1).alph.upcase
  end

  def to_s
    "Cube #{@id} (#{@x}:#{@y}:#{@z}) is #{@length + 1} long, #{@dept + 1} deep and #{@height + 1} high"
  end

  def overlap?(range1, range2)
    !(range1.first > range2.last || range1.last < range2.first)
  end

  def fall(grid)
    return if @z == 1

    occupied_space = false
    # puts "Cube #{@id} is at #{@z} level"

    grid.select { |_k, v| v.z == @z - 1 || v.z + v.height == @z - 1 }.each do |_key, cube|
      # puts "Compare to #{cube}"
      occupied_space ||= overlap?([@x, @x + @length], [cube.x, cube.x + cube.length]) &&
                         overlap?([@y, @y + @dept], [cube.y, cube.y + cube.dept])
    end

    # puts "Cube #{@id} space under it is occupied -> #{occupied_space}"

    return if occupied_space

    @z -= 1
    fall(grid)
  end

  def build_dependencies(grid)
    test_grid = grid.select { |_k, v| v.z == @z - 1 || v.z + v.height == @z - 1 }

    return if test_grid.empty?

    test_grid.each do |k, v|
      above = overlap?([@x, @x + @length], [v.x, v.x + v.length]) &&
              overlap?([@y, @y + @dept], [v.y, v.y + v.dept])

      @dependencies << k if above
    end
  end

  def chain_reaction(grid)
    above_cubes = grid.select { |_k, v| v.z > @z + @height }

    removed_cubes = [@id]

    above_cubes.sort_by { |_k, v| v.z }.each do |cube|
      removed_cubes << cube[0] if cube[1].dependencies.all? { |d| removed_cubes.include?(d) }
    end

    @chain = removed_cubes.length - 1
  end
end

file_data = File.readlines('day22/real_input.txt')

grid = {}

file_data.each_with_index { |line, index| grid[index] = SandCube.new(index, line.split('~')) }

puts 'Start'
# grid.each { |_k, v| puts v }
puts ''

puts 'Cubes falling ...'
grid.sort_by { |_k, v| v.z }.each { |c| c[1].fall(grid) }
# grid.each { |_k, v| puts v if v.z == 1 }
puts ''

puts 'Build dependencies ...'
grid.each { |_k, v| v.build_dependencies(grid) }
# grid.sort_by { |_k, v| v.z }.each { |c| puts "#{c[1]} is supported by #{c[1].dependencies_alpha}" }
puts ''

puts 'Calculate which bricks can be disintegrated'
disintegrated_bricks_count = 0
grid.each do |key, _cube|
  safe = grid.select { |_k, v| v.dependencies.include?(key) && v.dependencies.length == 1 }.count.zero?
  disintegrated_bricks_count += 1 if safe
end
puts ''

# Part 1
# 1134 - too high
# 437 - ok
puts "Part 1: #{disintegrated_bricks_count}"
puts ''

puts 'Calculate chain reaction ...'
grid.each { |_k, v| v.chain_reaction(grid) }
# grid.each { |k, v| puts "#{v} would generate a chain of #{v.chain}" }
puts ''

# Part 2 - 42561
puts "Part 2: #{grid.sum { |_k, v| v.chain }}"
