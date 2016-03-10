
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


#line 897 "ext/dtext/dtext.rl"



#line 66 "ext/dtext/dtext.c"
static const int dtext_start = 237;
static const int dtext_first_final = 237;
static const int dtext_error = -1;

static const int dtext_en_inline = 252;
static const int dtext_en_code = 286;
static const int dtext_en_nodtext = 288;
static const int dtext_en_table = 290;
static const int dtext_en_list = 292;
static const int dtext_en_main = 237;


#line 900 "ext/dtext/dtext.rl"

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

static inline void append_segment(StateMachine * sm, const char * a, const char * b) {
  sm->output = g_string_append_len(sm->output, a, b - a + 1);
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
        append_block(sm, "</div>");
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

  
#line 298 "ext/dtext/dtext.c"
	{
	 sm->cs = dtext_start;
	( sm->top) = 0;
	( sm->ts) = 0;
	( sm->te) = 0;
	( sm->act) = 0;
	}

#line 1118 "ext/dtext/dtext.rl"
  
#line 309 "ext/dtext/dtext.c"
	{
	if ( ( sm->p) == ( sm->pe) )
		goto _test_eof;
	goto _resume;

_again:
	switch (  sm->cs ) {
		case 237: goto st237;
		case 238: goto st238;
		case 239: goto st239;
		case 0: goto st0;
		case 240: goto st240;
		case 241: goto st241;
		case 1: goto st1;
		case 242: goto st242;
		case 2: goto st2;
		case 3: goto st3;
		case 4: goto st4;
		case 5: goto st5;
		case 243: goto st243;
		case 6: goto st6;
		case 7: goto st7;
		case 8: goto st8;
		case 9: goto st9;
		case 10: goto st10;
		case 11: goto st11;
		case 12: goto st12;
		case 13: goto st13;
		case 244: goto st244;
		case 245: goto st245;
		case 14: goto st14;
		case 15: goto st15;
		case 16: goto st16;
		case 17: goto st17;
		case 18: goto st18;
		case 19: goto st19;
		case 20: goto st20;
		case 246: goto st246;
		case 21: goto st21;
		case 22: goto st22;
		case 23: goto st23;
		case 24: goto st24;
		case 25: goto st25;
		case 247: goto st247;
		case 26: goto st26;
		case 27: goto st27;
		case 28: goto st28;
		case 29: goto st29;
		case 30: goto st30;
		case 31: goto st31;
		case 32: goto st32;
		case 248: goto st248;
		case 33: goto st33;
		case 34: goto st34;
		case 35: goto st35;
		case 36: goto st36;
		case 37: goto st37;
		case 38: goto st38;
		case 249: goto st249;
		case 39: goto st39;
		case 40: goto st40;
		case 250: goto st250;
		case 251: goto st251;
		case 252: goto st252;
		case 253: goto st253;
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
		case 254: goto st254;
		case 68: goto st68;
		case 69: goto st69;
		case 70: goto st70;
		case 71: goto st71;
		case 72: goto st72;
		case 255: goto st255;
		case 256: goto st256;
		case 257: goto st257;
		case 73: goto st73;
		case 74: goto st74;
		case 75: goto st75;
		case 76: goto st76;
		case 258: goto st258;
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
		case 259: goto st259;
		case 260: goto st260;
		case 261: goto st261;
		case 262: goto st262;
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
		case 263: goto st263;
		case 127: goto st127;
		case 128: goto st128;
		case 129: goto st129;
		case 130: goto st130;
		case 131: goto st131;
		case 132: goto st132;
		case 133: goto st133;
		case 264: goto st264;
		case 265: goto st265;
		case 134: goto st134;
		case 135: goto st135;
		case 136: goto st136;
		case 137: goto st137;
		case 138: goto st138;
		case 139: goto st139;
		case 140: goto st140;
		case 141: goto st141;
		case 266: goto st266;
		case 267: goto st267;
		case 142: goto st142;
		case 143: goto st143;
		case 144: goto st144;
		case 145: goto st145;
		case 146: goto st146;
		case 147: goto st147;
		case 268: goto st268;
		case 269: goto st269;
		case 148: goto st148;
		case 149: goto st149;
		case 270: goto st270;
		case 271: goto st271;
		case 150: goto st150;
		case 151: goto st151;
		case 152: goto st152;
		case 153: goto st153;
		case 154: goto st154;
		case 155: goto st155;
		case 272: goto st272;
		case 156: goto st156;
		case 273: goto st273;
		case 157: goto st157;
		case 158: goto st158;
		case 159: goto st159;
		case 160: goto st160;
		case 161: goto st161;
		case 162: goto st162;
		case 274: goto st274;
		case 275: goto st275;
		case 163: goto st163;
		case 164: goto st164;
		case 165: goto st165;
		case 166: goto st166;
		case 167: goto st167;
		case 168: goto st168;
		case 276: goto st276;
		case 169: goto st169;
		case 170: goto st170;
		case 277: goto st277;
		case 171: goto st171;
		case 172: goto st172;
		case 173: goto st173;
		case 174: goto st174;
		case 175: goto st175;
		case 278: goto st278;
		case 176: goto st176;
		case 177: goto st177;
		case 178: goto st178;
		case 179: goto st179;
		case 279: goto st279;
		case 280: goto st280;
		case 180: goto st180;
		case 181: goto st181;
		case 182: goto st182;
		case 183: goto st183;
		case 184: goto st184;
		case 185: goto st185;
		case 281: goto st281;
		case 186: goto st186;
		case 187: goto st187;
		case 282: goto st282;
		case 283: goto st283;
		case 188: goto st188;
		case 189: goto st189;
		case 190: goto st190;
		case 191: goto st191;
		case 192: goto st192;
		case 284: goto st284;
		case 285: goto st285;
		case 193: goto st193;
		case 194: goto st194;
		case 195: goto st195;
		case 286: goto st286;
		case 287: goto st287;
		case 196: goto st196;
		case 197: goto st197;
		case 198: goto st198;
		case 199: goto st199;
		case 200: goto st200;
		case 288: goto st288;
		case 289: goto st289;
		case 201: goto st201;
		case 202: goto st202;
		case 203: goto st203;
		case 204: goto st204;
		case 205: goto st205;
		case 206: goto st206;
		case 207: goto st207;
		case 208: goto st208;
		case 290: goto st290;
		case 291: goto st291;
		case 209: goto st209;
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
		case 292: goto st292;
		case 293: goto st293;
		case 294: goto st294;
		case 295: goto st295;
		case 235: goto st235;
		case 296: goto st296;
		case 297: goto st297;
		case 236: goto st236;
	default: break;
	}

	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof;
_resume:
	switch (  sm->cs )
	{
tr0:
#line 884 "ext/dtext/dtext.rl"
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
{( ((int *)sm->stack->data))[( sm->top)++] = 237; goto st252;}}
  }}
	goto st237;
tr43:
#line 842 "ext/dtext/dtext.rl"
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
{( ((int *)sm->stack->data))[( sm->top)++] = 237; goto st290;}}
  }}
	goto st237;
tr44:
#line 850 "ext/dtext/dtext.rl"
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
{( ((int *)sm->stack->data))[( sm->top)++] = 237; goto st252;}}
  }}
	goto st237;
tr281:
#line 884 "ext/dtext/dtext.rl"
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
{( ((int *)sm->stack->data))[( sm->top)++] = 237; goto st252;}}
  }}
	goto st237;
tr282:
#line 878 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_close(sm);
  }}
	goto st237;
tr283:
#line 882 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;}
	goto st237;
tr285:
#line 866 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    append(sm, "&amp;");
  }}
	goto st237;
tr287:
#line 870 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    append(sm, "&lt;");
  }}
	goto st237;
tr288:
#line 874 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    append(sm, "&gt;");
  }}
	goto st237;
tr291:
#line 882 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;}
	goto st237;
tr292:
#line 884 "ext/dtext/dtext.rl"
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
{( ((int *)sm->stack->data))[( sm->top)++] = 237; goto st252;}}
  }}
	goto st237;
tr293:
#line 96 "ext/dtext/dtext.rl"
	{
  sm->b2 = sm->p;
}
#line 858 "ext/dtext/dtext.rl"
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
{( ((int *)sm->stack->data))[( sm->top)++] = 237; goto st292;}}
  }}
	goto st237;
tr301:
#line 801 "ext/dtext/dtext.rl"
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
{( ((int *)sm->stack->data))[( sm->top)++] = 237; goto st286;}}
  }}
	goto st237;
tr302:
#line 821 "ext/dtext/dtext.rl"
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
{( ((int *)sm->stack->data))[( sm->top)++] = 237; goto st252;}}
  }}
	goto st237;
tr304:
#line 810 "ext/dtext/dtext.rl"
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
{( ((int *)sm->stack->data))[( sm->top)++] = 237; goto st252;}}
  }}
	goto st237;
tr305:
#line 835 "ext/dtext/dtext.rl"
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
{( ((int *)sm->stack->data))[( sm->top)++] = 237; goto st288;}}
  }}
	goto st237;
tr306:
#line 783 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    dstack_push(sm, &BLOCK_QUOTE);
    append_newline(sm);
    append_newline(sm);
    append_block(sm, "<blockquote>");
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
{( ((int *)sm->stack->data))[( sm->top)++] = 237; goto st252;}}
  }}
	goto st237;
tr307:
#line 792 "ext/dtext/dtext.rl"
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
{( ((int *)sm->stack->data))[( sm->top)++] = 237; goto st252;}}
  }}
	goto st237;
tr309:
#line 96 "ext/dtext/dtext.rl"
	{
  sm->b2 = sm->p;
}
#line 763 "ext/dtext/dtext.rl"
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
	goto st237;
st237:
#line 1 "NONE"
	{( sm->ts) = 0;}
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof237;
case 237:
#line 1 "NONE"
	{( sm->ts) = ( sm->p);}
#line 968 "ext/dtext/dtext.c"
	switch( (*( sm->p)) ) {
		case 0: goto tr282;
		case 10: goto tr283;
		case 13: goto st238;
		case 38: goto tr285;
		case 42: goto tr286;
		case 60: goto tr287;
		case 62: goto tr288;
		case 91: goto tr289;
		case 104: goto tr290;
	}
	goto tr281;
st238:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof238;
case 238:
	if ( (*( sm->p)) == 10 )
		goto tr283;
	goto tr291;
tr286:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 84 "ext/dtext/dtext.rl"
	{
  sm->a1 = sm->p;
}
	goto st239;
st239:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof239;
case 239:
#line 1000 "ext/dtext/dtext.c"
	switch( (*( sm->p)) ) {
		case 9: goto tr3;
		case 32: goto tr3;
		case 42: goto st1;
	}
	goto tr292;
