
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


#line 965 "ext/dtext/dtext.rl"



#line 77 "ext/dtext/dtext.c"
static const int dtext_start = 245;
static const int dtext_first_final = 245;
static const int dtext_error = -1;

static const int dtext_en_inline = 260;
static const int dtext_en_code = 295;
static const int dtext_en_nodtext = 297;
static const int dtext_en_table = 299;
static const int dtext_en_list = 301;
static const int dtext_en_main = 245;


#line 968 "ext/dtext/dtext.rl"

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

  
#line 444 "ext/dtext/dtext.c"
	{
	 sm->cs = dtext_start;
	( sm->top) = 0;
	( sm->ts) = 0;
	( sm->te) = 0;
	( sm->act) = 0;
	}

#line 1321 "ext/dtext/dtext.rl"
  
#line 455 "ext/dtext/dtext.c"
	{
	if ( ( sm->p) == ( sm->pe) )
		goto _test_eof;
	goto _resume;

_again:
	switch (  sm->cs ) {
		case 245: goto st245;
		case 246: goto st246;
		case 0: goto st0;
		case 247: goto st247;
		case 248: goto st248;
		case 1: goto st1;
		case 249: goto st249;
		case 250: goto st250;
		case 2: goto st2;
		case 251: goto st251;
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
		case 252: goto st252;
		case 15: goto st15;
		case 16: goto st16;
		case 17: goto st17;
		case 18: goto st18;
		case 19: goto st19;
		case 20: goto st20;
		case 21: goto st21;
		case 22: goto st22;
		case 253: goto st253;
		case 254: goto st254;
		case 23: goto st23;
		case 24: goto st24;
		case 25: goto st25;
		case 26: goto st26;
		case 27: goto st27;
		case 28: goto st28;
		case 29: goto st29;
		case 255: goto st255;
		case 30: goto st30;
		case 31: goto st31;
		case 32: goto st32;
		case 33: goto st33;
		case 34: goto st34;
		case 256: goto st256;
		case 35: goto st35;
		case 36: goto st36;
		case 37: goto st37;
		case 38: goto st38;
		case 39: goto st39;
		case 40: goto st40;
		case 41: goto st41;
		case 257: goto st257;
		case 42: goto st42;
		case 43: goto st43;
		case 44: goto st44;
		case 45: goto st45;
		case 46: goto st46;
		case 47: goto st47;
		case 258: goto st258;
		case 48: goto st48;
		case 259: goto st259;
		case 260: goto st260;
		case 261: goto st261;
		case 262: goto st262;
		case 49: goto st49;
		case 50: goto st50;
		case 51: goto st51;
		case 263: goto st263;
		case 264: goto st264;
		case 265: goto st265;
		case 266: goto st266;
		case 52: goto st52;
		case 53: goto st53;
		case 54: goto st54;
		case 55: goto st55;
		case 267: goto st267;
		case 56: goto st56;
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
		case 268: goto st268;
		case 269: goto st269;
		case 270: goto st270;
		case 271: goto st271;
		case 73: goto st73;
		case 74: goto st74;
		case 75: goto st75;
		case 76: goto st76;
		case 77: goto st77;
		case 78: goto st78;
		case 79: goto st79;
		case 272: goto st272;
		case 273: goto st273;
		case 80: goto st80;
		case 81: goto st81;
		case 82: goto st82;
		case 83: goto st83;
		case 84: goto st84;
		case 85: goto st85;
		case 86: goto st86;
		case 87: goto st87;
		case 274: goto st274;
		case 275: goto st275;
		case 88: goto st88;
		case 89: goto st89;
		case 90: goto st90;
		case 91: goto st91;
		case 92: goto st92;
		case 93: goto st93;
		case 276: goto st276;
		case 277: goto st277;
		case 94: goto st94;
		case 95: goto st95;
		case 96: goto st96;
		case 97: goto st97;
		case 98: goto st98;
		case 99: goto st99;
		case 278: goto st278;
		case 279: goto st279;
		case 100: goto st100;
		case 101: goto st101;
		case 102: goto st102;
		case 103: goto st103;
		case 104: goto st104;
		case 105: goto st105;
		case 280: goto st280;
		case 106: goto st106;
		case 107: goto st107;
		case 281: goto st281;
		case 108: goto st108;
		case 109: goto st109;
		case 110: goto st110;
		case 111: goto st111;
		case 112: goto st112;
		case 282: goto st282;
		case 113: goto st113;
		case 114: goto st114;
		case 115: goto st115;
		case 116: goto st116;
		case 283: goto st283;
		case 284: goto st284;
		case 117: goto st117;
		case 118: goto st118;
		case 119: goto st119;
		case 120: goto st120;
		case 121: goto st121;
		case 122: goto st122;
		case 285: goto st285;
		case 123: goto st123;
		case 124: goto st124;
		case 286: goto st286;
		case 287: goto st287;
		case 125: goto st125;
		case 126: goto st126;
		case 127: goto st127;
		case 128: goto st128;
		case 129: goto st129;
		case 288: goto st288;
		case 289: goto st289;
		case 130: goto st130;
		case 131: goto st131;
		case 132: goto st132;
		case 133: goto st133;
		case 134: goto st134;
		case 135: goto st135;
		case 136: goto st136;
		case 137: goto st137;
		case 138: goto st138;
		case 139: goto st139;
		case 140: goto st140;
		case 141: goto st141;
		case 142: goto st142;
		case 143: goto st143;
		case 290: goto st290;
		case 144: goto st144;
		case 145: goto st145;
		case 146: goto st146;
		case 147: goto st147;
		case 148: goto st148;
		case 149: goto st149;
		case 150: goto st150;
		case 151: goto st151;
		case 152: goto st152;
		case 153: goto st153;
		case 154: goto st154;
		case 155: goto st155;
		case 156: goto st156;
		case 157: goto st157;
		case 158: goto st158;
		case 159: goto st159;
		case 160: goto st160;
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
		case 179: goto st179;
		case 180: goto st180;
		case 181: goto st181;
		case 182: goto st182;
		case 183: goto st183;
		case 184: goto st184;
		case 185: goto st185;
		case 186: goto st186;
		case 187: goto st187;
		case 188: goto st188;
		case 189: goto st189;
		case 190: goto st190;
		case 191: goto st191;
		case 291: goto st291;
		case 192: goto st192;
		case 292: goto st292;
		case 193: goto st193;
		case 194: goto st194;
		case 195: goto st195;
		case 196: goto st196;
		case 197: goto st197;
		case 198: goto st198;
		case 293: goto st293;
		case 199: goto st199;
		case 294: goto st294;
		case 200: goto st200;
		case 201: goto st201;
		case 202: goto st202;
		case 295: goto st295;
		case 296: goto st296;
		case 203: goto st203;
		case 204: goto st204;
		case 205: goto st205;
		case 206: goto st206;
		case 207: goto st207;
		case 297: goto st297;
		case 298: goto st298;
		case 208: goto st208;
		case 209: goto st209;
		case 210: goto st210;
		case 211: goto st211;
		case 212: goto st212;
		case 213: goto st213;
		case 214: goto st214;
		case 215: goto st215;
		case 299: goto st299;
		case 300: goto st300;
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
		case 301: goto st301;
		case 302: goto st302;
		case 242: goto st242;
		case 303: goto st303;
		case 304: goto st304;
		case 243: goto st243;
		case 305: goto st305;
		case 306: goto st306;
		case 244: goto st244;
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
	goto st245;
tr2:
#line 950 "ext/dtext/dtext.rl"
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
{( ((int *)sm->stack->data))[( sm->top)++] = 245; goto st260;}}
  }}
	goto st245;
tr14:
#line 857 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    g_debug("block [/spoiler]");
    dstack_close_before_block(sm);
    if (dstack_check(sm, BLOCK_SPOILER)) {
      g_debug("  rewind");
      dstack_rewind(sm);
    }
  }}
	goto st245;
tr53:
#line 904 "ext/dtext/dtext.rl"
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
{( ((int *)sm->stack->data))[( sm->top)++] = 245; goto st299;}}
  }}
	goto st245;
tr54:
#line 911 "ext/dtext/dtext.rl"
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
{( ((int *)sm->stack->data))[( sm->top)++] = 245; goto st260;}}
  }}
	goto st245;
tr292:
#line 950 "ext/dtext/dtext.rl"
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
{( ((int *)sm->stack->data))[( sm->top)++] = 245; goto st260;}}
  }}
	goto st245;
tr293:
#line 927 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    g_debug("block 0");
    g_debug("  close dstack");
    dstack_close(sm);
  }}
	goto st245;
tr300:
#line 950 "ext/dtext/dtext.rl"
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
{( ((int *)sm->stack->data))[( sm->top)++] = 245; goto st260;}}
  }}
	goto st245;
tr301:
#line 107 "ext/dtext/dtext.rl"
	{
  sm->b2 = sm->p;
}
#line 917 "ext/dtext/dtext.rl"
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
{( ((int *)sm->stack->data))[( sm->top)++] = 245; goto st301;}}
  }}
	goto st245;
tr310:
#line 866 "ext/dtext/dtext.rl"
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
{( ((int *)sm->stack->data))[( sm->top)++] = 245; goto st295;}}
  }}
	goto st245;
tr311:
#line 883 "ext/dtext/dtext.rl"
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
	goto st245;
tr313:
#line 874 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    g_debug("block [expand]");
    dstack_close_before_block(sm);
    dstack_push(sm, &BLOCK_EXPAND);
    append_block(sm, "<div class=\"expandable\"><div class=\"expandable-header\">");
    append_block(sm, "<input type=\"button\" value=\"Show\" class=\"expandable-button\"/></div>");
    append_block(sm, "<div class=\"expandable-content\">");
  }}
	goto st245;
tr314:
#line 895 "ext/dtext/dtext.rl"
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
{( ((int *)sm->stack->data))[( sm->top)++] = 245; goto st297;}}
  }}
	goto st245;
tr315:
#line 839 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    g_debug("block [quote]");
    g_debug("  push quote");
    g_debug("  print <blockquote>");
    dstack_close_before_block(sm);
    dstack_push(sm, &BLOCK_QUOTE);
    append_block(sm, "<blockquote>");
  }}
	goto st245;
tr316:
#line 848 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    g_debug("block [spoiler]");
    g_debug("  push spoiler");
    g_debug("  print <div>");
    dstack_close_before_block(sm);
    dstack_push(sm, &BLOCK_SPOILER);
    append_block(sm, "<div class=\"spoiler\">");
  }}
	goto st245;
tr318:
#line 794 "ext/dtext/dtext.rl"
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
{( ((int *)sm->stack->data))[( sm->top)++] = 245; goto st260;}}
  }}
	goto st245;
st245:
#line 1 "NONE"
	{( sm->ts) = 0;}
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof245;
case 245:
#line 1 "NONE"
	{( sm->ts) = ( sm->p);}
#line 1125 "ext/dtext/dtext.c"
	switch( (*( sm->p)) ) {
		case 0: goto tr293;
		case 10: goto tr294;
		case 13: goto st247;
		case 42: goto tr296;
		case 91: goto tr297;
		case 104: goto tr298;
	}
	goto tr292;
tr1:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 933 "ext/dtext/dtext.rl"
	{( sm->act) = 79;}
	goto st246;
tr294:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 946 "ext/dtext/dtext.rl"
	{( sm->act) = 80;}
	goto st246;
st246:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof246;
case 246:
#line 1151 "ext/dtext/dtext.c"
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
st247:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof247;
case 247:
	if ( (*( sm->p)) == 10 )
		goto tr294;
	goto tr300;
tr296:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 95 "ext/dtext/dtext.rl"
	{
  sm->a1 = sm->p;
}
	goto st248;
st248:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof248;
case 248:
#line 1183 "ext/dtext/dtext.c"
	switch( (*( sm->p)) ) {
		case 9: goto tr5;
		case 32: goto tr5;
		case 42: goto st2;
	}
	goto tr300;
tr5:
#line 99 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
	goto st1;
st1:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1;
case 1:
#line 1200 "ext/dtext/dtext.c"
	switch( (*( sm->p)) ) {
		case 0: goto tr2;
		case 9: goto tr4;
		case 10: goto tr2;
		case 13: goto tr2;
		case 32: goto tr4;
	}
	goto tr3;
