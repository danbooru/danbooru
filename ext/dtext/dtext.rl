#include <ruby.h>
#include <stdio.h>
#include <stdint.h>
#include <stdbool.h>
#include <glib.h>

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
  bool boundary;
  GString * output;
  GArray * stack;
  GQueue * dstack;
} StateMachine;

static const int MAX_STACK_DEPTH = 256;
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

%%{
machine dtext;

access sm->;
variable p sm->p;
variable pe sm->pe;
variable eof sm->eof;
variable top sm->top;
variable ts sm->ts;
variable te sm->te;
variable act sm->act;
variable stack sm->stack->data;

prepush {
  size_t len = sm->stack->len;

  if (len > MAX_STACK_DEPTH) {
    free_machine(sm);
    rb_raise(rb_eSyntaxError, "too many nested elements");
  }

  if (sm->top >= len) {
    sm->stack = g_array_set_size(sm->stack, len + 16);
  }
}

action mark_a1 {
  sm->a1 = sm->p;
}

action mark_a2 {
  sm->a2 = sm->p;
}

action mark_b1 {
  sm->b1 = sm->p;
}

action mark_b2 {
  sm->b2 = sm->p;
}

name_boundary = ':' | '?';
newline = '\r\n' | '\r' | '\n';

nonquote = ^'"';
nonbracket = ^']';
nonpipe = ^'|';
nonpipebracket = nonpipe & nonbracket;
noncurly = ^'}';

mention = '@' >{sm->boundary = false;} (graph+) >mark_a1 %mark_a2 :>> name_boundary? @{sm->boundary = true;};

url = 'http' 's'? '://' graph+;
basic_textile_link = '"' nonquote+ >mark_a1 '"' >mark_a2 ':' url >mark_b1 %mark_b2;
bracketed_textile_link = '"' nonquote+ >mark_a1 '"' >mark_a2 ':[' url >mark_b1 %mark_b2 :>> ']';

basic_wiki_link = '[[' nonpipebracket+ >mark_a1 %mark_a2 ']]';
aliased_wiki_link = '[[' nonpipebracket+ >mark_a1 %mark_a2 '|' nonbracket+ >mark_b1 %mark_b2 ']]';

post_link = '{{' noncurly+ >mark_a1 %mark_a2 '}}';

post_id = 'post #' digit+ >mark_a1 %mark_a2;
forum_post_id = 'forum #' digit+ >mark_a1 %mark_a2;
forum_topic_id = 'topic #' digit+ >mark_a1 %mark_a2;
forum_topic_paged_id = 'topic #' digit+ >mark_a1 %mark_a2 '/p' digit+ >mark_b1 %mark_b2;
comment_id = 'comment #' digit+ >mark_a1 %mark_a2;
pool_id = 'pool #' digit+ >mark_a1 %mark_a2;
user_id = 'user #' digit+ >mark_a1 %mark_a2;
artist_id = 'artist #' digit+ >mark_a1 %mark_a2;
github_issue_id = 'issue #' digit+ >mark_a1 %mark_a2;
pixiv_id = 'pixiv #' digit+ >mark_a1 %mark_a2;
pixiv_paged_id = 'pixiv #' digit+ >mark_a1 %mark_a2 '/p' digit+ >mark_b1 %mark_b2;

ws = ' ' | '\t';
header = 'h' [123456] >mark_a1 %mark_a2 '.' ws* print+ >mark_b1 %mark_b2;
aliased_expand = '[expand=' (nonbracket+ >mark_a1 %mark_a2) ']';

inline := |*
  post_id => {
    append(sm, "<a href=\"/posts/");
    append_segment(sm, sm->a1, sm->a2);
    append(sm, "\">post #");
    append_segment(sm, sm->a1, sm->a2);
    append(sm, "</a>");
  };

  forum_post_id => {
    append(sm, "<a href=\"/forum_posts/");
    append_segment(sm, sm->a1, sm->a2);
    append(sm, "\">forum #");
    append_segment(sm, sm->a1, sm->a2);
    append(sm, "</a>");
  };

  forum_topic_id => {
    append(sm, "<a href=\"/forum_topics/");
    append_segment(sm, sm->a1, sm->a2);
    append(sm, "\">topic #");
    append_segment(sm, sm->a1, sm->a2);
    append(sm, "</a>");
  };

  forum_topic_paged_id => {
    append(sm, "<a href=\"/forum_topics/");
    append_segment(sm, sm->a1, sm->a2);
    append(sm, "?page=");
    append_segment(sm, sm->b1, sm->b2);
    append(sm, "\">topic #");
    append_segment(sm, sm->a1, sm->a2);
    append(sm, "/p");
    append_segment(sm, sm->b1, sm->b2);
    append(sm, "</a>");
  };

  comment_id => {
    append(sm, "<a href=\"/comments/");
    append_segment(sm, sm->a1, sm->a2);
    append(sm, "\">comment #");
    append_segment(sm, sm->a1, sm->a2);
    append(sm, "</a>");
  };

  pool_id => {
    append(sm, "<a href=\"/pools/");
    append_segment(sm, sm->a1, sm->a2);
    append(sm, "\">pool #");
    append_segment(sm, sm->a1, sm->a2);
    append(sm, "</a>");
  };

  user_id => {
    append(sm, "<a href=\"/users/");
    append_segment(sm, sm->a1, sm->a2);
    append(sm, "\">user #");
    append_segment(sm, sm->a1, sm->a2);
    append(sm, "</a>");
  };

  artist_id => {
    append(sm, "<a href=\"/artists/");
    append_segment(sm, sm->a1, sm->a2);
    append(sm, "\">artist #");
    append_segment(sm, sm->a1, sm->a2);
    append(sm, "</a>");
  };

  github_issue_id => {
    append(sm, "<a href=\"https://github.com/r888888888/danbooru/issues/");
    append_segment(sm, sm->a1, sm->a2);
    append(sm, "\">issue #");
    append_segment(sm, sm->a1, sm->a2);
    append(sm, "</a>");
  };

  pixiv_id => {
    append(sm, "<a href=\"http://www.pixiv.net/member_illust.php?mode=medium&illust_id=");
    append_segment(sm, sm->a1, sm->a2);
    append(sm, "\">pixiv #");
    append_segment(sm, sm->a1, sm->a2);
    append(sm, "</a>");
  };

  pixiv_paged_id => {
    append(sm, "<a href=\"http://www.pixiv.net/member_illust.php?mode=manga_big&illust_id=");
    append_segment(sm, sm->a1, sm->a2);
    append(sm, "&page=");
    append_segment(sm, sm->b1, sm->b2);
    append(sm, "\">pixiv #");
    append_segment(sm, sm->a1, sm->a2);
    append(sm, "/p");
    append_segment(sm, sm->b1, sm->b2);
    append(sm, "</a>");
  };

  post_link => {
    append(sm, "<a rel=\"nofollow\" href=\"/posts?tags=");
    append_segment_uri_escaped(sm, sm->a1, sm->a2);
    append(sm, "\">");
    append_segment_html_escaped(sm, sm->a1, sm->a2);
    append(sm, "</a>");
  };

  basic_wiki_link => {
    GString * segment = g_string_new_len(sm->a1, sm->a2 - sm->a1 + 1);
    underscore_string(segment->str, segment->len);

    append(sm, "<a href=\"/wiki_pages/show_or_new?title=");
    append_segment_uri_escaped(sm, segment->str, segment->str + segment->len - 1);
    append(sm, "\">");
    append_segment_html_escaped(sm, sm->a1, sm->a2);
    append(sm, "</a>");

    g_string_free(segment, TRUE);
  };

  aliased_wiki_link => {
    GString * segment = g_string_new_len(sm->a1, sm->a2 - sm->a1 + 1);
    underscore_string(segment->str, segment->len);

    append(sm, "<a href=\"/wiki_pages/show_or_new?title=");
    append_segment_uri_escaped(sm, segment->str, segment->str + segment->len - 1);
    append(sm, "\">");
    append_segment_html_escaped(sm, sm->b1, sm->b2);
    append(sm, "</a>");

    g_string_free(segment, TRUE);
  };

  basic_textile_link => {
    append(sm, "<a rel=\"nofollow\" href=\"");
    append_segment_uri_escaped(sm, sm->b1, sm->b2);
    append(sm, "\">");
    append_segment_html_escaped(sm, sm->a1, sm->a2);
    append(sm, "</a>");
  };

  bracketed_textile_link => {
    append(sm, "<a rel=\"nofollow\" href=\"");
    append_segment_uri_escaped(sm, sm->b1, sm->b2);
    append(sm, "\">");
    append_segment_html_escaped(sm, sm->a1, sm->a2);
    append(sm, "</a>");
  };

  url => {
    append(sm, "<a rel=\"nofollow\" href=\"");
    append_segment_uri_escaped(sm, sm->ts, sm->te - 1);
    append(sm, "\">");
    append_segment_html_escaped(sm, sm->ts, sm->te - 1);
    append(sm, "</a>");
  };

  # probably a tag. examples include @.@ and @_@
  '@' graph '@' => {
    append_segment(sm, sm->ts, sm->te - 1);
  };

  mention => {
    append(sm, "<a rel=\"nofollow\" href=\"/users?name=");
    append_segment_uri_escaped(sm, sm->a1, sm->a2);
    append(sm, "\">@");
    append_segment_html_escaped(sm, sm->a2, sm->a2);
    append(sm, "</a>");
    if (sm->boundary) {
      append_c(sm, fc);
      sm->boundary = false;
    }
  };

  '[b]' => {
    dstack_push(sm, &INLINE_B);
    append(sm, "<strong>");
  };

  '[/b]' => {
    if (dstack_check(sm, INLINE_B)) {
      dstack_pop(sm);
      append(sm, "</strong>");
    } else {
      append(sm, "[/b]");
    }
  };

  '[i]' => {
    dstack_push(sm, &INLINE_I);
    append(sm, "<em>");
  };

  '[/i]' => {
    if (dstack_check(sm, INLINE_I)) {
      dstack_pop(sm);
      append(sm, "</em>");
    } else {
      append(sm, "[/i]");
    }
  };

  '[s]' => {
    dstack_push(sm, &INLINE_S);
    append(sm, "<s>");
  };

  '[/s]' => {
    if (dstack_check(sm, INLINE_S)) {
      dstack_pop(sm);
      append(sm, "</s>");
    } else {
      append(sm, "[/s]");
    }
  };

  '[u]' => {
    dstack_push(sm, &INLINE_U);
    append(sm, "<u>");
  };

  '[/u]' => {
    if (dstack_check(sm, INLINE_U)) {
      dstack_pop(sm);
      append(sm, "</u>");
    } else {
      append(sm, "[/u]");
    }
  };

  '[tn]' => {
    dstack_push(sm, &INLINE_TN);
    append(sm, "<span class=\"tn\">");
  };

  '[/tn]' => {
    if (dstack_check(sm, BLOCK_TN)) {
      dstack_pop(sm);
      append(sm, "</p>");
      fret;
    } else if (dstack_check(sm, INLINE_TN)) {
      dstack_pop(sm);
      append(sm, "</span>");
    } else {
      append(sm, "[/tn]");
    }
  };

  # these are block level elements that should kick us out of the inline
  # scanner
  '[quote]' => {
    dstack_close(sm);
    fexec sm->p - 7;
    fret;
  };

  '[/quote]' => {
    if (dstack_check(sm, BLOCK_P)) {
      dstack_pop(sm);
      append_block(sm, "</p>");
    } 

    if (dstack_check(sm, BLOCK_QUOTE)) {
      dstack_pop(sm);
      append_block(sm, "</blockquote>");
      fret;
    } else {
      append(sm, "[/quote]");
    }
  };

  '[spoiler]' => {
    dstack_push(sm, &INLINE_SPOILER);
    append(sm, "<span class=\"spoiler\">");
  };

  '[/spoiler]' => {
    if (dstack_check(sm, INLINE_SPOILER)) {
      dstack_pop(sm);
      append(sm, "</span>");
    } else if (dstack_check(sm, BLOCK_SPOILER)) {
      dstack_pop(sm);
      append_block(sm, "</p></div>");
      fret;
    } else {
      append(sm, "[/spoiler]");
    }
  };

  '[expand]' => {
    dstack_close(sm);
    fexec(sm->p - 8);
    fret;
  };

  '[/expand]' => {
    if (dstack_check(sm, BLOCK_EXPAND)) {
      append_block(sm, "</div></div>");
      dstack_pop(sm);
      fret;
    } else {
      append(sm, "[/expand]");
    }
  };

  '[nodtext]' => {
    dstack_push(sm, &INLINE_NODTEXT);
    fcall nodtext;
  };

  '[/td]' => {
    if (dstack_check(sm, BLOCK_TD)) {
      dstack_pop(sm);
      append_block(sm, "</td>");
      fret;
    } else {
      append(sm, "[/td]");
    }
  };

  '\0' => {
    fhold;
    fret;
  };

  newline{2,} => {
    dstack_close(sm);
    fret;
  };

  newline => {
    append_block(sm, "<br>");
  };

  any => {
    append_c(sm, fc);
  };
*|;

code := |*
  '[/code]' => {
    if (dstack_check(sm, BLOCK_CODE)) {
      dstack_pop(sm);
      append_block(sm, "</pre>");
    } else {
      append(sm, "[/code]");
    }
    fret;
  };

  '\0' => {
    fhold;
    fret;
  };

  any => {
    append_c(sm, fc);
  };
*|;

nodtext := |*
  '[/nodtext]' => {
    if (dstack_check(sm, BLOCK_NODTEXT)) {
      dstack_pop(sm);
      append_block(sm, "</p>");
      fret;
    } else if (dstack_check(sm, INLINE_NODTEXT)) {
      dstack_pop(sm);
      fret;
    } else {
      append(sm, "[/nodtext]");
    }
  };

  '&' => {
    append(sm, "&amp;");
  };

  '<' => {
    append(sm, "&lt;");
  };

  '>' => {
    append(sm, "&gt;");
  };

  '\0' => {
    fhold;
    fret;
  };

  any => {
    append_c(sm, fc);
  };
*|;

table := |*
  '[thead]' => {
    dstack_push(sm, &BLOCK_THEAD);
    append_block(sm, "<thead>");
  };

  '[/thead]' => {
    if (dstack_check(sm, BLOCK_THEAD)) {
      dstack_pop(sm);
      append_block(sm, "</thead>");
    } else {
      append(sm, "[/thead]");
    }
  };

  '[tbody]' => {
    dstack_push(sm, &BLOCK_TBODY);
    append_block(sm, "<tbody>");
  };

  '[/tbody]' => {
    if (dstack_check(sm, BLOCK_TBODY)) {
      dstack_pop(sm);
      append_block(sm, "</tbody>");
    } else {
      append(sm, "[/tbody]");
    }
  };

  '[tr]' => {
    dstack_push(sm, &BLOCK_TR);
    append_block(sm, "<tr>");
  };

  '[/tr]' => {
    if (dstack_check(sm, BLOCK_TR)) {
      dstack_pop(sm);
      append_block(sm, "</tr>");
    } else {
      append(sm, "[/tr]");
    }
  };

  '[td]' => {
    dstack_push(sm, &BLOCK_TD);
    append_block(sm, "<td>");
    fcall inline;
  };

  '[/table]' => {
    if (dstack_check(sm, BLOCK_TABLE)) {
      dstack_pop(sm);
      append_block(sm, "</table>");
      fret;
    } else {
      append(sm, "[/table]");
    }
  };

  '\0' => {
    fhold;
    fret;
  };

  any;
*|;

main := |*
  header => {
    char header = *sm->a1;

    if (sm->f_inline) {
      header = '6';
    }

    append(sm, "<h");
    append_c(sm, header);
    append_c(sm, '>');
    append_segment(sm, sm->b1, sm->b2);
    append(sm, "</h");
    append_c(sm, header);
    append_c(sm, '>');
  };

  '[quote]' => {
    dstack_push(sm, &BLOCK_QUOTE);
    append_block(sm, "<blockquote>");
    fcall inline;
  };

  '[spoiler]' => {
    dstack_push(sm, &BLOCK_SPOILER);
    append_block(sm, "<div class=\"spoiler\"><p>");
    fcall inline;
  };

  '[code]' => {
    dstack_push(sm, &BLOCK_CODE);
    append_block(sm, "<pre>");
    fcall code;
  };

  '[expand]' => {
    dstack_push(sm, &BLOCK_EXPAND);
    append_block(sm, "<div class=\"expandable\"><div class=\"expandable-header\">");
    append_block(sm, "<input type=\"button\" value=\"Show\" class=\"expandable-button\"/></div>");
    append_block(sm, "<div class=\"expandable-content\">");
    fcall inline;
  };

  aliased_expand => {
    dstack_push(sm, &BLOCK_EXPAND);
    append_block(sm, "<div class=\"expandable\"><div class=\"expandable-header\">");
    append(sm, "<span>");
    append_segment_html_escaped(sm, sm->a1, sm->a2);
    append(sm, "</span>");
    append_block(sm, "<input type=\"button\" value=\"Show\" class=\"expandable-button\"/></div>");
    append_block(sm, "<div class=\"expandable-content\">");
    fcall inline;
  };

  '[nodtext]' => {
    dstack_push(sm, &BLOCK_NODTEXT);
    append_block(sm, "<p>");
    fcall nodtext;
  };

  '[table]' => {
    dstack_push(sm, &BLOCK_TABLE);
    append_block(sm, "<table class=\"striped\">");
    fcall table;
  };

  '[tn]' => {
    dstack_push(sm, &BLOCK_TN);
    append_block(sm, "<p class=\"tn\">");
    fcall inline;
  };

  '&' => {
    append(sm, "&amp;");
  };

  '<' => {
    append(sm, "&lt;");
  };

  '>' => {
    append(sm, "&gt;");
  };

  '\0' => {
    dstack_close(sm);
  };

  newline;

  any => {
    fhold;

    if (g_queue_is_empty(sm->dstack)) {
      dstack_push(sm, &BLOCK_P);
      append_block(sm, "<p>");
    }

    fcall inline;
  };
*|;

}%%

