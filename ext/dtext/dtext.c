
#line 1 "ext/dtext/dtext.rl"
// situationally print newlines to make the generated html
// easier to read
#define PRETTY_PRINT 0

#include <ruby.h>
#include <ruby/encoding.h>
#include <stdio.h>
#include <stdint.h>
#include <stdbool.h>
#include <glib.h>

typedef struct StateMachine {
  size_t top;
  int cs;
  int act;
  const char * p;
  const char * pb;
  const char * pe;
  const char * eof;
  const char * ts;
  const char * te;

  const char * a1;
  const char * a2;
  const char * b1;
  const char * b2;
  bool f_inline;
  bool f_strip;
  bool f_mentions;
  bool list_mode;
  bool header_mode;
  GString * output;
  GArray * stack;
  GQueue * dstack;
  int list_nest;
  int d;
  int b;
  int quote;
} StateMachine;

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


#line 1053 "ext/dtext/dtext.rl"



#line 80 "ext/dtext/dtext.c"
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
	0, 0, 0, 0, 0, 60, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 60, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 60, 0, 60, 0, 60, 0, 
	60, 0, 0, 0, 0, 0
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
	0, 0, 0, 0, 0, 61, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 61, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 61, 0, 61, 0, 61, 0, 
	61, 0, 0, 0, 0, 0
};

static const int dtext_start = 261;
static const int dtext_first_final = 261;
static const int dtext_error = -1;

static const int dtext_en_inline = 277;
static const int dtext_en_code = 314;
static const int dtext_en_nodtext = 316;
static const int dtext_en_table = 318;
static const int dtext_en_list = 320;
static const int dtext_en_main = 261;


#line 1056 "ext/dtext/dtext.rl"

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

static inline bool dstack_search(StateMachine * sm, const int * element) {
  return g_queue_find(sm->dstack, (gconstpointer)element);
}

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

static bool print_machine(StateMachine * sm) {
  printf("p=%c\n", *sm->p);
  return true;
}

static void init_machine(StateMachine * sm, const char * src, size_t len) {
  size_t output_length = 0;
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
  sm->f_inline = false;
  sm->f_strip = false;
  sm->f_mentions = true;
  sm->stack = g_array_sized_new(FALSE, TRUE, sizeof(int), 16);
  sm->dstack = g_queue_new();
  sm->list_nest = 0;
  sm->list_mode = false;
  sm->header_mode = false;
  sm->d = 0;
  sm->b = 0;
  sm->quote = 0;
}

static void free_machine(StateMachine * sm) {
  g_string_free(sm->output, TRUE);
  g_array_free(sm->stack, FALSE);
  g_queue_free(sm->dstack);
  g_free(sm);
}