tr3:
#line 88 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
	goto st0;
st0:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof0;
case 0:
#line 1017 "ext/dtext/dtext.c"
	switch( (*( sm->p)) ) {
		case 0: goto tr0;
		case 9: goto tr2;
		case 10: goto tr0;
		case 13: goto tr0;
		case 32: goto tr2;
	}
	goto tr1;
tr1:
#line 92 "ext/dtext/dtext.rl"
	{
  sm->b1 = sm->p;
}
	goto st240;
st240:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof240;
case 240:
#line 1036 "ext/dtext/dtext.c"
	switch( (*( sm->p)) ) {
		case 0: goto tr293;
		case 10: goto tr293;
		case 13: goto tr293;
	}
	goto st240;
tr2:
#line 92 "ext/dtext/dtext.rl"
	{
  sm->b1 = sm->p;
}
	goto st241;
st241:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof241;
case 241:
#line 1053 "ext/dtext/dtext.c"
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
	goto st242;
st242:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof242;
case 242:
#line 1080 "ext/dtext/dtext.c"
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
		goto st243;
	goto tr0;
st243:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof243;
case 243:
	if ( (*( sm->p)) == 32 )
		goto st243;
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto st243;
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
		case 93: goto st245;
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
#line 84 "ext/dtext/dtext.rl"
	{
  sm->a1 = sm->p;
}
	goto st13;
st13:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof13;
case 13:
#line 1188 "ext/dtext/dtext.c"
	if ( (*( sm->p)) == 93 )
		goto tr18;
	goto st13;
tr18:
#line 88 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
	goto st244;
st244:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof244;
case 244:
#line 1202 "ext/dtext/dtext.c"
	if ( (*( sm->p)) == 32 )
		goto st244;
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto st244;
	goto tr302;
st245:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof245;
case 245:
	if ( (*( sm->p)) == 32 )
		goto st245;
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto st245;
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
		goto st246;
	goto tr0;
st246:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof246;
case 246:
	if ( (*( sm->p)) == 32 )
		goto st246;
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto st246;
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
	goto st249;
st249:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof249;
case 249:
#line 1429 "ext/dtext/dtext.c"
	if ( 49 <= (*( sm->p)) && (*( sm->p)) <= 54 )
		goto tr308;
	goto tr292;
tr308:
#line 84 "ext/dtext/dtext.rl"
	{
  sm->a1 = sm->p;
}
	goto st39;
st39:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof39;
case 39:
#line 1443 "ext/dtext/dtext.c"
	if ( (*( sm->p)) == 46 )
		goto tr45;
	goto tr0;
tr45:
#line 88 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
	goto st40;
st40:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof40;
case 40:
#line 1457 "ext/dtext/dtext.c"
	switch( (*( sm->p)) ) {
		case 0: goto tr0;
		case 9: goto tr47;
		case 10: goto tr0;
		case 13: goto tr0;
		case 32: goto tr47;
	}
	goto tr46;
tr46:
#line 92 "ext/dtext/dtext.rl"
	{
  sm->b1 = sm->p;
}
	goto st250;
st250:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof250;
case 250:
#line 1476 "ext/dtext/dtext.c"
	switch( (*( sm->p)) ) {
		case 0: goto tr309;
		case 10: goto tr309;
		case 13: goto tr309;
	}
	goto st250;
tr47:
#line 92 "ext/dtext/dtext.rl"
	{
  sm->b1 = sm->p;
}
	goto st251;
st251:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof251;
case 251:
#line 1493 "ext/dtext/dtext.c"
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
    append_segment_html_escaped(sm, sm->a1, sm->a2 - sm->d);
    append(sm, "\">@");
    append_segment_html_escaped(sm, sm->a1, sm->a2 - sm->d);
    append(sm, "</a>");

    if (sm->b) {
      append_c(sm, (*( sm->p)));
    }
  }
	break;
	case 40:
	{{( sm->p) = ((( sm->te)))-1;}
    dstack_close(sm);
    sm->list_mode = false;
    {( sm->p) = (( sm->ts))-1;}
    { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)];goto _again;}
  }
	break;
	case 41:
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
	case 45:
	{{( sm->p) = ((( sm->te)))-1;}
    append_c(sm, (*( sm->p)));
  }
	break;
	}
	}
	goto st252;
tr62:
#line 496 "ext/dtext/dtext.rl"
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
	goto st252;
tr67:
#line 448 "ext/dtext/dtext.rl"
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
	goto st252;
tr74:
#line 472 "ext/dtext/dtext.rl"
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
	goto st252;
tr85:
#line 442 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_close(sm);
    {( sm->p) = (( sm->p - 6))-1;}
    { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)];goto _again;}
  }}
	goto st252;
tr86:
#line 565 "ext/dtext/dtext.rl"
	{{( sm->p) = ((( sm->te)))-1;}{
    append_c(sm, (*( sm->p)));
  }}
	goto st252;
tr97:
#line 96 "ext/dtext/dtext.rl"
	{
  sm->b2 = sm->p;
}
#line 306 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    append(sm, "<a href=\"");
    append_segment_html_escaped(sm, sm->b1, sm->b2 - 1);
    append(sm, "\">");
    append_segment_html_escaped(sm, sm->a1, sm->a2 - 1);
    append(sm, "</a>");
  }}
	goto st252;
tr117:
#line 364 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    if (dstack_check(sm, INLINE_B)) {
      dstack_pop(sm);
      append(sm, "</strong>");
    } else {
      append(sm, "[/b]");
    }
  }}
	goto st252;
tr118:
#line 378 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    if (dstack_check(sm, INLINE_I)) {
      dstack_pop(sm);
      append(sm, "</em>");
    } else {
      append(sm, "[/i]");
    }
  }}
	goto st252;
tr119:
#line 392 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    if (dstack_check(sm, INLINE_S)) {
      dstack_pop(sm);
      append(sm, "</s>");
    } else {
      append(sm, "[/s]");
    }
  }}
	goto st252;
tr122:
#line 514 "ext/dtext/dtext.rl"
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
	goto st252;
tr123:
#line 420 "ext/dtext/dtext.rl"
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
	goto st252;
tr124:
#line 406 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    if (dstack_check(sm, INLINE_U)) {
      dstack_pop(sm);
      append(sm, "</u>");
    } else {
      append(sm, "[/u]");
    }
  }}
	goto st252;
tr129:
#line 244 "ext/dtext/dtext.rl"
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
    append_segment_html_escaped(sm, lowercase_segment->str, lowercase_segment->str + lowercase_segment->len - 1);
    append(sm, "\">");
    append_segment_html_escaped(sm, sm->a1, sm->a2 - 1);
    append(sm, "</a>");

    g_string_free(lowercase_segment, TRUE);
    g_string_free(segment, TRUE);
  }}
	goto st252;
tr133:
#line 265 "ext/dtext/dtext.rl"
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
    append_segment_html_escaped(sm, lowercase_segment->str, lowercase_segment->str + lowercase_segment->len - 1);
    append(sm, "\">");
    append_segment_html_escaped(sm, sm->b1, sm->b2 - 1);
    append(sm, "</a>");

    g_string_free(lowercase_segment, TRUE);
    g_string_free(segment, TRUE);
  }}
	goto st252;
tr134:
#line 359 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_push(sm, &INLINE_B);
    append(sm, "<strong>");
  }}
	goto st252;
tr135:
#line 373 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_push(sm, &INLINE_I);
    append(sm, "<em>");
  }}
	goto st252;
tr142:
#line 509 "ext/dtext/dtext.rl"
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
{( ((int *)sm->stack->data))[( sm->top)++] = 252; goto st288;}}
  }}
	goto st252;
tr143:
#line 387 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_push(sm, &INLINE_S);
    append(sm, "<s>");
  }}
	goto st252;
tr150:
#line 467 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_push(sm, &INLINE_SPOILER);
    append(sm, "<span class=\"spoiler\">");
  }}
	goto st252;
tr152:
#line 415 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_push(sm, &INLINE_TN);
    append(sm, "<span class=\"tn\">");
  }}
	goto st252;
tr153:
#line 401 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_push(sm, &INLINE_U);
    append(sm, "<u>");
  }}
	goto st252;
tr197:
#line 216 "ext/dtext/dtext.rl"
	{{( sm->p) = ((( sm->te)))-1;}{
    append(sm, "<a href=\"http://www.pixiv.net/member_illust.php?mode=medium&illust_id=");
    append_segment(sm, sm->a1, sm->a2);
    append(sm, "\">pixiv #");
    append_segment(sm, sm->a1, sm->a2);
    append(sm, "</a>");
  }}
	goto st252;
tr216:
#line 156 "ext/dtext/dtext.rl"
	{{( sm->p) = ((( sm->te)))-1;}{
    append(sm, "<a href=\"/forum_topics/");
    append_segment(sm, sm->a1, sm->a2 - 1);
    append(sm, "\">topic #");
    append_segment(sm, sm->a1, sm->a2 - 1);
    append(sm, "</a>");
  }}
	goto st252;
tr227:
#line 236 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    append(sm, "<a rel=\"nofollow\" href=\"/posts?tags=");
    append_segment_html_escaped(sm, sm->a1, sm->a2);
    append(sm, "\">");
    append_segment_html_escaped(sm, sm->a1, sm->a2);
    append(sm, "</a>");
  }}
	goto st252;
tr311:
#line 565 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    append_c(sm, (*( sm->p)));
  }}
	goto st252;
tr312:
#line 526 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    ( sm->p)--;
    { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)];goto _again;}
  }}
	goto st252;
tr317:
#line 561 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    append(sm, "&amp;");
  }}
	goto st252;
tr318:
#line 557 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    append(sm, "&lt;");
  }}
	goto st252;
tr319:
#line 553 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    append(sm, "&gt;");
  }}
	goto st252;
tr331:
#line 565 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append_c(sm, (*( sm->p)));
  }}
	goto st252;
tr332:
#line 489 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    dstack_close(sm);
    {( sm->p) = (((sm->p - 8)))-1;}
    printf("%c\n", (*( sm->p)));
    { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)];goto _again;}
  }}
	goto st252;
tr334:
#line 538 "ext/dtext/dtext.rl"
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
	goto st252;
tr336:
#line 96 "ext/dtext/dtext.rl"
	{
  sm->b2 = sm->p;
}
#line 286 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    if (is_boundary_c((*( sm->p)))) {
      sm->d = 2;
      sm->b = true;
    } else {
      sm->d = 1;
      sm->b = false;
    }

    append(sm, "<a href=\"");
    append_segment_html_escaped(sm, sm->b1, sm->b2 - sm->d);
    append(sm, "\">");
    append_segment_html_escaped(sm, sm->a1, sm->a2 - 1);
    append(sm, "</a>");

    if (sm->b) {
      append_c(sm, (*( sm->p)));
    }
  }}
	goto st252;
