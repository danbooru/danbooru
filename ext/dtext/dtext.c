
#line 1 "ext/dtext/dtext.rl"
// situationally print newlines to make the generated html
// easier to read
#define PRETTY_PRINT 0

#include <ruby.h>
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


#line 1001 "ext/dtext/dtext.rl"



#line 70 "ext/dtext/dtext.c"
static const int dtext_start = 247;
static const int dtext_first_final = 247;
static const int dtext_error = -1;

static const int dtext_en_inline = 263;
static const int dtext_en_code = 299;
static const int dtext_en_nodtext = 301;
static const int dtext_en_table = 303;
static const int dtext_en_list = 305;
static const int dtext_en_main = 247;


#line 1004 "ext/dtext/dtext.rl"

static inline void underscore_string(char * str, size_t len) {
  for (size_t i=0; i<len; ++i) {
    if (str[i] == ' ') {
      str[i] = '_';
    }
  }
}

static inline void append(StateMachine * sm, bool is_markup, const char * s) {
  if (!(is_markup && sm->f_strip)) {
    sm->output = g_string_append(sm->output, s);
  }
}

static inline void append_newline(StateMachine * sm) {
#if (PRETTY_PRINT)
  g_string_append_c(sm->output, '\n');
#endif
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

  GString * segment_string = g_string_new_len(a, b - a + 1);
  char * segment = g_uri_escape_string(segment_string->str, ":/=&#%?", TRUE);
  sm->output = g_string_append(sm->output, segment);
  g_string_free(segment_string, TRUE);
  g_free(segment);
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

static inline void append_closing_p(StateMachine * sm) {
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

static void dstack_rewind(StateMachine * sm) {
  int * element = dstack_pop(sm);

  if (element == NULL) {
    return;
  }

  if (*element == BLOCK_P) {
    append_closing_p(sm);
    append_newline(sm);

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
    append_newline(sm);

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
    append_newline(sm);

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
    append_newline(sm);

  } else if (*element == BLOCK_LI) {
    append_block(sm, "</li>");
    append_newline(sm);
  }
}

static void dstack_close(StateMachine * sm) {
  while (dstack_peek(sm) != NULL) {
    dstack_rewind(sm);
  }
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

  
#line 387 "ext/dtext/dtext.c"
	{
	 sm->cs = dtext_start;
	( sm->top) = 0;
	( sm->ts) = 0;
	( sm->te) = 0;
	( sm->act) = 0;
	}

#line 1307 "ext/dtext/dtext.rl"
  
#line 398 "ext/dtext/dtext.c"
	{
	if ( ( sm->p) == ( sm->pe) )
		goto _test_eof;
	goto _resume;

_again:
	switch (  sm->cs ) {
		case 247: goto st247;
		case 248: goto st248;
		case 0: goto st0;
		case 249: goto st249;
		case 250: goto st250;
		case 1: goto st1;
		case 251: goto st251;
		case 252: goto st252;
		case 2: goto st2;
		case 253: goto st253;
		case 3: goto st3;
		case 4: goto st4;
		case 5: goto st5;
		case 6: goto st6;
		case 7: goto st7;
		case 8: goto st8;
		case 9: goto st9;
		case 10: goto st10;
		case 11: goto st11;
		case 12: goto st12;
		case 13: goto st13;
		case 14: goto st14;
		case 254: goto st254;
		case 15: goto st15;
		case 16: goto st16;
		case 17: goto st17;
		case 18: goto st18;
		case 19: goto st19;
		case 20: goto st20;
		case 21: goto st21;
		case 22: goto st22;
		case 255: goto st255;
		case 256: goto st256;
		case 23: goto st23;
		case 24: goto st24;
		case 25: goto st25;
		case 26: goto st26;
		case 27: goto st27;
		case 28: goto st28;
		case 29: goto st29;
		case 257: goto st257;
		case 30: goto st30;
		case 31: goto st31;
		case 32: goto st32;
		case 33: goto st33;
		case 34: goto st34;
		case 258: goto st258;
		case 35: goto st35;
		case 36: goto st36;
		case 37: goto st37;
		case 38: goto st38;
		case 39: goto st39;
		case 40: goto st40;
		case 41: goto st41;
		case 259: goto st259;
		case 42: goto st42;
		case 43: goto st43;
		case 44: goto st44;
		case 45: goto st45;
		case 46: goto st46;
		case 47: goto st47;
		case 260: goto st260;
		case 48: goto st48;
		case 49: goto st49;
		case 261: goto st261;
		case 262: goto st262;
		case 263: goto st263;
		case 264: goto st264;
		case 265: goto st265;
		case 50: goto st50;
		case 51: goto st51;
		case 52: goto st52;
		case 266: goto st266;
		case 267: goto st267;
		case 268: goto st268;
		case 269: goto st269;
		case 53: goto st53;
		case 54: goto st54;
		case 55: goto st55;
		case 56: goto st56;
		case 270: goto st270;
		case 57: goto st57;
		case 58: goto st58;
		case 59: goto st59;
		case 60: goto st60;
		case 61: goto st61;
		case 62: goto st62;
		case 63: goto st63;
		case 64: goto st64;
		case 65: goto st65;
		case 66: goto st66;
		case 67: goto st67;
		case 68: goto st68;
		case 69: goto st69;
		case 70: goto st70;
		case 71: goto st71;
		case 72: goto st72;
		case 73: goto st73;
		case 271: goto st271;
		case 272: goto st272;
		case 273: goto st273;
		case 274: goto st274;
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
		case 275: goto st275;
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
		case 135: goto st135;
		case 276: goto st276;
		case 136: goto st136;
		case 137: goto st137;
		case 138: goto st138;
		case 139: goto st139;
		case 140: goto st140;
		case 141: goto st141;
		case 142: goto st142;
		case 277: goto st277;
		case 278: goto st278;
		case 143: goto st143;
		case 144: goto st144;
		case 145: goto st145;
		case 146: goto st146;
		case 147: goto st147;
		case 148: goto st148;
		case 149: goto st149;
		case 150: goto st150;
		case 279: goto st279;
		case 280: goto st280;
		case 151: goto st151;
		case 152: goto st152;
		case 153: goto st153;
		case 154: goto st154;
		case 155: goto st155;
		case 156: goto st156;
		case 281: goto st281;
		case 282: goto st282;
		case 157: goto st157;
		case 158: goto st158;
		case 283: goto st283;
		case 284: goto st284;
		case 159: goto st159;
		case 160: goto st160;
		case 161: goto st161;
		case 162: goto st162;
		case 163: goto st163;
		case 164: goto st164;
		case 285: goto st285;
		case 165: goto st165;
		case 286: goto st286;
		case 166: goto st166;
		case 167: goto st167;
		case 168: goto st168;
		case 169: goto st169;
		case 170: goto st170;
		case 171: goto st171;
		case 287: goto st287;
		case 288: goto st288;
		case 172: goto st172;
		case 173: goto st173;
		case 174: goto st174;
		case 175: goto st175;
		case 176: goto st176;
		case 177: goto st177;
		case 289: goto st289;
		case 178: goto st178;
		case 179: goto st179;
		case 290: goto st290;
		case 180: goto st180;
		case 181: goto st181;
		case 182: goto st182;
		case 183: goto st183;
		case 184: goto st184;
		case 291: goto st291;
		case 185: goto st185;
		case 186: goto st186;
		case 187: goto st187;
		case 188: goto st188;
		case 292: goto st292;
		case 293: goto st293;
		case 189: goto st189;
		case 190: goto st190;
		case 191: goto st191;
		case 192: goto st192;
		case 193: goto st193;
		case 194: goto st194;
		case 294: goto st294;
		case 195: goto st195;
		case 196: goto st196;
		case 295: goto st295;
		case 296: goto st296;
		case 197: goto st197;
		case 198: goto st198;
		case 199: goto st199;
		case 200: goto st200;
		case 201: goto st201;
		case 297: goto st297;
		case 298: goto st298;
		case 202: goto st202;
		case 203: goto st203;
		case 204: goto st204;
		case 299: goto st299;
		case 300: goto st300;
		case 205: goto st205;
		case 206: goto st206;
		case 207: goto st207;
		case 208: goto st208;
		case 209: goto st209;
		case 301: goto st301;
		case 302: goto st302;
		case 210: goto st210;
		case 211: goto st211;
		case 212: goto st212;
		case 213: goto st213;
		case 214: goto st214;
		case 215: goto st215;
		case 216: goto st216;
		case 217: goto st217;
		case 303: goto st303;
		case 304: goto st304;
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
		case 305: goto st305;
		case 306: goto st306;
		case 244: goto st244;
		case 307: goto st307;
		case 308: goto st308;
		case 245: goto st245;
		case 309: goto st309;
		case 310: goto st310;
		case 246: goto st246;
	default: break;
	}

	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof;
_resume:
	switch (  sm->cs )
	{
tr0:
#line 1 "NONE"
	{	switch( ( sm->act) ) {
	case 78:
	{{( sm->p) = ((( sm->te)))-1;}
    g_debug("block newline2");
    if (dstack_check(sm, BLOCK_P)) {
      g_debug("  pop p");
      dstack_rewind(sm);
    }
  }
	break;
	case 79:
	{{( sm->p) = ((( sm->te)))-1;}
    g_debug("block newline");
  }
	break;
	}
	}
	goto st247;
tr2:
#line 985 "ext/dtext/dtext.rl"
	{{( sm->p) = ((( sm->te)))-1;}{
    g_debug("block c: %c", (*( sm->p)));
    ( sm->p)--;

    if (g_queue_is_empty(sm->dstack) || dstack_check(sm, BLOCK_QUOTE) || dstack_check(sm, BLOCK_SPOILER) || dstack_check(sm, BLOCK_EXPAND)) {
      g_debug("  push p");
      g_debug("  print <p>");
      dstack_push(sm, &BLOCK_P);
      append_newline(sm);
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
{( ((int *)sm->stack->data))[( sm->top)++] = 247; goto st263;}}
  }}
	goto st247;
tr14:
#line 884 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    if (dstack_check(sm, BLOCK_P)) {
      dstack_rewind(sm);
    }

    if (dstack_check(sm, BLOCK_SPOILER)) {
      dstack_rewind(sm);
    }
  }}
	goto st247;
tr53:
#line 938 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_push(sm, &BLOCK_TABLE);
    append_newline(sm);
    append_newline(sm);
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
{( ((int *)sm->stack->data))[( sm->top)++] = 247; goto st303;}}
  }}
	goto st247;
tr54:
#line 946 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_push(sm, &BLOCK_TN);
    append_newline(sm);
    append_newline(sm);
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
{( ((int *)sm->stack->data))[( sm->top)++] = 247; goto st263;}}
  }}
	goto st247;
tr296:
#line 985 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    g_debug("block c: %c", (*( sm->p)));
    ( sm->p)--;

    if (g_queue_is_empty(sm->dstack) || dstack_check(sm, BLOCK_QUOTE) || dstack_check(sm, BLOCK_SPOILER) || dstack_check(sm, BLOCK_EXPAND)) {
      g_debug("  push p");
      g_debug("  print <p>");
      dstack_push(sm, &BLOCK_P);
      append_newline(sm);
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
{( ((int *)sm->stack->data))[( sm->top)++] = 247; goto st263;}}
  }}
	goto st247;
tr297:
#line 967 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    g_debug("block 0");
    g_debug("  close dstack");
    dstack_close(sm);
  }}
	goto st247;
tr304:
#line 985 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    g_debug("block c: %c", (*( sm->p)));
    ( sm->p)--;

    if (g_queue_is_empty(sm->dstack) || dstack_check(sm, BLOCK_QUOTE) || dstack_check(sm, BLOCK_SPOILER) || dstack_check(sm, BLOCK_EXPAND)) {
      g_debug("  push p");
      g_debug("  print <p>");
      dstack_push(sm, &BLOCK_P);
      append_newline(sm);
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
{( ((int *)sm->stack->data))[( sm->top)++] = 247; goto st263;}}
  }}
	goto st247;
tr305:
#line 100 "ext/dtext/dtext.rl"
	{
  sm->b2 = sm->p;
}
#line 954 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    g_debug("block list");
    sm->list_nest = 0;
    sm->list_mode = true;
    if (dstack_check(sm, BLOCK_P)) {
      g_debug("  pop dstack");
      dstack_rewind(sm);
    }
    g_debug("  call list");
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
{( ((int *)sm->stack->data))[( sm->top)++] = 247; goto st305;}}
  }}
	goto st247;
tr314:
#line 894 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    dstack_push(sm, &BLOCK_CODE);
    append_newline(sm);
    append_newline(sm);
    append_block(sm, "<pre>");
    append_newline(sm);
    {
  size_t len = sm->stack->len;

  if (len > MAX_STACK_DEPTH) {
    free_machine(sm);
    rb_raise(rb_eSyntaxError, "too many nested elements");
  }

  if (sm->top >= len) {
    sm->stack = g_array_set_size(sm->stack, len + 16);
  }
{( ((int *)sm->stack->data))[( sm->top)++] = 247; goto st299;}}
  }}
	goto st247;
tr315:
#line 916 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    dstack_push(sm, &BLOCK_EXPAND);
    dstack_push(sm, &BLOCK_P);
    append_newline(sm);
    append_newline(sm);
    append_block(sm, "<div class=\"expandable\"><div class=\"expandable-header\">");
    append(sm, true, "<span>");
    append_segment_html_escaped(sm, sm->a1, sm->a2 - 1);
    append(sm, true, "</span>");
    append_block(sm, "<input type=\"button\" value=\"Show\" class=\"expandable-button\"/></div>");
    append_block(sm, "<div class=\"expandable-content\">");
    append_newline(sm);
    {
  size_t len = sm->stack->len;

  if (len > MAX_STACK_DEPTH) {
    free_machine(sm);
    rb_raise(rb_eSyntaxError, "too many nested elements");
  }

  if (sm->top >= len) {
    sm->stack = g_array_set_size(sm->stack, len + 16);
  }
{( ((int *)sm->stack->data))[( sm->top)++] = 247; goto st263;}}
  }}
	goto st247;
tr317:
#line 903 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    dstack_push(sm, &BLOCK_EXPAND);
    dstack_push(sm, &BLOCK_P);
    append_newline(sm);
    append_newline(sm);
    append_block(sm, "<div class=\"expandable\"><div class=\"expandable-header\">");
    append_block(sm, "<input type=\"button\" value=\"Show\" class=\"expandable-button\"/></div>");
    append_block(sm, "<div class=\"expandable-content\">");
    append_block(sm, "<p>");
    append_newline(sm);
    {
  size_t len = sm->stack->len;

  if (len > MAX_STACK_DEPTH) {
    free_machine(sm);
    rb_raise(rb_eSyntaxError, "too many nested elements");
  }

  if (sm->top >= len) {
    sm->stack = g_array_set_size(sm->stack, len + 16);
  }
{( ((int *)sm->stack->data))[( sm->top)++] = 247; goto st263;}}
  }}
	goto st247;
