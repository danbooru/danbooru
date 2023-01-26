require "mkmf"

CONFIG["MKMF_VERBOSE"] = "1"

$warnflags = "-Wall -Wextra -Werror -Wno-unused-parameter -Wuninitialized -Wnull-dereference -Wformat=2 -Wformat-overflow=2 -Wstrict-overflow=5"
$CXXFLAGS << " -std=c++20 -O2 -pipe -flto -fno-strict-aliasing -D_GNU_SOURCE -DNDEBUG"

create_makefile "dtext/dtext"
