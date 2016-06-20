
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
  bool list_mode;
  bool header_mode;
  GString * output;
  GArray * stack;
  GQueue * dstack;
  int list_nest;
  int d;
  int b;
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


#line 976 "ext/dtext/dtext.rl"



#line 78 "ext/dtext/dtext.c"
static const unsigned char _dtext_to_state_actions[] = {
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	57, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 57, 
	0, 57, 57, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 57, 0, 57, 
	0, 57, 0, 57, 0, 0, 0, 0, 
	0
};

static const unsigned char _dtext_from_state_actions[] = {
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	58, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 58, 
	0, 58, 58, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 58, 0, 58, 
	0, 58, 0, 58, 0, 0, 0, 0, 
	0
};

static const int dtext_start = 256;
static const int dtext_first_final = 256;
static const int dtext_error = 0;

static const int dtext_en_textile_link_desc = 271;
static const int dtext_en_textile_link = 273;
static const int dtext_en_inline = 274;
static const int dtext_en_code = 309;
static const int dtext_en_nodtext = 311;
static const int dtext_en_table = 313;
static const int dtext_en_list = 315;
static const int dtext_en_main = 256;


#line 979 "ext/dtext/dtext.rl"

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
    sm->output = g_string_append_c(sm->output, ' ');
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

static void init_machine(StateMachine * sm, VALUE input) {
  size_t output_length = 0;
  sm->p = RSTRING_PTR(input);
  sm->pb = sm->p;
  sm->pe = sm->p + RSTRING_LEN(input);
  sm->eof = sm->pe;
  sm->ts = NULL;
  sm->te = NULL;
  sm->cs = 0;
  sm->act = 0;
  sm->top = 0;
  output_length = RSTRING_LEN(input);
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
  sm->stack = g_array_sized_new(FALSE, TRUE, sizeof(int), 16);
  sm->dstack = g_queue_new();
  sm->list_nest = 0;
  sm->list_mode = false;
  sm->header_mode = false;
  sm->d = 0;
  sm->b = 0;
}

static void free_machine(StateMachine * sm) {
  g_string_free(sm->output, TRUE);
  g_array_free(sm->stack, FALSE);
  g_queue_free(sm->dstack);
  g_free(sm);
}

