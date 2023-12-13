# frozen_string_literal: true

file_data = File.read('day13/real_input.txt')
patterns = file_data.split("\n\n")

all_row_ids = []
all_column_ids = []
all_row_ids2 = []
all_column_ids2 = []

patterns.each_with_index do |pattern, pattern_id|
  pattern = pattern.split("\n")

  row_length = pattern.first.length
  col_length = pattern.length
  found_mirror = false

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
  row_candidates2 = []
  last_row = ''
  (1..col_length).each do |id|
    if id == 1
      last_row = pattern[0]
      next
    end

    row_candidates << (id - 1) if pattern[id - 1] == last_row

    row_diff = 0
    (0..pattern[id - 1].length - 1).each do |char_id|
      row_diff += 1 if pattern[id - 1][char_id] != last_row[char_id]
    end
    row_candidates2 << (id - 1) if row_diff == 1

    last_row = pattern[id - 1]
  end
  row_candidates2 += row_candidates

  col_candidates = []
  col_candidates2 = []
  last_col = ''
  (1..columns.length).each do |id|
    if id == 1
      last_col = columns[0]
      next
    end

    col_candidates << (id - 1) if columns[id - 1] == last_col

    # puts "check candidate #{id} against #{columns[id - 1]}"
    # puts "against candidate #{id - 1} against #{last_col}"
    col_diff = 0
    (0..columns[id - 1].length - 1).each do |char_id|
      col_diff += 1 if columns[id - 1][char_id] != last_col[char_id]
    end
    col_candidates2 << (id - 1) if col_diff == 1

    last_col = columns[id - 1]
  end
  col_candidates2 += col_candidates

  # puts "Row candidates #{row_candidates}"
  # puts "Col candidates #{col_candidates}"
  # puts "Row candidates2 #{row_candidates2}"
  # puts "Col candidates2 #{col_candidates2}"

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

  row_candidates2.each do |candidate|
    row_id = candidate
    row_count = 1
    row_diff = 0

    while row_id.positive? && (row_id + row_count) <= col_length
      # puts "Check row #{row_id} -> #{pattern[row_id - 1]}"
      # puts "With row #{row_id + row_count} -> #{pattern[row_id - 1 + row_count]}"
      (0..pattern[row_id - 1].length - 1).each do |char_id|
        row_diff += 1 if pattern[row_id - 1][char_id] != pattern[row_id - 1 + row_count][char_id]
      end

      row_id -= 1
      row_count += 2
    end

    # puts "Row #{candidate} total difference is #{row_diff}"
    if row_diff == 1
      all_row_ids2 << candidate
      found_mirror = true
    end
  end

  col_candidates.each do |candidate|
    valid = true
    col_id = candidate
    col_count = 1
    col_diff = 0

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

  col_candidates2.each do |candidate|
    col_id = candidate
    col_count = 1
    col_diff = 0

    while col_id.positive? && (col_id + col_count) <= row_length
      # puts "Check col #{col_id} -> #{columns[col_id - 1]}"
      # puts "With col #{col_id + col_count} -> #{columns[col_id - 1 + col_count]}"
      (0..columns[col_id - 1].length - 1).each do |char_id|
        col_diff += 1 if columns[col_id - 1][char_id] != columns[col_id - 1 + col_count][char_id]
      end

      col_id -= 1
      col_count += 2
    end

    if col_diff == 1
      all_column_ids2 << candidate
      found_mirror = true
    end
  end

  puts "Pattern number #{pattern_id + 1} has no candidate for part 2" unless found_mirror
  # puts "\n"
end

# puts "Row mirrors #{all_row_ids}"
# puts "Column mirrors #{all_column_ids}"
# puts "Total mirrors #{all_row_ids.count + all_column_ids.count}"

p1_total = all_column_ids.sum + all_row_ids.sum { |r| r * 100 }

# Part 1: 30535
puts "Part 1: #{p1_total}"

# puts "Row mirrors part 2 #{all_row_ids2}"
# puts "Column mirrors part 2 #{all_column_ids2}"
# puts "Total mirrors #{all_row_ids2.count + all_column_ids2.count}"

p2_total = all_column_ids2.sum + all_row_ids2.sum { |r| r * 100 }

# Part 2:
# 35479 - too high
# 31079 - too high
# 18279 - too low
# 30844 - right answer
puts "Part 2: #{p2_total}"
