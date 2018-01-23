
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
} element_t;


#line 824 "ext/dtext/dtext.rl"



#line 57 "ext/dtext/dtext.c"
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
	0, 0, 0, 0, 0, 64, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 64, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 64, 0, 64, 0, 64, 0, 
	64, 0, 0, 0, 0, 0
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
	0, 0, 0, 0, 0, 65, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 65, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 65, 0, 65, 0, 65, 0, 
	65, 0, 0, 0, 0, 0
};

static const int dtext_start = 293;
static const int dtext_first_final = 293;
static const int dtext_error = -1;

static const int dtext_en_inline = 309;
static const int dtext_en_code = 346;
static const int dtext_en_nodtext = 348;
static const int dtext_en_table = 350;
static const int dtext_en_list = 352;
static const int dtext_en_main = 293;


#line 827 "ext/dtext/dtext.rl"

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
    // do nothing
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
  sm->cs = 0;
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

gboolean parse_inline(StateMachine* sm, const char* dtext, const ssize_t length) {
    StateMachine* inline_sm = init_machine(dtext, length, sm->f_strip, true, sm->f_mentions);
    gboolean success = parse_helper(inline_sm);

    if (success) {
      append(sm, true, inline_sm->output->str);
    } else {
      g_debug("parse_inline failed");
      g_propagate_error(&sm->error, inline_sm->error);
    }

    free_machine(inline_sm);
    return success;
}