tr318:
#line 931 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    dstack_push(sm, &BLOCK_NODTEXT);
    append_newline(sm);
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
{( ((int *)sm->stack->data))[( sm->top)++] = 247; goto st301;}}
  }}
	goto st247;
tr319:
#line 851 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    g_debug("block [quote]");
    g_debug("  push quote");
    g_debug("  push p");
    g_debug("  print <blockquote>");
    g_debug("  print <p>");
    g_debug("  call inline");

    dstack_push(sm, &BLOCK_QUOTE);
    dstack_push(sm, &BLOCK_P);
    append_newline(sm);
    append_newline(sm);
    append_block(sm, "<blockquote><p>");
    append_newline(sm);
    {
  size_t len = sm->stack->len;

  if (len > MAX_STACK_DEPTH) {
    free_machine(sm);
    rb_raise(rb_eSyntaxError, "too many nested elements");
  }

  if (sm->top >= len) {
    sm->stack = g_array_set_size(sm->stack, len + 16);
  }
{( ((int *)sm->stack->data))[( sm->top)++] = 247; goto st263;}}
  }}
	goto st247;
tr320:
#line 868 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    g_debug("block [spoiler]");
    g_debug("  push spoiler");
    g_debug("  push p");
    g_debug("  print <div>");
    g_debug("  print <p>");
    g_debug("  call inline");
    dstack_push(sm, &BLOCK_SPOILER);
    dstack_push(sm, &BLOCK_P);
    append_newline(sm);
    append_newline(sm);
    append_block(sm, "<div class=\"spoiler\"><p>");
    append_newline(sm);
    {
  size_t len = sm->stack->len;

  if (len > MAX_STACK_DEPTH) {
    free_machine(sm);
    rb_raise(rb_eSyntaxError, "too many nested elements");
  }

  if (sm->top >= len) {
    sm->stack = g_array_set_size(sm->stack, len + 16);
  }
{( ((int *)sm->stack->data))[( sm->top)++] = 247; goto st263;}}
  }}
	goto st247;
tr322:
#line 100 "ext/dtext/dtext.rl"
	{
  sm->b2 = sm->p;
}
#line 827 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    char header = *sm->a1;

    if (sm->f_inline) {
      header = '6';
    }

    append_newline(sm);
    append_newline(sm);
    if (!sm->f_strip) {
      append(sm, true, "<h");
      append_c(sm, header);
      append_c(sm, '>');
    }
    append_segment(sm, false, sm->b1, sm->b2 - 1);
    if (!sm->f_strip) {
      append(sm, true, "</h");
      append_c(sm, header);
      append_c(sm, '>');
    }
    append_newline(sm);
    append_newline(sm);
  }}
	goto st247;
st247:
#line 1 "NONE"
	{( sm->ts) = 0;}
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof247;
case 247:
#line 1 "NONE"
	{( sm->ts) = ( sm->p);}
#line 1114 "ext/dtext/dtext.c"
	switch( (*( sm->p)) ) {
		case 0: goto tr297;
		case 10: goto tr298;
		case 13: goto st249;
		case 42: goto tr300;
		case 91: goto tr301;
		case 104: goto tr302;
	}
	goto tr296;
tr1:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 973 "ext/dtext/dtext.rl"
	{( sm->act) = 78;}
	goto st248;
tr298:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 981 "ext/dtext/dtext.rl"
	{( sm->act) = 79;}
	goto st248;
st248:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof248;
case 248:
#line 1140 "ext/dtext/dtext.c"
	switch( (*( sm->p)) ) {
		case 10: goto tr1;
		case 13: goto st0;
	}
	goto tr0;
st0:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof0;
case 0:
	if ( (*( sm->p)) == 10 )
		goto tr1;
	goto tr0;
st249:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof249;
case 249:
	if ( (*( sm->p)) == 10 )
		goto tr298;
	goto tr304;
tr300:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 88 "ext/dtext/dtext.rl"
	{
  sm->a1 = sm->p;
}
	goto st250;
st250:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof250;
case 250:
#line 1172 "ext/dtext/dtext.c"
	switch( (*( sm->p)) ) {
		case 9: goto tr5;
		case 32: goto tr5;
		case 42: goto st2;
	}
	goto tr304;
tr5:
#line 92 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
	goto st1;
st1:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1;
case 1:
#line 1189 "ext/dtext/dtext.c"
	switch( (*( sm->p)) ) {
		case 0: goto tr2;
		case 9: goto tr4;
		case 10: goto tr2;
		case 32: goto tr4;
	}
	goto tr3;
tr3:
#line 96 "ext/dtext/dtext.rl"
	{
  sm->b1 = sm->p;
}
	goto st251;
st251:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof251;
case 251:
#line 1207 "ext/dtext/dtext.c"
	switch( (*( sm->p)) ) {
		case 0: goto tr305;
		case 10: goto tr305;
	}
	goto st251;
tr4:
#line 96 "ext/dtext/dtext.rl"
	{
  sm->b1 = sm->p;
}
	goto st252;
st252:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof252;
case 252:
#line 1223 "ext/dtext/dtext.c"
	switch( (*( sm->p)) ) {
		case 0: goto tr305;
		case 9: goto tr4;
		case 10: goto tr305;
		case 32: goto tr4;
	}
	goto tr3;
st2:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof2;
case 2:
	switch( (*( sm->p)) ) {
		case 9: goto tr5;
		case 32: goto tr5;
		case 42: goto st2;
	}
	goto tr2;
tr301:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
	goto st253;
st253:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof253;
case 253:
#line 1249 "ext/dtext/dtext.c"
	switch( (*( sm->p)) ) {
		case 47: goto st3;
		case 99: goto st11;
		case 101: goto st15;
		case 110: goto st23;
		case 113: goto st30;
		case 115: goto st35;
		case 116: goto st42;
	}
	goto tr304;
st3:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof3;
case 3:
	if ( (*( sm->p)) == 115 )
		goto st4;
	goto tr2;
st4:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof4;
case 4:
	if ( (*( sm->p)) == 112 )
		goto st5;
	goto tr2;
st5:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof5;
case 5:
	if ( (*( sm->p)) == 111 )
		goto st6;
	goto tr2;
st6:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof6;
case 6:
	if ( (*( sm->p)) == 105 )
		goto st7;
	goto tr2;
st7:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof7;
case 7:
	if ( (*( sm->p)) == 108 )
		goto st8;
	goto tr2;
st8:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof8;
case 8:
	if ( (*( sm->p)) == 101 )
		goto st9;
	goto tr2;
st9:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof9;
case 9:
	if ( (*( sm->p)) == 114 )
		goto st10;
	goto tr2;
st10:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof10;
case 10:
	if ( (*( sm->p)) == 93 )
		goto tr14;
	goto tr2;
st11:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof11;
case 11:
	if ( (*( sm->p)) == 111 )
		goto st12;
	goto tr2;
st12:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof12;
case 12:
	if ( (*( sm->p)) == 100 )
		goto st13;
	goto tr2;
st13:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof13;
case 13:
	if ( (*( sm->p)) == 101 )
		goto st14;
	goto tr2;
st14:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof14;
case 14:
	if ( (*( sm->p)) == 93 )
		goto st254;
	goto tr2;
st254:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof254;
case 254:
	if ( (*( sm->p)) == 32 )
		goto st254;
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto st254;
	goto tr314;
st15:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof15;
case 15:
	if ( (*( sm->p)) == 120 )
		goto st16;
	goto tr2;
st16:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof16;
case 16:
	if ( (*( sm->p)) == 112 )
		goto st17;
	goto tr2;
st17:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof17;
case 17:
	if ( (*( sm->p)) == 97 )
		goto st18;
	goto tr2;
st18:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof18;
case 18:
	if ( (*( sm->p)) == 110 )
		goto st19;
	goto tr2;
st19:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof19;
case 19:
	if ( (*( sm->p)) == 100 )
		goto st20;
	goto tr2;
st20:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof20;
case 20:
	switch( (*( sm->p)) ) {
		case 61: goto st21;
		case 93: goto st256;
	}
	goto tr2;
st21:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof21;
case 21:
	if ( (*( sm->p)) == 93 )
		goto tr2;
	goto tr26;
tr26:
#line 88 "ext/dtext/dtext.rl"
	{
  sm->a1 = sm->p;
}
	goto st22;
st22:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof22;
case 22:
#line 1414 "ext/dtext/dtext.c"
	if ( (*( sm->p)) == 93 )
		goto tr28;
	goto st22;
tr28:
#line 92 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
	goto st255;
st255:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof255;
case 255:
#line 1428 "ext/dtext/dtext.c"
	if ( (*( sm->p)) == 32 )
		goto st255;
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto st255;
	goto tr315;
st256:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof256;
case 256:
	if ( (*( sm->p)) == 32 )
		goto st256;
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto st256;
	goto tr317;
st23:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof23;
case 23:
	if ( (*( sm->p)) == 111 )
		goto st24;
	goto tr2;
st24:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof24;
case 24:
	if ( (*( sm->p)) == 100 )
		goto st25;
	goto tr2;
st25:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof25;
case 25:
	if ( (*( sm->p)) == 116 )
		goto st26;
	goto tr2;
st26:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof26;
case 26:
	if ( (*( sm->p)) == 101 )
		goto st27;
	goto tr2;
st27:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof27;
case 27:
	if ( (*( sm->p)) == 120 )
		goto st28;
	goto tr2;
st28:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof28;
case 28:
	if ( (*( sm->p)) == 116 )
		goto st29;
	goto tr2;
st29:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof29;
case 29:
	if ( (*( sm->p)) == 93 )
		goto st257;
	goto tr2;
st257:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof257;
case 257:
	if ( (*( sm->p)) == 32 )
		goto st257;
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto st257;
	goto tr318;
st30:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof30;
case 30:
	if ( (*( sm->p)) == 117 )
		goto st31;
	goto tr2;
st31:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof31;
case 31:
	if ( (*( sm->p)) == 111 )
		goto st32;
	goto tr2;
st32:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof32;
case 32:
	if ( (*( sm->p)) == 116 )
		goto st33;
	goto tr2;
st33:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof33;
case 33:
	if ( (*( sm->p)) == 101 )
		goto st34;
	goto tr2;
st34:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof34;
case 34:
	if ( (*( sm->p)) == 93 )
		goto st258;
	goto tr2;
st258:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof258;
case 258:
	if ( (*( sm->p)) == 32 )
		goto st258;
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto st258;
	goto tr319;
st35:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof35;
case 35:
	if ( (*( sm->p)) == 112 )
		goto st36;
	goto tr2;
st36:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof36;
case 36:
	if ( (*( sm->p)) == 111 )
		goto st37;
	goto tr2;
st37:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof37;
case 37:
	if ( (*( sm->p)) == 105 )
		goto st38;
	goto tr2;
st38:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof38;
case 38:
	if ( (*( sm->p)) == 108 )
		goto st39;
	goto tr2;
st39:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof39;
case 39:
	if ( (*( sm->p)) == 101 )
		goto st40;
	goto tr2;
st40:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof40;
case 40:
	if ( (*( sm->p)) == 114 )
		goto st41;
	goto tr2;
st41:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof41;
case 41:
	if ( (*( sm->p)) == 93 )
		goto st259;
	goto tr2;
st259:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof259;
case 259:
	if ( (*( sm->p)) == 32 )
		goto st259;
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto st259;
	goto tr320;
st42:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof42;
case 42:
	switch( (*( sm->p)) ) {
		case 97: goto st43;
		case 110: goto st47;
	}
	goto tr2;
st43:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof43;
case 43:
	if ( (*( sm->p)) == 98 )
		goto st44;
	goto tr2;
st44:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof44;
case 44:
	if ( (*( sm->p)) == 108 )
		goto st45;
	goto tr2;
st45:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof45;
case 45:
	if ( (*( sm->p)) == 101 )
		goto st46;
	goto tr2;
st46:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof46;
case 46:
	if ( (*( sm->p)) == 93 )
		goto tr53;
	goto tr2;
st47:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof47;
case 47:
	if ( (*( sm->p)) == 93 )
		goto tr54;
	goto tr2;
tr302:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
	goto st260;
st260:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof260;
case 260:
#line 1655 "ext/dtext/dtext.c"
	if ( 49 <= (*( sm->p)) && (*( sm->p)) <= 54 )
		goto tr321;
	goto tr304;
tr321:
#line 88 "ext/dtext/dtext.rl"
	{
  sm->a1 = sm->p;
}
	goto st48;
st48:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof48;
case 48:
#line 1669 "ext/dtext/dtext.c"
	if ( (*( sm->p)) == 46 )
		goto tr55;
	goto tr2;
tr55:
#line 92 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
	goto st49;
st49:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof49;
case 49:
#line 1683 "ext/dtext/dtext.c"
	switch( (*( sm->p)) ) {
		case 0: goto tr2;
		case 9: goto tr57;
		case 10: goto tr2;
		case 32: goto tr57;
	}
	goto tr56;
tr56:
#line 96 "ext/dtext/dtext.rl"
	{
  sm->b1 = sm->p;
}
	goto st261;
st261:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof261;
case 261:
#line 1701 "ext/dtext/dtext.c"
	switch( (*( sm->p)) ) {
		case 0: goto tr322;
		case 10: goto tr322;
	}
	goto st261;
tr57:
#line 96 "ext/dtext/dtext.rl"
	{
  sm->b1 = sm->p;
}
	goto st262;
st262:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof262;
case 262:
#line 1717 "ext/dtext/dtext.c"
	switch( (*( sm->p)) ) {
		case 0: goto tr322;
		case 9: goto tr57;
		case 10: goto tr322;
		case 32: goto tr57;
	}
	goto tr56;
tr58:
#line 1 "NONE"
	{	switch( ( sm->act) ) {
	case 18:
	{{( sm->p) = ((( sm->te)))-1;}
    append_segment_html_escaped(sm, sm->ts, sm->te - 1);
  }
	break;
	case 19:
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
	case 42:
	{{( sm->p) = ((( sm->te)))-1;}
    g_debug("inline newline2");
    g_debug("  return");

    if (sm->list_mode) {
      if (dstack_check(sm, BLOCK_LI)) {
        dstack_rewind(sm);
      }

      sm->list_mode = false;
    }

    {( sm->p) = (( sm->ts))-1;}
    { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)];goto _again;}
  }
	break;
	case 43:
	{{( sm->p) = ((( sm->te)))-1;}
    g_debug("inline newline");

    append(sm, true, "<br>");
    append_newline(sm);
  }
	break;
	}
	}
	goto st263;