static StateMachine * parse_helper(const char * src, size_t len, bool f_strip, bool f_inline, bool f_mentions) {
  StateMachine * sm = NULL;
  StateMachine * link_content_sm = NULL;

  sm = (StateMachine *)g_malloc0(sizeof(StateMachine));
  init_machine(sm, src, len);
  sm->f_strip = f_strip;
  sm->f_inline = f_inline;
  sm->f_mentions = f_mentions;

  
#line 511 "ext/dtext/dtext.c"
	{
	 sm->cs = dtext_start;
	( sm->top) = 0;
	( sm->ts) = 0;
	( sm->te) = 0;
	( sm->act) = 0;
	}

#line 1385 "ext/dtext/dtext.rl"
  
#line 522 "ext/dtext/dtext.c"
	{
	if ( ( sm->p) == ( sm->pe) )
		goto _test_eof;
_resume:
	switch ( _dtext_from_state_actions[ sm->cs] ) {
	case 61:
#line 1 "NONE"
	{( sm->ts) = ( sm->p);}
	break;
#line 532 "ext/dtext/dtext.c"
	}

	switch (  sm->cs ) {
case 261:
	switch( (*( sm->p)) ) {
		case 0: goto tr313;
		case 10: goto tr314;
		case 13: goto tr315;
		case 42: goto tr316;
		case 72: goto tr317;
		case 91: goto tr318;
		case 104: goto tr317;
	}
	goto tr312;
case 262:
	switch( (*( sm->p)) ) {
		case 10: goto tr1;
		case 13: goto tr319;
	}
	goto tr0;
case 0:
	if ( (*( sm->p)) == 10 )
		goto tr1;
	goto tr0;
case 263:
	if ( (*( sm->p)) == 10 )
		goto tr314;
	goto tr320;
case 264:
	switch( (*( sm->p)) ) {
		case 9: goto tr5;
		case 32: goto tr5;
		case 42: goto tr6;
	}
	goto tr320;
case 1:
	switch( (*( sm->p)) ) {
		case 0: goto tr2;
		case 9: goto tr4;
		case 10: goto tr2;
		case 13: goto tr2;
		case 32: goto tr4;
	}
	goto tr3;
case 265:
	switch( (*( sm->p)) ) {
		case 0: goto tr321;
		case 10: goto tr321;
		case 13: goto tr321;
	}
	goto tr322;
case 266:
	switch( (*( sm->p)) ) {
		case 0: goto tr321;
		case 9: goto tr4;
		case 10: goto tr321;
		case 13: goto tr321;
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
case 267:
	if ( 49 <= (*( sm->p)) && (*( sm->p)) <= 54 )
		goto tr323;
	goto tr320;
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
case 268:
	switch( (*( sm->p)) ) {
		case 9: goto tr325;
		case 32: goto tr325;
	}
	goto tr324;
case 269:
	switch( (*( sm->p)) ) {
		case 9: goto tr327;
		case 32: goto tr327;
	}
	goto tr326;
case 270:
	switch( (*( sm->p)) ) {
		case 47: goto tr328;
		case 67: goto tr329;
		case 69: goto tr330;
		case 78: goto tr331;
		case 81: goto tr332;
		case 83: goto tr333;
		case 84: goto tr334;
		case 99: goto tr329;
		case 101: goto tr330;
		case 110: goto tr331;
		case 113: goto tr332;
		case 115: goto tr333;
		case 116: goto tr334;
	}
	goto tr320;
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
	if ( (*( sm->p)) == 93 )
		goto tr19;
	goto tr2;
case 14:
	switch( (*( sm->p)) ) {
		case 79: goto tr20;
		case 111: goto tr20;
	}
	goto tr2;
case 15:
	switch( (*( sm->p)) ) {
		case 68: goto tr21;
		case 100: goto tr21;
	}
	goto tr2;
case 16:
	switch( (*( sm->p)) ) {
		case 69: goto tr22;
		case 101: goto tr22;
	}
	goto tr2;
case 17:
	if ( (*( sm->p)) == 93 )
		goto tr23;
	goto tr2;
case 271:
	if ( (*( sm->p)) == 32 )
		goto tr23;
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr23;
	goto tr335;
case 18:
	switch( (*( sm->p)) ) {
		case 88: goto tr24;
		case 120: goto tr24;
	}
	goto tr2;
case 19:
	switch( (*( sm->p)) ) {
		case 80: goto tr25;
		case 112: goto tr25;
	}
	goto tr2;
case 20:
	switch( (*( sm->p)) ) {
		case 65: goto tr26;
		case 97: goto tr26;
	}
	goto tr2;
case 21:
	switch( (*( sm->p)) ) {
		case 78: goto tr27;
		case 110: goto tr27;
	}
	goto tr2;
case 22:
	switch( (*( sm->p)) ) {
		case 68: goto tr28;
		case 100: goto tr28;
	}
	goto tr2;
case 23:
	switch( (*( sm->p)) ) {
		case 61: goto tr29;
		case 93: goto tr30;
	}
	goto tr2;
case 24:
	if ( (*( sm->p)) == 93 )
		goto tr2;
	goto tr31;
case 25:
	if ( (*( sm->p)) == 93 )
		goto tr33;
	goto tr32;
case 272:
	if ( (*( sm->p)) == 32 )
		goto tr337;
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr337;
	goto tr336;
case 273:
	if ( (*( sm->p)) == 32 )
		goto tr30;
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr30;
	goto tr338;
case 26:
	switch( (*( sm->p)) ) {
		case 79: goto tr34;
		case 111: goto tr34;
	}
	goto tr2;
case 27:
	switch( (*( sm->p)) ) {
		case 68: goto tr35;
		case 100: goto tr35;
	}
	goto tr2;
case 28:
	switch( (*( sm->p)) ) {
		case 84: goto tr36;
		case 116: goto tr36;
	}
	goto tr2;
case 29:
	switch( (*( sm->p)) ) {
		case 69: goto tr37;
		case 101: goto tr37;
	}
	goto tr2;
case 30:
	switch( (*( sm->p)) ) {
		case 88: goto tr38;
		case 120: goto tr38;
	}
	goto tr2;
case 31:
	switch( (*( sm->p)) ) {
		case 84: goto tr39;
		case 116: goto tr39;
	}
	goto tr2;
case 32:
	if ( (*( sm->p)) == 93 )
		goto tr40;
	goto tr2;
case 274:
	if ( (*( sm->p)) == 32 )
		goto tr40;
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr40;
	goto tr339;
case 33:
	switch( (*( sm->p)) ) {
		case 85: goto tr41;
		case 117: goto tr41;
	}
	goto tr2;
case 34:
	switch( (*( sm->p)) ) {
		case 79: goto tr42;
		case 111: goto tr42;
	}
	goto tr2;
case 35:
	switch( (*( sm->p)) ) {
		case 84: goto tr43;
		case 116: goto tr43;
	}
	goto tr2;
case 36:
	switch( (*( sm->p)) ) {
		case 69: goto tr44;
		case 101: goto tr44;
	}
	goto tr2;
case 37:
	if ( (*( sm->p)) == 93 )
		goto tr45;
	goto tr2;
case 275:
	if ( (*( sm->p)) == 32 )
		goto tr45;
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr45;
	goto tr340;
case 38:
	switch( (*( sm->p)) ) {
		case 80: goto tr46;
		case 112: goto tr46;
	}
	goto tr2;
case 39:
	switch( (*( sm->p)) ) {
		case 79: goto tr47;
		case 111: goto tr47;
	}
	goto tr2;
case 40:
	switch( (*( sm->p)) ) {
		case 73: goto tr48;
		case 105: goto tr48;
	}
	goto tr2;
case 41:
	switch( (*( sm->p)) ) {
		case 76: goto tr49;
		case 108: goto tr49;
	}
	goto tr2;
case 42:
	switch( (*( sm->p)) ) {
		case 69: goto tr50;
		case 101: goto tr50;
	}
	goto tr2;
case 43:
	switch( (*( sm->p)) ) {
		case 82: goto tr51;
		case 114: goto tr51;
	}
	goto tr2;
case 44:
	if ( (*( sm->p)) == 93 )
		goto tr52;
	goto tr2;
case 276:
	if ( (*( sm->p)) == 32 )
		goto tr52;
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr52;
	goto tr341;
case 45:
	switch( (*( sm->p)) ) {
		case 65: goto tr53;
		case 78: goto tr54;
		case 97: goto tr53;
		case 110: goto tr54;
	}
	goto tr2;
case 46:
	switch( (*( sm->p)) ) {
		case 66: goto tr55;
		case 98: goto tr55;
	}
	goto tr2;
case 47:
	switch( (*( sm->p)) ) {
		case 76: goto tr56;
		case 108: goto tr56;
	}
	goto tr2;
case 48:
	switch( (*( sm->p)) ) {
		case 69: goto tr57;
		case 101: goto tr57;
	}
	goto tr2;
case 49:
	if ( (*( sm->p)) == 93 )
		goto tr58;
	goto tr2;
case 50:
	if ( (*( sm->p)) == 93 )
		goto tr59;
	goto tr2;
case 277:
	switch( (*( sm->p)) ) {
		case 0: goto tr343;
		case 10: goto tr344;
		case 13: goto tr345;
		case 34: goto tr346;
		case 64: goto tr347;
		case 65: goto tr348;
		case 67: goto tr349;
		case 70: goto tr350;
		case 72: goto tr351;
		case 73: goto tr352;
		case 80: goto tr353;
		case 84: goto tr354;
		case 85: goto tr355;
		case 91: goto tr356;
		case 97: goto tr348;
		case 99: goto tr349;
		case 102: goto tr350;
		case 104: goto tr357;
		case 105: goto tr352;
		case 112: goto tr353;
		case 116: goto tr354;
		case 117: goto tr355;
		case 123: goto tr358;
	}
	goto tr342;
case 278:
	switch( (*( sm->p)) ) {
		case 10: goto tr61;
		case 13: goto tr360;
		case 42: goto tr361;
	}
	goto tr359;
case 279:
	switch( (*( sm->p)) ) {
		case 10: goto tr61;
		case 13: goto tr360;
	}
	goto tr362;
case 51:
	if ( (*( sm->p)) == 10 )
		goto tr61;
	goto tr60;
case 52:
	switch( (*( sm->p)) ) {
		case 9: goto tr63;
		case 32: goto tr63;
		case 42: goto tr64;
	}
	goto tr62;
case 53:
	switch( (*( sm->p)) ) {
		case 0: goto tr62;
		case 9: goto tr66;
		case 10: goto tr62;
		case 13: goto tr62;
		case 32: goto tr66;
	}
	goto tr65;
case 280:
	switch( (*( sm->p)) ) {
		case 0: goto tr363;
		case 10: goto tr363;
		case 13: goto tr363;
	}
	goto tr364;
case 281:
	switch( (*( sm->p)) ) {
		case 0: goto tr363;
		case 9: goto tr66;
		case 10: goto tr363;
		case 13: goto tr363;
		case 32: goto tr66;
	}
	goto tr65;
case 282:
	if ( (*( sm->p)) == 10 )
		goto tr344;
	goto tr365;
case 283:
	if ( (*( sm->p)) == 34 )
		goto tr366;
	goto tr367;
case 54:
	if ( (*( sm->p)) == 34 )
		goto tr69;
	goto tr68;
case 55:
	if ( (*( sm->p)) == 58 )
		goto tr70;
	goto tr67;
case 56:
	switch( (*( sm->p)) ) {
		case 47: goto tr71;
		case 91: goto tr72;
		case 104: goto tr73;
	}
	goto tr67;
case 57:
	if ( (*( sm->p)) < -32 ) {
		if ( -62 <= (*( sm->p)) && (*( sm->p)) <= -33 )
			goto tr74;
	} else if ( (*( sm->p)) > -17 ) {
		if ( (*( sm->p)) > -12 ) {
			if ( 33 <= (*( sm->p)) && (*( sm->p)) <= 126 )
				goto tr77;
		} else if ( (*( sm->p)) >= -16 )
			goto tr76;
	} else
		goto tr75;
	goto tr67;
case 58:
	if ( (*( sm->p)) <= -65 )
		goto tr77;
	goto tr60;
case 284:
	if ( (*( sm->p)) < -32 ) {
		if ( -62 <= (*( sm->p)) && (*( sm->p)) <= -33 )
			goto tr74;
	} else if ( (*( sm->p)) > -17 ) {
		if ( (*( sm->p)) > -12 ) {
			if ( 33 <= (*( sm->p)) && (*( sm->p)) <= 126 )
				goto tr77;
		} else if ( (*( sm->p)) >= -16 )
			goto tr76;
	} else
		goto tr75;
	goto tr368;
case 59:
	if ( (*( sm->p)) <= -65 )
		goto tr74;
	goto tr60;
case 60:
	if ( (*( sm->p)) <= -65 )
		goto tr75;
	goto tr60;
case 61:
	switch( (*( sm->p)) ) {
		case 47: goto tr78;
		case 104: goto tr79;
	}
	goto tr67;
case 62:
	if ( (*( sm->p)) < -32 ) {
		if ( -62 <= (*( sm->p)) && (*( sm->p)) <= -33 )
			goto tr80;
	} else if ( (*( sm->p)) > -17 ) {
		if ( (*( sm->p)) > -12 ) {
			if ( 33 <= (*( sm->p)) && (*( sm->p)) <= 126 )
				goto tr83;
		} else if ( (*( sm->p)) >= -16 )
			goto tr82;
	} else
		goto tr81;
	goto tr67;
case 63:
	if ( (*( sm->p)) <= -65 )
		goto tr83;
	goto tr67;
case 64:
	if ( (*( sm->p)) == 93 )
		goto tr84;
	if ( (*( sm->p)) < -32 ) {
		if ( -62 <= (*( sm->p)) && (*( sm->p)) <= -33 )
			goto tr80;
	} else if ( (*( sm->p)) > -17 ) {
		if ( (*( sm->p)) > -12 ) {
			if ( 33 <= (*( sm->p)) && (*( sm->p)) <= 126 )
				goto tr83;
		} else if ( (*( sm->p)) >= -16 )
			goto tr82;
	} else
		goto tr81;
	goto tr67;
case 65:
	if ( (*( sm->p)) <= -65 )
		goto tr80;
	goto tr67;
case 66:
	if ( (*( sm->p)) <= -65 )
		goto tr81;
	goto tr67;
case 67:
	if ( (*( sm->p)) == 116 )
		goto tr85;
	goto tr67;
case 68:
	if ( (*( sm->p)) == 116 )
		goto tr86;
	goto tr67;
case 69:
	if ( (*( sm->p)) == 112 )
		goto tr87;
	goto tr67;
case 70:
	switch( (*( sm->p)) ) {
		case 58: goto tr88;
		case 115: goto tr89;
	}
	goto tr67;
case 71:
	if ( (*( sm->p)) == 47 )
		goto tr90;
	goto tr67;
case 72:
	if ( (*( sm->p)) == 47 )
		goto tr91;
	goto tr67;
case 73:
	if ( (*( sm->p)) == 58 )
		goto tr88;
	goto tr67;
case 74:
	if ( (*( sm->p)) == 116 )
		goto tr92;
	goto tr67;
case 75:
	if ( (*( sm->p)) == 116 )
		goto tr93;
	goto tr67;
case 76:
	if ( (*( sm->p)) == 112 )
		goto tr94;
	goto tr67;
case 77:
	switch( (*( sm->p)) ) {
		case 58: goto tr95;
		case 115: goto tr96;
	}
	goto tr67;
case 78:
	if ( (*( sm->p)) == 47 )
		goto tr97;
	goto tr67;
case 79:
	if ( (*( sm->p)) == 47 )
		goto tr98;
	goto tr67;
case 80:
	if ( (*( sm->p)) == 58 )
		goto tr95;
	goto tr67;
case 285:
	if ( (*( sm->p)) < -32 ) {
		if ( -62 <= (*( sm->p)) && (*( sm->p)) <= -33 )
			goto tr369;
	} else if ( (*( sm->p)) > -17 ) {
		if ( (*( sm->p)) > -12 ) {
			if ( 33 <= (*( sm->p)) && (*( sm->p)) <= 126 )
				goto tr372;
		} else if ( (*( sm->p)) >= -16 )
			goto tr371;
	} else
		goto tr370;
	goto tr366;
case 81:
	if ( (*( sm->p)) <= -65 )
		goto tr99;
	goto tr60;
case 286:
	if ( (*( sm->p)) < -32 ) {
		if ( -62 <= (*( sm->p)) && (*( sm->p)) <= -33 )
			goto tr100;
	} else if ( (*( sm->p)) > -17 ) {
		if ( (*( sm->p)) > -12 ) {
			if ( 33 <= (*( sm->p)) && (*( sm->p)) <= 126 )
				goto tr99;
		} else if ( (*( sm->p)) >= -16 )
			goto tr374;
	} else
		goto tr101;
	goto tr373;
case 82:
	if ( (*( sm->p)) <= -65 )
		goto tr100;
	goto tr60;
case 83:
	if ( (*( sm->p)) <= -65 )
		goto tr101;
	goto tr60;
case 287:
	if ( (*( sm->p)) == 64 )
		goto tr376;
	if ( (*( sm->p)) < -32 ) {
		if ( -62 <= (*( sm->p)) && (*( sm->p)) <= -33 )
			goto tr100;
	} else if ( (*( sm->p)) > -17 ) {
		if ( (*( sm->p)) > -12 ) {
			if ( 33 <= (*( sm->p)) && (*( sm->p)) <= 126 )
				goto tr99;
		} else if ( (*( sm->p)) >= -16 )
			goto tr374;
	} else
		goto tr101;
	goto tr375;
case 288:
	switch( (*( sm->p)) ) {
		case 82: goto tr377;
		case 114: goto tr377;
	}
	goto tr366;
case 84:
	switch( (*( sm->p)) ) {
		case 84: goto tr102;
		case 116: goto tr102;
	}
	goto tr67;
case 85:
	switch( (*( sm->p)) ) {
		case 73: goto tr103;
		case 105: goto tr103;
	}
	goto tr67;
case 86:
	switch( (*( sm->p)) ) {
		case 83: goto tr104;
		case 115: goto tr104;
	}
	goto tr67;
case 87:
	switch( (*( sm->p)) ) {
		case 84: goto tr105;
		case 116: goto tr105;
	}
	goto tr67;
case 88:
	if ( (*( sm->p)) == 32 )
		goto tr106;
	goto tr67;
case 89:
	if ( (*( sm->p)) == 35 )
		goto tr107;
	goto tr67;
case 90:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr108;
	goto tr67;
case 289:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr379;
	goto tr378;
case 290:
	switch( (*( sm->p)) ) {
		case 79: goto tr380;
		case 111: goto tr380;
	}
	goto tr366;
case 91:
	switch( (*( sm->p)) ) {
		case 77: goto tr109;
		case 109: goto tr109;
	}
	goto tr67;
case 92:
	switch( (*( sm->p)) ) {
		case 77: goto tr110;
		case 109: goto tr110;
	}
	goto tr67;
case 93:
	switch( (*( sm->p)) ) {
		case 69: goto tr111;
		case 101: goto tr111;
	}
	goto tr67;
case 94:
	switch( (*( sm->p)) ) {
		case 78: goto tr112;
		case 110: goto tr112;
	}
	goto tr67;
case 95:
	switch( (*( sm->p)) ) {
		case 84: goto tr113;
		case 116: goto tr113;
	}
	goto tr67;
case 96:
	if ( (*( sm->p)) == 32 )
		goto tr114;
	goto tr67;
case 97:
	if ( (*( sm->p)) == 35 )
		goto tr115;
	goto tr67;
case 98:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr116;
	goto tr67;
case 291:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr382;
	goto tr381;
case 292:
	switch( (*( sm->p)) ) {
		case 79: goto tr383;
		case 111: goto tr383;
	}
	goto tr366;
case 99:
	switch( (*( sm->p)) ) {
		case 82: goto tr117;
		case 114: goto tr117;
	}
	goto tr67;
case 100:
	switch( (*( sm->p)) ) {
		case 85: goto tr118;
		case 117: goto tr118;
	}
	goto tr67;
case 101:
	switch( (*( sm->p)) ) {
		case 77: goto tr119;
		case 109: goto tr119;
	}
	goto tr67;
case 102:
	if ( (*( sm->p)) == 32 )
		goto tr120;
	goto tr67;
case 103:
	if ( (*( sm->p)) == 35 )
		goto tr121;
	goto tr67;
case 104:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr122;
	goto tr67;
case 293:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr385;
	goto tr384;
case 294:
	if ( 49 <= (*( sm->p)) && (*( sm->p)) <= 54 )
		goto tr386;
	goto tr366;
case 105:
	switch( (*( sm->p)) ) {
		case 35: goto tr123;
		case 46: goto tr124;
	}
	goto tr67;
case 106:
	if ( (*( sm->p)) == 33 )
		goto tr125;
	if ( (*( sm->p)) > 45 ) {
		if ( 47 <= (*( sm->p)) && (*( sm->p)) <= 126 )
			goto tr125;
	} else if ( (*( sm->p)) >= 35 )
		goto tr125;
	goto tr67;
case 107:
	switch( (*( sm->p)) ) {
		case 33: goto tr126;
		case 46: goto tr127;
	}
	if ( 35 <= (*( sm->p)) && (*( sm->p)) <= 126 )
		goto tr126;
	goto tr67;
case 295:
	switch( (*( sm->p)) ) {
		case 9: goto tr388;
		case 32: goto tr388;
	}
	goto tr387;
case 296:
	switch( (*( sm->p)) ) {
		case 9: goto tr390;
		case 32: goto tr390;
	}
	goto tr389;
case 297:
	switch( (*( sm->p)) ) {
		case 83: goto tr391;
		case 115: goto tr391;
	}
	goto tr366;
case 108:
	switch( (*( sm->p)) ) {
		case 83: goto tr128;
		case 115: goto tr128;
	}
	goto tr67;
case 109:
	switch( (*( sm->p)) ) {
		case 85: goto tr129;
		case 117: goto tr129;
	}
	goto tr67;
case 110:
	switch( (*( sm->p)) ) {
		case 69: goto tr130;
		case 101: goto tr130;
	}
	goto tr67;
case 111:
	if ( (*( sm->p)) == 32 )
		goto tr131;
	goto tr67;
case 112:
	if ( (*( sm->p)) == 35 )
		goto tr132;
	goto tr67;
case 113:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr133;
	goto tr67;
case 298:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr393;
	goto tr392;
case 299:
	switch( (*( sm->p)) ) {
		case 73: goto tr394;
		case 79: goto tr395;
		case 105: goto tr394;
		case 111: goto tr395;
	}
	goto tr366;
case 114:
	switch( (*( sm->p)) ) {
		case 88: goto tr134;
		case 120: goto tr134;
	}
	goto tr67;
case 115:
	switch( (*( sm->p)) ) {
		case 73: goto tr135;
		case 105: goto tr135;
	}
	goto tr67;
case 116:
	switch( (*( sm->p)) ) {
		case 86: goto tr136;
		case 118: goto tr136;
	}
	goto tr67;
case 117:
	if ( (*( sm->p)) == 32 )
		goto tr137;
	goto tr67;
case 118:
	if ( (*( sm->p)) == 35 )
		goto tr138;
	goto tr67;
case 119:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr139;
	goto tr67;
case 300:
	if ( (*( sm->p)) == 47 )
		goto tr397;
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr398;
	goto tr396;
case 120:
	if ( (*( sm->p)) == 112 )
		goto tr141;
	goto tr140;
case 121:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr142;
	goto tr140;
case 301:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr400;
	goto tr399;
case 122:
	switch( (*( sm->p)) ) {
		case 79: goto tr143;
		case 83: goto tr144;
		case 111: goto tr143;
		case 115: goto tr144;
	}
	goto tr67;
case 123:
	switch( (*( sm->p)) ) {
		case 76: goto tr145;
		case 108: goto tr145;
	}
	goto tr67;
case 124:
	if ( (*( sm->p)) == 32 )
		goto tr146;
	goto tr67;
case 125:
	if ( (*( sm->p)) == 35 )
		goto tr147;
	goto tr67;
case 126:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr148;
	goto tr67;
case 302:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr402;
	goto tr401;
case 127:
	switch( (*( sm->p)) ) {
		case 84: goto tr149;
		case 116: goto tr149;
	}
	goto tr67;
case 128:
	if ( (*( sm->p)) == 32 )
		goto tr150;
	goto tr67;
case 129:
	if ( (*( sm->p)) == 35 )
		goto tr151;
	goto tr67;
case 130:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr152;
	goto tr67;
case 303:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr404;
	goto tr403;
case 304:
	switch( (*( sm->p)) ) {
		case 79: goto tr405;
		case 111: goto tr405;
	}
	goto tr366;
case 131:
	switch( (*( sm->p)) ) {
		case 80: goto tr153;
		case 112: goto tr153;
	}
	goto tr67;
case 132:
	switch( (*( sm->p)) ) {
		case 73: goto tr154;
		case 105: goto tr154;
	}
	goto tr67;
case 133:
	switch( (*( sm->p)) ) {
		case 67: goto tr155;
		case 99: goto tr155;
	}
	goto tr67;
case 134:
	if ( (*( sm->p)) == 32 )
		goto tr156;
	goto tr67;
case 135:
	if ( (*( sm->p)) == 35 )
		goto tr157;
	goto tr67;
case 136:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr158;
	goto tr67;
case 305:
	if ( (*( sm->p)) == 47 )
		goto tr407;
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr408;
	goto tr406;
case 137:
	if ( (*( sm->p)) == 112 )
		goto tr160;
	goto tr159;
case 138:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr161;
	goto tr159;
case 306:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr410;
	goto tr409;
case 307:
	switch( (*( sm->p)) ) {
		case 83: goto tr411;
		case 115: goto tr411;
	}
	goto tr366;
case 139:
	switch( (*( sm->p)) ) {
		case 69: goto tr162;
		case 101: goto tr162;
	}
	goto tr67;
case 140:
	switch( (*( sm->p)) ) {
		case 82: goto tr163;
		case 114: goto tr163;
	}
	goto tr67;
case 141:
	if ( (*( sm->p)) == 32 )
		goto tr164;
	goto tr67;
case 142:
	if ( (*( sm->p)) == 35 )
		goto tr165;
	goto tr67;
case 143:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr166;
	goto tr67;
case 308:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr413;
	goto tr412;
case 309:
	switch( (*( sm->p)) ) {
		case 47: goto tr414;
		case 66: goto tr415;
		case 69: goto tr416;
		case 73: goto tr417;
		case 78: goto tr418;
		case 81: goto tr419;
		case 83: goto tr420;
		case 84: goto tr421;
		case 85: goto tr422;
		case 91: goto tr423;
		case 98: goto tr415;
		case 101: goto tr416;
		case 105: goto tr417;
		case 110: goto tr418;
		case 113: goto tr419;
		case 115: goto tr420;
		case 116: goto tr421;
		case 117: goto tr422;
	}
	goto tr366;
case 144:
	switch( (*( sm->p)) ) {
		case 66: goto tr167;
		case 69: goto tr168;
		case 73: goto tr169;
		case 81: goto tr170;
		case 83: goto tr171;
		case 84: goto tr172;
		case 85: goto tr173;
		case 98: goto tr167;
		case 101: goto tr168;
		case 105: goto tr169;
		case 113: goto tr170;
		case 115: goto tr171;
		case 116: goto tr172;
		case 117: goto tr173;
	}
	goto tr67;
case 145:
	if ( (*( sm->p)) == 93 )
		goto tr174;
	goto tr67;
case 146:
	switch( (*( sm->p)) ) {
		case 88: goto tr175;
		case 120: goto tr175;
	}
	goto tr67;
case 147:
	switch( (*( sm->p)) ) {
		case 80: goto tr176;
		case 112: goto tr176;
	}
	goto tr67;
case 148:
	switch( (*( sm->p)) ) {
		case 65: goto tr177;
		case 97: goto tr177;
	}
	goto tr67;
case 149:
	switch( (*( sm->p)) ) {
		case 78: goto tr178;
		case 110: goto tr178;
	}
	goto tr67;
case 150:
	switch( (*( sm->p)) ) {
		case 68: goto tr179;
		case 100: goto tr179;
	}
	goto tr67;
case 151:
	if ( (*( sm->p)) == 93 )
		goto tr180;
	goto tr67;
case 152:
	if ( (*( sm->p)) == 93 )
		goto tr181;
	goto tr67;
case 153:
	switch( (*( sm->p)) ) {
		case 85: goto tr182;
		case 117: goto tr182;
	}
	goto tr67;
case 154:
	switch( (*( sm->p)) ) {
		case 79: goto tr183;
		case 111: goto tr183;
	}
	goto tr67;
case 155:
	switch( (*( sm->p)) ) {
		case 84: goto tr184;
		case 116: goto tr184;
	}
	goto tr67;
case 156:
	switch( (*( sm->p)) ) {
		case 69: goto tr185;
		case 101: goto tr185;
	}
	goto tr67;
case 157:
	if ( (*( sm->p)) == 93 )
		goto tr186;
	goto tr67;
case 310:
	if ( (*( sm->p)) == 32 )
		goto tr186;
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr186;
	goto tr424;
case 158:
	switch( (*( sm->p)) ) {
		case 80: goto tr187;
		case 93: goto tr188;
		case 112: goto tr187;
	}
	goto tr67;
case 159:
	switch( (*( sm->p)) ) {
		case 79: goto tr189;
		case 111: goto tr189;
	}
	goto tr67;
case 160:
	switch( (*( sm->p)) ) {
		case 73: goto tr190;
		case 105: goto tr190;
	}
	goto tr67;
case 161:
	switch( (*( sm->p)) ) {
		case 76: goto tr191;
		case 108: goto tr191;
	}
	goto tr67;
case 162:
	switch( (*( sm->p)) ) {
		case 69: goto tr192;
		case 101: goto tr192;
	}
	goto tr67;
case 163:
	switch( (*( sm->p)) ) {
		case 82: goto tr193;
		case 114: goto tr193;
	}
	goto tr67;
case 164:
	if ( (*( sm->p)) == 93 )
		goto tr194;
	goto tr67;
case 165:
	switch( (*( sm->p)) ) {
		case 68: goto tr195;
		case 72: goto tr196;
		case 78: goto tr197;
		case 100: goto tr195;
		case 104: goto tr196;
		case 110: goto tr197;
	}
	goto tr67;
case 166:
	if ( (*( sm->p)) == 93 )
		goto tr198;
	goto tr67;
case 167:
	if ( (*( sm->p)) == 93 )
		goto tr199;
	goto tr67;
case 168:
	if ( (*( sm->p)) == 93 )
		goto tr200;
	goto tr67;
case 169:
	if ( (*( sm->p)) == 93 )
		goto tr201;
	goto tr67;
case 170:
	if ( (*( sm->p)) == 93 )
		goto tr202;
	goto tr67;
case 171:
	switch( (*( sm->p)) ) {
		case 88: goto tr203;
		case 120: goto tr203;
	}
	goto tr67;
case 172:
	switch( (*( sm->p)) ) {
		case 80: goto tr204;
		case 112: goto tr204;
	}
	goto tr67;
case 173:
	switch( (*( sm->p)) ) {
		case 65: goto tr205;
		case 97: goto tr205;
	}
	goto tr67;
case 174:
	switch( (*( sm->p)) ) {
		case 78: goto tr206;
		case 110: goto tr206;
	}
	goto tr67;
case 175:
	switch( (*( sm->p)) ) {
		case 68: goto tr207;
		case 100: goto tr207;
	}
	goto tr67;
case 176:
	if ( (*( sm->p)) == 93 )
		goto tr208;
	goto tr67;
case 177:
	if ( (*( sm->p)) == 93 )
		goto tr209;
	goto tr67;
case 178:
	switch( (*( sm->p)) ) {
		case 79: goto tr210;
		case 111: goto tr210;
	}
	goto tr67;
case 179:
	switch( (*( sm->p)) ) {
		case 68: goto tr211;
		case 100: goto tr211;
	}
	goto tr67;
case 180:
	switch( (*( sm->p)) ) {
		case 84: goto tr212;
		case 116: goto tr212;
	}
	goto tr67;
case 181:
	switch( (*( sm->p)) ) {
		case 69: goto tr213;
		case 101: goto tr213;
	}
	goto tr67;
case 182:
	switch( (*( sm->p)) ) {
		case 88: goto tr214;
		case 120: goto tr214;
	}
	goto tr67;
case 183:
	switch( (*( sm->p)) ) {
		case 84: goto tr215;
		case 116: goto tr215;
	}
	goto tr67;
case 184:
	if ( (*( sm->p)) == 93 )
		goto tr216;
	goto tr67;
case 185:
	switch( (*( sm->p)) ) {
		case 85: goto tr217;
		case 117: goto tr217;
	}
	goto tr67;
case 186:
	switch( (*( sm->p)) ) {
		case 79: goto tr218;
		case 111: goto tr218;
	}
	goto tr67;
case 187:
	switch( (*( sm->p)) ) {
		case 84: goto tr219;
		case 116: goto tr219;
	}
	goto tr67;
case 188:
	switch( (*( sm->p)) ) {
		case 69: goto tr220;
		case 101: goto tr220;
	}
	goto tr67;
case 189:
	if ( (*( sm->p)) == 93 )
		goto tr221;
	goto tr67;
case 190:
	switch( (*( sm->p)) ) {
		case 80: goto tr222;
		case 93: goto tr223;
		case 112: goto tr222;
	}
	goto tr67;
case 191:
	switch( (*( sm->p)) ) {
		case 79: goto tr224;
		case 111: goto tr224;
	}
	goto tr67;
case 192:
	switch( (*( sm->p)) ) {
		case 73: goto tr225;
		case 105: goto tr225;
	}
	goto tr67;
case 193:
	switch( (*( sm->p)) ) {
		case 76: goto tr226;
		case 108: goto tr226;
	}
	goto tr67;
case 194:
	switch( (*( sm->p)) ) {
		case 69: goto tr227;
		case 101: goto tr227;
	}
	goto tr67;
case 195:
	switch( (*( sm->p)) ) {
		case 82: goto tr228;
		case 114: goto tr228;
	}
	goto tr67;
case 196:
	if ( (*( sm->p)) == 93 )
		goto tr229;
	goto tr67;
case 197:
	switch( (*( sm->p)) ) {
		case 78: goto tr230;
		case 110: goto tr230;
	}
	goto tr67;
case 198:
	if ( (*( sm->p)) == 93 )
		goto tr231;
	goto tr67;
case 199:
	if ( (*( sm->p)) == 93 )
		goto tr232;
	goto tr67;
case 200:
	switch( (*( sm->p)) ) {
		case 93: goto tr67;
		case 124: goto tr67;
	}
	goto tr233;
case 201:
	switch( (*( sm->p)) ) {
		case 93: goto tr235;
		case 124: goto tr236;
	}
	goto tr234;
case 202:
	if ( (*( sm->p)) == 93 )
		goto tr237;
	goto tr67;
case 203:
	if ( (*( sm->p)) == 93 )
		goto tr67;
	goto tr238;
case 204:
	if ( (*( sm->p)) == 93 )
		goto tr240;
	goto tr239;
case 205:
	if ( (*( sm->p)) == 93 )
		goto tr241;
	goto tr67;
case 311:
	if ( (*( sm->p)) == 116 )
		goto tr425;
	if ( 49 <= (*( sm->p)) && (*( sm->p)) <= 54 )
		goto tr386;
	goto tr366;
case 206:
	if ( (*( sm->p)) == 116 )
		goto tr242;
	goto tr67;
case 207:
	if ( (*( sm->p)) == 112 )
		goto tr243;
	goto tr67;
case 208:
	switch( (*( sm->p)) ) {
		case 58: goto tr244;
		case 115: goto tr245;
	}
	goto tr67;
case 209:
	if ( (*( sm->p)) == 47 )
		goto tr246;
	goto tr67;
case 210:
	if ( (*( sm->p)) == 47 )
		goto tr247;
	goto tr67;
case 211:
	if ( (*( sm->p)) < -32 ) {
		if ( -62 <= (*( sm->p)) && (*( sm->p)) <= -33 )
			goto tr248;
	} else if ( (*( sm->p)) > -17 ) {
		if ( (*( sm->p)) > -12 ) {
			if ( 33 <= (*( sm->p)) && (*( sm->p)) <= 126 )
				goto tr251;
		} else if ( (*( sm->p)) >= -16 )
			goto tr250;
	} else
		goto tr249;
	goto tr67;
case 212:
	if ( (*( sm->p)) <= -65 )
		goto tr251;
	goto tr60;
case 312:
	if ( (*( sm->p)) < -32 ) {
		if ( -62 <= (*( sm->p)) && (*( sm->p)) <= -33 )
			goto tr248;
	} else if ( (*( sm->p)) > -17 ) {
		if ( (*( sm->p)) > -12 ) {
			if ( 33 <= (*( sm->p)) && (*( sm->p)) <= 126 )
				goto tr251;
		} else if ( (*( sm->p)) >= -16 )
			goto tr250;
	} else
		goto tr249;
	goto tr426;
case 213:
	if ( (*( sm->p)) <= -65 )
		goto tr248;
	goto tr60;
case 214:
	if ( (*( sm->p)) <= -65 )
		goto tr249;
	goto tr60;
case 215:
	if ( (*( sm->p)) == 58 )
		goto tr244;
	goto tr67;
case 313:
	if ( (*( sm->p)) == 123 )
		goto tr427;
	goto tr366;
case 216:
	if ( (*( sm->p)) == 125 )
		goto tr67;
	goto tr252;
case 217:
	if ( (*( sm->p)) == 125 )
		goto tr254;
	goto tr253;
case 218:
	if ( (*( sm->p)) == 125 )
		goto tr255;
	goto tr67;
case 314:
	switch( (*( sm->p)) ) {
		case 0: goto tr429;
		case 91: goto tr430;
	}
	goto tr428;
case 315:
	if ( (*( sm->p)) == 47 )
		goto tr432;
	goto tr431;
case 219:
	switch( (*( sm->p)) ) {
		case 67: goto tr257;
		case 99: goto tr257;
	}
	goto tr256;
case 220:
	switch( (*( sm->p)) ) {
		case 79: goto tr258;
		case 111: goto tr258;
	}
	goto tr256;
case 221:
	switch( (*( sm->p)) ) {
		case 68: goto tr259;
		case 100: goto tr259;
	}
	goto tr256;
case 222:
	switch( (*( sm->p)) ) {
		case 69: goto tr260;
		case 101: goto tr260;
	}
	goto tr256;
case 223:
	if ( (*( sm->p)) == 93 )
		goto tr261;
	goto tr256;
case 316:
	switch( (*( sm->p)) ) {
		case 0: goto tr434;
		case 91: goto tr435;
	}
	goto tr433;
case 317:
	if ( (*( sm->p)) == 47 )
		goto tr437;
	goto tr436;
case 224:
	switch( (*( sm->p)) ) {
		case 78: goto tr263;
		case 110: goto tr263;
	}
	goto tr262;
case 225:
	switch( (*( sm->p)) ) {
		case 79: goto tr264;
		case 111: goto tr264;
	}
	goto tr262;
case 226:
	switch( (*( sm->p)) ) {
		case 68: goto tr265;
		case 100: goto tr265;
	}
	goto tr262;
case 227:
	switch( (*( sm->p)) ) {
		case 84: goto tr266;
		case 116: goto tr266;
	}
	goto tr262;
case 228:
	switch( (*( sm->p)) ) {
		case 69: goto tr267;
		case 101: goto tr267;
	}
	goto tr262;
case 229:
	switch( (*( sm->p)) ) {
		case 88: goto tr268;
		case 120: goto tr268;
	}
	goto tr262;
case 230:
	switch( (*( sm->p)) ) {
		case 84: goto tr269;
		case 116: goto tr269;
	}
	goto tr262;
case 231:
	if ( (*( sm->p)) == 93 )
		goto tr270;
	goto tr262;
case 318:
	switch( (*( sm->p)) ) {
		case 0: goto tr439;
		case 91: goto tr440;
	}
	goto tr438;
case 319:
	switch( (*( sm->p)) ) {
		case 47: goto tr442;
		case 84: goto tr443;
		case 116: goto tr443;
	}
	goto tr441;
case 232:
	switch( (*( sm->p)) ) {
		case 84: goto tr272;
		case 116: goto tr272;
	}
	goto tr271;
case 233:
	switch( (*( sm->p)) ) {
		case 65: goto tr273;
		case 66: goto tr274;
		case 72: goto tr275;
		case 82: goto tr276;
		case 97: goto tr273;
		case 98: goto tr274;
		case 104: goto tr275;
		case 114: goto tr276;
	}
	goto tr271;
case 234:
	switch( (*( sm->p)) ) {
		case 66: goto tr277;
		case 98: goto tr277;
	}
	goto tr271;
case 235:
	switch( (*( sm->p)) ) {
		case 76: goto tr278;
		case 108: goto tr278;
	}
	goto tr271;
case 236:
	switch( (*( sm->p)) ) {
		case 69: goto tr279;
		case 101: goto tr279;
	}
	goto tr271;
case 237:
	if ( (*( sm->p)) == 93 )
		goto tr280;
	goto tr271;
case 238:
	switch( (*( sm->p)) ) {
		case 79: goto tr281;
		case 111: goto tr281;
	}
	goto tr271;
case 239:
	switch( (*( sm->p)) ) {
		case 68: goto tr282;
		case 100: goto tr282;
	}
	goto tr271;
case 240:
	switch( (*( sm->p)) ) {
		case 89: goto tr283;
		case 121: goto tr283;
	}
	goto tr271;
case 241:
	if ( (*( sm->p)) == 93 )
		goto tr284;
	goto tr271;
case 242:
	switch( (*( sm->p)) ) {
		case 69: goto tr285;
		case 101: goto tr285;
	}
	goto tr271;
case 243:
	switch( (*( sm->p)) ) {
		case 65: goto tr286;
		case 97: goto tr286;
	}
	goto tr271;
case 244:
	switch( (*( sm->p)) ) {
		case 68: goto tr287;
		case 100: goto tr287;
	}
	goto tr271;
case 245:
	if ( (*( sm->p)) == 93 )
		goto tr288;
	goto tr271;
case 246:
	if ( (*( sm->p)) == 93 )
		goto tr289;
	goto tr271;
case 247:
	switch( (*( sm->p)) ) {
		case 66: goto tr290;
		case 68: goto tr291;
		case 72: goto tr292;
		case 82: goto tr293;
		case 98: goto tr290;
		case 100: goto tr291;
		case 104: goto tr292;
		case 114: goto tr293;
	}
	goto tr271;
case 248:
	switch( (*( sm->p)) ) {
		case 79: goto tr294;
		case 111: goto tr294;
	}
	goto tr271;
case 249:
	switch( (*( sm->p)) ) {
		case 68: goto tr295;
		case 100: goto tr295;
	}
	goto tr271;
case 250:
	switch( (*( sm->p)) ) {
		case 89: goto tr296;
		case 121: goto tr296;
	}
	goto tr271;
case 251:
	if ( (*( sm->p)) == 93 )
		goto tr297;
	goto tr271;
case 252:
	if ( (*( sm->p)) == 93 )
		goto tr298;
	goto tr271;
case 253:
	switch( (*( sm->p)) ) {
		case 69: goto tr299;
		case 93: goto tr300;
		case 101: goto tr299;
	}
	goto tr271;
case 254:
	switch( (*( sm->p)) ) {
		case 65: goto tr301;
		case 97: goto tr301;
	}
	goto tr271;
case 255:
	switch( (*( sm->p)) ) {
		case 68: goto tr302;
		case 100: goto tr302;
	}
	goto tr271;
case 256:
	if ( (*( sm->p)) == 93 )
		goto tr303;
	goto tr271;
case 257:
	if ( (*( sm->p)) == 93 )
		goto tr304;
	goto tr271;
case 320:
	switch( (*( sm->p)) ) {
		case 0: goto tr445;
		case 10: goto tr446;
		case 13: goto tr447;
		case 42: goto tr448;
	}
	goto tr444;
case 321:
	switch( (*( sm->p)) ) {
		case 10: goto tr306;
		case 13: goto tr449;
	}
	goto tr305;
case 258:
	if ( (*( sm->p)) == 10 )
		goto tr306;
	goto tr305;
case 322:
	if ( (*( sm->p)) == 10 )
		goto tr446;
	goto tr450;
case 323:
	switch( (*( sm->p)) ) {
		case 9: goto tr310;
		case 32: goto tr310;
		case 42: goto tr311;
	}
	goto tr450;
case 259:
	switch( (*( sm->p)) ) {
		case 0: goto tr307;
		case 9: goto tr309;
		case 10: goto tr307;
		case 13: goto tr307;
		case 32: goto tr309;
	}
	goto tr308;
case 324:
	switch( (*( sm->p)) ) {
		case 0: goto tr451;
		case 10: goto tr451;
		case 13: goto tr451;
	}
	goto tr452;
case 325:
	switch( (*( sm->p)) ) {
		case 0: goto tr451;
		case 9: goto tr309;
		case 10: goto tr451;
		case 13: goto tr451;
		case 32: goto tr309;
	}
	goto tr308;
case 260:
	switch( (*( sm->p)) ) {
		case 9: goto tr310;
		case 32: goto tr310;
		case 42: goto tr311;
	}
	goto tr307;
	}

	tr319:  sm->cs = 0; goto _again;
	tr5:  sm->cs = 1; goto f4;
	tr6:  sm->cs = 2; goto _again;
	tr323:  sm->cs = 3; goto f7;
	tr7:  sm->cs = 4; goto f4;
	tr10:  sm->cs = 5; goto _again;
	tr9:  sm->cs = 5; goto f3;
	tr328:  sm->cs = 6; goto _again;
	tr12:  sm->cs = 7; goto _again;
	tr13:  sm->cs = 8; goto _again;
	tr14:  sm->cs = 9; goto _again;
	tr15:  sm->cs = 10; goto _again;
	tr16:  sm->cs = 11; goto _again;
	tr17:  sm->cs = 12; goto _again;
	tr18:  sm->cs = 13; goto _again;
	tr329:  sm->cs = 14; goto _again;
	tr20:  sm->cs = 15; goto _again;
	tr21:  sm->cs = 16; goto _again;
	tr22:  sm->cs = 17; goto _again;
	tr330:  sm->cs = 18; goto _again;
	tr24:  sm->cs = 19; goto _again;
	tr25:  sm->cs = 20; goto _again;
	tr26:  sm->cs = 21; goto _again;
	tr27:  sm->cs = 22; goto _again;
	tr28:  sm->cs = 23; goto _again;
	tr29:  sm->cs = 24; goto _again;
	tr32:  sm->cs = 25; goto _again;
	tr31:  sm->cs = 25; goto f7;
	tr331:  sm->cs = 26; goto _again;
	tr34:  sm->cs = 27; goto _again;
	tr35:  sm->cs = 28; goto _again;
	tr36:  sm->cs = 29; goto _again;
	tr37:  sm->cs = 30; goto _again;
	tr38:  sm->cs = 31; goto _again;
	tr39:  sm->cs = 32; goto _again;
	tr332:  sm->cs = 33; goto _again;
	tr41:  sm->cs = 34; goto _again;
	tr42:  sm->cs = 35; goto _again;
	tr43:  sm->cs = 36; goto _again;
	tr44:  sm->cs = 37; goto _again;
	tr333:  sm->cs = 38; goto _again;
	tr46:  sm->cs = 39; goto _again;
	tr47:  sm->cs = 40; goto _again;
	tr48:  sm->cs = 41; goto _again;
	tr49:  sm->cs = 42; goto _again;
	tr50:  sm->cs = 43; goto _again;
	tr51:  sm->cs = 44; goto _again;
	tr334:  sm->cs = 45; goto _again;
	tr53:  sm->cs = 46; goto _again;
	tr55:  sm->cs = 47; goto _again;
	tr56:  sm->cs = 48; goto _again;
	tr57:  sm->cs = 49; goto _again;
	tr54:  sm->cs = 50; goto _again;
	tr360:  sm->cs = 51; goto _again;
	tr64:  sm->cs = 52; goto _again;
	tr361:  sm->cs = 52; goto f7;
	tr63:  sm->cs = 53; goto f4;
	tr68:  sm->cs = 54; goto _again;
	tr367:  sm->cs = 54; goto f7;
	tr69:  sm->cs = 55; goto f4;
	tr70:  sm->cs = 56; goto _again;
	tr98:  sm->cs = 57; goto _again;
	tr71:  sm->cs = 57; goto f3;
	tr74:  sm->cs = 58; goto _again;
	tr75:  sm->cs = 59; goto _again;
	tr76:  sm->cs = 60; goto _again;
	tr72:  sm->cs = 61; goto _again;
	tr91:  sm->cs = 62; goto _again;
	tr78:  sm->cs = 62; goto f3;
	tr80:  sm->cs = 63; goto _again;
	tr83:  sm->cs = 64; goto _again;
	tr81:  sm->cs = 65; goto _again;
	tr82:  sm->cs = 66; goto _again;
	tr79:  sm->cs = 67; goto f3;
	tr85:  sm->cs = 68; goto _again;
	tr86:  sm->cs = 69; goto _again;
	tr87:  sm->cs = 70; goto _again;
	tr88:  sm->cs = 71; goto _again;
	tr90:  sm->cs = 72; goto _again;
	tr89:  sm->cs = 73; goto _again;
	tr73:  sm->cs = 74; goto f3;
	tr92:  sm->cs = 75; goto _again;
	tr93:  sm->cs = 76; goto _again;
	tr94:  sm->cs = 77; goto _again;
	tr95:  sm->cs = 78; goto _again;
	tr97:  sm->cs = 79; goto _again;
	tr96:  sm->cs = 80; goto _again;
	tr100:  sm->cs = 81; goto _again;
	tr369:  sm->cs = 81; goto f7;
	tr101:  sm->cs = 82; goto _again;
	tr370:  sm->cs = 82; goto f7;
	tr374:  sm->cs = 83; goto _again;
	tr371:  sm->cs = 83; goto f7;
	tr377:  sm->cs = 84; goto _again;
	tr102:  sm->cs = 85; goto _again;
	tr103:  sm->cs = 86; goto _again;
	tr104:  sm->cs = 87; goto _again;
	tr105:  sm->cs = 88; goto _again;
	tr106:  sm->cs = 89; goto _again;
	tr107:  sm->cs = 90; goto _again;
	tr380:  sm->cs = 91; goto _again;
	tr109:  sm->cs = 92; goto _again;
	tr110:  sm->cs = 93; goto _again;
	tr111:  sm->cs = 94; goto _again;
	tr112:  sm->cs = 95; goto _again;
	tr113:  sm->cs = 96; goto _again;
	tr114:  sm->cs = 97; goto _again;
	tr115:  sm->cs = 98; goto _again;
	tr383:  sm->cs = 99; goto _again;
	tr117:  sm->cs = 100; goto _again;
	tr118:  sm->cs = 101; goto _again;
	tr119:  sm->cs = 102; goto _again;
	tr120:  sm->cs = 103; goto _again;
	tr121:  sm->cs = 104; goto _again;
	tr386:  sm->cs = 105; goto f7;
	tr123:  sm->cs = 106; goto f4;
	tr126:  sm->cs = 107; goto _again;
	tr125:  sm->cs = 107; goto f3;
	tr391:  sm->cs = 108; goto _again;
	tr128:  sm->cs = 109; goto _again;
	tr129:  sm->cs = 110; goto _again;
	tr130:  sm->cs = 111; goto _again;
	tr131:  sm->cs = 112; goto _again;
	tr132:  sm->cs = 113; goto _again;
	tr394:  sm->cs = 114; goto _again;
	tr134:  sm->cs = 115; goto _again;
	tr135:  sm->cs = 116; goto _again;
	tr136:  sm->cs = 117; goto _again;
	tr137:  sm->cs = 118; goto _again;
	tr138:  sm->cs = 119; goto _again;
	tr397:  sm->cs = 120; goto f4;
	tr141:  sm->cs = 121; goto _again;
	tr395:  sm->cs = 122; goto _again;
	tr143:  sm->cs = 123; goto _again;
	tr145:  sm->cs = 124; goto _again;
	tr146:  sm->cs = 125; goto _again;
	tr147:  sm->cs = 126; goto _again;
	tr144:  sm->cs = 127; goto _again;
	tr149:  sm->cs = 128; goto _again;
	tr150:  sm->cs = 129; goto _again;
	tr151:  sm->cs = 130; goto _again;
	tr405:  sm->cs = 131; goto _again;
	tr153:  sm->cs = 132; goto _again;
	tr154:  sm->cs = 133; goto _again;
	tr155:  sm->cs = 134; goto _again;
	tr156:  sm->cs = 135; goto _again;
	tr157:  sm->cs = 136; goto _again;
	tr407:  sm->cs = 137; goto f4;
	tr160:  sm->cs = 138; goto _again;
	tr411:  sm->cs = 139; goto _again;
	tr162:  sm->cs = 140; goto _again;
	tr163:  sm->cs = 141; goto _again;
	tr164:  sm->cs = 142; goto _again;
	tr165:  sm->cs = 143; goto _again;
	tr414:  sm->cs = 144; goto _again;
	tr167:  sm->cs = 145; goto _again;
	tr168:  sm->cs = 146; goto _again;
	tr175:  sm->cs = 147; goto _again;
	tr176:  sm->cs = 148; goto _again;
	tr177:  sm->cs = 149; goto _again;
	tr178:  sm->cs = 150; goto _again;
	tr179:  sm->cs = 151; goto _again;
	tr169:  sm->cs = 152; goto _again;
	tr170:  sm->cs = 153; goto _again;
	tr182:  sm->cs = 154; goto _again;
	tr183:  sm->cs = 155; goto _again;
	tr184:  sm->cs = 156; goto _again;
	tr185:  sm->cs = 157; goto _again;
	tr171:  sm->cs = 158; goto _again;
	tr187:  sm->cs = 159; goto _again;
	tr189:  sm->cs = 160; goto _again;
	tr190:  sm->cs = 161; goto _again;
	tr191:  sm->cs = 162; goto _again;
	tr192:  sm->cs = 163; goto _again;
	tr193:  sm->cs = 164; goto _again;
	tr172:  sm->cs = 165; goto _again;
	tr195:  sm->cs = 166; goto _again;
	tr196:  sm->cs = 167; goto _again;
	tr197:  sm->cs = 168; goto _again;
	tr173:  sm->cs = 169; goto _again;
	tr415:  sm->cs = 170; goto _again;
	tr416:  sm->cs = 171; goto _again;
	tr203:  sm->cs = 172; goto _again;
	tr204:  sm->cs = 173; goto _again;
	tr205:  sm->cs = 174; goto _again;
	tr206:  sm->cs = 175; goto _again;
	tr207:  sm->cs = 176; goto _again;
	tr417:  sm->cs = 177; goto _again;
	tr418:  sm->cs = 178; goto _again;
	tr210:  sm->cs = 179; goto _again;
	tr211:  sm->cs = 180; goto _again;
	tr212:  sm->cs = 181; goto _again;
	tr213:  sm->cs = 182; goto _again;
	tr214:  sm->cs = 183; goto _again;
	tr215:  sm->cs = 184; goto _again;
	tr419:  sm->cs = 185; goto _again;
	tr217:  sm->cs = 186; goto _again;
	tr218:  sm->cs = 187; goto _again;
	tr219:  sm->cs = 188; goto _again;
	tr220:  sm->cs = 189; goto _again;
	tr420:  sm->cs = 190; goto _again;
	tr222:  sm->cs = 191; goto _again;
	tr224:  sm->cs = 192; goto _again;
	tr225:  sm->cs = 193; goto _again;
	tr226:  sm->cs = 194; goto _again;
	tr227:  sm->cs = 195; goto _again;
	tr228:  sm->cs = 196; goto _again;
	tr421:  sm->cs = 197; goto _again;
	tr230:  sm->cs = 198; goto _again;
	tr422:  sm->cs = 199; goto _again;
	tr423:  sm->cs = 200; goto _again;
	tr234:  sm->cs = 201; goto _again;
	tr233:  sm->cs = 201; goto f7;
	tr235:  sm->cs = 202; goto f4;
	tr236:  sm->cs = 203; goto f4;
	tr239:  sm->cs = 204; goto _again;
	tr238:  sm->cs = 204; goto f3;
	tr240:  sm->cs = 205; goto f5;
	tr425:  sm->cs = 206; goto _again;
	tr242:  sm->cs = 207; goto _again;
	tr243:  sm->cs = 208; goto _again;
	tr244:  sm->cs = 209; goto _again;
	tr246:  sm->cs = 210; goto _again;
	tr247:  sm->cs = 211; goto _again;
	tr248:  sm->cs = 212; goto _again;
	tr249:  sm->cs = 213; goto _again;
	tr250:  sm->cs = 214; goto _again;
	tr245:  sm->cs = 215; goto _again;
	tr427:  sm->cs = 216; goto _again;
	tr253:  sm->cs = 217; goto _again;
	tr252:  sm->cs = 217; goto f7;
	tr254:  sm->cs = 218; goto f4;
	tr432:  sm->cs = 219; goto _again;
	tr257:  sm->cs = 220; goto _again;
	tr258:  sm->cs = 221; goto _again;
	tr259:  sm->cs = 222; goto _again;
	tr260:  sm->cs = 223; goto _again;
	tr437:  sm->cs = 224; goto _again;
	tr263:  sm->cs = 225; goto _again;
	tr264:  sm->cs = 226; goto _again;
	tr265:  sm->cs = 227; goto _again;
	tr266:  sm->cs = 228; goto _again;
	tr267:  sm->cs = 229; goto _again;
	tr268:  sm->cs = 230; goto _again;
	tr269:  sm->cs = 231; goto _again;
	tr442:  sm->cs = 232; goto _again;
	tr272:  sm->cs = 233; goto _again;
	tr273:  sm->cs = 234; goto _again;
	tr277:  sm->cs = 235; goto _again;
	tr278:  sm->cs = 236; goto _again;
	tr279:  sm->cs = 237; goto _again;
	tr274:  sm->cs = 238; goto _again;
	tr281:  sm->cs = 239; goto _again;
	tr282:  sm->cs = 240; goto _again;
	tr283:  sm->cs = 241; goto _again;
	tr275:  sm->cs = 242; goto _again;
	tr285:  sm->cs = 243; goto _again;
	tr286:  sm->cs = 244; goto _again;
	tr287:  sm->cs = 245; goto _again;
	tr276:  sm->cs = 246; goto _again;
	tr443:  sm->cs = 247; goto _again;
	tr290:  sm->cs = 248; goto _again;
	tr294:  sm->cs = 249; goto _again;
	tr295:  sm->cs = 250; goto _again;
	tr296:  sm->cs = 251; goto _again;
	tr291:  sm->cs = 252; goto _again;
	tr292:  sm->cs = 253; goto _again;
	tr299:  sm->cs = 254; goto _again;
	tr301:  sm->cs = 255; goto _again;
	tr302:  sm->cs = 256; goto _again;
	tr293:  sm->cs = 257; goto _again;
	tr449:  sm->cs = 258; goto _again;
	tr310:  sm->cs = 259; goto f4;
	tr311:  sm->cs = 260; goto _again;
	tr0:  sm->cs = 261; goto f0;
	tr2:  sm->cs = 261; goto f2;
	tr19:  sm->cs = 261; goto f6;
	tr58:  sm->cs = 261; goto f8;
	tr59:  sm->cs = 261; goto f9;
	tr312:  sm->cs = 261; goto f61;
	tr313:  sm->cs = 261; goto f62;
	tr320:  sm->cs = 261; goto f65;
	tr321:  sm->cs = 261; goto f66;
	tr324:  sm->cs = 261; goto f67;
	tr326:  sm->cs = 261; goto f68;
	tr335:  sm->cs = 261; goto f69;
	tr336:  sm->cs = 261; goto f70;
	tr338:  sm->cs = 261; goto f71;
	tr339:  sm->cs = 261; goto f72;
	tr340:  sm->cs = 261; goto f73;
	tr341:  sm->cs = 261; goto f74;
	tr1:  sm->cs = 262; goto f1;
	tr314:  sm->cs = 262; goto f63;
	tr315:  sm->cs = 263; goto _again;
	tr316:  sm->cs = 264; goto f17;
	tr322:  sm->cs = 265; goto _again;
	tr3:  sm->cs = 265; goto f3;
	tr4:  sm->cs = 266; goto f3;
	tr317:  sm->cs = 267; goto f64;
	tr325:  sm->cs = 268; goto _again;
	tr11:  sm->cs = 268; goto f5;
	tr327:  sm->cs = 269; goto _again;
	tr8:  sm->cs = 269; goto f4;
	tr318:  sm->cs = 270; goto f64;
	tr23:  sm->cs = 271; goto _again;
	tr337:  sm->cs = 272; goto _again;
	tr33:  sm->cs = 272; goto f4;
	tr30:  sm->cs = 273; goto _again;
	tr40:  sm->cs = 274; goto _again;
	tr45:  sm->cs = 275; goto _again;
	tr52:  sm->cs = 276; goto _again;
	tr60:  sm->cs = 277; goto f10;
	tr62:  sm->cs = 277; goto f12;
	tr67:  sm->cs = 277; goto f13;
	tr84:  sm->cs = 277; goto f15;
	tr140:  sm->cs = 277; goto f18;
	tr159:  sm->cs = 277; goto f19;
	tr174:  sm->cs = 277; goto f20;
	tr180:  sm->cs = 277; goto f21;
	tr181:  sm->cs = 277; goto f22;
	tr188:  sm->cs = 277; goto f23;
	tr194:  sm->cs = 277; goto f24;
	tr198:  sm->cs = 277; goto f25;
	tr199:  sm->cs = 277; goto f26;
	tr200:  sm->cs = 277; goto f27;
	tr201:  sm->cs = 277; goto f28;
	tr202:  sm->cs = 277; goto f29;
	tr208:  sm->cs = 277; goto f30;
	tr209:  sm->cs = 277; goto f31;
	tr216:  sm->cs = 277; goto f32;
	tr221:  sm->cs = 277; goto f33;
	tr223:  sm->cs = 277; goto f34;
	tr229:  sm->cs = 277; goto f35;
	tr231:  sm->cs = 277; goto f36;
	tr232:  sm->cs = 277; goto f37;
	tr237:  sm->cs = 277; goto f38;
	tr241:  sm->cs = 277; goto f39;
	tr255:  sm->cs = 277; goto f41;
	tr342:  sm->cs = 277; goto f75;
	tr343:  sm->cs = 277; goto f76;
	tr359:  sm->cs = 277; goto f79;
	tr362:  sm->cs = 277; goto f80;
	tr363:  sm->cs = 277; goto f81;
	tr365:  sm->cs = 277; goto f82;
	tr366:  sm->cs = 277; goto f83;
	tr368:  sm->cs = 277; goto f84;
	tr373:  sm->cs = 277; goto f86;
	tr375:  sm->cs = 277; goto f87;
	tr378:  sm->cs = 277; goto f89;
	tr381:  sm->cs = 277; goto f90;
	tr384:  sm->cs = 277; goto f91;
	tr387:  sm->cs = 277; goto f92;
	tr389:  sm->cs = 277; goto f93;
	tr392:  sm->cs = 277; goto f94;
	tr396:  sm->cs = 277; goto f95;
	tr399:  sm->cs = 277; goto f96;
	tr401:  sm->cs = 277; goto f97;
	tr403:  sm->cs = 277; goto f98;
	tr406:  sm->cs = 277; goto f99;
	tr409:  sm->cs = 277; goto f100;
	tr412:  sm->cs = 277; goto f101;
	tr424:  sm->cs = 277; goto f102;
	tr426:  sm->cs = 277; goto f103;
	tr344:  sm->cs = 278; goto f77;
	tr61:  sm->cs = 279; goto f11;
	tr364:  sm->cs = 280; goto _again;
	tr65:  sm->cs = 280; goto f3;
	tr66:  sm->cs = 281; goto f3;
	tr345:  sm->cs = 282; goto _again;
	tr346:  sm->cs = 283; goto f78;
	tr77:  sm->cs = 284; goto f14;
	tr347:  sm->cs = 285; goto f78;
	tr99:  sm->cs = 286; goto f16;
	tr376:  sm->cs = 286; goto f88;
	tr372:  sm->cs = 287; goto f85;
	tr348:  sm->cs = 288; goto f64;
	tr379:  sm->cs = 289; goto _again;
	tr108:  sm->cs = 289; goto f7;
	tr349:  sm->cs = 290; goto f64;
	tr382:  sm->cs = 291; goto _again;
	tr116:  sm->cs = 291; goto f7;
	tr350:  sm->cs = 292; goto f64;
	tr385:  sm->cs = 293; goto _again;
	tr122:  sm->cs = 293; goto f7;
	tr351:  sm->cs = 294; goto f64;
	tr388:  sm->cs = 295; goto _again;
	tr127:  sm->cs = 295; goto f5;
	tr390:  sm->cs = 296; goto _again;
	tr124:  sm->cs = 296; goto f4;
	tr352:  sm->cs = 297; goto f64;
	tr393:  sm->cs = 298; goto _again;
	tr133:  sm->cs = 298; goto f7;
	tr353:  sm->cs = 299; goto f64;
	tr139:  sm->cs = 300; goto f17;
	tr398:  sm->cs = 300; goto f64;
	tr400:  sm->cs = 301; goto _again;
	tr142:  sm->cs = 301; goto f3;
	tr402:  sm->cs = 302; goto _again;
	tr148:  sm->cs = 302; goto f7;
	tr404:  sm->cs = 303; goto _again;
	tr152:  sm->cs = 303; goto f7;
	tr354:  sm->cs = 304; goto f64;
	tr158:  sm->cs = 305; goto f17;
	tr408:  sm->cs = 305; goto f64;
	tr410:  sm->cs = 306; goto _again;
	tr161:  sm->cs = 306; goto f3;
	tr355:  sm->cs = 307; goto f64;
	tr413:  sm->cs = 308; goto _again;
	tr166:  sm->cs = 308; goto f7;
	tr356:  sm->cs = 309; goto f64;
	tr186:  sm->cs = 310; goto _again;
	tr357:  sm->cs = 311; goto f78;
	tr251:  sm->cs = 312; goto f40;
	tr358:  sm->cs = 313; goto f64;
	tr256:  sm->cs = 314; goto f42;
	tr261:  sm->cs = 314; goto f43;
	tr428:  sm->cs = 314; goto f104;
	tr429:  sm->cs = 314; goto f105;
	tr431:  sm->cs = 314; goto f106;
	tr430:  sm->cs = 315; goto f64;
	tr262:  sm->cs = 316; goto f44;
	tr270:  sm->cs = 316; goto f45;
	tr433:  sm->cs = 316; goto f107;
	tr434:  sm->cs = 316; goto f108;
	tr436:  sm->cs = 316; goto f109;
	tr435:  sm->cs = 317; goto f64;
	tr271:  sm->cs = 318; goto f46;
	tr280:  sm->cs = 318; goto f47;
	tr284:  sm->cs = 318; goto f48;
	tr288:  sm->cs = 318; goto f49;
	tr289:  sm->cs = 318; goto f50;
	tr297:  sm->cs = 318; goto f51;
	tr298:  sm->cs = 318; goto f52;
	tr300:  sm->cs = 318; goto f53;
	tr303:  sm->cs = 318; goto f54;
	tr304:  sm->cs = 318; goto f55;
	tr438:  sm->cs = 318; goto f110;
	tr439:  sm->cs = 318; goto f111;
	tr441:  sm->cs = 318; goto f112;
	tr440:  sm->cs = 319; goto f64;
	tr305:  sm->cs = 320; goto f56;
	tr307:  sm->cs = 320; goto f58;
	tr444:  sm->cs = 320; goto f113;
	tr445:  sm->cs = 320; goto f114;
	tr450:  sm->cs = 320; goto f116;
	tr451:  sm->cs = 320; goto f117;
	tr306:  sm->cs = 321; goto f57;
	tr446:  sm->cs = 321; goto f115;
	tr447:  sm->cs = 322; goto _again;
	tr448:  sm->cs = 323; goto f17;
	tr452:  sm->cs = 324; goto _again;
	tr308:  sm->cs = 324; goto f3;
	tr309:  sm->cs = 325; goto f3;

f7:
#line 98 "ext/dtext/dtext.rl"
	{
  sm->a1 = sm->p;
}
	goto _again;
f4:
#line 102 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
	goto _again;
f3:
#line 106 "ext/dtext/dtext.rl"
	{
  sm->b1 = sm->p;
}
	goto _again;
f5:
#line 110 "ext/dtext/dtext.rl"
	{
  sm->b2 = sm->p;
}
	goto _again;
f64:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
	goto _again;
f41:
#line 269 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    append(sm, true, "<a rel=\"nofollow\" href=\"/posts?tags=");
    append_segment_uri_escaped(sm, sm->a1, sm->a2 - 1);
    append(sm, true, "\">");
    append_segment_html_escaped(sm, sm->a1, sm->a2 - 1);
    append(sm, true, "</a>");
  }}
	goto _again;
f38:
#line 277 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    GString * segment = g_string_new_len(sm->a1, sm->a2 - sm->a1);
    GString * lowercase_segment = NULL;
    underscore_string(segment->str, segment->len);

    if (g_utf8_validate(segment->str, -1, NULL)) {
      lowercase_segment = g_string_new(g_utf8_strdown(segment->str, -1));
    } else {
      lowercase_segment = g_string_new(g_ascii_strdown(segment->str, -1));
    }

    append(sm, true, "<a href=\"/wiki_pages/show_or_new?title=");
    append_segment_uri_escaped(sm, lowercase_segment->str, lowercase_segment->str + lowercase_segment->len - 1);
    append(sm, true, "\">");
    append_segment_html_escaped(sm, sm->a1, sm->a2 - 1);
    append(sm, true, "</a>");

    g_string_free(lowercase_segment, TRUE);
    g_string_free(segment, TRUE);
  }}
	goto _again;
