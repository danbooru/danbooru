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
  BLOCK_P,
  BLOCK_TN,
  BLOCK_QUOTE,
  BLOCK_EXPAND,
  BLOCK_SPOILER,
  BLOCK_NODTEXT,
  BLOCK_CODE,
  BLOCK_TABLE,
  BLOCK_THEAD,
  BLOCK_TBODY,
  BLOCK_TR,
  BLOCK_TH,
  BLOCK_TD,
  BLOCK_UL,
  BLOCK_LI,
  BLOCK_H1,
  BLOCK_H2,
  BLOCK_H3,
  BLOCK_H4,
  BLOCK_H5,
  BLOCK_H6,
  INLINE_B,
  INLINE_I,
  INLINE_U,
  INLINE_S,
  INLINE_TN,
  INLINE_CODE,
  INLINE_SPOILER,
  INLINE_NODTEXT,
} element_t;

const char* element_names[] = {
  "QUEUE_EMPTY",
  "BLOCK_P",
  "BLOCK_TN",
  "BLOCK_QUOTE",
  "BLOCK_EXPAND",
  "BLOCK_SPOILER",
  "BLOCK_NODTEXT",
  "BLOCK_CODE",
  "BLOCK_TABLE",
  "BLOCK_THEAD",
  "BLOCK_TBODY",
  "BLOCK_TR",
  "BLOCK_TH",
  "BLOCK_TD",
  "BLOCK_UL",
  "BLOCK_LI",
  "BLOCK_H1",
  "BLOCK_H2",
  "BLOCK_H3",
  "BLOCK_H4",
  "BLOCK_H5",
  "BLOCK_H6",
  "INLINE_B",
  "INLINE_I",
  "INLINE_U",
  "INLINE_S",
  "INLINE_TN",
  "INLINE_CODE",
  "INLINE_SPOILER",
  "INLINE_NODTEXT",
};

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
    g_debug("growing sm->stack %zi", len + 16);
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

action mark_c1 {
  sm->c1 = sm->p;
}

action mark_c2 {
  sm->c2 = sm->p;
}

action mark_d1 {
  sm->d1 = sm->p;
}

action mark_d2 {
  sm->d2 = sm->p;
}

newline = '\r\n' | '\n';
ws = ' ' | '\t';

nonnewline = any - (newline | '\r');
nonquote = ^'"';
nonbracket = ^']';
nonrparen = ^')';
nonpipe = ^'|';
nonpipebracket = nonpipe & nonbracket;
noncurly = ^'}';

mention = '@' ^space+ >mark_a1 %mark_a2;
delimited_mention = '<' mention :>> '>';

