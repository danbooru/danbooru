
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

static const int BLOCK_P = 1;
static const int INLINE_SPOILER = 2;
static const int BLOCK_SPOILER = 3;
static const int BLOCK_QUOTE = 4;
static const int BLOCK_EXPAND = 5;
static const int BLOCK_NODTEXT = 6;
static const int BLOCK_CODE = 7;
static const int BLOCK_TD = 8;
static const int INLINE_NODTEXT = 9;
static const int INLINE_B = 10;
static const int INLINE_I = 11;
static const int INLINE_U = 12;
static const int INLINE_S = 13;
static const int INLINE_TN = 14;
static const int BLOCK_TN = 15;
static const int BLOCK_TABLE = 16;
static const int BLOCK_THEAD = 17;
static const int BLOCK_TBODY = 18;
static const int BLOCK_TR = 19;
static const int BLOCK_UL = 20;
static const int BLOCK_LI = 21;
static const int BLOCK_TH = 22;
static const int BLOCK_H1 = 23;
static const int BLOCK_H2 = 24;
static const int BLOCK_H3 = 25;
static const int BLOCK_H4 = 26;
static const int BLOCK_H5 = 27;
static const int BLOCK_H6 = 28;
static const int INLINE_CODE = 29;


#line 1050 "ext/dtext/dtext.rl"



#line 54 "ext/dtext/dtext.c"
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
	0, 0, 0, 0, 0, 0, 0, 62, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 62, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 62, 0, 62, 0, 62, 0, 62, 
	0, 0, 0, 0, 0
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
	0, 0, 0, 0, 0, 0, 0, 63, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 63, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 63, 0, 63, 0, 63, 0, 63, 
	0, 0, 0, 0, 0
};

static const int dtext_start = 271;
static const int dtext_first_final = 271;
static const int dtext_error = -1;

static const int dtext_en_inline = 287;
static const int dtext_en_code = 321;
static const int dtext_en_nodtext = 323;
static const int dtext_en_table = 325;
static const int dtext_en_list = 327;
static const int dtext_en_main = 271;


#line 1053 "ext/dtext/dtext.rl"

static inline void underscore_string(char * str, size_t len) {
  for (size_t i=0; i<len; ++i) {
    if (str[i] == ' ') {
      str[i] = '_';
    }
  }
}

static inline void dstack_push(StateMachine * sm, const int * element) {
  g_queue_push_tail(sm->dstack, (gpointer)element);
}

static inline int * dstack_pop(StateMachine * sm) {
  return g_queue_pop_tail(sm->dstack);
}

static inline int * dstack_peek(StateMachine * sm) {
  return g_queue_peek_tail(sm->dstack);
}

/*
static inline bool dstack_search(StateMachine * sm, const int * element) {
  return g_queue_find(sm->dstack, (gconstpointer)element);
}
*/

static inline bool dstack_check(StateMachine * sm, int expected_element) {
  int * top = dstack_peek(sm);
  return top && *top == expected_element;
}

static inline bool dstack_check2(StateMachine * sm, int expected_element) {
  int * top2 = NULL;

  if (sm->dstack->length < 2) {
    return false;
  }

  top2 = g_queue_peek_nth(sm->dstack, sm->dstack->length - 2);
  return top2 && *top2 == expected_element;
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

  char * segment1 = NULL;
  char * segment2 = NULL;
  GString * segment_string = g_string_new_len(a, b - a + 1);

  segment1 = g_uri_escape_string(segment_string->str, NULL, TRUE);
  segment2 = g_markup_escape_text(segment1, -1);
  sm->output = g_string_append(sm->output, segment2);
  g_string_free(segment_string, TRUE);
  g_free(segment1);
  g_free(segment2);
}

static inline void append_segment_html_escaped(StateMachine * sm, const char * a, const char * b) {
  gchar * segment = g_markup_escape_text(a, b - a + 1);
  sm->output = g_string_append(sm->output, segment);
  g_free(segment);
}

