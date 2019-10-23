
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


#line 793 "ext/dtext/dtext.rl"



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
	0, 76, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 76, 0, 0, 76, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 76, 
	0, 0, 76, 0, 0, 76, 0, 0, 
	76, 0, 0, 0, 0, 0
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
	0, 77, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 77, 0, 0, 77, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 77, 
	0, 0, 77, 0, 0, 77, 0, 0, 
	77, 0, 0, 0, 0, 0
};

static const int dtext_start = 657;
static const int dtext_first_final = 657;
static const int dtext_error = -1;

static const int dtext_en_basic_inline = 674;
static const int dtext_en_inline = 677;
static const int dtext_en_code = 735;
static const int dtext_en_nodtext = 738;
static const int dtext_en_table = 741;
static const int dtext_en_list = 744;
static const int dtext_en_main = 657;


#line 796 "ext/dtext/dtext.rl"

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

static inline void append_id_link(StateMachine * sm, const char * title, const char * id_name, const char * url) {
  if (url[0] == '/') {
    append(sm, "<a class=\"dtext-link dtext-id-link dtext-");
  } else {
    append(sm, "<a rel=\"external nofollow noreferrer\" class=\"dtext-link dtext-id-link dtext-");
  }

  append(sm, id_name);
  append(sm, "-id-link\" href=\"");
  append(sm, url);
  append_segment_uri_escaped(sm, sm->a1, sm->a2 - 1);
  append(sm, "\">");
  append(sm, title);
  append(sm, " #");
  append_segment_html_escaped(sm, sm->a1, sm->a2 - 1);
  append(sm, "</a>");
}

static inline void append_url(StateMachine * sm, const char * url_start, const char * url_end, const char * title_start, const char * title_end) {
  append(sm, "<a rel=\"external nofollow noreferrer\" class=\"dtext-link dtext-external-link\" href=\"");
  append_segment_html_escaped(sm, url_start, url_end);
  append(sm, "\">");
  append_segment_html_escaped(sm, title_start, title_end);
  append(sm, "</a>");
}

static inline bool append_named_url(StateMachine * sm, const char * url_start, const char * url_end, const char * title_start, const char * title_end) {
  g_autoptr(GString) parsed_title = parse_basic_inline(title_start, title_end - title_start);

  if (!parsed_title) {
    return false;
  }

  if (url_start[0] == '/' || url_start[0] == '#') {
    append(sm, "<a class=\"dtext-link\" href=\"");
  } else {
    append(sm, "<a rel=\"external nofollow noreferrer\" class=\"dtext-link dtext-external-link dtext-named-external-link\" href=\"");
  }

  append_segment_html_escaped(sm, url_start, url_end);
  append(sm, "\">");
  append_segment(sm, parsed_title->str, parsed_title->str + parsed_title->len - 1);
  append(sm, "</a>");

  return true;
}

static inline void append_wiki_link(StateMachine * sm, const char * tag, const size_t tag_len, const char * title, const size_t title_len) {
  g_autofree gchar* lowercased_tag = g_utf8_strdown(tag, tag_len);
  g_autoptr(GString) normalized_tag = g_string_new(g_strdelimit(lowercased_tag, " ", '_'));

  append(sm, "<a class=\"dtext-link dtext-wiki-link\" href=\"/wiki_pages/show_or_new?title=");
  append_segment_uri_escaped(sm, normalized_tag->str, normalized_tag->str + normalized_tag->len - 1);
  append(sm, "\">");
  append_segment_html_escaped(sm, title, title + title_len - 1);
  append(sm, "</a>");
}

