require 'rake'
require 'rake/testtask'

$LOAD_PATH << File.join(File.dirname(__FILE__), 'lib')
require 'blog_converter'

desc 'Default: run unit tests.'
task :default => [:test]

namespace :gem do
  desc 'Build gem'
  task :build => :clean do
    system "gem build blog_converter.gemspec"
  end
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