static inline void append_block(StateMachine * sm, const char * s) {
  if (sm->f_inline) {
    // sm->output = g_string_append_c(sm->output, ' ');
  } else if (sm->f_strip) {
    // do nothing
  } else {
    sm->output = g_string_append(sm->output, s);
  }
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

static void dstack_rewind(StateMachine * sm) {
  int * element = dstack_pop(sm);

  if (element == NULL) {
    return;
  }

  if (*element == BLOCK_P) {
    append_closing_p(sm);

  } else if (*element == INLINE_SPOILER) {
    append(sm, true, "</span>");

  } else if (*element == BLOCK_SPOILER) {
    append_block(sm, "</div>");

  } else if (*element == BLOCK_QUOTE) {
    append_block(sm, "</blockquote>");

  } else if (*element == BLOCK_EXPAND) {
    append_block(sm, "</div></div>");

  } else if (*element == BLOCK_NODTEXT) {
    append_closing_p(sm);

  } else if (*element == BLOCK_CODE) {
    append_block(sm, "</pre>");

  } else if (*element == BLOCK_TD) {
    append_block(sm, "</td>");

  } else if (*element == INLINE_NODTEXT) {

  } else if (*element == INLINE_B) {
    append(sm, true, "</strong>");

  } else if (*element == INLINE_I) {
    append(sm, true, "</em>");

  } else if (*element == INLINE_U) {
    append(sm, true, "</u>");

  } else if (*element == INLINE_S) {
    append(sm, true, "</s>");

  } else if (*element == INLINE_TN) {
    append(sm, true, "</span>");

  } else if (*element == INLINE_CODE) {
    append(sm, true, "</code>");

  } else if (*element == BLOCK_TN) {
    append_closing_p(sm);

  } else if (*element == BLOCK_TABLE) {
    append_block(sm, "</table>");

  } else if (*element == BLOCK_THEAD) {
    append_block(sm, "</thead>");

  } else if (*element == BLOCK_TBODY) {
    append_block(sm, "</tbody>");

  } else if (*element == BLOCK_TR) {
    append_block(sm, "</tr>");

  } else if (*element == BLOCK_UL) {
    append_block(sm, "</ul>");

  } else if (*element == BLOCK_LI) {
    append_block(sm, "</li>");

  } else if (*element == BLOCK_H6) {
    append_block(sm, "</h6>");

  } else if (*element == BLOCK_H5) {
    append_block(sm, "</h5>");

  } else if (*element == BLOCK_H4) {
    append_block(sm, "</h4>");

  } else if (*element == BLOCK_H3) {
    append_block(sm, "</h3>");

  } else if (*element == BLOCK_H2) {
    append_block(sm, "</h2>");

  } else if (*element == BLOCK_H1) {
    append_block(sm, "</h1>");
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
  while (dstack_peek(sm) != NULL) {
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

static inline bool is_boundary_c(char c) {
  switch (c) {
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
      return true;
  }

  return false;
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
  g_array_free(sm->stack, FALSE);
  g_queue_free(sm->dstack);
  g_clear_error(&sm->error);
  g_free(sm);
}

GQuark dtext_parse_error_quark() {
  return g_quark_from_static_string("dtext-parse-error-quark");
}

gboolean parse_helper(StateMachine* sm) {
  StateMachine* link_content_sm = NULL;

  g_debug("start\n");

  
#line 499 "ext/dtext/dtext.c"
	{
	 sm->cs = dtext_start;
	( sm->top) = 0;
	( sm->ts) = 0;
	( sm->te) = 0;
	( sm->act) = 0;
	}

#line 1394 "ext/dtext/dtext.rl"
  
#line 510 "ext/dtext/dtext.c"
	{
	if ( ( sm->p) == ( sm->pe) )
		goto _test_eof;
_resume:
	switch ( _dtext_from_state_actions[ sm->cs] ) {
	case 63:
#line 1 "NONE"
	{( sm->ts) = ( sm->p);}
	break;
#line 520 "ext/dtext/dtext.c"
	}

	switch (  sm->cs ) {
case 271:
	switch( (*( sm->p)) ) {
		case 0: goto tr323;
		case 10: goto tr324;
		case 13: goto tr325;
		case 42: goto tr326;
		case 72: goto tr327;
		case 91: goto tr328;
		case 104: goto tr327;
	}
	goto tr322;
case 272:
	switch( (*( sm->p)) ) {
		case 10: goto tr1;
		case 13: goto tr329;
	}
	goto tr0;
case 0:
	if ( (*( sm->p)) == 10 )
		goto tr1;
	goto tr0;
case 273:
	if ( (*( sm->p)) == 10 )
		goto tr324;
	goto tr330;
case 274:
	switch( (*( sm->p)) ) {
		case 9: goto tr5;
		case 32: goto tr5;
		case 42: goto tr6;
	}
	goto tr330;
case 1:
	switch( (*( sm->p)) ) {
		case 0: goto tr2;
		case 9: goto tr4;
		case 10: goto tr2;
		case 13: goto tr2;
		case 32: goto tr4;
	}
	goto tr3;
case 275:
	switch( (*( sm->p)) ) {
		case 0: goto tr331;
		case 10: goto tr331;
		case 13: goto tr331;
	}
	goto tr332;
case 276:
	switch( (*( sm->p)) ) {
		case 0: goto tr331;
		case 9: goto tr4;
		case 10: goto tr331;
		case 13: goto tr331;
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
case 277:
	if ( 49 <= (*( sm->p)) && (*( sm->p)) <= 54 )
		goto tr333;
	goto tr330;
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
case 278:
	switch( (*( sm->p)) ) {
		case 9: goto tr335;
		case 32: goto tr335;
	}
	goto tr334;
case 279:
	switch( (*( sm->p)) ) {
		case 9: goto tr337;
		case 32: goto tr337;
	}
	goto tr336;
case 280:
	switch( (*( sm->p)) ) {
		case 47: goto tr338;
		case 67: goto tr339;
		case 69: goto tr340;
		case 78: goto tr341;
		case 81: goto tr342;
		case 83: goto tr343;
		case 84: goto tr344;
		case 99: goto tr339;
		case 101: goto tr340;
		case 110: goto tr341;
		case 113: goto tr342;
		case 115: goto tr343;
		case 116: goto tr344;
	}
	goto tr330;
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
case 281:
	if ( (*( sm->p)) == 32 )
		goto tr24;
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr24;
	goto tr345;
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
case 282:
	if ( (*( sm->p)) == 32 )
		goto tr347;
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr347;
	goto tr346;
case 283:
	if ( (*( sm->p)) == 32 )
		goto tr31;
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr31;
	goto tr348;
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
case 284:
	if ( (*( sm->p)) == 32 )
		goto tr41;
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr41;
	goto tr349;
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
case 285:
	if ( (*( sm->p)) == 32 )
		goto tr46;
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr46;
	goto tr350;
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
case 286:
	if ( (*( sm->p)) == 32 )
		goto tr54;
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr54;
	goto tr351;
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
case 287:
	switch( (*( sm->p)) ) {
		case 0: goto tr353;
		case 10: goto tr354;
		case 13: goto tr355;
		case 34: goto tr356;
		case 64: goto tr357;
		case 65: goto tr358;
		case 67: goto tr359;
		case 70: goto tr360;
		case 73: goto tr361;
		case 80: goto tr362;
		case 84: goto tr363;
		case 85: goto tr364;
		case 91: goto tr365;
		case 97: goto tr358;
		case 99: goto tr359;
		case 102: goto tr360;
		case 104: goto tr366;
		case 105: goto tr361;
		case 112: goto tr362;
		case 116: goto tr363;
		case 117: goto tr364;
		case 123: goto tr367;
	}
	goto tr352;
case 288:
	switch( (*( sm->p)) ) {
		case 10: goto tr63;
		case 13: goto tr369;
		case 42: goto tr370;
	}
	goto tr368;
case 289:
	switch( (*( sm->p)) ) {
		case 10: goto tr63;
		case 13: goto tr369;
	}
	goto tr371;
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
		case 0: goto tr64;
		case 9: goto tr68;
		case 10: goto tr64;
		case 13: goto tr64;
		case 32: goto tr68;
	}
	goto tr67;
case 290:
	switch( (*( sm->p)) ) {
		case 0: goto tr372;
		case 10: goto tr372;
		case 13: goto tr372;
	}
	goto tr373;
case 291:
	switch( (*( sm->p)) ) {
		case 0: goto tr372;
		case 9: goto tr68;
		case 10: goto tr372;
		case 13: goto tr372;
		case 32: goto tr68;
	}
	goto tr67;
case 292:
	if ( (*( sm->p)) == 10 )
		goto tr354;
	goto tr374;
case 293:
	if ( (*( sm->p)) == 34 )
		goto tr375;
	goto tr376;
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
case 294:
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
	goto tr377;
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
case 295:
	if ( (*( sm->p)) < -32 ) {
		if ( -62 <= (*( sm->p)) && (*( sm->p)) <= -33 )
			goto tr378;
	} else if ( (*( sm->p)) > -17 ) {
		if ( (*( sm->p)) > -12 ) {
			if ( 33 <= (*( sm->p)) && (*( sm->p)) <= 126 )
				goto tr381;
		} else if ( (*( sm->p)) >= -16 )
			goto tr380;
	} else
		goto tr379;
	goto tr375;
case 83:
	if ( (*( sm->p)) <= -65 )
		goto tr101;
	goto tr62;
case 296:
	if ( (*( sm->p)) < -32 ) {
		if ( -62 <= (*( sm->p)) && (*( sm->p)) <= -33 )
			goto tr102;
	} else if ( (*( sm->p)) > -17 ) {
		if ( (*( sm->p)) > -12 ) {
			if ( 33 <= (*( sm->p)) && (*( sm->p)) <= 126 )
				goto tr101;
		} else if ( (*( sm->p)) >= -16 )
			goto tr383;
	} else
		goto tr103;
	goto tr382;
case 84:
	if ( (*( sm->p)) <= -65 )
		goto tr102;
	goto tr62;
case 85:
	if ( (*( sm->p)) <= -65 )
		goto tr103;
	goto tr62;
case 297:
	if ( (*( sm->p)) == 64 )
		goto tr385;
	if ( (*( sm->p)) < -32 ) {
		if ( -62 <= (*( sm->p)) && (*( sm->p)) <= -33 )
			goto tr102;
	} else if ( (*( sm->p)) > -17 ) {
		if ( (*( sm->p)) > -12 ) {
			if ( 33 <= (*( sm->p)) && (*( sm->p)) <= 126 )
				goto tr101;
		} else if ( (*( sm->p)) >= -16 )
			goto tr383;
	} else
		goto tr103;
	goto tr384;
case 298:
	switch( (*( sm->p)) ) {
		case 82: goto tr386;
		case 114: goto tr386;
	}
	goto tr375;
case 86:
	switch( (*( sm->p)) ) {
		case 84: goto tr104;
		case 116: goto tr104;
	}
	goto tr69;
case 87:
	switch( (*( sm->p)) ) {
		case 73: goto tr105;
		case 105: goto tr105;
	}
	goto tr69;
case 88:
	switch( (*( sm->p)) ) {
		case 83: goto tr106;
		case 115: goto tr106;
	}
	goto tr69;
case 89:
	switch( (*( sm->p)) ) {
		case 84: goto tr107;
		case 116: goto tr107;
	}
	goto tr69;
case 90:
	if ( (*( sm->p)) == 32 )
		goto tr108;
	goto tr69;
case 91:
	if ( (*( sm->p)) == 35 )
		goto tr109;
	goto tr69;
case 92:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr110;
	goto tr69;
case 299:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr388;
	goto tr387;
case 300:
	switch( (*( sm->p)) ) {
		case 79: goto tr389;
		case 111: goto tr389;
	}
	goto tr375;
case 93:
	switch( (*( sm->p)) ) {
		case 77: goto tr111;
		case 109: goto tr111;
	}
	goto tr69;
case 94:
	switch( (*( sm->p)) ) {
		case 77: goto tr112;
		case 109: goto tr112;
	}
	goto tr69;
case 95:
	switch( (*( sm->p)) ) {
		case 69: goto tr113;
		case 101: goto tr113;
	}
	goto tr69;
case 96:
	switch( (*( sm->p)) ) {
		case 78: goto tr114;
		case 110: goto tr114;
	}
	goto tr69;
case 97:
	switch( (*( sm->p)) ) {
		case 84: goto tr115;
		case 116: goto tr115;
	}
	goto tr69;
case 98:
	if ( (*( sm->p)) == 32 )
		goto tr116;
	goto tr69;
case 99:
	if ( (*( sm->p)) == 35 )
		goto tr117;
	goto tr69;
case 100:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr118;
	goto tr69;
case 301:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr391;
	goto tr390;
case 302:
	switch( (*( sm->p)) ) {
		case 79: goto tr392;
		case 111: goto tr392;
	}
	goto tr375;
case 101:
	switch( (*( sm->p)) ) {
		case 82: goto tr119;
		case 114: goto tr119;
	}
	goto tr69;
case 102:
	switch( (*( sm->p)) ) {
		case 85: goto tr120;
		case 117: goto tr120;
	}
	goto tr69;
case 103:
	switch( (*( sm->p)) ) {
		case 77: goto tr121;
		case 109: goto tr121;
	}
	goto tr69;
case 104:
	if ( (*( sm->p)) == 32 )
		goto tr122;
	goto tr69;
case 105:
	if ( (*( sm->p)) == 35 )
		goto tr123;
	goto tr69;
case 106:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr124;
	goto tr69;
case 303:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr394;
	goto tr393;
case 304:
	switch( (*( sm->p)) ) {
		case 83: goto tr395;
		case 115: goto tr395;
	}
	goto tr375;
case 107:
	switch( (*( sm->p)) ) {
		case 83: goto tr125;
		case 115: goto tr125;
	}
	goto tr69;
case 108:
	switch( (*( sm->p)) ) {
		case 85: goto tr126;
		case 117: goto tr126;
	}
	goto tr69;
case 109:
	switch( (*( sm->p)) ) {
		case 69: goto tr127;
		case 101: goto tr127;
	}
	goto tr69;
case 110:
	if ( (*( sm->p)) == 32 )
		goto tr128;
	goto tr69;
case 111:
	if ( (*( sm->p)) == 35 )
		goto tr129;
	goto tr69;
case 112:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr130;
	goto tr69;
case 305:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr397;
	goto tr396;
case 306:
	switch( (*( sm->p)) ) {
		case 73: goto tr398;
		case 79: goto tr399;
		case 105: goto tr398;
		case 111: goto tr399;
	}
	goto tr375;
case 113:
	switch( (*( sm->p)) ) {
		case 88: goto tr131;
		case 120: goto tr131;
	}
	goto tr69;
case 114:
	switch( (*( sm->p)) ) {
		case 73: goto tr132;
		case 105: goto tr132;
	}
	goto tr69;
case 115:
	switch( (*( sm->p)) ) {
		case 86: goto tr133;
		case 118: goto tr133;
	}
	goto tr69;
case 116:
	if ( (*( sm->p)) == 32 )
		goto tr134;
	goto tr69;
case 117:
	if ( (*( sm->p)) == 35 )
		goto tr135;
	goto tr69;
case 118:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr136;
	goto tr69;
case 307:
	if ( (*( sm->p)) == 47 )
		goto tr401;
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr402;
	goto tr400;
case 119:
	if ( (*( sm->p)) == 112 )
		goto tr138;
	goto tr137;
case 120:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr139;
	goto tr137;
case 308:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr404;
	goto tr403;
case 121:
	switch( (*( sm->p)) ) {
		case 79: goto tr140;
		case 83: goto tr141;
		case 111: goto tr140;
		case 115: goto tr141;
	}
	goto tr69;
case 122:
	switch( (*( sm->p)) ) {
		case 76: goto tr142;
		case 108: goto tr142;
	}
	goto tr69;
case 123:
	if ( (*( sm->p)) == 32 )
		goto tr143;
	goto tr69;
case 124:
	if ( (*( sm->p)) == 35 )
		goto tr144;
	goto tr69;
case 125:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr145;
	goto tr69;
case 309:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr406;
	goto tr405;
case 126:
	switch( (*( sm->p)) ) {
		case 84: goto tr146;
		case 116: goto tr146;
	}
	goto tr69;
case 127:
	if ( (*( sm->p)) == 32 )
		goto tr147;
	goto tr69;
case 128:
	if ( (*( sm->p)) == 35 )
		goto tr148;
	goto tr69;
case 129:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr149;
	goto tr69;
case 310:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr408;
	goto tr407;
case 311:
	switch( (*( sm->p)) ) {
		case 79: goto tr409;
		case 111: goto tr409;
	}
	goto tr375;
case 130:
	switch( (*( sm->p)) ) {
		case 80: goto tr150;
		case 112: goto tr150;
	}
	goto tr69;
case 131:
	switch( (*( sm->p)) ) {
		case 73: goto tr151;
		case 105: goto tr151;
	}
	goto tr69;
case 132:
	switch( (*( sm->p)) ) {
		case 67: goto tr152;
		case 99: goto tr152;
	}
	goto tr69;
case 133:
	if ( (*( sm->p)) == 32 )
		goto tr153;
	goto tr69;
case 134:
	if ( (*( sm->p)) == 35 )
		goto tr154;
	goto tr69;
case 135:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr155;
	goto tr69;
case 312:
	if ( (*( sm->p)) == 47 )
		goto tr411;
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr412;
	goto tr410;
case 136:
	if ( (*( sm->p)) == 112 )
		goto tr157;
	goto tr156;
case 137:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr158;
	goto tr156;
case 313:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr414;
	goto tr413;
case 314:
	switch( (*( sm->p)) ) {
		case 83: goto tr415;
		case 115: goto tr415;
	}
	goto tr375;
case 138:
	switch( (*( sm->p)) ) {
		case 69: goto tr159;
		case 101: goto tr159;
	}
	goto tr69;
case 139:
	switch( (*( sm->p)) ) {
		case 82: goto tr160;
		case 114: goto tr160;
	}
	goto tr69;
case 140:
	if ( (*( sm->p)) == 32 )
		goto tr161;
	goto tr69;
case 141:
	if ( (*( sm->p)) == 35 )
		goto tr162;
	goto tr69;
case 142:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr163;
	goto tr69;
case 315:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr417;
	goto tr416;
case 316:
	switch( (*( sm->p)) ) {
		case 47: goto tr418;
		case 66: goto tr419;
		case 67: goto tr420;
		case 69: goto tr421;
		case 73: goto tr422;
		case 78: goto tr423;
		case 81: goto tr424;
		case 83: goto tr425;
		case 84: goto tr426;
		case 85: goto tr427;
		case 91: goto tr428;
		case 98: goto tr419;
		case 99: goto tr420;
		case 101: goto tr421;
		case 105: goto tr422;
		case 110: goto tr423;
		case 113: goto tr424;
		case 115: goto tr425;
		case 116: goto tr426;
		case 117: goto tr427;
	}
	goto tr375;
case 143:
	switch( (*( sm->p)) ) {
		case 66: goto tr164;
		case 67: goto tr165;
		case 69: goto tr166;
		case 73: goto tr167;
		case 81: goto tr168;
		case 83: goto tr169;
		case 84: goto tr170;
		case 85: goto tr171;
		case 98: goto tr164;
		case 99: goto tr165;
		case 101: goto tr166;
		case 105: goto tr167;
		case 113: goto tr168;
		case 115: goto tr169;
		case 116: goto tr170;
		case 117: goto tr171;
	}
	goto tr69;
case 144:
	if ( (*( sm->p)) == 93 )
		goto tr172;
	goto tr69;
case 145:
	switch( (*( sm->p)) ) {
		case 79: goto tr173;
		case 111: goto tr173;
	}
	goto tr69;
case 146:
	switch( (*( sm->p)) ) {
		case 68: goto tr174;
		case 100: goto tr174;
	}
	goto tr69;
case 147:
	switch( (*( sm->p)) ) {
		case 69: goto tr175;
		case 101: goto tr175;
	}
	goto tr69;
case 148:
	if ( (*( sm->p)) == 93 )
		goto tr176;
	goto tr69;
case 149:
	switch( (*( sm->p)) ) {
		case 88: goto tr177;
		case 120: goto tr177;
	}
	goto tr69;
case 150:
	switch( (*( sm->p)) ) {
		case 80: goto tr178;
		case 112: goto tr178;
	}
	goto tr69;
case 151:
	switch( (*( sm->p)) ) {
		case 65: goto tr179;
		case 97: goto tr179;
	}
	goto tr69;
case 152:
	switch( (*( sm->p)) ) {
		case 78: goto tr180;
		case 110: goto tr180;
	}
	goto tr69;
case 153:
	switch( (*( sm->p)) ) {
		case 68: goto tr181;
		case 100: goto tr181;
	}
	goto tr69;
case 154:
	if ( (*( sm->p)) == 93 )
		goto tr182;
	goto tr69;
case 155:
	if ( (*( sm->p)) == 93 )
		goto tr183;
	goto tr69;
case 156:
	switch( (*( sm->p)) ) {
		case 85: goto tr184;
		case 117: goto tr184;
	}
	goto tr69;
case 157:
	switch( (*( sm->p)) ) {
		case 79: goto tr185;
		case 111: goto tr185;
	}
	goto tr69;
case 158:
	switch( (*( sm->p)) ) {
		case 84: goto tr186;
		case 116: goto tr186;
	}
	goto tr69;
case 159:
	switch( (*( sm->p)) ) {
		case 69: goto tr187;
		case 101: goto tr187;
	}
	goto tr69;
case 160:
	if ( (*( sm->p)) == 93 )
		goto tr188;
	goto tr69;
case 317:
	if ( (*( sm->p)) == 32 )
		goto tr188;
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr188;
	goto tr429;
case 161:
	switch( (*( sm->p)) ) {
		case 80: goto tr189;
		case 93: goto tr190;
		case 112: goto tr189;
	}
	goto tr69;
case 162:
	switch( (*( sm->p)) ) {
		case 79: goto tr191;
		case 111: goto tr191;
	}
	goto tr69;
case 163:
	switch( (*( sm->p)) ) {
		case 73: goto tr192;
		case 105: goto tr192;
	}
	goto tr69;
case 164:
	switch( (*( sm->p)) ) {
		case 76: goto tr193;
		case 108: goto tr193;
	}
	goto tr69;
case 165:
	switch( (*( sm->p)) ) {
		case 69: goto tr194;
		case 101: goto tr194;
	}
	goto tr69;
case 166:
	switch( (*( sm->p)) ) {
		case 82: goto tr195;
		case 114: goto tr195;
	}
	goto tr69;
case 167:
	switch( (*( sm->p)) ) {
		case 83: goto tr196;
		case 93: goto tr197;
		case 115: goto tr196;
	}
	goto tr69;
case 168:
	if ( (*( sm->p)) == 93 )
		goto tr197;
	goto tr69;
case 169:
	switch( (*( sm->p)) ) {
		case 68: goto tr198;
		case 72: goto tr199;
		case 78: goto tr200;
		case 100: goto tr198;
		case 104: goto tr199;
		case 110: goto tr200;
	}
	goto tr69;
case 170:
	if ( (*( sm->p)) == 93 )
		goto tr201;
	goto tr69;
case 171:
	if ( (*( sm->p)) == 93 )
		goto tr202;
	goto tr69;
case 172:
	if ( (*( sm->p)) == 93 )
		goto tr203;
	goto tr69;
case 173:
	if ( (*( sm->p)) == 93 )
		goto tr204;
	goto tr69;
case 174:
	if ( (*( sm->p)) == 93 )
		goto tr205;
	goto tr69;
case 175:
	switch( (*( sm->p)) ) {
		case 79: goto tr206;
		case 111: goto tr206;
	}
	goto tr69;
case 176:
	switch( (*( sm->p)) ) {
		case 68: goto tr207;
		case 100: goto tr207;
	}
	goto tr69;
case 177:
	switch( (*( sm->p)) ) {
		case 69: goto tr208;
		case 101: goto tr208;
	}
	goto tr69;
case 178:
	if ( (*( sm->p)) == 93 )
		goto tr209;
	goto tr69;
case 179:
	switch( (*( sm->p)) ) {
		case 88: goto tr210;
		case 120: goto tr210;
	}
	goto tr69;
case 180:
	switch( (*( sm->p)) ) {
		case 80: goto tr211;
		case 112: goto tr211;
	}
	goto tr69;
case 181:
	switch( (*( sm->p)) ) {
		case 65: goto tr212;
		case 97: goto tr212;
	}
	goto tr69;
case 182:
	switch( (*( sm->p)) ) {
		case 78: goto tr213;
		case 110: goto tr213;
	}
	goto tr69;
case 183:
	switch( (*( sm->p)) ) {
		case 68: goto tr214;
		case 100: goto tr214;
	}
	goto tr69;
case 184:
	if ( (*( sm->p)) == 93 )
		goto tr215;
	goto tr69;
case 185:
	if ( (*( sm->p)) == 93 )
		goto tr216;
	goto tr69;
case 186:
	switch( (*( sm->p)) ) {
		case 79: goto tr217;
		case 111: goto tr217;
	}
	goto tr69;
case 187:
	switch( (*( sm->p)) ) {
		case 68: goto tr218;
		case 100: goto tr218;
	}
	goto tr69;
case 188:
	switch( (*( sm->p)) ) {
		case 84: goto tr219;
		case 116: goto tr219;
	}
	goto tr69;
case 189:
	switch( (*( sm->p)) ) {
		case 69: goto tr220;
		case 101: goto tr220;
	}
	goto tr69;
case 190:
	switch( (*( sm->p)) ) {
		case 88: goto tr221;
		case 120: goto tr221;
	}
	goto tr69;
case 191:
	switch( (*( sm->p)) ) {
		case 84: goto tr222;
		case 116: goto tr222;
	}
	goto tr69;
case 192:
	if ( (*( sm->p)) == 93 )
		goto tr223;
	goto tr69;
case 193:
	switch( (*( sm->p)) ) {
		case 85: goto tr224;
		case 117: goto tr224;
	}
	goto tr69;
case 194:
	switch( (*( sm->p)) ) {
		case 79: goto tr225;
		case 111: goto tr225;
	}
	goto tr69;
case 195:
	switch( (*( sm->p)) ) {
		case 84: goto tr226;
		case 116: goto tr226;
	}
	goto tr69;
case 196:
	switch( (*( sm->p)) ) {
		case 69: goto tr227;
		case 101: goto tr227;
	}
	goto tr69;
case 197:
	if ( (*( sm->p)) == 93 )
		goto tr228;
	goto tr69;
case 198:
	switch( (*( sm->p)) ) {
		case 80: goto tr229;
		case 93: goto tr230;
		case 112: goto tr229;
	}
	goto tr69;
case 199:
	switch( (*( sm->p)) ) {
		case 79: goto tr231;
		case 111: goto tr231;
	}
	goto tr69;
case 200:
	switch( (*( sm->p)) ) {
		case 73: goto tr232;
		case 105: goto tr232;
	}
	goto tr69;
case 201:
	switch( (*( sm->p)) ) {
		case 76: goto tr233;
		case 108: goto tr233;
	}
	goto tr69;
case 202:
	switch( (*( sm->p)) ) {
		case 69: goto tr234;
		case 101: goto tr234;
	}
	goto tr69;
case 203:
	switch( (*( sm->p)) ) {
		case 82: goto tr235;
		case 114: goto tr235;
	}
	goto tr69;
case 204:
	switch( (*( sm->p)) ) {
		case 83: goto tr236;
		case 93: goto tr237;
		case 115: goto tr236;
	}
	goto tr69;
case 205:
	if ( (*( sm->p)) == 93 )
		goto tr237;
	goto tr69;
case 206:
	switch( (*( sm->p)) ) {
		case 78: goto tr238;
		case 110: goto tr238;
	}
	goto tr69;
case 207:
	if ( (*( sm->p)) == 93 )
		goto tr239;
	goto tr69;
case 208:
	if ( (*( sm->p)) == 93 )
		goto tr240;
	goto tr69;
case 209:
	switch( (*( sm->p)) ) {
		case 93: goto tr69;
		case 124: goto tr242;
	}
	goto tr241;
case 210:
	switch( (*( sm->p)) ) {
		case 93: goto tr244;
		case 124: goto tr245;
	}
	goto tr243;
case 211:
	if ( (*( sm->p)) == 93 )
		goto tr246;
	goto tr69;
case 212:
	switch( (*( sm->p)) ) {
		case 93: goto tr69;
		case 124: goto tr69;
	}
	goto tr247;
case 213:
	switch( (*( sm->p)) ) {
		case 93: goto tr249;
		case 124: goto tr69;
	}
	goto tr248;
case 214:
	if ( (*( sm->p)) == 93 )
		goto tr250;
	goto tr69;
case 215:
	switch( (*( sm->p)) ) {
		case 93: goto tr244;
		case 124: goto tr69;
	}
	goto tr251;
case 318:
	if ( (*( sm->p)) == 116 )
		goto tr430;
	goto tr375;
case 216:
	if ( (*( sm->p)) == 116 )
		goto tr252;
	goto tr69;
case 217:
	if ( (*( sm->p)) == 112 )
		goto tr253;
	goto tr69;
case 218:
	switch( (*( sm->p)) ) {
		case 58: goto tr254;
		case 115: goto tr255;
	}
	goto tr69;
case 219:
	if ( (*( sm->p)) == 47 )
		goto tr256;
	goto tr69;
case 220:
	if ( (*( sm->p)) == 47 )
		goto tr257;
	goto tr69;
case 221:
	if ( (*( sm->p)) < -32 ) {
		if ( -62 <= (*( sm->p)) && (*( sm->p)) <= -33 )
			goto tr258;
	} else if ( (*( sm->p)) > -17 ) {
		if ( (*( sm->p)) > -12 ) {
			if ( 33 <= (*( sm->p)) && (*( sm->p)) <= 126 )
				goto tr261;
		} else if ( (*( sm->p)) >= -16 )
			goto tr260;
	} else
		goto tr259;
	goto tr69;
case 222:
	if ( (*( sm->p)) <= -65 )
		goto tr261;
	goto tr62;
case 319:
	if ( (*( sm->p)) < -32 ) {
		if ( -62 <= (*( sm->p)) && (*( sm->p)) <= -33 )
			goto tr258;
	} else if ( (*( sm->p)) > -17 ) {
		if ( (*( sm->p)) > -12 ) {
			if ( 33 <= (*( sm->p)) && (*( sm->p)) <= 126 )
				goto tr261;
		} else if ( (*( sm->p)) >= -16 )
			goto tr260;
	} else
		goto tr259;
	goto tr431;
case 223:
	if ( (*( sm->p)) <= -65 )
		goto tr258;
	goto tr62;
case 224:
	if ( (*( sm->p)) <= -65 )
		goto tr259;
	goto tr62;
case 225:
	if ( (*( sm->p)) == 58 )
		goto tr254;
	goto tr69;
case 320:
	if ( (*( sm->p)) == 123 )
		goto tr432;
	goto tr375;
case 226:
	if ( (*( sm->p)) == 125 )
		goto tr69;
	goto tr262;
case 227:
	if ( (*( sm->p)) == 125 )
		goto tr264;
	goto tr263;
case 228:
	if ( (*( sm->p)) == 125 )
		goto tr265;
	goto tr69;
case 321:
	switch( (*( sm->p)) ) {
		case 0: goto tr434;
		case 91: goto tr435;
	}
	goto tr433;
case 322:
	if ( (*( sm->p)) == 47 )
		goto tr437;
	goto tr436;
case 229:
	switch( (*( sm->p)) ) {
		case 67: goto tr267;
		case 99: goto tr267;
	}
	goto tr266;
case 230:
	switch( (*( sm->p)) ) {
		case 79: goto tr268;
		case 111: goto tr268;
	}
	goto tr266;
case 231:
	switch( (*( sm->p)) ) {
		case 68: goto tr269;
		case 100: goto tr269;
	}
	goto tr266;
case 232:
	switch( (*( sm->p)) ) {
		case 69: goto tr270;
		case 101: goto tr270;
	}
	goto tr266;
case 233:
	if ( (*( sm->p)) == 93 )
		goto tr271;
	goto tr266;
case 323:
	switch( (*( sm->p)) ) {
		case 0: goto tr439;
		case 91: goto tr440;
	}
	goto tr438;
case 324:
	if ( (*( sm->p)) == 47 )
		goto tr442;
	goto tr441;
case 234:
	switch( (*( sm->p)) ) {
		case 78: goto tr273;
		case 110: goto tr273;
	}
	goto tr272;
case 235:
	switch( (*( sm->p)) ) {
		case 79: goto tr274;
		case 111: goto tr274;
	}
	goto tr272;
case 236:
	switch( (*( sm->p)) ) {
		case 68: goto tr275;
		case 100: goto tr275;
	}
	goto tr272;
case 237:
	switch( (*( sm->p)) ) {
		case 84: goto tr276;
		case 116: goto tr276;
	}
	goto tr272;
case 238:
	switch( (*( sm->p)) ) {
		case 69: goto tr277;
		case 101: goto tr277;
	}
	goto tr272;
case 239:
	switch( (*( sm->p)) ) {
		case 88: goto tr278;
		case 120: goto tr278;
	}
	goto tr272;
case 240:
	switch( (*( sm->p)) ) {
		case 84: goto tr279;
		case 116: goto tr279;
	}
	goto tr272;
case 241:
	if ( (*( sm->p)) == 93 )
		goto tr280;
	goto tr272;
case 325:
	switch( (*( sm->p)) ) {
		case 0: goto tr444;
		case 91: goto tr445;
	}
	goto tr443;
case 326:
	switch( (*( sm->p)) ) {
		case 47: goto tr447;
		case 84: goto tr448;
		case 116: goto tr448;
	}
	goto tr446;
case 242:
	switch( (*( sm->p)) ) {
		case 84: goto tr282;
		case 116: goto tr282;
	}
	goto tr281;
case 243:
	switch( (*( sm->p)) ) {
		case 65: goto tr283;
		case 66: goto tr284;
		case 72: goto tr285;
		case 82: goto tr286;
		case 97: goto tr283;
		case 98: goto tr284;
		case 104: goto tr285;
		case 114: goto tr286;
	}
	goto tr281;
case 244:
	switch( (*( sm->p)) ) {
		case 66: goto tr287;
		case 98: goto tr287;
	}
	goto tr281;
case 245:
	switch( (*( sm->p)) ) {
		case 76: goto tr288;
		case 108: goto tr288;
	}
	goto tr281;
case 246:
	switch( (*( sm->p)) ) {
		case 69: goto tr289;
		case 101: goto tr289;
	}
	goto tr281;
case 247:
	if ( (*( sm->p)) == 93 )
		goto tr290;
	goto tr281;
case 248:
	switch( (*( sm->p)) ) {
		case 79: goto tr291;
		case 111: goto tr291;
	}
	goto tr281;
case 249:
	switch( (*( sm->p)) ) {
		case 68: goto tr292;
		case 100: goto tr292;
	}
	goto tr281;
case 250:
	switch( (*( sm->p)) ) {
		case 89: goto tr293;
		case 121: goto tr293;
	}
	goto tr281;
case 251:
	if ( (*( sm->p)) == 93 )
		goto tr294;
	goto tr281;
case 252:
	switch( (*( sm->p)) ) {
		case 69: goto tr295;
		case 101: goto tr295;
	}
	goto tr281;
case 253:
	switch( (*( sm->p)) ) {
		case 65: goto tr296;
		case 97: goto tr296;
	}
	goto tr281;
case 254:
	switch( (*( sm->p)) ) {
		case 68: goto tr297;
		case 100: goto tr297;
	}
	goto tr281;
case 255:
	if ( (*( sm->p)) == 93 )
		goto tr298;
	goto tr281;
case 256:
	if ( (*( sm->p)) == 93 )
		goto tr299;
	goto tr281;
case 257:
	switch( (*( sm->p)) ) {
		case 66: goto tr300;
		case 68: goto tr301;
		case 72: goto tr302;
		case 82: goto tr303;
		case 98: goto tr300;
		case 100: goto tr301;
		case 104: goto tr302;
		case 114: goto tr303;
	}
	goto tr281;
case 258:
	switch( (*( sm->p)) ) {
		case 79: goto tr304;
		case 111: goto tr304;
	}
	goto tr281;
case 259:
	switch( (*( sm->p)) ) {
		case 68: goto tr305;
		case 100: goto tr305;
	}
	goto tr281;
case 260:
	switch( (*( sm->p)) ) {
		case 89: goto tr306;
		case 121: goto tr306;
	}
	goto tr281;
case 261:
	if ( (*( sm->p)) == 93 )
		goto tr307;
	goto tr281;
case 262:
	if ( (*( sm->p)) == 93 )
		goto tr308;
	goto tr281;
case 263:
	switch( (*( sm->p)) ) {
		case 69: goto tr309;
		case 93: goto tr310;
		case 101: goto tr309;
	}
	goto tr281;
case 264:
	switch( (*( sm->p)) ) {
		case 65: goto tr311;
		case 97: goto tr311;
	}
	goto tr281;
case 265:
	switch( (*( sm->p)) ) {
		case 68: goto tr312;
		case 100: goto tr312;
	}
	goto tr281;
case 266:
	if ( (*( sm->p)) == 93 )
		goto tr313;
	goto tr281;
case 267:
	if ( (*( sm->p)) == 93 )
		goto tr314;
	goto tr281;
case 327:
	switch( (*( sm->p)) ) {
		case 0: goto tr450;
		case 10: goto tr451;
		case 13: goto tr452;
		case 42: goto tr453;
	}
	goto tr449;
case 328:
	switch( (*( sm->p)) ) {
		case 10: goto tr316;
		case 13: goto tr454;
	}
	goto tr315;
case 268:
	if ( (*( sm->p)) == 10 )
		goto tr316;
	goto tr315;
case 329:
	if ( (*( sm->p)) == 10 )
		goto tr451;
	goto tr455;
case 330:
	switch( (*( sm->p)) ) {
		case 9: goto tr320;
		case 32: goto tr320;
		case 42: goto tr321;
	}
	goto tr455;
case 269:
	switch( (*( sm->p)) ) {
		case 0: goto tr317;
		case 9: goto tr319;
		case 10: goto tr317;
		case 13: goto tr317;
		case 32: goto tr319;
	}
	goto tr318;
case 331:
	switch( (*( sm->p)) ) {
		case 0: goto tr456;
		case 10: goto tr456;
		case 13: goto tr456;
	}
	goto tr457;
case 332:
	switch( (*( sm->p)) ) {
		case 0: goto tr456;
		case 9: goto tr319;
		case 10: goto tr456;
		case 13: goto tr456;
		case 32: goto tr319;
	}
	goto tr318;
case 270:
	switch( (*( sm->p)) ) {
		case 9: goto tr320;
		case 32: goto tr320;
		case 42: goto tr321;
	}
	goto tr317;
	}

	tr329:  sm->cs = 0; goto _again;
	tr5:  sm->cs = 1; goto f4;
	tr6:  sm->cs = 2; goto _again;
	tr333:  sm->cs = 3; goto f7;
	tr7:  sm->cs = 4; goto f4;
	tr10:  sm->cs = 5; goto _again;
	tr9:  sm->cs = 5; goto f3;
	tr338:  sm->cs = 6; goto _again;
	tr12:  sm->cs = 7; goto _again;
	tr13:  sm->cs = 8; goto _again;
	tr14:  sm->cs = 9; goto _again;
	tr15:  sm->cs = 10; goto _again;
	tr16:  sm->cs = 11; goto _again;
	tr17:  sm->cs = 12; goto _again;
	tr18:  sm->cs = 13; goto _again;
	tr19:  sm->cs = 14; goto _again;
	tr339:  sm->cs = 15; goto _again;
	tr21:  sm->cs = 16; goto _again;
	tr22:  sm->cs = 17; goto _again;
	tr23:  sm->cs = 18; goto _again;
	tr340:  sm->cs = 19; goto _again;
	tr25:  sm->cs = 20; goto _again;
	tr26:  sm->cs = 21; goto _again;
	tr27:  sm->cs = 22; goto _again;
	tr28:  sm->cs = 23; goto _again;
	tr29:  sm->cs = 24; goto _again;
	tr30:  sm->cs = 25; goto _again;
	tr33:  sm->cs = 26; goto _again;
	tr32:  sm->cs = 26; goto f7;
	tr341:  sm->cs = 27; goto _again;
	tr35:  sm->cs = 28; goto _again;
	tr36:  sm->cs = 29; goto _again;
	tr37:  sm->cs = 30; goto _again;
	tr38:  sm->cs = 31; goto _again;
	tr39:  sm->cs = 32; goto _again;
	tr40:  sm->cs = 33; goto _again;
	tr342:  sm->cs = 34; goto _again;
	tr42:  sm->cs = 35; goto _again;
	tr43:  sm->cs = 36; goto _again;
	tr44:  sm->cs = 37; goto _again;
	tr45:  sm->cs = 38; goto _again;
	tr343:  sm->cs = 39; goto _again;
	tr47:  sm->cs = 40; goto _again;
	tr48:  sm->cs = 41; goto _again;
	tr49:  sm->cs = 42; goto _again;
	tr50:  sm->cs = 43; goto _again;
	tr51:  sm->cs = 44; goto _again;
	tr52:  sm->cs = 45; goto _again;
	tr53:  sm->cs = 46; goto _again;
	tr344:  sm->cs = 47; goto _again;
	tr55:  sm->cs = 48; goto _again;
	tr57:  sm->cs = 49; goto _again;
	tr58:  sm->cs = 50; goto _again;
	tr59:  sm->cs = 51; goto _again;
	tr56:  sm->cs = 52; goto _again;
	tr369:  sm->cs = 53; goto _again;
	tr66:  sm->cs = 54; goto _again;
	tr370:  sm->cs = 54; goto f7;
	tr65:  sm->cs = 55; goto f4;
	tr70:  sm->cs = 56; goto _again;
	tr376:  sm->cs = 56; goto f7;
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
	tr102:  sm->cs = 83; goto _again;
	tr378:  sm->cs = 83; goto f7;
	tr103:  sm->cs = 84; goto _again;
	tr379:  sm->cs = 84; goto f7;
	tr383:  sm->cs = 85; goto _again;
	tr380:  sm->cs = 85; goto f7;
	tr386:  sm->cs = 86; goto _again;
	tr104:  sm->cs = 87; goto _again;
	tr105:  sm->cs = 88; goto _again;
	tr106:  sm->cs = 89; goto _again;
	tr107:  sm->cs = 90; goto _again;
	tr108:  sm->cs = 91; goto _again;
	tr109:  sm->cs = 92; goto _again;
	tr389:  sm->cs = 93; goto _again;
	tr111:  sm->cs = 94; goto _again;
	tr112:  sm->cs = 95; goto _again;
	tr113:  sm->cs = 96; goto _again;
	tr114:  sm->cs = 97; goto _again;
	tr115:  sm->cs = 98; goto _again;
	tr116:  sm->cs = 99; goto _again;
	tr117:  sm->cs = 100; goto _again;
	tr392:  sm->cs = 101; goto _again;
	tr119:  sm->cs = 102; goto _again;
	tr120:  sm->cs = 103; goto _again;
	tr121:  sm->cs = 104; goto _again;
	tr122:  sm->cs = 105; goto _again;
	tr123:  sm->cs = 106; goto _again;
	tr395:  sm->cs = 107; goto _again;
	tr125:  sm->cs = 108; goto _again;
	tr126:  sm->cs = 109; goto _again;
	tr127:  sm->cs = 110; goto _again;
	tr128:  sm->cs = 111; goto _again;
	tr129:  sm->cs = 112; goto _again;
	tr398:  sm->cs = 113; goto _again;
	tr131:  sm->cs = 114; goto _again;
	tr132:  sm->cs = 115; goto _again;
	tr133:  sm->cs = 116; goto _again;
	tr134:  sm->cs = 117; goto _again;
	tr135:  sm->cs = 118; goto _again;
	tr401:  sm->cs = 119; goto f4;
	tr138:  sm->cs = 120; goto _again;
	tr399:  sm->cs = 121; goto _again;
	tr140:  sm->cs = 122; goto _again;
	tr142:  sm->cs = 123; goto _again;
	tr143:  sm->cs = 124; goto _again;
	tr144:  sm->cs = 125; goto _again;
	tr141:  sm->cs = 126; goto _again;
	tr146:  sm->cs = 127; goto _again;
	tr147:  sm->cs = 128; goto _again;
	tr148:  sm->cs = 129; goto _again;
	tr409:  sm->cs = 130; goto _again;
	tr150:  sm->cs = 131; goto _again;
	tr151:  sm->cs = 132; goto _again;
	tr152:  sm->cs = 133; goto _again;
	tr153:  sm->cs = 134; goto _again;
	tr154:  sm->cs = 135; goto _again;
	tr411:  sm->cs = 136; goto f4;
	tr157:  sm->cs = 137; goto _again;
	tr415:  sm->cs = 138; goto _again;
	tr159:  sm->cs = 139; goto _again;
	tr160:  sm->cs = 140; goto _again;
	tr161:  sm->cs = 141; goto _again;
	tr162:  sm->cs = 142; goto _again;
	tr418:  sm->cs = 143; goto _again;
	tr164:  sm->cs = 144; goto _again;
	tr165:  sm->cs = 145; goto _again;
	tr173:  sm->cs = 146; goto _again;
	tr174:  sm->cs = 147; goto _again;
	tr175:  sm->cs = 148; goto _again;
	tr166:  sm->cs = 149; goto _again;
	tr177:  sm->cs = 150; goto _again;
	tr178:  sm->cs = 151; goto _again;
	tr179:  sm->cs = 152; goto _again;
	tr180:  sm->cs = 153; goto _again;
	tr181:  sm->cs = 154; goto _again;
	tr167:  sm->cs = 155; goto _again;
	tr168:  sm->cs = 156; goto _again;
	tr184:  sm->cs = 157; goto _again;
	tr185:  sm->cs = 158; goto _again;
	tr186:  sm->cs = 159; goto _again;
	tr187:  sm->cs = 160; goto _again;
	tr169:  sm->cs = 161; goto _again;
	tr189:  sm->cs = 162; goto _again;
	tr191:  sm->cs = 163; goto _again;
	tr192:  sm->cs = 164; goto _again;
	tr193:  sm->cs = 165; goto _again;
	tr194:  sm->cs = 166; goto _again;
	tr195:  sm->cs = 167; goto _again;
	tr196:  sm->cs = 168; goto _again;
	tr170:  sm->cs = 169; goto _again;
	tr198:  sm->cs = 170; goto _again;
	tr199:  sm->cs = 171; goto _again;
	tr200:  sm->cs = 172; goto _again;
	tr171:  sm->cs = 173; goto _again;
	tr419:  sm->cs = 174; goto _again;
	tr420:  sm->cs = 175; goto _again;
	tr206:  sm->cs = 176; goto _again;
	tr207:  sm->cs = 177; goto _again;
	tr208:  sm->cs = 178; goto _again;
	tr421:  sm->cs = 179; goto _again;
	tr210:  sm->cs = 180; goto _again;
	tr211:  sm->cs = 181; goto _again;
	tr212:  sm->cs = 182; goto _again;
	tr213:  sm->cs = 183; goto _again;
	tr214:  sm->cs = 184; goto _again;
	tr422:  sm->cs = 185; goto _again;
	tr423:  sm->cs = 186; goto _again;
	tr217:  sm->cs = 187; goto _again;
	tr218:  sm->cs = 188; goto _again;
	tr219:  sm->cs = 189; goto _again;
	tr220:  sm->cs = 190; goto _again;
	tr221:  sm->cs = 191; goto _again;
	tr222:  sm->cs = 192; goto _again;
	tr424:  sm->cs = 193; goto _again;
	tr224:  sm->cs = 194; goto _again;
	tr225:  sm->cs = 195; goto _again;
	tr226:  sm->cs = 196; goto _again;
	tr227:  sm->cs = 197; goto _again;
	tr425:  sm->cs = 198; goto _again;
	tr229:  sm->cs = 199; goto _again;
	tr231:  sm->cs = 200; goto _again;
	tr232:  sm->cs = 201; goto _again;
	tr233:  sm->cs = 202; goto _again;
	tr234:  sm->cs = 203; goto _again;
	tr235:  sm->cs = 204; goto _again;
	tr236:  sm->cs = 205; goto _again;
	tr426:  sm->cs = 206; goto _again;
	tr238:  sm->cs = 207; goto _again;
	tr427:  sm->cs = 208; goto _again;
	tr428:  sm->cs = 209; goto _again;
	tr243:  sm->cs = 210; goto _again;
	tr241:  sm->cs = 210; goto f7;
	tr244:  sm->cs = 211; goto f4;
	tr245:  sm->cs = 212; goto f4;
	tr248:  sm->cs = 213; goto _again;
	tr247:  sm->cs = 213; goto f3;
	tr249:  sm->cs = 214; goto f5;
	tr251:  sm->cs = 215; goto _again;
	tr242:  sm->cs = 215; goto f7;
	tr430:  sm->cs = 216; goto _again;
	tr252:  sm->cs = 217; goto _again;
	tr253:  sm->cs = 218; goto _again;
	tr254:  sm->cs = 219; goto _again;
	tr256:  sm->cs = 220; goto _again;
	tr257:  sm->cs = 221; goto _again;
	tr258:  sm->cs = 222; goto _again;
	tr259:  sm->cs = 223; goto _again;
	tr260:  sm->cs = 224; goto _again;
	tr255:  sm->cs = 225; goto _again;
	tr432:  sm->cs = 226; goto _again;
	tr263:  sm->cs = 227; goto _again;
	tr262:  sm->cs = 227; goto f7;
	tr264:  sm->cs = 228; goto f4;
	tr437:  sm->cs = 229; goto _again;
	tr267:  sm->cs = 230; goto _again;
	tr268:  sm->cs = 231; goto _again;
	tr269:  sm->cs = 232; goto _again;
	tr270:  sm->cs = 233; goto _again;
	tr442:  sm->cs = 234; goto _again;
	tr273:  sm->cs = 235; goto _again;
	tr274:  sm->cs = 236; goto _again;
	tr275:  sm->cs = 237; goto _again;
	tr276:  sm->cs = 238; goto _again;
	tr277:  sm->cs = 239; goto _again;
	tr278:  sm->cs = 240; goto _again;
	tr279:  sm->cs = 241; goto _again;
	tr447:  sm->cs = 242; goto _again;
	tr282:  sm->cs = 243; goto _again;
	tr283:  sm->cs = 244; goto _again;
	tr287:  sm->cs = 245; goto _again;
	tr288:  sm->cs = 246; goto _again;
	tr289:  sm->cs = 247; goto _again;
	tr284:  sm->cs = 248; goto _again;
	tr291:  sm->cs = 249; goto _again;
	tr292:  sm->cs = 250; goto _again;
	tr293:  sm->cs = 251; goto _again;
	tr285:  sm->cs = 252; goto _again;
	tr295:  sm->cs = 253; goto _again;
	tr296:  sm->cs = 254; goto _again;
	tr297:  sm->cs = 255; goto _again;
	tr286:  sm->cs = 256; goto _again;
	tr448:  sm->cs = 257; goto _again;
	tr300:  sm->cs = 258; goto _again;
	tr304:  sm->cs = 259; goto _again;
	tr305:  sm->cs = 260; goto _again;
	tr306:  sm->cs = 261; goto _again;
	tr301:  sm->cs = 262; goto _again;
	tr302:  sm->cs = 263; goto _again;
	tr309:  sm->cs = 264; goto _again;
	tr311:  sm->cs = 265; goto _again;
	tr312:  sm->cs = 266; goto _again;
	tr303:  sm->cs = 267; goto _again;
	tr454:  sm->cs = 268; goto _again;
	tr320:  sm->cs = 269; goto f4;
	tr321:  sm->cs = 270; goto _again;
	tr0:  sm->cs = 271; goto f0;
	tr2:  sm->cs = 271; goto f2;
	tr20:  sm->cs = 271; goto f6;
	tr60:  sm->cs = 271; goto f8;
	tr61:  sm->cs = 271; goto f9;
	tr322:  sm->cs = 271; goto f63;
	tr323:  sm->cs = 271; goto f64;
	tr330:  sm->cs = 271; goto f67;
	tr331:  sm->cs = 271; goto f68;
	tr334:  sm->cs = 271; goto f69;
	tr336:  sm->cs = 271; goto f70;
	tr345:  sm->cs = 271; goto f71;
	tr346:  sm->cs = 271; goto f72;
	tr348:  sm->cs = 271; goto f73;
	tr349:  sm->cs = 271; goto f74;
	tr350:  sm->cs = 271; goto f75;
	tr351:  sm->cs = 271; goto f76;
	tr1:  sm->cs = 272; goto f1;
	tr324:  sm->cs = 272; goto f65;
	tr325:  sm->cs = 273; goto _again;
	tr326:  sm->cs = 274; goto f17;
	tr332:  sm->cs = 275; goto _again;
	tr3:  sm->cs = 275; goto f3;
	tr4:  sm->cs = 276; goto f3;
	tr327:  sm->cs = 277; goto f66;
	tr335:  sm->cs = 278; goto _again;
	tr11:  sm->cs = 278; goto f5;
	tr337:  sm->cs = 279; goto _again;
	tr8:  sm->cs = 279; goto f4;
	tr328:  sm->cs = 280; goto f66;
	tr24:  sm->cs = 281; goto _again;
	tr347:  sm->cs = 282; goto _again;
	tr34:  sm->cs = 282; goto f4;
	tr31:  sm->cs = 283; goto _again;
	tr41:  sm->cs = 284; goto _again;
	tr46:  sm->cs = 285; goto _again;
	tr54:  sm->cs = 286; goto _again;
	tr62:  sm->cs = 287; goto f10;
	tr64:  sm->cs = 287; goto f12;
	tr69:  sm->cs = 287; goto f13;
	tr86:  sm->cs = 287; goto f15;
	tr137:  sm->cs = 287; goto f18;
	tr156:  sm->cs = 287; goto f19;
	tr172:  sm->cs = 287; goto f20;
	tr176:  sm->cs = 287; goto f21;
	tr182:  sm->cs = 287; goto f22;
	tr183:  sm->cs = 287; goto f23;
	tr190:  sm->cs = 287; goto f24;
	tr197:  sm->cs = 287; goto f25;
	tr201:  sm->cs = 287; goto f26;
	tr202:  sm->cs = 287; goto f27;
	tr203:  sm->cs = 287; goto f28;
	tr204:  sm->cs = 287; goto f29;
	tr205:  sm->cs = 287; goto f30;
	tr209:  sm->cs = 287; goto f31;
	tr215:  sm->cs = 287; goto f32;
	tr216:  sm->cs = 287; goto f33;
	tr223:  sm->cs = 287; goto f34;
	tr228:  sm->cs = 287; goto f35;
	tr230:  sm->cs = 287; goto f36;
	tr237:  sm->cs = 287; goto f37;
	tr239:  sm->cs = 287; goto f38;
	tr240:  sm->cs = 287; goto f39;
	tr246:  sm->cs = 287; goto f40;
	tr250:  sm->cs = 287; goto f41;
	tr265:  sm->cs = 287; goto f43;
	tr352:  sm->cs = 287; goto f77;
	tr353:  sm->cs = 287; goto f78;
	tr368:  sm->cs = 287; goto f81;
	tr371:  sm->cs = 287; goto f82;
	tr372:  sm->cs = 287; goto f83;
	tr374:  sm->cs = 287; goto f84;
	tr375:  sm->cs = 287; goto f85;
	tr377:  sm->cs = 287; goto f86;
	tr382:  sm->cs = 287; goto f88;
	tr384:  sm->cs = 287; goto f89;
	tr387:  sm->cs = 287; goto f91;
	tr390:  sm->cs = 287; goto f92;
	tr393:  sm->cs = 287; goto f93;
	tr396:  sm->cs = 287; goto f94;
	tr400:  sm->cs = 287; goto f95;
	tr403:  sm->cs = 287; goto f96;
	tr405:  sm->cs = 287; goto f97;
	tr407:  sm->cs = 287; goto f98;
	tr410:  sm->cs = 287; goto f99;
	tr413:  sm->cs = 287; goto f100;
	tr416:  sm->cs = 287; goto f101;
	tr429:  sm->cs = 287; goto f102;
	tr431:  sm->cs = 287; goto f103;
	tr354:  sm->cs = 288; goto f79;
	tr63:  sm->cs = 289; goto f11;
	tr373:  sm->cs = 290; goto _again;
	tr67:  sm->cs = 290; goto f3;
	tr68:  sm->cs = 291; goto f3;
	tr355:  sm->cs = 292; goto _again;
	tr356:  sm->cs = 293; goto f80;
	tr79:  sm->cs = 294; goto f14;
	tr357:  sm->cs = 295; goto f80;
	tr101:  sm->cs = 296; goto f16;
	tr385:  sm->cs = 296; goto f90;
	tr381:  sm->cs = 297; goto f87;
	tr358:  sm->cs = 298; goto f66;
	tr388:  sm->cs = 299; goto _again;
	tr110:  sm->cs = 299; goto f7;
	tr359:  sm->cs = 300; goto f66;
	tr391:  sm->cs = 301; goto _again;
	tr118:  sm->cs = 301; goto f7;
	tr360:  sm->cs = 302; goto f66;
	tr394:  sm->cs = 303; goto _again;
	tr124:  sm->cs = 303; goto f7;
	tr361:  sm->cs = 304; goto f66;
	tr397:  sm->cs = 305; goto _again;
	tr130:  sm->cs = 305; goto f7;
	tr362:  sm->cs = 306; goto f66;
	tr136:  sm->cs = 307; goto f17;
	tr402:  sm->cs = 307; goto f66;
	tr404:  sm->cs = 308; goto _again;
	tr139:  sm->cs = 308; goto f3;
	tr406:  sm->cs = 309; goto _again;
	tr145:  sm->cs = 309; goto f7;
	tr408:  sm->cs = 310; goto _again;
	tr149:  sm->cs = 310; goto f7;
	tr363:  sm->cs = 311; goto f66;
	tr155:  sm->cs = 312; goto f17;
	tr412:  sm->cs = 312; goto f66;
	tr414:  sm->cs = 313; goto _again;
	tr158:  sm->cs = 313; goto f3;
	tr364:  sm->cs = 314; goto f66;
	tr417:  sm->cs = 315; goto _again;
	tr163:  sm->cs = 315; goto f7;
	tr365:  sm->cs = 316; goto f66;
	tr188:  sm->cs = 317; goto _again;
	tr366:  sm->cs = 318; goto f80;
	tr261:  sm->cs = 319; goto f42;
	tr367:  sm->cs = 320; goto f66;
	tr266:  sm->cs = 321; goto f44;
	tr271:  sm->cs = 321; goto f45;
	tr433:  sm->cs = 321; goto f104;
	tr434:  sm->cs = 321; goto f105;
	tr436:  sm->cs = 321; goto f106;
	tr435:  sm->cs = 322; goto f66;
	tr272:  sm->cs = 323; goto f46;
	tr280:  sm->cs = 323; goto f47;
	tr438:  sm->cs = 323; goto f107;
	tr439:  sm->cs = 323; goto f108;
	tr441:  sm->cs = 323; goto f109;
	tr440:  sm->cs = 324; goto f66;
	tr281:  sm->cs = 325; goto f48;
	tr290:  sm->cs = 325; goto f49;
	tr294:  sm->cs = 325; goto f50;
	tr298:  sm->cs = 325; goto f51;
	tr299:  sm->cs = 325; goto f52;
	tr307:  sm->cs = 325; goto f53;
	tr308:  sm->cs = 325; goto f54;
	tr310:  sm->cs = 325; goto f55;
	tr313:  sm->cs = 325; goto f56;
	tr314:  sm->cs = 325; goto f57;
	tr443:  sm->cs = 325; goto f110;
	tr444:  sm->cs = 325; goto f111;
	tr446:  sm->cs = 325; goto f112;
	tr445:  sm->cs = 326; goto f66;
	tr315:  sm->cs = 327; goto f58;
	tr317:  sm->cs = 327; goto f60;
	tr449:  sm->cs = 327; goto f113;
	tr450:  sm->cs = 327; goto f114;
	tr455:  sm->cs = 327; goto f116;
	tr456:  sm->cs = 327; goto f117;
	tr316:  sm->cs = 328; goto f59;
	tr451:  sm->cs = 328; goto f115;
	tr452:  sm->cs = 329; goto _again;
	tr453:  sm->cs = 330; goto f17;
	tr457:  sm->cs = 331; goto _again;
	tr318:  sm->cs = 331; goto f3;
	tr319:  sm->cs = 332; goto f3;

f7:
#line 73 "ext/dtext/dtext.rl"
	{
  sm->a1 = sm->p;
}
	goto _again;
f4:
#line 77 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
	goto _again;
f3:
#line 81 "ext/dtext/dtext.rl"
	{
  sm->b1 = sm->p;
}
	goto _again;
f5:
#line 85 "ext/dtext/dtext.rl"
	{
  sm->b2 = sm->p;
}
	goto _again;
f66:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
	goto _again;
f43:
#line 247 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    append(sm, true, "<a rel=\"nofollow\" class=\"dtext-link dtext-post-search-link\" href=\"/posts?tags=");
    append_segment_uri_escaped(sm, sm->a1, sm->a2 - 1);
    append(sm, true, "\">");
    append_segment_html_escaped(sm, sm->a1, sm->a2 - 1);
    append(sm, true, "</a>");
  }}
	goto _again;
f40:
#line 255 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    GString * segment = g_string_new_len(sm->a1, sm->a2 - sm->a1);
    GString * lowercase_segment = NULL;
    underscore_string(segment->str, segment->len);

    if (g_utf8_validate(segment->str, -1, NULL)) {
      lowercase_segment = g_string_new(g_utf8_strdown(segment->str, -1));
    } else {
      lowercase_segment = g_string_new(g_ascii_strdown(segment->str, -1));
    }

    append(sm, true, "<a class=\"dtext-link dtext-wiki-link\" href=\"/wiki_pages/show_or_new?title=");
    append_segment_uri_escaped(sm, lowercase_segment->str, lowercase_segment->str + lowercase_segment->len - 1);
    append(sm, true, "\">");
    append_segment_html_escaped(sm, sm->a1, sm->a2 - 1);
    append(sm, true, "</a>");

    g_string_free(lowercase_segment, TRUE);
    g_string_free(segment, TRUE);
  }}
	goto _again;
f41:
#line 276 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    GString * segment = g_string_new_len(sm->a1, sm->a2 - sm->a1);
    GString * lowercase_segment = NULL;
    underscore_string(segment->str, segment->len);

    if (g_utf8_validate(segment->str, -1, NULL)) {
      lowercase_segment = g_string_new(g_utf8_strdown(segment->str, -1));
    } else {
      lowercase_segment = g_string_new(g_ascii_strdown(segment->str, -1));
    }

    append(sm, true, "<a class=\"dtext-link dtext-wiki-link\" href=\"/wiki_pages/show_or_new?title=");
    append_segment_uri_escaped(sm, lowercase_segment->str, lowercase_segment->str + lowercase_segment->len - 1);
    append(sm, true, "\">");
    append_segment_html_escaped(sm, sm->b1, sm->b2 - 1);
    append(sm, true, "</a>");

    g_string_free(lowercase_segment, TRUE);
    g_string_free(segment, TRUE);
  }}
	goto _again;
