
#line 1 "ext/dtext/dtext.rl"
#include "dtext.h"

#include <stdio.h>
#include <stdint.h>
#include <stdbool.h>
#include <stdlib.h>
#include <string.h>
#include <glib.h>

static const size_t MAX_STACK_DEPTH = 512;

typedef enum element_t {
  QUEUE_EMPTY = 0,
  BLOCK_P = 1,
  INLINE_SPOILER = 2,
  BLOCK_SPOILER = 3,
  BLOCK_QUOTE = 4,
  BLOCK_EXPAND = 5,
  BLOCK_NODTEXT = 6,
  BLOCK_CODE = 7,
  BLOCK_TD = 8,
  INLINE_NODTEXT = 9,
  INLINE_B = 10,
  INLINE_I = 11,
  INLINE_U = 12,
  INLINE_S = 13,
  INLINE_TN = 14,
  BLOCK_TN = 15,
  BLOCK_TABLE = 16,
  BLOCK_THEAD = 17,
  BLOCK_TBODY = 18,
  BLOCK_TR = 19,
  BLOCK_UL = 20,
  BLOCK_LI = 21,
  BLOCK_TH = 22,
  BLOCK_H1 = 23,
  BLOCK_H2 = 24,
  BLOCK_H3 = 25,
  BLOCK_H4 = 26,
  BLOCK_H5 = 27,
  BLOCK_H6 = 28,
  INLINE_CODE = 29,
} element_t;


#line 822 "ext/dtext/dtext.rl"



#line 53 "ext/dtext/dtext.c"
static const short _dtext_to_state_actions[] = {
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	76, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 76, 0, 0, 76, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 76, 0, 0, 
	76, 0, 0, 76, 0, 0, 76, 0, 
	0, 0, 0, 0
};

static const short _dtext_from_state_actions[] = {
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	77, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 77, 0, 0, 77, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 77, 0, 0, 
	77, 0, 0, 77, 0, 0, 77, 0, 
	0, 0, 0, 0
};

static const int dtext_start = 696;
static const int dtext_first_final = 696;
static const int dtext_error = -1;

static const int dtext_en_basic_inline = 713;
static const int dtext_en_inline = 716;
static const int dtext_en_code = 789;
static const int dtext_en_nodtext = 792;
static const int dtext_en_table = 795;
static const int dtext_en_list = 798;
static const int dtext_en_main = 696;


#line 825 "ext/dtext/dtext.rl"

static inline void dstack_push(StateMachine * sm, element_t element) {
  g_queue_push_tail(sm->dstack, GINT_TO_POINTER(element));
}

static inline element_t dstack_pop(StateMachine * sm) {
  return GPOINTER_TO_INT(g_queue_pop_tail(sm->dstack));
}

static inline element_t dstack_peek(const StateMachine * sm) {
  return GPOINTER_TO_INT(g_queue_peek_tail(sm->dstack));
}

static inline bool dstack_check(const StateMachine * sm, element_t expected_element) {
  return dstack_peek(sm) == expected_element;
}

static inline bool dstack_check2(const StateMachine * sm, element_t expected_element) {
  if (sm->dstack->length < 2) {
    return false;
  }

  element_t top2 = GPOINTER_TO_INT(g_queue_peek_nth(sm->dstack, sm->dstack->length - 2));
  return top2 == expected_element;
}

static inline bool is_internal_url(StateMachine * sm, GUri* url) {
  if (sm->domain == NULL || url == NULL) {
    return false;
  }

  const char* host = g_uri_get_host(url);
  if (host == NULL) {
    return false;
  }

  return strcmp(sm->domain, host) == 0;
}

static inline void append(StateMachine * sm, const char * s) {
  sm->output = g_string_append(sm->output, s);
}

static inline void append_c(StateMachine * sm, char s) {
  sm->output = g_string_append_c(sm->output, s);
}

static inline void append_c_html_escaped(StateMachine * sm, char s) {
  switch (s) {
    case '<':
      sm->output = g_string_append(sm->output, "&lt;");
      break;

    case '>':
      sm->output = g_string_append(sm->output, "&gt;");
      break;

    case '&':
      sm->output = g_string_append(sm->output, "&amp;");
      break;

    case '"':
      sm->output = g_string_append(sm->output, "&quot;");
      break;

    default:
      sm->output = g_string_append_c(sm->output, s);
      break;
  }
}

static inline void append_segment(StateMachine * sm, const char * a, const char * b) {
  sm->output = g_string_append_len(sm->output, a, b - a + 1);
}

static inline void append_segment_uri_escaped(StateMachine * sm, const char * a, const char * b) {
  g_autofree char * segment1 = NULL;
  g_autofree char * segment2 = NULL;
  g_autoptr(GString) segment_string = g_string_new_len(a, b - a + 1);

  segment1 = g_uri_escape_string(segment_string->str, NULL, TRUE);
  segment2 = g_markup_escape_text(segment1, -1);
  sm->output = g_string_append(sm->output, segment2);
}

static inline void append_segment_html_escaped(StateMachine * sm, const char * a, const char * b) {
  g_autofree gchar * segment = g_markup_escape_text(a, b - a + 1);
  sm->output = g_string_append(sm->output, segment);
}

static inline void append_url(StateMachine * sm, const char* url) {
  if ((url[0] == '/' || url[0] == '#') && sm->base_url) {
    append(sm, sm->base_url);
  }

  append(sm, url);
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
  g_autoptr(GString) url = g_string_new_len(url_start, url_end - url_start + 1);
  g_autoptr(GUri) parsed_url = g_uri_parse(url->str, G_URI_FLAGS_NONE, NULL);

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
  g_autoptr(GString) parsed_title = parse_basic_inline(title_start, title_end - title_start);

  if (!parsed_title) {
    return false;
  }

  if (url_start[0] == '/' || url_start[0] == '#') {
    append(sm, "<a class=\"dtext-link\" href=\"");

    if (sm->base_url) {
      append(sm, sm->base_url);
    }
  } else {
    g_autoptr(GString) url = g_string_new_len(url_start, url_end - url_start + 1);
    g_autoptr(GUri) parsed_url = g_uri_parse(url->str, G_URI_FLAGS_NONE, NULL);

    if (is_internal_url(sm, parsed_url)) {
      append(sm, "<a class=\"dtext-link\" href=\"");
    } else {
      append(sm, "<a rel=\"external nofollow noreferrer\" class=\"dtext-link dtext-external-link dtext-named-external-link\" href=\"");
    }
  }

  append_segment_html_escaped(sm, url_start, url_end);
  append(sm, "\">");
  append_segment(sm, parsed_title->str, parsed_title->str + parsed_title->len - 1);
  append(sm, "</a>");

  return true;
}

static inline void append_wiki_link(StateMachine * sm, const char * tag_segment, const size_t tag_len, const char * title_segment, const size_t title_len, const char * prefix_segment, const size_t prefix_len, const char * suffix_segment, const size_t suffix_len) {
  g_autofree gchar* lowercased_tag = g_utf8_strdown(tag_segment, tag_len);
  g_autoptr(GString) normalized_tag = g_string_new(g_strdelimit(lowercased_tag, " ", '_'));
  g_autoptr(GString) title_string = g_string_new_len(title_segment, title_len);

  if (g_regex_match_simple("^[0-9]+$", normalized_tag->str, 0, 0)) {
    g_string_prepend(normalized_tag, "~");
  }
  
  /* handle pipe trick: [[Kaga (Kantai Collection)|]] -> [[kaga_(kantai_collection)|Kaga]] */
  if (title_string->len == 0) {
    g_string_append_len(title_string, tag_segment, tag_len);

    /* strip qualifier from tag: "kaga (kantai collection)" -> "kaga" */
    g_autoptr(GRegex) qualifier_regex = g_regex_new("[ _]\\([^)]+?\\)$", 0, 0, NULL);
    g_autofree gchar* stripped_string = g_regex_replace_literal(qualifier_regex, title_string->str, title_string->len, 0, "", 0, NULL);

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
    sm->output = g_string_append_len(sm->output, a, b - a + 1);
  }
}

static inline void append_block(StateMachine * sm, const char * s) {
  append_block_segment(sm, s, s + strlen(s) - 1);
}

static void append_closing_p(StateMachine * sm) {
  size_t i = sm->output->len;

  if (i > 4 && !strncmp(sm->output->str + i - 4, "<br>", 4)) {
    sm->output = g_string_truncate(sm->output, sm->output->len - 4);
  }

  if (i > 3 && !strncmp(sm->output->str + i - 3, "<p>", 3)) {
    sm->output = g_string_truncate(sm->output, sm->output->len - 3);
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
  g_debug("push inline element [%d]: %s", type, html);

  dstack_push(sm, type);
  append(sm, html);
}

static void dstack_open_block(StateMachine * sm, element_t type, const char * html) {
  g_debug("push block element [%d]: %s", type, html);

  dstack_push(sm, type);
  append_block(sm, html);
}

static void dstack_close_inline(StateMachine * sm, element_t type, const char * close_html) {
  if (dstack_check(sm, type)) {
    g_debug("pop inline element [%d]: %s", type, close_html);

    dstack_pop(sm);
    append(sm, close_html);
  } else {
    g_debug("ignored out-of-order closing inline tag [%d]", type);

    append_segment(sm, sm->ts, sm->te - 1);
  }
}

static bool dstack_close_block(StateMachine * sm, element_t type, const char * close_html) {
  if (dstack_check(sm, type)) {
    g_debug("pop block element [%d]: %s", type, close_html);

    dstack_pop(sm);
    append_block(sm, close_html);
    return true;
  } else {
    g_debug("ignored out-of-order closing block tag [%d]", type);

    append_block_segment(sm, sm->ts, sm->te - 1);
    return false;
  }
}

static void dstack_rewind(StateMachine * sm) {
  element_t element = dstack_pop(sm);

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

    case QUEUE_EMPTY: break;
  } 
}

static void dstack_close_before_block(StateMachine * sm) {
  while (1) {
    if (dstack_check(sm, BLOCK_P)) {
      dstack_pop(sm);
      append_closing_p(sm);
    } else if (dstack_check(sm, BLOCK_LI) || dstack_check(sm, BLOCK_UL)) {
      dstack_rewind(sm);
    } else {
      return;
    }
  }
}

static void dstack_close(StateMachine * sm) {
  while (!g_queue_is_empty(sm->dstack)) {
    dstack_rewind(sm);
  }
}

static void dstack_close_list(StateMachine * sm) {
  while (dstack_check(sm, BLOCK_LI) || dstack_check(sm, BLOCK_UL)) {
    dstack_rewind(sm);
  }

  sm->list_mode = false;
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

StateMachine* init_machine(const char* src, size_t len) {
  size_t output_length = 0;
  StateMachine* sm = (StateMachine *)g_malloc0(sizeof(StateMachine));

  sm->p = src;
  sm->pb = sm->p;
  sm->pe = sm->p + len;
  sm->eof = sm->pe;
  sm->ts = NULL;
  sm->te = NULL;
  sm->cs = dtext_start;
  sm->act = 0;
  sm->top = 0;
  output_length = len;
  if (output_length < (INT16_MAX / 2)) {
    output_length *= 2;
  }
  sm->output = g_string_sized_new(output_length);
  sm->a1 = NULL;
  sm->a2 = NULL;
  sm->b1 = NULL;
  sm->b2 = NULL;
  sm->c1 = NULL;
  sm->c2 = NULL;
  sm->d1 = NULL;
  sm->d2 = NULL;
  sm->f_inline = FALSE;
  sm->f_mentions = TRUE;
  sm->base_url = NULL;
  sm->domain = NULL;
  sm->stack = g_array_sized_new(FALSE, TRUE, sizeof(int), 16);
  sm->dstack = g_queue_new();
  sm->error = NULL;
  sm->list_nest = 0;
  sm->list_mode = false;
  sm->header_mode = false;

  return sm;
}

void free_machine(StateMachine * sm) {
  g_string_free(sm->output, TRUE);
  g_array_unref(sm->stack);
  g_queue_free(sm->dstack);
  g_clear_error(&sm->error);
  g_free(sm);
}

GQuark dtext_parse_error_quark() {
  return g_quark_from_static_string("dtext-parse-error-quark");
}

GString* parse_basic_inline(const char* dtext, const ssize_t length) {
    GString* output = NULL;
    StateMachine* sm = init_machine(dtext, length);
    sm->f_inline = true;
    sm->f_mentions = false;
    sm->cs = dtext_en_basic_inline;

    if (parse_helper(sm)) {
      output = g_string_new(sm->output->str);
    } else {
      g_debug("parse_basic_inline failed");
    }

    free_machine(sm);
    return output;
}

gboolean parse_helper(StateMachine* sm) {
  const gchar* end = NULL;

  g_debug("start\n");

  if (!g_utf8_validate(sm->pb, sm->pe - sm->pb, &end)) {
    g_set_error(&sm->error, DTEXT_PARSE_ERROR, DTEXT_PARSE_ERROR_INVALID_UTF8, "invalid utf8 starting at byte %td", end - sm->pb + 1);
    return FALSE;
  }

  
#line 751 "ext/dtext/dtext.c"
	{
	( sm->top) = 0;
	( sm->ts) = 0;
	( sm->te) = 0;
	( sm->act) = 0;
	}

#line 1300 "ext/dtext/dtext.rl"
  
#line 761 "ext/dtext/dtext.c"
	{
	if ( ( sm->p) == ( sm->pe) )
		goto _test_eof;
_resume:
	switch ( _dtext_from_state_actions[ sm->cs] ) {
	case 77:
#line 1 "NONE"
	{( sm->ts) = ( sm->p);}
	break;
#line 771 "ext/dtext/dtext.c"
	}

	switch (  sm->cs ) {
case 696:
	switch( (*( sm->p)) ) {
		case 10: goto tr741;
		case 13: goto tr742;
		case 42: goto tr743;
		case 60: goto tr744;
		case 72: goto tr745;
		case 91: goto tr746;
		case 104: goto tr745;
	}
	goto tr740;
case 697:
	switch( (*( sm->p)) ) {
		case 10: goto tr1;
		case 13: goto tr747;
	}
	goto tr0;
case 0:
	if ( (*( sm->p)) == 10 )
		goto tr1;
	goto tr0;
case 698:
	if ( (*( sm->p)) == 10 )
		goto tr741;
	goto tr748;
case 699:
	switch( (*( sm->p)) ) {
		case 9: goto tr5;
		case 32: goto tr5;
		case 42: goto tr6;
	}
	goto tr748;
case 1:
	switch( (*( sm->p)) ) {
		case 9: goto tr4;
		case 10: goto tr2;
		case 13: goto tr2;
		case 32: goto tr4;
	}
	goto tr3;
case 700:
	switch( (*( sm->p)) ) {
		case 10: goto tr749;
		case 13: goto tr749;
	}
	goto tr750;
case 701:
	switch( (*( sm->p)) ) {
		case 9: goto tr4;
		case 10: goto tr749;
		case 13: goto tr749;
		case 32: goto tr4;
	}
	goto tr3;
case 2:
	switch( (*( sm->p)) ) {
		case 9: goto tr5;
		case 32: goto tr5;
		case 42: goto tr6;
	}
	goto tr2;
case 702:
	switch( (*( sm->p)) ) {
		case 47: goto tr751;
		case 66: goto tr752;
		case 67: goto tr753;
		case 69: goto tr754;
		case 78: goto tr755;
		case 81: goto tr20;
		case 83: goto tr756;
		case 84: goto tr757;
		case 98: goto tr752;
		case 99: goto tr753;
		case 101: goto tr754;
		case 110: goto tr755;
		case 113: goto tr20;
		case 115: goto tr756;
		case 116: goto tr757;
	}
	goto tr748;
case 3:
	switch( (*( sm->p)) ) {
		case 83: goto tr7;
		case 115: goto tr7;
	}
	goto tr2;
case 4:
	switch( (*( sm->p)) ) {
		case 80: goto tr8;
		case 112: goto tr8;
	}
	goto tr2;
case 5:
	switch( (*( sm->p)) ) {
		case 79: goto tr9;
		case 111: goto tr9;
	}
	goto tr2;
case 6:
	switch( (*( sm->p)) ) {
		case 73: goto tr10;
		case 105: goto tr10;
	}
	goto tr2;
case 7:
	switch( (*( sm->p)) ) {
		case 76: goto tr11;
		case 108: goto tr11;
	}
	goto tr2;
case 8:
	switch( (*( sm->p)) ) {
		case 69: goto tr12;
		case 101: goto tr12;
	}
	goto tr2;
case 9:
	switch( (*( sm->p)) ) {
		case 82: goto tr13;
		case 114: goto tr13;
	}
	goto tr2;
case 10:
	switch( (*( sm->p)) ) {
		case 62: goto tr14;
		case 83: goto tr15;
		case 115: goto tr15;
	}
	goto tr2;
case 11:
	if ( (*( sm->p)) == 62 )
		goto tr14;
	goto tr2;
case 12:
	switch( (*( sm->p)) ) {
		case 76: goto tr16;
		case 108: goto tr16;
	}
	goto tr2;
case 13:
	switch( (*( sm->p)) ) {
		case 79: goto tr17;
		case 111: goto tr17;
	}
	goto tr2;
case 14:
	switch( (*( sm->p)) ) {
		case 67: goto tr18;
		case 99: goto tr18;
	}
	goto tr2;
case 15:
	switch( (*( sm->p)) ) {
		case 75: goto tr19;
		case 107: goto tr19;
	}
	goto tr2;
case 16:
	switch( (*( sm->p)) ) {
		case 81: goto tr20;
		case 113: goto tr20;
	}
	goto tr2;
case 17:
	switch( (*( sm->p)) ) {
		case 85: goto tr21;
		case 117: goto tr21;
	}
	goto tr2;
case 18:
	switch( (*( sm->p)) ) {
		case 79: goto tr22;
		case 111: goto tr22;
	}
	goto tr2;
case 19:
	switch( (*( sm->p)) ) {
		case 84: goto tr23;
		case 116: goto tr23;
	}
	goto tr2;
case 20:
	switch( (*( sm->p)) ) {
		case 69: goto tr24;
		case 101: goto tr24;
	}
	goto tr2;
case 21:
	if ( (*( sm->p)) == 62 )
		goto tr25;
	goto tr2;
case 703:
	if ( (*( sm->p)) == 32 )
		goto tr25;
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr25;
	goto tr758;
case 22:
	switch( (*( sm->p)) ) {
		case 79: goto tr26;
		case 111: goto tr26;
	}
	goto tr2;
case 23:
	switch( (*( sm->p)) ) {
		case 68: goto tr27;
		case 100: goto tr27;
	}
	goto tr2;
case 24:
	switch( (*( sm->p)) ) {
		case 69: goto tr28;
		case 101: goto tr28;
	}
	goto tr2;
case 25:
	if ( (*( sm->p)) == 62 )
		goto tr29;
	goto tr2;
case 704:
	if ( (*( sm->p)) == 32 )
		goto tr29;
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr29;
	goto tr759;
case 26:
	switch( (*( sm->p)) ) {
		case 88: goto tr30;
		case 120: goto tr30;
	}
	goto tr2;
case 27:
	switch( (*( sm->p)) ) {
		case 80: goto tr31;
		case 112: goto tr31;
	}
	goto tr2;
case 28:
	switch( (*( sm->p)) ) {
		case 65: goto tr32;
		case 97: goto tr32;
	}
	goto tr2;
case 29:
	switch( (*( sm->p)) ) {
		case 78: goto tr33;
		case 110: goto tr33;
	}
	goto tr2;
case 30:
	switch( (*( sm->p)) ) {
		case 68: goto tr34;
		case 100: goto tr34;
	}
	goto tr2;
case 31:
	if ( (*( sm->p)) == 62 )
		goto tr35;
	goto tr2;
case 705:
	if ( (*( sm->p)) == 32 )
		goto tr35;
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr35;
	goto tr760;
case 32:
	switch( (*( sm->p)) ) {
		case 79: goto tr36;
		case 111: goto tr36;
	}
	goto tr2;
case 33:
	switch( (*( sm->p)) ) {
		case 68: goto tr37;
		case 100: goto tr37;
	}
	goto tr2;
case 34:
	switch( (*( sm->p)) ) {
		case 84: goto tr38;
		case 116: goto tr38;
	}
	goto tr2;
case 35:
	switch( (*( sm->p)) ) {
		case 69: goto tr39;
		case 101: goto tr39;
	}
	goto tr2;
case 36:
	switch( (*( sm->p)) ) {
		case 88: goto tr40;
		case 120: goto tr40;
	}
	goto tr2;
case 37:
	switch( (*( sm->p)) ) {
		case 84: goto tr41;
		case 116: goto tr41;
	}
	goto tr2;
case 38:
	if ( (*( sm->p)) == 62 )
		goto tr42;
	goto tr2;
case 706:
	if ( (*( sm->p)) == 32 )
		goto tr42;
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr42;
	goto tr761;
case 39:
	switch( (*( sm->p)) ) {
		case 80: goto tr43;
		case 112: goto tr43;
	}
	goto tr2;
case 40:
	switch( (*( sm->p)) ) {
		case 79: goto tr44;
		case 111: goto tr44;
	}
	goto tr2;
case 41:
	switch( (*( sm->p)) ) {
		case 73: goto tr45;
		case 105: goto tr45;
	}
	goto tr2;
case 42:
	switch( (*( sm->p)) ) {
		case 76: goto tr46;
		case 108: goto tr46;
	}
	goto tr2;
case 43:
	switch( (*( sm->p)) ) {
		case 69: goto tr47;
		case 101: goto tr47;
	}
	goto tr2;
case 44:
	switch( (*( sm->p)) ) {
		case 82: goto tr48;
		case 114: goto tr48;
	}
	goto tr2;
case 45:
	switch( (*( sm->p)) ) {
		case 62: goto tr49;
		case 83: goto tr50;
		case 115: goto tr50;
	}
	goto tr2;
case 707:
	if ( (*( sm->p)) == 32 )
		goto tr49;
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr49;
	goto tr762;
case 46:
	if ( (*( sm->p)) == 62 )
		goto tr49;
	goto tr2;
case 47:
	switch( (*( sm->p)) ) {
		case 65: goto tr51;
		case 78: goto tr52;
		case 97: goto tr51;
		case 110: goto tr52;
	}
	goto tr2;
case 48:
	switch( (*( sm->p)) ) {
		case 66: goto tr53;
		case 98: goto tr53;
	}
	goto tr2;
case 49:
	switch( (*( sm->p)) ) {
		case 76: goto tr54;
		case 108: goto tr54;
	}
	goto tr2;
case 50:
	switch( (*( sm->p)) ) {
		case 69: goto tr55;
		case 101: goto tr55;
	}
	goto tr2;
case 51:
	if ( (*( sm->p)) == 62 )
		goto tr56;
	goto tr2;
case 52:
	if ( (*( sm->p)) == 62 )
		goto tr57;
	goto tr2;
case 708:
	if ( 49 <= (*( sm->p)) && (*( sm->p)) <= 54 )
		goto tr763;
	goto tr748;
case 53:
	switch( (*( sm->p)) ) {
		case 35: goto tr58;
		case 46: goto tr59;
	}
	goto tr2;
case 54:
	if ( (*( sm->p)) == 33 )
		goto tr60;
	if ( (*( sm->p)) > 45 ) {
		if ( 47 <= (*( sm->p)) && (*( sm->p)) <= 126 )
			goto tr60;
	} else if ( (*( sm->p)) >= 35 )
		goto tr60;
	goto tr2;
case 55:
	switch( (*( sm->p)) ) {
		case 33: goto tr61;
		case 46: goto tr62;
	}
	if ( 35 <= (*( sm->p)) && (*( sm->p)) <= 126 )
		goto tr61;
	goto tr2;
case 709:
	switch( (*( sm->p)) ) {
		case 9: goto tr765;
		case 32: goto tr765;
	}
	goto tr764;
case 710:
	switch( (*( sm->p)) ) {
		case 9: goto tr767;
		case 32: goto tr767;
	}
	goto tr766;
case 711:
	switch( (*( sm->p)) ) {
		case 47: goto tr768;
		case 67: goto tr769;
		case 69: goto tr770;
		case 78: goto tr771;
		case 81: goto tr772;
		case 83: goto tr773;
		case 84: goto tr774;
		case 99: goto tr769;
		case 101: goto tr770;
		case 110: goto tr771;
		case 113: goto tr772;
		case 115: goto tr773;
		case 116: goto tr774;
	}
	goto tr748;
case 56:
	switch( (*( sm->p)) ) {
		case 83: goto tr63;
		case 115: goto tr63;
	}
	goto tr2;
case 57:
	switch( (*( sm->p)) ) {
		case 80: goto tr64;
		case 112: goto tr64;
	}
	goto tr2;
case 58:
	switch( (*( sm->p)) ) {
		case 79: goto tr65;
		case 111: goto tr65;
	}
	goto tr2;
case 59:
	switch( (*( sm->p)) ) {
		case 73: goto tr66;
		case 105: goto tr66;
	}
	goto tr2;
case 60:
	switch( (*( sm->p)) ) {
		case 76: goto tr67;
		case 108: goto tr67;
	}
	goto tr2;
case 61:
	switch( (*( sm->p)) ) {
		case 69: goto tr68;
		case 101: goto tr68;
	}
	goto tr2;
case 62:
	switch( (*( sm->p)) ) {
		case 82: goto tr69;
		case 114: goto tr69;
	}
	goto tr2;
case 63:
	switch( (*( sm->p)) ) {
		case 83: goto tr70;
		case 93: goto tr14;
		case 115: goto tr70;
	}
	goto tr2;
case 64:
	if ( (*( sm->p)) == 93 )
		goto tr14;
	goto tr2;
case 65:
	switch( (*( sm->p)) ) {
		case 79: goto tr71;
		case 111: goto tr71;
	}
	goto tr2;
case 66:
	switch( (*( sm->p)) ) {
		case 68: goto tr72;
		case 100: goto tr72;
	}
	goto tr2;
case 67:
	switch( (*( sm->p)) ) {
		case 69: goto tr73;
		case 101: goto tr73;
	}
	goto tr2;
case 68:
	if ( (*( sm->p)) == 93 )
		goto tr29;
	goto tr2;
case 69:
	switch( (*( sm->p)) ) {
		case 88: goto tr74;
		case 120: goto tr74;
	}
	goto tr2;
case 70:
	switch( (*( sm->p)) ) {
		case 80: goto tr75;
		case 112: goto tr75;
	}
	goto tr2;
case 71:
	switch( (*( sm->p)) ) {
		case 65: goto tr76;
		case 97: goto tr76;
	}
	goto tr2;
case 72:
	switch( (*( sm->p)) ) {
		case 78: goto tr77;
		case 110: goto tr77;
	}
	goto tr2;
case 73:
	switch( (*( sm->p)) ) {
		case 68: goto tr78;
		case 100: goto tr78;
	}
	goto tr2;
case 74:
	switch( (*( sm->p)) ) {
		case 61: goto tr79;
		case 93: goto tr35;
	}
	goto tr2;
case 75:
	if ( (*( sm->p)) == 93 )
		goto tr2;
	goto tr80;
case 76:
	if ( (*( sm->p)) == 93 )
		goto tr82;
	goto tr81;
case 712:
	if ( (*( sm->p)) == 32 )
		goto tr776;
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr776;
	goto tr775;
case 77:
	switch( (*( sm->p)) ) {
		case 79: goto tr83;
		case 111: goto tr83;
	}
	goto tr2;
case 78:
	switch( (*( sm->p)) ) {
		case 68: goto tr84;
		case 100: goto tr84;
	}
	goto tr2;
case 79:
	switch( (*( sm->p)) ) {
		case 84: goto tr85;
		case 116: goto tr85;
	}
	goto tr2;
case 80:
	switch( (*( sm->p)) ) {
		case 69: goto tr86;
		case 101: goto tr86;
	}
	goto tr2;
case 81:
	switch( (*( sm->p)) ) {
		case 88: goto tr87;
		case 120: goto tr87;
	}
	goto tr2;
case 82:
	switch( (*( sm->p)) ) {
		case 84: goto tr88;
		case 116: goto tr88;
	}
	goto tr2;
case 83:
	if ( (*( sm->p)) == 93 )
		goto tr42;
	goto tr2;
case 84:
	switch( (*( sm->p)) ) {
		case 85: goto tr89;
		case 117: goto tr89;
	}
	goto tr2;
case 85:
	switch( (*( sm->p)) ) {
		case 79: goto tr90;
		case 111: goto tr90;
	}
	goto tr2;
case 86:
	switch( (*( sm->p)) ) {
		case 84: goto tr91;
		case 116: goto tr91;
	}
	goto tr2;
case 87:
	switch( (*( sm->p)) ) {
		case 69: goto tr92;
		case 101: goto tr92;
	}
	goto tr2;
case 88:
	if ( (*( sm->p)) == 93 )
		goto tr25;
	goto tr2;
case 89:
	switch( (*( sm->p)) ) {
		case 80: goto tr93;
		case 112: goto tr93;
	}
	goto tr2;
case 90:
	switch( (*( sm->p)) ) {
		case 79: goto tr94;
		case 111: goto tr94;
	}
	goto tr2;
case 91:
	switch( (*( sm->p)) ) {
		case 73: goto tr95;
		case 105: goto tr95;
	}
	goto tr2;
case 92:
	switch( (*( sm->p)) ) {
		case 76: goto tr96;
		case 108: goto tr96;
	}
	goto tr2;
case 93:
	switch( (*( sm->p)) ) {
		case 69: goto tr97;
		case 101: goto tr97;
	}
	goto tr2;
case 94:
	switch( (*( sm->p)) ) {
		case 82: goto tr98;
		case 114: goto tr98;
	}
	goto tr2;
case 95:
	switch( (*( sm->p)) ) {
		case 83: goto tr99;
		case 93: goto tr49;
		case 115: goto tr99;
	}
	goto tr2;
case 96:
	if ( (*( sm->p)) == 93 )
		goto tr49;
	goto tr2;
case 97:
	switch( (*( sm->p)) ) {
		case 65: goto tr100;
		case 78: goto tr101;
		case 97: goto tr100;
		case 110: goto tr101;
	}
	goto tr2;
case 98:
	switch( (*( sm->p)) ) {
		case 66: goto tr102;
		case 98: goto tr102;
	}
	goto tr2;
case 99:
	switch( (*( sm->p)) ) {
		case 76: goto tr103;
		case 108: goto tr103;
	}
	goto tr2;
case 100:
	switch( (*( sm->p)) ) {
		case 69: goto tr104;
		case 101: goto tr104;
	}
	goto tr2;
case 101:
	if ( (*( sm->p)) == 93 )
		goto tr56;
	goto tr2;
case 102:
	if ( (*( sm->p)) == 93 )
		goto tr57;
	goto tr2;
case 713:
	switch( (*( sm->p)) ) {
		case 60: goto tr778;
		case 91: goto tr779;
	}
	goto tr777;
case 714:
	switch( (*( sm->p)) ) {
		case 47: goto tr781;
		case 66: goto tr127;
		case 69: goto tr782;
		case 73: goto tr120;
		case 83: goto tr783;
		case 85: goto tr784;
		case 98: goto tr127;
		case 101: goto tr782;
		case 105: goto tr120;
		case 115: goto tr783;
		case 117: goto tr784;
	}
	goto tr780;
case 103:
	switch( (*( sm->p)) ) {
		case 66: goto tr106;
		case 69: goto tr107;
		case 73: goto tr108;
		case 83: goto tr109;
		case 85: goto tr110;
		case 98: goto tr106;
		case 101: goto tr107;
		case 105: goto tr108;
		case 115: goto tr109;
		case 117: goto tr110;
	}
	goto tr105;
case 104:
	if ( (*( sm->p)) == 62 )
		goto tr111;
	goto tr105;
case 105:
	switch( (*( sm->p)) ) {
		case 77: goto tr108;
		case 109: goto tr108;
	}
	goto tr105;
case 106:
	if ( (*( sm->p)) == 62 )
		goto tr112;
	goto tr105;
case 107:
	switch( (*( sm->p)) ) {
		case 62: goto tr113;
		case 84: goto tr114;
		case 116: goto tr114;
	}
	goto tr105;
case 108:
	switch( (*( sm->p)) ) {
		case 82: goto tr115;
		case 114: goto tr115;
	}
	goto tr105;
case 109:
	switch( (*( sm->p)) ) {
		case 79: goto tr116;
		case 111: goto tr116;
	}
	goto tr105;
case 110:
	switch( (*( sm->p)) ) {
		case 78: goto tr117;
		case 110: goto tr117;
	}
	goto tr105;
case 111:
	switch( (*( sm->p)) ) {
		case 71: goto tr106;
		case 103: goto tr106;
	}
	goto tr105;
case 112:
	if ( (*( sm->p)) == 62 )
		goto tr118;
	goto tr105;
case 113:
	if ( (*( sm->p)) == 62 )
		goto tr119;
	goto tr105;
case 114:
	switch( (*( sm->p)) ) {
		case 77: goto tr120;
		case 109: goto tr120;
	}
	goto tr105;
case 115:
	if ( (*( sm->p)) == 62 )
		goto tr121;
	goto tr105;
case 116:
	switch( (*( sm->p)) ) {
		case 62: goto tr122;
		case 84: goto tr123;
		case 116: goto tr123;
	}
	goto tr105;
case 117:
	switch( (*( sm->p)) ) {
		case 82: goto tr124;
		case 114: goto tr124;
	}
	goto tr105;
case 118:
	switch( (*( sm->p)) ) {
		case 79: goto tr125;
		case 111: goto tr125;
	}
	goto tr105;
case 119:
	switch( (*( sm->p)) ) {
		case 78: goto tr126;
		case 110: goto tr126;
	}
	goto tr105;
case 120:
	switch( (*( sm->p)) ) {
		case 71: goto tr127;
		case 103: goto tr127;
	}
	goto tr105;
case 121:
	if ( (*( sm->p)) == 62 )
		goto tr128;
	goto tr105;
case 715:
	switch( (*( sm->p)) ) {
		case 47: goto tr785;
		case 66: goto tr786;
		case 73: goto tr787;
		case 83: goto tr788;
		case 85: goto tr789;
		case 98: goto tr786;
		case 105: goto tr787;
		case 115: goto tr788;
		case 117: goto tr789;
	}
	goto tr780;
case 122:
	switch( (*( sm->p)) ) {
		case 66: goto tr129;
		case 73: goto tr130;
		case 83: goto tr131;
		case 85: goto tr132;
		case 98: goto tr129;
		case 105: goto tr130;
		case 115: goto tr131;
		case 117: goto tr132;
	}
	goto tr105;
case 123:
	if ( (*( sm->p)) == 93 )
		goto tr111;
	goto tr105;
case 124:
	if ( (*( sm->p)) == 93 )
		goto tr112;
	goto tr105;
case 125:
	if ( (*( sm->p)) == 93 )
		goto tr113;
	goto tr105;
case 126:
	if ( (*( sm->p)) == 93 )
		goto tr118;
	goto tr105;
case 127:
	if ( (*( sm->p)) == 93 )
		goto tr119;
	goto tr105;
case 128:
	if ( (*( sm->p)) == 93 )
		goto tr121;
	goto tr105;
case 129:
	if ( (*( sm->p)) == 93 )
		goto tr122;
	goto tr105;
case 130:
	if ( (*( sm->p)) == 93 )
		goto tr128;
	goto tr105;
case 716:
	switch( (*( sm->p)) ) {
		case 10: goto tr791;
		case 13: goto tr792;
		case 34: goto tr793;
		case 60: goto tr795;
		case 64: goto tr796;
		case 65: goto tr797;
		case 66: goto tr798;
		case 67: goto tr799;
		case 68: goto tr800;
		case 70: goto tr801;
		case 71: goto tr802;
		case 73: goto tr803;
		case 77: goto tr804;
		case 78: goto tr805;
		case 80: goto tr806;
		case 83: goto tr807;
		case 84: goto tr808;
		case 85: goto tr809;
		case 87: goto tr810;
		case 89: goto tr811;
		case 91: goto tr812;
		case 97: goto tr797;
		case 98: goto tr798;
		case 99: goto tr799;
		case 100: goto tr800;
		case 102: goto tr801;
		case 103: goto tr802;
		case 104: goto tr813;
		case 105: goto tr803;
		case 109: goto tr804;
		case 110: goto tr805;
		case 112: goto tr806;
		case 115: goto tr807;
		case 116: goto tr808;
		case 117: goto tr809;
		case 119: goto tr810;
		case 121: goto tr811;
		case 123: goto tr814;
	}
	if ( (*( sm->p)) < 69 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr794;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 101 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr794;
	} else
		goto tr794;
	goto tr790;
case 717:
	switch( (*( sm->p)) ) {
		case 10: goto tr134;
		case 13: goto tr816;
		case 42: goto tr817;
	}
	goto tr815;
case 718:
	switch( (*( sm->p)) ) {
		case 10: goto tr134;
		case 13: goto tr816;
	}
	goto tr818;
case 131:
	if ( (*( sm->p)) == 10 )
		goto tr134;
	goto tr133;
case 132:
	switch( (*( sm->p)) ) {
		case 9: goto tr136;
		case 32: goto tr136;
		case 42: goto tr137;
	}
	goto tr135;
case 133:
	switch( (*( sm->p)) ) {
		case 9: goto tr139;
		case 10: goto tr135;
		case 13: goto tr135;
		case 32: goto tr139;
	}
	goto tr138;
case 719:
	switch( (*( sm->p)) ) {
		case 10: goto tr819;
		case 13: goto tr819;
	}
	goto tr820;
case 720:
	switch( (*( sm->p)) ) {
		case 9: goto tr139;
		case 10: goto tr819;
		case 13: goto tr819;
		case 32: goto tr139;
	}
	goto tr138;
case 721:
	if ( (*( sm->p)) == 10 )
		goto tr791;
	goto tr821;
case 722:
	if ( (*( sm->p)) == 34 )
		goto tr822;
	goto tr823;
case 134:
	if ( (*( sm->p)) == 34 )
		goto tr142;
	goto tr141;
case 135:
	if ( (*( sm->p)) == 58 )
		goto tr143;
	goto tr140;
case 136:
	switch( (*( sm->p)) ) {
		case 35: goto tr144;
		case 47: goto tr144;
		case 91: goto tr145;
		case 104: goto tr146;
	}
	goto tr140;
case 137:
	if ( (*( sm->p)) < -32 ) {
		if ( -62 <= (*( sm->p)) && (*( sm->p)) <= -33 )
			goto tr147;
	} else if ( (*( sm->p)) > -17 ) {
		if ( (*( sm->p)) > -12 ) {
			if ( 33 <= (*( sm->p)) && (*( sm->p)) <= 126 )
				goto tr150;
		} else if ( (*( sm->p)) >= -16 )
			goto tr149;
	} else
		goto tr148;
	goto tr140;
case 138:
	if ( (*( sm->p)) <= -65 )
		goto tr150;
	goto tr133;
case 723:
	if ( (*( sm->p)) < -32 ) {
		if ( -62 <= (*( sm->p)) && (*( sm->p)) <= -33 )
			goto tr147;
	} else if ( (*( sm->p)) > -17 ) {
		if ( (*( sm->p)) > -12 ) {
			if ( 33 <= (*( sm->p)) && (*( sm->p)) <= 126 )
				goto tr150;
		} else if ( (*( sm->p)) >= -16 )
			goto tr149;
	} else
		goto tr148;
	goto tr824;
case 139:
	if ( (*( sm->p)) <= -65 )
		goto tr147;
	goto tr133;
case 140:
	if ( (*( sm->p)) <= -65 )
		goto tr148;
	goto tr133;
case 141:
	switch( (*( sm->p)) ) {
		case 35: goto tr151;
		case 47: goto tr151;
		case 104: goto tr152;
	}
	goto tr140;
case 142:
	if ( (*( sm->p)) < -32 ) {
		if ( -62 <= (*( sm->p)) && (*( sm->p)) <= -33 )
			goto tr153;
	} else if ( (*( sm->p)) > -17 ) {
		if ( (*( sm->p)) > -12 ) {
			if ( 33 <= (*( sm->p)) && (*( sm->p)) <= 126 )
				goto tr156;
		} else if ( (*( sm->p)) >= -16 )
			goto tr155;
	} else
		goto tr154;
	goto tr140;
case 143:
	if ( (*( sm->p)) <= -65 )
		goto tr156;
	goto tr140;
case 144:
	if ( (*( sm->p)) == 93 )
		goto tr157;
	if ( (*( sm->p)) < -32 ) {
		if ( -62 <= (*( sm->p)) && (*( sm->p)) <= -33 )
			goto tr153;
	} else if ( (*( sm->p)) > -17 ) {
		if ( (*( sm->p)) > -12 ) {
			if ( 33 <= (*( sm->p)) && (*( sm->p)) <= 126 )
				goto tr156;
		} else if ( (*( sm->p)) >= -16 )
			goto tr155;
	} else
		goto tr154;
	goto tr140;
case 145:
	if ( (*( sm->p)) <= -65 )
		goto tr153;
	goto tr140;
case 146:
	if ( (*( sm->p)) <= -65 )
		goto tr154;
	goto tr140;
case 147:
	if ( (*( sm->p)) == 116 )
		goto tr158;
	goto tr140;
case 148:
	if ( (*( sm->p)) == 116 )
		goto tr159;
	goto tr140;
case 149:
	if ( (*( sm->p)) == 112 )
		goto tr160;
	goto tr140;
case 150:
	switch( (*( sm->p)) ) {
		case 58: goto tr161;
		case 115: goto tr162;
	}
	goto tr140;
case 151:
	if ( (*( sm->p)) == 47 )
		goto tr163;
	goto tr140;
case 152:
	if ( (*( sm->p)) == 47 )
		goto tr164;
	goto tr140;
case 153:
	if ( (*( sm->p)) == 58 )
		goto tr161;
	goto tr140;
case 154:
	if ( (*( sm->p)) == 116 )
		goto tr165;
	goto tr140;
case 155:
	if ( (*( sm->p)) == 116 )
		goto tr166;
	goto tr140;
case 156:
	if ( (*( sm->p)) == 112 )
		goto tr167;
	goto tr140;
case 157:
	switch( (*( sm->p)) ) {
		case 58: goto tr168;
		case 115: goto tr169;
	}
	goto tr140;
case 158:
	if ( (*( sm->p)) == 47 )
		goto tr170;
	goto tr140;
case 159:
	if ( (*( sm->p)) == 47 )
		goto tr171;
	goto tr140;
case 160:
	if ( (*( sm->p)) == 58 )
		goto tr168;
	goto tr140;
case 724:
	if ( (*( sm->p)) == 91 )
		goto tr173;
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr172;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr172;
	} else
		goto tr172;
	goto tr822;
case 161:
	if ( (*( sm->p)) == 91 )
		goto tr173;
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr172;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr172;
	} else
		goto tr172;
	goto tr140;
case 162:
	if ( (*( sm->p)) == 91 )
		goto tr174;
	goto tr140;
case 163:
	switch( (*( sm->p)) ) {
		case 93: goto tr140;
		case 124: goto tr176;
	}
	goto tr175;
case 164:
	switch( (*( sm->p)) ) {
		case 93: goto tr178;
		case 124: goto tr179;
	}
	goto tr177;
case 165:
	if ( (*( sm->p)) == 93 )
		goto tr180;
	goto tr140;
case 725:
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr826;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr826;
	} else
		goto tr826;
	goto tr825;
case 726:
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr828;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr828;
	} else
		goto tr828;
	goto tr827;
