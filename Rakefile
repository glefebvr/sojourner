($:.unshift File.expand_path(File.join( File.dirname(__FILE__), 'lib' ))).uniq!
require 'rake/testtask'
require 'bundler/gem_tasks'
require 'yard'

task :default=>:test


# Documentation
YARD::Rake::YardocTask.new do |t|
  t.files   = ['lib/**/*.rb', "GIST.rb"]
end
task :doc => :yard


# Test
Rake::TestTask.new do |t|
  t.pattern = 'test/*_test.rb'
end

# REPL
desc "Launch with pry"
task :console do
  system "pry", "-r", "./lib/sojourner.rb"
end
