
#line 1 "ext/dtext/dtext.cpp.rl"
#include "dtext.h"

#include <stdio.h>
#include <stdint.h>
#include <stdbool.h>
#include <stdlib.h>
#include <string.h>
#include <glib.h>
#include <algorithm>

#ifndef DEBUG
#undef g_debug
#define g_debug(...)
#endif

static const size_t MAX_STACK_DEPTH = 512;


#line 797 "ext/dtext/dtext.cpp.rl"



#line 26 "ext/dtext/dtext.cpp"
static const int dtext_start = 696;
static const int dtext_first_final = 696;
static const int dtext_error = -1;

static const int dtext_en_basic_inline = 715;
static const int dtext_en_inline = 718;
static const int dtext_en_code = 793;
static const int dtext_en_nodtext = 796;
static const int dtext_en_table = 799;
static const int dtext_en_list = 802;
static const int dtext_en_main = 696;


#line 800 "ext/dtext/dtext.cpp.rl"

static inline void dstack_push(StateMachine * sm, element_t element) {
  sm->dstack.push_back(element);
}

static inline element_t dstack_pop(StateMachine * sm) {
  if (sm->dstack.empty()) {
    g_debug("dstack pop empty stack");
    return DSTACK_EMPTY;
  } else {
    auto element = sm->dstack.back();
    sm->dstack.pop_back();
    return element;
  }
}

static inline element_t dstack_peek(const StateMachine * sm) {
  return sm->dstack.empty() ? DSTACK_EMPTY : sm->dstack.back();
}

static inline bool dstack_check(const StateMachine * sm, element_t expected_element) {
  return dstack_peek(sm) == expected_element;
}

// Return true if the given tag is currently open.
static inline bool dstack_is_open(const StateMachine * sm, element_t element) {
  return std::find(sm->dstack.begin(), sm->dstack.end(), element) != sm->dstack.end();
}

static inline bool is_internal_url(StateMachine * sm, GUri* url) {
  if (sm->domain.empty() || url == NULL) {
    return false;
  }

  const char* host = g_uri_get_host(url);
  if (host == NULL) {
    return false;
  }

  return !sm->domain.compare(host);
}

static inline void append(StateMachine * sm, const char * s) {
  sm->output += s;
}

static inline void append(StateMachine * sm, const std::string string) {
  sm->output += string;
}

static inline void append_c_html_escaped(StateMachine * sm, char s) {
  g_debug("write '%c'", s);

  switch (s) {
    case '<':
      sm->output += "&lt;";
      break;

    case '>':
      sm->output += "&gt;";
      break;

    case '&':
      sm->output += "&amp;";
      break;

    case '"':
      sm->output += "&quot;";
      break;

    default:
      sm->output += s;
      break;
  }
}

static inline void append_segment(StateMachine * sm, const char * a, const char * b) {
  sm->output.append(a, b - a + 1);
}

static inline void append_segment_uri_escaped(StateMachine * sm, const char * a, const char * b) {
  g_autofree char* escaped = g_uri_escape_bytes((const guint8 *)a, b - a + 1, NULL);
  sm->output += escaped;
}

static inline void append_segment_html_escaped(StateMachine * sm, const char * a, const char * b) {
  g_autofree gchar * segment = g_markup_escape_text(a, b - a + 1);
  sm->output += segment;
}

static inline void append_url(StateMachine * sm, const char* url) {
  if ((url[0] == '/' || url[0] == '#') && !sm->base_url.empty()) {
    append(sm, sm->base_url);
  }

  append(sm, url);
}

static inline void append_mention(StateMachine * sm, const char* name_start, const char* name_end) {
  append(sm, "<a class=\"dtext-link dtext-user-mention-link\" data-user-name=\"");
  append_segment_html_escaped(sm, name_start, name_end);
  append(sm, "\" href=\"");
  append_url(sm, "/users?name=");
  append_segment_uri_escaped(sm, name_start, name_end);
  append(sm, "\">@");
  append_segment_html_escaped(sm, name_start, name_end);
  append(sm, "</a>");
}

static inline void append_id_link(StateMachine * sm, const char * title, const char * id_name, const char * url) {
  if (url[0] == '/') {
    append(sm, "<a class=\"dtext-link dtext-id-link dtext-");
  } else {
    append(sm, "<a rel=\"external nofollow noreferrer\" class=\"dtext-link dtext-id-link dtext-");
  }

  append(sm, id_name);
  append(sm, "-id-link\" href=\"");
  append_url(sm, url);
  append_segment_uri_escaped(sm, sm->a1, sm->a2 - 1);
  append(sm, "\">");
  append(sm, title);
  append(sm, " #");
  append_segment_html_escaped(sm, sm->a1, sm->a2 - 1);
  append(sm, "</a>");
}

static inline void append_unnamed_url(StateMachine * sm, const char * url_start, const char * url_end) {
  std::string url = std::string(url_start, url_end - url_start + 1);
  g_autoptr(GUri) parsed_url = g_uri_parse(url.c_str(), G_URI_FLAGS_NONE, NULL);

  if (is_internal_url(sm, parsed_url)) {
    append(sm, "<a class=\"dtext-link\" href=\"");
  } else {
    append(sm, "<a rel=\"external nofollow noreferrer\" class=\"dtext-link dtext-external-link\" href=\"");
  }

  append_segment_html_escaped(sm, url_start, url_end);
  append(sm, "\">");
  append_segment_html_escaped(sm, url_start, url_end);
  append(sm, "</a>");
}

static inline bool append_named_url(StateMachine * sm, const char * url_start, const char * url_end, const char * title_start, const char * title_end) {
  int url_len = url_end - url_start + 1;
  auto parsed_title = parse_basic_inline(title_start, title_end - title_start);

  if (parsed_title.empty()) {
    return false;
  }

  // protocol-relative url; treat `//example.com` like `http://example.com`
  if (url_len > 2 && url_start[0] == '/' && url_start[1] == '/') {
    std::string url = "http:" + std::string(url_start, url_len);
    g_autoptr(GUri) parsed_url = g_uri_parse(url.c_str(), G_URI_FLAGS_NONE, NULL);

    if (is_internal_url(sm, parsed_url)) {
      append(sm, "<a class=\"dtext-link\" href=\"http:");
    } else {
      append(sm, "<a rel=\"external nofollow noreferrer\" class=\"dtext-link dtext-external-link dtext-named-external-link\" href=\"http:");
    }
  } else if (url_start[0] == '/' || url_start[0] == '#') {
    append(sm, "<a class=\"dtext-link\" href=\"");

    if (!sm->base_url.empty()) {
      append(sm, sm->base_url);
    }
  } else {
    std::string url = std::string(url_start, url_len);
    g_autoptr(GUri) parsed_url = g_uri_parse(url.c_str(), G_URI_FLAGS_NONE, NULL);

    if (is_internal_url(sm, parsed_url)) {
      append(sm, "<a class=\"dtext-link\" href=\"");
    } else {
      append(sm, "<a rel=\"external nofollow noreferrer\" class=\"dtext-link dtext-external-link dtext-named-external-link\" href=\"");
    }
  }

  append_segment_html_escaped(sm, url_start, url_end);
  append(sm, "\">");
  append(sm, parsed_title);
  append(sm, "</a>");

  return true;
}

static inline void append_wiki_link(StateMachine * sm, const char * tag_segment, const size_t tag_len, const char * title_segment, const size_t title_len, const char * prefix_segment, const size_t prefix_len, const char * suffix_segment, const size_t suffix_len) {
  g_autofree gchar* lowercased_tag = g_utf8_strdown(tag_segment, tag_len);
  g_autoptr(GString) normalized_tag = g_string_new(g_strdelimit(lowercased_tag, " ", '_'));
  g_autoptr(GString) title_string = g_string_new_len(title_segment, title_len);

  if (std::all_of(normalized_tag->str, normalized_tag->str + normalized_tag->len, ::isdigit)) {
    g_string_prepend(normalized_tag, "~");
  }
  
  /* handle pipe trick: [[Kaga (Kantai Collection)|]] -> [[kaga_(kantai_collection)|Kaga]] */
  if (title_string->len == 0) {
    g_string_append_len(title_string, tag_segment, tag_len);

    /* strip qualifier from tag: "kaga (kantai collection)" -> "kaga" */
    g_autoptr(GRegex) qualifier_regex = g_regex_new("[ _]\\([^)]+?\\)$", (GRegexCompileFlags)0, (GRegexMatchFlags)0, NULL);
    g_autofree gchar* stripped_string = g_regex_replace_literal(qualifier_regex, title_string->str, title_string->len, 0, "", (GRegexMatchFlags)0, NULL);

    g_string_assign(title_string, stripped_string);
  }

  g_string_prepend_len(title_string, prefix_segment, prefix_len);
  g_string_append_len(title_string, suffix_segment, suffix_len);

  append(sm, "<a class=\"dtext-link dtext-wiki-link\" href=\"");
  append_url(sm, "/wiki_pages/");
  append_segment_uri_escaped(sm, normalized_tag->str, normalized_tag->str + normalized_tag->len - 1);
  append(sm, "\">");
  append_segment_html_escaped(sm, title_string->str, title_string->str + title_string->len - 1);
  append(sm, "</a>");
}

static inline void append_paged_link(StateMachine * sm, const char * title, const char * tag, const char * href, const char * param) {
  append(sm, tag);
  append_url(sm, href);
  append_segment(sm, sm->a1, sm->a2 - 1);
  append(sm, param);
  append_segment(sm, sm->b1, sm->b2 - 1);
  append(sm, "\">");
  append(sm, title);
  append_segment(sm, sm->a1, sm->a2 - 1);
  append(sm, "/p");
  append_segment(sm, sm->b1, sm->b2 - 1);
  append(sm, "</a>");
}

static inline void append_dmail_key_link(StateMachine * sm) {
  append(sm, "<a class=\"dtext-link dtext-id-link dtext-dmail-id-link\" href=\"");
  append_url(sm, "/dmails/");
  append_segment(sm, sm->a1, sm->a2 - 1);
  append(sm, "?key=");
  append_segment_uri_escaped(sm, sm->b1, sm->b2 - 1);
  append(sm, "\">");
  append(sm, "dmail #");
  append_segment(sm, sm->a1, sm->a2 - 1);
  append(sm, "</a>");
}

static inline void append_block_segment(StateMachine * sm, const char * a, const char * b) {
  if (!sm->f_inline) {
    g_debug("write '%.*s'", (int)(b - a + 1), a);
    sm->output.append(a, b - a + 1);
  }
}

static inline void append_block(StateMachine * sm, const char * s) {
  append_block_segment(sm, s, s + strlen(s) - 1);
}

static void append_closing_p(StateMachine * sm) {
  size_t i = sm->output.size();

  g_debug("append closing p");

  if (i > 4 && !strncmp(sm->output.c_str() + i - 4, "<br>", 4)) {
    g_debug("trim last <br>");
    sm->output.resize(sm->output.size() - 4);
  }

  if (i > 3 && !strncmp(sm->output.c_str() + i - 3, "<p>", 3)) {
    g_debug("trim last <p>");
    sm->output.resize(sm->output.size() - 3);
    return;
  }

  append_block(sm, "</p>");
}

static void append_closing_p_if(StateMachine * sm) {
  if (!dstack_check(sm, BLOCK_P)) {
    return;
  }

  dstack_pop(sm);
  append_closing_p(sm);
}

static void dstack_open_inline(StateMachine * sm, element_t type, const char * html) {
  g_debug("opening inline %s", html);

  dstack_push(sm, type);
  append(sm, html);
}

static void dstack_open_block(StateMachine * sm, element_t type, const char * html) {
  g_debug("opening block %s", html);

  dstack_push(sm, type);
  append_block(sm, html);
}

static void dstack_close_inline(StateMachine * sm, element_t type, const char * close_html) {
  if (dstack_check(sm, type)) {
    g_debug("closing inline %s", close_html);

    dstack_pop(sm);
    append(sm, close_html);
  } else {
    g_debug("out-of-order closing %s", element_names[type]);

    append_segment(sm, sm->ts, sm->te - 1);
  }
}

static bool dstack_close_block(StateMachine * sm, element_t type, const char * close_html) {
  if (dstack_check(sm, type)) {
    g_debug("closing block %s", close_html);

    dstack_pop(sm);
    append_block(sm, close_html);
    return true;
  } else {
    g_debug("out-of-order closing %s", element_names[type]);

    append_block_segment(sm, sm->ts, sm->te - 1);
    return false;
  }
}

// Close the last open tag.
static void dstack_rewind(StateMachine * sm) {
  element_t element = dstack_pop(sm);
  g_debug("dstack rewind %s", element_names[element]);

  switch(element) {
    case BLOCK_P: append_closing_p(sm); break;
    case INLINE_SPOILER: append(sm, "</span>"); break;
    case BLOCK_SPOILER: append_block(sm, "</div>"); break;
    case BLOCK_QUOTE: append_block(sm, "</blockquote>"); break;
    case BLOCK_EXPAND: append_block(sm, "</div></details>"); break;
    case BLOCK_NODTEXT: append_closing_p(sm); break;
    case BLOCK_CODE: append_block(sm, "</pre>"); break;
    case BLOCK_TD: append_block(sm, "</td>"); break;
    case BLOCK_TH: append_block(sm, "</th>"); break;

    case INLINE_NODTEXT: break;
    case INLINE_B: append(sm, "</strong>"); break;
    case INLINE_I: append(sm, "</em>"); break;
    case INLINE_U: append(sm, "</u>"); break;
    case INLINE_S: append(sm, "</s>"); break;
    case INLINE_TN: append(sm, "</span>"); break;
    case INLINE_CODE: append(sm, "</code>"); break;

    case BLOCK_TN: append_closing_p(sm); break;
    case BLOCK_TABLE: append_block(sm, "</table>"); break;
    case BLOCK_THEAD: append_block(sm, "</thead>"); break;
    case BLOCK_TBODY: append_block(sm, "</tbody>"); break;
    case BLOCK_TR: append_block(sm, "</tr>"); break;
    case BLOCK_UL: append_block(sm, "</ul>"); break;
    case BLOCK_LI: append_block(sm, "</li>"); break;
    case BLOCK_H6: append_block(sm, "</h6>"); break;
    case BLOCK_H5: append_block(sm, "</h5>"); break;
    case BLOCK_H4: append_block(sm, "</h4>"); break;
    case BLOCK_H3: append_block(sm, "</h3>"); break;
    case BLOCK_H2: append_block(sm, "</h2>"); break;
    case BLOCK_H1: append_block(sm, "</h1>"); break;

    // Should never happen.
    case INLINE: break;
    case DSTACK_EMPTY: break;
  } 
}

// Close the last open paragraph or list, if there is one.
static void dstack_close_before_block(StateMachine * sm) {
  g_debug("dstack close before block");

  while (dstack_check(sm, BLOCK_P) || dstack_check(sm, BLOCK_LI) || dstack_check(sm, BLOCK_UL)) {
    dstack_rewind(sm);
  }
}

// Close all open tags up to and including the given tag.
static void dstack_close_until(StateMachine * sm, element_t element) {
  while (!sm->dstack.empty() && !dstack_check(sm, element)) {
    dstack_rewind(sm);
  }

  dstack_rewind(sm);
}

// Close all remaining open tags.
static void dstack_close_all(StateMachine * sm) {
  while (!sm->dstack.empty()) {
    dstack_rewind(sm);
  }
}

static void dstack_close_list(StateMachine * sm) {
  while (dstack_check(sm, BLOCK_LI) || dstack_check(sm, BLOCK_UL)) {
    dstack_rewind(sm);
  }

  sm->list_nest = 0;
}

// Returns the preceding non-boundary character if `c` is a boundary character.
// Otherwise, returns `c` if `c` is not a boundary character. Boundary characters
// are trailing punctuation characters that should not be part of the matched text.
static inline const char* find_boundary_c(const char* c) {
  gunichar ch = g_utf8_get_char(g_utf8_prev_char(c + 1));
  int offset = 0;

  // Close punctuation: http://www.fileformat.info/info/unicode/category/Pe/list.htm
  // U+3000 - U+303F: http://www.fileformat.info/info/unicode/block/cjk_symbols_and_punctuation/list.htm
  if (g_unichar_type(ch) == G_UNICODE_CLOSE_PUNCTUATION || (ch >= 0x3000 && ch <= 0x303F)) {
    offset = g_unichar_to_utf8(ch, NULL);
  }

  switch (*c) {
    case ':':
    case ';':
    case '.':
    case ',':
    case '!':
    case '?':
    case ')':
    case ']':
    case '<':
    case '>':
      offset = 1;
  }

  return c - offset;
}

StateMachine init_machine(const char* src, size_t len) {
  StateMachine sm;

  size_t output_length = len;
  if (output_length < (INT16_MAX / 2)) {
    output_length *= 2;
  }

  // Add null bytes to the beginning and end of the string as start and end of string markers.
  sm.input.resize(len + 2, '\0');
  sm.input.replace(1, len, src, len);

  sm.output.reserve(output_length);
  sm.stack.reserve(16);
  sm.dstack.reserve(16);

  sm.p = sm.input.c_str();
  sm.pb = sm.input.c_str();
  sm.pe = sm.input.c_str() + sm.input.size();
  sm.eof = sm.pe;
  sm.ts = NULL;
  sm.te = NULL;
  sm.cs = dtext_start;
  sm.act = 0;
  sm.top = 0;
  sm.a1 = NULL;
  sm.a2 = NULL;
  sm.b1 = NULL;
  sm.b2 = NULL;
  sm.c1 = NULL;
  sm.c2 = NULL;
  sm.d1 = NULL;
  sm.d2 = NULL;
  sm.f_inline = FALSE;
  sm.f_mentions = TRUE;
  sm.list_nest = 0;
  sm.header_mode = false;

  return sm;
}

std::string parse_basic_inline(const char* dtext, const ssize_t length) {
    StateMachine sm = init_machine(dtext, length);
    sm.f_inline = true;
    sm.f_mentions = false;
    sm.cs = dtext_en_basic_inline;

    if (!parse_helper(&sm)) {
      g_debug("parse_basic_inline failed");
    }

    return sm.output;
}

bool parse_helper(StateMachine* sm) {
  const gchar* end = NULL;

  g_debug("parse '%.*s'", (int)(sm->input.size() - 2), sm->input.c_str() + 1);

  if (!g_utf8_validate_len(sm->input.c_str() + 1, sm->input.size() - 2, &end)) {
    sm->error = "invalid utf8 starting at byte " + std::to_string(end - sm->input.c_str() + 1);
    return false;
  }

  
#line 537 "ext/dtext/dtext.cpp"
	{
	( sm->top) = 0;
	( sm->ts) = 0;
	( sm->te) = 0;
	( sm->act) = 0;
	}

#line 1296 "ext/dtext/dtext.cpp.rl"
  
#line 547 "ext/dtext/dtext.cpp"
	{
	if ( ( sm->p) == ( sm->pe) )
		goto _test_eof;
	goto _resume;

_again:
	switch (  sm->cs ) {
		case 696: goto st696;
		case 697: goto st697;
		case 0: goto st0;
		case 1: goto st1;
		case 2: goto st2;
		case 3: goto st3;
		case 4: goto st4;
		case 698: goto st698;
		case 5: goto st5;
		case 6: goto st6;
		case 7: goto st7;
		case 8: goto st8;
		case 699: goto st699;
		case 9: goto st9;
		case 700: goto st700;
		case 701: goto st701;
		case 10: goto st10;
		case 702: goto st702;
		case 703: goto st703;
		case 11: goto st11;
		case 704: goto st704;
		case 12: goto st12;
		case 13: goto st13;
		case 14: goto st14;
		case 15: goto st15;
		case 16: goto st16;
		case 17: goto st17;
		case 18: goto st18;
		case 19: goto st19;
		case 20: goto st20;
		case 21: goto st21;
		case 22: goto st22;
		case 23: goto st23;
		case 24: goto st24;
		case 25: goto st25;
		case 26: goto st26;
		case 27: goto st27;
		case 28: goto st28;
		case 29: goto st29;
		case 30: goto st30;
		case 705: goto st705;
		case 31: goto st31;
		case 32: goto st32;
		case 33: goto st33;
		case 34: goto st34;
		case 706: goto st706;
		case 35: goto st35;
		case 36: goto st36;
		case 37: goto st37;
		case 38: goto st38;
		case 39: goto st39;
		case 40: goto st40;
		case 41: goto st41;
		case 707: goto st707;
		case 42: goto st42;
		case 43: goto st43;
		case 708: goto st708;
		case 44: goto st44;
		case 45: goto st45;
		case 46: goto st46;
		case 47: goto st47;
		case 48: goto st48;
		case 49: goto st49;
		case 50: goto st50;
		case 709: goto st709;
		case 51: goto st51;
		case 52: goto st52;
		case 53: goto st53;
		case 54: goto st54;
		case 55: goto st55;
		case 56: goto st56;
		case 57: goto st57;
		case 710: goto st710;
		case 58: goto st58;
		case 59: goto st59;
		case 60: goto st60;
		case 61: goto st61;
		case 62: goto st62;
		case 63: goto st63;
		case 64: goto st64;
		case 711: goto st711;
		case 65: goto st65;
		case 66: goto st66;
		case 67: goto st67;
		case 712: goto st712;
		case 713: goto st713;
		case 714: goto st714;
		case 68: goto st68;
		case 69: goto st69;
		case 70: goto st70;
		case 71: goto st71;
		case 72: goto st72;
		case 73: goto st73;
		case 74: goto st74;
		case 75: goto st75;
		case 76: goto st76;
		case 77: goto st77;
		case 78: goto st78;
		case 79: goto st79;
		case 80: goto st80;
		case 81: goto st81;
		case 82: goto st82;
		case 83: goto st83;
		case 84: goto st84;
		case 85: goto st85;
		case 86: goto st86;
		case 87: goto st87;
		case 88: goto st88;
		case 89: goto st89;
		case 90: goto st90;
		case 91: goto st91;
		case 92: goto st92;
		case 93: goto st93;
		case 94: goto st94;
		case 95: goto st95;
		case 96: goto st96;
		case 97: goto st97;
		case 98: goto st98;
		case 99: goto st99;
		case 100: goto st100;
		case 101: goto st101;
		case 102: goto st102;
		case 103: goto st103;
		case 104: goto st104;
		case 105: goto st105;
		case 106: goto st106;
		case 107: goto st107;
		case 108: goto st108;
		case 109: goto st109;
		case 110: goto st110;
		case 111: goto st111;
		case 112: goto st112;
		case 113: goto st113;
		case 114: goto st114;
		case 115: goto st115;
		case 715: goto st715;
		case 716: goto st716;
		case 116: goto st116;
		case 117: goto st117;
		case 118: goto st118;
		case 119: goto st119;
		case 120: goto st120;
		case 121: goto st121;
		case 122: goto st122;
		case 123: goto st123;
		case 124: goto st124;
		case 125: goto st125;
		case 126: goto st126;
		case 127: goto st127;
		case 128: goto st128;
		case 129: goto st129;
		case 130: goto st130;
		case 131: goto st131;
		case 132: goto st132;
		case 133: goto st133;
		case 134: goto st134;
		case 717: goto st717;
		case 135: goto st135;
		case 136: goto st136;
		case 137: goto st137;
		case 138: goto st138;
		case 139: goto st139;
		case 140: goto st140;
		case 141: goto st141;
		case 142: goto st142;
		case 143: goto st143;
		case 718: goto st718;
		case 719: goto st719;
		case 144: goto st144;
		case 145: goto st145;
		case 146: goto st146;
		case 147: goto st147;
		case 148: goto st148;
		case 149: goto st149;
		case 720: goto st720;
		case 150: goto st150;
		case 151: goto st151;
		case 152: goto st152;
		case 153: goto st153;
		case 154: goto st154;
		case 721: goto st721;
		case 722: goto st722;
		case 155: goto st155;
		case 156: goto st156;
		case 157: goto st157;
		case 723: goto st723;
		case 724: goto st724;
		case 725: goto st725;
		case 726: goto st726;
		case 158: goto st158;
		case 159: goto st159;
		case 160: goto st160;
		case 727: goto st727;
		case 161: goto st161;
		case 162: goto st162;
		case 163: goto st163;
		case 164: goto st164;
		case 165: goto st165;
		case 166: goto st166;
		case 167: goto st167;
		case 168: goto st168;
		case 169: goto st169;
		case 170: goto st170;
		case 171: goto st171;
		case 172: goto st172;
		case 173: goto st173;
		case 174: goto st174;
		case 175: goto st175;
		case 176: goto st176;
		case 177: goto st177;
		case 178: goto st178;
		case 728: goto st728;
		case 179: goto st179;
		case 180: goto st180;
		case 181: goto st181;
		case 182: goto st182;
		case 183: goto st183;
		case 729: goto st729;
		case 730: goto st730;
		case 184: goto st184;
		case 185: goto st185;
		case 186: goto st186;
		case 731: goto st731;
		case 732: goto st732;
		case 187: goto st187;
		case 733: goto st733;
		case 188: goto st188;
		case 189: goto st189;
		case 190: goto st190;
		case 191: goto st191;
		case 192: goto st192;
		case 193: goto st193;
		case 194: goto st194;
		case 195: goto st195;
		case 196: goto st196;
		case 197: goto st197;
		case 198: goto st198;
		case 734: goto st734;
		case 199: goto st199;
		case 200: goto st200;
		case 201: goto st201;
		case 202: goto st202;
		case 203: goto st203;
		case 204: goto st204;
		case 205: goto st205;
		case 206: goto st206;
		case 207: goto st207;
		case 208: goto st208;
		case 209: goto st209;
		case 210: goto st210;
		case 211: goto st211;
		case 212: goto st212;
		case 213: goto st213;
		case 214: goto st214;
		case 215: goto st215;
		case 216: goto st216;
		case 217: goto st217;
		case 218: goto st218;
		case 219: goto st219;
		case 220: goto st220;
		case 221: goto st221;
		case 222: goto st222;
		case 223: goto st223;
		case 224: goto st224;
		case 225: goto st225;
		case 226: goto st226;
		case 227: goto st227;
		case 228: goto st228;
		case 229: goto st229;
		case 230: goto st230;
		case 231: goto st231;
		case 232: goto st232;
		case 233: goto st233;
		case 234: goto st234;
		case 235: goto st235;
		case 236: goto st236;
		case 237: goto st237;
		case 238: goto st238;
		case 239: goto st239;
		case 240: goto st240;
		case 241: goto st241;
		case 242: goto st242;
		case 243: goto st243;
		case 244: goto st244;
		case 245: goto st245;
		case 246: goto st246;
		case 247: goto st247;
		case 248: goto st248;
		case 249: goto st249;
		case 250: goto st250;
		case 251: goto st251;
		case 252: goto st252;
		case 253: goto st253;
		case 254: goto st254;
		case 255: goto st255;
		case 256: goto st256;
		case 257: goto st257;
		case 258: goto st258;
		case 259: goto st259;
		case 260: goto st260;
		case 261: goto st261;
		case 262: goto st262;
		case 263: goto st263;
		case 264: goto st264;
		case 265: goto st265;
		case 266: goto st266;
		case 267: goto st267;
		case 268: goto st268;
		case 269: goto st269;
		case 270: goto st270;
		case 271: goto st271;
		case 272: goto st272;
		case 273: goto st273;
		case 274: goto st274;
		case 275: goto st275;
		case 276: goto st276;
		case 277: goto st277;
		case 278: goto st278;
		case 279: goto st279;
		case 280: goto st280;
		case 281: goto st281;
		case 282: goto st282;
		case 283: goto st283;
		case 284: goto st284;
		case 285: goto st285;
		case 286: goto st286;
		case 287: goto st287;
		case 288: goto st288;
		case 289: goto st289;
		case 290: goto st290;
		case 291: goto st291;
		case 292: goto st292;
		case 293: goto st293;
		case 294: goto st294;
		case 295: goto st295;
		case 296: goto st296;
		case 297: goto st297;
		case 298: goto st298;
		case 299: goto st299;
		case 300: goto st300;
		case 301: goto st301;
		case 735: goto st735;
		case 736: goto st736;
		case 737: goto st737;
		case 738: goto st738;
		case 302: goto st302;
		case 303: goto st303;
		case 304: goto st304;
		case 305: goto st305;
		case 306: goto st306;
		case 307: goto st307;
		case 739: goto st739;
		case 308: goto st308;
		case 309: goto st309;
		case 310: goto st310;
		case 311: goto st311;
		case 312: goto st312;
		case 313: goto st313;
		case 314: goto st314;
		case 740: goto st740;
		case 315: goto st315;
		case 316: goto st316;
		case 317: goto st317;
		case 318: goto st318;
		case 319: goto st319;
		case 320: goto st320;
		case 321: goto st321;
		case 741: goto st741;
		case 322: goto st322;
		case 323: goto st323;
		case 324: goto st324;
		case 325: goto st325;
		case 326: goto st326;
		case 327: goto st327;
		case 328: goto st328;
		case 329: goto st329;
		case 330: goto st330;
		case 742: goto st742;
		case 743: goto st743;
		case 331: goto st331;
		case 332: goto st332;
		case 333: goto st333;
		case 334: goto st334;
		case 744: goto st744;
		case 335: goto st335;
		case 336: goto st336;
		case 337: goto st337;
		case 338: goto st338;
		case 745: goto st745;
		case 746: goto st746;
		case 339: goto st339;
		case 340: goto st340;
		case 341: goto st341;
		case 342: goto st342;
		case 343: goto st343;
		case 344: goto st344;
		case 345: goto st345;
		case 346: goto st346;
		case 747: goto st747;
		case 347: goto st347;
		case 348: goto st348;
		case 349: goto st349;
		case 350: goto st350;
		case 748: goto st748;
		case 749: goto st749;
		case 351: goto st351;
		case 352: goto st352;
		case 353: goto st353;
		case 354: goto st354;
		case 355: goto st355;
		case 356: goto st356;
		case 357: goto st357;
		case 358: goto st358;
		case 359: goto st359;
		case 360: goto st360;
		case 361: goto st361;
		case 750: goto st750;
		case 362: goto st362;
		case 363: goto st363;
		case 364: goto st364;
		case 365: goto st365;
		case 366: goto st366;
		case 367: goto st367;
		case 751: goto st751;
		case 368: goto st368;
		case 752: goto st752;
		case 753: goto st753;
		case 369: goto st369;
		case 370: goto st370;
		case 371: goto st371;
		case 372: goto st372;
		case 373: goto st373;
		case 374: goto st374;
		case 375: goto st375;
		case 376: goto st376;
		case 377: goto st377;
		case 754: goto st754;
		case 378: goto st378;
		case 379: goto st379;
		case 380: goto st380;
		case 381: goto st381;
		case 382: goto st382;
		case 383: goto st383;
		case 384: goto st384;
		case 385: goto st385;
		case 386: goto st386;
		case 755: goto st755;
		case 387: goto st387;
		case 388: goto st388;
		case 389: goto st389;
		case 390: goto st390;
		case 391: goto st391;
		case 756: goto st756;
		case 392: goto st392;
		case 393: goto st393;
		case 394: goto st394;
		case 395: goto st395;
		case 396: goto st396;
		case 397: goto st397;
		case 757: goto st757;
		case 758: goto st758;
		case 398: goto st398;
		case 399: goto st399;
		case 400: goto st400;
		case 401: goto st401;
		case 402: goto st402;
		case 403: goto st403;
		case 404: goto st404;
		case 405: goto st405;
		case 406: goto st406;
		case 759: goto st759;
		case 760: goto st760;
		case 407: goto st407;
		case 408: goto st408;
		case 409: goto st409;
		case 410: goto st410;
		case 411: goto st411;
		case 412: goto st412;
		case 761: goto st761;
		case 413: goto st413;
		case 762: goto st762;
		case 414: goto st414;
		case 415: goto st415;
		case 416: goto st416;
		case 417: goto st417;
		case 418: goto st418;
		case 419: goto st419;
		case 420: goto st420;
		case 421: goto st421;
		case 422: goto st422;
		case 423: goto st423;
		case 424: goto st424;
		case 425: goto st425;
		case 763: goto st763;
		case 426: goto st426;
		case 427: goto st427;
		case 428: goto st428;
		case 429: goto st429;
		case 430: goto st430;
		case 431: goto st431;
		case 764: goto st764;
		case 765: goto st765;
		case 432: goto st432;
		case 433: goto st433;
		case 434: goto st434;
		case 435: goto st435;
		case 436: goto st436;
		case 437: goto st437;
		case 438: goto st438;
		case 439: goto st439;
		case 440: goto st440;
		case 441: goto st441;
		case 442: goto st442;
		case 766: goto st766;
		case 443: goto st443;
		case 444: goto st444;
		case 445: goto st445;
		case 446: goto st446;
		case 447: goto st447;
		case 448: goto st448;
		case 449: goto st449;
		case 450: goto st450;
		case 767: goto st767;
		case 768: goto st768;
		case 451: goto st451;
		case 452: goto st452;
		case 453: goto st453;
		case 454: goto st454;
		case 455: goto st455;
		case 456: goto st456;
		case 769: goto st769;
		case 457: goto st457;
		case 458: goto st458;
		case 459: goto st459;
		case 460: goto st460;
		case 461: goto st461;
		case 770: goto st770;
		case 771: goto st771;
		case 462: goto st462;
		case 463: goto st463;
		case 464: goto st464;
		case 465: goto st465;
		case 466: goto st466;
		case 467: goto st467;
		case 772: goto st772;
		case 468: goto st468;
		case 469: goto st469;
		case 470: goto st470;
		case 471: goto st471;
		case 472: goto st472;
		case 473: goto st473;
		case 773: goto st773;
		case 474: goto st474;
		case 475: goto st475;
		case 774: goto st774;
		case 476: goto st476;
		case 477: goto st477;
		case 478: goto st478;
		case 479: goto st479;
		case 480: goto st480;
		case 775: goto st775;
		case 481: goto st481;
		case 482: goto st482;
		case 483: goto st483;
		case 484: goto st484;
		case 776: goto st776;
		case 485: goto st485;
		case 486: goto st486;
		case 487: goto st487;
		case 488: goto st488;
		case 489: goto st489;
		case 777: goto st777;
		case 778: goto st778;
		case 490: goto st490;
		case 491: goto st491;
		case 492: goto st492;
		case 493: goto st493;
		case 494: goto st494;
		case 495: goto st495;
		case 496: goto st496;
		case 497: goto st497;
		case 779: goto st779;
		case 498: goto st498;
		case 499: goto st499;
		case 500: goto st500;
		case 501: goto st501;
		case 502: goto st502;
		case 503: goto st503;
		case 780: goto st780;
		case 781: goto st781;
		case 504: goto st504;
		case 505: goto st505;
		case 506: goto st506;
		case 507: goto st507;
		case 508: goto st508;
		case 509: goto st509;
		case 782: goto st782;
		case 510: goto st510;
		case 511: goto st511;
		case 783: goto st783;
		case 512: goto st512;
		case 513: goto st513;
		case 514: goto st514;
		case 515: goto st515;
		case 516: goto st516;
		case 517: goto st517;
		case 518: goto st518;
		case 519: goto st519;
		case 784: goto st784;
		case 785: goto st785;
		case 520: goto st520;
		case 521: goto st521;
		case 522: goto st522;
		case 523: goto st523;
		case 524: goto st524;
		case 786: goto st786;
		case 787: goto st787;
		case 525: goto st525;
		case 526: goto st526;
		case 527: goto st527;
		case 528: goto st528;
		case 529: goto st529;
		case 788: goto st788;
		case 789: goto st789;
		case 530: goto st530;
		case 531: goto st531;
		case 532: goto st532;
		case 533: goto st533;
		case 534: goto st534;
		case 535: goto st535;
		case 536: goto st536;
		case 537: goto st537;
		case 790: goto st790;
		case 791: goto st791;
		case 538: goto st538;
		case 539: goto st539;
		case 540: goto st540;
		case 541: goto st541;
		case 542: goto st542;
		case 543: goto st543;
		case 544: goto st544;
		case 545: goto st545;
		case 546: goto st546;
		case 547: goto st547;
		case 548: goto st548;
		case 549: goto st549;
		case 550: goto st550;
		case 551: goto st551;
		case 552: goto st552;
		case 553: goto st553;
		case 554: goto st554;
		case 555: goto st555;
		case 556: goto st556;
		case 557: goto st557;
		case 558: goto st558;
		case 559: goto st559;
		case 560: goto st560;
		case 561: goto st561;
		case 562: goto st562;
		case 563: goto st563;
		case 564: goto st564;
		case 565: goto st565;
		case 566: goto st566;
		case 567: goto st567;
		case 568: goto st568;
		case 569: goto st569;
		case 570: goto st570;
		case 571: goto st571;
		case 572: goto st572;
		case 573: goto st573;
		case 574: goto st574;
		case 575: goto st575;
		case 576: goto st576;
		case 577: goto st577;
		case 578: goto st578;
		case 579: goto st579;
		case 580: goto st580;
		case 581: goto st581;
		case 582: goto st582;
		case 583: goto st583;
		case 584: goto st584;
		case 585: goto st585;
		case 586: goto st586;
		case 587: goto st587;
		case 588: goto st588;
		case 589: goto st589;
		case 590: goto st590;
		case 591: goto st591;
		case 592: goto st592;
		case 593: goto st593;
		case 594: goto st594;
		case 595: goto st595;
		case 596: goto st596;
		case 597: goto st597;
		case 598: goto st598;
		case 599: goto st599;
		case 600: goto st600;
		case 601: goto st601;
		case 602: goto st602;
		case 603: goto st603;
		case 604: goto st604;
		case 605: goto st605;
		case 606: goto st606;
		case 607: goto st607;
		case 608: goto st608;
		case 609: goto st609;
		case 610: goto st610;
		case 611: goto st611;
		case 792: goto st792;
		case 612: goto st612;
		case 613: goto st613;
		case 614: goto st614;
		case 793: goto st793;
		case 794: goto st794;
		case 615: goto st615;
		case 616: goto st616;
		case 617: goto st617;
		case 618: goto st618;
		case 619: goto st619;
		case 795: goto st795;
		case 620: goto st620;
		case 621: goto st621;
		case 622: goto st622;
		case 623: goto st623;
		case 624: goto st624;
		case 796: goto st796;
		case 797: goto st797;
		case 625: goto st625;
		case 626: goto st626;
		case 627: goto st627;
		case 628: goto st628;
		case 629: goto st629;
		case 630: goto st630;
		case 631: goto st631;
		case 632: goto st632;
		case 798: goto st798;
		case 633: goto st633;
		case 634: goto st634;
		case 635: goto st635;
		case 636: goto st636;
		case 637: goto st637;
		case 638: goto st638;
		case 639: goto st639;
		case 640: goto st640;
		case 799: goto st799;
		case 800: goto st800;
		case 641: goto st641;
		case 642: goto st642;
		case 643: goto st643;
		case 644: goto st644;
		case 645: goto st645;
		case 646: goto st646;
		case 647: goto st647;
		case 648: goto st648;
		case 649: goto st649;
		case 650: goto st650;
		case 651: goto st651;
		case 652: goto st652;
		case 653: goto st653;
		case 654: goto st654;
		case 655: goto st655;
		case 656: goto st656;
		case 657: goto st657;
		case 658: goto st658;
		case 659: goto st659;
		case 660: goto st660;
		case 661: goto st661;
		case 662: goto st662;
		case 663: goto st663;
		case 664: goto st664;
		case 665: goto st665;
		case 666: goto st666;
		case 801: goto st801;
		case 667: goto st667;
		case 668: goto st668;
		case 669: goto st669;
		case 670: goto st670;
		case 671: goto st671;
		case 672: goto st672;
		case 673: goto st673;
		case 674: goto st674;
		case 675: goto st675;
		case 676: goto st676;
		case 677: goto st677;
		case 678: goto st678;
		case 679: goto st679;
		case 680: goto st680;
		case 681: goto st681;
		case 682: goto st682;
		case 683: goto st683;
		case 684: goto st684;
		case 685: goto st685;
		case 686: goto st686;
		case 687: goto st687;
		case 688: goto st688;
		case 689: goto st689;
		case 690: goto st690;
		case 691: goto st691;
		case 692: goto st692;
		case 802: goto st802;
		case 803: goto st803;
		case 693: goto st693;
		case 804: goto st804;
		case 805: goto st805;
		case 694: goto st694;
		case 806: goto st806;
		case 807: goto st807;
		case 695: goto st695;
	default: break;
	}

	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof;
_resume:
	switch (  sm->cs )
	{
tr0:
#line 785 "ext/dtext/dtext.cpp.rl"
	{{( sm->p) = ((( sm->te)))-1;}{
    g_debug("block char");
    ( sm->p)--;

    if (sm->dstack.empty() || dstack_check(sm, BLOCK_QUOTE) || dstack_check(sm, BLOCK_SPOILER) || dstack_check(sm, BLOCK_EXPAND)) {
      dstack_open_block(sm, BLOCK_P, "<p>");
    }

    {
  size_t len = sm->stack.size();

  if (len > MAX_STACK_DEPTH) {
    sm->error = "too many nested elements";
    {( sm->p)++;  sm->cs = 0; goto _out;}
  }

  if (sm->top >= len) {
    g_debug("growing sm->stack %zi", len + 16);
    sm->stack.resize(len + 16, 0);
  }
{( (sm->stack.data()))[( sm->top)++] = 696;goto st718;}}
  }}
	goto st696;
tr9:
#line 1 "NONE"
	{	switch( ( sm->act) ) {
	case 116:
	{{( sm->p) = ((( sm->te)))-1;}
    g_debug("write '<hr>' (pos: %ld)", sm->ts - sm->pb);
    append(sm, "<hr>");
  }
	break;
	case 118:
	{{( sm->p) = ((( sm->te)))-1;}
    g_debug("block newline2");

    if (sm->header_mode) {
      sm->header_mode = false;
      dstack_rewind(sm);
    } else if (sm->list_nest) {
      dstack_close_list(sm);
    } else {
      dstack_close_before_block(sm);
    }
  }
	break;
	case 119:
	{{( sm->p) = ((( sm->te)))-1;}
    g_debug("block newline");
  }
	break;
	case 121:
	{{( sm->p) = ((( sm->te)))-1;}
    g_debug("block char");
    ( sm->p)--;

    if (sm->dstack.empty() || dstack_check(sm, BLOCK_QUOTE) || dstack_check(sm, BLOCK_SPOILER) || dstack_check(sm, BLOCK_EXPAND)) {
      dstack_open_block(sm, BLOCK_P, "<p>");
    }

    {
  size_t len = sm->stack.size();

  if (len > MAX_STACK_DEPTH) {
    sm->error = "too many nested elements";
    {( sm->p)++;  sm->cs = 0; goto _out;}
  }

  if (sm->top >= len) {
    g_debug("growing sm->stack %zi", len + 16);
    sm->stack.resize(len + 16, 0);
  }
{( (sm->stack.data()))[( sm->top)++] = 696;goto st718;}}
  }
	break;
	}
	}
	goto st696;
tr24:
#line 705 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{
    g_debug("block [/spoiler]");
    dstack_close_before_block(sm);
    if (dstack_check(sm, BLOCK_SPOILER)) {
      g_debug("  rewind");
      dstack_rewind(sm);
    }
  }}
	goto st696;
tr71:
#line 741 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_close_before_block(sm);
    dstack_open_block(sm, BLOCK_TABLE, "<table class=\"striped\">");
    {
  size_t len = sm->stack.size();

  if (len > MAX_STACK_DEPTH) {
    sm->error = "too many nested elements";
    {( sm->p)++;  sm->cs = 0; goto _out;}
  }

  if (sm->top >= len) {
    g_debug("growing sm->stack %zi", len + 16);
    sm->stack.resize(len + 16, 0);
  }
{( (sm->stack.data()))[( sm->top)++] = 696;goto st799;}}
  }}
	goto st696;
tr72:
#line 747 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_open_block(sm, BLOCK_TN, "<p class=\"tn\">");
    {
  size_t len = sm->stack.size();

  if (len > MAX_STACK_DEPTH) {
    sm->error = "too many nested elements";
    {( sm->p)++;  sm->cs = 0; goto _out;}
  }

  if (sm->top >= len) {
    g_debug("growing sm->stack %zi", len + 16);
    sm->stack.resize(len + 16, 0);
  }
{( (sm->stack.data()))[( sm->top)++] = 696;goto st718;}}
  }}
	goto st696;
tr740:
#line 785 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{
    g_debug("block char");
    ( sm->p)--;

    if (sm->dstack.empty() || dstack_check(sm, BLOCK_QUOTE) || dstack_check(sm, BLOCK_SPOILER) || dstack_check(sm, BLOCK_EXPAND)) {
      dstack_open_block(sm, BLOCK_P, "<p>");
    }

    {
  size_t len = sm->stack.size();

  if (len > MAX_STACK_DEPTH) {
    sm->error = "too many nested elements";
    {( sm->p)++;  sm->cs = 0; goto _out;}
  }

  if (sm->top >= len) {
    g_debug("growing sm->stack %zi", len + 16);
    sm->stack.resize(len + 16, 0);
  }
{( (sm->stack.data()))[( sm->top)++] = 696;goto st718;}}
  }}
	goto st696;
tr741:
#line 783 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;}
	goto st696;
tr749:
#line 785 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    g_debug("block char");
    ( sm->p)--;

    if (sm->dstack.empty() || dstack_check(sm, BLOCK_QUOTE) || dstack_check(sm, BLOCK_SPOILER) || dstack_check(sm, BLOCK_EXPAND)) {
      dstack_open_block(sm, BLOCK_P, "<p>");
    }

    {
  size_t len = sm->stack.size();

  if (len > MAX_STACK_DEPTH) {
    sm->error = "too many nested elements";
    {( sm->p)++;  sm->cs = 0; goto _out;}
  }

  if (sm->top >= len) {
    g_debug("growing sm->stack %zi", len + 16);
    sm->stack.resize(len + 16, 0);
  }
{( (sm->stack.data()))[( sm->top)++] = 696;goto st718;}}
  }}
	goto st696;
tr750:
#line 752 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    g_debug("write '<hr>' (pos: %ld)", sm->ts - sm->pb);
    append(sm, "<hr>");
  }}
	goto st696;
tr752:
#line 57 "ext/dtext/dtext.cpp.rl"
	{
  sm->b2 = sm->p;
}
#line 757 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    g_debug("block list");
    g_debug("  call list");
    sm->list_nest = 0;
    append_closing_p_if(sm);
    {( sm->p) = (( sm->ts))-1;}
    {
  size_t len = sm->stack.size();

  if (len > MAX_STACK_DEPTH) {
    sm->error = "too many nested elements";
    {( sm->p)++;  sm->cs = 0; goto _out;}
  }

  if (sm->top >= len) {
    g_debug("growing sm->stack %zi", len + 16);
    sm->stack.resize(len + 16, 0);
  }
{( (sm->stack.data()))[( sm->top)++] = 696;goto st802;}}
  }}
	goto st696;
tr761:
#line 695 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    dstack_close_before_block(sm);
    dstack_open_block(sm, BLOCK_QUOTE, "<blockquote>");
  }}
	goto st696;
tr762:
#line 714 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    dstack_close_before_block(sm);
    dstack_open_block(sm, BLOCK_CODE, "<pre>");
    {
  size_t len = sm->stack.size();

  if (len > MAX_STACK_DEPTH) {
    sm->error = "too many nested elements";
    {( sm->p)++;  sm->cs = 0; goto _out;}
  }

  if (sm->top >= len) {
    g_debug("growing sm->stack %zi", len + 16);
    sm->stack.resize(len + 16, 0);
  }
{( (sm->stack.data()))[( sm->top)++] = 696;goto st793;}}
  }}
	goto st696;
tr763:
#line 726 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    g_debug("block [expand=]");
    dstack_close_before_block(sm);
    dstack_open_block(sm, BLOCK_EXPAND, "<details>");
    append(sm, "<summary>");
    append_segment_html_escaped(sm, sm->a1, sm->a2 - 1);
    append(sm, "</summary><div>");
  }}
	goto st696;
tr765:
#line 720 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    dstack_close_before_block(sm);
    dstack_open_block(sm, BLOCK_EXPAND, "<details>");
    append(sm, "<summary>Show</summary><div>");
  }}
	goto st696;
tr766:
#line 735 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    dstack_close_before_block(sm);
    dstack_open_block(sm, BLOCK_NODTEXT, "<p>");
    {
  size_t len = sm->stack.size();

  if (len > MAX_STACK_DEPTH) {
    sm->error = "too many nested elements";
    {( sm->p)++;  sm->cs = 0; goto _out;}
  }

  if (sm->top >= len) {
    g_debug("growing sm->stack %zi", len + 16);
    sm->stack.resize(len + 16, 0);
  }
{( (sm->stack.data()))[( sm->top)++] = 696;goto st796;}}
  }}
	goto st696;
tr767:
#line 700 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    dstack_close_before_block(sm);
    dstack_open_block(sm, BLOCK_SPOILER, "<div class=\"spoiler\">");
  }}
	goto st696;
tr769:
#line 596 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    char header = *sm->a1;
    std::string id_name = "dtext-" + std::string(sm->b1, sm->b2 - sm->b1);

    if (sm->f_inline) {
      header = '6';
    }

    switch (header) {
      case '1':
        dstack_push(sm, BLOCK_H1);
        append_block(sm, "<h1 id=\"");
        append_block(sm, id_name.c_str());
        append_block(sm, "\">");
        break;

      case '2':
        dstack_push(sm, BLOCK_H2);
        append_block(sm, "<h2 id=\"");
        append_block(sm, id_name.c_str());
        append_block(sm, "\">");
        break;

      case '3':
        dstack_push(sm, BLOCK_H3);
        append_block(sm, "<h3 id=\"");
        append_block(sm, id_name.c_str());
        append_block(sm, "\">");
        break;

      case '4':
        dstack_push(sm, BLOCK_H4);
        append_block(sm, "<h4 id=\"");
        append_block(sm, id_name.c_str());
        append_block(sm, "\">");
        break;

      case '5':
        dstack_push(sm, BLOCK_H5);
        append_block(sm, "<h5 id=\"");
        append_block(sm, id_name.c_str());
        append_block(sm, "\">");
        break;

      case '6':
        dstack_push(sm, BLOCK_H6);
        append_block(sm, "<h6 id=\"");
        append_block(sm, id_name.c_str());
        append_block(sm, "\">");
        break;
    }

    sm->header_mode = true;
    {
  size_t len = sm->stack.size();

  if (len > MAX_STACK_DEPTH) {
    sm->error = "too many nested elements";
    {( sm->p)++;  sm->cs = 0; goto _out;}
  }

  if (sm->top >= len) {
    g_debug("growing sm->stack %zi", len + 16);
    sm->stack.resize(len + 16, 0);
  }
{( (sm->stack.data()))[( sm->top)++] = 696;goto st718;}}
  }}
	goto st696;
tr771:
#line 652 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    char header = *sm->a1;

    if (sm->f_inline) {
      header = '6';
    }

    switch (header) {
      case '1':
        dstack_push(sm, BLOCK_H1);
        append_block(sm, "<h1>");
        break;

      case '2':
        dstack_push(sm, BLOCK_H2);
        append_block(sm, "<h2>");
        break;

      case '3':
        dstack_push(sm, BLOCK_H3);
        append_block(sm, "<h3>");
        break;

      case '4':
        dstack_push(sm, BLOCK_H4);
        append_block(sm, "<h4>");
        break;

      case '5':
        dstack_push(sm, BLOCK_H5);
        append_block(sm, "<h5>");
        break;

      case '6':
        dstack_push(sm, BLOCK_H6);
        append_block(sm, "<h6>");
        break;
    }

    sm->header_mode = true;
    {
  size_t len = sm->stack.size();

  if (len > MAX_STACK_DEPTH) {
    sm->error = "too many nested elements";
    {( sm->p)++;  sm->cs = 0; goto _out;}
  }

  if (sm->top >= len) {
    g_debug("growing sm->stack %zi", len + 16);
    sm->stack.resize(len + 16, 0);
  }
{( (sm->stack.data()))[( sm->top)++] = 696;goto st718;}}
  }}
	goto st696;
st696:
#line 1 "NONE"
	{( sm->ts) = 0;}
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof696;
case 696:
#line 1 "NONE"
	{( sm->ts) = ( sm->p);}
#line 1797 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr741;
		case 9: goto tr742;
		case 10: goto tr743;
		case 13: goto st700;
		case 32: goto tr742;
		case 42: goto tr745;
		case 60: goto tr746;
		case 72: goto tr747;
		case 91: goto tr748;
		case 104: goto tr747;
	}
	goto tr740;
tr742:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 785 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 121;}
	goto st697;
st697:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof697;
case 697:
#line 1821 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto st0;
		case 32: goto st0;
		case 60: goto st1;
		case 91: goto st6;
	}
	goto tr749;
st0:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof0;
case 0:
	switch( (*( sm->p)) ) {
		case 9: goto st0;
		case 32: goto st0;
		case 60: goto st1;
		case 91: goto st6;
	}
	goto tr0;
st1:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1;
case 1:
	switch( (*( sm->p)) ) {
		case 72: goto st2;
		case 104: goto st2;
	}
	goto tr0;
st2:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof2;
case 2:
	switch( (*( sm->p)) ) {
		case 82: goto st3;
		case 114: goto st3;
	}
	goto tr0;
st3:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof3;
case 3:
	if ( (*( sm->p)) == 62 )
		goto st4;
	goto tr0;
st4:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof4;
case 4:
	switch( (*( sm->p)) ) {
		case 0: goto tr7;
		case 9: goto st4;
		case 10: goto tr7;
		case 13: goto st5;
		case 32: goto st4;
	}
	goto tr0;
tr7:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 752 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 116;}
	goto st698;
st698:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof698;
case 698:
#line 1887 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr7;
		case 10: goto tr7;
		case 13: goto st5;
	}
	goto tr750;
st5:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof5;
case 5:
	if ( (*( sm->p)) == 10 )
		goto tr7;
	goto tr9;
st6:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof6;
case 6:
	switch( (*( sm->p)) ) {
		case 72: goto st7;
		case 104: goto st7;
	}
	goto tr0;
st7:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof7;
case 7:
	switch( (*( sm->p)) ) {
		case 82: goto st8;
		case 114: goto st8;
	}
	goto tr0;
st8:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof8;
case 8:
	if ( (*( sm->p)) == 93 )
		goto st4;
	goto tr0;
tr12:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 766 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 118;}
	goto st699;
tr743:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 779 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 119;}
	goto st699;
st699:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof699;
case 699:
#line 1942 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 10: goto tr12;
		case 13: goto st9;
	}
	goto tr9;
st9:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof9;
case 9:
	if ( (*( sm->p)) == 10 )
		goto tr12;
	goto tr9;
st700:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof700;
case 700:
	if ( (*( sm->p)) == 10 )
		goto tr743;
	goto tr749;
tr745:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 45 "ext/dtext/dtext.cpp.rl"
	{
  sm->a1 = sm->p;
}
	goto st701;
st701:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof701;
case 701:
#line 1974 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto tr15;
		case 32: goto tr15;
		case 42: goto st11;
	}
	goto tr749;
tr15:
#line 49 "ext/dtext/dtext.cpp.rl"
	{
  sm->a2 = sm->p;
}
	goto st10;
st10:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof10;
case 10:
#line 1991 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto tr14;
		case 10: goto tr0;
		case 13: goto tr0;
		case 32: goto tr14;
	}
	goto tr13;
tr13:
#line 53 "ext/dtext/dtext.cpp.rl"
	{
  sm->b1 = sm->p;
}
	goto st702;
st702:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof702;
case 702:
#line 2009 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 10: goto tr752;
		case 13: goto tr752;
	}
	goto st702;
tr14:
#line 53 "ext/dtext/dtext.cpp.rl"
	{
  sm->b1 = sm->p;
}
	goto st703;
st703:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof703;
case 703:
#line 2025 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto tr14;
		case 10: goto tr752;
		case 13: goto tr752;
		case 32: goto tr14;
	}
	goto tr13;
st11:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof11;
case 11:
	switch( (*( sm->p)) ) {
		case 9: goto tr15;
		case 32: goto tr15;
		case 42: goto st11;
	}
	goto tr0;
tr746:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 785 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 121;}
	goto st704;
st704:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof704;
case 704:
#line 2053 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 47: goto st12;
		case 66: goto st21;
		case 67: goto st31;
		case 69: goto st35;
		case 72: goto st2;
		case 78: goto st44;
		case 81: goto st26;
		case 83: goto st51;
		case 84: goto st59;
		case 98: goto st21;
		case 99: goto st31;
		case 101: goto st35;
		case 104: goto st2;
		case 110: goto st44;
		case 113: goto st26;
		case 115: goto st51;
		case 116: goto st59;
	}
	goto tr749;
st12:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof12;
case 12:
	switch( (*( sm->p)) ) {
		case 83: goto st13;
		case 115: goto st13;
	}
	goto tr0;
st13:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof13;
case 13:
	switch( (*( sm->p)) ) {
		case 80: goto st14;
		case 112: goto st14;
	}
	goto tr0;
st14:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof14;
case 14:
	switch( (*( sm->p)) ) {
		case 79: goto st15;
		case 111: goto st15;
	}
	goto tr0;
st15:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof15;
case 15:
	switch( (*( sm->p)) ) {
		case 73: goto st16;
		case 105: goto st16;
	}
	goto tr0;
st16:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof16;
case 16:
	switch( (*( sm->p)) ) {
		case 76: goto st17;
		case 108: goto st17;
	}
	goto tr0;
st17:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof17;
case 17:
	switch( (*( sm->p)) ) {
		case 69: goto st18;
		case 101: goto st18;
	}
	goto tr0;
st18:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof18;
case 18:
	switch( (*( sm->p)) ) {
		case 82: goto st19;
		case 114: goto st19;
	}
	goto tr0;
st19:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof19;
case 19:
	switch( (*( sm->p)) ) {
		case 62: goto tr24;
		case 83: goto st20;
		case 115: goto st20;
	}
	goto tr0;
st20:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof20;
case 20:
	if ( (*( sm->p)) == 62 )
		goto tr24;
	goto tr0;
st21:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof21;
case 21:
	switch( (*( sm->p)) ) {
		case 76: goto st22;
		case 108: goto st22;
	}
	goto tr0;
st22:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof22;
case 22:
	switch( (*( sm->p)) ) {
		case 79: goto st23;
		case 111: goto st23;
	}
	goto tr0;
st23:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof23;
case 23:
	switch( (*( sm->p)) ) {
		case 67: goto st24;
		case 99: goto st24;
	}
	goto tr0;
st24:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof24;
case 24:
	switch( (*( sm->p)) ) {
		case 75: goto st25;
		case 107: goto st25;
	}
	goto tr0;
st25:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof25;
case 25:
	switch( (*( sm->p)) ) {
		case 81: goto st26;
		case 113: goto st26;
	}
	goto tr0;
st26:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof26;
case 26:
	switch( (*( sm->p)) ) {
		case 85: goto st27;
		case 117: goto st27;
	}
	goto tr0;
st27:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof27;
case 27:
	switch( (*( sm->p)) ) {
		case 79: goto st28;
		case 111: goto st28;
	}
	goto tr0;
st28:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof28;
case 28:
	switch( (*( sm->p)) ) {
		case 84: goto st29;
		case 116: goto st29;
	}
	goto tr0;
st29:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof29;
case 29:
	switch( (*( sm->p)) ) {
		case 69: goto st30;
		case 101: goto st30;
	}
	goto tr0;
st30:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof30;
case 30:
	if ( (*( sm->p)) == 62 )
		goto st705;
	goto tr0;
st705:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof705;
case 705:
	if ( (*( sm->p)) == 32 )
		goto st705;
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto st705;
	goto tr761;
st31:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof31;
case 31:
	switch( (*( sm->p)) ) {
		case 79: goto st32;
		case 111: goto st32;
	}
	goto tr0;
st32:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof32;
case 32:
	switch( (*( sm->p)) ) {
		case 68: goto st33;
		case 100: goto st33;
	}
	goto tr0;
st33:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof33;
case 33:
	switch( (*( sm->p)) ) {
		case 69: goto st34;
		case 101: goto st34;
	}
	goto tr0;
st34:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof34;
case 34:
	if ( (*( sm->p)) == 62 )
		goto st706;
	goto tr0;
st706:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof706;
case 706:
	if ( (*( sm->p)) == 32 )
		goto st706;
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto st706;
	goto tr762;
st35:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof35;
case 35:
	switch( (*( sm->p)) ) {
		case 88: goto st36;
		case 120: goto st36;
	}
	goto tr0;
st36:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof36;
case 36:
	switch( (*( sm->p)) ) {
		case 80: goto st37;
		case 112: goto st37;
	}
	goto tr0;
st37:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof37;
case 37:
	switch( (*( sm->p)) ) {
		case 65: goto st38;
		case 97: goto st38;
	}
	goto tr0;
st38:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof38;
case 38:
	switch( (*( sm->p)) ) {
		case 78: goto st39;
		case 110: goto st39;
	}
	goto tr0;
st39:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof39;
case 39:
	switch( (*( sm->p)) ) {
		case 68: goto st40;
		case 100: goto st40;
	}
	goto tr0;
st40:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof40;
case 40:
	switch( (*( sm->p)) ) {
		case 9: goto tr46;
		case 32: goto tr46;
		case 61: goto tr47;
		case 62: goto st708;
	}
	goto tr45;
tr45:
#line 45 "ext/dtext/dtext.cpp.rl"
	{
  sm->a1 = sm->p;
}
	goto st41;
st41:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof41;
case 41:
#line 2360 "ext/dtext/dtext.cpp"
	if ( (*( sm->p)) == 62 )
		goto tr50;
	goto st41;
tr50:
#line 49 "ext/dtext/dtext.cpp.rl"
	{
  sm->a2 = sm->p;
}
	goto st707;
st707:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof707;
case 707:
#line 2374 "ext/dtext/dtext.cpp"
	if ( (*( sm->p)) == 32 )
		goto st707;
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto st707;
	goto tr763;
tr46:
#line 45 "ext/dtext/dtext.cpp.rl"
	{
  sm->a1 = sm->p;
}
	goto st42;
st42:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof42;
case 42:
#line 2390 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto tr46;
		case 32: goto tr46;
		case 61: goto tr47;
		case 62: goto tr50;
	}
	goto tr45;
tr47:
#line 45 "ext/dtext/dtext.cpp.rl"
	{
  sm->a1 = sm->p;
}
	goto st43;
st43:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof43;
case 43:
#line 2408 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto tr47;
		case 32: goto tr47;
		case 62: goto tr50;
	}
	goto tr45;
st708:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof708;
case 708:
	if ( (*( sm->p)) == 32 )
		goto st708;
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto st708;
	goto tr765;
st44:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof44;
case 44:
	switch( (*( sm->p)) ) {
		case 79: goto st45;
		case 111: goto st45;
	}
	goto tr0;
st45:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof45;
case 45:
	switch( (*( sm->p)) ) {
		case 68: goto st46;
		case 100: goto st46;
	}
	goto tr0;
st46:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof46;
case 46:
	switch( (*( sm->p)) ) {
		case 84: goto st47;
		case 116: goto st47;
	}
	goto tr0;
st47:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof47;
case 47:
	switch( (*( sm->p)) ) {
		case 69: goto st48;
		case 101: goto st48;
	}
	goto tr0;
st48:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof48;
case 48:
	switch( (*( sm->p)) ) {
		case 88: goto st49;
		case 120: goto st49;
	}
	goto tr0;
st49:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof49;
case 49:
	switch( (*( sm->p)) ) {
		case 84: goto st50;
		case 116: goto st50;
	}
	goto tr0;
st50:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof50;
case 50:
	if ( (*( sm->p)) == 62 )
		goto st709;
	goto tr0;
st709:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof709;
case 709:
	if ( (*( sm->p)) == 32 )
		goto st709;
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto st709;
	goto tr766;
st51:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof51;
case 51:
	switch( (*( sm->p)) ) {
		case 80: goto st52;
		case 112: goto st52;
	}
	goto tr0;
st52:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof52;
case 52:
	switch( (*( sm->p)) ) {
		case 79: goto st53;
		case 111: goto st53;
	}
	goto tr0;
st53:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof53;
case 53:
	switch( (*( sm->p)) ) {
		case 73: goto st54;
		case 105: goto st54;
	}
	goto tr0;
st54:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof54;
case 54:
	switch( (*( sm->p)) ) {
		case 76: goto st55;
		case 108: goto st55;
	}
	goto tr0;
st55:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof55;
case 55:
	switch( (*( sm->p)) ) {
		case 69: goto st56;
		case 101: goto st56;
	}
	goto tr0;
st56:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof56;
case 56:
	switch( (*( sm->p)) ) {
		case 82: goto st57;
		case 114: goto st57;
	}
	goto tr0;
st57:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof57;
case 57:
	switch( (*( sm->p)) ) {
		case 62: goto st710;
		case 83: goto st58;
		case 115: goto st58;
	}
	goto tr0;
st710:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof710;
case 710:
	if ( (*( sm->p)) == 32 )
		goto st710;
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto st710;
	goto tr767;
st58:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof58;
case 58:
	if ( (*( sm->p)) == 62 )
		goto st710;
	goto tr0;
st59:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof59;
case 59:
	switch( (*( sm->p)) ) {
		case 65: goto st60;
		case 78: goto st64;
		case 97: goto st60;
		case 110: goto st64;
	}
	goto tr0;
st60:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof60;
case 60:
	switch( (*( sm->p)) ) {
		case 66: goto st61;
		case 98: goto st61;
	}
	goto tr0;
st61:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof61;
case 61:
	switch( (*( sm->p)) ) {
		case 76: goto st62;
		case 108: goto st62;
	}
	goto tr0;
st62:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof62;
case 62:
	switch( (*( sm->p)) ) {
		case 69: goto st63;
		case 101: goto st63;
	}
	goto tr0;
st63:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof63;
case 63:
	if ( (*( sm->p)) == 62 )
		goto tr71;
	goto tr0;
st64:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof64;
case 64:
	if ( (*( sm->p)) == 62 )
		goto tr72;
	goto tr0;
tr747:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
	goto st711;
st711:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof711;
case 711:
#line 2634 "ext/dtext/dtext.cpp"
	if ( 49 <= (*( sm->p)) && (*( sm->p)) <= 54 )
		goto tr768;
	goto tr749;
tr768:
#line 45 "ext/dtext/dtext.cpp.rl"
	{
  sm->a1 = sm->p;
}
	goto st65;
st65:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof65;
case 65:
#line 2648 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 35: goto tr73;
		case 46: goto tr74;
	}
	goto tr0;
tr73:
#line 49 "ext/dtext/dtext.cpp.rl"
	{
  sm->a2 = sm->p;
}
	goto st66;
st66:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof66;
case 66:
#line 2664 "ext/dtext/dtext.cpp"
	if ( (*( sm->p)) == 33 )
		goto tr75;
	if ( (*( sm->p)) > 45 ) {
		if ( 47 <= (*( sm->p)) && (*( sm->p)) <= 126 )
			goto tr75;
	} else if ( (*( sm->p)) >= 35 )
		goto tr75;
	goto tr0;
tr75:
#line 53 "ext/dtext/dtext.cpp.rl"
	{
  sm->b1 = sm->p;
}
	goto st67;
st67:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof67;
case 67:
#line 2683 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 33: goto st67;
		case 46: goto tr77;
	}
	if ( 35 <= (*( sm->p)) && (*( sm->p)) <= 126 )
		goto st67;
	goto tr0;
tr77:
#line 57 "ext/dtext/dtext.cpp.rl"
	{
  sm->b2 = sm->p;
}
	goto st712;
st712:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof712;
case 712:
#line 2701 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto st712;
		case 32: goto st712;
	}
	goto tr769;
tr74:
#line 49 "ext/dtext/dtext.cpp.rl"
	{
  sm->a2 = sm->p;
}
	goto st713;
st713:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof713;
case 713:
#line 2717 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto st713;
		case 32: goto st713;
	}
	goto tr771;
tr748:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 785 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 121;}
	goto st714;
st714:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof714;
case 714:
#line 2733 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 47: goto st68;
		case 67: goto st77;
		case 69: goto st81;
		case 72: goto st7;
		case 78: goto st90;
		case 81: goto st97;
		case 83: goto st102;
		case 84: goto st110;
		case 99: goto st77;
		case 101: goto st81;
		case 104: goto st7;
		case 110: goto st90;
		case 113: goto st97;
		case 115: goto st102;
		case 116: goto st110;
	}
	goto tr749;
st68:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof68;
case 68:
	switch( (*( sm->p)) ) {
		case 83: goto st69;
		case 115: goto st69;
	}
	goto tr0;
st69:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof69;
case 69:
	switch( (*( sm->p)) ) {
		case 80: goto st70;
		case 112: goto st70;
	}
	goto tr0;
st70:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof70;
case 70:
	switch( (*( sm->p)) ) {
		case 79: goto st71;
		case 111: goto st71;
	}
	goto tr0;
st71:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof71;
case 71:
	switch( (*( sm->p)) ) {
		case 73: goto st72;
		case 105: goto st72;
	}
	goto tr0;
st72:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof72;
case 72:
	switch( (*( sm->p)) ) {
		case 76: goto st73;
		case 108: goto st73;
	}
	goto tr0;
st73:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof73;
case 73:
	switch( (*( sm->p)) ) {
		case 69: goto st74;
		case 101: goto st74;
	}
	goto tr0;
st74:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof74;
case 74:
	switch( (*( sm->p)) ) {
		case 82: goto st75;
		case 114: goto st75;
	}
	goto tr0;
st75:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof75;
case 75:
	switch( (*( sm->p)) ) {
		case 83: goto st76;
		case 93: goto tr24;
		case 115: goto st76;
	}
	goto tr0;
st76:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof76;
case 76:
	if ( (*( sm->p)) == 93 )
		goto tr24;
	goto tr0;
st77:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof77;
case 77:
	switch( (*( sm->p)) ) {
		case 79: goto st78;
		case 111: goto st78;
	}
	goto tr0;
st78:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof78;
case 78:
	switch( (*( sm->p)) ) {
		case 68: goto st79;
		case 100: goto st79;
	}
	goto tr0;
st79:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof79;
case 79:
	switch( (*( sm->p)) ) {
		case 69: goto st80;
		case 101: goto st80;
	}
	goto tr0;
st80:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof80;
case 80:
	if ( (*( sm->p)) == 93 )
		goto st706;
	goto tr0;
st81:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof81;
case 81:
	switch( (*( sm->p)) ) {
		case 88: goto st82;
		case 120: goto st82;
	}
	goto tr0;
st82:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof82;
case 82:
	switch( (*( sm->p)) ) {
		case 80: goto st83;
		case 112: goto st83;
	}
	goto tr0;
st83:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof83;
case 83:
	switch( (*( sm->p)) ) {
		case 65: goto st84;
		case 97: goto st84;
	}
	goto tr0;
st84:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof84;
case 84:
	switch( (*( sm->p)) ) {
		case 78: goto st85;
		case 110: goto st85;
	}
	goto tr0;
st85:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof85;
case 85:
	switch( (*( sm->p)) ) {
		case 68: goto st86;
		case 100: goto st86;
	}
	goto tr0;
st86:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof86;
case 86:
	switch( (*( sm->p)) ) {
		case 9: goto tr95;
		case 32: goto tr95;
		case 61: goto tr96;
		case 93: goto st708;
	}
	goto tr94;
tr94:
#line 45 "ext/dtext/dtext.cpp.rl"
	{
  sm->a1 = sm->p;
}
	goto st87;
st87:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof87;
case 87:
#line 2932 "ext/dtext/dtext.cpp"
	if ( (*( sm->p)) == 93 )
		goto tr50;
	goto st87;
tr95:
#line 45 "ext/dtext/dtext.cpp.rl"
	{
  sm->a1 = sm->p;
}
	goto st88;
st88:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof88;
case 88:
#line 2946 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto tr95;
		case 32: goto tr95;
		case 61: goto tr96;
		case 93: goto tr50;
	}
	goto tr94;
tr96:
#line 45 "ext/dtext/dtext.cpp.rl"
	{
  sm->a1 = sm->p;
}
	goto st89;
st89:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof89;
case 89:
#line 2964 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto tr96;
		case 32: goto tr96;
		case 93: goto tr50;
	}
	goto tr94;
st90:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof90;
case 90:
	switch( (*( sm->p)) ) {
		case 79: goto st91;
		case 111: goto st91;
	}
	goto tr0;
st91:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof91;
case 91:
	switch( (*( sm->p)) ) {
		case 68: goto st92;
		case 100: goto st92;
	}
	goto tr0;
st92:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof92;
case 92:
	switch( (*( sm->p)) ) {
		case 84: goto st93;
		case 116: goto st93;
	}
	goto tr0;
st93:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof93;
case 93:
	switch( (*( sm->p)) ) {
		case 69: goto st94;
		case 101: goto st94;
	}
	goto tr0;
st94:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof94;
case 94:
	switch( (*( sm->p)) ) {
		case 88: goto st95;
		case 120: goto st95;
	}
	goto tr0;
st95:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof95;
case 95:
	switch( (*( sm->p)) ) {
		case 84: goto st96;
		case 116: goto st96;
	}
	goto tr0;
st96:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof96;
case 96:
	if ( (*( sm->p)) == 93 )
		goto st709;
	goto tr0;
st97:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof97;
case 97:
	switch( (*( sm->p)) ) {
		case 85: goto st98;
		case 117: goto st98;
	}
	goto tr0;
st98:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof98;
case 98:
	switch( (*( sm->p)) ) {
		case 79: goto st99;
		case 111: goto st99;
	}
	goto tr0;
st99:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof99;
case 99:
	switch( (*( sm->p)) ) {
		case 84: goto st100;
		case 116: goto st100;
	}
	goto tr0;
st100:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof100;
case 100:
	switch( (*( sm->p)) ) {
		case 69: goto st101;
		case 101: goto st101;
	}
	goto tr0;
st101:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof101;
case 101:
	if ( (*( sm->p)) == 93 )
		goto st705;
	goto tr0;
st102:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof102;
case 102:
	switch( (*( sm->p)) ) {
		case 80: goto st103;
		case 112: goto st103;
	}
	goto tr0;
st103:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof103;
case 103:
	switch( (*( sm->p)) ) {
		case 79: goto st104;
		case 111: goto st104;
	}
	goto tr0;
st104:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof104;
case 104:
	switch( (*( sm->p)) ) {
		case 73: goto st105;
		case 105: goto st105;
	}
	goto tr0;
st105:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof105;
case 105:
	switch( (*( sm->p)) ) {
		case 76: goto st106;
		case 108: goto st106;
	}
	goto tr0;
st106:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof106;
case 106:
	switch( (*( sm->p)) ) {
		case 69: goto st107;
		case 101: goto st107;
	}
	goto tr0;
st107:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof107;
case 107:
	switch( (*( sm->p)) ) {
		case 82: goto st108;
		case 114: goto st108;
	}
	goto tr0;
st108:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof108;
case 108:
	switch( (*( sm->p)) ) {
		case 83: goto st109;
		case 93: goto st710;
		case 115: goto st109;
	}
	goto tr0;
st109:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof109;
case 109:
	if ( (*( sm->p)) == 93 )
		goto st710;
	goto tr0;
st110:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof110;
case 110:
	switch( (*( sm->p)) ) {
		case 65: goto st111;
		case 78: goto st115;
		case 97: goto st111;
		case 110: goto st115;
	}
	goto tr0;
st111:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof111;
case 111:
	switch( (*( sm->p)) ) {
		case 66: goto st112;
		case 98: goto st112;
	}
	goto tr0;
st112:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof112;
case 112:
	switch( (*( sm->p)) ) {
		case 76: goto st113;
		case 108: goto st113;
	}
	goto tr0;
st113:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof113;
case 113:
	switch( (*( sm->p)) ) {
		case 69: goto st114;
		case 101: goto st114;
	}
	goto tr0;
st114:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof114;
case 114:
	if ( (*( sm->p)) == 93 )
		goto tr71;
	goto tr0;
st115:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof115;
case 115:
	if ( (*( sm->p)) == 93 )
		goto tr72;
	goto tr0;
tr120:
#line 170 "ext/dtext/dtext.cpp.rl"
	{{( sm->p) = ((( sm->te)))-1;}{ append_c_html_escaped(sm, (*( sm->p))); }}
	goto st715;
tr126:
#line 162 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{ dstack_close_inline(sm, INLINE_B, "</strong>"); }}
	goto st715;
tr127:
#line 164 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{ dstack_close_inline(sm, INLINE_I, "</em>"); }}
	goto st715;
tr128:
#line 166 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{ dstack_close_inline(sm, INLINE_S, "</s>"); }}
	goto st715;
tr133:
#line 168 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{ dstack_close_inline(sm, INLINE_U, "</u>"); }}
	goto st715;
tr134:
#line 161 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{ dstack_open_inline(sm,  INLINE_B, "<strong>"); }}
	goto st715;
tr136:
#line 163 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{ dstack_open_inline(sm,  INLINE_I, "<em>"); }}
	goto st715;
tr137:
#line 165 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{ dstack_open_inline(sm,  INLINE_S, "<s>"); }}
	goto st715;
tr143:
#line 167 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{ dstack_open_inline(sm,  INLINE_U, "<u>"); }}
	goto st715;
tr780:
#line 170 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{ append_c_html_escaped(sm, (*( sm->p))); }}
	goto st715;
tr781:
#line 169 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;}
	goto st715;
tr784:
#line 170 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{ append_c_html_escaped(sm, (*( sm->p))); }}
	goto st715;
st715:
#line 1 "NONE"
	{( sm->ts) = 0;}
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof715;
case 715:
#line 1 "NONE"
	{( sm->ts) = ( sm->p);}
#line 3254 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr781;
		case 60: goto tr782;
		case 91: goto tr783;
	}
	goto tr780;
tr782:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
	goto st716;
st716:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof716;
case 716:
#line 3269 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 47: goto st116;
		case 66: goto st126;
		case 69: goto st127;
		case 73: goto st128;
		case 83: goto st129;
		case 85: goto st134;
		case 98: goto st126;
		case 101: goto st127;
		case 105: goto st128;
		case 115: goto st129;
		case 117: goto st134;
	}
	goto tr784;
st116:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof116;
case 116:
	switch( (*( sm->p)) ) {
		case 66: goto st117;
		case 69: goto st118;
		case 73: goto st119;
		case 83: goto st120;
		case 85: goto st125;
		case 98: goto st117;
		case 101: goto st118;
		case 105: goto st119;
		case 115: goto st120;
		case 117: goto st125;
	}
	goto tr120;
st117:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof117;
case 117:
	if ( (*( sm->p)) == 62 )
		goto tr126;
	goto tr120;
st118:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof118;
case 118:
	switch( (*( sm->p)) ) {
		case 77: goto st119;
		case 109: goto st119;
	}
	goto tr120;
st119:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof119;
case 119:
	if ( (*( sm->p)) == 62 )
		goto tr127;
	goto tr120;
st120:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof120;
case 120:
	switch( (*( sm->p)) ) {
		case 62: goto tr128;
		case 84: goto st121;
		case 116: goto st121;
	}
	goto tr120;
st121:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof121;
case 121:
	switch( (*( sm->p)) ) {
		case 82: goto st122;
		case 114: goto st122;
	}
	goto tr120;
st122:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof122;
case 122:
	switch( (*( sm->p)) ) {
		case 79: goto st123;
		case 111: goto st123;
	}
	goto tr120;
st123:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof123;
case 123:
	switch( (*( sm->p)) ) {
		case 78: goto st124;
		case 110: goto st124;
	}
	goto tr120;
st124:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof124;
case 124:
	switch( (*( sm->p)) ) {
		case 71: goto st117;
		case 103: goto st117;
	}
	goto tr120;
st125:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof125;
case 125:
	if ( (*( sm->p)) == 62 )
		goto tr133;
	goto tr120;
st126:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof126;
case 126:
	if ( (*( sm->p)) == 62 )
		goto tr134;
	goto tr120;
st127:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof127;
case 127:
	switch( (*( sm->p)) ) {
		case 77: goto st128;
		case 109: goto st128;
	}
	goto tr120;
st128:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof128;
case 128:
	if ( (*( sm->p)) == 62 )
		goto tr136;
	goto tr120;
st129:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof129;
case 129:
	switch( (*( sm->p)) ) {
		case 62: goto tr137;
		case 84: goto st130;
		case 116: goto st130;
	}
	goto tr120;
st130:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof130;
case 130:
	switch( (*( sm->p)) ) {
		case 82: goto st131;
		case 114: goto st131;
	}
	goto tr120;
st131:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof131;
case 131:
	switch( (*( sm->p)) ) {
		case 79: goto st132;
		case 111: goto st132;
	}
	goto tr120;
st132:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof132;
case 132:
	switch( (*( sm->p)) ) {
		case 78: goto st133;
		case 110: goto st133;
	}
	goto tr120;
st133:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof133;
case 133:
	switch( (*( sm->p)) ) {
		case 71: goto st126;
		case 103: goto st126;
	}
	goto tr120;
st134:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof134;
case 134:
	if ( (*( sm->p)) == 62 )
		goto tr143;
	goto tr120;
tr783:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
	goto st717;
st717:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof717;
case 717:
#line 3461 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 47: goto st135;
		case 66: goto st140;
		case 73: goto st141;
		case 83: goto st142;
		case 85: goto st143;
		case 98: goto st140;
		case 105: goto st141;
		case 115: goto st142;
		case 117: goto st143;
	}
	goto tr784;
st135:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof135;
case 135:
	switch( (*( sm->p)) ) {
		case 66: goto st136;
		case 73: goto st137;
		case 83: goto st138;
		case 85: goto st139;
		case 98: goto st136;
		case 105: goto st137;
		case 115: goto st138;
		case 117: goto st139;
	}
	goto tr120;
st136:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof136;
case 136:
	if ( (*( sm->p)) == 93 )
		goto tr126;
	goto tr120;
st137:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof137;
case 137:
	if ( (*( sm->p)) == 93 )
		goto tr127;
	goto tr120;
st138:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof138;
case 138:
	if ( (*( sm->p)) == 93 )
		goto tr128;
	goto tr120;
st139:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof139;
case 139:
	if ( (*( sm->p)) == 93 )
		goto tr133;
	goto tr120;
st140:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof140;
case 140:
	if ( (*( sm->p)) == 93 )
		goto tr134;
	goto tr120;
st141:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof141;
case 141:
	if ( (*( sm->p)) == 93 )
		goto tr136;
	goto tr120;
st142:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof142;
case 142:
	if ( (*( sm->p)) == 93 )
		goto tr137;
	goto tr120;
st143:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof143;
case 143:
	if ( (*( sm->p)) == 93 )
		goto tr143;
	goto tr120;
tr148:
#line 1 "NONE"
	{	switch( ( sm->act) ) {
	case 55:
	{{( sm->p) = ((( sm->te)))-1;}
    append_segment_html_escaped(sm, sm->ts, sm->te - 1);
  }
	break;
	case 56:
	{{( sm->p) = ((( sm->te)))-1;}
    if (!sm->f_mentions || (sm->a1[-2] != '\0' && sm->a1[-2] != ' ' && sm->a1[-2] != '\r' && sm->a1[-2] != '\n')) {
      g_debug("write '@' (ignored mention)");
      append_c_html_escaped(sm, '@');
      {( sm->p) = (( sm->a1))-1;}
    } else {
      const char* match_end = sm->a2 - 1;
      const char* name_start = sm->a1;
      const char* name_end = find_boundary_c(match_end);

      g_debug("mention: '@%.*s'", (int)(name_end - name_start + 1), sm->a1);
      append_mention(sm, name_start, name_end);

      if (name_end < match_end) {
        append_segment_html_escaped(sm, name_end + 1, match_end);
      }
    }
  }
	break;
	case 79:
	{{( sm->p) = ((( sm->te)))-1;}
    g_debug("inline [hr] (pos: %ld)", sm->ts - sm->pb);

    if (sm->header_mode) {
      sm->header_mode = false;
      dstack_rewind(sm);
    }

    dstack_close_before_block(sm);
    {( sm->p) = (( sm->ts))-1;}
    { sm->cs = ( (sm->stack.data()))[--( sm->top)];goto _again;}
  }
	break;
	case 80:
	{{( sm->p) = ((( sm->te)))-1;}
    g_debug("inline newline2");
    g_debug("  return");

    dstack_close_list(sm);
    {( sm->p) = (( sm->ts))-1;}
    { sm->cs = ( (sm->stack.data()))[--( sm->top)];goto _again;}
  }
	break;
	case 81:
	{{( sm->p) = ((( sm->te)))-1;}
    g_debug("inline newline");

    if (sm->header_mode) {
      sm->header_mode = false;
      dstack_rewind(sm);
      { sm->cs = ( (sm->stack.data()))[--( sm->top)];goto _again;}
    } else {
      append(sm, "<br>");
    }
  }
	break;
	default:
	{{( sm->p) = ((( sm->te)))-1;}}
	break;
	}
	}
	goto st718;
tr162:
#line 448 "ext/dtext/dtext.cpp.rl"
	{{( sm->p) = ((( sm->te)))-1;}{
    g_debug("inline newline");

    if (sm->header_mode) {
      sm->header_mode = false;
      dstack_rewind(sm);
      { sm->cs = ( (sm->stack.data()))[--( sm->top)];goto _again;}
    } else {
      append(sm, "<br>");
    }
  }}
	goto st718;
tr167:
#line 466 "ext/dtext/dtext.cpp.rl"
	{{( sm->p) = ((( sm->te)))-1;}{
    append_c_html_escaped(sm, (*( sm->p)));
  }}
	goto st718;
tr185:
#line 246 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{
    if (!append_named_url(sm, sm->b1, sm->b2, sm->a1, sm->a2)) {
      {( sm->p)++;  sm->cs = 718; goto _out;}
    }
  }}
	goto st718;
tr215:
#line 325 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{ dstack_close_inline(sm, INLINE_B, "</strong>"); }}
	goto st718;
tr226:
#line 327 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{ dstack_close_inline(sm, INLINE_I, "</em>"); }}
	goto st718;
tr231:
#line 406 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_close_before_block(sm);

    if (dstack_close_block(sm, BLOCK_EXPAND, "</div></details>")) {
      { sm->cs = ( (sm->stack.data()))[--( sm->top)];goto _again;}
    }
  }}
	goto st718;
tr232:
#line 329 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{ dstack_close_inline(sm, INLINE_S, "</s>"); }}
	goto st718;
tr240:
#line 357 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{
    g_debug("inline [/spoiler]");
    dstack_close_before_block(sm);

    if (dstack_check(sm, INLINE_SPOILER)) {
      dstack_close_inline(sm, INLINE_SPOILER, "</span>");
    } else if (dstack_close_block(sm, BLOCK_SPOILER, "</div>")) {
      { sm->cs = ( (sm->stack.data()))[--( sm->top)];goto _again;}
    }
  }}
	goto st718;
tr249:
#line 420 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{
    if (dstack_close_block(sm, BLOCK_TD, "</td>")) {
      { sm->cs = ( (sm->stack.data()))[--( sm->top)];goto _again;}
    }
  }}
	goto st718;
tr250:
#line 414 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{
    if (dstack_close_block(sm, BLOCK_TH, "</th>")) {
      { sm->cs = ( (sm->stack.data()))[--( sm->top)];goto _again;}
    }
  }}
	goto st718;
tr251:
#line 337 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{
    g_debug("inline [/tn]");
    dstack_close_before_block(sm);

    if (dstack_check(sm, INLINE_TN)) {
      dstack_close_inline(sm, INLINE_TN, "</span>");
    } else if (dstack_close_block(sm, BLOCK_TN, "</p>")) {
      { sm->cs = ( (sm->stack.data()))[--( sm->top)];goto _again;}
    }
  }}
	goto st718;
tr252:
#line 331 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{ dstack_close_inline(sm, INLINE_U, "</u>"); }}
	goto st718;
tr255:
#line 49 "ext/dtext/dtext.cpp.rl"
	{
  sm->a2 = sm->p;
}
#line 298 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{
    if (sm->f_mentions) {
      g_debug("delimited mention: <@%.*s>", (int)(sm->a2 - sm->a1), sm->a1);
      append_mention(sm, sm->a1, sm->a2 - 1);
    }
  }}
	goto st718;
tr273:
#line 252 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{
    if (!append_named_url(sm, sm->a1, sm->a2 - 1, sm->b1, sm->b2)) {
      {( sm->p)++;  sm->cs = 718; goto _out;}
    }
  }}
	goto st718;
tr281:
#line 324 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{ dstack_open_inline(sm,  INLINE_B, "<strong>"); }}
	goto st718;
tr291:
#line 376 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{
    g_debug("inline [quote]");
    dstack_close_before_block(sm);
    {( sm->p) = (( sm->ts))-1;}
    { sm->cs = ( (sm->stack.data()))[--( sm->top)];goto _again;}
  }}
	goto st718;
tr295:
#line 348 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_open_inline(sm, INLINE_CODE, "<code>");
    {
  size_t len = sm->stack.size();

  if (len > MAX_STACK_DEPTH) {
    sm->error = "too many nested elements";
    {( sm->p)++;  sm->cs = 0; goto _out;}
  }

  if (sm->top >= len) {
    g_debug("growing sm->stack %zi", len + 16);
    sm->stack.resize(len + 16, 0);
  }
{( (sm->stack.data()))[( sm->top)++] = 718;goto st793;}}
  }}
	goto st718;
tr298:
#line 326 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{ dstack_open_inline(sm,  INLINE_I, "<em>"); }}
	goto st718;
tr303:
#line 399 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{
    g_debug("inline [expand]");
    dstack_rewind(sm);
    {( sm->p) = (((sm->p - 7)))-1;}
    { sm->cs = ( (sm->stack.data()))[--( sm->top)];goto _again;}
  }}
	goto st718;
tr312:
#line 270 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{
    append_unnamed_url(sm, sm->ts + 1, sm->te - 2);
  }}
	goto st718;
tr319:
#line 368 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_open_inline(sm, INLINE_NODTEXT, "");
    {
  size_t len = sm->stack.size();

  if (len > MAX_STACK_DEPTH) {
    sm->error = "too many nested elements";
    {( sm->p)++;  sm->cs = 0; goto _out;}
  }

  if (sm->top >= len) {
    g_debug("growing sm->stack %zi", len + 16);
    sm->stack.resize(len + 16, 0);
  }
{( (sm->stack.data()))[( sm->top)++] = 718;goto st796;}}
  }}
	goto st718;
tr320:
#line 328 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{ dstack_open_inline(sm,  INLINE_S, "<s>"); }}
	goto st718;
tr328:
#line 353 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_open_inline(sm, INLINE_SPOILER, "<span class=\"spoiler\">");
  }}
	goto st718;
tr335:
#line 333 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_open_inline(sm, INLINE_TN, "<span class=\"tn\">");
  }}
	goto st718;
tr336:
#line 330 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{ dstack_open_inline(sm,  INLINE_U, "<u>"); }}
	goto st718;
tr405:
#line 181 "ext/dtext/dtext.cpp.rl"
	{{( sm->p) = ((( sm->te)))-1;}{ append_id_link(sm, "dmail", "dmail", "/dmails/"); }}
	goto st718;
tr513:
#line 202 "ext/dtext/dtext.cpp.rl"
	{{( sm->p) = ((( sm->te)))-1;}{ append_id_link(sm, "pixiv", "pixiv", "https://www.pixiv.net/artworks/"); }}
	goto st718;
tr551:
#line 179 "ext/dtext/dtext.cpp.rl"
	{{( sm->p) = ((( sm->te)))-1;}{ append_id_link(sm, "topic", "forum-topic", "/forum_topics/"); }}
	goto st718;
tr626:
#line 57 "ext/dtext/dtext.cpp.rl"
	{
  sm->b2 = sm->p;
}
#line 252 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{
    if (!append_named_url(sm, sm->a1, sm->a2 - 1, sm->b1, sm->b2)) {
      {( sm->p)++;  sm->cs = 718; goto _out;}
    }
  }}
	goto st718;
tr648:
#line 215 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{
    append(sm, "<a class=\"dtext-link dtext-post-search-link\" href=\"");
    append_url(sm, "/posts?tags=");
    append_segment_uri_escaped(sm, sm->a1, sm->a2 - 1);
    append(sm, "\">");
    append_segment_html_escaped(sm, sm->a1, sm->a2 - 1);
    append(sm, "</a>");
  }}
	goto st718;
tr794:
#line 466 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{
    append_c_html_escaped(sm, (*( sm->p)));
  }}
	goto st718;
tr820:
#line 464 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;}
	goto st718;
tr821:
#line 426 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    g_debug("inline [hr] (pos: %ld)", sm->ts - sm->pb);

    if (sm->header_mode) {
      sm->header_mode = false;
      dstack_rewind(sm);
    }

    dstack_close_before_block(sm);
    {( sm->p) = (( sm->ts))-1;}
    { sm->cs = ( (sm->stack.data()))[--( sm->top)];goto _again;}
  }}
	goto st718;
tr822:
#line 448 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    g_debug("inline newline");

    if (sm->header_mode) {
      sm->header_mode = false;
      dstack_rewind(sm);
      { sm->cs = ( (sm->stack.data()))[--( sm->top)];goto _again;}
    } else {
      append(sm, "<br>");
    }
  }}
	goto st718;
tr825:
#line 439 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    g_debug("inline newline2");
    g_debug("  return");

    dstack_close_list(sm);
    {( sm->p) = (( sm->ts))-1;}
    { sm->cs = ( (sm->stack.data()))[--( sm->top)];goto _again;}
  }}
	goto st718;
tr826:
	 sm->cs = 718;
#line 57 "ext/dtext/dtext.cpp.rl"
	{
  sm->b2 = sm->p;
}
#line 305 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    g_debug("inline list");

    if (dstack_check(sm, BLOCK_LI)) {
      g_debug("  rewind li");
      dstack_rewind(sm);
    } else if (dstack_check(sm, BLOCK_P)) {
      g_debug("  rewind p");
      dstack_rewind(sm);
    } else if (sm->header_mode) {
      g_debug("  rewind header");
      dstack_rewind(sm);
    }

    g_debug("  next list");
    {( sm->p) = (( sm->ts + 1))-1;}
     sm->cs = 802;
  }}
	goto _again;
tr828:
#line 460 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append_c_html_escaped(sm, ' ');
  }}
	goto st718;
tr829:
#line 466 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append_c_html_escaped(sm, (*( sm->p)));
  }}
	goto st718;
tr831:
#line 232 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    const char* match_end = sm->b2;
    const char* url_start = sm->b1;
    const char* url_end = find_boundary_c(match_end);

    if (!append_named_url(sm, url_start, url_end, sm->a1, sm->a2)) {
      {( sm->p)++;  sm->cs = 718; goto _out;}
    }

    if (url_end < match_end) {
      append_segment_html_escaped(sm, url_end + 1, match_end);
    }
  }}
	goto st718;
tr832:
#line 61 "ext/dtext/dtext.cpp.rl"
	{
  sm->c1 = sm->p;
}
#line 65 "ext/dtext/dtext.cpp.rl"
	{
  sm->c2 = sm->p;
}
#line 224 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append_wiki_link(sm, sm->b1, sm->b2 - sm->b1, sm->b1, sm->b2 - sm->b1, sm->a1, sm->a2 - sm->a1, sm->c1, sm->c2 - sm->c1);
  }}
	goto st718;
tr834:
#line 65 "ext/dtext/dtext.cpp.rl"
	{
  sm->c2 = sm->p;
}
#line 224 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append_wiki_link(sm, sm->b1, sm->b2 - sm->b1, sm->b1, sm->b2 - sm->b1, sm->a1, sm->a2 - sm->a1, sm->c1, sm->c2 - sm->c1);
  }}
	goto st718;
tr836:
#line 69 "ext/dtext/dtext.cpp.rl"
	{
  sm->d1 = sm->p;
}
#line 73 "ext/dtext/dtext.cpp.rl"
	{
  sm->d2 = sm->p;
}
#line 228 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append_wiki_link(sm, sm->b1, sm->b2 - sm->b1, sm->c1, sm->c2 - sm->c1, sm->a1, sm->a2 - sm->a1, sm->d1, sm->d2 - sm->d1);
  }}
	goto st718;
tr838:
#line 73 "ext/dtext/dtext.cpp.rl"
	{
  sm->d2 = sm->p;
}
#line 228 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append_wiki_link(sm, sm->b1, sm->b2 - sm->b1, sm->c1, sm->c2 - sm->c1, sm->a1, sm->a2 - sm->a1, sm->d1, sm->d2 - sm->d1);
  }}
	goto st718;
tr851:
#line 383 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    g_debug("inline [/quote]");
    dstack_close_before_block(sm);

    if (dstack_check(sm, BLOCK_LI)) {
      dstack_close_list(sm);
    }

    if (dstack_is_open(sm, BLOCK_QUOTE)) {
      dstack_close_until(sm, BLOCK_QUOTE);
      { sm->cs = ( (sm->stack.data()))[--( sm->top)];goto _again;}
    } else {
      append_block(sm, "[/quote]");
    }
  }}
	goto st718;
tr854:
#line 49 "ext/dtext/dtext.cpp.rl"
	{
  sm->a2 = sm->p;
}
#line 1 "NONE"
	{	switch( ( sm->act) ) {
	case 55:
	{{( sm->p) = ((( sm->te)))-1;}
    append_segment_html_escaped(sm, sm->ts, sm->te - 1);
  }
	break;
	case 56:
	{{( sm->p) = ((( sm->te)))-1;}
    if (!sm->f_mentions || (sm->a1[-2] != '\0' && sm->a1[-2] != ' ' && sm->a1[-2] != '\r' && sm->a1[-2] != '\n')) {
      g_debug("write '@' (ignored mention)");
      append_c_html_escaped(sm, '@');
      {( sm->p) = (( sm->a1))-1;}
    } else {
      const char* match_end = sm->a2 - 1;
      const char* name_start = sm->a1;
      const char* name_end = find_boundary_c(match_end);

      g_debug("mention: '@%.*s'", (int)(name_end - name_start + 1), sm->a1);
      append_mention(sm, name_start, name_end);

      if (name_end < match_end) {
        append_segment_html_escaped(sm, name_end + 1, match_end);
      }
    }
  }
	break;
	case 79:
	{{( sm->p) = ((( sm->te)))-1;}
    g_debug("inline [hr] (pos: %ld)", sm->ts - sm->pb);

    if (sm->header_mode) {
      sm->header_mode = false;
      dstack_rewind(sm);
    }

    dstack_close_before_block(sm);
    {( sm->p) = (( sm->ts))-1;}
    { sm->cs = ( (sm->stack.data()))[--( sm->top)];goto _again;}
  }
	break;
	case 80:
	{{( sm->p) = ((( sm->te)))-1;}
    g_debug("inline newline2");
    g_debug("  return");

    dstack_close_list(sm);
    {( sm->p) = (( sm->ts))-1;}
    { sm->cs = ( (sm->stack.data()))[--( sm->top)];goto _again;}
  }
	break;
	case 81:
	{{( sm->p) = ((( sm->te)))-1;}
    g_debug("inline newline");

    if (sm->header_mode) {
      sm->header_mode = false;
      dstack_rewind(sm);
      { sm->cs = ( (sm->stack.data()))[--( sm->top)];goto _again;}
    } else {
      append(sm, "<br>");
    }
  }
	break;
	default:
	{{( sm->p) = ((( sm->te)))-1;}}
	break;
	}
	}
	goto st718;
tr856:
#line 49 "ext/dtext/dtext.cpp.rl"
	{
  sm->a2 = sm->p;
}
#line 279 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    if (!sm->f_mentions || (sm->a1[-2] != '\0' && sm->a1[-2] != ' ' && sm->a1[-2] != '\r' && sm->a1[-2] != '\n')) {
      g_debug("write '@' (ignored mention)");
      append_c_html_escaped(sm, '@');
      {( sm->p) = (( sm->a1))-1;}
    } else {
      const char* match_end = sm->a2 - 1;
      const char* name_start = sm->a1;
      const char* name_end = find_boundary_c(match_end);

      g_debug("mention: '@%.*s'", (int)(name_end - name_start + 1), sm->a1);
      append_mention(sm, name_start, name_end);

      if (name_end < match_end) {
        append_segment_html_escaped(sm, name_end + 1, match_end);
      }
    }
  }}
	goto st718;
tr861:
#line 49 "ext/dtext/dtext.cpp.rl"
	{
  sm->a2 = sm->p;
}
#line 187 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{ append_id_link(sm, "alias", "tag-alias", "/tag_aliases/"); }}
	goto st718;
tr863:
#line 49 "ext/dtext/dtext.cpp.rl"
	{
  sm->a2 = sm->p;
}
#line 175 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{ append_id_link(sm, "appeal", "post-appeal", "/post_appeals/"); }}
	goto st718;
tr865:
#line 49 "ext/dtext/dtext.cpp.rl"
	{
  sm->a2 = sm->p;
}
#line 184 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{ append_id_link(sm, "artist", "artist", "/artists/"); }}
	goto st718;
tr867:
#line 49 "ext/dtext/dtext.cpp.rl"
	{
  sm->a2 = sm->p;
}
#line 198 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{ append_id_link(sm, "artstation", "artstation", "https://www.artstation.com/artwork/"); }}
	goto st718;
tr871:
#line 49 "ext/dtext/dtext.cpp.rl"
	{
  sm->a2 = sm->p;
}
#line 185 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{ append_id_link(sm, "ban", "ban", "/bans/"); }}
	goto st718;
tr873:
#line 49 "ext/dtext/dtext.cpp.rl"
	{
  sm->a2 = sm->p;
}
#line 186 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{ append_id_link(sm, "BUR", "bulk-update-request", "/bulk_update_requests/"); }}
	goto st718;
tr876:
#line 49 "ext/dtext/dtext.cpp.rl"
	{
  sm->a2 = sm->p;
}
#line 180 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{ append_id_link(sm, "comment", "comment", "/comments/"); }}
	goto st718;
tr878:
#line 49 "ext/dtext/dtext.cpp.rl"
	{
  sm->a2 = sm->p;
}
#line 197 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{ append_id_link(sm, "commit", "github-commit", "https://github.com/danbooru/danbooru/commit/"); }}
	goto st718;
tr882:
#line 49 "ext/dtext/dtext.cpp.rl"
	{
  sm->a2 = sm->p;
}
#line 199 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{ append_id_link(sm, "deviantart", "deviantart", "https://www.deviantart.com/deviation/"); }}
	goto st718;
tr884:
#line 49 "ext/dtext/dtext.cpp.rl"
	{
  sm->a2 = sm->p;
}
#line 181 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{ append_id_link(sm, "dmail", "dmail", "/dmails/"); }}
	goto st718;
tr887:
#line 57 "ext/dtext/dtext.cpp.rl"
	{
  sm->b2 = sm->p;
}
#line 210 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{ append_dmail_key_link(sm); }}
	goto st718;
tr893:
#line 49 "ext/dtext/dtext.cpp.rl"
	{
  sm->a2 = sm->p;
}
#line 189 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{ append_id_link(sm, "favgroup", "favorite-group", "/favorite_groups/"); }}
	goto st718;
tr895:
#line 49 "ext/dtext/dtext.cpp.rl"
	{
  sm->a2 = sm->p;
}
#line 192 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{ append_id_link(sm, "feedback", "user-feedback", "/user_feedbacks/"); }}
	goto st718;
tr897:
#line 49 "ext/dtext/dtext.cpp.rl"
	{
  sm->a2 = sm->p;
}
#line 176 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{ append_id_link(sm, "flag", "post-flag", "/post_flags/"); }}
	goto st718;
tr899:
#line 49 "ext/dtext/dtext.cpp.rl"
	{
  sm->a2 = sm->p;
}
#line 178 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{ append_id_link(sm, "forum", "forum-post", "/forum_posts/"); }}
	goto st718;
tr902:
#line 49 "ext/dtext/dtext.cpp.rl"
	{
  sm->a2 = sm->p;
}
#line 208 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{ append_id_link(sm, "gelbooru", "gelbooru", "https://gelbooru.com/index.php?page=post&s=view&id="); }}
	goto st718;
tr905:
#line 258 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    const char* match_end = sm->te - 1;
    const char* url_start = sm->ts;
    const char* url_end = find_boundary_c(match_end);

    append_unnamed_url(sm, url_start, url_end);

    if (url_end < match_end) {
      append_segment_html_escaped(sm, url_end + 1, match_end);
    }
  }}
	goto st718;
tr908:
#line 49 "ext/dtext/dtext.cpp.rl"
	{
  sm->a2 = sm->p;
}
#line 188 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{ append_id_link(sm, "implication", "tag-implication", "/tag_implications/"); }}
	goto st718;
tr910:
#line 49 "ext/dtext/dtext.cpp.rl"
	{
  sm->a2 = sm->p;
}
#line 195 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{ append_id_link(sm, "issue", "github", "https://github.com/danbooru/danbooru/issues/"); }}
	goto st718;
tr913:
#line 49 "ext/dtext/dtext.cpp.rl"
	{
  sm->a2 = sm->p;
}
#line 190 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{ append_id_link(sm, "mod action", "mod-action", "/mod_actions/"); }}
	goto st718;
tr915:
#line 49 "ext/dtext/dtext.cpp.rl"
	{
  sm->a2 = sm->p;
}
#line 191 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{ append_id_link(sm, "modreport", "moderation-report", "/moderation_reports/"); }}
	goto st718;
tr919:
#line 49 "ext/dtext/dtext.cpp.rl"
	{
  sm->a2 = sm->p;
}
#line 200 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{ append_id_link(sm, "nijie", "nijie", "https://nijie.info/view.php?id="); }}
	goto st718;
tr921:
#line 49 "ext/dtext/dtext.cpp.rl"
	{
  sm->a2 = sm->p;
}
#line 177 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{ append_id_link(sm, "note", "note", "/notes/"); }}
	goto st718;
tr927:
#line 49 "ext/dtext/dtext.cpp.rl"
	{
  sm->a2 = sm->p;
}
#line 201 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{ append_id_link(sm, "pawoo", "pawoo", "https://pawoo.net/web/statuses/"); }}
	goto st718;
tr929:
#line 49 "ext/dtext/dtext.cpp.rl"
	{
  sm->a2 = sm->p;
}
#line 202 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{ append_id_link(sm, "pixiv", "pixiv", "https://www.pixiv.net/artworks/"); }}
	goto st718;
tr932:
#line 57 "ext/dtext/dtext.cpp.rl"
	{
  sm->b2 = sm->p;
}
#line 213 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{ append_paged_link(sm, "pixiv #", "<a rel=\"external nofollow noreferrer\" class=\"dtext-link dtext-id-link dtext-pixiv-id-link\" href=\"", "https://www.pixiv.net/artworks/", "#"); }}
	goto st718;
tr934:
#line 49 "ext/dtext/dtext.cpp.rl"
	{
  sm->a2 = sm->p;
}
#line 182 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{ append_id_link(sm, "pool", "pool", "/pools/"); }}
	goto st718;
tr936:
#line 49 "ext/dtext/dtext.cpp.rl"
	{
  sm->a2 = sm->p;
}
#line 174 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{ append_id_link(sm, "post", "post", "/posts/"); }}
	goto st718;
tr938:
#line 49 "ext/dtext/dtext.cpp.rl"
	{
  sm->a2 = sm->p;
}
#line 196 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{ append_id_link(sm, "pull", "github-pull", "https://github.com/danbooru/danbooru/pull/"); }}
	goto st718;
tr942:
#line 49 "ext/dtext/dtext.cpp.rl"
	{
  sm->a2 = sm->p;
}
#line 207 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{ append_id_link(sm, "sankaku", "sankaku", "https://chan.sankakucomplex.com/post/show/"); }}
	goto st718;
tr944:
#line 49 "ext/dtext/dtext.cpp.rl"
	{
  sm->a2 = sm->p;
}
#line 203 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{ append_id_link(sm, "seiga", "seiga", "https://seiga.nicovideo.jp/seiga/im"); }}
	goto st718;
tr948:
#line 49 "ext/dtext/dtext.cpp.rl"
	{
  sm->a2 = sm->p;
}
#line 179 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{ append_id_link(sm, "topic", "forum-topic", "/forum_topics/"); }}
	goto st718;
tr951:
#line 57 "ext/dtext/dtext.cpp.rl"
	{
  sm->b2 = sm->p;
}
#line 212 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{ append_paged_link(sm, "topic #", "<a class=\"dtext-link dtext-id-link dtext-forum-topic-id-link\" href=\"", "/forum_topics/", "?page="); }}
	goto st718;
tr953:
#line 49 "ext/dtext/dtext.cpp.rl"
	{
  sm->a2 = sm->p;
}
#line 204 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{ append_id_link(sm, "twitter", "twitter", "https://twitter.com/i/web/status/"); }}
	goto st718;
tr956:
#line 49 "ext/dtext/dtext.cpp.rl"
	{
  sm->a2 = sm->p;
}
#line 183 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{ append_id_link(sm, "user", "user", "/users/"); }}
	goto st718;
tr959:
#line 49 "ext/dtext/dtext.cpp.rl"
	{
  sm->a2 = sm->p;
}
#line 193 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{ append_id_link(sm, "wiki", "wiki-page", "/wiki_pages/"); }}
	goto st718;
tr962:
#line 49 "ext/dtext/dtext.cpp.rl"
	{
  sm->a2 = sm->p;
}
#line 206 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{ append_id_link(sm, "yandere", "yandere", "https://yande.re/post/show/"); }}
	goto st718;
st718:
#line 1 "NONE"
	{( sm->ts) = 0;}
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof718;
case 718:
#line 1 "NONE"
	{( sm->ts) = ( sm->p);}
#line 4438 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr795;
		case 10: goto tr796;
		case 13: goto st725;
		case 34: goto tr798;
		case 60: goto tr800;
		case 64: goto st735;
		case 65: goto tr802;
		case 66: goto tr803;
		case 67: goto tr804;
		case 68: goto tr805;
		case 70: goto tr806;
		case 71: goto tr807;
		case 72: goto tr808;
		case 73: goto tr809;
		case 77: goto tr810;
		case 78: goto tr811;
		case 80: goto tr812;
		case 83: goto tr813;
		case 84: goto tr814;
		case 85: goto tr815;
		case 87: goto tr816;
		case 89: goto tr817;
		case 91: goto tr818;
		case 97: goto tr802;
		case 98: goto tr803;
		case 99: goto tr804;
		case 100: goto tr805;
		case 102: goto tr806;
		case 103: goto tr807;
		case 104: goto tr808;
		case 105: goto tr809;
		case 109: goto tr810;
		case 110: goto tr811;
		case 112: goto tr812;
		case 115: goto tr813;
		case 116: goto tr814;
		case 117: goto tr815;
		case 119: goto tr816;
		case 121: goto tr817;
		case 123: goto tr819;
	}
	if ( (*( sm->p)) < 69 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr799;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 101 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr799;
	} else
		goto tr799;
	goto tr794;
tr795:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 464 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 83;}
	goto st719;
st719:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof719;
case 719:
#line 4500 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto st144;
		case 9: goto st145;
		case 10: goto st144;
		case 13: goto st154;
		case 32: goto st145;
		case 60: goto st146;
		case 91: goto st151;
	}
	goto tr820;
st144:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof144;
case 144:
	switch( (*( sm->p)) ) {
		case 0: goto st144;
		case 9: goto st145;
		case 10: goto st144;
		case 13: goto st154;
		case 32: goto st145;
		case 60: goto st146;
		case 91: goto st151;
	}
	goto tr148;
st145:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof145;
case 145:
	switch( (*( sm->p)) ) {
		case 9: goto st145;
		case 32: goto st145;
		case 60: goto st146;
		case 91: goto st151;
	}
	goto tr148;
st146:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof146;
case 146:
	switch( (*( sm->p)) ) {
		case 72: goto st147;
		case 104: goto st147;
	}
	goto tr148;
st147:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof147;
case 147:
	switch( (*( sm->p)) ) {
		case 82: goto st148;
		case 114: goto st148;
	}
	goto tr148;
st148:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof148;
case 148:
	if ( (*( sm->p)) == 62 )
		goto st149;
	goto tr148;
st149:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof149;
case 149:
	switch( (*( sm->p)) ) {
		case 0: goto tr157;
		case 9: goto st149;
		case 10: goto tr157;
		case 13: goto st150;
		case 32: goto st149;
	}
	goto tr148;
tr157:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 426 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 79;}
	goto st720;
st720:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof720;
case 720:
#line 4583 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr157;
		case 10: goto tr157;
		case 13: goto st150;
	}
	goto tr821;
st150:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof150;
case 150:
	if ( (*( sm->p)) == 10 )
		goto tr157;
	goto tr148;
st151:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof151;
case 151:
	switch( (*( sm->p)) ) {
		case 72: goto st152;
		case 104: goto st152;
	}
	goto tr148;
st152:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof152;
case 152:
	switch( (*( sm->p)) ) {
		case 82: goto st153;
		case 114: goto st153;
	}
	goto tr148;
st153:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof153;
case 153:
	if ( (*( sm->p)) == 93 )
		goto st149;
	goto tr148;
st154:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof154;
case 154:
	if ( (*( sm->p)) == 10 )
		goto st144;
	goto tr148;
tr796:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 448 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 81;}
	goto st721;
st721:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof721;
case 721:
#line 4639 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto st144;
		case 9: goto st145;
		case 10: goto tr161;
		case 13: goto st155;
		case 32: goto st145;
		case 42: goto tr824;
		case 60: goto st146;
		case 91: goto st151;
	}
	goto tr822;
tr161:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 439 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 80;}
	goto st722;
st722:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof722;
case 722:
#line 4661 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto st144;
		case 9: goto st145;
		case 10: goto tr161;
		case 13: goto st155;
		case 32: goto st145;
		case 60: goto st146;
		case 91: goto st151;
	}
	goto tr825;
st155:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof155;
case 155:
	if ( (*( sm->p)) == 10 )
		goto tr161;
	goto tr148;
tr824:
#line 45 "ext/dtext/dtext.cpp.rl"
	{
  sm->a1 = sm->p;
}
	goto st156;
st156:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof156;
case 156:
#line 4689 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto tr163;
		case 32: goto tr163;
		case 42: goto st156;
	}
	goto tr162;
tr163:
#line 49 "ext/dtext/dtext.cpp.rl"
	{
  sm->a2 = sm->p;
}
	goto st157;
st157:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof157;
case 157:
#line 4706 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto tr166;
		case 10: goto tr162;
		case 13: goto tr162;
		case 32: goto tr166;
	}
	goto tr165;
tr165:
#line 53 "ext/dtext/dtext.cpp.rl"
	{
  sm->b1 = sm->p;
}
	goto st723;
st723:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof723;
case 723:
#line 4724 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 10: goto tr826;
		case 13: goto tr826;
	}
	goto st723;
tr166:
#line 53 "ext/dtext/dtext.cpp.rl"
	{
  sm->b1 = sm->p;
}
	goto st724;
st724:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof724;
case 724:
#line 4740 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto tr166;
		case 10: goto tr826;
		case 13: goto tr826;
		case 32: goto tr166;
	}
	goto tr165;
st725:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof725;
case 725:
	if ( (*( sm->p)) == 10 )
		goto tr796;
	goto tr828;
tr798:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
	goto st726;
st726:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof726;
case 726:
#line 4763 "ext/dtext/dtext.cpp"
	if ( (*( sm->p)) == 34 )
		goto tr829;
	goto tr830;
tr830:
#line 45 "ext/dtext/dtext.cpp.rl"
	{
  sm->a1 = sm->p;
}
	goto st158;
st158:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof158;
case 158:
#line 4777 "ext/dtext/dtext.cpp"
	if ( (*( sm->p)) == 34 )
		goto tr169;
	goto st158;
tr169:
#line 49 "ext/dtext/dtext.cpp.rl"
	{
  sm->a2 = sm->p;
}
	goto st159;
st159:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof159;
case 159:
#line 4791 "ext/dtext/dtext.cpp"
	if ( (*( sm->p)) == 58 )
		goto st160;
	goto tr167;
st160:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof160;
case 160:
	switch( (*( sm->p)) ) {
		case 35: goto tr171;
		case 47: goto tr171;
		case 72: goto tr172;
		case 91: goto st169;
		case 104: goto tr172;
	}
	goto tr167;
tr181:
#line 57 "ext/dtext/dtext.cpp.rl"
	{
  sm->b2 = sm->p;
}
	goto st727;
tr171:
#line 53 "ext/dtext/dtext.cpp.rl"
	{
  sm->b1 = sm->p;
}
#line 57 "ext/dtext/dtext.cpp.rl"
	{
  sm->b2 = sm->p;
}
	goto st727;
st727:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof727;
case 727:
#line 4827 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr831;
		case 32: goto tr831;
	}
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr831;
	goto tr181;
tr172:
#line 53 "ext/dtext/dtext.cpp.rl"
	{
  sm->b1 = sm->p;
}
	goto st161;
st161:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof161;
case 161:
#line 4845 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 84: goto st162;
		case 116: goto st162;
	}
	goto tr167;
st162:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof162;
case 162:
	switch( (*( sm->p)) ) {
		case 84: goto st163;
		case 116: goto st163;
	}
	goto tr167;
st163:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof163;
case 163:
	switch( (*( sm->p)) ) {
		case 80: goto st164;
		case 112: goto st164;
	}
	goto tr167;
st164:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof164;
case 164:
	switch( (*( sm->p)) ) {
		case 58: goto st165;
		case 83: goto st168;
		case 115: goto st168;
	}
	goto tr167;
st165:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof165;
case 165:
	if ( (*( sm->p)) == 47 )
		goto st166;
	goto tr167;
st166:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof166;
case 166:
	if ( (*( sm->p)) == 47 )
		goto st167;
	goto tr167;
st167:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof167;
case 167:
	switch( (*( sm->p)) ) {
		case 0: goto tr167;
		case 32: goto tr167;
	}
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr167;
	goto tr181;
st168:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof168;
case 168:
	if ( (*( sm->p)) == 58 )
		goto st165;
	goto tr167;
st169:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof169;
case 169:
	switch( (*( sm->p)) ) {
		case 35: goto tr182;
		case 47: goto tr182;
		case 72: goto tr183;
		case 104: goto tr183;
	}
	goto tr167;
tr184:
#line 57 "ext/dtext/dtext.cpp.rl"
	{
  sm->b2 = sm->p;
}
	goto st170;
tr182:
#line 53 "ext/dtext/dtext.cpp.rl"
	{
  sm->b1 = sm->p;
}
#line 57 "ext/dtext/dtext.cpp.rl"
	{
  sm->b2 = sm->p;
}
	goto st170;
st170:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof170;
case 170:
#line 4942 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr167;
		case 32: goto tr167;
		case 93: goto tr185;
	}
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr167;
	goto tr184;
tr183:
#line 53 "ext/dtext/dtext.cpp.rl"
	{
  sm->b1 = sm->p;
}
	goto st171;
st171:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof171;
case 171:
#line 4961 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 84: goto st172;
		case 116: goto st172;
	}
	goto tr167;
st172:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof172;
case 172:
	switch( (*( sm->p)) ) {
		case 84: goto st173;
		case 116: goto st173;
	}
	goto tr167;
st173:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof173;
case 173:
	switch( (*( sm->p)) ) {
		case 80: goto st174;
		case 112: goto st174;
	}
	goto tr167;
st174:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof174;
case 174:
	switch( (*( sm->p)) ) {
		case 58: goto st175;
		case 83: goto st178;
		case 115: goto st178;
	}
	goto tr167;
st175:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof175;
case 175:
	if ( (*( sm->p)) == 47 )
		goto st176;
	goto tr167;
st176:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof176;
case 176:
	if ( (*( sm->p)) == 47 )
		goto st177;
	goto tr167;
st177:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof177;
case 177:
	switch( (*( sm->p)) ) {
		case 0: goto tr167;
		case 32: goto tr167;
	}
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr167;
	goto tr184;
st178:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof178;
case 178:
	if ( (*( sm->p)) == 58 )
		goto st175;
	goto tr167;
tr799:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 45 "ext/dtext/dtext.cpp.rl"
	{
  sm->a1 = sm->p;
}
	goto st728;
st728:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof728;
case 728:
#line 5039 "ext/dtext/dtext.cpp"
	if ( (*( sm->p)) == 91 )
		goto tr194;
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st179;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st179;
	} else
		goto st179;
	goto tr829;
st179:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof179;
case 179:
	if ( (*( sm->p)) == 91 )
		goto tr194;
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st179;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st179;
	} else
		goto st179;
	goto tr167;
tr194:
#line 49 "ext/dtext/dtext.cpp.rl"
	{
  sm->a2 = sm->p;
}
	goto st180;
st180:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof180;
case 180:
#line 5076 "ext/dtext/dtext.cpp"
	if ( (*( sm->p)) == 91 )
		goto st181;
	goto tr167;
st181:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof181;
case 181:
	switch( (*( sm->p)) ) {
		case 93: goto tr167;
		case 124: goto tr197;
	}
	goto tr196;
tr196:
#line 53 "ext/dtext/dtext.cpp.rl"
	{
  sm->b1 = sm->p;
}
	goto st182;
st182:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof182;
case 182:
#line 5099 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 93: goto tr199;
		case 124: goto tr200;
	}
	goto st182;
tr199:
#line 57 "ext/dtext/dtext.cpp.rl"
	{
  sm->b2 = sm->p;
}
	goto st183;
st183:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof183;
case 183:
#line 5115 "ext/dtext/dtext.cpp"
	if ( (*( sm->p)) == 93 )
		goto st729;
	goto tr167;
st729:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof729;
case 729:
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr833;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr833;
	} else
		goto tr833;
	goto tr832;
tr833:
#line 61 "ext/dtext/dtext.cpp.rl"
	{
  sm->c1 = sm->p;
}
	goto st730;
st730:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof730;
case 730:
#line 5142 "ext/dtext/dtext.cpp"
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st730;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st730;
	} else
		goto st730;
	goto tr834;
tr200:
#line 57 "ext/dtext/dtext.cpp.rl"
	{
  sm->b2 = sm->p;
}
	goto st184;
st184:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof184;
case 184:
#line 5162 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 93: goto tr203;
		case 124: goto tr167;
	}
	goto tr202;
tr202:
#line 61 "ext/dtext/dtext.cpp.rl"
	{
  sm->c1 = sm->p;
}
	goto st185;
st185:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof185;
case 185:
#line 5178 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 93: goto tr205;
		case 124: goto tr167;
	}
	goto st185;
tr203:
#line 61 "ext/dtext/dtext.cpp.rl"
	{
  sm->c1 = sm->p;
}
#line 65 "ext/dtext/dtext.cpp.rl"
	{
  sm->c2 = sm->p;
}
	goto st186;
tr205:
#line 65 "ext/dtext/dtext.cpp.rl"
	{
  sm->c2 = sm->p;
}
	goto st186;
st186:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof186;
case 186:
#line 5204 "ext/dtext/dtext.cpp"
	if ( (*( sm->p)) == 93 )
		goto st731;
	goto tr167;
st731:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof731;
case 731:
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr837;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr837;
	} else
		goto tr837;
	goto tr836;
tr837:
#line 69 "ext/dtext/dtext.cpp.rl"
	{
  sm->d1 = sm->p;
}
	goto st732;
st732:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof732;
case 732:
#line 5231 "ext/dtext/dtext.cpp"
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st732;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st732;
	} else
		goto st732;
	goto tr838;
tr197:
#line 53 "ext/dtext/dtext.cpp.rl"
	{
  sm->b1 = sm->p;
}
	goto st187;
st187:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof187;
case 187:
#line 5251 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 93: goto tr199;
		case 124: goto tr167;
	}
	goto st187;
tr800:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
	goto st733;
st733:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof733;
case 733:
#line 5265 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 47: goto st188;
		case 64: goto st224;
		case 65: goto st226;
		case 66: goto st249;
		case 67: goto st259;
		case 69: goto st263;
		case 72: goto st270;
		case 73: goto st264;
		case 78: goto st279;
		case 81: goto st254;
		case 83: goto st286;
		case 84: goto st299;
		case 85: goto st301;
		case 97: goto st226;
		case 98: goto st249;
		case 99: goto st259;
		case 101: goto st263;
		case 104: goto st270;
		case 105: goto st264;
		case 110: goto st279;
		case 113: goto st254;
		case 115: goto st286;
		case 116: goto st299;
		case 117: goto st301;
	}
	goto tr829;
st188:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof188;
case 188:
	switch( (*( sm->p)) ) {
		case 66: goto st189;
		case 69: goto st199;
		case 73: goto st200;
		case 81: goto st194;
		case 83: goto st206;
		case 84: goto st219;
		case 85: goto st223;
		case 98: goto st189;
		case 101: goto st199;
		case 105: goto st200;
		case 113: goto st194;
		case 115: goto st206;
		case 116: goto st219;
		case 117: goto st223;
	}
	goto tr167;
st189:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof189;
case 189:
	switch( (*( sm->p)) ) {
		case 62: goto tr215;
		case 76: goto st190;
		case 108: goto st190;
	}
	goto tr167;
st190:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof190;
case 190:
	switch( (*( sm->p)) ) {
		case 79: goto st191;
		case 111: goto st191;
	}
	goto tr167;
st191:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof191;
case 191:
	switch( (*( sm->p)) ) {
		case 67: goto st192;
		case 99: goto st192;
	}
	goto tr167;
st192:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof192;
case 192:
	switch( (*( sm->p)) ) {
		case 75: goto st193;
		case 107: goto st193;
	}
	goto tr167;
st193:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof193;
case 193:
	switch( (*( sm->p)) ) {
		case 81: goto st194;
		case 113: goto st194;
	}
	goto tr167;
st194:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof194;
case 194:
	switch( (*( sm->p)) ) {
		case 85: goto st195;
		case 117: goto st195;
	}
	goto tr167;
st195:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof195;
case 195:
	switch( (*( sm->p)) ) {
		case 79: goto st196;
		case 111: goto st196;
	}
	goto tr167;
st196:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof196;
case 196:
	switch( (*( sm->p)) ) {
		case 84: goto st197;
		case 116: goto st197;
	}
	goto tr167;
st197:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof197;
case 197:
	switch( (*( sm->p)) ) {
		case 69: goto st198;
		case 101: goto st198;
	}
	goto tr167;
st198:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof198;
case 198:
	if ( (*( sm->p)) == 62 )
		goto st734;
	goto tr167;
st734:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof734;
case 734:
	if ( (*( sm->p)) == 32 )
		goto st734;
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto st734;
	goto tr851;
st199:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof199;
case 199:
	switch( (*( sm->p)) ) {
		case 77: goto st200;
		case 88: goto st201;
		case 109: goto st200;
		case 120: goto st201;
	}
	goto tr167;
st200:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof200;
case 200:
	if ( (*( sm->p)) == 62 )
		goto tr226;
	goto tr167;
st201:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof201;
case 201:
	switch( (*( sm->p)) ) {
		case 80: goto st202;
		case 112: goto st202;
	}
	goto tr167;
st202:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof202;
case 202:
	switch( (*( sm->p)) ) {
		case 65: goto st203;
		case 97: goto st203;
	}
	goto tr167;
st203:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof203;
case 203:
	switch( (*( sm->p)) ) {
		case 78: goto st204;
		case 110: goto st204;
	}
	goto tr167;
st204:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof204;
case 204:
	switch( (*( sm->p)) ) {
		case 68: goto st205;
		case 100: goto st205;
	}
	goto tr167;
st205:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof205;
case 205:
	if ( (*( sm->p)) == 62 )
		goto tr231;
	goto tr167;
st206:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof206;
case 206:
	switch( (*( sm->p)) ) {
		case 62: goto tr232;
		case 80: goto st207;
		case 84: goto st214;
		case 112: goto st207;
		case 116: goto st214;
	}
	goto tr167;
st207:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof207;
case 207:
	switch( (*( sm->p)) ) {
		case 79: goto st208;
		case 111: goto st208;
	}
	goto tr167;
st208:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof208;
case 208:
	switch( (*( sm->p)) ) {
		case 73: goto st209;
		case 105: goto st209;
	}
	goto tr167;
st209:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof209;
case 209:
	switch( (*( sm->p)) ) {
		case 76: goto st210;
		case 108: goto st210;
	}
	goto tr167;
st210:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof210;
case 210:
	switch( (*( sm->p)) ) {
		case 69: goto st211;
		case 101: goto st211;
	}
	goto tr167;
st211:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof211;
case 211:
	switch( (*( sm->p)) ) {
		case 82: goto st212;
		case 114: goto st212;
	}
	goto tr167;
st212:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof212;
case 212:
	switch( (*( sm->p)) ) {
		case 62: goto tr240;
		case 83: goto st213;
		case 115: goto st213;
	}
	goto tr167;
st213:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof213;
case 213:
	if ( (*( sm->p)) == 62 )
		goto tr240;
	goto tr167;
st214:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof214;
case 214:
	switch( (*( sm->p)) ) {
		case 82: goto st215;
		case 114: goto st215;
	}
	goto tr167;
st215:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof215;
case 215:
	switch( (*( sm->p)) ) {
		case 79: goto st216;
		case 111: goto st216;
	}
	goto tr167;
st216:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof216;
case 216:
	switch( (*( sm->p)) ) {
		case 78: goto st217;
		case 110: goto st217;
	}
	goto tr167;
st217:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof217;
case 217:
	switch( (*( sm->p)) ) {
		case 71: goto st218;
		case 103: goto st218;
	}
	goto tr167;
st218:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof218;
case 218:
	if ( (*( sm->p)) == 62 )
		goto tr215;
	goto tr167;
st219:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof219;
case 219:
	switch( (*( sm->p)) ) {
		case 68: goto st220;
		case 72: goto st221;
		case 78: goto st222;
		case 100: goto st220;
		case 104: goto st221;
		case 110: goto st222;
	}
	goto tr167;
st220:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof220;
case 220:
	if ( (*( sm->p)) == 62 )
		goto tr249;
	goto tr167;
st221:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof221;
case 221:
	if ( (*( sm->p)) == 62 )
		goto tr250;
	goto tr167;
st222:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof222;
case 222:
	if ( (*( sm->p)) == 62 )
		goto tr251;
	goto tr167;
st223:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof223;
case 223:
	if ( (*( sm->p)) == 62 )
		goto tr252;
	goto tr167;
st224:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof224;
case 224:
	switch( (*( sm->p)) ) {
		case 0: goto tr167;
		case 32: goto tr167;
	}
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr167;
	goto tr253;
tr253:
#line 45 "ext/dtext/dtext.cpp.rl"
	{
  sm->a1 = sm->p;
}
	goto st225;
st225:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof225;
case 225:
#line 5652 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr167;
		case 32: goto tr167;
		case 62: goto tr255;
	}
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr167;
	goto st225;
st226:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof226;
case 226:
	switch( (*( sm->p)) ) {
		case 9: goto st227;
		case 32: goto st227;
	}
	goto tr167;
st227:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof227;
case 227:
	switch( (*( sm->p)) ) {
		case 9: goto st227;
		case 32: goto st227;
		case 72: goto st228;
		case 104: goto st228;
	}
	goto tr167;
st228:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof228;
case 228:
	switch( (*( sm->p)) ) {
		case 82: goto st229;
		case 114: goto st229;
	}
	goto tr167;
st229:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof229;
case 229:
	switch( (*( sm->p)) ) {
		case 69: goto st230;
		case 101: goto st230;
	}
	goto tr167;
st230:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof230;
case 230:
	switch( (*( sm->p)) ) {
		case 70: goto st231;
		case 102: goto st231;
	}
	goto tr167;
st231:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof231;
case 231:
	if ( (*( sm->p)) == 61 )
		goto st232;
	goto tr167;
st232:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof232;
case 232:
	if ( (*( sm->p)) == 34 )
		goto st233;
	goto tr167;
st233:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof233;
case 233:
	switch( (*( sm->p)) ) {
		case 35: goto tr263;
		case 47: goto tr263;
		case 72: goto tr264;
		case 104: goto tr264;
	}
	goto tr167;
tr263:
#line 45 "ext/dtext/dtext.cpp.rl"
	{
  sm->a1 = sm->p;
}
	goto st234;
st234:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof234;
case 234:
#line 5743 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr167;
		case 32: goto tr167;
		case 34: goto tr266;
	}
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr167;
	goto st234;
tr266:
#line 49 "ext/dtext/dtext.cpp.rl"
	{
  sm->a2 = sm->p;
}
	goto st235;
st235:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof235;
case 235:
#line 5762 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr167;
		case 32: goto tr167;
		case 34: goto tr266;
		case 62: goto st236;
	}
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr167;
	goto st234;
st236:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof236;
case 236:
	switch( (*( sm->p)) ) {
		case 10: goto tr167;
		case 13: goto tr167;
	}
	goto tr268;
tr268:
#line 53 "ext/dtext/dtext.cpp.rl"
	{
  sm->b1 = sm->p;
}
	goto st237;
st237:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof237;
case 237:
#line 5791 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 10: goto tr167;
		case 13: goto tr167;
		case 60: goto tr270;
	}
	goto st237;
tr270:
#line 57 "ext/dtext/dtext.cpp.rl"
	{
  sm->b2 = sm->p;
}
	goto st238;
st238:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof238;
case 238:
#line 5808 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 10: goto tr167;
		case 13: goto tr167;
		case 47: goto st239;
		case 60: goto tr270;
	}
	goto st237;
st239:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof239;
case 239:
	switch( (*( sm->p)) ) {
		case 10: goto tr167;
		case 13: goto tr167;
		case 60: goto tr270;
		case 65: goto st240;
		case 97: goto st240;
	}
	goto st237;
st240:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof240;
case 240:
	switch( (*( sm->p)) ) {
		case 10: goto tr167;
		case 13: goto tr167;
		case 60: goto tr270;
		case 62: goto tr273;
	}
	goto st237;
tr264:
#line 45 "ext/dtext/dtext.cpp.rl"
	{
  sm->a1 = sm->p;
}
	goto st241;
st241:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof241;
case 241:
#line 5849 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 84: goto st242;
		case 116: goto st242;
	}
	goto tr167;
st242:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof242;
case 242:
	switch( (*( sm->p)) ) {
		case 84: goto st243;
		case 116: goto st243;
	}
	goto tr167;
st243:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof243;
case 243:
	switch( (*( sm->p)) ) {
		case 80: goto st244;
		case 112: goto st244;
	}
	goto tr167;
st244:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof244;
case 244:
	switch( (*( sm->p)) ) {
		case 58: goto st245;
		case 83: goto st248;
		case 115: goto st248;
	}
	goto tr167;
st245:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof245;
case 245:
	if ( (*( sm->p)) == 47 )
		goto st246;
	goto tr167;
st246:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof246;
case 246:
	if ( (*( sm->p)) == 47 )
		goto st247;
	goto tr167;
st247:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof247;
case 247:
	switch( (*( sm->p)) ) {
		case 0: goto tr167;
		case 32: goto tr167;
	}
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr167;
	goto st234;
st248:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof248;
case 248:
	if ( (*( sm->p)) == 58 )
		goto st245;
	goto tr167;
st249:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof249;
case 249:
	switch( (*( sm->p)) ) {
		case 62: goto tr281;
		case 76: goto st250;
		case 108: goto st250;
	}
	goto tr167;
st250:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof250;
case 250:
	switch( (*( sm->p)) ) {
		case 79: goto st251;
		case 111: goto st251;
	}
	goto tr167;
st251:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof251;
case 251:
	switch( (*( sm->p)) ) {
		case 67: goto st252;
		case 99: goto st252;
	}
	goto tr167;
st252:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof252;
case 252:
	switch( (*( sm->p)) ) {
		case 75: goto st253;
		case 107: goto st253;
	}
	goto tr167;
st253:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof253;
case 253:
	switch( (*( sm->p)) ) {
		case 81: goto st254;
		case 113: goto st254;
	}
	goto tr167;
st254:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof254;
case 254:
	switch( (*( sm->p)) ) {
		case 85: goto st255;
		case 117: goto st255;
	}
	goto tr167;
st255:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof255;
case 255:
	switch( (*( sm->p)) ) {
		case 79: goto st256;
		case 111: goto st256;
	}
	goto tr167;
st256:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof256;
case 256:
	switch( (*( sm->p)) ) {
		case 84: goto st257;
		case 116: goto st257;
	}
	goto tr167;
st257:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof257;
case 257:
	switch( (*( sm->p)) ) {
		case 69: goto st258;
		case 101: goto st258;
	}
	goto tr167;
st258:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof258;
case 258:
	if ( (*( sm->p)) == 62 )
		goto tr291;
	goto tr167;
st259:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof259;
case 259:
	switch( (*( sm->p)) ) {
		case 79: goto st260;
		case 111: goto st260;
	}
	goto tr167;
st260:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof260;
case 260:
	switch( (*( sm->p)) ) {
		case 68: goto st261;
		case 100: goto st261;
	}
	goto tr167;
st261:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof261;
case 261:
	switch( (*( sm->p)) ) {
		case 69: goto st262;
		case 101: goto st262;
	}
	goto tr167;
st262:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof262;
case 262:
	if ( (*( sm->p)) == 62 )
		goto tr295;
	goto tr167;
st263:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof263;
case 263:
	switch( (*( sm->p)) ) {
		case 77: goto st264;
		case 88: goto st265;
		case 109: goto st264;
		case 120: goto st265;
	}
	goto tr167;
st264:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof264;
case 264:
	if ( (*( sm->p)) == 62 )
		goto tr298;
	goto tr167;
st265:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof265;
case 265:
	switch( (*( sm->p)) ) {
		case 80: goto st266;
		case 112: goto st266;
	}
	goto tr167;
st266:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof266;
case 266:
	switch( (*( sm->p)) ) {
		case 65: goto st267;
		case 97: goto st267;
	}
	goto tr167;
st267:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof267;
case 267:
	switch( (*( sm->p)) ) {
		case 78: goto st268;
		case 110: goto st268;
	}
	goto tr167;
st268:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof268;
case 268:
	switch( (*( sm->p)) ) {
		case 68: goto st269;
		case 100: goto st269;
	}
	goto tr167;
st269:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof269;
case 269:
	if ( (*( sm->p)) == 62 )
		goto tr303;
	goto tr167;
st270:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof270;
case 270:
	switch( (*( sm->p)) ) {
		case 84: goto st271;
		case 116: goto st271;
	}
	goto tr167;
st271:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof271;
case 271:
	switch( (*( sm->p)) ) {
		case 84: goto st272;
		case 116: goto st272;
	}
	goto tr167;
st272:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof272;
case 272:
	switch( (*( sm->p)) ) {
		case 80: goto st273;
		case 112: goto st273;
	}
	goto tr167;
st273:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof273;
case 273:
	switch( (*( sm->p)) ) {
		case 58: goto st274;
		case 83: goto st278;
		case 115: goto st278;
	}
	goto tr167;
st274:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof274;
case 274:
	if ( (*( sm->p)) == 47 )
		goto st275;
	goto tr167;
st275:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof275;
case 275:
	if ( (*( sm->p)) == 47 )
		goto st276;
	goto tr167;
st276:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof276;
case 276:
	switch( (*( sm->p)) ) {
		case 0: goto tr167;
		case 32: goto tr167;
	}
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr167;
	goto st277;
st277:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof277;
case 277:
	switch( (*( sm->p)) ) {
		case 0: goto tr167;
		case 32: goto tr167;
		case 62: goto tr312;
	}
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr167;
	goto st277;
st278:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof278;
case 278:
	if ( (*( sm->p)) == 58 )
		goto st274;
	goto tr167;
st279:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof279;
case 279:
	switch( (*( sm->p)) ) {
		case 79: goto st280;
		case 111: goto st280;
	}
	goto tr167;
st280:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof280;
case 280:
	switch( (*( sm->p)) ) {
		case 68: goto st281;
		case 100: goto st281;
	}
	goto tr167;
st281:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof281;
case 281:
	switch( (*( sm->p)) ) {
		case 84: goto st282;
		case 116: goto st282;
	}
	goto tr167;
st282:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof282;
case 282:
	switch( (*( sm->p)) ) {
		case 69: goto st283;
		case 101: goto st283;
	}
	goto tr167;
st283:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof283;
case 283:
	switch( (*( sm->p)) ) {
		case 88: goto st284;
		case 120: goto st284;
	}
	goto tr167;
st284:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof284;
case 284:
	switch( (*( sm->p)) ) {
		case 84: goto st285;
		case 116: goto st285;
	}
	goto tr167;
st285:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof285;
case 285:
	if ( (*( sm->p)) == 62 )
		goto tr319;
	goto tr167;
st286:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof286;
case 286:
	switch( (*( sm->p)) ) {
		case 62: goto tr320;
		case 80: goto st287;
		case 84: goto st294;
		case 112: goto st287;
		case 116: goto st294;
	}
	goto tr167;
st287:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof287;
case 287:
	switch( (*( sm->p)) ) {
		case 79: goto st288;
		case 111: goto st288;
	}
	goto tr167;
st288:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof288;
case 288:
	switch( (*( sm->p)) ) {
		case 73: goto st289;
		case 105: goto st289;
	}
	goto tr167;
st289:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof289;
case 289:
	switch( (*( sm->p)) ) {
		case 76: goto st290;
		case 108: goto st290;
	}
	goto tr167;
st290:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof290;
case 290:
	switch( (*( sm->p)) ) {
		case 69: goto st291;
		case 101: goto st291;
	}
	goto tr167;
st291:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof291;
case 291:
	switch( (*( sm->p)) ) {
		case 82: goto st292;
		case 114: goto st292;
	}
	goto tr167;
st292:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof292;
case 292:
	switch( (*( sm->p)) ) {
		case 62: goto tr328;
		case 83: goto st293;
		case 115: goto st293;
	}
	goto tr167;
st293:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof293;
case 293:
	if ( (*( sm->p)) == 62 )
		goto tr328;
	goto tr167;
st294:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof294;
case 294:
	switch( (*( sm->p)) ) {
		case 82: goto st295;
		case 114: goto st295;
	}
	goto tr167;
st295:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof295;
case 295:
	switch( (*( sm->p)) ) {
		case 79: goto st296;
		case 111: goto st296;
	}
	goto tr167;
st296:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof296;
case 296:
	switch( (*( sm->p)) ) {
		case 78: goto st297;
		case 110: goto st297;
	}
	goto tr167;
st297:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof297;
case 297:
	switch( (*( sm->p)) ) {
		case 71: goto st298;
		case 103: goto st298;
	}
	goto tr167;
st298:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof298;
case 298:
	if ( (*( sm->p)) == 62 )
		goto tr281;
	goto tr167;
st299:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof299;
case 299:
	switch( (*( sm->p)) ) {
		case 78: goto st300;
		case 110: goto st300;
	}
	goto tr167;
st300:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof300;
case 300:
	if ( (*( sm->p)) == 62 )
		goto tr335;
	goto tr167;
st301:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof301;
case 301:
	if ( (*( sm->p)) == 62 )
		goto tr336;
	goto tr167;
st735:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof735;
case 735:
	switch( (*( sm->p)) ) {
		case 0: goto tr829;
		case 32: goto tr829;
	}
	if ( (*( sm->p)) > 13 ) {
		if ( 33 <= (*( sm->p)) && (*( sm->p)) <= 126 )
			goto tr853;
	} else if ( (*( sm->p)) >= 9 )
		goto tr829;
	goto tr852;
tr852:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 45 "ext/dtext/dtext.cpp.rl"
	{
  sm->a1 = sm->p;
}
#line 279 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 56;}
	goto st736;
tr855:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 279 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 56;}
	goto st736;
tr857:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 275 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 55;}
	goto st736;
st736:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof736;
case 736:
#line 6421 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr854;
		case 32: goto tr854;
	}
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr854;
	goto tr855;
tr853:
#line 45 "ext/dtext/dtext.cpp.rl"
	{
  sm->a1 = sm->p;
}
	goto st737;
st737:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof737;
case 737:
#line 6439 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr856;
		case 32: goto tr856;
		case 64: goto tr857;
	}
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr856;
	goto tr855;
tr802:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 45 "ext/dtext/dtext.cpp.rl"
	{
  sm->a1 = sm->p;
}
	goto st738;
st738:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof738;
case 738:
#line 6460 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 76: goto st302;
		case 80: goto st308;
		case 82: goto st315;
		case 91: goto tr194;
		case 108: goto st302;
		case 112: goto st308;
		case 114: goto st315;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st179;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st179;
	} else
		goto st179;
	goto tr829;
st302:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof302;
case 302:
	switch( (*( sm->p)) ) {
		case 73: goto st303;
		case 91: goto tr194;
		case 105: goto st303;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st179;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st179;
	} else
		goto st179;
	goto tr167;
st303:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof303;
case 303:
	switch( (*( sm->p)) ) {
		case 65: goto st304;
		case 91: goto tr194;
		case 97: goto st304;
	}
	if ( (*( sm->p)) < 66 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st179;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 98 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st179;
	} else
		goto st179;
	goto tr167;
st304:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof304;
case 304:
	switch( (*( sm->p)) ) {
		case 83: goto st305;
		case 91: goto tr194;
		case 115: goto st305;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st179;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st179;
	} else
		goto st179;
	goto tr167;
st305:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof305;
case 305:
	switch( (*( sm->p)) ) {
		case 32: goto st306;
		case 91: goto tr194;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st179;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st179;
	} else
		goto st179;
	goto tr167;
st306:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof306;
case 306:
	if ( (*( sm->p)) == 35 )
		goto st307;
	goto tr167;
st307:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof307;
case 307:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr342;
	goto tr167;
tr342:
#line 45 "ext/dtext/dtext.cpp.rl"
	{
  sm->a1 = sm->p;
}
	goto st739;
st739:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof739;
case 739:
#line 6574 "ext/dtext/dtext.cpp"
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto st739;
	goto tr861;
st308:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof308;
case 308:
	switch( (*( sm->p)) ) {
		case 80: goto st309;
		case 91: goto tr194;
		case 112: goto st309;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st179;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st179;
	} else
		goto st179;
	goto tr167;
st309:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof309;
case 309:
	switch( (*( sm->p)) ) {
		case 69: goto st310;
		case 91: goto tr194;
		case 101: goto st310;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st179;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st179;
	} else
		goto st179;
	goto tr167;
st310:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof310;
case 310:
	switch( (*( sm->p)) ) {
		case 65: goto st311;
		case 91: goto tr194;
		case 97: goto st311;
	}
	if ( (*( sm->p)) < 66 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st179;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 98 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st179;
	} else
		goto st179;
	goto tr167;
st311:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof311;
case 311:
	switch( (*( sm->p)) ) {
		case 76: goto st312;
		case 91: goto tr194;
		case 108: goto st312;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st179;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st179;
	} else
		goto st179;
	goto tr167;
st312:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof312;
case 312:
	switch( (*( sm->p)) ) {
		case 32: goto st313;
		case 91: goto tr194;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st179;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st179;
	} else
		goto st179;
	goto tr167;
st313:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof313;
case 313:
	if ( (*( sm->p)) == 35 )
		goto st314;
	goto tr167;
st314:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof314;
case 314:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr349;
	goto tr167;
tr349:
#line 45 "ext/dtext/dtext.cpp.rl"
	{
  sm->a1 = sm->p;
}
	goto st740;
st740:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof740;
case 740:
#line 6691 "ext/dtext/dtext.cpp"
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto st740;
	goto tr863;
st315:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof315;
case 315:
	switch( (*( sm->p)) ) {
		case 84: goto st316;
		case 91: goto tr194;
		case 116: goto st316;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st179;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st179;
	} else
		goto st179;
	goto tr167;
st316:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof316;
case 316:
	switch( (*( sm->p)) ) {
		case 73: goto st317;
		case 83: goto st322;
		case 91: goto tr194;
		case 105: goto st317;
		case 115: goto st322;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st179;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st179;
	} else
		goto st179;
	goto tr167;
st317:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof317;
case 317:
	switch( (*( sm->p)) ) {
		case 83: goto st318;
		case 91: goto tr194;
		case 115: goto st318;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st179;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st179;
	} else
		goto st179;
	goto tr167;
st318:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof318;
case 318:
	switch( (*( sm->p)) ) {
		case 84: goto st319;
		case 91: goto tr194;
		case 116: goto st319;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st179;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st179;
	} else
		goto st179;
	goto tr167;
st319:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof319;
case 319:
	switch( (*( sm->p)) ) {
		case 32: goto st320;
		case 91: goto tr194;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st179;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st179;
	} else
		goto st179;
	goto tr167;
st320:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof320;
case 320:
	if ( (*( sm->p)) == 35 )
		goto st321;
	goto tr167;
st321:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof321;
case 321:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr357;
	goto tr167;
tr357:
#line 45 "ext/dtext/dtext.cpp.rl"
	{
  sm->a1 = sm->p;
}
	goto st741;
st741:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof741;
case 741:
#line 6810 "ext/dtext/dtext.cpp"
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto st741;
	goto tr865;
st322:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof322;
case 322:
	switch( (*( sm->p)) ) {
		case 84: goto st323;
		case 91: goto tr194;
		case 116: goto st323;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st179;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st179;
	} else
		goto st179;
	goto tr167;
st323:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof323;
case 323:
	switch( (*( sm->p)) ) {
		case 65: goto st324;
		case 91: goto tr194;
		case 97: goto st324;
	}
	if ( (*( sm->p)) < 66 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st179;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 98 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st179;
	} else
		goto st179;
	goto tr167;
st324:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof324;
case 324:
	switch( (*( sm->p)) ) {
		case 84: goto st325;
		case 91: goto tr194;
		case 116: goto st325;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st179;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st179;
	} else
		goto st179;
	goto tr167;
st325:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof325;
case 325:
	switch( (*( sm->p)) ) {
		case 73: goto st326;
		case 91: goto tr194;
		case 105: goto st326;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st179;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st179;
	} else
		goto st179;
	goto tr167;
st326:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof326;
case 326:
	switch( (*( sm->p)) ) {
		case 79: goto st327;
		case 91: goto tr194;
		case 111: goto st327;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st179;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st179;
	} else
		goto st179;
	goto tr167;
st327:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof327;
case 327:
	switch( (*( sm->p)) ) {
		case 78: goto st328;
		case 91: goto tr194;
		case 110: goto st328;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st179;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st179;
	} else
		goto st179;
	goto tr167;
st328:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof328;
case 328:
	switch( (*( sm->p)) ) {
		case 32: goto st329;
		case 91: goto tr194;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st179;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st179;
	} else
		goto st179;
	goto tr167;
st329:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof329;
case 329:
	if ( (*( sm->p)) == 35 )
		goto st330;
	goto tr167;
st330:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof330;
case 330:
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr366;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr366;
	} else
		goto tr366;
	goto tr167;
tr366:
#line 45 "ext/dtext/dtext.cpp.rl"
	{
  sm->a1 = sm->p;
}
	goto st742;
st742:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof742;
case 742:
#line 6969 "ext/dtext/dtext.cpp"
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st742;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st742;
	} else
		goto st742;
	goto tr867;
tr803:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 45 "ext/dtext/dtext.cpp.rl"
	{
  sm->a1 = sm->p;
}
	goto st743;
st743:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof743;
case 743:
#line 6991 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 65: goto st331;
		case 85: goto st335;
		case 91: goto tr194;
		case 97: goto st331;
		case 117: goto st335;
	}
	if ( (*( sm->p)) < 66 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st179;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 98 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st179;
	} else
		goto st179;
	goto tr829;
st331:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof331;
case 331:
	switch( (*( sm->p)) ) {
		case 78: goto st332;
		case 91: goto tr194;
		case 110: goto st332;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st179;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st179;
	} else
		goto st179;
	goto tr167;
st332:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof332;
case 332:
	switch( (*( sm->p)) ) {
		case 32: goto st333;
		case 91: goto tr194;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st179;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st179;
	} else
		goto st179;
	goto tr167;
st333:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof333;
case 333:
	if ( (*( sm->p)) == 35 )
		goto st334;
	goto tr167;
st334:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof334;
case 334:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr370;
	goto tr167;
tr370:
#line 45 "ext/dtext/dtext.cpp.rl"
	{
  sm->a1 = sm->p;
}
	goto st744;
st744:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof744;
case 744:
#line 7067 "ext/dtext/dtext.cpp"
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto st744;
	goto tr871;
st335:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof335;
case 335:
	switch( (*( sm->p)) ) {
		case 82: goto st336;
		case 91: goto tr194;
		case 114: goto st336;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st179;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st179;
	} else
		goto st179;
	goto tr167;
st336:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof336;
case 336:
	switch( (*( sm->p)) ) {
		case 32: goto st337;
		case 91: goto tr194;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st179;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st179;
	} else
		goto st179;
	goto tr167;
st337:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof337;
case 337:
	if ( (*( sm->p)) == 35 )
		goto st338;
	goto tr167;
st338:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof338;
case 338:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr374;
	goto tr167;
tr374:
#line 45 "ext/dtext/dtext.cpp.rl"
	{
  sm->a1 = sm->p;
}
	goto st745;
st745:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof745;
case 745:
#line 7130 "ext/dtext/dtext.cpp"
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto st745;
	goto tr873;
tr804:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 45 "ext/dtext/dtext.cpp.rl"
	{
  sm->a1 = sm->p;
}
	goto st746;
st746:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof746;
case 746:
#line 7146 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 79: goto st339;
		case 91: goto tr194;
		case 111: goto st339;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st179;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st179;
	} else
		goto st179;
	goto tr829;
st339:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof339;
case 339:
	switch( (*( sm->p)) ) {
		case 77: goto st340;
		case 91: goto tr194;
		case 109: goto st340;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st179;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st179;
	} else
		goto st179;
	goto tr167;
st340:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof340;
case 340:
	switch( (*( sm->p)) ) {
		case 77: goto st341;
		case 91: goto tr194;
		case 109: goto st341;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st179;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st179;
	} else
		goto st179;
	goto tr167;
st341:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof341;
case 341:
	switch( (*( sm->p)) ) {
		case 69: goto st342;
		case 73: goto st347;
		case 91: goto tr194;
		case 101: goto st342;
		case 105: goto st347;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st179;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st179;
	} else
		goto st179;
	goto tr167;
st342:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof342;
case 342:
	switch( (*( sm->p)) ) {
		case 78: goto st343;
		case 91: goto tr194;
		case 110: goto st343;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st179;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st179;
	} else
		goto st179;
	goto tr167;
st343:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof343;
case 343:
	switch( (*( sm->p)) ) {
		case 84: goto st344;
		case 91: goto tr194;
		case 116: goto st344;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st179;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st179;
	} else
		goto st179;
	goto tr167;
st344:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof344;
case 344:
	switch( (*( sm->p)) ) {
		case 32: goto st345;
		case 91: goto tr194;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st179;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st179;
	} else
		goto st179;
	goto tr167;
st345:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof345;
case 345:
	if ( (*( sm->p)) == 35 )
		goto st346;
	goto tr167;
st346:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof346;
case 346:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr383;
	goto tr167;
tr383:
#line 45 "ext/dtext/dtext.cpp.rl"
	{
  sm->a1 = sm->p;
}
	goto st747;
st747:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof747;
case 747:
#line 7294 "ext/dtext/dtext.cpp"
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto st747;
	goto tr876;
st347:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof347;
case 347:
	switch( (*( sm->p)) ) {
		case 84: goto st348;
		case 91: goto tr194;
		case 116: goto st348;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st179;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st179;
	} else
		goto st179;
	goto tr167;
st348:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof348;
case 348:
	switch( (*( sm->p)) ) {
		case 32: goto st349;
		case 91: goto tr194;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st179;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st179;
	} else
		goto st179;
	goto tr167;
st349:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof349;
case 349:
	if ( (*( sm->p)) == 35 )
		goto st350;
	goto tr167;
st350:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof350;
case 350:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr387;
	goto tr167;
tr387:
#line 45 "ext/dtext/dtext.cpp.rl"
	{
  sm->a1 = sm->p;
}
	goto st748;
st748:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof748;
case 748:
#line 7357 "ext/dtext/dtext.cpp"
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto st748;
	goto tr878;
tr805:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 45 "ext/dtext/dtext.cpp.rl"
	{
  sm->a1 = sm->p;
}
	goto st749;
st749:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof749;
case 749:
#line 7373 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 69: goto st351;
		case 77: goto st362;
		case 91: goto tr194;
		case 101: goto st351;
		case 109: goto st362;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st179;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st179;
	} else
		goto st179;
	goto tr829;
st351:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof351;
case 351:
	switch( (*( sm->p)) ) {
		case 86: goto st352;
		case 91: goto tr194;
		case 118: goto st352;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st179;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st179;
	} else
		goto st179;
	goto tr167;
st352:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof352;
case 352:
	switch( (*( sm->p)) ) {
		case 73: goto st353;
		case 91: goto tr194;
		case 105: goto st353;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st179;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st179;
	} else
		goto st179;
	goto tr167;
st353:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof353;
case 353:
	switch( (*( sm->p)) ) {
		case 65: goto st354;
		case 91: goto tr194;
		case 97: goto st354;
	}
	if ( (*( sm->p)) < 66 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st179;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 98 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st179;
	} else
		goto st179;
	goto tr167;
st354:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof354;
case 354:
	switch( (*( sm->p)) ) {
		case 78: goto st355;
		case 91: goto tr194;
		case 110: goto st355;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st179;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st179;
	} else
		goto st179;
	goto tr167;
st355:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof355;
case 355:
	switch( (*( sm->p)) ) {
		case 84: goto st356;
		case 91: goto tr194;
		case 116: goto st356;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st179;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st179;
	} else
		goto st179;
	goto tr167;
st356:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof356;
case 356:
	switch( (*( sm->p)) ) {
		case 65: goto st357;
		case 91: goto tr194;
		case 97: goto st357;
	}
	if ( (*( sm->p)) < 66 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st179;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 98 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st179;
	} else
		goto st179;
	goto tr167;
st357:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof357;
case 357:
	switch( (*( sm->p)) ) {
		case 82: goto st358;
		case 91: goto tr194;
		case 114: goto st358;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st179;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st179;
	} else
		goto st179;
	goto tr167;
st358:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof358;
case 358:
	switch( (*( sm->p)) ) {
		case 84: goto st359;
		case 91: goto tr194;
		case 116: goto st359;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st179;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st179;
	} else
		goto st179;
	goto tr167;
st359:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof359;
case 359:
	switch( (*( sm->p)) ) {
		case 32: goto st360;
		case 91: goto tr194;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st179;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st179;
	} else
		goto st179;
	goto tr167;
st360:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof360;
case 360:
	if ( (*( sm->p)) == 35 )
		goto st361;
	goto tr167;
st361:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof361;
case 361:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr398;
	goto tr167;
tr398:
#line 45 "ext/dtext/dtext.cpp.rl"
	{
  sm->a1 = sm->p;
}
	goto st750;
st750:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof750;
case 750:
#line 7575 "ext/dtext/dtext.cpp"
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto st750;
	goto tr882;
st362:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof362;
case 362:
	switch( (*( sm->p)) ) {
		case 65: goto st363;
		case 91: goto tr194;
		case 97: goto st363;
	}
	if ( (*( sm->p)) < 66 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st179;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 98 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st179;
	} else
		goto st179;
	goto tr167;
st363:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof363;
case 363:
	switch( (*( sm->p)) ) {
		case 73: goto st364;
		case 91: goto tr194;
		case 105: goto st364;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st179;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st179;
	} else
		goto st179;
	goto tr167;
st364:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof364;
case 364:
	switch( (*( sm->p)) ) {
		case 76: goto st365;
		case 91: goto tr194;
		case 108: goto st365;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st179;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st179;
	} else
		goto st179;
	goto tr167;
st365:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof365;
case 365:
	switch( (*( sm->p)) ) {
		case 32: goto st366;
		case 91: goto tr194;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st179;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st179;
	} else
		goto st179;
	goto tr167;
st366:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof366;
case 366:
	if ( (*( sm->p)) == 35 )
		goto st367;
	goto tr167;
st367:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof367;
case 367:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr404;
	goto tr167;
tr404:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 45 "ext/dtext/dtext.cpp.rl"
	{
  sm->a1 = sm->p;
}
	goto st751;
tr886:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
	goto st751;
st751:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof751;
case 751:
#line 7680 "ext/dtext/dtext.cpp"
	if ( (*( sm->p)) == 47 )
		goto tr885;
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr886;
	goto tr884;
tr885:
#line 49 "ext/dtext/dtext.cpp.rl"
	{
  sm->a2 = sm->p;
}
	goto st368;
st368:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof368;
case 368:
#line 7696 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 45: goto tr406;
		case 61: goto tr406;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr406;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr406;
	} else
		goto tr406;
	goto tr405;
tr406:
#line 53 "ext/dtext/dtext.cpp.rl"
	{
  sm->b1 = sm->p;
}
	goto st752;
st752:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof752;
case 752:
#line 7720 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 45: goto st752;
		case 61: goto st752;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st752;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st752;
	} else
		goto st752;
	goto tr887;
tr806:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 45 "ext/dtext/dtext.cpp.rl"
	{
  sm->a1 = sm->p;
}
	goto st753;
st753:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof753;
case 753:
#line 7746 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 65: goto st369;
		case 69: goto st378;
		case 76: goto st387;
		case 79: goto st392;
		case 91: goto tr194;
		case 97: goto st369;
		case 101: goto st378;
		case 108: goto st387;
		case 111: goto st392;
	}
	if ( (*( sm->p)) < 66 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st179;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 98 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st179;
	} else
		goto st179;
	goto tr829;
st369:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof369;
case 369:
	switch( (*( sm->p)) ) {
		case 86: goto st370;
		case 91: goto tr194;
		case 118: goto st370;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st179;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st179;
	} else
		goto st179;
	goto tr167;
st370:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof370;
case 370:
	switch( (*( sm->p)) ) {
		case 71: goto st371;
		case 91: goto tr194;
		case 103: goto st371;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st179;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st179;
	} else
		goto st179;
	goto tr167;
st371:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof371;
case 371:
	switch( (*( sm->p)) ) {
		case 82: goto st372;
		case 91: goto tr194;
		case 114: goto st372;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st179;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st179;
	} else
		goto st179;
	goto tr167;
st372:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof372;
case 372:
	switch( (*( sm->p)) ) {
		case 79: goto st373;
		case 91: goto tr194;
		case 111: goto st373;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st179;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st179;
	} else
		goto st179;
	goto tr167;
st373:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof373;
case 373:
	switch( (*( sm->p)) ) {
		case 85: goto st374;
		case 91: goto tr194;
		case 117: goto st374;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st179;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st179;
	} else
		goto st179;
	goto tr167;
st374:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof374;
case 374:
	switch( (*( sm->p)) ) {
		case 80: goto st375;
		case 91: goto tr194;
		case 112: goto st375;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st179;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st179;
	} else
		goto st179;
	goto tr167;
st375:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof375;
case 375:
	switch( (*( sm->p)) ) {
		case 32: goto st376;
		case 91: goto tr194;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st179;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st179;
	} else
		goto st179;
	goto tr167;
st376:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof376;
case 376:
	if ( (*( sm->p)) == 35 )
		goto st377;
	goto tr167;
st377:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof377;
case 377:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr415;
	goto tr167;
tr415:
#line 45 "ext/dtext/dtext.cpp.rl"
	{
  sm->a1 = sm->p;
}
	goto st754;
st754:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof754;
case 754:
#line 7916 "ext/dtext/dtext.cpp"
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto st754;
	goto tr893;
st378:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof378;
case 378:
	switch( (*( sm->p)) ) {
		case 69: goto st379;
		case 91: goto tr194;
		case 101: goto st379;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st179;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st179;
	} else
		goto st179;
	goto tr167;
st379:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof379;
case 379:
	switch( (*( sm->p)) ) {
		case 68: goto st380;
		case 91: goto tr194;
		case 100: goto st380;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st179;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st179;
	} else
		goto st179;
	goto tr167;
st380:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof380;
case 380:
	switch( (*( sm->p)) ) {
		case 66: goto st381;
		case 91: goto tr194;
		case 98: goto st381;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st179;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st179;
	} else
		goto st179;
	goto tr167;
st381:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof381;
case 381:
	switch( (*( sm->p)) ) {
		case 65: goto st382;
		case 91: goto tr194;
		case 97: goto st382;
	}
	if ( (*( sm->p)) < 66 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st179;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 98 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st179;
	} else
		goto st179;
	goto tr167;
st382:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof382;
case 382:
	switch( (*( sm->p)) ) {
		case 67: goto st383;
		case 91: goto tr194;
		case 99: goto st383;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st179;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st179;
	} else
		goto st179;
	goto tr167;
st383:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof383;
case 383:
	switch( (*( sm->p)) ) {
		case 75: goto st384;
		case 91: goto tr194;
		case 107: goto st384;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st179;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st179;
	} else
		goto st179;
	goto tr167;
st384:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof384;
case 384:
	switch( (*( sm->p)) ) {
		case 32: goto st385;
		case 91: goto tr194;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st179;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st179;
	} else
		goto st179;
	goto tr167;
st385:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof385;
case 385:
	if ( (*( sm->p)) == 35 )
		goto st386;
	goto tr167;
st386:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof386;
case 386:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr424;
	goto tr167;
tr424:
#line 45 "ext/dtext/dtext.cpp.rl"
	{
  sm->a1 = sm->p;
}
	goto st755;
st755:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof755;
case 755:
#line 8069 "ext/dtext/dtext.cpp"
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto st755;
	goto tr895;
st387:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof387;
case 387:
	switch( (*( sm->p)) ) {
		case 65: goto st388;
		case 91: goto tr194;
		case 97: goto st388;
	}
	if ( (*( sm->p)) < 66 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st179;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 98 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st179;
	} else
		goto st179;
	goto tr167;
st388:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof388;
case 388:
	switch( (*( sm->p)) ) {
		case 71: goto st389;
		case 91: goto tr194;
		case 103: goto st389;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st179;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st179;
	} else
		goto st179;
	goto tr167;
st389:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof389;
case 389:
	switch( (*( sm->p)) ) {
		case 32: goto st390;
		case 91: goto tr194;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st179;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st179;
	} else
		goto st179;
	goto tr167;
st390:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof390;
case 390:
	if ( (*( sm->p)) == 35 )
		goto st391;
	goto tr167;
st391:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof391;
case 391:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr429;
	goto tr167;
tr429:
#line 45 "ext/dtext/dtext.cpp.rl"
	{
  sm->a1 = sm->p;
}
	goto st756;
st756:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof756;
case 756:
#line 8150 "ext/dtext/dtext.cpp"
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto st756;
	goto tr897;
st392:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof392;
case 392:
	switch( (*( sm->p)) ) {
		case 82: goto st393;
		case 91: goto tr194;
		case 114: goto st393;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st179;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st179;
	} else
		goto st179;
	goto tr167;
st393:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof393;
case 393:
	switch( (*( sm->p)) ) {
		case 85: goto st394;
		case 91: goto tr194;
		case 117: goto st394;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st179;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st179;
	} else
		goto st179;
	goto tr167;
st394:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof394;
case 394:
	switch( (*( sm->p)) ) {
		case 77: goto st395;
		case 91: goto tr194;
		case 109: goto st395;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st179;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st179;
	} else
		goto st179;
	goto tr167;
st395:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof395;
case 395:
	switch( (*( sm->p)) ) {
		case 32: goto st396;
		case 91: goto tr194;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st179;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st179;
	} else
		goto st179;
	goto tr167;
st396:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof396;
case 396:
	if ( (*( sm->p)) == 35 )
		goto st397;
	goto tr167;
st397:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof397;
case 397:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr435;
	goto tr167;
tr435:
#line 45 "ext/dtext/dtext.cpp.rl"
	{
  sm->a1 = sm->p;
}
	goto st757;
st757:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof757;
case 757:
#line 8249 "ext/dtext/dtext.cpp"
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto st757;
	goto tr899;
tr807:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 45 "ext/dtext/dtext.cpp.rl"
	{
  sm->a1 = sm->p;
}
	goto st758;
st758:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof758;
case 758:
#line 8265 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 69: goto st398;
		case 91: goto tr194;
		case 101: goto st398;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st179;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st179;
	} else
		goto st179;
	goto tr829;
st398:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof398;
case 398:
	switch( (*( sm->p)) ) {
		case 76: goto st399;
		case 91: goto tr194;
		case 108: goto st399;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st179;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st179;
	} else
		goto st179;
	goto tr167;
st399:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof399;
case 399:
	switch( (*( sm->p)) ) {
		case 66: goto st400;
		case 91: goto tr194;
		case 98: goto st400;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st179;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st179;
	} else
		goto st179;
	goto tr167;
st400:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof400;
case 400:
	switch( (*( sm->p)) ) {
		case 79: goto st401;
		case 91: goto tr194;
		case 111: goto st401;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st179;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st179;
	} else
		goto st179;
	goto tr167;
st401:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof401;
case 401:
	switch( (*( sm->p)) ) {
		case 79: goto st402;
		case 91: goto tr194;
		case 111: goto st402;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st179;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st179;
	} else
		goto st179;
	goto tr167;
st402:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof402;
case 402:
	switch( (*( sm->p)) ) {
		case 82: goto st403;
		case 91: goto tr194;
		case 114: goto st403;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st179;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st179;
	} else
		goto st179;
	goto tr167;
st403:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof403;
case 403:
	switch( (*( sm->p)) ) {
		case 85: goto st404;
		case 91: goto tr194;
		case 117: goto st404;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st179;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st179;
	} else
		goto st179;
	goto tr167;
st404:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof404;
case 404:
	switch( (*( sm->p)) ) {
		case 32: goto st405;
		case 91: goto tr194;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st179;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st179;
	} else
		goto st179;
	goto tr167;
st405:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof405;
case 405:
	if ( (*( sm->p)) == 35 )
		goto st406;
	goto tr167;
st406:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof406;
case 406:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr444;
	goto tr167;
tr444:
#line 45 "ext/dtext/dtext.cpp.rl"
	{
  sm->a1 = sm->p;
}
	goto st759;
st759:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof759;
case 759:
#line 8429 "ext/dtext/dtext.cpp"
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto st759;
	goto tr902;
tr808:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 45 "ext/dtext/dtext.cpp.rl"
	{
  sm->a1 = sm->p;
}
	goto st760;
st760:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof760;
case 760:
#line 8445 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 84: goto st407;
		case 91: goto tr194;
		case 116: goto st407;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st179;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st179;
	} else
		goto st179;
	goto tr829;
st407:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof407;
case 407:
	switch( (*( sm->p)) ) {
		case 84: goto st408;
		case 91: goto tr194;
		case 116: goto st408;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st179;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st179;
	} else
		goto st179;
	goto tr167;
st408:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof408;
case 408:
	switch( (*( sm->p)) ) {
		case 80: goto st409;
		case 91: goto tr194;
		case 112: goto st409;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st179;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st179;
	} else
		goto st179;
	goto tr167;
st409:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof409;
case 409:
	switch( (*( sm->p)) ) {
		case 58: goto st410;
		case 83: goto st413;
		case 91: goto tr194;
		case 115: goto st413;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st179;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st179;
	} else
		goto st179;
	goto tr167;
st410:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof410;
case 410:
	if ( (*( sm->p)) == 47 )
		goto st411;
	goto tr167;
st411:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof411;
case 411:
	if ( (*( sm->p)) == 47 )
		goto st412;
	goto tr167;
st412:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof412;
case 412:
	switch( (*( sm->p)) ) {
		case 0: goto tr167;
		case 32: goto tr167;
	}
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr167;
	goto st761;
st761:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof761;
case 761:
	switch( (*( sm->p)) ) {
		case 0: goto tr905;
		case 32: goto tr905;
	}
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr905;
	goto st761;
st413:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof413;
case 413:
	switch( (*( sm->p)) ) {
		case 58: goto st410;
		case 91: goto tr194;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st179;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st179;
	} else
		goto st179;
	goto tr167;
tr809:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 45 "ext/dtext/dtext.cpp.rl"
	{
  sm->a1 = sm->p;
}
	goto st762;
st762:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof762;
case 762:
#line 8580 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 77: goto st414;
		case 83: goto st426;
		case 91: goto tr194;
		case 109: goto st414;
		case 115: goto st426;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st179;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st179;
	} else
		goto st179;
	goto tr829;
st414:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof414;
case 414:
	switch( (*( sm->p)) ) {
		case 80: goto st415;
		case 91: goto tr194;
		case 112: goto st415;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st179;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st179;
	} else
		goto st179;
	goto tr167;
st415:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof415;
case 415:
	switch( (*( sm->p)) ) {
		case 76: goto st416;
		case 91: goto tr194;
		case 108: goto st416;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st179;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st179;
	} else
		goto st179;
	goto tr167;
st416:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof416;
case 416:
	switch( (*( sm->p)) ) {
		case 73: goto st417;
		case 91: goto tr194;
		case 105: goto st417;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st179;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st179;
	} else
		goto st179;
	goto tr167;
st417:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof417;
case 417:
	switch( (*( sm->p)) ) {
		case 67: goto st418;
		case 91: goto tr194;
		case 99: goto st418;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st179;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st179;
	} else
		goto st179;
	goto tr167;
st418:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof418;
case 418:
	switch( (*( sm->p)) ) {
		case 65: goto st419;
		case 91: goto tr194;
		case 97: goto st419;
	}
	if ( (*( sm->p)) < 66 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st179;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 98 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st179;
	} else
		goto st179;
	goto tr167;
st419:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof419;
case 419:
	switch( (*( sm->p)) ) {
		case 84: goto st420;
		case 91: goto tr194;
		case 116: goto st420;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st179;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st179;
	} else
		goto st179;
	goto tr167;
st420:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof420;
case 420:
	switch( (*( sm->p)) ) {
		case 73: goto st421;
		case 91: goto tr194;
		case 105: goto st421;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st179;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st179;
	} else
		goto st179;
	goto tr167;
st421:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof421;
case 421:
	switch( (*( sm->p)) ) {
		case 79: goto st422;
		case 91: goto tr194;
		case 111: goto st422;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st179;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st179;
	} else
		goto st179;
	goto tr167;
st422:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof422;
case 422:
	switch( (*( sm->p)) ) {
		case 78: goto st423;
		case 91: goto tr194;
		case 110: goto st423;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st179;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st179;
	} else
		goto st179;
	goto tr167;
st423:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof423;
case 423:
	switch( (*( sm->p)) ) {
		case 32: goto st424;
		case 91: goto tr194;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st179;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st179;
	} else
		goto st179;
	goto tr167;
st424:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof424;
case 424:
	if ( (*( sm->p)) == 35 )
		goto st425;
	goto tr167;
st425:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof425;
case 425:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr463;
	goto tr167;
tr463:
#line 45 "ext/dtext/dtext.cpp.rl"
	{
  sm->a1 = sm->p;
}
	goto st763;
st763:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof763;
case 763:
#line 8800 "ext/dtext/dtext.cpp"
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto st763;
	goto tr908;
st426:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof426;
case 426:
	switch( (*( sm->p)) ) {
		case 83: goto st427;
		case 91: goto tr194;
		case 115: goto st427;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st179;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st179;
	} else
		goto st179;
	goto tr167;
st427:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof427;
case 427:
	switch( (*( sm->p)) ) {
		case 85: goto st428;
		case 91: goto tr194;
		case 117: goto st428;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st179;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st179;
	} else
		goto st179;
	goto tr167;
st428:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof428;
case 428:
	switch( (*( sm->p)) ) {
		case 69: goto st429;
		case 91: goto tr194;
		case 101: goto st429;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st179;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st179;
	} else
		goto st179;
	goto tr167;
st429:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof429;
case 429:
	switch( (*( sm->p)) ) {
		case 32: goto st430;
		case 91: goto tr194;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st179;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st179;
	} else
		goto st179;
	goto tr167;
st430:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof430;
case 430:
	if ( (*( sm->p)) == 35 )
		goto st431;
	goto tr167;
st431:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof431;
case 431:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr469;
	goto tr167;
tr469:
#line 45 "ext/dtext/dtext.cpp.rl"
	{
  sm->a1 = sm->p;
}
	goto st764;
st764:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof764;
case 764:
#line 8899 "ext/dtext/dtext.cpp"
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto st764;
	goto tr910;
tr810:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 45 "ext/dtext/dtext.cpp.rl"
	{
  sm->a1 = sm->p;
}
	goto st765;
st765:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof765;
case 765:
#line 8915 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 79: goto st432;
		case 91: goto tr194;
		case 111: goto st432;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st179;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st179;
	} else
		goto st179;
	goto tr829;
st432:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof432;
case 432:
	switch( (*( sm->p)) ) {
		case 68: goto st433;
		case 91: goto tr194;
		case 100: goto st433;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st179;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st179;
	} else
		goto st179;
	goto tr167;
st433:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof433;
case 433:
	switch( (*( sm->p)) ) {
		case 32: goto st434;
		case 82: goto st443;
		case 91: goto tr194;
		case 114: goto st443;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st179;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st179;
	} else
		goto st179;
	goto tr167;
st434:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof434;
case 434:
	switch( (*( sm->p)) ) {
		case 65: goto st435;
		case 97: goto st435;
	}
	goto tr167;
st435:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof435;
case 435:
	switch( (*( sm->p)) ) {
		case 67: goto st436;
		case 99: goto st436;
	}
	goto tr167;
st436:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof436;
case 436:
	switch( (*( sm->p)) ) {
		case 84: goto st437;
		case 116: goto st437;
	}
	goto tr167;
st437:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof437;
case 437:
	switch( (*( sm->p)) ) {
		case 73: goto st438;
		case 105: goto st438;
	}
	goto tr167;
st438:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof438;
case 438:
	switch( (*( sm->p)) ) {
		case 79: goto st439;
		case 111: goto st439;
	}
	goto tr167;
st439:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof439;
case 439:
	switch( (*( sm->p)) ) {
		case 78: goto st440;
		case 110: goto st440;
	}
	goto tr167;
st440:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof440;
case 440:
	if ( (*( sm->p)) == 32 )
		goto st441;
	goto tr167;
st441:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof441;
case 441:
	if ( (*( sm->p)) == 35 )
		goto st442;
	goto tr167;
st442:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof442;
case 442:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr481;
	goto tr167;
tr481:
#line 45 "ext/dtext/dtext.cpp.rl"
	{
  sm->a1 = sm->p;
}
	goto st766;
st766:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof766;
case 766:
#line 9052 "ext/dtext/dtext.cpp"
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto st766;
	goto tr913;
st443:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof443;
case 443:
	switch( (*( sm->p)) ) {
		case 69: goto st444;
		case 91: goto tr194;
		case 101: goto st444;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st179;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st179;
	} else
		goto st179;
	goto tr167;
st444:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof444;
case 444:
	switch( (*( sm->p)) ) {
		case 80: goto st445;
		case 91: goto tr194;
		case 112: goto st445;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st179;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st179;
	} else
		goto st179;
	goto tr167;
st445:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof445;
case 445:
	switch( (*( sm->p)) ) {
		case 79: goto st446;
		case 91: goto tr194;
		case 111: goto st446;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st179;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st179;
	} else
		goto st179;
	goto tr167;
st446:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof446;
case 446:
	switch( (*( sm->p)) ) {
		case 82: goto st447;
		case 91: goto tr194;
		case 114: goto st447;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st179;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st179;
	} else
		goto st179;
	goto tr167;
st447:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof447;
case 447:
	switch( (*( sm->p)) ) {
		case 84: goto st448;
		case 91: goto tr194;
		case 116: goto st448;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st179;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st179;
	} else
		goto st179;
	goto tr167;
st448:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof448;
case 448:
	switch( (*( sm->p)) ) {
		case 32: goto st449;
		case 91: goto tr194;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st179;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st179;
	} else
		goto st179;
	goto tr167;
st449:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof449;
case 449:
	if ( (*( sm->p)) == 35 )
		goto st450;
	goto tr167;
st450:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof450;
case 450:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr489;
	goto tr167;
tr489:
#line 45 "ext/dtext/dtext.cpp.rl"
	{
  sm->a1 = sm->p;
}
	goto st767;
st767:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof767;
case 767:
#line 9187 "ext/dtext/dtext.cpp"
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto st767;
	goto tr915;
tr811:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 45 "ext/dtext/dtext.cpp.rl"
	{
  sm->a1 = sm->p;
}
	goto st768;
st768:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof768;
case 768:
#line 9203 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 73: goto st451;
		case 79: goto st457;
		case 91: goto tr194;
		case 105: goto st451;
		case 111: goto st457;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st179;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st179;
	} else
		goto st179;
	goto tr829;
st451:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof451;
case 451:
	switch( (*( sm->p)) ) {
		case 74: goto st452;
		case 91: goto tr194;
		case 106: goto st452;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st179;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st179;
	} else
		goto st179;
	goto tr167;
st452:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof452;
case 452:
	switch( (*( sm->p)) ) {
		case 73: goto st453;
		case 91: goto tr194;
		case 105: goto st453;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st179;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st179;
	} else
		goto st179;
	goto tr167;
st453:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof453;
case 453:
	switch( (*( sm->p)) ) {
		case 69: goto st454;
		case 91: goto tr194;
		case 101: goto st454;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st179;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st179;
	} else
		goto st179;
	goto tr167;
st454:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof454;
case 454:
	switch( (*( sm->p)) ) {
		case 32: goto st455;
		case 91: goto tr194;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st179;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st179;
	} else
		goto st179;
	goto tr167;
st455:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof455;
case 455:
	if ( (*( sm->p)) == 35 )
		goto st456;
	goto tr167;
st456:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof456;
case 456:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr495;
	goto tr167;
tr495:
#line 45 "ext/dtext/dtext.cpp.rl"
	{
  sm->a1 = sm->p;
}
	goto st769;
st769:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof769;
case 769:
#line 9315 "ext/dtext/dtext.cpp"
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto st769;
	goto tr919;
st457:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof457;
case 457:
	switch( (*( sm->p)) ) {
		case 84: goto st458;
		case 91: goto tr194;
		case 116: goto st458;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st179;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st179;
	} else
		goto st179;
	goto tr167;
st458:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof458;
case 458:
	switch( (*( sm->p)) ) {
		case 69: goto st459;
		case 91: goto tr194;
		case 101: goto st459;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st179;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st179;
	} else
		goto st179;
	goto tr167;
st459:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof459;
case 459:
	switch( (*( sm->p)) ) {
		case 32: goto st460;
		case 91: goto tr194;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st179;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st179;
	} else
		goto st179;
	goto tr167;
st460:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof460;
case 460:
	if ( (*( sm->p)) == 35 )
		goto st461;
	goto tr167;
st461:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof461;
case 461:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr500;
	goto tr167;
tr500:
#line 45 "ext/dtext/dtext.cpp.rl"
	{
  sm->a1 = sm->p;
}
	goto st770;
st770:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof770;
case 770:
#line 9396 "ext/dtext/dtext.cpp"
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto st770;
	goto tr921;
tr812:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 45 "ext/dtext/dtext.cpp.rl"
	{
  sm->a1 = sm->p;
}
	goto st771;
st771:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof771;
case 771:
#line 9412 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 65: goto st462;
		case 73: goto st468;
		case 79: goto st476;
		case 85: goto st485;
		case 91: goto tr194;
		case 97: goto st462;
		case 105: goto st468;
		case 111: goto st476;
		case 117: goto st485;
	}
	if ( (*( sm->p)) < 66 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st179;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 98 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st179;
	} else
		goto st179;
	goto tr829;
st462:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof462;
case 462:
	switch( (*( sm->p)) ) {
		case 87: goto st463;
		case 91: goto tr194;
		case 119: goto st463;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st179;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st179;
	} else
		goto st179;
	goto tr167;
st463:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof463;
case 463:
	switch( (*( sm->p)) ) {
		case 79: goto st464;
		case 91: goto tr194;
		case 111: goto st464;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st179;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st179;
	} else
		goto st179;
	goto tr167;
st464:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof464;
case 464:
	switch( (*( sm->p)) ) {
		case 79: goto st465;
		case 91: goto tr194;
		case 111: goto st465;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st179;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st179;
	} else
		goto st179;
	goto tr167;
st465:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof465;
case 465:
	switch( (*( sm->p)) ) {
		case 32: goto st466;
		case 91: goto tr194;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st179;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st179;
	} else
		goto st179;
	goto tr167;
st466:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof466;
case 466:
	if ( (*( sm->p)) == 35 )
		goto st467;
	goto tr167;
st467:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof467;
case 467:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr506;
	goto tr167;
tr506:
#line 45 "ext/dtext/dtext.cpp.rl"
	{
  sm->a1 = sm->p;
}
	goto st772;
st772:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof772;
case 772:
#line 9528 "ext/dtext/dtext.cpp"
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto st772;
	goto tr927;
st468:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof468;
case 468:
	switch( (*( sm->p)) ) {
		case 88: goto st469;
		case 91: goto tr194;
		case 120: goto st469;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st179;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st179;
	} else
		goto st179;
	goto tr167;
st469:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof469;
case 469:
	switch( (*( sm->p)) ) {
		case 73: goto st470;
		case 91: goto tr194;
		case 105: goto st470;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st179;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st179;
	} else
		goto st179;
	goto tr167;
st470:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof470;
case 470:
	switch( (*( sm->p)) ) {
		case 86: goto st471;
		case 91: goto tr194;
		case 118: goto st471;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st179;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st179;
	} else
		goto st179;
	goto tr167;
st471:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof471;
case 471:
	switch( (*( sm->p)) ) {
		case 32: goto st472;
		case 91: goto tr194;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st179;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st179;
	} else
		goto st179;
	goto tr167;
st472:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof472;
case 472:
	if ( (*( sm->p)) == 35 )
		goto st473;
	goto tr167;
st473:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof473;
case 473:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr512;
	goto tr167;
tr512:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 45 "ext/dtext/dtext.cpp.rl"
	{
  sm->a1 = sm->p;
}
	goto st773;
tr931:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
	goto st773;
st773:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof773;
case 773:
#line 9633 "ext/dtext/dtext.cpp"
	if ( (*( sm->p)) == 47 )
		goto tr930;
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr931;
	goto tr929;
tr930:
#line 49 "ext/dtext/dtext.cpp.rl"
	{
  sm->a2 = sm->p;
}
	goto st474;
st474:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof474;
case 474:
#line 9649 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 80: goto st475;
		case 112: goto st475;
	}
	goto tr513;
st475:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof475;
case 475:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr515;
	goto tr513;
tr515:
#line 53 "ext/dtext/dtext.cpp.rl"
	{
  sm->b1 = sm->p;
}
	goto st774;
st774:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof774;
case 774:
#line 9672 "ext/dtext/dtext.cpp"
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto st774;
	goto tr932;
st476:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof476;
case 476:
	switch( (*( sm->p)) ) {
		case 79: goto st477;
		case 83: goto st481;
		case 91: goto tr194;
		case 111: goto st477;
		case 115: goto st481;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st179;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st179;
	} else
		goto st179;
	goto tr167;
st477:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof477;
case 477:
	switch( (*( sm->p)) ) {
		case 76: goto st478;
		case 91: goto tr194;
		case 108: goto st478;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st179;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st179;
	} else
		goto st179;
	goto tr167;
st478:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof478;
case 478:
	switch( (*( sm->p)) ) {
		case 32: goto st479;
		case 91: goto tr194;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st179;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st179;
	} else
		goto st179;
	goto tr167;
st479:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof479;
case 479:
	if ( (*( sm->p)) == 35 )
		goto st480;
	goto tr167;
st480:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof480;
case 480:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr521;
	goto tr167;
tr521:
#line 45 "ext/dtext/dtext.cpp.rl"
	{
  sm->a1 = sm->p;
}
	goto st775;
st775:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof775;
case 775:
#line 9755 "ext/dtext/dtext.cpp"
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto st775;
	goto tr934;
st481:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof481;
case 481:
	switch( (*( sm->p)) ) {
		case 84: goto st482;
		case 91: goto tr194;
		case 116: goto st482;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st179;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st179;
	} else
		goto st179;
	goto tr167;
st482:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof482;
case 482:
	switch( (*( sm->p)) ) {
		case 32: goto st483;
		case 91: goto tr194;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st179;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st179;
	} else
		goto st179;
	goto tr167;
st483:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof483;
case 483:
	if ( (*( sm->p)) == 35 )
		goto st484;
	goto tr167;
st484:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof484;
case 484:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr525;
	goto tr167;
tr525:
#line 45 "ext/dtext/dtext.cpp.rl"
	{
  sm->a1 = sm->p;
}
	goto st776;
st776:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof776;
case 776:
#line 9818 "ext/dtext/dtext.cpp"
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto st776;
	goto tr936;
st485:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof485;
case 485:
	switch( (*( sm->p)) ) {
		case 76: goto st486;
		case 91: goto tr194;
		case 108: goto st486;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st179;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st179;
	} else
		goto st179;
	goto tr167;
st486:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof486;
case 486:
	switch( (*( sm->p)) ) {
		case 76: goto st487;
		case 91: goto tr194;
		case 108: goto st487;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st179;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st179;
	} else
		goto st179;
	goto tr167;
st487:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof487;
case 487:
	switch( (*( sm->p)) ) {
		case 32: goto st488;
		case 91: goto tr194;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st179;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st179;
	} else
		goto st179;
	goto tr167;
st488:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof488;
case 488:
	if ( (*( sm->p)) == 35 )
		goto st489;
	goto tr167;
st489:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof489;
case 489:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr530;
	goto tr167;
tr530:
#line 45 "ext/dtext/dtext.cpp.rl"
	{
  sm->a1 = sm->p;
}
	goto st777;
st777:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof777;
case 777:
#line 9899 "ext/dtext/dtext.cpp"
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto st777;
	goto tr938;
tr813:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 45 "ext/dtext/dtext.cpp.rl"
	{
  sm->a1 = sm->p;
}
	goto st778;
st778:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof778;
case 778:
#line 9915 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 65: goto st490;
		case 69: goto st498;
		case 91: goto tr194;
		case 97: goto st490;
		case 101: goto st498;
	}
	if ( (*( sm->p)) < 66 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st179;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 98 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st179;
	} else
		goto st179;
	goto tr829;
st490:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof490;
case 490:
	switch( (*( sm->p)) ) {
		case 78: goto st491;
		case 91: goto tr194;
		case 110: goto st491;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st179;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st179;
	} else
		goto st179;
	goto tr167;
st491:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof491;
case 491:
	switch( (*( sm->p)) ) {
		case 75: goto st492;
		case 91: goto tr194;
		case 107: goto st492;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st179;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st179;
	} else
		goto st179;
	goto tr167;
st492:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof492;
case 492:
	switch( (*( sm->p)) ) {
		case 65: goto st493;
		case 91: goto tr194;
		case 97: goto st493;
	}
	if ( (*( sm->p)) < 66 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st179;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 98 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st179;
	} else
		goto st179;
	goto tr167;
st493:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof493;
case 493:
	switch( (*( sm->p)) ) {
		case 75: goto st494;
		case 91: goto tr194;
		case 107: goto st494;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st179;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st179;
	} else
		goto st179;
	goto tr167;
st494:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof494;
case 494:
	switch( (*( sm->p)) ) {
		case 85: goto st495;
		case 91: goto tr194;
		case 117: goto st495;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st179;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st179;
	} else
		goto st179;
	goto tr167;
st495:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof495;
case 495:
	switch( (*( sm->p)) ) {
		case 32: goto st496;
		case 91: goto tr194;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st179;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st179;
	} else
		goto st179;
	goto tr167;
st496:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof496;
case 496:
	if ( (*( sm->p)) == 35 )
		goto st497;
	goto tr167;
st497:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof497;
case 497:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr538;
	goto tr167;
tr538:
#line 45 "ext/dtext/dtext.cpp.rl"
	{
  sm->a1 = sm->p;
}
	goto st779;
st779:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof779;
case 779:
#line 10063 "ext/dtext/dtext.cpp"
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto st779;
	goto tr942;
st498:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof498;
case 498:
	switch( (*( sm->p)) ) {
		case 73: goto st499;
		case 91: goto tr194;
		case 105: goto st499;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st179;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st179;
	} else
		goto st179;
	goto tr167;
st499:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof499;
case 499:
	switch( (*( sm->p)) ) {
		case 71: goto st500;
		case 91: goto tr194;
		case 103: goto st500;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st179;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st179;
	} else
		goto st179;
	goto tr167;
st500:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof500;
case 500:
	switch( (*( sm->p)) ) {
		case 65: goto st501;
		case 91: goto tr194;
		case 97: goto st501;
	}
	if ( (*( sm->p)) < 66 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st179;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 98 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st179;
	} else
		goto st179;
	goto tr167;
st501:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof501;
case 501:
	switch( (*( sm->p)) ) {
		case 32: goto st502;
		case 91: goto tr194;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st179;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st179;
	} else
		goto st179;
	goto tr167;
st502:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof502;
case 502:
	if ( (*( sm->p)) == 35 )
		goto st503;
	goto tr167;
st503:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof503;
case 503:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr544;
	goto tr167;
tr544:
#line 45 "ext/dtext/dtext.cpp.rl"
	{
  sm->a1 = sm->p;
}
	goto st780;
st780:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof780;
case 780:
#line 10162 "ext/dtext/dtext.cpp"
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto st780;
	goto tr944;
tr814:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 45 "ext/dtext/dtext.cpp.rl"
	{
  sm->a1 = sm->p;
}
	goto st781;
st781:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof781;
case 781:
#line 10178 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 79: goto st504;
		case 87: goto st512;
		case 91: goto tr194;
		case 111: goto st504;
		case 119: goto st512;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st179;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st179;
	} else
		goto st179;
	goto tr829;
st504:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof504;
case 504:
	switch( (*( sm->p)) ) {
		case 80: goto st505;
		case 91: goto tr194;
		case 112: goto st505;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st179;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st179;
	} else
		goto st179;
	goto tr167;
st505:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof505;
case 505:
	switch( (*( sm->p)) ) {
		case 73: goto st506;
		case 91: goto tr194;
		case 105: goto st506;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st179;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st179;
	} else
		goto st179;
	goto tr167;
st506:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof506;
case 506:
	switch( (*( sm->p)) ) {
		case 67: goto st507;
		case 91: goto tr194;
		case 99: goto st507;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st179;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st179;
	} else
		goto st179;
	goto tr167;
st507:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof507;
case 507:
	switch( (*( sm->p)) ) {
		case 32: goto st508;
		case 91: goto tr194;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st179;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st179;
	} else
		goto st179;
	goto tr167;
st508:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof508;
case 508:
	if ( (*( sm->p)) == 35 )
		goto st509;
	goto tr167;
st509:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof509;
case 509:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr550;
	goto tr167;
tr550:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 45 "ext/dtext/dtext.cpp.rl"
	{
  sm->a1 = sm->p;
}
	goto st782;
tr950:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
	goto st782;
st782:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof782;
case 782:
#line 10296 "ext/dtext/dtext.cpp"
	if ( (*( sm->p)) == 47 )
		goto tr949;
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr950;
	goto tr948;
tr949:
#line 49 "ext/dtext/dtext.cpp.rl"
	{
  sm->a2 = sm->p;
}
	goto st510;
st510:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof510;
case 510:
#line 10312 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 80: goto st511;
		case 112: goto st511;
	}
	goto tr551;
st511:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof511;
case 511:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr553;
	goto tr551;
tr553:
#line 53 "ext/dtext/dtext.cpp.rl"
	{
  sm->b1 = sm->p;
}
	goto st783;
st783:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof783;
case 783:
#line 10335 "ext/dtext/dtext.cpp"
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto st783;
	goto tr951;
st512:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof512;
case 512:
	switch( (*( sm->p)) ) {
		case 73: goto st513;
		case 91: goto tr194;
		case 105: goto st513;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st179;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st179;
	} else
		goto st179;
	goto tr167;
st513:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof513;
case 513:
	switch( (*( sm->p)) ) {
		case 84: goto st514;
		case 91: goto tr194;
		case 116: goto st514;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st179;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st179;
	} else
		goto st179;
	goto tr167;
st514:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof514;
case 514:
	switch( (*( sm->p)) ) {
		case 84: goto st515;
		case 91: goto tr194;
		case 116: goto st515;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st179;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st179;
	} else
		goto st179;
	goto tr167;
st515:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof515;
case 515:
	switch( (*( sm->p)) ) {
		case 69: goto st516;
		case 91: goto tr194;
		case 101: goto st516;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st179;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st179;
	} else
		goto st179;
	goto tr167;
st516:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof516;
case 516:
	switch( (*( sm->p)) ) {
		case 82: goto st517;
		case 91: goto tr194;
		case 114: goto st517;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st179;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st179;
	} else
		goto st179;
	goto tr167;
st517:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof517;
case 517:
	switch( (*( sm->p)) ) {
		case 32: goto st518;
		case 91: goto tr194;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st179;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st179;
	} else
		goto st179;
	goto tr167;
st518:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof518;
case 518:
	if ( (*( sm->p)) == 35 )
		goto st519;
	goto tr167;
st519:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof519;
case 519:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr561;
	goto tr167;
tr561:
#line 45 "ext/dtext/dtext.cpp.rl"
	{
  sm->a1 = sm->p;
}
	goto st784;
st784:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof784;
case 784:
#line 10470 "ext/dtext/dtext.cpp"
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto st784;
	goto tr953;
tr815:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 45 "ext/dtext/dtext.cpp.rl"
	{
  sm->a1 = sm->p;
}
	goto st785;
st785:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof785;
case 785:
#line 10486 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 83: goto st520;
		case 91: goto tr194;
		case 115: goto st520;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st179;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st179;
	} else
		goto st179;
	goto tr829;
st520:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof520;
case 520:
	switch( (*( sm->p)) ) {
		case 69: goto st521;
		case 91: goto tr194;
		case 101: goto st521;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st179;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st179;
	} else
		goto st179;
	goto tr167;
st521:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof521;
case 521:
	switch( (*( sm->p)) ) {
		case 82: goto st522;
		case 91: goto tr194;
		case 114: goto st522;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st179;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st179;
	} else
		goto st179;
	goto tr167;
st522:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof522;
case 522:
	switch( (*( sm->p)) ) {
		case 32: goto st523;
		case 91: goto tr194;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st179;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st179;
	} else
		goto st179;
	goto tr167;
st523:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof523;
case 523:
	if ( (*( sm->p)) == 35 )
		goto st524;
	goto tr167;
st524:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof524;
case 524:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr566;
	goto tr167;
tr566:
#line 45 "ext/dtext/dtext.cpp.rl"
	{
  sm->a1 = sm->p;
}
	goto st786;
st786:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof786;
case 786:
#line 10578 "ext/dtext/dtext.cpp"
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto st786;
	goto tr956;
tr816:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 45 "ext/dtext/dtext.cpp.rl"
	{
  sm->a1 = sm->p;
}
	goto st787;
st787:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof787;
case 787:
#line 10594 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 73: goto st525;
		case 91: goto tr194;
		case 105: goto st525;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st179;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st179;
	} else
		goto st179;
	goto tr829;
st525:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof525;
case 525:
	switch( (*( sm->p)) ) {
		case 75: goto st526;
		case 91: goto tr194;
		case 107: goto st526;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st179;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st179;
	} else
		goto st179;
	goto tr167;
st526:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof526;
case 526:
	switch( (*( sm->p)) ) {
		case 73: goto st527;
		case 91: goto tr194;
		case 105: goto st527;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st179;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st179;
	} else
		goto st179;
	goto tr167;
st527:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof527;
case 527:
	switch( (*( sm->p)) ) {
		case 32: goto st528;
		case 91: goto tr194;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st179;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st179;
	} else
		goto st179;
	goto tr167;
st528:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof528;
case 528:
	if ( (*( sm->p)) == 35 )
		goto st529;
	goto tr167;
st529:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof529;
case 529:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr571;
	goto tr167;
tr571:
#line 45 "ext/dtext/dtext.cpp.rl"
	{
  sm->a1 = sm->p;
}
	goto st788;
st788:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof788;
case 788:
#line 10686 "ext/dtext/dtext.cpp"
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto st788;
	goto tr959;
tr817:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 45 "ext/dtext/dtext.cpp.rl"
	{
  sm->a1 = sm->p;
}
	goto st789;
st789:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof789;
case 789:
#line 10702 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 65: goto st530;
		case 91: goto tr194;
		case 97: goto st530;
	}
	if ( (*( sm->p)) < 66 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st179;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 98 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st179;
	} else
		goto st179;
	goto tr829;
st530:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof530;
case 530:
	switch( (*( sm->p)) ) {
		case 78: goto st531;
		case 91: goto tr194;
		case 110: goto st531;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st179;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st179;
	} else
		goto st179;
	goto tr167;
st531:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof531;
case 531:
	switch( (*( sm->p)) ) {
		case 68: goto st532;
		case 91: goto tr194;
		case 100: goto st532;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st179;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st179;
	} else
		goto st179;
	goto tr167;
st532:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof532;
case 532:
	switch( (*( sm->p)) ) {
		case 69: goto st533;
		case 91: goto tr194;
		case 101: goto st533;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st179;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st179;
	} else
		goto st179;
	goto tr167;
st533:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof533;
case 533:
	switch( (*( sm->p)) ) {
		case 82: goto st534;
		case 91: goto tr194;
		case 114: goto st534;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st179;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st179;
	} else
		goto st179;
	goto tr167;
st534:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof534;
case 534:
	switch( (*( sm->p)) ) {
		case 69: goto st535;
		case 91: goto tr194;
		case 101: goto st535;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st179;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st179;
	} else
		goto st179;
	goto tr167;
st535:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof535;
case 535:
	switch( (*( sm->p)) ) {
		case 32: goto st536;
		case 91: goto tr194;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st179;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st179;
	} else
		goto st179;
	goto tr167;
st536:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof536;
case 536:
	if ( (*( sm->p)) == 35 )
		goto st537;
	goto tr167;
st537:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof537;
case 537:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr579;
	goto tr167;
tr579:
#line 45 "ext/dtext/dtext.cpp.rl"
	{
  sm->a1 = sm->p;
}
	goto st790;
st790:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof790;
case 790:
#line 10848 "ext/dtext/dtext.cpp"
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto st790;
	goto tr962;
tr818:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 45 "ext/dtext/dtext.cpp.rl"
	{
  sm->a1 = sm->p;
}
#line 49 "ext/dtext/dtext.cpp.rl"
	{
  sm->a2 = sm->p;
}
	goto st791;
st791:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof791;
case 791:
#line 10868 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 47: goto st538;
		case 66: goto st565;
		case 67: goto st566;
		case 69: goto st570;
		case 72: goto tr968;
		case 73: goto st588;
		case 78: goto st589;
		case 81: goto st596;
		case 83: goto st601;
		case 84: goto st609;
		case 85: goto st611;
		case 91: goto st181;
		case 98: goto st565;
		case 99: goto st566;
		case 101: goto st570;
		case 104: goto tr968;
		case 105: goto st588;
		case 110: goto st589;
		case 113: goto st596;
		case 115: goto st601;
		case 116: goto st609;
		case 117: goto st611;
	}
	goto tr829;
st538:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof538;
case 538:
	switch( (*( sm->p)) ) {
		case 66: goto st539;
		case 69: goto st540;
		case 73: goto st546;
		case 81: goto st547;
		case 83: goto st552;
		case 84: goto st560;
		case 85: goto st564;
		case 98: goto st539;
		case 101: goto st540;
		case 105: goto st546;
		case 113: goto st547;
		case 115: goto st552;
		case 116: goto st560;
		case 117: goto st564;
	}
	goto tr167;
st539:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof539;
case 539:
	if ( (*( sm->p)) == 93 )
		goto tr215;
	goto tr167;
st540:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof540;
case 540:
	switch( (*( sm->p)) ) {
		case 88: goto st541;
		case 120: goto st541;
	}
	goto tr167;
st541:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof541;
case 541:
	switch( (*( sm->p)) ) {
		case 80: goto st542;
		case 112: goto st542;
	}
	goto tr167;
st542:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof542;
case 542:
	switch( (*( sm->p)) ) {
		case 65: goto st543;
		case 97: goto st543;
	}
	goto tr167;
st543:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof543;
case 543:
	switch( (*( sm->p)) ) {
		case 78: goto st544;
		case 110: goto st544;
	}
	goto tr167;
st544:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof544;
case 544:
	switch( (*( sm->p)) ) {
		case 68: goto st545;
		case 100: goto st545;
	}
	goto tr167;
st545:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof545;
case 545:
	if ( (*( sm->p)) == 93 )
		goto tr231;
	goto tr167;
st546:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof546;
case 546:
	if ( (*( sm->p)) == 93 )
		goto tr226;
	goto tr167;
st547:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof547;
case 547:
	switch( (*( sm->p)) ) {
		case 85: goto st548;
		case 117: goto st548;
	}
	goto tr167;
st548:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof548;
case 548:
	switch( (*( sm->p)) ) {
		case 79: goto st549;
		case 111: goto st549;
	}
	goto tr167;
st549:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof549;
case 549:
	switch( (*( sm->p)) ) {
		case 84: goto st550;
		case 116: goto st550;
	}
	goto tr167;
st550:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof550;
case 550:
	switch( (*( sm->p)) ) {
		case 69: goto st551;
		case 101: goto st551;
	}
	goto tr167;
st551:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof551;
case 551:
	if ( (*( sm->p)) == 93 )
		goto st734;
	goto tr167;
st552:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof552;
case 552:
	switch( (*( sm->p)) ) {
		case 80: goto st553;
		case 93: goto tr232;
		case 112: goto st553;
	}
	goto tr167;
st553:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof553;
case 553:
	switch( (*( sm->p)) ) {
		case 79: goto st554;
		case 111: goto st554;
	}
	goto tr167;
st554:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof554;
case 554:
	switch( (*( sm->p)) ) {
		case 73: goto st555;
		case 105: goto st555;
	}
	goto tr167;
st555:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof555;
case 555:
	switch( (*( sm->p)) ) {
		case 76: goto st556;
		case 108: goto st556;
	}
	goto tr167;
st556:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof556;
case 556:
	switch( (*( sm->p)) ) {
		case 69: goto st557;
		case 101: goto st557;
	}
	goto tr167;
st557:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof557;
case 557:
	switch( (*( sm->p)) ) {
		case 82: goto st558;
		case 114: goto st558;
	}
	goto tr167;
st558:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof558;
case 558:
	switch( (*( sm->p)) ) {
		case 83: goto st559;
		case 93: goto tr240;
		case 115: goto st559;
	}
	goto tr167;
st559:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof559;
case 559:
	if ( (*( sm->p)) == 93 )
		goto tr240;
	goto tr167;
st560:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof560;
case 560:
	switch( (*( sm->p)) ) {
		case 68: goto st561;
		case 72: goto st562;
		case 78: goto st563;
		case 100: goto st561;
		case 104: goto st562;
		case 110: goto st563;
	}
	goto tr167;
st561:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof561;
case 561:
	if ( (*( sm->p)) == 93 )
		goto tr249;
	goto tr167;
st562:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof562;
case 562:
	if ( (*( sm->p)) == 93 )
		goto tr250;
	goto tr167;
st563:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof563;
case 563:
	if ( (*( sm->p)) == 93 )
		goto tr251;
	goto tr167;
st564:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof564;
case 564:
	if ( (*( sm->p)) == 93 )
		goto tr252;
	goto tr167;
st565:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof565;
case 565:
	if ( (*( sm->p)) == 93 )
		goto tr281;
	goto tr167;
st566:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof566;
case 566:
	switch( (*( sm->p)) ) {
		case 79: goto st567;
		case 111: goto st567;
	}
	goto tr167;
st567:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof567;
case 567:
	switch( (*( sm->p)) ) {
		case 68: goto st568;
		case 100: goto st568;
	}
	goto tr167;
st568:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof568;
case 568:
	switch( (*( sm->p)) ) {
		case 69: goto st569;
		case 101: goto st569;
	}
	goto tr167;
st569:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof569;
case 569:
	if ( (*( sm->p)) == 93 )
		goto tr295;
	goto tr167;
st570:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof570;
case 570:
	switch( (*( sm->p)) ) {
		case 88: goto st571;
		case 120: goto st571;
	}
	goto tr167;
st571:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof571;
case 571:
	switch( (*( sm->p)) ) {
		case 80: goto st572;
		case 112: goto st572;
	}
	goto tr167;
st572:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof572;
case 572:
	switch( (*( sm->p)) ) {
		case 65: goto st573;
		case 97: goto st573;
	}
	goto tr167;
st573:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof573;
case 573:
	switch( (*( sm->p)) ) {
		case 78: goto st574;
		case 110: goto st574;
	}
	goto tr167;
st574:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof574;
case 574:
	switch( (*( sm->p)) ) {
		case 68: goto st575;
		case 100: goto st575;
	}
	goto tr167;
st575:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof575;
case 575:
	if ( (*( sm->p)) == 93 )
		goto tr303;
	goto tr167;
tr968:
#line 45 "ext/dtext/dtext.cpp.rl"
	{
  sm->a1 = sm->p;
}
	goto st576;
st576:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof576;
case 576:
#line 11240 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 84: goto st577;
		case 116: goto st577;
	}
	goto tr167;
st577:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof577;
case 577:
	switch( (*( sm->p)) ) {
		case 84: goto st578;
		case 116: goto st578;
	}
	goto tr167;
st578:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof578;
case 578:
	switch( (*( sm->p)) ) {
		case 80: goto st579;
		case 112: goto st579;
	}
	goto tr167;
st579:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof579;
case 579:
	switch( (*( sm->p)) ) {
		case 58: goto st580;
		case 83: goto st587;
		case 115: goto st587;
	}
	goto tr167;
st580:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof580;
case 580:
	if ( (*( sm->p)) == 47 )
		goto st581;
	goto tr167;
st581:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof581;
case 581:
	if ( (*( sm->p)) == 47 )
		goto st582;
	goto tr167;
st582:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof582;
case 582:
	switch( (*( sm->p)) ) {
		case 0: goto tr167;
		case 32: goto tr167;
	}
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr167;
	goto st583;
st583:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof583;
case 583:
	switch( (*( sm->p)) ) {
		case 0: goto tr167;
		case 32: goto tr167;
		case 93: goto tr622;
	}
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr167;
	goto st583;
tr622:
#line 49 "ext/dtext/dtext.cpp.rl"
	{
  sm->a2 = sm->p;
}
	goto st584;
st584:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof584;
case 584:
#line 11321 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr167;
		case 32: goto tr167;
		case 40: goto st585;
		case 93: goto tr622;
	}
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr167;
	goto st583;
st585:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof585;
case 585:
	if ( (*( sm->p)) == 41 )
		goto tr167;
	goto tr624;
tr624:
#line 53 "ext/dtext/dtext.cpp.rl"
	{
  sm->b1 = sm->p;
}
	goto st586;
st586:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof586;
case 586:
#line 11348 "ext/dtext/dtext.cpp"
	if ( (*( sm->p)) == 41 )
		goto tr626;
	goto st586;
st587:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof587;
case 587:
	if ( (*( sm->p)) == 58 )
		goto st580;
	goto tr167;
st588:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof588;
case 588:
	if ( (*( sm->p)) == 93 )
		goto tr298;
	goto tr167;
st589:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof589;
case 589:
	switch( (*( sm->p)) ) {
		case 79: goto st590;
		case 111: goto st590;
	}
	goto tr167;
st590:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof590;
case 590:
	switch( (*( sm->p)) ) {
		case 68: goto st591;
		case 100: goto st591;
	}
	goto tr167;
st591:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof591;
case 591:
	switch( (*( sm->p)) ) {
		case 84: goto st592;
		case 116: goto st592;
	}
	goto tr167;
st592:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof592;
case 592:
	switch( (*( sm->p)) ) {
		case 69: goto st593;
		case 101: goto st593;
	}
	goto tr167;
st593:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof593;
case 593:
	switch( (*( sm->p)) ) {
		case 88: goto st594;
		case 120: goto st594;
	}
	goto tr167;
st594:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof594;
case 594:
	switch( (*( sm->p)) ) {
		case 84: goto st595;
		case 116: goto st595;
	}
	goto tr167;
st595:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof595;
case 595:
	if ( (*( sm->p)) == 93 )
		goto tr319;
	goto tr167;
st596:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof596;
case 596:
	switch( (*( sm->p)) ) {
		case 85: goto st597;
		case 117: goto st597;
	}
	goto tr167;
st597:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof597;
case 597:
	switch( (*( sm->p)) ) {
		case 79: goto st598;
		case 111: goto st598;
	}
	goto tr167;
st598:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof598;
case 598:
	switch( (*( sm->p)) ) {
		case 84: goto st599;
		case 116: goto st599;
	}
	goto tr167;
st599:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof599;
case 599:
	switch( (*( sm->p)) ) {
		case 69: goto st600;
		case 101: goto st600;
	}
	goto tr167;
st600:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof600;
case 600:
	if ( (*( sm->p)) == 93 )
		goto tr291;
	goto tr167;
st601:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof601;
case 601:
	switch( (*( sm->p)) ) {
		case 80: goto st602;
		case 93: goto tr320;
		case 112: goto st602;
	}
	goto tr167;
st602:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof602;
case 602:
	switch( (*( sm->p)) ) {
		case 79: goto st603;
		case 111: goto st603;
	}
	goto tr167;
st603:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof603;
case 603:
	switch( (*( sm->p)) ) {
		case 73: goto st604;
		case 105: goto st604;
	}
	goto tr167;
st604:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof604;
case 604:
	switch( (*( sm->p)) ) {
		case 76: goto st605;
		case 108: goto st605;
	}
	goto tr167;
st605:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof605;
case 605:
	switch( (*( sm->p)) ) {
		case 69: goto st606;
		case 101: goto st606;
	}
	goto tr167;
st606:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof606;
case 606:
	switch( (*( sm->p)) ) {
		case 82: goto st607;
		case 114: goto st607;
	}
	goto tr167;
st607:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof607;
case 607:
	switch( (*( sm->p)) ) {
		case 83: goto st608;
		case 93: goto tr328;
		case 115: goto st608;
	}
	goto tr167;
st608:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof608;
case 608:
	if ( (*( sm->p)) == 93 )
		goto tr328;
	goto tr167;
st609:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof609;
case 609:
	switch( (*( sm->p)) ) {
		case 78: goto st610;
		case 110: goto st610;
	}
	goto tr167;
st610:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof610;
case 610:
	if ( (*( sm->p)) == 93 )
		goto tr335;
	goto tr167;
st611:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof611;
case 611:
	if ( (*( sm->p)) == 93 )
		goto tr336;
	goto tr167;
tr819:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
	goto st792;
st792:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof792;
case 792:
#line 11573 "ext/dtext/dtext.cpp"
	if ( (*( sm->p)) == 123 )
		goto st612;
	goto tr829;
st612:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof612;
case 612:
	if ( (*( sm->p)) == 125 )
		goto tr167;
	goto tr645;
tr645:
#line 45 "ext/dtext/dtext.cpp.rl"
	{
  sm->a1 = sm->p;
}
	goto st613;
st613:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof613;
case 613:
#line 11594 "ext/dtext/dtext.cpp"
	if ( (*( sm->p)) == 125 )
		goto tr647;
	goto st613;
tr647:
#line 49 "ext/dtext/dtext.cpp.rl"
	{
  sm->a2 = sm->p;
}
	goto st614;
st614:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof614;
case 614:
#line 11608 "ext/dtext/dtext.cpp"
	if ( (*( sm->p)) == 125 )
		goto tr648;
	goto tr167;
tr649:
#line 479 "ext/dtext/dtext.cpp.rl"
	{{( sm->p) = ((( sm->te)))-1;}{
    append_c_html_escaped(sm, (*( sm->p)));
  }}
	goto st793;
tr654:
#line 472 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_rewind(sm);
    { sm->cs = ( (sm->stack.data()))[--( sm->top)];goto _again;}
  }}
	goto st793;
tr976:
#line 479 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{
    append_c_html_escaped(sm, (*( sm->p)));
  }}
	goto st793;
tr977:
#line 477 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;}
	goto st793;
tr980:
#line 479 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append_c_html_escaped(sm, (*( sm->p)));
  }}
	goto st793;
st793:
#line 1 "NONE"
	{( sm->ts) = 0;}
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof793;
case 793:
#line 1 "NONE"
	{( sm->ts) = ( sm->p);}
#line 11649 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr977;
		case 60: goto tr978;
		case 91: goto tr979;
	}
	goto tr976;
tr978:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
	goto st794;
st794:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof794;
case 794:
#line 11664 "ext/dtext/dtext.cpp"
	if ( (*( sm->p)) == 47 )
		goto st615;
	goto tr980;
st615:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof615;
case 615:
	switch( (*( sm->p)) ) {
		case 67: goto st616;
		case 99: goto st616;
	}
	goto tr649;
st616:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof616;
case 616:
	switch( (*( sm->p)) ) {
		case 79: goto st617;
		case 111: goto st617;
	}
	goto tr649;
st617:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof617;
case 617:
	switch( (*( sm->p)) ) {
		case 68: goto st618;
		case 100: goto st618;
	}
	goto tr649;
st618:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof618;
case 618:
	switch( (*( sm->p)) ) {
		case 69: goto st619;
		case 101: goto st619;
	}
	goto tr649;
st619:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof619;
case 619:
	if ( (*( sm->p)) == 62 )
		goto tr654;
	goto tr649;
tr979:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
	goto st795;
st795:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof795;
case 795:
#line 11719 "ext/dtext/dtext.cpp"
	if ( (*( sm->p)) == 47 )
		goto st620;
	goto tr980;
st620:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof620;
case 620:
	switch( (*( sm->p)) ) {
		case 67: goto st621;
		case 99: goto st621;
	}
	goto tr649;
st621:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof621;
case 621:
	switch( (*( sm->p)) ) {
		case 79: goto st622;
		case 111: goto st622;
	}
	goto tr649;
st622:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof622;
case 622:
	switch( (*( sm->p)) ) {
		case 68: goto st623;
		case 100: goto st623;
	}
	goto tr649;
st623:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof623;
case 623:
	switch( (*( sm->p)) ) {
		case 69: goto st624;
		case 101: goto st624;
	}
	goto tr649;
st624:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof624;
case 624:
	if ( (*( sm->p)) == 93 )
		goto tr654;
	goto tr649;
tr659:
#line 503 "ext/dtext/dtext.cpp.rl"
	{{( sm->p) = ((( sm->te)))-1;}{
    append_c_html_escaped(sm, (*( sm->p)));
  }}
	goto st796;
tr667:
#line 485 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{
    if (dstack_check(sm, BLOCK_NODTEXT)) {
      g_debug("block dstack check");
      dstack_pop(sm);
      append_block(sm, "</p>");
      { sm->cs = ( (sm->stack.data()))[--( sm->top)];goto _again;}
    } else if (dstack_check(sm, INLINE_NODTEXT)) {
      g_debug("inline dstack check");
      dstack_rewind(sm);
      { sm->cs = ( (sm->stack.data()))[--( sm->top)];goto _again;}
    } else {
      g_debug("else dstack check");
      append(sm, "[/nodtext]");
    }
  }}
	goto st796;
tr983:
#line 503 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{
    append_c_html_escaped(sm, (*( sm->p)));
  }}
	goto st796;
tr984:
#line 501 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;}
	goto st796;
tr987:
#line 503 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append_c_html_escaped(sm, (*( sm->p)));
  }}
	goto st796;
st796:
#line 1 "NONE"
	{( sm->ts) = 0;}
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof796;
case 796:
#line 1 "NONE"
	{( sm->ts) = ( sm->p);}
#line 11814 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr984;
		case 60: goto tr985;
		case 91: goto tr986;
	}
	goto tr983;
tr985:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
	goto st797;
st797:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof797;
case 797:
#line 11829 "ext/dtext/dtext.cpp"
	if ( (*( sm->p)) == 47 )
		goto st625;
	goto tr987;
st625:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof625;
case 625:
	switch( (*( sm->p)) ) {
		case 78: goto st626;
		case 110: goto st626;
	}
	goto tr659;
st626:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof626;
case 626:
	switch( (*( sm->p)) ) {
		case 79: goto st627;
		case 111: goto st627;
	}
	goto tr659;
st627:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof627;
case 627:
	switch( (*( sm->p)) ) {
		case 68: goto st628;
		case 100: goto st628;
	}
	goto tr659;
st628:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof628;
case 628:
	switch( (*( sm->p)) ) {
		case 84: goto st629;
		case 116: goto st629;
	}
	goto tr659;
st629:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof629;
case 629:
	switch( (*( sm->p)) ) {
		case 69: goto st630;
		case 101: goto st630;
	}
	goto tr659;
st630:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof630;
case 630:
	switch( (*( sm->p)) ) {
		case 88: goto st631;
		case 120: goto st631;
	}
	goto tr659;
st631:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof631;
case 631:
	switch( (*( sm->p)) ) {
		case 84: goto st632;
		case 116: goto st632;
	}
	goto tr659;
st632:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof632;
case 632:
	if ( (*( sm->p)) == 62 )
		goto tr667;
	goto tr659;
tr986:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
	goto st798;
st798:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof798;
case 798:
#line 11911 "ext/dtext/dtext.cpp"
	if ( (*( sm->p)) == 47 )
		goto st633;
	goto tr987;
st633:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof633;
case 633:
	switch( (*( sm->p)) ) {
		case 78: goto st634;
		case 110: goto st634;
	}
	goto tr659;
st634:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof634;
case 634:
	switch( (*( sm->p)) ) {
		case 79: goto st635;
		case 111: goto st635;
	}
	goto tr659;
st635:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof635;
case 635:
	switch( (*( sm->p)) ) {
		case 68: goto st636;
		case 100: goto st636;
	}
	goto tr659;
st636:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof636;
case 636:
	switch( (*( sm->p)) ) {
		case 84: goto st637;
		case 116: goto st637;
	}
	goto tr659;
st637:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof637;
case 637:
	switch( (*( sm->p)) ) {
		case 69: goto st638;
		case 101: goto st638;
	}
	goto tr659;
st638:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof638;
case 638:
	switch( (*( sm->p)) ) {
		case 88: goto st639;
		case 120: goto st639;
	}
	goto tr659;
st639:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof639;
case 639:
	switch( (*( sm->p)) ) {
		case 84: goto st640;
		case 116: goto st640;
	}
	goto tr659;
st640:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof640;
case 640:
	if ( (*( sm->p)) == 93 )
		goto tr667;
	goto tr659;
tr675:
#line 549 "ext/dtext/dtext.cpp.rl"
	{{( sm->p) = ((( sm->te)))-1;}}
	goto st799;
tr684:
#line 543 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{
    if (dstack_close_block(sm, BLOCK_TABLE, "</table>")) {
      { sm->cs = ( (sm->stack.data()))[--( sm->top)];goto _again;}
    }
  }}
	goto st799;
tr688:
#line 521 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_close_block(sm, BLOCK_TBODY, "</tbody>");
  }}
	goto st799;
tr692:
#line 513 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_close_block(sm, BLOCK_THEAD, "</thead>");
  }}
	goto st799;
tr693:
#line 534 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_close_block(sm, BLOCK_TR, "</tr>");
  }}
	goto st799;
tr701:
#line 517 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_open_block(sm, BLOCK_TBODY, "<tbody>");
  }}
	goto st799;
tr702:
#line 538 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_open_block(sm, BLOCK_TD, "<td>");
    {
  size_t len = sm->stack.size();

  if (len > MAX_STACK_DEPTH) {
    sm->error = "too many nested elements";
    {( sm->p)++;  sm->cs = 0; goto _out;}
  }

  if (sm->top >= len) {
    g_debug("growing sm->stack %zi", len + 16);
    sm->stack.resize(len + 16, 0);
  }
{( (sm->stack.data()))[( sm->top)++] = 799;goto st718;}}
  }}
	goto st799;
tr703:
#line 525 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_open_block(sm, BLOCK_TH, "<th>");
    {
  size_t len = sm->stack.size();

  if (len > MAX_STACK_DEPTH) {
    sm->error = "too many nested elements";
    {( sm->p)++;  sm->cs = 0; goto _out;}
  }

  if (sm->top >= len) {
    g_debug("growing sm->stack %zi", len + 16);
    sm->stack.resize(len + 16, 0);
  }
{( (sm->stack.data()))[( sm->top)++] = 799;goto st718;}}
  }}
	goto st799;
tr707:
#line 509 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_open_block(sm, BLOCK_THEAD, "<thead>");
  }}
	goto st799;
tr708:
#line 530 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_open_block(sm, BLOCK_TR, "<tr>");
  }}
	goto st799;
tr990:
#line 549 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;}
	goto st799;
tr993:
#line 549 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;}
	goto st799;
st799:
#line 1 "NONE"
	{( sm->ts) = 0;}
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof799;
case 799:
#line 1 "NONE"
	{( sm->ts) = ( sm->p);}
#line 12087 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 60: goto tr991;
		case 91: goto tr992;
	}
	goto tr990;
tr991:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
	goto st800;
st800:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof800;
case 800:
#line 12101 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 47: goto st641;
		case 84: goto st656;
		case 116: goto st656;
	}
	goto tr993;
st641:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof641;
case 641:
	switch( (*( sm->p)) ) {
		case 84: goto st642;
		case 116: goto st642;
	}
	goto tr675;
st642:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof642;
case 642:
	switch( (*( sm->p)) ) {
		case 65: goto st643;
		case 66: goto st647;
		case 72: goto st651;
		case 82: goto st655;
		case 97: goto st643;
		case 98: goto st647;
		case 104: goto st651;
		case 114: goto st655;
	}
	goto tr675;
st643:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof643;
case 643:
	switch( (*( sm->p)) ) {
		case 66: goto st644;
		case 98: goto st644;
	}
	goto tr675;
st644:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof644;
case 644:
	switch( (*( sm->p)) ) {
		case 76: goto st645;
		case 108: goto st645;
	}
	goto tr675;
st645:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof645;
case 645:
	switch( (*( sm->p)) ) {
		case 69: goto st646;
		case 101: goto st646;
	}
	goto tr675;
st646:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof646;
case 646:
	if ( (*( sm->p)) == 62 )
		goto tr684;
	goto tr675;
st647:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof647;
case 647:
	switch( (*( sm->p)) ) {
		case 79: goto st648;
		case 111: goto st648;
	}
	goto tr675;
st648:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof648;
case 648:
	switch( (*( sm->p)) ) {
		case 68: goto st649;
		case 100: goto st649;
	}
	goto tr675;
st649:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof649;
case 649:
	switch( (*( sm->p)) ) {
		case 89: goto st650;
		case 121: goto st650;
	}
	goto tr675;
st650:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof650;
case 650:
	if ( (*( sm->p)) == 62 )
		goto tr688;
	goto tr675;
st651:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof651;
case 651:
	switch( (*( sm->p)) ) {
		case 69: goto st652;
		case 101: goto st652;
	}
	goto tr675;
st652:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof652;
case 652:
	switch( (*( sm->p)) ) {
		case 65: goto st653;
		case 97: goto st653;
	}
	goto tr675;
st653:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof653;
case 653:
	switch( (*( sm->p)) ) {
		case 68: goto st654;
		case 100: goto st654;
	}
	goto tr675;
st654:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof654;
case 654:
	if ( (*( sm->p)) == 62 )
		goto tr692;
	goto tr675;
st655:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof655;
case 655:
	if ( (*( sm->p)) == 62 )
		goto tr693;
	goto tr675;
st656:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof656;
case 656:
	switch( (*( sm->p)) ) {
		case 66: goto st657;
		case 68: goto st661;
		case 72: goto st662;
		case 82: goto st666;
		case 98: goto st657;
		case 100: goto st661;
		case 104: goto st662;
		case 114: goto st666;
	}
	goto tr675;
st657:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof657;
case 657:
	switch( (*( sm->p)) ) {
		case 79: goto st658;
		case 111: goto st658;
	}
	goto tr675;
st658:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof658;
case 658:
	switch( (*( sm->p)) ) {
		case 68: goto st659;
		case 100: goto st659;
	}
	goto tr675;
st659:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof659;
case 659:
	switch( (*( sm->p)) ) {
		case 89: goto st660;
		case 121: goto st660;
	}
	goto tr675;
st660:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof660;
case 660:
	if ( (*( sm->p)) == 62 )
		goto tr701;
	goto tr675;
st661:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof661;
case 661:
	if ( (*( sm->p)) == 62 )
		goto tr702;
	goto tr675;
st662:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof662;
case 662:
	switch( (*( sm->p)) ) {
		case 62: goto tr703;
		case 69: goto st663;
		case 101: goto st663;
	}
	goto tr675;
st663:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof663;
case 663:
	switch( (*( sm->p)) ) {
		case 65: goto st664;
		case 97: goto st664;
	}
	goto tr675;
st664:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof664;
case 664:
	switch( (*( sm->p)) ) {
		case 68: goto st665;
		case 100: goto st665;
	}
	goto tr675;
st665:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof665;
case 665:
	if ( (*( sm->p)) == 62 )
		goto tr707;
	goto tr675;
st666:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof666;
case 666:
	if ( (*( sm->p)) == 62 )
		goto tr708;
	goto tr675;
tr992:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
	goto st801;
st801:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof801;
case 801:
#line 12347 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 47: goto st667;
		case 84: goto st682;
		case 116: goto st682;
	}
	goto tr993;
st667:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof667;
case 667:
	switch( (*( sm->p)) ) {
		case 84: goto st668;
		case 116: goto st668;
	}
	goto tr675;
st668:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof668;
case 668:
	switch( (*( sm->p)) ) {
		case 65: goto st669;
		case 66: goto st673;
		case 72: goto st677;
		case 82: goto st681;
		case 97: goto st669;
		case 98: goto st673;
		case 104: goto st677;
		case 114: goto st681;
	}
	goto tr675;
st669:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof669;
case 669:
	switch( (*( sm->p)) ) {
		case 66: goto st670;
		case 98: goto st670;
	}
	goto tr675;
st670:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof670;
case 670:
	switch( (*( sm->p)) ) {
		case 76: goto st671;
		case 108: goto st671;
	}
	goto tr675;
st671:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof671;
case 671:
	switch( (*( sm->p)) ) {
		case 69: goto st672;
		case 101: goto st672;
	}
	goto tr675;
st672:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof672;
case 672:
	if ( (*( sm->p)) == 93 )
		goto tr684;
	goto tr675;
st673:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof673;
case 673:
	switch( (*( sm->p)) ) {
		case 79: goto st674;
		case 111: goto st674;
	}
	goto tr675;
st674:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof674;
case 674:
	switch( (*( sm->p)) ) {
		case 68: goto st675;
		case 100: goto st675;
	}
	goto tr675;
st675:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof675;
case 675:
	switch( (*( sm->p)) ) {
		case 89: goto st676;
		case 121: goto st676;
	}
	goto tr675;
st676:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof676;
case 676:
	if ( (*( sm->p)) == 93 )
		goto tr688;
	goto tr675;
st677:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof677;
case 677:
	switch( (*( sm->p)) ) {
		case 69: goto st678;
		case 101: goto st678;
	}
	goto tr675;
st678:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof678;
case 678:
	switch( (*( sm->p)) ) {
		case 65: goto st679;
		case 97: goto st679;
	}
	goto tr675;
st679:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof679;
case 679:
	switch( (*( sm->p)) ) {
		case 68: goto st680;
		case 100: goto st680;
	}
	goto tr675;
st680:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof680;
case 680:
	if ( (*( sm->p)) == 93 )
		goto tr692;
	goto tr675;
st681:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof681;
case 681:
	if ( (*( sm->p)) == 93 )
		goto tr693;
	goto tr675;
st682:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof682;
case 682:
	switch( (*( sm->p)) ) {
		case 66: goto st683;
		case 68: goto st687;
		case 72: goto st688;
		case 82: goto st692;
		case 98: goto st683;
		case 100: goto st687;
		case 104: goto st688;
		case 114: goto st692;
	}
	goto tr675;
st683:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof683;
case 683:
	switch( (*( sm->p)) ) {
		case 79: goto st684;
		case 111: goto st684;
	}
	goto tr675;
st684:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof684;
case 684:
	switch( (*( sm->p)) ) {
		case 68: goto st685;
		case 100: goto st685;
	}
	goto tr675;
st685:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof685;
case 685:
	switch( (*( sm->p)) ) {
		case 89: goto st686;
		case 121: goto st686;
	}
	goto tr675;
st686:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof686;
case 686:
	if ( (*( sm->p)) == 93 )
		goto tr701;
	goto tr675;
st687:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof687;
case 687:
	if ( (*( sm->p)) == 93 )
		goto tr702;
	goto tr675;
st688:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof688;
case 688:
	switch( (*( sm->p)) ) {
		case 69: goto st689;
		case 93: goto tr703;
		case 101: goto st689;
	}
	goto tr675;
st689:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof689;
case 689:
	switch( (*( sm->p)) ) {
		case 65: goto st690;
		case 97: goto st690;
	}
	goto tr675;
st690:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof690;
case 690:
	switch( (*( sm->p)) ) {
		case 68: goto st691;
		case 100: goto st691;
	}
	goto tr675;
st691:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof691;
case 691:
	if ( (*( sm->p)) == 93 )
		goto tr707;
	goto tr675;
st692:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof692;
case 692:
	if ( (*( sm->p)) == 93 )
		goto tr708;
	goto tr675;
tr733:
#line 1 "NONE"
	{	switch( ( sm->act) ) {
	case 102:
	{{( sm->p) = ((( sm->te)))-1;}
    dstack_close_list(sm);
    {( sm->p) = (( sm->ts))-1;}
    { sm->cs = ( (sm->stack.data()))[--( sm->top)];goto _again;}
  }
	break;
	default:
	{{( sm->p) = ((( sm->te)))-1;}}
	break;
	}
	}
	goto st802;
tr735:
#line 588 "ext/dtext/dtext.cpp.rl"
	{{( sm->p) = ((( sm->te)))-1;}{
    dstack_rewind(sm);
    ( sm->p)--;
    { sm->cs = ( (sm->stack.data()))[--( sm->top)];goto _again;}
  }}
	goto st802;
tr998:
#line 588 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_rewind(sm);
    ( sm->p)--;
    { sm->cs = ( (sm->stack.data()))[--( sm->top)];goto _again;}
  }}
	goto st802;
tr1003:
#line 588 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    dstack_rewind(sm);
    ( sm->p)--;
    { sm->cs = ( (sm->stack.data()))[--( sm->top)];goto _again;}
  }}
	goto st802;
tr1004:
#line 57 "ext/dtext/dtext.cpp.rl"
	{
  sm->b2 = sm->p;
}
#line 553 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    int prev_nest = sm->list_nest;
    append_closing_p_if(sm);
    g_debug("list start");
    sm->list_nest = sm->a2 - sm->a1;
    {( sm->p) = (( sm->b1))-1;}

    if (sm->list_nest > prev_nest) {
      for (int i = prev_nest; i < sm->list_nest; ++i) {
        dstack_open_block(sm, BLOCK_UL, "<ul>");
      }
    } else if (sm->list_nest < prev_nest) {
      for (int i = sm->list_nest; i < prev_nest; ++i) {
        if (dstack_check(sm, BLOCK_UL)) {
          dstack_rewind(sm);
        }
      }
    }

    dstack_open_block(sm, BLOCK_LI, "<li>");

    g_debug("  call inline");

    {
  size_t len = sm->stack.size();

  if (len > MAX_STACK_DEPTH) {
    sm->error = "too many nested elements";
    {( sm->p)++;  sm->cs = 0; goto _out;}
  }

  if (sm->top >= len) {
    g_debug("growing sm->stack %zi", len + 16);
    sm->stack.resize(len + 16, 0);
  }
{( (sm->stack.data()))[( sm->top)++] = 802;goto st718;}}
  }}
	goto st802;
st802:
#line 1 "NONE"
	{( sm->ts) = 0;}
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof802;
case 802:
#line 1 "NONE"
	{( sm->ts) = ( sm->p);}
#line 12677 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 10: goto tr999;
		case 13: goto st804;
		case 42: goto tr1001;
	}
	goto tr998;
tr734:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 580 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 102;}
	goto st803;
tr999:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 586 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 103;}
	goto st803;
st803:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof803;
case 803:
#line 12700 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 10: goto tr734;
		case 13: goto st693;
	}
	goto tr733;
st693:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof693;
case 693:
	if ( (*( sm->p)) == 10 )
		goto tr734;
	goto tr733;
st804:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof804;
case 804:
	if ( (*( sm->p)) == 10 )
		goto tr999;
	goto tr1003;
tr1001:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 45 "ext/dtext/dtext.cpp.rl"
	{
  sm->a1 = sm->p;
}
	goto st805;
st805:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof805;
case 805:
#line 12732 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto tr738;
		case 32: goto tr738;
		case 42: goto st695;
	}
	goto tr1003;
tr738:
#line 49 "ext/dtext/dtext.cpp.rl"
	{
  sm->a2 = sm->p;
}
	goto st694;
st694:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof694;
case 694:
#line 12749 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto tr737;
		case 10: goto tr735;
		case 13: goto tr735;
		case 32: goto tr737;
	}
	goto tr736;
tr736:
#line 53 "ext/dtext/dtext.cpp.rl"
	{
  sm->b1 = sm->p;
}
	goto st806;
st806:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof806;
case 806:
#line 12767 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 10: goto tr1004;
		case 13: goto tr1004;
	}
	goto st806;
tr737:
#line 53 "ext/dtext/dtext.cpp.rl"
	{
  sm->b1 = sm->p;
}
	goto st807;
st807:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof807;
case 807:
#line 12783 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto tr737;
		case 10: goto tr1004;
		case 13: goto tr1004;
		case 32: goto tr737;
	}
	goto tr736;
st695:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof695;
case 695:
	switch( (*( sm->p)) ) {
		case 9: goto tr738;
		case 32: goto tr738;
		case 42: goto st695;
	}
	goto tr735;
	}
	_test_eof696:  sm->cs = 696; goto _test_eof; 
	_test_eof697:  sm->cs = 697; goto _test_eof; 
	_test_eof0:  sm->cs = 0; goto _test_eof; 
	_test_eof1:  sm->cs = 1; goto _test_eof; 
	_test_eof2:  sm->cs = 2; goto _test_eof; 
	_test_eof3:  sm->cs = 3; goto _test_eof; 
	_test_eof4:  sm->cs = 4; goto _test_eof; 
	_test_eof698:  sm->cs = 698; goto _test_eof; 
	_test_eof5:  sm->cs = 5; goto _test_eof; 
	_test_eof6:  sm->cs = 6; goto _test_eof; 
	_test_eof7:  sm->cs = 7; goto _test_eof; 
	_test_eof8:  sm->cs = 8; goto _test_eof; 
	_test_eof699:  sm->cs = 699; goto _test_eof; 
	_test_eof9:  sm->cs = 9; goto _test_eof; 
	_test_eof700:  sm->cs = 700; goto _test_eof; 
	_test_eof701:  sm->cs = 701; goto _test_eof; 
	_test_eof10:  sm->cs = 10; goto _test_eof; 
	_test_eof702:  sm->cs = 702; goto _test_eof; 
	_test_eof703:  sm->cs = 703; goto _test_eof; 
	_test_eof11:  sm->cs = 11; goto _test_eof; 
	_test_eof704:  sm->cs = 704; goto _test_eof; 
	_test_eof12:  sm->cs = 12; goto _test_eof; 
	_test_eof13:  sm->cs = 13; goto _test_eof; 
	_test_eof14:  sm->cs = 14; goto _test_eof; 
	_test_eof15:  sm->cs = 15; goto _test_eof; 
	_test_eof16:  sm->cs = 16; goto _test_eof; 
	_test_eof17:  sm->cs = 17; goto _test_eof; 
	_test_eof18:  sm->cs = 18; goto _test_eof; 
	_test_eof19:  sm->cs = 19; goto _test_eof; 
	_test_eof20:  sm->cs = 20; goto _test_eof; 
	_test_eof21:  sm->cs = 21; goto _test_eof; 
	_test_eof22:  sm->cs = 22; goto _test_eof; 
	_test_eof23:  sm->cs = 23; goto _test_eof; 
	_test_eof24:  sm->cs = 24; goto _test_eof; 
	_test_eof25:  sm->cs = 25; goto _test_eof; 
	_test_eof26:  sm->cs = 26; goto _test_eof; 
	_test_eof27:  sm->cs = 27; goto _test_eof; 
	_test_eof28:  sm->cs = 28; goto _test_eof; 
	_test_eof29:  sm->cs = 29; goto _test_eof; 
	_test_eof30:  sm->cs = 30; goto _test_eof; 
	_test_eof705:  sm->cs = 705; goto _test_eof; 
	_test_eof31:  sm->cs = 31; goto _test_eof; 
	_test_eof32:  sm->cs = 32; goto _test_eof; 
	_test_eof33:  sm->cs = 33; goto _test_eof; 
	_test_eof34:  sm->cs = 34; goto _test_eof; 
	_test_eof706:  sm->cs = 706; goto _test_eof; 
	_test_eof35:  sm->cs = 35; goto _test_eof; 
	_test_eof36:  sm->cs = 36; goto _test_eof; 
	_test_eof37:  sm->cs = 37; goto _test_eof; 
	_test_eof38:  sm->cs = 38; goto _test_eof; 
	_test_eof39:  sm->cs = 39; goto _test_eof; 
	_test_eof40:  sm->cs = 40; goto _test_eof; 
	_test_eof41:  sm->cs = 41; goto _test_eof; 
	_test_eof707:  sm->cs = 707; goto _test_eof; 
	_test_eof42:  sm->cs = 42; goto _test_eof; 
	_test_eof43:  sm->cs = 43; goto _test_eof; 
	_test_eof708:  sm->cs = 708; goto _test_eof; 
	_test_eof44:  sm->cs = 44; goto _test_eof; 
	_test_eof45:  sm->cs = 45; goto _test_eof; 
	_test_eof46:  sm->cs = 46; goto _test_eof; 
	_test_eof47:  sm->cs = 47; goto _test_eof; 
	_test_eof48:  sm->cs = 48; goto _test_eof; 
	_test_eof49:  sm->cs = 49; goto _test_eof; 
	_test_eof50:  sm->cs = 50; goto _test_eof; 
	_test_eof709:  sm->cs = 709; goto _test_eof; 
	_test_eof51:  sm->cs = 51; goto _test_eof; 
	_test_eof52:  sm->cs = 52; goto _test_eof; 
	_test_eof53:  sm->cs = 53; goto _test_eof; 
	_test_eof54:  sm->cs = 54; goto _test_eof; 
	_test_eof55:  sm->cs = 55; goto _test_eof; 
	_test_eof56:  sm->cs = 56; goto _test_eof; 
	_test_eof57:  sm->cs = 57; goto _test_eof; 
	_test_eof710:  sm->cs = 710; goto _test_eof; 
	_test_eof58:  sm->cs = 58; goto _test_eof; 
	_test_eof59:  sm->cs = 59; goto _test_eof; 
	_test_eof60:  sm->cs = 60; goto _test_eof; 
	_test_eof61:  sm->cs = 61; goto _test_eof; 
	_test_eof62:  sm->cs = 62; goto _test_eof; 
	_test_eof63:  sm->cs = 63; goto _test_eof; 
	_test_eof64:  sm->cs = 64; goto _test_eof; 
	_test_eof711:  sm->cs = 711; goto _test_eof; 
	_test_eof65:  sm->cs = 65; goto _test_eof; 
	_test_eof66:  sm->cs = 66; goto _test_eof; 
	_test_eof67:  sm->cs = 67; goto _test_eof; 
	_test_eof712:  sm->cs = 712; goto _test_eof; 
	_test_eof713:  sm->cs = 713; goto _test_eof; 
	_test_eof714:  sm->cs = 714; goto _test_eof; 
	_test_eof68:  sm->cs = 68; goto _test_eof; 
	_test_eof69:  sm->cs = 69; goto _test_eof; 
	_test_eof70:  sm->cs = 70; goto _test_eof; 
	_test_eof71:  sm->cs = 71; goto _test_eof; 
	_test_eof72:  sm->cs = 72; goto _test_eof; 
	_test_eof73:  sm->cs = 73; goto _test_eof; 
	_test_eof74:  sm->cs = 74; goto _test_eof; 
	_test_eof75:  sm->cs = 75; goto _test_eof; 
	_test_eof76:  sm->cs = 76; goto _test_eof; 
	_test_eof77:  sm->cs = 77; goto _test_eof; 
	_test_eof78:  sm->cs = 78; goto _test_eof; 
	_test_eof79:  sm->cs = 79; goto _test_eof; 
	_test_eof80:  sm->cs = 80; goto _test_eof; 
	_test_eof81:  sm->cs = 81; goto _test_eof; 
	_test_eof82:  sm->cs = 82; goto _test_eof; 
	_test_eof83:  sm->cs = 83; goto _test_eof; 
	_test_eof84:  sm->cs = 84; goto _test_eof; 
	_test_eof85:  sm->cs = 85; goto _test_eof; 
	_test_eof86:  sm->cs = 86; goto _test_eof; 
	_test_eof87:  sm->cs = 87; goto _test_eof; 
	_test_eof88:  sm->cs = 88; goto _test_eof; 
	_test_eof89:  sm->cs = 89; goto _test_eof; 
	_test_eof90:  sm->cs = 90; goto _test_eof; 
	_test_eof91:  sm->cs = 91; goto _test_eof; 
	_test_eof92:  sm->cs = 92; goto _test_eof; 
	_test_eof93:  sm->cs = 93; goto _test_eof; 
	_test_eof94:  sm->cs = 94; goto _test_eof; 
	_test_eof95:  sm->cs = 95; goto _test_eof; 
	_test_eof96:  sm->cs = 96; goto _test_eof; 
	_test_eof97:  sm->cs = 97; goto _test_eof; 
	_test_eof98:  sm->cs = 98; goto _test_eof; 
	_test_eof99:  sm->cs = 99; goto _test_eof; 
	_test_eof100:  sm->cs = 100; goto _test_eof; 
	_test_eof101:  sm->cs = 101; goto _test_eof; 
	_test_eof102:  sm->cs = 102; goto _test_eof; 
	_test_eof103:  sm->cs = 103; goto _test_eof; 
	_test_eof104:  sm->cs = 104; goto _test_eof; 
	_test_eof105:  sm->cs = 105; goto _test_eof; 
	_test_eof106:  sm->cs = 106; goto _test_eof; 
	_test_eof107:  sm->cs = 107; goto _test_eof; 
	_test_eof108:  sm->cs = 108; goto _test_eof; 
	_test_eof109:  sm->cs = 109; goto _test_eof; 
	_test_eof110:  sm->cs = 110; goto _test_eof; 
	_test_eof111:  sm->cs = 111; goto _test_eof; 
	_test_eof112:  sm->cs = 112; goto _test_eof; 
	_test_eof113:  sm->cs = 113; goto _test_eof; 
	_test_eof114:  sm->cs = 114; goto _test_eof; 
	_test_eof115:  sm->cs = 115; goto _test_eof; 
	_test_eof715:  sm->cs = 715; goto _test_eof; 
	_test_eof716:  sm->cs = 716; goto _test_eof; 
	_test_eof116:  sm->cs = 116; goto _test_eof; 
	_test_eof117:  sm->cs = 117; goto _test_eof; 
	_test_eof118:  sm->cs = 118; goto _test_eof; 
	_test_eof119:  sm->cs = 119; goto _test_eof; 
	_test_eof120:  sm->cs = 120; goto _test_eof; 
	_test_eof121:  sm->cs = 121; goto _test_eof; 
	_test_eof122:  sm->cs = 122; goto _test_eof; 
	_test_eof123:  sm->cs = 123; goto _test_eof; 
	_test_eof124:  sm->cs = 124; goto _test_eof; 
	_test_eof125:  sm->cs = 125; goto _test_eof; 
	_test_eof126:  sm->cs = 126; goto _test_eof; 
	_test_eof127:  sm->cs = 127; goto _test_eof; 
	_test_eof128:  sm->cs = 128; goto _test_eof; 
	_test_eof129:  sm->cs = 129; goto _test_eof; 
	_test_eof130:  sm->cs = 130; goto _test_eof; 
	_test_eof131:  sm->cs = 131; goto _test_eof; 
	_test_eof132:  sm->cs = 132; goto _test_eof; 
	_test_eof133:  sm->cs = 133; goto _test_eof; 
	_test_eof134:  sm->cs = 134; goto _test_eof; 
	_test_eof717:  sm->cs = 717; goto _test_eof; 
	_test_eof135:  sm->cs = 135; goto _test_eof; 
	_test_eof136:  sm->cs = 136; goto _test_eof; 
	_test_eof137:  sm->cs = 137; goto _test_eof; 
	_test_eof138:  sm->cs = 138; goto _test_eof; 
	_test_eof139:  sm->cs = 139; goto _test_eof; 
	_test_eof140:  sm->cs = 140; goto _test_eof; 
	_test_eof141:  sm->cs = 141; goto _test_eof; 
	_test_eof142:  sm->cs = 142; goto _test_eof; 
	_test_eof143:  sm->cs = 143; goto _test_eof; 
	_test_eof718:  sm->cs = 718; goto _test_eof; 
	_test_eof719:  sm->cs = 719; goto _test_eof; 
	_test_eof144:  sm->cs = 144; goto _test_eof; 
	_test_eof145:  sm->cs = 145; goto _test_eof; 
	_test_eof146:  sm->cs = 146; goto _test_eof; 
	_test_eof147:  sm->cs = 147; goto _test_eof; 
	_test_eof148:  sm->cs = 148; goto _test_eof; 
	_test_eof149:  sm->cs = 149; goto _test_eof; 
	_test_eof720:  sm->cs = 720; goto _test_eof; 
	_test_eof150:  sm->cs = 150; goto _test_eof; 
	_test_eof151:  sm->cs = 151; goto _test_eof; 
	_test_eof152:  sm->cs = 152; goto _test_eof; 
	_test_eof153:  sm->cs = 153; goto _test_eof; 
	_test_eof154:  sm->cs = 154; goto _test_eof; 
	_test_eof721:  sm->cs = 721; goto _test_eof; 
	_test_eof722:  sm->cs = 722; goto _test_eof; 
	_test_eof155:  sm->cs = 155; goto _test_eof; 
	_test_eof156:  sm->cs = 156; goto _test_eof; 
	_test_eof157:  sm->cs = 157; goto _test_eof; 
	_test_eof723:  sm->cs = 723; goto _test_eof; 
	_test_eof724:  sm->cs = 724; goto _test_eof; 
	_test_eof725:  sm->cs = 725; goto _test_eof; 
	_test_eof726:  sm->cs = 726; goto _test_eof; 
	_test_eof158:  sm->cs = 158; goto _test_eof; 
	_test_eof159:  sm->cs = 159; goto _test_eof; 
	_test_eof160:  sm->cs = 160; goto _test_eof; 
	_test_eof727:  sm->cs = 727; goto _test_eof; 
	_test_eof161:  sm->cs = 161; goto _test_eof; 
	_test_eof162:  sm->cs = 162; goto _test_eof; 
	_test_eof163:  sm->cs = 163; goto _test_eof; 
	_test_eof164:  sm->cs = 164; goto _test_eof; 
	_test_eof165:  sm->cs = 165; goto _test_eof; 
	_test_eof166:  sm->cs = 166; goto _test_eof; 
	_test_eof167:  sm->cs = 167; goto _test_eof; 
	_test_eof168:  sm->cs = 168; goto _test_eof; 
	_test_eof169:  sm->cs = 169; goto _test_eof; 
	_test_eof170:  sm->cs = 170; goto _test_eof; 
	_test_eof171:  sm->cs = 171; goto _test_eof; 
	_test_eof172:  sm->cs = 172; goto _test_eof; 
	_test_eof173:  sm->cs = 173; goto _test_eof; 
	_test_eof174:  sm->cs = 174; goto _test_eof; 
	_test_eof175:  sm->cs = 175; goto _test_eof; 
	_test_eof176:  sm->cs = 176; goto _test_eof; 
	_test_eof177:  sm->cs = 177; goto _test_eof; 
	_test_eof178:  sm->cs = 178; goto _test_eof; 
	_test_eof728:  sm->cs = 728; goto _test_eof; 
	_test_eof179:  sm->cs = 179; goto _test_eof; 
	_test_eof180:  sm->cs = 180; goto _test_eof; 
	_test_eof181:  sm->cs = 181; goto _test_eof; 
	_test_eof182:  sm->cs = 182; goto _test_eof; 
	_test_eof183:  sm->cs = 183; goto _test_eof; 
	_test_eof729:  sm->cs = 729; goto _test_eof; 
	_test_eof730:  sm->cs = 730; goto _test_eof; 
	_test_eof184:  sm->cs = 184; goto _test_eof; 
	_test_eof185:  sm->cs = 185; goto _test_eof; 
	_test_eof186:  sm->cs = 186; goto _test_eof; 
	_test_eof731:  sm->cs = 731; goto _test_eof; 
	_test_eof732:  sm->cs = 732; goto _test_eof; 
	_test_eof187:  sm->cs = 187; goto _test_eof; 
	_test_eof733:  sm->cs = 733; goto _test_eof; 
	_test_eof188:  sm->cs = 188; goto _test_eof; 
	_test_eof189:  sm->cs = 189; goto _test_eof; 
	_test_eof190:  sm->cs = 190; goto _test_eof; 
	_test_eof191:  sm->cs = 191; goto _test_eof; 
	_test_eof192:  sm->cs = 192; goto _test_eof; 
	_test_eof193:  sm->cs = 193; goto _test_eof; 
	_test_eof194:  sm->cs = 194; goto _test_eof; 
	_test_eof195:  sm->cs = 195; goto _test_eof; 
	_test_eof196:  sm->cs = 196; goto _test_eof; 
	_test_eof197:  sm->cs = 197; goto _test_eof; 
	_test_eof198:  sm->cs = 198; goto _test_eof; 
	_test_eof734:  sm->cs = 734; goto _test_eof; 
	_test_eof199:  sm->cs = 199; goto _test_eof; 
	_test_eof200:  sm->cs = 200; goto _test_eof; 
	_test_eof201:  sm->cs = 201; goto _test_eof; 
	_test_eof202:  sm->cs = 202; goto _test_eof; 
	_test_eof203:  sm->cs = 203; goto _test_eof; 
	_test_eof204:  sm->cs = 204; goto _test_eof; 
	_test_eof205:  sm->cs = 205; goto _test_eof; 
	_test_eof206:  sm->cs = 206; goto _test_eof; 
	_test_eof207:  sm->cs = 207; goto _test_eof; 
	_test_eof208:  sm->cs = 208; goto _test_eof; 
	_test_eof209:  sm->cs = 209; goto _test_eof; 
	_test_eof210:  sm->cs = 210; goto _test_eof; 
	_test_eof211:  sm->cs = 211; goto _test_eof; 
	_test_eof212:  sm->cs = 212; goto _test_eof; 
	_test_eof213:  sm->cs = 213; goto _test_eof; 
	_test_eof214:  sm->cs = 214; goto _test_eof; 
	_test_eof215:  sm->cs = 215; goto _test_eof; 
	_test_eof216:  sm->cs = 216; goto _test_eof; 
	_test_eof217:  sm->cs = 217; goto _test_eof; 
	_test_eof218:  sm->cs = 218; goto _test_eof; 
	_test_eof219:  sm->cs = 219; goto _test_eof; 
	_test_eof220:  sm->cs = 220; goto _test_eof; 
	_test_eof221:  sm->cs = 221; goto _test_eof; 
	_test_eof222:  sm->cs = 222; goto _test_eof; 
	_test_eof223:  sm->cs = 223; goto _test_eof; 
	_test_eof224:  sm->cs = 224; goto _test_eof; 
	_test_eof225:  sm->cs = 225; goto _test_eof; 
	_test_eof226:  sm->cs = 226; goto _test_eof; 
	_test_eof227:  sm->cs = 227; goto _test_eof; 
	_test_eof228:  sm->cs = 228; goto _test_eof; 
	_test_eof229:  sm->cs = 229; goto _test_eof; 
	_test_eof230:  sm->cs = 230; goto _test_eof; 
	_test_eof231:  sm->cs = 231; goto _test_eof; 
	_test_eof232:  sm->cs = 232; goto _test_eof; 
	_test_eof233:  sm->cs = 233; goto _test_eof; 
	_test_eof234:  sm->cs = 234; goto _test_eof; 
	_test_eof235:  sm->cs = 235; goto _test_eof; 
	_test_eof236:  sm->cs = 236; goto _test_eof; 
	_test_eof237:  sm->cs = 237; goto _test_eof; 
	_test_eof238:  sm->cs = 238; goto _test_eof; 
	_test_eof239:  sm->cs = 239; goto _test_eof; 
	_test_eof240:  sm->cs = 240; goto _test_eof; 
	_test_eof241:  sm->cs = 241; goto _test_eof; 
	_test_eof242:  sm->cs = 242; goto _test_eof; 
	_test_eof243:  sm->cs = 243; goto _test_eof; 
	_test_eof244:  sm->cs = 244; goto _test_eof; 
	_test_eof245:  sm->cs = 245; goto _test_eof; 
	_test_eof246:  sm->cs = 246; goto _test_eof; 
	_test_eof247:  sm->cs = 247; goto _test_eof; 
	_test_eof248:  sm->cs = 248; goto _test_eof; 
	_test_eof249:  sm->cs = 249; goto _test_eof; 
	_test_eof250:  sm->cs = 250; goto _test_eof; 
	_test_eof251:  sm->cs = 251; goto _test_eof; 
	_test_eof252:  sm->cs = 252; goto _test_eof; 
	_test_eof253:  sm->cs = 253; goto _test_eof; 
	_test_eof254:  sm->cs = 254; goto _test_eof; 
	_test_eof255:  sm->cs = 255; goto _test_eof; 
	_test_eof256:  sm->cs = 256; goto _test_eof; 
	_test_eof257:  sm->cs = 257; goto _test_eof; 
	_test_eof258:  sm->cs = 258; goto _test_eof; 
	_test_eof259:  sm->cs = 259; goto _test_eof; 
	_test_eof260:  sm->cs = 260; goto _test_eof; 
	_test_eof261:  sm->cs = 261; goto _test_eof; 
	_test_eof262:  sm->cs = 262; goto _test_eof; 
	_test_eof263:  sm->cs = 263; goto _test_eof; 
	_test_eof264:  sm->cs = 264; goto _test_eof; 
	_test_eof265:  sm->cs = 265; goto _test_eof; 
	_test_eof266:  sm->cs = 266; goto _test_eof; 
	_test_eof267:  sm->cs = 267; goto _test_eof; 
	_test_eof268:  sm->cs = 268; goto _test_eof; 
	_test_eof269:  sm->cs = 269; goto _test_eof; 
	_test_eof270:  sm->cs = 270; goto _test_eof; 
	_test_eof271:  sm->cs = 271; goto _test_eof; 
	_test_eof272:  sm->cs = 272; goto _test_eof; 
	_test_eof273:  sm->cs = 273; goto _test_eof; 
	_test_eof274:  sm->cs = 274; goto _test_eof; 
	_test_eof275:  sm->cs = 275; goto _test_eof; 
	_test_eof276:  sm->cs = 276; goto _test_eof; 
	_test_eof277:  sm->cs = 277; goto _test_eof; 
	_test_eof278:  sm->cs = 278; goto _test_eof; 
	_test_eof279:  sm->cs = 279; goto _test_eof; 
	_test_eof280:  sm->cs = 280; goto _test_eof; 
	_test_eof281:  sm->cs = 281; goto _test_eof; 
	_test_eof282:  sm->cs = 282; goto _test_eof; 
	_test_eof283:  sm->cs = 283; goto _test_eof; 
	_test_eof284:  sm->cs = 284; goto _test_eof; 
	_test_eof285:  sm->cs = 285; goto _test_eof; 
	_test_eof286:  sm->cs = 286; goto _test_eof; 
	_test_eof287:  sm->cs = 287; goto _test_eof; 
	_test_eof288:  sm->cs = 288; goto _test_eof; 
	_test_eof289:  sm->cs = 289; goto _test_eof; 
	_test_eof290:  sm->cs = 290; goto _test_eof; 
	_test_eof291:  sm->cs = 291; goto _test_eof; 
	_test_eof292:  sm->cs = 292; goto _test_eof; 
	_test_eof293:  sm->cs = 293; goto _test_eof; 
	_test_eof294:  sm->cs = 294; goto _test_eof; 
	_test_eof295:  sm->cs = 295; goto _test_eof; 
	_test_eof296:  sm->cs = 296; goto _test_eof; 
	_test_eof297:  sm->cs = 297; goto _test_eof; 
	_test_eof298:  sm->cs = 298; goto _test_eof; 
	_test_eof299:  sm->cs = 299; goto _test_eof; 
	_test_eof300:  sm->cs = 300; goto _test_eof; 
	_test_eof301:  sm->cs = 301; goto _test_eof; 
	_test_eof735:  sm->cs = 735; goto _test_eof; 
	_test_eof736:  sm->cs = 736; goto _test_eof; 
	_test_eof737:  sm->cs = 737; goto _test_eof; 
	_test_eof738:  sm->cs = 738; goto _test_eof; 
	_test_eof302:  sm->cs = 302; goto _test_eof; 
	_test_eof303:  sm->cs = 303; goto _test_eof; 
	_test_eof304:  sm->cs = 304; goto _test_eof; 
	_test_eof305:  sm->cs = 305; goto _test_eof; 
	_test_eof306:  sm->cs = 306; goto _test_eof; 
	_test_eof307:  sm->cs = 307; goto _test_eof; 
	_test_eof739:  sm->cs = 739; goto _test_eof; 
	_test_eof308:  sm->cs = 308; goto _test_eof; 
	_test_eof309:  sm->cs = 309; goto _test_eof; 
	_test_eof310:  sm->cs = 310; goto _test_eof; 
	_test_eof311:  sm->cs = 311; goto _test_eof; 
	_test_eof312:  sm->cs = 312; goto _test_eof; 
	_test_eof313:  sm->cs = 313; goto _test_eof; 
	_test_eof314:  sm->cs = 314; goto _test_eof; 
	_test_eof740:  sm->cs = 740; goto _test_eof; 
	_test_eof315:  sm->cs = 315; goto _test_eof; 
	_test_eof316:  sm->cs = 316; goto _test_eof; 
	_test_eof317:  sm->cs = 317; goto _test_eof; 
	_test_eof318:  sm->cs = 318; goto _test_eof; 
	_test_eof319:  sm->cs = 319; goto _test_eof; 
	_test_eof320:  sm->cs = 320; goto _test_eof; 
	_test_eof321:  sm->cs = 321; goto _test_eof; 
	_test_eof741:  sm->cs = 741; goto _test_eof; 
	_test_eof322:  sm->cs = 322; goto _test_eof; 
	_test_eof323:  sm->cs = 323; goto _test_eof; 
	_test_eof324:  sm->cs = 324; goto _test_eof; 
	_test_eof325:  sm->cs = 325; goto _test_eof; 
	_test_eof326:  sm->cs = 326; goto _test_eof; 
	_test_eof327:  sm->cs = 327; goto _test_eof; 
	_test_eof328:  sm->cs = 328; goto _test_eof; 
	_test_eof329:  sm->cs = 329; goto _test_eof; 
	_test_eof330:  sm->cs = 330; goto _test_eof; 
	_test_eof742:  sm->cs = 742; goto _test_eof; 
	_test_eof743:  sm->cs = 743; goto _test_eof; 
	_test_eof331:  sm->cs = 331; goto _test_eof; 
	_test_eof332:  sm->cs = 332; goto _test_eof; 
	_test_eof333:  sm->cs = 333; goto _test_eof; 
	_test_eof334:  sm->cs = 334; goto _test_eof; 
	_test_eof744:  sm->cs = 744; goto _test_eof; 
	_test_eof335:  sm->cs = 335; goto _test_eof; 
	_test_eof336:  sm->cs = 336; goto _test_eof; 
	_test_eof337:  sm->cs = 337; goto _test_eof; 
	_test_eof338:  sm->cs = 338; goto _test_eof; 
	_test_eof745:  sm->cs = 745; goto _test_eof; 
	_test_eof746:  sm->cs = 746; goto _test_eof; 
	_test_eof339:  sm->cs = 339; goto _test_eof; 
	_test_eof340:  sm->cs = 340; goto _test_eof; 
	_test_eof341:  sm->cs = 341; goto _test_eof; 
	_test_eof342:  sm->cs = 342; goto _test_eof; 
	_test_eof343:  sm->cs = 343; goto _test_eof; 
	_test_eof344:  sm->cs = 344; goto _test_eof; 
	_test_eof345:  sm->cs = 345; goto _test_eof; 
	_test_eof346:  sm->cs = 346; goto _test_eof; 
	_test_eof747:  sm->cs = 747; goto _test_eof; 
	_test_eof347:  sm->cs = 347; goto _test_eof; 
	_test_eof348:  sm->cs = 348; goto _test_eof; 
	_test_eof349:  sm->cs = 349; goto _test_eof; 
	_test_eof350:  sm->cs = 350; goto _test_eof; 
	_test_eof748:  sm->cs = 748; goto _test_eof; 
	_test_eof749:  sm->cs = 749; goto _test_eof; 
	_test_eof351:  sm->cs = 351; goto _test_eof; 
	_test_eof352:  sm->cs = 352; goto _test_eof; 
	_test_eof353:  sm->cs = 353; goto _test_eof; 
	_test_eof354:  sm->cs = 354; goto _test_eof; 
	_test_eof355:  sm->cs = 355; goto _test_eof; 
	_test_eof356:  sm->cs = 356; goto _test_eof; 
	_test_eof357:  sm->cs = 357; goto _test_eof; 
	_test_eof358:  sm->cs = 358; goto _test_eof; 
	_test_eof359:  sm->cs = 359; goto _test_eof; 
	_test_eof360:  sm->cs = 360; goto _test_eof; 
	_test_eof361:  sm->cs = 361; goto _test_eof; 
	_test_eof750:  sm->cs = 750; goto _test_eof; 
	_test_eof362:  sm->cs = 362; goto _test_eof; 
	_test_eof363:  sm->cs = 363; goto _test_eof; 
	_test_eof364:  sm->cs = 364; goto _test_eof; 
	_test_eof365:  sm->cs = 365; goto _test_eof; 
	_test_eof366:  sm->cs = 366; goto _test_eof; 
	_test_eof367:  sm->cs = 367; goto _test_eof; 
	_test_eof751:  sm->cs = 751; goto _test_eof; 
	_test_eof368:  sm->cs = 368; goto _test_eof; 
	_test_eof752:  sm->cs = 752; goto _test_eof; 
	_test_eof753:  sm->cs = 753; goto _test_eof; 
	_test_eof369:  sm->cs = 369; goto _test_eof; 
	_test_eof370:  sm->cs = 370; goto _test_eof; 
	_test_eof371:  sm->cs = 371; goto _test_eof; 
	_test_eof372:  sm->cs = 372; goto _test_eof; 
	_test_eof373:  sm->cs = 373; goto _test_eof; 
	_test_eof374:  sm->cs = 374; goto _test_eof; 
	_test_eof375:  sm->cs = 375; goto _test_eof; 
	_test_eof376:  sm->cs = 376; goto _test_eof; 
	_test_eof377:  sm->cs = 377; goto _test_eof; 
	_test_eof754:  sm->cs = 754; goto _test_eof; 
	_test_eof378:  sm->cs = 378; goto _test_eof; 
	_test_eof379:  sm->cs = 379; goto _test_eof; 
	_test_eof380:  sm->cs = 380; goto _test_eof; 
	_test_eof381:  sm->cs = 381; goto _test_eof; 
	_test_eof382:  sm->cs = 382; goto _test_eof; 
	_test_eof383:  sm->cs = 383; goto _test_eof; 
	_test_eof384:  sm->cs = 384; goto _test_eof; 
	_test_eof385:  sm->cs = 385; goto _test_eof; 
	_test_eof386:  sm->cs = 386; goto _test_eof; 
	_test_eof755:  sm->cs = 755; goto _test_eof; 
	_test_eof387:  sm->cs = 387; goto _test_eof; 
	_test_eof388:  sm->cs = 388; goto _test_eof; 
	_test_eof389:  sm->cs = 389; goto _test_eof; 
	_test_eof390:  sm->cs = 390; goto _test_eof; 
	_test_eof391:  sm->cs = 391; goto _test_eof; 
	_test_eof756:  sm->cs = 756; goto _test_eof; 
	_test_eof392:  sm->cs = 392; goto _test_eof; 
	_test_eof393:  sm->cs = 393; goto _test_eof; 
	_test_eof394:  sm->cs = 394; goto _test_eof; 
	_test_eof395:  sm->cs = 395; goto _test_eof; 
	_test_eof396:  sm->cs = 396; goto _test_eof; 
	_test_eof397:  sm->cs = 397; goto _test_eof; 
	_test_eof757:  sm->cs = 757; goto _test_eof; 
	_test_eof758:  sm->cs = 758; goto _test_eof; 
	_test_eof398:  sm->cs = 398; goto _test_eof; 
	_test_eof399:  sm->cs = 399; goto _test_eof; 
	_test_eof400:  sm->cs = 400; goto _test_eof; 
	_test_eof401:  sm->cs = 401; goto _test_eof; 
	_test_eof402:  sm->cs = 402; goto _test_eof; 
	_test_eof403:  sm->cs = 403; goto _test_eof; 
	_test_eof404:  sm->cs = 404; goto _test_eof; 
	_test_eof405:  sm->cs = 405; goto _test_eof; 
	_test_eof406:  sm->cs = 406; goto _test_eof; 
	_test_eof759:  sm->cs = 759; goto _test_eof; 
	_test_eof760:  sm->cs = 760; goto _test_eof; 
	_test_eof407:  sm->cs = 407; goto _test_eof; 
	_test_eof408:  sm->cs = 408; goto _test_eof; 
	_test_eof409:  sm->cs = 409; goto _test_eof; 
	_test_eof410:  sm->cs = 410; goto _test_eof; 
	_test_eof411:  sm->cs = 411; goto _test_eof; 
	_test_eof412:  sm->cs = 412; goto _test_eof; 
	_test_eof761:  sm->cs = 761; goto _test_eof; 
	_test_eof413:  sm->cs = 413; goto _test_eof; 
	_test_eof762:  sm->cs = 762; goto _test_eof; 
	_test_eof414:  sm->cs = 414; goto _test_eof; 
	_test_eof415:  sm->cs = 415; goto _test_eof; 
	_test_eof416:  sm->cs = 416; goto _test_eof; 
	_test_eof417:  sm->cs = 417; goto _test_eof; 
	_test_eof418:  sm->cs = 418; goto _test_eof; 
	_test_eof419:  sm->cs = 419; goto _test_eof; 
	_test_eof420:  sm->cs = 420; goto _test_eof; 
	_test_eof421:  sm->cs = 421; goto _test_eof; 
	_test_eof422:  sm->cs = 422; goto _test_eof; 
	_test_eof423:  sm->cs = 423; goto _test_eof; 
	_test_eof424:  sm->cs = 424; goto _test_eof; 
	_test_eof425:  sm->cs = 425; goto _test_eof; 
	_test_eof763:  sm->cs = 763; goto _test_eof; 
	_test_eof426:  sm->cs = 426; goto _test_eof; 
	_test_eof427:  sm->cs = 427; goto _test_eof; 
	_test_eof428:  sm->cs = 428; goto _test_eof; 
	_test_eof429:  sm->cs = 429; goto _test_eof; 
	_test_eof430:  sm->cs = 430; goto _test_eof; 
	_test_eof431:  sm->cs = 431; goto _test_eof; 
	_test_eof764:  sm->cs = 764; goto _test_eof; 
	_test_eof765:  sm->cs = 765; goto _test_eof; 
	_test_eof432:  sm->cs = 432; goto _test_eof; 
	_test_eof433:  sm->cs = 433; goto _test_eof; 
	_test_eof434:  sm->cs = 434; goto _test_eof; 
	_test_eof435:  sm->cs = 435; goto _test_eof; 
	_test_eof436:  sm->cs = 436; goto _test_eof; 
	_test_eof437:  sm->cs = 437; goto _test_eof; 
	_test_eof438:  sm->cs = 438; goto _test_eof; 
	_test_eof439:  sm->cs = 439; goto _test_eof; 
	_test_eof440:  sm->cs = 440; goto _test_eof; 
	_test_eof441:  sm->cs = 441; goto _test_eof; 
	_test_eof442:  sm->cs = 442; goto _test_eof; 
	_test_eof766:  sm->cs = 766; goto _test_eof; 
	_test_eof443:  sm->cs = 443; goto _test_eof; 
	_test_eof444:  sm->cs = 444; goto _test_eof; 
	_test_eof445:  sm->cs = 445; goto _test_eof; 
	_test_eof446:  sm->cs = 446; goto _test_eof; 
	_test_eof447:  sm->cs = 447; goto _test_eof; 
	_test_eof448:  sm->cs = 448; goto _test_eof; 
	_test_eof449:  sm->cs = 449; goto _test_eof; 
	_test_eof450:  sm->cs = 450; goto _test_eof; 
	_test_eof767:  sm->cs = 767; goto _test_eof; 
	_test_eof768:  sm->cs = 768; goto _test_eof; 
	_test_eof451:  sm->cs = 451; goto _test_eof; 
	_test_eof452:  sm->cs = 452; goto _test_eof; 
	_test_eof453:  sm->cs = 453; goto _test_eof; 
	_test_eof454:  sm->cs = 454; goto _test_eof; 
	_test_eof455:  sm->cs = 455; goto _test_eof; 
	_test_eof456:  sm->cs = 456; goto _test_eof; 
	_test_eof769:  sm->cs = 769; goto _test_eof; 
	_test_eof457:  sm->cs = 457; goto _test_eof; 
	_test_eof458:  sm->cs = 458; goto _test_eof; 
	_test_eof459:  sm->cs = 459; goto _test_eof; 
	_test_eof460:  sm->cs = 460; goto _test_eof; 
	_test_eof461:  sm->cs = 461; goto _test_eof; 
	_test_eof770:  sm->cs = 770; goto _test_eof; 
	_test_eof771:  sm->cs = 771; goto _test_eof; 
	_test_eof462:  sm->cs = 462; goto _test_eof; 
	_test_eof463:  sm->cs = 463; goto _test_eof; 
	_test_eof464:  sm->cs = 464; goto _test_eof; 
	_test_eof465:  sm->cs = 465; goto _test_eof; 
	_test_eof466:  sm->cs = 466; goto _test_eof; 
	_test_eof467:  sm->cs = 467; goto _test_eof; 
	_test_eof772:  sm->cs = 772; goto _test_eof; 
	_test_eof468:  sm->cs = 468; goto _test_eof; 
	_test_eof469:  sm->cs = 469; goto _test_eof; 
	_test_eof470:  sm->cs = 470; goto _test_eof; 
	_test_eof471:  sm->cs = 471; goto _test_eof; 
	_test_eof472:  sm->cs = 472; goto _test_eof; 
	_test_eof473:  sm->cs = 473; goto _test_eof; 
	_test_eof773:  sm->cs = 773; goto _test_eof; 
	_test_eof474:  sm->cs = 474; goto _test_eof; 
	_test_eof475:  sm->cs = 475; goto _test_eof; 
	_test_eof774:  sm->cs = 774; goto _test_eof; 
	_test_eof476:  sm->cs = 476; goto _test_eof; 
	_test_eof477:  sm->cs = 477; goto _test_eof; 
	_test_eof478:  sm->cs = 478; goto _test_eof; 
	_test_eof479:  sm->cs = 479; goto _test_eof; 
	_test_eof480:  sm->cs = 480; goto _test_eof; 
	_test_eof775:  sm->cs = 775; goto _test_eof; 
	_test_eof481:  sm->cs = 481; goto _test_eof; 
	_test_eof482:  sm->cs = 482; goto _test_eof; 
	_test_eof483:  sm->cs = 483; goto _test_eof; 
	_test_eof484:  sm->cs = 484; goto _test_eof; 
	_test_eof776:  sm->cs = 776; goto _test_eof; 
	_test_eof485:  sm->cs = 485; goto _test_eof; 
	_test_eof486:  sm->cs = 486; goto _test_eof; 
	_test_eof487:  sm->cs = 487; goto _test_eof; 
	_test_eof488:  sm->cs = 488; goto _test_eof; 
	_test_eof489:  sm->cs = 489; goto _test_eof; 
	_test_eof777:  sm->cs = 777; goto _test_eof; 
	_test_eof778:  sm->cs = 778; goto _test_eof; 
	_test_eof490:  sm->cs = 490; goto _test_eof; 
	_test_eof491:  sm->cs = 491; goto _test_eof; 
	_test_eof492:  sm->cs = 492; goto _test_eof; 
	_test_eof493:  sm->cs = 493; goto _test_eof; 
	_test_eof494:  sm->cs = 494; goto _test_eof; 
	_test_eof495:  sm->cs = 495; goto _test_eof; 
	_test_eof496:  sm->cs = 496; goto _test_eof; 
	_test_eof497:  sm->cs = 497; goto _test_eof; 
	_test_eof779:  sm->cs = 779; goto _test_eof; 
	_test_eof498:  sm->cs = 498; goto _test_eof; 
	_test_eof499:  sm->cs = 499; goto _test_eof; 
	_test_eof500:  sm->cs = 500; goto _test_eof; 
	_test_eof501:  sm->cs = 501; goto _test_eof; 
	_test_eof502:  sm->cs = 502; goto _test_eof; 
	_test_eof503:  sm->cs = 503; goto _test_eof; 
	_test_eof780:  sm->cs = 780; goto _test_eof; 
	_test_eof781:  sm->cs = 781; goto _test_eof; 
	_test_eof504:  sm->cs = 504; goto _test_eof; 
	_test_eof505:  sm->cs = 505; goto _test_eof; 
	_test_eof506:  sm->cs = 506; goto _test_eof; 
	_test_eof507:  sm->cs = 507; goto _test_eof; 
	_test_eof508:  sm->cs = 508; goto _test_eof; 
	_test_eof509:  sm->cs = 509; goto _test_eof; 
	_test_eof782:  sm->cs = 782; goto _test_eof; 
	_test_eof510:  sm->cs = 510; goto _test_eof; 
	_test_eof511:  sm->cs = 511; goto _test_eof; 
	_test_eof783:  sm->cs = 783; goto _test_eof; 
	_test_eof512:  sm->cs = 512; goto _test_eof; 
	_test_eof513:  sm->cs = 513; goto _test_eof; 
	_test_eof514:  sm->cs = 514; goto _test_eof; 
	_test_eof515:  sm->cs = 515; goto _test_eof; 
	_test_eof516:  sm->cs = 516; goto _test_eof; 
	_test_eof517:  sm->cs = 517; goto _test_eof; 
	_test_eof518:  sm->cs = 518; goto _test_eof; 
	_test_eof519:  sm->cs = 519; goto _test_eof; 
	_test_eof784:  sm->cs = 784; goto _test_eof; 
	_test_eof785:  sm->cs = 785; goto _test_eof; 
	_test_eof520:  sm->cs = 520; goto _test_eof; 
	_test_eof521:  sm->cs = 521; goto _test_eof; 
	_test_eof522:  sm->cs = 522; goto _test_eof; 
	_test_eof523:  sm->cs = 523; goto _test_eof; 
	_test_eof524:  sm->cs = 524; goto _test_eof; 
	_test_eof786:  sm->cs = 786; goto _test_eof; 
	_test_eof787:  sm->cs = 787; goto _test_eof; 
	_test_eof525:  sm->cs = 525; goto _test_eof; 
	_test_eof526:  sm->cs = 526; goto _test_eof; 
	_test_eof527:  sm->cs = 527; goto _test_eof; 
	_test_eof528:  sm->cs = 528; goto _test_eof; 
	_test_eof529:  sm->cs = 529; goto _test_eof; 
	_test_eof788:  sm->cs = 788; goto _test_eof; 
	_test_eof789:  sm->cs = 789; goto _test_eof; 
	_test_eof530:  sm->cs = 530; goto _test_eof; 
	_test_eof531:  sm->cs = 531; goto _test_eof; 
	_test_eof532:  sm->cs = 532; goto _test_eof; 
	_test_eof533:  sm->cs = 533; goto _test_eof; 
	_test_eof534:  sm->cs = 534; goto _test_eof; 
	_test_eof535:  sm->cs = 535; goto _test_eof; 
	_test_eof536:  sm->cs = 536; goto _test_eof; 
	_test_eof537:  sm->cs = 537; goto _test_eof; 
	_test_eof790:  sm->cs = 790; goto _test_eof; 
	_test_eof791:  sm->cs = 791; goto _test_eof; 
	_test_eof538:  sm->cs = 538; goto _test_eof; 
	_test_eof539:  sm->cs = 539; goto _test_eof; 
	_test_eof540:  sm->cs = 540; goto _test_eof; 
	_test_eof541:  sm->cs = 541; goto _test_eof; 
	_test_eof542:  sm->cs = 542; goto _test_eof; 
	_test_eof543:  sm->cs = 543; goto _test_eof; 
	_test_eof544:  sm->cs = 544; goto _test_eof; 
	_test_eof545:  sm->cs = 545; goto _test_eof; 
	_test_eof546:  sm->cs = 546; goto _test_eof; 
	_test_eof547:  sm->cs = 547; goto _test_eof; 
	_test_eof548:  sm->cs = 548; goto _test_eof; 
	_test_eof549:  sm->cs = 549; goto _test_eof; 
	_test_eof550:  sm->cs = 550; goto _test_eof; 
	_test_eof551:  sm->cs = 551; goto _test_eof; 
	_test_eof552:  sm->cs = 552; goto _test_eof; 
	_test_eof553:  sm->cs = 553; goto _test_eof; 
	_test_eof554:  sm->cs = 554; goto _test_eof; 
	_test_eof555:  sm->cs = 555; goto _test_eof; 
	_test_eof556:  sm->cs = 556; goto _test_eof; 
	_test_eof557:  sm->cs = 557; goto _test_eof; 
	_test_eof558:  sm->cs = 558; goto _test_eof; 
	_test_eof559:  sm->cs = 559; goto _test_eof; 
	_test_eof560:  sm->cs = 560; goto _test_eof; 
	_test_eof561:  sm->cs = 561; goto _test_eof; 
	_test_eof562:  sm->cs = 562; goto _test_eof; 
	_test_eof563:  sm->cs = 563; goto _test_eof; 
	_test_eof564:  sm->cs = 564; goto _test_eof; 
	_test_eof565:  sm->cs = 565; goto _test_eof; 
	_test_eof566:  sm->cs = 566; goto _test_eof; 
	_test_eof567:  sm->cs = 567; goto _test_eof; 
	_test_eof568:  sm->cs = 568; goto _test_eof; 
	_test_eof569:  sm->cs = 569; goto _test_eof; 
	_test_eof570:  sm->cs = 570; goto _test_eof; 
	_test_eof571:  sm->cs = 571; goto _test_eof; 
	_test_eof572:  sm->cs = 572; goto _test_eof; 
	_test_eof573:  sm->cs = 573; goto _test_eof; 
	_test_eof574:  sm->cs = 574; goto _test_eof; 
	_test_eof575:  sm->cs = 575; goto _test_eof; 
	_test_eof576:  sm->cs = 576; goto _test_eof; 
	_test_eof577:  sm->cs = 577; goto _test_eof; 
	_test_eof578:  sm->cs = 578; goto _test_eof; 
	_test_eof579:  sm->cs = 579; goto _test_eof; 
	_test_eof580:  sm->cs = 580; goto _test_eof; 
	_test_eof581:  sm->cs = 581; goto _test_eof; 
	_test_eof582:  sm->cs = 582; goto _test_eof; 
	_test_eof583:  sm->cs = 583; goto _test_eof; 
	_test_eof584:  sm->cs = 584; goto _test_eof; 
	_test_eof585:  sm->cs = 585; goto _test_eof; 
	_test_eof586:  sm->cs = 586; goto _test_eof; 
	_test_eof587:  sm->cs = 587; goto _test_eof; 
	_test_eof588:  sm->cs = 588; goto _test_eof; 
	_test_eof589:  sm->cs = 589; goto _test_eof; 
	_test_eof590:  sm->cs = 590; goto _test_eof; 
	_test_eof591:  sm->cs = 591; goto _test_eof; 
	_test_eof592:  sm->cs = 592; goto _test_eof; 
	_test_eof593:  sm->cs = 593; goto _test_eof; 
	_test_eof594:  sm->cs = 594; goto _test_eof; 
	_test_eof595:  sm->cs = 595; goto _test_eof; 
	_test_eof596:  sm->cs = 596; goto _test_eof; 
	_test_eof597:  sm->cs = 597; goto _test_eof; 
	_test_eof598:  sm->cs = 598; goto _test_eof; 
	_test_eof599:  sm->cs = 599; goto _test_eof; 
	_test_eof600:  sm->cs = 600; goto _test_eof; 
	_test_eof601:  sm->cs = 601; goto _test_eof; 
	_test_eof602:  sm->cs = 602; goto _test_eof; 
	_test_eof603:  sm->cs = 603; goto _test_eof; 
	_test_eof604:  sm->cs = 604; goto _test_eof; 
	_test_eof605:  sm->cs = 605; goto _test_eof; 
	_test_eof606:  sm->cs = 606; goto _test_eof; 
	_test_eof607:  sm->cs = 607; goto _test_eof; 
	_test_eof608:  sm->cs = 608; goto _test_eof; 
	_test_eof609:  sm->cs = 609; goto _test_eof; 
	_test_eof610:  sm->cs = 610; goto _test_eof; 
	_test_eof611:  sm->cs = 611; goto _test_eof; 
	_test_eof792:  sm->cs = 792; goto _test_eof; 
	_test_eof612:  sm->cs = 612; goto _test_eof; 
	_test_eof613:  sm->cs = 613; goto _test_eof; 
	_test_eof614:  sm->cs = 614; goto _test_eof; 
	_test_eof793:  sm->cs = 793; goto _test_eof; 
	_test_eof794:  sm->cs = 794; goto _test_eof; 
	_test_eof615:  sm->cs = 615; goto _test_eof; 
	_test_eof616:  sm->cs = 616; goto _test_eof; 
	_test_eof617:  sm->cs = 617; goto _test_eof; 
	_test_eof618:  sm->cs = 618; goto _test_eof; 
	_test_eof619:  sm->cs = 619; goto _test_eof; 
	_test_eof795:  sm->cs = 795; goto _test_eof; 
	_test_eof620:  sm->cs = 620; goto _test_eof; 
	_test_eof621:  sm->cs = 621; goto _test_eof; 
	_test_eof622:  sm->cs = 622; goto _test_eof; 
	_test_eof623:  sm->cs = 623; goto _test_eof; 
	_test_eof624:  sm->cs = 624; goto _test_eof; 
	_test_eof796:  sm->cs = 796; goto _test_eof; 
	_test_eof797:  sm->cs = 797; goto _test_eof; 
	_test_eof625:  sm->cs = 625; goto _test_eof; 
	_test_eof626:  sm->cs = 626; goto _test_eof; 
	_test_eof627:  sm->cs = 627; goto _test_eof; 
	_test_eof628:  sm->cs = 628; goto _test_eof; 
	_test_eof629:  sm->cs = 629; goto _test_eof; 
	_test_eof630:  sm->cs = 630; goto _test_eof; 
	_test_eof631:  sm->cs = 631; goto _test_eof; 
	_test_eof632:  sm->cs = 632; goto _test_eof; 
	_test_eof798:  sm->cs = 798; goto _test_eof; 
	_test_eof633:  sm->cs = 633; goto _test_eof; 
	_test_eof634:  sm->cs = 634; goto _test_eof; 
	_test_eof635:  sm->cs = 635; goto _test_eof; 
	_test_eof636:  sm->cs = 636; goto _test_eof; 
	_test_eof637:  sm->cs = 637; goto _test_eof; 
	_test_eof638:  sm->cs = 638; goto _test_eof; 
	_test_eof639:  sm->cs = 639; goto _test_eof; 
	_test_eof640:  sm->cs = 640; goto _test_eof; 
	_test_eof799:  sm->cs = 799; goto _test_eof; 
	_test_eof800:  sm->cs = 800; goto _test_eof; 
	_test_eof641:  sm->cs = 641; goto _test_eof; 
	_test_eof642:  sm->cs = 642; goto _test_eof; 
	_test_eof643:  sm->cs = 643; goto _test_eof; 
	_test_eof644:  sm->cs = 644; goto _test_eof; 
	_test_eof645:  sm->cs = 645; goto _test_eof; 
	_test_eof646:  sm->cs = 646; goto _test_eof; 
	_test_eof647:  sm->cs = 647; goto _test_eof; 
	_test_eof648:  sm->cs = 648; goto _test_eof; 
	_test_eof649:  sm->cs = 649; goto _test_eof; 
	_test_eof650:  sm->cs = 650; goto _test_eof; 
	_test_eof651:  sm->cs = 651; goto _test_eof; 
	_test_eof652:  sm->cs = 652; goto _test_eof; 
	_test_eof653:  sm->cs = 653; goto _test_eof; 
	_test_eof654:  sm->cs = 654; goto _test_eof; 
	_test_eof655:  sm->cs = 655; goto _test_eof; 
	_test_eof656:  sm->cs = 656; goto _test_eof; 
	_test_eof657:  sm->cs = 657; goto _test_eof; 
	_test_eof658:  sm->cs = 658; goto _test_eof; 
	_test_eof659:  sm->cs = 659; goto _test_eof; 
	_test_eof660:  sm->cs = 660; goto _test_eof; 
	_test_eof661:  sm->cs = 661; goto _test_eof; 
	_test_eof662:  sm->cs = 662; goto _test_eof; 
	_test_eof663:  sm->cs = 663; goto _test_eof; 
	_test_eof664:  sm->cs = 664; goto _test_eof; 
	_test_eof665:  sm->cs = 665; goto _test_eof; 
	_test_eof666:  sm->cs = 666; goto _test_eof; 
	_test_eof801:  sm->cs = 801; goto _test_eof; 
	_test_eof667:  sm->cs = 667; goto _test_eof; 
	_test_eof668:  sm->cs = 668; goto _test_eof; 
	_test_eof669:  sm->cs = 669; goto _test_eof; 
	_test_eof670:  sm->cs = 670; goto _test_eof; 
	_test_eof671:  sm->cs = 671; goto _test_eof; 
	_test_eof672:  sm->cs = 672; goto _test_eof; 
	_test_eof673:  sm->cs = 673; goto _test_eof; 
	_test_eof674:  sm->cs = 674; goto _test_eof; 
	_test_eof675:  sm->cs = 675; goto _test_eof; 
	_test_eof676:  sm->cs = 676; goto _test_eof; 
	_test_eof677:  sm->cs = 677; goto _test_eof; 
	_test_eof678:  sm->cs = 678; goto _test_eof; 
	_test_eof679:  sm->cs = 679; goto _test_eof; 
	_test_eof680:  sm->cs = 680; goto _test_eof; 
	_test_eof681:  sm->cs = 681; goto _test_eof; 
	_test_eof682:  sm->cs = 682; goto _test_eof; 
	_test_eof683:  sm->cs = 683; goto _test_eof; 
	_test_eof684:  sm->cs = 684; goto _test_eof; 
	_test_eof685:  sm->cs = 685; goto _test_eof; 
	_test_eof686:  sm->cs = 686; goto _test_eof; 
	_test_eof687:  sm->cs = 687; goto _test_eof; 
	_test_eof688:  sm->cs = 688; goto _test_eof; 
	_test_eof689:  sm->cs = 689; goto _test_eof; 
	_test_eof690:  sm->cs = 690; goto _test_eof; 
	_test_eof691:  sm->cs = 691; goto _test_eof; 
	_test_eof692:  sm->cs = 692; goto _test_eof; 
	_test_eof802:  sm->cs = 802; goto _test_eof; 
	_test_eof803:  sm->cs = 803; goto _test_eof; 
	_test_eof693:  sm->cs = 693; goto _test_eof; 
	_test_eof804:  sm->cs = 804; goto _test_eof; 
	_test_eof805:  sm->cs = 805; goto _test_eof; 
	_test_eof694:  sm->cs = 694; goto _test_eof; 
	_test_eof806:  sm->cs = 806; goto _test_eof; 
	_test_eof807:  sm->cs = 807; goto _test_eof; 
	_test_eof695:  sm->cs = 695; goto _test_eof; 

	_test_eof: {}
	if ( ( sm->p) == ( sm->eof) )
	{
	switch (  sm->cs ) {
	case 697: goto tr749;
	case 0: goto tr0;
	case 1: goto tr0;
	case 2: goto tr0;
	case 3: goto tr0;
	case 4: goto tr0;
	case 698: goto tr750;
	case 5: goto tr9;
	case 6: goto tr0;
	case 7: goto tr0;
	case 8: goto tr0;
	case 699: goto tr9;
	case 9: goto tr9;
	case 700: goto tr749;
	case 701: goto tr749;
	case 10: goto tr0;
	case 702: goto tr752;
	case 703: goto tr752;
	case 11: goto tr0;
	case 704: goto tr749;
	case 12: goto tr0;
	case 13: goto tr0;
	case 14: goto tr0;
	case 15: goto tr0;
	case 16: goto tr0;
	case 17: goto tr0;
	case 18: goto tr0;
	case 19: goto tr0;
	case 20: goto tr0;
	case 21: goto tr0;
	case 22: goto tr0;
	case 23: goto tr0;
	case 24: goto tr0;
	case 25: goto tr0;
	case 26: goto tr0;
	case 27: goto tr0;
	case 28: goto tr0;
	case 29: goto tr0;
	case 30: goto tr0;
	case 705: goto tr761;
	case 31: goto tr0;
	case 32: goto tr0;
	case 33: goto tr0;
	case 34: goto tr0;
	case 706: goto tr762;
	case 35: goto tr0;
	case 36: goto tr0;
	case 37: goto tr0;
	case 38: goto tr0;
	case 39: goto tr0;
	case 40: goto tr0;
	case 41: goto tr0;
	case 707: goto tr763;
	case 42: goto tr0;
	case 43: goto tr0;
	case 708: goto tr765;
	case 44: goto tr0;
	case 45: goto tr0;
	case 46: goto tr0;
	case 47: goto tr0;
	case 48: goto tr0;
	case 49: goto tr0;
	case 50: goto tr0;
	case 709: goto tr766;
	case 51: goto tr0;
	case 52: goto tr0;
	case 53: goto tr0;
	case 54: goto tr0;
	case 55: goto tr0;
	case 56: goto tr0;
	case 57: goto tr0;
	case 710: goto tr767;
	case 58: goto tr0;
	case 59: goto tr0;
	case 60: goto tr0;
	case 61: goto tr0;
	case 62: goto tr0;
	case 63: goto tr0;
	case 64: goto tr0;
	case 711: goto tr749;
	case 65: goto tr0;
	case 66: goto tr0;
	case 67: goto tr0;
	case 712: goto tr769;
	case 713: goto tr771;
	case 714: goto tr749;
	case 68: goto tr0;
	case 69: goto tr0;
	case 70: goto tr0;
	case 71: goto tr0;
	case 72: goto tr0;
	case 73: goto tr0;
	case 74: goto tr0;
	case 75: goto tr0;
	case 76: goto tr0;
	case 77: goto tr0;
	case 78: goto tr0;
	case 79: goto tr0;
	case 80: goto tr0;
	case 81: goto tr0;
	case 82: goto tr0;
	case 83: goto tr0;
	case 84: goto tr0;
	case 85: goto tr0;
	case 86: goto tr0;
	case 87: goto tr0;
	case 88: goto tr0;
	case 89: goto tr0;
	case 90: goto tr0;
	case 91: goto tr0;
	case 92: goto tr0;
	case 93: goto tr0;
	case 94: goto tr0;
	case 95: goto tr0;
	case 96: goto tr0;
	case 97: goto tr0;
	case 98: goto tr0;
	case 99: goto tr0;
	case 100: goto tr0;
	case 101: goto tr0;
	case 102: goto tr0;
	case 103: goto tr0;
	case 104: goto tr0;
	case 105: goto tr0;
	case 106: goto tr0;
	case 107: goto tr0;
	case 108: goto tr0;
	case 109: goto tr0;
	case 110: goto tr0;
	case 111: goto tr0;
	case 112: goto tr0;
	case 113: goto tr0;
	case 114: goto tr0;
	case 115: goto tr0;
	case 716: goto tr784;
	case 116: goto tr120;
	case 117: goto tr120;
	case 118: goto tr120;
	case 119: goto tr120;
	case 120: goto tr120;
	case 121: goto tr120;
	case 122: goto tr120;
	case 123: goto tr120;
	case 124: goto tr120;
	case 125: goto tr120;
	case 126: goto tr120;
	case 127: goto tr120;
	case 128: goto tr120;
	case 129: goto tr120;
	case 130: goto tr120;
	case 131: goto tr120;
	case 132: goto tr120;
	case 133: goto tr120;
	case 134: goto tr120;
	case 717: goto tr784;
	case 135: goto tr120;
	case 136: goto tr120;
	case 137: goto tr120;
	case 138: goto tr120;
	case 139: goto tr120;
	case 140: goto tr120;
	case 141: goto tr120;
	case 142: goto tr120;
	case 143: goto tr120;
	case 719: goto tr820;
	case 144: goto tr148;
	case 145: goto tr148;
	case 146: goto tr148;
	case 147: goto tr148;
	case 148: goto tr148;
	case 149: goto tr148;
	case 720: goto tr821;
	case 150: goto tr148;
	case 151: goto tr148;
	case 152: goto tr148;
	case 153: goto tr148;
	case 154: goto tr148;
	case 721: goto tr822;
	case 722: goto tr825;
	case 155: goto tr148;
	case 156: goto tr162;
	case 157: goto tr162;
	case 723: goto tr826;
	case 724: goto tr826;
	case 725: goto tr828;
	case 726: goto tr829;
	case 158: goto tr167;
	case 159: goto tr167;
	case 160: goto tr167;
	case 727: goto tr831;
	case 161: goto tr167;
	case 162: goto tr167;
	case 163: goto tr167;
	case 164: goto tr167;
	case 165: goto tr167;
	case 166: goto tr167;
	case 167: goto tr167;
	case 168: goto tr167;
	case 169: goto tr167;
	case 170: goto tr167;
	case 171: goto tr167;
	case 172: goto tr167;
	case 173: goto tr167;
	case 174: goto tr167;
	case 175: goto tr167;
	case 176: goto tr167;
	case 177: goto tr167;
	case 178: goto tr167;
	case 728: goto tr829;
	case 179: goto tr167;
	case 180: goto tr167;
	case 181: goto tr167;
	case 182: goto tr167;
	case 183: goto tr167;
	case 729: goto tr832;
	case 730: goto tr834;
	case 184: goto tr167;
	case 185: goto tr167;
	case 186: goto tr167;
	case 731: goto tr836;
	case 732: goto tr838;
	case 187: goto tr167;
	case 733: goto tr829;
	case 188: goto tr167;
	case 189: goto tr167;
	case 190: goto tr167;
	case 191: goto tr167;
	case 192: goto tr167;
	case 193: goto tr167;
	case 194: goto tr167;
	case 195: goto tr167;
	case 196: goto tr167;
	case 197: goto tr167;
	case 198: goto tr167;
	case 734: goto tr851;
	case 199: goto tr167;
	case 200: goto tr167;
	case 201: goto tr167;
	case 202: goto tr167;
	case 203: goto tr167;
	case 204: goto tr167;
	case 205: goto tr167;
	case 206: goto tr167;
	case 207: goto tr167;
	case 208: goto tr167;
	case 209: goto tr167;
	case 210: goto tr167;
	case 211: goto tr167;
	case 212: goto tr167;
	case 213: goto tr167;
	case 214: goto tr167;
	case 215: goto tr167;
	case 216: goto tr167;
	case 217: goto tr167;
	case 218: goto tr167;
	case 219: goto tr167;
	case 220: goto tr167;
	case 221: goto tr167;
	case 222: goto tr167;
	case 223: goto tr167;
	case 224: goto tr167;
	case 225: goto tr167;
	case 226: goto tr167;
	case 227: goto tr167;
	case 228: goto tr167;
	case 229: goto tr167;
	case 230: goto tr167;
	case 231: goto tr167;
	case 232: goto tr167;
	case 233: goto tr167;
	case 234: goto tr167;
	case 235: goto tr167;
	case 236: goto tr167;
	case 237: goto tr167;
	case 238: goto tr167;
	case 239: goto tr167;
	case 240: goto tr167;
	case 241: goto tr167;
	case 242: goto tr167;
	case 243: goto tr167;
	case 244: goto tr167;
	case 245: goto tr167;
	case 246: goto tr167;
	case 247: goto tr167;
	case 248: goto tr167;
	case 249: goto tr167;
	case 250: goto tr167;
	case 251: goto tr167;
	case 252: goto tr167;
	case 253: goto tr167;
	case 254: goto tr167;
	case 255: goto tr167;
	case 256: goto tr167;
	case 257: goto tr167;
	case 258: goto tr167;
	case 259: goto tr167;
	case 260: goto tr167;
	case 261: goto tr167;
	case 262: goto tr167;
	case 263: goto tr167;
	case 264: goto tr167;
	case 265: goto tr167;
	case 266: goto tr167;
	case 267: goto tr167;
	case 268: goto tr167;
	case 269: goto tr167;
	case 270: goto tr167;
	case 271: goto tr167;
	case 272: goto tr167;
	case 273: goto tr167;
	case 274: goto tr167;
	case 275: goto tr167;
	case 276: goto tr167;
	case 277: goto tr167;
	case 278: goto tr167;
	case 279: goto tr167;
	case 280: goto tr167;
	case 281: goto tr167;
	case 282: goto tr167;
	case 283: goto tr167;
	case 284: goto tr167;
	case 285: goto tr167;
	case 286: goto tr167;
	case 287: goto tr167;
	case 288: goto tr167;
	case 289: goto tr167;
	case 290: goto tr167;
	case 291: goto tr167;
	case 292: goto tr167;
	case 293: goto tr167;
	case 294: goto tr167;
	case 295: goto tr167;
	case 296: goto tr167;
	case 297: goto tr167;
	case 298: goto tr167;
	case 299: goto tr167;
	case 300: goto tr167;
	case 301: goto tr167;
	case 735: goto tr829;
	case 736: goto tr854;
	case 737: goto tr856;
	case 738: goto tr829;
	case 302: goto tr167;
	case 303: goto tr167;
	case 304: goto tr167;
	case 305: goto tr167;
	case 306: goto tr167;
	case 307: goto tr167;
	case 739: goto tr861;
	case 308: goto tr167;
	case 309: goto tr167;
	case 310: goto tr167;
	case 311: goto tr167;
	case 312: goto tr167;
	case 313: goto tr167;
	case 314: goto tr167;
	case 740: goto tr863;
	case 315: goto tr167;
	case 316: goto tr167;
	case 317: goto tr167;
	case 318: goto tr167;
	case 319: goto tr167;
	case 320: goto tr167;
	case 321: goto tr167;
	case 741: goto tr865;
	case 322: goto tr167;
	case 323: goto tr167;
	case 324: goto tr167;
	case 325: goto tr167;
	case 326: goto tr167;
	case 327: goto tr167;
	case 328: goto tr167;
	case 329: goto tr167;
	case 330: goto tr167;
	case 742: goto tr867;
	case 743: goto tr829;
	case 331: goto tr167;
	case 332: goto tr167;
	case 333: goto tr167;
	case 334: goto tr167;
	case 744: goto tr871;
	case 335: goto tr167;
	case 336: goto tr167;
	case 337: goto tr167;
	case 338: goto tr167;
	case 745: goto tr873;
	case 746: goto tr829;
	case 339: goto tr167;
	case 340: goto tr167;
	case 341: goto tr167;
	case 342: goto tr167;
	case 343: goto tr167;
	case 344: goto tr167;
	case 345: goto tr167;
	case 346: goto tr167;
	case 747: goto tr876;
	case 347: goto tr167;
	case 348: goto tr167;
	case 349: goto tr167;
	case 350: goto tr167;
	case 748: goto tr878;
	case 749: goto tr829;
	case 351: goto tr167;
	case 352: goto tr167;
	case 353: goto tr167;
	case 354: goto tr167;
	case 355: goto tr167;
	case 356: goto tr167;
	case 357: goto tr167;
	case 358: goto tr167;
	case 359: goto tr167;
	case 360: goto tr167;
	case 361: goto tr167;
	case 750: goto tr882;
	case 362: goto tr167;
	case 363: goto tr167;
	case 364: goto tr167;
	case 365: goto tr167;
	case 366: goto tr167;
	case 367: goto tr167;
	case 751: goto tr884;
	case 368: goto tr405;
	case 752: goto tr887;
	case 753: goto tr829;
	case 369: goto tr167;
	case 370: goto tr167;
	case 371: goto tr167;
	case 372: goto tr167;
	case 373: goto tr167;
	case 374: goto tr167;
	case 375: goto tr167;
	case 376: goto tr167;
	case 377: goto tr167;
	case 754: goto tr893;
	case 378: goto tr167;
	case 379: goto tr167;
	case 380: goto tr167;
	case 381: goto tr167;
	case 382: goto tr167;
	case 383: goto tr167;
	case 384: goto tr167;
	case 385: goto tr167;
	case 386: goto tr167;
	case 755: goto tr895;
	case 387: goto tr167;
	case 388: goto tr167;
	case 389: goto tr167;
	case 390: goto tr167;
	case 391: goto tr167;
	case 756: goto tr897;
	case 392: goto tr167;
	case 393: goto tr167;
	case 394: goto tr167;
	case 395: goto tr167;
	case 396: goto tr167;
	case 397: goto tr167;
	case 757: goto tr899;
	case 758: goto tr829;
	case 398: goto tr167;
	case 399: goto tr167;
	case 400: goto tr167;
	case 401: goto tr167;
	case 402: goto tr167;
	case 403: goto tr167;
	case 404: goto tr167;
	case 405: goto tr167;
	case 406: goto tr167;
	case 759: goto tr902;
	case 760: goto tr829;
	case 407: goto tr167;
	case 408: goto tr167;
	case 409: goto tr167;
	case 410: goto tr167;
	case 411: goto tr167;
	case 412: goto tr167;
	case 761: goto tr905;
	case 413: goto tr167;
	case 762: goto tr829;
	case 414: goto tr167;
	case 415: goto tr167;
	case 416: goto tr167;
	case 417: goto tr167;
	case 418: goto tr167;
	case 419: goto tr167;
	case 420: goto tr167;
	case 421: goto tr167;
	case 422: goto tr167;
	case 423: goto tr167;
	case 424: goto tr167;
	case 425: goto tr167;
	case 763: goto tr908;
	case 426: goto tr167;
	case 427: goto tr167;
	case 428: goto tr167;
	case 429: goto tr167;
	case 430: goto tr167;
	case 431: goto tr167;
	case 764: goto tr910;
	case 765: goto tr829;
	case 432: goto tr167;
	case 433: goto tr167;
	case 434: goto tr167;
	case 435: goto tr167;
	case 436: goto tr167;
	case 437: goto tr167;
	case 438: goto tr167;
	case 439: goto tr167;
	case 440: goto tr167;
	case 441: goto tr167;
	case 442: goto tr167;
	case 766: goto tr913;
	case 443: goto tr167;
	case 444: goto tr167;
	case 445: goto tr167;
	case 446: goto tr167;
	case 447: goto tr167;
	case 448: goto tr167;
	case 449: goto tr167;
	case 450: goto tr167;
	case 767: goto tr915;
	case 768: goto tr829;
	case 451: goto tr167;
	case 452: goto tr167;
	case 453: goto tr167;
	case 454: goto tr167;
	case 455: goto tr167;
	case 456: goto tr167;
	case 769: goto tr919;
	case 457: goto tr167;
	case 458: goto tr167;
	case 459: goto tr167;
	case 460: goto tr167;
	case 461: goto tr167;
	case 770: goto tr921;
	case 771: goto tr829;
	case 462: goto tr167;
	case 463: goto tr167;
	case 464: goto tr167;
	case 465: goto tr167;
	case 466: goto tr167;
	case 467: goto tr167;
	case 772: goto tr927;
	case 468: goto tr167;
	case 469: goto tr167;
	case 470: goto tr167;
	case 471: goto tr167;
	case 472: goto tr167;
	case 473: goto tr167;
	case 773: goto tr929;
	case 474: goto tr513;
	case 475: goto tr513;
	case 774: goto tr932;
	case 476: goto tr167;
	case 477: goto tr167;
	case 478: goto tr167;
	case 479: goto tr167;
	case 480: goto tr167;
	case 775: goto tr934;
	case 481: goto tr167;
	case 482: goto tr167;
	case 483: goto tr167;
	case 484: goto tr167;
	case 776: goto tr936;
	case 485: goto tr167;
	case 486: goto tr167;
	case 487: goto tr167;
	case 488: goto tr167;
	case 489: goto tr167;
	case 777: goto tr938;
	case 778: goto tr829;
	case 490: goto tr167;
	case 491: goto tr167;
	case 492: goto tr167;
	case 493: goto tr167;
	case 494: goto tr167;
	case 495: goto tr167;
	case 496: goto tr167;
	case 497: goto tr167;
	case 779: goto tr942;
	case 498: goto tr167;
	case 499: goto tr167;
	case 500: goto tr167;
	case 501: goto tr167;
	case 502: goto tr167;
	case 503: goto tr167;
	case 780: goto tr944;
	case 781: goto tr829;
	case 504: goto tr167;
	case 505: goto tr167;
	case 506: goto tr167;
	case 507: goto tr167;
	case 508: goto tr167;
	case 509: goto tr167;
	case 782: goto tr948;
	case 510: goto tr551;
	case 511: goto tr551;
	case 783: goto tr951;
	case 512: goto tr167;
	case 513: goto tr167;
	case 514: goto tr167;
	case 515: goto tr167;
	case 516: goto tr167;
	case 517: goto tr167;
	case 518: goto tr167;
	case 519: goto tr167;
	case 784: goto tr953;
	case 785: goto tr829;
	case 520: goto tr167;
	case 521: goto tr167;
	case 522: goto tr167;
	case 523: goto tr167;
	case 524: goto tr167;
	case 786: goto tr956;
	case 787: goto tr829;
	case 525: goto tr167;
	case 526: goto tr167;
	case 527: goto tr167;
	case 528: goto tr167;
	case 529: goto tr167;
	case 788: goto tr959;
	case 789: goto tr829;
	case 530: goto tr167;
	case 531: goto tr167;
	case 532: goto tr167;
	case 533: goto tr167;
	case 534: goto tr167;
	case 535: goto tr167;
	case 536: goto tr167;
	case 537: goto tr167;
	case 790: goto tr962;
	case 791: goto tr829;
	case 538: goto tr167;
	case 539: goto tr167;
	case 540: goto tr167;
	case 541: goto tr167;
	case 542: goto tr167;
	case 543: goto tr167;
	case 544: goto tr167;
	case 545: goto tr167;
	case 546: goto tr167;
	case 547: goto tr167;
	case 548: goto tr167;
	case 549: goto tr167;
	case 550: goto tr167;
	case 551: goto tr167;
	case 552: goto tr167;
	case 553: goto tr167;
	case 554: goto tr167;
	case 555: goto tr167;
	case 556: goto tr167;
	case 557: goto tr167;
	case 558: goto tr167;
	case 559: goto tr167;
	case 560: goto tr167;
	case 561: goto tr167;
	case 562: goto tr167;
	case 563: goto tr167;
	case 564: goto tr167;
	case 565: goto tr167;
	case 566: goto tr167;
	case 567: goto tr167;
	case 568: goto tr167;
	case 569: goto tr167;
	case 570: goto tr167;
	case 571: goto tr167;
	case 572: goto tr167;
	case 573: goto tr167;
	case 574: goto tr167;
	case 575: goto tr167;
	case 576: goto tr167;
	case 577: goto tr167;
	case 578: goto tr167;
	case 579: goto tr167;
	case 580: goto tr167;
	case 581: goto tr167;
	case 582: goto tr167;
	case 583: goto tr167;
	case 584: goto tr167;
	case 585: goto tr167;
	case 586: goto tr167;
	case 587: goto tr167;
	case 588: goto tr167;
	case 589: goto tr167;
	case 590: goto tr167;
	case 591: goto tr167;
	case 592: goto tr167;
	case 593: goto tr167;
	case 594: goto tr167;
	case 595: goto tr167;
	case 596: goto tr167;
	case 597: goto tr167;
	case 598: goto tr167;
	case 599: goto tr167;
	case 600: goto tr167;
	case 601: goto tr167;
	case 602: goto tr167;
	case 603: goto tr167;
	case 604: goto tr167;
	case 605: goto tr167;
	case 606: goto tr167;
	case 607: goto tr167;
	case 608: goto tr167;
	case 609: goto tr167;
	case 610: goto tr167;
	case 611: goto tr167;
	case 792: goto tr829;
	case 612: goto tr167;
	case 613: goto tr167;
	case 614: goto tr167;
	case 794: goto tr980;
	case 615: goto tr649;
	case 616: goto tr649;
	case 617: goto tr649;
	case 618: goto tr649;
	case 619: goto tr649;
	case 795: goto tr980;
	case 620: goto tr649;
	case 621: goto tr649;
	case 622: goto tr649;
	case 623: goto tr649;
	case 624: goto tr649;
	case 797: goto tr987;
	case 625: goto tr659;
	case 626: goto tr659;
	case 627: goto tr659;
	case 628: goto tr659;
	case 629: goto tr659;
	case 630: goto tr659;
	case 631: goto tr659;
	case 632: goto tr659;
	case 798: goto tr987;
	case 633: goto tr659;
	case 634: goto tr659;
	case 635: goto tr659;
	case 636: goto tr659;
	case 637: goto tr659;
	case 638: goto tr659;
	case 639: goto tr659;
	case 640: goto tr659;
	case 800: goto tr993;
	case 641: goto tr675;
	case 642: goto tr675;
	case 643: goto tr675;
	case 644: goto tr675;
	case 645: goto tr675;
	case 646: goto tr675;
	case 647: goto tr675;
	case 648: goto tr675;
	case 649: goto tr675;
	case 650: goto tr675;
	case 651: goto tr675;
	case 652: goto tr675;
	case 653: goto tr675;
	case 654: goto tr675;
	case 655: goto tr675;
	case 656: goto tr675;
	case 657: goto tr675;
	case 658: goto tr675;
	case 659: goto tr675;
	case 660: goto tr675;
	case 661: goto tr675;
	case 662: goto tr675;
	case 663: goto tr675;
	case 664: goto tr675;
	case 665: goto tr675;
	case 666: goto tr675;
	case 801: goto tr993;
	case 667: goto tr675;
	case 668: goto tr675;
	case 669: goto tr675;
	case 670: goto tr675;
	case 671: goto tr675;
	case 672: goto tr675;
	case 673: goto tr675;
	case 674: goto tr675;
	case 675: goto tr675;
	case 676: goto tr675;
	case 677: goto tr675;
	case 678: goto tr675;
	case 679: goto tr675;
	case 680: goto tr675;
	case 681: goto tr675;
	case 682: goto tr675;
	case 683: goto tr675;
	case 684: goto tr675;
	case 685: goto tr675;
	case 686: goto tr675;
	case 687: goto tr675;
	case 688: goto tr675;
	case 689: goto tr675;
	case 690: goto tr675;
	case 691: goto tr675;
	case 692: goto tr675;
	case 803: goto tr733;
	case 693: goto tr733;
	case 804: goto tr1003;
	case 805: goto tr1003;
	case 694: goto tr735;
	case 806: goto tr1004;
	case 807: goto tr1004;
	case 695: goto tr735;
	}
	}

	_out: {}
	}

#line 1297 "ext/dtext/dtext.cpp.rl"

  g_debug("EOF; closing stray blocks");
  dstack_close_all(sm);
  g_debug("done");

  return sm->error.empty();
}

/* Everything below is optional, it's only needed to build bin/cdtext.exe. */
#ifdef CDTEXT

static void parse_file(FILE* input, FILE* output, bool opt_inline, bool opt_mentions) {
  g_autofree char* dtext = NULL;
  size_t n = 0;

  ssize_t length = getdelim(&dtext, &n, '\0', input);
  if (length == -1) {
    if (ferror(input)) {
      perror("getdelim failed");
      exit(1);
    } else /* EOF (file was empty, continue with the empty string) */ {
      dtext = NULL;
      length = 0;
    }
  }

  StateMachine sm = init_machine(dtext, length);
  sm.f_inline = opt_inline;
  sm.f_mentions = opt_mentions;

  if (!parse_helper(&sm)) {
    fprintf(stderr, "dtext parse error: %s\n", sm.error.c_str());
    exit(1);
  }

  if (fwrite(sm.output.c_str(), 1, sm.output.size(), output) != sm.output.size()) {
    perror("fwrite failed");
    exit(1);
  }
}

int main(int argc, char* argv[]) {
  GError* error = NULL;
  bool opt_verbose = FALSE;
  bool opt_inline = FALSE;
  bool opt_no_mentions = FALSE;

  GOptionEntry options[] = {
    { "no-mentions", 'm', 0, G_OPTION_ARG_NONE, &opt_no_mentions, "Don't parse @mentions", NULL },
    { "inline",      'i', 0, G_OPTION_ARG_NONE, &opt_inline,      "Parse in inline mode", NULL },
    { "verbose",     'v', 0, G_OPTION_ARG_NONE, &opt_verbose,     "Print debug output", NULL },
    { NULL }
  };

  g_autoptr(GOptionContext) context = g_option_context_new("[FILE...]");
  g_option_context_add_main_entries(context, options, NULL);

  if (!g_option_context_parse(context, &argc, &argv, &error)) {
    fprintf(stderr, "option parsing failed: %s\n", error->message);
    g_clear_error(&error);
    return 1;
  }

  if (opt_verbose) {
    g_setenv("G_MESSAGES_DEBUG", "all", TRUE);
  }

  /* skip first argument (progname) */
  argc--, argv++;

  if (argc == 0) {
    parse_file(stdin, stdout, opt_inline, !opt_no_mentions);
    return 0;
  }

  for (const char* filename = *argv; argc > 0; argc--, argv++) {
    FILE* input = fopen(filename, "r");
    if (!input) {
      perror("fopen failed");
      return 1;
    }

    parse_file(input, stdout, opt_inline, !opt_no_mentions);
    fclose(input);
  }

  return 0;
}

#endif
