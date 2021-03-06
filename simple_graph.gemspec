lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "simple_graph/version"

Gem::Specification.new do |spec|
  spec.name          = "simple_graph"
  spec.version       = SimpleGraph::VERSION
  spec.authors       = ["Kevin Nowald"]
  spec.email         = ["knowald1@gmail.com"]

  spec.summary       = "A simple graph library for Ruby supporting undirected, unweighted graphs."
  # spec.description   = "TODO: Write a longer description or delete this line."
  spec.homepage      = "https://github.com/Vesther/simple_graph"
  spec.license       = "MIT"

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "json", "~> 2.1", ">= 2.1.0"

  spec.add_development_dependency "bundler", "~> 1.15"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
