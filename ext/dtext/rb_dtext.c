#include "dtext.h"

#include <glib.h>
#include <ruby.h>
#include <ruby/encoding.h>

static VALUE mDTextRagel = Qnil;
static VALUE mDTextRagelError = Qnil;

static VALUE c_parse(VALUE self, VALUE input, VALUE f_strip, VALUE f_inline, VALUE f_disable_mentions) {
  if (NIL_P(input)) {
    return Qnil;
  }

  StringValue(input);
  StateMachine* sm = init_machine(RSTRING_PTR(input), RSTRING_LEN(input), RTEST(f_strip), RTEST(f_inline), !RTEST(f_disable_mentions));
  if (!parse_helper(sm)) {
    GError* error = g_error_copy(sm->error);
    free_machine(sm);
    rb_raise(mDTextRagelError, "%s", error->message);
  }

  VALUE ret = rb_utf8_str_new(sm->output->str, sm->output->len);

  free_machine(sm);

  return ret;
}

void Init_dtext() {
  mDTextRagel = rb_define_module("DTextRagel");
  mDTextRagelError = rb_define_class_under(mDTextRagel, "Error", rb_eStandardError);
  rb_define_singleton_method(mDTextRagel, "c_parse", c_parse, 4);
}