f30:
#line 409 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_push(sm, &INLINE_B);
    append(sm, true, "<strong>");
  }}
	goto _again;
f20:
#line 414 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    if (dstack_check(sm, INLINE_B)) {
      dstack_pop(sm);
      append(sm, true, "</strong>");
    } else {
      append(sm, true, "[/b]");
    }
  }}
	goto _again;
f33:
#line 423 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_push(sm, &INLINE_I);
    append(sm, true, "<em>");
  }}
	goto _again;
f23:
#line 428 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    if (dstack_check(sm, INLINE_I)) {
      dstack_pop(sm);
      append(sm, true, "</em>");
    } else {
      append(sm, true, "[/i]");
    }
  }}
	goto _again;
f36:
#line 437 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_push(sm, &INLINE_S);
    append(sm, true, "<s>");
  }}
	goto _again;
f24:
#line 442 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    if (dstack_check(sm, INLINE_S)) {
      dstack_pop(sm);
      append(sm, true, "</s>");
    } else {
      append(sm, true, "[/s]");
    }
  }}
	goto _again;
f39:
#line 451 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_push(sm, &INLINE_U);
    append(sm, true, "<u>");
  }}
	goto _again;
f29:
#line 456 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    if (dstack_check(sm, INLINE_U)) {
      dstack_pop(sm);
      append(sm, true, "</u>");
    } else {
      append(sm, true, "[/u]");
    }
  }}
	goto _again;
