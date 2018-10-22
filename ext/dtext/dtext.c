
#line 1 "ext/dtext/dtext.rl"
// situationally print newlines to make the generated html
// easier to read
#define PRETTY_PRINT 0

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
  BLOCK_STRIP = 30,
} element_t;


#line 881 "ext/dtext/dtext.rl"



#line 58 "ext/dtext/dtext.c"
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
	0, 0, 0, 0, 73, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 73, 0, 73, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	73, 0, 73, 0, 73, 0, 73, 0, 
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
	0, 0, 0, 0, 74, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 74, 0, 74, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	74, 0, 74, 0, 74, 0, 74, 0, 
	0, 0, 0, 0
};

static const int dtext_start = 420;
static const int dtext_first_final = 420;
static const int dtext_error = -1;

static const int dtext_en_basic_inline = 436;
static const int dtext_en_inline = 438;
static const int dtext_en_code = 496;
static const int dtext_en_nodtext = 498;
static const int dtext_en_table = 500;
static const int dtext_en_list = 502;
static const int dtext_en_main = 420;


#line 884 "ext/dtext/dtext.rl"

static inline void dstack_push(StateMachine * sm, element_t element) {
  g_queue_push_tail(sm->dstack, GINT_TO_POINTER(element));
}

static inline element_t dstack_pop(StateMachine * sm) {
  return GPOINTER_TO_INT(g_queue_pop_tail(sm->dstack));
}

static inline element_t dstack_peek(const StateMachine * sm) {
  return GPOINTER_TO_INT(g_queue_peek_tail(sm->dstack));
}

/*
static inline bool dstack_search(StateMachine * sm, const int * element) {
  return g_queue_find(sm->dstack, (gconstpointer)element);
}
*/

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

