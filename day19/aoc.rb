# frozen_string_literal: true

file_data = File.read('day19/real_input.txt')

file_data = file_data.split("\n\n")

rules_input = file_data[0]
parts_input = file_data[1]

workflows = {}

rules_input.split("\n").each do |workflow|
  workflow_name = workflow[/^[^{]+/]
  workflows[workflow_name] = {}

  workflow[/{([^}]+)/, 1].split(',').each do |rule|
    parts = rule.split(':')

    if parts[1]
      workflows[workflow_name][(parts[0]).to_s] = parts[1]
    else
      workflows[workflow_name]['goto'] = parts[0]
    end
  end
end

# puts workflows

accepted_parts = []
rejected_parts = []

parts_input.split("\n").each do |part_list|
  parts = {}

  part_list.chars.reject { |c| ['{', '}'].include?(c) }.join.split(',').each do |part|
    part = part.split('=')
    parts[part[0]] = part[1].to_i
  end
  # puts "Process parts #{parts}"

  status = nil
  workflow = 'in'

  until %i[accepted rejected].include?(status)
    # puts "With workflow #{workflow} with rules #{workflows[workflow]}"
    workflow_rules = workflows[workflow]

    workflow_rules.each_key do |rule|
      # puts "Rule #{rule}"
      match = false

      if rule == 'goto'
        workflow = workflow_rules[rule]
        match = true
      else
        part_type = rule[0]
        part_condition = rule[1]
        part_check = rule[2..].to_i
        # puts "#{part_type} must be #{part_condition} than #{part_check}"

        case part_condition
        when '<'
          if parts[part_type] < part_check
            workflow = workflow_rules[rule]
            match = true
          end
        when '>'
          if parts[part_type] > part_check
            workflow = workflow_rules[rule]
            match = true
          end
        end
      end

      if workflow == 'A'
        accepted_parts << parts
        status = :accepted
        break
      elsif workflow == 'R'
        rejected_parts << parts
        status = :rejected
        break
      end

      break if match
    end
  end
end

# Part 1 - 352052
total_rating = 0
accepted_parts.each do |part|
  part.each_key { |p| total_rating += part[p] }
end
puts "Part 1: #{total_rating}"

## Part 2

class Range
  attr_accessor :ranges, :start_workflow

  def initialize(params = {})
    @ranges = {}
    @ranges['x'] = params.fetch('x', [1, 4000])
    @ranges['m'] = params.fetch('m', [1, 4000])
    @ranges['a'] = params.fetch('a', [1, 4000])
    @ranges['s'] = params.fetch('s', [1, 4000])
    @start_workflow = params.fetch('start', 'in')
  end

  def combinations
    (@ranges['x'][1] - @ranges['x'][0] + 1) * (@ranges['m'][1] - @ranges['m'][0] + 1) * (@ranges['a'][1] - @ranges['a'][0] + 1) * (@ranges['s'][1] - @ranges['s'][0] + 1)
  end
end

total_rating = 0

parts_ranges = []
parts_ranges << Range.new

result_ranges = []

parts_ranges.each do |range|
  # puts '---'
  # puts "Start range #{range.ranges}"
  status = nil
  workflow = range.start_workflow

  until %i[accepted rejected].include?(status)
    # puts "With workflow #{workflow} with rules #{workflows[workflow]}"
    workflow_rules = workflows[workflow]

    workflow_rules.each_key do |rule|
      # puts "Rule #{rule}"
      match = false

      if rule == 'goto'
        workflow = workflow_rules[rule]
        match = true
      else
        part_type = rule[0]
        part_condition = rule[1]
        part_check = rule[2..].to_i
        # puts "#{part_type} must be #{part_condition} than #{part_check}"

        case part_condition
        when '<'
          if range.ranges[part_type][0] < part_check && range.ranges[part_type][1] >= part_check
            params = {
              'x' => range.ranges['x'].dup,
              'm' => range.ranges['m'].dup,
              'a' => range.ranges['a'].dup,
              's' => range.ranges['s'].dup,
              'start' => workflow
            }
            params[part_type] = [part_check, range.ranges[part_type][1]]
            # puts "New params #{params}"
            parts_ranges << Range.new(params)

            range.ranges[part_type][1] = part_check - 1
            workflow = workflow_rules[rule]
            match = true
          elsif range.ranges[part_type][1] < part_check
            workflow = workflow_rules[rule]
            match = true
          end
        when '>'
          if range.ranges[part_type][0] <= part_check && range.ranges[part_type][1] > part_check
            params = {
              'x' => range.ranges['x'].dup,
              'm' => range.ranges['m'].dup,
              'a' => range.ranges['a'].dup,
              's' => range.ranges['s'].dup,
              'start' => workflow
            }
            params[part_type] = [range.ranges[part_type][0], part_check]
            # puts "New range #{params}"
            parts_ranges << Range.new(params)

            range.ranges[part_type][0] = part_check + 1
            workflow = workflow_rules[rule]
            match = true
          elsif range.ranges[part_type][0] > part_check
            workflow = workflow_rules[rule]
            match = true
          end
        end
      end

      # puts "Updated range: #{range.ranges}"

      if workflow == 'A'
        # puts 'Accepted'
        status = :accepted

        total_rating += range.combinations

        result_ranges << [range, status]

        break
      elsif workflow == 'R'
        # puts 'Rejected'
        status = :rejected

        result_ranges << [range, status]
        break
      end

      break if match
    end
  end

  # puts '---'
end

# Part 2 - 116606738659695
# 256_000_000_000_000 (4000^3)
# 167_409_079_868_000 (test answer)
puts "Part 2: #{total_rating}"

total_accepted = 0
total_rejected = 0

result_ranges.each do |result|
  total_accepted += result[0].combinations if result[1] == :accepted
  total_rejected += result[0].combinations if result[1] == :rejected

  # puts "Range: #{result[0].ranges} is #{result[1]} with a value of #{result[0].combinations}"
end

puts "Total accepted: #{total_accepted}"
puts "Total rejected: #{total_rejected}"
puts "Full total: #{total_accepted + total_rejected}"