f39:
#line 298 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    GString * segment = g_string_new_len(sm->a1, sm->a2 - sm->a1);
    GString * lowercase_segment = NULL;
    underscore_string(segment->str, segment->len);

    if (g_utf8_validate(segment->str, -1, NULL)) {
      lowercase_segment = g_string_new(g_utf8_strdown(segment->str, -1));
    } else {
      lowercase_segment = g_string_new(g_ascii_strdown(segment->str, -1));
    }

    append(sm, true, "<a href=\"/wiki_pages/show_or_new?title=");
    append_segment_uri_escaped(sm, lowercase_segment->str, lowercase_segment->str + lowercase_segment->len - 1);
    append(sm, true, "\">");
    append_segment_html_escaped(sm, sm->b1, sm->b2 - 1);
    append(sm, true, "</a>");

    g_string_free(lowercase_segment, TRUE);
    g_string_free(segment, TRUE);
  }}
	goto _again;
f29:
#line 422 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_push(sm, &INLINE_B);
    append(sm, true, "<strong>");
  }}
	goto _again;
f20:
#line 427 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    if (dstack_check(sm, INLINE_B)) {
      dstack_pop(sm);
      append(sm, true, "</strong>");
    } else {
      append(sm, true, "[/b]");
    }
  }}
	goto _again;
