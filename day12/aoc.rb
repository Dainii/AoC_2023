# frozen_string_literal: true

class Record
  attr_accessor :records, :broken_groups

  def initialize(records, broken_groups)
    @records = records
    @broken_groups = broken_groups.split(',').map(&:to_i)
  end

  def find_isolated_groups
    records = @records.split('.')

    isolated_groups = []
    records.each do |record|
      isolated_groups << record.length if record.chars.uniq.count == 1 && record.chars.uniq.first == '#'
    end
    puts "Isolated group: #{isolated_groups.join(',')}"

    isolated_groups
  end

  def group_to_find(isolated_groups)
    group = @broken_groups.join

    isolated_groups.each do |p|
      group = group.sub(p.to_s, '')
    end

    group.chars.map(&:to_i)
  end

  def group_possible?(record, size)
    puts "Test sample #{record} with size #{size}"
    uniq_chars = record.chars.uniq
    return true if uniq_chars.count == 1 && uniq_chars.first == '?'
    return false if !uniq_chars.include?('?') && record.count('#') == size && record.chars.last == '#'
    return false if record.length == size + 2 && record.chars.last == '#'
    return false if record.length == size + 2 && record.chars.first == '#'
    return false if record.scan(/(#|\?)/).count < size
    return false if record.chars.last == '?' && !uniq_chars.include?('#') && record.count('?') <= size
    return false if record.length < size + 2 && record.count('#') > size

    return true if record.count('#') == size && record.chars.last.match?(/(\.|\?)/)
    return true if record.chars.last == '?' && record.gsub('?', '#').count('#') == size + 1

    return false if record.chars.first == '?' && record.gsub('?', '#').count('#') > size

    true
  end

  def create_possible_arrangement(record, group)
    return 'not possible' if record.count('?').zero?

    index = 0
    puts "- record #{record}"
    group.each do |g|
      puts "index #{index} with group size #{g}"

      group_start = index.zero? ? 0 : index - 1
      group_end = index + g

      until group_possible?(record[group_start..group_end], g)
        return 'not possible' if index > record.length - g - 1

        index = index += 1
        group_start = index - 1
        group_end = index + g
      end

      record[index..index + g - 1] = '#' * g

      record[index + g] = '.' if record[index + g] != '.'
      puts "record: #{record}"

      index += g + 1
    end

    record
  end

  def arrangements
    arrangements = 1

    groups = group_to_find(find_isolated_groups)
    puts "Groups left to find #{groups}"

    record = create_possible_arrangement(@records.dup, groups)
    puts "Arrangement 1: #{record}"

    # If the first ? was not replaced, it cannot be used
    @records[0] = '.' if record[0] == '?'

    # Replace the first ? by a . to try to find new arrangements
    @records = @records.sub('?', '.')

    record = create_possible_arrangement(@records.dup, groups)
    puts "Arrangement 2: #{record}"

    arrangements
  end
end

file_data = File.readlines('day12/test_input.txt')

total_arrangements = 0

file_data.each do |line|
  record = Record.new(line.split.first, line.split.last)

  puts "Record #{record.records} - Broken groups #{record.broken_groups.join(',')}"

  total_arrangements += record.arrangements
  puts '---'
end

# Part 1:
puts "Part 1: #{total_arrangements}"