static inline void append(StateMachine * sm, bool is_markup, const char * s) {
  if (!(is_markup && sm->f_strip)) {
    sm->output = g_string_append(sm->output, s);
  }
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

static inline void append_segment(StateMachine * sm, bool is_markup, const char * a, const char * b) {
  if (!(is_markup && sm->f_strip)) {
    sm->output = g_string_append_len(sm->output, a, b - a + 1);
  }
}

static inline void append_segment_uri_escaped(StateMachine * sm, const char * a, const char * b) {
  if (sm->f_strip) {
    return;
  }

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

static inline void append_link(StateMachine * sm, const char * title, const char * ahref) {
  append(sm, true, ahref);
  append_segment_uri_escaped(sm, sm->a1, sm->a2 - 1);
  append(sm, true, "\">");
  append(sm, false, title);
  append_segment_html_escaped(sm, sm->a1, sm->a2 - 1);
  append(sm, true, "</a>");
}

static inline void append_url(StateMachine * sm, const char * url_start, const char * url_end, const char * title_start, const char * title_end) {
  append(sm, true, "<a class=\"dtext-link\" href=\"");
  append_segment_html_escaped(sm, url_start, url_end);
  append(sm, true, "\">");
  append_segment_html_escaped(sm, title_start, title_end);
  append(sm, true, "</a>");
}

static inline bool append_named_url(StateMachine * sm, const char * url_start, const char * url_end, const char * title_start, const char * title_end) {
  g_autoptr(GString) parsed_title = parse_basic_inline(title_start, title_end - title_start, sm->f_strip);

  if (!parsed_title) {
    return false;
  }

  if (url_start[0] == '/' || url_start[0] == '#') {
    append(sm, true, "<a class=\"dtext-link\" href=\"");
  } else {
    append(sm, true, "<a class=\"dtext-link dtext-external-link\" href=\"");
  }

  append_segment_html_escaped(sm, url_start, url_end);
  append(sm, true, "\">");
  append_segment(sm, false, parsed_title->str, parsed_title->str + parsed_title->len - 1);
  append(sm, true, "</a>");

  return true;
}

static inline void append_wiki_link(StateMachine * sm, const char * tag, const size_t tag_len, const char * title, const size_t title_len) {
  g_autofree gchar* lowercased_tag = g_utf8_strdown(tag, tag_len);
  g_autoptr(GString) normalized_tag = g_string_new(g_strdelimit(lowercased_tag, " ", '_'));

  append(sm, true, "<a class=\"dtext-link dtext-wiki-link\" href=\"/wiki_pages/show_or_new?title=");
  append_segment_uri_escaped(sm, normalized_tag->str, normalized_tag->str + normalized_tag->len - 1);
  append(sm, true, "\">");
  append_segment_html_escaped(sm, title, title + title_len - 1);
  append(sm, true, "</a>");
}

static inline void append_paged_link(StateMachine * sm, const char * title, const char * ahref, const char * param) {
  append(sm, true, ahref);
  append_segment(sm, true, sm->a1, sm->a2 - 1);
  append(sm, true, param);
  append_segment(sm, true, sm->b1, sm->b2 - 1);
  append(sm, true, "\">");
  append(sm, false, title);
  append_segment(sm, false, sm->a1, sm->a2 - 1);
  append(sm, false, "/p");
  append_segment(sm, false, sm->b1, sm->b2 - 1);
  append(sm, true, "</a>");
}

static inline void append_block_segment(StateMachine * sm, const char * a, const char * b) {
  if (sm->f_inline) {
    // sm->output = g_string_append_c(sm->output, ' ');
  } else if (sm->f_strip) {
    if (sm->output->len > 0 && sm->output->str[sm->output->len-1] != ' ') {
      append_c(sm, ' ');
    }
  } else {
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
  append(sm, true, html);
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
    append(sm, true, close_html);
  } else {
    g_debug("ignored out-of-order closing inline tag [%d]", type);

    append_segment(sm, true, sm->ts, sm->te - 1); // XXX should be false?
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
    case INLINE_SPOILER: append(sm, true, "</span>"); break;
    case BLOCK_SPOILER: append_block(sm, "</div>"); break;
    case BLOCK_QUOTE: append_block(sm, "</blockquote>"); break;
    case BLOCK_EXPAND: append_block(sm, "</div></div>"); break;
    case BLOCK_NODTEXT: append_closing_p(sm); break;
    case BLOCK_CODE: append_block(sm, "</pre>"); break;
    case BLOCK_TD: append_block(sm, "</td>"); break;
    case BLOCK_TH: append_block(sm, "</th>"); break;

    case INLINE_NODTEXT: break;
    case INLINE_B: append(sm, true, "</strong>"); break;
    case INLINE_I: append(sm, true, "</em>"); break;
    case INLINE_U: append(sm, true, "</u>"); break;
    case INLINE_S: append(sm, true, "</s>"); break;
    case INLINE_TN: append(sm, true, "</span>"); break;
    case INLINE_CODE: append(sm, true, "</code>"); break;

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
    case BLOCK_STRIP: append_c(sm, ' '); break;

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

/*
static bool print_machine(StateMachine * sm) {
  printf("p=%c\n", *sm->p);
  return true;
}
*/

StateMachine* init_machine(const char * src, size_t len, bool f_strip, bool f_inline, bool f_mentions) {
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
  sm->f_strip = f_strip;
  sm->f_mentions = f_mentions;
  sm->stack = g_array_sized_new(FALSE, TRUE, sizeof(int), 16);
  sm->dstack = g_queue_new();
  sm->error = NULL;
  sm->list_nest = 0;
  sm->list_mode = false;
  sm->header_mode = false;
  sm->d = 0;
  sm->b = 0;
  sm->quote = 0;

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

GString* parse_basic_inline(const char* dtext, const ssize_t length, const bool f_strip) {
    GString* output = NULL;
    StateMachine* sm = init_machine(dtext, length, f_strip, true, false);
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

  
#line 624 "ext/dtext/dtext.c"
	{
	( sm->top) = 0;
	( sm->ts) = 0;
	( sm->te) = 0;
	( sm->act) = 0;
	}

#line 1301 "ext/dtext/dtext.rl"
  
#line 634 "ext/dtext/dtext.c"
	{
	if ( ( sm->p) == ( sm->pe) )
		goto _test_eof;
_resume:
	switch ( _dtext_from_state_actions[ sm->cs] ) {
	case 74:
#line 1 "NONE"
	{( sm->ts) = ( sm->p);}
	break;
#line 644 "ext/dtext/dtext.c"
	}

	switch (  sm->cs ) {
case 420:
	switch( (*( sm->p)) ) {
		case 10: goto tr481;
		case 13: goto tr482;
		case 42: goto tr483;
		case 72: goto tr484;
		case 91: goto tr485;
		case 104: goto tr484;
	}
	goto tr480;
case 421:
	switch( (*( sm->p)) ) {
		case 10: goto tr1;
		case 13: goto tr486;
	}
	goto tr0;
case 0:
	if ( (*( sm->p)) == 10 )
		goto tr1;
	goto tr0;
case 422:
	if ( (*( sm->p)) == 10 )
		goto tr481;
	goto tr487;
case 423:
	switch( (*( sm->p)) ) {
		case 9: goto tr5;
		case 32: goto tr5;
		case 42: goto tr6;
	}
	goto tr487;
case 1:
	switch( (*( sm->p)) ) {
		case 9: goto tr4;
		case 10: goto tr2;
		case 13: goto tr2;
		case 32: goto tr4;
	}
	goto tr3;
case 424:
	switch( (*( sm->p)) ) {
		case 10: goto tr488;
		case 13: goto tr488;
	}
	goto tr489;
case 425:
	switch( (*( sm->p)) ) {
		case 9: goto tr4;
		case 10: goto tr488;
		case 13: goto tr488;
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
case 426:
	if ( 49 <= (*( sm->p)) && (*( sm->p)) <= 54 )
		goto tr490;
	goto tr487;
case 3:
	switch( (*( sm->p)) ) {
		case 35: goto tr7;
		case 46: goto tr8;
	}
	goto tr2;
case 4:
	if ( (*( sm->p)) == 33 )
		goto tr9;
	if ( (*( sm->p)) > 45 ) {
		if ( 47 <= (*( sm->p)) && (*( sm->p)) <= 126 )
			goto tr9;
	} else if ( (*( sm->p)) >= 35 )
		goto tr9;
	goto tr2;
case 5:
	switch( (*( sm->p)) ) {
		case 33: goto tr10;
		case 46: goto tr11;
	}
	if ( 35 <= (*( sm->p)) && (*( sm->p)) <= 126 )
		goto tr10;
	goto tr2;
case 427:
	switch( (*( sm->p)) ) {
		case 9: goto tr492;
		case 32: goto tr492;
	}
	goto tr491;
case 428:
	switch( (*( sm->p)) ) {
		case 9: goto tr494;
		case 32: goto tr494;
	}
	goto tr493;
case 429:
	switch( (*( sm->p)) ) {
		case 47: goto tr495;
		case 67: goto tr496;
		case 69: goto tr497;
		case 78: goto tr498;
		case 81: goto tr499;
		case 83: goto tr500;
		case 84: goto tr501;
		case 99: goto tr496;
		case 101: goto tr497;
		case 110: goto tr498;
		case 113: goto tr499;
		case 115: goto tr500;
		case 116: goto tr501;
	}
	goto tr487;
case 6:
	switch( (*( sm->p)) ) {
		case 83: goto tr12;
		case 115: goto tr12;
	}
	goto tr2;
case 7:
	switch( (*( sm->p)) ) {
		case 80: goto tr13;
		case 112: goto tr13;
	}
	goto tr2;
case 8:
	switch( (*( sm->p)) ) {
		case 79: goto tr14;
		case 111: goto tr14;
	}
	goto tr2;
case 9:
	switch( (*( sm->p)) ) {
		case 73: goto tr15;
		case 105: goto tr15;
	}
	goto tr2;
case 10:
	switch( (*( sm->p)) ) {
		case 76: goto tr16;
		case 108: goto tr16;
	}
	goto tr2;
case 11:
	switch( (*( sm->p)) ) {
		case 69: goto tr17;
		case 101: goto tr17;
	}
	goto tr2;
case 12:
	switch( (*( sm->p)) ) {
		case 82: goto tr18;
		case 114: goto tr18;
	}
	goto tr2;
case 13:
	switch( (*( sm->p)) ) {
		case 83: goto tr19;
		case 93: goto tr20;
		case 115: goto tr19;
	}
	goto tr2;
case 14:
	if ( (*( sm->p)) == 93 )
		goto tr20;
	goto tr2;
case 15:
	switch( (*( sm->p)) ) {
		case 79: goto tr21;
		case 111: goto tr21;
	}
	goto tr2;
case 16:
	switch( (*( sm->p)) ) {
		case 68: goto tr22;
		case 100: goto tr22;
	}
	goto tr2;
case 17:
	switch( (*( sm->p)) ) {
		case 69: goto tr23;
		case 101: goto tr23;
	}
	goto tr2;
case 18:
	if ( (*( sm->p)) == 93 )
		goto tr24;
	goto tr2;
case 430:
	if ( (*( sm->p)) == 32 )
		goto tr24;
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr24;
	goto tr502;
case 19:
	switch( (*( sm->p)) ) {
		case 88: goto tr25;
		case 120: goto tr25;
	}
	goto tr2;
case 20:
	switch( (*( sm->p)) ) {
		case 80: goto tr26;
		case 112: goto tr26;
	}
	goto tr2;
case 21:
	switch( (*( sm->p)) ) {
		case 65: goto tr27;
		case 97: goto tr27;
	}
	goto tr2;
case 22:
	switch( (*( sm->p)) ) {
		case 78: goto tr28;
		case 110: goto tr28;
	}
	goto tr2;
case 23:
	switch( (*( sm->p)) ) {
		case 68: goto tr29;
		case 100: goto tr29;
	}
	goto tr2;
case 24:
	switch( (*( sm->p)) ) {
		case 61: goto tr30;
		case 93: goto tr31;
	}
	goto tr2;
case 25:
	if ( (*( sm->p)) == 93 )
		goto tr2;
	goto tr32;
case 26:
	if ( (*( sm->p)) == 93 )
		goto tr34;
	goto tr33;
case 431:
	if ( (*( sm->p)) == 32 )
		goto tr504;
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr504;
	goto tr503;
case 432:
	if ( (*( sm->p)) == 32 )
		goto tr31;
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr31;
	goto tr505;
case 27:
	switch( (*( sm->p)) ) {
		case 79: goto tr35;
		case 111: goto tr35;
	}
	goto tr2;
case 28:
	switch( (*( sm->p)) ) {
		case 68: goto tr36;
		case 100: goto tr36;
	}
	goto tr2;
case 29:
	switch( (*( sm->p)) ) {
		case 84: goto tr37;
		case 116: goto tr37;
	}
	goto tr2;
case 30:
	switch( (*( sm->p)) ) {
		case 69: goto tr38;
		case 101: goto tr38;
	}
	goto tr2;
case 31:
	switch( (*( sm->p)) ) {
		case 88: goto tr39;
		case 120: goto tr39;
	}
	goto tr2;
case 32:
	switch( (*( sm->p)) ) {
		case 84: goto tr40;
		case 116: goto tr40;
	}
	goto tr2;
case 33:
	if ( (*( sm->p)) == 93 )
		goto tr41;
	goto tr2;
case 433:
	if ( (*( sm->p)) == 32 )
		goto tr41;
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr41;
	goto tr506;
case 34:
	switch( (*( sm->p)) ) {
		case 85: goto tr42;
		case 117: goto tr42;
	}
	goto tr2;
case 35:
	switch( (*( sm->p)) ) {
		case 79: goto tr43;
		case 111: goto tr43;
	}
	goto tr2;
case 36:
	switch( (*( sm->p)) ) {
		case 84: goto tr44;
		case 116: goto tr44;
	}
	goto tr2;
case 37:
	switch( (*( sm->p)) ) {
		case 69: goto tr45;
		case 101: goto tr45;
	}
	goto tr2;
case 38:
	if ( (*( sm->p)) == 93 )
		goto tr46;
	goto tr2;
case 434:
	if ( (*( sm->p)) == 32 )
		goto tr46;
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr46;
	goto tr507;
case 39:
	switch( (*( sm->p)) ) {
		case 80: goto tr47;
		case 112: goto tr47;
	}
	goto tr2;
case 40:
	switch( (*( sm->p)) ) {
		case 79: goto tr48;
		case 111: goto tr48;
	}
	goto tr2;
case 41:
	switch( (*( sm->p)) ) {
		case 73: goto tr49;
		case 105: goto tr49;
	}
	goto tr2;
case 42:
	switch( (*( sm->p)) ) {
		case 76: goto tr50;
		case 108: goto tr50;
	}
	goto tr2;
case 43:
	switch( (*( sm->p)) ) {
		case 69: goto tr51;
		case 101: goto tr51;
	}
	goto tr2;
case 44:
	switch( (*( sm->p)) ) {
		case 82: goto tr52;
		case 114: goto tr52;
	}
	goto tr2;
case 45:
	switch( (*( sm->p)) ) {
		case 83: goto tr53;
		case 93: goto tr54;
		case 115: goto tr53;
	}
	goto tr2;
case 46:
	if ( (*( sm->p)) == 93 )
		goto tr54;
	goto tr2;
case 435:
	if ( (*( sm->p)) == 32 )
		goto tr54;
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr54;
	goto tr508;
case 47:
	switch( (*( sm->p)) ) {
		case 65: goto tr55;
		case 78: goto tr56;
		case 97: goto tr55;
		case 110: goto tr56;
	}
	goto tr2;
case 48:
	switch( (*( sm->p)) ) {
		case 66: goto tr57;
		case 98: goto tr57;
	}
	goto tr2;
case 49:
	switch( (*( sm->p)) ) {
		case 76: goto tr58;
		case 108: goto tr58;
	}
	goto tr2;
case 50:
	switch( (*( sm->p)) ) {
		case 69: goto tr59;
		case 101: goto tr59;
	}
	goto tr2;
case 51:
	if ( (*( sm->p)) == 93 )
		goto tr60;
	goto tr2;
case 52:
	if ( (*( sm->p)) == 93 )
		goto tr61;
	goto tr2;
case 436:
	if ( (*( sm->p)) == 91 )
		goto tr510;
	goto tr509;
case 437:
	switch( (*( sm->p)) ) {
		case 47: goto tr512;
		case 66: goto tr513;
		case 73: goto tr514;
		case 83: goto tr515;
		case 85: goto tr516;
		case 98: goto tr513;
		case 105: goto tr514;
		case 115: goto tr515;
		case 117: goto tr516;
	}
	goto tr511;
case 53:
	switch( (*( sm->p)) ) {
		case 66: goto tr63;
		case 73: goto tr64;
		case 83: goto tr65;
		case 85: goto tr66;
		case 98: goto tr63;
		case 105: goto tr64;
		case 115: goto tr65;
		case 117: goto tr66;
	}
	goto tr62;
case 54:
	if ( (*( sm->p)) == 93 )
		goto tr67;
	goto tr62;
case 55:
	if ( (*( sm->p)) == 93 )
		goto tr68;
	goto tr62;
case 56:
	if ( (*( sm->p)) == 93 )
		goto tr69;
	goto tr62;
case 57:
	if ( (*( sm->p)) == 93 )
		goto tr70;
	goto tr62;
case 58:
	if ( (*( sm->p)) == 93 )
		goto tr71;
	goto tr62;
case 59:
	if ( (*( sm->p)) == 93 )
		goto tr72;
	goto tr62;
case 60:
	if ( (*( sm->p)) == 93 )
		goto tr73;
	goto tr62;
case 61:
	if ( (*( sm->p)) == 93 )
		goto tr74;
	goto tr62;
case 438:
	switch( (*( sm->p)) ) {
		case 10: goto tr518;
		case 13: goto tr519;
		case 34: goto tr520;
		case 60: goto tr521;
		case 64: goto tr522;
		case 65: goto tr523;
		case 66: goto tr524;
		case 67: goto tr525;
		case 68: goto tr526;
		case 70: goto tr527;
		case 73: goto tr528;
		case 77: goto tr529;
		case 78: goto tr530;
		case 80: goto tr531;
		case 83: goto tr532;
		case 84: goto tr533;
		case 85: goto tr534;
		case 87: goto tr535;
		case 91: goto tr536;
		case 97: goto tr523;
		case 98: goto tr524;
		case 99: goto tr525;
		case 100: goto tr526;
		case 102: goto tr527;
		case 104: goto tr537;
		case 105: goto tr528;
		case 109: goto tr529;
		case 110: goto tr530;
		case 112: goto tr531;
		case 115: goto tr532;
		case 116: goto tr533;
		case 117: goto tr534;
		case 119: goto tr535;
		case 123: goto tr538;
	}
	goto tr517;
case 439:
	switch( (*( sm->p)) ) {
		case 10: goto tr76;
		case 13: goto tr540;
		case 42: goto tr541;
	}
	goto tr539;
case 440:
	switch( (*( sm->p)) ) {
		case 10: goto tr76;
		case 13: goto tr540;
	}
	goto tr542;
case 62:
	if ( (*( sm->p)) == 10 )
		goto tr76;
	goto tr75;
case 63:
	switch( (*( sm->p)) ) {
		case 9: goto tr78;
		case 32: goto tr78;
		case 42: goto tr79;
	}
	goto tr77;
case 64:
	switch( (*( sm->p)) ) {
		case 9: goto tr81;
		case 10: goto tr77;
		case 13: goto tr77;
		case 32: goto tr81;
	}
	goto tr80;
case 441:
	switch( (*( sm->p)) ) {
		case 10: goto tr543;
		case 13: goto tr543;
	}
	goto tr544;
case 442:
	switch( (*( sm->p)) ) {
		case 9: goto tr81;
		case 10: goto tr543;
		case 13: goto tr543;
		case 32: goto tr81;
	}
	goto tr80;
case 443:
	if ( (*( sm->p)) == 10 )
		goto tr518;
	goto tr545;
case 444:
	if ( (*( sm->p)) == 34 )
		goto tr546;
	goto tr547;
case 65:
	if ( (*( sm->p)) == 34 )
		goto tr84;
	goto tr83;
case 66:
	if ( (*( sm->p)) == 58 )
		goto tr85;
	goto tr82;
case 67:
	switch( (*( sm->p)) ) {
		case 35: goto tr86;
		case 47: goto tr86;
		case 91: goto tr87;
		case 104: goto tr88;
	}
	goto tr82;
case 68:
	if ( (*( sm->p)) < -32 ) {
		if ( -62 <= (*( sm->p)) && (*( sm->p)) <= -33 )
			goto tr89;
	} else if ( (*( sm->p)) > -17 ) {
		if ( (*( sm->p)) > -12 ) {
			if ( 33 <= (*( sm->p)) && (*( sm->p)) <= 126 )
				goto tr92;
		} else if ( (*( sm->p)) >= -16 )
			goto tr91;
	} else
		goto tr90;
	goto tr82;
case 69:
	if ( (*( sm->p)) <= -65 )
		goto tr92;
	goto tr75;
case 445:
	if ( (*( sm->p)) < -32 ) {
		if ( -62 <= (*( sm->p)) && (*( sm->p)) <= -33 )
			goto tr89;
	} else if ( (*( sm->p)) > -17 ) {
		if ( (*( sm->p)) > -12 ) {
			if ( 33 <= (*( sm->p)) && (*( sm->p)) <= 126 )
				goto tr92;
		} else if ( (*( sm->p)) >= -16 )
			goto tr91;
	} else
		goto tr90;
	goto tr548;
case 70:
	if ( (*( sm->p)) <= -65 )
		goto tr89;
	goto tr75;
case 71:
	if ( (*( sm->p)) <= -65 )
		goto tr90;
	goto tr75;
case 72:
	switch( (*( sm->p)) ) {
		case 35: goto tr93;
		case 47: goto tr93;
		case 104: goto tr94;
	}
	goto tr82;
case 73:
	if ( (*( sm->p)) < -32 ) {
		if ( -62 <= (*( sm->p)) && (*( sm->p)) <= -33 )
			goto tr95;
	} else if ( (*( sm->p)) > -17 ) {
		if ( (*( sm->p)) > -12 ) {
			if ( 33 <= (*( sm->p)) && (*( sm->p)) <= 126 )
				goto tr98;
		} else if ( (*( sm->p)) >= -16 )
			goto tr97;
	} else
		goto tr96;
	goto tr82;
case 74:
	if ( (*( sm->p)) <= -65 )
		goto tr98;
	goto tr82;
case 75:
	if ( (*( sm->p)) == 93 )
		goto tr99;
	if ( (*( sm->p)) < -32 ) {
		if ( -62 <= (*( sm->p)) && (*( sm->p)) <= -33 )
			goto tr95;
	} else if ( (*( sm->p)) > -17 ) {
		if ( (*( sm->p)) > -12 ) {
			if ( 33 <= (*( sm->p)) && (*( sm->p)) <= 126 )
				goto tr98;
		} else if ( (*( sm->p)) >= -16 )
			goto tr97;
	} else
		goto tr96;
	goto tr82;
case 76:
	if ( (*( sm->p)) <= -65 )
		goto tr95;
	goto tr82;
case 77:
	if ( (*( sm->p)) <= -65 )
		goto tr96;
	goto tr82;
case 78:
	if ( (*( sm->p)) == 116 )
		goto tr100;
	goto tr82;
case 79:
	if ( (*( sm->p)) == 116 )
		goto tr101;
	goto tr82;
case 80:
	if ( (*( sm->p)) == 112 )
		goto tr102;
	goto tr82;
case 81:
	switch( (*( sm->p)) ) {
		case 58: goto tr103;
		case 115: goto tr104;
	}
	goto tr82;
case 82:
	if ( (*( sm->p)) == 47 )
		goto tr105;
	goto tr82;
case 83:
	if ( (*( sm->p)) == 47 )
		goto tr106;
	goto tr82;
case 84:
	if ( (*( sm->p)) == 58 )
		goto tr103;
	goto tr82;
case 85:
	if ( (*( sm->p)) == 116 )
		goto tr107;
	goto tr82;
case 86:
	if ( (*( sm->p)) == 116 )
		goto tr108;
	goto tr82;
case 87:
	if ( (*( sm->p)) == 112 )
		goto tr109;
	goto tr82;
case 88:
	switch( (*( sm->p)) ) {
		case 58: goto tr110;
		case 115: goto tr111;
	}
	goto tr82;
case 89:
	if ( (*( sm->p)) == 47 )
		goto tr112;
	goto tr82;
case 90:
	if ( (*( sm->p)) == 47 )
		goto tr113;
	goto tr82;
case 91:
	if ( (*( sm->p)) == 58 )
		goto tr110;
	goto tr82;
case 446:
	switch( (*( sm->p)) ) {
		case 64: goto tr549;
		case 104: goto tr550;
	}
	goto tr546;
case 92:
	if ( (*( sm->p)) < -32 ) {
		if ( -62 <= (*( sm->p)) && (*( sm->p)) <= -33 )
			goto tr114;
	} else if ( (*( sm->p)) > -17 ) {
		if ( (*( sm->p)) > -12 ) {
			if ( 33 <= (*( sm->p)) && (*( sm->p)) <= 126 )
				goto tr117;
		} else if ( (*( sm->p)) >= -16 )
			goto tr116;
	} else
		goto tr115;
	goto tr82;
case 93:
	if ( (*( sm->p)) <= -65 )
		goto tr118;
	goto tr82;
case 94:
	if ( (*( sm->p)) == 62 )
		goto tr122;
	if ( (*( sm->p)) < -32 ) {
		if ( -62 <= (*( sm->p)) && (*( sm->p)) <= -33 )
			goto tr119;
	} else if ( (*( sm->p)) > -17 ) {
		if ( (*( sm->p)) > -12 ) {
			if ( 33 <= (*( sm->p)) && (*( sm->p)) <= 126 )
				goto tr118;
		} else if ( (*( sm->p)) >= -16 )
			goto tr121;
	} else
		goto tr120;
	goto tr82;
case 95:
	if ( (*( sm->p)) <= -65 )
		goto tr119;
	goto tr82;
case 96:
	if ( (*( sm->p)) <= -65 )
		goto tr120;
	goto tr82;
case 97:
	if ( (*( sm->p)) == 116 )
		goto tr123;
	goto tr82;
case 98:
	if ( (*( sm->p)) == 116 )
		goto tr124;
	goto tr82;
case 99:
	if ( (*( sm->p)) == 112 )
		goto tr125;
	goto tr82;
case 100:
	switch( (*( sm->p)) ) {
		case 58: goto tr126;
		case 115: goto tr127;
	}
	goto tr82;
case 101:
	if ( (*( sm->p)) == 47 )
		goto tr128;
	goto tr82;
case 102:
	if ( (*( sm->p)) == 47 )
		goto tr129;
	goto tr82;
case 103:
	if ( (*( sm->p)) < -32 ) {
		if ( -62 <= (*( sm->p)) && (*( sm->p)) <= -33 )
			goto tr130;
	} else if ( (*( sm->p)) > -17 ) {
		if ( (*( sm->p)) > -12 ) {
			if ( 33 <= (*( sm->p)) && (*( sm->p)) <= 126 )
				goto tr133;
		} else if ( (*( sm->p)) >= -16 )
			goto tr132;
	} else
		goto tr131;
	goto tr82;
case 104:
	if ( (*( sm->p)) <= -65 )
		goto tr133;
	goto tr82;
case 105:
	if ( (*( sm->p)) == 62 )
		goto tr134;
	if ( (*( sm->p)) < -32 ) {
		if ( -62 <= (*( sm->p)) && (*( sm->p)) <= -33 )
			goto tr130;
	} else if ( (*( sm->p)) > -17 ) {
		if ( (*( sm->p)) > -12 ) {
			if ( 33 <= (*( sm->p)) && (*( sm->p)) <= 126 )
				goto tr133;
		} else if ( (*( sm->p)) >= -16 )
			goto tr132;
	} else
		goto tr131;
	goto tr82;
case 106:
	if ( (*( sm->p)) <= -65 )
		goto tr130;
	goto tr82;
case 107:
	if ( (*( sm->p)) <= -65 )
		goto tr131;
	goto tr82;
case 108:
	if ( (*( sm->p)) == 58 )
		goto tr126;
	goto tr82;
case 447:
	if ( (*( sm->p)) < -32 ) {
		if ( -62 <= (*( sm->p)) && (*( sm->p)) <= -33 )
			goto tr551;
	} else if ( (*( sm->p)) > -17 ) {
		if ( (*( sm->p)) > -12 ) {
			if ( 33 <= (*( sm->p)) && (*( sm->p)) <= 126 )
				goto tr554;
		} else if ( (*( sm->p)) >= -16 )
			goto tr553;
	} else
		goto tr552;
	goto tr546;
case 109:
	if ( (*( sm->p)) <= -65 )
		goto tr135;
	goto tr75;
case 448:
	if ( (*( sm->p)) < -32 ) {
		if ( -62 <= (*( sm->p)) && (*( sm->p)) <= -33 )
			goto tr136;
	} else if ( (*( sm->p)) > -17 ) {
		if ( (*( sm->p)) > -12 ) {
			if ( 33 <= (*( sm->p)) && (*( sm->p)) <= 126 )
				goto tr135;
		} else if ( (*( sm->p)) >= -16 )
			goto tr556;
	} else
		goto tr137;
	goto tr555;
case 110:
	if ( (*( sm->p)) <= -65 )
		goto tr136;
	goto tr75;
case 111:
	if ( (*( sm->p)) <= -65 )
		goto tr137;
	goto tr75;
case 449:
	if ( (*( sm->p)) == 64 )
		goto tr558;
	if ( (*( sm->p)) < -32 ) {
		if ( -62 <= (*( sm->p)) && (*( sm->p)) <= -33 )
			goto tr136;
	} else if ( (*( sm->p)) > -17 ) {
		if ( (*( sm->p)) > -12 ) {
			if ( 33 <= (*( sm->p)) && (*( sm->p)) <= 126 )
				goto tr135;
		} else if ( (*( sm->p)) >= -16 )
			goto tr556;
	} else
		goto tr137;
	goto tr557;
case 450:
	switch( (*( sm->p)) ) {
		case 76: goto tr559;
		case 80: goto tr560;
		case 82: goto tr561;
		case 108: goto tr559;
		case 112: goto tr560;
		case 114: goto tr561;
	}
	goto tr546;
case 112:
	switch( (*( sm->p)) ) {
		case 73: goto tr138;
		case 105: goto tr138;
	}
	goto tr82;
case 113:
	switch( (*( sm->p)) ) {
		case 65: goto tr139;
		case 97: goto tr139;
	}
	goto tr82;
case 114:
	switch( (*( sm->p)) ) {
		case 83: goto tr140;
		case 115: goto tr140;
	}
	goto tr82;
case 115:
	if ( (*( sm->p)) == 32 )
		goto tr141;
	goto tr82;
case 116:
	if ( (*( sm->p)) == 35 )
		goto tr142;
	goto tr82;
case 117:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr143;
	goto tr82;
case 451:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr563;
	goto tr562;
case 118:
	switch( (*( sm->p)) ) {
		case 80: goto tr144;
		case 112: goto tr144;
	}
	goto tr82;
case 119:
	switch( (*( sm->p)) ) {
		case 69: goto tr145;
		case 101: goto tr145;
	}
	goto tr82;
case 120:
	switch( (*( sm->p)) ) {
		case 65: goto tr146;
		case 97: goto tr146;
	}
	goto tr82;
case 121:
	switch( (*( sm->p)) ) {
		case 76: goto tr147;
		case 108: goto tr147;
	}
	goto tr82;
case 122:
	if ( (*( sm->p)) == 32 )
		goto tr148;
	goto tr82;
case 123:
	if ( (*( sm->p)) == 35 )
		goto tr149;
	goto tr82;
case 124:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr150;
	goto tr82;
case 452:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr565;
	goto tr564;
case 125:
	switch( (*( sm->p)) ) {
		case 84: goto tr151;
		case 116: goto tr151;
	}
	goto tr82;
case 126:
	switch( (*( sm->p)) ) {
		case 73: goto tr152;
		case 83: goto tr153;
		case 105: goto tr152;
		case 115: goto tr153;
	}
	goto tr82;
case 127:
	switch( (*( sm->p)) ) {
		case 83: goto tr154;
		case 115: goto tr154;
	}
	goto tr82;
case 128:
	switch( (*( sm->p)) ) {
		case 84: goto tr155;
		case 116: goto tr155;
	}
	goto tr82;
case 129:
	if ( (*( sm->p)) == 32 )
		goto tr156;
	goto tr82;
case 130:
	if ( (*( sm->p)) == 35 )
		goto tr157;
	goto tr82;
case 131:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr158;
	goto tr82;
case 453:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr567;
	goto tr566;
case 132:
	switch( (*( sm->p)) ) {
		case 84: goto tr159;
		case 116: goto tr159;
	}
	goto tr82;
case 133:
	switch( (*( sm->p)) ) {
		case 65: goto tr160;
		case 97: goto tr160;
	}
	goto tr82;
case 134:
	switch( (*( sm->p)) ) {
		case 84: goto tr161;
		case 116: goto tr161;
	}
	goto tr82;
case 135:
	switch( (*( sm->p)) ) {
		case 73: goto tr162;
		case 105: goto tr162;
	}
	goto tr82;
case 136:
	switch( (*( sm->p)) ) {
		case 79: goto tr163;
		case 111: goto tr163;
	}
	goto tr82;
case 137:
	switch( (*( sm->p)) ) {
		case 78: goto tr164;
		case 110: goto tr164;
	}
	goto tr82;
case 138:
	if ( (*( sm->p)) == 32 )
		goto tr165;
	goto tr82;
case 139:
	if ( (*( sm->p)) == 35 )
		goto tr166;
	goto tr82;
case 140:
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr167;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr167;
	} else
		goto tr167;
	goto tr82;
case 454:
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr569;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr569;
	} else
		goto tr569;
	goto tr568;
case 455:
	switch( (*( sm->p)) ) {
		case 65: goto tr570;
		case 85: goto tr571;
		case 97: goto tr570;
		case 117: goto tr571;
	}
	goto tr546;
case 141:
	switch( (*( sm->p)) ) {
		case 78: goto tr168;
		case 110: goto tr168;
	}
	goto tr82;
case 142:
	if ( (*( sm->p)) == 32 )
		goto tr169;
	goto tr82;
case 143:
	if ( (*( sm->p)) == 35 )
		goto tr170;
	goto tr82;
case 144:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr171;
	goto tr82;
case 456:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr573;
	goto tr572;
case 145:
	switch( (*( sm->p)) ) {
		case 82: goto tr172;
		case 114: goto tr172;
	}
	goto tr82;
case 146:
	if ( (*( sm->p)) == 32 )
		goto tr173;
	goto tr82;
case 147:
	if ( (*( sm->p)) == 35 )
		goto tr174;
	goto tr82;
case 148:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr175;
	goto tr82;
case 457:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr575;
	goto tr574;
case 458:
	switch( (*( sm->p)) ) {
		case 79: goto tr576;
		case 111: goto tr576;
	}
	goto tr546;
case 149:
	switch( (*( sm->p)) ) {
		case 77: goto tr176;
		case 109: goto tr176;
	}
	goto tr82;
case 150:
	switch( (*( sm->p)) ) {
		case 77: goto tr177;
		case 109: goto tr177;
	}
	goto tr82;
case 151:
	switch( (*( sm->p)) ) {
		case 69: goto tr178;
		case 101: goto tr178;
	}
	goto tr82;
case 152:
	switch( (*( sm->p)) ) {
		case 78: goto tr179;
		case 110: goto tr179;
	}
	goto tr82;
case 153:
	switch( (*( sm->p)) ) {
		case 84: goto tr180;
		case 116: goto tr180;
	}
	goto tr82;
case 154:
	if ( (*( sm->p)) == 32 )
		goto tr181;
	goto tr82;
case 155:
	if ( (*( sm->p)) == 35 )
		goto tr182;
	goto tr82;
case 156:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr183;
	goto tr82;
case 459:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr578;
	goto tr577;
case 460:
	switch( (*( sm->p)) ) {
		case 69: goto tr579;
		case 101: goto tr579;
	}
	goto tr546;
case 157:
	switch( (*( sm->p)) ) {
		case 86: goto tr184;
		case 118: goto tr184;
	}
	goto tr82;
case 158:
	switch( (*( sm->p)) ) {
		case 73: goto tr185;
		case 105: goto tr185;
	}
	goto tr82;
case 159:
	switch( (*( sm->p)) ) {
		case 65: goto tr186;
		case 97: goto tr186;
	}
	goto tr82;
case 160:
	switch( (*( sm->p)) ) {
		case 78: goto tr187;
		case 110: goto tr187;
	}
	goto tr82;
case 161:
	switch( (*( sm->p)) ) {
		case 84: goto tr188;
		case 116: goto tr188;
	}
	goto tr82;
case 162:
	switch( (*( sm->p)) ) {
		case 65: goto tr189;
		case 97: goto tr189;
	}
	goto tr82;
case 163:
	switch( (*( sm->p)) ) {
		case 82: goto tr190;
		case 114: goto tr190;
	}
	goto tr82;
case 164:
	switch( (*( sm->p)) ) {
		case 84: goto tr191;
		case 116: goto tr191;
	}
	goto tr82;
case 165:
	if ( (*( sm->p)) == 32 )
		goto tr192;
	goto tr82;
case 166:
	if ( (*( sm->p)) == 35 )
		goto tr193;
	goto tr82;
case 167:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr194;
	goto tr82;
case 461:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr581;
	goto tr580;
case 462:
	switch( (*( sm->p)) ) {
		case 65: goto tr582;
		case 69: goto tr583;
		case 76: goto tr584;
		case 79: goto tr585;
		case 97: goto tr582;
		case 101: goto tr583;
		case 108: goto tr584;
		case 111: goto tr585;
	}
	goto tr546;
case 168:
	switch( (*( sm->p)) ) {
		case 86: goto tr195;
		case 118: goto tr195;
	}
	goto tr82;
case 169:
	switch( (*( sm->p)) ) {
		case 71: goto tr196;
		case 103: goto tr196;
	}
	goto tr82;
case 170:
	switch( (*( sm->p)) ) {
		case 82: goto tr197;
		case 114: goto tr197;
	}
	goto tr82;
case 171:
	switch( (*( sm->p)) ) {
		case 79: goto tr198;
		case 111: goto tr198;
	}
	goto tr82;
case 172:
	switch( (*( sm->p)) ) {
		case 85: goto tr199;
		case 117: goto tr199;
	}
	goto tr82;
case 173:
	switch( (*( sm->p)) ) {
		case 80: goto tr200;
		case 112: goto tr200;
	}
	goto tr82;
case 174:
	if ( (*( sm->p)) == 32 )
		goto tr201;
	goto tr82;
case 175:
	if ( (*( sm->p)) == 35 )
		goto tr202;
	goto tr82;
case 176:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr203;
	goto tr82;
case 463:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr587;
	goto tr586;
case 177:
	switch( (*( sm->p)) ) {
		case 69: goto tr204;
		case 101: goto tr204;
	}
	goto tr82;
case 178:
	switch( (*( sm->p)) ) {
		case 68: goto tr205;
		case 100: goto tr205;
	}
	goto tr82;
case 179:
	switch( (*( sm->p)) ) {
		case 66: goto tr206;
		case 98: goto tr206;
	}
	goto tr82;
case 180:
	switch( (*( sm->p)) ) {
		case 65: goto tr207;
		case 97: goto tr207;
	}
	goto tr82;
case 181:
	switch( (*( sm->p)) ) {
		case 67: goto tr208;
		case 99: goto tr208;
	}
	goto tr82;
case 182:
	switch( (*( sm->p)) ) {
		case 75: goto tr209;
		case 107: goto tr209;
	}
	goto tr82;
case 183:
	if ( (*( sm->p)) == 32 )
		goto tr210;
	goto tr82;
case 184:
	if ( (*( sm->p)) == 35 )
		goto tr211;
	goto tr82;
case 185:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr212;
	goto tr82;
case 464:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr589;
	goto tr588;
case 186:
	switch( (*( sm->p)) ) {
		case 65: goto tr213;
		case 97: goto tr213;
	}
	goto tr82;
case 187:
	switch( (*( sm->p)) ) {
		case 71: goto tr214;
		case 103: goto tr214;
	}
	goto tr82;
case 188:
	if ( (*( sm->p)) == 32 )
		goto tr215;
	goto tr82;
case 189:
	if ( (*( sm->p)) == 35 )
		goto tr216;
	goto tr82;
case 190:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr217;
	goto tr82;
case 465:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr591;
	goto tr590;
case 191:
	switch( (*( sm->p)) ) {
		case 82: goto tr218;
		case 114: goto tr218;
	}
	goto tr82;
case 192:
	switch( (*( sm->p)) ) {
		case 85: goto tr219;
		case 117: goto tr219;
	}
	goto tr82;
case 193:
	switch( (*( sm->p)) ) {
		case 77: goto tr220;
		case 109: goto tr220;
	}
	goto tr82;
case 194:
	if ( (*( sm->p)) == 32 )
		goto tr221;
	goto tr82;
case 195:
	if ( (*( sm->p)) == 35 )
		goto tr222;
	goto tr82;
case 196:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr223;
	goto tr82;
case 466:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr593;
	goto tr592;
case 467:
	switch( (*( sm->p)) ) {
		case 77: goto tr594;
		case 83: goto tr595;
		case 109: goto tr594;
		case 115: goto tr595;
	}
	goto tr546;
case 197:
	switch( (*( sm->p)) ) {
		case 80: goto tr224;
		case 112: goto tr224;
	}
	goto tr82;
case 198:
	switch( (*( sm->p)) ) {
		case 76: goto tr225;
		case 108: goto tr225;
	}
	goto tr82;
case 199:
	switch( (*( sm->p)) ) {
		case 73: goto tr226;
		case 105: goto tr226;
	}
	goto tr82;
case 200:
	switch( (*( sm->p)) ) {
		case 67: goto tr227;
		case 99: goto tr227;
	}
	goto tr82;
case 201:
	switch( (*( sm->p)) ) {
		case 65: goto tr228;
		case 97: goto tr228;
	}
	goto tr82;
case 202:
	switch( (*( sm->p)) ) {
		case 84: goto tr229;
		case 116: goto tr229;
	}
	goto tr82;
case 203:
	switch( (*( sm->p)) ) {
		case 73: goto tr230;
		case 105: goto tr230;
	}
	goto tr82;
case 204:
	switch( (*( sm->p)) ) {
		case 79: goto tr231;
		case 111: goto tr231;
	}
	goto tr82;
case 205:
	switch( (*( sm->p)) ) {
		case 78: goto tr232;
		case 110: goto tr232;
	}
	goto tr82;
case 206:
	if ( (*( sm->p)) == 32 )
		goto tr233;
	goto tr82;
case 207:
	if ( (*( sm->p)) == 35 )
		goto tr234;
	goto tr82;
case 208:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr235;
	goto tr82;
case 468:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr597;
	goto tr596;
case 209:
	switch( (*( sm->p)) ) {
		case 83: goto tr236;
		case 115: goto tr236;
	}
	goto tr82;
case 210:
	switch( (*( sm->p)) ) {
		case 85: goto tr237;
		case 117: goto tr237;
	}
	goto tr82;
case 211:
	switch( (*( sm->p)) ) {
		case 69: goto tr238;
		case 101: goto tr238;
	}
	goto tr82;
case 212:
	if ( (*( sm->p)) == 32 )
		goto tr239;
	goto tr82;
case 213:
	if ( (*( sm->p)) == 35 )
		goto tr240;
	goto tr82;
case 214:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr241;
	goto tr82;
case 469:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr599;
	goto tr598;
case 470:
	switch( (*( sm->p)) ) {
		case 79: goto tr600;
		case 111: goto tr600;
	}
	goto tr546;
case 215:
	switch( (*( sm->p)) ) {
		case 68: goto tr242;
		case 100: goto tr242;
	}
	goto tr82;
case 216:
	if ( (*( sm->p)) == 32 )
		goto tr243;
	goto tr82;
case 217:
	switch( (*( sm->p)) ) {
		case 65: goto tr244;
		case 97: goto tr244;
	}
	goto tr82;
case 218:
	switch( (*( sm->p)) ) {
		case 67: goto tr245;
		case 99: goto tr245;
	}
	goto tr82;
case 219:
	switch( (*( sm->p)) ) {
		case 84: goto tr246;
		case 116: goto tr246;
	}
	goto tr82;
case 220:
	switch( (*( sm->p)) ) {
		case 73: goto tr247;
		case 105: goto tr247;
	}
	goto tr82;
case 221:
	switch( (*( sm->p)) ) {
		case 79: goto tr248;
		case 111: goto tr248;
	}
	goto tr82;
case 222:
	switch( (*( sm->p)) ) {
		case 78: goto tr249;
		case 110: goto tr249;
	}
	goto tr82;
case 223:
	if ( (*( sm->p)) == 32 )
		goto tr250;
	goto tr82;
case 224:
	if ( (*( sm->p)) == 35 )
		goto tr251;
	goto tr82;
case 225:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr252;
	goto tr82;
case 471:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr602;
	goto tr601;
case 472:
	switch( (*( sm->p)) ) {
		case 73: goto tr603;
		case 79: goto tr604;
		case 105: goto tr603;
		case 111: goto tr604;
	}
	goto tr546;
case 226:
	switch( (*( sm->p)) ) {
		case 74: goto tr253;
		case 106: goto tr253;
	}
	goto tr82;
case 227:
	switch( (*( sm->p)) ) {
		case 73: goto tr254;
		case 105: goto tr254;
	}
	goto tr82;
case 228:
	switch( (*( sm->p)) ) {
		case 69: goto tr255;
		case 101: goto tr255;
	}
	goto tr82;
case 229:
	if ( (*( sm->p)) == 32 )
		goto tr256;
	goto tr82;
case 230:
	if ( (*( sm->p)) == 35 )
		goto tr257;
	goto tr82;
case 231:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr258;
	goto tr82;
case 473:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr606;
	goto tr605;
case 232:
	switch( (*( sm->p)) ) {
		case 84: goto tr259;
		case 116: goto tr259;
	}
	goto tr82;
case 233:
	switch( (*( sm->p)) ) {
		case 69: goto tr260;
		case 101: goto tr260;
	}
	goto tr82;
case 234:
	if ( (*( sm->p)) == 32 )
		goto tr261;
	goto tr82;
case 235:
	if ( (*( sm->p)) == 35 )
		goto tr262;
	goto tr82;
case 236:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr263;
	goto tr82;
case 474:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr608;
	goto tr607;
case 475:
	switch( (*( sm->p)) ) {
		case 65: goto tr609;
		case 73: goto tr610;
		case 79: goto tr611;
		case 97: goto tr609;
		case 105: goto tr610;
		case 111: goto tr611;
	}
	goto tr546;
case 237:
	switch( (*( sm->p)) ) {
		case 87: goto tr264;
		case 119: goto tr264;
	}
	goto tr82;
case 238:
	switch( (*( sm->p)) ) {
		case 79: goto tr265;
		case 111: goto tr265;
	}
	goto tr82;
case 239:
	switch( (*( sm->p)) ) {
		case 79: goto tr266;
		case 111: goto tr266;
	}
	goto tr82;
case 240:
	if ( (*( sm->p)) == 32 )
		goto tr267;
	goto tr82;
case 241:
	if ( (*( sm->p)) == 35 )
		goto tr268;
	goto tr82;
case 242:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr269;
	goto tr82;
case 476:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr613;
	goto tr612;
case 243:
	switch( (*( sm->p)) ) {
		case 88: goto tr270;
		case 120: goto tr270;
	}
	goto tr82;
case 244:
	switch( (*( sm->p)) ) {
		case 73: goto tr271;
		case 105: goto tr271;
	}
	goto tr82;
case 245:
	switch( (*( sm->p)) ) {
		case 86: goto tr272;
		case 118: goto tr272;
	}
	goto tr82;
case 246:
	if ( (*( sm->p)) == 32 )
		goto tr273;
	goto tr82;
case 247:
	if ( (*( sm->p)) == 35 )
		goto tr274;
	goto tr82;
case 248:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr275;
	goto tr82;
case 477:
	if ( (*( sm->p)) == 47 )
		goto tr615;
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr616;
	goto tr614;
case 249:
	switch( (*( sm->p)) ) {
		case 80: goto tr277;
		case 112: goto tr277;
	}
	goto tr276;
case 250:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr278;
	goto tr276;
case 478:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr618;
	goto tr617;
case 251:
	switch( (*( sm->p)) ) {
		case 79: goto tr279;
		case 83: goto tr280;
		case 111: goto tr279;
		case 115: goto tr280;
	}
	goto tr82;
case 252:
	switch( (*( sm->p)) ) {
		case 76: goto tr281;
		case 108: goto tr281;
	}
	goto tr82;
case 253:
	if ( (*( sm->p)) == 32 )
		goto tr282;
	goto tr82;
case 254:
	if ( (*( sm->p)) == 35 )
		goto tr283;
	goto tr82;
case 255:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr284;
	goto tr82;
case 479:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr620;
	goto tr619;
case 256:
	switch( (*( sm->p)) ) {
		case 84: goto tr285;
		case 116: goto tr285;
	}
	goto tr82;
case 257:
	if ( (*( sm->p)) == 32 )
		goto tr286;
	goto tr82;
case 258:
	if ( (*( sm->p)) == 35 )
		goto tr287;
	goto tr82;
case 259:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr288;
	goto tr82;
case 480:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr622;
	goto tr621;
case 481:
	switch( (*( sm->p)) ) {
		case 69: goto tr623;
		case 101: goto tr623;
	}
	goto tr546;
case 260:
	switch( (*( sm->p)) ) {
		case 73: goto tr289;
		case 105: goto tr289;
	}
	goto tr82;
case 261:
	switch( (*( sm->p)) ) {
		case 71: goto tr290;
		case 103: goto tr290;
	}
	goto tr82;
case 262:
	switch( (*( sm->p)) ) {
		case 65: goto tr291;
		case 97: goto tr291;
	}
	goto tr82;
case 263:
	if ( (*( sm->p)) == 32 )
		goto tr292;
	goto tr82;
case 264:
	if ( (*( sm->p)) == 35 )
		goto tr293;
	goto tr82;
case 265:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr294;
	goto tr82;
case 482:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr625;
	goto tr624;
case 483:
	switch( (*( sm->p)) ) {
		case 79: goto tr626;
		case 87: goto tr627;
		case 111: goto tr626;
		case 119: goto tr627;
	}
	goto tr546;
case 266:
	switch( (*( sm->p)) ) {
		case 80: goto tr295;
		case 112: goto tr295;
	}
	goto tr82;
case 267:
	switch( (*( sm->p)) ) {
		case 73: goto tr296;
		case 105: goto tr296;
	}
	goto tr82;
case 268:
	switch( (*( sm->p)) ) {
		case 67: goto tr297;
		case 99: goto tr297;
	}
	goto tr82;
case 269:
	if ( (*( sm->p)) == 32 )
		goto tr298;
	goto tr82;
case 270:
	if ( (*( sm->p)) == 35 )
		goto tr299;
	goto tr82;
case 271:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr300;
	goto tr82;
case 484:
	if ( (*( sm->p)) == 47 )
		goto tr629;
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr630;
	goto tr628;
case 272:
	switch( (*( sm->p)) ) {
		case 80: goto tr302;
		case 112: goto tr302;
	}
	goto tr301;
case 273:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr303;
	goto tr301;
case 485:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr632;
	goto tr631;
case 274:
	switch( (*( sm->p)) ) {
		case 73: goto tr304;
		case 105: goto tr304;
	}
	goto tr82;
case 275:
	switch( (*( sm->p)) ) {
		case 84: goto tr305;
		case 116: goto tr305;
	}
	goto tr82;
case 276:
	switch( (*( sm->p)) ) {
		case 84: goto tr306;
		case 116: goto tr306;
	}
	goto tr82;
case 277:
	switch( (*( sm->p)) ) {
		case 69: goto tr307;
		case 101: goto tr307;
	}
	goto tr82;
case 278:
	switch( (*( sm->p)) ) {
		case 82: goto tr308;
		case 114: goto tr308;
	}
	goto tr82;
case 279:
	if ( (*( sm->p)) == 32 )
		goto tr309;
	goto tr82;
case 280:
	if ( (*( sm->p)) == 35 )
		goto tr310;
	goto tr82;
case 281:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr311;
	goto tr82;
case 486:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr634;
	goto tr633;
case 487:
	switch( (*( sm->p)) ) {
		case 83: goto tr635;
		case 115: goto tr635;
	}
	goto tr546;
case 282:
	switch( (*( sm->p)) ) {
		case 69: goto tr312;
		case 101: goto tr312;
	}
	goto tr82;
case 283:
	switch( (*( sm->p)) ) {
		case 82: goto tr313;
		case 114: goto tr313;
	}
	goto tr82;
case 284:
	if ( (*( sm->p)) == 32 )
		goto tr314;
	goto tr82;
case 285:
	if ( (*( sm->p)) == 35 )
		goto tr315;
	goto tr82;
case 286:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr316;
	goto tr82;
case 488:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr637;
	goto tr636;
case 489:
	switch( (*( sm->p)) ) {
		case 73: goto tr638;
		case 105: goto tr638;
	}
	goto tr546;
case 287:
	switch( (*( sm->p)) ) {
		case 75: goto tr317;
		case 107: goto tr317;
	}
	goto tr82;
case 288:
	switch( (*( sm->p)) ) {
		case 73: goto tr318;
		case 105: goto tr318;
	}
	goto tr82;
case 289:
	if ( (*( sm->p)) == 32 )
		goto tr319;
	goto tr82;
case 290:
	if ( (*( sm->p)) == 35 )
		goto tr320;
	goto tr82;
case 291:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr321;
	goto tr82;
case 490:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr640;
	goto tr639;
case 491:
	switch( (*( sm->p)) ) {
		case 47: goto tr641;
		case 66: goto tr642;
		case 67: goto tr643;
		case 69: goto tr644;
		case 73: goto tr645;
		case 78: goto tr646;
		case 81: goto tr647;
		case 83: goto tr648;
		case 84: goto tr649;
		case 85: goto tr650;
		case 91: goto tr651;
		case 98: goto tr642;
		case 99: goto tr643;
		case 101: goto tr644;
		case 105: goto tr645;
		case 110: goto tr646;
		case 113: goto tr647;
		case 115: goto tr648;
		case 116: goto tr649;
		case 117: goto tr650;
	}
	goto tr546;
case 292:
	switch( (*( sm->p)) ) {
		case 66: goto tr322;
		case 67: goto tr323;
		case 69: goto tr324;
		case 73: goto tr325;
		case 81: goto tr326;
		case 83: goto tr327;
		case 84: goto tr328;
		case 85: goto tr329;
		case 98: goto tr322;
		case 99: goto tr323;
		case 101: goto tr324;
		case 105: goto tr325;
		case 113: goto tr326;
		case 115: goto tr327;
		case 116: goto tr328;
		case 117: goto tr329;
	}
	goto tr82;
case 293:
	if ( (*( sm->p)) == 93 )
		goto tr330;
	goto tr82;
case 294:
	switch( (*( sm->p)) ) {
		case 79: goto tr331;
		case 111: goto tr331;
	}
	goto tr82;
case 295:
	switch( (*( sm->p)) ) {
		case 68: goto tr332;
		case 100: goto tr332;
	}
	goto tr82;
case 296:
	switch( (*( sm->p)) ) {
		case 69: goto tr333;
		case 101: goto tr333;
	}
	goto tr82;
case 297:
	if ( (*( sm->p)) == 93 )
		goto tr334;
	goto tr82;
case 298:
	switch( (*( sm->p)) ) {
		case 88: goto tr335;
		case 120: goto tr335;
	}
	goto tr82;
case 299:
	switch( (*( sm->p)) ) {
		case 80: goto tr336;
		case 112: goto tr336;
	}
	goto tr82;
case 300:
	switch( (*( sm->p)) ) {
		case 65: goto tr337;
		case 97: goto tr337;
	}
	goto tr82;
case 301:
	switch( (*( sm->p)) ) {
		case 78: goto tr338;
		case 110: goto tr338;
	}
	goto tr82;
case 302:
	switch( (*( sm->p)) ) {
		case 68: goto tr339;
		case 100: goto tr339;
	}
	goto tr82;
case 303:
	if ( (*( sm->p)) == 93 )
		goto tr340;
	goto tr82;
case 304:
	if ( (*( sm->p)) == 93 )
		goto tr341;
	goto tr82;
case 305:
	switch( (*( sm->p)) ) {
		case 85: goto tr342;
		case 117: goto tr342;
	}
	goto tr82;
case 306:
	switch( (*( sm->p)) ) {
		case 79: goto tr343;
		case 111: goto tr343;
	}
	goto tr82;
case 307:
	switch( (*( sm->p)) ) {
		case 84: goto tr344;
		case 116: goto tr344;
	}
	goto tr82;
case 308:
	switch( (*( sm->p)) ) {
		case 69: goto tr345;
		case 101: goto tr345;
	}
	goto tr82;
case 309:
	if ( (*( sm->p)) == 93 )
		goto tr346;
	goto tr82;
case 492:
	if ( (*( sm->p)) == 32 )
		goto tr346;
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr346;
	goto tr652;
case 310:
	switch( (*( sm->p)) ) {
		case 80: goto tr347;
		case 93: goto tr348;
		case 112: goto tr347;
	}
	goto tr82;
case 311:
	switch( (*( sm->p)) ) {
		case 79: goto tr349;
		case 111: goto tr349;
	}
	goto tr82;
case 312:
	switch( (*( sm->p)) ) {
		case 73: goto tr350;
		case 105: goto tr350;
	}
	goto tr82;
case 313:
	switch( (*( sm->p)) ) {
		case 76: goto tr351;
		case 108: goto tr351;
	}
	goto tr82;
case 314:
	switch( (*( sm->p)) ) {
		case 69: goto tr352;
		case 101: goto tr352;
	}
	goto tr82;
case 315:
	switch( (*( sm->p)) ) {
		case 82: goto tr353;
		case 114: goto tr353;
	}
	goto tr82;
case 316:
	switch( (*( sm->p)) ) {
		case 83: goto tr354;
		case 93: goto tr355;
		case 115: goto tr354;
	}
	goto tr82;
case 317:
	if ( (*( sm->p)) == 93 )
		goto tr355;
	goto tr82;
case 318:
	switch( (*( sm->p)) ) {
		case 68: goto tr356;
		case 72: goto tr357;
		case 78: goto tr358;
		case 100: goto tr356;
		case 104: goto tr357;
		case 110: goto tr358;
	}
	goto tr82;
case 319:
	if ( (*( sm->p)) == 93 )
		goto tr359;
	goto tr82;
case 320:
	if ( (*( sm->p)) == 93 )
		goto tr360;
	goto tr82;
case 321:
	if ( (*( sm->p)) == 93 )
		goto tr361;
	goto tr82;
case 322:
	if ( (*( sm->p)) == 93 )
		goto tr362;
	goto tr82;
case 323:
	if ( (*( sm->p)) == 93 )
		goto tr363;
	goto tr82;
case 324:
	switch( (*( sm->p)) ) {
		case 79: goto tr364;
		case 111: goto tr364;
	}
	goto tr82;
case 325:
	switch( (*( sm->p)) ) {
		case 68: goto tr365;
		case 100: goto tr365;
	}
	goto tr82;
case 326:
	switch( (*( sm->p)) ) {
		case 69: goto tr366;
		case 101: goto tr366;
	}
	goto tr82;
case 327:
	if ( (*( sm->p)) == 93 )
		goto tr367;
	goto tr82;
case 328:
	switch( (*( sm->p)) ) {
		case 88: goto tr368;
		case 120: goto tr368;
	}
	goto tr82;
case 329:
	switch( (*( sm->p)) ) {
		case 80: goto tr369;
		case 112: goto tr369;
	}
	goto tr82;
case 330:
	switch( (*( sm->p)) ) {
		case 65: goto tr370;
		case 97: goto tr370;
	}
	goto tr82;
case 331:
	switch( (*( sm->p)) ) {
		case 78: goto tr371;
		case 110: goto tr371;
	}
	goto tr82;
case 332:
	switch( (*( sm->p)) ) {
		case 68: goto tr372;
		case 100: goto tr372;
	}
	goto tr82;
case 333:
	if ( (*( sm->p)) == 93 )
		goto tr373;
	goto tr82;
case 334:
	if ( (*( sm->p)) == 93 )
		goto tr374;
	goto tr82;
case 335:
	switch( (*( sm->p)) ) {
		case 79: goto tr375;
		case 111: goto tr375;
	}
	goto tr82;
case 336:
	switch( (*( sm->p)) ) {
		case 68: goto tr376;
		case 100: goto tr376;
	}
	goto tr82;
case 337:
	switch( (*( sm->p)) ) {
		case 84: goto tr377;
		case 116: goto tr377;
	}
	goto tr82;
case 338:
	switch( (*( sm->p)) ) {
		case 69: goto tr378;
		case 101: goto tr378;
	}
	goto tr82;
case 339:
	switch( (*( sm->p)) ) {
		case 88: goto tr379;
		case 120: goto tr379;
	}
	goto tr82;
case 340:
	switch( (*( sm->p)) ) {
		case 84: goto tr380;
		case 116: goto tr380;
	}
	goto tr82;
case 341:
	if ( (*( sm->p)) == 93 )
		goto tr381;
	goto tr82;
case 342:
	switch( (*( sm->p)) ) {
		case 85: goto tr382;
		case 117: goto tr382;
	}
	goto tr82;
case 343:
	switch( (*( sm->p)) ) {
		case 79: goto tr383;
		case 111: goto tr383;
	}
	goto tr82;
case 344:
	switch( (*( sm->p)) ) {
		case 84: goto tr384;
		case 116: goto tr384;
	}
	goto tr82;
case 345:
	switch( (*( sm->p)) ) {
		case 69: goto tr385;
		case 101: goto tr385;
	}
	goto tr82;
case 346:
	if ( (*( sm->p)) == 93 )
		goto tr386;
	goto tr82;
case 347:
	switch( (*( sm->p)) ) {
		case 80: goto tr387;
		case 93: goto tr388;
		case 112: goto tr387;
	}
	goto tr82;
case 348:
	switch( (*( sm->p)) ) {
		case 79: goto tr389;
		case 111: goto tr389;
	}
	goto tr82;
case 349:
	switch( (*( sm->p)) ) {
		case 73: goto tr390;
		case 105: goto tr390;
	}
	goto tr82;
case 350:
	switch( (*( sm->p)) ) {
		case 76: goto tr391;
		case 108: goto tr391;
	}
	goto tr82;
case 351:
	switch( (*( sm->p)) ) {
		case 69: goto tr392;
		case 101: goto tr392;
	}
	goto tr82;
case 352:
	switch( (*( sm->p)) ) {
		case 82: goto tr393;
		case 114: goto tr393;
	}
	goto tr82;
case 353:
	switch( (*( sm->p)) ) {
		case 83: goto tr394;
		case 93: goto tr395;
		case 115: goto tr394;
	}
	goto tr82;
case 354:
	if ( (*( sm->p)) == 93 )
		goto tr395;
	goto tr82;
case 355:
	switch( (*( sm->p)) ) {
		case 78: goto tr396;
		case 110: goto tr396;
	}
	goto tr82;
case 356:
	if ( (*( sm->p)) == 93 )
		goto tr397;
	goto tr82;
case 357:
	if ( (*( sm->p)) == 93 )
		goto tr398;
	goto tr82;
case 358:
	switch( (*( sm->p)) ) {
		case 93: goto tr82;
		case 124: goto tr400;
	}
	goto tr399;
case 359:
	switch( (*( sm->p)) ) {
		case 93: goto tr402;
		case 124: goto tr403;
	}
	goto tr401;
case 360:
	if ( (*( sm->p)) == 93 )
		goto tr404;
	goto tr82;
case 361:
	switch( (*( sm->p)) ) {
		case 93: goto tr82;
		case 124: goto tr82;
	}
	goto tr405;
case 362:
	switch( (*( sm->p)) ) {
		case 93: goto tr407;
		case 124: goto tr82;
	}
	goto tr406;
case 363:
	if ( (*( sm->p)) == 93 )
		goto tr408;
	goto tr82;
case 364:
	switch( (*( sm->p)) ) {
		case 93: goto tr402;
		case 124: goto tr82;
	}
	goto tr409;
case 493:
	if ( (*( sm->p)) == 116 )
		goto tr653;
	goto tr546;
case 365:
	if ( (*( sm->p)) == 116 )
		goto tr410;
	goto tr82;
case 366:
	if ( (*( sm->p)) == 112 )
		goto tr411;
	goto tr82;
case 367:
	switch( (*( sm->p)) ) {
		case 58: goto tr412;
		case 115: goto tr413;
	}
	goto tr82;
case 368:
	if ( (*( sm->p)) == 47 )
		goto tr414;
	goto tr82;
case 369:
	if ( (*( sm->p)) == 47 )
		goto tr415;
	goto tr82;
case 370:
	if ( (*( sm->p)) < -32 ) {
		if ( -62 <= (*( sm->p)) && (*( sm->p)) <= -33 )
			goto tr416;
	} else if ( (*( sm->p)) > -17 ) {
		if ( (*( sm->p)) > -12 ) {
			if ( 33 <= (*( sm->p)) && (*( sm->p)) <= 126 )
				goto tr419;
		} else if ( (*( sm->p)) >= -16 )
			goto tr418;
	} else
		goto tr417;
	goto tr82;
case 371:
	if ( (*( sm->p)) <= -65 )
		goto tr419;
	goto tr75;
case 494:
	if ( (*( sm->p)) < -32 ) {
		if ( -62 <= (*( sm->p)) && (*( sm->p)) <= -33 )
			goto tr416;
	} else if ( (*( sm->p)) > -17 ) {
		if ( (*( sm->p)) > -12 ) {
			if ( 33 <= (*( sm->p)) && (*( sm->p)) <= 126 )
				goto tr419;
		} else if ( (*( sm->p)) >= -16 )
			goto tr418;
	} else
		goto tr417;
	goto tr654;
case 372:
	if ( (*( sm->p)) <= -65 )
		goto tr416;
	goto tr75;
case 373:
	if ( (*( sm->p)) <= -65 )
		goto tr417;
	goto tr75;
case 374:
	if ( (*( sm->p)) == 58 )
		goto tr412;
	goto tr82;
case 495:
	if ( (*( sm->p)) == 123 )
		goto tr655;
	goto tr546;
case 375:
	if ( (*( sm->p)) == 125 )
		goto tr82;
	goto tr420;
case 376:
	if ( (*( sm->p)) == 125 )
		goto tr422;
	goto tr421;
case 377:
	if ( (*( sm->p)) == 125 )
		goto tr423;
	goto tr82;
case 496:
	if ( (*( sm->p)) == 91 )
		goto tr657;
	goto tr656;
case 497:
	if ( (*( sm->p)) == 47 )
		goto tr659;
	goto tr658;
case 378:
	switch( (*( sm->p)) ) {
		case 67: goto tr425;
		case 99: goto tr425;
	}
	goto tr424;
case 379:
	switch( (*( sm->p)) ) {
		case 79: goto tr426;
		case 111: goto tr426;
	}
	goto tr424;
case 380:
	switch( (*( sm->p)) ) {
		case 68: goto tr427;
		case 100: goto tr427;
	}
	goto tr424;
case 381:
	switch( (*( sm->p)) ) {
		case 69: goto tr428;
		case 101: goto tr428;
	}
	goto tr424;
case 382:
	if ( (*( sm->p)) == 93 )
		goto tr429;
	goto tr424;
case 498:
	if ( (*( sm->p)) == 91 )
		goto tr661;
	goto tr660;
case 499:
	if ( (*( sm->p)) == 47 )
		goto tr663;
	goto tr662;
case 383:
	switch( (*( sm->p)) ) {
		case 78: goto tr431;
		case 110: goto tr431;
	}
	goto tr430;
case 384:
	switch( (*( sm->p)) ) {
		case 79: goto tr432;
		case 111: goto tr432;
	}
	goto tr430;
case 385:
	switch( (*( sm->p)) ) {
		case 68: goto tr433;
		case 100: goto tr433;
	}
	goto tr430;
case 386:
	switch( (*( sm->p)) ) {
		case 84: goto tr434;
		case 116: goto tr434;
	}
	goto tr430;
case 387:
	switch( (*( sm->p)) ) {
		case 69: goto tr435;
		case 101: goto tr435;
	}
	goto tr430;
case 388:
	switch( (*( sm->p)) ) {
		case 88: goto tr436;
		case 120: goto tr436;
	}
	goto tr430;
case 389:
	switch( (*( sm->p)) ) {
		case 84: goto tr437;
		case 116: goto tr437;
	}
	goto tr430;
case 390:
	if ( (*( sm->p)) == 93 )
		goto tr438;
	goto tr430;
case 500:
	if ( (*( sm->p)) == 91 )
		goto tr665;
	goto tr664;
case 501:
	switch( (*( sm->p)) ) {
		case 47: goto tr667;
		case 84: goto tr668;
		case 116: goto tr668;
	}
	goto tr666;
case 391:
	switch( (*( sm->p)) ) {
		case 84: goto tr440;
		case 116: goto tr440;
	}
	goto tr439;
case 392:
	switch( (*( sm->p)) ) {
		case 65: goto tr441;
		case 66: goto tr442;
		case 72: goto tr443;
		case 82: goto tr444;
		case 97: goto tr441;
		case 98: goto tr442;
		case 104: goto tr443;
		case 114: goto tr444;
	}
	goto tr439;
case 393:
	switch( (*( sm->p)) ) {
		case 66: goto tr445;
		case 98: goto tr445;
	}
	goto tr439;
case 394:
	switch( (*( sm->p)) ) {
		case 76: goto tr446;
		case 108: goto tr446;
	}
	goto tr439;
case 395:
	switch( (*( sm->p)) ) {
		case 69: goto tr447;
		case 101: goto tr447;
	}
	goto tr439;
case 396:
	if ( (*( sm->p)) == 93 )
		goto tr448;
	goto tr439;
case 397:
	switch( (*( sm->p)) ) {
		case 79: goto tr449;
		case 111: goto tr449;
	}
	goto tr439;
case 398:
	switch( (*( sm->p)) ) {
		case 68: goto tr450;
		case 100: goto tr450;
	}
	goto tr439;
case 399:
	switch( (*( sm->p)) ) {
		case 89: goto tr451;
		case 121: goto tr451;
	}
	goto tr439;
case 400:
	if ( (*( sm->p)) == 93 )
		goto tr452;
	goto tr439;
case 401:
	switch( (*( sm->p)) ) {
		case 69: goto tr453;
		case 101: goto tr453;
	}
	goto tr439;
case 402:
	switch( (*( sm->p)) ) {
		case 65: goto tr454;
		case 97: goto tr454;
	}
	goto tr439;
case 403:
	switch( (*( sm->p)) ) {
		case 68: goto tr455;
		case 100: goto tr455;
	}
	goto tr439;
case 404:
	if ( (*( sm->p)) == 93 )
		goto tr456;
	goto tr439;
case 405:
	if ( (*( sm->p)) == 93 )
		goto tr457;
	goto tr439;
case 406:
	switch( (*( sm->p)) ) {
		case 66: goto tr458;
		case 68: goto tr459;
		case 72: goto tr460;
		case 82: goto tr461;
		case 98: goto tr458;
		case 100: goto tr459;
		case 104: goto tr460;
		case 114: goto tr461;
	}
	goto tr439;
case 407:
	switch( (*( sm->p)) ) {
		case 79: goto tr462;
		case 111: goto tr462;
	}
	goto tr439;
case 408:
	switch( (*( sm->p)) ) {
		case 68: goto tr463;
		case 100: goto tr463;
	}
	goto tr439;
case 409:
	switch( (*( sm->p)) ) {
		case 89: goto tr464;
		case 121: goto tr464;
	}
	goto tr439;
case 410:
	if ( (*( sm->p)) == 93 )
		goto tr465;
	goto tr439;
case 411:
	if ( (*( sm->p)) == 93 )
		goto tr466;
	goto tr439;
case 412:
	switch( (*( sm->p)) ) {
		case 69: goto tr467;
		case 93: goto tr468;
		case 101: goto tr467;
	}
	goto tr439;
case 413:
	switch( (*( sm->p)) ) {
		case 65: goto tr469;
		case 97: goto tr469;
	}
	goto tr439;
case 414:
	switch( (*( sm->p)) ) {
		case 68: goto tr470;
		case 100: goto tr470;
	}
	goto tr439;
case 415:
	if ( (*( sm->p)) == 93 )
		goto tr471;
	goto tr439;
case 416:
	if ( (*( sm->p)) == 93 )
		goto tr472;
	goto tr439;
case 502:
	switch( (*( sm->p)) ) {
		case 10: goto tr670;
		case 13: goto tr671;
		case 42: goto tr672;
	}
	goto tr669;
case 503:
	switch( (*( sm->p)) ) {
		case 10: goto tr474;
		case 13: goto tr673;
	}
	goto tr473;
case 417:
	if ( (*( sm->p)) == 10 )
		goto tr474;
	goto tr473;
case 504:
	if ( (*( sm->p)) == 10 )
		goto tr670;
	goto tr674;
case 505:
	switch( (*( sm->p)) ) {
		case 9: goto tr478;
		case 32: goto tr478;
		case 42: goto tr479;
	}
	goto tr674;
case 418:
	switch( (*( sm->p)) ) {
		case 9: goto tr477;
		case 10: goto tr475;
		case 13: goto tr475;
		case 32: goto tr477;
	}
	goto tr476;
case 506:
	switch( (*( sm->p)) ) {
		case 10: goto tr675;
		case 13: goto tr675;
	}
	goto tr676;
case 507:
	switch( (*( sm->p)) ) {
		case 9: goto tr477;
		case 10: goto tr675;
		case 13: goto tr675;
		case 32: goto tr477;
	}
	goto tr476;
case 419:
	switch( (*( sm->p)) ) {
		case 9: goto tr478;
		case 32: goto tr478;
		case 42: goto tr479;
	}
	goto tr475;
	}

	tr486:  sm->cs = 0; goto _again;
	tr5:  sm->cs = 1; goto f4;
	tr6:  sm->cs = 2; goto _again;
	tr490:  sm->cs = 3; goto f7;
	tr7:  sm->cs = 4; goto f4;
	tr10:  sm->cs = 5; goto _again;
	tr9:  sm->cs = 5; goto f3;
	tr495:  sm->cs = 6; goto _again;
	tr12:  sm->cs = 7; goto _again;
	tr13:  sm->cs = 8; goto _again;
	tr14:  sm->cs = 9; goto _again;
	tr15:  sm->cs = 10; goto _again;
	tr16:  sm->cs = 11; goto _again;
	tr17:  sm->cs = 12; goto _again;
	tr18:  sm->cs = 13; goto _again;
	tr19:  sm->cs = 14; goto _again;
	tr496:  sm->cs = 15; goto _again;
	tr21:  sm->cs = 16; goto _again;
	tr22:  sm->cs = 17; goto _again;
	tr23:  sm->cs = 18; goto _again;
	tr497:  sm->cs = 19; goto _again;
	tr25:  sm->cs = 20; goto _again;
	tr26:  sm->cs = 21; goto _again;
	tr27:  sm->cs = 22; goto _again;
	tr28:  sm->cs = 23; goto _again;
	tr29:  sm->cs = 24; goto _again;
	tr30:  sm->cs = 25; goto _again;
	tr33:  sm->cs = 26; goto _again;
	tr32:  sm->cs = 26; goto f7;
	tr498:  sm->cs = 27; goto _again;
	tr35:  sm->cs = 28; goto _again;
	tr36:  sm->cs = 29; goto _again;
	tr37:  sm->cs = 30; goto _again;
	tr38:  sm->cs = 31; goto _again;
	tr39:  sm->cs = 32; goto _again;
	tr40:  sm->cs = 33; goto _again;
	tr499:  sm->cs = 34; goto _again;
	tr42:  sm->cs = 35; goto _again;
	tr43:  sm->cs = 36; goto _again;
	tr44:  sm->cs = 37; goto _again;
	tr45:  sm->cs = 38; goto _again;
	tr500:  sm->cs = 39; goto _again;
	tr47:  sm->cs = 40; goto _again;
	tr48:  sm->cs = 41; goto _again;
	tr49:  sm->cs = 42; goto _again;
	tr50:  sm->cs = 43; goto _again;
	tr51:  sm->cs = 44; goto _again;
	tr52:  sm->cs = 45; goto _again;
	tr53:  sm->cs = 46; goto _again;
	tr501:  sm->cs = 47; goto _again;
	tr55:  sm->cs = 48; goto _again;
	tr57:  sm->cs = 49; goto _again;
	tr58:  sm->cs = 50; goto _again;
	tr59:  sm->cs = 51; goto _again;
	tr56:  sm->cs = 52; goto _again;
	tr512:  sm->cs = 53; goto _again;
	tr63:  sm->cs = 54; goto _again;
	tr64:  sm->cs = 55; goto _again;
	tr65:  sm->cs = 56; goto _again;
	tr66:  sm->cs = 57; goto _again;
	tr513:  sm->cs = 58; goto _again;
	tr514:  sm->cs = 59; goto _again;
	tr515:  sm->cs = 60; goto _again;
	tr516:  sm->cs = 61; goto _again;
	tr540:  sm->cs = 62; goto _again;
	tr79:  sm->cs = 63; goto _again;
	tr541:  sm->cs = 63; goto f7;
	tr78:  sm->cs = 64; goto f4;
	tr83:  sm->cs = 65; goto _again;
	tr547:  sm->cs = 65; goto f7;
	tr84:  sm->cs = 66; goto f4;
	tr85:  sm->cs = 67; goto _again;
	tr113:  sm->cs = 68; goto _again;
	tr86:  sm->cs = 68; goto f3;
	tr89:  sm->cs = 69; goto _again;
	tr90:  sm->cs = 70; goto _again;
	tr91:  sm->cs = 71; goto _again;
	tr87:  sm->cs = 72; goto _again;
	tr106:  sm->cs = 73; goto _again;
	tr93:  sm->cs = 73; goto f3;
	tr95:  sm->cs = 74; goto _again;
	tr98:  sm->cs = 75; goto f5;
	tr96:  sm->cs = 76; goto _again;
	tr97:  sm->cs = 77; goto _again;
	tr94:  sm->cs = 78; goto f3;
	tr100:  sm->cs = 79; goto _again;
	tr101:  sm->cs = 80; goto _again;
	tr102:  sm->cs = 81; goto _again;
	tr103:  sm->cs = 82; goto _again;
	tr105:  sm->cs = 83; goto _again;
	tr104:  sm->cs = 84; goto _again;
	tr88:  sm->cs = 85; goto f3;
	tr107:  sm->cs = 86; goto _again;
	tr108:  sm->cs = 87; goto _again;
	tr109:  sm->cs = 88; goto _again;
	tr110:  sm->cs = 89; goto _again;
	tr112:  sm->cs = 90; goto _again;
	tr111:  sm->cs = 91; goto _again;
	tr549:  sm->cs = 92; goto _again;
	tr119:  sm->cs = 93; goto _again;
	tr114:  sm->cs = 93; goto f7;
	tr118:  sm->cs = 94; goto _again;
	tr117:  sm->cs = 94; goto f7;
	tr120:  sm->cs = 95; goto _again;
	tr115:  sm->cs = 95; goto f7;
	tr121:  sm->cs = 96; goto _again;
	tr116:  sm->cs = 96; goto f7;
	tr550:  sm->cs = 97; goto _again;
	tr123:  sm->cs = 98; goto _again;
	tr124:  sm->cs = 99; goto _again;
	tr125:  sm->cs = 100; goto _again;
	tr126:  sm->cs = 101; goto _again;
	tr128:  sm->cs = 102; goto _again;
	tr129:  sm->cs = 103; goto _again;
	tr130:  sm->cs = 104; goto _again;
	tr133:  sm->cs = 105; goto _again;
	tr131:  sm->cs = 106; goto _again;
	tr132:  sm->cs = 107; goto _again;
	tr127:  sm->cs = 108; goto _again;
	tr136:  sm->cs = 109; goto _again;
	tr551:  sm->cs = 109; goto f7;
	tr137:  sm->cs = 110; goto _again;
	tr552:  sm->cs = 110; goto f7;
	tr556:  sm->cs = 111; goto _again;
	tr553:  sm->cs = 111; goto f7;
	tr559:  sm->cs = 112; goto _again;
	tr138:  sm->cs = 113; goto _again;
	tr139:  sm->cs = 114; goto _again;
	tr140:  sm->cs = 115; goto _again;
	tr141:  sm->cs = 116; goto _again;
	tr142:  sm->cs = 117; goto _again;
	tr560:  sm->cs = 118; goto _again;
	tr144:  sm->cs = 119; goto _again;
	tr145:  sm->cs = 120; goto _again;
	tr146:  sm->cs = 121; goto _again;
	tr147:  sm->cs = 122; goto _again;
	tr148:  sm->cs = 123; goto _again;
	tr149:  sm->cs = 124; goto _again;
	tr561:  sm->cs = 125; goto _again;
	tr151:  sm->cs = 126; goto _again;
	tr152:  sm->cs = 127; goto _again;
	tr154:  sm->cs = 128; goto _again;
	tr155:  sm->cs = 129; goto _again;
	tr156:  sm->cs = 130; goto _again;
	tr157:  sm->cs = 131; goto _again;
	tr153:  sm->cs = 132; goto _again;
	tr159:  sm->cs = 133; goto _again;
	tr160:  sm->cs = 134; goto _again;
	tr161:  sm->cs = 135; goto _again;
	tr162:  sm->cs = 136; goto _again;
	tr163:  sm->cs = 137; goto _again;
	tr164:  sm->cs = 138; goto _again;
	tr165:  sm->cs = 139; goto _again;
	tr166:  sm->cs = 140; goto _again;
	tr570:  sm->cs = 141; goto _again;
	tr168:  sm->cs = 142; goto _again;
	tr169:  sm->cs = 143; goto _again;
	tr170:  sm->cs = 144; goto _again;
	tr571:  sm->cs = 145; goto _again;
	tr172:  sm->cs = 146; goto _again;
	tr173:  sm->cs = 147; goto _again;
	tr174:  sm->cs = 148; goto _again;
	tr576:  sm->cs = 149; goto _again;
	tr176:  sm->cs = 150; goto _again;
	tr177:  sm->cs = 151; goto _again;
	tr178:  sm->cs = 152; goto _again;
	tr179:  sm->cs = 153; goto _again;
	tr180:  sm->cs = 154; goto _again;
	tr181:  sm->cs = 155; goto _again;
	tr182:  sm->cs = 156; goto _again;
	tr579:  sm->cs = 157; goto _again;
	tr184:  sm->cs = 158; goto _again;
	tr185:  sm->cs = 159; goto _again;
	tr186:  sm->cs = 160; goto _again;
	tr187:  sm->cs = 161; goto _again;
	tr188:  sm->cs = 162; goto _again;
	tr189:  sm->cs = 163; goto _again;
	tr190:  sm->cs = 164; goto _again;
	tr191:  sm->cs = 165; goto _again;
	tr192:  sm->cs = 166; goto _again;
	tr193:  sm->cs = 167; goto _again;
	tr582:  sm->cs = 168; goto _again;
	tr195:  sm->cs = 169; goto _again;
	tr196:  sm->cs = 170; goto _again;
	tr197:  sm->cs = 171; goto _again;
	tr198:  sm->cs = 172; goto _again;
	tr199:  sm->cs = 173; goto _again;
	tr200:  sm->cs = 174; goto _again;
	tr201:  sm->cs = 175; goto _again;
	tr202:  sm->cs = 176; goto _again;
	tr583:  sm->cs = 177; goto _again;
	tr204:  sm->cs = 178; goto _again;
	tr205:  sm->cs = 179; goto _again;
	tr206:  sm->cs = 180; goto _again;
	tr207:  sm->cs = 181; goto _again;
	tr208:  sm->cs = 182; goto _again;
	tr209:  sm->cs = 183; goto _again;
	tr210:  sm->cs = 184; goto _again;
	tr211:  sm->cs = 185; goto _again;
	tr584:  sm->cs = 186; goto _again;
	tr213:  sm->cs = 187; goto _again;
	tr214:  sm->cs = 188; goto _again;
	tr215:  sm->cs = 189; goto _again;
	tr216:  sm->cs = 190; goto _again;
	tr585:  sm->cs = 191; goto _again;
	tr218:  sm->cs = 192; goto _again;
	tr219:  sm->cs = 193; goto _again;
	tr220:  sm->cs = 194; goto _again;
	tr221:  sm->cs = 195; goto _again;
	tr222:  sm->cs = 196; goto _again;
	tr594:  sm->cs = 197; goto _again;
	tr224:  sm->cs = 198; goto _again;
	tr225:  sm->cs = 199; goto _again;
	tr226:  sm->cs = 200; goto _again;
	tr227:  sm->cs = 201; goto _again;
	tr228:  sm->cs = 202; goto _again;
	tr229:  sm->cs = 203; goto _again;
	tr230:  sm->cs = 204; goto _again;
	tr231:  sm->cs = 205; goto _again;
	tr232:  sm->cs = 206; goto _again;
	tr233:  sm->cs = 207; goto _again;
	tr234:  sm->cs = 208; goto _again;
	tr595:  sm->cs = 209; goto _again;
	tr236:  sm->cs = 210; goto _again;
	tr237:  sm->cs = 211; goto _again;
	tr238:  sm->cs = 212; goto _again;
	tr239:  sm->cs = 213; goto _again;
	tr240:  sm->cs = 214; goto _again;
	tr600:  sm->cs = 215; goto _again;
	tr242:  sm->cs = 216; goto _again;
	tr243:  sm->cs = 217; goto _again;
	tr244:  sm->cs = 218; goto _again;
	tr245:  sm->cs = 219; goto _again;
	tr246:  sm->cs = 220; goto _again;
	tr247:  sm->cs = 221; goto _again;
	tr248:  sm->cs = 222; goto _again;
	tr249:  sm->cs = 223; goto _again;
	tr250:  sm->cs = 224; goto _again;
	tr251:  sm->cs = 225; goto _again;
	tr603:  sm->cs = 226; goto _again;
	tr253:  sm->cs = 227; goto _again;
	tr254:  sm->cs = 228; goto _again;
	tr255:  sm->cs = 229; goto _again;
	tr256:  sm->cs = 230; goto _again;
	tr257:  sm->cs = 231; goto _again;
	tr604:  sm->cs = 232; goto _again;
	tr259:  sm->cs = 233; goto _again;
	tr260:  sm->cs = 234; goto _again;
	tr261:  sm->cs = 235; goto _again;
	tr262:  sm->cs = 236; goto _again;
	tr609:  sm->cs = 237; goto _again;
	tr264:  sm->cs = 238; goto _again;
	tr265:  sm->cs = 239; goto _again;
	tr266:  sm->cs = 240; goto _again;
	tr267:  sm->cs = 241; goto _again;
	tr268:  sm->cs = 242; goto _again;
	tr610:  sm->cs = 243; goto _again;
	tr270:  sm->cs = 244; goto _again;
	tr271:  sm->cs = 245; goto _again;
	tr272:  sm->cs = 246; goto _again;
	tr273:  sm->cs = 247; goto _again;
	tr274:  sm->cs = 248; goto _again;
	tr615:  sm->cs = 249; goto f4;
	tr277:  sm->cs = 250; goto _again;
	tr611:  sm->cs = 251; goto _again;
	tr279:  sm->cs = 252; goto _again;
	tr281:  sm->cs = 253; goto _again;
	tr282:  sm->cs = 254; goto _again;
	tr283:  sm->cs = 255; goto _again;
	tr280:  sm->cs = 256; goto _again;
	tr285:  sm->cs = 257; goto _again;
	tr286:  sm->cs = 258; goto _again;
	tr287:  sm->cs = 259; goto _again;
	tr623:  sm->cs = 260; goto _again;
	tr289:  sm->cs = 261; goto _again;
	tr290:  sm->cs = 262; goto _again;
	tr291:  sm->cs = 263; goto _again;
	tr292:  sm->cs = 264; goto _again;
	tr293:  sm->cs = 265; goto _again;
	tr626:  sm->cs = 266; goto _again;
	tr295:  sm->cs = 267; goto _again;
	tr296:  sm->cs = 268; goto _again;
	tr297:  sm->cs = 269; goto _again;
	tr298:  sm->cs = 270; goto _again;
	tr299:  sm->cs = 271; goto _again;
	tr629:  sm->cs = 272; goto f4;
	tr302:  sm->cs = 273; goto _again;
	tr627:  sm->cs = 274; goto _again;
	tr304:  sm->cs = 275; goto _again;
	tr305:  sm->cs = 276; goto _again;
	tr306:  sm->cs = 277; goto _again;
	tr307:  sm->cs = 278; goto _again;
	tr308:  sm->cs = 279; goto _again;
	tr309:  sm->cs = 280; goto _again;
	tr310:  sm->cs = 281; goto _again;
	tr635:  sm->cs = 282; goto _again;
	tr312:  sm->cs = 283; goto _again;
	tr313:  sm->cs = 284; goto _again;
	tr314:  sm->cs = 285; goto _again;
	tr315:  sm->cs = 286; goto _again;
	tr638:  sm->cs = 287; goto _again;
	tr317:  sm->cs = 288; goto _again;
	tr318:  sm->cs = 289; goto _again;
	tr319:  sm->cs = 290; goto _again;
	tr320:  sm->cs = 291; goto _again;
	tr641:  sm->cs = 292; goto _again;
	tr322:  sm->cs = 293; goto _again;
	tr323:  sm->cs = 294; goto _again;
	tr331:  sm->cs = 295; goto _again;
	tr332:  sm->cs = 296; goto _again;
	tr333:  sm->cs = 297; goto _again;
	tr324:  sm->cs = 298; goto _again;
	tr335:  sm->cs = 299; goto _again;
	tr336:  sm->cs = 300; goto _again;
	tr337:  sm->cs = 301; goto _again;
	tr338:  sm->cs = 302; goto _again;
	tr339:  sm->cs = 303; goto _again;
	tr325:  sm->cs = 304; goto _again;
	tr326:  sm->cs = 305; goto _again;
	tr342:  sm->cs = 306; goto _again;
	tr343:  sm->cs = 307; goto _again;
	tr344:  sm->cs = 308; goto _again;
	tr345:  sm->cs = 309; goto _again;
	tr327:  sm->cs = 310; goto _again;
	tr347:  sm->cs = 311; goto _again;
	tr349:  sm->cs = 312; goto _again;
	tr350:  sm->cs = 313; goto _again;
	tr351:  sm->cs = 314; goto _again;
	tr352:  sm->cs = 315; goto _again;
	tr353:  sm->cs = 316; goto _again;
	tr354:  sm->cs = 317; goto _again;
	tr328:  sm->cs = 318; goto _again;
	tr356:  sm->cs = 319; goto _again;
	tr357:  sm->cs = 320; goto _again;
	tr358:  sm->cs = 321; goto _again;
	tr329:  sm->cs = 322; goto _again;
	tr642:  sm->cs = 323; goto _again;
	tr643:  sm->cs = 324; goto _again;
	tr364:  sm->cs = 325; goto _again;
	tr365:  sm->cs = 326; goto _again;
	tr366:  sm->cs = 327; goto _again;
	tr644:  sm->cs = 328; goto _again;
	tr368:  sm->cs = 329; goto _again;
	tr369:  sm->cs = 330; goto _again;
	tr370:  sm->cs = 331; goto _again;
	tr371:  sm->cs = 332; goto _again;
	tr372:  sm->cs = 333; goto _again;
	tr645:  sm->cs = 334; goto _again;
	tr646:  sm->cs = 335; goto _again;
	tr375:  sm->cs = 336; goto _again;
	tr376:  sm->cs = 337; goto _again;
	tr377:  sm->cs = 338; goto _again;
	tr378:  sm->cs = 339; goto _again;
	tr379:  sm->cs = 340; goto _again;
	tr380:  sm->cs = 341; goto _again;
	tr647:  sm->cs = 342; goto _again;
	tr382:  sm->cs = 343; goto _again;
	tr383:  sm->cs = 344; goto _again;
	tr384:  sm->cs = 345; goto _again;
	tr385:  sm->cs = 346; goto _again;
	tr648:  sm->cs = 347; goto _again;
	tr387:  sm->cs = 348; goto _again;
	tr389:  sm->cs = 349; goto _again;
	tr390:  sm->cs = 350; goto _again;
	tr391:  sm->cs = 351; goto _again;
	tr392:  sm->cs = 352; goto _again;
	tr393:  sm->cs = 353; goto _again;
	tr394:  sm->cs = 354; goto _again;
	tr649:  sm->cs = 355; goto _again;
	tr396:  sm->cs = 356; goto _again;
	tr650:  sm->cs = 357; goto _again;
	tr651:  sm->cs = 358; goto _again;
	tr401:  sm->cs = 359; goto _again;
	tr399:  sm->cs = 359; goto f7;
	tr402:  sm->cs = 360; goto f4;
	tr403:  sm->cs = 361; goto f4;
	tr406:  sm->cs = 362; goto _again;
	tr405:  sm->cs = 362; goto f3;
	tr407:  sm->cs = 363; goto f5;
	tr409:  sm->cs = 364; goto _again;
	tr400:  sm->cs = 364; goto f7;
	tr653:  sm->cs = 365; goto _again;
	tr410:  sm->cs = 366; goto _again;
	tr411:  sm->cs = 367; goto _again;
	tr412:  sm->cs = 368; goto _again;
	tr414:  sm->cs = 369; goto _again;
	tr415:  sm->cs = 370; goto _again;
	tr416:  sm->cs = 371; goto _again;
	tr417:  sm->cs = 372; goto _again;
	tr418:  sm->cs = 373; goto _again;
	tr413:  sm->cs = 374; goto _again;
	tr655:  sm->cs = 375; goto _again;
	tr421:  sm->cs = 376; goto _again;
	tr420:  sm->cs = 376; goto f7;
	tr422:  sm->cs = 377; goto f4;
	tr659:  sm->cs = 378; goto _again;
	tr425:  sm->cs = 379; goto _again;
	tr426:  sm->cs = 380; goto _again;
	tr427:  sm->cs = 381; goto _again;
	tr428:  sm->cs = 382; goto _again;
	tr663:  sm->cs = 383; goto _again;
	tr431:  sm->cs = 384; goto _again;
	tr432:  sm->cs = 385; goto _again;
	tr433:  sm->cs = 386; goto _again;
	tr434:  sm->cs = 387; goto _again;
	tr435:  sm->cs = 388; goto _again;
	tr436:  sm->cs = 389; goto _again;
	tr437:  sm->cs = 390; goto _again;
	tr667:  sm->cs = 391; goto _again;
	tr440:  sm->cs = 392; goto _again;
	tr441:  sm->cs = 393; goto _again;
	tr445:  sm->cs = 394; goto _again;
	tr446:  sm->cs = 395; goto _again;
	tr447:  sm->cs = 396; goto _again;
	tr442:  sm->cs = 397; goto _again;
	tr449:  sm->cs = 398; goto _again;
	tr450:  sm->cs = 399; goto _again;
	tr451:  sm->cs = 400; goto _again;
	tr443:  sm->cs = 401; goto _again;
	tr453:  sm->cs = 402; goto _again;
	tr454:  sm->cs = 403; goto _again;
	tr455:  sm->cs = 404; goto _again;
	tr444:  sm->cs = 405; goto _again;
	tr668:  sm->cs = 406; goto _again;
	tr458:  sm->cs = 407; goto _again;
	tr462:  sm->cs = 408; goto _again;
	tr463:  sm->cs = 409; goto _again;
	tr464:  sm->cs = 410; goto _again;
	tr459:  sm->cs = 411; goto _again;
	tr460:  sm->cs = 412; goto _again;
	tr467:  sm->cs = 413; goto _again;
	tr469:  sm->cs = 414; goto _again;
	tr470:  sm->cs = 415; goto _again;
	tr461:  sm->cs = 416; goto _again;
	tr673:  sm->cs = 417; goto _again;
	tr478:  sm->cs = 418; goto f4;
	tr479:  sm->cs = 419; goto _again;
	tr0:  sm->cs = 420; goto f0;
	tr2:  sm->cs = 420; goto f2;
	tr20:  sm->cs = 420; goto f6;
	tr60:  sm->cs = 420; goto f8;
	tr61:  sm->cs = 420; goto f9;
	tr480:  sm->cs = 420; goto f74;
	tr487:  sm->cs = 420; goto f77;
	tr488:  sm->cs = 420; goto f78;
	tr491:  sm->cs = 420; goto f79;
	tr493:  sm->cs = 420; goto f80;
	tr502:  sm->cs = 420; goto f81;
	tr503:  sm->cs = 420; goto f82;
	tr505:  sm->cs = 420; goto f83;
	tr506:  sm->cs = 420; goto f84;
	tr507:  sm->cs = 420; goto f85;
	tr508:  sm->cs = 420; goto f86;
	tr1:  sm->cs = 421; goto f1;
	tr481:  sm->cs = 421; goto f75;
	tr482:  sm->cs = 422; goto _again;
	tr483:  sm->cs = 423; goto f28;
	tr489:  sm->cs = 424; goto _again;
	tr3:  sm->cs = 424; goto f3;
	tr4:  sm->cs = 425; goto f3;
	tr484:  sm->cs = 426; goto f76;
	tr492:  sm->cs = 427; goto _again;
	tr11:  sm->cs = 427; goto f5;
	tr494:  sm->cs = 428; goto _again;
	tr8:  sm->cs = 428; goto f4;
	tr485:  sm->cs = 429; goto f76;
	tr24:  sm->cs = 430; goto _again;
	tr504:  sm->cs = 431; goto _again;
	tr34:  sm->cs = 431; goto f4;
	tr31:  sm->cs = 432; goto _again;
	tr41:  sm->cs = 433; goto _again;
	tr46:  sm->cs = 434; goto _again;
	tr54:  sm->cs = 435; goto _again;
	tr62:  sm->cs = 436; goto f10;
	tr67:  sm->cs = 436; goto f11;
	tr68:  sm->cs = 436; goto f12;
	tr69:  sm->cs = 436; goto f13;
	tr70:  sm->cs = 436; goto f14;
	tr71:  sm->cs = 436; goto f15;
	tr72:  sm->cs = 436; goto f16;
	tr73:  sm->cs = 436; goto f17;
	tr74:  sm->cs = 436; goto f18;
	tr509:  sm->cs = 436; goto f87;
	tr511:  sm->cs = 436; goto f88;
	tr510:  sm->cs = 437; goto f76;
	tr75:  sm->cs = 438; goto f19;
	tr77:  sm->cs = 438; goto f21;
	tr82:  sm->cs = 438; goto f22;
	tr99:  sm->cs = 438; goto f24;
	tr122:  sm->cs = 438; goto f25;
	tr134:  sm->cs = 438; goto f26;
	tr276:  sm->cs = 438; goto f29;
	tr301:  sm->cs = 438; goto f30;
	tr330:  sm->cs = 438; goto f31;
	tr334:  sm->cs = 438; goto f32;
	tr340:  sm->cs = 438; goto f33;
	tr341:  sm->cs = 438; goto f34;
	tr348:  sm->cs = 438; goto f35;
	tr355:  sm->cs = 438; goto f36;
	tr359:  sm->cs = 438; goto f37;
	tr360:  sm->cs = 438; goto f38;
	tr361:  sm->cs = 438; goto f39;
	tr362:  sm->cs = 438; goto f40;
	tr363:  sm->cs = 438; goto f41;
	tr367:  sm->cs = 438; goto f42;
	tr373:  sm->cs = 438; goto f43;
	tr374:  sm->cs = 438; goto f44;
	tr381:  sm->cs = 438; goto f45;
	tr386:  sm->cs = 438; goto f46;
	tr388:  sm->cs = 438; goto f47;
	tr395:  sm->cs = 438; goto f48;
	tr397:  sm->cs = 438; goto f49;
	tr398:  sm->cs = 438; goto f50;
	tr404:  sm->cs = 438; goto f51;
	tr408:  sm->cs = 438; goto f52;
	tr423:  sm->cs = 438; goto f54;
	tr517:  sm->cs = 438; goto f89;
	tr539:  sm->cs = 438; goto f92;
	tr542:  sm->cs = 438; goto f93;
	tr543:  sm->cs = 438; goto f94;
	tr545:  sm->cs = 438; goto f95;
	tr546:  sm->cs = 438; goto f96;
	tr548:  sm->cs = 438; goto f97;
	tr555:  sm->cs = 438; goto f99;
	tr557:  sm->cs = 438; goto f100;
	tr562:  sm->cs = 438; goto f102;
	tr564:  sm->cs = 438; goto f103;
	tr566:  sm->cs = 438; goto f104;
	tr568:  sm->cs = 438; goto f105;
	tr572:  sm->cs = 438; goto f106;
	tr574:  sm->cs = 438; goto f107;
	tr577:  sm->cs = 438; goto f108;
	tr580:  sm->cs = 438; goto f109;
	tr586:  sm->cs = 438; goto f110;
	tr588:  sm->cs = 438; goto f111;
	tr590:  sm->cs = 438; goto f112;
	tr592:  sm->cs = 438; goto f113;
	tr596:  sm->cs = 438; goto f114;
	tr598:  sm->cs = 438; goto f115;
	tr601:  sm->cs = 438; goto f116;
	tr605:  sm->cs = 438; goto f117;
	tr607:  sm->cs = 438; goto f118;
	tr612:  sm->cs = 438; goto f119;
	tr614:  sm->cs = 438; goto f120;
	tr617:  sm->cs = 438; goto f121;
	tr619:  sm->cs = 438; goto f122;
	tr621:  sm->cs = 438; goto f123;
	tr624:  sm->cs = 438; goto f124;
	tr628:  sm->cs = 438; goto f125;
	tr631:  sm->cs = 438; goto f126;
	tr633:  sm->cs = 438; goto f127;
	tr636:  sm->cs = 438; goto f128;
	tr639:  sm->cs = 438; goto f129;
	tr652:  sm->cs = 438; goto f130;
	tr654:  sm->cs = 438; goto f131;
	tr518:  sm->cs = 439; goto f90;
	tr76:  sm->cs = 440; goto f20;
	tr544:  sm->cs = 441; goto _again;
	tr80:  sm->cs = 441; goto f3;
	tr81:  sm->cs = 442; goto f3;
	tr519:  sm->cs = 443; goto _again;
	tr520:  sm->cs = 444; goto f91;
	tr92:  sm->cs = 445; goto f23;
	tr521:  sm->cs = 446; goto f76;
	tr522:  sm->cs = 447; goto f91;
	tr135:  sm->cs = 448; goto f27;
	tr558:  sm->cs = 448; goto f101;
	tr554:  sm->cs = 449; goto f98;
	tr523:  sm->cs = 450; goto f76;
	tr563:  sm->cs = 451; goto _again;
	tr143:  sm->cs = 451; goto f7;
	tr565:  sm->cs = 452; goto _again;
	tr150:  sm->cs = 452; goto f7;
	tr567:  sm->cs = 453; goto _again;
	tr158:  sm->cs = 453; goto f7;
	tr569:  sm->cs = 454; goto _again;
	tr167:  sm->cs = 454; goto f7;
	tr524:  sm->cs = 455; goto f76;
	tr573:  sm->cs = 456; goto _again;
	tr171:  sm->cs = 456; goto f7;
	tr575:  sm->cs = 457; goto _again;
	tr175:  sm->cs = 457; goto f7;
	tr525:  sm->cs = 458; goto f76;
	tr578:  sm->cs = 459; goto _again;
	tr183:  sm->cs = 459; goto f7;
	tr526:  sm->cs = 460; goto f76;
	tr581:  sm->cs = 461; goto _again;
	tr194:  sm->cs = 461; goto f7;
	tr527:  sm->cs = 462; goto f76;
	tr587:  sm->cs = 463; goto _again;
	tr203:  sm->cs = 463; goto f7;
	tr589:  sm->cs = 464; goto _again;
	tr212:  sm->cs = 464; goto f7;
	tr591:  sm->cs = 465; goto _again;
	tr217:  sm->cs = 465; goto f7;
	tr593:  sm->cs = 466; goto _again;
	tr223:  sm->cs = 466; goto f7;
	tr528:  sm->cs = 467; goto f76;
	tr597:  sm->cs = 468; goto _again;
	tr235:  sm->cs = 468; goto f7;
	tr599:  sm->cs = 469; goto _again;
	tr241:  sm->cs = 469; goto f7;
	tr529:  sm->cs = 470; goto f76;
	tr602:  sm->cs = 471; goto _again;
	tr252:  sm->cs = 471; goto f7;
	tr530:  sm->cs = 472; goto f76;
	tr606:  sm->cs = 473; goto _again;
	tr258:  sm->cs = 473; goto f7;
	tr608:  sm->cs = 474; goto _again;
	tr263:  sm->cs = 474; goto f7;
	tr531:  sm->cs = 475; goto f76;
	tr613:  sm->cs = 476; goto _again;
	tr269:  sm->cs = 476; goto f7;
	tr275:  sm->cs = 477; goto f28;
	tr616:  sm->cs = 477; goto f76;
	tr618:  sm->cs = 478; goto _again;
	tr278:  sm->cs = 478; goto f3;
	tr620:  sm->cs = 479; goto _again;
	tr284:  sm->cs = 479; goto f7;
	tr622:  sm->cs = 480; goto _again;
	tr288:  sm->cs = 480; goto f7;
	tr532:  sm->cs = 481; goto f76;
	tr625:  sm->cs = 482; goto _again;
	tr294:  sm->cs = 482; goto f7;
	tr533:  sm->cs = 483; goto f76;
	tr300:  sm->cs = 484; goto f28;
	tr630:  sm->cs = 484; goto f76;
	tr632:  sm->cs = 485; goto _again;
	tr303:  sm->cs = 485; goto f3;
	tr634:  sm->cs = 486; goto _again;
	tr311:  sm->cs = 486; goto f7;
	tr534:  sm->cs = 487; goto f76;
	tr637:  sm->cs = 488; goto _again;
	tr316:  sm->cs = 488; goto f7;
	tr535:  sm->cs = 489; goto f76;
	tr640:  sm->cs = 490; goto _again;
	tr321:  sm->cs = 490; goto f7;
	tr536:  sm->cs = 491; goto f76;
	tr346:  sm->cs = 492; goto _again;
	tr537:  sm->cs = 493; goto f91;
	tr419:  sm->cs = 494; goto f53;
	tr538:  sm->cs = 495; goto f76;
	tr424:  sm->cs = 496; goto f55;
	tr429:  sm->cs = 496; goto f56;
	tr656:  sm->cs = 496; goto f132;
	tr658:  sm->cs = 496; goto f133;
	tr657:  sm->cs = 497; goto f76;
	tr430:  sm->cs = 498; goto f57;
	tr438:  sm->cs = 498; goto f58;
	tr660:  sm->cs = 498; goto f134;
	tr662:  sm->cs = 498; goto f135;
	tr661:  sm->cs = 499; goto f76;
	tr439:  sm->cs = 500; goto f59;
	tr448:  sm->cs = 500; goto f60;
	tr452:  sm->cs = 500; goto f61;
	tr456:  sm->cs = 500; goto f62;
	tr457:  sm->cs = 500; goto f63;
	tr465:  sm->cs = 500; goto f64;
	tr466:  sm->cs = 500; goto f65;
	tr468:  sm->cs = 500; goto f66;
	tr471:  sm->cs = 500; goto f67;
	tr472:  sm->cs = 500; goto f68;
	tr664:  sm->cs = 500; goto f136;
	tr666:  sm->cs = 500; goto f137;
	tr665:  sm->cs = 501; goto f76;
	tr473:  sm->cs = 502; goto f69;
	tr475:  sm->cs = 502; goto f71;
	tr669:  sm->cs = 502; goto f138;
	tr674:  sm->cs = 502; goto f140;
	tr675:  sm->cs = 502; goto f141;
	tr474:  sm->cs = 503; goto f70;
	tr670:  sm->cs = 503; goto f139;
	tr671:  sm->cs = 504; goto _again;
	tr672:  sm->cs = 505; goto f28;
	tr676:  sm->cs = 506; goto _again;
	tr476:  sm->cs = 506; goto f3;
	tr477:  sm->cs = 507; goto f3;

f7:
#line 77 "ext/dtext/dtext.rl"
	{
  sm->a1 = sm->p;
}
	goto _again;
f4:
#line 81 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
	goto _again;
f3:
#line 85 "ext/dtext/dtext.rl"
	{
  sm->b1 = sm->p;
}
	goto _again;
f5:
#line 89 "ext/dtext/dtext.rl"
	{
  sm->b2 = sm->p;
}
	goto _again;
f76:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
	goto _again;
f15:
#line 167 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{ dstack_open_inline(sm,  INLINE_B, "<strong>"); }}
	goto _again;
f11:
#line 168 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{ dstack_close_inline(sm, INLINE_B, "</strong>"); }}
	goto _again;
f16:
#line 169 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{ dstack_open_inline(sm,  INLINE_I, "<em>"); }}
	goto _again;
f12:
#line 170 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{ dstack_close_inline(sm, INLINE_I, "</em>"); }}
	goto _again;
f17:
#line 171 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{ dstack_open_inline(sm,  INLINE_S, "<s>"); }}
	goto _again;
f13:
#line 172 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{ dstack_close_inline(sm, INLINE_S, "</s>"); }}
	goto _again;
f18:
#line 173 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{ dstack_open_inline(sm,  INLINE_U, "<u>"); }}
	goto _again;
f14:
#line 174 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{ dstack_close_inline(sm, INLINE_U, "</u>"); }}
	goto _again;
f87:
#line 175 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{ append_c_html_escaped(sm, (*( sm->p))); }}
	goto _again;
f88:
#line 175 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{ append_c_html_escaped(sm, (*( sm->p))); }}
	goto _again;
f10:
#line 175 "ext/dtext/dtext.rl"
	{{( sm->p) = ((( sm->te)))-1;}{ append_c_html_escaped(sm, (*( sm->p))); }}
	goto _again;
f54:
#line 291 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    append_link(sm, "", "<a rel=\"nofollow\" class=\"dtext-link dtext-post-search-link\" href=\"/posts?tags=");
  }}
	goto _again;
f51:
#line 295 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    append_wiki_link(sm, sm->a1, sm->a2 - sm->a1, sm->a1, sm->a2 - sm->a1);
  }}
	goto _again;
f52:
#line 299 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    append_wiki_link(sm, sm->a1, sm->a2 - sm->a1, sm->b1, sm->b2 - sm->b1);
  }}
	goto _again;