tr338:
#line 88 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
#line 339 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    if (is_boundary_c((*( sm->p)))) {
      sm->b = true;
      sm->d = 2;
    } else {
      sm->b = false;
      sm->d = 1;
    }

    append(sm, "<a rel=\"nofollow\" href=\"/users?name=");
    append_segment_html_escaped(sm, sm->a1, sm->a2 - sm->d);
    append(sm, "\">@");
    append_segment_html_escaped(sm, sm->a1, sm->a2 - sm->d);
    append(sm, "</a>");

    if (sm->b) {
      append_c(sm, (*( sm->p)));
    }
  }}
	goto st252;
tr341:
#line 88 "ext/dtext/dtext.rl"
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
    append_segment_html_escaped(sm, sm->a1, sm->a2 - sm->d);
    append(sm, "\">@");
    append_segment_html_escaped(sm, sm->a1, sm->a2 - sm->d);
    append(sm, "</a>");

    if (sm->b) {
      append_c(sm, (*( sm->p)));
    }
  }
	break;
	case 40:
	{{( sm->p) = ((( sm->te)))-1;}
    dstack_close(sm);
    sm->list_mode = false;
    {( sm->p) = (( sm->ts))-1;}
    { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)];goto _again;}
  }
	break;
	case 41:
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
	case 45:
	{{( sm->p) = ((( sm->te)))-1;}
    append_c(sm, (*( sm->p)));
  }
	break;
	}
	}
	goto st252;
tr351:
#line 88 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
#line 200 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append(sm, "<a href=\"/artists/");
    append_segment(sm, sm->a1, sm->a2);
    append(sm, "\">artist #");
    append_segment(sm, sm->a1, sm->a2);
    append(sm, "</a>");
  }}
	goto st252;
tr354:
#line 88 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
#line 176 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append(sm, "<a href=\"/comments/");
    append_segment(sm, sm->a1, sm->a2);
    append(sm, "\">comment #");
    append_segment(sm, sm->a1, sm->a2);
    append(sm, "</a>");
  }}
	goto st252;
tr357:
#line 88 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
#line 148 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append(sm, "<a href=\"/forum_posts/");
    append_segment(sm, sm->a1, sm->a2);
    append(sm, "\">forum #");
    append_segment(sm, sm->a1, sm->a2);
    append(sm, "</a>");
  }}
	goto st252;
tr361:
#line 96 "ext/dtext/dtext.rl"
	{
  sm->b2 = sm->p;
}
#line 436 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    dstack_close(sm);
    {( sm->p) = (( sm->a1 - 1))-1;}
    { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)];goto _again;}
  }}
	goto st252;
tr363:
#line 314 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    if (is_boundary_c((*( sm->p)))) {
      sm->b = true;
      sm->d = 2;
    } else {
      sm->b = false;
      sm->d = 1;
    }

    append(sm, "<a href=\"");
    append_segment_html_escaped(sm, sm->ts, sm->te - sm->d);
    append(sm, "\">");
    append_segment_html_escaped(sm, sm->ts, sm->te - sm->d);
    append(sm, "</a>");

    if (sm->b) {
      append_c(sm, (*( sm->p)));
    }
  }}
	goto st252;
tr365:
#line 88 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
#line 208 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append(sm, "<a href=\"https://github.com/r888888888/danbooru/issues/");
    append_segment(sm, sm->a1, sm->a2);
    append(sm, "\">issue #");
    append_segment(sm, sm->a1, sm->a2);
    append(sm, "</a>");
  }}
	goto st252;
tr369:
#line 88 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
#line 216 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append(sm, "<a href=\"http://www.pixiv.net/member_illust.php?mode=medium&illust_id=");
    append_segment(sm, sm->a1, sm->a2);
    append(sm, "\">pixiv #");
    append_segment(sm, sm->a1, sm->a2);
    append(sm, "</a>");
  }}
	goto st252;
tr372:
#line 96 "ext/dtext/dtext.rl"
	{
  sm->b2 = sm->p;
}
#line 224 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append(sm, "<a href=\"http://www.pixiv.net/member_illust.php?mode=manga_big&illust_id=");
    append_segment(sm, sm->a1, sm->a2);
    append(sm, "&page=");
    append_segment(sm, sm->b1, sm->b2);
    append(sm, "\">pixiv #");
    append_segment(sm, sm->a1, sm->a2);
    append(sm, "/p");
    append_segment(sm, sm->b1, sm->b2);
    append(sm, "</a>");
  }}
	goto st252;
tr374:
#line 88 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
#line 184 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append(sm, "<a href=\"/pools/");
    append_segment(sm, sm->a1, sm->a2);
    append(sm, "\">pool #");
    append_segment(sm, sm->a1, sm->a2);
    append(sm, "</a>");
  }}
	goto st252;
tr376:
#line 88 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
#line 140 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append(sm, "<a href=\"/posts/");
    append_segment(sm, sm->a1, sm->a2);
    append(sm, "\">post #");
    append_segment(sm, sm->a1, sm->a2);
    append(sm, "</a>");
  }}
	goto st252;
tr379:
#line 88 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
#line 156 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append(sm, "<a href=\"/forum_topics/");
    append_segment(sm, sm->a1, sm->a2 - 1);
    append(sm, "\">topic #");
    append_segment(sm, sm->a1, sm->a2 - 1);
    append(sm, "</a>");
  }}
	goto st252;
tr382:
#line 96 "ext/dtext/dtext.rl"
	{
  sm->b2 = sm->p;
}
#line 164 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append(sm, "<a href=\"/forum_topics/");
    append_segment(sm, sm->a1, sm->a2);
    append(sm, "?page=");
    append_segment(sm, sm->b1, sm->b2);
    append(sm, "\">topic #");
    append_segment(sm, sm->a1, sm->a2);
    append(sm, "/p");
    append_segment(sm, sm->b1, sm->b2);
    append(sm, "</a>");
  }}
	goto st252;
tr385:
#line 88 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
#line 192 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append(sm, "<a href=\"/users/");
    append_segment(sm, sm->a1, sm->a2);
    append(sm, "\">user #");
    append_segment(sm, sm->a1, sm->a2);
    append(sm, "</a>");
  }}
	goto st252;
st252:
#line 1 "NONE"
	{( sm->ts) = 0;}
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof252;
case 252:
#line 1 "NONE"
	{( sm->ts) = ( sm->p);}
#line 2240 "ext/dtext/dtext.c"
	switch( (*( sm->p)) ) {
		case 0: goto tr312;
		case 10: goto tr314;
		case 13: goto tr315;
		case 32: goto tr313;
		case 34: goto tr316;
		case 38: goto tr317;
		case 60: goto tr318;
		case 62: goto tr319;
		case 64: goto st259;
		case 91: goto tr321;
		case 97: goto tr322;
		case 99: goto tr323;
		case 102: goto tr324;
		case 104: goto tr325;
		case 105: goto tr326;
		case 112: goto tr327;
		case 116: goto tr328;
		case 117: goto tr329;
		case 123: goto tr330;
	}
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 12 )
		goto tr313;
	goto tr311;
tr313:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 565 "ext/dtext/dtext.rl"
	{( sm->act) = 45;}
	goto st253;
st253:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof253;
case 253:
#line 2275 "ext/dtext/dtext.c"
	switch( (*( sm->p)) ) {
		case 32: goto st41;
		case 91: goto st42;
	}
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto st41;
	goto tr331;
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
		goto st254;
	goto tr48;
st254:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof254;
case 254:
	if ( (*( sm->p)) == 32 )
		goto st254;
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto st254;
	goto tr332;
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
#line 538 "ext/dtext/dtext.rl"
	{( sm->act) = 41;}
	goto st255;
tr333:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 531 "ext/dtext/dtext.rl"
	{( sm->act) = 40;}
	goto st255;
st255:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof255;
case 255:
#line 2542 "ext/dtext/dtext.c"
	switch( (*( sm->p)) ) {
		case 10: goto tr333;
		case 13: goto tr333;
		case 32: goto st41;
		case 91: goto st42;
	}
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 12 )
		goto st41;
	goto tr48;
tr315:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 538 "ext/dtext/dtext.rl"
	{( sm->act) = 41;}
	goto st256;
st256:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof256;
case 256:
#line 2562 "ext/dtext/dtext.c"
	switch( (*( sm->p)) ) {
		case 10: goto tr333;
		case 13: goto tr333;
		case 32: goto st41;
		case 91: goto st42;
	}
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 12 )
		goto st41;
	goto tr334;
tr316:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
	goto st257;
st257:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof257;
case 257:
#line 2580 "ext/dtext/dtext.c"
	if ( (*( sm->p)) == 34 )
		goto tr331;
	goto tr335;
tr335:
#line 84 "ext/dtext/dtext.rl"
	{
  sm->a1 = sm->p;
}
	goto st73;
st73:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof73;
case 73:
#line 2594 "ext/dtext/dtext.c"
	if ( (*( sm->p)) == 34 )
		goto tr88;
	goto st73;
tr88:
#line 88 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
	goto st74;
st74:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof74;
case 74:
#line 2608 "ext/dtext/dtext.c"
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
#line 92 "ext/dtext/dtext.rl"
	{
  sm->b1 = sm->p;
}
	goto st76;
st76:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof76;
case 76:
#line 2632 "ext/dtext/dtext.c"
	if ( 33 <= (*( sm->p)) && (*( sm->p)) <= 126 )
		goto st258;
	goto tr86;
st258:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof258;
case 258:
	if ( 33 <= (*( sm->p)) && (*( sm->p)) <= 126 )
		goto st258;
	goto tr336;
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
#line 92 "ext/dtext/dtext.rl"
	{
  sm->b1 = sm->p;
}
	goto st78;
st78:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof78;
case 78:
#line 2662 "ext/dtext/dtext.c"
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
#line 92 "ext/dtext/dtext.rl"
	{
  sm->b1 = sm->p;
}
	goto st80;
st80:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof80;
case 80:
#line 2685 "ext/dtext/dtext.c"
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
#line 92 "ext/dtext/dtext.rl"
	{
  sm->b1 = sm->p;
}
	goto st87;
st87:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof87;
case 87:
#line 2743 "ext/dtext/dtext.c"
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
st259:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof259;
case 259:
	if ( 33 <= (*( sm->p)) && (*( sm->p)) <= 126 )
		goto tr337;
	goto tr331;