static inline void append_paged_link(StateMachine * sm, const char * title, const char * ahref, const char * param) {
  append(sm, ahref);
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
    case BLOCK_EXPAND: append_block(sm, "</div></div>"); break;
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

StateMachine* init_machine(const char * src, size_t len, bool f_inline, bool f_mentions) {
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
  sm->f_inline = f_inline;
  sm->f_mentions = f_mentions;
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
    StateMachine* sm = init_machine(dtext, length, true, false);
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

  
#line 656 "ext/dtext/dtext.c"
	{
	( sm->top) = 0;
	( sm->ts) = 0;
	( sm->te) = 0;
	( sm->act) = 0;
	}

#line 1190 "ext/dtext/dtext.rl"
  
#line 666 "ext/dtext/dtext.c"
	{
	if ( ( sm->p) == ( sm->pe) )
		goto _test_eof;
_resume:
	switch ( _dtext_from_state_actions[ sm->cs] ) {
	case 77:
#line 1 "NONE"
	{( sm->ts) = ( sm->p);}
	break;
#line 676 "ext/dtext/dtext.c"
	}

	switch (  sm->cs ) {
case 657:
	switch( (*( sm->p)) ) {
		case 10: goto tr695;
		case 13: goto tr696;
		case 42: goto tr697;
		case 60: goto tr698;
		case 72: goto tr699;
		case 91: goto tr700;
		case 104: goto tr699;
	}
	goto tr694;
case 658:
	switch( (*( sm->p)) ) {
		case 10: goto tr1;
		case 13: goto tr701;
	}
	goto tr0;
case 0:
	if ( (*( sm->p)) == 10 )
		goto tr1;
	goto tr0;
case 659:
	if ( (*( sm->p)) == 10 )
		goto tr695;
	goto tr702;
case 660:
	switch( (*( sm->p)) ) {
		case 9: goto tr5;
		case 32: goto tr5;
		case 42: goto tr6;
	}
	goto tr702;
case 1:
	switch( (*( sm->p)) ) {
		case 9: goto tr4;
		case 10: goto tr2;
		case 13: goto tr2;
		case 32: goto tr4;
	}
	goto tr3;
case 661:
	switch( (*( sm->p)) ) {
		case 10: goto tr703;
		case 13: goto tr703;
	}
	goto tr704;
case 662:
	switch( (*( sm->p)) ) {
		case 9: goto tr4;
		case 10: goto tr703;
		case 13: goto tr703;
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
case 663:
	switch( (*( sm->p)) ) {
		case 47: goto tr705;
		case 66: goto tr706;
		case 67: goto tr707;
		case 69: goto tr708;
		case 78: goto tr709;
		case 81: goto tr20;
		case 83: goto tr710;
		case 84: goto tr711;
		case 98: goto tr706;
		case 99: goto tr707;
		case 101: goto tr708;
		case 110: goto tr709;
		case 113: goto tr20;
		case 115: goto tr710;
		case 116: goto tr711;
	}
	goto tr702;
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
case 664:
	if ( (*( sm->p)) == 32 )
		goto tr25;
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr25;
	goto tr712;
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
case 665:
	if ( (*( sm->p)) == 32 )
		goto tr29;
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr29;
	goto tr713;
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
case 666:
	if ( (*( sm->p)) == 32 )
		goto tr35;
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr35;
	goto tr714;
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
case 667:
	if ( (*( sm->p)) == 32 )
		goto tr42;
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr42;
	goto tr715;
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
case 668:
	if ( (*( sm->p)) == 32 )
		goto tr49;
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr49;
	goto tr716;
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
case 669:
	if ( 49 <= (*( sm->p)) && (*( sm->p)) <= 54 )
		goto tr717;
	goto tr702;
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
case 670:
	switch( (*( sm->p)) ) {
		case 9: goto tr719;
		case 32: goto tr719;
	}
	goto tr718;
case 671:
	switch( (*( sm->p)) ) {
		case 9: goto tr721;
		case 32: goto tr721;
	}
	goto tr720;
case 672:
	switch( (*( sm->p)) ) {
		case 47: goto tr722;
		case 67: goto tr723;
		case 69: goto tr724;
		case 78: goto tr725;
		case 81: goto tr726;
		case 83: goto tr727;
		case 84: goto tr728;
		case 99: goto tr723;
		case 101: goto tr729;
		case 110: goto tr725;
		case 113: goto tr726;
		case 115: goto tr727;
		case 116: goto tr730;
	}
	goto tr702;
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
	if ( (*( sm->p)) == 61 )
		goto tr79;
	goto tr2;
case 75:
	if ( (*( sm->p)) == 93 )
		goto tr2;
	goto tr80;
case 76:
	if ( (*( sm->p)) == 93 )
		goto tr82;
	goto tr81;
case 673:
	if ( (*( sm->p)) == 32 )
		goto tr732;
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr732;
	goto tr731;
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
		case 78: goto tr100;
		case 110: goto tr100;
	}
	goto tr2;
case 98:
	if ( (*( sm->p)) == 93 )
		goto tr57;
	goto tr2;
case 99:
	switch( (*( sm->p)) ) {
		case 88: goto tr74;
		case 120: goto tr101;
	}
	goto tr2;
case 100:
	switch( (*( sm->p)) ) {
		case 80: goto tr75;
		case 112: goto tr102;
	}
	goto tr2;
case 101:
	switch( (*( sm->p)) ) {
		case 65: goto tr76;
		case 97: goto tr103;
	}
	goto tr2;
case 102:
	switch( (*( sm->p)) ) {
		case 78: goto tr77;
		case 110: goto tr104;
	}
	goto tr2;
case 103:
	switch( (*( sm->p)) ) {
		case 68: goto tr78;
		case 100: goto tr105;
	}
	goto tr2;
case 104:
	switch( (*( sm->p)) ) {
		case 61: goto tr79;
		case 93: goto tr35;
	}
	goto tr2;
case 105:
	switch( (*( sm->p)) ) {
		case 78: goto tr100;
		case 97: goto tr106;
		case 110: goto tr100;
	}
	goto tr2;
case 106:
	if ( (*( sm->p)) == 98 )
		goto tr107;
	goto tr2;
case 107:
	if ( (*( sm->p)) == 108 )
		goto tr108;
	goto tr2;
case 108:
	if ( (*( sm->p)) == 101 )
		goto tr109;
	goto tr2;
case 109:
	if ( (*( sm->p)) == 93 )
		goto tr56;
	goto tr2;
case 674:
	switch( (*( sm->p)) ) {
		case 60: goto tr734;
		case 91: goto tr735;
	}
	goto tr733;
case 675:
	switch( (*( sm->p)) ) {
		case 47: goto tr737;
		case 66: goto tr132;
		case 69: goto tr738;
		case 73: goto tr125;
		case 83: goto tr739;
		case 85: goto tr740;
		case 98: goto tr132;
		case 101: goto tr738;
		case 105: goto tr125;
		case 115: goto tr739;
		case 117: goto tr740;
	}
	goto tr736;
case 110:
	switch( (*( sm->p)) ) {
		case 66: goto tr111;
		case 69: goto tr112;
		case 73: goto tr113;
		case 83: goto tr114;
		case 85: goto tr115;
		case 98: goto tr111;
		case 101: goto tr112;
		case 105: goto tr113;
		case 115: goto tr114;
		case 117: goto tr115;
	}
	goto tr110;
case 111:
	if ( (*( sm->p)) == 62 )
		goto tr116;
	goto tr110;
case 112:
	switch( (*( sm->p)) ) {
		case 77: goto tr113;
		case 109: goto tr113;
	}
	goto tr110;
case 113:
	if ( (*( sm->p)) == 62 )
		goto tr117;
	goto tr110;
case 114:
	switch( (*( sm->p)) ) {
		case 62: goto tr118;
		case 84: goto tr119;
		case 116: goto tr119;
	}
	goto tr110;
case 115:
	switch( (*( sm->p)) ) {
		case 82: goto tr120;
		case 114: goto tr120;
	}
	goto tr110;
case 116:
	switch( (*( sm->p)) ) {
		case 79: goto tr121;
		case 111: goto tr121;
	}
	goto tr110;
case 117:
	switch( (*( sm->p)) ) {
		case 78: goto tr122;
		case 110: goto tr122;
	}
	goto tr110;
case 118:
	switch( (*( sm->p)) ) {
		case 71: goto tr111;
		case 103: goto tr111;
	}
	goto tr110;
case 119:
	if ( (*( sm->p)) == 62 )
		goto tr123;
	goto tr110;
case 120:
	if ( (*( sm->p)) == 62 )
		goto tr124;
	goto tr110;
case 121:
	switch( (*( sm->p)) ) {
		case 77: goto tr125;
		case 109: goto tr125;
	}
	goto tr110;
case 122:
	if ( (*( sm->p)) == 62 )
		goto tr126;
	goto tr110;
case 123:
	switch( (*( sm->p)) ) {
		case 62: goto tr127;
		case 84: goto tr128;
		case 116: goto tr128;
	}
	goto tr110;
case 124:
	switch( (*( sm->p)) ) {
		case 82: goto tr129;
		case 114: goto tr129;
	}
	goto tr110;
case 125:
	switch( (*( sm->p)) ) {
		case 79: goto tr130;
		case 111: goto tr130;
	}
	goto tr110;
case 126:
	switch( (*( sm->p)) ) {
		case 78: goto tr131;
		case 110: goto tr131;
	}
	goto tr110;
case 127:
	switch( (*( sm->p)) ) {
		case 71: goto tr132;
		case 103: goto tr132;
	}
	goto tr110;
case 128:
	if ( (*( sm->p)) == 62 )
		goto tr133;
	goto tr110;
case 676:
	switch( (*( sm->p)) ) {
		case 47: goto tr741;
		case 66: goto tr742;
		case 73: goto tr743;
		case 83: goto tr744;
		case 85: goto tr745;
		case 98: goto tr742;
		case 105: goto tr743;
		case 115: goto tr744;
		case 117: goto tr745;
	}
	goto tr736;
case 129:
	switch( (*( sm->p)) ) {
		case 66: goto tr134;
		case 73: goto tr135;
		case 83: goto tr136;
		case 85: goto tr137;
		case 98: goto tr134;
		case 105: goto tr135;
		case 115: goto tr136;
		case 117: goto tr137;
	}
	goto tr110;
case 130:
	if ( (*( sm->p)) == 93 )
		goto tr116;
	goto tr110;
case 131:
	if ( (*( sm->p)) == 93 )
		goto tr117;
	goto tr110;
case 132:
	if ( (*( sm->p)) == 93 )
		goto tr118;
	goto tr110;
case 133:
	if ( (*( sm->p)) == 93 )
		goto tr123;
	goto tr110;
case 134:
	if ( (*( sm->p)) == 93 )
		goto tr124;
	goto tr110;
case 135:
	if ( (*( sm->p)) == 93 )
		goto tr126;
	goto tr110;
case 136:
	if ( (*( sm->p)) == 93 )
		goto tr127;
	goto tr110;
case 137:
	if ( (*( sm->p)) == 93 )
		goto tr133;
	goto tr110;
case 677:
	switch( (*( sm->p)) ) {
		case 10: goto tr747;
		case 13: goto tr748;
		case 34: goto tr749;
		case 60: goto tr750;
		case 64: goto tr751;
		case 65: goto tr752;
		case 66: goto tr753;
		case 67: goto tr754;
		case 68: goto tr755;
		case 70: goto tr756;
		case 73: goto tr757;
		case 77: goto tr758;
		case 78: goto tr759;
		case 80: goto tr760;
		case 83: goto tr761;
		case 84: goto tr762;
		case 85: goto tr763;
		case 87: goto tr764;
		case 91: goto tr765;
		case 97: goto tr752;
		case 98: goto tr753;
		case 99: goto tr754;
		case 100: goto tr755;
		case 102: goto tr756;
		case 104: goto tr766;
		case 105: goto tr757;
		case 109: goto tr758;
		case 110: goto tr759;
		case 112: goto tr760;
		case 115: goto tr761;
		case 116: goto tr762;
		case 117: goto tr763;
		case 119: goto tr764;
		case 123: goto tr767;
	}
	goto tr746;
case 678:
	switch( (*( sm->p)) ) {
		case 10: goto tr139;
		case 13: goto tr769;
		case 42: goto tr770;
	}
	goto tr768;
case 679:
	switch( (*( sm->p)) ) {
		case 10: goto tr139;
		case 13: goto tr769;
	}
	goto tr771;
case 138:
	if ( (*( sm->p)) == 10 )
		goto tr139;
	goto tr138;
case 139:
	switch( (*( sm->p)) ) {
		case 9: goto tr141;
		case 32: goto tr141;
		case 42: goto tr142;
	}
	goto tr140;
case 140:
	switch( (*( sm->p)) ) {
		case 9: goto tr144;
		case 10: goto tr140;
		case 13: goto tr140;
		case 32: goto tr144;
	}
	goto tr143;
case 680:
	switch( (*( sm->p)) ) {
		case 10: goto tr772;
		case 13: goto tr772;
	}
	goto tr773;
case 681:
	switch( (*( sm->p)) ) {
		case 9: goto tr144;
		case 10: goto tr772;
		case 13: goto tr772;
		case 32: goto tr144;
	}
	goto tr143;
case 682:
	if ( (*( sm->p)) == 10 )
		goto tr747;
	goto tr774;
case 683:
	if ( (*( sm->p)) == 34 )
		goto tr775;
	goto tr776;
case 141:
	if ( (*( sm->p)) == 34 )
		goto tr147;
	goto tr146;
case 142:
	if ( (*( sm->p)) == 58 )
		goto tr148;
	goto tr145;
case 143:
	switch( (*( sm->p)) ) {
		case 35: goto tr149;
		case 47: goto tr149;
		case 91: goto tr150;
		case 104: goto tr151;
	}
	goto tr145;
case 144:
	if ( (*( sm->p)) < -32 ) {
		if ( -62 <= (*( sm->p)) && (*( sm->p)) <= -33 )
			goto tr152;
	} else if ( (*( sm->p)) > -17 ) {
		if ( (*( sm->p)) > -12 ) {
			if ( 33 <= (*( sm->p)) && (*( sm->p)) <= 126 )
				goto tr155;
		} else if ( (*( sm->p)) >= -16 )
			goto tr154;
	} else
		goto tr153;
	goto tr145;
case 145:
	if ( (*( sm->p)) <= -65 )
		goto tr155;
	goto tr138;
case 684:
	if ( (*( sm->p)) < -32 ) {
		if ( -62 <= (*( sm->p)) && (*( sm->p)) <= -33 )
			goto tr152;
	} else if ( (*( sm->p)) > -17 ) {
		if ( (*( sm->p)) > -12 ) {
			if ( 33 <= (*( sm->p)) && (*( sm->p)) <= 126 )
				goto tr155;
		} else if ( (*( sm->p)) >= -16 )
			goto tr154;
	} else
		goto tr153;
	goto tr777;
case 146:
	if ( (*( sm->p)) <= -65 )
		goto tr152;
	goto tr138;
case 147:
	if ( (*( sm->p)) <= -65 )
		goto tr153;
	goto tr138;
case 148:
	switch( (*( sm->p)) ) {
		case 35: goto tr156;
		case 47: goto tr156;
		case 104: goto tr157;
	}
	goto tr145;
case 149:
	if ( (*( sm->p)) < -32 ) {
		if ( -62 <= (*( sm->p)) && (*( sm->p)) <= -33 )
			goto tr158;
	} else if ( (*( sm->p)) > -17 ) {
		if ( (*( sm->p)) > -12 ) {
			if ( 33 <= (*( sm->p)) && (*( sm->p)) <= 126 )
				goto tr161;
		} else if ( (*( sm->p)) >= -16 )
			goto tr160;
	} else
		goto tr159;
	goto tr145;
case 150:
	if ( (*( sm->p)) <= -65 )
		goto tr161;
	goto tr145;
case 151:
	if ( (*( sm->p)) == 93 )
		goto tr162;
	if ( (*( sm->p)) < -32 ) {
		if ( -62 <= (*( sm->p)) && (*( sm->p)) <= -33 )
			goto tr158;
	} else if ( (*( sm->p)) > -17 ) {
		if ( (*( sm->p)) > -12 ) {
			if ( 33 <= (*( sm->p)) && (*( sm->p)) <= 126 )
				goto tr161;
		} else if ( (*( sm->p)) >= -16 )
			goto tr160;
	} else
		goto tr159;
	goto tr145;
case 152:
	if ( (*( sm->p)) <= -65 )
		goto tr158;
	goto tr145;
case 153:
	if ( (*( sm->p)) <= -65 )
		goto tr159;
	goto tr145;
case 154:
	if ( (*( sm->p)) == 116 )
		goto tr163;
	goto tr145;
case 155:
	if ( (*( sm->p)) == 116 )
		goto tr164;
	goto tr145;
case 156:
	if ( (*( sm->p)) == 112 )
		goto tr165;
	goto tr145;
case 157:
	switch( (*( sm->p)) ) {
		case 58: goto tr166;
		case 115: goto tr167;
	}
	goto tr145;
case 158:
	if ( (*( sm->p)) == 47 )
		goto tr168;
	goto tr145;
case 159:
	if ( (*( sm->p)) == 47 )
		goto tr169;
	goto tr145;
case 160:
	if ( (*( sm->p)) == 58 )
		goto tr166;
	goto tr145;
case 161:
	if ( (*( sm->p)) == 116 )
		goto tr170;
	goto tr145;
case 162:
	if ( (*( sm->p)) == 116 )
		goto tr171;
	goto tr145;
case 163:
	if ( (*( sm->p)) == 112 )
		goto tr172;
	goto tr145;
case 164:
	switch( (*( sm->p)) ) {
		case 58: goto tr173;
		case 115: goto tr174;
	}
	goto tr145;
case 165:
	if ( (*( sm->p)) == 47 )
		goto tr175;
	goto tr145;
case 166:
	if ( (*( sm->p)) == 47 )
		goto tr176;
	goto tr145;
case 167:
	if ( (*( sm->p)) == 58 )
		goto tr173;
	goto tr145;
case 685:
	switch( (*( sm->p)) ) {
		case 47: goto tr778;
		case 64: goto tr779;
		case 66: goto tr780;
		case 67: goto tr781;
		case 69: goto tr782;
		case 73: goto tr244;
		case 78: goto tr783;
		case 81: goto tr784;
		case 83: goto tr785;
		case 84: goto tr786;
		case 85: goto tr787;
		case 97: goto tr788;
		case 98: goto tr780;
		case 99: goto tr781;
		case 101: goto tr782;
		case 104: goto tr789;
		case 105: goto tr244;
		case 110: goto tr783;
		case 113: goto tr784;
		case 115: goto tr785;
		case 116: goto tr786;
		case 117: goto tr787;
	}
	goto tr775;
case 168:
	switch( (*( sm->p)) ) {
		case 66: goto tr177;
		case 69: goto tr178;
		case 73: goto tr179;
		case 83: goto tr180;
		case 84: goto tr181;
		case 85: goto tr182;
		case 98: goto tr177;
		case 101: goto tr178;
		case 105: goto tr179;
		case 115: goto tr180;
		case 116: goto tr181;
		case 117: goto tr182;
	}
	goto tr145;
case 169:
	switch( (*( sm->p)) ) {
		case 62: goto tr183;
		case 76: goto tr184;
		case 108: goto tr184;
	}
	goto tr145;
case 170:
	switch( (*( sm->p)) ) {
		case 79: goto tr185;
		case 111: goto tr185;
	}
	goto tr145;
case 171:
	switch( (*( sm->p)) ) {
		case 67: goto tr186;
		case 99: goto tr186;
	}
	goto tr145;
case 172:
	switch( (*( sm->p)) ) {
		case 75: goto tr187;
		case 107: goto tr187;
	}
	goto tr145;
case 173:
	switch( (*( sm->p)) ) {
		case 81: goto tr188;
		case 113: goto tr188;
	}
	goto tr145;
case 174:
	switch( (*( sm->p)) ) {
		case 85: goto tr189;
		case 117: goto tr189;
	}
	goto tr145;
case 175:
	switch( (*( sm->p)) ) {
		case 79: goto tr190;
		case 111: goto tr190;
	}
	goto tr145;
case 176:
	switch( (*( sm->p)) ) {
		case 84: goto tr191;
		case 116: goto tr191;
	}
	goto tr145;
case 177:
	switch( (*( sm->p)) ) {
		case 69: goto tr192;
		case 101: goto tr192;
	}
	goto tr145;
case 178:
	if ( (*( sm->p)) == 62 )
		goto tr193;
	goto tr145;
case 686:
	if ( (*( sm->p)) == 32 )
		goto tr193;
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr193;
	goto tr138;
case 179:
	switch( (*( sm->p)) ) {
		case 77: goto tr179;
		case 88: goto tr194;
		case 109: goto tr179;
		case 120: goto tr194;
	}
	goto tr145;
case 180:
	if ( (*( sm->p)) == 62 )
		goto tr195;
	goto tr145;
case 181:
	switch( (*( sm->p)) ) {
		case 80: goto tr196;
		case 112: goto tr196;
	}
	goto tr145;
case 182:
	switch( (*( sm->p)) ) {
		case 65: goto tr197;
		case 97: goto tr197;
	}
	goto tr145;
case 183:
	switch( (*( sm->p)) ) {
		case 78: goto tr198;
		case 110: goto tr198;
	}
	goto tr145;
case 184:
	switch( (*( sm->p)) ) {
		case 68: goto tr199;
		case 100: goto tr199;
	}
	goto tr145;
case 185:
	if ( (*( sm->p)) == 62 )
		goto tr200;
	goto tr145;
case 186:
	switch( (*( sm->p)) ) {
		case 62: goto tr201;
		case 80: goto tr202;
		case 84: goto tr203;
		case 112: goto tr202;
		case 116: goto tr203;
	}
	goto tr145;
case 187:
	switch( (*( sm->p)) ) {
		case 79: goto tr204;
		case 111: goto tr204;
	}
	goto tr145;
case 188:
	switch( (*( sm->p)) ) {
		case 73: goto tr205;
		case 105: goto tr205;
	}
	goto tr145;
case 189:
	switch( (*( sm->p)) ) {
		case 76: goto tr206;
		case 108: goto tr206;
	}
	goto tr145;
case 190:
	switch( (*( sm->p)) ) {
		case 69: goto tr207;
		case 101: goto tr207;
	}
	goto tr145;
case 191:
	switch( (*( sm->p)) ) {
		case 82: goto tr208;
		case 114: goto tr208;
	}
	goto tr145;
case 192:
	switch( (*( sm->p)) ) {
		case 62: goto tr209;
		case 83: goto tr210;
		case 115: goto tr210;
	}
	goto tr145;
case 193:
	if ( (*( sm->p)) == 62 )
		goto tr209;
	goto tr145;
case 194:
	switch( (*( sm->p)) ) {
		case 82: goto tr211;
		case 114: goto tr211;
	}
	goto tr145;
case 195:
	switch( (*( sm->p)) ) {
		case 79: goto tr212;
		case 111: goto tr212;
	}
	goto tr145;
case 196:
	switch( (*( sm->p)) ) {
		case 78: goto tr213;
		case 110: goto tr213;
	}
	goto tr145;
case 197:
	switch( (*( sm->p)) ) {
		case 71: goto tr214;
		case 103: goto tr214;
	}
	goto tr145;
case 198:
	if ( (*( sm->p)) == 62 )
		goto tr183;
	goto tr145;
case 199:
	switch( (*( sm->p)) ) {
		case 68: goto tr215;
		case 72: goto tr216;
		case 100: goto tr215;
		case 104: goto tr216;
	}
	goto tr145;
case 200:
	if ( (*( sm->p)) == 62 )
		goto tr217;
	goto tr145;
case 201:
	if ( (*( sm->p)) == 62 )
		goto tr218;
	goto tr145;
case 202:
	if ( (*( sm->p)) == 62 )
		goto tr219;
	goto tr145;
case 203:
	if ( (*( sm->p)) < -32 ) {
		if ( -62 <= (*( sm->p)) && (*( sm->p)) <= -33 )
			goto tr220;
	} else if ( (*( sm->p)) > -17 ) {
		if ( (*( sm->p)) > -12 ) {
			if ( 33 <= (*( sm->p)) && (*( sm->p)) <= 126 )
				goto tr223;
		} else if ( (*( sm->p)) >= -16 )
			goto tr222;
	} else
		goto tr221;
	goto tr145;
case 204:
	if ( (*( sm->p)) <= -65 )
		goto tr224;
	goto tr145;
case 205:
	if ( (*( sm->p)) == 62 )
		goto tr228;
	if ( (*( sm->p)) < -32 ) {
		if ( -62 <= (*( sm->p)) && (*( sm->p)) <= -33 )
			goto tr225;
	} else if ( (*( sm->p)) > -17 ) {
		if ( (*( sm->p)) > -12 ) {
			if ( 33 <= (*( sm->p)) && (*( sm->p)) <= 126 )
				goto tr224;
		} else if ( (*( sm->p)) >= -16 )
			goto tr227;
	} else
		goto tr226;
	goto tr145;
case 206:
	if ( (*( sm->p)) <= -65 )
		goto tr225;
	goto tr145;
case 207:
	if ( (*( sm->p)) <= -65 )
		goto tr226;
	goto tr145;
case 208:
	switch( (*( sm->p)) ) {
		case 62: goto tr229;
		case 76: goto tr230;
		case 108: goto tr230;
	}
	goto tr145;
case 209:
	switch( (*( sm->p)) ) {
		case 79: goto tr231;
		case 111: goto tr231;
	}
	goto tr145;
case 210:
	switch( (*( sm->p)) ) {
		case 67: goto tr232;
		case 99: goto tr232;
	}
	goto tr145;
case 211:
	switch( (*( sm->p)) ) {
		case 75: goto tr233;
		case 107: goto tr233;
	}
	goto tr145;
case 212:
	switch( (*( sm->p)) ) {
		case 81: goto tr234;
		case 113: goto tr234;
	}
	goto tr145;
case 213:
	switch( (*( sm->p)) ) {
		case 85: goto tr235;
		case 117: goto tr235;
	}
	goto tr145;
case 214:
	switch( (*( sm->p)) ) {
		case 79: goto tr236;
		case 111: goto tr236;
	}
	goto tr145;
case 215:
	switch( (*( sm->p)) ) {
		case 84: goto tr237;
		case 116: goto tr237;
	}
	goto tr145;
case 216:
	switch( (*( sm->p)) ) {
		case 69: goto tr238;
		case 101: goto tr238;
	}
	goto tr145;
case 217:
	if ( (*( sm->p)) == 62 )
		goto tr239;
	goto tr145;
case 218:
	switch( (*( sm->p)) ) {
		case 79: goto tr240;
		case 111: goto tr240;
	}
	goto tr145;
case 219:
	switch( (*( sm->p)) ) {
		case 68: goto tr241;
		case 100: goto tr241;
	}
	goto tr145;
case 220:
	switch( (*( sm->p)) ) {
		case 69: goto tr242;
		case 101: goto tr242;
	}
	goto tr145;
case 221:
	if ( (*( sm->p)) == 62 )
		goto tr243;
	goto tr145;
case 222:
	switch( (*( sm->p)) ) {
		case 77: goto tr244;
		case 88: goto tr245;
		case 109: goto tr244;
		case 120: goto tr245;
	}
	goto tr145;
case 223:
	if ( (*( sm->p)) == 62 )
		goto tr246;
	goto tr145;
case 224:
	switch( (*( sm->p)) ) {
		case 80: goto tr247;
		case 112: goto tr247;
	}
	goto tr145;
case 225:
	switch( (*( sm->p)) ) {
		case 65: goto tr248;
		case 97: goto tr248;
	}
	goto tr145;
case 226:
	switch( (*( sm->p)) ) {
		case 78: goto tr249;
		case 110: goto tr249;
	}
	goto tr145;
case 227:
	switch( (*( sm->p)) ) {
		case 68: goto tr250;
		case 100: goto tr250;
	}
	goto tr145;
case 228:
	if ( (*( sm->p)) == 62 )
		goto tr251;
	goto tr145;
case 229:
	switch( (*( sm->p)) ) {
		case 79: goto tr252;
		case 111: goto tr252;
	}
	goto tr145;
case 230:
	switch( (*( sm->p)) ) {
		case 68: goto tr253;
		case 100: goto tr253;
	}
	goto tr145;
case 231:
	switch( (*( sm->p)) ) {
		case 84: goto tr254;
		case 116: goto tr254;
	}
	goto tr145;
case 232:
	switch( (*( sm->p)) ) {
		case 69: goto tr255;
		case 101: goto tr255;
	}
	goto tr145;
case 233:
	switch( (*( sm->p)) ) {
		case 88: goto tr256;
		case 120: goto tr256;
	}
	goto tr145;
case 234:
	switch( (*( sm->p)) ) {
		case 84: goto tr257;
		case 116: goto tr257;
	}
	goto tr145;
case 235:
	if ( (*( sm->p)) == 62 )
		goto tr258;
	goto tr145;
case 236:
	switch( (*( sm->p)) ) {
		case 85: goto tr259;
		case 117: goto tr259;
	}
	goto tr145;
case 237:
	switch( (*( sm->p)) ) {
		case 79: goto tr260;
		case 111: goto tr260;
	}
	goto tr145;
case 238:
	switch( (*( sm->p)) ) {
		case 84: goto tr261;
		case 116: goto tr261;
	}
	goto tr145;
case 239:
	switch( (*( sm->p)) ) {
		case 69: goto tr262;
		case 101: goto tr262;
	}
	goto tr145;
case 240:
	if ( (*( sm->p)) == 62 )
		goto tr263;
	goto tr145;
case 241:
	switch( (*( sm->p)) ) {
		case 62: goto tr264;
		case 80: goto tr265;
		case 84: goto tr266;
		case 112: goto tr265;
		case 116: goto tr266;
	}
	goto tr145;
case 242:
	switch( (*( sm->p)) ) {
		case 79: goto tr267;
		case 111: goto tr267;
	}
	goto tr145;
case 243:
	switch( (*( sm->p)) ) {
		case 73: goto tr268;
		case 105: goto tr268;
	}
	goto tr145;
case 244:
	switch( (*( sm->p)) ) {
		case 76: goto tr269;
		case 108: goto tr269;
	}
	goto tr145;
case 245:
	switch( (*( sm->p)) ) {
		case 69: goto tr270;
		case 101: goto tr270;
	}
	goto tr145;
case 246:
	switch( (*( sm->p)) ) {
		case 82: goto tr271;
		case 114: goto tr271;
	}
	goto tr145;
case 247:
	switch( (*( sm->p)) ) {
		case 62: goto tr272;
		case 83: goto tr273;
		case 115: goto tr273;
	}
	goto tr145;
case 248:
	if ( (*( sm->p)) == 62 )
		goto tr272;
	goto tr145;
case 249:
	switch( (*( sm->p)) ) {
		case 82: goto tr274;
		case 114: goto tr274;
	}
	goto tr145;
case 250:
	switch( (*( sm->p)) ) {
		case 79: goto tr275;
		case 111: goto tr275;
	}
	goto tr145;
case 251:
	switch( (*( sm->p)) ) {
		case 78: goto tr276;
		case 110: goto tr276;
	}
	goto tr145;
case 252:
	switch( (*( sm->p)) ) {
		case 71: goto tr277;
		case 103: goto tr277;
	}
	goto tr145;
case 253:
	if ( (*( sm->p)) == 62 )
		goto tr229;
	goto tr145;
case 254:
	switch( (*( sm->p)) ) {
		case 78: goto tr278;
		case 110: goto tr278;
	}
	goto tr145;
case 255:
	if ( (*( sm->p)) == 62 )
		goto tr279;
	goto tr145;
case 256:
	if ( (*( sm->p)) == 62 )
		goto tr280;
	goto tr145;
case 257:
	if ( (*( sm->p)) == 32 )
		goto tr281;
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr281;
	goto tr145;
case 258:
	switch( (*( sm->p)) ) {
		case 32: goto tr281;
		case 72: goto tr282;
		case 104: goto tr282;
	}
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr281;
	goto tr145;
case 259:
	switch( (*( sm->p)) ) {
		case 82: goto tr283;
		case 114: goto tr283;
	}
	goto tr145;
case 260:
	switch( (*( sm->p)) ) {
		case 69: goto tr284;
		case 101: goto tr284;
	}
	goto tr145;
case 261:
	switch( (*( sm->p)) ) {
		case 70: goto tr285;
		case 102: goto tr285;
	}
	goto tr145;
case 262:
	if ( (*( sm->p)) == 61 )
		goto tr286;
	goto tr145;
case 263:
	if ( (*( sm->p)) == 34 )
		goto tr287;
	goto tr145;
case 264:
	switch( (*( sm->p)) ) {
		case 35: goto tr288;
		case 47: goto tr288;
		case 104: goto tr289;
	}
	goto tr145;
case 265:
	if ( (*( sm->p)) < -32 ) {
		if ( -62 <= (*( sm->p)) && (*( sm->p)) <= -33 )
			goto tr290;
	} else if ( (*( sm->p)) > -17 ) {
		if ( (*( sm->p)) > -12 ) {
			if ( 33 <= (*( sm->p)) && (*( sm->p)) <= 126 )
				goto tr293;
		} else if ( (*( sm->p)) >= -16 )
			goto tr292;
	} else
		goto tr291;
	goto tr145;
case 266:
	if ( (*( sm->p)) <= -65 )
		goto tr293;
	goto tr145;
case 267:
	if ( (*( sm->p)) == 34 )
		goto tr294;
	if ( (*( sm->p)) < -32 ) {
		if ( -62 <= (*( sm->p)) && (*( sm->p)) <= -33 )
			goto tr290;
	} else if ( (*( sm->p)) > -17 ) {
		if ( (*( sm->p)) > -12 ) {
			if ( 33 <= (*( sm->p)) && (*( sm->p)) <= 126 )
				goto tr293;
		} else if ( (*( sm->p)) >= -16 )
			goto tr292;
	} else
		goto tr291;
	goto tr145;
case 268:
	if ( (*( sm->p)) <= -65 )
		goto tr290;
	goto tr145;
case 269:
	if ( (*( sm->p)) <= -65 )
		goto tr291;
	goto tr145;
case 270:
	switch( (*( sm->p)) ) {
		case 34: goto tr294;
		case 62: goto tr295;
	}
	if ( (*( sm->p)) < -32 ) {
		if ( -62 <= (*( sm->p)) && (*( sm->p)) <= -33 )
			goto tr290;
	} else if ( (*( sm->p)) > -17 ) {
		if ( (*( sm->p)) > -12 ) {
			if ( 33 <= (*( sm->p)) && (*( sm->p)) <= 126 )
				goto tr293;
		} else if ( (*( sm->p)) >= -16 )
			goto tr292;
	} else
		goto tr291;
	goto tr145;
case 271:
	switch( (*( sm->p)) ) {
		case 10: goto tr145;
		case 13: goto tr145;
	}
	goto tr296;
case 272:
	switch( (*( sm->p)) ) {
		case 10: goto tr145;
		case 13: goto tr145;
		case 60: goto tr298;
	}
	goto tr297;
case 273:
	switch( (*( sm->p)) ) {
		case 10: goto tr145;
		case 13: goto tr145;
		case 47: goto tr299;
		case 60: goto tr298;
	}
	goto tr297;
case 274:
	switch( (*( sm->p)) ) {
		case 10: goto tr145;
		case 13: goto tr145;
		case 60: goto tr298;
		case 65: goto tr300;
		case 97: goto tr300;
	}
	goto tr297;
case 275:
	switch( (*( sm->p)) ) {
		case 10: goto tr145;
		case 13: goto tr145;
		case 60: goto tr298;
		case 62: goto tr301;
	}
	goto tr297;
case 276:
	if ( (*( sm->p)) == 116 )
		goto tr302;
	goto tr145;
case 277:
	if ( (*( sm->p)) == 116 )
		goto tr303;
	goto tr145;
case 278:
	if ( (*( sm->p)) == 112 )
		goto tr304;
	goto tr145;
case 279:
	switch( (*( sm->p)) ) {
		case 58: goto tr305;
		case 115: goto tr306;
	}
	goto tr145;
case 280:
	if ( (*( sm->p)) == 47 )
		goto tr307;
	goto tr145;
case 281:
	if ( (*( sm->p)) == 47 )
		goto tr308;
	goto tr145;
case 282:
	if ( (*( sm->p)) == 58 )
		goto tr305;
	goto tr145;
case 283:
	if ( (*( sm->p)) == 116 )
		goto tr309;
	goto tr145;
case 284:
	if ( (*( sm->p)) == 116 )
		goto tr310;
	goto tr145;
case 285:
	if ( (*( sm->p)) == 112 )
		goto tr311;
	goto tr145;
case 286:
	switch( (*( sm->p)) ) {
		case 58: goto tr312;
		case 115: goto tr313;
	}
	goto tr145;
case 287:
	if ( (*( sm->p)) == 47 )
		goto tr314;
	goto tr145;
case 288:
	if ( (*( sm->p)) == 47 )
		goto tr315;
	goto tr145;
case 289:
	if ( (*( sm->p)) < -32 ) {
		if ( -62 <= (*( sm->p)) && (*( sm->p)) <= -33 )
			goto tr316;
	} else if ( (*( sm->p)) > -17 ) {
		if ( (*( sm->p)) > -12 ) {
			if ( 33 <= (*( sm->p)) && (*( sm->p)) <= 126 )
				goto tr319;
		} else if ( (*( sm->p)) >= -16 )
			goto tr318;
	} else
		goto tr317;
	goto tr145;
case 290:
	if ( (*( sm->p)) <= -65 )
		goto tr319;
	goto tr145;
case 291:
	if ( (*( sm->p)) == 62 )
		goto tr320;
	if ( (*( sm->p)) < -32 ) {
		if ( -62 <= (*( sm->p)) && (*( sm->p)) <= -33 )
			goto tr316;
	} else if ( (*( sm->p)) > -17 ) {
		if ( (*( sm->p)) > -12 ) {
			if ( 33 <= (*( sm->p)) && (*( sm->p)) <= 126 )
				goto tr319;
		} else if ( (*( sm->p)) >= -16 )
			goto tr318;
	} else
		goto tr317;
	goto tr145;
case 292:
	if ( (*( sm->p)) <= -65 )
		goto tr316;
	goto tr145;
case 293:
	if ( (*( sm->p)) <= -65 )
		goto tr317;
	goto tr145;
case 294:
	if ( (*( sm->p)) == 58 )
		goto tr312;
	goto tr145;
case 687:
	if ( (*( sm->p)) < -32 ) {
		if ( -62 <= (*( sm->p)) && (*( sm->p)) <= -33 )
			goto tr790;
	} else if ( (*( sm->p)) > -17 ) {
		if ( (*( sm->p)) > -12 ) {
			if ( 33 <= (*( sm->p)) && (*( sm->p)) <= 126 )
				goto tr793;
		} else if ( (*( sm->p)) >= -16 )
			goto tr792;
	} else
		goto tr791;
	goto tr775;
case 295:
	if ( (*( sm->p)) <= -65 )
		goto tr321;
	goto tr138;
case 688:
	if ( (*( sm->p)) < -32 ) {
		if ( -62 <= (*( sm->p)) && (*( sm->p)) <= -33 )
			goto tr322;
	} else if ( (*( sm->p)) > -17 ) {
		if ( (*( sm->p)) > -12 ) {
			if ( 33 <= (*( sm->p)) && (*( sm->p)) <= 126 )
				goto tr321;
		} else if ( (*( sm->p)) >= -16 )
			goto tr795;
	} else
		goto tr323;
	goto tr794;
case 296:
	if ( (*( sm->p)) <= -65 )
		goto tr322;
	goto tr138;
case 297:
	if ( (*( sm->p)) <= -65 )
		goto tr323;
	goto tr138;
case 689:
	if ( (*( sm->p)) == 64 )
		goto tr797;
	if ( (*( sm->p)) < -32 ) {
		if ( -62 <= (*( sm->p)) && (*( sm->p)) <= -33 )
			goto tr322;
	} else if ( (*( sm->p)) > -17 ) {
		if ( (*( sm->p)) > -12 ) {
			if ( 33 <= (*( sm->p)) && (*( sm->p)) <= 126 )
				goto tr321;
		} else if ( (*( sm->p)) >= -16 )
			goto tr795;
	} else
		goto tr323;
	goto tr796;
case 690:
	switch( (*( sm->p)) ) {
		case 76: goto tr798;
		case 80: goto tr799;
		case 82: goto tr800;
		case 108: goto tr798;
		case 112: goto tr799;
		case 114: goto tr800;
	}
	goto tr775;
case 298:
	switch( (*( sm->p)) ) {
		case 73: goto tr324;
		case 105: goto tr324;
	}
	goto tr145;
case 299:
	switch( (*( sm->p)) ) {
		case 65: goto tr325;
		case 97: goto tr325;
	}
	goto tr145;
case 300:
	switch( (*( sm->p)) ) {
		case 83: goto tr326;
		case 115: goto tr326;
	}
	goto tr145;
case 301:
	if ( (*( sm->p)) == 32 )
		goto tr327;
	goto tr145;
case 302:
	if ( (*( sm->p)) == 35 )
		goto tr328;
	goto tr145;
case 303:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr329;
	goto tr145;
case 691:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr802;
	goto tr801;
case 304:
	switch( (*( sm->p)) ) {
		case 80: goto tr330;
		case 112: goto tr330;
	}
	goto tr145;
case 305:
	switch( (*( sm->p)) ) {
		case 69: goto tr331;
		case 101: goto tr331;
	}
	goto tr145;
case 306:
	switch( (*( sm->p)) ) {
		case 65: goto tr332;
		case 97: goto tr332;
	}
	goto tr145;
case 307:
	switch( (*( sm->p)) ) {
		case 76: goto tr333;
		case 108: goto tr333;
	}
	goto tr145;
case 308:
	if ( (*( sm->p)) == 32 )
		goto tr334;
	goto tr145;
case 309:
	if ( (*( sm->p)) == 35 )
		goto tr335;
	goto tr145;
case 310:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr336;
	goto tr145;
case 692:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr804;
	goto tr803;
case 311:
	switch( (*( sm->p)) ) {
		case 84: goto tr337;
		case 116: goto tr337;
	}
	goto tr145;
case 312:
	switch( (*( sm->p)) ) {
		case 73: goto tr338;
		case 83: goto tr339;
		case 105: goto tr338;
		case 115: goto tr339;
	}
	goto tr145;
case 313:
	switch( (*( sm->p)) ) {
		case 83: goto tr340;
		case 115: goto tr340;
	}
	goto tr145;
case 314:
	switch( (*( sm->p)) ) {
		case 84: goto tr341;
		case 116: goto tr341;
	}
	goto tr145;
case 315:
	if ( (*( sm->p)) == 32 )
		goto tr342;
	goto tr145;
case 316:
	if ( (*( sm->p)) == 35 )
		goto tr343;
	goto tr145;
case 317:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr344;
	goto tr145;
case 693:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr806;
	goto tr805;
case 318:
	switch( (*( sm->p)) ) {
		case 84: goto tr345;
		case 116: goto tr345;
	}
	goto tr145;
case 319:
	switch( (*( sm->p)) ) {
		case 65: goto tr346;
		case 97: goto tr346;
	}
	goto tr145;
case 320:
	switch( (*( sm->p)) ) {
		case 84: goto tr347;
		case 116: goto tr347;
	}
	goto tr145;
case 321:
	switch( (*( sm->p)) ) {
		case 73: goto tr348;
		case 105: goto tr348;
	}
	goto tr145;
case 322:
	switch( (*( sm->p)) ) {
		case 79: goto tr349;
		case 111: goto tr349;
	}
	goto tr145;
case 323:
	switch( (*( sm->p)) ) {
		case 78: goto tr350;
		case 110: goto tr350;
	}
	goto tr145;
case 324:
	if ( (*( sm->p)) == 32 )
		goto tr351;
	goto tr145;
case 325:
	if ( (*( sm->p)) == 35 )
		goto tr352;
	goto tr145;
case 326:
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr353;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr353;
	} else
		goto tr353;
	goto tr145;
case 694:
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr808;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr808;
	} else
		goto tr808;
	goto tr807;
case 695:
	switch( (*( sm->p)) ) {
		case 65: goto tr809;
		case 85: goto tr810;
		case 97: goto tr809;
		case 117: goto tr810;
	}
	goto tr775;
case 327:
	switch( (*( sm->p)) ) {
		case 78: goto tr354;
		case 110: goto tr354;
	}
	goto tr145;
case 328:
	if ( (*( sm->p)) == 32 )
		goto tr355;
	goto tr145;
case 329:
	if ( (*( sm->p)) == 35 )
		goto tr356;
	goto tr145;
case 330:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr357;
	goto tr145;
case 696:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr812;
	goto tr811;
case 331:
	switch( (*( sm->p)) ) {
		case 82: goto tr358;
		case 114: goto tr358;
	}
	goto tr145;
case 332:
	if ( (*( sm->p)) == 32 )
		goto tr359;
	goto tr145;
case 333:
	if ( (*( sm->p)) == 35 )
		goto tr360;
	goto tr145;
case 334:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr361;
	goto tr145;
case 697:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr814;
	goto tr813;
case 698:
	switch( (*( sm->p)) ) {
		case 79: goto tr815;
		case 111: goto tr815;
	}
	goto tr775;
case 335:
	switch( (*( sm->p)) ) {
		case 77: goto tr362;
		case 109: goto tr362;
	}
	goto tr145;
case 336:
	switch( (*( sm->p)) ) {
		case 77: goto tr363;
		case 109: goto tr363;
	}
	goto tr145;
case 337:
	switch( (*( sm->p)) ) {
		case 69: goto tr364;
		case 101: goto tr364;
	}
	goto tr145;
case 338:
	switch( (*( sm->p)) ) {
		case 78: goto tr365;
		case 110: goto tr365;
	}
	goto tr145;
case 339:
	switch( (*( sm->p)) ) {
		case 84: goto tr366;
		case 116: goto tr366;
	}
	goto tr145;
case 340:
	if ( (*( sm->p)) == 32 )
		goto tr367;
	goto tr145;
case 341:
	if ( (*( sm->p)) == 35 )
		goto tr368;
	goto tr145;
case 342:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr369;
	goto tr145;
case 699:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr817;
	goto tr816;
case 700:
	switch( (*( sm->p)) ) {
		case 69: goto tr818;
		case 101: goto tr818;
	}
	goto tr775;
case 343:
	switch( (*( sm->p)) ) {
		case 86: goto tr370;
		case 118: goto tr370;
	}
	goto tr145;
case 344:
	switch( (*( sm->p)) ) {
		case 73: goto tr371;
		case 105: goto tr371;
	}
	goto tr145;
case 345:
	switch( (*( sm->p)) ) {
		case 65: goto tr372;
		case 97: goto tr372;
	}
	goto tr145;
case 346:
	switch( (*( sm->p)) ) {
		case 78: goto tr373;
		case 110: goto tr373;
	}
	goto tr145;
case 347:
	switch( (*( sm->p)) ) {
		case 84: goto tr374;
		case 116: goto tr374;
	}
	goto tr145;
case 348:
	switch( (*( sm->p)) ) {
		case 65: goto tr375;
		case 97: goto tr375;
	}
	goto tr145;
case 349:
	switch( (*( sm->p)) ) {
		case 82: goto tr376;
		case 114: goto tr376;
	}
	goto tr145;
case 350:
	switch( (*( sm->p)) ) {
		case 84: goto tr377;
		case 116: goto tr377;
	}
	goto tr145;
case 351:
	if ( (*( sm->p)) == 32 )
		goto tr378;
	goto tr145;
case 352:
	if ( (*( sm->p)) == 35 )
		goto tr379;
	goto tr145;
case 353:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr380;
	goto tr145;
case 701:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr820;
	goto tr819;
case 702:
	switch( (*( sm->p)) ) {
		case 65: goto tr821;
		case 69: goto tr822;
		case 76: goto tr823;
		case 79: goto tr824;
		case 97: goto tr821;
		case 101: goto tr822;
		case 108: goto tr823;
		case 111: goto tr824;
	}
	goto tr775;
case 354:
	switch( (*( sm->p)) ) {
		case 86: goto tr381;
		case 118: goto tr381;
	}
	goto tr145;
case 355:
	switch( (*( sm->p)) ) {
		case 71: goto tr382;
		case 103: goto tr382;
	}
	goto tr145;
case 356:
	switch( (*( sm->p)) ) {
		case 82: goto tr383;
		case 114: goto tr383;
	}
	goto tr145;
case 357:
	switch( (*( sm->p)) ) {
		case 79: goto tr384;
		case 111: goto tr384;
	}
	goto tr145;
case 358:
	switch( (*( sm->p)) ) {
		case 85: goto tr385;
		case 117: goto tr385;
	}
	goto tr145;
case 359:
	switch( (*( sm->p)) ) {
		case 80: goto tr386;
		case 112: goto tr386;
	}
	goto tr145;
case 360:
	if ( (*( sm->p)) == 32 )
		goto tr387;
	goto tr145;
case 361:
	if ( (*( sm->p)) == 35 )
		goto tr388;
	goto tr145;
case 362:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr389;
	goto tr145;
case 703:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr826;
	goto tr825;
case 363:
	switch( (*( sm->p)) ) {
		case 69: goto tr390;
		case 101: goto tr390;
	}
	goto tr145;
case 364:
	switch( (*( sm->p)) ) {
		case 68: goto tr391;
		case 100: goto tr391;
	}
	goto tr145;
case 365:
	switch( (*( sm->p)) ) {
		case 66: goto tr392;
		case 98: goto tr392;
	}
	goto tr145;
case 366:
	switch( (*( sm->p)) ) {
		case 65: goto tr393;
		case 97: goto tr393;
	}
	goto tr145;
case 367:
	switch( (*( sm->p)) ) {
		case 67: goto tr394;
		case 99: goto tr394;
	}
	goto tr145;
case 368:
	switch( (*( sm->p)) ) {
		case 75: goto tr395;
		case 107: goto tr395;
	}
	goto tr145;
case 369:
	if ( (*( sm->p)) == 32 )
		goto tr396;
	goto tr145;
case 370:
	if ( (*( sm->p)) == 35 )
		goto tr397;
	goto tr145;
case 371:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr398;
	goto tr145;
case 704:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr828;
	goto tr827;
case 372:
	switch( (*( sm->p)) ) {
		case 65: goto tr399;
		case 97: goto tr399;
	}
	goto tr145;
case 373:
	switch( (*( sm->p)) ) {
		case 71: goto tr400;
		case 103: goto tr400;
	}
	goto tr145;
case 374:
	if ( (*( sm->p)) == 32 )
		goto tr401;
	goto tr145;
case 375:
	if ( (*( sm->p)) == 35 )
		goto tr402;
	goto tr145;
case 376:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr403;
	goto tr145;
case 705:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr830;
	goto tr829;
case 377:
	switch( (*( sm->p)) ) {
		case 82: goto tr404;
		case 114: goto tr404;
	}
	goto tr145;
case 378:
	switch( (*( sm->p)) ) {
		case 85: goto tr405;
		case 117: goto tr405;
	}
	goto tr145;
case 379:
	switch( (*( sm->p)) ) {
		case 77: goto tr406;
		case 109: goto tr406;
	}
	goto tr145;
case 380:
	if ( (*( sm->p)) == 32 )
		goto tr407;
	goto tr145;
case 381:
	if ( (*( sm->p)) == 35 )
		goto tr408;
	goto tr145;
case 382:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr409;
	goto tr145;
case 706:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr832;
	goto tr831;
case 707:
	switch( (*( sm->p)) ) {
		case 77: goto tr833;
		case 83: goto tr834;
		case 109: goto tr833;
		case 115: goto tr834;
	}
	goto tr775;
case 383:
	switch( (*( sm->p)) ) {
		case 80: goto tr410;
		case 112: goto tr410;
	}
	goto tr145;
case 384:
	switch( (*( sm->p)) ) {
		case 76: goto tr411;
		case 108: goto tr411;
	}
	goto tr145;
case 385:
	switch( (*( sm->p)) ) {
		case 73: goto tr412;
		case 105: goto tr412;
	}
	goto tr145;
case 386:
	switch( (*( sm->p)) ) {
		case 67: goto tr413;
		case 99: goto tr413;
	}
	goto tr145;
case 387:
	switch( (*( sm->p)) ) {
		case 65: goto tr414;
		case 97: goto tr414;
	}
	goto tr145;
case 388:
	switch( (*( sm->p)) ) {
		case 84: goto tr415;
		case 116: goto tr415;
	}
	goto tr145;
case 389:
	switch( (*( sm->p)) ) {
		case 73: goto tr416;
		case 105: goto tr416;
	}
	goto tr145;
case 390:
	switch( (*( sm->p)) ) {
		case 79: goto tr417;
		case 111: goto tr417;
	}
	goto tr145;
case 391:
	switch( (*( sm->p)) ) {
		case 78: goto tr418;
		case 110: goto tr418;
	}
	goto tr145;
case 392:
	if ( (*( sm->p)) == 32 )
		goto tr419;
	goto tr145;
case 393:
	if ( (*( sm->p)) == 35 )
		goto tr420;
	goto tr145;
case 394:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr421;
	goto tr145;
case 708:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr836;
	goto tr835;
case 395:
	switch( (*( sm->p)) ) {
		case 83: goto tr422;
		case 115: goto tr422;
	}
	goto tr145;
case 396:
	switch( (*( sm->p)) ) {
		case 85: goto tr423;
		case 117: goto tr423;
	}
	goto tr145;
case 397:
	switch( (*( sm->p)) ) {
		case 69: goto tr424;
		case 101: goto tr424;
	}
	goto tr145;
case 398:
	if ( (*( sm->p)) == 32 )
		goto tr425;
	goto tr145;
case 399:
	if ( (*( sm->p)) == 35 )
		goto tr426;
	goto tr145;
case 400:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr427;
	goto tr145;
case 709:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr838;
	goto tr837;
case 710:
	switch( (*( sm->p)) ) {
		case 79: goto tr839;
		case 111: goto tr839;
	}
	goto tr775;
case 401:
	switch( (*( sm->p)) ) {
		case 68: goto tr428;
		case 100: goto tr428;
	}
	goto tr145;
case 402:
	if ( (*( sm->p)) == 32 )
		goto tr429;
	goto tr145;
case 403:
	switch( (*( sm->p)) ) {
		case 65: goto tr430;
		case 97: goto tr430;
	}
	goto tr145;
case 404:
	switch( (*( sm->p)) ) {
		case 67: goto tr431;
		case 99: goto tr431;
	}
	goto tr145;
case 405:
	switch( (*( sm->p)) ) {
		case 84: goto tr432;
		case 116: goto tr432;
	}
	goto tr145;
case 406:
	switch( (*( sm->p)) ) {
		case 73: goto tr433;
		case 105: goto tr433;
	}
	goto tr145;
case 407:
	switch( (*( sm->p)) ) {
		case 79: goto tr434;
		case 111: goto tr434;
	}
	goto tr145;
case 408:
	switch( (*( sm->p)) ) {
		case 78: goto tr435;
		case 110: goto tr435;
	}
	goto tr145;
case 409:
	if ( (*( sm->p)) == 32 )
		goto tr436;
	goto tr145;
case 410:
	if ( (*( sm->p)) == 35 )
		goto tr437;
	goto tr145;
case 411:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr438;
	goto tr145;
case 711:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr841;
	goto tr840;
case 712:
	switch( (*( sm->p)) ) {
		case 73: goto tr842;
		case 79: goto tr843;
		case 105: goto tr842;
		case 111: goto tr843;
	}
	goto tr775;
case 412:
	switch( (*( sm->p)) ) {
		case 74: goto tr439;
		case 106: goto tr439;
	}
	goto tr145;
case 413:
	switch( (*( sm->p)) ) {
		case 73: goto tr440;
		case 105: goto tr440;
	}
	goto tr145;
case 414:
	switch( (*( sm->p)) ) {
		case 69: goto tr441;
		case 101: goto tr441;
	}
	goto tr145;
case 415:
	if ( (*( sm->p)) == 32 )
		goto tr442;
	goto tr145;
case 416:
	if ( (*( sm->p)) == 35 )
		goto tr443;
	goto tr145;
case 417:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr444;
	goto tr145;
case 713:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr845;
	goto tr844;
case 418:
	switch( (*( sm->p)) ) {
		case 84: goto tr445;
		case 116: goto tr445;
	}
	goto tr145;
case 419:
	switch( (*( sm->p)) ) {
		case 69: goto tr446;
		case 101: goto tr446;
	}
	goto tr145;
case 420:
	if ( (*( sm->p)) == 32 )
		goto tr447;
	goto tr145;
case 421:
	if ( (*( sm->p)) == 35 )
		goto tr448;
	goto tr145;
case 422:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr449;
	goto tr145;
case 714:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr847;
	goto tr846;
case 715:
	switch( (*( sm->p)) ) {
		case 65: goto tr848;
		case 73: goto tr849;
		case 79: goto tr850;
		case 97: goto tr848;
		case 105: goto tr849;
		case 111: goto tr850;
	}
	goto tr775;
case 423:
	switch( (*( sm->p)) ) {
		case 87: goto tr450;
		case 119: goto tr450;
	}
	goto tr145;
case 424:
	switch( (*( sm->p)) ) {
		case 79: goto tr451;
		case 111: goto tr451;
	}
	goto tr145;
case 425:
	switch( (*( sm->p)) ) {
		case 79: goto tr452;
		case 111: goto tr452;
	}
	goto tr145;
case 426:
	if ( (*( sm->p)) == 32 )
		goto tr453;
	goto tr145;
case 427:
	if ( (*( sm->p)) == 35 )
		goto tr454;
	goto tr145;
case 428:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr455;
	goto tr145;
case 716:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr852;
	goto tr851;
case 429:
	switch( (*( sm->p)) ) {
		case 88: goto tr456;
		case 120: goto tr456;
	}
	goto tr145;
case 430:
	switch( (*( sm->p)) ) {
		case 73: goto tr457;
		case 105: goto tr457;
	}
	goto tr145;
case 431:
	switch( (*( sm->p)) ) {
		case 86: goto tr458;
		case 118: goto tr458;
	}
	goto tr145;
case 432:
	if ( (*( sm->p)) == 32 )
		goto tr459;
	goto tr145;
case 433:
	if ( (*( sm->p)) == 35 )
		goto tr460;
	goto tr145;
case 434:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr461;
	goto tr145;
case 717:
	if ( (*( sm->p)) == 47 )
		goto tr854;
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr855;
	goto tr853;
case 435:
	switch( (*( sm->p)) ) {
		case 80: goto tr463;
		case 112: goto tr463;
	}
	goto tr462;
case 436:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr464;
	goto tr462;
case 718:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr857;
	goto tr856;
case 437:
	switch( (*( sm->p)) ) {
		case 79: goto tr465;
		case 83: goto tr466;
		case 111: goto tr465;
		case 115: goto tr466;
	}
	goto tr145;
case 438:
	switch( (*( sm->p)) ) {
		case 76: goto tr467;
		case 108: goto tr467;
	}
	goto tr145;
case 439:
	if ( (*( sm->p)) == 32 )
		goto tr468;
	goto tr145;
case 440:
	if ( (*( sm->p)) == 35 )
		goto tr469;
	goto tr145;
case 441:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr470;
	goto tr145;
case 719:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr859;
	goto tr858;
case 442:
	switch( (*( sm->p)) ) {
		case 84: goto tr471;
		case 116: goto tr471;
	}
	goto tr145;
case 443:
	if ( (*( sm->p)) == 32 )
		goto tr472;
	goto tr145;
case 444:
	if ( (*( sm->p)) == 35 )
		goto tr473;
	goto tr145;
case 445:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr474;
	goto tr145;
case 720:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr861;
	goto tr860;
case 721:
	switch( (*( sm->p)) ) {
		case 69: goto tr862;
		case 101: goto tr862;
	}
	goto tr775;
case 446:
	switch( (*( sm->p)) ) {
		case 73: goto tr475;
		case 105: goto tr475;
	}
	goto tr145;
case 447:
	switch( (*( sm->p)) ) {
		case 71: goto tr476;
		case 103: goto tr476;
	}
	goto tr145;
case 448:
	switch( (*( sm->p)) ) {
		case 65: goto tr477;
		case 97: goto tr477;
	}
	goto tr145;
case 449:
	if ( (*( sm->p)) == 32 )
		goto tr478;
	goto tr145;
case 450:
	if ( (*( sm->p)) == 35 )
		goto tr479;
	goto tr145;
case 451:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr480;
	goto tr145;
case 722:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr864;
	goto tr863;
case 723:
	switch( (*( sm->p)) ) {
		case 79: goto tr865;
		case 87: goto tr866;
		case 111: goto tr865;
		case 119: goto tr866;
	}
	goto tr775;
case 452:
	switch( (*( sm->p)) ) {
		case 80: goto tr481;
		case 112: goto tr481;
	}
	goto tr145;
case 453:
	switch( (*( sm->p)) ) {
		case 73: goto tr482;
		case 105: goto tr482;
	}
	goto tr145;
case 454:
	switch( (*( sm->p)) ) {
		case 67: goto tr483;
		case 99: goto tr483;
	}
	goto tr145;
case 455:
	if ( (*( sm->p)) == 32 )
		goto tr484;
	goto tr145;
case 456:
	if ( (*( sm->p)) == 35 )
		goto tr485;
	goto tr145;
case 457:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr486;
	goto tr145;
case 724:
	if ( (*( sm->p)) == 47 )
		goto tr868;
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr869;
	goto tr867;
case 458:
	switch( (*( sm->p)) ) {
		case 80: goto tr488;
		case 112: goto tr488;
	}
	goto tr487;
case 459:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr489;
	goto tr487;
case 725:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr871;
	goto tr870;
case 460:
	switch( (*( sm->p)) ) {
		case 73: goto tr490;
		case 105: goto tr490;
	}
	goto tr145;
case 461:
	switch( (*( sm->p)) ) {
		case 84: goto tr491;
		case 116: goto tr491;
	}
	goto tr145;
case 462:
	switch( (*( sm->p)) ) {
		case 84: goto tr492;
		case 116: goto tr492;
	}
	goto tr145;
case 463:
	switch( (*( sm->p)) ) {
		case 69: goto tr493;
		case 101: goto tr493;
	}
	goto tr145;
case 464:
	switch( (*( sm->p)) ) {
		case 82: goto tr494;
		case 114: goto tr494;
	}
	goto tr145;
case 465:
	if ( (*( sm->p)) == 32 )
		goto tr495;
	goto tr145;
case 466:
	if ( (*( sm->p)) == 35 )
		goto tr496;
	goto tr145;
case 467:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr497;
	goto tr145;
case 726:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr873;
	goto tr872;
case 727:
	switch( (*( sm->p)) ) {
		case 83: goto tr874;
		case 115: goto tr874;
	}
	goto tr775;
case 468:
	switch( (*( sm->p)) ) {
		case 69: goto tr498;
		case 101: goto tr498;
	}
	goto tr145;
case 469:
	switch( (*( sm->p)) ) {
		case 82: goto tr499;
		case 114: goto tr499;
	}
	goto tr145;
case 470:
	if ( (*( sm->p)) == 32 )
		goto tr500;
	goto tr145;
case 471:
	if ( (*( sm->p)) == 35 )
		goto tr501;
	goto tr145;
case 472:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr502;
	goto tr145;
case 728:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr876;
	goto tr875;
case 729:
	switch( (*( sm->p)) ) {
		case 73: goto tr877;
		case 105: goto tr877;
	}
	goto tr775;
case 473:
	switch( (*( sm->p)) ) {
		case 75: goto tr503;
		case 107: goto tr503;
	}
	goto tr145;
case 474:
	switch( (*( sm->p)) ) {
		case 73: goto tr504;
		case 105: goto tr504;
	}
	goto tr145;
case 475:
	if ( (*( sm->p)) == 32 )
		goto tr505;
	goto tr145;
case 476:
	if ( (*( sm->p)) == 35 )
		goto tr506;
	goto tr145;
case 477:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr507;
	goto tr145;
case 730:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr879;
	goto tr878;
case 731:
	switch( (*( sm->p)) ) {
		case 47: goto tr880;
		case 66: goto tr881;
		case 67: goto tr882;
		case 73: goto tr883;
		case 78: goto tr884;
		case 81: goto tr885;
		case 83: goto tr886;
		case 84: goto tr887;
		case 85: goto tr888;
		case 91: goto tr889;
		case 98: goto tr881;
		case 99: goto tr882;
		case 101: goto tr890;
		case 104: goto tr891;
		case 105: goto tr883;
		case 110: goto tr884;
		case 113: goto tr885;
		case 115: goto tr886;
		case 116: goto tr887;
		case 117: goto tr888;
	}
	goto tr775;
case 478:
	switch( (*( sm->p)) ) {
		case 66: goto tr508;
		case 73: goto tr509;
		case 81: goto tr510;
		case 83: goto tr511;
		case 84: goto tr512;
		case 85: goto tr513;
		case 98: goto tr508;
		case 101: goto tr514;
		case 105: goto tr509;
		case 113: goto tr510;
		case 115: goto tr511;
		case 116: goto tr515;
		case 117: goto tr513;
	}
	goto tr145;
case 479:
	if ( (*( sm->p)) == 93 )
		goto tr183;
	goto tr145;
case 480:
	if ( (*( sm->p)) == 93 )
		goto tr195;
	goto tr145;
case 481:
	switch( (*( sm->p)) ) {
		case 85: goto tr516;
		case 117: goto tr516;
	}
	goto tr145;
case 482:
	switch( (*( sm->p)) ) {
		case 79: goto tr517;
		case 111: goto tr517;
	}
	goto tr145;
case 483:
	switch( (*( sm->p)) ) {
		case 84: goto tr518;
		case 116: goto tr518;
	}
	goto tr145;
case 484:
	switch( (*( sm->p)) ) {
		case 69: goto tr519;
		case 101: goto tr519;
	}
	goto tr145;
case 485:
	if ( (*( sm->p)) == 93 )
		goto tr193;
	goto tr145;
case 486:
	switch( (*( sm->p)) ) {
		case 80: goto tr520;
		case 93: goto tr201;
		case 112: goto tr520;
	}
	goto tr145;
case 487:
	switch( (*( sm->p)) ) {
		case 79: goto tr521;
		case 111: goto tr521;
	}
	goto tr145;
case 488:
	switch( (*( sm->p)) ) {
		case 73: goto tr522;
		case 105: goto tr522;
	}
	goto tr145;
case 489:
	switch( (*( sm->p)) ) {
		case 76: goto tr523;
		case 108: goto tr523;
	}
	goto tr145;
case 490:
	switch( (*( sm->p)) ) {
		case 69: goto tr524;
		case 101: goto tr524;
	}
	goto tr145;
case 491:
	switch( (*( sm->p)) ) {
		case 82: goto tr525;
		case 114: goto tr525;
	}
	goto tr145;
case 492:
	switch( (*( sm->p)) ) {
		case 83: goto tr526;
		case 93: goto tr209;
		case 115: goto tr526;
	}
	goto tr145;
case 493:
	if ( (*( sm->p)) == 93 )
		goto tr209;
	goto tr145;
case 494:
	switch( (*( sm->p)) ) {
		case 78: goto tr527;
		case 110: goto tr527;
	}
	goto tr145;
case 495:
	if ( (*( sm->p)) == 93 )
		goto tr528;
	goto tr145;
case 496:
	if ( (*( sm->p)) == 93 )
		goto tr219;
	goto tr145;
case 497:
	if ( (*( sm->p)) == 120 )
		goto tr529;
	goto tr145;
case 498:
	if ( (*( sm->p)) == 112 )
		goto tr530;
	goto tr145;
case 499:
	if ( (*( sm->p)) == 97 )
		goto tr531;
	goto tr145;
case 500:
	if ( (*( sm->p)) == 110 )
		goto tr532;
	goto tr145;
case 501:
	if ( (*( sm->p)) == 100 )
		goto tr533;
	goto tr145;
case 502:
	if ( (*( sm->p)) == 93 )
		goto tr200;
	goto tr145;
case 503:
	switch( (*( sm->p)) ) {
		case 78: goto tr527;
		case 100: goto tr534;
		case 104: goto tr535;
		case 110: goto tr527;
	}
	goto tr145;
case 504:
	if ( (*( sm->p)) == 93 )
		goto tr217;
	goto tr145;
case 505:
	if ( (*( sm->p)) == 93 )
		goto tr218;
	goto tr145;
case 506:
	if ( (*( sm->p)) == 93 )
		goto tr229;
	goto tr145;
case 507:
	switch( (*( sm->p)) ) {
		case 79: goto tr536;
		case 111: goto tr536;
	}
	goto tr145;
case 508:
	switch( (*( sm->p)) ) {
		case 68: goto tr537;
		case 100: goto tr537;
	}
	goto tr145;
case 509:
	switch( (*( sm->p)) ) {
		case 69: goto tr538;
		case 101: goto tr538;
	}
	goto tr145;
case 510:
	if ( (*( sm->p)) == 93 )
		goto tr243;
	goto tr145;
case 511:
	if ( (*( sm->p)) == 93 )
		goto tr246;
	goto tr145;
case 512:
	switch( (*( sm->p)) ) {
		case 79: goto tr539;
		case 111: goto tr539;
	}
	goto tr145;
case 513:
	switch( (*( sm->p)) ) {
		case 68: goto tr540;
		case 100: goto tr540;
	}
	goto tr145;
case 514:
	switch( (*( sm->p)) ) {
		case 84: goto tr541;
		case 116: goto tr541;
	}
	goto tr145;
case 515:
	switch( (*( sm->p)) ) {
		case 69: goto tr542;
		case 101: goto tr542;
	}
	goto tr145;
case 516:
	switch( (*( sm->p)) ) {
		case 88: goto tr543;
		case 120: goto tr543;
	}
	goto tr145;
case 517:
	switch( (*( sm->p)) ) {
		case 84: goto tr544;
		case 116: goto tr544;
	}
	goto tr145;
case 518:
	if ( (*( sm->p)) == 93 )
		goto tr258;
	goto tr145;
case 519:
	switch( (*( sm->p)) ) {
		case 85: goto tr545;
		case 117: goto tr545;
	}
	goto tr145;
case 520:
	switch( (*( sm->p)) ) {
		case 79: goto tr546;
		case 111: goto tr546;
	}
	goto tr145;
case 521:
	switch( (*( sm->p)) ) {
		case 84: goto tr547;
		case 116: goto tr547;
	}
	goto tr145;
case 522:
	switch( (*( sm->p)) ) {
		case 69: goto tr548;
		case 101: goto tr548;
	}
	goto tr145;
case 523:
	if ( (*( sm->p)) == 93 )
		goto tr239;
	goto tr145;
case 524:
	switch( (*( sm->p)) ) {
		case 80: goto tr549;
		case 93: goto tr264;
		case 112: goto tr549;
	}
	goto tr145;
case 525:
	switch( (*( sm->p)) ) {
		case 79: goto tr550;
		case 111: goto tr550;
	}
	goto tr145;
case 526:
	switch( (*( sm->p)) ) {
		case 73: goto tr551;
		case 105: goto tr551;
	}
	goto tr145;
case 527:
	switch( (*( sm->p)) ) {
		case 76: goto tr552;
		case 108: goto tr552;
	}
	goto tr145;
case 528:
	switch( (*( sm->p)) ) {
		case 69: goto tr553;
		case 101: goto tr553;
	}
	goto tr145;
case 529:
	switch( (*( sm->p)) ) {
		case 82: goto tr554;
		case 114: goto tr554;
	}
	goto tr145;
case 530:
	switch( (*( sm->p)) ) {
		case 83: goto tr555;
		case 93: goto tr272;
		case 115: goto tr555;
	}
	goto tr145;
case 531:
	if ( (*( sm->p)) == 93 )
		goto tr272;
	goto tr145;
case 532:
	switch( (*( sm->p)) ) {
		case 78: goto tr556;
		case 110: goto tr556;
	}
	goto tr145;
case 533:
	if ( (*( sm->p)) == 93 )
		goto tr279;
	goto tr145;
case 534:
	if ( (*( sm->p)) == 93 )
		goto tr280;
	goto tr145;
case 535:
	switch( (*( sm->p)) ) {
		case 93: goto tr145;
		case 124: goto tr558;
	}
	goto tr557;
case 536:
	switch( (*( sm->p)) ) {
		case 93: goto tr560;
		case 124: goto tr561;
	}
	goto tr559;
case 537:
	if ( (*( sm->p)) == 93 )
		goto tr562;
	goto tr145;
case 538:
	switch( (*( sm->p)) ) {
		case 93: goto tr145;
		case 124: goto tr145;
	}
	goto tr563;
case 539:
	switch( (*( sm->p)) ) {
		case 93: goto tr565;
		case 124: goto tr145;
	}
	goto tr564;
case 540:
	if ( (*( sm->p)) == 93 )
		goto tr566;
	goto tr145;
case 541:
	switch( (*( sm->p)) ) {
		case 93: goto tr560;
		case 124: goto tr145;
	}
	goto tr567;
case 542:
	if ( (*( sm->p)) == 120 )
		goto tr568;
	goto tr145;
case 543:
	if ( (*( sm->p)) == 112 )
		goto tr569;
	goto tr145;
case 544:
	if ( (*( sm->p)) == 97 )
		goto tr570;
	goto tr145;
case 545:
	if ( (*( sm->p)) == 110 )
		goto tr571;
	goto tr145;
case 546:
	if ( (*( sm->p)) == 100 )
		goto tr572;
	goto tr145;
case 547:
	if ( (*( sm->p)) == 93 )
		goto tr251;
	goto tr145;
case 548:
	if ( (*( sm->p)) == 116 )
		goto tr573;
	goto tr145;
case 549:
	if ( (*( sm->p)) == 116 )
		goto tr574;
	goto tr145;
case 550:
	if ( (*( sm->p)) == 112 )
		goto tr575;
	goto tr145;
case 551:
	switch( (*( sm->p)) ) {
		case 58: goto tr576;
		case 115: goto tr577;
	}
	goto tr145;
case 552:
	if ( (*( sm->p)) == 47 )
		goto tr578;
	goto tr145;
case 553:
	if ( (*( sm->p)) == 47 )
		goto tr579;
	goto tr145;
case 554:
	if ( (*( sm->p)) < -32 ) {
		if ( -62 <= (*( sm->p)) && (*( sm->p)) <= -33 )
			goto tr580;
	} else if ( (*( sm->p)) > -17 ) {
		if ( (*( sm->p)) > -12 ) {
			if ( 33 <= (*( sm->p)) && (*( sm->p)) <= 126 )
				goto tr583;
		} else if ( (*( sm->p)) >= -16 )
			goto tr582;
	} else
		goto tr581;
	goto tr145;
case 555:
	if ( (*( sm->p)) <= -65 )
		goto tr583;
	goto tr145;
case 556:
	if ( (*( sm->p)) == 93 )
		goto tr584;
	if ( (*( sm->p)) < -32 ) {
		if ( -62 <= (*( sm->p)) && (*( sm->p)) <= -33 )
			goto tr580;
	} else if ( (*( sm->p)) > -17 ) {
		if ( (*( sm->p)) > -12 ) {
			if ( 33 <= (*( sm->p)) && (*( sm->p)) <= 126 )
				goto tr583;
		} else if ( (*( sm->p)) >= -16 )
			goto tr582;
	} else
		goto tr581;
	goto tr145;
case 557:
	if ( (*( sm->p)) <= -65 )
		goto tr580;
	goto tr145;
case 558:
	if ( (*( sm->p)) <= -65 )
		goto tr581;
	goto tr145;
case 559:
	switch( (*( sm->p)) ) {
		case 40: goto tr585;
		case 93: goto tr584;
	}
	if ( (*( sm->p)) < -32 ) {
		if ( -62 <= (*( sm->p)) && (*( sm->p)) <= -33 )
			goto tr580;
	} else if ( (*( sm->p)) > -17 ) {
		if ( (*( sm->p)) > -12 ) {
			if ( 33 <= (*( sm->p)) && (*( sm->p)) <= 126 )
				goto tr583;
		} else if ( (*( sm->p)) >= -16 )
			goto tr582;
	} else
		goto tr581;
	goto tr145;
case 560:
	if ( (*( sm->p)) == 41 )
		goto tr145;
	goto tr586;
case 561:
	if ( (*( sm->p)) == 41 )
		goto tr588;
	goto tr587;
case 562:
	if ( (*( sm->p)) == 58 )
		goto tr576;
	goto tr145;
case 732:
	if ( (*( sm->p)) == 116 )
		goto tr892;
	goto tr775;
case 563:
	if ( (*( sm->p)) == 116 )
		goto tr589;
	goto tr145;
case 564:
	if ( (*( sm->p)) == 112 )
		goto tr590;
	goto tr145;
case 565:
	switch( (*( sm->p)) ) {
		case 58: goto tr591;
		case 115: goto tr592;
	}
	goto tr145;
case 566:
	if ( (*( sm->p)) == 47 )
		goto tr593;
	goto tr145;
case 567:
	if ( (*( sm->p)) == 47 )
		goto tr594;
	goto tr145;
case 568:
	if ( (*( sm->p)) < -32 ) {
		if ( -62 <= (*( sm->p)) && (*( sm->p)) <= -33 )
			goto tr595;
	} else if ( (*( sm->p)) > -17 ) {
		if ( (*( sm->p)) > -12 ) {
			if ( 33 <= (*( sm->p)) && (*( sm->p)) <= 126 )
				goto tr598;
		} else if ( (*( sm->p)) >= -16 )
			goto tr597;
	} else
		goto tr596;
	goto tr145;
case 569:
	if ( (*( sm->p)) <= -65 )
		goto tr598;
	goto tr138;
case 733:
	if ( (*( sm->p)) < -32 ) {
		if ( -62 <= (*( sm->p)) && (*( sm->p)) <= -33 )
			goto tr595;
	} else if ( (*( sm->p)) > -17 ) {
		if ( (*( sm->p)) > -12 ) {
			if ( 33 <= (*( sm->p)) && (*( sm->p)) <= 126 )
				goto tr598;
		} else if ( (*( sm->p)) >= -16 )
			goto tr597;
	} else
		goto tr596;
	goto tr893;
case 570:
	if ( (*( sm->p)) <= -65 )
		goto tr595;
	goto tr138;
case 571:
	if ( (*( sm->p)) <= -65 )
		goto tr596;
	goto tr138;
case 572:
	if ( (*( sm->p)) == 58 )
		goto tr591;
	goto tr145;
case 734:
	if ( (*( sm->p)) == 123 )
		goto tr894;
	goto tr775;
case 573:
	if ( (*( sm->p)) == 125 )
		goto tr145;
	goto tr599;
case 574:
	if ( (*( sm->p)) == 125 )
		goto tr601;
	goto tr600;
case 575:
	if ( (*( sm->p)) == 125 )
		goto tr602;
	goto tr145;
case 735:
	switch( (*( sm->p)) ) {
		case 60: goto tr896;
		case 91: goto tr897;
	}
	goto tr895;
case 736:
	if ( (*( sm->p)) == 47 )
		goto tr899;
	goto tr898;
case 576:
	switch( (*( sm->p)) ) {
		case 67: goto tr604;
		case 99: goto tr604;
	}
	goto tr603;
case 577:
	switch( (*( sm->p)) ) {
		case 79: goto tr605;
		case 111: goto tr605;
	}
	goto tr603;
case 578:
	switch( (*( sm->p)) ) {
		case 68: goto tr606;
		case 100: goto tr606;
	}
	goto tr603;
case 579:
	switch( (*( sm->p)) ) {
		case 69: goto tr607;
		case 101: goto tr607;
	}
	goto tr603;
case 580:
	if ( (*( sm->p)) == 62 )
		goto tr608;
	goto tr603;
case 737:
	if ( (*( sm->p)) == 47 )
		goto tr900;
	goto tr898;
case 581:
	switch( (*( sm->p)) ) {
		case 67: goto tr609;
		case 99: goto tr609;
	}
	goto tr603;
case 582:
	switch( (*( sm->p)) ) {
		case 79: goto tr610;
		case 111: goto tr610;
	}
	goto tr603;
case 583:
	switch( (*( sm->p)) ) {
		case 68: goto tr611;
		case 100: goto tr611;
	}
	goto tr603;
case 584:
	switch( (*( sm->p)) ) {
		case 69: goto tr612;
		case 101: goto tr612;
	}
	goto tr603;
case 585:
	if ( (*( sm->p)) == 93 )
		goto tr608;
	goto tr603;
case 738:
	switch( (*( sm->p)) ) {
		case 60: goto tr902;
		case 91: goto tr903;
	}
	goto tr901;
case 739:
	if ( (*( sm->p)) == 47 )
		goto tr905;
	goto tr904;
case 586:
	switch( (*( sm->p)) ) {
		case 78: goto tr614;
		case 110: goto tr614;
	}
	goto tr613;
case 587:
	switch( (*( sm->p)) ) {
		case 79: goto tr615;
		case 111: goto tr615;
	}
	goto tr613;
case 588:
	switch( (*( sm->p)) ) {
		case 68: goto tr616;
		case 100: goto tr616;
	}
	goto tr613;
case 589:
	switch( (*( sm->p)) ) {
		case 84: goto tr617;
		case 116: goto tr617;
	}
	goto tr613;
case 590:
	switch( (*( sm->p)) ) {
		case 69: goto tr618;
		case 101: goto tr618;
	}
	goto tr613;
case 591:
	switch( (*( sm->p)) ) {
		case 88: goto tr619;
		case 120: goto tr619;
	}
	goto tr613;
case 592:
	switch( (*( sm->p)) ) {
		case 84: goto tr620;
		case 116: goto tr620;
	}
	goto tr613;
case 593:
	if ( (*( sm->p)) == 62 )
		goto tr621;
	goto tr613;
case 740:
	if ( (*( sm->p)) == 47 )
		goto tr906;
	goto tr904;
case 594:
	switch( (*( sm->p)) ) {
		case 78: goto tr622;
		case 110: goto tr622;
	}
	goto tr613;
case 595:
	switch( (*( sm->p)) ) {
		case 79: goto tr623;
		case 111: goto tr623;
	}
	goto tr613;
case 596:
	switch( (*( sm->p)) ) {
		case 68: goto tr624;
		case 100: goto tr624;
	}
	goto tr613;
case 597:
	switch( (*( sm->p)) ) {
		case 84: goto tr625;
		case 116: goto tr625;
	}
	goto tr613;
case 598:
	switch( (*( sm->p)) ) {
		case 69: goto tr626;
		case 101: goto tr626;
	}
	goto tr613;
case 599:
	switch( (*( sm->p)) ) {
		case 88: goto tr627;
		case 120: goto tr627;
	}
	goto tr613;
case 600:
	switch( (*( sm->p)) ) {
		case 84: goto tr628;
		case 116: goto tr628;
	}
	goto tr613;
case 601:
	if ( (*( sm->p)) == 93 )
		goto tr621;
	goto tr613;
case 741:
	switch( (*( sm->p)) ) {
		case 60: goto tr908;
		case 91: goto tr909;
	}
	goto tr907;
case 742:
	switch( (*( sm->p)) ) {
		case 47: goto tr911;
		case 84: goto tr912;
		case 116: goto tr912;
	}
	goto tr910;
case 602:
	switch( (*( sm->p)) ) {
		case 84: goto tr630;
		case 116: goto tr630;
	}
	goto tr629;
case 603:
	switch( (*( sm->p)) ) {
		case 65: goto tr631;
		case 66: goto tr632;
		case 72: goto tr633;
		case 82: goto tr634;
		case 97: goto tr631;
		case 98: goto tr632;
		case 104: goto tr633;
		case 114: goto tr634;
	}
	goto tr629;
case 604:
	switch( (*( sm->p)) ) {
		case 66: goto tr635;
		case 98: goto tr635;
	}
	goto tr629;
case 605:
	switch( (*( sm->p)) ) {
		case 76: goto tr636;
		case 108: goto tr636;
	}
	goto tr629;
case 606:
	switch( (*( sm->p)) ) {
		case 69: goto tr637;
		case 101: goto tr637;
	}
	goto tr629;
case 607:
	if ( (*( sm->p)) == 62 )
		goto tr638;
	goto tr629;
case 608:
	switch( (*( sm->p)) ) {
		case 79: goto tr639;
		case 111: goto tr639;
	}
	goto tr629;
case 609:
	switch( (*( sm->p)) ) {
		case 68: goto tr640;
		case 100: goto tr640;
	}
	goto tr629;
case 610:
	switch( (*( sm->p)) ) {
		case 89: goto tr641;
		case 121: goto tr641;
	}
	goto tr629;
case 611:
	if ( (*( sm->p)) == 62 )
		goto tr642;
	goto tr629;
case 612:
	switch( (*( sm->p)) ) {
		case 69: goto tr643;
		case 101: goto tr643;
	}
	goto tr629;
case 613:
	switch( (*( sm->p)) ) {
		case 65: goto tr644;
		case 97: goto tr644;
	}
	goto tr629;
case 614:
	switch( (*( sm->p)) ) {
		case 68: goto tr645;
		case 100: goto tr645;
	}
	goto tr629;
case 615:
	if ( (*( sm->p)) == 62 )
		goto tr646;
	goto tr629;
case 616:
	if ( (*( sm->p)) == 62 )
		goto tr647;
	goto tr629;
case 617:
	switch( (*( sm->p)) ) {
		case 66: goto tr648;
		case 68: goto tr649;
		case 72: goto tr650;
		case 82: goto tr651;
		case 98: goto tr648;
		case 100: goto tr649;
		case 104: goto tr650;
		case 114: goto tr651;
	}
	goto tr629;
case 618:
	switch( (*( sm->p)) ) {
		case 79: goto tr652;
		case 111: goto tr652;
	}
	goto tr629;
case 619:
	switch( (*( sm->p)) ) {
		case 68: goto tr653;
		case 100: goto tr653;
	}
	goto tr629;
case 620:
	switch( (*( sm->p)) ) {
		case 89: goto tr654;
		case 121: goto tr654;
	}
	goto tr629;
case 621:
	if ( (*( sm->p)) == 62 )
		goto tr655;
	goto tr629;
case 622:
	if ( (*( sm->p)) == 62 )
		goto tr656;
	goto tr629;
case 623:
	switch( (*( sm->p)) ) {
		case 62: goto tr657;
		case 69: goto tr658;
		case 101: goto tr658;
	}
	goto tr629;
case 624:
	switch( (*( sm->p)) ) {
		case 65: goto tr659;
		case 97: goto tr659;
	}
	goto tr629;
case 625:
	switch( (*( sm->p)) ) {
		case 68: goto tr660;
		case 100: goto tr660;
	}
	goto tr629;
case 626:
	if ( (*( sm->p)) == 62 )
		goto tr661;
	goto tr629;
case 627:
	if ( (*( sm->p)) == 62 )
		goto tr662;
	goto tr629;
case 743:
	switch( (*( sm->p)) ) {
		case 47: goto tr913;
		case 116: goto tr914;
	}
	goto tr910;
case 628:
	if ( (*( sm->p)) == 116 )
		goto tr663;
	goto tr629;
case 629:
	switch( (*( sm->p)) ) {
		case 97: goto tr664;
		case 98: goto tr665;
		case 104: goto tr666;
		case 114: goto tr667;
	}
	goto tr629;
case 630:
	if ( (*( sm->p)) == 98 )
		goto tr668;
	goto tr629;
case 631:
	if ( (*( sm->p)) == 108 )
		goto tr669;
	goto tr629;
case 632:
	if ( (*( sm->p)) == 101 )
		goto tr670;
	goto tr629;
case 633:
	if ( (*( sm->p)) == 93 )
		goto tr638;
	goto tr629;
case 634:
	if ( (*( sm->p)) == 111 )
		goto tr671;
	goto tr629;
case 635:
	if ( (*( sm->p)) == 100 )
		goto tr672;
	goto tr629;
case 636:
	if ( (*( sm->p)) == 121 )
		goto tr673;
	goto tr629;
case 637:
	if ( (*( sm->p)) == 93 )
		goto tr642;
	goto tr629;
case 638:
	if ( (*( sm->p)) == 101 )
		goto tr674;
	goto tr629;
case 639:
	if ( (*( sm->p)) == 97 )
		goto tr675;
	goto tr629;
case 640:
	if ( (*( sm->p)) == 100 )
		goto tr676;
	goto tr629;
case 641:
	if ( (*( sm->p)) == 93 )
		goto tr646;
	goto tr629;
case 642:
	if ( (*( sm->p)) == 93 )
		goto tr647;
	goto tr629;
case 643:
	switch( (*( sm->p)) ) {
		case 98: goto tr677;
		case 100: goto tr678;
		case 104: goto tr679;
		case 114: goto tr680;
	}
	goto tr629;
case 644:
	if ( (*( sm->p)) == 111 )
		goto tr681;
	goto tr629;
case 645:
	if ( (*( sm->p)) == 100 )
		goto tr682;
	goto tr629;
case 646:
	if ( (*( sm->p)) == 121 )
		goto tr683;
	goto tr629;
case 647:
	if ( (*( sm->p)) == 93 )
		goto tr655;
	goto tr629;
case 648:
	if ( (*( sm->p)) == 93 )
		goto tr656;
	goto tr629;
case 649:
	switch( (*( sm->p)) ) {
		case 93: goto tr657;
		case 101: goto tr684;
	}
	goto tr629;
case 650:
	if ( (*( sm->p)) == 97 )
		goto tr685;
	goto tr629;
case 651:
	if ( (*( sm->p)) == 100 )
		goto tr686;
	goto tr629;
case 652:
	if ( (*( sm->p)) == 93 )
		goto tr661;
	goto tr629;
case 653:
	if ( (*( sm->p)) == 93 )
		goto tr662;
	goto tr629;
case 744:
	switch( (*( sm->p)) ) {
		case 10: goto tr916;
		case 13: goto tr917;
		case 42: goto tr918;
	}
	goto tr915;
case 745:
	switch( (*( sm->p)) ) {
		case 10: goto tr688;
		case 13: goto tr919;
	}
	goto tr687;
case 654:
	if ( (*( sm->p)) == 10 )
		goto tr688;
	goto tr687;
case 746:
	if ( (*( sm->p)) == 10 )
		goto tr916;
	goto tr920;
case 747:
	switch( (*( sm->p)) ) {
		case 9: goto tr692;
		case 32: goto tr692;
		case 42: goto tr693;
	}
	goto tr920;
case 655:
	switch( (*( sm->p)) ) {
		case 9: goto tr691;
		case 10: goto tr689;
		case 13: goto tr689;
		case 32: goto tr691;
	}
	goto tr690;
case 748:
	switch( (*( sm->p)) ) {
		case 10: goto tr921;
		case 13: goto tr921;
	}
	goto tr922;
case 749:
	switch( (*( sm->p)) ) {
		case 9: goto tr691;
		case 10: goto tr921;
		case 13: goto tr921;
		case 32: goto tr691;
	}
	goto tr690;
case 656:
	switch( (*( sm->p)) ) {
		case 9: goto tr692;
		case 32: goto tr692;
		case 42: goto tr693;
	}
	goto tr689;
	}

	tr701:  sm->cs = 0; goto _again;
	tr5:  sm->cs = 1; goto f4;
	tr6:  sm->cs = 2; goto _again;
	tr705:  sm->cs = 3; goto _again;
	tr7:  sm->cs = 4; goto _again;
	tr8:  sm->cs = 5; goto _again;
	tr9:  sm->cs = 6; goto _again;
	tr10:  sm->cs = 7; goto _again;
	tr11:  sm->cs = 8; goto _again;
	tr12:  sm->cs = 9; goto _again;
	tr13:  sm->cs = 10; goto _again;
	tr15:  sm->cs = 11; goto _again;
	tr706:  sm->cs = 12; goto _again;
	tr16:  sm->cs = 13; goto _again;
	tr17:  sm->cs = 14; goto _again;
	tr18:  sm->cs = 15; goto _again;
	tr19:  sm->cs = 16; goto _again;
	tr20:  sm->cs = 17; goto _again;
	tr21:  sm->cs = 18; goto _again;
	tr22:  sm->cs = 19; goto _again;
	tr23:  sm->cs = 20; goto _again;
	tr24:  sm->cs = 21; goto _again;
	tr707:  sm->cs = 22; goto _again;
	tr26:  sm->cs = 23; goto _again;
	tr27:  sm->cs = 24; goto _again;
	tr28:  sm->cs = 25; goto _again;
	tr708:  sm->cs = 26; goto _again;
	tr30:  sm->cs = 27; goto _again;
	tr31:  sm->cs = 28; goto _again;
	tr32:  sm->cs = 29; goto _again;
	tr33:  sm->cs = 30; goto _again;
	tr34:  sm->cs = 31; goto _again;
	tr709:  sm->cs = 32; goto _again;
	tr36:  sm->cs = 33; goto _again;
	tr37:  sm->cs = 34; goto _again;
	tr38:  sm->cs = 35; goto _again;
	tr39:  sm->cs = 36; goto _again;
	tr40:  sm->cs = 37; goto _again;
	tr41:  sm->cs = 38; goto _again;
	tr710:  sm->cs = 39; goto _again;
	tr43:  sm->cs = 40; goto _again;
	tr44:  sm->cs = 41; goto _again;
	tr45:  sm->cs = 42; goto _again;
	tr46:  sm->cs = 43; goto _again;
	tr47:  sm->cs = 44; goto _again;
	tr48:  sm->cs = 45; goto _again;
	tr50:  sm->cs = 46; goto _again;
	tr711:  sm->cs = 47; goto _again;
	tr51:  sm->cs = 48; goto _again;
	tr53:  sm->cs = 49; goto _again;
	tr54:  sm->cs = 50; goto _again;
	tr55:  sm->cs = 51; goto _again;
	tr52:  sm->cs = 52; goto _again;
	tr717:  sm->cs = 53; goto f9;
	tr58:  sm->cs = 54; goto f4;
	tr61:  sm->cs = 55; goto _again;
	tr60:  sm->cs = 55; goto f3;
	tr722:  sm->cs = 56; goto _again;
	tr63:  sm->cs = 57; goto _again;
	tr64:  sm->cs = 58; goto _again;
	tr65:  sm->cs = 59; goto _again;
	tr66:  sm->cs = 60; goto _again;
	tr67:  sm->cs = 61; goto _again;
	tr68:  sm->cs = 62; goto _again;
	tr69:  sm->cs = 63; goto _again;
	tr70:  sm->cs = 64; goto _again;
	tr723:  sm->cs = 65; goto _again;
	tr71:  sm->cs = 66; goto _again;
	tr72:  sm->cs = 67; goto _again;
	tr73:  sm->cs = 68; goto _again;
	tr724:  sm->cs = 69; goto _again;
	tr74:  sm->cs = 70; goto _again;
	tr75:  sm->cs = 71; goto _again;
	tr76:  sm->cs = 72; goto _again;
	tr77:  sm->cs = 73; goto _again;
	tr78:  sm->cs = 74; goto _again;
	tr79:  sm->cs = 75; goto _again;
	tr81:  sm->cs = 76; goto _again;
	tr80:  sm->cs = 76; goto f9;
	tr725:  sm->cs = 77; goto _again;
	tr83:  sm->cs = 78; goto _again;
	tr84:  sm->cs = 79; goto _again;
	tr85:  sm->cs = 80; goto _again;
	tr86:  sm->cs = 81; goto _again;
	tr87:  sm->cs = 82; goto _again;
	tr88:  sm->cs = 83; goto _again;
	tr726:  sm->cs = 84; goto _again;
	tr89:  sm->cs = 85; goto _again;
	tr90:  sm->cs = 86; goto _again;
	tr91:  sm->cs = 87; goto _again;
	tr92:  sm->cs = 88; goto _again;
	tr727:  sm->cs = 89; goto _again;
	tr93:  sm->cs = 90; goto _again;
	tr94:  sm->cs = 91; goto _again;
	tr95:  sm->cs = 92; goto _again;
	tr96:  sm->cs = 93; goto _again;
	tr97:  sm->cs = 94; goto _again;
	tr98:  sm->cs = 95; goto _again;
	tr99:  sm->cs = 96; goto _again;
	tr728:  sm->cs = 97; goto _again;
	tr100:  sm->cs = 98; goto _again;
	tr729:  sm->cs = 99; goto _again;
	tr101:  sm->cs = 100; goto _again;
	tr102:  sm->cs = 101; goto _again;
	tr103:  sm->cs = 102; goto _again;
	tr104:  sm->cs = 103; goto _again;
	tr105:  sm->cs = 104; goto _again;
	tr730:  sm->cs = 105; goto _again;
	tr106:  sm->cs = 106; goto _again;
	tr107:  sm->cs = 107; goto _again;
	tr108:  sm->cs = 108; goto _again;
	tr109:  sm->cs = 109; goto _again;
	tr737:  sm->cs = 110; goto _again;
	tr111:  sm->cs = 111; goto _again;
	tr112:  sm->cs = 112; goto _again;
	tr113:  sm->cs = 113; goto _again;
	tr114:  sm->cs = 114; goto _again;
	tr119:  sm->cs = 115; goto _again;
	tr120:  sm->cs = 116; goto _again;
	tr121:  sm->cs = 117; goto _again;
	tr122:  sm->cs = 118; goto _again;
	tr115:  sm->cs = 119; goto _again;
	tr132:  sm->cs = 120; goto _again;
	tr738:  sm->cs = 121; goto _again;
	tr125:  sm->cs = 122; goto _again;
	tr739:  sm->cs = 123; goto _again;
	tr128:  sm->cs = 124; goto _again;
	tr129:  sm->cs = 125; goto _again;
	tr130:  sm->cs = 126; goto _again;
	tr131:  sm->cs = 127; goto _again;
	tr740:  sm->cs = 128; goto _again;
	tr741:  sm->cs = 129; goto _again;
	tr134:  sm->cs = 130; goto _again;
	tr135:  sm->cs = 131; goto _again;
	tr136:  sm->cs = 132; goto _again;
	tr137:  sm->cs = 133; goto _again;
	tr742:  sm->cs = 134; goto _again;
	tr743:  sm->cs = 135; goto _again;
	tr744:  sm->cs = 136; goto _again;
	tr745:  sm->cs = 137; goto _again;
	tr769:  sm->cs = 138; goto _again;
	tr142:  sm->cs = 139; goto _again;
	tr770:  sm->cs = 139; goto f9;
	tr141:  sm->cs = 140; goto f4;
	tr146:  sm->cs = 141; goto _again;
	tr776:  sm->cs = 141; goto f9;
	tr147:  sm->cs = 142; goto f4;
	tr148:  sm->cs = 143; goto _again;
	tr176:  sm->cs = 144; goto _again;
	tr149:  sm->cs = 144; goto f3;
	tr152:  sm->cs = 145; goto _again;
	tr153:  sm->cs = 146; goto _again;
	tr154:  sm->cs = 147; goto _again;
	tr150:  sm->cs = 148; goto _again;
	tr169:  sm->cs = 149; goto _again;
	tr156:  sm->cs = 149; goto f3;
	tr158:  sm->cs = 150; goto _again;
	tr161:  sm->cs = 151; goto f8;
	tr159:  sm->cs = 152; goto _again;
	tr160:  sm->cs = 153; goto _again;
	tr157:  sm->cs = 154; goto f3;
	tr163:  sm->cs = 155; goto _again;
	tr164:  sm->cs = 156; goto _again;
	tr165:  sm->cs = 157; goto _again;
	tr166:  sm->cs = 158; goto _again;
	tr168:  sm->cs = 159; goto _again;
	tr167:  sm->cs = 160; goto _again;
	tr151:  sm->cs = 161; goto f3;
	tr170:  sm->cs = 162; goto _again;
	tr171:  sm->cs = 163; goto _again;
	tr172:  sm->cs = 164; goto _again;
	tr173:  sm->cs = 165; goto _again;
	tr175:  sm->cs = 166; goto _again;
	tr174:  sm->cs = 167; goto _again;
	tr778:  sm->cs = 168; goto _again;
	tr177:  sm->cs = 169; goto _again;
	tr184:  sm->cs = 170; goto _again;
	tr185:  sm->cs = 171; goto _again;
	tr186:  sm->cs = 172; goto _again;
	tr187:  sm->cs = 173; goto _again;
	tr188:  sm->cs = 174; goto _again;
	tr189:  sm->cs = 175; goto _again;
	tr190:  sm->cs = 176; goto _again;
	tr191:  sm->cs = 177; goto _again;
	tr192:  sm->cs = 178; goto _again;
	tr178:  sm->cs = 179; goto _again;
	tr179:  sm->cs = 180; goto _again;
	tr194:  sm->cs = 181; goto _again;
	tr196:  sm->cs = 182; goto _again;
	tr197:  sm->cs = 183; goto _again;
	tr198:  sm->cs = 184; goto _again;
	tr199:  sm->cs = 185; goto _again;
	tr180:  sm->cs = 186; goto _again;
	tr202:  sm->cs = 187; goto _again;
	tr204:  sm->cs = 188; goto _again;
	tr205:  sm->cs = 189; goto _again;
	tr206:  sm->cs = 190; goto _again;
	tr207:  sm->cs = 191; goto _again;
	tr208:  sm->cs = 192; goto _again;
	tr210:  sm->cs = 193; goto _again;
	tr203:  sm->cs = 194; goto _again;
	tr211:  sm->cs = 195; goto _again;
	tr212:  sm->cs = 196; goto _again;
	tr213:  sm->cs = 197; goto _again;
	tr214:  sm->cs = 198; goto _again;
	tr181:  sm->cs = 199; goto _again;
	tr215:  sm->cs = 200; goto _again;
	tr216:  sm->cs = 201; goto _again;
	tr182:  sm->cs = 202; goto _again;
	tr779:  sm->cs = 203; goto _again;
	tr225:  sm->cs = 204; goto _again;
	tr220:  sm->cs = 204; goto f9;
	tr224:  sm->cs = 205; goto _again;
	tr223:  sm->cs = 205; goto f9;
	tr226:  sm->cs = 206; goto _again;
	tr221:  sm->cs = 206; goto f9;
	tr227:  sm->cs = 207; goto _again;
	tr222:  sm->cs = 207; goto f9;
	tr780:  sm->cs = 208; goto _again;
	tr230:  sm->cs = 209; goto _again;
	tr231:  sm->cs = 210; goto _again;
	tr232:  sm->cs = 211; goto _again;
	tr233:  sm->cs = 212; goto _again;
	tr234:  sm->cs = 213; goto _again;
	tr235:  sm->cs = 214; goto _again;
	tr236:  sm->cs = 215; goto _again;
	tr237:  sm->cs = 216; goto _again;
	tr238:  sm->cs = 217; goto _again;
	tr781:  sm->cs = 218; goto _again;
	tr240:  sm->cs = 219; goto _again;
	tr241:  sm->cs = 220; goto _again;
	tr242:  sm->cs = 221; goto _again;
	tr782:  sm->cs = 222; goto _again;
	tr244:  sm->cs = 223; goto _again;
	tr245:  sm->cs = 224; goto _again;
	tr247:  sm->cs = 225; goto _again;
	tr248:  sm->cs = 226; goto _again;
	tr249:  sm->cs = 227; goto _again;
	tr250:  sm->cs = 228; goto _again;
	tr783:  sm->cs = 229; goto _again;
	tr252:  sm->cs = 230; goto _again;
	tr253:  sm->cs = 231; goto _again;
	tr254:  sm->cs = 232; goto _again;
	tr255:  sm->cs = 233; goto _again;
	tr256:  sm->cs = 234; goto _again;
	tr257:  sm->cs = 235; goto _again;
	tr784:  sm->cs = 236; goto _again;
	tr259:  sm->cs = 237; goto _again;
	tr260:  sm->cs = 238; goto _again;
	tr261:  sm->cs = 239; goto _again;
	tr262:  sm->cs = 240; goto _again;
	tr785:  sm->cs = 241; goto _again;
	tr265:  sm->cs = 242; goto _again;
	tr267:  sm->cs = 243; goto _again;
	tr268:  sm->cs = 244; goto _again;
	tr269:  sm->cs = 245; goto _again;
	tr270:  sm->cs = 246; goto _again;
	tr271:  sm->cs = 247; goto _again;
	tr273:  sm->cs = 248; goto _again;
	tr266:  sm->cs = 249; goto _again;
	tr274:  sm->cs = 250; goto _again;
	tr275:  sm->cs = 251; goto _again;
	tr276:  sm->cs = 252; goto _again;
	tr277:  sm->cs = 253; goto _again;
	tr786:  sm->cs = 254; goto _again;
	tr278:  sm->cs = 255; goto _again;
	tr787:  sm->cs = 256; goto _again;
	tr788:  sm->cs = 257; goto _again;
	tr281:  sm->cs = 258; goto _again;
	tr282:  sm->cs = 259; goto _again;
	tr283:  sm->cs = 260; goto _again;
	tr284:  sm->cs = 261; goto _again;
	tr285:  sm->cs = 262; goto _again;
	tr286:  sm->cs = 263; goto _again;
	tr287:  sm->cs = 264; goto _again;
	tr308:  sm->cs = 265; goto _again;
	tr288:  sm->cs = 265; goto f9;
	tr290:  sm->cs = 266; goto _again;
	tr293:  sm->cs = 267; goto _again;
	tr291:  sm->cs = 268; goto _again;
	tr292:  sm->cs = 269; goto _again;
	tr294:  sm->cs = 270; goto f4;
	tr295:  sm->cs = 271; goto _again;
	tr297:  sm->cs = 272; goto _again;
	tr296:  sm->cs = 272; goto f3;
	tr298:  sm->cs = 273; goto f8;
	tr299:  sm->cs = 274; goto _again;
	tr300:  sm->cs = 275; goto _again;
	tr289:  sm->cs = 276; goto f9;
	tr302:  sm->cs = 277; goto _again;
	tr303:  sm->cs = 278; goto _again;
	tr304:  sm->cs = 279; goto _again;
	tr305:  sm->cs = 280; goto _again;
	tr307:  sm->cs = 281; goto _again;
	tr306:  sm->cs = 282; goto _again;
	tr789:  sm->cs = 283; goto _again;
	tr309:  sm->cs = 284; goto _again;
	tr310:  sm->cs = 285; goto _again;
	tr311:  sm->cs = 286; goto _again;
	tr312:  sm->cs = 287; goto _again;
	tr314:  sm->cs = 288; goto _again;
	tr315:  sm->cs = 289; goto _again;
	tr316:  sm->cs = 290; goto _again;
	tr319:  sm->cs = 291; goto _again;
	tr317:  sm->cs = 292; goto _again;
	tr318:  sm->cs = 293; goto _again;
	tr313:  sm->cs = 294; goto _again;
	tr322:  sm->cs = 295; goto _again;
	tr790:  sm->cs = 295; goto f9;
	tr323:  sm->cs = 296; goto _again;
	tr791:  sm->cs = 296; goto f9;
	tr795:  sm->cs = 297; goto _again;
	tr792:  sm->cs = 297; goto f9;
	tr798:  sm->cs = 298; goto _again;
	tr324:  sm->cs = 299; goto _again;
	tr325:  sm->cs = 300; goto _again;
	tr326:  sm->cs = 301; goto _again;
	tr327:  sm->cs = 302; goto _again;
	tr328:  sm->cs = 303; goto _again;
	tr799:  sm->cs = 304; goto _again;
	tr330:  sm->cs = 305; goto _again;
	tr331:  sm->cs = 306; goto _again;
	tr332:  sm->cs = 307; goto _again;
	tr333:  sm->cs = 308; goto _again;
	tr334:  sm->cs = 309; goto _again;
	tr335:  sm->cs = 310; goto _again;
	tr800:  sm->cs = 311; goto _again;
	tr337:  sm->cs = 312; goto _again;
	tr338:  sm->cs = 313; goto _again;
	tr340:  sm->cs = 314; goto _again;
	tr341:  sm->cs = 315; goto _again;
	tr342:  sm->cs = 316; goto _again;
	tr343:  sm->cs = 317; goto _again;
	tr339:  sm->cs = 318; goto _again;
	tr345:  sm->cs = 319; goto _again;
	tr346:  sm->cs = 320; goto _again;
	tr347:  sm->cs = 321; goto _again;
	tr348:  sm->cs = 322; goto _again;
	tr349:  sm->cs = 323; goto _again;
	tr350:  sm->cs = 324; goto _again;
	tr351:  sm->cs = 325; goto _again;
	tr352:  sm->cs = 326; goto _again;
	tr809:  sm->cs = 327; goto _again;
	tr354:  sm->cs = 328; goto _again;
	tr355:  sm->cs = 329; goto _again;
	tr356:  sm->cs = 330; goto _again;
	tr810:  sm->cs = 331; goto _again;
	tr358:  sm->cs = 332; goto _again;
	tr359:  sm->cs = 333; goto _again;
	tr360:  sm->cs = 334; goto _again;
	tr815:  sm->cs = 335; goto _again;
	tr362:  sm->cs = 336; goto _again;
	tr363:  sm->cs = 337; goto _again;
	tr364:  sm->cs = 338; goto _again;
	tr365:  sm->cs = 339; goto _again;
	tr366:  sm->cs = 340; goto _again;
	tr367:  sm->cs = 341; goto _again;
	tr368:  sm->cs = 342; goto _again;
	tr818:  sm->cs = 343; goto _again;
	tr370:  sm->cs = 344; goto _again;
	tr371:  sm->cs = 345; goto _again;
	tr372:  sm->cs = 346; goto _again;
	tr373:  sm->cs = 347; goto _again;
	tr374:  sm->cs = 348; goto _again;
	tr375:  sm->cs = 349; goto _again;
	tr376:  sm->cs = 350; goto _again;
	tr377:  sm->cs = 351; goto _again;
	tr378:  sm->cs = 352; goto _again;
	tr379:  sm->cs = 353; goto _again;
	tr821:  sm->cs = 354; goto _again;
	tr381:  sm->cs = 355; goto _again;
	tr382:  sm->cs = 356; goto _again;
	tr383:  sm->cs = 357; goto _again;
	tr384:  sm->cs = 358; goto _again;
	tr385:  sm->cs = 359; goto _again;
	tr386:  sm->cs = 360; goto _again;
	tr387:  sm->cs = 361; goto _again;
	tr388:  sm->cs = 362; goto _again;
	tr822:  sm->cs = 363; goto _again;
	tr390:  sm->cs = 364; goto _again;
	tr391:  sm->cs = 365; goto _again;
	tr392:  sm->cs = 366; goto _again;
	tr393:  sm->cs = 367; goto _again;
	tr394:  sm->cs = 368; goto _again;
	tr395:  sm->cs = 369; goto _again;
	tr396:  sm->cs = 370; goto _again;
	tr397:  sm->cs = 371; goto _again;
	tr823:  sm->cs = 372; goto _again;
	tr399:  sm->cs = 373; goto _again;
	tr400:  sm->cs = 374; goto _again;
	tr401:  sm->cs = 375; goto _again;
	tr402:  sm->cs = 376; goto _again;
	tr824:  sm->cs = 377; goto _again;
	tr404:  sm->cs = 378; goto _again;
	tr405:  sm->cs = 379; goto _again;
	tr406:  sm->cs = 380; goto _again;
	tr407:  sm->cs = 381; goto _again;
	tr408:  sm->cs = 382; goto _again;
	tr833:  sm->cs = 383; goto _again;
	tr410:  sm->cs = 384; goto _again;
	tr411:  sm->cs = 385; goto _again;
	tr412:  sm->cs = 386; goto _again;
	tr413:  sm->cs = 387; goto _again;
	tr414:  sm->cs = 388; goto _again;
	tr415:  sm->cs = 389; goto _again;
	tr416:  sm->cs = 390; goto _again;
	tr417:  sm->cs = 391; goto _again;
	tr418:  sm->cs = 392; goto _again;
	tr419:  sm->cs = 393; goto _again;
	tr420:  sm->cs = 394; goto _again;
	tr834:  sm->cs = 395; goto _again;
	tr422:  sm->cs = 396; goto _again;
	tr423:  sm->cs = 397; goto _again;
	tr424:  sm->cs = 398; goto _again;
	tr425:  sm->cs = 399; goto _again;
	tr426:  sm->cs = 400; goto _again;
	tr839:  sm->cs = 401; goto _again;
	tr428:  sm->cs = 402; goto _again;
	tr429:  sm->cs = 403; goto _again;
	tr430:  sm->cs = 404; goto _again;
	tr431:  sm->cs = 405; goto _again;
	tr432:  sm->cs = 406; goto _again;
	tr433:  sm->cs = 407; goto _again;
	tr434:  sm->cs = 408; goto _again;
	tr435:  sm->cs = 409; goto _again;
	tr436:  sm->cs = 410; goto _again;
	tr437:  sm->cs = 411; goto _again;
	tr842:  sm->cs = 412; goto _again;
	tr439:  sm->cs = 413; goto _again;
	tr440:  sm->cs = 414; goto _again;
	tr441:  sm->cs = 415; goto _again;
	tr442:  sm->cs = 416; goto _again;
	tr443:  sm->cs = 417; goto _again;
	tr843:  sm->cs = 418; goto _again;
	tr445:  sm->cs = 419; goto _again;
	tr446:  sm->cs = 420; goto _again;
	tr447:  sm->cs = 421; goto _again;
	tr448:  sm->cs = 422; goto _again;
	tr848:  sm->cs = 423; goto _again;
	tr450:  sm->cs = 424; goto _again;
	tr451:  sm->cs = 425; goto _again;
	tr452:  sm->cs = 426; goto _again;
	tr453:  sm->cs = 427; goto _again;
	tr454:  sm->cs = 428; goto _again;
	tr849:  sm->cs = 429; goto _again;
	tr456:  sm->cs = 430; goto _again;
	tr457:  sm->cs = 431; goto _again;
	tr458:  sm->cs = 432; goto _again;
	tr459:  sm->cs = 433; goto _again;
	tr460:  sm->cs = 434; goto _again;
	tr854:  sm->cs = 435; goto f4;
	tr463:  sm->cs = 436; goto _again;
	tr850:  sm->cs = 437; goto _again;
	tr465:  sm->cs = 438; goto _again;
	tr467:  sm->cs = 439; goto _again;
	tr468:  sm->cs = 440; goto _again;
	tr469:  sm->cs = 441; goto _again;
	tr466:  sm->cs = 442; goto _again;
	tr471:  sm->cs = 443; goto _again;
	tr472:  sm->cs = 444; goto _again;
	tr473:  sm->cs = 445; goto _again;
	tr862:  sm->cs = 446; goto _again;
	tr475:  sm->cs = 447; goto _again;
	tr476:  sm->cs = 448; goto _again;
	tr477:  sm->cs = 449; goto _again;
	tr478:  sm->cs = 450; goto _again;
	tr479:  sm->cs = 451; goto _again;
	tr865:  sm->cs = 452; goto _again;
	tr481:  sm->cs = 453; goto _again;
	tr482:  sm->cs = 454; goto _again;
	tr483:  sm->cs = 455; goto _again;
	tr484:  sm->cs = 456; goto _again;
	tr485:  sm->cs = 457; goto _again;
	tr868:  sm->cs = 458; goto f4;
	tr488:  sm->cs = 459; goto _again;
	tr866:  sm->cs = 460; goto _again;
	tr490:  sm->cs = 461; goto _again;
	tr491:  sm->cs = 462; goto _again;
	tr492:  sm->cs = 463; goto _again;
	tr493:  sm->cs = 464; goto _again;
	tr494:  sm->cs = 465; goto _again;
	tr495:  sm->cs = 466; goto _again;
	tr496:  sm->cs = 467; goto _again;
	tr874:  sm->cs = 468; goto _again;
	tr498:  sm->cs = 469; goto _again;
	tr499:  sm->cs = 470; goto _again;
	tr500:  sm->cs = 471; goto _again;
	tr501:  sm->cs = 472; goto _again;
	tr877:  sm->cs = 473; goto _again;
	tr503:  sm->cs = 474; goto _again;
	tr504:  sm->cs = 475; goto _again;
	tr505:  sm->cs = 476; goto _again;
	tr506:  sm->cs = 477; goto _again;
	tr880:  sm->cs = 478; goto _again;
	tr508:  sm->cs = 479; goto _again;
	tr509:  sm->cs = 480; goto _again;
	tr510:  sm->cs = 481; goto _again;
	tr516:  sm->cs = 482; goto _again;
	tr517:  sm->cs = 483; goto _again;
	tr518:  sm->cs = 484; goto _again;
	tr519:  sm->cs = 485; goto _again;
	tr511:  sm->cs = 486; goto _again;
	tr520:  sm->cs = 487; goto _again;
	tr521:  sm->cs = 488; goto _again;
	tr522:  sm->cs = 489; goto _again;
	tr523:  sm->cs = 490; goto _again;
	tr524:  sm->cs = 491; goto _again;
	tr525:  sm->cs = 492; goto _again;
	tr526:  sm->cs = 493; goto _again;
	tr512:  sm->cs = 494; goto _again;
	tr527:  sm->cs = 495; goto _again;
	tr513:  sm->cs = 496; goto _again;
	tr514:  sm->cs = 497; goto _again;
	tr529:  sm->cs = 498; goto _again;
	tr530:  sm->cs = 499; goto _again;
	tr531:  sm->cs = 500; goto _again;
	tr532:  sm->cs = 501; goto _again;
	tr533:  sm->cs = 502; goto _again;
	tr515:  sm->cs = 503; goto _again;
	tr534:  sm->cs = 504; goto _again;
	tr535:  sm->cs = 505; goto _again;
	tr881:  sm->cs = 506; goto _again;
	tr882:  sm->cs = 507; goto _again;
	tr536:  sm->cs = 508; goto _again;
	tr537:  sm->cs = 509; goto _again;
	tr538:  sm->cs = 510; goto _again;
	tr883:  sm->cs = 511; goto _again;
	tr884:  sm->cs = 512; goto _again;
	tr539:  sm->cs = 513; goto _again;
	tr540:  sm->cs = 514; goto _again;
	tr541:  sm->cs = 515; goto _again;
	tr542:  sm->cs = 516; goto _again;
	tr543:  sm->cs = 517; goto _again;
	tr544:  sm->cs = 518; goto _again;
	tr885:  sm->cs = 519; goto _again;
	tr545:  sm->cs = 520; goto _again;
	tr546:  sm->cs = 521; goto _again;
	tr547:  sm->cs = 522; goto _again;
	tr548:  sm->cs = 523; goto _again;
	tr886:  sm->cs = 524; goto _again;
	tr549:  sm->cs = 525; goto _again;
	tr550:  sm->cs = 526; goto _again;
	tr551:  sm->cs = 527; goto _again;
	tr552:  sm->cs = 528; goto _again;
	tr553:  sm->cs = 529; goto _again;
	tr554:  sm->cs = 530; goto _again;
	tr555:  sm->cs = 531; goto _again;
	tr887:  sm->cs = 532; goto _again;
	tr556:  sm->cs = 533; goto _again;
	tr888:  sm->cs = 534; goto _again;
	tr889:  sm->cs = 535; goto _again;
	tr559:  sm->cs = 536; goto _again;
	tr557:  sm->cs = 536; goto f9;
	tr560:  sm->cs = 537; goto f4;
	tr561:  sm->cs = 538; goto f4;
	tr564:  sm->cs = 539; goto _again;
	tr563:  sm->cs = 539; goto f3;
	tr565:  sm->cs = 540; goto f8;
	tr567:  sm->cs = 541; goto _again;
	tr558:  sm->cs = 541; goto f9;
	tr890:  sm->cs = 542; goto _again;
	tr568:  sm->cs = 543; goto _again;
	tr569:  sm->cs = 544; goto _again;
	tr570:  sm->cs = 545; goto _again;
	tr571:  sm->cs = 546; goto _again;
	tr572:  sm->cs = 547; goto _again;
	tr891:  sm->cs = 548; goto f9;
	tr573:  sm->cs = 549; goto _again;
	tr574:  sm->cs = 550; goto _again;
	tr575:  sm->cs = 551; goto _again;
	tr576:  sm->cs = 552; goto _again;
	tr578:  sm->cs = 553; goto _again;
	tr579:  sm->cs = 554; goto _again;
	tr580:  sm->cs = 555; goto _again;
	tr583:  sm->cs = 556; goto _again;
	tr581:  sm->cs = 557; goto _again;
	tr582:  sm->cs = 558; goto _again;
	tr584:  sm->cs = 559; goto f4;
	tr585:  sm->cs = 560; goto _again;
	tr587:  sm->cs = 561; goto _again;
	tr586:  sm->cs = 561; goto f3;
	tr577:  sm->cs = 562; goto _again;
	tr892:  sm->cs = 563; goto _again;
	tr589:  sm->cs = 564; goto _again;
	tr590:  sm->cs = 565; goto _again;
	tr591:  sm->cs = 566; goto _again;
	tr593:  sm->cs = 567; goto _again;
	tr594:  sm->cs = 568; goto _again;
	tr595:  sm->cs = 569; goto _again;
	tr596:  sm->cs = 570; goto _again;
	tr597:  sm->cs = 571; goto _again;
	tr592:  sm->cs = 572; goto _again;
	tr894:  sm->cs = 573; goto _again;
	tr600:  sm->cs = 574; goto _again;
	tr599:  sm->cs = 574; goto f9;
	tr601:  sm->cs = 575; goto f4;
	tr899:  sm->cs = 576; goto _again;
	tr604:  sm->cs = 577; goto _again;
	tr605:  sm->cs = 578; goto _again;
	tr606:  sm->cs = 579; goto _again;
	tr607:  sm->cs = 580; goto _again;
	tr900:  sm->cs = 581; goto _again;
	tr609:  sm->cs = 582; goto _again;
	tr610:  sm->cs = 583; goto _again;
	tr611:  sm->cs = 584; goto _again;
	tr612:  sm->cs = 585; goto _again;
	tr905:  sm->cs = 586; goto _again;
	tr614:  sm->cs = 587; goto _again;
	tr615:  sm->cs = 588; goto _again;
	tr616:  sm->cs = 589; goto _again;
	tr617:  sm->cs = 590; goto _again;
	tr618:  sm->cs = 591; goto _again;
	tr619:  sm->cs = 592; goto _again;
	tr620:  sm->cs = 593; goto _again;
	tr906:  sm->cs = 594; goto _again;
	tr622:  sm->cs = 595; goto _again;
	tr623:  sm->cs = 596; goto _again;
	tr624:  sm->cs = 597; goto _again;
	tr625:  sm->cs = 598; goto _again;
	tr626:  sm->cs = 599; goto _again;
	tr627:  sm->cs = 600; goto _again;
	tr628:  sm->cs = 601; goto _again;
	tr911:  sm->cs = 602; goto _again;
	tr630:  sm->cs = 603; goto _again;
	tr631:  sm->cs = 604; goto _again;
	tr635:  sm->cs = 605; goto _again;
	tr636:  sm->cs = 606; goto _again;
	tr637:  sm->cs = 607; goto _again;
	tr632:  sm->cs = 608; goto _again;
	tr639:  sm->cs = 609; goto _again;
	tr640:  sm->cs = 610; goto _again;
	tr641:  sm->cs = 611; goto _again;
	tr633:  sm->cs = 612; goto _again;
	tr643:  sm->cs = 613; goto _again;
	tr644:  sm->cs = 614; goto _again;
	tr645:  sm->cs = 615; goto _again;
	tr634:  sm->cs = 616; goto _again;
	tr912:  sm->cs = 617; goto _again;
	tr648:  sm->cs = 618; goto _again;
	tr652:  sm->cs = 619; goto _again;
	tr653:  sm->cs = 620; goto _again;
	tr654:  sm->cs = 621; goto _again;
	tr649:  sm->cs = 622; goto _again;
	tr650:  sm->cs = 623; goto _again;
	tr658:  sm->cs = 624; goto _again;
	tr659:  sm->cs = 625; goto _again;
	tr660:  sm->cs = 626; goto _again;
	tr651:  sm->cs = 627; goto _again;
	tr913:  sm->cs = 628; goto _again;
	tr663:  sm->cs = 629; goto _again;
	tr664:  sm->cs = 630; goto _again;
	tr668:  sm->cs = 631; goto _again;
	tr669:  sm->cs = 632; goto _again;
	tr670:  sm->cs = 633; goto _again;
	tr665:  sm->cs = 634; goto _again;
	tr671:  sm->cs = 635; goto _again;
	tr672:  sm->cs = 636; goto _again;
	tr673:  sm->cs = 637; goto _again;
	tr666:  sm->cs = 638; goto _again;
	tr674:  sm->cs = 639; goto _again;
	tr675:  sm->cs = 640; goto _again;
	tr676:  sm->cs = 641; goto _again;
	tr667:  sm->cs = 642; goto _again;
	tr914:  sm->cs = 643; goto _again;
	tr677:  sm->cs = 644; goto _again;
	tr681:  sm->cs = 645; goto _again;
	tr682:  sm->cs = 646; goto _again;
	tr683:  sm->cs = 647; goto _again;
	tr678:  sm->cs = 648; goto _again;
	tr679:  sm->cs = 649; goto _again;
	tr684:  sm->cs = 650; goto _again;
	tr685:  sm->cs = 651; goto _again;
	tr686:  sm->cs = 652; goto _again;
	tr680:  sm->cs = 653; goto _again;
	tr919:  sm->cs = 654; goto _again;
	tr692:  sm->cs = 655; goto f4;
	tr693:  sm->cs = 656; goto _again;
	tr0:  sm->cs = 657; goto f0;
	tr2:  sm->cs = 657; goto f2;
	tr14:  sm->cs = 657; goto f5;
	tr56:  sm->cs = 657; goto f6;
	tr57:  sm->cs = 657; goto f7;
	tr694:  sm->cs = 657; goto f77;
	tr702:  sm->cs = 657; goto f80;
	tr703:  sm->cs = 657; goto f81;
	tr712:  sm->cs = 657; goto f82;
	tr713:  sm->cs = 657; goto f83;
	tr714:  sm->cs = 657; goto f84;
	tr715:  sm->cs = 657; goto f85;
	tr716:  sm->cs = 657; goto f86;
	tr718:  sm->cs = 657; goto f87;
	tr720:  sm->cs = 657; goto f88;
	tr731:  sm->cs = 657; goto f89;
	tr1:  sm->cs = 658; goto f1;
	tr695:  sm->cs = 658; goto f78;
	tr696:  sm->cs = 659; goto _again;
	tr697:  sm->cs = 660; goto f49;
	tr704:  sm->cs = 661; goto _again;
	tr3:  sm->cs = 661; goto f3;
	tr4:  sm->cs = 662; goto f3;
	tr698:  sm->cs = 663; goto f79;
	tr25:  sm->cs = 664; goto _again;
	tr29:  sm->cs = 665; goto _again;
	tr35:  sm->cs = 666; goto _again;
	tr42:  sm->cs = 667; goto _again;
	tr49:  sm->cs = 668; goto _again;
	tr699:  sm->cs = 669; goto f79;
	tr719:  sm->cs = 670; goto _again;
	tr62:  sm->cs = 670; goto f8;
	tr721:  sm->cs = 671; goto _again;
	tr59:  sm->cs = 671; goto f4;
	tr700:  sm->cs = 672; goto f79;
	tr732:  sm->cs = 673; goto _again;
	tr82:  sm->cs = 673; goto f4;
	tr110:  sm->cs = 674; goto f10;
	tr116:  sm->cs = 674; goto f11;
	tr117:  sm->cs = 674; goto f12;
	tr118:  sm->cs = 674; goto f13;
	tr123:  sm->cs = 674; goto f14;
	tr124:  sm->cs = 674; goto f15;
	tr126:  sm->cs = 674; goto f16;
	tr127:  sm->cs = 674; goto f17;
	tr133:  sm->cs = 674; goto f18;
	tr733:  sm->cs = 674; goto f90;
	tr736:  sm->cs = 674; goto f91;
	tr734:  sm->cs = 675; goto f79;
	tr735:  sm->cs = 676; goto f79;
	tr138:  sm->cs = 677; goto f19;
	tr140:  sm->cs = 677; goto f21;
	tr145:  sm->cs = 677; goto f22;
	tr162:  sm->cs = 677; goto f24;
	tr183:  sm->cs = 677; goto f25;
	tr195:  sm->cs = 677; goto f27;
	tr200:  sm->cs = 677; goto f28;
	tr201:  sm->cs = 677; goto f29;
	tr209:  sm->cs = 677; goto f30;
	tr217:  sm->cs = 677; goto f31;
	tr218:  sm->cs = 677; goto f32;
	tr219:  sm->cs = 677; goto f33;
	tr228:  sm->cs = 677; goto f34;
	tr229:  sm->cs = 677; goto f35;
	tr239:  sm->cs = 677; goto f36;
	tr243:  sm->cs = 677; goto f37;
	tr246:  sm->cs = 677; goto f38;
	tr251:  sm->cs = 677; goto f39;
	tr258:  sm->cs = 677; goto f40;
	tr264:  sm->cs = 677; goto f42;
	tr272:  sm->cs = 677; goto f43;
	tr279:  sm->cs = 677; goto f44;
	tr280:  sm->cs = 677; goto f45;
	tr301:  sm->cs = 677; goto f46;
	tr320:  sm->cs = 677; goto f47;
	tr462:  sm->cs = 677; goto f50;
	tr487:  sm->cs = 677; goto f51;
	tr528:  sm->cs = 677; goto f52;
	tr562:  sm->cs = 677; goto f53;
	tr566:  sm->cs = 677; goto f54;
	tr588:  sm->cs = 677; goto f55;
	tr602:  sm->cs = 677; goto f57;
	tr746:  sm->cs = 677; goto f92;
	tr768:  sm->cs = 677; goto f95;
	tr771:  sm->cs = 677; goto f96;
	tr772:  sm->cs = 677; goto f97;
	tr774:  sm->cs = 677; goto f98;
	tr775:  sm->cs = 677; goto f99;
	tr777:  sm->cs = 677; goto f100;
	tr794:  sm->cs = 677; goto f102;
	tr796:  sm->cs = 677; goto f103;
	tr801:  sm->cs = 677; goto f105;
	tr803:  sm->cs = 677; goto f106;
	tr805:  sm->cs = 677; goto f107;
	tr807:  sm->cs = 677; goto f108;
	tr811:  sm->cs = 677; goto f109;
	tr813:  sm->cs = 677; goto f110;
	tr816:  sm->cs = 677; goto f111;
	tr819:  sm->cs = 677; goto f112;
	tr825:  sm->cs = 677; goto f113;
	tr827:  sm->cs = 677; goto f114;
	tr829:  sm->cs = 677; goto f115;
	tr831:  sm->cs = 677; goto f116;
	tr835:  sm->cs = 677; goto f117;
	tr837:  sm->cs = 677; goto f118;
	tr840:  sm->cs = 677; goto f119;
	tr844:  sm->cs = 677; goto f120;
	tr846:  sm->cs = 677; goto f121;
	tr851:  sm->cs = 677; goto f122;
	tr853:  sm->cs = 677; goto f123;
	tr856:  sm->cs = 677; goto f124;
	tr858:  sm->cs = 677; goto f125;
	tr860:  sm->cs = 677; goto f126;
	tr863:  sm->cs = 677; goto f127;
	tr867:  sm->cs = 677; goto f128;
	tr870:  sm->cs = 677; goto f129;
	tr872:  sm->cs = 677; goto f130;
	tr875:  sm->cs = 677; goto f131;
	tr878:  sm->cs = 677; goto f132;
	tr893:  sm->cs = 677; goto f133;
	tr747:  sm->cs = 678; goto f93;
	tr139:  sm->cs = 679; goto f20;
	tr773:  sm->cs = 680; goto _again;
	tr143:  sm->cs = 680; goto f3;
	tr144:  sm->cs = 681; goto f3;
	tr748:  sm->cs = 682; goto _again;
	tr749:  sm->cs = 683; goto f94;
	tr155:  sm->cs = 684; goto f23;
	tr750:  sm->cs = 685; goto f79;
	tr193:  sm->cs = 686; goto f26;
	tr263:  sm->cs = 686; goto f41;
	tr751:  sm->cs = 687; goto f94;
	tr321:  sm->cs = 688; goto f48;
	tr797:  sm->cs = 688; goto f104;
	tr793:  sm->cs = 689; goto f101;
	tr752:  sm->cs = 690; goto f79;
	tr802:  sm->cs = 691; goto _again;
	tr329:  sm->cs = 691; goto f9;
	tr804:  sm->cs = 692; goto _again;
	tr336:  sm->cs = 692; goto f9;
	tr806:  sm->cs = 693; goto _again;
	tr344:  sm->cs = 693; goto f9;
	tr808:  sm->cs = 694; goto _again;
	tr353:  sm->cs = 694; goto f9;
	tr753:  sm->cs = 695; goto f79;
	tr812:  sm->cs = 696; goto _again;
	tr357:  sm->cs = 696; goto f9;
	tr814:  sm->cs = 697; goto _again;
	tr361:  sm->cs = 697; goto f9;
	tr754:  sm->cs = 698; goto f79;
	tr817:  sm->cs = 699; goto _again;
	tr369:  sm->cs = 699; goto f9;
	tr755:  sm->cs = 700; goto f79;
	tr820:  sm->cs = 701; goto _again;
	tr380:  sm->cs = 701; goto f9;
	tr756:  sm->cs = 702; goto f79;
	tr826:  sm->cs = 703; goto _again;
	tr389:  sm->cs = 703; goto f9;
	tr828:  sm->cs = 704; goto _again;
	tr398:  sm->cs = 704; goto f9;
	tr830:  sm->cs = 705; goto _again;
	tr403:  sm->cs = 705; goto f9;
	tr832:  sm->cs = 706; goto _again;
	tr409:  sm->cs = 706; goto f9;
	tr757:  sm->cs = 707; goto f79;
	tr836:  sm->cs = 708; goto _again;
	tr421:  sm->cs = 708; goto f9;
	tr838:  sm->cs = 709; goto _again;
	tr427:  sm->cs = 709; goto f9;
	tr758:  sm->cs = 710; goto f79;
	tr841:  sm->cs = 711; goto _again;
	tr438:  sm->cs = 711; goto f9;
	tr759:  sm->cs = 712; goto f79;
	tr845:  sm->cs = 713; goto _again;
	tr444:  sm->cs = 713; goto f9;
	tr847:  sm->cs = 714; goto _again;
	tr449:  sm->cs = 714; goto f9;
	tr760:  sm->cs = 715; goto f79;
	tr852:  sm->cs = 716; goto _again;
	tr455:  sm->cs = 716; goto f9;
	tr461:  sm->cs = 717; goto f49;
	tr855:  sm->cs = 717; goto f79;
	tr857:  sm->cs = 718; goto _again;
	tr464:  sm->cs = 718; goto f3;
	tr859:  sm->cs = 719; goto _again;
	tr470:  sm->cs = 719; goto f9;
	tr861:  sm->cs = 720; goto _again;
	tr474:  sm->cs = 720; goto f9;
	tr761:  sm->cs = 721; goto f79;
	tr864:  sm->cs = 722; goto _again;
	tr480:  sm->cs = 722; goto f9;
	tr762:  sm->cs = 723; goto f79;
	tr486:  sm->cs = 724; goto f49;
	tr869:  sm->cs = 724; goto f79;
	tr871:  sm->cs = 725; goto _again;
	tr489:  sm->cs = 725; goto f3;
	tr873:  sm->cs = 726; goto _again;
	tr497:  sm->cs = 726; goto f9;
	tr763:  sm->cs = 727; goto f79;
	tr876:  sm->cs = 728; goto _again;
	tr502:  sm->cs = 728; goto f9;
	tr764:  sm->cs = 729; goto f79;
	tr879:  sm->cs = 730; goto _again;
	tr507:  sm->cs = 730; goto f9;
	tr765:  sm->cs = 731; goto f79;
	tr766:  sm->cs = 732; goto f94;
	tr598:  sm->cs = 733; goto f56;
	tr767:  sm->cs = 734; goto f79;
	tr603:  sm->cs = 735; goto f58;
	tr608:  sm->cs = 735; goto f59;
	tr895:  sm->cs = 735; goto f134;
	tr898:  sm->cs = 735; goto f135;
	tr896:  sm->cs = 736; goto f79;
	tr897:  sm->cs = 737; goto f79;
	tr613:  sm->cs = 738; goto f60;
	tr621:  sm->cs = 738; goto f61;
	tr901:  sm->cs = 738; goto f136;
	tr904:  sm->cs = 738; goto f137;
	tr902:  sm->cs = 739; goto f79;
	tr903:  sm->cs = 740; goto f79;
	tr629:  sm->cs = 741; goto f62;
	tr638:  sm->cs = 741; goto f63;
	tr642:  sm->cs = 741; goto f64;
	tr646:  sm->cs = 741; goto f65;
	tr647:  sm->cs = 741; goto f66;
	tr655:  sm->cs = 741; goto f67;
	tr656:  sm->cs = 741; goto f68;
	tr657:  sm->cs = 741; goto f69;
	tr661:  sm->cs = 741; goto f70;
	tr662:  sm->cs = 741; goto f71;
	tr907:  sm->cs = 741; goto f138;
	tr910:  sm->cs = 741; goto f139;
	tr908:  sm->cs = 742; goto f79;
	tr909:  sm->cs = 743; goto f79;
	tr687:  sm->cs = 744; goto f72;
	tr689:  sm->cs = 744; goto f74;
	tr915:  sm->cs = 744; goto f140;
	tr920:  sm->cs = 744; goto f142;
	tr921:  sm->cs = 744; goto f143;
	tr688:  sm->cs = 745; goto f73;
	tr916:  sm->cs = 745; goto f141;
	tr917:  sm->cs = 746; goto _again;
	tr918:  sm->cs = 747; goto f49;
	tr922:  sm->cs = 748; goto _again;
	tr690:  sm->cs = 748; goto f3;
	tr691:  sm->cs = 749; goto f3;

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
f79:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
	goto _again;
f15:
#line 169 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{ dstack_open_inline(sm,  INLINE_B, "<strong>"); }}
	goto _again;
f11:
#line 170 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{ dstack_close_inline(sm, INLINE_B, "</strong>"); }}
	goto _again;
f16:
#line 171 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{ dstack_open_inline(sm,  INLINE_I, "<em>"); }}
	goto _again;
f12:
#line 172 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{ dstack_close_inline(sm, INLINE_I, "</em>"); }}
	goto _again;
f17:
#line 173 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{ dstack_open_inline(sm,  INLINE_S, "<s>"); }}
	goto _again;
f13:
#line 174 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{ dstack_close_inline(sm, INLINE_S, "</s>"); }}
	goto _again;
f18:
#line 175 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{ dstack_open_inline(sm,  INLINE_U, "<u>"); }}
	goto _again;
f14:
#line 176 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{ dstack_close_inline(sm, INLINE_U, "</u>"); }}
	goto _again;
f90:
#line 177 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{ append_c_html_escaped(sm, (*( sm->p))); }}
	goto _again;
f91:
#line 177 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{ append_c_html_escaped(sm, (*( sm->p))); }}
	goto _again;
f10:
#line 177 "ext/dtext/dtext.rl"
	{{( sm->p) = ((( sm->te)))-1;}{ append_c_html_escaped(sm, (*( sm->p))); }}
	goto _again;
f57:
#line 212 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    append(sm, "<a class=\"dtext-link dtext-post-search-link\" href=\"/posts?tags=");
    append_segment_uri_escaped(sm, sm->a1, sm->a2 - 1);
    append(sm, "\">");
    append_segment_html_escaped(sm, sm->a1, sm->a2 - 1);
    append(sm, "</a>");
  }}
	goto _again;
