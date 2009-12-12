require 'rubygems'
require 'rake'
require File.dirname(__FILE__) + '/lib/correlate'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.version = Correlate::VERSION
    gem.name = "correlate"
    gem.summary = %Q{Help correlate individual documents in a No/Less-SQL environment}
    gem.email = "kenneth.kalmer@gmail.com"
    gem.homepage = "http://github.com/kennethkalmer/correlate"
    gem.authors = ["Kenneth Kalmer"]
    gem.add_dependency "couchrest", ">= 0.33"
    gem.add_development_dependency "rspec", ">= 1.2.9"
    gem.add_development_dependency "yard", ">= 0"
    gem.add_development_dependency "activerecord", ">= 2.3.2"
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

require 'spec/rake/spectask'
Spec::Rake::SpecTask.new(:spec) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.spec_files = FileList['spec/**/*_spec.rb']
end

Spec::Rake::SpecTask.new(:rcov) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rcov = true
end

task :spec => :check_dependencies

task :default => :spec

begin
  require 'yard'
  YARD::Rake::YardocTask.new
rescue LoadError
  task :yardoc do
    abort "YARD is not available. In order to run yardoc, you must: sudo gem install yard"
  end
end