gboolean parse_helper(StateMachine* sm) {
  const gchar* end = NULL;

  g_debug("start\n");

  if (!g_utf8_validate(sm->pb, sm->pe - sm->pb, &end)) {
    g_set_error(&sm->error, DTEXT_PARSE_ERROR, DTEXT_PARSE_ERROR_INVALID_UTF8, "invalid utf8 starting at byte %td", end - sm->pb + 1);
    return FALSE;
  }

  
#line 552 "ext/dtext/dtext.c"
	{
	 sm->cs = dtext_start;
	( sm->top) = 0;
	( sm->ts) = 0;
	( sm->te) = 0;
	( sm->act) = 0;
	}

#line 1212 "ext/dtext/dtext.rl"
  
#line 563 "ext/dtext/dtext.c"
	{
	if ( ( sm->p) == ( sm->pe) )
		goto _test_eof;
_resume:
	switch ( _dtext_from_state_actions[ sm->cs] ) {
	case 65:
#line 1 "NONE"
	{( sm->ts) = ( sm->p);}
	break;
#line 573 "ext/dtext/dtext.c"
	}

	switch (  sm->cs ) {
case 293:
	switch( (*( sm->p)) ) {
		case 10: goto tr349;
		case 13: goto tr350;
		case 42: goto tr351;
		case 72: goto tr352;
		case 91: goto tr353;
		case 104: goto tr352;
	}
	goto tr348;
case 294:
	switch( (*( sm->p)) ) {
		case 10: goto tr1;
		case 13: goto tr354;
	}
	goto tr0;
case 0:
	if ( (*( sm->p)) == 10 )
		goto tr1;
	goto tr0;
case 295:
	if ( (*( sm->p)) == 10 )
		goto tr349;
	goto tr355;
case 296:
	switch( (*( sm->p)) ) {
		case 9: goto tr5;
		case 32: goto tr5;
		case 42: goto tr6;
	}
	goto tr355;
case 1:
	switch( (*( sm->p)) ) {
		case 9: goto tr4;
		case 10: goto tr2;
		case 13: goto tr2;
		case 32: goto tr4;
	}
	goto tr3;
case 297:
	switch( (*( sm->p)) ) {
		case 10: goto tr356;
		case 13: goto tr356;
	}
	goto tr357;
case 298:
	switch( (*( sm->p)) ) {
		case 9: goto tr4;
		case 10: goto tr356;
		case 13: goto tr356;
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
case 299:
	if ( 49 <= (*( sm->p)) && (*( sm->p)) <= 54 )
		goto tr358;
	goto tr355;
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
case 300:
	switch( (*( sm->p)) ) {
		case 9: goto tr360;
		case 32: goto tr360;
	}
	goto tr359;
case 301:
	switch( (*( sm->p)) ) {
		case 9: goto tr362;
		case 32: goto tr362;
	}
	goto tr361;
case 302:
	switch( (*( sm->p)) ) {
		case 47: goto tr363;
		case 67: goto tr364;
		case 69: goto tr365;
		case 78: goto tr366;
		case 81: goto tr367;
		case 83: goto tr368;
		case 84: goto tr369;
		case 99: goto tr364;
		case 101: goto tr365;
		case 110: goto tr366;
		case 113: goto tr367;
		case 115: goto tr368;
		case 116: goto tr369;
	}
	goto tr355;
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
case 303:
	if ( (*( sm->p)) == 32 )
		goto tr24;
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr24;
	goto tr370;
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
case 304:
	if ( (*( sm->p)) == 32 )
		goto tr372;
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr372;
	goto tr371;
case 305:
	if ( (*( sm->p)) == 32 )
		goto tr31;
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr31;
	goto tr373;
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
case 306:
	if ( (*( sm->p)) == 32 )
		goto tr41;
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr41;
	goto tr374;
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
case 307:
	if ( (*( sm->p)) == 32 )
		goto tr46;
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr46;
	goto tr375;
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
case 308:
	if ( (*( sm->p)) == 32 )
		goto tr54;
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr54;
	goto tr376;
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
case 309:
	switch( (*( sm->p)) ) {
		case 10: goto tr378;
		case 13: goto tr379;
		case 34: goto tr380;
		case 60: goto tr381;
		case 64: goto tr382;
		case 65: goto tr383;
		case 67: goto tr384;
		case 70: goto tr385;
		case 73: goto tr386;
		case 78: goto tr387;
		case 80: goto tr388;
		case 84: goto tr389;
		case 85: goto tr390;
		case 91: goto tr391;
		case 97: goto tr383;
		case 99: goto tr384;
		case 102: goto tr385;
		case 104: goto tr392;
		case 105: goto tr386;
		case 110: goto tr387;
		case 112: goto tr388;
		case 116: goto tr389;
		case 117: goto tr390;
		case 123: goto tr393;
	}
	goto tr377;
case 310:
	switch( (*( sm->p)) ) {
		case 10: goto tr63;
		case 13: goto tr395;
		case 42: goto tr396;
	}
	goto tr394;
case 311:
	switch( (*( sm->p)) ) {
		case 10: goto tr63;
		case 13: goto tr395;
	}
	goto tr397;
case 53:
	if ( (*( sm->p)) == 10 )
		goto tr63;
	goto tr62;
case 54:
	switch( (*( sm->p)) ) {
		case 9: goto tr65;
		case 32: goto tr65;
		case 42: goto tr66;
	}
	goto tr64;
case 55:
	switch( (*( sm->p)) ) {
		case 9: goto tr68;
		case 10: goto tr64;
		case 13: goto tr64;
		case 32: goto tr68;
	}
	goto tr67;
case 312:
	switch( (*( sm->p)) ) {
		case 10: goto tr398;
		case 13: goto tr398;
	}
	goto tr399;
case 313:
	switch( (*( sm->p)) ) {
		case 9: goto tr68;
		case 10: goto tr398;
		case 13: goto tr398;
		case 32: goto tr68;
	}
	goto tr67;
case 314:
	if ( (*( sm->p)) == 10 )
		goto tr378;
	goto tr400;
case 315:
	if ( (*( sm->p)) == 34 )
		goto tr401;
	goto tr402;
case 56:
	if ( (*( sm->p)) == 34 )
		goto tr71;
	goto tr70;
case 57:
	if ( (*( sm->p)) == 58 )
		goto tr72;
	goto tr69;
case 58:
	switch( (*( sm->p)) ) {
		case 35: goto tr73;
		case 47: goto tr73;
		case 91: goto tr74;
		case 104: goto tr75;
	}
	goto tr69;
case 59:
	if ( (*( sm->p)) < -32 ) {
		if ( -62 <= (*( sm->p)) && (*( sm->p)) <= -33 )
			goto tr76;
	} else if ( (*( sm->p)) > -17 ) {
		if ( (*( sm->p)) > -12 ) {
			if ( 33 <= (*( sm->p)) && (*( sm->p)) <= 126 )
				goto tr79;
		} else if ( (*( sm->p)) >= -16 )
			goto tr78;
	} else
		goto tr77;
	goto tr69;
case 60:
	if ( (*( sm->p)) <= -65 )
		goto tr79;
	goto tr62;
case 316:
	if ( (*( sm->p)) < -32 ) {
		if ( -62 <= (*( sm->p)) && (*( sm->p)) <= -33 )
			goto tr76;
	} else if ( (*( sm->p)) > -17 ) {
		if ( (*( sm->p)) > -12 ) {
			if ( 33 <= (*( sm->p)) && (*( sm->p)) <= 126 )
				goto tr79;
		} else if ( (*( sm->p)) >= -16 )
			goto tr78;
	} else
		goto tr77;
	goto tr403;
case 61:
	if ( (*( sm->p)) <= -65 )
		goto tr76;
	goto tr62;
case 62:
	if ( (*( sm->p)) <= -65 )
		goto tr77;
	goto tr62;
case 63:
	switch( (*( sm->p)) ) {
		case 35: goto tr80;
		case 47: goto tr80;
		case 104: goto tr81;
	}
	goto tr69;
case 64:
	if ( (*( sm->p)) < -32 ) {
		if ( -62 <= (*( sm->p)) && (*( sm->p)) <= -33 )
			goto tr82;
	} else if ( (*( sm->p)) > -17 ) {
		if ( (*( sm->p)) > -12 ) {
			if ( 33 <= (*( sm->p)) && (*( sm->p)) <= 126 )
				goto tr85;
		} else if ( (*( sm->p)) >= -16 )
			goto tr84;
	} else
		goto tr83;
	goto tr69;
case 65:
	if ( (*( sm->p)) <= -65 )
		goto tr85;
	goto tr69;
case 66:
	if ( (*( sm->p)) == 93 )
		goto tr86;
	if ( (*( sm->p)) < -32 ) {
		if ( -62 <= (*( sm->p)) && (*( sm->p)) <= -33 )
			goto tr82;
	} else if ( (*( sm->p)) > -17 ) {
		if ( (*( sm->p)) > -12 ) {
			if ( 33 <= (*( sm->p)) && (*( sm->p)) <= 126 )
				goto tr85;
		} else if ( (*( sm->p)) >= -16 )
			goto tr84;
	} else
		goto tr83;
	goto tr69;
case 67:
	if ( (*( sm->p)) <= -65 )
		goto tr82;
	goto tr69;
case 68:
	if ( (*( sm->p)) <= -65 )
		goto tr83;
	goto tr69;
case 69:
	if ( (*( sm->p)) == 116 )
		goto tr87;
	goto tr69;
case 70:
	if ( (*( sm->p)) == 116 )
		goto tr88;
	goto tr69;
case 71:
	if ( (*( sm->p)) == 112 )
		goto tr89;
	goto tr69;
case 72:
	switch( (*( sm->p)) ) {
		case 58: goto tr90;
		case 115: goto tr91;
	}
	goto tr69;
case 73:
	if ( (*( sm->p)) == 47 )
		goto tr92;
	goto tr69;
case 74:
	if ( (*( sm->p)) == 47 )
		goto tr93;
	goto tr69;
case 75:
	if ( (*( sm->p)) == 58 )
		goto tr90;
	goto tr69;
case 76:
	if ( (*( sm->p)) == 116 )
		goto tr94;
	goto tr69;
case 77:
	if ( (*( sm->p)) == 116 )
		goto tr95;
	goto tr69;
case 78:
	if ( (*( sm->p)) == 112 )
		goto tr96;
	goto tr69;
case 79:
	switch( (*( sm->p)) ) {
		case 58: goto tr97;
		case 115: goto tr98;
	}
	goto tr69;
case 80:
	if ( (*( sm->p)) == 47 )
		goto tr99;
	goto tr69;
case 81:
	if ( (*( sm->p)) == 47 )
		goto tr100;
	goto tr69;
case 82:
	if ( (*( sm->p)) == 58 )
		goto tr97;
	goto tr69;
case 317:
	switch( (*( sm->p)) ) {
		case 64: goto tr404;
		case 104: goto tr405;
	}
	goto tr401;
case 83:
	if ( (*( sm->p)) < -32 ) {
		if ( -62 <= (*( sm->p)) && (*( sm->p)) <= -33 )
			goto tr101;
	} else if ( (*( sm->p)) > -17 ) {
		if ( (*( sm->p)) > -12 ) {
			if ( 33 <= (*( sm->p)) && (*( sm->p)) <= 126 )
				goto tr104;
		} else if ( (*( sm->p)) >= -16 )
			goto tr103;
	} else
		goto tr102;
	goto tr69;
case 84:
	if ( (*( sm->p)) <= -65 )
		goto tr105;
	goto tr69;
case 85:
	if ( (*( sm->p)) == 62 )
		goto tr109;
	if ( (*( sm->p)) < -32 ) {
		if ( -62 <= (*( sm->p)) && (*( sm->p)) <= -33 )
			goto tr106;
	} else if ( (*( sm->p)) > -17 ) {
		if ( (*( sm->p)) > -12 ) {
			if ( 33 <= (*( sm->p)) && (*( sm->p)) <= 126 )
				goto tr105;
		} else if ( (*( sm->p)) >= -16 )
			goto tr108;
	} else
		goto tr107;
	goto tr69;
case 86:
	if ( (*( sm->p)) <= -65 )
		goto tr106;
	goto tr69;
case 87:
	if ( (*( sm->p)) <= -65 )
		goto tr107;
	goto tr69;
case 88:
	if ( (*( sm->p)) == 116 )
		goto tr110;
	goto tr69;
case 89:
	if ( (*( sm->p)) == 116 )
		goto tr111;
	goto tr69;
case 90:
	if ( (*( sm->p)) == 112 )
		goto tr112;
	goto tr69;
case 91:
	switch( (*( sm->p)) ) {
		case 58: goto tr113;
		case 115: goto tr114;
	}
	goto tr69;
case 92:
	if ( (*( sm->p)) == 47 )
		goto tr115;
	goto tr69;
case 93:
	if ( (*( sm->p)) == 47 )
		goto tr116;
	goto tr69;
case 94:
	if ( (*( sm->p)) < -32 ) {
		if ( -62 <= (*( sm->p)) && (*( sm->p)) <= -33 )
			goto tr117;
	} else if ( (*( sm->p)) > -17 ) {
		if ( (*( sm->p)) > -12 ) {
			if ( 33 <= (*( sm->p)) && (*( sm->p)) <= 126 )
				goto tr120;
		} else if ( (*( sm->p)) >= -16 )
			goto tr119;
	} else
		goto tr118;
	goto tr69;
case 95:
	if ( (*( sm->p)) <= -65 )
		goto tr120;
	goto tr69;
case 96:
	if ( (*( sm->p)) == 62 )
		goto tr121;
	if ( (*( sm->p)) < -32 ) {
		if ( -62 <= (*( sm->p)) && (*( sm->p)) <= -33 )
			goto tr117;
	} else if ( (*( sm->p)) > -17 ) {
		if ( (*( sm->p)) > -12 ) {
			if ( 33 <= (*( sm->p)) && (*( sm->p)) <= 126 )
				goto tr120;
		} else if ( (*( sm->p)) >= -16 )
			goto tr119;
	} else
		goto tr118;
	goto tr69;
case 97:
	if ( (*( sm->p)) <= -65 )
		goto tr117;
	goto tr69;
case 98:
	if ( (*( sm->p)) <= -65 )
		goto tr118;
	goto tr69;
case 99:
	if ( (*( sm->p)) == 58 )
		goto tr113;
	goto tr69;
case 318:
	if ( (*( sm->p)) < -32 ) {
		if ( -62 <= (*( sm->p)) && (*( sm->p)) <= -33 )
			goto tr406;
	} else if ( (*( sm->p)) > -17 ) {
		if ( (*( sm->p)) > -12 ) {
			if ( 33 <= (*( sm->p)) && (*( sm->p)) <= 126 )
				goto tr409;
		} else if ( (*( sm->p)) >= -16 )
			goto tr408;
	} else
		goto tr407;
	goto tr401;
case 100:
	if ( (*( sm->p)) <= -65 )
		goto tr122;
	goto tr62;
case 319:
	if ( (*( sm->p)) < -32 ) {
		if ( -62 <= (*( sm->p)) && (*( sm->p)) <= -33 )
			goto tr123;
	} else if ( (*( sm->p)) > -17 ) {
		if ( (*( sm->p)) > -12 ) {
			if ( 33 <= (*( sm->p)) && (*( sm->p)) <= 126 )
				goto tr122;
		} else if ( (*( sm->p)) >= -16 )
			goto tr411;
	} else
		goto tr124;
	goto tr410;
case 101:
	if ( (*( sm->p)) <= -65 )
		goto tr123;
	goto tr62;
case 102:
	if ( (*( sm->p)) <= -65 )
		goto tr124;
	goto tr62;
case 320:
	if ( (*( sm->p)) == 64 )
		goto tr413;
	if ( (*( sm->p)) < -32 ) {
		if ( -62 <= (*( sm->p)) && (*( sm->p)) <= -33 )
			goto tr123;
	} else if ( (*( sm->p)) > -17 ) {
		if ( (*( sm->p)) > -12 ) {
			if ( 33 <= (*( sm->p)) && (*( sm->p)) <= 126 )
				goto tr122;
		} else if ( (*( sm->p)) >= -16 )
			goto tr411;
	} else
		goto tr124;
	goto tr412;
case 321:
	switch( (*( sm->p)) ) {
		case 82: goto tr414;
		case 114: goto tr414;
	}
	goto tr401;
case 103:
	switch( (*( sm->p)) ) {
		case 84: goto tr125;
		case 116: goto tr125;
	}
	goto tr69;
case 104:
	switch( (*( sm->p)) ) {
		case 73: goto tr126;
		case 105: goto tr126;
	}
	goto tr69;
case 105:
	switch( (*( sm->p)) ) {
		case 83: goto tr127;
		case 115: goto tr127;
	}
	goto tr69;
case 106:
	switch( (*( sm->p)) ) {
		case 84: goto tr128;
		case 116: goto tr128;
	}
	goto tr69;
case 107:
	if ( (*( sm->p)) == 32 )
		goto tr129;
	goto tr69;
case 108:
	if ( (*( sm->p)) == 35 )
		goto tr130;
	goto tr69;
case 109:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr131;
	goto tr69;
case 322:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr416;
	goto tr415;
case 323:
	switch( (*( sm->p)) ) {
		case 79: goto tr417;
		case 111: goto tr417;
	}
	goto tr401;
case 110:
	switch( (*( sm->p)) ) {
		case 77: goto tr132;
		case 109: goto tr132;
	}
	goto tr69;
case 111:
	switch( (*( sm->p)) ) {
		case 77: goto tr133;
		case 109: goto tr133;
	}
	goto tr69;
case 112:
	switch( (*( sm->p)) ) {
		case 69: goto tr134;
		case 101: goto tr134;
	}
	goto tr69;
case 113:
	switch( (*( sm->p)) ) {
		case 78: goto tr135;
		case 110: goto tr135;
	}
	goto tr69;
case 114:
	switch( (*( sm->p)) ) {
		case 84: goto tr136;
		case 116: goto tr136;
	}
	goto tr69;
case 115:
	if ( (*( sm->p)) == 32 )
		goto tr137;
	goto tr69;
case 116:
	if ( (*( sm->p)) == 35 )
		goto tr138;
	goto tr69;
case 117:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr139;
	goto tr69;
case 324:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr419;
	goto tr418;
case 325:
	switch( (*( sm->p)) ) {
		case 79: goto tr420;
		case 111: goto tr420;
	}
	goto tr401;
case 118:
	switch( (*( sm->p)) ) {
		case 82: goto tr140;
		case 114: goto tr140;
	}
	goto tr69;
case 119:
	switch( (*( sm->p)) ) {
		case 85: goto tr141;
		case 117: goto tr141;
	}
	goto tr69;
case 120:
	switch( (*( sm->p)) ) {
		case 77: goto tr142;
		case 109: goto tr142;
	}
	goto tr69;
case 121:
	if ( (*( sm->p)) == 32 )
		goto tr143;
	goto tr69;
case 122:
	if ( (*( sm->p)) == 35 )
		goto tr144;
	goto tr69;
case 123:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr145;
	goto tr69;
case 326:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr422;
	goto tr421;
case 327:
	switch( (*( sm->p)) ) {
		case 83: goto tr423;
		case 115: goto tr423;
	}
	goto tr401;
case 124:
	switch( (*( sm->p)) ) {
		case 83: goto tr146;
		case 115: goto tr146;
	}
	goto tr69;
case 125:
	switch( (*( sm->p)) ) {
		case 85: goto tr147;
		case 117: goto tr147;
	}
	goto tr69;
case 126:
	switch( (*( sm->p)) ) {
		case 69: goto tr148;
		case 101: goto tr148;
	}
	goto tr69;
case 127:
	if ( (*( sm->p)) == 32 )
		goto tr149;
	goto tr69;
case 128:
	if ( (*( sm->p)) == 35 )
		goto tr150;
	goto tr69;
case 129:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr151;
	goto tr69;
case 328:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr425;
	goto tr424;
case 329:
	switch( (*( sm->p)) ) {
		case 79: goto tr426;
		case 111: goto tr426;
	}
	goto tr401;
case 130:
	switch( (*( sm->p)) ) {
		case 84: goto tr152;
		case 116: goto tr152;
	}
	goto tr69;
case 131:
	switch( (*( sm->p)) ) {
		case 69: goto tr153;
		case 101: goto tr153;
	}
	goto tr69;
case 132:
	if ( (*( sm->p)) == 32 )
		goto tr154;
	goto tr69;
case 133:
	if ( (*( sm->p)) == 35 )
		goto tr155;
	goto tr69;
case 134:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr156;
	goto tr69;
case 330:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr428;
	goto tr427;
case 331:
	switch( (*( sm->p)) ) {
		case 73: goto tr429;
		case 79: goto tr430;
		case 105: goto tr429;
		case 111: goto tr430;
	}
	goto tr401;
case 135:
	switch( (*( sm->p)) ) {
		case 88: goto tr157;
		case 120: goto tr157;
	}
	goto tr69;
case 136:
	switch( (*( sm->p)) ) {
		case 73: goto tr158;
		case 105: goto tr158;
	}
	goto tr69;
case 137:
	switch( (*( sm->p)) ) {
		case 86: goto tr159;
		case 118: goto tr159;
	}
	goto tr69;
case 138:
	if ( (*( sm->p)) == 32 )
		goto tr160;
	goto tr69;
case 139:
	if ( (*( sm->p)) == 35 )
		goto tr161;
	goto tr69;
case 140:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr162;
	goto tr69;
case 332:
	if ( (*( sm->p)) == 47 )
		goto tr432;
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr433;
	goto tr431;
case 141:
	if ( (*( sm->p)) == 112 )
		goto tr164;
	goto tr163;
case 142:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr165;
	goto tr163;
case 333:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr435;
	goto tr434;
case 143:
	switch( (*( sm->p)) ) {
		case 79: goto tr166;
		case 83: goto tr167;
		case 111: goto tr166;
		case 115: goto tr167;
	}
	goto tr69;
case 144:
	switch( (*( sm->p)) ) {
		case 76: goto tr168;
		case 108: goto tr168;
	}
	goto tr69;
case 145:
	if ( (*( sm->p)) == 32 )
		goto tr169;
	goto tr69;
case 146:
	if ( (*( sm->p)) == 35 )
		goto tr170;
	goto tr69;
case 147:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr171;
	goto tr69;
case 334:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr437;
	goto tr436;
case 148:
	switch( (*( sm->p)) ) {
		case 84: goto tr172;
		case 116: goto tr172;
	}
	goto tr69;
case 149:
	if ( (*( sm->p)) == 32 )
		goto tr173;
	goto tr69;
case 150:
	if ( (*( sm->p)) == 35 )
		goto tr174;
	goto tr69;
case 151:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr175;
	goto tr69;
case 335:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr439;
	goto tr438;
case 336:
	switch( (*( sm->p)) ) {
		case 79: goto tr440;
		case 111: goto tr440;
	}
	goto tr401;
case 152:
	switch( (*( sm->p)) ) {
		case 80: goto tr176;
		case 112: goto tr176;
	}
	goto tr69;
case 153:
	switch( (*( sm->p)) ) {
		case 73: goto tr177;
		case 105: goto tr177;
	}
	goto tr69;
case 154:
	switch( (*( sm->p)) ) {
		case 67: goto tr178;
		case 99: goto tr178;
	}
	goto tr69;
case 155:
	if ( (*( sm->p)) == 32 )
		goto tr179;
	goto tr69;
case 156:
	if ( (*( sm->p)) == 35 )
		goto tr180;
	goto tr69;
case 157:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr181;
	goto tr69;
case 337:
	if ( (*( sm->p)) == 47 )
		goto tr442;
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr443;
	goto tr441;
case 158:
	if ( (*( sm->p)) == 112 )
		goto tr183;
	goto tr182;
case 159:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr184;
	goto tr182;
case 338:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr445;
	goto tr444;
case 339:
	switch( (*( sm->p)) ) {
		case 83: goto tr446;
		case 115: goto tr446;
	}
	goto tr401;
case 160:
	switch( (*( sm->p)) ) {
		case 69: goto tr185;
		case 101: goto tr185;
	}
	goto tr69;
case 161:
	switch( (*( sm->p)) ) {
		case 82: goto tr186;
		case 114: goto tr186;
	}
	goto tr69;
case 162:
	if ( (*( sm->p)) == 32 )
		goto tr187;
	goto tr69;
case 163:
	if ( (*( sm->p)) == 35 )
		goto tr188;
	goto tr69;
case 164:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr189;
	goto tr69;
case 340:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr448;
	goto tr447;
case 341:
	switch( (*( sm->p)) ) {
		case 47: goto tr449;
		case 66: goto tr450;
		case 67: goto tr451;
		case 69: goto tr452;
		case 73: goto tr453;
		case 78: goto tr454;
		case 81: goto tr455;
		case 83: goto tr456;
		case 84: goto tr457;
		case 85: goto tr458;
		case 91: goto tr459;
		case 98: goto tr450;
		case 99: goto tr451;
		case 101: goto tr452;
		case 105: goto tr453;
		case 110: goto tr454;
		case 113: goto tr455;
		case 115: goto tr456;
		case 116: goto tr457;
		case 117: goto tr458;
	}
	goto tr401;
case 165:
	switch( (*( sm->p)) ) {
		case 66: goto tr190;
		case 67: goto tr191;
		case 69: goto tr192;
		case 73: goto tr193;
		case 81: goto tr194;
		case 83: goto tr195;
		case 84: goto tr196;
		case 85: goto tr197;
		case 98: goto tr190;
		case 99: goto tr191;
		case 101: goto tr192;
		case 105: goto tr193;
		case 113: goto tr194;
		case 115: goto tr195;
		case 116: goto tr196;
		case 117: goto tr197;
	}
	goto tr69;
case 166:
	if ( (*( sm->p)) == 93 )
		goto tr198;
	goto tr69;
case 167:
	switch( (*( sm->p)) ) {
		case 79: goto tr199;
		case 111: goto tr199;
	}
	goto tr69;
case 168:
	switch( (*( sm->p)) ) {
		case 68: goto tr200;
		case 100: goto tr200;
	}
	goto tr69;
case 169:
	switch( (*( sm->p)) ) {
		case 69: goto tr201;
		case 101: goto tr201;
	}
	goto tr69;
case 170:
	if ( (*( sm->p)) == 93 )
		goto tr202;
	goto tr69;
case 171:
	switch( (*( sm->p)) ) {
		case 88: goto tr203;
		case 120: goto tr203;
	}
	goto tr69;
case 172:
	switch( (*( sm->p)) ) {
		case 80: goto tr204;
		case 112: goto tr204;
	}
	goto tr69;
case 173:
	switch( (*( sm->p)) ) {
		case 65: goto tr205;
		case 97: goto tr205;
	}
	goto tr69;
case 174:
	switch( (*( sm->p)) ) {
		case 78: goto tr206;
		case 110: goto tr206;
	}
	goto tr69;
case 175:
	switch( (*( sm->p)) ) {
		case 68: goto tr207;
		case 100: goto tr207;
	}
	goto tr69;
case 176:
	if ( (*( sm->p)) == 93 )
		goto tr208;
	goto tr69;
case 177:
	if ( (*( sm->p)) == 93 )
		goto tr209;
	goto tr69;
case 178:
	switch( (*( sm->p)) ) {
		case 85: goto tr210;
		case 117: goto tr210;
	}
	goto tr69;
case 179:
	switch( (*( sm->p)) ) {
		case 79: goto tr211;
		case 111: goto tr211;
	}
	goto tr69;
case 180:
	switch( (*( sm->p)) ) {
		case 84: goto tr212;
		case 116: goto tr212;
	}
	goto tr69;
case 181:
	switch( (*( sm->p)) ) {
		case 69: goto tr213;
		case 101: goto tr213;
	}
	goto tr69;
case 182:
	if ( (*( sm->p)) == 93 )
		goto tr214;
	goto tr69;
case 342:
	if ( (*( sm->p)) == 32 )
		goto tr214;
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr214;
	goto tr460;
case 183:
	switch( (*( sm->p)) ) {
		case 80: goto tr215;
		case 93: goto tr216;
		case 112: goto tr215;
	}
	goto tr69;
case 184:
	switch( (*( sm->p)) ) {
		case 79: goto tr217;
		case 111: goto tr217;
	}
	goto tr69;
case 185:
	switch( (*( sm->p)) ) {
		case 73: goto tr218;
		case 105: goto tr218;
	}
	goto tr69;
case 186:
	switch( (*( sm->p)) ) {
		case 76: goto tr219;
		case 108: goto tr219;
	}
	goto tr69;
case 187:
	switch( (*( sm->p)) ) {
		case 69: goto tr220;
		case 101: goto tr220;
	}
	goto tr69;
case 188:
	switch( (*( sm->p)) ) {
		case 82: goto tr221;
		case 114: goto tr221;
	}
	goto tr69;
case 189:
	switch( (*( sm->p)) ) {
		case 83: goto tr222;
		case 93: goto tr223;
		case 115: goto tr222;
	}
	goto tr69;
case 190:
	if ( (*( sm->p)) == 93 )
		goto tr223;
	goto tr69;
case 191:
	switch( (*( sm->p)) ) {
		case 68: goto tr224;
		case 72: goto tr225;
		case 78: goto tr226;
		case 100: goto tr224;
		case 104: goto tr225;
		case 110: goto tr226;
	}
	goto tr69;
case 192:
	if ( (*( sm->p)) == 93 )
		goto tr227;
	goto tr69;
case 193:
	if ( (*( sm->p)) == 93 )
		goto tr228;
	goto tr69;
case 194:
	if ( (*( sm->p)) == 93 )
		goto tr229;
	goto tr69;
case 195:
	if ( (*( sm->p)) == 93 )
		goto tr230;
	goto tr69;
case 196:
	if ( (*( sm->p)) == 93 )
		goto tr231;
	goto tr69;
case 197:
	switch( (*( sm->p)) ) {
		case 79: goto tr232;
		case 111: goto tr232;
	}
	goto tr69;
case 198:
	switch( (*( sm->p)) ) {
		case 68: goto tr233;
		case 100: goto tr233;
	}
	goto tr69;
case 199:
	switch( (*( sm->p)) ) {
		case 69: goto tr234;
		case 101: goto tr234;
	}
	goto tr69;
case 200:
	if ( (*( sm->p)) == 93 )
		goto tr235;
	goto tr69;
case 201:
	switch( (*( sm->p)) ) {
		case 88: goto tr236;
		case 120: goto tr236;
	}
	goto tr69;
case 202:
	switch( (*( sm->p)) ) {
		case 80: goto tr237;
		case 112: goto tr237;
	}
	goto tr69;
case 203:
	switch( (*( sm->p)) ) {
		case 65: goto tr238;
		case 97: goto tr238;
	}
	goto tr69;
case 204:
	switch( (*( sm->p)) ) {
		case 78: goto tr239;
		case 110: goto tr239;
	}
	goto tr69;
case 205:
	switch( (*( sm->p)) ) {
		case 68: goto tr240;
		case 100: goto tr240;
	}
	goto tr69;
case 206:
	if ( (*( sm->p)) == 93 )
		goto tr241;
	goto tr69;
case 207:
	if ( (*( sm->p)) == 93 )
		goto tr242;
	goto tr69;
case 208:
	switch( (*( sm->p)) ) {
		case 79: goto tr243;
		case 111: goto tr243;
	}
	goto tr69;
case 209:
	switch( (*( sm->p)) ) {
		case 68: goto tr244;
		case 100: goto tr244;
	}
	goto tr69;
case 210:
	switch( (*( sm->p)) ) {
		case 84: goto tr245;
		case 116: goto tr245;
	}
	goto tr69;
case 211:
	switch( (*( sm->p)) ) {
		case 69: goto tr246;
		case 101: goto tr246;
	}
	goto tr69;
case 212:
	switch( (*( sm->p)) ) {
		case 88: goto tr247;
		case 120: goto tr247;
	}
	goto tr69;
case 213:
	switch( (*( sm->p)) ) {
		case 84: goto tr248;
		case 116: goto tr248;
	}
	goto tr69;
case 214:
	if ( (*( sm->p)) == 93 )
		goto tr249;
	goto tr69;
case 215:
	switch( (*( sm->p)) ) {
		case 85: goto tr250;
		case 117: goto tr250;
	}
	goto tr69;
case 216:
	switch( (*( sm->p)) ) {
		case 79: goto tr251;
		case 111: goto tr251;
	}
	goto tr69;
case 217:
	switch( (*( sm->p)) ) {
		case 84: goto tr252;
		case 116: goto tr252;
	}
	goto tr69;
case 218:
	switch( (*( sm->p)) ) {
		case 69: goto tr253;
		case 101: goto tr253;
	}
	goto tr69;
case 219:
	if ( (*( sm->p)) == 93 )
		goto tr254;
	goto tr69;
case 220:
	switch( (*( sm->p)) ) {
		case 80: goto tr255;
		case 93: goto tr256;
		case 112: goto tr255;
	}
	goto tr69;
case 221:
	switch( (*( sm->p)) ) {
		case 79: goto tr257;
		case 111: goto tr257;
	}
	goto tr69;
case 222:
	switch( (*( sm->p)) ) {
		case 73: goto tr258;
		case 105: goto tr258;
	}
	goto tr69;
case 223:
	switch( (*( sm->p)) ) {
		case 76: goto tr259;
		case 108: goto tr259;
	}
	goto tr69;
case 224:
	switch( (*( sm->p)) ) {
		case 69: goto tr260;
		case 101: goto tr260;
	}
	goto tr69;
case 225:
	switch( (*( sm->p)) ) {
		case 82: goto tr261;
		case 114: goto tr261;
	}
	goto tr69;
case 226:
	switch( (*( sm->p)) ) {
		case 83: goto tr262;
		case 93: goto tr263;
		case 115: goto tr262;
	}
	goto tr69;
case 227:
	if ( (*( sm->p)) == 93 )
		goto tr263;
	goto tr69;
case 228:
	switch( (*( sm->p)) ) {
		case 78: goto tr264;
		case 110: goto tr264;
	}
	goto tr69;
case 229:
	if ( (*( sm->p)) == 93 )
		goto tr265;
	goto tr69;
case 230:
	if ( (*( sm->p)) == 93 )
		goto tr266;
	goto tr69;
case 231:
	switch( (*( sm->p)) ) {
		case 93: goto tr69;
		case 124: goto tr268;
	}
	goto tr267;
case 232:
	switch( (*( sm->p)) ) {
		case 93: goto tr270;
		case 124: goto tr271;
	}
	goto tr269;
case 233:
	if ( (*( sm->p)) == 93 )
		goto tr272;
	goto tr69;
case 234:
	switch( (*( sm->p)) ) {
		case 93: goto tr69;
		case 124: goto tr69;
	}
	goto tr273;
case 235:
	switch( (*( sm->p)) ) {
		case 93: goto tr275;
		case 124: goto tr69;
	}
	goto tr274;
case 236:
	if ( (*( sm->p)) == 93 )
		goto tr276;
	goto tr69;
case 237:
	switch( (*( sm->p)) ) {
		case 93: goto tr270;
		case 124: goto tr69;
	}
	goto tr277;
case 343:
	if ( (*( sm->p)) == 116 )
		goto tr461;
	goto tr401;
case 238:
	if ( (*( sm->p)) == 116 )
		goto tr278;
	goto tr69;
case 239:
	if ( (*( sm->p)) == 112 )
		goto tr279;
	goto tr69;
case 240:
	switch( (*( sm->p)) ) {
		case 58: goto tr280;
		case 115: goto tr281;
	}
	goto tr69;
case 241:
	if ( (*( sm->p)) == 47 )
		goto tr282;
	goto tr69;
case 242:
	if ( (*( sm->p)) == 47 )
		goto tr283;
	goto tr69;
case 243:
	if ( (*( sm->p)) < -32 ) {
		if ( -62 <= (*( sm->p)) && (*( sm->p)) <= -33 )
			goto tr284;
	} else if ( (*( sm->p)) > -17 ) {
		if ( (*( sm->p)) > -12 ) {
			if ( 33 <= (*( sm->p)) && (*( sm->p)) <= 126 )
				goto tr287;
		} else if ( (*( sm->p)) >= -16 )
			goto tr286;
	} else
		goto tr285;
	goto tr69;
case 244:
	if ( (*( sm->p)) <= -65 )
		goto tr287;
	goto tr62;
case 344:
	if ( (*( sm->p)) < -32 ) {
		if ( -62 <= (*( sm->p)) && (*( sm->p)) <= -33 )
			goto tr284;
	} else if ( (*( sm->p)) > -17 ) {
		if ( (*( sm->p)) > -12 ) {
			if ( 33 <= (*( sm->p)) && (*( sm->p)) <= 126 )
				goto tr287;
		} else if ( (*( sm->p)) >= -16 )
			goto tr286;
	} else
		goto tr285;
	goto tr462;
case 245:
	if ( (*( sm->p)) <= -65 )
		goto tr284;
	goto tr62;
case 246:
	if ( (*( sm->p)) <= -65 )
		goto tr285;
	goto tr62;
case 247:
	if ( (*( sm->p)) == 58 )
		goto tr280;
	goto tr69;
case 345:
	if ( (*( sm->p)) == 123 )
		goto tr463;
	goto tr401;
case 248:
	if ( (*( sm->p)) == 125 )
		goto tr69;
	goto tr288;
case 249:
	if ( (*( sm->p)) == 125 )
		goto tr290;
	goto tr289;
case 250:
	if ( (*( sm->p)) == 125 )
		goto tr291;
	goto tr69;
case 346:
	if ( (*( sm->p)) == 91 )
		goto tr465;
	goto tr464;
case 347:
	if ( (*( sm->p)) == 47 )
		goto tr467;
	goto tr466;
case 251:
	switch( (*( sm->p)) ) {
		case 67: goto tr293;
		case 99: goto tr293;
	}
	goto tr292;
case 252:
	switch( (*( sm->p)) ) {
		case 79: goto tr294;
		case 111: goto tr294;
	}
	goto tr292;
case 253:
	switch( (*( sm->p)) ) {
		case 68: goto tr295;
		case 100: goto tr295;
	}
	goto tr292;
case 254:
	switch( (*( sm->p)) ) {
		case 69: goto tr296;
		case 101: goto tr296;
	}
	goto tr292;
case 255:
	if ( (*( sm->p)) == 93 )
		goto tr297;
	goto tr292;
case 348:
	if ( (*( sm->p)) == 91 )
		goto tr469;
	goto tr468;
case 349:
	if ( (*( sm->p)) == 47 )
		goto tr471;
	goto tr470;
case 256:
	switch( (*( sm->p)) ) {
		case 78: goto tr299;
		case 110: goto tr299;
	}
	goto tr298;
case 257:
	switch( (*( sm->p)) ) {
		case 79: goto tr300;
		case 111: goto tr300;
	}
	goto tr298;
case 258:
	switch( (*( sm->p)) ) {
		case 68: goto tr301;
		case 100: goto tr301;
	}
	goto tr298;
case 259:
	switch( (*( sm->p)) ) {
		case 84: goto tr302;
		case 116: goto tr302;
	}
	goto tr298;
case 260:
	switch( (*( sm->p)) ) {
		case 69: goto tr303;
		case 101: goto tr303;
	}
	goto tr298;
case 261:
	switch( (*( sm->p)) ) {
		case 88: goto tr304;
		case 120: goto tr304;
	}
	goto tr298;
case 262:
	switch( (*( sm->p)) ) {
		case 84: goto tr305;
		case 116: goto tr305;
	}
	goto tr298;
case 263:
	if ( (*( sm->p)) == 93 )
		goto tr306;
	goto tr298;
case 350:
	if ( (*( sm->p)) == 91 )
		goto tr473;
	goto tr472;
case 351:
	switch( (*( sm->p)) ) {
		case 47: goto tr475;
		case 84: goto tr476;
		case 116: goto tr476;
	}
	goto tr474;
case 264:
	switch( (*( sm->p)) ) {
		case 84: goto tr308;
		case 116: goto tr308;
	}
	goto tr307;
case 265:
	switch( (*( sm->p)) ) {
		case 65: goto tr309;
		case 66: goto tr310;
		case 72: goto tr311;
		case 82: goto tr312;
		case 97: goto tr309;
		case 98: goto tr310;
		case 104: goto tr311;
		case 114: goto tr312;
	}
	goto tr307;
case 266:
	switch( (*( sm->p)) ) {
		case 66: goto tr313;
		case 98: goto tr313;
	}
	goto tr307;
case 267:
	switch( (*( sm->p)) ) {
		case 76: goto tr314;
		case 108: goto tr314;
	}
	goto tr307;
case 268:
	switch( (*( sm->p)) ) {
		case 69: goto tr315;
		case 101: goto tr315;
	}
	goto tr307;
case 269:
	if ( (*( sm->p)) == 93 )
		goto tr316;
	goto tr307;
case 270:
	switch( (*( sm->p)) ) {
		case 79: goto tr317;
		case 111: goto tr317;
	}
	goto tr307;
case 271:
	switch( (*( sm->p)) ) {
		case 68: goto tr318;
		case 100: goto tr318;
	}
	goto tr307;
case 272:
	switch( (*( sm->p)) ) {
		case 89: goto tr319;
		case 121: goto tr319;
	}
	goto tr307;
case 273:
	if ( (*( sm->p)) == 93 )
		goto tr320;
	goto tr307;
case 274:
	switch( (*( sm->p)) ) {
		case 69: goto tr321;
		case 101: goto tr321;
	}
	goto tr307;
case 275:
	switch( (*( sm->p)) ) {
		case 65: goto tr322;
		case 97: goto tr322;
	}
	goto tr307;
case 276:
	switch( (*( sm->p)) ) {
		case 68: goto tr323;
		case 100: goto tr323;
	}
	goto tr307;
case 277:
	if ( (*( sm->p)) == 93 )
		goto tr324;
	goto tr307;
case 278:
	if ( (*( sm->p)) == 93 )
		goto tr325;
	goto tr307;
case 279:
	switch( (*( sm->p)) ) {
		case 66: goto tr326;
		case 68: goto tr327;
		case 72: goto tr328;
		case 82: goto tr329;
		case 98: goto tr326;
		case 100: goto tr327;
		case 104: goto tr328;
		case 114: goto tr329;
	}
	goto tr307;
case 280:
	switch( (*( sm->p)) ) {
		case 79: goto tr330;
		case 111: goto tr330;
	}
	goto tr307;
case 281:
	switch( (*( sm->p)) ) {
		case 68: goto tr331;
		case 100: goto tr331;
	}
	goto tr307;
case 282:
	switch( (*( sm->p)) ) {
		case 89: goto tr332;
		case 121: goto tr332;
	}
	goto tr307;
case 283:
	if ( (*( sm->p)) == 93 )
		goto tr333;
	goto tr307;
case 284:
	if ( (*( sm->p)) == 93 )
		goto tr334;
	goto tr307;
case 285:
	switch( (*( sm->p)) ) {
		case 69: goto tr335;
		case 93: goto tr336;
		case 101: goto tr335;
	}
	goto tr307;
case 286:
	switch( (*( sm->p)) ) {
		case 65: goto tr337;
		case 97: goto tr337;
	}
	goto tr307;
case 287:
	switch( (*( sm->p)) ) {
		case 68: goto tr338;
		case 100: goto tr338;
	}
	goto tr307;
case 288:
	if ( (*( sm->p)) == 93 )
		goto tr339;
	goto tr307;
case 289:
	if ( (*( sm->p)) == 93 )
		goto tr340;
	goto tr307;
case 352:
	switch( (*( sm->p)) ) {
		case 10: goto tr478;
		case 13: goto tr479;
		case 42: goto tr480;
	}
	goto tr477;
case 353:
	switch( (*( sm->p)) ) {
		case 10: goto tr342;
		case 13: goto tr481;
	}
	goto tr341;
case 290:
	if ( (*( sm->p)) == 10 )
		goto tr342;
	goto tr341;
case 354:
	if ( (*( sm->p)) == 10 )
		goto tr478;
	goto tr482;
case 355:
	switch( (*( sm->p)) ) {
		case 9: goto tr346;
		case 32: goto tr346;
		case 42: goto tr347;
	}
	goto tr482;
case 291:
	switch( (*( sm->p)) ) {
		case 9: goto tr345;
		case 10: goto tr343;
		case 13: goto tr343;
		case 32: goto tr345;
	}
	goto tr344;
case 356:
	switch( (*( sm->p)) ) {
		case 10: goto tr483;
		case 13: goto tr483;
	}
	goto tr484;
case 357:
	switch( (*( sm->p)) ) {
		case 9: goto tr345;
		case 10: goto tr483;
		case 13: goto tr483;
		case 32: goto tr345;
	}
	goto tr344;
case 292:
	switch( (*( sm->p)) ) {
		case 9: goto tr346;
		case 32: goto tr346;
		case 42: goto tr347;
	}
	goto tr343;
	}

	tr354:  sm->cs = 0; goto _again;
	tr5:  sm->cs = 1; goto f4;
	tr6:  sm->cs = 2; goto _again;
	tr358:  sm->cs = 3; goto f7;
	tr7:  sm->cs = 4; goto f4;
	tr10:  sm->cs = 5; goto _again;
	tr9:  sm->cs = 5; goto f3;
	tr363:  sm->cs = 6; goto _again;
	tr12:  sm->cs = 7; goto _again;
	tr13:  sm->cs = 8; goto _again;
	tr14:  sm->cs = 9; goto _again;
	tr15:  sm->cs = 10; goto _again;
	tr16:  sm->cs = 11; goto _again;
	tr17:  sm->cs = 12; goto _again;
	tr18:  sm->cs = 13; goto _again;
	tr19:  sm->cs = 14; goto _again;
	tr364:  sm->cs = 15; goto _again;
	tr21:  sm->cs = 16; goto _again;
	tr22:  sm->cs = 17; goto _again;
	tr23:  sm->cs = 18; goto _again;
	tr365:  sm->cs = 19; goto _again;
	tr25:  sm->cs = 20; goto _again;
	tr26:  sm->cs = 21; goto _again;
	tr27:  sm->cs = 22; goto _again;
	tr28:  sm->cs = 23; goto _again;
	tr29:  sm->cs = 24; goto _again;
	tr30:  sm->cs = 25; goto _again;
	tr33:  sm->cs = 26; goto _again;
	tr32:  sm->cs = 26; goto f7;
	tr366:  sm->cs = 27; goto _again;
	tr35:  sm->cs = 28; goto _again;
	tr36:  sm->cs = 29; goto _again;
	tr37:  sm->cs = 30; goto _again;
	tr38:  sm->cs = 31; goto _again;
	tr39:  sm->cs = 32; goto _again;
	tr40:  sm->cs = 33; goto _again;
	tr367:  sm->cs = 34; goto _again;
	tr42:  sm->cs = 35; goto _again;
	tr43:  sm->cs = 36; goto _again;
	tr44:  sm->cs = 37; goto _again;
	tr45:  sm->cs = 38; goto _again;
	tr368:  sm->cs = 39; goto _again;
	tr47:  sm->cs = 40; goto _again;
	tr48:  sm->cs = 41; goto _again;
	tr49:  sm->cs = 42; goto _again;
	tr50:  sm->cs = 43; goto _again;
	tr51:  sm->cs = 44; goto _again;
	tr52:  sm->cs = 45; goto _again;
	tr53:  sm->cs = 46; goto _again;
	tr369:  sm->cs = 47; goto _again;
	tr55:  sm->cs = 48; goto _again;
	tr57:  sm->cs = 49; goto _again;
	tr58:  sm->cs = 50; goto _again;
	tr59:  sm->cs = 51; goto _again;
	tr56:  sm->cs = 52; goto _again;
	tr395:  sm->cs = 53; goto _again;
	tr66:  sm->cs = 54; goto _again;
	tr396:  sm->cs = 54; goto f7;
	tr65:  sm->cs = 55; goto f4;
	tr70:  sm->cs = 56; goto _again;
	tr402:  sm->cs = 56; goto f7;
	tr71:  sm->cs = 57; goto f4;
	tr72:  sm->cs = 58; goto _again;
	tr100:  sm->cs = 59; goto _again;
	tr73:  sm->cs = 59; goto f3;
	tr76:  sm->cs = 60; goto _again;
	tr77:  sm->cs = 61; goto _again;
	tr78:  sm->cs = 62; goto _again;
	tr74:  sm->cs = 63; goto _again;
	tr93:  sm->cs = 64; goto _again;
	tr80:  sm->cs = 64; goto f3;
	tr82:  sm->cs = 65; goto _again;
	tr85:  sm->cs = 66; goto _again;
	tr83:  sm->cs = 67; goto _again;
	tr84:  sm->cs = 68; goto _again;
	tr81:  sm->cs = 69; goto f3;
	tr87:  sm->cs = 70; goto _again;
	tr88:  sm->cs = 71; goto _again;
	tr89:  sm->cs = 72; goto _again;
	tr90:  sm->cs = 73; goto _again;
	tr92:  sm->cs = 74; goto _again;
	tr91:  sm->cs = 75; goto _again;
	tr75:  sm->cs = 76; goto f3;
	tr94:  sm->cs = 77; goto _again;
	tr95:  sm->cs = 78; goto _again;
	tr96:  sm->cs = 79; goto _again;
	tr97:  sm->cs = 80; goto _again;
	tr99:  sm->cs = 81; goto _again;
	tr98:  sm->cs = 82; goto _again;
	tr404:  sm->cs = 83; goto _again;
	tr106:  sm->cs = 84; goto _again;
	tr101:  sm->cs = 84; goto f7;
	tr105:  sm->cs = 85; goto _again;
	tr104:  sm->cs = 85; goto f7;
	tr107:  sm->cs = 86; goto _again;
	tr102:  sm->cs = 86; goto f7;
	tr108:  sm->cs = 87; goto _again;
	tr103:  sm->cs = 87; goto f7;
	tr405:  sm->cs = 88; goto _again;
	tr110:  sm->cs = 89; goto _again;
	tr111:  sm->cs = 90; goto _again;
	tr112:  sm->cs = 91; goto _again;
	tr113:  sm->cs = 92; goto _again;
	tr115:  sm->cs = 93; goto _again;
	tr116:  sm->cs = 94; goto _again;
	tr117:  sm->cs = 95; goto _again;
	tr120:  sm->cs = 96; goto _again;
	tr118:  sm->cs = 97; goto _again;
	tr119:  sm->cs = 98; goto _again;
	tr114:  sm->cs = 99; goto _again;
	tr123:  sm->cs = 100; goto _again;
	tr406:  sm->cs = 100; goto f7;
	tr124:  sm->cs = 101; goto _again;
	tr407:  sm->cs = 101; goto f7;
	tr411:  sm->cs = 102; goto _again;
	tr408:  sm->cs = 102; goto f7;
	tr414:  sm->cs = 103; goto _again;
	tr125:  sm->cs = 104; goto _again;
	tr126:  sm->cs = 105; goto _again;
	tr127:  sm->cs = 106; goto _again;
	tr128:  sm->cs = 107; goto _again;
	tr129:  sm->cs = 108; goto _again;
	tr130:  sm->cs = 109; goto _again;
	tr417:  sm->cs = 110; goto _again;
	tr132:  sm->cs = 111; goto _again;
	tr133:  sm->cs = 112; goto _again;
	tr134:  sm->cs = 113; goto _again;
	tr135:  sm->cs = 114; goto _again;
	tr136:  sm->cs = 115; goto _again;
	tr137:  sm->cs = 116; goto _again;
	tr138:  sm->cs = 117; goto _again;
	tr420:  sm->cs = 118; goto _again;
	tr140:  sm->cs = 119; goto _again;
	tr141:  sm->cs = 120; goto _again;
	tr142:  sm->cs = 121; goto _again;
	tr143:  sm->cs = 122; goto _again;
	tr144:  sm->cs = 123; goto _again;
	tr423:  sm->cs = 124; goto _again;
	tr146:  sm->cs = 125; goto _again;
	tr147:  sm->cs = 126; goto _again;
	tr148:  sm->cs = 127; goto _again;
	tr149:  sm->cs = 128; goto _again;
	tr150:  sm->cs = 129; goto _again;
	tr426:  sm->cs = 130; goto _again;
	tr152:  sm->cs = 131; goto _again;
	tr153:  sm->cs = 132; goto _again;
	tr154:  sm->cs = 133; goto _again;
	tr155:  sm->cs = 134; goto _again;
	tr429:  sm->cs = 135; goto _again;
	tr157:  sm->cs = 136; goto _again;
	tr158:  sm->cs = 137; goto _again;
	tr159:  sm->cs = 138; goto _again;
	tr160:  sm->cs = 139; goto _again;
	tr161:  sm->cs = 140; goto _again;
	tr432:  sm->cs = 141; goto f4;
	tr164:  sm->cs = 142; goto _again;
	tr430:  sm->cs = 143; goto _again;
	tr166:  sm->cs = 144; goto _again;
	tr168:  sm->cs = 145; goto _again;
	tr169:  sm->cs = 146; goto _again;
	tr170:  sm->cs = 147; goto _again;
	tr167:  sm->cs = 148; goto _again;
	tr172:  sm->cs = 149; goto _again;
	tr173:  sm->cs = 150; goto _again;
	tr174:  sm->cs = 151; goto _again;
	tr440:  sm->cs = 152; goto _again;
	tr176:  sm->cs = 153; goto _again;
	tr177:  sm->cs = 154; goto _again;
	tr178:  sm->cs = 155; goto _again;
	tr179:  sm->cs = 156; goto _again;
	tr180:  sm->cs = 157; goto _again;
	tr442:  sm->cs = 158; goto f4;
	tr183:  sm->cs = 159; goto _again;
	tr446:  sm->cs = 160; goto _again;
	tr185:  sm->cs = 161; goto _again;
	tr186:  sm->cs = 162; goto _again;
	tr187:  sm->cs = 163; goto _again;
	tr188:  sm->cs = 164; goto _again;
	tr449:  sm->cs = 165; goto _again;
	tr190:  sm->cs = 166; goto _again;
	tr191:  sm->cs = 167; goto _again;
	tr199:  sm->cs = 168; goto _again;
	tr200:  sm->cs = 169; goto _again;
	tr201:  sm->cs = 170; goto _again;
	tr192:  sm->cs = 171; goto _again;
	tr203:  sm->cs = 172; goto _again;
	tr204:  sm->cs = 173; goto _again;
	tr205:  sm->cs = 174; goto _again;
	tr206:  sm->cs = 175; goto _again;
	tr207:  sm->cs = 176; goto _again;
	tr193:  sm->cs = 177; goto _again;
	tr194:  sm->cs = 178; goto _again;
	tr210:  sm->cs = 179; goto _again;
	tr211:  sm->cs = 180; goto _again;
	tr212:  sm->cs = 181; goto _again;
	tr213:  sm->cs = 182; goto _again;
	tr195:  sm->cs = 183; goto _again;
	tr215:  sm->cs = 184; goto _again;
	tr217:  sm->cs = 185; goto _again;
	tr218:  sm->cs = 186; goto _again;
	tr219:  sm->cs = 187; goto _again;
	tr220:  sm->cs = 188; goto _again;
	tr221:  sm->cs = 189; goto _again;
	tr222:  sm->cs = 190; goto _again;
	tr196:  sm->cs = 191; goto _again;
	tr224:  sm->cs = 192; goto _again;
	tr225:  sm->cs = 193; goto _again;
	tr226:  sm->cs = 194; goto _again;
	tr197:  sm->cs = 195; goto _again;
	tr450:  sm->cs = 196; goto _again;
	tr451:  sm->cs = 197; goto _again;
	tr232:  sm->cs = 198; goto _again;
	tr233:  sm->cs = 199; goto _again;
	tr234:  sm->cs = 200; goto _again;
	tr452:  sm->cs = 201; goto _again;
	tr236:  sm->cs = 202; goto _again;
	tr237:  sm->cs = 203; goto _again;
	tr238:  sm->cs = 204; goto _again;
	tr239:  sm->cs = 205; goto _again;
	tr240:  sm->cs = 206; goto _again;
	tr453:  sm->cs = 207; goto _again;
	tr454:  sm->cs = 208; goto _again;
	tr243:  sm->cs = 209; goto _again;
	tr244:  sm->cs = 210; goto _again;
	tr245:  sm->cs = 211; goto _again;
	tr246:  sm->cs = 212; goto _again;
	tr247:  sm->cs = 213; goto _again;
	tr248:  sm->cs = 214; goto _again;
	tr455:  sm->cs = 215; goto _again;
	tr250:  sm->cs = 216; goto _again;
	tr251:  sm->cs = 217; goto _again;
	tr252:  sm->cs = 218; goto _again;
	tr253:  sm->cs = 219; goto _again;
	tr456:  sm->cs = 220; goto _again;
	tr255:  sm->cs = 221; goto _again;
	tr257:  sm->cs = 222; goto _again;
	tr258:  sm->cs = 223; goto _again;
	tr259:  sm->cs = 224; goto _again;
	tr260:  sm->cs = 225; goto _again;
	tr261:  sm->cs = 226; goto _again;
	tr262:  sm->cs = 227; goto _again;
	tr457:  sm->cs = 228; goto _again;
	tr264:  sm->cs = 229; goto _again;
	tr458:  sm->cs = 230; goto _again;
	tr459:  sm->cs = 231; goto _again;
	tr269:  sm->cs = 232; goto _again;
	tr267:  sm->cs = 232; goto f7;
	tr270:  sm->cs = 233; goto f4;
	tr271:  sm->cs = 234; goto f4;
	tr274:  sm->cs = 235; goto _again;
	tr273:  sm->cs = 235; goto f3;
	tr275:  sm->cs = 236; goto f5;
	tr277:  sm->cs = 237; goto _again;
	tr268:  sm->cs = 237; goto f7;
	tr461:  sm->cs = 238; goto _again;
	tr278:  sm->cs = 239; goto _again;
	tr279:  sm->cs = 240; goto _again;
	tr280:  sm->cs = 241; goto _again;
	tr282:  sm->cs = 242; goto _again;
	tr283:  sm->cs = 243; goto _again;
	tr284:  sm->cs = 244; goto _again;
	tr285:  sm->cs = 245; goto _again;
	tr286:  sm->cs = 246; goto _again;
	tr281:  sm->cs = 247; goto _again;
	tr463:  sm->cs = 248; goto _again;
	tr289:  sm->cs = 249; goto _again;
	tr288:  sm->cs = 249; goto f7;
	tr290:  sm->cs = 250; goto f4;
	tr467:  sm->cs = 251; goto _again;
	tr293:  sm->cs = 252; goto _again;
	tr294:  sm->cs = 253; goto _again;
	tr295:  sm->cs = 254; goto _again;
	tr296:  sm->cs = 255; goto _again;
	tr471:  sm->cs = 256; goto _again;
	tr299:  sm->cs = 257; goto _again;
	tr300:  sm->cs = 258; goto _again;
	tr301:  sm->cs = 259; goto _again;
	tr302:  sm->cs = 260; goto _again;
	tr303:  sm->cs = 261; goto _again;
	tr304:  sm->cs = 262; goto _again;
	tr305:  sm->cs = 263; goto _again;
	tr475:  sm->cs = 264; goto _again;
	tr308:  sm->cs = 265; goto _again;
	tr309:  sm->cs = 266; goto _again;
	tr313:  sm->cs = 267; goto _again;
	tr314:  sm->cs = 268; goto _again;
	tr315:  sm->cs = 269; goto _again;
	tr310:  sm->cs = 270; goto _again;
	tr317:  sm->cs = 271; goto _again;
	tr318:  sm->cs = 272; goto _again;
	tr319:  sm->cs = 273; goto _again;
	tr311:  sm->cs = 274; goto _again;
	tr321:  sm->cs = 275; goto _again;
	tr322:  sm->cs = 276; goto _again;
	tr323:  sm->cs = 277; goto _again;
	tr312:  sm->cs = 278; goto _again;
	tr476:  sm->cs = 279; goto _again;
	tr326:  sm->cs = 280; goto _again;
	tr330:  sm->cs = 281; goto _again;
	tr331:  sm->cs = 282; goto _again;
	tr332:  sm->cs = 283; goto _again;
	tr327:  sm->cs = 284; goto _again;
	tr328:  sm->cs = 285; goto _again;
	tr335:  sm->cs = 286; goto _again;
	tr337:  sm->cs = 287; goto _again;
	tr338:  sm->cs = 288; goto _again;
	tr329:  sm->cs = 289; goto _again;
	tr481:  sm->cs = 290; goto _again;
	tr346:  sm->cs = 291; goto f4;
	tr347:  sm->cs = 292; goto _again;
	tr0:  sm->cs = 293; goto f0;
	tr2:  sm->cs = 293; goto f2;
	tr20:  sm->cs = 293; goto f6;
	tr60:  sm->cs = 293; goto f8;
	tr61:  sm->cs = 293; goto f9;
	tr348:  sm->cs = 293; goto f65;
	tr355:  sm->cs = 293; goto f68;
	tr356:  sm->cs = 293; goto f69;
	tr359:  sm->cs = 293; goto f70;
	tr361:  sm->cs = 293; goto f71;
	tr370:  sm->cs = 293; goto f72;
	tr371:  sm->cs = 293; goto f73;
	tr373:  sm->cs = 293; goto f74;
	tr374:  sm->cs = 293; goto f75;
	tr375:  sm->cs = 293; goto f76;
	tr376:  sm->cs = 293; goto f77;
	tr1:  sm->cs = 294; goto f1;
	tr349:  sm->cs = 294; goto f66;
	tr350:  sm->cs = 295; goto _again;
	tr351:  sm->cs = 296; goto f19;
	tr357:  sm->cs = 297; goto _again;
	tr3:  sm->cs = 297; goto f3;
	tr4:  sm->cs = 298; goto f3;
	tr352:  sm->cs = 299; goto f67;
	tr360:  sm->cs = 300; goto _again;
	tr11:  sm->cs = 300; goto f5;
	tr362:  sm->cs = 301; goto _again;
	tr8:  sm->cs = 301; goto f4;
	tr353:  sm->cs = 302; goto f67;
	tr24:  sm->cs = 303; goto _again;
	tr372:  sm->cs = 304; goto _again;
	tr34:  sm->cs = 304; goto f4;
	tr31:  sm->cs = 305; goto _again;
	tr41:  sm->cs = 306; goto _again;
	tr46:  sm->cs = 307; goto _again;
	tr54:  sm->cs = 308; goto _again;
	tr62:  sm->cs = 309; goto f10;
	tr64:  sm->cs = 309; goto f12;
	tr69:  sm->cs = 309; goto f13;
	tr86:  sm->cs = 309; goto f15;
	tr109:  sm->cs = 309; goto f16;
	tr121:  sm->cs = 309; goto f17;
	tr163:  sm->cs = 309; goto f20;
	tr182:  sm->cs = 309; goto f21;
	tr198:  sm->cs = 309; goto f22;
	tr202:  sm->cs = 309; goto f23;
	tr208:  sm->cs = 309; goto f24;
	tr209:  sm->cs = 309; goto f25;
	tr216:  sm->cs = 309; goto f26;
	tr223:  sm->cs = 309; goto f27;
	tr227:  sm->cs = 309; goto f28;
	tr228:  sm->cs = 309; goto f29;
	tr229:  sm->cs = 309; goto f30;
	tr230:  sm->cs = 309; goto f31;
	tr231:  sm->cs = 309; goto f32;
	tr235:  sm->cs = 309; goto f33;
	tr241:  sm->cs = 309; goto f34;
	tr242:  sm->cs = 309; goto f35;
	tr249:  sm->cs = 309; goto f36;
	tr254:  sm->cs = 309; goto f37;
	tr256:  sm->cs = 309; goto f38;
	tr263:  sm->cs = 309; goto f39;
	tr265:  sm->cs = 309; goto f40;
	tr266:  sm->cs = 309; goto f41;
	tr272:  sm->cs = 309; goto f42;
	tr276:  sm->cs = 309; goto f43;
	tr291:  sm->cs = 309; goto f45;
	tr377:  sm->cs = 309; goto f78;
	tr394:  sm->cs = 309; goto f81;
	tr397:  sm->cs = 309; goto f82;
	tr398:  sm->cs = 309; goto f83;
	tr400:  sm->cs = 309; goto f84;
	tr401:  sm->cs = 309; goto f85;
	tr403:  sm->cs = 309; goto f86;
	tr410:  sm->cs = 309; goto f88;
	tr412:  sm->cs = 309; goto f89;
	tr415:  sm->cs = 309; goto f91;
	tr418:  sm->cs = 309; goto f92;
	tr421:  sm->cs = 309; goto f93;
	tr424:  sm->cs = 309; goto f94;
	tr427:  sm->cs = 309; goto f95;
	tr431:  sm->cs = 309; goto f96;
	tr434:  sm->cs = 309; goto f97;
	tr436:  sm->cs = 309; goto f98;
	tr438:  sm->cs = 309; goto f99;
	tr441:  sm->cs = 309; goto f100;
	tr444:  sm->cs = 309; goto f101;
	tr447:  sm->cs = 309; goto f102;
	tr460:  sm->cs = 309; goto f103;
	tr462:  sm->cs = 309; goto f104;
	tr378:  sm->cs = 310; goto f79;
	tr63:  sm->cs = 311; goto f11;
	tr399:  sm->cs = 312; goto _again;
	tr67:  sm->cs = 312; goto f3;
	tr68:  sm->cs = 313; goto f3;
	tr379:  sm->cs = 314; goto _again;
	tr380:  sm->cs = 315; goto f80;
	tr79:  sm->cs = 316; goto f14;
	tr381:  sm->cs = 317; goto f67;
	tr382:  sm->cs = 318; goto f80;
	tr122:  sm->cs = 319; goto f18;
	tr413:  sm->cs = 319; goto f90;
	tr409:  sm->cs = 320; goto f87;
	tr383:  sm->cs = 321; goto f67;
	tr416:  sm->cs = 322; goto _again;
	tr131:  sm->cs = 322; goto f7;
	tr384:  sm->cs = 323; goto f67;
	tr419:  sm->cs = 324; goto _again;
	tr139:  sm->cs = 324; goto f7;
	tr385:  sm->cs = 325; goto f67;
	tr422:  sm->cs = 326; goto _again;
	tr145:  sm->cs = 326; goto f7;
	tr386:  sm->cs = 327; goto f67;
	tr425:  sm->cs = 328; goto _again;
	tr151:  sm->cs = 328; goto f7;
	tr387:  sm->cs = 329; goto f67;
	tr428:  sm->cs = 330; goto _again;
	tr156:  sm->cs = 330; goto f7;
	tr388:  sm->cs = 331; goto f67;
	tr162:  sm->cs = 332; goto f19;
	tr433:  sm->cs = 332; goto f67;
	tr435:  sm->cs = 333; goto _again;
	tr165:  sm->cs = 333; goto f3;
	tr437:  sm->cs = 334; goto _again;
	tr171:  sm->cs = 334; goto f7;
	tr439:  sm->cs = 335; goto _again;
	tr175:  sm->cs = 335; goto f7;
	tr389:  sm->cs = 336; goto f67;
	tr181:  sm->cs = 337; goto f19;
	tr443:  sm->cs = 337; goto f67;
	tr445:  sm->cs = 338; goto _again;
	tr184:  sm->cs = 338; goto f3;
	tr390:  sm->cs = 339; goto f67;
	tr448:  sm->cs = 340; goto _again;
	tr189:  sm->cs = 340; goto f7;
	tr391:  sm->cs = 341; goto f67;
	tr214:  sm->cs = 342; goto _again;
	tr392:  sm->cs = 343; goto f80;
	tr287:  sm->cs = 344; goto f44;
	tr393:  sm->cs = 345; goto f67;
	tr292:  sm->cs = 346; goto f46;
	tr297:  sm->cs = 346; goto f47;
	tr464:  sm->cs = 346; goto f105;
	tr466:  sm->cs = 346; goto f106;
	tr465:  sm->cs = 347; goto f67;
	tr298:  sm->cs = 348; goto f48;
	tr306:  sm->cs = 348; goto f49;
	tr468:  sm->cs = 348; goto f107;
	tr470:  sm->cs = 348; goto f108;
	tr469:  sm->cs = 349; goto f67;
	tr307:  sm->cs = 350; goto f50;
	tr316:  sm->cs = 350; goto f51;
	tr320:  sm->cs = 350; goto f52;
	tr324:  sm->cs = 350; goto f53;
	tr325:  sm->cs = 350; goto f54;
	tr333:  sm->cs = 350; goto f55;
	tr334:  sm->cs = 350; goto f56;
	tr336:  sm->cs = 350; goto f57;
	tr339:  sm->cs = 350; goto f58;
	tr340:  sm->cs = 350; goto f59;
	tr472:  sm->cs = 350; goto f109;
	tr474:  sm->cs = 350; goto f110;
	tr473:  sm->cs = 351; goto f67;
	tr341:  sm->cs = 352; goto f60;
	tr343:  sm->cs = 352; goto f62;
	tr477:  sm->cs = 352; goto f111;
	tr482:  sm->cs = 352; goto f113;
	tr483:  sm->cs = 352; goto f114;
	tr342:  sm->cs = 353; goto f61;
	tr478:  sm->cs = 353; goto f112;
	tr479:  sm->cs = 354; goto _again;
	tr480:  sm->cs = 355; goto f19;
	tr484:  sm->cs = 356; goto _again;
	tr344:  sm->cs = 356; goto f3;
	tr345:  sm->cs = 357; goto f3;

f7:
#line 76 "ext/dtext/dtext.rl"
	{
  sm->a1 = sm->p;
}
	goto _again;
f4:
#line 80 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
	goto _again;
f3:
#line 84 "ext/dtext/dtext.rl"
	{
  sm->b1 = sm->p;
}
	goto _again;
f5:
#line 88 "ext/dtext/dtext.rl"
	{
  sm->b2 = sm->p;
}
	goto _again;
f67:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
	goto _again;
f45:
#line 199 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    append_link(sm, "", "<a rel=\"nofollow\" class=\"dtext-link dtext-post-search-link\" href=\"/posts?tags=");
  }}
	goto _again;
f42:
#line 203 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    append_wiki_link(sm, sm->a1, sm->a2 - sm->a1, sm->a1, sm->a2 - sm->a1);
  }}
	goto _again;
