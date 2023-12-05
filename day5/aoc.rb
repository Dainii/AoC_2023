# frozen_string_literal: true

class Seed
  attr_accessor :id, :stage, :result

  def initialize(id)
    @id = id.to_i
    @stage = :seed
    @result = @id
  end

  def process(maps)
    until @stage == :location
      map = maps.select { |m| m.from == @stage }.first

      @result = map.calculate(@result)
      @stage = map.to
    end

    # puts "Seed #{@id} location = #{@result}"
  end
end

class Map
  attr_accessor :from, :to, :lines

  def initialize(map)
    @lines = []
    extract_map_info(map)
    extract_map_lines(map)
  end

  def extract_map_info(map)
    type = map[/([^\s]+)/, 1].split('-')
    @from = type.first.to_sym
    @to = type.last.to_sym
  end

  def extract_map_lines(map)
    lines = map.split("\n")
    lines.delete_at(0)

    lines.each do |line|
      info = line.split
      @lines << {
        source: info[1].to_i,
        destination: info[0].to_i,
        range: info[2].to_i
      }
    end
  end

  def calculate(id)
    result = id
    @lines.each do |line|
      if (line[:source]..(line[:source] + line[:range] - 1)).include?(id)
        result = line[:destination] + (id - line[:source])
      end
    end
    result
  end
end

file_data = File.read('day5/real_input.txt')
data = file_data.split("\n\n")
seeds = []
maps = []
locations = []

data[0][/seeds: (.*)/, 1].split.each do |seed|
  seeds << Seed.new(seed)
end
data.delete_at(0)

data.each do |map|
  maps << Map.new(map)
end

# maps.each do |map|
#   puts "Map from #{map.from} to #{map.to}"
#   puts map.lines
#   puts "---"
# end

seeds.each do |seed|
  seed.process(maps)
  locations << seed.result
end

# Part 1
puts "Part 1: #{locations.min}"

data2 = file_data.split("\n\n")
data_seeds = data2[0][/seeds: (.*)/, 1].split

count = 0
location = 0

# (0..data_seeds.length / 2).each do |pair|
#   (data_seeds[pair].to_i..data_seeds[pair].to_i + data_seeds[count].to_i - 1).each do |id|
#     seed = Seed.new(id)
#     seed.process(maps)
#     location = seed.result if seed.result < location || location.zero?
#     count += 2
#   end
# end

(919_339_981..(919_339_981 + 562_444_630 - 1)).each do |id|
  seed = Seed.new(id)
  seed.process(maps)
  location = seed.result if seed.result < location || location.zero?
end

puts location
