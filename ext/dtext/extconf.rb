require "mkmf"

$CFLAGS << " -std=c99"

pkg_config "glib-2.0"

have_library "glib-2.0"
have_header "glib.h"
have_header "dtext.h"
create_makefile "dtext/dtext"
