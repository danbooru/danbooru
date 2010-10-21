require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "betamatt-jrails"
    gem.summary = "jRails is a drop-in jQuery replacement for the Rails Prototype/script.aculo.us helpers."
    gem.description = "Using jRails, you can get all of the same default Rails helpers for javascript functionality using the lighter jQuery library."
    gem.email = "aaronchi@gmail.com"
    gem.homepage = "http://github.com/betamatt/jrails"
    gem.authors = ["Aaron Eisenberger", "Patrick Hurley"]
    gem.files =  FileList["[A-Z]*.rb","{bin,generators,javascripts,lib,rails,tasks}/**/*"]
    
    gem.add_dependency 'rails', '~> 2.3.0'
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: sudo gem install jeweler"
end