f24:
#line 317 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    if (!append_named_url(sm, sm->b1, sm->b2, sm->a1, sm->a2)) {
      {( sm->p)++; goto _out; }
    }
  }}
	goto _again;
f26:
#line 335 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    append_url(sm, sm->ts + 1, sm->te - 2, sm->ts + 1, sm->te - 2);
  }}
	goto _again;
f41:
#line 397 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{ dstack_open_inline(sm,  INLINE_B, "<strong>"); }}
	goto _again;
f31:
#line 398 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{ dstack_close_inline(sm, INLINE_B, "</strong>"); }}
	goto _again;
f44:
#line 399 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{ dstack_open_inline(sm,  INLINE_I, "<em>"); }}
	goto _again;
f34:
#line 400 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{ dstack_close_inline(sm, INLINE_I, "</em>"); }}
	goto _again;
f47:
#line 401 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{ dstack_open_inline(sm,  INLINE_S, "<s>"); }}
	goto _again;
f35:
#line 402 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{ dstack_close_inline(sm, INLINE_S, "</s>"); }}
	goto _again;
f50:
#line 403 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{ dstack_open_inline(sm,  INLINE_U, "<u>"); }}
	goto _again;
f40:
#line 404 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{ dstack_close_inline(sm, INLINE_U, "</u>"); }}
	goto _again;