url = 'http'i 's'i? '://' ^space+;
delimited_url = '<' url :>> '>';
relative_url = [/#] ^space*;
basic_textile_link = '"' nonquote+ >mark_a1 '"' >mark_a2 ':' (url | relative_url) >mark_b1 @mark_b2;
bracketed_textile_link = '"' nonquote+ >mark_a1 '"' >mark_a2 ':[' (url | relative_url) >mark_b1 @mark_b2 :>> ']';

# XXX: internal markdown links aren't allowed to avoid parsing closing tags as links: `[b]foo[/b](bar)`.
markdown_link = '[' url >mark_a1 %mark_a2 :>> '](' nonrparen+ >mark_b1 %mark_b2 ')';
html_link = '<a'i ws+ 'href="'i (url | relative_url) >mark_a1 %mark_a2 :>> '">' nonnewline+ >mark_b1 %mark_b2 :>> '</a>'i;

basic_wiki_link = alnum* >mark_a1 %mark_a2 '[[' (nonbracket nonpipebracket*) >mark_b1 %mark_b2 ']]' alnum* >mark_c1 %mark_c2;
aliased_wiki_link = alnum* >mark_a1 %mark_a2 '[[' nonpipebracket+ >mark_b1 %mark_b2 '|' nonpipebracket* >mark_c1 %mark_c2 ']]' alnum* >mark_d1 %mark_d2;

post_link = '{{' noncurly+ >mark_a1 %mark_a2 '}}';

id = digit+ >mark_a1 %mark_a2;
alnum_id = alnum+ >mark_a1 %mark_a2;
page = digit+ >mark_b1 %mark_b2;
dmail_key = (alnum | '=' | '-')+ >mark_b1 %mark_b2;

nonperiod = graph - ('.' | '"');
header = 'h'i [123456] >mark_a1 %mark_a2 '.' ws*;
header_with_id = 'h'i [123456] >mark_a1 %mark_a2 '#' nonperiod+ >mark_b1 %mark_b2 '.' ws*;
aliased_expand = ('[expand'i ws* '='? ws* (nonbracket+ >mark_a1 %mark_a2) ']')
               | ('<expand'i ws* '='? ws* ((^'>')+ >mark_a1 %mark_a2) '>');

list_item = '*'+ >mark_a1 %mark_a2 ws+ nonnewline+ >mark_b1 %mark_b2;

open_spoilers = ('[spoiler'i 's'i? ']') | ('<spoiler'i 's'i? '>');
open_nodtext = '[nodtext]'i | '<nodtext>'i;
open_quote = '[quote]'i | '<quote>'i | '<blockquote>'i;
open_expand = '[expand]'i | '<expand>'i;
open_code = '[code]'i | '<code>'i;
open_table = '[table]'i | '<table>'i;
open_thead = '[thead]'i | '<thead>'i;
open_tbody = '[tbody]'i | '<tbody>'i;
open_th = '[th]'i | '<th>'i;
open_tr = '[tr]'i | '<tr>'i;
open_td = '[td]'i | '<td>'i;
open_tn = '[tn]'i | '<tn>'i;
open_b = '[b]'i | '<b>'i | '<strong>'i;
open_i = '[i]'i | '<i>'i | '<em>'i;
open_s = '[s]'i | '<s>'i;
open_u = '[u]'i | '<u>'i;

close_spoilers = ('[/spoiler'i 's'i? ']') | ('</spoiler'i 's'i? '>');
close_nodtext = '[/nodtext]'i | '</nodtext>'i;
close_quote = '[/quote]'i | '</quote>'i | '</blockquote>'i;
close_expand = '[/expand]'i | '</expand>'i;
close_code = '[/code]'i | '</code>'i;
close_table = '[/table]'i | '</table>'i;
close_thead = '[/thead]'i | '</thead>'i;
close_tbody = '[/tbody]'i | '</tbody>'i;
close_tr = '[/tr]'i | '</tr>'i;
close_th = '[/th]'i | '</th>'i;
close_td = '[/td]'i | '</td>'i;
close_tn = '[/tn]'i | '</tn>'i;
close_b = '[/b]'i | '</b>'i | '</strong>'i;
close_i = '[/i]'i | '</i>'i | '</em>'i;
close_s = '[/s]'i | '</s>'i;
close_u = '[/u]'i | '</u>'i;

basic_inline := |*
  open_b  => { dstack_open_inline(sm,  INLINE_B, "<strong>"); };
  close_b => { dstack_close_inline(sm, INLINE_B, "</strong>"); };
  open_i  => { dstack_open_inline(sm,  INLINE_I, "<em>"); };
  close_i => { dstack_close_inline(sm, INLINE_I, "</em>"); };
  open_s  => { dstack_open_inline(sm,  INLINE_S, "<s>"); };
  close_s => { dstack_close_inline(sm, INLINE_S, "</s>"); };
  open_u  => { dstack_open_inline(sm,  INLINE_U, "<u>"); };
  close_u => { dstack_close_inline(sm, INLINE_U, "</u>"); };
  any => { append_c_html_escaped(sm, fc); };
*|;

inline := |*
  'post #'i id        => { append_id_link(sm, "post", "post", "/posts/"); };
  'appeal #'i id      => { append_id_link(sm, "appeal", "post-appeal", "/post_appeals/"); };
  'flag #'i id        => { append_id_link(sm, "flag", "post-flag", "/post_flags/"); };
  'note #'i id        => { append_id_link(sm, "note", "note", "/notes/"); };
  'forum #'i id       => { append_id_link(sm, "forum", "forum-post", "/forum_posts/"); };
  'topic #'i id       => { append_id_link(sm, "topic", "forum-topic", "/forum_topics/"); };
  'comment #'i id     => { append_id_link(sm, "comment", "comment", "/comments/"); };
  'dmail #'i id       => { append_id_link(sm, "dmail", "dmail", "/dmails/"); };
  'pool #'i id        => { append_id_link(sm, "pool", "pool", "/pools/"); };
  'user #'i id        => { append_id_link(sm, "user", "user", "/users/"); };
  'artist #'i id      => { append_id_link(sm, "artist", "artist", "/artists/"); };
  'ban #'i id         => { append_id_link(sm, "ban", "ban", "/bans/"); };
  'bur #'i id         => { append_id_link(sm, "BUR", "bulk-update-request", "/bulk_update_requests/"); };
  'alias #'i id       => { append_id_link(sm, "alias", "tag-alias", "/tag_aliases/"); };
  'implication #'i id => { append_id_link(sm, "implication", "tag-implication", "/tag_implications/"); };
  'favgroup #'i id    => { append_id_link(sm, "favgroup", "favorite-group", "/favorite_groups/"); };
  'mod action #'i id  => { append_id_link(sm, "mod action", "mod-action", "/mod_actions/"); };
  'modreport #'i id   => { append_id_link(sm, "modreport", "moderation-report", "/moderation_reports/"); };
  'feedback #'i id    => { append_id_link(sm, "feedback", "user-feedback", "/user_feedbacks/"); };
  'wiki #'i id        => { append_id_link(sm, "wiki", "wiki-page", "/wiki_pages/"); };

  'issue #'i id            => { append_id_link(sm, "issue", "github", "https://github.com/danbooru/danbooru/issues/"); };
  'pull #'i id             => { append_id_link(sm, "pull", "github-pull", "https://github.com/danbooru/danbooru/pull/"); };
  'commit #'i id           => { append_id_link(sm, "commit", "github-commit", "https://github.com/danbooru/danbooru/commit/"); };
  'artstation #'i alnum_id => { append_id_link(sm, "artstation", "artstation", "https://www.artstation.com/artwork/"); };
  'deviantart #'i id       => { append_id_link(sm, "deviantart", "deviantart", "https://www.deviantart.com/deviation/"); };
  'nijie #'i id            => { append_id_link(sm, "nijie", "nijie", "https://nijie.info/view.php?id="); };
  'pawoo #'i id            => { append_id_link(sm, "pawoo", "pawoo", "https://pawoo.net/web/statuses/"); };
  'pixiv #'i id            => { append_id_link(sm, "pixiv", "pixiv", "https://www.pixiv.net/artworks/"); };
  'seiga #'i id            => { append_id_link(sm, "seiga", "seiga", "https://seiga.nicovideo.jp/seiga/im"); };
  'twitter #'i id          => { append_id_link(sm, "twitter", "twitter", "https://twitter.com/i/web/status/"); };

  'yandere #'i id => { append_id_link(sm, "yandere", "yandere", "https://yande.re/post/show/"); };
  'sankaku #'i id => { append_id_link(sm, "sankaku", "sankaku", "https://chan.sankakucomplex.com/post/show/"); };
  'gelbooru #'i id => { append_id_link(sm, "gelbooru", "gelbooru", "https://gelbooru.com/index.php?page=post&s=view&id="); };

  'dmail #'i id '/' dmail_key => { append_dmail_key_link(sm); };

  'topic #'i id '/p'i page => { append_paged_link(sm, "topic #", "<a class=\"dtext-link dtext-id-link dtext-forum-topic-id-link\" href=\"", "/forum_topics/", "?page="); };
  'pixiv #'i id '/p'i page => { append_paged_link(sm, "pixiv #", "<a rel=\"external nofollow noreferrer\" class=\"dtext-link dtext-id-link dtext-pixiv-id-link\" href=\"", "https://www.pixiv.net/artworks/", "#"); };

  post_link => {
    append(sm, "<a class=\"dtext-link dtext-post-search-link\" href=\"");
    append_url(sm, "/posts?tags=");
    append_segment_uri_escaped(sm, sm->a1, sm->a2 - 1);
    append(sm, "\">");
    append_segment_html_escaped(sm, sm->a1, sm->a2 - 1);
    append(sm, "</a>");
  };

  basic_wiki_link => {
    append_wiki_link(sm, sm->b1, sm->b2 - sm->b1, sm->b1, sm->b2 - sm->b1, sm->a1, sm->a2 - sm->a1, sm->c1, sm->c2 - sm->c1);
  };

  aliased_wiki_link => {
    append_wiki_link(sm, sm->b1, sm->b2 - sm->b1, sm->c1, sm->c2 - sm->c1, sm->a1, sm->a2 - sm->a1, sm->d1, sm->d2 - sm->d1);
  };

  basic_textile_link => {
    const char* match_end = sm->b2;
    const char* url_start = sm->b1;
    const char* url_end = find_boundary_c(match_end);

    if (!append_named_url(sm, url_start, url_end, sm->a1, sm->a2)) {
      fbreak;
    }

    if (url_end < match_end) {
      append_segment_html_escaped(sm, url_end + 1, match_end);
    }
  };

  bracketed_textile_link => {
    if (!append_named_url(sm, sm->b1, sm->b2, sm->a1, sm->a2)) {
      fbreak;
    }
  };

  markdown_link | html_link => {
    if (!append_named_url(sm, sm->a1, sm->a2 - 1, sm->b1, sm->b2)) {
      fbreak;
    }
  };

  url => {
    const char* match_end = sm->te - 1;
    const char* url_start = sm->ts;
    const char* url_end = find_boundary_c(match_end);

    append_unnamed_url(sm, url_start, url_end);

    if (url_end < match_end) {
      append_segment_html_escaped(sm, url_end + 1, match_end);
    }
  };

  delimited_url => {
    append_unnamed_url(sm, sm->ts + 1, sm->te - 2);
  };

  # probably a tag. examples include @.@ and @_@
  '@' graph '@' => {
    append_segment_html_escaped(sm, sm->ts, sm->te - 1);
  };

  mention => {
    if (!sm->f_mentions || (sm->a1 - 2 >= sm->pb && sm->a1[-2] != ' ' && sm->a1[-2] != '\r' && sm->a1[-2] != '\n')) {
      g_debug("write '@' (ignored mention)");
      append_c_html_escaped(sm, '@');
      fexec sm->a1;
    } else {
      const char* match_end = sm->a2 - 1;
      const char* name_start = sm->a1;
      const char* name_end = find_boundary_c(match_end);

      g_debug("mention: '@%.*s'", (int)(name_end - name_start + 1), sm->a1);
      append_mention(sm, name_start, name_end);

      if (name_end < match_end) {
        append_segment_html_escaped(sm, name_end + 1, match_end);
      }
    }
  };

  delimited_mention => {
    if (sm->f_mentions) {
      g_debug("delimited mention: <@%.*s>", (int)(sm->a2 - sm->a1), sm->a1);
      append_mention(sm, sm->a1, sm->a2 - 1);
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

  open_b  => { dstack_open_inline(sm,  INLINE_B, "<strong>"); };
  close_b => { dstack_close_inline(sm, INLINE_B, "</strong>"); };
  open_i  => { dstack_open_inline(sm,  INLINE_I, "<em>"); };
  close_i => { dstack_close_inline(sm, INLINE_I, "</em>"); };
  open_s  => { dstack_open_inline(sm,  INLINE_S, "<s>"); };
  close_s => { dstack_close_inline(sm, INLINE_S, "</s>"); };
  open_u  => { dstack_open_inline(sm,  INLINE_U, "<u>"); };
  close_u => { dstack_close_inline(sm, INLINE_U, "</u>"); };

  open_tn => {
    dstack_open_inline(sm, INLINE_TN, "<span class=\"tn\">");
  };

  close_tn => {
    g_debug("inline [/tn]");
    dstack_close_before_block(sm);

    if (dstack_check(sm, INLINE_TN)) {
      dstack_close_inline(sm, INLINE_TN, "</span>");
    } else if (dstack_close_block(sm, BLOCK_TN, "</p>")) {
      fret;
    }
  };

  open_code => {
    dstack_open_inline(sm, INLINE_CODE, "<code>");
    fcall code;
  };

  open_spoilers => {
    dstack_open_inline(sm, INLINE_SPOILER, "<span class=\"spoiler\">");
  };

  close_spoilers => {
    g_debug("inline [/spoiler]");
    dstack_close_before_block(sm);

    if (dstack_check(sm, INLINE_SPOILER)) {
      dstack_close_inline(sm, INLINE_SPOILER, "</span>");
    } else if (dstack_close_block(sm, BLOCK_SPOILER, "</div>")) {
      fret;
    }
  };

  open_nodtext => {
    dstack_open_inline(sm, INLINE_NODTEXT, "");
    fcall nodtext;
  };
  
  # these are block level elements that should kick us out of the inline
  # scanner

  open_quote => {
    g_debug("inline [quote]");
    dstack_close_before_block(sm);
    fexec sm->ts;
    fret;
  };

  close_quote space* => {
    g_debug("inline [/quote]");
    dstack_close_before_block(sm);

    if (dstack_check(sm, BLOCK_LI)) {
      dstack_close_list(sm);
    }

    if (dstack_is_open(sm, BLOCK_QUOTE)) {
      dstack_close_until(sm, BLOCK_QUOTE);
      fret;
    } else {
      append_block(sm, "[/quote]");
    }
  };

  open_expand => {
    g_debug("inline [expand]");
    dstack_rewind(sm);
    fexec(sm->p - 7);
    fret;
  };

  close_expand => {
    dstack_close_before_block(sm);

    if (dstack_close_block(sm, BLOCK_EXPAND, "</div></details>")) {
      fret;
    }
  };

  close_th => {
    if (dstack_close_block(sm, BLOCK_TH, "</th>")) {
      fret;
    }
  };

  close_td => {
    if (dstack_close_block(sm, BLOCK_TD, "</td>")) {
      fret;
    }
  };

  newline{2,} => {
    g_debug("inline newline2");
    g_debug("  return");

    dstack_close_list(sm);
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
      append(sm, "<br>");
    }
  };

  '\r' => {
    append_c_html_escaped(sm, ' ');
  };

  any => {
    append_c_html_escaped(sm, fc);
  };
*|;

code := |*
  close_code => {
    dstack_rewind(sm);
    fret;
  };

  any => {
    append_c_html_escaped(sm, fc);
  };
*|;

nodtext := |*
  close_nodtext => {
    if (dstack_check(sm, BLOCK_NODTEXT)) {
      g_debug("block dstack check");
      dstack_pop(sm);
      append_block(sm, "</p>");
      fret;
    } else if (dstack_check(sm, INLINE_NODTEXT)) {
      g_debug("inline dstack check");
      dstack_rewind(sm);
      fret;
    } else {
      g_debug("else dstack check");
      append(sm, "[/nodtext]");
    }
  };

  any => {
    append_c_html_escaped(sm, fc);
  };
*|;

table := |*
  open_thead => {
    dstack_open_block(sm, BLOCK_THEAD, "<thead>");
  };

  close_thead => {
    dstack_close_block(sm, BLOCK_THEAD, "</thead>");
  };

  open_tbody => {
    dstack_open_block(sm, BLOCK_TBODY, "<tbody>");
  };

  close_tbody => {
    dstack_close_block(sm, BLOCK_TBODY, "</tbody>");
  };

  open_th => {
    dstack_open_block(sm, BLOCK_TH, "<th>");
    fcall inline;
  };

  open_tr => {
    dstack_open_block(sm, BLOCK_TR, "<tr>");
  };

  close_tr => {
    dstack_close_block(sm, BLOCK_TR, "</tr>");
  };

  open_td => {
    dstack_open_block(sm, BLOCK_TD, "<td>");
    fcall inline;
  };

  close_table => {
    if (dstack_close_block(sm, BLOCK_TABLE, "</table>")) {
      fret;
    }
  };

  any;
*|;

list := |*
  list_item => {
    int prev_nest = sm->list_nest;
    append_closing_p_if(sm);
    g_debug("list start");
    sm->list_nest = sm->a2 - sm->a1;
    fexec sm->b1;

    if (sm->list_nest > prev_nest) {
      for (int i = prev_nest; i < sm->list_nest; ++i) {
        dstack_open_block(sm, BLOCK_UL, "<ul>");
      }
    } else if (sm->list_nest < prev_nest) {
      for (int i = sm->list_nest; i < prev_nest; ++i) {
        if (dstack_check(sm, BLOCK_UL)) {
          dstack_rewind(sm);
        }
      }
    }

    dstack_open_block(sm, BLOCK_LI, "<li>");

    g_debug("  call inline");

    fcall inline;
  };

  # exit list
  newline{2,} => {
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
    g_autoptr(GString) id_name = g_string_new_len(sm->b1, sm->b2 - sm->b1);
    id_name = g_string_prepend(id_name, "dtext-");

    if (sm->f_inline) {
      header = '6';
    }

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

    sm->header_mode = true;
    fcall inline;
  };

  header => {
    char header = *sm->a1;

    if (sm->f_inline) {
      header = '6';
    }

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

    sm->header_mode = true;
    fcall inline;
  };

  open_quote space* => {
    dstack_close_before_block(sm);
    dstack_open_block(sm, BLOCK_QUOTE, "<blockquote>");
  };

  open_spoilers space* => {
    dstack_close_before_block(sm);
    dstack_open_block(sm, BLOCK_SPOILER, "<div class=\"spoiler\">");
  };

  close_spoilers => {
    g_debug("block [/spoiler]");
    dstack_close_before_block(sm);
    if (dstack_check(sm, BLOCK_SPOILER)) {
      g_debug("  rewind");
      dstack_rewind(sm);
    }
  };

  open_code space* => {
    dstack_close_before_block(sm);
    dstack_open_block(sm, BLOCK_CODE, "<pre>");
    fcall code;
  };

  open_expand space* => {
    dstack_close_before_block(sm);
    dstack_open_block(sm, BLOCK_EXPAND, "<details>");
    append(sm, "<summary>Show</summary><div>");
  };

  aliased_expand space* => {
    g_debug("block [expand=]");
    dstack_close_before_block(sm);
    dstack_open_block(sm, BLOCK_EXPAND, "<details>");
    append(sm, "<summary>");
    append_segment_html_escaped(sm, sm->a1, sm->a2 - 1);
    append(sm, "</summary><div>");
  };

  open_nodtext space* => {
    dstack_close_before_block(sm);
    dstack_open_block(sm, BLOCK_NODTEXT, "<p>");
    fcall nodtext;
  };

  open_table => {
    dstack_close_before_block(sm);
    dstack_open_block(sm, BLOCK_TABLE, "<table class=\"striped\">");
    fcall table;
  };

  open_tn => {
    dstack_open_block(sm, BLOCK_TN, "<p class=\"tn\">");
    fcall inline;
  };

  list_item => {
    g_debug("block list");
    g_debug("  call list");
    sm->list_nest = 0;
    append_closing_p_if(sm);
    fexec sm->ts;
    fcall list;
  };

  newline{2,} => {
    g_debug("block newline2");

    if (sm->header_mode) {
      sm->header_mode = false;
      dstack_rewind(sm);
    } else if (sm->list_nest) {
      dstack_close_list(sm);
    } else {
      dstack_close_before_block(sm);
    }
  };

  newline => {
    g_debug("block newline");
  };

  any => {
    g_debug("block char");
    fhold;

    if (g_queue_is_empty(sm->dstack) || dstack_check(sm, BLOCK_QUOTE) || dstack_check(sm, BLOCK_SPOILER) || dstack_check(sm, BLOCK_EXPAND)) {
      dstack_open_block(sm, BLOCK_P, "<p>");
    }

    fcall inline;
  };
*|;

}%%

%% write data;

static inline void dstack_push(StateMachine * sm, element_t element) {
  g_queue_push_tail(sm->dstack, GINT_TO_POINTER(element));
}

static inline element_t dstack_pop(StateMachine * sm) {
  return GPOINTER_TO_INT(g_queue_pop_tail(sm->dstack));
}

static inline element_t dstack_peek(const StateMachine * sm) {
  return GPOINTER_TO_INT(g_queue_peek_tail(sm->dstack));
}

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

// Return true if the given tag is currently open.
static inline bool dstack_is_open(const StateMachine * sm, element_t element) {
  return g_queue_index(sm->dstack, GINT_TO_POINTER(element)) != -1;
}

static inline bool is_internal_url(StateMachine * sm, GUri* url) {
  if (sm->domain == NULL || url == NULL) {
    return false;
  }

  const char* host = g_uri_get_host(url);
  if (host == NULL) {
    return false;
  }

  return strcmp(sm->domain, host) == 0;
}

static inline void append(StateMachine * sm, const char * s) {
  sm->output = g_string_append(sm->output, s);
}

static inline void append_c_html_escaped(StateMachine * sm, char s) {
  g_debug("write '%c'", s);

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

static inline void append_segment(StateMachine * sm, const char * a, const char * b) {
  sm->output = g_string_append_len(sm->output, a, b - a + 1);
}

static inline void append_segment_uri_escaped(StateMachine * sm, const char * a, const char * b) {
  g_autofree char* escaped = g_uri_escape_bytes((const guint8 *)a, b - a + 1, NULL);
  g_string_append(sm->output, escaped);
}

static inline void append_segment_html_escaped(StateMachine * sm, const char * a, const char * b) {
  g_autofree gchar * segment = g_markup_escape_text(a, b - a + 1);
  g_string_append(sm->output, segment);
}

static inline void append_url(StateMachine * sm, const char* url) {
  if ((url[0] == '/' || url[0] == '#') && sm->base_url) {
    append(sm, sm->base_url);
  }

  append(sm, url);
}

static inline void append_mention(StateMachine * sm, const char* name_start, const char* name_end) {
  append(sm, "<a class=\"dtext-link dtext-user-mention-link\" data-user-name=\"");
  append_segment_html_escaped(sm, name_start, name_end);
  append(sm, "\" href=\"");
  append_url(sm, "/users?name=");
  append_segment_uri_escaped(sm, name_start, name_end);
  append(sm, "\">@");
  append_segment_html_escaped(sm, name_start, name_end);
  append(sm, "</a>");
}

static inline void append_id_link(StateMachine * sm, const char * title, const char * id_name, const char * url) {
  if (url[0] == '/') {
    append(sm, "<a class=\"dtext-link dtext-id-link dtext-");
  } else {
    append(sm, "<a rel=\"external nofollow noreferrer\" class=\"dtext-link dtext-id-link dtext-");
  }

  append(sm, id_name);
  append(sm, "-id-link\" href=\"");
  append_url(sm, url);
  append_segment_uri_escaped(sm, sm->a1, sm->a2 - 1);
  append(sm, "\">");
  append(sm, title);
  append(sm, " #");
  append_segment_html_escaped(sm, sm->a1, sm->a2 - 1);
  append(sm, "</a>");
}

static inline void append_unnamed_url(StateMachine * sm, const char * url_start, const char * url_end) {
  g_autoptr(GString) url = g_string_new_len(url_start, url_end - url_start + 1);
  g_autoptr(GUri) parsed_url = g_uri_parse(url->str, G_URI_FLAGS_NONE, NULL);

  if (is_internal_url(sm, parsed_url)) {
    append(sm, "<a class=\"dtext-link\" href=\"");
  } else {
    append(sm, "<a rel=\"external nofollow noreferrer\" class=\"dtext-link dtext-external-link\" href=\"");
  }

  append_segment_html_escaped(sm, url_start, url_end);
  append(sm, "\">");
  append_segment_html_escaped(sm, url_start, url_end);
  append(sm, "</a>");
}

static inline bool append_named_url(StateMachine * sm, const char * url_start, const char * url_end, const char * title_start, const char * title_end) {
  int url_len = url_end - url_start + 1;
  g_autoptr(GString) parsed_title = parse_basic_inline(title_start, title_end - title_start);

  if (!parsed_title) {
    return false;
  }

  // protocol-relative url; treat `//example.com` like `http://example.com`
  if (url_len > 2 && url_start[0] == '/' && url_start[1] == '/') {
    g_autoptr(GString) url = g_string_new_len(url_start, url_len);
    g_string_prepend(url, "http:");
    g_autoptr(GUri) parsed_url = g_uri_parse(url->str, G_URI_FLAGS_NONE, NULL);

    if (is_internal_url(sm, parsed_url)) {
      append(sm, "<a class=\"dtext-link\" href=\"http:");
    } else {
      append(sm, "<a rel=\"external nofollow noreferrer\" class=\"dtext-link dtext-external-link dtext-named-external-link\" href=\"http:");
    }
  } else if (url_start[0] == '/' || url_start[0] == '#') {
    append(sm, "<a class=\"dtext-link\" href=\"");

    if (sm->base_url) {
      append(sm, sm->base_url);
    }
  } else {
    g_autoptr(GString) url = g_string_new_len(url_start, url_len);
    g_autoptr(GUri) parsed_url = g_uri_parse(url->str, G_URI_FLAGS_NONE, NULL);

    if (is_internal_url(sm, parsed_url)) {
      append(sm, "<a class=\"dtext-link\" href=\"");
    } else {
      append(sm, "<a rel=\"external nofollow noreferrer\" class=\"dtext-link dtext-external-link dtext-named-external-link\" href=\"");
    }
  }

  append_segment_html_escaped(sm, url_start, url_end);
  append(sm, "\">");
  append_segment(sm, parsed_title->str, parsed_title->str + parsed_title->len - 1);
  append(sm, "</a>");

  return true;
}

static inline void append_wiki_link(StateMachine * sm, const char * tag_segment, const size_t tag_len, const char * title_segment, const size_t title_len, const char * prefix_segment, const size_t prefix_len, const char * suffix_segment, const size_t suffix_len) {
  g_autofree gchar* lowercased_tag = g_utf8_strdown(tag_segment, tag_len);
  g_autoptr(GString) normalized_tag = g_string_new(g_strdelimit(lowercased_tag, " ", '_'));
  g_autoptr(GString) title_string = g_string_new_len(title_segment, title_len);

  if (g_regex_match_simple("^[0-9]+$", normalized_tag->str, 0, 0)) {
    g_string_prepend(normalized_tag, "~");
  }
  
  /* handle pipe trick: [[Kaga (Kantai Collection)|]] -> [[kaga_(kantai_collection)|Kaga]] */
  if (title_string->len == 0) {
    g_string_append_len(title_string, tag_segment, tag_len);

    /* strip qualifier from tag: "kaga (kantai collection)" -> "kaga" */
    g_autoptr(GRegex) qualifier_regex = g_regex_new("[ _]\\([^)]+?\\)$", 0, 0, NULL);
    g_autofree gchar* stripped_string = g_regex_replace_literal(qualifier_regex, title_string->str, title_string->len, 0, "", 0, NULL);

    g_string_assign(title_string, stripped_string);
  }

  g_string_prepend_len(title_string, prefix_segment, prefix_len);
  g_string_append_len(title_string, suffix_segment, suffix_len);

  append(sm, "<a class=\"dtext-link dtext-wiki-link\" href=\"");
  append_url(sm, "/wiki_pages/");
  append_segment_uri_escaped(sm, normalized_tag->str, normalized_tag->str + normalized_tag->len - 1);
  append(sm, "\">");
  append_segment_html_escaped(sm, title_string->str, title_string->str + title_string->len - 1);
  append(sm, "</a>");
}

static inline void append_paged_link(StateMachine * sm, const char * title, const char * tag, const char * href, const char * param) {
  append(sm, tag);
  append_url(sm, href);
  append_segment(sm, sm->a1, sm->a2 - 1);
  append(sm, param);
  append_segment(sm, sm->b1, sm->b2 - 1);
  append(sm, "\">");
  append(sm, title);
  append_segment(sm, sm->a1, sm->a2 - 1);
  append(sm, "/p");
  append_segment(sm, sm->b1, sm->b2 - 1);
  append(sm, "</a>");
}

static inline void append_dmail_key_link(StateMachine * sm) {
  append(sm, "<a class=\"dtext-link dtext-id-link dtext-dmail-id-link\" href=\"");
  append_url(sm, "/dmails/");
  append_segment(sm, sm->a1, sm->a2 - 1);
  append(sm, "?key=");
  append_segment_uri_escaped(sm, sm->b1, sm->b2 - 1);
  append(sm, "\">");
  append(sm, "dmail #");
  append_segment(sm, sm->a1, sm->a2 - 1);
  append(sm, "</a>");
}

static inline void append_block_segment(StateMachine * sm, const char * a, const char * b) {
  if (!sm->f_inline) {
    g_debug("write '%.*s'", (int)(b - a + 1), a);
    sm->output = g_string_append_len(sm->output, a, b - a + 1);
  }
}

static inline void append_block(StateMachine * sm, const char * s) {
  append_block_segment(sm, s, s + strlen(s) - 1);
}

static void append_closing_p(StateMachine * sm) {
  size_t i = sm->output->len;

  g_debug("append closing p");

  if (i > 4 && !strncmp(sm->output->str + i - 4, "<br>", 4)) {
    g_debug("trim last <br>");
    sm->output = g_string_truncate(sm->output, sm->output->len - 4);
  }

  if (i > 3 && !strncmp(sm->output->str + i - 3, "<p>", 3)) {
    g_debug("trim last <p>");
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
  g_debug("opening inline %s", html);

  dstack_push(sm, type);
  append(sm, html);
}

static void dstack_open_block(StateMachine * sm, element_t type, const char * html) {
  g_debug("opening block %s", html);

  dstack_push(sm, type);
  append_block(sm, html);
}

static void dstack_close_inline(StateMachine * sm, element_t type, const char * close_html) {
  if (dstack_check(sm, type)) {
    g_debug("closing inline %s", close_html);

    dstack_pop(sm);
    append(sm, close_html);
  } else {
    g_debug("out-of-order closing %s", element_names[type]);

    append_segment(sm, sm->ts, sm->te - 1);
  }
}

static bool dstack_close_block(StateMachine * sm, element_t type, const char * close_html) {
  if (dstack_check(sm, type)) {
    g_debug("closing block %s", close_html);

    dstack_pop(sm);
    append_block(sm, close_html);
    return true;
  } else {
    g_debug("out-of-order closing %s", element_names[type]);

    append_block_segment(sm, sm->ts, sm->te - 1);
    return false;
  }
}

// Close the last open tag.
static void dstack_rewind(StateMachine * sm) {
  element_t element = dstack_pop(sm);
  g_debug("dstack rewind %s", element_names[element]);

  switch(element) {
    case BLOCK_P: append_closing_p(sm); break;
    case INLINE_SPOILER: append(sm, "</span>"); break;
    case BLOCK_SPOILER: append_block(sm, "</div>"); break;
    case BLOCK_QUOTE: append_block(sm, "</blockquote>"); break;
    case BLOCK_EXPAND: append_block(sm, "</div></details>"); break;
    case BLOCK_NODTEXT: append_closing_p(sm); break;
    case BLOCK_CODE: append_block(sm, "</pre>"); break;
    case BLOCK_TD: append_block(sm, "</td>"); break;
    case BLOCK_TH: append_block(sm, "</th>"); break;

    case INLINE_NODTEXT: break;
    case INLINE_B: append(sm, "</strong>"); break;
    case INLINE_I: append(sm, "</em>"); break;
    case INLINE_U: append(sm, "</u>"); break;
    case INLINE_S: append(sm, "</s>"); break;
    case INLINE_TN: append(sm, "</span>"); break;
    case INLINE_CODE: append(sm, "</code>"); break;

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

// Close the last open paragraph or list, if there is one.
static void dstack_close_before_block(StateMachine * sm) {
  g_debug("dstack close before block");

  while (dstack_check(sm, BLOCK_P) || dstack_check(sm, BLOCK_LI) || dstack_check(sm, BLOCK_UL)) {
    dstack_rewind(sm);
  }
}

// Close all open tags up to and including the given tag.
static void dstack_close_until(StateMachine * sm, element_t element) {
  while (!g_queue_is_empty(sm->dstack) && !dstack_check(sm, element)) {
    dstack_rewind(sm);
  }

  dstack_rewind(sm);
}

// Close all remaining open tags.
static void dstack_close_all(StateMachine * sm) {
  while (!g_queue_is_empty(sm->dstack)) {
    dstack_rewind(sm);
  }
}

static void dstack_close_list(StateMachine * sm) {
  while (dstack_check(sm, BLOCK_LI) || dstack_check(sm, BLOCK_UL)) {
    dstack_rewind(sm);
  }

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

StateMachine* init_machine(const char* src, size_t len) {
  StateMachine* sm = (StateMachine *)g_malloc0(sizeof(StateMachine));

  size_t output_length = len;
  if (output_length < (INT16_MAX / 2)) {
    output_length *= 2;
  }

  sm->p = src;
  sm->pb = sm->p;
  sm->pe = sm->p + len;
  sm->eof = sm->pe;
  sm->ts = NULL;
  sm->te = NULL;
  sm->cs = dtext_start;
  sm->act = 0;
  sm->top = 0;
  sm->output = g_string_sized_new(output_length);
  sm->a1 = NULL;
  sm->a2 = NULL;
  sm->b1 = NULL;
  sm->b2 = NULL;
  sm->c1 = NULL;
  sm->c2 = NULL;
  sm->d1 = NULL;
  sm->d2 = NULL;
  sm->f_inline = FALSE;
  sm->f_mentions = TRUE;
  sm->base_url = NULL;
  sm->domain = NULL;
  sm->stack = g_array_sized_new(FALSE, TRUE, sizeof(int), 16);
  sm->dstack = g_queue_new();
  sm->error = NULL;
  sm->list_nest = 0;
  sm->header_mode = false;

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

GString* parse_basic_inline(const char* dtext, const ssize_t length) {
    GString* output = NULL;
    StateMachine* sm = init_machine(dtext, length);
    sm->f_inline = true;
    sm->f_mentions = false;
    sm->cs = dtext_en_basic_inline;

    if (parse_helper(sm)) {
      output = g_string_new(sm->output->str);
    } else {
      g_debug("parse_basic_inline failed");
    }

    free_machine(sm);
    return output;
}

gboolean parse_helper(StateMachine* sm) {
  const gchar* end = NULL;

  g_debug("parse '%s'", sm->p);

  if (!g_utf8_validate(sm->pb, sm->pe - sm->pb, &end)) {
    g_set_error(&sm->error, DTEXT_PARSE_ERROR, DTEXT_PARSE_ERROR_INVALID_UTF8, "invalid utf8 starting at byte %td", end - sm->pb + 1);
    return FALSE;
  }

  %% write init nocs;
  %% write exec;

  g_debug("EOF; closing stray blocks");
  dstack_close_all(sm);
  g_debug("done");

  return sm->error == NULL;
}

/* Everything below is optional, it's only needed to build bin/cdtext.exe. */
#ifdef CDTEXT

static void parse_file(FILE* input, FILE* output, gboolean opt_inline, gboolean opt_mentions) {
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

  StateMachine* sm = init_machine(dtext, length);
  sm->f_inline = opt_inline;
  sm->f_mentions = opt_mentions;

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
  gboolean opt_inline = FALSE;
  gboolean opt_no_mentions = FALSE;

  GOptionEntry options[] = {
    { "no-mentions", 'm', 0, G_OPTION_ARG_NONE, &opt_no_mentions, "Don't parse @mentions", NULL },
    { "inline",      'i', 0, G_OPTION_ARG_NONE, &opt_inline,      "Parse in inline mode", NULL },
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
    parse_file(stdin, stdout, opt_inline, !opt_no_mentions);
    return 0;
  }

  for (const char* filename = *argv; argc > 0; argc--, argv++) {
    FILE* input = fopen(filename, "r");
    if (!input) {
      perror("fopen failed");
      return 1;
    }

    parse_file(input, stdout, opt_inline, !opt_no_mentions);
    fclose(input);
  }

  return 0;
}

#endif