tr3:
#line 103 "ext/dtext/dtext.rl"
	{
  sm->b1 = sm->p;
}
	goto st249;
st249:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof249;
case 249:
#line 1219 "ext/dtext/dtext.c"
	switch( (*( sm->p)) ) {
		case 0: goto tr301;
		case 10: goto tr301;
		case 13: goto tr301;
	}
	goto st249;
tr4:
#line 103 "ext/dtext/dtext.rl"
	{
  sm->b1 = sm->p;
}
	goto st250;
st250:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof250;
case 250:
#line 1236 "ext/dtext/dtext.c"
	switch( (*( sm->p)) ) {
		case 0: goto tr301;
		case 9: goto tr4;
		case 10: goto tr301;
		case 13: goto tr301;
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
tr297:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
	goto st251;
st251:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof251;
case 251:
#line 1263 "ext/dtext/dtext.c"
	switch( (*( sm->p)) ) {
		case 47: goto st3;
		case 99: goto st11;
		case 101: goto st15;
		case 110: goto st23;
		case 113: goto st30;
		case 115: goto st35;
		case 116: goto st42;
	}
	goto tr300;
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
		goto st252;
	goto tr2;
st252:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof252;
case 252:
	if ( (*( sm->p)) == 32 )
		goto st252;
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto st252;
	goto tr310;
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
		case 93: goto st254;
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
#line 95 "ext/dtext/dtext.rl"
	{
  sm->a1 = sm->p;
}
	goto st22;
st22:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof22;
case 22:
#line 1428 "ext/dtext/dtext.c"
	if ( (*( sm->p)) == 93 )
		goto tr28;
	goto st22;
tr28:
#line 99 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
	goto st253;
st253:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof253;
case 253:
#line 1442 "ext/dtext/dtext.c"
	if ( (*( sm->p)) == 32 )
		goto st253;
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto st253;
	goto tr311;
st254:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof254;
case 254:
	if ( (*( sm->p)) == 32 )
		goto st254;
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto st254;
	goto tr313;
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
		goto st255;
	goto tr2;
st255:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof255;
case 255:
	if ( (*( sm->p)) == 32 )
		goto st255;
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto st255;
	goto tr314;
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
		goto st256;
	goto tr2;
st256:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof256;
case 256:
	if ( (*( sm->p)) == 32 )
		goto st256;
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto st256;
	goto tr315;
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
	goto tr316;
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
tr298:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
	goto st258;
st258:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof258;
case 258:
#line 1669 "ext/dtext/dtext.c"
	if ( 49 <= (*( sm->p)) && (*( sm->p)) <= 54 )
		goto tr317;
	goto tr300;
tr317:
#line 95 "ext/dtext/dtext.rl"
	{
  sm->a1 = sm->p;
}
	goto st48;
st48:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof48;
case 48:
#line 1683 "ext/dtext/dtext.c"
	if ( (*( sm->p)) == 46 )
		goto tr55;
	goto tr2;
tr55:
#line 99 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
	goto st259;
st259:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof259;
case 259:
#line 1697 "ext/dtext/dtext.c"
	switch( (*( sm->p)) ) {
		case 9: goto st259;
		case 32: goto st259;
	}
	goto tr318;
tr56:
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
      dstack_close_list(sm);
    }

    {( sm->p) = (( sm->ts))-1;}
    { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)];goto _again;}
  }
	break;
	case 43:
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
	goto st260;
tr58:
#line 599 "ext/dtext/dtext.rl"
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
	goto st260;
tr63:
#line 615 "ext/dtext/dtext.rl"
	{{( sm->p) = ((( sm->te)))-1;}{
    g_debug("inline char: %c", (*( sm->p)));
    append_c_html_escaped(sm, (*( sm->p)));
  }}
	goto st260;
tr74:
#line 107 "ext/dtext/dtext.rl"
	{
  sm->b2 = sm->p;
}
#line 328 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    append(sm, true, "<a href=\"");
    append_segment_html_escaped(sm, sm->b1, sm->b2 - 1);
    append(sm, true, "\">");
    append_segment_html_escaped(sm, sm->a1, sm->a2 - 1);
    append(sm, true, "</a>");
  }}
	goto st260;
tr122:
#line 236 "ext/dtext/dtext.rl"
	{{( sm->p) = ((( sm->te)))-1;}{
    append(sm, true, "<a href=\"http://www.pixiv.net/member_illust.php?mode=medium&illust_id=");
    append_segment(sm, true, sm->a1, sm->a2 - 1);
    append(sm, true, "\">");
    append(sm, false, "pixiv #");
    append_segment(sm, false, sm->a1, sm->a2 - 1);
    append(sm, true, "</a>");
  }}
	goto st260;
tr141:
#line 169 "ext/dtext/dtext.rl"
	{{( sm->p) = ((( sm->te)))-1;}{
    append(sm, true, "<a href=\"/forum_topics/");
    append_segment(sm, true, sm->a1, sm->a2 - 1);
    append(sm, true, "\">");
    append(sm, false, "topic #");
    append_segment(sm, false, sm->a1, sm->a2 - 1);
    append(sm, true, "</a>");
  }}
	goto st260;
tr156:
#line 406 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    if (dstack_check(sm, INLINE_B)) {
      dstack_pop(sm);
      append(sm, true, "</strong>");
    } else {
      append(sm, true, "[/b]");
    }
  }}
	goto st260;
tr162:
#line 542 "ext/dtext/dtext.rl"
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
	goto st260;
tr163:
#line 420 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    if (dstack_check(sm, INLINE_I)) {
      dstack_pop(sm);
      append(sm, true, "</em>");
    } else {
      append(sm, true, "[/i]");
    }
  }}
	goto st260;
tr169:
#line 434 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    if (dstack_check(sm, INLINE_S)) {
      dstack_pop(sm);
      append(sm, true, "</s>");
    } else {
      append(sm, true, "[/s]");
    }
  }}
	goto st260;
tr176:
#line 514 "ext/dtext/dtext.rl"
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
	goto st260;
tr180:
#line 569 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    if (dstack_check(sm, BLOCK_TD)) {
      dstack_pop(sm);
      append_block(sm, "</td>");
      { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)];goto _again;}
    } else {
      append_block(sm, "[/td]");
    }
  }}
	goto st260;
tr181:
#line 559 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    if (dstack_check(sm, BLOCK_TH)) {
      dstack_pop(sm);
      append_block(sm, "</th>");
      { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)];goto _again;}
    } else {
      append_block(sm, "[/th]");
    }
  }}
	goto st260;
tr182:
#line 462 "ext/dtext/dtext.rl"
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
	goto st260;
tr183:
#line 448 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    if (dstack_check(sm, INLINE_U)) {
      dstack_pop(sm);
      append(sm, true, "</u>");
    } else {
      append(sm, true, "[/u]");
    }
  }}
	goto st260;
tr188:
#line 266 "ext/dtext/dtext.rl"
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
	goto st260;
tr192:
#line 287 "ext/dtext/dtext.rl"
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
	goto st260;
tr193:
#line 401 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_push(sm, &INLINE_B);
    append(sm, true, "<strong>");
  }}
	goto st260;
tr199:
#line 535 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    g_debug("inline [expand]");
    dstack_rewind(sm);
    {( sm->p) = (((sm->p - 7)))-1;}
    { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)];goto _again;}
  }}
	goto st260;
tr200:
#line 415 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_push(sm, &INLINE_I);
    append(sm, true, "<em>");
  }}
	goto st260;
tr207:
#line 554 "ext/dtext/dtext.rl"
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
{( ((int *)sm->stack->data))[( sm->top)++] = 260; goto st297;}}
  }}
	goto st260;
tr212:
#line 484 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    g_debug("inline [quote]");
    dstack_close_before_block(sm);
    {( sm->p) = (( sm->ts))-1;}
    { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)];goto _again;}
  }}
	goto st260;
tr213:
#line 429 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_push(sm, &INLINE_S);
    append(sm, true, "<s>");
  }}
	goto st260;
tr220:
#line 507 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    g_debug("inline [spoiler]");
    g_debug("  push <span>");
    dstack_push(sm, &INLINE_SPOILER);
    append(sm, true, "<span class=\"spoiler\">");
  }}
	goto st260;
tr222:
#line 457 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_push(sm, &INLINE_TN);
    append(sm, true, "<span class=\"tn\">");
  }}
	goto st260;
tr223:
#line 443 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_push(sm, &INLINE_U);
    append(sm, true, "<u>");
  }}
	goto st260;
tr235:
#line 258 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    append(sm, true, "<a rel=\"nofollow\" href=\"/posts?tags=");
    append_segment_uri_escaped(sm, sm->a1, sm->a2 - 1);
    append(sm, true, "\">");
    append_segment_html_escaped(sm, sm->a1, sm->a2 - 1);
    append(sm, true, "</a>");
  }}
	goto st260;
tr320:
#line 615 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    g_debug("inline char: %c", (*( sm->p)));
    append_c_html_escaped(sm, (*( sm->p)));
  }}
	goto st260;
tr321:
#line 579 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    g_debug("inline 0");
    g_debug("  return");

    ( sm->p)--;
    { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)];goto _again;}
  }}
	goto st260;
tr336:
#line 599 "ext/dtext/dtext.rl"
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
	goto st260;
tr339:
#line 587 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    g_debug("inline newline2");
    g_debug("  return");

    if (sm->list_mode) {
      dstack_close_list(sm);
    }

    {( sm->p) = (( sm->ts))-1;}
    { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)];goto _again;}
  }}
	goto st260;
tr340:
	 sm->cs = 260;
#line 107 "ext/dtext/dtext.rl"
	{
  sm->b2 = sm->p;
}
#line 382 "ext/dtext/dtext.rl"
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
     sm->cs = 301;
  }}
	goto _again;
tr342:
#line 611 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append_c(sm, ' ');
  }}
	goto st260;
tr343:
#line 615 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    g_debug("inline char: %c", (*( sm->p)));
    append_c_html_escaped(sm, (*( sm->p)));
  }}
	goto st260;
tr345:
#line 107 "ext/dtext/dtext.rl"
	{
  sm->b2 = sm->p;
}
#line 308 "ext/dtext/dtext.rl"
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
	goto st260;
tr347:
#line 99 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
#line 361 "ext/dtext/dtext.rl"
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
	goto st260;
tr350:
#line 99 "ext/dtext/dtext.rl"
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
      dstack_close_list(sm);
    }

    {( sm->p) = (( sm->ts))-1;}
    { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)];goto _again;}
  }
	break;
	case 43:
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
	goto st260;
tr352:
#line 99 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
#line 218 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append(sm, true, "<a href=\"/artists/");
    append_segment(sm, true, sm->a1, sm->a2 - 1);
    append(sm, true, "\">");
    append(sm, false, "artist #");
    append_segment(sm, false, sm->a1, sm->a2 - 1);
    append(sm, true, "</a>");
  }}
	goto st260;
tr355:
#line 99 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
#line 191 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append(sm, true, "<a href=\"/comments/");
    append_segment(sm, true, sm->a1, sm->a2 - 1);
    append(sm, true, "\">");
    append(sm, false, "comment #");
    append_segment(sm, false, sm->a1, sm->a2 - 1);
    append(sm, true, "</a>");
  }}
	goto st260;
tr358:
#line 99 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
#line 160 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append(sm, true, "<a href=\"/forum_posts/");
    append_segment(sm, true, sm->a1, sm->a2 - 1);
    append(sm, true, "\">");
    append(sm, false, "forum #");
    append_segment(sm, false, sm->a1, sm->a2 - 1);
    append(sm, true, "</a>");
  }}
	goto st260;
tr361:
#line 99 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
#line 227 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append(sm, true, "<a href=\"https://github.com/r888888888/danbooru/issues/");
    append_segment(sm, true, sm->a1, sm->a2 - 1);
    append(sm, true, "\">");
    append(sm, false, "issue #");
    append_segment(sm, false, sm->a1, sm->a2 - 1);
    append(sm, true, "</a>");
  }}
	goto st260;