case 166:
	switch( (*( sm->p)) ) {
		case 93: goto tr182;
		case 124: goto tr140;
	}
	goto tr181;
case 167:
	switch( (*( sm->p)) ) {
		case 93: goto tr184;
		case 124: goto tr140;
	}
	goto tr183;
case 168:
	if ( (*( sm->p)) == 93 )
		goto tr185;
	goto tr140;
case 727:
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr830;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr830;
	} else
		goto tr830;
	goto tr829;
case 728:
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr832;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr832;
	} else
		goto tr832;
	goto tr831;
case 169:
	switch( (*( sm->p)) ) {
		case 93: goto tr178;
		case 124: goto tr140;
	}
	goto tr186;
case 729:
	switch( (*( sm->p)) ) {
		case 47: goto tr833;
		case 64: goto tr834;
		case 65: goto tr835;
		case 66: goto tr836;
		case 67: goto tr837;
		case 69: goto tr838;
		case 73: goto tr284;
		case 78: goto tr839;
		case 81: goto tr274;
		case 83: goto tr840;
		case 84: goto tr841;
		case 85: goto tr842;
		case 97: goto tr835;
		case 98: goto tr836;
		case 99: goto tr837;
		case 101: goto tr838;
		case 104: goto tr843;
		case 105: goto tr284;
		case 110: goto tr839;
		case 113: goto tr274;
		case 115: goto tr840;
		case 116: goto tr841;
		case 117: goto tr842;
	}
	goto tr822;
case 170:
	switch( (*( sm->p)) ) {
		case 66: goto tr187;
		case 69: goto tr188;
		case 73: goto tr189;
		case 81: goto tr190;
		case 83: goto tr191;
		case 84: goto tr192;
		case 85: goto tr193;
		case 98: goto tr187;
		case 101: goto tr188;
		case 105: goto tr189;
		case 113: goto tr190;
		case 115: goto tr191;
		case 116: goto tr192;
		case 117: goto tr193;
	}
	goto tr140;
case 171:
	switch( (*( sm->p)) ) {
		case 62: goto tr194;
		case 76: goto tr195;
		case 108: goto tr195;
	}
	goto tr140;
case 172:
	switch( (*( sm->p)) ) {
		case 79: goto tr196;
		case 111: goto tr196;
	}
	goto tr140;
case 173:
	switch( (*( sm->p)) ) {
		case 67: goto tr197;
		case 99: goto tr197;
	}
	goto tr140;
case 174:
	switch( (*( sm->p)) ) {
		case 75: goto tr198;
		case 107: goto tr198;
	}
	goto tr140;
case 175:
	switch( (*( sm->p)) ) {
		case 81: goto tr190;
		case 113: goto tr190;
	}
	goto tr140;
case 176:
	switch( (*( sm->p)) ) {
		case 85: goto tr199;
		case 117: goto tr199;
	}
	goto tr140;
case 177:
	switch( (*( sm->p)) ) {
		case 79: goto tr200;
		case 111: goto tr200;
	}
	goto tr140;
case 178:
	switch( (*( sm->p)) ) {
		case 84: goto tr201;
		case 116: goto tr201;
	}
	goto tr140;
case 179:
	switch( (*( sm->p)) ) {
		case 69: goto tr202;
		case 101: goto tr202;
	}
	goto tr140;
case 180:
	if ( (*( sm->p)) == 62 )
		goto tr203;
	goto tr140;
case 730:
	if ( (*( sm->p)) == 32 )
		goto tr203;
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr203;
	goto tr844;
case 181:
	switch( (*( sm->p)) ) {
		case 77: goto tr189;
		case 88: goto tr204;
		case 109: goto tr189;
		case 120: goto tr204;
	}
	goto tr140;
case 182:
	if ( (*( sm->p)) == 62 )
		goto tr205;
	goto tr140;
case 183:
	switch( (*( sm->p)) ) {
		case 80: goto tr206;
		case 112: goto tr206;
	}
	goto tr140;
case 184:
	switch( (*( sm->p)) ) {
		case 65: goto tr207;
		case 97: goto tr207;
	}
	goto tr140;
case 185:
	switch( (*( sm->p)) ) {
		case 78: goto tr208;
		case 110: goto tr208;
	}
	goto tr140;
case 186:
	switch( (*( sm->p)) ) {
		case 68: goto tr209;
		case 100: goto tr209;
	}
	goto tr140;
case 187:
	if ( (*( sm->p)) == 62 )
		goto tr210;
	goto tr140;
case 188:
	switch( (*( sm->p)) ) {
		case 62: goto tr211;
		case 80: goto tr212;
		case 84: goto tr213;
		case 112: goto tr212;
		case 116: goto tr213;
	}
	goto tr140;
case 189:
	switch( (*( sm->p)) ) {
		case 79: goto tr214;
		case 111: goto tr214;
	}
	goto tr140;
case 190:
	switch( (*( sm->p)) ) {
		case 73: goto tr215;
		case 105: goto tr215;
	}
	goto tr140;
case 191:
	switch( (*( sm->p)) ) {
		case 76: goto tr216;
		case 108: goto tr216;
	}
	goto tr140;
case 192:
	switch( (*( sm->p)) ) {
		case 69: goto tr217;
		case 101: goto tr217;
	}
	goto tr140;
case 193:
	switch( (*( sm->p)) ) {
		case 82: goto tr218;
		case 114: goto tr218;
	}
	goto tr140;
case 194:
	switch( (*( sm->p)) ) {
		case 62: goto tr219;
		case 83: goto tr220;
		case 115: goto tr220;
	}
	goto tr140;
case 195:
	if ( (*( sm->p)) == 62 )
		goto tr219;
	goto tr140;
case 196:
	switch( (*( sm->p)) ) {
		case 82: goto tr221;
		case 114: goto tr221;
	}
	goto tr140;
case 197:
	switch( (*( sm->p)) ) {
		case 79: goto tr222;
		case 111: goto tr222;
	}
	goto tr140;
case 198:
	switch( (*( sm->p)) ) {
		case 78: goto tr223;
		case 110: goto tr223;
	}
	goto tr140;
case 199:
	switch( (*( sm->p)) ) {
		case 71: goto tr224;
		case 103: goto tr224;
	}
	goto tr140;
case 200:
	if ( (*( sm->p)) == 62 )
		goto tr194;
	goto tr140;
case 201:
	switch( (*( sm->p)) ) {
		case 68: goto tr225;
		case 72: goto tr226;
		case 78: goto tr227;
		case 100: goto tr225;
		case 104: goto tr226;
		case 110: goto tr227;
	}
	goto tr140;
case 202:
	if ( (*( sm->p)) == 62 )
		goto tr228;
	goto tr140;
case 203:
	if ( (*( sm->p)) == 62 )
		goto tr229;
	goto tr140;
case 204:
	if ( (*( sm->p)) == 62 )
		goto tr230;
	goto tr140;
case 205:
	if ( (*( sm->p)) == 62 )
		goto tr231;
	goto tr140;
case 206:
	if ( (*( sm->p)) < -32 ) {
		if ( -62 <= (*( sm->p)) && (*( sm->p)) <= -33 )
			goto tr232;
	} else if ( (*( sm->p)) > -17 ) {
		if ( (*( sm->p)) > -12 ) {
			if ( 33 <= (*( sm->p)) && (*( sm->p)) <= 126 )
				goto tr235;
		} else if ( (*( sm->p)) >= -16 )
			goto tr234;
	} else
		goto tr233;
	goto tr140;
case 207:
	if ( (*( sm->p)) <= -65 )
		goto tr236;
	goto tr140;
case 208:
	if ( (*( sm->p)) == 62 )
		goto tr240;
	if ( (*( sm->p)) < -32 ) {
		if ( -62 <= (*( sm->p)) && (*( sm->p)) <= -33 )
			goto tr237;
	} else if ( (*( sm->p)) > -17 ) {
		if ( (*( sm->p)) > -12 ) {
			if ( 33 <= (*( sm->p)) && (*( sm->p)) <= 126 )
				goto tr236;
		} else if ( (*( sm->p)) >= -16 )
			goto tr239;
	} else
		goto tr238;
	goto tr140;
case 209:
	if ( (*( sm->p)) <= -65 )
		goto tr237;
	goto tr140;
case 210:
	if ( (*( sm->p)) <= -65 )
		goto tr238;
	goto tr140;
case 211:
	if ( (*( sm->p)) == 32 )
		goto tr241;
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr241;
	goto tr140;
case 212:
	switch( (*( sm->p)) ) {
		case 32: goto tr241;
		case 72: goto tr242;
		case 104: goto tr242;
	}
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr241;
	goto tr140;
case 213:
	switch( (*( sm->p)) ) {
		case 82: goto tr243;
		case 114: goto tr243;
	}
	goto tr140;
case 214:
	switch( (*( sm->p)) ) {
		case 69: goto tr244;
		case 101: goto tr244;
	}
	goto tr140;
case 215:
	switch( (*( sm->p)) ) {
		case 70: goto tr245;
		case 102: goto tr245;
	}
	goto tr140;
case 216:
	if ( (*( sm->p)) == 61 )
		goto tr246;
	goto tr140;
case 217:
	if ( (*( sm->p)) == 34 )
		goto tr247;
	goto tr140;
case 218:
	switch( (*( sm->p)) ) {
		case 35: goto tr248;
		case 47: goto tr248;
		case 104: goto tr249;
	}
	goto tr140;
case 219:
	if ( (*( sm->p)) < -32 ) {
		if ( -62 <= (*( sm->p)) && (*( sm->p)) <= -33 )
			goto tr250;
	} else if ( (*( sm->p)) > -17 ) {
		if ( (*( sm->p)) > -12 ) {
			if ( 33 <= (*( sm->p)) && (*( sm->p)) <= 126 )
				goto tr253;
		} else if ( (*( sm->p)) >= -16 )
			goto tr252;
	} else
		goto tr251;
	goto tr140;
case 220:
	if ( (*( sm->p)) <= -65 )
		goto tr253;
	goto tr140;
case 221:
	if ( (*( sm->p)) == 34 )
		goto tr254;
	if ( (*( sm->p)) < -32 ) {
		if ( -62 <= (*( sm->p)) && (*( sm->p)) <= -33 )
			goto tr250;
	} else if ( (*( sm->p)) > -17 ) {
		if ( (*( sm->p)) > -12 ) {
			if ( 33 <= (*( sm->p)) && (*( sm->p)) <= 126 )
				goto tr253;
		} else if ( (*( sm->p)) >= -16 )
			goto tr252;
	} else
		goto tr251;
	goto tr140;
case 222:
	if ( (*( sm->p)) <= -65 )
		goto tr250;
	goto tr140;
case 223:
	if ( (*( sm->p)) <= -65 )
		goto tr251;
	goto tr140;
case 224:
	switch( (*( sm->p)) ) {
		case 34: goto tr254;
		case 62: goto tr255;
	}
	if ( (*( sm->p)) < -32 ) {
		if ( -62 <= (*( sm->p)) && (*( sm->p)) <= -33 )
			goto tr250;
	} else if ( (*( sm->p)) > -17 ) {
		if ( (*( sm->p)) > -12 ) {
			if ( 33 <= (*( sm->p)) && (*( sm->p)) <= 126 )
				goto tr253;
		} else if ( (*( sm->p)) >= -16 )
			goto tr252;
	} else
		goto tr251;
	goto tr140;
case 225:
	switch( (*( sm->p)) ) {
		case 10: goto tr140;
		case 13: goto tr140;
	}
	goto tr256;
case 226:
	switch( (*( sm->p)) ) {
		case 10: goto tr140;
		case 13: goto tr140;
		case 60: goto tr258;
	}
	goto tr257;
case 227:
	switch( (*( sm->p)) ) {
		case 10: goto tr140;
		case 13: goto tr140;
		case 47: goto tr259;
		case 60: goto tr258;
	}
	goto tr257;
case 228:
	switch( (*( sm->p)) ) {
		case 10: goto tr140;
		case 13: goto tr140;
		case 60: goto tr258;
		case 65: goto tr260;
		case 97: goto tr260;
	}
	goto tr257;
case 229:
	switch( (*( sm->p)) ) {
		case 10: goto tr140;
		case 13: goto tr140;
		case 60: goto tr258;
		case 62: goto tr261;
	}
	goto tr257;
case 230:
	if ( (*( sm->p)) == 116 )
		goto tr262;
	goto tr140;
case 231:
	if ( (*( sm->p)) == 116 )
		goto tr263;
	goto tr140;
case 232:
	if ( (*( sm->p)) == 112 )
		goto tr264;
	goto tr140;
case 233:
	switch( (*( sm->p)) ) {
		case 58: goto tr265;
		case 115: goto tr266;
	}
	goto tr140;
case 234:
	if ( (*( sm->p)) == 47 )
		goto tr267;
	goto tr140;
case 235:
	if ( (*( sm->p)) == 47 )
		goto tr268;
	goto tr140;
case 236:
	if ( (*( sm->p)) == 58 )
		goto tr265;
	goto tr140;
case 237:
	switch( (*( sm->p)) ) {
		case 62: goto tr269;
		case 76: goto tr270;
		case 108: goto tr270;
	}
	goto tr140;
case 238:
	switch( (*( sm->p)) ) {
		case 79: goto tr271;
		case 111: goto tr271;
	}
	goto tr140;
case 239:
	switch( (*( sm->p)) ) {
		case 67: goto tr272;
		case 99: goto tr272;
	}
	goto tr140;
case 240:
	switch( (*( sm->p)) ) {
		case 75: goto tr273;
		case 107: goto tr273;
	}
	goto tr140;
case 241:
	switch( (*( sm->p)) ) {
		case 81: goto tr274;
		case 113: goto tr274;
	}
	goto tr140;
case 242:
	switch( (*( sm->p)) ) {
		case 85: goto tr275;
		case 117: goto tr275;
	}
	goto tr140;
case 243:
	switch( (*( sm->p)) ) {
		case 79: goto tr276;
		case 111: goto tr276;
	}
	goto tr140;
case 244:
	switch( (*( sm->p)) ) {
		case 84: goto tr277;
		case 116: goto tr277;
	}
	goto tr140;
case 245:
	switch( (*( sm->p)) ) {
		case 69: goto tr278;
		case 101: goto tr278;
	}
	goto tr140;
case 246:
	if ( (*( sm->p)) == 62 )
		goto tr279;
	goto tr140;
case 247:
	switch( (*( sm->p)) ) {
		case 79: goto tr280;
		case 111: goto tr280;
	}
	goto tr140;
case 248:
	switch( (*( sm->p)) ) {
		case 68: goto tr281;
		case 100: goto tr281;
	}
	goto tr140;
case 249:
	switch( (*( sm->p)) ) {
		case 69: goto tr282;
		case 101: goto tr282;
	}
	goto tr140;
case 250:
	if ( (*( sm->p)) == 62 )
		goto tr283;
	goto tr140;
case 251:
	switch( (*( sm->p)) ) {
		case 77: goto tr284;
		case 88: goto tr285;
		case 109: goto tr284;
		case 120: goto tr285;
	}
	goto tr140;
case 252:
	if ( (*( sm->p)) == 62 )
		goto tr286;
	goto tr140;
case 253:
	switch( (*( sm->p)) ) {
		case 80: goto tr287;
		case 112: goto tr287;
	}
	goto tr140;
case 254:
	switch( (*( sm->p)) ) {
		case 65: goto tr288;
		case 97: goto tr288;
	}
	goto tr140;
case 255:
	switch( (*( sm->p)) ) {
		case 78: goto tr289;
		case 110: goto tr289;
	}
	goto tr140;
case 256:
	switch( (*( sm->p)) ) {
		case 68: goto tr290;
		case 100: goto tr290;
	}
	goto tr140;
case 257:
	if ( (*( sm->p)) == 62 )
		goto tr291;
	goto tr140;
case 258:
	switch( (*( sm->p)) ) {
		case 79: goto tr292;
		case 111: goto tr292;
	}
	goto tr140;
case 259:
	switch( (*( sm->p)) ) {
		case 68: goto tr293;
		case 100: goto tr293;
	}
	goto tr140;
case 260:
	switch( (*( sm->p)) ) {
		case 84: goto tr294;
		case 116: goto tr294;
	}
	goto tr140;
case 261:
	switch( (*( sm->p)) ) {
		case 69: goto tr295;
		case 101: goto tr295;
	}
	goto tr140;
case 262:
	switch( (*( sm->p)) ) {
		case 88: goto tr296;
		case 120: goto tr296;
	}
	goto tr140;
case 263:
	switch( (*( sm->p)) ) {
		case 84: goto tr297;
		case 116: goto tr297;
	}
	goto tr140;
case 264:
	if ( (*( sm->p)) == 62 )
		goto tr298;
	goto tr140;
case 265:
	switch( (*( sm->p)) ) {
		case 62: goto tr299;
		case 80: goto tr300;
		case 84: goto tr301;
		case 112: goto tr300;
		case 116: goto tr301;
	}
	goto tr140;
case 266:
	switch( (*( sm->p)) ) {
		case 79: goto tr302;
		case 111: goto tr302;
	}
	goto tr140;
case 267:
	switch( (*( sm->p)) ) {
		case 73: goto tr303;
		case 105: goto tr303;
	}
	goto tr140;
case 268:
	switch( (*( sm->p)) ) {
		case 76: goto tr304;
		case 108: goto tr304;
	}
	goto tr140;
case 269:
	switch( (*( sm->p)) ) {
		case 69: goto tr305;
		case 101: goto tr305;
	}
	goto tr140;
case 270:
	switch( (*( sm->p)) ) {
		case 82: goto tr306;
		case 114: goto tr306;
	}
	goto tr140;
case 271:
	switch( (*( sm->p)) ) {
		case 62: goto tr307;
		case 83: goto tr308;
		case 115: goto tr308;
	}
	goto tr140;
case 272:
	if ( (*( sm->p)) == 62 )
		goto tr307;
	goto tr140;
case 273:
	switch( (*( sm->p)) ) {
		case 82: goto tr309;
		case 114: goto tr309;
	}
	goto tr140;
case 274:
	switch( (*( sm->p)) ) {
		case 79: goto tr310;
		case 111: goto tr310;
	}
	goto tr140;
case 275:
	switch( (*( sm->p)) ) {
		case 78: goto tr311;
		case 110: goto tr311;
	}
	goto tr140;
case 276:
	switch( (*( sm->p)) ) {
		case 71: goto tr312;
		case 103: goto tr312;
	}
	goto tr140;
case 277:
	if ( (*( sm->p)) == 62 )
		goto tr269;
	goto tr140;
case 278:
	switch( (*( sm->p)) ) {
		case 78: goto tr313;
		case 110: goto tr313;
	}
	goto tr140;
case 279:
	if ( (*( sm->p)) == 62 )
		goto tr314;
	goto tr140;
case 280:
	if ( (*( sm->p)) == 62 )
		goto tr315;
	goto tr140;
case 281:
	if ( (*( sm->p)) == 116 )
		goto tr316;
	goto tr140;
case 282:
	if ( (*( sm->p)) == 116 )
		goto tr317;
	goto tr140;
case 283:
	if ( (*( sm->p)) == 112 )
		goto tr318;
	goto tr140;
case 284:
	switch( (*( sm->p)) ) {
		case 58: goto tr319;
		case 115: goto tr320;
	}
	goto tr140;
case 285:
	if ( (*( sm->p)) == 47 )
		goto tr321;
	goto tr140;
case 286:
	if ( (*( sm->p)) == 47 )
		goto tr322;
	goto tr140;
case 287:
	if ( (*( sm->p)) < -32 ) {
		if ( -62 <= (*( sm->p)) && (*( sm->p)) <= -33 )
			goto tr323;
	} else if ( (*( sm->p)) > -17 ) {
		if ( (*( sm->p)) > -12 ) {
			if ( 33 <= (*( sm->p)) && (*( sm->p)) <= 126 )
				goto tr326;
		} else if ( (*( sm->p)) >= -16 )
			goto tr325;
	} else
		goto tr324;
	goto tr140;
case 288:
	if ( (*( sm->p)) <= -65 )
		goto tr326;
	goto tr140;
case 289:
	if ( (*( sm->p)) == 62 )
		goto tr327;
	if ( (*( sm->p)) < -32 ) {
		if ( -62 <= (*( sm->p)) && (*( sm->p)) <= -33 )
			goto tr323;
	} else if ( (*( sm->p)) > -17 ) {
		if ( (*( sm->p)) > -12 ) {
			if ( 33 <= (*( sm->p)) && (*( sm->p)) <= 126 )
				goto tr326;
		} else if ( (*( sm->p)) >= -16 )
			goto tr325;
	} else
		goto tr324;
	goto tr140;
case 290:
	if ( (*( sm->p)) <= -65 )
		goto tr323;
	goto tr140;
case 291:
	if ( (*( sm->p)) <= -65 )
		goto tr324;
	goto tr140;
case 292:
	if ( (*( sm->p)) == 58 )
		goto tr319;
	goto tr140;