f49:
#line 406 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_open_inline(sm, INLINE_TN, "<span class=\"tn\">");
  }}
	goto _again;
f39:
#line 410 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_close_before_block(sm);

    if (dstack_check(sm, INLINE_TN)) {
      dstack_close_inline(sm, INLINE_TN, "</span>");
    } else if (dstack_close_block(sm, BLOCK_TN, "</p>")) {
      { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)];goto _again;}
    }
  }}
	goto _again;
f42:
#line 420 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_open_inline(sm, INLINE_CODE, "<code>");
  }}
	goto _again;
f32:
#line 424 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_close_inline(sm, INLINE_CODE, "</code>");
  }}
	goto _again;
f48:
#line 428 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_open_inline(sm, INLINE_SPOILER, "<span class=\"spoiler\">");
  }}
	goto _again;
f36:
#line 432 "ext/dtext/dtext.rl"
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
f45:
#line 443 "ext/dtext/dtext.rl"
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
{( ((int *)sm->stack->data))[( sm->top)++] =  sm->cs;  sm->cs = 498;goto _again;}}
  }}
	goto _again;
f46:
#line 451 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    g_debug("inline [quote]");
    dstack_close_before_block(sm);
    {( sm->p) = (( sm->ts))-1;}
    { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)];goto _again;}
  }}
	goto _again;