tr60:
#line 617 "ext/dtext/dtext.rl"
	{{( sm->p) = ((( sm->te)))-1;}{
    g_debug("inline newline");

    append(sm, true, "<br>");
    append_newline(sm);
  }}
	goto st263;
tr65:
#line 624 "ext/dtext/dtext.rl"
	{{( sm->p) = ((( sm->te)))-1;}{
    g_debug("inline c: %c", (*( sm->p)));
    append_c_html_escaped(sm, (*( sm->p)));
  }}
	goto st263;
tr76:
#line 100 "ext/dtext/dtext.rl"
	{
  sm->b2 = sm->p;
}
#line 321 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    append(sm, true, "<a href=\"");
    append_segment_uri_escaped(sm, sm->b1, sm->b2 - 1);
    append(sm, true, "\">");
    append_segment_html_escaped(sm, sm->a1, sm->a2 - 1);
    append(sm, true, "</a>");
  }}
	goto st263;
tr98:
#line 396 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    if (dstack_check(sm, INLINE_B)) {
      dstack_pop(sm);
      append(sm, true, "</strong>");
    } else {
      append(sm, true, "[/b]");
    }
  }}
	goto st263;
tr104:
#line 545 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    if (dstack_check(sm, BLOCK_P)) {
      append_closing_p(sm);
      append_newline(sm);
      dstack_pop(sm);
    }

    if (dstack_check(sm, BLOCK_EXPAND)) {
      append_newline(sm);
      append_block(sm, "</div></div>");
      append_newline(sm);
      append_newline(sm);
      dstack_pop(sm);
      { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)];goto _again;}
    } else {
      append_block(sm, "[/expand]");
    }
  }}
	goto st263;
tr105:
#line 410 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    if (dstack_check(sm, INLINE_I)) {
      dstack_pop(sm);
      append(sm, true, "</em>");
    } else {
      append(sm, true, "[/i]");
    }
  }}
	goto st263;
tr111:
#line 424 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    if (dstack_check(sm, INLINE_S)) {
      dstack_pop(sm);
      append(sm, true, "</s>");
    } else {
      append(sm, true, "[/s]");
    }
  }}
	goto st263;
tr118:
#line 512 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    g_debug("inline [/spoiler]");

    if (dstack_check(sm, INLINE_SPOILER)) {
      g_debug("  pop dstack");
      g_debug("  print </span>");
      dstack_pop(sm);
      append(sm, true, "</span>");
    } else if (dstack_check(sm, BLOCK_P) && dstack_check2(sm, BLOCK_SPOILER)) {
      g_debug("  pop dstack");
      g_debug("  print </p></div>");
      g_debug("  return");
      dstack_pop(sm);
      dstack_pop(sm);
      append_newline(sm);
      append_closing_p(sm);
      append_block(sm, "</div>");
      append_newline(sm);
      append_newline(sm);

      { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)];goto _again;}
    } else {
      append_block(sm, "[/spoiler]");
    }
  }}
	goto st263;
tr122:
#line 581 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    if (dstack_check(sm, BLOCK_TD)) {
      dstack_pop(sm);
      append_newline(sm);
      append_block(sm, "</td>");
      append_newline(sm);
      { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)];goto _again;}
    } else {
      append_block(sm, "[/td]");
    }
  }}
	goto st263;
tr123:
#line 569 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    if (dstack_check(sm, BLOCK_TH)) {
      dstack_pop(sm);
      append_newline(sm);
      append_block(sm, "</th>");
      append_newline(sm);
      { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)];goto _again;}
    } else {
      append_block(sm, "[/th]");
    }
  }}
	goto st263;
tr124:
#line 452 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    if (dstack_check(sm, BLOCK_TN)) {
      dstack_pop(sm);
      append_closing_p(sm);
      append_newline(sm);
      { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)];goto _again;}
    } else if (dstack_check(sm, INLINE_TN)) {
      dstack_pop(sm);
      append(sm, true, "</span>");
    } else {
      append_block(sm, "[/tn]");
    }
  }}
	goto st263;
tr125:
#line 438 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    if (dstack_check(sm, INLINE_U)) {
      dstack_pop(sm);
      append(sm, true, "</u>");
    } else {
      append(sm, true, "[/u]");
    }
  }}
	goto st263;
tr130:
#line 259 "ext/dtext/dtext.rl"
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
	goto st263;
tr134:
#line 280 "ext/dtext/dtext.rl"
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
	goto st263;
tr135:
#line 391 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_push(sm, &INLINE_B);
    append(sm, true, "<strong>");
  }}
	goto st263;
tr141:
#line 538 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    g_debug("inline [expand]");
    dstack_rewind(sm);
    {( sm->p) = (((sm->p - 7)))-1;}
    { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)];goto _again;}
  }}
	goto st263;
tr142:
#line 405 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_push(sm, &INLINE_I);
    append(sm, true, "<em>");
  }}
	goto st263;
tr149:
#line 564 "ext/dtext/dtext.rl"
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
{( ((int *)sm->stack->data))[( sm->top)++] = 263; goto st301;}}
  }}
	goto st263;
tr154:
#line 474 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    g_debug("inline [quote]");

    if (dstack_check(sm, BLOCK_P)) {
      g_debug("  pop dstack");
      g_debug("  print </p>");

      dstack_pop(sm);
      append_closing_p(sm);
      append_newline(sm);
    } 

    {( sm->p) = (( sm->ts))-1;}
    { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)];goto _again;}
  }}
	goto st263;
tr155:
#line 419 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_push(sm, &INLINE_S);
    append(sm, true, "<s>");
  }}
	goto st263;
tr162:
#line 505 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    g_debug("inline [spoiler]");
    g_debug("  push <span>");
    dstack_push(sm, &INLINE_SPOILER);
    append(sm, true, "<span class=\"spoiler\">");
  }}
	goto st263;
tr164:
#line 447 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_push(sm, &INLINE_TN);
    append(sm, true, "<span class=\"tn\">");
  }}
	goto st263;
tr165:
#line 433 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_push(sm, &INLINE_U);
    append(sm, true, "<u>");
  }}
	goto st263;
tr209:
#line 229 "ext/dtext/dtext.rl"
	{{( sm->p) = ((( sm->te)))-1;}{
    append(sm, true, "<a href=\"http://www.pixiv.net/member_illust.php?mode=medium&illust_id=");
    append_segment(sm, true, sm->a1, sm->a2 - 1);
    append(sm, true, "\">");
    append(sm, false, "pixiv #");
    append_segment(sm, false, sm->a1, sm->a2 - 1);
    append(sm, true, "</a>");
  }}
	goto st263;
tr228:
#line 162 "ext/dtext/dtext.rl"
	{{( sm->p) = ((( sm->te)))-1;}{
    append(sm, true, "<a href=\"/forum_topics/");
    append_segment(sm, true, sm->a1, sm->a2 - 1);
    append(sm, true, "\">");
    append(sm, false, "topic #");
    append_segment(sm, false, sm->a1, sm->a2 - 1);
    append(sm, true, "</a>");
  }}
	goto st263;
tr239:
#line 251 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    append(sm, true, "<a rel=\"nofollow\" href=\"/posts?tags=");
    append_segment_uri_escaped(sm, sm->a1, sm->a2 - 1);
    append(sm, true, "\">");
    append_segment_html_escaped(sm, sm->a1, sm->a2 - 1);
    append(sm, true, "</a>");
  }}
	goto st263;
tr324:
#line 624 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    g_debug("inline c: %c", (*( sm->p)));
    append_c_html_escaped(sm, (*( sm->p)));
  }}
	goto st263;
tr325:
#line 593 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    g_debug("inline 0");
    g_debug("  return");

    ( sm->p)--;
    { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)];goto _again;}
  }}
	goto st263;
tr340:
#line 617 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    g_debug("inline newline");

    append(sm, true, "<br>");
    append_newline(sm);
  }}
	goto st263;
tr343:
#line 601 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    g_debug("inline newline2");
    g_debug("  return");

    if (sm->list_mode) {
      if (dstack_check(sm, BLOCK_LI)) {
        dstack_rewind(sm);
      }

      sm->list_mode = false;
    }

    {( sm->p) = (( sm->ts))-1;}
    { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)];goto _again;}
  }}
	goto st263;
tr344:
#line 100 "ext/dtext/dtext.rl"
	{
  sm->b2 = sm->p;
}
#line 375 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    g_debug("inline list");

    if (dstack_check(sm, BLOCK_LI)) {
      g_debug("  rewind li");
      dstack_rewind(sm);
    } else if (dstack_check(sm, BLOCK_P)) {
      g_debug("  rewind p");
      dstack_rewind(sm);
    }

    g_debug("  call list");
    {( sm->p) = (( sm->ts + 1))-1;}
    {
  size_t len = sm->stack->len;

  if (len > MAX_STACK_DEPTH) {
    free_machine(sm);
    rb_raise(rb_eSyntaxError, "too many nested elements");
  }

  if (sm->top >= len) {
    sm->stack = g_array_set_size(sm->stack, len + 16);
  }
{( ((int *)sm->stack->data))[( sm->top)++] = 263; goto st305;}}
  }}
	goto st263;
tr346:
#line 624 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    g_debug("inline c: %c", (*( sm->p)));
    append_c_html_escaped(sm, (*( sm->p)));
  }}
	goto st263;
tr348:
#line 100 "ext/dtext/dtext.rl"
	{
  sm->b2 = sm->p;
}
#line 301 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    if (is_boundary_c((*( sm->p)))) {
      sm->d = 2;
      sm->b = true;
    } else {
      sm->d = 1;
      sm->b = false;
    }

    append(sm, true, "<a href=\"");
    append_segment_uri_escaped(sm, sm->b1, sm->b2 - sm->d);
    append(sm, true, "\">");
    append_segment_html_escaped(sm, sm->a1, sm->a2 - 1);
    append(sm, true, "</a>");

    if (sm->b) {
      append_c_html_escaped(sm, (*( sm->p)));
    }
  }}
	goto st263;
tr350:
#line 92 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
#line 354 "ext/dtext/dtext.rl"
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
	goto st263;
tr353:
#line 92 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
#line 1 "NONE"
	{	switch( ( sm->act) ) {
	case 18:
	{{( sm->p) = ((( sm->te)))-1;}
    append_segment_html_escaped(sm, sm->ts, sm->te - 1);
  }
	break;
	case 19:
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
	case 42:
	{{( sm->p) = ((( sm->te)))-1;}
    g_debug("inline newline2");
    g_debug("  return");

    if (sm->list_mode) {
      if (dstack_check(sm, BLOCK_LI)) {
        dstack_rewind(sm);
      }

      sm->list_mode = false;
    }

    {( sm->p) = (( sm->ts))-1;}
    { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)];goto _again;}
  }
	break;
	case 43:
	{{( sm->p) = ((( sm->te)))-1;}
    g_debug("inline newline");

    append(sm, true, "<br>");
    append_newline(sm);
  }
	break;
	}
	}
	goto st263;
tr364:
#line 490 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    g_debug("inline [/quote]");

    if (dstack_check(sm, BLOCK_P)) {
      dstack_rewind(sm);
    }

    if (dstack_check(sm, BLOCK_QUOTE)) {
      dstack_rewind(sm);
      { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)];goto _again;}
    } else {
      append_block(sm, "[/quote]");
    }
  }}
	goto st263;
tr366:
#line 92 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
#line 211 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append(sm, true, "<a href=\"/artists/");
    append_segment(sm, true, sm->a1, sm->a2 - 1);
    append(sm, true, "\">");
    append(sm, false, "artist #");
    append_segment(sm, false, sm->a1, sm->a2 - 1);
    append(sm, true, "</a>");
  }}
	goto st263;
tr369:
#line 92 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
#line 184 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append(sm, true, "<a href=\"/comments/");
    append_segment(sm, true, sm->a1, sm->a2 - 1);
    append(sm, true, "\">");
    append(sm, false, "comment #");
    append_segment(sm, false, sm->a1, sm->a2 - 1);
    append(sm, true, "</a>");
  }}
	goto st263;
tr372:
#line 92 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
#line 153 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append(sm, true, "<a href=\"/forum_posts/");
    append_segment(sm, true, sm->a1, sm->a2 - 1);
    append(sm, true, "\">");
    append(sm, false, "forum #");
    append_segment(sm, false, sm->a1, sm->a2 - 1);
    append(sm, true, "</a>");
  }}
	goto st263;
tr376:
#line 100 "ext/dtext/dtext.rl"
	{
  sm->b2 = sm->p;
}
#line 468 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    dstack_rewind(sm);
    {( sm->p) = (( sm->a1 - 1))-1;}
    { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)];goto _again;}
  }}
	goto st263;
tr378:
#line 329 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    if (is_boundary_c((*( sm->p)))) {
      sm->b = true;
      sm->d = 2;
    } else {
      sm->b = false;
      sm->d = 1;
    }

    append(sm, true, "<a href=\"");
    append_segment_uri_escaped(sm, sm->ts, sm->te - sm->d);
    append(sm, true, "\">");
    append_segment_html_escaped(sm, sm->ts, sm->te - sm->d);
    append(sm, true, "</a>");

    if (sm->b) {
      append_c_html_escaped(sm, (*( sm->p)));
    }
  }}
	goto st263;
tr380:
#line 92 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
#line 220 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append(sm, true, "<a href=\"https://github.com/r888888888/danbooru/issues/");
    append_segment(sm, true, sm->a1, sm->a2 - 1);
    append(sm, true, "\">");
    append(sm, false, "issue #");
    append_segment(sm, false, sm->a1, sm->a2 - 1);
    append(sm, true, "</a>");
  }}
	goto st263;
tr384:
#line 92 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
#line 229 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append(sm, true, "<a href=\"http://www.pixiv.net/member_illust.php?mode=medium&illust_id=");
    append_segment(sm, true, sm->a1, sm->a2 - 1);
    append(sm, true, "\">");
    append(sm, false, "pixiv #");
    append_segment(sm, false, sm->a1, sm->a2 - 1);
    append(sm, true, "</a>");
  }}
	goto st263;
tr387:
#line 100 "ext/dtext/dtext.rl"
	{
  sm->b2 = sm->p;
}
#line 238 "ext/dtext/dtext.rl"
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
	goto st263;
