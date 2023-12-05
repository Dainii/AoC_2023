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
    @lines.each do |line|
      if (line[:source]..(line[:source] + line[:range] - 1)).include?(id)
        return line[:destination] + (id - line[:source])
      end
    end
    id
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

# Part 1 -> 346433842
puts "Part 1: #{locations.min}"

data2 = file_data.split("\n\n")
data_seeds = data2[0][/seeds: (.*)/, 1].split

count = 0
location = 0

(ARGV[0].to_i..(ARGV[0].to_i + ARGV[1].to_i - 1)).each do |id|
  seed = Seed.new(id)
  seed.process(maps)
  location = seed.result if seed.result < location || location.zero?
end

# Part 2 -> 60294664
puts "Part 2: #{location}"

# 4140591657 5858311 -> 1013518473
# mri -> ruby day5/aoc.rb 4140591657 5858311  91.46s user 0.24s system 100% cpu 1:31.70 total
# jruby -> ruby day5/aoc.rb 4140591657 5858311  88.78s user 0.85s system 107% cpu 1:23.03 total
# truffleruby -> ruby day5/aoc.rb 4140591657 5858311  6.76s user 0.36s system 114% cpu 6.207 total
#
# 2721360939 35899538 -> 60294664
# mri -> ruby day5/aoc.rb 2721360939 35899538  726.18s user 1.76s system 99% cpu 12:07.95 total
# truffleruby -> ruby day5/aoc.rb 2721360939 35899538  46.01s user 1.60s system 102% cpu 46.317 total
#
# 2566406753 71724353 -> 1216540866
# mri -> ruby day5/aoc.rb 2566406753 71724353  1088.18s user 2.66s system 99% cpu 18:10.85 total
#
# 2846055542 49953829 -> 471665171
# mri -> ruby day5/aoc.rb 2846055542 49953829  922.96s user 2.50s system 99% cpu 15:25.69 total
#
# 3366006921 67827214 -> 60579149
# mri -> ruby day5/aoc.rb 3366006921 67827214  1116.03s user 2.63s system 99% cpu 18:38.68 total
#
# 1496677366 101156779 -> 427651238
# mri -> ruby day5/aoc.rb 1496677366 101156779  1724.70s user 4.58s system 99% cpu 28:49.51 total
# truffleruby -> ruby day5/aoc.rb 1496677366 101156779  108.37s user 3.13s system 101% cpu 1:50.08 total
#
# 383860877 424668759 ->
#
# 3649554897 442182562 ->
#
# 2988140126 256306471 -> 94595176
#
# 919339981 562444630 ->
# truffleruby -> ruby day5/aoc.rb 919339981 562444630  1488.06s user 28.02s system 98% cpu 25:37.38 total
#
