# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require File.expand_path('../version', __FILE__)
 
Gem::Specification.new do |s|
  s.name        = "portable-hole"
  s.version     = Reamaze::PortableHole::VERSION::STRING
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Lu Wang"]
  s.email       = ["lwang@reamaze.com"]
  s.homepage    = "http://github.com/lunaru/portable-hole"
  s.summary     = "Portable Hole is an extension to ActiveRecord that adds EAV functionality to a model via a polymorphic association with an EAV table."

  s.required_rubygems_version = ">= 1.3.6"
 
  s.files        = Dir.glob("{bin,lib}/**/*") + %w(MIT-LICENSE README.md Gemfile Rakefile)
  s.require_path = 'lib'

  s.add_dependency 'rails', '>= 3.1.0'
end