tr389:
#line 92 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
#line 193 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append(sm, true, "<a href=\"/pools/");
    append_segment(sm, true, sm->a1, sm->a2 - 1);
    append(sm, true, "\">");
    append(sm, false, "pool #");
    append_segment(sm, false, sm->a1, sm->a2 - 1);
    append(sm, true, "</a>");
  }}
	goto st263;
tr391:
#line 92 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
#line 144 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append(sm, true, "<a href=\"/posts/");
    append_segment(sm, true, sm->a1, sm->a2 - 1);
    append(sm, true, "\">");
    append(sm, false, "post #");
    append_segment(sm, false, sm->a1, sm->a2 - 1);
    append(sm, true, "</a>");
  }}
	goto st263;
tr394:
#line 92 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
#line 162 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append(sm, true, "<a href=\"/forum_topics/");
    append_segment(sm, true, sm->a1, sm->a2 - 1);
    append(sm, true, "\">");
    append(sm, false, "topic #");
    append_segment(sm, false, sm->a1, sm->a2 - 1);
    append(sm, true, "</a>");
  }}
	goto st263;
tr397:
#line 100 "ext/dtext/dtext.rl"
	{
  sm->b2 = sm->p;
}
#line 171 "ext/dtext/dtext.rl"
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
	goto st263;
tr400:
#line 92 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
#line 202 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append(sm, true, "<a href=\"/users/");
    append_segment(sm, true, sm->a1, sm->a2 - 1);
    append(sm, true, "\">");
    append(sm, false, "user #");
    append_segment(sm, false, sm->a1, sm->a2 - 1);
    append(sm, true, "</a>");
  }}
	goto st263;
st263:
#line 1 "NONE"
	{( sm->ts) = 0;}
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof263;
case 263:
#line 1 "NONE"
	{( sm->ts) = ( sm->p);}
#line 2548 "ext/dtext/dtext.c"
	switch( (*( sm->p)) ) {
		case 0: goto tr325;
		case 10: goto tr326;
		case 13: goto st268;
		case 34: goto tr328;
		case 64: goto st271;
		case 91: goto tr330;
		case 97: goto tr331;
		case 99: goto tr332;
		case 102: goto tr333;
		case 104: goto tr334;
		case 105: goto tr335;
		case 112: goto tr336;
		case 116: goto tr337;
		case 117: goto tr338;
		case 123: goto tr339;
	}
	goto tr324;
tr326:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 617 "ext/dtext/dtext.rl"
	{( sm->act) = 43;}
	goto st264;
st264:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof264;
case 264:
#line 2577 "ext/dtext/dtext.c"
	switch( (*( sm->p)) ) {
		case 10: goto tr59;
		case 13: goto st50;
		case 42: goto tr342;
	}
	goto tr340;
tr59:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 601 "ext/dtext/dtext.rl"
	{( sm->act) = 42;}
	goto st265;
st265:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof265;
case 265:
#line 2594 "ext/dtext/dtext.c"
	switch( (*( sm->p)) ) {
		case 10: goto tr59;
		case 13: goto st50;
	}
	goto tr343;
st50:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof50;
case 50:
	if ( (*( sm->p)) == 10 )
		goto tr59;
	goto tr58;
tr342:
#line 88 "ext/dtext/dtext.rl"
	{
  sm->a1 = sm->p;
}
	goto st51;
st51:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof51;
case 51:
#line 2617 "ext/dtext/dtext.c"
	switch( (*( sm->p)) ) {
		case 9: goto tr61;
		case 32: goto tr61;
		case 42: goto st51;
	}
	goto tr60;
tr61:
#line 92 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
	goto st52;
st52:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof52;
case 52:
#line 2634 "ext/dtext/dtext.c"
	switch( (*( sm->p)) ) {
		case 0: goto tr60;
		case 9: goto tr64;
		case 10: goto tr60;
		case 32: goto tr64;
	}
	goto tr63;
tr63:
#line 96 "ext/dtext/dtext.rl"
	{
  sm->b1 = sm->p;
}
	goto st266;
st266:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof266;
case 266:
#line 2652 "ext/dtext/dtext.c"
	switch( (*( sm->p)) ) {
		case 0: goto tr344;
		case 10: goto tr344;
	}
	goto st266;
tr64:
#line 96 "ext/dtext/dtext.rl"
	{
  sm->b1 = sm->p;
}
	goto st267;
st267:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof267;
case 267:
#line 2668 "ext/dtext/dtext.c"
	switch( (*( sm->p)) ) {
		case 0: goto tr344;
		case 9: goto tr64;
		case 10: goto tr344;
		case 32: goto tr64;
	}
	goto tr63;
st268:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof268;
case 268:
	if ( (*( sm->p)) == 10 )
		goto tr326;
	goto tr346;
tr328:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
	goto st269;
st269:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof269;
case 269:
#line 2691 "ext/dtext/dtext.c"
	if ( (*( sm->p)) == 34 )
		goto tr346;
	goto tr347;
tr347:
#line 88 "ext/dtext/dtext.rl"
	{
  sm->a1 = sm->p;
}
	goto st53;
st53:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof53;
case 53:
#line 2705 "ext/dtext/dtext.c"
	if ( (*( sm->p)) == 34 )
		goto tr67;
	goto st53;
tr67:
#line 92 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
	goto st54;
st54:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof54;
case 54:
#line 2719 "ext/dtext/dtext.c"
	if ( (*( sm->p)) == 58 )
		goto st55;
	goto tr65;
st55:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof55;
case 55:
	switch( (*( sm->p)) ) {
		case 47: goto tr69;
		case 91: goto st57;
		case 104: goto tr71;
	}
	goto tr65;
tr69:
#line 96 "ext/dtext/dtext.rl"
	{
  sm->b1 = sm->p;
}
	goto st56;
st56:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof56;
case 56:
#line 2743 "ext/dtext/dtext.c"
	if ( 33 <= (*( sm->p)) && (*( sm->p)) <= 126 )
		goto st270;
	goto tr65;
st270:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof270;
case 270:
	if ( 33 <= (*( sm->p)) && (*( sm->p)) <= 126 )
		goto st270;
	goto tr348;
st57:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof57;
case 57:
	switch( (*( sm->p)) ) {
		case 47: goto tr73;
		case 104: goto tr74;
	}
	goto tr65;
tr73:
#line 96 "ext/dtext/dtext.rl"
	{
  sm->b1 = sm->p;
}
	goto st58;
st58:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof58;
case 58:
#line 2773 "ext/dtext/dtext.c"
	if ( 33 <= (*( sm->p)) && (*( sm->p)) <= 126 )
		goto st59;
	goto tr65;
st59:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof59;
case 59:
	if ( (*( sm->p)) == 93 )
		goto tr76;
	if ( 33 <= (*( sm->p)) && (*( sm->p)) <= 126 )
		goto st59;
	goto tr65;
tr74:
#line 96 "ext/dtext/dtext.rl"
	{
  sm->b1 = sm->p;
}
	goto st60;
st60:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof60;
case 60:
#line 2796 "ext/dtext/dtext.c"
	if ( (*( sm->p)) == 116 )
		goto st61;
	goto tr65;
st61:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof61;
case 61:
	if ( (*( sm->p)) == 116 )
		goto st62;
	goto tr65;
st62:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof62;
case 62:
	if ( (*( sm->p)) == 112 )
		goto st63;
	goto tr65;
st63:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof63;
case 63:
	switch( (*( sm->p)) ) {
		case 58: goto st64;
		case 115: goto st66;
	}
	goto tr65;
st64:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof64;
case 64:
	if ( (*( sm->p)) == 47 )
		goto st65;
	goto tr65;
st65:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof65;
case 65:
	if ( (*( sm->p)) == 47 )
		goto st58;
	goto tr65;
st66:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof66;
case 66:
	if ( (*( sm->p)) == 58 )
		goto st64;
	goto tr65;
tr71:
#line 96 "ext/dtext/dtext.rl"
	{
  sm->b1 = sm->p;
}
	goto st67;
st67:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof67;
case 67:
#line 2854 "ext/dtext/dtext.c"
	if ( (*( sm->p)) == 116 )
		goto st68;
	goto tr65;
st68:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof68;
case 68:
	if ( (*( sm->p)) == 116 )
		goto st69;
	goto tr65;
st69:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof69;
case 69:
	if ( (*( sm->p)) == 112 )
		goto st70;
	goto tr65;
st70:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof70;
case 70:
	switch( (*( sm->p)) ) {
		case 58: goto st71;
		case 115: goto st73;
	}
	goto tr65;
st71:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof71;
case 71:
	if ( (*( sm->p)) == 47 )
		goto st72;
	goto tr65;
st72:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof72;
case 72:
	if ( (*( sm->p)) == 47 )
		goto st56;
	goto tr65;
st73:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof73;
case 73:
	if ( (*( sm->p)) == 58 )
		goto st71;
	goto tr65;
st271:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof271;
case 271:
	if ( 33 <= (*( sm->p)) && (*( sm->p)) <= 126 )
		goto tr349;
	goto tr346;
tr349:
#line 88 "ext/dtext/dtext.rl"
	{
  sm->a1 = sm->p;
}
	goto st272;
st272:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof272;
case 272:
#line 2919 "ext/dtext/dtext.c"
	if ( (*( sm->p)) == 64 )
		goto tr352;
	if ( 33 <= (*( sm->p)) && (*( sm->p)) <= 126 )
		goto tr351;
	goto tr350;
tr351:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 354 "ext/dtext/dtext.rl"
	{( sm->act) = 19;}
	goto st273;
tr352:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 350 "ext/dtext/dtext.rl"
	{( sm->act) = 18;}
	goto st273;
st273:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof273;
case 273:
#line 2941 "ext/dtext/dtext.c"
	if ( 33 <= (*( sm->p)) && (*( sm->p)) <= 126 )
		goto tr351;
	goto tr353;
tr330:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
	goto st274;
st274:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof274;
case 274:
#line 2953 "ext/dtext/dtext.c"
	switch( (*( sm->p)) ) {
		case 47: goto st74;
		case 91: goto st100;
		case 98: goto st106;
		case 101: goto st107;
		case 105: goto st113;
		case 110: goto st114;
		case 113: goto st121;
		case 115: goto st126;
		case 116: goto st133;
		case 117: goto st135;
	}
	goto tr346;
st74:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof74;
case 74:
	switch( (*( sm->p)) ) {
		case 98: goto st75;
		case 101: goto st76;
		case 105: goto st82;
		case 113: goto st83;
		case 115: goto st88;
		case 116: goto st95;
		case 117: goto st99;
	}
	goto tr65;
st75:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof75;
case 75:
	if ( (*( sm->p)) == 93 )
		goto tr98;
	goto tr65;
st76:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof76;
case 76:
	if ( (*( sm->p)) == 120 )
		goto st77;
	goto tr65;
st77:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof77;
case 77:
	if ( (*( sm->p)) == 112 )
		goto st78;
	goto tr65;
st78:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof78;
case 78:
	if ( (*( sm->p)) == 97 )
		goto st79;
	goto tr65;
st79:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof79;
case 79:
	if ( (*( sm->p)) == 110 )
		goto st80;
	goto tr65;
st80:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof80;
case 80:
	if ( (*( sm->p)) == 100 )
		goto st81;
	goto tr65;
st81:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof81;
case 81:
	if ( (*( sm->p)) == 93 )
		goto tr104;
	goto tr65;
st82:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof82;
case 82:
	if ( (*( sm->p)) == 93 )
		goto tr105;
	goto tr65;
st83:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof83;
case 83:
	if ( (*( sm->p)) == 117 )
		goto st84;
	goto tr65;
st84:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof84;
case 84:
	if ( (*( sm->p)) == 111 )
		goto st85;
	goto tr65;
st85:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof85;
case 85:
	if ( (*( sm->p)) == 116 )
		goto st86;
	goto tr65;
st86:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof86;
case 86:
	if ( (*( sm->p)) == 101 )
		goto st87;
	goto tr65;
st87:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof87;
case 87:
	if ( (*( sm->p)) == 93 )
		goto st275;
	goto tr65;
st275:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof275;
case 275:
	if ( (*( sm->p)) == 32 )
		goto st275;
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto st275;
	goto tr364;
st88:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof88;
case 88:
	switch( (*( sm->p)) ) {
		case 93: goto tr111;
		case 112: goto st89;
	}
	goto tr65;
st89:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof89;
case 89:
	if ( (*( sm->p)) == 111 )
		goto st90;
	goto tr65;
st90:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof90;
case 90:
	if ( (*( sm->p)) == 105 )
		goto st91;
	goto tr65;
st91:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof91;
case 91:
	if ( (*( sm->p)) == 108 )
		goto st92;
	goto tr65;
st92:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof92;
case 92:
	if ( (*( sm->p)) == 101 )
		goto st93;
	goto tr65;
st93:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof93;
case 93:
	if ( (*( sm->p)) == 114 )
		goto st94;
	goto tr65;
st94:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof94;
case 94:
	if ( (*( sm->p)) == 93 )
		goto tr118;
	goto tr65;
st95:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof95;
case 95:
	switch( (*( sm->p)) ) {
		case 100: goto st96;
		case 104: goto st97;
		case 110: goto st98;
	}
	goto tr65;
st96:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof96;
case 96:
	if ( (*( sm->p)) == 93 )
		goto tr122;
	goto tr65;
st97:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof97;
case 97:
	if ( (*( sm->p)) == 93 )
		goto tr123;
	goto tr65;
st98:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof98;
case 98:
	if ( (*( sm->p)) == 93 )
		goto tr124;
	goto tr65;
st99:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof99;
case 99:
	if ( (*( sm->p)) == 93 )
		goto tr125;
	goto tr65;
st100:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof100;
case 100:
	switch( (*( sm->p)) ) {
		case 93: goto tr65;
		case 124: goto tr65;
	}
	goto tr126;
tr126:
#line 88 "ext/dtext/dtext.rl"
	{
  sm->a1 = sm->p;
}
	goto st101;
st101:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof101;
case 101:
#line 3189 "ext/dtext/dtext.c"
	switch( (*( sm->p)) ) {
		case 93: goto tr128;
		case 124: goto tr129;
	}
	goto st101;
tr128:
#line 92 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
	goto st102;
st102:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof102;
case 102:
#line 3205 "ext/dtext/dtext.c"
	if ( (*( sm->p)) == 93 )
		goto tr130;
	goto tr65;
tr129:
#line 92 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
	goto st103;
st103:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof103;
case 103:
#line 3219 "ext/dtext/dtext.c"
	if ( (*( sm->p)) == 93 )
		goto tr65;
	goto tr131;