f43:
#line 207 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    append_wiki_link(sm, sm->a1, sm->a2 - sm->a1, sm->b1, sm->b2 - sm->b1);
  }}
	goto _again;
f17:
#line 259 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    append(sm, true, "<a href=\"");
    append_segment_html_escaped(sm, sm->ts + 1, sm->te - 2);
    append(sm, true, "\">");
    append_segment_html_escaped(sm, sm->ts + 1, sm->te - 2);
    append(sm, true, "</a>");
  }}
	goto _again;
f32:
#line 325 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_open_inline(sm, INLINE_B, "<strong>");
  }}
	goto _again;
f22:
#line 329 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_close_inline(sm, INLINE_B, "</strong>");
  }}
	goto _again;
f35:
#line 333 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_open_inline(sm, INLINE_I, "<em>");
  }}
	goto _again;
f25:
#line 337 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_close_inline(sm, INLINE_I, "</em>");
  }}
	goto _again;
f38:
#line 341 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_open_inline(sm, INLINE_S, "<s>");
  }}
	goto _again;
f26:
#line 345 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_close_inline(sm, INLINE_S, "</s>");
  }}
	goto _again;
f41:
#line 349 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_open_inline(sm, INLINE_U, "<u>");
  }}
	goto _again;
f31:
#line 353 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_close_inline(sm, INLINE_U, "</u>");
  }}
	goto _again;