f43:
#line 474 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    g_debug("inline [expand]");
    dstack_rewind(sm);
    {( sm->p) = (((sm->p - 7)))-1;}
    { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)];goto _again;}
  }}
	goto _again;
f33:
#line 481 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_close_before_block(sm);

    if (dstack_close_block(sm, BLOCK_EXPAND, "</div></div>")) {
      { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)];goto _again;}
    }
  }}
	goto _again;
f38:
#line 489 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    if (dstack_close_block(sm, BLOCK_TH, "</th>")) {
      { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)];goto _again;}
    }
  }}
	goto _again;
f37:
#line 495 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    if (dstack_close_block(sm, BLOCK_TD, "</td>")) {
      { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)];goto _again;}
    }
  }}
	goto _again;
f89:
#line 529 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    g_debug("inline char: %c", (*( sm->p)));
    append_c_html_escaped(sm, (*( sm->p)));
  }}
	goto _again;
f97:
#line 303 "ext/dtext/dtext.rl"
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
f131:
#line 323 "ext/dtext/dtext.rl"
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
f130:
#line 458 "ext/dtext/dtext.rl"
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
f93:
#line 501 "ext/dtext/dtext.rl"
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
f92:
#line 513 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    g_debug("inline newline");

    if (sm->header_mode) {
      sm->header_mode = false;
      dstack_rewind(sm);
      { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)];goto _again;}
    } else {
      append(sm, true, "<br>");
    }
  }}
	goto _again;
