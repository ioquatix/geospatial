require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec) do |task|
	task.rspec_opts = ["--require", "simplecov"] if ENV['COVERAGE']
end

task :default => :spec

task :console do
	require 'pry'
	
	$LOAD_PATH.unshift(File.expand_path('lib', __dir__))
	
	require 'geospatial'
	require 'geospatial/hilbert'
	
	Pry.start
end