f38:
#line 465 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_push(sm, &INLINE_TN);
    append(sm, true, "<span class=\"tn\">");
  }}
	goto _again;
f28:
#line 470 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_close_before_block(sm);

    if (dstack_check(sm, BLOCK_TN)) {
      dstack_pop(sm);
      { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)];goto _again;}
    } else if (dstack_check(sm, INLINE_TN)) {
      dstack_pop(sm);
      append(sm, true, "</span>");
    } else {
      append_block(sm, "[/tn]");
    }
  }}
	goto _again;
f31:
#line 484 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_push(sm, &INLINE_CODE);
    append(sm, true, "<code>");
  }}
	goto _again;
f21:
#line 489 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    if (dstack_check(sm, INLINE_CODE)) {
      dstack_pop(sm);
      append(sm, true, "</code>");
    } else {
      append(sm, true, "[/code]");
    }
  }}
	goto _again;
f37:
#line 498 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    g_debug("inline [spoiler]");
    g_debug("  push <span>");
    dstack_push(sm, &INLINE_SPOILER);
    append(sm, true, "<span class=\"spoiler\">");
  }}
	goto _again;
f25:
#line 505 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    g_debug("inline [/spoiler]");
    dstack_close_before_block(sm);

    if (dstack_check(sm, INLINE_SPOILER)) {
      g_debug("  pop dstack");
      g_debug("  print </span>");
      dstack_pop(sm);
      append(sm, true, "</span>");
    } else if (dstack_check(sm, BLOCK_SPOILER)) {
      g_debug("  pop dstack");
      g_debug("  print </div>");
      g_debug("  return");
      dstack_pop(sm);
      append_block(sm, "</div>");
      { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)];goto _again;}
    } else {
      append_block(sm, "[/spoiler]");
    }
  }}
	goto _again;