static VALUE parse(int argc, VALUE * argv, VALUE self) {
  VALUE input;
  VALUE options;
  VALUE opt_inline;
  VALUE opt_strip;
  VALUE ret;
  rb_encoding * encoding = NULL;
  StateMachine * sm = NULL;

  g_debug("start\n");

  if (argc == 0) {
    rb_raise(rb_eArgError, "wrong number of arguments (0 for 1)");
  }

  input = argv[0];
  
  sm = (StateMachine *)g_malloc0(sizeof(StateMachine));
  input = rb_str_cat(input, "\0", 1);
  init_machine(sm, input);

  if (argc > 1) {
    options = argv[1];

    if (!NIL_P(options)) {
      opt_strip  = rb_hash_aref(options, ID2SYM(rb_intern("strip")));
      if (RTEST(opt_strip)) {
        sm->f_strip = true;
      }

      opt_inline = rb_hash_aref(options, ID2SYM(rb_intern("inline")));
      if (RTEST(opt_inline)) {
        sm->f_inline = true;
      }
    }
  }

  
#line 536 "ext/dtext/dtext.c"
	{
	 sm->cs = dtext_start;
	( sm->top) = 0;
	( sm->ts) = 0;
	( sm->te) = 0;
	( sm->act) = 0;
	}

#line 1333 "ext/dtext/dtext.rl"
  
#line 547 "ext/dtext/dtext.c"
	{
	if ( ( sm->p) == ( sm->pe) )
		goto _test_eof;
	if (  sm->cs == 0 )
		goto _out;
_resume:
	switch ( _dtext_from_state_actions[ sm->cs] ) {
	case 58:
#line 1 "NONE"
	{( sm->ts) = ( sm->p);}
	break;
#line 559 "ext/dtext/dtext.c"
	}

	switch (  sm->cs ) {
case 256:
	switch( (*( sm->p)) ) {
		case 0: goto tr304;
		case 10: goto tr305;
		case 13: goto tr306;
		case 42: goto tr307;
		case 91: goto tr308;
		case 104: goto tr309;
	}
	goto tr303;
case 257:
	switch( (*( sm->p)) ) {
		case 10: goto tr1;
		case 13: goto tr310;
	}
	goto tr0;
case 1:
	if ( (*( sm->p)) == 10 )
		goto tr1;
	goto tr0;
case 258:
	if ( (*( sm->p)) == 10 )
		goto tr305;
	goto tr311;
case 259:
	switch( (*( sm->p)) ) {
		case 9: goto tr5;
		case 32: goto tr5;
		case 42: goto tr6;
	}
	goto tr311;
case 2:
	switch( (*( sm->p)) ) {
		case 0: goto tr2;
		case 9: goto tr4;
		case 10: goto tr2;
		case 13: goto tr2;
		case 32: goto tr4;
	}
	goto tr3;
case 260:
	switch( (*( sm->p)) ) {
		case 0: goto tr312;
		case 10: goto tr312;
		case 13: goto tr312;
	}
	goto tr313;
case 261:
	switch( (*( sm->p)) ) {
		case 0: goto tr312;
		case 9: goto tr4;
		case 10: goto tr312;
		case 13: goto tr312;
		case 32: goto tr4;
	}
	goto tr3;
case 3:
	switch( (*( sm->p)) ) {
		case 9: goto tr5;
		case 32: goto tr5;
		case 42: goto tr6;
	}
	goto tr2;
case 262:
	switch( (*( sm->p)) ) {
		case 47: goto tr314;
		case 99: goto tr315;
		case 101: goto tr316;
		case 110: goto tr317;
		case 113: goto tr318;
		case 115: goto tr319;
		case 116: goto tr320;
	}
	goto tr311;
case 4:
	if ( (*( sm->p)) == 115 )
		goto tr7;
	goto tr2;
case 5:
	if ( (*( sm->p)) == 112 )
		goto tr8;
	goto tr2;
case 6:
	if ( (*( sm->p)) == 111 )
		goto tr9;
	goto tr2;
case 7:
	if ( (*( sm->p)) == 105 )
		goto tr10;
	goto tr2;
case 8:
	if ( (*( sm->p)) == 108 )
		goto tr11;
	goto tr2;
case 9:
	if ( (*( sm->p)) == 101 )
		goto tr12;
	goto tr2;
case 10:
	if ( (*( sm->p)) == 114 )
		goto tr13;
	goto tr2;
case 11:
	if ( (*( sm->p)) == 93 )
		goto tr14;
	goto tr2;
case 12:
	if ( (*( sm->p)) == 111 )
		goto tr15;
	goto tr2;
case 13:
	if ( (*( sm->p)) == 100 )
		goto tr16;
	goto tr2;
case 14:
	if ( (*( sm->p)) == 101 )
		goto tr17;
	goto tr2;
case 15:
	if ( (*( sm->p)) == 93 )
		goto tr18;
	goto tr2;
case 263:
	if ( (*( sm->p)) == 32 )
		goto tr18;
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr18;
	goto tr321;
case 16:
	if ( (*( sm->p)) == 120 )
		goto tr19;
	goto tr2;
case 17:
	if ( (*( sm->p)) == 112 )
		goto tr20;
	goto tr2;
case 18:
	if ( (*( sm->p)) == 97 )
		goto tr21;
	goto tr2;
case 19:
	if ( (*( sm->p)) == 110 )
		goto tr22;
	goto tr2;
case 20:
	if ( (*( sm->p)) == 100 )
		goto tr23;
	goto tr2;
case 21:
	switch( (*( sm->p)) ) {
		case 61: goto tr24;
		case 93: goto tr25;
	}
	goto tr2;
case 22:
	if ( (*( sm->p)) == 93 )
		goto tr2;
	goto tr26;
case 23:
	if ( (*( sm->p)) == 93 )
		goto tr28;
	goto tr27;
case 264:
	if ( (*( sm->p)) == 32 )
		goto tr323;
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr323;
	goto tr322;
case 265:
	if ( (*( sm->p)) == 32 )
		goto tr25;
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr25;
	goto tr324;
case 24:
	if ( (*( sm->p)) == 111 )
		goto tr29;
	goto tr2;
case 25:
	if ( (*( sm->p)) == 100 )
		goto tr30;
	goto tr2;
case 26:
	if ( (*( sm->p)) == 116 )
		goto tr31;
	goto tr2;
case 27:
	if ( (*( sm->p)) == 101 )
		goto tr32;
	goto tr2;
case 28:
	if ( (*( sm->p)) == 120 )
		goto tr33;
	goto tr2;
case 29:
	if ( (*( sm->p)) == 116 )
		goto tr34;
	goto tr2;
case 30:
	if ( (*( sm->p)) == 93 )
		goto tr35;
	goto tr2;
case 266:
	if ( (*( sm->p)) == 32 )
		goto tr35;
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr35;
	goto tr325;
case 31:
	if ( (*( sm->p)) == 117 )
		goto tr36;
	goto tr2;
case 32:
	if ( (*( sm->p)) == 111 )
		goto tr37;
	goto tr2;
case 33:
	if ( (*( sm->p)) == 116 )
		goto tr38;
	goto tr2;
case 34:
	if ( (*( sm->p)) == 101 )
		goto tr39;
	goto tr2;
case 35:
	if ( (*( sm->p)) == 93 )
		goto tr40;
	goto tr2;
case 267:
	if ( (*( sm->p)) == 32 )
		goto tr40;
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr40;
	goto tr326;
case 36:
	if ( (*( sm->p)) == 112 )
		goto tr41;
	goto tr2;
case 37:
	if ( (*( sm->p)) == 111 )
		goto tr42;
	goto tr2;
case 38:
	if ( (*( sm->p)) == 105 )
		goto tr43;
	goto tr2;
case 39:
	if ( (*( sm->p)) == 108 )
		goto tr44;
	goto tr2;
case 40:
	if ( (*( sm->p)) == 101 )
		goto tr45;
	goto tr2;
case 41:
	if ( (*( sm->p)) == 114 )
		goto tr46;
	goto tr2;
case 42:
	if ( (*( sm->p)) == 93 )
		goto tr47;
	goto tr2;
case 268:
	if ( (*( sm->p)) == 32 )
		goto tr47;
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr47;
	goto tr327;
case 43:
	switch( (*( sm->p)) ) {
		case 97: goto tr48;
		case 110: goto tr49;
	}
	goto tr2;
case 44:
	if ( (*( sm->p)) == 98 )
		goto tr50;
	goto tr2;
case 45:
	if ( (*( sm->p)) == 108 )
		goto tr51;
	goto tr2;
case 46:
	if ( (*( sm->p)) == 101 )
		goto tr52;
	goto tr2;
case 47:
	if ( (*( sm->p)) == 93 )
		goto tr53;
	goto tr2;
case 48:
	if ( (*( sm->p)) == 93 )
		goto tr54;
	goto tr2;
case 269:
	if ( 49 <= (*( sm->p)) && (*( sm->p)) <= 54 )
		goto tr328;
	goto tr311;
case 49:
	if ( (*( sm->p)) == 46 )
		goto tr55;
	goto tr2;
case 270:
	switch( (*( sm->p)) ) {
		case 9: goto tr330;
		case 32: goto tr330;
	}
	goto tr329;
case 271:
	if ( (*( sm->p)) == 34 )
		goto tr331;
	goto tr57;
case 0:
	goto _out;
case 50:
	if ( (*( sm->p)) == 58 )
		goto tr56;
	goto tr57;
case 51:
	switch( (*( sm->p)) ) {
		case 47: goto tr58;
		case 104: goto tr59;
	}
	goto tr57;
case 52:
	if ( 33 <= (*( sm->p)) && (*( sm->p)) <= 126 )
		goto tr60;
	goto tr57;
case 272:
	if ( 33 <= (*( sm->p)) && (*( sm->p)) <= 126 )
		goto tr60;
	goto tr332;
case 53:
	if ( (*( sm->p)) == 116 )
		goto tr61;
	goto tr57;
case 54:
	if ( (*( sm->p)) == 116 )
		goto tr62;
	goto tr57;
case 55:
	if ( (*( sm->p)) == 112 )
		goto tr63;
	goto tr57;
case 56:
	switch( (*( sm->p)) ) {
		case 58: goto tr64;
		case 115: goto tr65;
	}
	goto tr57;
case 57:
	if ( (*( sm->p)) == 47 )
		goto tr66;
	goto tr57;
case 58:
	if ( (*( sm->p)) == 47 )
		goto tr58;
	goto tr57;
case 59:
	if ( (*( sm->p)) == 58 )
		goto tr64;
	goto tr57;
case 273:
	if ( (*( sm->p)) == 34 )
		goto tr334;
	goto tr333;
case 274:
	switch( (*( sm->p)) ) {
		case 0: goto tr336;
		case 10: goto tr337;
		case 13: goto tr338;
		case 34: goto tr339;
		case 64: goto tr340;
		case 65: goto tr341;
		case 67: goto tr342;
		case 70: goto tr343;
		case 73: goto tr344;
		case 80: goto tr345;
		case 84: goto tr346;
		case 85: goto tr347;
		case 91: goto tr348;
		case 97: goto tr341;
		case 99: goto tr342;
		case 102: goto tr343;
		case 104: goto tr349;
		case 105: goto tr344;
		case 112: goto tr345;
		case 116: goto tr346;
		case 117: goto tr347;
		case 123: goto tr350;
	}
	goto tr335;
case 275:
	switch( (*( sm->p)) ) {
		case 10: goto tr68;
		case 13: goto tr352;
		case 42: goto tr353;
	}
	goto tr351;
case 276:
	switch( (*( sm->p)) ) {
		case 10: goto tr68;
		case 13: goto tr352;
	}
	goto tr354;
case 60:
	if ( (*( sm->p)) == 10 )
		goto tr68;
	goto tr67;
case 61:
	switch( (*( sm->p)) ) {
		case 9: goto tr70;
		case 32: goto tr70;
		case 42: goto tr71;
	}
	goto tr69;
case 62:
	switch( (*( sm->p)) ) {
		case 0: goto tr69;
		case 9: goto tr73;
		case 10: goto tr69;
		case 13: goto tr69;
		case 32: goto tr73;
	}
	goto tr72;
case 277:
	switch( (*( sm->p)) ) {
		case 0: goto tr355;
		case 10: goto tr355;
		case 13: goto tr355;
	}
	goto tr356;
case 278:
	switch( (*( sm->p)) ) {
		case 0: goto tr355;
		case 9: goto tr73;
		case 10: goto tr355;
		case 13: goto tr355;
		case 32: goto tr73;
	}
	goto tr72;
case 279:
	if ( (*( sm->p)) == 10 )
		goto tr337;
	goto tr357;
case 280:
	if ( (*( sm->p)) == 34 )
		goto tr358;
	goto tr359;
case 63:
	if ( (*( sm->p)) == 34 )
		goto tr76;
	goto tr75;
case 64:
	if ( (*( sm->p)) == 58 )
		goto tr77;
	goto tr74;
case 65:
	switch( (*( sm->p)) ) {
		case 47: goto tr78;
		case 91: goto tr79;
		case 104: goto tr80;
	}
	goto tr74;
case 66:
	if ( 33 <= (*( sm->p)) && (*( sm->p)) <= 126 )
		goto tr81;
	goto tr74;
case 281:
	if ( 33 <= (*( sm->p)) && (*( sm->p)) <= 126 )
		goto tr81;
	goto tr360;
case 67:
	switch( (*( sm->p)) ) {
		case 47: goto tr82;
		case 104: goto tr83;
	}
	goto tr74;
case 68:
	if ( 33 <= (*( sm->p)) && (*( sm->p)) <= 126 )
		goto tr84;
	goto tr74;
case 69:
	if ( (*( sm->p)) == 93 )
		goto tr85;
	if ( 33 <= (*( sm->p)) && (*( sm->p)) <= 126 )
		goto tr84;
	goto tr74;
case 70:
	if ( (*( sm->p)) == 116 )
		goto tr86;
	goto tr74;
case 71:
	if ( (*( sm->p)) == 116 )
		goto tr87;
	goto tr74;
case 72:
	if ( (*( sm->p)) == 112 )
		goto tr88;
	goto tr74;
case 73:
	switch( (*( sm->p)) ) {
		case 58: goto tr89;
		case 115: goto tr90;
	}
	goto tr74;
case 74:
	if ( (*( sm->p)) == 47 )
		goto tr91;
	goto tr74;
case 75:
	if ( (*( sm->p)) == 47 )
		goto tr92;
	goto tr74;
case 76:
	if ( (*( sm->p)) == 58 )
		goto tr89;
	goto tr74;
case 77:
	if ( (*( sm->p)) == 116 )
		goto tr93;
	goto tr74;
case 78:
	if ( (*( sm->p)) == 116 )
		goto tr94;
	goto tr74;
case 79:
	if ( (*( sm->p)) == 112 )
		goto tr95;
	goto tr74;
case 80:
	switch( (*( sm->p)) ) {
		case 58: goto tr96;
		case 115: goto tr97;
	}
	goto tr74;
case 81:
	if ( (*( sm->p)) == 47 )
		goto tr98;
	goto tr74;
case 82:
	if ( (*( sm->p)) == 47 )
		goto tr99;
	goto tr74;
case 83:
	if ( (*( sm->p)) == 58 )
		goto tr96;
	goto tr74;
case 282:
	if ( 33 <= (*( sm->p)) && (*( sm->p)) <= 126 )
		goto tr361;
	goto tr358;
case 283:
	if ( (*( sm->p)) == 64 )
		goto tr364;
	if ( 33 <= (*( sm->p)) && (*( sm->p)) <= 126 )
		goto tr363;
	goto tr362;
case 284:
	if ( 33 <= (*( sm->p)) && (*( sm->p)) <= 126 )
		goto tr363;
	goto tr365;
case 285:
	switch( (*( sm->p)) ) {
		case 82: goto tr366;
		case 114: goto tr366;
	}
	goto tr358;
case 84:
	switch( (*( sm->p)) ) {
		case 84: goto tr100;
		case 116: goto tr100;
	}
	goto tr74;
case 85:
	switch( (*( sm->p)) ) {
		case 73: goto tr101;
		case 105: goto tr101;
	}
	goto tr74;
case 86:
	switch( (*( sm->p)) ) {
		case 83: goto tr102;
		case 115: goto tr102;
	}
	goto tr74;
case 87:
	switch( (*( sm->p)) ) {
		case 84: goto tr103;
		case 116: goto tr103;
	}
	goto tr74;
case 88:
	if ( (*( sm->p)) == 32 )
		goto tr104;
	goto tr74;
case 89:
	if ( (*( sm->p)) == 35 )
		goto tr105;
	goto tr74;
case 90:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr106;
	goto tr74;
case 286:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr368;
	goto tr367;
case 287:
	switch( (*( sm->p)) ) {
		case 79: goto tr369;
		case 111: goto tr369;
	}
	goto tr358;
case 91:
	switch( (*( sm->p)) ) {
		case 77: goto tr107;
		case 109: goto tr107;
	}
	goto tr74;
case 92:
	switch( (*( sm->p)) ) {
		case 77: goto tr108;
		case 109: goto tr108;
	}
	goto tr74;
case 93:
	switch( (*( sm->p)) ) {
		case 69: goto tr109;
		case 101: goto tr109;
	}
	goto tr74;
case 94:
	switch( (*( sm->p)) ) {
		case 78: goto tr110;
		case 110: goto tr110;
	}
	goto tr74;
case 95:
	switch( (*( sm->p)) ) {
		case 84: goto tr111;
		case 116: goto tr111;
	}
	goto tr74;
case 96:
	if ( (*( sm->p)) == 32 )
		goto tr112;
	goto tr74;
case 97:
	if ( (*( sm->p)) == 35 )
		goto tr113;
	goto tr74;
case 98:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr114;
	goto tr74;
case 288:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr371;
	goto tr370;
case 289:
	switch( (*( sm->p)) ) {
		case 79: goto tr372;
		case 111: goto tr372;
	}
	goto tr358;
case 99:
	switch( (*( sm->p)) ) {
		case 82: goto tr115;
		case 114: goto tr115;
	}
	goto tr74;
case 100:
	switch( (*( sm->p)) ) {
		case 85: goto tr116;
		case 117: goto tr116;
	}
	goto tr74;
case 101:
	switch( (*( sm->p)) ) {
		case 77: goto tr117;
		case 109: goto tr117;
	}
	goto tr74;
case 102:
	if ( (*( sm->p)) == 32 )
		goto tr118;
	goto tr74;
case 103:
	if ( (*( sm->p)) == 35 )
		goto tr119;
	goto tr74;
case 104:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr120;
	goto tr74;
case 290:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr374;
	goto tr373;
case 291:
	switch( (*( sm->p)) ) {
		case 83: goto tr375;
		case 115: goto tr375;
	}
	goto tr358;
case 105:
	switch( (*( sm->p)) ) {
		case 83: goto tr121;
		case 115: goto tr121;
	}
	goto tr74;
case 106:
	switch( (*( sm->p)) ) {
		case 85: goto tr122;
		case 117: goto tr122;
	}
	goto tr74;
case 107:
	switch( (*( sm->p)) ) {
		case 69: goto tr123;
		case 101: goto tr123;
	}
	goto tr74;
case 108:
	if ( (*( sm->p)) == 32 )
		goto tr124;
	goto tr74;
case 109:
	if ( (*( sm->p)) == 35 )
		goto tr125;
	goto tr74;
case 110:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr126;
	goto tr74;
case 292:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr377;
	goto tr376;
case 293:
	switch( (*( sm->p)) ) {
		case 73: goto tr378;
		case 79: goto tr379;
		case 105: goto tr378;
		case 111: goto tr379;
	}
	goto tr358;
case 111:
	switch( (*( sm->p)) ) {
		case 88: goto tr127;
		case 120: goto tr127;
	}
	goto tr74;
case 112:
	switch( (*( sm->p)) ) {
		case 73: goto tr128;
		case 105: goto tr128;
	}
	goto tr74;
case 113:
	switch( (*( sm->p)) ) {
		case 86: goto tr129;
		case 118: goto tr129;
	}
	goto tr74;
case 114:
	if ( (*( sm->p)) == 32 )
		goto tr130;
	goto tr74;
case 115:
	if ( (*( sm->p)) == 35 )
		goto tr131;
	goto tr74;
case 116:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr132;
	goto tr74;
case 294:
	if ( (*( sm->p)) == 47 )
		goto tr381;
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr382;
	goto tr380;
case 117:
	if ( (*( sm->p)) == 112 )
		goto tr134;
	goto tr133;
case 118:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr135;
	goto tr133;
case 295:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr384;
	goto tr383;
case 119:
	switch( (*( sm->p)) ) {
		case 79: goto tr136;
		case 83: goto tr137;
		case 111: goto tr136;
		case 115: goto tr137;
	}
	goto tr74;
case 120:
	switch( (*( sm->p)) ) {
		case 76: goto tr138;
		case 108: goto tr138;
	}
	goto tr74;
case 121:
	if ( (*( sm->p)) == 32 )
		goto tr139;
	goto tr74;
case 122:
	if ( (*( sm->p)) == 35 )
		goto tr140;
	goto tr74;
case 123:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr141;
	goto tr74;
case 296:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr386;
	goto tr385;
case 124:
	switch( (*( sm->p)) ) {
		case 84: goto tr142;
		case 116: goto tr142;
	}
	goto tr74;
case 125:
	if ( (*( sm->p)) == 32 )
		goto tr143;
	goto tr74;
case 126:
	if ( (*( sm->p)) == 35 )
		goto tr144;
	goto tr74;
case 127:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr145;
	goto tr74;
case 297:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr388;
	goto tr387;
case 298:
	switch( (*( sm->p)) ) {
		case 79: goto tr389;
		case 111: goto tr389;
	}
	goto tr358;
case 128:
	switch( (*( sm->p)) ) {
		case 80: goto tr146;
		case 112: goto tr146;
	}
	goto tr74;
case 129:
	switch( (*( sm->p)) ) {
		case 73: goto tr147;
		case 105: goto tr147;
	}
	goto tr74;
case 130:
	switch( (*( sm->p)) ) {
		case 67: goto tr148;
		case 99: goto tr148;
	}
	goto tr74;
case 131:
	if ( (*( sm->p)) == 32 )
		goto tr149;
	goto tr74;
case 132:
	if ( (*( sm->p)) == 35 )
		goto tr150;
	goto tr74;
case 133:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr151;
	goto tr74;
case 299:
	if ( (*( sm->p)) == 47 )
		goto tr391;
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr392;
	goto tr390;
case 134:
	if ( (*( sm->p)) == 112 )
		goto tr153;
	goto tr152;
case 135:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr154;
	goto tr152;
case 300:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr394;
	goto tr393;
case 301:
	switch( (*( sm->p)) ) {
		case 83: goto tr395;
		case 115: goto tr395;
	}
	goto tr358;
case 136:
	switch( (*( sm->p)) ) {
		case 69: goto tr155;
		case 101: goto tr155;
	}
	goto tr74;
case 137:
	switch( (*( sm->p)) ) {
		case 82: goto tr156;
		case 114: goto tr156;
	}
	goto tr74;
case 138:
	if ( (*( sm->p)) == 32 )
		goto tr157;
	goto tr74;
case 139:
	if ( (*( sm->p)) == 35 )
		goto tr158;
	goto tr74;
case 140:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr159;
	goto tr74;
case 302:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr397;
	goto tr396;
case 303:
	switch( (*( sm->p)) ) {
		case 47: goto tr398;
		case 91: goto tr399;
		case 98: goto tr400;
		case 101: goto tr401;
		case 105: goto tr402;
		case 110: goto tr403;
		case 113: goto tr404;
		case 115: goto tr405;
		case 116: goto tr406;
		case 117: goto tr407;
	}
	goto tr358;
case 141:
	switch( (*( sm->p)) ) {
		case 98: goto tr160;
		case 101: goto tr161;
		case 105: goto tr162;
		case 113: goto tr163;
		case 115: goto tr164;
		case 116: goto tr165;
		case 117: goto tr166;
	}
	goto tr74;
case 142:
	if ( (*( sm->p)) == 93 )
		goto tr167;
	goto tr74;
case 143:
	if ( (*( sm->p)) == 120 )
		goto tr168;
	goto tr74;
case 144:
	if ( (*( sm->p)) == 112 )
		goto tr169;
	goto tr74;
case 145:
	if ( (*( sm->p)) == 97 )
		goto tr170;
	goto tr74;
case 146:
	if ( (*( sm->p)) == 110 )
		goto tr171;
	goto tr74;
case 147:
	if ( (*( sm->p)) == 100 )
		goto tr172;
	goto tr74;
case 148:
	if ( (*( sm->p)) == 93 )
		goto tr173;
	goto tr74;
case 149:
	if ( (*( sm->p)) == 93 )
		goto tr174;
	goto tr74;
case 150:
	if ( (*( sm->p)) == 117 )
		goto tr175;
	goto tr74;
case 151:
	if ( (*( sm->p)) == 111 )
		goto tr176;
	goto tr74;
case 152:
	if ( (*( sm->p)) == 116 )
		goto tr177;
	goto tr74;
case 153:
	if ( (*( sm->p)) == 101 )
		goto tr178;
	goto tr74;
case 154:
	if ( (*( sm->p)) == 93 )
		goto tr179;
	goto tr74;
case 304:
	if ( (*( sm->p)) == 32 )
		goto tr179;
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr179;
	goto tr408;
case 155:
	switch( (*( sm->p)) ) {
		case 93: goto tr180;
		case 112: goto tr181;
	}
	goto tr74;
case 156:
	if ( (*( sm->p)) == 111 )
		goto tr182;
	goto tr74;
case 157:
	if ( (*( sm->p)) == 105 )
		goto tr183;
	goto tr74;
case 158:
	if ( (*( sm->p)) == 108 )
		goto tr184;
	goto tr74;
case 159:
	if ( (*( sm->p)) == 101 )
		goto tr185;
	goto tr74;
case 160:
	if ( (*( sm->p)) == 114 )
		goto tr186;
	goto tr74;
case 161:
	if ( (*( sm->p)) == 93 )
		goto tr187;
	goto tr74;
case 162:
	switch( (*( sm->p)) ) {
		case 100: goto tr188;
		case 104: goto tr189;
		case 110: goto tr190;
	}
	goto tr74;
case 163:
	if ( (*( sm->p)) == 93 )
		goto tr191;
	goto tr74;
case 164:
	if ( (*( sm->p)) == 93 )
		goto tr192;
	goto tr74;
case 165:
	if ( (*( sm->p)) == 93 )
		goto tr193;
	goto tr74;
case 166:
	if ( (*( sm->p)) == 93 )
		goto tr194;
	goto tr74;
case 167:
	switch( (*( sm->p)) ) {
		case 93: goto tr74;
		case 124: goto tr74;
	}
	goto tr195;
case 168:
	switch( (*( sm->p)) ) {
		case 93: goto tr197;
		case 124: goto tr198;
	}
	goto tr196;
case 169:
	if ( (*( sm->p)) == 93 )
		goto tr199;
	goto tr74;
case 170:
	if ( (*( sm->p)) == 93 )
		goto tr74;
	goto tr200;
case 171:
	if ( (*( sm->p)) == 93 )
		goto tr202;
	goto tr201;
case 172:
	if ( (*( sm->p)) == 93 )
		goto tr203;
	goto tr74;
case 173:
	if ( (*( sm->p)) == 93 )
		goto tr204;
	goto tr74;
case 174:
	if ( (*( sm->p)) == 120 )
		goto tr205;
	goto tr74;
case 175:
	if ( (*( sm->p)) == 112 )
		goto tr206;
	goto tr74;
case 176:
	if ( (*( sm->p)) == 97 )
		goto tr207;
	goto tr74;
case 177:
	if ( (*( sm->p)) == 110 )
		goto tr208;
	goto tr74;
case 178:
	if ( (*( sm->p)) == 100 )
		goto tr209;
	goto tr74;
case 179:
	if ( (*( sm->p)) == 93 )
		goto tr210;
	goto tr74;
case 180:
	if ( (*( sm->p)) == 93 )
		goto tr211;
	goto tr74;
case 181:
	if ( (*( sm->p)) == 111 )
		goto tr212;
	goto tr74;
case 182:
	if ( (*( sm->p)) == 100 )
		goto tr213;
	goto tr74;
case 183:
	if ( (*( sm->p)) == 116 )
		goto tr214;
	goto tr74;
case 184:
	if ( (*( sm->p)) == 101 )
		goto tr215;
	goto tr74;
case 185:
	if ( (*( sm->p)) == 120 )
		goto tr216;
	goto tr74;
case 186:
	if ( (*( sm->p)) == 116 )
		goto tr217;
	goto tr74;
case 187:
	if ( (*( sm->p)) == 93 )
		goto tr218;
	goto tr74;
case 188:
	if ( (*( sm->p)) == 117 )
		goto tr219;
	goto tr74;
case 189:
	if ( (*( sm->p)) == 111 )
		goto tr220;
	goto tr74;
case 190:
	if ( (*( sm->p)) == 116 )
		goto tr221;
	goto tr74;
case 191:
	if ( (*( sm->p)) == 101 )
		goto tr222;
	goto tr74;
case 192:
	if ( (*( sm->p)) == 93 )
		goto tr223;
	goto tr74;
case 193:
	switch( (*( sm->p)) ) {
		case 93: goto tr224;
		case 112: goto tr225;
	}
	goto tr74;
case 194:
	if ( (*( sm->p)) == 111 )
		goto tr226;
	goto tr74;
case 195:
	if ( (*( sm->p)) == 105 )
		goto tr227;
	goto tr74;
case 196:
	if ( (*( sm->p)) == 108 )
		goto tr228;
	goto tr74;
case 197:
	if ( (*( sm->p)) == 101 )
		goto tr229;
	goto tr74;
case 198:
	if ( (*( sm->p)) == 114 )
		goto tr230;
	goto tr74;
case 199:
	if ( (*( sm->p)) == 93 )
		goto tr231;
	goto tr74;
case 200:
	if ( (*( sm->p)) == 110 )
		goto tr232;
	goto tr74;
case 201:
	if ( (*( sm->p)) == 93 )
		goto tr233;
	goto tr74;
case 202:
	if ( (*( sm->p)) == 93 )
		goto tr234;
	goto tr74;
case 305:
	if ( (*( sm->p)) == 116 )
		goto tr410;
	if ( 49 <= (*( sm->p)) && (*( sm->p)) <= 54 )
		goto tr409;
	goto tr358;
case 203:
	if ( (*( sm->p)) == 46 )
		goto tr235;
	goto tr74;
case 306:
	switch( (*( sm->p)) ) {
		case 9: goto tr412;
		case 32: goto tr412;
	}
	goto tr411;
case 204:
	if ( (*( sm->p)) == 116 )
		goto tr236;
	goto tr74;
case 205:
	if ( (*( sm->p)) == 112 )
		goto tr237;
	goto tr74;
case 206:
	switch( (*( sm->p)) ) {
		case 58: goto tr238;
		case 115: goto tr239;
	}
	goto tr74;
case 207:
	if ( (*( sm->p)) == 47 )
		goto tr240;
	goto tr74;
case 208:
	if ( (*( sm->p)) == 47 )
		goto tr241;
	goto tr74;
case 209:
	if ( 33 <= (*( sm->p)) && (*( sm->p)) <= 126 )
		goto tr242;
	goto tr74;
case 307:
	if ( 33 <= (*( sm->p)) && (*( sm->p)) <= 126 )
		goto tr242;
	goto tr413;
case 210:
	if ( (*( sm->p)) == 58 )
		goto tr238;
	goto tr74;
case 308:
	if ( (*( sm->p)) == 123 )
		goto tr414;
	goto tr358;
case 211:
	if ( (*( sm->p)) == 125 )
		goto tr74;
	goto tr243;
case 212:
	if ( (*( sm->p)) == 125 )
		goto tr245;
	goto tr244;
case 213:
	if ( (*( sm->p)) == 125 )
		goto tr246;
	goto tr74;
case 309:
	switch( (*( sm->p)) ) {
		case 0: goto tr416;
		case 91: goto tr417;
	}
	goto tr415;
case 310:
	if ( (*( sm->p)) == 47 )
		goto tr419;
	goto tr418;
case 214:
	if ( (*( sm->p)) == 99 )
		goto tr248;
	goto tr247;
case 215:
	if ( (*( sm->p)) == 111 )
		goto tr249;
	goto tr247;
case 216:
	if ( (*( sm->p)) == 100 )
		goto tr250;
	goto tr247;
case 217:
	if ( (*( sm->p)) == 101 )
		goto tr251;
	goto tr247;
case 218:
	if ( (*( sm->p)) == 93 )
		goto tr252;
	goto tr247;
case 311:
	switch( (*( sm->p)) ) {
		case 0: goto tr421;
		case 91: goto tr422;
	}
	goto tr420;
case 312:
	if ( (*( sm->p)) == 47 )
		goto tr424;
	goto tr423;
case 219:
	if ( (*( sm->p)) == 110 )
		goto tr254;
	goto tr253;
case 220:
	if ( (*( sm->p)) == 111 )
		goto tr255;
	goto tr253;
case 221:
	if ( (*( sm->p)) == 100 )
		goto tr256;
	goto tr253;
case 222:
	if ( (*( sm->p)) == 116 )
		goto tr257;
	goto tr253;
case 223:
	if ( (*( sm->p)) == 101 )
		goto tr258;
	goto tr253;
case 224:
	if ( (*( sm->p)) == 120 )
		goto tr259;
	goto tr253;
case 225:
	if ( (*( sm->p)) == 116 )
		goto tr260;
	goto tr253;
case 226:
	if ( (*( sm->p)) == 93 )
		goto tr261;
	goto tr253;
case 313:
	switch( (*( sm->p)) ) {
		case 0: goto tr426;
		case 91: goto tr427;
	}
	goto tr425;
case 314:
	switch( (*( sm->p)) ) {
		case 47: goto tr429;
		case 116: goto tr430;
	}
	goto tr428;
case 227:
	if ( (*( sm->p)) == 116 )
		goto tr263;
	goto tr262;
case 228:
	switch( (*( sm->p)) ) {
		case 97: goto tr264;
		case 98: goto tr265;
		case 104: goto tr266;
		case 114: goto tr267;
	}
	goto tr262;
case 229:
	if ( (*( sm->p)) == 98 )
		goto tr268;
	goto tr262;
case 230:
	if ( (*( sm->p)) == 108 )
		goto tr269;
	goto tr262;
case 231:
	if ( (*( sm->p)) == 101 )
		goto tr270;
	goto tr262;
case 232:
	if ( (*( sm->p)) == 93 )
		goto tr271;
	goto tr262;
case 233:
	if ( (*( sm->p)) == 111 )
		goto tr272;
	goto tr262;
case 234:
	if ( (*( sm->p)) == 100 )
		goto tr273;
	goto tr262;
case 235:
	if ( (*( sm->p)) == 121 )
		goto tr274;
	goto tr262;
case 236:
	if ( (*( sm->p)) == 93 )
		goto tr275;
	goto tr262;
case 237:
	if ( (*( sm->p)) == 101 )
		goto tr276;
	goto tr262;
case 238:
	if ( (*( sm->p)) == 97 )
		goto tr277;
	goto tr262;
case 239:
	if ( (*( sm->p)) == 100 )
		goto tr278;
	goto tr262;
case 240:
	if ( (*( sm->p)) == 93 )
		goto tr279;
	goto tr262;
case 241:
	if ( (*( sm->p)) == 93 )
		goto tr280;
	goto tr262;
case 242:
	switch( (*( sm->p)) ) {
		case 98: goto tr281;
		case 100: goto tr282;
		case 104: goto tr283;
		case 114: goto tr284;
	}
	goto tr262;
case 243:
	if ( (*( sm->p)) == 111 )
		goto tr285;
	goto tr262;
case 244:
	if ( (*( sm->p)) == 100 )
		goto tr286;
	goto tr262;
case 245:
	if ( (*( sm->p)) == 121 )
		goto tr287;
	goto tr262;
case 246:
	if ( (*( sm->p)) == 93 )
		goto tr288;
	goto tr262;
case 247:
	if ( (*( sm->p)) == 93 )
		goto tr289;
	goto tr262;
case 248:
	switch( (*( sm->p)) ) {
		case 93: goto tr290;
		case 101: goto tr291;
	}
	goto tr262;
case 249:
	if ( (*( sm->p)) == 97 )
		goto tr292;
	goto tr262;
case 250:
	if ( (*( sm->p)) == 100 )
		goto tr293;
	goto tr262;
case 251:
	if ( (*( sm->p)) == 93 )
		goto tr294;
	goto tr262;
case 252:
	if ( (*( sm->p)) == 93 )
		goto tr295;
	goto tr262;
case 315:
	switch( (*( sm->p)) ) {
		case 0: goto tr432;
		case 10: goto tr433;
		case 13: goto tr434;
		case 42: goto tr435;
	}
	goto tr431;
case 316:
	switch( (*( sm->p)) ) {
		case 10: goto tr297;
		case 13: goto tr436;
	}
	goto tr296;
case 253:
	if ( (*( sm->p)) == 10 )
		goto tr297;
	goto tr296;
case 317:
	if ( (*( sm->p)) == 10 )
		goto tr433;
	goto tr437;
case 318:
	switch( (*( sm->p)) ) {
		case 9: goto tr301;
		case 32: goto tr301;
		case 42: goto tr302;
	}
	goto tr437;
case 254:
	switch( (*( sm->p)) ) {
		case 0: goto tr298;
		case 9: goto tr300;
		case 10: goto tr298;
		case 13: goto tr298;
		case 32: goto tr300;
	}
	goto tr299;
case 319:
	switch( (*( sm->p)) ) {
		case 0: goto tr438;
		case 10: goto tr438;
		case 13: goto tr438;
	}
	goto tr439;
case 320:
	switch( (*( sm->p)) ) {
		case 0: goto tr438;
		case 9: goto tr300;
		case 10: goto tr438;
		case 13: goto tr438;
		case 32: goto tr300;
	}
	goto tr299;
case 255:
	switch( (*( sm->p)) ) {
		case 9: goto tr301;
		case 32: goto tr301;
		case 42: goto tr302;
	}
	goto tr298;
	}

	tr57:  sm->cs = 0; goto _again;
	tr310:  sm->cs = 1; goto _again;
	tr5:  sm->cs = 2; goto f4;
	tr6:  sm->cs = 3; goto _again;
	tr314:  sm->cs = 4; goto _again;
	tr7:  sm->cs = 5; goto _again;
	tr8:  sm->cs = 6; goto _again;
	tr9:  sm->cs = 7; goto _again;
	tr10:  sm->cs = 8; goto _again;
	tr11:  sm->cs = 9; goto _again;
	tr12:  sm->cs = 10; goto _again;
	tr13:  sm->cs = 11; goto _again;
	tr315:  sm->cs = 12; goto _again;
	tr15:  sm->cs = 13; goto _again;
	tr16:  sm->cs = 14; goto _again;
	tr17:  sm->cs = 15; goto _again;
	tr316:  sm->cs = 16; goto _again;
	tr19:  sm->cs = 17; goto _again;
	tr20:  sm->cs = 18; goto _again;
	tr21:  sm->cs = 19; goto _again;
	tr22:  sm->cs = 20; goto _again;
	tr23:  sm->cs = 21; goto _again;
	tr24:  sm->cs = 22; goto _again;
	tr27:  sm->cs = 23; goto _again;
	tr26:  sm->cs = 23; goto f6;
	tr317:  sm->cs = 24; goto _again;
	tr29:  sm->cs = 25; goto _again;
	tr30:  sm->cs = 26; goto _again;
	tr31:  sm->cs = 27; goto _again;
	tr32:  sm->cs = 28; goto _again;
	tr33:  sm->cs = 29; goto _again;
	tr34:  sm->cs = 30; goto _again;
	tr318:  sm->cs = 31; goto _again;
	tr36:  sm->cs = 32; goto _again;
	tr37:  sm->cs = 33; goto _again;
	tr38:  sm->cs = 34; goto _again;
	tr39:  sm->cs = 35; goto _again;
	tr319:  sm->cs = 36; goto _again;
	tr41:  sm->cs = 37; goto _again;
	tr42:  sm->cs = 38; goto _again;
	tr43:  sm->cs = 39; goto _again;
	tr44:  sm->cs = 40; goto _again;
	tr45:  sm->cs = 41; goto _again;
	tr46:  sm->cs = 42; goto _again;
	tr320:  sm->cs = 43; goto _again;
	tr48:  sm->cs = 44; goto _again;
	tr50:  sm->cs = 45; goto _again;
	tr51:  sm->cs = 46; goto _again;
	tr52:  sm->cs = 47; goto _again;
	tr49:  sm->cs = 48; goto _again;
	tr328:  sm->cs = 49; goto f6;
	tr331:  sm->cs = 50; goto _again;
	tr56:  sm->cs = 51; goto _again;
	tr58:  sm->cs = 52; goto _again;
	tr59:  sm->cs = 53; goto _again;
	tr61:  sm->cs = 54; goto _again;
	tr62:  sm->cs = 55; goto _again;
	tr63:  sm->cs = 56; goto _again;
	tr64:  sm->cs = 57; goto _again;
	tr66:  sm->cs = 58; goto _again;
	tr65:  sm->cs = 59; goto _again;
	tr352:  sm->cs = 60; goto _again;
	tr71:  sm->cs = 61; goto _again;
	tr353:  sm->cs = 61; goto f6;
	tr70:  sm->cs = 62; goto f4;
	tr75:  sm->cs = 63; goto _again;
	tr359:  sm->cs = 63; goto f6;
	tr76:  sm->cs = 64; goto f4;
	tr77:  sm->cs = 65; goto _again;
	tr99:  sm->cs = 66; goto _again;
	tr78:  sm->cs = 66; goto f3;
	tr79:  sm->cs = 67; goto _again;
	tr92:  sm->cs = 68; goto _again;
	tr82:  sm->cs = 68; goto f3;
	tr84:  sm->cs = 69; goto _again;
	tr83:  sm->cs = 70; goto f3;
	tr86:  sm->cs = 71; goto _again;
	tr87:  sm->cs = 72; goto _again;
	tr88:  sm->cs = 73; goto _again;
	tr89:  sm->cs = 74; goto _again;
	tr91:  sm->cs = 75; goto _again;
	tr90:  sm->cs = 76; goto _again;
	tr80:  sm->cs = 77; goto f3;
	tr93:  sm->cs = 78; goto _again;
	tr94:  sm->cs = 79; goto _again;
	tr95:  sm->cs = 80; goto _again;
	tr96:  sm->cs = 81; goto _again;
	tr98:  sm->cs = 82; goto _again;
	tr97:  sm->cs = 83; goto _again;
	tr366:  sm->cs = 84; goto _again;
	tr100:  sm->cs = 85; goto _again;
	tr101:  sm->cs = 86; goto _again;
	tr102:  sm->cs = 87; goto _again;
	tr103:  sm->cs = 88; goto _again;
	tr104:  sm->cs = 89; goto _again;
	tr105:  sm->cs = 90; goto _again;
	tr369:  sm->cs = 91; goto _again;
	tr107:  sm->cs = 92; goto _again;
	tr108:  sm->cs = 93; goto _again;
	tr109:  sm->cs = 94; goto _again;
	tr110:  sm->cs = 95; goto _again;
	tr111:  sm->cs = 96; goto _again;
	tr112:  sm->cs = 97; goto _again;
	tr113:  sm->cs = 98; goto _again;
	tr372:  sm->cs = 99; goto _again;
	tr115:  sm->cs = 100; goto _again;
	tr116:  sm->cs = 101; goto _again;
	tr117:  sm->cs = 102; goto _again;
	tr118:  sm->cs = 103; goto _again;
	tr119:  sm->cs = 104; goto _again;
	tr375:  sm->cs = 105; goto _again;
	tr121:  sm->cs = 106; goto _again;
	tr122:  sm->cs = 107; goto _again;
	tr123:  sm->cs = 108; goto _again;
	tr124:  sm->cs = 109; goto _again;
	tr125:  sm->cs = 110; goto _again;
	tr378:  sm->cs = 111; goto _again;
	tr127:  sm->cs = 112; goto _again;
	tr128:  sm->cs = 113; goto _again;
	tr129:  sm->cs = 114; goto _again;
	tr130:  sm->cs = 115; goto _again;
	tr131:  sm->cs = 116; goto _again;
	tr381:  sm->cs = 117; goto f4;
	tr134:  sm->cs = 118; goto _again;
	tr379:  sm->cs = 119; goto _again;
	tr136:  sm->cs = 120; goto _again;
	tr138:  sm->cs = 121; goto _again;
	tr139:  sm->cs = 122; goto _again;
	tr140:  sm->cs = 123; goto _again;
	tr137:  sm->cs = 124; goto _again;
	tr142:  sm->cs = 125; goto _again;
	tr143:  sm->cs = 126; goto _again;
	tr144:  sm->cs = 127; goto _again;
	tr389:  sm->cs = 128; goto _again;
	tr146:  sm->cs = 129; goto _again;
	tr147:  sm->cs = 130; goto _again;
	tr148:  sm->cs = 131; goto _again;
	tr149:  sm->cs = 132; goto _again;
	tr150:  sm->cs = 133; goto _again;
	tr391:  sm->cs = 134; goto f4;
	tr153:  sm->cs = 135; goto _again;
	tr395:  sm->cs = 136; goto _again;
	tr155:  sm->cs = 137; goto _again;
	tr156:  sm->cs = 138; goto _again;
	tr157:  sm->cs = 139; goto _again;
	tr158:  sm->cs = 140; goto _again;
	tr398:  sm->cs = 141; goto _again;
	tr160:  sm->cs = 142; goto _again;
	tr161:  sm->cs = 143; goto _again;
	tr168:  sm->cs = 144; goto _again;
	tr169:  sm->cs = 145; goto _again;
	tr170:  sm->cs = 146; goto _again;
	tr171:  sm->cs = 147; goto _again;
	tr172:  sm->cs = 148; goto _again;
	tr162:  sm->cs = 149; goto _again;
	tr163:  sm->cs = 150; goto _again;
	tr175:  sm->cs = 151; goto _again;
	tr176:  sm->cs = 152; goto _again;
	tr177:  sm->cs = 153; goto _again;
	tr178:  sm->cs = 154; goto _again;
	tr164:  sm->cs = 155; goto _again;
	tr181:  sm->cs = 156; goto _again;
	tr182:  sm->cs = 157; goto _again;
	tr183:  sm->cs = 158; goto _again;
	tr184:  sm->cs = 159; goto _again;
	tr185:  sm->cs = 160; goto _again;
	tr186:  sm->cs = 161; goto _again;
	tr165:  sm->cs = 162; goto _again;
	tr188:  sm->cs = 163; goto _again;
	tr189:  sm->cs = 164; goto _again;
	tr190:  sm->cs = 165; goto _again;
	tr166:  sm->cs = 166; goto _again;
	tr399:  sm->cs = 167; goto _again;
	tr196:  sm->cs = 168; goto _again;
	tr195:  sm->cs = 168; goto f6;
	tr197:  sm->cs = 169; goto f4;
	tr198:  sm->cs = 170; goto f4;
	tr201:  sm->cs = 171; goto _again;
	tr200:  sm->cs = 171; goto f3;
	tr202:  sm->cs = 172; goto f27;
	tr400:  sm->cs = 173; goto _again;
	tr401:  sm->cs = 174; goto _again;
	tr205:  sm->cs = 175; goto _again;
	tr206:  sm->cs = 176; goto _again;
	tr207:  sm->cs = 177; goto _again;
	tr208:  sm->cs = 178; goto _again;
	tr209:  sm->cs = 179; goto _again;
	tr402:  sm->cs = 180; goto _again;
	tr403:  sm->cs = 181; goto _again;
	tr212:  sm->cs = 182; goto _again;
	tr213:  sm->cs = 183; goto _again;
	tr214:  sm->cs = 184; goto _again;
	tr215:  sm->cs = 185; goto _again;
	tr216:  sm->cs = 186; goto _again;
	tr217:  sm->cs = 187; goto _again;
	tr404:  sm->cs = 188; goto _again;
	tr219:  sm->cs = 189; goto _again;
	tr220:  sm->cs = 190; goto _again;
	tr221:  sm->cs = 191; goto _again;
	tr222:  sm->cs = 192; goto _again;
	tr405:  sm->cs = 193; goto _again;
	tr225:  sm->cs = 194; goto _again;
	tr226:  sm->cs = 195; goto _again;
	tr227:  sm->cs = 196; goto _again;
	tr228:  sm->cs = 197; goto _again;
	tr229:  sm->cs = 198; goto _again;
	tr230:  sm->cs = 199; goto _again;
	tr406:  sm->cs = 200; goto _again;
	tr232:  sm->cs = 201; goto _again;
	tr407:  sm->cs = 202; goto _again;
	tr409:  sm->cs = 203; goto f6;
	tr410:  sm->cs = 204; goto _again;
	tr236:  sm->cs = 205; goto _again;
	tr237:  sm->cs = 206; goto _again;
	tr238:  sm->cs = 207; goto _again;
	tr240:  sm->cs = 208; goto _again;
	tr241:  sm->cs = 209; goto _again;
	tr239:  sm->cs = 210; goto _again;
	tr414:  sm->cs = 211; goto _again;
	tr244:  sm->cs = 212; goto _again;
	tr243:  sm->cs = 212; goto f6;
	tr245:  sm->cs = 213; goto f4;
	tr419:  sm->cs = 214; goto _again;
	tr248:  sm->cs = 215; goto _again;
	tr249:  sm->cs = 216; goto _again;
	tr250:  sm->cs = 217; goto _again;
	tr251:  sm->cs = 218; goto _again;
	tr424:  sm->cs = 219; goto _again;
	tr254:  sm->cs = 220; goto _again;
	tr255:  sm->cs = 221; goto _again;
	tr256:  sm->cs = 222; goto _again;
	tr257:  sm->cs = 223; goto _again;
	tr258:  sm->cs = 224; goto _again;
	tr259:  sm->cs = 225; goto _again;
	tr260:  sm->cs = 226; goto _again;
	tr429:  sm->cs = 227; goto _again;
	tr263:  sm->cs = 228; goto _again;
	tr264:  sm->cs = 229; goto _again;
	tr268:  sm->cs = 230; goto _again;
	tr269:  sm->cs = 231; goto _again;
	tr270:  sm->cs = 232; goto _again;
	tr265:  sm->cs = 233; goto _again;
	tr272:  sm->cs = 234; goto _again;
	tr273:  sm->cs = 235; goto _again;
	tr274:  sm->cs = 236; goto _again;
	tr266:  sm->cs = 237; goto _again;
	tr276:  sm->cs = 238; goto _again;
	tr277:  sm->cs = 239; goto _again;
	tr278:  sm->cs = 240; goto _again;
	tr267:  sm->cs = 241; goto _again;
	tr430:  sm->cs = 242; goto _again;
	tr281:  sm->cs = 243; goto _again;
	tr285:  sm->cs = 244; goto _again;
	tr286:  sm->cs = 245; goto _again;
	tr287:  sm->cs = 246; goto _again;
	tr282:  sm->cs = 247; goto _again;
	tr283:  sm->cs = 248; goto _again;
	tr291:  sm->cs = 249; goto _again;
	tr292:  sm->cs = 250; goto _again;
	tr293:  sm->cs = 251; goto _again;
	tr284:  sm->cs = 252; goto _again;
	tr436:  sm->cs = 253; goto _again;
	tr301:  sm->cs = 254; goto f4;
	tr302:  sm->cs = 255; goto _again;
	tr0:  sm->cs = 256; goto f0;
	tr2:  sm->cs = 256; goto f2;
	tr14:  sm->cs = 256; goto f5;
	tr53:  sm->cs = 256; goto f7;
	tr54:  sm->cs = 256; goto f8;
	tr303:  sm->cs = 256; goto f58;
	tr304:  sm->cs = 256; goto f59;
	tr311:  sm->cs = 256; goto f62;
	tr312:  sm->cs = 256; goto f63;
	tr321:  sm->cs = 256; goto f64;
	tr322:  sm->cs = 256; goto f65;
	tr324:  sm->cs = 256; goto f66;
	tr325:  sm->cs = 256; goto f67;
	tr326:  sm->cs = 256; goto f68;
	tr327:  sm->cs = 256; goto f69;
	tr329:  sm->cs = 256; goto f70;
	tr1:  sm->cs = 257; goto f1;
	tr305:  sm->cs = 257; goto f60;
	tr306:  sm->cs = 258; goto _again;
	tr307:  sm->cs = 259; goto f14;
	tr313:  sm->cs = 260; goto _again;
	tr3:  sm->cs = 260; goto f3;
	tr4:  sm->cs = 261; goto f3;
	tr308:  sm->cs = 262; goto f61;
	tr18:  sm->cs = 263; goto _again;
	tr323:  sm->cs = 264; goto _again;
	tr28:  sm->cs = 264; goto f4;
	tr25:  sm->cs = 265; goto _again;
	tr35:  sm->cs = 266; goto _again;
	tr40:  sm->cs = 267; goto _again;
	tr47:  sm->cs = 268; goto _again;
	tr309:  sm->cs = 269; goto f61;
	tr330:  sm->cs = 270; goto _again;
	tr55:  sm->cs = 270; goto f4;
	tr332:  sm->cs = 271; goto f71;
	tr60:  sm->cs = 272; goto _again;
	tr333:  sm->cs = 273; goto f72;
	tr334:  sm->cs = 273; goto f73;
	tr67:  sm->cs = 274; goto f9;
	tr69:  sm->cs = 274; goto f11;
	tr74:  sm->cs = 274; goto f12;
	tr85:  sm->cs = 274; goto f13;
	tr133:  sm->cs = 274; goto f15;
	tr152:  sm->cs = 274; goto f16;
	tr167:  sm->cs = 274; goto f17;
	tr173:  sm->cs = 274; goto f18;
	tr174:  sm->cs = 274; goto f19;
	tr180:  sm->cs = 274; goto f20;
	tr187:  sm->cs = 274; goto f21;
	tr191:  sm->cs = 274; goto f22;
	tr192:  sm->cs = 274; goto f23;
	tr193:  sm->cs = 274; goto f24;
	tr194:  sm->cs = 274; goto f25;
	tr199:  sm->cs = 274; goto f26;
	tr203:  sm->cs = 274; goto f28;
	tr204:  sm->cs = 274; goto f29;
	tr210:  sm->cs = 274; goto f30;
	tr211:  sm->cs = 274; goto f31;
	tr218:  sm->cs = 274; goto f32;
	tr223:  sm->cs = 274; goto f33;
	tr224:  sm->cs = 274; goto f34;
	tr231:  sm->cs = 274; goto f35;
	tr233:  sm->cs = 274; goto f36;
	tr234:  sm->cs = 274; goto f37;
	tr246:  sm->cs = 274; goto f38;
	tr335:  sm->cs = 274; goto f74;
	tr336:  sm->cs = 274; goto f75;
	tr351:  sm->cs = 274; goto f77;
	tr354:  sm->cs = 274; goto f78;
	tr355:  sm->cs = 274; goto f79;
	tr357:  sm->cs = 274; goto f80;
	tr358:  sm->cs = 274; goto f81;
	tr360:  sm->cs = 274; goto f82;
	tr362:  sm->cs = 274; goto f83;
	tr365:  sm->cs = 274; goto f86;
	tr367:  sm->cs = 274; goto f87;
	tr370:  sm->cs = 274; goto f88;
	tr373:  sm->cs = 274; goto f89;
	tr376:  sm->cs = 274; goto f90;
	tr380:  sm->cs = 274; goto f91;
	tr383:  sm->cs = 274; goto f92;
	tr385:  sm->cs = 274; goto f93;
	tr387:  sm->cs = 274; goto f94;
	tr390:  sm->cs = 274; goto f95;
	tr393:  sm->cs = 274; goto f96;
	tr396:  sm->cs = 274; goto f97;
	tr408:  sm->cs = 274; goto f98;
	tr411:  sm->cs = 274; goto f99;
	tr413:  sm->cs = 274; goto f100;
	tr337:  sm->cs = 275; goto f76;
	tr68:  sm->cs = 276; goto f10;
	tr356:  sm->cs = 277; goto _again;
	tr72:  sm->cs = 277; goto f3;
	tr73:  sm->cs = 278; goto f3;
	tr338:  sm->cs = 279; goto _again;
	tr339:  sm->cs = 280; goto f61;
	tr81:  sm->cs = 281; goto _again;
	tr340:  sm->cs = 282; goto _again;
	tr361:  sm->cs = 283; goto f6;
	tr363:  sm->cs = 284; goto f84;
	tr364:  sm->cs = 284; goto f85;
	tr341:  sm->cs = 285; goto f61;
	tr368:  sm->cs = 286; goto _again;
	tr106:  sm->cs = 286; goto f6;
	tr342:  sm->cs = 287; goto f61;
	tr371:  sm->cs = 288; goto _again;
	tr114:  sm->cs = 288; goto f6;
	tr343:  sm->cs = 289; goto f61;
	tr374:  sm->cs = 290; goto _again;
	tr120:  sm->cs = 290; goto f6;
	tr344:  sm->cs = 291; goto f61;
	tr377:  sm->cs = 292; goto _again;
	tr126:  sm->cs = 292; goto f6;
	tr345:  sm->cs = 293; goto f61;
	tr132:  sm->cs = 294; goto f14;
	tr382:  sm->cs = 294; goto f61;
	tr384:  sm->cs = 295; goto _again;
	tr135:  sm->cs = 295; goto f3;
	tr386:  sm->cs = 296; goto _again;
	tr141:  sm->cs = 296; goto f6;
	tr388:  sm->cs = 297; goto _again;
	tr145:  sm->cs = 297; goto f6;
	tr346:  sm->cs = 298; goto f61;
	tr151:  sm->cs = 299; goto f14;
	tr392:  sm->cs = 299; goto f61;
	tr394:  sm->cs = 300; goto _again;
	tr154:  sm->cs = 300; goto f3;
	tr347:  sm->cs = 301; goto f61;
	tr397:  sm->cs = 302; goto _again;
	tr159:  sm->cs = 302; goto f6;
	tr348:  sm->cs = 303; goto f61;
	tr179:  sm->cs = 304; goto _again;
	tr349:  sm->cs = 305; goto f61;
	tr412:  sm->cs = 306; goto _again;
	tr235:  sm->cs = 306; goto f4;
	tr242:  sm->cs = 307; goto _again;
	tr350:  sm->cs = 308; goto f61;
	tr247:  sm->cs = 309; goto f39;
	tr252:  sm->cs = 309; goto f40;
	tr415:  sm->cs = 309; goto f101;
	tr416:  sm->cs = 309; goto f102;
	tr418:  sm->cs = 309; goto f103;
	tr417:  sm->cs = 310; goto f61;
	tr253:  sm->cs = 311; goto f41;
	tr261:  sm->cs = 311; goto f42;
	tr420:  sm->cs = 311; goto f104;
	tr421:  sm->cs = 311; goto f105;
	tr423:  sm->cs = 311; goto f106;
	tr422:  sm->cs = 312; goto f61;
	tr262:  sm->cs = 313; goto f43;
	tr271:  sm->cs = 313; goto f44;
	tr275:  sm->cs = 313; goto f45;
	tr279:  sm->cs = 313; goto f46;
	tr280:  sm->cs = 313; goto f47;
	tr288:  sm->cs = 313; goto f48;
	tr289:  sm->cs = 313; goto f49;
	tr290:  sm->cs = 313; goto f50;
	tr294:  sm->cs = 313; goto f51;
	tr295:  sm->cs = 313; goto f52;
	tr425:  sm->cs = 313; goto f107;
	tr426:  sm->cs = 313; goto f108;
	tr428:  sm->cs = 313; goto f109;
	tr427:  sm->cs = 314; goto f61;
	tr296:  sm->cs = 315; goto f53;
	tr298:  sm->cs = 315; goto f55;
	tr431:  sm->cs = 315; goto f110;
	tr432:  sm->cs = 315; goto f111;
	tr437:  sm->cs = 315; goto f113;
	tr438:  sm->cs = 315; goto f114;
	tr297:  sm->cs = 316; goto f54;
	tr433:  sm->cs = 316; goto f112;
	tr434:  sm->cs = 317; goto _again;
	tr435:  sm->cs = 318; goto f14;
	tr439:  sm->cs = 319; goto _again;
	tr299:  sm->cs = 319; goto f3;
	tr300:  sm->cs = 320; goto f3;

f6:
#line 96 "ext/dtext/dtext.rl"
	{
  sm->a1 = sm->p;
}
	goto _again;
f4:
#line 100 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
	goto _again;
f3:
#line 104 "ext/dtext/dtext.rl"
	{
  sm->b1 = sm->p;
}
	goto _again;
f27:
#line 108 "ext/dtext/dtext.rl"
	{
  sm->b2 = sm->p;
}
	goto _again;
f61:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
	goto _again;
f71:
#line 152 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;}
	goto _again;
f73:
#line 156 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;}
	goto _again;
f72:
#line 158 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;}
	goto _again;
f38:
#line 269 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    append(sm, true, "<a rel=\"nofollow\" href=\"/posts?tags=");
    append_segment_uri_escaped(sm, sm->a1, sm->a2 - 1);
    append(sm, true, "\">");
    append_segment_html_escaped(sm, sm->a1, sm->a2 - 1);
    append(sm, true, "</a>");
  }}
	goto _again;
