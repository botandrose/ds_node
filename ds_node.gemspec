# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ds_node/version'

Gem::Specification.new do |spec|
  spec.name          = "ds_node"
  spec.version       = DSNode::VERSION
  spec.authors       = ["Micah Geisel"]
  spec.email         = ["micah@botandrose.com"]

  spec.summary       = %q{Gem for interfacing with Downstream's DSNode}
  spec.description   = %q{Gem for interfacing with Downstream's DSNode}
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "activerecord"
  spec.add_dependency "active_record-json_associations"
  spec.add_dependency "mime-types"

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "database_cleaner"
  spec.add_development_dependency "sqlite3"
end
