# SimpleGraph

A very basic graph gem for Ruby.

Currently only unweighted, undirected graphs are supported.
This means that multiple edges between nodes are ignored, although self loops are allowed.

#### Warning
Note that this is a very early version, and everything about this library is subject to change at any given time without notice. Expect breaking changes.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'simple_graph'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install simple_graph

## Usage

### Quickstart
```ruby
require "simple_graph"

# Creating a new, empty graph
graph = SimpleGraph::Graph.new

## Adding nodes to the graph
a = graph.add_node()
# Returns a graph-unique id for the newly created node
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/vesther/simple_graph.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