case 731:
	if ( (*( sm->p)) < -32 ) {
		if ( -62 <= (*( sm->p)) && (*( sm->p)) <= -33 )
			goto tr845;
	} else if ( (*( sm->p)) > -17 ) {
		if ( (*( sm->p)) > -12 ) {
			if ( 33 <= (*( sm->p)) && (*( sm->p)) <= 126 )
				goto tr848;
		} else if ( (*( sm->p)) >= -16 )
			goto tr847;
	} else
		goto tr846;
	goto tr822;
case 293:
	if ( (*( sm->p)) <= -65 )
		goto tr328;
	goto tr133;
case 732:
	if ( (*( sm->p)) < -32 ) {
		if ( -62 <= (*( sm->p)) && (*( sm->p)) <= -33 )
			goto tr329;
	} else if ( (*( sm->p)) > -17 ) {
		if ( (*( sm->p)) > -12 ) {
			if ( 33 <= (*( sm->p)) && (*( sm->p)) <= 126 )
				goto tr328;
		} else if ( (*( sm->p)) >= -16 )
			goto tr850;
	} else
		goto tr330;
	goto tr849;
case 294:
	if ( (*( sm->p)) <= -65 )
		goto tr329;
	goto tr133;
case 295:
	if ( (*( sm->p)) <= -65 )
		goto tr330;
	goto tr133;
case 733:
	if ( (*( sm->p)) == 64 )
		goto tr852;
	if ( (*( sm->p)) < -32 ) {
		if ( -62 <= (*( sm->p)) && (*( sm->p)) <= -33 )
			goto tr329;
	} else if ( (*( sm->p)) > -17 ) {
		if ( (*( sm->p)) > -12 ) {
			if ( 33 <= (*( sm->p)) && (*( sm->p)) <= 126 )
				goto tr328;
		} else if ( (*( sm->p)) >= -16 )
			goto tr850;
	} else
		goto tr330;
	goto tr851;
case 734:
	switch( (*( sm->p)) ) {
		case 76: goto tr853;
		case 80: goto tr854;
		case 82: goto tr855;
		case 91: goto tr173;
		case 108: goto tr853;
		case 112: goto tr854;
		case 114: goto tr855;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr172;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr172;
	} else
		goto tr172;
	goto tr822;
case 296:
	switch( (*( sm->p)) ) {
		case 73: goto tr331;
		case 91: goto tr173;
		case 105: goto tr331;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr172;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr172;
	} else
		goto tr172;
	goto tr140;
case 297:
	switch( (*( sm->p)) ) {
		case 65: goto tr332;
		case 91: goto tr173;
		case 97: goto tr332;
	}
	if ( (*( sm->p)) < 66 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr172;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 98 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr172;
	} else
		goto tr172;
	goto tr140;
case 298:
	switch( (*( sm->p)) ) {
		case 83: goto tr333;
		case 91: goto tr173;
		case 115: goto tr333;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr172;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr172;
	} else
		goto tr172;
	goto tr140;
case 299:
	switch( (*( sm->p)) ) {
		case 32: goto tr334;
		case 91: goto tr173;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr172;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr172;
	} else
		goto tr172;
	goto tr140;
case 300:
	if ( (*( sm->p)) == 35 )
		goto tr335;
	goto tr140;
case 301:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr336;
	goto tr140;
case 735:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr857;
	goto tr856;
case 302:
	switch( (*( sm->p)) ) {
		case 80: goto tr337;
		case 91: goto tr173;
		case 112: goto tr337;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr172;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr172;
	} else
		goto tr172;
	goto tr140;
case 303:
	switch( (*( sm->p)) ) {
		case 69: goto tr338;
		case 91: goto tr173;
		case 101: goto tr338;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr172;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr172;
	} else
		goto tr172;
	goto tr140;
case 304:
	switch( (*( sm->p)) ) {
		case 65: goto tr339;
		case 91: goto tr173;
		case 97: goto tr339;
	}
	if ( (*( sm->p)) < 66 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr172;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 98 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr172;
	} else
		goto tr172;
	goto tr140;
case 305:
	switch( (*( sm->p)) ) {
		case 76: goto tr340;
		case 91: goto tr173;
		case 108: goto tr340;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr172;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr172;
	} else
		goto tr172;
	goto tr140;
case 306:
	switch( (*( sm->p)) ) {
		case 32: goto tr341;
		case 91: goto tr173;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr172;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr172;
	} else
		goto tr172;
	goto tr140;
case 307:
	if ( (*( sm->p)) == 35 )
		goto tr342;
	goto tr140;
case 308:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr343;
	goto tr140;
case 736:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr859;
	goto tr858;
case 309:
	switch( (*( sm->p)) ) {
		case 84: goto tr344;
		case 91: goto tr173;
		case 116: goto tr344;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr172;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr172;
	} else
		goto tr172;
	goto tr140;
case 310:
	switch( (*( sm->p)) ) {
		case 73: goto tr345;
		case 83: goto tr346;
		case 91: goto tr173;
		case 105: goto tr345;
		case 115: goto tr346;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr172;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr172;
	} else
		goto tr172;
	goto tr140;
case 311:
	switch( (*( sm->p)) ) {
		case 83: goto tr347;
		case 91: goto tr173;
		case 115: goto tr347;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr172;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr172;
	} else
		goto tr172;
	goto tr140;
case 312:
	switch( (*( sm->p)) ) {
		case 84: goto tr348;
		case 91: goto tr173;
		case 116: goto tr348;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr172;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr172;
	} else
		goto tr172;
	goto tr140;
case 313:
	switch( (*( sm->p)) ) {
		case 32: goto tr349;
		case 91: goto tr173;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr172;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr172;
	} else
		goto tr172;
	goto tr140;
case 314:
	if ( (*( sm->p)) == 35 )
		goto tr350;
	goto tr140;
case 315:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr351;
	goto tr140;
case 737:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr861;
	goto tr860;
case 316:
	switch( (*( sm->p)) ) {
		case 84: goto tr352;
		case 91: goto tr173;
		case 116: goto tr352;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr172;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr172;
	} else
		goto tr172;
	goto tr140;
case 317:
	switch( (*( sm->p)) ) {
		case 65: goto tr353;
		case 91: goto tr173;
		case 97: goto tr353;
	}
	if ( (*( sm->p)) < 66 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr172;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 98 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr172;
	} else
		goto tr172;
	goto tr140;
case 318:
	switch( (*( sm->p)) ) {
		case 84: goto tr354;
		case 91: goto tr173;
		case 116: goto tr354;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr172;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr172;
	} else
		goto tr172;
	goto tr140;
case 319:
	switch( (*( sm->p)) ) {
		case 73: goto tr355;
		case 91: goto tr173;
		case 105: goto tr355;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr172;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr172;
	} else
		goto tr172;
	goto tr140;
case 320:
	switch( (*( sm->p)) ) {
		case 79: goto tr356;
		case 91: goto tr173;
		case 111: goto tr356;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr172;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr172;
	} else
		goto tr172;
	goto tr140;
case 321:
	switch( (*( sm->p)) ) {
		case 78: goto tr357;
		case 91: goto tr173;
		case 110: goto tr357;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr172;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr172;
	} else
		goto tr172;
	goto tr140;
case 322:
	switch( (*( sm->p)) ) {
		case 32: goto tr358;
		case 91: goto tr173;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr172;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr172;
	} else
		goto tr172;
	goto tr140;
case 323:
	if ( (*( sm->p)) == 35 )
		goto tr359;
	goto tr140;
case 324:
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr360;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr360;
	} else
		goto tr360;
	goto tr140;
case 738:
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr863;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr863;
	} else
		goto tr863;
	goto tr862;
case 739:
	switch( (*( sm->p)) ) {
		case 65: goto tr864;
		case 85: goto tr865;
		case 91: goto tr173;
		case 97: goto tr864;
		case 117: goto tr865;
	}
	if ( (*( sm->p)) < 66 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr172;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 98 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr172;
	} else
		goto tr172;
	goto tr822;
case 325:
	switch( (*( sm->p)) ) {
		case 78: goto tr361;
		case 91: goto tr173;
		case 110: goto tr361;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr172;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr172;
	} else
		goto tr172;
	goto tr140;
case 326:
	switch( (*( sm->p)) ) {
		case 32: goto tr362;
		case 91: goto tr173;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr172;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr172;
	} else
		goto tr172;
	goto tr140;
case 327:
	if ( (*( sm->p)) == 35 )
		goto tr363;
	goto tr140;
case 328:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr364;
	goto tr140;
case 740:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr867;
	goto tr866;
case 329:
	switch( (*( sm->p)) ) {
		case 82: goto tr365;
		case 91: goto tr173;
		case 114: goto tr365;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr172;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr172;
	} else
		goto tr172;
	goto tr140;
case 330:
	switch( (*( sm->p)) ) {
		case 32: goto tr366;
		case 91: goto tr173;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr172;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr172;
	} else
		goto tr172;
	goto tr140;
case 331:
	if ( (*( sm->p)) == 35 )
		goto tr367;
	goto tr140;
case 332:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr368;
	goto tr140;
case 741:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr869;
	goto tr868;
case 742:
	switch( (*( sm->p)) ) {
		case 79: goto tr870;
		case 91: goto tr173;
		case 111: goto tr870;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr172;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr172;
	} else
		goto tr172;
	goto tr822;
case 333:
	switch( (*( sm->p)) ) {
		case 77: goto tr369;
		case 91: goto tr173;
		case 109: goto tr369;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr172;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr172;
	} else
		goto tr172;
	goto tr140;
case 334:
	switch( (*( sm->p)) ) {
		case 77: goto tr370;
		case 91: goto tr173;
		case 109: goto tr370;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr172;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr172;
	} else
		goto tr172;
	goto tr140;
case 335:
	switch( (*( sm->p)) ) {
		case 69: goto tr371;
		case 73: goto tr372;
		case 91: goto tr173;
		case 101: goto tr371;
		case 105: goto tr372;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr172;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr172;
	} else
		goto tr172;
	goto tr140;
case 336:
	switch( (*( sm->p)) ) {
		case 78: goto tr373;
		case 91: goto tr173;
		case 110: goto tr373;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr172;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr172;
	} else
		goto tr172;
	goto tr140;
case 337:
	switch( (*( sm->p)) ) {
		case 84: goto tr374;
		case 91: goto tr173;
		case 116: goto tr374;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr172;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr172;
	} else
		goto tr172;
	goto tr140;
case 338:
	switch( (*( sm->p)) ) {
		case 32: goto tr375;
		case 91: goto tr173;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr172;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr172;
	} else
		goto tr172;
	goto tr140;
case 339:
	if ( (*( sm->p)) == 35 )
		goto tr376;
	goto tr140;
case 340:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr377;
	goto tr140;
case 743:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr872;
	goto tr871;
case 341:
	switch( (*( sm->p)) ) {
		case 84: goto tr378;
		case 91: goto tr173;
		case 116: goto tr378;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr172;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr172;
	} else
		goto tr172;
	goto tr140;
case 342:
	switch( (*( sm->p)) ) {
		case 32: goto tr379;
		case 91: goto tr173;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr172;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr172;
	} else
		goto tr172;
	goto tr140;
case 343:
	if ( (*( sm->p)) == 35 )
		goto tr380;
	goto tr140;
case 344:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr381;
	goto tr140;
case 744:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr874;
	goto tr873;
case 745:
	switch( (*( sm->p)) ) {
		case 69: goto tr875;
		case 77: goto tr876;
		case 91: goto tr173;
		case 101: goto tr875;
		case 109: goto tr876;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr172;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr172;
	} else
		goto tr172;
	goto tr822;
case 345:
	switch( (*( sm->p)) ) {
		case 86: goto tr382;
		case 91: goto tr173;
		case 118: goto tr382;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr172;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr172;
	} else
		goto tr172;
	goto tr140;
case 346:
	switch( (*( sm->p)) ) {
		case 73: goto tr383;
		case 91: goto tr173;
		case 105: goto tr383;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr172;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr172;
	} else
		goto tr172;
	goto tr140;
case 347:
	switch( (*( sm->p)) ) {
		case 65: goto tr384;
		case 91: goto tr173;
		case 97: goto tr384;
	}
	if ( (*( sm->p)) < 66 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr172;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 98 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr172;
	} else
		goto tr172;
	goto tr140;
case 348:
	switch( (*( sm->p)) ) {
		case 78: goto tr385;
		case 91: goto tr173;
		case 110: goto tr385;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr172;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr172;
	} else
		goto tr172;
	goto tr140;
case 349:
	switch( (*( sm->p)) ) {
		case 84: goto tr386;
		case 91: goto tr173;
		case 116: goto tr386;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr172;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr172;
	} else
		goto tr172;
	goto tr140;
case 350:
	switch( (*( sm->p)) ) {
		case 65: goto tr387;
		case 91: goto tr173;
		case 97: goto tr387;
	}
	if ( (*( sm->p)) < 66 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr172;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 98 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr172;
	} else
		goto tr172;
	goto tr140;
case 351:
	switch( (*( sm->p)) ) {
		case 82: goto tr388;
		case 91: goto tr173;
		case 114: goto tr388;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr172;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr172;
	} else
		goto tr172;
	goto tr140;
case 352:
	switch( (*( sm->p)) ) {
		case 84: goto tr389;
		case 91: goto tr173;
		case 116: goto tr389;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr172;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr172;
	} else
		goto tr172;
	goto tr140;
case 353:
	switch( (*( sm->p)) ) {
		case 32: goto tr390;
		case 91: goto tr173;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr172;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr172;
	} else
		goto tr172;
	goto tr140;
case 354:
	if ( (*( sm->p)) == 35 )
		goto tr391;
	goto tr140;
case 355:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr392;
	goto tr140;
case 746:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr878;
	goto tr877;
case 356:
	switch( (*( sm->p)) ) {
		case 65: goto tr393;
		case 91: goto tr173;
		case 97: goto tr393;
	}
	if ( (*( sm->p)) < 66 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr172;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 98 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr172;
	} else
		goto tr172;
	goto tr140;
case 357:
	switch( (*( sm->p)) ) {
		case 73: goto tr394;
		case 91: goto tr173;
		case 105: goto tr394;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr172;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr172;
	} else
		goto tr172;
	goto tr140;
case 358:
	switch( (*( sm->p)) ) {
		case 76: goto tr395;
		case 91: goto tr173;
		case 108: goto tr395;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr172;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr172;
	} else
		goto tr172;
	goto tr140;
case 359:
	switch( (*( sm->p)) ) {
		case 32: goto tr396;
		case 91: goto tr173;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr172;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr172;
	} else
		goto tr172;
	goto tr140;
case 360:
	if ( (*( sm->p)) == 35 )
		goto tr397;
	goto tr140;
case 361:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr398;
	goto tr140;
case 747:
	if ( (*( sm->p)) == 47 )
		goto tr880;
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr881;
	goto tr879;
case 362:
	switch( (*( sm->p)) ) {
		case 45: goto tr400;
		case 61: goto tr400;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr400;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr400;
	} else
		goto tr400;
	goto tr399;
case 748:
	switch( (*( sm->p)) ) {
		case 45: goto tr883;
		case 61: goto tr883;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr883;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr883;
	} else
		goto tr883;
	goto tr882;
case 749:
	switch( (*( sm->p)) ) {
		case 65: goto tr884;
		case 69: goto tr885;
		case 76: goto tr886;
		case 79: goto tr887;
		case 91: goto tr173;
		case 97: goto tr884;
		case 101: goto tr885;
		case 108: goto tr886;
		case 111: goto tr887;
	}
	if ( (*( sm->p)) < 66 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr172;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 98 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr172;
	} else
		goto tr172;
	goto tr822;
case 363:
	switch( (*( sm->p)) ) {
		case 86: goto tr401;
		case 91: goto tr173;
		case 118: goto tr401;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr172;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr172;
	} else
		goto tr172;
	goto tr140;
case 364:
	switch( (*( sm->p)) ) {
		case 71: goto tr402;
		case 91: goto tr173;
		case 103: goto tr402;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr172;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr172;
	} else
		goto tr172;
	goto tr140;
case 365:
	switch( (*( sm->p)) ) {
		case 82: goto tr403;
		case 91: goto tr173;
		case 114: goto tr403;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr172;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr172;
	} else
		goto tr172;
	goto tr140;
case 366:
	switch( (*( sm->p)) ) {
		case 79: goto tr404;
		case 91: goto tr173;
		case 111: goto tr404;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr172;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr172;
	} else
		goto tr172;
	goto tr140;
case 367:
	switch( (*( sm->p)) ) {
		case 85: goto tr405;
		case 91: goto tr173;
		case 117: goto tr405;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr172;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr172;
	} else
		goto tr172;
	goto tr140;
case 368:
	switch( (*( sm->p)) ) {
		case 80: goto tr406;
		case 91: goto tr173;
		case 112: goto tr406;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr172;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr172;
	} else
		goto tr172;
	goto tr140;
case 369:
	switch( (*( sm->p)) ) {
		case 32: goto tr407;
		case 91: goto tr173;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr172;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr172;
	} else
		goto tr172;
	goto tr140;
case 370:
	if ( (*( sm->p)) == 35 )
		goto tr408;
	goto tr140;
case 371:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr409;
	goto tr140;
case 750:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr889;
	goto tr888;
case 372:
	switch( (*( sm->p)) ) {
		case 69: goto tr410;
		case 91: goto tr173;
		case 101: goto tr410;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr172;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr172;
	} else
		goto tr172;
	goto tr140;
case 373:
	switch( (*( sm->p)) ) {
		case 68: goto tr411;
		case 91: goto tr173;
		case 100: goto tr411;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr172;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr172;
	} else
		goto tr172;
	goto tr140;
case 374:
	switch( (*( sm->p)) ) {
		case 66: goto tr412;
		case 91: goto tr173;
		case 98: goto tr412;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr172;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr172;
	} else
		goto tr172;
	goto tr140;
case 375:
	switch( (*( sm->p)) ) {
		case 65: goto tr413;
		case 91: goto tr173;
		case 97: goto tr413;
	}
	if ( (*( sm->p)) < 66 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr172;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 98 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr172;
	} else
		goto tr172;
	goto tr140;
case 376:
	switch( (*( sm->p)) ) {
		case 67: goto tr414;
		case 91: goto tr173;
		case 99: goto tr414;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr172;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr172;
	} else
		goto tr172;
	goto tr140;
case 377:
	switch( (*( sm->p)) ) {
		case 75: goto tr415;
		case 91: goto tr173;
		case 107: goto tr415;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr172;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr172;
	} else
		goto tr172;
	goto tr140;
case 378:
	switch( (*( sm->p)) ) {
		case 32: goto tr416;
		case 91: goto tr173;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr172;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr172;
	} else
		goto tr172;
	goto tr140;
case 379:
	if ( (*( sm->p)) == 35 )
		goto tr417;
	goto tr140;
case 380:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr418;
	goto tr140;
case 751:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr891;
	goto tr890;
case 381:
	switch( (*( sm->p)) ) {
		case 65: goto tr419;
		case 91: goto tr173;
		case 97: goto tr419;
	}
	if ( (*( sm->p)) < 66 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr172;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 98 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr172;
	} else
		goto tr172;
	goto tr140;
case 382:
	switch( (*( sm->p)) ) {
		case 71: goto tr420;
		case 91: goto tr173;
		case 103: goto tr420;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr172;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr172;
	} else
		goto tr172;
	goto tr140;
case 383:
	switch( (*( sm->p)) ) {
		case 32: goto tr421;
		case 91: goto tr173;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr172;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr172;
	} else
		goto tr172;
	goto tr140;
case 384:
	if ( (*( sm->p)) == 35 )
		goto tr422;
	goto tr140;
case 385:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr423;
	goto tr140;
case 752:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr893;
	goto tr892;
case 386:
	switch( (*( sm->p)) ) {
		case 82: goto tr424;
		case 91: goto tr173;
		case 114: goto tr424;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr172;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr172;
	} else
		goto tr172;
	goto tr140;
case 387:
	switch( (*( sm->p)) ) {
		case 85: goto tr425;
		case 91: goto tr173;
		case 117: goto tr425;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr172;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr172;
	} else
		goto tr172;
	goto tr140;
case 388:
	switch( (*( sm->p)) ) {
		case 77: goto tr426;
		case 91: goto tr173;
		case 109: goto tr426;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr172;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr172;
	} else
		goto tr172;
	goto tr140;
case 389:
	switch( (*( sm->p)) ) {
		case 32: goto tr427;
		case 91: goto tr173;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr172;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr172;
	} else
		goto tr172;
	goto tr140;
case 390:
	if ( (*( sm->p)) == 35 )
		goto tr428;
	goto tr140;
case 391:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr429;
	goto tr140;
case 753:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr895;
	goto tr894;
case 754:
	switch( (*( sm->p)) ) {
		case 69: goto tr896;
		case 91: goto tr173;
		case 101: goto tr896;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr172;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr172;
	} else
		goto tr172;
	goto tr822;
case 392:
	switch( (*( sm->p)) ) {
		case 76: goto tr430;
		case 91: goto tr173;
		case 108: goto tr430;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr172;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr172;
	} else
		goto tr172;
	goto tr140;
case 393:
	switch( (*( sm->p)) ) {
		case 66: goto tr431;
		case 91: goto tr173;
		case 98: goto tr431;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr172;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr172;
	} else
		goto tr172;
	goto tr140;
case 394:
	switch( (*( sm->p)) ) {
		case 79: goto tr432;
		case 91: goto tr173;
		case 111: goto tr432;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr172;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr172;
	} else
		goto tr172;
	goto tr140;
case 395:
	switch( (*( sm->p)) ) {
		case 79: goto tr433;
		case 91: goto tr173;
		case 111: goto tr433;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr172;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr172;
	} else
		goto tr172;
	goto tr140;
case 396:
	switch( (*( sm->p)) ) {
		case 82: goto tr434;
		case 91: goto tr173;
		case 114: goto tr434;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr172;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr172;
	} else
		goto tr172;
	goto tr140;
case 397:
	switch( (*( sm->p)) ) {
		case 85: goto tr435;
		case 91: goto tr173;
		case 117: goto tr435;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr172;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr172;
	} else
		goto tr172;
	goto tr140;
case 398:
	switch( (*( sm->p)) ) {
		case 32: goto tr436;
		case 91: goto tr173;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr172;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr172;
	} else
		goto tr172;
	goto tr140;
case 399:
	if ( (*( sm->p)) == 35 )
		goto tr437;
	goto tr140;
case 400:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr438;
	goto tr140;
case 755:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr898;
	goto tr897;
case 756:
	switch( (*( sm->p)) ) {
		case 77: goto tr899;
		case 83: goto tr900;
		case 91: goto tr173;
		case 109: goto tr899;
		case 115: goto tr900;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr172;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr172;
	} else
		goto tr172;
	goto tr822;
case 401:
	switch( (*( sm->p)) ) {
		case 80: goto tr439;
		case 91: goto tr173;
		case 112: goto tr439;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr172;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr172;
	} else
		goto tr172;
	goto tr140;
case 402:
	switch( (*( sm->p)) ) {
		case 76: goto tr440;
		case 91: goto tr173;
		case 108: goto tr440;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr172;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr172;
	} else
		goto tr172;
	goto tr140;
case 403:
	switch( (*( sm->p)) ) {
		case 73: goto tr441;
		case 91: goto tr173;
		case 105: goto tr441;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr172;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr172;
	} else
		goto tr172;
	goto tr140;
case 404:
	switch( (*( sm->p)) ) {
		case 67: goto tr442;
		case 91: goto tr173;
		case 99: goto tr442;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr172;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr172;
	} else
		goto tr172;
	goto tr140;
case 405:
	switch( (*( sm->p)) ) {
		case 65: goto tr443;
		case 91: goto tr173;
		case 97: goto tr443;
	}
	if ( (*( sm->p)) < 66 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr172;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 98 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr172;
	} else
		goto tr172;
	goto tr140;
case 406:
	switch( (*( sm->p)) ) {
		case 84: goto tr444;
		case 91: goto tr173;
		case 116: goto tr444;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr172;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr172;
	} else
		goto tr172;
	goto tr140;
case 407:
	switch( (*( sm->p)) ) {
		case 73: goto tr445;
		case 91: goto tr173;
		case 105: goto tr445;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr172;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr172;
	} else
		goto tr172;
	goto tr140;
case 408:
	switch( (*( sm->p)) ) {
		case 79: goto tr446;
		case 91: goto tr173;
		case 111: goto tr446;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr172;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr172;
	} else
		goto tr172;
	goto tr140;
case 409:
	switch( (*( sm->p)) ) {
		case 78: goto tr447;
		case 91: goto tr173;
		case 110: goto tr447;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr172;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr172;
	} else
		goto tr172;
	goto tr140;
case 410:
	switch( (*( sm->p)) ) {
		case 32: goto tr448;
		case 91: goto tr173;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr172;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr172;
	} else
		goto tr172;
	goto tr140;
case 411:
	if ( (*( sm->p)) == 35 )
		goto tr449;
	goto tr140;
case 412:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr450;
	goto tr140;
case 757:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr902;
	goto tr901;
case 413:
	switch( (*( sm->p)) ) {
		case 83: goto tr451;
		case 91: goto tr173;
		case 115: goto tr451;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr172;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr172;
	} else
		goto tr172;
	goto tr140;
case 414:
	switch( (*( sm->p)) ) {
		case 85: goto tr452;
		case 91: goto tr173;
		case 117: goto tr452;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr172;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr172;
	} else
		goto tr172;
	goto tr140;
case 415:
	switch( (*( sm->p)) ) {
		case 69: goto tr453;
		case 91: goto tr173;
		case 101: goto tr453;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr172;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr172;
	} else
		goto tr172;
	goto tr140;
case 416:
	switch( (*( sm->p)) ) {
		case 32: goto tr454;
		case 91: goto tr173;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr172;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr172;
	} else
		goto tr172;
	goto tr140;
case 417:
	if ( (*( sm->p)) == 35 )
		goto tr455;
	goto tr140;
case 418:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr456;
	goto tr140;
case 758:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr904;
	goto tr903;
case 759:
	switch( (*( sm->p)) ) {
		case 79: goto tr905;
		case 91: goto tr173;
		case 111: goto tr905;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr172;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr172;
	} else
		goto tr172;
	goto tr822;
case 419:
	switch( (*( sm->p)) ) {
		case 68: goto tr457;
		case 91: goto tr173;
		case 100: goto tr457;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr172;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr172;
	} else
		goto tr172;
	goto tr140;
case 420:
	switch( (*( sm->p)) ) {
		case 32: goto tr458;
		case 82: goto tr459;
		case 91: goto tr173;
		case 114: goto tr459;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr172;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr172;
	} else
		goto tr172;
	goto tr140;
case 421:
	switch( (*( sm->p)) ) {
		case 65: goto tr460;
		case 97: goto tr460;
	}
	goto tr140;
case 422:
	switch( (*( sm->p)) ) {
		case 67: goto tr461;
		case 99: goto tr461;
	}
	goto tr140;
case 423:
	switch( (*( sm->p)) ) {
		case 84: goto tr462;
		case 116: goto tr462;
	}
	goto tr140;
case 424:
	switch( (*( sm->p)) ) {
		case 73: goto tr463;
		case 105: goto tr463;
	}
	goto tr140;
case 425:
	switch( (*( sm->p)) ) {
		case 79: goto tr464;
		case 111: goto tr464;
	}
	goto tr140;
case 426:
	switch( (*( sm->p)) ) {
		case 78: goto tr465;
		case 110: goto tr465;
	}
	goto tr140;
case 427:
	if ( (*( sm->p)) == 32 )
		goto tr466;
	goto tr140;
case 428:
	if ( (*( sm->p)) == 35 )
		goto tr467;
	goto tr140;
case 429:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr468;
	goto tr140;
case 760:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr907;
	goto tr906;
case 430:
	switch( (*( sm->p)) ) {
		case 69: goto tr469;
		case 91: goto tr173;
		case 101: goto tr469;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr172;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr172;
	} else
		goto tr172;
	goto tr140;
case 431:
	switch( (*( sm->p)) ) {
		case 80: goto tr470;
		case 91: goto tr173;
		case 112: goto tr470;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr172;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr172;
	} else
		goto tr172;
	goto tr140;
case 432:
	switch( (*( sm->p)) ) {
		case 79: goto tr471;
		case 91: goto tr173;
		case 111: goto tr471;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr172;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr172;
	} else
		goto tr172;
	goto tr140;
case 433:
	switch( (*( sm->p)) ) {
		case 82: goto tr472;
		case 91: goto tr173;
		case 114: goto tr472;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr172;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr172;
	} else
		goto tr172;
	goto tr140;
case 434:
	switch( (*( sm->p)) ) {
		case 84: goto tr473;
		case 91: goto tr173;
		case 116: goto tr473;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr172;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr172;
	} else
		goto tr172;
	goto tr140;
case 435:
	switch( (*( sm->p)) ) {
		case 32: goto tr474;
		case 91: goto tr173;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr172;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr172;
	} else
		goto tr172;
	goto tr140;
case 436:
	if ( (*( sm->p)) == 35 )
		goto tr475;
	goto tr140;
case 437:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr476;
	goto tr140;
case 761:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr909;
	goto tr908;
case 762:
	switch( (*( sm->p)) ) {
		case 73: goto tr910;
		case 79: goto tr911;
		case 91: goto tr173;
		case 105: goto tr910;
		case 111: goto tr911;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr172;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr172;
	} else
		goto tr172;
	goto tr822;
case 438:
	switch( (*( sm->p)) ) {
		case 74: goto tr477;
		case 91: goto tr173;
		case 106: goto tr477;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr172;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr172;
	} else
		goto tr172;
	goto tr140;
case 439:
	switch( (*( sm->p)) ) {
		case 73: goto tr478;
		case 91: goto tr173;
		case 105: goto tr478;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr172;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr172;
	} else
		goto tr172;
	goto tr140;
case 440:
	switch( (*( sm->p)) ) {
		case 69: goto tr479;
		case 91: goto tr173;
		case 101: goto tr479;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr172;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr172;
	} else
		goto tr172;
	goto tr140;
case 441:
	switch( (*( sm->p)) ) {
		case 32: goto tr480;
		case 91: goto tr173;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr172;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr172;
	} else
		goto tr172;
	goto tr140;
case 442:
	if ( (*( sm->p)) == 35 )
		goto tr481;
	goto tr140;
case 443:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr482;
	goto tr140;
case 763:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr913;
	goto tr912;
case 444:
	switch( (*( sm->p)) ) {
		case 84: goto tr483;
		case 91: goto tr173;
		case 116: goto tr483;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr172;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr172;
	} else
		goto tr172;
	goto tr140;
case 445:
	switch( (*( sm->p)) ) {
		case 69: goto tr484;
		case 91: goto tr173;
		case 101: goto tr484;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr172;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr172;
	} else
		goto tr172;
	goto tr140;
case 446:
	switch( (*( sm->p)) ) {
		case 32: goto tr485;
		case 91: goto tr173;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr172;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr172;
	} else
		goto tr172;
	goto tr140;
case 447:
	if ( (*( sm->p)) == 35 )
		goto tr486;
	goto tr140;
case 448:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr487;
	goto tr140;
case 764:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr915;
	goto tr914;
case 765:
	switch( (*( sm->p)) ) {
		case 65: goto tr916;
		case 73: goto tr917;
		case 79: goto tr918;
		case 85: goto tr919;
		case 91: goto tr173;
		case 97: goto tr916;
		case 105: goto tr917;
		case 111: goto tr918;
		case 117: goto tr919;
	}
	if ( (*( sm->p)) < 66 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr172;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 98 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr172;
	} else
		goto tr172;
	goto tr822;
case 449:
	switch( (*( sm->p)) ) {
		case 87: goto tr488;
		case 91: goto tr173;
		case 119: goto tr488;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr172;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr172;
	} else
		goto tr172;
	goto tr140;
case 450:
	switch( (*( sm->p)) ) {
		case 79: goto tr489;
		case 91: goto tr173;
		case 111: goto tr489;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr172;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr172;
	} else
		goto tr172;
	goto tr140;
case 451:
	switch( (*( sm->p)) ) {
		case 79: goto tr490;
		case 91: goto tr173;
		case 111: goto tr490;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr172;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr172;
	} else
		goto tr172;
	goto tr140;
case 452:
	switch( (*( sm->p)) ) {
		case 32: goto tr491;
		case 91: goto tr173;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr172;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr172;
	} else
		goto tr172;
	goto tr140;
case 453:
	if ( (*( sm->p)) == 35 )
		goto tr492;
	goto tr140;
case 454:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr493;
	goto tr140;
