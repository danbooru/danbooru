// situationally print newlines to make the generated html
// easier to read
#define PRETTY_PRINT 0

#include "dtext.h"

#include <stdio.h>
#include <stdint.h>
#include <stdbool.h>
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
variable stack ((int *)sm->stack->data);

prepush {
  size_t len = sm->stack->len;

  if (len > MAX_STACK_DEPTH) {
    g_set_error_literal(&sm->error, DTEXT_PARSE_ERROR, DTEXT_PARSE_ERROR_DEPTH_EXCEEDED, "too many nested elements");
    fbreak;
  }

  if (sm->top >= len) {
    g_debug("growing sm->stack %zi\n", len + 16);
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

newline = '\r\n' | '\n';

nonnewline = any - (newline | '\0' | '\r');
nonquote = ^'"';
nonbracket = ^']';
nonpipe = ^'|';
nonpipebracket = nonpipe & nonbracket;
noncurly = ^'}';

utf8graph = (0x00..0x7F) & graph
          | 0xC2..0xDF 0x80..0xBF
          | 0xE0..0xEF 0x80..0xBF 0x80..0xBF
          | 0xF0..0xF4 0x80..0xBF 0x80..0xBF 0x80..0xBF;


mention = '@' utf8graph+ >mark_a1 %mark_a2;

url = 'http' 's'? '://' utf8graph+;
internal_url = '/' utf8graph+;
basic_textile_link = '"' nonquote+ >mark_a1 '"' >mark_a2 ':' (url | internal_url) >mark_b1 %mark_b2;
bracketed_textile_link = '"' nonquote+ >mark_a1 '"' >mark_a2 ':[' (url | internal_url) >mark_b1 %mark_b2 :>> ']';

basic_wiki_link = '[[' (nonbracket nonpipebracket*) >mark_a1 %mark_a2 ']]';
aliased_wiki_link = '[[' nonpipebracket+ >mark_a1 %mark_a2 '|' nonpipebracket+ >mark_b1 %mark_b2 ']]';

post_link = '{{' noncurly+ >mark_a1 %mark_a2 '}}';

spoilers_open = '[spoiler'i 's'i? ']';
spoilers_close = '[/spoiler'i 's'i? ']';

post_id = 'post #'i digit+ >mark_a1 %mark_a2;
forum_post_id = 'forum #'i digit+ >mark_a1 %mark_a2;
forum_topic_id = 'topic #'i digit+ >mark_a1 %mark_a2;
forum_topic_paged_id = 'topic #'i digit+ >mark_a1 %mark_a2 '/p' digit+ >mark_b1 %mark_b2;
comment_id = 'comment #'i digit+ >mark_a1 %mark_a2;
pool_id = 'pool #'i digit+ >mark_a1 %mark_a2;
user_id = 'user #'i digit+ >mark_a1 %mark_a2;
artist_id = 'artist #'i digit+ >mark_a1 %mark_a2;
github_issue_id = 'issue #'i digit+ >mark_a1 %mark_a2;
pixiv_id = 'pixiv #'i digit+ >mark_a1 %mark_a2;
pixiv_paged_id = 'pixiv #'i digit+ >mark_a1 %mark_a2 '/p' digit+ >mark_b1 %mark_b2;

ws = ' ' | '\t';
nonperiod = graph - ('.' | '"');
header = 'h'i [123456] >mark_a1 %mark_a2 '.' ws*;
header_with_id = 'h'i [123456] >mark_a1 %mark_a2 '#' nonperiod+ >mark_b1 %mark_b2 '.' ws*;
aliased_expand = '[expand='i (nonbracket+ >mark_a1 %mark_a2) ']';

list_item = '*'+ >mark_a1 %mark_a2 ws+ nonnewline+ >mark_b1 %mark_b2;

inline := |*
  post_id => {
    append(sm, true, "<a class=\"dtext-link dtext-id-link dtext-post-id-link\" href=\"/posts/");
    append_segment(sm, true, sm->a1, sm->a2 - 1);
    append(sm, true, "\">");
    append(sm, false, "post #");
    append_segment(sm, false, sm->a1, sm->a2 - 1);
    append(sm, true, "</a>");
  };

  forum_post_id => {
    append(sm, true, "<a class=\"dtext-link dtext-id-link dtext-forum-post-id-link\" href=\"/forum_posts/");
    append_segment(sm, true, sm->a1, sm->a2 - 1);
    append(sm, true, "\">");
    append(sm, false, "forum #");
    append_segment(sm, false, sm->a1, sm->a2 - 1);
    append(sm, true, "</a>");
  };

  forum_topic_id => {
    append(sm, true, "<a class=\"dtext-link dtext-id-link dtext-forum-topic-id-link\" href=\"/forum_topics/");
    append_segment(sm, true, sm->a1, sm->a2 - 1);
    append(sm, true, "\">");
    append(sm, false, "topic #");
    append_segment(sm, false, sm->a1, sm->a2 - 1);
    append(sm, true, "</a>");
  };

  forum_topic_paged_id => {
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
  };

  comment_id => {
    append(sm, true, "<a class=\"dtext-link dtext-id-link dtext-comment-id-link\" href=\"/comments/");
    append_segment(sm, true, sm->a1, sm->a2 - 1);
    append(sm, true, "\">");
    append(sm, false, "comment #");
    append_segment(sm, false, sm->a1, sm->a2 - 1);
    append(sm, true, "</a>");
  };

  pool_id => {
    append(sm, true, "<a class=\"dtext-link dtext-id-link dtext-pool-id-link\" href=\"/pools/");
    append_segment(sm, true, sm->a1, sm->a2 - 1);
    append(sm, true, "\">");
    append(sm, false, "pool #");
    append_segment(sm, false, sm->a1, sm->a2 - 1);
    append(sm, true, "</a>");
  };

  user_id => {
    append(sm, true, "<a class=\"dtext-link dtext-id-link dtext-user-id-link\" href=\"/users/");
    append_segment(sm, true, sm->a1, sm->a2 - 1);
    append(sm, true, "\">");
    append(sm, false, "user #");
    append_segment(sm, false, sm->a1, sm->a2 - 1);
    append(sm, true, "</a>");
  };

  artist_id => {
    append(sm, true, "<a class=\"dtext-link dtext-id-link dtext-artist-id-link\" href=\"/artists/");
    append_segment(sm, true, sm->a1, sm->a2 - 1);
    append(sm, true, "\">");
    append(sm, false, "artist #");
    append_segment(sm, false, sm->a1, sm->a2 - 1);
    append(sm, true, "</a>");
  };

  github_issue_id => {
    append(sm, true, "<a class=\"dtext-link dtext-id-link dtext-github-id-link\" href=\"https://github.com/r888888888/danbooru/issues/");
    append_segment(sm, true, sm->a1, sm->a2 - 1);
    append(sm, true, "\">");
    append(sm, false, "issue #");
    append_segment(sm, false, sm->a1, sm->a2 - 1);
    append(sm, true, "</a>");
  };

  pixiv_id => {
    append(sm, true, "<a class=\"dtext-link dtext-id-link dtext-pixiv-id-link\" href=\"http://www.pixiv.net/member_illust.php?mode=medium&illust_id=");
    append_segment(sm, true, sm->a1, sm->a2 - 1);
    append(sm, true, "\">");
    append(sm, false, "pixiv #");
    append_segment(sm, false, sm->a1, sm->a2 - 1);
    append(sm, true, "</a>");
  };

  pixiv_paged_id => {
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
  };

  post_link => {
    append(sm, true, "<a rel=\"nofollow\" class=\"dtext-link dtext-post-search-link\" href=\"/posts?tags=");
    append_segment_uri_escaped(sm, sm->a1, sm->a2 - 1);
    append(sm, true, "\">");
    append_segment_html_escaped(sm, sm->a1, sm->a2 - 1);
    append(sm, true, "</a>");
  };

  basic_wiki_link => {
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
  };

  aliased_wiki_link => {
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
  };

  basic_textile_link => {
    if (is_boundary_c(fc)) {
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
      fbreak;
    } else {
      append(sm, true, link_content_sm->output->str);
      free_machine(link_content_sm);
      link_content_sm = NULL;
    }

    append(sm, true, "</a>");

    if (sm->b) {
      append_c_html_escaped(sm, fc);
    }
  };

  bracketed_textile_link => {
    append(sm, true, "<a class=\"dtext-link dtext-external-link\" href=\"");
    append_segment_html_escaped(sm, sm->b1, sm->b2 - 1);
    append(sm, true, "\">");
    append_segment_html_escaped(sm, sm->a1, sm->a2 - 1);
    append(sm, true, "</a>");
  };

  url => {
    if (is_boundary_c(fc)) {
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
      append_c_html_escaped(sm, fc);
    }
  };

  # probably a tag. examples include @.@ and @_@
  '@' graph '@' => {
    append_segment_html_escaped(sm, sm->ts, sm->te - 1);
  };

  mention => {
    if (!sm->f_mentions || (sm->a1 > sm->pb && sm->a1 - 1 > sm->pb && sm->a1[-2] != ' ' && sm->a1[-2] != '\r' && sm->a1[-2] != '\n')) {
      // handle emails
      append_c(sm, '@');
      append_segment_html_escaped(sm, sm->a1, sm->a2 - 1);

    } else {
      if (is_boundary_c(fc)) {
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
        append_c_html_escaped(sm, fc);
      }
    }
  };

  newline list_item => {
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
    fexec sm->ts + 1;
    fnext list;
  };

  '[b]'i => {
    dstack_push(sm, &INLINE_B);
    append(sm, true, "<strong>");
  };

  '[/b]'i => {
    if (dstack_check(sm, INLINE_B)) {
      dstack_pop(sm);
      append(sm, true, "</strong>");
    } else {
      append(sm, true, "[/b]");
    }
  };

  '[i]'i => {
    dstack_push(sm, &INLINE_I);
    append(sm, true, "<em>");
  };

  '[/i]'i => {
    if (dstack_check(sm, INLINE_I)) {
      dstack_pop(sm);
      append(sm, true, "</em>");
    } else {
      append(sm, true, "[/i]");
    }
  };

  '[s]'i => {
    dstack_push(sm, &INLINE_S);
    append(sm, true, "<s>");
  };

  '[/s]'i => {
    if (dstack_check(sm, INLINE_S)) {
      dstack_pop(sm);
      append(sm, true, "</s>");
    } else {
      append(sm, true, "[/s]");
    }
  };

  '[u]'i => {
    dstack_push(sm, &INLINE_U);
    append(sm, true, "<u>");
  };

  '[/u]'i => {
    if (dstack_check(sm, INLINE_U)) {
      dstack_pop(sm);
      append(sm, true, "</u>");
    } else {
      append(sm, true, "[/u]");
    }
  };

  '[tn]'i => {
    dstack_push(sm, &INLINE_TN);
    append(sm, true, "<span class=\"tn\">");
  };

  '[/tn]'i => {
    dstack_close_before_block(sm);

    if (dstack_check(sm, BLOCK_TN)) {
      dstack_pop(sm);
      fret;
    } else if (dstack_check(sm, INLINE_TN)) {
      dstack_pop(sm);
      append(sm, true, "</span>");
    } else {
      append_block(sm, "[/tn]");
    }
  };

  spoilers_open => {
    g_debug("inline [spoiler]");
    g_debug("  push <span>");
    dstack_push(sm, &INLINE_SPOILER);
    append(sm, true, "<span class=\"spoiler\">");
  };

  spoilers_close => {
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
      fret;
    } else {
      append_block(sm, "[/spoiler]");
    }
  };

  '[nodtext]'i => {
    dstack_push(sm, &INLINE_NODTEXT);
    g_debug("push inline nodtext");
    fcall nodtext;
  };
  
  # these are block level elements that should kick us out of the inline
  # scanner

  '[quote]'i => {
    g_debug("inline [quote]");
    dstack_close_before_block(sm);
    fexec sm->ts;
    fret;
  };

  '[/quote]'i space* => {
    g_debug("inline [/quote]");
    dstack_close_before_block(sm);

    if (dstack_check(sm, BLOCK_LI)) {
      dstack_close_list(sm);
    }

    if (dstack_check(sm, BLOCK_QUOTE)) {
      dstack_rewind(sm);
      fret;
    } else {
      append_block(sm, "[/quote]");
    }
  };

  '[expand]'i => {
    g_debug("inline [expand]");
    dstack_rewind(sm);
    fexec(sm->p - 7);
    fret;
  };

  '[/expand]'i => {
    dstack_close_before_block(sm);

    if (dstack_check(sm, BLOCK_EXPAND)) {
      append_block(sm, "</div></div>");
      dstack_pop(sm);
      fret;
    } else {
      append_block(sm, "[/expand]");
    }
  };

  '[/th]'i => {
    if (dstack_check(sm, BLOCK_TH)) {
      dstack_pop(sm);
      append_block(sm, "</th>");
      fret;
    } else {
      append_block(sm, "[/th]");
    }
  };

  '[/td]'i => {
    if (dstack_check(sm, BLOCK_TD)) {
      dstack_pop(sm);
      append_block(sm, "</td>");
      fret;
    } else {
      append_block(sm, "[/td]");
    }
  };

  '\0' => {
    g_debug("inline 0");
    g_debug("  return");

    fhold;
    fret;
  };

  newline{2,} => {
    g_debug("inline newline2");
    g_debug("  return");

    if (sm->list_mode) {
      dstack_close_list(sm);
    }

    fexec sm->ts;
    fret;
  };

  newline => {
    g_debug("inline newline");

    if (sm->header_mode) {
      sm->header_mode = false;
      dstack_rewind(sm);
      fret;
    } else {
      append(sm, true, "<br>");
    }
  };

  '\r' => {
    append_c(sm, ' ');
  };

  any => {
    g_debug("inline char: %c", fc);
    append_c_html_escaped(sm, fc);
  };
*|;

code := |*
  '[/code]'i => {
    if (dstack_check(sm, BLOCK_CODE)) {
      dstack_rewind(sm);
    } else {
      append(sm, true, "[/code]");
    }
    fret;
  };

  '\0' => {
    fhold;
    fret;
  };

  any => {
    append_c_html_escaped(sm, fc);
  };
*|;

nodtext := |*
  '[/nodtext]'i => {
    if (dstack_check2(sm, BLOCK_NODTEXT)) {
      g_debug("block dstack check");
      dstack_pop(sm);
      dstack_pop(sm);
      append_block(sm, "</p>");
      fret;
    } else if (dstack_check(sm, INLINE_NODTEXT)) {
      g_debug("inline dstack check");
      dstack_pop(sm);
      fret;
    } else {
      g_debug("else dstack check");
      append(sm, true, "[/nodtext]");
    }
  };

  '\0' => {
    fhold;
    fret;
  };

  any => {
    append_c_html_escaped(sm, fc);
  };
*|;

table := |*
  '[thead]'i => {
    dstack_push(sm, &BLOCK_THEAD);
    append_block(sm, "<thead>");
  };

  '[/thead]'i => {
    if (dstack_check(sm, BLOCK_THEAD)) {
      dstack_pop(sm);
      append_block(sm, "</thead>");
    } else {
      append(sm, true, "[/thead]");
    }
  };

  '[tbody]'i => {
    dstack_push(sm, &BLOCK_TBODY);
    append_block(sm, "<tbody>");
  };

  '[/tbody]'i => {
    if (dstack_check(sm, BLOCK_TBODY)) {
      dstack_pop(sm);
      append_block(sm, "</tbody>");
    } else {
      append(sm, true, "[/tbody]");
    }
  };

  '[th]'i => {
    dstack_push(sm, &BLOCK_TH);
    append_block(sm, "<th>");
    fcall inline;
  };

  '[tr]'i => {
    dstack_push(sm, &BLOCK_TR);
    append_block(sm, "<tr>");
  };

  '[/tr]'i => {
    if (dstack_check(sm, BLOCK_TR)) {
      dstack_pop(sm);
      append_block(sm, "</tr>");
    } else {
      append(sm, true, "[/tr]");
    }
  };

  '[td]'i => {
    dstack_push(sm, &BLOCK_TD);
    append_block(sm, "<td>");
    fcall inline;
  };

  '[/table]'i => {
    if (dstack_check(sm, BLOCK_TABLE)) {
      dstack_pop(sm);
      append_block(sm, "</table>");
      fret;
    } else {
      append(sm, true, "[/table]");
    }
  };

  '\0' => {
    fhold;
    fret;
  };

  any;
*|;

list := |*
  list_item => {
    int prev_nest = sm->list_nest;
    append_closing_p_if(sm);
    g_debug("list start");
    sm->list_mode = true;
    sm->list_nest = sm->a2 - sm->a1;
    fexec sm->b1;

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

    fcall inline;
  };

  # exit list
  (newline{2,} | '\0') => {
    dstack_close_list(sm);
    fexec sm->ts;
    fret;
  };

  newline;

  any => {
    dstack_rewind(sm);
    fhold;
    fret;
  };
*|;

main := |*
  header_with_id => {
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
    fcall inline;
  };

  header => {
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
    fcall inline;
  };

  '[quote]'i space* => {
    g_debug("block [quote]");
    g_debug("  push quote");
    g_debug("  print <blockquote>");
    dstack_close_before_block(sm);
    dstack_push(sm, &BLOCK_QUOTE);
    append_block(sm, "<blockquote>");
  };

  spoilers_open space* => {
    g_debug("block [spoiler]");
    g_debug("  push spoiler");
    g_debug("  print <div>");
    dstack_close_before_block(sm);
    dstack_push(sm, &BLOCK_SPOILER);
    append_block(sm, "<div class=\"spoiler\">");
  };

  spoilers_close => {
    g_debug("block [/spoiler]");
    dstack_close_before_block(sm);
    if (dstack_check(sm, BLOCK_SPOILER)) {
      g_debug("  rewind");
      dstack_rewind(sm);
    }
  };

  '[code]'i space* => {
    g_debug("block [code]");
    dstack_close_before_block(sm);
    dstack_push(sm, &BLOCK_CODE);
    append_block(sm, "<pre>");
    fcall code;
  };

  '[expand]'i space* => {
    g_debug("block [expand]");
    dstack_close_before_block(sm);
    dstack_push(sm, &BLOCK_EXPAND);
    append_block(sm, "<div class=\"expandable\"><div class=\"expandable-header\">");
    append_block(sm, "<input type=\"button\" value=\"Show\" class=\"expandable-button\"/></div>");
    append_block(sm, "<div class=\"expandable-content\">");
  };

  aliased_expand space* => {
    g_debug("block [expand=]");
    dstack_close_before_block(sm);
    dstack_push(sm, &BLOCK_EXPAND);
    append_block(sm, "<div class=\"expandable\"><div class=\"expandable-header\">");
    append(sm, true, "<span>");
    append_segment_html_escaped(sm, sm->a1, sm->a2 - 1);
    append(sm, true, "</span>");
    append_block(sm, "<input type=\"button\" value=\"Show\" class=\"expandable-button\"/></div>");
    append_block(sm, "<div class=\"expandable-content\">");
  };

  '[nodtext]'i space* => {
    g_debug("block [nodtext]");
    dstack_close_before_block(sm);
    dstack_push(sm, &BLOCK_NODTEXT);
    dstack_push(sm, &BLOCK_P);
    g_debug("push block nodtext");
    g_debug("push block p");
    append_block(sm, "<p>");
    fcall nodtext;
  };

  '[table]'i => {
    dstack_close_before_block(sm);
    dstack_push(sm, &BLOCK_TABLE);
    append_block(sm, "<table class=\"striped\">");
    fcall table;
  };

  '[tn]'i => {
    dstack_push(sm, &BLOCK_TN);
    append_block(sm, "<p class=\"tn\">");
    fcall inline;
  };

  list_item => {
    g_debug("block list");
    g_debug("  call list");
    sm->list_nest = 0;
    sm->list_mode = true;
    append_closing_p_if(sm);
    fexec sm->ts;
    fcall list;
  };

  '\0' => {
    g_debug("block 0");
    g_debug("  close dstack");
    dstack_close(sm);
  };

  newline{2,} => {
    g_debug("block newline2");

    if (sm->header_mode) {
      sm->header_mode = false;
      dstack_rewind(sm);
    } else if (sm->list_mode) {
      dstack_close_list(sm);
    } else {
      dstack_close_before_block(sm);
    }
  };

  newline => {
    g_debug("block newline");
  };

  any => {
    g_debug("block char: %c", fc);
    fhold;

    if (g_queue_is_empty(sm->dstack) || dstack_check(sm, BLOCK_QUOTE) || dstack_check(sm, BLOCK_SPOILER) || dstack_check(sm, BLOCK_EXPAND)) {
      g_debug("  push p");
      g_debug("  print <p>");
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

  %% write init;
  %% write exec;

  dstack_close(sm);

  return sm->error == NULL;
}