f31:
#line 436 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_push(sm, &INLINE_I);
    append(sm, true, "<em>");
  }}
	goto _again;
f22:
#line 441 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    if (dstack_check(sm, INLINE_I)) {
      dstack_pop(sm);
      append(sm, true, "</em>");
    } else {
      append(sm, true, "[/i]");
    }
  }}
	goto _again;
f34:
#line 450 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_push(sm, &INLINE_S);
    append(sm, true, "<s>");
  }}
	goto _again;
f23:
#line 455 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    if (dstack_check(sm, INLINE_S)) {
      dstack_pop(sm);
      append(sm, true, "</s>");
    } else {
      append(sm, true, "[/s]");
    }
  }}
	goto _again;
f37:
#line 464 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_push(sm, &INLINE_U);
    append(sm, true, "<u>");
  }}
	goto _again;
f28:
#line 469 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    if (dstack_check(sm, INLINE_U)) {
      dstack_pop(sm);
      append(sm, true, "</u>");
    } else {
      append(sm, true, "[/u]");
    }
  }}
	goto _again;
f36:
#line 478 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_push(sm, &INLINE_TN);
    append(sm, true, "<span class=\"tn\">");
  }}
	goto _again;
f27:
#line 483 "ext/dtext/dtext.rl"
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
f33:
#line 511 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    g_debug("inline [quote]");
    dstack_close_before_block(sm);
    {( sm->p) = (( sm->ts))-1;}
    { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)];goto _again;}
  }}
	goto _again;