f26:
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
f28:
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
#line 412 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_push(sm, &INLINE_B);
    append(sm, true, "<strong>");
  }}
	goto _again;
f17:
#line 417 "ext/dtext/dtext.rl"
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
#line 426 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_push(sm, &INLINE_I);
    append(sm, true, "<em>");
  }}
	goto _again;
f19:
#line 431 "ext/dtext/dtext.rl"
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
#line 440 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_push(sm, &INLINE_S);
    append(sm, true, "<s>");
  }}
	goto _again;
f20:
#line 445 "ext/dtext/dtext.rl"
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
#line 454 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_push(sm, &INLINE_U);
    append(sm, true, "<u>");
  }}
	goto _again;
f25:
#line 459 "ext/dtext/dtext.rl"
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
#line 468 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_push(sm, &INLINE_TN);
    append(sm, true, "<span class=\"tn\">");
  }}
	goto _again;
f24:
#line 473 "ext/dtext/dtext.rl"
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
#line 495 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    g_debug("inline [quote]");
    dstack_close_before_block(sm);
    {( sm->p) = (( sm->ts))-1;}
    { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)];goto _again;}
  }}
	goto _again;
f35:
#line 518 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    g_debug("inline [spoiler]");
    g_debug("  push <span>");
    dstack_push(sm, &INLINE_SPOILER);
    append(sm, true, "<span class=\"spoiler\">");
  }}
	goto _again;
