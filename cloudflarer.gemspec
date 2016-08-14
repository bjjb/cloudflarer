# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'cloudflarer/version'

Gem::Specification.new do |spec|
  spec.name          = 'cloudflarer'
  spec.version       = Cloudflarer::VERSION
  spec.authors       = ['JJ Buckley']
  spec.email         = ['jj@bjjb.org']

  spec.summary       = 'A Ruby/Cloudflare CLI/API-client'
  spec.description   = <<-DESC
A Ruby API library for managing your cloudflare domains and settings. Comes
with a simple command-line tool.
DESC
  spec.homepage      = "http://bjjb.gitlab.com/cloudflarer"
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'faraday', '~> 0.9.2'
  spec.add_dependency 'hipsterhash', '~> 0.0.4'
  spec.add_dependency 'ordu', '~> 0.0.1'
  spec.add_development_dependency 'bundler', '~> 1.12'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'minitest', '~> 5.0'
end
