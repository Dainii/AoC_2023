# frozen_string_literal: true

file_data = File.readlines('day11/real_input.txt')

line_length = file_data.first.length
row_length = file_data.length

empty_factor = 999_999

empty_lines = []
# Find empty lines
file_data.each_with_index do |line, index|
  # puts "Line #{index}: #{line}"
  empty_lines << index if line.chars.reject { |c| c == "\n" }.uniq.count == 1 && line.chars.reject do |c|
                            c == "\n"
                          end.uniq.first == '.'
end
# puts empty_lines.join

empty_rows = []
# Find empty rows
(0..row_length - 1).each do |index|
  row = ''
  file_data.each do |line|
    row += line[index] if line[index]
  end
  # puts "Row #{index}: #{row}"
  empty_rows << index if row.chars.uniq.count == 1 && row.chars.uniq.first == '.'
end
# puts empty_rows.join

galaxy_id = 1
galaxies_locations = {}

file_data.each_with_index do |line, y|
  line.chars.each_with_index do |char, x|
    next unless char == '#'

    galaxies_locations[galaxy_id] = [y, x]
    # file_data[y][x] = galaxy_id.to_s
    galaxy_id += 1
  end
end

# Expanded galaxy
# puts 'Expanded galaxy'
# file_data.each_with_index do |line, index|
#   puts "Line: #{index}: #{line}"
# end

# puts galaxies_locations

def calc_empty_lines(galaxy1, galaxy2, empty_lines)
  count = 0
  min_y = [galaxy1.first, galaxy2.first].min
  max_y = [galaxy1.first, galaxy2.first].max

  empty_lines.each do |line_id|
    count += 1 if line_id.between?(min_y, max_y)
  end

  count
end

def calc_empty_rows(galaxy1, galaxy2, empty_rows)
  count = 0
  min_y = [galaxy1.last, galaxy2.last].min
  max_y = [galaxy1.last, galaxy2.last].max

  empty_rows.each do |row_id|
    count += 1 if row_id.between?(min_y, max_y)
  end

  count
end

def galaxy_path_length(galaxy1, galaxy2, empty_factor, empty_lines, empty_rows)
  base = (galaxy2.first - galaxy1.first).abs + (galaxy2.last - galaxy1.last).abs

  base += (empty_factor * calc_empty_lines(galaxy1, galaxy2, empty_lines))
  base += (empty_factor * calc_empty_rows(galaxy1, galaxy2, empty_rows))

  base
end

total_path_length = 0
pairs = 0

(1..galaxy_id - 1).each do |id|
  # puts "Path length between galaxy #{id}"
  (id + 1..galaxy_id - 1).each do |id2|
    path_length = galaxy_path_length(
      galaxies_locations[id],
      galaxies_locations[id2],
      empty_factor, empty_lines,
      empty_rows
    )
    # puts "and galaxy #{id2}: #{path_length}"
    total_path_length += path_length

    pairs += 1
  end
end

puts "Total pair: #{pairs}"

# Part 1: 9275815 - too high
# 9274989 - right answer
# puts "Part 1: #{total_path_length}"
# Part 2: 357134917863 - too high
# 357134560737 - correct answer
puts "Part 2: #{total_path_length}"