f53:
#line 220 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    append_wiki_link(sm, sm->a1, sm->a2 - sm->a1, sm->a1, sm->a2 - sm->a1);
  }}
	goto _again;
f54:
#line 224 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    append_wiki_link(sm, sm->a1, sm->a2 - sm->a1, sm->b1, sm->b2 - sm->b1);
  }}
	goto _again;
f24:
#line 242 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    if (!append_named_url(sm, sm->b1, sm->b2, sm->a1, sm->a2)) {
      {( sm->p)++; goto _out; }
    }
  }}
	goto _again;
f46:
#line 248 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    if (!append_named_url(sm, sm->a1, sm->a2 - 1, sm->b1, sm->b2)) {
      {( sm->p)++; goto _out; }
    }
  }}
	goto _again;
f47:
#line 266 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    append_url(sm, sm->ts + 1, sm->te - 2, sm->ts + 1, sm->te - 2);
  }}
	goto _again;
f35:
#line 328 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{ dstack_open_inline(sm,  INLINE_B, "<strong>"); }}
	goto _again;
f25:
#line 329 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{ dstack_close_inline(sm, INLINE_B, "</strong>"); }}
	goto _again;
f38:
#line 330 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{ dstack_open_inline(sm,  INLINE_I, "<em>"); }}
	goto _again;
