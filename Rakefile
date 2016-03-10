require "rake/extensiontask"
require "rubygems/package_task"

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
	sh "ragel -G2 -C ext/dtext/dtext.rl -o ext/dtext/dtext.c"
end

task test_inline: %w(ragel compile) do
	ruby '-Ilib', '-rdtext', '-e', 'puts DTextRagel.parse("[b]mismatched [u]tags[/b] blah[/u]")'
end

task test: %w(ragel compile) do
	ruby "-Ilib", '-rdtext', "test/dtext_test.rb"
end

task default: :test