f40:
#line 357 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_open_inline(sm, INLINE_TN, "<span class=\"tn\">");
  }}
	goto _again;
f30:
#line 361 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_close_before_block(sm);

    if (dstack_check(sm, INLINE_TN)) {
      dstack_close_inline(sm, INLINE_TN, "</span>");
    } else if (dstack_close_block(sm, BLOCK_TN, "</p>")) {
      { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)];goto _again;}
    }
  }}
	goto _again;
f33:
#line 371 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_open_inline(sm, INLINE_CODE, "<code>");
  }}
	goto _again;
f23:
#line 375 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_close_inline(sm, INLINE_CODE, "</code>");
  }}
	goto _again;
f39:
#line 379 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_open_inline(sm, INLINE_SPOILER, "<span class=\"spoiler\">");
  }}
	goto _again;
f27:
#line 383 "ext/dtext/dtext.rl"
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
f36:
#line 394 "ext/dtext/dtext.rl"
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
{( ((int *)sm->stack->data))[( sm->top)++] =  sm->cs;  sm->cs = 348;goto _again;}}
  }}
	goto _again;
f37:
#line 402 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    g_debug("inline [quote]");
    dstack_close_before_block(sm);
    {( sm->p) = (( sm->ts))-1;}
    { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)];goto _again;}
  }}
	goto _again;
