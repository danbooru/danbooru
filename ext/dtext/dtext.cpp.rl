#include "dtext.h"
#include "url.h"

#include <algorithm>
#include <unordered_map>
#include <unordered_set>
#include <regex>

#ifdef DEBUG
#undef g_debug
#define STRINGIFY(x) XSTRINGIFY(x)
#define XSTRINGIFY(x) #x
#define g_debug(fmt, ...) fprintf(stderr, "\x1B[1;32mDEBUG\x1B[0m %-28.28s %-24.24s " fmt "\n", __FILE__ ":" STRINGIFY(__LINE__), __func__, ##__VA_ARGS__)
#else
#undef g_debug
#define g_debug(...)
#endif

static const size_t MAX_STACK_DEPTH = 512;

// Strip qualifier from tag: "Artoria Pendragon (Lancer) (Fate)" -> "Artoria Pendragon (Lancer)"
static const std::regex tag_qualifier_regex("[ _]\\([^)]+?\\)$");

// Permitted HTML attribute names.
static const std::unordered_map<std::string_view, const std::unordered_set<std::string_view>> permitted_attribute_names = {
  { "thead",    { "align" } },
  { "tbody",    { "align" } },
  { "tr",       { "align" } },
  { "td",       { "align", "colspan", "rowspan" } },
  { "th",       { "align", "colspan", "rowspan" } },
  { "col",      { "align", "span" } },
  { "colgroup", {} },
};

// Permitted HTML attribute values.
static const std::unordered_set<std::string_view> align_values = { "left", "center", "right", "justify" };
static const std::unordered_map<std::string_view, std::function<bool(std::string_view)>> permitted_attribute_values = {
  { "align",   [](auto value) { return align_values.find(value) != align_values.end(); } },
  { "span",    [](auto value) { return std::all_of(value.begin(), value.end(), isdigit); } },
  { "colspan", [](auto value) { return std::all_of(value.begin(), value.end(), isdigit); } },
  { "rowspan", [](auto value) { return std::all_of(value.begin(), value.end(), isdigit); } },
};