f27:
#line 331 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{ dstack_close_inline(sm, INLINE_I, "</em>"); }}
	goto _again;
f42:
#line 332 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{ dstack_open_inline(sm,  INLINE_S, "<s>"); }}
	goto _again;
f29:
#line 333 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{ dstack_close_inline(sm, INLINE_S, "</s>"); }}
	goto _again;
f45:
#line 334 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{ dstack_open_inline(sm,  INLINE_U, "<u>"); }}
	goto _again;
f33:
#line 335 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{ dstack_close_inline(sm, INLINE_U, "</u>"); }}
	goto _again;
f44:
#line 337 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_open_inline(sm, INLINE_TN, "<span class=\"tn\">");
  }}
	goto _again;
f52:
#line 341 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_close_before_block(sm);

    if (dstack_check(sm, INLINE_TN)) {
      dstack_close_inline(sm, INLINE_TN, "</span>");
    } else if (dstack_close_block(sm, BLOCK_TN, "</p>")) {
      { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)];goto _again;}
    }
  }}
	goto _again;
f37:
#line 351 "ext/dtext/dtext.rl"
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
{( ((int *)sm->stack->data))[( sm->top)++] =  sm->cs;  sm->cs = 735;goto _again;}}
  }}
	goto _again;
f43:
#line 356 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_open_inline(sm, INLINE_SPOILER, "<span class=\"spoiler\">");
  }}
	goto _again;
