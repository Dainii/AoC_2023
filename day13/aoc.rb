# frozen_string_literal: true

file_data = File.read('day13/real_input.txt')
patterns = file_data.split("\n\n")

all_row_ids = []
all_column_ids = []

patterns.each do |pattern|
  pattern = pattern.split("\n")

  row_length = pattern.first.length
  col_length = pattern.length

  columns = []
  (0..row_length - 1).each { |l| columns[l] = '' }
  pattern.each do |row|
    (0..row.length - 1).each do |col|
      columns[col] += row[col]
    end
  end

  pattern.each_with_index do |row, index|
    # puts "Row #{index + 1}: #{row}"
  end

  columns.each_with_index do |col, index|
    # puts "Col #{index + 1}: #{col}"
  end

  row_candidates = []
  last_row = ''
  (1..col_length).each do |id|
    if id == 1
      last_row = pattern[0]
      next
    end

    row_candidates << (id - 1) if pattern[id - 1] == last_row

    last_row = pattern[id - 1]
  end

  col_candidates = []
  last_col = ''
  (1..columns.length).each do |id|
    if id == 1
      last_col = columns[0]
      next
    end

    col_candidates << (id - 1) if columns[id - 1] == last_col

    last_col = columns[id - 1]
  end

  # puts "Row candidates #{row_candidates}"
  # puts "Col candidates #{col_candidates}"

  row_candidates.each do |candidate|
    valid = true
    row_id = candidate
    row_count = 1

    while row_id.positive? && (row_id + row_count) <= col_length
      # puts "Check row #{row_id} -> #{pattern[row_id - 1]}"
      # puts "With row #{row_id + row_count} -> #{pattern[row_id - 1 + row_count]}"
      valid = pattern[row_id - 1] == pattern[row_id - 1 + row_count]

      break unless valid

      row_id -= 1
      row_count += 2
    end

    # puts "Candidate row #{candidate} is valid: #{valid}"
    all_row_ids << candidate if valid
  end

  col_candidates.each do |candidate|
    valid = true
    col_id = candidate
    col_count = 1

    while col_id.positive? && (col_id + col_count) <= row_length
      # puts "Check col #{col_id} -> #{columns[col_id - 1]}"
      # puts "With col #{col_id + col_count} -> #{columns[col_id - 1 + col_count]}"
      valid = columns[col_id - 1] == columns[col_id - 1 + col_count]

      break unless valid

      col_id -= 1
      col_count += 2
    end

    # puts "Candidate col #{candidate} is valid: #{valid}"
    all_column_ids << candidate if valid
  end

  # puts "\n"
end

puts "Row mirrors #{all_row_ids}"
puts "Column mirrors #{all_column_ids}"

p1_total = all_column_ids.sum + all_row_ids.sum { |r| r * 100 }

# Part 1: 30535
puts "Part 1: #{p1_total}"