f34:
#line 526 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_push(sm, &INLINE_NODTEXT);
    g_debug("push inline nodtext");
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
{( ((int *)sm->stack->data))[( sm->top)++] =  sm->cs;  sm->cs = 323; goto _again;}}
  }}
	goto _again;
f35:
#line 535 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    g_debug("inline [quote]");
    dstack_close_before_block(sm);
    {( sm->p) = (( sm->ts))-1;}
    { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)];goto _again;}
  }}
	goto _again;
f32:
#line 558 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    g_debug("inline [expand]");
    dstack_rewind(sm);
    {( sm->p) = (((sm->p - 7)))-1;}
    { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)];goto _again;}
  }}
	goto _again;
f22:
#line 565 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_close_before_block(sm);

    if (dstack_check(sm, BLOCK_EXPAND)) {
      append_block(sm, "</div></div>");
      dstack_pop(sm);
      { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)];goto _again;}
    } else {
      append_block(sm, "[/expand]");
    }
  }}
	goto _again;
f27:
#line 577 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    if (dstack_check(sm, BLOCK_TH)) {
      dstack_pop(sm);
      append_block(sm, "</th>");
      { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)];goto _again;}
    } else {
      append_block(sm, "[/th]");
    }
  }}
	goto _again;
f26:
#line 587 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    if (dstack_check(sm, BLOCK_TD)) {
      dstack_pop(sm);
      append_block(sm, "</td>");
      { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)];goto _again;}
    } else {
      append_block(sm, "[/td]");
    }
  }}
	goto _again;
