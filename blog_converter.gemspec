require 'rubygems'
include_files = ["README*", "Rakefile", "{lib,test}/**/*"].map{|glob| Dir[glob]}.flatten

Gem::Specification.new do |s|
  s.name    = "blog_converter"
  s.version = "0.1.0"
  s.author  = "Rei"
  s.email = "chloerei@gmail.com"
  s.platform = Gem::Platform::RUBY
  s.summary = "An tool to convert blog achive file."
  s.files = include_files
  s.require_path = "lib"
  s.test_files = Dir["test/**/*_test.rb"]
  s.has_rdoc = false
  s.add_dependency "nokogiri"
end
