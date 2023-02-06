
#line 1 "ext/dtext/dtext.cpp.rl"
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


#line 763 "ext/dtext/dtext.cpp.rl"



#line 98 "ext/dtext/dtext.cpp"
static const int dtext_start = 959;
static const int dtext_first_final = 959;
static const int dtext_error = 0;

static const int dtext_en_basic_inline = 979;
static const int dtext_en_inline = 982;
static const int dtext_en_code = 1233;
static const int dtext_en_nodtext = 1238;
static const int dtext_en_table = 1243;
static const int dtext_en_main = 959;


#line 766 "ext/dtext/dtext.cpp.rl"

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

  
#line 847 "ext/dtext/dtext.cpp"
	{
	( sm->top) = 0;
	( sm->ts) = 0;
	( sm->te) = 0;
	( sm->act) = 0;
	}

#line 1501 "ext/dtext/dtext.cpp.rl"
  
#line 857 "ext/dtext/dtext.cpp"
	{
	short _widec;
	if ( ( sm->p) == ( sm->pe) )
		goto _test_eof;
	goto _resume;

_again:
	switch (  sm->cs ) {
		case 959: goto st959;
		case 960: goto st960;
		case 1: goto st1;
		case 2: goto st2;
		case 961: goto st961;
		case 3: goto st3;
		case 4: goto st4;
		case 5: goto st5;
		case 6: goto st6;
		case 7: goto st7;
		case 8: goto st8;
		case 962: goto st962;
		case 9: goto st9;
		case 10: goto st10;
		case 11: goto st11;
		case 12: goto st12;
		case 13: goto st13;
		case 14: goto st14;
		case 15: goto st15;
		case 16: goto st16;
		case 17: goto st17;
		case 18: goto st18;
		case 19: goto st19;
		case 20: goto st20;
		case 21: goto st21;
		case 22: goto st22;
		case 963: goto st963;
		case 964: goto st964;
		case 23: goto st23;
		case 965: goto st965;
		case 966: goto st966;
		case 24: goto st24;
		case 967: goto st967;
		case 25: goto st25;
		case 26: goto st26;
		case 27: goto st27;
		case 28: goto st28;
		case 29: goto st29;
		case 30: goto st30;
		case 31: goto st31;
		case 32: goto st32;
		case 33: goto st33;
		case 34: goto st34;
		case 968: goto st968;
		case 35: goto st35;
		case 36: goto st36;
		case 37: goto st37;
		case 38: goto st38;
		case 39: goto st39;
		case 40: goto st40;
		case 41: goto st41;
		case 969: goto st969;
		case 42: goto st42;
		case 43: goto st43;
		case 970: goto st970;
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
		case 971: goto st971;
		case 54: goto st54;
		case 972: goto st972;
		case 55: goto st55;
		case 56: goto st56;
		case 57: goto st57;
		case 58: goto st58;
		case 59: goto st59;
		case 60: goto st60;
		case 61: goto st61;
		case 973: goto st973;
		case 62: goto st62;
		case 63: goto st63;
		case 64: goto st64;
		case 65: goto st65;
		case 66: goto st66;
		case 67: goto st67;
		case 68: goto st68;
		case 69: goto st69;
		case 70: goto st70;
		case 974: goto st974;
		case 71: goto st71;
		case 72: goto st72;
		case 73: goto st73;
		case 975: goto st975;
		case 74: goto st74;
		case 75: goto st75;
		case 76: goto st76;
		case 976: goto st976;
		case 977: goto st977;
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
		case 978: goto st978;
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
		case 979: goto st979;
		case 980: goto st980;
		case 127: goto st127;
		case 128: goto st128;
		case 129: goto st129;
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
		case 144: goto st144;
		case 145: goto st145;
		case 981: goto st981;
		case 146: goto st146;
		case 147: goto st147;
		case 148: goto st148;
		case 149: goto st149;
		case 150: goto st150;
		case 151: goto st151;
		case 152: goto st152;
		case 153: goto st153;
		case 154: goto st154;
		case 982: goto st982;
		case 983: goto st983;
		case 984: goto st984;
		case 155: goto st155;
		case 156: goto st156;
		case 157: goto st157;
		case 985: goto st985;
		case 986: goto st986;
		case 987: goto st987;
		case 158: goto st158;
		case 159: goto st159;
		case 988: goto st988;
		case 160: goto st160;
		case 161: goto st161;
		case 989: goto st989;
		case 162: goto st162;
		case 163: goto st163;
		case 164: goto st164;
		case 165: goto st165;
		case 166: goto st166;
		case 990: goto st990;
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
		case 192: goto st192;
		case 193: goto st193;
		case 194: goto st194;
		case 195: goto st195;
		case 196: goto st196;
		case 197: goto st197;
		case 198: goto st198;
		case 991: goto st991;
		case 199: goto st199;
		case 200: goto st200;
		case 201: goto st201;
		case 202: goto st202;
		case 203: goto st203;
		case 204: goto st204;
		case 205: goto st205;
		case 206: goto st206;
		case 207: goto st207;
		case 208: goto st208;
		case 209: goto st209;
		case 210: goto st210;
		case 211: goto st211;
		case 212: goto st212;
		case 213: goto st213;
		case 992: goto st992;
		case 993: goto st993;
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
		case 994: goto st994;
		case 226: goto st226;
		case 227: goto st227;
		case 228: goto st228;
		case 229: goto st229;
		case 230: goto st230;
		case 231: goto st231;
		case 995: goto st995;
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
		case 244: goto st244;
		case 245: goto st245;
		case 246: goto st246;
		case 247: goto st247;
		case 248: goto st248;
		case 249: goto st249;
		case 250: goto st250;
		case 251: goto st251;
		case 252: goto st252;
		case 253: goto st253;
		case 254: goto st254;
		case 255: goto st255;
		case 256: goto st256;
		case 257: goto st257;
		case 258: goto st258;
		case 259: goto st259;
		case 260: goto st260;
		case 261: goto st261;
		case 262: goto st262;
		case 996: goto st996;
		case 263: goto st263;
		case 264: goto st264;
		case 265: goto st265;
		case 266: goto st266;
		case 267: goto st267;
		case 268: goto st268;
		case 269: goto st269;
		case 270: goto st270;
		case 271: goto st271;
		case 272: goto st272;
		case 273: goto st273;
		case 274: goto st274;
		case 275: goto st275;
		case 276: goto st276;
		case 277: goto st277;
		case 278: goto st278;
		case 279: goto st279;
		case 280: goto st280;
		case 281: goto st281;
		case 282: goto st282;
		case 283: goto st283;
		case 284: goto st284;
		case 285: goto st285;
		case 286: goto st286;
		case 287: goto st287;
		case 288: goto st288;
		case 289: goto st289;
		case 290: goto st290;
		case 291: goto st291;
		case 292: goto st292;
		case 293: goto st293;
		case 294: goto st294;
		case 295: goto st295;
		case 296: goto st296;
		case 297: goto st297;
		case 298: goto st298;
		case 299: goto st299;
		case 300: goto st300;
		case 301: goto st301;
		case 302: goto st302;
		case 303: goto st303;
		case 304: goto st304;
		case 305: goto st305;
		case 997: goto st997;
		case 998: goto st998;
		case 306: goto st306;
		case 307: goto st307;
		case 308: goto st308;
		case 999: goto st999;
		case 309: goto st309;
		case 310: goto st310;
		case 311: goto st311;
		case 312: goto st312;
		case 313: goto st313;
		case 314: goto st314;
		case 315: goto st315;
		case 316: goto st316;
		case 317: goto st317;
		case 318: goto st318;
		case 319: goto st319;
		case 320: goto st320;
		case 321: goto st321;
		case 322: goto st322;
		case 323: goto st323;
		case 324: goto st324;
		case 325: goto st325;
		case 326: goto st326;
		case 1000: goto st1000;
		case 327: goto st327;
		case 328: goto st328;
		case 329: goto st329;
		case 330: goto st330;
		case 331: goto st331;
		case 332: goto st332;
		case 333: goto st333;
		case 334: goto st334;
		case 335: goto st335;
		case 1001: goto st1001;
		case 1002: goto st1002;
		case 336: goto st336;
		case 337: goto st337;
		case 338: goto st338;
		case 339: goto st339;
		case 1003: goto st1003;
		case 1004: goto st1004;
		case 340: goto st340;
		case 341: goto st341;
		case 342: goto st342;
		case 343: goto st343;
		case 344: goto st344;
		case 345: goto st345;
		case 346: goto st346;
		case 347: goto st347;
		case 348: goto st348;
		case 1005: goto st1005;
		case 1006: goto st1006;
		case 349: goto st349;
		case 350: goto st350;
		case 351: goto st351;
		case 352: goto st352;
		case 353: goto st353;
		case 354: goto st354;
		case 355: goto st355;
		case 356: goto st356;
		case 357: goto st357;
		case 358: goto st358;
		case 359: goto st359;
		case 360: goto st360;
		case 361: goto st361;
		case 362: goto st362;
		case 363: goto st363;
		case 364: goto st364;
		case 365: goto st365;
		case 366: goto st366;
		case 367: goto st367;
		case 368: goto st368;
		case 369: goto st369;
		case 370: goto st370;
		case 371: goto st371;
		case 372: goto st372;
		case 373: goto st373;
		case 374: goto st374;
		case 375: goto st375;
		case 376: goto st376;
		case 377: goto st377;
		case 378: goto st378;
		case 379: goto st379;
		case 380: goto st380;
		case 381: goto st381;
		case 382: goto st382;
		case 383: goto st383;
		case 384: goto st384;
		case 385: goto st385;
		case 386: goto st386;
		case 387: goto st387;
		case 388: goto st388;
		case 389: goto st389;
		case 390: goto st390;
		case 391: goto st391;
		case 1007: goto st1007;
		case 1008: goto st1008;
		case 392: goto st392;
		case 1009: goto st1009;
		case 1010: goto st1010;
		case 393: goto st393;
		case 394: goto st394;
		case 395: goto st395;
		case 396: goto st396;
		case 397: goto st397;
		case 398: goto st398;
		case 399: goto st399;
		case 400: goto st400;
		case 1011: goto st1011;
		case 1012: goto st1012;
		case 401: goto st401;
		case 1013: goto st1013;
		case 402: goto st402;
		case 403: goto st403;
		case 404: goto st404;
		case 405: goto st405;
		case 406: goto st406;
		case 407: goto st407;
		case 408: goto st408;
		case 409: goto st409;
		case 410: goto st410;
		case 411: goto st411;
		case 412: goto st412;
		case 413: goto st413;
		case 414: goto st414;
		case 415: goto st415;
		case 416: goto st416;
		case 417: goto st417;
		case 418: goto st418;
		case 419: goto st419;
		case 1014: goto st1014;
		case 420: goto st420;
		case 421: goto st421;
		case 422: goto st422;
		case 423: goto st423;
		case 424: goto st424;
		case 425: goto st425;
		case 426: goto st426;
		case 427: goto st427;
		case 428: goto st428;
		case 0: goto st0;
		case 1015: goto st1015;
		case 1016: goto st1016;
		case 1017: goto st1017;
		case 1018: goto st1018;
		case 1019: goto st1019;
		case 429: goto st429;
		case 430: goto st430;
		case 1020: goto st1020;
		case 1021: goto st1021;
		case 1022: goto st1022;
		case 1023: goto st1023;
		case 1024: goto st1024;
		case 1025: goto st1025;
		case 431: goto st431;
		case 432: goto st432;
		case 1026: goto st1026;
		case 1027: goto st1027;
		case 1028: goto st1028;
		case 1029: goto st1029;
		case 1030: goto st1030;
		case 1031: goto st1031;
		case 433: goto st433;
		case 434: goto st434;
		case 1032: goto st1032;
		case 1033: goto st1033;
		case 1034: goto st1034;
		case 1035: goto st1035;
		case 1036: goto st1036;
		case 1037: goto st1037;
		case 1038: goto st1038;
		case 1039: goto st1039;
		case 435: goto st435;
		case 436: goto st436;
		case 1040: goto st1040;
		case 1041: goto st1041;
		case 1042: goto st1042;
		case 1043: goto st1043;
		case 437: goto st437;
		case 438: goto st438;
		case 1044: goto st1044;
		case 1045: goto st1045;
		case 1046: goto st1046;
		case 439: goto st439;
		case 440: goto st440;
		case 1047: goto st1047;
		case 1048: goto st1048;
		case 1049: goto st1049;
		case 1050: goto st1050;
		case 1051: goto st1051;
		case 1052: goto st1052;
		case 1053: goto st1053;
		case 1054: goto st1054;
		case 441: goto st441;
		case 442: goto st442;
		case 1055: goto st1055;
		case 1056: goto st1056;
		case 1057: goto st1057;
		case 443: goto st443;
		case 444: goto st444;
		case 1058: goto st1058;
		case 1059: goto st1059;
		case 1060: goto st1060;
		case 1061: goto st1061;
		case 1062: goto st1062;
		case 1063: goto st1063;
		case 1064: goto st1064;
		case 1065: goto st1065;
		case 1066: goto st1066;
		case 1067: goto st1067;
		case 1068: goto st1068;
		case 445: goto st445;
		case 446: goto st446;
		case 1069: goto st1069;
		case 1070: goto st1070;
		case 1071: goto st1071;
		case 1072: goto st1072;
		case 1073: goto st1073;
		case 447: goto st447;
		case 448: goto st448;
		case 1074: goto st1074;
		case 449: goto st449;
		case 1075: goto st1075;
		case 1076: goto st1076;
		case 1077: goto st1077;
		case 1078: goto st1078;
		case 1079: goto st1079;
		case 1080: goto st1080;
		case 1081: goto st1081;
		case 1082: goto st1082;
		case 1083: goto st1083;
		case 450: goto st450;
		case 451: goto st451;
		case 1084: goto st1084;
		case 1085: goto st1085;
		case 1086: goto st1086;
		case 1087: goto st1087;
		case 1088: goto st1088;
		case 1089: goto st1089;
		case 1090: goto st1090;
		case 1091: goto st1091;
		case 452: goto st452;
		case 453: goto st453;
		case 1092: goto st1092;
		case 1093: goto st1093;
		case 1094: goto st1094;
		case 1095: goto st1095;
		case 454: goto st454;
		case 455: goto st455;
		case 1096: goto st1096;
		case 1097: goto st1097;
		case 1098: goto st1098;
		case 1099: goto st1099;
		case 1100: goto st1100;
		case 456: goto st456;
		case 457: goto st457;
		case 1101: goto st1101;
		case 1102: goto st1102;
		case 1103: goto st1103;
		case 1104: goto st1104;
		case 1105: goto st1105;
		case 1106: goto st1106;
		case 1107: goto st1107;
		case 1108: goto st1108;
		case 1109: goto st1109;
		case 458: goto st458;
		case 459: goto st459;
		case 1110: goto st1110;
		case 1111: goto st1111;
		case 1112: goto st1112;
		case 1113: goto st1113;
		case 1114: goto st1114;
		case 460: goto st460;
		case 461: goto st461;
		case 462: goto st462;
		case 1115: goto st1115;
		case 1116: goto st1116;
		case 1117: goto st1117;
		case 1118: goto st1118;
		case 1119: goto st1119;
		case 1120: goto st1120;
		case 1121: goto st1121;
		case 1122: goto st1122;
		case 1123: goto st1123;
		case 1124: goto st1124;
		case 1125: goto st1125;
		case 1126: goto st1126;
		case 1127: goto st1127;
		case 463: goto st463;
		case 464: goto st464;
		case 1128: goto st1128;
		case 1129: goto st1129;
		case 1130: goto st1130;
		case 1131: goto st1131;
		case 1132: goto st1132;
		case 465: goto st465;
		case 466: goto st466;
		case 1133: goto st1133;
		case 1134: goto st1134;
		case 1135: goto st1135;
		case 1136: goto st1136;
		case 467: goto st467;
		case 468: goto st468;
		case 469: goto st469;
		case 470: goto st470;
		case 471: goto st471;
		case 472: goto st472;
		case 473: goto st473;
		case 474: goto st474;
		case 475: goto st475;
		case 1137: goto st1137;
		case 1138: goto st1138;
		case 1139: goto st1139;
		case 1140: goto st1140;
		case 1141: goto st1141;
		case 1142: goto st1142;
		case 1143: goto st1143;
		case 476: goto st476;
		case 477: goto st477;
		case 1144: goto st1144;
		case 1145: goto st1145;
		case 1146: goto st1146;
		case 1147: goto st1147;
		case 1148: goto st1148;
		case 1149: goto st1149;
		case 478: goto st478;
		case 479: goto st479;
		case 1150: goto st1150;
		case 1151: goto st1151;
		case 1152: goto st1152;
		case 1153: goto st1153;
		case 480: goto st480;
		case 481: goto st481;
		case 1154: goto st1154;
		case 1155: goto st1155;
		case 1156: goto st1156;
		case 1157: goto st1157;
		case 1158: goto st1158;
		case 1159: goto st1159;
		case 482: goto st482;
		case 483: goto st483;
		case 1160: goto st1160;
		case 1161: goto st1161;
		case 1162: goto st1162;
		case 1163: goto st1163;
		case 1164: goto st1164;
		case 484: goto st484;
		case 485: goto st485;
		case 1165: goto st1165;
		case 486: goto st486;
		case 487: goto st487;
		case 1166: goto st1166;
		case 1167: goto st1167;
		case 1168: goto st1168;
		case 1169: goto st1169;
		case 488: goto st488;
		case 489: goto st489;
		case 1170: goto st1170;
		case 1171: goto st1171;
		case 1172: goto st1172;
		case 490: goto st490;
		case 491: goto st491;
		case 1173: goto st1173;
		case 1174: goto st1174;
		case 1175: goto st1175;
		case 1176: goto st1176;
		case 492: goto st492;
		case 493: goto st493;
		case 1177: goto st1177;
		case 1178: goto st1178;
		case 1179: goto st1179;
		case 1180: goto st1180;
		case 1181: goto st1181;
		case 1182: goto st1182;
		case 1183: goto st1183;
		case 1184: goto st1184;
		case 494: goto st494;
		case 495: goto st495;
		case 1185: goto st1185;
		case 1186: goto st1186;
		case 1187: goto st1187;
		case 1188: goto st1188;
		case 1189: goto st1189;
		case 496: goto st496;
		case 497: goto st497;
		case 1190: goto st1190;
		case 1191: goto st1191;
		case 1192: goto st1192;
		case 1193: goto st1193;
		case 1194: goto st1194;
		case 1195: goto st1195;
		case 498: goto st498;
		case 499: goto st499;
		case 1196: goto st1196;
		case 500: goto st500;
		case 501: goto st501;
		case 1197: goto st1197;
		case 1198: goto st1198;
		case 1199: goto st1199;
		case 1200: goto st1200;
		case 1201: goto st1201;
		case 1202: goto st1202;
		case 1203: goto st1203;
		case 502: goto st502;
		case 503: goto st503;
		case 1204: goto st1204;
		case 1205: goto st1205;
		case 1206: goto st1206;
		case 1207: goto st1207;
		case 1208: goto st1208;
		case 504: goto st504;
		case 505: goto st505;
		case 1209: goto st1209;
		case 1210: goto st1210;
		case 1211: goto st1211;
		case 1212: goto st1212;
		case 1213: goto st1213;
		case 506: goto st506;
		case 507: goto st507;
		case 1214: goto st1214;
		case 1215: goto st1215;
		case 1216: goto st1216;
		case 1217: goto st1217;
		case 1218: goto st1218;
		case 1219: goto st1219;
		case 1220: goto st1220;
		case 1221: goto st1221;
		case 508: goto st508;
		case 509: goto st509;
		case 1222: goto st1222;
		case 1223: goto st1223;
		case 510: goto st510;
		case 511: goto st511;
		case 512: goto st512;
		case 513: goto st513;
		case 514: goto st514;
		case 515: goto st515;
		case 516: goto st516;
		case 517: goto st517;
		case 518: goto st518;
		case 519: goto st519;
		case 520: goto st520;
		case 521: goto st521;
		case 522: goto st522;
		case 1224: goto st1224;
		case 523: goto st523;
		case 524: goto st524;
		case 1225: goto st1225;
		case 525: goto st525;
		case 526: goto st526;
		case 527: goto st527;
		case 528: goto st528;
		case 529: goto st529;
		case 530: goto st530;
		case 531: goto st531;
		case 532: goto st532;
		case 533: goto st533;
		case 534: goto st534;
		case 535: goto st535;
		case 536: goto st536;
		case 537: goto st537;
		case 538: goto st538;
		case 539: goto st539;
		case 540: goto st540;
		case 541: goto st541;
		case 542: goto st542;
		case 543: goto st543;
		case 544: goto st544;
		case 545: goto st545;
		case 546: goto st546;
		case 547: goto st547;
		case 548: goto st548;
		case 549: goto st549;
		case 550: goto st550;
		case 551: goto st551;
		case 552: goto st552;
		case 553: goto st553;
		case 554: goto st554;
		case 555: goto st555;
		case 1226: goto st1226;
		case 556: goto st556;
		case 557: goto st557;
		case 558: goto st558;
		case 559: goto st559;
		case 560: goto st560;
		case 561: goto st561;
		case 562: goto st562;
		case 563: goto st563;
		case 564: goto st564;
		case 565: goto st565;
		case 566: goto st566;
		case 567: goto st567;
		case 568: goto st568;
		case 569: goto st569;
		case 570: goto st570;
		case 571: goto st571;
		case 572: goto st572;
		case 573: goto st573;
		case 1227: goto st1227;
		case 1228: goto st1228;
		case 574: goto st574;
		case 575: goto st575;
		case 576: goto st576;
		case 577: goto st577;
		case 578: goto st578;
		case 579: goto st579;
		case 580: goto st580;
		case 581: goto st581;
		case 582: goto st582;
		case 583: goto st583;
		case 584: goto st584;
		case 585: goto st585;
		case 586: goto st586;
		case 587: goto st587;
		case 588: goto st588;
		case 589: goto st589;
		case 590: goto st590;
		case 591: goto st591;
		case 592: goto st592;
		case 593: goto st593;
		case 594: goto st594;
		case 595: goto st595;
		case 596: goto st596;
		case 597: goto st597;
		case 598: goto st598;
		case 599: goto st599;
		case 600: goto st600;
		case 601: goto st601;
		case 602: goto st602;
		case 603: goto st603;
		case 604: goto st604;
		case 605: goto st605;
		case 606: goto st606;
		case 607: goto st607;
		case 608: goto st608;
		case 609: goto st609;
		case 610: goto st610;
		case 611: goto st611;
		case 612: goto st612;
		case 613: goto st613;
		case 614: goto st614;
		case 615: goto st615;
		case 616: goto st616;
		case 617: goto st617;
		case 618: goto st618;
		case 619: goto st619;
		case 620: goto st620;
		case 621: goto st621;
		case 622: goto st622;
		case 623: goto st623;
		case 624: goto st624;
		case 625: goto st625;
		case 626: goto st626;
		case 627: goto st627;
		case 628: goto st628;
		case 629: goto st629;
		case 630: goto st630;
		case 631: goto st631;
		case 632: goto st632;
		case 633: goto st633;
		case 634: goto st634;
		case 635: goto st635;
		case 636: goto st636;
		case 637: goto st637;
		case 638: goto st638;
		case 639: goto st639;
		case 640: goto st640;
		case 641: goto st641;
		case 642: goto st642;
		case 643: goto st643;
		case 644: goto st644;
		case 645: goto st645;
		case 646: goto st646;
		case 647: goto st647;
		case 648: goto st648;
		case 649: goto st649;
		case 650: goto st650;
		case 651: goto st651;
		case 652: goto st652;
		case 653: goto st653;
		case 654: goto st654;
		case 655: goto st655;
		case 656: goto st656;
		case 657: goto st657;
		case 658: goto st658;
		case 659: goto st659;
		case 660: goto st660;
		case 661: goto st661;
		case 662: goto st662;
		case 663: goto st663;
		case 664: goto st664;
		case 665: goto st665;
		case 666: goto st666;
		case 1229: goto st1229;
		case 667: goto st667;
		case 668: goto st668;
		case 1230: goto st1230;
		case 669: goto st669;
		case 670: goto st670;
		case 671: goto st671;
		case 672: goto st672;
		case 1231: goto st1231;
		case 673: goto st673;
		case 674: goto st674;
		case 675: goto st675;
		case 676: goto st676;
		case 677: goto st677;
		case 678: goto st678;
		case 679: goto st679;
		case 680: goto st680;
		case 681: goto st681;
		case 682: goto st682;
		case 1232: goto st1232;
		case 683: goto st683;
		case 684: goto st684;
		case 685: goto st685;
		case 686: goto st686;
		case 687: goto st687;
		case 688: goto st688;
		case 689: goto st689;
		case 690: goto st690;
		case 691: goto st691;
		case 692: goto st692;
		case 693: goto st693;
		case 694: goto st694;
		case 695: goto st695;
		case 696: goto st696;
		case 697: goto st697;
		case 698: goto st698;
		case 699: goto st699;
		case 700: goto st700;
		case 701: goto st701;
		case 702: goto st702;
		case 1233: goto st1233;
		case 1234: goto st1234;
		case 703: goto st703;
		case 704: goto st704;
		case 705: goto st705;
		case 706: goto st706;
		case 707: goto st707;
		case 708: goto st708;
		case 709: goto st709;
		case 710: goto st710;
		case 711: goto st711;
		case 712: goto st712;
		case 713: goto st713;
		case 714: goto st714;
		case 1235: goto st1235;
		case 715: goto st715;
		case 1236: goto st1236;
		case 1237: goto st1237;
		case 1238: goto st1238;
		case 1239: goto st1239;
		case 716: goto st716;
		case 717: goto st717;
		case 718: goto st718;
		case 719: goto st719;
		case 720: goto st720;
		case 721: goto st721;
		case 722: goto st722;
		case 723: goto st723;
		case 724: goto st724;
		case 725: goto st725;
		case 726: goto st726;
		case 727: goto st727;
		case 728: goto st728;
		case 729: goto st729;
		case 730: goto st730;
		case 731: goto st731;
		case 732: goto st732;
		case 733: goto st733;
		case 1240: goto st1240;
		case 734: goto st734;
		case 1241: goto st1241;
		case 1242: goto st1242;
		case 1243: goto st1243;
		case 1244: goto st1244;
		case 735: goto st735;
		case 736: goto st736;
		case 737: goto st737;
		case 738: goto st738;
		case 739: goto st739;
		case 740: goto st740;
		case 741: goto st741;
		case 742: goto st742;
		case 743: goto st743;
		case 744: goto st744;
		case 745: goto st745;
		case 746: goto st746;
		case 747: goto st747;
		case 748: goto st748;
		case 749: goto st749;
		case 750: goto st750;
		case 751: goto st751;
		case 752: goto st752;
		case 753: goto st753;
		case 754: goto st754;
		case 755: goto st755;
		case 756: goto st756;
		case 757: goto st757;
		case 758: goto st758;
		case 759: goto st759;
		case 760: goto st760;
		case 761: goto st761;
		case 762: goto st762;
		case 763: goto st763;
		case 764: goto st764;
		case 765: goto st765;
		case 766: goto st766;
		case 767: goto st767;
		case 768: goto st768;
		case 769: goto st769;
		case 770: goto st770;
		case 771: goto st771;
		case 772: goto st772;
		case 773: goto st773;
		case 774: goto st774;
		case 775: goto st775;
		case 776: goto st776;
		case 777: goto st777;
		case 778: goto st778;
		case 779: goto st779;
		case 780: goto st780;
		case 781: goto st781;
		case 782: goto st782;
		case 783: goto st783;
		case 784: goto st784;
		case 785: goto st785;
		case 786: goto st786;
		case 787: goto st787;
		case 788: goto st788;
		case 789: goto st789;
		case 790: goto st790;
		case 791: goto st791;
		case 792: goto st792;
		case 793: goto st793;
		case 794: goto st794;
		case 795: goto st795;
		case 796: goto st796;
		case 797: goto st797;
		case 798: goto st798;
		case 799: goto st799;
		case 800: goto st800;
		case 801: goto st801;
		case 802: goto st802;
		case 803: goto st803;
		case 804: goto st804;
		case 805: goto st805;
		case 806: goto st806;
		case 807: goto st807;
		case 808: goto st808;
		case 809: goto st809;
		case 810: goto st810;
		case 811: goto st811;
		case 812: goto st812;
		case 813: goto st813;
		case 814: goto st814;
		case 815: goto st815;
		case 816: goto st816;
		case 817: goto st817;
		case 818: goto st818;
		case 819: goto st819;
		case 820: goto st820;
		case 821: goto st821;
		case 822: goto st822;
		case 823: goto st823;
		case 824: goto st824;
		case 825: goto st825;
		case 826: goto st826;
		case 827: goto st827;
		case 828: goto st828;
		case 829: goto st829;
		case 830: goto st830;
		case 831: goto st831;
		case 832: goto st832;
		case 833: goto st833;
		case 834: goto st834;
		case 835: goto st835;
		case 836: goto st836;
		case 837: goto st837;
		case 838: goto st838;
		case 839: goto st839;
		case 840: goto st840;
		case 841: goto st841;
		case 842: goto st842;
		case 843: goto st843;
		case 844: goto st844;
		case 845: goto st845;
		case 846: goto st846;
		case 1245: goto st1245;
		case 847: goto st847;
		case 848: goto st848;
		case 849: goto st849;
		case 850: goto st850;
		case 851: goto st851;
		case 852: goto st852;
		case 853: goto st853;
		case 854: goto st854;
		case 855: goto st855;
		case 856: goto st856;
		case 857: goto st857;
		case 858: goto st858;
		case 859: goto st859;
		case 860: goto st860;
		case 861: goto st861;
		case 862: goto st862;
		case 863: goto st863;
		case 864: goto st864;
		case 865: goto st865;
		case 866: goto st866;
		case 867: goto st867;
		case 868: goto st868;
		case 869: goto st869;
		case 870: goto st870;
		case 871: goto st871;
		case 872: goto st872;
		case 873: goto st873;
		case 874: goto st874;
		case 875: goto st875;
		case 876: goto st876;
		case 877: goto st877;
		case 878: goto st878;
		case 879: goto st879;
		case 880: goto st880;
		case 881: goto st881;
		case 882: goto st882;
		case 883: goto st883;
		case 884: goto st884;
		case 885: goto st885;
		case 886: goto st886;
		case 887: goto st887;
		case 888: goto st888;
		case 889: goto st889;
		case 890: goto st890;
		case 891: goto st891;
		case 892: goto st892;
		case 893: goto st893;
		case 894: goto st894;
		case 895: goto st895;
		case 896: goto st896;
		case 897: goto st897;
		case 898: goto st898;
		case 899: goto st899;
		case 900: goto st900;
		case 901: goto st901;
		case 902: goto st902;
		case 903: goto st903;
		case 904: goto st904;
		case 905: goto st905;
		case 906: goto st906;
		case 907: goto st907;
		case 908: goto st908;
		case 909: goto st909;
		case 910: goto st910;
		case 911: goto st911;
		case 912: goto st912;
		case 913: goto st913;
		case 914: goto st914;
		case 915: goto st915;
		case 916: goto st916;
		case 917: goto st917;
		case 918: goto st918;
		case 919: goto st919;
		case 920: goto st920;
		case 921: goto st921;
		case 922: goto st922;
		case 923: goto st923;
		case 924: goto st924;
		case 925: goto st925;
		case 926: goto st926;
		case 927: goto st927;
		case 928: goto st928;
		case 929: goto st929;
		case 930: goto st930;
		case 931: goto st931;
		case 932: goto st932;
		case 933: goto st933;
		case 934: goto st934;
		case 935: goto st935;
		case 936: goto st936;
		case 937: goto st937;
		case 938: goto st938;
		case 939: goto st939;
		case 940: goto st940;
		case 941: goto st941;
		case 942: goto st942;
		case 943: goto st943;
		case 944: goto st944;
		case 945: goto st945;
		case 946: goto st946;
		case 947: goto st947;
		case 948: goto st948;
		case 949: goto st949;
		case 950: goto st950;
		case 951: goto st951;
		case 952: goto st952;
		case 953: goto st953;
		case 954: goto st954;
		case 955: goto st955;
		case 956: goto st956;
		case 957: goto st957;
		case 958: goto st958;
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
	case 122:
	{{( sm->p) = ((( sm->te)))-1;}
    g_debug("write '<hr>' (pos: %ld)", sm->ts - sm->pb);
    append(sm, "<hr>");
  }
	break;
	case 124:
	{{( sm->p) = ((( sm->te)))-1;}
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
  }
	break;
	case 125:
	{{( sm->p) = ((( sm->te)))-1;}
    g_debug("block newline");
  }
	break;
	case 127:
	{{( sm->p) = ((( sm->te)))-1;}
    g_debug("block char");
    ( sm->p)--;

    if (sm->dstack.empty() || dstack_check(sm, BLOCK_QUOTE) || dstack_check(sm, BLOCK_SPOILER) || dstack_check(sm, BLOCK_EXPAND)) {
      dstack_open_block(sm, BLOCK_P, "<p>");
    }

    {
  size_t len = sm->stack.size();

  if (len > MAX_STACK_DEPTH) {
    // Should never happen.
    throw DTextError("too many nested elements");
  }

  if (sm->top >= len) {
    g_debug("growing sm->stack %zi", len + 16);
    sm->stack.resize(len + 16, 0);
  }
{( (sm->stack.data()))[( sm->top)++] = 959;goto st982;}}
  }
	break;
	default:
	{{( sm->p) = ((( sm->te)))-1;}}
	break;
	}
	}
	goto st959;
tr4:
#line 751 "ext/dtext/dtext.cpp.rl"
	{{( sm->p) = ((( sm->te)))-1;}{
    g_debug("block char");
    ( sm->p)--;

    if (sm->dstack.empty() || dstack_check(sm, BLOCK_QUOTE) || dstack_check(sm, BLOCK_SPOILER) || dstack_check(sm, BLOCK_EXPAND)) {
      dstack_open_block(sm, BLOCK_P, "<p>");
    }

    {
  size_t len = sm->stack.size();

  if (len > MAX_STACK_DEPTH) {
    // Should never happen.
    throw DTextError("too many nested elements");
  }

  if (sm->top >= len) {
    g_debug("growing sm->stack %zi", len + 16);
    sm->stack.resize(len + 16, 0);
  }
{( (sm->stack.data()))[( sm->top)++] = 959;goto st982;}}
  }}
	goto st959;
tr19:
#line 705 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_close_leaf_blocks(sm);
    dstack_open_block(sm, BLOCK_TABLE, "<table class=\"striped\">");
    {
  size_t len = sm->stack.size();

  if (len > MAX_STACK_DEPTH) {
    // Should never happen.
    throw DTextError("too many nested elements");
  }

  if (sm->top >= len) {
    g_debug("growing sm->stack %zi", len + 16);
    sm->stack.resize(len + 16, 0);
  }
{( (sm->stack.data()))[( sm->top)++] = 959;goto st1243;}}
  }}
	goto st959;
tr50:
#line 675 "ext/dtext/dtext.cpp.rl"
	{{( sm->p) = ((( sm->te)))-1;}{
    append_block_code(sm, { sm->a1, sm->a2 });
    {
  size_t len = sm->stack.size();

  if (len > MAX_STACK_DEPTH) {
    // Should never happen.
    throw DTextError("too many nested elements");
  }

  if (sm->top >= len) {
    g_debug("growing sm->stack %zi", len + 16);
    sm->stack.resize(len + 16, 0);
  }
{( (sm->stack.data()))[( sm->top)++] = 959;goto st1233;}}
  }}
	goto st959;
tr51:
#line 675 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{
    append_block_code(sm, { sm->a1, sm->a2 });
    {
  size_t len = sm->stack.size();

  if (len > MAX_STACK_DEPTH) {
    // Should never happen.
    throw DTextError("too many nested elements");
  }

  if (sm->top >= len) {
    g_debug("growing sm->stack %zi", len + 16);
    sm->stack.resize(len + 16, 0);
  }
{( (sm->stack.data()))[( sm->top)++] = 959;goto st1233;}}
  }}
	goto st959;
tr54:
#line 670 "ext/dtext/dtext.cpp.rl"
	{{( sm->p) = ((( sm->te)))-1;}{
    append_block_code(sm);
    {
  size_t len = sm->stack.size();

  if (len > MAX_STACK_DEPTH) {
    // Should never happen.
    throw DTextError("too many nested elements");
  }

  if (sm->top >= len) {
    g_debug("growing sm->stack %zi", len + 16);
    sm->stack.resize(len + 16, 0);
  }
{( (sm->stack.data()))[( sm->top)++] = 959;goto st1233;}}
  }}
	goto st959;
tr55:
#line 670 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{
    append_block_code(sm);
    {
  size_t len = sm->stack.size();

  if (len > MAX_STACK_DEPTH) {
    // Should never happen.
    throw DTextError("too many nested elements");
  }

  if (sm->top >= len) {
    g_debug("growing sm->stack %zi", len + 16);
    sm->stack.resize(len + 16, 0);
  }
{( (sm->stack.data()))[( sm->top)++] = 959;goto st1233;}}
  }}
	goto st959;
tr79:
#line 699 "ext/dtext/dtext.cpp.rl"
	{{( sm->p) = ((( sm->te)))-1;}{
    dstack_close_leaf_blocks(sm);
    dstack_open_block(sm, BLOCK_NODTEXT, "<p>");
    {
  size_t len = sm->stack.size();

  if (len > MAX_STACK_DEPTH) {
    // Should never happen.
    throw DTextError("too many nested elements");
  }

  if (sm->top >= len) {
    g_debug("growing sm->stack %zi", len + 16);
    sm->stack.resize(len + 16, 0);
  }
{( (sm->stack.data()))[( sm->top)++] = 959;goto st1238;}}
  }}
	goto st959;
tr80:
#line 699 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_close_leaf_blocks(sm);
    dstack_open_block(sm, BLOCK_NODTEXT, "<p>");
    {
  size_t len = sm->stack.size();

  if (len > MAX_STACK_DEPTH) {
    // Should never happen.
    throw DTextError("too many nested elements");
  }

  if (sm->top >= len) {
    g_debug("growing sm->stack %zi", len + 16);
    sm->stack.resize(len + 16, 0);
  }
{( (sm->stack.data()))[( sm->top)++] = 959;goto st1238;}}
  }}
	goto st959;
tr92:
#line 711 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_open_block(sm, BLOCK_TN, "<p class=\"tn\">");
    {
  size_t len = sm->stack.size();

  if (len > MAX_STACK_DEPTH) {
    // Should never happen.
    throw DTextError("too many nested elements");
  }

  if (sm->top >= len) {
    g_debug("growing sm->stack %zi", len + 16);
    sm->stack.resize(len + 16, 0);
  }
{( (sm->stack.data()))[( sm->top)++] = 959;goto st982;}}
  }}
	goto st959;
tr148:
#line 680 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{
    append_code_fence(sm, { sm->b1, sm->b2 }, { sm->a1, sm->a2 });
  }}
	goto st959;
tr1253:
#line 751 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{
    g_debug("block char");
    ( sm->p)--;

    if (sm->dstack.empty() || dstack_check(sm, BLOCK_QUOTE) || dstack_check(sm, BLOCK_SPOILER) || dstack_check(sm, BLOCK_EXPAND)) {
      dstack_open_block(sm, BLOCK_P, "<p>");
    }

    {
  size_t len = sm->stack.size();

  if (len > MAX_STACK_DEPTH) {
    // Should never happen.
    throw DTextError("too many nested elements");
  }

  if (sm->top >= len) {
    g_debug("growing sm->stack %zi", len + 16);
    sm->stack.resize(len + 16, 0);
  }
{( (sm->stack.data()))[( sm->top)++] = 959;goto st982;}}
  }}
	goto st959;
tr1263:
#line 751 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    g_debug("block char");
    ( sm->p)--;

    if (sm->dstack.empty() || dstack_check(sm, BLOCK_QUOTE) || dstack_check(sm, BLOCK_SPOILER) || dstack_check(sm, BLOCK_EXPAND)) {
      dstack_open_block(sm, BLOCK_P, "<p>");
    }

    {
  size_t len = sm->stack.size();

  if (len > MAX_STACK_DEPTH) {
    // Should never happen.
    throw DTextError("too many nested elements");
  }

  if (sm->top >= len) {
    g_debug("growing sm->stack %zi", len + 16);
    sm->stack.resize(len + 16, 0);
  }
{( (sm->stack.data()))[( sm->top)++] = 959;goto st982;}}
  }}
	goto st959;
tr1264:
#line 716 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    g_debug("write '<hr>' (pos: %ld)", sm->ts - sm->pb);
    append(sm, "<hr>");
  }}
	goto st959;
tr1265:
#line 120 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
#line 721 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    g_debug("block list");
    dstack_open_list(sm, sm->a2 - sm->a1);
    {( sm->p) = (( sm->b1))-1;}
    {
  size_t len = sm->stack.size();

  if (len > MAX_STACK_DEPTH) {
    // Should never happen.
    throw DTextError("too many nested elements");
  }

  if (sm->top >= len) {
    g_debug("growing sm->stack %zi", len + 16);
    sm->stack.resize(len + 16, 0);
  }
{( (sm->stack.data()))[( sm->top)++] = 959;goto st982;}}
  }}
	goto st959;
tr1273:
#line 660 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    dstack_close_leaf_blocks(sm);
    dstack_open_block(sm, BLOCK_QUOTE, "<blockquote>");
  }}
	goto st959;
tr1274:
#line 675 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append_block_code(sm, { sm->a1, sm->a2 });
    {
  size_t len = sm->stack.size();

  if (len > MAX_STACK_DEPTH) {
    // Should never happen.
    throw DTextError("too many nested elements");
  }

  if (sm->top >= len) {
    g_debug("growing sm->stack %zi", len + 16);
    sm->stack.resize(len + 16, 0);
  }
{( (sm->stack.data()))[( sm->top)++] = 959;goto st1233;}}
  }}
	goto st959;
tr1275:
#line 670 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append_block_code(sm);
    {
  size_t len = sm->stack.size();

  if (len > MAX_STACK_DEPTH) {
    // Should never happen.
    throw DTextError("too many nested elements");
  }

  if (sm->top >= len) {
    g_debug("growing sm->stack %zi", len + 16);
    sm->stack.resize(len + 16, 0);
  }
{( (sm->stack.data()))[( sm->top)++] = 959;goto st1233;}}
  }}
	goto st959;
tr1276:
#line 690 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    g_debug("block [expand=]");
    dstack_close_leaf_blocks(sm);
    dstack_open_block(sm, BLOCK_EXPAND, "<details>");
    append(sm, "<summary>");
    append_html_escaped(sm, { sm->a1, sm->a2 });
    append(sm, "</summary><div>");
  }}
	goto st959;
tr1278:
#line 684 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    dstack_close_leaf_blocks(sm);
    dstack_open_block(sm, BLOCK_EXPAND, "<details>");
    append(sm, "<summary>Show</summary><div>");
  }}
	goto st959;
tr1279:
#line 699 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    dstack_close_leaf_blocks(sm);
    dstack_open_block(sm, BLOCK_NODTEXT, "<p>");
    {
  size_t len = sm->stack.size();

  if (len > MAX_STACK_DEPTH) {
    // Should never happen.
    throw DTextError("too many nested elements");
  }

  if (sm->top >= len) {
    g_debug("growing sm->stack %zi", len + 16);
    sm->stack.resize(len + 16, 0);
  }
{( (sm->stack.data()))[( sm->top)++] = 959;goto st1238;}}
  }}
	goto st959;
tr1280:
#line 665 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    dstack_close_leaf_blocks(sm);
    dstack_open_block(sm, BLOCK_SPOILER, "<div class=\"spoiler\">");
  }}
	goto st959;
tr1282:
#line 655 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append_header(sm, *sm->a1, { sm->b1, sm->b2 });
    {
  size_t len = sm->stack.size();

  if (len > MAX_STACK_DEPTH) {
    // Should never happen.
    throw DTextError("too many nested elements");
  }

  if (sm->top >= len) {
    g_debug("growing sm->stack %zi", len + 16);
    sm->stack.resize(len + 16, 0);
  }
{( (sm->stack.data()))[( sm->top)++] = 959;goto st982;}}
  }}
	goto st959;
st959:
#line 1 "NONE"
	{( sm->ts) = 0;}
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof959;
case 959:
#line 1 "NONE"
	{( sm->ts) = ( sm->p);}
#line 2566 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr1254;
		case 9: goto tr1255;
		case 10: goto tr1256;
		case 13: goto st963;
		case 32: goto tr1255;
		case 42: goto tr1258;
		case 60: goto tr1259;
		case 72: goto tr1260;
		case 91: goto tr1261;
		case 96: goto tr1262;
		case 104: goto tr1260;
	}
	goto tr1253;
tr1:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 728 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 124;}
	goto st960;
tr1254:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 749 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 126;}
	goto st960;
tr1256:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 745 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 125;}
	goto st960;
st960:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof960;
case 960:
#line 2603 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr1;
		case 9: goto st1;
		case 10: goto tr1;
		case 13: goto st2;
		case 32: goto st1;
	}
	goto tr0;
st1:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1;
case 1:
	switch( (*( sm->p)) ) {
		case 0: goto tr1;
		case 9: goto st1;
		case 10: goto tr1;
		case 13: goto st2;
		case 32: goto st1;
	}
	goto tr0;
st2:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof2;
case 2:
	if ( (*( sm->p)) == 10 )
		goto tr1;
	goto tr0;
tr1255:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 751 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 127;}
	goto st961;
st961:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof961;
case 961:
#line 2641 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto st1;
		case 9: goto st3;
		case 10: goto st1;
		case 13: goto st4;
		case 32: goto st3;
		case 60: goto st5;
		case 91: goto st15;
	}
	goto tr1263;
st3:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof3;
case 3:
	switch( (*( sm->p)) ) {
		case 0: goto st1;
		case 9: goto st3;
		case 10: goto st1;
		case 13: goto st4;
		case 32: goto st3;
		case 60: goto st5;
		case 91: goto st15;
	}
	goto tr4;
st4:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof4;
case 4:
	if ( (*( sm->p)) == 10 )
		goto st1;
	goto tr4;
st5:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof5;
case 5:
	switch( (*( sm->p)) ) {
		case 72: goto st6;
		case 84: goto st10;
		case 104: goto st6;
		case 116: goto st10;
	}
	goto tr4;
st6:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof6;
case 6:
	switch( (*( sm->p)) ) {
		case 82: goto st7;
		case 114: goto st7;
	}
	goto tr4;
st7:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof7;
case 7:
	if ( (*( sm->p)) == 62 )
		goto st8;
	goto tr4;
st8:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof8;
case 8:
	switch( (*( sm->p)) ) {
		case 0: goto tr13;
		case 9: goto st8;
		case 10: goto tr13;
		case 13: goto st9;
		case 32: goto st8;
	}
	goto tr4;
tr13:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 716 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 122;}
	goto st962;
st962:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof962;
case 962:
#line 2722 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr13;
		case 10: goto tr13;
		case 13: goto st9;
	}
	goto tr1264;
st9:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof9;
case 9:
	if ( (*( sm->p)) == 10 )
		goto tr13;
	goto tr0;
st10:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof10;
case 10:
	switch( (*( sm->p)) ) {
		case 65: goto st11;
		case 97: goto st11;
	}
	goto tr4;
st11:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof11;
case 11:
	switch( (*( sm->p)) ) {
		case 66: goto st12;
		case 98: goto st12;
	}
	goto tr4;
st12:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof12;
case 12:
	switch( (*( sm->p)) ) {
		case 76: goto st13;
		case 108: goto st13;
	}
	goto tr4;
st13:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof13;
case 13:
	switch( (*( sm->p)) ) {
		case 69: goto st14;
		case 101: goto st14;
	}
	goto tr4;
st14:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof14;
case 14:
	if ( (*( sm->p)) == 62 )
		goto tr19;
	goto tr4;
st15:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof15;
case 15:
	switch( (*( sm->p)) ) {
		case 72: goto st16;
		case 84: goto st18;
		case 104: goto st16;
		case 116: goto st18;
	}
	goto tr4;
st16:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof16;
case 16:
	switch( (*( sm->p)) ) {
		case 82: goto st17;
		case 114: goto st17;
	}
	goto tr4;
st17:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof17;
case 17:
	if ( (*( sm->p)) == 93 )
		goto st8;
	goto tr4;
st18:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof18;
case 18:
	switch( (*( sm->p)) ) {
		case 65: goto st19;
		case 97: goto st19;
	}
	goto tr4;
st19:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof19;
case 19:
	switch( (*( sm->p)) ) {
		case 66: goto st20;
		case 98: goto st20;
	}
	goto tr4;
st20:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof20;
case 20:
	switch( (*( sm->p)) ) {
		case 76: goto st21;
		case 108: goto st21;
	}
	goto tr4;
st21:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof21;
case 21:
	switch( (*( sm->p)) ) {
		case 69: goto st22;
		case 101: goto st22;
	}
	goto tr4;
st22:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof22;
case 22:
	if ( (*( sm->p)) == 93 )
		goto tr19;
	goto tr4;
st963:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof963;
case 963:
	if ( (*( sm->p)) == 10 )
		goto tr1256;
	goto tr1263;
tr1258:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 117 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st964;
st964:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof964;
case 964:
#line 2866 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto tr29;
		case 32: goto tr29;
		case 42: goto st24;
	}
	goto tr1263;
tr29:
#line 118 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
	goto st23;
st23:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof23;
case 23:
#line 2881 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto tr28;
		case 10: goto tr4;
		case 13: goto tr4;
		case 32: goto tr28;
	}
	goto tr27;
tr27:
#line 119 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st965;
st965:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof965;
case 965:
#line 2897 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 10: goto tr1265;
		case 13: goto tr1265;
	}
	goto st965;
tr28:
#line 119 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st966;
st966:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof966;
case 966:
#line 2911 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto tr28;
		case 10: goto tr1265;
		case 13: goto tr1265;
		case 32: goto tr28;
	}
	goto tr27;
st24:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof24;
case 24:
	switch( (*( sm->p)) ) {
		case 9: goto tr29;
		case 32: goto tr29;
		case 42: goto st24;
	}
	goto tr4;
tr1259:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 751 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 127;}
	goto st967;
st967:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof967;
case 967:
#line 2939 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 66: goto st25;
		case 67: goto st35;
		case 69: goto st46;
		case 72: goto st6;
		case 78: goto st55;
		case 81: goto st30;
		case 83: goto st64;
		case 84: goto st72;
		case 98: goto st25;
		case 99: goto st35;
		case 101: goto st46;
		case 104: goto st6;
		case 110: goto st55;
		case 113: goto st30;
		case 115: goto st64;
		case 116: goto st72;
	}
	goto tr1263;
st25:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof25;
case 25:
	switch( (*( sm->p)) ) {
		case 76: goto st26;
		case 108: goto st26;
	}
	goto tr4;
st26:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof26;
case 26:
	switch( (*( sm->p)) ) {
		case 79: goto st27;
		case 111: goto st27;
	}
	goto tr4;
st27:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof27;
case 27:
	switch( (*( sm->p)) ) {
		case 67: goto st28;
		case 99: goto st28;
	}
	goto tr4;
st28:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof28;
case 28:
	switch( (*( sm->p)) ) {
		case 75: goto st29;
		case 107: goto st29;
	}
	goto tr4;
st29:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof29;
case 29:
	switch( (*( sm->p)) ) {
		case 81: goto st30;
		case 113: goto st30;
	}
	goto tr4;
st30:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof30;
case 30:
	switch( (*( sm->p)) ) {
		case 85: goto st31;
		case 117: goto st31;
	}
	goto tr4;
st31:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof31;
case 31:
	switch( (*( sm->p)) ) {
		case 79: goto st32;
		case 111: goto st32;
	}
	goto tr4;
st32:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof32;
case 32:
	switch( (*( sm->p)) ) {
		case 84: goto st33;
		case 116: goto st33;
	}
	goto tr4;
st33:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof33;
case 33:
	switch( (*( sm->p)) ) {
		case 69: goto st34;
		case 101: goto st34;
	}
	goto tr4;
st34:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof34;
case 34:
	if ( (*( sm->p)) == 62 )
		goto st968;
	goto tr4;
st968:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof968;
case 968:
	if ( (*( sm->p)) == 32 )
		goto st968;
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto st968;
	goto tr1273;
st35:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof35;
case 35:
	switch( (*( sm->p)) ) {
		case 79: goto st36;
		case 111: goto st36;
	}
	goto tr4;
st36:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof36;
case 36:
	switch( (*( sm->p)) ) {
		case 68: goto st37;
		case 100: goto st37;
	}
	goto tr4;
st37:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof37;
case 37:
	switch( (*( sm->p)) ) {
		case 69: goto st38;
		case 101: goto st38;
	}
	goto tr4;
st38:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof38;
case 38:
	switch( (*( sm->p)) ) {
		case 9: goto st39;
		case 32: goto st39;
		case 61: goto st40;
		case 62: goto tr46;
	}
	goto tr4;
st39:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof39;
case 39:
	switch( (*( sm->p)) ) {
		case 9: goto st39;
		case 32: goto st39;
		case 61: goto st40;
	}
	goto tr4;
st40:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof40;
case 40:
	switch( (*( sm->p)) ) {
		case 9: goto st40;
		case 32: goto st40;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr47;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr47;
	} else
		goto tr47;
	goto tr4;
tr47:
#line 117 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st41;
st41:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof41;
case 41:
#line 3129 "ext/dtext/dtext.cpp"
	if ( (*( sm->p)) == 62 )
		goto tr49;
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st41;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st41;
	} else
		goto st41;
	goto tr4;
tr49:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 118 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
	goto st969;
st969:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof969;
case 969:
#line 3151 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr51;
		case 9: goto st42;
		case 10: goto tr51;
		case 13: goto st43;
		case 32: goto st42;
	}
	goto tr1274;
st42:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof42;
case 42:
	switch( (*( sm->p)) ) {
		case 0: goto tr51;
		case 9: goto st42;
		case 10: goto tr51;
		case 13: goto st43;
		case 32: goto st42;
	}
	goto tr50;
st43:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof43;
case 43:
	if ( (*( sm->p)) == 10 )
		goto tr51;
	goto tr50;
tr46:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
	goto st970;
st970:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof970;
case 970:
#line 3187 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr55;
		case 9: goto st44;
		case 10: goto tr55;
		case 13: goto st45;
		case 32: goto st44;
	}
	goto tr1275;
st44:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof44;
case 44:
	switch( (*( sm->p)) ) {
		case 0: goto tr55;
		case 9: goto st44;
		case 10: goto tr55;
		case 13: goto st45;
		case 32: goto st44;
	}
	goto tr54;
st45:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof45;
case 45:
	if ( (*( sm->p)) == 10 )
		goto tr55;
	goto tr54;
st46:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof46;
case 46:
	switch( (*( sm->p)) ) {
		case 88: goto st47;
		case 120: goto st47;
	}
	goto tr4;
st47:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof47;
case 47:
	switch( (*( sm->p)) ) {
		case 80: goto st48;
		case 112: goto st48;
	}
	goto tr4;
st48:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof48;
case 48:
	switch( (*( sm->p)) ) {
		case 65: goto st49;
		case 97: goto st49;
	}
	goto tr4;
st49:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof49;
case 49:
	switch( (*( sm->p)) ) {
		case 78: goto st50;
		case 110: goto st50;
	}
	goto tr4;
st50:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof50;
case 50:
	switch( (*( sm->p)) ) {
		case 68: goto st51;
		case 100: goto st51;
	}
	goto tr4;
st51:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof51;
case 51:
	switch( (*( sm->p)) ) {
		case 9: goto st52;
		case 32: goto st52;
		case 61: goto st54;
		case 62: goto st972;
	}
	goto tr4;
tr67:
#line 117 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st52;
st52:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof52;
case 52:
#line 3279 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto tr67;
		case 10: goto tr4;
		case 13: goto tr4;
		case 32: goto tr67;
		case 61: goto tr68;
		case 62: goto tr69;
	}
	goto tr66;
tr66:
#line 117 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st53;
st53:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof53;
case 53:
#line 3297 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 10: goto tr4;
		case 13: goto tr4;
		case 62: goto tr71;
	}
	goto st53;
tr71:
#line 118 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
	goto st971;
tr69:
#line 117 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
#line 118 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
	goto st971;
st971:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof971;
case 971:
#line 3318 "ext/dtext/dtext.cpp"
	if ( (*( sm->p)) == 32 )
		goto st971;
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto st971;
	goto tr1276;
tr68:
#line 117 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st54;
st54:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof54;
case 54:
#line 3332 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto tr68;
		case 10: goto tr4;
		case 13: goto tr4;
		case 32: goto tr68;
		case 62: goto tr69;
	}
	goto tr66;
st972:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof972;
case 972:
	if ( (*( sm->p)) == 32 )
		goto st972;
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto st972;
	goto tr1278;
st55:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof55;
case 55:
	switch( (*( sm->p)) ) {
		case 79: goto st56;
		case 111: goto st56;
	}
	goto tr4;
st56:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof56;
case 56:
	switch( (*( sm->p)) ) {
		case 68: goto st57;
		case 100: goto st57;
	}
	goto tr4;
st57:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof57;
case 57:
	switch( (*( sm->p)) ) {
		case 84: goto st58;
		case 116: goto st58;
	}
	goto tr4;
st58:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof58;
case 58:
	switch( (*( sm->p)) ) {
		case 69: goto st59;
		case 101: goto st59;
	}
	goto tr4;
st59:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof59;
case 59:
	switch( (*( sm->p)) ) {
		case 88: goto st60;
		case 120: goto st60;
	}
	goto tr4;
st60:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof60;
case 60:
	switch( (*( sm->p)) ) {
		case 84: goto st61;
		case 116: goto st61;
	}
	goto tr4;
st61:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof61;
case 61:
	if ( (*( sm->p)) == 62 )
		goto tr78;
	goto tr4;
tr78:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
	goto st973;
st973:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof973;
case 973:
#line 3419 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr80;
		case 9: goto st62;
		case 10: goto tr80;
		case 13: goto st63;
		case 32: goto st62;
	}
	goto tr1279;
st62:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof62;
case 62:
	switch( (*( sm->p)) ) {
		case 0: goto tr80;
		case 9: goto st62;
		case 10: goto tr80;
		case 13: goto st63;
		case 32: goto st62;
	}
	goto tr79;
st63:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof63;
case 63:
	if ( (*( sm->p)) == 10 )
		goto tr80;
	goto tr79;
st64:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof64;
case 64:
	switch( (*( sm->p)) ) {
		case 80: goto st65;
		case 112: goto st65;
	}
	goto tr4;
st65:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof65;
case 65:
	switch( (*( sm->p)) ) {
		case 79: goto st66;
		case 111: goto st66;
	}
	goto tr4;
st66:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof66;
case 66:
	switch( (*( sm->p)) ) {
		case 73: goto st67;
		case 105: goto st67;
	}
	goto tr4;
st67:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof67;
case 67:
	switch( (*( sm->p)) ) {
		case 76: goto st68;
		case 108: goto st68;
	}
	goto tr4;
st68:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof68;
case 68:
	switch( (*( sm->p)) ) {
		case 69: goto st69;
		case 101: goto st69;
	}
	goto tr4;
st69:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof69;
case 69:
	switch( (*( sm->p)) ) {
		case 82: goto st70;
		case 114: goto st70;
	}
	goto tr4;
st70:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof70;
case 70:
	switch( (*( sm->p)) ) {
		case 62: goto st974;
		case 83: goto st71;
		case 115: goto st71;
	}
	goto tr4;
st974:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof974;
case 974:
	if ( (*( sm->p)) == 32 )
		goto st974;
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto st974;
	goto tr1280;
st71:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof71;
case 71:
	if ( (*( sm->p)) == 62 )
		goto st974;
	goto tr4;
st72:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof72;
case 72:
	switch( (*( sm->p)) ) {
		case 65: goto st11;
		case 78: goto st73;
		case 97: goto st11;
		case 110: goto st73;
	}
	goto tr4;
st73:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof73;
case 73:
	if ( (*( sm->p)) == 62 )
		goto tr92;
	goto tr4;
tr1260:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
	goto st975;
st975:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof975;
case 975:
#line 3553 "ext/dtext/dtext.cpp"
	if ( 49 <= (*( sm->p)) && (*( sm->p)) <= 54 )
		goto tr1281;
	goto tr1263;
tr1281:
#line 117 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st74;
st74:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof74;
case 74:
#line 3565 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 35: goto tr93;
		case 46: goto tr94;
	}
	goto tr4;
tr93:
#line 118 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
	goto st75;
st75:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof75;
case 75:
#line 3579 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 33: goto tr95;
		case 35: goto tr95;
		case 38: goto tr95;
		case 45: goto tr95;
		case 95: goto tr95;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 47 <= (*( sm->p)) && (*( sm->p)) <= 58 )
			goto tr95;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr95;
	} else
		goto tr95;
	goto tr4;
tr95:
#line 119 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st76;
st76:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof76;
case 76:
#line 3604 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 33: goto st76;
		case 35: goto st76;
		case 38: goto st76;
		case 46: goto tr97;
		case 95: goto st76;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 45 <= (*( sm->p)) && (*( sm->p)) <= 58 )
			goto st76;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st76;
	} else
		goto st76;
	goto tr4;
tr94:
#line 118 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
#line 119 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
#line 120 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
	goto st976;
tr97:
#line 120 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
	goto st976;
st976:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof976;
case 976:
#line 3637 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto st976;
		case 32: goto st976;
	}
	goto tr1282;
tr1261:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 751 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 127;}
	goto st977;
st977:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof977;
case 977:
#line 3653 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 67: goto st77;
		case 69: goto st84;
		case 72: goto st16;
		case 78: goto st93;
		case 81: goto st100;
		case 83: goto st105;
		case 84: goto st113;
		case 99: goto st77;
		case 101: goto st84;
		case 104: goto st16;
		case 110: goto st93;
		case 113: goto st100;
		case 115: goto st105;
		case 116: goto st113;
	}
	goto tr1263;
st77:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof77;
case 77:
	switch( (*( sm->p)) ) {
		case 79: goto st78;
		case 111: goto st78;
	}
	goto tr4;
st78:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof78;
case 78:
	switch( (*( sm->p)) ) {
		case 68: goto st79;
		case 100: goto st79;
	}
	goto tr4;
st79:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof79;
case 79:
	switch( (*( sm->p)) ) {
		case 69: goto st80;
		case 101: goto st80;
	}
	goto tr4;
st80:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof80;
case 80:
	switch( (*( sm->p)) ) {
		case 9: goto st81;
		case 32: goto st81;
		case 61: goto st82;
		case 93: goto tr46;
	}
	goto tr4;
st81:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof81;
case 81:
	switch( (*( sm->p)) ) {
		case 9: goto st81;
		case 32: goto st81;
		case 61: goto st82;
	}
	goto tr4;
st82:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof82;
case 82:
	switch( (*( sm->p)) ) {
		case 9: goto st82;
		case 32: goto st82;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr103;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr103;
	} else
		goto tr103;
	goto tr4;
tr103:
#line 117 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st83;
st83:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof83;
case 83:
#line 3744 "ext/dtext/dtext.cpp"
	if ( (*( sm->p)) == 93 )
		goto tr49;
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st83;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st83;
	} else
		goto st83;
	goto tr4;
st84:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof84;
case 84:
	switch( (*( sm->p)) ) {
		case 88: goto st85;
		case 120: goto st85;
	}
	goto tr4;
st85:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof85;
case 85:
	switch( (*( sm->p)) ) {
		case 80: goto st86;
		case 112: goto st86;
	}
	goto tr4;
st86:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof86;
case 86:
	switch( (*( sm->p)) ) {
		case 65: goto st87;
		case 97: goto st87;
	}
	goto tr4;
st87:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof87;
case 87:
	switch( (*( sm->p)) ) {
		case 78: goto st88;
		case 110: goto st88;
	}
	goto tr4;
st88:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof88;
case 88:
	switch( (*( sm->p)) ) {
		case 68: goto st89;
		case 100: goto st89;
	}
	goto tr4;
st89:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof89;
case 89:
	switch( (*( sm->p)) ) {
		case 9: goto st90;
		case 32: goto st90;
		case 61: goto st92;
		case 93: goto st972;
	}
	goto tr4;
tr113:
#line 117 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st90;
st90:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof90;
case 90:
#line 3820 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto tr113;
		case 10: goto tr4;
		case 13: goto tr4;
		case 32: goto tr113;
		case 61: goto tr114;
		case 93: goto tr69;
	}
	goto tr112;
tr112:
#line 117 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st91;
st91:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof91;
case 91:
#line 3838 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 10: goto tr4;
		case 13: goto tr4;
		case 93: goto tr71;
	}
	goto st91;
tr114:
#line 117 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st92;
st92:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof92;
case 92:
#line 3853 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto tr114;
		case 10: goto tr4;
		case 13: goto tr4;
		case 32: goto tr114;
		case 93: goto tr69;
	}
	goto tr112;
st93:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof93;
case 93:
	switch( (*( sm->p)) ) {
		case 79: goto st94;
		case 111: goto st94;
	}
	goto tr4;
st94:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof94;
case 94:
	switch( (*( sm->p)) ) {
		case 68: goto st95;
		case 100: goto st95;
	}
	goto tr4;
st95:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof95;
case 95:
	switch( (*( sm->p)) ) {
		case 84: goto st96;
		case 116: goto st96;
	}
	goto tr4;
st96:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof96;
case 96:
	switch( (*( sm->p)) ) {
		case 69: goto st97;
		case 101: goto st97;
	}
	goto tr4;
st97:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof97;
case 97:
	switch( (*( sm->p)) ) {
		case 88: goto st98;
		case 120: goto st98;
	}
	goto tr4;
st98:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof98;
case 98:
	switch( (*( sm->p)) ) {
		case 84: goto st99;
		case 116: goto st99;
	}
	goto tr4;
st99:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof99;
case 99:
	if ( (*( sm->p)) == 93 )
		goto tr78;
	goto tr4;
st100:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof100;
case 100:
	switch( (*( sm->p)) ) {
		case 85: goto st101;
		case 117: goto st101;
	}
	goto tr4;
st101:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof101;
case 101:
	switch( (*( sm->p)) ) {
		case 79: goto st102;
		case 111: goto st102;
	}
	goto tr4;
st102:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof102;
case 102:
	switch( (*( sm->p)) ) {
		case 84: goto st103;
		case 116: goto st103;
	}
	goto tr4;
st103:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof103;
case 103:
	switch( (*( sm->p)) ) {
		case 69: goto st104;
		case 101: goto st104;
	}
	goto tr4;
st104:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof104;
case 104:
	if ( (*( sm->p)) == 93 )
		goto st968;
	goto tr4;
st105:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof105;
case 105:
	switch( (*( sm->p)) ) {
		case 80: goto st106;
		case 112: goto st106;
	}
	goto tr4;
st106:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof106;
case 106:
	switch( (*( sm->p)) ) {
		case 79: goto st107;
		case 111: goto st107;
	}
	goto tr4;
st107:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof107;
case 107:
	switch( (*( sm->p)) ) {
		case 73: goto st108;
		case 105: goto st108;
	}
	goto tr4;
st108:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof108;
case 108:
	switch( (*( sm->p)) ) {
		case 76: goto st109;
		case 108: goto st109;
	}
	goto tr4;
st109:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof109;
case 109:
	switch( (*( sm->p)) ) {
		case 69: goto st110;
		case 101: goto st110;
	}
	goto tr4;
st110:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof110;
case 110:
	switch( (*( sm->p)) ) {
		case 82: goto st111;
		case 114: goto st111;
	}
	goto tr4;
st111:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof111;
case 111:
	switch( (*( sm->p)) ) {
		case 83: goto st112;
		case 93: goto st974;
		case 115: goto st112;
	}
	goto tr4;
st112:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof112;
case 112:
	if ( (*( sm->p)) == 93 )
		goto st974;
	goto tr4;
st113:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof113;
case 113:
	switch( (*( sm->p)) ) {
		case 65: goto st19;
		case 78: goto st114;
		case 97: goto st19;
		case 110: goto st114;
	}
	goto tr4;
st114:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof114;
case 114:
	if ( (*( sm->p)) == 93 )
		goto tr92;
	goto tr4;
tr1262:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
	goto st978;
st978:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof978;
case 978:
#line 4063 "ext/dtext/dtext.cpp"
	if ( (*( sm->p)) == 96 )
		goto st115;
	goto tr1263;
st115:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof115;
case 115:
	if ( (*( sm->p)) == 96 )
		goto st116;
	goto tr4;
tr136:
#line 117 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
#line 118 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
	goto st116;
st116:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof116;
case 116:
#line 4084 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr135;
		case 9: goto tr136;
		case 10: goto tr135;
		case 13: goto tr137;
		case 32: goto tr136;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr138;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr138;
	} else
		goto tr138;
	goto tr4;
tr151:
#line 118 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
	goto st117;
tr135:
#line 117 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
#line 118 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
	goto st117;
st117:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof117;
case 117:
#line 4115 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr140;
		case 10: goto tr140;
		case 13: goto tr141;
	}
	goto tr139;
tr139:
#line 119 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st118;
tr144:
#line 120 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
	goto st118;
tr141:
#line 119 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
#line 120 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
	goto st118;
st118:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof118;
case 118:
#line 4140 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr143;
		case 10: goto tr143;
		case 13: goto tr144;
	}
	goto st118;
tr143:
#line 120 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
	goto st119;
tr140:
#line 119 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
#line 120 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
	goto st119;
st119:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof119;
case 119:
#line 4161 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr143;
		case 10: goto tr143;
		case 13: goto tr144;
		case 96: goto st120;
	}
	goto st118;
st120:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof120;
case 120:
	switch( (*( sm->p)) ) {
		case 0: goto tr143;
		case 10: goto tr143;
		case 13: goto tr144;
		case 96: goto st121;
	}
	goto st118;
st121:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof121;
case 121:
	switch( (*( sm->p)) ) {
		case 0: goto tr143;
		case 10: goto tr143;
		case 13: goto tr144;
		case 96: goto st122;
	}
	goto st118;
st122:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof122;
case 122:
	switch( (*( sm->p)) ) {
		case 0: goto tr148;
		case 9: goto st122;
		case 10: goto tr148;
		case 13: goto tr149;
		case 32: goto st122;
	}
	goto st118;
tr149:
#line 120 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
	goto st123;
st123:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof123;
case 123:
#line 4211 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr143;
		case 10: goto tr148;
		case 13: goto tr144;
	}
	goto st118;
tr153:
#line 118 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
	goto st124;
tr137:
#line 117 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
#line 118 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
	goto st124;
st124:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof124;
case 124:
#line 4232 "ext/dtext/dtext.cpp"
	if ( (*( sm->p)) == 10 )
		goto st117;
	goto tr4;
tr138:
#line 117 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st125;
st125:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof125;
case 125:
#line 4244 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr151;
		case 9: goto tr152;
		case 10: goto tr151;
		case 13: goto tr153;
		case 32: goto tr152;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st125;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st125;
	} else
		goto st125;
	goto tr4;
tr152:
#line 118 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
	goto st126;
st126:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof126;
case 126:
#line 4269 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto st117;
		case 9: goto st126;
		case 10: goto st117;
		case 13: goto st124;
		case 32: goto st126;
	}
	goto tr4;
tr157:
#line 305 "ext/dtext/dtext.cpp.rl"
	{{( sm->p) = ((( sm->te)))-1;}{ append_html_escaped(sm, (*( sm->p))); }}
	goto st979;
tr163:
#line 297 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{ dstack_close_inline(sm, INLINE_B, "</strong>"); }}
	goto st979;
tr164:
#line 299 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{ dstack_close_inline(sm, INLINE_I, "</em>"); }}
	goto st979;
tr165:
#line 301 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{ dstack_close_inline(sm, INLINE_S, "</s>"); }}
	goto st979;
tr170:
#line 303 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{ dstack_close_inline(sm, INLINE_U, "</u>"); }}
	goto st979;
tr171:
#line 296 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{ dstack_open_inline(sm,  INLINE_B, "<strong>"); }}
	goto st979;
tr173:
#line 298 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{ dstack_open_inline(sm,  INLINE_I, "<em>"); }}
	goto st979;
tr174:
#line 300 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{ dstack_open_inline(sm,  INLINE_S, "<s>"); }}
	goto st979;
tr180:
#line 302 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{ dstack_open_inline(sm,  INLINE_U, "<u>"); }}
	goto st979;
tr1291:
#line 305 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{ append_html_escaped(sm, (*( sm->p))); }}
	goto st979;
tr1292:
#line 304 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;}
	goto st979;
tr1295:
#line 305 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{ append_html_escaped(sm, (*( sm->p))); }}
	goto st979;
st979:
#line 1 "NONE"
	{( sm->ts) = 0;}
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof979;
case 979:
#line 1 "NONE"
	{( sm->ts) = ( sm->p);}
#line 4334 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr1292;
		case 60: goto tr1293;
		case 91: goto tr1294;
	}
	goto tr1291;
tr1293:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
	goto st980;
st980:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof980;
case 980:
#line 4349 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 47: goto st127;
		case 66: goto st137;
		case 69: goto st138;
		case 73: goto st139;
		case 83: goto st140;
		case 85: goto st145;
		case 98: goto st137;
		case 101: goto st138;
		case 105: goto st139;
		case 115: goto st140;
		case 117: goto st145;
	}
	goto tr1295;
st127:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof127;
case 127:
	switch( (*( sm->p)) ) {
		case 66: goto st128;
		case 69: goto st129;
		case 73: goto st130;
		case 83: goto st131;
		case 85: goto st136;
		case 98: goto st128;
		case 101: goto st129;
		case 105: goto st130;
		case 115: goto st131;
		case 117: goto st136;
	}
	goto tr157;
st128:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof128;
case 128:
	if ( (*( sm->p)) == 62 )
		goto tr163;
	goto tr157;
st129:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof129;
case 129:
	switch( (*( sm->p)) ) {
		case 77: goto st130;
		case 109: goto st130;
	}
	goto tr157;
st130:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof130;
case 130:
	if ( (*( sm->p)) == 62 )
		goto tr164;
	goto tr157;
st131:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof131;
case 131:
	switch( (*( sm->p)) ) {
		case 62: goto tr165;
		case 84: goto st132;
		case 116: goto st132;
	}
	goto tr157;
st132:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof132;
case 132:
	switch( (*( sm->p)) ) {
		case 82: goto st133;
		case 114: goto st133;
	}
	goto tr157;
st133:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof133;
case 133:
	switch( (*( sm->p)) ) {
		case 79: goto st134;
		case 111: goto st134;
	}
	goto tr157;
st134:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof134;
case 134:
	switch( (*( sm->p)) ) {
		case 78: goto st135;
		case 110: goto st135;
	}
	goto tr157;
st135:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof135;
case 135:
	switch( (*( sm->p)) ) {
		case 71: goto st128;
		case 103: goto st128;
	}
	goto tr157;
st136:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof136;
case 136:
	if ( (*( sm->p)) == 62 )
		goto tr170;
	goto tr157;
st137:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof137;
case 137:
	if ( (*( sm->p)) == 62 )
		goto tr171;
	goto tr157;
st138:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof138;
case 138:
	switch( (*( sm->p)) ) {
		case 77: goto st139;
		case 109: goto st139;
	}
	goto tr157;
st139:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof139;
case 139:
	if ( (*( sm->p)) == 62 )
		goto tr173;
	goto tr157;
st140:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof140;
case 140:
	switch( (*( sm->p)) ) {
		case 62: goto tr174;
		case 84: goto st141;
		case 116: goto st141;
	}
	goto tr157;
st141:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof141;
case 141:
	switch( (*( sm->p)) ) {
		case 82: goto st142;
		case 114: goto st142;
	}
	goto tr157;
st142:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof142;
case 142:
	switch( (*( sm->p)) ) {
		case 79: goto st143;
		case 111: goto st143;
	}
	goto tr157;
st143:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof143;
case 143:
	switch( (*( sm->p)) ) {
		case 78: goto st144;
		case 110: goto st144;
	}
	goto tr157;
st144:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof144;
case 144:
	switch( (*( sm->p)) ) {
		case 71: goto st137;
		case 103: goto st137;
	}
	goto tr157;
st145:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof145;
case 145:
	if ( (*( sm->p)) == 62 )
		goto tr180;
	goto tr157;
tr1294:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
	goto st981;
st981:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof981;
case 981:
#line 4541 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 47: goto st146;
		case 66: goto st151;
		case 73: goto st152;
		case 83: goto st153;
		case 85: goto st154;
		case 98: goto st151;
		case 105: goto st152;
		case 115: goto st153;
		case 117: goto st154;
	}
	goto tr1295;
st146:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof146;
case 146:
	switch( (*( sm->p)) ) {
		case 66: goto st147;
		case 73: goto st148;
		case 83: goto st149;
		case 85: goto st150;
		case 98: goto st147;
		case 105: goto st148;
		case 115: goto st149;
		case 117: goto st150;
	}
	goto tr157;
st147:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof147;
case 147:
	if ( (*( sm->p)) == 93 )
		goto tr163;
	goto tr157;
st148:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof148;
case 148:
	if ( (*( sm->p)) == 93 )
		goto tr164;
	goto tr157;
st149:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof149;
case 149:
	if ( (*( sm->p)) == 93 )
		goto tr165;
	goto tr157;
st150:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof150;
case 150:
	if ( (*( sm->p)) == 93 )
		goto tr170;
	goto tr157;
st151:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof151;
case 151:
	if ( (*( sm->p)) == 93 )
		goto tr171;
	goto tr157;
st152:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof152;
case 152:
	if ( (*( sm->p)) == 93 )
		goto tr173;
	goto tr157;
st153:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof153;
case 153:
	if ( (*( sm->p)) == 93 )
		goto tr174;
	goto tr157;
st154:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof154;
case 154:
	if ( (*( sm->p)) == 93 )
		goto tr180;
	goto tr157;
tr185:
#line 1 "NONE"
	{	switch( ( sm->act) ) {
	case 56:
	{{( sm->p) = ((( sm->te)))-1;}
    append_mention(sm, { sm->a1, sm->a2 + 1 });
  }
	break;
	case 85:
	{{( sm->p) = ((( sm->te)))-1;}
    g_debug("inline [hr] (pos: %ld)", sm->ts - sm->pb);
    dstack_close_leaf_blocks(sm);
    {( sm->p) = (( sm->ts))-1;}
    { sm->cs = ( (sm->stack.data()))[--( sm->top)];goto _again;}
  }
	break;
	case 86:
	{{( sm->p) = ((( sm->te)))-1;}
    g_debug("inline newline2");
    g_debug("  return");

    dstack_close_list(sm);
    {( sm->p) = (( sm->ts))-1;}
    { sm->cs = ( (sm->stack.data()))[--( sm->top)];goto _again;}
  }
	break;
	case 87:
	{{( sm->p) = ((( sm->te)))-1;}
    g_debug("inline newline");

    if (sm->header_mode) {
      sm->header_mode = false;
      dstack_rewind(sm);
      { sm->cs = ( (sm->stack.data()))[--( sm->top)];goto _again;}
    } else if (dstack_is_open(sm, BLOCK_UL)) {
      dstack_close_list(sm);
      { sm->cs = ( (sm->stack.data()))[--( sm->top)];goto _again;}
    } else {
      append(sm, "<br>");
    }
  }
	break;
	case 90:
	{{( sm->p) = ((( sm->te)))-1;}
    append(sm, std::string_view { sm->ts, sm->te });
  }
	break;
	case 91:
	{{( sm->p) = ((( sm->te)))-1;}
    append_html_escaped(sm, (*( sm->p)));
  }
	break;
	default:
	{{( sm->p) = ((( sm->te)))-1;}}
	break;
	}
	}
	goto st982;
tr188:
#line 562 "ext/dtext/dtext.cpp.rl"
	{{( sm->p) = ((( sm->te)))-1;}{
    append(sm, std::string_view { sm->ts, sm->te });
  }}
	goto st982;
tr193:
#line 566 "ext/dtext/dtext.cpp.rl"
	{{( sm->p) = ((( sm->te)))-1;}{
    append_html_escaped(sm, (*( sm->p)));
  }}
	goto st982;
tr196:
#line 541 "ext/dtext/dtext.cpp.rl"
	{{( sm->p) = ((( sm->te)))-1;}{
    g_debug("inline newline");

    if (sm->header_mode) {
      sm->header_mode = false;
      dstack_rewind(sm);
      { sm->cs = ( (sm->stack.data()))[--( sm->top)];goto _again;}
    } else if (dstack_is_open(sm, BLOCK_UL)) {
      dstack_close_list(sm);
      { sm->cs = ( (sm->stack.data()))[--( sm->top)];goto _again;}
    } else {
      append(sm, "<br>");
    }
  }}
	goto st982;
tr215:
#line 440 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_close_leaf_blocks(sm);
    {( sm->p) = (( sm->ts))-1;}
    { sm->cs = ( (sm->stack.data()))[--( sm->top)];goto _again;}
  }}
	goto st982;
tr221:
#line 507 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_close_leaf_blocks(sm);
    {( sm->p) = (( sm->ts))-1;}
    { sm->cs = ( (sm->stack.data()))[--( sm->top)];goto _again;}
  }}
	goto st982;
tr238:
#line 532 "ext/dtext/dtext.cpp.rl"
	{{( sm->p) = ((( sm->te)))-1;}{
    g_debug("inline newline2");
    g_debug("  return");

    dstack_close_list(sm);
    {( sm->p) = (( sm->ts))-1;}
    { sm->cs = ( (sm->stack.data()))[--( sm->top)];goto _again;}
  }}
	goto st982;
tr244:
#line 519 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{
    if (dstack_close_block(sm, BLOCK_TD, "</td>")) {
      { sm->cs = ( (sm->stack.data()))[--( sm->top)];goto _again;}
    }
  }}
	goto st982;
tr245:
#line 513 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{
    if (dstack_close_block(sm, BLOCK_TH, "</th>")) {
      { sm->cs = ( (sm->stack.data()))[--( sm->top)];goto _again;}
    }
  }}
	goto st982;
tr246:
#line 414 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{
    g_debug("inline [/tn]");

    if (dstack_check(sm, INLINE_TN)) {
      dstack_close_inline(sm, INLINE_TN, "</span>");
    } else if (dstack_close_block(sm, BLOCK_TN, "</p>")) {
      { sm->cs = ( (sm->stack.data()))[--( sm->top)];goto _again;}
    }
  }}
	goto st982;
tr289:
#line 450 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{
    if (dstack_check(sm, INLINE_SPOILER)) {
      dstack_close_inline(sm, INLINE_SPOILER, "</span>");
    } else if (dstack_is_open(sm, BLOCK_SPOILER)) {
      dstack_close_until(sm, BLOCK_SPOILER);
      { sm->cs = ( (sm->stack.data()))[--( sm->top)];goto _again;}
    } else {
      append_html_escaped(sm, { sm->ts, sm->te });
    }
  }}
	goto st982;
tr296:
#line 469 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_close_leaf_blocks(sm);
    {( sm->p) = (( sm->ts))-1;}
    { sm->cs = ( (sm->stack.data()))[--( sm->top)];goto _again;}
  }}
	goto st982;
tr299:
#line 118 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
#line 469 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_close_leaf_blocks(sm);
    {( sm->p) = (( sm->ts))-1;}
    { sm->cs = ( (sm->stack.data()))[--( sm->top)];goto _again;}
  }}
	goto st982;
tr357:
#line 434 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_close_leaf_blocks(sm);
    {( sm->p) = (( sm->ts))-1;}
    { sm->cs = ( (sm->stack.data()))[--( sm->top)];goto _again;}
  }}
	goto st982;
tr383:
#line 120 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
#line 370 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{
    append_named_url(sm, { sm->b1, sm->b2 }, { sm->a1, sm->a2 });
  }}
	goto st982;
tr587:
#line 316 "ext/dtext/dtext.cpp.rl"
	{{( sm->p) = ((( sm->te)))-1;}{ append_id_link(sm, "dmail", "dmail", "/dmails/", { sm->a1, sm->a2 }); }}
	goto st982;
tr625:
#line 337 "ext/dtext/dtext.cpp.rl"
	{{( sm->p) = ((( sm->te)))-1;}{ append_id_link(sm, "pixiv", "pixiv", "https://www.pixiv.net/artworks/", { sm->a1, sm->a2 }); }}
	goto st982;
tr640:
#line 314 "ext/dtext/dtext.cpp.rl"
	{{( sm->p) = ((( sm->te)))-1;}{ append_id_link(sm, "topic", "forum-topic", "/forum_topics/", { sm->a1, sm->a2 }); }}
	goto st982;
tr655:
#line 402 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{ dstack_close_inline(sm, INLINE_B, "</strong>"); }}
	goto st982;
tr656:
#line 404 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{ dstack_close_inline(sm, INLINE_I, "</em>"); }}
	goto st982;
tr657:
#line 406 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{ dstack_close_inline(sm, INLINE_S, "</s>"); }}
	goto st982;
tr658:
#line 408 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{ dstack_close_inline(sm, INLINE_U, "</u>"); }}
	goto st982;
tr659:
#line 401 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{ dstack_open_inline(sm,  INLINE_B, "<strong>"); }}
	goto st982;
tr669:
#line 429 "ext/dtext/dtext.cpp.rl"
	{{( sm->p) = ((( sm->te)))-1;}{
    append_inline_code(sm, { sm->a1, sm->a2 });
    {
  size_t len = sm->stack.size();

  if (len > MAX_STACK_DEPTH) {
    // Should never happen.
    throw DTextError("too many nested elements");
  }

  if (sm->top >= len) {
    g_debug("growing sm->stack %zi", len + 16);
    sm->stack.resize(len + 16, 0);
  }
{( (sm->stack.data()))[( sm->top)++] = 982;goto st1233;}}
  }}
	goto st982;
tr670:
#line 429 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{
    append_inline_code(sm, { sm->a1, sm->a2 });
    {
  size_t len = sm->stack.size();

  if (len > MAX_STACK_DEPTH) {
    // Should never happen.
    throw DTextError("too many nested elements");
  }

  if (sm->top >= len) {
    g_debug("growing sm->stack %zi", len + 16);
    sm->stack.resize(len + 16, 0);
  }
{( (sm->stack.data()))[( sm->top)++] = 982;goto st1233;}}
  }}
	goto st982;
tr673:
#line 424 "ext/dtext/dtext.cpp.rl"
	{{( sm->p) = ((( sm->te)))-1;}{
    append_inline_code(sm);
    {
  size_t len = sm->stack.size();

  if (len > MAX_STACK_DEPTH) {
    // Should never happen.
    throw DTextError("too many nested elements");
  }

  if (sm->top >= len) {
    g_debug("growing sm->stack %zi", len + 16);
    sm->stack.resize(len + 16, 0);
  }
{( (sm->stack.data()))[( sm->top)++] = 982;goto st1233;}}
  }}
	goto st982;
tr674:
#line 424 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{
    append_inline_code(sm);
    {
  size_t len = sm->stack.size();

  if (len > MAX_STACK_DEPTH) {
    // Should never happen.
    throw DTextError("too many nested elements");
  }

  if (sm->top >= len) {
    g_debug("growing sm->stack %zi", len + 16);
    sm->stack.resize(len + 16, 0);
  }
{( (sm->stack.data()))[( sm->top)++] = 982;goto st1233;}}
  }}
	goto st982;
tr684:
#line 494 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{
    g_debug("inline [expand]");
    dstack_close_leaf_blocks(sm);
    {( sm->p) = (( sm->ts))-1;}
    { sm->cs = ( (sm->stack.data()))[--( sm->top)];goto _again;}
  }}
	goto st982;
tr688:
#line 117 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
#line 118 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
#line 494 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{
    g_debug("inline [expand]");
    dstack_close_leaf_blocks(sm);
    {( sm->p) = (( sm->ts))-1;}
    { sm->cs = ( (sm->stack.data()))[--( sm->top)];goto _again;}
  }}
	goto st982;
tr690:
#line 118 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
#line 494 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{
    g_debug("inline [expand]");
    dstack_close_leaf_blocks(sm);
    {( sm->p) = (( sm->ts))-1;}
    { sm->cs = ( (sm->stack.data()))[--( sm->top)];goto _again;}
  }}
	goto st982;
tr703:
#line 120 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
#line 374 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{
    append_named_url(sm, { sm->a1, sm->a2 }, { sm->b1, sm->b2 });
  }}
	goto st982;
tr704:
#line 403 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{ dstack_open_inline(sm,  INLINE_I, "<em>"); }}
	goto st982;
tr712:
#line 461 "ext/dtext/dtext.cpp.rl"
	{{( sm->p) = ((( sm->te)))-1;}{
    dstack_open_inline(sm, INLINE_NODTEXT, "");
    {
  size_t len = sm->stack.size();

  if (len > MAX_STACK_DEPTH) {
    // Should never happen.
    throw DTextError("too many nested elements");
  }

  if (sm->top >= len) {
    g_debug("growing sm->stack %zi", len + 16);
    sm->stack.resize(len + 16, 0);
  }
{( (sm->stack.data()))[( sm->top)++] = 982;goto st1238;}}
  }}
	goto st982;
tr713:
#line 461 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_open_inline(sm, INLINE_NODTEXT, "");
    {
  size_t len = sm->stack.size();

  if (len > MAX_STACK_DEPTH) {
    // Should never happen.
    throw DTextError("too many nested elements");
  }

  if (sm->top >= len) {
    g_debug("growing sm->stack %zi", len + 16);
    sm->stack.resize(len + 16, 0);
  }
{( (sm->stack.data()))[( sm->top)++] = 982;goto st1238;}}
  }}
	goto st982;
tr720:
#line 481 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{
    g_debug("inline [quote]");
    dstack_close_leaf_blocks(sm);
    {( sm->p) = (( sm->ts))-1;}
    { sm->cs = ( (sm->stack.data()))[--( sm->top)];goto _again;}
  }}
	goto st982;
tr722:
#line 405 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{ dstack_open_inline(sm,  INLINE_S, "<s>"); }}
	goto st982;
tr729:
#line 446 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_open_inline(sm, INLINE_SPOILER, "<span class=\"spoiler\">");
  }}
	goto st982;
tr731:
#line 410 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_open_inline(sm, INLINE_TN, "<span class=\"tn\">");
  }}
	goto st982;
tr732:
#line 407 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{ dstack_open_inline(sm,  INLINE_U, "<u>"); }}
	goto st982;
tr760:
#line 374 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{
    append_named_url(sm, { sm->a1, sm->a2 }, { sm->b1, sm->b2 });
  }}
	goto st982;
tr804:
#line 118 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
#line 382 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{
    append_unnamed_url(sm, { sm->a1, sm->a2 });
  }}
	goto st982;
tr826:
#line 118 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
#line 390 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{
    g_debug("delimited mention: <@%.*s>", (int)(sm->a2 - sm->a1), sm->a1);
    append_mention(sm, { sm->a1, sm->a2 });
  }}
	goto st982;
tr1305:
#line 566 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{
    append_html_escaped(sm, (*( sm->p)));
  }}
	goto st982;
tr1337:
#line 566 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append_html_escaped(sm, (*( sm->p)));
  }}
	goto st982;
tr1338:
#line 562 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append(sm, std::string_view { sm->ts, sm->te });
  }}
	goto st982;
tr1340:
#line 541 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    g_debug("inline newline");

    if (sm->header_mode) {
      sm->header_mode = false;
      dstack_rewind(sm);
      { sm->cs = ( (sm->stack.data()))[--( sm->top)];goto _again;}
    } else if (dstack_is_open(sm, BLOCK_UL)) {
      dstack_close_list(sm);
      { sm->cs = ( (sm->stack.data()))[--( sm->top)];goto _again;}
    } else {
      append(sm, "<br>");
    }
  }}
	goto st982;
tr1347:
#line 525 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    g_debug("inline [hr] (pos: %ld)", sm->ts - sm->pb);
    dstack_close_leaf_blocks(sm);
    {( sm->p) = (( sm->ts))-1;}
    { sm->cs = ( (sm->stack.data()))[--( sm->top)];goto _again;}
  }}
	goto st982;
tr1348:
#line 532 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    g_debug("inline newline2");
    g_debug("  return");

    dstack_close_list(sm);
    {( sm->p) = (( sm->ts))-1;}
    { sm->cs = ( (sm->stack.data()))[--( sm->top)];goto _again;}
  }}
	goto st982;
tr1351:
#line 120 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
#line 395 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    g_debug("inline list");
    {( sm->p) = (( sm->ts + 1))-1;}
    { sm->cs = ( (sm->stack.data()))[--( sm->top)];goto _again;}
  }}
	goto st982;
tr1353:
#line 488 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    g_debug("inline [/quote]");
    dstack_close_until(sm, BLOCK_QUOTE);
    { sm->cs = ( (sm->stack.data()))[--( sm->top)];goto _again;}
  }}
	goto st982;
tr1354:
#line 501 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    g_debug("inline [/expand]");
    dstack_close_until(sm, BLOCK_EXPAND);
    { sm->cs = ( (sm->stack.data()))[--( sm->top)];goto _again;}
  }}
	goto st982;
tr1355:
#line 475 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    dstack_close_leaf_blocks(sm);
    {( sm->p) = (( sm->ts))-1;}
    { sm->cs = ( (sm->stack.data()))[--( sm->top)];goto _again;}
  }}
	goto st982;
tr1357:
#line 556 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append(sm, ' ');
  }}
	goto st982;
tr1359:
#line 120 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
#line 366 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append_bare_named_url(sm, { sm->b1, sm->b2 }, { sm->a1, sm->a2 });
  }}
	goto st982;
tr1363:
#line 125 "ext/dtext/dtext.cpp.rl"
	{ sm->e1 = sm->p; }
#line 126 "ext/dtext/dtext.cpp.rl"
	{ sm->e2 = sm->p; }
#line 358 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append_wiki_link(sm, { sm->a1, sm->a2 }, { sm->b1, sm->b2 }, { sm->c1, sm->c2 }, { sm->b1, sm->b2 }, { sm->e1, sm->e2 });
  }}
	goto st982;
tr1365:
#line 126 "ext/dtext/dtext.cpp.rl"
	{ sm->e2 = sm->p; }
#line 358 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append_wiki_link(sm, { sm->a1, sm->a2 }, { sm->b1, sm->b2 }, { sm->c1, sm->c2 }, { sm->b1, sm->b2 }, { sm->e1, sm->e2 });
  }}
	goto st982;
tr1367:
#line 125 "ext/dtext/dtext.cpp.rl"
	{ sm->e1 = sm->p; }
#line 126 "ext/dtext/dtext.cpp.rl"
	{ sm->e2 = sm->p; }
#line 362 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append_wiki_link(sm, { sm->a1, sm->a2 }, { sm->b1, sm->b2 }, { sm->c1, sm->c2 }, { sm->d1, sm->d2 }, { sm->e1, sm->e2 });
  }}
	goto st982;
tr1369:
#line 126 "ext/dtext/dtext.cpp.rl"
	{ sm->e2 = sm->p; }
#line 362 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append_wiki_link(sm, { sm->a1, sm->a2 }, { sm->b1, sm->b2 }, { sm->c1, sm->c2 }, { sm->d1, sm->d2 }, { sm->e1, sm->e2 });
  }}
	goto st982;
tr1373:
#line 123 "ext/dtext/dtext.cpp.rl"
	{ sm->d1 = sm->p; }
#line 124 "ext/dtext/dtext.cpp.rl"
	{ sm->d2 = sm->p; }
#line 354 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append_post_search_link(sm, { sm->a1, sm->a2 }, { sm->b1, sm->b2 }, { sm->c1, sm->c2 }, { sm->d1, sm->d2 });
  }}
	goto st982;
tr1375:
#line 124 "ext/dtext/dtext.cpp.rl"
	{ sm->d2 = sm->p; }
#line 354 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append_post_search_link(sm, { sm->a1, sm->a2 }, { sm->b1, sm->b2 }, { sm->c1, sm->c2 }, { sm->d1, sm->d2 });
  }}
	goto st982;
tr1377:
#line 123 "ext/dtext/dtext.cpp.rl"
	{ sm->d1 = sm->p; }
#line 124 "ext/dtext/dtext.cpp.rl"
	{ sm->d2 = sm->p; }
#line 350 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append_post_search_link(sm, { sm->a1, sm->a2 }, { sm->b1, sm->b2 }, { sm->b1, sm->b2 }, { sm->d1, sm->d2 });
  }}
	goto st982;
tr1379:
#line 124 "ext/dtext/dtext.cpp.rl"
	{ sm->d2 = sm->p; }
#line 350 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append_post_search_link(sm, { sm->a1, sm->a2 }, { sm->b1, sm->b2 }, { sm->b1, sm->b2 }, { sm->d1, sm->d2 });
  }}
	goto st982;
tr1391:
#line 118 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
#line 322 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{ append_id_link(sm, "alias", "tag-alias", "/tag_aliases/", { sm->a1, sm->a2 }); }}
	goto st982;
tr1398:
#line 118 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
#line 310 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{ append_id_link(sm, "appeal", "post-appeal", "/post_appeals/", { sm->a1, sm->a2 }); }}
	goto st982;
tr1406:
#line 118 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
#line 319 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{ append_id_link(sm, "artist", "artist", "/artists/", { sm->a1, sm->a2 }); }}
	goto st982;
tr1415:
#line 118 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
#line 333 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{ append_id_link(sm, "artstation", "artstation", "https://www.artstation.com/artwork/", { sm->a1, sm->a2 }); }}
	goto st982;
tr1421:
#line 118 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
#line 320 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{ append_id_link(sm, "ban", "ban", "/bans/", { sm->a1, sm->a2 }); }}
	goto st982;
tr1425:
#line 118 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
#line 321 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{ append_id_link(sm, "BUR", "bulk-update-request", "/bulk_update_requests/", { sm->a1, sm->a2 }); }}
	goto st982;
tr1435:
#line 118 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
#line 315 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{ append_id_link(sm, "comment", "comment", "/comments/", { sm->a1, sm->a2 }); }}
	goto st982;
tr1439:
#line 118 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
#line 332 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{ append_id_link(sm, "commit", "github-commit", "https://github.com/danbooru/danbooru/commit/", { sm->a1, sm->a2 }); }}
	goto st982;
tr1452:
#line 118 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
#line 334 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{ append_id_link(sm, "deviantart", "deviantart", "https://www.deviantart.com/deviation/", { sm->a1, sm->a2 }); }}
	goto st982;
tr1458:
#line 118 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
#line 316 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{ append_id_link(sm, "dmail", "dmail", "/dmails/", { sm->a1, sm->a2 }); }}
	goto st982;
tr1461:
#line 120 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
#line 345 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{ append_dmail_key_link(sm); }}
	goto st982;
tr1474:
#line 118 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
#line 324 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{ append_id_link(sm, "favgroup", "favorite-group", "/favorite_groups/", { sm->a1, sm->a2 }); }}
	goto st982;
tr1483:
#line 118 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
#line 327 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{ append_id_link(sm, "feedback", "user-feedback", "/user_feedbacks/", { sm->a1, sm->a2 }); }}
	goto st982;
tr1488:
#line 118 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
#line 311 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{ append_id_link(sm, "flag", "post-flag", "/post_flags/", { sm->a1, sm->a2 }); }}
	goto st982;
tr1494:
#line 118 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
#line 313 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{ append_id_link(sm, "forum", "forum-post", "/forum_posts/", { sm->a1, sm->a2 }); }}
	goto st982;
tr1504:
#line 118 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
#line 343 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{ append_id_link(sm, "gelbooru", "gelbooru", "https://gelbooru.com/index.php?page=post&s=view&id=", { sm->a1, sm->a2 }); }}
	goto st982;
tr1511:
#line 378 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append_bare_unnamed_url(sm, { sm->ts, sm->te });
  }}
	goto st982;
tr1524:
#line 118 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
#line 323 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{ append_id_link(sm, "implication", "tag-implication", "/tag_implications/", { sm->a1, sm->a2 }); }}
	goto st982;
tr1530:
#line 118 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
#line 330 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{ append_id_link(sm, "issue", "github", "https://github.com/danbooru/danbooru/issues/", { sm->a1, sm->a2 }); }}
	goto st982;
tr1536:
#line 118 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
#line 325 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{ append_id_link(sm, "mod action", "mod-action", "/mod_actions/", { sm->a1, sm->a2 }); }}
	goto st982;
tr1544:
#line 118 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
#line 326 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{ append_id_link(sm, "modreport", "moderation-report", "/moderation_reports/", { sm->a1, sm->a2 }); }}
	goto st982;
tr1552:
#line 118 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
#line 335 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{ append_id_link(sm, "nijie", "nijie", "https://nijie.info/view.php?id=", { sm->a1, sm->a2 }); }}
	goto st982;
tr1557:
#line 118 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
#line 312 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{ append_id_link(sm, "note", "note", "/notes/", { sm->a1, sm->a2 }); }}
	goto st982;
tr1567:
#line 118 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
#line 336 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{ append_id_link(sm, "pawoo", "pawoo", "https://pawoo.net/web/statuses/", { sm->a1, sm->a2 }); }}
	goto st982;
tr1573:
#line 118 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
#line 337 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{ append_id_link(sm, "pixiv", "pixiv", "https://www.pixiv.net/artworks/", { sm->a1, sm->a2 }); }}
	goto st982;
tr1576:
#line 120 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
#line 348 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{ append_paged_link(sm, "pixiv #", "<a rel=\"external nofollow noreferrer\" class=\"dtext-link dtext-id-link dtext-pixiv-id-link\" href=\"", "https://www.pixiv.net/artworks/", "#"); }}
	goto st982;
tr1582:
#line 118 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
#line 317 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{ append_id_link(sm, "pool", "pool", "/pools/", { sm->a1, sm->a2 }); }}
	goto st982;
tr1586:
#line 118 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
#line 309 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{ append_id_link(sm, "post", "post", "/posts/", { sm->a1, sm->a2 }); }}
	goto st982;
tr1591:
#line 118 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
#line 331 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{ append_id_link(sm, "pull", "github-pull", "https://github.com/danbooru/danbooru/pull/", { sm->a1, sm->a2 }); }}
	goto st982;
tr1601:
#line 118 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
#line 342 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{ append_id_link(sm, "sankaku", "sankaku", "https://chan.sankakucomplex.com/post/show/", { sm->a1, sm->a2 }); }}
	goto st982;
tr1607:
#line 118 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
#line 338 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{ append_id_link(sm, "seiga", "seiga", "https://seiga.nicovideo.jp/seiga/im", { sm->a1, sm->a2 }); }}
	goto st982;
tr1615:
#line 118 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
#line 314 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{ append_id_link(sm, "topic", "forum-topic", "/forum_topics/", { sm->a1, sm->a2 }); }}
	goto st982;
tr1618:
#line 120 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
#line 347 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{ append_paged_link(sm, "topic #", "<a class=\"dtext-link dtext-id-link dtext-forum-topic-id-link\" href=\"", "/forum_topics/", "?page="); }}
	goto st982;
tr1626:
#line 118 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
#line 339 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{ append_id_link(sm, "twitter", "twitter", "https://twitter.com/i/web/status/", { sm->a1, sm->a2 }); }}
	goto st982;
tr1632:
#line 118 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
#line 318 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{ append_id_link(sm, "user", "user", "/users/", { sm->a1, sm->a2 }); }}
	goto st982;
tr1638:
#line 118 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
#line 328 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{ append_id_link(sm, "wiki", "wiki-page", "/wiki_pages/", { sm->a1, sm->a2 }); }}
	goto st982;
tr1647:
#line 118 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
#line 341 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{ append_id_link(sm, "yandere", "yandere", "https://yande.re/post/show/", { sm->a1, sm->a2 }); }}
	goto st982;
tr1660:
#line 429 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append_inline_code(sm, { sm->a1, sm->a2 });
    {
  size_t len = sm->stack.size();

  if (len > MAX_STACK_DEPTH) {
    // Should never happen.
    throw DTextError("too many nested elements");
  }

  if (sm->top >= len) {
    g_debug("growing sm->stack %zi", len + 16);
    sm->stack.resize(len + 16, 0);
  }
{( (sm->stack.data()))[( sm->top)++] = 982;goto st1233;}}
  }}
	goto st982;
tr1661:
#line 424 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append_inline_code(sm);
    {
  size_t len = sm->stack.size();

  if (len > MAX_STACK_DEPTH) {
    // Should never happen.
    throw DTextError("too many nested elements");
  }

  if (sm->top >= len) {
    g_debug("growing sm->stack %zi", len + 16);
    sm->stack.resize(len + 16, 0);
  }
{( (sm->stack.data()))[( sm->top)++] = 982;goto st1233;}}
  }}
	goto st982;
tr1662:
#line 461 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    dstack_open_inline(sm, INLINE_NODTEXT, "");
    {
  size_t len = sm->stack.size();

  if (len > MAX_STACK_DEPTH) {
    // Should never happen.
    throw DTextError("too many nested elements");
  }

  if (sm->top >= len) {
    g_debug("growing sm->stack %zi", len + 16);
    sm->stack.resize(len + 16, 0);
  }
{( (sm->stack.data()))[( sm->top)++] = 982;goto st1238;}}
  }}
	goto st982;
tr1682:
#line 386 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append_mention(sm, { sm->a1, sm->a2 + 1 });
  }}
	goto st982;
st982:
#line 1 "NONE"
	{( sm->ts) = 0;}
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof982;
case 982:
#line 1 "NONE"
	{( sm->ts) = ( sm->p);}
#line 5525 "ext/dtext/dtext.cpp"
	_widec = (*( sm->p));
	if ( (*( sm->p)) > 60 ) {
		if ( 64 <= (*( sm->p)) && (*( sm->p)) <= 64 ) {
			_widec = (short)(1152 + ((*( sm->p)) - -128));
			if ( 
#line 128 "ext/dtext/dtext.cpp.rl"
 is_mention_boundary(p[-1])  ) _widec += 256;
			if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 512;
		}
	} else if ( (*( sm->p)) >= 60 ) {
		_widec = (short)(640 + ((*( sm->p)) - -128));
		if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
	}
	switch( _widec ) {
		case 0: goto tr1309;
		case 9: goto tr1310;
		case 10: goto tr1311;
		case 13: goto st997;
		case 32: goto tr1310;
		case 34: goto tr1313;
		case 65: goto tr1316;
		case 66: goto tr1317;
		case 67: goto tr1318;
		case 68: goto tr1319;
		case 70: goto tr1320;
		case 71: goto tr1321;
		case 72: goto tr1322;
		case 73: goto tr1323;
		case 77: goto tr1324;
		case 78: goto tr1325;
		case 80: goto tr1326;
		case 83: goto tr1327;
		case 84: goto tr1328;
		case 85: goto tr1329;
		case 87: goto tr1330;
		case 89: goto tr1331;
		case 91: goto tr1332;
		case 97: goto tr1316;
		case 98: goto tr1317;
		case 99: goto tr1318;
		case 100: goto tr1319;
		case 102: goto tr1320;
		case 103: goto tr1321;
		case 104: goto tr1322;
		case 105: goto tr1323;
		case 109: goto tr1324;
		case 110: goto tr1325;
		case 112: goto tr1326;
		case 115: goto tr1327;
		case 116: goto tr1328;
		case 117: goto tr1329;
		case 119: goto tr1330;
		case 121: goto tr1331;
		case 123: goto tr1333;
		case 828: goto tr1334;
		case 1084: goto tr1335;
		case 1344: goto tr1305;
		case 1600: goto tr1305;
		case 1856: goto tr1305;
		case 2112: goto tr1336;
	}
	if ( _widec < 48 ) {
		if ( _widec < -32 ) {
			if ( _widec > -63 ) {
				if ( -62 <= _widec && _widec <= -33 )
					goto st983;
			} else
				goto tr1305;
		} else if ( _widec > -17 ) {
			if ( _widec > -12 ) {
				if ( -11 <= _widec && _widec <= 47 )
					goto tr1305;
			} else if ( _widec >= -16 )
				goto tr1308;
		} else
			goto tr1307;
	} else if ( _widec > 57 ) {
		if ( _widec < 69 ) {
			if ( _widec > 59 ) {
				if ( 61 <= _widec && _widec <= 63 )
					goto tr1305;
			} else if ( _widec >= 58 )
				goto tr1305;
		} else if ( _widec > 90 ) {
			if ( _widec < 101 ) {
				if ( 92 <= _widec && _widec <= 96 )
					goto tr1305;
			} else if ( _widec > 122 ) {
				if ( 124 <= _widec )
					goto tr1305;
			} else
				goto tr1314;
		} else
			goto tr1314;
	} else
		goto tr1314;
	goto st0;
st983:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof983;
case 983:
	if ( (*( sm->p)) <= -65 )
		goto tr186;
	goto tr1337;
tr186:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 562 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st984;
st984:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof984;
case 984:
#line 5644 "ext/dtext/dtext.cpp"
	if ( (*( sm->p)) < -32 ) {
		if ( -62 <= (*( sm->p)) && (*( sm->p)) <= -33 )
			goto st155;
	} else if ( (*( sm->p)) > -17 ) {
		if ( -16 <= (*( sm->p)) && (*( sm->p)) <= -12 )
			goto st157;
	} else
		goto st156;
	goto tr1338;
st155:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof155;
case 155:
	if ( (*( sm->p)) <= -65 )
		goto tr186;
	goto tr185;
st156:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof156;
case 156:
	if ( (*( sm->p)) <= -65 )
		goto st155;
	goto tr185;
st157:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof157;
case 157:
	if ( (*( sm->p)) <= -65 )
		goto st156;
	goto tr188;
tr1307:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 566 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 91;}
	goto st985;
st985:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof985;
case 985:
#line 5685 "ext/dtext/dtext.cpp"
	if ( (*( sm->p)) <= -65 )
		goto st155;
	goto tr1337;
tr1308:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 566 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 91;}
	goto st986;
st986:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof986;
case 986:
#line 5699 "ext/dtext/dtext.cpp"
	if ( (*( sm->p)) <= -65 )
		goto st156;
	goto tr1337;
tr190:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 532 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 86;}
	goto st987;
tr1309:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 560 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 89;}
	goto st987;
st987:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof987;
case 987:
#line 5719 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr190;
		case 9: goto st158;
		case 10: goto tr190;
		case 13: goto st159;
		case 32: goto st158;
	}
	goto tr185;
st158:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof158;
case 158:
	switch( (*( sm->p)) ) {
		case 0: goto tr190;
		case 9: goto st158;
		case 10: goto tr190;
		case 13: goto st159;
		case 32: goto st158;
	}
	goto tr185;
st159:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof159;
case 159:
	if ( (*( sm->p)) == 10 )
		goto tr190;
	goto tr185;
tr1310:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 566 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 91;}
	goto st988;
st988:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof988;
case 988:
#line 5757 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto st158;
		case 9: goto st160;
		case 10: goto st158;
		case 13: goto st161;
		case 32: goto st160;
	}
	goto tr1337;
st160:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof160;
case 160:
	switch( (*( sm->p)) ) {
		case 0: goto st158;
		case 9: goto st160;
		case 10: goto st158;
		case 13: goto st161;
		case 32: goto st160;
	}
	goto tr193;
st161:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof161;
case 161:
	if ( (*( sm->p)) == 10 )
		goto st158;
	goto tr193;
tr1311:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 541 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 87;}
	goto st989;
st989:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof989;
case 989:
#line 5795 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr190;
		case 9: goto st162;
		case 10: goto tr237;
		case 13: goto st199;
		case 32: goto st162;
		case 42: goto tr1342;
		case 60: goto st214;
		case 72: goto st259;
		case 91: goto st263;
		case 96: goto st293;
		case 104: goto st259;
	}
	goto tr1340;
st162:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof162;
case 162:
	switch( (*( sm->p)) ) {
		case 0: goto tr190;
		case 9: goto st162;
		case 10: goto tr190;
		case 13: goto st159;
		case 32: goto st162;
		case 60: goto st163;
		case 91: goto st183;
	}
	goto tr196;
st163:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof163;
case 163:
	switch( (*( sm->p)) ) {
		case 72: goto st164;
		case 83: goto st168;
		case 84: goto st178;
		case 104: goto st164;
		case 115: goto st168;
		case 116: goto st178;
	}
	goto tr196;
st164:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof164;
case 164:
	switch( (*( sm->p)) ) {
		case 82: goto st165;
		case 114: goto st165;
	}
	goto tr196;
st165:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof165;
case 165:
	if ( (*( sm->p)) == 62 )
		goto st166;
	goto tr196;
st166:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof166;
case 166:
	switch( (*( sm->p)) ) {
		case 0: goto tr205;
		case 9: goto st166;
		case 10: goto tr205;
		case 13: goto st167;
		case 32: goto st166;
	}
	goto tr196;
tr205:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 525 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 85;}
	goto st990;
st990:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof990;
case 990:
#line 5875 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr205;
		case 10: goto tr205;
		case 13: goto st167;
	}
	goto tr1347;
st167:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof167;
case 167:
	if ( (*( sm->p)) == 10 )
		goto tr205;
	goto tr185;
st168:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof168;
case 168:
	switch( (*( sm->p)) ) {
		case 80: goto st169;
		case 112: goto st169;
	}
	goto tr196;
st169:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof169;
case 169:
	switch( (*( sm->p)) ) {
		case 79: goto st170;
		case 111: goto st170;
	}
	goto tr196;
st170:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof170;
case 170:
	switch( (*( sm->p)) ) {
		case 73: goto st171;
		case 105: goto st171;
	}
	goto tr196;
st171:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof171;
case 171:
	switch( (*( sm->p)) ) {
		case 76: goto st172;
		case 108: goto st172;
	}
	goto tr196;
st172:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof172;
case 172:
	switch( (*( sm->p)) ) {
		case 69: goto st173;
		case 101: goto st173;
	}
	goto tr196;
st173:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof173;
case 173:
	switch( (*( sm->p)) ) {
		case 82: goto st174;
		case 114: goto st174;
	}
	goto tr196;
st174:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof174;
case 174:
	switch( (*( sm->p)) ) {
		case 62: goto st175;
		case 83: goto st177;
		case 115: goto st177;
	}
	goto tr196;
st175:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof175;
case 175:
	switch( (*( sm->p)) ) {
		case 0: goto tr215;
		case 9: goto st175;
		case 10: goto tr215;
		case 13: goto st176;
		case 32: goto st175;
	}
	goto tr196;
st176:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof176;
case 176:
	if ( (*( sm->p)) == 10 )
		goto tr215;
	goto tr196;
st177:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof177;
case 177:
	if ( (*( sm->p)) == 62 )
		goto st175;
	goto tr196;
st178:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof178;
case 178:
	switch( (*( sm->p)) ) {
		case 65: goto st179;
		case 97: goto st179;
	}
	goto tr196;
st179:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof179;
case 179:
	switch( (*( sm->p)) ) {
		case 66: goto st180;
		case 98: goto st180;
	}
	goto tr196;
st180:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof180;
case 180:
	switch( (*( sm->p)) ) {
		case 76: goto st181;
		case 108: goto st181;
	}
	goto tr196;
st181:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof181;
case 181:
	switch( (*( sm->p)) ) {
		case 69: goto st182;
		case 101: goto st182;
	}
	goto tr196;
st182:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof182;
case 182:
	if ( (*( sm->p)) == 62 )
		goto tr221;
	goto tr196;
st183:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof183;
case 183:
	switch( (*( sm->p)) ) {
		case 72: goto st184;
		case 83: goto st186;
		case 84: goto st194;
		case 104: goto st184;
		case 115: goto st186;
		case 116: goto st194;
	}
	goto tr196;
st184:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof184;
case 184:
	switch( (*( sm->p)) ) {
		case 82: goto st185;
		case 114: goto st185;
	}
	goto tr196;
st185:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof185;
case 185:
	if ( (*( sm->p)) == 93 )
		goto st166;
	goto tr196;
st186:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof186;
case 186:
	switch( (*( sm->p)) ) {
		case 80: goto st187;
		case 112: goto st187;
	}
	goto tr196;
st187:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof187;
case 187:
	switch( (*( sm->p)) ) {
		case 79: goto st188;
		case 111: goto st188;
	}
	goto tr196;
st188:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof188;
case 188:
	switch( (*( sm->p)) ) {
		case 73: goto st189;
		case 105: goto st189;
	}
	goto tr196;
st189:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof189;
case 189:
	switch( (*( sm->p)) ) {
		case 76: goto st190;
		case 108: goto st190;
	}
	goto tr196;
st190:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof190;
case 190:
	switch( (*( sm->p)) ) {
		case 69: goto st191;
		case 101: goto st191;
	}
	goto tr196;
st191:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof191;
case 191:
	switch( (*( sm->p)) ) {
		case 82: goto st192;
		case 114: goto st192;
	}
	goto tr196;
st192:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof192;
case 192:
	switch( (*( sm->p)) ) {
		case 83: goto st193;
		case 93: goto st175;
		case 115: goto st193;
	}
	goto tr196;
st193:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof193;
case 193:
	if ( (*( sm->p)) == 93 )
		goto st175;
	goto tr196;
st194:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof194;
case 194:
	switch( (*( sm->p)) ) {
		case 65: goto st195;
		case 97: goto st195;
	}
	goto tr196;
st195:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof195;
case 195:
	switch( (*( sm->p)) ) {
		case 66: goto st196;
		case 98: goto st196;
	}
	goto tr196;
st196:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof196;
case 196:
	switch( (*( sm->p)) ) {
		case 76: goto st197;
		case 108: goto st197;
	}
	goto tr196;
st197:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof197;
case 197:
	switch( (*( sm->p)) ) {
		case 69: goto st198;
		case 101: goto st198;
	}
	goto tr196;
st198:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof198;
case 198:
	if ( (*( sm->p)) == 93 )
		goto tr221;
	goto tr196;
tr237:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 532 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 86;}
	goto st991;
st991:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof991;
case 991:
#line 6175 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr190;
		case 9: goto st158;
		case 10: goto tr237;
		case 13: goto st199;
		case 32: goto st158;
		case 60: goto st200;
		case 91: goto st206;
	}
	goto tr1348;
st199:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof199;
case 199:
	if ( (*( sm->p)) == 10 )
		goto tr237;
	goto tr185;
st200:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof200;
case 200:
	if ( (*( sm->p)) == 47 )
		goto st201;
	goto tr238;
st201:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof201;
case 201:
	switch( (*( sm->p)) ) {
		case 84: goto st202;
		case 116: goto st202;
	}
	goto tr238;
st202:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof202;
case 202:
	switch( (*( sm->p)) ) {
		case 68: goto st203;
		case 72: goto st204;
		case 78: goto st205;
		case 100: goto st203;
		case 104: goto st204;
		case 110: goto st205;
	}
	goto tr185;
st203:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof203;
case 203:
	if ( (*( sm->p)) == 62 )
		goto tr244;
	goto tr185;
st204:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof204;
case 204:
	if ( (*( sm->p)) == 62 )
		goto tr245;
	goto tr185;
st205:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof205;
case 205:
	if ( (*( sm->p)) == 62 )
		goto tr246;
	goto tr185;
st206:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof206;
case 206:
	if ( (*( sm->p)) == 47 )
		goto st207;
	goto tr238;
st207:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof207;
case 207:
	switch( (*( sm->p)) ) {
		case 84: goto st208;
		case 116: goto st208;
	}
	goto tr238;
st208:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof208;
case 208:
	switch( (*( sm->p)) ) {
		case 68: goto st209;
		case 72: goto st210;
		case 78: goto st211;
		case 100: goto st209;
		case 104: goto st210;
		case 110: goto st211;
	}
	goto tr185;
st209:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof209;
case 209:
	if ( (*( sm->p)) == 93 )
		goto tr244;
	goto tr185;
st210:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof210;
case 210:
	if ( (*( sm->p)) == 93 )
		goto tr245;
	goto tr185;
st211:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof211;
case 211:
	if ( (*( sm->p)) == 93 )
		goto tr246;
	goto tr185;
tr1342:
#line 117 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st212;
st212:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof212;
case 212:
#line 6301 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto tr252;
		case 32: goto tr252;
		case 42: goto st212;
	}
	goto tr196;
tr252:
#line 118 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
	goto st213;
st213:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof213;
case 213:
#line 6316 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto tr255;
		case 10: goto tr196;
		case 13: goto tr196;
		case 32: goto tr255;
	}
	goto tr254;
tr254:
#line 119 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st992;
st992:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof992;
case 992:
#line 6332 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 10: goto tr1351;
		case 13: goto tr1351;
	}
	goto st992;
tr255:
#line 119 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st993;
st993:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof993;
case 993:
#line 6346 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto tr255;
		case 10: goto tr1351;
		case 13: goto tr1351;
		case 32: goto tr255;
	}
	goto tr254;
st214:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof214;
case 214:
	switch( (*( sm->p)) ) {
		case 47: goto st215;
		case 67: goto st245;
		case 72: goto st164;
		case 78: goto st252;
		case 83: goto st168;
		case 84: goto st178;
		case 99: goto st245;
		case 104: goto st164;
		case 110: goto st252;
		case 115: goto st168;
		case 116: goto st178;
	}
	goto tr196;
st215:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof215;
case 215:
	switch( (*( sm->p)) ) {
		case 66: goto st216;
		case 69: goto st226;
		case 81: goto st232;
		case 83: goto st237;
		case 84: goto st202;
		case 98: goto st216;
		case 101: goto st226;
		case 113: goto st232;
		case 115: goto st237;
		case 116: goto st202;
	}
	goto tr196;
st216:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof216;
case 216:
	switch( (*( sm->p)) ) {
		case 76: goto st217;
		case 108: goto st217;
	}
	goto tr196;
st217:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof217;
case 217:
	switch( (*( sm->p)) ) {
		case 79: goto st218;
		case 111: goto st218;
	}
	goto tr185;
st218:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof218;
case 218:
	switch( (*( sm->p)) ) {
		case 67: goto st219;
		case 99: goto st219;
	}
	goto tr185;
st219:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof219;
case 219:
	switch( (*( sm->p)) ) {
		case 75: goto st220;
		case 107: goto st220;
	}
	goto tr185;
st220:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof220;
case 220:
	switch( (*( sm->p)) ) {
		case 81: goto st221;
		case 113: goto st221;
	}
	goto tr185;
st221:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof221;
case 221:
	switch( (*( sm->p)) ) {
		case 85: goto st222;
		case 117: goto st222;
	}
	goto tr185;
st222:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof222;
case 222:
	switch( (*( sm->p)) ) {
		case 79: goto st223;
		case 111: goto st223;
	}
	goto tr185;
st223:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof223;
case 223:
	switch( (*( sm->p)) ) {
		case 84: goto st224;
		case 116: goto st224;
	}
	goto tr185;
st224:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof224;
case 224:
	switch( (*( sm->p)) ) {
		case 69: goto st225;
		case 101: goto st225;
	}
	goto tr185;
st225:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof225;
case 225:
	_widec = (*( sm->p));
	if ( 93 <= (*( sm->p)) && (*( sm->p)) <= 93 ) {
		_widec = (short)(2176 + ((*( sm->p)) - -128));
		if ( 
#line 130 "ext/dtext/dtext.cpp.rl"
 dstack_is_open(sm, BLOCK_QUOTE)  ) _widec += 256;
	}
	if ( _widec == 2653 )
		goto st994;
	goto tr185;
st994:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof994;
case 994:
	switch( (*( sm->p)) ) {
		case 9: goto st994;
		case 32: goto st994;
	}
	goto tr1353;
st226:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof226;
case 226:
	switch( (*( sm->p)) ) {
		case 88: goto st227;
		case 120: goto st227;
	}
	goto tr196;
st227:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof227;
case 227:
	switch( (*( sm->p)) ) {
		case 80: goto st228;
		case 112: goto st228;
	}
	goto tr185;
st228:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof228;
case 228:
	switch( (*( sm->p)) ) {
		case 65: goto st229;
		case 97: goto st229;
	}
	goto tr185;
st229:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof229;
case 229:
	switch( (*( sm->p)) ) {
		case 78: goto st230;
		case 110: goto st230;
	}
	goto tr185;
st230:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof230;
case 230:
	switch( (*( sm->p)) ) {
		case 68: goto st231;
		case 100: goto st231;
	}
	goto tr185;
st231:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof231;
case 231:
	_widec = (*( sm->p));
	if ( 62 <= (*( sm->p)) && (*( sm->p)) <= 62 ) {
		_widec = (short)(2688 + ((*( sm->p)) - -128));
		if ( 
#line 131 "ext/dtext/dtext.cpp.rl"
 dstack_is_open(sm, BLOCK_EXPAND)  ) _widec += 256;
	}
	if ( _widec == 3134 )
		goto st995;
	goto tr185;
st995:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof995;
case 995:
	switch( (*( sm->p)) ) {
		case 9: goto st995;
		case 32: goto st995;
	}
	goto tr1354;
st232:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof232;
case 232:
	switch( (*( sm->p)) ) {
		case 85: goto st233;
		case 117: goto st233;
	}
	goto tr185;
st233:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof233;
case 233:
	switch( (*( sm->p)) ) {
		case 79: goto st234;
		case 111: goto st234;
	}
	goto tr185;
st234:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof234;
case 234:
	switch( (*( sm->p)) ) {
		case 84: goto st235;
		case 116: goto st235;
	}
	goto tr185;
st235:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof235;
case 235:
	switch( (*( sm->p)) ) {
		case 69: goto st236;
		case 101: goto st236;
	}
	goto tr185;
st236:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof236;
case 236:
	_widec = (*( sm->p));
	if ( 62 <= (*( sm->p)) && (*( sm->p)) <= 62 ) {
		_widec = (short)(2176 + ((*( sm->p)) - -128));
		if ( 
#line 130 "ext/dtext/dtext.cpp.rl"
 dstack_is_open(sm, BLOCK_QUOTE)  ) _widec += 256;
	}
	if ( _widec == 2622 )
		goto st994;
	goto tr185;
st237:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof237;
case 237:
	switch( (*( sm->p)) ) {
		case 80: goto st238;
		case 112: goto st238;
	}
	goto tr196;
st238:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof238;
case 238:
	switch( (*( sm->p)) ) {
		case 79: goto st239;
		case 111: goto st239;
	}
	goto tr185;
st239:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof239;
case 239:
	switch( (*( sm->p)) ) {
		case 73: goto st240;
		case 105: goto st240;
	}
	goto tr185;
st240:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof240;
case 240:
	switch( (*( sm->p)) ) {
		case 76: goto st241;
		case 108: goto st241;
	}
	goto tr185;
st241:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof241;
case 241:
	switch( (*( sm->p)) ) {
		case 69: goto st242;
		case 101: goto st242;
	}
	goto tr185;
st242:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof242;
case 242:
	switch( (*( sm->p)) ) {
		case 82: goto st243;
		case 114: goto st243;
	}
	goto tr185;
st243:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof243;
case 243:
	switch( (*( sm->p)) ) {
		case 62: goto tr289;
		case 83: goto st244;
		case 115: goto st244;
	}
	goto tr185;
st244:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof244;
case 244:
	if ( (*( sm->p)) == 62 )
		goto tr289;
	goto tr185;
st245:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof245;
case 245:
	switch( (*( sm->p)) ) {
		case 79: goto st246;
		case 111: goto st246;
	}
	goto tr196;
st246:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof246;
case 246:
	switch( (*( sm->p)) ) {
		case 68: goto st247;
		case 100: goto st247;
	}
	goto tr196;
st247:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof247;
case 247:
	switch( (*( sm->p)) ) {
		case 69: goto st248;
		case 101: goto st248;
	}
	goto tr196;
st248:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof248;
case 248:
	switch( (*( sm->p)) ) {
		case 9: goto st249;
		case 32: goto st249;
		case 61: goto st250;
		case 62: goto tr296;
	}
	goto tr196;
st249:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof249;
case 249:
	switch( (*( sm->p)) ) {
		case 9: goto st249;
		case 32: goto st249;
		case 61: goto st250;
	}
	goto tr196;
st250:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof250;
case 250:
	switch( (*( sm->p)) ) {
		case 9: goto st250;
		case 32: goto st250;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr297;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr297;
	} else
		goto tr297;
	goto tr196;
tr297:
#line 117 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st251;
st251:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof251;
case 251:
#line 6755 "ext/dtext/dtext.cpp"
	if ( (*( sm->p)) == 62 )
		goto tr299;
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st251;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st251;
	} else
		goto st251;
	goto tr196;
st252:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof252;
case 252:
	switch( (*( sm->p)) ) {
		case 79: goto st253;
		case 111: goto st253;
	}
	goto tr196;
st253:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof253;
case 253:
	switch( (*( sm->p)) ) {
		case 68: goto st254;
		case 100: goto st254;
	}
	goto tr196;
st254:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof254;
case 254:
	switch( (*( sm->p)) ) {
		case 84: goto st255;
		case 116: goto st255;
	}
	goto tr196;
st255:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof255;
case 255:
	switch( (*( sm->p)) ) {
		case 69: goto st256;
		case 101: goto st256;
	}
	goto tr196;
st256:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof256;
case 256:
	switch( (*( sm->p)) ) {
		case 88: goto st257;
		case 120: goto st257;
	}
	goto tr196;
st257:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof257;
case 257:
	switch( (*( sm->p)) ) {
		case 84: goto st258;
		case 116: goto st258;
	}
	goto tr196;
st258:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof258;
case 258:
	if ( (*( sm->p)) == 62 )
		goto tr296;
	goto tr196;
st259:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof259;
case 259:
	if ( 49 <= (*( sm->p)) && (*( sm->p)) <= 54 )
		goto tr306;
	goto tr196;
tr306:
#line 117 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st260;
st260:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof260;
case 260:
#line 6843 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 35: goto tr307;
		case 46: goto tr308;
	}
	goto tr196;
tr307:
#line 118 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
	goto st261;
st261:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof261;
case 261:
#line 6857 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 33: goto tr309;
		case 35: goto tr309;
		case 38: goto tr309;
		case 45: goto tr309;
		case 95: goto tr309;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 47 <= (*( sm->p)) && (*( sm->p)) <= 58 )
			goto tr309;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr309;
	} else
		goto tr309;
	goto tr196;
tr309:
#line 119 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st262;
st262:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof262;
case 262:
#line 6882 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 33: goto st262;
		case 35: goto st262;
		case 38: goto st262;
		case 46: goto tr311;
		case 95: goto st262;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 45 <= (*( sm->p)) && (*( sm->p)) <= 58 )
			goto st262;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st262;
	} else
		goto st262;
	goto tr196;
tr308:
#line 118 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
#line 119 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
#line 120 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
	goto st996;
tr311:
#line 120 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
	goto st996;
st996:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof996;
case 996:
#line 6915 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto st996;
		case 32: goto st996;
	}
	goto tr1355;
st263:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof263;
case 263:
	switch( (*( sm->p)) ) {
		case 47: goto st264;
		case 67: goto st279;
		case 72: goto st184;
		case 78: goto st286;
		case 83: goto st186;
		case 84: goto st194;
		case 99: goto st279;
		case 104: goto st184;
		case 110: goto st286;
		case 115: goto st186;
		case 116: goto st194;
	}
	goto tr196;
st264:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof264;
case 264:
	switch( (*( sm->p)) ) {
		case 69: goto st265;
		case 81: goto st221;
		case 83: goto st271;
		case 84: goto st208;
		case 101: goto st265;
		case 113: goto st221;
		case 115: goto st271;
		case 116: goto st208;
	}
	goto tr196;
st265:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof265;
case 265:
	switch( (*( sm->p)) ) {
		case 88: goto st266;
		case 120: goto st266;
	}
	goto tr185;
st266:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof266;
case 266:
	switch( (*( sm->p)) ) {
		case 80: goto st267;
		case 112: goto st267;
	}
	goto tr185;
st267:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof267;
case 267:
	switch( (*( sm->p)) ) {
		case 65: goto st268;
		case 97: goto st268;
	}
	goto tr185;
st268:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof268;
case 268:
	switch( (*( sm->p)) ) {
		case 78: goto st269;
		case 110: goto st269;
	}
	goto tr185;
st269:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof269;
case 269:
	switch( (*( sm->p)) ) {
		case 68: goto st270;
		case 100: goto st270;
	}
	goto tr185;
st270:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof270;
case 270:
	_widec = (*( sm->p));
	if ( 93 <= (*( sm->p)) && (*( sm->p)) <= 93 ) {
		_widec = (short)(2688 + ((*( sm->p)) - -128));
		if ( 
#line 131 "ext/dtext/dtext.cpp.rl"
 dstack_is_open(sm, BLOCK_EXPAND)  ) _widec += 256;
	}
	if ( _widec == 3165 )
		goto st995;
	goto tr185;
st271:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof271;
case 271:
	switch( (*( sm->p)) ) {
		case 80: goto st272;
		case 112: goto st272;
	}
	goto tr196;
st272:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof272;
case 272:
	switch( (*( sm->p)) ) {
		case 79: goto st273;
		case 111: goto st273;
	}
	goto tr185;
st273:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof273;
case 273:
	switch( (*( sm->p)) ) {
		case 73: goto st274;
		case 105: goto st274;
	}
	goto tr185;
st274:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof274;
case 274:
	switch( (*( sm->p)) ) {
		case 76: goto st275;
		case 108: goto st275;
	}
	goto tr185;
st275:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof275;
case 275:
	switch( (*( sm->p)) ) {
		case 69: goto st276;
		case 101: goto st276;
	}
	goto tr185;
st276:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof276;
case 276:
	switch( (*( sm->p)) ) {
		case 82: goto st277;
		case 114: goto st277;
	}
	goto tr185;
st277:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof277;
case 277:
	switch( (*( sm->p)) ) {
		case 83: goto st278;
		case 93: goto tr289;
		case 115: goto st278;
	}
	goto tr185;
st278:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof278;
case 278:
	if ( (*( sm->p)) == 93 )
		goto tr289;
	goto tr185;
st279:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof279;
case 279:
	switch( (*( sm->p)) ) {
		case 79: goto st280;
		case 111: goto st280;
	}
	goto tr196;
st280:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof280;
case 280:
	switch( (*( sm->p)) ) {
		case 68: goto st281;
		case 100: goto st281;
	}
	goto tr196;
st281:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof281;
case 281:
	switch( (*( sm->p)) ) {
		case 69: goto st282;
		case 101: goto st282;
	}
	goto tr196;
st282:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof282;
case 282:
	switch( (*( sm->p)) ) {
		case 9: goto st283;
		case 32: goto st283;
		case 61: goto st284;
		case 93: goto tr296;
	}
	goto tr196;
st283:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof283;
case 283:
	switch( (*( sm->p)) ) {
		case 9: goto st283;
		case 32: goto st283;
		case 61: goto st284;
	}
	goto tr196;
st284:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof284;
case 284:
	switch( (*( sm->p)) ) {
		case 9: goto st284;
		case 32: goto st284;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr334;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr334;
	} else
		goto tr334;
	goto tr196;
tr334:
#line 117 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st285;
st285:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof285;
case 285:
#line 7157 "ext/dtext/dtext.cpp"
	if ( (*( sm->p)) == 93 )
		goto tr299;
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st285;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st285;
	} else
		goto st285;
	goto tr196;
st286:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof286;
case 286:
	switch( (*( sm->p)) ) {
		case 79: goto st287;
		case 111: goto st287;
	}
	goto tr196;
st287:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof287;
case 287:
	switch( (*( sm->p)) ) {
		case 68: goto st288;
		case 100: goto st288;
	}
	goto tr196;
st288:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof288;
case 288:
	switch( (*( sm->p)) ) {
		case 84: goto st289;
		case 116: goto st289;
	}
	goto tr196;
st289:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof289;
case 289:
	switch( (*( sm->p)) ) {
		case 69: goto st290;
		case 101: goto st290;
	}
	goto tr196;
st290:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof290;
case 290:
	switch( (*( sm->p)) ) {
		case 88: goto st291;
		case 120: goto st291;
	}
	goto tr196;
st291:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof291;
case 291:
	switch( (*( sm->p)) ) {
		case 84: goto st292;
		case 116: goto st292;
	}
	goto tr196;
st292:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof292;
case 292:
	if ( (*( sm->p)) == 93 )
		goto tr296;
	goto tr196;
st293:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof293;
case 293:
	if ( (*( sm->p)) == 96 )
		goto st294;
	goto tr196;
st294:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof294;
case 294:
	if ( (*( sm->p)) == 96 )
		goto st295;
	goto tr196;
tr345:
#line 117 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
#line 118 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
	goto st295;
st295:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof295;
case 295:
#line 7254 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr344;
		case 9: goto tr345;
		case 10: goto tr344;
		case 13: goto tr346;
		case 32: goto tr345;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr347;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr347;
	} else
		goto tr347;
	goto tr196;
tr360:
#line 118 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
	goto st296;
tr344:
#line 117 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
#line 118 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
	goto st296;
st296:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof296;
case 296:
#line 7285 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr349;
		case 10: goto tr349;
		case 13: goto tr350;
	}
	goto tr348;
tr348:
#line 119 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st297;
tr353:
#line 120 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
	goto st297;
tr350:
#line 119 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
#line 120 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
	goto st297;
st297:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof297;
case 297:
#line 7310 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr352;
		case 10: goto tr352;
		case 13: goto tr353;
	}
	goto st297;
tr352:
#line 120 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
	goto st298;
tr349:
#line 119 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
#line 120 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
	goto st298;
st298:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof298;
case 298:
#line 7331 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr352;
		case 10: goto tr352;
		case 13: goto tr353;
		case 96: goto st299;
	}
	goto st297;
st299:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof299;
case 299:
	switch( (*( sm->p)) ) {
		case 0: goto tr352;
		case 10: goto tr352;
		case 13: goto tr353;
		case 96: goto st300;
	}
	goto st297;
st300:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof300;
case 300:
	switch( (*( sm->p)) ) {
		case 0: goto tr352;
		case 10: goto tr352;
		case 13: goto tr353;
		case 96: goto st301;
	}
	goto st297;
st301:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof301;
case 301:
	switch( (*( sm->p)) ) {
		case 0: goto tr357;
		case 9: goto st301;
		case 10: goto tr357;
		case 13: goto tr358;
		case 32: goto st301;
	}
	goto st297;
tr358:
#line 120 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
	goto st302;
st302:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof302;
case 302:
#line 7381 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr352;
		case 10: goto tr357;
		case 13: goto tr353;
	}
	goto st297;
tr362:
#line 118 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
	goto st303;
tr346:
#line 117 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
#line 118 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
	goto st303;
st303:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof303;
case 303:
#line 7402 "ext/dtext/dtext.cpp"
	if ( (*( sm->p)) == 10 )
		goto st296;
	goto tr196;
tr347:
#line 117 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st304;
st304:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof304;
case 304:
#line 7414 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr360;
		case 9: goto tr361;
		case 10: goto tr360;
		case 13: goto tr362;
		case 32: goto tr361;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st304;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st304;
	} else
		goto st304;
	goto tr196;
tr361:
#line 118 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
	goto st305;
st305:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof305;
case 305:
#line 7439 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto st296;
		case 9: goto st305;
		case 10: goto st296;
		case 13: goto st303;
		case 32: goto st305;
	}
	goto tr196;
st997:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof997;
case 997:
	if ( (*( sm->p)) == 10 )
		goto tr1311;
	goto tr1357;
tr1313:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
	goto st998;
st998:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof998;
case 998:
#line 7463 "ext/dtext/dtext.cpp"
	if ( (*( sm->p)) == 34 )
		goto tr1337;
	goto tr1358;
tr1358:
#line 117 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st306;
st306:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof306;
case 306:
#line 7475 "ext/dtext/dtext.cpp"
	if ( (*( sm->p)) == 34 )
		goto tr367;
	goto st306;
tr367:
#line 118 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
	goto st307;
st307:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof307;
case 307:
#line 7487 "ext/dtext/dtext.cpp"
	if ( (*( sm->p)) == 58 )
		goto st308;
	goto tr193;
st308:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof308;
case 308:
	switch( (*( sm->p)) ) {
		case 35: goto tr369;
		case 47: goto tr369;
		case 72: goto tr370;
		case 91: goto st317;
		case 104: goto tr370;
	}
	goto tr193;
tr369:
#line 119 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st999;
st999:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof999;
case 999:
#line 7511 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr1359;
		case 32: goto tr1359;
	}
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr1359;
	goto st999;
tr370:
#line 119 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st309;
st309:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof309;
case 309:
#line 7527 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 84: goto st310;
		case 116: goto st310;
	}
	goto tr193;
st310:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof310;
case 310:
	switch( (*( sm->p)) ) {
		case 84: goto st311;
		case 116: goto st311;
	}
	goto tr193;
st311:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof311;
case 311:
	switch( (*( sm->p)) ) {
		case 80: goto st312;
		case 112: goto st312;
	}
	goto tr193;
st312:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof312;
case 312:
	switch( (*( sm->p)) ) {
		case 58: goto st313;
		case 83: goto st316;
		case 115: goto st316;
	}
	goto tr193;
st313:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof313;
case 313:
	if ( (*( sm->p)) == 47 )
		goto st314;
	goto tr193;
st314:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof314;
case 314:
	if ( (*( sm->p)) == 47 )
		goto st315;
	goto tr193;
st315:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof315;
case 315:
	switch( (*( sm->p)) ) {
		case 0: goto tr193;
		case 32: goto tr193;
	}
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr193;
	goto st999;
st316:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof316;
case 316:
	if ( (*( sm->p)) == 58 )
		goto st313;
	goto tr193;
st317:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof317;
case 317:
	switch( (*( sm->p)) ) {
		case 35: goto tr380;
		case 47: goto tr380;
		case 72: goto tr381;
		case 104: goto tr381;
	}
	goto tr193;
tr380:
#line 119 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st318;
st318:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof318;
case 318:
#line 7612 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr193;
		case 32: goto tr193;
		case 93: goto tr383;
	}
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr193;
	goto st318;
tr381:
#line 119 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st319;
st319:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof319;
case 319:
#line 7629 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 84: goto st320;
		case 116: goto st320;
	}
	goto tr193;
st320:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof320;
case 320:
	switch( (*( sm->p)) ) {
		case 84: goto st321;
		case 116: goto st321;
	}
	goto tr193;
st321:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof321;
case 321:
	switch( (*( sm->p)) ) {
		case 80: goto st322;
		case 112: goto st322;
	}
	goto tr193;
st322:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof322;
case 322:
	switch( (*( sm->p)) ) {
		case 58: goto st323;
		case 83: goto st326;
		case 115: goto st326;
	}
	goto tr193;
st323:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof323;
case 323:
	if ( (*( sm->p)) == 47 )
		goto st324;
	goto tr193;
st324:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof324;
case 324:
	if ( (*( sm->p)) == 47 )
		goto st325;
	goto tr193;
st325:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof325;
case 325:
	switch( (*( sm->p)) ) {
		case 0: goto tr193;
		case 32: goto tr193;
	}
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr193;
	goto st318;
st326:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof326;
case 326:
	if ( (*( sm->p)) == 58 )
		goto st323;
	goto tr193;
tr1360:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 562 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1000;
tr1314:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 117 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
#line 562 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1000;
st1000:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1000;
case 1000:
#line 7713 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 91: goto tr1361;
		case 123: goto tr1362;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1360;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1360;
	} else
		goto tr1360;
	goto tr1338;
tr1361:
#line 118 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
	goto st327;
st327:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof327;
case 327:
#line 7735 "ext/dtext/dtext.cpp"
	if ( (*( sm->p)) == 91 )
		goto st328;
	goto tr188;
tr393:
#line 119 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st328;
st328:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof328;
case 328:
#line 7747 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto tr393;
		case 32: goto tr393;
		case 58: goto tr395;
		case 60: goto tr396;
		case 62: goto tr397;
		case 92: goto tr398;
		case 93: goto tr185;
		case 124: goto tr399;
	}
	if ( 10 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr394;
	goto tr392;
tr392:
#line 119 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st329;
st329:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof329;
case 329:
#line 7769 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto tr401;
		case 32: goto tr401;
		case 35: goto tr403;
		case 93: goto tr404;
		case 124: goto tr405;
	}
	if ( 10 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto st331;
	goto st329;
tr401:
#line 120 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
	goto st330;
st330:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof330;
case 330:
#line 7788 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto st330;
		case 32: goto st330;
		case 35: goto st332;
		case 93: goto st335;
		case 124: goto st336;
	}
	if ( 10 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto st331;
	goto st329;
tr394:
#line 119 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st331;
st331:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof331;
case 331:
#line 7807 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 32: goto st331;
		case 93: goto tr185;
		case 124: goto tr185;
	}
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto st331;
	goto st329;
tr403:
#line 120 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
	goto st332;
st332:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof332;
case 332:
#line 7824 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto tr401;
		case 32: goto tr401;
		case 35: goto tr403;
		case 93: goto tr404;
		case 124: goto tr405;
	}
	if ( (*( sm->p)) > 13 ) {
		if ( 65 <= (*( sm->p)) && (*( sm->p)) <= 90 )
			goto tr410;
	} else if ( (*( sm->p)) >= 10 )
		goto st331;
	goto st329;
tr410:
#line 121 "ext/dtext/dtext.cpp.rl"
	{ sm->c1 = sm->p; }
	goto st333;
st333:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof333;
case 333:
#line 7846 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto tr411;
		case 32: goto tr412;
		case 45: goto st341;
		case 93: goto tr415;
		case 95: goto st341;
		case 124: goto tr416;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st333;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st333;
	} else
		goto st333;
	goto tr185;
tr411:
#line 122 "ext/dtext/dtext.cpp.rl"
	{ sm->c2 = sm->p; }
	goto st334;
st334:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof334;
case 334:
#line 7872 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto st334;
		case 32: goto st334;
		case 93: goto st335;
		case 124: goto st336;
	}
	goto tr185;
tr404:
#line 120 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
	goto st335;
tr415:
#line 122 "ext/dtext/dtext.cpp.rl"
	{ sm->c2 = sm->p; }
	goto st335;
st335:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof335;
case 335:
#line 7892 "ext/dtext/dtext.cpp"
	if ( (*( sm->p)) == 93 )
		goto st1001;
	goto tr185;
st1001:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1001;
case 1001:
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1364;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1364;
	} else
		goto tr1364;
	goto tr1363;
tr1364:
#line 125 "ext/dtext/dtext.cpp.rl"
	{ sm->e1 = sm->p; }
	goto st1002;
st1002:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1002;
case 1002:
#line 7917 "ext/dtext/dtext.cpp"
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st1002;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st1002;
	} else
		goto st1002;
	goto tr1365;
tr405:
#line 120 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
	goto st336;
tr416:
#line 122 "ext/dtext/dtext.cpp.rl"
	{ sm->c2 = sm->p; }
	goto st336;
tr420:
#line 123 "ext/dtext/dtext.cpp.rl"
	{ sm->d1 = sm->p; }
#line 124 "ext/dtext/dtext.cpp.rl"
	{ sm->d2 = sm->p; }
	goto st336;
st336:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof336;
case 336:
#line 7945 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto tr420;
		case 32: goto tr420;
		case 93: goto tr421;
		case 124: goto tr185;
	}
	if ( 10 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr185;
	goto tr419;
tr419:
#line 123 "ext/dtext/dtext.cpp.rl"
	{ sm->d1 = sm->p; }
	goto st337;
st337:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof337;
case 337:
#line 7963 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto tr423;
		case 32: goto tr423;
		case 93: goto tr424;
		case 124: goto tr185;
	}
	if ( 10 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr185;
	goto st337;
tr423:
#line 124 "ext/dtext/dtext.cpp.rl"
	{ sm->d2 = sm->p; }
	goto st338;
st338:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof338;
case 338:
#line 7981 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto st338;
		case 32: goto st338;
		case 93: goto st339;
		case 124: goto tr185;
	}
	if ( 10 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr185;
	goto st337;
tr421:
#line 123 "ext/dtext/dtext.cpp.rl"
	{ sm->d1 = sm->p; }
#line 124 "ext/dtext/dtext.cpp.rl"
	{ sm->d2 = sm->p; }
	goto st339;
tr424:
#line 124 "ext/dtext/dtext.cpp.rl"
	{ sm->d2 = sm->p; }
	goto st339;
st339:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof339;
case 339:
#line 8005 "ext/dtext/dtext.cpp"
	if ( (*( sm->p)) == 93 )
		goto st1003;
	goto tr185;
st1003:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1003;
case 1003:
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1368;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1368;
	} else
		goto tr1368;
	goto tr1367;
tr1368:
#line 125 "ext/dtext/dtext.cpp.rl"
	{ sm->e1 = sm->p; }
	goto st1004;
st1004:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1004;
case 1004:
#line 8030 "ext/dtext/dtext.cpp"
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st1004;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st1004;
	} else
		goto st1004;
	goto tr1369;
tr412:
#line 122 "ext/dtext/dtext.cpp.rl"
	{ sm->c2 = sm->p; }
	goto st340;
st340:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof340;
case 340:
#line 8048 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto st334;
		case 32: goto st340;
		case 45: goto st341;
		case 93: goto st335;
		case 95: goto st341;
		case 124: goto st336;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st333;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st333;
	} else
		goto st333;
	goto tr185;
st341:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof341;
case 341:
	switch( (*( sm->p)) ) {
		case 32: goto st341;
		case 45: goto st341;
		case 95: goto st341;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st333;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st333;
	} else
		goto st333;
	goto tr185;
tr395:
#line 119 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st342;
st342:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof342;
case 342:
#line 8092 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto tr401;
		case 32: goto tr401;
		case 35: goto tr403;
		case 93: goto tr404;
		case 124: goto tr429;
	}
	if ( 10 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto st331;
	goto st329;
tr429:
#line 120 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
	goto st343;
st343:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof343;
case 343:
#line 8111 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto tr430;
		case 32: goto tr430;
		case 35: goto tr431;
		case 93: goto tr432;
		case 124: goto tr185;
	}
	if ( 10 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr185;
	goto tr419;
tr433:
#line 123 "ext/dtext/dtext.cpp.rl"
	{ sm->d1 = sm->p; }
#line 124 "ext/dtext/dtext.cpp.rl"
	{ sm->d2 = sm->p; }
	goto st344;
tr430:
#line 120 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
#line 123 "ext/dtext/dtext.cpp.rl"
	{ sm->d1 = sm->p; }
#line 124 "ext/dtext/dtext.cpp.rl"
	{ sm->d2 = sm->p; }
	goto st344;
st344:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof344;
case 344:
#line 8140 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto tr433;
		case 32: goto tr433;
		case 35: goto tr434;
		case 93: goto tr435;
		case 124: goto tr185;
	}
	if ( 10 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr185;
	goto tr419;
tr469:
#line 120 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
	goto st345;
tr434:
#line 123 "ext/dtext/dtext.cpp.rl"
	{ sm->d1 = sm->p; }
	goto st345;
tr431:
#line 120 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
#line 123 "ext/dtext/dtext.cpp.rl"
	{ sm->d1 = sm->p; }
	goto st345;
st345:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof345;
case 345:
#line 8169 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto tr423;
		case 32: goto tr423;
		case 93: goto tr424;
		case 124: goto tr185;
	}
	if ( (*( sm->p)) > 13 ) {
		if ( 65 <= (*( sm->p)) && (*( sm->p)) <= 90 )
			goto tr436;
	} else if ( (*( sm->p)) >= 10 )
		goto tr185;
	goto st337;
tr436:
#line 121 "ext/dtext/dtext.cpp.rl"
	{ sm->c1 = sm->p; }
	goto st346;
st346:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof346;
case 346:
#line 8190 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto tr437;
		case 32: goto tr438;
		case 45: goto st350;
		case 93: goto tr441;
		case 95: goto st350;
		case 124: goto tr185;
	}
	if ( (*( sm->p)) < 48 ) {
		if ( 10 <= (*( sm->p)) && (*( sm->p)) <= 13 )
			goto tr185;
	} else if ( (*( sm->p)) > 57 ) {
		if ( (*( sm->p)) > 90 ) {
			if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
				goto st346;
		} else if ( (*( sm->p)) >= 65 )
			goto st346;
	} else
		goto st346;
	goto st337;
tr437:
#line 122 "ext/dtext/dtext.cpp.rl"
	{ sm->c2 = sm->p; }
#line 124 "ext/dtext/dtext.cpp.rl"
	{ sm->d2 = sm->p; }
	goto st347;
st347:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof347;
case 347:
#line 8221 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto st347;
		case 32: goto st347;
		case 93: goto st348;
		case 124: goto tr185;
	}
	if ( 10 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr185;
	goto st337;
tr435:
#line 123 "ext/dtext/dtext.cpp.rl"
	{ sm->d1 = sm->p; }
#line 124 "ext/dtext/dtext.cpp.rl"
	{ sm->d2 = sm->p; }
	goto st348;
tr432:
#line 120 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
#line 123 "ext/dtext/dtext.cpp.rl"
	{ sm->d1 = sm->p; }
#line 124 "ext/dtext/dtext.cpp.rl"
	{ sm->d2 = sm->p; }
	goto st348;
tr441:
#line 122 "ext/dtext/dtext.cpp.rl"
	{ sm->c2 = sm->p; }
#line 124 "ext/dtext/dtext.cpp.rl"
	{ sm->d2 = sm->p; }
	goto st348;
tr470:
#line 120 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
#line 124 "ext/dtext/dtext.cpp.rl"
	{ sm->d2 = sm->p; }
	goto st348;
st348:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof348;
case 348:
#line 8261 "ext/dtext/dtext.cpp"
	if ( (*( sm->p)) == 93 )
		goto st1005;
	goto tr185;
st1005:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1005;
case 1005:
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1371;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1371;
	} else
		goto tr1371;
	goto tr1363;
tr1371:
#line 125 "ext/dtext/dtext.cpp.rl"
	{ sm->e1 = sm->p; }
	goto st1006;
st1006:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1006;
case 1006:
#line 8286 "ext/dtext/dtext.cpp"
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st1006;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st1006;
	} else
		goto st1006;
	goto tr1365;
tr438:
#line 122 "ext/dtext/dtext.cpp.rl"
	{ sm->c2 = sm->p; }
#line 124 "ext/dtext/dtext.cpp.rl"
	{ sm->d2 = sm->p; }
	goto st349;
st349:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof349;
case 349:
#line 8306 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto st347;
		case 32: goto st349;
		case 45: goto st350;
		case 93: goto st348;
		case 95: goto st350;
		case 124: goto tr185;
	}
	if ( (*( sm->p)) < 48 ) {
		if ( 10 <= (*( sm->p)) && (*( sm->p)) <= 13 )
			goto tr185;
	} else if ( (*( sm->p)) > 57 ) {
		if ( (*( sm->p)) > 90 ) {
			if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
				goto st346;
		} else if ( (*( sm->p)) >= 65 )
			goto st346;
	} else
		goto st346;
	goto st337;
st350:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof350;
case 350:
	switch( (*( sm->p)) ) {
		case 9: goto tr423;
		case 32: goto tr446;
		case 45: goto st350;
		case 93: goto tr424;
		case 95: goto st350;
		case 124: goto tr185;
	}
	if ( (*( sm->p)) < 48 ) {
		if ( 10 <= (*( sm->p)) && (*( sm->p)) <= 13 )
			goto tr185;
	} else if ( (*( sm->p)) > 57 ) {
		if ( (*( sm->p)) > 90 ) {
			if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
				goto st346;
		} else if ( (*( sm->p)) >= 65 )
			goto st346;
	} else
		goto st346;
	goto st337;
tr446:
#line 124 "ext/dtext/dtext.cpp.rl"
	{ sm->d2 = sm->p; }
	goto st351;
st351:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof351;
case 351:
#line 8359 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto st338;
		case 32: goto st351;
		case 45: goto st350;
		case 93: goto st339;
		case 95: goto st350;
		case 124: goto tr185;
	}
	if ( (*( sm->p)) < 48 ) {
		if ( 10 <= (*( sm->p)) && (*( sm->p)) <= 13 )
			goto tr185;
	} else if ( (*( sm->p)) > 57 ) {
		if ( (*( sm->p)) > 90 ) {
			if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
				goto st346;
		} else if ( (*( sm->p)) >= 65 )
			goto st346;
	} else
		goto st346;
	goto st337;
tr396:
#line 119 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st352;
st352:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof352;
case 352:
#line 8388 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto tr401;
		case 32: goto tr401;
		case 35: goto tr403;
		case 93: goto tr404;
		case 124: goto tr448;
	}
	if ( 10 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto st331;
	goto st329;
tr448:
#line 120 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
	goto st353;
st353:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof353;
case 353:
#line 8407 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto tr420;
		case 32: goto tr420;
		case 62: goto tr449;
		case 93: goto tr421;
		case 124: goto tr185;
	}
	if ( 10 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr185;
	goto tr419;
tr449:
#line 123 "ext/dtext/dtext.cpp.rl"
	{ sm->d1 = sm->p; }
	goto st354;
st354:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof354;
case 354:
#line 8426 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto tr423;
		case 32: goto tr423;
		case 93: goto tr424;
		case 95: goto st355;
		case 124: goto tr185;
	}
	if ( 10 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr185;
	goto st337;
st355:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof355;
case 355:
	switch( (*( sm->p)) ) {
		case 9: goto tr423;
		case 32: goto tr423;
		case 60: goto st356;
		case 93: goto tr424;
		case 124: goto tr185;
	}
	if ( 10 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr185;
	goto st337;
st356:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof356;
case 356:
	switch( (*( sm->p)) ) {
		case 9: goto tr423;
		case 32: goto tr423;
		case 93: goto tr424;
		case 124: goto st357;
	}
	if ( 10 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr185;
	goto st337;
st357:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof357;
case 357:
	if ( (*( sm->p)) == 62 )
		goto st358;
	goto tr185;
st358:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof358;
case 358:
	switch( (*( sm->p)) ) {
		case 9: goto tr454;
		case 32: goto tr454;
		case 35: goto tr455;
		case 93: goto tr404;
	}
	goto tr185;
tr454:
#line 120 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
	goto st359;
st359:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof359;
case 359:
#line 8490 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto st359;
		case 32: goto st359;
		case 35: goto st360;
		case 93: goto st335;
	}
	goto tr185;
tr455:
#line 120 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
	goto st360;
st360:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof360;
case 360:
#line 8506 "ext/dtext/dtext.cpp"
	if ( 65 <= (*( sm->p)) && (*( sm->p)) <= 90 )
		goto tr458;
	goto tr185;
tr458:
#line 121 "ext/dtext/dtext.cpp.rl"
	{ sm->c1 = sm->p; }
	goto st361;
st361:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof361;
case 361:
#line 8518 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto tr459;
		case 32: goto tr460;
		case 45: goto st364;
		case 93: goto tr415;
		case 95: goto st364;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st361;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st361;
	} else
		goto st361;
	goto tr185;
tr459:
#line 122 "ext/dtext/dtext.cpp.rl"
	{ sm->c2 = sm->p; }
	goto st362;
st362:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof362;
case 362:
#line 8543 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto st362;
		case 32: goto st362;
		case 93: goto st335;
	}
	goto tr185;
tr460:
#line 122 "ext/dtext/dtext.cpp.rl"
	{ sm->c2 = sm->p; }
	goto st363;
st363:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof363;
case 363:
#line 8558 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto st362;
		case 32: goto st363;
		case 45: goto st364;
		case 93: goto st335;
		case 95: goto st364;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st361;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st361;
	} else
		goto st361;
	goto tr185;
st364:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof364;
case 364:
	switch( (*( sm->p)) ) {
		case 32: goto st364;
		case 45: goto st364;
		case 95: goto st364;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st361;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st361;
	} else
		goto st361;
	goto tr185;
tr397:
#line 119 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st365;
st365:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof365;
case 365:
#line 8601 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto tr401;
		case 32: goto tr401;
		case 35: goto tr403;
		case 58: goto st342;
		case 93: goto tr404;
		case 124: goto tr466;
	}
	if ( 10 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto st331;
	goto st329;
tr466:
#line 120 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
	goto st366;
st366:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof366;
case 366:
#line 8621 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto tr420;
		case 32: goto tr420;
		case 51: goto tr467;
		case 93: goto tr421;
		case 124: goto tr185;
	}
	if ( 10 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr185;
	goto tr419;
tr467:
#line 123 "ext/dtext/dtext.cpp.rl"
	{ sm->d1 = sm->p; }
	goto st367;
st367:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof367;
case 367:
#line 8640 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto tr468;
		case 32: goto tr468;
		case 35: goto tr469;
		case 93: goto tr470;
		case 124: goto tr185;
	}
	if ( 10 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr185;
	goto st337;
tr468:
#line 120 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
#line 124 "ext/dtext/dtext.cpp.rl"
	{ sm->d2 = sm->p; }
	goto st368;
st368:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof368;
case 368:
#line 8661 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto st368;
		case 32: goto st368;
		case 35: goto st345;
		case 93: goto st348;
		case 124: goto tr185;
	}
	if ( 10 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr185;
	goto st337;
tr398:
#line 119 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st369;
st369:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof369;
case 369:
#line 8680 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto tr401;
		case 32: goto tr401;
		case 35: goto tr403;
		case 93: goto tr404;
		case 124: goto tr473;
	}
	if ( 10 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto st331;
	goto st329;
tr473:
#line 120 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
	goto st370;
st370:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof370;
case 370:
#line 8699 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto tr420;
		case 32: goto tr420;
		case 93: goto tr421;
		case 124: goto st371;
	}
	if ( 10 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr185;
	goto tr419;
st371:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof371;
case 371:
	if ( (*( sm->p)) == 47 )
		goto st358;
	goto tr185;
tr399:
#line 119 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st372;
st372:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof372;
case 372:
#line 8724 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 95: goto st376;
		case 119: goto st377;
		case 124: goto st378;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st373;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st373;
	} else
		goto st373;
	goto tr185;
st373:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof373;
case 373:
	switch( (*( sm->p)) ) {
		case 9: goto tr479;
		case 32: goto tr479;
		case 35: goto tr480;
		case 93: goto tr404;
		case 124: goto tr405;
	}
	goto tr185;
tr479:
#line 120 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
	goto st374;
st374:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof374;
case 374:
#line 8759 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto st374;
		case 32: goto st374;
		case 35: goto st375;
		case 93: goto st335;
		case 124: goto st336;
	}
	goto tr185;
tr480:
#line 120 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
	goto st375;
st375:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof375;
case 375:
#line 8776 "ext/dtext/dtext.cpp"
	if ( 65 <= (*( sm->p)) && (*( sm->p)) <= 90 )
		goto tr410;
	goto tr185;
st376:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof376;
case 376:
	if ( (*( sm->p)) == 124 )
		goto st373;
	goto tr185;
st377:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof377;
case 377:
	switch( (*( sm->p)) ) {
		case 9: goto tr479;
		case 32: goto tr479;
		case 35: goto tr480;
		case 93: goto tr404;
		case 124: goto tr429;
	}
	goto tr185;
st378:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof378;
case 378:
	if ( (*( sm->p)) == 95 )
		goto st379;
	goto tr185;
st379:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof379;
case 379:
	if ( (*( sm->p)) == 124 )
		goto st376;
	goto tr185;
tr1362:
#line 118 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
	goto st380;
st380:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof380;
case 380:
#line 8821 "ext/dtext/dtext.cpp"
	if ( (*( sm->p)) == 123 )
		goto st381;
	goto tr188;
st381:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof381;
case 381:
	switch( (*( sm->p)) ) {
		case 0: goto tr185;
		case 9: goto st381;
		case 32: goto st381;
		case 45: goto tr486;
		case 58: goto tr487;
		case 60: goto tr488;
		case 62: goto tr489;
		case 92: goto tr490;
		case 124: goto tr491;
		case 126: goto tr486;
	}
	if ( (*( sm->p)) > 13 ) {
		if ( 123 <= (*( sm->p)) && (*( sm->p)) <= 125 )
			goto tr185;
	} else if ( (*( sm->p)) >= 10 )
		goto tr185;
	goto tr485;
tr485:
#line 119 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st382;
st382:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof382;
case 382:
#line 8855 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr185;
		case 9: goto tr493;
		case 32: goto tr493;
		case 123: goto tr185;
		case 124: goto tr494;
		case 125: goto tr495;
	}
	if ( 10 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr185;
	goto st382;
tr493:
#line 120 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
	goto st383;
st383:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof383;
case 383:
#line 8875 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr185;
		case 9: goto st383;
		case 32: goto st383;
		case 45: goto st384;
		case 58: goto st385;
		case 60: goto st420;
		case 62: goto st421;
		case 92: goto st423;
		case 123: goto tr185;
		case 124: goto st414;
		case 125: goto st392;
		case 126: goto st384;
	}
	if ( 10 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr185;
	goto st382;
tr486:
#line 119 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st384;
st384:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof384;
case 384:
#line 8901 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr185;
		case 9: goto tr493;
		case 32: goto tr493;
		case 58: goto st385;
		case 60: goto st420;
		case 62: goto st421;
		case 92: goto st423;
		case 123: goto tr185;
		case 124: goto tr504;
		case 125: goto tr495;
	}
	if ( 10 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr185;
	goto st382;
tr487:
#line 119 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st385;
st385:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof385;
case 385:
#line 8925 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr185;
		case 9: goto tr493;
		case 32: goto tr493;
		case 123: goto st386;
		case 124: goto tr506;
		case 125: goto tr507;
	}
	if ( 10 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr185;
	goto st382;
st386:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof386;
case 386:
	switch( (*( sm->p)) ) {
		case 9: goto tr493;
		case 32: goto tr493;
		case 124: goto tr494;
		case 125: goto tr495;
	}
	goto tr185;
tr494:
#line 120 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
	goto st387;
tr510:
#line 121 "ext/dtext/dtext.cpp.rl"
	{ sm->c1 = sm->p; }
#line 122 "ext/dtext/dtext.cpp.rl"
	{ sm->c2 = sm->p; }
	goto st387;
tr521:
#line 120 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
#line 121 "ext/dtext/dtext.cpp.rl"
	{ sm->c1 = sm->p; }
	goto st387;
st387:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof387;
case 387:
#line 8968 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr509;
		case 9: goto tr510;
		case 10: goto tr185;
		case 13: goto tr185;
		case 32: goto tr510;
		case 125: goto tr511;
	}
	if ( 11 <= (*( sm->p)) && (*( sm->p)) <= 12 )
		goto tr509;
	goto tr508;
tr508:
#line 121 "ext/dtext/dtext.cpp.rl"
	{ sm->c1 = sm->p; }
	goto st388;
st388:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof388;
case 388:
#line 8988 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto st389;
		case 9: goto tr514;
		case 10: goto tr185;
		case 13: goto tr185;
		case 32: goto tr514;
		case 125: goto tr515;
	}
	if ( 11 <= (*( sm->p)) && (*( sm->p)) <= 12 )
		goto st389;
	goto st388;
tr509:
#line 121 "ext/dtext/dtext.cpp.rl"
	{ sm->c1 = sm->p; }
	goto st389;
st389:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof389;
case 389:
#line 9008 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto st389;
		case 10: goto tr185;
		case 13: goto tr185;
		case 32: goto st389;
		case 125: goto tr185;
	}
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 12 )
		goto st389;
	goto st388;
tr514:
#line 122 "ext/dtext/dtext.cpp.rl"
	{ sm->c2 = sm->p; }
	goto st390;
st390:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof390;
case 390:
#line 9027 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto st389;
		case 9: goto st390;
		case 10: goto tr185;
		case 13: goto tr185;
		case 32: goto st390;
		case 125: goto st391;
	}
	if ( 11 <= (*( sm->p)) && (*( sm->p)) <= 12 )
		goto st389;
	goto st388;
tr515:
#line 122 "ext/dtext/dtext.cpp.rl"
	{ sm->c2 = sm->p; }
	goto st391;
tr511:
#line 121 "ext/dtext/dtext.cpp.rl"
	{ sm->c1 = sm->p; }
#line 122 "ext/dtext/dtext.cpp.rl"
	{ sm->c2 = sm->p; }
	goto st391;
st391:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof391;
case 391:
#line 9053 "ext/dtext/dtext.cpp"
	if ( (*( sm->p)) == 125 )
		goto st1007;
	goto tr185;
st1007:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1007;
case 1007:
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1374;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1374;
	} else
		goto tr1374;
	goto tr1373;
tr1374:
#line 123 "ext/dtext/dtext.cpp.rl"
	{ sm->d1 = sm->p; }
	goto st1008;
st1008:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1008;
case 1008:
#line 9078 "ext/dtext/dtext.cpp"
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st1008;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st1008;
	} else
		goto st1008;
	goto tr1375;
tr495:
#line 120 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
	goto st392;
st392:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof392;
case 392:
#line 9096 "ext/dtext/dtext.cpp"
	if ( (*( sm->p)) == 125 )
		goto st1009;
	goto tr185;
tr1383:
#line 123 "ext/dtext/dtext.cpp.rl"
	{ sm->d1 = sm->p; }
#line 124 "ext/dtext/dtext.cpp.rl"
	{ sm->d2 = sm->p; }
	goto st1009;
st1009:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1009;
case 1009:
#line 9110 "ext/dtext/dtext.cpp"
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1378;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1378;
	} else
		goto tr1378;
	goto tr1377;
tr1378:
#line 123 "ext/dtext/dtext.cpp.rl"
	{ sm->d1 = sm->p; }
	goto st1010;
st1010:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1010;
case 1010:
#line 9128 "ext/dtext/dtext.cpp"
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st1010;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st1010;
	} else
		goto st1010;
	goto tr1379;
tr506:
#line 120 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
	goto st393;
st393:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof393;
case 393:
#line 9146 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr509;
		case 9: goto tr520;
		case 10: goto tr185;
		case 13: goto tr185;
		case 32: goto tr520;
		case 124: goto tr521;
		case 125: goto tr522;
	}
	if ( 11 <= (*( sm->p)) && (*( sm->p)) <= 12 )
		goto tr509;
	goto tr508;
tr524:
#line 121 "ext/dtext/dtext.cpp.rl"
	{ sm->c1 = sm->p; }
#line 122 "ext/dtext/dtext.cpp.rl"
	{ sm->c2 = sm->p; }
	goto st394;
tr520:
#line 120 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
#line 121 "ext/dtext/dtext.cpp.rl"
	{ sm->c1 = sm->p; }
#line 122 "ext/dtext/dtext.cpp.rl"
	{ sm->c2 = sm->p; }
	goto st394;
st394:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof394;
case 394:
#line 9177 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr509;
		case 9: goto tr524;
		case 10: goto tr185;
		case 13: goto tr185;
		case 32: goto tr524;
		case 45: goto tr525;
		case 58: goto tr526;
		case 60: goto tr527;
		case 62: goto tr528;
		case 92: goto tr529;
		case 123: goto tr508;
		case 124: goto tr530;
		case 125: goto tr531;
		case 126: goto tr525;
	}
	if ( 11 <= (*( sm->p)) && (*( sm->p)) <= 12 )
		goto tr509;
	goto tr523;
tr523:
#line 121 "ext/dtext/dtext.cpp.rl"
	{ sm->c1 = sm->p; }
	goto st395;
st395:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof395;
case 395:
#line 9205 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto st389;
		case 9: goto tr533;
		case 10: goto tr185;
		case 13: goto tr185;
		case 32: goto tr533;
		case 123: goto st388;
		case 124: goto tr494;
		case 125: goto tr534;
	}
	if ( 11 <= (*( sm->p)) && (*( sm->p)) <= 12 )
		goto st389;
	goto st395;
tr533:
#line 120 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
#line 122 "ext/dtext/dtext.cpp.rl"
	{ sm->c2 = sm->p; }
	goto st396;
st396:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof396;
case 396:
#line 9229 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto st389;
		case 9: goto st396;
		case 10: goto tr185;
		case 13: goto tr185;
		case 32: goto st396;
		case 45: goto st397;
		case 58: goto st398;
		case 60: goto st402;
		case 62: goto st408;
		case 92: goto st411;
		case 123: goto st388;
		case 124: goto st414;
		case 125: goto st400;
		case 126: goto st397;
	}
	if ( 11 <= (*( sm->p)) && (*( sm->p)) <= 12 )
		goto st389;
	goto st395;
tr525:
#line 121 "ext/dtext/dtext.cpp.rl"
	{ sm->c1 = sm->p; }
	goto st397;
st397:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof397;
case 397:
#line 9257 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto st389;
		case 9: goto tr533;
		case 10: goto tr185;
		case 13: goto tr185;
		case 32: goto tr533;
		case 58: goto st398;
		case 60: goto st402;
		case 62: goto st408;
		case 92: goto st411;
		case 123: goto st388;
		case 124: goto tr504;
		case 125: goto tr534;
	}
	if ( 11 <= (*( sm->p)) && (*( sm->p)) <= 12 )
		goto st389;
	goto st395;
tr526:
#line 121 "ext/dtext/dtext.cpp.rl"
	{ sm->c1 = sm->p; }
	goto st398;
st398:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof398;
case 398:
#line 9283 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto st389;
		case 9: goto tr533;
		case 10: goto tr185;
		case 13: goto tr185;
		case 32: goto tr533;
		case 123: goto st399;
		case 124: goto tr506;
		case 125: goto tr543;
	}
	if ( 11 <= (*( sm->p)) && (*( sm->p)) <= 12 )
		goto st389;
	goto st395;
tr553:
#line 121 "ext/dtext/dtext.cpp.rl"
	{ sm->c1 = sm->p; }
	goto st399;
st399:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof399;
case 399:
#line 9305 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto st389;
		case 9: goto tr533;
		case 10: goto tr185;
		case 13: goto tr185;
		case 32: goto tr533;
		case 124: goto tr494;
		case 125: goto tr534;
	}
	if ( 11 <= (*( sm->p)) && (*( sm->p)) <= 12 )
		goto st389;
	goto st388;
tr531:
#line 121 "ext/dtext/dtext.cpp.rl"
	{ sm->c1 = sm->p; }
#line 122 "ext/dtext/dtext.cpp.rl"
	{ sm->c2 = sm->p; }
	goto st400;
tr522:
#line 120 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
#line 121 "ext/dtext/dtext.cpp.rl"
	{ sm->c1 = sm->p; }
#line 122 "ext/dtext/dtext.cpp.rl"
	{ sm->c2 = sm->p; }
	goto st400;
tr534:
#line 120 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
#line 122 "ext/dtext/dtext.cpp.rl"
	{ sm->c2 = sm->p; }
	goto st400;
st400:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof400;
case 400:
#line 9342 "ext/dtext/dtext.cpp"
	if ( (*( sm->p)) == 125 )
		goto st1011;
	goto tr185;
st1011:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1011;
case 1011:
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1381;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1381;
	} else
		goto tr1381;
	goto tr1377;
tr1381:
#line 123 "ext/dtext/dtext.cpp.rl"
	{ sm->d1 = sm->p; }
	goto st1012;
st1012:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1012;
case 1012:
#line 9367 "ext/dtext/dtext.cpp"
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st1012;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st1012;
	} else
		goto st1012;
	goto tr1379;
tr543:
#line 120 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
#line 122 "ext/dtext/dtext.cpp.rl"
	{ sm->c2 = sm->p; }
	goto st401;
st401:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof401;
case 401:
#line 9387 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto tr493;
		case 32: goto tr493;
		case 124: goto tr494;
		case 125: goto tr545;
	}
	goto tr185;
tr545:
#line 120 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
	goto st1013;
st1013:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1013;
case 1013:
#line 9403 "ext/dtext/dtext.cpp"
	if ( (*( sm->p)) == 125 )
		goto tr1383;
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1381;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1381;
	} else
		goto tr1381;
	goto tr1377;
tr527:
#line 121 "ext/dtext/dtext.cpp.rl"
	{ sm->c1 = sm->p; }
	goto st402;
st402:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof402;
case 402:
#line 9423 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto st389;
		case 9: goto tr533;
		case 10: goto tr185;
		case 13: goto tr185;
		case 32: goto tr533;
		case 123: goto st388;
		case 124: goto tr546;
		case 125: goto tr534;
	}
	if ( 11 <= (*( sm->p)) && (*( sm->p)) <= 12 )
		goto st389;
	goto st395;
tr546:
#line 120 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
	goto st403;
st403:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof403;
case 403:
#line 9445 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr509;
		case 9: goto tr510;
		case 10: goto tr185;
		case 13: goto tr185;
		case 32: goto tr510;
		case 62: goto tr547;
		case 125: goto tr511;
	}
	if ( 11 <= (*( sm->p)) && (*( sm->p)) <= 12 )
		goto tr509;
	goto tr508;
tr547:
#line 121 "ext/dtext/dtext.cpp.rl"
	{ sm->c1 = sm->p; }
	goto st404;
st404:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof404;
case 404:
#line 9466 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto st389;
		case 9: goto tr514;
		case 10: goto tr185;
		case 13: goto tr185;
		case 32: goto tr514;
		case 95: goto st405;
		case 125: goto tr515;
	}
	if ( 11 <= (*( sm->p)) && (*( sm->p)) <= 12 )
		goto st389;
	goto st388;
st405:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof405;
case 405:
	switch( (*( sm->p)) ) {
		case 0: goto st389;
		case 9: goto tr514;
		case 10: goto tr185;
		case 13: goto tr185;
		case 32: goto tr514;
		case 60: goto st406;
		case 125: goto tr515;
	}
	if ( 11 <= (*( sm->p)) && (*( sm->p)) <= 12 )
		goto st389;
	goto st388;
st406:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof406;
case 406:
	switch( (*( sm->p)) ) {
		case 0: goto st389;
		case 9: goto tr514;
		case 10: goto tr185;
		case 13: goto tr185;
		case 32: goto tr514;
		case 124: goto st407;
		case 125: goto tr515;
	}
	if ( 11 <= (*( sm->p)) && (*( sm->p)) <= 12 )
		goto st389;
	goto st388;
st407:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof407;
case 407:
	switch( (*( sm->p)) ) {
		case 0: goto st389;
		case 9: goto tr514;
		case 10: goto tr185;
		case 13: goto tr185;
		case 32: goto tr514;
		case 62: goto st399;
		case 125: goto tr515;
	}
	if ( 11 <= (*( sm->p)) && (*( sm->p)) <= 12 )
		goto st389;
	goto st388;
tr528:
#line 121 "ext/dtext/dtext.cpp.rl"
	{ sm->c1 = sm->p; }
	goto st408;
st408:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof408;
case 408:
#line 9535 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto st389;
		case 9: goto tr533;
		case 10: goto tr185;
		case 13: goto tr185;
		case 32: goto tr533;
		case 58: goto st409;
		case 123: goto st388;
		case 124: goto tr552;
		case 125: goto tr534;
	}
	if ( 11 <= (*( sm->p)) && (*( sm->p)) <= 12 )
		goto st389;
	goto st395;
st409:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof409;
case 409:
	switch( (*( sm->p)) ) {
		case 0: goto st389;
		case 9: goto tr533;
		case 10: goto tr185;
		case 13: goto tr185;
		case 32: goto tr533;
		case 123: goto st388;
		case 124: goto tr506;
		case 125: goto tr534;
	}
	if ( 11 <= (*( sm->p)) && (*( sm->p)) <= 12 )
		goto st389;
	goto st395;
tr552:
#line 120 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
	goto st410;
st410:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof410;
case 410:
#line 9575 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr509;
		case 9: goto tr510;
		case 10: goto tr185;
		case 13: goto tr185;
		case 32: goto tr510;
		case 51: goto tr553;
		case 125: goto tr511;
	}
	if ( 11 <= (*( sm->p)) && (*( sm->p)) <= 12 )
		goto tr509;
	goto tr508;
tr529:
#line 121 "ext/dtext/dtext.cpp.rl"
	{ sm->c1 = sm->p; }
	goto st411;
st411:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof411;
case 411:
#line 9596 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto st389;
		case 9: goto tr533;
		case 10: goto tr185;
		case 13: goto tr185;
		case 32: goto tr533;
		case 123: goto st388;
		case 124: goto tr554;
		case 125: goto tr534;
	}
	if ( 11 <= (*( sm->p)) && (*( sm->p)) <= 12 )
		goto st389;
	goto st395;
tr554:
#line 120 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
	goto st412;
st412:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof412;
case 412:
#line 9618 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr509;
		case 9: goto tr510;
		case 10: goto tr185;
		case 13: goto tr185;
		case 32: goto tr510;
		case 124: goto tr555;
		case 125: goto tr511;
	}
	if ( 11 <= (*( sm->p)) && (*( sm->p)) <= 12 )
		goto tr509;
	goto tr508;
tr555:
#line 121 "ext/dtext/dtext.cpp.rl"
	{ sm->c1 = sm->p; }
	goto st413;
st413:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof413;
case 413:
#line 9639 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto st389;
		case 9: goto tr514;
		case 10: goto tr185;
		case 13: goto tr185;
		case 32: goto tr514;
		case 47: goto st399;
		case 125: goto tr515;
	}
	if ( 11 <= (*( sm->p)) && (*( sm->p)) <= 12 )
		goto st389;
	goto st388;
tr504:
#line 120 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
	goto st414;
tr530:
#line 121 "ext/dtext/dtext.cpp.rl"
	{ sm->c1 = sm->p; }
	goto st414;
st414:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof414;
case 414:
#line 9664 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr509;
		case 9: goto tr510;
		case 10: goto tr185;
		case 13: goto tr185;
		case 32: goto tr510;
		case 95: goto tr556;
		case 119: goto tr557;
		case 124: goto tr558;
		case 125: goto tr511;
	}
	if ( (*( sm->p)) < 48 ) {
		if ( 11 <= (*( sm->p)) && (*( sm->p)) <= 12 )
			goto tr509;
	} else if ( (*( sm->p)) > 57 ) {
		if ( (*( sm->p)) > 90 ) {
			if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
				goto tr553;
		} else if ( (*( sm->p)) >= 65 )
			goto tr553;
	} else
		goto tr553;
	goto tr508;
tr556:
#line 121 "ext/dtext/dtext.cpp.rl"
	{ sm->c1 = sm->p; }
	goto st415;
st415:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof415;
case 415:
#line 9696 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto st389;
		case 9: goto tr514;
		case 10: goto tr185;
		case 13: goto tr185;
		case 32: goto tr514;
		case 124: goto st399;
		case 125: goto tr515;
	}
	if ( 11 <= (*( sm->p)) && (*( sm->p)) <= 12 )
		goto st389;
	goto st388;
tr557:
#line 121 "ext/dtext/dtext.cpp.rl"
	{ sm->c1 = sm->p; }
	goto st416;
st416:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof416;
case 416:
#line 9717 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto st389;
		case 9: goto tr533;
		case 10: goto tr185;
		case 13: goto tr185;
		case 32: goto tr533;
		case 124: goto tr506;
		case 125: goto tr534;
	}
	if ( 11 <= (*( sm->p)) && (*( sm->p)) <= 12 )
		goto st389;
	goto st388;
tr558:
#line 121 "ext/dtext/dtext.cpp.rl"
	{ sm->c1 = sm->p; }
	goto st417;
st417:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof417;
case 417:
#line 9738 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto st389;
		case 9: goto tr514;
		case 10: goto tr185;
		case 13: goto tr185;
		case 32: goto tr514;
		case 95: goto st418;
		case 125: goto tr515;
	}
	if ( 11 <= (*( sm->p)) && (*( sm->p)) <= 12 )
		goto st389;
	goto st388;
st418:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof418;
case 418:
	switch( (*( sm->p)) ) {
		case 0: goto st389;
		case 9: goto tr514;
		case 10: goto tr185;
		case 13: goto tr185;
		case 32: goto tr514;
		case 124: goto st415;
		case 125: goto tr515;
	}
	if ( 11 <= (*( sm->p)) && (*( sm->p)) <= 12 )
		goto st389;
	goto st388;
tr507:
#line 120 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
	goto st419;
st419:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof419;
case 419:
#line 9775 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto tr493;
		case 32: goto tr493;
		case 124: goto tr494;
		case 125: goto tr561;
	}
	goto tr185;
tr561:
#line 120 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
	goto st1014;
st1014:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1014;
case 1014:
#line 9791 "ext/dtext/dtext.cpp"
	if ( (*( sm->p)) == 125 )
		goto st1009;
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1378;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1378;
	} else
		goto tr1378;
	goto tr1377;
tr488:
#line 119 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st420;
st420:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof420;
case 420:
#line 9811 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr185;
		case 9: goto tr493;
		case 32: goto tr493;
		case 123: goto tr185;
		case 124: goto tr546;
		case 125: goto tr495;
	}
	if ( 10 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr185;
	goto st382;
tr489:
#line 119 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st421;
st421:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof421;
case 421:
#line 9831 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr185;
		case 9: goto tr493;
		case 32: goto tr493;
		case 58: goto st422;
		case 123: goto tr185;
		case 124: goto tr552;
		case 125: goto tr495;
	}
	if ( 10 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr185;
	goto st382;
st422:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof422;
case 422:
	switch( (*( sm->p)) ) {
		case 0: goto tr185;
		case 9: goto tr493;
		case 32: goto tr493;
		case 123: goto tr185;
		case 124: goto tr506;
		case 125: goto tr495;
	}
	if ( 10 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr185;
	goto st382;
tr490:
#line 119 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st423;
st423:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof423;
case 423:
#line 9867 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr185;
		case 9: goto tr493;
		case 32: goto tr493;
		case 123: goto tr185;
		case 124: goto tr554;
		case 125: goto tr495;
	}
	if ( 10 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr185;
	goto st382;
tr491:
#line 119 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st424;
st424:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof424;
case 424:
#line 9887 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 95: goto st425;
		case 119: goto st426;
		case 124: goto st427;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st386;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st386;
	} else
		goto st386;
	goto tr185;
st425:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof425;
case 425:
	if ( (*( sm->p)) == 124 )
		goto st386;
	goto tr185;
st426:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof426;
case 426:
	switch( (*( sm->p)) ) {
		case 9: goto tr493;
		case 32: goto tr493;
		case 124: goto tr506;
		case 125: goto tr495;
	}
	goto tr185;
st427:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof427;
case 427:
	if ( (*( sm->p)) == 95 )
		goto st428;
	goto tr185;
st428:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof428;
case 428:
	if ( (*( sm->p)) == 124 )
		goto st425;
	goto tr185;
st0:
 sm->cs = 0;
	goto _out;
tr1316:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 117 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
#line 562 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1015;
st1015:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1015;
case 1015:
#line 9949 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 76: goto tr1384;
		case 80: goto tr1385;
		case 82: goto tr1386;
		case 91: goto tr1361;
		case 108: goto tr1384;
		case 112: goto tr1385;
		case 114: goto tr1386;
		case 123: goto tr1362;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1360;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1360;
	} else
		goto tr1360;
	goto tr1338;
tr1384:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 562 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1016;
st1016:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1016;
case 1016:
#line 9979 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 73: goto tr1387;
		case 91: goto tr1361;
		case 105: goto tr1387;
		case 123: goto tr1362;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1360;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1360;
	} else
		goto tr1360;
	goto tr1338;
tr1387:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 562 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1017;
st1017:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1017;
case 1017:
#line 10005 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 65: goto tr1388;
		case 91: goto tr1361;
		case 97: goto tr1388;
		case 123: goto tr1362;
	}
	if ( (*( sm->p)) < 66 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1360;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 98 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1360;
	} else
		goto tr1360;
	goto tr1338;
tr1388:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 562 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1018;
st1018:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1018;
case 1018:
#line 10031 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 83: goto tr1389;
		case 91: goto tr1361;
		case 115: goto tr1389;
		case 123: goto tr1362;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1360;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1360;
	} else
		goto tr1360;
	goto tr1338;
tr1389:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 562 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1019;
st1019:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1019;
case 1019:
#line 10057 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 32: goto st429;
		case 91: goto tr1361;
		case 123: goto tr1362;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1360;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1360;
	} else
		goto tr1360;
	goto tr1338;
st429:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof429;
case 429:
	if ( (*( sm->p)) == 35 )
		goto st430;
	goto tr188;
st430:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof430;
case 430:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr568;
	goto tr188;
tr568:
#line 117 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st1020;
st1020:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1020;
case 1020:
#line 10094 "ext/dtext/dtext.cpp"
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto st1020;
	goto tr1391;
tr1385:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 562 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1021;
st1021:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1021;
case 1021:
#line 10108 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 80: goto tr1393;
		case 91: goto tr1361;
		case 112: goto tr1393;
		case 123: goto tr1362;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1360;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1360;
	} else
		goto tr1360;
	goto tr1338;
tr1393:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 562 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1022;
st1022:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1022;
case 1022:
#line 10134 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 69: goto tr1394;
		case 91: goto tr1361;
		case 101: goto tr1394;
		case 123: goto tr1362;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1360;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1360;
	} else
		goto tr1360;
	goto tr1338;
tr1394:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 562 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1023;
st1023:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1023;
case 1023:
#line 10160 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 65: goto tr1395;
		case 91: goto tr1361;
		case 97: goto tr1395;
		case 123: goto tr1362;
	}
	if ( (*( sm->p)) < 66 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1360;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 98 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1360;
	} else
		goto tr1360;
	goto tr1338;
tr1395:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 562 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1024;
st1024:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1024;
case 1024:
#line 10186 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 76: goto tr1396;
		case 91: goto tr1361;
		case 108: goto tr1396;
		case 123: goto tr1362;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1360;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1360;
	} else
		goto tr1360;
	goto tr1338;
tr1396:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 562 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1025;
st1025:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1025;
case 1025:
#line 10212 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 32: goto st431;
		case 91: goto tr1361;
		case 123: goto tr1362;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1360;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1360;
	} else
		goto tr1360;
	goto tr1338;
st431:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof431;
case 431:
	if ( (*( sm->p)) == 35 )
		goto st432;
	goto tr188;
st432:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof432;
case 432:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr570;
	goto tr188;
tr570:
#line 117 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st1026;
st1026:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1026;
case 1026:
#line 10249 "ext/dtext/dtext.cpp"
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto st1026;
	goto tr1398;
tr1386:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 562 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1027;
st1027:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1027;
case 1027:
#line 10263 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 84: goto tr1400;
		case 91: goto tr1361;
		case 116: goto tr1400;
		case 123: goto tr1362;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1360;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1360;
	} else
		goto tr1360;
	goto tr1338;
tr1400:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 562 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1028;
st1028:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1028;
case 1028:
#line 10289 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 73: goto tr1401;
		case 83: goto tr1402;
		case 91: goto tr1361;
		case 105: goto tr1401;
		case 115: goto tr1402;
		case 123: goto tr1362;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1360;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1360;
	} else
		goto tr1360;
	goto tr1338;
tr1401:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 562 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1029;
st1029:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1029;
case 1029:
#line 10317 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 83: goto tr1403;
		case 91: goto tr1361;
		case 115: goto tr1403;
		case 123: goto tr1362;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1360;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1360;
	} else
		goto tr1360;
	goto tr1338;
tr1403:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 562 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1030;
st1030:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1030;
case 1030:
#line 10343 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 84: goto tr1404;
		case 91: goto tr1361;
		case 116: goto tr1404;
		case 123: goto tr1362;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1360;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1360;
	} else
		goto tr1360;
	goto tr1338;
tr1404:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 562 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1031;
st1031:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1031;
case 1031:
#line 10369 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 32: goto st433;
		case 91: goto tr1361;
		case 123: goto tr1362;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1360;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1360;
	} else
		goto tr1360;
	goto tr1338;
st433:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof433;
case 433:
	if ( (*( sm->p)) == 35 )
		goto st434;
	goto tr188;
st434:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof434;
case 434:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr572;
	goto tr188;
tr572:
#line 117 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st1032;
st1032:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1032;
case 1032:
#line 10406 "ext/dtext/dtext.cpp"
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto st1032;
	goto tr1406;
tr1402:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 562 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1033;
st1033:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1033;
case 1033:
#line 10420 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 84: goto tr1408;
		case 91: goto tr1361;
		case 116: goto tr1408;
		case 123: goto tr1362;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1360;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1360;
	} else
		goto tr1360;
	goto tr1338;
tr1408:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 562 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1034;
st1034:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1034;
case 1034:
#line 10446 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 65: goto tr1409;
		case 91: goto tr1361;
		case 97: goto tr1409;
		case 123: goto tr1362;
	}
	if ( (*( sm->p)) < 66 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1360;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 98 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1360;
	} else
		goto tr1360;
	goto tr1338;
tr1409:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 562 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1035;
st1035:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1035;
case 1035:
#line 10472 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 84: goto tr1410;
		case 91: goto tr1361;
		case 116: goto tr1410;
		case 123: goto tr1362;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1360;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1360;
	} else
		goto tr1360;
	goto tr1338;
tr1410:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 562 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1036;
st1036:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1036;
case 1036:
#line 10498 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 73: goto tr1411;
		case 91: goto tr1361;
		case 105: goto tr1411;
		case 123: goto tr1362;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1360;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1360;
	} else
		goto tr1360;
	goto tr1338;
tr1411:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 562 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1037;
st1037:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1037;
case 1037:
#line 10524 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 79: goto tr1412;
		case 91: goto tr1361;
		case 111: goto tr1412;
		case 123: goto tr1362;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1360;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1360;
	} else
		goto tr1360;
	goto tr1338;
tr1412:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 562 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1038;
st1038:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1038;
case 1038:
#line 10550 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 78: goto tr1413;
		case 91: goto tr1361;
		case 110: goto tr1413;
		case 123: goto tr1362;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1360;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1360;
	} else
		goto tr1360;
	goto tr1338;
tr1413:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 562 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1039;
st1039:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1039;
case 1039:
#line 10576 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 32: goto st435;
		case 91: goto tr1361;
		case 123: goto tr1362;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1360;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1360;
	} else
		goto tr1360;
	goto tr1338;
st435:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof435;
case 435:
	if ( (*( sm->p)) == 35 )
		goto st436;
	goto tr188;
st436:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof436;
case 436:
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr574;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr574;
	} else
		goto tr574;
	goto tr188;
tr574:
#line 117 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st1040;
st1040:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1040;
case 1040:
#line 10619 "ext/dtext/dtext.cpp"
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st1040;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st1040;
	} else
		goto st1040;
	goto tr1415;
tr1317:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 117 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
#line 562 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1041;
st1041:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1041;
case 1041:
#line 10641 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 65: goto tr1417;
		case 85: goto tr1418;
		case 91: goto tr1361;
		case 97: goto tr1417;
		case 117: goto tr1418;
		case 123: goto tr1362;
	}
	if ( (*( sm->p)) < 66 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1360;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 98 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1360;
	} else
		goto tr1360;
	goto tr1338;
tr1417:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 562 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1042;
st1042:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1042;
case 1042:
#line 10669 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 78: goto tr1419;
		case 91: goto tr1361;
		case 110: goto tr1419;
		case 123: goto tr1362;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1360;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1360;
	} else
		goto tr1360;
	goto tr1338;
tr1419:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 562 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1043;
st1043:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1043;
case 1043:
#line 10695 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 32: goto st437;
		case 91: goto tr1361;
		case 123: goto tr1362;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1360;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1360;
	} else
		goto tr1360;
	goto tr1338;
st437:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof437;
case 437:
	if ( (*( sm->p)) == 35 )
		goto st438;
	goto tr188;
st438:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof438;
case 438:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr576;
	goto tr188;
tr576:
#line 117 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st1044;
st1044:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1044;
case 1044:
#line 10732 "ext/dtext/dtext.cpp"
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto st1044;
	goto tr1421;
tr1418:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 562 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1045;
st1045:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1045;
case 1045:
#line 10746 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 82: goto tr1423;
		case 91: goto tr1361;
		case 114: goto tr1423;
		case 123: goto tr1362;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1360;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1360;
	} else
		goto tr1360;
	goto tr1338;
tr1423:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 562 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1046;
st1046:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1046;
case 1046:
#line 10772 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 32: goto st439;
		case 91: goto tr1361;
		case 123: goto tr1362;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1360;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1360;
	} else
		goto tr1360;
	goto tr1338;
st439:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof439;
case 439:
	if ( (*( sm->p)) == 35 )
		goto st440;
	goto tr188;
st440:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof440;
case 440:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr578;
	goto tr188;
tr578:
#line 117 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st1047;
st1047:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1047;
case 1047:
#line 10809 "ext/dtext/dtext.cpp"
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto st1047;
	goto tr1425;
tr1318:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 117 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
#line 562 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1048;
st1048:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1048;
case 1048:
#line 10825 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 79: goto tr1427;
		case 91: goto tr1361;
		case 111: goto tr1427;
		case 123: goto tr1362;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1360;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1360;
	} else
		goto tr1360;
	goto tr1338;
tr1427:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 562 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1049;
st1049:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1049;
case 1049:
#line 10851 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 77: goto tr1428;
		case 91: goto tr1361;
		case 109: goto tr1428;
		case 123: goto tr1362;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1360;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1360;
	} else
		goto tr1360;
	goto tr1338;
tr1428:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 562 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1050;
st1050:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1050;
case 1050:
#line 10877 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 77: goto tr1429;
		case 91: goto tr1361;
		case 109: goto tr1429;
		case 123: goto tr1362;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1360;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1360;
	} else
		goto tr1360;
	goto tr1338;
tr1429:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 562 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1051;
st1051:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1051;
case 1051:
#line 10903 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 69: goto tr1430;
		case 73: goto tr1431;
		case 91: goto tr1361;
		case 101: goto tr1430;
		case 105: goto tr1431;
		case 123: goto tr1362;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1360;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1360;
	} else
		goto tr1360;
	goto tr1338;
tr1430:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 562 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1052;
st1052:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1052;
case 1052:
#line 10931 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 78: goto tr1432;
		case 91: goto tr1361;
		case 110: goto tr1432;
		case 123: goto tr1362;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1360;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1360;
	} else
		goto tr1360;
	goto tr1338;
tr1432:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 562 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1053;
st1053:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1053;
case 1053:
#line 10957 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 84: goto tr1433;
		case 91: goto tr1361;
		case 116: goto tr1433;
		case 123: goto tr1362;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1360;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1360;
	} else
		goto tr1360;
	goto tr1338;
tr1433:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 562 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1054;
st1054:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1054;
case 1054:
#line 10983 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 32: goto st441;
		case 91: goto tr1361;
		case 123: goto tr1362;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1360;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1360;
	} else
		goto tr1360;
	goto tr1338;
st441:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof441;
case 441:
	if ( (*( sm->p)) == 35 )
		goto st442;
	goto tr188;
st442:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof442;
case 442:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr580;
	goto tr188;
tr580:
#line 117 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st1055;
st1055:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1055;
case 1055:
#line 11020 "ext/dtext/dtext.cpp"
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto st1055;
	goto tr1435;
tr1431:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 562 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1056;
st1056:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1056;
case 1056:
#line 11034 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 84: goto tr1437;
		case 91: goto tr1361;
		case 116: goto tr1437;
		case 123: goto tr1362;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1360;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1360;
	} else
		goto tr1360;
	goto tr1338;
tr1437:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 562 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1057;
st1057:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1057;
case 1057:
#line 11060 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 32: goto st443;
		case 91: goto tr1361;
		case 123: goto tr1362;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1360;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1360;
	} else
		goto tr1360;
	goto tr1338;
st443:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof443;
case 443:
	if ( (*( sm->p)) == 35 )
		goto st444;
	goto tr188;
st444:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof444;
case 444:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr582;
	goto tr188;
tr582:
#line 117 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st1058;
st1058:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1058;
case 1058:
#line 11097 "ext/dtext/dtext.cpp"
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto st1058;
	goto tr1439;
tr1319:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 117 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
#line 562 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1059;
st1059:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1059;
case 1059:
#line 11113 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 69: goto tr1441;
		case 77: goto tr1442;
		case 91: goto tr1361;
		case 101: goto tr1441;
		case 109: goto tr1442;
		case 123: goto tr1362;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1360;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1360;
	} else
		goto tr1360;
	goto tr1338;
tr1441:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 562 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1060;
st1060:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1060;
case 1060:
#line 11141 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 86: goto tr1443;
		case 91: goto tr1361;
		case 118: goto tr1443;
		case 123: goto tr1362;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1360;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1360;
	} else
		goto tr1360;
	goto tr1338;
tr1443:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 562 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1061;
st1061:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1061;
case 1061:
#line 11167 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 73: goto tr1444;
		case 91: goto tr1361;
		case 105: goto tr1444;
		case 123: goto tr1362;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1360;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1360;
	} else
		goto tr1360;
	goto tr1338;
tr1444:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 562 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1062;
st1062:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1062;
case 1062:
#line 11193 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 65: goto tr1445;
		case 91: goto tr1361;
		case 97: goto tr1445;
		case 123: goto tr1362;
	}
	if ( (*( sm->p)) < 66 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1360;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 98 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1360;
	} else
		goto tr1360;
	goto tr1338;
tr1445:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 562 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1063;
st1063:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1063;
case 1063:
#line 11219 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 78: goto tr1446;
		case 91: goto tr1361;
		case 110: goto tr1446;
		case 123: goto tr1362;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1360;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1360;
	} else
		goto tr1360;
	goto tr1338;
tr1446:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 562 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1064;
st1064:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1064;
case 1064:
#line 11245 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 84: goto tr1447;
		case 91: goto tr1361;
		case 116: goto tr1447;
		case 123: goto tr1362;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1360;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1360;
	} else
		goto tr1360;
	goto tr1338;
tr1447:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 562 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1065;
st1065:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1065;
case 1065:
#line 11271 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 65: goto tr1448;
		case 91: goto tr1361;
		case 97: goto tr1448;
		case 123: goto tr1362;
	}
	if ( (*( sm->p)) < 66 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1360;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 98 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1360;
	} else
		goto tr1360;
	goto tr1338;
tr1448:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 562 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1066;
st1066:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1066;
case 1066:
#line 11297 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 82: goto tr1449;
		case 91: goto tr1361;
		case 114: goto tr1449;
		case 123: goto tr1362;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1360;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1360;
	} else
		goto tr1360;
	goto tr1338;
tr1449:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 562 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1067;
st1067:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1067;
case 1067:
#line 11323 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 84: goto tr1450;
		case 91: goto tr1361;
		case 116: goto tr1450;
		case 123: goto tr1362;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1360;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1360;
	} else
		goto tr1360;
	goto tr1338;
tr1450:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 562 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1068;
st1068:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1068;
case 1068:
#line 11349 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 32: goto st445;
		case 91: goto tr1361;
		case 123: goto tr1362;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1360;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1360;
	} else
		goto tr1360;
	goto tr1338;
st445:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof445;
case 445:
	if ( (*( sm->p)) == 35 )
		goto st446;
	goto tr188;
st446:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof446;
case 446:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr584;
	goto tr188;
tr584:
#line 117 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st1069;
st1069:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1069;
case 1069:
#line 11386 "ext/dtext/dtext.cpp"
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto st1069;
	goto tr1452;
tr1442:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 562 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1070;
st1070:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1070;
case 1070:
#line 11400 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 65: goto tr1454;
		case 91: goto tr1361;
		case 97: goto tr1454;
		case 123: goto tr1362;
	}
	if ( (*( sm->p)) < 66 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1360;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 98 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1360;
	} else
		goto tr1360;
	goto tr1338;
tr1454:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 562 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1071;
st1071:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1071;
case 1071:
#line 11426 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 73: goto tr1455;
		case 91: goto tr1361;
		case 105: goto tr1455;
		case 123: goto tr1362;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1360;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1360;
	} else
		goto tr1360;
	goto tr1338;
tr1455:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 562 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1072;
st1072:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1072;
case 1072:
#line 11452 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 76: goto tr1456;
		case 91: goto tr1361;
		case 108: goto tr1456;
		case 123: goto tr1362;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1360;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1360;
	} else
		goto tr1360;
	goto tr1338;
tr1456:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 562 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1073;
st1073:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1073;
case 1073:
#line 11478 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 32: goto st447;
		case 91: goto tr1361;
		case 123: goto tr1362;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1360;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1360;
	} else
		goto tr1360;
	goto tr1338;
st447:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof447;
case 447:
	if ( (*( sm->p)) == 35 )
		goto st448;
	goto tr188;
st448:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof448;
case 448:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr586;
	goto tr188;
tr1460:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
	goto st1074;
tr586:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 117 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st1074;
st1074:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1074;
case 1074:
#line 11521 "ext/dtext/dtext.cpp"
	if ( (*( sm->p)) == 47 )
		goto tr1459;
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr1460;
	goto tr1458;
tr1459:
#line 118 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
	goto st449;
st449:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof449;
case 449:
#line 11535 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 45: goto tr588;
		case 61: goto tr588;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr588;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr588;
	} else
		goto tr588;
	goto tr587;
tr588:
#line 119 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st1075;
st1075:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1075;
case 1075:
#line 11557 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 45: goto st1075;
		case 61: goto st1075;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st1075;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st1075;
	} else
		goto st1075;
	goto tr1461;
tr1320:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 117 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
#line 562 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1076;
st1076:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1076;
case 1076:
#line 11583 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 65: goto tr1463;
		case 69: goto tr1464;
		case 76: goto tr1465;
		case 79: goto tr1466;
		case 91: goto tr1361;
		case 97: goto tr1463;
		case 101: goto tr1464;
		case 108: goto tr1465;
		case 111: goto tr1466;
		case 123: goto tr1362;
	}
	if ( (*( sm->p)) < 66 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1360;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 98 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1360;
	} else
		goto tr1360;
	goto tr1338;
tr1463:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 562 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1077;
st1077:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1077;
case 1077:
#line 11615 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 86: goto tr1467;
		case 91: goto tr1361;
		case 118: goto tr1467;
		case 123: goto tr1362;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1360;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1360;
	} else
		goto tr1360;
	goto tr1338;
tr1467:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 562 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1078;
st1078:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1078;
case 1078:
#line 11641 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 71: goto tr1468;
		case 91: goto tr1361;
		case 103: goto tr1468;
		case 123: goto tr1362;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1360;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1360;
	} else
		goto tr1360;
	goto tr1338;
tr1468:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 562 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1079;
st1079:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1079;
case 1079:
#line 11667 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 82: goto tr1469;
		case 91: goto tr1361;
		case 114: goto tr1469;
		case 123: goto tr1362;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1360;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1360;
	} else
		goto tr1360;
	goto tr1338;
tr1469:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 562 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1080;
st1080:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1080;
case 1080:
#line 11693 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 79: goto tr1470;
		case 91: goto tr1361;
		case 111: goto tr1470;
		case 123: goto tr1362;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1360;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1360;
	} else
		goto tr1360;
	goto tr1338;
tr1470:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 562 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1081;
st1081:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1081;
case 1081:
#line 11719 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 85: goto tr1471;
		case 91: goto tr1361;
		case 117: goto tr1471;
		case 123: goto tr1362;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1360;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1360;
	} else
		goto tr1360;
	goto tr1338;
tr1471:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 562 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1082;
st1082:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1082;
case 1082:
#line 11745 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 80: goto tr1472;
		case 91: goto tr1361;
		case 112: goto tr1472;
		case 123: goto tr1362;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1360;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1360;
	} else
		goto tr1360;
	goto tr1338;
tr1472:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 562 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1083;
st1083:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1083;
case 1083:
#line 11771 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 32: goto st450;
		case 91: goto tr1361;
		case 123: goto tr1362;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1360;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1360;
	} else
		goto tr1360;
	goto tr1338;
st450:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof450;
case 450:
	if ( (*( sm->p)) == 35 )
		goto st451;
	goto tr188;
st451:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof451;
case 451:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr590;
	goto tr188;
tr590:
#line 117 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st1084;
st1084:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1084;
case 1084:
#line 11808 "ext/dtext/dtext.cpp"
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto st1084;
	goto tr1474;
tr1464:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 562 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1085;
st1085:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1085;
case 1085:
#line 11822 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 69: goto tr1476;
		case 91: goto tr1361;
		case 101: goto tr1476;
		case 123: goto tr1362;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1360;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1360;
	} else
		goto tr1360;
	goto tr1338;
tr1476:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 562 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1086;
st1086:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1086;
case 1086:
#line 11848 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 68: goto tr1477;
		case 91: goto tr1361;
		case 100: goto tr1477;
		case 123: goto tr1362;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1360;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1360;
	} else
		goto tr1360;
	goto tr1338;
tr1477:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 562 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1087;
st1087:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1087;
case 1087:
#line 11874 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 66: goto tr1478;
		case 91: goto tr1361;
		case 98: goto tr1478;
		case 123: goto tr1362;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1360;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1360;
	} else
		goto tr1360;
	goto tr1338;
tr1478:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 562 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1088;
st1088:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1088;
case 1088:
#line 11900 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 65: goto tr1479;
		case 91: goto tr1361;
		case 97: goto tr1479;
		case 123: goto tr1362;
	}
	if ( (*( sm->p)) < 66 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1360;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 98 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1360;
	} else
		goto tr1360;
	goto tr1338;
tr1479:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 562 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1089;
st1089:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1089;
case 1089:
#line 11926 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 67: goto tr1480;
		case 91: goto tr1361;
		case 99: goto tr1480;
		case 123: goto tr1362;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1360;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1360;
	} else
		goto tr1360;
	goto tr1338;
tr1480:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 562 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1090;
st1090:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1090;
case 1090:
#line 11952 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 75: goto tr1481;
		case 91: goto tr1361;
		case 107: goto tr1481;
		case 123: goto tr1362;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1360;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1360;
	} else
		goto tr1360;
	goto tr1338;
tr1481:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 562 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1091;
st1091:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1091;
case 1091:
#line 11978 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 32: goto st452;
		case 91: goto tr1361;
		case 123: goto tr1362;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1360;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1360;
	} else
		goto tr1360;
	goto tr1338;
st452:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof452;
case 452:
	if ( (*( sm->p)) == 35 )
		goto st453;
	goto tr188;
st453:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof453;
case 453:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr592;
	goto tr188;
tr592:
#line 117 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st1092;
st1092:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1092;
case 1092:
#line 12015 "ext/dtext/dtext.cpp"
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto st1092;
	goto tr1483;
tr1465:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 562 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1093;
st1093:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1093;
case 1093:
#line 12029 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 65: goto tr1485;
		case 91: goto tr1361;
		case 97: goto tr1485;
		case 123: goto tr1362;
	}
	if ( (*( sm->p)) < 66 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1360;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 98 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1360;
	} else
		goto tr1360;
	goto tr1338;
tr1485:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 562 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1094;
st1094:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1094;
case 1094:
#line 12055 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 71: goto tr1486;
		case 91: goto tr1361;
		case 103: goto tr1486;
		case 123: goto tr1362;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1360;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1360;
	} else
		goto tr1360;
	goto tr1338;
tr1486:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 562 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1095;
st1095:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1095;
case 1095:
#line 12081 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 32: goto st454;
		case 91: goto tr1361;
		case 123: goto tr1362;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1360;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1360;
	} else
		goto tr1360;
	goto tr1338;
st454:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof454;
case 454:
	if ( (*( sm->p)) == 35 )
		goto st455;
	goto tr188;
st455:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof455;
case 455:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr594;
	goto tr188;
tr594:
#line 117 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st1096;
st1096:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1096;
case 1096:
#line 12118 "ext/dtext/dtext.cpp"
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto st1096;
	goto tr1488;
tr1466:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 562 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1097;
st1097:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1097;
case 1097:
#line 12132 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 82: goto tr1490;
		case 91: goto tr1361;
		case 114: goto tr1490;
		case 123: goto tr1362;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1360;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1360;
	} else
		goto tr1360;
	goto tr1338;
tr1490:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 562 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1098;
st1098:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1098;
case 1098:
#line 12158 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 85: goto tr1491;
		case 91: goto tr1361;
		case 117: goto tr1491;
		case 123: goto tr1362;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1360;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1360;
	} else
		goto tr1360;
	goto tr1338;
tr1491:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 562 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1099;
st1099:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1099;
case 1099:
#line 12184 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 77: goto tr1492;
		case 91: goto tr1361;
		case 109: goto tr1492;
		case 123: goto tr1362;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1360;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1360;
	} else
		goto tr1360;
	goto tr1338;
tr1492:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 562 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1100;
st1100:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1100;
case 1100:
#line 12210 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 32: goto st456;
		case 91: goto tr1361;
		case 123: goto tr1362;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1360;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1360;
	} else
		goto tr1360;
	goto tr1338;
st456:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof456;
case 456:
	if ( (*( sm->p)) == 35 )
		goto st457;
	goto tr188;
st457:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof457;
case 457:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr596;
	goto tr188;
tr596:
#line 117 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st1101;
st1101:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1101;
case 1101:
#line 12247 "ext/dtext/dtext.cpp"
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto st1101;
	goto tr1494;
tr1321:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 117 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
#line 562 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1102;
st1102:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1102;
case 1102:
#line 12263 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 69: goto tr1496;
		case 91: goto tr1361;
		case 101: goto tr1496;
		case 123: goto tr1362;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1360;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1360;
	} else
		goto tr1360;
	goto tr1338;
tr1496:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 562 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1103;
st1103:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1103;
case 1103:
#line 12289 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 76: goto tr1497;
		case 91: goto tr1361;
		case 108: goto tr1497;
		case 123: goto tr1362;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1360;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1360;
	} else
		goto tr1360;
	goto tr1338;
tr1497:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 562 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1104;
st1104:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1104;
case 1104:
#line 12315 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 66: goto tr1498;
		case 91: goto tr1361;
		case 98: goto tr1498;
		case 123: goto tr1362;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1360;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1360;
	} else
		goto tr1360;
	goto tr1338;
tr1498:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 562 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1105;
st1105:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1105;
case 1105:
#line 12341 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 79: goto tr1499;
		case 91: goto tr1361;
		case 111: goto tr1499;
		case 123: goto tr1362;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1360;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1360;
	} else
		goto tr1360;
	goto tr1338;
tr1499:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 562 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1106;
st1106:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1106;
case 1106:
#line 12367 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 79: goto tr1500;
		case 91: goto tr1361;
		case 111: goto tr1500;
		case 123: goto tr1362;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1360;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1360;
	} else
		goto tr1360;
	goto tr1338;
tr1500:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 562 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1107;
st1107:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1107;
case 1107:
#line 12393 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 82: goto tr1501;
		case 91: goto tr1361;
		case 114: goto tr1501;
		case 123: goto tr1362;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1360;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1360;
	} else
		goto tr1360;
	goto tr1338;
tr1501:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 562 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1108;
st1108:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1108;
case 1108:
#line 12419 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 85: goto tr1502;
		case 91: goto tr1361;
		case 117: goto tr1502;
		case 123: goto tr1362;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1360;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1360;
	} else
		goto tr1360;
	goto tr1338;
tr1502:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 562 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1109;
st1109:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1109;
case 1109:
#line 12445 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 32: goto st458;
		case 91: goto tr1361;
		case 123: goto tr1362;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1360;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1360;
	} else
		goto tr1360;
	goto tr1338;
st458:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof458;
case 458:
	if ( (*( sm->p)) == 35 )
		goto st459;
	goto tr188;
st459:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof459;
case 459:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr598;
	goto tr188;
tr598:
#line 117 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st1110;
st1110:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1110;
case 1110:
#line 12482 "ext/dtext/dtext.cpp"
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto st1110;
	goto tr1504;
tr1322:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 117 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
#line 562 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1111;
st1111:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1111;
case 1111:
#line 12498 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 84: goto tr1506;
		case 91: goto tr1361;
		case 116: goto tr1506;
		case 123: goto tr1362;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1360;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1360;
	} else
		goto tr1360;
	goto tr1338;
tr1506:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 562 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1112;
st1112:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1112;
case 1112:
#line 12524 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 84: goto tr1507;
		case 91: goto tr1361;
		case 116: goto tr1507;
		case 123: goto tr1362;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1360;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1360;
	} else
		goto tr1360;
	goto tr1338;
tr1507:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 562 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1113;
st1113:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1113;
case 1113:
#line 12550 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 80: goto tr1508;
		case 91: goto tr1361;
		case 112: goto tr1508;
		case 123: goto tr1362;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1360;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1360;
	} else
		goto tr1360;
	goto tr1338;
tr1508:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 562 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1114;
st1114:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1114;
case 1114:
#line 12576 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 58: goto st460;
		case 83: goto tr1510;
		case 91: goto tr1361;
		case 115: goto tr1510;
		case 123: goto tr1362;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1360;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1360;
	} else
		goto tr1360;
	goto tr1338;
st460:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof460;
case 460:
	if ( (*( sm->p)) == 47 )
		goto st461;
	goto tr188;
st461:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof461;
case 461:
	if ( (*( sm->p)) == 47 )
		goto st462;
	goto tr188;
st462:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof462;
case 462:
	switch( (*( sm->p)) ) {
		case 0: goto tr188;
		case 32: goto tr188;
	}
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr188;
	goto st1115;
st1115:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1115;
case 1115:
	switch( (*( sm->p)) ) {
		case 0: goto tr1511;
		case 32: goto tr1511;
	}
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr1511;
	goto st1115;
tr1510:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 562 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1116;
st1116:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1116;
case 1116:
#line 12639 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 58: goto st460;
		case 91: goto tr1361;
		case 123: goto tr1362;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1360;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1360;
	} else
		goto tr1360;
	goto tr1338;
tr1323:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 117 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
#line 562 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1117;
st1117:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1117;
case 1117:
#line 12666 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 77: goto tr1512;
		case 83: goto tr1513;
		case 91: goto tr1361;
		case 109: goto tr1512;
		case 115: goto tr1513;
		case 123: goto tr1362;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1360;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1360;
	} else
		goto tr1360;
	goto tr1338;
tr1512:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 562 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1118;
st1118:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1118;
case 1118:
#line 12694 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 80: goto tr1514;
		case 91: goto tr1361;
		case 112: goto tr1514;
		case 123: goto tr1362;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1360;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1360;
	} else
		goto tr1360;
	goto tr1338;
tr1514:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 562 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1119;
st1119:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1119;
case 1119:
#line 12720 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 76: goto tr1515;
		case 91: goto tr1361;
		case 108: goto tr1515;
		case 123: goto tr1362;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1360;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1360;
	} else
		goto tr1360;
	goto tr1338;
tr1515:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 562 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1120;
st1120:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1120;
case 1120:
#line 12746 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 73: goto tr1516;
		case 91: goto tr1361;
		case 105: goto tr1516;
		case 123: goto tr1362;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1360;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1360;
	} else
		goto tr1360;
	goto tr1338;
tr1516:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 562 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1121;
st1121:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1121;
case 1121:
#line 12772 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 67: goto tr1517;
		case 91: goto tr1361;
		case 99: goto tr1517;
		case 123: goto tr1362;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1360;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1360;
	} else
		goto tr1360;
	goto tr1338;
tr1517:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 562 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1122;
st1122:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1122;
case 1122:
#line 12798 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 65: goto tr1518;
		case 91: goto tr1361;
		case 97: goto tr1518;
		case 123: goto tr1362;
	}
	if ( (*( sm->p)) < 66 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1360;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 98 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1360;
	} else
		goto tr1360;
	goto tr1338;
tr1518:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 562 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1123;
st1123:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1123;
case 1123:
#line 12824 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 84: goto tr1519;
		case 91: goto tr1361;
		case 116: goto tr1519;
		case 123: goto tr1362;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1360;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1360;
	} else
		goto tr1360;
	goto tr1338;
tr1519:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 562 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1124;
st1124:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1124;
case 1124:
#line 12850 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 73: goto tr1520;
		case 91: goto tr1361;
		case 105: goto tr1520;
		case 123: goto tr1362;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1360;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1360;
	} else
		goto tr1360;
	goto tr1338;
tr1520:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 562 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1125;
st1125:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1125;
case 1125:
#line 12876 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 79: goto tr1521;
		case 91: goto tr1361;
		case 111: goto tr1521;
		case 123: goto tr1362;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1360;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1360;
	} else
		goto tr1360;
	goto tr1338;
tr1521:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 562 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1126;
st1126:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1126;
case 1126:
#line 12902 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 78: goto tr1522;
		case 91: goto tr1361;
		case 110: goto tr1522;
		case 123: goto tr1362;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1360;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1360;
	} else
		goto tr1360;
	goto tr1338;
tr1522:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 562 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1127;
st1127:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1127;
case 1127:
#line 12928 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 32: goto st463;
		case 91: goto tr1361;
		case 123: goto tr1362;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1360;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1360;
	} else
		goto tr1360;
	goto tr1338;
st463:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof463;
case 463:
	if ( (*( sm->p)) == 35 )
		goto st464;
	goto tr188;
st464:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof464;
case 464:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr603;
	goto tr188;
tr603:
#line 117 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st1128;
st1128:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1128;
case 1128:
#line 12965 "ext/dtext/dtext.cpp"
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto st1128;
	goto tr1524;
tr1513:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 562 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1129;
st1129:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1129;
case 1129:
#line 12979 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 83: goto tr1526;
		case 91: goto tr1361;
		case 115: goto tr1526;
		case 123: goto tr1362;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1360;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1360;
	} else
		goto tr1360;
	goto tr1338;
tr1526:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 562 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1130;
st1130:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1130;
case 1130:
#line 13005 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 85: goto tr1527;
		case 91: goto tr1361;
		case 117: goto tr1527;
		case 123: goto tr1362;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1360;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1360;
	} else
		goto tr1360;
	goto tr1338;
tr1527:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 562 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1131;
st1131:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1131;
case 1131:
#line 13031 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 69: goto tr1528;
		case 91: goto tr1361;
		case 101: goto tr1528;
		case 123: goto tr1362;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1360;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1360;
	} else
		goto tr1360;
	goto tr1338;
tr1528:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 562 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1132;
st1132:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1132;
case 1132:
#line 13057 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 32: goto st465;
		case 91: goto tr1361;
		case 123: goto tr1362;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1360;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1360;
	} else
		goto tr1360;
	goto tr1338;
st465:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof465;
case 465:
	if ( (*( sm->p)) == 35 )
		goto st466;
	goto tr188;
st466:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof466;
case 466:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr605;
	goto tr188;
tr605:
#line 117 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st1133;
st1133:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1133;
case 1133:
#line 13094 "ext/dtext/dtext.cpp"
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto st1133;
	goto tr1530;
tr1324:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 117 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
#line 562 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1134;
st1134:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1134;
case 1134:
#line 13110 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 79: goto tr1532;
		case 91: goto tr1361;
		case 111: goto tr1532;
		case 123: goto tr1362;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1360;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1360;
	} else
		goto tr1360;
	goto tr1338;
tr1532:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 562 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1135;
st1135:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1135;
case 1135:
#line 13136 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 68: goto tr1533;
		case 91: goto tr1361;
		case 100: goto tr1533;
		case 123: goto tr1362;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1360;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1360;
	} else
		goto tr1360;
	goto tr1338;
tr1533:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 562 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1136;
st1136:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1136;
case 1136:
#line 13162 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 32: goto st467;
		case 82: goto tr1535;
		case 91: goto tr1361;
		case 114: goto tr1535;
		case 123: goto tr1362;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1360;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1360;
	} else
		goto tr1360;
	goto tr1338;
st467:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof467;
case 467:
	switch( (*( sm->p)) ) {
		case 65: goto st468;
		case 97: goto st468;
	}
	goto tr188;
st468:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof468;
case 468:
	switch( (*( sm->p)) ) {
		case 67: goto st469;
		case 99: goto st469;
	}
	goto tr188;
st469:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof469;
case 469:
	switch( (*( sm->p)) ) {
		case 84: goto st470;
		case 116: goto st470;
	}
	goto tr188;
st470:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof470;
case 470:
	switch( (*( sm->p)) ) {
		case 73: goto st471;
		case 105: goto st471;
	}
	goto tr188;
st471:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof471;
case 471:
	switch( (*( sm->p)) ) {
		case 79: goto st472;
		case 111: goto st472;
	}
	goto tr188;
st472:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof472;
case 472:
	switch( (*( sm->p)) ) {
		case 78: goto st473;
		case 110: goto st473;
	}
	goto tr188;
st473:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof473;
case 473:
	if ( (*( sm->p)) == 32 )
		goto st474;
	goto tr188;
st474:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof474;
case 474:
	if ( (*( sm->p)) == 35 )
		goto st475;
	goto tr188;
st475:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof475;
case 475:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr614;
	goto tr188;
tr614:
#line 117 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st1137;
st1137:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1137;
case 1137:
#line 13262 "ext/dtext/dtext.cpp"
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto st1137;
	goto tr1536;
tr1535:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 562 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1138;
st1138:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1138;
case 1138:
#line 13276 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 69: goto tr1538;
		case 91: goto tr1361;
		case 101: goto tr1538;
		case 123: goto tr1362;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1360;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1360;
	} else
		goto tr1360;
	goto tr1338;
tr1538:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 562 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1139;
st1139:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1139;
case 1139:
#line 13302 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 80: goto tr1539;
		case 91: goto tr1361;
		case 112: goto tr1539;
		case 123: goto tr1362;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1360;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1360;
	} else
		goto tr1360;
	goto tr1338;
tr1539:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 562 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1140;
st1140:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1140;
case 1140:
#line 13328 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 79: goto tr1540;
		case 91: goto tr1361;
		case 111: goto tr1540;
		case 123: goto tr1362;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1360;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1360;
	} else
		goto tr1360;
	goto tr1338;
tr1540:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 562 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1141;
st1141:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1141;
case 1141:
#line 13354 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 82: goto tr1541;
		case 91: goto tr1361;
		case 114: goto tr1541;
		case 123: goto tr1362;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1360;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1360;
	} else
		goto tr1360;
	goto tr1338;
tr1541:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 562 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1142;
st1142:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1142;
case 1142:
#line 13380 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 84: goto tr1542;
		case 91: goto tr1361;
		case 116: goto tr1542;
		case 123: goto tr1362;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1360;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1360;
	} else
		goto tr1360;
	goto tr1338;
tr1542:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 562 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1143;
st1143:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1143;
case 1143:
#line 13406 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 32: goto st476;
		case 91: goto tr1361;
		case 123: goto tr1362;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1360;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1360;
	} else
		goto tr1360;
	goto tr1338;
st476:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof476;
case 476:
	if ( (*( sm->p)) == 35 )
		goto st477;
	goto tr188;
st477:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof477;
case 477:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr616;
	goto tr188;
tr616:
#line 117 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st1144;
st1144:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1144;
case 1144:
#line 13443 "ext/dtext/dtext.cpp"
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto st1144;
	goto tr1544;
tr1325:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 117 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
#line 562 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1145;
st1145:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1145;
case 1145:
#line 13459 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 73: goto tr1546;
		case 79: goto tr1547;
		case 91: goto tr1361;
		case 105: goto tr1546;
		case 111: goto tr1547;
		case 123: goto tr1362;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1360;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1360;
	} else
		goto tr1360;
	goto tr1338;
tr1546:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 562 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1146;
st1146:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1146;
case 1146:
#line 13487 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 74: goto tr1548;
		case 91: goto tr1361;
		case 106: goto tr1548;
		case 123: goto tr1362;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1360;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1360;
	} else
		goto tr1360;
	goto tr1338;
tr1548:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 562 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1147;
st1147:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1147;
case 1147:
#line 13513 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 73: goto tr1549;
		case 91: goto tr1361;
		case 105: goto tr1549;
		case 123: goto tr1362;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1360;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1360;
	} else
		goto tr1360;
	goto tr1338;
tr1549:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 562 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1148;
st1148:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1148;
case 1148:
#line 13539 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 69: goto tr1550;
		case 91: goto tr1361;
		case 101: goto tr1550;
		case 123: goto tr1362;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1360;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1360;
	} else
		goto tr1360;
	goto tr1338;
tr1550:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 562 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1149;
st1149:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1149;
case 1149:
#line 13565 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 32: goto st478;
		case 91: goto tr1361;
		case 123: goto tr1362;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1360;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1360;
	} else
		goto tr1360;
	goto tr1338;
st478:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof478;
case 478:
	if ( (*( sm->p)) == 35 )
		goto st479;
	goto tr188;
st479:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof479;
case 479:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr618;
	goto tr188;
tr618:
#line 117 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st1150;
st1150:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1150;
case 1150:
#line 13602 "ext/dtext/dtext.cpp"
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto st1150;
	goto tr1552;
tr1547:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 562 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1151;
st1151:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1151;
case 1151:
#line 13616 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 84: goto tr1554;
		case 91: goto tr1361;
		case 116: goto tr1554;
		case 123: goto tr1362;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1360;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1360;
	} else
		goto tr1360;
	goto tr1338;
tr1554:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 562 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1152;
st1152:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1152;
case 1152:
#line 13642 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 69: goto tr1555;
		case 91: goto tr1361;
		case 101: goto tr1555;
		case 123: goto tr1362;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1360;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1360;
	} else
		goto tr1360;
	goto tr1338;
tr1555:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 562 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1153;
st1153:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1153;
case 1153:
#line 13668 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 32: goto st480;
		case 91: goto tr1361;
		case 123: goto tr1362;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1360;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1360;
	} else
		goto tr1360;
	goto tr1338;
st480:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof480;
case 480:
	if ( (*( sm->p)) == 35 )
		goto st481;
	goto tr188;
st481:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof481;
case 481:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr620;
	goto tr188;
tr620:
#line 117 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st1154;
st1154:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1154;
case 1154:
#line 13705 "ext/dtext/dtext.cpp"
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto st1154;
	goto tr1557;
tr1326:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 117 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
#line 562 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1155;
st1155:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1155;
case 1155:
#line 13721 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 65: goto tr1559;
		case 73: goto tr1560;
		case 79: goto tr1561;
		case 85: goto tr1562;
		case 91: goto tr1361;
		case 97: goto tr1559;
		case 105: goto tr1560;
		case 111: goto tr1561;
		case 117: goto tr1562;
		case 123: goto tr1362;
	}
	if ( (*( sm->p)) < 66 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1360;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 98 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1360;
	} else
		goto tr1360;
	goto tr1338;
tr1559:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 562 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1156;
st1156:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1156;
case 1156:
#line 13753 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 87: goto tr1563;
		case 91: goto tr1361;
		case 119: goto tr1563;
		case 123: goto tr1362;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1360;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1360;
	} else
		goto tr1360;
	goto tr1338;
tr1563:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 562 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1157;
st1157:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1157;
case 1157:
#line 13779 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 79: goto tr1564;
		case 91: goto tr1361;
		case 111: goto tr1564;
		case 123: goto tr1362;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1360;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1360;
	} else
		goto tr1360;
	goto tr1338;
tr1564:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 562 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1158;
st1158:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1158;
case 1158:
#line 13805 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 79: goto tr1565;
		case 91: goto tr1361;
		case 111: goto tr1565;
		case 123: goto tr1362;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1360;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1360;
	} else
		goto tr1360;
	goto tr1338;
tr1565:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 562 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1159;
st1159:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1159;
case 1159:
#line 13831 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 32: goto st482;
		case 91: goto tr1361;
		case 123: goto tr1362;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1360;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1360;
	} else
		goto tr1360;
	goto tr1338;
st482:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof482;
case 482:
	if ( (*( sm->p)) == 35 )
		goto st483;
	goto tr188;
st483:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof483;
case 483:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr622;
	goto tr188;
tr622:
#line 117 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st1160;
st1160:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1160;
case 1160:
#line 13868 "ext/dtext/dtext.cpp"
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto st1160;
	goto tr1567;
tr1560:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 562 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1161;
st1161:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1161;
case 1161:
#line 13882 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 88: goto tr1569;
		case 91: goto tr1361;
		case 120: goto tr1569;
		case 123: goto tr1362;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1360;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1360;
	} else
		goto tr1360;
	goto tr1338;
tr1569:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 562 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1162;
st1162:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1162;
case 1162:
#line 13908 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 73: goto tr1570;
		case 91: goto tr1361;
		case 105: goto tr1570;
		case 123: goto tr1362;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1360;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1360;
	} else
		goto tr1360;
	goto tr1338;
tr1570:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 562 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1163;
st1163:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1163;
case 1163:
#line 13934 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 86: goto tr1571;
		case 91: goto tr1361;
		case 118: goto tr1571;
		case 123: goto tr1362;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1360;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1360;
	} else
		goto tr1360;
	goto tr1338;
tr1571:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 562 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1164;
st1164:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1164;
case 1164:
#line 13960 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 32: goto st484;
		case 91: goto tr1361;
		case 123: goto tr1362;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1360;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1360;
	} else
		goto tr1360;
	goto tr1338;
st484:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof484;
case 484:
	if ( (*( sm->p)) == 35 )
		goto st485;
	goto tr188;
st485:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof485;
case 485:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr624;
	goto tr188;
tr1575:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
	goto st1165;
tr624:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 117 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st1165;
st1165:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1165;
case 1165:
#line 14003 "ext/dtext/dtext.cpp"
	if ( (*( sm->p)) == 47 )
		goto tr1574;
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr1575;
	goto tr1573;
tr1574:
#line 118 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
	goto st486;
st486:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof486;
case 486:
#line 14017 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 80: goto st487;
		case 112: goto st487;
	}
	goto tr625;
st487:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof487;
case 487:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr627;
	goto tr625;
tr627:
#line 119 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st1166;
st1166:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1166;
case 1166:
#line 14038 "ext/dtext/dtext.cpp"
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto st1166;
	goto tr1576;
tr1561:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 562 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1167;
st1167:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1167;
case 1167:
#line 14052 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 79: goto tr1578;
		case 83: goto tr1579;
		case 91: goto tr1361;
		case 111: goto tr1578;
		case 115: goto tr1579;
		case 123: goto tr1362;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1360;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1360;
	} else
		goto tr1360;
	goto tr1338;
tr1578:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 562 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1168;
st1168:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1168;
case 1168:
#line 14080 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 76: goto tr1580;
		case 91: goto tr1361;
		case 108: goto tr1580;
		case 123: goto tr1362;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1360;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1360;
	} else
		goto tr1360;
	goto tr1338;
tr1580:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 562 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1169;
st1169:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1169;
case 1169:
#line 14106 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 32: goto st488;
		case 91: goto tr1361;
		case 123: goto tr1362;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1360;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1360;
	} else
		goto tr1360;
	goto tr1338;
st488:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof488;
case 488:
	if ( (*( sm->p)) == 35 )
		goto st489;
	goto tr188;
st489:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof489;
case 489:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr629;
	goto tr188;
tr629:
#line 117 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st1170;
st1170:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1170;
case 1170:
#line 14143 "ext/dtext/dtext.cpp"
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto st1170;
	goto tr1582;
tr1579:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 562 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1171;
st1171:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1171;
case 1171:
#line 14157 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 84: goto tr1584;
		case 91: goto tr1361;
		case 116: goto tr1584;
		case 123: goto tr1362;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1360;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1360;
	} else
		goto tr1360;
	goto tr1338;
tr1584:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 562 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1172;
st1172:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1172;
case 1172:
#line 14183 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 32: goto st490;
		case 91: goto tr1361;
		case 123: goto tr1362;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1360;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1360;
	} else
		goto tr1360;
	goto tr1338;
st490:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof490;
case 490:
	if ( (*( sm->p)) == 35 )
		goto st491;
	goto tr188;
st491:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof491;
case 491:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr631;
	goto tr188;
tr631:
#line 117 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st1173;
st1173:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1173;
case 1173:
#line 14220 "ext/dtext/dtext.cpp"
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto st1173;
	goto tr1586;
tr1562:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 562 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1174;
st1174:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1174;
case 1174:
#line 14234 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 76: goto tr1588;
		case 91: goto tr1361;
		case 108: goto tr1588;
		case 123: goto tr1362;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1360;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1360;
	} else
		goto tr1360;
	goto tr1338;
tr1588:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 562 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1175;
st1175:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1175;
case 1175:
#line 14260 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 76: goto tr1589;
		case 91: goto tr1361;
		case 108: goto tr1589;
		case 123: goto tr1362;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1360;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1360;
	} else
		goto tr1360;
	goto tr1338;
tr1589:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 562 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1176;
st1176:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1176;
case 1176:
#line 14286 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 32: goto st492;
		case 91: goto tr1361;
		case 123: goto tr1362;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1360;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1360;
	} else
		goto tr1360;
	goto tr1338;
st492:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof492;
case 492:
	if ( (*( sm->p)) == 35 )
		goto st493;
	goto tr188;
st493:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof493;
case 493:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr633;
	goto tr188;
tr633:
#line 117 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st1177;
st1177:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1177;
case 1177:
#line 14323 "ext/dtext/dtext.cpp"
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto st1177;
	goto tr1591;
tr1327:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 117 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
#line 562 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1178;
st1178:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1178;
case 1178:
#line 14339 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 65: goto tr1593;
		case 69: goto tr1594;
		case 91: goto tr1361;
		case 97: goto tr1593;
		case 101: goto tr1594;
		case 123: goto tr1362;
	}
	if ( (*( sm->p)) < 66 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1360;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 98 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1360;
	} else
		goto tr1360;
	goto tr1338;
tr1593:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 562 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1179;
st1179:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1179;
case 1179:
#line 14367 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 78: goto tr1595;
		case 91: goto tr1361;
		case 110: goto tr1595;
		case 123: goto tr1362;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1360;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1360;
	} else
		goto tr1360;
	goto tr1338;
tr1595:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 562 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1180;
st1180:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1180;
case 1180:
#line 14393 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 75: goto tr1596;
		case 91: goto tr1361;
		case 107: goto tr1596;
		case 123: goto tr1362;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1360;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1360;
	} else
		goto tr1360;
	goto tr1338;
tr1596:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 562 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1181;
st1181:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1181;
case 1181:
#line 14419 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 65: goto tr1597;
		case 91: goto tr1361;
		case 97: goto tr1597;
		case 123: goto tr1362;
	}
	if ( (*( sm->p)) < 66 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1360;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 98 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1360;
	} else
		goto tr1360;
	goto tr1338;
tr1597:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 562 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1182;
st1182:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1182;
case 1182:
#line 14445 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 75: goto tr1598;
		case 91: goto tr1361;
		case 107: goto tr1598;
		case 123: goto tr1362;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1360;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1360;
	} else
		goto tr1360;
	goto tr1338;
tr1598:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 562 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1183;
st1183:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1183;
case 1183:
#line 14471 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 85: goto tr1599;
		case 91: goto tr1361;
		case 117: goto tr1599;
		case 123: goto tr1362;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1360;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1360;
	} else
		goto tr1360;
	goto tr1338;
tr1599:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 562 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1184;
st1184:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1184;
case 1184:
#line 14497 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 32: goto st494;
		case 91: goto tr1361;
		case 123: goto tr1362;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1360;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1360;
	} else
		goto tr1360;
	goto tr1338;
st494:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof494;
case 494:
	if ( (*( sm->p)) == 35 )
		goto st495;
	goto tr188;
st495:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof495;
case 495:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr635;
	goto tr188;
tr635:
#line 117 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st1185;
st1185:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1185;
case 1185:
#line 14534 "ext/dtext/dtext.cpp"
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto st1185;
	goto tr1601;
tr1594:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 562 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1186;
st1186:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1186;
case 1186:
#line 14548 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 73: goto tr1603;
		case 91: goto tr1361;
		case 105: goto tr1603;
		case 123: goto tr1362;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1360;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1360;
	} else
		goto tr1360;
	goto tr1338;
tr1603:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 562 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1187;
st1187:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1187;
case 1187:
#line 14574 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 71: goto tr1604;
		case 91: goto tr1361;
		case 103: goto tr1604;
		case 123: goto tr1362;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1360;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1360;
	} else
		goto tr1360;
	goto tr1338;
tr1604:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 562 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1188;
st1188:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1188;
case 1188:
#line 14600 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 65: goto tr1605;
		case 91: goto tr1361;
		case 97: goto tr1605;
		case 123: goto tr1362;
	}
	if ( (*( sm->p)) < 66 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1360;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 98 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1360;
	} else
		goto tr1360;
	goto tr1338;
tr1605:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 562 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1189;
st1189:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1189;
case 1189:
#line 14626 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 32: goto st496;
		case 91: goto tr1361;
		case 123: goto tr1362;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1360;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1360;
	} else
		goto tr1360;
	goto tr1338;
st496:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof496;
case 496:
	if ( (*( sm->p)) == 35 )
		goto st497;
	goto tr188;
st497:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof497;
case 497:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr637;
	goto tr188;
tr637:
#line 117 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st1190;
st1190:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1190;
case 1190:
#line 14663 "ext/dtext/dtext.cpp"
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto st1190;
	goto tr1607;
tr1328:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 117 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
#line 562 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1191;
st1191:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1191;
case 1191:
#line 14679 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 79: goto tr1609;
		case 87: goto tr1610;
		case 91: goto tr1361;
		case 111: goto tr1609;
		case 119: goto tr1610;
		case 123: goto tr1362;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1360;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1360;
	} else
		goto tr1360;
	goto tr1338;
tr1609:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 562 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1192;
st1192:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1192;
case 1192:
#line 14707 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 80: goto tr1611;
		case 91: goto tr1361;
		case 112: goto tr1611;
		case 123: goto tr1362;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1360;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1360;
	} else
		goto tr1360;
	goto tr1338;
tr1611:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 562 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1193;
st1193:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1193;
case 1193:
#line 14733 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 73: goto tr1612;
		case 91: goto tr1361;
		case 105: goto tr1612;
		case 123: goto tr1362;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1360;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1360;
	} else
		goto tr1360;
	goto tr1338;
tr1612:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 562 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1194;
st1194:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1194;
case 1194:
#line 14759 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 67: goto tr1613;
		case 91: goto tr1361;
		case 99: goto tr1613;
		case 123: goto tr1362;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1360;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1360;
	} else
		goto tr1360;
	goto tr1338;
tr1613:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 562 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1195;
st1195:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1195;
case 1195:
#line 14785 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 32: goto st498;
		case 91: goto tr1361;
		case 123: goto tr1362;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1360;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1360;
	} else
		goto tr1360;
	goto tr1338;
st498:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof498;
case 498:
	if ( (*( sm->p)) == 35 )
		goto st499;
	goto tr188;
st499:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof499;
case 499:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr639;
	goto tr188;
tr1617:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
	goto st1196;
tr639:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 117 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st1196;
st1196:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1196;
case 1196:
#line 14828 "ext/dtext/dtext.cpp"
	if ( (*( sm->p)) == 47 )
		goto tr1616;
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr1617;
	goto tr1615;
tr1616:
#line 118 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
	goto st500;
st500:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof500;
case 500:
#line 14842 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 80: goto st501;
		case 112: goto st501;
	}
	goto tr640;
st501:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof501;
case 501:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr642;
	goto tr640;
tr642:
#line 119 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st1197;
st1197:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1197;
case 1197:
#line 14863 "ext/dtext/dtext.cpp"
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto st1197;
	goto tr1618;
tr1610:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 562 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1198;
st1198:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1198;
case 1198:
#line 14877 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 73: goto tr1620;
		case 91: goto tr1361;
		case 105: goto tr1620;
		case 123: goto tr1362;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1360;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1360;
	} else
		goto tr1360;
	goto tr1338;
tr1620:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 562 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1199;
st1199:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1199;
case 1199:
#line 14903 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 84: goto tr1621;
		case 91: goto tr1361;
		case 116: goto tr1621;
		case 123: goto tr1362;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1360;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1360;
	} else
		goto tr1360;
	goto tr1338;
tr1621:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 562 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1200;
st1200:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1200;
case 1200:
#line 14929 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 84: goto tr1622;
		case 91: goto tr1361;
		case 116: goto tr1622;
		case 123: goto tr1362;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1360;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1360;
	} else
		goto tr1360;
	goto tr1338;
tr1622:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 562 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1201;
st1201:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1201;
case 1201:
#line 14955 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 69: goto tr1623;
		case 91: goto tr1361;
		case 101: goto tr1623;
		case 123: goto tr1362;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1360;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1360;
	} else
		goto tr1360;
	goto tr1338;
tr1623:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 562 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1202;
st1202:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1202;
case 1202:
#line 14981 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 82: goto tr1624;
		case 91: goto tr1361;
		case 114: goto tr1624;
		case 123: goto tr1362;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1360;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1360;
	} else
		goto tr1360;
	goto tr1338;
tr1624:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 562 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1203;
st1203:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1203;
case 1203:
#line 15007 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 32: goto st502;
		case 91: goto tr1361;
		case 123: goto tr1362;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1360;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1360;
	} else
		goto tr1360;
	goto tr1338;
st502:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof502;
case 502:
	if ( (*( sm->p)) == 35 )
		goto st503;
	goto tr188;
st503:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof503;
case 503:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr644;
	goto tr188;
tr644:
#line 117 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st1204;
st1204:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1204;
case 1204:
#line 15044 "ext/dtext/dtext.cpp"
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto st1204;
	goto tr1626;
tr1329:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 117 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
#line 562 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1205;
st1205:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1205;
case 1205:
#line 15060 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 83: goto tr1628;
		case 91: goto tr1361;
		case 115: goto tr1628;
		case 123: goto tr1362;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1360;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1360;
	} else
		goto tr1360;
	goto tr1338;
tr1628:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 562 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1206;
st1206:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1206;
case 1206:
#line 15086 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 69: goto tr1629;
		case 91: goto tr1361;
		case 101: goto tr1629;
		case 123: goto tr1362;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1360;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1360;
	} else
		goto tr1360;
	goto tr1338;
tr1629:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 562 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1207;
st1207:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1207;
case 1207:
#line 15112 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 82: goto tr1630;
		case 91: goto tr1361;
		case 114: goto tr1630;
		case 123: goto tr1362;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1360;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1360;
	} else
		goto tr1360;
	goto tr1338;
tr1630:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 562 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1208;
st1208:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1208;
case 1208:
#line 15138 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 32: goto st504;
		case 91: goto tr1361;
		case 123: goto tr1362;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1360;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1360;
	} else
		goto tr1360;
	goto tr1338;
st504:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof504;
case 504:
	if ( (*( sm->p)) == 35 )
		goto st505;
	goto tr188;
st505:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof505;
case 505:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr646;
	goto tr188;
tr646:
#line 117 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st1209;
st1209:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1209;
case 1209:
#line 15175 "ext/dtext/dtext.cpp"
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto st1209;
	goto tr1632;
tr1330:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 117 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
#line 562 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1210;
st1210:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1210;
case 1210:
#line 15191 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 73: goto tr1634;
		case 91: goto tr1361;
		case 105: goto tr1634;
		case 123: goto tr1362;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1360;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1360;
	} else
		goto tr1360;
	goto tr1338;
tr1634:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 562 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1211;
st1211:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1211;
case 1211:
#line 15217 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 75: goto tr1635;
		case 91: goto tr1361;
		case 107: goto tr1635;
		case 123: goto tr1362;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1360;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1360;
	} else
		goto tr1360;
	goto tr1338;
tr1635:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 562 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1212;
st1212:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1212;
case 1212:
#line 15243 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 73: goto tr1636;
		case 91: goto tr1361;
		case 105: goto tr1636;
		case 123: goto tr1362;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1360;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1360;
	} else
		goto tr1360;
	goto tr1338;
tr1636:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 562 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1213;
st1213:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1213;
case 1213:
#line 15269 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 32: goto st506;
		case 91: goto tr1361;
		case 123: goto tr1362;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1360;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1360;
	} else
		goto tr1360;
	goto tr1338;
st506:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof506;
case 506:
	if ( (*( sm->p)) == 35 )
		goto st507;
	goto tr188;
st507:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof507;
case 507:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr648;
	goto tr188;
tr648:
#line 117 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st1214;
st1214:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1214;
case 1214:
#line 15306 "ext/dtext/dtext.cpp"
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto st1214;
	goto tr1638;
tr1331:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 117 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
#line 562 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1215;
st1215:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1215;
case 1215:
#line 15322 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 65: goto tr1640;
		case 91: goto tr1361;
		case 97: goto tr1640;
		case 123: goto tr1362;
	}
	if ( (*( sm->p)) < 66 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1360;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 98 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1360;
	} else
		goto tr1360;
	goto tr1338;
tr1640:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 562 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1216;
st1216:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1216;
case 1216:
#line 15348 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 78: goto tr1641;
		case 91: goto tr1361;
		case 110: goto tr1641;
		case 123: goto tr1362;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1360;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1360;
	} else
		goto tr1360;
	goto tr1338;
tr1641:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 562 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1217;
st1217:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1217;
case 1217:
#line 15374 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 68: goto tr1642;
		case 91: goto tr1361;
		case 100: goto tr1642;
		case 123: goto tr1362;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1360;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1360;
	} else
		goto tr1360;
	goto tr1338;
tr1642:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 562 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1218;
st1218:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1218;
case 1218:
#line 15400 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 69: goto tr1643;
		case 91: goto tr1361;
		case 101: goto tr1643;
		case 123: goto tr1362;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1360;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1360;
	} else
		goto tr1360;
	goto tr1338;
tr1643:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 562 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1219;
st1219:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1219;
case 1219:
#line 15426 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 82: goto tr1644;
		case 91: goto tr1361;
		case 114: goto tr1644;
		case 123: goto tr1362;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1360;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1360;
	} else
		goto tr1360;
	goto tr1338;
tr1644:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 562 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1220;
st1220:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1220;
case 1220:
#line 15452 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 69: goto tr1645;
		case 91: goto tr1361;
		case 101: goto tr1645;
		case 123: goto tr1362;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1360;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1360;
	} else
		goto tr1360;
	goto tr1338;
tr1645:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 562 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1221;
st1221:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1221;
case 1221:
#line 15478 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 32: goto st508;
		case 91: goto tr1361;
		case 123: goto tr1362;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1360;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1360;
	} else
		goto tr1360;
	goto tr1338;
st508:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof508;
case 508:
	if ( (*( sm->p)) == 35 )
		goto st509;
	goto tr188;
st509:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof509;
case 509:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr650;
	goto tr188;
tr650:
#line 117 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st1222;
st1222:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1222;
case 1222:
#line 15515 "ext/dtext/dtext.cpp"
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto st1222;
	goto tr1647;
tr1332:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 117 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
#line 118 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
#line 566 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 91;}
	goto st1223;
st1223:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1223;
case 1223:
#line 15533 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 47: goto st510;
		case 66: goto st515;
		case 67: goto st516;
		case 69: goto st527;
		case 72: goto tr1653;
		case 73: goto st548;
		case 78: goto st549;
		case 81: goto st558;
		case 83: goto st563;
		case 84: goto st571;
		case 85: goto st573;
		case 91: goto st328;
		case 98: goto st515;
		case 99: goto st516;
		case 101: goto st527;
		case 104: goto tr1653;
		case 105: goto st548;
		case 110: goto st549;
		case 113: goto st558;
		case 115: goto st563;
		case 116: goto st571;
		case 117: goto st573;
	}
	goto tr1337;
st510:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof510;
case 510:
	switch( (*( sm->p)) ) {
		case 66: goto st511;
		case 69: goto st265;
		case 73: goto st512;
		case 81: goto st221;
		case 83: goto st513;
		case 84: goto st208;
		case 85: goto st514;
		case 98: goto st511;
		case 101: goto st265;
		case 105: goto st512;
		case 113: goto st221;
		case 115: goto st513;
		case 116: goto st208;
		case 117: goto st514;
	}
	goto tr193;
st511:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof511;
case 511:
	if ( (*( sm->p)) == 93 )
		goto tr655;
	goto tr193;
st512:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof512;
case 512:
	if ( (*( sm->p)) == 93 )
		goto tr656;
	goto tr193;
st513:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof513;
case 513:
	switch( (*( sm->p)) ) {
		case 80: goto st272;
		case 93: goto tr657;
		case 112: goto st272;
	}
	goto tr193;
st514:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof514;
case 514:
	if ( (*( sm->p)) == 93 )
		goto tr658;
	goto tr193;
st515:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof515;
case 515:
	if ( (*( sm->p)) == 93 )
		goto tr659;
	goto tr193;
st516:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof516;
case 516:
	switch( (*( sm->p)) ) {
		case 79: goto st517;
		case 111: goto st517;
	}
	goto tr193;
st517:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof517;
case 517:
	switch( (*( sm->p)) ) {
		case 68: goto st518;
		case 100: goto st518;
	}
	goto tr193;
st518:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof518;
case 518:
	switch( (*( sm->p)) ) {
		case 69: goto st519;
		case 101: goto st519;
	}
	goto tr193;
st519:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof519;
case 519:
	switch( (*( sm->p)) ) {
		case 9: goto st520;
		case 32: goto st520;
		case 61: goto st521;
		case 93: goto tr665;
	}
	goto tr193;
st520:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof520;
case 520:
	switch( (*( sm->p)) ) {
		case 9: goto st520;
		case 32: goto st520;
		case 61: goto st521;
	}
	goto tr193;
st521:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof521;
case 521:
	switch( (*( sm->p)) ) {
		case 9: goto st521;
		case 32: goto st521;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr666;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr666;
	} else
		goto tr666;
	goto tr193;
tr666:
#line 117 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st522;
st522:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof522;
case 522:
#line 15691 "ext/dtext/dtext.cpp"
	if ( (*( sm->p)) == 93 )
		goto tr668;
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st522;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st522;
	} else
		goto st522;
	goto tr193;
tr668:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 118 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
	goto st1224;
st1224:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1224;
case 1224:
#line 15713 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr670;
		case 9: goto st523;
		case 10: goto tr670;
		case 13: goto st524;
		case 32: goto st523;
	}
	goto tr1660;
st523:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof523;
case 523:
	switch( (*( sm->p)) ) {
		case 0: goto tr670;
		case 9: goto st523;
		case 10: goto tr670;
		case 13: goto st524;
		case 32: goto st523;
	}
	goto tr669;
st524:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof524;
case 524:
	if ( (*( sm->p)) == 10 )
		goto tr670;
	goto tr669;
tr665:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
	goto st1225;
st1225:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1225;
case 1225:
#line 15749 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr674;
		case 9: goto st525;
		case 10: goto tr674;
		case 13: goto st526;
		case 32: goto st525;
	}
	goto tr1661;
st525:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof525;
case 525:
	switch( (*( sm->p)) ) {
		case 0: goto tr674;
		case 9: goto st525;
		case 10: goto tr674;
		case 13: goto st526;
		case 32: goto st525;
	}
	goto tr673;
st526:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof526;
case 526:
	if ( (*( sm->p)) == 10 )
		goto tr674;
	goto tr673;
st527:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof527;
case 527:
	switch( (*( sm->p)) ) {
		case 88: goto st528;
		case 120: goto st528;
	}
	goto tr193;
st528:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof528;
case 528:
	switch( (*( sm->p)) ) {
		case 80: goto st529;
		case 112: goto st529;
	}
	goto tr193;
st529:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof529;
case 529:
	switch( (*( sm->p)) ) {
		case 65: goto st530;
		case 97: goto st530;
	}
	goto tr193;
st530:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof530;
case 530:
	switch( (*( sm->p)) ) {
		case 78: goto st531;
		case 110: goto st531;
	}
	goto tr193;
st531:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof531;
case 531:
	switch( (*( sm->p)) ) {
		case 68: goto st532;
		case 100: goto st532;
	}
	goto tr193;
st532:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof532;
case 532:
	switch( (*( sm->p)) ) {
		case 9: goto st533;
		case 32: goto st533;
		case 61: goto st535;
		case 93: goto tr684;
	}
	goto tr193;
tr686:
#line 117 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st533;
st533:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof533;
case 533:
#line 15841 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto tr686;
		case 10: goto tr193;
		case 13: goto tr193;
		case 32: goto tr686;
		case 61: goto tr687;
		case 93: goto tr688;
	}
	goto tr685;
tr685:
#line 117 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st534;
st534:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof534;
case 534:
#line 15859 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 10: goto tr193;
		case 13: goto tr193;
		case 93: goto tr690;
	}
	goto st534;
tr687:
#line 117 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st535;
st535:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof535;
case 535:
#line 15874 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto tr687;
		case 10: goto tr193;
		case 13: goto tr193;
		case 32: goto tr687;
		case 93: goto tr688;
	}
	goto tr685;
tr1653:
#line 117 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st536;
st536:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof536;
case 536:
#line 15891 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 84: goto st537;
		case 116: goto st537;
	}
	goto tr193;
st537:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof537;
case 537:
	switch( (*( sm->p)) ) {
		case 84: goto st538;
		case 116: goto st538;
	}
	goto tr193;
st538:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof538;
case 538:
	switch( (*( sm->p)) ) {
		case 80: goto st539;
		case 112: goto st539;
	}
	goto tr193;
st539:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof539;
case 539:
	switch( (*( sm->p)) ) {
		case 58: goto st540;
		case 83: goto st547;
		case 115: goto st547;
	}
	goto tr193;
st540:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof540;
case 540:
	if ( (*( sm->p)) == 47 )
		goto st541;
	goto tr193;
st541:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof541;
case 541:
	if ( (*( sm->p)) == 47 )
		goto st542;
	goto tr193;
st542:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof542;
case 542:
	switch( (*( sm->p)) ) {
		case 0: goto tr193;
		case 32: goto tr193;
	}
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr193;
	goto st543;
st543:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof543;
case 543:
	switch( (*( sm->p)) ) {
		case 0: goto tr193;
		case 32: goto tr193;
		case 93: goto tr699;
	}
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr193;
	goto st543;
tr699:
#line 118 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
	goto st544;
st544:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof544;
case 544:
#line 15970 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr193;
		case 32: goto tr193;
		case 40: goto st545;
		case 93: goto tr699;
	}
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr193;
	goto st543;
st545:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof545;
case 545:
	switch( (*( sm->p)) ) {
		case 10: goto tr193;
		case 13: goto tr193;
	}
	goto tr701;
tr701:
#line 119 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st546;
st546:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof546;
case 546:
#line 15997 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 10: goto tr193;
		case 13: goto tr193;
		case 41: goto tr703;
	}
	goto st546;
st547:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof547;
case 547:
	if ( (*( sm->p)) == 58 )
		goto st540;
	goto tr193;
st548:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof548;
case 548:
	if ( (*( sm->p)) == 93 )
		goto tr704;
	goto tr193;
st549:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof549;
case 549:
	switch( (*( sm->p)) ) {
		case 79: goto st550;
		case 111: goto st550;
	}
	goto tr193;
st550:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof550;
case 550:
	switch( (*( sm->p)) ) {
		case 68: goto st551;
		case 100: goto st551;
	}
	goto tr193;
st551:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof551;
case 551:
	switch( (*( sm->p)) ) {
		case 84: goto st552;
		case 116: goto st552;
	}
	goto tr193;
st552:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof552;
case 552:
	switch( (*( sm->p)) ) {
		case 69: goto st553;
		case 101: goto st553;
	}
	goto tr193;
st553:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof553;
case 553:
	switch( (*( sm->p)) ) {
		case 88: goto st554;
		case 120: goto st554;
	}
	goto tr193;
st554:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof554;
case 554:
	switch( (*( sm->p)) ) {
		case 84: goto st555;
		case 116: goto st555;
	}
	goto tr193;
st555:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof555;
case 555:
	if ( (*( sm->p)) == 93 )
		goto tr711;
	goto tr193;
tr711:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
	goto st1226;
st1226:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1226;
case 1226:
#line 16087 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr713;
		case 9: goto st556;
		case 10: goto tr713;
		case 13: goto st557;
		case 32: goto st556;
	}
	goto tr1662;
st556:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof556;
case 556:
	switch( (*( sm->p)) ) {
		case 0: goto tr713;
		case 9: goto st556;
		case 10: goto tr713;
		case 13: goto st557;
		case 32: goto st556;
	}
	goto tr712;
st557:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof557;
case 557:
	if ( (*( sm->p)) == 10 )
		goto tr713;
	goto tr712;
st558:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof558;
case 558:
	switch( (*( sm->p)) ) {
		case 85: goto st559;
		case 117: goto st559;
	}
	goto tr193;
st559:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof559;
case 559:
	switch( (*( sm->p)) ) {
		case 79: goto st560;
		case 111: goto st560;
	}
	goto tr193;
st560:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof560;
case 560:
	switch( (*( sm->p)) ) {
		case 84: goto st561;
		case 116: goto st561;
	}
	goto tr193;
st561:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof561;
case 561:
	switch( (*( sm->p)) ) {
		case 69: goto st562;
		case 101: goto st562;
	}
	goto tr193;
st562:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof562;
case 562:
	if ( (*( sm->p)) == 93 )
		goto tr720;
	goto tr193;
st563:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof563;
case 563:
	switch( (*( sm->p)) ) {
		case 80: goto st564;
		case 93: goto tr722;
		case 112: goto st564;
	}
	goto tr193;
st564:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof564;
case 564:
	switch( (*( sm->p)) ) {
		case 79: goto st565;
		case 111: goto st565;
	}
	goto tr193;
st565:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof565;
case 565:
	switch( (*( sm->p)) ) {
		case 73: goto st566;
		case 105: goto st566;
	}
	goto tr193;
st566:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof566;
case 566:
	switch( (*( sm->p)) ) {
		case 76: goto st567;
		case 108: goto st567;
	}
	goto tr193;
st567:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof567;
case 567:
	switch( (*( sm->p)) ) {
		case 69: goto st568;
		case 101: goto st568;
	}
	goto tr193;
st568:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof568;
case 568:
	switch( (*( sm->p)) ) {
		case 82: goto st569;
		case 114: goto st569;
	}
	goto tr193;
st569:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof569;
case 569:
	switch( (*( sm->p)) ) {
		case 83: goto st570;
		case 93: goto tr729;
		case 115: goto st570;
	}
	goto tr193;
st570:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof570;
case 570:
	if ( (*( sm->p)) == 93 )
		goto tr729;
	goto tr193;
st571:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof571;
case 571:
	switch( (*( sm->p)) ) {
		case 78: goto st572;
		case 110: goto st572;
	}
	goto tr193;
st572:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof572;
case 572:
	if ( (*( sm->p)) == 93 )
		goto tr731;
	goto tr193;
st573:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof573;
case 573:
	if ( (*( sm->p)) == 93 )
		goto tr732;
	goto tr193;
tr1333:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 117 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
#line 118 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
#line 566 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 91;}
	goto st1227;
st1227:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1227;
case 1227:
#line 16267 "ext/dtext/dtext.cpp"
	if ( (*( sm->p)) == 123 )
		goto st381;
	goto tr1337;
tr1334:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 566 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 91;}
	goto st1228;
st1228:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1228;
case 1228:
#line 16281 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 47: goto st574;
		case 65: goto st585;
		case 66: goto st608;
		case 67: goto st618;
		case 69: goto st625;
		case 72: goto tr1668;
		case 73: goto st626;
		case 78: goto st644;
		case 81: goto st613;
		case 83: goto st651;
		case 84: goto st664;
		case 85: goto st666;
		case 97: goto st585;
		case 98: goto st608;
		case 99: goto st618;
		case 101: goto st625;
		case 104: goto tr1668;
		case 105: goto st626;
		case 110: goto st644;
		case 113: goto st613;
		case 115: goto st651;
		case 116: goto st664;
		case 117: goto st666;
	}
	goto tr1337;
st574:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof574;
case 574:
	switch( (*( sm->p)) ) {
		case 66: goto st575;
		case 69: goto st576;
		case 73: goto st577;
		case 81: goto st232;
		case 83: goto st578;
		case 84: goto st202;
		case 85: goto st584;
		case 98: goto st575;
		case 101: goto st576;
		case 105: goto st577;
		case 113: goto st232;
		case 115: goto st578;
		case 116: goto st202;
		case 117: goto st584;
	}
	goto tr193;
st575:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof575;
case 575:
	switch( (*( sm->p)) ) {
		case 62: goto tr655;
		case 76: goto st217;
		case 108: goto st217;
	}
	goto tr193;
st576:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof576;
case 576:
	switch( (*( sm->p)) ) {
		case 77: goto st577;
		case 88: goto st227;
		case 109: goto st577;
		case 120: goto st227;
	}
	goto tr193;
st577:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof577;
case 577:
	if ( (*( sm->p)) == 62 )
		goto tr656;
	goto tr193;
st578:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof578;
case 578:
	switch( (*( sm->p)) ) {
		case 62: goto tr657;
		case 80: goto st238;
		case 84: goto st579;
		case 112: goto st238;
		case 116: goto st579;
	}
	goto tr193;
st579:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof579;
case 579:
	switch( (*( sm->p)) ) {
		case 82: goto st580;
		case 114: goto st580;
	}
	goto tr193;
st580:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof580;
case 580:
	switch( (*( sm->p)) ) {
		case 79: goto st581;
		case 111: goto st581;
	}
	goto tr193;
st581:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof581;
case 581:
	switch( (*( sm->p)) ) {
		case 78: goto st582;
		case 110: goto st582;
	}
	goto tr193;
st582:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof582;
case 582:
	switch( (*( sm->p)) ) {
		case 71: goto st583;
		case 103: goto st583;
	}
	goto tr193;
st583:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof583;
case 583:
	if ( (*( sm->p)) == 62 )
		goto tr655;
	goto tr193;
st584:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof584;
case 584:
	if ( (*( sm->p)) == 62 )
		goto tr658;
	goto tr193;
st585:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof585;
case 585:
	switch( (*( sm->p)) ) {
		case 9: goto st586;
		case 32: goto st586;
	}
	goto tr193;
st586:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof586;
case 586:
	switch( (*( sm->p)) ) {
		case 9: goto st586;
		case 32: goto st586;
		case 72: goto st587;
		case 104: goto st587;
	}
	goto tr193;
st587:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof587;
case 587:
	switch( (*( sm->p)) ) {
		case 82: goto st588;
		case 114: goto st588;
	}
	goto tr193;
st588:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof588;
case 588:
	switch( (*( sm->p)) ) {
		case 69: goto st589;
		case 101: goto st589;
	}
	goto tr193;
st589:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof589;
case 589:
	switch( (*( sm->p)) ) {
		case 70: goto st590;
		case 102: goto st590;
	}
	goto tr193;
st590:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof590;
case 590:
	if ( (*( sm->p)) == 61 )
		goto st591;
	goto tr193;
st591:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof591;
case 591:
	if ( (*( sm->p)) == 34 )
		goto st592;
	goto tr193;
st592:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof592;
case 592:
	switch( (*( sm->p)) ) {
		case 35: goto tr750;
		case 47: goto tr750;
		case 72: goto tr751;
		case 104: goto tr751;
	}
	goto tr193;
tr750:
#line 117 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st593;
st593:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof593;
case 593:
#line 16499 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr193;
		case 32: goto tr193;
		case 34: goto tr753;
	}
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr193;
	goto st593;
tr753:
#line 118 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
	goto st594;
st594:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof594;
case 594:
#line 16516 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr193;
		case 32: goto tr193;
		case 34: goto tr753;
		case 62: goto st595;
	}
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr193;
	goto st593;
st595:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof595;
case 595:
	switch( (*( sm->p)) ) {
		case 10: goto tr193;
		case 13: goto tr193;
	}
	goto tr755;
tr755:
#line 119 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st596;
st596:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof596;
case 596:
#line 16543 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 10: goto tr193;
		case 13: goto tr193;
		case 60: goto tr757;
	}
	goto st596;
tr757:
#line 120 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
	goto st597;
st597:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof597;
case 597:
#line 16558 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 10: goto tr193;
		case 13: goto tr193;
		case 47: goto st598;
		case 60: goto tr757;
	}
	goto st596;
st598:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof598;
case 598:
	switch( (*( sm->p)) ) {
		case 10: goto tr193;
		case 13: goto tr193;
		case 60: goto tr757;
		case 65: goto st599;
		case 97: goto st599;
	}
	goto st596;
st599:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof599;
case 599:
	switch( (*( sm->p)) ) {
		case 10: goto tr193;
		case 13: goto tr193;
		case 60: goto tr757;
		case 62: goto tr760;
	}
	goto st596;
tr751:
#line 117 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st600;
st600:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof600;
case 600:
#line 16597 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 84: goto st601;
		case 116: goto st601;
	}
	goto tr193;
st601:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof601;
case 601:
	switch( (*( sm->p)) ) {
		case 84: goto st602;
		case 116: goto st602;
	}
	goto tr193;
st602:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof602;
case 602:
	switch( (*( sm->p)) ) {
		case 80: goto st603;
		case 112: goto st603;
	}
	goto tr193;
st603:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof603;
case 603:
	switch( (*( sm->p)) ) {
		case 58: goto st604;
		case 83: goto st607;
		case 115: goto st607;
	}
	goto tr193;
st604:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof604;
case 604:
	if ( (*( sm->p)) == 47 )
		goto st605;
	goto tr193;
st605:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof605;
case 605:
	if ( (*( sm->p)) == 47 )
		goto st606;
	goto tr193;
st606:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof606;
case 606:
	switch( (*( sm->p)) ) {
		case 0: goto tr193;
		case 32: goto tr193;
	}
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr193;
	goto st593;
st607:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof607;
case 607:
	if ( (*( sm->p)) == 58 )
		goto st604;
	goto tr193;
st608:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof608;
case 608:
	switch( (*( sm->p)) ) {
		case 62: goto tr659;
		case 76: goto st609;
		case 108: goto st609;
	}
	goto tr193;
st609:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof609;
case 609:
	switch( (*( sm->p)) ) {
		case 79: goto st610;
		case 111: goto st610;
	}
	goto tr193;
st610:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof610;
case 610:
	switch( (*( sm->p)) ) {
		case 67: goto st611;
		case 99: goto st611;
	}
	goto tr193;
st611:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof611;
case 611:
	switch( (*( sm->p)) ) {
		case 75: goto st612;
		case 107: goto st612;
	}
	goto tr193;
st612:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof612;
case 612:
	switch( (*( sm->p)) ) {
		case 81: goto st613;
		case 113: goto st613;
	}
	goto tr193;
st613:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof613;
case 613:
	switch( (*( sm->p)) ) {
		case 85: goto st614;
		case 117: goto st614;
	}
	goto tr193;
st614:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof614;
case 614:
	switch( (*( sm->p)) ) {
		case 79: goto st615;
		case 111: goto st615;
	}
	goto tr193;
st615:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof615;
case 615:
	switch( (*( sm->p)) ) {
		case 84: goto st616;
		case 116: goto st616;
	}
	goto tr193;
st616:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof616;
case 616:
	switch( (*( sm->p)) ) {
		case 69: goto st617;
		case 101: goto st617;
	}
	goto tr193;
st617:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof617;
case 617:
	if ( (*( sm->p)) == 62 )
		goto tr720;
	goto tr193;
st618:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof618;
case 618:
	switch( (*( sm->p)) ) {
		case 79: goto st619;
		case 111: goto st619;
	}
	goto tr193;
st619:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof619;
case 619:
	switch( (*( sm->p)) ) {
		case 68: goto st620;
		case 100: goto st620;
	}
	goto tr193;
st620:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof620;
case 620:
	switch( (*( sm->p)) ) {
		case 69: goto st621;
		case 101: goto st621;
	}
	goto tr193;
st621:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof621;
case 621:
	switch( (*( sm->p)) ) {
		case 9: goto st622;
		case 32: goto st622;
		case 61: goto st623;
		case 62: goto tr665;
	}
	goto tr193;
st622:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof622;
case 622:
	switch( (*( sm->p)) ) {
		case 9: goto st622;
		case 32: goto st622;
		case 61: goto st623;
	}
	goto tr193;
st623:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof623;
case 623:
	switch( (*( sm->p)) ) {
		case 9: goto st623;
		case 32: goto st623;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr782;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr782;
	} else
		goto tr782;
	goto tr193;
tr782:
#line 117 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st624;
st624:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof624;
case 624:
#line 16825 "ext/dtext/dtext.cpp"
	if ( (*( sm->p)) == 62 )
		goto tr668;
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st624;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st624;
	} else
		goto st624;
	goto tr193;
st625:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof625;
case 625:
	switch( (*( sm->p)) ) {
		case 77: goto st626;
		case 88: goto st627;
		case 109: goto st626;
		case 120: goto st627;
	}
	goto tr193;
st626:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof626;
case 626:
	if ( (*( sm->p)) == 62 )
		goto tr704;
	goto tr193;
st627:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof627;
case 627:
	switch( (*( sm->p)) ) {
		case 80: goto st628;
		case 112: goto st628;
	}
	goto tr193;
st628:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof628;
case 628:
	switch( (*( sm->p)) ) {
		case 65: goto st629;
		case 97: goto st629;
	}
	goto tr193;
st629:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof629;
case 629:
	switch( (*( sm->p)) ) {
		case 78: goto st630;
		case 110: goto st630;
	}
	goto tr193;
st630:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof630;
case 630:
	switch( (*( sm->p)) ) {
		case 68: goto st631;
		case 100: goto st631;
	}
	goto tr193;
st631:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof631;
case 631:
	switch( (*( sm->p)) ) {
		case 9: goto st632;
		case 32: goto st632;
		case 61: goto st634;
		case 62: goto tr684;
	}
	goto tr193;
tr793:
#line 117 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st632;
st632:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof632;
case 632:
#line 16910 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto tr793;
		case 10: goto tr193;
		case 13: goto tr193;
		case 32: goto tr793;
		case 61: goto tr794;
		case 62: goto tr688;
	}
	goto tr792;
tr792:
#line 117 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st633;
st633:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof633;
case 633:
#line 16928 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 10: goto tr193;
		case 13: goto tr193;
		case 62: goto tr690;
	}
	goto st633;
tr794:
#line 117 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st634;
st634:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof634;
case 634:
#line 16943 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto tr794;
		case 10: goto tr193;
		case 13: goto tr193;
		case 32: goto tr794;
		case 62: goto tr688;
	}
	goto tr792;
tr1668:
#line 117 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st635;
st635:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof635;
case 635:
#line 16960 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 84: goto st636;
		case 116: goto st636;
	}
	goto tr193;
st636:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof636;
case 636:
	switch( (*( sm->p)) ) {
		case 84: goto st637;
		case 116: goto st637;
	}
	goto tr193;
st637:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof637;
case 637:
	switch( (*( sm->p)) ) {
		case 80: goto st638;
		case 112: goto st638;
	}
	goto tr193;
st638:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof638;
case 638:
	switch( (*( sm->p)) ) {
		case 58: goto st639;
		case 83: goto st643;
		case 115: goto st643;
	}
	goto tr193;
st639:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof639;
case 639:
	if ( (*( sm->p)) == 47 )
		goto st640;
	goto tr193;
st640:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof640;
case 640:
	if ( (*( sm->p)) == 47 )
		goto st641;
	goto tr193;
st641:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof641;
case 641:
	switch( (*( sm->p)) ) {
		case 0: goto tr193;
		case 32: goto tr193;
	}
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr193;
	goto st642;
st642:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof642;
case 642:
	switch( (*( sm->p)) ) {
		case 0: goto tr193;
		case 32: goto tr193;
		case 62: goto tr804;
	}
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr193;
	goto st642;
st643:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof643;
case 643:
	if ( (*( sm->p)) == 58 )
		goto st639;
	goto tr193;
st644:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof644;
case 644:
	switch( (*( sm->p)) ) {
		case 79: goto st645;
		case 111: goto st645;
	}
	goto tr193;
st645:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof645;
case 645:
	switch( (*( sm->p)) ) {
		case 68: goto st646;
		case 100: goto st646;
	}
	goto tr193;
st646:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof646;
case 646:
	switch( (*( sm->p)) ) {
		case 84: goto st647;
		case 116: goto st647;
	}
	goto tr193;
st647:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof647;
case 647:
	switch( (*( sm->p)) ) {
		case 69: goto st648;
		case 101: goto st648;
	}
	goto tr193;
st648:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof648;
case 648:
	switch( (*( sm->p)) ) {
		case 88: goto st649;
		case 120: goto st649;
	}
	goto tr193;
st649:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof649;
case 649:
	switch( (*( sm->p)) ) {
		case 84: goto st650;
		case 116: goto st650;
	}
	goto tr193;
st650:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof650;
case 650:
	if ( (*( sm->p)) == 62 )
		goto tr711;
	goto tr193;
st651:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof651;
case 651:
	switch( (*( sm->p)) ) {
		case 62: goto tr722;
		case 80: goto st652;
		case 84: goto st659;
		case 112: goto st652;
		case 116: goto st659;
	}
	goto tr193;
st652:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof652;
case 652:
	switch( (*( sm->p)) ) {
		case 79: goto st653;
		case 111: goto st653;
	}
	goto tr193;
st653:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof653;
case 653:
	switch( (*( sm->p)) ) {
		case 73: goto st654;
		case 105: goto st654;
	}
	goto tr193;
st654:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof654;
case 654:
	switch( (*( sm->p)) ) {
		case 76: goto st655;
		case 108: goto st655;
	}
	goto tr193;
st655:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof655;
case 655:
	switch( (*( sm->p)) ) {
		case 69: goto st656;
		case 101: goto st656;
	}
	goto tr193;
st656:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof656;
case 656:
	switch( (*( sm->p)) ) {
		case 82: goto st657;
		case 114: goto st657;
	}
	goto tr193;
st657:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof657;
case 657:
	switch( (*( sm->p)) ) {
		case 62: goto tr729;
		case 83: goto st658;
		case 115: goto st658;
	}
	goto tr193;
st658:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof658;
case 658:
	if ( (*( sm->p)) == 62 )
		goto tr729;
	goto tr193;
st659:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof659;
case 659:
	switch( (*( sm->p)) ) {
		case 82: goto st660;
		case 114: goto st660;
	}
	goto tr193;
st660:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof660;
case 660:
	switch( (*( sm->p)) ) {
		case 79: goto st661;
		case 111: goto st661;
	}
	goto tr193;
st661:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof661;
case 661:
	switch( (*( sm->p)) ) {
		case 78: goto st662;
		case 110: goto st662;
	}
	goto tr193;
st662:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof662;
case 662:
	switch( (*( sm->p)) ) {
		case 71: goto st663;
		case 103: goto st663;
	}
	goto tr193;
st663:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof663;
case 663:
	if ( (*( sm->p)) == 62 )
		goto tr659;
	goto tr193;
st664:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof664;
case 664:
	switch( (*( sm->p)) ) {
		case 78: goto st665;
		case 110: goto st665;
	}
	goto tr193;
st665:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof665;
case 665:
	if ( (*( sm->p)) == 62 )
		goto tr731;
	goto tr193;
st666:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof666;
case 666:
	if ( (*( sm->p)) == 62 )
		goto tr732;
	goto tr193;
tr1335:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 566 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 91;}
	goto st1229;
st1229:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1229;
case 1229:
#line 17249 "ext/dtext/dtext.cpp"
	_widec = (*( sm->p));
	if ( 64 <= (*( sm->p)) && (*( sm->p)) <= 64 ) {
		_widec = (short)(640 + ((*( sm->p)) - -128));
		if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
	}
	switch( _widec ) {
		case 47: goto st574;
		case 65: goto st585;
		case 66: goto st608;
		case 67: goto st618;
		case 69: goto st625;
		case 72: goto tr1668;
		case 73: goto st626;
		case 78: goto st644;
		case 81: goto st613;
		case 83: goto st651;
		case 84: goto st664;
		case 85: goto st666;
		case 97: goto st585;
		case 98: goto st608;
		case 99: goto st618;
		case 101: goto st625;
		case 104: goto tr1668;
		case 105: goto st626;
		case 110: goto st644;
		case 113: goto st613;
		case 115: goto st651;
		case 116: goto st664;
		case 117: goto st666;
		case 1088: goto st667;
	}
	goto tr1337;
st667:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof667;
case 667:
	_widec = (*( sm->p));
	if ( (*( sm->p)) < 1 ) {
		if ( (*( sm->p)) <= -1 ) {
			_widec = (short)(640 + ((*( sm->p)) - -128));
			if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
		}
	} else if ( (*( sm->p)) > 8 ) {
		if ( (*( sm->p)) > 31 ) {
			if ( 33 <= (*( sm->p)) )
 {				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else if ( (*( sm->p)) >= 14 ) {
			_widec = (short)(640 + ((*( sm->p)) - -128));
			if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
		}
	} else {
		_widec = (short)(640 + ((*( sm->p)) - -128));
		if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
	}
	if ( _widec < 1025 ) {
		if ( 896 <= _widec && _widec <= 1023 )
			goto tr824;
	} else if ( _widec > 1032 ) {
		if ( _widec > 1055 ) {
			if ( 1057 <= _widec && _widec <= 1151 )
				goto tr824;
		} else if ( _widec >= 1038 )
			goto tr824;
	} else
		goto tr824;
	goto tr193;
tr824:
#line 117 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st668;
st668:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof668;
case 668:
#line 17336 "ext/dtext/dtext.cpp"
	_widec = (*( sm->p));
	if ( (*( sm->p)) < 14 ) {
		if ( (*( sm->p)) > 9 ) {
			if ( 11 <= (*( sm->p)) && (*( sm->p)) <= 12 ) {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else {
			_widec = (short)(640 + ((*( sm->p)) - -128));
			if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
		}
	} else if ( (*( sm->p)) > 61 ) {
		if ( (*( sm->p)) > 62 ) {
			if ( 63 <= (*( sm->p)) )
 {				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else if ( (*( sm->p)) >= 62 ) {
			_widec = (short)(640 + ((*( sm->p)) - -128));
			if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
		}
	} else {
		_widec = (short)(640 + ((*( sm->p)) - -128));
		if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
	}
	if ( _widec == 1086 )
		goto tr826;
	if ( _widec < 1035 ) {
		if ( 896 <= _widec && _widec <= 1033 )
			goto st668;
	} else if ( _widec > 1036 ) {
		if ( 1038 <= _widec && _widec <= 1151 )
			goto st668;
	} else
		goto st668;
	goto tr193;
tr1336:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 566 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 91;}
	goto st1230;
st1230:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1230;
case 1230:
#line 17393 "ext/dtext/dtext.cpp"
	_widec = (*( sm->p));
	if ( (*( sm->p)) < 1 ) {
		if ( (*( sm->p)) < -29 ) {
			if ( (*( sm->p)) < -32 ) {
				if ( -62 <= (*( sm->p)) && (*( sm->p)) <= -33 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > -31 ) {
				if ( -30 <= (*( sm->p)) && (*( sm->p)) <= -30 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else if ( (*( sm->p)) > -29 ) {
			if ( (*( sm->p)) < -17 ) {
				if ( -28 <= (*( sm->p)) && (*( sm->p)) <= -18 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > -17 ) {
				if ( -16 <= (*( sm->p)) && (*( sm->p)) <= -12 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else {
			_widec = (short)(640 + ((*( sm->p)) - -128));
			if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
		}
	} else if ( (*( sm->p)) > 8 ) {
		if ( (*( sm->p)) < 65 ) {
			if ( (*( sm->p)) < 46 ) {
				if ( 14 <= (*( sm->p)) && (*( sm->p)) <= 31 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > 46 ) {
				if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else if ( (*( sm->p)) > 90 ) {
			if ( (*( sm->p)) < 97 ) {
				if ( 95 <= (*( sm->p)) && (*( sm->p)) <= 95 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > 122 ) {
				if ( 127 <= (*( sm->p)) )
 {					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else {
			_widec = (short)(640 + ((*( sm->p)) - -128));
			if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
		}
	} else {
		_widec = (short)(640 + ((*( sm->p)) - -128));
		if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
	}
	switch( _widec ) {
		case 994: goto tr1676;
		case 995: goto tr1677;
		case 1007: goto tr1678;
		case 1070: goto tr1681;
		case 1119: goto tr1681;
		case 1151: goto tr1680;
	}
	if ( _widec < 1025 ) {
		if ( _widec < 992 ) {
			if ( 962 <= _widec && _widec <= 991 )
				goto tr1674;
		} else if ( _widec > 1006 ) {
			if ( 1008 <= _widec && _widec <= 1012 )
				goto tr1679;
		} else
			goto tr1675;
	} else if ( _widec > 1032 ) {
		if ( _widec < 1072 ) {
			if ( 1038 <= _widec && _widec <= 1055 )
				goto tr1680;
		} else if ( _widec > 1081 ) {
			if ( _widec > 1114 ) {
				if ( 1121 <= _widec && _widec <= 1146 )
					goto tr1680;
			} else if ( _widec >= 1089 )
				goto tr1680;
		} else
			goto tr1680;
	} else
		goto tr1680;
	goto tr1337;
tr1674:
#line 117 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st669;
st669:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof669;
case 669:
#line 17539 "ext/dtext/dtext.cpp"
	_widec = (*( sm->p));
	if ( (*( sm->p)) <= -65 ) {
		_widec = (short)(640 + ((*( sm->p)) - -128));
		if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
	}
	if ( 896 <= _widec && _widec <= 959 )
		goto st670;
	goto tr193;
tr1680:
#line 117 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st670;
st670:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof670;
case 670:
#line 17558 "ext/dtext/dtext.cpp"
	_widec = (*( sm->p));
	if ( (*( sm->p)) < 1 ) {
		if ( (*( sm->p)) < -29 ) {
			if ( (*( sm->p)) < -62 ) {
				if ( (*( sm->p)) <= -63 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > -33 ) {
				if ( (*( sm->p)) > -31 ) {
					if ( -30 <= (*( sm->p)) && (*( sm->p)) <= -30 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= -32 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else if ( (*( sm->p)) > -29 ) {
			if ( (*( sm->p)) < -17 ) {
				if ( -28 <= (*( sm->p)) && (*( sm->p)) <= -18 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > -17 ) {
				if ( (*( sm->p)) > -12 ) {
					if ( -11 <= (*( sm->p)) && (*( sm->p)) <= -1 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= -16 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else {
			_widec = (short)(640 + ((*( sm->p)) - -128));
			if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
		}
	} else if ( (*( sm->p)) > 8 ) {
		if ( (*( sm->p)) < 45 ) {
			if ( (*( sm->p)) < 33 ) {
				if ( 14 <= (*( sm->p)) && (*( sm->p)) <= 31 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > 33 ) {
				if ( (*( sm->p)) > 39 ) {
					if ( 43 <= (*( sm->p)) && (*( sm->p)) <= 43 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= 39 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else if ( (*( sm->p)) > 47 ) {
			if ( (*( sm->p)) < 95 ) {
				if ( (*( sm->p)) > 57 ) {
					if ( 65 <= (*( sm->p)) && (*( sm->p)) <= 90 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= 48 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > 95 ) {
				if ( (*( sm->p)) > 122 ) {
					if ( 127 <= (*( sm->p)) )
 {						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= 97 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else {
			_widec = (short)(640 + ((*( sm->p)) - -128));
			if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
		}
	} else {
		_widec = (short)(640 + ((*( sm->p)) - -128));
		if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
	}
	switch( _widec ) {
		case 994: goto st684;
		case 995: goto st686;
		case 1007: goto st688;
		case 1057: goto st670;
		case 1063: goto st692;
		case 1067: goto st670;
		case 1119: goto st670;
		case 1151: goto tr835;
	}
	if ( _widec < 1025 ) {
		if ( _widec < 992 ) {
			if ( _widec > 961 ) {
				if ( 962 <= _widec && _widec <= 991 )
					goto st682;
			} else if ( _widec >= 896 )
				goto st671;
		} else if ( _widec > 1006 ) {
			if ( _widec > 1012 ) {
				if ( 1013 <= _widec && _widec <= 1023 )
					goto st671;
			} else if ( _widec >= 1008 )
				goto st691;
		} else
			goto st683;
	} else if ( _widec > 1032 ) {
		if ( _widec < 1072 ) {
			if ( _widec > 1055 ) {
				if ( 1069 <= _widec && _widec <= 1071 )
					goto st670;
			} else if ( _widec >= 1038 )
				goto tr835;
		} else if ( _widec > 1081 ) {
			if ( _widec > 1114 ) {
				if ( 1121 <= _widec && _widec <= 1146 )
					goto tr835;
			} else if ( _widec >= 1089 )
				goto tr835;
		} else
			goto tr835;
	} else
		goto tr835;
	goto tr185;
st671:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof671;
case 671:
	_widec = (*( sm->p));
	if ( (*( sm->p)) < 1 ) {
		if ( (*( sm->p)) < -29 ) {
			if ( (*( sm->p)) < -62 ) {
				if ( (*( sm->p)) <= -63 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > -33 ) {
				if ( (*( sm->p)) > -31 ) {
					if ( -30 <= (*( sm->p)) && (*( sm->p)) <= -30 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= -32 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else if ( (*( sm->p)) > -29 ) {
			if ( (*( sm->p)) < -17 ) {
				if ( -28 <= (*( sm->p)) && (*( sm->p)) <= -18 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > -17 ) {
				if ( (*( sm->p)) > -12 ) {
					if ( -11 <= (*( sm->p)) && (*( sm->p)) <= -1 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= -16 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else {
			_widec = (short)(640 + ((*( sm->p)) - -128));
			if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
		}
	} else if ( (*( sm->p)) > 8 ) {
		if ( (*( sm->p)) < 45 ) {
			if ( (*( sm->p)) < 33 ) {
				if ( 14 <= (*( sm->p)) && (*( sm->p)) <= 31 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > 33 ) {
				if ( (*( sm->p)) > 39 ) {
					if ( 43 <= (*( sm->p)) && (*( sm->p)) <= 43 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= 39 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else if ( (*( sm->p)) > 47 ) {
			if ( (*( sm->p)) < 95 ) {
				if ( (*( sm->p)) > 57 ) {
					if ( 65 <= (*( sm->p)) && (*( sm->p)) <= 90 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= 48 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > 95 ) {
				if ( (*( sm->p)) > 122 ) {
					if ( 127 <= (*( sm->p)) )
 {						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= 97 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else {
			_widec = (short)(640 + ((*( sm->p)) - -128));
			if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
		}
	} else {
		_widec = (short)(640 + ((*( sm->p)) - -128));
		if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
	}
	switch( _widec ) {
		case 994: goto st674;
		case 995: goto st676;
		case 1007: goto st678;
		case 1057: goto st671;
		case 1063: goto st671;
		case 1067: goto st671;
		case 1119: goto st671;
		case 1151: goto tr843;
	}
	if ( _widec < 1025 ) {
		if ( _widec < 992 ) {
			if ( _widec > 961 ) {
				if ( 962 <= _widec && _widec <= 991 )
					goto st672;
			} else if ( _widec >= 896 )
				goto st671;
		} else if ( _widec > 1006 ) {
			if ( _widec > 1012 ) {
				if ( 1013 <= _widec && _widec <= 1023 )
					goto st671;
			} else if ( _widec >= 1008 )
				goto st680;
		} else
			goto st673;
	} else if ( _widec > 1032 ) {
		if ( _widec < 1072 ) {
			if ( _widec > 1055 ) {
				if ( 1069 <= _widec && _widec <= 1071 )
					goto st671;
			} else if ( _widec >= 1038 )
				goto tr843;
		} else if ( _widec > 1081 ) {
			if ( _widec > 1114 ) {
				if ( 1121 <= _widec && _widec <= 1146 )
					goto tr843;
			} else if ( _widec >= 1089 )
				goto tr843;
		} else
			goto tr843;
	} else
		goto tr843;
	goto tr185;
st672:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof672;
case 672:
	_widec = (*( sm->p));
	if ( (*( sm->p)) < 1 ) {
		if ( (*( sm->p)) < -30 ) {
			if ( (*( sm->p)) < -64 ) {
				if ( (*( sm->p)) <= -65 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > -63 ) {
				if ( (*( sm->p)) > -33 ) {
					if ( -32 <= (*( sm->p)) && (*( sm->p)) <= -31 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= -62 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else if ( (*( sm->p)) > -30 ) {
			if ( (*( sm->p)) < -17 ) {
				if ( (*( sm->p)) > -29 ) {
					if ( -28 <= (*( sm->p)) && (*( sm->p)) <= -18 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= -29 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > -17 ) {
				if ( (*( sm->p)) > -12 ) {
					if ( -11 <= (*( sm->p)) && (*( sm->p)) <= -1 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= -16 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else {
			_widec = (short)(640 + ((*( sm->p)) - -128));
			if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
		}
	} else if ( (*( sm->p)) > 8 ) {
		if ( (*( sm->p)) < 45 ) {
			if ( (*( sm->p)) < 33 ) {
				if ( 14 <= (*( sm->p)) && (*( sm->p)) <= 31 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > 33 ) {
				if ( (*( sm->p)) > 39 ) {
					if ( 43 <= (*( sm->p)) && (*( sm->p)) <= 43 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= 39 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else if ( (*( sm->p)) > 47 ) {
			if ( (*( sm->p)) < 95 ) {
				if ( (*( sm->p)) > 57 ) {
					if ( 65 <= (*( sm->p)) && (*( sm->p)) <= 90 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= 48 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > 95 ) {
				if ( (*( sm->p)) > 122 ) {
					if ( 127 <= (*( sm->p)) )
 {						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= 97 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else {
			_widec = (short)(640 + ((*( sm->p)) - -128));
			if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
		}
	} else {
		_widec = (short)(640 + ((*( sm->p)) - -128));
		if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
	}
	switch( _widec ) {
		case 994: goto st674;
		case 995: goto st676;
		case 1007: goto st678;
		case 1057: goto st671;
		case 1063: goto st671;
		case 1067: goto st671;
		case 1119: goto st671;
		case 1151: goto tr843;
	}
	if ( _widec < 1013 ) {
		if ( _widec < 962 ) {
			if ( _widec > 959 ) {
				if ( 960 <= _widec && _widec <= 961 )
					goto st671;
			} else if ( _widec >= 896 )
				goto tr843;
		} else if ( _widec > 991 ) {
			if ( _widec > 1006 ) {
				if ( 1008 <= _widec && _widec <= 1012 )
					goto st680;
			} else if ( _widec >= 992 )
				goto st673;
		} else
			goto st672;
	} else if ( _widec > 1023 ) {
		if ( _widec < 1069 ) {
			if ( _widec > 1032 ) {
				if ( 1038 <= _widec && _widec <= 1055 )
					goto tr843;
			} else if ( _widec >= 1025 )
				goto tr843;
		} else if ( _widec > 1071 ) {
			if ( _widec < 1089 ) {
				if ( 1072 <= _widec && _widec <= 1081 )
					goto tr843;
			} else if ( _widec > 1114 ) {
				if ( 1121 <= _widec && _widec <= 1146 )
					goto tr843;
			} else
				goto tr843;
		} else
			goto st671;
	} else
		goto st671;
	goto tr185;
tr843:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 118 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
#line 386 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 56;}
	goto st1231;
st1231:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1231;
case 1231:
#line 18138 "ext/dtext/dtext.cpp"
	_widec = (*( sm->p));
	if ( (*( sm->p)) < 1 ) {
		if ( (*( sm->p)) < -29 ) {
			if ( (*( sm->p)) < -62 ) {
				if ( (*( sm->p)) <= -63 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > -33 ) {
				if ( (*( sm->p)) > -31 ) {
					if ( -30 <= (*( sm->p)) && (*( sm->p)) <= -30 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= -32 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else if ( (*( sm->p)) > -29 ) {
			if ( (*( sm->p)) < -17 ) {
				if ( -28 <= (*( sm->p)) && (*( sm->p)) <= -18 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > -17 ) {
				if ( (*( sm->p)) > -12 ) {
					if ( -11 <= (*( sm->p)) && (*( sm->p)) <= -1 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= -16 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else {
			_widec = (short)(640 + ((*( sm->p)) - -128));
			if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
		}
	} else if ( (*( sm->p)) > 8 ) {
		if ( (*( sm->p)) < 45 ) {
			if ( (*( sm->p)) < 33 ) {
				if ( 14 <= (*( sm->p)) && (*( sm->p)) <= 31 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > 33 ) {
				if ( (*( sm->p)) > 39 ) {
					if ( 43 <= (*( sm->p)) && (*( sm->p)) <= 43 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= 39 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else if ( (*( sm->p)) > 47 ) {
			if ( (*( sm->p)) < 95 ) {
				if ( (*( sm->p)) > 57 ) {
					if ( 65 <= (*( sm->p)) && (*( sm->p)) <= 90 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= 48 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > 95 ) {
				if ( (*( sm->p)) > 122 ) {
					if ( 127 <= (*( sm->p)) )
 {						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= 97 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else {
			_widec = (short)(640 + ((*( sm->p)) - -128));
			if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
		}
	} else {
		_widec = (short)(640 + ((*( sm->p)) - -128));
		if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
	}
	switch( _widec ) {
		case 994: goto st674;
		case 995: goto st676;
		case 1007: goto st678;
		case 1057: goto st671;
		case 1063: goto st671;
		case 1067: goto st671;
		case 1119: goto st671;
		case 1151: goto tr843;
	}
	if ( _widec < 1025 ) {
		if ( _widec < 992 ) {
			if ( _widec > 961 ) {
				if ( 962 <= _widec && _widec <= 991 )
					goto st672;
			} else if ( _widec >= 896 )
				goto st671;
		} else if ( _widec > 1006 ) {
			if ( _widec > 1012 ) {
				if ( 1013 <= _widec && _widec <= 1023 )
					goto st671;
			} else if ( _widec >= 1008 )
				goto st680;
		} else
			goto st673;
	} else if ( _widec > 1032 ) {
		if ( _widec < 1072 ) {
			if ( _widec > 1055 ) {
				if ( 1069 <= _widec && _widec <= 1071 )
					goto st671;
			} else if ( _widec >= 1038 )
				goto tr843;
		} else if ( _widec > 1081 ) {
			if ( _widec > 1114 ) {
				if ( 1121 <= _widec && _widec <= 1146 )
					goto tr843;
			} else if ( _widec >= 1089 )
				goto tr843;
		} else
			goto tr843;
	} else
		goto tr843;
	goto tr1682;
st673:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof673;
case 673:
	_widec = (*( sm->p));
	if ( (*( sm->p)) < 1 ) {
		if ( (*( sm->p)) < -30 ) {
			if ( (*( sm->p)) < -64 ) {
				if ( (*( sm->p)) <= -65 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > -63 ) {
				if ( (*( sm->p)) > -33 ) {
					if ( -32 <= (*( sm->p)) && (*( sm->p)) <= -31 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= -62 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else if ( (*( sm->p)) > -30 ) {
			if ( (*( sm->p)) < -17 ) {
				if ( (*( sm->p)) > -29 ) {
					if ( -28 <= (*( sm->p)) && (*( sm->p)) <= -18 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= -29 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > -17 ) {
				if ( (*( sm->p)) > -12 ) {
					if ( -11 <= (*( sm->p)) && (*( sm->p)) <= -1 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= -16 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else {
			_widec = (short)(640 + ((*( sm->p)) - -128));
			if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
		}
	} else if ( (*( sm->p)) > 8 ) {
		if ( (*( sm->p)) < 45 ) {
			if ( (*( sm->p)) < 33 ) {
				if ( 14 <= (*( sm->p)) && (*( sm->p)) <= 31 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > 33 ) {
				if ( (*( sm->p)) > 39 ) {
					if ( 43 <= (*( sm->p)) && (*( sm->p)) <= 43 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= 39 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else if ( (*( sm->p)) > 47 ) {
			if ( (*( sm->p)) < 95 ) {
				if ( (*( sm->p)) > 57 ) {
					if ( 65 <= (*( sm->p)) && (*( sm->p)) <= 90 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= 48 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > 95 ) {
				if ( (*( sm->p)) > 122 ) {
					if ( 127 <= (*( sm->p)) )
 {						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= 97 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else {
			_widec = (short)(640 + ((*( sm->p)) - -128));
			if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
		}
	} else {
		_widec = (short)(640 + ((*( sm->p)) - -128));
		if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
	}
	switch( _widec ) {
		case 994: goto st674;
		case 995: goto st676;
		case 1007: goto st678;
		case 1057: goto st671;
		case 1063: goto st671;
		case 1067: goto st671;
		case 1119: goto st671;
		case 1151: goto tr843;
	}
	if ( _widec < 1013 ) {
		if ( _widec < 962 ) {
			if ( _widec > 959 ) {
				if ( 960 <= _widec && _widec <= 961 )
					goto st671;
			} else if ( _widec >= 896 )
				goto st672;
		} else if ( _widec > 991 ) {
			if ( _widec > 1006 ) {
				if ( 1008 <= _widec && _widec <= 1012 )
					goto st680;
			} else if ( _widec >= 992 )
				goto st673;
		} else
			goto st672;
	} else if ( _widec > 1023 ) {
		if ( _widec < 1069 ) {
			if ( _widec > 1032 ) {
				if ( 1038 <= _widec && _widec <= 1055 )
					goto tr843;
			} else if ( _widec >= 1025 )
				goto tr843;
		} else if ( _widec > 1071 ) {
			if ( _widec < 1089 ) {
				if ( 1072 <= _widec && _widec <= 1081 )
					goto tr843;
			} else if ( _widec > 1114 ) {
				if ( 1121 <= _widec && _widec <= 1146 )
					goto tr843;
			} else
				goto tr843;
		} else
			goto st671;
	} else
		goto st671;
	goto tr185;
st674:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof674;
case 674:
	_widec = (*( sm->p));
	if ( (*( sm->p)) < -11 ) {
		if ( (*( sm->p)) < -32 ) {
			if ( (*( sm->p)) < -98 ) {
				if ( (*( sm->p)) > -100 ) {
					if ( -99 <= (*( sm->p)) && (*( sm->p)) <= -99 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > -65 ) {
				if ( (*( sm->p)) > -63 ) {
					if ( -62 <= (*( sm->p)) && (*( sm->p)) <= -33 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= -64 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else if ( (*( sm->p)) > -31 ) {
			if ( (*( sm->p)) < -28 ) {
				if ( (*( sm->p)) > -30 ) {
					if ( -29 <= (*( sm->p)) && (*( sm->p)) <= -29 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= -30 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > -18 ) {
				if ( (*( sm->p)) > -17 ) {
					if ( -16 <= (*( sm->p)) && (*( sm->p)) <= -12 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= -17 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else {
			_widec = (short)(640 + ((*( sm->p)) - -128));
			if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
		}
	} else if ( (*( sm->p)) > -1 ) {
		if ( (*( sm->p)) < 45 ) {
			if ( (*( sm->p)) < 33 ) {
				if ( (*( sm->p)) > 8 ) {
					if ( 14 <= (*( sm->p)) && (*( sm->p)) <= 31 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= 1 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > 33 ) {
				if ( (*( sm->p)) > 39 ) {
					if ( 43 <= (*( sm->p)) && (*( sm->p)) <= 43 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= 39 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else if ( (*( sm->p)) > 47 ) {
			if ( (*( sm->p)) < 95 ) {
				if ( (*( sm->p)) > 57 ) {
					if ( 65 <= (*( sm->p)) && (*( sm->p)) <= 90 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= 48 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > 95 ) {
				if ( (*( sm->p)) > 122 ) {
					if ( 127 <= (*( sm->p)) )
 {						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= 97 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else {
			_widec = (short)(640 + ((*( sm->p)) - -128));
			if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
		}
	} else {
		_widec = (short)(640 + ((*( sm->p)) - -128));
		if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
	}
	switch( _widec ) {
		case 925: goto st675;
		case 994: goto st674;
		case 995: goto st676;
		case 1007: goto st678;
		case 1057: goto st671;
		case 1063: goto st671;
		case 1067: goto st671;
		case 1119: goto st671;
		case 1151: goto tr843;
	}
	if ( _widec < 1013 ) {
		if ( _widec < 962 ) {
			if ( _widec > 959 ) {
				if ( 960 <= _widec && _widec <= 961 )
					goto st671;
			} else if ( _widec >= 896 )
				goto st672;
		} else if ( _widec > 991 ) {
			if ( _widec > 1006 ) {
				if ( 1008 <= _widec && _widec <= 1012 )
					goto st680;
			} else if ( _widec >= 992 )
				goto st673;
		} else
			goto st672;
	} else if ( _widec > 1023 ) {
		if ( _widec < 1069 ) {
			if ( _widec > 1032 ) {
				if ( 1038 <= _widec && _widec <= 1055 )
					goto tr843;
			} else if ( _widec >= 1025 )
				goto tr843;
		} else if ( _widec > 1071 ) {
			if ( _widec < 1089 ) {
				if ( 1072 <= _widec && _widec <= 1081 )
					goto tr843;
			} else if ( _widec > 1114 ) {
				if ( 1121 <= _widec && _widec <= 1146 )
					goto tr843;
			} else
				goto tr843;
		} else
			goto st671;
	} else
		goto st671;
	goto tr185;
st675:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof675;
case 675:
	_widec = (*( sm->p));
	if ( (*( sm->p)) < -11 ) {
		if ( (*( sm->p)) < -32 ) {
			if ( (*( sm->p)) < -82 ) {
				if ( (*( sm->p)) > -84 ) {
					if ( -83 <= (*( sm->p)) && (*( sm->p)) <= -83 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > -65 ) {
				if ( (*( sm->p)) > -63 ) {
					if ( -62 <= (*( sm->p)) && (*( sm->p)) <= -33 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= -64 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else if ( (*( sm->p)) > -31 ) {
			if ( (*( sm->p)) < -28 ) {
				if ( (*( sm->p)) > -30 ) {
					if ( -29 <= (*( sm->p)) && (*( sm->p)) <= -29 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= -30 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > -18 ) {
				if ( (*( sm->p)) > -17 ) {
					if ( -16 <= (*( sm->p)) && (*( sm->p)) <= -12 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= -17 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else {
			_widec = (short)(640 + ((*( sm->p)) - -128));
			if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
		}
	} else if ( (*( sm->p)) > -1 ) {
		if ( (*( sm->p)) < 45 ) {
			if ( (*( sm->p)) < 33 ) {
				if ( (*( sm->p)) > 8 ) {
					if ( 14 <= (*( sm->p)) && (*( sm->p)) <= 31 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= 1 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > 33 ) {
				if ( (*( sm->p)) > 39 ) {
					if ( 43 <= (*( sm->p)) && (*( sm->p)) <= 43 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= 39 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else if ( (*( sm->p)) > 47 ) {
			if ( (*( sm->p)) < 95 ) {
				if ( (*( sm->p)) > 57 ) {
					if ( 65 <= (*( sm->p)) && (*( sm->p)) <= 90 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= 48 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > 95 ) {
				if ( (*( sm->p)) > 122 ) {
					if ( 127 <= (*( sm->p)) )
 {						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= 97 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else {
			_widec = (short)(640 + ((*( sm->p)) - -128));
			if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
		}
	} else {
		_widec = (short)(640 + ((*( sm->p)) - -128));
		if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
	}
	switch( _widec ) {
		case 941: goto st671;
		case 994: goto st674;
		case 995: goto st676;
		case 1007: goto st678;
		case 1057: goto st671;
		case 1063: goto st671;
		case 1067: goto st671;
		case 1119: goto st671;
		case 1151: goto tr843;
	}
	if ( _widec < 1013 ) {
		if ( _widec < 962 ) {
			if ( _widec > 959 ) {
				if ( 960 <= _widec && _widec <= 961 )
					goto st671;
			} else if ( _widec >= 896 )
				goto tr843;
		} else if ( _widec > 991 ) {
			if ( _widec > 1006 ) {
				if ( 1008 <= _widec && _widec <= 1012 )
					goto st680;
			} else if ( _widec >= 992 )
				goto st673;
		} else
			goto st672;
	} else if ( _widec > 1023 ) {
		if ( _widec < 1069 ) {
			if ( _widec > 1032 ) {
				if ( 1038 <= _widec && _widec <= 1055 )
					goto tr843;
			} else if ( _widec >= 1025 )
				goto tr843;
		} else if ( _widec > 1071 ) {
			if ( _widec < 1089 ) {
				if ( 1072 <= _widec && _widec <= 1081 )
					goto tr843;
			} else if ( _widec > 1114 ) {
				if ( 1121 <= _widec && _widec <= 1146 )
					goto tr843;
			} else
				goto tr843;
		} else
			goto st671;
	} else
		goto st671;
	goto tr185;
st676:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof676;
case 676:
	_widec = (*( sm->p));
	if ( (*( sm->p)) < -11 ) {
		if ( (*( sm->p)) < -32 ) {
			if ( (*( sm->p)) < -127 ) {
				if ( (*( sm->p)) <= -128 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > -65 ) {
				if ( (*( sm->p)) > -63 ) {
					if ( -62 <= (*( sm->p)) && (*( sm->p)) <= -33 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= -64 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else if ( (*( sm->p)) > -31 ) {
			if ( (*( sm->p)) < -28 ) {
				if ( (*( sm->p)) > -30 ) {
					if ( -29 <= (*( sm->p)) && (*( sm->p)) <= -29 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= -30 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > -18 ) {
				if ( (*( sm->p)) > -17 ) {
					if ( -16 <= (*( sm->p)) && (*( sm->p)) <= -12 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= -17 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else {
			_widec = (short)(640 + ((*( sm->p)) - -128));
			if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
		}
	} else if ( (*( sm->p)) > -1 ) {
		if ( (*( sm->p)) < 45 ) {
			if ( (*( sm->p)) < 33 ) {
				if ( (*( sm->p)) > 8 ) {
					if ( 14 <= (*( sm->p)) && (*( sm->p)) <= 31 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= 1 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > 33 ) {
				if ( (*( sm->p)) > 39 ) {
					if ( 43 <= (*( sm->p)) && (*( sm->p)) <= 43 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= 39 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else if ( (*( sm->p)) > 47 ) {
			if ( (*( sm->p)) < 95 ) {
				if ( (*( sm->p)) > 57 ) {
					if ( 65 <= (*( sm->p)) && (*( sm->p)) <= 90 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= 48 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > 95 ) {
				if ( (*( sm->p)) > 122 ) {
					if ( 127 <= (*( sm->p)) )
 {						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= 97 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else {
			_widec = (short)(640 + ((*( sm->p)) - -128));
			if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
		}
	} else {
		_widec = (short)(640 + ((*( sm->p)) - -128));
		if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
	}
	switch( _widec ) {
		case 896: goto st677;
		case 994: goto st674;
		case 995: goto st676;
		case 1007: goto st678;
		case 1057: goto st671;
		case 1063: goto st671;
		case 1067: goto st671;
		case 1119: goto st671;
		case 1151: goto tr843;
	}
	if ( _widec < 1013 ) {
		if ( _widec < 962 ) {
			if ( _widec > 959 ) {
				if ( 960 <= _widec && _widec <= 961 )
					goto st671;
			} else if ( _widec >= 897 )
				goto st672;
		} else if ( _widec > 991 ) {
			if ( _widec > 1006 ) {
				if ( 1008 <= _widec && _widec <= 1012 )
					goto st680;
			} else if ( _widec >= 992 )
				goto st673;
		} else
			goto st672;
	} else if ( _widec > 1023 ) {
		if ( _widec < 1069 ) {
			if ( _widec > 1032 ) {
				if ( 1038 <= _widec && _widec <= 1055 )
					goto tr843;
			} else if ( _widec >= 1025 )
				goto tr843;
		} else if ( _widec > 1071 ) {
			if ( _widec < 1089 ) {
				if ( 1072 <= _widec && _widec <= 1081 )
					goto tr843;
			} else if ( _widec > 1114 ) {
				if ( 1121 <= _widec && _widec <= 1146 )
					goto tr843;
			} else
				goto tr843;
		} else
			goto st671;
	} else
		goto st671;
	goto tr185;
st677:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof677;
case 677:
	_widec = (*( sm->p));
	if ( (*( sm->p)) < -17 ) {
		if ( (*( sm->p)) < -99 ) {
			if ( (*( sm->p)) < -120 ) {
				if ( (*( sm->p)) > -126 ) {
					if ( -125 <= (*( sm->p)) && (*( sm->p)) <= -121 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > -111 ) {
				if ( (*( sm->p)) > -109 ) {
					if ( -108 <= (*( sm->p)) && (*( sm->p)) <= -100 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= -110 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else if ( (*( sm->p)) > -65 ) {
			if ( (*( sm->p)) < -32 ) {
				if ( (*( sm->p)) > -63 ) {
					if ( -62 <= (*( sm->p)) && (*( sm->p)) <= -33 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= -64 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > -31 ) {
				if ( (*( sm->p)) < -29 ) {
					if ( -30 <= (*( sm->p)) && (*( sm->p)) <= -30 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) > -29 ) {
					if ( -28 <= (*( sm->p)) && (*( sm->p)) <= -18 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else {
			_widec = (short)(640 + ((*( sm->p)) - -128));
			if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
		}
	} else if ( (*( sm->p)) > -17 ) {
		if ( (*( sm->p)) < 43 ) {
			if ( (*( sm->p)) < 1 ) {
				if ( (*( sm->p)) > -12 ) {
					if ( -11 <= (*( sm->p)) && (*( sm->p)) <= -1 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= -16 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > 8 ) {
				if ( (*( sm->p)) < 33 ) {
					if ( 14 <= (*( sm->p)) && (*( sm->p)) <= 31 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) > 33 ) {
					if ( 39 <= (*( sm->p)) && (*( sm->p)) <= 39 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else if ( (*( sm->p)) > 43 ) {
			if ( (*( sm->p)) < 65 ) {
				if ( (*( sm->p)) > 47 ) {
					if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= 45 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > 90 ) {
				if ( (*( sm->p)) < 97 ) {
					if ( 95 <= (*( sm->p)) && (*( sm->p)) <= 95 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) > 122 ) {
					if ( 127 <= (*( sm->p)) )
 {						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else {
			_widec = (short)(640 + ((*( sm->p)) - -128));
			if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
		}
	} else {
		_widec = (short)(640 + ((*( sm->p)) - -128));
		if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
	}
	switch( _widec ) {
		case 994: goto st674;
		case 995: goto st676;
		case 1007: goto st678;
		case 1057: goto st671;
		case 1063: goto st671;
		case 1067: goto st671;
		case 1119: goto st671;
		case 1151: goto tr843;
	}
	if ( _widec < 992 ) {
		if ( _widec < 914 ) {
			if ( _widec < 899 ) {
				if ( 896 <= _widec && _widec <= 898 )
					goto st671;
			} else if ( _widec > 903 ) {
				if ( 904 <= _widec && _widec <= 913 )
					goto st671;
			} else
				goto tr843;
		} else if ( _widec > 915 ) {
			if ( _widec < 925 ) {
				if ( 916 <= _widec && _widec <= 924 )
					goto st671;
			} else if ( _widec > 959 ) {
				if ( _widec > 961 ) {
					if ( 962 <= _widec && _widec <= 991 )
						goto st672;
				} else if ( _widec >= 960 )
					goto st671;
			} else
				goto tr843;
		} else
			goto tr843;
	} else if ( _widec > 1006 ) {
		if ( _widec < 1038 ) {
			if ( _widec < 1013 ) {
				if ( 1008 <= _widec && _widec <= 1012 )
					goto st680;
			} else if ( _widec > 1023 ) {
				if ( 1025 <= _widec && _widec <= 1032 )
					goto tr843;
			} else
				goto st671;
		} else if ( _widec > 1055 ) {
			if ( _widec < 1072 ) {
				if ( 1069 <= _widec && _widec <= 1071 )
					goto st671;
			} else if ( _widec > 1081 ) {
				if ( _widec > 1114 ) {
					if ( 1121 <= _widec && _widec <= 1146 )
						goto tr843;
				} else if ( _widec >= 1089 )
					goto tr843;
			} else
				goto tr843;
		} else
			goto tr843;
	} else
		goto st673;
	goto tr185;
st678:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof678;
case 678:
	_widec = (*( sm->p));
	if ( (*( sm->p)) < -16 ) {
		if ( (*( sm->p)) < -62 ) {
			if ( (*( sm->p)) < -67 ) {
				if ( (*( sm->p)) > -69 ) {
					if ( -68 <= (*( sm->p)) && (*( sm->p)) <= -68 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > -67 ) {
				if ( (*( sm->p)) > -65 ) {
					if ( -64 <= (*( sm->p)) && (*( sm->p)) <= -63 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= -66 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else if ( (*( sm->p)) > -33 ) {
			if ( (*( sm->p)) < -29 ) {
				if ( (*( sm->p)) > -31 ) {
					if ( -30 <= (*( sm->p)) && (*( sm->p)) <= -30 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= -32 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > -29 ) {
				if ( (*( sm->p)) > -18 ) {
					if ( -17 <= (*( sm->p)) && (*( sm->p)) <= -17 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= -28 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else {
			_widec = (short)(640 + ((*( sm->p)) - -128));
			if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
		}
	} else if ( (*( sm->p)) > -12 ) {
		if ( (*( sm->p)) < 43 ) {
			if ( (*( sm->p)) < 14 ) {
				if ( (*( sm->p)) > -1 ) {
					if ( 1 <= (*( sm->p)) && (*( sm->p)) <= 8 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= -11 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > 31 ) {
				if ( (*( sm->p)) > 33 ) {
					if ( 39 <= (*( sm->p)) && (*( sm->p)) <= 39 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= 33 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else if ( (*( sm->p)) > 43 ) {
			if ( (*( sm->p)) < 65 ) {
				if ( (*( sm->p)) > 47 ) {
					if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= 45 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > 90 ) {
				if ( (*( sm->p)) < 97 ) {
					if ( 95 <= (*( sm->p)) && (*( sm->p)) <= 95 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) > 122 ) {
					if ( 127 <= (*( sm->p)) )
 {						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else {
			_widec = (short)(640 + ((*( sm->p)) - -128));
			if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
		}
	} else {
		_widec = (short)(640 + ((*( sm->p)) - -128));
		if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
	}
	switch( _widec ) {
		case 956: goto st679;
		case 957: goto st681;
		case 994: goto st674;
		case 995: goto st676;
		case 1007: goto st678;
		case 1057: goto st671;
		case 1063: goto st671;
		case 1067: goto st671;
		case 1119: goto st671;
		case 1151: goto tr843;
	}
	if ( _widec < 1013 ) {
		if ( _widec < 962 ) {
			if ( _widec > 959 ) {
				if ( 960 <= _widec && _widec <= 961 )
					goto st671;
			} else if ( _widec >= 896 )
				goto st672;
		} else if ( _widec > 991 ) {
			if ( _widec > 1006 ) {
				if ( 1008 <= _widec && _widec <= 1012 )
					goto st680;
			} else if ( _widec >= 992 )
				goto st673;
		} else
			goto st672;
	} else if ( _widec > 1023 ) {
		if ( _widec < 1069 ) {
			if ( _widec > 1032 ) {
				if ( 1038 <= _widec && _widec <= 1055 )
					goto tr843;
			} else if ( _widec >= 1025 )
				goto tr843;
		} else if ( _widec > 1071 ) {
			if ( _widec < 1089 ) {
				if ( 1072 <= _widec && _widec <= 1081 )
					goto tr843;
			} else if ( _widec > 1114 ) {
				if ( 1121 <= _widec && _widec <= 1146 )
					goto tr843;
			} else
				goto tr843;
		} else
			goto st671;
	} else
		goto st671;
	goto tr185;
st679:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof679;
case 679:
	_widec = (*( sm->p));
	if ( (*( sm->p)) < -16 ) {
		if ( (*( sm->p)) < -64 ) {
			if ( (*( sm->p)) < -118 ) {
				if ( (*( sm->p)) > -120 ) {
					if ( -119 <= (*( sm->p)) && (*( sm->p)) <= -119 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > -68 ) {
				if ( (*( sm->p)) > -67 ) {
					if ( -66 <= (*( sm->p)) && (*( sm->p)) <= -65 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= -67 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else if ( (*( sm->p)) > -63 ) {
			if ( (*( sm->p)) < -30 ) {
				if ( (*( sm->p)) > -33 ) {
					if ( -32 <= (*( sm->p)) && (*( sm->p)) <= -31 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= -62 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > -30 ) {
				if ( (*( sm->p)) < -28 ) {
					if ( -29 <= (*( sm->p)) && (*( sm->p)) <= -29 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) > -18 ) {
					if ( -17 <= (*( sm->p)) && (*( sm->p)) <= -17 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else {
			_widec = (short)(640 + ((*( sm->p)) - -128));
			if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
		}
	} else if ( (*( sm->p)) > -12 ) {
		if ( (*( sm->p)) < 43 ) {
			if ( (*( sm->p)) < 14 ) {
				if ( (*( sm->p)) > -1 ) {
					if ( 1 <= (*( sm->p)) && (*( sm->p)) <= 8 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= -11 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > 31 ) {
				if ( (*( sm->p)) > 33 ) {
					if ( 39 <= (*( sm->p)) && (*( sm->p)) <= 39 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= 33 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else if ( (*( sm->p)) > 43 ) {
			if ( (*( sm->p)) < 65 ) {
				if ( (*( sm->p)) > 47 ) {
					if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= 45 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > 90 ) {
				if ( (*( sm->p)) < 97 ) {
					if ( 95 <= (*( sm->p)) && (*( sm->p)) <= 95 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) > 122 ) {
					if ( 127 <= (*( sm->p)) )
 {						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else {
			_widec = (short)(640 + ((*( sm->p)) - -128));
			if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
		}
	} else {
		_widec = (short)(640 + ((*( sm->p)) - -128));
		if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
	}
	switch( _widec ) {
		case 905: goto st671;
		case 957: goto st671;
		case 994: goto st674;
		case 995: goto st676;
		case 1007: goto st678;
		case 1057: goto st671;
		case 1063: goto st671;
		case 1067: goto st671;
		case 1119: goto st671;
		case 1151: goto tr843;
	}
	if ( _widec < 1013 ) {
		if ( _widec < 962 ) {
			if ( _widec > 959 ) {
				if ( 960 <= _widec && _widec <= 961 )
					goto st671;
			} else if ( _widec >= 896 )
				goto tr843;
		} else if ( _widec > 991 ) {
			if ( _widec > 1006 ) {
				if ( 1008 <= _widec && _widec <= 1012 )
					goto st680;
			} else if ( _widec >= 992 )
				goto st673;
		} else
			goto st672;
	} else if ( _widec > 1023 ) {
		if ( _widec < 1069 ) {
			if ( _widec > 1032 ) {
				if ( 1038 <= _widec && _widec <= 1055 )
					goto tr843;
			} else if ( _widec >= 1025 )
				goto tr843;
		} else if ( _widec > 1071 ) {
			if ( _widec < 1089 ) {
				if ( 1072 <= _widec && _widec <= 1081 )
					goto tr843;
			} else if ( _widec > 1114 ) {
				if ( 1121 <= _widec && _widec <= 1146 )
					goto tr843;
			} else
				goto tr843;
		} else
			goto st671;
	} else
		goto st671;
	goto tr185;
st680:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof680;
case 680:
	_widec = (*( sm->p));
	if ( (*( sm->p)) < 1 ) {
		if ( (*( sm->p)) < -30 ) {
			if ( (*( sm->p)) < -64 ) {
				if ( (*( sm->p)) <= -65 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > -63 ) {
				if ( (*( sm->p)) > -33 ) {
					if ( -32 <= (*( sm->p)) && (*( sm->p)) <= -31 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= -62 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else if ( (*( sm->p)) > -30 ) {
			if ( (*( sm->p)) < -17 ) {
				if ( (*( sm->p)) > -29 ) {
					if ( -28 <= (*( sm->p)) && (*( sm->p)) <= -18 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= -29 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > -17 ) {
				if ( (*( sm->p)) > -12 ) {
					if ( -11 <= (*( sm->p)) && (*( sm->p)) <= -1 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= -16 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else {
			_widec = (short)(640 + ((*( sm->p)) - -128));
			if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
		}
	} else if ( (*( sm->p)) > 8 ) {
		if ( (*( sm->p)) < 45 ) {
			if ( (*( sm->p)) < 33 ) {
				if ( 14 <= (*( sm->p)) && (*( sm->p)) <= 31 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > 33 ) {
				if ( (*( sm->p)) > 39 ) {
					if ( 43 <= (*( sm->p)) && (*( sm->p)) <= 43 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= 39 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else if ( (*( sm->p)) > 47 ) {
			if ( (*( sm->p)) < 95 ) {
				if ( (*( sm->p)) > 57 ) {
					if ( 65 <= (*( sm->p)) && (*( sm->p)) <= 90 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= 48 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > 95 ) {
				if ( (*( sm->p)) > 122 ) {
					if ( 127 <= (*( sm->p)) )
 {						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= 97 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else {
			_widec = (short)(640 + ((*( sm->p)) - -128));
			if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
		}
	} else {
		_widec = (short)(640 + ((*( sm->p)) - -128));
		if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
	}
	switch( _widec ) {
		case 994: goto st674;
		case 995: goto st676;
		case 1007: goto st678;
		case 1057: goto st671;
		case 1063: goto st671;
		case 1067: goto st671;
		case 1119: goto st671;
		case 1151: goto tr843;
	}
	if ( _widec < 1013 ) {
		if ( _widec < 962 ) {
			if ( _widec > 959 ) {
				if ( 960 <= _widec && _widec <= 961 )
					goto st671;
			} else if ( _widec >= 896 )
				goto st673;
		} else if ( _widec > 991 ) {
			if ( _widec > 1006 ) {
				if ( 1008 <= _widec && _widec <= 1012 )
					goto st680;
			} else if ( _widec >= 992 )
				goto st673;
		} else
			goto st672;
	} else if ( _widec > 1023 ) {
		if ( _widec < 1069 ) {
			if ( _widec > 1032 ) {
				if ( 1038 <= _widec && _widec <= 1055 )
					goto tr843;
			} else if ( _widec >= 1025 )
				goto tr843;
		} else if ( _widec > 1071 ) {
			if ( _widec < 1089 ) {
				if ( 1072 <= _widec && _widec <= 1081 )
					goto tr843;
			} else if ( _widec > 1114 ) {
				if ( 1121 <= _widec && _widec <= 1146 )
					goto tr843;
			} else
				goto tr843;
		} else
			goto st671;
	} else
		goto st671;
	goto tr185;
st681:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof681;
case 681:
	_widec = (*( sm->p));
	if ( (*( sm->p)) < -17 ) {
		if ( (*( sm->p)) < -92 ) {
			if ( (*( sm->p)) < -98 ) {
				if ( (*( sm->p)) > -100 ) {
					if ( -99 <= (*( sm->p)) && (*( sm->p)) <= -99 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > -97 ) {
				if ( (*( sm->p)) < -95 ) {
					if ( -96 <= (*( sm->p)) && (*( sm->p)) <= -96 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) > -94 ) {
					if ( -93 <= (*( sm->p)) && (*( sm->p)) <= -93 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else if ( (*( sm->p)) > -65 ) {
			if ( (*( sm->p)) < -32 ) {
				if ( (*( sm->p)) > -63 ) {
					if ( -62 <= (*( sm->p)) && (*( sm->p)) <= -33 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= -64 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > -31 ) {
				if ( (*( sm->p)) < -29 ) {
					if ( -30 <= (*( sm->p)) && (*( sm->p)) <= -30 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) > -29 ) {
					if ( -28 <= (*( sm->p)) && (*( sm->p)) <= -18 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else {
			_widec = (short)(640 + ((*( sm->p)) - -128));
			if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
		}
	} else if ( (*( sm->p)) > -17 ) {
		if ( (*( sm->p)) < 43 ) {
			if ( (*( sm->p)) < 1 ) {
				if ( (*( sm->p)) > -12 ) {
					if ( -11 <= (*( sm->p)) && (*( sm->p)) <= -1 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= -16 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > 8 ) {
				if ( (*( sm->p)) < 33 ) {
					if ( 14 <= (*( sm->p)) && (*( sm->p)) <= 31 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) > 33 ) {
					if ( 39 <= (*( sm->p)) && (*( sm->p)) <= 39 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else if ( (*( sm->p)) > 43 ) {
			if ( (*( sm->p)) < 65 ) {
				if ( (*( sm->p)) > 47 ) {
					if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= 45 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > 90 ) {
				if ( (*( sm->p)) < 97 ) {
					if ( 95 <= (*( sm->p)) && (*( sm->p)) <= 95 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) > 122 ) {
					if ( 127 <= (*( sm->p)) )
 {						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else {
			_widec = (short)(640 + ((*( sm->p)) - -128));
			if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
		}
	} else {
		_widec = (short)(640 + ((*( sm->p)) - -128));
		if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
	}
	switch( _widec ) {
		case 925: goto st671;
		case 928: goto st671;
		case 931: goto st671;
		case 994: goto st674;
		case 995: goto st676;
		case 1007: goto st678;
		case 1057: goto st671;
		case 1063: goto st671;
		case 1067: goto st671;
		case 1119: goto st671;
		case 1151: goto tr843;
	}
	if ( _widec < 1013 ) {
		if ( _widec < 962 ) {
			if ( _widec > 959 ) {
				if ( 960 <= _widec && _widec <= 961 )
					goto st671;
			} else if ( _widec >= 896 )
				goto tr843;
		} else if ( _widec > 991 ) {
			if ( _widec > 1006 ) {
				if ( 1008 <= _widec && _widec <= 1012 )
					goto st680;
			} else if ( _widec >= 992 )
				goto st673;
		} else
			goto st672;
	} else if ( _widec > 1023 ) {
		if ( _widec < 1069 ) {
			if ( _widec > 1032 ) {
				if ( 1038 <= _widec && _widec <= 1055 )
					goto tr843;
			} else if ( _widec >= 1025 )
				goto tr843;
		} else if ( _widec > 1071 ) {
			if ( _widec < 1089 ) {
				if ( 1072 <= _widec && _widec <= 1081 )
					goto tr843;
			} else if ( _widec > 1114 ) {
				if ( 1121 <= _widec && _widec <= 1146 )
					goto tr843;
			} else
				goto tr843;
		} else
			goto st671;
	} else
		goto st671;
	goto tr185;
st682:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof682;
case 682:
	_widec = (*( sm->p));
	if ( (*( sm->p)) < 1 ) {
		if ( (*( sm->p)) < -30 ) {
			if ( (*( sm->p)) < -64 ) {
				if ( (*( sm->p)) <= -65 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > -63 ) {
				if ( (*( sm->p)) > -33 ) {
					if ( -32 <= (*( sm->p)) && (*( sm->p)) <= -31 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= -62 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else if ( (*( sm->p)) > -30 ) {
			if ( (*( sm->p)) < -17 ) {
				if ( (*( sm->p)) > -29 ) {
					if ( -28 <= (*( sm->p)) && (*( sm->p)) <= -18 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= -29 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > -17 ) {
				if ( (*( sm->p)) > -12 ) {
					if ( -11 <= (*( sm->p)) && (*( sm->p)) <= -1 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= -16 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else {
			_widec = (short)(640 + ((*( sm->p)) - -128));
			if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
		}
	} else if ( (*( sm->p)) > 8 ) {
		if ( (*( sm->p)) < 45 ) {
			if ( (*( sm->p)) < 33 ) {
				if ( 14 <= (*( sm->p)) && (*( sm->p)) <= 31 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > 33 ) {
				if ( (*( sm->p)) > 39 ) {
					if ( 43 <= (*( sm->p)) && (*( sm->p)) <= 43 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= 39 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else if ( (*( sm->p)) > 47 ) {
			if ( (*( sm->p)) < 95 ) {
				if ( (*( sm->p)) > 57 ) {
					if ( 65 <= (*( sm->p)) && (*( sm->p)) <= 90 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= 48 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > 95 ) {
				if ( (*( sm->p)) > 122 ) {
					if ( 127 <= (*( sm->p)) )
 {						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= 97 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else {
			_widec = (short)(640 + ((*( sm->p)) - -128));
			if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
		}
	} else {
		_widec = (short)(640 + ((*( sm->p)) - -128));
		if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
	}
	switch( _widec ) {
		case 994: goto st674;
		case 995: goto st676;
		case 1007: goto st678;
		case 1057: goto st671;
		case 1063: goto st671;
		case 1067: goto st671;
		case 1119: goto st671;
		case 1151: goto tr843;
	}
	if ( _widec < 1013 ) {
		if ( _widec < 962 ) {
			if ( _widec > 959 ) {
				if ( 960 <= _widec && _widec <= 961 )
					goto st671;
			} else if ( _widec >= 896 )
				goto tr835;
		} else if ( _widec > 991 ) {
			if ( _widec > 1006 ) {
				if ( 1008 <= _widec && _widec <= 1012 )
					goto st680;
			} else if ( _widec >= 992 )
				goto st673;
		} else
			goto st672;
	} else if ( _widec > 1023 ) {
		if ( _widec < 1069 ) {
			if ( _widec > 1032 ) {
				if ( 1038 <= _widec && _widec <= 1055 )
					goto tr843;
			} else if ( _widec >= 1025 )
				goto tr843;
		} else if ( _widec > 1071 ) {
			if ( _widec < 1089 ) {
				if ( 1072 <= _widec && _widec <= 1081 )
					goto tr843;
			} else if ( _widec > 1114 ) {
				if ( 1121 <= _widec && _widec <= 1146 )
					goto tr843;
			} else
				goto tr843;
		} else
			goto st671;
	} else
		goto st671;
	goto tr185;
tr835:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 118 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
#line 386 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 56;}
	goto st1232;
st1232:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1232;
case 1232:
#line 20490 "ext/dtext/dtext.cpp"
	_widec = (*( sm->p));
	if ( (*( sm->p)) < 1 ) {
		if ( (*( sm->p)) < -29 ) {
			if ( (*( sm->p)) < -62 ) {
				if ( (*( sm->p)) <= -63 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > -33 ) {
				if ( (*( sm->p)) > -31 ) {
					if ( -30 <= (*( sm->p)) && (*( sm->p)) <= -30 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= -32 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else if ( (*( sm->p)) > -29 ) {
			if ( (*( sm->p)) < -17 ) {
				if ( -28 <= (*( sm->p)) && (*( sm->p)) <= -18 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > -17 ) {
				if ( (*( sm->p)) > -12 ) {
					if ( -11 <= (*( sm->p)) && (*( sm->p)) <= -1 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= -16 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else {
			_widec = (short)(640 + ((*( sm->p)) - -128));
			if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
		}
	} else if ( (*( sm->p)) > 8 ) {
		if ( (*( sm->p)) < 45 ) {
			if ( (*( sm->p)) < 33 ) {
				if ( 14 <= (*( sm->p)) && (*( sm->p)) <= 31 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > 33 ) {
				if ( (*( sm->p)) > 39 ) {
					if ( 43 <= (*( sm->p)) && (*( sm->p)) <= 43 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= 39 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else if ( (*( sm->p)) > 47 ) {
			if ( (*( sm->p)) < 95 ) {
				if ( (*( sm->p)) > 57 ) {
					if ( 65 <= (*( sm->p)) && (*( sm->p)) <= 90 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= 48 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > 95 ) {
				if ( (*( sm->p)) > 122 ) {
					if ( 127 <= (*( sm->p)) )
 {						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= 97 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else {
			_widec = (short)(640 + ((*( sm->p)) - -128));
			if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
		}
	} else {
		_widec = (short)(640 + ((*( sm->p)) - -128));
		if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
	}
	switch( _widec ) {
		case 994: goto st684;
		case 995: goto st686;
		case 1007: goto st688;
		case 1057: goto st670;
		case 1063: goto st692;
		case 1067: goto st670;
		case 1119: goto st670;
		case 1151: goto tr835;
	}
	if ( _widec < 1025 ) {
		if ( _widec < 992 ) {
			if ( _widec > 961 ) {
				if ( 962 <= _widec && _widec <= 991 )
					goto st682;
			} else if ( _widec >= 896 )
				goto st671;
		} else if ( _widec > 1006 ) {
			if ( _widec > 1012 ) {
				if ( 1013 <= _widec && _widec <= 1023 )
					goto st671;
			} else if ( _widec >= 1008 )
				goto st691;
		} else
			goto st683;
	} else if ( _widec > 1032 ) {
		if ( _widec < 1072 ) {
			if ( _widec > 1055 ) {
				if ( 1069 <= _widec && _widec <= 1071 )
					goto st670;
			} else if ( _widec >= 1038 )
				goto tr835;
		} else if ( _widec > 1081 ) {
			if ( _widec > 1114 ) {
				if ( 1121 <= _widec && _widec <= 1146 )
					goto tr835;
			} else if ( _widec >= 1089 )
				goto tr835;
		} else
			goto tr835;
	} else
		goto tr835;
	goto tr1682;
st683:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof683;
case 683:
	_widec = (*( sm->p));
	if ( (*( sm->p)) < 1 ) {
		if ( (*( sm->p)) < -30 ) {
			if ( (*( sm->p)) < -64 ) {
				if ( (*( sm->p)) <= -65 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > -63 ) {
				if ( (*( sm->p)) > -33 ) {
					if ( -32 <= (*( sm->p)) && (*( sm->p)) <= -31 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= -62 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else if ( (*( sm->p)) > -30 ) {
			if ( (*( sm->p)) < -17 ) {
				if ( (*( sm->p)) > -29 ) {
					if ( -28 <= (*( sm->p)) && (*( sm->p)) <= -18 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= -29 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > -17 ) {
				if ( (*( sm->p)) > -12 ) {
					if ( -11 <= (*( sm->p)) && (*( sm->p)) <= -1 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= -16 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else {
			_widec = (short)(640 + ((*( sm->p)) - -128));
			if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
		}
	} else if ( (*( sm->p)) > 8 ) {
		if ( (*( sm->p)) < 45 ) {
			if ( (*( sm->p)) < 33 ) {
				if ( 14 <= (*( sm->p)) && (*( sm->p)) <= 31 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > 33 ) {
				if ( (*( sm->p)) > 39 ) {
					if ( 43 <= (*( sm->p)) && (*( sm->p)) <= 43 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= 39 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else if ( (*( sm->p)) > 47 ) {
			if ( (*( sm->p)) < 95 ) {
				if ( (*( sm->p)) > 57 ) {
					if ( 65 <= (*( sm->p)) && (*( sm->p)) <= 90 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= 48 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > 95 ) {
				if ( (*( sm->p)) > 122 ) {
					if ( 127 <= (*( sm->p)) )
 {						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= 97 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else {
			_widec = (short)(640 + ((*( sm->p)) - -128));
			if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
		}
	} else {
		_widec = (short)(640 + ((*( sm->p)) - -128));
		if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
	}
	switch( _widec ) {
		case 994: goto st674;
		case 995: goto st676;
		case 1007: goto st678;
		case 1057: goto st671;
		case 1063: goto st671;
		case 1067: goto st671;
		case 1119: goto st671;
		case 1151: goto tr843;
	}
	if ( _widec < 1013 ) {
		if ( _widec < 962 ) {
			if ( _widec > 959 ) {
				if ( 960 <= _widec && _widec <= 961 )
					goto st671;
			} else if ( _widec >= 896 )
				goto st682;
		} else if ( _widec > 991 ) {
			if ( _widec > 1006 ) {
				if ( 1008 <= _widec && _widec <= 1012 )
					goto st680;
			} else if ( _widec >= 992 )
				goto st673;
		} else
			goto st672;
	} else if ( _widec > 1023 ) {
		if ( _widec < 1069 ) {
			if ( _widec > 1032 ) {
				if ( 1038 <= _widec && _widec <= 1055 )
					goto tr843;
			} else if ( _widec >= 1025 )
				goto tr843;
		} else if ( _widec > 1071 ) {
			if ( _widec < 1089 ) {
				if ( 1072 <= _widec && _widec <= 1081 )
					goto tr843;
			} else if ( _widec > 1114 ) {
				if ( 1121 <= _widec && _widec <= 1146 )
					goto tr843;
			} else
				goto tr843;
		} else
			goto st671;
	} else
		goto st671;
	goto tr185;
st684:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof684;
case 684:
	_widec = (*( sm->p));
	if ( (*( sm->p)) < -11 ) {
		if ( (*( sm->p)) < -32 ) {
			if ( (*( sm->p)) < -98 ) {
				if ( (*( sm->p)) > -100 ) {
					if ( -99 <= (*( sm->p)) && (*( sm->p)) <= -99 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > -65 ) {
				if ( (*( sm->p)) > -63 ) {
					if ( -62 <= (*( sm->p)) && (*( sm->p)) <= -33 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= -64 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else if ( (*( sm->p)) > -31 ) {
			if ( (*( sm->p)) < -28 ) {
				if ( (*( sm->p)) > -30 ) {
					if ( -29 <= (*( sm->p)) && (*( sm->p)) <= -29 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= -30 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > -18 ) {
				if ( (*( sm->p)) > -17 ) {
					if ( -16 <= (*( sm->p)) && (*( sm->p)) <= -12 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= -17 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else {
			_widec = (short)(640 + ((*( sm->p)) - -128));
			if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
		}
	} else if ( (*( sm->p)) > -1 ) {
		if ( (*( sm->p)) < 45 ) {
			if ( (*( sm->p)) < 33 ) {
				if ( (*( sm->p)) > 8 ) {
					if ( 14 <= (*( sm->p)) && (*( sm->p)) <= 31 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= 1 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > 33 ) {
				if ( (*( sm->p)) > 39 ) {
					if ( 43 <= (*( sm->p)) && (*( sm->p)) <= 43 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= 39 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else if ( (*( sm->p)) > 47 ) {
			if ( (*( sm->p)) < 95 ) {
				if ( (*( sm->p)) > 57 ) {
					if ( 65 <= (*( sm->p)) && (*( sm->p)) <= 90 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= 48 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > 95 ) {
				if ( (*( sm->p)) > 122 ) {
					if ( 127 <= (*( sm->p)) )
 {						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= 97 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else {
			_widec = (short)(640 + ((*( sm->p)) - -128));
			if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
		}
	} else {
		_widec = (short)(640 + ((*( sm->p)) - -128));
		if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
	}
	switch( _widec ) {
		case 925: goto st685;
		case 994: goto st674;
		case 995: goto st676;
		case 1007: goto st678;
		case 1057: goto st671;
		case 1063: goto st671;
		case 1067: goto st671;
		case 1119: goto st671;
		case 1151: goto tr843;
	}
	if ( _widec < 1013 ) {
		if ( _widec < 962 ) {
			if ( _widec > 959 ) {
				if ( 960 <= _widec && _widec <= 961 )
					goto st671;
			} else if ( _widec >= 896 )
				goto st682;
		} else if ( _widec > 991 ) {
			if ( _widec > 1006 ) {
				if ( 1008 <= _widec && _widec <= 1012 )
					goto st680;
			} else if ( _widec >= 992 )
				goto st673;
		} else
			goto st672;
	} else if ( _widec > 1023 ) {
		if ( _widec < 1069 ) {
			if ( _widec > 1032 ) {
				if ( 1038 <= _widec && _widec <= 1055 )
					goto tr843;
			} else if ( _widec >= 1025 )
				goto tr843;
		} else if ( _widec > 1071 ) {
			if ( _widec < 1089 ) {
				if ( 1072 <= _widec && _widec <= 1081 )
					goto tr843;
			} else if ( _widec > 1114 ) {
				if ( 1121 <= _widec && _widec <= 1146 )
					goto tr843;
			} else
				goto tr843;
		} else
			goto st671;
	} else
		goto st671;
	goto tr185;
st685:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof685;
case 685:
	_widec = (*( sm->p));
	if ( (*( sm->p)) < -11 ) {
		if ( (*( sm->p)) < -32 ) {
			if ( (*( sm->p)) < -82 ) {
				if ( (*( sm->p)) > -84 ) {
					if ( -83 <= (*( sm->p)) && (*( sm->p)) <= -83 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > -65 ) {
				if ( (*( sm->p)) > -63 ) {
					if ( -62 <= (*( sm->p)) && (*( sm->p)) <= -33 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= -64 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else if ( (*( sm->p)) > -31 ) {
			if ( (*( sm->p)) < -28 ) {
				if ( (*( sm->p)) > -30 ) {
					if ( -29 <= (*( sm->p)) && (*( sm->p)) <= -29 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= -30 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > -18 ) {
				if ( (*( sm->p)) > -17 ) {
					if ( -16 <= (*( sm->p)) && (*( sm->p)) <= -12 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= -17 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else {
			_widec = (short)(640 + ((*( sm->p)) - -128));
			if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
		}
	} else if ( (*( sm->p)) > -1 ) {
		if ( (*( sm->p)) < 45 ) {
			if ( (*( sm->p)) < 33 ) {
				if ( (*( sm->p)) > 8 ) {
					if ( 14 <= (*( sm->p)) && (*( sm->p)) <= 31 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= 1 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > 33 ) {
				if ( (*( sm->p)) > 39 ) {
					if ( 43 <= (*( sm->p)) && (*( sm->p)) <= 43 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= 39 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else if ( (*( sm->p)) > 47 ) {
			if ( (*( sm->p)) < 95 ) {
				if ( (*( sm->p)) > 57 ) {
					if ( 65 <= (*( sm->p)) && (*( sm->p)) <= 90 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= 48 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > 95 ) {
				if ( (*( sm->p)) > 122 ) {
					if ( 127 <= (*( sm->p)) )
 {						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= 97 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else {
			_widec = (short)(640 + ((*( sm->p)) - -128));
			if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
		}
	} else {
		_widec = (short)(640 + ((*( sm->p)) - -128));
		if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
	}
	switch( _widec ) {
		case 941: goto st670;
		case 994: goto st674;
		case 995: goto st676;
		case 1007: goto st678;
		case 1057: goto st671;
		case 1063: goto st671;
		case 1067: goto st671;
		case 1119: goto st671;
		case 1151: goto tr843;
	}
	if ( _widec < 1013 ) {
		if ( _widec < 962 ) {
			if ( _widec > 959 ) {
				if ( 960 <= _widec && _widec <= 961 )
					goto st671;
			} else if ( _widec >= 896 )
				goto tr835;
		} else if ( _widec > 991 ) {
			if ( _widec > 1006 ) {
				if ( 1008 <= _widec && _widec <= 1012 )
					goto st680;
			} else if ( _widec >= 992 )
				goto st673;
		} else
			goto st672;
	} else if ( _widec > 1023 ) {
		if ( _widec < 1069 ) {
			if ( _widec > 1032 ) {
				if ( 1038 <= _widec && _widec <= 1055 )
					goto tr843;
			} else if ( _widec >= 1025 )
				goto tr843;
		} else if ( _widec > 1071 ) {
			if ( _widec < 1089 ) {
				if ( 1072 <= _widec && _widec <= 1081 )
					goto tr843;
			} else if ( _widec > 1114 ) {
				if ( 1121 <= _widec && _widec <= 1146 )
					goto tr843;
			} else
				goto tr843;
		} else
			goto st671;
	} else
		goto st671;
	goto tr185;
st686:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof686;
case 686:
	_widec = (*( sm->p));
	if ( (*( sm->p)) < -11 ) {
		if ( (*( sm->p)) < -32 ) {
			if ( (*( sm->p)) < -127 ) {
				if ( (*( sm->p)) <= -128 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > -65 ) {
				if ( (*( sm->p)) > -63 ) {
					if ( -62 <= (*( sm->p)) && (*( sm->p)) <= -33 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= -64 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else if ( (*( sm->p)) > -31 ) {
			if ( (*( sm->p)) < -28 ) {
				if ( (*( sm->p)) > -30 ) {
					if ( -29 <= (*( sm->p)) && (*( sm->p)) <= -29 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= -30 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > -18 ) {
				if ( (*( sm->p)) > -17 ) {
					if ( -16 <= (*( sm->p)) && (*( sm->p)) <= -12 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= -17 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else {
			_widec = (short)(640 + ((*( sm->p)) - -128));
			if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
		}
	} else if ( (*( sm->p)) > -1 ) {
		if ( (*( sm->p)) < 45 ) {
			if ( (*( sm->p)) < 33 ) {
				if ( (*( sm->p)) > 8 ) {
					if ( 14 <= (*( sm->p)) && (*( sm->p)) <= 31 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= 1 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > 33 ) {
				if ( (*( sm->p)) > 39 ) {
					if ( 43 <= (*( sm->p)) && (*( sm->p)) <= 43 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= 39 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else if ( (*( sm->p)) > 47 ) {
			if ( (*( sm->p)) < 95 ) {
				if ( (*( sm->p)) > 57 ) {
					if ( 65 <= (*( sm->p)) && (*( sm->p)) <= 90 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= 48 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > 95 ) {
				if ( (*( sm->p)) > 122 ) {
					if ( 127 <= (*( sm->p)) )
 {						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= 97 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else {
			_widec = (short)(640 + ((*( sm->p)) - -128));
			if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
		}
	} else {
		_widec = (short)(640 + ((*( sm->p)) - -128));
		if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
	}
	switch( _widec ) {
		case 896: goto st687;
		case 994: goto st674;
		case 995: goto st676;
		case 1007: goto st678;
		case 1057: goto st671;
		case 1063: goto st671;
		case 1067: goto st671;
		case 1119: goto st671;
		case 1151: goto tr843;
	}
	if ( _widec < 1013 ) {
		if ( _widec < 962 ) {
			if ( _widec > 959 ) {
				if ( 960 <= _widec && _widec <= 961 )
					goto st671;
			} else if ( _widec >= 897 )
				goto st682;
		} else if ( _widec > 991 ) {
			if ( _widec > 1006 ) {
				if ( 1008 <= _widec && _widec <= 1012 )
					goto st680;
			} else if ( _widec >= 992 )
				goto st673;
		} else
			goto st672;
	} else if ( _widec > 1023 ) {
		if ( _widec < 1069 ) {
			if ( _widec > 1032 ) {
				if ( 1038 <= _widec && _widec <= 1055 )
					goto tr843;
			} else if ( _widec >= 1025 )
				goto tr843;
		} else if ( _widec > 1071 ) {
			if ( _widec < 1089 ) {
				if ( 1072 <= _widec && _widec <= 1081 )
					goto tr843;
			} else if ( _widec > 1114 ) {
				if ( 1121 <= _widec && _widec <= 1146 )
					goto tr843;
			} else
				goto tr843;
		} else
			goto st671;
	} else
		goto st671;
	goto tr185;
st687:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof687;
case 687:
	_widec = (*( sm->p));
	if ( (*( sm->p)) < -17 ) {
		if ( (*( sm->p)) < -99 ) {
			if ( (*( sm->p)) < -120 ) {
				if ( (*( sm->p)) > -126 ) {
					if ( -125 <= (*( sm->p)) && (*( sm->p)) <= -121 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > -111 ) {
				if ( (*( sm->p)) > -109 ) {
					if ( -108 <= (*( sm->p)) && (*( sm->p)) <= -100 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= -110 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else if ( (*( sm->p)) > -65 ) {
			if ( (*( sm->p)) < -32 ) {
				if ( (*( sm->p)) > -63 ) {
					if ( -62 <= (*( sm->p)) && (*( sm->p)) <= -33 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= -64 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > -31 ) {
				if ( (*( sm->p)) < -29 ) {
					if ( -30 <= (*( sm->p)) && (*( sm->p)) <= -30 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) > -29 ) {
					if ( -28 <= (*( sm->p)) && (*( sm->p)) <= -18 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else {
			_widec = (short)(640 + ((*( sm->p)) - -128));
			if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
		}
	} else if ( (*( sm->p)) > -17 ) {
		if ( (*( sm->p)) < 43 ) {
			if ( (*( sm->p)) < 1 ) {
				if ( (*( sm->p)) > -12 ) {
					if ( -11 <= (*( sm->p)) && (*( sm->p)) <= -1 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= -16 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > 8 ) {
				if ( (*( sm->p)) < 33 ) {
					if ( 14 <= (*( sm->p)) && (*( sm->p)) <= 31 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) > 33 ) {
					if ( 39 <= (*( sm->p)) && (*( sm->p)) <= 39 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else if ( (*( sm->p)) > 43 ) {
			if ( (*( sm->p)) < 65 ) {
				if ( (*( sm->p)) > 47 ) {
					if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= 45 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > 90 ) {
				if ( (*( sm->p)) < 97 ) {
					if ( 95 <= (*( sm->p)) && (*( sm->p)) <= 95 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) > 122 ) {
					if ( 127 <= (*( sm->p)) )
 {						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else {
			_widec = (short)(640 + ((*( sm->p)) - -128));
			if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
		}
	} else {
		_widec = (short)(640 + ((*( sm->p)) - -128));
		if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
	}
	switch( _widec ) {
		case 994: goto st674;
		case 995: goto st676;
		case 1007: goto st678;
		case 1057: goto st671;
		case 1063: goto st671;
		case 1067: goto st671;
		case 1119: goto st671;
		case 1151: goto tr843;
	}
	if ( _widec < 992 ) {
		if ( _widec < 914 ) {
			if ( _widec < 899 ) {
				if ( 896 <= _widec && _widec <= 898 )
					goto st670;
			} else if ( _widec > 903 ) {
				if ( 904 <= _widec && _widec <= 913 )
					goto st670;
			} else
				goto tr835;
		} else if ( _widec > 915 ) {
			if ( _widec < 925 ) {
				if ( 916 <= _widec && _widec <= 924 )
					goto st670;
			} else if ( _widec > 959 ) {
				if ( _widec > 961 ) {
					if ( 962 <= _widec && _widec <= 991 )
						goto st672;
				} else if ( _widec >= 960 )
					goto st671;
			} else
				goto tr835;
		} else
			goto tr835;
	} else if ( _widec > 1006 ) {
		if ( _widec < 1038 ) {
			if ( _widec < 1013 ) {
				if ( 1008 <= _widec && _widec <= 1012 )
					goto st680;
			} else if ( _widec > 1023 ) {
				if ( 1025 <= _widec && _widec <= 1032 )
					goto tr843;
			} else
				goto st671;
		} else if ( _widec > 1055 ) {
			if ( _widec < 1072 ) {
				if ( 1069 <= _widec && _widec <= 1071 )
					goto st671;
			} else if ( _widec > 1081 ) {
				if ( _widec > 1114 ) {
					if ( 1121 <= _widec && _widec <= 1146 )
						goto tr843;
				} else if ( _widec >= 1089 )
					goto tr843;
			} else
				goto tr843;
		} else
			goto tr843;
	} else
		goto st673;
	goto tr185;
st688:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof688;
case 688:
	_widec = (*( sm->p));
	if ( (*( sm->p)) < -16 ) {
		if ( (*( sm->p)) < -62 ) {
			if ( (*( sm->p)) < -67 ) {
				if ( (*( sm->p)) > -69 ) {
					if ( -68 <= (*( sm->p)) && (*( sm->p)) <= -68 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > -67 ) {
				if ( (*( sm->p)) > -65 ) {
					if ( -64 <= (*( sm->p)) && (*( sm->p)) <= -63 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= -66 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else if ( (*( sm->p)) > -33 ) {
			if ( (*( sm->p)) < -29 ) {
				if ( (*( sm->p)) > -31 ) {
					if ( -30 <= (*( sm->p)) && (*( sm->p)) <= -30 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= -32 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > -29 ) {
				if ( (*( sm->p)) > -18 ) {
					if ( -17 <= (*( sm->p)) && (*( sm->p)) <= -17 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= -28 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else {
			_widec = (short)(640 + ((*( sm->p)) - -128));
			if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
		}
	} else if ( (*( sm->p)) > -12 ) {
		if ( (*( sm->p)) < 43 ) {
			if ( (*( sm->p)) < 14 ) {
				if ( (*( sm->p)) > -1 ) {
					if ( 1 <= (*( sm->p)) && (*( sm->p)) <= 8 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= -11 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > 31 ) {
				if ( (*( sm->p)) > 33 ) {
					if ( 39 <= (*( sm->p)) && (*( sm->p)) <= 39 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= 33 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else if ( (*( sm->p)) > 43 ) {
			if ( (*( sm->p)) < 65 ) {
				if ( (*( sm->p)) > 47 ) {
					if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= 45 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > 90 ) {
				if ( (*( sm->p)) < 97 ) {
					if ( 95 <= (*( sm->p)) && (*( sm->p)) <= 95 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) > 122 ) {
					if ( 127 <= (*( sm->p)) )
 {						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else {
			_widec = (short)(640 + ((*( sm->p)) - -128));
			if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
		}
	} else {
		_widec = (short)(640 + ((*( sm->p)) - -128));
		if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
	}
	switch( _widec ) {
		case 956: goto st689;
		case 957: goto st690;
		case 994: goto st674;
		case 995: goto st676;
		case 1007: goto st678;
		case 1057: goto st671;
		case 1063: goto st671;
		case 1067: goto st671;
		case 1119: goto st671;
		case 1151: goto tr843;
	}
	if ( _widec < 1013 ) {
		if ( _widec < 962 ) {
			if ( _widec > 959 ) {
				if ( 960 <= _widec && _widec <= 961 )
					goto st671;
			} else if ( _widec >= 896 )
				goto st682;
		} else if ( _widec > 991 ) {
			if ( _widec > 1006 ) {
				if ( 1008 <= _widec && _widec <= 1012 )
					goto st680;
			} else if ( _widec >= 992 )
				goto st673;
		} else
			goto st672;
	} else if ( _widec > 1023 ) {
		if ( _widec < 1069 ) {
			if ( _widec > 1032 ) {
				if ( 1038 <= _widec && _widec <= 1055 )
					goto tr843;
			} else if ( _widec >= 1025 )
				goto tr843;
		} else if ( _widec > 1071 ) {
			if ( _widec < 1089 ) {
				if ( 1072 <= _widec && _widec <= 1081 )
					goto tr843;
			} else if ( _widec > 1114 ) {
				if ( 1121 <= _widec && _widec <= 1146 )
					goto tr843;
			} else
				goto tr843;
		} else
			goto st671;
	} else
		goto st671;
	goto tr185;
st689:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof689;
case 689:
	_widec = (*( sm->p));
	if ( (*( sm->p)) < -16 ) {
		if ( (*( sm->p)) < -64 ) {
			if ( (*( sm->p)) < -118 ) {
				if ( (*( sm->p)) > -120 ) {
					if ( -119 <= (*( sm->p)) && (*( sm->p)) <= -119 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > -68 ) {
				if ( (*( sm->p)) > -67 ) {
					if ( -66 <= (*( sm->p)) && (*( sm->p)) <= -65 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= -67 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else if ( (*( sm->p)) > -63 ) {
			if ( (*( sm->p)) < -30 ) {
				if ( (*( sm->p)) > -33 ) {
					if ( -32 <= (*( sm->p)) && (*( sm->p)) <= -31 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= -62 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > -30 ) {
				if ( (*( sm->p)) < -28 ) {
					if ( -29 <= (*( sm->p)) && (*( sm->p)) <= -29 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) > -18 ) {
					if ( -17 <= (*( sm->p)) && (*( sm->p)) <= -17 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else {
			_widec = (short)(640 + ((*( sm->p)) - -128));
			if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
		}
	} else if ( (*( sm->p)) > -12 ) {
		if ( (*( sm->p)) < 43 ) {
			if ( (*( sm->p)) < 14 ) {
				if ( (*( sm->p)) > -1 ) {
					if ( 1 <= (*( sm->p)) && (*( sm->p)) <= 8 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= -11 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > 31 ) {
				if ( (*( sm->p)) > 33 ) {
					if ( 39 <= (*( sm->p)) && (*( sm->p)) <= 39 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= 33 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else if ( (*( sm->p)) > 43 ) {
			if ( (*( sm->p)) < 65 ) {
				if ( (*( sm->p)) > 47 ) {
					if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= 45 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > 90 ) {
				if ( (*( sm->p)) < 97 ) {
					if ( 95 <= (*( sm->p)) && (*( sm->p)) <= 95 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) > 122 ) {
					if ( 127 <= (*( sm->p)) )
 {						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else {
			_widec = (short)(640 + ((*( sm->p)) - -128));
			if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
		}
	} else {
		_widec = (short)(640 + ((*( sm->p)) - -128));
		if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
	}
	switch( _widec ) {
		case 905: goto st670;
		case 957: goto st670;
		case 994: goto st674;
		case 995: goto st676;
		case 1007: goto st678;
		case 1057: goto st671;
		case 1063: goto st671;
		case 1067: goto st671;
		case 1119: goto st671;
		case 1151: goto tr843;
	}
	if ( _widec < 1013 ) {
		if ( _widec < 962 ) {
			if ( _widec > 959 ) {
				if ( 960 <= _widec && _widec <= 961 )
					goto st671;
			} else if ( _widec >= 896 )
				goto tr835;
		} else if ( _widec > 991 ) {
			if ( _widec > 1006 ) {
				if ( 1008 <= _widec && _widec <= 1012 )
					goto st680;
			} else if ( _widec >= 992 )
				goto st673;
		} else
			goto st672;
	} else if ( _widec > 1023 ) {
		if ( _widec < 1069 ) {
			if ( _widec > 1032 ) {
				if ( 1038 <= _widec && _widec <= 1055 )
					goto tr843;
			} else if ( _widec >= 1025 )
				goto tr843;
		} else if ( _widec > 1071 ) {
			if ( _widec < 1089 ) {
				if ( 1072 <= _widec && _widec <= 1081 )
					goto tr843;
			} else if ( _widec > 1114 ) {
				if ( 1121 <= _widec && _widec <= 1146 )
					goto tr843;
			} else
				goto tr843;
		} else
			goto st671;
	} else
		goto st671;
	goto tr185;
st690:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof690;
case 690:
	_widec = (*( sm->p));
	if ( (*( sm->p)) < -17 ) {
		if ( (*( sm->p)) < -92 ) {
			if ( (*( sm->p)) < -98 ) {
				if ( (*( sm->p)) > -100 ) {
					if ( -99 <= (*( sm->p)) && (*( sm->p)) <= -99 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > -97 ) {
				if ( (*( sm->p)) < -95 ) {
					if ( -96 <= (*( sm->p)) && (*( sm->p)) <= -96 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) > -94 ) {
					if ( -93 <= (*( sm->p)) && (*( sm->p)) <= -93 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else if ( (*( sm->p)) > -65 ) {
			if ( (*( sm->p)) < -32 ) {
				if ( (*( sm->p)) > -63 ) {
					if ( -62 <= (*( sm->p)) && (*( sm->p)) <= -33 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= -64 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > -31 ) {
				if ( (*( sm->p)) < -29 ) {
					if ( -30 <= (*( sm->p)) && (*( sm->p)) <= -30 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) > -29 ) {
					if ( -28 <= (*( sm->p)) && (*( sm->p)) <= -18 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else {
			_widec = (short)(640 + ((*( sm->p)) - -128));
			if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
		}
	} else if ( (*( sm->p)) > -17 ) {
		if ( (*( sm->p)) < 43 ) {
			if ( (*( sm->p)) < 1 ) {
				if ( (*( sm->p)) > -12 ) {
					if ( -11 <= (*( sm->p)) && (*( sm->p)) <= -1 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= -16 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > 8 ) {
				if ( (*( sm->p)) < 33 ) {
					if ( 14 <= (*( sm->p)) && (*( sm->p)) <= 31 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) > 33 ) {
					if ( 39 <= (*( sm->p)) && (*( sm->p)) <= 39 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else if ( (*( sm->p)) > 43 ) {
			if ( (*( sm->p)) < 65 ) {
				if ( (*( sm->p)) > 47 ) {
					if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= 45 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > 90 ) {
				if ( (*( sm->p)) < 97 ) {
					if ( 95 <= (*( sm->p)) && (*( sm->p)) <= 95 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) > 122 ) {
					if ( 127 <= (*( sm->p)) )
 {						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else {
			_widec = (short)(640 + ((*( sm->p)) - -128));
			if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
		}
	} else {
		_widec = (short)(640 + ((*( sm->p)) - -128));
		if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
	}
	switch( _widec ) {
		case 925: goto st670;
		case 928: goto st670;
		case 931: goto st670;
		case 994: goto st674;
		case 995: goto st676;
		case 1007: goto st678;
		case 1057: goto st671;
		case 1063: goto st671;
		case 1067: goto st671;
		case 1119: goto st671;
		case 1151: goto tr843;
	}
	if ( _widec < 1013 ) {
		if ( _widec < 962 ) {
			if ( _widec > 959 ) {
				if ( 960 <= _widec && _widec <= 961 )
					goto st671;
			} else if ( _widec >= 896 )
				goto tr835;
		} else if ( _widec > 991 ) {
			if ( _widec > 1006 ) {
				if ( 1008 <= _widec && _widec <= 1012 )
					goto st680;
			} else if ( _widec >= 992 )
				goto st673;
		} else
			goto st672;
	} else if ( _widec > 1023 ) {
		if ( _widec < 1069 ) {
			if ( _widec > 1032 ) {
				if ( 1038 <= _widec && _widec <= 1055 )
					goto tr843;
			} else if ( _widec >= 1025 )
				goto tr843;
		} else if ( _widec > 1071 ) {
			if ( _widec < 1089 ) {
				if ( 1072 <= _widec && _widec <= 1081 )
					goto tr843;
			} else if ( _widec > 1114 ) {
				if ( 1121 <= _widec && _widec <= 1146 )
					goto tr843;
			} else
				goto tr843;
		} else
			goto st671;
	} else
		goto st671;
	goto tr185;
st691:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof691;
case 691:
	_widec = (*( sm->p));
	if ( (*( sm->p)) < 1 ) {
		if ( (*( sm->p)) < -30 ) {
			if ( (*( sm->p)) < -64 ) {
				if ( (*( sm->p)) <= -65 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > -63 ) {
				if ( (*( sm->p)) > -33 ) {
					if ( -32 <= (*( sm->p)) && (*( sm->p)) <= -31 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= -62 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else if ( (*( sm->p)) > -30 ) {
			if ( (*( sm->p)) < -17 ) {
				if ( (*( sm->p)) > -29 ) {
					if ( -28 <= (*( sm->p)) && (*( sm->p)) <= -18 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= -29 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > -17 ) {
				if ( (*( sm->p)) > -12 ) {
					if ( -11 <= (*( sm->p)) && (*( sm->p)) <= -1 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= -16 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else {
			_widec = (short)(640 + ((*( sm->p)) - -128));
			if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
		}
	} else if ( (*( sm->p)) > 8 ) {
		if ( (*( sm->p)) < 45 ) {
			if ( (*( sm->p)) < 33 ) {
				if ( 14 <= (*( sm->p)) && (*( sm->p)) <= 31 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > 33 ) {
				if ( (*( sm->p)) > 39 ) {
					if ( 43 <= (*( sm->p)) && (*( sm->p)) <= 43 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= 39 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else if ( (*( sm->p)) > 47 ) {
			if ( (*( sm->p)) < 95 ) {
				if ( (*( sm->p)) > 57 ) {
					if ( 65 <= (*( sm->p)) && (*( sm->p)) <= 90 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= 48 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > 95 ) {
				if ( (*( sm->p)) > 122 ) {
					if ( 127 <= (*( sm->p)) )
 {						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= 97 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else {
			_widec = (short)(640 + ((*( sm->p)) - -128));
			if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
		}
	} else {
		_widec = (short)(640 + ((*( sm->p)) - -128));
		if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
	}
	switch( _widec ) {
		case 994: goto st674;
		case 995: goto st676;
		case 1007: goto st678;
		case 1057: goto st671;
		case 1063: goto st671;
		case 1067: goto st671;
		case 1119: goto st671;
		case 1151: goto tr843;
	}
	if ( _widec < 1013 ) {
		if ( _widec < 962 ) {
			if ( _widec > 959 ) {
				if ( 960 <= _widec && _widec <= 961 )
					goto st671;
			} else if ( _widec >= 896 )
				goto st683;
		} else if ( _widec > 991 ) {
			if ( _widec > 1006 ) {
				if ( 1008 <= _widec && _widec <= 1012 )
					goto st680;
			} else if ( _widec >= 992 )
				goto st673;
		} else
			goto st672;
	} else if ( _widec > 1023 ) {
		if ( _widec < 1069 ) {
			if ( _widec > 1032 ) {
				if ( 1038 <= _widec && _widec <= 1055 )
					goto tr843;
			} else if ( _widec >= 1025 )
				goto tr843;
		} else if ( _widec > 1071 ) {
			if ( _widec < 1089 ) {
				if ( 1072 <= _widec && _widec <= 1081 )
					goto tr843;
			} else if ( _widec > 1114 ) {
				if ( 1121 <= _widec && _widec <= 1146 )
					goto tr843;
			} else
				goto tr843;
		} else
			goto st671;
	} else
		goto st671;
	goto tr185;
st692:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof692;
case 692:
	_widec = (*( sm->p));
	if ( (*( sm->p)) < 33 ) {
		if ( (*( sm->p)) < -28 ) {
			if ( (*( sm->p)) < -32 ) {
				if ( (*( sm->p)) > -63 ) {
					if ( -62 <= (*( sm->p)) && (*( sm->p)) <= -33 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > -31 ) {
				if ( (*( sm->p)) > -30 ) {
					if ( -29 <= (*( sm->p)) && (*( sm->p)) <= -29 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= -30 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else if ( (*( sm->p)) > -18 ) {
			if ( (*( sm->p)) < -11 ) {
				if ( (*( sm->p)) > -17 ) {
					if ( -16 <= (*( sm->p)) && (*( sm->p)) <= -12 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= -17 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > -1 ) {
				if ( (*( sm->p)) > 8 ) {
					if ( 14 <= (*( sm->p)) && (*( sm->p)) <= 31 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= 1 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else {
			_widec = (short)(640 + ((*( sm->p)) - -128));
			if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
		}
	} else if ( (*( sm->p)) > 33 ) {
		if ( (*( sm->p)) < 95 ) {
			if ( (*( sm->p)) < 45 ) {
				if ( (*( sm->p)) > 39 ) {
					if ( 43 <= (*( sm->p)) && (*( sm->p)) <= 43 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= 39 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > 47 ) {
				if ( (*( sm->p)) > 57 ) {
					if ( 65 <= (*( sm->p)) && (*( sm->p)) <= 90 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= 48 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else if ( (*( sm->p)) > 95 ) {
			if ( (*( sm->p)) < 101 ) {
				if ( (*( sm->p)) > 99 ) {
					if ( 100 <= (*( sm->p)) && (*( sm->p)) <= 100 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= 97 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > 114 ) {
				if ( (*( sm->p)) < 116 ) {
					if ( 115 <= (*( sm->p)) && (*( sm->p)) <= 115 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) > 122 ) {
					if ( 127 <= (*( sm->p)) )
 {						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else {
			_widec = (short)(640 + ((*( sm->p)) - -128));
			if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
		}
	} else {
		_widec = (short)(640 + ((*( sm->p)) - -128));
		if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
	}
	switch( _widec ) {
		case 994: goto st684;
		case 995: goto st686;
		case 1007: goto st688;
		case 1057: goto st670;
		case 1063: goto st692;
		case 1067: goto st670;
		case 1119: goto st670;
		case 1124: goto st670;
		case 1139: goto st670;
		case 1151: goto tr835;
	}
	if ( _widec < 1025 ) {
		if ( _widec < 992 ) {
			if ( _widec > 961 ) {
				if ( 962 <= _widec && _widec <= 991 )
					goto st682;
			} else if ( _widec >= 896 )
				goto st671;
		} else if ( _widec > 1006 ) {
			if ( _widec > 1012 ) {
				if ( 1013 <= _widec && _widec <= 1023 )
					goto st671;
			} else if ( _widec >= 1008 )
				goto st691;
		} else
			goto st683;
	} else if ( _widec > 1032 ) {
		if ( _widec < 1072 ) {
			if ( _widec > 1055 ) {
				if ( 1069 <= _widec && _widec <= 1071 )
					goto st670;
			} else if ( _widec >= 1038 )
				goto tr835;
		} else if ( _widec > 1081 ) {
			if ( _widec > 1114 ) {
				if ( 1121 <= _widec && _widec <= 1146 )
					goto tr835;
			} else if ( _widec >= 1089 )
				goto tr835;
		} else
			goto tr835;
	} else
		goto tr835;
	goto tr185;
tr1675:
#line 117 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st693;
st693:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof693;
case 693:
#line 22858 "ext/dtext/dtext.cpp"
	_widec = (*( sm->p));
	if ( (*( sm->p)) <= -65 ) {
		_widec = (short)(640 + ((*( sm->p)) - -128));
		if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
	}
	if ( 896 <= _widec && _widec <= 959 )
		goto st669;
	goto tr193;
tr1676:
#line 117 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st694;
st694:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof694;
case 694:
#line 22877 "ext/dtext/dtext.cpp"
	_widec = (*( sm->p));
	if ( (*( sm->p)) < -99 ) {
		if ( (*( sm->p)) <= -100 ) {
			_widec = (short)(640 + ((*( sm->p)) - -128));
			if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
		}
	} else if ( (*( sm->p)) > -99 ) {
		if ( -98 <= (*( sm->p)) && (*( sm->p)) <= -65 ) {
			_widec = (short)(640 + ((*( sm->p)) - -128));
			if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
		}
	} else {
		_widec = (short)(640 + ((*( sm->p)) - -128));
		if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
	}
	if ( _widec == 925 )
		goto st695;
	if ( 896 <= _widec && _widec <= 959 )
		goto st669;
	goto tr193;
st695:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof695;
case 695:
	_widec = (*( sm->p));
	if ( (*( sm->p)) > -84 ) {
		if ( -82 <= (*( sm->p)) && (*( sm->p)) <= -65 ) {
			_widec = (short)(640 + ((*( sm->p)) - -128));
			if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
		}
	} else {
		_widec = (short)(640 + ((*( sm->p)) - -128));
		if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
	}
	if ( _widec > 940 ) {
		if ( 942 <= _widec && _widec <= 959 )
			goto st670;
	} else if ( _widec >= 896 )
		goto st670;
	goto tr193;
tr1677:
#line 117 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st696;
st696:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof696;
case 696:
#line 22936 "ext/dtext/dtext.cpp"
	_widec = (*( sm->p));
	if ( (*( sm->p)) > -128 ) {
		if ( -127 <= (*( sm->p)) && (*( sm->p)) <= -65 ) {
			_widec = (short)(640 + ((*( sm->p)) - -128));
			if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
		}
	} else {
		_widec = (short)(640 + ((*( sm->p)) - -128));
		if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
	}
	if ( _widec == 896 )
		goto st697;
	if ( 897 <= _widec && _widec <= 959 )
		goto st669;
	goto tr193;
st697:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof697;
case 697:
	_widec = (*( sm->p));
	if ( (*( sm->p)) < -110 ) {
		if ( -125 <= (*( sm->p)) && (*( sm->p)) <= -121 ) {
			_widec = (short)(640 + ((*( sm->p)) - -128));
			if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
		}
	} else if ( (*( sm->p)) > -109 ) {
		if ( -99 <= (*( sm->p)) && (*( sm->p)) <= -65 ) {
			_widec = (short)(640 + ((*( sm->p)) - -128));
			if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
		}
	} else {
		_widec = (short)(640 + ((*( sm->p)) - -128));
		if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
	}
	if ( _widec < 914 ) {
		if ( 899 <= _widec && _widec <= 903 )
			goto st670;
	} else if ( _widec > 915 ) {
		if ( 925 <= _widec && _widec <= 959 )
			goto st670;
	} else
		goto st670;
	goto tr193;
tr1678:
#line 117 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st698;
st698:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof698;
case 698:
#line 22998 "ext/dtext/dtext.cpp"
	_widec = (*( sm->p));
	if ( (*( sm->p)) < -68 ) {
		if ( (*( sm->p)) <= -69 ) {
			_widec = (short)(640 + ((*( sm->p)) - -128));
			if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
		}
	} else if ( (*( sm->p)) > -68 ) {
		if ( (*( sm->p)) > -67 ) {
			if ( -66 <= (*( sm->p)) && (*( sm->p)) <= -65 ) {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else if ( (*( sm->p)) >= -67 ) {
			_widec = (short)(640 + ((*( sm->p)) - -128));
			if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
		}
	} else {
		_widec = (short)(640 + ((*( sm->p)) - -128));
		if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
	}
	switch( _widec ) {
		case 956: goto st699;
		case 957: goto st700;
	}
	if ( 896 <= _widec && _widec <= 959 )
		goto st669;
	goto tr193;
st699:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof699;
case 699:
	_widec = (*( sm->p));
	if ( (*( sm->p)) < -118 ) {
		if ( (*( sm->p)) <= -120 ) {
			_widec = (short)(640 + ((*( sm->p)) - -128));
			if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
		}
	} else if ( (*( sm->p)) > -68 ) {
		if ( -66 <= (*( sm->p)) && (*( sm->p)) <= -65 ) {
			_widec = (short)(640 + ((*( sm->p)) - -128));
			if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
		}
	} else {
		_widec = (short)(640 + ((*( sm->p)) - -128));
		if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
	}
	if ( _widec < 906 ) {
		if ( 896 <= _widec && _widec <= 904 )
			goto st670;
	} else if ( _widec > 956 ) {
		if ( 958 <= _widec && _widec <= 959 )
			goto st670;
	} else
		goto st670;
	goto tr193;
st700:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof700;
case 700:
	_widec = (*( sm->p));
	if ( (*( sm->p)) < -98 ) {
		if ( (*( sm->p)) <= -100 ) {
			_widec = (short)(640 + ((*( sm->p)) - -128));
			if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
		}
	} else if ( (*( sm->p)) > -97 ) {
		if ( (*( sm->p)) > -94 ) {
			if ( -92 <= (*( sm->p)) && (*( sm->p)) <= -65 ) {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else if ( (*( sm->p)) >= -95 ) {
			_widec = (short)(640 + ((*( sm->p)) - -128));
			if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
		}
	} else {
		_widec = (short)(640 + ((*( sm->p)) - -128));
		if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
	}
	if ( _widec < 926 ) {
		if ( 896 <= _widec && _widec <= 924 )
			goto st670;
	} else if ( _widec > 927 ) {
		if ( _widec > 930 ) {
			if ( 932 <= _widec && _widec <= 959 )
				goto st670;
		} else if ( _widec >= 929 )
			goto st670;
	} else
		goto st670;
	goto tr193;
tr1679:
#line 117 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st701;
st701:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof701;
case 701:
#line 23120 "ext/dtext/dtext.cpp"
	_widec = (*( sm->p));
	if ( (*( sm->p)) <= -65 ) {
		_widec = (short)(640 + ((*( sm->p)) - -128));
		if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
	}
	if ( 896 <= _widec && _widec <= 959 )
		goto st693;
	goto tr193;
tr1681:
#line 117 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st702;
st702:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof702;
case 702:
#line 23139 "ext/dtext/dtext.cpp"
	_widec = (*( sm->p));
	if ( (*( sm->p)) < -16 ) {
		if ( (*( sm->p)) < -30 ) {
			if ( (*( sm->p)) > -33 ) {
				if ( -32 <= (*( sm->p)) && (*( sm->p)) <= -31 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) >= -62 ) {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else if ( (*( sm->p)) > -30 ) {
			if ( (*( sm->p)) < -28 ) {
				if ( -29 <= (*( sm->p)) && (*( sm->p)) <= -29 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > -18 ) {
				if ( -17 <= (*( sm->p)) && (*( sm->p)) <= -17 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else {
			_widec = (short)(640 + ((*( sm->p)) - -128));
			if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
		}
	} else if ( (*( sm->p)) > -12 ) {
		if ( (*( sm->p)) < 48 ) {
			if ( (*( sm->p)) > 8 ) {
				if ( 14 <= (*( sm->p)) && (*( sm->p)) <= 31 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) >= 1 ) {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else if ( (*( sm->p)) > 57 ) {
			if ( (*( sm->p)) < 97 ) {
				if ( 65 <= (*( sm->p)) && (*( sm->p)) <= 90 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > 122 ) {
				if ( 127 <= (*( sm->p)) )
 {					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else {
			_widec = (short)(640 + ((*( sm->p)) - -128));
			if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
		}
	} else {
		_widec = (short)(640 + ((*( sm->p)) - -128));
		if ( 
#line 129 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
	}
	switch( _widec ) {
		case 994: goto st694;
		case 995: goto st696;
		case 1007: goto st698;
		case 1151: goto st670;
	}
	if ( _widec < 1025 ) {
		if ( _widec < 992 ) {
			if ( 962 <= _widec && _widec <= 991 )
				goto st669;
		} else if ( _widec > 1006 ) {
			if ( 1008 <= _widec && _widec <= 1012 )
				goto st701;
		} else
			goto st693;
	} else if ( _widec > 1032 ) {
		if ( _widec < 1072 ) {
			if ( 1038 <= _widec && _widec <= 1055 )
				goto st670;
		} else if ( _widec > 1081 ) {
			if ( _widec > 1114 ) {
				if ( 1121 <= _widec && _widec <= 1146 )
					goto st670;
			} else if ( _widec >= 1089 )
				goto st670;
		} else
			goto st670;
	} else
		goto st670;
	goto tr193;
tr862:
#line 579 "ext/dtext/dtext.cpp.rl"
	{{( sm->p) = ((( sm->te)))-1;}{
    append_html_escaped(sm, (*( sm->p)));
  }}
	goto st1233;
tr868:
#line 572 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_rewind(sm);
    { sm->cs = ( (sm->stack.data()))[--( sm->top)];goto _again;}
  }}
	goto st1233;
tr1683:
#line 579 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{
    append_html_escaped(sm, (*( sm->p)));
  }}
	goto st1233;
tr1684:
#line 577 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;}
	goto st1233;
tr1689:
#line 579 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append_html_escaped(sm, (*( sm->p)));
  }}
	goto st1233;
st1233:
#line 1 "NONE"
	{( sm->ts) = 0;}
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1233;
case 1233:
#line 1 "NONE"
	{( sm->ts) = ( sm->p);}
#line 23298 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr1684;
		case 10: goto tr1685;
		case 13: goto tr1686;
		case 60: goto tr1687;
		case 91: goto tr1688;
	}
	goto tr1683;
tr1685:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
	goto st1234;
st1234:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1234;
case 1234:
#line 23315 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 60: goto st703;
		case 91: goto st709;
	}
	goto tr1689;
st703:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof703;
case 703:
	if ( (*( sm->p)) == 47 )
		goto st704;
	goto tr862;
st704:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof704;
case 704:
	switch( (*( sm->p)) ) {
		case 67: goto st705;
		case 99: goto st705;
	}
	goto tr862;
st705:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof705;
case 705:
	switch( (*( sm->p)) ) {
		case 79: goto st706;
		case 111: goto st706;
	}
	goto tr862;
st706:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof706;
case 706:
	switch( (*( sm->p)) ) {
		case 68: goto st707;
		case 100: goto st707;
	}
	goto tr862;
st707:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof707;
case 707:
	switch( (*( sm->p)) ) {
		case 69: goto st708;
		case 101: goto st708;
	}
	goto tr862;
st708:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof708;
case 708:
	if ( (*( sm->p)) == 62 )
		goto tr868;
	goto tr862;
st709:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof709;
case 709:
	if ( (*( sm->p)) == 47 )
		goto st710;
	goto tr862;
st710:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof710;
case 710:
	switch( (*( sm->p)) ) {
		case 67: goto st711;
		case 99: goto st711;
	}
	goto tr862;
st711:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof711;
case 711:
	switch( (*( sm->p)) ) {
		case 79: goto st712;
		case 111: goto st712;
	}
	goto tr862;
st712:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof712;
case 712:
	switch( (*( sm->p)) ) {
		case 68: goto st713;
		case 100: goto st713;
	}
	goto tr862;
st713:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof713;
case 713:
	switch( (*( sm->p)) ) {
		case 69: goto st714;
		case 101: goto st714;
	}
	goto tr862;
st714:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof714;
case 714:
	if ( (*( sm->p)) == 93 )
		goto tr868;
	goto tr862;
tr1686:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
	goto st1235;
st1235:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1235;
case 1235:
#line 23429 "ext/dtext/dtext.cpp"
	if ( (*( sm->p)) == 10 )
		goto st715;
	goto tr1689;
st715:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof715;
case 715:
	switch( (*( sm->p)) ) {
		case 60: goto st703;
		case 91: goto st709;
	}
	goto tr862;
tr1687:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
	goto st1236;
st1236:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1236;
case 1236:
#line 23450 "ext/dtext/dtext.cpp"
	if ( (*( sm->p)) == 47 )
		goto st704;
	goto tr1689;
tr1688:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
	goto st1237;
st1237:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1237;
case 1237:
#line 23462 "ext/dtext/dtext.cpp"
	if ( (*( sm->p)) == 47 )
		goto st710;
	goto tr1689;
tr876:
#line 592 "ext/dtext/dtext.cpp.rl"
	{{( sm->p) = ((( sm->te)))-1;}{
    append_html_escaped(sm, (*( sm->p)));
  }}
	goto st1238;
tr885:
#line 585 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_rewind(sm);
    { sm->cs = ( (sm->stack.data()))[--( sm->top)];goto _again;}
  }}
	goto st1238;
tr1691:
#line 592 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{
    append_html_escaped(sm, (*( sm->p)));
  }}
	goto st1238;
tr1692:
#line 590 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;}
	goto st1238;
tr1697:
#line 592 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append_html_escaped(sm, (*( sm->p)));
  }}
	goto st1238;
st1238:
#line 1 "NONE"
	{( sm->ts) = 0;}
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1238;
case 1238:
#line 1 "NONE"
	{( sm->ts) = ( sm->p);}
#line 23503 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr1692;
		case 10: goto tr1693;
		case 13: goto tr1694;
		case 60: goto tr1695;
		case 91: goto tr1696;
	}
	goto tr1691;
tr1693:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
	goto st1239;
st1239:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1239;
case 1239:
#line 23520 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 60: goto st716;
		case 91: goto st725;
	}
	goto tr1697;
st716:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof716;
case 716:
	if ( (*( sm->p)) == 47 )
		goto st717;
	goto tr876;
st717:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof717;
case 717:
	switch( (*( sm->p)) ) {
		case 78: goto st718;
		case 110: goto st718;
	}
	goto tr876;
st718:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof718;
case 718:
	switch( (*( sm->p)) ) {
		case 79: goto st719;
		case 111: goto st719;
	}
	goto tr876;
st719:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof719;
case 719:
	switch( (*( sm->p)) ) {
		case 68: goto st720;
		case 100: goto st720;
	}
	goto tr876;
st720:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof720;
case 720:
	switch( (*( sm->p)) ) {
		case 84: goto st721;
		case 116: goto st721;
	}
	goto tr876;
st721:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof721;
case 721:
	switch( (*( sm->p)) ) {
		case 69: goto st722;
		case 101: goto st722;
	}
	goto tr876;
st722:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof722;
case 722:
	switch( (*( sm->p)) ) {
		case 88: goto st723;
		case 120: goto st723;
	}
	goto tr876;
st723:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof723;
case 723:
	switch( (*( sm->p)) ) {
		case 84: goto st724;
		case 116: goto st724;
	}
	goto tr876;
st724:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof724;
case 724:
	if ( (*( sm->p)) == 62 )
		goto tr885;
	goto tr876;
st725:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof725;
case 725:
	if ( (*( sm->p)) == 47 )
		goto st726;
	goto tr876;
st726:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof726;
case 726:
	switch( (*( sm->p)) ) {
		case 78: goto st727;
		case 110: goto st727;
	}
	goto tr876;
st727:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof727;
case 727:
	switch( (*( sm->p)) ) {
		case 79: goto st728;
		case 111: goto st728;
	}
	goto tr876;
st728:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof728;
case 728:
	switch( (*( sm->p)) ) {
		case 68: goto st729;
		case 100: goto st729;
	}
	goto tr876;
st729:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof729;
case 729:
	switch( (*( sm->p)) ) {
		case 84: goto st730;
		case 116: goto st730;
	}
	goto tr876;
st730:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof730;
case 730:
	switch( (*( sm->p)) ) {
		case 69: goto st731;
		case 101: goto st731;
	}
	goto tr876;
st731:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof731;
case 731:
	switch( (*( sm->p)) ) {
		case 88: goto st732;
		case 120: goto st732;
	}
	goto tr876;
st732:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof732;
case 732:
	switch( (*( sm->p)) ) {
		case 84: goto st733;
		case 116: goto st733;
	}
	goto tr876;
st733:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof733;
case 733:
	if ( (*( sm->p)) == 93 )
		goto tr885;
	goto tr876;
tr1694:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
	goto st1240;
st1240:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1240;
case 1240:
#line 23688 "ext/dtext/dtext.cpp"
	if ( (*( sm->p)) == 10 )
		goto st734;
	goto tr1697;
st734:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof734;
case 734:
	switch( (*( sm->p)) ) {
		case 60: goto st716;
		case 91: goto st725;
	}
	goto tr876;
tr1695:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
	goto st1241;
st1241:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1241;
case 1241:
#line 23709 "ext/dtext/dtext.cpp"
	if ( (*( sm->p)) == 47 )
		goto st717;
	goto tr1697;
tr1696:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
	goto st1242;
st1242:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1242;
case 1242:
#line 23721 "ext/dtext/dtext.cpp"
	if ( (*( sm->p)) == 47 )
		goto st726;
	goto tr1697;
tr896:
#line 651 "ext/dtext/dtext.cpp.rl"
	{{( sm->p) = ((( sm->te)))-1;}}
	goto st1243;
tr906:
#line 602 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_close_block(sm, BLOCK_COLGROUP, "</colgroup>");
  }}
	goto st1243;
tr914:
#line 645 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{
    if (dstack_close_block(sm, BLOCK_TABLE, "</table>")) {
      { sm->cs = ( (sm->stack.data()))[--( sm->top)];goto _again;}
    }
  }}
	goto st1243;
tr918:
#line 623 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_close_block(sm, BLOCK_TBODY, "</tbody>");
  }}
	goto st1243;
tr922:
#line 615 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_close_block(sm, BLOCK_THEAD, "</thead>");
  }}
	goto st1243;
tr923:
#line 636 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_close_block(sm, BLOCK_TR, "</tr>");
  }}
	goto st1243;
tr927:
#line 606 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_open_block(sm, BLOCK_COL, "col", sm->tag_attributes);
    dstack_pop(sm); // XXX [col] has no end tag
  }}
	goto st1243;
tr942:
#line 132 "ext/dtext/dtext.cpp.rl"
	{ save_tag_attribute(sm, { sm->a1, sm->a2 }, { sm->b1, sm->b2 }); }
#line 606 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_open_block(sm, BLOCK_COL, "col", sm->tag_attributes);
    dstack_pop(sm); // XXX [col] has no end tag
  }}
	goto st1243;
tr947:
#line 120 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
#line 132 "ext/dtext/dtext.cpp.rl"
	{ save_tag_attribute(sm, { sm->a1, sm->a2 }, { sm->b1, sm->b2 }); }
#line 606 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_open_block(sm, BLOCK_COL, "col", sm->tag_attributes);
    dstack_pop(sm); // XXX [col] has no end tag
  }}
	goto st1243;
tr953:
#line 598 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_open_block(sm, BLOCK_COLGROUP, "colgroup", sm->tag_attributes);
  }}
	goto st1243;
tr967:
#line 132 "ext/dtext/dtext.cpp.rl"
	{ save_tag_attribute(sm, { sm->a1, sm->a2 }, { sm->b1, sm->b2 }); }
#line 598 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_open_block(sm, BLOCK_COLGROUP, "colgroup", sm->tag_attributes);
  }}
	goto st1243;
tr972:
#line 120 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
#line 132 "ext/dtext/dtext.cpp.rl"
	{ save_tag_attribute(sm, { sm->a1, sm->a2 }, { sm->b1, sm->b2 }); }
#line 598 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_open_block(sm, BLOCK_COLGROUP, "colgroup", sm->tag_attributes);
  }}
	goto st1243;
tr981:
#line 619 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_open_block(sm, BLOCK_TBODY, "tbody", sm->tag_attributes);
  }}
	goto st1243;
tr995:
#line 132 "ext/dtext/dtext.cpp.rl"
	{ save_tag_attribute(sm, { sm->a1, sm->a2 }, { sm->b1, sm->b2 }); }
#line 619 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_open_block(sm, BLOCK_TBODY, "tbody", sm->tag_attributes);
  }}
	goto st1243;
tr1000:
#line 120 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
#line 132 "ext/dtext/dtext.cpp.rl"
	{ save_tag_attribute(sm, { sm->a1, sm->a2 }, { sm->b1, sm->b2 }); }
#line 619 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_open_block(sm, BLOCK_TBODY, "tbody", sm->tag_attributes);
  }}
	goto st1243;
tr1002:
#line 640 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_open_block(sm, BLOCK_TD, "td", sm->tag_attributes);
    {
  size_t len = sm->stack.size();

  if (len > MAX_STACK_DEPTH) {
    // Should never happen.
    throw DTextError("too many nested elements");
  }

  if (sm->top >= len) {
    g_debug("growing sm->stack %zi", len + 16);
    sm->stack.resize(len + 16, 0);
  }
{( (sm->stack.data()))[( sm->top)++] = 1243;goto st982;}}
  }}
	goto st1243;
tr1016:
#line 132 "ext/dtext/dtext.cpp.rl"
	{ save_tag_attribute(sm, { sm->a1, sm->a2 }, { sm->b1, sm->b2 }); }
#line 640 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_open_block(sm, BLOCK_TD, "td", sm->tag_attributes);
    {
  size_t len = sm->stack.size();

  if (len > MAX_STACK_DEPTH) {
    // Should never happen.
    throw DTextError("too many nested elements");
  }

  if (sm->top >= len) {
    g_debug("growing sm->stack %zi", len + 16);
    sm->stack.resize(len + 16, 0);
  }
{( (sm->stack.data()))[( sm->top)++] = 1243;goto st982;}}
  }}
	goto st1243;
tr1021:
#line 120 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
#line 132 "ext/dtext/dtext.cpp.rl"
	{ save_tag_attribute(sm, { sm->a1, sm->a2 }, { sm->b1, sm->b2 }); }
#line 640 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_open_block(sm, BLOCK_TD, "td", sm->tag_attributes);
    {
  size_t len = sm->stack.size();

  if (len > MAX_STACK_DEPTH) {
    // Should never happen.
    throw DTextError("too many nested elements");
  }

  if (sm->top >= len) {
    g_debug("growing sm->stack %zi", len + 16);
    sm->stack.resize(len + 16, 0);
  }
{( (sm->stack.data()))[( sm->top)++] = 1243;goto st982;}}
  }}
	goto st1243;
tr1023:
#line 627 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_open_block(sm, BLOCK_TH, "th", sm->tag_attributes);
    {
  size_t len = sm->stack.size();

  if (len > MAX_STACK_DEPTH) {
    // Should never happen.
    throw DTextError("too many nested elements");
  }

  if (sm->top >= len) {
    g_debug("growing sm->stack %zi", len + 16);
    sm->stack.resize(len + 16, 0);
  }
{( (sm->stack.data()))[( sm->top)++] = 1243;goto st982;}}
  }}
	goto st1243;
tr1038:
#line 132 "ext/dtext/dtext.cpp.rl"
	{ save_tag_attribute(sm, { sm->a1, sm->a2 }, { sm->b1, sm->b2 }); }
#line 627 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_open_block(sm, BLOCK_TH, "th", sm->tag_attributes);
    {
  size_t len = sm->stack.size();

  if (len > MAX_STACK_DEPTH) {
    // Should never happen.
    throw DTextError("too many nested elements");
  }

  if (sm->top >= len) {
    g_debug("growing sm->stack %zi", len + 16);
    sm->stack.resize(len + 16, 0);
  }
{( (sm->stack.data()))[( sm->top)++] = 1243;goto st982;}}
  }}
	goto st1243;
tr1043:
#line 120 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
#line 132 "ext/dtext/dtext.cpp.rl"
	{ save_tag_attribute(sm, { sm->a1, sm->a2 }, { sm->b1, sm->b2 }); }
#line 627 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_open_block(sm, BLOCK_TH, "th", sm->tag_attributes);
    {
  size_t len = sm->stack.size();

  if (len > MAX_STACK_DEPTH) {
    // Should never happen.
    throw DTextError("too many nested elements");
  }

  if (sm->top >= len) {
    g_debug("growing sm->stack %zi", len + 16);
    sm->stack.resize(len + 16, 0);
  }
{( (sm->stack.data()))[( sm->top)++] = 1243;goto st982;}}
  }}
	goto st1243;
tr1047:
#line 611 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_open_block(sm, BLOCK_THEAD, "thead", sm->tag_attributes);
  }}
	goto st1243;
tr1061:
#line 132 "ext/dtext/dtext.cpp.rl"
	{ save_tag_attribute(sm, { sm->a1, sm->a2 }, { sm->b1, sm->b2 }); }
#line 611 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_open_block(sm, BLOCK_THEAD, "thead", sm->tag_attributes);
  }}
	goto st1243;
tr1066:
#line 120 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
#line 132 "ext/dtext/dtext.cpp.rl"
	{ save_tag_attribute(sm, { sm->a1, sm->a2 }, { sm->b1, sm->b2 }); }
#line 611 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_open_block(sm, BLOCK_THEAD, "thead", sm->tag_attributes);
  }}
	goto st1243;
tr1068:
#line 632 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_open_block(sm, BLOCK_TR, "tr", sm->tag_attributes);
  }}
	goto st1243;
tr1082:
#line 132 "ext/dtext/dtext.cpp.rl"
	{ save_tag_attribute(sm, { sm->a1, sm->a2 }, { sm->b1, sm->b2 }); }
#line 632 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_open_block(sm, BLOCK_TR, "tr", sm->tag_attributes);
  }}
	goto st1243;
tr1087:
#line 120 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
#line 132 "ext/dtext/dtext.cpp.rl"
	{ save_tag_attribute(sm, { sm->a1, sm->a2 }, { sm->b1, sm->b2 }); }
#line 632 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_open_block(sm, BLOCK_TR, "tr", sm->tag_attributes);
  }}
	goto st1243;
tr1699:
#line 651 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;}
	goto st1243;
tr1702:
#line 651 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;}
	goto st1243;
st1243:
#line 1 "NONE"
	{( sm->ts) = 0;}
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1243;
case 1243:
#line 1 "NONE"
	{( sm->ts) = ( sm->p);}
#line 24026 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 60: goto tr1700;
		case 91: goto tr1701;
	}
	goto tr1699;
tr1700:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
	goto st1244;
st1244:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1244;
case 1244:
#line 24040 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 47: goto st735;
		case 67: goto st758;
		case 84: goto st786;
		case 99: goto st758;
		case 116: goto st786;
	}
	goto tr1702;
st735:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof735;
case 735:
	switch( (*( sm->p)) ) {
		case 67: goto st736;
		case 84: goto st744;
		case 99: goto st736;
		case 116: goto st744;
	}
	goto tr896;
st736:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof736;
case 736:
	switch( (*( sm->p)) ) {
		case 79: goto st737;
		case 111: goto st737;
	}
	goto tr896;
st737:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof737;
case 737:
	switch( (*( sm->p)) ) {
		case 76: goto st738;
		case 108: goto st738;
	}
	goto tr896;
st738:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof738;
case 738:
	switch( (*( sm->p)) ) {
		case 71: goto st739;
		case 103: goto st739;
	}
	goto tr896;
st739:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof739;
case 739:
	switch( (*( sm->p)) ) {
		case 82: goto st740;
		case 114: goto st740;
	}
	goto tr896;
st740:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof740;
case 740:
	switch( (*( sm->p)) ) {
		case 79: goto st741;
		case 111: goto st741;
	}
	goto tr896;
st741:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof741;
case 741:
	switch( (*( sm->p)) ) {
		case 85: goto st742;
		case 117: goto st742;
	}
	goto tr896;
st742:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof742;
case 742:
	switch( (*( sm->p)) ) {
		case 80: goto st743;
		case 112: goto st743;
	}
	goto tr896;
st743:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof743;
case 743:
	if ( (*( sm->p)) == 62 )
		goto tr906;
	goto tr896;
st744:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof744;
case 744:
	switch( (*( sm->p)) ) {
		case 65: goto st745;
		case 66: goto st749;
		case 72: goto st753;
		case 82: goto st757;
		case 97: goto st745;
		case 98: goto st749;
		case 104: goto st753;
		case 114: goto st757;
	}
	goto tr896;
st745:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof745;
case 745:
	switch( (*( sm->p)) ) {
		case 66: goto st746;
		case 98: goto st746;
	}
	goto tr896;
st746:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof746;
case 746:
	switch( (*( sm->p)) ) {
		case 76: goto st747;
		case 108: goto st747;
	}
	goto tr896;
st747:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof747;
case 747:
	switch( (*( sm->p)) ) {
		case 69: goto st748;
		case 101: goto st748;
	}
	goto tr896;
st748:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof748;
case 748:
	if ( (*( sm->p)) == 62 )
		goto tr914;
	goto tr896;
st749:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof749;
case 749:
	switch( (*( sm->p)) ) {
		case 79: goto st750;
		case 111: goto st750;
	}
	goto tr896;
st750:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof750;
case 750:
	switch( (*( sm->p)) ) {
		case 68: goto st751;
		case 100: goto st751;
	}
	goto tr896;
st751:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof751;
case 751:
	switch( (*( sm->p)) ) {
		case 89: goto st752;
		case 121: goto st752;
	}
	goto tr896;
st752:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof752;
case 752:
	if ( (*( sm->p)) == 62 )
		goto tr918;
	goto tr896;
st753:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof753;
case 753:
	switch( (*( sm->p)) ) {
		case 69: goto st754;
		case 101: goto st754;
	}
	goto tr896;
st754:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof754;
case 754:
	switch( (*( sm->p)) ) {
		case 65: goto st755;
		case 97: goto st755;
	}
	goto tr896;
st755:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof755;
case 755:
	switch( (*( sm->p)) ) {
		case 68: goto st756;
		case 100: goto st756;
	}
	goto tr896;
st756:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof756;
case 756:
	if ( (*( sm->p)) == 62 )
		goto tr922;
	goto tr896;
st757:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof757;
case 757:
	if ( (*( sm->p)) == 62 )
		goto tr923;
	goto tr896;
st758:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof758;
case 758:
	switch( (*( sm->p)) ) {
		case 79: goto st759;
		case 111: goto st759;
	}
	goto tr896;
st759:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof759;
case 759:
	switch( (*( sm->p)) ) {
		case 76: goto st760;
		case 108: goto st760;
	}
	goto tr896;
st760:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof760;
case 760:
	switch( (*( sm->p)) ) {
		case 9: goto st761;
		case 32: goto st761;
		case 62: goto tr927;
		case 71: goto st771;
		case 103: goto st771;
	}
	goto tr896;
tr941:
#line 132 "ext/dtext/dtext.cpp.rl"
	{ save_tag_attribute(sm, { sm->a1, sm->a2 }, { sm->b1, sm->b2 }); }
	goto st761;
tr945:
#line 120 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
#line 132 "ext/dtext/dtext.cpp.rl"
	{ save_tag_attribute(sm, { sm->a1, sm->a2 }, { sm->b1, sm->b2 }); }
	goto st761;
st761:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof761;
case 761:
#line 24298 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto st761;
		case 32: goto st761;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr929;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr929;
	} else
		goto tr929;
	goto tr896;
tr929:
#line 117 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st762;
st762:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof762;
case 762:
#line 24320 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto tr930;
		case 32: goto tr930;
		case 61: goto tr932;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st762;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st762;
	} else
		goto st762;
	goto tr896;
tr930:
#line 118 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
	goto st763;
st763:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof763;
case 763:
#line 24343 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto st763;
		case 32: goto st763;
		case 61: goto st764;
	}
	goto tr896;
tr932:
#line 118 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
	goto st764;
st764:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof764;
case 764:
#line 24358 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto st764;
		case 32: goto st764;
		case 34: goto st765;
		case 39: goto st768;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr937;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr937;
	} else
		goto tr937;
	goto tr896;
st765:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof765;
case 765:
	switch( (*( sm->p)) ) {
		case 10: goto tr896;
		case 13: goto tr896;
	}
	goto tr938;
tr938:
#line 119 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st766;
st766:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof766;
case 766:
#line 24391 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 10: goto tr896;
		case 13: goto tr896;
		case 34: goto tr940;
	}
	goto st766;
tr940:
#line 120 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
	goto st767;
st767:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof767;
case 767:
#line 24406 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto tr941;
		case 32: goto tr941;
		case 62: goto tr942;
	}
	goto tr896;
st768:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof768;
case 768:
	switch( (*( sm->p)) ) {
		case 10: goto tr896;
		case 13: goto tr896;
	}
	goto tr943;
tr943:
#line 119 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st769;
st769:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof769;
case 769:
#line 24430 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 10: goto tr896;
		case 13: goto tr896;
		case 39: goto tr940;
	}
	goto st769;
tr937:
#line 119 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st770;
st770:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof770;
case 770:
#line 24445 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto tr945;
		case 32: goto tr945;
		case 62: goto tr947;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st770;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st770;
	} else
		goto st770;
	goto tr896;
st771:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof771;
case 771:
	switch( (*( sm->p)) ) {
		case 82: goto st772;
		case 114: goto st772;
	}
	goto tr896;
st772:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof772;
case 772:
	switch( (*( sm->p)) ) {
		case 79: goto st773;
		case 111: goto st773;
	}
	goto tr896;
st773:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof773;
case 773:
	switch( (*( sm->p)) ) {
		case 85: goto st774;
		case 117: goto st774;
	}
	goto tr896;
st774:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof774;
case 774:
	switch( (*( sm->p)) ) {
		case 80: goto st775;
		case 112: goto st775;
	}
	goto tr896;
st775:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof775;
case 775:
	switch( (*( sm->p)) ) {
		case 9: goto st776;
		case 32: goto st776;
		case 62: goto tr953;
	}
	goto tr896;
tr966:
#line 132 "ext/dtext/dtext.cpp.rl"
	{ save_tag_attribute(sm, { sm->a1, sm->a2 }, { sm->b1, sm->b2 }); }
	goto st776;
tr970:
#line 120 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
#line 132 "ext/dtext/dtext.cpp.rl"
	{ save_tag_attribute(sm, { sm->a1, sm->a2 }, { sm->b1, sm->b2 }); }
	goto st776;
st776:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof776;
case 776:
#line 24520 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto st776;
		case 32: goto st776;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr954;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr954;
	} else
		goto tr954;
	goto tr896;
tr954:
#line 117 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st777;
st777:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof777;
case 777:
#line 24542 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto tr955;
		case 32: goto tr955;
		case 61: goto tr957;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st777;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st777;
	} else
		goto st777;
	goto tr896;
tr955:
#line 118 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
	goto st778;
st778:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof778;
case 778:
#line 24565 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto st778;
		case 32: goto st778;
		case 61: goto st779;
	}
	goto tr896;
tr957:
#line 118 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
	goto st779;
st779:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof779;
case 779:
#line 24580 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto st779;
		case 32: goto st779;
		case 34: goto st780;
		case 39: goto st783;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr962;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr962;
	} else
		goto tr962;
	goto tr896;
st780:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof780;
case 780:
	switch( (*( sm->p)) ) {
		case 10: goto tr896;
		case 13: goto tr896;
	}
	goto tr963;
tr963:
#line 119 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st781;
st781:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof781;
case 781:
#line 24613 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 10: goto tr896;
		case 13: goto tr896;
		case 34: goto tr965;
	}
	goto st781;
tr965:
#line 120 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
	goto st782;
st782:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof782;
case 782:
#line 24628 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto tr966;
		case 32: goto tr966;
		case 62: goto tr967;
	}
	goto tr896;
st783:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof783;
case 783:
	switch( (*( sm->p)) ) {
		case 10: goto tr896;
		case 13: goto tr896;
	}
	goto tr968;
tr968:
#line 119 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st784;
st784:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof784;
case 784:
#line 24652 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 10: goto tr896;
		case 13: goto tr896;
		case 39: goto tr965;
	}
	goto st784;
tr962:
#line 119 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st785;
st785:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof785;
case 785:
#line 24667 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto tr970;
		case 32: goto tr970;
		case 62: goto tr972;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st785;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st785;
	} else
		goto st785;
	goto tr896;
st786:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof786;
case 786:
	switch( (*( sm->p)) ) {
		case 66: goto st787;
		case 68: goto st801;
		case 72: goto st812;
		case 82: goto st836;
		case 98: goto st787;
		case 100: goto st801;
		case 104: goto st812;
		case 114: goto st836;
	}
	goto tr896;
st787:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof787;
case 787:
	switch( (*( sm->p)) ) {
		case 79: goto st788;
		case 111: goto st788;
	}
	goto tr896;
st788:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof788;
case 788:
	switch( (*( sm->p)) ) {
		case 68: goto st789;
		case 100: goto st789;
	}
	goto tr896;
st789:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof789;
case 789:
	switch( (*( sm->p)) ) {
		case 89: goto st790;
		case 121: goto st790;
	}
	goto tr896;
st790:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof790;
case 790:
	switch( (*( sm->p)) ) {
		case 9: goto st791;
		case 32: goto st791;
		case 62: goto tr981;
	}
	goto tr896;
tr994:
#line 132 "ext/dtext/dtext.cpp.rl"
	{ save_tag_attribute(sm, { sm->a1, sm->a2 }, { sm->b1, sm->b2 }); }
	goto st791;
tr998:
#line 120 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
#line 132 "ext/dtext/dtext.cpp.rl"
	{ save_tag_attribute(sm, { sm->a1, sm->a2 }, { sm->b1, sm->b2 }); }
	goto st791;
st791:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof791;
case 791:
#line 24748 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto st791;
		case 32: goto st791;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr982;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr982;
	} else
		goto tr982;
	goto tr896;
tr982:
#line 117 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st792;
st792:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof792;
case 792:
#line 24770 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto tr983;
		case 32: goto tr983;
		case 61: goto tr985;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st792;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st792;
	} else
		goto st792;
	goto tr896;
tr983:
#line 118 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
	goto st793;
st793:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof793;
case 793:
#line 24793 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto st793;
		case 32: goto st793;
		case 61: goto st794;
	}
	goto tr896;
tr985:
#line 118 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
	goto st794;
st794:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof794;
case 794:
#line 24808 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto st794;
		case 32: goto st794;
		case 34: goto st795;
		case 39: goto st798;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr990;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr990;
	} else
		goto tr990;
	goto tr896;
st795:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof795;
case 795:
	switch( (*( sm->p)) ) {
		case 10: goto tr896;
		case 13: goto tr896;
	}
	goto tr991;
tr991:
#line 119 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st796;
st796:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof796;
case 796:
#line 24841 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 10: goto tr896;
		case 13: goto tr896;
		case 34: goto tr993;
	}
	goto st796;
tr993:
#line 120 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
	goto st797;
st797:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof797;
case 797:
#line 24856 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto tr994;
		case 32: goto tr994;
		case 62: goto tr995;
	}
	goto tr896;
st798:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof798;
case 798:
	switch( (*( sm->p)) ) {
		case 10: goto tr896;
		case 13: goto tr896;
	}
	goto tr996;
tr996:
#line 119 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st799;
st799:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof799;
case 799:
#line 24880 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 10: goto tr896;
		case 13: goto tr896;
		case 39: goto tr993;
	}
	goto st799;
tr990:
#line 119 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st800;
st800:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof800;
case 800:
#line 24895 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto tr998;
		case 32: goto tr998;
		case 62: goto tr1000;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st800;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st800;
	} else
		goto st800;
	goto tr896;
st801:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof801;
case 801:
	switch( (*( sm->p)) ) {
		case 9: goto st802;
		case 32: goto st802;
		case 62: goto tr1002;
	}
	goto tr896;
tr1015:
#line 132 "ext/dtext/dtext.cpp.rl"
	{ save_tag_attribute(sm, { sm->a1, sm->a2 }, { sm->b1, sm->b2 }); }
	goto st802;
tr1019:
#line 120 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
#line 132 "ext/dtext/dtext.cpp.rl"
	{ save_tag_attribute(sm, { sm->a1, sm->a2 }, { sm->b1, sm->b2 }); }
	goto st802;
st802:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof802;
case 802:
#line 24934 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto st802;
		case 32: goto st802;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1003;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1003;
	} else
		goto tr1003;
	goto tr896;
tr1003:
#line 117 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st803;
st803:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof803;
case 803:
#line 24956 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto tr1004;
		case 32: goto tr1004;
		case 61: goto tr1006;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st803;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st803;
	} else
		goto st803;
	goto tr896;
tr1004:
#line 118 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
	goto st804;
st804:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof804;
case 804:
#line 24979 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto st804;
		case 32: goto st804;
		case 61: goto st805;
	}
	goto tr896;
tr1006:
#line 118 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
	goto st805;
st805:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof805;
case 805:
#line 24994 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto st805;
		case 32: goto st805;
		case 34: goto st806;
		case 39: goto st809;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1011;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1011;
	} else
		goto tr1011;
	goto tr896;
st806:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof806;
case 806:
	switch( (*( sm->p)) ) {
		case 10: goto tr896;
		case 13: goto tr896;
	}
	goto tr1012;
tr1012:
#line 119 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st807;
st807:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof807;
case 807:
#line 25027 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 10: goto tr896;
		case 13: goto tr896;
		case 34: goto tr1014;
	}
	goto st807;
tr1014:
#line 120 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
	goto st808;
st808:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof808;
case 808:
#line 25042 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto tr1015;
		case 32: goto tr1015;
		case 62: goto tr1016;
	}
	goto tr896;
st809:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof809;
case 809:
	switch( (*( sm->p)) ) {
		case 10: goto tr896;
		case 13: goto tr896;
	}
	goto tr1017;
tr1017:
#line 119 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st810;
st810:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof810;
case 810:
#line 25066 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 10: goto tr896;
		case 13: goto tr896;
		case 39: goto tr1014;
	}
	goto st810;
tr1011:
#line 119 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st811;
st811:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof811;
case 811:
#line 25081 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto tr1019;
		case 32: goto tr1019;
		case 62: goto tr1021;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st811;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st811;
	} else
		goto st811;
	goto tr896;
st812:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof812;
case 812:
	switch( (*( sm->p)) ) {
		case 9: goto st813;
		case 32: goto st813;
		case 62: goto tr1023;
		case 69: goto st823;
		case 101: goto st823;
	}
	goto tr896;
tr1037:
#line 132 "ext/dtext/dtext.cpp.rl"
	{ save_tag_attribute(sm, { sm->a1, sm->a2 }, { sm->b1, sm->b2 }); }
	goto st813;
tr1041:
#line 120 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
#line 132 "ext/dtext/dtext.cpp.rl"
	{ save_tag_attribute(sm, { sm->a1, sm->a2 }, { sm->b1, sm->b2 }); }
	goto st813;
st813:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof813;
case 813:
#line 25122 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto st813;
		case 32: goto st813;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1025;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1025;
	} else
		goto tr1025;
	goto tr896;
tr1025:
#line 117 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st814;
st814:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof814;
case 814:
#line 25144 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto tr1026;
		case 32: goto tr1026;
		case 61: goto tr1028;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st814;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st814;
	} else
		goto st814;
	goto tr896;
tr1026:
#line 118 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
	goto st815;
st815:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof815;
case 815:
#line 25167 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto st815;
		case 32: goto st815;
		case 61: goto st816;
	}
	goto tr896;
tr1028:
#line 118 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
	goto st816;
st816:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof816;
case 816:
#line 25182 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto st816;
		case 32: goto st816;
		case 34: goto st817;
		case 39: goto st820;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1033;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1033;
	} else
		goto tr1033;
	goto tr896;
st817:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof817;
case 817:
	switch( (*( sm->p)) ) {
		case 10: goto tr896;
		case 13: goto tr896;
	}
	goto tr1034;
tr1034:
#line 119 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st818;
st818:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof818;
case 818:
#line 25215 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 10: goto tr896;
		case 13: goto tr896;
		case 34: goto tr1036;
	}
	goto st818;
tr1036:
#line 120 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
	goto st819;
st819:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof819;
case 819:
#line 25230 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto tr1037;
		case 32: goto tr1037;
		case 62: goto tr1038;
	}
	goto tr896;
st820:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof820;
case 820:
	switch( (*( sm->p)) ) {
		case 10: goto tr896;
		case 13: goto tr896;
	}
	goto tr1039;
tr1039:
#line 119 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st821;
st821:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof821;
case 821:
#line 25254 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 10: goto tr896;
		case 13: goto tr896;
		case 39: goto tr1036;
	}
	goto st821;
tr1033:
#line 119 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st822;
st822:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof822;
case 822:
#line 25269 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto tr1041;
		case 32: goto tr1041;
		case 62: goto tr1043;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st822;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st822;
	} else
		goto st822;
	goto tr896;
st823:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof823;
case 823:
	switch( (*( sm->p)) ) {
		case 65: goto st824;
		case 97: goto st824;
	}
	goto tr896;
st824:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof824;
case 824:
	switch( (*( sm->p)) ) {
		case 68: goto st825;
		case 100: goto st825;
	}
	goto tr896;
st825:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof825;
case 825:
	switch( (*( sm->p)) ) {
		case 9: goto st826;
		case 32: goto st826;
		case 62: goto tr1047;
	}
	goto tr896;
tr1060:
#line 132 "ext/dtext/dtext.cpp.rl"
	{ save_tag_attribute(sm, { sm->a1, sm->a2 }, { sm->b1, sm->b2 }); }
	goto st826;
tr1064:
#line 120 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
#line 132 "ext/dtext/dtext.cpp.rl"
	{ save_tag_attribute(sm, { sm->a1, sm->a2 }, { sm->b1, sm->b2 }); }
	goto st826;
st826:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof826;
case 826:
#line 25326 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto st826;
		case 32: goto st826;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1048;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1048;
	} else
		goto tr1048;
	goto tr896;
tr1048:
#line 117 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st827;
st827:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof827;
case 827:
#line 25348 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto tr1049;
		case 32: goto tr1049;
		case 61: goto tr1051;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st827;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st827;
	} else
		goto st827;
	goto tr896;
tr1049:
#line 118 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
	goto st828;
st828:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof828;
case 828:
#line 25371 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto st828;
		case 32: goto st828;
		case 61: goto st829;
	}
	goto tr896;
tr1051:
#line 118 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
	goto st829;
st829:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof829;
case 829:
#line 25386 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto st829;
		case 32: goto st829;
		case 34: goto st830;
		case 39: goto st833;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1056;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1056;
	} else
		goto tr1056;
	goto tr896;
st830:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof830;
case 830:
	switch( (*( sm->p)) ) {
		case 10: goto tr896;
		case 13: goto tr896;
	}
	goto tr1057;
tr1057:
#line 119 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st831;
st831:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof831;
case 831:
#line 25419 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 10: goto tr896;
		case 13: goto tr896;
		case 34: goto tr1059;
	}
	goto st831;
tr1059:
#line 120 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
	goto st832;
st832:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof832;
case 832:
#line 25434 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto tr1060;
		case 32: goto tr1060;
		case 62: goto tr1061;
	}
	goto tr896;
st833:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof833;
case 833:
	switch( (*( sm->p)) ) {
		case 10: goto tr896;
		case 13: goto tr896;
	}
	goto tr1062;
tr1062:
#line 119 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st834;
st834:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof834;
case 834:
#line 25458 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 10: goto tr896;
		case 13: goto tr896;
		case 39: goto tr1059;
	}
	goto st834;
tr1056:
#line 119 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st835;
st835:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof835;
case 835:
#line 25473 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto tr1064;
		case 32: goto tr1064;
		case 62: goto tr1066;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st835;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st835;
	} else
		goto st835;
	goto tr896;
st836:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof836;
case 836:
	switch( (*( sm->p)) ) {
		case 9: goto st837;
		case 32: goto st837;
		case 62: goto tr1068;
	}
	goto tr896;
tr1081:
#line 132 "ext/dtext/dtext.cpp.rl"
	{ save_tag_attribute(sm, { sm->a1, sm->a2 }, { sm->b1, sm->b2 }); }
	goto st837;
tr1085:
#line 120 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
#line 132 "ext/dtext/dtext.cpp.rl"
	{ save_tag_attribute(sm, { sm->a1, sm->a2 }, { sm->b1, sm->b2 }); }
	goto st837;
st837:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof837;
case 837:
#line 25512 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto st837;
		case 32: goto st837;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1069;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1069;
	} else
		goto tr1069;
	goto tr896;
tr1069:
#line 117 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st838;
st838:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof838;
case 838:
#line 25534 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto tr1070;
		case 32: goto tr1070;
		case 61: goto tr1072;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st838;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st838;
	} else
		goto st838;
	goto tr896;
tr1070:
#line 118 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
	goto st839;
st839:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof839;
case 839:
#line 25557 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto st839;
		case 32: goto st839;
		case 61: goto st840;
	}
	goto tr896;
tr1072:
#line 118 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
	goto st840;
st840:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof840;
case 840:
#line 25572 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto st840;
		case 32: goto st840;
		case 34: goto st841;
		case 39: goto st844;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1077;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1077;
	} else
		goto tr1077;
	goto tr896;
st841:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof841;
case 841:
	switch( (*( sm->p)) ) {
		case 10: goto tr896;
		case 13: goto tr896;
	}
	goto tr1078;
tr1078:
#line 119 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st842;
st842:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof842;
case 842:
#line 25605 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 10: goto tr896;
		case 13: goto tr896;
		case 34: goto tr1080;
	}
	goto st842;
tr1080:
#line 120 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
	goto st843;
st843:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof843;
case 843:
#line 25620 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto tr1081;
		case 32: goto tr1081;
		case 62: goto tr1082;
	}
	goto tr896;
st844:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof844;
case 844:
	switch( (*( sm->p)) ) {
		case 10: goto tr896;
		case 13: goto tr896;
	}
	goto tr1083;
tr1083:
#line 119 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st845;
st845:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof845;
case 845:
#line 25644 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 10: goto tr896;
		case 13: goto tr896;
		case 39: goto tr1080;
	}
	goto st845;
tr1077:
#line 119 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st846;
st846:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof846;
case 846:
#line 25659 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto tr1085;
		case 32: goto tr1085;
		case 62: goto tr1087;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st846;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st846;
	} else
		goto st846;
	goto tr896;
tr1701:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
	goto st1245;
st1245:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1245;
case 1245:
#line 25682 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 47: goto st847;
		case 67: goto st870;
		case 84: goto st898;
		case 99: goto st870;
		case 116: goto st898;
	}
	goto tr1702;
st847:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof847;
case 847:
	switch( (*( sm->p)) ) {
		case 67: goto st848;
		case 84: goto st856;
		case 99: goto st848;
		case 116: goto st856;
	}
	goto tr896;
st848:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof848;
case 848:
	switch( (*( sm->p)) ) {
		case 79: goto st849;
		case 111: goto st849;
	}
	goto tr896;
st849:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof849;
case 849:
	switch( (*( sm->p)) ) {
		case 76: goto st850;
		case 108: goto st850;
	}
	goto tr896;
st850:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof850;
case 850:
	switch( (*( sm->p)) ) {
		case 71: goto st851;
		case 103: goto st851;
	}
	goto tr896;
st851:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof851;
case 851:
	switch( (*( sm->p)) ) {
		case 82: goto st852;
		case 114: goto st852;
	}
	goto tr896;
st852:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof852;
case 852:
	switch( (*( sm->p)) ) {
		case 79: goto st853;
		case 111: goto st853;
	}
	goto tr896;
st853:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof853;
case 853:
	switch( (*( sm->p)) ) {
		case 85: goto st854;
		case 117: goto st854;
	}
	goto tr896;
st854:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof854;
case 854:
	switch( (*( sm->p)) ) {
		case 80: goto st855;
		case 112: goto st855;
	}
	goto tr896;
st855:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof855;
case 855:
	if ( (*( sm->p)) == 93 )
		goto tr906;
	goto tr896;
st856:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof856;
case 856:
	switch( (*( sm->p)) ) {
		case 65: goto st857;
		case 66: goto st861;
		case 72: goto st865;
		case 82: goto st869;
		case 97: goto st857;
		case 98: goto st861;
		case 104: goto st865;
		case 114: goto st869;
	}
	goto tr896;
st857:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof857;
case 857:
	switch( (*( sm->p)) ) {
		case 66: goto st858;
		case 98: goto st858;
	}
	goto tr896;
st858:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof858;
case 858:
	switch( (*( sm->p)) ) {
		case 76: goto st859;
		case 108: goto st859;
	}
	goto tr896;
st859:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof859;
case 859:
	switch( (*( sm->p)) ) {
		case 69: goto st860;
		case 101: goto st860;
	}
	goto tr896;
st860:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof860;
case 860:
	if ( (*( sm->p)) == 93 )
		goto tr914;
	goto tr896;
st861:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof861;
case 861:
	switch( (*( sm->p)) ) {
		case 79: goto st862;
		case 111: goto st862;
	}
	goto tr896;
st862:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof862;
case 862:
	switch( (*( sm->p)) ) {
		case 68: goto st863;
		case 100: goto st863;
	}
	goto tr896;
st863:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof863;
case 863:
	switch( (*( sm->p)) ) {
		case 89: goto st864;
		case 121: goto st864;
	}
	goto tr896;
st864:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof864;
case 864:
	if ( (*( sm->p)) == 93 )
		goto tr918;
	goto tr896;
st865:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof865;
case 865:
	switch( (*( sm->p)) ) {
		case 69: goto st866;
		case 101: goto st866;
	}
	goto tr896;
st866:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof866;
case 866:
	switch( (*( sm->p)) ) {
		case 65: goto st867;
		case 97: goto st867;
	}
	goto tr896;
st867:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof867;
case 867:
	switch( (*( sm->p)) ) {
		case 68: goto st868;
		case 100: goto st868;
	}
	goto tr896;
st868:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof868;
case 868:
	if ( (*( sm->p)) == 93 )
		goto tr922;
	goto tr896;
st869:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof869;
case 869:
	if ( (*( sm->p)) == 93 )
		goto tr923;
	goto tr896;
st870:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof870;
case 870:
	switch( (*( sm->p)) ) {
		case 79: goto st871;
		case 111: goto st871;
	}
	goto tr896;
st871:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof871;
case 871:
	switch( (*( sm->p)) ) {
		case 76: goto st872;
		case 108: goto st872;
	}
	goto tr896;
st872:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof872;
case 872:
	switch( (*( sm->p)) ) {
		case 9: goto st873;
		case 32: goto st873;
		case 71: goto st883;
		case 93: goto tr927;
		case 103: goto st883;
	}
	goto tr896;
tr1126:
#line 132 "ext/dtext/dtext.cpp.rl"
	{ save_tag_attribute(sm, { sm->a1, sm->a2 }, { sm->b1, sm->b2 }); }
	goto st873;
tr1129:
#line 120 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
#line 132 "ext/dtext/dtext.cpp.rl"
	{ save_tag_attribute(sm, { sm->a1, sm->a2 }, { sm->b1, sm->b2 }); }
	goto st873;
st873:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof873;
case 873:
#line 25940 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto st873;
		case 32: goto st873;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1114;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1114;
	} else
		goto tr1114;
	goto tr896;
tr1114:
#line 117 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st874;
st874:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof874;
case 874:
#line 25962 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto tr1115;
		case 32: goto tr1115;
		case 61: goto tr1117;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st874;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st874;
	} else
		goto st874;
	goto tr896;
tr1115:
#line 118 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
	goto st875;
st875:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof875;
case 875:
#line 25985 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto st875;
		case 32: goto st875;
		case 61: goto st876;
	}
	goto tr896;
tr1117:
#line 118 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
	goto st876;
st876:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof876;
case 876:
#line 26000 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto st876;
		case 32: goto st876;
		case 34: goto st877;
		case 39: goto st880;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1122;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1122;
	} else
		goto tr1122;
	goto tr896;
st877:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof877;
case 877:
	switch( (*( sm->p)) ) {
		case 10: goto tr896;
		case 13: goto tr896;
	}
	goto tr1123;
tr1123:
#line 119 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st878;
st878:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof878;
case 878:
#line 26033 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 10: goto tr896;
		case 13: goto tr896;
		case 34: goto tr1125;
	}
	goto st878;
tr1125:
#line 120 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
	goto st879;
st879:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof879;
case 879:
#line 26048 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto tr1126;
		case 32: goto tr1126;
		case 93: goto tr942;
	}
	goto tr896;
st880:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof880;
case 880:
	switch( (*( sm->p)) ) {
		case 10: goto tr896;
		case 13: goto tr896;
	}
	goto tr1127;
tr1127:
#line 119 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st881;
st881:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof881;
case 881:
#line 26072 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 10: goto tr896;
		case 13: goto tr896;
		case 39: goto tr1125;
	}
	goto st881;
tr1122:
#line 119 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st882;
st882:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof882;
case 882:
#line 26087 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto tr1129;
		case 32: goto tr1129;
		case 93: goto tr947;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st882;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st882;
	} else
		goto st882;
	goto tr896;
st883:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof883;
case 883:
	switch( (*( sm->p)) ) {
		case 82: goto st884;
		case 114: goto st884;
	}
	goto tr896;
st884:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof884;
case 884:
	switch( (*( sm->p)) ) {
		case 79: goto st885;
		case 111: goto st885;
	}
	goto tr896;
st885:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof885;
case 885:
	switch( (*( sm->p)) ) {
		case 85: goto st886;
		case 117: goto st886;
	}
	goto tr896;
st886:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof886;
case 886:
	switch( (*( sm->p)) ) {
		case 80: goto st887;
		case 112: goto st887;
	}
	goto tr896;
st887:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof887;
case 887:
	switch( (*( sm->p)) ) {
		case 9: goto st888;
		case 32: goto st888;
		case 93: goto tr953;
	}
	goto tr896;
tr1148:
#line 132 "ext/dtext/dtext.cpp.rl"
	{ save_tag_attribute(sm, { sm->a1, sm->a2 }, { sm->b1, sm->b2 }); }
	goto st888;
tr1151:
#line 120 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
#line 132 "ext/dtext/dtext.cpp.rl"
	{ save_tag_attribute(sm, { sm->a1, sm->a2 }, { sm->b1, sm->b2 }); }
	goto st888;
st888:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof888;
case 888:
#line 26162 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto st888;
		case 32: goto st888;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1136;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1136;
	} else
		goto tr1136;
	goto tr896;
tr1136:
#line 117 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st889;
st889:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof889;
case 889:
#line 26184 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto tr1137;
		case 32: goto tr1137;
		case 61: goto tr1139;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st889;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st889;
	} else
		goto st889;
	goto tr896;
tr1137:
#line 118 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
	goto st890;
st890:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof890;
case 890:
#line 26207 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto st890;
		case 32: goto st890;
		case 61: goto st891;
	}
	goto tr896;
tr1139:
#line 118 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
	goto st891;
st891:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof891;
case 891:
#line 26222 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto st891;
		case 32: goto st891;
		case 34: goto st892;
		case 39: goto st895;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1144;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1144;
	} else
		goto tr1144;
	goto tr896;
st892:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof892;
case 892:
	switch( (*( sm->p)) ) {
		case 10: goto tr896;
		case 13: goto tr896;
	}
	goto tr1145;
tr1145:
#line 119 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st893;
st893:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof893;
case 893:
#line 26255 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 10: goto tr896;
		case 13: goto tr896;
		case 34: goto tr1147;
	}
	goto st893;
tr1147:
#line 120 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
	goto st894;
st894:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof894;
case 894:
#line 26270 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto tr1148;
		case 32: goto tr1148;
		case 93: goto tr967;
	}
	goto tr896;
st895:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof895;
case 895:
	switch( (*( sm->p)) ) {
		case 10: goto tr896;
		case 13: goto tr896;
	}
	goto tr1149;
tr1149:
#line 119 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st896;
st896:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof896;
case 896:
#line 26294 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 10: goto tr896;
		case 13: goto tr896;
		case 39: goto tr1147;
	}
	goto st896;
tr1144:
#line 119 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st897;
st897:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof897;
case 897:
#line 26309 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto tr1151;
		case 32: goto tr1151;
		case 93: goto tr972;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st897;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st897;
	} else
		goto st897;
	goto tr896;
st898:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof898;
case 898:
	switch( (*( sm->p)) ) {
		case 66: goto st899;
		case 68: goto st913;
		case 72: goto st924;
		case 82: goto st948;
		case 98: goto st899;
		case 100: goto st913;
		case 104: goto st924;
		case 114: goto st948;
	}
	goto tr896;
st899:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof899;
case 899:
	switch( (*( sm->p)) ) {
		case 79: goto st900;
		case 111: goto st900;
	}
	goto tr896;
st900:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof900;
case 900:
	switch( (*( sm->p)) ) {
		case 68: goto st901;
		case 100: goto st901;
	}
	goto tr896;
st901:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof901;
case 901:
	switch( (*( sm->p)) ) {
		case 89: goto st902;
		case 121: goto st902;
	}
	goto tr896;
st902:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof902;
case 902:
	switch( (*( sm->p)) ) {
		case 9: goto st903;
		case 32: goto st903;
		case 93: goto tr981;
	}
	goto tr896;
tr1173:
#line 132 "ext/dtext/dtext.cpp.rl"
	{ save_tag_attribute(sm, { sm->a1, sm->a2 }, { sm->b1, sm->b2 }); }
	goto st903;
tr1176:
#line 120 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
#line 132 "ext/dtext/dtext.cpp.rl"
	{ save_tag_attribute(sm, { sm->a1, sm->a2 }, { sm->b1, sm->b2 }); }
	goto st903;
st903:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof903;
case 903:
#line 26390 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto st903;
		case 32: goto st903;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1161;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1161;
	} else
		goto tr1161;
	goto tr896;
tr1161:
#line 117 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st904;
st904:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof904;
case 904:
#line 26412 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto tr1162;
		case 32: goto tr1162;
		case 61: goto tr1164;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st904;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st904;
	} else
		goto st904;
	goto tr896;
tr1162:
#line 118 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
	goto st905;
st905:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof905;
case 905:
#line 26435 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto st905;
		case 32: goto st905;
		case 61: goto st906;
	}
	goto tr896;
tr1164:
#line 118 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
	goto st906;
st906:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof906;
case 906:
#line 26450 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto st906;
		case 32: goto st906;
		case 34: goto st907;
		case 39: goto st910;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1169;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1169;
	} else
		goto tr1169;
	goto tr896;
st907:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof907;
case 907:
	switch( (*( sm->p)) ) {
		case 10: goto tr896;
		case 13: goto tr896;
	}
	goto tr1170;
tr1170:
#line 119 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st908;
st908:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof908;
case 908:
#line 26483 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 10: goto tr896;
		case 13: goto tr896;
		case 34: goto tr1172;
	}
	goto st908;
tr1172:
#line 120 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
	goto st909;
st909:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof909;
case 909:
#line 26498 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto tr1173;
		case 32: goto tr1173;
		case 93: goto tr995;
	}
	goto tr896;
st910:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof910;
case 910:
	switch( (*( sm->p)) ) {
		case 10: goto tr896;
		case 13: goto tr896;
	}
	goto tr1174;
tr1174:
#line 119 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st911;
st911:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof911;
case 911:
#line 26522 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 10: goto tr896;
		case 13: goto tr896;
		case 39: goto tr1172;
	}
	goto st911;
tr1169:
#line 119 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st912;
st912:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof912;
case 912:
#line 26537 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto tr1176;
		case 32: goto tr1176;
		case 93: goto tr1000;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st912;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st912;
	} else
		goto st912;
	goto tr896;
st913:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof913;
case 913:
	switch( (*( sm->p)) ) {
		case 9: goto st914;
		case 32: goto st914;
		case 93: goto tr1002;
	}
	goto tr896;
tr1191:
#line 132 "ext/dtext/dtext.cpp.rl"
	{ save_tag_attribute(sm, { sm->a1, sm->a2 }, { sm->b1, sm->b2 }); }
	goto st914;
tr1194:
#line 120 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
#line 132 "ext/dtext/dtext.cpp.rl"
	{ save_tag_attribute(sm, { sm->a1, sm->a2 }, { sm->b1, sm->b2 }); }
	goto st914;
st914:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof914;
case 914:
#line 26576 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto st914;
		case 32: goto st914;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1179;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1179;
	} else
		goto tr1179;
	goto tr896;
tr1179:
#line 117 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st915;
st915:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof915;
case 915:
#line 26598 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto tr1180;
		case 32: goto tr1180;
		case 61: goto tr1182;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st915;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st915;
	} else
		goto st915;
	goto tr896;
tr1180:
#line 118 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
	goto st916;
st916:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof916;
case 916:
#line 26621 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto st916;
		case 32: goto st916;
		case 61: goto st917;
	}
	goto tr896;
tr1182:
#line 118 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
	goto st917;
st917:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof917;
case 917:
#line 26636 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto st917;
		case 32: goto st917;
		case 34: goto st918;
		case 39: goto st921;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1187;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1187;
	} else
		goto tr1187;
	goto tr896;
st918:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof918;
case 918:
	switch( (*( sm->p)) ) {
		case 10: goto tr896;
		case 13: goto tr896;
	}
	goto tr1188;
tr1188:
#line 119 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st919;
st919:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof919;
case 919:
#line 26669 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 10: goto tr896;
		case 13: goto tr896;
		case 34: goto tr1190;
	}
	goto st919;
tr1190:
#line 120 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
	goto st920;
st920:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof920;
case 920:
#line 26684 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto tr1191;
		case 32: goto tr1191;
		case 93: goto tr1016;
	}
	goto tr896;
st921:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof921;
case 921:
	switch( (*( sm->p)) ) {
		case 10: goto tr896;
		case 13: goto tr896;
	}
	goto tr1192;
tr1192:
#line 119 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st922;
st922:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof922;
case 922:
#line 26708 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 10: goto tr896;
		case 13: goto tr896;
		case 39: goto tr1190;
	}
	goto st922;
tr1187:
#line 119 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st923;
st923:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof923;
case 923:
#line 26723 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto tr1194;
		case 32: goto tr1194;
		case 93: goto tr1021;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st923;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st923;
	} else
		goto st923;
	goto tr896;
st924:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof924;
case 924:
	switch( (*( sm->p)) ) {
		case 9: goto st925;
		case 32: goto st925;
		case 69: goto st935;
		case 93: goto tr1023;
		case 101: goto st935;
	}
	goto tr896;
tr1210:
#line 132 "ext/dtext/dtext.cpp.rl"
	{ save_tag_attribute(sm, { sm->a1, sm->a2 }, { sm->b1, sm->b2 }); }
	goto st925;
tr1213:
#line 120 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
#line 132 "ext/dtext/dtext.cpp.rl"
	{ save_tag_attribute(sm, { sm->a1, sm->a2 }, { sm->b1, sm->b2 }); }
	goto st925;
st925:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof925;
case 925:
#line 26764 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto st925;
		case 32: goto st925;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1198;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1198;
	} else
		goto tr1198;
	goto tr896;
tr1198:
#line 117 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st926;
st926:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof926;
case 926:
#line 26786 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto tr1199;
		case 32: goto tr1199;
		case 61: goto tr1201;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st926;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st926;
	} else
		goto st926;
	goto tr896;
tr1199:
#line 118 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
	goto st927;
st927:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof927;
case 927:
#line 26809 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto st927;
		case 32: goto st927;
		case 61: goto st928;
	}
	goto tr896;
tr1201:
#line 118 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
	goto st928;
st928:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof928;
case 928:
#line 26824 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto st928;
		case 32: goto st928;
		case 34: goto st929;
		case 39: goto st932;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1206;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1206;
	} else
		goto tr1206;
	goto tr896;
st929:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof929;
case 929:
	switch( (*( sm->p)) ) {
		case 10: goto tr896;
		case 13: goto tr896;
	}
	goto tr1207;
tr1207:
#line 119 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st930;
st930:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof930;
case 930:
#line 26857 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 10: goto tr896;
		case 13: goto tr896;
		case 34: goto tr1209;
	}
	goto st930;
tr1209:
#line 120 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
	goto st931;
st931:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof931;
case 931:
#line 26872 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto tr1210;
		case 32: goto tr1210;
		case 93: goto tr1038;
	}
	goto tr896;
st932:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof932;
case 932:
	switch( (*( sm->p)) ) {
		case 10: goto tr896;
		case 13: goto tr896;
	}
	goto tr1211;
tr1211:
#line 119 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st933;
st933:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof933;
case 933:
#line 26896 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 10: goto tr896;
		case 13: goto tr896;
		case 39: goto tr1209;
	}
	goto st933;
tr1206:
#line 119 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st934;
st934:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof934;
case 934:
#line 26911 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto tr1213;
		case 32: goto tr1213;
		case 93: goto tr1043;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st934;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st934;
	} else
		goto st934;
	goto tr896;
st935:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof935;
case 935:
	switch( (*( sm->p)) ) {
		case 65: goto st936;
		case 97: goto st936;
	}
	goto tr896;
st936:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof936;
case 936:
	switch( (*( sm->p)) ) {
		case 68: goto st937;
		case 100: goto st937;
	}
	goto tr896;
st937:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof937;
case 937:
	switch( (*( sm->p)) ) {
		case 9: goto st938;
		case 32: goto st938;
		case 93: goto tr1047;
	}
	goto tr896;
tr1230:
#line 132 "ext/dtext/dtext.cpp.rl"
	{ save_tag_attribute(sm, { sm->a1, sm->a2 }, { sm->b1, sm->b2 }); }
	goto st938;
tr1233:
#line 120 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
#line 132 "ext/dtext/dtext.cpp.rl"
	{ save_tag_attribute(sm, { sm->a1, sm->a2 }, { sm->b1, sm->b2 }); }
	goto st938;
st938:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof938;
case 938:
#line 26968 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto st938;
		case 32: goto st938;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1218;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1218;
	} else
		goto tr1218;
	goto tr896;
tr1218:
#line 117 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st939;
st939:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof939;
case 939:
#line 26990 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto tr1219;
		case 32: goto tr1219;
		case 61: goto tr1221;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st939;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st939;
	} else
		goto st939;
	goto tr896;
tr1219:
#line 118 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
	goto st940;
st940:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof940;
case 940:
#line 27013 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto st940;
		case 32: goto st940;
		case 61: goto st941;
	}
	goto tr896;
tr1221:
#line 118 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
	goto st941;
st941:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof941;
case 941:
#line 27028 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto st941;
		case 32: goto st941;
		case 34: goto st942;
		case 39: goto st945;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1226;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1226;
	} else
		goto tr1226;
	goto tr896;
st942:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof942;
case 942:
	switch( (*( sm->p)) ) {
		case 10: goto tr896;
		case 13: goto tr896;
	}
	goto tr1227;
tr1227:
#line 119 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st943;
st943:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof943;
case 943:
#line 27061 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 10: goto tr896;
		case 13: goto tr896;
		case 34: goto tr1229;
	}
	goto st943;
tr1229:
#line 120 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
	goto st944;
st944:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof944;
case 944:
#line 27076 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto tr1230;
		case 32: goto tr1230;
		case 93: goto tr1061;
	}
	goto tr896;
st945:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof945;
case 945:
	switch( (*( sm->p)) ) {
		case 10: goto tr896;
		case 13: goto tr896;
	}
	goto tr1231;
tr1231:
#line 119 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st946;
st946:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof946;
case 946:
#line 27100 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 10: goto tr896;
		case 13: goto tr896;
		case 39: goto tr1229;
	}
	goto st946;
tr1226:
#line 119 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st947;
st947:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof947;
case 947:
#line 27115 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto tr1233;
		case 32: goto tr1233;
		case 93: goto tr1066;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st947;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st947;
	} else
		goto st947;
	goto tr896;
st948:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof948;
case 948:
	switch( (*( sm->p)) ) {
		case 9: goto st949;
		case 32: goto st949;
		case 93: goto tr1068;
	}
	goto tr896;
tr1248:
#line 132 "ext/dtext/dtext.cpp.rl"
	{ save_tag_attribute(sm, { sm->a1, sm->a2 }, { sm->b1, sm->b2 }); }
	goto st949;
tr1251:
#line 120 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
#line 132 "ext/dtext/dtext.cpp.rl"
	{ save_tag_attribute(sm, { sm->a1, sm->a2 }, { sm->b1, sm->b2 }); }
	goto st949;
st949:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof949;
case 949:
#line 27154 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto st949;
		case 32: goto st949;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1236;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1236;
	} else
		goto tr1236;
	goto tr896;
tr1236:
#line 117 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st950;
st950:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof950;
case 950:
#line 27176 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto tr1237;
		case 32: goto tr1237;
		case 61: goto tr1239;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st950;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st950;
	} else
		goto st950;
	goto tr896;
tr1237:
#line 118 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
	goto st951;
st951:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof951;
case 951:
#line 27199 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto st951;
		case 32: goto st951;
		case 61: goto st952;
	}
	goto tr896;
tr1239:
#line 118 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
	goto st952;
st952:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof952;
case 952:
#line 27214 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto st952;
		case 32: goto st952;
		case 34: goto st953;
		case 39: goto st956;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1244;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1244;
	} else
		goto tr1244;
	goto tr896;
st953:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof953;
case 953:
	switch( (*( sm->p)) ) {
		case 10: goto tr896;
		case 13: goto tr896;
	}
	goto tr1245;
tr1245:
#line 119 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st954;
st954:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof954;
case 954:
#line 27247 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 10: goto tr896;
		case 13: goto tr896;
		case 34: goto tr1247;
	}
	goto st954;
tr1247:
#line 120 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
	goto st955;
st955:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof955;
case 955:
#line 27262 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto tr1248;
		case 32: goto tr1248;
		case 93: goto tr1082;
	}
	goto tr896;
st956:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof956;
case 956:
	switch( (*( sm->p)) ) {
		case 10: goto tr896;
		case 13: goto tr896;
	}
	goto tr1249;
tr1249:
#line 119 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st957;
st957:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof957;
case 957:
#line 27286 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 10: goto tr896;
		case 13: goto tr896;
		case 39: goto tr1247;
	}
	goto st957;
tr1244:
#line 119 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st958;
st958:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof958;
case 958:
#line 27301 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto tr1251;
		case 32: goto tr1251;
		case 93: goto tr1087;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st958;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st958;
	} else
		goto st958;
	goto tr896;
	}
	_test_eof959:  sm->cs = 959; goto _test_eof; 
	_test_eof960:  sm->cs = 960; goto _test_eof; 
	_test_eof1:  sm->cs = 1; goto _test_eof; 
	_test_eof2:  sm->cs = 2; goto _test_eof; 
	_test_eof961:  sm->cs = 961; goto _test_eof; 
	_test_eof3:  sm->cs = 3; goto _test_eof; 
	_test_eof4:  sm->cs = 4; goto _test_eof; 
	_test_eof5:  sm->cs = 5; goto _test_eof; 
	_test_eof6:  sm->cs = 6; goto _test_eof; 
	_test_eof7:  sm->cs = 7; goto _test_eof; 
	_test_eof8:  sm->cs = 8; goto _test_eof; 
	_test_eof962:  sm->cs = 962; goto _test_eof; 
	_test_eof9:  sm->cs = 9; goto _test_eof; 
	_test_eof10:  sm->cs = 10; goto _test_eof; 
	_test_eof11:  sm->cs = 11; goto _test_eof; 
	_test_eof12:  sm->cs = 12; goto _test_eof; 
	_test_eof13:  sm->cs = 13; goto _test_eof; 
	_test_eof14:  sm->cs = 14; goto _test_eof; 
	_test_eof15:  sm->cs = 15; goto _test_eof; 
	_test_eof16:  sm->cs = 16; goto _test_eof; 
	_test_eof17:  sm->cs = 17; goto _test_eof; 
	_test_eof18:  sm->cs = 18; goto _test_eof; 
	_test_eof19:  sm->cs = 19; goto _test_eof; 
	_test_eof20:  sm->cs = 20; goto _test_eof; 
	_test_eof21:  sm->cs = 21; goto _test_eof; 
	_test_eof22:  sm->cs = 22; goto _test_eof; 
	_test_eof963:  sm->cs = 963; goto _test_eof; 
	_test_eof964:  sm->cs = 964; goto _test_eof; 
	_test_eof23:  sm->cs = 23; goto _test_eof; 
	_test_eof965:  sm->cs = 965; goto _test_eof; 
	_test_eof966:  sm->cs = 966; goto _test_eof; 
	_test_eof24:  sm->cs = 24; goto _test_eof; 
	_test_eof967:  sm->cs = 967; goto _test_eof; 
	_test_eof25:  sm->cs = 25; goto _test_eof; 
	_test_eof26:  sm->cs = 26; goto _test_eof; 
	_test_eof27:  sm->cs = 27; goto _test_eof; 
	_test_eof28:  sm->cs = 28; goto _test_eof; 
	_test_eof29:  sm->cs = 29; goto _test_eof; 
	_test_eof30:  sm->cs = 30; goto _test_eof; 
	_test_eof31:  sm->cs = 31; goto _test_eof; 
	_test_eof32:  sm->cs = 32; goto _test_eof; 
	_test_eof33:  sm->cs = 33; goto _test_eof; 
	_test_eof34:  sm->cs = 34; goto _test_eof; 
	_test_eof968:  sm->cs = 968; goto _test_eof; 
	_test_eof35:  sm->cs = 35; goto _test_eof; 
	_test_eof36:  sm->cs = 36; goto _test_eof; 
	_test_eof37:  sm->cs = 37; goto _test_eof; 
	_test_eof38:  sm->cs = 38; goto _test_eof; 
	_test_eof39:  sm->cs = 39; goto _test_eof; 
	_test_eof40:  sm->cs = 40; goto _test_eof; 
	_test_eof41:  sm->cs = 41; goto _test_eof; 
	_test_eof969:  sm->cs = 969; goto _test_eof; 
	_test_eof42:  sm->cs = 42; goto _test_eof; 
	_test_eof43:  sm->cs = 43; goto _test_eof; 
	_test_eof970:  sm->cs = 970; goto _test_eof; 
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
	_test_eof971:  sm->cs = 971; goto _test_eof; 
	_test_eof54:  sm->cs = 54; goto _test_eof; 
	_test_eof972:  sm->cs = 972; goto _test_eof; 
	_test_eof55:  sm->cs = 55; goto _test_eof; 
	_test_eof56:  sm->cs = 56; goto _test_eof; 
	_test_eof57:  sm->cs = 57; goto _test_eof; 
	_test_eof58:  sm->cs = 58; goto _test_eof; 
	_test_eof59:  sm->cs = 59; goto _test_eof; 
	_test_eof60:  sm->cs = 60; goto _test_eof; 
	_test_eof61:  sm->cs = 61; goto _test_eof; 
	_test_eof973:  sm->cs = 973; goto _test_eof; 
	_test_eof62:  sm->cs = 62; goto _test_eof; 
	_test_eof63:  sm->cs = 63; goto _test_eof; 
	_test_eof64:  sm->cs = 64; goto _test_eof; 
	_test_eof65:  sm->cs = 65; goto _test_eof; 
	_test_eof66:  sm->cs = 66; goto _test_eof; 
	_test_eof67:  sm->cs = 67; goto _test_eof; 
	_test_eof68:  sm->cs = 68; goto _test_eof; 
	_test_eof69:  sm->cs = 69; goto _test_eof; 
	_test_eof70:  sm->cs = 70; goto _test_eof; 
	_test_eof974:  sm->cs = 974; goto _test_eof; 
	_test_eof71:  sm->cs = 71; goto _test_eof; 
	_test_eof72:  sm->cs = 72; goto _test_eof; 
	_test_eof73:  sm->cs = 73; goto _test_eof; 
	_test_eof975:  sm->cs = 975; goto _test_eof; 
	_test_eof74:  sm->cs = 74; goto _test_eof; 
	_test_eof75:  sm->cs = 75; goto _test_eof; 
	_test_eof76:  sm->cs = 76; goto _test_eof; 
	_test_eof976:  sm->cs = 976; goto _test_eof; 
	_test_eof977:  sm->cs = 977; goto _test_eof; 
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
	_test_eof978:  sm->cs = 978; goto _test_eof; 
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
	_test_eof979:  sm->cs = 979; goto _test_eof; 
	_test_eof980:  sm->cs = 980; goto _test_eof; 
	_test_eof127:  sm->cs = 127; goto _test_eof; 
	_test_eof128:  sm->cs = 128; goto _test_eof; 
	_test_eof129:  sm->cs = 129; goto _test_eof; 
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
	_test_eof144:  sm->cs = 144; goto _test_eof; 
	_test_eof145:  sm->cs = 145; goto _test_eof; 
	_test_eof981:  sm->cs = 981; goto _test_eof; 
	_test_eof146:  sm->cs = 146; goto _test_eof; 
	_test_eof147:  sm->cs = 147; goto _test_eof; 
	_test_eof148:  sm->cs = 148; goto _test_eof; 
	_test_eof149:  sm->cs = 149; goto _test_eof; 
	_test_eof150:  sm->cs = 150; goto _test_eof; 
	_test_eof151:  sm->cs = 151; goto _test_eof; 
	_test_eof152:  sm->cs = 152; goto _test_eof; 
	_test_eof153:  sm->cs = 153; goto _test_eof; 
	_test_eof154:  sm->cs = 154; goto _test_eof; 
	_test_eof982:  sm->cs = 982; goto _test_eof; 
	_test_eof983:  sm->cs = 983; goto _test_eof; 
	_test_eof984:  sm->cs = 984; goto _test_eof; 
	_test_eof155:  sm->cs = 155; goto _test_eof; 
	_test_eof156:  sm->cs = 156; goto _test_eof; 
	_test_eof157:  sm->cs = 157; goto _test_eof; 
	_test_eof985:  sm->cs = 985; goto _test_eof; 
	_test_eof986:  sm->cs = 986; goto _test_eof; 
	_test_eof987:  sm->cs = 987; goto _test_eof; 
	_test_eof158:  sm->cs = 158; goto _test_eof; 
	_test_eof159:  sm->cs = 159; goto _test_eof; 
	_test_eof988:  sm->cs = 988; goto _test_eof; 
	_test_eof160:  sm->cs = 160; goto _test_eof; 
	_test_eof161:  sm->cs = 161; goto _test_eof; 
	_test_eof989:  sm->cs = 989; goto _test_eof; 
	_test_eof162:  sm->cs = 162; goto _test_eof; 
	_test_eof163:  sm->cs = 163; goto _test_eof; 
	_test_eof164:  sm->cs = 164; goto _test_eof; 
	_test_eof165:  sm->cs = 165; goto _test_eof; 
	_test_eof166:  sm->cs = 166; goto _test_eof; 
	_test_eof990:  sm->cs = 990; goto _test_eof; 
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
	_test_eof192:  sm->cs = 192; goto _test_eof; 
	_test_eof193:  sm->cs = 193; goto _test_eof; 
	_test_eof194:  sm->cs = 194; goto _test_eof; 
	_test_eof195:  sm->cs = 195; goto _test_eof; 
	_test_eof196:  sm->cs = 196; goto _test_eof; 
	_test_eof197:  sm->cs = 197; goto _test_eof; 
	_test_eof198:  sm->cs = 198; goto _test_eof; 
	_test_eof991:  sm->cs = 991; goto _test_eof; 
	_test_eof199:  sm->cs = 199; goto _test_eof; 
	_test_eof200:  sm->cs = 200; goto _test_eof; 
	_test_eof201:  sm->cs = 201; goto _test_eof; 
	_test_eof202:  sm->cs = 202; goto _test_eof; 
	_test_eof203:  sm->cs = 203; goto _test_eof; 
	_test_eof204:  sm->cs = 204; goto _test_eof; 
	_test_eof205:  sm->cs = 205; goto _test_eof; 
	_test_eof206:  sm->cs = 206; goto _test_eof; 
	_test_eof207:  sm->cs = 207; goto _test_eof; 
	_test_eof208:  sm->cs = 208; goto _test_eof; 
	_test_eof209:  sm->cs = 209; goto _test_eof; 
	_test_eof210:  sm->cs = 210; goto _test_eof; 
	_test_eof211:  sm->cs = 211; goto _test_eof; 
	_test_eof212:  sm->cs = 212; goto _test_eof; 
	_test_eof213:  sm->cs = 213; goto _test_eof; 
	_test_eof992:  sm->cs = 992; goto _test_eof; 
	_test_eof993:  sm->cs = 993; goto _test_eof; 
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
	_test_eof994:  sm->cs = 994; goto _test_eof; 
	_test_eof226:  sm->cs = 226; goto _test_eof; 
	_test_eof227:  sm->cs = 227; goto _test_eof; 
	_test_eof228:  sm->cs = 228; goto _test_eof; 
	_test_eof229:  sm->cs = 229; goto _test_eof; 
	_test_eof230:  sm->cs = 230; goto _test_eof; 
	_test_eof231:  sm->cs = 231; goto _test_eof; 
	_test_eof995:  sm->cs = 995; goto _test_eof; 
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
	_test_eof244:  sm->cs = 244; goto _test_eof; 
	_test_eof245:  sm->cs = 245; goto _test_eof; 
	_test_eof246:  sm->cs = 246; goto _test_eof; 
	_test_eof247:  sm->cs = 247; goto _test_eof; 
	_test_eof248:  sm->cs = 248; goto _test_eof; 
	_test_eof249:  sm->cs = 249; goto _test_eof; 
	_test_eof250:  sm->cs = 250; goto _test_eof; 
	_test_eof251:  sm->cs = 251; goto _test_eof; 
	_test_eof252:  sm->cs = 252; goto _test_eof; 
	_test_eof253:  sm->cs = 253; goto _test_eof; 
	_test_eof254:  sm->cs = 254; goto _test_eof; 
	_test_eof255:  sm->cs = 255; goto _test_eof; 
	_test_eof256:  sm->cs = 256; goto _test_eof; 
	_test_eof257:  sm->cs = 257; goto _test_eof; 
	_test_eof258:  sm->cs = 258; goto _test_eof; 
	_test_eof259:  sm->cs = 259; goto _test_eof; 
	_test_eof260:  sm->cs = 260; goto _test_eof; 
	_test_eof261:  sm->cs = 261; goto _test_eof; 
	_test_eof262:  sm->cs = 262; goto _test_eof; 
	_test_eof996:  sm->cs = 996; goto _test_eof; 
	_test_eof263:  sm->cs = 263; goto _test_eof; 
	_test_eof264:  sm->cs = 264; goto _test_eof; 
	_test_eof265:  sm->cs = 265; goto _test_eof; 
	_test_eof266:  sm->cs = 266; goto _test_eof; 
	_test_eof267:  sm->cs = 267; goto _test_eof; 
	_test_eof268:  sm->cs = 268; goto _test_eof; 
	_test_eof269:  sm->cs = 269; goto _test_eof; 
	_test_eof270:  sm->cs = 270; goto _test_eof; 
	_test_eof271:  sm->cs = 271; goto _test_eof; 
	_test_eof272:  sm->cs = 272; goto _test_eof; 
	_test_eof273:  sm->cs = 273; goto _test_eof; 
	_test_eof274:  sm->cs = 274; goto _test_eof; 
	_test_eof275:  sm->cs = 275; goto _test_eof; 
	_test_eof276:  sm->cs = 276; goto _test_eof; 
	_test_eof277:  sm->cs = 277; goto _test_eof; 
	_test_eof278:  sm->cs = 278; goto _test_eof; 
	_test_eof279:  sm->cs = 279; goto _test_eof; 
	_test_eof280:  sm->cs = 280; goto _test_eof; 
	_test_eof281:  sm->cs = 281; goto _test_eof; 
	_test_eof282:  sm->cs = 282; goto _test_eof; 
	_test_eof283:  sm->cs = 283; goto _test_eof; 
	_test_eof284:  sm->cs = 284; goto _test_eof; 
	_test_eof285:  sm->cs = 285; goto _test_eof; 
	_test_eof286:  sm->cs = 286; goto _test_eof; 
	_test_eof287:  sm->cs = 287; goto _test_eof; 
	_test_eof288:  sm->cs = 288; goto _test_eof; 
	_test_eof289:  sm->cs = 289; goto _test_eof; 
	_test_eof290:  sm->cs = 290; goto _test_eof; 
	_test_eof291:  sm->cs = 291; goto _test_eof; 
	_test_eof292:  sm->cs = 292; goto _test_eof; 
	_test_eof293:  sm->cs = 293; goto _test_eof; 
	_test_eof294:  sm->cs = 294; goto _test_eof; 
	_test_eof295:  sm->cs = 295; goto _test_eof; 
	_test_eof296:  sm->cs = 296; goto _test_eof; 
	_test_eof297:  sm->cs = 297; goto _test_eof; 
	_test_eof298:  sm->cs = 298; goto _test_eof; 
	_test_eof299:  sm->cs = 299; goto _test_eof; 
	_test_eof300:  sm->cs = 300; goto _test_eof; 
	_test_eof301:  sm->cs = 301; goto _test_eof; 
	_test_eof302:  sm->cs = 302; goto _test_eof; 
	_test_eof303:  sm->cs = 303; goto _test_eof; 
	_test_eof304:  sm->cs = 304; goto _test_eof; 
	_test_eof305:  sm->cs = 305; goto _test_eof; 
	_test_eof997:  sm->cs = 997; goto _test_eof; 
	_test_eof998:  sm->cs = 998; goto _test_eof; 
	_test_eof306:  sm->cs = 306; goto _test_eof; 
	_test_eof307:  sm->cs = 307; goto _test_eof; 
	_test_eof308:  sm->cs = 308; goto _test_eof; 
	_test_eof999:  sm->cs = 999; goto _test_eof; 
	_test_eof309:  sm->cs = 309; goto _test_eof; 
	_test_eof310:  sm->cs = 310; goto _test_eof; 
	_test_eof311:  sm->cs = 311; goto _test_eof; 
	_test_eof312:  sm->cs = 312; goto _test_eof; 
	_test_eof313:  sm->cs = 313; goto _test_eof; 
	_test_eof314:  sm->cs = 314; goto _test_eof; 
	_test_eof315:  sm->cs = 315; goto _test_eof; 
	_test_eof316:  sm->cs = 316; goto _test_eof; 
	_test_eof317:  sm->cs = 317; goto _test_eof; 
	_test_eof318:  sm->cs = 318; goto _test_eof; 
	_test_eof319:  sm->cs = 319; goto _test_eof; 
	_test_eof320:  sm->cs = 320; goto _test_eof; 
	_test_eof321:  sm->cs = 321; goto _test_eof; 
	_test_eof322:  sm->cs = 322; goto _test_eof; 
	_test_eof323:  sm->cs = 323; goto _test_eof; 
	_test_eof324:  sm->cs = 324; goto _test_eof; 
	_test_eof325:  sm->cs = 325; goto _test_eof; 
	_test_eof326:  sm->cs = 326; goto _test_eof; 
	_test_eof1000:  sm->cs = 1000; goto _test_eof; 
	_test_eof327:  sm->cs = 327; goto _test_eof; 
	_test_eof328:  sm->cs = 328; goto _test_eof; 
	_test_eof329:  sm->cs = 329; goto _test_eof; 
	_test_eof330:  sm->cs = 330; goto _test_eof; 
	_test_eof331:  sm->cs = 331; goto _test_eof; 
	_test_eof332:  sm->cs = 332; goto _test_eof; 
	_test_eof333:  sm->cs = 333; goto _test_eof; 
	_test_eof334:  sm->cs = 334; goto _test_eof; 
	_test_eof335:  sm->cs = 335; goto _test_eof; 
	_test_eof1001:  sm->cs = 1001; goto _test_eof; 
	_test_eof1002:  sm->cs = 1002; goto _test_eof; 
	_test_eof336:  sm->cs = 336; goto _test_eof; 
	_test_eof337:  sm->cs = 337; goto _test_eof; 
	_test_eof338:  sm->cs = 338; goto _test_eof; 
	_test_eof339:  sm->cs = 339; goto _test_eof; 
	_test_eof1003:  sm->cs = 1003; goto _test_eof; 
	_test_eof1004:  sm->cs = 1004; goto _test_eof; 
	_test_eof340:  sm->cs = 340; goto _test_eof; 
	_test_eof341:  sm->cs = 341; goto _test_eof; 
	_test_eof342:  sm->cs = 342; goto _test_eof; 
	_test_eof343:  sm->cs = 343; goto _test_eof; 
	_test_eof344:  sm->cs = 344; goto _test_eof; 
	_test_eof345:  sm->cs = 345; goto _test_eof; 
	_test_eof346:  sm->cs = 346; goto _test_eof; 
	_test_eof347:  sm->cs = 347; goto _test_eof; 
	_test_eof348:  sm->cs = 348; goto _test_eof; 
	_test_eof1005:  sm->cs = 1005; goto _test_eof; 
	_test_eof1006:  sm->cs = 1006; goto _test_eof; 
	_test_eof349:  sm->cs = 349; goto _test_eof; 
	_test_eof350:  sm->cs = 350; goto _test_eof; 
	_test_eof351:  sm->cs = 351; goto _test_eof; 
	_test_eof352:  sm->cs = 352; goto _test_eof; 
	_test_eof353:  sm->cs = 353; goto _test_eof; 
	_test_eof354:  sm->cs = 354; goto _test_eof; 
	_test_eof355:  sm->cs = 355; goto _test_eof; 
	_test_eof356:  sm->cs = 356; goto _test_eof; 
	_test_eof357:  sm->cs = 357; goto _test_eof; 
	_test_eof358:  sm->cs = 358; goto _test_eof; 
	_test_eof359:  sm->cs = 359; goto _test_eof; 
	_test_eof360:  sm->cs = 360; goto _test_eof; 
	_test_eof361:  sm->cs = 361; goto _test_eof; 
	_test_eof362:  sm->cs = 362; goto _test_eof; 
	_test_eof363:  sm->cs = 363; goto _test_eof; 
	_test_eof364:  sm->cs = 364; goto _test_eof; 
	_test_eof365:  sm->cs = 365; goto _test_eof; 
	_test_eof366:  sm->cs = 366; goto _test_eof; 
	_test_eof367:  sm->cs = 367; goto _test_eof; 
	_test_eof368:  sm->cs = 368; goto _test_eof; 
	_test_eof369:  sm->cs = 369; goto _test_eof; 
	_test_eof370:  sm->cs = 370; goto _test_eof; 
	_test_eof371:  sm->cs = 371; goto _test_eof; 
	_test_eof372:  sm->cs = 372; goto _test_eof; 
	_test_eof373:  sm->cs = 373; goto _test_eof; 
	_test_eof374:  sm->cs = 374; goto _test_eof; 
	_test_eof375:  sm->cs = 375; goto _test_eof; 
	_test_eof376:  sm->cs = 376; goto _test_eof; 
	_test_eof377:  sm->cs = 377; goto _test_eof; 
	_test_eof378:  sm->cs = 378; goto _test_eof; 
	_test_eof379:  sm->cs = 379; goto _test_eof; 
	_test_eof380:  sm->cs = 380; goto _test_eof; 
	_test_eof381:  sm->cs = 381; goto _test_eof; 
	_test_eof382:  sm->cs = 382; goto _test_eof; 
	_test_eof383:  sm->cs = 383; goto _test_eof; 
	_test_eof384:  sm->cs = 384; goto _test_eof; 
	_test_eof385:  sm->cs = 385; goto _test_eof; 
	_test_eof386:  sm->cs = 386; goto _test_eof; 
	_test_eof387:  sm->cs = 387; goto _test_eof; 
	_test_eof388:  sm->cs = 388; goto _test_eof; 
	_test_eof389:  sm->cs = 389; goto _test_eof; 
	_test_eof390:  sm->cs = 390; goto _test_eof; 
	_test_eof391:  sm->cs = 391; goto _test_eof; 
	_test_eof1007:  sm->cs = 1007; goto _test_eof; 
	_test_eof1008:  sm->cs = 1008; goto _test_eof; 
	_test_eof392:  sm->cs = 392; goto _test_eof; 
	_test_eof1009:  sm->cs = 1009; goto _test_eof; 
	_test_eof1010:  sm->cs = 1010; goto _test_eof; 
	_test_eof393:  sm->cs = 393; goto _test_eof; 
	_test_eof394:  sm->cs = 394; goto _test_eof; 
	_test_eof395:  sm->cs = 395; goto _test_eof; 
	_test_eof396:  sm->cs = 396; goto _test_eof; 
	_test_eof397:  sm->cs = 397; goto _test_eof; 
	_test_eof398:  sm->cs = 398; goto _test_eof; 
	_test_eof399:  sm->cs = 399; goto _test_eof; 
	_test_eof400:  sm->cs = 400; goto _test_eof; 
	_test_eof1011:  sm->cs = 1011; goto _test_eof; 
	_test_eof1012:  sm->cs = 1012; goto _test_eof; 
	_test_eof401:  sm->cs = 401; goto _test_eof; 
	_test_eof1013:  sm->cs = 1013; goto _test_eof; 
	_test_eof402:  sm->cs = 402; goto _test_eof; 
	_test_eof403:  sm->cs = 403; goto _test_eof; 
	_test_eof404:  sm->cs = 404; goto _test_eof; 
	_test_eof405:  sm->cs = 405; goto _test_eof; 
	_test_eof406:  sm->cs = 406; goto _test_eof; 
	_test_eof407:  sm->cs = 407; goto _test_eof; 
	_test_eof408:  sm->cs = 408; goto _test_eof; 
	_test_eof409:  sm->cs = 409; goto _test_eof; 
	_test_eof410:  sm->cs = 410; goto _test_eof; 
	_test_eof411:  sm->cs = 411; goto _test_eof; 
	_test_eof412:  sm->cs = 412; goto _test_eof; 
	_test_eof413:  sm->cs = 413; goto _test_eof; 
	_test_eof414:  sm->cs = 414; goto _test_eof; 
	_test_eof415:  sm->cs = 415; goto _test_eof; 
	_test_eof416:  sm->cs = 416; goto _test_eof; 
	_test_eof417:  sm->cs = 417; goto _test_eof; 
	_test_eof418:  sm->cs = 418; goto _test_eof; 
	_test_eof419:  sm->cs = 419; goto _test_eof; 
	_test_eof1014:  sm->cs = 1014; goto _test_eof; 
	_test_eof420:  sm->cs = 420; goto _test_eof; 
	_test_eof421:  sm->cs = 421; goto _test_eof; 
	_test_eof422:  sm->cs = 422; goto _test_eof; 
	_test_eof423:  sm->cs = 423; goto _test_eof; 
	_test_eof424:  sm->cs = 424; goto _test_eof; 
	_test_eof425:  sm->cs = 425; goto _test_eof; 
	_test_eof426:  sm->cs = 426; goto _test_eof; 
	_test_eof427:  sm->cs = 427; goto _test_eof; 
	_test_eof428:  sm->cs = 428; goto _test_eof; 
	_test_eof1015:  sm->cs = 1015; goto _test_eof; 
	_test_eof1016:  sm->cs = 1016; goto _test_eof; 
	_test_eof1017:  sm->cs = 1017; goto _test_eof; 
	_test_eof1018:  sm->cs = 1018; goto _test_eof; 
	_test_eof1019:  sm->cs = 1019; goto _test_eof; 
	_test_eof429:  sm->cs = 429; goto _test_eof; 
	_test_eof430:  sm->cs = 430; goto _test_eof; 
	_test_eof1020:  sm->cs = 1020; goto _test_eof; 
	_test_eof1021:  sm->cs = 1021; goto _test_eof; 
	_test_eof1022:  sm->cs = 1022; goto _test_eof; 
	_test_eof1023:  sm->cs = 1023; goto _test_eof; 
	_test_eof1024:  sm->cs = 1024; goto _test_eof; 
	_test_eof1025:  sm->cs = 1025; goto _test_eof; 
	_test_eof431:  sm->cs = 431; goto _test_eof; 
	_test_eof432:  sm->cs = 432; goto _test_eof; 
	_test_eof1026:  sm->cs = 1026; goto _test_eof; 
	_test_eof1027:  sm->cs = 1027; goto _test_eof; 
	_test_eof1028:  sm->cs = 1028; goto _test_eof; 
	_test_eof1029:  sm->cs = 1029; goto _test_eof; 
	_test_eof1030:  sm->cs = 1030; goto _test_eof; 
	_test_eof1031:  sm->cs = 1031; goto _test_eof; 
	_test_eof433:  sm->cs = 433; goto _test_eof; 
	_test_eof434:  sm->cs = 434; goto _test_eof; 
	_test_eof1032:  sm->cs = 1032; goto _test_eof; 
	_test_eof1033:  sm->cs = 1033; goto _test_eof; 
	_test_eof1034:  sm->cs = 1034; goto _test_eof; 
	_test_eof1035:  sm->cs = 1035; goto _test_eof; 
	_test_eof1036:  sm->cs = 1036; goto _test_eof; 
	_test_eof1037:  sm->cs = 1037; goto _test_eof; 
	_test_eof1038:  sm->cs = 1038; goto _test_eof; 
	_test_eof1039:  sm->cs = 1039; goto _test_eof; 
	_test_eof435:  sm->cs = 435; goto _test_eof; 
	_test_eof436:  sm->cs = 436; goto _test_eof; 
	_test_eof1040:  sm->cs = 1040; goto _test_eof; 
	_test_eof1041:  sm->cs = 1041; goto _test_eof; 
	_test_eof1042:  sm->cs = 1042; goto _test_eof; 
	_test_eof1043:  sm->cs = 1043; goto _test_eof; 
	_test_eof437:  sm->cs = 437; goto _test_eof; 
	_test_eof438:  sm->cs = 438; goto _test_eof; 
	_test_eof1044:  sm->cs = 1044; goto _test_eof; 
	_test_eof1045:  sm->cs = 1045; goto _test_eof; 
	_test_eof1046:  sm->cs = 1046; goto _test_eof; 
	_test_eof439:  sm->cs = 439; goto _test_eof; 
	_test_eof440:  sm->cs = 440; goto _test_eof; 
	_test_eof1047:  sm->cs = 1047; goto _test_eof; 
	_test_eof1048:  sm->cs = 1048; goto _test_eof; 
	_test_eof1049:  sm->cs = 1049; goto _test_eof; 
	_test_eof1050:  sm->cs = 1050; goto _test_eof; 
	_test_eof1051:  sm->cs = 1051; goto _test_eof; 
	_test_eof1052:  sm->cs = 1052; goto _test_eof; 
	_test_eof1053:  sm->cs = 1053; goto _test_eof; 
	_test_eof1054:  sm->cs = 1054; goto _test_eof; 
	_test_eof441:  sm->cs = 441; goto _test_eof; 
	_test_eof442:  sm->cs = 442; goto _test_eof; 
	_test_eof1055:  sm->cs = 1055; goto _test_eof; 
	_test_eof1056:  sm->cs = 1056; goto _test_eof; 
	_test_eof1057:  sm->cs = 1057; goto _test_eof; 
	_test_eof443:  sm->cs = 443; goto _test_eof; 
	_test_eof444:  sm->cs = 444; goto _test_eof; 
	_test_eof1058:  sm->cs = 1058; goto _test_eof; 
	_test_eof1059:  sm->cs = 1059; goto _test_eof; 
	_test_eof1060:  sm->cs = 1060; goto _test_eof; 
	_test_eof1061:  sm->cs = 1061; goto _test_eof; 
	_test_eof1062:  sm->cs = 1062; goto _test_eof; 
	_test_eof1063:  sm->cs = 1063; goto _test_eof; 
	_test_eof1064:  sm->cs = 1064; goto _test_eof; 
	_test_eof1065:  sm->cs = 1065; goto _test_eof; 
	_test_eof1066:  sm->cs = 1066; goto _test_eof; 
	_test_eof1067:  sm->cs = 1067; goto _test_eof; 
	_test_eof1068:  sm->cs = 1068; goto _test_eof; 
	_test_eof445:  sm->cs = 445; goto _test_eof; 
	_test_eof446:  sm->cs = 446; goto _test_eof; 
	_test_eof1069:  sm->cs = 1069; goto _test_eof; 
	_test_eof1070:  sm->cs = 1070; goto _test_eof; 
	_test_eof1071:  sm->cs = 1071; goto _test_eof; 
	_test_eof1072:  sm->cs = 1072; goto _test_eof; 
	_test_eof1073:  sm->cs = 1073; goto _test_eof; 
	_test_eof447:  sm->cs = 447; goto _test_eof; 
	_test_eof448:  sm->cs = 448; goto _test_eof; 
	_test_eof1074:  sm->cs = 1074; goto _test_eof; 
	_test_eof449:  sm->cs = 449; goto _test_eof; 
	_test_eof1075:  sm->cs = 1075; goto _test_eof; 
	_test_eof1076:  sm->cs = 1076; goto _test_eof; 
	_test_eof1077:  sm->cs = 1077; goto _test_eof; 
	_test_eof1078:  sm->cs = 1078; goto _test_eof; 
	_test_eof1079:  sm->cs = 1079; goto _test_eof; 
	_test_eof1080:  sm->cs = 1080; goto _test_eof; 
	_test_eof1081:  sm->cs = 1081; goto _test_eof; 
	_test_eof1082:  sm->cs = 1082; goto _test_eof; 
	_test_eof1083:  sm->cs = 1083; goto _test_eof; 
	_test_eof450:  sm->cs = 450; goto _test_eof; 
	_test_eof451:  sm->cs = 451; goto _test_eof; 
	_test_eof1084:  sm->cs = 1084; goto _test_eof; 
	_test_eof1085:  sm->cs = 1085; goto _test_eof; 
	_test_eof1086:  sm->cs = 1086; goto _test_eof; 
	_test_eof1087:  sm->cs = 1087; goto _test_eof; 
	_test_eof1088:  sm->cs = 1088; goto _test_eof; 
	_test_eof1089:  sm->cs = 1089; goto _test_eof; 
	_test_eof1090:  sm->cs = 1090; goto _test_eof; 
	_test_eof1091:  sm->cs = 1091; goto _test_eof; 
	_test_eof452:  sm->cs = 452; goto _test_eof; 
	_test_eof453:  sm->cs = 453; goto _test_eof; 
	_test_eof1092:  sm->cs = 1092; goto _test_eof; 
	_test_eof1093:  sm->cs = 1093; goto _test_eof; 
	_test_eof1094:  sm->cs = 1094; goto _test_eof; 
	_test_eof1095:  sm->cs = 1095; goto _test_eof; 
	_test_eof454:  sm->cs = 454; goto _test_eof; 
	_test_eof455:  sm->cs = 455; goto _test_eof; 
	_test_eof1096:  sm->cs = 1096; goto _test_eof; 
	_test_eof1097:  sm->cs = 1097; goto _test_eof; 
	_test_eof1098:  sm->cs = 1098; goto _test_eof; 
	_test_eof1099:  sm->cs = 1099; goto _test_eof; 
	_test_eof1100:  sm->cs = 1100; goto _test_eof; 
	_test_eof456:  sm->cs = 456; goto _test_eof; 
	_test_eof457:  sm->cs = 457; goto _test_eof; 
	_test_eof1101:  sm->cs = 1101; goto _test_eof; 
	_test_eof1102:  sm->cs = 1102; goto _test_eof; 
	_test_eof1103:  sm->cs = 1103; goto _test_eof; 
	_test_eof1104:  sm->cs = 1104; goto _test_eof; 
	_test_eof1105:  sm->cs = 1105; goto _test_eof; 
	_test_eof1106:  sm->cs = 1106; goto _test_eof; 
	_test_eof1107:  sm->cs = 1107; goto _test_eof; 
	_test_eof1108:  sm->cs = 1108; goto _test_eof; 
	_test_eof1109:  sm->cs = 1109; goto _test_eof; 
	_test_eof458:  sm->cs = 458; goto _test_eof; 
	_test_eof459:  sm->cs = 459; goto _test_eof; 
	_test_eof1110:  sm->cs = 1110; goto _test_eof; 
	_test_eof1111:  sm->cs = 1111; goto _test_eof; 
	_test_eof1112:  sm->cs = 1112; goto _test_eof; 
	_test_eof1113:  sm->cs = 1113; goto _test_eof; 
	_test_eof1114:  sm->cs = 1114; goto _test_eof; 
	_test_eof460:  sm->cs = 460; goto _test_eof; 
	_test_eof461:  sm->cs = 461; goto _test_eof; 
	_test_eof462:  sm->cs = 462; goto _test_eof; 
	_test_eof1115:  sm->cs = 1115; goto _test_eof; 
	_test_eof1116:  sm->cs = 1116; goto _test_eof; 
	_test_eof1117:  sm->cs = 1117; goto _test_eof; 
	_test_eof1118:  sm->cs = 1118; goto _test_eof; 
	_test_eof1119:  sm->cs = 1119; goto _test_eof; 
	_test_eof1120:  sm->cs = 1120; goto _test_eof; 
	_test_eof1121:  sm->cs = 1121; goto _test_eof; 
	_test_eof1122:  sm->cs = 1122; goto _test_eof; 
	_test_eof1123:  sm->cs = 1123; goto _test_eof; 
	_test_eof1124:  sm->cs = 1124; goto _test_eof; 
	_test_eof1125:  sm->cs = 1125; goto _test_eof; 
	_test_eof1126:  sm->cs = 1126; goto _test_eof; 
	_test_eof1127:  sm->cs = 1127; goto _test_eof; 
	_test_eof463:  sm->cs = 463; goto _test_eof; 
	_test_eof464:  sm->cs = 464; goto _test_eof; 
	_test_eof1128:  sm->cs = 1128; goto _test_eof; 
	_test_eof1129:  sm->cs = 1129; goto _test_eof; 
	_test_eof1130:  sm->cs = 1130; goto _test_eof; 
	_test_eof1131:  sm->cs = 1131; goto _test_eof; 
	_test_eof1132:  sm->cs = 1132; goto _test_eof; 
	_test_eof465:  sm->cs = 465; goto _test_eof; 
	_test_eof466:  sm->cs = 466; goto _test_eof; 
	_test_eof1133:  sm->cs = 1133; goto _test_eof; 
	_test_eof1134:  sm->cs = 1134; goto _test_eof; 
	_test_eof1135:  sm->cs = 1135; goto _test_eof; 
	_test_eof1136:  sm->cs = 1136; goto _test_eof; 
	_test_eof467:  sm->cs = 467; goto _test_eof; 
	_test_eof468:  sm->cs = 468; goto _test_eof; 
	_test_eof469:  sm->cs = 469; goto _test_eof; 
	_test_eof470:  sm->cs = 470; goto _test_eof; 
	_test_eof471:  sm->cs = 471; goto _test_eof; 
	_test_eof472:  sm->cs = 472; goto _test_eof; 
	_test_eof473:  sm->cs = 473; goto _test_eof; 
	_test_eof474:  sm->cs = 474; goto _test_eof; 
	_test_eof475:  sm->cs = 475; goto _test_eof; 
	_test_eof1137:  sm->cs = 1137; goto _test_eof; 
	_test_eof1138:  sm->cs = 1138; goto _test_eof; 
	_test_eof1139:  sm->cs = 1139; goto _test_eof; 
	_test_eof1140:  sm->cs = 1140; goto _test_eof; 
	_test_eof1141:  sm->cs = 1141; goto _test_eof; 
	_test_eof1142:  sm->cs = 1142; goto _test_eof; 
	_test_eof1143:  sm->cs = 1143; goto _test_eof; 
	_test_eof476:  sm->cs = 476; goto _test_eof; 
	_test_eof477:  sm->cs = 477; goto _test_eof; 
	_test_eof1144:  sm->cs = 1144; goto _test_eof; 
	_test_eof1145:  sm->cs = 1145; goto _test_eof; 
	_test_eof1146:  sm->cs = 1146; goto _test_eof; 
	_test_eof1147:  sm->cs = 1147; goto _test_eof; 
	_test_eof1148:  sm->cs = 1148; goto _test_eof; 
	_test_eof1149:  sm->cs = 1149; goto _test_eof; 
	_test_eof478:  sm->cs = 478; goto _test_eof; 
	_test_eof479:  sm->cs = 479; goto _test_eof; 
	_test_eof1150:  sm->cs = 1150; goto _test_eof; 
	_test_eof1151:  sm->cs = 1151; goto _test_eof; 
	_test_eof1152:  sm->cs = 1152; goto _test_eof; 
	_test_eof1153:  sm->cs = 1153; goto _test_eof; 
	_test_eof480:  sm->cs = 480; goto _test_eof; 
	_test_eof481:  sm->cs = 481; goto _test_eof; 
	_test_eof1154:  sm->cs = 1154; goto _test_eof; 
	_test_eof1155:  sm->cs = 1155; goto _test_eof; 
	_test_eof1156:  sm->cs = 1156; goto _test_eof; 
	_test_eof1157:  sm->cs = 1157; goto _test_eof; 
	_test_eof1158:  sm->cs = 1158; goto _test_eof; 
	_test_eof1159:  sm->cs = 1159; goto _test_eof; 
	_test_eof482:  sm->cs = 482; goto _test_eof; 
	_test_eof483:  sm->cs = 483; goto _test_eof; 
	_test_eof1160:  sm->cs = 1160; goto _test_eof; 
	_test_eof1161:  sm->cs = 1161; goto _test_eof; 
	_test_eof1162:  sm->cs = 1162; goto _test_eof; 
	_test_eof1163:  sm->cs = 1163; goto _test_eof; 
	_test_eof1164:  sm->cs = 1164; goto _test_eof; 
	_test_eof484:  sm->cs = 484; goto _test_eof; 
	_test_eof485:  sm->cs = 485; goto _test_eof; 
	_test_eof1165:  sm->cs = 1165; goto _test_eof; 
	_test_eof486:  sm->cs = 486; goto _test_eof; 
	_test_eof487:  sm->cs = 487; goto _test_eof; 
	_test_eof1166:  sm->cs = 1166; goto _test_eof; 
	_test_eof1167:  sm->cs = 1167; goto _test_eof; 
	_test_eof1168:  sm->cs = 1168; goto _test_eof; 
	_test_eof1169:  sm->cs = 1169; goto _test_eof; 
	_test_eof488:  sm->cs = 488; goto _test_eof; 
	_test_eof489:  sm->cs = 489; goto _test_eof; 
	_test_eof1170:  sm->cs = 1170; goto _test_eof; 
	_test_eof1171:  sm->cs = 1171; goto _test_eof; 
	_test_eof1172:  sm->cs = 1172; goto _test_eof; 
	_test_eof490:  sm->cs = 490; goto _test_eof; 
	_test_eof491:  sm->cs = 491; goto _test_eof; 
	_test_eof1173:  sm->cs = 1173; goto _test_eof; 
	_test_eof1174:  sm->cs = 1174; goto _test_eof; 
	_test_eof1175:  sm->cs = 1175; goto _test_eof; 
	_test_eof1176:  sm->cs = 1176; goto _test_eof; 
	_test_eof492:  sm->cs = 492; goto _test_eof; 
	_test_eof493:  sm->cs = 493; goto _test_eof; 
	_test_eof1177:  sm->cs = 1177; goto _test_eof; 
	_test_eof1178:  sm->cs = 1178; goto _test_eof; 
	_test_eof1179:  sm->cs = 1179; goto _test_eof; 
	_test_eof1180:  sm->cs = 1180; goto _test_eof; 
	_test_eof1181:  sm->cs = 1181; goto _test_eof; 
	_test_eof1182:  sm->cs = 1182; goto _test_eof; 
	_test_eof1183:  sm->cs = 1183; goto _test_eof; 
	_test_eof1184:  sm->cs = 1184; goto _test_eof; 
	_test_eof494:  sm->cs = 494; goto _test_eof; 
	_test_eof495:  sm->cs = 495; goto _test_eof; 
	_test_eof1185:  sm->cs = 1185; goto _test_eof; 
	_test_eof1186:  sm->cs = 1186; goto _test_eof; 
	_test_eof1187:  sm->cs = 1187; goto _test_eof; 
	_test_eof1188:  sm->cs = 1188; goto _test_eof; 
	_test_eof1189:  sm->cs = 1189; goto _test_eof; 
	_test_eof496:  sm->cs = 496; goto _test_eof; 
	_test_eof497:  sm->cs = 497; goto _test_eof; 
	_test_eof1190:  sm->cs = 1190; goto _test_eof; 
	_test_eof1191:  sm->cs = 1191; goto _test_eof; 
	_test_eof1192:  sm->cs = 1192; goto _test_eof; 
	_test_eof1193:  sm->cs = 1193; goto _test_eof; 
	_test_eof1194:  sm->cs = 1194; goto _test_eof; 
	_test_eof1195:  sm->cs = 1195; goto _test_eof; 
	_test_eof498:  sm->cs = 498; goto _test_eof; 
	_test_eof499:  sm->cs = 499; goto _test_eof; 
	_test_eof1196:  sm->cs = 1196; goto _test_eof; 
	_test_eof500:  sm->cs = 500; goto _test_eof; 
	_test_eof501:  sm->cs = 501; goto _test_eof; 
	_test_eof1197:  sm->cs = 1197; goto _test_eof; 
	_test_eof1198:  sm->cs = 1198; goto _test_eof; 
	_test_eof1199:  sm->cs = 1199; goto _test_eof; 
	_test_eof1200:  sm->cs = 1200; goto _test_eof; 
	_test_eof1201:  sm->cs = 1201; goto _test_eof; 
	_test_eof1202:  sm->cs = 1202; goto _test_eof; 
	_test_eof1203:  sm->cs = 1203; goto _test_eof; 
	_test_eof502:  sm->cs = 502; goto _test_eof; 
	_test_eof503:  sm->cs = 503; goto _test_eof; 
	_test_eof1204:  sm->cs = 1204; goto _test_eof; 
	_test_eof1205:  sm->cs = 1205; goto _test_eof; 
	_test_eof1206:  sm->cs = 1206; goto _test_eof; 
	_test_eof1207:  sm->cs = 1207; goto _test_eof; 
	_test_eof1208:  sm->cs = 1208; goto _test_eof; 
	_test_eof504:  sm->cs = 504; goto _test_eof; 
	_test_eof505:  sm->cs = 505; goto _test_eof; 
	_test_eof1209:  sm->cs = 1209; goto _test_eof; 
	_test_eof1210:  sm->cs = 1210; goto _test_eof; 
	_test_eof1211:  sm->cs = 1211; goto _test_eof; 
	_test_eof1212:  sm->cs = 1212; goto _test_eof; 
	_test_eof1213:  sm->cs = 1213; goto _test_eof; 
	_test_eof506:  sm->cs = 506; goto _test_eof; 
	_test_eof507:  sm->cs = 507; goto _test_eof; 
	_test_eof1214:  sm->cs = 1214; goto _test_eof; 
	_test_eof1215:  sm->cs = 1215; goto _test_eof; 
	_test_eof1216:  sm->cs = 1216; goto _test_eof; 
	_test_eof1217:  sm->cs = 1217; goto _test_eof; 
	_test_eof1218:  sm->cs = 1218; goto _test_eof; 
	_test_eof1219:  sm->cs = 1219; goto _test_eof; 
	_test_eof1220:  sm->cs = 1220; goto _test_eof; 
	_test_eof1221:  sm->cs = 1221; goto _test_eof; 
	_test_eof508:  sm->cs = 508; goto _test_eof; 
	_test_eof509:  sm->cs = 509; goto _test_eof; 
	_test_eof1222:  sm->cs = 1222; goto _test_eof; 
	_test_eof1223:  sm->cs = 1223; goto _test_eof; 
	_test_eof510:  sm->cs = 510; goto _test_eof; 
	_test_eof511:  sm->cs = 511; goto _test_eof; 
	_test_eof512:  sm->cs = 512; goto _test_eof; 
	_test_eof513:  sm->cs = 513; goto _test_eof; 
	_test_eof514:  sm->cs = 514; goto _test_eof; 
	_test_eof515:  sm->cs = 515; goto _test_eof; 
	_test_eof516:  sm->cs = 516; goto _test_eof; 
	_test_eof517:  sm->cs = 517; goto _test_eof; 
	_test_eof518:  sm->cs = 518; goto _test_eof; 
	_test_eof519:  sm->cs = 519; goto _test_eof; 
	_test_eof520:  sm->cs = 520; goto _test_eof; 
	_test_eof521:  sm->cs = 521; goto _test_eof; 
	_test_eof522:  sm->cs = 522; goto _test_eof; 
	_test_eof1224:  sm->cs = 1224; goto _test_eof; 
	_test_eof523:  sm->cs = 523; goto _test_eof; 
	_test_eof524:  sm->cs = 524; goto _test_eof; 
	_test_eof1225:  sm->cs = 1225; goto _test_eof; 
	_test_eof525:  sm->cs = 525; goto _test_eof; 
	_test_eof526:  sm->cs = 526; goto _test_eof; 
	_test_eof527:  sm->cs = 527; goto _test_eof; 
	_test_eof528:  sm->cs = 528; goto _test_eof; 
	_test_eof529:  sm->cs = 529; goto _test_eof; 
	_test_eof530:  sm->cs = 530; goto _test_eof; 
	_test_eof531:  sm->cs = 531; goto _test_eof; 
	_test_eof532:  sm->cs = 532; goto _test_eof; 
	_test_eof533:  sm->cs = 533; goto _test_eof; 
	_test_eof534:  sm->cs = 534; goto _test_eof; 
	_test_eof535:  sm->cs = 535; goto _test_eof; 
	_test_eof536:  sm->cs = 536; goto _test_eof; 
	_test_eof537:  sm->cs = 537; goto _test_eof; 
	_test_eof538:  sm->cs = 538; goto _test_eof; 
	_test_eof539:  sm->cs = 539; goto _test_eof; 
	_test_eof540:  sm->cs = 540; goto _test_eof; 
	_test_eof541:  sm->cs = 541; goto _test_eof; 
	_test_eof542:  sm->cs = 542; goto _test_eof; 
	_test_eof543:  sm->cs = 543; goto _test_eof; 
	_test_eof544:  sm->cs = 544; goto _test_eof; 
	_test_eof545:  sm->cs = 545; goto _test_eof; 
	_test_eof546:  sm->cs = 546; goto _test_eof; 
	_test_eof547:  sm->cs = 547; goto _test_eof; 
	_test_eof548:  sm->cs = 548; goto _test_eof; 
	_test_eof549:  sm->cs = 549; goto _test_eof; 
	_test_eof550:  sm->cs = 550; goto _test_eof; 
	_test_eof551:  sm->cs = 551; goto _test_eof; 
	_test_eof552:  sm->cs = 552; goto _test_eof; 
	_test_eof553:  sm->cs = 553; goto _test_eof; 
	_test_eof554:  sm->cs = 554; goto _test_eof; 
	_test_eof555:  sm->cs = 555; goto _test_eof; 
	_test_eof1226:  sm->cs = 1226; goto _test_eof; 
	_test_eof556:  sm->cs = 556; goto _test_eof; 
	_test_eof557:  sm->cs = 557; goto _test_eof; 
	_test_eof558:  sm->cs = 558; goto _test_eof; 
	_test_eof559:  sm->cs = 559; goto _test_eof; 
	_test_eof560:  sm->cs = 560; goto _test_eof; 
	_test_eof561:  sm->cs = 561; goto _test_eof; 
	_test_eof562:  sm->cs = 562; goto _test_eof; 
	_test_eof563:  sm->cs = 563; goto _test_eof; 
	_test_eof564:  sm->cs = 564; goto _test_eof; 
	_test_eof565:  sm->cs = 565; goto _test_eof; 
	_test_eof566:  sm->cs = 566; goto _test_eof; 
	_test_eof567:  sm->cs = 567; goto _test_eof; 
	_test_eof568:  sm->cs = 568; goto _test_eof; 
	_test_eof569:  sm->cs = 569; goto _test_eof; 
	_test_eof570:  sm->cs = 570; goto _test_eof; 
	_test_eof571:  sm->cs = 571; goto _test_eof; 
	_test_eof572:  sm->cs = 572; goto _test_eof; 
	_test_eof573:  sm->cs = 573; goto _test_eof; 
	_test_eof1227:  sm->cs = 1227; goto _test_eof; 
	_test_eof1228:  sm->cs = 1228; goto _test_eof; 
	_test_eof574:  sm->cs = 574; goto _test_eof; 
	_test_eof575:  sm->cs = 575; goto _test_eof; 
	_test_eof576:  sm->cs = 576; goto _test_eof; 
	_test_eof577:  sm->cs = 577; goto _test_eof; 
	_test_eof578:  sm->cs = 578; goto _test_eof; 
	_test_eof579:  sm->cs = 579; goto _test_eof; 
	_test_eof580:  sm->cs = 580; goto _test_eof; 
	_test_eof581:  sm->cs = 581; goto _test_eof; 
	_test_eof582:  sm->cs = 582; goto _test_eof; 
	_test_eof583:  sm->cs = 583; goto _test_eof; 
	_test_eof584:  sm->cs = 584; goto _test_eof; 
	_test_eof585:  sm->cs = 585; goto _test_eof; 
	_test_eof586:  sm->cs = 586; goto _test_eof; 
	_test_eof587:  sm->cs = 587; goto _test_eof; 
	_test_eof588:  sm->cs = 588; goto _test_eof; 
	_test_eof589:  sm->cs = 589; goto _test_eof; 
	_test_eof590:  sm->cs = 590; goto _test_eof; 
	_test_eof591:  sm->cs = 591; goto _test_eof; 
	_test_eof592:  sm->cs = 592; goto _test_eof; 
	_test_eof593:  sm->cs = 593; goto _test_eof; 
	_test_eof594:  sm->cs = 594; goto _test_eof; 
	_test_eof595:  sm->cs = 595; goto _test_eof; 
	_test_eof596:  sm->cs = 596; goto _test_eof; 
	_test_eof597:  sm->cs = 597; goto _test_eof; 
	_test_eof598:  sm->cs = 598; goto _test_eof; 
	_test_eof599:  sm->cs = 599; goto _test_eof; 
	_test_eof600:  sm->cs = 600; goto _test_eof; 
	_test_eof601:  sm->cs = 601; goto _test_eof; 
	_test_eof602:  sm->cs = 602; goto _test_eof; 
	_test_eof603:  sm->cs = 603; goto _test_eof; 
	_test_eof604:  sm->cs = 604; goto _test_eof; 
	_test_eof605:  sm->cs = 605; goto _test_eof; 
	_test_eof606:  sm->cs = 606; goto _test_eof; 
	_test_eof607:  sm->cs = 607; goto _test_eof; 
	_test_eof608:  sm->cs = 608; goto _test_eof; 
	_test_eof609:  sm->cs = 609; goto _test_eof; 
	_test_eof610:  sm->cs = 610; goto _test_eof; 
	_test_eof611:  sm->cs = 611; goto _test_eof; 
	_test_eof612:  sm->cs = 612; goto _test_eof; 
	_test_eof613:  sm->cs = 613; goto _test_eof; 
	_test_eof614:  sm->cs = 614; goto _test_eof; 
	_test_eof615:  sm->cs = 615; goto _test_eof; 
	_test_eof616:  sm->cs = 616; goto _test_eof; 
	_test_eof617:  sm->cs = 617; goto _test_eof; 
	_test_eof618:  sm->cs = 618; goto _test_eof; 
	_test_eof619:  sm->cs = 619; goto _test_eof; 
	_test_eof620:  sm->cs = 620; goto _test_eof; 
	_test_eof621:  sm->cs = 621; goto _test_eof; 
	_test_eof622:  sm->cs = 622; goto _test_eof; 
	_test_eof623:  sm->cs = 623; goto _test_eof; 
	_test_eof624:  sm->cs = 624; goto _test_eof; 
	_test_eof625:  sm->cs = 625; goto _test_eof; 
	_test_eof626:  sm->cs = 626; goto _test_eof; 
	_test_eof627:  sm->cs = 627; goto _test_eof; 
	_test_eof628:  sm->cs = 628; goto _test_eof; 
	_test_eof629:  sm->cs = 629; goto _test_eof; 
	_test_eof630:  sm->cs = 630; goto _test_eof; 
	_test_eof631:  sm->cs = 631; goto _test_eof; 
	_test_eof632:  sm->cs = 632; goto _test_eof; 
	_test_eof633:  sm->cs = 633; goto _test_eof; 
	_test_eof634:  sm->cs = 634; goto _test_eof; 
	_test_eof635:  sm->cs = 635; goto _test_eof; 
	_test_eof636:  sm->cs = 636; goto _test_eof; 
	_test_eof637:  sm->cs = 637; goto _test_eof; 
	_test_eof638:  sm->cs = 638; goto _test_eof; 
	_test_eof639:  sm->cs = 639; goto _test_eof; 
	_test_eof640:  sm->cs = 640; goto _test_eof; 
	_test_eof641:  sm->cs = 641; goto _test_eof; 
	_test_eof642:  sm->cs = 642; goto _test_eof; 
	_test_eof643:  sm->cs = 643; goto _test_eof; 
	_test_eof644:  sm->cs = 644; goto _test_eof; 
	_test_eof645:  sm->cs = 645; goto _test_eof; 
	_test_eof646:  sm->cs = 646; goto _test_eof; 
	_test_eof647:  sm->cs = 647; goto _test_eof; 
	_test_eof648:  sm->cs = 648; goto _test_eof; 
	_test_eof649:  sm->cs = 649; goto _test_eof; 
	_test_eof650:  sm->cs = 650; goto _test_eof; 
	_test_eof651:  sm->cs = 651; goto _test_eof; 
	_test_eof652:  sm->cs = 652; goto _test_eof; 
	_test_eof653:  sm->cs = 653; goto _test_eof; 
	_test_eof654:  sm->cs = 654; goto _test_eof; 
	_test_eof655:  sm->cs = 655; goto _test_eof; 
	_test_eof656:  sm->cs = 656; goto _test_eof; 
	_test_eof657:  sm->cs = 657; goto _test_eof; 
	_test_eof658:  sm->cs = 658; goto _test_eof; 
	_test_eof659:  sm->cs = 659; goto _test_eof; 
	_test_eof660:  sm->cs = 660; goto _test_eof; 
	_test_eof661:  sm->cs = 661; goto _test_eof; 
	_test_eof662:  sm->cs = 662; goto _test_eof; 
	_test_eof663:  sm->cs = 663; goto _test_eof; 
	_test_eof664:  sm->cs = 664; goto _test_eof; 
	_test_eof665:  sm->cs = 665; goto _test_eof; 
	_test_eof666:  sm->cs = 666; goto _test_eof; 
	_test_eof1229:  sm->cs = 1229; goto _test_eof; 
	_test_eof667:  sm->cs = 667; goto _test_eof; 
	_test_eof668:  sm->cs = 668; goto _test_eof; 
	_test_eof1230:  sm->cs = 1230; goto _test_eof; 
	_test_eof669:  sm->cs = 669; goto _test_eof; 
	_test_eof670:  sm->cs = 670; goto _test_eof; 
	_test_eof671:  sm->cs = 671; goto _test_eof; 
	_test_eof672:  sm->cs = 672; goto _test_eof; 
	_test_eof1231:  sm->cs = 1231; goto _test_eof; 
	_test_eof673:  sm->cs = 673; goto _test_eof; 
	_test_eof674:  sm->cs = 674; goto _test_eof; 
	_test_eof675:  sm->cs = 675; goto _test_eof; 
	_test_eof676:  sm->cs = 676; goto _test_eof; 
	_test_eof677:  sm->cs = 677; goto _test_eof; 
	_test_eof678:  sm->cs = 678; goto _test_eof; 
	_test_eof679:  sm->cs = 679; goto _test_eof; 
	_test_eof680:  sm->cs = 680; goto _test_eof; 
	_test_eof681:  sm->cs = 681; goto _test_eof; 
	_test_eof682:  sm->cs = 682; goto _test_eof; 
	_test_eof1232:  sm->cs = 1232; goto _test_eof; 
	_test_eof683:  sm->cs = 683; goto _test_eof; 
	_test_eof684:  sm->cs = 684; goto _test_eof; 
	_test_eof685:  sm->cs = 685; goto _test_eof; 
	_test_eof686:  sm->cs = 686; goto _test_eof; 
	_test_eof687:  sm->cs = 687; goto _test_eof; 
	_test_eof688:  sm->cs = 688; goto _test_eof; 
	_test_eof689:  sm->cs = 689; goto _test_eof; 
	_test_eof690:  sm->cs = 690; goto _test_eof; 
	_test_eof691:  sm->cs = 691; goto _test_eof; 
	_test_eof692:  sm->cs = 692; goto _test_eof; 
	_test_eof693:  sm->cs = 693; goto _test_eof; 
	_test_eof694:  sm->cs = 694; goto _test_eof; 
	_test_eof695:  sm->cs = 695; goto _test_eof; 
	_test_eof696:  sm->cs = 696; goto _test_eof; 
	_test_eof697:  sm->cs = 697; goto _test_eof; 
	_test_eof698:  sm->cs = 698; goto _test_eof; 
	_test_eof699:  sm->cs = 699; goto _test_eof; 
	_test_eof700:  sm->cs = 700; goto _test_eof; 
	_test_eof701:  sm->cs = 701; goto _test_eof; 
	_test_eof702:  sm->cs = 702; goto _test_eof; 
	_test_eof1233:  sm->cs = 1233; goto _test_eof; 
	_test_eof1234:  sm->cs = 1234; goto _test_eof; 
	_test_eof703:  sm->cs = 703; goto _test_eof; 
	_test_eof704:  sm->cs = 704; goto _test_eof; 
	_test_eof705:  sm->cs = 705; goto _test_eof; 
	_test_eof706:  sm->cs = 706; goto _test_eof; 
	_test_eof707:  sm->cs = 707; goto _test_eof; 
	_test_eof708:  sm->cs = 708; goto _test_eof; 
	_test_eof709:  sm->cs = 709; goto _test_eof; 
	_test_eof710:  sm->cs = 710; goto _test_eof; 
	_test_eof711:  sm->cs = 711; goto _test_eof; 
	_test_eof712:  sm->cs = 712; goto _test_eof; 
	_test_eof713:  sm->cs = 713; goto _test_eof; 
	_test_eof714:  sm->cs = 714; goto _test_eof; 
	_test_eof1235:  sm->cs = 1235; goto _test_eof; 
	_test_eof715:  sm->cs = 715; goto _test_eof; 
	_test_eof1236:  sm->cs = 1236; goto _test_eof; 
	_test_eof1237:  sm->cs = 1237; goto _test_eof; 
	_test_eof1238:  sm->cs = 1238; goto _test_eof; 
	_test_eof1239:  sm->cs = 1239; goto _test_eof; 
	_test_eof716:  sm->cs = 716; goto _test_eof; 
	_test_eof717:  sm->cs = 717; goto _test_eof; 
	_test_eof718:  sm->cs = 718; goto _test_eof; 
	_test_eof719:  sm->cs = 719; goto _test_eof; 
	_test_eof720:  sm->cs = 720; goto _test_eof; 
	_test_eof721:  sm->cs = 721; goto _test_eof; 
	_test_eof722:  sm->cs = 722; goto _test_eof; 
	_test_eof723:  sm->cs = 723; goto _test_eof; 
	_test_eof724:  sm->cs = 724; goto _test_eof; 
	_test_eof725:  sm->cs = 725; goto _test_eof; 
	_test_eof726:  sm->cs = 726; goto _test_eof; 
	_test_eof727:  sm->cs = 727; goto _test_eof; 
	_test_eof728:  sm->cs = 728; goto _test_eof; 
	_test_eof729:  sm->cs = 729; goto _test_eof; 
	_test_eof730:  sm->cs = 730; goto _test_eof; 
	_test_eof731:  sm->cs = 731; goto _test_eof; 
	_test_eof732:  sm->cs = 732; goto _test_eof; 
	_test_eof733:  sm->cs = 733; goto _test_eof; 
	_test_eof1240:  sm->cs = 1240; goto _test_eof; 
	_test_eof734:  sm->cs = 734; goto _test_eof; 
	_test_eof1241:  sm->cs = 1241; goto _test_eof; 
	_test_eof1242:  sm->cs = 1242; goto _test_eof; 
	_test_eof1243:  sm->cs = 1243; goto _test_eof; 
	_test_eof1244:  sm->cs = 1244; goto _test_eof; 
	_test_eof735:  sm->cs = 735; goto _test_eof; 
	_test_eof736:  sm->cs = 736; goto _test_eof; 
	_test_eof737:  sm->cs = 737; goto _test_eof; 
	_test_eof738:  sm->cs = 738; goto _test_eof; 
	_test_eof739:  sm->cs = 739; goto _test_eof; 
	_test_eof740:  sm->cs = 740; goto _test_eof; 
	_test_eof741:  sm->cs = 741; goto _test_eof; 
	_test_eof742:  sm->cs = 742; goto _test_eof; 
	_test_eof743:  sm->cs = 743; goto _test_eof; 
	_test_eof744:  sm->cs = 744; goto _test_eof; 
	_test_eof745:  sm->cs = 745; goto _test_eof; 
	_test_eof746:  sm->cs = 746; goto _test_eof; 
	_test_eof747:  sm->cs = 747; goto _test_eof; 
	_test_eof748:  sm->cs = 748; goto _test_eof; 
	_test_eof749:  sm->cs = 749; goto _test_eof; 
	_test_eof750:  sm->cs = 750; goto _test_eof; 
	_test_eof751:  sm->cs = 751; goto _test_eof; 
	_test_eof752:  sm->cs = 752; goto _test_eof; 
	_test_eof753:  sm->cs = 753; goto _test_eof; 
	_test_eof754:  sm->cs = 754; goto _test_eof; 
	_test_eof755:  sm->cs = 755; goto _test_eof; 
	_test_eof756:  sm->cs = 756; goto _test_eof; 
	_test_eof757:  sm->cs = 757; goto _test_eof; 
	_test_eof758:  sm->cs = 758; goto _test_eof; 
	_test_eof759:  sm->cs = 759; goto _test_eof; 
	_test_eof760:  sm->cs = 760; goto _test_eof; 
	_test_eof761:  sm->cs = 761; goto _test_eof; 
	_test_eof762:  sm->cs = 762; goto _test_eof; 
	_test_eof763:  sm->cs = 763; goto _test_eof; 
	_test_eof764:  sm->cs = 764; goto _test_eof; 
	_test_eof765:  sm->cs = 765; goto _test_eof; 
	_test_eof766:  sm->cs = 766; goto _test_eof; 
	_test_eof767:  sm->cs = 767; goto _test_eof; 
	_test_eof768:  sm->cs = 768; goto _test_eof; 
	_test_eof769:  sm->cs = 769; goto _test_eof; 
	_test_eof770:  sm->cs = 770; goto _test_eof; 
	_test_eof771:  sm->cs = 771; goto _test_eof; 
	_test_eof772:  sm->cs = 772; goto _test_eof; 
	_test_eof773:  sm->cs = 773; goto _test_eof; 
	_test_eof774:  sm->cs = 774; goto _test_eof; 
	_test_eof775:  sm->cs = 775; goto _test_eof; 
	_test_eof776:  sm->cs = 776; goto _test_eof; 
	_test_eof777:  sm->cs = 777; goto _test_eof; 
	_test_eof778:  sm->cs = 778; goto _test_eof; 
	_test_eof779:  sm->cs = 779; goto _test_eof; 
	_test_eof780:  sm->cs = 780; goto _test_eof; 
	_test_eof781:  sm->cs = 781; goto _test_eof; 
	_test_eof782:  sm->cs = 782; goto _test_eof; 
	_test_eof783:  sm->cs = 783; goto _test_eof; 
	_test_eof784:  sm->cs = 784; goto _test_eof; 
	_test_eof785:  sm->cs = 785; goto _test_eof; 
	_test_eof786:  sm->cs = 786; goto _test_eof; 
	_test_eof787:  sm->cs = 787; goto _test_eof; 
	_test_eof788:  sm->cs = 788; goto _test_eof; 
	_test_eof789:  sm->cs = 789; goto _test_eof; 
	_test_eof790:  sm->cs = 790; goto _test_eof; 
	_test_eof791:  sm->cs = 791; goto _test_eof; 
	_test_eof792:  sm->cs = 792; goto _test_eof; 
	_test_eof793:  sm->cs = 793; goto _test_eof; 
	_test_eof794:  sm->cs = 794; goto _test_eof; 
	_test_eof795:  sm->cs = 795; goto _test_eof; 
	_test_eof796:  sm->cs = 796; goto _test_eof; 
	_test_eof797:  sm->cs = 797; goto _test_eof; 
	_test_eof798:  sm->cs = 798; goto _test_eof; 
	_test_eof799:  sm->cs = 799; goto _test_eof; 
	_test_eof800:  sm->cs = 800; goto _test_eof; 
	_test_eof801:  sm->cs = 801; goto _test_eof; 
	_test_eof802:  sm->cs = 802; goto _test_eof; 
	_test_eof803:  sm->cs = 803; goto _test_eof; 
	_test_eof804:  sm->cs = 804; goto _test_eof; 
	_test_eof805:  sm->cs = 805; goto _test_eof; 
	_test_eof806:  sm->cs = 806; goto _test_eof; 
	_test_eof807:  sm->cs = 807; goto _test_eof; 
	_test_eof808:  sm->cs = 808; goto _test_eof; 
	_test_eof809:  sm->cs = 809; goto _test_eof; 
	_test_eof810:  sm->cs = 810; goto _test_eof; 
	_test_eof811:  sm->cs = 811; goto _test_eof; 
	_test_eof812:  sm->cs = 812; goto _test_eof; 
	_test_eof813:  sm->cs = 813; goto _test_eof; 
	_test_eof814:  sm->cs = 814; goto _test_eof; 
	_test_eof815:  sm->cs = 815; goto _test_eof; 
	_test_eof816:  sm->cs = 816; goto _test_eof; 
	_test_eof817:  sm->cs = 817; goto _test_eof; 
	_test_eof818:  sm->cs = 818; goto _test_eof; 
	_test_eof819:  sm->cs = 819; goto _test_eof; 
	_test_eof820:  sm->cs = 820; goto _test_eof; 
	_test_eof821:  sm->cs = 821; goto _test_eof; 
	_test_eof822:  sm->cs = 822; goto _test_eof; 
	_test_eof823:  sm->cs = 823; goto _test_eof; 
	_test_eof824:  sm->cs = 824; goto _test_eof; 
	_test_eof825:  sm->cs = 825; goto _test_eof; 
	_test_eof826:  sm->cs = 826; goto _test_eof; 
	_test_eof827:  sm->cs = 827; goto _test_eof; 
	_test_eof828:  sm->cs = 828; goto _test_eof; 
	_test_eof829:  sm->cs = 829; goto _test_eof; 
	_test_eof830:  sm->cs = 830; goto _test_eof; 
	_test_eof831:  sm->cs = 831; goto _test_eof; 
	_test_eof832:  sm->cs = 832; goto _test_eof; 
	_test_eof833:  sm->cs = 833; goto _test_eof; 
	_test_eof834:  sm->cs = 834; goto _test_eof; 
	_test_eof835:  sm->cs = 835; goto _test_eof; 
	_test_eof836:  sm->cs = 836; goto _test_eof; 
	_test_eof837:  sm->cs = 837; goto _test_eof; 
	_test_eof838:  sm->cs = 838; goto _test_eof; 
	_test_eof839:  sm->cs = 839; goto _test_eof; 
	_test_eof840:  sm->cs = 840; goto _test_eof; 
	_test_eof841:  sm->cs = 841; goto _test_eof; 
	_test_eof842:  sm->cs = 842; goto _test_eof; 
	_test_eof843:  sm->cs = 843; goto _test_eof; 
	_test_eof844:  sm->cs = 844; goto _test_eof; 
	_test_eof845:  sm->cs = 845; goto _test_eof; 
	_test_eof846:  sm->cs = 846; goto _test_eof; 
	_test_eof1245:  sm->cs = 1245; goto _test_eof; 
	_test_eof847:  sm->cs = 847; goto _test_eof; 
	_test_eof848:  sm->cs = 848; goto _test_eof; 
	_test_eof849:  sm->cs = 849; goto _test_eof; 
	_test_eof850:  sm->cs = 850; goto _test_eof; 
	_test_eof851:  sm->cs = 851; goto _test_eof; 
	_test_eof852:  sm->cs = 852; goto _test_eof; 
	_test_eof853:  sm->cs = 853; goto _test_eof; 
	_test_eof854:  sm->cs = 854; goto _test_eof; 
	_test_eof855:  sm->cs = 855; goto _test_eof; 
	_test_eof856:  sm->cs = 856; goto _test_eof; 
	_test_eof857:  sm->cs = 857; goto _test_eof; 
	_test_eof858:  sm->cs = 858; goto _test_eof; 
	_test_eof859:  sm->cs = 859; goto _test_eof; 
	_test_eof860:  sm->cs = 860; goto _test_eof; 
	_test_eof861:  sm->cs = 861; goto _test_eof; 
	_test_eof862:  sm->cs = 862; goto _test_eof; 
	_test_eof863:  sm->cs = 863; goto _test_eof; 
	_test_eof864:  sm->cs = 864; goto _test_eof; 
	_test_eof865:  sm->cs = 865; goto _test_eof; 
	_test_eof866:  sm->cs = 866; goto _test_eof; 
	_test_eof867:  sm->cs = 867; goto _test_eof; 
	_test_eof868:  sm->cs = 868; goto _test_eof; 
	_test_eof869:  sm->cs = 869; goto _test_eof; 
	_test_eof870:  sm->cs = 870; goto _test_eof; 
	_test_eof871:  sm->cs = 871; goto _test_eof; 
	_test_eof872:  sm->cs = 872; goto _test_eof; 
	_test_eof873:  sm->cs = 873; goto _test_eof; 
	_test_eof874:  sm->cs = 874; goto _test_eof; 
	_test_eof875:  sm->cs = 875; goto _test_eof; 
	_test_eof876:  sm->cs = 876; goto _test_eof; 
	_test_eof877:  sm->cs = 877; goto _test_eof; 
	_test_eof878:  sm->cs = 878; goto _test_eof; 
	_test_eof879:  sm->cs = 879; goto _test_eof; 
	_test_eof880:  sm->cs = 880; goto _test_eof; 
	_test_eof881:  sm->cs = 881; goto _test_eof; 
	_test_eof882:  sm->cs = 882; goto _test_eof; 
	_test_eof883:  sm->cs = 883; goto _test_eof; 
	_test_eof884:  sm->cs = 884; goto _test_eof; 
	_test_eof885:  sm->cs = 885; goto _test_eof; 
	_test_eof886:  sm->cs = 886; goto _test_eof; 
	_test_eof887:  sm->cs = 887; goto _test_eof; 
	_test_eof888:  sm->cs = 888; goto _test_eof; 
	_test_eof889:  sm->cs = 889; goto _test_eof; 
	_test_eof890:  sm->cs = 890; goto _test_eof; 
	_test_eof891:  sm->cs = 891; goto _test_eof; 
	_test_eof892:  sm->cs = 892; goto _test_eof; 
	_test_eof893:  sm->cs = 893; goto _test_eof; 
	_test_eof894:  sm->cs = 894; goto _test_eof; 
	_test_eof895:  sm->cs = 895; goto _test_eof; 
	_test_eof896:  sm->cs = 896; goto _test_eof; 
	_test_eof897:  sm->cs = 897; goto _test_eof; 
	_test_eof898:  sm->cs = 898; goto _test_eof; 
	_test_eof899:  sm->cs = 899; goto _test_eof; 
	_test_eof900:  sm->cs = 900; goto _test_eof; 
	_test_eof901:  sm->cs = 901; goto _test_eof; 
	_test_eof902:  sm->cs = 902; goto _test_eof; 
	_test_eof903:  sm->cs = 903; goto _test_eof; 
	_test_eof904:  sm->cs = 904; goto _test_eof; 
	_test_eof905:  sm->cs = 905; goto _test_eof; 
	_test_eof906:  sm->cs = 906; goto _test_eof; 
	_test_eof907:  sm->cs = 907; goto _test_eof; 
	_test_eof908:  sm->cs = 908; goto _test_eof; 
	_test_eof909:  sm->cs = 909; goto _test_eof; 
	_test_eof910:  sm->cs = 910; goto _test_eof; 
	_test_eof911:  sm->cs = 911; goto _test_eof; 
	_test_eof912:  sm->cs = 912; goto _test_eof; 
	_test_eof913:  sm->cs = 913; goto _test_eof; 
	_test_eof914:  sm->cs = 914; goto _test_eof; 
	_test_eof915:  sm->cs = 915; goto _test_eof; 
	_test_eof916:  sm->cs = 916; goto _test_eof; 
	_test_eof917:  sm->cs = 917; goto _test_eof; 
	_test_eof918:  sm->cs = 918; goto _test_eof; 
	_test_eof919:  sm->cs = 919; goto _test_eof; 
	_test_eof920:  sm->cs = 920; goto _test_eof; 
	_test_eof921:  sm->cs = 921; goto _test_eof; 
	_test_eof922:  sm->cs = 922; goto _test_eof; 
	_test_eof923:  sm->cs = 923; goto _test_eof; 
	_test_eof924:  sm->cs = 924; goto _test_eof; 
	_test_eof925:  sm->cs = 925; goto _test_eof; 
	_test_eof926:  sm->cs = 926; goto _test_eof; 
	_test_eof927:  sm->cs = 927; goto _test_eof; 
	_test_eof928:  sm->cs = 928; goto _test_eof; 
	_test_eof929:  sm->cs = 929; goto _test_eof; 
	_test_eof930:  sm->cs = 930; goto _test_eof; 
	_test_eof931:  sm->cs = 931; goto _test_eof; 
	_test_eof932:  sm->cs = 932; goto _test_eof; 
	_test_eof933:  sm->cs = 933; goto _test_eof; 
	_test_eof934:  sm->cs = 934; goto _test_eof; 
	_test_eof935:  sm->cs = 935; goto _test_eof; 
	_test_eof936:  sm->cs = 936; goto _test_eof; 
	_test_eof937:  sm->cs = 937; goto _test_eof; 
	_test_eof938:  sm->cs = 938; goto _test_eof; 
	_test_eof939:  sm->cs = 939; goto _test_eof; 
	_test_eof940:  sm->cs = 940; goto _test_eof; 
	_test_eof941:  sm->cs = 941; goto _test_eof; 
	_test_eof942:  sm->cs = 942; goto _test_eof; 
	_test_eof943:  sm->cs = 943; goto _test_eof; 
	_test_eof944:  sm->cs = 944; goto _test_eof; 
	_test_eof945:  sm->cs = 945; goto _test_eof; 
	_test_eof946:  sm->cs = 946; goto _test_eof; 
	_test_eof947:  sm->cs = 947; goto _test_eof; 
	_test_eof948:  sm->cs = 948; goto _test_eof; 
	_test_eof949:  sm->cs = 949; goto _test_eof; 
	_test_eof950:  sm->cs = 950; goto _test_eof; 
	_test_eof951:  sm->cs = 951; goto _test_eof; 
	_test_eof952:  sm->cs = 952; goto _test_eof; 
	_test_eof953:  sm->cs = 953; goto _test_eof; 
	_test_eof954:  sm->cs = 954; goto _test_eof; 
	_test_eof955:  sm->cs = 955; goto _test_eof; 
	_test_eof956:  sm->cs = 956; goto _test_eof; 
	_test_eof957:  sm->cs = 957; goto _test_eof; 
	_test_eof958:  sm->cs = 958; goto _test_eof; 

	_test_eof: {}
	if ( ( sm->p) == ( sm->eof) )
	{
	switch (  sm->cs ) {
	case 960: goto tr0;
	case 1: goto tr0;
	case 2: goto tr0;
	case 961: goto tr1263;
	case 3: goto tr4;
	case 4: goto tr4;
	case 5: goto tr4;
	case 6: goto tr4;
	case 7: goto tr4;
	case 8: goto tr4;
	case 962: goto tr1264;
	case 9: goto tr0;
	case 10: goto tr4;
	case 11: goto tr4;
	case 12: goto tr4;
	case 13: goto tr4;
	case 14: goto tr4;
	case 15: goto tr4;
	case 16: goto tr4;
	case 17: goto tr4;
	case 18: goto tr4;
	case 19: goto tr4;
	case 20: goto tr4;
	case 21: goto tr4;
	case 22: goto tr4;
	case 963: goto tr1263;
	case 964: goto tr1263;
	case 23: goto tr4;
	case 965: goto tr1265;
	case 966: goto tr1265;
	case 24: goto tr4;
	case 967: goto tr1263;
	case 25: goto tr4;
	case 26: goto tr4;
	case 27: goto tr4;
	case 28: goto tr4;
	case 29: goto tr4;
	case 30: goto tr4;
	case 31: goto tr4;
	case 32: goto tr4;
	case 33: goto tr4;
	case 34: goto tr4;
	case 968: goto tr1273;
	case 35: goto tr4;
	case 36: goto tr4;
	case 37: goto tr4;
	case 38: goto tr4;
	case 39: goto tr4;
	case 40: goto tr4;
	case 41: goto tr4;
	case 969: goto tr1274;
	case 42: goto tr50;
	case 43: goto tr50;
	case 970: goto tr1275;
	case 44: goto tr54;
	case 45: goto tr54;
	case 46: goto tr4;
	case 47: goto tr4;
	case 48: goto tr4;
	case 49: goto tr4;
	case 50: goto tr4;
	case 51: goto tr4;
	case 52: goto tr4;
	case 53: goto tr4;
	case 971: goto tr1276;
	case 54: goto tr4;
	case 972: goto tr1278;
	case 55: goto tr4;
	case 56: goto tr4;
	case 57: goto tr4;
	case 58: goto tr4;
	case 59: goto tr4;
	case 60: goto tr4;
	case 61: goto tr4;
	case 973: goto tr1279;
	case 62: goto tr79;
	case 63: goto tr79;
	case 64: goto tr4;
	case 65: goto tr4;
	case 66: goto tr4;
	case 67: goto tr4;
	case 68: goto tr4;
	case 69: goto tr4;
	case 70: goto tr4;
	case 974: goto tr1280;
	case 71: goto tr4;
	case 72: goto tr4;
	case 73: goto tr4;
	case 975: goto tr1263;
	case 74: goto tr4;
	case 75: goto tr4;
	case 76: goto tr4;
	case 976: goto tr1282;
	case 977: goto tr1263;
	case 77: goto tr4;
	case 78: goto tr4;
	case 79: goto tr4;
	case 80: goto tr4;
	case 81: goto tr4;
	case 82: goto tr4;
	case 83: goto tr4;
	case 84: goto tr4;
	case 85: goto tr4;
	case 86: goto tr4;
	case 87: goto tr4;
	case 88: goto tr4;
	case 89: goto tr4;
	case 90: goto tr4;
	case 91: goto tr4;
	case 92: goto tr4;
	case 93: goto tr4;
	case 94: goto tr4;
	case 95: goto tr4;
	case 96: goto tr4;
	case 97: goto tr4;
	case 98: goto tr4;
	case 99: goto tr4;
	case 100: goto tr4;
	case 101: goto tr4;
	case 102: goto tr4;
	case 103: goto tr4;
	case 104: goto tr4;
	case 105: goto tr4;
	case 106: goto tr4;
	case 107: goto tr4;
	case 108: goto tr4;
	case 109: goto tr4;
	case 110: goto tr4;
	case 111: goto tr4;
	case 112: goto tr4;
	case 113: goto tr4;
	case 114: goto tr4;
	case 978: goto tr1263;
	case 115: goto tr4;
	case 116: goto tr4;
	case 117: goto tr4;
	case 118: goto tr4;
	case 119: goto tr4;
	case 120: goto tr4;
	case 121: goto tr4;
	case 122: goto tr4;
	case 123: goto tr4;
	case 124: goto tr4;
	case 125: goto tr4;
	case 126: goto tr4;
	case 980: goto tr1295;
	case 127: goto tr157;
	case 128: goto tr157;
	case 129: goto tr157;
	case 130: goto tr157;
	case 131: goto tr157;
	case 132: goto tr157;
	case 133: goto tr157;
	case 134: goto tr157;
	case 135: goto tr157;
	case 136: goto tr157;
	case 137: goto tr157;
	case 138: goto tr157;
	case 139: goto tr157;
	case 140: goto tr157;
	case 141: goto tr157;
	case 142: goto tr157;
	case 143: goto tr157;
	case 144: goto tr157;
	case 145: goto tr157;
	case 981: goto tr1295;
	case 146: goto tr157;
	case 147: goto tr157;
	case 148: goto tr157;
	case 149: goto tr157;
	case 150: goto tr157;
	case 151: goto tr157;
	case 152: goto tr157;
	case 153: goto tr157;
	case 154: goto tr157;
	case 983: goto tr1337;
	case 984: goto tr1338;
	case 155: goto tr185;
	case 156: goto tr185;
	case 157: goto tr188;
	case 985: goto tr1337;
	case 986: goto tr1337;
	case 987: goto tr185;
	case 158: goto tr185;
	case 159: goto tr185;
	case 988: goto tr1337;
	case 160: goto tr193;
	case 161: goto tr193;
	case 989: goto tr1340;
	case 162: goto tr196;
	case 163: goto tr196;
	case 164: goto tr196;
	case 165: goto tr196;
	case 166: goto tr196;
	case 990: goto tr1347;
	case 167: goto tr185;
	case 168: goto tr196;
	case 169: goto tr196;
	case 170: goto tr196;
	case 171: goto tr196;
	case 172: goto tr196;
	case 173: goto tr196;
	case 174: goto tr196;
	case 175: goto tr196;
	case 176: goto tr196;
	case 177: goto tr196;
	case 178: goto tr196;
	case 179: goto tr196;
	case 180: goto tr196;
	case 181: goto tr196;
	case 182: goto tr196;
	case 183: goto tr196;
	case 184: goto tr196;
	case 185: goto tr196;
	case 186: goto tr196;
	case 187: goto tr196;
	case 188: goto tr196;
	case 189: goto tr196;
	case 190: goto tr196;
	case 191: goto tr196;
	case 192: goto tr196;
	case 193: goto tr196;
	case 194: goto tr196;
	case 195: goto tr196;
	case 196: goto tr196;
	case 197: goto tr196;
	case 198: goto tr196;
	case 991: goto tr1348;
	case 199: goto tr185;
	case 200: goto tr238;
	case 201: goto tr238;
	case 202: goto tr185;
	case 203: goto tr185;
	case 204: goto tr185;
	case 205: goto tr185;
	case 206: goto tr238;
	case 207: goto tr238;
	case 208: goto tr185;
	case 209: goto tr185;
	case 210: goto tr185;
	case 211: goto tr185;
	case 212: goto tr196;
	case 213: goto tr196;
	case 992: goto tr1351;
	case 993: goto tr1351;
	case 214: goto tr196;
	case 215: goto tr196;
	case 216: goto tr196;
	case 217: goto tr185;
	case 218: goto tr185;
	case 219: goto tr185;
	case 220: goto tr185;
	case 221: goto tr185;
	case 222: goto tr185;
	case 223: goto tr185;
	case 224: goto tr185;
	case 225: goto tr185;
	case 994: goto tr1353;
	case 226: goto tr196;
	case 227: goto tr185;
	case 228: goto tr185;
	case 229: goto tr185;
	case 230: goto tr185;
	case 231: goto tr185;
	case 995: goto tr1354;
	case 232: goto tr185;
	case 233: goto tr185;
	case 234: goto tr185;
	case 235: goto tr185;
	case 236: goto tr185;
	case 237: goto tr196;
	case 238: goto tr185;
	case 239: goto tr185;
	case 240: goto tr185;
	case 241: goto tr185;
	case 242: goto tr185;
	case 243: goto tr185;
	case 244: goto tr185;
	case 245: goto tr196;
	case 246: goto tr196;
	case 247: goto tr196;
	case 248: goto tr196;
	case 249: goto tr196;
	case 250: goto tr196;
	case 251: goto tr196;
	case 252: goto tr196;
	case 253: goto tr196;
	case 254: goto tr196;
	case 255: goto tr196;
	case 256: goto tr196;
	case 257: goto tr196;
	case 258: goto tr196;
	case 259: goto tr196;
	case 260: goto tr196;
	case 261: goto tr196;
	case 262: goto tr196;
	case 996: goto tr1355;
	case 263: goto tr196;
	case 264: goto tr196;
	case 265: goto tr185;
	case 266: goto tr185;
	case 267: goto tr185;
	case 268: goto tr185;
	case 269: goto tr185;
	case 270: goto tr185;
	case 271: goto tr196;
	case 272: goto tr185;
	case 273: goto tr185;
	case 274: goto tr185;
	case 275: goto tr185;
	case 276: goto tr185;
	case 277: goto tr185;
	case 278: goto tr185;
	case 279: goto tr196;
	case 280: goto tr196;
	case 281: goto tr196;
	case 282: goto tr196;
	case 283: goto tr196;
	case 284: goto tr196;
	case 285: goto tr196;
	case 286: goto tr196;
	case 287: goto tr196;
	case 288: goto tr196;
	case 289: goto tr196;
	case 290: goto tr196;
	case 291: goto tr196;
	case 292: goto tr196;
	case 293: goto tr196;
	case 294: goto tr196;
	case 295: goto tr196;
	case 296: goto tr196;
	case 297: goto tr196;
	case 298: goto tr196;
	case 299: goto tr196;
	case 300: goto tr196;
	case 301: goto tr196;
	case 302: goto tr196;
	case 303: goto tr196;
	case 304: goto tr196;
	case 305: goto tr196;
	case 997: goto tr1357;
	case 998: goto tr1337;
	case 306: goto tr193;
	case 307: goto tr193;
	case 308: goto tr193;
	case 999: goto tr1359;
	case 309: goto tr193;
	case 310: goto tr193;
	case 311: goto tr193;
	case 312: goto tr193;
	case 313: goto tr193;
	case 314: goto tr193;
	case 315: goto tr193;
	case 316: goto tr193;
	case 317: goto tr193;
	case 318: goto tr193;
	case 319: goto tr193;
	case 320: goto tr193;
	case 321: goto tr193;
	case 322: goto tr193;
	case 323: goto tr193;
	case 324: goto tr193;
	case 325: goto tr193;
	case 326: goto tr193;
	case 1000: goto tr1338;
	case 327: goto tr188;
	case 328: goto tr185;
	case 329: goto tr185;
	case 330: goto tr185;
	case 331: goto tr185;
	case 332: goto tr185;
	case 333: goto tr185;
	case 334: goto tr185;
	case 335: goto tr185;
	case 1001: goto tr1363;
	case 1002: goto tr1365;
	case 336: goto tr185;
	case 337: goto tr185;
	case 338: goto tr185;
	case 339: goto tr185;
	case 1003: goto tr1367;
	case 1004: goto tr1369;
	case 340: goto tr185;
	case 341: goto tr185;
	case 342: goto tr185;
	case 343: goto tr185;
	case 344: goto tr185;
	case 345: goto tr185;
	case 346: goto tr185;
	case 347: goto tr185;
	case 348: goto tr185;
	case 1005: goto tr1363;
	case 1006: goto tr1365;
	case 349: goto tr185;
	case 350: goto tr185;
	case 351: goto tr185;
	case 352: goto tr185;
	case 353: goto tr185;
	case 354: goto tr185;
	case 355: goto tr185;
	case 356: goto tr185;
	case 357: goto tr185;
	case 358: goto tr185;
	case 359: goto tr185;
	case 360: goto tr185;
	case 361: goto tr185;
	case 362: goto tr185;
	case 363: goto tr185;
	case 364: goto tr185;
	case 365: goto tr185;
	case 366: goto tr185;
	case 367: goto tr185;
	case 368: goto tr185;
	case 369: goto tr185;
	case 370: goto tr185;
	case 371: goto tr185;
	case 372: goto tr185;
	case 373: goto tr185;
	case 374: goto tr185;
	case 375: goto tr185;
	case 376: goto tr185;
	case 377: goto tr185;
	case 378: goto tr185;
	case 379: goto tr185;
	case 380: goto tr188;
	case 381: goto tr185;
	case 382: goto tr185;
	case 383: goto tr185;
	case 384: goto tr185;
	case 385: goto tr185;
	case 386: goto tr185;
	case 387: goto tr185;
	case 388: goto tr185;
	case 389: goto tr185;
	case 390: goto tr185;
	case 391: goto tr185;
	case 1007: goto tr1373;
	case 1008: goto tr1375;
	case 392: goto tr185;
	case 1009: goto tr1377;
	case 1010: goto tr1379;
	case 393: goto tr185;
	case 394: goto tr185;
	case 395: goto tr185;
	case 396: goto tr185;
	case 397: goto tr185;
	case 398: goto tr185;
	case 399: goto tr185;
	case 400: goto tr185;
	case 1011: goto tr1377;
	case 1012: goto tr1379;
	case 401: goto tr185;
	case 1013: goto tr1377;
	case 402: goto tr185;
	case 403: goto tr185;
	case 404: goto tr185;
	case 405: goto tr185;
	case 406: goto tr185;
	case 407: goto tr185;
	case 408: goto tr185;
	case 409: goto tr185;
	case 410: goto tr185;
	case 411: goto tr185;
	case 412: goto tr185;
	case 413: goto tr185;
	case 414: goto tr185;
	case 415: goto tr185;
	case 416: goto tr185;
	case 417: goto tr185;
	case 418: goto tr185;
	case 419: goto tr185;
	case 1014: goto tr1377;
	case 420: goto tr185;
	case 421: goto tr185;
	case 422: goto tr185;
	case 423: goto tr185;
	case 424: goto tr185;
	case 425: goto tr185;
	case 426: goto tr185;
	case 427: goto tr185;
	case 428: goto tr185;
	case 1015: goto tr1338;
	case 1016: goto tr1338;
	case 1017: goto tr1338;
	case 1018: goto tr1338;
	case 1019: goto tr1338;
	case 429: goto tr188;
	case 430: goto tr188;
	case 1020: goto tr1391;
	case 1021: goto tr1338;
	case 1022: goto tr1338;
	case 1023: goto tr1338;
	case 1024: goto tr1338;
	case 1025: goto tr1338;
	case 431: goto tr188;
	case 432: goto tr188;
	case 1026: goto tr1398;
	case 1027: goto tr1338;
	case 1028: goto tr1338;
	case 1029: goto tr1338;
	case 1030: goto tr1338;
	case 1031: goto tr1338;
	case 433: goto tr188;
	case 434: goto tr188;
	case 1032: goto tr1406;
	case 1033: goto tr1338;
	case 1034: goto tr1338;
	case 1035: goto tr1338;
	case 1036: goto tr1338;
	case 1037: goto tr1338;
	case 1038: goto tr1338;
	case 1039: goto tr1338;
	case 435: goto tr188;
	case 436: goto tr188;
	case 1040: goto tr1415;
	case 1041: goto tr1338;
	case 1042: goto tr1338;
	case 1043: goto tr1338;
	case 437: goto tr188;
	case 438: goto tr188;
	case 1044: goto tr1421;
	case 1045: goto tr1338;
	case 1046: goto tr1338;
	case 439: goto tr188;
	case 440: goto tr188;
	case 1047: goto tr1425;
	case 1048: goto tr1338;
	case 1049: goto tr1338;
	case 1050: goto tr1338;
	case 1051: goto tr1338;
	case 1052: goto tr1338;
	case 1053: goto tr1338;
	case 1054: goto tr1338;
	case 441: goto tr188;
	case 442: goto tr188;
	case 1055: goto tr1435;
	case 1056: goto tr1338;
	case 1057: goto tr1338;
	case 443: goto tr188;
	case 444: goto tr188;
	case 1058: goto tr1439;
	case 1059: goto tr1338;
	case 1060: goto tr1338;
	case 1061: goto tr1338;
	case 1062: goto tr1338;
	case 1063: goto tr1338;
	case 1064: goto tr1338;
	case 1065: goto tr1338;
	case 1066: goto tr1338;
	case 1067: goto tr1338;
	case 1068: goto tr1338;
	case 445: goto tr188;
	case 446: goto tr188;
	case 1069: goto tr1452;
	case 1070: goto tr1338;
	case 1071: goto tr1338;
	case 1072: goto tr1338;
	case 1073: goto tr1338;
	case 447: goto tr188;
	case 448: goto tr188;
	case 1074: goto tr1458;
	case 449: goto tr587;
	case 1075: goto tr1461;
	case 1076: goto tr1338;
	case 1077: goto tr1338;
	case 1078: goto tr1338;
	case 1079: goto tr1338;
	case 1080: goto tr1338;
	case 1081: goto tr1338;
	case 1082: goto tr1338;
	case 1083: goto tr1338;
	case 450: goto tr188;
	case 451: goto tr188;
	case 1084: goto tr1474;
	case 1085: goto tr1338;
	case 1086: goto tr1338;
	case 1087: goto tr1338;
	case 1088: goto tr1338;
	case 1089: goto tr1338;
	case 1090: goto tr1338;
	case 1091: goto tr1338;
	case 452: goto tr188;
	case 453: goto tr188;
	case 1092: goto tr1483;
	case 1093: goto tr1338;
	case 1094: goto tr1338;
	case 1095: goto tr1338;
	case 454: goto tr188;
	case 455: goto tr188;
	case 1096: goto tr1488;
	case 1097: goto tr1338;
	case 1098: goto tr1338;
	case 1099: goto tr1338;
	case 1100: goto tr1338;
	case 456: goto tr188;
	case 457: goto tr188;
	case 1101: goto tr1494;
	case 1102: goto tr1338;
	case 1103: goto tr1338;
	case 1104: goto tr1338;
	case 1105: goto tr1338;
	case 1106: goto tr1338;
	case 1107: goto tr1338;
	case 1108: goto tr1338;
	case 1109: goto tr1338;
	case 458: goto tr188;
	case 459: goto tr188;
	case 1110: goto tr1504;
	case 1111: goto tr1338;
	case 1112: goto tr1338;
	case 1113: goto tr1338;
	case 1114: goto tr1338;
	case 460: goto tr188;
	case 461: goto tr188;
	case 462: goto tr188;
	case 1115: goto tr1511;
	case 1116: goto tr1338;
	case 1117: goto tr1338;
	case 1118: goto tr1338;
	case 1119: goto tr1338;
	case 1120: goto tr1338;
	case 1121: goto tr1338;
	case 1122: goto tr1338;
	case 1123: goto tr1338;
	case 1124: goto tr1338;
	case 1125: goto tr1338;
	case 1126: goto tr1338;
	case 1127: goto tr1338;
	case 463: goto tr188;
	case 464: goto tr188;
	case 1128: goto tr1524;
	case 1129: goto tr1338;
	case 1130: goto tr1338;
	case 1131: goto tr1338;
	case 1132: goto tr1338;
	case 465: goto tr188;
	case 466: goto tr188;
	case 1133: goto tr1530;
	case 1134: goto tr1338;
	case 1135: goto tr1338;
	case 1136: goto tr1338;
	case 467: goto tr188;
	case 468: goto tr188;
	case 469: goto tr188;
	case 470: goto tr188;
	case 471: goto tr188;
	case 472: goto tr188;
	case 473: goto tr188;
	case 474: goto tr188;
	case 475: goto tr188;
	case 1137: goto tr1536;
	case 1138: goto tr1338;
	case 1139: goto tr1338;
	case 1140: goto tr1338;
	case 1141: goto tr1338;
	case 1142: goto tr1338;
	case 1143: goto tr1338;
	case 476: goto tr188;
	case 477: goto tr188;
	case 1144: goto tr1544;
	case 1145: goto tr1338;
	case 1146: goto tr1338;
	case 1147: goto tr1338;
	case 1148: goto tr1338;
	case 1149: goto tr1338;
	case 478: goto tr188;
	case 479: goto tr188;
	case 1150: goto tr1552;
	case 1151: goto tr1338;
	case 1152: goto tr1338;
	case 1153: goto tr1338;
	case 480: goto tr188;
	case 481: goto tr188;
	case 1154: goto tr1557;
	case 1155: goto tr1338;
	case 1156: goto tr1338;
	case 1157: goto tr1338;
	case 1158: goto tr1338;
	case 1159: goto tr1338;
	case 482: goto tr188;
	case 483: goto tr188;
	case 1160: goto tr1567;
	case 1161: goto tr1338;
	case 1162: goto tr1338;
	case 1163: goto tr1338;
	case 1164: goto tr1338;
	case 484: goto tr188;
	case 485: goto tr188;
	case 1165: goto tr1573;
	case 486: goto tr625;
	case 487: goto tr625;
	case 1166: goto tr1576;
	case 1167: goto tr1338;
	case 1168: goto tr1338;
	case 1169: goto tr1338;
	case 488: goto tr188;
	case 489: goto tr188;
	case 1170: goto tr1582;
	case 1171: goto tr1338;
	case 1172: goto tr1338;
	case 490: goto tr188;
	case 491: goto tr188;
	case 1173: goto tr1586;
	case 1174: goto tr1338;
	case 1175: goto tr1338;
	case 1176: goto tr1338;
	case 492: goto tr188;
	case 493: goto tr188;
	case 1177: goto tr1591;
	case 1178: goto tr1338;
	case 1179: goto tr1338;
	case 1180: goto tr1338;
	case 1181: goto tr1338;
	case 1182: goto tr1338;
	case 1183: goto tr1338;
	case 1184: goto tr1338;
	case 494: goto tr188;
	case 495: goto tr188;
	case 1185: goto tr1601;
	case 1186: goto tr1338;
	case 1187: goto tr1338;
	case 1188: goto tr1338;
	case 1189: goto tr1338;
	case 496: goto tr188;
	case 497: goto tr188;
	case 1190: goto tr1607;
	case 1191: goto tr1338;
	case 1192: goto tr1338;
	case 1193: goto tr1338;
	case 1194: goto tr1338;
	case 1195: goto tr1338;
	case 498: goto tr188;
	case 499: goto tr188;
	case 1196: goto tr1615;
	case 500: goto tr640;
	case 501: goto tr640;
	case 1197: goto tr1618;
	case 1198: goto tr1338;
	case 1199: goto tr1338;
	case 1200: goto tr1338;
	case 1201: goto tr1338;
	case 1202: goto tr1338;
	case 1203: goto tr1338;
	case 502: goto tr188;
	case 503: goto tr188;
	case 1204: goto tr1626;
	case 1205: goto tr1338;
	case 1206: goto tr1338;
	case 1207: goto tr1338;
	case 1208: goto tr1338;
	case 504: goto tr188;
	case 505: goto tr188;
	case 1209: goto tr1632;
	case 1210: goto tr1338;
	case 1211: goto tr1338;
	case 1212: goto tr1338;
	case 1213: goto tr1338;
	case 506: goto tr188;
	case 507: goto tr188;
	case 1214: goto tr1638;
	case 1215: goto tr1338;
	case 1216: goto tr1338;
	case 1217: goto tr1338;
	case 1218: goto tr1338;
	case 1219: goto tr1338;
	case 1220: goto tr1338;
	case 1221: goto tr1338;
	case 508: goto tr188;
	case 509: goto tr188;
	case 1222: goto tr1647;
	case 1223: goto tr1337;
	case 510: goto tr193;
	case 511: goto tr193;
	case 512: goto tr193;
	case 513: goto tr193;
	case 514: goto tr193;
	case 515: goto tr193;
	case 516: goto tr193;
	case 517: goto tr193;
	case 518: goto tr193;
	case 519: goto tr193;
	case 520: goto tr193;
	case 521: goto tr193;
	case 522: goto tr193;
	case 1224: goto tr1660;
	case 523: goto tr669;
	case 524: goto tr669;
	case 1225: goto tr1661;
	case 525: goto tr673;
	case 526: goto tr673;
	case 527: goto tr193;
	case 528: goto tr193;
	case 529: goto tr193;
	case 530: goto tr193;
	case 531: goto tr193;
	case 532: goto tr193;
	case 533: goto tr193;
	case 534: goto tr193;
	case 535: goto tr193;
	case 536: goto tr193;
	case 537: goto tr193;
	case 538: goto tr193;
	case 539: goto tr193;
	case 540: goto tr193;
	case 541: goto tr193;
	case 542: goto tr193;
	case 543: goto tr193;
	case 544: goto tr193;
	case 545: goto tr193;
	case 546: goto tr193;
	case 547: goto tr193;
	case 548: goto tr193;
	case 549: goto tr193;
	case 550: goto tr193;
	case 551: goto tr193;
	case 552: goto tr193;
	case 553: goto tr193;
	case 554: goto tr193;
	case 555: goto tr193;
	case 1226: goto tr1662;
	case 556: goto tr712;
	case 557: goto tr712;
	case 558: goto tr193;
	case 559: goto tr193;
	case 560: goto tr193;
	case 561: goto tr193;
	case 562: goto tr193;
	case 563: goto tr193;
	case 564: goto tr193;
	case 565: goto tr193;
	case 566: goto tr193;
	case 567: goto tr193;
	case 568: goto tr193;
	case 569: goto tr193;
	case 570: goto tr193;
	case 571: goto tr193;
	case 572: goto tr193;
	case 573: goto tr193;
	case 1227: goto tr1337;
	case 1228: goto tr1337;
	case 574: goto tr193;
	case 575: goto tr193;
	case 576: goto tr193;
	case 577: goto tr193;
	case 578: goto tr193;
	case 579: goto tr193;
	case 580: goto tr193;
	case 581: goto tr193;
	case 582: goto tr193;
	case 583: goto tr193;
	case 584: goto tr193;
	case 585: goto tr193;
	case 586: goto tr193;
	case 587: goto tr193;
	case 588: goto tr193;
	case 589: goto tr193;
	case 590: goto tr193;
	case 591: goto tr193;
	case 592: goto tr193;
	case 593: goto tr193;
	case 594: goto tr193;
	case 595: goto tr193;
	case 596: goto tr193;
	case 597: goto tr193;
	case 598: goto tr193;
	case 599: goto tr193;
	case 600: goto tr193;
	case 601: goto tr193;
	case 602: goto tr193;
	case 603: goto tr193;
	case 604: goto tr193;
	case 605: goto tr193;
	case 606: goto tr193;
	case 607: goto tr193;
	case 608: goto tr193;
	case 609: goto tr193;
	case 610: goto tr193;
	case 611: goto tr193;
	case 612: goto tr193;
	case 613: goto tr193;
	case 614: goto tr193;
	case 615: goto tr193;
	case 616: goto tr193;
	case 617: goto tr193;
	case 618: goto tr193;
	case 619: goto tr193;
	case 620: goto tr193;
	case 621: goto tr193;
	case 622: goto tr193;
	case 623: goto tr193;
	case 624: goto tr193;
	case 625: goto tr193;
	case 626: goto tr193;
	case 627: goto tr193;
	case 628: goto tr193;
	case 629: goto tr193;
	case 630: goto tr193;
	case 631: goto tr193;
	case 632: goto tr193;
	case 633: goto tr193;
	case 634: goto tr193;
	case 635: goto tr193;
	case 636: goto tr193;
	case 637: goto tr193;
	case 638: goto tr193;
	case 639: goto tr193;
	case 640: goto tr193;
	case 641: goto tr193;
	case 642: goto tr193;
	case 643: goto tr193;
	case 644: goto tr193;
	case 645: goto tr193;
	case 646: goto tr193;
	case 647: goto tr193;
	case 648: goto tr193;
	case 649: goto tr193;
	case 650: goto tr193;
	case 651: goto tr193;
	case 652: goto tr193;
	case 653: goto tr193;
	case 654: goto tr193;
	case 655: goto tr193;
	case 656: goto tr193;
	case 657: goto tr193;
	case 658: goto tr193;
	case 659: goto tr193;
	case 660: goto tr193;
	case 661: goto tr193;
	case 662: goto tr193;
	case 663: goto tr193;
	case 664: goto tr193;
	case 665: goto tr193;
	case 666: goto tr193;
	case 1229: goto tr1337;
	case 667: goto tr193;
	case 668: goto tr193;
	case 1230: goto tr1337;
	case 669: goto tr193;
	case 670: goto tr185;
	case 671: goto tr185;
	case 672: goto tr185;
	case 1231: goto tr1682;
	case 673: goto tr185;
	case 674: goto tr185;
	case 675: goto tr185;
	case 676: goto tr185;
	case 677: goto tr185;
	case 678: goto tr185;
	case 679: goto tr185;
	case 680: goto tr185;
	case 681: goto tr185;
	case 682: goto tr185;
	case 1232: goto tr1682;
	case 683: goto tr185;
	case 684: goto tr185;
	case 685: goto tr185;
	case 686: goto tr185;
	case 687: goto tr185;
	case 688: goto tr185;
	case 689: goto tr185;
	case 690: goto tr185;
	case 691: goto tr185;
	case 692: goto tr185;
	case 693: goto tr193;
	case 694: goto tr193;
	case 695: goto tr193;
	case 696: goto tr193;
	case 697: goto tr193;
	case 698: goto tr193;
	case 699: goto tr193;
	case 700: goto tr193;
	case 701: goto tr193;
	case 702: goto tr193;
	case 1234: goto tr1689;
	case 703: goto tr862;
	case 704: goto tr862;
	case 705: goto tr862;
	case 706: goto tr862;
	case 707: goto tr862;
	case 708: goto tr862;
	case 709: goto tr862;
	case 710: goto tr862;
	case 711: goto tr862;
	case 712: goto tr862;
	case 713: goto tr862;
	case 714: goto tr862;
	case 1235: goto tr1689;
	case 715: goto tr862;
	case 1236: goto tr1689;
	case 1237: goto tr1689;
	case 1239: goto tr1697;
	case 716: goto tr876;
	case 717: goto tr876;
	case 718: goto tr876;
	case 719: goto tr876;
	case 720: goto tr876;
	case 721: goto tr876;
	case 722: goto tr876;
	case 723: goto tr876;
	case 724: goto tr876;
	case 725: goto tr876;
	case 726: goto tr876;
	case 727: goto tr876;
	case 728: goto tr876;
	case 729: goto tr876;
	case 730: goto tr876;
	case 731: goto tr876;
	case 732: goto tr876;
	case 733: goto tr876;
	case 1240: goto tr1697;
	case 734: goto tr876;
	case 1241: goto tr1697;
	case 1242: goto tr1697;
	case 1244: goto tr1702;
	case 735: goto tr896;
	case 736: goto tr896;
	case 737: goto tr896;
	case 738: goto tr896;
	case 739: goto tr896;
	case 740: goto tr896;
	case 741: goto tr896;
	case 742: goto tr896;
	case 743: goto tr896;
	case 744: goto tr896;
	case 745: goto tr896;
	case 746: goto tr896;
	case 747: goto tr896;
	case 748: goto tr896;
	case 749: goto tr896;
	case 750: goto tr896;
	case 751: goto tr896;
	case 752: goto tr896;
	case 753: goto tr896;
	case 754: goto tr896;
	case 755: goto tr896;
	case 756: goto tr896;
	case 757: goto tr896;
	case 758: goto tr896;
	case 759: goto tr896;
	case 760: goto tr896;
	case 761: goto tr896;
	case 762: goto tr896;
	case 763: goto tr896;
	case 764: goto tr896;
	case 765: goto tr896;
	case 766: goto tr896;
	case 767: goto tr896;
	case 768: goto tr896;
	case 769: goto tr896;
	case 770: goto tr896;
	case 771: goto tr896;
	case 772: goto tr896;
	case 773: goto tr896;
	case 774: goto tr896;
	case 775: goto tr896;
	case 776: goto tr896;
	case 777: goto tr896;
	case 778: goto tr896;
	case 779: goto tr896;
	case 780: goto tr896;
	case 781: goto tr896;
	case 782: goto tr896;
	case 783: goto tr896;
	case 784: goto tr896;
	case 785: goto tr896;
	case 786: goto tr896;
	case 787: goto tr896;
	case 788: goto tr896;
	case 789: goto tr896;
	case 790: goto tr896;
	case 791: goto tr896;
	case 792: goto tr896;
	case 793: goto tr896;
	case 794: goto tr896;
	case 795: goto tr896;
	case 796: goto tr896;
	case 797: goto tr896;
	case 798: goto tr896;
	case 799: goto tr896;
	case 800: goto tr896;
	case 801: goto tr896;
	case 802: goto tr896;
	case 803: goto tr896;
	case 804: goto tr896;
	case 805: goto tr896;
	case 806: goto tr896;
	case 807: goto tr896;
	case 808: goto tr896;
	case 809: goto tr896;
	case 810: goto tr896;
	case 811: goto tr896;
	case 812: goto tr896;
	case 813: goto tr896;
	case 814: goto tr896;
	case 815: goto tr896;
	case 816: goto tr896;
	case 817: goto tr896;
	case 818: goto tr896;
	case 819: goto tr896;
	case 820: goto tr896;
	case 821: goto tr896;
	case 822: goto tr896;
	case 823: goto tr896;
	case 824: goto tr896;
	case 825: goto tr896;
	case 826: goto tr896;
	case 827: goto tr896;
	case 828: goto tr896;
	case 829: goto tr896;
	case 830: goto tr896;
	case 831: goto tr896;
	case 832: goto tr896;
	case 833: goto tr896;
	case 834: goto tr896;
	case 835: goto tr896;
	case 836: goto tr896;
	case 837: goto tr896;
	case 838: goto tr896;
	case 839: goto tr896;
	case 840: goto tr896;
	case 841: goto tr896;
	case 842: goto tr896;
	case 843: goto tr896;
	case 844: goto tr896;
	case 845: goto tr896;
	case 846: goto tr896;
	case 1245: goto tr1702;
	case 847: goto tr896;
	case 848: goto tr896;
	case 849: goto tr896;
	case 850: goto tr896;
	case 851: goto tr896;
	case 852: goto tr896;
	case 853: goto tr896;
	case 854: goto tr896;
	case 855: goto tr896;
	case 856: goto tr896;
	case 857: goto tr896;
	case 858: goto tr896;
	case 859: goto tr896;
	case 860: goto tr896;
	case 861: goto tr896;
	case 862: goto tr896;
	case 863: goto tr896;
	case 864: goto tr896;
	case 865: goto tr896;
	case 866: goto tr896;
	case 867: goto tr896;
	case 868: goto tr896;
	case 869: goto tr896;
	case 870: goto tr896;
	case 871: goto tr896;
	case 872: goto tr896;
	case 873: goto tr896;
	case 874: goto tr896;
	case 875: goto tr896;
	case 876: goto tr896;
	case 877: goto tr896;
	case 878: goto tr896;
	case 879: goto tr896;
	case 880: goto tr896;
	case 881: goto tr896;
	case 882: goto tr896;
	case 883: goto tr896;
	case 884: goto tr896;
	case 885: goto tr896;
	case 886: goto tr896;
	case 887: goto tr896;
	case 888: goto tr896;
	case 889: goto tr896;
	case 890: goto tr896;
	case 891: goto tr896;
	case 892: goto tr896;
	case 893: goto tr896;
	case 894: goto tr896;
	case 895: goto tr896;
	case 896: goto tr896;
	case 897: goto tr896;
	case 898: goto tr896;
	case 899: goto tr896;
	case 900: goto tr896;
	case 901: goto tr896;
	case 902: goto tr896;
	case 903: goto tr896;
	case 904: goto tr896;
	case 905: goto tr896;
	case 906: goto tr896;
	case 907: goto tr896;
	case 908: goto tr896;
	case 909: goto tr896;
	case 910: goto tr896;
	case 911: goto tr896;
	case 912: goto tr896;
	case 913: goto tr896;
	case 914: goto tr896;
	case 915: goto tr896;
	case 916: goto tr896;
	case 917: goto tr896;
	case 918: goto tr896;
	case 919: goto tr896;
	case 920: goto tr896;
	case 921: goto tr896;
	case 922: goto tr896;
	case 923: goto tr896;
	case 924: goto tr896;
	case 925: goto tr896;
	case 926: goto tr896;
	case 927: goto tr896;
	case 928: goto tr896;
	case 929: goto tr896;
	case 930: goto tr896;
	case 931: goto tr896;
	case 932: goto tr896;
	case 933: goto tr896;
	case 934: goto tr896;
	case 935: goto tr896;
	case 936: goto tr896;
	case 937: goto tr896;
	case 938: goto tr896;
	case 939: goto tr896;
	case 940: goto tr896;
	case 941: goto tr896;
	case 942: goto tr896;
	case 943: goto tr896;
	case 944: goto tr896;
	case 945: goto tr896;
	case 946: goto tr896;
	case 947: goto tr896;
	case 948: goto tr896;
	case 949: goto tr896;
	case 950: goto tr896;
	case 951: goto tr896;
	case 952: goto tr896;
	case 953: goto tr896;
	case 954: goto tr896;
	case 955: goto tr896;
	case 956: goto tr896;
	case 957: goto tr896;
	case 958: goto tr896;
	}
	}

	_out: {}
	}

#line 1502 "ext/dtext/dtext.cpp.rl"

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