f78:
#line 597 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    g_debug("inline 0");
    g_debug("  return");

    ( sm->p)--;
    { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)];goto _again;}
  }}
	goto _again;
f77:
#line 633 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    g_debug("inline char: %c", (*( sm->p)));
    append_c_html_escaped(sm, (*( sm->p)));
  }}
	goto _again;
f103:
#line 337 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    if (is_boundary_c((*( sm->p)))) {
      sm->b = true;
      sm->d = 2;
    } else {
      sm->b = false;
      sm->d = 1;
    }

    append(sm, true, "<a href=\"");
    append_segment_html_escaped(sm, sm->ts, sm->te - sm->d);
    append(sm, true, "\">");
    append_segment_html_escaped(sm, sm->ts, sm->te - sm->d);
    append(sm, true, "</a>");

    if (sm->b) {
      append_c_html_escaped(sm, (*( sm->p)));
    }
  }}
	goto _again;
f102:
#line 542 "ext/dtext/dtext.rl"
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
#line 605 "ext/dtext/dtext.rl"
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
#line 617 "ext/dtext/dtext.rl"
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
#line 629 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append_c(sm, ' ');
  }}
	goto _again;
f85:
#line 633 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    g_debug("inline char: %c", (*( sm->p)));
    append_c_html_escaped(sm, (*( sm->p)));
  }}
	goto _again;
f19:
#line 158 "ext/dtext/dtext.rl"
	{{( sm->p) = ((( sm->te)))-1;}{
    append(sm, true, "<a class=\"dtext-link dtext-id-link dtext-forum-topic-id-link\" href=\"/forum_topics/");
    append_segment(sm, true, sm->a1, sm->a2 - 1);
    append(sm, true, "\">");
    append(sm, false, "topic #");
    append_segment(sm, false, sm->a1, sm->a2 - 1);
    append(sm, true, "</a>");
  }}
	goto _again;
f18:
#line 225 "ext/dtext/dtext.rl"
	{{( sm->p) = ((( sm->te)))-1;}{
    append(sm, true, "<a class=\"dtext-link dtext-id-link dtext-pixiv-id-link\" href=\"http://www.pixiv.net/member_illust.php?mode=medium&illust_id=");
    append_segment(sm, true, sm->a1, sm->a2 - 1);
    append(sm, true, "\">");
    append(sm, false, "pixiv #");
    append_segment(sm, false, sm->a1, sm->a2 - 1);
    append(sm, true, "</a>");
  }}
	goto _again;
f12:
#line 617 "ext/dtext/dtext.rl"
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
#line 633 "ext/dtext/dtext.rl"
	{{( sm->p) = ((( sm->te)))-1;}{
    g_debug("inline char: %c", (*( sm->p)));
    append_c_html_escaped(sm, (*( sm->p)));
  }}
	goto _again;
f10:
#line 1 "NONE"
	{	switch( ( sm->act) ) {
	case 15:
	{{( sm->p) = ((( sm->te)))-1;}
    if (is_boundary_c((*( sm->p)))) {
      sm->d = 2;
      sm->b = true;
    } else {
      sm->d = 1;
      sm->b = false;
    }

    append(sm, true, "<a class=\"dtext-link dtext-external-link\" href=\"");
    append_segment_html_escaped(sm, sm->b1, sm->b2 - sm->d);
    append(sm, true, "\">");

    link_content_sm = init_machine(sm->a1, sm->a2 - sm->a1, false, true, false);
    if (!parse_helper(link_content_sm)) {
      g_debug("basic_textile_link: parse_helper failed");
      g_propagate_error(&sm->error, link_content_sm->error);
      free_machine(link_content_sm);
      {( sm->p)++; goto _out; }
    } else {
      append(sm, true, link_content_sm->output->str);
      free_machine(link_content_sm);
      link_content_sm = NULL;
    }

    append(sm, true, "</a>");

    if (sm->b) {
      append_c_html_escaped(sm, (*( sm->p)));
    }
  }
	break;
	case 17:
	{{( sm->p) = ((( sm->te)))-1;}
    if (is_boundary_c((*( sm->p)))) {
      sm->b = true;
      sm->d = 2;
    } else {
      sm->b = false;
      sm->d = 1;
    }

    append(sm, true, "<a href=\"");
    append_segment_html_escaped(sm, sm->ts, sm->te - sm->d);
    append(sm, true, "\">");
    append_segment_html_escaped(sm, sm->ts, sm->te - sm->d);
    append(sm, true, "</a>");

    if (sm->b) {
      append_c_html_escaped(sm, (*( sm->p)));
    }
  }
	break;
	case 18:
	{{( sm->p) = ((( sm->te)))-1;}
    append_segment_html_escaped(sm, sm->ts, sm->te - 1);
  }
	break;
	case 19:
	{{( sm->p) = ((( sm->te)))-1;}
    if (!sm->f_mentions || (sm->a1 > sm->pb && sm->a1 - 1 > sm->pb && sm->a1[-2] != ' ' && sm->a1[-2] != '\r' && sm->a1[-2] != '\n')) {
      // handle emails
      append_c(sm, '@');
      append_segment_html_escaped(sm, sm->a1, sm->a2 - 1);

    } else {
      if (is_boundary_c((*( sm->p)))) {
        sm->b = true;
        sm->d = 2;
      } else {
        sm->b = false;
        sm->d = 1;
      }

      append(sm, true, "<a rel=\"nofollow\" href=\"/users?name=");
      append_segment_uri_escaped(sm, sm->a1, sm->a2 - sm->d);
      append(sm, true, "\">");
      append_c(sm, '@');
      append_segment_html_escaped(sm, sm->a1, sm->a2 - sm->d);
      append(sm, true, "</a>");

      if (sm->b) {
        append_c_html_escaped(sm, (*( sm->p)));
      }
    }
  }
	break;
	case 43:
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
	case 44:
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
	case 46:
	{{( sm->p) = ((( sm->te)))-1;}
    g_debug("inline char: %c", (*( sm->p)));
    append_c_html_escaped(sm, (*( sm->p)));
  }
	break;
	}
	}
	goto _again;
f45:
#line 640 "ext/dtext/dtext.rl"
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
#line 649 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    ( sm->p)--;
    { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)];goto _again;}
  }}
	goto _again;
f104:
#line 654 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    append_c_html_escaped(sm, (*( sm->p)));
  }}
	goto _again;
f106:
#line 654 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append_c_html_escaped(sm, (*( sm->p)));
  }}
	goto _again;
f44:
#line 654 "ext/dtext/dtext.rl"
	{{( sm->p) = ((( sm->te)))-1;}{
    append_c_html_escaped(sm, (*( sm->p)));
  }}
	goto _again;
f47:
#line 660 "ext/dtext/dtext.rl"
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
f108:
#line 677 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    ( sm->p)--;
    { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)];goto _again;}
  }}
	goto _again;
f107:
#line 682 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    append_c_html_escaped(sm, (*( sm->p)));
  }}
	goto _again;
f109:
#line 682 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append_c_html_escaped(sm, (*( sm->p)));
  }}
	goto _again;
f46:
#line 682 "ext/dtext/dtext.rl"
	{{( sm->p) = ((( sm->te)))-1;}{
    append_c_html_escaped(sm, (*( sm->p)));
  }}
	goto _again;
f56:
#line 688 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_push(sm, &BLOCK_THEAD);
    append_block(sm, "<thead>");
  }}
	goto _again;
f51:
#line 693 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    if (dstack_check(sm, BLOCK_THEAD)) {
      dstack_pop(sm);
      append_block(sm, "</thead>");
    } else {
      append(sm, true, "[/thead]");
    }
  }}
	goto _again;
f53:
#line 702 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_push(sm, &BLOCK_TBODY);
    append_block(sm, "<tbody>");
  }}
	goto _again;
f50:
#line 707 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    if (dstack_check(sm, BLOCK_TBODY)) {
      dstack_pop(sm);
      append_block(sm, "</tbody>");
    } else {
      append(sm, true, "[/tbody]");
    }
  }}
	goto _again;
f55:
#line 716 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_push(sm, &BLOCK_TH);
    append_block(sm, "<th>");
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
{( ((int *)sm->stack->data))[( sm->top)++] =  sm->cs;  sm->cs = 287; goto _again;}}
  }}
	goto _again;
f57:
#line 722 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_push(sm, &BLOCK_TR);
    append_block(sm, "<tr>");
  }}
	goto _again;
f52:
#line 727 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    if (dstack_check(sm, BLOCK_TR)) {
      dstack_pop(sm);
      append_block(sm, "</tr>");
    } else {
      append(sm, true, "[/tr]");
    }
  }}
	goto _again;
f54:
#line 736 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_push(sm, &BLOCK_TD);
    append_block(sm, "<td>");
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
{( ((int *)sm->stack->data))[( sm->top)++] =  sm->cs;  sm->cs = 287; goto _again;}}
  }}
	goto _again;
f49:
#line 742 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    if (dstack_check(sm, BLOCK_TABLE)) {
      dstack_pop(sm);
      append_block(sm, "</table>");
      { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)];goto _again;}
    } else {
      append(sm, true, "[/table]");
    }
  }}
	goto _again;
f111:
#line 752 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    ( sm->p)--;
    { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)];goto _again;}
  }}
	goto _again;
f110:
#line 757 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;}
	goto _again;
f112:
#line 757 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;}
	goto _again;
f48:
#line 757 "ext/dtext/dtext.rl"
	{{( sm->p) = ((( sm->te)))-1;}}
	goto _again;
f114:
#line 800 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_close_list(sm);
    {( sm->p) = (( sm->ts))-1;}
    { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)];goto _again;}
  }}
	goto _again;
f113:
#line 808 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_rewind(sm);
    ( sm->p)--;
    { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)];goto _again;}
  }}
	goto _again;
f116:
#line 808 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    dstack_rewind(sm);
    ( sm->p)--;
    { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)];goto _again;}
  }}
	goto _again;
f60:
#line 808 "ext/dtext/dtext.rl"
	{{( sm->p) = ((( sm->te)))-1;}{
    dstack_rewind(sm);
    ( sm->p)--;
    { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)];goto _again;}
  }}
	goto _again;
f58:
#line 1 "NONE"
	{	switch( ( sm->act) ) {
	case 65:
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
#line 940 "ext/dtext/dtext.rl"
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
#line 989 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_close_before_block(sm);
    dstack_push(sm, &BLOCK_TABLE);
    append_block(sm, "<table class=\"striped\">");
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
{( ((int *)sm->stack->data))[( sm->top)++] =  sm->cs;  sm->cs = 325; goto _again;}}
  }}
	goto _again;
f9:
#line 996 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_push(sm, &BLOCK_TN);
    append_block(sm, "<p class=\"tn\">");
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
{( ((int *)sm->stack->data))[( sm->top)++] =  sm->cs;  sm->cs = 287; goto _again;}}
  }}
	goto _again;
f64:
#line 1012 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    g_debug("block 0");
    g_debug("  close dstack");
    dstack_close(sm);
  }}
	goto _again;
f63:
#line 1035 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    g_debug("block char: %c", (*( sm->p)));
    ( sm->p)--;

    if (g_queue_is_empty(sm->dstack) || dstack_check(sm, BLOCK_QUOTE) || dstack_check(sm, BLOCK_SPOILER) || dstack_check(sm, BLOCK_EXPAND)) {
      g_debug("  push p");
      g_debug("  print <p>");
      dstack_push(sm, &BLOCK_P);
      append_block(sm, "<p>");
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
{( ((int *)sm->stack->data))[( sm->top)++] =  sm->cs;  sm->cs = 287; goto _again;}}
  }}
	goto _again;
f69:
#line 816 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    char header = *sm->a1;
    GString * id_name = g_string_new_len(sm->b1, sm->b2 - sm->b1);
    id_name = g_string_prepend(id_name, "dtext-");

    if (sm->f_inline) {
      header = '6';
    }

    if (!sm->f_strip) {
      switch (header) {
        case '1':
          dstack_push(sm, &BLOCK_H1);
          append_block(sm, "<h1 id=\"");
          append_block(sm, id_name->str);
          append_block(sm, "\">");
          break;

        case '2':
          dstack_push(sm, &BLOCK_H2);
          append_block(sm, "<h2 id=\"");
          append_block(sm, id_name->str);
          append_block(sm, "\">");
          break;

        case '3':
          dstack_push(sm, &BLOCK_H3);
          append_block(sm, "<h3 id=\"");
          append_block(sm, id_name->str);
          append_block(sm, "\">");
          break;

        case '4':
          dstack_push(sm, &BLOCK_H4);
          append_block(sm, "<h4 id=\"");
          append_block(sm, id_name->str);
          append_block(sm, "\">");
          break;

        case '5':
          dstack_push(sm, &BLOCK_H5);
          append_block(sm, "<h5 id=\"");
          append_block(sm, id_name->str);
          append_block(sm, "\">");
          break;

        case '6':
          dstack_push(sm, &BLOCK_H6);
          append_block(sm, "<h6 id=\"");
          append_block(sm, id_name->str);
          append_block(sm, "\">");
          break;
      }
    }

    sm->header_mode = true;
    g_string_free(id_name, false);
    id_name = NULL;
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
{( ((int *)sm->stack->data))[( sm->top)++] =  sm->cs;  sm->cs = 287; goto _again;}}
  }}
	goto _again;
