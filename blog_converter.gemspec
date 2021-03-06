require 'rubygems'
require './lib/blog_converter/version'

Gem::Specification.new do |s|
  s.name    = "blog_converter"
  s.version = BlogConverter::VERSION
  s.author  = "Rei"
  s.homepage = 'https://github.com/chloerei/blog_converter'
  s.email = "chloerei@gmail.com"
  s.platform = Gem::Platform::RUBY
  s.summary = "An tool to convert blog achive file."
  s.files = Dir["README*", "Rakefile", "MIT-LICENSE", "{lib,test}/**/*", "bin/*"]
  s.require_path = "lib"
	s.executables = ["blog_converter"]
  s.test_files = Dir["test/**/*_test.rb"]
  s.has_rdoc = false
  s.add_dependency "nokogiri"
end
