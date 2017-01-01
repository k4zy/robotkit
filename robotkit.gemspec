# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'robotkit/version'

Gem::Specification.new do |spec|
  spec.name          = "robotkit"
  spec.version       = Robotkit::VERSION
  spec.authors       = ["kazuki-yoshida"]
  spec.email         = ["kzk.yshd@gmail.com"]

  spec.summary       = "Android library template generator"
  spec.description   = "You do only type package name."
  spec.homepage      = "https://github.com/kazy1991/robotkit"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency 'thor'

  spec.add_development_dependency "bundler", "~> 1.13"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "pry", "~> 0.10"
end