f21:
#line 525 "ext/dtext/dtext.rl"
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
#line 546 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    g_debug("inline [expand]");
    dstack_rewind(sm);
    {( sm->p) = (((sm->p - 7)))-1;}
    { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)];goto _again;}
  }}
	goto _again;
f18:
#line 553 "ext/dtext/dtext.rl"
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
#line 565 "ext/dtext/dtext.rl"
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
{( ((int *)sm->stack->data))[( sm->top)++] =  sm->cs;  sm->cs = 311; goto _again;}}
  }}
	goto _again;
f23:
#line 570 "ext/dtext/dtext.rl"
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
f22:
#line 580 "ext/dtext/dtext.rl"
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
f75:
#line 590 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    g_debug("inline 0");
    g_debug("  return");

    ( sm->p)--;
    { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)];goto _again;}
  }}
	goto _again;
f74:
#line 626 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    g_debug("inline char: %c", (*( sm->p)));
    append_c_html_escaped(sm, (*( sm->p)));
  }}
	goto _again;
f100:
#line 347 "ext/dtext/dtext.rl"
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
f99:
#line 489 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    dstack_rewind(sm);
    {( sm->p) = (( sm->a1 - 1))-1;}
    { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)];goto _again;}
  }}
	goto _again;
f98:
#line 502 "ext/dtext/dtext.rl"
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
f78:
#line 598 "ext/dtext/dtext.rl"
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
f77:
#line 610 "ext/dtext/dtext.rl"
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
f80:
#line 622 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append_c(sm, ' ');
  }}
	goto _again;
