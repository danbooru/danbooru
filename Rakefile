# frozen_string_literal: true

# ENV["G_MESSAGES_DEBUG"] = "all"

require "bundler/gem_tasks"
require "rake/extensiontask"
require "rake/testtask"

Rake::ExtensionTask.new "dtext" do |ext|
  # this goes here to ensure ragel runs *before* the extension is compiled.
  task :compile => ["ext/dtext/dtext.c", "ext/dtext/rb_dtext.c"]
  ext.lib_dir = "lib/dtext"
end

CLOBBER.include %w[ext/dtext/dtext.c]
CLEAN.include %w[lib/dtext bin/cdtext.exe]

task compile: "bin/cdtext.exe"
file "bin/cdtext.exe" => "ext/dtext/dtext.c" do
  flags = "#{ENV["CFLAGS"] || "-ggdb3 -pg -Wall -Wno-unused-const-variable"}"
  libs = "$(pkg-config --cflags --libs glib-2.0)"
  sh "gcc -DCDTEXT -o bin/cdtext.exe ext/dtext/dtext.c #{flags} #{libs}"
end

file "ext/dtext/dtext.c" => Dir["ext/dtext/dtext.{rl,h}", "Rakefile"] do
  sh "ragel -G1 ext/dtext/dtext.rl -o ext/dtext/dtext.c"
end

task test: :compile
Rake::TestTask.new(:test) do |t|
  t.test_files = FileList["test/**/test_*.rb"]
end

task default: :test
