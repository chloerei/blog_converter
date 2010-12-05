require 'rake'
require 'rake/testtask'

$LOAD_PATH << File.join(File.dirname(__FILE__), 'lib')
require 'blog_converter'

desc 'Default: run unit tests.'
task :default => [:test]

desc 'Build gem'
task :build => :clean do
  system "gem build blog_converter.gemspec"
end

task :install => :build do
  system "sudo gem install blog_converter -l"
end

desc 'Test the paperclip plugin.'
Rake::TestTask.new(:test) do |t|
  t.libs << 'lib'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = true
end

desc 'Clean up files'
task :clean do
  Dir.glob("blog_converter-*.gem").each{|f| FileUtils.rm f}
end
