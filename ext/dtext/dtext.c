
#line 1 "ext/dtext/dtext.rl"
#include <ruby.h>
#include <stdio.h>
#include <stdint.h>
#include <stdbool.h>
#include <glib.h>

// situationally print newlines to make the generated html
// easier to read
#define PRETTY_PRINT 0

typedef struct StateMachine {
  int top;
  int cs;
  int act;
  const char * p;
  const char * pe;
  const char * eof;
  const char * ts;
  const char * te;

  const char * a1;
  const char * a2;
  const char * b1;
  const char * b2;
  bool f_inline;
  bool list_mode;
  GString * output;
  GArray * stack;
  GQueue * dstack;
  int list_nest;
  int d;
  int b;
} StateMachine;

static const int MAX_STACK_DEPTH = 512;
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


#line 887 "ext/dtext/dtext.rl"



#line 67 "ext/dtext/dtext.c"
static const int dtext_start = 238;
static const int dtext_first_final = 238;
static const int dtext_error = -1;

static const int dtext_en_inline = 253;
static const int dtext_en_code = 287;
static const int dtext_en_nodtext = 289;
static const int dtext_en_table = 291;
static const int dtext_en_list = 293;
static const int dtext_en_main = 238;


#line 890 "ext/dtext/dtext.rl"

static inline void underscore_string(char * str, size_t len) {
  for (size_t i=0; i<len; ++i) {
    if (str[i] == ' ') {
      str[i] = '_';
    }
  }
}

static inline void append(StateMachine * sm, const char * s) {
  sm->output = g_string_append(sm->output, s);
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

static inline void append_segment(StateMachine * sm, const char * a, const char * b) {
  sm->output = g_string_append_len(sm->output, a, b - a + 1);
}

static inline void append_segment_uri_escaped(StateMachine * sm, const char * a, const char * b) {
  GString * segment_string = g_string_new_len(a, b - a + 1);
  char * segment = g_uri_escape_string(segment_string->str, G_URI_RESERVED_CHARS_ALLOWED_IN_PATH "#", TRUE);
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
  } else {
    sm->output = g_string_append(sm->output, s);
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

static inline bool dstack_check(StateMachine * sm, int expected_element) {
  int * top = dstack_peek(sm);
  return top && *top == expected_element;
}

static void dstack_print_element(gpointer data, gpointer user_data) {
  printf("%i\n", *(int *)data);
}

static void dstack_dump(StateMachine * sm) {
  g_queue_foreach(sm->dstack, dstack_print_element, NULL);
}

static void dstack_close(StateMachine * sm) {
  while (dstack_peek(sm) != NULL) {
    int * top = dstack_pop(sm);

    switch (*top) {
      case BLOCK_P:
        append_block(sm, "</p>");
        append_newline(sm);
        break;

      case INLINE_SPOILER:
        append(sm, "</span>");
        break;

      case BLOCK_SPOILER:
        append_block(sm, "</p></div>");
        break;

      case BLOCK_QUOTE:
        append_block(sm, "</blockquote>");
        break;

      case BLOCK_EXPAND:
        append_block(sm, "</div></div>");
        break;

      case BLOCK_NODTEXT:
        append_block(sm, "</p>");
        append_newline(sm);
        break;

      case BLOCK_CODE:
        append_block(sm, "</pre>");
        break;

      case BLOCK_TD:
        append_block(sm, "</td>");
        break;

      case INLINE_NODTEXT:
        break;

      case INLINE_B:
        append(sm, "</strong>");
        break;

      case INLINE_I:
        append(sm, "</em>");
        break;

      case INLINE_U:
        append(sm, "</u>");
        break;

      case INLINE_S:
        append(sm, "</s>");
        break;

      case INLINE_TN:
        append(sm, "</span>");
        break;

      case BLOCK_TN:
        append_block(sm, "</p>");
        append_newline(sm);
        break;

      case BLOCK_TABLE:
        append_block(sm, "</table>");
        break;

      case BLOCK_THEAD:
        append_block(sm, "</thead>");
        break;

      case BLOCK_TBODY:
        append_block(sm, "</tbody>");
        break;

      case BLOCK_TR:
        append_block(sm, "</tr>");
        break;

      case BLOCK_UL:
        append_block(sm, "</ul>");
        append_newline(sm);
        break;

      case BLOCK_LI:
        append_block(sm, "</li>");
        append_newline(sm);
        break;
    }
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

static void init_machine(StateMachine * sm, VALUE input) {
  sm->p = RSTRING_PTR(input);
  sm->pe = sm->p + RSTRING_LEN(input);
  sm->eof = sm->pe;
  sm->ts = NULL;
  sm->te = NULL;
  sm->cs = 0;
  sm->act = 0;
  sm->top = 0;
  size_t output_length = RSTRING_LEN(input);
  if (output_length < (INT16_MAX / 2)) {
    output_length *= 2;
  }
  sm->output = g_string_sized_new(output_length);
  sm->a1 = NULL;
  sm->a2 = NULL;
  sm->b1 = NULL;
  sm->b2 = NULL;
  sm->f_inline = false;
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

static VALUE parse(VALUE self, VALUE input) {
  StateMachine * sm = (StateMachine *)g_malloc0(sizeof(StateMachine));
  input = rb_str_cat(input, "\0", 1);
  init_machine(sm, input);

  
#line 327 "ext/dtext/dtext.c"
	{
	 sm->cs = dtext_start;
	( sm->top) = 0;
	( sm->ts) = 0;
	( sm->te) = 0;
	( sm->act) = 0;
	}

#line 1136 "ext/dtext/dtext.rl"
  
#line 338 "ext/dtext/dtext.c"
	{
	if ( ( sm->p) == ( sm->pe) )
		goto _test_eof;
	goto _resume;

_again:
	switch (  sm->cs ) {
		case 238: goto st238;
		case 239: goto st239;
		case 240: goto st240;
		case 0: goto st0;
		case 241: goto st241;
		case 242: goto st242;
		case 1: goto st1;
		case 243: goto st243;
		case 2: goto st2;
		case 3: goto st3;
		case 4: goto st4;
		case 5: goto st5;
		case 244: goto st244;
		case 6: goto st6;
		case 7: goto st7;
		case 8: goto st8;
		case 9: goto st9;
		case 10: goto st10;
		case 11: goto st11;
		case 12: goto st12;
		case 13: goto st13;
		case 245: goto st245;
		case 246: goto st246;
		case 14: goto st14;
		case 15: goto st15;
		case 16: goto st16;
		case 17: goto st17;
		case 18: goto st18;
		case 19: goto st19;
		case 20: goto st20;
		case 247: goto st247;
		case 21: goto st21;
		case 22: goto st22;
		case 23: goto st23;
		case 24: goto st24;
		case 25: goto st25;
		case 248: goto st248;
		case 26: goto st26;
		case 27: goto st27;
		case 28: goto st28;
		case 29: goto st29;
		case 30: goto st30;
		case 31: goto st31;
		case 32: goto st32;
		case 249: goto st249;
		case 33: goto st33;
		case 34: goto st34;
		case 35: goto st35;
		case 36: goto st36;
		case 37: goto st37;
		case 38: goto st38;
		case 250: goto st250;
		case 39: goto st39;
		case 40: goto st40;
		case 251: goto st251;
		case 252: goto st252;
		case 253: goto st253;
		case 254: goto st254;
		case 41: goto st41;
		case 42: goto st42;
		case 43: goto st43;
		case 44: goto st44;
		case 45: goto st45;
		case 46: goto st46;
		case 47: goto st47;
		case 48: goto st48;
		case 49: goto st49;
		case 50: goto st50;
		case 51: goto st51;
		case 52: goto st52;
		case 53: goto st53;
		case 54: goto st54;
		case 55: goto st55;
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
		case 255: goto st255;
		case 68: goto st68;
		case 69: goto st69;
		case 70: goto st70;
		case 71: goto st71;
		case 72: goto st72;
		case 256: goto st256;
		case 257: goto st257;
		case 258: goto st258;
		case 73: goto st73;
		case 74: goto st74;
		case 75: goto st75;
		case 76: goto st76;
		case 259: goto st259;
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
		case 260: goto st260;
		case 261: goto st261;
		case 262: goto st262;
		case 263: goto st263;
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
		case 264: goto st264;
		case 128: goto st128;
		case 129: goto st129;
		case 130: goto st130;
		case 131: goto st131;
		case 132: goto st132;
		case 133: goto st133;
		case 134: goto st134;
		case 265: goto st265;
		case 266: goto st266;
		case 135: goto st135;
		case 136: goto st136;
		case 137: goto st137;
		case 138: goto st138;
		case 139: goto st139;
		case 140: goto st140;
		case 141: goto st141;
		case 142: goto st142;
		case 267: goto st267;
		case 268: goto st268;
		case 143: goto st143;
		case 144: goto st144;
		case 145: goto st145;
		case 146: goto st146;
		case 147: goto st147;
		case 148: goto st148;
		case 269: goto st269;
		case 270: goto st270;
		case 149: goto st149;
		case 150: goto st150;
		case 271: goto st271;
		case 272: goto st272;
		case 151: goto st151;
		case 152: goto st152;
		case 153: goto st153;
		case 154: goto st154;
		case 155: goto st155;
		case 156: goto st156;
		case 273: goto st273;
		case 157: goto st157;
		case 274: goto st274;
		case 158: goto st158;
		case 159: goto st159;
		case 160: goto st160;
		case 161: goto st161;
		case 162: goto st162;
		case 163: goto st163;
		case 275: goto st275;
		case 276: goto st276;
		case 164: goto st164;
		case 165: goto st165;
		case 166: goto st166;
		case 167: goto st167;
		case 168: goto st168;
		case 169: goto st169;
		case 277: goto st277;
		case 170: goto st170;
		case 171: goto st171;
		case 278: goto st278;
		case 172: goto st172;
		case 173: goto st173;
		case 174: goto st174;
		case 175: goto st175;
		case 176: goto st176;
		case 279: goto st279;
		case 177: goto st177;
		case 178: goto st178;
		case 179: goto st179;
		case 180: goto st180;
		case 280: goto st280;
		case 281: goto st281;
		case 181: goto st181;
		case 182: goto st182;
		case 183: goto st183;
		case 184: goto st184;
		case 185: goto st185;
		case 186: goto st186;
		case 282: goto st282;
		case 187: goto st187;
		case 188: goto st188;
		case 283: goto st283;
		case 284: goto st284;
		case 189: goto st189;
		case 190: goto st190;
		case 191: goto st191;
		case 192: goto st192;
		case 193: goto st193;
		case 285: goto st285;
		case 286: goto st286;
		case 194: goto st194;
		case 195: goto st195;
		case 196: goto st196;
		case 287: goto st287;
		case 288: goto st288;
		case 197: goto st197;
		case 198: goto st198;
		case 199: goto st199;
		case 200: goto st200;
		case 201: goto st201;
		case 289: goto st289;
		case 290: goto st290;
		case 202: goto st202;
		case 203: goto st203;
		case 204: goto st204;
		case 205: goto st205;
		case 206: goto st206;
		case 207: goto st207;
		case 208: goto st208;
		case 209: goto st209;
		case 291: goto st291;
		case 292: goto st292;
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
		case 293: goto st293;
		case 294: goto st294;
		case 295: goto st295;
		case 296: goto st296;
		case 236: goto st236;
		case 297: goto st297;
		case 298: goto st298;
		case 237: goto st237;
	default: break;
	}

	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof;
_resume:
	switch (  sm->cs )
	{
tr0:
#line 874 "ext/dtext/dtext.rl"
	{{( sm->p) = ((( sm->te)))-1;}{
    ( sm->p)--;

    if (g_queue_is_empty(sm->dstack)) {
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
{( ((int *)sm->stack->data))[( sm->top)++] = 238; goto st253;}}
  }}
	goto st238;
tr43:
#line 844 "ext/dtext/dtext.rl"
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
{( ((int *)sm->stack->data))[( sm->top)++] = 238; goto st291;}}
  }}
	goto st238;
tr44:
#line 852 "ext/dtext/dtext.rl"
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
{( ((int *)sm->stack->data))[( sm->top)++] = 238; goto st253;}}
  }}
	goto st238;
tr284:
#line 874 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    ( sm->p)--;

    if (g_queue_is_empty(sm->dstack)) {
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
{( ((int *)sm->stack->data))[( sm->top)++] = 238; goto st253;}}
  }}
	goto st238;
tr285:
#line 868 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_close(sm);
  }}
	goto st238;
tr286:
#line 872 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;}
	goto st238;
tr291:
#line 872 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;}
	goto st238;
tr292:
#line 874 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    ( sm->p)--;

    if (g_queue_is_empty(sm->dstack)) {
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
{( ((int *)sm->stack->data))[( sm->top)++] = 238; goto st253;}}
  }}
	goto st238;
tr293:
#line 97 "ext/dtext/dtext.rl"
	{
  sm->b2 = sm->p;
}
#line 860 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    sm->list_nest = 0;
    sm->list_mode = true;
    dstack_close(sm);
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
{( ((int *)sm->stack->data))[( sm->top)++] = 238; goto st293;}}
  }}
	goto st238;
tr301:
#line 803 "ext/dtext/dtext.rl"
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
{( ((int *)sm->stack->data))[( sm->top)++] = 238; goto st287;}}
  }}
	goto st238;
tr302:
#line 823 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    dstack_push(sm, &BLOCK_EXPAND);
    append_newline(sm);
    append_newline(sm);
    append_block(sm, "<div class=\"expandable\"><div class=\"expandable-header\">");
    append(sm, "<span>");
    append_segment_html_escaped(sm, sm->a1, sm->a2);
    append(sm, "</span>");
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
{( ((int *)sm->stack->data))[( sm->top)++] = 238; goto st253;}}
  }}
	goto st238;
tr304:
#line 812 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    dstack_push(sm, &BLOCK_EXPAND);
    append_newline(sm);
    append_newline(sm);
    append_block(sm, "<div class=\"expandable\"><div class=\"expandable-header\">");
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
{( ((int *)sm->stack->data))[( sm->top)++] = 238; goto st253;}}
  }}
	goto st238;