case 766:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr921;
	goto tr920;
case 455:
	switch( (*( sm->p)) ) {
		case 88: goto tr494;
		case 91: goto tr173;
		case 120: goto tr494;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr172;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr172;
	} else
		goto tr172;
	goto tr140;
case 456:
	switch( (*( sm->p)) ) {
		case 73: goto tr495;
		case 91: goto tr173;
		case 105: goto tr495;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr172;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr172;
	} else
		goto tr172;
	goto tr140;
case 457:
	switch( (*( sm->p)) ) {
		case 86: goto tr496;
		case 91: goto tr173;
		case 118: goto tr496;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr172;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr172;
	} else
		goto tr172;
	goto tr140;
case 458:
	switch( (*( sm->p)) ) {
		case 32: goto tr497;
		case 91: goto tr173;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr172;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr172;
	} else
		goto tr172;
	goto tr140;
case 459:
	if ( (*( sm->p)) == 35 )
		goto tr498;
	goto tr140;
case 460:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr499;
	goto tr140;
case 767:
	if ( (*( sm->p)) == 47 )
		goto tr923;
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr924;
	goto tr922;
case 461:
	switch( (*( sm->p)) ) {
		case 80: goto tr501;
		case 112: goto tr501;
	}
	goto tr500;
case 462:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr502;
	goto tr500;
case 768:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr926;
	goto tr925;
case 463:
	switch( (*( sm->p)) ) {
		case 79: goto tr503;
		case 83: goto tr504;
		case 91: goto tr173;
		case 111: goto tr503;
		case 115: goto tr504;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr172;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr172;
	} else
		goto tr172;
	goto tr140;
case 464:
	switch( (*( sm->p)) ) {
		case 76: goto tr505;
		case 91: goto tr173;
		case 108: goto tr505;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr172;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr172;
	} else
		goto tr172;
	goto tr140;
case 465:
	switch( (*( sm->p)) ) {
		case 32: goto tr506;
		case 91: goto tr173;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr172;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr172;
	} else
		goto tr172;
	goto tr140;
case 466:
	if ( (*( sm->p)) == 35 )
		goto tr507;
	goto tr140;
case 467:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr508;
	goto tr140;
case 769:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr928;
	goto tr927;
case 468:
	switch( (*( sm->p)) ) {
		case 84: goto tr509;
		case 91: goto tr173;
		case 116: goto tr509;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr172;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr172;
	} else
		goto tr172;
	goto tr140;
case 469:
	switch( (*( sm->p)) ) {
		case 32: goto tr510;
		case 91: goto tr173;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr172;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr172;
	} else
		goto tr172;
	goto tr140;
case 470:
	if ( (*( sm->p)) == 35 )
		goto tr511;
	goto tr140;
case 471:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr512;
	goto tr140;
case 770:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr930;
	goto tr929;
case 472:
	switch( (*( sm->p)) ) {
		case 76: goto tr513;
		case 91: goto tr173;
		case 108: goto tr513;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr172;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr172;
	} else
		goto tr172;
	goto tr140;
case 473:
	switch( (*( sm->p)) ) {
		case 76: goto tr514;
		case 91: goto tr173;
		case 108: goto tr514;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr172;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr172;
	} else
		goto tr172;
	goto tr140;
case 474:
	switch( (*( sm->p)) ) {
		case 32: goto tr515;
		case 91: goto tr173;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr172;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr172;
	} else
		goto tr172;
	goto tr140;
case 475:
	if ( (*( sm->p)) == 35 )
		goto tr516;
	goto tr140;
case 476:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr517;
	goto tr140;
case 771:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr932;
	goto tr931;
case 772:
	switch( (*( sm->p)) ) {
		case 65: goto tr933;
		case 69: goto tr934;
		case 91: goto tr173;
		case 97: goto tr933;
		case 101: goto tr934;
	}
	if ( (*( sm->p)) < 66 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr172;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 98 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr172;
	} else
		goto tr172;
	goto tr822;
case 477:
	switch( (*( sm->p)) ) {
		case 78: goto tr518;
		case 91: goto tr173;
		case 110: goto tr518;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr172;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr172;
	} else
		goto tr172;
	goto tr140;
case 478:
	switch( (*( sm->p)) ) {
		case 75: goto tr519;
		case 91: goto tr173;
		case 107: goto tr519;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr172;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr172;
	} else
		goto tr172;
	goto tr140;
case 479:
	switch( (*( sm->p)) ) {
		case 65: goto tr520;
		case 91: goto tr173;
		case 97: goto tr520;
	}
	if ( (*( sm->p)) < 66 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr172;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 98 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr172;
	} else
		goto tr172;
	goto tr140;
case 480:
	switch( (*( sm->p)) ) {
		case 75: goto tr521;
		case 91: goto tr173;
		case 107: goto tr521;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr172;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr172;
	} else
		goto tr172;
	goto tr140;
case 481:
	switch( (*( sm->p)) ) {
		case 85: goto tr522;
		case 91: goto tr173;
		case 117: goto tr522;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr172;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr172;
	} else
		goto tr172;
	goto tr140;
case 482:
	switch( (*( sm->p)) ) {
		case 32: goto tr523;
		case 91: goto tr173;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr172;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr172;
	} else
		goto tr172;
	goto tr140;
case 483:
	if ( (*( sm->p)) == 35 )
		goto tr524;
	goto tr140;
case 484:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr525;
	goto tr140;
case 773:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr936;
	goto tr935;
case 485:
	switch( (*( sm->p)) ) {
		case 73: goto tr526;
		case 91: goto tr173;
		case 105: goto tr526;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr172;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr172;
	} else
		goto tr172;
	goto tr140;
case 486:
	switch( (*( sm->p)) ) {
		case 71: goto tr527;
		case 91: goto tr173;
		case 103: goto tr527;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr172;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr172;
	} else
		goto tr172;
	goto tr140;
case 487:
	switch( (*( sm->p)) ) {
		case 65: goto tr528;
		case 91: goto tr173;
		case 97: goto tr528;
	}
	if ( (*( sm->p)) < 66 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr172;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 98 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr172;
	} else
		goto tr172;
	goto tr140;
case 488:
	switch( (*( sm->p)) ) {
		case 32: goto tr529;
		case 91: goto tr173;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr172;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr172;
	} else
		goto tr172;
	goto tr140;
case 489:
	if ( (*( sm->p)) == 35 )
		goto tr530;
	goto tr140;
case 490:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr531;
	goto tr140;
case 774:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr938;
	goto tr937;
case 775:
	switch( (*( sm->p)) ) {
		case 79: goto tr939;
		case 87: goto tr940;
		case 91: goto tr173;
		case 111: goto tr939;
		case 119: goto tr940;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr172;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr172;
	} else
		goto tr172;
	goto tr822;
case 491:
	switch( (*( sm->p)) ) {
		case 80: goto tr532;
		case 91: goto tr173;
		case 112: goto tr532;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr172;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr172;
	} else
		goto tr172;
	goto tr140;
case 492:
	switch( (*( sm->p)) ) {
		case 73: goto tr533;
		case 91: goto tr173;
		case 105: goto tr533;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr172;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr172;
	} else
		goto tr172;
	goto tr140;
case 493:
	switch( (*( sm->p)) ) {
		case 67: goto tr534;
		case 91: goto tr173;
		case 99: goto tr534;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr172;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr172;
	} else
		goto tr172;
	goto tr140;
case 494:
	switch( (*( sm->p)) ) {
		case 32: goto tr535;
		case 91: goto tr173;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr172;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr172;
	} else
		goto tr172;
	goto tr140;
case 495:
	if ( (*( sm->p)) == 35 )
		goto tr536;
	goto tr140;
case 496:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr537;
	goto tr140;
case 776:
	if ( (*( sm->p)) == 47 )
		goto tr942;
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr943;
	goto tr941;
case 497:
	switch( (*( sm->p)) ) {
		case 80: goto tr539;
		case 112: goto tr539;
	}
	goto tr538;
case 498:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr540;
	goto tr538;
case 777:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr945;
	goto tr944;
case 499:
	switch( (*( sm->p)) ) {
		case 73: goto tr541;
		case 91: goto tr173;
		case 105: goto tr541;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr172;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr172;
	} else
		goto tr172;
	goto tr140;
case 500:
	switch( (*( sm->p)) ) {
		case 84: goto tr542;
		case 91: goto tr173;
		case 116: goto tr542;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr172;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr172;
	} else
		goto tr172;
	goto tr140;
case 501:
	switch( (*( sm->p)) ) {
		case 84: goto tr543;
		case 91: goto tr173;
		case 116: goto tr543;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr172;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr172;
	} else
		goto tr172;
	goto tr140;
case 502:
	switch( (*( sm->p)) ) {
		case 69: goto tr544;
		case 91: goto tr173;
		case 101: goto tr544;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr172;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr172;
	} else
		goto tr172;
	goto tr140;
case 503:
	switch( (*( sm->p)) ) {
		case 82: goto tr545;
		case 91: goto tr173;
		case 114: goto tr545;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr172;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr172;
	} else
		goto tr172;
	goto tr140;
case 504:
	switch( (*( sm->p)) ) {
		case 32: goto tr546;
		case 91: goto tr173;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr172;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr172;
	} else
		goto tr172;
	goto tr140;
case 505:
	if ( (*( sm->p)) == 35 )
		goto tr547;
	goto tr140;
case 506:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr548;
	goto tr140;
case 778:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr947;
	goto tr946;
case 779:
	switch( (*( sm->p)) ) {
		case 83: goto tr948;
		case 91: goto tr173;
		case 115: goto tr948;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr172;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr172;
	} else
		goto tr172;
	goto tr822;
case 507:
	switch( (*( sm->p)) ) {
		case 69: goto tr549;
		case 91: goto tr173;
		case 101: goto tr549;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr172;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr172;
	} else
		goto tr172;
	goto tr140;
case 508:
	switch( (*( sm->p)) ) {
		case 82: goto tr550;
		case 91: goto tr173;
		case 114: goto tr550;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr172;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr172;
	} else
		goto tr172;
	goto tr140;
case 509:
	switch( (*( sm->p)) ) {
		case 32: goto tr551;
		case 91: goto tr173;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr172;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr172;
	} else
		goto tr172;
	goto tr140;
case 510:
	if ( (*( sm->p)) == 35 )
		goto tr552;
	goto tr140;
case 511:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr553;
	goto tr140;
case 780:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr950;
	goto tr949;
case 781:
	switch( (*( sm->p)) ) {
		case 73: goto tr951;
		case 91: goto tr173;
		case 105: goto tr951;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr172;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr172;
	} else
		goto tr172;
	goto tr822;
case 512:
	switch( (*( sm->p)) ) {
		case 75: goto tr554;
		case 91: goto tr173;
		case 107: goto tr554;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr172;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr172;
	} else
		goto tr172;
	goto tr140;
case 513:
	switch( (*( sm->p)) ) {
		case 73: goto tr555;
		case 91: goto tr173;
		case 105: goto tr555;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr172;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr172;
	} else
		goto tr172;
	goto tr140;
case 514:
	switch( (*( sm->p)) ) {
		case 32: goto tr556;
		case 91: goto tr173;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr172;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr172;
	} else
		goto tr172;
	goto tr140;
case 515:
	if ( (*( sm->p)) == 35 )
		goto tr557;
	goto tr140;
case 516:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr558;
	goto tr140;
case 782:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr953;
	goto tr952;
case 783:
	switch( (*( sm->p)) ) {
		case 65: goto tr954;
		case 91: goto tr173;
		case 97: goto tr954;
	}
	if ( (*( sm->p)) < 66 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr172;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 98 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr172;
	} else
		goto tr172;
	goto tr822;
case 517:
	switch( (*( sm->p)) ) {
		case 78: goto tr559;
		case 91: goto tr173;
		case 110: goto tr559;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr172;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr172;
	} else
		goto tr172;
	goto tr140;
case 518:
	switch( (*( sm->p)) ) {
		case 68: goto tr560;
		case 91: goto tr173;
		case 100: goto tr560;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr172;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr172;
	} else
		goto tr172;
	goto tr140;
case 519:
	switch( (*( sm->p)) ) {
		case 69: goto tr561;
		case 91: goto tr173;
		case 101: goto tr561;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr172;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr172;
	} else
		goto tr172;
	goto tr140;
case 520:
	switch( (*( sm->p)) ) {
		case 82: goto tr562;
		case 91: goto tr173;
		case 114: goto tr562;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr172;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr172;
	} else
		goto tr172;
	goto tr140;
case 521:
	switch( (*( sm->p)) ) {
		case 69: goto tr563;
		case 91: goto tr173;
		case 101: goto tr563;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr172;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr172;
	} else
		goto tr172;
	goto tr140;
case 522:
	switch( (*( sm->p)) ) {
		case 32: goto tr564;
		case 91: goto tr173;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr172;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr172;
	} else
		goto tr172;
	goto tr140;
case 523:
	if ( (*( sm->p)) == 35 )
		goto tr565;
	goto tr140;
case 524:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr566;
	goto tr140;
case 784:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr956;
	goto tr955;
case 785:
	switch( (*( sm->p)) ) {
		case 47: goto tr957;
		case 66: goto tr958;
		case 67: goto tr959;
		case 69: goto tr960;
		case 73: goto tr961;
		case 78: goto tr962;
		case 81: goto tr963;
		case 83: goto tr964;
		case 84: goto tr965;
		case 85: goto tr966;
		case 91: goto tr174;
		case 98: goto tr958;
		case 99: goto tr959;
		case 101: goto tr960;
		case 104: goto tr967;
		case 105: goto tr961;
		case 110: goto tr962;
		case 113: goto tr963;
		case 115: goto tr964;
		case 116: goto tr965;
		case 117: goto tr966;
	}
	goto tr822;
case 525:
	switch( (*( sm->p)) ) {
		case 66: goto tr567;
		case 69: goto tr568;
		case 73: goto tr569;
		case 81: goto tr570;
		case 83: goto tr571;
		case 84: goto tr572;
		case 85: goto tr573;
		case 98: goto tr567;
		case 101: goto tr568;
		case 105: goto tr569;
		case 113: goto tr570;
		case 115: goto tr571;
		case 116: goto tr572;
		case 117: goto tr573;
	}
	goto tr140;
case 526:
	if ( (*( sm->p)) == 93 )
		goto tr194;
	goto tr140;
case 527:
	switch( (*( sm->p)) ) {
		case 88: goto tr574;
		case 120: goto tr574;
	}
	goto tr140;
case 528:
	switch( (*( sm->p)) ) {
		case 80: goto tr575;
		case 112: goto tr575;
	}
	goto tr140;
case 529:
	switch( (*( sm->p)) ) {
		case 65: goto tr576;
		case 97: goto tr576;
	}
	goto tr140;
case 530:
	switch( (*( sm->p)) ) {
		case 78: goto tr577;
		case 110: goto tr577;
	}
	goto tr140;
case 531:
	switch( (*( sm->p)) ) {
		case 68: goto tr578;
		case 100: goto tr578;
	}
	goto tr140;
case 532:
	if ( (*( sm->p)) == 93 )
		goto tr210;
	goto tr140;
case 533:
	if ( (*( sm->p)) == 93 )
		goto tr205;
	goto tr140;
case 534:
	switch( (*( sm->p)) ) {
		case 85: goto tr579;
		case 117: goto tr579;
	}
	goto tr140;
case 535:
	switch( (*( sm->p)) ) {
		case 79: goto tr580;
		case 111: goto tr580;
	}
	goto tr140;
case 536:
	switch( (*( sm->p)) ) {
		case 84: goto tr581;
		case 116: goto tr581;
	}
	goto tr140;
case 537:
	switch( (*( sm->p)) ) {
		case 69: goto tr582;
		case 101: goto tr582;
	}
	goto tr140;
case 538:
	if ( (*( sm->p)) == 93 )
		goto tr203;
	goto tr140;
case 539:
	switch( (*( sm->p)) ) {
		case 80: goto tr583;
		case 93: goto tr211;
		case 112: goto tr583;
	}
	goto tr140;
case 540:
	switch( (*( sm->p)) ) {
		case 79: goto tr584;
		case 111: goto tr584;
	}
	goto tr140;
case 541:
	switch( (*( sm->p)) ) {
		case 73: goto tr585;
		case 105: goto tr585;
	}
	goto tr140;
case 542:
	switch( (*( sm->p)) ) {
		case 76: goto tr586;
		case 108: goto tr586;
	}
	goto tr140;
case 543:
	switch( (*( sm->p)) ) {
		case 69: goto tr587;
		case 101: goto tr587;
	}
	goto tr140;
case 544:
	switch( (*( sm->p)) ) {
		case 82: goto tr588;
		case 114: goto tr588;
	}
	goto tr140;
case 545:
	switch( (*( sm->p)) ) {
		case 83: goto tr589;
		case 93: goto tr219;
		case 115: goto tr589;
	}
	goto tr140;
case 546:
	if ( (*( sm->p)) == 93 )
		goto tr219;
	goto tr140;
case 547:
	switch( (*( sm->p)) ) {
		case 68: goto tr590;
		case 72: goto tr591;
		case 78: goto tr592;
		case 100: goto tr590;
		case 104: goto tr591;
		case 110: goto tr592;
	}
	goto tr140;
case 548:
	if ( (*( sm->p)) == 93 )
		goto tr228;
	goto tr140;
case 549:
	if ( (*( sm->p)) == 93 )
		goto tr229;
	goto tr140;
case 550:
	if ( (*( sm->p)) == 93 )
		goto tr230;
	goto tr140;
case 551:
	if ( (*( sm->p)) == 93 )
		goto tr231;
	goto tr140;
case 552:
	if ( (*( sm->p)) == 93 )
		goto tr269;
	goto tr140;
case 553:
	switch( (*( sm->p)) ) {
		case 79: goto tr593;
		case 111: goto tr593;
	}
	goto tr140;
case 554:
	switch( (*( sm->p)) ) {
		case 68: goto tr594;
		case 100: goto tr594;
	}
	goto tr140;
case 555:
	switch( (*( sm->p)) ) {
		case 69: goto tr595;
		case 101: goto tr595;
	}
	goto tr140;
case 556:
	if ( (*( sm->p)) == 93 )
		goto tr283;
	goto tr140;
case 557:
	switch( (*( sm->p)) ) {
		case 88: goto tr596;
		case 120: goto tr596;
	}
	goto tr140;
case 558:
	switch( (*( sm->p)) ) {
		case 80: goto tr597;
		case 112: goto tr597;
	}
	goto tr140;
case 559:
	switch( (*( sm->p)) ) {
		case 65: goto tr598;
		case 97: goto tr598;
	}
	goto tr140;
case 560:
	switch( (*( sm->p)) ) {
		case 78: goto tr599;
		case 110: goto tr599;
	}
	goto tr140;
case 561:
	switch( (*( sm->p)) ) {
		case 68: goto tr600;
		case 100: goto tr600;
	}
	goto tr140;
case 562:
	if ( (*( sm->p)) == 93 )
		goto tr291;
	goto tr140;
case 563:
	if ( (*( sm->p)) == 93 )
		goto tr286;
	goto tr140;
case 564:
	switch( (*( sm->p)) ) {
		case 79: goto tr601;
		case 111: goto tr601;
	}
	goto tr140;
case 565:
	switch( (*( sm->p)) ) {
		case 68: goto tr602;
		case 100: goto tr602;
	}
	goto tr140;
case 566:
	switch( (*( sm->p)) ) {
		case 84: goto tr603;
		case 116: goto tr603;
	}
	goto tr140;
case 567:
	switch( (*( sm->p)) ) {
		case 69: goto tr604;
		case 101: goto tr604;
	}
	goto tr140;
case 568:
	switch( (*( sm->p)) ) {
		case 88: goto tr605;
		case 120: goto tr605;
	}
	goto tr140;
case 569:
	switch( (*( sm->p)) ) {
		case 84: goto tr606;
		case 116: goto tr606;
	}
	goto tr140;
case 570:
	if ( (*( sm->p)) == 93 )
		goto tr298;
	goto tr140;
case 571:
	switch( (*( sm->p)) ) {
		case 85: goto tr607;
		case 117: goto tr607;
	}
	goto tr140;
case 572:
	switch( (*( sm->p)) ) {
		case 79: goto tr608;
		case 111: goto tr608;
	}
	goto tr140;
case 573:
	switch( (*( sm->p)) ) {
		case 84: goto tr609;
		case 116: goto tr609;
	}
	goto tr140;
case 574:
	switch( (*( sm->p)) ) {
		case 69: goto tr610;
		case 101: goto tr610;
	}
	goto tr140;
case 575:
	if ( (*( sm->p)) == 93 )
		goto tr279;
	goto tr140;
case 576:
	switch( (*( sm->p)) ) {
		case 80: goto tr611;
		case 93: goto tr299;
		case 112: goto tr611;
	}
	goto tr140;
case 577:
	switch( (*( sm->p)) ) {
		case 79: goto tr612;
		case 111: goto tr612;
	}
	goto tr140;
case 578:
	switch( (*( sm->p)) ) {
		case 73: goto tr613;
		case 105: goto tr613;
	}
	goto tr140;
case 579:
	switch( (*( sm->p)) ) {
		case 76: goto tr614;
		case 108: goto tr614;
	}
	goto tr140;
case 580:
	switch( (*( sm->p)) ) {
		case 69: goto tr615;
		case 101: goto tr615;
	}
	goto tr140;
case 581:
	switch( (*( sm->p)) ) {
		case 82: goto tr616;
		case 114: goto tr616;
	}
	goto tr140;
case 582:
	switch( (*( sm->p)) ) {
		case 83: goto tr617;
		case 93: goto tr307;
		case 115: goto tr617;
	}
	goto tr140;
case 583:
	if ( (*( sm->p)) == 93 )
		goto tr307;
	goto tr140;
case 584:
	switch( (*( sm->p)) ) {
		case 78: goto tr618;
		case 110: goto tr618;
	}
	goto tr140;
case 585:
	if ( (*( sm->p)) == 93 )
		goto tr314;
	goto tr140;
case 586:
	if ( (*( sm->p)) == 93 )
		goto tr315;
	goto tr140;
case 587:
	if ( (*( sm->p)) == 116 )
		goto tr619;
	goto tr140;
case 588:
	if ( (*( sm->p)) == 116 )
		goto tr620;
	goto tr140;
case 589:
	if ( (*( sm->p)) == 112 )
		goto tr621;
	goto tr140;
case 590:
	switch( (*( sm->p)) ) {
		case 58: goto tr622;
		case 115: goto tr623;
	}
	goto tr140;
case 591:
	if ( (*( sm->p)) == 47 )
		goto tr624;
	goto tr140;
case 592:
	if ( (*( sm->p)) == 47 )
		goto tr625;
	goto tr140;
case 593:
	if ( (*( sm->p)) < -32 ) {
		if ( -62 <= (*( sm->p)) && (*( sm->p)) <= -33 )
			goto tr626;
	} else if ( (*( sm->p)) > -17 ) {
		if ( (*( sm->p)) > -12 ) {
			if ( 33 <= (*( sm->p)) && (*( sm->p)) <= 126 )
				goto tr629;
		} else if ( (*( sm->p)) >= -16 )
			goto tr628;
	} else
		goto tr627;
	goto tr140;
case 594:
	if ( (*( sm->p)) <= -65 )
		goto tr629;
	goto tr140;
case 595:
	if ( (*( sm->p)) == 93 )
		goto tr630;
	if ( (*( sm->p)) < -32 ) {
		if ( -62 <= (*( sm->p)) && (*( sm->p)) <= -33 )
			goto tr626;
	} else if ( (*( sm->p)) > -17 ) {
		if ( (*( sm->p)) > -12 ) {
			if ( 33 <= (*( sm->p)) && (*( sm->p)) <= 126 )
				goto tr629;
		} else if ( (*( sm->p)) >= -16 )
			goto tr628;
	} else
		goto tr627;
	goto tr140;
case 596:
	if ( (*( sm->p)) <= -65 )
		goto tr626;
	goto tr140;
case 597:
	if ( (*( sm->p)) <= -65 )
		goto tr627;
	goto tr140;
case 598:
	switch( (*( sm->p)) ) {
		case 40: goto tr631;
		case 93: goto tr630;
	}
	if ( (*( sm->p)) < -32 ) {
		if ( -62 <= (*( sm->p)) && (*( sm->p)) <= -33 )
			goto tr626;
	} else if ( (*( sm->p)) > -17 ) {
		if ( (*( sm->p)) > -12 ) {
			if ( 33 <= (*( sm->p)) && (*( sm->p)) <= 126 )
				goto tr629;
		} else if ( (*( sm->p)) >= -16 )
			goto tr628;
	} else
		goto tr627;
	goto tr140;
case 599:
	if ( (*( sm->p)) == 41 )
		goto tr140;
	goto tr632;
case 600:
	if ( (*( sm->p)) == 41 )
		goto tr634;
	goto tr633;
case 601:
	if ( (*( sm->p)) == 58 )
		goto tr622;
	goto tr140;
case 786:
	switch( (*( sm->p)) ) {
		case 91: goto tr173;
		case 116: goto tr968;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr172;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr172;
	} else
		goto tr172;
	goto tr822;
case 602:
	switch( (*( sm->p)) ) {
		case 91: goto tr173;
		case 116: goto tr635;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr172;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr172;
	} else
		goto tr172;
	goto tr140;
case 603:
	switch( (*( sm->p)) ) {
		case 91: goto tr173;
		case 112: goto tr636;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr172;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr172;
	} else
		goto tr172;
	goto tr140;
case 604:
	switch( (*( sm->p)) ) {
		case 58: goto tr637;
		case 91: goto tr173;
		case 115: goto tr638;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr172;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr172;
	} else
		goto tr172;
	goto tr140;
case 605:
	if ( (*( sm->p)) == 47 )
		goto tr639;
	goto tr140;
case 606:
	if ( (*( sm->p)) == 47 )
		goto tr640;
	goto tr140;
case 607:
	if ( (*( sm->p)) < -32 ) {
		if ( -62 <= (*( sm->p)) && (*( sm->p)) <= -33 )
			goto tr641;
	} else if ( (*( sm->p)) > -17 ) {
		if ( (*( sm->p)) > -12 ) {
			if ( 33 <= (*( sm->p)) && (*( sm->p)) <= 126 )
				goto tr644;
		} else if ( (*( sm->p)) >= -16 )
			goto tr643;
	} else
		goto tr642;
	goto tr140;
case 608:
	if ( (*( sm->p)) <= -65 )
		goto tr644;
	goto tr133;
case 787:
	if ( (*( sm->p)) < -32 ) {
		if ( -62 <= (*( sm->p)) && (*( sm->p)) <= -33 )
			goto tr641;
	} else if ( (*( sm->p)) > -17 ) {
		if ( (*( sm->p)) > -12 ) {
			if ( 33 <= (*( sm->p)) && (*( sm->p)) <= 126 )
				goto tr644;
		} else if ( (*( sm->p)) >= -16 )
			goto tr643;
	} else
		goto tr642;
	goto tr969;
case 609:
	if ( (*( sm->p)) <= -65 )
		goto tr641;
	goto tr133;
case 610:
	if ( (*( sm->p)) <= -65 )
		goto tr642;
	goto tr133;
case 611:
	switch( (*( sm->p)) ) {
		case 58: goto tr637;
		case 91: goto tr173;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr172;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr172;
	} else
		goto tr172;
	goto tr140;
case 788:
	if ( (*( sm->p)) == 123 )
		goto tr970;
	goto tr822;
case 612:
	if ( (*( sm->p)) == 125 )
		goto tr140;
	goto tr645;
case 613:
	if ( (*( sm->p)) == 125 )
		goto tr647;
	goto tr646;
case 614:
	if ( (*( sm->p)) == 125 )
		goto tr648;
	goto tr140;
case 789:
	switch( (*( sm->p)) ) {
		case 60: goto tr972;
		case 91: goto tr973;
	}
	goto tr971;
case 790:
	if ( (*( sm->p)) == 47 )
		goto tr975;
	goto tr974;
case 615:
	switch( (*( sm->p)) ) {
		case 67: goto tr650;
		case 99: goto tr650;
	}
	goto tr649;
case 616:
	switch( (*( sm->p)) ) {
		case 79: goto tr651;
		case 111: goto tr651;
	}
	goto tr649;
case 617:
	switch( (*( sm->p)) ) {
		case 68: goto tr652;
		case 100: goto tr652;
	}
	goto tr649;
case 618:
	switch( (*( sm->p)) ) {
		case 69: goto tr653;
		case 101: goto tr653;
	}
	goto tr649;
case 619:
	if ( (*( sm->p)) == 62 )
		goto tr654;
	goto tr649;
case 791:
	if ( (*( sm->p)) == 47 )
		goto tr976;
	goto tr974;
case 620:
	switch( (*( sm->p)) ) {
		case 67: goto tr655;
		case 99: goto tr655;
	}
	goto tr649;
case 621:
	switch( (*( sm->p)) ) {
		case 79: goto tr656;
		case 111: goto tr656;
	}
	goto tr649;
case 622:
	switch( (*( sm->p)) ) {
		case 68: goto tr657;
		case 100: goto tr657;
	}
	goto tr649;
case 623:
	switch( (*( sm->p)) ) {
		case 69: goto tr658;
		case 101: goto tr658;
	}
	goto tr649;
case 624:
	if ( (*( sm->p)) == 93 )
		goto tr654;
	goto tr649;
case 792:
	switch( (*( sm->p)) ) {
		case 60: goto tr978;
		case 91: goto tr979;
	}
	goto tr977;
case 793:
	if ( (*( sm->p)) == 47 )
		goto tr981;
	goto tr980;
case 625:
	switch( (*( sm->p)) ) {
		case 78: goto tr660;
		case 110: goto tr660;
	}
	goto tr659;
case 626:
	switch( (*( sm->p)) ) {
		case 79: goto tr661;
		case 111: goto tr661;
	}
	goto tr659;
case 627:
	switch( (*( sm->p)) ) {
		case 68: goto tr662;
		case 100: goto tr662;
	}
	goto tr659;
case 628:
	switch( (*( sm->p)) ) {
		case 84: goto tr663;
		case 116: goto tr663;
	}
	goto tr659;
case 629:
	switch( (*( sm->p)) ) {
		case 69: goto tr664;
		case 101: goto tr664;
	}
	goto tr659;
case 630:
	switch( (*( sm->p)) ) {
		case 88: goto tr665;
		case 120: goto tr665;
	}
	goto tr659;
case 631:
	switch( (*( sm->p)) ) {
		case 84: goto tr666;
		case 116: goto tr666;
	}
	goto tr659;
case 632:
	if ( (*( sm->p)) == 62 )
		goto tr667;
	goto tr659;
case 794:
	if ( (*( sm->p)) == 47 )
		goto tr982;
	goto tr980;
case 633:
	switch( (*( sm->p)) ) {
		case 78: goto tr668;
		case 110: goto tr668;
	}
	goto tr659;
case 634:
	switch( (*( sm->p)) ) {
		case 79: goto tr669;
		case 111: goto tr669;
	}
	goto tr659;
case 635:
	switch( (*( sm->p)) ) {
		case 68: goto tr670;
		case 100: goto tr670;
	}
	goto tr659;
case 636:
	switch( (*( sm->p)) ) {
		case 84: goto tr671;
		case 116: goto tr671;
	}
	goto tr659;
case 637:
	switch( (*( sm->p)) ) {
		case 69: goto tr672;
		case 101: goto tr672;
	}
	goto tr659;
case 638:
	switch( (*( sm->p)) ) {
		case 88: goto tr673;
		case 120: goto tr673;
	}
	goto tr659;
case 639:
	switch( (*( sm->p)) ) {
		case 84: goto tr674;
		case 116: goto tr674;
	}
	goto tr659;
case 640:
	if ( (*( sm->p)) == 93 )
		goto tr667;
	goto tr659;
case 795:
	switch( (*( sm->p)) ) {
		case 60: goto tr984;
		case 91: goto tr985;
	}
	goto tr983;
case 796:
	switch( (*( sm->p)) ) {
		case 47: goto tr987;
		case 84: goto tr988;
		case 116: goto tr988;
	}
	goto tr986;
case 641:
	switch( (*( sm->p)) ) {
		case 84: goto tr676;
		case 116: goto tr676;
	}
	goto tr675;
