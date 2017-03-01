#ENV["G_MESSAGES_DEBUG"] = "all"

begin
  require "rake/extensiontask"
  require "rubygems/package_task"
  require "bundler"
  require "jeweler"

  Bundler.setup(:default, :development)
rescue LoadError, Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit 1
end

Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
  gem.name = "dtext_rb"
  gem.homepage = "http://github.com/r888888888/dtext_rb"
  gem.license = "MIT"
  gem.summary = %Q{Compiled DText parser}
  gem.description = %Q{Compiled DText parser}
  gem.email = "r888888888@gmail.com"
  gem.authors = ["r888888888"]
  gem.executables = %w(cdtext dtext)
  gem.files = %w(
    bin/cdtext
    bin/dtext
    lib/dtext.rb
    lib/dtext_ruby.rb
    lib/dtext/dtext.so
  )

  Gem::PackageTask.new(gem)
end
Jeweler::RubygemsDotOrgTasks.new

Rake::ExtensionTask.new "dtext" do |ext|
  # this goes here to ensure ragel runs *before* the extension is compiled.
  task :compile => ["ext/dtext/dtext.c", "ext/dtext/rb_dtext.c"]
  ext.lib_dir = "lib/dtext"
end

CLOBBER.include %w(ext/dtext/dtext.c dtext_rb.gemspec)
CLEAN.include %w(lib/dtext bin/cdtext.exe)

task compile: "bin/cdtext.exe"
file "bin/cdtext.exe" => "ext/dtext/dtext.c" do
  flags = "#{ENV["CFLAGS"] || "-ggdb3 -pg -Wall -Wno-unused-const-variable"}"
  libs = "$(pkg-config --cflags --libs glib-2.0)"
  sh "gcc -DCDTEXT -o bin/cdtext.exe ext/dtext/dtext.c #{flags} #{libs}"
end

file "ext/dtext/dtext.c" => Dir["ext/dtext/dtext.{rl,h}", "Rakefile"] do
  sh "ragel -G1 -C ext/dtext/dtext.rl -o ext/dtext/dtext.c"
end

task test_inline_ragel: :compile do
  Bundler.with_clean_env do
    ruby '-Ilib', '-rdtext', '-e', 'puts DTextRagel.parse("hello\r\nworld")'
  end
end

task test: :compile do
  Bundler.with_clean_env do
    ruby "-Ilib", '-rdtext', "test/dtext_test.rb" #, '--name=test_headers_with_ids'
  end
end

task default: :test
