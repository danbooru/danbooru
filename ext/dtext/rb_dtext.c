#include "dtext.h"

#include <glib.h>
#include <ruby.h>
#include <ruby/encoding.h>

static VALUE mDTextRagel = Qnil;
static VALUE mDTextRagelError = Qnil;

static VALUE parse(int argc, VALUE * argv, VALUE self) {
  VALUE input;
  VALUE options;
  VALUE opt_inline;
  VALUE opt_strip;
  VALUE opt_mentions;
  VALUE ret;
  rb_encoding * encoding = NULL;
  StateMachine * sm = NULL;
  bool f_strip = false;
  bool f_inline = false;
  bool f_mentions = true;

  if (argc == 0) {
    rb_raise(rb_eArgError, "wrong number of arguments (0 for 1)");
  }

  input = argv[0];

  if (NIL_P(input)) {
    return Qnil;
  }

  if (argc > 1) {
    options = argv[1];

    if (!NIL_P(options)) {
      opt_strip  = rb_hash_aref(options, ID2SYM(rb_intern("strip")));
      if (RTEST(opt_strip)) {
        f_strip = true;
      }

      opt_inline = rb_hash_aref(options, ID2SYM(rb_intern("inline")));
      if (RTEST(opt_inline)) {
        f_inline = true;
      }

      opt_mentions = rb_hash_aref(options, ID2SYM(rb_intern("disable_mentions")));
      if (RTEST(opt_mentions)) {
        f_mentions = false;
      }
    }
  }

  sm = init_machine(RSTRING_PTR(input), RSTRING_LEN(input), f_strip, f_inline, f_mentions);
  if (!parse_helper(sm)) {
    GError* error = g_error_copy(sm->error);
    free_machine(sm);
    rb_raise(mDTextRagelError, "%s", error->message);
  }

  encoding = rb_enc_find("utf-8");
  ret = rb_enc_str_new(sm->output->str, sm->output->len, encoding);

  free_machine(sm);

  return ret;
}

void Init_dtext() {
  mDTextRagel = rb_define_module("DTextRagel");
  mDTextRagelError = rb_define_class_under(mDTextRagel, "Error", rb_eStandardError);
  rb_define_singleton_method(mDTextRagel, "parse", parse, -1);
}
