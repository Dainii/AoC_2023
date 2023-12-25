
Node = Struct.new(:id)
Link = Struct.new(:node1, :node2)

nodes = []
links = []

file_data = File.readlines('day25/real_input.txt')

file_data.each do |line|
  line = line.split(':')
  source_node_id = line[0]
  destination_nodes = line[1].split

  unless (source_node = nodes.select { |n| n.id == source_node_id }.first)
    source_node = Node.new(id: source_node_id)
    nodes << source_node
  end

  destination_nodes.each do |node|
    unless (destination_node = nodes.select { |n| n.id == node }.first)
      destination_node = Node.new(id: node)
      nodes << destination_node
    end

    links << Link.new(source_node, destination_node)
  end
end

# puts links

graph = {}

nodes.each do |node|
  graph[node.id] = {}
  links.select { |l| l.node1 == node || l.node2 == node }.each do |link|
    other_node = link.node1 == node ? link.node2 : link.node1
    graph[node.id][other_node.id] = 1
  end
end

# puts graph

require 'ruby-graphviz'

# Create a new graph
g = GraphViz.new( :G, :type => :digraph )

# Create two nodes
graph_nodes = {}
nodes.each { |n| graph_nodes[n.id] = g.add_nodes(n.id) }

# Create an edge between the two nodes
links.each { |l| g.add_edges(graph_nodes[l.node1.id], graph_nodes[l.node2.id]) }

# Generate output image
g.output( :png => "day25/part1.png" )