tr305:
#line 837 "ext/dtext/dtext.rl"
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
{( ((int *)sm->stack->data))[( sm->top)++] = 238; goto st289;}}
  }}
	goto st238;
tr306:
#line 784 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
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
{( ((int *)sm->stack->data))[( sm->top)++] = 238; goto st253;}}
  }}
	goto st238;
tr307:
#line 794 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    dstack_push(sm, &BLOCK_SPOILER);
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
{( ((int *)sm->stack->data))[( sm->top)++] = 238; goto st253;}}
  }}
	goto st238;
tr309:
#line 97 "ext/dtext/dtext.rl"
	{
  sm->b2 = sm->p;
}
#line 764 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    char header = *sm->a1;

    if (sm->f_inline) {
      header = '6';
    }

    append_newline(sm);
    append_newline(sm);
    append(sm, "<h");
    append_c(sm, header);
    append_c(sm, '>');
    append_segment(sm, sm->b1, sm->b2 - 1);
    append(sm, "</h");
    append_c(sm, header);
    append(sm, ">");
    append_newline(sm);
    append_newline(sm);
  }}
	goto st238;
st238:
#line 1 "NONE"
	{( sm->ts) = 0;}
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof238;
case 238:
#line 1 "NONE"
	{( sm->ts) = ( sm->p);}
#line 981 "ext/dtext/dtext.c"
	switch( (*( sm->p)) ) {
		case 0: goto tr285;
		case 10: goto tr286;
		case 13: goto st239;
		case 42: goto tr288;
		case 91: goto tr289;
		case 104: goto tr290;
	}
	goto tr284;
st239:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof239;
case 239:
	if ( (*( sm->p)) == 10 )
		goto tr286;
	goto tr291;
tr288:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 85 "ext/dtext/dtext.rl"
	{
  sm->a1 = sm->p;
}
	goto st240;
st240:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof240;
case 240:
#line 1010 "ext/dtext/dtext.c"
	switch( (*( sm->p)) ) {
		case 9: goto tr3;
		case 32: goto tr3;
		case 42: goto st1;
	}
	goto tr292;
tr3:
#line 89 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
	goto st0;
st0:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof0;
case 0:
#line 1027 "ext/dtext/dtext.c"
	switch( (*( sm->p)) ) {
		case 0: goto tr0;
		case 9: goto tr2;
		case 10: goto tr0;
		case 13: goto tr0;
		case 32: goto tr2;
	}
	goto tr1;
tr1:
#line 93 "ext/dtext/dtext.rl"
	{
  sm->b1 = sm->p;
}
	goto st241;
st241:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof241;
case 241:
#line 1046 "ext/dtext/dtext.c"
	switch( (*( sm->p)) ) {
		case 0: goto tr293;
		case 10: goto tr293;
		case 13: goto tr293;
	}
	goto st241;
tr2:
#line 93 "ext/dtext/dtext.rl"
	{
  sm->b1 = sm->p;
}
	goto st242;
st242:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof242;
case 242:
#line 1063 "ext/dtext/dtext.c"
	switch( (*( sm->p)) ) {
		case 0: goto tr293;
		case 9: goto tr2;
		case 10: goto tr293;
		case 13: goto tr293;
		case 32: goto tr2;
	}
	goto tr1;
st1:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1;
case 1:
	switch( (*( sm->p)) ) {
		case 9: goto tr3;
		case 32: goto tr3;
		case 42: goto st1;
	}
	goto tr0;
tr289:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
	goto st243;
st243:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof243;
case 243:
#line 1090 "ext/dtext/dtext.c"
	switch( (*( sm->p)) ) {
		case 99: goto st2;
		case 101: goto st6;
		case 110: goto st14;
		case 113: goto st21;
		case 115: goto st26;
		case 116: goto st33;
	}
	goto tr292;
st2:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof2;
case 2:
	if ( (*( sm->p)) == 111 )
		goto st3;
	goto tr0;
st3:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof3;
case 3:
	if ( (*( sm->p)) == 100 )
		goto st4;
	goto tr0;
st4:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof4;
case 4:
	if ( (*( sm->p)) == 101 )
		goto st5;
	goto tr0;
st5:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof5;
case 5:
	if ( (*( sm->p)) == 93 )
		goto st244;
	goto tr0;
st244:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof244;
case 244:
	if ( (*( sm->p)) == 32 )
		goto st244;
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto st244;
	goto tr301;
st6:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof6;
case 6:
	if ( (*( sm->p)) == 120 )
		goto st7;
	goto tr0;
st7:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof7;
case 7:
	if ( (*( sm->p)) == 112 )
		goto st8;
	goto tr0;
st8:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof8;
case 8:
	if ( (*( sm->p)) == 97 )
		goto st9;
	goto tr0;
st9:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof9;
case 9:
	if ( (*( sm->p)) == 110 )
		goto st10;
	goto tr0;
st10:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof10;
case 10:
	if ( (*( sm->p)) == 100 )
		goto st11;
	goto tr0;
st11:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof11;
case 11:
	switch( (*( sm->p)) ) {
		case 61: goto st12;
		case 93: goto st246;
	}
	goto tr0;
st12:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof12;
case 12:
	if ( (*( sm->p)) == 93 )
		goto tr0;
	goto tr16;
tr16:
#line 85 "ext/dtext/dtext.rl"
	{
  sm->a1 = sm->p;
}
	goto st13;
st13:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof13;
case 13:
#line 1198 "ext/dtext/dtext.c"
	if ( (*( sm->p)) == 93 )
		goto tr18;
	goto st13;
tr18:
#line 89 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
	goto st245;
st245:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof245;
case 245:
#line 1212 "ext/dtext/dtext.c"
	if ( (*( sm->p)) == 32 )
		goto st245;
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto st245;
	goto tr302;
st246:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof246;
case 246:
	if ( (*( sm->p)) == 32 )
		goto st246;
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto st246;
	goto tr304;
st14:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof14;
case 14:
	if ( (*( sm->p)) == 111 )
		goto st15;
	goto tr0;
st15:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof15;
case 15:
	if ( (*( sm->p)) == 100 )
		goto st16;
	goto tr0;
st16:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof16;
case 16:
	if ( (*( sm->p)) == 116 )
		goto st17;
	goto tr0;
st17:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof17;
case 17:
	if ( (*( sm->p)) == 101 )
		goto st18;
	goto tr0;
st18:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof18;
case 18:
	if ( (*( sm->p)) == 120 )
		goto st19;
	goto tr0;
st19:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof19;
case 19:
	if ( (*( sm->p)) == 116 )
		goto st20;
	goto tr0;
st20:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof20;
case 20:
	if ( (*( sm->p)) == 93 )
		goto st247;
	goto tr0;
st247:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof247;
case 247:
	if ( (*( sm->p)) == 32 )
		goto st247;
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto st247;
	goto tr305;
st21:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof21;
case 21:
	if ( (*( sm->p)) == 117 )
		goto st22;
	goto tr0;
st22:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof22;
case 22:
	if ( (*( sm->p)) == 111 )
		goto st23;
	goto tr0;
st23:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof23;
case 23:
	if ( (*( sm->p)) == 116 )
		goto st24;
	goto tr0;
st24:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof24;
case 24:
	if ( (*( sm->p)) == 101 )
		goto st25;
	goto tr0;
st25:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof25;
case 25:
	if ( (*( sm->p)) == 93 )
		goto st248;
	goto tr0;
st248:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof248;
case 248:
	if ( (*( sm->p)) == 32 )
		goto st248;
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto st248;
	goto tr306;
st26:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof26;
case 26:
	if ( (*( sm->p)) == 112 )
		goto st27;
	goto tr0;
st27:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof27;
case 27:
	if ( (*( sm->p)) == 111 )
		goto st28;
	goto tr0;
st28:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof28;
case 28:
	if ( (*( sm->p)) == 105 )
		goto st29;
	goto tr0;
st29:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof29;
case 29:
	if ( (*( sm->p)) == 108 )
		goto st30;
	goto tr0;
st30:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof30;
case 30:
	if ( (*( sm->p)) == 101 )
		goto st31;
	goto tr0;
st31:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof31;
case 31:
	if ( (*( sm->p)) == 114 )
		goto st32;
	goto tr0;
st32:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof32;
case 32:
	if ( (*( sm->p)) == 93 )
		goto st249;
	goto tr0;
st249:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof249;
case 249:
	if ( (*( sm->p)) == 32 )
		goto st249;
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto st249;
	goto tr307;
st33:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof33;
case 33:
	switch( (*( sm->p)) ) {
		case 97: goto st34;
		case 110: goto st38;
	}
	goto tr0;
st34:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof34;
case 34:
	if ( (*( sm->p)) == 98 )
		goto st35;
	goto tr0;
st35:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof35;
case 35:
	if ( (*( sm->p)) == 108 )
		goto st36;
	goto tr0;
st36:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof36;
case 36:
	if ( (*( sm->p)) == 101 )
		goto st37;
	goto tr0;
st37:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof37;
case 37:
	if ( (*( sm->p)) == 93 )
		goto tr43;
	goto tr0;
st38:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof38;
case 38:
	if ( (*( sm->p)) == 93 )
		goto tr44;
	goto tr0;
tr290:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
	goto st250;
st250:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof250;
case 250:
#line 1439 "ext/dtext/dtext.c"
	if ( 49 <= (*( sm->p)) && (*( sm->p)) <= 54 )
		goto tr308;
	goto tr292;
tr308:
#line 85 "ext/dtext/dtext.rl"
	{
  sm->a1 = sm->p;
}
	goto st39;
st39:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof39;
case 39:
#line 1453 "ext/dtext/dtext.c"
	if ( (*( sm->p)) == 46 )
		goto tr45;
	goto tr0;
tr45:
#line 89 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
	goto st40;
st40:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof40;
case 40:
#line 1467 "ext/dtext/dtext.c"
	switch( (*( sm->p)) ) {
		case 0: goto tr0;
		case 9: goto tr47;
		case 10: goto tr0;
		case 13: goto tr0;
		case 32: goto tr47;
	}
	goto tr46;
tr46:
#line 93 "ext/dtext/dtext.rl"
	{
  sm->b1 = sm->p;
}
	goto st251;
st251:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof251;
case 251:
#line 1486 "ext/dtext/dtext.c"
	switch( (*( sm->p)) ) {
		case 0: goto tr309;
		case 10: goto tr309;
		case 13: goto tr309;
	}
	goto st251;
tr47:
#line 93 "ext/dtext/dtext.rl"
	{
  sm->b1 = sm->p;
}
	goto st252;
st252:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof252;
case 252:
#line 1503 "ext/dtext/dtext.c"
	switch( (*( sm->p)) ) {
		case 0: goto tr309;
		case 9: goto tr47;
		case 10: goto tr309;
		case 13: goto tr309;
		case 32: goto tr47;
	}
	goto tr46;
tr48:
#line 1 "NONE"
	{	switch( ( sm->act) ) {
	case 18:
	{{( sm->p) = ((( sm->te)))-1;}
    append_segment(sm, sm->ts, sm->te - 1);
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

    append(sm, "<a rel=\"nofollow\" href=\"/users?name=");
    append_segment_uri_escaped(sm, sm->a1, sm->a2 - sm->d);
    append(sm, "\">@");
    append_segment_html_escaped(sm, sm->a1, sm->a2 - sm->d);
    append(sm, "</a>");

    if (sm->b) {
      append_c_html_escaped(sm, (*( sm->p)));
    }
  }
	break;
	case 41:
	{{( sm->p) = ((( sm->te)))-1;}
    dstack_close(sm);
    sm->list_mode = false;
    {( sm->p) = (( sm->ts))-1;}
    { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)];goto _again;}
  }
	break;
	case 42:
	{{( sm->p) = ((( sm->te)))-1;}
    if (sm->list_mode) {
      if (dstack_check(sm, BLOCK_LI)) {
        dstack_pop(sm);
        append_block(sm, "</li>");
        append_newline(sm);
      }
      ( sm->p)--;
      { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)];goto _again;}
    } else {
      append(sm, "<br>");
      append_newline(sm);
    }
  }
	break;
	case 43:
	{{( sm->p) = ((( sm->te)))-1;}
    append_c_html_escaped(sm, (*( sm->p)));
  }
	break;
	}
	}
	goto st253;
tr62:
#line 501 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    if (dstack_check(sm, BLOCK_EXPAND)) {
      append_newline(sm);
      append_block(sm, "</div></div>");
      append_newline(sm);
      append_newline(sm);
      dstack_pop(sm);
      { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)];goto _again;}
    } else {
      append(sm, "[/expand]");
    }
  }}
	goto st253;
tr67:
#line 454 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    if (dstack_check(sm, BLOCK_P)) {
      dstack_pop(sm);
      append_block(sm, "</p>");
      append_newline(sm);
    } 

    if (dstack_check(sm, BLOCK_QUOTE)) {
      dstack_pop(sm);
      append_newline(sm);
      append_block(sm, "</blockquote>");
      append_newline(sm);
      append_newline(sm);
      { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)];goto _again;}
    } else {
      append(sm, "[/quote]");
    }
  }}
	goto st253;
tr74:
#line 478 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    if (dstack_check(sm, INLINE_SPOILER)) {
      dstack_pop(sm);
      append(sm, "</span>");
    } else if (dstack_check(sm, BLOCK_SPOILER)) {
      dstack_pop(sm);
      append_newline(sm);
      append_block(sm, "</p></div>");
      append_newline(sm);
      append_newline(sm);

      { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)];goto _again;}
    } else {
      append(sm, "[/spoiler]");
    }
  }}
	goto st253;
tr85:
#line 443 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    if (dstack_check(sm, BLOCK_P)) {
      dstack_pop(sm);
      append_block(sm, "</p>");
      append_newline(sm);
    } 

    {( sm->p) = (( sm->p - 6))-1;}
    { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)];goto _again;}
  }}
	goto st253;
tr86:
#line 570 "ext/dtext/dtext.rl"
	{{( sm->p) = ((( sm->te)))-1;}{
    append_c_html_escaped(sm, (*( sm->p)));
  }}
	goto st253;