case 642:
	switch( (*( sm->p)) ) {
		case 65: goto tr677;
		case 66: goto tr678;
		case 72: goto tr679;
		case 82: goto tr680;
		case 97: goto tr677;
		case 98: goto tr678;
		case 104: goto tr679;
		case 114: goto tr680;
	}
	goto tr675;
case 643:
	switch( (*( sm->p)) ) {
		case 66: goto tr681;
		case 98: goto tr681;
	}
	goto tr675;
case 644:
	switch( (*( sm->p)) ) {
		case 76: goto tr682;
		case 108: goto tr682;
	}
	goto tr675;
case 645:
	switch( (*( sm->p)) ) {
		case 69: goto tr683;
		case 101: goto tr683;
	}
	goto tr675;
case 646:
	if ( (*( sm->p)) == 62 )
		goto tr684;
	goto tr675;
case 647:
	switch( (*( sm->p)) ) {
		case 79: goto tr685;
		case 111: goto tr685;
	}
	goto tr675;
case 648:
	switch( (*( sm->p)) ) {
		case 68: goto tr686;
		case 100: goto tr686;
	}
	goto tr675;
case 649:
	switch( (*( sm->p)) ) {
		case 89: goto tr687;
		case 121: goto tr687;
	}
	goto tr675;
case 650:
	if ( (*( sm->p)) == 62 )
		goto tr688;
	goto tr675;
case 651:
	switch( (*( sm->p)) ) {
		case 69: goto tr689;
		case 101: goto tr689;
	}
	goto tr675;
case 652:
	switch( (*( sm->p)) ) {
		case 65: goto tr690;
		case 97: goto tr690;
	}
	goto tr675;
case 653:
	switch( (*( sm->p)) ) {
		case 68: goto tr691;
		case 100: goto tr691;
	}
	goto tr675;
case 654:
	if ( (*( sm->p)) == 62 )
		goto tr692;
	goto tr675;
case 655:
	if ( (*( sm->p)) == 62 )
		goto tr693;
	goto tr675;
case 656:
	switch( (*( sm->p)) ) {
		case 66: goto tr694;
		case 68: goto tr695;
		case 72: goto tr696;
		case 82: goto tr697;
		case 98: goto tr694;
		case 100: goto tr695;
		case 104: goto tr696;
		case 114: goto tr697;
	}
	goto tr675;
case 657:
	switch( (*( sm->p)) ) {
		case 79: goto tr698;
		case 111: goto tr698;
	}
	goto tr675;
case 658:
	switch( (*( sm->p)) ) {
		case 68: goto tr699;
		case 100: goto tr699;
	}
	goto tr675;
case 659:
	switch( (*( sm->p)) ) {
		case 89: goto tr700;
		case 121: goto tr700;
	}
	goto tr675;
case 660:
	if ( (*( sm->p)) == 62 )
		goto tr701;
	goto tr675;
case 661:
	if ( (*( sm->p)) == 62 )
		goto tr702;
	goto tr675;
case 662:
	switch( (*( sm->p)) ) {
		case 62: goto tr703;
		case 69: goto tr704;
		case 101: goto tr704;
	}
	goto tr675;
case 663:
	switch( (*( sm->p)) ) {
		case 65: goto tr705;
		case 97: goto tr705;
	}
	goto tr675;
case 664:
	switch( (*( sm->p)) ) {
		case 68: goto tr706;
		case 100: goto tr706;
	}
	goto tr675;
case 665:
	if ( (*( sm->p)) == 62 )
		goto tr707;
	goto tr675;
case 666:
	if ( (*( sm->p)) == 62 )
		goto tr708;
	goto tr675;
case 797:
	switch( (*( sm->p)) ) {
		case 47: goto tr989;
		case 84: goto tr990;
		case 116: goto tr990;
	}
	goto tr986;
case 667:
	switch( (*( sm->p)) ) {
		case 84: goto tr709;
		case 116: goto tr709;
	}
	goto tr675;
case 668:
	switch( (*( sm->p)) ) {
		case 65: goto tr710;
		case 66: goto tr711;
		case 72: goto tr712;
		case 82: goto tr713;
		case 97: goto tr710;
		case 98: goto tr711;
		case 104: goto tr712;
		case 114: goto tr713;
	}
	goto tr675;
case 669:
	switch( (*( sm->p)) ) {
		case 66: goto tr714;
		case 98: goto tr714;
	}
	goto tr675;
case 670:
	switch( (*( sm->p)) ) {
		case 76: goto tr715;
		case 108: goto tr715;
	}
	goto tr675;
case 671:
	switch( (*( sm->p)) ) {
		case 69: goto tr716;
		case 101: goto tr716;
	}
	goto tr675;
case 672:
	if ( (*( sm->p)) == 93 )
		goto tr684;
	goto tr675;
case 673:
	switch( (*( sm->p)) ) {
		case 79: goto tr717;
		case 111: goto tr717;
	}
	goto tr675;
case 674:
	switch( (*( sm->p)) ) {
		case 68: goto tr718;
		case 100: goto tr718;
	}
	goto tr675;
case 675:
	switch( (*( sm->p)) ) {
		case 89: goto tr719;
		case 121: goto tr719;
	}
	goto tr675;
case 676:
	if ( (*( sm->p)) == 93 )
		goto tr688;
	goto tr675;
case 677:
	switch( (*( sm->p)) ) {
		case 69: goto tr720;
		case 101: goto tr720;
	}
	goto tr675;
case 678:
	switch( (*( sm->p)) ) {
		case 65: goto tr721;
		case 97: goto tr721;
	}
	goto tr675;
case 679:
	switch( (*( sm->p)) ) {
		case 68: goto tr722;
		case 100: goto tr722;
	}
	goto tr675;
case 680:
	if ( (*( sm->p)) == 93 )
		goto tr692;
	goto tr675;
case 681:
	if ( (*( sm->p)) == 93 )
		goto tr693;
	goto tr675;
case 682:
	switch( (*( sm->p)) ) {
		case 66: goto tr723;
		case 68: goto tr724;
		case 72: goto tr725;
		case 82: goto tr726;
		case 98: goto tr723;
		case 100: goto tr724;
		case 104: goto tr725;
		case 114: goto tr726;
	}
	goto tr675;
case 683:
	switch( (*( sm->p)) ) {
		case 79: goto tr727;
		case 111: goto tr727;
	}
	goto tr675;
case 684:
	switch( (*( sm->p)) ) {
		case 68: goto tr728;
		case 100: goto tr728;
	}
	goto tr675;
case 685:
	switch( (*( sm->p)) ) {
		case 89: goto tr729;
		case 121: goto tr729;
	}
	goto tr675;
case 686:
	if ( (*( sm->p)) == 93 )
		goto tr701;
	goto tr675;
case 687:
	if ( (*( sm->p)) == 93 )
		goto tr702;
	goto tr675;
case 688:
	switch( (*( sm->p)) ) {
		case 69: goto tr730;
		case 93: goto tr703;
		case 101: goto tr730;
	}
	goto tr675;
case 689:
	switch( (*( sm->p)) ) {
		case 65: goto tr731;
		case 97: goto tr731;
	}
	goto tr675;
case 690:
	switch( (*( sm->p)) ) {
		case 68: goto tr732;
		case 100: goto tr732;
	}
	goto tr675;
case 691:
	if ( (*( sm->p)) == 93 )
		goto tr707;
	goto tr675;
case 692:
	if ( (*( sm->p)) == 93 )
		goto tr708;
	goto tr675;
case 798:
	switch( (*( sm->p)) ) {
		case 10: goto tr992;
		case 13: goto tr993;
		case 42: goto tr994;
	}
	goto tr991;
case 799:
	switch( (*( sm->p)) ) {
		case 10: goto tr734;
		case 13: goto tr995;
	}
	goto tr733;
case 693:
	if ( (*( sm->p)) == 10 )
		goto tr734;
	goto tr733;
case 800:
	if ( (*( sm->p)) == 10 )
		goto tr992;
	goto tr996;
case 801:
	switch( (*( sm->p)) ) {
		case 9: goto tr738;
		case 32: goto tr738;
		case 42: goto tr739;
	}
	goto tr996;
case 694:
	switch( (*( sm->p)) ) {
		case 9: goto tr737;
		case 10: goto tr735;
		case 13: goto tr735;
		case 32: goto tr737;
	}
	goto tr736;
case 802:
	switch( (*( sm->p)) ) {
		case 10: goto tr997;
		case 13: goto tr997;
	}
	goto tr998;
case 803:
	switch( (*( sm->p)) ) {
		case 9: goto tr737;
		case 10: goto tr997;
		case 13: goto tr997;
		case 32: goto tr737;
	}
	goto tr736;