f81:
#line 626 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    g_debug("inline char: %c", (*( sm->p)));
    append_c_html_escaped(sm, (*( sm->p)));
  }}
	goto _again;
f16:
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
f15:
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
f11:
#line 610 "ext/dtext/dtext.rl"
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
f12:
#line 626 "ext/dtext/dtext.rl"
	{{( sm->p) = ((( sm->te)))-1;}{
    g_debug("inline char: %c", (*( sm->p)));
    append_c_html_escaped(sm, (*( sm->p)));
  }}
	goto _again;
f9:
#line 1 "NONE"
	{	switch( ( sm->act) ) {
	case 21:
	{{( sm->p) = ((( sm->te)))-1;}
    append_segment_html_escaped(sm, sm->ts, sm->te - 1);
  }
	break;
	case 22:
	{{( sm->p) = ((( sm->te)))-1;}
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
	}
	}
	goto _again;
f40:
#line 633 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    if (dstack_check(sm, BLOCK_CODE)) {
      dstack_rewind(sm);
    } else {
      append(sm, true, "[/code]");
    }
    { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)];goto _again;}
  }}
	goto _again;
f102:
#line 642 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    ( sm->p)--;
    { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)];goto _again;}
  }}
	goto _again;
f101:
#line 647 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    append_c_html_escaped(sm, (*( sm->p)));
  }}
	goto _again;