tr337:
#line 84 "ext/dtext/dtext.rl"
	{
  sm->a1 = sm->p;
}
	goto st260;
st260:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof260;
case 260:
#line 2808 "ext/dtext/dtext.c"
	if ( (*( sm->p)) == 64 )
		goto tr340;
	if ( 33 <= (*( sm->p)) && (*( sm->p)) <= 126 )
		goto tr339;
	goto tr338;
tr339:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 339 "ext/dtext/dtext.rl"
	{( sm->act) = 19;}
	goto st261;
tr340:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 335 "ext/dtext/dtext.rl"
	{( sm->act) = 18;}
	goto st261;
st261:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof261;
case 261:
#line 2830 "ext/dtext/dtext.c"
	if ( 33 <= (*( sm->p)) && (*( sm->p)) <= 126 )
		goto tr339;
	goto tr341;
tr321:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 565 "ext/dtext/dtext.rl"
	{( sm->act) = 45;}
	goto st262;
st262:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof262;
case 262:
#line 2844 "ext/dtext/dtext.c"
	switch( (*( sm->p)) ) {
		case 47: goto st94;
		case 91: goto st102;
		case 98: goto st108;
		case 101: goto st62;
		case 105: goto st109;
		case 110: goto st110;
		case 113: goto st68;
		case 115: goto st117;
		case 116: goto st124;
		case 117: goto st126;
	}
	goto tr331;
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
		case 117: goto st101;
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
		case 110: goto st100;
	}
	goto tr86;
st99:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof99;
case 99:
	if ( (*( sm->p)) == 93 )
		goto tr122;
	goto tr86;
st100:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof100;
case 100:
	if ( (*( sm->p)) == 93 )
		goto tr123;
	goto tr86;
st101:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof101;
case 101:
	if ( (*( sm->p)) == 93 )
		goto tr124;
	goto tr86;
st102:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof102;
case 102:
	switch( (*( sm->p)) ) {
		case 93: goto tr86;
		case 124: goto tr86;
	}
	goto tr125;
tr125:
#line 84 "ext/dtext/dtext.rl"
	{
  sm->a1 = sm->p;
}
	goto st103;
st103:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof103;
case 103:
#line 2944 "ext/dtext/dtext.c"
	switch( (*( sm->p)) ) {
		case 93: goto tr127;
		case 124: goto tr128;
	}
	goto st103;
tr127:
#line 88 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
	goto st104;
st104:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof104;
case 104:
#line 2960 "ext/dtext/dtext.c"
	if ( (*( sm->p)) == 93 )
		goto tr129;
	goto tr86;
tr128:
#line 88 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
	goto st105;
st105:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof105;
case 105:
#line 2974 "ext/dtext/dtext.c"
	if ( (*( sm->p)) == 93 )
		goto tr86;
	goto tr130;
tr130:
#line 92 "ext/dtext/dtext.rl"
	{
  sm->b1 = sm->p;
}
	goto st106;
st106:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof106;
case 106:
#line 2988 "ext/dtext/dtext.c"
	if ( (*( sm->p)) == 93 )
		goto tr132;
	goto st106;
tr132:
#line 96 "ext/dtext/dtext.rl"
	{
  sm->b2 = sm->p;
}
	goto st107;
st107:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof107;
case 107:
#line 3002 "ext/dtext/dtext.c"
	if ( (*( sm->p)) == 93 )
		goto tr133;
	goto tr86;
st108:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof108;
case 108:
	if ( (*( sm->p)) == 93 )
		goto tr134;
	goto tr86;
st109:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof109;
case 109:
	if ( (*( sm->p)) == 93 )
		goto tr135;
	goto tr86;
st110:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof110;
case 110:
	if ( (*( sm->p)) == 111 )
		goto st111;
	goto tr86;
st111:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof111;
case 111:
	if ( (*( sm->p)) == 100 )
		goto st112;
	goto tr86;
st112:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof112;
case 112:
	if ( (*( sm->p)) == 116 )
		goto st113;
	goto tr86;
st113:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof113;
case 113:
	if ( (*( sm->p)) == 101 )
		goto st114;
	goto tr86;
st114:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof114;
case 114:
	if ( (*( sm->p)) == 120 )
		goto st115;
	goto tr86;
st115:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof115;
case 115:
	if ( (*( sm->p)) == 116 )
		goto st116;
	goto tr86;
st116:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof116;
case 116:
	if ( (*( sm->p)) == 93 )
		goto tr142;
	goto tr86;
st117:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof117;
case 117:
	switch( (*( sm->p)) ) {
		case 93: goto tr143;
		case 112: goto st118;
	}
	goto tr86;
st118:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof118;
case 118:
	if ( (*( sm->p)) == 111 )
		goto st119;
	goto tr86;
st119:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof119;
case 119:
	if ( (*( sm->p)) == 105 )
		goto st120;
	goto tr86;
st120:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof120;
case 120:
	if ( (*( sm->p)) == 108 )
		goto st121;
	goto tr86;
st121:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof121;
case 121:
	if ( (*( sm->p)) == 101 )
		goto st122;
	goto tr86;
st122:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof122;
case 122:
	if ( (*( sm->p)) == 114 )
		goto st123;
	goto tr86;
st123:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof123;
case 123:
	if ( (*( sm->p)) == 93 )
		goto tr150;
	goto tr86;
st124:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof124;
case 124:
	if ( (*( sm->p)) == 110 )
		goto st125;
	goto tr86;
st125:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof125;
case 125:
	if ( (*( sm->p)) == 93 )
		goto tr152;
	goto tr86;
st126:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof126;
case 126:
	if ( (*( sm->p)) == 93 )
		goto tr153;
	goto tr86;
tr322:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
	goto st263;
st263:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof263;
case 263:
#line 3149 "ext/dtext/dtext.c"
	if ( (*( sm->p)) == 114 )
		goto st127;
	goto tr331;
st127:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof127;
case 127:
	if ( (*( sm->p)) == 116 )
		goto st128;
	goto tr86;
st128:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof128;
case 128:
	if ( (*( sm->p)) == 105 )
		goto st129;
	goto tr86;
st129:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof129;
case 129:
	if ( (*( sm->p)) == 115 )
		goto st130;
	goto tr86;
st130:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof130;
case 130:
	if ( (*( sm->p)) == 116 )
		goto st131;
	goto tr86;
st131:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof131;
case 131:
	if ( (*( sm->p)) == 32 )
		goto st132;
	goto tr86;
st132:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof132;
case 132:
	if ( (*( sm->p)) == 35 )
		goto st133;
	goto tr86;
st133:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof133;
case 133:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr160;
	goto tr86;
tr160:
#line 84 "ext/dtext/dtext.rl"
	{
  sm->a1 = sm->p;
}
	goto st264;
st264:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof264;
case 264:
#line 3212 "ext/dtext/dtext.c"
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto st264;
	goto tr351;
tr323:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
	goto st265;
st265:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof265;
case 265:
#line 3224 "ext/dtext/dtext.c"
	if ( (*( sm->p)) == 111 )
		goto st134;
	goto tr331;
st134:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof134;
case 134:
	if ( (*( sm->p)) == 109 )
		goto st135;
	goto tr86;
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
	if ( (*( sm->p)) == 101 )
		goto st137;
	goto tr86;
st137:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof137;
case 137:
	if ( (*( sm->p)) == 110 )
		goto st138;
	goto tr86;
st138:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof138;
case 138:
	if ( (*( sm->p)) == 116 )
		goto st139;
	goto tr86;
st139:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof139;
case 139:
	if ( (*( sm->p)) == 32 )
		goto st140;
	goto tr86;
st140:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof140;
case 140:
	if ( (*( sm->p)) == 35 )
		goto st141;
	goto tr86;
st141:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof141;
case 141:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr168;
	goto tr86;
tr168:
#line 84 "ext/dtext/dtext.rl"
	{
  sm->a1 = sm->p;
}
	goto st266;
st266:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof266;
case 266:
#line 3294 "ext/dtext/dtext.c"
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto st266;
	goto tr354;
tr324:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
	goto st267;
st267:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof267;
case 267:
#line 3306 "ext/dtext/dtext.c"
	if ( (*( sm->p)) == 111 )
		goto st142;
	goto tr331;
st142:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof142;
case 142:
	if ( (*( sm->p)) == 114 )
		goto st143;
	goto tr86;
st143:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof143;
case 143:
	if ( (*( sm->p)) == 117 )
		goto st144;
	goto tr86;
st144:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof144;
case 144:
	if ( (*( sm->p)) == 109 )
		goto st145;
	goto tr86;
st145:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof145;
case 145:
	if ( (*( sm->p)) == 32 )
		goto st146;
	goto tr86;
st146:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof146;
case 146:
	if ( (*( sm->p)) == 35 )
		goto st147;
	goto tr86;
st147:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof147;
case 147:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr174;
	goto tr86;
tr174:
#line 84 "ext/dtext/dtext.rl"
	{
  sm->a1 = sm->p;
}
	goto st268;
st268:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof268;
case 268:
#line 3362 "ext/dtext/dtext.c"
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto st268;
	goto tr357;
tr325:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
	goto st269;
st269:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof269;
case 269:
#line 3374 "ext/dtext/dtext.c"
	if ( (*( sm->p)) == 116 )
		goto st150;
	if ( 49 <= (*( sm->p)) && (*( sm->p)) <= 54 )
		goto tr359;
	goto tr331;
tr359:
#line 84 "ext/dtext/dtext.rl"
	{
  sm->a1 = sm->p;
}
	goto st148;
st148:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof148;
case 148:
#line 3390 "ext/dtext/dtext.c"
	if ( (*( sm->p)) == 46 )
		goto tr175;
	goto tr86;
tr175:
#line 88 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
	goto st149;
st149:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof149;
case 149:
#line 3404 "ext/dtext/dtext.c"
	switch( (*( sm->p)) ) {
		case 0: goto tr86;
		case 9: goto tr177;
		case 10: goto tr86;
		case 13: goto tr86;
		case 32: goto tr177;
	}
	goto tr176;
tr176:
#line 92 "ext/dtext/dtext.rl"
	{
  sm->b1 = sm->p;
}
	goto st270;
st270:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof270;
case 270:
#line 3423 "ext/dtext/dtext.c"
	switch( (*( sm->p)) ) {
		case 0: goto tr361;
		case 10: goto tr361;
		case 13: goto tr361;
	}
	goto st270;
tr177:
#line 92 "ext/dtext/dtext.rl"
	{
  sm->b1 = sm->p;
}
	goto st271;
