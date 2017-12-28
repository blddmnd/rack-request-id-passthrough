lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rack-request-id-passthrough/version'

Gem::Specification.new do |s|
  s.name          = 'rack-request-id-passthrough'
  s.version       = RackRequestIDPassthrough::VERSION
  s.summary       = 'Middleware for persisting request IDs'
  s.description   = 'Rack middleware which will take incoming headers (such as request id) and ensure that they are passed along to outgoing http requests'
  s.author        = 'Alexander Morozov'
  s.email         = 'alexander.morozov@ring.com'
  s.homepage      = 'https://github.com/EdisonJunior/rack-request-id-passthrough'
  s.files         = `git ls-files`.split("\n")
  s.require_paths = ['lib']

  s.add_development_dependency 'rack'
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'pry'
  s.add_development_dependency 'webmock'
  s.add_development_dependency 'simplecov'
  s.add_development_dependency 'rubocop'
  s.add_development_dependency 'rspec_junit_formatter'
end