f103:
#line 647 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append_c_html_escaped(sm, (*( sm->p)));
  }}
	goto _again;
f39:
#line 647 "ext/dtext/dtext.rl"
	{{( sm->p) = ((( sm->te)))-1;}{
    append_c_html_escaped(sm, (*( sm->p)));
  }}
	goto _again;
f42:
#line 653 "ext/dtext/dtext.rl"
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
f105:
#line 666 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    ( sm->p)--;
    { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)];goto _again;}
  }}
	goto _again;
f104:
#line 671 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    append_c_html_escaped(sm, (*( sm->p)));
  }}
	goto _again;
f106:
#line 671 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append_c_html_escaped(sm, (*( sm->p)));
  }}
	goto _again;
f41:
#line 671 "ext/dtext/dtext.rl"
	{{( sm->p) = ((( sm->te)))-1;}{
    append_c_html_escaped(sm, (*( sm->p)));
  }}
	goto _again;
f51:
#line 677 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_push(sm, &BLOCK_THEAD);
    append_block(sm, "<thead>");
  }}
	goto _again;
f46:
#line 682 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    if (dstack_check(sm, BLOCK_THEAD)) {
      dstack_pop(sm);
      append_block(sm, "</thead>");
    } else {
      append(sm, true, "[/thead]");
    }
  }}
	goto _again;