f95:
#line 525 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append_c(sm, ' ');
  }}
	goto _again;
f96:
#line 529 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    g_debug("inline char: %c", (*( sm->p)));
    append_c_html_escaped(sm, (*( sm->p)));
  }}
	goto _again;
f30:
#line 199 "ext/dtext/dtext.rl"
	{{( sm->p) = ((( sm->te)))-1;}{
    append_link(sm, "topic #", "<a class=\"dtext-link dtext-id-link dtext-forum-topic-id-link\" href=\"/forum_topics/");
  }}
	goto _again;
f29:
#line 275 "ext/dtext/dtext.rl"
	{{( sm->p) = ((( sm->te)))-1;}{
    append_link(sm, "pixiv #", "<a class=\"dtext-link dtext-id-link dtext-pixiv-id-link\" href=\"http://www.pixiv.net/member_illust.php?mode=medium&illust_id=");
  }}
	goto _again;
f21:
#line 513 "ext/dtext/dtext.rl"
	{{( sm->p) = ((( sm->te)))-1;}{
    g_debug("inline newline");

    if (sm->header_mode) {
      sm->header_mode = false;
      dstack_rewind(sm);
      { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)];goto _again;}
    } else {
      append(sm, true, "<br>");
    }
  }}
	goto _again;
f22:
#line 529 "ext/dtext/dtext.rl"
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
	case 43:
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
	case 45:
	{{( sm->p) = ((( sm->te)))-1;}
    append_segment_html_escaped(sm, sm->ts, sm->te - 1);
  }
	break;
	case 46:
	{{( sm->p) = ((( sm->te)))-1;}
    if (!sm->f_mentions || (sm->a1 > sm->pb && sm->a1 - 1 > sm->pb && sm->a1[-2] != ' ' && sm->a1[-2] != '\r' && sm->a1[-2] != '\n')) {
      // handle emails
      append_c(sm, '@');
      {( sm->p) = (( sm->a1))-1;}
    } else {
      const char* match_end = sm->a2 - 1;
      const char* name_start = sm->a1;
      const char* name_end = find_boundary_c(match_end);

      append(sm, true, "<a rel=\"nofollow\" href=\"/users?name=");
      append_segment_uri_escaped(sm, name_start, name_end);
      append(sm, true, "\">");
      append_c(sm, '@');
      append_segment_html_escaped(sm, name_start, name_end);
      append(sm, true, "</a>");

      if (name_end < match_end) {
        append_segment_html_escaped(sm, name_end + 1, match_end);
      }
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
      append(sm, true, "<br>");
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
f56:
#line 536 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    if (dstack_check(sm, BLOCK_CODE)) {
      dstack_rewind(sm);
    } else {
      append(sm, true, "[/code]");
    }
    { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)];goto _again;}
  }}
	goto _again;
