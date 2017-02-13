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
  gem.description = %Q{Compield DText parser}
  gem.email = "r888888888@gmail.com"
  gem.authors = ["r888888888"]
end
Jeweler::RubygemsDotOrgTasks.new

Rake::ExtensionTask.new "dtext" do |ext|
	ext.lib_dir = "lib/dtext"
end

s = Gem::Specification.new "dtext", "1.0" do |s|
	s.summary = "dtext parser"
	s.authors = ["r888888888@gmail.com"]
	s.extensions = %w(ext/dtext/extconf.rb)
	s.files = %w(
		Rakefile
		ext/dtext/extconf.rb
		ext/dtext/dtext.c
		lib/dtext.rb
	)
end

Gem::PackageTask.new(s) do
end

task :ragel do
	sh "ragel -G1 -C ext/dtext/dtext.rl -o ext/dtext/dtext.c"
end

task test_forum_posts: %w(ragel compile) do
  ruby '-Ilib', '-rdtext', '-rdtext_ruby', 'test/test_forum_posts.rb'
end

task test_wiki_pages: %w(ragel compile) do
  ruby '-Ilib', '-rdtext', '-rdtext_ruby', 'test/test_wiki_pages.rb'
end

task test_inline_ragel: %w(ragel compile) do
	ruby '-Ilib', '-rdtext', '-e', 'puts DTextRagel.parse("hello\r\nworld")'
end

task test_file_ruby: %w(ragel compile) do
	ruby '-Ilib', '-rdtext_ruby', '-e', "puts DTextRuby.parse(File.read('test/wiki.txt'))"
end

task test_file_ragel: %w(ragel compile) do
	ruby "-Ilib", '-rdtext', "-e", "puts DTextRagel.parse(File.read('test/wiki.txt'))"
end

task test: %w(ragel compile) do
	ruby "-Ilib", '-rdtext', "test/dtext_test.rb" #, '--name=test_headers_with_ids'
end

task default: :test