f48:
#line 691 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_push(sm, &BLOCK_TBODY);
    append_block(sm, "<tbody>");
  }}
	goto _again;
f45:
#line 696 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    if (dstack_check(sm, BLOCK_TBODY)) {
      dstack_pop(sm);
      append_block(sm, "</tbody>");
    } else {
      append(sm, true, "[/tbody]");
    }
  }}
	goto _again;
f50:
#line 705 "ext/dtext/dtext.rl"
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
{( ((int *)sm->stack->data))[( sm->top)++] =  sm->cs;  sm->cs = 274; goto _again;}}
  }}
	goto _again;
f52:
#line 711 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_push(sm, &BLOCK_TR);
    append_block(sm, "<tr>");
  }}
	goto _again;
f47:
#line 716 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    if (dstack_check(sm, BLOCK_TR)) {
      dstack_pop(sm);
      append_block(sm, "</tr>");
    } else {
      append(sm, true, "[/tr]");
    }
  }}
	goto _again;
f49:
#line 725 "ext/dtext/dtext.rl"
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
{( ((int *)sm->stack->data))[( sm->top)++] =  sm->cs;  sm->cs = 274; goto _again;}}
  }}
	goto _again;
f44:
#line 731 "ext/dtext/dtext.rl"
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
f108:
#line 741 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    ( sm->p)--;
    { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)];goto _again;}
  }}
	goto _again;
f107:
#line 746 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;}
	goto _again;
f109:
#line 746 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;}
	goto _again;
f43:
#line 746 "ext/dtext/dtext.rl"
	{{( sm->p) = ((( sm->te)))-1;}}
	goto _again;
f111:
#line 789 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_close_list(sm);
    {( sm->p) = (( sm->ts))-1;}
    { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)];goto _again;}
  }}
	goto _again;
f110:
#line 797 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_rewind(sm);
    ( sm->p)--;
    { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)];goto _again;}
  }}
	goto _again;
f113:
#line 797 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    dstack_rewind(sm);
    ( sm->p)--;
    { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)];goto _again;}
  }}
	goto _again;
f55:
#line 797 "ext/dtext/dtext.rl"
	{{( sm->p) = ((( sm->te)))-1;}{
    dstack_rewind(sm);
    ( sm->p)--;
    { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)];goto _again;}
  }}
	goto _again;
f53:
#line 1 "NONE"
	{	switch( ( sm->act) ) {
	case 67:
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
#line 868 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    g_debug("block [/spoiler]");
    dstack_close_before_block(sm);
    if (dstack_check(sm, BLOCK_SPOILER)) {
      g_debug("  rewind");
      dstack_rewind(sm);
    }
  }}
	goto _again;
f7:
#line 915 "ext/dtext/dtext.rl"
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
{( ((int *)sm->stack->data))[( sm->top)++] =  sm->cs;  sm->cs = 313; goto _again;}}
  }}
	goto _again;
f8:
#line 922 "ext/dtext/dtext.rl"
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
{( ((int *)sm->stack->data))[( sm->top)++] =  sm->cs;  sm->cs = 274; goto _again;}}
  }}
	goto _again;
f59:
#line 938 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    g_debug("block 0");
    g_debug("  close dstack");
    dstack_close(sm);
  }}
	goto _again;
f58:
#line 961 "ext/dtext/dtext.rl"
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
{( ((int *)sm->stack->data))[( sm->top)++] =  sm->cs;  sm->cs = 274; goto _again;}}
  }}
	goto _again;
f70:
#line 805 "ext/dtext/dtext.rl"
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
{( ((int *)sm->stack->data))[( sm->top)++] =  sm->cs;  sm->cs = 274; goto _again;}}
  }}
	goto _again;
f68:
#line 850 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    g_debug("block [quote]");
    g_debug("  push quote");
    g_debug("  print <blockquote>");
    dstack_close_before_block(sm);
    dstack_push(sm, &BLOCK_QUOTE);
    append_block(sm, "<blockquote>");
  }}
	goto _again;
f69:
#line 859 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    g_debug("block [spoiler]");
    g_debug("  push spoiler");
    g_debug("  print <div>");
    dstack_close_before_block(sm);
    dstack_push(sm, &BLOCK_SPOILER);
    append_block(sm, "<div class=\"spoiler\">");
  }}
	goto _again;
f64:
#line 877 "ext/dtext/dtext.rl"
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
{( ((int *)sm->stack->data))[( sm->top)++] =  sm->cs;  sm->cs = 309; goto _again;}}
  }}
	goto _again;
f66:
#line 885 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    g_debug("block [expand]");
    dstack_close_before_block(sm);
    dstack_push(sm, &BLOCK_EXPAND);
    append_block(sm, "<div class=\"expandable\"><div class=\"expandable-header\">");
    append_block(sm, "<input type=\"button\" value=\"Show\" class=\"expandable-button\"/></div>");
    append_block(sm, "<div class=\"expandable-content\">");
  }}
	goto _again;
f65:
#line 894 "ext/dtext/dtext.rl"
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
f67:
#line 906 "ext/dtext/dtext.rl"
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
{( ((int *)sm->stack->data))[( sm->top)++] =  sm->cs;  sm->cs = 311; goto _again;}}
  }}
	goto _again;
f62:
#line 961 "ext/dtext/dtext.rl"
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
{( ((int *)sm->stack->data))[( sm->top)++] =  sm->cs;  sm->cs = 274; goto _again;}}
  }}
	goto _again;
f2:
#line 961 "ext/dtext/dtext.rl"
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
{( ((int *)sm->stack->data))[( sm->top)++] =  sm->cs;  sm->cs = 274; goto _again;}}
  }}
	goto _again;
f0:
#line 1 "NONE"
	{	switch( ( sm->act) ) {
	case 82:
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
	case 83:
	{{( sm->p) = ((( sm->te)))-1;}
    g_debug("block newline");
  }
	break;
	}
	}
	goto _again;
f94:
#line 100 "ext/dtext/dtext.rl"
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
f89:
#line 100 "ext/dtext/dtext.rl"
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
f95:
#line 100 "ext/dtext/dtext.rl"
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
f88:
#line 100 "ext/dtext/dtext.rl"
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
f93:
#line 100 "ext/dtext/dtext.rl"
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
f97:
#line 100 "ext/dtext/dtext.rl"
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
f87:
#line 100 "ext/dtext/dtext.rl"
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
f90:
#line 100 "ext/dtext/dtext.rl"
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
f91:
#line 100 "ext/dtext/dtext.rl"
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
f83:
#line 100 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
#line 372 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
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
  }}
	goto _again;
f86:
#line 100 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
#line 1 "NONE"
	{	switch( ( sm->act) ) {
	case 21:
	{{( sm->p) = ((( sm->te)))-1;}
    append_segment_html_escaped(sm, sm->ts, sm->te - 1);
  }
	break;
	case 22:
	{{( sm->p) = ((( sm->te)))-1;}
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
	}
	}
	goto _again;
f13:
#line 108 "ext/dtext/dtext.rl"
	{
  sm->b2 = sm->p;
}
#line 339 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    append(sm, true, "<a href=\"");
    append_segment_html_escaped(sm, sm->b1, sm->b2 - 1);
    append(sm, true, "\">");
    append_segment_html_escaped(sm, sm->a1, sm->a2 - 1);
    append(sm, true, "</a>");
  }}
	goto _again;
f96:
#line 108 "ext/dtext/dtext.rl"
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
f92:
#line 108 "ext/dtext/dtext.rl"
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
f82:
#line 108 "ext/dtext/dtext.rl"
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
    append_segment_html_escaped(sm, sm->a1, sm->a2 - 1);
    append(sm, true, "</a>");

    if (sm->b) {
      append_c_html_escaped(sm, (*( sm->p)));
    }
  }}
	goto _again;
f79:
#line 108 "ext/dtext/dtext.rl"
	{
  sm->b2 = sm->p;
}
#line 393 "ext/dtext/dtext.rl"
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
     sm->cs = 315;
  }}
	goto _again;
