# frozen_string_literal: true

# Credit to Legrems for this solution

class SeedRange
  attr_accessor :start, :end, :range, :shift

  def initialize(start, range)
    @start = start.to_i
    @range = range.to_i
    @end = @start + @range - 1
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
        source_end: info[1].to_i + info[2].to_i - 1,
        destination: info[0].to_i,
        destination_end: info[0].to_i + info[2].to_i - 1,
        range: info[2].to_i,
        shift: info[0].to_i - info[1].to_i
      }
    end
  end

  def line_starts
    @lines.map { |l| [l[:source], l[:source_end]] }.sort.reverse
  end

  def process(seedranges)
    # puts "Start process map #{@from}-to-#{@to}"
    seedranges.each do |seedrange|
      # puts "process seedrange #{seedrange.start} - #{seedrange.end}"
      line_starts.each do |start|
        # puts "check line range #{start.first} to #{start.last}"
        next unless (start.first..start.last).include?(seedrange.start)

        line = @lines.select { |l| l[:source] == start.first }.first

        # unless the whole seed range is in the line
        unless seedrange.end <= line[:source_end]
          # puts "End #{seedrange.end} + #{seedrange.shift} > #{line[:source_end]}"
          new_seedrange_start = line[:source_end] + 1
          new_seedrange_range = seedrange.end - new_seedrange_start + 1

          seedranges << SeedRange.new(new_seedrange_start, new_seedrange_range)
          seedrange.end = line[:source_end]
          seedrange.range = seedrange.range - new_seedrange_range
        end

        seedrange.start += line[:shift]
        seedrange.end += line[:shift]
        break
      end
      # puts "end seedrange #{seedrange.start} - #{seedrange.end}"
    end
    # puts "End process map #{@from}-to-#{@to}"

    seedranges
  end
end

# Part 2
file_data = File.read('day5/real_input.txt')
maps = []
data = file_data.split("\n\n")
data_seedranges = data[0][/seeds: (.*)/, 1].split(/([0-9]+\s[0-9]+)/).reject(&:empty?).reject { |s| s.strip.empty? }
seedranges = []

data_seedranges.each do |range|
  seedranges << SeedRange.new(range.split.first, range.split.last)
end

# puts '--- SeedRange ---'
# seedranges.sort_by(&:start).each do |range|
#   puts "Range start #{range.start} end at #{range.end}"
# end
# puts "Range total: #{seedranges.sum(&:range)}"
# puts '--- SeedRange ---'

data.delete_at(0)
data.each do |map|
  maps << Map.new(map)
end

# puts '--- MAPS ---'
# maps.each do |map|
#   puts "Maps from #{map.from} to #{map.to}"
#   map.lines.each do |line|
#     puts "Line source:#{line[:source]}-#{line[:source_end]} -> destination #{line[:destination]}-#{line[:destination_end]}, shift: #{line[:shift]}"
#   end
#   puts "All map start #{map.line_starts}"
#   puts '---'
# end
# puts '--- MAPS ---'

stages = %i[seed soil fertilizer water light temperature humidity]

stages.each do |stage|
  seedranges = maps.select { |m| m.from == stage }.first.process(seedranges)

  # puts '--- SeedRange ---'
  # seedranges.sort_by(&:start).each do |range|
  #   puts "Range start #{range.start} end at #{range.end}"
  # end
  # puts "Range total: #{seedranges.sum(&:range)}"
  # puts '--- SeedRange ---'
end

# Part 2 -> 60294664
# mri -> ruby day5/aoc2.rb  0.10s user 0.01s system 98% cpu 0.115 total
#
puts "Part 2: #{seedranges.map(&:start).min}"
