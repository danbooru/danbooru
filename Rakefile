# frozen_string_literal: true

# ENV["G_MESSAGES_DEBUG"] = "all"

require "bundler/gem_tasks"
require "rake/extensiontask"
require "rake/testtask"

Rake::ExtensionTask.new "dtext" do |ext|
  # this goes here to ensure ragel runs *before* the extension is compiled.
  task :compile => ["ext/dtext/dtext.cpp", "ext/dtext/rb_dtext.cpp"]
  ext.lib_dir = "lib/dtext"
end

CLOBBER.include %w[ext/dtext/dtext.cpp]
CLEAN.include %w[lib/dtext/dtext.so bin/cdtext.exe]

#task compile: "bin/cdtext.exe"
#file "bin/cdtext.exe" => "ext/dtext/dtext.cpp" do
#  flags = "#{ENV["CFLAGS"] || "-std=c++20 -ggdb3 -pg -Wall -Wno-unused-const-variable"}"
#  libs = "$(pkg-config --cflags --libs glib-2.0)"
#  sh "g++ -DCDTEXT -o bin/cdtext.exe ext/dtext/dtext.cpp #{flags} #{libs}"
#end

file "ext/dtext/dtext.cpp" => Dir["ext/dtext/dtext.{cpp.rl,h}", "Rakefile"] do
  sh "ragel -G2 ext/dtext/dtext.cpp.rl -o ext/dtext/dtext.cpp"
end

task test: :compile
Rake::TestTask.new(:test) do |t|
  t.test_files = FileList["test/**/test_*.rb"]
end

task bench: :compile do
  require_relative "test/bench_dtext.rb"
end

task default: :test