tr131:
#line 96 "ext/dtext/dtext.rl"
	{
  sm->b1 = sm->p;
}
	goto st104;
st104:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof104;
case 104:
#line 3233 "ext/dtext/dtext.c"
	if ( (*( sm->p)) == 93 )
		goto tr133;
	goto st104;
tr133:
#line 100 "ext/dtext/dtext.rl"
	{
  sm->b2 = sm->p;
}
	goto st105;
st105:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof105;
case 105:
#line 3247 "ext/dtext/dtext.c"
	if ( (*( sm->p)) == 93 )
		goto tr134;
	goto tr65;
st106:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof106;
case 106:
	if ( (*( sm->p)) == 93 )
		goto tr135;
	goto tr65;
st107:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof107;
case 107:
	if ( (*( sm->p)) == 120 )
		goto st108;
	goto tr65;
st108:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof108;
case 108:
	if ( (*( sm->p)) == 112 )
		goto st109;
	goto tr65;
st109:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof109;
case 109:
	if ( (*( sm->p)) == 97 )
		goto st110;
	goto tr65;
st110:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof110;
case 110:
	if ( (*( sm->p)) == 110 )
		goto st111;
	goto tr65;
st111:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof111;
case 111:
	if ( (*( sm->p)) == 100 )
		goto st112;
	goto tr65;
st112:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof112;
case 112:
	if ( (*( sm->p)) == 93 )
		goto tr141;
	goto tr65;
st113:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof113;
case 113:
	if ( (*( sm->p)) == 93 )
		goto tr142;
	goto tr65;
st114:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof114;
case 114:
	if ( (*( sm->p)) == 111 )
		goto st115;
	goto tr65;
st115:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof115;
case 115:
	if ( (*( sm->p)) == 100 )
		goto st116;
	goto tr65;
st116:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof116;
case 116:
	if ( (*( sm->p)) == 116 )
		goto st117;
	goto tr65;
st117:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof117;
case 117:
	if ( (*( sm->p)) == 101 )
		goto st118;
	goto tr65;
st118:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof118;
case 118:
	if ( (*( sm->p)) == 120 )
		goto st119;
	goto tr65;
st119:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof119;
case 119:
	if ( (*( sm->p)) == 116 )
		goto st120;
	goto tr65;
st120:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof120;
case 120:
	if ( (*( sm->p)) == 93 )
		goto tr149;
	goto tr65;
st121:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof121;
case 121:
	if ( (*( sm->p)) == 117 )
		goto st122;
	goto tr65;
st122:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof122;
case 122:
	if ( (*( sm->p)) == 111 )
		goto st123;
	goto tr65;
st123:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof123;
case 123:
	if ( (*( sm->p)) == 116 )
		goto st124;
	goto tr65;
st124:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof124;
case 124:
	if ( (*( sm->p)) == 101 )
		goto st125;
	goto tr65;
st125:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof125;
case 125:
	if ( (*( sm->p)) == 93 )
		goto tr154;
	goto tr65;
st126:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof126;
case 126:
	switch( (*( sm->p)) ) {
		case 93: goto tr155;
		case 112: goto st127;
	}
	goto tr65;
st127:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof127;
case 127:
	if ( (*( sm->p)) == 111 )
		goto st128;
	goto tr65;
st128:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof128;
case 128:
	if ( (*( sm->p)) == 105 )
		goto st129;
	goto tr65;
st129:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof129;
case 129:
	if ( (*( sm->p)) == 108 )
		goto st130;
	goto tr65;
st130:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof130;
case 130:
	if ( (*( sm->p)) == 101 )
		goto st131;
	goto tr65;
st131:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof131;
case 131:
	if ( (*( sm->p)) == 114 )
		goto st132;
	goto tr65;
st132:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof132;
case 132:
	if ( (*( sm->p)) == 93 )
		goto tr162;
	goto tr65;
st133:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof133;
case 133:
	if ( (*( sm->p)) == 110 )
		goto st134;
	goto tr65;
st134:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof134;
case 134:
	if ( (*( sm->p)) == 93 )
		goto tr164;
	goto tr65;
st135:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof135;
case 135:
	if ( (*( sm->p)) == 93 )
		goto tr165;
	goto tr65;
tr331:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
	goto st276;
st276:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof276;
case 276:
#line 3471 "ext/dtext/dtext.c"
	if ( (*( sm->p)) == 114 )
		goto st136;
	goto tr346;
st136:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof136;
case 136:
	if ( (*( sm->p)) == 116 )
		goto st137;
	goto tr65;
st137:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof137;
case 137:
	if ( (*( sm->p)) == 105 )
		goto st138;
	goto tr65;
st138:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof138;
case 138:
	if ( (*( sm->p)) == 115 )
		goto st139;
	goto tr65;
st139:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof139;
case 139:
	if ( (*( sm->p)) == 116 )
		goto st140;
	goto tr65;
st140:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof140;
case 140:
	if ( (*( sm->p)) == 32 )
		goto st141;
	goto tr65;
st141:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof141;
case 141:
	if ( (*( sm->p)) == 35 )
		goto st142;
	goto tr65;
st142:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof142;
case 142:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr172;
	goto tr65;
tr172:
#line 88 "ext/dtext/dtext.rl"
	{
  sm->a1 = sm->p;
}
	goto st277;
st277:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof277;
case 277:
#line 3534 "ext/dtext/dtext.c"
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto st277;
	goto tr366;
tr332:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
	goto st278;
st278:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof278;
case 278:
#line 3546 "ext/dtext/dtext.c"
	if ( (*( sm->p)) == 111 )
		goto st143;
	goto tr346;
st143:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof143;
case 143:
	if ( (*( sm->p)) == 109 )
		goto st144;
	goto tr65;
st144:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof144;
case 144:
	if ( (*( sm->p)) == 109 )
		goto st145;
	goto tr65;
st145:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof145;
case 145:
	if ( (*( sm->p)) == 101 )
		goto st146;
	goto tr65;
st146:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof146;
case 146:
	if ( (*( sm->p)) == 110 )
		goto st147;
	goto tr65;
st147:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof147;
case 147:
	if ( (*( sm->p)) == 116 )
		goto st148;
	goto tr65;
st148:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof148;
case 148:
	if ( (*( sm->p)) == 32 )
		goto st149;
	goto tr65;
st149:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof149;
case 149:
	if ( (*( sm->p)) == 35 )
		goto st150;
	goto tr65;
st150:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof150;
case 150:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr180;
	goto tr65;
tr180:
#line 88 "ext/dtext/dtext.rl"
	{
  sm->a1 = sm->p;
}
	goto st279;
st279:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof279;
case 279:
#line 3616 "ext/dtext/dtext.c"
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto st279;
	goto tr369;
tr333:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
	goto st280;
st280:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof280;
case 280:
#line 3628 "ext/dtext/dtext.c"
	if ( (*( sm->p)) == 111 )
		goto st151;
	goto tr346;
st151:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof151;
case 151:
	if ( (*( sm->p)) == 114 )
		goto st152;
	goto tr65;
st152:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof152;
case 152:
	if ( (*( sm->p)) == 117 )
		goto st153;
	goto tr65;
st153:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof153;
case 153:
	if ( (*( sm->p)) == 109 )
		goto st154;
	goto tr65;
st154:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof154;
case 154:
	if ( (*( sm->p)) == 32 )
		goto st155;
	goto tr65;
st155:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof155;
case 155:
	if ( (*( sm->p)) == 35 )
		goto st156;
	goto tr65;
st156:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof156;
case 156:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr186;
	goto tr65;
tr186:
#line 88 "ext/dtext/dtext.rl"
	{
  sm->a1 = sm->p;
}
	goto st281;
st281:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof281;
case 281:
#line 3684 "ext/dtext/dtext.c"
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto st281;
	goto tr372;
tr334:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
	goto st282;
st282:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof282;
case 282:
#line 3696 "ext/dtext/dtext.c"
	if ( (*( sm->p)) == 116 )
		goto st159;
	if ( 49 <= (*( sm->p)) && (*( sm->p)) <= 54 )
		goto tr374;
	goto tr346;
tr374:
#line 88 "ext/dtext/dtext.rl"
	{
  sm->a1 = sm->p;
}
	goto st157;
st157:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof157;
case 157:
#line 3712 "ext/dtext/dtext.c"
	if ( (*( sm->p)) == 46 )
		goto tr187;
	goto tr65;
tr187:
#line 92 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
	goto st158;
st158:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof158;
case 158:
#line 3726 "ext/dtext/dtext.c"
	switch( (*( sm->p)) ) {
		case 0: goto tr65;
		case 9: goto tr189;
		case 10: goto tr65;
		case 32: goto tr189;
	}
	goto tr188;
tr188:
#line 96 "ext/dtext/dtext.rl"
	{
  sm->b1 = sm->p;
}
	goto st283;
st283:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof283;
case 283:
#line 3744 "ext/dtext/dtext.c"
	switch( (*( sm->p)) ) {
		case 0: goto tr376;
		case 10: goto tr376;
	}
	goto st283;
tr189:
#line 96 "ext/dtext/dtext.rl"
	{
  sm->b1 = sm->p;
}
	goto st284;
st284:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof284;
case 284:
#line 3760 "ext/dtext/dtext.c"
	switch( (*( sm->p)) ) {
		case 0: goto tr376;
		case 9: goto tr189;
		case 10: goto tr376;
		case 32: goto tr189;
	}
	goto tr188;
st159:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof159;
case 159:
	if ( (*( sm->p)) == 116 )
		goto st160;
	goto tr65;
st160:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof160;
case 160:
	if ( (*( sm->p)) == 112 )
		goto st161;
	goto tr65;
st161:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof161;
case 161:
	switch( (*( sm->p)) ) {
		case 58: goto st162;
		case 115: goto st165;
	}
	goto tr65;
st162:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof162;
case 162:
	if ( (*( sm->p)) == 47 )
		goto st163;
	goto tr65;
st163:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof163;
case 163:
	if ( (*( sm->p)) == 47 )
		goto st164;
	goto tr65;
st164:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof164;
case 164:
	if ( 33 <= (*( sm->p)) && (*( sm->p)) <= 126 )
		goto st285;
	goto tr65;
st285:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof285;
case 285:
	if ( 33 <= (*( sm->p)) && (*( sm->p)) <= 126 )
		goto st285;
	goto tr378;
st165:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof165;
case 165:
	if ( (*( sm->p)) == 58 )
		goto st162;
	goto tr65;
tr335:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
	goto st286;
st286:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof286;
case 286:
#line 3834 "ext/dtext/dtext.c"
	if ( (*( sm->p)) == 115 )
		goto st166;
	goto tr346;
st166:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof166;
case 166:
	if ( (*( sm->p)) == 115 )
		goto st167;
	goto tr65;
st167:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof167;
case 167:
	if ( (*( sm->p)) == 117 )
		goto st168;
	goto tr65;
st168:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof168;
case 168:
	if ( (*( sm->p)) == 101 )
		goto st169;
	goto tr65;
st169:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof169;
case 169:
	if ( (*( sm->p)) == 32 )
		goto st170;
	goto tr65;
st170:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof170;
case 170:
	if ( (*( sm->p)) == 35 )
		goto st171;
	goto tr65;
st171:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof171;
case 171:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr202;
	goto tr65;
tr202:
#line 88 "ext/dtext/dtext.rl"
	{
  sm->a1 = sm->p;
}
	goto st287;
st287:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof287;
case 287:
#line 3890 "ext/dtext/dtext.c"
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto st287;
	goto tr380;
tr336:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
	goto st288;
st288:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof288;
case 288:
#line 3902 "ext/dtext/dtext.c"
	switch( (*( sm->p)) ) {
		case 105: goto st172;
		case 111: goto st180;
	}
	goto tr346;
st172:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof172;
case 172:
	if ( (*( sm->p)) == 120 )
		goto st173;
	goto tr65;
st173:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof173;
case 173:
	if ( (*( sm->p)) == 105 )
		goto st174;
	goto tr65;
st174:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof174;
case 174:
	if ( (*( sm->p)) == 118 )
		goto st175;
	goto tr65;
st175:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof175;
case 175:
	if ( (*( sm->p)) == 32 )
		goto st176;
	goto tr65;
st176:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof176;
case 176:
	if ( (*( sm->p)) == 35 )
		goto st177;
	goto tr65;
st177:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof177;
case 177:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr208;
	goto tr65;
tr208:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 88 "ext/dtext/dtext.rl"
	{
  sm->a1 = sm->p;
}
	goto st289;
tr386:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
	goto st289;
st289:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof289;
case 289:
#line 3966 "ext/dtext/dtext.c"
	if ( (*( sm->p)) == 47 )
		goto tr385;
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr386;
	goto tr384;
tr385:
#line 92 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
	goto st178;
st178:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof178;
case 178:
#line 3982 "ext/dtext/dtext.c"
	if ( (*( sm->p)) == 112 )
		goto st179;
	goto tr209;
st179:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof179;
case 179:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr211;
	goto tr209;
tr211:
#line 96 "ext/dtext/dtext.rl"
	{
  sm->b1 = sm->p;
}
	goto st290;
st290:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof290;
case 290:
#line 4003 "ext/dtext/dtext.c"
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto st290;
	goto tr387;
st180:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof180;
case 180:
	switch( (*( sm->p)) ) {
		case 111: goto st181;
		case 115: goto st185;
	}
	goto tr65;
st181:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof181;
case 181:
	if ( (*( sm->p)) == 108 )
		goto st182;
	goto tr65;
st182:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof182;
case 182:
	if ( (*( sm->p)) == 32 )
		goto st183;
	goto tr65;
st183:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof183;
case 183:
	if ( (*( sm->p)) == 35 )
		goto st184;
	goto tr65;
st184:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof184;
case 184:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr217;
	goto tr65;
tr217:
#line 88 "ext/dtext/dtext.rl"
	{
  sm->a1 = sm->p;
}
	goto st291;
st291:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof291;
case 291:
#line 4054 "ext/dtext/dtext.c"
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto st291;
	goto tr389;
st185:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof185;
case 185:
	if ( (*( sm->p)) == 116 )
		goto st186;
	goto tr65;
st186:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof186;
case 186:
	if ( (*( sm->p)) == 32 )
		goto st187;
	goto tr65;
st187:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof187;
case 187:
	if ( (*( sm->p)) == 35 )
		goto st188;
	goto tr65;
st188:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof188;
case 188:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr221;
	goto tr65;
tr221:
#line 88 "ext/dtext/dtext.rl"
	{
  sm->a1 = sm->p;
}
	goto st292;