f34:
#line 425 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    g_debug("inline [expand]");
    dstack_rewind(sm);
    {( sm->p) = (((sm->p - 7)))-1;}
    { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)];goto _again;}
  }}
	goto _again;
f24:
#line 432 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_close_before_block(sm);

    if (dstack_close_block(sm, BLOCK_EXPAND, "</div></div>")) {
      { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)];goto _again;}
    }
  }}
	goto _again;
f29:
#line 440 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    if (dstack_close_block(sm, BLOCK_TH, "</th>")) {
      { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)];goto _again;}
    }
  }}
	goto _again;
f28:
#line 446 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    if (dstack_close_block(sm, BLOCK_TD, "</td>")) {
      { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)];goto _again;}
    }
  }}
	goto _again;
f78:
#line 480 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    g_debug("inline char: %c", (*( sm->p)));
    append_c_html_escaped(sm, (*( sm->p)));
  }}
	goto _again;
f104:
#line 243 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    const char* match_end = sm->te - 1;
    const char* url_start = sm->ts;
    const char* url_end = find_boundary_c(match_end);

    append(sm, true, "<a href=\"");
    append_segment_html_escaped(sm, url_start, url_end);
    append(sm, true, "\">");
    append_segment_html_escaped(sm, url_start, url_end);
    append(sm, true, "</a>");

    if (url_end < match_end) {
      append_segment_html_escaped(sm, url_end + 1, match_end);
    }
  }}
	goto _again;