tr97:
#line 97 "ext/dtext/dtext.rl"
	{
  sm->b2 = sm->p;
}
#line 307 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    append(sm, "<a href=\"");
    append_segment_uri_escaped(sm, sm->b1, sm->b2 - 1);
    append(sm, "\">");
    append_segment_html_escaped(sm, sm->a1, sm->a2 - 1);
    append(sm, "</a>");
  }}
	goto st253;
tr117:
#line 365 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    if (dstack_check(sm, INLINE_B)) {
      dstack_pop(sm);
      append(sm, "</strong>");
    } else {
      append(sm, "[/b]");
    }
  }}
	goto st253;
tr118:
#line 379 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    if (dstack_check(sm, INLINE_I)) {
      dstack_pop(sm);
      append(sm, "</em>");
    } else {
      append(sm, "[/i]");
    }
  }}
	goto st253;
tr119:
#line 393 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    if (dstack_check(sm, INLINE_S)) {
      dstack_pop(sm);
      append(sm, "</s>");
    } else {
      append(sm, "[/s]");
    }
  }}
	goto st253;
tr123:
#line 531 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    if (dstack_check(sm, BLOCK_TD)) {
      dstack_pop(sm);
      append_newline(sm);
      append_block(sm, "</td>");
      append_newline(sm);
      { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)];goto _again;}
    } else {
      append(sm, "[/td]");
    }
  }}
	goto st253;
tr124:
#line 519 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    if (dstack_check(sm, BLOCK_TH)) {
      dstack_pop(sm);
      append_newline(sm);
      append_block(sm, "</th>");
      append_newline(sm);
      { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)];goto _again;}
    } else {
      append(sm, "[/th]");
    }
  }}
	goto st253;
tr125:
#line 421 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    if (dstack_check(sm, BLOCK_TN)) {
      dstack_pop(sm);
      append(sm, "</p>");
      append_newline(sm);
      { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)];goto _again;}
    } else if (dstack_check(sm, INLINE_TN)) {
      dstack_pop(sm);
      append(sm, "</span>");
    } else {
      append(sm, "[/tn]");
    }
  }}
	goto st253;
tr126:
#line 407 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    if (dstack_check(sm, INLINE_U)) {
      dstack_pop(sm);
      append(sm, "</u>");
    } else {
      append(sm, "[/u]");
    }
  }}
	goto st253;
tr131:
#line 245 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    GString * segment = g_string_new_len(sm->a1, sm->a2 - sm->a1);
    underscore_string(segment->str, segment->len);
    GString * lowercase_segment = NULL;

    if (g_utf8_validate(segment->str, -1, NULL)) {
      lowercase_segment = g_string_new(g_utf8_strdown(segment->str, -1));
    } else {
      lowercase_segment = g_string_new(g_ascii_strdown(segment->str, -1));
    }

    append(sm, "<a href=\"/wiki_pages/show_or_new?title=");
    append_segment_uri_escaped(sm, lowercase_segment->str, lowercase_segment->str + lowercase_segment->len - 1);
    append(sm, "\">");
    append_segment_html_escaped(sm, sm->a1, sm->a2 - 1);
    append(sm, "</a>");

    g_string_free(lowercase_segment, TRUE);
    g_string_free(segment, TRUE);
  }}
	goto st253;
tr135:
#line 266 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    GString * segment = g_string_new_len(sm->a1, sm->a2 - sm->a1);
    underscore_string(segment->str, segment->len);
    GString * lowercase_segment = NULL;

    if (g_utf8_validate(segment->str, -1, NULL)) {
      lowercase_segment = g_string_new(g_utf8_strdown(segment->str, -1));
    } else {
      lowercase_segment = g_string_new(g_ascii_strdown(segment->str, -1));
    }

    append(sm, "<a href=\"/wiki_pages/show_or_new?title=");
    append_segment_uri_escaped(sm, lowercase_segment->str, lowercase_segment->str + lowercase_segment->len - 1);
    append(sm, "\">");
    append_segment_html_escaped(sm, sm->b1, sm->b2 - 1);
    append(sm, "</a>");

    g_string_free(lowercase_segment, TRUE);
    g_string_free(segment, TRUE);
  }}
	goto st253;
tr136:
#line 360 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_push(sm, &INLINE_B);
    append(sm, "<strong>");
  }}
	goto st253;
tr137:
#line 374 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_push(sm, &INLINE_I);
    append(sm, "<em>");
  }}
	goto st253;
tr144:
#line 514 "ext/dtext/dtext.rl"
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
{( ((int *)sm->stack->data))[( sm->top)++] = 253; goto st289;}}
  }}
	goto st253;
tr145:
#line 388 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_push(sm, &INLINE_S);
    append(sm, "<s>");
  }}
	goto st253;
tr152:
#line 473 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_push(sm, &INLINE_SPOILER);
    append(sm, "<span class=\"spoiler\">");
  }}
	goto st253;
tr154:
#line 416 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_push(sm, &INLINE_TN);
    append(sm, "<span class=\"tn\">");
  }}
	goto st253;
tr155:
#line 402 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_push(sm, &INLINE_U);
    append(sm, "<u>");
  }}
	goto st253;
tr199:
#line 217 "ext/dtext/dtext.rl"
	{{( sm->p) = ((( sm->te)))-1;}{
    append(sm, "<a href=\"http://www.pixiv.net/member_illust.php?mode=medium&illust_id=");
    append_segment(sm, sm->a1, sm->a2 - 1);
    append(sm, "\">pixiv #");
    append_segment(sm, sm->a1, sm->a2 - 1);
    append(sm, "</a>");
  }}
	goto st253;
tr218:
#line 157 "ext/dtext/dtext.rl"
	{{( sm->p) = ((( sm->te)))-1;}{
    append(sm, "<a href=\"/forum_topics/");
    append_segment(sm, sm->a1, sm->a2 - 1);
    append(sm, "\">topic #");
    append_segment(sm, sm->a1, sm->a2 - 1);
    append(sm, "</a>");
  }}
	goto st253;
tr229:
#line 237 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    append(sm, "<a rel=\"nofollow\" href=\"/posts?tags=");
    append_segment_uri_escaped(sm, sm->a1, sm->a2 - 1);
    append(sm, "\">");
    append_segment_html_escaped(sm, sm->a1, sm->a2 - 1);
    append(sm, "</a>");
  }}
	goto st253;
tr311:
#line 570 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    append_c_html_escaped(sm, (*( sm->p)));
  }}
	goto st253;
tr312:
#line 543 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    ( sm->p)--;
    { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)];goto _again;}
  }}
	goto st253;
tr328:
#line 570 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append_c_html_escaped(sm, (*( sm->p)));
  }}
	goto st253;
tr329:
#line 495 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    dstack_close(sm);
    {( sm->p) = (((sm->p - 8)))-1;}
    { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)];goto _again;}
  }}
	goto st253;
tr331:
#line 555 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    if (sm->list_mode) {
      if (dstack_check(sm, BLOCK_LI)) {
        dstack_pop(sm);
        append_block(sm, "</li>");
        append_newline(sm);
      }
      ( sm->p)--;
      { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)];goto _again;}
    } else {
      append(sm, "<br>");
      append_newline(sm);
    }
  }}
	goto st253;
tr333:
#line 97 "ext/dtext/dtext.rl"
	{
  sm->b2 = sm->p;
}
#line 287 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    if (is_boundary_c((*( sm->p)))) {
      sm->d = 2;
      sm->b = true;
    } else {
      sm->d = 1;
      sm->b = false;
    }

    append(sm, "<a href=\"");
    append_segment_uri_escaped(sm, sm->b1, sm->b2 - sm->d);
    append(sm, "\">");
    append_segment_html_escaped(sm, sm->a1, sm->a2 - 1);
    append(sm, "</a>");

    if (sm->b) {
      append_c_html_escaped(sm, (*( sm->p)));
    }
  }}
	goto st253;
tr335:
#line 89 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
#line 340 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    if (is_boundary_c((*( sm->p)))) {
      sm->b = true;
      sm->d = 2;
    } else {
      sm->b = false;
      sm->d = 1;
    }

    append(sm, "<a rel=\"nofollow\" href=\"/users?name=");
    append_segment_uri_escaped(sm, sm->a1, sm->a2 - sm->d);
    append(sm, "\">@");
    append_segment_html_escaped(sm, sm->a1, sm->a2 - sm->d);
    append(sm, "</a>");

    if (sm->b) {
      append_c_html_escaped(sm, (*( sm->p)));
    }
  }}
	goto st253;
tr338:
#line 89 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
#line 1 "NONE"
	{	switch( ( sm->act) ) {
	case 18:
	{{( sm->p) = ((( sm->te)))-1;}
    append_segment(sm, sm->ts, sm->te - 1);
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

    append(sm, "<a rel=\"nofollow\" href=\"/users?name=");
    append_segment_uri_escaped(sm, sm->a1, sm->a2 - sm->d);
    append(sm, "\">@");
    append_segment_html_escaped(sm, sm->a1, sm->a2 - sm->d);
    append(sm, "</a>");

    if (sm->b) {
      append_c_html_escaped(sm, (*( sm->p)));
    }
  }
	break;
	case 41:
	{{( sm->p) = ((( sm->te)))-1;}
    dstack_close(sm);
    sm->list_mode = false;
    {( sm->p) = (( sm->ts))-1;}
    { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)];goto _again;}
  }
	break;
	case 42:
	{{( sm->p) = ((( sm->te)))-1;}
    if (sm->list_mode) {
      if (dstack_check(sm, BLOCK_LI)) {
        dstack_pop(sm);
        append_block(sm, "</li>");
        append_newline(sm);
      }
      ( sm->p)--;
      { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)];goto _again;}
    } else {
      append(sm, "<br>");
      append_newline(sm);
    }
  }
	break;
	case 43:
	{{( sm->p) = ((( sm->te)))-1;}
    append_c_html_escaped(sm, (*( sm->p)));
  }
	break;
	}
	}
	goto st253;
tr348:
#line 89 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
#line 201 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append(sm, "<a href=\"/artists/");
    append_segment(sm, sm->a1, sm->a2 - 1);
    append(sm, "\">artist #");
    append_segment(sm, sm->a1, sm->a2 - 1);
    append(sm, "</a>");
  }}
	goto st253;
tr351:
#line 89 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
#line 177 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append(sm, "<a href=\"/comments/");
    append_segment(sm, sm->a1, sm->a2 - 1);
    append(sm, "\">comment #");
    append_segment(sm, sm->a1, sm->a2 - 1);
    append(sm, "</a>");
  }}
	goto st253;
tr354:
#line 89 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
#line 149 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append(sm, "<a href=\"/forum_posts/");
    append_segment(sm, sm->a1, sm->a2 - 1);
    append(sm, "\">forum #");
    append_segment(sm, sm->a1, sm->a2 - 1);
    append(sm, "</a>");
  }}
	goto st253;
tr358:
#line 97 "ext/dtext/dtext.rl"
	{
  sm->b2 = sm->p;
}
#line 437 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    dstack_close(sm);
    {( sm->p) = (( sm->a1 - 1))-1;}
    { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)];goto _again;}
  }}
	goto st253;
tr360:
#line 315 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    if (is_boundary_c((*( sm->p)))) {
      sm->b = true;
      sm->d = 2;
    } else {
      sm->b = false;
      sm->d = 1;
    }

    append(sm, "<a href=\"");
    append_segment_uri_escaped(sm, sm->ts, sm->te - sm->d);
    append(sm, "\">");
    append_segment_html_escaped(sm, sm->ts, sm->te - sm->d);
    append(sm, "</a>");

    if (sm->b) {
      append_c_html_escaped(sm, (*( sm->p)));
    }
  }}
	goto st253;
tr362:
#line 89 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
#line 209 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append(sm, "<a href=\"https://github.com/r888888888/danbooru/issues/");
    append_segment(sm, sm->a1, sm->a2 - 1);
    append(sm, "\">issue #");
    append_segment(sm, sm->a1, sm->a2 - 1);
    append(sm, "</a>");
  }}
	goto st253;
tr366:
#line 89 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
#line 217 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append(sm, "<a href=\"http://www.pixiv.net/member_illust.php?mode=medium&illust_id=");
    append_segment(sm, sm->a1, sm->a2 - 1);
    append(sm, "\">pixiv #");
    append_segment(sm, sm->a1, sm->a2 - 1);
    append(sm, "</a>");
  }}
	goto st253;
tr369:
#line 97 "ext/dtext/dtext.rl"
	{
  sm->b2 = sm->p;
}
#line 225 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append(sm, "<a href=\"http://www.pixiv.net/member_illust.php?mode=manga_big&illust_id=");
    append_segment(sm, sm->a1, sm->a2 - 1);
    append(sm, "&page=");
    append_segment(sm, sm->b1, sm->b2 - 1);
    append(sm, "\">pixiv #");
    append_segment(sm, sm->a1, sm->a2 - 1);
    append(sm, "/p");
    append_segment(sm, sm->b1, sm->b2 - 1);
    append(sm, "</a>");
  }}
	goto st253;
tr371:
#line 89 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
#line 185 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append(sm, "<a href=\"/pools/");
    append_segment(sm, sm->a1, sm->a2 - 1);
    append(sm, "\">pool #");
    append_segment(sm, sm->a1, sm->a2 - 1);
    append(sm, "</a>");
  }}
	goto st253;
tr373:
#line 89 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
#line 141 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append(sm, "<a href=\"/posts/");
    append_segment(sm, sm->a1, sm->a2 - 1);
    append(sm, "\">post #");
    append_segment(sm, sm->a1, sm->a2 - 1);
    append(sm, "</a>");
  }}
	goto st253;
tr376:
#line 89 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
#line 157 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append(sm, "<a href=\"/forum_topics/");
    append_segment(sm, sm->a1, sm->a2 - 1);
    append(sm, "\">topic #");
    append_segment(sm, sm->a1, sm->a2 - 1);
    append(sm, "</a>");
  }}
	goto st253;
tr379:
#line 97 "ext/dtext/dtext.rl"
	{
  sm->b2 = sm->p;
}
#line 165 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append(sm, "<a href=\"/forum_topics/");
    append_segment(sm, sm->a1, sm->a2 - 1);
    append(sm, "?page=");
    append_segment(sm, sm->b1, sm->b2 - 1);
    append(sm, "\">topic #");
    append_segment(sm, sm->a1, sm->a2 - 1);
    append(sm, "/p");
    append_segment(sm, sm->b1, sm->b2 - 1);
    append(sm, "</a>");
  }}
	goto st253;