st271:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof271;
case 271:
#line 3440 "ext/dtext/dtext.c"
	switch( (*( sm->p)) ) {
		case 0: goto tr361;
		case 9: goto tr177;
		case 10: goto tr361;
		case 13: goto tr361;
		case 32: goto tr177;
	}
	goto tr176;
st150:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof150;
case 150:
	if ( (*( sm->p)) == 116 )
		goto st151;
	goto tr86;
st151:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof151;
case 151:
	if ( (*( sm->p)) == 112 )
		goto st152;
	goto tr86;
st152:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof152;
case 152:
	switch( (*( sm->p)) ) {
		case 58: goto st153;
		case 115: goto st156;
	}
	goto tr86;
st153:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof153;
case 153:
	if ( (*( sm->p)) == 47 )
		goto st154;
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
	if ( 33 <= (*( sm->p)) && (*( sm->p)) <= 126 )
		goto st272;
	goto tr86;
st272:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof272;
case 272:
	if ( 33 <= (*( sm->p)) && (*( sm->p)) <= 126 )
		goto st272;
	goto tr363;
st156:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof156;
case 156:
	if ( (*( sm->p)) == 58 )
		goto st153;
	goto tr86;
tr326:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
	goto st273;
st273:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof273;
case 273:
#line 3515 "ext/dtext/dtext.c"
	if ( (*( sm->p)) == 115 )
		goto st157;
	goto tr331;
st157:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof157;
case 157:
	if ( (*( sm->p)) == 115 )
		goto st158;
	goto tr86;
st158:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof158;
case 158:
	if ( (*( sm->p)) == 117 )
		goto st159;
	goto tr86;
st159:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof159;
case 159:
	if ( (*( sm->p)) == 101 )
		goto st160;
	goto tr86;
st160:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof160;
case 160:
	if ( (*( sm->p)) == 32 )
		goto st161;
	goto tr86;
st161:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof161;
case 161:
	if ( (*( sm->p)) == 35 )
		goto st162;
	goto tr86;
st162:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof162;
case 162:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr190;
	goto tr86;
tr190:
#line 84 "ext/dtext/dtext.rl"
	{
  sm->a1 = sm->p;
}
	goto st274;
st274:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof274;
case 274:
#line 3571 "ext/dtext/dtext.c"
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto st274;
	goto tr365;
tr327:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
	goto st275;
st275:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof275;
case 275:
#line 3583 "ext/dtext/dtext.c"
	switch( (*( sm->p)) ) {
		case 105: goto st163;
		case 111: goto st171;
	}
	goto tr331;
st163:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof163;
case 163:
	if ( (*( sm->p)) == 120 )
		goto st164;
	goto tr86;
st164:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof164;
case 164:
	if ( (*( sm->p)) == 105 )
		goto st165;
	goto tr86;
st165:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof165;
case 165:
	if ( (*( sm->p)) == 118 )
		goto st166;
	goto tr86;
st166:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof166;
case 166:
	if ( (*( sm->p)) == 32 )
		goto st167;
	goto tr86;
st167:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof167;
case 167:
	if ( (*( sm->p)) == 35 )
		goto st168;
	goto tr86;
st168:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof168;
case 168:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr196;
	goto tr86;
tr196:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 84 "ext/dtext/dtext.rl"
	{
  sm->a1 = sm->p;
}
	goto st276;
tr371:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
	goto st276;
st276:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof276;
case 276:
#line 3647 "ext/dtext/dtext.c"
	if ( (*( sm->p)) == 47 )
		goto tr370;
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr371;
	goto tr369;
tr370:
#line 88 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
	goto st169;
st169:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof169;
case 169:
#line 3663 "ext/dtext/dtext.c"
	if ( (*( sm->p)) == 112 )
		goto st170;
	goto tr197;
st170:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof170;
case 170:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr199;
	goto tr197;
tr199:
#line 92 "ext/dtext/dtext.rl"
	{
  sm->b1 = sm->p;
}
	goto st277;
st277:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof277;
case 277:
#line 3684 "ext/dtext/dtext.c"
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto st277;
	goto tr372;
st171:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof171;
case 171:
	switch( (*( sm->p)) ) {
		case 111: goto st172;
		case 115: goto st176;
	}
	goto tr86;
st172:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof172;
case 172:
	if ( (*( sm->p)) == 108 )
		goto st173;
	goto tr86;
st173:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof173;
case 173:
	if ( (*( sm->p)) == 32 )
		goto st174;
	goto tr86;
st174:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof174;
case 174:
	if ( (*( sm->p)) == 35 )
		goto st175;
	goto tr86;
st175:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof175;
case 175:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr205;
	goto tr86;
tr205:
#line 84 "ext/dtext/dtext.rl"
	{
  sm->a1 = sm->p;
}
	goto st278;
st278:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof278;
case 278:
#line 3735 "ext/dtext/dtext.c"
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto st278;
	goto tr374;
st176:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof176;
case 176:
	if ( (*( sm->p)) == 116 )
		goto st177;
	goto tr86;
st177:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof177;
case 177:
	if ( (*( sm->p)) == 32 )
		goto st178;
	goto tr86;
st178:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof178;
case 178:
	if ( (*( sm->p)) == 35 )
		goto st179;
	goto tr86;
st179:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof179;
case 179:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr209;
	goto tr86;
tr209:
#line 84 "ext/dtext/dtext.rl"
	{
  sm->a1 = sm->p;
}
	goto st279;
st279:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof279;
case 279:
#line 3777 "ext/dtext/dtext.c"
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto st279;
	goto tr376;
tr328:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
	goto st280;
st280:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof280;
case 280:
#line 3789 "ext/dtext/dtext.c"
	if ( (*( sm->p)) == 111 )
		goto st180;
	goto tr331;
st180:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof180;
case 180:
	if ( (*( sm->p)) == 112 )
		goto st181;
	goto tr86;
st181:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof181;
case 181:
	if ( (*( sm->p)) == 105 )
		goto st182;
	goto tr86;
st182:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof182;
case 182:
	if ( (*( sm->p)) == 99 )
		goto st183;
	goto tr86;
st183:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof183;
case 183:
	if ( (*( sm->p)) == 32 )
		goto st184;
	goto tr86;
st184:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof184;
case 184:
	if ( (*( sm->p)) == 35 )
		goto st185;
	goto tr86;
st185:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof185;
case 185:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr215;
	goto tr86;
tr215:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 84 "ext/dtext/dtext.rl"
	{
  sm->a1 = sm->p;
}
	goto st281;
tr381:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
	goto st281;
st281:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof281;
case 281:
#line 3851 "ext/dtext/dtext.c"
	if ( (*( sm->p)) == 47 )
		goto tr380;
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr381;
	goto tr379;
tr380:
#line 88 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
	goto st186;
st186:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof186;
case 186:
#line 3867 "ext/dtext/dtext.c"
	if ( (*( sm->p)) == 112 )
		goto st187;
	goto tr216;
st187:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof187;
case 187:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr218;
	goto tr216;
tr218:
#line 92 "ext/dtext/dtext.rl"
	{
  sm->b1 = sm->p;
}
	goto st282;
st282:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof282;
case 282:
#line 3888 "ext/dtext/dtext.c"
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto st282;
	goto tr382;
tr329:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
	goto st283;
st283:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof283;
case 283:
#line 3900 "ext/dtext/dtext.c"
	if ( (*( sm->p)) == 115 )
		goto st188;
	goto tr331;
st188:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof188;
case 188:
	if ( (*( sm->p)) == 101 )
		goto st189;
	goto tr86;
st189:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof189;
case 189:
	if ( (*( sm->p)) == 114 )
		goto st190;
	goto tr86;
st190:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof190;
case 190:
	if ( (*( sm->p)) == 32 )
		goto st191;
	goto tr86;
st191:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof191;
case 191:
	if ( (*( sm->p)) == 35 )
		goto st192;
	goto tr86;
st192:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof192;
case 192:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr223;
	goto tr86;
tr223:
#line 84 "ext/dtext/dtext.rl"
	{
  sm->a1 = sm->p;
}
	goto st284;
st284:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof284;
case 284:
#line 3949 "ext/dtext/dtext.c"
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto st284;
	goto tr385;
tr330:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
	goto st285;
st285:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof285;
case 285:
#line 3961 "ext/dtext/dtext.c"
	if ( (*( sm->p)) == 123 )
		goto st193;
	goto tr331;
st193:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof193;
case 193:
	if ( (*( sm->p)) == 125 )
		goto tr86;
	goto tr224;
tr224:
#line 84 "ext/dtext/dtext.rl"
	{
  sm->a1 = sm->p;
}
	goto st194;
st194:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof194;
case 194:
#line 3982 "ext/dtext/dtext.c"
	if ( (*( sm->p)) == 125 )
		goto tr226;
	goto st194;
tr226:
#line 88 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
	goto st195;
st195:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof195;
case 195:
#line 3996 "ext/dtext/dtext.c"
	if ( (*( sm->p)) == 125 )
		goto tr227;
	goto tr86;
tr228:
#line 589 "ext/dtext/dtext.rl"
	{{( sm->p) = ((( sm->te)))-1;}{
    append_c(sm, (*( sm->p)));
  }}
	goto st286;
tr233:
#line 571 "ext/dtext/dtext.rl"
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
	goto st286;
tr388:
#line 589 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    append_c(sm, (*( sm->p)));
  }}
	goto st286;
tr389:
#line 584 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    ( sm->p)--;
    { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)];goto _again;}
  }}
	goto st286;
tr391:
#line 589 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append_c(sm, (*( sm->p)));
  }}
	goto st286;
st286:
#line 1 "NONE"
	{( sm->ts) = 0;}
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof286;
case 286:
#line 1 "NONE"
	{( sm->ts) = ( sm->p);}
#line 4048 "ext/dtext/dtext.c"
	switch( (*( sm->p)) ) {
		case 0: goto tr389;
		case 91: goto tr390;
	}
	goto tr388;
tr390:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
	goto st287;
st287:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof287;
case 287:
#line 4062 "ext/dtext/dtext.c"
	if ( (*( sm->p)) == 47 )
		goto st196;
	goto tr391;
st196:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof196;
case 196:
	if ( (*( sm->p)) == 99 )
		goto st197;
	goto tr228;
st197:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof197;
case 197:
	if ( (*( sm->p)) == 111 )
		goto st198;
	goto tr228;
st198:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof198;
case 198:
	if ( (*( sm->p)) == 100 )
		goto st199;
	goto tr228;
st199:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof199;
case 199:
	if ( (*( sm->p)) == 101 )
		goto st200;
	goto tr228;
st200:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof200;
case 200:
	if ( (*( sm->p)) == 93 )
		goto tr233;
	goto tr228;