case 695:
	switch( (*( sm->p)) ) {
		case 9: goto tr738;
		case 32: goto tr738;
		case 42: goto tr739;
	}
	goto tr735;
	}

	tr747:  sm->cs = 0; goto _again;
	tr5:  sm->cs = 1; goto f4;
	tr6:  sm->cs = 2; goto _again;
	tr751:  sm->cs = 3; goto _again;
	tr7:  sm->cs = 4; goto _again;
	tr8:  sm->cs = 5; goto _again;
	tr9:  sm->cs = 6; goto _again;
	tr10:  sm->cs = 7; goto _again;
	tr11:  sm->cs = 8; goto _again;
	tr12:  sm->cs = 9; goto _again;
	tr13:  sm->cs = 10; goto _again;
	tr15:  sm->cs = 11; goto _again;
	tr752:  sm->cs = 12; goto _again;
	tr16:  sm->cs = 13; goto _again;
	tr17:  sm->cs = 14; goto _again;
	tr18:  sm->cs = 15; goto _again;
	tr19:  sm->cs = 16; goto _again;
	tr20:  sm->cs = 17; goto _again;
	tr21:  sm->cs = 18; goto _again;
	tr22:  sm->cs = 19; goto _again;
	tr23:  sm->cs = 20; goto _again;
	tr24:  sm->cs = 21; goto _again;
	tr753:  sm->cs = 22; goto _again;
	tr26:  sm->cs = 23; goto _again;
	tr27:  sm->cs = 24; goto _again;
	tr28:  sm->cs = 25; goto _again;
	tr754:  sm->cs = 26; goto _again;
	tr30:  sm->cs = 27; goto _again;
	tr31:  sm->cs = 28; goto _again;
	tr32:  sm->cs = 29; goto _again;
	tr33:  sm->cs = 30; goto _again;
	tr34:  sm->cs = 31; goto _again;
	tr755:  sm->cs = 32; goto _again;
	tr36:  sm->cs = 33; goto _again;
	tr37:  sm->cs = 34; goto _again;
	tr38:  sm->cs = 35; goto _again;
	tr39:  sm->cs = 36; goto _again;
	tr40:  sm->cs = 37; goto _again;
	tr41:  sm->cs = 38; goto _again;
	tr756:  sm->cs = 39; goto _again;
	tr43:  sm->cs = 40; goto _again;
	tr44:  sm->cs = 41; goto _again;
	tr45:  sm->cs = 42; goto _again;
	tr46:  sm->cs = 43; goto _again;
	tr47:  sm->cs = 44; goto _again;
	tr48:  sm->cs = 45; goto _again;
	tr50:  sm->cs = 46; goto _again;
	tr757:  sm->cs = 47; goto _again;
	tr51:  sm->cs = 48; goto _again;
	tr53:  sm->cs = 49; goto _again;
	tr54:  sm->cs = 50; goto _again;
	tr55:  sm->cs = 51; goto _again;
	tr52:  sm->cs = 52; goto _again;
	tr763:  sm->cs = 53; goto f9;
	tr58:  sm->cs = 54; goto f4;
	tr61:  sm->cs = 55; goto _again;
	tr60:  sm->cs = 55; goto f3;
	tr768:  sm->cs = 56; goto _again;
	tr63:  sm->cs = 57; goto _again;
	tr64:  sm->cs = 58; goto _again;
	tr65:  sm->cs = 59; goto _again;
	tr66:  sm->cs = 60; goto _again;
	tr67:  sm->cs = 61; goto _again;
	tr68:  sm->cs = 62; goto _again;
	tr69:  sm->cs = 63; goto _again;
	tr70:  sm->cs = 64; goto _again;
	tr769:  sm->cs = 65; goto _again;
	tr71:  sm->cs = 66; goto _again;
	tr72:  sm->cs = 67; goto _again;
	tr73:  sm->cs = 68; goto _again;
	tr770:  sm->cs = 69; goto _again;
	tr74:  sm->cs = 70; goto _again;
	tr75:  sm->cs = 71; goto _again;
	tr76:  sm->cs = 72; goto _again;
	tr77:  sm->cs = 73; goto _again;
	tr78:  sm->cs = 74; goto _again;
	tr79:  sm->cs = 75; goto _again;
	tr81:  sm->cs = 76; goto _again;
	tr80:  sm->cs = 76; goto f9;
	tr771:  sm->cs = 77; goto _again;
	tr83:  sm->cs = 78; goto _again;
	tr84:  sm->cs = 79; goto _again;
	tr85:  sm->cs = 80; goto _again;
	tr86:  sm->cs = 81; goto _again;
	tr87:  sm->cs = 82; goto _again;
	tr88:  sm->cs = 83; goto _again;
	tr772:  sm->cs = 84; goto _again;
	tr89:  sm->cs = 85; goto _again;
	tr90:  sm->cs = 86; goto _again;
	tr91:  sm->cs = 87; goto _again;
	tr92:  sm->cs = 88; goto _again;
	tr773:  sm->cs = 89; goto _again;
	tr93:  sm->cs = 90; goto _again;
	tr94:  sm->cs = 91; goto _again;
	tr95:  sm->cs = 92; goto _again;
	tr96:  sm->cs = 93; goto _again;
	tr97:  sm->cs = 94; goto _again;
	tr98:  sm->cs = 95; goto _again;
	tr99:  sm->cs = 96; goto _again;
	tr774:  sm->cs = 97; goto _again;
	tr100:  sm->cs = 98; goto _again;
	tr102:  sm->cs = 99; goto _again;
	tr103:  sm->cs = 100; goto _again;
	tr104:  sm->cs = 101; goto _again;
	tr101:  sm->cs = 102; goto _again;
	tr781:  sm->cs = 103; goto _again;
	tr106:  sm->cs = 104; goto _again;
	tr107:  sm->cs = 105; goto _again;
	tr108:  sm->cs = 106; goto _again;
	tr109:  sm->cs = 107; goto _again;
	tr114:  sm->cs = 108; goto _again;
	tr115:  sm->cs = 109; goto _again;
	tr116:  sm->cs = 110; goto _again;
	tr117:  sm->cs = 111; goto _again;
	tr110:  sm->cs = 112; goto _again;
	tr127:  sm->cs = 113; goto _again;
	tr782:  sm->cs = 114; goto _again;
	tr120:  sm->cs = 115; goto _again;
	tr783:  sm->cs = 116; goto _again;
	tr123:  sm->cs = 117; goto _again;
	tr124:  sm->cs = 118; goto _again;
	tr125:  sm->cs = 119; goto _again;
	tr126:  sm->cs = 120; goto _again;
	tr784:  sm->cs = 121; goto _again;
	tr785:  sm->cs = 122; goto _again;
	tr129:  sm->cs = 123; goto _again;
	tr130:  sm->cs = 124; goto _again;
	tr131:  sm->cs = 125; goto _again;
	tr132:  sm->cs = 126; goto _again;
	tr786:  sm->cs = 127; goto _again;
	tr787:  sm->cs = 128; goto _again;
	tr788:  sm->cs = 129; goto _again;
	tr789:  sm->cs = 130; goto _again;
	tr816:  sm->cs = 131; goto _again;
	tr137:  sm->cs = 132; goto _again;
	tr817:  sm->cs = 132; goto f9;
	tr136:  sm->cs = 133; goto f4;
	tr141:  sm->cs = 134; goto _again;
	tr823:  sm->cs = 134; goto f9;
	tr142:  sm->cs = 135; goto f4;
	tr143:  sm->cs = 136; goto _again;
	tr171:  sm->cs = 137; goto _again;
	tr144:  sm->cs = 137; goto f3;
	tr147:  sm->cs = 138; goto _again;
	tr148:  sm->cs = 139; goto _again;
	tr149:  sm->cs = 140; goto _again;
	tr145:  sm->cs = 141; goto _again;
	tr164:  sm->cs = 142; goto _again;
	tr151:  sm->cs = 142; goto f3;
	tr153:  sm->cs = 143; goto _again;
	tr156:  sm->cs = 144; goto f8;
	tr154:  sm->cs = 145; goto _again;
	tr155:  sm->cs = 146; goto _again;
	tr152:  sm->cs = 147; goto f3;
	tr158:  sm->cs = 148; goto _again;
	tr159:  sm->cs = 149; goto _again;
	tr160:  sm->cs = 150; goto _again;
	tr161:  sm->cs = 151; goto _again;
	tr163:  sm->cs = 152; goto _again;
	tr162:  sm->cs = 153; goto _again;
	tr146:  sm->cs = 154; goto f3;
	tr165:  sm->cs = 155; goto _again;
	tr166:  sm->cs = 156; goto _again;
	tr167:  sm->cs = 157; goto _again;
	tr168:  sm->cs = 158; goto _again;
	tr170:  sm->cs = 159; goto _again;
	tr169:  sm->cs = 160; goto _again;
	tr172:  sm->cs = 161; goto _again;
	tr173:  sm->cs = 162; goto f4;
	tr174:  sm->cs = 163; goto _again;
	tr177:  sm->cs = 164; goto _again;
	tr175:  sm->cs = 164; goto f3;
	tr178:  sm->cs = 165; goto f8;
	tr179:  sm->cs = 166; goto f8;
	tr183:  sm->cs = 167; goto _again;
	tr181:  sm->cs = 167; goto f25;
	tr182:  sm->cs = 168; goto f26;
	tr184:  sm->cs = 168; goto f27;
	tr186:  sm->cs = 169; goto _again;
	tr176:  sm->cs = 169; goto f3;
	tr833:  sm->cs = 170; goto _again;
	tr187:  sm->cs = 171; goto _again;
	tr195:  sm->cs = 172; goto _again;
	tr196:  sm->cs = 173; goto _again;
	tr197:  sm->cs = 174; goto _again;
	tr198:  sm->cs = 175; goto _again;
	tr190:  sm->cs = 176; goto _again;
	tr199:  sm->cs = 177; goto _again;
	tr200:  sm->cs = 178; goto _again;
	tr201:  sm->cs = 179; goto _again;
	tr202:  sm->cs = 180; goto _again;
	tr188:  sm->cs = 181; goto _again;
	tr189:  sm->cs = 182; goto _again;
	tr204:  sm->cs = 183; goto _again;
	tr206:  sm->cs = 184; goto _again;
	tr207:  sm->cs = 185; goto _again;
	tr208:  sm->cs = 186; goto _again;
	tr209:  sm->cs = 187; goto _again;
	tr191:  sm->cs = 188; goto _again;
	tr212:  sm->cs = 189; goto _again;
	tr214:  sm->cs = 190; goto _again;
	tr215:  sm->cs = 191; goto _again;
	tr216:  sm->cs = 192; goto _again;
	tr217:  sm->cs = 193; goto _again;
	tr218:  sm->cs = 194; goto _again;
	tr220:  sm->cs = 195; goto _again;
	tr213:  sm->cs = 196; goto _again;
	tr221:  sm->cs = 197; goto _again;
	tr222:  sm->cs = 198; goto _again;
	tr223:  sm->cs = 199; goto _again;
	tr224:  sm->cs = 200; goto _again;
	tr192:  sm->cs = 201; goto _again;
	tr225:  sm->cs = 202; goto _again;
	tr226:  sm->cs = 203; goto _again;
	tr227:  sm->cs = 204; goto _again;
	tr193:  sm->cs = 205; goto _again;
	tr834:  sm->cs = 206; goto _again;
	tr237:  sm->cs = 207; goto _again;
	tr232:  sm->cs = 207; goto f9;
	tr236:  sm->cs = 208; goto _again;
	tr235:  sm->cs = 208; goto f9;
	tr238:  sm->cs = 209; goto _again;
	tr233:  sm->cs = 209; goto f9;
	tr239:  sm->cs = 210; goto _again;
	tr234:  sm->cs = 210; goto f9;
	tr835:  sm->cs = 211; goto _again;
	tr241:  sm->cs = 212; goto _again;
	tr242:  sm->cs = 213; goto _again;
	tr243:  sm->cs = 214; goto _again;
	tr244:  sm->cs = 215; goto _again;
	tr245:  sm->cs = 216; goto _again;
	tr246:  sm->cs = 217; goto _again;
	tr247:  sm->cs = 218; goto _again;
	tr268:  sm->cs = 219; goto _again;
	tr248:  sm->cs = 219; goto f9;
	tr250:  sm->cs = 220; goto _again;
	tr253:  sm->cs = 221; goto _again;
	tr251:  sm->cs = 222; goto _again;
	tr252:  sm->cs = 223; goto _again;
	tr254:  sm->cs = 224; goto f4;
	tr255:  sm->cs = 225; goto _again;
	tr257:  sm->cs = 226; goto _again;
	tr256:  sm->cs = 226; goto f3;
	tr258:  sm->cs = 227; goto f8;
	tr259:  sm->cs = 228; goto _again;
	tr260:  sm->cs = 229; goto _again;
	tr249:  sm->cs = 230; goto f9;
	tr262:  sm->cs = 231; goto _again;
	tr263:  sm->cs = 232; goto _again;
	tr264:  sm->cs = 233; goto _again;
	tr265:  sm->cs = 234; goto _again;
	tr267:  sm->cs = 235; goto _again;
	tr266:  sm->cs = 236; goto _again;
	tr836:  sm->cs = 237; goto _again;
	tr270:  sm->cs = 238; goto _again;
	tr271:  sm->cs = 239; goto _again;
	tr272:  sm->cs = 240; goto _again;
	tr273:  sm->cs = 241; goto _again;
	tr274:  sm->cs = 242; goto _again;
	tr275:  sm->cs = 243; goto _again;
	tr276:  sm->cs = 244; goto _again;
	tr277:  sm->cs = 245; goto _again;
	tr278:  sm->cs = 246; goto _again;
	tr837:  sm->cs = 247; goto _again;
	tr280:  sm->cs = 248; goto _again;
	tr281:  sm->cs = 249; goto _again;
	tr282:  sm->cs = 250; goto _again;
	tr838:  sm->cs = 251; goto _again;
	tr284:  sm->cs = 252; goto _again;
	tr285:  sm->cs = 253; goto _again;
	tr287:  sm->cs = 254; goto _again;
	tr288:  sm->cs = 255; goto _again;
	tr289:  sm->cs = 256; goto _again;
	tr290:  sm->cs = 257; goto _again;
	tr839:  sm->cs = 258; goto _again;
	tr292:  sm->cs = 259; goto _again;
	tr293:  sm->cs = 260; goto _again;
	tr294:  sm->cs = 261; goto _again;
	tr295:  sm->cs = 262; goto _again;
	tr296:  sm->cs = 263; goto _again;
	tr297:  sm->cs = 264; goto _again;
	tr840:  sm->cs = 265; goto _again;
	tr300:  sm->cs = 266; goto _again;
	tr302:  sm->cs = 267; goto _again;
	tr303:  sm->cs = 268; goto _again;
	tr304:  sm->cs = 269; goto _again;
	tr305:  sm->cs = 270; goto _again;
	tr306:  sm->cs = 271; goto _again;
	tr308:  sm->cs = 272; goto _again;
	tr301:  sm->cs = 273; goto _again;
	tr309:  sm->cs = 274; goto _again;
	tr310:  sm->cs = 275; goto _again;
	tr311:  sm->cs = 276; goto _again;
	tr312:  sm->cs = 277; goto _again;
	tr841:  sm->cs = 278; goto _again;
	tr313:  sm->cs = 279; goto _again;
	tr842:  sm->cs = 280; goto _again;
	tr843:  sm->cs = 281; goto _again;
	tr316:  sm->cs = 282; goto _again;
	tr317:  sm->cs = 283; goto _again;
	tr318:  sm->cs = 284; goto _again;
	tr319:  sm->cs = 285; goto _again;
	tr321:  sm->cs = 286; goto _again;
	tr322:  sm->cs = 287; goto _again;
	tr323:  sm->cs = 288; goto _again;
	tr326:  sm->cs = 289; goto _again;
	tr324:  sm->cs = 290; goto _again;
	tr325:  sm->cs = 291; goto _again;
	tr320:  sm->cs = 292; goto _again;
	tr329:  sm->cs = 293; goto _again;
	tr845:  sm->cs = 293; goto f9;
	tr330:  sm->cs = 294; goto _again;
	tr846:  sm->cs = 294; goto f9;
	tr850:  sm->cs = 295; goto _again;
	tr847:  sm->cs = 295; goto f9;
	tr853:  sm->cs = 296; goto _again;
	tr331:  sm->cs = 297; goto _again;
	tr332:  sm->cs = 298; goto _again;
	tr333:  sm->cs = 299; goto _again;
	tr334:  sm->cs = 300; goto _again;
	tr335:  sm->cs = 301; goto _again;
	tr854:  sm->cs = 302; goto _again;
	tr337:  sm->cs = 303; goto _again;
	tr338:  sm->cs = 304; goto _again;
	tr339:  sm->cs = 305; goto _again;
	tr340:  sm->cs = 306; goto _again;
	tr341:  sm->cs = 307; goto _again;
	tr342:  sm->cs = 308; goto _again;
	tr855:  sm->cs = 309; goto _again;
	tr344:  sm->cs = 310; goto _again;
	tr345:  sm->cs = 311; goto _again;
	tr347:  sm->cs = 312; goto _again;
	tr348:  sm->cs = 313; goto _again;
	tr349:  sm->cs = 314; goto _again;
	tr350:  sm->cs = 315; goto _again;
	tr346:  sm->cs = 316; goto _again;
	tr352:  sm->cs = 317; goto _again;
	tr353:  sm->cs = 318; goto _again;
	tr354:  sm->cs = 319; goto _again;
	tr355:  sm->cs = 320; goto _again;
	tr356:  sm->cs = 321; goto _again;
	tr357:  sm->cs = 322; goto _again;
	tr358:  sm->cs = 323; goto _again;
	tr359:  sm->cs = 324; goto _again;
	tr864:  sm->cs = 325; goto _again;
	tr361:  sm->cs = 326; goto _again;
	tr362:  sm->cs = 327; goto _again;
	tr363:  sm->cs = 328; goto _again;
	tr865:  sm->cs = 329; goto _again;
	tr365:  sm->cs = 330; goto _again;
	tr366:  sm->cs = 331; goto _again;
	tr367:  sm->cs = 332; goto _again;
	tr870:  sm->cs = 333; goto _again;
	tr369:  sm->cs = 334; goto _again;
	tr370:  sm->cs = 335; goto _again;
	tr371:  sm->cs = 336; goto _again;
	tr373:  sm->cs = 337; goto _again;
	tr374:  sm->cs = 338; goto _again;
	tr375:  sm->cs = 339; goto _again;
	tr376:  sm->cs = 340; goto _again;
	tr372:  sm->cs = 341; goto _again;
	tr378:  sm->cs = 342; goto _again;
	tr379:  sm->cs = 343; goto _again;
	tr380:  sm->cs = 344; goto _again;
	tr875:  sm->cs = 345; goto _again;
	tr382:  sm->cs = 346; goto _again;
	tr383:  sm->cs = 347; goto _again;
	tr384:  sm->cs = 348; goto _again;
	tr385:  sm->cs = 349; goto _again;
	tr386:  sm->cs = 350; goto _again;
	tr387:  sm->cs = 351; goto _again;
	tr388:  sm->cs = 352; goto _again;
	tr389:  sm->cs = 353; goto _again;
	tr390:  sm->cs = 354; goto _again;
	tr391:  sm->cs = 355; goto _again;
	tr876:  sm->cs = 356; goto _again;
	tr393:  sm->cs = 357; goto _again;
	tr394:  sm->cs = 358; goto _again;
	tr395:  sm->cs = 359; goto _again;
	tr396:  sm->cs = 360; goto _again;
	tr397:  sm->cs = 361; goto _again;
	tr880:  sm->cs = 362; goto f4;
	tr884:  sm->cs = 363; goto _again;
	tr401:  sm->cs = 364; goto _again;
	tr402:  sm->cs = 365; goto _again;
	tr403:  sm->cs = 366; goto _again;
	tr404:  sm->cs = 367; goto _again;
	tr405:  sm->cs = 368; goto _again;
	tr406:  sm->cs = 369; goto _again;
	tr407:  sm->cs = 370; goto _again;
	tr408:  sm->cs = 371; goto _again;
	tr885:  sm->cs = 372; goto _again;
	tr410:  sm->cs = 373; goto _again;
	tr411:  sm->cs = 374; goto _again;
	tr412:  sm->cs = 375; goto _again;
	tr413:  sm->cs = 376; goto _again;
	tr414:  sm->cs = 377; goto _again;
	tr415:  sm->cs = 378; goto _again;
	tr416:  sm->cs = 379; goto _again;
	tr417:  sm->cs = 380; goto _again;
	tr886:  sm->cs = 381; goto _again;
	tr419:  sm->cs = 382; goto _again;
	tr420:  sm->cs = 383; goto _again;
	tr421:  sm->cs = 384; goto _again;
	tr422:  sm->cs = 385; goto _again;
	tr887:  sm->cs = 386; goto _again;
	tr424:  sm->cs = 387; goto _again;
	tr425:  sm->cs = 388; goto _again;
	tr426:  sm->cs = 389; goto _again;
	tr427:  sm->cs = 390; goto _again;
	tr428:  sm->cs = 391; goto _again;
	tr896:  sm->cs = 392; goto _again;
	tr430:  sm->cs = 393; goto _again;
	tr431:  sm->cs = 394; goto _again;
	tr432:  sm->cs = 395; goto _again;
	tr433:  sm->cs = 396; goto _again;
	tr434:  sm->cs = 397; goto _again;
	tr435:  sm->cs = 398; goto _again;
	tr436:  sm->cs = 399; goto _again;
	tr437:  sm->cs = 400; goto _again;
	tr899:  sm->cs = 401; goto _again;
	tr439:  sm->cs = 402; goto _again;
	tr440:  sm->cs = 403; goto _again;
	tr441:  sm->cs = 404; goto _again;
	tr442:  sm->cs = 405; goto _again;
	tr443:  sm->cs = 406; goto _again;
	tr444:  sm->cs = 407; goto _again;
	tr445:  sm->cs = 408; goto _again;
	tr446:  sm->cs = 409; goto _again;
	tr447:  sm->cs = 410; goto _again;
	tr448:  sm->cs = 411; goto _again;
	tr449:  sm->cs = 412; goto _again;
	tr900:  sm->cs = 413; goto _again;
	tr451:  sm->cs = 414; goto _again;
	tr452:  sm->cs = 415; goto _again;
	tr453:  sm->cs = 416; goto _again;
	tr454:  sm->cs = 417; goto _again;
	tr455:  sm->cs = 418; goto _again;
	tr905:  sm->cs = 419; goto _again;
	tr457:  sm->cs = 420; goto _again;
	tr458:  sm->cs = 421; goto _again;
	tr460:  sm->cs = 422; goto _again;
	tr461:  sm->cs = 423; goto _again;
	tr462:  sm->cs = 424; goto _again;
	tr463:  sm->cs = 425; goto _again;
	tr464:  sm->cs = 426; goto _again;
	tr465:  sm->cs = 427; goto _again;
	tr466:  sm->cs = 428; goto _again;
	tr467:  sm->cs = 429; goto _again;
	tr459:  sm->cs = 430; goto _again;
	tr469:  sm->cs = 431; goto _again;
	tr470:  sm->cs = 432; goto _again;
	tr471:  sm->cs = 433; goto _again;
	tr472:  sm->cs = 434; goto _again;
	tr473:  sm->cs = 435; goto _again;
	tr474:  sm->cs = 436; goto _again;
	tr475:  sm->cs = 437; goto _again;
	tr910:  sm->cs = 438; goto _again;
	tr477:  sm->cs = 439; goto _again;
	tr478:  sm->cs = 440; goto _again;
	tr479:  sm->cs = 441; goto _again;
	tr480:  sm->cs = 442; goto _again;
	tr481:  sm->cs = 443; goto _again;
	tr911:  sm->cs = 444; goto _again;
	tr483:  sm->cs = 445; goto _again;
	tr484:  sm->cs = 446; goto _again;
	tr485:  sm->cs = 447; goto _again;
	tr486:  sm->cs = 448; goto _again;
	tr916:  sm->cs = 449; goto _again;
	tr488:  sm->cs = 450; goto _again;
	tr489:  sm->cs = 451; goto _again;
	tr490:  sm->cs = 452; goto _again;
	tr491:  sm->cs = 453; goto _again;
	tr492:  sm->cs = 454; goto _again;
	tr917:  sm->cs = 455; goto _again;
	tr494:  sm->cs = 456; goto _again;
	tr495:  sm->cs = 457; goto _again;
	tr496:  sm->cs = 458; goto _again;
	tr497:  sm->cs = 459; goto _again;
	tr498:  sm->cs = 460; goto _again;
	tr923:  sm->cs = 461; goto f4;
	tr501:  sm->cs = 462; goto _again;
	tr918:  sm->cs = 463; goto _again;
	tr503:  sm->cs = 464; goto _again;
	tr505:  sm->cs = 465; goto _again;
	tr506:  sm->cs = 466; goto _again;
	tr507:  sm->cs = 467; goto _again;
	tr504:  sm->cs = 468; goto _again;
	tr509:  sm->cs = 469; goto _again;
	tr510:  sm->cs = 470; goto _again;
	tr511:  sm->cs = 471; goto _again;
	tr919:  sm->cs = 472; goto _again;
	tr513:  sm->cs = 473; goto _again;
	tr514:  sm->cs = 474; goto _again;
	tr515:  sm->cs = 475; goto _again;
	tr516:  sm->cs = 476; goto _again;
	tr933:  sm->cs = 477; goto _again;
	tr518:  sm->cs = 478; goto _again;
	tr519:  sm->cs = 479; goto _again;
	tr520:  sm->cs = 480; goto _again;
	tr521:  sm->cs = 481; goto _again;
	tr522:  sm->cs = 482; goto _again;
	tr523:  sm->cs = 483; goto _again;
	tr524:  sm->cs = 484; goto _again;
	tr934:  sm->cs = 485; goto _again;
	tr526:  sm->cs = 486; goto _again;
	tr527:  sm->cs = 487; goto _again;
	tr528:  sm->cs = 488; goto _again;
	tr529:  sm->cs = 489; goto _again;
	tr530:  sm->cs = 490; goto _again;
	tr939:  sm->cs = 491; goto _again;
	tr532:  sm->cs = 492; goto _again;
	tr533:  sm->cs = 493; goto _again;
	tr534:  sm->cs = 494; goto _again;
	tr535:  sm->cs = 495; goto _again;
	tr536:  sm->cs = 496; goto _again;
	tr942:  sm->cs = 497; goto f4;
	tr539:  sm->cs = 498; goto _again;
	tr940:  sm->cs = 499; goto _again;
	tr541:  sm->cs = 500; goto _again;
	tr542:  sm->cs = 501; goto _again;
	tr543:  sm->cs = 502; goto _again;
	tr544:  sm->cs = 503; goto _again;
	tr545:  sm->cs = 504; goto _again;
	tr546:  sm->cs = 505; goto _again;
	tr547:  sm->cs = 506; goto _again;
	tr948:  sm->cs = 507; goto _again;
	tr549:  sm->cs = 508; goto _again;
	tr550:  sm->cs = 509; goto _again;
	tr551:  sm->cs = 510; goto _again;
	tr552:  sm->cs = 511; goto _again;
	tr951:  sm->cs = 512; goto _again;
	tr554:  sm->cs = 513; goto _again;
	tr555:  sm->cs = 514; goto _again;
	tr556:  sm->cs = 515; goto _again;
	tr557:  sm->cs = 516; goto _again;
	tr954:  sm->cs = 517; goto _again;
	tr559:  sm->cs = 518; goto _again;
	tr560:  sm->cs = 519; goto _again;
	tr561:  sm->cs = 520; goto _again;
	tr562:  sm->cs = 521; goto _again;
	tr563:  sm->cs = 522; goto _again;
	tr564:  sm->cs = 523; goto _again;
	tr565:  sm->cs = 524; goto _again;
	tr957:  sm->cs = 525; goto _again;
	tr567:  sm->cs = 526; goto _again;
	tr568:  sm->cs = 527; goto _again;
	tr574:  sm->cs = 528; goto _again;
	tr575:  sm->cs = 529; goto _again;
	tr576:  sm->cs = 530; goto _again;
	tr577:  sm->cs = 531; goto _again;
	tr578:  sm->cs = 532; goto _again;
	tr569:  sm->cs = 533; goto _again;
	tr570:  sm->cs = 534; goto _again;
	tr579:  sm->cs = 535; goto _again;
	tr580:  sm->cs = 536; goto _again;
	tr581:  sm->cs = 537; goto _again;
	tr582:  sm->cs = 538; goto _again;
	tr571:  sm->cs = 539; goto _again;
	tr583:  sm->cs = 540; goto _again;
	tr584:  sm->cs = 541; goto _again;
	tr585:  sm->cs = 542; goto _again;
	tr586:  sm->cs = 543; goto _again;
	tr587:  sm->cs = 544; goto _again;
	tr588:  sm->cs = 545; goto _again;
	tr589:  sm->cs = 546; goto _again;
	tr572:  sm->cs = 547; goto _again;
	tr590:  sm->cs = 548; goto _again;
	tr591:  sm->cs = 549; goto _again;
	tr592:  sm->cs = 550; goto _again;
	tr573:  sm->cs = 551; goto _again;
	tr958:  sm->cs = 552; goto _again;
	tr959:  sm->cs = 553; goto _again;
	tr593:  sm->cs = 554; goto _again;
	tr594:  sm->cs = 555; goto _again;
	tr595:  sm->cs = 556; goto _again;
	tr960:  sm->cs = 557; goto _again;
	tr596:  sm->cs = 558; goto _again;
	tr597:  sm->cs = 559; goto _again;
	tr598:  sm->cs = 560; goto _again;
	tr599:  sm->cs = 561; goto _again;
	tr600:  sm->cs = 562; goto _again;
	tr961:  sm->cs = 563; goto _again;
	tr962:  sm->cs = 564; goto _again;
	tr601:  sm->cs = 565; goto _again;
	tr602:  sm->cs = 566; goto _again;
	tr603:  sm->cs = 567; goto _again;
	tr604:  sm->cs = 568; goto _again;
	tr605:  sm->cs = 569; goto _again;
	tr606:  sm->cs = 570; goto _again;
	tr963:  sm->cs = 571; goto _again;
	tr607:  sm->cs = 572; goto _again;
	tr608:  sm->cs = 573; goto _again;
	tr609:  sm->cs = 574; goto _again;
	tr610:  sm->cs = 575; goto _again;
	tr964:  sm->cs = 576; goto _again;
	tr611:  sm->cs = 577; goto _again;
	tr612:  sm->cs = 578; goto _again;
	tr613:  sm->cs = 579; goto _again;
	tr614:  sm->cs = 580; goto _again;
	tr615:  sm->cs = 581; goto _again;
	tr616:  sm->cs = 582; goto _again;
	tr617:  sm->cs = 583; goto _again;
	tr965:  sm->cs = 584; goto _again;
	tr618:  sm->cs = 585; goto _again;
	tr966:  sm->cs = 586; goto _again;
	tr967:  sm->cs = 587; goto f9;
	tr619:  sm->cs = 588; goto _again;
	tr620:  sm->cs = 589; goto _again;
	tr621:  sm->cs = 590; goto _again;
	tr622:  sm->cs = 591; goto _again;
	tr624:  sm->cs = 592; goto _again;
	tr625:  sm->cs = 593; goto _again;
	tr626:  sm->cs = 594; goto _again;
	tr629:  sm->cs = 595; goto _again;
	tr627:  sm->cs = 596; goto _again;
	tr628:  sm->cs = 597; goto _again;
	tr630:  sm->cs = 598; goto f4;
	tr631:  sm->cs = 599; goto _again;
	tr633:  sm->cs = 600; goto _again;
	tr632:  sm->cs = 600; goto f3;
	tr623:  sm->cs = 601; goto _again;
	tr968:  sm->cs = 602; goto _again;
	tr635:  sm->cs = 603; goto _again;
	tr636:  sm->cs = 604; goto _again;
	tr637:  sm->cs = 605; goto _again;
	tr639:  sm->cs = 606; goto _again;
	tr640:  sm->cs = 607; goto _again;
	tr641:  sm->cs = 608; goto _again;
	tr642:  sm->cs = 609; goto _again;
	tr643:  sm->cs = 610; goto _again;
	tr638:  sm->cs = 611; goto _again;
	tr970:  sm->cs = 612; goto _again;
	tr646:  sm->cs = 613; goto _again;
	tr645:  sm->cs = 613; goto f9;
	tr647:  sm->cs = 614; goto f4;
	tr975:  sm->cs = 615; goto _again;
	tr650:  sm->cs = 616; goto _again;
	tr651:  sm->cs = 617; goto _again;
	tr652:  sm->cs = 618; goto _again;
	tr653:  sm->cs = 619; goto _again;
	tr976:  sm->cs = 620; goto _again;
	tr655:  sm->cs = 621; goto _again;
	tr656:  sm->cs = 622; goto _again;
	tr657:  sm->cs = 623; goto _again;
	tr658:  sm->cs = 624; goto _again;
	tr981:  sm->cs = 625; goto _again;
	tr660:  sm->cs = 626; goto _again;
	tr661:  sm->cs = 627; goto _again;
	tr662:  sm->cs = 628; goto _again;
	tr663:  sm->cs = 629; goto _again;
	tr664:  sm->cs = 630; goto _again;
	tr665:  sm->cs = 631; goto _again;
	tr666:  sm->cs = 632; goto _again;
	tr982:  sm->cs = 633; goto _again;
	tr668:  sm->cs = 634; goto _again;
	tr669:  sm->cs = 635; goto _again;
	tr670:  sm->cs = 636; goto _again;
	tr671:  sm->cs = 637; goto _again;
	tr672:  sm->cs = 638; goto _again;
	tr673:  sm->cs = 639; goto _again;
	tr674:  sm->cs = 640; goto _again;
	tr987:  sm->cs = 641; goto _again;
	tr676:  sm->cs = 642; goto _again;
	tr677:  sm->cs = 643; goto _again;
	tr681:  sm->cs = 644; goto _again;
	tr682:  sm->cs = 645; goto _again;
	tr683:  sm->cs = 646; goto _again;
	tr678:  sm->cs = 647; goto _again;
	tr685:  sm->cs = 648; goto _again;
	tr686:  sm->cs = 649; goto _again;
	tr687:  sm->cs = 650; goto _again;
	tr679:  sm->cs = 651; goto _again;
	tr689:  sm->cs = 652; goto _again;
	tr690:  sm->cs = 653; goto _again;
	tr691:  sm->cs = 654; goto _again;
	tr680:  sm->cs = 655; goto _again;
	tr988:  sm->cs = 656; goto _again;
	tr694:  sm->cs = 657; goto _again;
	tr698:  sm->cs = 658; goto _again;
	tr699:  sm->cs = 659; goto _again;
	tr700:  sm->cs = 660; goto _again;
	tr695:  sm->cs = 661; goto _again;
	tr696:  sm->cs = 662; goto _again;
	tr704:  sm->cs = 663; goto _again;
	tr705:  sm->cs = 664; goto _again;
	tr706:  sm->cs = 665; goto _again;
	tr697:  sm->cs = 666; goto _again;
	tr989:  sm->cs = 667; goto _again;
	tr709:  sm->cs = 668; goto _again;
	tr710:  sm->cs = 669; goto _again;
	tr714:  sm->cs = 670; goto _again;
	tr715:  sm->cs = 671; goto _again;
	tr716:  sm->cs = 672; goto _again;
	tr711:  sm->cs = 673; goto _again;
	tr717:  sm->cs = 674; goto _again;
	tr718:  sm->cs = 675; goto _again;
	tr719:  sm->cs = 676; goto _again;
	tr712:  sm->cs = 677; goto _again;
	tr720:  sm->cs = 678; goto _again;
	tr721:  sm->cs = 679; goto _again;
	tr722:  sm->cs = 680; goto _again;
	tr713:  sm->cs = 681; goto _again;
	tr990:  sm->cs = 682; goto _again;
	tr723:  sm->cs = 683; goto _again;
	tr727:  sm->cs = 684; goto _again;
	tr728:  sm->cs = 685; goto _again;
	tr729:  sm->cs = 686; goto _again;
	tr724:  sm->cs = 687; goto _again;
	tr725:  sm->cs = 688; goto _again;
	tr730:  sm->cs = 689; goto _again;
	tr731:  sm->cs = 690; goto _again;
	tr732:  sm->cs = 691; goto _again;
	tr726:  sm->cs = 692; goto _again;
	tr995:  sm->cs = 693; goto _again;
	tr738:  sm->cs = 694; goto f4;
	tr739:  sm->cs = 695; goto _again;
	tr0:  sm->cs = 696; goto f0;
	tr2:  sm->cs = 696; goto f2;
	tr14:  sm->cs = 696; goto f5;
	tr56:  sm->cs = 696; goto f6;
	tr57:  sm->cs = 696; goto f7;
	tr740:  sm->cs = 696; goto f77;
	tr748:  sm->cs = 696; goto f80;
	tr749:  sm->cs = 696; goto f81;
	tr758:  sm->cs = 696; goto f82;
	tr759:  sm->cs = 696; goto f83;
	tr760:  sm->cs = 696; goto f84;
	tr761:  sm->cs = 696; goto f85;
	tr762:  sm->cs = 696; goto f86;
	tr764:  sm->cs = 696; goto f87;
	tr766:  sm->cs = 696; goto f88;
	tr775:  sm->cs = 696; goto f89;
	tr1:  sm->cs = 697; goto f1;
	tr741:  sm->cs = 697; goto f78;
	tr742:  sm->cs = 698; goto _again;
	tr743:  sm->cs = 699; goto f51;
	tr750:  sm->cs = 700; goto _again;
	tr3:  sm->cs = 700; goto f3;
	tr4:  sm->cs = 701; goto f3;
	tr744:  sm->cs = 702; goto f79;
	tr25:  sm->cs = 703; goto _again;
	tr29:  sm->cs = 704; goto _again;
	tr35:  sm->cs = 705; goto _again;
	tr42:  sm->cs = 706; goto _again;
	tr49:  sm->cs = 707; goto _again;
	tr745:  sm->cs = 708; goto f79;
	tr765:  sm->cs = 709; goto _again;
	tr62:  sm->cs = 709; goto f8;
	tr767:  sm->cs = 710; goto _again;
	tr59:  sm->cs = 710; goto f4;
	tr746:  sm->cs = 711; goto f79;
	tr776:  sm->cs = 712; goto _again;
	tr82:  sm->cs = 712; goto f4;
	tr105:  sm->cs = 713; goto f10;
	tr111:  sm->cs = 713; goto f11;
	tr112:  sm->cs = 713; goto f12;
	tr113:  sm->cs = 713; goto f13;
	tr118:  sm->cs = 713; goto f14;
	tr119:  sm->cs = 713; goto f15;
	tr121:  sm->cs = 713; goto f16;
	tr122:  sm->cs = 713; goto f17;
	tr128:  sm->cs = 713; goto f18;
	tr777:  sm->cs = 713; goto f90;
	tr780:  sm->cs = 713; goto f91;
	tr778:  sm->cs = 714; goto f79;
	tr779:  sm->cs = 715; goto f79;
	tr133:  sm->cs = 716; goto f19;
	tr135:  sm->cs = 716; goto f21;
	tr140:  sm->cs = 716; goto f22;
	tr157:  sm->cs = 716; goto f24;
	tr194:  sm->cs = 716; goto f28;
	tr205:  sm->cs = 716; goto f29;
	tr210:  sm->cs = 716; goto f30;
	tr211:  sm->cs = 716; goto f31;
	tr219:  sm->cs = 716; goto f32;
	tr228:  sm->cs = 716; goto f33;
	tr229:  sm->cs = 716; goto f34;
	tr230:  sm->cs = 716; goto f35;
	tr231:  sm->cs = 716; goto f36;
	tr240:  sm->cs = 716; goto f37;
	tr261:  sm->cs = 716; goto f38;
	tr269:  sm->cs = 716; goto f39;
	tr279:  sm->cs = 716; goto f40;
	tr283:  sm->cs = 716; goto f41;
	tr286:  sm->cs = 716; goto f42;
	tr291:  sm->cs = 716; goto f43;
	tr298:  sm->cs = 716; goto f44;
	tr299:  sm->cs = 716; goto f45;
	tr307:  sm->cs = 716; goto f46;
	tr314:  sm->cs = 716; goto f47;
	tr315:  sm->cs = 716; goto f48;
	tr327:  sm->cs = 716; goto f49;
	tr399:  sm->cs = 716; goto f52;
	tr500:  sm->cs = 716; goto f53;
	tr538:  sm->cs = 716; goto f54;
	tr634:  sm->cs = 716; goto f55;
	tr648:  sm->cs = 716; goto f57;
	tr790:  sm->cs = 716; goto f92;
	tr815:  sm->cs = 716; goto f97;
	tr818:  sm->cs = 716; goto f98;
	tr819:  sm->cs = 716; goto f99;
	tr821:  sm->cs = 716; goto f100;
	tr822:  sm->cs = 716; goto f101;
	tr824:  sm->cs = 716; goto f102;
	tr825:  sm->cs = 716; goto f103;
	tr827:  sm->cs = 716; goto f104;
	tr829:  sm->cs = 716; goto f105;
	tr831:  sm->cs = 716; goto f107;
	tr844:  sm->cs = 716; goto f108;
	tr849:  sm->cs = 716; goto f110;
	tr851:  sm->cs = 716; goto f111;
	tr856:  sm->cs = 716; goto f113;
	tr858:  sm->cs = 716; goto f114;
	tr860:  sm->cs = 716; goto f115;
	tr862:  sm->cs = 716; goto f116;
	tr866:  sm->cs = 716; goto f117;
	tr868:  sm->cs = 716; goto f118;
	tr871:  sm->cs = 716; goto f119;
	tr873:  sm->cs = 716; goto f120;
	tr877:  sm->cs = 716; goto f121;
	tr879:  sm->cs = 716; goto f122;
	tr882:  sm->cs = 716; goto f123;
	tr888:  sm->cs = 716; goto f124;
	tr890:  sm->cs = 716; goto f125;
	tr892:  sm->cs = 716; goto f126;
	tr894:  sm->cs = 716; goto f127;
	tr897:  sm->cs = 716; goto f128;
	tr901:  sm->cs = 716; goto f129;
	tr903:  sm->cs = 716; goto f130;
	tr906:  sm->cs = 716; goto f131;
	tr908:  sm->cs = 716; goto f132;
	tr912:  sm->cs = 716; goto f133;
	tr914:  sm->cs = 716; goto f134;
	tr920:  sm->cs = 716; goto f135;
	tr922:  sm->cs = 716; goto f136;
	tr925:  sm->cs = 716; goto f137;
	tr927:  sm->cs = 716; goto f138;
	tr929:  sm->cs = 716; goto f139;
	tr931:  sm->cs = 716; goto f140;
	tr935:  sm->cs = 716; goto f141;
	tr937:  sm->cs = 716; goto f142;
	tr941:  sm->cs = 716; goto f143;
	tr944:  sm->cs = 716; goto f144;
	tr946:  sm->cs = 716; goto f145;
	tr949:  sm->cs = 716; goto f146;
	tr952:  sm->cs = 716; goto f147;
	tr955:  sm->cs = 716; goto f148;
	tr969:  sm->cs = 716; goto f149;
	tr791:  sm->cs = 717; goto f93;
	tr134:  sm->cs = 718; goto f20;
	tr820:  sm->cs = 719; goto _again;
	tr138:  sm->cs = 719; goto f3;
	tr139:  sm->cs = 720; goto f3;
	tr792:  sm->cs = 721; goto _again;
	tr793:  sm->cs = 722; goto f94;
	tr150:  sm->cs = 723; goto f23;
	tr794:  sm->cs = 724; goto f51;
	tr180:  sm->cs = 725; goto _again;
	tr828:  sm->cs = 726; goto _again;
	tr826:  sm->cs = 726; goto f25;
	tr185:  sm->cs = 727; goto _again;
	tr832:  sm->cs = 728; goto _again;
	tr830:  sm->cs = 728; goto f106;
	tr795:  sm->cs = 729; goto f79;
	tr203:  sm->cs = 730; goto _again;
	tr796:  sm->cs = 731; goto f94;
	tr328:  sm->cs = 732; goto f50;
	tr852:  sm->cs = 732; goto f112;
	tr848:  sm->cs = 733; goto f109;
	tr797:  sm->cs = 734; goto f51;
	tr857:  sm->cs = 735; goto _again;
	tr336:  sm->cs = 735; goto f9;
	tr859:  sm->cs = 736; goto _again;
	tr343:  sm->cs = 736; goto f9;
	tr861:  sm->cs = 737; goto _again;
	tr351:  sm->cs = 737; goto f9;
	tr863:  sm->cs = 738; goto _again;
	tr360:  sm->cs = 738; goto f9;
	tr798:  sm->cs = 739; goto f51;
	tr867:  sm->cs = 740; goto _again;
	tr364:  sm->cs = 740; goto f9;
	tr869:  sm->cs = 741; goto _again;
	tr368:  sm->cs = 741; goto f9;
	tr799:  sm->cs = 742; goto f51;
	tr872:  sm->cs = 743; goto _again;
	tr377:  sm->cs = 743; goto f9;
	tr874:  sm->cs = 744; goto _again;
	tr381:  sm->cs = 744; goto f9;
	tr800:  sm->cs = 745; goto f51;
	tr878:  sm->cs = 746; goto _again;
	tr392:  sm->cs = 746; goto f9;
	tr398:  sm->cs = 747; goto f51;
	tr881:  sm->cs = 747; goto f79;
	tr883:  sm->cs = 748; goto _again;
	tr400:  sm->cs = 748; goto f3;
	tr801:  sm->cs = 749; goto f51;
	tr889:  sm->cs = 750; goto _again;
	tr409:  sm->cs = 750; goto f9;
	tr891:  sm->cs = 751; goto _again;
	tr418:  sm->cs = 751; goto f9;
	tr893:  sm->cs = 752; goto _again;
	tr423:  sm->cs = 752; goto f9;
	tr895:  sm->cs = 753; goto _again;
	tr429:  sm->cs = 753; goto f9;
	tr802:  sm->cs = 754; goto f51;
	tr898:  sm->cs = 755; goto _again;
	tr438:  sm->cs = 755; goto f9;
	tr803:  sm->cs = 756; goto f51;
	tr902:  sm->cs = 757; goto _again;
	tr450:  sm->cs = 757; goto f9;
	tr904:  sm->cs = 758; goto _again;
	tr456:  sm->cs = 758; goto f9;
	tr804:  sm->cs = 759; goto f51;
	tr907:  sm->cs = 760; goto _again;
	tr468:  sm->cs = 760; goto f9;
	tr909:  sm->cs = 761; goto _again;
	tr476:  sm->cs = 761; goto f9;
	tr805:  sm->cs = 762; goto f51;
	tr913:  sm->cs = 763; goto _again;
	tr482:  sm->cs = 763; goto f9;
	tr915:  sm->cs = 764; goto _again;
	tr487:  sm->cs = 764; goto f9;
	tr806:  sm->cs = 765; goto f51;
	tr921:  sm->cs = 766; goto _again;
	tr493:  sm->cs = 766; goto f9;
	tr499:  sm->cs = 767; goto f51;
	tr924:  sm->cs = 767; goto f79;
	tr926:  sm->cs = 768; goto _again;
	tr502:  sm->cs = 768; goto f3;
	tr928:  sm->cs = 769; goto _again;
	tr508:  sm->cs = 769; goto f9;
	tr930:  sm->cs = 770; goto _again;
	tr512:  sm->cs = 770; goto f9;
	tr932:  sm->cs = 771; goto _again;
	tr517:  sm->cs = 771; goto f9;
	tr807:  sm->cs = 772; goto f51;
	tr936:  sm->cs = 773; goto _again;
	tr525:  sm->cs = 773; goto f9;
	tr938:  sm->cs = 774; goto _again;
	tr531:  sm->cs = 774; goto f9;
	tr808:  sm->cs = 775; goto f51;
	tr537:  sm->cs = 776; goto f51;
	tr943:  sm->cs = 776; goto f79;
	tr945:  sm->cs = 777; goto _again;
	tr540:  sm->cs = 777; goto f3;
	tr947:  sm->cs = 778; goto _again;
	tr548:  sm->cs = 778; goto f9;
	tr809:  sm->cs = 779; goto f51;
	tr950:  sm->cs = 780; goto _again;
	tr553:  sm->cs = 780; goto f9;
	tr810:  sm->cs = 781; goto f51;
	tr953:  sm->cs = 782; goto _again;
	tr558:  sm->cs = 782; goto f9;
	tr811:  sm->cs = 783; goto f51;
	tr956:  sm->cs = 784; goto _again;
	tr566:  sm->cs = 784; goto f9;
	tr812:  sm->cs = 785; goto f95;
	tr813:  sm->cs = 786; goto f96;
	tr644:  sm->cs = 787; goto f56;
	tr814:  sm->cs = 788; goto f79;
	tr649:  sm->cs = 789; goto f58;
	tr654:  sm->cs = 789; goto f59;
	tr971:  sm->cs = 789; goto f150;
	tr974:  sm->cs = 789; goto f151;
	tr972:  sm->cs = 790; goto f79;
	tr973:  sm->cs = 791; goto f79;
	tr659:  sm->cs = 792; goto f60;
	tr667:  sm->cs = 792; goto f61;
	tr977:  sm->cs = 792; goto f152;
	tr980:  sm->cs = 792; goto f153;
	tr978:  sm->cs = 793; goto f79;
	tr979:  sm->cs = 794; goto f79;
	tr675:  sm->cs = 795; goto f62;
	tr684:  sm->cs = 795; goto f63;
	tr688:  sm->cs = 795; goto f64;
	tr692:  sm->cs = 795; goto f65;
	tr693:  sm->cs = 795; goto f66;
	tr701:  sm->cs = 795; goto f67;
	tr702:  sm->cs = 795; goto f68;
	tr703:  sm->cs = 795; goto f69;
	tr707:  sm->cs = 795; goto f70;
	tr708:  sm->cs = 795; goto f71;
	tr983:  sm->cs = 795; goto f154;
	tr986:  sm->cs = 795; goto f155;
	tr984:  sm->cs = 796; goto f79;
	tr985:  sm->cs = 797; goto f79;
	tr733:  sm->cs = 798; goto f72;
	tr735:  sm->cs = 798; goto f74;
	tr991:  sm->cs = 798; goto f156;
	tr996:  sm->cs = 798; goto f158;
	tr997:  sm->cs = 798; goto f159;
	tr734:  sm->cs = 799; goto f73;
	tr992:  sm->cs = 799; goto f157;
	tr993:  sm->cs = 800; goto _again;
	tr994:  sm->cs = 801; goto f51;
	tr998:  sm->cs = 802; goto _again;
	tr736:  sm->cs = 802; goto f3;
	tr737:  sm->cs = 803; goto f3;

f9:
#line 72 "ext/dtext/dtext.rl"
	{
  sm->a1 = sm->p;
}
	goto _again;
f4:
#line 76 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
	goto _again;
f3:
#line 80 "ext/dtext/dtext.rl"
	{
  sm->b1 = sm->p;
}
	goto _again;
f8:
#line 84 "ext/dtext/dtext.rl"
	{
  sm->b2 = sm->p;
}
	goto _again;
f25:
#line 88 "ext/dtext/dtext.rl"
	{
  sm->c1 = sm->p;
}
	goto _again;
f27:
#line 92 "ext/dtext/dtext.rl"
	{
  sm->c2 = sm->p;
}
	goto _again;
f106:
#line 96 "ext/dtext/dtext.rl"
	{
  sm->d1 = sm->p;
}
	goto _again;
f79:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
	goto _again;
f15:
#line 186 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{ dstack_open_inline(sm,  INLINE_B, "<strong>"); }}
	goto _again;
f11:
#line 187 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{ dstack_close_inline(sm, INLINE_B, "</strong>"); }}
	goto _again;
f16:
#line 188 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{ dstack_open_inline(sm,  INLINE_I, "<em>"); }}
	goto _again;
f12:
#line 189 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{ dstack_close_inline(sm, INLINE_I, "</em>"); }}
	goto _again;
f17:
#line 190 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{ dstack_open_inline(sm,  INLINE_S, "<s>"); }}
	goto _again;
f13:
#line 191 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{ dstack_close_inline(sm, INLINE_S, "</s>"); }}
	goto _again;
f18:
#line 192 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{ dstack_open_inline(sm,  INLINE_U, "<u>"); }}
	goto _again;
f14:
#line 193 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{ dstack_close_inline(sm, INLINE_U, "</u>"); }}
	goto _again;
f90:
#line 194 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{ append_c_html_escaped(sm, (*( sm->p))); }}
	goto _again;
f91:
#line 194 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{ append_c_html_escaped(sm, (*( sm->p))); }}
	goto _again;
f10:
#line 194 "ext/dtext/dtext.rl"
	{{( sm->p) = ((( sm->te)))-1;}{ append_c_html_escaped(sm, (*( sm->p))); }}
	goto _again;
f57:
#line 239 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    append(sm, "<a class=\"dtext-link dtext-post-search-link\" href=\"");
    append_url(sm, "/posts?tags=");
    append_segment_uri_escaped(sm, sm->a1, sm->a2 - 1);
    append(sm, "\">");
    append_segment_html_escaped(sm, sm->a1, sm->a2 - 1);
    append(sm, "</a>");
  }}
	goto _again;
f24:
#line 270 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    if (!append_named_url(sm, sm->b1, sm->b2, sm->a1, sm->a2)) {
      {( sm->p)++; goto _out; }
    }
  }}
	goto _again;
f38:
#line 276 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    if (!append_named_url(sm, sm->a1, sm->a2 - 1, sm->b1, sm->b2)) {
      {( sm->p)++; goto _out; }
    }
  }}
	goto _again;
f49:
#line 294 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    append_unnamed_url(sm, sm->ts + 1, sm->te - 2);
  }}
	goto _again;
f39:
#line 362 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{ dstack_open_inline(sm,  INLINE_B, "<strong>"); }}
	goto _again;
f28:
#line 363 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{ dstack_close_inline(sm, INLINE_B, "</strong>"); }}
	goto _again;
f42:
#line 364 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{ dstack_open_inline(sm,  INLINE_I, "<em>"); }}
	goto _again;
f29:
#line 365 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{ dstack_close_inline(sm, INLINE_I, "</em>"); }}
	goto _again;
f45:
#line 366 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{ dstack_open_inline(sm,  INLINE_S, "<s>"); }}
	goto _again;
f31:
#line 367 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{ dstack_close_inline(sm, INLINE_S, "</s>"); }}
	goto _again;
f48:
#line 368 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{ dstack_open_inline(sm,  INLINE_U, "<u>"); }}
	goto _again;
f36:
#line 369 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{ dstack_close_inline(sm, INLINE_U, "</u>"); }}
	goto _again;
f47:
#line 371 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_open_inline(sm, INLINE_TN, "<span class=\"tn\">");
  }}
	goto _again;
f35:
#line 375 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_close_before_block(sm);

    if (dstack_check(sm, INLINE_TN)) {
      dstack_close_inline(sm, INLINE_TN, "</span>");
    } else if (dstack_close_block(sm, BLOCK_TN, "</p>")) {
      { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)];goto _again;}
    }
  }}
	goto _again;
f41:
#line 385 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_open_inline(sm, INLINE_CODE, "<code>");
    {
  size_t len = sm->stack->len;

  if (len > MAX_STACK_DEPTH) {
    g_set_error_literal(&sm->error, DTEXT_PARSE_ERROR, DTEXT_PARSE_ERROR_DEPTH_EXCEEDED, "too many nested elements");
    {( sm->p)++; goto _out; }
  }

  if (sm->top >= len) {
    g_debug("growing sm->stack %zi\n", len + 16);
    sm->stack = g_array_set_size(sm->stack, len + 16);
  }
{( ((int *)sm->stack->data))[( sm->top)++] =  sm->cs;  sm->cs = 789;goto _again;}}
  }}
	goto _again;
