require "mkmf"

$warnflags = "-Wall -Wextra -Wno-unused-parameter"
$CFLAGS << " -std=c99 -D_GNU_SOURCE #{ENV["CFLAGS"]}"

pkg_config "glib-2.0"

have_library "glib-2.0"
have_header "glib.h"
have_header "dtext.h"
create_makefile "dtext/dtext"