f30:
#line 360 "ext/dtext/dtext.rl"
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
f40:
#line 371 "ext/dtext/dtext.rl"
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
{( ((int *)sm->stack->data))[( sm->top)++] =  sm->cs;  sm->cs = 738;goto _again;}}
  }}
	goto _again;
f36:
#line 379 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    g_debug("inline [quote]");
    dstack_close_before_block(sm);
    {( sm->p) = (( sm->ts))-1;}
    { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)];goto _again;}
  }}
	goto _again;
f39:
#line 402 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    g_debug("inline [expand]");
    dstack_rewind(sm);
    {( sm->p) = (((sm->p - 7)))-1;}
    { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)];goto _again;}
  }}
	goto _again;
f28:
#line 409 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_close_before_block(sm);

    if (dstack_close_block(sm, BLOCK_EXPAND, "</div></div>")) {
      { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)];goto _again;}
    }
  }}
	goto _again;
f32:
#line 417 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    if (dstack_close_block(sm, BLOCK_TH, "</th>")) {
      { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)];goto _again;}
    }
  }}
	goto _again;
f31:
#line 423 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    if (dstack_close_block(sm, BLOCK_TD, "</td>")) {
      { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)];goto _again;}
    }
  }}
	goto _again;
f92:
#line 457 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    g_debug("inline char: %c", (*( sm->p)));
    append_c_html_escaped(sm, (*( sm->p)));
  }}
	goto _again;