f103:
#line 409 "ext/dtext/dtext.rl"
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
f82:
#line 452 "ext/dtext/dtext.rl"
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
f81:
#line 464 "ext/dtext/dtext.rl"
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
f84:
#line 476 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append_c(sm, ' ');
  }}
	goto _again;
f85:
#line 480 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    g_debug("inline char: %c", (*( sm->p)));
    append_c_html_escaped(sm, (*( sm->p)));
  }}
	goto _again;
f21:
#line 163 "ext/dtext/dtext.rl"
	{{( sm->p) = ((( sm->te)))-1;}{
    append_link(sm, "topic #", "<a class=\"dtext-link dtext-id-link dtext-forum-topic-id-link\" href=\"/forum_topics/");
  }}
	goto _again;
f20:
#line 191 "ext/dtext/dtext.rl"
	{{( sm->p) = ((( sm->te)))-1;}{
    append_link(sm, "pixiv #", "<a class=\"dtext-link dtext-id-link dtext-pixiv-id-link\" href=\"http://www.pixiv.net/member_illust.php?mode=medium&illust_id=");
  }}
	goto _again;
f12:
#line 464 "ext/dtext/dtext.rl"
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
f13:
#line 480 "ext/dtext/dtext.rl"
	{{( sm->p) = ((( sm->te)))-1;}{
    g_debug("inline char: %c", (*( sm->p)));
    append_c_html_escaped(sm, (*( sm->p)));
  }}
	goto _again;
f10:
#line 1 "NONE"
	{	switch( ( sm->act) ) {
	case 16:
	{{( sm->p) = ((( sm->te)))-1;}
    const char* match_end = sm->b2 - 1;
    const char* url_start = sm->b1;
    const char* url_end = find_boundary_c(match_end);

    append(sm, true, "<a class=\"dtext-link dtext-external-link\" href=\"");
    append_segment_html_escaped(sm, url_start, url_end);
    append(sm, true, "\">");

    if (!parse_inline(sm, sm->a1, sm->a2 - sm->a1)) {
        {( sm->p)++; goto _out; }
    }

    append(sm, true, "</a>");

    if (url_end < match_end) {
      append_segment_html_escaped(sm, url_end + 1, match_end);
    }
  }
	break;
	case 18:
	{{( sm->p) = ((( sm->te)))-1;}
    const char* match_end = sm->te - 1;
    const char* url_start = sm->ts;
    const char* url_end = find_boundary_c(match_end);

    append(sm, true, "<a href=\"");
    append_segment_html_escaped(sm, url_start, url_end);
    append(sm, true, "\">");
    append_segment_html_escaped(sm, url_start, url_end);
    append(sm, true, "</a>");

    if (url_end < match_end) {
      append_segment_html_escaped(sm, url_end + 1, match_end);
    }
  }
	break;
	case 20:
	{{( sm->p) = ((( sm->te)))-1;}
    append_segment_html_escaped(sm, sm->ts, sm->te - 1);
  }
	break;
	case 21:
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
	case 45:
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
	case 46:
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
	case 48:
	{{( sm->p) = ((( sm->te)))-1;}
    g_debug("inline char: %c", (*( sm->p)));
    append_c_html_escaped(sm, (*( sm->p)));
  }
	break;
	}
	}
	goto _again;