tr365:
#line 99 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
#line 236 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append(sm, true, "<a href=\"http://www.pixiv.net/member_illust.php?mode=medium&illust_id=");
    append_segment(sm, true, sm->a1, sm->a2 - 1);
    append(sm, true, "\">");
    append(sm, false, "pixiv #");
    append_segment(sm, false, sm->a1, sm->a2 - 1);
    append(sm, true, "</a>");
  }}
	goto st260;
tr368:
#line 107 "ext/dtext/dtext.rl"
	{
  sm->b2 = sm->p;
}
#line 245 "ext/dtext/dtext.rl"
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
	goto st260;
tr370:
#line 99 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
#line 200 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append(sm, true, "<a href=\"/pools/");
    append_segment(sm, true, sm->a1, sm->a2 - 1);
    append(sm, true, "\">");
    append(sm, false, "pool #");
    append_segment(sm, false, sm->a1, sm->a2 - 1);
    append(sm, true, "</a>");
  }}
	goto st260;
tr372:
#line 99 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
#line 151 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append(sm, true, "<a href=\"/posts/");
    append_segment(sm, true, sm->a1, sm->a2 - 1);
    append(sm, true, "\">");
    append(sm, false, "post #");
    append_segment(sm, false, sm->a1, sm->a2 - 1);
    append(sm, true, "</a>");
  }}
	goto st260;
tr375:
#line 99 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
#line 169 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append(sm, true, "<a href=\"/forum_topics/");
    append_segment(sm, true, sm->a1, sm->a2 - 1);
    append(sm, true, "\">");
    append(sm, false, "topic #");
    append_segment(sm, false, sm->a1, sm->a2 - 1);
    append(sm, true, "</a>");
  }}
	goto st260;
tr378:
#line 107 "ext/dtext/dtext.rl"
	{
  sm->b2 = sm->p;
}
#line 178 "ext/dtext/dtext.rl"
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
	goto st260;
tr381:
#line 99 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
#line 209 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append(sm, true, "<a href=\"/users/");
    append_segment(sm, true, sm->a1, sm->a2 - 1);
    append(sm, true, "\">");
    append(sm, false, "user #");
    append_segment(sm, false, sm->a1, sm->a2 - 1);
    append(sm, true, "</a>");
  }}
	goto st260;
tr393:
#line 491 "ext/dtext/dtext.rl"
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
	goto st260;
tr396:
#line 478 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    dstack_rewind(sm);
    {( sm->p) = (( sm->a1 - 1))-1;}
    { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)];goto _again;}
  }}
	goto st260;
tr398:
#line 336 "ext/dtext/dtext.rl"
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
	goto st260;
st260:
#line 1 "NONE"
	{( sm->ts) = 0;}
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof260;
case 260:
#line 1 "NONE"
	{( sm->ts) = ( sm->p);}
#line 2505 "ext/dtext/dtext.c"
	switch( (*( sm->p)) ) {
		case 0: goto tr321;
		case 10: goto tr322;
		case 13: goto st265;
		case 34: goto tr324;
		case 64: goto st268;
		case 65: goto tr326;
		case 67: goto tr327;
		case 70: goto tr328;
		case 73: goto tr329;
		case 80: goto tr330;
		case 84: goto tr331;
		case 85: goto tr332;
		case 91: goto tr333;
		case 97: goto tr326;
		case 99: goto tr327;
		case 102: goto tr328;
		case 104: goto tr334;
		case 105: goto tr329;
		case 112: goto tr330;
		case 116: goto tr331;
		case 117: goto tr332;
		case 123: goto tr335;
	}
	goto tr320;
tr322:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 599 "ext/dtext/dtext.rl"
	{( sm->act) = 43;}
	goto st261;
st261:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof261;
case 261:
#line 2541 "ext/dtext/dtext.c"
	switch( (*( sm->p)) ) {
		case 10: goto tr57;
		case 13: goto st49;
		case 42: goto tr338;
	}
	goto tr336;
tr57:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 587 "ext/dtext/dtext.rl"
	{( sm->act) = 42;}
	goto st262;
st262:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof262;
case 262:
#line 2558 "ext/dtext/dtext.c"
	switch( (*( sm->p)) ) {
		case 10: goto tr57;
		case 13: goto st49;
	}
	goto tr339;
st49:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof49;
case 49:
	if ( (*( sm->p)) == 10 )
		goto tr57;
	goto tr56;
tr338:
#line 95 "ext/dtext/dtext.rl"
	{
  sm->a1 = sm->p;
}
	goto st50;
st50:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof50;
case 50:
#line 2581 "ext/dtext/dtext.c"
	switch( (*( sm->p)) ) {
		case 9: goto tr59;
		case 32: goto tr59;
		case 42: goto st50;
	}
	goto tr58;
tr59:
#line 99 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
	goto st51;
st51:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof51;
case 51:
#line 2598 "ext/dtext/dtext.c"
	switch( (*( sm->p)) ) {
		case 0: goto tr58;
		case 9: goto tr62;
		case 10: goto tr58;
		case 13: goto tr58;
		case 32: goto tr62;
	}
	goto tr61;
tr61:
#line 103 "ext/dtext/dtext.rl"
	{
  sm->b1 = sm->p;
}
	goto st263;
st263:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof263;
case 263:
#line 2617 "ext/dtext/dtext.c"
	switch( (*( sm->p)) ) {
		case 0: goto tr340;
		case 10: goto tr340;
		case 13: goto tr340;
	}
	goto st263;
tr62:
#line 103 "ext/dtext/dtext.rl"
	{
  sm->b1 = sm->p;
}
	goto st264;
st264:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof264;
case 264:
#line 2634 "ext/dtext/dtext.c"
	switch( (*( sm->p)) ) {
		case 0: goto tr340;
		case 9: goto tr62;
		case 10: goto tr340;
		case 13: goto tr340;
		case 32: goto tr62;
	}
	goto tr61;
st265:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof265;
case 265:
	if ( (*( sm->p)) == 10 )
		goto tr322;
	goto tr342;
tr324:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
	goto st266;
st266:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof266;
case 266:
#line 2658 "ext/dtext/dtext.c"
	if ( (*( sm->p)) == 34 )
		goto tr343;
	goto tr344;
tr344:
#line 95 "ext/dtext/dtext.rl"
	{
  sm->a1 = sm->p;
}
	goto st52;
st52:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof52;
case 52:
#line 2672 "ext/dtext/dtext.c"
	if ( (*( sm->p)) == 34 )
		goto tr65;
	goto st52;
tr65:
#line 99 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
	goto st53;
st53:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof53;
case 53:
#line 2686 "ext/dtext/dtext.c"
	if ( (*( sm->p)) == 58 )
		goto st54;
	goto tr63;
st54:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof54;
case 54:
	switch( (*( sm->p)) ) {
		case 47: goto tr67;
		case 91: goto st56;
		case 104: goto tr69;
	}
	goto tr63;
tr67:
#line 103 "ext/dtext/dtext.rl"
	{
  sm->b1 = sm->p;
}
	goto st55;
st55:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof55;
case 55:
#line 2710 "ext/dtext/dtext.c"
	if ( 33 <= (*( sm->p)) && (*( sm->p)) <= 126 )
		goto st267;
	goto tr63;
st267:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof267;
case 267:
	if ( 33 <= (*( sm->p)) && (*( sm->p)) <= 126 )
		goto st267;
	goto tr345;
st56:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof56;
case 56:
	switch( (*( sm->p)) ) {
		case 47: goto tr71;
		case 104: goto tr72;
	}
	goto tr63;
tr71:
#line 103 "ext/dtext/dtext.rl"
	{
  sm->b1 = sm->p;
}
	goto st57;
st57:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof57;
case 57:
#line 2740 "ext/dtext/dtext.c"
	if ( 33 <= (*( sm->p)) && (*( sm->p)) <= 126 )
		goto st58;
	goto tr63;
st58:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof58;
case 58:
	if ( (*( sm->p)) == 93 )
		goto tr74;
	if ( 33 <= (*( sm->p)) && (*( sm->p)) <= 126 )
		goto st58;
	goto tr63;
tr72:
#line 103 "ext/dtext/dtext.rl"
	{
  sm->b1 = sm->p;
}
	goto st59;
st59:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof59;
case 59:
#line 2763 "ext/dtext/dtext.c"
	if ( (*( sm->p)) == 116 )
		goto st60;
	goto tr63;
st60:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof60;
case 60:
	if ( (*( sm->p)) == 116 )
		goto st61;
	goto tr63;
st61:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof61;
case 61:
	if ( (*( sm->p)) == 112 )
		goto st62;
	goto tr63;
st62:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof62;
case 62:
	switch( (*( sm->p)) ) {
		case 58: goto st63;
		case 115: goto st65;
	}
	goto tr63;
st63:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof63;
case 63:
	if ( (*( sm->p)) == 47 )
		goto st64;
	goto tr63;
st64:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof64;
case 64:
	if ( (*( sm->p)) == 47 )
		goto st57;
	goto tr63;
st65:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof65;
case 65:
	if ( (*( sm->p)) == 58 )
		goto st63;
	goto tr63;
tr69:
#line 103 "ext/dtext/dtext.rl"
	{
  sm->b1 = sm->p;
}
	goto st66;
st66:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof66;
case 66:
#line 2821 "ext/dtext/dtext.c"
	if ( (*( sm->p)) == 116 )
		goto st67;
	goto tr63;
st67:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof67;
case 67:
	if ( (*( sm->p)) == 116 )
		goto st68;
	goto tr63;
st68:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof68;
case 68:
	if ( (*( sm->p)) == 112 )
		goto st69;
	goto tr63;
st69:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof69;
case 69:
	switch( (*( sm->p)) ) {
		case 58: goto st70;
		case 115: goto st72;
	}
	goto tr63;
st70:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof70;
case 70:
	if ( (*( sm->p)) == 47 )
		goto st71;
	goto tr63;
st71:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof71;
case 71:
	if ( (*( sm->p)) == 47 )
		goto st55;
	goto tr63;
st72:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof72;
case 72:
	if ( (*( sm->p)) == 58 )
		goto st70;
	goto tr63;
st268:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof268;
case 268:
	if ( 33 <= (*( sm->p)) && (*( sm->p)) <= 126 )
		goto tr346;
	goto tr343;
tr346:
#line 95 "ext/dtext/dtext.rl"
	{
  sm->a1 = sm->p;
}
	goto st269;
st269:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof269;
case 269:
#line 2886 "ext/dtext/dtext.c"
	if ( (*( sm->p)) == 64 )
		goto tr349;
	if ( 33 <= (*( sm->p)) && (*( sm->p)) <= 126 )
		goto tr348;
	goto tr347;
tr348:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 361 "ext/dtext/dtext.rl"
	{( sm->act) = 19;}
	goto st270;
tr349:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 357 "ext/dtext/dtext.rl"
	{( sm->act) = 18;}
	goto st270;
st270:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof270;
case 270:
#line 2908 "ext/dtext/dtext.c"
	if ( 33 <= (*( sm->p)) && (*( sm->p)) <= 126 )
		goto tr348;
	goto tr350;
tr326:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
	goto st271;
st271:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof271;
case 271:
#line 2920 "ext/dtext/dtext.c"
	switch( (*( sm->p)) ) {
		case 82: goto st73;
		case 114: goto st73;
	}
	goto tr343;
st73:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof73;
case 73:
	switch( (*( sm->p)) ) {
		case 84: goto st74;
		case 116: goto st74;
	}
	goto tr63;
st74:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof74;
case 74:
	switch( (*( sm->p)) ) {
		case 73: goto st75;
		case 105: goto st75;
	}
	goto tr63;
st75:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof75;
case 75:
	switch( (*( sm->p)) ) {
		case 83: goto st76;
		case 115: goto st76;
	}
	goto tr63;
st76:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof76;
case 76:
	switch( (*( sm->p)) ) {
		case 84: goto st77;
		case 116: goto st77;
	}
	goto tr63;
st77:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof77;
case 77:
	if ( (*( sm->p)) == 32 )
		goto st78;
	goto tr63;
st78:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof78;
case 78:
	if ( (*( sm->p)) == 35 )
		goto st79;
	goto tr63;
st79:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof79;
case 79:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr95;
	goto tr63;
tr95:
#line 95 "ext/dtext/dtext.rl"
	{
  sm->a1 = sm->p;
}
	goto st272;