f35:
#line 534 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    g_debug("inline [spoiler]");
    g_debug("  push <span>");
    dstack_push(sm, &INLINE_SPOILER);
    append(sm, true, "<span class=\"spoiler\">");
  }}
	goto _again;
f24:
#line 541 "ext/dtext/dtext.rl"
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
f30:
#line 562 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    g_debug("inline [expand]");
    dstack_rewind(sm);
    {( sm->p) = (((sm->p - 7)))-1;}
    { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)];goto _again;}
  }}
	goto _again;
f21:
#line 569 "ext/dtext/dtext.rl"
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
f32:
#line 581 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_push(sm, &INLINE_NODTEXT);
    {
  size_t len = sm->stack->len;

  if (len > MAX_STACK_DEPTH) {
    free_machine(sm);
    rb_raise(rb_eSyntaxError, "too many nested elements");
  }

  if (sm->top >= len) {
    sm->stack = g_array_set_size(sm->stack, len + 16);
  }
{( ((int *)sm->stack->data))[( sm->top)++] =  sm->cs;  sm->cs = 316; goto _again;}}
  }}
	goto _again;
f26:
#line 586 "ext/dtext/dtext.rl"
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
f25:
#line 596 "ext/dtext/dtext.rl"
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
f76:
#line 606 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    g_debug("inline 0");
    g_debug("  return");

    ( sm->p)--;
    { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)];goto _again;}
  }}
	goto _again;