f70:
#line 877 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    char header = *sm->a1;

    if (sm->f_inline) {
      header = '6';
    }

    if (!sm->f_strip) {
      switch (header) {
        case '1':
          dstack_push(sm, &BLOCK_H1);
          append_block(sm, "<h1>");
          break;

        case '2':
          dstack_push(sm, &BLOCK_H2);
          append_block(sm, "<h2>");
          break;

        case '3':
          dstack_push(sm, &BLOCK_H3);
          append_block(sm, "<h3>");
          break;

        case '4':
          dstack_push(sm, &BLOCK_H4);
          append_block(sm, "<h4>");
          break;

        case '5':
          dstack_push(sm, &BLOCK_H5);
          append_block(sm, "<h5>");
          break;

        case '6':
          dstack_push(sm, &BLOCK_H6);
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
{( ((int *)sm->stack->data))[( sm->top)++] =  sm->cs;  sm->cs = 287; goto _again;}}
  }}
	goto _again;
f75:
#line 922 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    g_debug("block [quote]");
    g_debug("  push quote");
    g_debug("  print <blockquote>");
    dstack_close_before_block(sm);
    dstack_push(sm, &BLOCK_QUOTE);
    append_block(sm, "<blockquote>");
  }}
	goto _again;
f76:
#line 931 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    g_debug("block [spoiler]");
    g_debug("  push spoiler");
    g_debug("  print <div>");
    dstack_close_before_block(sm);
    dstack_push(sm, &BLOCK_SPOILER);
    append_block(sm, "<div class=\"spoiler\">");
  }}
	goto _again;
f71:
#line 949 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    g_debug("block [code]");
    dstack_close_before_block(sm);
    dstack_push(sm, &BLOCK_CODE);
    append_block(sm, "<pre>");
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
{( ((int *)sm->stack->data))[( sm->top)++] =  sm->cs;  sm->cs = 321; goto _again;}}
  }}
	goto _again;
f73:
#line 957 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    g_debug("block [expand]");
    dstack_close_before_block(sm);
    dstack_push(sm, &BLOCK_EXPAND);
    append_block(sm, "<div class=\"expandable\"><div class=\"expandable-header\">");
    append_block(sm, "<input type=\"button\" value=\"Show\" class=\"expandable-button\"/></div>");
    append_block(sm, "<div class=\"expandable-content\">");
  }}
	goto _again;
f72:
#line 966 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    g_debug("block [expand=]");
    dstack_close_before_block(sm);
    dstack_push(sm, &BLOCK_EXPAND);
    append_block(sm, "<div class=\"expandable\"><div class=\"expandable-header\">");
    append(sm, true, "<span>");
    append_segment_html_escaped(sm, sm->a1, sm->a2 - 1);
    append(sm, true, "</span>");
    append_block(sm, "<input type=\"button\" value=\"Show\" class=\"expandable-button\"/></div>");
    append_block(sm, "<div class=\"expandable-content\">");
  }}
	goto _again;
f74:
#line 978 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    g_debug("block [nodtext]");
    dstack_close_before_block(sm);
    dstack_push(sm, &BLOCK_NODTEXT);
    dstack_push(sm, &BLOCK_P);
    g_debug("push block nodtext");
    g_debug("push block p");
    append_block(sm, "<p>");
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
{( ((int *)sm->stack->data))[( sm->top)++] =  sm->cs;  sm->cs = 323; goto _again;}}
  }}
	goto _again;
f67:
#line 1035 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    g_debug("block char: %c", (*( sm->p)));
    ( sm->p)--;

    if (g_queue_is_empty(sm->dstack) || dstack_check(sm, BLOCK_QUOTE) || dstack_check(sm, BLOCK_SPOILER) || dstack_check(sm, BLOCK_EXPAND)) {
      g_debug("  push p");
      g_debug("  print <p>");
      dstack_push(sm, &BLOCK_P);
      append_block(sm, "<p>");
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
{( ((int *)sm->stack->data))[( sm->top)++] =  sm->cs;  sm->cs = 287; goto _again;}}
  }}
	goto _again;
f2:
#line 1035 "ext/dtext/dtext.rl"
	{{( sm->p) = ((( sm->te)))-1;}{
    g_debug("block char: %c", (*( sm->p)));
    ( sm->p)--;

    if (g_queue_is_empty(sm->dstack) || dstack_check(sm, BLOCK_QUOTE) || dstack_check(sm, BLOCK_SPOILER) || dstack_check(sm, BLOCK_EXPAND)) {
      g_debug("  push p");
      g_debug("  print <p>");
      dstack_push(sm, &BLOCK_P);
      append_block(sm, "<p>");
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
{( ((int *)sm->stack->data))[( sm->top)++] =  sm->cs;  sm->cs = 287; goto _again;}}
  }}
	goto _again;
f0:
#line 1 "NONE"
	{	switch( ( sm->act) ) {
	case 81:
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
	case 82:
	{{( sm->p) = ((( sm->te)))-1;}
    g_debug("block newline");
  }
	break;
	}
	}
	goto _again;
f98:
#line 77 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
#line 140 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append(sm, true, "<a class=\"dtext-link dtext-id-link dtext-post-id-link\" href=\"/posts/");
    append_segment(sm, true, sm->a1, sm->a2 - 1);
    append(sm, true, "\">");
    append(sm, false, "post #");
    append_segment(sm, false, sm->a1, sm->a2 - 1);
    append(sm, true, "</a>");
  }}
	goto _again;
f93:
#line 77 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
#line 149 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append(sm, true, "<a class=\"dtext-link dtext-id-link dtext-forum-post-id-link\" href=\"/forum_posts/");
    append_segment(sm, true, sm->a1, sm->a2 - 1);
    append(sm, true, "\">");
    append(sm, false, "forum #");
    append_segment(sm, false, sm->a1, sm->a2 - 1);
    append(sm, true, "</a>");
  }}
	goto _again;
f99:
#line 77 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
#line 158 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append(sm, true, "<a class=\"dtext-link dtext-id-link dtext-forum-topic-id-link\" href=\"/forum_topics/");
    append_segment(sm, true, sm->a1, sm->a2 - 1);
    append(sm, true, "\">");
    append(sm, false, "topic #");
    append_segment(sm, false, sm->a1, sm->a2 - 1);
    append(sm, true, "</a>");
  }}
	goto _again;
f92:
#line 77 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
#line 180 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append(sm, true, "<a class=\"dtext-link dtext-id-link dtext-comment-id-link\" href=\"/comments/");
    append_segment(sm, true, sm->a1, sm->a2 - 1);
    append(sm, true, "\">");
    append(sm, false, "comment #");
    append_segment(sm, false, sm->a1, sm->a2 - 1);
    append(sm, true, "</a>");
  }}
	goto _again;
f97:
#line 77 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
#line 189 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append(sm, true, "<a class=\"dtext-link dtext-id-link dtext-pool-id-link\" href=\"/pools/");
    append_segment(sm, true, sm->a1, sm->a2 - 1);
    append(sm, true, "\">");
    append(sm, false, "pool #");
    append_segment(sm, false, sm->a1, sm->a2 - 1);
    append(sm, true, "</a>");
  }}
	goto _again;
f101:
#line 77 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
#line 198 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append(sm, true, "<a class=\"dtext-link dtext-id-link dtext-user-id-link\" href=\"/users/");
    append_segment(sm, true, sm->a1, sm->a2 - 1);
    append(sm, true, "\">");
    append(sm, false, "user #");
    append_segment(sm, false, sm->a1, sm->a2 - 1);
    append(sm, true, "</a>");
  }}
	goto _again;
f91:
#line 77 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
#line 207 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append(sm, true, "<a class=\"dtext-link dtext-id-link dtext-artist-id-link\" href=\"/artists/");
    append_segment(sm, true, sm->a1, sm->a2 - 1);
    append(sm, true, "\">");
    append(sm, false, "artist #");
    append_segment(sm, false, sm->a1, sm->a2 - 1);
    append(sm, true, "</a>");
  }}
	goto _again;
f94:
#line 77 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
#line 216 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append(sm, true, "<a class=\"dtext-link dtext-id-link dtext-github-id-link\" href=\"https://github.com/r888888888/danbooru/issues/");
    append_segment(sm, true, sm->a1, sm->a2 - 1);
    append(sm, true, "\">");
    append(sm, false, "issue #");
    append_segment(sm, false, sm->a1, sm->a2 - 1);
    append(sm, true, "</a>");
  }}
	goto _again;
f95:
#line 77 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
#line 225 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append(sm, true, "<a class=\"dtext-link dtext-id-link dtext-pixiv-id-link\" href=\"http://www.pixiv.net/member_illust.php?mode=medium&illust_id=");
    append_segment(sm, true, sm->a1, sm->a2 - 1);
    append(sm, true, "\">");
    append(sm, false, "pixiv #");
    append_segment(sm, false, sm->a1, sm->a2 - 1);
    append(sm, true, "</a>");
  }}
	goto _again;
f89:
#line 77 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
#line 362 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    if (!sm->f_mentions || (sm->a1 > sm->pb && sm->a1 - 1 > sm->pb && sm->a1[-2] != ' ' && sm->a1[-2] != '\r' && sm->a1[-2] != '\n')) {
      // handle emails
      append_c(sm, '@');
      append_segment_html_escaped(sm, sm->a1, sm->a2 - 1);

    } else {
      if (is_boundary_c((*( sm->p)))) {
        sm->b = true;
        sm->d = 2;
      } else {
        sm->b = false;
        sm->d = 1;
      }

      append(sm, true, "<a rel=\"nofollow\" href=\"/users?name=");
      append_segment_uri_escaped(sm, sm->a1, sm->a2 - sm->d);
      append(sm, true, "\">");
      append_c(sm, '@');
      append_segment_html_escaped(sm, sm->a1, sm->a2 - sm->d);
      append(sm, true, "</a>");

      if (sm->b) {
        append_c_html_escaped(sm, (*( sm->p)));
      }
    }
  }}
	goto _again;
f88:
#line 77 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
#line 1 "NONE"
	{	switch( ( sm->act) ) {
	case 15:
	{{( sm->p) = ((( sm->te)))-1;}
    if (is_boundary_c((*( sm->p)))) {
      sm->d = 2;
      sm->b = true;
    } else {
      sm->d = 1;
      sm->b = false;
    }

    append(sm, true, "<a class=\"dtext-link dtext-external-link\" href=\"");
    append_segment_html_escaped(sm, sm->b1, sm->b2 - sm->d);
    append(sm, true, "\">");

    link_content_sm = init_machine(sm->a1, sm->a2 - sm->a1, false, true, false);
    if (!parse_helper(link_content_sm)) {
      g_debug("basic_textile_link: parse_helper failed");
      g_propagate_error(&sm->error, link_content_sm->error);
      free_machine(link_content_sm);
      {( sm->p)++; goto _out; }
    } else {
      append(sm, true, link_content_sm->output->str);
      free_machine(link_content_sm);
      link_content_sm = NULL;
    }

    append(sm, true, "</a>");

    if (sm->b) {
      append_c_html_escaped(sm, (*( sm->p)));
    }
  }
	break;
	case 17:
	{{( sm->p) = ((( sm->te)))-1;}
    if (is_boundary_c((*( sm->p)))) {
      sm->b = true;
      sm->d = 2;
    } else {
      sm->b = false;
      sm->d = 1;
    }

    append(sm, true, "<a href=\"");
    append_segment_html_escaped(sm, sm->ts, sm->te - sm->d);
    append(sm, true, "\">");
    append_segment_html_escaped(sm, sm->ts, sm->te - sm->d);
    append(sm, true, "</a>");

    if (sm->b) {
      append_c_html_escaped(sm, (*( sm->p)));
    }
  }
	break;
	case 18:
	{{( sm->p) = ((( sm->te)))-1;}
    append_segment_html_escaped(sm, sm->ts, sm->te - 1);
  }
	break;
	case 19:
	{{( sm->p) = ((( sm->te)))-1;}
    if (!sm->f_mentions || (sm->a1 > sm->pb && sm->a1 - 1 > sm->pb && sm->a1[-2] != ' ' && sm->a1[-2] != '\r' && sm->a1[-2] != '\n')) {
      // handle emails
      append_c(sm, '@');
      append_segment_html_escaped(sm, sm->a1, sm->a2 - 1);

    } else {
      if (is_boundary_c((*( sm->p)))) {
        sm->b = true;
        sm->d = 2;
      } else {
        sm->b = false;
        sm->d = 1;
      }

      append(sm, true, "<a rel=\"nofollow\" href=\"/users?name=");
      append_segment_uri_escaped(sm, sm->a1, sm->a2 - sm->d);
      append(sm, true, "\">");
      append_c(sm, '@');
      append_segment_html_escaped(sm, sm->a1, sm->a2 - sm->d);
      append(sm, true, "</a>");

      if (sm->b) {
        append_c_html_escaped(sm, (*( sm->p)));
      }
    }
  }
	break;
	case 43:
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
	case 44:
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
	case 46:
	{{( sm->p) = ((( sm->te)))-1;}
    g_debug("inline char: %c", (*( sm->p)));
    append_c_html_escaped(sm, (*( sm->p)));
  }
	break;
	}
	}
	goto _again;
f15:
#line 85 "ext/dtext/dtext.rl"
	{
  sm->b2 = sm->p;
}
#line 329 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    append(sm, true, "<a class=\"dtext-link dtext-external-link\" href=\"");
    append_segment_html_escaped(sm, sm->b1, sm->b2 - 1);
    append(sm, true, "\">");
    append_segment_html_escaped(sm, sm->a1, sm->a2 - 1);
    append(sm, true, "</a>");
  }}
	goto _again;