st272:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof272;
case 272:
#line 2993 "ext/dtext/dtext.c"
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto st272;
	goto tr352;
tr327:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
	goto st273;
st273:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof273;
case 273:
#line 3005 "ext/dtext/dtext.c"
	switch( (*( sm->p)) ) {
		case 79: goto st80;
		case 111: goto st80;
	}
	goto tr343;
st80:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof80;
case 80:
	switch( (*( sm->p)) ) {
		case 77: goto st81;
		case 109: goto st81;
	}
	goto tr63;
st81:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof81;
case 81:
	switch( (*( sm->p)) ) {
		case 77: goto st82;
		case 109: goto st82;
	}
	goto tr63;
st82:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof82;
case 82:
	switch( (*( sm->p)) ) {
		case 69: goto st83;
		case 101: goto st83;
	}
	goto tr63;
st83:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof83;
case 83:
	switch( (*( sm->p)) ) {
		case 78: goto st84;
		case 110: goto st84;
	}
	goto tr63;
st84:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof84;
case 84:
	switch( (*( sm->p)) ) {
		case 84: goto st85;
		case 116: goto st85;
	}
	goto tr63;
st85:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof85;
case 85:
	if ( (*( sm->p)) == 32 )
		goto st86;
	goto tr63;
st86:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof86;
case 86:
	if ( (*( sm->p)) == 35 )
		goto st87;
	goto tr63;
st87:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof87;
case 87:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr103;
	goto tr63;
tr103:
#line 95 "ext/dtext/dtext.rl"
	{
  sm->a1 = sm->p;
}
	goto st274;
st274:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof274;
case 274:
#line 3087 "ext/dtext/dtext.c"
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto st274;
	goto tr355;
tr328:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
	goto st275;
st275:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof275;
case 275:
#line 3099 "ext/dtext/dtext.c"
	switch( (*( sm->p)) ) {
		case 79: goto st88;
		case 111: goto st88;
	}
	goto tr343;
st88:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof88;
case 88:
	switch( (*( sm->p)) ) {
		case 82: goto st89;
		case 114: goto st89;
	}
	goto tr63;
st89:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof89;
case 89:
	switch( (*( sm->p)) ) {
		case 85: goto st90;
		case 117: goto st90;
	}
	goto tr63;
st90:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof90;
case 90:
	switch( (*( sm->p)) ) {
		case 77: goto st91;
		case 109: goto st91;
	}
	goto tr63;
st91:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof91;
case 91:
	if ( (*( sm->p)) == 32 )
		goto st92;
	goto tr63;
st92:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof92;
case 92:
	if ( (*( sm->p)) == 35 )
		goto st93;
	goto tr63;
st93:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof93;
case 93:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr109;
	goto tr63;
tr109:
#line 95 "ext/dtext/dtext.rl"
	{
  sm->a1 = sm->p;
}
	goto st276;
st276:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof276;
case 276:
#line 3163 "ext/dtext/dtext.c"
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto st276;
	goto tr358;
tr329:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
	goto st277;
st277:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof277;
case 277:
#line 3175 "ext/dtext/dtext.c"
	switch( (*( sm->p)) ) {
		case 83: goto st94;
		case 115: goto st94;
	}
	goto tr343;
st94:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof94;
case 94:
	switch( (*( sm->p)) ) {
		case 83: goto st95;
		case 115: goto st95;
	}
	goto tr63;
st95:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof95;
case 95:
	switch( (*( sm->p)) ) {
		case 85: goto st96;
		case 117: goto st96;
	}
	goto tr63;
st96:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof96;
case 96:
	switch( (*( sm->p)) ) {
		case 69: goto st97;
		case 101: goto st97;
	}
	goto tr63;
st97:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof97;
case 97:
	if ( (*( sm->p)) == 32 )
		goto st98;
	goto tr63;
st98:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof98;
case 98:
	if ( (*( sm->p)) == 35 )
		goto st99;
	goto tr63;
st99:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof99;
case 99:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr115;
	goto tr63;
tr115:
#line 95 "ext/dtext/dtext.rl"
	{
  sm->a1 = sm->p;
}
	goto st278;
st278:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof278;
case 278:
#line 3239 "ext/dtext/dtext.c"
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto st278;
	goto tr361;
tr330:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
	goto st279;
st279:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof279;
case 279:
#line 3251 "ext/dtext/dtext.c"
	switch( (*( sm->p)) ) {
		case 73: goto st100;
		case 79: goto st108;
		case 105: goto st100;
		case 111: goto st108;
	}
	goto tr343;
st100:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof100;
case 100:
	switch( (*( sm->p)) ) {
		case 88: goto st101;
		case 120: goto st101;
	}
	goto tr63;
st101:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof101;
case 101:
	switch( (*( sm->p)) ) {
		case 73: goto st102;
		case 105: goto st102;
	}
	goto tr63;
st102:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof102;
case 102:
	switch( (*( sm->p)) ) {
		case 86: goto st103;
		case 118: goto st103;
	}
	goto tr63;
st103:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof103;
case 103:
	if ( (*( sm->p)) == 32 )
		goto st104;
	goto tr63;
st104:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof104;
case 104:
	if ( (*( sm->p)) == 35 )
		goto st105;
	goto tr63;
st105:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof105;
case 105:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr121;
	goto tr63;
tr121:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 95 "ext/dtext/dtext.rl"
	{
  sm->a1 = sm->p;
}
	goto st280;
tr367:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
	goto st280;
st280:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof280;
case 280:
#line 3323 "ext/dtext/dtext.c"
	if ( (*( sm->p)) == 47 )
		goto tr366;
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr367;
	goto tr365;
tr366:
#line 99 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
	goto st106;
st106:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof106;
case 106:
#line 3339 "ext/dtext/dtext.c"
	if ( (*( sm->p)) == 112 )
		goto st107;
	goto tr122;
st107:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof107;
case 107:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr124;
	goto tr122;
tr124:
#line 103 "ext/dtext/dtext.rl"
	{
  sm->b1 = sm->p;
}
	goto st281;
st281:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof281;
case 281:
#line 3360 "ext/dtext/dtext.c"
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto st281;
	goto tr368;
st108:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof108;
case 108:
	switch( (*( sm->p)) ) {
		case 79: goto st109;
		case 83: goto st113;
		case 111: goto st109;
		case 115: goto st113;
	}
	goto tr63;
st109:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof109;
case 109:
	switch( (*( sm->p)) ) {
		case 76: goto st110;
		case 108: goto st110;
	}
	goto tr63;
st110:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof110;
case 110:
	if ( (*( sm->p)) == 32 )
		goto st111;
	goto tr63;
st111:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof111;
case 111:
	if ( (*( sm->p)) == 35 )
		goto st112;
	goto tr63;
st112:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof112;
case 112:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr130;
	goto tr63;
tr130:
#line 95 "ext/dtext/dtext.rl"
	{
  sm->a1 = sm->p;
}
	goto st282;
st282:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof282;
case 282:
#line 3415 "ext/dtext/dtext.c"
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto st282;
	goto tr370;
st113:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof113;
case 113:
	switch( (*( sm->p)) ) {
		case 84: goto st114;
		case 116: goto st114;
	}
	goto tr63;
st114:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof114;
case 114:
	if ( (*( sm->p)) == 32 )
		goto st115;
	goto tr63;
st115:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof115;
case 115:
	if ( (*( sm->p)) == 35 )
		goto st116;
	goto tr63;
st116:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof116;
case 116:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr134;
	goto tr63;
tr134:
#line 95 "ext/dtext/dtext.rl"
	{
  sm->a1 = sm->p;
}
	goto st283;
st283:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof283;
case 283:
#line 3459 "ext/dtext/dtext.c"
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto st283;
	goto tr372;
tr331:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
	goto st284;
st284:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof284;
case 284:
#line 3471 "ext/dtext/dtext.c"
	switch( (*( sm->p)) ) {
		case 79: goto st117;
		case 111: goto st117;
	}
	goto tr343;
st117:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof117;
case 117:
	switch( (*( sm->p)) ) {
		case 80: goto st118;
		case 112: goto st118;
	}
	goto tr63;
st118:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof118;
case 118:
	switch( (*( sm->p)) ) {
		case 73: goto st119;
		case 105: goto st119;
	}
	goto tr63;
st119:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof119;
case 119:
	switch( (*( sm->p)) ) {
		case 67: goto st120;
		case 99: goto st120;
	}
	goto tr63;
st120:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof120;
case 120:
	if ( (*( sm->p)) == 32 )
		goto st121;
	goto tr63;
st121:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof121;
case 121:
	if ( (*( sm->p)) == 35 )
		goto st122;
	goto tr63;
st122:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof122;
case 122:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr140;
	goto tr63;
tr140:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 95 "ext/dtext/dtext.rl"
	{
  sm->a1 = sm->p;
}
	goto st285;
tr377:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
	goto st285;
st285:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof285;
case 285:
#line 3541 "ext/dtext/dtext.c"
	if ( (*( sm->p)) == 47 )
		goto tr376;
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr377;
	goto tr375;
tr376:
#line 99 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
	goto st123;
st123:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof123;
case 123:
#line 3557 "ext/dtext/dtext.c"
	if ( (*( sm->p)) == 112 )
		goto st124;
	goto tr141;
st124:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof124;
case 124:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr143;
	goto tr141;
tr143:
#line 103 "ext/dtext/dtext.rl"
	{
  sm->b1 = sm->p;
}
	goto st286;
st286:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof286;
case 286:
#line 3578 "ext/dtext/dtext.c"
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto st286;
	goto tr378;
tr332:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
	goto st287;
st287:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof287;
case 287:
#line 3590 "ext/dtext/dtext.c"
	switch( (*( sm->p)) ) {
		case 83: goto st125;
		case 115: goto st125;
	}
	goto tr343;
st125:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof125;
case 125:
	switch( (*( sm->p)) ) {
		case 69: goto st126;
		case 101: goto st126;
	}
	goto tr63;
st126:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof126;
case 126:
	switch( (*( sm->p)) ) {
		case 82: goto st127;
		case 114: goto st127;
	}
	goto tr63;
st127:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof127;
case 127:
	if ( (*( sm->p)) == 32 )
		goto st128;
	goto tr63;
st128:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof128;
case 128:
	if ( (*( sm->p)) == 35 )
		goto st129;
	goto tr63;
st129:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof129;
case 129:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr148;
	goto tr63;
tr148:
#line 95 "ext/dtext/dtext.rl"
	{
  sm->a1 = sm->p;
}
	goto st288;
st288:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof288;
case 288:
#line 3645 "ext/dtext/dtext.c"
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto st288;
	goto tr381;
tr333:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
	goto st289;
st289:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof289;
case 289:
#line 3657 "ext/dtext/dtext.c"
	switch( (*( sm->p)) ) {
		case 47: goto st130;
		case 91: goto st156;
		case 98: goto st162;
		case 101: goto st163;
		case 105: goto st169;
		case 110: goto st170;
		case 113: goto st177;
		case 115: goto st182;
		case 116: goto st189;
		case 117: goto st191;
	}
	goto tr343;
st130:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof130;
case 130:
	switch( (*( sm->p)) ) {
		case 98: goto st131;
		case 101: goto st132;
		case 105: goto st138;
		case 113: goto st139;
		case 115: goto st144;
		case 116: goto st151;
		case 117: goto st155;
	}
	goto tr63;
st131:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof131;
case 131:
	if ( (*( sm->p)) == 93 )
		goto tr156;
	goto tr63;
st132:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof132;
case 132:
	if ( (*( sm->p)) == 120 )
		goto st133;
	goto tr63;
st133:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof133;
case 133:
	if ( (*( sm->p)) == 112 )
		goto st134;
	goto tr63;
st134:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof134;
case 134:
	if ( (*( sm->p)) == 97 )
		goto st135;
	goto tr63;
st135:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof135;
case 135:
	if ( (*( sm->p)) == 110 )
		goto st136;
	goto tr63;
st136:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof136;
case 136:
	if ( (*( sm->p)) == 100 )
		goto st137;
	goto tr63;
st137:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof137;
case 137:
	if ( (*( sm->p)) == 93 )
		goto tr162;
	goto tr63;
st138:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof138;
case 138:
	if ( (*( sm->p)) == 93 )
		goto tr163;
	goto tr63;
