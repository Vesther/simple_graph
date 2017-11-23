require "simple_graph/version"

module SimpleGraph
  class Graph
    class Node
      def initialize(id:, data:)
        @data = data
        @neighbors = []
        @id = id
      end

      def add_neighbor(node)
        @neighbors << node
      end

      attr_reader :neighbors
      attr_reader :data
      attr_reader :id
    end

    # Constructor
    def initialize
      # Our array of internal nodes
      @nodes = []
      # Helper hash lookup table
      @nodes_by_id = {}
      # Tracks the highest used id for autoincrement
      @last_id = 0
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

    # Method to connect 2 nodes
    def connect_nodes(first, second)
      @nodes_by_id[first].add_neighbor(@nodes_by_id[second])
      @nodes_by_id[second].add_neighbor(@nodes_by_id[first])
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

    def load_from_string(str)
      lines = str.lines.map(&:chomp)

      separator_position = lines.index("#")

      nodes = lines[0..separator_position - 1]
      edges = lines[separator_position + 1..-1].map(&:split)

      nodes.each do |node|
        add_node(id: node)
      end

      edges.each do |edge|
        connect_nodes(edge.first, edge.last)
      end
    end

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

      found_paths.map { |found_path| found_path.map(&:id) }
    end

    private

    def next_id
      @last_id += 1 while @nodes_by_id.keys.include?(@last_id + 1)
      @last_id += 1
    end
  end
end