f132:
#line 545 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    append_c_html_escaped(sm, (*( sm->p)));
  }}
	goto _again;
f133:
#line 545 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append_c_html_escaped(sm, (*( sm->p)));
  }}
	goto _again;
f55:
#line 545 "ext/dtext/dtext.rl"
	{{( sm->p) = ((( sm->te)))-1;}{
    append_c_html_escaped(sm, (*( sm->p)));
  }}
	goto _again;
f58:
#line 551 "ext/dtext/dtext.rl"
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
      append(sm, true, "[/nodtext]");
    }
  }}
	goto _again;
f134:
#line 568 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    append_c_html_escaped(sm, (*( sm->p)));
  }}
	goto _again;
f135:
#line 568 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append_c_html_escaped(sm, (*( sm->p)));
  }}
	goto _again;
f57:
#line 568 "ext/dtext/dtext.rl"
	{{( sm->p) = ((( sm->te)))-1;}{
    append_c_html_escaped(sm, (*( sm->p)));
  }}
	goto _again;
f67:
#line 574 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_open_block(sm, BLOCK_THEAD, "<thead>");
  }}
	goto _again;
f62:
#line 578 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_close_block(sm, BLOCK_THEAD, "</thead>");
  }}
	goto _again;
f64:
#line 582 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_open_block(sm, BLOCK_TBODY, "<tbody>");
  }}
	goto _again;
f61:
#line 586 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_close_block(sm, BLOCK_TBODY, "</tbody>");
  }}
	goto _again;
f66:
#line 590 "ext/dtext/dtext.rl"
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
{( ((int *)sm->stack->data))[( sm->top)++] =  sm->cs;  sm->cs = 438;goto _again;}}
  }}
	goto _again;
f68:
#line 595 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_open_block(sm, BLOCK_TR, "<tr>");
  }}
	goto _again;
f63:
#line 599 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_close_block(sm, BLOCK_TR, "</tr>");
  }}
	goto _again;
f65:
#line 603 "ext/dtext/dtext.rl"
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
{( ((int *)sm->stack->data))[( sm->top)++] =  sm->cs;  sm->cs = 438;goto _again;}}
  }}
	goto _again;
f60:
#line 608 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    if (dstack_close_block(sm, BLOCK_TABLE, "</table>")) {
      { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)];goto _again;}
    }
  }}
	goto _again;
f136:
#line 614 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;}
	goto _again;
f137:
#line 614 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;}
	goto _again;
f59:
#line 614 "ext/dtext/dtext.rl"
	{{( sm->p) = ((( sm->te)))-1;}}
	goto _again;
f138:
#line 659 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_rewind(sm);
    ( sm->p)--;
    { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)];goto _again;}
  }}
	goto _again;
f140:
#line 659 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    dstack_rewind(sm);
    ( sm->p)--;
    { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)];goto _again;}
  }}
	goto _again;
f71:
#line 659 "ext/dtext/dtext.rl"
	{{( sm->p) = ((( sm->te)))-1;}{
    dstack_rewind(sm);
    ( sm->p)--;
    { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)];goto _again;}
  }}
	goto _again;
f69:
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
f6:
#line 789 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    g_debug("block [/spoiler]");
    dstack_close_before_block(sm);
    if (dstack_check(sm, BLOCK_SPOILER)) {
      g_debug("  rewind");
      dstack_rewind(sm);
    }
  }}
	goto _again;
f8:
#line 831 "ext/dtext/dtext.rl"
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
{( ((int *)sm->stack->data))[( sm->top)++] =  sm->cs;  sm->cs = 500;goto _again;}}
  }}
	goto _again;
f9:
#line 837 "ext/dtext/dtext.rl"
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
{( ((int *)sm->stack->data))[( sm->top)++] =  sm->cs;  sm->cs = 438;goto _again;}}
  }}
	goto _again;
f74:
#line 869 "ext/dtext/dtext.rl"
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
{( ((int *)sm->stack->data))[( sm->top)++] =  sm->cs;  sm->cs = 438;goto _again;}}
  }}
	goto _again;
f79:
#line 667 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    char header = *sm->a1;
    g_autoptr(GString) id_name = g_string_new_len(sm->b1, sm->b2 - sm->b1);
    id_name = g_string_prepend(id_name, "dtext-");

    if (sm->f_inline) {
      header = '6';
    }

    if (sm->f_strip) {
      dstack_push(sm, BLOCK_STRIP);
    }

    if (!sm->f_strip) {
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
{( ((int *)sm->stack->data))[( sm->top)++] =  sm->cs;  sm->cs = 438;goto _again;}}
  }}
	goto _again;
f80:
#line 730 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    char header = *sm->a1;

    if (sm->f_inline) {
      header = '6';
    }

    if (sm->f_strip) {
      dstack_push(sm, BLOCK_STRIP);
    }

    if (!sm->f_strip) {
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
{( ((int *)sm->stack->data))[( sm->top)++] =  sm->cs;  sm->cs = 438;goto _again;}}
  }}
	goto _again;
f85:
#line 779 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    dstack_close_before_block(sm);
    dstack_open_block(sm, BLOCK_QUOTE, "<blockquote>");
  }}
	goto _again;
f86:
#line 784 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    dstack_close_before_block(sm);
    dstack_open_block(sm, BLOCK_SPOILER, "<div class=\"spoiler\">");
  }}
	goto _again;
f81:
#line 798 "ext/dtext/dtext.rl"
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
{( ((int *)sm->stack->data))[( sm->top)++] =  sm->cs;  sm->cs = 496;goto _again;}}
  }}
	goto _again;
f83:
#line 804 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    dstack_close_before_block(sm);
    const char* html = "<div class=\"expandable\"><div class=\"expandable-header\">"
                       "<input type=\"button\" value=\"Show\" class=\"expandable-button\"/></div>"
                       "<div class=\"expandable-content\">";
    dstack_open_block(sm, BLOCK_EXPAND, html);
  }}
	goto _again;
f82:
#line 812 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    g_debug("block [expand=]");
    dstack_close_before_block(sm);
    dstack_push(sm, BLOCK_EXPAND);
    append_block(sm, "<div class=\"expandable\"><div class=\"expandable-header\">");
    append(sm, true, "<span>");
    append_segment_html_escaped(sm, sm->a1, sm->a2 - 1);
    append(sm, true, "</span>");
    append_block(sm, "<input type=\"button\" value=\"Show\" class=\"expandable-button\"/></div>");
    append_block(sm, "<div class=\"expandable-content\">");
  }}
	goto _again;
f84:
#line 824 "ext/dtext/dtext.rl"
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
{( ((int *)sm->stack->data))[( sm->top)++] =  sm->cs;  sm->cs = 498;goto _again;}}
  }}
	goto _again;
f77:
#line 869 "ext/dtext/dtext.rl"
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
{( ((int *)sm->stack->data))[( sm->top)++] =  sm->cs;  sm->cs = 438;goto _again;}}
  }}
	goto _again;
f2:
#line 869 "ext/dtext/dtext.rl"
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
{( ((int *)sm->stack->data))[( sm->top)++] =  sm->cs;  sm->cs = 438;goto _again;}}
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
f25:
#line 81 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
#line 367 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    if (sm->f_mentions) {
      append(sm, true, "<a rel=\"nofollow\" href=\"/users?name=");
      append_segment_uri_escaped(sm, sm->a1, sm->a2 - 1);
      append(sm, true, "\">");
      append_c(sm, '@');
      append_segment_html_escaped(sm, sm->a1, sm->a2 - 1);
      append(sm, true, "</a>");
    }
  }}
	goto _again;
f123:
#line 81 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
#line 179 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append_link(sm, "post #", "<a class=\"dtext-link dtext-id-link dtext-post-id-link\" href=\"/posts/");
  }}
	goto _again;
f103:
#line 81 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
#line 183 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append_link(sm, "appeal #", "<a class=\"dtext-link dtext-id-link dtext-post-appeal-id-link\" href=\"/post_appeals/");
  }}
	goto _again;
f112:
#line 81 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
#line 187 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append_link(sm, "flag #", "<a class=\"dtext-link dtext-id-link dtext-post-flag-id-link\" href=\"/post_flags/");
  }}
	goto _again;
f118:
#line 81 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
#line 191 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append_link(sm, "note #", "<a class=\"dtext-link dtext-id-link dtext-note-id-link\" href=\"/notes/");
  }}
	goto _again;
f113:
#line 81 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
#line 195 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append_link(sm, "forum #", "<a class=\"dtext-link dtext-id-link dtext-forum-post-id-link\" href=\"/forum_posts/");
  }}
	goto _again;
f125:
#line 81 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
#line 199 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append_link(sm, "topic #", "<a class=\"dtext-link dtext-id-link dtext-forum-topic-id-link\" href=\"/forum_topics/");
  }}
	goto _again;
f108:
#line 81 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
#line 207 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append_link(sm, "comment #", "<a class=\"dtext-link dtext-id-link dtext-comment-id-link\" href=\"/comments/");
  }}
	goto _again;
f122:
#line 81 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
#line 211 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append_link(sm, "pool #", "<a class=\"dtext-link dtext-id-link dtext-pool-id-link\" href=\"/pools/");
  }}
	goto _again;
f128:
#line 81 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
#line 215 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append_link(sm, "user #", "<a class=\"dtext-link dtext-id-link dtext-user-id-link\" href=\"/users/");
  }}
	goto _again;
f104:
#line 81 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
#line 219 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append_link(sm, "artist #", "<a class=\"dtext-link dtext-id-link dtext-artist-id-link\" href=\"/artists/");
  }}
	goto _again;
f106:
#line 81 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
#line 223 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append_link(sm, "ban #", "<a class=\"dtext-link dtext-id-link dtext-ban-id-link\" href=\"/bans/");
  }}
	goto _again;
f107:
#line 81 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
#line 227 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append_link(sm, "BUR #", "<a class=\"dtext-link dtext-id-link dtext-bulk-update-request-id-link\" href=\"/bulk_update_requests/");
  }}
	goto _again;
f102:
#line 81 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
#line 231 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append_link(sm, "alias #", "<a class=\"dtext-link dtext-id-link dtext-tag-alias-id-link\" href=\"/tag_aliases/");
  }}
	goto _again;
f114:
#line 81 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
#line 235 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append_link(sm, "implication #", "<a class=\"dtext-link dtext-id-link dtext-tag-implication-id-link\" href=\"/tag_implications/");
  }}
	goto _again;
f110:
#line 81 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
#line 239 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append_link(sm, "favgroup #", "<a class=\"dtext-link dtext-id-link dtext-favorite-group-id-link\" href=\"/favorite_groups/");
  }}
	goto _again;
f116:
#line 81 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
#line 243 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append_link(sm, "mod action #", "<a class=\"dtext-link dtext-id-link dtext-mod-action-id-link\" href=\"/mod_actions/");
  }}
	goto _again;
f111:
#line 81 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
#line 247 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append_link(sm, "feedback #", "<a class=\"dtext-link dtext-id-link dtext-user-feedback-id-link\" href=\"/user_feedbacks/");
  }}
	goto _again;
f129:
#line 81 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
#line 251 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append_link(sm, "wiki #", "<a class=\"dtext-link dtext-id-link dtext-wiki-page-id-link\" href=\"/wiki_pages/");
  }}
	goto _again;
f115:
#line 81 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
#line 255 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append_link(sm, "issue #", "<a class=\"dtext-link dtext-id-link dtext-github-id-link\" href=\"https://github.com/r888888888/danbooru/issues/");
  }}
	goto _again;
f105:
#line 81 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
#line 259 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append_link(sm, "artstation #", "<a class=\"dtext-link dtext-id-link dtext-artstation-id-link\" href=\"https://www.artstation.com/artwork/");
  }}
	goto _again;
f109:
#line 81 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
#line 263 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append_link(sm, "deviantart #", "<a class=\"dtext-link dtext-id-link dtext-deviantart-id-link\" href=\"https://deviantart.com/deviation/");
  }}
	goto _again;
f117:
#line 81 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
#line 267 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append_link(sm, "nijie #", "<a class=\"dtext-link dtext-id-link dtext-nijie-id-link\" href=\"https://nijie.info/view.php?id=");
  }}
	goto _again;
f119:
#line 81 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
#line 271 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append_link(sm, "pawoo #", "<a class=\"dtext-link dtext-id-link dtext-pawoo-id-link\" href=\"https://pawoo.net/web/statuses/");
  }}
	goto _again;
f120:
#line 81 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
#line 275 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append_link(sm, "pixiv #", "<a class=\"dtext-link dtext-id-link dtext-pixiv-id-link\" href=\"http://www.pixiv.net/member_illust.php?mode=medium&illust_id=");
  }}
	goto _again;
f124:
#line 81 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
#line 283 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append_link(sm, "seiga #", "<a class=\"dtext-link dtext-id-link dtext-seiga-id-link\" href=\"http://seiga.nicovideo.jp/seiga/im");
  }}
	goto _again;
f127:
#line 81 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
#line 287 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append_link(sm, "twitter #", "<a class=\"dtext-link dtext-id-link dtext-twitter-id-link\" href=\"https://twitter.com/i/web/status/");
  }}
	goto _again;
f100:
#line 81 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
#line 344 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    if (!sm->f_mentions || (sm->a1 > sm->pb && sm->a1 - 1 > sm->pb && sm->a1[-2] != ' ' && sm->a1[-2] != '\r' && sm->a1[-2] != '\n')) {
      // handle emails
      append_c(sm, '@');
      {( sm->p) = (( sm->a1))-1;}
    } else {
      const char* match_end = sm->a2 - 1;
      const char* name_start = sm->a1;
      const char* name_end = find_boundary_c(match_end);

      append(sm, true, "<a rel=\"nofollow\" href=\"/users?name=");
      append_segment_uri_escaped(sm, name_start, name_end);
      append(sm, true, "\">");
      append_c(sm, '@');
      append_segment_html_escaped(sm, name_start, name_end);
      append(sm, true, "</a>");

      if (name_end < match_end) {
        append_segment_html_escaped(sm, name_end + 1, match_end);
      }
    }
  }}
	goto _again;
f99:
#line 81 "ext/dtext/dtext.rl"
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
	case 43:
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
	case 45:
	{{( sm->p) = ((( sm->te)))-1;}
    append_segment_html_escaped(sm, sm->ts, sm->te - 1);
  }
	break;
	case 46:
	{{( sm->p) = ((( sm->te)))-1;}
    if (!sm->f_mentions || (sm->a1 > sm->pb && sm->a1 - 1 > sm->pb && sm->a1[-2] != ' ' && sm->a1[-2] != '\r' && sm->a1[-2] != '\n')) {
      // handle emails
      append_c(sm, '@');
      {( sm->p) = (( sm->a1))-1;}
    } else {
      const char* match_end = sm->a2 - 1;
      const char* name_start = sm->a1;
      const char* name_end = find_boundary_c(match_end);

      append(sm, true, "<a rel=\"nofollow\" href=\"/users?name=");
      append_segment_uri_escaped(sm, name_start, name_end);
      append(sm, true, "\">");
      append_c(sm, '@');
      append_segment_html_escaped(sm, name_start, name_end);
      append(sm, true, "</a>");

      if (name_end < match_end) {
        append_segment_html_escaped(sm, name_end + 1, match_end);
      }
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
      append(sm, true, "<br>");
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
f126:
#line 89 "ext/dtext/dtext.rl"
	{
  sm->b2 = sm->p;
}
#line 203 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append_paged_link(sm, "topic #", "<a class=\"dtext-link dtext-id-link dtext-forum-topic-id-link\" href=\"/forum_topics/", "?page=");
  }}
	goto _again;
