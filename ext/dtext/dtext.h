#ifndef DTEXT_H
#define DTEXT_H

#include <glib.h>
#include <stdbool.h>

#ifndef DEBUG
#undef g_debug
#define g_debug(...)
#endif

#define DTEXT_PARSE_ERROR dtext_parse_error_quark()
#define DTEXT_PARSE_ERROR_FAILED 0
#define DTEXT_PARSE_ERROR_DEPTH_EXCEEDED 1
#define DTEXT_PARSE_ERROR_INVALID_UTF8 2

typedef struct StateMachine {
  size_t top;
  int cs;
  int act;
  const char * p;
  const char * pb;
  const char * pe;
  const char * eof;
  const char * ts;
  const char * te;

  const char * a1;
  const char * a2;
  const char * b1;
  const char * b2;
  bool f_inline;
  bool f_strip;
  bool f_mentions;
  bool list_mode;
  bool header_mode;
  GString * output;
  GArray * stack;
  GQueue * dstack;
  GError * error;
  int list_nest;
  int d;
  int b;
  int quote;
} StateMachine;

StateMachine* init_machine(const char * src, size_t len, bool f_strip, bool f_inline, bool f_mentions);
void free_machine(StateMachine * sm);
gboolean parse_helper(StateMachine* sm);
GQuark dtext_parse_error_quark();

#endif