f114:
#line 108 "ext/dtext/dtext.rl"
	{
  sm->b2 = sm->p;
}
#line 750 "ext/dtext/dtext.rl"
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
{( ((int *)sm->stack->data))[( sm->top)++] =  sm->cs;  sm->cs = 274; goto _again;}}
  }}
	goto _again;
f63:
#line 108 "ext/dtext/dtext.rl"
	{
  sm->b2 = sm->p;
}
#line 928 "ext/dtext/dtext.rl"
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
{( ((int *)sm->stack->data))[( sm->top)++] =  sm->cs;  sm->cs = 315; goto _again;}}
  }}
	goto _again;
f14:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 96 "ext/dtext/dtext.rl"
	{
  sm->a1 = sm->p;
}
	goto _again;
f85:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 368 "ext/dtext/dtext.rl"
	{( sm->act) = 21;}
	goto _again;
f84:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 372 "ext/dtext/dtext.rl"
	{( sm->act) = 22;}
	goto _again;
f10:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 598 "ext/dtext/dtext.rl"
	{( sm->act) = 45;}
	goto _again;
f76:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 610 "ext/dtext/dtext.rl"
	{( sm->act) = 46;}
	goto _again;
f54:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 789 "ext/dtext/dtext.rl"
	{( sm->act) = 67;}
	goto _again;
f112:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 795 "ext/dtext/dtext.rl"
	{( sm->act) = 68;}
	goto _again;
f1:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 944 "ext/dtext/dtext.rl"
	{( sm->act) = 82;}
	goto _again;
f60:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 957 "ext/dtext/dtext.rl"
	{( sm->act) = 83;}
	goto _again;

_again:
	switch ( _dtext_to_state_actions[ sm->cs] ) {
	case 57:
#line 1 "NONE"
	{( sm->ts) = 0;}
	break;
#line 4090 "ext/dtext/dtext.c"
	}

	if (  sm->cs == 0 )
		goto _out;
	if ( ++( sm->p) != ( sm->pe) )
		goto _resume;
	_test_eof: {}
	if ( ( sm->p) == ( sm->eof) )
	{
	switch (  sm->cs ) {
	case 257: goto tr0;
	case 1: goto tr0;
	case 258: goto tr311;
	case 259: goto tr311;
	case 2: goto tr2;
	case 260: goto tr312;
	case 261: goto tr312;
	case 3: goto tr2;
	case 262: goto tr311;
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
	case 263: goto tr321;
	case 16: goto tr2;
	case 17: goto tr2;
	case 18: goto tr2;
	case 19: goto tr2;
	case 20: goto tr2;
	case 21: goto tr2;
	case 22: goto tr2;
	case 23: goto tr2;
	case 264: goto tr322;
	case 265: goto tr324;
	case 24: goto tr2;
	case 25: goto tr2;
	case 26: goto tr2;
	case 27: goto tr2;
	case 28: goto tr2;
	case 29: goto tr2;
	case 30: goto tr2;
	case 266: goto tr325;
	case 31: goto tr2;
	case 32: goto tr2;
	case 33: goto tr2;
	case 34: goto tr2;
	case 35: goto tr2;
	case 267: goto tr326;
	case 36: goto tr2;
	case 37: goto tr2;
	case 38: goto tr2;
	case 39: goto tr2;
	case 40: goto tr2;
	case 41: goto tr2;
	case 42: goto tr2;
	case 268: goto tr327;
	case 43: goto tr2;
	case 44: goto tr2;
	case 45: goto tr2;
	case 46: goto tr2;
	case 47: goto tr2;
	case 48: goto tr2;
	case 269: goto tr311;
	case 49: goto tr2;
	case 270: goto tr329;
	case 272: goto tr332;
	case 275: goto tr351;
	case 276: goto tr354;
	case 60: goto tr67;
	case 61: goto tr69;
	case 62: goto tr69;
	case 277: goto tr355;
	case 278: goto tr355;
	case 279: goto tr357;
	case 280: goto tr358;
	case 63: goto tr74;
	case 64: goto tr74;
	case 65: goto tr74;
	case 66: goto tr74;
	case 281: goto tr360;
	case 67: goto tr74;
	case 68: goto tr74;
	case 69: goto tr74;
	case 70: goto tr74;
	case 71: goto tr74;
	case 72: goto tr74;
	case 73: goto tr74;
	case 74: goto tr74;
	case 75: goto tr74;
	case 76: goto tr74;
	case 77: goto tr74;
	case 78: goto tr74;
	case 79: goto tr74;
	case 80: goto tr74;
	case 81: goto tr74;
	case 82: goto tr74;
	case 83: goto tr74;
	case 282: goto tr358;
	case 283: goto tr362;
	case 284: goto tr365;
	case 285: goto tr358;
	case 84: goto tr74;
	case 85: goto tr74;
	case 86: goto tr74;
	case 87: goto tr74;
	case 88: goto tr74;
	case 89: goto tr74;
	case 90: goto tr74;
	case 286: goto tr367;
	case 287: goto tr358;
	case 91: goto tr74;
	case 92: goto tr74;
	case 93: goto tr74;
	case 94: goto tr74;
	case 95: goto tr74;
	case 96: goto tr74;
	case 97: goto tr74;
	case 98: goto tr74;
	case 288: goto tr370;
	case 289: goto tr358;
	case 99: goto tr74;
	case 100: goto tr74;
	case 101: goto tr74;
	case 102: goto tr74;
	case 103: goto tr74;
	case 104: goto tr74;
	case 290: goto tr373;
	case 291: goto tr358;
	case 105: goto tr74;
	case 106: goto tr74;
	case 107: goto tr74;
	case 108: goto tr74;
	case 109: goto tr74;
	case 110: goto tr74;
	case 292: goto tr376;
	case 293: goto tr358;
	case 111: goto tr74;
	case 112: goto tr74;
	case 113: goto tr74;
	case 114: goto tr74;
	case 115: goto tr74;
	case 116: goto tr74;
	case 294: goto tr380;
	case 117: goto tr133;
	case 118: goto tr133;
	case 295: goto tr383;
	case 119: goto tr74;
	case 120: goto tr74;
	case 121: goto tr74;
	case 122: goto tr74;
	case 123: goto tr74;
	case 296: goto tr385;
	case 124: goto tr74;
	case 125: goto tr74;
	case 126: goto tr74;
	case 127: goto tr74;
	case 297: goto tr387;
	case 298: goto tr358;
	case 128: goto tr74;
	case 129: goto tr74;
	case 130: goto tr74;
	case 131: goto tr74;
	case 132: goto tr74;
	case 133: goto tr74;
	case 299: goto tr390;
	case 134: goto tr152;
	case 135: goto tr152;
	case 300: goto tr393;
	case 301: goto tr358;
	case 136: goto tr74;
	case 137: goto tr74;
	case 138: goto tr74;
	case 139: goto tr74;
	case 140: goto tr74;
	case 302: goto tr396;
	case 303: goto tr358;
	case 141: goto tr74;
	case 142: goto tr74;
	case 143: goto tr74;
	case 144: goto tr74;
	case 145: goto tr74;
	case 146: goto tr74;
	case 147: goto tr74;
	case 148: goto tr74;
	case 149: goto tr74;
	case 150: goto tr74;
	case 151: goto tr74;
	case 152: goto tr74;
	case 153: goto tr74;
	case 154: goto tr74;
	case 304: goto tr408;
	case 155: goto tr74;
	case 156: goto tr74;
	case 157: goto tr74;
	case 158: goto tr74;
	case 159: goto tr74;
	case 160: goto tr74;
	case 161: goto tr74;
	case 162: goto tr74;
	case 163: goto tr74;
	case 164: goto tr74;
	case 165: goto tr74;
	case 166: goto tr74;
	case 167: goto tr74;
	case 168: goto tr74;
	case 169: goto tr74;
	case 170: goto tr74;
	case 171: goto tr74;
	case 172: goto tr74;
	case 173: goto tr74;
	case 174: goto tr74;
	case 175: goto tr74;
	case 176: goto tr74;
	case 177: goto tr74;
	case 178: goto tr74;
	case 179: goto tr74;
	case 180: goto tr74;
	case 181: goto tr74;
	case 182: goto tr74;
	case 183: goto tr74;
	case 184: goto tr74;
	case 185: goto tr74;
	case 186: goto tr74;
	case 187: goto tr74;
	case 188: goto tr74;
	case 189: goto tr74;
	case 190: goto tr74;
	case 191: goto tr74;
	case 192: goto tr74;
	case 193: goto tr74;
	case 194: goto tr74;
	case 195: goto tr74;
	case 196: goto tr74;
	case 197: goto tr74;
	case 198: goto tr74;
	case 199: goto tr74;
	case 200: goto tr74;
	case 201: goto tr74;
	case 202: goto tr74;
	case 305: goto tr358;
	case 203: goto tr74;
	case 306: goto tr411;
	case 204: goto tr74;
	case 205: goto tr74;
	case 206: goto tr74;
	case 207: goto tr74;
	case 208: goto tr74;
	case 209: goto tr74;
	case 307: goto tr413;
	case 210: goto tr74;
	case 308: goto tr358;
	case 211: goto tr74;
	case 212: goto tr74;
	case 213: goto tr74;
	case 310: goto tr418;
	case 214: goto tr247;
	case 215: goto tr247;
	case 216: goto tr247;
	case 217: goto tr247;
	case 218: goto tr247;
	case 312: goto tr423;
	case 219: goto tr253;
	case 220: goto tr253;
	case 221: goto tr253;
	case 222: goto tr253;
	case 223: goto tr253;
	case 224: goto tr253;
	case 225: goto tr253;
	case 226: goto tr253;
	case 314: goto tr428;
	case 227: goto tr262;
	case 228: goto tr262;
	case 229: goto tr262;
	case 230: goto tr262;
	case 231: goto tr262;
	case 232: goto tr262;
	case 233: goto tr262;
	case 234: goto tr262;
	case 235: goto tr262;
	case 236: goto tr262;
	case 237: goto tr262;
	case 238: goto tr262;
	case 239: goto tr262;
	case 240: goto tr262;
	case 241: goto tr262;
	case 242: goto tr262;
	case 243: goto tr262;
	case 244: goto tr262;
	case 245: goto tr262;
	case 246: goto tr262;
	case 247: goto tr262;
	case 248: goto tr262;
	case 249: goto tr262;
	case 250: goto tr262;
	case 251: goto tr262;
	case 252: goto tr262;
	case 316: goto tr296;
	case 253: goto tr296;
	case 317: goto tr437;
	case 318: goto tr437;
	case 254: goto tr298;
	case 319: goto tr438;
	case 320: goto tr438;
	case 255: goto tr298;
	}
	}

	_out: {}
	}

#line 1334 "ext/dtext/dtext.rl"

  dstack_close(sm);

  encoding = rb_enc_find("utf-8");
  ret = rb_enc_str_new(sm->output->str, sm->output->len, encoding);

  free_machine(sm);

  return ret;
}

void Init_dtext() {
  VALUE mDTextRagel = rb_define_module("DTextRagel");
  rb_define_singleton_method(mDTextRagel, "parse", parse, -1);
}