tr382:
#line 89 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
#line 193 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append(sm, "<a href=\"/users/");
    append_segment(sm, sm->a1, sm->a2 - 1);
    append(sm, "\">user #");
    append_segment(sm, sm->a1, sm->a2 - 1);
    append(sm, "</a>");
  }}
	goto st253;
st253:
#line 1 "NONE"
	{( sm->ts) = 0;}
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof253;
case 253:
#line 1 "NONE"
	{( sm->ts) = ( sm->p);}
#line 2250 "ext/dtext/dtext.c"
	switch( (*( sm->p)) ) {
		case 0: goto tr312;
		case 10: goto tr314;
		case 13: goto tr315;
		case 32: goto tr313;
		case 34: goto tr316;
		case 64: goto st260;
		case 91: goto tr318;
		case 97: goto tr319;
		case 99: goto tr320;
		case 102: goto tr321;
		case 104: goto tr322;
		case 105: goto tr323;
		case 112: goto tr324;
		case 116: goto tr325;
		case 117: goto tr326;
		case 123: goto tr327;
	}
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 12 )
		goto tr313;
	goto tr311;
tr313:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 570 "ext/dtext/dtext.rl"
	{( sm->act) = 43;}
	goto st254;
st254:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof254;
case 254:
#line 2282 "ext/dtext/dtext.c"
	switch( (*( sm->p)) ) {
		case 32: goto st41;
		case 91: goto st42;
	}
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto st41;
	goto tr328;
st41:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof41;
case 41:
	switch( (*( sm->p)) ) {
		case 32: goto st41;
		case 91: goto st42;
	}
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto st41;
	goto tr48;
st42:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof42;
case 42:
	switch( (*( sm->p)) ) {
		case 47: goto st43;
		case 101: goto st62;
		case 113: goto st68;
	}
	goto tr48;
st43:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof43;
case 43:
	switch( (*( sm->p)) ) {
		case 101: goto st44;
		case 113: goto st50;
		case 115: goto st55;
	}
	goto tr48;
st44:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof44;
case 44:
	if ( (*( sm->p)) == 120 )
		goto st45;
	goto tr48;
st45:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof45;
case 45:
	if ( (*( sm->p)) == 112 )
		goto st46;
	goto tr48;
st46:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof46;
case 46:
	if ( (*( sm->p)) == 97 )
		goto st47;
	goto tr48;
st47:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof47;
case 47:
	if ( (*( sm->p)) == 110 )
		goto st48;
	goto tr48;
st48:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof48;
case 48:
	if ( (*( sm->p)) == 100 )
		goto st49;
	goto tr48;
st49:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof49;
case 49:
	if ( (*( sm->p)) == 93 )
		goto tr62;
	goto tr48;
st50:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof50;
case 50:
	if ( (*( sm->p)) == 117 )
		goto st51;
	goto tr48;
st51:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof51;
case 51:
	if ( (*( sm->p)) == 111 )
		goto st52;
	goto tr48;
st52:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof52;
case 52:
	if ( (*( sm->p)) == 116 )
		goto st53;
	goto tr48;
st53:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof53;
case 53:
	if ( (*( sm->p)) == 101 )
		goto st54;
	goto tr48;
st54:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof54;
case 54:
	if ( (*( sm->p)) == 93 )
		goto tr67;
	goto tr48;
st55:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof55;
case 55:
	if ( (*( sm->p)) == 112 )
		goto st56;
	goto tr48;
st56:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof56;
case 56:
	if ( (*( sm->p)) == 111 )
		goto st57;
	goto tr48;
st57:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof57;
case 57:
	if ( (*( sm->p)) == 105 )
		goto st58;
	goto tr48;
st58:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof58;
case 58:
	if ( (*( sm->p)) == 108 )
		goto st59;
	goto tr48;
st59:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof59;
case 59:
	if ( (*( sm->p)) == 101 )
		goto st60;
	goto tr48;
st60:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof60;
case 60:
	if ( (*( sm->p)) == 114 )
		goto st61;
	goto tr48;
st61:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof61;
case 61:
	if ( (*( sm->p)) == 93 )
		goto tr74;
	goto tr48;
st62:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof62;
case 62:
	if ( (*( sm->p)) == 120 )
		goto st63;
	goto tr48;
st63:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof63;
case 63:
	if ( (*( sm->p)) == 112 )
		goto st64;
	goto tr48;
st64:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof64;
case 64:
	if ( (*( sm->p)) == 97 )
		goto st65;
	goto tr48;
st65:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof65;
case 65:
	if ( (*( sm->p)) == 110 )
		goto st66;
	goto tr48;
st66:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof66;
case 66:
	if ( (*( sm->p)) == 100 )
		goto st67;
	goto tr48;
st67:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof67;
case 67:
	if ( (*( sm->p)) == 93 )
		goto st255;
	goto tr48;
st255:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof255;
case 255:
	if ( (*( sm->p)) == 32 )
		goto st255;
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto st255;
	goto tr329;
st68:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof68;
case 68:
	if ( (*( sm->p)) == 117 )
		goto st69;
	goto tr48;
st69:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof69;
case 69:
	if ( (*( sm->p)) == 111 )
		goto st70;
	goto tr48;
st70:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof70;
case 70:
	if ( (*( sm->p)) == 116 )
		goto st71;
	goto tr48;
st71:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof71;
case 71:
	if ( (*( sm->p)) == 101 )
		goto st72;
	goto tr48;
st72:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof72;
case 72:
	if ( (*( sm->p)) == 93 )
		goto tr85;
	goto tr48;
tr314:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 555 "ext/dtext/dtext.rl"
	{( sm->act) = 42;}
	goto st256;
tr330:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 548 "ext/dtext/dtext.rl"
	{( sm->act) = 41;}
	goto st256;
st256:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof256;
case 256:
#line 2549 "ext/dtext/dtext.c"
	switch( (*( sm->p)) ) {
		case 10: goto tr330;
		case 13: goto tr330;
		case 32: goto st41;
		case 91: goto st42;
	}
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 12 )
		goto st41;
	goto tr48;
tr315:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 555 "ext/dtext/dtext.rl"
	{( sm->act) = 42;}
	goto st257;
st257:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof257;
case 257:
#line 2569 "ext/dtext/dtext.c"
	switch( (*( sm->p)) ) {
		case 10: goto tr330;
		case 13: goto tr330;
		case 32: goto st41;
		case 91: goto st42;
	}
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 12 )
		goto st41;
	goto tr331;
tr316:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
	goto st258;
st258:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof258;
case 258:
#line 2587 "ext/dtext/dtext.c"
	if ( (*( sm->p)) == 34 )
		goto tr328;
	goto tr332;
tr332:
#line 85 "ext/dtext/dtext.rl"
	{
  sm->a1 = sm->p;
}
	goto st73;
st73:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof73;
case 73:
#line 2601 "ext/dtext/dtext.c"
	if ( (*( sm->p)) == 34 )
		goto tr88;
	goto st73;
tr88:
#line 89 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
	goto st74;
st74:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof74;
case 74:
#line 2615 "ext/dtext/dtext.c"
	if ( (*( sm->p)) == 58 )
		goto st75;
	goto tr86;
st75:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof75;
case 75:
	switch( (*( sm->p)) ) {
		case 47: goto tr90;
		case 91: goto st77;
		case 104: goto tr92;
	}
	goto tr86;
tr90:
#line 93 "ext/dtext/dtext.rl"
	{
  sm->b1 = sm->p;
}
	goto st76;
st76:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof76;
case 76:
#line 2639 "ext/dtext/dtext.c"
	if ( 33 <= (*( sm->p)) && (*( sm->p)) <= 126 )
		goto st259;
	goto tr86;
st259:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof259;
case 259:
	if ( 33 <= (*( sm->p)) && (*( sm->p)) <= 126 )
		goto st259;
	goto tr333;
st77:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof77;
case 77:
	switch( (*( sm->p)) ) {
		case 47: goto tr94;
		case 104: goto tr95;
	}
	goto tr86;
tr94:
#line 93 "ext/dtext/dtext.rl"
	{
  sm->b1 = sm->p;
}
	goto st78;
st78:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof78;
case 78:
#line 2669 "ext/dtext/dtext.c"
	if ( 33 <= (*( sm->p)) && (*( sm->p)) <= 126 )
		goto st79;
	goto tr86;
st79:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof79;
case 79:
	if ( (*( sm->p)) == 93 )
		goto tr97;
	if ( 33 <= (*( sm->p)) && (*( sm->p)) <= 126 )
		goto st79;
	goto tr86;
tr95:
#line 93 "ext/dtext/dtext.rl"
	{
  sm->b1 = sm->p;
}
	goto st80;
st80:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof80;
case 80:
#line 2692 "ext/dtext/dtext.c"
	if ( (*( sm->p)) == 116 )
		goto st81;
	goto tr86;
st81:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof81;
case 81:
	if ( (*( sm->p)) == 116 )
		goto st82;
	goto tr86;
st82:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof82;
case 82:
	if ( (*( sm->p)) == 112 )
		goto st83;
	goto tr86;
st83:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof83;
case 83:
	switch( (*( sm->p)) ) {
		case 58: goto st84;
		case 115: goto st86;
	}
	goto tr86;
st84:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof84;
case 84:
	if ( (*( sm->p)) == 47 )
		goto st85;
	goto tr86;
st85:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof85;
case 85:
	if ( (*( sm->p)) == 47 )
		goto st78;
	goto tr86;
st86:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof86;
case 86:
	if ( (*( sm->p)) == 58 )
		goto st84;
	goto tr86;
tr92:
#line 93 "ext/dtext/dtext.rl"
	{
  sm->b1 = sm->p;
}
	goto st87;
st87:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof87;
case 87:
#line 2750 "ext/dtext/dtext.c"
	if ( (*( sm->p)) == 116 )
		goto st88;
	goto tr86;
st88:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof88;
case 88:
	if ( (*( sm->p)) == 116 )
		goto st89;
	goto tr86;
st89:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof89;
case 89:
	if ( (*( sm->p)) == 112 )
		goto st90;
	goto tr86;
st90:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof90;
case 90:
	switch( (*( sm->p)) ) {
		case 58: goto st91;
		case 115: goto st93;
	}
	goto tr86;
st91:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof91;
case 91:
	if ( (*( sm->p)) == 47 )
		goto st92;
	goto tr86;
st92:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof92;
case 92:
	if ( (*( sm->p)) == 47 )
		goto st76;
	goto tr86;
st93:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof93;
case 93:
	if ( (*( sm->p)) == 58 )
		goto st91;
	goto tr86;
st260:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof260;
case 260:
	if ( 33 <= (*( sm->p)) && (*( sm->p)) <= 126 )
		goto tr334;
	goto tr328;
tr334:
#line 85 "ext/dtext/dtext.rl"
	{
  sm->a1 = sm->p;
}
	goto st261;
st261:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof261;
case 261:
#line 2815 "ext/dtext/dtext.c"
	if ( (*( sm->p)) == 64 )
		goto tr337;
	if ( 33 <= (*( sm->p)) && (*( sm->p)) <= 126 )
		goto tr336;
	goto tr335;
tr336:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 340 "ext/dtext/dtext.rl"
	{( sm->act) = 19;}
	goto st262;
tr337:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 336 "ext/dtext/dtext.rl"
	{( sm->act) = 18;}
	goto st262;
st262:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof262;
case 262:
#line 2837 "ext/dtext/dtext.c"
	if ( 33 <= (*( sm->p)) && (*( sm->p)) <= 126 )
		goto tr336;
	goto tr338;
tr318:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 570 "ext/dtext/dtext.rl"
	{( sm->act) = 43;}
	goto st263;
st263:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof263;
case 263:
#line 2851 "ext/dtext/dtext.c"
	switch( (*( sm->p)) ) {
		case 47: goto st94;
		case 91: goto st103;
		case 98: goto st109;
		case 101: goto st62;
		case 105: goto st110;
		case 110: goto st111;
		case 113: goto st68;
		case 115: goto st118;
		case 116: goto st125;
		case 117: goto st127;
	}
	goto tr328;
st94:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof94;
case 94:
	switch( (*( sm->p)) ) {
		case 98: goto st95;
		case 101: goto st44;
		case 105: goto st96;
		case 113: goto st50;
		case 115: goto st97;
		case 116: goto st98;
		case 117: goto st102;
	}
	goto tr86;
st95:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof95;
case 95:
	if ( (*( sm->p)) == 93 )
		goto tr117;
	goto tr86;
st96:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof96;
case 96:
	if ( (*( sm->p)) == 93 )
		goto tr118;
	goto tr86;
st97:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof97;
case 97:
	switch( (*( sm->p)) ) {
		case 93: goto tr119;
		case 112: goto st56;
	}
	goto tr86;
st98:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof98;
case 98:
	switch( (*( sm->p)) ) {
		case 100: goto st99;
		case 104: goto st100;
		case 110: goto st101;
	}
	goto tr86;
st99:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof99;
case 99:
	if ( (*( sm->p)) == 93 )
		goto tr123;
	goto tr86;
st100:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof100;
case 100:
	if ( (*( sm->p)) == 93 )
		goto tr124;
	goto tr86;
st101:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof101;
case 101:
	if ( (*( sm->p)) == 93 )
		goto tr125;
	goto tr86;
st102:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof102;
case 102:
	if ( (*( sm->p)) == 93 )
		goto tr126;
	goto tr86;
st103:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof103;
case 103:
	switch( (*( sm->p)) ) {
		case 93: goto tr86;
		case 124: goto tr86;
	}
	goto tr127;
tr127:
#line 85 "ext/dtext/dtext.rl"
	{
  sm->a1 = sm->p;
}
	goto st104;
st104:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof104;
case 104:
#line 2959 "ext/dtext/dtext.c"
	switch( (*( sm->p)) ) {
		case 93: goto tr129;
		case 124: goto tr130;
	}
	goto st104;
tr129:
#line 89 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
	goto st105;
