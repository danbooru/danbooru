# frozen_string_literal: true

# This file generates a Makefile that builds the extension. This file is run both when the gem is built via `bin/rake
# build` or `bundle install`, and when it's installed via `gem install *.gem`.

require "mkmf"

CONFIG["MKMF_VERBOSE"] = "1"

# XXX Hack to generate dtext.cpp when running with `bin/rake build` or `bundle install`, but not with `gem install *.gem`.
#
# When running under `bin/rake build`, we have to tell it to generate dtext.cpp because it doesn't exist.
# When running under `gem install *.gem`, it will fail if we tell it to build these files because the *.gem doesn't include them.
$srcs = %w[dtext.cpp rb_dtext.cpp] if File.exist?("dtext.cpp.rl")

$warnflags = "-Wall -Wextra -pedantic -Wno-unused-parameter -Wno-implicit-fallthrough -Wno-unused-const-variable"
$CXXFLAGS << " -std=c++20 -O2 -pipe -fno-strict-aliasing #{$warnflags}"

if ENV["DTEXT_DEBUG"]
  $CXXFLAGS << " -g3 -fsanitize=undefined,leak -DDEBUG -D_GLIBCXX_DEBUG -D_GLIBCXX_DEBUG_PEDANTIC -D_GLIBCXX_SANITIZE_VECTOR -D_FORTIFY_SOURCE=3"
end

create_makefile "dtext/dtext"

# XXX Hack to add a rule to the Makefile to generate dtext.cpp from dtext.cpp.rl.
File.write("Makefile", <<~EOS, mode: "a+")
  %.cpp : %.cpp.rl
  \t$(ECHO) translating $(<)
  \t$(Q) ragel -G2 $< -o $@
EOS