f47:
#line 487 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    if (dstack_check(sm, BLOCK_CODE)) {
      dstack_rewind(sm);
    } else {
      append(sm, true, "[/code]");
    }
    { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)];goto _again;}
  }}
	goto _again;
f105:
#line 496 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    append_c_html_escaped(sm, (*( sm->p)));
  }}
	goto _again;
f106:
#line 496 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append_c_html_escaped(sm, (*( sm->p)));
  }}
	goto _again;
f46:
#line 496 "ext/dtext/dtext.rl"
	{{( sm->p) = ((( sm->te)))-1;}{
    append_c_html_escaped(sm, (*( sm->p)));
  }}
	goto _again;
f49:
#line 502 "ext/dtext/dtext.rl"
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
f107:
#line 519 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    append_c_html_escaped(sm, (*( sm->p)));
  }}
	goto _again;
f108:
#line 519 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append_c_html_escaped(sm, (*( sm->p)));
  }}
	goto _again;
f48:
#line 519 "ext/dtext/dtext.rl"
	{{( sm->p) = ((( sm->te)))-1;}{
    append_c_html_escaped(sm, (*( sm->p)));
  }}
	goto _again;
f58:
#line 525 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_open_block(sm, BLOCK_THEAD, "<thead>");
  }}
	goto _again;
f53:
#line 529 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_close_block(sm, BLOCK_THEAD, "</thead>");
  }}
	goto _again;
f55:
#line 533 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_open_block(sm, BLOCK_TBODY, "<tbody>");
  }}
	goto _again;
f52:
#line 537 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_close_block(sm, BLOCK_TBODY, "</tbody>");
  }}
	goto _again;
f57:
#line 541 "ext/dtext/dtext.rl"
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
{( ((int *)sm->stack->data))[( sm->top)++] =  sm->cs;  sm->cs = 309;goto _again;}}
  }}
	goto _again;
f59:
#line 546 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_open_block(sm, BLOCK_TR, "<tr>");
  }}
	goto _again;
f54:
#line 550 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_close_block(sm, BLOCK_TR, "</tr>");
  }}
	goto _again;
f56:
#line 554 "ext/dtext/dtext.rl"
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
{( ((int *)sm->stack->data))[( sm->top)++] =  sm->cs;  sm->cs = 309;goto _again;}}
  }}
	goto _again;
f51:
#line 559 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    if (dstack_close_block(sm, BLOCK_TABLE, "</table>")) {
      { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)];goto _again;}
    }
  }}
	goto _again;
f109:
#line 565 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;}
	goto _again;
f110:
#line 565 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;}
	goto _again;
f50:
#line 565 "ext/dtext/dtext.rl"
	{{( sm->p) = ((( sm->te)))-1;}}
	goto _again;
f111:
#line 610 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_rewind(sm);
    ( sm->p)--;
    { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)];goto _again;}
  }}
	goto _again;
f113:
#line 610 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    dstack_rewind(sm);
    ( sm->p)--;
    { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)];goto _again;}
  }}
	goto _again;
f62:
#line 610 "ext/dtext/dtext.rl"
	{{( sm->p) = ((( sm->te)))-1;}{
    dstack_rewind(sm);
    ( sm->p)--;
    { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)];goto _again;}
  }}
	goto _again;
f60:
#line 1 "NONE"
	{	switch( ( sm->act) ) {
	case 64:
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
#line 732 "ext/dtext/dtext.rl"
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
#line 774 "ext/dtext/dtext.rl"
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
{( ((int *)sm->stack->data))[( sm->top)++] =  sm->cs;  sm->cs = 350;goto _again;}}
  }}
	goto _again;
f9:
#line 780 "ext/dtext/dtext.rl"
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
{( ((int *)sm->stack->data))[( sm->top)++] =  sm->cs;  sm->cs = 309;goto _again;}}
  }}
	goto _again;
f65:
#line 812 "ext/dtext/dtext.rl"
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
{( ((int *)sm->stack->data))[( sm->top)++] =  sm->cs;  sm->cs = 309;goto _again;}}
  }}
	goto _again;
f70:
#line 618 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    char header = *sm->a1;
    g_autoptr(GString) id_name = g_string_new_len(sm->b1, sm->b2 - sm->b1);
    id_name = g_string_prepend(id_name, "dtext-");

    if (sm->f_inline) {
      header = '6';
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
{( ((int *)sm->stack->data))[( sm->top)++] =  sm->cs;  sm->cs = 309;goto _again;}}
  }}
	goto _again;
f71:
#line 677 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    char header = *sm->a1;

    if (sm->f_inline) {
      header = '6';
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
{( ((int *)sm->stack->data))[( sm->top)++] =  sm->cs;  sm->cs = 309;goto _again;}}
  }}
	goto _again;
f76:
#line 722 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    dstack_close_before_block(sm);
    dstack_open_block(sm, BLOCK_QUOTE, "<blockquote>");
  }}
	goto _again;
f77:
#line 727 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    dstack_close_before_block(sm);
    dstack_open_block(sm, BLOCK_SPOILER, "<div class=\"spoiler\">");
  }}
	goto _again;
f72:
#line 741 "ext/dtext/dtext.rl"
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
{( ((int *)sm->stack->data))[( sm->top)++] =  sm->cs;  sm->cs = 346;goto _again;}}
  }}
	goto _again;
f74:
#line 747 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    dstack_close_before_block(sm);
    const char* html = "<div class=\"expandable\"><div class=\"expandable-header\">"
                       "<input type=\"button\" value=\"Show\" class=\"expandable-button\"/></div>"
                       "<div class=\"expandable-content\">";
    dstack_open_block(sm, BLOCK_EXPAND, html);
  }}
	goto _again;
f73:
#line 755 "ext/dtext/dtext.rl"
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
f75:
#line 767 "ext/dtext/dtext.rl"
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
{( ((int *)sm->stack->data))[( sm->top)++] =  sm->cs;  sm->cs = 348;goto _again;}}
  }}
	goto _again;
f68:
#line 812 "ext/dtext/dtext.rl"
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
{( ((int *)sm->stack->data))[( sm->top)++] =  sm->cs;  sm->cs = 309;goto _again;}}
  }}
	goto _again;
f2:
#line 812 "ext/dtext/dtext.rl"
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
{( ((int *)sm->stack->data))[( sm->top)++] =  sm->cs;  sm->cs = 309;goto _again;}}
  }}
	goto _again;
f0:
#line 1 "NONE"
	{	switch( ( sm->act) ) {
	case 79:
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
	case 80:
	{{( sm->p) = ((( sm->te)))-1;}
    g_debug("block newline");
  }
	break;
	}
	}
	goto _again;
f16:
#line 80 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
#line 295 "ext/dtext/dtext.rl"
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
f99:
#line 80 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
#line 146 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append_link(sm, "post #", "<a class=\"dtext-link dtext-id-link dtext-post-id-link\" href=\"/posts/");
  }}
	goto _again;
f95:
#line 80 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
#line 150 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append(sm, true, "<a class=\"dtext-link dtext-id-link dtext-note-id-link\" href=\"/notes/");
    append_segment(sm, true, sm->a1, sm->a2 - 1);
    append(sm, true, "\">");
    append(sm, false, "note #");
    append_segment(sm, false, sm->a1, sm->a2 - 1);
    append(sm, true, "</a>");
  }}
	goto _again;
f93:
#line 80 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
#line 159 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append_link(sm, "forum #", "<a class=\"dtext-link dtext-id-link dtext-forum-post-id-link\" href=\"/forum_posts/");
  }}
	goto _again;
f100:
#line 80 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
#line 163 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append_link(sm, "topic #", "<a class=\"dtext-link dtext-id-link dtext-forum-topic-id-link\" href=\"/forum_topics/");
  }}
	goto _again;
f92:
#line 80 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
#line 171 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append_link(sm, "comment #", "<a class=\"dtext-link dtext-id-link dtext-comment-id-link\" href=\"/comments/");
  }}
	goto _again;
f98:
#line 80 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
#line 175 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append_link(sm, "pool #", "<a class=\"dtext-link dtext-id-link dtext-pool-id-link\" href=\"/pools/");
  }}
	goto _again;
f102:
#line 80 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
#line 179 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append_link(sm, "user #", "<a class=\"dtext-link dtext-id-link dtext-user-id-link\" href=\"/users/");
  }}
	goto _again;
f91:
#line 80 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
#line 183 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append_link(sm, "artist #", "<a class=\"dtext-link dtext-id-link dtext-artist-id-link\" href=\"/artists/");
  }}
	goto _again;
f94:
#line 80 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
#line 187 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append_link(sm, "issue #", "<a class=\"dtext-link dtext-id-link dtext-github-id-link\" href=\"https://github.com/r888888888/danbooru/issues/");
  }}
	goto _again;
f96:
#line 80 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
#line 191 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append_link(sm, "pixiv #", "<a class=\"dtext-link dtext-id-link dtext-pixiv-id-link\" href=\"http://www.pixiv.net/member_illust.php?mode=medium&illust_id=");
  }}
	goto _again;
f89:
#line 80 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
#line 272 "ext/dtext/dtext.rl"
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
f88:
#line 80 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
#line 1 "NONE"
	{	switch( ( sm->act) ) {
	case 16:
	{{( sm->p) = ((( sm->te)))-1;}
    const char* match_end = sm->b2 - 1;
    const char* url_start = sm->b1;
    const char* url_end = find_boundary_c(match_end);

    append(sm, true, "<a class=\"dtext-link dtext-external-link\" href=\"");
    append_segment_html_escaped(sm, url_start, url_end);
    append(sm, true, "\">");

    if (!parse_inline(sm, sm->a1, sm->a2 - sm->a1)) {
        {( sm->p)++; goto _out; }
    }

    append(sm, true, "</a>");

    if (url_end < match_end) {
      append_segment_html_escaped(sm, url_end + 1, match_end);
    }
  }
	break;
	case 18:
	{{( sm->p) = ((( sm->te)))-1;}
    const char* match_end = sm->te - 1;
    const char* url_start = sm->ts;
    const char* url_end = find_boundary_c(match_end);

    append(sm, true, "<a href=\"");
    append_segment_html_escaped(sm, url_start, url_end);
    append(sm, true, "\">");
    append_segment_html_escaped(sm, url_start, url_end);
    append(sm, true, "</a>");

    if (url_end < match_end) {
      append_segment_html_escaped(sm, url_end + 1, match_end);
    }
  }
	break;
	case 20:
	{{( sm->p) = ((( sm->te)))-1;}
    append_segment_html_escaped(sm, sm->ts, sm->te - 1);
  }
	break;
	case 21:
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
	case 45:
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
	case 46:
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
	case 48:
	{{( sm->p) = ((( sm->te)))-1;}
    g_debug("inline char: %c", (*( sm->p)));
    append_c_html_escaped(sm, (*( sm->p)));
  }
	break;
	}
	}
	goto _again;
f15:
#line 88 "ext/dtext/dtext.rl"
	{
  sm->b2 = sm->p;
}
#line 231 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    append(sm, true, "<a class=\"dtext-link dtext-external-link\" href=\"");
    append_segment_html_escaped(sm, sm->b1, sm->b2 - 1);
    append(sm, true, "\">");

    if (!parse_inline(sm, sm->a1, sm->a2 - sm->a1)) {
        {( sm->p)++; goto _out; }
    }

    append(sm, true, "</a>");
  }}
	goto _again;
f101:
#line 88 "ext/dtext/dtext.rl"
	{
  sm->b2 = sm->p;
}
#line 167 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append_paged_link(sm, "topic #", "<a class=\"dtext-link dtext-id-link dtext-forum-topic-id-link\" href=\"/forum_topics/", "?page=");
  }}
	goto _again;
f97:
#line 88 "ext/dtext/dtext.rl"
	{
  sm->b2 = sm->p;
}
#line 195 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append_paged_link(sm, "pixiv #", "<a class=\"dtext-link dtext-id-link dtext-pixiv-id-link\" href=\"http://www.pixiv.net/member_illust.php?mode=manga_big&illust_id=", "&page=");
  }}
	goto _again;
f86:
#line 88 "ext/dtext/dtext.rl"
	{
  sm->b2 = sm->p;
}
#line 211 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    const char* match_end = sm->b2 - 1;
    const char* url_start = sm->b1;
    const char* url_end = find_boundary_c(match_end);

    append(sm, true, "<a class=\"dtext-link dtext-external-link\" href=\"");
    append_segment_html_escaped(sm, url_start, url_end);
    append(sm, true, "\">");

    if (!parse_inline(sm, sm->a1, sm->a2 - sm->a1)) {
        {( sm->p)++; goto _out; }
    }

    append(sm, true, "</a>");

    if (url_end < match_end) {
      append_segment_html_escaped(sm, url_end + 1, match_end);
    }
  }}
	goto _again;