st105:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof105;
case 105:
#line 2975 "ext/dtext/dtext.c"
	if ( (*( sm->p)) == 93 )
		goto tr131;
	goto tr86;
tr130:
#line 89 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
	goto st106;
st106:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof106;
case 106:
#line 2989 "ext/dtext/dtext.c"
	if ( (*( sm->p)) == 93 )
		goto tr86;
	goto tr132;
tr132:
#line 93 "ext/dtext/dtext.rl"
	{
  sm->b1 = sm->p;
}
	goto st107;
st107:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof107;
case 107:
#line 3003 "ext/dtext/dtext.c"
	if ( (*( sm->p)) == 93 )
		goto tr134;
	goto st107;
tr134:
#line 97 "ext/dtext/dtext.rl"
	{
  sm->b2 = sm->p;
}
	goto st108;
st108:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof108;
case 108:
#line 3017 "ext/dtext/dtext.c"
	if ( (*( sm->p)) == 93 )
		goto tr135;
	goto tr86;
st109:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof109;
case 109:
	if ( (*( sm->p)) == 93 )
		goto tr136;
	goto tr86;
st110:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof110;
case 110:
	if ( (*( sm->p)) == 93 )
		goto tr137;
	goto tr86;
st111:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof111;
case 111:
	if ( (*( sm->p)) == 111 )
		goto st112;
	goto tr86;
st112:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof112;
case 112:
	if ( (*( sm->p)) == 100 )
		goto st113;
	goto tr86;
st113:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof113;
case 113:
	if ( (*( sm->p)) == 116 )
		goto st114;
	goto tr86;
st114:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof114;
case 114:
	if ( (*( sm->p)) == 101 )
		goto st115;
	goto tr86;
st115:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof115;
case 115:
	if ( (*( sm->p)) == 120 )
		goto st116;
	goto tr86;
st116:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof116;
case 116:
	if ( (*( sm->p)) == 116 )
		goto st117;
	goto tr86;
st117:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof117;
case 117:
	if ( (*( sm->p)) == 93 )
		goto tr144;
	goto tr86;
st118:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof118;
case 118:
	switch( (*( sm->p)) ) {
		case 93: goto tr145;
		case 112: goto st119;
	}
	goto tr86;
st119:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof119;
case 119:
	if ( (*( sm->p)) == 111 )
		goto st120;
	goto tr86;
st120:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof120;
case 120:
	if ( (*( sm->p)) == 105 )
		goto st121;
	goto tr86;
st121:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof121;
case 121:
	if ( (*( sm->p)) == 108 )
		goto st122;
	goto tr86;
st122:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof122;
case 122:
	if ( (*( sm->p)) == 101 )
		goto st123;
	goto tr86;
st123:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof123;
case 123:
	if ( (*( sm->p)) == 114 )
		goto st124;
	goto tr86;
st124:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof124;
case 124:
	if ( (*( sm->p)) == 93 )
		goto tr152;
	goto tr86;
st125:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof125;
case 125:
	if ( (*( sm->p)) == 110 )
		goto st126;
	goto tr86;
st126:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof126;
case 126:
	if ( (*( sm->p)) == 93 )
		goto tr154;
	goto tr86;
st127:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof127;
case 127:
	if ( (*( sm->p)) == 93 )
		goto tr155;
	goto tr86;
tr319:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
	goto st264;
st264:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof264;
case 264:
#line 3164 "ext/dtext/dtext.c"
	if ( (*( sm->p)) == 114 )
		goto st128;
	goto tr328;
st128:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof128;
case 128:
	if ( (*( sm->p)) == 116 )
		goto st129;
	goto tr86;
st129:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof129;
case 129:
	if ( (*( sm->p)) == 105 )
		goto st130;
	goto tr86;
st130:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof130;
case 130:
	if ( (*( sm->p)) == 115 )
		goto st131;
	goto tr86;
st131:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof131;
case 131:
	if ( (*( sm->p)) == 116 )
		goto st132;
	goto tr86;
st132:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof132;
case 132:
	if ( (*( sm->p)) == 32 )
		goto st133;
	goto tr86;
st133:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof133;
case 133:
	if ( (*( sm->p)) == 35 )
		goto st134;
	goto tr86;
st134:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof134;
case 134:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr162;
	goto tr86;
tr162:
#line 85 "ext/dtext/dtext.rl"
	{
  sm->a1 = sm->p;
}
	goto st265;
st265:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof265;
case 265:
#line 3227 "ext/dtext/dtext.c"
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto st265;
	goto tr348;
tr320:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
	goto st266;
st266:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof266;
case 266:
#line 3239 "ext/dtext/dtext.c"
	if ( (*( sm->p)) == 111 )
		goto st135;
	goto tr328;
st135:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof135;
case 135:
	if ( (*( sm->p)) == 109 )
		goto st136;
	goto tr86;
st136:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof136;
case 136:
	if ( (*( sm->p)) == 109 )
		goto st137;
	goto tr86;
st137:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof137;
case 137:
	if ( (*( sm->p)) == 101 )
		goto st138;
	goto tr86;
st138:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof138;
case 138:
	if ( (*( sm->p)) == 110 )
		goto st139;
	goto tr86;
st139:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof139;
case 139:
	if ( (*( sm->p)) == 116 )
		goto st140;
	goto tr86;
st140:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof140;
case 140:
	if ( (*( sm->p)) == 32 )
		goto st141;
	goto tr86;
st141:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof141;
case 141:
	if ( (*( sm->p)) == 35 )
		goto st142;
	goto tr86;
st142:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof142;
case 142:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr170;
	goto tr86;
tr170:
#line 85 "ext/dtext/dtext.rl"
	{
  sm->a1 = sm->p;
}
	goto st267;
st267:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof267;
case 267:
#line 3309 "ext/dtext/dtext.c"
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto st267;
	goto tr351;
tr321:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
	goto st268;
st268:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof268;
case 268:
#line 3321 "ext/dtext/dtext.c"
	if ( (*( sm->p)) == 111 )
		goto st143;
	goto tr328;
st143:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof143;
case 143:
	if ( (*( sm->p)) == 114 )
		goto st144;
	goto tr86;
st144:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof144;
case 144:
	if ( (*( sm->p)) == 117 )
		goto st145;
	goto tr86;
st145:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof145;
case 145:
	if ( (*( sm->p)) == 109 )
		goto st146;
	goto tr86;
st146:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof146;
case 146:
	if ( (*( sm->p)) == 32 )
		goto st147;
	goto tr86;
st147:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof147;
case 147:
	if ( (*( sm->p)) == 35 )
		goto st148;
	goto tr86;
st148:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof148;
case 148:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr176;
	goto tr86;
tr176:
#line 85 "ext/dtext/dtext.rl"
	{
  sm->a1 = sm->p;
}
	goto st269;
st269:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof269;
case 269:
#line 3377 "ext/dtext/dtext.c"
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto st269;
	goto tr354;
tr322:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
	goto st270;
st270:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof270;
case 270:
#line 3389 "ext/dtext/dtext.c"
	if ( (*( sm->p)) == 116 )
		goto st151;
	if ( 49 <= (*( sm->p)) && (*( sm->p)) <= 54 )
		goto tr356;
	goto tr328;
tr356:
#line 85 "ext/dtext/dtext.rl"
	{
  sm->a1 = sm->p;
}
	goto st149;
st149:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof149;
case 149:
#line 3405 "ext/dtext/dtext.c"
	if ( (*( sm->p)) == 46 )
		goto tr177;
	goto tr86;
tr177:
#line 89 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
	goto st150;
st150:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof150;
case 150:
#line 3419 "ext/dtext/dtext.c"
	switch( (*( sm->p)) ) {
		case 0: goto tr86;
		case 9: goto tr179;
		case 10: goto tr86;
		case 13: goto tr86;
		case 32: goto tr179;
	}
	goto tr178;
tr178:
#line 93 "ext/dtext/dtext.rl"
	{
  sm->b1 = sm->p;
}
	goto st271;
st271:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof271;
case 271:
#line 3438 "ext/dtext/dtext.c"
	switch( (*( sm->p)) ) {
		case 0: goto tr358;
		case 10: goto tr358;
		case 13: goto tr358;
	}
	goto st271;
tr179:
#line 93 "ext/dtext/dtext.rl"
	{
  sm->b1 = sm->p;
}
	goto st272;
st272:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof272;
case 272:
#line 3455 "ext/dtext/dtext.c"
	switch( (*( sm->p)) ) {
		case 0: goto tr358;
		case 9: goto tr179;
		case 10: goto tr358;
		case 13: goto tr358;
		case 32: goto tr179;
	}
	goto tr178;
st151:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof151;
case 151:
	if ( (*( sm->p)) == 116 )
		goto st152;
	goto tr86;
st152:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof152;
case 152:
	if ( (*( sm->p)) == 112 )
		goto st153;
	goto tr86;
st153:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof153;
case 153:
	switch( (*( sm->p)) ) {
		case 58: goto st154;
		case 115: goto st157;
	}
	goto tr86;
st154:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof154;
case 154:
	if ( (*( sm->p)) == 47 )
		goto st155;
	goto tr86;
st155:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof155;
case 155:
	if ( (*( sm->p)) == 47 )
		goto st156;
	goto tr86;
st156:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof156;
case 156:
	if ( 33 <= (*( sm->p)) && (*( sm->p)) <= 126 )
		goto st273;
	goto tr86;
st273:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof273;
case 273:
	if ( 33 <= (*( sm->p)) && (*( sm->p)) <= 126 )
		goto st273;
	goto tr360;
st157:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof157;
case 157:
	if ( (*( sm->p)) == 58 )
		goto st154;
	goto tr86;
tr323:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
	goto st274;
st274:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof274;
case 274:
#line 3530 "ext/dtext/dtext.c"
	if ( (*( sm->p)) == 115 )
		goto st158;
	goto tr328;
st158:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof158;
case 158:
	if ( (*( sm->p)) == 115 )
		goto st159;
	goto tr86;
st159:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof159;
case 159:
	if ( (*( sm->p)) == 117 )
		goto st160;
	goto tr86;
st160:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof160;
case 160:
	if ( (*( sm->p)) == 101 )
		goto st161;
	goto tr86;
st161:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof161;
case 161:
	if ( (*( sm->p)) == 32 )
		goto st162;
	goto tr86;
st162:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof162;
case 162:
	if ( (*( sm->p)) == 35 )
		goto st163;
	goto tr86;
st163:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof163;
case 163:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr192;
	goto tr86;
tr192:
#line 85 "ext/dtext/dtext.rl"
	{
  sm->a1 = sm->p;
}
	goto st275;
st275:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof275;
case 275:
#line 3586 "ext/dtext/dtext.c"
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto st275;
	goto tr362;
tr324:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
	goto st276;
st276:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof276;
case 276:
#line 3598 "ext/dtext/dtext.c"
	switch( (*( sm->p)) ) {
		case 105: goto st164;
		case 111: goto st172;
	}
	goto tr328;
st164:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof164;
case 164:
	if ( (*( sm->p)) == 120 )
		goto st165;
	goto tr86;
st165:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof165;
case 165:
	if ( (*( sm->p)) == 105 )
		goto st166;
	goto tr86;
st166:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof166;
case 166:
	if ( (*( sm->p)) == 118 )
		goto st167;
	goto tr86;
st167:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof167;
case 167:
	if ( (*( sm->p)) == 32 )
		goto st168;
	goto tr86;
st168:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof168;
case 168:
	if ( (*( sm->p)) == 35 )
		goto st169;
	goto tr86;
st169:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof169;
case 169:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr198;
	goto tr86;
tr198:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 85 "ext/dtext/dtext.rl"
	{
  sm->a1 = sm->p;
}
	goto st277;
tr368:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
	goto st277;
st277:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof277;
case 277:
#line 3662 "ext/dtext/dtext.c"
	if ( (*( sm->p)) == 47 )
		goto tr367;
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr368;
	goto tr366;
tr367:
#line 89 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
	goto st170;
st170:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof170;
case 170:
#line 3678 "ext/dtext/dtext.c"
	if ( (*( sm->p)) == 112 )
		goto st171;
	goto tr199;
st171:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof171;
case 171:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr201;
	goto tr199;
tr201:
#line 93 "ext/dtext/dtext.rl"
	{
  sm->b1 = sm->p;
}
	goto st278;
st278:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof278;
case 278:
#line 3699 "ext/dtext/dtext.c"
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto st278;
	goto tr369;
st172:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof172;
case 172:
	switch( (*( sm->p)) ) {
		case 111: goto st173;
		case 115: goto st177;
	}
	goto tr86;
st173:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof173;
case 173:
	if ( (*( sm->p)) == 108 )
		goto st174;
	goto tr86;
st174:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof174;
case 174:
	if ( (*( sm->p)) == 32 )
		goto st175;
	goto tr86;
st175:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof175;
case 175:
	if ( (*( sm->p)) == 35 )
		goto st176;
	goto tr86;
st176:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof176;
case 176:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr207;
	goto tr86;
tr207:
#line 85 "ext/dtext/dtext.rl"
	{
  sm->a1 = sm->p;
}
	goto st279;
st279:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof279;
case 279:
#line 3750 "ext/dtext/dtext.c"
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto st279;
	goto tr371;
st177:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof177;
case 177:
	if ( (*( sm->p)) == 116 )
		goto st178;
	goto tr86;
st178:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof178;
case 178:
	if ( (*( sm->p)) == 32 )
		goto st179;
	goto tr86;
st179:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof179;
case 179:
	if ( (*( sm->p)) == 35 )
		goto st180;
	goto tr86;
st180:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof180;
case 180:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr211;
	goto tr86;
tr211:
#line 85 "ext/dtext/dtext.rl"
	{
  sm->a1 = sm->p;
}
	goto st280;
st280:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof280;
case 280:
#line 3792 "ext/dtext/dtext.c"
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto st280;
	goto tr373;
tr325:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
	goto st281;
st281:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof281;
case 281:
#line 3804 "ext/dtext/dtext.c"
	if ( (*( sm->p)) == 111 )
		goto st181;
	goto tr328;
st181:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof181;
case 181:
	if ( (*( sm->p)) == 112 )
		goto st182;
	goto tr86;