f75:
#line 642 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    g_debug("inline char: %c", (*( sm->p)));
    append_c_html_escaped(sm, (*( sm->p)));
  }}
	goto _again;
f103:
#line 350 "ext/dtext/dtext.rl"
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
f93:
#line 499 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    dstack_rewind(sm);
    {( sm->p) = (( sm->a1 - 1))-1;}
    { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)];goto _again;}
  }}
	goto _again;
f92:
#line 505 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    dstack_rewind(sm);
    {( sm->p) = (( sm->a1 - 1))-1;}
    { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)];goto _again;}
  }}
	goto _again;
f102:
#line 518 "ext/dtext/dtext.rl"
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
f80:
#line 614 "ext/dtext/dtext.rl"
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
f79:
#line 626 "ext/dtext/dtext.rl"
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
f82:
#line 638 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append_c(sm, ' ');
  }}
	goto _again;
f83:
#line 642 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    g_debug("inline char: %c", (*( sm->p)));
    append_c_html_escaped(sm, (*( sm->p)));
  }}
	goto _again;
f19:
#line 180 "ext/dtext/dtext.rl"
	{{( sm->p) = ((( sm->te)))-1;}{
    append(sm, true, "<a href=\"/forum_topics/");
    append_segment(sm, true, sm->a1, sm->a2 - 1);
    append(sm, true, "\">");
    append(sm, false, "topic #");
    append_segment(sm, false, sm->a1, sm->a2 - 1);
    append(sm, true, "</a>");
  }}
	goto _again;
f18:
#line 247 "ext/dtext/dtext.rl"
	{{( sm->p) = ((( sm->te)))-1;}{
    append(sm, true, "<a href=\"http://www.pixiv.net/member_illust.php?mode=medium&illust_id=");
    append_segment(sm, true, sm->a1, sm->a2 - 1);
    append(sm, true, "\">");
    append(sm, false, "pixiv #");
    append_segment(sm, false, sm->a1, sm->a2 - 1);
    append(sm, true, "</a>");
  }}
	goto _again;
f12:
#line 626 "ext/dtext/dtext.rl"
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
#line 642 "ext/dtext/dtext.rl"
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

    append(sm, true, "<a href=\"");
    append_segment_html_escaped(sm, sm->b1, sm->b2 - sm->d);
    append(sm, true, "\">");
    link_content_sm = parse_helper(sm->a1, sm->a2 - sm->a1, false, true, false);
    append(sm, true, link_content_sm->output->str);
    free_machine(link_content_sm);
    link_content_sm = NULL;
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
f43:
#line 649 "ext/dtext/dtext.rl"
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
#line 658 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    ( sm->p)--;
    { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)];goto _again;}
  }}
	goto _again;
f104:
#line 663 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    append_c_html_escaped(sm, (*( sm->p)));
  }}
	goto _again;
f106:
#line 663 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append_c_html_escaped(sm, (*( sm->p)));
  }}
	goto _again;
f42:
#line 663 "ext/dtext/dtext.rl"
	{{( sm->p) = ((( sm->te)))-1;}{
    append_c_html_escaped(sm, (*( sm->p)));
  }}
	goto _again;
f45:
#line 669 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    if (dstack_check(sm, BLOCK_NODTEXT)) {
      dstack_pop(sm);
      append_block(sm, "</p>");
      { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)];goto _again;}
    } else if (dstack_check(sm, INLINE_NODTEXT)) {
      dstack_pop(sm);
      { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)];goto _again;}
    } else {
      append(sm, true, "[/nodtext]");
    }
  }}
	goto _again;
f108:
#line 682 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    ( sm->p)--;
    { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)];goto _again;}
  }}
	goto _again;
f107:
#line 687 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    append_c_html_escaped(sm, (*( sm->p)));
  }}
	goto _again;
f109:
#line 687 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append_c_html_escaped(sm, (*( sm->p)));
  }}
	goto _again;
f44:
#line 687 "ext/dtext/dtext.rl"
	{{( sm->p) = ((( sm->te)))-1;}{
    append_c_html_escaped(sm, (*( sm->p)));
  }}
	goto _again;
f54:
#line 693 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_push(sm, &BLOCK_THEAD);
    append_block(sm, "<thead>");
  }}
	goto _again;
f49:
#line 698 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    if (dstack_check(sm, BLOCK_THEAD)) {
      dstack_pop(sm);
      append_block(sm, "</thead>");
    } else {
      append(sm, true, "[/thead]");
    }
  }}
	goto _again;
f51:
#line 707 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_push(sm, &BLOCK_TBODY);
    append_block(sm, "<tbody>");
  }}
	goto _again;
f48:
#line 712 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    if (dstack_check(sm, BLOCK_TBODY)) {
      dstack_pop(sm);
      append_block(sm, "</tbody>");
    } else {
      append(sm, true, "[/tbody]");
    }
  }}
	goto _again;
f53:
#line 721 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_push(sm, &BLOCK_TH);
    append_block(sm, "<th>");
    {
  size_t len = sm->stack->len;

  if (len > MAX_STACK_DEPTH) {
    free_machine(sm);
    rb_raise(rb_eSyntaxError, "too many nested elements");
  }

  if (sm->top >= len) {
    sm->stack = g_array_set_size(sm->stack, len + 16);
  }
{( ((int *)sm->stack->data))[( sm->top)++] =  sm->cs;  sm->cs = 277; goto _again;}}
  }}
	goto _again;
