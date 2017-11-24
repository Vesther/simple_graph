require "simple_graph/version"
require "JSON"

# Top level namespace for classes provided by this gem
module SimpleGraph
  # A class representing a unweighted, undirected graph
  class Graph
    # A internal class representing a single vertex/node inside a graph
    class Node
      def initialize(id:, data:)
        @data = data
        @neighbors = []
        @id = id
      end

      # Adds a neighbor to the given node
      def add_neighbor(node)
        @neighbors << node
      end

      attr_reader :neighbors
      attr_reader :data
      attr_reader :id
    end

    def initialize
      # Our array of internal nodes
      @nodes = []
      # Helper hash lookup table
      @nodes_by_id = {}
      # Tracks the highest used id for autoincrement
      @last_id = 0
    end

    # Remove all nodes from the graph
    def clear
      initialize
    end

    # Add a new node to the graph
    def add_node(id: nil, data: {})
      id ||= next_id
      node = Graph::Node.new(id: id, data: data)
      @nodes << node
      @nodes_by_id[id] = node
      node
    end

    # Delete a node from the graph
    def delete_node(node)
      # Remove all edges connected with this node
      node.neighbors.each do |neighbor|
        neighbor.neighbors.delete(node)
      end
      # Remove the node itself
      @nodes.delete(node)
    end

    # Retrieve the amount of nodes in the graph
    def node_count
      @nodes.length
    end

    # Retrieve a array of node ids in the graph
    def node_ids
      # The .to_a call is used to return a copy of the array so it cannot be modified from the outside.
      @nodes_by_id.keys.to_a
    end

    # Returns a hash of nodes in the graph mapped to node_id => node_data pairs
    def nodes
      @nodes.map { |node| { node.id => node.data } }
    end

    # Method to connect 2 nodes
    def connect_nodes(first, second)
      @nodes_by_id[first].add_neighbor(@nodes_by_id[second])
      @nodes_by_id[second].add_neighbor(@nodes_by_id[first])
    end

    # Checks whether the graph contains a node with the given ID
    def include?(node_id)
      @nodes_by_id.key?(node_id)
    end

    # Check if two nodes are connected by an edge
    def are_connected?(first, second)
      @nodes_by_id[first].neighbors.include?(@nodes_by_id[second])
    end

    # Retrieve the current graph in the DOT format to be used with Graphviz
    def to_dot_string
      str = "strict graph {\n"

      @nodes.each do |node|
        node.neighbors.each do |neighbor|
          str << "    \"#{node.data[:name]}\" -- \"#{neighbor.data[:name]}\";\n"
        end
      end

      str << "}"
    end

    # Dumps the graph to a JSON string
    def to_json
      temp_hash = {
        nodes: {},
        edges: []
      }

      @nodes.each do |node|
        temp_hash[:nodes][node.id] = node.data
      end

      @nodes.each do |node|
        node.neighbors.each do |neighbor|
          temp_hash[:edges] << [node.id, neighbor.id]
        end
      end

      JSON.dump(temp_hash)
    end

    # Loads the graph from a JSON string
    # Returns the number of Nodes imported
    def load_from_json(str)
      temp_hash = JSON.parse(str)
      nodes = temp_hash["nodes"]
      edges = temp_hash["edges"]

      nodes.each do |node_id, data|
        add_node(id: node_id, data: data)
      end

      edges.each do |node_pair|
        # Ignore duplicate edges for now
        connect_nodes(node_pair.first, node_pair.last) unless are_connected?(node_pair.first, node_pair.last)
      end

      nodes.length
    end

    # Returns all the paths between two nodes as found by breadth-first-search
    def find_paths(source_id, terminal_id)
      found_paths = []

      # Path queue
      paths = Queue.new

      destination = @nodes_by_id[terminal_id]

      # Current Path
      path = [@nodes_by_id[source_id]]

      paths << path

      until paths.empty?
        path = paths.pop

        last = path.last

        found_paths << path if last == destination

        last.neighbors.each do |neighbor|
          next if path.include?(neighbor)
          # Note that this creates a copy of the current path.
          paths << path + [neighbor]
        end
      end

      found_paths.map { |found_path| found_path.map { |item| { item.id => item.data } } }
    end

    private

    # Helper method to autoincrement generated node IDs
    def next_id
      @last_id += 1 while @nodes_by_id.keys.include?(@last_id + 1)
      @last_id += 1
    end
  end
end