tr234:
#line 628 "ext/dtext/dtext.rl"
	{{( sm->p) = ((( sm->te)))-1;}{
    append_c(sm, (*( sm->p)));
  }}
	goto st288;
tr242:
#line 595 "ext/dtext/dtext.rl"
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
	goto st288;
tr393:
#line 628 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    append_c(sm, (*( sm->p)));
  }}
	goto st288;
tr394:
#line 623 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    ( sm->p)--;
    { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)];goto _again;}
  }}
	goto st288;
tr395:
#line 611 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    append(sm, "&amp;");
  }}
	goto st288;
tr396:
#line 615 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    append(sm, "&lt;");
  }}
	goto st288;
tr397:
#line 619 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    append(sm, "&gt;");
  }}
	goto st288;
tr399:
#line 628 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append_c(sm, (*( sm->p)));
  }}
	goto st288;
st288:
#line 1 "NONE"
	{( sm->ts) = 0;}
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof288;
case 288:
#line 1 "NONE"
	{( sm->ts) = ( sm->p);}
#line 4170 "ext/dtext/dtext.c"
	switch( (*( sm->p)) ) {
		case 0: goto tr394;
		case 38: goto tr395;
		case 60: goto tr396;
		case 62: goto tr397;
		case 91: goto tr398;
	}
	goto tr393;
tr398:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
	goto st289;
st289:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof289;
case 289:
#line 4187 "ext/dtext/dtext.c"
	if ( (*( sm->p)) == 47 )
		goto st201;
	goto tr399;
st201:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof201;
case 201:
	if ( (*( sm->p)) == 110 )
		goto st202;
	goto tr234;
st202:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof202;
case 202:
	if ( (*( sm->p)) == 111 )
		goto st203;
	goto tr234;
st203:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof203;
case 203:
	if ( (*( sm->p)) == 100 )
		goto st204;
	goto tr234;
st204:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof204;
case 204:
	if ( (*( sm->p)) == 116 )
		goto st205;
	goto tr234;
st205:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof205;
case 205:
	if ( (*( sm->p)) == 101 )
		goto st206;
	goto tr234;
st206:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof206;
case 206:
	if ( (*( sm->p)) == 120 )
		goto st207;
	goto tr234;
st207:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof207;
case 207:
	if ( (*( sm->p)) == 116 )
		goto st208;
	goto tr234;
st208:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof208;
case 208:
	if ( (*( sm->p)) == 93 )
		goto tr242;
	goto tr234;
tr243:
#line 714 "ext/dtext/dtext.rl"
	{{( sm->p) = ((( sm->te)))-1;}}
	goto st290;
tr252:
#line 696 "ext/dtext/dtext.rl"
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
	goto st290;
tr256:
#line 659 "ext/dtext/dtext.rl"
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
	goto st290;
tr260:
#line 641 "ext/dtext/dtext.rl"
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
	goto st290;
tr261:
#line 677 "ext/dtext/dtext.rl"
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
	goto st290;
tr269:
#line 652 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_push(sm, &BLOCK_TBODY);
    append_newline(sm);
    append_block(sm, "<tbody>");
    append_newline(sm);
  }}
	goto st290;
tr270:
#line 688 "ext/dtext/dtext.rl"
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
{( ((int *)sm->stack->data))[( sm->top)++] = 290; goto st252;}}
  }}
	goto st290;
tr274:
#line 634 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_push(sm, &BLOCK_THEAD);
    append_newline(sm);
    append_block(sm, "<thead>");
    append_newline(sm);
  }}
	goto st290;
tr275:
#line 670 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_push(sm, &BLOCK_TR);
    append_newline(sm);
    append_block(sm, "<tr>");
    append_newline(sm);
  }}
	goto st290;
tr401:
#line 714 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;}
	goto st290;
tr402:
#line 709 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    ( sm->p)--;
    { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)];goto _again;}
  }}
	goto st290;
tr404:
#line 714 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;}
	goto st290;
st290:
#line 1 "NONE"
	{( sm->ts) = 0;}
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof290;
case 290:
#line 1 "NONE"
	{( sm->ts) = ( sm->p);}
#line 4376 "ext/dtext/dtext.c"
	switch( (*( sm->p)) ) {
		case 0: goto tr402;
		case 91: goto tr403;
	}
	goto tr401;
tr403:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
	goto st291;
st291:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof291;
case 291:
#line 4390 "ext/dtext/dtext.c"
	switch( (*( sm->p)) ) {
		case 47: goto st209;
		case 116: goto st224;
	}
	goto tr404;
st209:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof209;
case 209:
	if ( (*( sm->p)) == 116 )
		goto st210;
	goto tr243;
st210:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof210;
case 210:
	switch( (*( sm->p)) ) {
		case 97: goto st211;
		case 98: goto st215;
		case 104: goto st219;
		case 114: goto st223;
	}
	goto tr243;
st211:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof211;
case 211:
	if ( (*( sm->p)) == 98 )
		goto st212;
	goto tr243;
st212:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof212;
case 212:
	if ( (*( sm->p)) == 108 )
		goto st213;
	goto tr243;
st213:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof213;
case 213:
	if ( (*( sm->p)) == 101 )
		goto st214;
	goto tr243;
st214:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof214;
case 214:
	if ( (*( sm->p)) == 93 )
		goto tr252;
	goto tr243;
st215:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof215;
case 215:
	if ( (*( sm->p)) == 111 )
		goto st216;
	goto tr243;
st216:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof216;
case 216:
	if ( (*( sm->p)) == 100 )
		goto st217;
	goto tr243;
st217:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof217;
case 217:
	if ( (*( sm->p)) == 121 )
		goto st218;
	goto tr243;
st218:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof218;
case 218:
	if ( (*( sm->p)) == 93 )
		goto tr256;
	goto tr243;
st219:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof219;
case 219:
	if ( (*( sm->p)) == 101 )
		goto st220;
	goto tr243;
st220:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof220;
case 220:
	if ( (*( sm->p)) == 97 )
		goto st221;
	goto tr243;
st221:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof221;
case 221:
	if ( (*( sm->p)) == 100 )
		goto st222;
	goto tr243;
st222:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof222;
case 222:
	if ( (*( sm->p)) == 93 )
		goto tr260;
	goto tr243;
st223:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof223;
case 223:
	if ( (*( sm->p)) == 93 )
		goto tr261;
	goto tr243;
st224:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof224;
case 224:
	switch( (*( sm->p)) ) {
		case 98: goto st225;
		case 100: goto st229;
		case 104: goto st230;
		case 114: goto st234;
	}
	goto tr243;
st225:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof225;
case 225:
	if ( (*( sm->p)) == 111 )
		goto st226;
	goto tr243;
st226:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof226;
case 226:
	if ( (*( sm->p)) == 100 )
		goto st227;
	goto tr243;
st227:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof227;
case 227:
	if ( (*( sm->p)) == 121 )
		goto st228;
	goto tr243;
st228:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof228;
case 228:
	if ( (*( sm->p)) == 93 )
		goto tr269;
	goto tr243;
st229:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof229;
case 229:
	if ( (*( sm->p)) == 93 )
		goto tr270;
	goto tr243;
st230:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof230;
case 230:
	if ( (*( sm->p)) == 101 )
		goto st231;
	goto tr243;
st231:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof231;
case 231:
	if ( (*( sm->p)) == 97 )
		goto st232;
	goto tr243;
st232:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof232;
case 232:
	if ( (*( sm->p)) == 100 )
		goto st233;
	goto tr243;
st233:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof233;
case 233:
	if ( (*( sm->p)) == 93 )
		goto tr274;
	goto tr243;
st234:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof234;
case 234:
	if ( (*( sm->p)) == 93 )
		goto tr275;
	goto tr243;
tr276:
#line 755 "ext/dtext/dtext.rl"
	{{( sm->p) = ((( sm->te)))-1;}{
    dstack_close(sm);
    ( sm->p)--;
    { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)];goto _again;}
  }}
	goto st292;
tr407:
#line 755 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_close(sm);
    ( sm->p)--;
    { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)];goto _again;}
  }}
	goto st292;
tr408:
#line 747 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_close(sm);
    {( sm->p) = (( sm->ts))-1;}
    { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)];goto _again;}
  }}
	goto st292;
tr412:
#line 1 "NONE"
	{	switch( ( sm->act) ) {
	case 66:
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
	goto st292;
tr414:
#line 753 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;}
	goto st292;
tr415:
#line 755 "ext/dtext/dtext.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    dstack_close(sm);
    ( sm->p)--;
    { sm->cs = ( ((int *)sm->stack->data))[--( sm->top)];goto _again;}
  }}
	goto st292;
tr416:
#line 96 "ext/dtext/dtext.rl"
	{
  sm->b2 = sm->p;
}
#line 718 "ext/dtext/dtext.rl"
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
{( ((int *)sm->stack->data))[( sm->top)++] = 292; goto st252;}}
  }}
	goto st292;
st292:
#line 1 "NONE"
	{( sm->ts) = 0;}
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof292;
case 292:
#line 1 "NONE"
	{( sm->ts) = ( sm->p);}
#line 4691 "ext/dtext/dtext.c"
	switch( (*( sm->p)) ) {
		case 0: goto tr408;
		case 10: goto tr409;
		case 13: goto st294;
		case 42: goto tr411;
	}
	goto tr407;
tr409:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 753 "ext/dtext/dtext.rl"
	{( sm->act) = 67;}
	goto st293;
tr413:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 747 "ext/dtext/dtext.rl"
	{( sm->act) = 66;}
	goto st293;
st293:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof293;
case 293:
#line 4715 "ext/dtext/dtext.c"
	switch( (*( sm->p)) ) {
		case 10: goto tr413;
		case 13: goto tr413;
	}
	goto tr412;
st294:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof294;
case 294:
	switch( (*( sm->p)) ) {
		case 10: goto tr413;
		case 13: goto tr413;
	}
	goto tr414;
tr411:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 84 "ext/dtext/dtext.rl"
	{
  sm->a1 = sm->p;
}
	goto st295;
st295:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof295;
case 295:
#line 4742 "ext/dtext/dtext.c"
	switch( (*( sm->p)) ) {
		case 9: goto tr279;
		case 32: goto tr279;
		case 42: goto st236;
	}
	goto tr415;
tr279:
#line 88 "ext/dtext/dtext.rl"
	{
  sm->a2 = sm->p;
}
	goto st235;
st235:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof235;
case 235:
#line 4759 "ext/dtext/dtext.c"
	switch( (*( sm->p)) ) {
		case 0: goto tr276;
		case 9: goto tr278;
		case 10: goto tr276;
		case 13: goto tr276;
		case 32: goto tr278;
	}
	goto tr277;