f55:
#line 727 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_push(sm, &BLOCK_TR);
    append_block(sm, "<tr>");
  }}
	goto _again;
f50:
#line 732 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    if (dstack_check(sm, BLOCK_TR)) {
      dstack_pop(sm);
      append_block(sm, "</tr>");
    } else {
      append(sm, true, "[/tr]");
    }
  }}
	goto _again;
f52:
#line 741 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_push(sm, &BLOCK_TD);
    append_block(sm, "<td>");
    {
  size_t len = sm->stack->len;

  if (len > MAX_STACK_DEPTH) {
    free_machine(sm);
    rb_raise(rb_eSyntaxError, "too many nested elements");
  }

  if (sm->top >= len) {
    sm->stack = g_array_set_size(sm->stack, len + 16);
  }
{( ((int *)sm->stack->data))[( sm->top)++] =  sm->cs;  sm->cs = 277; goto _again;}}
  }}
	goto _again;
f47:
#line 747 "ext/dtext/dtext.rl"
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
#line 757 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    ( sm->p)--;
    { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)];goto _again;}
  }}
	goto _again;
f110:
#line 762 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;}
	goto _again;
f112:
#line 762 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;}
	goto _again;
f46:
#line 762 "ext/dtext/dtext.rl"
	{{( sm->p) = ((( sm->te)))-1;}}
	goto _again;
f114:
#line 805 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_close_list(sm);
    {( sm->p) = (( sm->ts))-1;}
    { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)];goto _again;}
  }}
	goto _again;
f113:
#line 813 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_rewind(sm);
    ( sm->p)--;
    { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)];goto _again;}
  }}
	goto _again;
f116:
#line 813 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    dstack_rewind(sm);
    ( sm->p)--;
    { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)];goto _again;}
  }}
	goto _again;
f58:
#line 813 "ext/dtext/dtext.rl"
	{{( sm->p) = ((( sm->te)))-1;}{
    dstack_rewind(sm);
    ( sm->p)--;
    { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)];goto _again;}
  }}
	goto _again;
f56:
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
#line 945 "ext/dtext/dtext.rl"
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
#line 992 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_close_before_block(sm);
    dstack_push(sm, &BLOCK_TABLE);
    append_block(sm, "<table class=\"striped\">");
    {
  size_t len = sm->stack->len;

  if (len > MAX_STACK_DEPTH) {
    free_machine(sm);
    rb_raise(rb_eSyntaxError, "too many nested elements");
  }

  if (sm->top >= len) {
    sm->stack = g_array_set_size(sm->stack, len + 16);
  }
{( ((int *)sm->stack->data))[( sm->top)++] =  sm->cs;  sm->cs = 318; goto _again;}}
  }}
	goto _again;
f9:
#line 999 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_push(sm, &BLOCK_TN);
    append_block(sm, "<p class=\"tn\">");
    {
  size_t len = sm->stack->len;

  if (len > MAX_STACK_DEPTH) {
    free_machine(sm);
    rb_raise(rb_eSyntaxError, "too many nested elements");
  }

  if (sm->top >= len) {
    sm->stack = g_array_set_size(sm->stack, len + 16);
  }
{( ((int *)sm->stack->data))[( sm->top)++] =  sm->cs;  sm->cs = 277; goto _again;}}
  }}
	goto _again;
f62:
#line 1015 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    g_debug("block 0");
    g_debug("  close dstack");
    dstack_close(sm);
  }}
	goto _again;
f61:
#line 1038 "ext/dtext/dtext.rl"
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
    free_machine(sm);
    rb_raise(rb_eSyntaxError, "too many nested elements");
  }

  if (sm->top >= len) {
    sm->stack = g_array_set_size(sm->stack, len + 16);
  }
{( ((int *)sm->stack->data))[( sm->top)++] =  sm->cs;  sm->cs = 277; goto _again;}}
  }}
	goto _again;
f67:
#line 821 "ext/dtext/dtext.rl"
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
    free_machine(sm);
    rb_raise(rb_eSyntaxError, "too many nested elements");
  }

  if (sm->top >= len) {
    sm->stack = g_array_set_size(sm->stack, len + 16);
  }
{( ((int *)sm->stack->data))[( sm->top)++] =  sm->cs;  sm->cs = 277; goto _again;}}
  }}
	goto _again;
f68:
#line 882 "ext/dtext/dtext.rl"
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
    free_machine(sm);
    rb_raise(rb_eSyntaxError, "too many nested elements");
  }

  if (sm->top >= len) {
    sm->stack = g_array_set_size(sm->stack, len + 16);
  }
{( ((int *)sm->stack->data))[( sm->top)++] =  sm->cs;  sm->cs = 277; goto _again;}}
  }}
	goto _again;
f73:
#line 927 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    g_debug("block [quote]");
    g_debug("  push quote");
    g_debug("  print <blockquote>");
    dstack_close_before_block(sm);
    dstack_push(sm, &BLOCK_QUOTE);
    append_block(sm, "<blockquote>");
  }}
	goto _again;
f74:
#line 936 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    g_debug("block [spoiler]");
    g_debug("  push spoiler");
    g_debug("  print <div>");
    dstack_close_before_block(sm);
    dstack_push(sm, &BLOCK_SPOILER);
    append_block(sm, "<div class=\"spoiler\">");
  }}
	goto _again;
f69:
#line 954 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    g_debug("block [code]");
    dstack_close_before_block(sm);
    dstack_push(sm, &BLOCK_CODE);
    append_block(sm, "<pre>");
    {
  size_t len = sm->stack->len;

  if (len > MAX_STACK_DEPTH) {
    free_machine(sm);
    rb_raise(rb_eSyntaxError, "too many nested elements");
  }

  if (sm->top >= len) {
    sm->stack = g_array_set_size(sm->stack, len + 16);
  }
{( ((int *)sm->stack->data))[( sm->top)++] =  sm->cs;  sm->cs = 314; goto _again;}}
  }}
	goto _again;
f71:
#line 962 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    g_debug("block [expand]");
    dstack_close_before_block(sm);
    dstack_push(sm, &BLOCK_EXPAND);
    append_block(sm, "<div class=\"expandable\"><div class=\"expandable-header\">");
    append_block(sm, "<input type=\"button\" value=\"Show\" class=\"expandable-button\"/></div>");
    append_block(sm, "<div class=\"expandable-content\">");
  }}
	goto _again;
f70:
#line 971 "ext/dtext/dtext.rl"
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
f72:
#line 983 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    g_debug("block [nodtext]");
    dstack_close_before_block(sm);
    dstack_push(sm, &BLOCK_NODTEXT);
    dstack_push(sm, &BLOCK_P);
    append_block(sm, "<p>");
    {
  size_t len = sm->stack->len;

  if (len > MAX_STACK_DEPTH) {
    free_machine(sm);
    rb_raise(rb_eSyntaxError, "too many nested elements");
  }

  if (sm->top >= len) {
    sm->stack = g_array_set_size(sm->stack, len + 16);
  }
{( ((int *)sm->stack->data))[( sm->top)++] =  sm->cs;  sm->cs = 316; goto _again;}}
  }}
	goto _again;
f65:
#line 1038 "ext/dtext/dtext.rl"
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
    free_machine(sm);
    rb_raise(rb_eSyntaxError, "too many nested elements");
  }

  if (sm->top >= len) {
    sm->stack = g_array_set_size(sm->stack, len + 16);
  }
{( ((int *)sm->stack->data))[( sm->top)++] =  sm->cs;  sm->cs = 277; goto _again;}}
  }}
	goto _again;
f2:
#line 1038 "ext/dtext/dtext.rl"
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
    free_machine(sm);
    rb_raise(rb_eSyntaxError, "too many nested elements");
  }

  if (sm->top >= len) {
    sm->stack = g_array_set_size(sm->stack, len + 16);
  }
{( ((int *)sm->stack->data))[( sm->top)++] =  sm->cs;  sm->cs = 277; goto _again;}}
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
#line 102 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
#line 162 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append(sm, true, "<a href=\"/posts/");
    append_segment(sm, true, sm->a1, sm->a2 - 1);
    append(sm, true, "\">");
    append(sm, false, "post #");
    append_segment(sm, false, sm->a1, sm->a2 - 1);
    append(sm, true, "</a>");
  }}
	goto _again;
f91:
#line 102 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
#line 171 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append(sm, true, "<a href=\"/forum_posts/");
    append_segment(sm, true, sm->a1, sm->a2 - 1);
    append(sm, true, "\">");
    append(sm, false, "forum #");
    append_segment(sm, false, sm->a1, sm->a2 - 1);
    append(sm, true, "</a>");
  }}
	goto _again;
f99:
#line 102 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
#line 180 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append(sm, true, "<a href=\"/forum_topics/");
    append_segment(sm, true, sm->a1, sm->a2 - 1);
    append(sm, true, "\">");
    append(sm, false, "topic #");
    append_segment(sm, false, sm->a1, sm->a2 - 1);
    append(sm, true, "</a>");
  }}
	goto _again;
f90:
#line 102 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
#line 202 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append(sm, true, "<a href=\"/comments/");
    append_segment(sm, true, sm->a1, sm->a2 - 1);
    append(sm, true, "\">");
    append(sm, false, "comment #");
    append_segment(sm, false, sm->a1, sm->a2 - 1);
    append(sm, true, "</a>");
  }}
	goto _again;
f97:
#line 102 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
#line 211 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append(sm, true, "<a href=\"/pools/");
    append_segment(sm, true, sm->a1, sm->a2 - 1);
    append(sm, true, "\">");
    append(sm, false, "pool #");
    append_segment(sm, false, sm->a1, sm->a2 - 1);
    append(sm, true, "</a>");
  }}
	goto _again;
f101:
#line 102 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
#line 220 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append(sm, true, "<a href=\"/users/");
    append_segment(sm, true, sm->a1, sm->a2 - 1);
    append(sm, true, "\">");
    append(sm, false, "user #");
    append_segment(sm, false, sm->a1, sm->a2 - 1);
    append(sm, true, "</a>");
  }}
	goto _again;
f89:
#line 102 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
#line 229 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append(sm, true, "<a href=\"/artists/");
    append_segment(sm, true, sm->a1, sm->a2 - 1);
    append(sm, true, "\">");
    append(sm, false, "artist #");
    append_segment(sm, false, sm->a1, sm->a2 - 1);
    append(sm, true, "</a>");
  }}
	goto _again;
f94:
#line 102 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
#line 238 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append(sm, true, "<a href=\"https://github.com/r888888888/danbooru/issues/");
    append_segment(sm, true, sm->a1, sm->a2 - 1);
    append(sm, true, "\">");
    append(sm, false, "issue #");
    append_segment(sm, false, sm->a1, sm->a2 - 1);
    append(sm, true, "</a>");
  }}
	goto _again;
f95:
#line 102 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
#line 247 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append(sm, true, "<a href=\"http://www.pixiv.net/member_illust.php?mode=medium&illust_id=");
    append_segment(sm, true, sm->a1, sm->a2 - 1);
    append(sm, true, "\">");
    append(sm, false, "pixiv #");
    append_segment(sm, false, sm->a1, sm->a2 - 1);
    append(sm, true, "</a>");
  }}
	goto _again;
f87:
#line 102 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
#line 375 "ext/dtext/dtext.rl"
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
f86:
#line 102 "ext/dtext/dtext.rl"
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

    append(sm, true, "<a href=\"");
    append_segment_html_escaped(sm, sm->b1, sm->b2 - sm->d);
    append(sm, true, "\">");
    link_content_sm = parse_helper(sm->a1, sm->a2 - sm->a1, false, true, false);
    append(sm, true, link_content_sm->output->str);
    free_machine(link_content_sm);
    link_content_sm = NULL;
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
#line 110 "ext/dtext/dtext.rl"
	{
  sm->b2 = sm->p;
}
#line 342 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    append(sm, true, "<a href=\"");
    append_segment_html_escaped(sm, sm->b1, sm->b2 - 1);
    append(sm, true, "\">");
    append_segment_html_escaped(sm, sm->a1, sm->a2 - 1);
    append(sm, true, "</a>");
  }}
	goto _again;
f100:
#line 110 "ext/dtext/dtext.rl"
	{
  sm->b2 = sm->p;
}
#line 189 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append(sm, true, "<a href=\"/forum_topics/");
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
#line 110 "ext/dtext/dtext.rl"
	{
  sm->b2 = sm->p;
}
#line 256 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append(sm, true, "<a href=\"http://www.pixiv.net/member_illust.php?mode=manga_big&illust_id=");
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
f84:
#line 110 "ext/dtext/dtext.rl"
	{
  sm->b2 = sm->p;
}
#line 319 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    if (is_boundary_c((*( sm->p)))) {
      sm->d = 2;
      sm->b = true;
    } else {
      sm->d = 1;
      sm->b = false;
    }

    append(sm, true, "<a href=\"");
    append_segment_html_escaped(sm, sm->b1, sm->b2 - sm->d);
    append(sm, true, "\">");
    link_content_sm = parse_helper(sm->a1, sm->a2 - sm->a1, false, true, false);
    append(sm, true, link_content_sm->output->str);
    free_machine(link_content_sm);
    link_content_sm = NULL;
    append(sm, true, "</a>");

    if (sm->b) {
      append_c_html_escaped(sm, (*( sm->p)));
    }
  }}
	goto _again;
f81:
#line 110 "ext/dtext/dtext.rl"
	{
  sm->b2 = sm->p;
}
#line 403 "ext/dtext/dtext.rl"
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
     sm->cs = 320;
  }}
	goto _again;