f121:
#line 89 "ext/dtext/dtext.rl"
	{
  sm->b2 = sm->p;
}
#line 279 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append_paged_link(sm, "pixiv #", "<a class=\"dtext-link dtext-id-link dtext-pixiv-id-link\" href=\"http://www.pixiv.net/member_illust.php?mode=manga_big&illust_id=", "&page=");
  }}
	goto _again;
f94:
#line 89 "ext/dtext/dtext.rl"
	{
  sm->b2 = sm->p;
}
#line 378 "ext/dtext/dtext.rl"
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
     sm->cs = 502;
  }}
	goto _again;
f141:
#line 89 "ext/dtext/dtext.rl"
	{
  sm->b2 = sm->p;
}
#line 618 "ext/dtext/dtext.rl"
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
{( ((int *)sm->stack->data))[( sm->top)++] =  sm->cs;  sm->cs = 438;goto _again;}}
  }}
	goto _again;
f78:
#line 89 "ext/dtext/dtext.rl"
	{
  sm->b2 = sm->p;
}
#line 842 "ext/dtext/dtext.rl"
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
{( ((int *)sm->stack->data))[( sm->top)++] =  sm->cs;  sm->cs = 502;goto _again;}}
  }}
	goto _again;
f28:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 77 "ext/dtext/dtext.rl"
	{
  sm->a1 = sm->p;
}
	goto _again;
f53:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 323 "ext/dtext/dtext.rl"
	{( sm->act) = 43;}
	goto _again;
f101:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 340 "ext/dtext/dtext.rl"
	{( sm->act) = 45;}
	goto _again;
f27:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 344 "ext/dtext/dtext.rl"
	{( sm->act) = 46;}
	goto _again;
f20:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 501 "ext/dtext/dtext.rl"
	{( sm->act) = 70;}
	goto _again;
f90:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 513 "ext/dtext/dtext.rl"
	{( sm->act) = 71;}
	goto _again;
f91:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 529 "ext/dtext/dtext.rl"
	{( sm->act) = 73;}
	goto _again;
f70:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 651 "ext/dtext/dtext.rl"
	{( sm->act) = 89;}
	goto _again;
f139:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 657 "ext/dtext/dtext.rl"
	{( sm->act) = 90;}
	goto _again;
f1:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 852 "ext/dtext/dtext.rl"
	{( sm->act) = 104;}
	goto _again;
f75:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 865 "ext/dtext/dtext.rl"
	{( sm->act) = 105;}
	goto _again;
f98:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 77 "ext/dtext/dtext.rl"
	{
  sm->a1 = sm->p;
}
#line 344 "ext/dtext/dtext.rl"
	{( sm->act) = 46;}
	goto _again;
f23:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 89 "ext/dtext/dtext.rl"
	{
  sm->b2 = sm->p;
}
#line 303 "ext/dtext/dtext.rl"
	{( sm->act) = 41;}
	goto _again;

_again:
	switch ( _dtext_to_state_actions[ sm->cs] ) {
	case 73:
#line 1 "NONE"
	{( sm->ts) = 0;}
	break;
#line 5888 "ext/dtext/dtext.c"
	}

	if ( ++( sm->p) != ( sm->pe) )
		goto _resume;
	_test_eof: {}
	if ( ( sm->p) == ( sm->eof) )
	{
	switch (  sm->cs ) {
	case 421: goto tr0;
	case 0: goto tr0;
	case 422: goto tr487;
	case 423: goto tr487;
	case 1: goto tr2;
	case 424: goto tr488;
	case 425: goto tr488;
	case 2: goto tr2;
	case 426: goto tr487;
	case 3: goto tr2;
	case 4: goto tr2;
	case 5: goto tr2;
	case 427: goto tr491;
	case 428: goto tr493;
	case 429: goto tr487;
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
	case 430: goto tr502;
	case 19: goto tr2;
	case 20: goto tr2;
	case 21: goto tr2;
	case 22: goto tr2;
	case 23: goto tr2;
	case 24: goto tr2;
	case 25: goto tr2;
	case 26: goto tr2;
	case 431: goto tr503;
	case 432: goto tr505;
	case 27: goto tr2;
	case 28: goto tr2;
	case 29: goto tr2;
	case 30: goto tr2;
	case 31: goto tr2;
	case 32: goto tr2;
	case 33: goto tr2;
	case 433: goto tr506;
	case 34: goto tr2;
	case 35: goto tr2;
	case 36: goto tr2;
	case 37: goto tr2;
	case 38: goto tr2;
	case 434: goto tr507;
	case 39: goto tr2;
	case 40: goto tr2;
	case 41: goto tr2;
	case 42: goto tr2;
	case 43: goto tr2;
	case 44: goto tr2;
	case 45: goto tr2;
	case 46: goto tr2;
	case 435: goto tr508;
	case 47: goto tr2;
	case 48: goto tr2;
	case 49: goto tr2;
	case 50: goto tr2;
	case 51: goto tr2;
	case 52: goto tr2;
	case 437: goto tr511;
	case 53: goto tr62;
	case 54: goto tr62;
	case 55: goto tr62;
	case 56: goto tr62;
	case 57: goto tr62;
	case 58: goto tr62;
	case 59: goto tr62;
	case 60: goto tr62;
	case 61: goto tr62;
	case 439: goto tr539;
	case 440: goto tr542;
	case 62: goto tr75;
	case 63: goto tr77;
	case 64: goto tr77;
	case 441: goto tr543;
	case 442: goto tr543;
	case 443: goto tr545;
	case 444: goto tr546;
	case 65: goto tr82;
	case 66: goto tr82;
	case 67: goto tr82;
	case 68: goto tr82;
	case 69: goto tr75;
	case 445: goto tr548;
	case 70: goto tr75;
	case 71: goto tr75;
	case 72: goto tr82;
	case 73: goto tr82;
	case 74: goto tr82;
	case 75: goto tr82;
	case 76: goto tr82;
	case 77: goto tr82;
	case 78: goto tr82;
	case 79: goto tr82;
	case 80: goto tr82;
	case 81: goto tr82;
	case 82: goto tr82;
	case 83: goto tr82;
	case 84: goto tr82;
	case 85: goto tr82;
	case 86: goto tr82;
	case 87: goto tr82;
	case 88: goto tr82;
	case 89: goto tr82;
	case 90: goto tr82;
	case 91: goto tr82;
	case 446: goto tr546;
	case 92: goto tr82;
	case 93: goto tr82;
	case 94: goto tr82;
	case 95: goto tr82;
	case 96: goto tr82;
	case 97: goto tr82;
	case 98: goto tr82;
	case 99: goto tr82;
	case 100: goto tr82;
	case 101: goto tr82;
	case 102: goto tr82;
	case 103: goto tr82;
	case 104: goto tr82;
	case 105: goto tr82;
	case 106: goto tr82;
	case 107: goto tr82;
	case 108: goto tr82;
	case 447: goto tr546;
	case 109: goto tr75;
	case 448: goto tr555;
	case 110: goto tr75;
	case 111: goto tr75;
	case 449: goto tr557;
	case 450: goto tr546;
	case 112: goto tr82;
	case 113: goto tr82;
	case 114: goto tr82;
	case 115: goto tr82;
	case 116: goto tr82;
	case 117: goto tr82;
	case 451: goto tr562;
	case 118: goto tr82;
	case 119: goto tr82;
	case 120: goto tr82;
	case 121: goto tr82;
	case 122: goto tr82;
	case 123: goto tr82;
	case 124: goto tr82;
	case 452: goto tr564;
	case 125: goto tr82;
	case 126: goto tr82;
	case 127: goto tr82;
	case 128: goto tr82;
	case 129: goto tr82;
	case 130: goto tr82;
	case 131: goto tr82;
	case 453: goto tr566;
	case 132: goto tr82;
	case 133: goto tr82;
	case 134: goto tr82;
	case 135: goto tr82;
	case 136: goto tr82;
	case 137: goto tr82;
	case 138: goto tr82;
	case 139: goto tr82;
	case 140: goto tr82;
	case 454: goto tr568;
	case 455: goto tr546;
	case 141: goto tr82;
	case 142: goto tr82;
	case 143: goto tr82;
	case 144: goto tr82;
	case 456: goto tr572;
	case 145: goto tr82;
	case 146: goto tr82;
	case 147: goto tr82;
	case 148: goto tr82;
	case 457: goto tr574;
	case 458: goto tr546;
	case 149: goto tr82;
	case 150: goto tr82;
	case 151: goto tr82;
	case 152: goto tr82;
	case 153: goto tr82;
	case 154: goto tr82;
	case 155: goto tr82;
	case 156: goto tr82;
	case 459: goto tr577;
	case 460: goto tr546;
	case 157: goto tr82;
	case 158: goto tr82;
	case 159: goto tr82;
	case 160: goto tr82;
	case 161: goto tr82;
	case 162: goto tr82;
	case 163: goto tr82;
	case 164: goto tr82;
	case 165: goto tr82;
	case 166: goto tr82;
	case 167: goto tr82;
	case 461: goto tr580;
	case 462: goto tr546;
	case 168: goto tr82;
	case 169: goto tr82;
	case 170: goto tr82;
	case 171: goto tr82;
	case 172: goto tr82;
	case 173: goto tr82;
	case 174: goto tr82;
	case 175: goto tr82;
	case 176: goto tr82;
	case 463: goto tr586;
	case 177: goto tr82;
	case 178: goto tr82;
	case 179: goto tr82;
	case 180: goto tr82;
	case 181: goto tr82;
	case 182: goto tr82;
	case 183: goto tr82;
	case 184: goto tr82;
	case 185: goto tr82;
	case 464: goto tr588;
	case 186: goto tr82;
	case 187: goto tr82;
	case 188: goto tr82;
	case 189: goto tr82;
	case 190: goto tr82;
	case 465: goto tr590;
	case 191: goto tr82;
	case 192: goto tr82;
	case 193: goto tr82;
	case 194: goto tr82;
	case 195: goto tr82;
	case 196: goto tr82;
	case 466: goto tr592;
	case 467: goto tr546;
	case 197: goto tr82;
	case 198: goto tr82;
	case 199: goto tr82;
	case 200: goto tr82;
	case 201: goto tr82;
	case 202: goto tr82;
	case 203: goto tr82;
	case 204: goto tr82;
	case 205: goto tr82;
	case 206: goto tr82;
	case 207: goto tr82;
	case 208: goto tr82;
	case 468: goto tr596;
	case 209: goto tr82;
	case 210: goto tr82;
	case 211: goto tr82;
	case 212: goto tr82;
	case 213: goto tr82;
	case 214: goto tr82;
	case 469: goto tr598;
	case 470: goto tr546;
	case 215: goto tr82;
	case 216: goto tr82;
	case 217: goto tr82;
	case 218: goto tr82;
	case 219: goto tr82;
	case 220: goto tr82;
	case 221: goto tr82;
	case 222: goto tr82;
	case 223: goto tr82;
	case 224: goto tr82;
	case 225: goto tr82;
	case 471: goto tr601;
	case 472: goto tr546;
	case 226: goto tr82;
	case 227: goto tr82;
	case 228: goto tr82;
	case 229: goto tr82;
	case 230: goto tr82;
	case 231: goto tr82;
	case 473: goto tr605;
	case 232: goto tr82;
	case 233: goto tr82;
	case 234: goto tr82;
	case 235: goto tr82;
	case 236: goto tr82;
	case 474: goto tr607;
	case 475: goto tr546;
	case 237: goto tr82;
	case 238: goto tr82;
	case 239: goto tr82;
	case 240: goto tr82;
	case 241: goto tr82;
	case 242: goto tr82;
	case 476: goto tr612;
	case 243: goto tr82;
	case 244: goto tr82;
	case 245: goto tr82;
	case 246: goto tr82;
	case 247: goto tr82;
	case 248: goto tr82;
	case 477: goto tr614;
	case 249: goto tr276;
	case 250: goto tr276;
	case 478: goto tr617;
	case 251: goto tr82;
	case 252: goto tr82;
	case 253: goto tr82;
	case 254: goto tr82;
	case 255: goto tr82;
	case 479: goto tr619;
	case 256: goto tr82;
	case 257: goto tr82;
	case 258: goto tr82;
	case 259: goto tr82;
	case 480: goto tr621;
	case 481: goto tr546;
	case 260: goto tr82;
	case 261: goto tr82;
	case 262: goto tr82;
	case 263: goto tr82;
	case 264: goto tr82;
	case 265: goto tr82;
	case 482: goto tr624;
	case 483: goto tr546;
	case 266: goto tr82;
	case 267: goto tr82;
	case 268: goto tr82;
	case 269: goto tr82;
	case 270: goto tr82;
	case 271: goto tr82;
	case 484: goto tr628;
	case 272: goto tr301;
	case 273: goto tr301;
	case 485: goto tr631;
	case 274: goto tr82;
	case 275: goto tr82;
	case 276: goto tr82;
	case 277: goto tr82;
	case 278: goto tr82;
	case 279: goto tr82;
	case 280: goto tr82;
	case 281: goto tr82;
	case 486: goto tr633;
	case 487: goto tr546;
	case 282: goto tr82;
	case 283: goto tr82;
	case 284: goto tr82;
	case 285: goto tr82;
	case 286: goto tr82;
	case 488: goto tr636;
	case 489: goto tr546;
	case 287: goto tr82;
	case 288: goto tr82;
	case 289: goto tr82;
	case 290: goto tr82;
	case 291: goto tr82;
	case 490: goto tr639;
	case 491: goto tr546;
	case 292: goto tr82;
	case 293: goto tr82;
	case 294: goto tr82;
	case 295: goto tr82;
	case 296: goto tr82;
	case 297: goto tr82;
	case 298: goto tr82;
	case 299: goto tr82;
	case 300: goto tr82;
	case 301: goto tr82;
	case 302: goto tr82;
	case 303: goto tr82;
	case 304: goto tr82;
	case 305: goto tr82;
	case 306: goto tr82;
	case 307: goto tr82;
	case 308: goto tr82;
	case 309: goto tr82;
	case 492: goto tr652;
	case 310: goto tr82;
	case 311: goto tr82;
	case 312: goto tr82;
	case 313: goto tr82;
	case 314: goto tr82;
	case 315: goto tr82;
	case 316: goto tr82;
	case 317: goto tr82;
	case 318: goto tr82;
	case 319: goto tr82;
	case 320: goto tr82;
	case 321: goto tr82;
	case 322: goto tr82;
	case 323: goto tr82;
	case 324: goto tr82;
	case 325: goto tr82;
	case 326: goto tr82;
	case 327: goto tr82;
	case 328: goto tr82;
	case 329: goto tr82;
	case 330: goto tr82;
	case 331: goto tr82;
	case 332: goto tr82;
	case 333: goto tr82;
	case 334: goto tr82;
	case 335: goto tr82;
	case 336: goto tr82;
	case 337: goto tr82;
	case 338: goto tr82;
	case 339: goto tr82;
	case 340: goto tr82;
	case 341: goto tr82;
	case 342: goto tr82;
	case 343: goto tr82;
	case 344: goto tr82;
	case 345: goto tr82;
	case 346: goto tr82;
	case 347: goto tr82;
	case 348: goto tr82;
	case 349: goto tr82;
	case 350: goto tr82;
	case 351: goto tr82;
	case 352: goto tr82;
	case 353: goto tr82;
	case 354: goto tr82;
	case 355: goto tr82;
	case 356: goto tr82;
	case 357: goto tr82;
	case 358: goto tr82;
	case 359: goto tr82;
	case 360: goto tr82;
	case 361: goto tr82;
	case 362: goto tr82;
	case 363: goto tr82;
	case 364: goto tr82;
	case 493: goto tr546;
	case 365: goto tr82;
	case 366: goto tr82;
	case 367: goto tr82;
	case 368: goto tr82;
	case 369: goto tr82;
	case 370: goto tr82;
	case 371: goto tr75;
	case 494: goto tr654;
	case 372: goto tr75;
	case 373: goto tr75;
	case 374: goto tr82;
	case 495: goto tr546;
	case 375: goto tr82;
	case 376: goto tr82;
	case 377: goto tr82;
	case 497: goto tr658;
	case 378: goto tr424;
	case 379: goto tr424;
	case 380: goto tr424;
	case 381: goto tr424;
	case 382: goto tr424;
	case 499: goto tr662;
	case 383: goto tr430;
	case 384: goto tr430;
	case 385: goto tr430;
	case 386: goto tr430;
	case 387: goto tr430;
	case 388: goto tr430;
	case 389: goto tr430;
	case 390: goto tr430;
	case 501: goto tr666;
	case 391: goto tr439;
	case 392: goto tr439;
	case 393: goto tr439;
	case 394: goto tr439;
	case 395: goto tr439;
	case 396: goto tr439;
	case 397: goto tr439;
	case 398: goto tr439;
	case 399: goto tr439;
	case 400: goto tr439;
	case 401: goto tr439;
	case 402: goto tr439;
	case 403: goto tr439;
	case 404: goto tr439;
	case 405: goto tr439;
	case 406: goto tr439;
	case 407: goto tr439;
	case 408: goto tr439;
	case 409: goto tr439;
	case 410: goto tr439;
	case 411: goto tr439;
	case 412: goto tr439;
	case 413: goto tr439;
	case 414: goto tr439;
	case 415: goto tr439;
	case 416: goto tr439;
	case 503: goto tr473;
	case 417: goto tr473;
	case 504: goto tr674;
	case 505: goto tr674;
	case 418: goto tr475;
	case 506: goto tr675;
	case 507: goto tr675;
	case 419: goto tr475;
	}
	}

	_out: {}
	}

#line 1302 "ext/dtext/dtext.rl"

  dstack_close(sm);

  return sm->error == NULL;
}

/* Everything below is optional, it's only needed to build bin/cdtext.exe. */
#ifdef CDTEXT

static void parse_file(FILE* input, FILE* output, gboolean opt_strip, gboolean opt_inline, gboolean opt_mentions) {
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

  StateMachine* sm = init_machine(dtext, length, opt_strip, opt_inline, opt_mentions);
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
  gboolean opt_strip = FALSE;
  gboolean opt_inline = FALSE;
  gboolean opt_no_mentions = FALSE;

  GOptionEntry options[] = {
    { "no-mentions", 'm', 0, G_OPTION_ARG_NONE, &opt_no_mentions, "Don't parse @mentions", NULL },
    { "inline",      'i', 0, G_OPTION_ARG_NONE, &opt_inline,      "Parse in inline mode", NULL },
    { "strip",       's', 0, G_OPTION_ARG_NONE, &opt_strip,       "Strip markup", NULL },
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
    parse_file(stdin, stdout, opt_strip, opt_inline, !opt_no_mentions);
    return 0;
  }

  for (const char* filename = *argv; argc > 0; argc--, argv++) {
    FILE* input = fopen(filename, "r");
    if (!input) {
      perror("fopen failed");
      return 1;
    }

    parse_file(input, stdout, opt_strip, opt_inline, !opt_no_mentions);
    fclose(input);
  }

  return 0;
}

#endif
