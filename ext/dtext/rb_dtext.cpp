#include "dtext.h"

#include <ruby.h>
#include <ruby/encoding.h>

static VALUE cDText = Qnil;
static VALUE cDTextError = Qnil;

static VALUE c_parse(VALUE self, VALUE input, VALUE base_url, VALUE domain, VALUE f_inline, VALUE f_disable_mentions, VALUE validate) {
  if (NIL_P(input)) {
    return Qnil;
  }

  StringValue(input);

  DTextOptions options;
  options.f_inline = RTEST(f_inline);
  options.f_mentions = !RTEST(f_disable_mentions);

  if (!NIL_P(base_url)) {
    options.base_url = StringValueCStr(base_url); // base_url.to_str # raises ArgumentError if base_url contains null bytes.
  }

  if (!NIL_P(domain)) {
    options.domain = StringValueCStr(domain); // domain.to_str # raises ArgumentError if domain contains null bytes.
  }

  // if input.encoding != Encoding::UTF_8
  if (RTEST(validate) && rb_enc_get_index(input) != rb_utf8_encindex()) {
    rb_raise(cDTextError, "input must be UTF-8");
  }

  // if !input.valid_encoding?
  // https://github.com/ruby/ruby/blob/2d9812713171097eb4a3f38e49d9be39d90da2f6/string.c#L10847
  if (RTEST(validate) && rb_enc_str_coderange(input) == ENC_CODERANGE_BROKEN) {
    rb_raise(cDTextError, "input contains invalid UTF-8");
  }

  if (memchr(RSTRING_PTR(input), 0, RSTRING_LEN(input))) {
    rb_raise(cDTextError, "input contains null byte");
  }

  try  {
    auto dtext = std::string_view(RSTRING_PTR(input), RSTRING_LEN(input));
    auto result = StateMachine::parse_dtext(dtext, options);

    return rb_utf8_str_new(result.c_str(), result.size());
  } catch (std::exception& e) {
    rb_raise(cDTextError, "%s", e.what());
  }
}

extern "C" void Init_dtext() {
  cDText = rb_define_class("DText", rb_cObject);
  cDTextError = rb_define_class_under(cDText, "Error", rb_eStandardError);
  rb_define_singleton_method(cDText, "c_parse", c_parse, 6);
}