f117:
#line 110 "ext/dtext/dtext.rl"
	{
  sm->b2 = sm->p;
}
#line 766 "ext/dtext/dtext.rl"
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
    free_machine(sm);
    rb_raise(rb_eSyntaxError, "too many nested elements");
  }

  if (sm->top >= len) {
    sm->stack = g_array_set_size(sm->stack, len + 16);
  }
{( ((int *)sm->stack->data))[( sm->top)++] =  sm->cs;  sm->cs = 277; goto _again;}}
  }}
	goto _again;
f66:
#line 110 "ext/dtext/dtext.rl"
	{
  sm->b2 = sm->p;
}
#line 1005 "ext/dtext/dtext.rl"
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
    free_machine(sm);
    rb_raise(rb_eSyntaxError, "too many nested elements");
  }

  if (sm->top >= len) {
    sm->stack = g_array_set_size(sm->stack, len + 16);
  }
{( ((int *)sm->stack->data))[( sm->top)++] =  sm->cs;  sm->cs = 320; goto _again;}}
  }}
	goto _again;
f17:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 98 "ext/dtext/dtext.rl"
	{
  sm->a1 = sm->p;
}
	goto _again;
f14:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 319 "ext/dtext/dtext.rl"
	{( sm->act) = 15;}
	goto _again;
f40:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 350 "ext/dtext/dtext.rl"
	{( sm->act) = 17;}
	goto _again;
f88:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 371 "ext/dtext/dtext.rl"
	{( sm->act) = 18;}
	goto _again;
f16:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 375 "ext/dtext/dtext.rl"
	{( sm->act) = 19;}
	goto _again;
f11:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 614 "ext/dtext/dtext.rl"
	{( sm->act) = 43;}
	goto _again;
f77:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 626 "ext/dtext/dtext.rl"
	{( sm->act) = 44;}
	goto _again;
f78:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 642 "ext/dtext/dtext.rl"
	{( sm->act) = 46;}
	goto _again;
f57:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 805 "ext/dtext/dtext.rl"
	{( sm->act) = 65;}
	goto _again;
f115:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 811 "ext/dtext/dtext.rl"
	{( sm->act) = 66;}
	goto _again;
f1:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 1021 "ext/dtext/dtext.rl"
	{( sm->act) = 81;}
	goto _again;
f63:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 1034 "ext/dtext/dtext.rl"
	{( sm->act) = 82;}
	goto _again;
f85:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 98 "ext/dtext/dtext.rl"
	{
  sm->a1 = sm->p;
}
#line 375 "ext/dtext/dtext.rl"
	{( sm->act) = 19;}
	goto _again;

_again:
	switch ( _dtext_to_state_actions[ sm->cs] ) {
	case 60:
#line 1 "NONE"
	{( sm->ts) = 0;}
	break;
#line 4655 "ext/dtext/dtext.c"
	}

	if ( ++( sm->p) != ( sm->pe) )
		goto _resume;
	_test_eof: {}
	if ( ( sm->p) == ( sm->eof) )
	{
	switch (  sm->cs ) {
	case 262: goto tr0;
	case 0: goto tr0;
	case 263: goto tr320;
	case 264: goto tr320;
	case 1: goto tr2;
	case 265: goto tr321;
	case 266: goto tr321;
	case 2: goto tr2;
	case 267: goto tr320;
	case 3: goto tr2;
	case 4: goto tr2;
	case 5: goto tr2;
	case 268: goto tr324;
	case 269: goto tr326;
	case 270: goto tr320;
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
	case 271: goto tr335;
	case 18: goto tr2;
	case 19: goto tr2;
	case 20: goto tr2;
	case 21: goto tr2;
	case 22: goto tr2;
	case 23: goto tr2;
	case 24: goto tr2;
	case 25: goto tr2;
	case 272: goto tr336;
	case 273: goto tr338;
	case 26: goto tr2;
	case 27: goto tr2;
	case 28: goto tr2;
	case 29: goto tr2;
	case 30: goto tr2;
	case 31: goto tr2;
	case 32: goto tr2;
	case 274: goto tr339;
	case 33: goto tr2;
	case 34: goto tr2;
	case 35: goto tr2;
	case 36: goto tr2;
	case 37: goto tr2;
	case 275: goto tr340;
	case 38: goto tr2;
	case 39: goto tr2;
	case 40: goto tr2;
	case 41: goto tr2;
	case 42: goto tr2;
	case 43: goto tr2;
	case 44: goto tr2;
	case 276: goto tr341;
	case 45: goto tr2;
	case 46: goto tr2;
	case 47: goto tr2;
	case 48: goto tr2;
	case 49: goto tr2;
	case 50: goto tr2;
	case 278: goto tr359;
	case 279: goto tr362;
	case 51: goto tr60;
	case 52: goto tr62;
	case 53: goto tr62;
	case 280: goto tr363;
	case 281: goto tr363;
	case 282: goto tr365;
	case 283: goto tr366;
	case 54: goto tr67;
	case 55: goto tr67;
	case 56: goto tr67;
	case 57: goto tr67;
	case 58: goto tr60;
	case 284: goto tr368;
	case 59: goto tr60;
	case 60: goto tr60;
	case 61: goto tr67;
	case 62: goto tr67;
	case 63: goto tr67;
	case 64: goto tr67;
	case 65: goto tr67;
	case 66: goto tr67;
	case 67: goto tr67;
	case 68: goto tr67;
	case 69: goto tr67;
	case 70: goto tr67;
	case 71: goto tr67;
	case 72: goto tr67;
	case 73: goto tr67;
	case 74: goto tr67;
	case 75: goto tr67;
	case 76: goto tr67;
	case 77: goto tr67;
	case 78: goto tr67;
	case 79: goto tr67;
	case 80: goto tr67;
	case 285: goto tr366;
	case 81: goto tr60;
	case 286: goto tr373;
	case 82: goto tr60;
	case 83: goto tr60;
	case 287: goto tr375;
	case 288: goto tr366;
	case 84: goto tr67;
	case 85: goto tr67;
	case 86: goto tr67;
	case 87: goto tr67;
	case 88: goto tr67;
	case 89: goto tr67;
	case 90: goto tr67;
	case 289: goto tr378;
	case 290: goto tr366;
	case 91: goto tr67;
	case 92: goto tr67;
	case 93: goto tr67;
	case 94: goto tr67;
	case 95: goto tr67;
	case 96: goto tr67;
	case 97: goto tr67;
	case 98: goto tr67;
	case 291: goto tr381;
	case 292: goto tr366;
	case 99: goto tr67;
	case 100: goto tr67;
	case 101: goto tr67;
	case 102: goto tr67;
	case 103: goto tr67;
	case 104: goto tr67;
	case 293: goto tr384;
	case 294: goto tr366;
	case 105: goto tr67;
	case 106: goto tr67;
	case 107: goto tr67;
	case 295: goto tr387;
	case 296: goto tr389;
	case 297: goto tr366;
	case 108: goto tr67;
	case 109: goto tr67;
	case 110: goto tr67;
	case 111: goto tr67;
	case 112: goto tr67;
	case 113: goto tr67;
	case 298: goto tr392;
	case 299: goto tr366;
	case 114: goto tr67;
	case 115: goto tr67;
	case 116: goto tr67;
	case 117: goto tr67;
	case 118: goto tr67;
	case 119: goto tr67;
	case 300: goto tr396;
	case 120: goto tr140;
	case 121: goto tr140;
	case 301: goto tr399;
	case 122: goto tr67;
	case 123: goto tr67;
	case 124: goto tr67;
	case 125: goto tr67;
	case 126: goto tr67;
	case 302: goto tr401;
	case 127: goto tr67;
	case 128: goto tr67;
	case 129: goto tr67;
	case 130: goto tr67;
	case 303: goto tr403;
	case 304: goto tr366;
	case 131: goto tr67;
	case 132: goto tr67;
	case 133: goto tr67;
	case 134: goto tr67;
	case 135: goto tr67;
	case 136: goto tr67;
	case 305: goto tr406;
	case 137: goto tr159;
	case 138: goto tr159;
	case 306: goto tr409;
	case 307: goto tr366;
	case 139: goto tr67;
	case 140: goto tr67;
	case 141: goto tr67;
	case 142: goto tr67;
	case 143: goto tr67;
	case 308: goto tr412;
	case 309: goto tr366;
	case 144: goto tr67;
	case 145: goto tr67;
	case 146: goto tr67;
	case 147: goto tr67;
	case 148: goto tr67;
	case 149: goto tr67;
	case 150: goto tr67;
	case 151: goto tr67;
	case 152: goto tr67;
	case 153: goto tr67;
	case 154: goto tr67;
	case 155: goto tr67;
	case 156: goto tr67;
	case 157: goto tr67;
	case 310: goto tr424;
	case 158: goto tr67;
	case 159: goto tr67;
	case 160: goto tr67;
	case 161: goto tr67;
	case 162: goto tr67;
	case 163: goto tr67;
	case 164: goto tr67;
	case 165: goto tr67;
	case 166: goto tr67;
	case 167: goto tr67;
	case 168: goto tr67;
	case 169: goto tr67;
	case 170: goto tr67;
	case 171: goto tr67;
	case 172: goto tr67;
	case 173: goto tr67;
	case 174: goto tr67;
	case 175: goto tr67;
	case 176: goto tr67;
	case 177: goto tr67;
	case 178: goto tr67;
	case 179: goto tr67;
	case 180: goto tr67;
	case 181: goto tr67;
	case 182: goto tr67;
	case 183: goto tr67;
	case 184: goto tr67;
	case 185: goto tr67;
	case 186: goto tr67;
	case 187: goto tr67;
	case 188: goto tr67;
	case 189: goto tr67;
	case 190: goto tr67;
	case 191: goto tr67;
	case 192: goto tr67;
	case 193: goto tr67;
	case 194: goto tr67;
	case 195: goto tr67;
	case 196: goto tr67;
	case 197: goto tr67;
	case 198: goto tr67;
	case 199: goto tr67;
	case 200: goto tr67;
	case 201: goto tr67;
	case 202: goto tr67;
	case 203: goto tr67;
	case 204: goto tr67;
	case 205: goto tr67;
	case 311: goto tr366;
	case 206: goto tr67;
	case 207: goto tr67;
	case 208: goto tr67;
	case 209: goto tr67;
	case 210: goto tr67;
	case 211: goto tr67;
	case 212: goto tr60;
	case 312: goto tr426;
	case 213: goto tr60;
	case 214: goto tr60;
	case 215: goto tr67;
	case 313: goto tr366;
	case 216: goto tr67;
	case 217: goto tr67;
	case 218: goto tr67;
	case 315: goto tr431;
	case 219: goto tr256;
	case 220: goto tr256;
	case 221: goto tr256;
	case 222: goto tr256;
	case 223: goto tr256;
	case 317: goto tr436;
	case 224: goto tr262;
	case 225: goto tr262;
	case 226: goto tr262;
	case 227: goto tr262;
	case 228: goto tr262;
	case 229: goto tr262;
	case 230: goto tr262;
	case 231: goto tr262;
	case 319: goto tr441;
	case 232: goto tr271;
	case 233: goto tr271;
	case 234: goto tr271;
	case 235: goto tr271;
	case 236: goto tr271;
	case 237: goto tr271;
	case 238: goto tr271;
	case 239: goto tr271;
	case 240: goto tr271;
	case 241: goto tr271;
	case 242: goto tr271;
	case 243: goto tr271;
	case 244: goto tr271;
	case 245: goto tr271;
	case 246: goto tr271;
	case 247: goto tr271;
	case 248: goto tr271;
	case 249: goto tr271;
	case 250: goto tr271;
	case 251: goto tr271;
	case 252: goto tr271;
	case 253: goto tr271;
	case 254: goto tr271;
	case 255: goto tr271;
	case 256: goto tr271;
	case 257: goto tr271;
	case 321: goto tr305;
	case 258: goto tr305;
	case 322: goto tr450;
	case 323: goto tr450;
	case 259: goto tr307;
	case 324: goto tr451;
	case 325: goto tr451;
	case 260: goto tr307;
	}
	}

	}

#line 1386 "ext/dtext/dtext.rl"

  dstack_close(sm);

  return sm;
}

static VALUE parse(int argc, VALUE * argv, VALUE self) {
  VALUE input;
  VALUE input0;
  VALUE options;
  VALUE opt_inline;
  VALUE opt_strip;
  VALUE opt_mentions;
  VALUE ret;
  rb_encoding * encoding = NULL;
  StateMachine * sm = NULL;
  bool f_strip = false;
  bool f_inline = false;
  bool f_mentions = true;

  g_debug("start\n");

  if (argc == 0) {
    rb_raise(rb_eArgError, "wrong number of arguments (0 for 1)");
  }

  input = argv[0];

  if (NIL_P(input)) {
    return Qnil;
  }

  input0 = rb_str_dup(input);
  input0 = rb_str_cat(input0, "\0", 1);
  
  if (argc > 1) {
    options = argv[1];

    if (!NIL_P(options)) {
      opt_strip  = rb_hash_aref(options, ID2SYM(rb_intern("strip")));
      if (RTEST(opt_strip)) {
        f_strip = true;
      }

      opt_inline = rb_hash_aref(options, ID2SYM(rb_intern("inline")));
      if (RTEST(opt_inline)) {
        f_inline = true;
      }

      opt_mentions = rb_hash_aref(options, ID2SYM(rb_intern("disable_mentions")));
      if (RTEST(opt_mentions)) {
        f_mentions = false;
      }
    }
  }

  sm = parse_helper(RSTRING_PTR(input0), RSTRING_LEN(input0), f_strip, f_inline, f_mentions);

  encoding = rb_enc_find("utf-8");
  ret = rb_enc_str_new(sm->output->str, sm->output->len, encoding);

  free_machine(sm);

  return ret;
}

void Init_dtext() {
  VALUE mDTextRagel = rb_define_module("DTextRagel");
  rb_define_singleton_method(mDTextRagel, "parse", parse, -1);
}
