# frozen_string_literal: true

class Race
  attr_accessor :time, :record_distance

  def initialize(time, record_distance)
    @time = time.to_i
    @record_distance = record_distance.to_i
  end
end

class Boat
  attr_accessor :winning_speed

  def initialize
    @winning_speed = []
  end

  def race(race)
    (0..race.time).each do |speed|
      @winning_speed << speed if (race.time - speed) * speed > race.record_distance
    end
  end

  def winning_margin
    @winning_speed.length
  end
end

file_data = File.readlines('day6/real_input.txt')

race_times = file_data[0].squeeze(' ')[/Time: (.*)/, 1].split
race_record_distances = file_data[1].squeeze(' ')[/Distance: (.*)/, 1].split

races = []
(0..race_times.length - 1).each do |id|
  races << Race.new(race_times[id], race_record_distances[id])
end

record_margins = []

races.each do |race|
  # puts "Race time: #{race.time} with record distance: #{race.record_distance}"
  boat = Boat.new
  boat.race(race)

  # puts "For race time #{race.time}, they are #{boat.winning_margin} number of ways to beat the record"
  record_margins << boat.winning_margin
end

# Part 1
product_margin = 1
record_margins.each { |r| product_margin *= r }
puts "Part 1: #{product_margin}"

# Part 2
race_time = file_data[0].squeeze(' ')[/Time: (.*)/, 1].split.join
race_record_distance = file_data[1].squeeze(' ')[/Distance: (.*)/, 1].split.join

race = Race.new(race_time, race_record_distance)
boat = Boat.new
boat.race(race)

puts "Part 2: #{boat.winning_margin}"