// Characters that mark the end of a link.
//
// http://www.fileformat.info/info/unicode/category/Pe/list.htm
// http://www.fileformat.info/info/unicode/block/cjk_symbols_and_punctuation/list.htm
static char32_t boundary_characters[] = {
  0x0021, // '!' U+0021 EXCLAMATION MARK
  0x0029, // ')' U+0029 RIGHT PARENTHESIS
  0x002C, // ',' U+002C COMMA
  0x002E, // '.' U+002E FULL STOP
  0x003A, // ':' U+003A COLON
  0x003B, // ';' U+003B SEMICOLON
  0x003C, // '<' U+003C LESS-THAN SIGN
  0x003E, // '>' U+003E GREATER-THAN SIGN
  0x003F, // '?' U+003F QUESTION MARK
  0x005D, // ']' U+005D RIGHT SQUARE BRACKET
  0x007D, // '}' U+007D RIGHT CURLY BRACKET
  0x276D, // '❭' U+276D MEDIUM RIGHT-POINTING ANGLE BRACKET ORNAMENT
  0x3000, // '　' U+3000 IDEOGRAPHIC SPACE (U+3000)
  0x3001, // '、' U+3001 IDEOGRAPHIC COMMA (U+3001)
  0x3002, // '。' U+3002 IDEOGRAPHIC FULL STOP (U+3002)
  0x3008, // '〈' U+3008 LEFT ANGLE BRACKET (U+3008)
  0x3009, // '〉' U+3009 RIGHT ANGLE BRACKET (U+3009)
  0x300A, // '《' U+300A LEFT DOUBLE ANGLE BRACKET (U+300A)
  0x300B, // '》' U+300B RIGHT DOUBLE ANGLE BRACKET (U+300B)
  0x300C, // '「' U+300C LEFT CORNER BRACKET (U+300C)
  0x300D, // '」' U+300D RIGHT CORNER BRACKET (U+300D)
  0x300E, // '『' U+300E LEFT WHITE CORNER BRACKET (U+300E)
  0x300F, // '』' U+300F RIGHT WHITE CORNER BRACKET (U+300F)
  0x3010, // '【' U+3010 LEFT BLACK LENTICULAR BRACKET (U+3010)
  0x3011, // '】' U+3011 RIGHT BLACK LENTICULAR BRACKET (U+3011)
  0x3014, // '〔' U+3014 LEFT TORTOISE SHELL BRACKET (U+3014)
  0x3015, // '〕' U+3015 RIGHT TORTOISE SHELL BRACKET (U+3015)
  0x3016, // '〖' U+3016 LEFT WHITE LENTICULAR BRACKET (U+3016)
  0x3017, // '〗' U+3017 RIGHT WHITE LENTICULAR BRACKET (U+3017)
  0x3018, // '〘' U+3018 LEFT WHITE TORTOISE SHELL BRACKET (U+3018)
  0x3019, // '〙' U+3019 RIGHT WHITE TORTOISE SHELL BRACKET (U+3019)
  0x301A, // '〚' U+301A LEFT WHITE SQUARE BRACKET (U+301A)
  0x301B, // '〛' U+301B RIGHT WHITE SQUARE BRACKET (U+301B)
  0x301C, // '〜' U+301C WAVE DASH (U+301C)
  0xFF09, // '）' U+FF09 FULLWIDTH RIGHT PARENTHESIS
  0xFF3D, // '］' U+FF3D FULLWIDTH RIGHT SQUARE BRACKET
  0xFF5D, // '｝' U+FF5D FULLWIDTH RIGHT CURLY BRACKET
  0xFF60, // '｠' U+FF60 FULLWIDTH RIGHT WHITE PARENTHESIS
  0xFF63, // '｣' U+FF63 HALFWIDTH RIGHT CORNER BRACKET
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
variable stack (sm->stack.data());

prepush {
  size_t len = sm->stack.size();

  if (len > MAX_STACK_DEPTH) {
    // Should never happen.
    throw DTextError("too many nested elements");
  }

  if (sm->top >= len) {
    g_debug("growing sm->stack %zi", len + 16);
    sm->stack.resize(len + 16, 0);
  }
}

action mark_a1 { sm->a1 = sm->p; }
action mark_a2 { sm->a2 = sm->p; }
action mark_b1 { sm->b1 = sm->p; }
action mark_b2 { sm->b2 = sm->p; }
action mark_c1 { sm->c1 = sm->p; }
action mark_c2 { sm->c2 = sm->p; }
action mark_d1 { sm->d1 = sm->p; }
action mark_d2 { sm->d2 = sm->p; }
action mark_e1 { sm->e1 = sm->p; }
action mark_e2 { sm->e2 = sm->p; }

action after_mention_boundary { is_mention_boundary(p[-1]) }
action mentions_enabled { sm->options.f_mentions }
action in_quote { dstack_is_open(sm, BLOCK_QUOTE) }
action in_expand { dstack_is_open(sm, BLOCK_EXPAND) }
action save_tag_attribute { save_tag_attribute(sm, { sm->a1, sm->a2 }, { sm->b1, sm->b2 }); }

# Matches the beginning or the end of the string. The input string has null bytes prepended and appended to mark the ends of the string.
eos = '\0';

newline = '\r\n' | '\n';
ws = ' ' | '\t';
eol = newline | eos;
blank_line = ws* eol;
blank_lines = blank_line{2,};

asciichar = 0x00..0x7F;
utf8char  = 0xC2..0xDF 0x80..0xBF
          | 0xE0..0xEF 0x80..0xBF 0x80..0xBF
          | 0xF0..0xF4 0x80..0xBF 0x80..0xBF 0x80..0xBF;
char = asciichar | utf8char;

# Characters that can't be the first or last character in a @-mention.
utf8_boundary_char =
  0xE2 0x9D 0xAD | # '❭' U+276D MEDIUM RIGHT-POINTING ANGLE BRACKET ORNAMENT
  0xE3 0x80 0x80 | # '　' U+3000 IDEOGRAPHIC SPACE (U+3000)
  0xE3 0x80 0x81 | # '、' U+3001 IDEOGRAPHIC COMMA (U+3001)
  0xE3 0x80 0x82 | # '。' U+3002 IDEOGRAPHIC FULL STOP (U+3002)
  0xE3 0x80 0x88 | # '〈' U+3008 LEFT ANGLE BRACKET (U+3008)
  0xE3 0x80 0x89 | # '〉' U+3009 RIGHT ANGLE BRACKET (U+3009)
  0xE3 0x80 0x8A | # '《' U+300A LEFT DOUBLE ANGLE BRACKET (U+300A)
  0xE3 0x80 0x8B | # '》' U+300B RIGHT DOUBLE ANGLE BRACKET (U+300B)
  0xE3 0x80 0x8C | # '「' U+300C LEFT CORNER BRACKET (U+300C)
  0xE3 0x80 0x8D | # '」' U+300D RIGHT CORNER BRACKET (U+300D)
  0xE3 0x80 0x8E | # '『' U+300E LEFT WHITE CORNER BRACKET (U+300E)
  0xE3 0x80 0x8F | # '』' U+300F RIGHT WHITE CORNER BRACKET (U+300F)
  0xE3 0x80 0x90 | # '【' U+3010 LEFT BLACK LENTICULAR BRACKET (U+3010)
  0xE3 0x80 0x91 | # '】' U+3011 RIGHT BLACK LENTICULAR BRACKET (U+3011)
  0xE3 0x80 0x94 | # '〔' U+3014 LEFT TORTOISE SHELL BRACKET (U+3014)
  0xE3 0x80 0x95 | # '〕' U+3015 RIGHT TORTOISE SHELL BRACKET (U+3015)
  0xE3 0x80 0x96 | # '〖' U+3016 LEFT WHITE LENTICULAR BRACKET (U+3016)
  0xE3 0x80 0x97 | # '〗' U+3017 RIGHT WHITE LENTICULAR BRACKET (U+3017)
  0xE3 0x80 0x98 | # '〘' U+3018 LEFT WHITE TORTOISE SHELL BRACKET (U+3018)
  0xE3 0x80 0x99 | # '〙' U+3019 RIGHT WHITE TORTOISE SHELL BRACKET (U+3019)
  0xE3 0x80 0x9A | # '〚' U+301A LEFT WHITE SQUARE BRACKET (U+301A)
  0xE3 0x80 0x9B | # '〛' U+301B RIGHT WHITE SQUARE BRACKET (U+301B)
  0xE3 0x80 0x9C | # '〜' U+301C WAVE DASH (U+301C)
  0xEF 0xBC 0x89 | # '）' U+FF09 FULLWIDTH RIGHT PARENTHESIS
  0xEF 0xBC 0xBD | # '］' U+FF3D FULLWIDTH RIGHT SQUARE BRACKET
  0xEF 0xBD 0x9D | # '｝' U+FF5D FULLWIDTH RIGHT CURLY BRACKET
  0xEF 0xBD 0xA0 | # '｠' U+FF60 FULLWIDTH RIGHT WHITE PARENTHESIS
  0xEF 0xBD 0xA3 ; # '｣' U+FF63 HALFWIDTH RIGHT CORNER BRACKET

nonspace = ^space - eos;
nonnewline = any - (newline | '\r');
nonbracket = ^']';
nonpipe = ^'|';
nonpipebracket = nonpipe & nonbracket;

# A bare @-mention (e.g. `@username`):
#
# * Can only appear after a space or one of the following characters: / " \ ( ) [ ] { }
# * Can't start or end with a punctuation character (either ASCII or Unicode).
# ** Exception: it can start with `_` or `.`, as long the next character is a non-punctuation character (this is to grandfather in names like @.Dank or @_cf).
# * Can't contain punctuation characters, except for . _ / ' - + !
# * Can't end in "'s" or "'d" (to allow `@kia'ra`, but not `@user's`).
# * The second character can't be '@' (to avoid emoticons like '@_@').
# * Must be at least two characters long.

mention_nonboundary_char = char - punct - space - eos - utf8_boundary_char;
mention_char = nonspace - (punct - [._/'\-+!]);
bare_username = ([_.]? mention_nonboundary_char mention_char* mention_nonboundary_char) - (char '@') - (char* '\'' [sd]);

bare_mention = ('@' when after_mention_boundary) (bare_username >mark_a1 @mark_a2);
delimited_mention = '<@' (nonspace nonnewline*) >mark_a1 %mark_a2 :>> '>';

url = 'http'i 's'i? '://' nonspace+;
delimited_url = '<' url >mark_a1 %mark_a2 :>> '>';
relative_url = [/#] nonspace*;
basic_textile_link = '"' ^'"'+ >mark_a1 %mark_a2 '"' ':' (url | relative_url) >mark_b1 %mark_b2;
bracketed_textile_link = '"' ^'"'+ >mark_a1 %mark_a2 '"' ':[' (url | relative_url) >mark_b1 %mark_b2 :>> ']';

# XXX: internal markdown links aren't allowed to avoid parsing closing tags as links: `[b]foo[/b](bar)`.
markdown_link = '[' url >mark_a1 %mark_a2 :>> '](' nonnewline+ >mark_b1 %mark_b2 :>> ')';
html_link = '<a'i ws+ 'href="'i (url | relative_url) >mark_a1 %mark_a2 :>> '">' nonnewline+ >mark_b1 %mark_b2 :>> '</a>'i;

emoticon_tags = '|' alnum | ':|' | '|_|' | '||_||' | '\\||/' | '<|>_<|>' | '>:|' | '>|3' | '|w|' | ':{' | ':}';
wiki_prefix = alnum* >mark_a1 %mark_a2;
wiki_suffix = alnum* >mark_e1 %mark_e2;
wiki_target = (nonpipebracket* (nonpipebracket - space) | emoticon_tags) >mark_b1 %mark_b2;
wiki_anchor_id = ([A-Z] ([ _\-]* alnum+)*) >mark_c1 %mark_c2;
wiki_title = (ws* (nonpipebracket - space)+)* >mark_d1 %mark_d2;

basic_wiki_link = wiki_prefix '[[' ws* wiki_target ws* :>> ('#' wiki_anchor_id ws*)? ']]' wiki_suffix;
aliased_wiki_link = wiki_prefix '[[' ws* wiki_target ws* :>> ('#' wiki_anchor_id ws*)? '|' ws* wiki_title ws* ']]' wiki_suffix;

tag = (nonspace - [|{}])+ | ([~\-]? emoticon_tags);
tags = (tag (ws+ tag)*) >mark_b1 %mark_b2;
search_title = ((nonnewline* nonspace) -- '}')? >mark_c1 %mark_c2;
search_prefix = alnum* >mark_a1 %mark_a2;
search_suffix = alnum* >mark_d1 %mark_d2;

basic_post_search_link = search_prefix '{{' ws* tags ws* '}}' search_suffix;
aliased_post_search_link = search_prefix '{{' ws* tags ws* '|' ws* search_title ws* '}}' search_suffix;

id = digit+ >mark_a1 %mark_a2;
alnum_id = alnum+ >mark_a1 %mark_a2;
page = digit+ >mark_b1 %mark_b2;
dmail_key = (alnum | '=' | '-')+ >mark_b1 %mark_b2;

header_id = (alnum | [_/#!:&\-])+; # XXX '/', '#', '!', ':', and '&' are grandfathered in for old wiki versions.
header = 'h'i [123456] >mark_a1 %mark_a2 '.' >mark_b1 >mark_b2 ws*;
header_with_id = 'h'i [123456] >mark_a1 %mark_a2 '#' header_id >mark_b1 %mark_b2 '.' ws*;
aliased_expand = ('[expand'i (ws* '=' ws* | ws+) ((nonnewline - ']')* >mark_a1 %mark_a2) ']')
               | ('<expand'i (ws* '=' ws* | ws+) ((nonnewline - '>')* >mark_a1 %mark_a2) '>');

list_item = '*'+ >mark_a1 %mark_a2 ws+ nonnewline+ >mark_b1 %mark_b2;

hr = ws* ('[hr]'i | '<hr>'i) ws* eol+;

code_fence = ('```' ws* (alnum* >mark_a1 %mark_a2) ws* eol) (any* >mark_b1 %mark_b2) :>> (eol '```' ws* eol);

double_quoted_value = '"' (nonnewline+ >mark_b1 %mark_b2) :>> '"';
single_quoted_value = "'" (nonnewline+ >mark_b1 %mark_b2) :>> "'";
unquoted_value = alnum+ >mark_b1 %mark_b2;
tag_attribute_value = double_quoted_value | single_quoted_value | unquoted_value;
tag_attribute = ws+ (alnum+ >mark_a1 %mark_a2) ws* '=' ws* tag_attribute_value %save_tag_attribute;
tag_attributes = tag_attribute*;

open_spoilers = ('[spoiler'i 's'i? ']') | ('<spoiler'i 's'i? '>');
open_nodtext = '[nodtext]'i | '<nodtext>'i;
open_quote = '[quote]'i | '<quote>'i | '<blockquote>'i;
open_expand = '[expand]'i | '<expand>'i;
open_code = '[code]'i | '<code>'i;
open_code_lang = '[code'i ws* '=' ws* (alnum+ >mark_a1 %mark_a2) ']' | '<code'i ws* '=' ws* (alnum+ >mark_a1 %mark_a2) '>';
open_table = '[table]'i | '<table>'i;
open_colgroup = '[colgroup'i tag_attributes :>> ']' | '<colgroup'i tag_attributes :>> '>';
open_col = '[col'i tag_attributes :>> ']' | '<col'i tag_attributes :>> '>';
open_thead = '[thead'i tag_attributes :>> ']' | '<thead'i tag_attributes :>> '>';
open_tbody = '[tbody'i tag_attributes :>> ']' | '<tbody'i tag_attributes :>> '>';
open_tr = '[tr'i tag_attributes :>> ']' | '<tr'i tag_attributes :>> '>';
open_th = '[th'i tag_attributes :>> ']' | '<th'i tag_attributes :>> '>';
open_td = '[td'i tag_attributes :>> ']' | '<td'i tag_attributes :>> '>';

open_tn = '[tn]'i | '<tn>'i;
open_b = '[b]'i | '<b>'i | '<strong>'i;
open_i = '[i]'i | '<i>'i | '<em>'i;
open_s = '[s]'i | '<s>'i;
open_u = '[u]'i | '<u>'i;

close_spoilers = ('[/spoiler'i 's'i? ']') | ('</spoiler'i 's'i? '>');
close_nodtext = '[/nodtext]'i | '</nodtext>'i;
close_quote = '[/quote'i (']' when in_quote) | '</quote'i ('>' when in_quote) | '</blockquote'i (']' when in_quote);
close_expand = '[/expand'i (']' when in_expand) | '</expand'i ('>' when in_expand);
close_code = '[/code]'i | '</code>'i;
close_table = '[/table]'i | '</table>'i;
close_colgroup = '[/colgroup]'i | '</colgroup>'i;
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
  eos;
  any => { append_html_escaped(sm, fc); };
*|;

inline := |*
  'post #'i id             => { append_id_link(sm, "post", "post", "/posts/", { sm->a1, sm->a2 }); };
  'appeal #'i id           => { append_id_link(sm, "appeal", "post-appeal", "/post_appeals/", { sm->a1, sm->a2 }); };
  'flag #'i id             => { append_id_link(sm, "flag", "post-flag", "/post_flags/", { sm->a1, sm->a2 }); };
  'note #'i id             => { append_id_link(sm, "note", "note", "/notes/", { sm->a1, sm->a2 }); };
  'forum #'i id            => { append_id_link(sm, "forum", "forum-post", "/forum_posts/", { sm->a1, sm->a2 }); };
  'topic #'i id            => { append_id_link(sm, "topic", "forum-topic", "/forum_topics/", { sm->a1, sm->a2 }); };
  'comment #'i id          => { append_id_link(sm, "comment", "comment", "/comments/", { sm->a1, sm->a2 }); };
  'dmail #'i id            => { append_id_link(sm, "dmail", "dmail", "/dmails/", { sm->a1, sm->a2 }); };
  'pool #'i id             => { append_id_link(sm, "pool", "pool", "/pools/", { sm->a1, sm->a2 }); };
  'user #'i id             => { append_id_link(sm, "user", "user", "/users/", { sm->a1, sm->a2 }); };
  'artist #'i id           => { append_id_link(sm, "artist", "artist", "/artists/", { sm->a1, sm->a2 }); };
  'ban #'i id              => { append_id_link(sm, "ban", "ban", "/bans/", { sm->a1, sm->a2 }); };
  'bur #'i id              => { append_id_link(sm, "BUR", "bulk-update-request", "/bulk_update_requests/", { sm->a1, sm->a2 }); };
  'alias #'i id            => { append_id_link(sm, "alias", "tag-alias", "/tag_aliases/", { sm->a1, sm->a2 }); };
  'implication #'i id      => { append_id_link(sm, "implication", "tag-implication", "/tag_implications/", { sm->a1, sm->a2 }); };
  'favgroup #'i id         => { append_id_link(sm, "favgroup", "favorite-group", "/favorite_groups/", { sm->a1, sm->a2 }); };
  'mod action #'i id       => { append_id_link(sm, "mod action", "mod-action", "/mod_actions/", { sm->a1, sm->a2 }); };
  'modreport #'i id        => { append_id_link(sm, "modreport", "moderation-report", "/moderation_reports/", { sm->a1, sm->a2 }); };
  'feedback #'i id         => { append_id_link(sm, "feedback", "user-feedback", "/user_feedbacks/", { sm->a1, sm->a2 }); };
  'wiki #'i id             => { append_id_link(sm, "wiki", "wiki-page", "/wiki_pages/", { sm->a1, sm->a2 }); };

  'issue #'i id            => { append_id_link(sm, "issue", "github", "https://github.com/danbooru/danbooru/issues/", { sm->a1, sm->a2 }); };
  'pull #'i id             => { append_id_link(sm, "pull", "github-pull", "https://github.com/danbooru/danbooru/pull/", { sm->a1, sm->a2 }); };
  'commit #'i id           => { append_id_link(sm, "commit", "github-commit", "https://github.com/danbooru/danbooru/commit/", { sm->a1, sm->a2 }); };
  'artstation #'i alnum_id => { append_id_link(sm, "artstation", "artstation", "https://www.artstation.com/artwork/", { sm->a1, sm->a2 }); };
  'deviantart #'i id       => { append_id_link(sm, "deviantart", "deviantart", "https://www.deviantart.com/deviation/", { sm->a1, sm->a2 }); };
  'nijie #'i id            => { append_id_link(sm, "nijie", "nijie", "https://nijie.info/view.php?id=", { sm->a1, sm->a2 }); };
  'pawoo #'i id            => { append_id_link(sm, "pawoo", "pawoo", "https://pawoo.net/web/statuses/", { sm->a1, sm->a2 }); };
  'pixiv #'i id            => { append_id_link(sm, "pixiv", "pixiv", "https://www.pixiv.net/artworks/", { sm->a1, sm->a2 }); };
  'seiga #'i id            => { append_id_link(sm, "seiga", "seiga", "https://seiga.nicovideo.jp/seiga/im", { sm->a1, sm->a2 }); };
  'twitter #'i id          => { append_id_link(sm, "twitter", "twitter", "https://twitter.com/i/web/status/", { sm->a1, sm->a2 }); };

  'yandere #'i id => { append_id_link(sm, "yandere", "yandere", "https://yande.re/post/show/", { sm->a1, sm->a2 }); };
  'sankaku #'i id => { append_id_link(sm, "sankaku", "sankaku", "https://chan.sankakucomplex.com/post/show/", { sm->a1, sm->a2 }); };
  'gelbooru #'i id => { append_id_link(sm, "gelbooru", "gelbooru", "https://gelbooru.com/index.php?page=post&s=view&id=", { sm->a1, sm->a2 }); };

  'dmail #'i id '/' dmail_key => { append_dmail_key_link(sm); };

  'topic #'i id '/p'i page => { append_paged_link(sm, "topic #", "<a class=\"dtext-link dtext-id-link dtext-forum-topic-id-link\" href=\"", "/forum_topics/", "?page="); };
  'pixiv #'i id '/p'i page => { append_paged_link(sm, "pixiv #", "<a rel=\"external nofollow noreferrer\" class=\"dtext-link dtext-id-link dtext-pixiv-id-link\" href=\"", "https://www.pixiv.net/artworks/", "#"); };

  basic_post_search_link => {
    append_post_search_link(sm, { sm->a1, sm->a2 }, { sm->b1, sm->b2 }, { sm->b1, sm->b2 }, { sm->d1, sm->d2 });
  };

  aliased_post_search_link => {
    append_post_search_link(sm, { sm->a1, sm->a2 }, { sm->b1, sm->b2 }, { sm->c1, sm->c2 }, { sm->d1, sm->d2 });
  };

  basic_wiki_link => {
    append_wiki_link(sm, { sm->a1, sm->a2 }, { sm->b1, sm->b2 }, { sm->c1, sm->c2 }, { sm->b1, sm->b2 }, { sm->e1, sm->e2 });
  };

  aliased_wiki_link => {
    append_wiki_link(sm, { sm->a1, sm->a2 }, { sm->b1, sm->b2 }, { sm->c1, sm->c2 }, { sm->d1, sm->d2 }, { sm->e1, sm->e2 });
  };

  basic_textile_link => {
    append_bare_named_url(sm, { sm->b1, sm->b2 }, { sm->a1, sm->a2 });
  };

  bracketed_textile_link => {
    append_named_url(sm, { sm->b1, sm->b2 }, { sm->a1, sm->a2 });
  };

  markdown_link | html_link => {
    append_named_url(sm, { sm->a1, sm->a2 }, { sm->b1, sm->b2 });
  };

  url => {
    append_bare_unnamed_url(sm, { sm->ts, sm->te });
  };

  delimited_url => {
    append_unnamed_url(sm, { sm->a1, sm->a2 });
  };

  bare_mention when mentions_enabled => {
    append_mention(sm, { sm->a1, sm->a2 + 1 });
  };

  delimited_mention when mentions_enabled => {
    g_debug("delimited mention: <@%.*s>", (int)(sm->a2 - sm->a1), sm->a1);
    append_mention(sm, { sm->a1, sm->a2 });
  };

  newline list_item => {
    g_debug("inline list");
    fexec sm->ts + 1;
    fret;
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

  newline* close_tn => {
    g_debug("inline [/tn]");

    if (dstack_check(sm, INLINE_TN)) {
      dstack_close_inline(sm, INLINE_TN, "</span>");
    } else if (dstack_close_block(sm, BLOCK_TN, "</p>")) {
      fret;
    }
  };

  open_code blank_line? => {
    append_inline_code(sm);
    fcall code;
  };

  open_code_lang blank_line? => {
    append_inline_code(sm, { sm->a1, sm->a2 });
    fcall code;
  };

  newline code_fence => {
    dstack_close_leaf_blocks(sm);
    fexec sm->ts;
    fret;
  };

  newline ws* open_spoilers ws* eol => {
    dstack_close_leaf_blocks(sm);
    fexec sm->ts;
    fret;
  };

  open_spoilers => {
    dstack_open_inline(sm, INLINE_SPOILER, "<span class=\"spoiler\">");
  };

  newline? close_spoilers => {
    if (dstack_check(sm, INLINE_SPOILER)) {
      dstack_close_inline(sm, INLINE_SPOILER, "</span>");
    } else if (dstack_is_open(sm, BLOCK_SPOILER)) {
      dstack_close_until(sm, BLOCK_SPOILER);
      fret;
    } else {
      append_html_escaped(sm, { sm->ts, sm->te });
    }
  };

  open_nodtext blank_line? => {
    dstack_open_inline(sm, INLINE_NODTEXT, "");
    fcall nodtext;
  };
  
  # these are block level elements that should kick us out of the inline
  # scanner

  newline (open_code | open_code_lang | open_nodtext) => {
    dstack_close_leaf_blocks(sm);
    fexec sm->ts;
    fret;
  };

  newline (header | header_with_id) => {
    dstack_close_leaf_blocks(sm);
    fexec sm->ts;
    fret;
  };

  open_quote => {
    g_debug("inline [quote]");
    dstack_close_leaf_blocks(sm);
    fexec sm->ts;
    fret;
  };

  newline? close_quote ws* => {
    g_debug("inline [/quote]");
    dstack_close_until(sm, BLOCK_QUOTE);
    fret;
  };

  (open_expand | aliased_expand) => {
    g_debug("inline [expand]");
    dstack_close_leaf_blocks(sm);
    fexec sm->ts;
    fret;
  };

  newline? close_expand ws* => {
    g_debug("inline [/expand]");
    dstack_close_until(sm, BLOCK_EXPAND);
    fret;
  };

  newline ws* open_table => {
    dstack_close_leaf_blocks(sm);
    fexec sm->ts;
    fret;
  };

  newline* close_th => {
    if (dstack_close_block(sm, BLOCK_TH, "</th>")) {
      fret;
    }
  };

  newline* close_td => {
    if (dstack_close_block(sm, BLOCK_TD, "</td>")) {
      fret;
    }
  };

  newline hr => {
    g_debug("inline [hr] (pos: %ld)", sm->ts - sm->pb);
    dstack_close_leaf_blocks(sm);
    fexec sm->ts;
    fret;
  };

  blank_lines => {
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
    } else if (dstack_is_open(sm, BLOCK_UL)) {
      dstack_close_list(sm);
      fret;
    } else {
      append(sm, "<br>");
    }
  };

  '\r' => {
    append(sm, ' ');
  };

  eos;

  alnum+ | utf8char+ => {
    append(sm, std::string_view { sm->ts, sm->te });
  };

  any => {
    append_html_escaped(sm, fc);
  };
*|;

code := |*
  newline? close_code => {
    dstack_rewind(sm);
    fret;
  };

  eos;

  any => {
    append_html_escaped(sm, fc);
  };
*|;

nodtext := |*
  newline? close_nodtext => {
    dstack_rewind(sm);
    fret;
  };

  eos;

  any => {
    append_html_escaped(sm, fc);
  };
*|;

table := |*
  open_colgroup => {
    dstack_open_block(sm, BLOCK_COLGROUP, "colgroup", sm->tag_attributes);
  };

  close_colgroup => {
    dstack_close_block(sm, BLOCK_COLGROUP, "</colgroup>");
  };

  open_col => {
    dstack_open_block(sm, BLOCK_COL, "col", sm->tag_attributes);
    dstack_pop(sm); // XXX [col] has no end tag
  };

  open_thead => {
    dstack_open_block(sm, BLOCK_THEAD, "thead", sm->tag_attributes);
  };

  close_thead => {
    dstack_close_block(sm, BLOCK_THEAD, "</thead>");
  };

  open_tbody => {
    dstack_open_block(sm, BLOCK_TBODY, "tbody", sm->tag_attributes);
  };

  close_tbody => {
    dstack_close_block(sm, BLOCK_TBODY, "</tbody>");
  };

  open_th => {
    dstack_open_block(sm, BLOCK_TH, "th", sm->tag_attributes);
    fcall inline;
  };

  open_tr => {
    dstack_open_block(sm, BLOCK_TR, "tr", sm->tag_attributes);
  };

  close_tr => {
    dstack_close_block(sm, BLOCK_TR, "</tr>");
  };

  open_td => {
    dstack_open_block(sm, BLOCK_TD, "td", sm->tag_attributes);
    fcall inline;
  };

  close_table => {
    if (dstack_close_block(sm, BLOCK_TABLE, "</table>")) {
      fret;
    }
  };

  any;
*|;

main := |*
  header | header_with_id => {
    append_header(sm, *sm->a1, { sm->b1, sm->b2 });
    fcall inline;
  };

  open_quote space* => {
    dstack_close_leaf_blocks(sm);
    dstack_open_block(sm, BLOCK_QUOTE, "<blockquote>");
  };

  open_spoilers space* => {
    dstack_close_leaf_blocks(sm);
    dstack_open_block(sm, BLOCK_SPOILER, "<div class=\"spoiler\">");
  };

  open_code blank_line? => {
    append_block_code(sm);
    fcall code;
  };

  open_code_lang blank_line? => {
    append_block_code(sm, { sm->a1, sm->a2 });
    fcall code;
  };

  code_fence => {
    append_code_fence(sm, { sm->b1, sm->b2 }, { sm->a1, sm->a2 });
  };

  open_expand space* => {
    dstack_close_leaf_blocks(sm);
    dstack_open_block(sm, BLOCK_EXPAND, "<details>");
    append(sm, "<summary>Show</summary><div>");
  };

  aliased_expand space* => {
    g_debug("block [expand=]");
    dstack_close_leaf_blocks(sm);
    dstack_open_block(sm, BLOCK_EXPAND, "<details>");
    append(sm, "<summary>");
    append_html_escaped(sm, { sm->a1, sm->a2 });
    append(sm, "</summary><div>");
  };

  open_nodtext blank_line? => {
    dstack_close_leaf_blocks(sm);
    dstack_open_block(sm, BLOCK_NODTEXT, "<p>");
    fcall nodtext;
  };

  ws* open_table => {
    dstack_close_leaf_blocks(sm);
    dstack_open_block(sm, BLOCK_TABLE, "<table class=\"striped\">");
    fcall table;
  };

  open_tn => {
    dstack_open_block(sm, BLOCK_TN, "<p class=\"tn\">");
    fcall inline;
  };

  hr => {
    g_debug("write '<hr>' (pos: %ld)", sm->ts - sm->pb);
    append(sm, "<hr>");
  };

  list_item => {
    g_debug("block list");
    dstack_open_list(sm, sm->a2 - sm->a1);
    fexec sm->b1;
    fcall inline;
  };

  blank_lines => {
    g_debug("block newline2");

    if (sm->header_mode) {
      sm->header_mode = false;
      dstack_rewind(sm);
    } else if (dstack_is_open(sm, BLOCK_UL)) {
      dstack_close_until(sm, BLOCK_UL);
    } else {
      dstack_close_before_block(sm);
    }

    if (sm->options.f_inline) {
      append(sm, " ");
    }
  };

  newline => {
    g_debug("block newline");
  };

  eos;

  any => {
    g_debug("block char");
    fhold;

    if (sm->dstack.empty() || dstack_check(sm, BLOCK_QUOTE) || dstack_check(sm, BLOCK_SPOILER) || dstack_check(sm, BLOCK_EXPAND)) {
      dstack_open_block(sm, BLOCK_P, "<p>");
    }

    fcall inline;
  };
*|;

}%%

%% write data;

static void dstack_push(StateMachine * sm, element_t element) {
  sm->dstack.push_back(element);
}

static element_t dstack_pop(StateMachine * sm) {
  if (sm->dstack.empty()) {
    g_debug("dstack pop empty stack");
    return DSTACK_EMPTY;
  } else {
    auto element = sm->dstack.back();
    sm->dstack.pop_back();
    return element;
  }
}

static element_t dstack_peek(const StateMachine * sm) {
  return sm->dstack.empty() ? DSTACK_EMPTY : sm->dstack.back();
}

static bool dstack_check(const StateMachine * sm, element_t expected_element) {
  return dstack_peek(sm) == expected_element;
}

// Return true if the given tag is currently open.
static bool dstack_is_open(const StateMachine * sm, element_t element) {
  return std::find(sm->dstack.begin(), sm->dstack.end(), element) != sm->dstack.end();
}

static int dstack_count(const StateMachine * sm, element_t element) {
  return std::count(sm->dstack.begin(), sm->dstack.end(), element);
}

static bool is_internal_url(StateMachine * sm, const std::string_view url) {
  if (url.starts_with("/")) {
    return true;
  } else if (sm->options.domain.empty() || url.empty()) {
    return false;
  } else {
    // Matches the domain name part of a URL.
    static const std::regex url_regex("^https?://(?:[^/?#]*@)?([^/?#:]+)", std::regex_constants::icase);

    std::match_results<std::string_view::const_iterator> matches;
    std::regex_search(url.begin(), url.end(), matches, url_regex);
    return matches[1] == sm->options.domain;
  }
}

static void append(StateMachine * sm, const auto c) {
  sm->output += c;
}

static void append(StateMachine * sm, const char * a, const char * b) {
  append(sm, std::string_view(a, b));
}

static void append_html_escaped(StateMachine * sm, char s) {
  switch (s) {
    case '<': append(sm, "&lt;"); break;
    case '>': append(sm, "&gt;"); break;
    case '&': append(sm, "&amp;"); break;
    case '"': append(sm, "&quot;"); break;
    default:  append(sm, s);
  }
}

static void append_html_escaped(StateMachine * sm, const std::string_view string) {
  for (const unsigned char c : string) {
    append_html_escaped(sm, c);
  }
}

static void append_uri_escaped(StateMachine * sm, const std::string_view string) {
  static const char hex[] = "0123456789ABCDEF";

  for (const unsigned char c : string) {
    if ((c >= '0' && c <= '9') || (c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') || c == '-' || c == '_' || c == '.' || c == '~') {
      append(sm, c);
    } else {
      append(sm, '%');
      append(sm, hex[c >> 4]);
      append(sm, hex[c & 0x0F]);
    }
  }
}

static void append_relative_url(StateMachine * sm, const auto url) {
  if ((url[0] == '/' || url[0] == '#') && !sm->options.base_url.empty()) {
    append_html_escaped(sm, sm->options.base_url);
  }

  append_html_escaped(sm, url);
}

static void append_absolute_link(StateMachine * sm, const std::string_view url, const std::string_view title, bool internal_url, bool escape_title) {
  if (internal_url) {
    append(sm, "<a class=\"dtext-link\" href=\"");
  } else if (url == title) {
    append(sm, "<a rel=\"external nofollow noreferrer\" class=\"dtext-link dtext-external-link\" href=\"");
  } else {
    append(sm, "<a rel=\"external nofollow noreferrer\" class=\"dtext-link dtext-external-link dtext-named-external-link\" href=\"");
  }

  append_html_escaped(sm, url);
  append(sm, "\">");

  if (escape_title) {
    append_html_escaped(sm, title);
  } else {
    append(sm, title);
  }

  append(sm, "</a>");
}

static void append_mention(StateMachine * sm, const std::string_view name) {
  append(sm, "<a class=\"dtext-link dtext-user-mention-link\" data-user-name=\"");
  append_html_escaped(sm, name);
  append(sm, "\" href=\"");
  append_relative_url(sm, "/users?name=");
  append_uri_escaped(sm, name);
  append(sm, "\">@");
  append_html_escaped(sm, name);
  append(sm, "</a>");
}

static void append_id_link(StateMachine * sm, const char * title, const char * id_name, const char * url, const std::string_view id) {
  if (url[0] == '/') {
    append(sm, "<a class=\"dtext-link dtext-id-link dtext-");
    append(sm, id_name);
    append(sm, "-id-link\" href=\"");
    append_relative_url(sm, url);
  } else {
    append(sm, "<a rel=\"external nofollow noreferrer\" class=\"dtext-link dtext-id-link dtext-");
    append(sm, id_name);
    append(sm, "-id-link\" href=\"");
    append_html_escaped(sm, url);
  }

  append_uri_escaped(sm, id);
  append(sm, "\">");
  append(sm, title);
  append(sm, " #");
  append_html_escaped(sm, id);
  append(sm, "</a>");
}

static void append_bare_unnamed_url(StateMachine * sm, const std::string_view url) {
  const char* match_end = end(url);
  const char* url_start = begin(url);
  const char* url_end = find_boundary_c(match_end - 1) + 1;

  append_unnamed_url(sm, { url_start, url_end });

  if (url_end < match_end) {
    append_html_escaped(sm, { url_end, match_end });
  }
}

static void append_unnamed_url(StateMachine * sm, const std::string_view url) {
  DText::URL parsed_url(url);

  if (sm->options.internal_domains.find(std::string(parsed_url.domain)) != sm->options.internal_domains.end()) {
    append_internal_url(sm, parsed_url);
  } else {
    append_absolute_link(sm, url, url, parsed_url.domain == sm->options.domain);
  }
}

static void append_internal_url(StateMachine * sm, const DText::URL& url) {
  auto path_components = url.path_components();
  auto query = url.query;
  auto fragment = url.fragment;

  if (path_components.size() == 2) {
    auto controller = path_components.at(0);
    auto id = path_components.at(1);

    if (!id.empty() && std::all_of(id.begin(), id.end(), ::isdigit)) {
      if (controller == "posts" && fragment.empty()) {
        // https://danbooru.donmai.us/posts/6000000#comment_2288996
        return append_id_link(sm, "post", "post", "/posts/", id);
      } else if (controller == "pools" && query.empty()) {
        // https://danbooru.donmai.us/pools/903?page=2
        return append_id_link(sm, "pool", "pool", "/pools/", id);
      } else if (controller == "comments") {
        return append_id_link(sm, "comment", "comment", "/comments/", id);
      } else if (controller == "forum_posts") {
        return append_id_link(sm, "forum", "forum-post", "/forum_posts/", id);
      } else if (controller == "forum_topics" && query.empty() && fragment.empty()) {
        // https://danbooru.donmai.us/forum_topics/1234?page=2
        // https://danbooru.donmai.us/forum_topics/1234#forum_post_5678
        return append_id_link(sm, "topic", "forum-topic", "/forum_topics/", id);
      } else if (controller == "users") {
        return append_id_link(sm, "user", "user", "/users/", id);
      } else if (controller == "artists") {
        return append_id_link(sm, "artist", "artist", "/artists/", id);
      } else if (controller == "notes") {
        return append_id_link(sm, "note", "note", "/notes/", id);
      } else if (controller == "favorite_groups" && query.empty()) {
        // https://danbooru.donmai.us/favorite_groups/1234?page=2
        return append_id_link(sm, "favgroup", "favorite-group", "/favorite_groups/", id);
      } else if (controller == "wiki_pages" && fragment.empty()) {
        // http://danbooru.donmai.us/wiki_pages/10933#dtext-self-upload
        return append_id_link(sm, "wiki", "wiki-page", "/wiki_pages/", id);
      }
    } else if (controller == "wiki_pages" && fragment.empty()) {
      return append_wiki_link(sm, {}, id, {}, id, {});
    }
  } else if (path_components.size() >= 3) {
    // http://danbooru.donmai.us/post/show/1234/touhou
    auto controller = path_components.at(0);
    auto action = path_components.at(1);
    auto id = path_components.at(2);

    if (!id.empty() && std::all_of(id.begin(), id.end(), ::isdigit)) {
      if (controller == "post" && action == "show") {
        return append_id_link(sm, "post", "post", "/posts/", id);
      }
    }
  }

  append_absolute_link(sm, url.url, url.url, url.domain == sm->options.domain);
}

static void append_named_url(StateMachine * sm, const std::string_view url, const std::string_view title) {
  auto parsed_title = sm->parse_basic_inline(title);

  // protocol-relative url; treat `//example.com` like `http://example.com`
  if (url.size() > 2 && url.starts_with("//")) {
    auto full_url = "http:" + std::string(url);
    append_absolute_link(sm, full_url, parsed_title, is_internal_url(sm, full_url), false);
  } else if (url[0] == '/' || url[0] == '#') {
    append(sm, "<a class=\"dtext-link\" href=\"");
    append_relative_url(sm, url);
    append(sm, "\">");
    append(sm, parsed_title);
    append(sm, "</a>");
  } else if (url == title) {
    append_unnamed_url(sm, url);
  } else {
    append_absolute_link(sm, url, parsed_title, is_internal_url(sm, url), false);
  }
}

static void append_bare_named_url(StateMachine * sm, const std::string_view url, const std::string_view title) {
  const char* match_end = end(url);
  const char* url_start = begin(url);
  const char* url_end = find_boundary_c(match_end - 1) + 1;

  append_named_url(sm, { url_start, url_end }, title);

  if (url_end < match_end) {
    append_html_escaped(sm, { url_end, match_end });
  }
}

static void append_post_search_link(StateMachine * sm, const std::string_view prefix, const std::string_view search, const std::string_view title, const std::string_view suffix) {
  auto normalized_title = std::string(title);

  append(sm, "<a class=\"dtext-link dtext-post-search-link\" href=\"");
  append_relative_url(sm, "/posts?tags=");
  append_uri_escaped(sm, search);
  append(sm, "\">");

  // 19{{60s}} -> {{60s|1960s}}
  if (!prefix.empty()) {
    normalized_title.insert(0, prefix);
  }

  // {{pokemon_(creature)|}} -> {{pokemon_(creature)|pokemon}}
  if (title.empty()) {
    std::regex_replace(std::back_inserter(normalized_title), search.begin(), search.end(), tag_qualifier_regex, "");
  }

  // {{cat}}s -> {{cat|cats}}
  if (!suffix.empty()) {
    normalized_title.append(suffix);
  }

  append_html_escaped(sm, normalized_title);
  append(sm, "</a>");

  clear_matches(sm);
}

static void append_wiki_link(StateMachine * sm, const std::string_view prefix, const std::string_view tag, const std::string_view anchor, const std::string_view title, const std::string_view suffix) {
  auto normalized_tag = std::string(tag);
  auto title_string = std::string(title);

  // "Kantai Collection" -> "kantai_collection"
  std::transform(normalized_tag.cbegin(), normalized_tag.cend(), normalized_tag.begin(), [](unsigned char c) { return c == ' ' ? '_' : std::tolower(c); });

  // [[2019]] -> [[~2019]]
  if (std::all_of(normalized_tag.cbegin(), normalized_tag.cend(), ::isdigit)) {
    normalized_tag.insert(0, "~");
  }

  // Pipe trick: [[Kaga (Kantai Collection)|]] -> [[kaga_(kantai_collection)|Kaga]]
  if (title_string.empty()) {
    std::regex_replace(std::back_inserter(title_string), tag.cbegin(), tag.cend(), tag_qualifier_regex, "");
  }

  // 19[[60s]] -> [[60s|1960s]]
  if (!prefix.empty()) {
    title_string.insert(0, prefix);
  }

  // [[cat]]s -> [[cat|cats]]
  if (!suffix.empty()) {
    title_string.append(suffix);
  }

  append(sm, "<a class=\"dtext-link dtext-wiki-link\" href=\"");
  append_relative_url(sm, "/wiki_pages/");
  append_uri_escaped(sm, normalized_tag);

  if (!anchor.empty()) {
    std::string normalized_anchor(anchor);
    std::transform(normalized_anchor.begin(), normalized_anchor.end(), normalized_anchor.begin(), [](char c) { return isalnum(c) ? tolower(c) : '-'; });
    append_html_escaped(sm, "#dtext-");
    append_html_escaped(sm, normalized_anchor);
  }

  append(sm, "\">");
  append_html_escaped(sm, title_string);
  append(sm, "</a>");

  sm->wiki_pages.insert(std::string(tag));

  clear_matches(sm);
}

static void append_paged_link(StateMachine * sm, const char * title, const char * tag, const char * href, const char * param) {
  append(sm, tag);
  append_relative_url(sm, href);
  append(sm, sm->a1, sm->a2);
  append(sm, param);
  append(sm, sm->b1, sm->b2);
  append(sm, "\">");
  append(sm, title);
  append(sm, sm->a1, sm->a2);
  append(sm, "/p");
  append(sm, sm->b1, sm->b2);
  append(sm, "</a>");
}

static void append_dmail_key_link(StateMachine * sm) {
  append(sm, "<a class=\"dtext-link dtext-id-link dtext-dmail-id-link\" href=\"");
  append_relative_url(sm, "/dmails/");
  append(sm, sm->a1, sm->a2);
  append(sm, "?key=");
  append_uri_escaped(sm, { sm->b1, sm->b2 });
  append(sm, "\">");
  append(sm, "dmail #");
  append(sm, sm->a1, sm->a2);
  append(sm, "</a>");
}

static void append_code_fence(StateMachine * sm, const std::string_view code, const std::string_view language) {
  if (language.empty()) {
    append_block(sm, "<pre>");
    append_html_escaped(sm, code);
    append_block(sm, "</pre>");
  } else {
    append_block(sm, "<pre data-language=\"");
    append_html_escaped(sm, language);
    append_block(sm, "\">");
    append_html_escaped(sm, code);
    append_block(sm, "</pre>");
  }
}

static void append_inline_code(StateMachine * sm, const std::string_view language = {}) {
  if (language.empty()) {
    dstack_open_inline(sm, INLINE_CODE, "<code>");
  } else {
    dstack_open_inline(sm, INLINE_CODE, "<code data-language=\"");
    append_html_escaped(sm, language);
    append(sm, "\">");
  }
}

static void append_block_code(StateMachine * sm, const std::string_view language = {}) {
  dstack_close_leaf_blocks(sm);

  if (language.empty()) {
    dstack_open_block(sm, BLOCK_CODE, "<pre>");
  } else {
    dstack_open_block(sm, BLOCK_CODE, "<pre data-language=\"");
    append_html_escaped(sm, language);
    append(sm, "\">");
  }
}

static void append_header(StateMachine * sm, char header, const std::string_view id) {
  static element_t blocks[] = { BLOCK_H1, BLOCK_H2, BLOCK_H3, BLOCK_H4, BLOCK_H5, BLOCK_H6 };
  element_t block = blocks[header - '1'];

  if (id.empty()) {
    dstack_open_block(sm, block, "<h");
    append_block(sm, header);
    append_block(sm, ">");
  } else {
    auto normalized_id = std::string(id);
    std::transform(id.begin(), id.end(), normalized_id.begin(), [](char c) { return isalnum(c) ? tolower(c) : '-'; });

    dstack_open_block(sm, block, "<h");
    append_block(sm, header);
    append_block(sm, " id=\"dtext-");
    append_block(sm, normalized_id);
    append_block(sm, "\">");
  }

  sm->header_mode = true;
}

static void append_block(StateMachine * sm, const auto s) {
  if (!sm->options.f_inline) {
    append(sm, s);
  }
}

static void append_block_html_escaped(StateMachine * sm, const std::string_view string) {
  if (!sm->options.f_inline) {
    append_html_escaped(sm, string);
  }
}

static void append_closing_p(StateMachine * sm) {
  g_debug("append closing p");

  if (sm->output.size() > 4 && sm->output.ends_with("<br>")) {
    g_debug("trim last <br>");
    sm->output.resize(sm->output.size() - 4);
  }

  if (sm->output.size() > 3 && sm->output.ends_with("<p>")) {
    g_debug("trim last <p>");
    sm->output.resize(sm->output.size() - 3);
    return;
  }

  append_block(sm, "</p>");
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

static void dstack_open_block(StateMachine * sm, element_t type, const std::string_view& tag_name, const StateMachine::TagAttributes& tag_attributes) {
  dstack_push(sm, type);
  append_block(sm, "<");
  append_block(sm, tag_name);

  auto& permitted_names = permitted_attribute_names.at(tag_name);
  for (auto& [name, value] : tag_attributes) {
    if (permitted_names.find(name) != permitted_names.end()) {
      auto validate_value = permitted_attribute_values.at(name);

      if (validate_value(value)) {
        append_block(sm, " ");
        append_block_html_escaped(sm, name);
        append_block(sm, "=\"");
        append_block_html_escaped(sm, value);
        append_block(sm, "\"");
      }
    }
  }

  append_block(sm, ">");
  clear_tag_attributes(sm);
}

static void dstack_close_inline(StateMachine * sm, element_t type, const char * close_html) {
  if (dstack_check(sm, type)) {
    g_debug("closing inline %s", close_html);

    dstack_pop(sm);
    append(sm, close_html);
  } else {
    g_debug("out-of-order closing %s", element_names[type]);

    append_html_escaped(sm, { sm->ts, sm->te });
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

    append_block_html_escaped(sm, { sm->ts, sm->te });
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
    case BLOCK_NODTEXT: append_block(sm, "</p>"); break;
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
    case BLOCK_COLGROUP: append_block(sm, "</colgroup>"); break;
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

    // Should never happen.
    case INLINE: break;
    case DSTACK_EMPTY: break;
  } 
}

// Close the last open paragraph or list, if there is one.
static void dstack_close_before_block(StateMachine * sm) {
  g_debug("dstack close before block");

  while (dstack_check(sm, BLOCK_P) || dstack_check(sm, BLOCK_LI) || dstack_check(sm, BLOCK_UL)) {
    dstack_rewind(sm);
  }
}

// container blocks: [spoiler], [quote], [expand], [tn]
// leaf blocks: [nodtext], [code], [table], [td]?, [th]?, <h1>, <p>, <li>, <ul>
static void dstack_close_leaf_blocks(StateMachine * sm) {
  g_debug("dstack close leaf blocks");

  while (!sm->dstack.empty() && !dstack_check(sm, BLOCK_QUOTE) && !dstack_check(sm, BLOCK_SPOILER) && !dstack_check(sm, BLOCK_EXPAND) && !dstack_check(sm, BLOCK_TN)) {
    dstack_rewind(sm);
  }

  sm->header_mode = false;
}

// Close all open tags up to and including the given tag.
static void dstack_close_until(StateMachine * sm, element_t element) {
  while (!sm->dstack.empty() && !dstack_check(sm, element)) {
    dstack_rewind(sm);
  }

  dstack_rewind(sm);
}

// Close all remaining open tags.
static void dstack_close_all(StateMachine * sm) {
  while (!sm->dstack.empty()) {
    dstack_rewind(sm);
  }
}

static void dstack_open_list(StateMachine * sm, int depth) {
  g_debug("open list");

  if (dstack_is_open(sm, BLOCK_LI)) {
    dstack_close_until(sm, BLOCK_LI);
  } else {
    dstack_close_leaf_blocks(sm);
  }

  while (dstack_count(sm, BLOCK_UL) < depth) {
    dstack_open_block(sm, BLOCK_UL, "<ul>");
  }

  while (dstack_count(sm, BLOCK_UL) > depth) {
    dstack_close_until(sm, BLOCK_UL);
  }

  dstack_open_block(sm, BLOCK_LI, "<li>");
}

static void dstack_close_list(StateMachine * sm) {
  while (dstack_is_open(sm, BLOCK_UL)) {
    dstack_close_until(sm, BLOCK_UL);
  }
}

static void save_tag_attribute(StateMachine * sm, const std::string_view name, const std::string_view value) {
  sm->tag_attributes[name] = value;
}

static void clear_tag_attributes(StateMachine * sm) {
  sm->tag_attributes.clear();
}

static void clear_matches(StateMachine * sm) {
  sm->a1 = NULL;
  sm->a2 = NULL;
  sm->b1 = NULL;
  sm->b2 = NULL;
  sm->c1 = NULL;
  sm->c2 = NULL;
  sm->d1 = NULL;
  sm->d2 = NULL;
  sm->e1 = NULL;
  sm->e2 = NULL;
}

// True if a mention is allowed to start after this character.
static bool is_mention_boundary(unsigned char c) {
  switch (c) {
    case '\0': return true;
    case '\r': return true;
    case '\n': return true;
    case ' ':  return true;
    case '/':  return true;
    case '"':  return true;
    case '\'': return true;
    case '(':  return true;
    case ')':  return true;
    case '[':  return true;
    case ']':  return true;
    case '{':  return true;
    case '}':  return true;
    default:   return false;
  }
}

static std::tuple<char32_t, int> get_utf8_char(const char* c) {
  const unsigned char* p = reinterpret_cast<const unsigned char*>(c);

  // 0x10xxxxxx is a continuation byte; back up to the leading byte.
  while ((p[0] >> 6) == 0b10) {
    p--;
  }

  if (p[0] >> 7 == 0) {
    // 0x0xxxxxxx
    return { p[0], 1 };
  } else if ((p[0] >> 5) == 0b110) {
    // 0x110xxxxx, 0x10xxxxxx
    return { ((p[0] & 0b00011111) << 6) | (p[1] & 0b00111111), 2 };
  } else if ((p[0] >> 4) == 0b1110) {
    // 0x1110xxxx, 0x10xxxxxx, 0x10xxxxxx
    return { ((p[0] & 0b00001111) << 12) | (p[1] & 0b00111111) << 6 | (p[2] & 0b00111111), 3 };
  } else if ((p[0] >> 3) == 0b11110) {
    // 0x11110xxx, 0x10xxxxxx, 0x10xxxxxx, 0x10xxxxxx
    return { ((p[0] & 0b00000111) << 18) | (p[1] & 0b00111111) << 12 | (p[2] & 0b00111111) << 6 | (p[3] & 0b00111111), 4 };
  } else {
    return { 0, 0 };
  }
}

// Returns the preceding non-boundary character if `c` is a boundary character.
// Otherwise, returns `c` if `c` is not a boundary character. Boundary characters
// are trailing punctuation characters that should not be part of the matched text.
static const char* find_boundary_c(const char* c) {
  auto [ch, len] = get_utf8_char(c);

  if (std::binary_search(std::begin(boundary_characters), std::end(boundary_characters), ch)) {
    return c - len;
  } else {
    return c;
  }
}

StateMachine::StateMachine(const auto string, int initial_state, const DTextOptions options) : options(options) {
  // Add null bytes to the beginning and end of the string as start and end of string markers.
  input.resize(string.size() + 2, '\0');
  input.replace(1, string.size(), string.data(), string.size());

  output.reserve(string.size() * 1.5);
  stack.reserve(16);
  dstack.reserve(16);

  p = input.c_str();
  pb = input.c_str();
  pe = input.c_str() + input.size();
  eof = pe;
  cs = initial_state;
}

std::string StateMachine::parse_inline(const std::string_view dtext) {
  StateMachine sm(dtext, dtext_en_inline, options);
  return sm.parse();
}

std::string StateMachine::parse_basic_inline(const std::string_view dtext) {
  StateMachine sm(dtext, dtext_en_basic_inline, options);
  return sm.parse();
}

StateMachine::ParseResult StateMachine::parse_dtext(const std::string_view dtext, DTextOptions options) {
  StateMachine sm(dtext, dtext_en_main, options);
  return { sm.parse(), sm.wiki_pages };
}

std::string StateMachine::parse() {
  StateMachine* sm = this;
  g_debug("parse '%.*s'", (int)(sm->input.size() - 2), sm->input.c_str() + 1);

  %% write init nocs;
  %% write exec;

  g_debug("EOF; closing stray blocks");
  dstack_close_all(sm);
  g_debug("done");

  return sm->output;
}

/* Everything below is optional, it's only needed to build bin/cdtext.exe. */
#ifdef CDTEXT

#include <glib.h>
#include <iostream>

static void parse_file(FILE* input, FILE* output) {
  std::stringstream ss;
  ss << std::cin.rdbuf();
  std::string dtext = ss.str();

  try {
    auto result = StateMachine::parse_dtext(dtext, options);

    if (fwrite(result.c_str(), 1, result.size(), output) != result.size()) {
      perror("fwrite failed");
      exit(1);
    }
  } catch (std::exception& e) {
    fprintf(stderr, "dtext parse error: %s\n", e.what());
    exit(1);
  }
}

int main(int argc, char* argv[]) {
  GError* error = NULL;
  bool opt_verbose = FALSE;
  bool opt_inline = FALSE;
  bool opt_no_mentions = FALSE;

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
    parse_file(stdin, stdout, { .f_inline = opt_inline, .f_mentions = !opt_no_mentions });
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