f100:
#line 228 "ext/dtext/dtext.rl"
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
f133:
#line 254 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    const char* match_end = sm->te - 1;
    const char* url_start = sm->ts;
    const char* url_end = find_boundary_c(match_end);

    append_url(sm, url_start, url_end, url_start, url_end);

    if (url_end < match_end) {
      append_segment_html_escaped(sm, url_end + 1, match_end);
    }
  }}
	goto _again;
f96:
#line 429 "ext/dtext/dtext.rl"
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
f95:
#line 441 "ext/dtext/dtext.rl"
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
f98:
#line 453 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append_c(sm, ' ');
  }}
	goto _again;
f99:
#line 457 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    g_debug("inline char: %c", (*( sm->p)));
    append_c_html_escaped(sm, (*( sm->p)));
  }}
	goto _again;
f51:
#line 186 "ext/dtext/dtext.rl"
	{{( sm->p) = ((( sm->te)))-1;}{ append_id_link(sm, "topic", "forum-topic", "/forum_topics/"); }}
	goto _again;
f50:
#line 205 "ext/dtext/dtext.rl"
	{{( sm->p) = ((( sm->te)))-1;}{ append_id_link(sm, "pixiv", "pixiv", "https://www.pixiv.net/artworks/"); }}
	goto _again;