st292:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof292;
case 292:
#line 4096 "ext/dtext/dtext.c"
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto st292;
	goto tr391;
tr337:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
	goto st293;
st293:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof293;
case 293:
#line 4108 "ext/dtext/dtext.c"
	if ( (*( sm->p)) == 111 )
		goto st189;
	goto tr346;
st189:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof189;
case 189:
	if ( (*( sm->p)) == 112 )
		goto st190;
	goto tr65;
st190:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof190;
case 190:
	if ( (*( sm->p)) == 105 )
		goto st191;
	goto tr65;
st191:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof191;
case 191:
	if ( (*( sm->p)) == 99 )
		goto st192;
	goto tr65;
st192:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof192;
case 192:
	if ( (*( sm->p)) == 32 )
		goto st193;
	goto tr65;
st193:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof193;
case 193:
	if ( (*( sm->p)) == 35 )
		goto st194;
	goto tr65;
st194:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof194;
case 194:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr227;
	goto tr65;
tr227:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 88 "ext/dtext/dtext.rl"
	{
  sm->a1 = sm->p;
}
	goto st294;
tr396:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
	goto st294;
st294:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof294;
case 294:
#line 4170 "ext/dtext/dtext.c"
	if ( (*( sm->p)) == 47 )
		goto tr395;
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr396;
	goto tr394;
tr395:
#line 92 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
	goto st195;
st195:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof195;
case 195:
#line 4186 "ext/dtext/dtext.c"
	if ( (*( sm->p)) == 112 )
		goto st196;
	goto tr228;
st196:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof196;
case 196:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr230;
	goto tr228;
tr230:
#line 96 "ext/dtext/dtext.rl"
	{
  sm->b1 = sm->p;
}
	goto st295;
st295:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof295;
case 295:
#line 4207 "ext/dtext/dtext.c"
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto st295;
	goto tr397;
tr338:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
	goto st296;
st296:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof296;
case 296:
#line 4219 "ext/dtext/dtext.c"
	if ( (*( sm->p)) == 115 )
		goto st197;
	goto tr346;
st197:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof197;
case 197:
	if ( (*( sm->p)) == 101 )
		goto st198;
	goto tr65;
st198:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof198;
case 198:
	if ( (*( sm->p)) == 114 )
		goto st199;
	goto tr65;
st199:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof199;
case 199:
	if ( (*( sm->p)) == 32 )
		goto st200;
	goto tr65;
st200:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof200;
case 200:
	if ( (*( sm->p)) == 35 )
		goto st201;
	goto tr65;
st201:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof201;
case 201:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr235;
	goto tr65;
tr235:
#line 88 "ext/dtext/dtext.rl"
	{
  sm->a1 = sm->p;
}
	goto st297;
st297:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof297;
case 297:
#line 4268 "ext/dtext/dtext.c"
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto st297;
	goto tr400;
tr339:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
	goto st298;
st298:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof298;
case 298:
#line 4280 "ext/dtext/dtext.c"
	if ( (*( sm->p)) == 123 )
		goto st202;
	goto tr346;
st202:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof202;
case 202:
	if ( (*( sm->p)) == 125 )
		goto tr65;
	goto tr236;
tr236:
#line 88 "ext/dtext/dtext.rl"
	{
  sm->a1 = sm->p;
}
	goto st203;
st203:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof203;
case 203:
#line 4301 "ext/dtext/dtext.c"
	if ( (*( sm->p)) == 125 )
		goto tr238;
	goto st203;
tr238:
#line 92 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
	goto st204;
st204:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof204;
case 204:
#line 4315 "ext/dtext/dtext.c"
	if ( (*( sm->p)) == 125 )
		goto tr239;
	goto tr65;
tr240:
#line 645 "ext/dtext/dtext.rl"
	{{( sm->p) = ((( sm->te)))-1;}{
    append_c_html_escaped(sm, (*( sm->p)));
  }}
	goto st299;
tr245:
#line 631 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    if (dstack_check(sm, BLOCK_CODE)) {
      dstack_rewind(sm);
    } else {
      append(sm, true, "[/code]");
    }
    { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)];goto _again;}
  }}
	goto st299;
tr403:
#line 645 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    append_c_html_escaped(sm, (*( sm->p)));
  }}
	goto st299;
tr404:
#line 640 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    ( sm->p)--;
    { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)];goto _again;}
  }}
	goto st299;
tr406:
#line 645 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append_c_html_escaped(sm, (*( sm->p)));
  }}
	goto st299;
st299:
#line 1 "NONE"
	{( sm->ts) = 0;}
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof299;
case 299:
#line 1 "NONE"
	{( sm->ts) = ( sm->p);}
#line 4363 "ext/dtext/dtext.c"
	switch( (*( sm->p)) ) {
		case 0: goto tr404;
		case 91: goto tr405;
	}
	goto tr403;
tr405:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
	goto st300;
st300:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof300;
case 300:
#line 4377 "ext/dtext/dtext.c"
	if ( (*( sm->p)) == 47 )
		goto st205;
	goto tr406;
st205:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof205;
case 205:
	if ( (*( sm->p)) == 99 )
		goto st206;
	goto tr240;
st206:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof206;
case 206:
	if ( (*( sm->p)) == 111 )
		goto st207;
	goto tr240;
st207:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof207;
case 207:
	if ( (*( sm->p)) == 100 )
		goto st208;
	goto tr240;
st208:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof208;
case 208:
	if ( (*( sm->p)) == 101 )
		goto st209;
	goto tr240;
st209:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof209;
case 209:
	if ( (*( sm->p)) == 93 )
		goto tr245;
	goto tr240;
tr246:
#line 672 "ext/dtext/dtext.rl"
	{{( sm->p) = ((( sm->te)))-1;}{
    append_c_html_escaped(sm, (*( sm->p)));
  }}
	goto st301;
tr254:
#line 651 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    if (dstack_check(sm, BLOCK_NODTEXT)) {
      dstack_pop(sm);
      append_newline(sm);
      append_closing_p(sm);
      append_newline(sm);
      append_newline(sm);
      { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)];goto _again;}
    } else if (dstack_check(sm, INLINE_NODTEXT)) {
      dstack_pop(sm);
      { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)];goto _again;}
    } else {
      append(sm, true, "[/nodtext]");
    }
  }}
	goto st301;
tr408:
#line 672 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    append_c_html_escaped(sm, (*( sm->p)));
  }}
	goto st301;
tr409:
#line 667 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    ( sm->p)--;
    { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)];goto _again;}
  }}
	goto st301;
tr411:
#line 672 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append_c_html_escaped(sm, (*( sm->p)));
  }}
	goto st301;
st301:
#line 1 "NONE"
	{( sm->ts) = 0;}
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof301;
case 301:
#line 1 "NONE"
	{( sm->ts) = ( sm->p);}
#line 4467 "ext/dtext/dtext.c"
	switch( (*( sm->p)) ) {
		case 0: goto tr409;
		case 91: goto tr410;
	}
	goto tr408;
tr410:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
	goto st302;
st302:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof302;
case 302:
#line 4481 "ext/dtext/dtext.c"
	if ( (*( sm->p)) == 47 )
		goto st210;
	goto tr411;
st210:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof210;
case 210:
	if ( (*( sm->p)) == 110 )
		goto st211;
	goto tr246;
st211:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof211;
case 211:
	if ( (*( sm->p)) == 111 )
		goto st212;
	goto tr246;
st212:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof212;
case 212:
	if ( (*( sm->p)) == 100 )
		goto st213;
	goto tr246;
st213:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof213;
case 213:
	if ( (*( sm->p)) == 116 )
		goto st214;
	goto tr246;
st214:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof214;
case 214:
	if ( (*( sm->p)) == 101 )
		goto st215;
	goto tr246;
st215:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof215;
case 215:
	if ( (*( sm->p)) == 120 )
		goto st216;
	goto tr246;
st216:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof216;
case 216:
	if ( (*( sm->p)) == 116 )
		goto st217;
	goto tr246;
st217:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof217;
case 217:
	if ( (*( sm->p)) == 93 )
		goto tr254;
	goto tr246;
tr255:
#line 766 "ext/dtext/dtext.rl"
	{{( sm->p) = ((( sm->te)))-1;}}
	goto st303;
tr264:
#line 748 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    if (dstack_check(sm, BLOCK_TABLE)) {
      dstack_pop(sm);
      append_newline(sm);
      append_block(sm, "</table>");
      append_newline(sm);
      append_newline(sm);
      { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)];goto _again;}
    } else {
      append(sm, true, "[/table]");
    }
  }}
	goto st303;
tr268:
#line 703 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    if (dstack_check(sm, BLOCK_TBODY)) {
      dstack_pop(sm);
      append_newline(sm);
      append_block(sm, "</tbody>");
      append_newline(sm);
    } else {
      append(sm, true, "[/tbody]");
    }
  }}
	goto st303;
tr272:
#line 685 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    if (dstack_check(sm, BLOCK_THEAD)) {
      dstack_pop(sm);
      append_newline(sm);
      append_block(sm, "</thead>");
      append_newline(sm);
    } else {
      append(sm, true, "[/thead]");
    }
  }}
	goto st303;
tr273:
#line 729 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    if (dstack_check(sm, BLOCK_TR)) {
      dstack_pop(sm);
      append_newline(sm);
      append_block(sm, "</tr>");
      append_newline(sm);
    } else {
      append(sm, true, "[/tr]");
    }
  }}
	goto st303;
tr281:
#line 696 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_push(sm, &BLOCK_TBODY);
    append_newline(sm);
    append_block(sm, "<tbody>");
    append_newline(sm);
  }}
	goto st303;
tr282:
#line 740 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_push(sm, &BLOCK_TD);
    append_newline(sm);
    append_block(sm, "<td>");
    append_newline(sm);
    {
  size_t len = sm->stack->len;

  if (len > MAX_STACK_DEPTH) {
    free_machine(sm);
    rb_raise(rb_eSyntaxError, "too many nested elements");
  }

  if (sm->top >= len) {
    sm->stack = g_array_set_size(sm->stack, len + 16);
  }
{( ((int *)sm->stack->data))[( sm->top)++] = 303; goto st263;}}
  }}
	goto st303;
tr283:
#line 714 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_push(sm, &BLOCK_TH);
    append_newline(sm);
    append_block(sm, "<th>");
    append_newline(sm);
    {
  size_t len = sm->stack->len;

  if (len > MAX_STACK_DEPTH) {
    free_machine(sm);
    rb_raise(rb_eSyntaxError, "too many nested elements");
  }

  if (sm->top >= len) {
    sm->stack = g_array_set_size(sm->stack, len + 16);
  }
{( ((int *)sm->stack->data))[( sm->top)++] = 303; goto st263;}}
  }}
	goto st303;
tr287:
#line 678 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_push(sm, &BLOCK_THEAD);
    append_newline(sm);
    append_block(sm, "<thead>");
    append_newline(sm);
  }}
	goto st303;
tr288:
#line 722 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_push(sm, &BLOCK_TR);
    append_newline(sm);
    append_block(sm, "<tr>");
    append_newline(sm);
  }}
	goto st303;
tr413:
#line 766 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;}
	goto st303;
tr414:
#line 761 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    ( sm->p)--;
    { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)];goto _again;}
  }}
	goto st303;
tr416:
#line 766 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;}
	goto st303;
st303:
#line 1 "NONE"
	{( sm->ts) = 0;}
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof303;
case 303:
#line 1 "NONE"
	{( sm->ts) = ( sm->p);}
#line 4691 "ext/dtext/dtext.c"
	switch( (*( sm->p)) ) {
		case 0: goto tr414;
		case 91: goto tr415;
	}
	goto tr413;
tr415:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
	goto st304;
st304:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof304;
case 304:
#line 4705 "ext/dtext/dtext.c"
	switch( (*( sm->p)) ) {
		case 47: goto st218;
		case 116: goto st233;
	}
	goto tr416;
st218:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof218;
case 218:
	if ( (*( sm->p)) == 116 )
		goto st219;
	goto tr255;
st219:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof219;
case 219:
	switch( (*( sm->p)) ) {
		case 97: goto st220;
		case 98: goto st224;
		case 104: goto st228;
		case 114: goto st232;
	}
	goto tr255;
st220:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof220;
case 220:
	if ( (*( sm->p)) == 98 )
		goto st221;
	goto tr255;
st221:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof221;
case 221:
	if ( (*( sm->p)) == 108 )
		goto st222;
	goto tr255;
st222:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof222;
case 222:
	if ( (*( sm->p)) == 101 )
		goto st223;
	goto tr255;
st223:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof223;
case 223:
	if ( (*( sm->p)) == 93 )
		goto tr264;
	goto tr255;
st224:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof224;
case 224:
	if ( (*( sm->p)) == 111 )
		goto st225;
	goto tr255;
st225:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof225;
case 225:
	if ( (*( sm->p)) == 100 )
		goto st226;
	goto tr255;
st226:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof226;
case 226:
	if ( (*( sm->p)) == 121 )
		goto st227;
	goto tr255;
st227:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof227;
case 227:
	if ( (*( sm->p)) == 93 )
		goto tr268;
	goto tr255;
st228:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof228;
case 228:
	if ( (*( sm->p)) == 101 )
		goto st229;
	goto tr255;
st229:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof229;
case 229:
	if ( (*( sm->p)) == 97 )
		goto st230;
	goto tr255;
st230:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof230;
case 230:
	if ( (*( sm->p)) == 100 )
		goto st231;
	goto tr255;
st231:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof231;
case 231:
	if ( (*( sm->p)) == 93 )
		goto tr272;
	goto tr255;
st232:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof232;
case 232:
	if ( (*( sm->p)) == 93 )
		goto tr273;
	goto tr255;
st233:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof233;
case 233:
	switch( (*( sm->p)) ) {
		case 98: goto st234;
		case 100: goto st238;
		case 104: goto st239;
		case 114: goto st243;
	}
	goto tr255;
st234:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof234;
case 234:
	if ( (*( sm->p)) == 111 )
		goto st235;
	goto tr255;
st235:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof235;
case 235:
	if ( (*( sm->p)) == 100 )
		goto st236;
	goto tr255;
st236:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof236;
case 236:
	if ( (*( sm->p)) == 121 )
		goto st237;
	goto tr255;
st237:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof237;
case 237:
	if ( (*( sm->p)) == 93 )
		goto tr281;
	goto tr255;
st238:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof238;
case 238:
	if ( (*( sm->p)) == 93 )
		goto tr282;
	goto tr255;
st239:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof239;
case 239:
	switch( (*( sm->p)) ) {
		case 93: goto tr283;
		case 101: goto st240;
	}
	goto tr255;