f83:
#line 88 "ext/dtext/dtext.rl"
	{
  sm->b2 = sm->p;
}
#line 306 "ext/dtext/dtext.rl"
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
     sm->cs = 352;
  }}
	goto _again;
f114:
#line 88 "ext/dtext/dtext.rl"
	{
  sm->b2 = sm->p;
}
#line 569 "ext/dtext/dtext.rl"
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
{( ((int *)sm->stack->data))[( sm->top)++] =  sm->cs;  sm->cs = 309;goto _again;}}
  }}
	goto _again;
f69:
#line 88 "ext/dtext/dtext.rl"
	{
  sm->b2 = sm->p;
}
#line 785 "ext/dtext/dtext.rl"
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
{( ((int *)sm->stack->data))[( sm->top)++] =  sm->cs;  sm->cs = 352;goto _again;}}
  }}
	goto _again;
f19:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 76 "ext/dtext/dtext.rl"
	{
  sm->a1 = sm->p;
}
	goto _again;
f14:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 211 "ext/dtext/dtext.rl"
	{( sm->act) = 16;}
	goto _again;
f44:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 243 "ext/dtext/dtext.rl"
	{( sm->act) = 18;}
	goto _again;
f90:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 268 "ext/dtext/dtext.rl"
	{( sm->act) = 20;}
	goto _again;
f18:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 272 "ext/dtext/dtext.rl"
	{( sm->act) = 21;}
	goto _again;
f11:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 452 "ext/dtext/dtext.rl"
	{( sm->act) = 45;}
	goto _again;
f79:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 464 "ext/dtext/dtext.rl"
	{( sm->act) = 46;}
	goto _again;
f80:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 480 "ext/dtext/dtext.rl"
	{( sm->act) = 48;}
	goto _again;
f61:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 602 "ext/dtext/dtext.rl"
	{( sm->act) = 64;}
	goto _again;
f112:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 608 "ext/dtext/dtext.rl"
	{( sm->act) = 65;}
	goto _again;
f1:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 795 "ext/dtext/dtext.rl"
	{( sm->act) = 79;}
	goto _again;
f66:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 808 "ext/dtext/dtext.rl"
	{( sm->act) = 80;}
	goto _again;
f87:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 76 "ext/dtext/dtext.rl"
	{
  sm->a1 = sm->p;
}
#line 272 "ext/dtext/dtext.rl"
	{( sm->act) = 21;}
	goto _again;

_again:
	switch ( _dtext_to_state_actions[ sm->cs] ) {
	case 64:
#line 1 "NONE"
	{( sm->ts) = 0;}
	break;
#line 4665 "ext/dtext/dtext.c"
	}

	if ( ++( sm->p) != ( sm->pe) )
		goto _resume;
	_test_eof: {}
	if ( ( sm->p) == ( sm->eof) )
	{
	switch (  sm->cs ) {
	case 294: goto tr0;
	case 0: goto tr0;
	case 295: goto tr355;
	case 296: goto tr355;
	case 1: goto tr2;
	case 297: goto tr356;
	case 298: goto tr356;
	case 2: goto tr2;
	case 299: goto tr355;
	case 3: goto tr2;
	case 4: goto tr2;
	case 5: goto tr2;
	case 300: goto tr359;
	case 301: goto tr361;
	case 302: goto tr355;
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
	case 303: goto tr370;
	case 19: goto tr2;
	case 20: goto tr2;
	case 21: goto tr2;
	case 22: goto tr2;
	case 23: goto tr2;
	case 24: goto tr2;
	case 25: goto tr2;
	case 26: goto tr2;
	case 304: goto tr371;
	case 305: goto tr373;
	case 27: goto tr2;
	case 28: goto tr2;
	case 29: goto tr2;
	case 30: goto tr2;
	case 31: goto tr2;
	case 32: goto tr2;
	case 33: goto tr2;
	case 306: goto tr374;
	case 34: goto tr2;
	case 35: goto tr2;
	case 36: goto tr2;
	case 37: goto tr2;
	case 38: goto tr2;
	case 307: goto tr375;
	case 39: goto tr2;
	case 40: goto tr2;
	case 41: goto tr2;
	case 42: goto tr2;
	case 43: goto tr2;
	case 44: goto tr2;
	case 45: goto tr2;
	case 46: goto tr2;
	case 308: goto tr376;
	case 47: goto tr2;
	case 48: goto tr2;
	case 49: goto tr2;
	case 50: goto tr2;
	case 51: goto tr2;
	case 52: goto tr2;
	case 310: goto tr394;
	case 311: goto tr397;
	case 53: goto tr62;
	case 54: goto tr64;
	case 55: goto tr64;
	case 312: goto tr398;
	case 313: goto tr398;
	case 314: goto tr400;
	case 315: goto tr401;
	case 56: goto tr69;
	case 57: goto tr69;
	case 58: goto tr69;
	case 59: goto tr69;
	case 60: goto tr62;
	case 316: goto tr403;
	case 61: goto tr62;
	case 62: goto tr62;
	case 63: goto tr69;
	case 64: goto tr69;
	case 65: goto tr69;
	case 66: goto tr69;
	case 67: goto tr69;
	case 68: goto tr69;
	case 69: goto tr69;
	case 70: goto tr69;
	case 71: goto tr69;
	case 72: goto tr69;
	case 73: goto tr69;
	case 74: goto tr69;
	case 75: goto tr69;
	case 76: goto tr69;
	case 77: goto tr69;
	case 78: goto tr69;
	case 79: goto tr69;
	case 80: goto tr69;
	case 81: goto tr69;
	case 82: goto tr69;
	case 317: goto tr401;
	case 83: goto tr69;
	case 84: goto tr69;
	case 85: goto tr69;
	case 86: goto tr69;
	case 87: goto tr69;
	case 88: goto tr69;
	case 89: goto tr69;
	case 90: goto tr69;
	case 91: goto tr69;
	case 92: goto tr69;
	case 93: goto tr69;
	case 94: goto tr69;
	case 95: goto tr69;
	case 96: goto tr69;
	case 97: goto tr69;
	case 98: goto tr69;
	case 99: goto tr69;
	case 318: goto tr401;
	case 100: goto tr62;
	case 319: goto tr410;
	case 101: goto tr62;
	case 102: goto tr62;
	case 320: goto tr412;
	case 321: goto tr401;
	case 103: goto tr69;
	case 104: goto tr69;
	case 105: goto tr69;
	case 106: goto tr69;
	case 107: goto tr69;
	case 108: goto tr69;
	case 109: goto tr69;
	case 322: goto tr415;
	case 323: goto tr401;
	case 110: goto tr69;
	case 111: goto tr69;
	case 112: goto tr69;
	case 113: goto tr69;
	case 114: goto tr69;
	case 115: goto tr69;
	case 116: goto tr69;
	case 117: goto tr69;
	case 324: goto tr418;
	case 325: goto tr401;
	case 118: goto tr69;
	case 119: goto tr69;
	case 120: goto tr69;
	case 121: goto tr69;
	case 122: goto tr69;
	case 123: goto tr69;
	case 326: goto tr421;
	case 327: goto tr401;
	case 124: goto tr69;
	case 125: goto tr69;
	case 126: goto tr69;
	case 127: goto tr69;
	case 128: goto tr69;
	case 129: goto tr69;
	case 328: goto tr424;
	case 329: goto tr401;
	case 130: goto tr69;
	case 131: goto tr69;
	case 132: goto tr69;
	case 133: goto tr69;
	case 134: goto tr69;
	case 330: goto tr427;
	case 331: goto tr401;
	case 135: goto tr69;
	case 136: goto tr69;
	case 137: goto tr69;
	case 138: goto tr69;
	case 139: goto tr69;
	case 140: goto tr69;
	case 332: goto tr431;
	case 141: goto tr163;
	case 142: goto tr163;
	case 333: goto tr434;
	case 143: goto tr69;
	case 144: goto tr69;
	case 145: goto tr69;
	case 146: goto tr69;
	case 147: goto tr69;
	case 334: goto tr436;
	case 148: goto tr69;
	case 149: goto tr69;
	case 150: goto tr69;
	case 151: goto tr69;
	case 335: goto tr438;
	case 336: goto tr401;
	case 152: goto tr69;
	case 153: goto tr69;
	case 154: goto tr69;
	case 155: goto tr69;
	case 156: goto tr69;
	case 157: goto tr69;
	case 337: goto tr441;
	case 158: goto tr182;
	case 159: goto tr182;
	case 338: goto tr444;
	case 339: goto tr401;
	case 160: goto tr69;
	case 161: goto tr69;
	case 162: goto tr69;
	case 163: goto tr69;
	case 164: goto tr69;
	case 340: goto tr447;
	case 341: goto tr401;
	case 165: goto tr69;
	case 166: goto tr69;
	case 167: goto tr69;
	case 168: goto tr69;
	case 169: goto tr69;
	case 170: goto tr69;
	case 171: goto tr69;
	case 172: goto tr69;
	case 173: goto tr69;
	case 174: goto tr69;
	case 175: goto tr69;
	case 176: goto tr69;
	case 177: goto tr69;
	case 178: goto tr69;
	case 179: goto tr69;
	case 180: goto tr69;
	case 181: goto tr69;
	case 182: goto tr69;
	case 342: goto tr460;
	case 183: goto tr69;
	case 184: goto tr69;
	case 185: goto tr69;
	case 186: goto tr69;
	case 187: goto tr69;
	case 188: goto tr69;
	case 189: goto tr69;
	case 190: goto tr69;
	case 191: goto tr69;
	case 192: goto tr69;
	case 193: goto tr69;
	case 194: goto tr69;
	case 195: goto tr69;
	case 196: goto tr69;
	case 197: goto tr69;
	case 198: goto tr69;
	case 199: goto tr69;
	case 200: goto tr69;
	case 201: goto tr69;
	case 202: goto tr69;
	case 203: goto tr69;
	case 204: goto tr69;
	case 205: goto tr69;
	case 206: goto tr69;
	case 207: goto tr69;
	case 208: goto tr69;
	case 209: goto tr69;
	case 210: goto tr69;
	case 211: goto tr69;
	case 212: goto tr69;
	case 213: goto tr69;
	case 214: goto tr69;
	case 215: goto tr69;
	case 216: goto tr69;
	case 217: goto tr69;
	case 218: goto tr69;
	case 219: goto tr69;
	case 220: goto tr69;
	case 221: goto tr69;
	case 222: goto tr69;
	case 223: goto tr69;
	case 224: goto tr69;
	case 225: goto tr69;
	case 226: goto tr69;
	case 227: goto tr69;
	case 228: goto tr69;
	case 229: goto tr69;
	case 230: goto tr69;
	case 231: goto tr69;
	case 232: goto tr69;
	case 233: goto tr69;
	case 234: goto tr69;
	case 235: goto tr69;
	case 236: goto tr69;
	case 237: goto tr69;
	case 343: goto tr401;
	case 238: goto tr69;
	case 239: goto tr69;
	case 240: goto tr69;
	case 241: goto tr69;
	case 242: goto tr69;
	case 243: goto tr69;
	case 244: goto tr62;
	case 344: goto tr462;
	case 245: goto tr62;
	case 246: goto tr62;
	case 247: goto tr69;
	case 345: goto tr401;
	case 248: goto tr69;
	case 249: goto tr69;
	case 250: goto tr69;
	case 347: goto tr466;
	case 251: goto tr292;
	case 252: goto tr292;
	case 253: goto tr292;
	case 254: goto tr292;
	case 255: goto tr292;
	case 349: goto tr470;
	case 256: goto tr298;
	case 257: goto tr298;
	case 258: goto tr298;
	case 259: goto tr298;
	case 260: goto tr298;
	case 261: goto tr298;
	case 262: goto tr298;
	case 263: goto tr298;
	case 351: goto tr474;
	case 264: goto tr307;
	case 265: goto tr307;
	case 266: goto tr307;
	case 267: goto tr307;
	case 268: goto tr307;
	case 269: goto tr307;
	case 270: goto tr307;
	case 271: goto tr307;
	case 272: goto tr307;
	case 273: goto tr307;
	case 274: goto tr307;
	case 275: goto tr307;
	case 276: goto tr307;
	case 277: goto tr307;
	case 278: goto tr307;
	case 279: goto tr307;
	case 280: goto tr307;
	case 281: goto tr307;
	case 282: goto tr307;
	case 283: goto tr307;
	case 284: goto tr307;
	case 285: goto tr307;
	case 286: goto tr307;
	case 287: goto tr307;
	case 288: goto tr307;
	case 289: goto tr307;
	case 353: goto tr341;
	case 290: goto tr341;
	case 354: goto tr482;
	case 355: goto tr482;
	case 291: goto tr343;
	case 356: goto tr483;
	case 357: goto tr483;
	case 292: goto tr343;
	}
	}

	_out: {}
	}

#line 1213 "ext/dtext/dtext.rl"

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
