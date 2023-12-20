# frozen_string_literal: true

class Module
  attr_accessor :destination_modules, :id

  def process(pulses, pulse); end

  def initialize(id, destination_list)
    @destination_modules = []
    @id = id
    destination_list.split(',').each { |d| @destination_modules << d.strip }
    post_initialize
  end

  def post_initialize; end

  def to_s
    "Module: #{self.class.name} id #{@id}, destination modules #{@destination_modules.join(',')}"
  end
end

class FlipFlop < Module
  attr_accessor :status

  def post_initialize
    @status = :off
  end

  def flip_status
    @status = @status == :off ? :on : :off
  end

  def process(pulses, pulse)
    return if pulse.type == :high

    @destination_modules.each do |mod|
      if @status == :off
        pulses << Pulse.new(:high, @id, mod)
      elsif @status == :on
        pulses << Pulse.new(:low, @id, mod)
      end
    end

    flip_status
  end
end

class Conjunction < Module
  attr_accessor :input_modules

  def post_initialize
    @input_modules = {}
  end

  def initialize_inputs(inputs)
    inputs.each do |input|
      @input_modules[input] = :low
    end
  end

  def update_input(input, pulse_type)
    @input_modules[input] = pulse_type
  end

  def all_inputs_high?
    @input_modules.select { |_k, v| v == :low }.count.zero?
  end

  def pulse_type
    all_inputs_high? ? :low : :high
  end

  def process(pulses, pulse)
    update_input(pulse.source, pulse.type)

    @destination_modules.each do |mod|
      pulses << Pulse.new(pulse_type, @id, mod)
    end
  end
end

class Broadcast < Module
  def process(pulses, pulse)
    @destination_modules.each do |mod|
      pulses << Pulse.new(pulse.type, @id, mod)
    end
  end
end

class Button < Module
  def push(pulses)
    @destination_modules.each do |mod|
      pulses << Pulse.new(:low, @id, mod)
    end
  end
end

class Pulse
  attr_accessor :type, :source, :destination

  def initialize(type, source, destination)
    @type = type
    @source = source
    @destination = destination
  end

  def to_s
    "Pulse #{@source} -#{@type}-> #{@destination}"
  end
end

file_data = File.readlines('day20/real_input.txt')

modules = {}

modules['button'] = Button.new('button', 'broadcaster')

file_data.each do |line|
  line = line.split(' -> ')

  if line[0][0] == '%'
    modules["#{line[0][1..-1]}"] = FlipFlop.new(line[0][1..-1], line[1])
  elsif line[0][0] == '&'
    modules["#{line[0][1..-1]}"] = Conjunction.new(line[0][1..-1], line[1])
  elsif line[0] == 'broadcaster'
    modules['broadcaster'] = Broadcast.new('broadcaster', line[1])
  else
    modules["#{line[0][1..-1]}"] = Module.new(line[0][1..-1], line[1])
  end
end

# Need to scan for input of conjunction modules
modules.select { |_k, v| v.instance_of?(Conjunction) }.each_key do |mod|
  inputs = modules.select { |_k, v| v.destination_modules.include?(mod) }.keys
  modules[mod].initialize_inputs(inputs)
end

# All destinations modules
all_destination_modules = []
modules.each_key { |m| all_destination_modules += modules[m].destination_modules }
all_destination_modules.uniq.each do |mod|
  next if modules[mod]

  modules[mod] = Module.new(mod, '')
end

# modules.each_key do |mod|
#   puts modules[mod]
#   puts modules[mod].input_modules if modules[mod].instance_of?(Conjunction)
# end

low_pulses_count = 0
high_pulses_count = 0

1_000.times do |_cycle|
  pulses = []
  next_pulses = []

  modules['button'].push(pulses)
  low_pulses_count += 1

  until pulses.empty?
    # puts pulses
    pulses.each { |p| modules[p.destination].process(next_pulses, p) }

    low_pulses_count += next_pulses.select { |p| p.type == :low }.count
    high_pulses_count += next_pulses.select { |p| p.type == :high }.count

    pulses = next_pulses
    next_pulses = []
  end
end

puts "Low pulse count: #{low_pulses_count}"
puts "High pulse count: #{high_pulses_count}"
puts "Pulses product: #{low_pulses_count * high_pulses_count}"

# Parts 1 - 730797576
puts "Part 1: #{low_pulses_count * high_pulses_count}"