st182:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof182;
case 182:
	if ( (*( sm->p)) == 105 )
		goto st183;
	goto tr86;
st183:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof183;
case 183:
	if ( (*( sm->p)) == 99 )
		goto st184;
	goto tr86;
st184:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof184;
case 184:
	if ( (*( sm->p)) == 32 )
		goto st185;
	goto tr86;
st185:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof185;
case 185:
	if ( (*( sm->p)) == 35 )
		goto st186;
	goto tr86;
st186:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof186;
case 186:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr217;
	goto tr86;
tr217:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 85 "ext/dtext/dtext.rl"
	{
  sm->a1 = sm->p;
}
	goto st282;
tr378:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
	goto st282;
st282:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof282;
case 282:
#line 3866 "ext/dtext/dtext.c"
	if ( (*( sm->p)) == 47 )
		goto tr377;
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr378;
	goto tr376;
tr377:
#line 89 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
	goto st187;
st187:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof187;
case 187:
#line 3882 "ext/dtext/dtext.c"
	if ( (*( sm->p)) == 112 )
		goto st188;
	goto tr218;
st188:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof188;
case 188:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr220;
	goto tr218;
tr220:
#line 93 "ext/dtext/dtext.rl"
	{
  sm->b1 = sm->p;
}
	goto st283;
st283:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof283;
case 283:
#line 3903 "ext/dtext/dtext.c"
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto st283;
	goto tr379;
tr326:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
	goto st284;
st284:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof284;
case 284:
#line 3915 "ext/dtext/dtext.c"
	if ( (*( sm->p)) == 115 )
		goto st189;
	goto tr328;
st189:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof189;
case 189:
	if ( (*( sm->p)) == 101 )
		goto st190;
	goto tr86;
st190:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof190;
case 190:
	if ( (*( sm->p)) == 114 )
		goto st191;
	goto tr86;
st191:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof191;
case 191:
	if ( (*( sm->p)) == 32 )
		goto st192;
	goto tr86;
st192:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof192;
case 192:
	if ( (*( sm->p)) == 35 )
		goto st193;
	goto tr86;
st193:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof193;
case 193:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr225;
	goto tr86;
tr225:
#line 85 "ext/dtext/dtext.rl"
	{
  sm->a1 = sm->p;
}
	goto st285;
st285:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof285;
case 285:
#line 3964 "ext/dtext/dtext.c"
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto st285;
	goto tr382;
tr327:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
	goto st286;
st286:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof286;
case 286:
#line 3976 "ext/dtext/dtext.c"
	if ( (*( sm->p)) == 123 )
		goto st194;
	goto tr328;
st194:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof194;
case 194:
	if ( (*( sm->p)) == 125 )
		goto tr86;
	goto tr226;
tr226:
#line 85 "ext/dtext/dtext.rl"
	{
  sm->a1 = sm->p;
}
	goto st195;
st195:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof195;
case 195:
#line 3997 "ext/dtext/dtext.c"
	if ( (*( sm->p)) == 125 )
		goto tr228;
	goto st195;
tr228:
#line 89 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
	goto st196;
st196:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof196;
case 196:
#line 4011 "ext/dtext/dtext.c"
	if ( (*( sm->p)) == 125 )
		goto tr229;
	goto tr86;
tr230:
#line 594 "ext/dtext/dtext.rl"
	{{( sm->p) = ((( sm->te)))-1;}{
    append_c_html_escaped(sm, (*( sm->p)));
  }}
	goto st287;
tr235:
#line 576 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    if (dstack_check(sm, BLOCK_CODE)) {
      dstack_pop(sm);
      append_newline(sm);
      append_block(sm, "</pre>");
      append_newline(sm);
      append_newline(sm);
    } else {
      append(sm, "[/code]");
    }
    { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)];goto _again;}
  }}
	goto st287;
tr385:
#line 594 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    append_c_html_escaped(sm, (*( sm->p)));
  }}
	goto st287;
tr386:
#line 589 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    ( sm->p)--;
    { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)];goto _again;}
  }}
	goto st287;
tr388:
#line 594 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append_c_html_escaped(sm, (*( sm->p)));
  }}
	goto st287;
st287:
#line 1 "NONE"
	{( sm->ts) = 0;}
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof287;
case 287:
#line 1 "NONE"
	{( sm->ts) = ( sm->p);}
#line 4063 "ext/dtext/dtext.c"
	switch( (*( sm->p)) ) {
		case 0: goto tr386;
		case 91: goto tr387;
	}
	goto tr385;
tr387:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
	goto st288;
st288:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof288;
case 288:
#line 4077 "ext/dtext/dtext.c"
	if ( (*( sm->p)) == 47 )
		goto st197;
	goto tr388;
st197:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof197;
case 197:
	if ( (*( sm->p)) == 99 )
		goto st198;
	goto tr230;
st198:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof198;
case 198:
	if ( (*( sm->p)) == 111 )
		goto st199;
	goto tr230;
st199:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof199;
case 199:
	if ( (*( sm->p)) == 100 )
		goto st200;
	goto tr230;
st200:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof200;
case 200:
	if ( (*( sm->p)) == 101 )
		goto st201;
	goto tr230;
st201:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof201;
case 201:
	if ( (*( sm->p)) == 93 )
		goto tr235;
	goto tr230;
tr236:
#line 621 "ext/dtext/dtext.rl"
	{{( sm->p) = ((( sm->te)))-1;}{
    append_c_html_escaped(sm, (*( sm->p)));
  }}
	goto st289;
tr244:
#line 600 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    if (dstack_check(sm, BLOCK_NODTEXT)) {
      dstack_pop(sm);
      append_newline(sm);
      append_block(sm, "</p>");
      append_newline(sm);
      append_newline(sm);
      { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)];goto _again;}
    } else if (dstack_check(sm, INLINE_NODTEXT)) {
      dstack_pop(sm);
      { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)];goto _again;}
    } else {
      append(sm, "[/nodtext]");
    }
  }}
	goto st289;
tr390:
#line 621 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    append_c_html_escaped(sm, (*( sm->p)));
  }}
	goto st289;
tr391:
#line 616 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    ( sm->p)--;
    { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)];goto _again;}
  }}
	goto st289;
tr393:
#line 621 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append_c_html_escaped(sm, (*( sm->p)));
  }}
	goto st289;
st289:
#line 1 "NONE"
	{( sm->ts) = 0;}
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof289;
case 289:
#line 1 "NONE"
	{( sm->ts) = ( sm->p);}
#line 4167 "ext/dtext/dtext.c"
	switch( (*( sm->p)) ) {
		case 0: goto tr391;
		case 91: goto tr392;
	}
	goto tr390;
tr392:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
	goto st290;
st290:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof290;
case 290:
#line 4181 "ext/dtext/dtext.c"
	if ( (*( sm->p)) == 47 )
		goto st202;
	goto tr393;
st202:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof202;
case 202:
	if ( (*( sm->p)) == 110 )
		goto st203;
	goto tr236;
st203:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof203;
case 203:
	if ( (*( sm->p)) == 111 )
		goto st204;
	goto tr236;
st204:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof204;
case 204:
	if ( (*( sm->p)) == 100 )
		goto st205;
	goto tr236;
st205:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof205;
case 205:
	if ( (*( sm->p)) == 116 )
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
	if ( (*( sm->p)) == 120 )
		goto st208;
	goto tr236;
st208:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof208;
case 208:
	if ( (*( sm->p)) == 116 )
		goto st209;
	goto tr236;
st209:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof209;
case 209:
	if ( (*( sm->p)) == 93 )
		goto tr244;
	goto tr236;
tr245:
#line 715 "ext/dtext/dtext.rl"
	{{( sm->p) = ((( sm->te)))-1;}}
	goto st291;
tr254:
#line 697 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    if (dstack_check(sm, BLOCK_TABLE)) {
      dstack_pop(sm);
      append_newline(sm);
      append_block(sm, "</table>");
      append_newline(sm);
      append_newline(sm);
      { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)];goto _again;}
    } else {
      append(sm, "[/table]");
    }
  }}
	goto st291;
tr258:
#line 652 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    if (dstack_check(sm, BLOCK_TBODY)) {
      dstack_pop(sm);
      append_newline(sm);
      append_block(sm, "</tbody>");
      append_newline(sm);
    } else {
      append(sm, "[/tbody]");
    }
  }}
	goto st291;
tr262:
#line 634 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    if (dstack_check(sm, BLOCK_THEAD)) {
      dstack_pop(sm);
      append_newline(sm);
      append_block(sm, "</thead>");
      append_newline(sm);
    } else {
      append(sm, "[/thead]");
    }
  }}
	goto st291;
tr263:
#line 678 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    if (dstack_check(sm, BLOCK_TR)) {
      dstack_pop(sm);
      append_newline(sm);
      append_block(sm, "</tr>");
      append_newline(sm);
    } else {
      append(sm, "[/tr]");
    }
  }}
	goto st291;
tr271:
#line 645 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_push(sm, &BLOCK_TBODY);
    append_newline(sm);
    append_block(sm, "<tbody>");
    append_newline(sm);
  }}
	goto st291;
tr272:
#line 689 "ext/dtext/dtext.rl"
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
{( ((int *)sm->stack->data))[( sm->top)++] = 291; goto st253;}}
  }}
	goto st291;
tr273:
#line 663 "ext/dtext/dtext.rl"
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
{( ((int *)sm->stack->data))[( sm->top)++] = 291; goto st253;}}
  }}
	goto st291;
tr277:
#line 627 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_push(sm, &BLOCK_THEAD);
    append_newline(sm);
    append_block(sm, "<thead>");
    append_newline(sm);
  }}
	goto st291;
tr278:
#line 671 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_push(sm, &BLOCK_TR);
    append_newline(sm);
    append_block(sm, "<tr>");
    append_newline(sm);
  }}
	goto st291;
tr395:
#line 715 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;}
	goto st291;
tr396:
#line 710 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    ( sm->p)--;
    { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)];goto _again;}
  }}
	goto st291;
tr398:
#line 715 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;}
	goto st291;
st291:
#line 1 "NONE"
	{( sm->ts) = 0;}
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof291;
case 291:
#line 1 "NONE"
	{( sm->ts) = ( sm->p);}
#line 4391 "ext/dtext/dtext.c"
	switch( (*( sm->p)) ) {
		case 0: goto tr396;
		case 91: goto tr397;
	}
	goto tr395;
tr397:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
	goto st292;
st292:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof292;
case 292:
#line 4405 "ext/dtext/dtext.c"
	switch( (*( sm->p)) ) {
		case 47: goto st210;
		case 116: goto st225;
	}
	goto tr398;
st210:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof210;
case 210:
	if ( (*( sm->p)) == 116 )
		goto st211;
	goto tr245;
st211:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof211;
case 211:
	switch( (*( sm->p)) ) {
		case 97: goto st212;
		case 98: goto st216;
		case 104: goto st220;
		case 114: goto st224;
	}
	goto tr245;
st212:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof212;
case 212:
	if ( (*( sm->p)) == 98 )
		goto st213;
	goto tr245;
st213:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof213;
case 213:
	if ( (*( sm->p)) == 108 )
		goto st214;
	goto tr245;
st214:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof214;
case 214:
	if ( (*( sm->p)) == 101 )
		goto st215;
	goto tr245;
st215:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof215;
case 215:
	if ( (*( sm->p)) == 93 )
		goto tr254;
	goto tr245;
st216:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof216;
case 216:
	if ( (*( sm->p)) == 111 )
		goto st217;
	goto tr245;
st217:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof217;
case 217:
	if ( (*( sm->p)) == 100 )
		goto st218;
	goto tr245;
st218:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof218;
case 218:
	if ( (*( sm->p)) == 121 )
		goto st219;
	goto tr245;
st219:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof219;
case 219:
	if ( (*( sm->p)) == 93 )
		goto tr258;
	goto tr245;
st220:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof220;
case 220:
	if ( (*( sm->p)) == 101 )
		goto st221;
	goto tr245;
st221:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof221;
case 221:
	if ( (*( sm->p)) == 97 )
		goto st222;
	goto tr245;
st222:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof222;
case 222:
	if ( (*( sm->p)) == 100 )
		goto st223;
	goto tr245;
st223:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof223;
case 223:
	if ( (*( sm->p)) == 93 )
		goto tr262;
	goto tr245;
st224:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof224;
case 224:
	if ( (*( sm->p)) == 93 )
		goto tr263;
	goto tr245;
st225:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof225;
case 225:
	switch( (*( sm->p)) ) {
		case 98: goto st226;
		case 100: goto st230;
		case 104: goto st231;
		case 114: goto st235;
	}
	goto tr245;
st226:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof226;
case 226:
	if ( (*( sm->p)) == 111 )
		goto st227;
	goto tr245;
st227:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof227;
case 227:
	if ( (*( sm->p)) == 100 )
		goto st228;
	goto tr245;
st228:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof228;
case 228:
	if ( (*( sm->p)) == 121 )
		goto st229;
	goto tr245;
st229:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof229;
case 229:
	if ( (*( sm->p)) == 93 )
		goto tr271;
	goto tr245;
st230:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof230;
case 230:
	if ( (*( sm->p)) == 93 )
		goto tr272;
	goto tr245;
st231:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof231;
case 231:
	switch( (*( sm->p)) ) {
		case 93: goto tr273;
		case 101: goto st232;
	}
	goto tr245;
st232:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof232;
case 232:
	if ( (*( sm->p)) == 97 )
		goto st233;
	goto tr245;
st233:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof233;
case 233:
	if ( (*( sm->p)) == 100 )
		goto st234;
	goto tr245;
st234:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof234;
case 234:
	if ( (*( sm->p)) == 93 )
		goto tr277;
	goto tr245;
st235:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof235;
case 235:
	if ( (*( sm->p)) == 93 )
		goto tr278;
	goto tr245;
tr279:
#line 756 "ext/dtext/dtext.rl"
	{{( sm->p) = ((( sm->te)))-1;}{
    dstack_close(sm);
    ( sm->p)--;
    { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)];goto _again;}
  }}
	goto st293;
tr401:
#line 756 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_close(sm);
    ( sm->p)--;
    { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)];goto _again;}
  }}
	goto st293;
