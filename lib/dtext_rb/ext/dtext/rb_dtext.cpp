#include "dtext.h"

#include <ruby.h>
#include <ruby/encoding.h>

static VALUE cDText = Qnil;
static VALUE cDTextError = Qnil;

static void validate_dtext(VALUE string) {
  // if input.encoding != Encoding::UTF_8 || input.encoding != Encoding::USASCII
  int encoding = rb_enc_get_index(string);
  if (encoding != rb_usascii_encindex() && encoding != rb_utf8_encindex()) {
    rb_raise(cDTextError, "input must be US-ASCII or UTF-8");
  }

  // if !input.valid_encoding?
  // https://github.com/ruby/ruby/blob/2d9812713171097eb4a3f38e49d9be39d90da2f6/string.c#L10847
  if (rb_enc_str_coderange(string) == ENC_CODERANGE_BROKEN) {
    rb_raise(cDTextError, "input contains invalid UTF-8");
  }

  if (memchr(RSTRING_PTR(string), 0, RSTRING_LEN(string))) {
    rb_raise(cDTextError, "input contains null byte");
  }
}

// Raise TypeError if the argument isn't an array of strings.
static void validate_string_array(VALUE array) {
  Check_Type(array, T_ARRAY);

  for (long i = 0; i < RARRAY_LEN(array); i++) {
    Check_Type(rb_ary_entry(array, i), T_STRING);
  }
}

static std::string_view to_string_view(VALUE string) {
  return { RSTRING_PTR(string), static_cast<size_t>(RSTRING_LEN(string)) };
}

static std::vector<std::string_view> to_string_views(VALUE array) {
  std::vector<std::string_view> strings;

  for (long i = 0; i < RARRAY_LEN(array); i++) {
    strings.push_back(to_string_view(rb_ary_entry(array, i)));
  }

  return strings;
}

// Call a function that uses C++ objects and raise any C++ exceptions it throws as Ruby exceptions.
template <typename F>
static VALUE rescue(F f) {
  char error[256];

  try {
    return f();
  } catch (std::exception& e) {
    snprintf(error, sizeof(error), "%s", e.what());
  }

  rb_raise(cDTextError, "%s", error);
}


static VALUE c_parse(VALUE self, VALUE input, VALUE base_url, VALUE domain, VALUE internal_domains, VALUE emojis, VALUE f_inline, VALUE f_disable_mentions, VALUE f_media_embeds) {
  if (NIL_P(input)) {
    return Qnil;
  }

  // Ruby exceptions use longjmp, which skips C++ destructors and leaks memory if any C++ objects are live. So all
  // arguments are validated before any C++ objects are created.
  StringValue(input);
  validate_dtext(input);
  validate_string_array(internal_domains);
  validate_string_array(emojis);

  if (!NIL_P(base_url)) {
    StringValueCStr(base_url); // base_url.to_str # raises ArgumentError if base_url contains null bytes.
  }

  if (!NIL_P(domain)) {
    StringValueCStr(domain); // domain.to_str # raises ArgumentError if domain contains null bytes.
  }

  return rescue([&] {
    DTextOptions options = {
      .f_inline = RTEST(f_inline),
      .f_mentions = !RTEST(f_disable_mentions),
      .f_media_embeds = RTEST(f_media_embeds),
      .base_url = NIL_P(base_url) ? "" : std::string(to_string_view(base_url)),
      .domain = NIL_P(domain) ? "" : std::string(to_string_view(domain)),
      .internal_domains = to_string_views(internal_domains),
      .emojis = to_string_views(emojis),
    };

    auto [html, _wiki_pages] = StateMachine::parse_dtext(to_string_view(input), options);
    return rb_utf8_str_new(html.c_str(), html.size());
  });
}

static VALUE c_parse_wiki_pages(VALUE self, VALUE input) {
  StringValue(input);
  validate_dtext(input);

  return rescue([&] {
    auto [_html, wiki_pages] = StateMachine::parse_dtext(to_string_view(input), {});

    VALUE rb_wiki_pages = rb_ary_new_capa(wiki_pages.size());
    for (auto wiki_page : wiki_pages) {
      rb_ary_push(rb_wiki_pages, rb_str_new(wiki_page.data(), wiki_page.size()));
    }

    return rb_wiki_pages;
  });
}

extern "C" void Init_dtext() {
  cDText = rb_define_class("DText", rb_cObject);
  cDTextError = rb_define_class_under(cDText, "Error", rb_eStandardError);
  rb_define_singleton_method(cDText, "c_parse", c_parse, 8);
  rb_define_singleton_method(cDText, "c_parse_wiki_pages", c_parse_wiki_pages, 1);
}