f100:
#line 85 "ext/dtext/dtext.rl"
	{
  sm->b2 = sm->p;
}
#line 167 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append(sm, true, "<a class=\"dtext-link dtext-id-link dtext-forum-topic-id-link\" href=\"/forum_topics/");
    append_segment(sm, true, sm->a1, sm->a2 - 1);
    append(sm, true, "?page=");
    append_segment(sm, true, sm->b1, sm->b2 - 1);
    append(sm, true, "\">");
    append(sm, false, "topic #");
    append_segment(sm, false, sm->a1, sm->a2 - 1);
    append(sm, false, "/p");
    append_segment(sm, false, sm->b1, sm->b2 - 1);
    append(sm, true, "</a>");
  }}
	goto _again;
f96:
#line 85 "ext/dtext/dtext.rl"
	{
  sm->b2 = sm->p;
}
#line 234 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append(sm, true, "<a class=\"dtext-link dtext-id-link dtext-pixiv-id-link\" href=\"http://www.pixiv.net/member_illust.php?mode=manga_big&illust_id=");
    append_segment(sm, true, sm->a1, sm->a2 - 1);
    append(sm, true, "&page=");
    append_segment(sm, true, sm->b1, sm->b2 - 1);
    append(sm, true, "\">");
    append(sm, false, "pixiv #");
    append_segment(sm, false, sm->a1, sm->a2 - 1);
    append(sm, false, "/p");
    append_segment(sm, false, sm->b1, sm->b2 - 1);
    append(sm, true, "</a>");
  }}
	goto _again;
f86:
#line 85 "ext/dtext/dtext.rl"
	{
  sm->b2 = sm->p;
}
#line 297 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    if (is_boundary_c((*( sm->p)))) {
      sm->d = 2;
      sm->b = true;
    } else {
      sm->d = 1;
      sm->b = false;
    }

    append(sm, true, "<a class=\"dtext-link dtext-external-link\" href=\"");
    append_segment_html_escaped(sm, sm->b1, sm->b2 - sm->d);
    append(sm, true, "\">");

    link_content_sm = init_machine(sm->a1, sm->a2 - sm->a1, false, true, false);
    if (!parse_helper(link_content_sm)) {
      g_debug("basic_textile_link: parse_helper failed");
      g_propagate_error(&sm->error, link_content_sm->error);
      free_machine(link_content_sm);
      {( sm->p)++; goto _out; }
    } else {
      append(sm, true, link_content_sm->output->str);
      free_machine(link_content_sm);
      link_content_sm = NULL;
    }

    append(sm, true, "</a>");

    if (sm->b) {
      append_c_html_escaped(sm, (*( sm->p)));
    }
  }}
	goto _again;
f83:
#line 85 "ext/dtext/dtext.rl"
	{
  sm->b2 = sm->p;
}
#line 390 "ext/dtext/dtext.rl"
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
     sm->cs = 327;
  }}
	goto _again;
f117:
#line 85 "ext/dtext/dtext.rl"
	{
  sm->b2 = sm->p;
}
#line 761 "ext/dtext/dtext.rl"
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
        g_debug("  dstack push ul");
        g_debug("  print <ul>");
        append_block(sm, "<ul>");
        dstack_push(sm, &BLOCK_UL);
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

    append_block(sm, "<li>");
    dstack_push(sm, &BLOCK_LI);

    g_debug("  print <li>");
    g_debug("  push li");
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
{( ((int *)sm->stack->data))[( sm->top)++] =  sm->cs;  sm->cs = 287; goto _again;}}
  }}
	goto _again;
f68:
#line 85 "ext/dtext/dtext.rl"
	{
  sm->b2 = sm->p;
}
#line 1002 "ext/dtext/dtext.rl"
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
{( ((int *)sm->stack->data))[( sm->top)++] =  sm->cs;  sm->cs = 327; goto _again;}}
  }}
	goto _again;
f17:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 73 "ext/dtext/dtext.rl"
	{
  sm->a1 = sm->p;
}
	goto _again;
f14:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 297 "ext/dtext/dtext.rl"
	{( sm->act) = 15;}
	goto _again;
f42:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 337 "ext/dtext/dtext.rl"
	{( sm->act) = 17;}
	goto _again;
f90:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 358 "ext/dtext/dtext.rl"
	{( sm->act) = 18;}
	goto _again;
f16:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 362 "ext/dtext/dtext.rl"
	{( sm->act) = 19;}
	goto _again;
f11:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 605 "ext/dtext/dtext.rl"
	{( sm->act) = 43;}
	goto _again;
f79:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 617 "ext/dtext/dtext.rl"
	{( sm->act) = 44;}
	goto _again;
f80:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 633 "ext/dtext/dtext.rl"
	{( sm->act) = 46;}
	goto _again;
f59:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 800 "ext/dtext/dtext.rl"
	{( sm->act) = 65;}
	goto _again;
f115:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 806 "ext/dtext/dtext.rl"
	{( sm->act) = 66;}
	goto _again;
f1:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 1018 "ext/dtext/dtext.rl"
	{( sm->act) = 81;}
	goto _again;
f65:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 1031 "ext/dtext/dtext.rl"
	{( sm->act) = 82;}
	goto _again;
f87:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 73 "ext/dtext/dtext.rl"
	{
  sm->a1 = sm->p;
}
#line 362 "ext/dtext/dtext.rl"
	{( sm->act) = 19;}
	goto _again;

_again:
	switch ( _dtext_to_state_actions[ sm->cs] ) {
	case 62:
#line 1 "NONE"
	{( sm->ts) = 0;}
	break;
#line 4742 "ext/dtext/dtext.c"
	}

	if ( ++( sm->p) != ( sm->pe) )
		goto _resume;
	_test_eof: {}
	if ( ( sm->p) == ( sm->eof) )
	{
	switch (  sm->cs ) {
	case 272: goto tr0;
	case 0: goto tr0;
	case 273: goto tr330;
	case 274: goto tr330;
	case 1: goto tr2;
	case 275: goto tr331;
	case 276: goto tr331;
	case 2: goto tr2;
	case 277: goto tr330;
	case 3: goto tr2;
	case 4: goto tr2;
	case 5: goto tr2;
	case 278: goto tr334;
	case 279: goto tr336;
	case 280: goto tr330;
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
	case 281: goto tr345;
	case 19: goto tr2;
	case 20: goto tr2;
	case 21: goto tr2;
	case 22: goto tr2;
	case 23: goto tr2;
	case 24: goto tr2;
	case 25: goto tr2;
	case 26: goto tr2;
	case 282: goto tr346;
	case 283: goto tr348;
	case 27: goto tr2;
	case 28: goto tr2;
	case 29: goto tr2;
	case 30: goto tr2;
	case 31: goto tr2;
	case 32: goto tr2;
	case 33: goto tr2;
	case 284: goto tr349;
	case 34: goto tr2;
	case 35: goto tr2;
	case 36: goto tr2;
	case 37: goto tr2;
	case 38: goto tr2;
	case 285: goto tr350;
	case 39: goto tr2;
	case 40: goto tr2;
	case 41: goto tr2;
	case 42: goto tr2;
	case 43: goto tr2;
	case 44: goto tr2;
	case 45: goto tr2;
	case 46: goto tr2;
	case 286: goto tr351;
	case 47: goto tr2;
	case 48: goto tr2;
	case 49: goto tr2;
	case 50: goto tr2;
	case 51: goto tr2;
	case 52: goto tr2;
	case 288: goto tr368;
	case 289: goto tr371;
	case 53: goto tr62;
	case 54: goto tr64;
	case 55: goto tr64;
	case 290: goto tr372;
	case 291: goto tr372;
	case 292: goto tr374;
	case 293: goto tr375;
	case 56: goto tr69;
	case 57: goto tr69;
	case 58: goto tr69;
	case 59: goto tr69;
	case 60: goto tr62;
	case 294: goto tr377;
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
	case 295: goto tr375;
	case 83: goto tr62;
	case 296: goto tr382;
	case 84: goto tr62;
	case 85: goto tr62;
	case 297: goto tr384;
	case 298: goto tr375;
	case 86: goto tr69;
	case 87: goto tr69;
	case 88: goto tr69;
	case 89: goto tr69;
	case 90: goto tr69;
	case 91: goto tr69;
	case 92: goto tr69;
	case 299: goto tr387;
	case 300: goto tr375;
	case 93: goto tr69;
	case 94: goto tr69;
	case 95: goto tr69;
	case 96: goto tr69;
	case 97: goto tr69;
	case 98: goto tr69;
	case 99: goto tr69;
	case 100: goto tr69;
	case 301: goto tr390;
	case 302: goto tr375;
	case 101: goto tr69;
	case 102: goto tr69;
	case 103: goto tr69;
	case 104: goto tr69;
	case 105: goto tr69;
	case 106: goto tr69;
	case 303: goto tr393;
	case 304: goto tr375;
	case 107: goto tr69;
	case 108: goto tr69;
	case 109: goto tr69;
	case 110: goto tr69;
	case 111: goto tr69;
	case 112: goto tr69;
	case 305: goto tr396;
	case 306: goto tr375;
	case 113: goto tr69;
	case 114: goto tr69;
	case 115: goto tr69;
	case 116: goto tr69;
	case 117: goto tr69;
	case 118: goto tr69;
	case 307: goto tr400;
	case 119: goto tr137;
	case 120: goto tr137;
	case 308: goto tr403;
	case 121: goto tr69;
	case 122: goto tr69;
	case 123: goto tr69;
	case 124: goto tr69;
	case 125: goto tr69;
	case 309: goto tr405;
	case 126: goto tr69;
	case 127: goto tr69;
	case 128: goto tr69;
	case 129: goto tr69;
	case 310: goto tr407;
	case 311: goto tr375;
	case 130: goto tr69;
	case 131: goto tr69;
	case 132: goto tr69;
	case 133: goto tr69;
	case 134: goto tr69;
	case 135: goto tr69;
	case 312: goto tr410;
	case 136: goto tr156;
	case 137: goto tr156;
	case 313: goto tr413;
	case 314: goto tr375;
	case 138: goto tr69;
	case 139: goto tr69;
	case 140: goto tr69;
	case 141: goto tr69;
	case 142: goto tr69;
	case 315: goto tr416;
	case 316: goto tr375;
	case 143: goto tr69;
	case 144: goto tr69;
	case 145: goto tr69;
	case 146: goto tr69;
	case 147: goto tr69;
	case 148: goto tr69;
	case 149: goto tr69;
	case 150: goto tr69;
	case 151: goto tr69;
	case 152: goto tr69;
	case 153: goto tr69;
	case 154: goto tr69;
	case 155: goto tr69;
	case 156: goto tr69;
	case 157: goto tr69;
	case 158: goto tr69;
	case 159: goto tr69;
	case 160: goto tr69;
	case 317: goto tr429;
	case 161: goto tr69;
	case 162: goto tr69;
	case 163: goto tr69;
	case 164: goto tr69;
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
	case 318: goto tr375;
	case 216: goto tr69;
	case 217: goto tr69;
	case 218: goto tr69;
	case 219: goto tr69;
	case 220: goto tr69;
	case 221: goto tr69;
	case 222: goto tr62;
	case 319: goto tr431;
	case 223: goto tr62;
	case 224: goto tr62;
	case 225: goto tr69;
	case 320: goto tr375;
	case 226: goto tr69;
	case 227: goto tr69;
	case 228: goto tr69;
	case 322: goto tr436;
	case 229: goto tr266;
	case 230: goto tr266;
	case 231: goto tr266;
	case 232: goto tr266;
	case 233: goto tr266;
	case 324: goto tr441;
	case 234: goto tr272;
	case 235: goto tr272;
	case 236: goto tr272;
	case 237: goto tr272;
	case 238: goto tr272;
	case 239: goto tr272;
	case 240: goto tr272;
	case 241: goto tr272;
	case 326: goto tr446;
	case 242: goto tr281;
	case 243: goto tr281;
	case 244: goto tr281;
	case 245: goto tr281;
	case 246: goto tr281;
	case 247: goto tr281;
	case 248: goto tr281;
	case 249: goto tr281;
	case 250: goto tr281;
	case 251: goto tr281;
	case 252: goto tr281;
	case 253: goto tr281;
	case 254: goto tr281;
	case 255: goto tr281;
	case 256: goto tr281;
	case 257: goto tr281;
	case 258: goto tr281;
	case 259: goto tr281;
	case 260: goto tr281;
	case 261: goto tr281;
	case 262: goto tr281;
	case 263: goto tr281;
	case 264: goto tr281;
	case 265: goto tr281;
	case 266: goto tr281;
	case 267: goto tr281;
	case 328: goto tr315;
	case 268: goto tr315;
	case 329: goto tr455;
	case 330: goto tr455;
	case 269: goto tr317;
	case 331: goto tr456;
	case 332: goto tr456;
	case 270: goto tr317;
	}
	}

	_out: {}
	}

#line 1395 "ext/dtext/dtext.rl"

  dstack_close(sm);

  return sm->error == NULL;
}

static void parse_file(FILE* input, FILE* output, gboolean opt_strip, gboolean opt_inline, gboolean opt_mentions) {
  char* dtext = NULL;
  size_t n = 0;

  ssize_t length = getdelim(&dtext, &n, '\0', input);
  if (length == -1) {
    free(dtext);

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

  free(dtext);
  free_machine(sm);
}

int main(int argc, char* argv[]) {
  GError* error = NULL;
  gboolean opt_verbose = FALSE;
  gboolean opt_strip = FALSE;
  gboolean opt_inline = FALSE;
  gboolean opt_no_mentions = FALSE;

  GOptionEntry options[] = {
    { "no-mentions", 'm', G_OPTION_FLAG_NONE, G_OPTION_ARG_NONE, &opt_no_mentions, "Don't parse @mentions", NULL },
    { "inline",      'i', G_OPTION_FLAG_NONE, G_OPTION_ARG_NONE, &opt_inline,      "Parse in inline mode", NULL },
    { "strip",       's', G_OPTION_FLAG_NONE, G_OPTION_ARG_NONE, &opt_strip,       "Strip markup", NULL },
    { "verbose",     'v', G_OPTION_FLAG_NONE, G_OPTION_ARG_NONE, &opt_verbose,     "Print debug output", NULL },
    { NULL }
  };

  GOptionContext* context = g_option_context_new("[FILE...]");
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
