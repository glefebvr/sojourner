($:.unshift File.expand_path(File.join( File.dirname(__FILE__), 'lib' ))).uniq!

require 'bundler/gem_tasks'
require 'yard'

task :default=>:test


# Documentation
YARD::Rake::YardocTask.new do |t|
  t.files   = ['lib/**/*.rb', "GIST.rb"]
end
task :doc => :yard


# Test
desc "Run tests"
task :test do
    testfiles=Dir["test/*_test.rb"]
    testfiles.each {|f| puts "\n[Running #{File.basename(f)}...]" ; system "ruby -I./lib #{f}"; puts "\n-----------------\n"}
end

# REPL
desc "Launch with pry"
task :console do
  system "pry", "-r", "./lib/sojourner.rb"
end

# Gem
desc "Build gem"
task :build_gem do
  system "gem build sojourner.gemspec"
end