tr277:
#line 92 "ext/dtext/dtext.rl"
	{
  sm->b1 = sm->p;
}
	goto st296;
st296:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof296;
case 296:
#line 4778 "ext/dtext/dtext.c"
	switch( (*( sm->p)) ) {
		case 0: goto tr416;
		case 10: goto tr416;
		case 13: goto tr416;
	}
	goto st296;
tr278:
#line 92 "ext/dtext/dtext.rl"
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
		case 0: goto tr416;
		case 9: goto tr278;
		case 10: goto tr416;
		case 13: goto tr416;
		case 32: goto tr278;
	}
	goto tr277;
st236:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof236;
case 236:
	switch( (*( sm->p)) ) {
		case 9: goto tr279;
		case 32: goto tr279;
		case 42: goto st236;
	}
	goto tr276;
	}
	_test_eof237:  sm->cs = 237; goto _test_eof; 
	_test_eof238:  sm->cs = 238; goto _test_eof; 
	_test_eof239:  sm->cs = 239; goto _test_eof; 
	_test_eof0:  sm->cs = 0; goto _test_eof; 
	_test_eof240:  sm->cs = 240; goto _test_eof; 
	_test_eof241:  sm->cs = 241; goto _test_eof; 
	_test_eof1:  sm->cs = 1; goto _test_eof; 
	_test_eof242:  sm->cs = 242; goto _test_eof; 
	_test_eof2:  sm->cs = 2; goto _test_eof; 
	_test_eof3:  sm->cs = 3; goto _test_eof; 
	_test_eof4:  sm->cs = 4; goto _test_eof; 
	_test_eof5:  sm->cs = 5; goto _test_eof; 
	_test_eof243:  sm->cs = 243; goto _test_eof; 
	_test_eof6:  sm->cs = 6; goto _test_eof; 
	_test_eof7:  sm->cs = 7; goto _test_eof; 
	_test_eof8:  sm->cs = 8; goto _test_eof; 
	_test_eof9:  sm->cs = 9; goto _test_eof; 
	_test_eof10:  sm->cs = 10; goto _test_eof; 
	_test_eof11:  sm->cs = 11; goto _test_eof; 
	_test_eof12:  sm->cs = 12; goto _test_eof; 
	_test_eof13:  sm->cs = 13; goto _test_eof; 
	_test_eof244:  sm->cs = 244; goto _test_eof; 
	_test_eof245:  sm->cs = 245; goto _test_eof; 
	_test_eof14:  sm->cs = 14; goto _test_eof; 
	_test_eof15:  sm->cs = 15; goto _test_eof; 
	_test_eof16:  sm->cs = 16; goto _test_eof; 
	_test_eof17:  sm->cs = 17; goto _test_eof; 
	_test_eof18:  sm->cs = 18; goto _test_eof; 
	_test_eof19:  sm->cs = 19; goto _test_eof; 
	_test_eof20:  sm->cs = 20; goto _test_eof; 
	_test_eof246:  sm->cs = 246; goto _test_eof; 
	_test_eof21:  sm->cs = 21; goto _test_eof; 
	_test_eof22:  sm->cs = 22; goto _test_eof; 
	_test_eof23:  sm->cs = 23; goto _test_eof; 
	_test_eof24:  sm->cs = 24; goto _test_eof; 
	_test_eof25:  sm->cs = 25; goto _test_eof; 
	_test_eof247:  sm->cs = 247; goto _test_eof; 
	_test_eof26:  sm->cs = 26; goto _test_eof; 
	_test_eof27:  sm->cs = 27; goto _test_eof; 
	_test_eof28:  sm->cs = 28; goto _test_eof; 
	_test_eof29:  sm->cs = 29; goto _test_eof; 
	_test_eof30:  sm->cs = 30; goto _test_eof; 
	_test_eof31:  sm->cs = 31; goto _test_eof; 
	_test_eof32:  sm->cs = 32; goto _test_eof; 
	_test_eof248:  sm->cs = 248; goto _test_eof; 
	_test_eof33:  sm->cs = 33; goto _test_eof; 
	_test_eof34:  sm->cs = 34; goto _test_eof; 
	_test_eof35:  sm->cs = 35; goto _test_eof; 
	_test_eof36:  sm->cs = 36; goto _test_eof; 
	_test_eof37:  sm->cs = 37; goto _test_eof; 
	_test_eof38:  sm->cs = 38; goto _test_eof; 
	_test_eof249:  sm->cs = 249; goto _test_eof; 
	_test_eof39:  sm->cs = 39; goto _test_eof; 
	_test_eof40:  sm->cs = 40; goto _test_eof; 
	_test_eof250:  sm->cs = 250; goto _test_eof; 
	_test_eof251:  sm->cs = 251; goto _test_eof; 
	_test_eof252:  sm->cs = 252; goto _test_eof; 
	_test_eof253:  sm->cs = 253; goto _test_eof; 
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
	_test_eof254:  sm->cs = 254; goto _test_eof; 
	_test_eof68:  sm->cs = 68; goto _test_eof; 
	_test_eof69:  sm->cs = 69; goto _test_eof; 
	_test_eof70:  sm->cs = 70; goto _test_eof; 
	_test_eof71:  sm->cs = 71; goto _test_eof; 
	_test_eof72:  sm->cs = 72; goto _test_eof; 
	_test_eof255:  sm->cs = 255; goto _test_eof; 
	_test_eof256:  sm->cs = 256; goto _test_eof; 
	_test_eof257:  sm->cs = 257; goto _test_eof; 
	_test_eof73:  sm->cs = 73; goto _test_eof; 
	_test_eof74:  sm->cs = 74; goto _test_eof; 
	_test_eof75:  sm->cs = 75; goto _test_eof; 
	_test_eof76:  sm->cs = 76; goto _test_eof; 
	_test_eof258:  sm->cs = 258; goto _test_eof; 
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
	_test_eof259:  sm->cs = 259; goto _test_eof; 
	_test_eof260:  sm->cs = 260; goto _test_eof; 
	_test_eof261:  sm->cs = 261; goto _test_eof; 
	_test_eof262:  sm->cs = 262; goto _test_eof; 
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
	_test_eof263:  sm->cs = 263; goto _test_eof; 
	_test_eof127:  sm->cs = 127; goto _test_eof; 
	_test_eof128:  sm->cs = 128; goto _test_eof; 
	_test_eof129:  sm->cs = 129; goto _test_eof; 
	_test_eof130:  sm->cs = 130; goto _test_eof; 
	_test_eof131:  sm->cs = 131; goto _test_eof; 
	_test_eof132:  sm->cs = 132; goto _test_eof; 
	_test_eof133:  sm->cs = 133; goto _test_eof; 
	_test_eof264:  sm->cs = 264; goto _test_eof; 
	_test_eof265:  sm->cs = 265; goto _test_eof; 
	_test_eof134:  sm->cs = 134; goto _test_eof; 
	_test_eof135:  sm->cs = 135; goto _test_eof; 
	_test_eof136:  sm->cs = 136; goto _test_eof; 
	_test_eof137:  sm->cs = 137; goto _test_eof; 
	_test_eof138:  sm->cs = 138; goto _test_eof; 
	_test_eof139:  sm->cs = 139; goto _test_eof; 
	_test_eof140:  sm->cs = 140; goto _test_eof; 
	_test_eof141:  sm->cs = 141; goto _test_eof; 
	_test_eof266:  sm->cs = 266; goto _test_eof; 
	_test_eof267:  sm->cs = 267; goto _test_eof; 
	_test_eof142:  sm->cs = 142; goto _test_eof; 
	_test_eof143:  sm->cs = 143; goto _test_eof; 
	_test_eof144:  sm->cs = 144; goto _test_eof; 
	_test_eof145:  sm->cs = 145; goto _test_eof; 
	_test_eof146:  sm->cs = 146; goto _test_eof; 
	_test_eof147:  sm->cs = 147; goto _test_eof; 
	_test_eof268:  sm->cs = 268; goto _test_eof; 
	_test_eof269:  sm->cs = 269; goto _test_eof; 
	_test_eof148:  sm->cs = 148; goto _test_eof; 
	_test_eof149:  sm->cs = 149; goto _test_eof; 
	_test_eof270:  sm->cs = 270; goto _test_eof; 
	_test_eof271:  sm->cs = 271; goto _test_eof; 
	_test_eof150:  sm->cs = 150; goto _test_eof; 
	_test_eof151:  sm->cs = 151; goto _test_eof; 
	_test_eof152:  sm->cs = 152; goto _test_eof; 
	_test_eof153:  sm->cs = 153; goto _test_eof; 
	_test_eof154:  sm->cs = 154; goto _test_eof; 
	_test_eof155:  sm->cs = 155; goto _test_eof; 
	_test_eof272:  sm->cs = 272; goto _test_eof; 
	_test_eof156:  sm->cs = 156; goto _test_eof; 
	_test_eof273:  sm->cs = 273; goto _test_eof; 
	_test_eof157:  sm->cs = 157; goto _test_eof; 
	_test_eof158:  sm->cs = 158; goto _test_eof; 
	_test_eof159:  sm->cs = 159; goto _test_eof; 
	_test_eof160:  sm->cs = 160; goto _test_eof; 
	_test_eof161:  sm->cs = 161; goto _test_eof; 
	_test_eof162:  sm->cs = 162; goto _test_eof; 
	_test_eof274:  sm->cs = 274; goto _test_eof; 
	_test_eof275:  sm->cs = 275; goto _test_eof; 
	_test_eof163:  sm->cs = 163; goto _test_eof; 
	_test_eof164:  sm->cs = 164; goto _test_eof; 
	_test_eof165:  sm->cs = 165; goto _test_eof; 
	_test_eof166:  sm->cs = 166; goto _test_eof; 
	_test_eof167:  sm->cs = 167; goto _test_eof; 
	_test_eof168:  sm->cs = 168; goto _test_eof; 
	_test_eof276:  sm->cs = 276; goto _test_eof; 
	_test_eof169:  sm->cs = 169; goto _test_eof; 
	_test_eof170:  sm->cs = 170; goto _test_eof; 
	_test_eof277:  sm->cs = 277; goto _test_eof; 
	_test_eof171:  sm->cs = 171; goto _test_eof; 
	_test_eof172:  sm->cs = 172; goto _test_eof; 
	_test_eof173:  sm->cs = 173; goto _test_eof; 
	_test_eof174:  sm->cs = 174; goto _test_eof; 
	_test_eof175:  sm->cs = 175; goto _test_eof; 
	_test_eof278:  sm->cs = 278; goto _test_eof; 
	_test_eof176:  sm->cs = 176; goto _test_eof; 
	_test_eof177:  sm->cs = 177; goto _test_eof; 
	_test_eof178:  sm->cs = 178; goto _test_eof; 
	_test_eof179:  sm->cs = 179; goto _test_eof; 
	_test_eof279:  sm->cs = 279; goto _test_eof; 
	_test_eof280:  sm->cs = 280; goto _test_eof; 
	_test_eof180:  sm->cs = 180; goto _test_eof; 
	_test_eof181:  sm->cs = 181; goto _test_eof; 
	_test_eof182:  sm->cs = 182; goto _test_eof; 
	_test_eof183:  sm->cs = 183; goto _test_eof; 
	_test_eof184:  sm->cs = 184; goto _test_eof; 
	_test_eof185:  sm->cs = 185; goto _test_eof; 
	_test_eof281:  sm->cs = 281; goto _test_eof; 
	_test_eof186:  sm->cs = 186; goto _test_eof; 
	_test_eof187:  sm->cs = 187; goto _test_eof; 
	_test_eof282:  sm->cs = 282; goto _test_eof; 
	_test_eof283:  sm->cs = 283; goto _test_eof; 
	_test_eof188:  sm->cs = 188; goto _test_eof; 
	_test_eof189:  sm->cs = 189; goto _test_eof; 
	_test_eof190:  sm->cs = 190; goto _test_eof; 
	_test_eof191:  sm->cs = 191; goto _test_eof; 
	_test_eof192:  sm->cs = 192; goto _test_eof; 
	_test_eof284:  sm->cs = 284; goto _test_eof; 
	_test_eof285:  sm->cs = 285; goto _test_eof; 
	_test_eof193:  sm->cs = 193; goto _test_eof; 
	_test_eof194:  sm->cs = 194; goto _test_eof; 
	_test_eof195:  sm->cs = 195; goto _test_eof; 
	_test_eof286:  sm->cs = 286; goto _test_eof; 
	_test_eof287:  sm->cs = 287; goto _test_eof; 
	_test_eof196:  sm->cs = 196; goto _test_eof; 
	_test_eof197:  sm->cs = 197; goto _test_eof; 
	_test_eof198:  sm->cs = 198; goto _test_eof; 
	_test_eof199:  sm->cs = 199; goto _test_eof; 
	_test_eof200:  sm->cs = 200; goto _test_eof; 
	_test_eof288:  sm->cs = 288; goto _test_eof; 
	_test_eof289:  sm->cs = 289; goto _test_eof; 
	_test_eof201:  sm->cs = 201; goto _test_eof; 
	_test_eof202:  sm->cs = 202; goto _test_eof; 
	_test_eof203:  sm->cs = 203; goto _test_eof; 
	_test_eof204:  sm->cs = 204; goto _test_eof; 
	_test_eof205:  sm->cs = 205; goto _test_eof; 
	_test_eof206:  sm->cs = 206; goto _test_eof; 
	_test_eof207:  sm->cs = 207; goto _test_eof; 
	_test_eof208:  sm->cs = 208; goto _test_eof; 
	_test_eof290:  sm->cs = 290; goto _test_eof; 
	_test_eof291:  sm->cs = 291; goto _test_eof; 
	_test_eof209:  sm->cs = 209; goto _test_eof; 
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
	_test_eof292:  sm->cs = 292; goto _test_eof; 
	_test_eof293:  sm->cs = 293; goto _test_eof; 
	_test_eof294:  sm->cs = 294; goto _test_eof; 
	_test_eof295:  sm->cs = 295; goto _test_eof; 
	_test_eof235:  sm->cs = 235; goto _test_eof; 
	_test_eof296:  sm->cs = 296; goto _test_eof; 
	_test_eof297:  sm->cs = 297; goto _test_eof; 
	_test_eof236:  sm->cs = 236; goto _test_eof; 

	_test_eof: {}
	if ( ( sm->p) == ( sm->eof) )
	{
	switch (  sm->cs ) {
	case 238: goto tr291;
	case 239: goto tr292;
	case 0: goto tr0;
	case 240: goto tr293;
	case 241: goto tr293;
	case 1: goto tr0;
	case 242: goto tr292;
	case 2: goto tr0;
	case 3: goto tr0;
	case 4: goto tr0;
	case 5: goto tr0;
	case 243: goto tr301;
	case 6: goto tr0;
	case 7: goto tr0;
	case 8: goto tr0;
	case 9: goto tr0;
	case 10: goto tr0;
	case 11: goto tr0;
	case 12: goto tr0;
	case 13: goto tr0;
	case 244: goto tr302;
	case 245: goto tr304;
	case 14: goto tr0;
	case 15: goto tr0;
	case 16: goto tr0;
	case 17: goto tr0;
	case 18: goto tr0;
	case 19: goto tr0;
	case 20: goto tr0;
	case 246: goto tr305;
	case 21: goto tr0;
	case 22: goto tr0;
	case 23: goto tr0;
	case 24: goto tr0;
	case 25: goto tr0;
	case 247: goto tr306;
	case 26: goto tr0;
	case 27: goto tr0;
	case 28: goto tr0;
	case 29: goto tr0;
	case 30: goto tr0;
	case 31: goto tr0;
	case 32: goto tr0;
	case 248: goto tr307;
	case 33: goto tr0;
	case 34: goto tr0;
	case 35: goto tr0;
	case 36: goto tr0;
	case 37: goto tr0;
	case 38: goto tr0;
	case 249: goto tr292;
	case 39: goto tr0;
	case 40: goto tr0;
	case 250: goto tr309;
	case 251: goto tr309;
	case 253: goto tr331;
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
	case 254: goto tr332;
	case 68: goto tr48;
	case 69: goto tr48;
	case 70: goto tr48;
	case 71: goto tr48;
	case 72: goto tr48;
	case 255: goto tr48;
	case 256: goto tr334;
	case 257: goto tr331;
	case 73: goto tr86;
	case 74: goto tr86;
	case 75: goto tr86;
	case 76: goto tr86;
	case 258: goto tr336;
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
	case 259: goto tr331;
	case 260: goto tr338;
	case 261: goto tr341;
	case 262: goto tr331;
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
	case 263: goto tr331;
	case 127: goto tr86;
	case 128: goto tr86;
	case 129: goto tr86;
	case 130: goto tr86;
	case 131: goto tr86;
	case 132: goto tr86;
	case 133: goto tr86;
	case 264: goto tr351;
	case 265: goto tr331;
	case 134: goto tr86;
	case 135: goto tr86;
	case 136: goto tr86;
	case 137: goto tr86;
	case 138: goto tr86;
	case 139: goto tr86;
	case 140: goto tr86;
	case 141: goto tr86;
	case 266: goto tr354;
	case 267: goto tr331;
	case 142: goto tr86;
	case 143: goto tr86;
	case 144: goto tr86;
	case 145: goto tr86;
	case 146: goto tr86;
	case 147: goto tr86;
	case 268: goto tr357;
	case 269: goto tr331;
	case 148: goto tr86;
	case 149: goto tr86;
	case 270: goto tr361;
	case 271: goto tr361;
	case 150: goto tr86;
	case 151: goto tr86;
	case 152: goto tr86;
	case 153: goto tr86;
	case 154: goto tr86;
	case 155: goto tr86;
	case 272: goto tr363;
	case 156: goto tr86;
	case 273: goto tr331;
	case 157: goto tr86;
	case 158: goto tr86;
	case 159: goto tr86;
	case 160: goto tr86;
	case 161: goto tr86;
	case 162: goto tr86;
	case 274: goto tr365;
	case 275: goto tr331;
	case 163: goto tr86;
	case 164: goto tr86;
	case 165: goto tr86;
	case 166: goto tr86;
	case 167: goto tr86;
	case 168: goto tr86;
	case 276: goto tr369;
	case 169: goto tr197;
	case 170: goto tr197;
	case 277: goto tr372;
	case 171: goto tr86;
	case 172: goto tr86;
	case 173: goto tr86;
	case 174: goto tr86;
	case 175: goto tr86;
	case 278: goto tr374;
	case 176: goto tr86;
	case 177: goto tr86;
	case 178: goto tr86;
	case 179: goto tr86;
	case 279: goto tr376;
	case 280: goto tr331;
	case 180: goto tr86;
	case 181: goto tr86;
	case 182: goto tr86;
	case 183: goto tr86;
	case 184: goto tr86;
	case 185: goto tr86;
	case 281: goto tr379;
	case 186: goto tr216;
	case 187: goto tr216;
	case 282: goto tr382;
	case 283: goto tr331;
	case 188: goto tr86;
	case 189: goto tr86;
	case 190: goto tr86;
	case 191: goto tr86;
	case 192: goto tr86;
	case 284: goto tr385;
	case 285: goto tr331;
	case 193: goto tr86;
	case 194: goto tr86;
	case 195: goto tr86;
	case 287: goto tr391;
	case 196: goto tr228;
	case 197: goto tr228;
	case 198: goto tr228;
	case 199: goto tr228;
	case 200: goto tr228;
	case 289: goto tr399;
	case 201: goto tr234;
	case 202: goto tr234;
	case 203: goto tr234;
	case 204: goto tr234;
	case 205: goto tr234;
	case 206: goto tr234;
	case 207: goto tr234;
	case 208: goto tr234;
	case 291: goto tr404;
	case 209: goto tr243;
	case 210: goto tr243;
	case 211: goto tr243;
	case 212: goto tr243;
	case 213: goto tr243;
	case 214: goto tr243;
	case 215: goto tr243;
	case 216: goto tr243;
	case 217: goto tr243;
	case 218: goto tr243;
	case 219: goto tr243;
	case 220: goto tr243;
	case 221: goto tr243;
	case 222: goto tr243;
	case 223: goto tr243;
	case 224: goto tr243;
	case 225: goto tr243;
	case 226: goto tr243;
	case 227: goto tr243;
	case 228: goto tr243;
	case 229: goto tr243;
	case 230: goto tr243;
	case 231: goto tr243;
	case 232: goto tr243;
	case 233: goto tr243;
	case 234: goto tr243;
	case 293: goto tr412;
	case 294: goto tr414;
	case 295: goto tr415;
	case 235: goto tr276;
	case 296: goto tr416;
	case 297: goto tr416;
	case 236: goto tr276;
	}
	}

	}

#line 1119 "ext/dtext/dtext.rl"

  dstack_close(sm);

  VALUE ret = rb_str_new(sm->output->str, sm->output->len);
  free_machine(sm);

  return ret;
}

void Init_dtext() {
  VALUE mDTextRagel = rb_define_module("DTextRagel");
  rb_define_singleton_method(mDTextRagel, "parse", parse, 1);
}
