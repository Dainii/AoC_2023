# frozen_string_literal: true

# From https://github.com/alex-Symbroson/Advent-of-Code/blob/master/2023/12.rb

require 'English'
memo = {}
input = $DEFAULT_INPUT.map(&:split).each { _1[1] = _1[1].split(',').map(&:to_i) }

consume = lambda { |map, nums, c, num = -1, mi = 0, ni = 0|
  key = (mi.hash + num.hash) ^ ni.hash
  return memo[key] if memo[key]
  return 0 if c && map[mi] != c && map[mi] != '?'
  return 0 if ni >= nums.size && c == '#'

  num -= 1 if c == '#'
  return 1 if mi + 1 == map.size && num < 1 && ni + num + 1 == nums.size

  memo[key] = (
      if num.zero?
        consume.call(map, nums, '.', -1, mi + 1, ni + 1)
      elsif num.positive?
        consume.call(map, nums, '#', num, mi + 1, ni)
      else
        (consume.call(map, nums, '#', nums[ni], mi + 1, ni) +
        consume.call(map, nums, '.', -1, mi + 1, ni))
      end)
}

solve = lambda { |f|
  input.map { |(m, n)| [([m] * f).join('?'), n * f] }.sum do |(map, nums)|
    memo.clear
    consume.call(map, nums, '#', nums[0]) + consume.call(map, nums, '.')
  end
}

puts "Part 1: #{solve[1]}"
puts "Part 2: #{solve[5]}"