st240:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof240;
case 240:
	if ( (*( sm->p)) == 97 )
		goto st241;
	goto tr255;
st241:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof241;
case 241:
	if ( (*( sm->p)) == 100 )
		goto st242;
	goto tr255;
st242:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof242;
case 242:
	if ( (*( sm->p)) == 93 )
		goto tr287;
	goto tr255;
st243:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof243;
case 243:
	if ( (*( sm->p)) == 93 )
		goto tr288;
	goto tr255;
tr289:
#line 1 "NONE"
	{	switch( ( sm->act) ) {
	case 63:
	{{( sm->p) = ((( sm->te)))-1;}
    dstack_rewind(sm);
    {( sm->p) = (( sm->ts))-1;}
    { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)];goto _again;}
  }
	break;
	default:
	{{( sm->p) = ((( sm->te)))-1;}}
	break;
	}
	}
	goto st305;
tr291:
#line 819 "ext/dtext/dtext.rl"
	{{( sm->p) = ((( sm->te)))-1;}{
    dstack_rewind(sm);
    ( sm->p)--;
    { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)];goto _again;}
  }}
	goto st305;
tr419:
#line 819 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_rewind(sm);
    ( sm->p)--;
    { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)];goto _again;}
  }}
	goto st305;
tr420:
#line 811 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_rewind(sm);
    {( sm->p) = (( sm->ts))-1;}
    { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)];goto _again;}
  }}
	goto st305;
tr425:
#line 819 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    dstack_rewind(sm);
    ( sm->p)--;
    { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)];goto _again;}
  }}
	goto st305;
tr426:
#line 100 "ext/dtext/dtext.rl"
	{
  sm->b2 = sm->p;
}
#line 770 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    int prev_nest = sm->list_nest;
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
        append_newline(sm);
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
          append_newline(sm);
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
{( ((int *)sm->stack->data))[( sm->top)++] = 305; goto st263;}}
  }}
	goto st305;
st305:
#line 1 "NONE"
	{( sm->ts) = 0;}
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof305;
case 305:
#line 1 "NONE"
	{( sm->ts) = ( sm->p);}
#line 5016 "ext/dtext/dtext.c"
	switch( (*( sm->p)) ) {
		case 0: goto tr420;
		case 10: goto tr421;
		case 13: goto st307;
		case 42: goto tr423;
	}
	goto tr419;
tr290:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 811 "ext/dtext/dtext.rl"
	{( sm->act) = 63;}
	goto st306;
tr421:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 817 "ext/dtext/dtext.rl"
	{( sm->act) = 64;}
	goto st306;
st306:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof306;
case 306:
#line 5040 "ext/dtext/dtext.c"
	switch( (*( sm->p)) ) {
		case 10: goto tr290;
		case 13: goto st244;
	}
	goto tr289;
st244:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof244;
case 244:
	if ( (*( sm->p)) == 10 )
		goto tr290;
	goto tr289;
st307:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof307;
case 307:
	if ( (*( sm->p)) == 10 )
		goto tr421;
	goto tr425;
tr423:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 88 "ext/dtext/dtext.rl"
	{
  sm->a1 = sm->p;
}
	goto st308;
st308:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof308;
case 308:
#line 5072 "ext/dtext/dtext.c"
	switch( (*( sm->p)) ) {
		case 9: goto tr294;
		case 32: goto tr294;
		case 42: goto st246;
	}
	goto tr425;
tr294:
#line 92 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
	goto st245;
st245:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof245;
case 245:
#line 5089 "ext/dtext/dtext.c"
	switch( (*( sm->p)) ) {
		case 0: goto tr291;
		case 9: goto tr293;
		case 10: goto tr291;
		case 32: goto tr293;
	}
	goto tr292;
tr292:
#line 96 "ext/dtext/dtext.rl"
	{
  sm->b1 = sm->p;
}
	goto st309;
st309:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof309;
case 309:
#line 5107 "ext/dtext/dtext.c"
	switch( (*( sm->p)) ) {
		case 0: goto tr426;
		case 10: goto tr426;
	}
	goto st309;
tr293:
#line 96 "ext/dtext/dtext.rl"
	{
  sm->b1 = sm->p;
}
	goto st310;
st310:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof310;
case 310:
#line 5123 "ext/dtext/dtext.c"
	switch( (*( sm->p)) ) {
		case 0: goto tr426;
		case 9: goto tr293;
		case 10: goto tr426;
		case 32: goto tr293;
	}
	goto tr292;
