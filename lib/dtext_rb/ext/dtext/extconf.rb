require "mkmf"

CONFIG["MKMF_VERBOSE"] = "1"

$warnflags = "-Wall -Wextra -pedantic -Wno-unused-parameter -Wno-implicit-fallthrough -Wno-unused-const-variable"
$CXXFLAGS << " -std=c++20 -O2 -pipe -fno-strict-aliasing #{$warnflags}"

if ENV["DTEXT_DEBUG"]
  $CXXFLAGS << " -g3 -fsanitize=undefined,leak -DDEBUG -D_GLIBCXX_DEBUG -D_GLIBCXX_DEBUG_PEDANTIC -D_GLIBCXX_SANITIZE_VECTOR -D_FORTIFY_SOURCE=3"
end

create_makefile "dtext/dtext"
