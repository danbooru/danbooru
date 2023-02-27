require "mkmf"

CONFIG["MKMF_VERBOSE"] = "1"

$warnflags = "-Wall -Wextra -Werror -Wno-unused-parameter -Wuninitialized -Wnull-dereference -Wformat=2 -Wformat-overflow=2 -Wstrict-overflow=5"

if ENV["DTEXT_DEBUG"]
  $CXXFLAGS << " -std=c++20 -O2 -g3 -pipe -flto -fno-strict-aliasing -fsanitize=undefined,leak -D_GNU_SOURCE -DDEBUG -D_GLIBCXX_DEBUG -D_GLIBCXX_DEBUG_PEDANTIC -D_GLIBCXX_SANITIZE_VECTOR -D_FORTIFY_SOURCE=2"
else
  $CXXFLAGS << " -std=c++20 -O2 -pipe -flto -fno-strict-aliasing -D_GNU_SOURCE -DNDEBUG"
end

create_makefile "dtext/dtext"