st246:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof246;
case 246:
	switch( (*( sm->p)) ) {
		case 9: goto tr294;
		case 32: goto tr294;
		case 42: goto st246;
	}
	goto tr291;
	}
	_test_eof247:  sm->cs = 247; goto _test_eof; 
	_test_eof248:  sm->cs = 248; goto _test_eof; 
	_test_eof0:  sm->cs = 0; goto _test_eof; 
	_test_eof249:  sm->cs = 249; goto _test_eof; 
	_test_eof250:  sm->cs = 250; goto _test_eof; 
	_test_eof1:  sm->cs = 1; goto _test_eof; 
	_test_eof251:  sm->cs = 251; goto _test_eof; 
	_test_eof252:  sm->cs = 252; goto _test_eof; 
	_test_eof2:  sm->cs = 2; goto _test_eof; 
	_test_eof253:  sm->cs = 253; goto _test_eof; 
	_test_eof3:  sm->cs = 3; goto _test_eof; 
	_test_eof4:  sm->cs = 4; goto _test_eof; 
	_test_eof5:  sm->cs = 5; goto _test_eof; 
	_test_eof6:  sm->cs = 6; goto _test_eof; 
	_test_eof7:  sm->cs = 7; goto _test_eof; 
	_test_eof8:  sm->cs = 8; goto _test_eof; 
	_test_eof9:  sm->cs = 9; goto _test_eof; 
	_test_eof10:  sm->cs = 10; goto _test_eof; 
	_test_eof11:  sm->cs = 11; goto _test_eof; 
	_test_eof12:  sm->cs = 12; goto _test_eof; 
	_test_eof13:  sm->cs = 13; goto _test_eof; 
	_test_eof14:  sm->cs = 14; goto _test_eof; 
	_test_eof254:  sm->cs = 254; goto _test_eof; 
	_test_eof15:  sm->cs = 15; goto _test_eof; 
	_test_eof16:  sm->cs = 16; goto _test_eof; 
	_test_eof17:  sm->cs = 17; goto _test_eof; 
	_test_eof18:  sm->cs = 18; goto _test_eof; 
	_test_eof19:  sm->cs = 19; goto _test_eof; 
	_test_eof20:  sm->cs = 20; goto _test_eof; 
	_test_eof21:  sm->cs = 21; goto _test_eof; 
	_test_eof22:  sm->cs = 22; goto _test_eof; 
	_test_eof255:  sm->cs = 255; goto _test_eof; 
	_test_eof256:  sm->cs = 256; goto _test_eof; 
	_test_eof23:  sm->cs = 23; goto _test_eof; 
	_test_eof24:  sm->cs = 24; goto _test_eof; 
	_test_eof25:  sm->cs = 25; goto _test_eof; 
	_test_eof26:  sm->cs = 26; goto _test_eof; 
	_test_eof27:  sm->cs = 27; goto _test_eof; 
	_test_eof28:  sm->cs = 28; goto _test_eof; 
	_test_eof29:  sm->cs = 29; goto _test_eof; 
	_test_eof257:  sm->cs = 257; goto _test_eof; 
	_test_eof30:  sm->cs = 30; goto _test_eof; 
	_test_eof31:  sm->cs = 31; goto _test_eof; 
	_test_eof32:  sm->cs = 32; goto _test_eof; 
	_test_eof33:  sm->cs = 33; goto _test_eof; 
	_test_eof34:  sm->cs = 34; goto _test_eof; 
	_test_eof258:  sm->cs = 258; goto _test_eof; 
	_test_eof35:  sm->cs = 35; goto _test_eof; 
	_test_eof36:  sm->cs = 36; goto _test_eof; 
	_test_eof37:  sm->cs = 37; goto _test_eof; 
	_test_eof38:  sm->cs = 38; goto _test_eof; 
	_test_eof39:  sm->cs = 39; goto _test_eof; 
	_test_eof40:  sm->cs = 40; goto _test_eof; 
	_test_eof41:  sm->cs = 41; goto _test_eof; 
	_test_eof259:  sm->cs = 259; goto _test_eof; 
	_test_eof42:  sm->cs = 42; goto _test_eof; 
	_test_eof43:  sm->cs = 43; goto _test_eof; 
	_test_eof44:  sm->cs = 44; goto _test_eof; 
	_test_eof45:  sm->cs = 45; goto _test_eof; 
	_test_eof46:  sm->cs = 46; goto _test_eof; 
	_test_eof47:  sm->cs = 47; goto _test_eof; 
	_test_eof260:  sm->cs = 260; goto _test_eof; 
	_test_eof48:  sm->cs = 48; goto _test_eof; 
	_test_eof49:  sm->cs = 49; goto _test_eof; 
	_test_eof261:  sm->cs = 261; goto _test_eof; 
	_test_eof262:  sm->cs = 262; goto _test_eof; 
	_test_eof263:  sm->cs = 263; goto _test_eof; 
	_test_eof264:  sm->cs = 264; goto _test_eof; 
	_test_eof265:  sm->cs = 265; goto _test_eof; 
	_test_eof50:  sm->cs = 50; goto _test_eof; 
	_test_eof51:  sm->cs = 51; goto _test_eof; 
	_test_eof52:  sm->cs = 52; goto _test_eof; 
	_test_eof266:  sm->cs = 266; goto _test_eof; 
	_test_eof267:  sm->cs = 267; goto _test_eof; 
	_test_eof268:  sm->cs = 268; goto _test_eof; 
	_test_eof269:  sm->cs = 269; goto _test_eof; 
	_test_eof53:  sm->cs = 53; goto _test_eof; 
	_test_eof54:  sm->cs = 54; goto _test_eof; 
	_test_eof55:  sm->cs = 55; goto _test_eof; 
	_test_eof56:  sm->cs = 56; goto _test_eof; 
	_test_eof270:  sm->cs = 270; goto _test_eof; 
	_test_eof57:  sm->cs = 57; goto _test_eof; 
	_test_eof58:  sm->cs = 58; goto _test_eof; 
	_test_eof59:  sm->cs = 59; goto _test_eof; 
	_test_eof60:  sm->cs = 60; goto _test_eof; 
	_test_eof61:  sm->cs = 61; goto _test_eof; 
	_test_eof62:  sm->cs = 62; goto _test_eof; 
	_test_eof63:  sm->cs = 63; goto _test_eof; 
	_test_eof64:  sm->cs = 64; goto _test_eof; 
	_test_eof65:  sm->cs = 65; goto _test_eof; 
	_test_eof66:  sm->cs = 66; goto _test_eof; 
	_test_eof67:  sm->cs = 67; goto _test_eof; 
	_test_eof68:  sm->cs = 68; goto _test_eof; 
	_test_eof69:  sm->cs = 69; goto _test_eof; 
	_test_eof70:  sm->cs = 70; goto _test_eof; 
	_test_eof71:  sm->cs = 71; goto _test_eof; 
	_test_eof72:  sm->cs = 72; goto _test_eof; 
	_test_eof73:  sm->cs = 73; goto _test_eof; 
	_test_eof271:  sm->cs = 271; goto _test_eof; 
	_test_eof272:  sm->cs = 272; goto _test_eof; 
	_test_eof273:  sm->cs = 273; goto _test_eof; 
	_test_eof274:  sm->cs = 274; goto _test_eof; 
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
	_test_eof275:  sm->cs = 275; goto _test_eof; 
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
	_test_eof135:  sm->cs = 135; goto _test_eof; 
	_test_eof276:  sm->cs = 276; goto _test_eof; 
	_test_eof136:  sm->cs = 136; goto _test_eof; 
	_test_eof137:  sm->cs = 137; goto _test_eof; 
	_test_eof138:  sm->cs = 138; goto _test_eof; 
	_test_eof139:  sm->cs = 139; goto _test_eof; 
	_test_eof140:  sm->cs = 140; goto _test_eof; 
	_test_eof141:  sm->cs = 141; goto _test_eof; 
	_test_eof142:  sm->cs = 142; goto _test_eof; 
	_test_eof277:  sm->cs = 277; goto _test_eof; 
	_test_eof278:  sm->cs = 278; goto _test_eof; 
	_test_eof143:  sm->cs = 143; goto _test_eof; 
	_test_eof144:  sm->cs = 144; goto _test_eof; 
	_test_eof145:  sm->cs = 145; goto _test_eof; 
	_test_eof146:  sm->cs = 146; goto _test_eof; 
	_test_eof147:  sm->cs = 147; goto _test_eof; 
	_test_eof148:  sm->cs = 148; goto _test_eof; 
	_test_eof149:  sm->cs = 149; goto _test_eof; 
	_test_eof150:  sm->cs = 150; goto _test_eof; 
	_test_eof279:  sm->cs = 279; goto _test_eof; 
	_test_eof280:  sm->cs = 280; goto _test_eof; 
	_test_eof151:  sm->cs = 151; goto _test_eof; 
	_test_eof152:  sm->cs = 152; goto _test_eof; 
	_test_eof153:  sm->cs = 153; goto _test_eof; 
	_test_eof154:  sm->cs = 154; goto _test_eof; 
	_test_eof155:  sm->cs = 155; goto _test_eof; 
	_test_eof156:  sm->cs = 156; goto _test_eof; 
	_test_eof281:  sm->cs = 281; goto _test_eof; 
	_test_eof282:  sm->cs = 282; goto _test_eof; 
	_test_eof157:  sm->cs = 157; goto _test_eof; 
	_test_eof158:  sm->cs = 158; goto _test_eof; 
	_test_eof283:  sm->cs = 283; goto _test_eof; 
	_test_eof284:  sm->cs = 284; goto _test_eof; 
	_test_eof159:  sm->cs = 159; goto _test_eof; 
	_test_eof160:  sm->cs = 160; goto _test_eof; 
	_test_eof161:  sm->cs = 161; goto _test_eof; 
	_test_eof162:  sm->cs = 162; goto _test_eof; 
	_test_eof163:  sm->cs = 163; goto _test_eof; 
	_test_eof164:  sm->cs = 164; goto _test_eof; 
	_test_eof285:  sm->cs = 285; goto _test_eof; 
	_test_eof165:  sm->cs = 165; goto _test_eof; 
	_test_eof286:  sm->cs = 286; goto _test_eof; 
	_test_eof166:  sm->cs = 166; goto _test_eof; 
	_test_eof167:  sm->cs = 167; goto _test_eof; 
	_test_eof168:  sm->cs = 168; goto _test_eof; 
	_test_eof169:  sm->cs = 169; goto _test_eof; 
	_test_eof170:  sm->cs = 170; goto _test_eof; 
	_test_eof171:  sm->cs = 171; goto _test_eof; 
	_test_eof287:  sm->cs = 287; goto _test_eof; 
	_test_eof288:  sm->cs = 288; goto _test_eof; 
	_test_eof172:  sm->cs = 172; goto _test_eof; 
	_test_eof173:  sm->cs = 173; goto _test_eof; 
	_test_eof174:  sm->cs = 174; goto _test_eof; 
	_test_eof175:  sm->cs = 175; goto _test_eof; 
	_test_eof176:  sm->cs = 176; goto _test_eof; 
	_test_eof177:  sm->cs = 177; goto _test_eof; 
	_test_eof289:  sm->cs = 289; goto _test_eof; 
	_test_eof178:  sm->cs = 178; goto _test_eof; 
	_test_eof179:  sm->cs = 179; goto _test_eof; 
	_test_eof290:  sm->cs = 290; goto _test_eof; 
	_test_eof180:  sm->cs = 180; goto _test_eof; 
	_test_eof181:  sm->cs = 181; goto _test_eof; 
	_test_eof182:  sm->cs = 182; goto _test_eof; 
	_test_eof183:  sm->cs = 183; goto _test_eof; 
	_test_eof184:  sm->cs = 184; goto _test_eof; 
	_test_eof291:  sm->cs = 291; goto _test_eof; 
	_test_eof185:  sm->cs = 185; goto _test_eof; 
	_test_eof186:  sm->cs = 186; goto _test_eof; 
	_test_eof187:  sm->cs = 187; goto _test_eof; 
	_test_eof188:  sm->cs = 188; goto _test_eof; 
	_test_eof292:  sm->cs = 292; goto _test_eof; 
	_test_eof293:  sm->cs = 293; goto _test_eof; 
	_test_eof189:  sm->cs = 189; goto _test_eof; 
	_test_eof190:  sm->cs = 190; goto _test_eof; 
	_test_eof191:  sm->cs = 191; goto _test_eof; 
	_test_eof192:  sm->cs = 192; goto _test_eof; 
	_test_eof193:  sm->cs = 193; goto _test_eof; 
	_test_eof194:  sm->cs = 194; goto _test_eof; 
	_test_eof294:  sm->cs = 294; goto _test_eof; 
	_test_eof195:  sm->cs = 195; goto _test_eof; 
	_test_eof196:  sm->cs = 196; goto _test_eof; 
	_test_eof295:  sm->cs = 295; goto _test_eof; 
	_test_eof296:  sm->cs = 296; goto _test_eof; 
	_test_eof197:  sm->cs = 197; goto _test_eof; 
	_test_eof198:  sm->cs = 198; goto _test_eof; 
	_test_eof199:  sm->cs = 199; goto _test_eof; 
	_test_eof200:  sm->cs = 200; goto _test_eof; 
	_test_eof201:  sm->cs = 201; goto _test_eof; 
	_test_eof297:  sm->cs = 297; goto _test_eof; 
	_test_eof298:  sm->cs = 298; goto _test_eof; 
	_test_eof202:  sm->cs = 202; goto _test_eof; 
	_test_eof203:  sm->cs = 203; goto _test_eof; 
	_test_eof204:  sm->cs = 204; goto _test_eof; 
	_test_eof299:  sm->cs = 299; goto _test_eof; 
	_test_eof300:  sm->cs = 300; goto _test_eof; 
	_test_eof205:  sm->cs = 205; goto _test_eof; 
	_test_eof206:  sm->cs = 206; goto _test_eof; 
	_test_eof207:  sm->cs = 207; goto _test_eof; 
	_test_eof208:  sm->cs = 208; goto _test_eof; 
	_test_eof209:  sm->cs = 209; goto _test_eof; 
	_test_eof301:  sm->cs = 301; goto _test_eof; 
	_test_eof302:  sm->cs = 302; goto _test_eof; 
	_test_eof210:  sm->cs = 210; goto _test_eof; 
	_test_eof211:  sm->cs = 211; goto _test_eof; 
	_test_eof212:  sm->cs = 212; goto _test_eof; 
	_test_eof213:  sm->cs = 213; goto _test_eof; 
	_test_eof214:  sm->cs = 214; goto _test_eof; 
	_test_eof215:  sm->cs = 215; goto _test_eof; 
	_test_eof216:  sm->cs = 216; goto _test_eof; 
	_test_eof217:  sm->cs = 217; goto _test_eof; 
	_test_eof303:  sm->cs = 303; goto _test_eof; 
	_test_eof304:  sm->cs = 304; goto _test_eof; 
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
	_test_eof305:  sm->cs = 305; goto _test_eof; 
	_test_eof306:  sm->cs = 306; goto _test_eof; 
	_test_eof244:  sm->cs = 244; goto _test_eof; 
	_test_eof307:  sm->cs = 307; goto _test_eof; 
	_test_eof308:  sm->cs = 308; goto _test_eof; 
	_test_eof245:  sm->cs = 245; goto _test_eof; 
	_test_eof309:  sm->cs = 309; goto _test_eof; 
	_test_eof310:  sm->cs = 310; goto _test_eof; 
	_test_eof246:  sm->cs = 246; goto _test_eof; 

	_test_eof: {}
	if ( ( sm->p) == ( sm->eof) )
	{
	switch (  sm->cs ) {
	case 248: goto tr0;
	case 0: goto tr0;
	case 249: goto tr304;
	case 250: goto tr304;
	case 1: goto tr2;
	case 251: goto tr305;
	case 252: goto tr305;
	case 2: goto tr2;
	case 253: goto tr304;
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
	case 254: goto tr314;
	case 15: goto tr2;
	case 16: goto tr2;
	case 17: goto tr2;
	case 18: goto tr2;
	case 19: goto tr2;
	case 20: goto tr2;
	case 21: goto tr2;
	case 22: goto tr2;
	case 255: goto tr315;
	case 256: goto tr317;
	case 23: goto tr2;
	case 24: goto tr2;
	case 25: goto tr2;
	case 26: goto tr2;
	case 27: goto tr2;
	case 28: goto tr2;
	case 29: goto tr2;
	case 257: goto tr318;
	case 30: goto tr2;
	case 31: goto tr2;
	case 32: goto tr2;
	case 33: goto tr2;
	case 34: goto tr2;
	case 258: goto tr319;
	case 35: goto tr2;
	case 36: goto tr2;
	case 37: goto tr2;
	case 38: goto tr2;
	case 39: goto tr2;
	case 40: goto tr2;
	case 41: goto tr2;
	case 259: goto tr320;
	case 42: goto tr2;
	case 43: goto tr2;
	case 44: goto tr2;
	case 45: goto tr2;
	case 46: goto tr2;
	case 47: goto tr2;
	case 260: goto tr304;
	case 48: goto tr2;
	case 49: goto tr2;
	case 261: goto tr322;
	case 262: goto tr322;
	case 264: goto tr340;
	case 265: goto tr343;
	case 50: goto tr58;
	case 51: goto tr60;
	case 52: goto tr60;
	case 266: goto tr344;
	case 267: goto tr344;
	case 268: goto tr346;
	case 269: goto tr346;
	case 53: goto tr65;
	case 54: goto tr65;
	case 55: goto tr65;
	case 56: goto tr65;
	case 270: goto tr348;
	case 57: goto tr65;
	case 58: goto tr65;
	case 59: goto tr65;
	case 60: goto tr65;
	case 61: goto tr65;
	case 62: goto tr65;
	case 63: goto tr65;
	case 64: goto tr65;
	case 65: goto tr65;
	case 66: goto tr65;
	case 67: goto tr65;
	case 68: goto tr65;
	case 69: goto tr65;
	case 70: goto tr65;
	case 71: goto tr65;
	case 72: goto tr65;
	case 73: goto tr65;
	case 271: goto tr346;
	case 272: goto tr350;
	case 273: goto tr353;
	case 274: goto tr346;
	case 74: goto tr65;
	case 75: goto tr65;
	case 76: goto tr65;
	case 77: goto tr65;
	case 78: goto tr65;
	case 79: goto tr65;
	case 80: goto tr65;
	case 81: goto tr65;
	case 82: goto tr65;
	case 83: goto tr65;
	case 84: goto tr65;
	case 85: goto tr65;
	case 86: goto tr65;
	case 87: goto tr65;
	case 275: goto tr364;
	case 88: goto tr65;
	case 89: goto tr65;
	case 90: goto tr65;
	case 91: goto tr65;
	case 92: goto tr65;
	case 93: goto tr65;
	case 94: goto tr65;
	case 95: goto tr65;
	case 96: goto tr65;
	case 97: goto tr65;
	case 98: goto tr65;
	case 99: goto tr65;
	case 100: goto tr65;
	case 101: goto tr65;
	case 102: goto tr65;
	case 103: goto tr65;
	case 104: goto tr65;
	case 105: goto tr65;
	case 106: goto tr65;
	case 107: goto tr65;
	case 108: goto tr65;
	case 109: goto tr65;
	case 110: goto tr65;
	case 111: goto tr65;
	case 112: goto tr65;
	case 113: goto tr65;
	case 114: goto tr65;
	case 115: goto tr65;
	case 116: goto tr65;
	case 117: goto tr65;
	case 118: goto tr65;
	case 119: goto tr65;
	case 120: goto tr65;
	case 121: goto tr65;
	case 122: goto tr65;
	case 123: goto tr65;
	case 124: goto tr65;
	case 125: goto tr65;
	case 126: goto tr65;
	case 127: goto tr65;
	case 128: goto tr65;
	case 129: goto tr65;
	case 130: goto tr65;
	case 131: goto tr65;
	case 132: goto tr65;
	case 133: goto tr65;
	case 134: goto tr65;
	case 135: goto tr65;
	case 276: goto tr346;
	case 136: goto tr65;
	case 137: goto tr65;
	case 138: goto tr65;
	case 139: goto tr65;
	case 140: goto tr65;
	case 141: goto tr65;
	case 142: goto tr65;
	case 277: goto tr366;
	case 278: goto tr346;
	case 143: goto tr65;
	case 144: goto tr65;
	case 145: goto tr65;
	case 146: goto tr65;
	case 147: goto tr65;
	case 148: goto tr65;
	case 149: goto tr65;
	case 150: goto tr65;
	case 279: goto tr369;
	case 280: goto tr346;
	case 151: goto tr65;
	case 152: goto tr65;
	case 153: goto tr65;
	case 154: goto tr65;
	case 155: goto tr65;
	case 156: goto tr65;
	case 281: goto tr372;
	case 282: goto tr346;
	case 157: goto tr65;
	case 158: goto tr65;
	case 283: goto tr376;
	case 284: goto tr376;
	case 159: goto tr65;
	case 160: goto tr65;
	case 161: goto tr65;
	case 162: goto tr65;
	case 163: goto tr65;
	case 164: goto tr65;
	case 285: goto tr378;
	case 165: goto tr65;
	case 286: goto tr346;
	case 166: goto tr65;
	case 167: goto tr65;
	case 168: goto tr65;
	case 169: goto tr65;
	case 170: goto tr65;
	case 171: goto tr65;
	case 287: goto tr380;
	case 288: goto tr346;
	case 172: goto tr65;
	case 173: goto tr65;
	case 174: goto tr65;
	case 175: goto tr65;
	case 176: goto tr65;
	case 177: goto tr65;
	case 289: goto tr384;
	case 178: goto tr209;
	case 179: goto tr209;
	case 290: goto tr387;
	case 180: goto tr65;
	case 181: goto tr65;
	case 182: goto tr65;
	case 183: goto tr65;
	case 184: goto tr65;
	case 291: goto tr389;
	case 185: goto tr65;
	case 186: goto tr65;
	case 187: goto tr65;
	case 188: goto tr65;
	case 292: goto tr391;
	case 293: goto tr346;
	case 189: goto tr65;
	case 190: goto tr65;
	case 191: goto tr65;
	case 192: goto tr65;
	case 193: goto tr65;
	case 194: goto tr65;
	case 294: goto tr394;
	case 195: goto tr228;
	case 196: goto tr228;
	case 295: goto tr397;
	case 296: goto tr346;
	case 197: goto tr65;
	case 198: goto tr65;
	case 199: goto tr65;
	case 200: goto tr65;
	case 201: goto tr65;
	case 297: goto tr400;
	case 298: goto tr346;
	case 202: goto tr65;
	case 203: goto tr65;
	case 204: goto tr65;
	case 300: goto tr406;
	case 205: goto tr240;
	case 206: goto tr240;
	case 207: goto tr240;
	case 208: goto tr240;
	case 209: goto tr240;
	case 302: goto tr411;
	case 210: goto tr246;
	case 211: goto tr246;
	case 212: goto tr246;
	case 213: goto tr246;
	case 214: goto tr246;
	case 215: goto tr246;
	case 216: goto tr246;
	case 217: goto tr246;
	case 304: goto tr416;
	case 218: goto tr255;
	case 219: goto tr255;
	case 220: goto tr255;
	case 221: goto tr255;
	case 222: goto tr255;
	case 223: goto tr255;
	case 224: goto tr255;
	case 225: goto tr255;
	case 226: goto tr255;
	case 227: goto tr255;
	case 228: goto tr255;
	case 229: goto tr255;
	case 230: goto tr255;
	case 231: goto tr255;
	case 232: goto tr255;
	case 233: goto tr255;
	case 234: goto tr255;
	case 235: goto tr255;
	case 236: goto tr255;
	case 237: goto tr255;
	case 238: goto tr255;
	case 239: goto tr255;
	case 240: goto tr255;
	case 241: goto tr255;
	case 242: goto tr255;
	case 243: goto tr255;
	case 306: goto tr289;
	case 244: goto tr289;
	case 307: goto tr425;
	case 308: goto tr425;
	case 245: goto tr291;
	case 309: goto tr426;
	case 310: goto tr426;
	case 246: goto tr291;
	}
	}

	}

#line 1308 "ext/dtext/dtext.rl"

  dstack_close(sm);

  ret = rb_str_new(sm->output->str, sm->output->len);

  free_machine(sm);

  return ret;
}

void Init_dtext() {
  VALUE mDTextRagel = rb_define_module("DTextRagel");
  rb_define_singleton_method(mDTextRagel, "parse", parse, -1);
}
