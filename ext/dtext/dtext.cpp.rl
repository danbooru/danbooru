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

%%{
machine dtext;

variable p p;
variable pe pe;
variable eof eof;
variable cs cs;
variable top top;
variable ts ts;
variable te te;
variable act act;
variable stack (stack.data());

prepush {
  size_t len = stack.size();

  if (len > MAX_STACK_DEPTH) {
    // Should never happen.
    throw DTextError("too many nested elements");
  }

  if (top >= len) {
    g_debug("growing stack %zi", len + 16);
    stack.resize(len + 16, 0);
  }
}

action mark_a1 { a1 = p; }
action mark_a2 { a2 = p; }
action mark_b1 { b1 = p; }
action mark_b2 { b2 = p; }
action mark_c1 { c1 = p; }
action mark_c2 { c2 = p; }
action mark_d1 { d1 = p; }
action mark_d2 { d2 = p; }
action mark_e1 { e1 = p; }
action mark_e2 { e2 = p; }
action mark_f1 { f1 = p; }
action mark_f2 { f2 = p; }
action mark_g1 { g1 = p; }
action mark_g2 { g2 = p; }

action after_mention_boundary { is_mention_boundary(p[-1]) }
action mentions_enabled { options.f_mentions }
action in_quote { dstack_is_open(BLOCK_QUOTE) }
action in_expand { dstack_is_open(BLOCK_EXPAND) }
action save_tag_attribute { tag_attributes[{ a1, a2 }] = { b1, b2 }; }

# Matches the beginning or the end of the string. The input string has null bytes prepended and appended to mark the ends of the string.
eos = '\0';

newline = '\n';
ws = ' ' | '\t';
eol = newline | eos;
blank_line = ws* eol;
blank_lines = blank_line{2,};

asciichar = 0x00..0x7F;
utf8char  = 0xC2..0xDF 0x80..0xBF
          | 0xE0..0xEF 0x80..0xBF 0x80..0xBF
          | 0xF0..0xF4 0x80..0xBF 0x80..0xBF 0x80..0xBF;
char = asciichar | utf8char;

# Characters that can't be the first or last character in a @-mention, or be contained in a URL.
# http://www.fileformat.info/info/unicode/category/Pe/list.htm
# http://www.fileformat.info/info/unicode/block/cjk_symbols_and_punctuation/list.htm
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
nonnewline = any - newline - eos - '\r';
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

# The list of tags that can appear in brackets (e.g. [quote]).
bracket_tags = (
  'spoiler'i | 'spoilers'i | 'nodtext'i | 'quote'i | 'expand'i | 'code'i |
  'table'i | 'colgroup'i | 'col'i | 'thead'i | 'tbody'i | 'tr'i | 'th'i | 'td'i |
  'br'i | 'hr'i | 'url'i | 'tn'i | 'b'i | 'i'i | 's'i | 'u'i
);

http = 'http'i 's'i? '://';
subdomain = (utf8char | alnum | [_\-])+;
domain = subdomain ('.' subdomain)+;
port = ':' [0-9]+;

url_boundary_char = ["':;,.?] | utf8_boundary_char;
url_char = char - space - eos - utf8_boundary_char;
path = '/' (url_char - [?#<>[\]])*;
query = '?' (url_char - [#])*;
fragment = '#' (url_char - [#<>[\]])*;

bare_absolute_url = (http domain port? path? query? fragment?) - (char* url_boundary_char);
bare_relative_url = (path query? fragment? | fragment) - (char* url_boundary_char);

delimited_absolute_url = http nonspace+;
delimited_relative_url = [/#] nonspace*;

delimited_url = '<' delimited_absolute_url >mark_a1 %mark_a2 :>> '>';
basic_textile_link = '"' ^'"'+ >mark_a1 %mark_a2 '"' ':' (bare_absolute_url | bare_relative_url) >mark_b1 @mark_b2;
bracketed_textile_link = '"' ^'"'+ >mark_a1 %mark_a2 '"' ':[' (delimited_absolute_url | delimited_relative_url) >mark_b1 %mark_b2 :>> ']';

backwards_markdown_link = '[' (delimited_absolute_url | ((delimited_relative_url -- ']') - '/' bracket_tags)) >mark_a1 %mark_a2 :>> '](' nonnewline+ >mark_b1 %mark_b2 :>> ')';
markdown_link = (('[' nonnewline+ >mark_f1 %mark_f2 :>> ']') - ('[' '/'? bracket_tags ']')) '(' (delimited_absolute_url | delimited_relative_url) >mark_g1 %mark_g2 :>> ')';
html_link = '<a'i ws+ 'href="'i (delimited_absolute_url | delimited_relative_url) >mark_a1 %mark_a2 :>> '">' nonnewline+ >mark_b1 %mark_b2 :>> '</a>'i;

unquoted_bbcode_url = delimited_absolute_url | delimited_relative_url;
double_quoted_bbcode_url = '"' unquoted_bbcode_url >mark_b1 %mark_b2 :>> '"';
single_quoted_bbcode_url = "'" unquoted_bbcode_url >mark_b1 %mark_b2 :>> "'";
bbcode_url = double_quoted_bbcode_url | single_quoted_bbcode_url | unquoted_bbcode_url >mark_b1 %mark_b2;
named_bbcode_link   = '[url'i ws* '=' ws* (bbcode_url :>> ws* ']') ws* (nonnewline+ >mark_a1 %mark_a2 :>> ws* '[/url]'i);
unnamed_bbcode_link = '[url]'i ws* unquoted_bbcode_url >mark_a1 %mark_a2 ws* :>> '[/url]'i;

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
open_br = '[br]'i | '<br>'i;

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
  open_b  => { dstack_open_element(INLINE_B, "<strong>"); };
  close_b => { dstack_close_element(INLINE_B, { ts, te }); };
  open_i  => { dstack_open_element(INLINE_I, "<em>"); };
  close_i => { dstack_close_element(INLINE_I, { ts, te }); };
  open_s  => { dstack_open_element(INLINE_S, "<s>"); };
  close_s => { dstack_close_element(INLINE_S, { ts, te }); };
  open_u  => { dstack_open_element(INLINE_U, "<u>"); };
  close_u => { dstack_close_element(INLINE_U, { ts, te }); };
  eos;
  any => { append_html_escaped(fc); };
*|;

inline := |*
  'post #'i id             => { append_id_link("post", "post", "/posts/", { a1, a2 }); };
  'appeal #'i id           => { append_id_link("appeal", "post-appeal", "/post_appeals/", { a1, a2 }); };
  'flag #'i id             => { append_id_link("flag", "post-flag", "/post_flags/", { a1, a2 }); };
  'note #'i id             => { append_id_link("note", "note", "/notes/", { a1, a2 }); };
  'forum #'i id            => { append_id_link("forum", "forum-post", "/forum_posts/", { a1, a2 }); };
  'topic #'i id            => { append_id_link("topic", "forum-topic", "/forum_topics/", { a1, a2 }); };
  'comment #'i id          => { append_id_link("comment", "comment", "/comments/", { a1, a2 }); };
  'dmail #'i id            => { append_id_link("dmail", "dmail", "/dmails/", { a1, a2 }); };
  'pool #'i id             => { append_id_link("pool", "pool", "/pools/", { a1, a2 }); };
  'user #'i id             => { append_id_link("user", "user", "/users/", { a1, a2 }); };
  'artist #'i id           => { append_id_link("artist", "artist", "/artists/", { a1, a2 }); };
  'ban #'i id              => { append_id_link("ban", "ban", "/bans/", { a1, a2 }); };
  'bur #'i id              => { append_id_link("BUR", "bulk-update-request", "/bulk_update_requests/", { a1, a2 }); };
  'alias #'i id            => { append_id_link("alias", "tag-alias", "/tag_aliases/", { a1, a2 }); };
  'implication #'i id      => { append_id_link("implication", "tag-implication", "/tag_implications/", { a1, a2 }); };
  'favgroup #'i id         => { append_id_link("favgroup", "favorite-group", "/favorite_groups/", { a1, a2 }); };
  'mod action #'i id       => { append_id_link("mod action", "mod-action", "/mod_actions/", { a1, a2 }); };
  'modreport #'i id        => { append_id_link("modreport", "moderation-report", "/moderation_reports/", { a1, a2 }); };
  'feedback #'i id         => { append_id_link("feedback", "user-feedback", "/user_feedbacks/", { a1, a2 }); };
  'wiki #'i id             => { append_id_link("wiki", "wiki-page", "/wiki_pages/", { a1, a2 }); };
  'asset #'i id            => { append_id_link("asset", "media-asset", "/media_assets/", { a1, a2 }); };
  'media asset #'i id      => { append_id_link("asset", "media-asset", "/media_assets/", { a1, a2 }); };

  'issue #'i id            => { append_id_link("issue", "github", "https://github.com/danbooru/danbooru/issues/", { a1, a2 }); };
  'pull #'i id             => { append_id_link("pull", "github-pull", "https://github.com/danbooru/danbooru/pull/", { a1, a2 }); };
  'commit #'i id           => { append_id_link("commit", "github-commit", "https://github.com/danbooru/danbooru/commit/", { a1, a2 }); };
  'artstation #'i alnum_id => { append_id_link("artstation", "artstation", "https://www.artstation.com/artwork/", { a1, a2 }); };
  'deviantart #'i id       => { append_id_link("deviantart", "deviantart", "https://www.deviantart.com/deviation/", { a1, a2 }); };
  'nijie #'i id            => { append_id_link("nijie", "nijie", "https://nijie.info/view.php?id=", { a1, a2 }); };
  'pawoo #'i id            => { append_id_link("pawoo", "pawoo", "https://pawoo.net/web/statuses/", { a1, a2 }); };
  'pixiv #'i id            => { append_id_link("pixiv", "pixiv", "https://www.pixiv.net/artworks/", { a1, a2 }); };
  'seiga #'i id            => { append_id_link("seiga", "seiga", "https://seiga.nicovideo.jp/seiga/im", { a1, a2 }); };
  'twitter #'i id          => { append_id_link("twitter", "twitter", "https://twitter.com/i/web/status/", { a1, a2 }); };

  'yandere #'i id => { append_id_link("yandere", "yandere", "https://yande.re/post/show/", { a1, a2 }); };
  'sankaku #'i id => { append_id_link("sankaku", "sankaku", "https://chan.sankakucomplex.com/post/show/", { a1, a2 }); };
  'gelbooru #'i id => { append_id_link("gelbooru", "gelbooru", "https://gelbooru.com/index.php?page=post&s=view&id=", { a1, a2 }); };

  'dmail #'i id '/' dmail_key => { append_dmail_key_link({ a1, a2 }, { b1, b2 }); };

  'topic #'i id '/p'i page => { append_paged_link("topic #", { a1, a2 }, "<a class=\"dtext-link dtext-id-link dtext-forum-topic-id-link\" href=\"", "/forum_topics/", "?page=", { b1, b2 }); };
  'pixiv #'i id '/p'i page => { append_paged_link("pixiv #", { a1, a2 }, "<a rel=\"external nofollow noreferrer\" class=\"dtext-link dtext-id-link dtext-pixiv-id-link\" href=\"", "https://www.pixiv.net/artworks/", "#", { b1, b2 }); };

  basic_post_search_link => {
    append_post_search_link({ a1, a2 }, { b1, b2 }, { b1, b2 }, { d1, d2 });
  };

  aliased_post_search_link => {
    append_post_search_link({ a1, a2 }, { b1, b2 }, { c1, c2 }, { d1, d2 });
  };

  basic_wiki_link => {
    append_wiki_link({ a1, a2 }, { b1, b2 }, { c1, c2 }, { b1, b2 }, { e1, e2 });
  };

  aliased_wiki_link => {
    append_wiki_link({ a1, a2 }, { b1, b2 }, { c1, c2 }, { d1, d2 }, { e1, e2 });
  };

  basic_textile_link => {
    append_bare_named_url({ b1, b2 + 1 }, { a1, a2 });
  };

  bracketed_textile_link | named_bbcode_link => {
    append_named_url({ b1, b2 }, { a1, a2 });
  };

  backwards_markdown_link | html_link => {
    append_named_url({ a1, a2 }, { b1, b2 });
  };

  markdown_link => {
    append_named_url({ g1, g2 }, { f1, f2 });
  };

  bare_absolute_url => {
    append_bare_unnamed_url({ ts, te });
  };

  delimited_url | unnamed_bbcode_link => {
    append_unnamed_url({ a1, a2 });
  };

  bare_mention when mentions_enabled => {
    append_mention({ a1, a2 + 1 });
  };

  delimited_mention when mentions_enabled => {
    g_debug("delimited mention: <@%.*s>", (int)(a2 - a1), a1);
    append_mention({ a1, a2 });
  };

  newline list_item => {
    g_debug("inline list");
    fexec ts + 1;
    fret;
  };

  open_b  => { dstack_open_element(INLINE_B, "<strong>"); };
  close_b => { dstack_close_element(INLINE_B, { ts, te }); };
  open_i  => { dstack_open_element(INLINE_I, "<em>"); };
  close_i => { dstack_close_element(INLINE_I, { ts, te }); };
  open_s  => { dstack_open_element(INLINE_S, "<s>"); };
  close_s => { dstack_close_element(INLINE_S, { ts, te }); };
  open_u  => { dstack_open_element(INLINE_U, "<u>"); };
  close_u => { dstack_close_element(INLINE_U, { ts, te }); };

  open_tn => {
    dstack_open_element(INLINE_TN, "<span class=\"tn\">");
  };

  newline* close_tn => {
    g_debug("inline [/tn]");

    if (dstack_check(INLINE_TN)) {
      dstack_close_element(INLINE_TN, { ts, te });
    } else if (dstack_close_element(BLOCK_TN, { ts, te })) {
      fret;
    }
  };

  open_br => {
    if (header_mode) {
      append_html_escaped("<br>");
    } else {
      append("<br>");
    };
  };

  open_code blank_line? => {
    append_inline_code();
    fcall code;
  };

  open_code_lang blank_line? => {
    append_inline_code({ a1, a2 });
    fcall code;
  };

  newline code_fence => {
    dstack_close_leaf_blocks();
    fexec ts;
    fret;
  };

  newline ws* open_spoilers ws* eol => {
    dstack_close_leaf_blocks();
    fexec ts;
    fret;
  };

  open_spoilers => {
    dstack_open_element(INLINE_SPOILER, "<span class=\"spoiler\">");
  };

  newline? close_spoilers => {
    if (dstack_is_open(INLINE_SPOILER)) {
      dstack_close_element(INLINE_SPOILER, { ts, te });
    } else if (dstack_is_open(BLOCK_SPOILER)) {
      dstack_close_until(BLOCK_SPOILER);
      fret;
    } else {
      append_html_escaped({ ts, te });
    }
  };

  open_nodtext blank_line? => {
    dstack_open_element(INLINE_NODTEXT, "");
    fcall nodtext;
  };

  # these are block level elements that should kick us out of the inline
  # scanner

  newline (open_code | open_code_lang | open_nodtext) => {
    dstack_close_leaf_blocks();
    fexec ts;
    fret;
  };

  newline (header | header_with_id) => {
    dstack_close_leaf_blocks();
    fexec ts;
    fret;
  };

  open_quote => {
    g_debug("inline [quote]");
    dstack_close_leaf_blocks();
    fexec ts;
    fret;
  };

  newline? close_quote ws* => {
    g_debug("inline [/quote]");
    dstack_close_until(BLOCK_QUOTE);
    fret;
  };

  (open_expand | aliased_expand) => {
    g_debug("inline [expand]");
    dstack_close_leaf_blocks();
    fexec ts;
    fret;
  };

  newline? close_expand ws* => {
    g_debug("inline [/expand]");
    dstack_close_until(BLOCK_EXPAND);
    fret;
  };

  newline ws* open_table => {
    dstack_close_leaf_blocks();
    fexec ts;
    fret;
  };

  newline* close_th => {
    if (dstack_close_element(BLOCK_TH, { ts, te })) {
      fret;
    }
  };

  newline* close_td => {
    if (dstack_close_element(BLOCK_TD, { ts, te })) {
      fret;
    }
  };

  newline hr => {
    g_debug("inline [hr] (pos: %ld)", ts - pb);
    dstack_close_leaf_blocks();
    fexec ts;
    fret;
  };

  blank_lines => {
    g_debug("inline newline2");

    if (dstack_check(BLOCK_P)) {
      dstack_rewind();
    } else if (header_mode) {
      dstack_close_leaf_blocks();
    } else {
      dstack_close_list();
    }

    if (options.f_inline) {
      append(" ");
    }

    fret;
  };

  newline => {
    g_debug("inline newline");

    if (header_mode) {
      dstack_close_leaf_blocks();
      fret;
    } else if (dstack_is_open(BLOCK_UL)) {
      dstack_close_list();
      fret;
    } else {
      append("<br>");
    }
  };

  '\r' => {
    append(' ');
  };

  eos;

  alnum+ | utf8char+ => {
    append({ ts, te });
  };

  any => {
    append_html_escaped(fc);
  };
*|;

code := |*
  newline? close_code => {
    dstack_rewind();
    fret;
  };

  eos;

  any => {
    append_html_escaped(fc);
  };
*|;

nodtext := |*
  newline? close_nodtext => {
    dstack_rewind();
    fret;
  };

  eos;

  any => {
    append_html_escaped(fc);
  };
*|;

table := |*
  open_colgroup => {
    dstack_open_element_attributes(BLOCK_COLGROUP, "colgroup");
  };

  close_colgroup => {
    dstack_close_element(BLOCK_COLGROUP, { ts, te });
  };

  open_col => {
    dstack_open_element_attributes(BLOCK_COL, "col");
    dstack_pop(); // XXX [col] has no end tag
  };

  open_thead => {
    dstack_open_element_attributes(BLOCK_THEAD, "thead");
  };

  close_thead => {
    dstack_close_element(BLOCK_THEAD, { ts, te });
  };

  open_tbody => {
    dstack_open_element_attributes(BLOCK_TBODY, "tbody");
  };

  close_tbody => {
    dstack_close_element(BLOCK_TBODY, { ts, te });
  };

  open_th => {
    dstack_open_element_attributes(BLOCK_TH, "th");
    fcall inline;
  };

  open_tr => {
    dstack_open_element_attributes(BLOCK_TR, "tr");
  };

  close_tr => {
    dstack_close_element(BLOCK_TR, { ts, te });
  };

  open_td => {
    dstack_open_element_attributes(BLOCK_TD, "td");
    fcall inline;
  };

  close_table => {
    if (dstack_close_element(BLOCK_TABLE, { ts, te })) {
      fret;
    }
  };

  any;
*|;

main := |*
  header | header_with_id => {
    append_header(*a1, { b1, b2 });
    fcall inline;
  };

  open_quote space* => {
    dstack_close_leaf_blocks();
    dstack_open_element(BLOCK_QUOTE, "<blockquote>");
  };

  open_spoilers space* => {
    dstack_close_leaf_blocks();
    dstack_open_element(BLOCK_SPOILER, "<div class=\"spoiler\">");
  };

  open_code blank_line? => {
    append_block_code();
    fcall code;
  };

  open_code_lang blank_line? => {
    append_block_code({ a1, a2 });
    fcall code;
  };

  code_fence => {
    append_code_fence({ b1, b2 }, { a1, a2 });
  };

  open_expand space* => {
    dstack_close_leaf_blocks();
    dstack_open_element(BLOCK_EXPAND, "<details>");
    append_block("<summary>Show</summary><div>");
  };

  aliased_expand space* => {
    g_debug("block [expand=]");
    dstack_close_leaf_blocks();
    dstack_open_element(BLOCK_EXPAND, "<details>");
    append_block("<summary>");
    append_block_html_escaped({ a1, a2 });
    append_block("</summary><div>");
  };

  open_nodtext blank_line? => {
    dstack_close_leaf_blocks();
    dstack_open_element(BLOCK_NODTEXT, "<p>");
    fcall nodtext;
  };

  ws* open_table => {
    dstack_close_leaf_blocks();
    dstack_open_element(BLOCK_TABLE, "<table class=\"striped\">");
    fcall table;
  };

  open_tn => {
    dstack_open_element(BLOCK_TN, "<p class=\"tn\">");
    fcall inline;
  };

  hr => {
    g_debug("write '<hr>' (pos: %ld)", ts - pb);
    append_block("<hr>");
  };

  list_item => {
    g_debug("block list");
    dstack_open_list(a2 - a1);
    fexec b1;
    fcall inline;
  };

  blank_line+ => {
    g_debug("block blank line(s)");
  };

  any => {
    g_debug("block char");
    fhold;

    if (dstack.empty() || dstack_check(BLOCK_QUOTE) || dstack_check(BLOCK_SPOILER) || dstack_check(BLOCK_EXPAND)) {
      dstack_open_element(BLOCK_P, "<p>");
    }

    fcall inline;
  };
*|;

}%%

%% write data;

void StateMachine::dstack_push(element_t element) {
  dstack.push_back(element);
}

element_t StateMachine::dstack_pop() {
  if (dstack.empty()) {
    g_debug("dstack pop empty stack");
    return DSTACK_EMPTY;
  } else {
    auto element = dstack.back();
    dstack.pop_back();
    return element;
  }
}

element_t StateMachine::dstack_peek() {
  return dstack.empty() ? DSTACK_EMPTY : dstack.back();
}

bool StateMachine::dstack_check(element_t expected_element) {
  return dstack_peek() == expected_element;
}

// Return true if the given tag is currently open.
bool StateMachine::dstack_is_open(element_t element) {
  return std::find(dstack.begin(), dstack.end(), element) != dstack.end();
}

int StateMachine::dstack_count(element_t element) {
  return std::count(dstack.begin(), dstack.end(), element);
}

bool StateMachine::is_internal_url(const std::string_view url) {
  if (url.starts_with("/")) {
    return true;
  } else if (options.domain.empty() || url.empty()) {
    return false;
  } else {
    // Matches the domain name part of a URL.
    static const std::regex url_regex("^https?://(?:[^/?#]*@)?([^/?#:]+)", std::regex_constants::icase);

    std::match_results<std::string_view::const_iterator> matches;
    std::regex_search(url.begin(), url.end(), matches, url_regex);
    return matches[1] == options.domain;
  }
}

void StateMachine::append(const auto c) {
  output += c;
}

void StateMachine::append(const std::string_view string) {
  output += string;
}

void StateMachine::append_html_escaped(char s) {
  switch (s) {
    case '<': append("&lt;"); break;
    case '>': append("&gt;"); break;
    case '&': append("&amp;"); break;
    case '"': append("&quot;"); break;
    default:  append(s);
  }
}

void StateMachine::append_html_escaped(const std::string_view string) {
  for (const unsigned char c : string) {
    append_html_escaped(c);
  }
}

void StateMachine::append_uri_escaped(const std::string_view string) {
  static const char hex[] = "0123456789ABCDEF";

  for (const unsigned char c : string) {
    if ((c >= '0' && c <= '9') || (c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') || c == '-' || c == '_' || c == '.' || c == '~') {
      append(c);
    } else {
      append('%');
      append(hex[c >> 4]);
      append(hex[c & 0x0F]);
    }
  }
}

void StateMachine::append_relative_url(const auto url) {
  if ((url[0] == '/' || url[0] == '#') && !options.base_url.empty()) {
    append_html_escaped(options.base_url);
  }

  append_html_escaped(url);
}

void StateMachine::append_absolute_link(const std::string_view url, const std::string_view title, bool internal_url, bool escape_title) {
  if (internal_url) {
    append("<a class=\"dtext-link\" href=\"");
  } else if (url == title) {
    append("<a rel=\"external nofollow noreferrer\" class=\"dtext-link dtext-external-link\" href=\"");
  } else {
    append("<a rel=\"external nofollow noreferrer\" class=\"dtext-link dtext-external-link dtext-named-external-link\" href=\"");
  }

  append_html_escaped(url);
  append("\">");

  if (escape_title) {
    append_html_escaped(title);
  } else {
    append(title);
  }

  append("</a>");
}

void StateMachine::append_mention(const std::string_view name) {
  append("<a class=\"dtext-link dtext-user-mention-link\" data-user-name=\"");
  append_html_escaped(name);
  append("\" href=\"");
  append_relative_url("/users?name=");
  append_uri_escaped(name);
  append("\">@");
  append_html_escaped(name);
  append("</a>");
}

void StateMachine::append_id_link(const char * title, const char * id_name, const char * url, const std::string_view id) {
  if (url[0] == '/') {
    append("<a class=\"dtext-link dtext-id-link dtext-");
    append(id_name);
    append("-id-link\" href=\"");
    append_relative_url(url);
  } else {
    append("<a rel=\"external nofollow noreferrer\" class=\"dtext-link dtext-id-link dtext-");
    append(id_name);
    append("-id-link\" href=\"");
    append_html_escaped(url);
  }

  append_uri_escaped(id);
  append("\">");
  append(title);
  append(" #");
  append_html_escaped(id);
  append("</a>");
}

void StateMachine::append_bare_unnamed_url(const std::string_view url) {
  auto [trimmed_url, leftovers] = trim_url(url);
  append_unnamed_url(trimmed_url);
  append_html_escaped(leftovers);
}

void StateMachine::append_unnamed_url(const std::string_view url) {
  DText::URL parsed_url(url);

  if (options.internal_domains.find(std::string(parsed_url.domain)) != options.internal_domains.end()) {
    append_internal_url(parsed_url);
  } else {
    append_absolute_link(url, url, parsed_url.domain == options.domain);
  }
}

void StateMachine::append_internal_url(const DText::URL& url) {
  auto path_components = url.path_components();
  auto query = url.query;
  auto fragment = url.fragment;

  if (path_components.size() == 2) {
    auto controller = path_components.at(0);
    auto id = path_components.at(1);

    if (!id.empty() && std::all_of(id.begin(), id.end(), ::isdigit)) {
      if (controller == "posts" && fragment.empty()) {
        // https://danbooru.donmai.us/posts/6000000#comment_2288996
        return append_id_link("post", "post", "/posts/", id);
      } else if (controller == "pools" && query.empty()) {
        // https://danbooru.donmai.us/pools/903?page=2
        return append_id_link("pool", "pool", "/pools/", id);
      } else if (controller == "comments") {
        return append_id_link("comment", "comment", "/comments/", id);
      } else if (controller == "forum_posts") {
        return append_id_link("forum", "forum-post", "/forum_posts/", id);
      } else if (controller == "forum_topics" && query.empty() && fragment.empty()) {
        // https://danbooru.donmai.us/forum_topics/1234?page=2
        // https://danbooru.donmai.us/forum_topics/1234#forum_post_5678
        return append_id_link("topic", "forum-topic", "/forum_topics/", id);
      } else if (controller == "users") {
        return append_id_link("user", "user", "/users/", id);
      } else if (controller == "artists") {
        return append_id_link("artist", "artist", "/artists/", id);
      } else if (controller == "notes") {
        return append_id_link("note", "note", "/notes/", id);
      } else if (controller == "favorite_groups" && query.empty()) {
        // https://danbooru.donmai.us/favorite_groups/1234?page=2
        return append_id_link("favgroup", "favorite-group", "/favorite_groups/", id);
      } else if (controller == "wiki_pages" && fragment.empty()) {
        // http://danbooru.donmai.us/wiki_pages/10933#dtext-self-upload
        return append_id_link("wiki", "wiki-page", "/wiki_pages/", id);
      }
    } else if (controller == "wiki_pages" && fragment.empty()) {
      return append_wiki_link({}, id, {}, id, {});
    }
  } else if (path_components.size() >= 3) {
    // http://danbooru.donmai.us/post/show/1234/touhou
    auto controller = path_components.at(0);
    auto action = path_components.at(1);
    auto id = path_components.at(2);

    if (!id.empty() && std::all_of(id.begin(), id.end(), ::isdigit)) {
      if (controller == "post" && action == "show") {
        return append_id_link("post", "post", "/posts/", id);
      }
    }
  }

  append_absolute_link(url.url, url.url, url.domain == options.domain);
}

void StateMachine::append_named_url(const std::string_view url, const std::string_view title) {
  auto parsed_title = parse_basic_inline(title);

  // protocol-relative url; treat `//example.com` like `http://example.com`
  if (url.size() > 2 && url.starts_with("//")) {
    auto full_url = "http:" + std::string(url);
    append_absolute_link(full_url, parsed_title, is_internal_url(full_url), false);
  } else if (url[0] == '/' || url[0] == '#') {
    append("<a class=\"dtext-link\" href=\"");
    append_relative_url(url);
    append("\">");
    append(parsed_title);
    append("</a>");
  } else if (url == title) {
    append_unnamed_url(url);
  } else {
    append_absolute_link(url, parsed_title, is_internal_url(url), false);
  }
}

void StateMachine::append_bare_named_url(const std::string_view url, std::string_view title) {
  auto [trimmed_url, leftovers] = trim_url(url);
  append_named_url(trimmed_url, title);
  append_html_escaped(leftovers);
}

void StateMachine::append_post_search_link(const std::string_view prefix, const std::string_view search, const std::string_view title, const std::string_view suffix) {
  auto normalized_title = std::string(title);

  append("<a class=\"dtext-link dtext-post-search-link\" href=\"");
  append_relative_url("/posts?tags=");
  append_uri_escaped(search);
  append("\">");

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

  append_html_escaped(normalized_title);
  append("</a>");

  clear_matches();
}

void StateMachine::append_wiki_link(const std::string_view prefix, const std::string_view tag, const std::string_view anchor, const std::string_view title, const std::string_view suffix) {
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

  append("<a class=\"dtext-link dtext-wiki-link\" href=\"");
  append_relative_url("/wiki_pages/");
  append_uri_escaped(normalized_tag);

  if (!anchor.empty()) {
    std::string normalized_anchor(anchor);
    std::transform(normalized_anchor.begin(), normalized_anchor.end(), normalized_anchor.begin(), [](char c) { return isalnum(c) ? tolower(c) : '-'; });
    append_html_escaped("#dtext-");
    append_html_escaped(normalized_anchor);
  }

  append("\">");
  append_html_escaped(title_string);
  append("</a>");

  wiki_pages.insert(std::string(tag));

  clear_matches();
}

void StateMachine::append_paged_link(const char * title, const std::string_view id, const char * tag, const char * href, const char * param, const std::string_view page) {
  append(tag);
  append_relative_url(href);
  append(id);
  append(param);
  append(page);
  append("\">");
  append(title);
  append(id);
  append("/p");
  append(page);
  append("</a>");
}

void StateMachine::append_dmail_key_link(const std::string_view dmail_id, const std::string_view dmail_key) {
  append("<a class=\"dtext-link dtext-id-link dtext-dmail-id-link\" href=\"");
  append_relative_url("/dmails/");
  append(dmail_id);
  append("?key=");
  append_uri_escaped(dmail_key);
  append("\">");
  append("dmail #");
  append(dmail_id);
  append("</a>");
}

void StateMachine::append_code_fence(const std::string_view code, const std::string_view language) {
  if (language.empty()) {
    append_block("<pre>");
    append_html_escaped(code);
    append_block("</pre>");
  } else {
    append_block("<pre class=\"language-");
    append_html_escaped(language);
    append_block("\">");
    append_html_escaped(code);
    append_block("</pre>");
  }
}

void StateMachine::append_inline_code(const std::string_view language) {
  if (language.empty()) {
    dstack_open_element(INLINE_CODE, "<code>");
  } else {
    dstack_open_element(INLINE_CODE, "<code class=\"language-");
    append_html_escaped(language);
    append("\">");
  }
}

void StateMachine::append_block_code(const std::string_view language) {
  dstack_close_leaf_blocks();

  if (language.empty()) {
    dstack_open_element(BLOCK_CODE, "<pre>");
  } else {
    dstack_open_element(BLOCK_CODE, "<pre class=\"language-");
    append_html_escaped(language);
    append("\">");
  }
}

void StateMachine::append_header(char header, const std::string_view id) {
  static element_t blocks[] = {BLOCK_H1, BLOCK_H2, BLOCK_H3, BLOCK_H4, BLOCK_H5, BLOCK_H6};
  element_t block = blocks[header - '1'];

  if (id.empty()) {
    dstack_open_element(block, "<h");
    append_block(header);
    append_block(">");
  } else {
    auto normalized_id = std::string(id);
    std::transform(id.begin(), id.end(), normalized_id.begin(), [](char c) { return isalnum(c) ? tolower(c) : '-'; });

    dstack_open_element(block, "<h");
    append_block(header);
    append_block(" id=\"dtext-");
    append_block(normalized_id);
    append_block("\">");
  }

  header_mode = true;
}

void StateMachine::append_block(const auto s) {
  if (!options.f_inline) {
    append(s);
  }
}

void StateMachine::append_block_html_escaped(const std::string_view string) {
  if (!options.f_inline) {
    append_html_escaped(string);
  }
}

void StateMachine::append_closing_p() {
  g_debug("append closing p");

  if (output.size() > 4 && output.ends_with("<br>")) {
    g_debug("trim last <br>");
    output.resize(output.size() - 4);
  }

  if (output.size() > 3 && output.ends_with("<p>")) {
    g_debug("trim last <p>");
    output.resize(output.size() - 3);
    return;
  }

  append_block("</p>");
}

void StateMachine::dstack_open_element(element_t type, const char * html) {
  g_debug("opening %s", html);

  dstack_push(type);

  if (type >= INLINE) {
    append(html);
  } else {
    append_block(html);
  }
}

void StateMachine::dstack_open_element_attributes(element_t type, std::string_view tag_name) {
  dstack_push(type);
  append_block("<");
  append_block(tag_name);

  auto& permitted_names = permitted_attribute_names.at(tag_name);
  for (auto& [name, value] : tag_attributes) {
    if (permitted_names.find(name) != permitted_names.end()) {
      auto validate_value = permitted_attribute_values.at(name);

      if (validate_value(value)) {
        append_block(" ");
        append_block_html_escaped(name);
        append_block("=\"");
        append_block_html_escaped(value);
        append_block("\"");
      }
    }
  }

  append_block(">");
  tag_attributes.clear();
}

bool StateMachine::dstack_close_element(element_t type, const std::string_view tag_name) {
  if (dstack_check(type)) {
    dstack_rewind();
    return true;
  } else if (type >= INLINE && dstack_peek() >= INLINE) {
    g_debug("out-of-order close %s; closing %s instead", element_names[type], element_names[dstack_peek()]);
    dstack_rewind();
    return true;
  } else if (type >= INLINE) {
    g_debug("out-of-order closing %s", element_names[type]);
    append_html_escaped(tag_name);
    return false;
  } else {
    g_debug("out-of-order closing %s", element_names[type]);
    append_block_html_escaped(tag_name);
    return false;
  }
}

// Close the last open tag.
void StateMachine::dstack_rewind() {
  element_t element = dstack_pop();
  g_debug("dstack rewind %s", element_names[element]);

  switch(element) {
    case BLOCK_P: append_closing_p(); break;
    case INLINE_SPOILER: append("</span>"); break;
    case BLOCK_SPOILER: append_block("</div>"); break;
    case BLOCK_QUOTE: append_block("</blockquote>"); break;
    case BLOCK_EXPAND: append_block("</div></details>"); break;
    case BLOCK_NODTEXT: append_block("</p>"); break;
    case BLOCK_CODE: append_block("</pre>"); break;
    case BLOCK_TD: append_block("</td>"); break;
    case BLOCK_TH: append_block("</th>"); break;

    case INLINE_NODTEXT: break;
    case INLINE_B: append("</strong>"); break;
    case INLINE_I: append("</em>"); break;
    case INLINE_U: append("</u>"); break;
    case INLINE_S: append("</s>"); break;
    case INLINE_TN: append("</span>"); break;
    case INLINE_CODE: append("</code>"); break;

    case BLOCK_TN: append_closing_p(); break;
    case BLOCK_TABLE: append_block("</table>"); break;
    case BLOCK_COLGROUP: append_block("</colgroup>"); break;
    case BLOCK_THEAD: append_block("</thead>"); break;
    case BLOCK_TBODY: append_block("</tbody>"); break;
    case BLOCK_TR: append_block("</tr>"); break;
    case BLOCK_UL: append_block("</ul>"); break;
    case BLOCK_LI: append_block("</li>"); break;
    case BLOCK_H6: append_block("</h6>"); header_mode = false; break;
    case BLOCK_H5: append_block("</h5>"); header_mode = false; break;
    case BLOCK_H4: append_block("</h4>"); header_mode = false; break;
    case BLOCK_H3: append_block("</h3>"); header_mode = false; break;
    case BLOCK_H2: append_block("</h2>"); header_mode = false; break;
    case BLOCK_H1: append_block("</h1>"); header_mode = false; break;

    // Should never happen.
    case INLINE: break;
    case DSTACK_EMPTY: break;
  }
}

// container blocks: [spoiler], [quote], [expand], [tn]
// leaf blocks: [nodtext], [code], [table], [td]?, [th]?, <h1>, <p>, <li>, <ul>
void StateMachine::dstack_close_leaf_blocks() {
  g_debug("dstack close leaf blocks");

  while (!dstack.empty() && !dstack_check(BLOCK_QUOTE) && !dstack_check(BLOCK_SPOILER) && !dstack_check(BLOCK_EXPAND) && !dstack_check(BLOCK_TN)) {
    dstack_rewind();
  }
}

// Close all open tags up to and including the given tag.
void StateMachine::dstack_close_until(element_t element) {
  while (!dstack.empty() && !dstack_check(element)) {
    dstack_rewind();
  }

  dstack_rewind();
}

// Close all remaining open tags.
void StateMachine::dstack_close_all() {
  while (!dstack.empty()) {
    dstack_rewind();
  }
}

void StateMachine::dstack_open_list(int depth) {
  g_debug("open list");

  if (dstack_is_open(BLOCK_LI)) {
    dstack_close_until(BLOCK_LI);
  } else {
    dstack_close_leaf_blocks();
  }

  while (dstack_count(BLOCK_UL) < depth) {
    dstack_open_element(BLOCK_UL, "<ul>");
  }

  while (dstack_count(BLOCK_UL) > depth) {
    dstack_close_until(BLOCK_UL);
  }

  dstack_open_element(BLOCK_LI, "<li>");
}

void StateMachine::dstack_close_list() {
  while (dstack_is_open(BLOCK_UL)) {
    dstack_close_until(BLOCK_UL);
  }
}

void StateMachine::clear_matches() {
  a1 = NULL;
  a2 = NULL;
  b1 = NULL;
  b2 = NULL;
  c1 = NULL;
  c2 = NULL;
  d1 = NULL;
  d2 = NULL;
  e1 = NULL;
  e2 = NULL;
  f1 = NULL;
  f2 = NULL;
  g1 = NULL;
  g2 = NULL;
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

// Trim trailing unbalanced ')' characters from the URL.
std::tuple<std::string_view, std::string_view> StateMachine::trim_url(const std::string_view url) {
  std::string_view trimmed = url;

  while (!trimmed.empty() && trimmed.back() == ')' && std::count(trimmed.begin(), trimmed.end(), ')') > std::count(trimmed.begin(), trimmed.end(), '(')) {
    trimmed.remove_suffix(1);
  }

  return { trimmed, { trimmed.end(), url.end() } };
}

// Replace CRLF sequences with LF.
static void replace_newlines(const std::string_view input, std::string& output) {
  size_t pos, last = 0;

  while (std::string::npos != (pos = input.find("\r\n", last))) {
    output.append(input, last, pos - last);
    output.append("\n");
    last = pos + 2;
  }

  output.append(input, last, pos - last);
}

StateMachine::StateMachine(const auto string, int initial_state, const DTextOptions options) : options(options) {
  // Add null bytes to the beginning and end of the string as start and end of string markers.
  input.reserve(string.size());
  input.append(1, '\0');
  replace_newlines(string, input);
  input.append(1, '\0');

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
  g_debug("parse '%.*s'", (int)(input.size() - 2), input.c_str() + 1);

  %% write init nocs;
  %% write exec;

  g_debug("EOF; closing stray blocks");
  dstack_close_all();
  g_debug("done");

  return output;
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