f21:
#line 441 "ext/dtext/dtext.rl"
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
#line 457 "ext/dtext/dtext.rl"
	{{( sm->p) = ((( sm->te)))-1;}{
    g_debug("inline char: %c", (*( sm->p)));
    append_c_html_escaped(sm, (*( sm->p)));
  }}
	goto _again;
f19:
#line 1 "NONE"
	{	switch( ( sm->act) ) {
	case 41:
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
	case 44:
	{{( sm->p) = ((( sm->te)))-1;}
    const char* match_end = sm->te - 1;
    const char* url_start = sm->ts;
    const char* url_end = find_boundary_c(match_end);

    append_url(sm, url_start, url_end, url_start, url_end);

    if (url_end < match_end) {
      append_segment_html_escaped(sm, url_end + 1, match_end);
    }
  }
	break;
	case 46:
	{{( sm->p) = ((( sm->te)))-1;}
    append_segment_html_escaped(sm, sm->ts, sm->te - 1);
  }
	break;
	case 47:
	{{( sm->p) = ((( sm->te)))-1;}
    if (!sm->f_mentions || (sm->a1 > sm->pb && sm->a1 - 1 > sm->pb && sm->a1[-2] != ' ' && sm->a1[-2] != '\r' && sm->a1[-2] != '\n')) {
      // handle emails
      append_c(sm, '@');
      {( sm->p) = (( sm->a1))-1;}
    } else {
      const char* match_end = sm->a2 - 1;
      const char* name_start = sm->a1;
      const char* name_end = find_boundary_c(match_end);

      append(sm, "<a href=\"/users?name=");
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
	case 64:
	{{( sm->p) = ((( sm->te)))-1;}
    g_debug("inline [quote]");
    dstack_close_before_block(sm);
    {( sm->p) = (( sm->ts))-1;}
    { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)];goto _again;}
  }
	break;
	case 65:
	{{( sm->p) = ((( sm->te)))-1;}
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
  }
	break;
	case 70:
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
	case 71:
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
	case 73:
	{{( sm->p) = ((( sm->te)))-1;}
    g_debug("inline char: %c", (*( sm->p)));
    append_c_html_escaped(sm, (*( sm->p)));
  }
	break;
	}
	}
	goto _again;
f59:
#line 464 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_rewind(sm);
    { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)];goto _again;}
  }}
	goto _again;
f134:
#line 469 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    append_c_html_escaped(sm, (*( sm->p)));
  }}
	goto _again;
f135:
#line 469 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append_c_html_escaped(sm, (*( sm->p)));
  }}
	goto _again;
f58:
#line 469 "ext/dtext/dtext.rl"
	{{( sm->p) = ((( sm->te)))-1;}{
    append_c_html_escaped(sm, (*( sm->p)));
  }}
	goto _again;
f61:
#line 475 "ext/dtext/dtext.rl"
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
f136:
#line 492 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    append_c_html_escaped(sm, (*( sm->p)));
  }}
	goto _again;
f137:
#line 492 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append_c_html_escaped(sm, (*( sm->p)));
  }}
	goto _again;
f60:
#line 492 "ext/dtext/dtext.rl"
	{{( sm->p) = ((( sm->te)))-1;}{
    append_c_html_escaped(sm, (*( sm->p)));
  }}
	goto _again;
f70:
#line 498 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_open_block(sm, BLOCK_THEAD, "<thead>");
  }}
	goto _again;
f65:
#line 502 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_close_block(sm, BLOCK_THEAD, "</thead>");
  }}
	goto _again;
f67:
#line 506 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_open_block(sm, BLOCK_TBODY, "<tbody>");
  }}
	goto _again;
f64:
#line 510 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_close_block(sm, BLOCK_TBODY, "</tbody>");
  }}
	goto _again;
f69:
#line 514 "ext/dtext/dtext.rl"
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
{( ((int *)sm->stack->data))[( sm->top)++] =  sm->cs;  sm->cs = 677;goto _again;}}
  }}
	goto _again;
f71:
#line 519 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_open_block(sm, BLOCK_TR, "<tr>");
  }}
	goto _again;
f66:
#line 523 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_close_block(sm, BLOCK_TR, "</tr>");
  }}
	goto _again;
f68:
#line 527 "ext/dtext/dtext.rl"
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
{( ((int *)sm->stack->data))[( sm->top)++] =  sm->cs;  sm->cs = 677;goto _again;}}
  }}
	goto _again;
f63:
#line 532 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    if (dstack_close_block(sm, BLOCK_TABLE, "</table>")) {
      { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)];goto _again;}
    }
  }}
	goto _again;
f138:
#line 538 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;}
	goto _again;
f139:
#line 538 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;}
	goto _again;
f62:
#line 538 "ext/dtext/dtext.rl"
	{{( sm->p) = ((( sm->te)))-1;}}
	goto _again;
f140:
#line 583 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_rewind(sm);
    ( sm->p)--;
    { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)];goto _again;}
  }}
	goto _again;
f142:
#line 583 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    dstack_rewind(sm);
    ( sm->p)--;
    { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)];goto _again;}
  }}
	goto _again;
f74:
#line 583 "ext/dtext/dtext.rl"
	{{( sm->p) = ((( sm->te)))-1;}{
    dstack_rewind(sm);
    ( sm->p)--;
    { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)];goto _again;}
  }}
	goto _again;
f72:
#line 1 "NONE"
	{	switch( ( sm->act) ) {
	case 89:
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
#line 701 "ext/dtext/dtext.rl"
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
#line 743 "ext/dtext/dtext.rl"
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
{( ((int *)sm->stack->data))[( sm->top)++] =  sm->cs;  sm->cs = 741;goto _again;}}
  }}
	goto _again;
f7:
#line 749 "ext/dtext/dtext.rl"
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
{( ((int *)sm->stack->data))[( sm->top)++] =  sm->cs;  sm->cs = 677;goto _again;}}
  }}
	goto _again;
f77:
#line 781 "ext/dtext/dtext.rl"
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
{( ((int *)sm->stack->data))[( sm->top)++] =  sm->cs;  sm->cs = 677;goto _again;}}
  }}
	goto _again;
f87:
#line 591 "ext/dtext/dtext.rl"
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
{( ((int *)sm->stack->data))[( sm->top)++] =  sm->cs;  sm->cs = 677;goto _again;}}
  }}
	goto _again;
f88:
#line 648 "ext/dtext/dtext.rl"
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
{( ((int *)sm->stack->data))[( sm->top)++] =  sm->cs;  sm->cs = 677;goto _again;}}
  }}
	goto _again;
f82:
#line 691 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    dstack_close_before_block(sm);
    dstack_open_block(sm, BLOCK_QUOTE, "<blockquote>");
  }}
	goto _again;
f86:
#line 696 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    dstack_close_before_block(sm);
    dstack_open_block(sm, BLOCK_SPOILER, "<div class=\"spoiler\">");
  }}
	goto _again;
f83:
#line 710 "ext/dtext/dtext.rl"
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
{( ((int *)sm->stack->data))[( sm->top)++] =  sm->cs;  sm->cs = 735;goto _again;}}
  }}
	goto _again;
f84:
#line 716 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    dstack_close_before_block(sm);
    const char* html = "<div class=\"expandable\"><div class=\"expandable-header\">"
                       "<input type=\"button\" value=\"Show\" class=\"expandable-button\"/></div>"
                       "<div class=\"expandable-content\">";
    dstack_open_block(sm, BLOCK_EXPAND, html);
  }}
	goto _again;
f89:
#line 724 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    g_debug("block [expand=]");
    dstack_close_before_block(sm);
    dstack_push(sm, BLOCK_EXPAND);
    append_block(sm, "<div class=\"expandable\"><div class=\"expandable-header\">");
    append(sm, "<span>");
    append_segment_html_escaped(sm, sm->a1, sm->a2 - 1);
    append(sm, "</span>");
    append_block(sm, "<input type=\"button\" value=\"Show\" class=\"expandable-button\"/></div>");
    append_block(sm, "<div class=\"expandable-content\">");
  }}
	goto _again;
f85:
#line 736 "ext/dtext/dtext.rl"
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
{( ((int *)sm->stack->data))[( sm->top)++] =  sm->cs;  sm->cs = 738;goto _again;}}
  }}
	goto _again;
f80:
#line 781 "ext/dtext/dtext.rl"
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
{( ((int *)sm->stack->data))[( sm->top)++] =  sm->cs;  sm->cs = 677;goto _again;}}
  }}
	goto _again;
f2:
#line 781 "ext/dtext/dtext.rl"
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
{( ((int *)sm->stack->data))[( sm->top)++] =  sm->cs;  sm->cs = 677;goto _again;}}
  }}
	goto _again;
f0:
#line 1 "NONE"
	{	switch( ( sm->act) ) {
	case 104:
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
	case 105:
	{{( sm->p) = ((( sm->te)))-1;}
    g_debug("block newline");
  }
	break;
	}
	}
	goto _again;
f34:
#line 76 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
#line 298 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    if (sm->f_mentions) {
      append(sm, "<a href=\"/users?name=");
      append_segment_uri_escaped(sm, sm->a1, sm->a2 - 1);
      append(sm, "\">");
      append_c(sm, '@');
      append_segment_html_escaped(sm, sm->a1, sm->a2 - 1);
      append(sm, "</a>");
    }
  }}
	goto _again;
f126:
#line 76 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
#line 181 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{ append_id_link(sm, "post", "post", "/posts/"); }}
	goto _again;
f106:
#line 76 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
#line 182 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{ append_id_link(sm, "appeal", "post-appeal", "/post_appeals/"); }}
	goto _again;
f115:
#line 76 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
#line 183 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{ append_id_link(sm, "flag", "post-flag", "/post_flags/"); }}
	goto _again;
f121:
#line 76 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
#line 184 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{ append_id_link(sm, "note", "note", "/notes/"); }}
	goto _again;
f116:
#line 76 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
#line 185 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{ append_id_link(sm, "forum", "forum-post", "/forum_posts/"); }}
	goto _again;
f128:
#line 76 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
#line 186 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{ append_id_link(sm, "topic", "forum-topic", "/forum_topics/"); }}
	goto _again;
f111:
#line 76 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
#line 187 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{ append_id_link(sm, "comment", "comment", "/comments/"); }}
	goto _again;
f125:
#line 76 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
#line 188 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{ append_id_link(sm, "pool", "pool", "/pools/"); }}
	goto _again;
f131:
#line 76 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
#line 189 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{ append_id_link(sm, "user", "user", "/users/"); }}
	goto _again;
f107:
#line 76 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
#line 190 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{ append_id_link(sm, "artist", "artist", "/artists/"); }}
	goto _again;
f109:
#line 76 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
#line 191 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{ append_id_link(sm, "ban", "ban", "/bans/"); }}
	goto _again;
f110:
#line 76 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
#line 192 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{ append_id_link(sm, "BUR", "bulk-update-request", "/bulk_update_requests/"); }}
	goto _again;
f105:
#line 76 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
#line 193 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{ append_id_link(sm, "alias", "tag-alias", "/tag_aliases/"); }}
	goto _again;
f117:
#line 76 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
#line 194 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{ append_id_link(sm, "implication", "tag-implication", "/tag_implications/"); }}
	goto _again;
f113:
#line 76 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
#line 195 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{ append_id_link(sm, "favgroup", "favorite-group", "/favorite_groups/"); }}
	goto _again;
f119:
#line 76 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
#line 196 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{ append_id_link(sm, "mod action", "mod-action", "/mod_actions/"); }}
	goto _again;
f114:
#line 76 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
#line 197 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{ append_id_link(sm, "feedback", "user-feedback", "/user_feedbacks/"); }}
	goto _again;
f132:
#line 76 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
#line 198 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{ append_id_link(sm, "wiki", "wiki-page", "/wiki_pages/"); }}
	goto _again;
f118:
#line 76 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
#line 200 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{ append_id_link(sm, "issue", "github", "https://github.com/r888888888/danbooru/issues/"); }}
	goto _again;
f108:
#line 76 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
#line 201 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{ append_id_link(sm, "artstation", "artstation", "https://www.artstation.com/artwork/"); }}
	goto _again;
f112:
#line 76 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
#line 202 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{ append_id_link(sm, "deviantart", "deviantart", "https://www.deviantart.com/deviation/"); }}
	goto _again;
f120:
#line 76 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
#line 203 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{ append_id_link(sm, "nijie", "nijie", "https://nijie.info/view.php?id="); }}
	goto _again;
f122:
#line 76 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
#line 204 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{ append_id_link(sm, "pawoo", "pawoo", "https://pawoo.net/web/statuses/"); }}
	goto _again;
f123:
#line 76 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
#line 205 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{ append_id_link(sm, "pixiv", "pixiv", "https://www.pixiv.net/artworks/"); }}
	goto _again;
f127:
#line 76 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
#line 206 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{ append_id_link(sm, "seiga", "seiga", "https://seiga.nicovideo.jp/seiga/im"); }}
	goto _again;
f130:
#line 76 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
#line 207 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{ append_id_link(sm, "twitter", "twitter", "https://twitter.com/i/web/status/"); }}
	goto _again;
f103:
#line 76 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
#line 275 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    if (!sm->f_mentions || (sm->a1 > sm->pb && sm->a1 - 1 > sm->pb && sm->a1[-2] != ' ' && sm->a1[-2] != '\r' && sm->a1[-2] != '\n')) {
      // handle emails
      append_c(sm, '@');
      {( sm->p) = (( sm->a1))-1;}
    } else {
      const char* match_end = sm->a2 - 1;
      const char* name_start = sm->a1;
      const char* name_end = find_boundary_c(match_end);

      append(sm, "<a href=\"/users?name=");
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
f102:
#line 76 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
#line 1 "NONE"
	{	switch( ( sm->act) ) {
	case 41:
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
	case 44:
	{{( sm->p) = ((( sm->te)))-1;}
    const char* match_end = sm->te - 1;
    const char* url_start = sm->ts;
    const char* url_end = find_boundary_c(match_end);

    append_url(sm, url_start, url_end, url_start, url_end);

    if (url_end < match_end) {
      append_segment_html_escaped(sm, url_end + 1, match_end);
    }
  }
	break;
	case 46:
	{{( sm->p) = ((( sm->te)))-1;}
    append_segment_html_escaped(sm, sm->ts, sm->te - 1);
  }
	break;
	case 47:
	{{( sm->p) = ((( sm->te)))-1;}
    if (!sm->f_mentions || (sm->a1 > sm->pb && sm->a1 - 1 > sm->pb && sm->a1[-2] != ' ' && sm->a1[-2] != '\r' && sm->a1[-2] != '\n')) {
      // handle emails
      append_c(sm, '@');
      {( sm->p) = (( sm->a1))-1;}
    } else {
      const char* match_end = sm->a2 - 1;
      const char* name_start = sm->a1;
      const char* name_end = find_boundary_c(match_end);

      append(sm, "<a href=\"/users?name=");
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
	case 64:
	{{( sm->p) = ((( sm->te)))-1;}
    g_debug("inline [quote]");
    dstack_close_before_block(sm);
    {( sm->p) = (( sm->ts))-1;}
    { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)];goto _again;}
  }
	break;
	case 65:
	{{( sm->p) = ((( sm->te)))-1;}
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
  }
	break;
	case 70:
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
	case 71:
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
	case 73:
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
#line 248 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    if (!append_named_url(sm, sm->a1, sm->a2 - 1, sm->b1, sm->b2)) {
      {( sm->p)++; goto _out; }
    }
  }}
	goto _again;