st139:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof139;
case 139:
	if ( (*( sm->p)) == 117 )
		goto st140;
	goto tr63;
st140:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof140;
case 140:
	if ( (*( sm->p)) == 111 )
		goto st141;
	goto tr63;
st141:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof141;
case 141:
	if ( (*( sm->p)) == 116 )
		goto st142;
	goto tr63;
st142:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof142;
case 142:
	if ( (*( sm->p)) == 101 )
		goto st143;
	goto tr63;
st143:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof143;
case 143:
	if ( (*( sm->p)) == 93 )
		goto st290;
	goto tr63;
st290:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof290;
case 290:
	if ( (*( sm->p)) == 32 )
		goto st290;
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto st290;
	goto tr393;
st144:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof144;
case 144:
	switch( (*( sm->p)) ) {
		case 93: goto tr169;
		case 112: goto st145;
	}
	goto tr63;
st145:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof145;
case 145:
	if ( (*( sm->p)) == 111 )
		goto st146;
	goto tr63;
st146:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof146;
case 146:
	if ( (*( sm->p)) == 105 )
		goto st147;
	goto tr63;
st147:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof147;
case 147:
	if ( (*( sm->p)) == 108 )
		goto st148;
	goto tr63;
st148:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof148;
case 148:
	if ( (*( sm->p)) == 101 )
		goto st149;
	goto tr63;
st149:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof149;
case 149:
	if ( (*( sm->p)) == 114 )
		goto st150;
	goto tr63;
st150:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof150;
case 150:
	if ( (*( sm->p)) == 93 )
		goto tr176;
	goto tr63;
st151:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof151;
case 151:
	switch( (*( sm->p)) ) {
		case 100: goto st152;
		case 104: goto st153;
		case 110: goto st154;
	}
	goto tr63;
st152:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof152;
case 152:
	if ( (*( sm->p)) == 93 )
		goto tr180;
	goto tr63;
st153:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof153;
case 153:
	if ( (*( sm->p)) == 93 )
		goto tr181;
	goto tr63;
st154:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof154;
case 154:
	if ( (*( sm->p)) == 93 )
		goto tr182;
	goto tr63;
st155:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof155;
case 155:
	if ( (*( sm->p)) == 93 )
		goto tr183;
	goto tr63;
st156:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof156;
case 156:
	switch( (*( sm->p)) ) {
		case 93: goto tr63;
		case 124: goto tr63;
	}
	goto tr184;
tr184:
#line 95 "ext/dtext/dtext.rl"
	{
  sm->a1 = sm->p;
}
	goto st157;
st157:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof157;
case 157:
#line 3893 "ext/dtext/dtext.c"
	switch( (*( sm->p)) ) {
		case 93: goto tr186;
		case 124: goto tr187;
	}
	goto st157;
tr186:
#line 99 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
	goto st158;
st158:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof158;
case 158:
#line 3909 "ext/dtext/dtext.c"
	if ( (*( sm->p)) == 93 )
		goto tr188;
	goto tr63;
tr187:
#line 99 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
	goto st159;
st159:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof159;
case 159:
#line 3923 "ext/dtext/dtext.c"
	if ( (*( sm->p)) == 93 )
		goto tr63;
	goto tr189;
tr189:
#line 103 "ext/dtext/dtext.rl"
	{
  sm->b1 = sm->p;
}
	goto st160;
st160:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof160;
case 160:
#line 3937 "ext/dtext/dtext.c"
	if ( (*( sm->p)) == 93 )
		goto tr191;
	goto st160;
tr191:
#line 107 "ext/dtext/dtext.rl"
	{
  sm->b2 = sm->p;
}
	goto st161;
st161:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof161;
case 161:
#line 3951 "ext/dtext/dtext.c"
	if ( (*( sm->p)) == 93 )
		goto tr192;
	goto tr63;
st162:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof162;
case 162:
	if ( (*( sm->p)) == 93 )
		goto tr193;
	goto tr63;
st163:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof163;
case 163:
	if ( (*( sm->p)) == 120 )
		goto st164;
	goto tr63;
st164:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof164;
case 164:
	if ( (*( sm->p)) == 112 )
		goto st165;
	goto tr63;
st165:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof165;
case 165:
	if ( (*( sm->p)) == 97 )
		goto st166;
	goto tr63;
st166:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof166;
case 166:
	if ( (*( sm->p)) == 110 )
		goto st167;
	goto tr63;
st167:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof167;
case 167:
	if ( (*( sm->p)) == 100 )
		goto st168;
	goto tr63;
st168:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof168;
case 168:
	if ( (*( sm->p)) == 93 )
		goto tr199;
	goto tr63;
st169:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof169;
case 169:
	if ( (*( sm->p)) == 93 )
		goto tr200;
	goto tr63;
st170:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof170;
case 170:
	if ( (*( sm->p)) == 111 )
		goto st171;
	goto tr63;
st171:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof171;
case 171:
	if ( (*( sm->p)) == 100 )
		goto st172;
	goto tr63;
st172:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof172;
case 172:
	if ( (*( sm->p)) == 116 )
		goto st173;
	goto tr63;
st173:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof173;
case 173:
	if ( (*( sm->p)) == 101 )
		goto st174;
	goto tr63;
st174:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof174;
case 174:
	if ( (*( sm->p)) == 120 )
		goto st175;
	goto tr63;
st175:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof175;
case 175:
	if ( (*( sm->p)) == 116 )
		goto st176;
	goto tr63;
st176:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof176;
case 176:
	if ( (*( sm->p)) == 93 )
		goto tr207;
	goto tr63;
st177:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof177;
case 177:
	if ( (*( sm->p)) == 117 )
		goto st178;
	goto tr63;
st178:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof178;
case 178:
	if ( (*( sm->p)) == 111 )
		goto st179;
	goto tr63;
st179:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof179;
case 179:
	if ( (*( sm->p)) == 116 )
		goto st180;
	goto tr63;
st180:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof180;
case 180:
	if ( (*( sm->p)) == 101 )
		goto st181;
	goto tr63;
st181:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof181;
case 181:
	if ( (*( sm->p)) == 93 )
		goto tr212;
	goto tr63;
st182:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof182;
case 182:
	switch( (*( sm->p)) ) {
		case 93: goto tr213;
		case 112: goto st183;
	}
	goto tr63;
st183:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof183;
case 183:
	if ( (*( sm->p)) == 111 )
		goto st184;
	goto tr63;
st184:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof184;
case 184:
	if ( (*( sm->p)) == 105 )
		goto st185;
	goto tr63;
st185:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof185;
case 185:
	if ( (*( sm->p)) == 108 )
		goto st186;
	goto tr63;
st186:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof186;
case 186:
	if ( (*( sm->p)) == 101 )
		goto st187;
	goto tr63;
st187:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof187;
case 187:
	if ( (*( sm->p)) == 114 )
		goto st188;
	goto tr63;
st188:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof188;
case 188:
	if ( (*( sm->p)) == 93 )
		goto tr220;
	goto tr63;
st189:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof189;
case 189:
	if ( (*( sm->p)) == 110 )
		goto st190;
	goto tr63;
st190:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof190;
case 190:
	if ( (*( sm->p)) == 93 )
		goto tr222;
	goto tr63;
st191:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof191;
case 191:
	if ( (*( sm->p)) == 93 )
		goto tr223;
	goto tr63;
tr334:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
	goto st291;
st291:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof291;
case 291:
#line 4175 "ext/dtext/dtext.c"
	if ( (*( sm->p)) == 116 )
		goto st193;
	if ( 49 <= (*( sm->p)) && (*( sm->p)) <= 54 )
		goto tr394;
	goto tr343;
tr394:
#line 95 "ext/dtext/dtext.rl"
	{
  sm->a1 = sm->p;
}
	goto st192;
st192:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof192;
case 192:
#line 4191 "ext/dtext/dtext.c"
	if ( (*( sm->p)) == 46 )
		goto tr224;
	goto tr63;
tr224:
#line 99 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
	goto st292;
st292:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof292;
case 292:
#line 4205 "ext/dtext/dtext.c"
	switch( (*( sm->p)) ) {
		case 9: goto st292;
		case 32: goto st292;
	}
	goto tr396;
st193:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof193;
case 193:
	if ( (*( sm->p)) == 116 )
		goto st194;
	goto tr63;
st194:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof194;
case 194:
	if ( (*( sm->p)) == 112 )
		goto st195;
	goto tr63;
st195:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof195;
case 195:
	switch( (*( sm->p)) ) {
		case 58: goto st196;
		case 115: goto st199;
	}
	goto tr63;
st196:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof196;
case 196:
	if ( (*( sm->p)) == 47 )
		goto st197;
	goto tr63;
st197:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof197;
case 197:
	if ( (*( sm->p)) == 47 )
		goto st198;
	goto tr63;
st198:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof198;
case 198:
	if ( 33 <= (*( sm->p)) && (*( sm->p)) <= 126 )
		goto st293;
	goto tr63;
st293:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof293;
case 293:
	if ( 33 <= (*( sm->p)) && (*( sm->p)) <= 126 )
		goto st293;
	goto tr398;
st199:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof199;
case 199:
	if ( (*( sm->p)) == 58 )
		goto st196;
	goto tr63;
tr335:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
	goto st294;
st294:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof294;
case 294:
#line 4277 "ext/dtext/dtext.c"
	if ( (*( sm->p)) == 123 )
		goto st200;
	goto tr343;
st200:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof200;
case 200:
	if ( (*( sm->p)) == 125 )
		goto tr63;
	goto tr232;
tr232:
#line 95 "ext/dtext/dtext.rl"
	{
  sm->a1 = sm->p;
}
	goto st201;
st201:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof201;
case 201:
#line 4298 "ext/dtext/dtext.c"
	if ( (*( sm->p)) == 125 )
		goto tr234;
	goto st201;
tr234:
#line 99 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
	goto st202;
st202:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof202;
case 202:
#line 4312 "ext/dtext/dtext.c"
	if ( (*( sm->p)) == 125 )
		goto tr235;
	goto tr63;
tr236:
#line 636 "ext/dtext/dtext.rl"
	{{( sm->p) = ((( sm->te)))-1;}{
    append_c_html_escaped(sm, (*( sm->p)));
  }}
	goto st295;
tr241:
#line 622 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    if (dstack_check(sm, BLOCK_CODE)) {
      dstack_rewind(sm);
    } else {
      append(sm, true, "[/code]");
    }
    { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)];goto _again;}
  }}
	goto st295;
tr400:
#line 636 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    append_c_html_escaped(sm, (*( sm->p)));
  }}
	goto st295;
tr401:
#line 631 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    ( sm->p)--;
    { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)];goto _again;}
  }}
	goto st295;
tr403:
#line 636 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append_c_html_escaped(sm, (*( sm->p)));
  }}
	goto st295;
st295:
#line 1 "NONE"
	{( sm->ts) = 0;}
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof295;
case 295:
#line 1 "NONE"
	{( sm->ts) = ( sm->p);}
#line 4360 "ext/dtext/dtext.c"
	switch( (*( sm->p)) ) {
		case 0: goto tr401;
		case 91: goto tr402;
	}
	goto tr400;
tr402:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
	goto st296;
st296:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof296;
case 296:
#line 4374 "ext/dtext/dtext.c"
	if ( (*( sm->p)) == 47 )
		goto st203;
	goto tr403;
st203:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof203;
case 203:
	if ( (*( sm->p)) == 99 )
		goto st204;
	goto tr236;
st204:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof204;
case 204:
	if ( (*( sm->p)) == 111 )
		goto st205;
	goto tr236;
st205:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof205;
case 205:
	if ( (*( sm->p)) == 100 )
		goto st206;
	goto tr236;
st206:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof206;
case 206:
	if ( (*( sm->p)) == 101 )
		goto st207;
	goto tr236;
st207:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof207;
case 207:
	if ( (*( sm->p)) == 93 )
		goto tr241;
	goto tr236;
tr242:
#line 660 "ext/dtext/dtext.rl"
	{{( sm->p) = ((( sm->te)))-1;}{
    append_c_html_escaped(sm, (*( sm->p)));
  }}
	goto st297;
tr250:
#line 642 "ext/dtext/dtext.rl"
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
	goto st297;