f46:
#line 390 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_open_inline(sm, INLINE_SPOILER, "<span class=\"spoiler\">");
  }}
	goto _again;
f32:
#line 394 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    g_debug("inline [/spoiler]");
    dstack_close_before_block(sm);

    if (dstack_check(sm, INLINE_SPOILER)) {
      dstack_close_inline(sm, INLINE_SPOILER, "</span>");
    } else if (dstack_close_block(sm, BLOCK_SPOILER, "</div>")) {
      { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)];goto _again;}
    }
  }}
	goto _again;
f44:
#line 405 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_open_inline(sm, INLINE_NODTEXT, "");
    {
  size_t len = sm->stack->len;

  if (len > MAX_STACK_DEPTH) {
    g_set_error_literal(&sm->error, DTEXT_PARSE_ERROR, DTEXT_PARSE_ERROR_DEPTH_EXCEEDED, "too many nested elements");
    {( sm->p)++; goto _out; }
  }

  if (sm->top >= len) {
    g_debug("growing sm->stack %zi\n", len + 16);
    sm->stack = g_array_set_size(sm->stack, len + 16);
  }
{( ((int *)sm->stack->data))[( sm->top)++] =  sm->cs;  sm->cs = 792;goto _again;}}
  }}
	goto _again;
f40:
#line 413 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    g_debug("inline [quote]");
    dstack_close_before_block(sm);
    {( sm->p) = (( sm->ts))-1;}
    { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)];goto _again;}
  }}
	goto _again;
f43:
#line 436 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    g_debug("inline [expand]");
    dstack_rewind(sm);
    {( sm->p) = (((sm->p - 7)))-1;}
    { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)];goto _again;}
  }}
	goto _again;
f30:
#line 443 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_close_before_block(sm);

    if (dstack_close_block(sm, BLOCK_EXPAND, "</div></details>")) {
      { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)];goto _again;}
    }
  }}
	goto _again;
f34:
#line 451 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    if (dstack_close_block(sm, BLOCK_TH, "</th>")) {
      { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)];goto _again;}
    }
  }}
	goto _again;
f33:
#line 457 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    if (dstack_close_block(sm, BLOCK_TD, "</td>")) {
      { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)];goto _again;}
    }
  }}
	goto _again;
f92:
#line 491 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    g_debug("inline char: %c", (*( sm->p)));
    append_c_html_escaped(sm, (*( sm->p)));
  }}
	goto _again;
f102:
#line 256 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    const char* match_end = sm->b2;
    const char* url_start = sm->b1;
    const char* url_end = find_boundary_c(match_end);

    if (!append_named_url(sm, url_start, url_end, sm->a1, sm->a2)) {
      {( sm->p)++; goto _out; }
    }

    if (url_end < match_end) {
      append_segment_html_escaped(sm, url_end + 1, match_end);
    }
  }}
	goto _again;
f149:
#line 282 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    const char* match_end = sm->te - 1;
    const char* url_start = sm->ts;
    const char* url_end = find_boundary_c(match_end);

    append_unnamed_url(sm, url_start, url_end);

    if (url_end < match_end) {
      append_segment_html_escaped(sm, url_end + 1, match_end);
    }
  }}
	goto _again;
f108:
#line 420 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    g_debug("inline [/quote]");
    dstack_close_before_block(sm);

    if (dstack_check(sm, BLOCK_LI)) {
      dstack_close_list(sm);
    }

    if (dstack_check(sm, BLOCK_QUOTE)) {
      dstack_rewind(sm);
      { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)];goto _again;}
    } else {
      append_block(sm, "[/quote]");
    }
  }}
	goto _again;
f98:
#line 463 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    g_debug("inline newline2");
    g_debug("  return");

    if (sm->list_mode) {
      dstack_close_list(sm);
    }

    {( sm->p) = (( sm->ts))-1;}
    { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)];goto _again;}
  }}
	goto _again;
f97:
#line 475 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    g_debug("inline newline");

    if (sm->header_mode) {
      sm->header_mode = false;
      dstack_rewind(sm);
      { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)];goto _again;}
    } else {
      append(sm, "<br>");
    }
  }}
	goto _again;
f100:
#line 487 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append_c(sm, ' ');
  }}
	goto _again;
f101:
#line 491 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    g_debug("inline char: %c", (*( sm->p)));
    append_c_html_escaped(sm, (*( sm->p)));
  }}
	goto _again;
f54:
#line 203 "ext/dtext/dtext.rl"
	{{( sm->p) = ((( sm->te)))-1;}{ append_id_link(sm, "topic", "forum-topic", "/forum_topics/"); }}
	goto _again;
f52:
#line 205 "ext/dtext/dtext.rl"
	{{( sm->p) = ((( sm->te)))-1;}{ append_id_link(sm, "dmail", "dmail", "/dmails/"); }}
	goto _again;
f53:
#line 226 "ext/dtext/dtext.rl"
	{{( sm->p) = ((( sm->te)))-1;}{ append_id_link(sm, "pixiv", "pixiv", "https://www.pixiv.net/artworks/"); }}
	goto _again;
f21:
#line 475 "ext/dtext/dtext.rl"
	{{( sm->p) = ((( sm->te)))-1;}{
    g_debug("inline newline");

    if (sm->header_mode) {
      sm->header_mode = false;
      dstack_rewind(sm);
      { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)];goto _again;}
    } else {
      append(sm, "<br>");
    }
  }}
	goto _again;
f22:
#line 491 "ext/dtext/dtext.rl"
	{{( sm->p) = ((( sm->te)))-1;}{
    g_debug("inline char: %c", (*( sm->p)));
    append_c_html_escaped(sm, (*( sm->p)));
  }}
	goto _again;
f19:
#line 1 "NONE"
	{	switch( ( sm->act) ) {
	case 49:
	{{( sm->p) = ((( sm->te)))-1;}
    const char* match_end = sm->b2;
    const char* url_start = sm->b1;
    const char* url_end = find_boundary_c(match_end);

    if (!append_named_url(sm, url_start, url_end, sm->a1, sm->a2)) {
      {( sm->p)++; goto _out; }
    }

    if (url_end < match_end) {
      append_segment_html_escaped(sm, url_end + 1, match_end);
    }
  }
	break;
	case 52:
	{{( sm->p) = ((( sm->te)))-1;}
    const char* match_end = sm->te - 1;
    const char* url_start = sm->ts;
    const char* url_end = find_boundary_c(match_end);

    append_unnamed_url(sm, url_start, url_end);

    if (url_end < match_end) {
      append_segment_html_escaped(sm, url_end + 1, match_end);
    }
  }
	break;
	case 54:
	{{( sm->p) = ((( sm->te)))-1;}
    append_segment_html_escaped(sm, sm->ts, sm->te - 1);
  }
	break;
	case 55:
	{{( sm->p) = ((( sm->te)))-1;}
    if (!sm->f_mentions || (sm->a1 > sm->pb && sm->a1 - 1 > sm->pb && sm->a1[-2] != ' ' && sm->a1[-2] != '\r' && sm->a1[-2] != '\n')) {
      // handle emails
      append_c(sm, '@');
      {( sm->p) = (( sm->a1))-1;}
    } else {
      const char* match_end = sm->a2 - 1;
      const char* name_start = sm->a1;
      const char* name_end = find_boundary_c(match_end);

      append(sm, "<a class=\"dtext-link dtext-user-mention-link\" data-user-name=\"");
      append_segment_html_escaped(sm, name_start, name_end);
      append(sm, "\" href=\"");
      append_url(sm, "/users?name=");
      append_segment_uri_escaped(sm, name_start, name_end);
      append(sm, "\">");
      append_c(sm, '@');
      append_segment_html_escaped(sm, name_start, name_end);
      append(sm, "</a>");

      if (name_end < match_end) {
        append_segment_html_escaped(sm, name_end + 1, match_end);
      }
    }
  }
	break;
	case 78:
	{{( sm->p) = ((( sm->te)))-1;}
    g_debug("inline newline2");
    g_debug("  return");

    if (sm->list_mode) {
      dstack_close_list(sm);
    }

    {( sm->p) = (( sm->ts))-1;}
    { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)];goto _again;}
  }
	break;
	case 79:
	{{( sm->p) = ((( sm->te)))-1;}
    g_debug("inline newline");

    if (sm->header_mode) {
      sm->header_mode = false;
      dstack_rewind(sm);
      { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)];goto _again;}
    } else {
      append(sm, "<br>");
    }
  }
	break;
	case 81:
	{{( sm->p) = ((( sm->te)))-1;}
    g_debug("inline char: %c", (*( sm->p)));
    append_c_html_escaped(sm, (*( sm->p)));
  }
	break;
	}
	}
	goto _again;
f59:
#line 498 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_rewind(sm);
    { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)];goto _again;}
  }}
	goto _again;
f150:
#line 503 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    append_c_html_escaped(sm, (*( sm->p)));
  }}
	goto _again;
f151:
#line 503 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append_c_html_escaped(sm, (*( sm->p)));
  }}
	goto _again;
f58:
#line 503 "ext/dtext/dtext.rl"
	{{( sm->p) = ((( sm->te)))-1;}{
    append_c_html_escaped(sm, (*( sm->p)));
  }}
	goto _again;
f61:
#line 509 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    if (dstack_check2(sm, BLOCK_NODTEXT)) {
      g_debug("block dstack check");
      dstack_pop(sm);
      dstack_pop(sm);
      append_block(sm, "</p>");
      { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)];goto _again;}
    } else if (dstack_check(sm, INLINE_NODTEXT)) {
      g_debug("inline dstack check");
      dstack_pop(sm);
      { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)];goto _again;}
    } else {
      g_debug("else dstack check");
      append(sm, "[/nodtext]");
    }
  }}
	goto _again;
f152:
#line 526 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    append_c_html_escaped(sm, (*( sm->p)));
  }}
	goto _again;
f153:
#line 526 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append_c_html_escaped(sm, (*( sm->p)));
  }}
	goto _again;
f60:
#line 526 "ext/dtext/dtext.rl"
	{{( sm->p) = ((( sm->te)))-1;}{
    append_c_html_escaped(sm, (*( sm->p)));
  }}
	goto _again;
f70:
#line 532 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_open_block(sm, BLOCK_THEAD, "<thead>");
  }}
	goto _again;
f65:
#line 536 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_close_block(sm, BLOCK_THEAD, "</thead>");
  }}
	goto _again;
f67:
#line 540 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_open_block(sm, BLOCK_TBODY, "<tbody>");
  }}
	goto _again;
f64:
#line 544 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_close_block(sm, BLOCK_TBODY, "</tbody>");
  }}
	goto _again;
f69:
#line 548 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_open_block(sm, BLOCK_TH, "<th>");
    {
  size_t len = sm->stack->len;

  if (len > MAX_STACK_DEPTH) {
    g_set_error_literal(&sm->error, DTEXT_PARSE_ERROR, DTEXT_PARSE_ERROR_DEPTH_EXCEEDED, "too many nested elements");
    {( sm->p)++; goto _out; }
  }

  if (sm->top >= len) {
    g_debug("growing sm->stack %zi\n", len + 16);
    sm->stack = g_array_set_size(sm->stack, len + 16);
  }
{( ((int *)sm->stack->data))[( sm->top)++] =  sm->cs;  sm->cs = 716;goto _again;}}
  }}
	goto _again;
f71:
#line 553 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_open_block(sm, BLOCK_TR, "<tr>");
  }}
	goto _again;
f66:
#line 557 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_close_block(sm, BLOCK_TR, "</tr>");
  }}
	goto _again;
f68:
#line 561 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_open_block(sm, BLOCK_TD, "<td>");
    {
  size_t len = sm->stack->len;

  if (len > MAX_STACK_DEPTH) {
    g_set_error_literal(&sm->error, DTEXT_PARSE_ERROR, DTEXT_PARSE_ERROR_DEPTH_EXCEEDED, "too many nested elements");
    {( sm->p)++; goto _out; }
  }

  if (sm->top >= len) {
    g_debug("growing sm->stack %zi\n", len + 16);
    sm->stack = g_array_set_size(sm->stack, len + 16);
  }
{( ((int *)sm->stack->data))[( sm->top)++] =  sm->cs;  sm->cs = 716;goto _again;}}
  }}
	goto _again;
f63:
#line 566 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    if (dstack_close_block(sm, BLOCK_TABLE, "</table>")) {
      { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)];goto _again;}
    }
  }}
	goto _again;
f154:
#line 572 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;}
	goto _again;
f155:
#line 572 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;}
	goto _again;
f62:
#line 572 "ext/dtext/dtext.rl"
	{{( sm->p) = ((( sm->te)))-1;}}
	goto _again;
f156:
#line 617 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_rewind(sm);
    ( sm->p)--;
    { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)];goto _again;}
  }}
	goto _again;
f158:
#line 617 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    dstack_rewind(sm);
    ( sm->p)--;
    { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)];goto _again;}
  }}
	goto _again;
f74:
#line 617 "ext/dtext/dtext.rl"
	{{( sm->p) = ((( sm->te)))-1;}{
    dstack_rewind(sm);
    ( sm->p)--;
    { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)];goto _again;}
  }}
	goto _again;
f72:
#line 1 "NONE"
	{	switch( ( sm->act) ) {
	case 97:
	{{( sm->p) = ((( sm->te)))-1;}
    dstack_close_list(sm);
    {( sm->p) = (( sm->ts))-1;}
    { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)];goto _again;}
  }
	break;
	default:
	{{( sm->p) = ((( sm->te)))-1;}}
	break;
	}
	}
	goto _again;
f5:
#line 735 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    g_debug("block [/spoiler]");
    dstack_close_before_block(sm);
    if (dstack_check(sm, BLOCK_SPOILER)) {
      g_debug("  rewind");
      dstack_rewind(sm);
    }
  }}
	goto _again;
f6:
#line 772 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_close_before_block(sm);
    dstack_open_block(sm, BLOCK_TABLE, "<table class=\"striped\">");
    {
  size_t len = sm->stack->len;

  if (len > MAX_STACK_DEPTH) {
    g_set_error_literal(&sm->error, DTEXT_PARSE_ERROR, DTEXT_PARSE_ERROR_DEPTH_EXCEEDED, "too many nested elements");
    {( sm->p)++; goto _out; }
  }

  if (sm->top >= len) {
    g_debug("growing sm->stack %zi\n", len + 16);
    sm->stack = g_array_set_size(sm->stack, len + 16);
  }
{( ((int *)sm->stack->data))[( sm->top)++] =  sm->cs;  sm->cs = 795;goto _again;}}
  }}
	goto _again;
f7:
#line 778 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_open_block(sm, BLOCK_TN, "<p class=\"tn\">");
    {
  size_t len = sm->stack->len;

  if (len > MAX_STACK_DEPTH) {
    g_set_error_literal(&sm->error, DTEXT_PARSE_ERROR, DTEXT_PARSE_ERROR_DEPTH_EXCEEDED, "too many nested elements");
    {( sm->p)++; goto _out; }
  }

  if (sm->top >= len) {
    g_debug("growing sm->stack %zi\n", len + 16);
    sm->stack = g_array_set_size(sm->stack, len + 16);
  }
{( ((int *)sm->stack->data))[( sm->top)++] =  sm->cs;  sm->cs = 716;goto _again;}}
  }}
	goto _again;
f77:
#line 810 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    g_debug("block char: %c", (*( sm->p)));
    ( sm->p)--;

    if (g_queue_is_empty(sm->dstack) || dstack_check(sm, BLOCK_QUOTE) || dstack_check(sm, BLOCK_SPOILER) || dstack_check(sm, BLOCK_EXPAND)) {
      dstack_open_block(sm, BLOCK_P, "<p>");
    }

    {
  size_t len = sm->stack->len;

  if (len > MAX_STACK_DEPTH) {
    g_set_error_literal(&sm->error, DTEXT_PARSE_ERROR, DTEXT_PARSE_ERROR_DEPTH_EXCEEDED, "too many nested elements");
    {( sm->p)++; goto _out; }
  }

  if (sm->top >= len) {
    g_debug("growing sm->stack %zi\n", len + 16);
    sm->stack = g_array_set_size(sm->stack, len + 16);
  }
{( ((int *)sm->stack->data))[( sm->top)++] =  sm->cs;  sm->cs = 716;goto _again;}}
  }}
	goto _again;
f87:
#line 625 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    char header = *sm->a1;
    g_autoptr(GString) id_name = g_string_new_len(sm->b1, sm->b2 - sm->b1);
    id_name = g_string_prepend(id_name, "dtext-");

    if (sm->f_inline) {
      header = '6';
    }

    switch (header) {
      case '1':
        dstack_push(sm, BLOCK_H1);
        append_block(sm, "<h1 id=\"");
        append_block(sm, id_name->str);
        append_block(sm, "\">");
        break;

      case '2':
        dstack_push(sm, BLOCK_H2);
        append_block(sm, "<h2 id=\"");
        append_block(sm, id_name->str);
        append_block(sm, "\">");
        break;

      case '3':
        dstack_push(sm, BLOCK_H3);
        append_block(sm, "<h3 id=\"");
        append_block(sm, id_name->str);
        append_block(sm, "\">");
        break;

      case '4':
        dstack_push(sm, BLOCK_H4);
        append_block(sm, "<h4 id=\"");
        append_block(sm, id_name->str);
        append_block(sm, "\">");
        break;

      case '5':
        dstack_push(sm, BLOCK_H5);
        append_block(sm, "<h5 id=\"");
        append_block(sm, id_name->str);
        append_block(sm, "\">");
        break;

      case '6':
        dstack_push(sm, BLOCK_H6);
        append_block(sm, "<h6 id=\"");
        append_block(sm, id_name->str);
        append_block(sm, "\">");
        break;
    }

    sm->header_mode = true;
    {
  size_t len = sm->stack->len;

  if (len > MAX_STACK_DEPTH) {
    g_set_error_literal(&sm->error, DTEXT_PARSE_ERROR, DTEXT_PARSE_ERROR_DEPTH_EXCEEDED, "too many nested elements");
    {( sm->p)++; goto _out; }
  }

  if (sm->top >= len) {
    g_debug("growing sm->stack %zi\n", len + 16);
    sm->stack = g_array_set_size(sm->stack, len + 16);
  }
{( ((int *)sm->stack->data))[( sm->top)++] =  sm->cs;  sm->cs = 716;goto _again;}}
  }}
	goto _again;
f88:
#line 682 "ext/dtext/dtext.rl"
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
  size_t len = sm->stack->len;

  if (len > MAX_STACK_DEPTH) {
    g_set_error_literal(&sm->error, DTEXT_PARSE_ERROR, DTEXT_PARSE_ERROR_DEPTH_EXCEEDED, "too many nested elements");
    {( sm->p)++; goto _out; }
  }

  if (sm->top >= len) {
    g_debug("growing sm->stack %zi\n", len + 16);
    sm->stack = g_array_set_size(sm->stack, len + 16);
  }
{( ((int *)sm->stack->data))[( sm->top)++] =  sm->cs;  sm->cs = 716;goto _again;}}
  }}
	goto _again;
f82:
#line 725 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    dstack_close_before_block(sm);
    dstack_open_block(sm, BLOCK_QUOTE, "<blockquote>");
  }}
	goto _again;
f86:
#line 730 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    dstack_close_before_block(sm);
    dstack_open_block(sm, BLOCK_SPOILER, "<div class=\"spoiler\">");
  }}
	goto _again;
f83:
#line 744 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    dstack_close_before_block(sm);
    dstack_open_block(sm, BLOCK_CODE, "<pre>");
    {
  size_t len = sm->stack->len;

  if (len > MAX_STACK_DEPTH) {
    g_set_error_literal(&sm->error, DTEXT_PARSE_ERROR, DTEXT_PARSE_ERROR_DEPTH_EXCEEDED, "too many nested elements");
    {( sm->p)++; goto _out; }
  }

  if (sm->top >= len) {
    g_debug("growing sm->stack %zi\n", len + 16);
    sm->stack = g_array_set_size(sm->stack, len + 16);
  }
{( ((int *)sm->stack->data))[( sm->top)++] =  sm->cs;  sm->cs = 789;goto _again;}}
  }}
	goto _again;
f84:
#line 750 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    dstack_close_before_block(sm);
    dstack_open_block(sm, BLOCK_EXPAND, "<details>");
    append(sm, "<summary>Show</summary><div>");
  }}
	goto _again;
f89:
#line 756 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    g_debug("block [expand=]");
    dstack_close_before_block(sm);
    dstack_open_block(sm, BLOCK_EXPAND, "<details>");
    append(sm, "<summary>");
    append_segment_html_escaped(sm, sm->a1, sm->a2 - 1);
    append(sm, "</summary><div>");
  }}
	goto _again;
f85:
#line 765 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    dstack_close_before_block(sm);
    dstack_open_block(sm, BLOCK_NODTEXT, "");
    dstack_open_block(sm, BLOCK_P, "<p>");
    {
  size_t len = sm->stack->len;

  if (len > MAX_STACK_DEPTH) {
    g_set_error_literal(&sm->error, DTEXT_PARSE_ERROR, DTEXT_PARSE_ERROR_DEPTH_EXCEEDED, "too many nested elements");
    {( sm->p)++; goto _out; }
  }

  if (sm->top >= len) {
    g_debug("growing sm->stack %zi\n", len + 16);
    sm->stack = g_array_set_size(sm->stack, len + 16);
  }
{( ((int *)sm->stack->data))[( sm->top)++] =  sm->cs;  sm->cs = 792;goto _again;}}
  }}
	goto _again;
f80:
#line 810 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    g_debug("block char: %c", (*( sm->p)));
    ( sm->p)--;

    if (g_queue_is_empty(sm->dstack) || dstack_check(sm, BLOCK_QUOTE) || dstack_check(sm, BLOCK_SPOILER) || dstack_check(sm, BLOCK_EXPAND)) {
      dstack_open_block(sm, BLOCK_P, "<p>");
    }

    {
  size_t len = sm->stack->len;

  if (len > MAX_STACK_DEPTH) {
    g_set_error_literal(&sm->error, DTEXT_PARSE_ERROR, DTEXT_PARSE_ERROR_DEPTH_EXCEEDED, "too many nested elements");
    {( sm->p)++; goto _out; }
  }

  if (sm->top >= len) {
    g_debug("growing sm->stack %zi\n", len + 16);
    sm->stack = g_array_set_size(sm->stack, len + 16);
  }
{( ((int *)sm->stack->data))[( sm->top)++] =  sm->cs;  sm->cs = 716;goto _again;}}
  }}
	goto _again;
f2:
#line 810 "ext/dtext/dtext.rl"
	{{( sm->p) = ((( sm->te)))-1;}{
    g_debug("block char: %c", (*( sm->p)));
    ( sm->p)--;

    if (g_queue_is_empty(sm->dstack) || dstack_check(sm, BLOCK_QUOTE) || dstack_check(sm, BLOCK_SPOILER) || dstack_check(sm, BLOCK_EXPAND)) {
      dstack_open_block(sm, BLOCK_P, "<p>");
    }

    {
  size_t len = sm->stack->len;

  if (len > MAX_STACK_DEPTH) {
    g_set_error_literal(&sm->error, DTEXT_PARSE_ERROR, DTEXT_PARSE_ERROR_DEPTH_EXCEEDED, "too many nested elements");
    {( sm->p)++; goto _out; }
  }

  if (sm->top >= len) {
    g_debug("growing sm->stack %zi\n", len + 16);
    sm->stack = g_array_set_size(sm->stack, len + 16);
  }
{( ((int *)sm->stack->data))[( sm->top)++] =  sm->cs;  sm->cs = 716;goto _again;}}
  }}
	goto _again;
f0:
#line 1 "NONE"
	{	switch( ( sm->act) ) {
	case 112:
	{{( sm->p) = ((( sm->te)))-1;}
    g_debug("block newline2");

    if (sm->header_mode) {
      sm->header_mode = false;
      dstack_rewind(sm);
    } else if (sm->list_mode) {
      dstack_close_list(sm);
    } else {
      dstack_close_before_block(sm);
    }
  }
	break;
	case 113:
	{{( sm->p) = ((( sm->te)))-1;}
    g_debug("block newline");
  }
	break;
	}
	}
	goto _again;
f37:
#line 76 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
#line 329 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    if (sm->f_mentions) {
      append(sm, "<a class=\"dtext-link dtext-user-mention-link\" data-user-name=\"");
      append_segment_html_escaped(sm, sm->a1, sm->a2 - 1);
      append(sm, "\" href=\"");
      append_url(sm, "/users?name=");
      append_segment_uri_escaped(sm, sm->a1, sm->a2 - 1);
      append(sm, "\">");
      append_c(sm, '@');
      append_segment_html_escaped(sm, sm->a1, sm->a2 - 1);
      append(sm, "</a>");
    }
  }}
	goto _again;
f139:
#line 76 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
#line 198 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{ append_id_link(sm, "post", "post", "/posts/"); }}
	goto _again;
f114:
#line 76 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
#line 199 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{ append_id_link(sm, "appeal", "post-appeal", "/post_appeals/"); }}
	goto _again;
f126:
#line 76 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
#line 200 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{ append_id_link(sm, "flag", "post-flag", "/post_flags/"); }}
	goto _again;
f134:
#line 76 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
#line 201 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{ append_id_link(sm, "note", "note", "/notes/"); }}
	goto _again;
f127:
#line 76 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
#line 202 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{ append_id_link(sm, "forum", "forum-post", "/forum_posts/"); }}
	goto _again;
f143:
#line 76 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
#line 203 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{ append_id_link(sm, "topic", "forum-topic", "/forum_topics/"); }}
	goto _again;
f119:
#line 76 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
#line 204 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{ append_id_link(sm, "comment", "comment", "/comments/"); }}
	goto _again;
f122:
#line 76 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
#line 205 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{ append_id_link(sm, "dmail", "dmail", "/dmails/"); }}
	goto _again;
f138:
#line 76 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
#line 206 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{ append_id_link(sm, "pool", "pool", "/pools/"); }}
	goto _again;
f146:
#line 76 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
#line 207 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{ append_id_link(sm, "user", "user", "/users/"); }}
	goto _again;
f115:
#line 76 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
#line 208 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{ append_id_link(sm, "artist", "artist", "/artists/"); }}
	goto _again;
f117:
#line 76 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
#line 209 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{ append_id_link(sm, "ban", "ban", "/bans/"); }}
	goto _again;
f118:
#line 76 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
#line 210 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{ append_id_link(sm, "BUR", "bulk-update-request", "/bulk_update_requests/"); }}
	goto _again;
f113:
#line 76 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
#line 211 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{ append_id_link(sm, "alias", "tag-alias", "/tag_aliases/"); }}
	goto _again;
f129:
#line 76 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
#line 212 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{ append_id_link(sm, "implication", "tag-implication", "/tag_implications/"); }}
	goto _again;
f124:
#line 76 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
#line 213 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{ append_id_link(sm, "favgroup", "favorite-group", "/favorite_groups/"); }}
	goto _again;
f131:
#line 76 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
#line 214 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{ append_id_link(sm, "mod action", "mod-action", "/mod_actions/"); }}
	goto _again;
f132:
#line 76 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
#line 215 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{ append_id_link(sm, "modreport", "moderation-report", "/moderation_reports/"); }}
	goto _again;
f125:
#line 76 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
#line 216 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{ append_id_link(sm, "feedback", "user-feedback", "/user_feedbacks/"); }}
	goto _again;
f147:
#line 76 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
#line 217 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{ append_id_link(sm, "wiki", "wiki-page", "/wiki_pages/"); }}
	goto _again;
f130:
#line 76 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
#line 219 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{ append_id_link(sm, "issue", "github", "https://github.com/danbooru/danbooru/issues/"); }}
	goto _again;
f140:
#line 76 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
#line 220 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{ append_id_link(sm, "pull", "github-pull", "https://github.com/danbooru/danbooru/pull/"); }}
	goto _again;
f120:
#line 76 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
#line 221 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{ append_id_link(sm, "commit", "github-commit", "https://github.com/danbooru/danbooru/commit/"); }}
	goto _again;
f116:
#line 76 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
#line 222 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{ append_id_link(sm, "artstation", "artstation", "https://www.artstation.com/artwork/"); }}
	goto _again;
f121:
#line 76 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
#line 223 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{ append_id_link(sm, "deviantart", "deviantart", "https://www.deviantart.com/deviation/"); }}
	goto _again;
f133:
#line 76 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
#line 224 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{ append_id_link(sm, "nijie", "nijie", "https://nijie.info/view.php?id="); }}
	goto _again;
f135:
#line 76 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
#line 225 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{ append_id_link(sm, "pawoo", "pawoo", "https://pawoo.net/web/statuses/"); }}
	goto _again;
f136:
#line 76 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
#line 226 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{ append_id_link(sm, "pixiv", "pixiv", "https://www.pixiv.net/artworks/"); }}
	goto _again;
f142:
#line 76 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
#line 227 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{ append_id_link(sm, "seiga", "seiga", "https://seiga.nicovideo.jp/seiga/im"); }}
	goto _again;
f145:
#line 76 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
#line 228 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{ append_id_link(sm, "twitter", "twitter", "https://twitter.com/i/web/status/"); }}
	goto _again;
f148:
#line 76 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
#line 230 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{ append_id_link(sm, "yandere", "yandere", "https://yande.re/post/show/"); }}
	goto _again;
f141:
#line 76 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
#line 231 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{ append_id_link(sm, "sankaku", "sankaku", "https://chan.sankakucomplex.com/post/show/"); }}
	goto _again;
f128:
#line 76 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
#line 232 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{ append_id_link(sm, "gelbooru", "gelbooru", "https://gelbooru.com/index.php?page=post&s=view&id="); }}
	goto _again;
f111:
#line 76 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
#line 303 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    if (!sm->f_mentions || (sm->a1 > sm->pb && sm->a1 - 1 > sm->pb && sm->a1[-2] != ' ' && sm->a1[-2] != '\r' && sm->a1[-2] != '\n')) {
      // handle emails
      append_c(sm, '@');
      {( sm->p) = (( sm->a1))-1;}
    } else {
      const char* match_end = sm->a2 - 1;
      const char* name_start = sm->a1;
      const char* name_end = find_boundary_c(match_end);

      append(sm, "<a class=\"dtext-link dtext-user-mention-link\" data-user-name=\"");
      append_segment_html_escaped(sm, name_start, name_end);
      append(sm, "\" href=\"");
      append_url(sm, "/users?name=");
      append_segment_uri_escaped(sm, name_start, name_end);
      append(sm, "\">");
      append_c(sm, '@');
      append_segment_html_escaped(sm, name_start, name_end);
      append(sm, "</a>");

      if (name_end < match_end) {
        append_segment_html_escaped(sm, name_end + 1, match_end);
      }
    }
  }}
	goto _again;
f110:
#line 76 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
#line 1 "NONE"
	{	switch( ( sm->act) ) {
	case 49:
	{{( sm->p) = ((( sm->te)))-1;}
    const char* match_end = sm->b2;
    const char* url_start = sm->b1;
    const char* url_end = find_boundary_c(match_end);

    if (!append_named_url(sm, url_start, url_end, sm->a1, sm->a2)) {
      {( sm->p)++; goto _out; }
    }

    if (url_end < match_end) {
      append_segment_html_escaped(sm, url_end + 1, match_end);
    }
  }
	break;
	case 52:
	{{( sm->p) = ((( sm->te)))-1;}
    const char* match_end = sm->te - 1;
    const char* url_start = sm->ts;
    const char* url_end = find_boundary_c(match_end);

    append_unnamed_url(sm, url_start, url_end);

    if (url_end < match_end) {
      append_segment_html_escaped(sm, url_end + 1, match_end);
    }
  }
	break;
	case 54:
	{{( sm->p) = ((( sm->te)))-1;}
    append_segment_html_escaped(sm, sm->ts, sm->te - 1);
  }
	break;
	case 55:
	{{( sm->p) = ((( sm->te)))-1;}
    if (!sm->f_mentions || (sm->a1 > sm->pb && sm->a1 - 1 > sm->pb && sm->a1[-2] != ' ' && sm->a1[-2] != '\r' && sm->a1[-2] != '\n')) {
      // handle emails
      append_c(sm, '@');
      {( sm->p) = (( sm->a1))-1;}
    } else {
      const char* match_end = sm->a2 - 1;
      const char* name_start = sm->a1;
      const char* name_end = find_boundary_c(match_end);

      append(sm, "<a class=\"dtext-link dtext-user-mention-link\" data-user-name=\"");
      append_segment_html_escaped(sm, name_start, name_end);
      append(sm, "\" href=\"");
      append_url(sm, "/users?name=");
      append_segment_uri_escaped(sm, name_start, name_end);
      append(sm, "\">");
      append_c(sm, '@');
      append_segment_html_escaped(sm, name_start, name_end);
      append(sm, "</a>");

      if (name_end < match_end) {
        append_segment_html_escaped(sm, name_end + 1, match_end);
      }
    }
  }
	break;
	case 78:
	{{( sm->p) = ((( sm->te)))-1;}
    g_debug("inline newline2");
    g_debug("  return");

    if (sm->list_mode) {
      dstack_close_list(sm);
    }

    {( sm->p) = (( sm->ts))-1;}
    { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)];goto _again;}
  }
	break;
	case 79:
	{{( sm->p) = ((( sm->te)))-1;}
    g_debug("inline newline");

    if (sm->header_mode) {
      sm->header_mode = false;
      dstack_rewind(sm);
      { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)];goto _again;}
    } else {
      append(sm, "<br>");
    }
  }
	break;
	case 81:
	{{( sm->p) = ((( sm->te)))-1;}
    g_debug("inline char: %c", (*( sm->p)));
    append_c_html_escaped(sm, (*( sm->p)));
  }
	break;
	}
	}
	goto _again;