%% write data;

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

static inline void append_c(StateMachine * sm, char s) {
  sm->output = g_string_append_c(sm->output, s);
}

static inline void append_segment(StateMachine * sm, const char * a, const char * b) {
  sm->output = g_string_append_len(sm->output, a, b - a + 1);
}

static inline void append_segment_uri_escaped(StateMachine * sm, const char * a, const char * b) {
  GString * segment = g_string_new_len(a, b - a + 1);
  sm->output = g_string_append_uri_escaped(sm->output, segment->str, ":/?&=", TRUE);
  g_string_free(segment, TRUE);
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
  if (top && *top == expected_element) {
    return true;
  } else {
    return false;
  }
}

static void dstack_close(StateMachine * sm) {
  while (dstack_peek(sm) != NULL) {
    int * top = dstack_pop(sm);

    switch (*top) {
      case BLOCK_P:
        append_block(sm, "</p>");
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
    }
  }
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
  sm->boundary = false;
  sm->stack = g_array_sized_new(FALSE, TRUE, sizeof(int), 128);
  sm->dstack = g_queue_new();
}

static void free_machine(StateMachine * sm) {
  g_string_free(sm->output, TRUE);
  g_array_free(sm->stack, FALSE);
  g_queue_free(sm->dstack);
  free(sm);
}

static VALUE parse(VALUE self, VALUE input) {
  StateMachine * sm = (StateMachine *)malloc(sizeof(StateMachine));
  init_machine(sm, input);

  %% write init;
  %% write exec;

  dstack_close(sm);

  VALUE ret = rb_str_new(sm->output->str, sm->output->len);
  free_machine(sm);

  return ret;
}

void Init_dtext() {
  VALUE mDTextRagel = rb_define_module("DTextRagel");
  rb_define_singleton_method(mDTextRagel, "parse", parse, 1);
}
