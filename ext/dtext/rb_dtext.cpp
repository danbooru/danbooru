#include "dtext.h"

#include <glib.h>
#include <ruby.h>
#include <ruby/encoding.h>

static VALUE cDText = Qnil;
static VALUE cDTextError = Qnil;

static VALUE c_parse(VALUE self, VALUE input, VALUE base_url, VALUE domain, VALUE f_inline, VALUE f_disable_mentions) {
  if (NIL_P(input)) {
    return Qnil;
  }

  StringValue(input);

  StateMachine* sm = init_machine(RSTRING_PTR(input), RSTRING_LEN(input));
  sm->f_inline = RTEST(f_inline);
  sm->f_mentions = !RTEST(f_disable_mentions);

  if (!NIL_P(base_url)) {
    sm->base_url = StringValueCStr(base_url); // base_url.to_str # raises ArgumentError if base_url contains null bytes.
  }

  if (!NIL_P(domain)) {
    sm->domain = StringValueCStr(domain); // domain.to_str # raises ArgumentError if domain contains null bytes.
  }

  if (!parse_helper(sm)) {
    GError* error = g_error_copy(sm->error);
    free_machine(sm);
    rb_raise(cDTextError, "%s", error->message);
  }

  VALUE ret = rb_utf8_str_new(sm->output->str, sm->output->len);

  free_machine(sm);

  return ret;
}

extern "C" void Init_dtext() {
  cDText = rb_define_class("DText", rb_cObject);
  cDTextError = rb_define_class_under(cDText, "Error", rb_eStandardError);
  rb_define_singleton_method(cDText, "c_parse", c_parse, 5);
}
