$LOAD_PATH.unshift(File.expand_path('../lib', __FILE__))


Gem::Specification.new do |spec|
  spec.name          = "lita-ga"
  spec.version       = "0.1.0"
  spec.authors       = ["Ross Geesman"]
  spec.email         = ["rossgeesman@gmail.com"]
  spec.description   = "Lita handler for Google Analytics"
  spec.summary       = "Uses Google API to query Google Analytics"
  spec.homepage      = "http://www.fishisfast.com"
  spec.license       = "none"
  spec.metadata      = { "lita_plugin_type" => "handler" }

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "lita", ">= 4.3"
  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "pry-byebug"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rack-test"
  spec.add_development_dependency "rspec", ">= 3.0.0"
end