tr402:
#line 748 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_close(sm);
    {( sm->p) = (( sm->ts))-1;}
    { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)];goto _again;}
  }}
	goto st293;
tr406:
#line 1 "NONE"
	{	switch( ( sm->act) ) {
	case 62:
	{{( sm->p) = ((( sm->te)))-1;}
    dstack_close(sm);
    {( sm->p) = (( sm->ts))-1;}
    { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)];goto _again;}
  }
	break;
	default:
	{{( sm->p) = ((( sm->te)))-1;}}
	break;
	}
	}
	goto st293;
tr408:
#line 754 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;}
	goto st293;
tr409:
#line 756 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    dstack_close(sm);
    ( sm->p)--;
    { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)];goto _again;}
  }}
	goto st293;
tr410:
#line 97 "ext/dtext/dtext.rl"
	{
  sm->b2 = sm->p;
}
#line 719 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    int prev_nest = sm->list_nest;
    sm->list_mode = true;
    sm->list_nest = sm->a2 - sm->a1;
    {( sm->p) = (( sm->b1))-1;}

    if (sm->list_nest > prev_nest) {
      for (int i=prev_nest; i<sm->list_nest; ++i) {
        append_block(sm, "<ul>");
        append_newline(sm);
        dstack_push(sm, &BLOCK_UL);
      }
    } else if (sm->list_nest < prev_nest) {
      for (int i=sm->list_nest; i<prev_nest; ++i) {
        if (dstack_check(sm, BLOCK_UL)) {
          dstack_pop(sm);
          append_block(sm, "</ul>");
          append_newline(sm);
        }
      }
    }

    append_block(sm, "<li>");
    dstack_push(sm, &BLOCK_LI);

    {
  size_t len = sm->stack->len;

  if (len > MAX_STACK_DEPTH) {
    free_machine(sm);
    rb_raise(rb_eSyntaxError, "too many nested elements");
  }

  if (sm->top >= len) {
    sm->stack = g_array_set_size(sm->stack, len + 16);
  }
{( ((int *)sm->stack->data))[( sm->top)++] = 293; goto st253;}}
  }}
	goto st293;
st293:
#line 1 "NONE"
	{( sm->ts) = 0;}
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof293;
case 293:
#line 1 "NONE"
	{( sm->ts) = ( sm->p);}
#line 4708 "ext/dtext/dtext.c"
	switch( (*( sm->p)) ) {
		case 0: goto tr402;
		case 10: goto tr403;
		case 13: goto st295;
		case 42: goto tr405;
	}
	goto tr401;
tr403:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 754 "ext/dtext/dtext.rl"
	{( sm->act) = 63;}
	goto st294;
tr407:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 748 "ext/dtext/dtext.rl"
	{( sm->act) = 62;}
	goto st294;
st294:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof294;
case 294:
#line 4732 "ext/dtext/dtext.c"
	switch( (*( sm->p)) ) {
		case 10: goto tr407;
		case 13: goto tr407;
	}
	goto tr406;
st295:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof295;
case 295:
	switch( (*( sm->p)) ) {
		case 10: goto tr407;
		case 13: goto tr407;
	}
	goto tr408;
tr405:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 85 "ext/dtext/dtext.rl"
	{
  sm->a1 = sm->p;
}
	goto st296;
st296:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof296;
case 296:
#line 4759 "ext/dtext/dtext.c"
	switch( (*( sm->p)) ) {
		case 9: goto tr282;
		case 32: goto tr282;
		case 42: goto st237;
	}
	goto tr409;
tr282:
#line 89 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
	goto st236;
st236:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof236;
case 236:
#line 4776 "ext/dtext/dtext.c"
	switch( (*( sm->p)) ) {
		case 0: goto tr279;
		case 9: goto tr281;
		case 10: goto tr279;
		case 13: goto tr279;
		case 32: goto tr281;
	}
	goto tr280;
tr280:
#line 93 "ext/dtext/dtext.rl"
	{
  sm->b1 = sm->p;
}
	goto st297;
st297:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof297;
case 297:
#line 4795 "ext/dtext/dtext.c"
	switch( (*( sm->p)) ) {
		case 0: goto tr410;
		case 10: goto tr410;
		case 13: goto tr410;
	}
	goto st297;
tr281:
#line 93 "ext/dtext/dtext.rl"
	{
  sm->b1 = sm->p;
}
	goto st298;
st298:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof298;
case 298:
#line 4812 "ext/dtext/dtext.c"
	switch( (*( sm->p)) ) {
		case 0: goto tr410;
		case 9: goto tr281;
		case 10: goto tr410;
		case 13: goto tr410;
		case 32: goto tr281;
	}
	goto tr280;