tr405:
#line 660 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    append_c_html_escaped(sm, (*( sm->p)));
  }}
	goto st297;
tr406:
#line 655 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    ( sm->p)--;
    { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)];goto _again;}
  }}
	goto st297;
tr408:
#line 660 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append_c_html_escaped(sm, (*( sm->p)));
  }}
	goto st297;
st297:
#line 1 "NONE"
	{( sm->ts) = 0;}
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof297;
case 297:
#line 1 "NONE"
	{( sm->ts) = ( sm->p);}
#line 4461 "ext/dtext/dtext.c"
	switch( (*( sm->p)) ) {
		case 0: goto tr406;
		case 91: goto tr407;
	}
	goto tr405;
tr407:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
	goto st298;
st298:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof298;
case 298:
#line 4475 "ext/dtext/dtext.c"
	if ( (*( sm->p)) == 47 )
		goto st208;
	goto tr408;
st208:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof208;
case 208:
	if ( (*( sm->p)) == 110 )
		goto st209;
	goto tr242;
st209:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof209;
case 209:
	if ( (*( sm->p)) == 111 )
		goto st210;
	goto tr242;
st210:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof210;
case 210:
	if ( (*( sm->p)) == 100 )
		goto st211;
	goto tr242;
st211:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof211;
case 211:
	if ( (*( sm->p)) == 116 )
		goto st212;
	goto tr242;
st212:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof212;
case 212:
	if ( (*( sm->p)) == 101 )
		goto st213;
	goto tr242;
st213:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof213;
case 213:
	if ( (*( sm->p)) == 120 )
		goto st214;
	goto tr242;
st214:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof214;
case 214:
	if ( (*( sm->p)) == 116 )
		goto st215;
	goto tr242;
st215:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof215;
case 215:
	if ( (*( sm->p)) == 93 )
		goto tr250;
	goto tr242;
tr251:
#line 735 "ext/dtext/dtext.rl"
	{{( sm->p) = ((( sm->te)))-1;}}
	goto st299;
tr260:
#line 720 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    if (dstack_check(sm, BLOCK_TABLE)) {
      dstack_pop(sm);
      append_block(sm, "</table>");
      { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)];goto _again;}
    } else {
      append(sm, true, "[/table]");
    }
  }}
	goto st299;
tr264:
#line 685 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    if (dstack_check(sm, BLOCK_TBODY)) {
      dstack_pop(sm);
      append_block(sm, "</tbody>");
    } else {
      append(sm, true, "[/tbody]");
    }
  }}
	goto st299;
tr268:
#line 671 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    if (dstack_check(sm, BLOCK_THEAD)) {
      dstack_pop(sm);
      append_block(sm, "</thead>");
    } else {
      append(sm, true, "[/thead]");
    }
  }}
	goto st299;
tr269:
#line 705 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    if (dstack_check(sm, BLOCK_TR)) {
      dstack_pop(sm);
      append_block(sm, "</tr>");
    } else {
      append(sm, true, "[/tr]");
    }
  }}
	goto st299;
tr277:
#line 680 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_push(sm, &BLOCK_TBODY);
    append_block(sm, "<tbody>");
  }}
	goto st299;
tr278:
#line 714 "ext/dtext/dtext.rl"
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
{( ((int *)sm->stack->data))[( sm->top)++] = 299; goto st260;}}
  }}
	goto st299;
tr279:
#line 694 "ext/dtext/dtext.rl"
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
{( ((int *)sm->stack->data))[( sm->top)++] = 299; goto st260;}}
  }}
	goto st299;
tr283:
#line 666 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_push(sm, &BLOCK_THEAD);
    append_block(sm, "<thead>");
  }}
	goto st299;
tr284:
#line 700 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_push(sm, &BLOCK_TR);
    append_block(sm, "<tr>");
  }}
	goto st299;
tr410:
#line 735 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;}
	goto st299;
tr411:
#line 730 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    ( sm->p)--;
    { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)];goto _again;}
  }}
	goto st299;
tr413:
#line 735 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;}
	goto st299;
st299:
#line 1 "NONE"
	{( sm->ts) = 0;}
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof299;
case 299:
#line 1 "NONE"
	{( sm->ts) = ( sm->p);}
#line 4666 "ext/dtext/dtext.c"
	switch( (*( sm->p)) ) {
		case 0: goto tr411;
		case 91: goto tr412;
	}
	goto tr410;
tr412:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
	goto st300;
st300:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof300;
case 300:
#line 4680 "ext/dtext/dtext.c"
	switch( (*( sm->p)) ) {
		case 47: goto st216;
		case 116: goto st231;
	}
	goto tr413;
st216:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof216;
case 216:
	if ( (*( sm->p)) == 116 )
		goto st217;
	goto tr251;
st217:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof217;
case 217:
	switch( (*( sm->p)) ) {
		case 97: goto st218;
		case 98: goto st222;
		case 104: goto st226;
		case 114: goto st230;
	}
	goto tr251;
st218:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof218;
case 218:
	if ( (*( sm->p)) == 98 )
		goto st219;
	goto tr251;
st219:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof219;
case 219:
	if ( (*( sm->p)) == 108 )
		goto st220;
	goto tr251;
st220:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof220;
case 220:
	if ( (*( sm->p)) == 101 )
		goto st221;
	goto tr251;
st221:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof221;
case 221:
	if ( (*( sm->p)) == 93 )
		goto tr260;
	goto tr251;
st222:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof222;
case 222:
	if ( (*( sm->p)) == 111 )
		goto st223;
	goto tr251;
st223:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof223;
case 223:
	if ( (*( sm->p)) == 100 )
		goto st224;
	goto tr251;
st224:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof224;
case 224:
	if ( (*( sm->p)) == 121 )
		goto st225;
	goto tr251;
st225:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof225;
case 225:
	if ( (*( sm->p)) == 93 )
		goto tr264;
	goto tr251;
st226:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof226;
case 226:
	if ( (*( sm->p)) == 101 )
		goto st227;
	goto tr251;
st227:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof227;
case 227:
	if ( (*( sm->p)) == 97 )
		goto st228;
	goto tr251;
st228:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof228;
case 228:
	if ( (*( sm->p)) == 100 )
		goto st229;
	goto tr251;
st229:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof229;
case 229:
	if ( (*( sm->p)) == 93 )
		goto tr268;
	goto tr251;
st230:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof230;
case 230:
	if ( (*( sm->p)) == 93 )
		goto tr269;
	goto tr251;
st231:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof231;
case 231:
	switch( (*( sm->p)) ) {
		case 98: goto st232;
		case 100: goto st236;
		case 104: goto st237;
		case 114: goto st241;
	}
	goto tr251;
st232:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof232;
case 232:
	if ( (*( sm->p)) == 111 )
		goto st233;
	goto tr251;
st233:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof233;
case 233:
	if ( (*( sm->p)) == 100 )
		goto st234;
	goto tr251;
st234:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof234;
case 234:
	if ( (*( sm->p)) == 121 )
		goto st235;
	goto tr251;
st235:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof235;
case 235:
	if ( (*( sm->p)) == 93 )
		goto tr277;
	goto tr251;
st236:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof236;
case 236:
	if ( (*( sm->p)) == 93 )
		goto tr278;
	goto tr251;
st237:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof237;
case 237:
	switch( (*( sm->p)) ) {
		case 93: goto tr279;
		case 101: goto st238;
	}
	goto tr251;
st238:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof238;
case 238:
	if ( (*( sm->p)) == 97 )
		goto st239;
	goto tr251;
st239:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof239;
case 239:
	if ( (*( sm->p)) == 100 )
		goto st240;
	goto tr251;
st240:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof240;
case 240:
	if ( (*( sm->p)) == 93 )
		goto tr283;
	goto tr251;
st241:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof241;
case 241:
	if ( (*( sm->p)) == 93 )
		goto tr284;
	goto tr251;
tr285:
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
	goto st301;
tr287:
#line 786 "ext/dtext/dtext.rl"
	{{( sm->p) = ((( sm->te)))-1;}{
    dstack_rewind(sm);
    ( sm->p)--;
    { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)];goto _again;}
  }}
	goto st301;
tr416:
#line 786 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_rewind(sm);
    ( sm->p)--;
    { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)];goto _again;}
  }}
	goto st301;
tr417:
#line 778 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_close_list(sm);
    {( sm->p) = (( sm->ts))-1;}
    { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)];goto _again;}
  }}
	goto st301;
tr422:
#line 786 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    dstack_rewind(sm);
    ( sm->p)--;
    { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)];goto _again;}
  }}
	goto st301;
tr423:
#line 107 "ext/dtext/dtext.rl"
	{
  sm->b2 = sm->p;
}
#line 739 "ext/dtext/dtext.rl"
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
{( ((int *)sm->stack->data))[( sm->top)++] = 301; goto st260;}}
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
#line 4989 "ext/dtext/dtext.c"
	switch( (*( sm->p)) ) {
		case 0: goto tr417;
		case 10: goto tr418;
		case 13: goto st303;
		case 42: goto tr420;
	}
	goto tr416;
tr286:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 778 "ext/dtext/dtext.rl"
	{( sm->act) = 64;}
	goto st302;
tr418:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 784 "ext/dtext/dtext.rl"
	{( sm->act) = 65;}
	goto st302;
st302:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof302;
case 302:
#line 5013 "ext/dtext/dtext.c"
	switch( (*( sm->p)) ) {
		case 10: goto tr286;
		case 13: goto st242;
	}
	goto tr285;
st242:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof242;
case 242:
	if ( (*( sm->p)) == 10 )
		goto tr286;
	goto tr285;
st303:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof303;
case 303:
	if ( (*( sm->p)) == 10 )
		goto tr418;
	goto tr422;
tr420:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 95 "ext/dtext/dtext.rl"
	{
  sm->a1 = sm->p;
}
	goto st304;
st304:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof304;
case 304:
#line 5045 "ext/dtext/dtext.c"
	switch( (*( sm->p)) ) {
		case 9: goto tr290;
		case 32: goto tr290;
		case 42: goto st244;
	}
	goto tr422;
tr290:
#line 99 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
	goto st243;
st243:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof243;
case 243:
#line 5062 "ext/dtext/dtext.c"
	switch( (*( sm->p)) ) {
		case 0: goto tr287;
		case 9: goto tr289;
		case 10: goto tr287;
		case 13: goto tr287;
		case 32: goto tr289;
	}
	goto tr288;
tr288:
#line 103 "ext/dtext/dtext.rl"
	{
  sm->b1 = sm->p;
}
	goto st305;
st305:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof305;
case 305:
#line 5081 "ext/dtext/dtext.c"
	switch( (*( sm->p)) ) {
		case 0: goto tr423;
		case 10: goto tr423;
		case 13: goto tr423;
	}
	goto st305;
tr289:
#line 103 "ext/dtext/dtext.rl"
	{
  sm->b1 = sm->p;
}
	goto st306;
st306:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof306;
case 306:
#line 5098 "ext/dtext/dtext.c"
	switch( (*( sm->p)) ) {
		case 0: goto tr423;
		case 9: goto tr289;
		case 10: goto tr423;
		case 13: goto tr423;
		case 32: goto tr289;
	}
	goto tr288;