f55:
#line 84 "ext/dtext/dtext.rl"
	{
  sm->b2 = sm->p;
}
#line 276 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    if (!append_named_url(sm, sm->a1, sm->a2 - 1, sm->b1, sm->b2)) {
      {( sm->p)++; goto _out; }
    }
  }}
	goto _again;
f123:
#line 84 "ext/dtext/dtext.rl"
	{
  sm->b2 = sm->p;
}
#line 234 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{ append_dmail_key_link(sm); }}
	goto _again;
f144:
#line 84 "ext/dtext/dtext.rl"
	{
  sm->b2 = sm->p;
}
#line 236 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{ append_paged_link(sm, "topic #", "<a class=\"dtext-link dtext-id-link dtext-forum-topic-id-link\" href=\"", "/forum_topics/", "?page="); }}
	goto _again;
f137:
#line 84 "ext/dtext/dtext.rl"
	{
  sm->b2 = sm->p;
}
#line 237 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{ append_paged_link(sm, "pixiv #", "<a rel=\"external nofollow noreferrer\" class=\"dtext-link dtext-id-link dtext-pixiv-id-link\" href=\"", "https://www.pixiv.net/artworks/", "#"); }}
	goto _again;
f99:
#line 84 "ext/dtext/dtext.rl"
	{
  sm->b2 = sm->p;
}
#line 343 "ext/dtext/dtext.rl"
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
     sm->cs = 798;
  }}
	goto _again;
f159:
#line 84 "ext/dtext/dtext.rl"
	{
  sm->b2 = sm->p;
}
#line 576 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    int prev_nest = sm->list_nest;
    append_closing_p_if(sm);
    g_debug("list start");
    sm->list_mode = true;
    sm->list_nest = sm->a2 - sm->a1;
    {( sm->p) = (( sm->b1))-1;}

    if (sm->list_nest > prev_nest) {
      int i=0;
      for (i=prev_nest; i<sm->list_nest; ++i) {
        dstack_open_block(sm, BLOCK_UL, "<ul>");
      }
    } else if (sm->list_nest < prev_nest) {
      int i=0;
      for (i=sm->list_nest; i<prev_nest; ++i) {
        if (dstack_check(sm, BLOCK_UL)) {
          g_debug("  dstack pop");
          g_debug("  print </ul>");
          dstack_pop(sm);
          append_block(sm, "</ul>");
        }
      }
    }

    dstack_open_block(sm, BLOCK_LI, "<li>");

    g_debug("  call inline");

    {
  size_t len = sm->stack->len;

  if (len > MAX_STACK_DEPTH) {
    g_set_error_literal(&sm->error, DTEXT_PARSE_ERROR, DTEXT_PARSE_ERROR_DEPTH_EXCEEDED, "too many nested elements");
    {( sm->p)++; goto _out; }
  }

  if (sm->top >= len) {
    g_debug("growing sm->stack %zi\n", len + 16);
    sm->stack = g_array_set_size(sm->stack, len + 16);
  }
{( ((int *)sm->stack->data))[( sm->top)++] =  sm->cs;  sm->cs = 716;goto _again;}}
  }}
	goto _again;
f81:
#line 84 "ext/dtext/dtext.rl"
	{
  sm->b2 = sm->p;
}
#line 783 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    g_debug("block list");
    g_debug("  call list");
    sm->list_nest = 0;
    sm->list_mode = true;
    append_closing_p_if(sm);
    {( sm->p) = (( sm->ts))-1;}
    {
  size_t len = sm->stack->len;

  if (len > MAX_STACK_DEPTH) {
    g_set_error_literal(&sm->error, DTEXT_PARSE_ERROR, DTEXT_PARSE_ERROR_DEPTH_EXCEEDED, "too many nested elements");
    {( sm->p)++; goto _out; }
  }

  if (sm->top >= len) {
    g_debug("growing sm->stack %zi\n", len + 16);
    sm->stack = g_array_set_size(sm->stack, len + 16);
  }
{( ((int *)sm->stack->data))[( sm->top)++] =  sm->cs;  sm->cs = 798;goto _again;}}
  }}
	goto _again;
f26:
#line 88 "ext/dtext/dtext.rl"
	{
  sm->c1 = sm->p;
}
#line 92 "ext/dtext/dtext.rl"
	{
  sm->c2 = sm->p;
}
	goto _again;
f104:
#line 92 "ext/dtext/dtext.rl"
	{
  sm->c2 = sm->p;
}
#line 248 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append_wiki_link(sm, sm->b1, sm->b2 - sm->b1, sm->b1, sm->b2 - sm->b1, sm->a1, sm->a2 - sm->a1, sm->c1, sm->c2 - sm->c1);
  }}
	goto _again;
f107:
#line 100 "ext/dtext/dtext.rl"
	{
  sm->d2 = sm->p;
}
#line 252 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append_wiki_link(sm, sm->b1, sm->b2 - sm->b1, sm->c1, sm->c2 - sm->c1, sm->a1, sm->a2 - sm->a1, sm->d1, sm->d2 - sm->d1);
  }}
	goto _again;
f51:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 72 "ext/dtext/dtext.rl"
	{
  sm->a1 = sm->p;
}
	goto _again;
f56:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 282 "ext/dtext/dtext.rl"
	{( sm->act) = 52;}
	goto _again;
f112:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 299 "ext/dtext/dtext.rl"
	{( sm->act) = 54;}
	goto _again;
f50:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 303 "ext/dtext/dtext.rl"
	{( sm->act) = 55;}
	goto _again;
f20:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 463 "ext/dtext/dtext.rl"
	{( sm->act) = 78;}
	goto _again;
f93:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 475 "ext/dtext/dtext.rl"
	{( sm->act) = 79;}
	goto _again;
f94:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 491 "ext/dtext/dtext.rl"
	{( sm->act) = 81;}
	goto _again;
f73:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 609 "ext/dtext/dtext.rl"
	{( sm->act) = 97;}
	goto _again;
f157:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 615 "ext/dtext/dtext.rl"
	{( sm->act) = 98;}
	goto _again;
f1:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 793 "ext/dtext/dtext.rl"
	{( sm->act) = 112;}
	goto _again;
f78:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 806 "ext/dtext/dtext.rl"
	{( sm->act) = 113;}
	goto _again;
f103:
#line 88 "ext/dtext/dtext.rl"
	{
  sm->c1 = sm->p;
}
#line 92 "ext/dtext/dtext.rl"
	{
  sm->c2 = sm->p;
}
#line 248 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append_wiki_link(sm, sm->b1, sm->b2 - sm->b1, sm->b1, sm->b2 - sm->b1, sm->a1, sm->a2 - sm->a1, sm->c1, sm->c2 - sm->c1);
  }}
	goto _again;
f105:
#line 96 "ext/dtext/dtext.rl"
	{
  sm->d1 = sm->p;
}
#line 100 "ext/dtext/dtext.rl"
	{
  sm->d2 = sm->p;
}
#line 252 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append_wiki_link(sm, sm->b1, sm->b2 - sm->b1, sm->c1, sm->c2 - sm->c1, sm->a1, sm->a2 - sm->a1, sm->d1, sm->d2 - sm->d1);
  }}
	goto _again;
f95:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 72 "ext/dtext/dtext.rl"
	{
  sm->a1 = sm->p;
}
#line 76 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
	goto _again;
f109:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 72 "ext/dtext/dtext.rl"
	{
  sm->a1 = sm->p;
}
#line 303 "ext/dtext/dtext.rl"
	{( sm->act) = 55;}
	goto _again;
f96:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 72 "ext/dtext/dtext.rl"
	{
  sm->a1 = sm->p;
}
#line 491 "ext/dtext/dtext.rl"
	{( sm->act) = 81;}
	goto _again;
f23:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 84 "ext/dtext/dtext.rl"
	{
  sm->b2 = sm->p;
}
#line 256 "ext/dtext/dtext.rl"
	{( sm->act) = 49;}
	goto _again;

_again:
	switch ( _dtext_to_state_actions[ sm->cs] ) {
	case 76:
#line 1 "NONE"
	{( sm->ts) = 0;}
	break;
#line 9861 "ext/dtext/dtext.c"
	}

	if ( ++( sm->p) != ( sm->pe) )
		goto _resume;
	_test_eof: {}
	if ( ( sm->p) == ( sm->eof) )
	{
	switch (  sm->cs ) {
	case 697: goto tr0;
	case 0: goto tr0;
	case 698: goto tr748;
	case 699: goto tr748;
	case 1: goto tr2;
	case 700: goto tr749;
	case 701: goto tr749;
	case 2: goto tr2;
	case 702: goto tr748;
	case 3: goto tr2;
	case 4: goto tr2;
	case 5: goto tr2;
	case 6: goto tr2;
	case 7: goto tr2;
	case 8: goto tr2;
	case 9: goto tr2;
	case 10: goto tr2;
	case 11: goto tr2;
	case 12: goto tr2;
	case 13: goto tr2;
	case 14: goto tr2;
	case 15: goto tr2;
	case 16: goto tr2;
	case 17: goto tr2;
	case 18: goto tr2;
	case 19: goto tr2;
	case 20: goto tr2;
	case 21: goto tr2;
	case 703: goto tr758;
	case 22: goto tr2;
	case 23: goto tr2;
	case 24: goto tr2;
	case 25: goto tr2;
	case 704: goto tr759;
	case 26: goto tr2;
	case 27: goto tr2;
	case 28: goto tr2;
	case 29: goto tr2;
	case 30: goto tr2;
	case 31: goto tr2;
	case 705: goto tr760;
	case 32: goto tr2;
	case 33: goto tr2;
	case 34: goto tr2;
	case 35: goto tr2;
	case 36: goto tr2;
	case 37: goto tr2;
	case 38: goto tr2;
	case 706: goto tr761;
	case 39: goto tr2;
	case 40: goto tr2;
	case 41: goto tr2;
	case 42: goto tr2;
	case 43: goto tr2;
	case 44: goto tr2;
	case 45: goto tr2;
	case 707: goto tr762;
	case 46: goto tr2;
	case 47: goto tr2;
	case 48: goto tr2;
	case 49: goto tr2;
	case 50: goto tr2;
	case 51: goto tr2;
	case 52: goto tr2;
	case 708: goto tr748;
	case 53: goto tr2;
	case 54: goto tr2;
	case 55: goto tr2;
	case 709: goto tr764;
	case 710: goto tr766;
	case 711: goto tr748;
	case 56: goto tr2;
	case 57: goto tr2;
	case 58: goto tr2;
	case 59: goto tr2;
	case 60: goto tr2;
	case 61: goto tr2;
	case 62: goto tr2;
	case 63: goto tr2;
	case 64: goto tr2;
	case 65: goto tr2;
	case 66: goto tr2;
	case 67: goto tr2;
	case 68: goto tr2;
	case 69: goto tr2;
	case 70: goto tr2;
	case 71: goto tr2;
	case 72: goto tr2;
	case 73: goto tr2;
	case 74: goto tr2;
	case 75: goto tr2;
	case 76: goto tr2;
	case 712: goto tr775;
	case 77: goto tr2;
	case 78: goto tr2;
	case 79: goto tr2;
	case 80: goto tr2;
	case 81: goto tr2;
	case 82: goto tr2;
	case 83: goto tr2;
	case 84: goto tr2;
	case 85: goto tr2;
	case 86: goto tr2;
	case 87: goto tr2;
	case 88: goto tr2;
	case 89: goto tr2;
	case 90: goto tr2;
	case 91: goto tr2;
	case 92: goto tr2;
	case 93: goto tr2;
	case 94: goto tr2;
	case 95: goto tr2;
	case 96: goto tr2;
	case 97: goto tr2;
	case 98: goto tr2;
	case 99: goto tr2;
	case 100: goto tr2;
	case 101: goto tr2;
	case 102: goto tr2;
	case 714: goto tr780;
	case 103: goto tr105;
	case 104: goto tr105;
	case 105: goto tr105;
	case 106: goto tr105;
	case 107: goto tr105;
	case 108: goto tr105;
	case 109: goto tr105;
	case 110: goto tr105;
	case 111: goto tr105;
	case 112: goto tr105;
	case 113: goto tr105;
	case 114: goto tr105;
	case 115: goto tr105;
	case 116: goto tr105;
	case 117: goto tr105;
	case 118: goto tr105;
	case 119: goto tr105;
	case 120: goto tr105;
	case 121: goto tr105;
	case 715: goto tr780;
	case 122: goto tr105;
	case 123: goto tr105;
	case 124: goto tr105;
	case 125: goto tr105;
	case 126: goto tr105;
	case 127: goto tr105;
	case 128: goto tr105;
	case 129: goto tr105;
	case 130: goto tr105;
	case 717: goto tr815;
	case 718: goto tr818;
	case 131: goto tr133;
	case 132: goto tr135;
	case 133: goto tr135;
	case 719: goto tr819;
	case 720: goto tr819;
	case 721: goto tr821;
	case 722: goto tr822;
	case 134: goto tr140;
	case 135: goto tr140;
	case 136: goto tr140;
	case 137: goto tr140;
	case 138: goto tr133;
	case 723: goto tr824;
	case 139: goto tr133;
	case 140: goto tr133;
	case 141: goto tr140;
	case 142: goto tr140;
	case 143: goto tr140;
	case 144: goto tr140;
	case 145: goto tr140;
	case 146: goto tr140;
	case 147: goto tr140;
	case 148: goto tr140;
	case 149: goto tr140;
	case 150: goto tr140;
	case 151: goto tr140;
	case 152: goto tr140;
	case 153: goto tr140;
	case 154: goto tr140;
	case 155: goto tr140;
	case 156: goto tr140;
	case 157: goto tr140;
	case 158: goto tr140;
	case 159: goto tr140;
	case 160: goto tr140;
	case 724: goto tr822;
	case 161: goto tr140;
	case 162: goto tr140;
	case 163: goto tr140;
	case 164: goto tr140;
	case 165: goto tr140;
	case 725: goto tr825;
	case 726: goto tr827;
	case 166: goto tr140;
	case 167: goto tr140;
	case 168: goto tr140;
	case 727: goto tr829;
	case 728: goto tr831;
	case 169: goto tr140;
	case 729: goto tr822;
	case 170: goto tr140;
	case 171: goto tr140;
	case 172: goto tr140;
	case 173: goto tr140;
	case 174: goto tr140;
	case 175: goto tr140;
	case 176: goto tr140;
	case 177: goto tr140;
	case 178: goto tr140;
	case 179: goto tr140;
	case 180: goto tr140;
	case 730: goto tr844;
	case 181: goto tr140;
	case 182: goto tr140;
	case 183: goto tr140;
	case 184: goto tr140;
	case 185: goto tr140;
	case 186: goto tr140;
	case 187: goto tr140;
	case 188: goto tr140;
	case 189: goto tr140;
	case 190: goto tr140;
	case 191: goto tr140;
	case 192: goto tr140;
	case 193: goto tr140;
	case 194: goto tr140;
	case 195: goto tr140;
	case 196: goto tr140;
	case 197: goto tr140;
	case 198: goto tr140;
	case 199: goto tr140;
	case 200: goto tr140;
	case 201: goto tr140;
	case 202: goto tr140;
	case 203: goto tr140;
	case 204: goto tr140;
	case 205: goto tr140;
	case 206: goto tr140;
	case 207: goto tr140;
	case 208: goto tr140;
	case 209: goto tr140;
	case 210: goto tr140;
	case 211: goto tr140;
	case 212: goto tr140;
	case 213: goto tr140;
	case 214: goto tr140;
	case 215: goto tr140;
	case 216: goto tr140;
	case 217: goto tr140;
	case 218: goto tr140;
	case 219: goto tr140;
	case 220: goto tr140;
	case 221: goto tr140;
	case 222: goto tr140;
	case 223: goto tr140;
	case 224: goto tr140;
	case 225: goto tr140;
	case 226: goto tr140;
	case 227: goto tr140;
	case 228: goto tr140;
	case 229: goto tr140;
	case 230: goto tr140;
	case 231: goto tr140;
	case 232: goto tr140;
	case 233: goto tr140;
	case 234: goto tr140;
	case 235: goto tr140;
	case 236: goto tr140;
	case 237: goto tr140;
	case 238: goto tr140;
	case 239: goto tr140;
	case 240: goto tr140;
	case 241: goto tr140;
	case 242: goto tr140;
	case 243: goto tr140;
	case 244: goto tr140;
	case 245: goto tr140;
	case 246: goto tr140;
	case 247: goto tr140;
	case 248: goto tr140;
	case 249: goto tr140;
	case 250: goto tr140;
	case 251: goto tr140;
	case 252: goto tr140;
	case 253: goto tr140;
	case 254: goto tr140;
	case 255: goto tr140;
	case 256: goto tr140;
	case 257: goto tr140;
	case 258: goto tr140;
	case 259: goto tr140;
	case 260: goto tr140;
	case 261: goto tr140;
	case 262: goto tr140;
	case 263: goto tr140;
	case 264: goto tr140;
	case 265: goto tr140;
	case 266: goto tr140;
	case 267: goto tr140;
	case 268: goto tr140;
	case 269: goto tr140;
	case 270: goto tr140;
	case 271: goto tr140;
	case 272: goto tr140;
	case 273: goto tr140;
	case 274: goto tr140;
	case 275: goto tr140;
	case 276: goto tr140;
	case 277: goto tr140;
	case 278: goto tr140;
	case 279: goto tr140;
	case 280: goto tr140;
	case 281: goto tr140;
	case 282: goto tr140;
	case 283: goto tr140;
	case 284: goto tr140;
	case 285: goto tr140;
	case 286: goto tr140;
	case 287: goto tr140;
	case 288: goto tr140;
	case 289: goto tr140;
	case 290: goto tr140;
	case 291: goto tr140;
	case 292: goto tr140;
	case 731: goto tr822;
	case 293: goto tr133;
	case 732: goto tr849;
	case 294: goto tr133;
	case 295: goto tr133;
	case 733: goto tr851;
	case 734: goto tr822;
	case 296: goto tr140;
	case 297: goto tr140;
	case 298: goto tr140;
	case 299: goto tr140;
	case 300: goto tr140;
	case 301: goto tr140;
	case 735: goto tr856;
	case 302: goto tr140;
	case 303: goto tr140;
	case 304: goto tr140;
	case 305: goto tr140;
	case 306: goto tr140;
	case 307: goto tr140;
	case 308: goto tr140;
	case 736: goto tr858;
	case 309: goto tr140;
	case 310: goto tr140;
	case 311: goto tr140;
	case 312: goto tr140;
	case 313: goto tr140;
	case 314: goto tr140;
	case 315: goto tr140;
	case 737: goto tr860;
	case 316: goto tr140;
	case 317: goto tr140;
	case 318: goto tr140;
	case 319: goto tr140;
	case 320: goto tr140;
	case 321: goto tr140;
	case 322: goto tr140;
	case 323: goto tr140;
	case 324: goto tr140;
	case 738: goto tr862;
	case 739: goto tr822;
	case 325: goto tr140;
	case 326: goto tr140;
	case 327: goto tr140;
	case 328: goto tr140;
	case 740: goto tr866;
	case 329: goto tr140;
	case 330: goto tr140;
	case 331: goto tr140;
	case 332: goto tr140;
	case 741: goto tr868;
	case 742: goto tr822;
	case 333: goto tr140;
	case 334: goto tr140;
	case 335: goto tr140;
	case 336: goto tr140;
	case 337: goto tr140;
	case 338: goto tr140;
	case 339: goto tr140;
	case 340: goto tr140;
	case 743: goto tr871;
	case 341: goto tr140;
	case 342: goto tr140;
	case 343: goto tr140;
	case 344: goto tr140;
	case 744: goto tr873;
	case 745: goto tr822;
	case 345: goto tr140;
	case 346: goto tr140;
	case 347: goto tr140;
	case 348: goto tr140;
	case 349: goto tr140;
	case 350: goto tr140;
	case 351: goto tr140;
	case 352: goto tr140;
	case 353: goto tr140;
	case 354: goto tr140;
	case 355: goto tr140;
	case 746: goto tr877;
	case 356: goto tr140;
	case 357: goto tr140;
	case 358: goto tr140;
	case 359: goto tr140;
	case 360: goto tr140;
	case 361: goto tr140;
	case 747: goto tr879;
	case 362: goto tr399;
	case 748: goto tr882;
	case 749: goto tr822;
	case 363: goto tr140;
	case 364: goto tr140;
	case 365: goto tr140;
	case 366: goto tr140;
	case 367: goto tr140;
	case 368: goto tr140;
	case 369: goto tr140;
	case 370: goto tr140;
	case 371: goto tr140;
	case 750: goto tr888;
	case 372: goto tr140;
	case 373: goto tr140;
	case 374: goto tr140;
	case 375: goto tr140;
	case 376: goto tr140;
	case 377: goto tr140;
	case 378: goto tr140;
	case 379: goto tr140;
	case 380: goto tr140;
	case 751: goto tr890;
	case 381: goto tr140;
	case 382: goto tr140;
	case 383: goto tr140;
	case 384: goto tr140;
	case 385: goto tr140;
	case 752: goto tr892;
	case 386: goto tr140;
	case 387: goto tr140;
	case 388: goto tr140;
	case 389: goto tr140;
	case 390: goto tr140;
	case 391: goto tr140;
	case 753: goto tr894;
	case 754: goto tr822;
	case 392: goto tr140;
	case 393: goto tr140;
	case 394: goto tr140;
	case 395: goto tr140;
	case 396: goto tr140;
	case 397: goto tr140;
	case 398: goto tr140;
	case 399: goto tr140;
	case 400: goto tr140;
	case 755: goto tr897;
	case 756: goto tr822;
	case 401: goto tr140;
	case 402: goto tr140;
	case 403: goto tr140;
	case 404: goto tr140;
	case 405: goto tr140;
	case 406: goto tr140;
	case 407: goto tr140;
	case 408: goto tr140;
	case 409: goto tr140;
	case 410: goto tr140;
	case 411: goto tr140;
	case 412: goto tr140;
	case 757: goto tr901;
	case 413: goto tr140;
	case 414: goto tr140;
	case 415: goto tr140;
	case 416: goto tr140;
	case 417: goto tr140;
	case 418: goto tr140;
	case 758: goto tr903;
	case 759: goto tr822;
	case 419: goto tr140;
	case 420: goto tr140;
	case 421: goto tr140;
	case 422: goto tr140;
	case 423: goto tr140;
	case 424: goto tr140;
	case 425: goto tr140;
	case 426: goto tr140;
	case 427: goto tr140;
	case 428: goto tr140;
	case 429: goto tr140;
	case 760: goto tr906;
	case 430: goto tr140;
	case 431: goto tr140;
	case 432: goto tr140;
	case 433: goto tr140;
	case 434: goto tr140;
	case 435: goto tr140;
	case 436: goto tr140;
	case 437: goto tr140;
	case 761: goto tr908;
	case 762: goto tr822;
	case 438: goto tr140;
	case 439: goto tr140;
	case 440: goto tr140;
	case 441: goto tr140;
	case 442: goto tr140;
	case 443: goto tr140;
	case 763: goto tr912;
	case 444: goto tr140;
	case 445: goto tr140;
	case 446: goto tr140;
	case 447: goto tr140;
	case 448: goto tr140;
	case 764: goto tr914;
	case 765: goto tr822;
	case 449: goto tr140;
	case 450: goto tr140;
	case 451: goto tr140;
	case 452: goto tr140;
	case 453: goto tr140;
	case 454: goto tr140;
	case 766: goto tr920;
	case 455: goto tr140;
	case 456: goto tr140;
	case 457: goto tr140;
	case 458: goto tr140;
	case 459: goto tr140;
	case 460: goto tr140;
	case 767: goto tr922;
	case 461: goto tr500;
	case 462: goto tr500;
	case 768: goto tr925;
	case 463: goto tr140;
	case 464: goto tr140;
	case 465: goto tr140;
	case 466: goto tr140;
	case 467: goto tr140;
	case 769: goto tr927;
	case 468: goto tr140;
	case 469: goto tr140;
	case 470: goto tr140;
	case 471: goto tr140;
	case 770: goto tr929;
	case 472: goto tr140;
	case 473: goto tr140;
	case 474: goto tr140;
	case 475: goto tr140;
	case 476: goto tr140;
	case 771: goto tr931;
	case 772: goto tr822;
	case 477: goto tr140;
	case 478: goto tr140;
	case 479: goto tr140;
	case 480: goto tr140;
	case 481: goto tr140;
	case 482: goto tr140;
	case 483: goto tr140;
	case 484: goto tr140;
	case 773: goto tr935;
	case 485: goto tr140;
	case 486: goto tr140;
	case 487: goto tr140;
	case 488: goto tr140;
	case 489: goto tr140;
	case 490: goto tr140;
	case 774: goto tr937;
	case 775: goto tr822;
	case 491: goto tr140;
	case 492: goto tr140;
	case 493: goto tr140;
	case 494: goto tr140;
	case 495: goto tr140;
	case 496: goto tr140;
	case 776: goto tr941;
	case 497: goto tr538;
	case 498: goto tr538;
	case 777: goto tr944;
	case 499: goto tr140;
	case 500: goto tr140;
	case 501: goto tr140;
	case 502: goto tr140;
	case 503: goto tr140;
	case 504: goto tr140;
	case 505: goto tr140;
	case 506: goto tr140;
	case 778: goto tr946;
	case 779: goto tr822;
	case 507: goto tr140;
	case 508: goto tr140;
	case 509: goto tr140;
	case 510: goto tr140;
	case 511: goto tr140;
	case 780: goto tr949;
	case 781: goto tr822;
	case 512: goto tr140;
	case 513: goto tr140;
	case 514: goto tr140;
	case 515: goto tr140;
	case 516: goto tr140;
	case 782: goto tr952;
	case 783: goto tr822;
	case 517: goto tr140;
	case 518: goto tr140;
	case 519: goto tr140;
	case 520: goto tr140;
	case 521: goto tr140;
	case 522: goto tr140;
	case 523: goto tr140;
	case 524: goto tr140;
	case 784: goto tr955;
	case 785: goto tr822;
	case 525: goto tr140;
	case 526: goto tr140;
	case 527: goto tr140;
	case 528: goto tr140;
	case 529: goto tr140;
	case 530: goto tr140;
	case 531: goto tr140;
	case 532: goto tr140;
	case 533: goto tr140;
	case 534: goto tr140;
	case 535: goto tr140;
	case 536: goto tr140;
	case 537: goto tr140;
	case 538: goto tr140;
	case 539: goto tr140;
	case 540: goto tr140;
	case 541: goto tr140;
	case 542: goto tr140;
	case 543: goto tr140;
	case 544: goto tr140;
	case 545: goto tr140;
	case 546: goto tr140;
	case 547: goto tr140;
	case 548: goto tr140;
	case 549: goto tr140;
	case 550: goto tr140;
	case 551: goto tr140;
	case 552: goto tr140;
	case 553: goto tr140;
	case 554: goto tr140;
	case 555: goto tr140;
	case 556: goto tr140;
	case 557: goto tr140;
	case 558: goto tr140;
	case 559: goto tr140;
	case 560: goto tr140;
	case 561: goto tr140;
	case 562: goto tr140;
	case 563: goto tr140;
	case 564: goto tr140;
	case 565: goto tr140;
	case 566: goto tr140;
	case 567: goto tr140;
	case 568: goto tr140;
	case 569: goto tr140;
	case 570: goto tr140;
	case 571: goto tr140;
	case 572: goto tr140;
	case 573: goto tr140;
	case 574: goto tr140;
	case 575: goto tr140;
	case 576: goto tr140;
	case 577: goto tr140;
	case 578: goto tr140;
	case 579: goto tr140;
	case 580: goto tr140;
	case 581: goto tr140;
	case 582: goto tr140;
	case 583: goto tr140;
	case 584: goto tr140;
	case 585: goto tr140;
	case 586: goto tr140;
	case 587: goto tr140;
	case 588: goto tr140;
	case 589: goto tr140;
	case 590: goto tr140;
	case 591: goto tr140;
	case 592: goto tr140;
	case 593: goto tr140;
	case 594: goto tr140;
	case 595: goto tr140;
	case 596: goto tr140;
	case 597: goto tr140;
	case 598: goto tr140;
	case 599: goto tr140;
	case 600: goto tr140;
	case 601: goto tr140;
	case 786: goto tr822;
	case 602: goto tr140;
	case 603: goto tr140;
	case 604: goto tr140;
	case 605: goto tr140;
	case 606: goto tr140;
	case 607: goto tr140;
	case 608: goto tr133;
	case 787: goto tr969;
	case 609: goto tr133;
	case 610: goto tr133;
	case 611: goto tr140;
	case 788: goto tr822;
	case 612: goto tr140;
	case 613: goto tr140;
	case 614: goto tr140;
	case 790: goto tr974;
	case 615: goto tr649;
	case 616: goto tr649;
	case 617: goto tr649;
	case 618: goto tr649;
	case 619: goto tr649;
	case 791: goto tr974;
	case 620: goto tr649;
	case 621: goto tr649;
	case 622: goto tr649;
	case 623: goto tr649;
	case 624: goto tr649;
	case 793: goto tr980;
	case 625: goto tr659;
	case 626: goto tr659;
	case 627: goto tr659;
	case 628: goto tr659;
	case 629: goto tr659;
	case 630: goto tr659;
	case 631: goto tr659;
	case 632: goto tr659;
	case 794: goto tr980;
	case 633: goto tr659;
	case 634: goto tr659;
	case 635: goto tr659;
	case 636: goto tr659;
	case 637: goto tr659;
	case 638: goto tr659;
	case 639: goto tr659;
	case 640: goto tr659;
	case 796: goto tr986;
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
	case 797: goto tr986;
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
	case 799: goto tr733;
	case 693: goto tr733;
	case 800: goto tr996;
	case 801: goto tr996;
	case 694: goto tr735;
	case 802: goto tr997;
	case 803: goto tr997;
	case 695: goto tr735;
	}
	}

	_out: {}
	}

#line 1301 "ext/dtext/dtext.rl"

  dstack_close(sm);

  return sm->error == NULL;
}

/* Everything below is optional, it's only needed to build bin/cdtext.exe. */
#ifdef CDTEXT

static void parse_file(FILE* input, FILE* output, gboolean opt_inline, gboolean opt_mentions) {
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

  StateMachine* sm = init_machine(dtext, length);
  sm->f_inline = opt_inline;
  sm->f_mentions = opt_mentions;

  if (!parse_helper(sm)) {
    fprintf(stderr, "dtext parse error: %s\n", sm->error->message);
    exit(1);
  }

  if (fwrite(sm->output->str, 1, sm->output->len, output) != sm->output->len) {
    perror("fwrite failed");
    exit(1);
  }

  free_machine(sm);
}

int main(int argc, char* argv[]) {
  GError* error = NULL;
  gboolean opt_verbose = FALSE;
  gboolean opt_inline = FALSE;
  gboolean opt_no_mentions = FALSE;

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