f129:
#line 84 "ext/dtext/dtext.rl"
	{
  sm->b2 = sm->p;
}
#line 209 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{ append_paged_link(sm, "topic #", "<a class=\"dtext-link dtext-id-link dtext-forum-topic-id-link\" href=\"/forum_topics/", "?page="); }}
	goto _again;
f124:
#line 84 "ext/dtext/dtext.rl"
	{
  sm->b2 = sm->p;
}
#line 210 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{ append_paged_link(sm, "pixiv #", "<a rel=\"external nofollow noreferrer\" class=\"dtext-link dtext-id-link dtext-pixiv-id-link\" href=\"https://www.pixiv.net/artworks/", "#"); }}
	goto _again;
f97:
#line 84 "ext/dtext/dtext.rl"
	{
  sm->b2 = sm->p;
}
#line 309 "ext/dtext/dtext.rl"
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
     sm->cs = 744;
  }}
	goto _again;
f143:
#line 84 "ext/dtext/dtext.rl"
	{
  sm->b2 = sm->p;
}
#line 542 "ext/dtext/dtext.rl"
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
{( ((int *)sm->stack->data))[( sm->top)++] =  sm->cs;  sm->cs = 677;goto _again;}}
  }}
	goto _again;
f81:
#line 84 "ext/dtext/dtext.rl"
	{
  sm->b2 = sm->p;
}
#line 754 "ext/dtext/dtext.rl"
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
{( ((int *)sm->stack->data))[( sm->top)++] =  sm->cs;  sm->cs = 744;goto _again;}}
  }}
	goto _again;
f49:
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
#line 254 "ext/dtext/dtext.rl"
	{( sm->act) = 44;}
	goto _again;
f104:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 271 "ext/dtext/dtext.rl"
	{( sm->act) = 46;}
	goto _again;
f48:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 275 "ext/dtext/dtext.rl"
	{( sm->act) = 47;}
	goto _again;
f41:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 379 "ext/dtext/dtext.rl"
	{( sm->act) = 64;}
	goto _again;
f26:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 386 "ext/dtext/dtext.rl"
	{( sm->act) = 65;}
	goto _again;
f20:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 429 "ext/dtext/dtext.rl"
	{( sm->act) = 70;}
	goto _again;
f93:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 441 "ext/dtext/dtext.rl"
	{( sm->act) = 71;}
	goto _again;
f94:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 457 "ext/dtext/dtext.rl"
	{( sm->act) = 73;}
	goto _again;
f73:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 575 "ext/dtext/dtext.rl"
	{( sm->act) = 89;}
	goto _again;
f141:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 581 "ext/dtext/dtext.rl"
	{( sm->act) = 90;}
	goto _again;
f1:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 764 "ext/dtext/dtext.rl"
	{( sm->act) = 104;}
	goto _again;
f78:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 777 "ext/dtext/dtext.rl"
	{( sm->act) = 105;}
	goto _again;
f101:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 72 "ext/dtext/dtext.rl"
	{
  sm->a1 = sm->p;
}
#line 275 "ext/dtext/dtext.rl"
	{( sm->act) = 47;}
	goto _again;
f23:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 84 "ext/dtext/dtext.rl"
	{
  sm->b2 = sm->p;
}
#line 228 "ext/dtext/dtext.rl"
	{( sm->act) = 41;}
	goto _again;

_again:
	switch ( _dtext_to_state_actions[ sm->cs] ) {
	case 76:
#line 1 "NONE"
	{( sm->ts) = 0;}
	break;
#line 7584 "ext/dtext/dtext.c"
	}

	if ( ++( sm->p) != ( sm->pe) )
		goto _resume;
	_test_eof: {}
	if ( ( sm->p) == ( sm->eof) )
	{
	switch (  sm->cs ) {
	case 658: goto tr0;
	case 0: goto tr0;
	case 659: goto tr702;
	case 660: goto tr702;
	case 1: goto tr2;
	case 661: goto tr703;
	case 662: goto tr703;
	case 2: goto tr2;
	case 663: goto tr702;
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
	case 664: goto tr712;
	case 22: goto tr2;
	case 23: goto tr2;
	case 24: goto tr2;
	case 25: goto tr2;
	case 665: goto tr713;
	case 26: goto tr2;
	case 27: goto tr2;
	case 28: goto tr2;
	case 29: goto tr2;
	case 30: goto tr2;
	case 31: goto tr2;
	case 666: goto tr714;
	case 32: goto tr2;
	case 33: goto tr2;
	case 34: goto tr2;
	case 35: goto tr2;
	case 36: goto tr2;
	case 37: goto tr2;
	case 38: goto tr2;
	case 667: goto tr715;
	case 39: goto tr2;
	case 40: goto tr2;
	case 41: goto tr2;
	case 42: goto tr2;
	case 43: goto tr2;
	case 44: goto tr2;
	case 45: goto tr2;
	case 668: goto tr716;
	case 46: goto tr2;
	case 47: goto tr2;
	case 48: goto tr2;
	case 49: goto tr2;
	case 50: goto tr2;
	case 51: goto tr2;
	case 52: goto tr2;
	case 669: goto tr702;
	case 53: goto tr2;
	case 54: goto tr2;
	case 55: goto tr2;
	case 670: goto tr718;
	case 671: goto tr720;
	case 672: goto tr702;
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
	case 673: goto tr731;
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
	case 103: goto tr2;
	case 104: goto tr2;
	case 105: goto tr2;
	case 106: goto tr2;
	case 107: goto tr2;
	case 108: goto tr2;
	case 109: goto tr2;
	case 675: goto tr736;
	case 110: goto tr110;
	case 111: goto tr110;
	case 112: goto tr110;
	case 113: goto tr110;
	case 114: goto tr110;
	case 115: goto tr110;
	case 116: goto tr110;
	case 117: goto tr110;
	case 118: goto tr110;
	case 119: goto tr110;
	case 120: goto tr110;
	case 121: goto tr110;
	case 122: goto tr110;
	case 123: goto tr110;
	case 124: goto tr110;
	case 125: goto tr110;
	case 126: goto tr110;
	case 127: goto tr110;
	case 128: goto tr110;
	case 676: goto tr736;
	case 129: goto tr110;
	case 130: goto tr110;
	case 131: goto tr110;
	case 132: goto tr110;
	case 133: goto tr110;
	case 134: goto tr110;
	case 135: goto tr110;
	case 136: goto tr110;
	case 137: goto tr110;
	case 678: goto tr768;
	case 679: goto tr771;
	case 138: goto tr138;
	case 139: goto tr140;
	case 140: goto tr140;
	case 680: goto tr772;
	case 681: goto tr772;
	case 682: goto tr774;
	case 683: goto tr775;
	case 141: goto tr145;
	case 142: goto tr145;
	case 143: goto tr145;
	case 144: goto tr145;
	case 145: goto tr138;
	case 684: goto tr777;
	case 146: goto tr138;
	case 147: goto tr138;
	case 148: goto tr145;
	case 149: goto tr145;
	case 150: goto tr145;
	case 151: goto tr145;
	case 152: goto tr145;
	case 153: goto tr145;
	case 154: goto tr145;
	case 155: goto tr145;
	case 156: goto tr145;
	case 157: goto tr145;
	case 158: goto tr145;
	case 159: goto tr145;
	case 160: goto tr145;
	case 161: goto tr145;
	case 162: goto tr145;
	case 163: goto tr145;
	case 164: goto tr145;
	case 165: goto tr145;
	case 166: goto tr145;
	case 167: goto tr145;
	case 685: goto tr775;
	case 168: goto tr145;
	case 169: goto tr145;
	case 170: goto tr145;
	case 171: goto tr145;
	case 172: goto tr145;
	case 173: goto tr145;
	case 174: goto tr145;
	case 175: goto tr145;
	case 176: goto tr145;
	case 177: goto tr145;
	case 178: goto tr145;
	case 686: goto tr138;
	case 179: goto tr145;
	case 180: goto tr145;
	case 181: goto tr145;
	case 182: goto tr145;
	case 183: goto tr145;
	case 184: goto tr145;
	case 185: goto tr145;
	case 186: goto tr145;
	case 187: goto tr145;
	case 188: goto tr145;
	case 189: goto tr145;
	case 190: goto tr145;
	case 191: goto tr145;
	case 192: goto tr145;
	case 193: goto tr145;
	case 194: goto tr145;
	case 195: goto tr145;
	case 196: goto tr145;
	case 197: goto tr145;
	case 198: goto tr145;
	case 199: goto tr145;
	case 200: goto tr145;
	case 201: goto tr145;
	case 202: goto tr145;
	case 203: goto tr145;
	case 204: goto tr145;
	case 205: goto tr145;
	case 206: goto tr145;
	case 207: goto tr145;
	case 208: goto tr145;
	case 209: goto tr145;
	case 210: goto tr145;
	case 211: goto tr145;
	case 212: goto tr145;
	case 213: goto tr145;
	case 214: goto tr145;
	case 215: goto tr145;
	case 216: goto tr145;
	case 217: goto tr145;
	case 218: goto tr145;
	case 219: goto tr145;
	case 220: goto tr145;
	case 221: goto tr145;
	case 222: goto tr145;
	case 223: goto tr145;
	case 224: goto tr145;
	case 225: goto tr145;
	case 226: goto tr145;
	case 227: goto tr145;
	case 228: goto tr145;
	case 229: goto tr145;
	case 230: goto tr145;
	case 231: goto tr145;
	case 232: goto tr145;
	case 233: goto tr145;
	case 234: goto tr145;
	case 235: goto tr145;
	case 236: goto tr145;
	case 237: goto tr145;
	case 238: goto tr145;
	case 239: goto tr145;
	case 240: goto tr145;
	case 241: goto tr145;
	case 242: goto tr145;
	case 243: goto tr145;
	case 244: goto tr145;
	case 245: goto tr145;
	case 246: goto tr145;
	case 247: goto tr145;
	case 248: goto tr145;
	case 249: goto tr145;
	case 250: goto tr145;
	case 251: goto tr145;
	case 252: goto tr145;
	case 253: goto tr145;
	case 254: goto tr145;
	case 255: goto tr145;
	case 256: goto tr145;
	case 257: goto tr145;
	case 258: goto tr145;
	case 259: goto tr145;
	case 260: goto tr145;
	case 261: goto tr145;
	case 262: goto tr145;
	case 263: goto tr145;
	case 264: goto tr145;
	case 265: goto tr145;
	case 266: goto tr145;
	case 267: goto tr145;
	case 268: goto tr145;
	case 269: goto tr145;
	case 270: goto tr145;
	case 271: goto tr145;
	case 272: goto tr145;
	case 273: goto tr145;
	case 274: goto tr145;
	case 275: goto tr145;
	case 276: goto tr145;
	case 277: goto tr145;
	case 278: goto tr145;
	case 279: goto tr145;
	case 280: goto tr145;
	case 281: goto tr145;
	case 282: goto tr145;
	case 283: goto tr145;
	case 284: goto tr145;
	case 285: goto tr145;
	case 286: goto tr145;
	case 287: goto tr145;
	case 288: goto tr145;
	case 289: goto tr145;
	case 290: goto tr145;
	case 291: goto tr145;
	case 292: goto tr145;
	case 293: goto tr145;
	case 294: goto tr145;
	case 687: goto tr775;
	case 295: goto tr138;
	case 688: goto tr794;
	case 296: goto tr138;
	case 297: goto tr138;
	case 689: goto tr796;
	case 690: goto tr775;
	case 298: goto tr145;
	case 299: goto tr145;
	case 300: goto tr145;
	case 301: goto tr145;
	case 302: goto tr145;
	case 303: goto tr145;
	case 691: goto tr801;
	case 304: goto tr145;
	case 305: goto tr145;
	case 306: goto tr145;
	case 307: goto tr145;
	case 308: goto tr145;
	case 309: goto tr145;
	case 310: goto tr145;
	case 692: goto tr803;
	case 311: goto tr145;
	case 312: goto tr145;
	case 313: goto tr145;
	case 314: goto tr145;
	case 315: goto tr145;
	case 316: goto tr145;
	case 317: goto tr145;
	case 693: goto tr805;
	case 318: goto tr145;
	case 319: goto tr145;
	case 320: goto tr145;
	case 321: goto tr145;
	case 322: goto tr145;
	case 323: goto tr145;
	case 324: goto tr145;
	case 325: goto tr145;
	case 326: goto tr145;
	case 694: goto tr807;
	case 695: goto tr775;
	case 327: goto tr145;
	case 328: goto tr145;
	case 329: goto tr145;
	case 330: goto tr145;
	case 696: goto tr811;
	case 331: goto tr145;
	case 332: goto tr145;
	case 333: goto tr145;
	case 334: goto tr145;
	case 697: goto tr813;
	case 698: goto tr775;
	case 335: goto tr145;
	case 336: goto tr145;
	case 337: goto tr145;
	case 338: goto tr145;
	case 339: goto tr145;
	case 340: goto tr145;
	case 341: goto tr145;
	case 342: goto tr145;
	case 699: goto tr816;
	case 700: goto tr775;
	case 343: goto tr145;
	case 344: goto tr145;
	case 345: goto tr145;
	case 346: goto tr145;
	case 347: goto tr145;
	case 348: goto tr145;
	case 349: goto tr145;
	case 350: goto tr145;
	case 351: goto tr145;
	case 352: goto tr145;
	case 353: goto tr145;
	case 701: goto tr819;
	case 702: goto tr775;
	case 354: goto tr145;
	case 355: goto tr145;
	case 356: goto tr145;
	case 357: goto tr145;
	case 358: goto tr145;
	case 359: goto tr145;
	case 360: goto tr145;
	case 361: goto tr145;
	case 362: goto tr145;
	case 703: goto tr825;
	case 363: goto tr145;
	case 364: goto tr145;
	case 365: goto tr145;
	case 366: goto tr145;
	case 367: goto tr145;
	case 368: goto tr145;
	case 369: goto tr145;
	case 370: goto tr145;
	case 371: goto tr145;
	case 704: goto tr827;
	case 372: goto tr145;
	case 373: goto tr145;
	case 374: goto tr145;
	case 375: goto tr145;
	case 376: goto tr145;
	case 705: goto tr829;
	case 377: goto tr145;
	case 378: goto tr145;
	case 379: goto tr145;
	case 380: goto tr145;
	case 381: goto tr145;
	case 382: goto tr145;
	case 706: goto tr831;
	case 707: goto tr775;
	case 383: goto tr145;
	case 384: goto tr145;
	case 385: goto tr145;
	case 386: goto tr145;
	case 387: goto tr145;
	case 388: goto tr145;
	case 389: goto tr145;
	case 390: goto tr145;
	case 391: goto tr145;
	case 392: goto tr145;
	case 393: goto tr145;
	case 394: goto tr145;
	case 708: goto tr835;
	case 395: goto tr145;
	case 396: goto tr145;
	case 397: goto tr145;
	case 398: goto tr145;
	case 399: goto tr145;
	case 400: goto tr145;
	case 709: goto tr837;
	case 710: goto tr775;
	case 401: goto tr145;
	case 402: goto tr145;
	case 403: goto tr145;
	case 404: goto tr145;
	case 405: goto tr145;
	case 406: goto tr145;
	case 407: goto tr145;
	case 408: goto tr145;
	case 409: goto tr145;
	case 410: goto tr145;
	case 411: goto tr145;
	case 711: goto tr840;
	case 712: goto tr775;
	case 412: goto tr145;
	case 413: goto tr145;
	case 414: goto tr145;
	case 415: goto tr145;
	case 416: goto tr145;
	case 417: goto tr145;
	case 713: goto tr844;
	case 418: goto tr145;
	case 419: goto tr145;
	case 420: goto tr145;
	case 421: goto tr145;
	case 422: goto tr145;
	case 714: goto tr846;
	case 715: goto tr775;
	case 423: goto tr145;
	case 424: goto tr145;
	case 425: goto tr145;
	case 426: goto tr145;
	case 427: goto tr145;
	case 428: goto tr145;
	case 716: goto tr851;
	case 429: goto tr145;
	case 430: goto tr145;
	case 431: goto tr145;
	case 432: goto tr145;
	case 433: goto tr145;
	case 434: goto tr145;
	case 717: goto tr853;
	case 435: goto tr462;
	case 436: goto tr462;
	case 718: goto tr856;
	case 437: goto tr145;
	case 438: goto tr145;
	case 439: goto tr145;
	case 440: goto tr145;
	case 441: goto tr145;
	case 719: goto tr858;
	case 442: goto tr145;
	case 443: goto tr145;
	case 444: goto tr145;
	case 445: goto tr145;
	case 720: goto tr860;
	case 721: goto tr775;
	case 446: goto tr145;
	case 447: goto tr145;
	case 448: goto tr145;
	case 449: goto tr145;
	case 450: goto tr145;
	case 451: goto tr145;
	case 722: goto tr863;
	case 723: goto tr775;
	case 452: goto tr145;
	case 453: goto tr145;
	case 454: goto tr145;
	case 455: goto tr145;
	case 456: goto tr145;
	case 457: goto tr145;
	case 724: goto tr867;
	case 458: goto tr487;
	case 459: goto tr487;
	case 725: goto tr870;
	case 460: goto tr145;
	case 461: goto tr145;
	case 462: goto tr145;
	case 463: goto tr145;
	case 464: goto tr145;
	case 465: goto tr145;
	case 466: goto tr145;
	case 467: goto tr145;
	case 726: goto tr872;
	case 727: goto tr775;
	case 468: goto tr145;
	case 469: goto tr145;
	case 470: goto tr145;
	case 471: goto tr145;
	case 472: goto tr145;
	case 728: goto tr875;
	case 729: goto tr775;
	case 473: goto tr145;
	case 474: goto tr145;
	case 475: goto tr145;
	case 476: goto tr145;
	case 477: goto tr145;
	case 730: goto tr878;
	case 731: goto tr775;
	case 478: goto tr145;
	case 479: goto tr145;
	case 480: goto tr145;
	case 481: goto tr145;
	case 482: goto tr145;
	case 483: goto tr145;
	case 484: goto tr145;
	case 485: goto tr145;
	case 486: goto tr145;
	case 487: goto tr145;
	case 488: goto tr145;
	case 489: goto tr145;
	case 490: goto tr145;
	case 491: goto tr145;
	case 492: goto tr145;
	case 493: goto tr145;
	case 494: goto tr145;
	case 495: goto tr145;
	case 496: goto tr145;
	case 497: goto tr145;
	case 498: goto tr145;
	case 499: goto tr145;
	case 500: goto tr145;
	case 501: goto tr145;
	case 502: goto tr145;
	case 503: goto tr145;
	case 504: goto tr145;
	case 505: goto tr145;
	case 506: goto tr145;
	case 507: goto tr145;
	case 508: goto tr145;
	case 509: goto tr145;
	case 510: goto tr145;
	case 511: goto tr145;
	case 512: goto tr145;
	case 513: goto tr145;
	case 514: goto tr145;
	case 515: goto tr145;
	case 516: goto tr145;
	case 517: goto tr145;
	case 518: goto tr145;
	case 519: goto tr145;
	case 520: goto tr145;
	case 521: goto tr145;
	case 522: goto tr145;
	case 523: goto tr145;
	case 524: goto tr145;
	case 525: goto tr145;
	case 526: goto tr145;
	case 527: goto tr145;
	case 528: goto tr145;
	case 529: goto tr145;
	case 530: goto tr145;
	case 531: goto tr145;
	case 532: goto tr145;
	case 533: goto tr145;
	case 534: goto tr145;
	case 535: goto tr145;
	case 536: goto tr145;
	case 537: goto tr145;
	case 538: goto tr145;
	case 539: goto tr145;
	case 540: goto tr145;
	case 541: goto tr145;
	case 542: goto tr145;
	case 543: goto tr145;
	case 544: goto tr145;
	case 545: goto tr145;
	case 546: goto tr145;
	case 547: goto tr145;
	case 548: goto tr145;
	case 549: goto tr145;
	case 550: goto tr145;
	case 551: goto tr145;
	case 552: goto tr145;
	case 553: goto tr145;
	case 554: goto tr145;
	case 555: goto tr145;
	case 556: goto tr145;
	case 557: goto tr145;
	case 558: goto tr145;
	case 559: goto tr145;
	case 560: goto tr145;
	case 561: goto tr145;
	case 562: goto tr145;
	case 732: goto tr775;
	case 563: goto tr145;
	case 564: goto tr145;
	case 565: goto tr145;
	case 566: goto tr145;
	case 567: goto tr145;
	case 568: goto tr145;
	case 569: goto tr138;
	case 733: goto tr893;
	case 570: goto tr138;
	case 571: goto tr138;
	case 572: goto tr145;
	case 734: goto tr775;
	case 573: goto tr145;
	case 574: goto tr145;
	case 575: goto tr145;
	case 736: goto tr898;
	case 576: goto tr603;
	case 577: goto tr603;
	case 578: goto tr603;
	case 579: goto tr603;
	case 580: goto tr603;
	case 737: goto tr898;
	case 581: goto tr603;
	case 582: goto tr603;
	case 583: goto tr603;
	case 584: goto tr603;
	case 585: goto tr603;
	case 739: goto tr904;
	case 586: goto tr613;
	case 587: goto tr613;
	case 588: goto tr613;
	case 589: goto tr613;
	case 590: goto tr613;
	case 591: goto tr613;
	case 592: goto tr613;
	case 593: goto tr613;
	case 740: goto tr904;
	case 594: goto tr613;
	case 595: goto tr613;
	case 596: goto tr613;
	case 597: goto tr613;
	case 598: goto tr613;
	case 599: goto tr613;
	case 600: goto tr613;
	case 601: goto tr613;
	case 742: goto tr910;
	case 602: goto tr629;
	case 603: goto tr629;
	case 604: goto tr629;
	case 605: goto tr629;
	case 606: goto tr629;
	case 607: goto tr629;
	case 608: goto tr629;
	case 609: goto tr629;
	case 610: goto tr629;
	case 611: goto tr629;
	case 612: goto tr629;
	case 613: goto tr629;
	case 614: goto tr629;
	case 615: goto tr629;
	case 616: goto tr629;
	case 617: goto tr629;
	case 618: goto tr629;
	case 619: goto tr629;
	case 620: goto tr629;
	case 621: goto tr629;
	case 622: goto tr629;
	case 623: goto tr629;
	case 624: goto tr629;
	case 625: goto tr629;
	case 626: goto tr629;
	case 627: goto tr629;
	case 743: goto tr910;
	case 628: goto tr629;
	case 629: goto tr629;
	case 630: goto tr629;
	case 631: goto tr629;
	case 632: goto tr629;
	case 633: goto tr629;
	case 634: goto tr629;
	case 635: goto tr629;
	case 636: goto tr629;
	case 637: goto tr629;
	case 638: goto tr629;
	case 639: goto tr629;
	case 640: goto tr629;
	case 641: goto tr629;
	case 642: goto tr629;
	case 643: goto tr629;
	case 644: goto tr629;
	case 645: goto tr629;
	case 646: goto tr629;
	case 647: goto tr629;
	case 648: goto tr629;
	case 649: goto tr629;
	case 650: goto tr629;
	case 651: goto tr629;
	case 652: goto tr629;
	case 653: goto tr629;
	case 745: goto tr687;
	case 654: goto tr687;
	case 746: goto tr920;
	case 747: goto tr920;
	case 655: goto tr689;
	case 748: goto tr921;
	case 749: goto tr921;
	case 656: goto tr689;
	}
	}

	_out: {}
	}

#line 1191 "ext/dtext/dtext.rl"

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

  StateMachine* sm = init_machine(dtext, length, opt_inline, opt_mentions);
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
