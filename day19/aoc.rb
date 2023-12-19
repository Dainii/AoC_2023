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
