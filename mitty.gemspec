# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'mitty/version'

Gem::Specification.new do |spec|
  spec.name          = 'mitty'
  spec.version       = Mitty::VERSION
  spec.authors       = ['Tim Downey']
  spec.email         = 'tim@downey.io'

  spec.summary       = %q[
                          Mitty is a command line utility that lets you create thumbnails, 
                          resize images, and upload your images to Amazon S3!
                        ]
  spec.description   = %q[
                          Mitty is a CLI that allows you to painlessly process and resize images
                          (using ImageMagick via RMagick) and upload them to an AWS S3 bucket of your
                          choosing.  Mitty currently can generate thumbnails as well as both high and low
                          quality images of varying sizes.
                        ]
  spec.homepage      = 'https://github.com/tcdowney/mitty'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'bin'
  spec.executables   = ['mitty']
  spec.require_paths = ['lib']

  spec.required_ruby_version = '~> 2.1'

  spec.add_dependency 'activesupport', '~> 4.1'
  spec.add_dependency 'aws-sdk', '~> 2.1'
  spec.add_dependency 'rmagick', '~> 2.15'
  spec.add_dependency 'thor', '~> 0.19'

  spec.add_development_dependency 'bundler', '~> 1.10'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'simplecov', '~> 0.10'
end