st237:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof237;
case 237:
	switch( (*( sm->p)) ) {
		case 9: goto tr282;
		case 32: goto tr282;
		case 42: goto st237;
	}
	goto tr279;
	}
	_test_eof238:  sm->cs = 238; goto _test_eof; 
	_test_eof239:  sm->cs = 239; goto _test_eof; 
	_test_eof240:  sm->cs = 240; goto _test_eof; 
	_test_eof0:  sm->cs = 0; goto _test_eof; 
	_test_eof241:  sm->cs = 241; goto _test_eof; 
	_test_eof242:  sm->cs = 242; goto _test_eof; 
	_test_eof1:  sm->cs = 1; goto _test_eof; 
	_test_eof243:  sm->cs = 243; goto _test_eof; 
	_test_eof2:  sm->cs = 2; goto _test_eof; 
	_test_eof3:  sm->cs = 3; goto _test_eof; 
	_test_eof4:  sm->cs = 4; goto _test_eof; 
	_test_eof5:  sm->cs = 5; goto _test_eof; 
	_test_eof244:  sm->cs = 244; goto _test_eof; 
	_test_eof6:  sm->cs = 6; goto _test_eof; 
	_test_eof7:  sm->cs = 7; goto _test_eof; 
	_test_eof8:  sm->cs = 8; goto _test_eof; 
	_test_eof9:  sm->cs = 9; goto _test_eof; 
	_test_eof10:  sm->cs = 10; goto _test_eof; 
	_test_eof11:  sm->cs = 11; goto _test_eof; 
	_test_eof12:  sm->cs = 12; goto _test_eof; 
	_test_eof13:  sm->cs = 13; goto _test_eof; 
	_test_eof245:  sm->cs = 245; goto _test_eof; 
	_test_eof246:  sm->cs = 246; goto _test_eof; 
	_test_eof14:  sm->cs = 14; goto _test_eof; 
	_test_eof15:  sm->cs = 15; goto _test_eof; 
	_test_eof16:  sm->cs = 16; goto _test_eof; 
	_test_eof17:  sm->cs = 17; goto _test_eof; 
	_test_eof18:  sm->cs = 18; goto _test_eof; 
	_test_eof19:  sm->cs = 19; goto _test_eof; 
	_test_eof20:  sm->cs = 20; goto _test_eof; 
	_test_eof247:  sm->cs = 247; goto _test_eof; 
	_test_eof21:  sm->cs = 21; goto _test_eof; 
	_test_eof22:  sm->cs = 22; goto _test_eof; 
	_test_eof23:  sm->cs = 23; goto _test_eof; 
	_test_eof24:  sm->cs = 24; goto _test_eof; 
	_test_eof25:  sm->cs = 25; goto _test_eof; 
	_test_eof248:  sm->cs = 248; goto _test_eof; 
	_test_eof26:  sm->cs = 26; goto _test_eof; 
	_test_eof27:  sm->cs = 27; goto _test_eof; 
	_test_eof28:  sm->cs = 28; goto _test_eof; 
	_test_eof29:  sm->cs = 29; goto _test_eof; 
	_test_eof30:  sm->cs = 30; goto _test_eof; 
	_test_eof31:  sm->cs = 31; goto _test_eof; 
	_test_eof32:  sm->cs = 32; goto _test_eof; 
	_test_eof249:  sm->cs = 249; goto _test_eof; 
	_test_eof33:  sm->cs = 33; goto _test_eof; 
	_test_eof34:  sm->cs = 34; goto _test_eof; 
	_test_eof35:  sm->cs = 35; goto _test_eof; 
	_test_eof36:  sm->cs = 36; goto _test_eof; 
	_test_eof37:  sm->cs = 37; goto _test_eof; 
	_test_eof38:  sm->cs = 38; goto _test_eof; 
	_test_eof250:  sm->cs = 250; goto _test_eof; 
	_test_eof39:  sm->cs = 39; goto _test_eof; 
	_test_eof40:  sm->cs = 40; goto _test_eof; 
	_test_eof251:  sm->cs = 251; goto _test_eof; 
	_test_eof252:  sm->cs = 252; goto _test_eof; 
	_test_eof253:  sm->cs = 253; goto _test_eof; 
	_test_eof254:  sm->cs = 254; goto _test_eof; 
	_test_eof41:  sm->cs = 41; goto _test_eof; 
	_test_eof42:  sm->cs = 42; goto _test_eof; 
	_test_eof43:  sm->cs = 43; goto _test_eof; 
	_test_eof44:  sm->cs = 44; goto _test_eof; 
	_test_eof45:  sm->cs = 45; goto _test_eof; 
	_test_eof46:  sm->cs = 46; goto _test_eof; 
	_test_eof47:  sm->cs = 47; goto _test_eof; 
	_test_eof48:  sm->cs = 48; goto _test_eof; 
	_test_eof49:  sm->cs = 49; goto _test_eof; 
	_test_eof50:  sm->cs = 50; goto _test_eof; 
	_test_eof51:  sm->cs = 51; goto _test_eof; 
	_test_eof52:  sm->cs = 52; goto _test_eof; 
	_test_eof53:  sm->cs = 53; goto _test_eof; 
	_test_eof54:  sm->cs = 54; goto _test_eof; 
	_test_eof55:  sm->cs = 55; goto _test_eof; 
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
	_test_eof255:  sm->cs = 255; goto _test_eof; 
	_test_eof68:  sm->cs = 68; goto _test_eof; 
	_test_eof69:  sm->cs = 69; goto _test_eof; 
	_test_eof70:  sm->cs = 70; goto _test_eof; 
	_test_eof71:  sm->cs = 71; goto _test_eof; 
	_test_eof72:  sm->cs = 72; goto _test_eof; 
	_test_eof256:  sm->cs = 256; goto _test_eof; 
	_test_eof257:  sm->cs = 257; goto _test_eof; 
	_test_eof258:  sm->cs = 258; goto _test_eof; 
	_test_eof73:  sm->cs = 73; goto _test_eof; 
	_test_eof74:  sm->cs = 74; goto _test_eof; 
	_test_eof75:  sm->cs = 75; goto _test_eof; 
	_test_eof76:  sm->cs = 76; goto _test_eof; 
	_test_eof259:  sm->cs = 259; goto _test_eof; 
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
	_test_eof260:  sm->cs = 260; goto _test_eof; 
	_test_eof261:  sm->cs = 261; goto _test_eof; 
	_test_eof262:  sm->cs = 262; goto _test_eof; 
	_test_eof263:  sm->cs = 263; goto _test_eof; 
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
	_test_eof264:  sm->cs = 264; goto _test_eof; 
	_test_eof128:  sm->cs = 128; goto _test_eof; 
	_test_eof129:  sm->cs = 129; goto _test_eof; 
	_test_eof130:  sm->cs = 130; goto _test_eof; 
	_test_eof131:  sm->cs = 131; goto _test_eof; 
	_test_eof132:  sm->cs = 132; goto _test_eof; 
	_test_eof133:  sm->cs = 133; goto _test_eof; 
	_test_eof134:  sm->cs = 134; goto _test_eof; 
	_test_eof265:  sm->cs = 265; goto _test_eof; 
	_test_eof266:  sm->cs = 266; goto _test_eof; 
	_test_eof135:  sm->cs = 135; goto _test_eof; 
	_test_eof136:  sm->cs = 136; goto _test_eof; 
	_test_eof137:  sm->cs = 137; goto _test_eof; 
	_test_eof138:  sm->cs = 138; goto _test_eof; 
	_test_eof139:  sm->cs = 139; goto _test_eof; 
	_test_eof140:  sm->cs = 140; goto _test_eof; 
	_test_eof141:  sm->cs = 141; goto _test_eof; 
	_test_eof142:  sm->cs = 142; goto _test_eof; 
	_test_eof267:  sm->cs = 267; goto _test_eof; 
	_test_eof268:  sm->cs = 268; goto _test_eof; 
	_test_eof143:  sm->cs = 143; goto _test_eof; 
	_test_eof144:  sm->cs = 144; goto _test_eof; 
	_test_eof145:  sm->cs = 145; goto _test_eof; 
	_test_eof146:  sm->cs = 146; goto _test_eof; 
	_test_eof147:  sm->cs = 147; goto _test_eof; 
	_test_eof148:  sm->cs = 148; goto _test_eof; 
	_test_eof269:  sm->cs = 269; goto _test_eof; 
	_test_eof270:  sm->cs = 270; goto _test_eof; 
	_test_eof149:  sm->cs = 149; goto _test_eof; 
	_test_eof150:  sm->cs = 150; goto _test_eof; 
	_test_eof271:  sm->cs = 271; goto _test_eof; 
	_test_eof272:  sm->cs = 272; goto _test_eof; 
	_test_eof151:  sm->cs = 151; goto _test_eof; 
	_test_eof152:  sm->cs = 152; goto _test_eof; 
	_test_eof153:  sm->cs = 153; goto _test_eof; 
	_test_eof154:  sm->cs = 154; goto _test_eof; 
	_test_eof155:  sm->cs = 155; goto _test_eof; 
	_test_eof156:  sm->cs = 156; goto _test_eof; 
	_test_eof273:  sm->cs = 273; goto _test_eof; 
	_test_eof157:  sm->cs = 157; goto _test_eof; 
	_test_eof274:  sm->cs = 274; goto _test_eof; 
	_test_eof158:  sm->cs = 158; goto _test_eof; 
	_test_eof159:  sm->cs = 159; goto _test_eof; 
	_test_eof160:  sm->cs = 160; goto _test_eof; 
	_test_eof161:  sm->cs = 161; goto _test_eof; 
	_test_eof162:  sm->cs = 162; goto _test_eof; 
	_test_eof163:  sm->cs = 163; goto _test_eof; 
	_test_eof275:  sm->cs = 275; goto _test_eof; 
	_test_eof276:  sm->cs = 276; goto _test_eof; 
	_test_eof164:  sm->cs = 164; goto _test_eof; 
	_test_eof165:  sm->cs = 165; goto _test_eof; 
	_test_eof166:  sm->cs = 166; goto _test_eof; 
	_test_eof167:  sm->cs = 167; goto _test_eof; 
	_test_eof168:  sm->cs = 168; goto _test_eof; 
	_test_eof169:  sm->cs = 169; goto _test_eof; 
	_test_eof277:  sm->cs = 277; goto _test_eof; 
	_test_eof170:  sm->cs = 170; goto _test_eof; 
	_test_eof171:  sm->cs = 171; goto _test_eof; 
	_test_eof278:  sm->cs = 278; goto _test_eof; 
	_test_eof172:  sm->cs = 172; goto _test_eof; 
	_test_eof173:  sm->cs = 173; goto _test_eof; 
	_test_eof174:  sm->cs = 174; goto _test_eof; 
	_test_eof175:  sm->cs = 175; goto _test_eof; 
	_test_eof176:  sm->cs = 176; goto _test_eof; 
	_test_eof279:  sm->cs = 279; goto _test_eof; 
	_test_eof177:  sm->cs = 177; goto _test_eof; 
	_test_eof178:  sm->cs = 178; goto _test_eof; 
	_test_eof179:  sm->cs = 179; goto _test_eof; 
	_test_eof180:  sm->cs = 180; goto _test_eof; 
	_test_eof280:  sm->cs = 280; goto _test_eof; 
	_test_eof281:  sm->cs = 281; goto _test_eof; 
	_test_eof181:  sm->cs = 181; goto _test_eof; 
	_test_eof182:  sm->cs = 182; goto _test_eof; 
	_test_eof183:  sm->cs = 183; goto _test_eof; 
	_test_eof184:  sm->cs = 184; goto _test_eof; 
	_test_eof185:  sm->cs = 185; goto _test_eof; 
	_test_eof186:  sm->cs = 186; goto _test_eof; 
	_test_eof282:  sm->cs = 282; goto _test_eof; 
	_test_eof187:  sm->cs = 187; goto _test_eof; 
	_test_eof188:  sm->cs = 188; goto _test_eof; 
	_test_eof283:  sm->cs = 283; goto _test_eof; 
	_test_eof284:  sm->cs = 284; goto _test_eof; 
	_test_eof189:  sm->cs = 189; goto _test_eof; 
	_test_eof190:  sm->cs = 190; goto _test_eof; 
	_test_eof191:  sm->cs = 191; goto _test_eof; 
	_test_eof192:  sm->cs = 192; goto _test_eof; 
	_test_eof193:  sm->cs = 193; goto _test_eof; 
	_test_eof285:  sm->cs = 285; goto _test_eof; 
	_test_eof286:  sm->cs = 286; goto _test_eof; 
	_test_eof194:  sm->cs = 194; goto _test_eof; 
	_test_eof195:  sm->cs = 195; goto _test_eof; 
	_test_eof196:  sm->cs = 196; goto _test_eof; 
	_test_eof287:  sm->cs = 287; goto _test_eof; 
	_test_eof288:  sm->cs = 288; goto _test_eof; 
	_test_eof197:  sm->cs = 197; goto _test_eof; 
	_test_eof198:  sm->cs = 198; goto _test_eof; 
	_test_eof199:  sm->cs = 199; goto _test_eof; 
	_test_eof200:  sm->cs = 200; goto _test_eof; 
	_test_eof201:  sm->cs = 201; goto _test_eof; 
	_test_eof289:  sm->cs = 289; goto _test_eof; 
	_test_eof290:  sm->cs = 290; goto _test_eof; 
	_test_eof202:  sm->cs = 202; goto _test_eof; 
	_test_eof203:  sm->cs = 203; goto _test_eof; 
	_test_eof204:  sm->cs = 204; goto _test_eof; 
	_test_eof205:  sm->cs = 205; goto _test_eof; 
	_test_eof206:  sm->cs = 206; goto _test_eof; 
	_test_eof207:  sm->cs = 207; goto _test_eof; 
	_test_eof208:  sm->cs = 208; goto _test_eof; 
	_test_eof209:  sm->cs = 209; goto _test_eof; 
	_test_eof291:  sm->cs = 291; goto _test_eof; 
	_test_eof292:  sm->cs = 292; goto _test_eof; 
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
	_test_eof293:  sm->cs = 293; goto _test_eof; 
	_test_eof294:  sm->cs = 294; goto _test_eof; 
	_test_eof295:  sm->cs = 295; goto _test_eof; 
	_test_eof296:  sm->cs = 296; goto _test_eof; 
	_test_eof236:  sm->cs = 236; goto _test_eof; 
	_test_eof297:  sm->cs = 297; goto _test_eof; 
	_test_eof298:  sm->cs = 298; goto _test_eof; 
	_test_eof237:  sm->cs = 237; goto _test_eof; 

	_test_eof: {}
	if ( ( sm->p) == ( sm->eof) )
	{
	switch (  sm->cs ) {
	case 239: goto tr291;
	case 240: goto tr292;
	case 0: goto tr0;
	case 241: goto tr293;
	case 242: goto tr293;
	case 1: goto tr0;
	case 243: goto tr292;
	case 2: goto tr0;
	case 3: goto tr0;
	case 4: goto tr0;
	case 5: goto tr0;
	case 244: goto tr301;
	case 6: goto tr0;
	case 7: goto tr0;
	case 8: goto tr0;
	case 9: goto tr0;
	case 10: goto tr0;
	case 11: goto tr0;
	case 12: goto tr0;
	case 13: goto tr0;
	case 245: goto tr302;
	case 246: goto tr304;
	case 14: goto tr0;
	case 15: goto tr0;
	case 16: goto tr0;
	case 17: goto tr0;
	case 18: goto tr0;
	case 19: goto tr0;
	case 20: goto tr0;
	case 247: goto tr305;
	case 21: goto tr0;
	case 22: goto tr0;
	case 23: goto tr0;
	case 24: goto tr0;
	case 25: goto tr0;
	case 248: goto tr306;
	case 26: goto tr0;
	case 27: goto tr0;
	case 28: goto tr0;
	case 29: goto tr0;
	case 30: goto tr0;
	case 31: goto tr0;
	case 32: goto tr0;
	case 249: goto tr307;
	case 33: goto tr0;
	case 34: goto tr0;
	case 35: goto tr0;
	case 36: goto tr0;
	case 37: goto tr0;
	case 38: goto tr0;
	case 250: goto tr292;
	case 39: goto tr0;
	case 40: goto tr0;
	case 251: goto tr309;
	case 252: goto tr309;
	case 254: goto tr328;
	case 41: goto tr48;
	case 42: goto tr48;
	case 43: goto tr48;
	case 44: goto tr48;
	case 45: goto tr48;
	case 46: goto tr48;
	case 47: goto tr48;
	case 48: goto tr48;
	case 49: goto tr48;
	case 50: goto tr48;
	case 51: goto tr48;
	case 52: goto tr48;
	case 53: goto tr48;
	case 54: goto tr48;
	case 55: goto tr48;
	case 56: goto tr48;
	case 57: goto tr48;
	case 58: goto tr48;
	case 59: goto tr48;
	case 60: goto tr48;
	case 61: goto tr48;
	case 62: goto tr48;
	case 63: goto tr48;
	case 64: goto tr48;
	case 65: goto tr48;
	case 66: goto tr48;
	case 67: goto tr48;
	case 255: goto tr329;
	case 68: goto tr48;
	case 69: goto tr48;
	case 70: goto tr48;
	case 71: goto tr48;
	case 72: goto tr48;
	case 256: goto tr48;
	case 257: goto tr331;
	case 258: goto tr328;
	case 73: goto tr86;
	case 74: goto tr86;
	case 75: goto tr86;
	case 76: goto tr86;
	case 259: goto tr333;
	case 77: goto tr86;
	case 78: goto tr86;
	case 79: goto tr86;
	case 80: goto tr86;
	case 81: goto tr86;
	case 82: goto tr86;
	case 83: goto tr86;
	case 84: goto tr86;
	case 85: goto tr86;
	case 86: goto tr86;
	case 87: goto tr86;
	case 88: goto tr86;
	case 89: goto tr86;
	case 90: goto tr86;
	case 91: goto tr86;
	case 92: goto tr86;
	case 93: goto tr86;
	case 260: goto tr328;
	case 261: goto tr335;
	case 262: goto tr338;
	case 263: goto tr328;
	case 94: goto tr86;
	case 95: goto tr86;
	case 96: goto tr86;
	case 97: goto tr86;
	case 98: goto tr86;
	case 99: goto tr86;
	case 100: goto tr86;
	case 101: goto tr86;
	case 102: goto tr86;
	case 103: goto tr86;
	case 104: goto tr86;
	case 105: goto tr86;
	case 106: goto tr86;
	case 107: goto tr86;
	case 108: goto tr86;
	case 109: goto tr86;
	case 110: goto tr86;
	case 111: goto tr86;
	case 112: goto tr86;
	case 113: goto tr86;
	case 114: goto tr86;
	case 115: goto tr86;
	case 116: goto tr86;
	case 117: goto tr86;
	case 118: goto tr86;
	case 119: goto tr86;
	case 120: goto tr86;
	case 121: goto tr86;
	case 122: goto tr86;
	case 123: goto tr86;
	case 124: goto tr86;
	case 125: goto tr86;
	case 126: goto tr86;
	case 127: goto tr86;
	case 264: goto tr328;
	case 128: goto tr86;
	case 129: goto tr86;
	case 130: goto tr86;
	case 131: goto tr86;
	case 132: goto tr86;
	case 133: goto tr86;
	case 134: goto tr86;
	case 265: goto tr348;
	case 266: goto tr328;
	case 135: goto tr86;
	case 136: goto tr86;
	case 137: goto tr86;
	case 138: goto tr86;
	case 139: goto tr86;
	case 140: goto tr86;
	case 141: goto tr86;
	case 142: goto tr86;
	case 267: goto tr351;
	case 268: goto tr328;
	case 143: goto tr86;
	case 144: goto tr86;
	case 145: goto tr86;
	case 146: goto tr86;
	case 147: goto tr86;
	case 148: goto tr86;
	case 269: goto tr354;
	case 270: goto tr328;
	case 149: goto tr86;
	case 150: goto tr86;
	case 271: goto tr358;
	case 272: goto tr358;
	case 151: goto tr86;
	case 152: goto tr86;
	case 153: goto tr86;
	case 154: goto tr86;
	case 155: goto tr86;
	case 156: goto tr86;
	case 273: goto tr360;
	case 157: goto tr86;
	case 274: goto tr328;
	case 158: goto tr86;
	case 159: goto tr86;
	case 160: goto tr86;
	case 161: goto tr86;
	case 162: goto tr86;
	case 163: goto tr86;
	case 275: goto tr362;
	case 276: goto tr328;
	case 164: goto tr86;
	case 165: goto tr86;
	case 166: goto tr86;
	case 167: goto tr86;
	case 168: goto tr86;
	case 169: goto tr86;
	case 277: goto tr366;
	case 170: goto tr199;
	case 171: goto tr199;
	case 278: goto tr369;
	case 172: goto tr86;
	case 173: goto tr86;
	case 174: goto tr86;
	case 175: goto tr86;
	case 176: goto tr86;
	case 279: goto tr371;
	case 177: goto tr86;
	case 178: goto tr86;
	case 179: goto tr86;
	case 180: goto tr86;
	case 280: goto tr373;
	case 281: goto tr328;
	case 181: goto tr86;
	case 182: goto tr86;
	case 183: goto tr86;
	case 184: goto tr86;
	case 185: goto tr86;
	case 186: goto tr86;
	case 282: goto tr376;
	case 187: goto tr218;
	case 188: goto tr218;
	case 283: goto tr379;
	case 284: goto tr328;
	case 189: goto tr86;
	case 190: goto tr86;
	case 191: goto tr86;
	case 192: goto tr86;
	case 193: goto tr86;
	case 285: goto tr382;
	case 286: goto tr328;
	case 194: goto tr86;
	case 195: goto tr86;
	case 196: goto tr86;
	case 288: goto tr388;
	case 197: goto tr230;
	case 198: goto tr230;
	case 199: goto tr230;
	case 200: goto tr230;
	case 201: goto tr230;
	case 290: goto tr393;
	case 202: goto tr236;
	case 203: goto tr236;
	case 204: goto tr236;
	case 205: goto tr236;
	case 206: goto tr236;
	case 207: goto tr236;
	case 208: goto tr236;
	case 209: goto tr236;
	case 292: goto tr398;
	case 210: goto tr245;
	case 211: goto tr245;
	case 212: goto tr245;
	case 213: goto tr245;
	case 214: goto tr245;
	case 215: goto tr245;
	case 216: goto tr245;
	case 217: goto tr245;
	case 218: goto tr245;
	case 219: goto tr245;
	case 220: goto tr245;
	case 221: goto tr245;
	case 222: goto tr245;
	case 223: goto tr245;
	case 224: goto tr245;
	case 225: goto tr245;
	case 226: goto tr245;
	case 227: goto tr245;
	case 228: goto tr245;
	case 229: goto tr245;
	case 230: goto tr245;
	case 231: goto tr245;
	case 232: goto tr245;
	case 233: goto tr245;
	case 234: goto tr245;
	case 235: goto tr245;
	case 294: goto tr406;
	case 295: goto tr408;
	case 296: goto tr409;
	case 236: goto tr279;
	case 297: goto tr410;
	case 298: goto tr410;
	case 237: goto tr279;
	}
	}

	}

#line 1137 "ext/dtext/dtext.rl"

  dstack_close(sm);

  VALUE ret = rb_str_new(sm->output->str, sm->output->len);
  free_machine(sm);

  return ret;
}

void Init_dtext() {
  VALUE mDTextRagel = rb_define_module("DTextRagel");
  rb_define_singleton_method(mDTextRagel, "parse", parse, 1);
}