st244:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof244;
case 244:
	switch( (*( sm->p)) ) {
		case 9: goto tr290;
		case 32: goto tr290;
		case 42: goto st244;
	}
	goto tr287;
	}
	_test_eof245:  sm->cs = 245; goto _test_eof; 
	_test_eof246:  sm->cs = 246; goto _test_eof; 
	_test_eof0:  sm->cs = 0; goto _test_eof; 
	_test_eof247:  sm->cs = 247; goto _test_eof; 
	_test_eof248:  sm->cs = 248; goto _test_eof; 
	_test_eof1:  sm->cs = 1; goto _test_eof; 
	_test_eof249:  sm->cs = 249; goto _test_eof; 
	_test_eof250:  sm->cs = 250; goto _test_eof; 
	_test_eof2:  sm->cs = 2; goto _test_eof; 
	_test_eof251:  sm->cs = 251; goto _test_eof; 
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
	_test_eof252:  sm->cs = 252; goto _test_eof; 
	_test_eof15:  sm->cs = 15; goto _test_eof; 
	_test_eof16:  sm->cs = 16; goto _test_eof; 
	_test_eof17:  sm->cs = 17; goto _test_eof; 
	_test_eof18:  sm->cs = 18; goto _test_eof; 
	_test_eof19:  sm->cs = 19; goto _test_eof; 
	_test_eof20:  sm->cs = 20; goto _test_eof; 
	_test_eof21:  sm->cs = 21; goto _test_eof; 
	_test_eof22:  sm->cs = 22; goto _test_eof; 
	_test_eof253:  sm->cs = 253; goto _test_eof; 
	_test_eof254:  sm->cs = 254; goto _test_eof; 
	_test_eof23:  sm->cs = 23; goto _test_eof; 
	_test_eof24:  sm->cs = 24; goto _test_eof; 
	_test_eof25:  sm->cs = 25; goto _test_eof; 
	_test_eof26:  sm->cs = 26; goto _test_eof; 
	_test_eof27:  sm->cs = 27; goto _test_eof; 
	_test_eof28:  sm->cs = 28; goto _test_eof; 
	_test_eof29:  sm->cs = 29; goto _test_eof; 
	_test_eof255:  sm->cs = 255; goto _test_eof; 
	_test_eof30:  sm->cs = 30; goto _test_eof; 
	_test_eof31:  sm->cs = 31; goto _test_eof; 
	_test_eof32:  sm->cs = 32; goto _test_eof; 
	_test_eof33:  sm->cs = 33; goto _test_eof; 
	_test_eof34:  sm->cs = 34; goto _test_eof; 
	_test_eof256:  sm->cs = 256; goto _test_eof; 
	_test_eof35:  sm->cs = 35; goto _test_eof; 
	_test_eof36:  sm->cs = 36; goto _test_eof; 
	_test_eof37:  sm->cs = 37; goto _test_eof; 
	_test_eof38:  sm->cs = 38; goto _test_eof; 
	_test_eof39:  sm->cs = 39; goto _test_eof; 
	_test_eof40:  sm->cs = 40; goto _test_eof; 
	_test_eof41:  sm->cs = 41; goto _test_eof; 
	_test_eof257:  sm->cs = 257; goto _test_eof; 
	_test_eof42:  sm->cs = 42; goto _test_eof; 
	_test_eof43:  sm->cs = 43; goto _test_eof; 
	_test_eof44:  sm->cs = 44; goto _test_eof; 
	_test_eof45:  sm->cs = 45; goto _test_eof; 
	_test_eof46:  sm->cs = 46; goto _test_eof; 
	_test_eof47:  sm->cs = 47; goto _test_eof; 
	_test_eof258:  sm->cs = 258; goto _test_eof; 
	_test_eof48:  sm->cs = 48; goto _test_eof; 
	_test_eof259:  sm->cs = 259; goto _test_eof; 
	_test_eof260:  sm->cs = 260; goto _test_eof; 
	_test_eof261:  sm->cs = 261; goto _test_eof; 
	_test_eof262:  sm->cs = 262; goto _test_eof; 
	_test_eof49:  sm->cs = 49; goto _test_eof; 
	_test_eof50:  sm->cs = 50; goto _test_eof; 
	_test_eof51:  sm->cs = 51; goto _test_eof; 
	_test_eof263:  sm->cs = 263; goto _test_eof; 
	_test_eof264:  sm->cs = 264; goto _test_eof; 
	_test_eof265:  sm->cs = 265; goto _test_eof; 
	_test_eof266:  sm->cs = 266; goto _test_eof; 
	_test_eof52:  sm->cs = 52; goto _test_eof; 
	_test_eof53:  sm->cs = 53; goto _test_eof; 
	_test_eof54:  sm->cs = 54; goto _test_eof; 
	_test_eof55:  sm->cs = 55; goto _test_eof; 
	_test_eof267:  sm->cs = 267; goto _test_eof; 
	_test_eof56:  sm->cs = 56; goto _test_eof; 
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
	_test_eof268:  sm->cs = 268; goto _test_eof; 
	_test_eof269:  sm->cs = 269; goto _test_eof; 
	_test_eof270:  sm->cs = 270; goto _test_eof; 
	_test_eof271:  sm->cs = 271; goto _test_eof; 
	_test_eof73:  sm->cs = 73; goto _test_eof; 
	_test_eof74:  sm->cs = 74; goto _test_eof; 
	_test_eof75:  sm->cs = 75; goto _test_eof; 
	_test_eof76:  sm->cs = 76; goto _test_eof; 
	_test_eof77:  sm->cs = 77; goto _test_eof; 
	_test_eof78:  sm->cs = 78; goto _test_eof; 
	_test_eof79:  sm->cs = 79; goto _test_eof; 
	_test_eof272:  sm->cs = 272; goto _test_eof; 
	_test_eof273:  sm->cs = 273; goto _test_eof; 
	_test_eof80:  sm->cs = 80; goto _test_eof; 
	_test_eof81:  sm->cs = 81; goto _test_eof; 
	_test_eof82:  sm->cs = 82; goto _test_eof; 
	_test_eof83:  sm->cs = 83; goto _test_eof; 
	_test_eof84:  sm->cs = 84; goto _test_eof; 
	_test_eof85:  sm->cs = 85; goto _test_eof; 
	_test_eof86:  sm->cs = 86; goto _test_eof; 
	_test_eof87:  sm->cs = 87; goto _test_eof; 
	_test_eof274:  sm->cs = 274; goto _test_eof; 
	_test_eof275:  sm->cs = 275; goto _test_eof; 
	_test_eof88:  sm->cs = 88; goto _test_eof; 
	_test_eof89:  sm->cs = 89; goto _test_eof; 
	_test_eof90:  sm->cs = 90; goto _test_eof; 
	_test_eof91:  sm->cs = 91; goto _test_eof; 
	_test_eof92:  sm->cs = 92; goto _test_eof; 
	_test_eof93:  sm->cs = 93; goto _test_eof; 
	_test_eof276:  sm->cs = 276; goto _test_eof; 
	_test_eof277:  sm->cs = 277; goto _test_eof; 
	_test_eof94:  sm->cs = 94; goto _test_eof; 
	_test_eof95:  sm->cs = 95; goto _test_eof; 
	_test_eof96:  sm->cs = 96; goto _test_eof; 
	_test_eof97:  sm->cs = 97; goto _test_eof; 
	_test_eof98:  sm->cs = 98; goto _test_eof; 
	_test_eof99:  sm->cs = 99; goto _test_eof; 
	_test_eof278:  sm->cs = 278; goto _test_eof; 
	_test_eof279:  sm->cs = 279; goto _test_eof; 
	_test_eof100:  sm->cs = 100; goto _test_eof; 
	_test_eof101:  sm->cs = 101; goto _test_eof; 
	_test_eof102:  sm->cs = 102; goto _test_eof; 
	_test_eof103:  sm->cs = 103; goto _test_eof; 
	_test_eof104:  sm->cs = 104; goto _test_eof; 
	_test_eof105:  sm->cs = 105; goto _test_eof; 
	_test_eof280:  sm->cs = 280; goto _test_eof; 
	_test_eof106:  sm->cs = 106; goto _test_eof; 
	_test_eof107:  sm->cs = 107; goto _test_eof; 
	_test_eof281:  sm->cs = 281; goto _test_eof; 
	_test_eof108:  sm->cs = 108; goto _test_eof; 
	_test_eof109:  sm->cs = 109; goto _test_eof; 
	_test_eof110:  sm->cs = 110; goto _test_eof; 
	_test_eof111:  sm->cs = 111; goto _test_eof; 
	_test_eof112:  sm->cs = 112; goto _test_eof; 
	_test_eof282:  sm->cs = 282; goto _test_eof; 
	_test_eof113:  sm->cs = 113; goto _test_eof; 
	_test_eof114:  sm->cs = 114; goto _test_eof; 
	_test_eof115:  sm->cs = 115; goto _test_eof; 
	_test_eof116:  sm->cs = 116; goto _test_eof; 
	_test_eof283:  sm->cs = 283; goto _test_eof; 
	_test_eof284:  sm->cs = 284; goto _test_eof; 
	_test_eof117:  sm->cs = 117; goto _test_eof; 
	_test_eof118:  sm->cs = 118; goto _test_eof; 
	_test_eof119:  sm->cs = 119; goto _test_eof; 
	_test_eof120:  sm->cs = 120; goto _test_eof; 
	_test_eof121:  sm->cs = 121; goto _test_eof; 
	_test_eof122:  sm->cs = 122; goto _test_eof; 
	_test_eof285:  sm->cs = 285; goto _test_eof; 
	_test_eof123:  sm->cs = 123; goto _test_eof; 
	_test_eof124:  sm->cs = 124; goto _test_eof; 
	_test_eof286:  sm->cs = 286; goto _test_eof; 
	_test_eof287:  sm->cs = 287; goto _test_eof; 
	_test_eof125:  sm->cs = 125; goto _test_eof; 
	_test_eof126:  sm->cs = 126; goto _test_eof; 
	_test_eof127:  sm->cs = 127; goto _test_eof; 
	_test_eof128:  sm->cs = 128; goto _test_eof; 
	_test_eof129:  sm->cs = 129; goto _test_eof; 
	_test_eof288:  sm->cs = 288; goto _test_eof; 
	_test_eof289:  sm->cs = 289; goto _test_eof; 
	_test_eof130:  sm->cs = 130; goto _test_eof; 
	_test_eof131:  sm->cs = 131; goto _test_eof; 
	_test_eof132:  sm->cs = 132; goto _test_eof; 
	_test_eof133:  sm->cs = 133; goto _test_eof; 
	_test_eof134:  sm->cs = 134; goto _test_eof; 
	_test_eof135:  sm->cs = 135; goto _test_eof; 
	_test_eof136:  sm->cs = 136; goto _test_eof; 
	_test_eof137:  sm->cs = 137; goto _test_eof; 
	_test_eof138:  sm->cs = 138; goto _test_eof; 
	_test_eof139:  sm->cs = 139; goto _test_eof; 
	_test_eof140:  sm->cs = 140; goto _test_eof; 
	_test_eof141:  sm->cs = 141; goto _test_eof; 
	_test_eof142:  sm->cs = 142; goto _test_eof; 
	_test_eof143:  sm->cs = 143; goto _test_eof; 
	_test_eof290:  sm->cs = 290; goto _test_eof; 
	_test_eof144:  sm->cs = 144; goto _test_eof; 
	_test_eof145:  sm->cs = 145; goto _test_eof; 
	_test_eof146:  sm->cs = 146; goto _test_eof; 
	_test_eof147:  sm->cs = 147; goto _test_eof; 
	_test_eof148:  sm->cs = 148; goto _test_eof; 
	_test_eof149:  sm->cs = 149; goto _test_eof; 
	_test_eof150:  sm->cs = 150; goto _test_eof; 
	_test_eof151:  sm->cs = 151; goto _test_eof; 
	_test_eof152:  sm->cs = 152; goto _test_eof; 
	_test_eof153:  sm->cs = 153; goto _test_eof; 
	_test_eof154:  sm->cs = 154; goto _test_eof; 
	_test_eof155:  sm->cs = 155; goto _test_eof; 
	_test_eof156:  sm->cs = 156; goto _test_eof; 
	_test_eof157:  sm->cs = 157; goto _test_eof; 
	_test_eof158:  sm->cs = 158; goto _test_eof; 
	_test_eof159:  sm->cs = 159; goto _test_eof; 
	_test_eof160:  sm->cs = 160; goto _test_eof; 
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
	_test_eof179:  sm->cs = 179; goto _test_eof; 
	_test_eof180:  sm->cs = 180; goto _test_eof; 
	_test_eof181:  sm->cs = 181; goto _test_eof; 
	_test_eof182:  sm->cs = 182; goto _test_eof; 
	_test_eof183:  sm->cs = 183; goto _test_eof; 
	_test_eof184:  sm->cs = 184; goto _test_eof; 
	_test_eof185:  sm->cs = 185; goto _test_eof; 
	_test_eof186:  sm->cs = 186; goto _test_eof; 
	_test_eof187:  sm->cs = 187; goto _test_eof; 
	_test_eof188:  sm->cs = 188; goto _test_eof; 
	_test_eof189:  sm->cs = 189; goto _test_eof; 
	_test_eof190:  sm->cs = 190; goto _test_eof; 
	_test_eof191:  sm->cs = 191; goto _test_eof; 
	_test_eof291:  sm->cs = 291; goto _test_eof; 
	_test_eof192:  sm->cs = 192; goto _test_eof; 
	_test_eof292:  sm->cs = 292; goto _test_eof; 
	_test_eof193:  sm->cs = 193; goto _test_eof; 
	_test_eof194:  sm->cs = 194; goto _test_eof; 
	_test_eof195:  sm->cs = 195; goto _test_eof; 
	_test_eof196:  sm->cs = 196; goto _test_eof; 
	_test_eof197:  sm->cs = 197; goto _test_eof; 
	_test_eof198:  sm->cs = 198; goto _test_eof; 
	_test_eof293:  sm->cs = 293; goto _test_eof; 
	_test_eof199:  sm->cs = 199; goto _test_eof; 
	_test_eof294:  sm->cs = 294; goto _test_eof; 
	_test_eof200:  sm->cs = 200; goto _test_eof; 
	_test_eof201:  sm->cs = 201; goto _test_eof; 
	_test_eof202:  sm->cs = 202; goto _test_eof; 
	_test_eof295:  sm->cs = 295; goto _test_eof; 
	_test_eof296:  sm->cs = 296; goto _test_eof; 
	_test_eof203:  sm->cs = 203; goto _test_eof; 
	_test_eof204:  sm->cs = 204; goto _test_eof; 
	_test_eof205:  sm->cs = 205; goto _test_eof; 
	_test_eof206:  sm->cs = 206; goto _test_eof; 
	_test_eof207:  sm->cs = 207; goto _test_eof; 
	_test_eof297:  sm->cs = 297; goto _test_eof; 
	_test_eof298:  sm->cs = 298; goto _test_eof; 
	_test_eof208:  sm->cs = 208; goto _test_eof; 
	_test_eof209:  sm->cs = 209; goto _test_eof; 
	_test_eof210:  sm->cs = 210; goto _test_eof; 
	_test_eof211:  sm->cs = 211; goto _test_eof; 
	_test_eof212:  sm->cs = 212; goto _test_eof; 
	_test_eof213:  sm->cs = 213; goto _test_eof; 
	_test_eof214:  sm->cs = 214; goto _test_eof; 
	_test_eof215:  sm->cs = 215; goto _test_eof; 
	_test_eof299:  sm->cs = 299; goto _test_eof; 
	_test_eof300:  sm->cs = 300; goto _test_eof; 
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
	_test_eof301:  sm->cs = 301; goto _test_eof; 
	_test_eof302:  sm->cs = 302; goto _test_eof; 
	_test_eof242:  sm->cs = 242; goto _test_eof; 
	_test_eof303:  sm->cs = 303; goto _test_eof; 
	_test_eof304:  sm->cs = 304; goto _test_eof; 
	_test_eof243:  sm->cs = 243; goto _test_eof; 
	_test_eof305:  sm->cs = 305; goto _test_eof; 
	_test_eof306:  sm->cs = 306; goto _test_eof; 
	_test_eof244:  sm->cs = 244; goto _test_eof; 

	_test_eof: {}
	if ( ( sm->p) == ( sm->eof) )
	{
	switch (  sm->cs ) {
	case 246: goto tr0;
	case 0: goto tr0;
	case 247: goto tr300;
	case 248: goto tr300;
	case 1: goto tr2;
	case 249: goto tr301;
	case 250: goto tr301;
	case 2: goto tr2;
	case 251: goto tr300;
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
	case 252: goto tr310;
	case 15: goto tr2;
	case 16: goto tr2;
	case 17: goto tr2;
	case 18: goto tr2;
	case 19: goto tr2;
	case 20: goto tr2;
	case 21: goto tr2;
	case 22: goto tr2;
	case 253: goto tr311;
	case 254: goto tr313;
	case 23: goto tr2;
	case 24: goto tr2;
	case 25: goto tr2;
	case 26: goto tr2;
	case 27: goto tr2;
	case 28: goto tr2;
	case 29: goto tr2;
	case 255: goto tr314;
	case 30: goto tr2;
	case 31: goto tr2;
	case 32: goto tr2;
	case 33: goto tr2;
	case 34: goto tr2;
	case 256: goto tr315;
	case 35: goto tr2;
	case 36: goto tr2;
	case 37: goto tr2;
	case 38: goto tr2;
	case 39: goto tr2;
	case 40: goto tr2;
	case 41: goto tr2;
	case 257: goto tr316;
	case 42: goto tr2;
	case 43: goto tr2;
	case 44: goto tr2;
	case 45: goto tr2;
	case 46: goto tr2;
	case 47: goto tr2;
	case 258: goto tr300;
	case 48: goto tr2;
	case 259: goto tr318;
	case 261: goto tr336;
	case 262: goto tr339;
	case 49: goto tr56;
	case 50: goto tr58;
	case 51: goto tr58;
	case 263: goto tr340;
	case 264: goto tr340;
	case 265: goto tr342;
	case 266: goto tr343;
	case 52: goto tr63;
	case 53: goto tr63;
	case 54: goto tr63;
	case 55: goto tr63;
	case 267: goto tr345;
	case 56: goto tr63;
	case 57: goto tr63;
	case 58: goto tr63;
	case 59: goto tr63;
	case 60: goto tr63;
	case 61: goto tr63;
	case 62: goto tr63;
	case 63: goto tr63;
	case 64: goto tr63;
	case 65: goto tr63;
	case 66: goto tr63;
	case 67: goto tr63;
	case 68: goto tr63;
	case 69: goto tr63;
	case 70: goto tr63;
	case 71: goto tr63;
	case 72: goto tr63;
	case 268: goto tr343;
	case 269: goto tr347;
	case 270: goto tr350;
	case 271: goto tr343;
	case 73: goto tr63;
	case 74: goto tr63;
	case 75: goto tr63;
	case 76: goto tr63;
	case 77: goto tr63;
	case 78: goto tr63;
	case 79: goto tr63;
	case 272: goto tr352;
	case 273: goto tr343;
	case 80: goto tr63;
	case 81: goto tr63;
	case 82: goto tr63;
	case 83: goto tr63;
	case 84: goto tr63;
	case 85: goto tr63;
	case 86: goto tr63;
	case 87: goto tr63;
	case 274: goto tr355;
	case 275: goto tr343;
	case 88: goto tr63;
	case 89: goto tr63;
	case 90: goto tr63;
	case 91: goto tr63;
	case 92: goto tr63;
	case 93: goto tr63;
	case 276: goto tr358;
	case 277: goto tr343;
	case 94: goto tr63;
	case 95: goto tr63;
	case 96: goto tr63;
	case 97: goto tr63;
	case 98: goto tr63;
	case 99: goto tr63;
	case 278: goto tr361;
	case 279: goto tr343;
	case 100: goto tr63;
	case 101: goto tr63;
	case 102: goto tr63;
	case 103: goto tr63;
	case 104: goto tr63;
	case 105: goto tr63;
	case 280: goto tr365;
	case 106: goto tr122;
	case 107: goto tr122;
	case 281: goto tr368;
	case 108: goto tr63;
	case 109: goto tr63;
	case 110: goto tr63;
	case 111: goto tr63;
	case 112: goto tr63;
	case 282: goto tr370;
	case 113: goto tr63;
	case 114: goto tr63;
	case 115: goto tr63;
	case 116: goto tr63;
	case 283: goto tr372;
	case 284: goto tr343;
	case 117: goto tr63;
	case 118: goto tr63;
	case 119: goto tr63;
	case 120: goto tr63;
	case 121: goto tr63;
	case 122: goto tr63;
	case 285: goto tr375;
	case 123: goto tr141;
	case 124: goto tr141;
	case 286: goto tr378;
	case 287: goto tr343;
	case 125: goto tr63;
	case 126: goto tr63;
	case 127: goto tr63;
	case 128: goto tr63;
	case 129: goto tr63;
	case 288: goto tr381;
	case 289: goto tr343;
	case 130: goto tr63;
	case 131: goto tr63;
	case 132: goto tr63;
	case 133: goto tr63;
	case 134: goto tr63;
	case 135: goto tr63;
	case 136: goto tr63;
	case 137: goto tr63;
	case 138: goto tr63;
	case 139: goto tr63;
	case 140: goto tr63;
	case 141: goto tr63;
	case 142: goto tr63;
	case 143: goto tr63;
	case 290: goto tr393;
	case 144: goto tr63;
	case 145: goto tr63;
	case 146: goto tr63;
	case 147: goto tr63;
	case 148: goto tr63;
	case 149: goto tr63;
	case 150: goto tr63;
	case 151: goto tr63;
	case 152: goto tr63;
	case 153: goto tr63;
	case 154: goto tr63;
	case 155: goto tr63;
	case 156: goto tr63;
	case 157: goto tr63;
	case 158: goto tr63;
	case 159: goto tr63;
	case 160: goto tr63;
	case 161: goto tr63;
	case 162: goto tr63;
	case 163: goto tr63;
	case 164: goto tr63;
	case 165: goto tr63;
	case 166: goto tr63;
	case 167: goto tr63;
	case 168: goto tr63;
	case 169: goto tr63;
	case 170: goto tr63;
	case 171: goto tr63;
	case 172: goto tr63;
	case 173: goto tr63;
	case 174: goto tr63;
	case 175: goto tr63;
	case 176: goto tr63;
	case 177: goto tr63;
	case 178: goto tr63;
	case 179: goto tr63;
	case 180: goto tr63;
	case 181: goto tr63;
	case 182: goto tr63;
	case 183: goto tr63;
	case 184: goto tr63;
	case 185: goto tr63;
	case 186: goto tr63;
	case 187: goto tr63;
	case 188: goto tr63;
	case 189: goto tr63;
	case 190: goto tr63;
	case 191: goto tr63;
	case 291: goto tr343;
	case 192: goto tr63;
	case 292: goto tr396;
	case 193: goto tr63;
	case 194: goto tr63;
	case 195: goto tr63;
	case 196: goto tr63;
	case 197: goto tr63;
	case 198: goto tr63;
	case 293: goto tr398;
	case 199: goto tr63;
	case 294: goto tr343;
	case 200: goto tr63;
	case 201: goto tr63;
	case 202: goto tr63;
	case 296: goto tr403;
	case 203: goto tr236;
	case 204: goto tr236;
	case 205: goto tr236;
	case 206: goto tr236;
	case 207: goto tr236;
	case 298: goto tr408;
	case 208: goto tr242;
	case 209: goto tr242;
	case 210: goto tr242;
	case 211: goto tr242;
	case 212: goto tr242;
	case 213: goto tr242;
	case 214: goto tr242;
	case 215: goto tr242;
	case 300: goto tr413;
	case 216: goto tr251;
	case 217: goto tr251;
	case 218: goto tr251;
	case 219: goto tr251;
	case 220: goto tr251;
	case 221: goto tr251;
	case 222: goto tr251;
	case 223: goto tr251;
	case 224: goto tr251;
	case 225: goto tr251;
	case 226: goto tr251;
	case 227: goto tr251;
	case 228: goto tr251;
	case 229: goto tr251;
	case 230: goto tr251;
	case 231: goto tr251;
	case 232: goto tr251;
	case 233: goto tr251;
	case 234: goto tr251;
	case 235: goto tr251;
	case 236: goto tr251;
	case 237: goto tr251;
	case 238: goto tr251;
	case 239: goto tr251;
	case 240: goto tr251;
	case 241: goto tr251;
	case 302: goto tr285;
	case 242: goto tr285;
	case 303: goto tr422;
	case 304: goto tr422;
	case 243: goto tr287;
	case 305: goto tr423;
	case 306: goto tr423;
	case 244: goto tr287;
	}
	}

	}

#line 1322 "ext/dtext/dtext.rl"

  dstack_close(sm);

  ret = rb_str_new(sm->output->str, sm->output->len);

  free_machine(sm);

  return ret;
}

void Init_dtext() {
  VALUE mDTextRagel = rb_define_module("DTextRagel");
  rb_define_singleton_method(mDTextRagel, "parse", parse, -1);
}
