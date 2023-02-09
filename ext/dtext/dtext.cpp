
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


#line 741 "ext/dtext/dtext.cpp.rl"



#line 52 "ext/dtext/dtext.cpp"
static const int dtext_start = 1123;
static const int dtext_first_final = 1123;
static const int dtext_error = 0;

static const int dtext_en_basic_inline = 1143;
static const int dtext_en_inline = 1146;
static const int dtext_en_code = 1405;
static const int dtext_en_nodtext = 1410;
static const int dtext_en_table = 1415;
static const int dtext_en_main = 1123;


#line 744 "ext/dtext/dtext.cpp.rl"

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
  auto [trimmed_url, leftovers] = trim_url(url);
  append_unnamed_url(sm, trimmed_url);
  append_html_escaped(sm, leftovers);
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

static void append_bare_named_url(StateMachine * sm, const std::string_view url, std::string_view title) {
  auto [trimmed_url, leftovers] = trim_url(url);
  append_named_url(sm, trimmed_url, title);
  append_html_escaped(sm, leftovers);
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

// Trim trailing unbalanced ')' characters from the URL.
static std::tuple<std::string_view, std::string_view> trim_url(const std::string_view url) {
  std::string_view trimmed = url;

  while (!trimmed.empty() && trimmed.back() == ')' && std::count(trimmed.begin(), trimmed.end(), ')') > std::count(trimmed.begin(), trimmed.end(), '(')) {
    trimmed.remove_suffix(1);
  }

  return { trimmed, { trimmed.end(), url.end() } };
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

  
#line 762 "ext/dtext/dtext.cpp"
	{
	( sm->top) = 0;
	( sm->ts) = 0;
	( sm->te) = 0;
	( sm->act) = 0;
	}

#line 1440 "ext/dtext/dtext.cpp.rl"
  
#line 772 "ext/dtext/dtext.cpp"
	{
	short _widec;
	if ( ( sm->p) == ( sm->pe) )
		goto _test_eof;
	goto _resume;

_again:
	switch (  sm->cs ) {
		case 1123: goto st1123;
		case 1124: goto st1124;
		case 1: goto st1;
		case 2: goto st2;
		case 1125: goto st1125;
		case 3: goto st3;
		case 4: goto st4;
		case 5: goto st5;
		case 6: goto st6;
		case 7: goto st7;
		case 8: goto st8;
		case 1126: goto st1126;
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
		case 1127: goto st1127;
		case 1128: goto st1128;
		case 23: goto st23;
		case 1129: goto st1129;
		case 1130: goto st1130;
		case 24: goto st24;
		case 1131: goto st1131;
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
		case 1132: goto st1132;
		case 35: goto st35;
		case 36: goto st36;
		case 37: goto st37;
		case 38: goto st38;
		case 39: goto st39;
		case 40: goto st40;
		case 41: goto st41;
		case 1133: goto st1133;
		case 42: goto st42;
		case 43: goto st43;
		case 1134: goto st1134;
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
		case 1135: goto st1135;
		case 54: goto st54;
		case 1136: goto st1136;
		case 55: goto st55;
		case 56: goto st56;
		case 57: goto st57;
		case 58: goto st58;
		case 59: goto st59;
		case 60: goto st60;
		case 61: goto st61;
		case 1137: goto st1137;
		case 62: goto st62;
		case 63: goto st63;
		case 64: goto st64;
		case 65: goto st65;
		case 66: goto st66;
		case 67: goto st67;
		case 68: goto st68;
		case 69: goto st69;
		case 70: goto st70;
		case 1138: goto st1138;
		case 71: goto st71;
		case 72: goto st72;
		case 73: goto st73;
		case 1139: goto st1139;
		case 74: goto st74;
		case 75: goto st75;
		case 76: goto st76;
		case 1140: goto st1140;
		case 1141: goto st1141;
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
		case 1142: goto st1142;
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
		case 1143: goto st1143;
		case 1144: goto st1144;
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
		case 1145: goto st1145;
		case 146: goto st146;
		case 147: goto st147;
		case 148: goto st148;
		case 149: goto st149;
		case 150: goto st150;
		case 151: goto st151;
		case 152: goto st152;
		case 153: goto st153;
		case 154: goto st154;
		case 1146: goto st1146;
		case 1147: goto st1147;
		case 1148: goto st1148;
		case 155: goto st155;
		case 156: goto st156;
		case 157: goto st157;
		case 1149: goto st1149;
		case 1150: goto st1150;
		case 1151: goto st1151;
		case 158: goto st158;
		case 159: goto st159;
		case 1152: goto st1152;
		case 160: goto st160;
		case 161: goto st161;
		case 1153: goto st1153;
		case 162: goto st162;
		case 163: goto st163;
		case 164: goto st164;
		case 165: goto st165;
		case 166: goto st166;
		case 1154: goto st1154;
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
		case 1155: goto st1155;
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
		case 1156: goto st1156;
		case 1157: goto st1157;
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
		case 1158: goto st1158;
		case 226: goto st226;
		case 227: goto st227;
		case 228: goto st228;
		case 229: goto st229;
		case 230: goto st230;
		case 231: goto st231;
		case 1159: goto st1159;
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
		case 1160: goto st1160;
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
		case 1161: goto st1161;
		case 1162: goto st1162;
		case 306: goto st306;
		case 307: goto st307;
		case 308: goto st308;
		case 1163: goto st1163;
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
		case 1164: goto st1164;
		case 320: goto st320;
		case 321: goto st321;
		case 322: goto st322;
		case 323: goto st323;
		case 324: goto st324;
		case 325: goto st325;
		case 326: goto st326;
		case 327: goto st327;
		case 328: goto st328;
		case 329: goto st329;
		case 330: goto st330;
		case 331: goto st331;
		case 332: goto st332;
		case 1165: goto st1165;
		case 333: goto st333;
		case 334: goto st334;
		case 335: goto st335;
		case 336: goto st336;
		case 337: goto st337;
		case 338: goto st338;
		case 339: goto st339;
		case 340: goto st340;
		case 341: goto st341;
		case 342: goto st342;
		case 343: goto st343;
		case 344: goto st344;
		case 345: goto st345;
		case 346: goto st346;
		case 347: goto st347;
		case 348: goto st348;
		case 349: goto st349;
		case 350: goto st350;
		case 351: goto st351;
		case 352: goto st352;
		case 353: goto st353;
		case 354: goto st354;
		case 1166: goto st1166;
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
		case 1167: goto st1167;
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
		case 1168: goto st1168;
		case 377: goto st377;
		case 378: goto st378;
		case 379: goto st379;
		case 380: goto st380;
		case 381: goto st381;
		case 382: goto st382;
		case 383: goto st383;
		case 384: goto st384;
		case 385: goto st385;
		case 1169: goto st1169;
		case 1170: goto st1170;
		case 386: goto st386;
		case 387: goto st387;
		case 388: goto st388;
		case 389: goto st389;
		case 1171: goto st1171;
		case 1172: goto st1172;
		case 390: goto st390;
		case 391: goto st391;
		case 392: goto st392;
		case 393: goto st393;
		case 394: goto st394;
		case 395: goto st395;
		case 396: goto st396;
		case 397: goto st397;
		case 398: goto st398;
		case 1173: goto st1173;
		case 1174: goto st1174;
		case 399: goto st399;
		case 400: goto st400;
		case 401: goto st401;
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
		case 420: goto st420;
		case 421: goto st421;
		case 422: goto st422;
		case 423: goto st423;
		case 424: goto st424;
		case 425: goto st425;
		case 426: goto st426;
		case 427: goto st427;
		case 428: goto st428;
		case 429: goto st429;
		case 430: goto st430;
		case 431: goto st431;
		case 432: goto st432;
		case 433: goto st433;
		case 434: goto st434;
		case 435: goto st435;
		case 436: goto st436;
		case 437: goto st437;
		case 438: goto st438;
		case 439: goto st439;
		case 440: goto st440;
		case 441: goto st441;
		case 1175: goto st1175;
		case 1176: goto st1176;
		case 442: goto st442;
		case 1177: goto st1177;
		case 1178: goto st1178;
		case 443: goto st443;
		case 444: goto st444;
		case 445: goto st445;
		case 446: goto st446;
		case 447: goto st447;
		case 448: goto st448;
		case 449: goto st449;
		case 450: goto st450;
		case 1179: goto st1179;
		case 1180: goto st1180;
		case 451: goto st451;
		case 1181: goto st1181;
		case 452: goto st452;
		case 453: goto st453;
		case 454: goto st454;
		case 455: goto st455;
		case 456: goto st456;
		case 457: goto st457;
		case 458: goto st458;
		case 459: goto st459;
		case 460: goto st460;
		case 461: goto st461;
		case 462: goto st462;
		case 463: goto st463;
		case 464: goto st464;
		case 465: goto st465;
		case 466: goto st466;
		case 467: goto st467;
		case 468: goto st468;
		case 469: goto st469;
		case 1182: goto st1182;
		case 470: goto st470;
		case 471: goto st471;
		case 472: goto st472;
		case 473: goto st473;
		case 474: goto st474;
		case 475: goto st475;
		case 476: goto st476;
		case 477: goto st477;
		case 478: goto st478;
		case 0: goto st0;
		case 1183: goto st1183;
		case 1184: goto st1184;
		case 1185: goto st1185;
		case 1186: goto st1186;
		case 1187: goto st1187;
		case 479: goto st479;
		case 480: goto st480;
		case 1188: goto st1188;
		case 1189: goto st1189;
		case 1190: goto st1190;
		case 1191: goto st1191;
		case 1192: goto st1192;
		case 1193: goto st1193;
		case 481: goto st481;
		case 482: goto st482;
		case 1194: goto st1194;
		case 1195: goto st1195;
		case 1196: goto st1196;
		case 1197: goto st1197;
		case 1198: goto st1198;
		case 1199: goto st1199;
		case 483: goto st483;
		case 484: goto st484;
		case 1200: goto st1200;
		case 1201: goto st1201;
		case 1202: goto st1202;
		case 1203: goto st1203;
		case 1204: goto st1204;
		case 1205: goto st1205;
		case 1206: goto st1206;
		case 1207: goto st1207;
		case 485: goto st485;
		case 486: goto st486;
		case 1208: goto st1208;
		case 1209: goto st1209;
		case 1210: goto st1210;
		case 1211: goto st1211;
		case 487: goto st487;
		case 488: goto st488;
		case 1212: goto st1212;
		case 1213: goto st1213;
		case 1214: goto st1214;
		case 489: goto st489;
		case 490: goto st490;
		case 1215: goto st1215;
		case 1216: goto st1216;
		case 1217: goto st1217;
		case 1218: goto st1218;
		case 1219: goto st1219;
		case 1220: goto st1220;
		case 1221: goto st1221;
		case 1222: goto st1222;
		case 491: goto st491;
		case 492: goto st492;
		case 1223: goto st1223;
		case 1224: goto st1224;
		case 1225: goto st1225;
		case 493: goto st493;
		case 494: goto st494;
		case 1226: goto st1226;
		case 1227: goto st1227;
		case 1228: goto st1228;
		case 1229: goto st1229;
		case 1230: goto st1230;
		case 1231: goto st1231;
		case 1232: goto st1232;
		case 1233: goto st1233;
		case 1234: goto st1234;
		case 1235: goto st1235;
		case 1236: goto st1236;
		case 495: goto st495;
		case 496: goto st496;
		case 1237: goto st1237;
		case 1238: goto st1238;
		case 1239: goto st1239;
		case 1240: goto st1240;
		case 1241: goto st1241;
		case 497: goto st497;
		case 498: goto st498;
		case 1242: goto st1242;
		case 499: goto st499;
		case 1243: goto st1243;
		case 1244: goto st1244;
		case 1245: goto st1245;
		case 1246: goto st1246;
		case 1247: goto st1247;
		case 1248: goto st1248;
		case 1249: goto st1249;
		case 1250: goto st1250;
		case 1251: goto st1251;
		case 500: goto st500;
		case 501: goto st501;
		case 1252: goto st1252;
		case 1253: goto st1253;
		case 1254: goto st1254;
		case 1255: goto st1255;
		case 1256: goto st1256;
		case 1257: goto st1257;
		case 1258: goto st1258;
		case 1259: goto st1259;
		case 502: goto st502;
		case 503: goto st503;
		case 1260: goto st1260;
		case 1261: goto st1261;
		case 1262: goto st1262;
		case 1263: goto st1263;
		case 504: goto st504;
		case 505: goto st505;
		case 1264: goto st1264;
		case 1265: goto st1265;
		case 1266: goto st1266;
		case 1267: goto st1267;
		case 1268: goto st1268;
		case 506: goto st506;
		case 507: goto st507;
		case 1269: goto st1269;
		case 1270: goto st1270;
		case 1271: goto st1271;
		case 1272: goto st1272;
		case 1273: goto st1273;
		case 1274: goto st1274;
		case 1275: goto st1275;
		case 1276: goto st1276;
		case 1277: goto st1277;
		case 508: goto st508;
		case 509: goto st509;
		case 1278: goto st1278;
		case 1279: goto st1279;
		case 1280: goto st1280;
		case 1281: goto st1281;
		case 1282: goto st1282;
		case 510: goto st510;
		case 511: goto st511;
		case 512: goto st512;
		case 513: goto st513;
		case 514: goto st514;
		case 515: goto st515;
		case 516: goto st516;
		case 517: goto st517;
		case 518: goto st518;
		case 1283: goto st1283;
		case 519: goto st519;
		case 520: goto st520;
		case 521: goto st521;
		case 522: goto st522;
		case 523: goto st523;
		case 524: goto st524;
		case 525: goto st525;
		case 526: goto st526;
		case 527: goto st527;
		case 528: goto st528;
		case 1284: goto st1284;
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
		case 1285: goto st1285;
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
		case 1286: goto st1286;
		case 553: goto st553;
		case 554: goto st554;
		case 555: goto st555;
		case 556: goto st556;
		case 557: goto st557;
		case 558: goto st558;
		case 559: goto st559;
		case 560: goto st560;
		case 561: goto st561;
		case 562: goto st562;
		case 1287: goto st1287;
		case 1288: goto st1288;
		case 1289: goto st1289;
		case 1290: goto st1290;
		case 1291: goto st1291;
		case 1292: goto st1292;
		case 1293: goto st1293;
		case 1294: goto st1294;
		case 1295: goto st1295;
		case 1296: goto st1296;
		case 1297: goto st1297;
		case 1298: goto st1298;
		case 1299: goto st1299;
		case 563: goto st563;
		case 564: goto st564;
		case 1300: goto st1300;
		case 1301: goto st1301;
		case 1302: goto st1302;
		case 1303: goto st1303;
		case 1304: goto st1304;
		case 565: goto st565;
		case 566: goto st566;
		case 1305: goto st1305;
		case 1306: goto st1306;
		case 1307: goto st1307;
		case 1308: goto st1308;
		case 567: goto st567;
		case 568: goto st568;
		case 569: goto st569;
		case 570: goto st570;
		case 571: goto st571;
		case 572: goto st572;
		case 573: goto st573;
		case 574: goto st574;
		case 575: goto st575;
		case 1309: goto st1309;
		case 1310: goto st1310;
		case 1311: goto st1311;
		case 1312: goto st1312;
		case 1313: goto st1313;
		case 1314: goto st1314;
		case 1315: goto st1315;
		case 576: goto st576;
		case 577: goto st577;
		case 1316: goto st1316;
		case 1317: goto st1317;
		case 1318: goto st1318;
		case 1319: goto st1319;
		case 1320: goto st1320;
		case 1321: goto st1321;
		case 578: goto st578;
		case 579: goto st579;
		case 1322: goto st1322;
		case 1323: goto st1323;
		case 1324: goto st1324;
		case 1325: goto st1325;
		case 580: goto st580;
		case 581: goto st581;
		case 1326: goto st1326;
		case 1327: goto st1327;
		case 1328: goto st1328;
		case 1329: goto st1329;
		case 1330: goto st1330;
		case 1331: goto st1331;
		case 582: goto st582;
		case 583: goto st583;
		case 1332: goto st1332;
		case 1333: goto st1333;
		case 1334: goto st1334;
		case 1335: goto st1335;
		case 1336: goto st1336;
		case 584: goto st584;
		case 585: goto st585;
		case 1337: goto st1337;
		case 586: goto st586;
		case 587: goto st587;
		case 1338: goto st1338;
		case 1339: goto st1339;
		case 1340: goto st1340;
		case 1341: goto st1341;
		case 588: goto st588;
		case 589: goto st589;
		case 1342: goto st1342;
		case 1343: goto st1343;
		case 1344: goto st1344;
		case 590: goto st590;
		case 591: goto st591;
		case 1345: goto st1345;
		case 1346: goto st1346;
		case 1347: goto st1347;
		case 1348: goto st1348;
		case 592: goto st592;
		case 593: goto st593;
		case 1349: goto st1349;
		case 1350: goto st1350;
		case 1351: goto st1351;
		case 1352: goto st1352;
		case 1353: goto st1353;
		case 1354: goto st1354;
		case 1355: goto st1355;
		case 1356: goto st1356;
		case 594: goto st594;
		case 595: goto st595;
		case 1357: goto st1357;
		case 1358: goto st1358;
		case 1359: goto st1359;
		case 1360: goto st1360;
		case 1361: goto st1361;
		case 596: goto st596;
		case 597: goto st597;
		case 1362: goto st1362;
		case 1363: goto st1363;
		case 1364: goto st1364;
		case 1365: goto st1365;
		case 1366: goto st1366;
		case 1367: goto st1367;
		case 598: goto st598;
		case 599: goto st599;
		case 1368: goto st1368;
		case 600: goto st600;
		case 601: goto st601;
		case 1369: goto st1369;
		case 1370: goto st1370;
		case 1371: goto st1371;
		case 1372: goto st1372;
		case 1373: goto st1373;
		case 1374: goto st1374;
		case 1375: goto st1375;
		case 602: goto st602;
		case 603: goto st603;
		case 1376: goto st1376;
		case 1377: goto st1377;
		case 1378: goto st1378;
		case 1379: goto st1379;
		case 1380: goto st1380;
		case 604: goto st604;
		case 605: goto st605;
		case 1381: goto st1381;
		case 1382: goto st1382;
		case 1383: goto st1383;
		case 1384: goto st1384;
		case 1385: goto st1385;
		case 606: goto st606;
		case 607: goto st607;
		case 1386: goto st1386;
		case 1387: goto st1387;
		case 1388: goto st1388;
		case 1389: goto st1389;
		case 1390: goto st1390;
		case 1391: goto st1391;
		case 1392: goto st1392;
		case 1393: goto st1393;
		case 608: goto st608;
		case 609: goto st609;
		case 1394: goto st1394;
		case 1395: goto st1395;
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
		case 1396: goto st1396;
		case 623: goto st623;
		case 624: goto st624;
		case 1397: goto st1397;
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
		case 1398: goto st1398;
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
		case 667: goto st667;
		case 668: goto st668;
		case 669: goto st669;
		case 670: goto st670;
		case 671: goto st671;
		case 672: goto st672;
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
		case 715: goto st715;
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
		case 734: goto st734;
		case 735: goto st735;
		case 736: goto st736;
		case 737: goto st737;
		case 1399: goto st1399;
		case 1400: goto st1400;
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
		case 1401: goto st1401;
		case 831: goto st831;
		case 832: goto st832;
		case 1402: goto st1402;
		case 833: goto st833;
		case 834: goto st834;
		case 835: goto st835;
		case 836: goto st836;
		case 1403: goto st1403;
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
		case 1404: goto st1404;
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
		case 1405: goto st1405;
		case 1406: goto st1406;
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
		case 1407: goto st1407;
		case 879: goto st879;
		case 1408: goto st1408;
		case 1409: goto st1409;
		case 1410: goto st1410;
		case 1411: goto st1411;
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
		case 1412: goto st1412;
		case 898: goto st898;
		case 1413: goto st1413;
		case 1414: goto st1414;
		case 1415: goto st1415;
		case 1416: goto st1416;
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
		case 959: goto st959;
		case 960: goto st960;
		case 961: goto st961;
		case 962: goto st962;
		case 963: goto st963;
		case 964: goto st964;
		case 965: goto st965;
		case 966: goto st966;
		case 967: goto st967;
		case 968: goto st968;
		case 969: goto st969;
		case 970: goto st970;
		case 971: goto st971;
		case 972: goto st972;
		case 973: goto st973;
		case 974: goto st974;
		case 975: goto st975;
		case 976: goto st976;
		case 977: goto st977;
		case 978: goto st978;
		case 979: goto st979;
		case 980: goto st980;
		case 981: goto st981;
		case 982: goto st982;
		case 983: goto st983;
		case 984: goto st984;
		case 985: goto st985;
		case 986: goto st986;
		case 987: goto st987;
		case 988: goto st988;
		case 989: goto st989;
		case 990: goto st990;
		case 991: goto st991;
		case 992: goto st992;
		case 993: goto st993;
		case 994: goto st994;
		case 995: goto st995;
		case 996: goto st996;
		case 997: goto st997;
		case 998: goto st998;
		case 999: goto st999;
		case 1000: goto st1000;
		case 1001: goto st1001;
		case 1002: goto st1002;
		case 1003: goto st1003;
		case 1004: goto st1004;
		case 1005: goto st1005;
		case 1006: goto st1006;
		case 1007: goto st1007;
		case 1008: goto st1008;
		case 1009: goto st1009;
		case 1010: goto st1010;
		case 1417: goto st1417;
		case 1011: goto st1011;
		case 1012: goto st1012;
		case 1013: goto st1013;
		case 1014: goto st1014;
		case 1015: goto st1015;
		case 1016: goto st1016;
		case 1017: goto st1017;
		case 1018: goto st1018;
		case 1019: goto st1019;
		case 1020: goto st1020;
		case 1021: goto st1021;
		case 1022: goto st1022;
		case 1023: goto st1023;
		case 1024: goto st1024;
		case 1025: goto st1025;
		case 1026: goto st1026;
		case 1027: goto st1027;
		case 1028: goto st1028;
		case 1029: goto st1029;
		case 1030: goto st1030;
		case 1031: goto st1031;
		case 1032: goto st1032;
		case 1033: goto st1033;
		case 1034: goto st1034;
		case 1035: goto st1035;
		case 1036: goto st1036;
		case 1037: goto st1037;
		case 1038: goto st1038;
		case 1039: goto st1039;
		case 1040: goto st1040;
		case 1041: goto st1041;
		case 1042: goto st1042;
		case 1043: goto st1043;
		case 1044: goto st1044;
		case 1045: goto st1045;
		case 1046: goto st1046;
		case 1047: goto st1047;
		case 1048: goto st1048;
		case 1049: goto st1049;
		case 1050: goto st1050;
		case 1051: goto st1051;
		case 1052: goto st1052;
		case 1053: goto st1053;
		case 1054: goto st1054;
		case 1055: goto st1055;
		case 1056: goto st1056;
		case 1057: goto st1057;
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
		case 1069: goto st1069;
		case 1070: goto st1070;
		case 1071: goto st1071;
		case 1072: goto st1072;
		case 1073: goto st1073;
		case 1074: goto st1074;
		case 1075: goto st1075;
		case 1076: goto st1076;
		case 1077: goto st1077;
		case 1078: goto st1078;
		case 1079: goto st1079;
		case 1080: goto st1080;
		case 1081: goto st1081;
		case 1082: goto st1082;
		case 1083: goto st1083;
		case 1084: goto st1084;
		case 1085: goto st1085;
		case 1086: goto st1086;
		case 1087: goto st1087;
		case 1088: goto st1088;
		case 1089: goto st1089;
		case 1090: goto st1090;
		case 1091: goto st1091;
		case 1092: goto st1092;
		case 1093: goto st1093;
		case 1094: goto st1094;
		case 1095: goto st1095;
		case 1096: goto st1096;
		case 1097: goto st1097;
		case 1098: goto st1098;
		case 1099: goto st1099;
		case 1100: goto st1100;
		case 1101: goto st1101;
		case 1102: goto st1102;
		case 1103: goto st1103;
		case 1104: goto st1104;
		case 1105: goto st1105;
		case 1106: goto st1106;
		case 1107: goto st1107;
		case 1108: goto st1108;
		case 1109: goto st1109;
		case 1110: goto st1110;
		case 1111: goto st1111;
		case 1112: goto st1112;
		case 1113: goto st1113;
		case 1114: goto st1114;
		case 1115: goto st1115;
		case 1116: goto st1116;
		case 1117: goto st1117;
		case 1118: goto st1118;
		case 1119: goto st1119;
		case 1120: goto st1120;
		case 1121: goto st1121;
		case 1122: goto st1122;
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
    append_block(sm, "<hr>");
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
{( (sm->stack.data()))[( sm->top)++] = 1123;goto st1146;}}
  }
	break;
	default:
	{{( sm->p) = ((( sm->te)))-1;}}
	break;
	}
	}
	goto st1123;
tr4:
#line 729 "ext/dtext/dtext.cpp.rl"
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
{( (sm->stack.data()))[( sm->top)++] = 1123;goto st1146;}}
  }}
	goto st1123;
tr19:
#line 683 "ext/dtext/dtext.cpp.rl"
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
{( (sm->stack.data()))[( sm->top)++] = 1123;goto st1415;}}
  }}
	goto st1123;
tr50:
#line 653 "ext/dtext/dtext.cpp.rl"
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
{( (sm->stack.data()))[( sm->top)++] = 1123;goto st1405;}}
  }}
	goto st1123;
tr51:
#line 653 "ext/dtext/dtext.cpp.rl"
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
{( (sm->stack.data()))[( sm->top)++] = 1123;goto st1405;}}
  }}
	goto st1123;
tr54:
#line 648 "ext/dtext/dtext.cpp.rl"
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
{( (sm->stack.data()))[( sm->top)++] = 1123;goto st1405;}}
  }}
	goto st1123;
tr55:
#line 648 "ext/dtext/dtext.cpp.rl"
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
{( (sm->stack.data()))[( sm->top)++] = 1123;goto st1405;}}
  }}
	goto st1123;
tr79:
#line 677 "ext/dtext/dtext.cpp.rl"
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
{( (sm->stack.data()))[( sm->top)++] = 1123;goto st1410;}}
  }}
	goto st1123;
tr80:
#line 677 "ext/dtext/dtext.cpp.rl"
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
{( (sm->stack.data()))[( sm->top)++] = 1123;goto st1410;}}
  }}
	goto st1123;
tr92:
#line 689 "ext/dtext/dtext.cpp.rl"
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
{( (sm->stack.data()))[( sm->top)++] = 1123;goto st1146;}}
  }}
	goto st1123;
tr148:
#line 658 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{
    append_code_fence(sm, { sm->b1, sm->b2 }, { sm->a1, sm->a2 });
  }}
	goto st1123;
tr1440:
#line 729 "ext/dtext/dtext.cpp.rl"
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
{( (sm->stack.data()))[( sm->top)++] = 1123;goto st1146;}}
  }}
	goto st1123;
tr1450:
#line 729 "ext/dtext/dtext.cpp.rl"
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
{( (sm->stack.data()))[( sm->top)++] = 1123;goto st1146;}}
  }}
	goto st1123;
tr1451:
#line 694 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    g_debug("write '<hr>' (pos: %ld)", sm->ts - sm->pb);
    append_block(sm, "<hr>");
  }}
	goto st1123;
tr1452:
#line 74 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
#line 699 "ext/dtext/dtext.cpp.rl"
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
{( (sm->stack.data()))[( sm->top)++] = 1123;goto st1146;}}
  }}
	goto st1123;
tr1460:
#line 638 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    dstack_close_leaf_blocks(sm);
    dstack_open_block(sm, BLOCK_QUOTE, "<blockquote>");
  }}
	goto st1123;
tr1461:
#line 653 "ext/dtext/dtext.cpp.rl"
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
{( (sm->stack.data()))[( sm->top)++] = 1123;goto st1405;}}
  }}
	goto st1123;
tr1462:
#line 648 "ext/dtext/dtext.cpp.rl"
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
{( (sm->stack.data()))[( sm->top)++] = 1123;goto st1405;}}
  }}
	goto st1123;
tr1463:
#line 668 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    g_debug("block [expand=]");
    dstack_close_leaf_blocks(sm);
    dstack_open_block(sm, BLOCK_EXPAND, "<details>");
    append_block(sm, "<summary>");
    append_block_html_escaped(sm, { sm->a1, sm->a2 });
    append_block(sm, "</summary><div>");
  }}
	goto st1123;
tr1465:
#line 662 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    dstack_close_leaf_blocks(sm);
    dstack_open_block(sm, BLOCK_EXPAND, "<details>");
    append_block(sm, "<summary>Show</summary><div>");
  }}
	goto st1123;
tr1466:
#line 677 "ext/dtext/dtext.cpp.rl"
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
{( (sm->stack.data()))[( sm->top)++] = 1123;goto st1410;}}
  }}
	goto st1123;
tr1467:
#line 643 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    dstack_close_leaf_blocks(sm);
    dstack_open_block(sm, BLOCK_SPOILER, "<div class=\"spoiler\">");
  }}
	goto st1123;
tr1469:
#line 633 "ext/dtext/dtext.cpp.rl"
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
{( (sm->stack.data()))[( sm->top)++] = 1123;goto st1146;}}
  }}
	goto st1123;
st1123:
#line 1 "NONE"
	{( sm->ts) = 0;}
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1123;
case 1123:
#line 1 "NONE"
	{( sm->ts) = ( sm->p);}
#line 2653 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr1441;
		case 9: goto tr1442;
		case 10: goto tr1443;
		case 13: goto st1127;
		case 32: goto tr1442;
		case 42: goto tr1445;
		case 60: goto tr1446;
		case 72: goto tr1447;
		case 91: goto tr1448;
		case 96: goto tr1449;
		case 104: goto tr1447;
	}
	goto tr1440;
tr1:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 706 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 124;}
	goto st1124;
tr1441:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 727 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 126;}
	goto st1124;
tr1443:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 723 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 125;}
	goto st1124;
st1124:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1124;
case 1124:
#line 2690 "ext/dtext/dtext.cpp"
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
tr1442:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 729 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 127;}
	goto st1125;
st1125:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1125;
case 1125:
#line 2728 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto st1;
		case 9: goto st3;
		case 10: goto st1;
		case 13: goto st4;
		case 32: goto st3;
		case 60: goto st5;
		case 91: goto st15;
	}
	goto tr1450;
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
#line 694 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 122;}
	goto st1126;
st1126:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1126;
case 1126:
#line 2809 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr13;
		case 10: goto tr13;
		case 13: goto st9;
	}
	goto tr1451;
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
st1127:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1127;
case 1127:
	if ( (*( sm->p)) == 10 )
		goto tr1443;
	goto tr1450;
tr1445:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st1128;
st1128:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1128;
case 1128:
#line 2953 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto tr29;
		case 32: goto tr29;
		case 42: goto st24;
	}
	goto tr1450;
tr29:
#line 72 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
	goto st23;
st23:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof23;
case 23:
#line 2968 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr4;
		case 9: goto tr28;
		case 10: goto tr4;
		case 13: goto tr4;
		case 32: goto tr28;
	}
	goto tr27;
tr27:
#line 73 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st1129;
st1129:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1129;
case 1129:
#line 2985 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr1452;
		case 10: goto tr1452;
		case 13: goto tr1452;
	}
	goto st1129;
tr28:
#line 73 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st1130;
st1130:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1130;
case 1130:
#line 3000 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr1452;
		case 9: goto tr28;
		case 10: goto tr1452;
		case 13: goto tr1452;
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
tr1446:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 729 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 127;}
	goto st1131;
st1131:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1131;
case 1131:
#line 3029 "ext/dtext/dtext.cpp"
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
	goto tr1450;
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
		goto st1132;
	goto tr4;
st1132:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1132;
case 1132:
	if ( (*( sm->p)) == 32 )
		goto st1132;
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto st1132;
	goto tr1460;
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
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st41;
st41:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof41;
case 41:
#line 3219 "ext/dtext/dtext.cpp"
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
#line 72 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
	goto st1133;
st1133:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1133;
case 1133:
#line 3241 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr51;
		case 9: goto st42;
		case 10: goto tr51;
		case 13: goto st43;
		case 32: goto st42;
	}
	goto tr1461;
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
	goto st1134;
st1134:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1134;
case 1134:
#line 3277 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr55;
		case 9: goto st44;
		case 10: goto tr55;
		case 13: goto st45;
		case 32: goto st44;
	}
	goto tr1462;
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
		case 62: goto st1136;
	}
	goto tr4;
tr67:
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st52;
st52:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof52;
case 52:
#line 3369 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr4;
		case 9: goto tr67;
		case 10: goto tr4;
		case 13: goto tr4;
		case 32: goto tr67;
		case 61: goto tr68;
		case 62: goto tr69;
	}
	goto tr66;
tr66:
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st53;
st53:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof53;
case 53:
#line 3388 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr4;
		case 10: goto tr4;
		case 13: goto tr4;
		case 62: goto tr71;
	}
	goto st53;
tr71:
#line 72 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
	goto st1135;
tr69:
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
#line 72 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
	goto st1135;
st1135:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1135;
case 1135:
#line 3410 "ext/dtext/dtext.cpp"
	if ( (*( sm->p)) == 32 )
		goto st1135;
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto st1135;
	goto tr1463;
tr68:
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st54;
st54:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof54;
case 54:
#line 3424 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr4;
		case 9: goto tr68;
		case 10: goto tr4;
		case 13: goto tr4;
		case 32: goto tr68;
		case 62: goto tr69;
	}
	goto tr66;
st1136:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1136;
case 1136:
	if ( (*( sm->p)) == 32 )
		goto st1136;
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto st1136;
	goto tr1465;
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
	goto st1137;
st1137:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1137;
case 1137:
#line 3512 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr80;
		case 9: goto st62;
		case 10: goto tr80;
		case 13: goto st63;
		case 32: goto st62;
	}
	goto tr1466;
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
		case 62: goto st1138;
		case 83: goto st71;
		case 115: goto st71;
	}
	goto tr4;
st1138:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1138;
case 1138:
	if ( (*( sm->p)) == 32 )
		goto st1138;
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto st1138;
	goto tr1467;
st71:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof71;
case 71:
	if ( (*( sm->p)) == 62 )
		goto st1138;
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
tr1447:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
	goto st1139;
st1139:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1139;
case 1139:
#line 3646 "ext/dtext/dtext.cpp"
	if ( 49 <= (*( sm->p)) && (*( sm->p)) <= 54 )
		goto tr1468;
	goto tr1450;
tr1468:
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st74;
st74:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof74;
case 74:
#line 3658 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 35: goto tr93;
		case 46: goto tr94;
	}
	goto tr4;
tr93:
#line 72 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
	goto st75;
st75:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof75;
case 75:
#line 3672 "ext/dtext/dtext.cpp"
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
#line 73 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st76;
st76:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof76;
case 76:
#line 3697 "ext/dtext/dtext.cpp"
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
#line 72 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
#line 73 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
#line 74 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
	goto st1140;
tr97:
#line 74 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
	goto st1140;
st1140:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1140;
case 1140:
#line 3730 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto st1140;
		case 32: goto st1140;
	}
	goto tr1469;
tr1448:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 729 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 127;}
	goto st1141;
st1141:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1141;
case 1141:
#line 3746 "ext/dtext/dtext.cpp"
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
	goto tr1450;
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
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st83;
st83:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof83;
case 83:
#line 3837 "ext/dtext/dtext.cpp"
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
		case 93: goto st1136;
	}
	goto tr4;
tr113:
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st90;
st90:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof90;
case 90:
#line 3913 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr4;
		case 9: goto tr113;
		case 10: goto tr4;
		case 13: goto tr4;
		case 32: goto tr113;
		case 61: goto tr114;
		case 93: goto tr69;
	}
	goto tr112;
tr112:
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st91;
st91:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof91;
case 91:
#line 3932 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr4;
		case 10: goto tr4;
		case 13: goto tr4;
		case 93: goto tr71;
	}
	goto st91;
tr114:
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st92;
st92:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof92;
case 92:
#line 3948 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr4;
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
		goto st1132;
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
		case 93: goto st1138;
		case 115: goto st112;
	}
	goto tr4;
st112:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof112;
case 112:
	if ( (*( sm->p)) == 93 )
		goto st1138;
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
tr1449:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
	goto st1142;
st1142:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1142;
case 1142:
#line 4159 "ext/dtext/dtext.cpp"
	if ( (*( sm->p)) == 96 )
		goto st115;
	goto tr1450;
st115:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof115;
case 115:
	if ( (*( sm->p)) == 96 )
		goto st116;
	goto tr4;
tr136:
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
#line 72 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
	goto st116;
st116:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof116;
case 116:
#line 4180 "ext/dtext/dtext.cpp"
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
#line 72 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
	goto st117;
tr135:
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
#line 72 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
	goto st117;
st117:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof117;
case 117:
#line 4211 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr140;
		case 10: goto tr140;
		case 13: goto tr141;
	}
	goto tr139;
tr139:
#line 73 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st118;
tr144:
#line 74 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
	goto st118;
tr141:
#line 73 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
#line 74 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
	goto st118;
st118:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof118;
case 118:
#line 4236 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr143;
		case 10: goto tr143;
		case 13: goto tr144;
	}
	goto st118;
tr143:
#line 74 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
	goto st119;
tr140:
#line 73 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
#line 74 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
	goto st119;
st119:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof119;
case 119:
#line 4257 "ext/dtext/dtext.cpp"
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
#line 74 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
	goto st123;
st123:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof123;
case 123:
#line 4307 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr143;
		case 10: goto tr148;
		case 13: goto tr144;
	}
	goto st118;
tr153:
#line 72 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
	goto st124;
tr137:
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
#line 72 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
	goto st124;
st124:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof124;
case 124:
#line 4328 "ext/dtext/dtext.cpp"
	if ( (*( sm->p)) == 10 )
		goto st117;
	goto tr4;
tr138:
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st125;
st125:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof125;
case 125:
#line 4340 "ext/dtext/dtext.cpp"
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
#line 72 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
	goto st126;
st126:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof126;
case 126:
#line 4365 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto st117;
		case 9: goto st126;
		case 10: goto st117;
		case 13: goto st124;
		case 32: goto st126;
	}
	goto tr4;
tr157:
#line 283 "ext/dtext/dtext.cpp.rl"
	{{( sm->p) = ((( sm->te)))-1;}{ append_html_escaped(sm, (*( sm->p))); }}
	goto st1143;
tr163:
#line 275 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{ dstack_close_inline(sm, INLINE_B, "</strong>"); }}
	goto st1143;
tr164:
#line 277 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{ dstack_close_inline(sm, INLINE_I, "</em>"); }}
	goto st1143;
tr165:
#line 279 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{ dstack_close_inline(sm, INLINE_S, "</s>"); }}
	goto st1143;
tr170:
#line 281 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{ dstack_close_inline(sm, INLINE_U, "</u>"); }}
	goto st1143;
tr171:
#line 274 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{ dstack_open_inline(sm,  INLINE_B, "<strong>"); }}
	goto st1143;
tr173:
#line 276 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{ dstack_open_inline(sm,  INLINE_I, "<em>"); }}
	goto st1143;
tr174:
#line 278 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{ dstack_open_inline(sm,  INLINE_S, "<s>"); }}
	goto st1143;
tr180:
#line 280 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{ dstack_open_inline(sm,  INLINE_U, "<u>"); }}
	goto st1143;
tr1478:
#line 283 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{ append_html_escaped(sm, (*( sm->p))); }}
	goto st1143;
tr1479:
#line 282 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;}
	goto st1143;
tr1482:
#line 283 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{ append_html_escaped(sm, (*( sm->p))); }}
	goto st1143;
st1143:
#line 1 "NONE"
	{( sm->ts) = 0;}
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1143;
case 1143:
#line 1 "NONE"
	{( sm->ts) = ( sm->p);}
#line 4430 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr1479;
		case 60: goto tr1480;
		case 91: goto tr1481;
	}
	goto tr1478;
tr1480:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
	goto st1144;
st1144:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1144;
case 1144:
#line 4445 "ext/dtext/dtext.cpp"
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
	goto tr1482;
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
tr1481:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
	goto st1145;
st1145:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1145;
case 1145:
#line 4637 "ext/dtext/dtext.cpp"
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
	goto tr1482;
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
	case 51:
	{{( sm->p) = ((( sm->te)))-1;}
    append_bare_named_url(sm, { sm->b1, sm->b2 + 1 }, { sm->a1, sm->a2 });
  }
	break;
	case 54:
	{{( sm->p) = ((( sm->te)))-1;}
    append_bare_unnamed_url(sm, { sm->ts, sm->te });
  }
	break;
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
	goto st1146;
tr188:
#line 540 "ext/dtext/dtext.cpp.rl"
	{{( sm->p) = ((( sm->te)))-1;}{
    append(sm, std::string_view { sm->ts, sm->te });
  }}
	goto st1146;
tr193:
#line 544 "ext/dtext/dtext.cpp.rl"
	{{( sm->p) = ((( sm->te)))-1;}{
    append_html_escaped(sm, (*( sm->p)));
  }}
	goto st1146;
tr196:
#line 519 "ext/dtext/dtext.cpp.rl"
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
	goto st1146;
tr215:
#line 418 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_close_leaf_blocks(sm);
    {( sm->p) = (( sm->ts))-1;}
    { sm->cs = ( (sm->stack.data()))[--( sm->top)];goto _again;}
  }}
	goto st1146;
tr221:
#line 485 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_close_leaf_blocks(sm);
    {( sm->p) = (( sm->ts))-1;}
    { sm->cs = ( (sm->stack.data()))[--( sm->top)];goto _again;}
  }}
	goto st1146;
tr238:
#line 510 "ext/dtext/dtext.cpp.rl"
	{{( sm->p) = ((( sm->te)))-1;}{
    g_debug("inline newline2");
    g_debug("  return");

    dstack_close_list(sm);
    {( sm->p) = (( sm->ts))-1;}
    { sm->cs = ( (sm->stack.data()))[--( sm->top)];goto _again;}
  }}
	goto st1146;
tr244:
#line 497 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{
    if (dstack_close_block(sm, BLOCK_TD, "</td>")) {
      { sm->cs = ( (sm->stack.data()))[--( sm->top)];goto _again;}
    }
  }}
	goto st1146;
tr245:
#line 491 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{
    if (dstack_close_block(sm, BLOCK_TH, "</th>")) {
      { sm->cs = ( (sm->stack.data()))[--( sm->top)];goto _again;}
    }
  }}
	goto st1146;
tr246:
#line 392 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{
    g_debug("inline [/tn]");

    if (dstack_check(sm, INLINE_TN)) {
      dstack_close_inline(sm, INLINE_TN, "</span>");
    } else if (dstack_close_block(sm, BLOCK_TN, "</p>")) {
      { sm->cs = ( (sm->stack.data()))[--( sm->top)];goto _again;}
    }
  }}
	goto st1146;
tr289:
#line 428 "ext/dtext/dtext.cpp.rl"
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
	goto st1146;
tr296:
#line 447 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_close_leaf_blocks(sm);
    {( sm->p) = (( sm->ts))-1;}
    { sm->cs = ( (sm->stack.data()))[--( sm->top)];goto _again;}
  }}
	goto st1146;
tr299:
#line 72 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
#line 447 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_close_leaf_blocks(sm);
    {( sm->p) = (( sm->ts))-1;}
    { sm->cs = ( (sm->stack.data()))[--( sm->top)];goto _again;}
  }}
	goto st1146;
tr357:
#line 412 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_close_leaf_blocks(sm);
    {( sm->p) = (( sm->ts))-1;}
    { sm->cs = ( (sm->stack.data()))[--( sm->top)];goto _again;}
  }}
	goto st1146;
tr373:
#line 344 "ext/dtext/dtext.cpp.rl"
	{{( sm->p) = ((( sm->te)))-1;}{
    append_bare_named_url(sm, { sm->b1, sm->b2 + 1 }, { sm->a1, sm->a2 });
  }}
	goto st1146;
tr439:
#line 74 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
#line 348 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{
    append_named_url(sm, { sm->b1, sm->b2 }, { sm->a1, sm->a2 });
  }}
	goto st1146;
tr643:
#line 294 "ext/dtext/dtext.cpp.rl"
	{{( sm->p) = ((( sm->te)))-1;}{ append_id_link(sm, "dmail", "dmail", "/dmails/", { sm->a1, sm->a2 }); }}
	goto st1146;
tr678:
#line 356 "ext/dtext/dtext.cpp.rl"
	{{( sm->p) = ((( sm->te)))-1;}{
    append_bare_unnamed_url(sm, { sm->ts, sm->te });
  }}
	goto st1146;
tr736:
#line 315 "ext/dtext/dtext.cpp.rl"
	{{( sm->p) = ((( sm->te)))-1;}{ append_id_link(sm, "pixiv", "pixiv", "https://www.pixiv.net/artworks/", { sm->a1, sm->a2 }); }}
	goto st1146;
tr751:
#line 292 "ext/dtext/dtext.cpp.rl"
	{{( sm->p) = ((( sm->te)))-1;}{ append_id_link(sm, "topic", "forum-topic", "/forum_topics/", { sm->a1, sm->a2 }); }}
	goto st1146;
tr766:
#line 380 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{ dstack_close_inline(sm, INLINE_B, "</strong>"); }}
	goto st1146;
tr767:
#line 382 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{ dstack_close_inline(sm, INLINE_I, "</em>"); }}
	goto st1146;
tr768:
#line 384 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{ dstack_close_inline(sm, INLINE_S, "</s>"); }}
	goto st1146;
tr769:
#line 386 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{ dstack_close_inline(sm, INLINE_U, "</u>"); }}
	goto st1146;
tr770:
#line 379 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{ dstack_open_inline(sm,  INLINE_B, "<strong>"); }}
	goto st1146;
tr780:
#line 407 "ext/dtext/dtext.cpp.rl"
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
{( (sm->stack.data()))[( sm->top)++] = 1146;goto st1405;}}
  }}
	goto st1146;
tr781:
#line 407 "ext/dtext/dtext.cpp.rl"
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
{( (sm->stack.data()))[( sm->top)++] = 1146;goto st1405;}}
  }}
	goto st1146;
tr784:
#line 402 "ext/dtext/dtext.cpp.rl"
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
{( (sm->stack.data()))[( sm->top)++] = 1146;goto st1405;}}
  }}
	goto st1146;
tr785:
#line 402 "ext/dtext/dtext.cpp.rl"
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
{( (sm->stack.data()))[( sm->top)++] = 1146;goto st1405;}}
  }}
	goto st1146;
tr795:
#line 472 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{
    g_debug("inline [expand]");
    dstack_close_leaf_blocks(sm);
    {( sm->p) = (( sm->ts))-1;}
    { sm->cs = ( (sm->stack.data()))[--( sm->top)];goto _again;}
  }}
	goto st1146;
tr799:
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
#line 72 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
#line 472 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{
    g_debug("inline [expand]");
    dstack_close_leaf_blocks(sm);
    {( sm->p) = (( sm->ts))-1;}
    { sm->cs = ( (sm->stack.data()))[--( sm->top)];goto _again;}
  }}
	goto st1146;
tr801:
#line 72 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
#line 472 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{
    g_debug("inline [expand]");
    dstack_close_leaf_blocks(sm);
    {( sm->p) = (( sm->ts))-1;}
    { sm->cs = ( (sm->stack.data()))[--( sm->top)];goto _again;}
  }}
	goto st1146;
tr814:
#line 74 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
#line 352 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{
    append_named_url(sm, { sm->a1, sm->a2 }, { sm->b1, sm->b2 });
  }}
	goto st1146;
tr815:
#line 381 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{ dstack_open_inline(sm,  INLINE_I, "<em>"); }}
	goto st1146;
tr823:
#line 439 "ext/dtext/dtext.cpp.rl"
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
{( (sm->stack.data()))[( sm->top)++] = 1146;goto st1410;}}
  }}
	goto st1146;
tr824:
#line 439 "ext/dtext/dtext.cpp.rl"
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
{( (sm->stack.data()))[( sm->top)++] = 1146;goto st1410;}}
  }}
	goto st1146;
tr831:
#line 459 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{
    g_debug("inline [quote]");
    dstack_close_leaf_blocks(sm);
    {( sm->p) = (( sm->ts))-1;}
    { sm->cs = ( (sm->stack.data()))[--( sm->top)];goto _again;}
  }}
	goto st1146;
tr833:
#line 383 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{ dstack_open_inline(sm,  INLINE_S, "<s>"); }}
	goto st1146;
tr840:
#line 424 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_open_inline(sm, INLINE_SPOILER, "<span class=\"spoiler\">");
  }}
	goto st1146;
tr842:
#line 388 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_open_inline(sm, INLINE_TN, "<span class=\"tn\">");
  }}
	goto st1146;
tr844:
#line 385 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{ dstack_open_inline(sm,  INLINE_U, "<u>"); }}
	goto st1146;
tr870:
#line 348 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{
    append_named_url(sm, { sm->b1, sm->b2 }, { sm->a1, sm->a2 });
  }}
	goto st1146;
tr908:
#line 360 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{
    append_unnamed_url(sm, { sm->a1, sm->a2 });
  }}
	goto st1146;
tr947:
#line 352 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{
    append_named_url(sm, { sm->a1, sm->a2 }, { sm->b1, sm->b2 });
  }}
	goto st1146;
tr991:
#line 72 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
#line 360 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{
    append_unnamed_url(sm, { sm->a1, sm->a2 });
  }}
	goto st1146;
tr1013:
#line 72 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
#line 368 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{
    g_debug("delimited mention: <@%.*s>", (int)(sm->a2 - sm->a1), sm->a1);
    append_mention(sm, { sm->a1, sm->a2 });
  }}
	goto st1146;
tr1492:
#line 544 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{
    append_html_escaped(sm, (*( sm->p)));
  }}
	goto st1146;
tr1524:
#line 544 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append_html_escaped(sm, (*( sm->p)));
  }}
	goto st1146;
tr1525:
#line 540 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append(sm, std::string_view { sm->ts, sm->te });
  }}
	goto st1146;
tr1527:
#line 519 "ext/dtext/dtext.cpp.rl"
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
	goto st1146;
tr1534:
#line 503 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    g_debug("inline [hr] (pos: %ld)", sm->ts - sm->pb);
    dstack_close_leaf_blocks(sm);
    {( sm->p) = (( sm->ts))-1;}
    { sm->cs = ( (sm->stack.data()))[--( sm->top)];goto _again;}
  }}
	goto st1146;
tr1535:
#line 510 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    g_debug("inline newline2");
    g_debug("  return");

    dstack_close_list(sm);
    {( sm->p) = (( sm->ts))-1;}
    { sm->cs = ( (sm->stack.data()))[--( sm->top)];goto _again;}
  }}
	goto st1146;
tr1538:
#line 74 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
#line 373 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    g_debug("inline list");
    {( sm->p) = (( sm->ts + 1))-1;}
    { sm->cs = ( (sm->stack.data()))[--( sm->top)];goto _again;}
  }}
	goto st1146;
tr1540:
#line 466 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    g_debug("inline [/quote]");
    dstack_close_until(sm, BLOCK_QUOTE);
    { sm->cs = ( (sm->stack.data()))[--( sm->top)];goto _again;}
  }}
	goto st1146;
tr1541:
#line 479 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    g_debug("inline [/expand]");
    dstack_close_until(sm, BLOCK_EXPAND);
    { sm->cs = ( (sm->stack.data()))[--( sm->top)];goto _again;}
  }}
	goto st1146;
tr1542:
#line 453 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    dstack_close_leaf_blocks(sm);
    {( sm->p) = (( sm->ts))-1;}
    { sm->cs = ( (sm->stack.data()))[--( sm->top)];goto _again;}
  }}
	goto st1146;
tr1544:
#line 534 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append(sm, ' ');
  }}
	goto st1146;
tr1546:
#line 344 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append_bare_named_url(sm, { sm->b1, sm->b2 + 1 }, { sm->a1, sm->a2 });
  }}
	goto st1146;
tr1550:
#line 79 "ext/dtext/dtext.cpp.rl"
	{ sm->e1 = sm->p; }
#line 80 "ext/dtext/dtext.cpp.rl"
	{ sm->e2 = sm->p; }
#line 336 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append_wiki_link(sm, { sm->a1, sm->a2 }, { sm->b1, sm->b2 }, { sm->c1, sm->c2 }, { sm->b1, sm->b2 }, { sm->e1, sm->e2 });
  }}
	goto st1146;
tr1552:
#line 80 "ext/dtext/dtext.cpp.rl"
	{ sm->e2 = sm->p; }
#line 336 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append_wiki_link(sm, { sm->a1, sm->a2 }, { sm->b1, sm->b2 }, { sm->c1, sm->c2 }, { sm->b1, sm->b2 }, { sm->e1, sm->e2 });
  }}
	goto st1146;
tr1554:
#line 79 "ext/dtext/dtext.cpp.rl"
	{ sm->e1 = sm->p; }
#line 80 "ext/dtext/dtext.cpp.rl"
	{ sm->e2 = sm->p; }
#line 340 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append_wiki_link(sm, { sm->a1, sm->a2 }, { sm->b1, sm->b2 }, { sm->c1, sm->c2 }, { sm->d1, sm->d2 }, { sm->e1, sm->e2 });
  }}
	goto st1146;
tr1556:
#line 80 "ext/dtext/dtext.cpp.rl"
	{ sm->e2 = sm->p; }
#line 340 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append_wiki_link(sm, { sm->a1, sm->a2 }, { sm->b1, sm->b2 }, { sm->c1, sm->c2 }, { sm->d1, sm->d2 }, { sm->e1, sm->e2 });
  }}
	goto st1146;
tr1560:
#line 77 "ext/dtext/dtext.cpp.rl"
	{ sm->d1 = sm->p; }
#line 78 "ext/dtext/dtext.cpp.rl"
	{ sm->d2 = sm->p; }
#line 332 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append_post_search_link(sm, { sm->a1, sm->a2 }, { sm->b1, sm->b2 }, { sm->c1, sm->c2 }, { sm->d1, sm->d2 });
  }}
	goto st1146;
tr1562:
#line 78 "ext/dtext/dtext.cpp.rl"
	{ sm->d2 = sm->p; }
#line 332 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append_post_search_link(sm, { sm->a1, sm->a2 }, { sm->b1, sm->b2 }, { sm->c1, sm->c2 }, { sm->d1, sm->d2 });
  }}
	goto st1146;
tr1564:
#line 77 "ext/dtext/dtext.cpp.rl"
	{ sm->d1 = sm->p; }
#line 78 "ext/dtext/dtext.cpp.rl"
	{ sm->d2 = sm->p; }
#line 328 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append_post_search_link(sm, { sm->a1, sm->a2 }, { sm->b1, sm->b2 }, { sm->b1, sm->b2 }, { sm->d1, sm->d2 });
  }}
	goto st1146;
tr1566:
#line 78 "ext/dtext/dtext.cpp.rl"
	{ sm->d2 = sm->p; }
#line 328 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append_post_search_link(sm, { sm->a1, sm->a2 }, { sm->b1, sm->b2 }, { sm->b1, sm->b2 }, { sm->d1, sm->d2 });
  }}
	goto st1146;
tr1578:
#line 72 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
#line 300 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{ append_id_link(sm, "alias", "tag-alias", "/tag_aliases/", { sm->a1, sm->a2 }); }}
	goto st1146;
tr1585:
#line 72 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
#line 288 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{ append_id_link(sm, "appeal", "post-appeal", "/post_appeals/", { sm->a1, sm->a2 }); }}
	goto st1146;
tr1593:
#line 72 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
#line 297 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{ append_id_link(sm, "artist", "artist", "/artists/", { sm->a1, sm->a2 }); }}
	goto st1146;
tr1602:
#line 72 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
#line 311 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{ append_id_link(sm, "artstation", "artstation", "https://www.artstation.com/artwork/", { sm->a1, sm->a2 }); }}
	goto st1146;
tr1608:
#line 72 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
#line 298 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{ append_id_link(sm, "ban", "ban", "/bans/", { sm->a1, sm->a2 }); }}
	goto st1146;
tr1612:
#line 72 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
#line 299 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{ append_id_link(sm, "BUR", "bulk-update-request", "/bulk_update_requests/", { sm->a1, sm->a2 }); }}
	goto st1146;
tr1622:
#line 72 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
#line 293 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{ append_id_link(sm, "comment", "comment", "/comments/", { sm->a1, sm->a2 }); }}
	goto st1146;
tr1626:
#line 72 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
#line 310 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{ append_id_link(sm, "commit", "github-commit", "https://github.com/danbooru/danbooru/commit/", { sm->a1, sm->a2 }); }}
	goto st1146;
tr1639:
#line 72 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
#line 312 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{ append_id_link(sm, "deviantart", "deviantart", "https://www.deviantart.com/deviation/", { sm->a1, sm->a2 }); }}
	goto st1146;
tr1645:
#line 72 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
#line 294 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{ append_id_link(sm, "dmail", "dmail", "/dmails/", { sm->a1, sm->a2 }); }}
	goto st1146;
tr1648:
#line 74 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
#line 323 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{ append_dmail_key_link(sm); }}
	goto st1146;
tr1661:
#line 72 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
#line 302 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{ append_id_link(sm, "favgroup", "favorite-group", "/favorite_groups/", { sm->a1, sm->a2 }); }}
	goto st1146;
tr1670:
#line 72 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
#line 305 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{ append_id_link(sm, "feedback", "user-feedback", "/user_feedbacks/", { sm->a1, sm->a2 }); }}
	goto st1146;
tr1675:
#line 72 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
#line 289 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{ append_id_link(sm, "flag", "post-flag", "/post_flags/", { sm->a1, sm->a2 }); }}
	goto st1146;
tr1681:
#line 72 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
#line 291 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{ append_id_link(sm, "forum", "forum-post", "/forum_posts/", { sm->a1, sm->a2 }); }}
	goto st1146;
tr1691:
#line 72 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
#line 321 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{ append_id_link(sm, "gelbooru", "gelbooru", "https://gelbooru.com/index.php?page=post&s=view&id=", { sm->a1, sm->a2 }); }}
	goto st1146;
tr1698:
#line 356 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append_bare_unnamed_url(sm, { sm->ts, sm->te });
  }}
	goto st1146;
tr1711:
#line 72 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
#line 301 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{ append_id_link(sm, "implication", "tag-implication", "/tag_implications/", { sm->a1, sm->a2 }); }}
	goto st1146;
tr1717:
#line 72 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
#line 308 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{ append_id_link(sm, "issue", "github", "https://github.com/danbooru/danbooru/issues/", { sm->a1, sm->a2 }); }}
	goto st1146;
tr1723:
#line 72 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
#line 303 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{ append_id_link(sm, "mod action", "mod-action", "/mod_actions/", { sm->a1, sm->a2 }); }}
	goto st1146;
tr1731:
#line 72 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
#line 304 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{ append_id_link(sm, "modreport", "moderation-report", "/moderation_reports/", { sm->a1, sm->a2 }); }}
	goto st1146;
tr1739:
#line 72 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
#line 313 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{ append_id_link(sm, "nijie", "nijie", "https://nijie.info/view.php?id=", { sm->a1, sm->a2 }); }}
	goto st1146;
tr1744:
#line 72 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
#line 290 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{ append_id_link(sm, "note", "note", "/notes/", { sm->a1, sm->a2 }); }}
	goto st1146;
tr1754:
#line 72 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
#line 314 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{ append_id_link(sm, "pawoo", "pawoo", "https://pawoo.net/web/statuses/", { sm->a1, sm->a2 }); }}
	goto st1146;
tr1760:
#line 72 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
#line 315 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{ append_id_link(sm, "pixiv", "pixiv", "https://www.pixiv.net/artworks/", { sm->a1, sm->a2 }); }}
	goto st1146;
tr1763:
#line 74 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
#line 326 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{ append_paged_link(sm, "pixiv #", "<a rel=\"external nofollow noreferrer\" class=\"dtext-link dtext-id-link dtext-pixiv-id-link\" href=\"", "https://www.pixiv.net/artworks/", "#"); }}
	goto st1146;
tr1769:
#line 72 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
#line 295 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{ append_id_link(sm, "pool", "pool", "/pools/", { sm->a1, sm->a2 }); }}
	goto st1146;
tr1773:
#line 72 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
#line 287 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{ append_id_link(sm, "post", "post", "/posts/", { sm->a1, sm->a2 }); }}
	goto st1146;
tr1778:
#line 72 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
#line 309 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{ append_id_link(sm, "pull", "github-pull", "https://github.com/danbooru/danbooru/pull/", { sm->a1, sm->a2 }); }}
	goto st1146;
tr1788:
#line 72 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
#line 320 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{ append_id_link(sm, "sankaku", "sankaku", "https://chan.sankakucomplex.com/post/show/", { sm->a1, sm->a2 }); }}
	goto st1146;
tr1794:
#line 72 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
#line 316 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{ append_id_link(sm, "seiga", "seiga", "https://seiga.nicovideo.jp/seiga/im", { sm->a1, sm->a2 }); }}
	goto st1146;
tr1802:
#line 72 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
#line 292 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{ append_id_link(sm, "topic", "forum-topic", "/forum_topics/", { sm->a1, sm->a2 }); }}
	goto st1146;
tr1805:
#line 74 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
#line 325 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{ append_paged_link(sm, "topic #", "<a class=\"dtext-link dtext-id-link dtext-forum-topic-id-link\" href=\"", "/forum_topics/", "?page="); }}
	goto st1146;
tr1813:
#line 72 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
#line 317 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{ append_id_link(sm, "twitter", "twitter", "https://twitter.com/i/web/status/", { sm->a1, sm->a2 }); }}
	goto st1146;
tr1819:
#line 72 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
#line 296 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{ append_id_link(sm, "user", "user", "/users/", { sm->a1, sm->a2 }); }}
	goto st1146;
tr1825:
#line 72 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
#line 306 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{ append_id_link(sm, "wiki", "wiki-page", "/wiki_pages/", { sm->a1, sm->a2 }); }}
	goto st1146;
tr1834:
#line 72 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
#line 319 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{ append_id_link(sm, "yandere", "yandere", "https://yande.re/post/show/", { sm->a1, sm->a2 }); }}
	goto st1146;
tr1847:
#line 407 "ext/dtext/dtext.cpp.rl"
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
{( (sm->stack.data()))[( sm->top)++] = 1146;goto st1405;}}
  }}
	goto st1146;
tr1848:
#line 402 "ext/dtext/dtext.cpp.rl"
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
{( (sm->stack.data()))[( sm->top)++] = 1146;goto st1405;}}
  }}
	goto st1146;
tr1849:
#line 439 "ext/dtext/dtext.cpp.rl"
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
{( (sm->stack.data()))[( sm->top)++] = 1146;goto st1410;}}
  }}
	goto st1146;
tr1869:
#line 364 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append_mention(sm, { sm->a1, sm->a2 + 1 });
  }}
	goto st1146;
st1146:
#line 1 "NONE"
	{( sm->ts) = 0;}
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1146;
case 1146:
#line 1 "NONE"
	{( sm->ts) = ( sm->p);}
#line 5653 "ext/dtext/dtext.cpp"
	_widec = (*( sm->p));
	if ( (*( sm->p)) > 60 ) {
		if ( 64 <= (*( sm->p)) && (*( sm->p)) <= 64 ) {
			_widec = (short)(1152 + ((*( sm->p)) - -128));
			if ( 
#line 82 "ext/dtext/dtext.cpp.rl"
 is_mention_boundary(p[-1])  ) _widec += 256;
			if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 512;
		}
	} else if ( (*( sm->p)) >= 60 ) {
		_widec = (short)(640 + ((*( sm->p)) - -128));
		if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
	}
	switch( _widec ) {
		case 0: goto tr1496;
		case 9: goto tr1497;
		case 10: goto tr1498;
		case 13: goto st1161;
		case 32: goto tr1497;
		case 34: goto tr1500;
		case 65: goto tr1503;
		case 66: goto tr1504;
		case 67: goto tr1505;
		case 68: goto tr1506;
		case 70: goto tr1507;
		case 71: goto tr1508;
		case 72: goto tr1509;
		case 73: goto tr1510;
		case 77: goto tr1511;
		case 78: goto tr1512;
		case 80: goto tr1513;
		case 83: goto tr1514;
		case 84: goto tr1515;
		case 85: goto tr1516;
		case 87: goto tr1517;
		case 89: goto tr1518;
		case 91: goto tr1519;
		case 97: goto tr1503;
		case 98: goto tr1504;
		case 99: goto tr1505;
		case 100: goto tr1506;
		case 102: goto tr1507;
		case 103: goto tr1508;
		case 104: goto tr1509;
		case 105: goto tr1510;
		case 109: goto tr1511;
		case 110: goto tr1512;
		case 112: goto tr1513;
		case 115: goto tr1514;
		case 116: goto tr1515;
		case 117: goto tr1516;
		case 119: goto tr1517;
		case 121: goto tr1518;
		case 123: goto tr1520;
		case 828: goto tr1521;
		case 1084: goto tr1522;
		case 1344: goto tr1492;
		case 1600: goto tr1492;
		case 1856: goto tr1492;
		case 2112: goto tr1523;
	}
	if ( _widec < 48 ) {
		if ( _widec < -32 ) {
			if ( _widec > -63 ) {
				if ( -62 <= _widec && _widec <= -33 )
					goto st1147;
			} else
				goto tr1492;
		} else if ( _widec > -17 ) {
			if ( _widec > -12 ) {
				if ( -11 <= _widec && _widec <= 47 )
					goto tr1492;
			} else if ( _widec >= -16 )
				goto tr1495;
		} else
			goto tr1494;
	} else if ( _widec > 57 ) {
		if ( _widec < 69 ) {
			if ( _widec > 59 ) {
				if ( 61 <= _widec && _widec <= 63 )
					goto tr1492;
			} else if ( _widec >= 58 )
				goto tr1492;
		} else if ( _widec > 90 ) {
			if ( _widec < 101 ) {
				if ( 92 <= _widec && _widec <= 96 )
					goto tr1492;
			} else if ( _widec > 122 ) {
				if ( 124 <= _widec )
					goto tr1492;
			} else
				goto tr1501;
		} else
			goto tr1501;
	} else
		goto tr1501;
	goto st0;
st1147:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1147;
case 1147:
	if ( (*( sm->p)) <= -65 )
		goto tr186;
	goto tr1524;
tr186:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 540 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1148;
st1148:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1148;
case 1148:
#line 5772 "ext/dtext/dtext.cpp"
	if ( (*( sm->p)) < -32 ) {
		if ( -62 <= (*( sm->p)) && (*( sm->p)) <= -33 )
			goto st155;
	} else if ( (*( sm->p)) > -17 ) {
		if ( -16 <= (*( sm->p)) && (*( sm->p)) <= -12 )
			goto st157;
	} else
		goto st156;
	goto tr1525;
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
tr1494:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 544 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 91;}
	goto st1149;
st1149:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1149;
case 1149:
#line 5813 "ext/dtext/dtext.cpp"
	if ( (*( sm->p)) <= -65 )
		goto st155;
	goto tr1524;
tr1495:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 544 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 91;}
	goto st1150;
st1150:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1150;
case 1150:
#line 5827 "ext/dtext/dtext.cpp"
	if ( (*( sm->p)) <= -65 )
		goto st156;
	goto tr1524;
tr190:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 510 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 86;}
	goto st1151;
tr1496:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 538 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 89;}
	goto st1151;
st1151:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1151;
case 1151:
#line 5847 "ext/dtext/dtext.cpp"
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
tr1497:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 544 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 91;}
	goto st1152;
st1152:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1152;
case 1152:
#line 5885 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto st158;
		case 9: goto st160;
		case 10: goto st158;
		case 13: goto st161;
		case 32: goto st160;
	}
	goto tr1524;
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
tr1498:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 519 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 87;}
	goto st1153;
st1153:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1153;
case 1153:
#line 5923 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr190;
		case 9: goto st162;
		case 10: goto tr237;
		case 13: goto st199;
		case 32: goto st162;
		case 42: goto tr1529;
		case 60: goto st214;
		case 72: goto st259;
		case 91: goto st263;
		case 96: goto st293;
		case 104: goto st259;
	}
	goto tr1527;
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
#line 503 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 85;}
	goto st1154;
st1154:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1154;
case 1154:
#line 6003 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr205;
		case 10: goto tr205;
		case 13: goto st167;
	}
	goto tr1534;
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
#line 510 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 86;}
	goto st1155;
st1155:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1155;
case 1155:
#line 6303 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr190;
		case 9: goto st158;
		case 10: goto tr237;
		case 13: goto st199;
		case 32: goto st158;
		case 60: goto st200;
		case 91: goto st206;
	}
	goto tr1535;
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
tr1529:
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st212;
st212:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof212;
case 212:
#line 6429 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto tr252;
		case 32: goto tr252;
		case 42: goto st212;
	}
	goto tr196;
tr252:
#line 72 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
	goto st213;
st213:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof213;
case 213:
#line 6444 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr196;
		case 9: goto tr255;
		case 10: goto tr196;
		case 13: goto tr196;
		case 32: goto tr255;
	}
	goto tr254;
tr254:
#line 73 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st1156;
st1156:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1156;
case 1156:
#line 6461 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr1538;
		case 10: goto tr1538;
		case 13: goto tr1538;
	}
	goto st1156;
tr255:
#line 73 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st1157;
st1157:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1157;
case 1157:
#line 6476 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr1538;
		case 9: goto tr255;
		case 10: goto tr1538;
		case 13: goto tr1538;
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
#line 84 "ext/dtext/dtext.cpp.rl"
 dstack_is_open(sm, BLOCK_QUOTE)  ) _widec += 256;
	}
	if ( _widec == 2653 )
		goto st1158;
	goto tr185;
st1158:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1158;
case 1158:
	switch( (*( sm->p)) ) {
		case 9: goto st1158;
		case 32: goto st1158;
	}
	goto tr1540;
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
#line 85 "ext/dtext/dtext.cpp.rl"
 dstack_is_open(sm, BLOCK_EXPAND)  ) _widec += 256;
	}
	if ( _widec == 3134 )
		goto st1159;
	goto tr185;
st1159:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1159;
case 1159:
	switch( (*( sm->p)) ) {
		case 9: goto st1159;
		case 32: goto st1159;
	}
	goto tr1541;
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
#line 84 "ext/dtext/dtext.cpp.rl"
 dstack_is_open(sm, BLOCK_QUOTE)  ) _widec += 256;
	}
	if ( _widec == 2622 )
		goto st1158;
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
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st251;
st251:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof251;
case 251:
#line 6886 "ext/dtext/dtext.cpp"
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
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st260;
st260:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof260;
case 260:
#line 6974 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 35: goto tr307;
		case 46: goto tr308;
	}
	goto tr196;
tr307:
#line 72 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
	goto st261;
st261:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof261;
case 261:
#line 6988 "ext/dtext/dtext.cpp"
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
#line 73 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st262;
st262:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof262;
case 262:
#line 7013 "ext/dtext/dtext.cpp"
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
#line 72 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
#line 73 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
#line 74 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
	goto st1160;
tr311:
#line 74 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
	goto st1160;
st1160:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1160;
case 1160:
#line 7046 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto st1160;
		case 32: goto st1160;
	}
	goto tr1542;
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
#line 85 "ext/dtext/dtext.cpp.rl"
 dstack_is_open(sm, BLOCK_EXPAND)  ) _widec += 256;
	}
	if ( _widec == 3165 )
		goto st1159;
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
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st285;
st285:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof285;
case 285:
#line 7288 "ext/dtext/dtext.cpp"
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
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
#line 72 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
	goto st295;
st295:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof295;
case 295:
#line 7385 "ext/dtext/dtext.cpp"
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
#line 72 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
	goto st296;
tr344:
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
#line 72 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
	goto st296;
st296:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof296;
case 296:
#line 7416 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr349;
		case 10: goto tr349;
		case 13: goto tr350;
	}
	goto tr348;
tr348:
#line 73 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st297;
tr353:
#line 74 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
	goto st297;
tr350:
#line 73 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
#line 74 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
	goto st297;
st297:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof297;
case 297:
#line 7441 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr352;
		case 10: goto tr352;
		case 13: goto tr353;
	}
	goto st297;
tr352:
#line 74 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
	goto st298;
tr349:
#line 73 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
#line 74 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
	goto st298;
st298:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof298;
case 298:
#line 7462 "ext/dtext/dtext.cpp"
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
#line 74 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
	goto st302;
st302:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof302;
case 302:
#line 7512 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr352;
		case 10: goto tr357;
		case 13: goto tr353;
	}
	goto st297;
tr362:
#line 72 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
	goto st303;
tr346:
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
#line 72 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
	goto st303;
st303:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof303;
case 303:
#line 7533 "ext/dtext/dtext.cpp"
	if ( (*( sm->p)) == 10 )
		goto st296;
	goto tr196;
tr347:
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st304;
st304:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof304;
case 304:
#line 7545 "ext/dtext/dtext.cpp"
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
#line 72 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
	goto st305;
st305:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof305;
case 305:
#line 7570 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto st296;
		case 9: goto st305;
		case 10: goto st296;
		case 13: goto st303;
		case 32: goto st305;
	}
	goto tr196;
st1161:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1161;
case 1161:
	if ( (*( sm->p)) == 10 )
		goto tr1498;
	goto tr1544;
tr1500:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 544 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 91;}
	goto st1162;
st1162:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1162;
case 1162:
#line 7596 "ext/dtext/dtext.cpp"
	if ( (*( sm->p)) == 34 )
		goto tr1524;
	goto tr1545;
tr1545:
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st306;
st306:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof306;
case 306:
#line 7608 "ext/dtext/dtext.cpp"
	if ( (*( sm->p)) == 34 )
		goto tr367;
	goto st306;
tr367:
#line 72 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
	goto st307;
st307:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof307;
case 307:
#line 7620 "ext/dtext/dtext.cpp"
	if ( (*( sm->p)) == 58 )
		goto st308;
	goto tr193;
st308:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof308;
case 308:
	switch( (*( sm->p)) ) {
		case 35: goto tr369;
		case 47: goto tr370;
		case 72: goto tr371;
		case 91: goto st367;
		case 104: goto tr371;
	}
	goto tr193;
tr369:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 73 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
#line 74 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
	goto st1163;
tr374:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 74 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
	goto st1163;
st1163:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1163;
case 1163:
#line 7654 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case -30: goto st311;
		case -29: goto st313;
		case -17: goto st315;
		case 32: goto tr1546;
		case 34: goto st319;
		case 35: goto tr1546;
		case 39: goto st319;
		case 44: goto st319;
		case 46: goto st319;
		case 60: goto tr1546;
		case 62: goto tr1546;
		case 63: goto st319;
		case 91: goto tr1546;
		case 93: goto tr1546;
	}
	if ( (*( sm->p)) < -16 ) {
		if ( (*( sm->p)) < -62 ) {
			if ( (*( sm->p)) <= -63 )
				goto tr1546;
		} else if ( (*( sm->p)) > -33 ) {
			if ( -32 <= (*( sm->p)) && (*( sm->p)) <= -18 )
				goto st310;
		} else
			goto st309;
	} else if ( (*( sm->p)) > -12 ) {
		if ( (*( sm->p)) < 9 ) {
			if ( -11 <= (*( sm->p)) && (*( sm->p)) <= 0 )
				goto tr1546;
		} else if ( (*( sm->p)) > 13 ) {
			if ( 58 <= (*( sm->p)) && (*( sm->p)) <= 59 )
				goto st319;
		} else
			goto tr1546;
	} else
		goto st318;
	goto tr374;
st309:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof309;
case 309:
	if ( (*( sm->p)) <= -65 )
		goto tr374;
	goto tr373;
st310:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof310;
case 310:
	if ( (*( sm->p)) <= -65 )
		goto st309;
	goto tr373;
st311:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof311;
case 311:
	if ( (*( sm->p)) == -99 )
		goto st312;
	if ( (*( sm->p)) <= -65 )
		goto st309;
	goto tr373;
st312:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof312;
case 312:
	if ( (*( sm->p)) > -84 ) {
		if ( -82 <= (*( sm->p)) && (*( sm->p)) <= -65 )
			goto tr374;
	} else
		goto tr374;
	goto tr373;
st313:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof313;
case 313:
	if ( (*( sm->p)) == -128 )
		goto st314;
	if ( -127 <= (*( sm->p)) && (*( sm->p)) <= -65 )
		goto st309;
	goto tr373;
st314:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof314;
case 314:
	if ( (*( sm->p)) < -110 ) {
		if ( -125 <= (*( sm->p)) && (*( sm->p)) <= -121 )
			goto tr374;
	} else if ( (*( sm->p)) > -109 ) {
		if ( -99 <= (*( sm->p)) && (*( sm->p)) <= -65 )
			goto tr374;
	} else
		goto tr374;
	goto tr373;
st315:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof315;
case 315:
	switch( (*( sm->p)) ) {
		case -68: goto st316;
		case -67: goto st317;
	}
	if ( (*( sm->p)) <= -65 )
		goto st309;
	goto tr373;
st316:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof316;
case 316:
	if ( (*( sm->p)) < -118 ) {
		if ( (*( sm->p)) <= -120 )
			goto tr374;
	} else if ( (*( sm->p)) > -68 ) {
		if ( -66 <= (*( sm->p)) && (*( sm->p)) <= -65 )
			goto tr374;
	} else
		goto tr374;
	goto tr373;
st317:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof317;
case 317:
	if ( (*( sm->p)) < -98 ) {
		if ( (*( sm->p)) <= -100 )
			goto tr374;
	} else if ( (*( sm->p)) > -97 ) {
		if ( (*( sm->p)) > -94 ) {
			if ( -92 <= (*( sm->p)) && (*( sm->p)) <= -65 )
				goto tr374;
		} else if ( (*( sm->p)) >= -95 )
			goto tr374;
	} else
		goto tr374;
	goto tr373;
st318:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof318;
case 318:
	if ( (*( sm->p)) <= -65 )
		goto st310;
	goto tr373;
st319:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof319;
case 319:
	switch( (*( sm->p)) ) {
		case -30: goto st311;
		case -29: goto st313;
		case -17: goto st315;
		case 32: goto tr373;
		case 34: goto st319;
		case 35: goto tr373;
		case 39: goto st319;
		case 44: goto st319;
		case 46: goto st319;
		case 60: goto tr373;
		case 62: goto tr373;
		case 63: goto st319;
		case 91: goto tr373;
		case 93: goto tr373;
	}
	if ( (*( sm->p)) < -16 ) {
		if ( (*( sm->p)) < -62 ) {
			if ( (*( sm->p)) <= -63 )
				goto tr373;
		} else if ( (*( sm->p)) > -33 ) {
			if ( -32 <= (*( sm->p)) && (*( sm->p)) <= -18 )
				goto st310;
		} else
			goto st309;
	} else if ( (*( sm->p)) > -12 ) {
		if ( (*( sm->p)) < 9 ) {
			if ( -11 <= (*( sm->p)) && (*( sm->p)) <= 0 )
				goto tr373;
		} else if ( (*( sm->p)) > 13 ) {
			if ( 58 <= (*( sm->p)) && (*( sm->p)) <= 59 )
				goto st319;
		} else
			goto tr373;
	} else
		goto st318;
	goto tr374;
tr370:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 73 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
#line 74 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
#line 344 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 51;}
	goto st1164;
tr386:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 74 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
#line 344 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 51;}
	goto st1164;
st1164:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1164;
case 1164:
#line 7857 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case -30: goto st322;
		case -29: goto st324;
		case -17: goto st326;
		case 32: goto tr1546;
		case 34: goto st330;
		case 35: goto tr374;
		case 39: goto st330;
		case 44: goto st330;
		case 46: goto st330;
		case 60: goto tr1546;
		case 62: goto tr1546;
		case 63: goto st331;
		case 91: goto tr1546;
		case 93: goto tr1546;
	}
	if ( (*( sm->p)) < -16 ) {
		if ( (*( sm->p)) < -62 ) {
			if ( (*( sm->p)) <= -63 )
				goto tr1546;
		} else if ( (*( sm->p)) > -33 ) {
			if ( -32 <= (*( sm->p)) && (*( sm->p)) <= -18 )
				goto st321;
		} else
			goto st320;
	} else if ( (*( sm->p)) > -12 ) {
		if ( (*( sm->p)) < 9 ) {
			if ( -11 <= (*( sm->p)) && (*( sm->p)) <= 0 )
				goto tr1546;
		} else if ( (*( sm->p)) > 13 ) {
			if ( 58 <= (*( sm->p)) && (*( sm->p)) <= 59 )
				goto st330;
		} else
			goto tr1546;
	} else
		goto st329;
	goto tr386;
st320:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof320;
case 320:
	if ( (*( sm->p)) <= -65 )
		goto tr386;
	goto tr373;
st321:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof321;
case 321:
	if ( (*( sm->p)) <= -65 )
		goto st320;
	goto tr373;
st322:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof322;
case 322:
	if ( (*( sm->p)) == -99 )
		goto st323;
	if ( (*( sm->p)) <= -65 )
		goto st320;
	goto tr373;
st323:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof323;
case 323:
	if ( (*( sm->p)) > -84 ) {
		if ( -82 <= (*( sm->p)) && (*( sm->p)) <= -65 )
			goto tr386;
	} else
		goto tr386;
	goto tr373;
st324:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof324;
case 324:
	if ( (*( sm->p)) == -128 )
		goto st325;
	if ( -127 <= (*( sm->p)) && (*( sm->p)) <= -65 )
		goto st320;
	goto tr373;
st325:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof325;
case 325:
	if ( (*( sm->p)) < -110 ) {
		if ( -125 <= (*( sm->p)) && (*( sm->p)) <= -121 )
			goto tr386;
	} else if ( (*( sm->p)) > -109 ) {
		if ( -99 <= (*( sm->p)) && (*( sm->p)) <= -65 )
			goto tr386;
	} else
		goto tr386;
	goto tr373;
st326:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof326;
case 326:
	switch( (*( sm->p)) ) {
		case -68: goto st327;
		case -67: goto st328;
	}
	if ( (*( sm->p)) <= -65 )
		goto st320;
	goto tr373;
st327:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof327;
case 327:
	if ( (*( sm->p)) < -118 ) {
		if ( (*( sm->p)) <= -120 )
			goto tr386;
	} else if ( (*( sm->p)) > -68 ) {
		if ( -66 <= (*( sm->p)) && (*( sm->p)) <= -65 )
			goto tr386;
	} else
		goto tr386;
	goto tr373;
st328:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof328;
case 328:
	if ( (*( sm->p)) < -98 ) {
		if ( (*( sm->p)) <= -100 )
			goto tr386;
	} else if ( (*( sm->p)) > -97 ) {
		if ( (*( sm->p)) > -94 ) {
			if ( -92 <= (*( sm->p)) && (*( sm->p)) <= -65 )
				goto tr386;
		} else if ( (*( sm->p)) >= -95 )
			goto tr386;
	} else
		goto tr386;
	goto tr373;
st329:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof329;
case 329:
	if ( (*( sm->p)) <= -65 )
		goto st321;
	goto tr373;
st330:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof330;
case 330:
	switch( (*( sm->p)) ) {
		case -30: goto st322;
		case -29: goto st324;
		case -17: goto st326;
		case 32: goto tr373;
		case 34: goto st330;
		case 35: goto tr374;
		case 39: goto st330;
		case 44: goto st330;
		case 46: goto st330;
		case 60: goto tr373;
		case 62: goto tr373;
		case 63: goto st331;
		case 91: goto tr373;
		case 93: goto tr373;
	}
	if ( (*( sm->p)) < -16 ) {
		if ( (*( sm->p)) < -62 ) {
			if ( (*( sm->p)) <= -63 )
				goto tr373;
		} else if ( (*( sm->p)) > -33 ) {
			if ( -32 <= (*( sm->p)) && (*( sm->p)) <= -18 )
				goto st321;
		} else
			goto st320;
	} else if ( (*( sm->p)) > -12 ) {
		if ( (*( sm->p)) < 9 ) {
			if ( -11 <= (*( sm->p)) && (*( sm->p)) <= 0 )
				goto tr373;
		} else if ( (*( sm->p)) > 13 ) {
			if ( 58 <= (*( sm->p)) && (*( sm->p)) <= 59 )
				goto st330;
		} else
			goto tr373;
	} else
		goto st329;
	goto tr386;
st331:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof331;
case 331:
	switch( (*( sm->p)) ) {
		case -30: goto st334;
		case -29: goto st336;
		case -17: goto st338;
		case 32: goto tr185;
		case 34: goto st331;
		case 35: goto tr374;
		case 39: goto st331;
		case 44: goto st331;
		case 46: goto st331;
		case 63: goto st331;
	}
	if ( (*( sm->p)) < -16 ) {
		if ( (*( sm->p)) < -62 ) {
			if ( (*( sm->p)) <= -63 )
				goto tr185;
		} else if ( (*( sm->p)) > -33 ) {
			if ( -32 <= (*( sm->p)) && (*( sm->p)) <= -18 )
				goto st333;
		} else
			goto st332;
	} else if ( (*( sm->p)) > -12 ) {
		if ( (*( sm->p)) < 9 ) {
			if ( -11 <= (*( sm->p)) && (*( sm->p)) <= 0 )
				goto tr185;
		} else if ( (*( sm->p)) > 13 ) {
			if ( 58 <= (*( sm->p)) && (*( sm->p)) <= 59 )
				goto st331;
		} else
			goto tr185;
	} else
		goto st341;
	goto tr405;
st332:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof332;
case 332:
	if ( (*( sm->p)) <= -65 )
		goto tr405;
	goto tr185;
tr405:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 74 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
#line 344 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 51;}
	goto st1165;
st1165:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1165;
case 1165:
#line 8094 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case -30: goto st334;
		case -29: goto st336;
		case -17: goto st338;
		case 32: goto tr1546;
		case 34: goto st331;
		case 35: goto tr374;
		case 39: goto st331;
		case 44: goto st331;
		case 46: goto st331;
		case 63: goto st331;
	}
	if ( (*( sm->p)) < -16 ) {
		if ( (*( sm->p)) < -62 ) {
			if ( (*( sm->p)) <= -63 )
				goto tr1546;
		} else if ( (*( sm->p)) > -33 ) {
			if ( -32 <= (*( sm->p)) && (*( sm->p)) <= -18 )
				goto st333;
		} else
			goto st332;
	} else if ( (*( sm->p)) > -12 ) {
		if ( (*( sm->p)) < 9 ) {
			if ( -11 <= (*( sm->p)) && (*( sm->p)) <= 0 )
				goto tr1546;
		} else if ( (*( sm->p)) > 13 ) {
			if ( 58 <= (*( sm->p)) && (*( sm->p)) <= 59 )
				goto st331;
		} else
			goto tr1546;
	} else
		goto st341;
	goto tr405;
st333:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof333;
case 333:
	if ( (*( sm->p)) <= -65 )
		goto st332;
	goto tr185;
st334:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof334;
case 334:
	if ( (*( sm->p)) == -99 )
		goto st335;
	if ( (*( sm->p)) <= -65 )
		goto st332;
	goto tr185;
st335:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof335;
case 335:
	if ( (*( sm->p)) > -84 ) {
		if ( -82 <= (*( sm->p)) && (*( sm->p)) <= -65 )
			goto tr405;
	} else
		goto tr405;
	goto tr185;
st336:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof336;
case 336:
	if ( (*( sm->p)) == -128 )
		goto st337;
	if ( -127 <= (*( sm->p)) && (*( sm->p)) <= -65 )
		goto st332;
	goto tr185;
st337:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof337;
case 337:
	if ( (*( sm->p)) < -110 ) {
		if ( -125 <= (*( sm->p)) && (*( sm->p)) <= -121 )
			goto tr405;
	} else if ( (*( sm->p)) > -109 ) {
		if ( -99 <= (*( sm->p)) && (*( sm->p)) <= -65 )
			goto tr405;
	} else
		goto tr405;
	goto tr185;
st338:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof338;
case 338:
	switch( (*( sm->p)) ) {
		case -68: goto st339;
		case -67: goto st340;
	}
	if ( (*( sm->p)) <= -65 )
		goto st332;
	goto tr185;
st339:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof339;
case 339:
	if ( (*( sm->p)) < -118 ) {
		if ( (*( sm->p)) <= -120 )
			goto tr405;
	} else if ( (*( sm->p)) > -68 ) {
		if ( -66 <= (*( sm->p)) && (*( sm->p)) <= -65 )
			goto tr405;
	} else
		goto tr405;
	goto tr185;
st340:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof340;
case 340:
	if ( (*( sm->p)) < -98 ) {
		if ( (*( sm->p)) <= -100 )
			goto tr405;
	} else if ( (*( sm->p)) > -97 ) {
		if ( (*( sm->p)) > -94 ) {
			if ( -92 <= (*( sm->p)) && (*( sm->p)) <= -65 )
				goto tr405;
		} else if ( (*( sm->p)) >= -95 )
			goto tr405;
	} else
		goto tr405;
	goto tr185;
st341:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof341;
case 341:
	if ( (*( sm->p)) <= -65 )
		goto st333;
	goto tr185;
tr371:
#line 73 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st342;
st342:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof342;
case 342:
#line 8231 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 84: goto st343;
		case 116: goto st343;
	}
	goto tr193;
st343:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof343;
case 343:
	switch( (*( sm->p)) ) {
		case 84: goto st344;
		case 116: goto st344;
	}
	goto tr193;
st344:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof344;
case 344:
	switch( (*( sm->p)) ) {
		case 80: goto st345;
		case 112: goto st345;
	}
	goto tr193;
st345:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof345;
case 345:
	switch( (*( sm->p)) ) {
		case 58: goto st346;
		case 83: goto st366;
		case 115: goto st366;
	}
	goto tr193;
st346:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof346;
case 346:
	if ( (*( sm->p)) == 47 )
		goto st347;
	goto tr193;
st347:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof347;
case 347:
	if ( (*( sm->p)) == 47 )
		goto st348;
	goto tr193;
st348:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof348;
case 348:
	switch( (*( sm->p)) ) {
		case 45: goto st350;
		case 95: goto st350;
	}
	if ( (*( sm->p)) < -16 ) {
		if ( (*( sm->p)) > -33 ) {
			if ( -32 <= (*( sm->p)) && (*( sm->p)) <= -17 )
				goto st351;
		} else if ( (*( sm->p)) >= -62 )
			goto st349;
	} else if ( (*( sm->p)) > -12 ) {
		if ( (*( sm->p)) < 65 ) {
			if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
				goto st350;
		} else if ( (*( sm->p)) > 90 ) {
			if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
				goto st350;
		} else
			goto st350;
	} else
		goto st352;
	goto tr193;
st349:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof349;
case 349:
	if ( (*( sm->p)) <= -65 )
		goto st350;
	goto tr193;
st350:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof350;
case 350:
	switch( (*( sm->p)) ) {
		case 45: goto st350;
		case 46: goto st353;
		case 95: goto st350;
	}
	if ( (*( sm->p)) < -16 ) {
		if ( (*( sm->p)) > -33 ) {
			if ( -32 <= (*( sm->p)) && (*( sm->p)) <= -17 )
				goto st351;
		} else if ( (*( sm->p)) >= -62 )
			goto st349;
	} else if ( (*( sm->p)) > -12 ) {
		if ( (*( sm->p)) < 65 ) {
			if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
				goto st350;
		} else if ( (*( sm->p)) > 90 ) {
			if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
				goto st350;
		} else
			goto st350;
	} else
		goto st352;
	goto tr193;
st351:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof351;
case 351:
	if ( (*( sm->p)) <= -65 )
		goto st349;
	goto tr193;
st352:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof352;
case 352:
	if ( (*( sm->p)) <= -65 )
		goto st351;
	goto tr193;
st353:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof353;
case 353:
	switch( (*( sm->p)) ) {
		case -30: goto st356;
		case -29: goto st359;
		case -17: goto st361;
		case 45: goto tr428;
		case 95: goto tr428;
	}
	if ( (*( sm->p)) < -16 ) {
		if ( (*( sm->p)) > -33 ) {
			if ( -32 <= (*( sm->p)) && (*( sm->p)) <= -18 )
				goto st355;
		} else if ( (*( sm->p)) >= -62 )
			goto st354;
	} else if ( (*( sm->p)) > -12 ) {
		if ( (*( sm->p)) < 65 ) {
			if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
				goto tr428;
		} else if ( (*( sm->p)) > 90 ) {
			if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
				goto tr428;
		} else
			goto tr428;
	} else
		goto st364;
	goto tr185;
st354:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof354;
case 354:
	if ( (*( sm->p)) <= -65 )
		goto tr428;
	goto tr185;
tr428:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 74 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
#line 344 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 51;}
	goto st1166;
st1166:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1166;
case 1166:
#line 8401 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case -30: goto st356;
		case -29: goto st359;
		case -17: goto st361;
		case 35: goto tr374;
		case 46: goto st353;
		case 47: goto tr386;
		case 58: goto st365;
		case 63: goto st331;
		case 95: goto tr428;
	}
	if ( (*( sm->p)) < -16 ) {
		if ( (*( sm->p)) > -33 ) {
			if ( -32 <= (*( sm->p)) && (*( sm->p)) <= -18 )
				goto st355;
		} else if ( (*( sm->p)) >= -62 )
			goto st354;
	} else if ( (*( sm->p)) > -12 ) {
		if ( (*( sm->p)) < 65 ) {
			if ( 45 <= (*( sm->p)) && (*( sm->p)) <= 57 )
				goto tr428;
		} else if ( (*( sm->p)) > 90 ) {
			if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
				goto tr428;
		} else
			goto tr428;
	} else
		goto st364;
	goto tr1546;
st355:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof355;
case 355:
	if ( (*( sm->p)) <= -65 )
		goto st354;
	goto tr185;
st356:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof356;
case 356:
	if ( (*( sm->p)) == -99 )
		goto st357;
	if ( (*( sm->p)) <= -65 )
		goto st354;
	goto tr185;
st357:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof357;
case 357:
	if ( (*( sm->p)) == -83 )
		goto st358;
	if ( (*( sm->p)) <= -65 )
		goto tr428;
	goto tr185;
st358:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof358;
case 358:
	switch( (*( sm->p)) ) {
		case -30: goto st356;
		case -29: goto st359;
		case -17: goto st361;
		case 35: goto tr374;
		case 46: goto st353;
		case 47: goto tr386;
		case 58: goto st365;
		case 63: goto st331;
		case 95: goto tr428;
	}
	if ( (*( sm->p)) < -16 ) {
		if ( (*( sm->p)) > -33 ) {
			if ( -32 <= (*( sm->p)) && (*( sm->p)) <= -18 )
				goto st355;
		} else if ( (*( sm->p)) >= -62 )
			goto st354;
	} else if ( (*( sm->p)) > -12 ) {
		if ( (*( sm->p)) < 65 ) {
			if ( 45 <= (*( sm->p)) && (*( sm->p)) <= 57 )
				goto tr428;
		} else if ( (*( sm->p)) > 90 ) {
			if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
				goto tr428;
		} else
			goto tr428;
	} else
		goto st364;
	goto tr185;
st359:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof359;
case 359:
	if ( (*( sm->p)) == -128 )
		goto st360;
	if ( -127 <= (*( sm->p)) && (*( sm->p)) <= -65 )
		goto st354;
	goto tr185;
st360:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof360;
case 360:
	if ( (*( sm->p)) < -120 ) {
		if ( (*( sm->p)) > -126 ) {
			if ( -125 <= (*( sm->p)) && (*( sm->p)) <= -121 )
				goto tr428;
		} else
			goto st358;
	} else if ( (*( sm->p)) > -111 ) {
		if ( (*( sm->p)) < -108 ) {
			if ( -110 <= (*( sm->p)) && (*( sm->p)) <= -109 )
				goto tr428;
		} else if ( (*( sm->p)) > -100 ) {
			if ( -99 <= (*( sm->p)) && (*( sm->p)) <= -65 )
				goto tr428;
		} else
			goto st358;
	} else
		goto st358;
	goto tr185;
st361:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof361;
case 361:
	switch( (*( sm->p)) ) {
		case -68: goto st362;
		case -67: goto st363;
	}
	if ( (*( sm->p)) <= -65 )
		goto st354;
	goto tr185;
st362:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof362;
case 362:
	switch( (*( sm->p)) ) {
		case -119: goto st358;
		case -67: goto st358;
	}
	if ( (*( sm->p)) <= -65 )
		goto tr428;
	goto tr185;
st363:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof363;
case 363:
	switch( (*( sm->p)) ) {
		case -99: goto st358;
		case -96: goto st358;
		case -93: goto st358;
	}
	if ( (*( sm->p)) <= -65 )
		goto tr428;
	goto tr185;
st364:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof364;
case 364:
	if ( (*( sm->p)) <= -65 )
		goto st355;
	goto tr185;
st365:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof365;
case 365:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr435;
	goto tr185;
tr435:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 74 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
#line 344 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 51;}
	goto st1167;
st1167:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1167;
case 1167:
#line 8580 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 35: goto tr374;
		case 47: goto tr386;
		case 63: goto st331;
	}
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr435;
	goto tr1546;
st366:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof366;
case 366:
	if ( (*( sm->p)) == 58 )
		goto st346;
	goto tr193;
st367:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof367;
case 367:
	switch( (*( sm->p)) ) {
		case 35: goto tr436;
		case 47: goto tr436;
		case 72: goto tr437;
		case 104: goto tr437;
	}
	goto tr193;
tr436:
#line 73 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st368;
st368:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof368;
case 368:
#line 8615 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr193;
		case 32: goto tr193;
		case 93: goto tr439;
	}
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr193;
	goto st368;
tr437:
#line 73 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st369;
st369:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof369;
case 369:
#line 8632 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 84: goto st370;
		case 116: goto st370;
	}
	goto tr193;
st370:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof370;
case 370:
	switch( (*( sm->p)) ) {
		case 84: goto st371;
		case 116: goto st371;
	}
	goto tr193;
st371:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof371;
case 371:
	switch( (*( sm->p)) ) {
		case 80: goto st372;
		case 112: goto st372;
	}
	goto tr193;
st372:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof372;
case 372:
	switch( (*( sm->p)) ) {
		case 58: goto st373;
		case 83: goto st376;
		case 115: goto st376;
	}
	goto tr193;
st373:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof373;
case 373:
	if ( (*( sm->p)) == 47 )
		goto st374;
	goto tr193;
st374:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof374;
case 374:
	if ( (*( sm->p)) == 47 )
		goto st375;
	goto tr193;
st375:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof375;
case 375:
	switch( (*( sm->p)) ) {
		case 0: goto tr193;
		case 32: goto tr193;
	}
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr193;
	goto st368;
st376:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof376;
case 376:
	if ( (*( sm->p)) == 58 )
		goto st373;
	goto tr193;
tr1547:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 540 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1168;
tr1501:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
#line 540 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1168;
st1168:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1168;
case 1168:
#line 8716 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 91: goto tr1548;
		case 123: goto tr1549;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1547;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1547;
	} else
		goto tr1547;
	goto tr1525;
tr1548:
#line 72 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
	goto st377;
st377:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof377;
case 377:
#line 8738 "ext/dtext/dtext.cpp"
	if ( (*( sm->p)) == 91 )
		goto st378;
	goto tr188;
tr449:
#line 73 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st378;
st378:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof378;
case 378:
#line 8750 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto tr449;
		case 32: goto tr449;
		case 58: goto tr451;
		case 60: goto tr452;
		case 62: goto tr453;
		case 92: goto tr454;
		case 93: goto tr185;
		case 124: goto tr455;
	}
	if ( 10 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr450;
	goto tr448;
tr448:
#line 73 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st379;
st379:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof379;
case 379:
#line 8772 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto tr457;
		case 32: goto tr457;
		case 35: goto tr459;
		case 93: goto tr460;
		case 124: goto tr461;
	}
	if ( 10 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto st381;
	goto st379;
tr457:
#line 74 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
	goto st380;
st380:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof380;
case 380:
#line 8791 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto st380;
		case 32: goto st380;
		case 35: goto st382;
		case 93: goto st385;
		case 124: goto st386;
	}
	if ( 10 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto st381;
	goto st379;
tr450:
#line 73 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st381;
st381:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof381;
case 381:
#line 8810 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 32: goto st381;
		case 93: goto tr185;
		case 124: goto tr185;
	}
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto st381;
	goto st379;
tr459:
#line 74 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
	goto st382;
st382:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof382;
case 382:
#line 8827 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto tr457;
		case 32: goto tr457;
		case 35: goto tr459;
		case 93: goto tr460;
		case 124: goto tr461;
	}
	if ( (*( sm->p)) > 13 ) {
		if ( 65 <= (*( sm->p)) && (*( sm->p)) <= 90 )
			goto tr466;
	} else if ( (*( sm->p)) >= 10 )
		goto st381;
	goto st379;
tr466:
#line 75 "ext/dtext/dtext.cpp.rl"
	{ sm->c1 = sm->p; }
	goto st383;
st383:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof383;
case 383:
#line 8849 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto tr467;
		case 32: goto tr468;
		case 45: goto st391;
		case 93: goto tr471;
		case 95: goto st391;
		case 124: goto tr472;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st383;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st383;
	} else
		goto st383;
	goto tr185;
tr467:
#line 76 "ext/dtext/dtext.cpp.rl"
	{ sm->c2 = sm->p; }
	goto st384;
st384:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof384;
case 384:
#line 8875 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto st384;
		case 32: goto st384;
		case 93: goto st385;
		case 124: goto st386;
	}
	goto tr185;
tr460:
#line 74 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
	goto st385;
tr471:
#line 76 "ext/dtext/dtext.cpp.rl"
	{ sm->c2 = sm->p; }
	goto st385;
st385:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof385;
case 385:
#line 8895 "ext/dtext/dtext.cpp"
	if ( (*( sm->p)) == 93 )
		goto st1169;
	goto tr185;
st1169:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1169;
case 1169:
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1551;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1551;
	} else
		goto tr1551;
	goto tr1550;
tr1551:
#line 79 "ext/dtext/dtext.cpp.rl"
	{ sm->e1 = sm->p; }
	goto st1170;
st1170:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1170;
case 1170:
#line 8920 "ext/dtext/dtext.cpp"
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st1170;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st1170;
	} else
		goto st1170;
	goto tr1552;
tr461:
#line 74 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
	goto st386;
tr472:
#line 76 "ext/dtext/dtext.cpp.rl"
	{ sm->c2 = sm->p; }
	goto st386;
tr476:
#line 77 "ext/dtext/dtext.cpp.rl"
	{ sm->d1 = sm->p; }
#line 78 "ext/dtext/dtext.cpp.rl"
	{ sm->d2 = sm->p; }
	goto st386;
st386:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof386;
case 386:
#line 8948 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto tr476;
		case 32: goto tr476;
		case 93: goto tr477;
		case 124: goto tr185;
	}
	if ( 10 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr185;
	goto tr475;
tr475:
#line 77 "ext/dtext/dtext.cpp.rl"
	{ sm->d1 = sm->p; }
	goto st387;
st387:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof387;
case 387:
#line 8966 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto tr479;
		case 32: goto tr479;
		case 93: goto tr480;
		case 124: goto tr185;
	}
	if ( 10 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr185;
	goto st387;
tr479:
#line 78 "ext/dtext/dtext.cpp.rl"
	{ sm->d2 = sm->p; }
	goto st388;
st388:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof388;
case 388:
#line 8984 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto st388;
		case 32: goto st388;
		case 93: goto st389;
		case 124: goto tr185;
	}
	if ( 10 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr185;
	goto st387;
tr477:
#line 77 "ext/dtext/dtext.cpp.rl"
	{ sm->d1 = sm->p; }
#line 78 "ext/dtext/dtext.cpp.rl"
	{ sm->d2 = sm->p; }
	goto st389;
tr480:
#line 78 "ext/dtext/dtext.cpp.rl"
	{ sm->d2 = sm->p; }
	goto st389;
st389:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof389;
case 389:
#line 9008 "ext/dtext/dtext.cpp"
	if ( (*( sm->p)) == 93 )
		goto st1171;
	goto tr185;
st1171:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1171;
case 1171:
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1555;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1555;
	} else
		goto tr1555;
	goto tr1554;
tr1555:
#line 79 "ext/dtext/dtext.cpp.rl"
	{ sm->e1 = sm->p; }
	goto st1172;
st1172:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1172;
case 1172:
#line 9033 "ext/dtext/dtext.cpp"
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st1172;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st1172;
	} else
		goto st1172;
	goto tr1556;
tr468:
#line 76 "ext/dtext/dtext.cpp.rl"
	{ sm->c2 = sm->p; }
	goto st390;
st390:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof390;
case 390:
#line 9051 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto st384;
		case 32: goto st390;
		case 45: goto st391;
		case 93: goto st385;
		case 95: goto st391;
		case 124: goto st386;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st383;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st383;
	} else
		goto st383;
	goto tr185;
st391:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof391;
case 391:
	switch( (*( sm->p)) ) {
		case 32: goto st391;
		case 45: goto st391;
		case 95: goto st391;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st383;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st383;
	} else
		goto st383;
	goto tr185;
tr451:
#line 73 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st392;
st392:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof392;
case 392:
#line 9095 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto tr457;
		case 32: goto tr457;
		case 35: goto tr459;
		case 93: goto tr460;
		case 124: goto tr485;
	}
	if ( 10 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto st381;
	goto st379;
tr485:
#line 74 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
	goto st393;
st393:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof393;
case 393:
#line 9114 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto tr486;
		case 32: goto tr486;
		case 35: goto tr487;
		case 93: goto tr488;
		case 124: goto tr185;
	}
	if ( 10 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr185;
	goto tr475;
tr489:
#line 77 "ext/dtext/dtext.cpp.rl"
	{ sm->d1 = sm->p; }
#line 78 "ext/dtext/dtext.cpp.rl"
	{ sm->d2 = sm->p; }
	goto st394;
tr486:
#line 74 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
#line 77 "ext/dtext/dtext.cpp.rl"
	{ sm->d1 = sm->p; }
#line 78 "ext/dtext/dtext.cpp.rl"
	{ sm->d2 = sm->p; }
	goto st394;
st394:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof394;
case 394:
#line 9143 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto tr489;
		case 32: goto tr489;
		case 35: goto tr490;
		case 93: goto tr491;
		case 124: goto tr185;
	}
	if ( 10 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr185;
	goto tr475;
tr525:
#line 74 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
	goto st395;
tr490:
#line 77 "ext/dtext/dtext.cpp.rl"
	{ sm->d1 = sm->p; }
	goto st395;
tr487:
#line 74 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
#line 77 "ext/dtext/dtext.cpp.rl"
	{ sm->d1 = sm->p; }
	goto st395;
st395:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof395;
case 395:
#line 9172 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto tr479;
		case 32: goto tr479;
		case 93: goto tr480;
		case 124: goto tr185;
	}
	if ( (*( sm->p)) > 13 ) {
		if ( 65 <= (*( sm->p)) && (*( sm->p)) <= 90 )
			goto tr492;
	} else if ( (*( sm->p)) >= 10 )
		goto tr185;
	goto st387;
tr492:
#line 75 "ext/dtext/dtext.cpp.rl"
	{ sm->c1 = sm->p; }
	goto st396;
st396:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof396;
case 396:
#line 9193 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto tr493;
		case 32: goto tr494;
		case 45: goto st400;
		case 93: goto tr497;
		case 95: goto st400;
		case 124: goto tr185;
	}
	if ( (*( sm->p)) < 48 ) {
		if ( 10 <= (*( sm->p)) && (*( sm->p)) <= 13 )
			goto tr185;
	} else if ( (*( sm->p)) > 57 ) {
		if ( (*( sm->p)) > 90 ) {
			if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
				goto st396;
		} else if ( (*( sm->p)) >= 65 )
			goto st396;
	} else
		goto st396;
	goto st387;
tr493:
#line 76 "ext/dtext/dtext.cpp.rl"
	{ sm->c2 = sm->p; }
#line 78 "ext/dtext/dtext.cpp.rl"
	{ sm->d2 = sm->p; }
	goto st397;
st397:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof397;
case 397:
#line 9224 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto st397;
		case 32: goto st397;
		case 93: goto st398;
		case 124: goto tr185;
	}
	if ( 10 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr185;
	goto st387;
tr491:
#line 77 "ext/dtext/dtext.cpp.rl"
	{ sm->d1 = sm->p; }
#line 78 "ext/dtext/dtext.cpp.rl"
	{ sm->d2 = sm->p; }
	goto st398;
tr488:
#line 74 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
#line 77 "ext/dtext/dtext.cpp.rl"
	{ sm->d1 = sm->p; }
#line 78 "ext/dtext/dtext.cpp.rl"
	{ sm->d2 = sm->p; }
	goto st398;
tr497:
#line 76 "ext/dtext/dtext.cpp.rl"
	{ sm->c2 = sm->p; }
#line 78 "ext/dtext/dtext.cpp.rl"
	{ sm->d2 = sm->p; }
	goto st398;
tr526:
#line 74 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
#line 78 "ext/dtext/dtext.cpp.rl"
	{ sm->d2 = sm->p; }
	goto st398;
st398:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof398;
case 398:
#line 9264 "ext/dtext/dtext.cpp"
	if ( (*( sm->p)) == 93 )
		goto st1173;
	goto tr185;
st1173:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1173;
case 1173:
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1558;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1558;
	} else
		goto tr1558;
	goto tr1550;
tr1558:
#line 79 "ext/dtext/dtext.cpp.rl"
	{ sm->e1 = sm->p; }
	goto st1174;
st1174:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1174;
case 1174:
#line 9289 "ext/dtext/dtext.cpp"
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st1174;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st1174;
	} else
		goto st1174;
	goto tr1552;
tr494:
#line 76 "ext/dtext/dtext.cpp.rl"
	{ sm->c2 = sm->p; }
#line 78 "ext/dtext/dtext.cpp.rl"
	{ sm->d2 = sm->p; }
	goto st399;
st399:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof399;
case 399:
#line 9309 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto st397;
		case 32: goto st399;
		case 45: goto st400;
		case 93: goto st398;
		case 95: goto st400;
		case 124: goto tr185;
	}
	if ( (*( sm->p)) < 48 ) {
		if ( 10 <= (*( sm->p)) && (*( sm->p)) <= 13 )
			goto tr185;
	} else if ( (*( sm->p)) > 57 ) {
		if ( (*( sm->p)) > 90 ) {
			if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
				goto st396;
		} else if ( (*( sm->p)) >= 65 )
			goto st396;
	} else
		goto st396;
	goto st387;
st400:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof400;
case 400:
	switch( (*( sm->p)) ) {
		case 9: goto tr479;
		case 32: goto tr502;
		case 45: goto st400;
		case 93: goto tr480;
		case 95: goto st400;
		case 124: goto tr185;
	}
	if ( (*( sm->p)) < 48 ) {
		if ( 10 <= (*( sm->p)) && (*( sm->p)) <= 13 )
			goto tr185;
	} else if ( (*( sm->p)) > 57 ) {
		if ( (*( sm->p)) > 90 ) {
			if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
				goto st396;
		} else if ( (*( sm->p)) >= 65 )
			goto st396;
	} else
		goto st396;
	goto st387;
tr502:
#line 78 "ext/dtext/dtext.cpp.rl"
	{ sm->d2 = sm->p; }
	goto st401;
st401:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof401;
case 401:
#line 9362 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto st388;
		case 32: goto st401;
		case 45: goto st400;
		case 93: goto st389;
		case 95: goto st400;
		case 124: goto tr185;
	}
	if ( (*( sm->p)) < 48 ) {
		if ( 10 <= (*( sm->p)) && (*( sm->p)) <= 13 )
			goto tr185;
	} else if ( (*( sm->p)) > 57 ) {
		if ( (*( sm->p)) > 90 ) {
			if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
				goto st396;
		} else if ( (*( sm->p)) >= 65 )
			goto st396;
	} else
		goto st396;
	goto st387;
tr452:
#line 73 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st402;
st402:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof402;
case 402:
#line 9391 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto tr457;
		case 32: goto tr457;
		case 35: goto tr459;
		case 93: goto tr460;
		case 124: goto tr504;
	}
	if ( 10 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto st381;
	goto st379;
tr504:
#line 74 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
	goto st403;
st403:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof403;
case 403:
#line 9410 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto tr476;
		case 32: goto tr476;
		case 62: goto tr505;
		case 93: goto tr477;
		case 124: goto tr185;
	}
	if ( 10 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr185;
	goto tr475;
tr505:
#line 77 "ext/dtext/dtext.cpp.rl"
	{ sm->d1 = sm->p; }
	goto st404;
st404:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof404;
case 404:
#line 9429 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto tr479;
		case 32: goto tr479;
		case 93: goto tr480;
		case 95: goto st405;
		case 124: goto tr185;
	}
	if ( 10 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr185;
	goto st387;
st405:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof405;
case 405:
	switch( (*( sm->p)) ) {
		case 9: goto tr479;
		case 32: goto tr479;
		case 60: goto st406;
		case 93: goto tr480;
		case 124: goto tr185;
	}
	if ( 10 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr185;
	goto st387;
st406:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof406;
case 406:
	switch( (*( sm->p)) ) {
		case 9: goto tr479;
		case 32: goto tr479;
		case 93: goto tr480;
		case 124: goto st407;
	}
	if ( 10 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr185;
	goto st387;
st407:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof407;
case 407:
	if ( (*( sm->p)) == 62 )
		goto st408;
	goto tr185;
st408:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof408;
case 408:
	switch( (*( sm->p)) ) {
		case 9: goto tr510;
		case 32: goto tr510;
		case 35: goto tr511;
		case 93: goto tr460;
	}
	goto tr185;
tr510:
#line 74 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
	goto st409;
st409:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof409;
case 409:
#line 9493 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto st409;
		case 32: goto st409;
		case 35: goto st410;
		case 93: goto st385;
	}
	goto tr185;
tr511:
#line 74 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
	goto st410;
st410:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof410;
case 410:
#line 9509 "ext/dtext/dtext.cpp"
	if ( 65 <= (*( sm->p)) && (*( sm->p)) <= 90 )
		goto tr514;
	goto tr185;
tr514:
#line 75 "ext/dtext/dtext.cpp.rl"
	{ sm->c1 = sm->p; }
	goto st411;
st411:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof411;
case 411:
#line 9521 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto tr515;
		case 32: goto tr516;
		case 45: goto st414;
		case 93: goto tr471;
		case 95: goto st414;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st411;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st411;
	} else
		goto st411;
	goto tr185;
tr515:
#line 76 "ext/dtext/dtext.cpp.rl"
	{ sm->c2 = sm->p; }
	goto st412;
st412:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof412;
case 412:
#line 9546 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto st412;
		case 32: goto st412;
		case 93: goto st385;
	}
	goto tr185;
tr516:
#line 76 "ext/dtext/dtext.cpp.rl"
	{ sm->c2 = sm->p; }
	goto st413;
st413:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof413;
case 413:
#line 9561 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto st412;
		case 32: goto st413;
		case 45: goto st414;
		case 93: goto st385;
		case 95: goto st414;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st411;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st411;
	} else
		goto st411;
	goto tr185;
st414:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof414;
case 414:
	switch( (*( sm->p)) ) {
		case 32: goto st414;
		case 45: goto st414;
		case 95: goto st414;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st411;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st411;
	} else
		goto st411;
	goto tr185;
tr453:
#line 73 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st415;
st415:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof415;
case 415:
#line 9604 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto tr457;
		case 32: goto tr457;
		case 35: goto tr459;
		case 58: goto st392;
		case 93: goto tr460;
		case 124: goto tr522;
	}
	if ( 10 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto st381;
	goto st379;
tr522:
#line 74 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
	goto st416;
st416:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof416;
case 416:
#line 9624 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto tr476;
		case 32: goto tr476;
		case 51: goto tr523;
		case 93: goto tr477;
		case 124: goto tr185;
	}
	if ( 10 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr185;
	goto tr475;
tr523:
#line 77 "ext/dtext/dtext.cpp.rl"
	{ sm->d1 = sm->p; }
	goto st417;
st417:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof417;
case 417:
#line 9643 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto tr524;
		case 32: goto tr524;
		case 35: goto tr525;
		case 93: goto tr526;
		case 124: goto tr185;
	}
	if ( 10 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr185;
	goto st387;
tr524:
#line 74 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
#line 78 "ext/dtext/dtext.cpp.rl"
	{ sm->d2 = sm->p; }
	goto st418;
st418:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof418;
case 418:
#line 9664 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto st418;
		case 32: goto st418;
		case 35: goto st395;
		case 93: goto st398;
		case 124: goto tr185;
	}
	if ( 10 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr185;
	goto st387;
tr454:
#line 73 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st419;
st419:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof419;
case 419:
#line 9683 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto tr457;
		case 32: goto tr457;
		case 35: goto tr459;
		case 93: goto tr460;
		case 124: goto tr529;
	}
	if ( 10 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto st381;
	goto st379;
tr529:
#line 74 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
	goto st420;
st420:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof420;
case 420:
#line 9702 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto tr476;
		case 32: goto tr476;
		case 93: goto tr477;
		case 124: goto st421;
	}
	if ( 10 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr185;
	goto tr475;
st421:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof421;
case 421:
	if ( (*( sm->p)) == 47 )
		goto st408;
	goto tr185;
tr455:
#line 73 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st422;
st422:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof422;
case 422:
#line 9727 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 95: goto st426;
		case 119: goto st427;
		case 124: goto st428;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st423;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st423;
	} else
		goto st423;
	goto tr185;
st423:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof423;
case 423:
	switch( (*( sm->p)) ) {
		case 9: goto tr535;
		case 32: goto tr535;
		case 35: goto tr536;
		case 93: goto tr460;
		case 124: goto tr461;
	}
	goto tr185;
tr535:
#line 74 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
	goto st424;
st424:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof424;
case 424:
#line 9762 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto st424;
		case 32: goto st424;
		case 35: goto st425;
		case 93: goto st385;
		case 124: goto st386;
	}
	goto tr185;
tr536:
#line 74 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
	goto st425;
st425:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof425;
case 425:
#line 9779 "ext/dtext/dtext.cpp"
	if ( 65 <= (*( sm->p)) && (*( sm->p)) <= 90 )
		goto tr466;
	goto tr185;
st426:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof426;
case 426:
	if ( (*( sm->p)) == 124 )
		goto st423;
	goto tr185;
st427:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof427;
case 427:
	switch( (*( sm->p)) ) {
		case 9: goto tr535;
		case 32: goto tr535;
		case 35: goto tr536;
		case 93: goto tr460;
		case 124: goto tr485;
	}
	goto tr185;
st428:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof428;
case 428:
	if ( (*( sm->p)) == 95 )
		goto st429;
	goto tr185;
st429:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof429;
case 429:
	if ( (*( sm->p)) == 124 )
		goto st426;
	goto tr185;
tr1549:
#line 72 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
	goto st430;
st430:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof430;
case 430:
#line 9824 "ext/dtext/dtext.cpp"
	if ( (*( sm->p)) == 123 )
		goto st431;
	goto tr188;
st431:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof431;
case 431:
	switch( (*( sm->p)) ) {
		case 0: goto tr185;
		case 9: goto st431;
		case 32: goto st431;
		case 45: goto tr542;
		case 58: goto tr543;
		case 60: goto tr544;
		case 62: goto tr545;
		case 92: goto tr546;
		case 124: goto tr547;
		case 126: goto tr542;
	}
	if ( (*( sm->p)) > 13 ) {
		if ( 123 <= (*( sm->p)) && (*( sm->p)) <= 125 )
			goto tr185;
	} else if ( (*( sm->p)) >= 10 )
		goto tr185;
	goto tr541;
tr541:
#line 73 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st432;
st432:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof432;
case 432:
#line 9858 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr185;
		case 9: goto tr549;
		case 32: goto tr549;
		case 123: goto tr185;
		case 124: goto tr550;
		case 125: goto tr551;
	}
	if ( 10 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr185;
	goto st432;
tr549:
#line 74 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
	goto st433;
st433:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof433;
case 433:
#line 9878 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr185;
		case 9: goto st433;
		case 32: goto st433;
		case 45: goto st434;
		case 58: goto st435;
		case 60: goto st470;
		case 62: goto st471;
		case 92: goto st473;
		case 123: goto tr185;
		case 124: goto st464;
		case 125: goto st442;
		case 126: goto st434;
	}
	if ( 10 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr185;
	goto st432;
tr542:
#line 73 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st434;
st434:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof434;
case 434:
#line 9904 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr185;
		case 9: goto tr549;
		case 32: goto tr549;
		case 58: goto st435;
		case 60: goto st470;
		case 62: goto st471;
		case 92: goto st473;
		case 123: goto tr185;
		case 124: goto tr560;
		case 125: goto tr551;
	}
	if ( 10 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr185;
	goto st432;
tr543:
#line 73 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st435;
st435:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof435;
case 435:
#line 9928 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr185;
		case 9: goto tr549;
		case 32: goto tr549;
		case 123: goto st436;
		case 124: goto tr562;
		case 125: goto tr563;
	}
	if ( 10 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr185;
	goto st432;
st436:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof436;
case 436:
	switch( (*( sm->p)) ) {
		case 9: goto tr549;
		case 32: goto tr549;
		case 124: goto tr550;
		case 125: goto tr551;
	}
	goto tr185;
tr550:
#line 74 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
	goto st437;
tr565:
#line 75 "ext/dtext/dtext.cpp.rl"
	{ sm->c1 = sm->p; }
#line 76 "ext/dtext/dtext.cpp.rl"
	{ sm->c2 = sm->p; }
	goto st437;
tr577:
#line 74 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
#line 75 "ext/dtext/dtext.cpp.rl"
	{ sm->c1 = sm->p; }
	goto st437;
st437:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof437;
case 437:
#line 9971 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr185;
		case 9: goto tr565;
		case 10: goto tr185;
		case 13: goto tr185;
		case 32: goto tr565;
		case 125: goto tr567;
	}
	if ( 11 <= (*( sm->p)) && (*( sm->p)) <= 12 )
		goto tr566;
	goto tr564;
tr564:
#line 75 "ext/dtext/dtext.cpp.rl"
	{ sm->c1 = sm->p; }
	goto st438;
st438:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof438;
case 438:
#line 9991 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr185;
		case 9: goto tr569;
		case 10: goto tr185;
		case 13: goto tr185;
		case 32: goto tr569;
		case 125: goto tr571;
	}
	if ( 11 <= (*( sm->p)) && (*( sm->p)) <= 12 )
		goto st440;
	goto st438;
tr569:
#line 76 "ext/dtext/dtext.cpp.rl"
	{ sm->c2 = sm->p; }
	goto st439;
st439:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof439;
case 439:
#line 10011 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr185;
		case 9: goto st439;
		case 10: goto tr185;
		case 13: goto tr185;
		case 32: goto st439;
		case 125: goto st441;
	}
	if ( 11 <= (*( sm->p)) && (*( sm->p)) <= 12 )
		goto st440;
	goto st438;
tr566:
#line 75 "ext/dtext/dtext.cpp.rl"
	{ sm->c1 = sm->p; }
	goto st440;
st440:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof440;
case 440:
#line 10031 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr185;
		case 10: goto tr185;
		case 13: goto tr185;
		case 32: goto st440;
		case 125: goto tr185;
	}
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 12 )
		goto st440;
	goto st438;
tr571:
#line 76 "ext/dtext/dtext.cpp.rl"
	{ sm->c2 = sm->p; }
	goto st441;
tr567:
#line 75 "ext/dtext/dtext.cpp.rl"
	{ sm->c1 = sm->p; }
#line 76 "ext/dtext/dtext.cpp.rl"
	{ sm->c2 = sm->p; }
	goto st441;
st441:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof441;
case 441:
#line 10056 "ext/dtext/dtext.cpp"
	if ( (*( sm->p)) == 125 )
		goto st1175;
	goto tr185;
st1175:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1175;
case 1175:
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1561;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1561;
	} else
		goto tr1561;
	goto tr1560;
tr1561:
#line 77 "ext/dtext/dtext.cpp.rl"
	{ sm->d1 = sm->p; }
	goto st1176;
st1176:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1176;
case 1176:
#line 10081 "ext/dtext/dtext.cpp"
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st1176;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st1176;
	} else
		goto st1176;
	goto tr1562;
tr551:
#line 74 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
	goto st442;
st442:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof442;
case 442:
#line 10099 "ext/dtext/dtext.cpp"
	if ( (*( sm->p)) == 125 )
		goto st1177;
	goto tr185;
tr1570:
#line 77 "ext/dtext/dtext.cpp.rl"
	{ sm->d1 = sm->p; }
#line 78 "ext/dtext/dtext.cpp.rl"
	{ sm->d2 = sm->p; }
	goto st1177;
st1177:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1177;
case 1177:
#line 10113 "ext/dtext/dtext.cpp"
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1565;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1565;
	} else
		goto tr1565;
	goto tr1564;
tr1565:
#line 77 "ext/dtext/dtext.cpp.rl"
	{ sm->d1 = sm->p; }
	goto st1178;
st1178:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1178;
case 1178:
#line 10131 "ext/dtext/dtext.cpp"
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st1178;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st1178;
	} else
		goto st1178;
	goto tr1566;
tr562:
#line 74 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
	goto st443;
st443:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof443;
case 443:
#line 10149 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr185;
		case 9: goto tr576;
		case 10: goto tr185;
		case 13: goto tr185;
		case 32: goto tr576;
		case 124: goto tr577;
		case 125: goto tr578;
	}
	if ( 11 <= (*( sm->p)) && (*( sm->p)) <= 12 )
		goto tr566;
	goto tr564;
tr580:
#line 75 "ext/dtext/dtext.cpp.rl"
	{ sm->c1 = sm->p; }
#line 76 "ext/dtext/dtext.cpp.rl"
	{ sm->c2 = sm->p; }
	goto st444;
tr576:
#line 74 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
#line 75 "ext/dtext/dtext.cpp.rl"
	{ sm->c1 = sm->p; }
#line 76 "ext/dtext/dtext.cpp.rl"
	{ sm->c2 = sm->p; }
	goto st444;
st444:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof444;
case 444:
#line 10180 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr185;
		case 9: goto tr580;
		case 10: goto tr185;
		case 13: goto tr185;
		case 32: goto tr580;
		case 45: goto tr581;
		case 58: goto tr582;
		case 60: goto tr583;
		case 62: goto tr584;
		case 92: goto tr585;
		case 123: goto tr564;
		case 124: goto tr586;
		case 125: goto tr587;
		case 126: goto tr581;
	}
	if ( 11 <= (*( sm->p)) && (*( sm->p)) <= 12 )
		goto tr566;
	goto tr579;
tr579:
#line 75 "ext/dtext/dtext.cpp.rl"
	{ sm->c1 = sm->p; }
	goto st445;
st445:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof445;
case 445:
#line 10208 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr185;
		case 9: goto tr589;
		case 10: goto tr185;
		case 13: goto tr185;
		case 32: goto tr589;
		case 123: goto st438;
		case 124: goto tr550;
		case 125: goto tr590;
	}
	if ( 11 <= (*( sm->p)) && (*( sm->p)) <= 12 )
		goto st440;
	goto st445;
tr589:
#line 74 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
#line 76 "ext/dtext/dtext.cpp.rl"
	{ sm->c2 = sm->p; }
	goto st446;
st446:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof446;
case 446:
#line 10232 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr185;
		case 9: goto st446;
		case 10: goto tr185;
		case 13: goto tr185;
		case 32: goto st446;
		case 45: goto st447;
		case 58: goto st448;
		case 60: goto st452;
		case 62: goto st458;
		case 92: goto st461;
		case 123: goto st438;
		case 124: goto st464;
		case 125: goto st450;
		case 126: goto st447;
	}
	if ( 11 <= (*( sm->p)) && (*( sm->p)) <= 12 )
		goto st440;
	goto st445;
tr581:
#line 75 "ext/dtext/dtext.cpp.rl"
	{ sm->c1 = sm->p; }
	goto st447;
st447:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof447;
case 447:
#line 10260 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr185;
		case 9: goto tr589;
		case 10: goto tr185;
		case 13: goto tr185;
		case 32: goto tr589;
		case 58: goto st448;
		case 60: goto st452;
		case 62: goto st458;
		case 92: goto st461;
		case 123: goto st438;
		case 124: goto tr560;
		case 125: goto tr590;
	}
	if ( 11 <= (*( sm->p)) && (*( sm->p)) <= 12 )
		goto st440;
	goto st445;
tr582:
#line 75 "ext/dtext/dtext.cpp.rl"
	{ sm->c1 = sm->p; }
	goto st448;
st448:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof448;
case 448:
#line 10286 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr185;
		case 9: goto tr589;
		case 10: goto tr185;
		case 13: goto tr185;
		case 32: goto tr589;
		case 123: goto st449;
		case 124: goto tr562;
		case 125: goto tr599;
	}
	if ( 11 <= (*( sm->p)) && (*( sm->p)) <= 12 )
		goto st440;
	goto st445;
tr609:
#line 75 "ext/dtext/dtext.cpp.rl"
	{ sm->c1 = sm->p; }
	goto st449;
st449:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof449;
case 449:
#line 10308 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr185;
		case 9: goto tr589;
		case 10: goto tr185;
		case 13: goto tr185;
		case 32: goto tr589;
		case 124: goto tr550;
		case 125: goto tr590;
	}
	if ( 11 <= (*( sm->p)) && (*( sm->p)) <= 12 )
		goto st440;
	goto st438;
tr587:
#line 75 "ext/dtext/dtext.cpp.rl"
	{ sm->c1 = sm->p; }
#line 76 "ext/dtext/dtext.cpp.rl"
	{ sm->c2 = sm->p; }
	goto st450;
tr578:
#line 74 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
#line 75 "ext/dtext/dtext.cpp.rl"
	{ sm->c1 = sm->p; }
#line 76 "ext/dtext/dtext.cpp.rl"
	{ sm->c2 = sm->p; }
	goto st450;
tr590:
#line 74 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
#line 76 "ext/dtext/dtext.cpp.rl"
	{ sm->c2 = sm->p; }
	goto st450;
st450:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof450;
case 450:
#line 10345 "ext/dtext/dtext.cpp"
	if ( (*( sm->p)) == 125 )
		goto st1179;
	goto tr185;
st1179:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1179;
case 1179:
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1568;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1568;
	} else
		goto tr1568;
	goto tr1564;
tr1568:
#line 77 "ext/dtext/dtext.cpp.rl"
	{ sm->d1 = sm->p; }
	goto st1180;
st1180:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1180;
case 1180:
#line 10370 "ext/dtext/dtext.cpp"
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st1180;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st1180;
	} else
		goto st1180;
	goto tr1566;
tr599:
#line 74 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
#line 76 "ext/dtext/dtext.cpp.rl"
	{ sm->c2 = sm->p; }
	goto st451;
st451:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof451;
case 451:
#line 10390 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto tr549;
		case 32: goto tr549;
		case 124: goto tr550;
		case 125: goto tr601;
	}
	goto tr185;
tr601:
#line 74 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
	goto st1181;
st1181:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1181;
case 1181:
#line 10406 "ext/dtext/dtext.cpp"
	if ( (*( sm->p)) == 125 )
		goto tr1570;
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1568;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1568;
	} else
		goto tr1568;
	goto tr1564;
tr583:
#line 75 "ext/dtext/dtext.cpp.rl"
	{ sm->c1 = sm->p; }
	goto st452;
st452:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof452;
case 452:
#line 10426 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr185;
		case 9: goto tr589;
		case 10: goto tr185;
		case 13: goto tr185;
		case 32: goto tr589;
		case 123: goto st438;
		case 124: goto tr602;
		case 125: goto tr590;
	}
	if ( 11 <= (*( sm->p)) && (*( sm->p)) <= 12 )
		goto st440;
	goto st445;
tr602:
#line 74 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
	goto st453;
st453:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof453;
case 453:
#line 10448 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr185;
		case 9: goto tr565;
		case 10: goto tr185;
		case 13: goto tr185;
		case 32: goto tr565;
		case 62: goto tr603;
		case 125: goto tr567;
	}
	if ( 11 <= (*( sm->p)) && (*( sm->p)) <= 12 )
		goto tr566;
	goto tr564;
tr603:
#line 75 "ext/dtext/dtext.cpp.rl"
	{ sm->c1 = sm->p; }
	goto st454;
st454:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof454;
case 454:
#line 10469 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr185;
		case 9: goto tr569;
		case 10: goto tr185;
		case 13: goto tr185;
		case 32: goto tr569;
		case 95: goto st455;
		case 125: goto tr571;
	}
	if ( 11 <= (*( sm->p)) && (*( sm->p)) <= 12 )
		goto st440;
	goto st438;
st455:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof455;
case 455:
	switch( (*( sm->p)) ) {
		case 0: goto tr185;
		case 9: goto tr569;
		case 10: goto tr185;
		case 13: goto tr185;
		case 32: goto tr569;
		case 60: goto st456;
		case 125: goto tr571;
	}
	if ( 11 <= (*( sm->p)) && (*( sm->p)) <= 12 )
		goto st440;
	goto st438;
st456:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof456;
case 456:
	switch( (*( sm->p)) ) {
		case 0: goto tr185;
		case 9: goto tr569;
		case 10: goto tr185;
		case 13: goto tr185;
		case 32: goto tr569;
		case 124: goto st457;
		case 125: goto tr571;
	}
	if ( 11 <= (*( sm->p)) && (*( sm->p)) <= 12 )
		goto st440;
	goto st438;
st457:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof457;
case 457:
	switch( (*( sm->p)) ) {
		case 0: goto tr185;
		case 9: goto tr569;
		case 10: goto tr185;
		case 13: goto tr185;
		case 32: goto tr569;
		case 62: goto st449;
		case 125: goto tr571;
	}
	if ( 11 <= (*( sm->p)) && (*( sm->p)) <= 12 )
		goto st440;
	goto st438;
tr584:
#line 75 "ext/dtext/dtext.cpp.rl"
	{ sm->c1 = sm->p; }
	goto st458;
st458:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof458;
case 458:
#line 10538 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr185;
		case 9: goto tr589;
		case 10: goto tr185;
		case 13: goto tr185;
		case 32: goto tr589;
		case 58: goto st459;
		case 123: goto st438;
		case 124: goto tr608;
		case 125: goto tr590;
	}
	if ( 11 <= (*( sm->p)) && (*( sm->p)) <= 12 )
		goto st440;
	goto st445;
st459:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof459;
case 459:
	switch( (*( sm->p)) ) {
		case 0: goto tr185;
		case 9: goto tr589;
		case 10: goto tr185;
		case 13: goto tr185;
		case 32: goto tr589;
		case 123: goto st438;
		case 124: goto tr562;
		case 125: goto tr590;
	}
	if ( 11 <= (*( sm->p)) && (*( sm->p)) <= 12 )
		goto st440;
	goto st445;
tr608:
#line 74 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
	goto st460;
st460:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof460;
case 460:
#line 10578 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr185;
		case 9: goto tr565;
		case 10: goto tr185;
		case 13: goto tr185;
		case 32: goto tr565;
		case 51: goto tr609;
		case 125: goto tr567;
	}
	if ( 11 <= (*( sm->p)) && (*( sm->p)) <= 12 )
		goto tr566;
	goto tr564;
tr585:
#line 75 "ext/dtext/dtext.cpp.rl"
	{ sm->c1 = sm->p; }
	goto st461;
st461:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof461;
case 461:
#line 10599 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr185;
		case 9: goto tr589;
		case 10: goto tr185;
		case 13: goto tr185;
		case 32: goto tr589;
		case 123: goto st438;
		case 124: goto tr610;
		case 125: goto tr590;
	}
	if ( 11 <= (*( sm->p)) && (*( sm->p)) <= 12 )
		goto st440;
	goto st445;
tr610:
#line 74 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
	goto st462;
st462:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof462;
case 462:
#line 10621 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr185;
		case 9: goto tr565;
		case 10: goto tr185;
		case 13: goto tr185;
		case 32: goto tr565;
		case 124: goto tr611;
		case 125: goto tr567;
	}
	if ( 11 <= (*( sm->p)) && (*( sm->p)) <= 12 )
		goto tr566;
	goto tr564;
tr611:
#line 75 "ext/dtext/dtext.cpp.rl"
	{ sm->c1 = sm->p; }
	goto st463;
st463:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof463;
case 463:
#line 10642 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr185;
		case 9: goto tr569;
		case 10: goto tr185;
		case 13: goto tr185;
		case 32: goto tr569;
		case 47: goto st449;
		case 125: goto tr571;
	}
	if ( 11 <= (*( sm->p)) && (*( sm->p)) <= 12 )
		goto st440;
	goto st438;
tr560:
#line 74 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
	goto st464;
tr586:
#line 75 "ext/dtext/dtext.cpp.rl"
	{ sm->c1 = sm->p; }
	goto st464;
st464:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof464;
case 464:
#line 10667 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr185;
		case 9: goto tr565;
		case 10: goto tr185;
		case 13: goto tr185;
		case 32: goto tr565;
		case 95: goto tr612;
		case 119: goto tr613;
		case 124: goto tr614;
		case 125: goto tr567;
	}
	if ( (*( sm->p)) < 48 ) {
		if ( 11 <= (*( sm->p)) && (*( sm->p)) <= 12 )
			goto tr566;
	} else if ( (*( sm->p)) > 57 ) {
		if ( (*( sm->p)) > 90 ) {
			if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
				goto tr609;
		} else if ( (*( sm->p)) >= 65 )
			goto tr609;
	} else
		goto tr609;
	goto tr564;
tr612:
#line 75 "ext/dtext/dtext.cpp.rl"
	{ sm->c1 = sm->p; }
	goto st465;
st465:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof465;
case 465:
#line 10699 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr185;
		case 9: goto tr569;
		case 10: goto tr185;
		case 13: goto tr185;
		case 32: goto tr569;
		case 124: goto st449;
		case 125: goto tr571;
	}
	if ( 11 <= (*( sm->p)) && (*( sm->p)) <= 12 )
		goto st440;
	goto st438;
tr613:
#line 75 "ext/dtext/dtext.cpp.rl"
	{ sm->c1 = sm->p; }
	goto st466;
st466:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof466;
case 466:
#line 10720 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr185;
		case 9: goto tr589;
		case 10: goto tr185;
		case 13: goto tr185;
		case 32: goto tr589;
		case 124: goto tr562;
		case 125: goto tr590;
	}
	if ( 11 <= (*( sm->p)) && (*( sm->p)) <= 12 )
		goto st440;
	goto st438;
tr614:
#line 75 "ext/dtext/dtext.cpp.rl"
	{ sm->c1 = sm->p; }
	goto st467;
st467:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof467;
case 467:
#line 10741 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr185;
		case 9: goto tr569;
		case 10: goto tr185;
		case 13: goto tr185;
		case 32: goto tr569;
		case 95: goto st468;
		case 125: goto tr571;
	}
	if ( 11 <= (*( sm->p)) && (*( sm->p)) <= 12 )
		goto st440;
	goto st438;
st468:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof468;
case 468:
	switch( (*( sm->p)) ) {
		case 0: goto tr185;
		case 9: goto tr569;
		case 10: goto tr185;
		case 13: goto tr185;
		case 32: goto tr569;
		case 124: goto st465;
		case 125: goto tr571;
	}
	if ( 11 <= (*( sm->p)) && (*( sm->p)) <= 12 )
		goto st440;
	goto st438;
tr563:
#line 74 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
	goto st469;
st469:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof469;
case 469:
#line 10778 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto tr549;
		case 32: goto tr549;
		case 124: goto tr550;
		case 125: goto tr617;
	}
	goto tr185;
tr617:
#line 74 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
	goto st1182;
st1182:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1182;
case 1182:
#line 10794 "ext/dtext/dtext.cpp"
	if ( (*( sm->p)) == 125 )
		goto st1177;
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1565;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1565;
	} else
		goto tr1565;
	goto tr1564;
tr544:
#line 73 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st470;
st470:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof470;
case 470:
#line 10814 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr185;
		case 9: goto tr549;
		case 32: goto tr549;
		case 123: goto tr185;
		case 124: goto tr602;
		case 125: goto tr551;
	}
	if ( 10 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr185;
	goto st432;
tr545:
#line 73 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st471;
st471:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof471;
case 471:
#line 10834 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr185;
		case 9: goto tr549;
		case 32: goto tr549;
		case 58: goto st472;
		case 123: goto tr185;
		case 124: goto tr608;
		case 125: goto tr551;
	}
	if ( 10 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr185;
	goto st432;
st472:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof472;
case 472:
	switch( (*( sm->p)) ) {
		case 0: goto tr185;
		case 9: goto tr549;
		case 32: goto tr549;
		case 123: goto tr185;
		case 124: goto tr562;
		case 125: goto tr551;
	}
	if ( 10 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr185;
	goto st432;
tr546:
#line 73 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st473;
st473:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof473;
case 473:
#line 10870 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr185;
		case 9: goto tr549;
		case 32: goto tr549;
		case 123: goto tr185;
		case 124: goto tr610;
		case 125: goto tr551;
	}
	if ( 10 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr185;
	goto st432;
tr547:
#line 73 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st474;
st474:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof474;
case 474:
#line 10890 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 95: goto st475;
		case 119: goto st476;
		case 124: goto st477;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st436;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st436;
	} else
		goto st436;
	goto tr185;
st475:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof475;
case 475:
	if ( (*( sm->p)) == 124 )
		goto st436;
	goto tr185;
st476:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof476;
case 476:
	switch( (*( sm->p)) ) {
		case 9: goto tr549;
		case 32: goto tr549;
		case 124: goto tr562;
		case 125: goto tr551;
	}
	goto tr185;
st477:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof477;
case 477:
	if ( (*( sm->p)) == 95 )
		goto st478;
	goto tr185;
st478:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof478;
case 478:
	if ( (*( sm->p)) == 124 )
		goto st475;
	goto tr185;
st0:
 sm->cs = 0;
	goto _out;
tr1503:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
#line 540 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1183;
st1183:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1183;
case 1183:
#line 10952 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 76: goto tr1571;
		case 80: goto tr1572;
		case 82: goto tr1573;
		case 91: goto tr1548;
		case 108: goto tr1571;
		case 112: goto tr1572;
		case 114: goto tr1573;
		case 123: goto tr1549;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1547;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1547;
	} else
		goto tr1547;
	goto tr1525;
tr1571:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 540 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1184;
st1184:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1184;
case 1184:
#line 10982 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 73: goto tr1574;
		case 91: goto tr1548;
		case 105: goto tr1574;
		case 123: goto tr1549;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1547;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1547;
	} else
		goto tr1547;
	goto tr1525;
tr1574:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 540 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1185;
st1185:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1185;
case 1185:
#line 11008 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 65: goto tr1575;
		case 91: goto tr1548;
		case 97: goto tr1575;
		case 123: goto tr1549;
	}
	if ( (*( sm->p)) < 66 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1547;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 98 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1547;
	} else
		goto tr1547;
	goto tr1525;
tr1575:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 540 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1186;
st1186:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1186;
case 1186:
#line 11034 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 83: goto tr1576;
		case 91: goto tr1548;
		case 115: goto tr1576;
		case 123: goto tr1549;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1547;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1547;
	} else
		goto tr1547;
	goto tr1525;
tr1576:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 540 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1187;
st1187:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1187;
case 1187:
#line 11060 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 32: goto st479;
		case 91: goto tr1548;
		case 123: goto tr1549;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1547;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1547;
	} else
		goto tr1547;
	goto tr1525;
st479:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof479;
case 479:
	if ( (*( sm->p)) == 35 )
		goto st480;
	goto tr188;
st480:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof480;
case 480:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr624;
	goto tr188;
tr624:
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st1188;
st1188:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1188;
case 1188:
#line 11097 "ext/dtext/dtext.cpp"
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto st1188;
	goto tr1578;
tr1572:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 540 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1189;
st1189:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1189;
case 1189:
#line 11111 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 80: goto tr1580;
		case 91: goto tr1548;
		case 112: goto tr1580;
		case 123: goto tr1549;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1547;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1547;
	} else
		goto tr1547;
	goto tr1525;
tr1580:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 540 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1190;
st1190:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1190;
case 1190:
#line 11137 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 69: goto tr1581;
		case 91: goto tr1548;
		case 101: goto tr1581;
		case 123: goto tr1549;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1547;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1547;
	} else
		goto tr1547;
	goto tr1525;
tr1581:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 540 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1191;
st1191:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1191;
case 1191:
#line 11163 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 65: goto tr1582;
		case 91: goto tr1548;
		case 97: goto tr1582;
		case 123: goto tr1549;
	}
	if ( (*( sm->p)) < 66 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1547;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 98 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1547;
	} else
		goto tr1547;
	goto tr1525;
tr1582:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 540 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1192;
st1192:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1192;
case 1192:
#line 11189 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 76: goto tr1583;
		case 91: goto tr1548;
		case 108: goto tr1583;
		case 123: goto tr1549;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1547;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1547;
	} else
		goto tr1547;
	goto tr1525;
tr1583:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 540 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1193;
st1193:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1193;
case 1193:
#line 11215 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 32: goto st481;
		case 91: goto tr1548;
		case 123: goto tr1549;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1547;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1547;
	} else
		goto tr1547;
	goto tr1525;
st481:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof481;
case 481:
	if ( (*( sm->p)) == 35 )
		goto st482;
	goto tr188;
st482:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof482;
case 482:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr626;
	goto tr188;
tr626:
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st1194;
st1194:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1194;
case 1194:
#line 11252 "ext/dtext/dtext.cpp"
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto st1194;
	goto tr1585;
tr1573:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 540 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1195;
st1195:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1195;
case 1195:
#line 11266 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 84: goto tr1587;
		case 91: goto tr1548;
		case 116: goto tr1587;
		case 123: goto tr1549;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1547;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1547;
	} else
		goto tr1547;
	goto tr1525;
tr1587:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 540 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1196;
st1196:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1196;
case 1196:
#line 11292 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 73: goto tr1588;
		case 83: goto tr1589;
		case 91: goto tr1548;
		case 105: goto tr1588;
		case 115: goto tr1589;
		case 123: goto tr1549;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1547;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1547;
	} else
		goto tr1547;
	goto tr1525;
tr1588:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 540 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1197;
st1197:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1197;
case 1197:
#line 11320 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 83: goto tr1590;
		case 91: goto tr1548;
		case 115: goto tr1590;
		case 123: goto tr1549;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1547;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1547;
	} else
		goto tr1547;
	goto tr1525;
tr1590:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 540 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1198;
st1198:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1198;
case 1198:
#line 11346 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 84: goto tr1591;
		case 91: goto tr1548;
		case 116: goto tr1591;
		case 123: goto tr1549;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1547;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1547;
	} else
		goto tr1547;
	goto tr1525;
tr1591:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 540 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1199;
st1199:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1199;
case 1199:
#line 11372 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 32: goto st483;
		case 91: goto tr1548;
		case 123: goto tr1549;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1547;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1547;
	} else
		goto tr1547;
	goto tr1525;
st483:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof483;
case 483:
	if ( (*( sm->p)) == 35 )
		goto st484;
	goto tr188;
st484:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof484;
case 484:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr628;
	goto tr188;
tr628:
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st1200;
st1200:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1200;
case 1200:
#line 11409 "ext/dtext/dtext.cpp"
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto st1200;
	goto tr1593;
tr1589:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 540 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1201;
st1201:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1201;
case 1201:
#line 11423 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 84: goto tr1595;
		case 91: goto tr1548;
		case 116: goto tr1595;
		case 123: goto tr1549;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1547;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1547;
	} else
		goto tr1547;
	goto tr1525;
tr1595:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 540 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1202;
st1202:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1202;
case 1202:
#line 11449 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 65: goto tr1596;
		case 91: goto tr1548;
		case 97: goto tr1596;
		case 123: goto tr1549;
	}
	if ( (*( sm->p)) < 66 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1547;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 98 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1547;
	} else
		goto tr1547;
	goto tr1525;
tr1596:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 540 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1203;
st1203:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1203;
case 1203:
#line 11475 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 84: goto tr1597;
		case 91: goto tr1548;
		case 116: goto tr1597;
		case 123: goto tr1549;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1547;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1547;
	} else
		goto tr1547;
	goto tr1525;
tr1597:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 540 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1204;
st1204:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1204;
case 1204:
#line 11501 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 73: goto tr1598;
		case 91: goto tr1548;
		case 105: goto tr1598;
		case 123: goto tr1549;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1547;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1547;
	} else
		goto tr1547;
	goto tr1525;
tr1598:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 540 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1205;
st1205:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1205;
case 1205:
#line 11527 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 79: goto tr1599;
		case 91: goto tr1548;
		case 111: goto tr1599;
		case 123: goto tr1549;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1547;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1547;
	} else
		goto tr1547;
	goto tr1525;
tr1599:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 540 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1206;
st1206:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1206;
case 1206:
#line 11553 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 78: goto tr1600;
		case 91: goto tr1548;
		case 110: goto tr1600;
		case 123: goto tr1549;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1547;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1547;
	} else
		goto tr1547;
	goto tr1525;
tr1600:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 540 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1207;
st1207:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1207;
case 1207:
#line 11579 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 32: goto st485;
		case 91: goto tr1548;
		case 123: goto tr1549;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1547;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1547;
	} else
		goto tr1547;
	goto tr1525;
st485:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof485;
case 485:
	if ( (*( sm->p)) == 35 )
		goto st486;
	goto tr188;
st486:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof486;
case 486:
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr630;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr630;
	} else
		goto tr630;
	goto tr188;
tr630:
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st1208;
st1208:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1208;
case 1208:
#line 11622 "ext/dtext/dtext.cpp"
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st1208;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st1208;
	} else
		goto st1208;
	goto tr1602;
tr1504:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
#line 540 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1209;
st1209:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1209;
case 1209:
#line 11644 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 65: goto tr1604;
		case 85: goto tr1605;
		case 91: goto tr1548;
		case 97: goto tr1604;
		case 117: goto tr1605;
		case 123: goto tr1549;
	}
	if ( (*( sm->p)) < 66 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1547;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 98 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1547;
	} else
		goto tr1547;
	goto tr1525;
tr1604:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 540 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1210;
st1210:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1210;
case 1210:
#line 11672 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 78: goto tr1606;
		case 91: goto tr1548;
		case 110: goto tr1606;
		case 123: goto tr1549;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1547;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1547;
	} else
		goto tr1547;
	goto tr1525;
tr1606:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 540 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1211;
st1211:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1211;
case 1211:
#line 11698 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 32: goto st487;
		case 91: goto tr1548;
		case 123: goto tr1549;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1547;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1547;
	} else
		goto tr1547;
	goto tr1525;
st487:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof487;
case 487:
	if ( (*( sm->p)) == 35 )
		goto st488;
	goto tr188;
st488:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof488;
case 488:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr632;
	goto tr188;
tr632:
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st1212;
st1212:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1212;
case 1212:
#line 11735 "ext/dtext/dtext.cpp"
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto st1212;
	goto tr1608;
tr1605:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 540 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1213;
st1213:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1213;
case 1213:
#line 11749 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 82: goto tr1610;
		case 91: goto tr1548;
		case 114: goto tr1610;
		case 123: goto tr1549;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1547;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1547;
	} else
		goto tr1547;
	goto tr1525;
tr1610:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 540 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1214;
st1214:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1214;
case 1214:
#line 11775 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 32: goto st489;
		case 91: goto tr1548;
		case 123: goto tr1549;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1547;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1547;
	} else
		goto tr1547;
	goto tr1525;
st489:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof489;
case 489:
	if ( (*( sm->p)) == 35 )
		goto st490;
	goto tr188;
st490:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof490;
case 490:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr634;
	goto tr188;
tr634:
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st1215;
st1215:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1215;
case 1215:
#line 11812 "ext/dtext/dtext.cpp"
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto st1215;
	goto tr1612;
tr1505:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
#line 540 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1216;
st1216:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1216;
case 1216:
#line 11828 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 79: goto tr1614;
		case 91: goto tr1548;
		case 111: goto tr1614;
		case 123: goto tr1549;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1547;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1547;
	} else
		goto tr1547;
	goto tr1525;
tr1614:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 540 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1217;
st1217:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1217;
case 1217:
#line 11854 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 77: goto tr1615;
		case 91: goto tr1548;
		case 109: goto tr1615;
		case 123: goto tr1549;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1547;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1547;
	} else
		goto tr1547;
	goto tr1525;
tr1615:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 540 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1218;
st1218:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1218;
case 1218:
#line 11880 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 77: goto tr1616;
		case 91: goto tr1548;
		case 109: goto tr1616;
		case 123: goto tr1549;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1547;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1547;
	} else
		goto tr1547;
	goto tr1525;
tr1616:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 540 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1219;
st1219:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1219;
case 1219:
#line 11906 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 69: goto tr1617;
		case 73: goto tr1618;
		case 91: goto tr1548;
		case 101: goto tr1617;
		case 105: goto tr1618;
		case 123: goto tr1549;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1547;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1547;
	} else
		goto tr1547;
	goto tr1525;
tr1617:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 540 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1220;
st1220:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1220;
case 1220:
#line 11934 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 78: goto tr1619;
		case 91: goto tr1548;
		case 110: goto tr1619;
		case 123: goto tr1549;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1547;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1547;
	} else
		goto tr1547;
	goto tr1525;
tr1619:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 540 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1221;
st1221:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1221;
case 1221:
#line 11960 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 84: goto tr1620;
		case 91: goto tr1548;
		case 116: goto tr1620;
		case 123: goto tr1549;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1547;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1547;
	} else
		goto tr1547;
	goto tr1525;
tr1620:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 540 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1222;
st1222:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1222;
case 1222:
#line 11986 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 32: goto st491;
		case 91: goto tr1548;
		case 123: goto tr1549;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1547;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1547;
	} else
		goto tr1547;
	goto tr1525;
st491:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof491;
case 491:
	if ( (*( sm->p)) == 35 )
		goto st492;
	goto tr188;
st492:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof492;
case 492:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr636;
	goto tr188;
tr636:
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st1223;
st1223:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1223;
case 1223:
#line 12023 "ext/dtext/dtext.cpp"
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto st1223;
	goto tr1622;
tr1618:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 540 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1224;
st1224:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1224;
case 1224:
#line 12037 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 84: goto tr1624;
		case 91: goto tr1548;
		case 116: goto tr1624;
		case 123: goto tr1549;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1547;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1547;
	} else
		goto tr1547;
	goto tr1525;
tr1624:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 540 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1225;
st1225:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1225;
case 1225:
#line 12063 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 32: goto st493;
		case 91: goto tr1548;
		case 123: goto tr1549;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1547;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1547;
	} else
		goto tr1547;
	goto tr1525;
st493:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof493;
case 493:
	if ( (*( sm->p)) == 35 )
		goto st494;
	goto tr188;
st494:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof494;
case 494:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr638;
	goto tr188;
tr638:
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st1226;
st1226:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1226;
case 1226:
#line 12100 "ext/dtext/dtext.cpp"
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto st1226;
	goto tr1626;
tr1506:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
#line 540 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1227;
st1227:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1227;
case 1227:
#line 12116 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 69: goto tr1628;
		case 77: goto tr1629;
		case 91: goto tr1548;
		case 101: goto tr1628;
		case 109: goto tr1629;
		case 123: goto tr1549;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1547;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1547;
	} else
		goto tr1547;
	goto tr1525;
tr1628:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 540 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1228;
st1228:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1228;
case 1228:
#line 12144 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 86: goto tr1630;
		case 91: goto tr1548;
		case 118: goto tr1630;
		case 123: goto tr1549;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1547;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1547;
	} else
		goto tr1547;
	goto tr1525;
tr1630:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 540 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1229;
st1229:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1229;
case 1229:
#line 12170 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 73: goto tr1631;
		case 91: goto tr1548;
		case 105: goto tr1631;
		case 123: goto tr1549;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1547;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1547;
	} else
		goto tr1547;
	goto tr1525;
tr1631:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 540 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1230;
st1230:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1230;
case 1230:
#line 12196 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 65: goto tr1632;
		case 91: goto tr1548;
		case 97: goto tr1632;
		case 123: goto tr1549;
	}
	if ( (*( sm->p)) < 66 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1547;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 98 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1547;
	} else
		goto tr1547;
	goto tr1525;
tr1632:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 540 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1231;
st1231:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1231;
case 1231:
#line 12222 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 78: goto tr1633;
		case 91: goto tr1548;
		case 110: goto tr1633;
		case 123: goto tr1549;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1547;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1547;
	} else
		goto tr1547;
	goto tr1525;
tr1633:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 540 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1232;
st1232:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1232;
case 1232:
#line 12248 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 84: goto tr1634;
		case 91: goto tr1548;
		case 116: goto tr1634;
		case 123: goto tr1549;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1547;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1547;
	} else
		goto tr1547;
	goto tr1525;
tr1634:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 540 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1233;
st1233:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1233;
case 1233:
#line 12274 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 65: goto tr1635;
		case 91: goto tr1548;
		case 97: goto tr1635;
		case 123: goto tr1549;
	}
	if ( (*( sm->p)) < 66 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1547;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 98 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1547;
	} else
		goto tr1547;
	goto tr1525;
tr1635:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 540 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1234;
st1234:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1234;
case 1234:
#line 12300 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 82: goto tr1636;
		case 91: goto tr1548;
		case 114: goto tr1636;
		case 123: goto tr1549;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1547;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1547;
	} else
		goto tr1547;
	goto tr1525;
tr1636:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 540 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1235;
st1235:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1235;
case 1235:
#line 12326 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 84: goto tr1637;
		case 91: goto tr1548;
		case 116: goto tr1637;
		case 123: goto tr1549;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1547;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1547;
	} else
		goto tr1547;
	goto tr1525;
tr1637:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 540 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1236;
st1236:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1236;
case 1236:
#line 12352 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 32: goto st495;
		case 91: goto tr1548;
		case 123: goto tr1549;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1547;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1547;
	} else
		goto tr1547;
	goto tr1525;
st495:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof495;
case 495:
	if ( (*( sm->p)) == 35 )
		goto st496;
	goto tr188;
st496:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof496;
case 496:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr640;
	goto tr188;
tr640:
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st1237;
st1237:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1237;
case 1237:
#line 12389 "ext/dtext/dtext.cpp"
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto st1237;
	goto tr1639;
tr1629:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 540 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1238;
st1238:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1238;
case 1238:
#line 12403 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 65: goto tr1641;
		case 91: goto tr1548;
		case 97: goto tr1641;
		case 123: goto tr1549;
	}
	if ( (*( sm->p)) < 66 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1547;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 98 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1547;
	} else
		goto tr1547;
	goto tr1525;
tr1641:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 540 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1239;
st1239:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1239;
case 1239:
#line 12429 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 73: goto tr1642;
		case 91: goto tr1548;
		case 105: goto tr1642;
		case 123: goto tr1549;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1547;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1547;
	} else
		goto tr1547;
	goto tr1525;
tr1642:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 540 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1240;
st1240:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1240;
case 1240:
#line 12455 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 76: goto tr1643;
		case 91: goto tr1548;
		case 108: goto tr1643;
		case 123: goto tr1549;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1547;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1547;
	} else
		goto tr1547;
	goto tr1525;
tr1643:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 540 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1241;
st1241:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1241;
case 1241:
#line 12481 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 32: goto st497;
		case 91: goto tr1548;
		case 123: goto tr1549;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1547;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1547;
	} else
		goto tr1547;
	goto tr1525;
st497:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof497;
case 497:
	if ( (*( sm->p)) == 35 )
		goto st498;
	goto tr188;
st498:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof498;
case 498:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr642;
	goto tr188;
tr1647:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
	goto st1242;
tr642:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st1242;
st1242:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1242;
case 1242:
#line 12524 "ext/dtext/dtext.cpp"
	if ( (*( sm->p)) == 47 )
		goto tr1646;
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr1647;
	goto tr1645;
tr1646:
#line 72 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
	goto st499;
st499:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof499;
case 499:
#line 12538 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 45: goto tr644;
		case 61: goto tr644;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr644;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr644;
	} else
		goto tr644;
	goto tr643;
tr644:
#line 73 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st1243;
st1243:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1243;
case 1243:
#line 12560 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 45: goto st1243;
		case 61: goto st1243;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st1243;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st1243;
	} else
		goto st1243;
	goto tr1648;
tr1507:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
#line 540 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1244;
st1244:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1244;
case 1244:
#line 12586 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 65: goto tr1650;
		case 69: goto tr1651;
		case 76: goto tr1652;
		case 79: goto tr1653;
		case 91: goto tr1548;
		case 97: goto tr1650;
		case 101: goto tr1651;
		case 108: goto tr1652;
		case 111: goto tr1653;
		case 123: goto tr1549;
	}
	if ( (*( sm->p)) < 66 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1547;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 98 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1547;
	} else
		goto tr1547;
	goto tr1525;
tr1650:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 540 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1245;
st1245:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1245;
case 1245:
#line 12618 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 86: goto tr1654;
		case 91: goto tr1548;
		case 118: goto tr1654;
		case 123: goto tr1549;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1547;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1547;
	} else
		goto tr1547;
	goto tr1525;
tr1654:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 540 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1246;
st1246:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1246;
case 1246:
#line 12644 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 71: goto tr1655;
		case 91: goto tr1548;
		case 103: goto tr1655;
		case 123: goto tr1549;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1547;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1547;
	} else
		goto tr1547;
	goto tr1525;
tr1655:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 540 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1247;
st1247:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1247;
case 1247:
#line 12670 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 82: goto tr1656;
		case 91: goto tr1548;
		case 114: goto tr1656;
		case 123: goto tr1549;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1547;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1547;
	} else
		goto tr1547;
	goto tr1525;
tr1656:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 540 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1248;
st1248:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1248;
case 1248:
#line 12696 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 79: goto tr1657;
		case 91: goto tr1548;
		case 111: goto tr1657;
		case 123: goto tr1549;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1547;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1547;
	} else
		goto tr1547;
	goto tr1525;
tr1657:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 540 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1249;
st1249:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1249;
case 1249:
#line 12722 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 85: goto tr1658;
		case 91: goto tr1548;
		case 117: goto tr1658;
		case 123: goto tr1549;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1547;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1547;
	} else
		goto tr1547;
	goto tr1525;
tr1658:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 540 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1250;
st1250:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1250;
case 1250:
#line 12748 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 80: goto tr1659;
		case 91: goto tr1548;
		case 112: goto tr1659;
		case 123: goto tr1549;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1547;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1547;
	} else
		goto tr1547;
	goto tr1525;
tr1659:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 540 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1251;
st1251:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1251;
case 1251:
#line 12774 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 32: goto st500;
		case 91: goto tr1548;
		case 123: goto tr1549;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1547;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1547;
	} else
		goto tr1547;
	goto tr1525;
st500:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof500;
case 500:
	if ( (*( sm->p)) == 35 )
		goto st501;
	goto tr188;
st501:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof501;
case 501:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr646;
	goto tr188;
tr646:
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st1252;
st1252:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1252;
case 1252:
#line 12811 "ext/dtext/dtext.cpp"
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto st1252;
	goto tr1661;
tr1651:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 540 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1253;
st1253:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1253;
case 1253:
#line 12825 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 69: goto tr1663;
		case 91: goto tr1548;
		case 101: goto tr1663;
		case 123: goto tr1549;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1547;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1547;
	} else
		goto tr1547;
	goto tr1525;
tr1663:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 540 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1254;
st1254:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1254;
case 1254:
#line 12851 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 68: goto tr1664;
		case 91: goto tr1548;
		case 100: goto tr1664;
		case 123: goto tr1549;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1547;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1547;
	} else
		goto tr1547;
	goto tr1525;
tr1664:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 540 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1255;
st1255:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1255;
case 1255:
#line 12877 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 66: goto tr1665;
		case 91: goto tr1548;
		case 98: goto tr1665;
		case 123: goto tr1549;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1547;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1547;
	} else
		goto tr1547;
	goto tr1525;
tr1665:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 540 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1256;
st1256:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1256;
case 1256:
#line 12903 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 65: goto tr1666;
		case 91: goto tr1548;
		case 97: goto tr1666;
		case 123: goto tr1549;
	}
	if ( (*( sm->p)) < 66 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1547;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 98 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1547;
	} else
		goto tr1547;
	goto tr1525;
tr1666:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 540 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1257;
st1257:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1257;
case 1257:
#line 12929 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 67: goto tr1667;
		case 91: goto tr1548;
		case 99: goto tr1667;
		case 123: goto tr1549;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1547;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1547;
	} else
		goto tr1547;
	goto tr1525;
tr1667:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 540 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1258;
st1258:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1258;
case 1258:
#line 12955 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 75: goto tr1668;
		case 91: goto tr1548;
		case 107: goto tr1668;
		case 123: goto tr1549;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1547;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1547;
	} else
		goto tr1547;
	goto tr1525;
tr1668:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 540 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1259;
st1259:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1259;
case 1259:
#line 12981 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 32: goto st502;
		case 91: goto tr1548;
		case 123: goto tr1549;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1547;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1547;
	} else
		goto tr1547;
	goto tr1525;
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
		goto tr648;
	goto tr188;
tr648:
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st1260;
st1260:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1260;
case 1260:
#line 13018 "ext/dtext/dtext.cpp"
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto st1260;
	goto tr1670;
tr1652:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 540 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1261;
st1261:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1261;
case 1261:
#line 13032 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 65: goto tr1672;
		case 91: goto tr1548;
		case 97: goto tr1672;
		case 123: goto tr1549;
	}
	if ( (*( sm->p)) < 66 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1547;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 98 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1547;
	} else
		goto tr1547;
	goto tr1525;
tr1672:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 540 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1262;
st1262:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1262;
case 1262:
#line 13058 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 71: goto tr1673;
		case 91: goto tr1548;
		case 103: goto tr1673;
		case 123: goto tr1549;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1547;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1547;
	} else
		goto tr1547;
	goto tr1525;
tr1673:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 540 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1263;
st1263:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1263;
case 1263:
#line 13084 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 32: goto st504;
		case 91: goto tr1548;
		case 123: goto tr1549;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1547;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1547;
	} else
		goto tr1547;
	goto tr1525;
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
		goto tr650;
	goto tr188;
tr650:
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st1264;
st1264:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1264;
case 1264:
#line 13121 "ext/dtext/dtext.cpp"
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto st1264;
	goto tr1675;
tr1653:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 540 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1265;
st1265:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1265;
case 1265:
#line 13135 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 82: goto tr1677;
		case 91: goto tr1548;
		case 114: goto tr1677;
		case 123: goto tr1549;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1547;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1547;
	} else
		goto tr1547;
	goto tr1525;
tr1677:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 540 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1266;
st1266:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1266;
case 1266:
#line 13161 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 85: goto tr1678;
		case 91: goto tr1548;
		case 117: goto tr1678;
		case 123: goto tr1549;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1547;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1547;
	} else
		goto tr1547;
	goto tr1525;
tr1678:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 540 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1267;
st1267:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1267;
case 1267:
#line 13187 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 77: goto tr1679;
		case 91: goto tr1548;
		case 109: goto tr1679;
		case 123: goto tr1549;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1547;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1547;
	} else
		goto tr1547;
	goto tr1525;
tr1679:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 540 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1268;
st1268:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1268;
case 1268:
#line 13213 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 32: goto st506;
		case 91: goto tr1548;
		case 123: goto tr1549;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1547;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1547;
	} else
		goto tr1547;
	goto tr1525;
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
		goto tr652;
	goto tr188;
tr652:
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st1269;
st1269:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1269;
case 1269:
#line 13250 "ext/dtext/dtext.cpp"
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto st1269;
	goto tr1681;
tr1508:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
#line 540 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1270;
st1270:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1270;
case 1270:
#line 13266 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 69: goto tr1683;
		case 91: goto tr1548;
		case 101: goto tr1683;
		case 123: goto tr1549;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1547;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1547;
	} else
		goto tr1547;
	goto tr1525;
tr1683:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 540 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1271;
st1271:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1271;
case 1271:
#line 13292 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 76: goto tr1684;
		case 91: goto tr1548;
		case 108: goto tr1684;
		case 123: goto tr1549;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1547;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1547;
	} else
		goto tr1547;
	goto tr1525;
tr1684:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 540 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1272;
st1272:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1272;
case 1272:
#line 13318 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 66: goto tr1685;
		case 91: goto tr1548;
		case 98: goto tr1685;
		case 123: goto tr1549;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1547;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1547;
	} else
		goto tr1547;
	goto tr1525;
tr1685:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 540 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1273;
st1273:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1273;
case 1273:
#line 13344 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 79: goto tr1686;
		case 91: goto tr1548;
		case 111: goto tr1686;
		case 123: goto tr1549;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1547;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1547;
	} else
		goto tr1547;
	goto tr1525;
tr1686:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 540 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1274;
st1274:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1274;
case 1274:
#line 13370 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 79: goto tr1687;
		case 91: goto tr1548;
		case 111: goto tr1687;
		case 123: goto tr1549;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1547;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1547;
	} else
		goto tr1547;
	goto tr1525;
tr1687:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 540 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1275;
st1275:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1275;
case 1275:
#line 13396 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 82: goto tr1688;
		case 91: goto tr1548;
		case 114: goto tr1688;
		case 123: goto tr1549;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1547;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1547;
	} else
		goto tr1547;
	goto tr1525;
tr1688:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 540 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1276;
st1276:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1276;
case 1276:
#line 13422 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 85: goto tr1689;
		case 91: goto tr1548;
		case 117: goto tr1689;
		case 123: goto tr1549;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1547;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1547;
	} else
		goto tr1547;
	goto tr1525;
tr1689:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 540 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1277;
st1277:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1277;
case 1277:
#line 13448 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 32: goto st508;
		case 91: goto tr1548;
		case 123: goto tr1549;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1547;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1547;
	} else
		goto tr1547;
	goto tr1525;
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
		goto tr654;
	goto tr188;
tr654:
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st1278;
st1278:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1278;
case 1278:
#line 13485 "ext/dtext/dtext.cpp"
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto st1278;
	goto tr1691;
tr1509:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
#line 540 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1279;
st1279:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1279;
case 1279:
#line 13501 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 84: goto tr1693;
		case 91: goto tr1548;
		case 116: goto tr1693;
		case 123: goto tr1549;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1547;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1547;
	} else
		goto tr1547;
	goto tr1525;
tr1693:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 540 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1280;
st1280:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1280;
case 1280:
#line 13527 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 84: goto tr1694;
		case 91: goto tr1548;
		case 116: goto tr1694;
		case 123: goto tr1549;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1547;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1547;
	} else
		goto tr1547;
	goto tr1525;
tr1694:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 540 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1281;
st1281:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1281;
case 1281:
#line 13553 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 80: goto tr1695;
		case 91: goto tr1548;
		case 112: goto tr1695;
		case 123: goto tr1549;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1547;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1547;
	} else
		goto tr1547;
	goto tr1525;
tr1695:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 540 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1282;
st1282:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1282;
case 1282:
#line 13579 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 58: goto st510;
		case 83: goto tr1697;
		case 91: goto tr1548;
		case 115: goto tr1697;
		case 123: goto tr1549;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1547;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1547;
	} else
		goto tr1547;
	goto tr1525;
st510:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof510;
case 510:
	if ( (*( sm->p)) == 47 )
		goto st511;
	goto tr188;
st511:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof511;
case 511:
	if ( (*( sm->p)) == 47 )
		goto st512;
	goto tr188;
st512:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof512;
case 512:
	switch( (*( sm->p)) ) {
		case 45: goto st514;
		case 95: goto st514;
	}
	if ( (*( sm->p)) < -16 ) {
		if ( (*( sm->p)) > -33 ) {
			if ( -32 <= (*( sm->p)) && (*( sm->p)) <= -17 )
				goto st515;
		} else if ( (*( sm->p)) >= -62 )
			goto st513;
	} else if ( (*( sm->p)) > -12 ) {
		if ( (*( sm->p)) < 65 ) {
			if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
				goto st514;
		} else if ( (*( sm->p)) > 90 ) {
			if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
				goto st514;
		} else
			goto st514;
	} else
		goto st516;
	goto tr188;
st513:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof513;
case 513:
	if ( (*( sm->p)) <= -65 )
		goto st514;
	goto tr188;
st514:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof514;
case 514:
	switch( (*( sm->p)) ) {
		case 45: goto st514;
		case 46: goto st517;
		case 95: goto st514;
	}
	if ( (*( sm->p)) < -16 ) {
		if ( (*( sm->p)) > -33 ) {
			if ( -32 <= (*( sm->p)) && (*( sm->p)) <= -17 )
				goto st515;
		} else if ( (*( sm->p)) >= -62 )
			goto st513;
	} else if ( (*( sm->p)) > -12 ) {
		if ( (*( sm->p)) < 65 ) {
			if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
				goto st514;
		} else if ( (*( sm->p)) > 90 ) {
			if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
				goto st514;
		} else
			goto st514;
	} else
		goto st516;
	goto tr188;
st515:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof515;
case 515:
	if ( (*( sm->p)) <= -65 )
		goto st513;
	goto tr188;
st516:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof516;
case 516:
	if ( (*( sm->p)) <= -65 )
		goto st515;
	goto tr188;
st517:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof517;
case 517:
	switch( (*( sm->p)) ) {
		case -30: goto st520;
		case -29: goto st523;
		case -17: goto st525;
		case 45: goto tr668;
		case 95: goto tr668;
	}
	if ( (*( sm->p)) < -16 ) {
		if ( (*( sm->p)) > -33 ) {
			if ( -32 <= (*( sm->p)) && (*( sm->p)) <= -18 )
				goto st519;
		} else if ( (*( sm->p)) >= -62 )
			goto st518;
	} else if ( (*( sm->p)) > -12 ) {
		if ( (*( sm->p)) < 65 ) {
			if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
				goto tr668;
		} else if ( (*( sm->p)) > 90 ) {
			if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
				goto tr668;
		} else
			goto tr668;
	} else
		goto st528;
	goto tr185;
st518:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof518;
case 518:
	if ( (*( sm->p)) <= -65 )
		goto tr668;
	goto tr185;
tr668:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 356 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 54;}
	goto st1283;
st1283:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1283;
case 1283:
#line 13730 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case -30: goto st520;
		case -29: goto st523;
		case -17: goto st525;
		case 35: goto tr671;
		case 46: goto st517;
		case 47: goto tr672;
		case 58: goto st562;
		case 63: goto st551;
		case 95: goto tr668;
	}
	if ( (*( sm->p)) < -16 ) {
		if ( (*( sm->p)) > -33 ) {
			if ( -32 <= (*( sm->p)) && (*( sm->p)) <= -18 )
				goto st519;
		} else if ( (*( sm->p)) >= -62 )
			goto st518;
	} else if ( (*( sm->p)) > -12 ) {
		if ( (*( sm->p)) < 65 ) {
			if ( 45 <= (*( sm->p)) && (*( sm->p)) <= 57 )
				goto tr668;
		} else if ( (*( sm->p)) > 90 ) {
			if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
				goto tr668;
		} else
			goto tr668;
	} else
		goto st528;
	goto tr1698;
st519:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof519;
case 519:
	if ( (*( sm->p)) <= -65 )
		goto st518;
	goto tr185;
st520:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof520;
case 520:
	if ( (*( sm->p)) == -99 )
		goto st521;
	if ( (*( sm->p)) <= -65 )
		goto st518;
	goto tr185;
st521:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof521;
case 521:
	if ( (*( sm->p)) == -83 )
		goto st522;
	if ( (*( sm->p)) <= -65 )
		goto tr668;
	goto tr185;
st522:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof522;
case 522:
	switch( (*( sm->p)) ) {
		case -30: goto st520;
		case -29: goto st523;
		case -17: goto st525;
		case 35: goto tr671;
		case 46: goto st517;
		case 47: goto tr672;
		case 58: goto st562;
		case 63: goto st551;
		case 95: goto tr668;
	}
	if ( (*( sm->p)) < -16 ) {
		if ( (*( sm->p)) > -33 ) {
			if ( -32 <= (*( sm->p)) && (*( sm->p)) <= -18 )
				goto st519;
		} else if ( (*( sm->p)) >= -62 )
			goto st518;
	} else if ( (*( sm->p)) > -12 ) {
		if ( (*( sm->p)) < 65 ) {
			if ( 45 <= (*( sm->p)) && (*( sm->p)) <= 57 )
				goto tr668;
		} else if ( (*( sm->p)) > 90 ) {
			if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
				goto tr668;
		} else
			goto tr668;
	} else
		goto st528;
	goto tr185;
st523:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof523;
case 523:
	if ( (*( sm->p)) == -128 )
		goto st524;
	if ( -127 <= (*( sm->p)) && (*( sm->p)) <= -65 )
		goto st518;
	goto tr185;
st524:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof524;
case 524:
	if ( (*( sm->p)) < -120 ) {
		if ( (*( sm->p)) > -126 ) {
			if ( -125 <= (*( sm->p)) && (*( sm->p)) <= -121 )
				goto tr668;
		} else
			goto st522;
	} else if ( (*( sm->p)) > -111 ) {
		if ( (*( sm->p)) < -108 ) {
			if ( -110 <= (*( sm->p)) && (*( sm->p)) <= -109 )
				goto tr668;
		} else if ( (*( sm->p)) > -100 ) {
			if ( -99 <= (*( sm->p)) && (*( sm->p)) <= -65 )
				goto tr668;
		} else
			goto st522;
	} else
		goto st522;
	goto tr185;
st525:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof525;
case 525:
	switch( (*( sm->p)) ) {
		case -68: goto st526;
		case -67: goto st527;
	}
	if ( (*( sm->p)) <= -65 )
		goto st518;
	goto tr185;
st526:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof526;
case 526:
	switch( (*( sm->p)) ) {
		case -119: goto st522;
		case -67: goto st522;
	}
	if ( (*( sm->p)) <= -65 )
		goto tr668;
	goto tr185;
st527:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof527;
case 527:
	switch( (*( sm->p)) ) {
		case -99: goto st522;
		case -96: goto st522;
		case -93: goto st522;
	}
	if ( (*( sm->p)) <= -65 )
		goto tr668;
	goto tr185;
st528:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof528;
case 528:
	if ( (*( sm->p)) <= -65 )
		goto st519;
	goto tr185;
tr671:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
	goto st1284;
st1284:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1284;
case 1284:
#line 13898 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case -30: goto st531;
		case -29: goto st533;
		case -17: goto st535;
		case 32: goto tr1698;
		case 34: goto st539;
		case 35: goto tr1698;
		case 39: goto st539;
		case 44: goto st539;
		case 46: goto st539;
		case 60: goto tr1698;
		case 62: goto tr1698;
		case 63: goto st539;
		case 91: goto tr1698;
		case 93: goto tr1698;
	}
	if ( (*( sm->p)) < -16 ) {
		if ( (*( sm->p)) < -62 ) {
			if ( (*( sm->p)) <= -63 )
				goto tr1698;
		} else if ( (*( sm->p)) > -33 ) {
			if ( -32 <= (*( sm->p)) && (*( sm->p)) <= -18 )
				goto st530;
		} else
			goto st529;
	} else if ( (*( sm->p)) > -12 ) {
		if ( (*( sm->p)) < 9 ) {
			if ( -11 <= (*( sm->p)) && (*( sm->p)) <= 0 )
				goto tr1698;
		} else if ( (*( sm->p)) > 13 ) {
			if ( 58 <= (*( sm->p)) && (*( sm->p)) <= 59 )
				goto st539;
		} else
			goto tr1698;
	} else
		goto st538;
	goto tr671;
st529:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof529;
case 529:
	if ( (*( sm->p)) <= -65 )
		goto tr671;
	goto tr678;
st530:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof530;
case 530:
	if ( (*( sm->p)) <= -65 )
		goto st529;
	goto tr678;
st531:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof531;
case 531:
	if ( (*( sm->p)) == -99 )
		goto st532;
	if ( (*( sm->p)) <= -65 )
		goto st529;
	goto tr678;
st532:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof532;
case 532:
	if ( (*( sm->p)) > -84 ) {
		if ( -82 <= (*( sm->p)) && (*( sm->p)) <= -65 )
			goto tr671;
	} else
		goto tr671;
	goto tr678;
st533:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof533;
case 533:
	if ( (*( sm->p)) == -128 )
		goto st534;
	if ( -127 <= (*( sm->p)) && (*( sm->p)) <= -65 )
		goto st529;
	goto tr678;
st534:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof534;
case 534:
	if ( (*( sm->p)) < -110 ) {
		if ( -125 <= (*( sm->p)) && (*( sm->p)) <= -121 )
			goto tr671;
	} else if ( (*( sm->p)) > -109 ) {
		if ( -99 <= (*( sm->p)) && (*( sm->p)) <= -65 )
			goto tr671;
	} else
		goto tr671;
	goto tr678;
st535:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof535;
case 535:
	switch( (*( sm->p)) ) {
		case -68: goto st536;
		case -67: goto st537;
	}
	if ( (*( sm->p)) <= -65 )
		goto st529;
	goto tr678;
st536:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof536;
case 536:
	if ( (*( sm->p)) < -118 ) {
		if ( (*( sm->p)) <= -120 )
			goto tr671;
	} else if ( (*( sm->p)) > -68 ) {
		if ( -66 <= (*( sm->p)) && (*( sm->p)) <= -65 )
			goto tr671;
	} else
		goto tr671;
	goto tr678;
st537:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof537;
case 537:
	if ( (*( sm->p)) < -98 ) {
		if ( (*( sm->p)) <= -100 )
			goto tr671;
	} else if ( (*( sm->p)) > -97 ) {
		if ( (*( sm->p)) > -94 ) {
			if ( -92 <= (*( sm->p)) && (*( sm->p)) <= -65 )
				goto tr671;
		} else if ( (*( sm->p)) >= -95 )
			goto tr671;
	} else
		goto tr671;
	goto tr678;
st538:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof538;
case 538:
	if ( (*( sm->p)) <= -65 )
		goto st530;
	goto tr678;
st539:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof539;
case 539:
	switch( (*( sm->p)) ) {
		case -30: goto st531;
		case -29: goto st533;
		case -17: goto st535;
		case 32: goto tr678;
		case 34: goto st539;
		case 35: goto tr678;
		case 39: goto st539;
		case 44: goto st539;
		case 46: goto st539;
		case 60: goto tr678;
		case 62: goto tr678;
		case 63: goto st539;
		case 91: goto tr678;
		case 93: goto tr678;
	}
	if ( (*( sm->p)) < -16 ) {
		if ( (*( sm->p)) < -62 ) {
			if ( (*( sm->p)) <= -63 )
				goto tr678;
		} else if ( (*( sm->p)) > -33 ) {
			if ( -32 <= (*( sm->p)) && (*( sm->p)) <= -18 )
				goto st530;
		} else
			goto st529;
	} else if ( (*( sm->p)) > -12 ) {
		if ( (*( sm->p)) < 9 ) {
			if ( -11 <= (*( sm->p)) && (*( sm->p)) <= 0 )
				goto tr678;
		} else if ( (*( sm->p)) > 13 ) {
			if ( 58 <= (*( sm->p)) && (*( sm->p)) <= 59 )
				goto st539;
		} else
			goto tr678;
	} else
		goto st538;
	goto tr671;
tr672:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 356 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 54;}
	goto st1285;
st1285:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1285;
case 1285:
#line 14089 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case -30: goto st542;
		case -29: goto st544;
		case -17: goto st546;
		case 32: goto tr1698;
		case 34: goto st550;
		case 35: goto tr671;
		case 39: goto st550;
		case 44: goto st550;
		case 46: goto st550;
		case 60: goto tr1698;
		case 62: goto tr1698;
		case 63: goto st551;
		case 91: goto tr1698;
		case 93: goto tr1698;
	}
	if ( (*( sm->p)) < -16 ) {
		if ( (*( sm->p)) < -62 ) {
			if ( (*( sm->p)) <= -63 )
				goto tr1698;
		} else if ( (*( sm->p)) > -33 ) {
			if ( -32 <= (*( sm->p)) && (*( sm->p)) <= -18 )
				goto st541;
		} else
			goto st540;
	} else if ( (*( sm->p)) > -12 ) {
		if ( (*( sm->p)) < 9 ) {
			if ( -11 <= (*( sm->p)) && (*( sm->p)) <= 0 )
				goto tr1698;
		} else if ( (*( sm->p)) > 13 ) {
			if ( 58 <= (*( sm->p)) && (*( sm->p)) <= 59 )
				goto st550;
		} else
			goto tr1698;
	} else
		goto st549;
	goto tr672;
st540:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof540;
case 540:
	if ( (*( sm->p)) <= -65 )
		goto tr672;
	goto tr678;
st541:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof541;
case 541:
	if ( (*( sm->p)) <= -65 )
		goto st540;
	goto tr678;
st542:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof542;
case 542:
	if ( (*( sm->p)) == -99 )
		goto st543;
	if ( (*( sm->p)) <= -65 )
		goto st540;
	goto tr678;
st543:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof543;
case 543:
	if ( (*( sm->p)) > -84 ) {
		if ( -82 <= (*( sm->p)) && (*( sm->p)) <= -65 )
			goto tr672;
	} else
		goto tr672;
	goto tr678;
st544:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof544;
case 544:
	if ( (*( sm->p)) == -128 )
		goto st545;
	if ( -127 <= (*( sm->p)) && (*( sm->p)) <= -65 )
		goto st540;
	goto tr678;
st545:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof545;
case 545:
	if ( (*( sm->p)) < -110 ) {
		if ( -125 <= (*( sm->p)) && (*( sm->p)) <= -121 )
			goto tr672;
	} else if ( (*( sm->p)) > -109 ) {
		if ( -99 <= (*( sm->p)) && (*( sm->p)) <= -65 )
			goto tr672;
	} else
		goto tr672;
	goto tr678;
st546:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof546;
case 546:
	switch( (*( sm->p)) ) {
		case -68: goto st547;
		case -67: goto st548;
	}
	if ( (*( sm->p)) <= -65 )
		goto st540;
	goto tr678;
st547:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof547;
case 547:
	if ( (*( sm->p)) < -118 ) {
		if ( (*( sm->p)) <= -120 )
			goto tr672;
	} else if ( (*( sm->p)) > -68 ) {
		if ( -66 <= (*( sm->p)) && (*( sm->p)) <= -65 )
			goto tr672;
	} else
		goto tr672;
	goto tr678;
st548:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof548;
case 548:
	if ( (*( sm->p)) < -98 ) {
		if ( (*( sm->p)) <= -100 )
			goto tr672;
	} else if ( (*( sm->p)) > -97 ) {
		if ( (*( sm->p)) > -94 ) {
			if ( -92 <= (*( sm->p)) && (*( sm->p)) <= -65 )
				goto tr672;
		} else if ( (*( sm->p)) >= -95 )
			goto tr672;
	} else
		goto tr672;
	goto tr678;
st549:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof549;
case 549:
	if ( (*( sm->p)) <= -65 )
		goto st541;
	goto tr678;
st550:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof550;
case 550:
	switch( (*( sm->p)) ) {
		case -30: goto st542;
		case -29: goto st544;
		case -17: goto st546;
		case 32: goto tr678;
		case 34: goto st550;
		case 35: goto tr671;
		case 39: goto st550;
		case 44: goto st550;
		case 46: goto st550;
		case 60: goto tr678;
		case 62: goto tr678;
		case 63: goto st551;
		case 91: goto tr678;
		case 93: goto tr678;
	}
	if ( (*( sm->p)) < -16 ) {
		if ( (*( sm->p)) < -62 ) {
			if ( (*( sm->p)) <= -63 )
				goto tr678;
		} else if ( (*( sm->p)) > -33 ) {
			if ( -32 <= (*( sm->p)) && (*( sm->p)) <= -18 )
				goto st541;
		} else
			goto st540;
	} else if ( (*( sm->p)) > -12 ) {
		if ( (*( sm->p)) < 9 ) {
			if ( -11 <= (*( sm->p)) && (*( sm->p)) <= 0 )
				goto tr678;
		} else if ( (*( sm->p)) > 13 ) {
			if ( 58 <= (*( sm->p)) && (*( sm->p)) <= 59 )
				goto st550;
		} else
			goto tr678;
	} else
		goto st549;
	goto tr672;
st551:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof551;
case 551:
	switch( (*( sm->p)) ) {
		case -30: goto st554;
		case -29: goto st556;
		case -17: goto st558;
		case 32: goto tr185;
		case 34: goto st551;
		case 35: goto tr671;
		case 39: goto st551;
		case 44: goto st551;
		case 46: goto st551;
		case 63: goto st551;
	}
	if ( (*( sm->p)) < -16 ) {
		if ( (*( sm->p)) < -62 ) {
			if ( (*( sm->p)) <= -63 )
				goto tr185;
		} else if ( (*( sm->p)) > -33 ) {
			if ( -32 <= (*( sm->p)) && (*( sm->p)) <= -18 )
				goto st553;
		} else
			goto st552;
	} else if ( (*( sm->p)) > -12 ) {
		if ( (*( sm->p)) < 9 ) {
			if ( -11 <= (*( sm->p)) && (*( sm->p)) <= 0 )
				goto tr185;
		} else if ( (*( sm->p)) > 13 ) {
			if ( 58 <= (*( sm->p)) && (*( sm->p)) <= 59 )
				goto st551;
		} else
			goto tr185;
	} else
		goto st561;
	goto tr707;
st552:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof552;
case 552:
	if ( (*( sm->p)) <= -65 )
		goto tr707;
	goto tr185;
tr707:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 356 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 54;}
	goto st1286;
st1286:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1286;
case 1286:
#line 14324 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case -30: goto st554;
		case -29: goto st556;
		case -17: goto st558;
		case 32: goto tr1698;
		case 34: goto st551;
		case 35: goto tr671;
		case 39: goto st551;
		case 44: goto st551;
		case 46: goto st551;
		case 63: goto st551;
	}
	if ( (*( sm->p)) < -16 ) {
		if ( (*( sm->p)) < -62 ) {
			if ( (*( sm->p)) <= -63 )
				goto tr1698;
		} else if ( (*( sm->p)) > -33 ) {
			if ( -32 <= (*( sm->p)) && (*( sm->p)) <= -18 )
				goto st553;
		} else
			goto st552;
	} else if ( (*( sm->p)) > -12 ) {
		if ( (*( sm->p)) < 9 ) {
			if ( -11 <= (*( sm->p)) && (*( sm->p)) <= 0 )
				goto tr1698;
		} else if ( (*( sm->p)) > 13 ) {
			if ( 58 <= (*( sm->p)) && (*( sm->p)) <= 59 )
				goto st551;
		} else
			goto tr1698;
	} else
		goto st561;
	goto tr707;
st553:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof553;
case 553:
	if ( (*( sm->p)) <= -65 )
		goto st552;
	goto tr185;
st554:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof554;
case 554:
	if ( (*( sm->p)) == -99 )
		goto st555;
	if ( (*( sm->p)) <= -65 )
		goto st552;
	goto tr185;
st555:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof555;
case 555:
	if ( (*( sm->p)) > -84 ) {
		if ( -82 <= (*( sm->p)) && (*( sm->p)) <= -65 )
			goto tr707;
	} else
		goto tr707;
	goto tr185;
st556:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof556;
case 556:
	if ( (*( sm->p)) == -128 )
		goto st557;
	if ( -127 <= (*( sm->p)) && (*( sm->p)) <= -65 )
		goto st552;
	goto tr185;
st557:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof557;
case 557:
	if ( (*( sm->p)) < -110 ) {
		if ( -125 <= (*( sm->p)) && (*( sm->p)) <= -121 )
			goto tr707;
	} else if ( (*( sm->p)) > -109 ) {
		if ( -99 <= (*( sm->p)) && (*( sm->p)) <= -65 )
			goto tr707;
	} else
		goto tr707;
	goto tr185;
st558:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof558;
case 558:
	switch( (*( sm->p)) ) {
		case -68: goto st559;
		case -67: goto st560;
	}
	if ( (*( sm->p)) <= -65 )
		goto st552;
	goto tr185;
st559:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof559;
case 559:
	if ( (*( sm->p)) < -118 ) {
		if ( (*( sm->p)) <= -120 )
			goto tr707;
	} else if ( (*( sm->p)) > -68 ) {
		if ( -66 <= (*( sm->p)) && (*( sm->p)) <= -65 )
			goto tr707;
	} else
		goto tr707;
	goto tr185;
st560:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof560;
case 560:
	if ( (*( sm->p)) < -98 ) {
		if ( (*( sm->p)) <= -100 )
			goto tr707;
	} else if ( (*( sm->p)) > -97 ) {
		if ( (*( sm->p)) > -94 ) {
			if ( -92 <= (*( sm->p)) && (*( sm->p)) <= -65 )
				goto tr707;
		} else if ( (*( sm->p)) >= -95 )
			goto tr707;
	} else
		goto tr707;
	goto tr185;
st561:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof561;
case 561:
	if ( (*( sm->p)) <= -65 )
		goto st553;
	goto tr185;
st562:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof562;
case 562:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr712;
	goto tr185;
tr712:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 356 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 54;}
	goto st1287;
st1287:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1287;
case 1287:
#line 14470 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 35: goto tr671;
		case 47: goto tr672;
		case 63: goto st551;
	}
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr712;
	goto tr1698;
tr1697:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 540 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1288;
st1288:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1288;
case 1288:
#line 14489 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 58: goto st510;
		case 91: goto tr1548;
		case 123: goto tr1549;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1547;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1547;
	} else
		goto tr1547;
	goto tr1525;
tr1510:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
#line 540 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1289;
st1289:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1289;
case 1289:
#line 14516 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 77: goto tr1699;
		case 83: goto tr1700;
		case 91: goto tr1548;
		case 109: goto tr1699;
		case 115: goto tr1700;
		case 123: goto tr1549;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1547;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1547;
	} else
		goto tr1547;
	goto tr1525;
tr1699:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 540 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1290;
st1290:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1290;
case 1290:
#line 14544 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 80: goto tr1701;
		case 91: goto tr1548;
		case 112: goto tr1701;
		case 123: goto tr1549;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1547;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1547;
	} else
		goto tr1547;
	goto tr1525;
tr1701:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 540 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1291;
st1291:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1291;
case 1291:
#line 14570 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 76: goto tr1702;
		case 91: goto tr1548;
		case 108: goto tr1702;
		case 123: goto tr1549;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1547;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1547;
	} else
		goto tr1547;
	goto tr1525;
tr1702:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 540 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1292;
st1292:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1292;
case 1292:
#line 14596 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 73: goto tr1703;
		case 91: goto tr1548;
		case 105: goto tr1703;
		case 123: goto tr1549;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1547;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1547;
	} else
		goto tr1547;
	goto tr1525;
tr1703:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 540 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1293;
st1293:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1293;
case 1293:
#line 14622 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 67: goto tr1704;
		case 91: goto tr1548;
		case 99: goto tr1704;
		case 123: goto tr1549;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1547;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1547;
	} else
		goto tr1547;
	goto tr1525;
tr1704:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 540 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1294;
st1294:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1294;
case 1294:
#line 14648 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 65: goto tr1705;
		case 91: goto tr1548;
		case 97: goto tr1705;
		case 123: goto tr1549;
	}
	if ( (*( sm->p)) < 66 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1547;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 98 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1547;
	} else
		goto tr1547;
	goto tr1525;
tr1705:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 540 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1295;
st1295:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1295;
case 1295:
#line 14674 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 84: goto tr1706;
		case 91: goto tr1548;
		case 116: goto tr1706;
		case 123: goto tr1549;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1547;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1547;
	} else
		goto tr1547;
	goto tr1525;
tr1706:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 540 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1296;
st1296:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1296;
case 1296:
#line 14700 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 73: goto tr1707;
		case 91: goto tr1548;
		case 105: goto tr1707;
		case 123: goto tr1549;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1547;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1547;
	} else
		goto tr1547;
	goto tr1525;
tr1707:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 540 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1297;
st1297:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1297;
case 1297:
#line 14726 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 79: goto tr1708;
		case 91: goto tr1548;
		case 111: goto tr1708;
		case 123: goto tr1549;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1547;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1547;
	} else
		goto tr1547;
	goto tr1525;
tr1708:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 540 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1298;
st1298:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1298;
case 1298:
#line 14752 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 78: goto tr1709;
		case 91: goto tr1548;
		case 110: goto tr1709;
		case 123: goto tr1549;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1547;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1547;
	} else
		goto tr1547;
	goto tr1525;
tr1709:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 540 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1299;
st1299:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1299;
case 1299:
#line 14778 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 32: goto st563;
		case 91: goto tr1548;
		case 123: goto tr1549;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1547;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1547;
	} else
		goto tr1547;
	goto tr1525;
st563:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof563;
case 563:
	if ( (*( sm->p)) == 35 )
		goto st564;
	goto tr188;
st564:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof564;
case 564:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr714;
	goto tr188;
tr714:
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st1300;
st1300:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1300;
case 1300:
#line 14815 "ext/dtext/dtext.cpp"
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto st1300;
	goto tr1711;
tr1700:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 540 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1301;
st1301:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1301;
case 1301:
#line 14829 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 83: goto tr1713;
		case 91: goto tr1548;
		case 115: goto tr1713;
		case 123: goto tr1549;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1547;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1547;
	} else
		goto tr1547;
	goto tr1525;
tr1713:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 540 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1302;
st1302:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1302;
case 1302:
#line 14855 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 85: goto tr1714;
		case 91: goto tr1548;
		case 117: goto tr1714;
		case 123: goto tr1549;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1547;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1547;
	} else
		goto tr1547;
	goto tr1525;
tr1714:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 540 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1303;
st1303:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1303;
case 1303:
#line 14881 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 69: goto tr1715;
		case 91: goto tr1548;
		case 101: goto tr1715;
		case 123: goto tr1549;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1547;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1547;
	} else
		goto tr1547;
	goto tr1525;
tr1715:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 540 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1304;
st1304:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1304;
case 1304:
#line 14907 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 32: goto st565;
		case 91: goto tr1548;
		case 123: goto tr1549;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1547;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1547;
	} else
		goto tr1547;
	goto tr1525;
st565:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof565;
case 565:
	if ( (*( sm->p)) == 35 )
		goto st566;
	goto tr188;
st566:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof566;
case 566:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr716;
	goto tr188;
tr716:
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st1305;
st1305:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1305;
case 1305:
#line 14944 "ext/dtext/dtext.cpp"
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto st1305;
	goto tr1717;
tr1511:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
#line 540 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1306;
st1306:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1306;
case 1306:
#line 14960 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 79: goto tr1719;
		case 91: goto tr1548;
		case 111: goto tr1719;
		case 123: goto tr1549;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1547;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1547;
	} else
		goto tr1547;
	goto tr1525;
tr1719:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 540 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1307;
st1307:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1307;
case 1307:
#line 14986 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 68: goto tr1720;
		case 91: goto tr1548;
		case 100: goto tr1720;
		case 123: goto tr1549;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1547;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1547;
	} else
		goto tr1547;
	goto tr1525;
tr1720:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 540 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1308;
st1308:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1308;
case 1308:
#line 15012 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 32: goto st567;
		case 82: goto tr1722;
		case 91: goto tr1548;
		case 114: goto tr1722;
		case 123: goto tr1549;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1547;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1547;
	} else
		goto tr1547;
	goto tr1525;
st567:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof567;
case 567:
	switch( (*( sm->p)) ) {
		case 65: goto st568;
		case 97: goto st568;
	}
	goto tr188;
st568:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof568;
case 568:
	switch( (*( sm->p)) ) {
		case 67: goto st569;
		case 99: goto st569;
	}
	goto tr188;
st569:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof569;
case 569:
	switch( (*( sm->p)) ) {
		case 84: goto st570;
		case 116: goto st570;
	}
	goto tr188;
st570:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof570;
case 570:
	switch( (*( sm->p)) ) {
		case 73: goto st571;
		case 105: goto st571;
	}
	goto tr188;
st571:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof571;
case 571:
	switch( (*( sm->p)) ) {
		case 79: goto st572;
		case 111: goto st572;
	}
	goto tr188;
st572:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof572;
case 572:
	switch( (*( sm->p)) ) {
		case 78: goto st573;
		case 110: goto st573;
	}
	goto tr188;
st573:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof573;
case 573:
	if ( (*( sm->p)) == 32 )
		goto st574;
	goto tr188;
st574:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof574;
case 574:
	if ( (*( sm->p)) == 35 )
		goto st575;
	goto tr188;
st575:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof575;
case 575:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr725;
	goto tr188;
tr725:
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st1309;
st1309:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1309;
case 1309:
#line 15112 "ext/dtext/dtext.cpp"
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto st1309;
	goto tr1723;
tr1722:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 540 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1310;
st1310:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1310;
case 1310:
#line 15126 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 69: goto tr1725;
		case 91: goto tr1548;
		case 101: goto tr1725;
		case 123: goto tr1549;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1547;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1547;
	} else
		goto tr1547;
	goto tr1525;
tr1725:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 540 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1311;
st1311:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1311;
case 1311:
#line 15152 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 80: goto tr1726;
		case 91: goto tr1548;
		case 112: goto tr1726;
		case 123: goto tr1549;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1547;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1547;
	} else
		goto tr1547;
	goto tr1525;
tr1726:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 540 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1312;
st1312:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1312;
case 1312:
#line 15178 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 79: goto tr1727;
		case 91: goto tr1548;
		case 111: goto tr1727;
		case 123: goto tr1549;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1547;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1547;
	} else
		goto tr1547;
	goto tr1525;
tr1727:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 540 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1313;
st1313:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1313;
case 1313:
#line 15204 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 82: goto tr1728;
		case 91: goto tr1548;
		case 114: goto tr1728;
		case 123: goto tr1549;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1547;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1547;
	} else
		goto tr1547;
	goto tr1525;
tr1728:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 540 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1314;
st1314:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1314;
case 1314:
#line 15230 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 84: goto tr1729;
		case 91: goto tr1548;
		case 116: goto tr1729;
		case 123: goto tr1549;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1547;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1547;
	} else
		goto tr1547;
	goto tr1525;
tr1729:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 540 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1315;
st1315:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1315;
case 1315:
#line 15256 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 32: goto st576;
		case 91: goto tr1548;
		case 123: goto tr1549;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1547;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1547;
	} else
		goto tr1547;
	goto tr1525;
st576:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof576;
case 576:
	if ( (*( sm->p)) == 35 )
		goto st577;
	goto tr188;
st577:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof577;
case 577:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr727;
	goto tr188;
tr727:
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st1316;
st1316:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1316;
case 1316:
#line 15293 "ext/dtext/dtext.cpp"
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto st1316;
	goto tr1731;
tr1512:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
#line 540 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1317;
st1317:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1317;
case 1317:
#line 15309 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 73: goto tr1733;
		case 79: goto tr1734;
		case 91: goto tr1548;
		case 105: goto tr1733;
		case 111: goto tr1734;
		case 123: goto tr1549;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1547;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1547;
	} else
		goto tr1547;
	goto tr1525;
tr1733:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 540 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1318;
st1318:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1318;
case 1318:
#line 15337 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 74: goto tr1735;
		case 91: goto tr1548;
		case 106: goto tr1735;
		case 123: goto tr1549;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1547;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1547;
	} else
		goto tr1547;
	goto tr1525;
tr1735:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 540 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1319;
st1319:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1319;
case 1319:
#line 15363 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 73: goto tr1736;
		case 91: goto tr1548;
		case 105: goto tr1736;
		case 123: goto tr1549;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1547;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1547;
	} else
		goto tr1547;
	goto tr1525;
tr1736:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 540 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1320;
st1320:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1320;
case 1320:
#line 15389 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 69: goto tr1737;
		case 91: goto tr1548;
		case 101: goto tr1737;
		case 123: goto tr1549;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1547;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1547;
	} else
		goto tr1547;
	goto tr1525;
tr1737:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 540 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1321;
st1321:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1321;
case 1321:
#line 15415 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 32: goto st578;
		case 91: goto tr1548;
		case 123: goto tr1549;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1547;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1547;
	} else
		goto tr1547;
	goto tr1525;
st578:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof578;
case 578:
	if ( (*( sm->p)) == 35 )
		goto st579;
	goto tr188;
st579:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof579;
case 579:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr729;
	goto tr188;
tr729:
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st1322;
st1322:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1322;
case 1322:
#line 15452 "ext/dtext/dtext.cpp"
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto st1322;
	goto tr1739;
tr1734:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 540 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1323;
st1323:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1323;
case 1323:
#line 15466 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 84: goto tr1741;
		case 91: goto tr1548;
		case 116: goto tr1741;
		case 123: goto tr1549;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1547;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1547;
	} else
		goto tr1547;
	goto tr1525;
tr1741:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 540 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1324;
st1324:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1324;
case 1324:
#line 15492 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 69: goto tr1742;
		case 91: goto tr1548;
		case 101: goto tr1742;
		case 123: goto tr1549;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1547;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1547;
	} else
		goto tr1547;
	goto tr1525;
tr1742:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 540 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1325;
st1325:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1325;
case 1325:
#line 15518 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 32: goto st580;
		case 91: goto tr1548;
		case 123: goto tr1549;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1547;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1547;
	} else
		goto tr1547;
	goto tr1525;
st580:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof580;
case 580:
	if ( (*( sm->p)) == 35 )
		goto st581;
	goto tr188;
st581:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof581;
case 581:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr731;
	goto tr188;
tr731:
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st1326;
st1326:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1326;
case 1326:
#line 15555 "ext/dtext/dtext.cpp"
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto st1326;
	goto tr1744;
tr1513:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
#line 540 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1327;
st1327:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1327;
case 1327:
#line 15571 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 65: goto tr1746;
		case 73: goto tr1747;
		case 79: goto tr1748;
		case 85: goto tr1749;
		case 91: goto tr1548;
		case 97: goto tr1746;
		case 105: goto tr1747;
		case 111: goto tr1748;
		case 117: goto tr1749;
		case 123: goto tr1549;
	}
	if ( (*( sm->p)) < 66 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1547;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 98 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1547;
	} else
		goto tr1547;
	goto tr1525;
tr1746:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 540 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1328;
st1328:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1328;
case 1328:
#line 15603 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 87: goto tr1750;
		case 91: goto tr1548;
		case 119: goto tr1750;
		case 123: goto tr1549;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1547;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1547;
	} else
		goto tr1547;
	goto tr1525;
tr1750:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 540 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1329;
st1329:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1329;
case 1329:
#line 15629 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 79: goto tr1751;
		case 91: goto tr1548;
		case 111: goto tr1751;
		case 123: goto tr1549;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1547;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1547;
	} else
		goto tr1547;
	goto tr1525;
tr1751:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 540 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1330;
st1330:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1330;
case 1330:
#line 15655 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 79: goto tr1752;
		case 91: goto tr1548;
		case 111: goto tr1752;
		case 123: goto tr1549;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1547;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1547;
	} else
		goto tr1547;
	goto tr1525;
tr1752:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 540 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1331;
st1331:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1331;
case 1331:
#line 15681 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 32: goto st582;
		case 91: goto tr1548;
		case 123: goto tr1549;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1547;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1547;
	} else
		goto tr1547;
	goto tr1525;
st582:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof582;
case 582:
	if ( (*( sm->p)) == 35 )
		goto st583;
	goto tr188;
st583:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof583;
case 583:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr733;
	goto tr188;
tr733:
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st1332;
st1332:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1332;
case 1332:
#line 15718 "ext/dtext/dtext.cpp"
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto st1332;
	goto tr1754;
tr1747:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 540 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1333;
st1333:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1333;
case 1333:
#line 15732 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 88: goto tr1756;
		case 91: goto tr1548;
		case 120: goto tr1756;
		case 123: goto tr1549;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1547;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1547;
	} else
		goto tr1547;
	goto tr1525;
tr1756:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 540 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1334;
st1334:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1334;
case 1334:
#line 15758 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 73: goto tr1757;
		case 91: goto tr1548;
		case 105: goto tr1757;
		case 123: goto tr1549;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1547;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1547;
	} else
		goto tr1547;
	goto tr1525;
tr1757:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 540 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1335;
st1335:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1335;
case 1335:
#line 15784 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 86: goto tr1758;
		case 91: goto tr1548;
		case 118: goto tr1758;
		case 123: goto tr1549;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1547;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1547;
	} else
		goto tr1547;
	goto tr1525;
tr1758:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 540 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1336;
st1336:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1336;
case 1336:
#line 15810 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 32: goto st584;
		case 91: goto tr1548;
		case 123: goto tr1549;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1547;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1547;
	} else
		goto tr1547;
	goto tr1525;
st584:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof584;
case 584:
	if ( (*( sm->p)) == 35 )
		goto st585;
	goto tr188;
st585:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof585;
case 585:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr735;
	goto tr188;
tr1762:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
	goto st1337;
tr735:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st1337;
st1337:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1337;
case 1337:
#line 15853 "ext/dtext/dtext.cpp"
	if ( (*( sm->p)) == 47 )
		goto tr1761;
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr1762;
	goto tr1760;
tr1761:
#line 72 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
	goto st586;
st586:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof586;
case 586:
#line 15867 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 80: goto st587;
		case 112: goto st587;
	}
	goto tr736;
st587:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof587;
case 587:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr738;
	goto tr736;
tr738:
#line 73 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st1338;
st1338:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1338;
case 1338:
#line 15888 "ext/dtext/dtext.cpp"
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto st1338;
	goto tr1763;
tr1748:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 540 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1339;
st1339:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1339;
case 1339:
#line 15902 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 79: goto tr1765;
		case 83: goto tr1766;
		case 91: goto tr1548;
		case 111: goto tr1765;
		case 115: goto tr1766;
		case 123: goto tr1549;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1547;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1547;
	} else
		goto tr1547;
	goto tr1525;
tr1765:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 540 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1340;
st1340:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1340;
case 1340:
#line 15930 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 76: goto tr1767;
		case 91: goto tr1548;
		case 108: goto tr1767;
		case 123: goto tr1549;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1547;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1547;
	} else
		goto tr1547;
	goto tr1525;
tr1767:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 540 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1341;
st1341:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1341;
case 1341:
#line 15956 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 32: goto st588;
		case 91: goto tr1548;
		case 123: goto tr1549;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1547;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1547;
	} else
		goto tr1547;
	goto tr1525;
st588:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof588;
case 588:
	if ( (*( sm->p)) == 35 )
		goto st589;
	goto tr188;
st589:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof589;
case 589:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr740;
	goto tr188;
tr740:
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st1342;
st1342:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1342;
case 1342:
#line 15993 "ext/dtext/dtext.cpp"
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto st1342;
	goto tr1769;
tr1766:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 540 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1343;
st1343:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1343;
case 1343:
#line 16007 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 84: goto tr1771;
		case 91: goto tr1548;
		case 116: goto tr1771;
		case 123: goto tr1549;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1547;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1547;
	} else
		goto tr1547;
	goto tr1525;
tr1771:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 540 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1344;
st1344:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1344;
case 1344:
#line 16033 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 32: goto st590;
		case 91: goto tr1548;
		case 123: goto tr1549;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1547;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1547;
	} else
		goto tr1547;
	goto tr1525;
st590:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof590;
case 590:
	if ( (*( sm->p)) == 35 )
		goto st591;
	goto tr188;
st591:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof591;
case 591:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr742;
	goto tr188;
tr742:
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st1345;
st1345:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1345;
case 1345:
#line 16070 "ext/dtext/dtext.cpp"
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto st1345;
	goto tr1773;
tr1749:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 540 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1346;
st1346:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1346;
case 1346:
#line 16084 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 76: goto tr1775;
		case 91: goto tr1548;
		case 108: goto tr1775;
		case 123: goto tr1549;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1547;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1547;
	} else
		goto tr1547;
	goto tr1525;
tr1775:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 540 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1347;
st1347:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1347;
case 1347:
#line 16110 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 76: goto tr1776;
		case 91: goto tr1548;
		case 108: goto tr1776;
		case 123: goto tr1549;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1547;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1547;
	} else
		goto tr1547;
	goto tr1525;
tr1776:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 540 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1348;
st1348:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1348;
case 1348:
#line 16136 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 32: goto st592;
		case 91: goto tr1548;
		case 123: goto tr1549;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1547;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1547;
	} else
		goto tr1547;
	goto tr1525;
st592:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof592;
case 592:
	if ( (*( sm->p)) == 35 )
		goto st593;
	goto tr188;
st593:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof593;
case 593:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr744;
	goto tr188;
tr744:
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st1349;
st1349:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1349;
case 1349:
#line 16173 "ext/dtext/dtext.cpp"
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto st1349;
	goto tr1778;
tr1514:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
#line 540 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1350;
st1350:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1350;
case 1350:
#line 16189 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 65: goto tr1780;
		case 69: goto tr1781;
		case 91: goto tr1548;
		case 97: goto tr1780;
		case 101: goto tr1781;
		case 123: goto tr1549;
	}
	if ( (*( sm->p)) < 66 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1547;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 98 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1547;
	} else
		goto tr1547;
	goto tr1525;
tr1780:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 540 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1351;
st1351:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1351;
case 1351:
#line 16217 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 78: goto tr1782;
		case 91: goto tr1548;
		case 110: goto tr1782;
		case 123: goto tr1549;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1547;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1547;
	} else
		goto tr1547;
	goto tr1525;
tr1782:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 540 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1352;
st1352:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1352;
case 1352:
#line 16243 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 75: goto tr1783;
		case 91: goto tr1548;
		case 107: goto tr1783;
		case 123: goto tr1549;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1547;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1547;
	} else
		goto tr1547;
	goto tr1525;
tr1783:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 540 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1353;
st1353:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1353;
case 1353:
#line 16269 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 65: goto tr1784;
		case 91: goto tr1548;
		case 97: goto tr1784;
		case 123: goto tr1549;
	}
	if ( (*( sm->p)) < 66 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1547;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 98 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1547;
	} else
		goto tr1547;
	goto tr1525;
tr1784:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 540 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1354;
st1354:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1354;
case 1354:
#line 16295 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 75: goto tr1785;
		case 91: goto tr1548;
		case 107: goto tr1785;
		case 123: goto tr1549;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1547;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1547;
	} else
		goto tr1547;
	goto tr1525;
tr1785:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 540 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1355;
st1355:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1355;
case 1355:
#line 16321 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 85: goto tr1786;
		case 91: goto tr1548;
		case 117: goto tr1786;
		case 123: goto tr1549;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1547;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1547;
	} else
		goto tr1547;
	goto tr1525;
tr1786:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 540 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1356;
st1356:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1356;
case 1356:
#line 16347 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 32: goto st594;
		case 91: goto tr1548;
		case 123: goto tr1549;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1547;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1547;
	} else
		goto tr1547;
	goto tr1525;
st594:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof594;
case 594:
	if ( (*( sm->p)) == 35 )
		goto st595;
	goto tr188;
st595:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof595;
case 595:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr746;
	goto tr188;
tr746:
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st1357;
st1357:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1357;
case 1357:
#line 16384 "ext/dtext/dtext.cpp"
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto st1357;
	goto tr1788;
tr1781:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 540 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1358;
st1358:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1358;
case 1358:
#line 16398 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 73: goto tr1790;
		case 91: goto tr1548;
		case 105: goto tr1790;
		case 123: goto tr1549;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1547;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1547;
	} else
		goto tr1547;
	goto tr1525;
tr1790:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 540 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1359;
st1359:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1359;
case 1359:
#line 16424 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 71: goto tr1791;
		case 91: goto tr1548;
		case 103: goto tr1791;
		case 123: goto tr1549;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1547;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1547;
	} else
		goto tr1547;
	goto tr1525;
tr1791:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 540 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1360;
st1360:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1360;
case 1360:
#line 16450 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 65: goto tr1792;
		case 91: goto tr1548;
		case 97: goto tr1792;
		case 123: goto tr1549;
	}
	if ( (*( sm->p)) < 66 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1547;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 98 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1547;
	} else
		goto tr1547;
	goto tr1525;
tr1792:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 540 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1361;
st1361:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1361;
case 1361:
#line 16476 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 32: goto st596;
		case 91: goto tr1548;
		case 123: goto tr1549;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1547;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1547;
	} else
		goto tr1547;
	goto tr1525;
st596:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof596;
case 596:
	if ( (*( sm->p)) == 35 )
		goto st597;
	goto tr188;
st597:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof597;
case 597:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr748;
	goto tr188;
tr748:
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st1362;
st1362:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1362;
case 1362:
#line 16513 "ext/dtext/dtext.cpp"
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto st1362;
	goto tr1794;
tr1515:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
#line 540 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1363;
st1363:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1363;
case 1363:
#line 16529 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 79: goto tr1796;
		case 87: goto tr1797;
		case 91: goto tr1548;
		case 111: goto tr1796;
		case 119: goto tr1797;
		case 123: goto tr1549;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1547;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1547;
	} else
		goto tr1547;
	goto tr1525;
tr1796:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 540 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1364;
st1364:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1364;
case 1364:
#line 16557 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 80: goto tr1798;
		case 91: goto tr1548;
		case 112: goto tr1798;
		case 123: goto tr1549;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1547;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1547;
	} else
		goto tr1547;
	goto tr1525;
tr1798:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 540 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1365;
st1365:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1365;
case 1365:
#line 16583 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 73: goto tr1799;
		case 91: goto tr1548;
		case 105: goto tr1799;
		case 123: goto tr1549;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1547;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1547;
	} else
		goto tr1547;
	goto tr1525;
tr1799:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 540 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1366;
st1366:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1366;
case 1366:
#line 16609 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 67: goto tr1800;
		case 91: goto tr1548;
		case 99: goto tr1800;
		case 123: goto tr1549;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1547;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1547;
	} else
		goto tr1547;
	goto tr1525;
tr1800:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 540 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1367;
st1367:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1367;
case 1367:
#line 16635 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 32: goto st598;
		case 91: goto tr1548;
		case 123: goto tr1549;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1547;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1547;
	} else
		goto tr1547;
	goto tr1525;
st598:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof598;
case 598:
	if ( (*( sm->p)) == 35 )
		goto st599;
	goto tr188;
st599:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof599;
case 599:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr750;
	goto tr188;
tr1804:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
	goto st1368;
tr750:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st1368;
st1368:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1368;
case 1368:
#line 16678 "ext/dtext/dtext.cpp"
	if ( (*( sm->p)) == 47 )
		goto tr1803;
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr1804;
	goto tr1802;
tr1803:
#line 72 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
	goto st600;
st600:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof600;
case 600:
#line 16692 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 80: goto st601;
		case 112: goto st601;
	}
	goto tr751;
st601:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof601;
case 601:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr753;
	goto tr751;
tr753:
#line 73 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st1369;
st1369:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1369;
case 1369:
#line 16713 "ext/dtext/dtext.cpp"
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto st1369;
	goto tr1805;
tr1797:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 540 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1370;
st1370:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1370;
case 1370:
#line 16727 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 73: goto tr1807;
		case 91: goto tr1548;
		case 105: goto tr1807;
		case 123: goto tr1549;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1547;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1547;
	} else
		goto tr1547;
	goto tr1525;
tr1807:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 540 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1371;
st1371:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1371;
case 1371:
#line 16753 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 84: goto tr1808;
		case 91: goto tr1548;
		case 116: goto tr1808;
		case 123: goto tr1549;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1547;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1547;
	} else
		goto tr1547;
	goto tr1525;
tr1808:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 540 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1372;
st1372:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1372;
case 1372:
#line 16779 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 84: goto tr1809;
		case 91: goto tr1548;
		case 116: goto tr1809;
		case 123: goto tr1549;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1547;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1547;
	} else
		goto tr1547;
	goto tr1525;
tr1809:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 540 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1373;
st1373:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1373;
case 1373:
#line 16805 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 69: goto tr1810;
		case 91: goto tr1548;
		case 101: goto tr1810;
		case 123: goto tr1549;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1547;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1547;
	} else
		goto tr1547;
	goto tr1525;
tr1810:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 540 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1374;
st1374:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1374;
case 1374:
#line 16831 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 82: goto tr1811;
		case 91: goto tr1548;
		case 114: goto tr1811;
		case 123: goto tr1549;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1547;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1547;
	} else
		goto tr1547;
	goto tr1525;
tr1811:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 540 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1375;
st1375:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1375;
case 1375:
#line 16857 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 32: goto st602;
		case 91: goto tr1548;
		case 123: goto tr1549;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1547;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1547;
	} else
		goto tr1547;
	goto tr1525;
st602:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof602;
case 602:
	if ( (*( sm->p)) == 35 )
		goto st603;
	goto tr188;
st603:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof603;
case 603:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr755;
	goto tr188;
tr755:
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st1376;
st1376:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1376;
case 1376:
#line 16894 "ext/dtext/dtext.cpp"
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto st1376;
	goto tr1813;
tr1516:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
#line 540 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1377;
st1377:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1377;
case 1377:
#line 16910 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 83: goto tr1815;
		case 91: goto tr1548;
		case 115: goto tr1815;
		case 123: goto tr1549;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1547;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1547;
	} else
		goto tr1547;
	goto tr1525;
tr1815:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 540 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1378;
st1378:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1378;
case 1378:
#line 16936 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 69: goto tr1816;
		case 91: goto tr1548;
		case 101: goto tr1816;
		case 123: goto tr1549;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1547;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1547;
	} else
		goto tr1547;
	goto tr1525;
tr1816:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 540 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1379;
st1379:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1379;
case 1379:
#line 16962 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 82: goto tr1817;
		case 91: goto tr1548;
		case 114: goto tr1817;
		case 123: goto tr1549;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1547;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1547;
	} else
		goto tr1547;
	goto tr1525;
tr1817:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 540 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1380;
st1380:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1380;
case 1380:
#line 16988 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 32: goto st604;
		case 91: goto tr1548;
		case 123: goto tr1549;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1547;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1547;
	} else
		goto tr1547;
	goto tr1525;
st604:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof604;
case 604:
	if ( (*( sm->p)) == 35 )
		goto st605;
	goto tr188;
st605:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof605;
case 605:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr757;
	goto tr188;
tr757:
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st1381;
st1381:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1381;
case 1381:
#line 17025 "ext/dtext/dtext.cpp"
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto st1381;
	goto tr1819;
tr1517:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
#line 540 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1382;
st1382:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1382;
case 1382:
#line 17041 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 73: goto tr1821;
		case 91: goto tr1548;
		case 105: goto tr1821;
		case 123: goto tr1549;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1547;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1547;
	} else
		goto tr1547;
	goto tr1525;
tr1821:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 540 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1383;
st1383:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1383;
case 1383:
#line 17067 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 75: goto tr1822;
		case 91: goto tr1548;
		case 107: goto tr1822;
		case 123: goto tr1549;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1547;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1547;
	} else
		goto tr1547;
	goto tr1525;
tr1822:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 540 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1384;
st1384:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1384;
case 1384:
#line 17093 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 73: goto tr1823;
		case 91: goto tr1548;
		case 105: goto tr1823;
		case 123: goto tr1549;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1547;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1547;
	} else
		goto tr1547;
	goto tr1525;
tr1823:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 540 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1385;
st1385:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1385;
case 1385:
#line 17119 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 32: goto st606;
		case 91: goto tr1548;
		case 123: goto tr1549;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1547;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1547;
	} else
		goto tr1547;
	goto tr1525;
st606:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof606;
case 606:
	if ( (*( sm->p)) == 35 )
		goto st607;
	goto tr188;
st607:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof607;
case 607:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr759;
	goto tr188;
tr759:
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st1386;
st1386:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1386;
case 1386:
#line 17156 "ext/dtext/dtext.cpp"
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto st1386;
	goto tr1825;
tr1518:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
#line 540 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1387;
st1387:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1387;
case 1387:
#line 17172 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 65: goto tr1827;
		case 91: goto tr1548;
		case 97: goto tr1827;
		case 123: goto tr1549;
	}
	if ( (*( sm->p)) < 66 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1547;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 98 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1547;
	} else
		goto tr1547;
	goto tr1525;
tr1827:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 540 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1388;
st1388:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1388;
case 1388:
#line 17198 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 78: goto tr1828;
		case 91: goto tr1548;
		case 110: goto tr1828;
		case 123: goto tr1549;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1547;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1547;
	} else
		goto tr1547;
	goto tr1525;
tr1828:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 540 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1389;
st1389:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1389;
case 1389:
#line 17224 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 68: goto tr1829;
		case 91: goto tr1548;
		case 100: goto tr1829;
		case 123: goto tr1549;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1547;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1547;
	} else
		goto tr1547;
	goto tr1525;
tr1829:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 540 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1390;
st1390:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1390;
case 1390:
#line 17250 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 69: goto tr1830;
		case 91: goto tr1548;
		case 101: goto tr1830;
		case 123: goto tr1549;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1547;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1547;
	} else
		goto tr1547;
	goto tr1525;
tr1830:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 540 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1391;
st1391:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1391;
case 1391:
#line 17276 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 82: goto tr1831;
		case 91: goto tr1548;
		case 114: goto tr1831;
		case 123: goto tr1549;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1547;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1547;
	} else
		goto tr1547;
	goto tr1525;
tr1831:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 540 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1392;
st1392:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1392;
case 1392:
#line 17302 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 69: goto tr1832;
		case 91: goto tr1548;
		case 101: goto tr1832;
		case 123: goto tr1549;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1547;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1547;
	} else
		goto tr1547;
	goto tr1525;
tr1832:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 540 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1393;
st1393:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1393;
case 1393:
#line 17328 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 32: goto st608;
		case 91: goto tr1548;
		case 123: goto tr1549;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1547;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1547;
	} else
		goto tr1547;
	goto tr1525;
st608:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof608;
case 608:
	if ( (*( sm->p)) == 35 )
		goto st609;
	goto tr188;
st609:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof609;
case 609:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr761;
	goto tr188;
tr761:
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st1394;
st1394:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1394;
case 1394:
#line 17365 "ext/dtext/dtext.cpp"
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto st1394;
	goto tr1834;
tr1519:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
#line 72 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
#line 544 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 91;}
	goto st1395;
st1395:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1395;
case 1395:
#line 17383 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 47: goto st610;
		case 66: goto st615;
		case 67: goto st616;
		case 69: goto st627;
		case 72: goto tr1840;
		case 73: goto st648;
		case 78: goto st649;
		case 81: goto st658;
		case 83: goto st663;
		case 84: goto st671;
		case 85: goto st673;
		case 91: goto st378;
		case 98: goto st615;
		case 99: goto st616;
		case 101: goto st627;
		case 104: goto tr1840;
		case 105: goto st648;
		case 110: goto st649;
		case 113: goto st658;
		case 115: goto st663;
		case 116: goto st671;
		case 117: goto st673;
	}
	goto tr1524;
st610:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof610;
case 610:
	switch( (*( sm->p)) ) {
		case 66: goto st611;
		case 69: goto st265;
		case 73: goto st612;
		case 81: goto st221;
		case 83: goto st613;
		case 84: goto st208;
		case 85: goto st614;
		case 98: goto st611;
		case 101: goto st265;
		case 105: goto st612;
		case 113: goto st221;
		case 115: goto st613;
		case 116: goto st208;
		case 117: goto st614;
	}
	goto tr193;
st611:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof611;
case 611:
	if ( (*( sm->p)) == 93 )
		goto tr766;
	goto tr193;
st612:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof612;
case 612:
	if ( (*( sm->p)) == 93 )
		goto tr767;
	goto tr193;
st613:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof613;
case 613:
	switch( (*( sm->p)) ) {
		case 80: goto st272;
		case 93: goto tr768;
		case 112: goto st272;
	}
	goto tr193;
st614:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof614;
case 614:
	if ( (*( sm->p)) == 93 )
		goto tr769;
	goto tr193;
st615:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof615;
case 615:
	if ( (*( sm->p)) == 93 )
		goto tr770;
	goto tr193;
st616:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof616;
case 616:
	switch( (*( sm->p)) ) {
		case 79: goto st617;
		case 111: goto st617;
	}
	goto tr193;
st617:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof617;
case 617:
	switch( (*( sm->p)) ) {
		case 68: goto st618;
		case 100: goto st618;
	}
	goto tr193;
st618:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof618;
case 618:
	switch( (*( sm->p)) ) {
		case 69: goto st619;
		case 101: goto st619;
	}
	goto tr193;
st619:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof619;
case 619:
	switch( (*( sm->p)) ) {
		case 9: goto st620;
		case 32: goto st620;
		case 61: goto st621;
		case 93: goto tr776;
	}
	goto tr193;
st620:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof620;
case 620:
	switch( (*( sm->p)) ) {
		case 9: goto st620;
		case 32: goto st620;
		case 61: goto st621;
	}
	goto tr193;
st621:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof621;
case 621:
	switch( (*( sm->p)) ) {
		case 9: goto st621;
		case 32: goto st621;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr777;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr777;
	} else
		goto tr777;
	goto tr193;
tr777:
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st622;
st622:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof622;
case 622:
#line 17541 "ext/dtext/dtext.cpp"
	if ( (*( sm->p)) == 93 )
		goto tr779;
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st622;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st622;
	} else
		goto st622;
	goto tr193;
tr779:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 72 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
	goto st1396;
st1396:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1396;
case 1396:
#line 17563 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr781;
		case 9: goto st623;
		case 10: goto tr781;
		case 13: goto st624;
		case 32: goto st623;
	}
	goto tr1847;
st623:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof623;
case 623:
	switch( (*( sm->p)) ) {
		case 0: goto tr781;
		case 9: goto st623;
		case 10: goto tr781;
		case 13: goto st624;
		case 32: goto st623;
	}
	goto tr780;
st624:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof624;
case 624:
	if ( (*( sm->p)) == 10 )
		goto tr781;
	goto tr780;
tr776:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
	goto st1397;
st1397:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1397;
case 1397:
#line 17599 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr785;
		case 9: goto st625;
		case 10: goto tr785;
		case 13: goto st626;
		case 32: goto st625;
	}
	goto tr1848;
st625:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof625;
case 625:
	switch( (*( sm->p)) ) {
		case 0: goto tr785;
		case 9: goto st625;
		case 10: goto tr785;
		case 13: goto st626;
		case 32: goto st625;
	}
	goto tr784;
st626:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof626;
case 626:
	if ( (*( sm->p)) == 10 )
		goto tr785;
	goto tr784;
st627:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof627;
case 627:
	switch( (*( sm->p)) ) {
		case 88: goto st628;
		case 120: goto st628;
	}
	goto tr193;
st628:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof628;
case 628:
	switch( (*( sm->p)) ) {
		case 80: goto st629;
		case 112: goto st629;
	}
	goto tr193;
st629:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof629;
case 629:
	switch( (*( sm->p)) ) {
		case 65: goto st630;
		case 97: goto st630;
	}
	goto tr193;
st630:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof630;
case 630:
	switch( (*( sm->p)) ) {
		case 78: goto st631;
		case 110: goto st631;
	}
	goto tr193;
st631:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof631;
case 631:
	switch( (*( sm->p)) ) {
		case 68: goto st632;
		case 100: goto st632;
	}
	goto tr193;
st632:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof632;
case 632:
	switch( (*( sm->p)) ) {
		case 9: goto st633;
		case 32: goto st633;
		case 61: goto st635;
		case 93: goto tr795;
	}
	goto tr193;
tr797:
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st633;
st633:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof633;
case 633:
#line 17691 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr193;
		case 9: goto tr797;
		case 10: goto tr193;
		case 13: goto tr193;
		case 32: goto tr797;
		case 61: goto tr798;
		case 93: goto tr799;
	}
	goto tr796;
tr796:
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st634;
st634:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof634;
case 634:
#line 17710 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr193;
		case 10: goto tr193;
		case 13: goto tr193;
		case 93: goto tr801;
	}
	goto st634;
tr798:
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st635;
st635:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof635;
case 635:
#line 17726 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr193;
		case 9: goto tr798;
		case 10: goto tr193;
		case 13: goto tr193;
		case 32: goto tr798;
		case 93: goto tr799;
	}
	goto tr796;
tr1840:
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st636;
st636:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof636;
case 636:
#line 17744 "ext/dtext/dtext.cpp"
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
		case 84: goto st638;
		case 116: goto st638;
	}
	goto tr193;
st638:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof638;
case 638:
	switch( (*( sm->p)) ) {
		case 80: goto st639;
		case 112: goto st639;
	}
	goto tr193;
st639:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof639;
case 639:
	switch( (*( sm->p)) ) {
		case 58: goto st640;
		case 83: goto st647;
		case 115: goto st647;
	}
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
	if ( (*( sm->p)) == 47 )
		goto st642;
	goto tr193;
st642:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof642;
case 642:
	switch( (*( sm->p)) ) {
		case 0: goto tr193;
		case 32: goto tr193;
	}
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr193;
	goto st643;
st643:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof643;
case 643:
	switch( (*( sm->p)) ) {
		case 0: goto tr193;
		case 32: goto tr193;
		case 93: goto tr810;
	}
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr193;
	goto st643;
tr810:
#line 72 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
	goto st644;
st644:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof644;
case 644:
#line 17823 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr193;
		case 32: goto tr193;
		case 40: goto st645;
		case 93: goto tr810;
	}
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr193;
	goto st643;
st645:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof645;
case 645:
	switch( (*( sm->p)) ) {
		case 0: goto tr193;
		case 10: goto tr193;
		case 13: goto tr193;
	}
	goto tr812;
tr812:
#line 73 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st646;
st646:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof646;
case 646:
#line 17851 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr193;
		case 10: goto tr193;
		case 13: goto tr193;
		case 41: goto tr814;
	}
	goto st646;
st647:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof647;
case 647:
	if ( (*( sm->p)) == 58 )
		goto st640;
	goto tr193;
st648:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof648;
case 648:
	if ( (*( sm->p)) == 93 )
		goto tr815;
	goto tr193;
st649:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof649;
case 649:
	switch( (*( sm->p)) ) {
		case 79: goto st650;
		case 111: goto st650;
	}
	goto tr193;
st650:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof650;
case 650:
	switch( (*( sm->p)) ) {
		case 68: goto st651;
		case 100: goto st651;
	}
	goto tr193;
st651:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof651;
case 651:
	switch( (*( sm->p)) ) {
		case 84: goto st652;
		case 116: goto st652;
	}
	goto tr193;
st652:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof652;
case 652:
	switch( (*( sm->p)) ) {
		case 69: goto st653;
		case 101: goto st653;
	}
	goto tr193;
st653:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof653;
case 653:
	switch( (*( sm->p)) ) {
		case 88: goto st654;
		case 120: goto st654;
	}
	goto tr193;
st654:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof654;
case 654:
	switch( (*( sm->p)) ) {
		case 84: goto st655;
		case 116: goto st655;
	}
	goto tr193;
st655:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof655;
case 655:
	if ( (*( sm->p)) == 93 )
		goto tr822;
	goto tr193;
tr822:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
	goto st1398;
st1398:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1398;
case 1398:
#line 17942 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr824;
		case 9: goto st656;
		case 10: goto tr824;
		case 13: goto st657;
		case 32: goto st656;
	}
	goto tr1849;
st656:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof656;
case 656:
	switch( (*( sm->p)) ) {
		case 0: goto tr824;
		case 9: goto st656;
		case 10: goto tr824;
		case 13: goto st657;
		case 32: goto st656;
	}
	goto tr823;
st657:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof657;
case 657:
	if ( (*( sm->p)) == 10 )
		goto tr824;
	goto tr823;
st658:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof658;
case 658:
	switch( (*( sm->p)) ) {
		case 85: goto st659;
		case 117: goto st659;
	}
	goto tr193;
st659:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof659;
case 659:
	switch( (*( sm->p)) ) {
		case 79: goto st660;
		case 111: goto st660;
	}
	goto tr193;
st660:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof660;
case 660:
	switch( (*( sm->p)) ) {
		case 84: goto st661;
		case 116: goto st661;
	}
	goto tr193;
st661:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof661;
case 661:
	switch( (*( sm->p)) ) {
		case 69: goto st662;
		case 101: goto st662;
	}
	goto tr193;
st662:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof662;
case 662:
	if ( (*( sm->p)) == 93 )
		goto tr831;
	goto tr193;
st663:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof663;
case 663:
	switch( (*( sm->p)) ) {
		case 80: goto st664;
		case 93: goto tr833;
		case 112: goto st664;
	}
	goto tr193;
st664:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof664;
case 664:
	switch( (*( sm->p)) ) {
		case 79: goto st665;
		case 111: goto st665;
	}
	goto tr193;
st665:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof665;
case 665:
	switch( (*( sm->p)) ) {
		case 73: goto st666;
		case 105: goto st666;
	}
	goto tr193;
st666:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof666;
case 666:
	switch( (*( sm->p)) ) {
		case 76: goto st667;
		case 108: goto st667;
	}
	goto tr193;
st667:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof667;
case 667:
	switch( (*( sm->p)) ) {
		case 69: goto st668;
		case 101: goto st668;
	}
	goto tr193;
st668:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof668;
case 668:
	switch( (*( sm->p)) ) {
		case 82: goto st669;
		case 114: goto st669;
	}
	goto tr193;
st669:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof669;
case 669:
	switch( (*( sm->p)) ) {
		case 83: goto st670;
		case 93: goto tr840;
		case 115: goto st670;
	}
	goto tr193;
st670:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof670;
case 670:
	if ( (*( sm->p)) == 93 )
		goto tr840;
	goto tr193;
st671:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof671;
case 671:
	switch( (*( sm->p)) ) {
		case 78: goto st672;
		case 110: goto st672;
	}
	goto tr193;
st672:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof672;
case 672:
	if ( (*( sm->p)) == 93 )
		goto tr842;
	goto tr193;
st673:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof673;
case 673:
	switch( (*( sm->p)) ) {
		case 82: goto st674;
		case 93: goto tr844;
		case 114: goto st674;
	}
	goto tr193;
st674:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof674;
case 674:
	switch( (*( sm->p)) ) {
		case 76: goto st675;
		case 108: goto st675;
	}
	goto tr193;
st675:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof675;
case 675:
	switch( (*( sm->p)) ) {
		case 9: goto st676;
		case 32: goto st676;
		case 61: goto st677;
		case 93: goto st717;
	}
	goto tr193;
st676:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof676;
case 676:
	switch( (*( sm->p)) ) {
		case 9: goto st676;
		case 32: goto st676;
		case 61: goto st677;
	}
	goto tr193;
st677:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof677;
case 677:
	switch( (*( sm->p)) ) {
		case 9: goto st677;
		case 32: goto st677;
		case 34: goto st678;
		case 35: goto tr850;
		case 39: goto st699;
		case 47: goto tr850;
		case 72: goto tr852;
		case 104: goto tr852;
	}
	goto tr193;
st678:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof678;
case 678:
	switch( (*( sm->p)) ) {
		case 35: goto tr853;
		case 47: goto tr853;
		case 72: goto tr854;
		case 104: goto tr854;
	}
	goto tr193;
tr853:
#line 73 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st679;
st679:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof679;
case 679:
#line 18175 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr193;
		case 32: goto tr193;
		case 34: goto tr856;
	}
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr193;
	goto st679;
tr856:
#line 74 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
	goto st680;
st680:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof680;
case 680:
#line 18192 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto st680;
		case 32: goto st680;
		case 93: goto st681;
	}
	goto tr193;
tr879:
#line 74 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
	goto st681;
st681:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof681;
case 681:
#line 18207 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr193;
		case 9: goto tr860;
		case 10: goto tr193;
		case 13: goto tr193;
		case 32: goto tr860;
	}
	goto tr859;
tr859:
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st682;
st682:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof682;
case 682:
#line 18224 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr193;
		case 9: goto tr862;
		case 10: goto tr193;
		case 13: goto tr193;
		case 32: goto tr862;
		case 91: goto tr863;
	}
	goto st682;
tr862:
#line 72 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
	goto st683;
st683:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof683;
case 683:
#line 18242 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto st683;
		case 32: goto st683;
		case 91: goto st684;
	}
	goto tr193;
tr863:
#line 72 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
	goto st684;
st684:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof684;
case 684:
#line 18257 "ext/dtext/dtext.cpp"
	if ( (*( sm->p)) == 47 )
		goto st685;
	goto tr193;
st685:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof685;
case 685:
	switch( (*( sm->p)) ) {
		case 85: goto st686;
		case 117: goto st686;
	}
	goto tr193;
st686:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof686;
case 686:
	switch( (*( sm->p)) ) {
		case 82: goto st687;
		case 114: goto st687;
	}
	goto tr193;
st687:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof687;
case 687:
	switch( (*( sm->p)) ) {
		case 76: goto st688;
		case 108: goto st688;
	}
	goto tr193;
st688:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof688;
case 688:
	if ( (*( sm->p)) == 93 )
		goto tr870;
	goto tr193;
tr860:
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st689;
st689:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof689;
case 689:
#line 18303 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr193;
		case 9: goto tr862;
		case 10: goto tr193;
		case 13: goto tr193;
		case 32: goto tr862;
		case 91: goto tr863;
	}
	goto tr859;
tr854:
#line 73 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st690;
st690:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof690;
case 690:
#line 18321 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 84: goto st691;
		case 116: goto st691;
	}
	goto tr193;
st691:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof691;
case 691:
	switch( (*( sm->p)) ) {
		case 84: goto st692;
		case 116: goto st692;
	}
	goto tr193;
st692:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof692;
case 692:
	switch( (*( sm->p)) ) {
		case 80: goto st693;
		case 112: goto st693;
	}
	goto tr193;
st693:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof693;
case 693:
	switch( (*( sm->p)) ) {
		case 58: goto st694;
		case 83: goto st697;
		case 115: goto st697;
	}
	goto tr193;
st694:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof694;
case 694:
	if ( (*( sm->p)) == 47 )
		goto st695;
	goto tr193;
st695:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof695;
case 695:
	if ( (*( sm->p)) == 47 )
		goto st696;
	goto tr193;
st696:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof696;
case 696:
	switch( (*( sm->p)) ) {
		case 0: goto tr193;
		case 32: goto tr193;
	}
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr193;
	goto st679;
st697:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof697;
case 697:
	if ( (*( sm->p)) == 58 )
		goto st694;
	goto tr193;
tr850:
#line 73 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st698;
st698:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof698;
case 698:
#line 18395 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr193;
		case 9: goto tr856;
		case 32: goto tr856;
		case 93: goto tr879;
	}
	if ( 10 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr193;
	goto st698;
st699:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof699;
case 699:
	switch( (*( sm->p)) ) {
		case 35: goto tr880;
		case 47: goto tr880;
		case 72: goto tr881;
		case 104: goto tr881;
	}
	goto tr193;
tr880:
#line 73 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st700;
st700:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof700;
case 700:
#line 18424 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr193;
		case 32: goto tr193;
		case 39: goto tr856;
	}
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr193;
	goto st700;
tr881:
#line 73 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st701;
st701:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof701;
case 701:
#line 18441 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 84: goto st702;
		case 116: goto st702;
	}
	goto tr193;
st702:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof702;
case 702:
	switch( (*( sm->p)) ) {
		case 84: goto st703;
		case 116: goto st703;
	}
	goto tr193;
st703:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof703;
case 703:
	switch( (*( sm->p)) ) {
		case 80: goto st704;
		case 112: goto st704;
	}
	goto tr193;
st704:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof704;
case 704:
	switch( (*( sm->p)) ) {
		case 58: goto st705;
		case 83: goto st708;
		case 115: goto st708;
	}
	goto tr193;
st705:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof705;
case 705:
	if ( (*( sm->p)) == 47 )
		goto st706;
	goto tr193;
st706:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof706;
case 706:
	if ( (*( sm->p)) == 47 )
		goto st707;
	goto tr193;
st707:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof707;
case 707:
	switch( (*( sm->p)) ) {
		case 0: goto tr193;
		case 32: goto tr193;
	}
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr193;
	goto st700;
st708:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof708;
case 708:
	if ( (*( sm->p)) == 58 )
		goto st705;
	goto tr193;
tr852:
#line 73 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st709;
st709:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof709;
case 709:
#line 18515 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 84: goto st710;
		case 116: goto st710;
	}
	goto tr193;
st710:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof710;
case 710:
	switch( (*( sm->p)) ) {
		case 84: goto st711;
		case 116: goto st711;
	}
	goto tr193;
st711:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof711;
case 711:
	switch( (*( sm->p)) ) {
		case 80: goto st712;
		case 112: goto st712;
	}
	goto tr193;
st712:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof712;
case 712:
	switch( (*( sm->p)) ) {
		case 58: goto st713;
		case 83: goto st716;
		case 115: goto st716;
	}
	goto tr193;
st713:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof713;
case 713:
	if ( (*( sm->p)) == 47 )
		goto st714;
	goto tr193;
st714:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof714;
case 714:
	if ( (*( sm->p)) == 47 )
		goto st715;
	goto tr193;
st715:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof715;
case 715:
	switch( (*( sm->p)) ) {
		case 0: goto tr193;
		case 32: goto tr193;
	}
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr193;
	goto st698;
st716:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof716;
case 716:
	if ( (*( sm->p)) == 58 )
		goto st713;
	goto tr193;
st717:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof717;
case 717:
	switch( (*( sm->p)) ) {
		case 9: goto st717;
		case 32: goto st717;
		case 35: goto tr897;
		case 47: goto tr897;
		case 72: goto tr898;
		case 104: goto tr898;
	}
	goto tr193;
tr897:
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st718;
st718:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof718;
case 718:
#line 18602 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr193;
		case 9: goto tr900;
		case 32: goto tr900;
		case 91: goto tr901;
	}
	if ( 10 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr193;
	goto st718;
tr900:
#line 72 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
	goto st719;
st719:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof719;
case 719:
#line 18620 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto st719;
		case 32: goto st719;
		case 91: goto st720;
	}
	goto tr193;
st720:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof720;
case 720:
	if ( (*( sm->p)) == 47 )
		goto st721;
	goto tr193;
st721:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof721;
case 721:
	switch( (*( sm->p)) ) {
		case 85: goto st722;
		case 117: goto st722;
	}
	goto tr193;
st722:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof722;
case 722:
	switch( (*( sm->p)) ) {
		case 82: goto st723;
		case 114: goto st723;
	}
	goto tr193;
st723:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof723;
case 723:
	switch( (*( sm->p)) ) {
		case 76: goto st724;
		case 108: goto st724;
	}
	goto tr193;
st724:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof724;
case 724:
	if ( (*( sm->p)) == 93 )
		goto tr908;
	goto tr193;
tr901:
#line 72 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
	goto st725;
st725:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof725;
case 725:
#line 18676 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr193;
		case 9: goto tr900;
		case 32: goto tr900;
		case 47: goto st726;
		case 91: goto tr901;
	}
	if ( 10 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr193;
	goto st718;
st726:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof726;
case 726:
	switch( (*( sm->p)) ) {
		case 0: goto tr193;
		case 9: goto tr900;
		case 32: goto tr900;
		case 85: goto st727;
		case 91: goto tr901;
		case 117: goto st727;
	}
	if ( 10 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr193;
	goto st718;
st727:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof727;
case 727:
	switch( (*( sm->p)) ) {
		case 0: goto tr193;
		case 9: goto tr900;
		case 32: goto tr900;
		case 82: goto st728;
		case 91: goto tr901;
		case 114: goto st728;
	}
	if ( 10 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr193;
	goto st718;
st728:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof728;
case 728:
	switch( (*( sm->p)) ) {
		case 0: goto tr193;
		case 9: goto tr900;
		case 32: goto tr900;
		case 76: goto st729;
		case 91: goto tr901;
		case 108: goto st729;
	}
	if ( 10 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr193;
	goto st718;
st729:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof729;
case 729:
	switch( (*( sm->p)) ) {
		case 0: goto tr193;
		case 9: goto tr900;
		case 32: goto tr900;
		case 91: goto tr901;
		case 93: goto tr908;
	}
	if ( 10 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr193;
	goto st718;
tr898:
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st730;
st730:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof730;
case 730:
#line 18754 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 84: goto st731;
		case 116: goto st731;
	}
	goto tr193;
st731:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof731;
case 731:
	switch( (*( sm->p)) ) {
		case 84: goto st732;
		case 116: goto st732;
	}
	goto tr193;
st732:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof732;
case 732:
	switch( (*( sm->p)) ) {
		case 80: goto st733;
		case 112: goto st733;
	}
	goto tr193;
st733:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof733;
case 733:
	switch( (*( sm->p)) ) {
		case 58: goto st734;
		case 83: goto st737;
		case 115: goto st737;
	}
	goto tr193;
st734:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof734;
case 734:
	if ( (*( sm->p)) == 47 )
		goto st735;
	goto tr193;
st735:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof735;
case 735:
	if ( (*( sm->p)) == 47 )
		goto st736;
	goto tr193;
st736:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof736;
case 736:
	switch( (*( sm->p)) ) {
		case 0: goto tr193;
		case 32: goto tr193;
	}
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr193;
	goto st718;
st737:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof737;
case 737:
	if ( (*( sm->p)) == 58 )
		goto st734;
	goto tr193;
tr1520:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
#line 72 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
#line 544 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 91;}
	goto st1399;
st1399:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1399;
case 1399:
#line 18834 "ext/dtext/dtext.cpp"
	if ( (*( sm->p)) == 123 )
		goto st431;
	goto tr1524;
tr1521:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 544 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 91;}
	goto st1400;
st1400:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1400;
case 1400:
#line 18848 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 47: goto st738;
		case 65: goto st749;
		case 66: goto st772;
		case 67: goto st782;
		case 69: goto st789;
		case 72: goto tr1855;
		case 73: goto st790;
		case 78: goto st808;
		case 81: goto st777;
		case 83: goto st815;
		case 84: goto st828;
		case 85: goto st830;
		case 97: goto st749;
		case 98: goto st772;
		case 99: goto st782;
		case 101: goto st789;
		case 104: goto tr1855;
		case 105: goto st790;
		case 110: goto st808;
		case 113: goto st777;
		case 115: goto st815;
		case 116: goto st828;
		case 117: goto st830;
	}
	goto tr1524;
st738:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof738;
case 738:
	switch( (*( sm->p)) ) {
		case 66: goto st739;
		case 69: goto st740;
		case 73: goto st741;
		case 81: goto st232;
		case 83: goto st742;
		case 84: goto st202;
		case 85: goto st748;
		case 98: goto st739;
		case 101: goto st740;
		case 105: goto st741;
		case 113: goto st232;
		case 115: goto st742;
		case 116: goto st202;
		case 117: goto st748;
	}
	goto tr193;
st739:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof739;
case 739:
	switch( (*( sm->p)) ) {
		case 62: goto tr766;
		case 76: goto st217;
		case 108: goto st217;
	}
	goto tr193;
st740:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof740;
case 740:
	switch( (*( sm->p)) ) {
		case 77: goto st741;
		case 88: goto st227;
		case 109: goto st741;
		case 120: goto st227;
	}
	goto tr193;
st741:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof741;
case 741:
	if ( (*( sm->p)) == 62 )
		goto tr767;
	goto tr193;
st742:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof742;
case 742:
	switch( (*( sm->p)) ) {
		case 62: goto tr768;
		case 80: goto st238;
		case 84: goto st743;
		case 112: goto st238;
		case 116: goto st743;
	}
	goto tr193;
st743:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof743;
case 743:
	switch( (*( sm->p)) ) {
		case 82: goto st744;
		case 114: goto st744;
	}
	goto tr193;
st744:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof744;
case 744:
	switch( (*( sm->p)) ) {
		case 79: goto st745;
		case 111: goto st745;
	}
	goto tr193;
st745:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof745;
case 745:
	switch( (*( sm->p)) ) {
		case 78: goto st746;
		case 110: goto st746;
	}
	goto tr193;
st746:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof746;
case 746:
	switch( (*( sm->p)) ) {
		case 71: goto st747;
		case 103: goto st747;
	}
	goto tr193;
st747:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof747;
case 747:
	if ( (*( sm->p)) == 62 )
		goto tr766;
	goto tr193;
st748:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof748;
case 748:
	if ( (*( sm->p)) == 62 )
		goto tr769;
	goto tr193;
st749:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof749;
case 749:
	switch( (*( sm->p)) ) {
		case 9: goto st750;
		case 32: goto st750;
	}
	goto tr193;
st750:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof750;
case 750:
	switch( (*( sm->p)) ) {
		case 9: goto st750;
		case 32: goto st750;
		case 72: goto st751;
		case 104: goto st751;
	}
	goto tr193;
st751:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof751;
case 751:
	switch( (*( sm->p)) ) {
		case 82: goto st752;
		case 114: goto st752;
	}
	goto tr193;
st752:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof752;
case 752:
	switch( (*( sm->p)) ) {
		case 69: goto st753;
		case 101: goto st753;
	}
	goto tr193;
st753:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof753;
case 753:
	switch( (*( sm->p)) ) {
		case 70: goto st754;
		case 102: goto st754;
	}
	goto tr193;
st754:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof754;
case 754:
	if ( (*( sm->p)) == 61 )
		goto st755;
	goto tr193;
st755:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof755;
case 755:
	if ( (*( sm->p)) == 34 )
		goto st756;
	goto tr193;
st756:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof756;
case 756:
	switch( (*( sm->p)) ) {
		case 35: goto tr937;
		case 47: goto tr937;
		case 72: goto tr938;
		case 104: goto tr938;
	}
	goto tr193;
tr937:
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st757;
st757:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof757;
case 757:
#line 19066 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr193;
		case 32: goto tr193;
		case 34: goto tr940;
	}
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr193;
	goto st757;
tr940:
#line 72 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
	goto st758;
st758:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof758;
case 758:
#line 19083 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr193;
		case 32: goto tr193;
		case 34: goto tr940;
		case 62: goto st759;
	}
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr193;
	goto st757;
st759:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof759;
case 759:
	switch( (*( sm->p)) ) {
		case 0: goto tr193;
		case 10: goto tr193;
		case 13: goto tr193;
	}
	goto tr942;
tr942:
#line 73 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st760;
st760:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof760;
case 760:
#line 19111 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr193;
		case 10: goto tr193;
		case 13: goto tr193;
		case 60: goto tr944;
	}
	goto st760;
tr944:
#line 74 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
	goto st761;
st761:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof761;
case 761:
#line 19127 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr193;
		case 10: goto tr193;
		case 13: goto tr193;
		case 47: goto st762;
		case 60: goto tr944;
	}
	goto st760;
st762:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof762;
case 762:
	switch( (*( sm->p)) ) {
		case 0: goto tr193;
		case 10: goto tr193;
		case 13: goto tr193;
		case 60: goto tr944;
		case 65: goto st763;
		case 97: goto st763;
	}
	goto st760;
st763:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof763;
case 763:
	switch( (*( sm->p)) ) {
		case 0: goto tr193;
		case 10: goto tr193;
		case 13: goto tr193;
		case 60: goto tr944;
		case 62: goto tr947;
	}
	goto st760;
tr938:
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st764;
st764:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof764;
case 764:
#line 19169 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 84: goto st765;
		case 116: goto st765;
	}
	goto tr193;
st765:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof765;
case 765:
	switch( (*( sm->p)) ) {
		case 84: goto st766;
		case 116: goto st766;
	}
	goto tr193;
st766:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof766;
case 766:
	switch( (*( sm->p)) ) {
		case 80: goto st767;
		case 112: goto st767;
	}
	goto tr193;
st767:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof767;
case 767:
	switch( (*( sm->p)) ) {
		case 58: goto st768;
		case 83: goto st771;
		case 115: goto st771;
	}
	goto tr193;
st768:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof768;
case 768:
	if ( (*( sm->p)) == 47 )
		goto st769;
	goto tr193;
st769:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof769;
case 769:
	if ( (*( sm->p)) == 47 )
		goto st770;
	goto tr193;
st770:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof770;
case 770:
	switch( (*( sm->p)) ) {
		case 0: goto tr193;
		case 32: goto tr193;
	}
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr193;
	goto st757;
st771:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof771;
case 771:
	if ( (*( sm->p)) == 58 )
		goto st768;
	goto tr193;
st772:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof772;
case 772:
	switch( (*( sm->p)) ) {
		case 62: goto tr770;
		case 76: goto st773;
		case 108: goto st773;
	}
	goto tr193;
st773:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof773;
case 773:
	switch( (*( sm->p)) ) {
		case 79: goto st774;
		case 111: goto st774;
	}
	goto tr193;
st774:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof774;
case 774:
	switch( (*( sm->p)) ) {
		case 67: goto st775;
		case 99: goto st775;
	}
	goto tr193;
st775:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof775;
case 775:
	switch( (*( sm->p)) ) {
		case 75: goto st776;
		case 107: goto st776;
	}
	goto tr193;
st776:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof776;
case 776:
	switch( (*( sm->p)) ) {
		case 81: goto st777;
		case 113: goto st777;
	}
	goto tr193;
st777:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof777;
case 777:
	switch( (*( sm->p)) ) {
		case 85: goto st778;
		case 117: goto st778;
	}
	goto tr193;
st778:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof778;
case 778:
	switch( (*( sm->p)) ) {
		case 79: goto st779;
		case 111: goto st779;
	}
	goto tr193;
st779:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof779;
case 779:
	switch( (*( sm->p)) ) {
		case 84: goto st780;
		case 116: goto st780;
	}
	goto tr193;
st780:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof780;
case 780:
	switch( (*( sm->p)) ) {
		case 69: goto st781;
		case 101: goto st781;
	}
	goto tr193;
st781:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof781;
case 781:
	if ( (*( sm->p)) == 62 )
		goto tr831;
	goto tr193;
st782:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof782;
case 782:
	switch( (*( sm->p)) ) {
		case 79: goto st783;
		case 111: goto st783;
	}
	goto tr193;
st783:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof783;
case 783:
	switch( (*( sm->p)) ) {
		case 68: goto st784;
		case 100: goto st784;
	}
	goto tr193;
st784:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof784;
case 784:
	switch( (*( sm->p)) ) {
		case 69: goto st785;
		case 101: goto st785;
	}
	goto tr193;
st785:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof785;
case 785:
	switch( (*( sm->p)) ) {
		case 9: goto st786;
		case 32: goto st786;
		case 61: goto st787;
		case 62: goto tr776;
	}
	goto tr193;
st786:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof786;
case 786:
	switch( (*( sm->p)) ) {
		case 9: goto st786;
		case 32: goto st786;
		case 61: goto st787;
	}
	goto tr193;
st787:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof787;
case 787:
	switch( (*( sm->p)) ) {
		case 9: goto st787;
		case 32: goto st787;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr969;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr969;
	} else
		goto tr969;
	goto tr193;
tr969:
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st788;
st788:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof788;
case 788:
#line 19397 "ext/dtext/dtext.cpp"
	if ( (*( sm->p)) == 62 )
		goto tr779;
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st788;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st788;
	} else
		goto st788;
	goto tr193;
st789:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof789;
case 789:
	switch( (*( sm->p)) ) {
		case 77: goto st790;
		case 88: goto st791;
		case 109: goto st790;
		case 120: goto st791;
	}
	goto tr193;
st790:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof790;
case 790:
	if ( (*( sm->p)) == 62 )
		goto tr815;
	goto tr193;
st791:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof791;
case 791:
	switch( (*( sm->p)) ) {
		case 80: goto st792;
		case 112: goto st792;
	}
	goto tr193;
st792:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof792;
case 792:
	switch( (*( sm->p)) ) {
		case 65: goto st793;
		case 97: goto st793;
	}
	goto tr193;
st793:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof793;
case 793:
	switch( (*( sm->p)) ) {
		case 78: goto st794;
		case 110: goto st794;
	}
	goto tr193;
st794:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof794;
case 794:
	switch( (*( sm->p)) ) {
		case 68: goto st795;
		case 100: goto st795;
	}
	goto tr193;
st795:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof795;
case 795:
	switch( (*( sm->p)) ) {
		case 9: goto st796;
		case 32: goto st796;
		case 61: goto st798;
		case 62: goto tr795;
	}
	goto tr193;
tr980:
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st796;
st796:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof796;
case 796:
#line 19482 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr193;
		case 9: goto tr980;
		case 10: goto tr193;
		case 13: goto tr193;
		case 32: goto tr980;
		case 61: goto tr981;
		case 62: goto tr799;
	}
	goto tr979;
tr979:
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st797;
st797:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof797;
case 797:
#line 19501 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr193;
		case 10: goto tr193;
		case 13: goto tr193;
		case 62: goto tr801;
	}
	goto st797;
tr981:
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st798;
st798:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof798;
case 798:
#line 19517 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr193;
		case 9: goto tr981;
		case 10: goto tr193;
		case 13: goto tr193;
		case 32: goto tr981;
		case 62: goto tr799;
	}
	goto tr979;
tr1855:
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st799;
st799:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof799;
case 799:
#line 19535 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 84: goto st800;
		case 116: goto st800;
	}
	goto tr193;
st800:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof800;
case 800:
	switch( (*( sm->p)) ) {
		case 84: goto st801;
		case 116: goto st801;
	}
	goto tr193;
st801:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof801;
case 801:
	switch( (*( sm->p)) ) {
		case 80: goto st802;
		case 112: goto st802;
	}
	goto tr193;
st802:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof802;
case 802:
	switch( (*( sm->p)) ) {
		case 58: goto st803;
		case 83: goto st807;
		case 115: goto st807;
	}
	goto tr193;
st803:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof803;
case 803:
	if ( (*( sm->p)) == 47 )
		goto st804;
	goto tr193;
st804:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof804;
case 804:
	if ( (*( sm->p)) == 47 )
		goto st805;
	goto tr193;
st805:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof805;
case 805:
	switch( (*( sm->p)) ) {
		case 0: goto tr193;
		case 32: goto tr193;
	}
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr193;
	goto st806;
st806:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof806;
case 806:
	switch( (*( sm->p)) ) {
		case 0: goto tr193;
		case 32: goto tr193;
		case 62: goto tr991;
	}
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr193;
	goto st806;
st807:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof807;
case 807:
	if ( (*( sm->p)) == 58 )
		goto st803;
	goto tr193;
st808:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof808;
case 808:
	switch( (*( sm->p)) ) {
		case 79: goto st809;
		case 111: goto st809;
	}
	goto tr193;
st809:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof809;
case 809:
	switch( (*( sm->p)) ) {
		case 68: goto st810;
		case 100: goto st810;
	}
	goto tr193;
st810:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof810;
case 810:
	switch( (*( sm->p)) ) {
		case 84: goto st811;
		case 116: goto st811;
	}
	goto tr193;
st811:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof811;
case 811:
	switch( (*( sm->p)) ) {
		case 69: goto st812;
		case 101: goto st812;
	}
	goto tr193;
st812:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof812;
case 812:
	switch( (*( sm->p)) ) {
		case 88: goto st813;
		case 120: goto st813;
	}
	goto tr193;
st813:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof813;
case 813:
	switch( (*( sm->p)) ) {
		case 84: goto st814;
		case 116: goto st814;
	}
	goto tr193;
st814:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof814;
case 814:
	if ( (*( sm->p)) == 62 )
		goto tr822;
	goto tr193;
st815:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof815;
case 815:
	switch( (*( sm->p)) ) {
		case 62: goto tr833;
		case 80: goto st816;
		case 84: goto st823;
		case 112: goto st816;
		case 116: goto st823;
	}
	goto tr193;
st816:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof816;
case 816:
	switch( (*( sm->p)) ) {
		case 79: goto st817;
		case 111: goto st817;
	}
	goto tr193;
st817:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof817;
case 817:
	switch( (*( sm->p)) ) {
		case 73: goto st818;
		case 105: goto st818;
	}
	goto tr193;
st818:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof818;
case 818:
	switch( (*( sm->p)) ) {
		case 76: goto st819;
		case 108: goto st819;
	}
	goto tr193;
st819:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof819;
case 819:
	switch( (*( sm->p)) ) {
		case 69: goto st820;
		case 101: goto st820;
	}
	goto tr193;
st820:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof820;
case 820:
	switch( (*( sm->p)) ) {
		case 82: goto st821;
		case 114: goto st821;
	}
	goto tr193;
st821:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof821;
case 821:
	switch( (*( sm->p)) ) {
		case 62: goto tr840;
		case 83: goto st822;
		case 115: goto st822;
	}
	goto tr193;
st822:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof822;
case 822:
	if ( (*( sm->p)) == 62 )
		goto tr840;
	goto tr193;
st823:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof823;
case 823:
	switch( (*( sm->p)) ) {
		case 82: goto st824;
		case 114: goto st824;
	}
	goto tr193;
st824:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof824;
case 824:
	switch( (*( sm->p)) ) {
		case 79: goto st825;
		case 111: goto st825;
	}
	goto tr193;
st825:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof825;
case 825:
	switch( (*( sm->p)) ) {
		case 78: goto st826;
		case 110: goto st826;
	}
	goto tr193;
st826:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof826;
case 826:
	switch( (*( sm->p)) ) {
		case 71: goto st827;
		case 103: goto st827;
	}
	goto tr193;
st827:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof827;
case 827:
	if ( (*( sm->p)) == 62 )
		goto tr770;
	goto tr193;
st828:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof828;
case 828:
	switch( (*( sm->p)) ) {
		case 78: goto st829;
		case 110: goto st829;
	}
	goto tr193;
st829:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof829;
case 829:
	if ( (*( sm->p)) == 62 )
		goto tr842;
	goto tr193;
st830:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof830;
case 830:
	if ( (*( sm->p)) == 62 )
		goto tr844;
	goto tr193;
tr1522:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 544 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 91;}
	goto st1401;
st1401:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1401;
case 1401:
#line 19824 "ext/dtext/dtext.cpp"
	_widec = (*( sm->p));
	if ( 64 <= (*( sm->p)) && (*( sm->p)) <= 64 ) {
		_widec = (short)(640 + ((*( sm->p)) - -128));
		if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
	}
	switch( _widec ) {
		case 47: goto st738;
		case 65: goto st749;
		case 66: goto st772;
		case 67: goto st782;
		case 69: goto st789;
		case 72: goto tr1855;
		case 73: goto st790;
		case 78: goto st808;
		case 81: goto st777;
		case 83: goto st815;
		case 84: goto st828;
		case 85: goto st830;
		case 97: goto st749;
		case 98: goto st772;
		case 99: goto st782;
		case 101: goto st789;
		case 104: goto tr1855;
		case 105: goto st790;
		case 110: goto st808;
		case 113: goto st777;
		case 115: goto st815;
		case 116: goto st828;
		case 117: goto st830;
		case 1088: goto st831;
	}
	goto tr1524;
st831:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof831;
case 831:
	_widec = (*( sm->p));
	if ( (*( sm->p)) < 1 ) {
		if ( (*( sm->p)) <= -1 ) {
			_widec = (short)(640 + ((*( sm->p)) - -128));
			if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
		}
	} else if ( (*( sm->p)) > 8 ) {
		if ( (*( sm->p)) > 31 ) {
			if ( 33 <= (*( sm->p)) )
 {				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else if ( (*( sm->p)) >= 14 ) {
			_widec = (short)(640 + ((*( sm->p)) - -128));
			if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
		}
	} else {
		_widec = (short)(640 + ((*( sm->p)) - -128));
		if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
	}
	if ( _widec < 1025 ) {
		if ( 896 <= _widec && _widec <= 1023 )
			goto tr1011;
	} else if ( _widec > 1032 ) {
		if ( _widec > 1055 ) {
			if ( 1057 <= _widec && _widec <= 1151 )
				goto tr1011;
		} else if ( _widec >= 1038 )
			goto tr1011;
	} else
		goto tr1011;
	goto tr193;
tr1011:
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st832;
st832:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof832;
case 832:
#line 19911 "ext/dtext/dtext.cpp"
	_widec = (*( sm->p));
	if ( (*( sm->p)) < 11 ) {
		if ( (*( sm->p)) > -1 ) {
			if ( 1 <= (*( sm->p)) && (*( sm->p)) <= 9 ) {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else {
			_widec = (short)(640 + ((*( sm->p)) - -128));
			if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
		}
	} else if ( (*( sm->p)) > 12 ) {
		if ( (*( sm->p)) < 62 ) {
			if ( 14 <= (*( sm->p)) && (*( sm->p)) <= 61 ) {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else if ( (*( sm->p)) > 62 ) {
			if ( 63 <= (*( sm->p)) )
 {				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else {
			_widec = (short)(640 + ((*( sm->p)) - -128));
			if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
		}
	} else {
		_widec = (short)(640 + ((*( sm->p)) - -128));
		if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
	}
	if ( _widec == 1086 )
		goto tr1013;
	if ( _widec < 1025 ) {
		if ( 896 <= _widec && _widec <= 1023 )
			goto st832;
	} else if ( _widec > 1033 ) {
		if ( _widec > 1036 ) {
			if ( 1038 <= _widec && _widec <= 1151 )
				goto st832;
		} else if ( _widec >= 1035 )
			goto st832;
	} else
		goto st832;
	goto tr193;
tr1523:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 544 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 91;}
	goto st1402;
st1402:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1402;
case 1402:
#line 19978 "ext/dtext/dtext.cpp"
	_widec = (*( sm->p));
	if ( (*( sm->p)) < 1 ) {
		if ( (*( sm->p)) < -29 ) {
			if ( (*( sm->p)) < -32 ) {
				if ( -62 <= (*( sm->p)) && (*( sm->p)) <= -33 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > -31 ) {
				if ( -30 <= (*( sm->p)) && (*( sm->p)) <= -30 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else if ( (*( sm->p)) > -29 ) {
			if ( (*( sm->p)) < -17 ) {
				if ( -28 <= (*( sm->p)) && (*( sm->p)) <= -18 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > -17 ) {
				if ( -16 <= (*( sm->p)) && (*( sm->p)) <= -12 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else {
			_widec = (short)(640 + ((*( sm->p)) - -128));
			if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
		}
	} else if ( (*( sm->p)) > 8 ) {
		if ( (*( sm->p)) < 65 ) {
			if ( (*( sm->p)) < 46 ) {
				if ( 14 <= (*( sm->p)) && (*( sm->p)) <= 31 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > 46 ) {
				if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else if ( (*( sm->p)) > 90 ) {
			if ( (*( sm->p)) < 97 ) {
				if ( 95 <= (*( sm->p)) && (*( sm->p)) <= 95 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > 122 ) {
				if ( 127 <= (*( sm->p)) )
 {					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else {
			_widec = (short)(640 + ((*( sm->p)) - -128));
			if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
		}
	} else {
		_widec = (short)(640 + ((*( sm->p)) - -128));
		if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
	}
	switch( _widec ) {
		case 994: goto tr1863;
		case 995: goto tr1864;
		case 1007: goto tr1865;
		case 1070: goto tr1868;
		case 1119: goto tr1868;
		case 1151: goto tr1867;
	}
	if ( _widec < 1025 ) {
		if ( _widec < 992 ) {
			if ( 962 <= _widec && _widec <= 991 )
				goto tr1861;
		} else if ( _widec > 1006 ) {
			if ( 1008 <= _widec && _widec <= 1012 )
				goto tr1866;
		} else
			goto tr1862;
	} else if ( _widec > 1032 ) {
		if ( _widec < 1072 ) {
			if ( 1038 <= _widec && _widec <= 1055 )
				goto tr1867;
		} else if ( _widec > 1081 ) {
			if ( _widec > 1114 ) {
				if ( 1121 <= _widec && _widec <= 1146 )
					goto tr1867;
			} else if ( _widec >= 1089 )
				goto tr1867;
		} else
			goto tr1867;
	} else
		goto tr1867;
	goto tr1524;
tr1861:
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st833;
st833:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof833;
case 833:
#line 20124 "ext/dtext/dtext.cpp"
	_widec = (*( sm->p));
	if ( (*( sm->p)) <= -65 ) {
		_widec = (short)(640 + ((*( sm->p)) - -128));
		if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
	}
	if ( 896 <= _widec && _widec <= 959 )
		goto st834;
	goto tr193;
tr1867:
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st834;
st834:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof834;
case 834:
#line 20143 "ext/dtext/dtext.cpp"
	_widec = (*( sm->p));
	if ( (*( sm->p)) < 1 ) {
		if ( (*( sm->p)) < -29 ) {
			if ( (*( sm->p)) < -62 ) {
				if ( (*( sm->p)) <= -63 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > -33 ) {
				if ( (*( sm->p)) > -31 ) {
					if ( -30 <= (*( sm->p)) && (*( sm->p)) <= -30 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= -32 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else if ( (*( sm->p)) > -29 ) {
			if ( (*( sm->p)) < -17 ) {
				if ( -28 <= (*( sm->p)) && (*( sm->p)) <= -18 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > -17 ) {
				if ( (*( sm->p)) > -12 ) {
					if ( -11 <= (*( sm->p)) && (*( sm->p)) <= -1 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= -16 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else {
			_widec = (short)(640 + ((*( sm->p)) - -128));
			if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
		}
	} else if ( (*( sm->p)) > 8 ) {
		if ( (*( sm->p)) < 45 ) {
			if ( (*( sm->p)) < 33 ) {
				if ( 14 <= (*( sm->p)) && (*( sm->p)) <= 31 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > 33 ) {
				if ( (*( sm->p)) > 39 ) {
					if ( 43 <= (*( sm->p)) && (*( sm->p)) <= 43 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= 39 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else if ( (*( sm->p)) > 47 ) {
			if ( (*( sm->p)) < 95 ) {
				if ( (*( sm->p)) > 57 ) {
					if ( 65 <= (*( sm->p)) && (*( sm->p)) <= 90 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= 48 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > 95 ) {
				if ( (*( sm->p)) > 122 ) {
					if ( 127 <= (*( sm->p)) )
 {						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= 97 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else {
			_widec = (short)(640 + ((*( sm->p)) - -128));
			if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
		}
	} else {
		_widec = (short)(640 + ((*( sm->p)) - -128));
		if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
	}
	switch( _widec ) {
		case 994: goto st848;
		case 995: goto st850;
		case 1007: goto st852;
		case 1057: goto st834;
		case 1063: goto st856;
		case 1067: goto st834;
		case 1119: goto st834;
		case 1151: goto tr1022;
	}
	if ( _widec < 1025 ) {
		if ( _widec < 992 ) {
			if ( _widec > 961 ) {
				if ( 962 <= _widec && _widec <= 991 )
					goto st846;
			} else if ( _widec >= 896 )
				goto st835;
		} else if ( _widec > 1006 ) {
			if ( _widec > 1012 ) {
				if ( 1013 <= _widec && _widec <= 1023 )
					goto st835;
			} else if ( _widec >= 1008 )
				goto st855;
		} else
			goto st847;
	} else if ( _widec > 1032 ) {
		if ( _widec < 1072 ) {
			if ( _widec > 1055 ) {
				if ( 1069 <= _widec && _widec <= 1071 )
					goto st834;
			} else if ( _widec >= 1038 )
				goto tr1022;
		} else if ( _widec > 1081 ) {
			if ( _widec > 1114 ) {
				if ( 1121 <= _widec && _widec <= 1146 )
					goto tr1022;
			} else if ( _widec >= 1089 )
				goto tr1022;
		} else
			goto tr1022;
	} else
		goto tr1022;
	goto tr185;
st835:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof835;
case 835:
	_widec = (*( sm->p));
	if ( (*( sm->p)) < 1 ) {
		if ( (*( sm->p)) < -29 ) {
			if ( (*( sm->p)) < -62 ) {
				if ( (*( sm->p)) <= -63 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > -33 ) {
				if ( (*( sm->p)) > -31 ) {
					if ( -30 <= (*( sm->p)) && (*( sm->p)) <= -30 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= -32 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else if ( (*( sm->p)) > -29 ) {
			if ( (*( sm->p)) < -17 ) {
				if ( -28 <= (*( sm->p)) && (*( sm->p)) <= -18 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > -17 ) {
				if ( (*( sm->p)) > -12 ) {
					if ( -11 <= (*( sm->p)) && (*( sm->p)) <= -1 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= -16 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else {
			_widec = (short)(640 + ((*( sm->p)) - -128));
			if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
		}
	} else if ( (*( sm->p)) > 8 ) {
		if ( (*( sm->p)) < 45 ) {
			if ( (*( sm->p)) < 33 ) {
				if ( 14 <= (*( sm->p)) && (*( sm->p)) <= 31 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > 33 ) {
				if ( (*( sm->p)) > 39 ) {
					if ( 43 <= (*( sm->p)) && (*( sm->p)) <= 43 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= 39 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else if ( (*( sm->p)) > 47 ) {
			if ( (*( sm->p)) < 95 ) {
				if ( (*( sm->p)) > 57 ) {
					if ( 65 <= (*( sm->p)) && (*( sm->p)) <= 90 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= 48 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > 95 ) {
				if ( (*( sm->p)) > 122 ) {
					if ( 127 <= (*( sm->p)) )
 {						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= 97 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else {
			_widec = (short)(640 + ((*( sm->p)) - -128));
			if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
		}
	} else {
		_widec = (short)(640 + ((*( sm->p)) - -128));
		if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
	}
	switch( _widec ) {
		case 994: goto st838;
		case 995: goto st840;
		case 1007: goto st842;
		case 1057: goto st835;
		case 1063: goto st835;
		case 1067: goto st835;
		case 1119: goto st835;
		case 1151: goto tr1030;
	}
	if ( _widec < 1025 ) {
		if ( _widec < 992 ) {
			if ( _widec > 961 ) {
				if ( 962 <= _widec && _widec <= 991 )
					goto st836;
			} else if ( _widec >= 896 )
				goto st835;
		} else if ( _widec > 1006 ) {
			if ( _widec > 1012 ) {
				if ( 1013 <= _widec && _widec <= 1023 )
					goto st835;
			} else if ( _widec >= 1008 )
				goto st844;
		} else
			goto st837;
	} else if ( _widec > 1032 ) {
		if ( _widec < 1072 ) {
			if ( _widec > 1055 ) {
				if ( 1069 <= _widec && _widec <= 1071 )
					goto st835;
			} else if ( _widec >= 1038 )
				goto tr1030;
		} else if ( _widec > 1081 ) {
			if ( _widec > 1114 ) {
				if ( 1121 <= _widec && _widec <= 1146 )
					goto tr1030;
			} else if ( _widec >= 1089 )
				goto tr1030;
		} else
			goto tr1030;
	} else
		goto tr1030;
	goto tr185;
st836:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof836;
case 836:
	_widec = (*( sm->p));
	if ( (*( sm->p)) < 1 ) {
		if ( (*( sm->p)) < -30 ) {
			if ( (*( sm->p)) < -64 ) {
				if ( (*( sm->p)) <= -65 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > -63 ) {
				if ( (*( sm->p)) > -33 ) {
					if ( -32 <= (*( sm->p)) && (*( sm->p)) <= -31 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= -62 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else if ( (*( sm->p)) > -30 ) {
			if ( (*( sm->p)) < -17 ) {
				if ( (*( sm->p)) > -29 ) {
					if ( -28 <= (*( sm->p)) && (*( sm->p)) <= -18 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= -29 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > -17 ) {
				if ( (*( sm->p)) > -12 ) {
					if ( -11 <= (*( sm->p)) && (*( sm->p)) <= -1 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= -16 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else {
			_widec = (short)(640 + ((*( sm->p)) - -128));
			if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
		}
	} else if ( (*( sm->p)) > 8 ) {
		if ( (*( sm->p)) < 45 ) {
			if ( (*( sm->p)) < 33 ) {
				if ( 14 <= (*( sm->p)) && (*( sm->p)) <= 31 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > 33 ) {
				if ( (*( sm->p)) > 39 ) {
					if ( 43 <= (*( sm->p)) && (*( sm->p)) <= 43 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= 39 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else if ( (*( sm->p)) > 47 ) {
			if ( (*( sm->p)) < 95 ) {
				if ( (*( sm->p)) > 57 ) {
					if ( 65 <= (*( sm->p)) && (*( sm->p)) <= 90 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= 48 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > 95 ) {
				if ( (*( sm->p)) > 122 ) {
					if ( 127 <= (*( sm->p)) )
 {						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= 97 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else {
			_widec = (short)(640 + ((*( sm->p)) - -128));
			if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
		}
	} else {
		_widec = (short)(640 + ((*( sm->p)) - -128));
		if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
	}
	switch( _widec ) {
		case 994: goto st838;
		case 995: goto st840;
		case 1007: goto st842;
		case 1057: goto st835;
		case 1063: goto st835;
		case 1067: goto st835;
		case 1119: goto st835;
		case 1151: goto tr1030;
	}
	if ( _widec < 1013 ) {
		if ( _widec < 962 ) {
			if ( _widec > 959 ) {
				if ( 960 <= _widec && _widec <= 961 )
					goto st835;
			} else if ( _widec >= 896 )
				goto tr1030;
		} else if ( _widec > 991 ) {
			if ( _widec > 1006 ) {
				if ( 1008 <= _widec && _widec <= 1012 )
					goto st844;
			} else if ( _widec >= 992 )
				goto st837;
		} else
			goto st836;
	} else if ( _widec > 1023 ) {
		if ( _widec < 1069 ) {
			if ( _widec > 1032 ) {
				if ( 1038 <= _widec && _widec <= 1055 )
					goto tr1030;
			} else if ( _widec >= 1025 )
				goto tr1030;
		} else if ( _widec > 1071 ) {
			if ( _widec < 1089 ) {
				if ( 1072 <= _widec && _widec <= 1081 )
					goto tr1030;
			} else if ( _widec > 1114 ) {
				if ( 1121 <= _widec && _widec <= 1146 )
					goto tr1030;
			} else
				goto tr1030;
		} else
			goto st835;
	} else
		goto st835;
	goto tr185;
tr1030:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 72 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
#line 364 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 56;}
	goto st1403;
st1403:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1403;
case 1403:
#line 20723 "ext/dtext/dtext.cpp"
	_widec = (*( sm->p));
	if ( (*( sm->p)) < 1 ) {
		if ( (*( sm->p)) < -29 ) {
			if ( (*( sm->p)) < -62 ) {
				if ( (*( sm->p)) <= -63 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > -33 ) {
				if ( (*( sm->p)) > -31 ) {
					if ( -30 <= (*( sm->p)) && (*( sm->p)) <= -30 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= -32 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else if ( (*( sm->p)) > -29 ) {
			if ( (*( sm->p)) < -17 ) {
				if ( -28 <= (*( sm->p)) && (*( sm->p)) <= -18 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > -17 ) {
				if ( (*( sm->p)) > -12 ) {
					if ( -11 <= (*( sm->p)) && (*( sm->p)) <= -1 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= -16 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else {
			_widec = (short)(640 + ((*( sm->p)) - -128));
			if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
		}
	} else if ( (*( sm->p)) > 8 ) {
		if ( (*( sm->p)) < 45 ) {
			if ( (*( sm->p)) < 33 ) {
				if ( 14 <= (*( sm->p)) && (*( sm->p)) <= 31 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > 33 ) {
				if ( (*( sm->p)) > 39 ) {
					if ( 43 <= (*( sm->p)) && (*( sm->p)) <= 43 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= 39 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else if ( (*( sm->p)) > 47 ) {
			if ( (*( sm->p)) < 95 ) {
				if ( (*( sm->p)) > 57 ) {
					if ( 65 <= (*( sm->p)) && (*( sm->p)) <= 90 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= 48 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > 95 ) {
				if ( (*( sm->p)) > 122 ) {
					if ( 127 <= (*( sm->p)) )
 {						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= 97 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else {
			_widec = (short)(640 + ((*( sm->p)) - -128));
			if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
		}
	} else {
		_widec = (short)(640 + ((*( sm->p)) - -128));
		if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
	}
	switch( _widec ) {
		case 994: goto st838;
		case 995: goto st840;
		case 1007: goto st842;
		case 1057: goto st835;
		case 1063: goto st835;
		case 1067: goto st835;
		case 1119: goto st835;
		case 1151: goto tr1030;
	}
	if ( _widec < 1025 ) {
		if ( _widec < 992 ) {
			if ( _widec > 961 ) {
				if ( 962 <= _widec && _widec <= 991 )
					goto st836;
			} else if ( _widec >= 896 )
				goto st835;
		} else if ( _widec > 1006 ) {
			if ( _widec > 1012 ) {
				if ( 1013 <= _widec && _widec <= 1023 )
					goto st835;
			} else if ( _widec >= 1008 )
				goto st844;
		} else
			goto st837;
	} else if ( _widec > 1032 ) {
		if ( _widec < 1072 ) {
			if ( _widec > 1055 ) {
				if ( 1069 <= _widec && _widec <= 1071 )
					goto st835;
			} else if ( _widec >= 1038 )
				goto tr1030;
		} else if ( _widec > 1081 ) {
			if ( _widec > 1114 ) {
				if ( 1121 <= _widec && _widec <= 1146 )
					goto tr1030;
			} else if ( _widec >= 1089 )
				goto tr1030;
		} else
			goto tr1030;
	} else
		goto tr1030;
	goto tr1869;
st837:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof837;
case 837:
	_widec = (*( sm->p));
	if ( (*( sm->p)) < 1 ) {
		if ( (*( sm->p)) < -30 ) {
			if ( (*( sm->p)) < -64 ) {
				if ( (*( sm->p)) <= -65 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > -63 ) {
				if ( (*( sm->p)) > -33 ) {
					if ( -32 <= (*( sm->p)) && (*( sm->p)) <= -31 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= -62 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else if ( (*( sm->p)) > -30 ) {
			if ( (*( sm->p)) < -17 ) {
				if ( (*( sm->p)) > -29 ) {
					if ( -28 <= (*( sm->p)) && (*( sm->p)) <= -18 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= -29 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > -17 ) {
				if ( (*( sm->p)) > -12 ) {
					if ( -11 <= (*( sm->p)) && (*( sm->p)) <= -1 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= -16 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else {
			_widec = (short)(640 + ((*( sm->p)) - -128));
			if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
		}
	} else if ( (*( sm->p)) > 8 ) {
		if ( (*( sm->p)) < 45 ) {
			if ( (*( sm->p)) < 33 ) {
				if ( 14 <= (*( sm->p)) && (*( sm->p)) <= 31 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > 33 ) {
				if ( (*( sm->p)) > 39 ) {
					if ( 43 <= (*( sm->p)) && (*( sm->p)) <= 43 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= 39 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else if ( (*( sm->p)) > 47 ) {
			if ( (*( sm->p)) < 95 ) {
				if ( (*( sm->p)) > 57 ) {
					if ( 65 <= (*( sm->p)) && (*( sm->p)) <= 90 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= 48 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > 95 ) {
				if ( (*( sm->p)) > 122 ) {
					if ( 127 <= (*( sm->p)) )
 {						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= 97 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else {
			_widec = (short)(640 + ((*( sm->p)) - -128));
			if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
		}
	} else {
		_widec = (short)(640 + ((*( sm->p)) - -128));
		if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
	}
	switch( _widec ) {
		case 994: goto st838;
		case 995: goto st840;
		case 1007: goto st842;
		case 1057: goto st835;
		case 1063: goto st835;
		case 1067: goto st835;
		case 1119: goto st835;
		case 1151: goto tr1030;
	}
	if ( _widec < 1013 ) {
		if ( _widec < 962 ) {
			if ( _widec > 959 ) {
				if ( 960 <= _widec && _widec <= 961 )
					goto st835;
			} else if ( _widec >= 896 )
				goto st836;
		} else if ( _widec > 991 ) {
			if ( _widec > 1006 ) {
				if ( 1008 <= _widec && _widec <= 1012 )
					goto st844;
			} else if ( _widec >= 992 )
				goto st837;
		} else
			goto st836;
	} else if ( _widec > 1023 ) {
		if ( _widec < 1069 ) {
			if ( _widec > 1032 ) {
				if ( 1038 <= _widec && _widec <= 1055 )
					goto tr1030;
			} else if ( _widec >= 1025 )
				goto tr1030;
		} else if ( _widec > 1071 ) {
			if ( _widec < 1089 ) {
				if ( 1072 <= _widec && _widec <= 1081 )
					goto tr1030;
			} else if ( _widec > 1114 ) {
				if ( 1121 <= _widec && _widec <= 1146 )
					goto tr1030;
			} else
				goto tr1030;
		} else
			goto st835;
	} else
		goto st835;
	goto tr185;
st838:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof838;
case 838:
	_widec = (*( sm->p));
	if ( (*( sm->p)) < -11 ) {
		if ( (*( sm->p)) < -32 ) {
			if ( (*( sm->p)) < -98 ) {
				if ( (*( sm->p)) > -100 ) {
					if ( -99 <= (*( sm->p)) && (*( sm->p)) <= -99 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > -65 ) {
				if ( (*( sm->p)) > -63 ) {
					if ( -62 <= (*( sm->p)) && (*( sm->p)) <= -33 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= -64 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else if ( (*( sm->p)) > -31 ) {
			if ( (*( sm->p)) < -28 ) {
				if ( (*( sm->p)) > -30 ) {
					if ( -29 <= (*( sm->p)) && (*( sm->p)) <= -29 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= -30 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > -18 ) {
				if ( (*( sm->p)) > -17 ) {
					if ( -16 <= (*( sm->p)) && (*( sm->p)) <= -12 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= -17 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else {
			_widec = (short)(640 + ((*( sm->p)) - -128));
			if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
		}
	} else if ( (*( sm->p)) > -1 ) {
		if ( (*( sm->p)) < 45 ) {
			if ( (*( sm->p)) < 33 ) {
				if ( (*( sm->p)) > 8 ) {
					if ( 14 <= (*( sm->p)) && (*( sm->p)) <= 31 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= 1 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > 33 ) {
				if ( (*( sm->p)) > 39 ) {
					if ( 43 <= (*( sm->p)) && (*( sm->p)) <= 43 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= 39 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else if ( (*( sm->p)) > 47 ) {
			if ( (*( sm->p)) < 95 ) {
				if ( (*( sm->p)) > 57 ) {
					if ( 65 <= (*( sm->p)) && (*( sm->p)) <= 90 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= 48 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > 95 ) {
				if ( (*( sm->p)) > 122 ) {
					if ( 127 <= (*( sm->p)) )
 {						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= 97 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else {
			_widec = (short)(640 + ((*( sm->p)) - -128));
			if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
		}
	} else {
		_widec = (short)(640 + ((*( sm->p)) - -128));
		if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
	}
	switch( _widec ) {
		case 925: goto st839;
		case 994: goto st838;
		case 995: goto st840;
		case 1007: goto st842;
		case 1057: goto st835;
		case 1063: goto st835;
		case 1067: goto st835;
		case 1119: goto st835;
		case 1151: goto tr1030;
	}
	if ( _widec < 1013 ) {
		if ( _widec < 962 ) {
			if ( _widec > 959 ) {
				if ( 960 <= _widec && _widec <= 961 )
					goto st835;
			} else if ( _widec >= 896 )
				goto st836;
		} else if ( _widec > 991 ) {
			if ( _widec > 1006 ) {
				if ( 1008 <= _widec && _widec <= 1012 )
					goto st844;
			} else if ( _widec >= 992 )
				goto st837;
		} else
			goto st836;
	} else if ( _widec > 1023 ) {
		if ( _widec < 1069 ) {
			if ( _widec > 1032 ) {
				if ( 1038 <= _widec && _widec <= 1055 )
					goto tr1030;
			} else if ( _widec >= 1025 )
				goto tr1030;
		} else if ( _widec > 1071 ) {
			if ( _widec < 1089 ) {
				if ( 1072 <= _widec && _widec <= 1081 )
					goto tr1030;
			} else if ( _widec > 1114 ) {
				if ( 1121 <= _widec && _widec <= 1146 )
					goto tr1030;
			} else
				goto tr1030;
		} else
			goto st835;
	} else
		goto st835;
	goto tr185;
st839:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof839;
case 839:
	_widec = (*( sm->p));
	if ( (*( sm->p)) < -11 ) {
		if ( (*( sm->p)) < -32 ) {
			if ( (*( sm->p)) < -82 ) {
				if ( (*( sm->p)) > -84 ) {
					if ( -83 <= (*( sm->p)) && (*( sm->p)) <= -83 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > -65 ) {
				if ( (*( sm->p)) > -63 ) {
					if ( -62 <= (*( sm->p)) && (*( sm->p)) <= -33 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= -64 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else if ( (*( sm->p)) > -31 ) {
			if ( (*( sm->p)) < -28 ) {
				if ( (*( sm->p)) > -30 ) {
					if ( -29 <= (*( sm->p)) && (*( sm->p)) <= -29 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= -30 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > -18 ) {
				if ( (*( sm->p)) > -17 ) {
					if ( -16 <= (*( sm->p)) && (*( sm->p)) <= -12 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= -17 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else {
			_widec = (short)(640 + ((*( sm->p)) - -128));
			if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
		}
	} else if ( (*( sm->p)) > -1 ) {
		if ( (*( sm->p)) < 45 ) {
			if ( (*( sm->p)) < 33 ) {
				if ( (*( sm->p)) > 8 ) {
					if ( 14 <= (*( sm->p)) && (*( sm->p)) <= 31 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= 1 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > 33 ) {
				if ( (*( sm->p)) > 39 ) {
					if ( 43 <= (*( sm->p)) && (*( sm->p)) <= 43 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= 39 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else if ( (*( sm->p)) > 47 ) {
			if ( (*( sm->p)) < 95 ) {
				if ( (*( sm->p)) > 57 ) {
					if ( 65 <= (*( sm->p)) && (*( sm->p)) <= 90 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= 48 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > 95 ) {
				if ( (*( sm->p)) > 122 ) {
					if ( 127 <= (*( sm->p)) )
 {						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= 97 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else {
			_widec = (short)(640 + ((*( sm->p)) - -128));
			if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
		}
	} else {
		_widec = (short)(640 + ((*( sm->p)) - -128));
		if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
	}
	switch( _widec ) {
		case 941: goto st835;
		case 994: goto st838;
		case 995: goto st840;
		case 1007: goto st842;
		case 1057: goto st835;
		case 1063: goto st835;
		case 1067: goto st835;
		case 1119: goto st835;
		case 1151: goto tr1030;
	}
	if ( _widec < 1013 ) {
		if ( _widec < 962 ) {
			if ( _widec > 959 ) {
				if ( 960 <= _widec && _widec <= 961 )
					goto st835;
			} else if ( _widec >= 896 )
				goto tr1030;
		} else if ( _widec > 991 ) {
			if ( _widec > 1006 ) {
				if ( 1008 <= _widec && _widec <= 1012 )
					goto st844;
			} else if ( _widec >= 992 )
				goto st837;
		} else
			goto st836;
	} else if ( _widec > 1023 ) {
		if ( _widec < 1069 ) {
			if ( _widec > 1032 ) {
				if ( 1038 <= _widec && _widec <= 1055 )
					goto tr1030;
			} else if ( _widec >= 1025 )
				goto tr1030;
		} else if ( _widec > 1071 ) {
			if ( _widec < 1089 ) {
				if ( 1072 <= _widec && _widec <= 1081 )
					goto tr1030;
			} else if ( _widec > 1114 ) {
				if ( 1121 <= _widec && _widec <= 1146 )
					goto tr1030;
			} else
				goto tr1030;
		} else
			goto st835;
	} else
		goto st835;
	goto tr185;
st840:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof840;
case 840:
	_widec = (*( sm->p));
	if ( (*( sm->p)) < -11 ) {
		if ( (*( sm->p)) < -32 ) {
			if ( (*( sm->p)) < -127 ) {
				if ( (*( sm->p)) <= -128 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > -65 ) {
				if ( (*( sm->p)) > -63 ) {
					if ( -62 <= (*( sm->p)) && (*( sm->p)) <= -33 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= -64 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else if ( (*( sm->p)) > -31 ) {
			if ( (*( sm->p)) < -28 ) {
				if ( (*( sm->p)) > -30 ) {
					if ( -29 <= (*( sm->p)) && (*( sm->p)) <= -29 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= -30 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > -18 ) {
				if ( (*( sm->p)) > -17 ) {
					if ( -16 <= (*( sm->p)) && (*( sm->p)) <= -12 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= -17 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else {
			_widec = (short)(640 + ((*( sm->p)) - -128));
			if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
		}
	} else if ( (*( sm->p)) > -1 ) {
		if ( (*( sm->p)) < 45 ) {
			if ( (*( sm->p)) < 33 ) {
				if ( (*( sm->p)) > 8 ) {
					if ( 14 <= (*( sm->p)) && (*( sm->p)) <= 31 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= 1 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > 33 ) {
				if ( (*( sm->p)) > 39 ) {
					if ( 43 <= (*( sm->p)) && (*( sm->p)) <= 43 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= 39 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else if ( (*( sm->p)) > 47 ) {
			if ( (*( sm->p)) < 95 ) {
				if ( (*( sm->p)) > 57 ) {
					if ( 65 <= (*( sm->p)) && (*( sm->p)) <= 90 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= 48 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > 95 ) {
				if ( (*( sm->p)) > 122 ) {
					if ( 127 <= (*( sm->p)) )
 {						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= 97 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else {
			_widec = (short)(640 + ((*( sm->p)) - -128));
			if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
		}
	} else {
		_widec = (short)(640 + ((*( sm->p)) - -128));
		if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
	}
	switch( _widec ) {
		case 896: goto st841;
		case 994: goto st838;
		case 995: goto st840;
		case 1007: goto st842;
		case 1057: goto st835;
		case 1063: goto st835;
		case 1067: goto st835;
		case 1119: goto st835;
		case 1151: goto tr1030;
	}
	if ( _widec < 1013 ) {
		if ( _widec < 962 ) {
			if ( _widec > 959 ) {
				if ( 960 <= _widec && _widec <= 961 )
					goto st835;
			} else if ( _widec >= 897 )
				goto st836;
		} else if ( _widec > 991 ) {
			if ( _widec > 1006 ) {
				if ( 1008 <= _widec && _widec <= 1012 )
					goto st844;
			} else if ( _widec >= 992 )
				goto st837;
		} else
			goto st836;
	} else if ( _widec > 1023 ) {
		if ( _widec < 1069 ) {
			if ( _widec > 1032 ) {
				if ( 1038 <= _widec && _widec <= 1055 )
					goto tr1030;
			} else if ( _widec >= 1025 )
				goto tr1030;
		} else if ( _widec > 1071 ) {
			if ( _widec < 1089 ) {
				if ( 1072 <= _widec && _widec <= 1081 )
					goto tr1030;
			} else if ( _widec > 1114 ) {
				if ( 1121 <= _widec && _widec <= 1146 )
					goto tr1030;
			} else
				goto tr1030;
		} else
			goto st835;
	} else
		goto st835;
	goto tr185;
st841:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof841;
case 841:
	_widec = (*( sm->p));
	if ( (*( sm->p)) < -17 ) {
		if ( (*( sm->p)) < -99 ) {
			if ( (*( sm->p)) < -120 ) {
				if ( (*( sm->p)) > -126 ) {
					if ( -125 <= (*( sm->p)) && (*( sm->p)) <= -121 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > -111 ) {
				if ( (*( sm->p)) > -109 ) {
					if ( -108 <= (*( sm->p)) && (*( sm->p)) <= -100 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= -110 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else if ( (*( sm->p)) > -65 ) {
			if ( (*( sm->p)) < -32 ) {
				if ( (*( sm->p)) > -63 ) {
					if ( -62 <= (*( sm->p)) && (*( sm->p)) <= -33 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= -64 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > -31 ) {
				if ( (*( sm->p)) < -29 ) {
					if ( -30 <= (*( sm->p)) && (*( sm->p)) <= -30 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) > -29 ) {
					if ( -28 <= (*( sm->p)) && (*( sm->p)) <= -18 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else {
			_widec = (short)(640 + ((*( sm->p)) - -128));
			if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
		}
	} else if ( (*( sm->p)) > -17 ) {
		if ( (*( sm->p)) < 43 ) {
			if ( (*( sm->p)) < 1 ) {
				if ( (*( sm->p)) > -12 ) {
					if ( -11 <= (*( sm->p)) && (*( sm->p)) <= -1 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= -16 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > 8 ) {
				if ( (*( sm->p)) < 33 ) {
					if ( 14 <= (*( sm->p)) && (*( sm->p)) <= 31 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) > 33 ) {
					if ( 39 <= (*( sm->p)) && (*( sm->p)) <= 39 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else if ( (*( sm->p)) > 43 ) {
			if ( (*( sm->p)) < 65 ) {
				if ( (*( sm->p)) > 47 ) {
					if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= 45 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > 90 ) {
				if ( (*( sm->p)) < 97 ) {
					if ( 95 <= (*( sm->p)) && (*( sm->p)) <= 95 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) > 122 ) {
					if ( 127 <= (*( sm->p)) )
 {						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else {
			_widec = (short)(640 + ((*( sm->p)) - -128));
			if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
		}
	} else {
		_widec = (short)(640 + ((*( sm->p)) - -128));
		if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
	}
	switch( _widec ) {
		case 994: goto st838;
		case 995: goto st840;
		case 1007: goto st842;
		case 1057: goto st835;
		case 1063: goto st835;
		case 1067: goto st835;
		case 1119: goto st835;
		case 1151: goto tr1030;
	}
	if ( _widec < 992 ) {
		if ( _widec < 914 ) {
			if ( _widec < 899 ) {
				if ( 896 <= _widec && _widec <= 898 )
					goto st835;
			} else if ( _widec > 903 ) {
				if ( 904 <= _widec && _widec <= 913 )
					goto st835;
			} else
				goto tr1030;
		} else if ( _widec > 915 ) {
			if ( _widec < 925 ) {
				if ( 916 <= _widec && _widec <= 924 )
					goto st835;
			} else if ( _widec > 959 ) {
				if ( _widec > 961 ) {
					if ( 962 <= _widec && _widec <= 991 )
						goto st836;
				} else if ( _widec >= 960 )
					goto st835;
			} else
				goto tr1030;
		} else
			goto tr1030;
	} else if ( _widec > 1006 ) {
		if ( _widec < 1038 ) {
			if ( _widec < 1013 ) {
				if ( 1008 <= _widec && _widec <= 1012 )
					goto st844;
			} else if ( _widec > 1023 ) {
				if ( 1025 <= _widec && _widec <= 1032 )
					goto tr1030;
			} else
				goto st835;
		} else if ( _widec > 1055 ) {
			if ( _widec < 1072 ) {
				if ( 1069 <= _widec && _widec <= 1071 )
					goto st835;
			} else if ( _widec > 1081 ) {
				if ( _widec > 1114 ) {
					if ( 1121 <= _widec && _widec <= 1146 )
						goto tr1030;
				} else if ( _widec >= 1089 )
					goto tr1030;
			} else
				goto tr1030;
		} else
			goto tr1030;
	} else
		goto st837;
	goto tr185;
st842:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof842;
case 842:
	_widec = (*( sm->p));
	if ( (*( sm->p)) < -16 ) {
		if ( (*( sm->p)) < -62 ) {
			if ( (*( sm->p)) < -67 ) {
				if ( (*( sm->p)) > -69 ) {
					if ( -68 <= (*( sm->p)) && (*( sm->p)) <= -68 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > -67 ) {
				if ( (*( sm->p)) > -65 ) {
					if ( -64 <= (*( sm->p)) && (*( sm->p)) <= -63 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= -66 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else if ( (*( sm->p)) > -33 ) {
			if ( (*( sm->p)) < -29 ) {
				if ( (*( sm->p)) > -31 ) {
					if ( -30 <= (*( sm->p)) && (*( sm->p)) <= -30 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= -32 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > -29 ) {
				if ( (*( sm->p)) > -18 ) {
					if ( -17 <= (*( sm->p)) && (*( sm->p)) <= -17 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= -28 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else {
			_widec = (short)(640 + ((*( sm->p)) - -128));
			if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
		}
	} else if ( (*( sm->p)) > -12 ) {
		if ( (*( sm->p)) < 43 ) {
			if ( (*( sm->p)) < 14 ) {
				if ( (*( sm->p)) > -1 ) {
					if ( 1 <= (*( sm->p)) && (*( sm->p)) <= 8 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= -11 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > 31 ) {
				if ( (*( sm->p)) > 33 ) {
					if ( 39 <= (*( sm->p)) && (*( sm->p)) <= 39 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= 33 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else if ( (*( sm->p)) > 43 ) {
			if ( (*( sm->p)) < 65 ) {
				if ( (*( sm->p)) > 47 ) {
					if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= 45 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > 90 ) {
				if ( (*( sm->p)) < 97 ) {
					if ( 95 <= (*( sm->p)) && (*( sm->p)) <= 95 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) > 122 ) {
					if ( 127 <= (*( sm->p)) )
 {						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else {
			_widec = (short)(640 + ((*( sm->p)) - -128));
			if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
		}
	} else {
		_widec = (short)(640 + ((*( sm->p)) - -128));
		if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
	}
	switch( _widec ) {
		case 956: goto st843;
		case 957: goto st845;
		case 994: goto st838;
		case 995: goto st840;
		case 1007: goto st842;
		case 1057: goto st835;
		case 1063: goto st835;
		case 1067: goto st835;
		case 1119: goto st835;
		case 1151: goto tr1030;
	}
	if ( _widec < 1013 ) {
		if ( _widec < 962 ) {
			if ( _widec > 959 ) {
				if ( 960 <= _widec && _widec <= 961 )
					goto st835;
			} else if ( _widec >= 896 )
				goto st836;
		} else if ( _widec > 991 ) {
			if ( _widec > 1006 ) {
				if ( 1008 <= _widec && _widec <= 1012 )
					goto st844;
			} else if ( _widec >= 992 )
				goto st837;
		} else
			goto st836;
	} else if ( _widec > 1023 ) {
		if ( _widec < 1069 ) {
			if ( _widec > 1032 ) {
				if ( 1038 <= _widec && _widec <= 1055 )
					goto tr1030;
			} else if ( _widec >= 1025 )
				goto tr1030;
		} else if ( _widec > 1071 ) {
			if ( _widec < 1089 ) {
				if ( 1072 <= _widec && _widec <= 1081 )
					goto tr1030;
			} else if ( _widec > 1114 ) {
				if ( 1121 <= _widec && _widec <= 1146 )
					goto tr1030;
			} else
				goto tr1030;
		} else
			goto st835;
	} else
		goto st835;
	goto tr185;
st843:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof843;
case 843:
	_widec = (*( sm->p));
	if ( (*( sm->p)) < -16 ) {
		if ( (*( sm->p)) < -64 ) {
			if ( (*( sm->p)) < -118 ) {
				if ( (*( sm->p)) > -120 ) {
					if ( -119 <= (*( sm->p)) && (*( sm->p)) <= -119 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > -68 ) {
				if ( (*( sm->p)) > -67 ) {
					if ( -66 <= (*( sm->p)) && (*( sm->p)) <= -65 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= -67 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else if ( (*( sm->p)) > -63 ) {
			if ( (*( sm->p)) < -30 ) {
				if ( (*( sm->p)) > -33 ) {
					if ( -32 <= (*( sm->p)) && (*( sm->p)) <= -31 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= -62 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > -30 ) {
				if ( (*( sm->p)) < -28 ) {
					if ( -29 <= (*( sm->p)) && (*( sm->p)) <= -29 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) > -18 ) {
					if ( -17 <= (*( sm->p)) && (*( sm->p)) <= -17 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else {
			_widec = (short)(640 + ((*( sm->p)) - -128));
			if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
		}
	} else if ( (*( sm->p)) > -12 ) {
		if ( (*( sm->p)) < 43 ) {
			if ( (*( sm->p)) < 14 ) {
				if ( (*( sm->p)) > -1 ) {
					if ( 1 <= (*( sm->p)) && (*( sm->p)) <= 8 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= -11 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > 31 ) {
				if ( (*( sm->p)) > 33 ) {
					if ( 39 <= (*( sm->p)) && (*( sm->p)) <= 39 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= 33 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else if ( (*( sm->p)) > 43 ) {
			if ( (*( sm->p)) < 65 ) {
				if ( (*( sm->p)) > 47 ) {
					if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= 45 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > 90 ) {
				if ( (*( sm->p)) < 97 ) {
					if ( 95 <= (*( sm->p)) && (*( sm->p)) <= 95 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) > 122 ) {
					if ( 127 <= (*( sm->p)) )
 {						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else {
			_widec = (short)(640 + ((*( sm->p)) - -128));
			if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
		}
	} else {
		_widec = (short)(640 + ((*( sm->p)) - -128));
		if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
	}
	switch( _widec ) {
		case 905: goto st835;
		case 957: goto st835;
		case 994: goto st838;
		case 995: goto st840;
		case 1007: goto st842;
		case 1057: goto st835;
		case 1063: goto st835;
		case 1067: goto st835;
		case 1119: goto st835;
		case 1151: goto tr1030;
	}
	if ( _widec < 1013 ) {
		if ( _widec < 962 ) {
			if ( _widec > 959 ) {
				if ( 960 <= _widec && _widec <= 961 )
					goto st835;
			} else if ( _widec >= 896 )
				goto tr1030;
		} else if ( _widec > 991 ) {
			if ( _widec > 1006 ) {
				if ( 1008 <= _widec && _widec <= 1012 )
					goto st844;
			} else if ( _widec >= 992 )
				goto st837;
		} else
			goto st836;
	} else if ( _widec > 1023 ) {
		if ( _widec < 1069 ) {
			if ( _widec > 1032 ) {
				if ( 1038 <= _widec && _widec <= 1055 )
					goto tr1030;
			} else if ( _widec >= 1025 )
				goto tr1030;
		} else if ( _widec > 1071 ) {
			if ( _widec < 1089 ) {
				if ( 1072 <= _widec && _widec <= 1081 )
					goto tr1030;
			} else if ( _widec > 1114 ) {
				if ( 1121 <= _widec && _widec <= 1146 )
					goto tr1030;
			} else
				goto tr1030;
		} else
			goto st835;
	} else
		goto st835;
	goto tr185;
st844:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof844;
case 844:
	_widec = (*( sm->p));
	if ( (*( sm->p)) < 1 ) {
		if ( (*( sm->p)) < -30 ) {
			if ( (*( sm->p)) < -64 ) {
				if ( (*( sm->p)) <= -65 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > -63 ) {
				if ( (*( sm->p)) > -33 ) {
					if ( -32 <= (*( sm->p)) && (*( sm->p)) <= -31 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= -62 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else if ( (*( sm->p)) > -30 ) {
			if ( (*( sm->p)) < -17 ) {
				if ( (*( sm->p)) > -29 ) {
					if ( -28 <= (*( sm->p)) && (*( sm->p)) <= -18 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= -29 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > -17 ) {
				if ( (*( sm->p)) > -12 ) {
					if ( -11 <= (*( sm->p)) && (*( sm->p)) <= -1 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= -16 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else {
			_widec = (short)(640 + ((*( sm->p)) - -128));
			if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
		}
	} else if ( (*( sm->p)) > 8 ) {
		if ( (*( sm->p)) < 45 ) {
			if ( (*( sm->p)) < 33 ) {
				if ( 14 <= (*( sm->p)) && (*( sm->p)) <= 31 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > 33 ) {
				if ( (*( sm->p)) > 39 ) {
					if ( 43 <= (*( sm->p)) && (*( sm->p)) <= 43 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= 39 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else if ( (*( sm->p)) > 47 ) {
			if ( (*( sm->p)) < 95 ) {
				if ( (*( sm->p)) > 57 ) {
					if ( 65 <= (*( sm->p)) && (*( sm->p)) <= 90 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= 48 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > 95 ) {
				if ( (*( sm->p)) > 122 ) {
					if ( 127 <= (*( sm->p)) )
 {						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= 97 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else {
			_widec = (short)(640 + ((*( sm->p)) - -128));
			if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
		}
	} else {
		_widec = (short)(640 + ((*( sm->p)) - -128));
		if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
	}
	switch( _widec ) {
		case 994: goto st838;
		case 995: goto st840;
		case 1007: goto st842;
		case 1057: goto st835;
		case 1063: goto st835;
		case 1067: goto st835;
		case 1119: goto st835;
		case 1151: goto tr1030;
	}
	if ( _widec < 1013 ) {
		if ( _widec < 962 ) {
			if ( _widec > 959 ) {
				if ( 960 <= _widec && _widec <= 961 )
					goto st835;
			} else if ( _widec >= 896 )
				goto st837;
		} else if ( _widec > 991 ) {
			if ( _widec > 1006 ) {
				if ( 1008 <= _widec && _widec <= 1012 )
					goto st844;
			} else if ( _widec >= 992 )
				goto st837;
		} else
			goto st836;
	} else if ( _widec > 1023 ) {
		if ( _widec < 1069 ) {
			if ( _widec > 1032 ) {
				if ( 1038 <= _widec && _widec <= 1055 )
					goto tr1030;
			} else if ( _widec >= 1025 )
				goto tr1030;
		} else if ( _widec > 1071 ) {
			if ( _widec < 1089 ) {
				if ( 1072 <= _widec && _widec <= 1081 )
					goto tr1030;
			} else if ( _widec > 1114 ) {
				if ( 1121 <= _widec && _widec <= 1146 )
					goto tr1030;
			} else
				goto tr1030;
		} else
			goto st835;
	} else
		goto st835;
	goto tr185;
st845:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof845;
case 845:
	_widec = (*( sm->p));
	if ( (*( sm->p)) < -17 ) {
		if ( (*( sm->p)) < -92 ) {
			if ( (*( sm->p)) < -98 ) {
				if ( (*( sm->p)) > -100 ) {
					if ( -99 <= (*( sm->p)) && (*( sm->p)) <= -99 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > -97 ) {
				if ( (*( sm->p)) < -95 ) {
					if ( -96 <= (*( sm->p)) && (*( sm->p)) <= -96 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) > -94 ) {
					if ( -93 <= (*( sm->p)) && (*( sm->p)) <= -93 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else if ( (*( sm->p)) > -65 ) {
			if ( (*( sm->p)) < -32 ) {
				if ( (*( sm->p)) > -63 ) {
					if ( -62 <= (*( sm->p)) && (*( sm->p)) <= -33 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= -64 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > -31 ) {
				if ( (*( sm->p)) < -29 ) {
					if ( -30 <= (*( sm->p)) && (*( sm->p)) <= -30 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) > -29 ) {
					if ( -28 <= (*( sm->p)) && (*( sm->p)) <= -18 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else {
			_widec = (short)(640 + ((*( sm->p)) - -128));
			if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
		}
	} else if ( (*( sm->p)) > -17 ) {
		if ( (*( sm->p)) < 43 ) {
			if ( (*( sm->p)) < 1 ) {
				if ( (*( sm->p)) > -12 ) {
					if ( -11 <= (*( sm->p)) && (*( sm->p)) <= -1 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= -16 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > 8 ) {
				if ( (*( sm->p)) < 33 ) {
					if ( 14 <= (*( sm->p)) && (*( sm->p)) <= 31 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) > 33 ) {
					if ( 39 <= (*( sm->p)) && (*( sm->p)) <= 39 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else if ( (*( sm->p)) > 43 ) {
			if ( (*( sm->p)) < 65 ) {
				if ( (*( sm->p)) > 47 ) {
					if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= 45 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > 90 ) {
				if ( (*( sm->p)) < 97 ) {
					if ( 95 <= (*( sm->p)) && (*( sm->p)) <= 95 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) > 122 ) {
					if ( 127 <= (*( sm->p)) )
 {						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else {
			_widec = (short)(640 + ((*( sm->p)) - -128));
			if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
		}
	} else {
		_widec = (short)(640 + ((*( sm->p)) - -128));
		if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
	}
	switch( _widec ) {
		case 925: goto st835;
		case 928: goto st835;
		case 931: goto st835;
		case 994: goto st838;
		case 995: goto st840;
		case 1007: goto st842;
		case 1057: goto st835;
		case 1063: goto st835;
		case 1067: goto st835;
		case 1119: goto st835;
		case 1151: goto tr1030;
	}
	if ( _widec < 1013 ) {
		if ( _widec < 962 ) {
			if ( _widec > 959 ) {
				if ( 960 <= _widec && _widec <= 961 )
					goto st835;
			} else if ( _widec >= 896 )
				goto tr1030;
		} else if ( _widec > 991 ) {
			if ( _widec > 1006 ) {
				if ( 1008 <= _widec && _widec <= 1012 )
					goto st844;
			} else if ( _widec >= 992 )
				goto st837;
		} else
			goto st836;
	} else if ( _widec > 1023 ) {
		if ( _widec < 1069 ) {
			if ( _widec > 1032 ) {
				if ( 1038 <= _widec && _widec <= 1055 )
					goto tr1030;
			} else if ( _widec >= 1025 )
				goto tr1030;
		} else if ( _widec > 1071 ) {
			if ( _widec < 1089 ) {
				if ( 1072 <= _widec && _widec <= 1081 )
					goto tr1030;
			} else if ( _widec > 1114 ) {
				if ( 1121 <= _widec && _widec <= 1146 )
					goto tr1030;
			} else
				goto tr1030;
		} else
			goto st835;
	} else
		goto st835;
	goto tr185;
st846:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof846;
case 846:
	_widec = (*( sm->p));
	if ( (*( sm->p)) < 1 ) {
		if ( (*( sm->p)) < -30 ) {
			if ( (*( sm->p)) < -64 ) {
				if ( (*( sm->p)) <= -65 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > -63 ) {
				if ( (*( sm->p)) > -33 ) {
					if ( -32 <= (*( sm->p)) && (*( sm->p)) <= -31 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= -62 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else if ( (*( sm->p)) > -30 ) {
			if ( (*( sm->p)) < -17 ) {
				if ( (*( sm->p)) > -29 ) {
					if ( -28 <= (*( sm->p)) && (*( sm->p)) <= -18 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= -29 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > -17 ) {
				if ( (*( sm->p)) > -12 ) {
					if ( -11 <= (*( sm->p)) && (*( sm->p)) <= -1 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= -16 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else {
			_widec = (short)(640 + ((*( sm->p)) - -128));
			if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
		}
	} else if ( (*( sm->p)) > 8 ) {
		if ( (*( sm->p)) < 45 ) {
			if ( (*( sm->p)) < 33 ) {
				if ( 14 <= (*( sm->p)) && (*( sm->p)) <= 31 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > 33 ) {
				if ( (*( sm->p)) > 39 ) {
					if ( 43 <= (*( sm->p)) && (*( sm->p)) <= 43 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= 39 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else if ( (*( sm->p)) > 47 ) {
			if ( (*( sm->p)) < 95 ) {
				if ( (*( sm->p)) > 57 ) {
					if ( 65 <= (*( sm->p)) && (*( sm->p)) <= 90 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= 48 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > 95 ) {
				if ( (*( sm->p)) > 122 ) {
					if ( 127 <= (*( sm->p)) )
 {						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= 97 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else {
			_widec = (short)(640 + ((*( sm->p)) - -128));
			if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
		}
	} else {
		_widec = (short)(640 + ((*( sm->p)) - -128));
		if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
	}
	switch( _widec ) {
		case 994: goto st838;
		case 995: goto st840;
		case 1007: goto st842;
		case 1057: goto st835;
		case 1063: goto st835;
		case 1067: goto st835;
		case 1119: goto st835;
		case 1151: goto tr1030;
	}
	if ( _widec < 1013 ) {
		if ( _widec < 962 ) {
			if ( _widec > 959 ) {
				if ( 960 <= _widec && _widec <= 961 )
					goto st835;
			} else if ( _widec >= 896 )
				goto tr1022;
		} else if ( _widec > 991 ) {
			if ( _widec > 1006 ) {
				if ( 1008 <= _widec && _widec <= 1012 )
					goto st844;
			} else if ( _widec >= 992 )
				goto st837;
		} else
			goto st836;
	} else if ( _widec > 1023 ) {
		if ( _widec < 1069 ) {
			if ( _widec > 1032 ) {
				if ( 1038 <= _widec && _widec <= 1055 )
					goto tr1030;
			} else if ( _widec >= 1025 )
				goto tr1030;
		} else if ( _widec > 1071 ) {
			if ( _widec < 1089 ) {
				if ( 1072 <= _widec && _widec <= 1081 )
					goto tr1030;
			} else if ( _widec > 1114 ) {
				if ( 1121 <= _widec && _widec <= 1146 )
					goto tr1030;
			} else
				goto tr1030;
		} else
			goto st835;
	} else
		goto st835;
	goto tr185;
tr1022:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 72 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
#line 364 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 56;}
	goto st1404;
st1404:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1404;
case 1404:
#line 23075 "ext/dtext/dtext.cpp"
	_widec = (*( sm->p));
	if ( (*( sm->p)) < 1 ) {
		if ( (*( sm->p)) < -29 ) {
			if ( (*( sm->p)) < -62 ) {
				if ( (*( sm->p)) <= -63 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > -33 ) {
				if ( (*( sm->p)) > -31 ) {
					if ( -30 <= (*( sm->p)) && (*( sm->p)) <= -30 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= -32 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else if ( (*( sm->p)) > -29 ) {
			if ( (*( sm->p)) < -17 ) {
				if ( -28 <= (*( sm->p)) && (*( sm->p)) <= -18 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > -17 ) {
				if ( (*( sm->p)) > -12 ) {
					if ( -11 <= (*( sm->p)) && (*( sm->p)) <= -1 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= -16 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else {
			_widec = (short)(640 + ((*( sm->p)) - -128));
			if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
		}
	} else if ( (*( sm->p)) > 8 ) {
		if ( (*( sm->p)) < 45 ) {
			if ( (*( sm->p)) < 33 ) {
				if ( 14 <= (*( sm->p)) && (*( sm->p)) <= 31 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > 33 ) {
				if ( (*( sm->p)) > 39 ) {
					if ( 43 <= (*( sm->p)) && (*( sm->p)) <= 43 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= 39 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else if ( (*( sm->p)) > 47 ) {
			if ( (*( sm->p)) < 95 ) {
				if ( (*( sm->p)) > 57 ) {
					if ( 65 <= (*( sm->p)) && (*( sm->p)) <= 90 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= 48 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > 95 ) {
				if ( (*( sm->p)) > 122 ) {
					if ( 127 <= (*( sm->p)) )
 {						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= 97 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else {
			_widec = (short)(640 + ((*( sm->p)) - -128));
			if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
		}
	} else {
		_widec = (short)(640 + ((*( sm->p)) - -128));
		if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
	}
	switch( _widec ) {
		case 994: goto st848;
		case 995: goto st850;
		case 1007: goto st852;
		case 1057: goto st834;
		case 1063: goto st856;
		case 1067: goto st834;
		case 1119: goto st834;
		case 1151: goto tr1022;
	}
	if ( _widec < 1025 ) {
		if ( _widec < 992 ) {
			if ( _widec > 961 ) {
				if ( 962 <= _widec && _widec <= 991 )
					goto st846;
			} else if ( _widec >= 896 )
				goto st835;
		} else if ( _widec > 1006 ) {
			if ( _widec > 1012 ) {
				if ( 1013 <= _widec && _widec <= 1023 )
					goto st835;
			} else if ( _widec >= 1008 )
				goto st855;
		} else
			goto st847;
	} else if ( _widec > 1032 ) {
		if ( _widec < 1072 ) {
			if ( _widec > 1055 ) {
				if ( 1069 <= _widec && _widec <= 1071 )
					goto st834;
			} else if ( _widec >= 1038 )
				goto tr1022;
		} else if ( _widec > 1081 ) {
			if ( _widec > 1114 ) {
				if ( 1121 <= _widec && _widec <= 1146 )
					goto tr1022;
			} else if ( _widec >= 1089 )
				goto tr1022;
		} else
			goto tr1022;
	} else
		goto tr1022;
	goto tr1869;
st847:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof847;
case 847:
	_widec = (*( sm->p));
	if ( (*( sm->p)) < 1 ) {
		if ( (*( sm->p)) < -30 ) {
			if ( (*( sm->p)) < -64 ) {
				if ( (*( sm->p)) <= -65 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > -63 ) {
				if ( (*( sm->p)) > -33 ) {
					if ( -32 <= (*( sm->p)) && (*( sm->p)) <= -31 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= -62 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else if ( (*( sm->p)) > -30 ) {
			if ( (*( sm->p)) < -17 ) {
				if ( (*( sm->p)) > -29 ) {
					if ( -28 <= (*( sm->p)) && (*( sm->p)) <= -18 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= -29 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > -17 ) {
				if ( (*( sm->p)) > -12 ) {
					if ( -11 <= (*( sm->p)) && (*( sm->p)) <= -1 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= -16 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else {
			_widec = (short)(640 + ((*( sm->p)) - -128));
			if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
		}
	} else if ( (*( sm->p)) > 8 ) {
		if ( (*( sm->p)) < 45 ) {
			if ( (*( sm->p)) < 33 ) {
				if ( 14 <= (*( sm->p)) && (*( sm->p)) <= 31 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > 33 ) {
				if ( (*( sm->p)) > 39 ) {
					if ( 43 <= (*( sm->p)) && (*( sm->p)) <= 43 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= 39 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else if ( (*( sm->p)) > 47 ) {
			if ( (*( sm->p)) < 95 ) {
				if ( (*( sm->p)) > 57 ) {
					if ( 65 <= (*( sm->p)) && (*( sm->p)) <= 90 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= 48 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > 95 ) {
				if ( (*( sm->p)) > 122 ) {
					if ( 127 <= (*( sm->p)) )
 {						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= 97 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else {
			_widec = (short)(640 + ((*( sm->p)) - -128));
			if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
		}
	} else {
		_widec = (short)(640 + ((*( sm->p)) - -128));
		if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
	}
	switch( _widec ) {
		case 994: goto st838;
		case 995: goto st840;
		case 1007: goto st842;
		case 1057: goto st835;
		case 1063: goto st835;
		case 1067: goto st835;
		case 1119: goto st835;
		case 1151: goto tr1030;
	}
	if ( _widec < 1013 ) {
		if ( _widec < 962 ) {
			if ( _widec > 959 ) {
				if ( 960 <= _widec && _widec <= 961 )
					goto st835;
			} else if ( _widec >= 896 )
				goto st846;
		} else if ( _widec > 991 ) {
			if ( _widec > 1006 ) {
				if ( 1008 <= _widec && _widec <= 1012 )
					goto st844;
			} else if ( _widec >= 992 )
				goto st837;
		} else
			goto st836;
	} else if ( _widec > 1023 ) {
		if ( _widec < 1069 ) {
			if ( _widec > 1032 ) {
				if ( 1038 <= _widec && _widec <= 1055 )
					goto tr1030;
			} else if ( _widec >= 1025 )
				goto tr1030;
		} else if ( _widec > 1071 ) {
			if ( _widec < 1089 ) {
				if ( 1072 <= _widec && _widec <= 1081 )
					goto tr1030;
			} else if ( _widec > 1114 ) {
				if ( 1121 <= _widec && _widec <= 1146 )
					goto tr1030;
			} else
				goto tr1030;
		} else
			goto st835;
	} else
		goto st835;
	goto tr185;
st848:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof848;
case 848:
	_widec = (*( sm->p));
	if ( (*( sm->p)) < -11 ) {
		if ( (*( sm->p)) < -32 ) {
			if ( (*( sm->p)) < -98 ) {
				if ( (*( sm->p)) > -100 ) {
					if ( -99 <= (*( sm->p)) && (*( sm->p)) <= -99 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > -65 ) {
				if ( (*( sm->p)) > -63 ) {
					if ( -62 <= (*( sm->p)) && (*( sm->p)) <= -33 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= -64 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else if ( (*( sm->p)) > -31 ) {
			if ( (*( sm->p)) < -28 ) {
				if ( (*( sm->p)) > -30 ) {
					if ( -29 <= (*( sm->p)) && (*( sm->p)) <= -29 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= -30 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > -18 ) {
				if ( (*( sm->p)) > -17 ) {
					if ( -16 <= (*( sm->p)) && (*( sm->p)) <= -12 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= -17 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else {
			_widec = (short)(640 + ((*( sm->p)) - -128));
			if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
		}
	} else if ( (*( sm->p)) > -1 ) {
		if ( (*( sm->p)) < 45 ) {
			if ( (*( sm->p)) < 33 ) {
				if ( (*( sm->p)) > 8 ) {
					if ( 14 <= (*( sm->p)) && (*( sm->p)) <= 31 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= 1 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > 33 ) {
				if ( (*( sm->p)) > 39 ) {
					if ( 43 <= (*( sm->p)) && (*( sm->p)) <= 43 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= 39 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else if ( (*( sm->p)) > 47 ) {
			if ( (*( sm->p)) < 95 ) {
				if ( (*( sm->p)) > 57 ) {
					if ( 65 <= (*( sm->p)) && (*( sm->p)) <= 90 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= 48 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > 95 ) {
				if ( (*( sm->p)) > 122 ) {
					if ( 127 <= (*( sm->p)) )
 {						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= 97 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else {
			_widec = (short)(640 + ((*( sm->p)) - -128));
			if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
		}
	} else {
		_widec = (short)(640 + ((*( sm->p)) - -128));
		if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
	}
	switch( _widec ) {
		case 925: goto st849;
		case 994: goto st838;
		case 995: goto st840;
		case 1007: goto st842;
		case 1057: goto st835;
		case 1063: goto st835;
		case 1067: goto st835;
		case 1119: goto st835;
		case 1151: goto tr1030;
	}
	if ( _widec < 1013 ) {
		if ( _widec < 962 ) {
			if ( _widec > 959 ) {
				if ( 960 <= _widec && _widec <= 961 )
					goto st835;
			} else if ( _widec >= 896 )
				goto st846;
		} else if ( _widec > 991 ) {
			if ( _widec > 1006 ) {
				if ( 1008 <= _widec && _widec <= 1012 )
					goto st844;
			} else if ( _widec >= 992 )
				goto st837;
		} else
			goto st836;
	} else if ( _widec > 1023 ) {
		if ( _widec < 1069 ) {
			if ( _widec > 1032 ) {
				if ( 1038 <= _widec && _widec <= 1055 )
					goto tr1030;
			} else if ( _widec >= 1025 )
				goto tr1030;
		} else if ( _widec > 1071 ) {
			if ( _widec < 1089 ) {
				if ( 1072 <= _widec && _widec <= 1081 )
					goto tr1030;
			} else if ( _widec > 1114 ) {
				if ( 1121 <= _widec && _widec <= 1146 )
					goto tr1030;
			} else
				goto tr1030;
		} else
			goto st835;
	} else
		goto st835;
	goto tr185;
st849:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof849;
case 849:
	_widec = (*( sm->p));
	if ( (*( sm->p)) < -11 ) {
		if ( (*( sm->p)) < -32 ) {
			if ( (*( sm->p)) < -82 ) {
				if ( (*( sm->p)) > -84 ) {
					if ( -83 <= (*( sm->p)) && (*( sm->p)) <= -83 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > -65 ) {
				if ( (*( sm->p)) > -63 ) {
					if ( -62 <= (*( sm->p)) && (*( sm->p)) <= -33 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= -64 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else if ( (*( sm->p)) > -31 ) {
			if ( (*( sm->p)) < -28 ) {
				if ( (*( sm->p)) > -30 ) {
					if ( -29 <= (*( sm->p)) && (*( sm->p)) <= -29 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= -30 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > -18 ) {
				if ( (*( sm->p)) > -17 ) {
					if ( -16 <= (*( sm->p)) && (*( sm->p)) <= -12 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= -17 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else {
			_widec = (short)(640 + ((*( sm->p)) - -128));
			if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
		}
	} else if ( (*( sm->p)) > -1 ) {
		if ( (*( sm->p)) < 45 ) {
			if ( (*( sm->p)) < 33 ) {
				if ( (*( sm->p)) > 8 ) {
					if ( 14 <= (*( sm->p)) && (*( sm->p)) <= 31 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= 1 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > 33 ) {
				if ( (*( sm->p)) > 39 ) {
					if ( 43 <= (*( sm->p)) && (*( sm->p)) <= 43 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= 39 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else if ( (*( sm->p)) > 47 ) {
			if ( (*( sm->p)) < 95 ) {
				if ( (*( sm->p)) > 57 ) {
					if ( 65 <= (*( sm->p)) && (*( sm->p)) <= 90 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= 48 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > 95 ) {
				if ( (*( sm->p)) > 122 ) {
					if ( 127 <= (*( sm->p)) )
 {						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= 97 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else {
			_widec = (short)(640 + ((*( sm->p)) - -128));
			if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
		}
	} else {
		_widec = (short)(640 + ((*( sm->p)) - -128));
		if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
	}
	switch( _widec ) {
		case 941: goto st834;
		case 994: goto st838;
		case 995: goto st840;
		case 1007: goto st842;
		case 1057: goto st835;
		case 1063: goto st835;
		case 1067: goto st835;
		case 1119: goto st835;
		case 1151: goto tr1030;
	}
	if ( _widec < 1013 ) {
		if ( _widec < 962 ) {
			if ( _widec > 959 ) {
				if ( 960 <= _widec && _widec <= 961 )
					goto st835;
			} else if ( _widec >= 896 )
				goto tr1022;
		} else if ( _widec > 991 ) {
			if ( _widec > 1006 ) {
				if ( 1008 <= _widec && _widec <= 1012 )
					goto st844;
			} else if ( _widec >= 992 )
				goto st837;
		} else
			goto st836;
	} else if ( _widec > 1023 ) {
		if ( _widec < 1069 ) {
			if ( _widec > 1032 ) {
				if ( 1038 <= _widec && _widec <= 1055 )
					goto tr1030;
			} else if ( _widec >= 1025 )
				goto tr1030;
		} else if ( _widec > 1071 ) {
			if ( _widec < 1089 ) {
				if ( 1072 <= _widec && _widec <= 1081 )
					goto tr1030;
			} else if ( _widec > 1114 ) {
				if ( 1121 <= _widec && _widec <= 1146 )
					goto tr1030;
			} else
				goto tr1030;
		} else
			goto st835;
	} else
		goto st835;
	goto tr185;
st850:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof850;
case 850:
	_widec = (*( sm->p));
	if ( (*( sm->p)) < -11 ) {
		if ( (*( sm->p)) < -32 ) {
			if ( (*( sm->p)) < -127 ) {
				if ( (*( sm->p)) <= -128 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > -65 ) {
				if ( (*( sm->p)) > -63 ) {
					if ( -62 <= (*( sm->p)) && (*( sm->p)) <= -33 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= -64 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else if ( (*( sm->p)) > -31 ) {
			if ( (*( sm->p)) < -28 ) {
				if ( (*( sm->p)) > -30 ) {
					if ( -29 <= (*( sm->p)) && (*( sm->p)) <= -29 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= -30 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > -18 ) {
				if ( (*( sm->p)) > -17 ) {
					if ( -16 <= (*( sm->p)) && (*( sm->p)) <= -12 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= -17 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else {
			_widec = (short)(640 + ((*( sm->p)) - -128));
			if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
		}
	} else if ( (*( sm->p)) > -1 ) {
		if ( (*( sm->p)) < 45 ) {
			if ( (*( sm->p)) < 33 ) {
				if ( (*( sm->p)) > 8 ) {
					if ( 14 <= (*( sm->p)) && (*( sm->p)) <= 31 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= 1 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > 33 ) {
				if ( (*( sm->p)) > 39 ) {
					if ( 43 <= (*( sm->p)) && (*( sm->p)) <= 43 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= 39 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else if ( (*( sm->p)) > 47 ) {
			if ( (*( sm->p)) < 95 ) {
				if ( (*( sm->p)) > 57 ) {
					if ( 65 <= (*( sm->p)) && (*( sm->p)) <= 90 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= 48 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > 95 ) {
				if ( (*( sm->p)) > 122 ) {
					if ( 127 <= (*( sm->p)) )
 {						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= 97 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else {
			_widec = (short)(640 + ((*( sm->p)) - -128));
			if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
		}
	} else {
		_widec = (short)(640 + ((*( sm->p)) - -128));
		if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
	}
	switch( _widec ) {
		case 896: goto st851;
		case 994: goto st838;
		case 995: goto st840;
		case 1007: goto st842;
		case 1057: goto st835;
		case 1063: goto st835;
		case 1067: goto st835;
		case 1119: goto st835;
		case 1151: goto tr1030;
	}
	if ( _widec < 1013 ) {
		if ( _widec < 962 ) {
			if ( _widec > 959 ) {
				if ( 960 <= _widec && _widec <= 961 )
					goto st835;
			} else if ( _widec >= 897 )
				goto st846;
		} else if ( _widec > 991 ) {
			if ( _widec > 1006 ) {
				if ( 1008 <= _widec && _widec <= 1012 )
					goto st844;
			} else if ( _widec >= 992 )
				goto st837;
		} else
			goto st836;
	} else if ( _widec > 1023 ) {
		if ( _widec < 1069 ) {
			if ( _widec > 1032 ) {
				if ( 1038 <= _widec && _widec <= 1055 )
					goto tr1030;
			} else if ( _widec >= 1025 )
				goto tr1030;
		} else if ( _widec > 1071 ) {
			if ( _widec < 1089 ) {
				if ( 1072 <= _widec && _widec <= 1081 )
					goto tr1030;
			} else if ( _widec > 1114 ) {
				if ( 1121 <= _widec && _widec <= 1146 )
					goto tr1030;
			} else
				goto tr1030;
		} else
			goto st835;
	} else
		goto st835;
	goto tr185;
st851:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof851;
case 851:
	_widec = (*( sm->p));
	if ( (*( sm->p)) < -17 ) {
		if ( (*( sm->p)) < -99 ) {
			if ( (*( sm->p)) < -120 ) {
				if ( (*( sm->p)) > -126 ) {
					if ( -125 <= (*( sm->p)) && (*( sm->p)) <= -121 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > -111 ) {
				if ( (*( sm->p)) > -109 ) {
					if ( -108 <= (*( sm->p)) && (*( sm->p)) <= -100 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= -110 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else if ( (*( sm->p)) > -65 ) {
			if ( (*( sm->p)) < -32 ) {
				if ( (*( sm->p)) > -63 ) {
					if ( -62 <= (*( sm->p)) && (*( sm->p)) <= -33 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= -64 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > -31 ) {
				if ( (*( sm->p)) < -29 ) {
					if ( -30 <= (*( sm->p)) && (*( sm->p)) <= -30 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) > -29 ) {
					if ( -28 <= (*( sm->p)) && (*( sm->p)) <= -18 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else {
			_widec = (short)(640 + ((*( sm->p)) - -128));
			if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
		}
	} else if ( (*( sm->p)) > -17 ) {
		if ( (*( sm->p)) < 43 ) {
			if ( (*( sm->p)) < 1 ) {
				if ( (*( sm->p)) > -12 ) {
					if ( -11 <= (*( sm->p)) && (*( sm->p)) <= -1 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= -16 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > 8 ) {
				if ( (*( sm->p)) < 33 ) {
					if ( 14 <= (*( sm->p)) && (*( sm->p)) <= 31 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) > 33 ) {
					if ( 39 <= (*( sm->p)) && (*( sm->p)) <= 39 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else if ( (*( sm->p)) > 43 ) {
			if ( (*( sm->p)) < 65 ) {
				if ( (*( sm->p)) > 47 ) {
					if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= 45 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > 90 ) {
				if ( (*( sm->p)) < 97 ) {
					if ( 95 <= (*( sm->p)) && (*( sm->p)) <= 95 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) > 122 ) {
					if ( 127 <= (*( sm->p)) )
 {						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else {
			_widec = (short)(640 + ((*( sm->p)) - -128));
			if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
		}
	} else {
		_widec = (short)(640 + ((*( sm->p)) - -128));
		if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
	}
	switch( _widec ) {
		case 994: goto st838;
		case 995: goto st840;
		case 1007: goto st842;
		case 1057: goto st835;
		case 1063: goto st835;
		case 1067: goto st835;
		case 1119: goto st835;
		case 1151: goto tr1030;
	}
	if ( _widec < 992 ) {
		if ( _widec < 914 ) {
			if ( _widec < 899 ) {
				if ( 896 <= _widec && _widec <= 898 )
					goto st834;
			} else if ( _widec > 903 ) {
				if ( 904 <= _widec && _widec <= 913 )
					goto st834;
			} else
				goto tr1022;
		} else if ( _widec > 915 ) {
			if ( _widec < 925 ) {
				if ( 916 <= _widec && _widec <= 924 )
					goto st834;
			} else if ( _widec > 959 ) {
				if ( _widec > 961 ) {
					if ( 962 <= _widec && _widec <= 991 )
						goto st836;
				} else if ( _widec >= 960 )
					goto st835;
			} else
				goto tr1022;
		} else
			goto tr1022;
	} else if ( _widec > 1006 ) {
		if ( _widec < 1038 ) {
			if ( _widec < 1013 ) {
				if ( 1008 <= _widec && _widec <= 1012 )
					goto st844;
			} else if ( _widec > 1023 ) {
				if ( 1025 <= _widec && _widec <= 1032 )
					goto tr1030;
			} else
				goto st835;
		} else if ( _widec > 1055 ) {
			if ( _widec < 1072 ) {
				if ( 1069 <= _widec && _widec <= 1071 )
					goto st835;
			} else if ( _widec > 1081 ) {
				if ( _widec > 1114 ) {
					if ( 1121 <= _widec && _widec <= 1146 )
						goto tr1030;
				} else if ( _widec >= 1089 )
					goto tr1030;
			} else
				goto tr1030;
		} else
			goto tr1030;
	} else
		goto st837;
	goto tr185;
st852:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof852;
case 852:
	_widec = (*( sm->p));
	if ( (*( sm->p)) < -16 ) {
		if ( (*( sm->p)) < -62 ) {
			if ( (*( sm->p)) < -67 ) {
				if ( (*( sm->p)) > -69 ) {
					if ( -68 <= (*( sm->p)) && (*( sm->p)) <= -68 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > -67 ) {
				if ( (*( sm->p)) > -65 ) {
					if ( -64 <= (*( sm->p)) && (*( sm->p)) <= -63 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= -66 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else if ( (*( sm->p)) > -33 ) {
			if ( (*( sm->p)) < -29 ) {
				if ( (*( sm->p)) > -31 ) {
					if ( -30 <= (*( sm->p)) && (*( sm->p)) <= -30 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= -32 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > -29 ) {
				if ( (*( sm->p)) > -18 ) {
					if ( -17 <= (*( sm->p)) && (*( sm->p)) <= -17 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= -28 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else {
			_widec = (short)(640 + ((*( sm->p)) - -128));
			if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
		}
	} else if ( (*( sm->p)) > -12 ) {
		if ( (*( sm->p)) < 43 ) {
			if ( (*( sm->p)) < 14 ) {
				if ( (*( sm->p)) > -1 ) {
					if ( 1 <= (*( sm->p)) && (*( sm->p)) <= 8 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= -11 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > 31 ) {
				if ( (*( sm->p)) > 33 ) {
					if ( 39 <= (*( sm->p)) && (*( sm->p)) <= 39 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= 33 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else if ( (*( sm->p)) > 43 ) {
			if ( (*( sm->p)) < 65 ) {
				if ( (*( sm->p)) > 47 ) {
					if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= 45 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > 90 ) {
				if ( (*( sm->p)) < 97 ) {
					if ( 95 <= (*( sm->p)) && (*( sm->p)) <= 95 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) > 122 ) {
					if ( 127 <= (*( sm->p)) )
 {						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else {
			_widec = (short)(640 + ((*( sm->p)) - -128));
			if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
		}
	} else {
		_widec = (short)(640 + ((*( sm->p)) - -128));
		if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
	}
	switch( _widec ) {
		case 956: goto st853;
		case 957: goto st854;
		case 994: goto st838;
		case 995: goto st840;
		case 1007: goto st842;
		case 1057: goto st835;
		case 1063: goto st835;
		case 1067: goto st835;
		case 1119: goto st835;
		case 1151: goto tr1030;
	}
	if ( _widec < 1013 ) {
		if ( _widec < 962 ) {
			if ( _widec > 959 ) {
				if ( 960 <= _widec && _widec <= 961 )
					goto st835;
			} else if ( _widec >= 896 )
				goto st846;
		} else if ( _widec > 991 ) {
			if ( _widec > 1006 ) {
				if ( 1008 <= _widec && _widec <= 1012 )
					goto st844;
			} else if ( _widec >= 992 )
				goto st837;
		} else
			goto st836;
	} else if ( _widec > 1023 ) {
		if ( _widec < 1069 ) {
			if ( _widec > 1032 ) {
				if ( 1038 <= _widec && _widec <= 1055 )
					goto tr1030;
			} else if ( _widec >= 1025 )
				goto tr1030;
		} else if ( _widec > 1071 ) {
			if ( _widec < 1089 ) {
				if ( 1072 <= _widec && _widec <= 1081 )
					goto tr1030;
			} else if ( _widec > 1114 ) {
				if ( 1121 <= _widec && _widec <= 1146 )
					goto tr1030;
			} else
				goto tr1030;
		} else
			goto st835;
	} else
		goto st835;
	goto tr185;
st853:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof853;
case 853:
	_widec = (*( sm->p));
	if ( (*( sm->p)) < -16 ) {
		if ( (*( sm->p)) < -64 ) {
			if ( (*( sm->p)) < -118 ) {
				if ( (*( sm->p)) > -120 ) {
					if ( -119 <= (*( sm->p)) && (*( sm->p)) <= -119 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > -68 ) {
				if ( (*( sm->p)) > -67 ) {
					if ( -66 <= (*( sm->p)) && (*( sm->p)) <= -65 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= -67 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else if ( (*( sm->p)) > -63 ) {
			if ( (*( sm->p)) < -30 ) {
				if ( (*( sm->p)) > -33 ) {
					if ( -32 <= (*( sm->p)) && (*( sm->p)) <= -31 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= -62 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > -30 ) {
				if ( (*( sm->p)) < -28 ) {
					if ( -29 <= (*( sm->p)) && (*( sm->p)) <= -29 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) > -18 ) {
					if ( -17 <= (*( sm->p)) && (*( sm->p)) <= -17 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else {
			_widec = (short)(640 + ((*( sm->p)) - -128));
			if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
		}
	} else if ( (*( sm->p)) > -12 ) {
		if ( (*( sm->p)) < 43 ) {
			if ( (*( sm->p)) < 14 ) {
				if ( (*( sm->p)) > -1 ) {
					if ( 1 <= (*( sm->p)) && (*( sm->p)) <= 8 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= -11 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > 31 ) {
				if ( (*( sm->p)) > 33 ) {
					if ( 39 <= (*( sm->p)) && (*( sm->p)) <= 39 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= 33 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else if ( (*( sm->p)) > 43 ) {
			if ( (*( sm->p)) < 65 ) {
				if ( (*( sm->p)) > 47 ) {
					if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= 45 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > 90 ) {
				if ( (*( sm->p)) < 97 ) {
					if ( 95 <= (*( sm->p)) && (*( sm->p)) <= 95 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) > 122 ) {
					if ( 127 <= (*( sm->p)) )
 {						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else {
			_widec = (short)(640 + ((*( sm->p)) - -128));
			if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
		}
	} else {
		_widec = (short)(640 + ((*( sm->p)) - -128));
		if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
	}
	switch( _widec ) {
		case 905: goto st834;
		case 957: goto st834;
		case 994: goto st838;
		case 995: goto st840;
		case 1007: goto st842;
		case 1057: goto st835;
		case 1063: goto st835;
		case 1067: goto st835;
		case 1119: goto st835;
		case 1151: goto tr1030;
	}
	if ( _widec < 1013 ) {
		if ( _widec < 962 ) {
			if ( _widec > 959 ) {
				if ( 960 <= _widec && _widec <= 961 )
					goto st835;
			} else if ( _widec >= 896 )
				goto tr1022;
		} else if ( _widec > 991 ) {
			if ( _widec > 1006 ) {
				if ( 1008 <= _widec && _widec <= 1012 )
					goto st844;
			} else if ( _widec >= 992 )
				goto st837;
		} else
			goto st836;
	} else if ( _widec > 1023 ) {
		if ( _widec < 1069 ) {
			if ( _widec > 1032 ) {
				if ( 1038 <= _widec && _widec <= 1055 )
					goto tr1030;
			} else if ( _widec >= 1025 )
				goto tr1030;
		} else if ( _widec > 1071 ) {
			if ( _widec < 1089 ) {
				if ( 1072 <= _widec && _widec <= 1081 )
					goto tr1030;
			} else if ( _widec > 1114 ) {
				if ( 1121 <= _widec && _widec <= 1146 )
					goto tr1030;
			} else
				goto tr1030;
		} else
			goto st835;
	} else
		goto st835;
	goto tr185;
st854:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof854;
case 854:
	_widec = (*( sm->p));
	if ( (*( sm->p)) < -17 ) {
		if ( (*( sm->p)) < -92 ) {
			if ( (*( sm->p)) < -98 ) {
				if ( (*( sm->p)) > -100 ) {
					if ( -99 <= (*( sm->p)) && (*( sm->p)) <= -99 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > -97 ) {
				if ( (*( sm->p)) < -95 ) {
					if ( -96 <= (*( sm->p)) && (*( sm->p)) <= -96 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) > -94 ) {
					if ( -93 <= (*( sm->p)) && (*( sm->p)) <= -93 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else if ( (*( sm->p)) > -65 ) {
			if ( (*( sm->p)) < -32 ) {
				if ( (*( sm->p)) > -63 ) {
					if ( -62 <= (*( sm->p)) && (*( sm->p)) <= -33 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= -64 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > -31 ) {
				if ( (*( sm->p)) < -29 ) {
					if ( -30 <= (*( sm->p)) && (*( sm->p)) <= -30 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) > -29 ) {
					if ( -28 <= (*( sm->p)) && (*( sm->p)) <= -18 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else {
			_widec = (short)(640 + ((*( sm->p)) - -128));
			if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
		}
	} else if ( (*( sm->p)) > -17 ) {
		if ( (*( sm->p)) < 43 ) {
			if ( (*( sm->p)) < 1 ) {
				if ( (*( sm->p)) > -12 ) {
					if ( -11 <= (*( sm->p)) && (*( sm->p)) <= -1 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= -16 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > 8 ) {
				if ( (*( sm->p)) < 33 ) {
					if ( 14 <= (*( sm->p)) && (*( sm->p)) <= 31 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) > 33 ) {
					if ( 39 <= (*( sm->p)) && (*( sm->p)) <= 39 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else if ( (*( sm->p)) > 43 ) {
			if ( (*( sm->p)) < 65 ) {
				if ( (*( sm->p)) > 47 ) {
					if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= 45 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > 90 ) {
				if ( (*( sm->p)) < 97 ) {
					if ( 95 <= (*( sm->p)) && (*( sm->p)) <= 95 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) > 122 ) {
					if ( 127 <= (*( sm->p)) )
 {						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else {
			_widec = (short)(640 + ((*( sm->p)) - -128));
			if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
		}
	} else {
		_widec = (short)(640 + ((*( sm->p)) - -128));
		if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
	}
	switch( _widec ) {
		case 925: goto st834;
		case 928: goto st834;
		case 931: goto st834;
		case 994: goto st838;
		case 995: goto st840;
		case 1007: goto st842;
		case 1057: goto st835;
		case 1063: goto st835;
		case 1067: goto st835;
		case 1119: goto st835;
		case 1151: goto tr1030;
	}
	if ( _widec < 1013 ) {
		if ( _widec < 962 ) {
			if ( _widec > 959 ) {
				if ( 960 <= _widec && _widec <= 961 )
					goto st835;
			} else if ( _widec >= 896 )
				goto tr1022;
		} else if ( _widec > 991 ) {
			if ( _widec > 1006 ) {
				if ( 1008 <= _widec && _widec <= 1012 )
					goto st844;
			} else if ( _widec >= 992 )
				goto st837;
		} else
			goto st836;
	} else if ( _widec > 1023 ) {
		if ( _widec < 1069 ) {
			if ( _widec > 1032 ) {
				if ( 1038 <= _widec && _widec <= 1055 )
					goto tr1030;
			} else if ( _widec >= 1025 )
				goto tr1030;
		} else if ( _widec > 1071 ) {
			if ( _widec < 1089 ) {
				if ( 1072 <= _widec && _widec <= 1081 )
					goto tr1030;
			} else if ( _widec > 1114 ) {
				if ( 1121 <= _widec && _widec <= 1146 )
					goto tr1030;
			} else
				goto tr1030;
		} else
			goto st835;
	} else
		goto st835;
	goto tr185;
st855:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof855;
case 855:
	_widec = (*( sm->p));
	if ( (*( sm->p)) < 1 ) {
		if ( (*( sm->p)) < -30 ) {
			if ( (*( sm->p)) < -64 ) {
				if ( (*( sm->p)) <= -65 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > -63 ) {
				if ( (*( sm->p)) > -33 ) {
					if ( -32 <= (*( sm->p)) && (*( sm->p)) <= -31 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= -62 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else if ( (*( sm->p)) > -30 ) {
			if ( (*( sm->p)) < -17 ) {
				if ( (*( sm->p)) > -29 ) {
					if ( -28 <= (*( sm->p)) && (*( sm->p)) <= -18 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= -29 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > -17 ) {
				if ( (*( sm->p)) > -12 ) {
					if ( -11 <= (*( sm->p)) && (*( sm->p)) <= -1 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= -16 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else {
			_widec = (short)(640 + ((*( sm->p)) - -128));
			if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
		}
	} else if ( (*( sm->p)) > 8 ) {
		if ( (*( sm->p)) < 45 ) {
			if ( (*( sm->p)) < 33 ) {
				if ( 14 <= (*( sm->p)) && (*( sm->p)) <= 31 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > 33 ) {
				if ( (*( sm->p)) > 39 ) {
					if ( 43 <= (*( sm->p)) && (*( sm->p)) <= 43 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= 39 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else if ( (*( sm->p)) > 47 ) {
			if ( (*( sm->p)) < 95 ) {
				if ( (*( sm->p)) > 57 ) {
					if ( 65 <= (*( sm->p)) && (*( sm->p)) <= 90 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= 48 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > 95 ) {
				if ( (*( sm->p)) > 122 ) {
					if ( 127 <= (*( sm->p)) )
 {						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= 97 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else {
			_widec = (short)(640 + ((*( sm->p)) - -128));
			if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
		}
	} else {
		_widec = (short)(640 + ((*( sm->p)) - -128));
		if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
	}
	switch( _widec ) {
		case 994: goto st838;
		case 995: goto st840;
		case 1007: goto st842;
		case 1057: goto st835;
		case 1063: goto st835;
		case 1067: goto st835;
		case 1119: goto st835;
		case 1151: goto tr1030;
	}
	if ( _widec < 1013 ) {
		if ( _widec < 962 ) {
			if ( _widec > 959 ) {
				if ( 960 <= _widec && _widec <= 961 )
					goto st835;
			} else if ( _widec >= 896 )
				goto st847;
		} else if ( _widec > 991 ) {
			if ( _widec > 1006 ) {
				if ( 1008 <= _widec && _widec <= 1012 )
					goto st844;
			} else if ( _widec >= 992 )
				goto st837;
		} else
			goto st836;
	} else if ( _widec > 1023 ) {
		if ( _widec < 1069 ) {
			if ( _widec > 1032 ) {
				if ( 1038 <= _widec && _widec <= 1055 )
					goto tr1030;
			} else if ( _widec >= 1025 )
				goto tr1030;
		} else if ( _widec > 1071 ) {
			if ( _widec < 1089 ) {
				if ( 1072 <= _widec && _widec <= 1081 )
					goto tr1030;
			} else if ( _widec > 1114 ) {
				if ( 1121 <= _widec && _widec <= 1146 )
					goto tr1030;
			} else
				goto tr1030;
		} else
			goto st835;
	} else
		goto st835;
	goto tr185;
st856:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof856;
case 856:
	_widec = (*( sm->p));
	if ( (*( sm->p)) < 33 ) {
		if ( (*( sm->p)) < -28 ) {
			if ( (*( sm->p)) < -32 ) {
				if ( (*( sm->p)) > -63 ) {
					if ( -62 <= (*( sm->p)) && (*( sm->p)) <= -33 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > -31 ) {
				if ( (*( sm->p)) > -30 ) {
					if ( -29 <= (*( sm->p)) && (*( sm->p)) <= -29 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= -30 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else if ( (*( sm->p)) > -18 ) {
			if ( (*( sm->p)) < -11 ) {
				if ( (*( sm->p)) > -17 ) {
					if ( -16 <= (*( sm->p)) && (*( sm->p)) <= -12 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= -17 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > -1 ) {
				if ( (*( sm->p)) > 8 ) {
					if ( 14 <= (*( sm->p)) && (*( sm->p)) <= 31 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= 1 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else {
			_widec = (short)(640 + ((*( sm->p)) - -128));
			if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
		}
	} else if ( (*( sm->p)) > 33 ) {
		if ( (*( sm->p)) < 95 ) {
			if ( (*( sm->p)) < 45 ) {
				if ( (*( sm->p)) > 39 ) {
					if ( 43 <= (*( sm->p)) && (*( sm->p)) <= 43 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= 39 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > 47 ) {
				if ( (*( sm->p)) > 57 ) {
					if ( 65 <= (*( sm->p)) && (*( sm->p)) <= 90 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= 48 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else if ( (*( sm->p)) > 95 ) {
			if ( (*( sm->p)) < 101 ) {
				if ( (*( sm->p)) > 99 ) {
					if ( 100 <= (*( sm->p)) && (*( sm->p)) <= 100 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= 97 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > 114 ) {
				if ( (*( sm->p)) < 116 ) {
					if ( 115 <= (*( sm->p)) && (*( sm->p)) <= 115 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) > 122 ) {
					if ( 127 <= (*( sm->p)) )
 {						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else {
			_widec = (short)(640 + ((*( sm->p)) - -128));
			if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
		}
	} else {
		_widec = (short)(640 + ((*( sm->p)) - -128));
		if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
	}
	switch( _widec ) {
		case 994: goto st848;
		case 995: goto st850;
		case 1007: goto st852;
		case 1057: goto st834;
		case 1063: goto st856;
		case 1067: goto st834;
		case 1119: goto st834;
		case 1124: goto st834;
		case 1139: goto st834;
		case 1151: goto tr1022;
	}
	if ( _widec < 1025 ) {
		if ( _widec < 992 ) {
			if ( _widec > 961 ) {
				if ( 962 <= _widec && _widec <= 991 )
					goto st846;
			} else if ( _widec >= 896 )
				goto st835;
		} else if ( _widec > 1006 ) {
			if ( _widec > 1012 ) {
				if ( 1013 <= _widec && _widec <= 1023 )
					goto st835;
			} else if ( _widec >= 1008 )
				goto st855;
		} else
			goto st847;
	} else if ( _widec > 1032 ) {
		if ( _widec < 1072 ) {
			if ( _widec > 1055 ) {
				if ( 1069 <= _widec && _widec <= 1071 )
					goto st834;
			} else if ( _widec >= 1038 )
				goto tr1022;
		} else if ( _widec > 1081 ) {
			if ( _widec > 1114 ) {
				if ( 1121 <= _widec && _widec <= 1146 )
					goto tr1022;
			} else if ( _widec >= 1089 )
				goto tr1022;
		} else
			goto tr1022;
	} else
		goto tr1022;
	goto tr185;
tr1862:
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st857;
st857:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof857;
case 857:
#line 25443 "ext/dtext/dtext.cpp"
	_widec = (*( sm->p));
	if ( (*( sm->p)) <= -65 ) {
		_widec = (short)(640 + ((*( sm->p)) - -128));
		if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
	}
	if ( 896 <= _widec && _widec <= 959 )
		goto st833;
	goto tr193;
tr1863:
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st858;
st858:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof858;
case 858:
#line 25462 "ext/dtext/dtext.cpp"
	_widec = (*( sm->p));
	if ( (*( sm->p)) < -99 ) {
		if ( (*( sm->p)) <= -100 ) {
			_widec = (short)(640 + ((*( sm->p)) - -128));
			if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
		}
	} else if ( (*( sm->p)) > -99 ) {
		if ( -98 <= (*( sm->p)) && (*( sm->p)) <= -65 ) {
			_widec = (short)(640 + ((*( sm->p)) - -128));
			if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
		}
	} else {
		_widec = (short)(640 + ((*( sm->p)) - -128));
		if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
	}
	if ( _widec == 925 )
		goto st859;
	if ( 896 <= _widec && _widec <= 959 )
		goto st833;
	goto tr193;
st859:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof859;
case 859:
	_widec = (*( sm->p));
	if ( (*( sm->p)) > -84 ) {
		if ( -82 <= (*( sm->p)) && (*( sm->p)) <= -65 ) {
			_widec = (short)(640 + ((*( sm->p)) - -128));
			if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
		}
	} else {
		_widec = (short)(640 + ((*( sm->p)) - -128));
		if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
	}
	if ( _widec > 940 ) {
		if ( 942 <= _widec && _widec <= 959 )
			goto st834;
	} else if ( _widec >= 896 )
		goto st834;
	goto tr193;
tr1864:
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st860;
st860:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof860;
case 860:
#line 25521 "ext/dtext/dtext.cpp"
	_widec = (*( sm->p));
	if ( (*( sm->p)) > -128 ) {
		if ( -127 <= (*( sm->p)) && (*( sm->p)) <= -65 ) {
			_widec = (short)(640 + ((*( sm->p)) - -128));
			if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
		}
	} else {
		_widec = (short)(640 + ((*( sm->p)) - -128));
		if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
	}
	if ( _widec == 896 )
		goto st861;
	if ( 897 <= _widec && _widec <= 959 )
		goto st833;
	goto tr193;
st861:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof861;
case 861:
	_widec = (*( sm->p));
	if ( (*( sm->p)) < -110 ) {
		if ( -125 <= (*( sm->p)) && (*( sm->p)) <= -121 ) {
			_widec = (short)(640 + ((*( sm->p)) - -128));
			if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
		}
	} else if ( (*( sm->p)) > -109 ) {
		if ( -99 <= (*( sm->p)) && (*( sm->p)) <= -65 ) {
			_widec = (short)(640 + ((*( sm->p)) - -128));
			if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
		}
	} else {
		_widec = (short)(640 + ((*( sm->p)) - -128));
		if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
	}
	if ( _widec < 914 ) {
		if ( 899 <= _widec && _widec <= 903 )
			goto st834;
	} else if ( _widec > 915 ) {
		if ( 925 <= _widec && _widec <= 959 )
			goto st834;
	} else
		goto st834;
	goto tr193;
tr1865:
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st862;
st862:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof862;
case 862:
#line 25583 "ext/dtext/dtext.cpp"
	_widec = (*( sm->p));
	if ( (*( sm->p)) < -68 ) {
		if ( (*( sm->p)) <= -69 ) {
			_widec = (short)(640 + ((*( sm->p)) - -128));
			if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
		}
	} else if ( (*( sm->p)) > -68 ) {
		if ( (*( sm->p)) > -67 ) {
			if ( -66 <= (*( sm->p)) && (*( sm->p)) <= -65 ) {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else if ( (*( sm->p)) >= -67 ) {
			_widec = (short)(640 + ((*( sm->p)) - -128));
			if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
		}
	} else {
		_widec = (short)(640 + ((*( sm->p)) - -128));
		if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
	}
	switch( _widec ) {
		case 956: goto st863;
		case 957: goto st864;
	}
	if ( 896 <= _widec && _widec <= 959 )
		goto st833;
	goto tr193;
st863:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof863;
case 863:
	_widec = (*( sm->p));
	if ( (*( sm->p)) < -118 ) {
		if ( (*( sm->p)) <= -120 ) {
			_widec = (short)(640 + ((*( sm->p)) - -128));
			if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
		}
	} else if ( (*( sm->p)) > -68 ) {
		if ( -66 <= (*( sm->p)) && (*( sm->p)) <= -65 ) {
			_widec = (short)(640 + ((*( sm->p)) - -128));
			if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
		}
	} else {
		_widec = (short)(640 + ((*( sm->p)) - -128));
		if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
	}
	if ( _widec < 906 ) {
		if ( 896 <= _widec && _widec <= 904 )
			goto st834;
	} else if ( _widec > 956 ) {
		if ( 958 <= _widec && _widec <= 959 )
			goto st834;
	} else
		goto st834;
	goto tr193;
st864:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof864;
case 864:
	_widec = (*( sm->p));
	if ( (*( sm->p)) < -98 ) {
		if ( (*( sm->p)) <= -100 ) {
			_widec = (short)(640 + ((*( sm->p)) - -128));
			if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
		}
	} else if ( (*( sm->p)) > -97 ) {
		if ( (*( sm->p)) > -94 ) {
			if ( -92 <= (*( sm->p)) && (*( sm->p)) <= -65 ) {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else if ( (*( sm->p)) >= -95 ) {
			_widec = (short)(640 + ((*( sm->p)) - -128));
			if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
		}
	} else {
		_widec = (short)(640 + ((*( sm->p)) - -128));
		if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
	}
	if ( _widec < 926 ) {
		if ( 896 <= _widec && _widec <= 924 )
			goto st834;
	} else if ( _widec > 927 ) {
		if ( _widec > 930 ) {
			if ( 932 <= _widec && _widec <= 959 )
				goto st834;
		} else if ( _widec >= 929 )
			goto st834;
	} else
		goto st834;
	goto tr193;
tr1866:
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st865;
st865:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof865;
case 865:
#line 25705 "ext/dtext/dtext.cpp"
	_widec = (*( sm->p));
	if ( (*( sm->p)) <= -65 ) {
		_widec = (short)(640 + ((*( sm->p)) - -128));
		if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
	}
	if ( 896 <= _widec && _widec <= 959 )
		goto st857;
	goto tr193;
tr1868:
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st866;
st866:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof866;
case 866:
#line 25724 "ext/dtext/dtext.cpp"
	_widec = (*( sm->p));
	if ( (*( sm->p)) < -16 ) {
		if ( (*( sm->p)) < -30 ) {
			if ( (*( sm->p)) > -33 ) {
				if ( -32 <= (*( sm->p)) && (*( sm->p)) <= -31 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) >= -62 ) {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else if ( (*( sm->p)) > -30 ) {
			if ( (*( sm->p)) < -28 ) {
				if ( -29 <= (*( sm->p)) && (*( sm->p)) <= -29 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > -18 ) {
				if ( -17 <= (*( sm->p)) && (*( sm->p)) <= -17 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else {
			_widec = (short)(640 + ((*( sm->p)) - -128));
			if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
		}
	} else if ( (*( sm->p)) > -12 ) {
		if ( (*( sm->p)) < 48 ) {
			if ( (*( sm->p)) > 8 ) {
				if ( 14 <= (*( sm->p)) && (*( sm->p)) <= 31 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) >= 1 ) {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else if ( (*( sm->p)) > 57 ) {
			if ( (*( sm->p)) < 97 ) {
				if ( 65 <= (*( sm->p)) && (*( sm->p)) <= 90 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > 122 ) {
				if ( 127 <= (*( sm->p)) )
 {					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else {
			_widec = (short)(640 + ((*( sm->p)) - -128));
			if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
		}
	} else {
		_widec = (short)(640 + ((*( sm->p)) - -128));
		if ( 
#line 83 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
	}
	switch( _widec ) {
		case 994: goto st858;
		case 995: goto st860;
		case 1007: goto st862;
		case 1151: goto st834;
	}
	if ( _widec < 1025 ) {
		if ( _widec < 992 ) {
			if ( 962 <= _widec && _widec <= 991 )
				goto st833;
		} else if ( _widec > 1006 ) {
			if ( 1008 <= _widec && _widec <= 1012 )
				goto st865;
		} else
			goto st857;
	} else if ( _widec > 1032 ) {
		if ( _widec < 1072 ) {
			if ( 1038 <= _widec && _widec <= 1055 )
				goto st834;
		} else if ( _widec > 1081 ) {
			if ( _widec > 1114 ) {
				if ( 1121 <= _widec && _widec <= 1146 )
					goto st834;
			} else if ( _widec >= 1089 )
				goto st834;
		} else
			goto st834;
	} else
		goto st834;
	goto tr193;
tr1049:
#line 557 "ext/dtext/dtext.cpp.rl"
	{{( sm->p) = ((( sm->te)))-1;}{
    append_html_escaped(sm, (*( sm->p)));
  }}
	goto st1405;
tr1055:
#line 550 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_rewind(sm);
    { sm->cs = ( (sm->stack.data()))[--( sm->top)];goto _again;}
  }}
	goto st1405;
tr1870:
#line 557 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{
    append_html_escaped(sm, (*( sm->p)));
  }}
	goto st1405;
tr1871:
#line 555 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;}
	goto st1405;
tr1876:
#line 557 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append_html_escaped(sm, (*( sm->p)));
  }}
	goto st1405;
st1405:
#line 1 "NONE"
	{( sm->ts) = 0;}
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1405;
case 1405:
#line 1 "NONE"
	{( sm->ts) = ( sm->p);}
#line 25883 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr1871;
		case 10: goto tr1872;
		case 13: goto tr1873;
		case 60: goto tr1874;
		case 91: goto tr1875;
	}
	goto tr1870;
tr1872:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
	goto st1406;
st1406:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1406;
case 1406:
#line 25900 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 60: goto st867;
		case 91: goto st873;
	}
	goto tr1876;
st867:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof867;
case 867:
	if ( (*( sm->p)) == 47 )
		goto st868;
	goto tr1049;
st868:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof868;
case 868:
	switch( (*( sm->p)) ) {
		case 67: goto st869;
		case 99: goto st869;
	}
	goto tr1049;
st869:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof869;
case 869:
	switch( (*( sm->p)) ) {
		case 79: goto st870;
		case 111: goto st870;
	}
	goto tr1049;
st870:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof870;
case 870:
	switch( (*( sm->p)) ) {
		case 68: goto st871;
		case 100: goto st871;
	}
	goto tr1049;
st871:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof871;
case 871:
	switch( (*( sm->p)) ) {
		case 69: goto st872;
		case 101: goto st872;
	}
	goto tr1049;
st872:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof872;
case 872:
	if ( (*( sm->p)) == 62 )
		goto tr1055;
	goto tr1049;
st873:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof873;
case 873:
	if ( (*( sm->p)) == 47 )
		goto st874;
	goto tr1049;
st874:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof874;
case 874:
	switch( (*( sm->p)) ) {
		case 67: goto st875;
		case 99: goto st875;
	}
	goto tr1049;
st875:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof875;
case 875:
	switch( (*( sm->p)) ) {
		case 79: goto st876;
		case 111: goto st876;
	}
	goto tr1049;
st876:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof876;
case 876:
	switch( (*( sm->p)) ) {
		case 68: goto st877;
		case 100: goto st877;
	}
	goto tr1049;
st877:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof877;
case 877:
	switch( (*( sm->p)) ) {
		case 69: goto st878;
		case 101: goto st878;
	}
	goto tr1049;
st878:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof878;
case 878:
	if ( (*( sm->p)) == 93 )
		goto tr1055;
	goto tr1049;
tr1873:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
	goto st1407;
st1407:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1407;
case 1407:
#line 26014 "ext/dtext/dtext.cpp"
	if ( (*( sm->p)) == 10 )
		goto st879;
	goto tr1876;
st879:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof879;
case 879:
	switch( (*( sm->p)) ) {
		case 60: goto st867;
		case 91: goto st873;
	}
	goto tr1049;
tr1874:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
	goto st1408;
st1408:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1408;
case 1408:
#line 26035 "ext/dtext/dtext.cpp"
	if ( (*( sm->p)) == 47 )
		goto st868;
	goto tr1876;
tr1875:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
	goto st1409;
st1409:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1409;
case 1409:
#line 26047 "ext/dtext/dtext.cpp"
	if ( (*( sm->p)) == 47 )
		goto st874;
	goto tr1876;
tr1063:
#line 570 "ext/dtext/dtext.cpp.rl"
	{{( sm->p) = ((( sm->te)))-1;}{
    append_html_escaped(sm, (*( sm->p)));
  }}
	goto st1410;
tr1072:
#line 563 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_rewind(sm);
    { sm->cs = ( (sm->stack.data()))[--( sm->top)];goto _again;}
  }}
	goto st1410;
tr1878:
#line 570 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{
    append_html_escaped(sm, (*( sm->p)));
  }}
	goto st1410;
tr1879:
#line 568 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;}
	goto st1410;
tr1884:
#line 570 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append_html_escaped(sm, (*( sm->p)));
  }}
	goto st1410;
st1410:
#line 1 "NONE"
	{( sm->ts) = 0;}
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1410;
case 1410:
#line 1 "NONE"
	{( sm->ts) = ( sm->p);}
#line 26088 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr1879;
		case 10: goto tr1880;
		case 13: goto tr1881;
		case 60: goto tr1882;
		case 91: goto tr1883;
	}
	goto tr1878;
tr1880:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
	goto st1411;
st1411:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1411;
case 1411:
#line 26105 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 60: goto st880;
		case 91: goto st889;
	}
	goto tr1884;
st880:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof880;
case 880:
	if ( (*( sm->p)) == 47 )
		goto st881;
	goto tr1063;
st881:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof881;
case 881:
	switch( (*( sm->p)) ) {
		case 78: goto st882;
		case 110: goto st882;
	}
	goto tr1063;
st882:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof882;
case 882:
	switch( (*( sm->p)) ) {
		case 79: goto st883;
		case 111: goto st883;
	}
	goto tr1063;
st883:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof883;
case 883:
	switch( (*( sm->p)) ) {
		case 68: goto st884;
		case 100: goto st884;
	}
	goto tr1063;
st884:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof884;
case 884:
	switch( (*( sm->p)) ) {
		case 84: goto st885;
		case 116: goto st885;
	}
	goto tr1063;
st885:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof885;
case 885:
	switch( (*( sm->p)) ) {
		case 69: goto st886;
		case 101: goto st886;
	}
	goto tr1063;
st886:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof886;
case 886:
	switch( (*( sm->p)) ) {
		case 88: goto st887;
		case 120: goto st887;
	}
	goto tr1063;
st887:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof887;
case 887:
	switch( (*( sm->p)) ) {
		case 84: goto st888;
		case 116: goto st888;
	}
	goto tr1063;
st888:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof888;
case 888:
	if ( (*( sm->p)) == 62 )
		goto tr1072;
	goto tr1063;
st889:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof889;
case 889:
	if ( (*( sm->p)) == 47 )
		goto st890;
	goto tr1063;
st890:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof890;
case 890:
	switch( (*( sm->p)) ) {
		case 78: goto st891;
		case 110: goto st891;
	}
	goto tr1063;
st891:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof891;
case 891:
	switch( (*( sm->p)) ) {
		case 79: goto st892;
		case 111: goto st892;
	}
	goto tr1063;
st892:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof892;
case 892:
	switch( (*( sm->p)) ) {
		case 68: goto st893;
		case 100: goto st893;
	}
	goto tr1063;
st893:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof893;
case 893:
	switch( (*( sm->p)) ) {
		case 84: goto st894;
		case 116: goto st894;
	}
	goto tr1063;
st894:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof894;
case 894:
	switch( (*( sm->p)) ) {
		case 69: goto st895;
		case 101: goto st895;
	}
	goto tr1063;
st895:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof895;
case 895:
	switch( (*( sm->p)) ) {
		case 88: goto st896;
		case 120: goto st896;
	}
	goto tr1063;
st896:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof896;
case 896:
	switch( (*( sm->p)) ) {
		case 84: goto st897;
		case 116: goto st897;
	}
	goto tr1063;
st897:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof897;
case 897:
	if ( (*( sm->p)) == 93 )
		goto tr1072;
	goto tr1063;
tr1881:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
	goto st1412;
st1412:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1412;
case 1412:
#line 26273 "ext/dtext/dtext.cpp"
	if ( (*( sm->p)) == 10 )
		goto st898;
	goto tr1884;
st898:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof898;
case 898:
	switch( (*( sm->p)) ) {
		case 60: goto st880;
		case 91: goto st889;
	}
	goto tr1063;
tr1882:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
	goto st1413;
st1413:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1413;
case 1413:
#line 26294 "ext/dtext/dtext.cpp"
	if ( (*( sm->p)) == 47 )
		goto st881;
	goto tr1884;
tr1883:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
	goto st1414;
st1414:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1414;
case 1414:
#line 26306 "ext/dtext/dtext.cpp"
	if ( (*( sm->p)) == 47 )
		goto st890;
	goto tr1884;
tr1083:
#line 629 "ext/dtext/dtext.cpp.rl"
	{{( sm->p) = ((( sm->te)))-1;}}
	goto st1415;
tr1093:
#line 580 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_close_block(sm, BLOCK_COLGROUP, "</colgroup>");
  }}
	goto st1415;
tr1101:
#line 623 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{
    if (dstack_close_block(sm, BLOCK_TABLE, "</table>")) {
      { sm->cs = ( (sm->stack.data()))[--( sm->top)];goto _again;}
    }
  }}
	goto st1415;
tr1105:
#line 601 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_close_block(sm, BLOCK_TBODY, "</tbody>");
  }}
	goto st1415;
tr1109:
#line 593 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_close_block(sm, BLOCK_THEAD, "</thead>");
  }}
	goto st1415;
tr1110:
#line 614 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_close_block(sm, BLOCK_TR, "</tr>");
  }}
	goto st1415;
tr1114:
#line 584 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_open_block(sm, BLOCK_COL, "col", sm->tag_attributes);
    dstack_pop(sm); // XXX [col] has no end tag
  }}
	goto st1415;
tr1129:
#line 86 "ext/dtext/dtext.cpp.rl"
	{ save_tag_attribute(sm, { sm->a1, sm->a2 }, { sm->b1, sm->b2 }); }
#line 584 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_open_block(sm, BLOCK_COL, "col", sm->tag_attributes);
    dstack_pop(sm); // XXX [col] has no end tag
  }}
	goto st1415;
tr1134:
#line 74 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
#line 86 "ext/dtext/dtext.cpp.rl"
	{ save_tag_attribute(sm, { sm->a1, sm->a2 }, { sm->b1, sm->b2 }); }
#line 584 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_open_block(sm, BLOCK_COL, "col", sm->tag_attributes);
    dstack_pop(sm); // XXX [col] has no end tag
  }}
	goto st1415;
tr1140:
#line 576 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_open_block(sm, BLOCK_COLGROUP, "colgroup", sm->tag_attributes);
  }}
	goto st1415;
tr1154:
#line 86 "ext/dtext/dtext.cpp.rl"
	{ save_tag_attribute(sm, { sm->a1, sm->a2 }, { sm->b1, sm->b2 }); }
#line 576 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_open_block(sm, BLOCK_COLGROUP, "colgroup", sm->tag_attributes);
  }}
	goto st1415;
tr1159:
#line 74 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
#line 86 "ext/dtext/dtext.cpp.rl"
	{ save_tag_attribute(sm, { sm->a1, sm->a2 }, { sm->b1, sm->b2 }); }
#line 576 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_open_block(sm, BLOCK_COLGROUP, "colgroup", sm->tag_attributes);
  }}
	goto st1415;
tr1168:
#line 597 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_open_block(sm, BLOCK_TBODY, "tbody", sm->tag_attributes);
  }}
	goto st1415;
tr1182:
#line 86 "ext/dtext/dtext.cpp.rl"
	{ save_tag_attribute(sm, { sm->a1, sm->a2 }, { sm->b1, sm->b2 }); }
#line 597 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_open_block(sm, BLOCK_TBODY, "tbody", sm->tag_attributes);
  }}
	goto st1415;
tr1187:
#line 74 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
#line 86 "ext/dtext/dtext.cpp.rl"
	{ save_tag_attribute(sm, { sm->a1, sm->a2 }, { sm->b1, sm->b2 }); }
#line 597 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_open_block(sm, BLOCK_TBODY, "tbody", sm->tag_attributes);
  }}
	goto st1415;
tr1189:
#line 618 "ext/dtext/dtext.cpp.rl"
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
{( (sm->stack.data()))[( sm->top)++] = 1415;goto st1146;}}
  }}
	goto st1415;
tr1203:
#line 86 "ext/dtext/dtext.cpp.rl"
	{ save_tag_attribute(sm, { sm->a1, sm->a2 }, { sm->b1, sm->b2 }); }
#line 618 "ext/dtext/dtext.cpp.rl"
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
{( (sm->stack.data()))[( sm->top)++] = 1415;goto st1146;}}
  }}
	goto st1415;
tr1208:
#line 74 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
#line 86 "ext/dtext/dtext.cpp.rl"
	{ save_tag_attribute(sm, { sm->a1, sm->a2 }, { sm->b1, sm->b2 }); }
#line 618 "ext/dtext/dtext.cpp.rl"
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
{( (sm->stack.data()))[( sm->top)++] = 1415;goto st1146;}}
  }}
	goto st1415;
tr1210:
#line 605 "ext/dtext/dtext.cpp.rl"
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
{( (sm->stack.data()))[( sm->top)++] = 1415;goto st1146;}}
  }}
	goto st1415;
tr1225:
#line 86 "ext/dtext/dtext.cpp.rl"
	{ save_tag_attribute(sm, { sm->a1, sm->a2 }, { sm->b1, sm->b2 }); }
#line 605 "ext/dtext/dtext.cpp.rl"
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
{( (sm->stack.data()))[( sm->top)++] = 1415;goto st1146;}}
  }}
	goto st1415;
tr1230:
#line 74 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
#line 86 "ext/dtext/dtext.cpp.rl"
	{ save_tag_attribute(sm, { sm->a1, sm->a2 }, { sm->b1, sm->b2 }); }
#line 605 "ext/dtext/dtext.cpp.rl"
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
{( (sm->stack.data()))[( sm->top)++] = 1415;goto st1146;}}
  }}
	goto st1415;
tr1234:
#line 589 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_open_block(sm, BLOCK_THEAD, "thead", sm->tag_attributes);
  }}
	goto st1415;
tr1248:
#line 86 "ext/dtext/dtext.cpp.rl"
	{ save_tag_attribute(sm, { sm->a1, sm->a2 }, { sm->b1, sm->b2 }); }
#line 589 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_open_block(sm, BLOCK_THEAD, "thead", sm->tag_attributes);
  }}
	goto st1415;
tr1253:
#line 74 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
#line 86 "ext/dtext/dtext.cpp.rl"
	{ save_tag_attribute(sm, { sm->a1, sm->a2 }, { sm->b1, sm->b2 }); }
#line 589 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_open_block(sm, BLOCK_THEAD, "thead", sm->tag_attributes);
  }}
	goto st1415;
tr1255:
#line 610 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_open_block(sm, BLOCK_TR, "tr", sm->tag_attributes);
  }}
	goto st1415;
tr1269:
#line 86 "ext/dtext/dtext.cpp.rl"
	{ save_tag_attribute(sm, { sm->a1, sm->a2 }, { sm->b1, sm->b2 }); }
#line 610 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_open_block(sm, BLOCK_TR, "tr", sm->tag_attributes);
  }}
	goto st1415;
tr1274:
#line 74 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
#line 86 "ext/dtext/dtext.cpp.rl"
	{ save_tag_attribute(sm, { sm->a1, sm->a2 }, { sm->b1, sm->b2 }); }
#line 610 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_open_block(sm, BLOCK_TR, "tr", sm->tag_attributes);
  }}
	goto st1415;
tr1886:
#line 629 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;}
	goto st1415;
tr1889:
#line 629 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;}
	goto st1415;
st1415:
#line 1 "NONE"
	{( sm->ts) = 0;}
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1415;
case 1415:
#line 1 "NONE"
	{( sm->ts) = ( sm->p);}
#line 26611 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 60: goto tr1887;
		case 91: goto tr1888;
	}
	goto tr1886;
tr1887:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
	goto st1416;
st1416:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1416;
case 1416:
#line 26625 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 47: goto st899;
		case 67: goto st922;
		case 84: goto st950;
		case 99: goto st922;
		case 116: goto st950;
	}
	goto tr1889;
st899:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof899;
case 899:
	switch( (*( sm->p)) ) {
		case 67: goto st900;
		case 84: goto st908;
		case 99: goto st900;
		case 116: goto st908;
	}
	goto tr1083;
st900:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof900;
case 900:
	switch( (*( sm->p)) ) {
		case 79: goto st901;
		case 111: goto st901;
	}
	goto tr1083;
st901:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof901;
case 901:
	switch( (*( sm->p)) ) {
		case 76: goto st902;
		case 108: goto st902;
	}
	goto tr1083;
st902:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof902;
case 902:
	switch( (*( sm->p)) ) {
		case 71: goto st903;
		case 103: goto st903;
	}
	goto tr1083;
st903:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof903;
case 903:
	switch( (*( sm->p)) ) {
		case 82: goto st904;
		case 114: goto st904;
	}
	goto tr1083;
st904:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof904;
case 904:
	switch( (*( sm->p)) ) {
		case 79: goto st905;
		case 111: goto st905;
	}
	goto tr1083;
st905:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof905;
case 905:
	switch( (*( sm->p)) ) {
		case 85: goto st906;
		case 117: goto st906;
	}
	goto tr1083;
st906:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof906;
case 906:
	switch( (*( sm->p)) ) {
		case 80: goto st907;
		case 112: goto st907;
	}
	goto tr1083;
st907:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof907;
case 907:
	if ( (*( sm->p)) == 62 )
		goto tr1093;
	goto tr1083;
st908:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof908;
case 908:
	switch( (*( sm->p)) ) {
		case 65: goto st909;
		case 66: goto st913;
		case 72: goto st917;
		case 82: goto st921;
		case 97: goto st909;
		case 98: goto st913;
		case 104: goto st917;
		case 114: goto st921;
	}
	goto tr1083;
st909:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof909;
case 909:
	switch( (*( sm->p)) ) {
		case 66: goto st910;
		case 98: goto st910;
	}
	goto tr1083;
st910:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof910;
case 910:
	switch( (*( sm->p)) ) {
		case 76: goto st911;
		case 108: goto st911;
	}
	goto tr1083;
st911:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof911;
case 911:
	switch( (*( sm->p)) ) {
		case 69: goto st912;
		case 101: goto st912;
	}
	goto tr1083;
st912:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof912;
case 912:
	if ( (*( sm->p)) == 62 )
		goto tr1101;
	goto tr1083;
st913:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof913;
case 913:
	switch( (*( sm->p)) ) {
		case 79: goto st914;
		case 111: goto st914;
	}
	goto tr1083;
st914:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof914;
case 914:
	switch( (*( sm->p)) ) {
		case 68: goto st915;
		case 100: goto st915;
	}
	goto tr1083;
st915:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof915;
case 915:
	switch( (*( sm->p)) ) {
		case 89: goto st916;
		case 121: goto st916;
	}
	goto tr1083;
st916:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof916;
case 916:
	if ( (*( sm->p)) == 62 )
		goto tr1105;
	goto tr1083;
st917:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof917;
case 917:
	switch( (*( sm->p)) ) {
		case 69: goto st918;
		case 101: goto st918;
	}
	goto tr1083;
st918:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof918;
case 918:
	switch( (*( sm->p)) ) {
		case 65: goto st919;
		case 97: goto st919;
	}
	goto tr1083;
st919:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof919;
case 919:
	switch( (*( sm->p)) ) {
		case 68: goto st920;
		case 100: goto st920;
	}
	goto tr1083;
st920:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof920;
case 920:
	if ( (*( sm->p)) == 62 )
		goto tr1109;
	goto tr1083;
st921:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof921;
case 921:
	if ( (*( sm->p)) == 62 )
		goto tr1110;
	goto tr1083;
st922:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof922;
case 922:
	switch( (*( sm->p)) ) {
		case 79: goto st923;
		case 111: goto st923;
	}
	goto tr1083;
st923:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof923;
case 923:
	switch( (*( sm->p)) ) {
		case 76: goto st924;
		case 108: goto st924;
	}
	goto tr1083;
st924:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof924;
case 924:
	switch( (*( sm->p)) ) {
		case 9: goto st925;
		case 32: goto st925;
		case 62: goto tr1114;
		case 71: goto st935;
		case 103: goto st935;
	}
	goto tr1083;
tr1128:
#line 86 "ext/dtext/dtext.cpp.rl"
	{ save_tag_attribute(sm, { sm->a1, sm->a2 }, { sm->b1, sm->b2 }); }
	goto st925;
tr1132:
#line 74 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
#line 86 "ext/dtext/dtext.cpp.rl"
	{ save_tag_attribute(sm, { sm->a1, sm->a2 }, { sm->b1, sm->b2 }); }
	goto st925;
st925:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof925;
case 925:
#line 26883 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto st925;
		case 32: goto st925;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1116;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1116;
	} else
		goto tr1116;
	goto tr1083;
tr1116:
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st926;
st926:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof926;
case 926:
#line 26905 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto tr1117;
		case 32: goto tr1117;
		case 61: goto tr1119;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st926;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st926;
	} else
		goto st926;
	goto tr1083;
tr1117:
#line 72 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
	goto st927;
st927:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof927;
case 927:
#line 26928 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto st927;
		case 32: goto st927;
		case 61: goto st928;
	}
	goto tr1083;
tr1119:
#line 72 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
	goto st928;
st928:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof928;
case 928:
#line 26943 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto st928;
		case 32: goto st928;
		case 34: goto st929;
		case 39: goto st932;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1124;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1124;
	} else
		goto tr1124;
	goto tr1083;
st929:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof929;
case 929:
	switch( (*( sm->p)) ) {
		case 0: goto tr1083;
		case 10: goto tr1083;
		case 13: goto tr1083;
	}
	goto tr1125;
tr1125:
#line 73 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st930;
st930:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof930;
case 930:
#line 26977 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr1083;
		case 10: goto tr1083;
		case 13: goto tr1083;
		case 34: goto tr1127;
	}
	goto st930;
tr1127:
#line 74 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
	goto st931;
st931:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof931;
case 931:
#line 26993 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto tr1128;
		case 32: goto tr1128;
		case 62: goto tr1129;
	}
	goto tr1083;
st932:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof932;
case 932:
	switch( (*( sm->p)) ) {
		case 0: goto tr1083;
		case 10: goto tr1083;
		case 13: goto tr1083;
	}
	goto tr1130;
tr1130:
#line 73 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st933;
st933:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof933;
case 933:
#line 27018 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr1083;
		case 10: goto tr1083;
		case 13: goto tr1083;
		case 39: goto tr1127;
	}
	goto st933;
tr1124:
#line 73 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st934;
st934:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof934;
case 934:
#line 27034 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto tr1132;
		case 32: goto tr1132;
		case 62: goto tr1134;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st934;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st934;
	} else
		goto st934;
	goto tr1083;
st935:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof935;
case 935:
	switch( (*( sm->p)) ) {
		case 82: goto st936;
		case 114: goto st936;
	}
	goto tr1083;
st936:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof936;
case 936:
	switch( (*( sm->p)) ) {
		case 79: goto st937;
		case 111: goto st937;
	}
	goto tr1083;
st937:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof937;
case 937:
	switch( (*( sm->p)) ) {
		case 85: goto st938;
		case 117: goto st938;
	}
	goto tr1083;
st938:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof938;
case 938:
	switch( (*( sm->p)) ) {
		case 80: goto st939;
		case 112: goto st939;
	}
	goto tr1083;
st939:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof939;
case 939:
	switch( (*( sm->p)) ) {
		case 9: goto st940;
		case 32: goto st940;
		case 62: goto tr1140;
	}
	goto tr1083;
tr1153:
#line 86 "ext/dtext/dtext.cpp.rl"
	{ save_tag_attribute(sm, { sm->a1, sm->a2 }, { sm->b1, sm->b2 }); }
	goto st940;
tr1157:
#line 74 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
#line 86 "ext/dtext/dtext.cpp.rl"
	{ save_tag_attribute(sm, { sm->a1, sm->a2 }, { sm->b1, sm->b2 }); }
	goto st940;
st940:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof940;
case 940:
#line 27109 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto st940;
		case 32: goto st940;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1141;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1141;
	} else
		goto tr1141;
	goto tr1083;
tr1141:
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st941;
st941:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof941;
case 941:
#line 27131 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto tr1142;
		case 32: goto tr1142;
		case 61: goto tr1144;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st941;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st941;
	} else
		goto st941;
	goto tr1083;
tr1142:
#line 72 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
	goto st942;
st942:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof942;
case 942:
#line 27154 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto st942;
		case 32: goto st942;
		case 61: goto st943;
	}
	goto tr1083;
tr1144:
#line 72 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
	goto st943;
st943:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof943;
case 943:
#line 27169 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto st943;
		case 32: goto st943;
		case 34: goto st944;
		case 39: goto st947;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1149;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1149;
	} else
		goto tr1149;
	goto tr1083;
st944:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof944;
case 944:
	switch( (*( sm->p)) ) {
		case 0: goto tr1083;
		case 10: goto tr1083;
		case 13: goto tr1083;
	}
	goto tr1150;
tr1150:
#line 73 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st945;
st945:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof945;
case 945:
#line 27203 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr1083;
		case 10: goto tr1083;
		case 13: goto tr1083;
		case 34: goto tr1152;
	}
	goto st945;
tr1152:
#line 74 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
	goto st946;
st946:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof946;
case 946:
#line 27219 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto tr1153;
		case 32: goto tr1153;
		case 62: goto tr1154;
	}
	goto tr1083;
st947:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof947;
case 947:
	switch( (*( sm->p)) ) {
		case 0: goto tr1083;
		case 10: goto tr1083;
		case 13: goto tr1083;
	}
	goto tr1155;
tr1155:
#line 73 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st948;
st948:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof948;
case 948:
#line 27244 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr1083;
		case 10: goto tr1083;
		case 13: goto tr1083;
		case 39: goto tr1152;
	}
	goto st948;
tr1149:
#line 73 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st949;
st949:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof949;
case 949:
#line 27260 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto tr1157;
		case 32: goto tr1157;
		case 62: goto tr1159;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st949;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st949;
	} else
		goto st949;
	goto tr1083;
st950:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof950;
case 950:
	switch( (*( sm->p)) ) {
		case 66: goto st951;
		case 68: goto st965;
		case 72: goto st976;
		case 82: goto st1000;
		case 98: goto st951;
		case 100: goto st965;
		case 104: goto st976;
		case 114: goto st1000;
	}
	goto tr1083;
st951:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof951;
case 951:
	switch( (*( sm->p)) ) {
		case 79: goto st952;
		case 111: goto st952;
	}
	goto tr1083;
st952:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof952;
case 952:
	switch( (*( sm->p)) ) {
		case 68: goto st953;
		case 100: goto st953;
	}
	goto tr1083;
st953:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof953;
case 953:
	switch( (*( sm->p)) ) {
		case 89: goto st954;
		case 121: goto st954;
	}
	goto tr1083;
st954:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof954;
case 954:
	switch( (*( sm->p)) ) {
		case 9: goto st955;
		case 32: goto st955;
		case 62: goto tr1168;
	}
	goto tr1083;
tr1181:
#line 86 "ext/dtext/dtext.cpp.rl"
	{ save_tag_attribute(sm, { sm->a1, sm->a2 }, { sm->b1, sm->b2 }); }
	goto st955;
tr1185:
#line 74 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
#line 86 "ext/dtext/dtext.cpp.rl"
	{ save_tag_attribute(sm, { sm->a1, sm->a2 }, { sm->b1, sm->b2 }); }
	goto st955;
st955:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof955;
case 955:
#line 27341 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto st955;
		case 32: goto st955;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1169;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1169;
	} else
		goto tr1169;
	goto tr1083;
tr1169:
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st956;
st956:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof956;
case 956:
#line 27363 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto tr1170;
		case 32: goto tr1170;
		case 61: goto tr1172;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st956;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st956;
	} else
		goto st956;
	goto tr1083;
tr1170:
#line 72 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
	goto st957;
st957:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof957;
case 957:
#line 27386 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto st957;
		case 32: goto st957;
		case 61: goto st958;
	}
	goto tr1083;
tr1172:
#line 72 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
	goto st958;
st958:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof958;
case 958:
#line 27401 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto st958;
		case 32: goto st958;
		case 34: goto st959;
		case 39: goto st962;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1177;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1177;
	} else
		goto tr1177;
	goto tr1083;
st959:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof959;
case 959:
	switch( (*( sm->p)) ) {
		case 0: goto tr1083;
		case 10: goto tr1083;
		case 13: goto tr1083;
	}
	goto tr1178;
tr1178:
#line 73 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st960;
st960:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof960;
case 960:
#line 27435 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr1083;
		case 10: goto tr1083;
		case 13: goto tr1083;
		case 34: goto tr1180;
	}
	goto st960;
tr1180:
#line 74 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
	goto st961;
st961:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof961;
case 961:
#line 27451 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto tr1181;
		case 32: goto tr1181;
		case 62: goto tr1182;
	}
	goto tr1083;
st962:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof962;
case 962:
	switch( (*( sm->p)) ) {
		case 0: goto tr1083;
		case 10: goto tr1083;
		case 13: goto tr1083;
	}
	goto tr1183;
tr1183:
#line 73 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st963;
st963:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof963;
case 963:
#line 27476 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr1083;
		case 10: goto tr1083;
		case 13: goto tr1083;
		case 39: goto tr1180;
	}
	goto st963;
tr1177:
#line 73 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st964;
st964:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof964;
case 964:
#line 27492 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto tr1185;
		case 32: goto tr1185;
		case 62: goto tr1187;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st964;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st964;
	} else
		goto st964;
	goto tr1083;
st965:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof965;
case 965:
	switch( (*( sm->p)) ) {
		case 9: goto st966;
		case 32: goto st966;
		case 62: goto tr1189;
	}
	goto tr1083;
tr1202:
#line 86 "ext/dtext/dtext.cpp.rl"
	{ save_tag_attribute(sm, { sm->a1, sm->a2 }, { sm->b1, sm->b2 }); }
	goto st966;
tr1206:
#line 74 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
#line 86 "ext/dtext/dtext.cpp.rl"
	{ save_tag_attribute(sm, { sm->a1, sm->a2 }, { sm->b1, sm->b2 }); }
	goto st966;
st966:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof966;
case 966:
#line 27531 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto st966;
		case 32: goto st966;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1190;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1190;
	} else
		goto tr1190;
	goto tr1083;
tr1190:
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st967;
st967:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof967;
case 967:
#line 27553 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto tr1191;
		case 32: goto tr1191;
		case 61: goto tr1193;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st967;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st967;
	} else
		goto st967;
	goto tr1083;
tr1191:
#line 72 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
	goto st968;
st968:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof968;
case 968:
#line 27576 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto st968;
		case 32: goto st968;
		case 61: goto st969;
	}
	goto tr1083;
tr1193:
#line 72 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
	goto st969;
st969:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof969;
case 969:
#line 27591 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto st969;
		case 32: goto st969;
		case 34: goto st970;
		case 39: goto st973;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1198;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1198;
	} else
		goto tr1198;
	goto tr1083;
st970:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof970;
case 970:
	switch( (*( sm->p)) ) {
		case 0: goto tr1083;
		case 10: goto tr1083;
		case 13: goto tr1083;
	}
	goto tr1199;
tr1199:
#line 73 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st971;
st971:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof971;
case 971:
#line 27625 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr1083;
		case 10: goto tr1083;
		case 13: goto tr1083;
		case 34: goto tr1201;
	}
	goto st971;
tr1201:
#line 74 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
	goto st972;
st972:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof972;
case 972:
#line 27641 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto tr1202;
		case 32: goto tr1202;
		case 62: goto tr1203;
	}
	goto tr1083;
st973:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof973;
case 973:
	switch( (*( sm->p)) ) {
		case 0: goto tr1083;
		case 10: goto tr1083;
		case 13: goto tr1083;
	}
	goto tr1204;
tr1204:
#line 73 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st974;
st974:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof974;
case 974:
#line 27666 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr1083;
		case 10: goto tr1083;
		case 13: goto tr1083;
		case 39: goto tr1201;
	}
	goto st974;
tr1198:
#line 73 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st975;
st975:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof975;
case 975:
#line 27682 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto tr1206;
		case 32: goto tr1206;
		case 62: goto tr1208;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st975;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st975;
	} else
		goto st975;
	goto tr1083;
st976:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof976;
case 976:
	switch( (*( sm->p)) ) {
		case 9: goto st977;
		case 32: goto st977;
		case 62: goto tr1210;
		case 69: goto st987;
		case 101: goto st987;
	}
	goto tr1083;
tr1224:
#line 86 "ext/dtext/dtext.cpp.rl"
	{ save_tag_attribute(sm, { sm->a1, sm->a2 }, { sm->b1, sm->b2 }); }
	goto st977;
tr1228:
#line 74 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
#line 86 "ext/dtext/dtext.cpp.rl"
	{ save_tag_attribute(sm, { sm->a1, sm->a2 }, { sm->b1, sm->b2 }); }
	goto st977;
st977:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof977;
case 977:
#line 27723 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto st977;
		case 32: goto st977;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1212;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1212;
	} else
		goto tr1212;
	goto tr1083;
tr1212:
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st978;
st978:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof978;
case 978:
#line 27745 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto tr1213;
		case 32: goto tr1213;
		case 61: goto tr1215;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st978;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st978;
	} else
		goto st978;
	goto tr1083;
tr1213:
#line 72 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
	goto st979;
st979:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof979;
case 979:
#line 27768 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto st979;
		case 32: goto st979;
		case 61: goto st980;
	}
	goto tr1083;
tr1215:
#line 72 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
	goto st980;
st980:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof980;
case 980:
#line 27783 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto st980;
		case 32: goto st980;
		case 34: goto st981;
		case 39: goto st984;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1220;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1220;
	} else
		goto tr1220;
	goto tr1083;
st981:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof981;
case 981:
	switch( (*( sm->p)) ) {
		case 0: goto tr1083;
		case 10: goto tr1083;
		case 13: goto tr1083;
	}
	goto tr1221;
tr1221:
#line 73 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st982;
st982:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof982;
case 982:
#line 27817 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr1083;
		case 10: goto tr1083;
		case 13: goto tr1083;
		case 34: goto tr1223;
	}
	goto st982;
tr1223:
#line 74 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
	goto st983;
st983:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof983;
case 983:
#line 27833 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto tr1224;
		case 32: goto tr1224;
		case 62: goto tr1225;
	}
	goto tr1083;
st984:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof984;
case 984:
	switch( (*( sm->p)) ) {
		case 0: goto tr1083;
		case 10: goto tr1083;
		case 13: goto tr1083;
	}
	goto tr1226;
tr1226:
#line 73 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st985;
st985:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof985;
case 985:
#line 27858 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr1083;
		case 10: goto tr1083;
		case 13: goto tr1083;
		case 39: goto tr1223;
	}
	goto st985;
tr1220:
#line 73 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st986;
st986:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof986;
case 986:
#line 27874 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto tr1228;
		case 32: goto tr1228;
		case 62: goto tr1230;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st986;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st986;
	} else
		goto st986;
	goto tr1083;
st987:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof987;
case 987:
	switch( (*( sm->p)) ) {
		case 65: goto st988;
		case 97: goto st988;
	}
	goto tr1083;
st988:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof988;
case 988:
	switch( (*( sm->p)) ) {
		case 68: goto st989;
		case 100: goto st989;
	}
	goto tr1083;
st989:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof989;
case 989:
	switch( (*( sm->p)) ) {
		case 9: goto st990;
		case 32: goto st990;
		case 62: goto tr1234;
	}
	goto tr1083;
tr1247:
#line 86 "ext/dtext/dtext.cpp.rl"
	{ save_tag_attribute(sm, { sm->a1, sm->a2 }, { sm->b1, sm->b2 }); }
	goto st990;
tr1251:
#line 74 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
#line 86 "ext/dtext/dtext.cpp.rl"
	{ save_tag_attribute(sm, { sm->a1, sm->a2 }, { sm->b1, sm->b2 }); }
	goto st990;
st990:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof990;
case 990:
#line 27931 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto st990;
		case 32: goto st990;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1235;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1235;
	} else
		goto tr1235;
	goto tr1083;
tr1235:
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st991;
st991:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof991;
case 991:
#line 27953 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto tr1236;
		case 32: goto tr1236;
		case 61: goto tr1238;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st991;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st991;
	} else
		goto st991;
	goto tr1083;
tr1236:
#line 72 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
	goto st992;
st992:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof992;
case 992:
#line 27976 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto st992;
		case 32: goto st992;
		case 61: goto st993;
	}
	goto tr1083;
tr1238:
#line 72 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
	goto st993;
st993:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof993;
case 993:
#line 27991 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto st993;
		case 32: goto st993;
		case 34: goto st994;
		case 39: goto st997;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1243;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1243;
	} else
		goto tr1243;
	goto tr1083;
st994:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof994;
case 994:
	switch( (*( sm->p)) ) {
		case 0: goto tr1083;
		case 10: goto tr1083;
		case 13: goto tr1083;
	}
	goto tr1244;
tr1244:
#line 73 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st995;
st995:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof995;
case 995:
#line 28025 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr1083;
		case 10: goto tr1083;
		case 13: goto tr1083;
		case 34: goto tr1246;
	}
	goto st995;
tr1246:
#line 74 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
	goto st996;
st996:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof996;
case 996:
#line 28041 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto tr1247;
		case 32: goto tr1247;
		case 62: goto tr1248;
	}
	goto tr1083;
st997:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof997;
case 997:
	switch( (*( sm->p)) ) {
		case 0: goto tr1083;
		case 10: goto tr1083;
		case 13: goto tr1083;
	}
	goto tr1249;
tr1249:
#line 73 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st998;
st998:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof998;
case 998:
#line 28066 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr1083;
		case 10: goto tr1083;
		case 13: goto tr1083;
		case 39: goto tr1246;
	}
	goto st998;
tr1243:
#line 73 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st999;
st999:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof999;
case 999:
#line 28082 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto tr1251;
		case 32: goto tr1251;
		case 62: goto tr1253;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st999;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st999;
	} else
		goto st999;
	goto tr1083;
st1000:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1000;
case 1000:
	switch( (*( sm->p)) ) {
		case 9: goto st1001;
		case 32: goto st1001;
		case 62: goto tr1255;
	}
	goto tr1083;
tr1268:
#line 86 "ext/dtext/dtext.cpp.rl"
	{ save_tag_attribute(sm, { sm->a1, sm->a2 }, { sm->b1, sm->b2 }); }
	goto st1001;
tr1272:
#line 74 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
#line 86 "ext/dtext/dtext.cpp.rl"
	{ save_tag_attribute(sm, { sm->a1, sm->a2 }, { sm->b1, sm->b2 }); }
	goto st1001;
st1001:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1001;
case 1001:
#line 28121 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto st1001;
		case 32: goto st1001;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1256;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1256;
	} else
		goto tr1256;
	goto tr1083;
tr1256:
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st1002;
st1002:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1002;
case 1002:
#line 28143 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto tr1257;
		case 32: goto tr1257;
		case 61: goto tr1259;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st1002;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st1002;
	} else
		goto st1002;
	goto tr1083;
tr1257:
#line 72 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
	goto st1003;
st1003:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1003;
case 1003:
#line 28166 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto st1003;
		case 32: goto st1003;
		case 61: goto st1004;
	}
	goto tr1083;
tr1259:
#line 72 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
	goto st1004;
st1004:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1004;
case 1004:
#line 28181 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto st1004;
		case 32: goto st1004;
		case 34: goto st1005;
		case 39: goto st1008;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1264;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1264;
	} else
		goto tr1264;
	goto tr1083;
st1005:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1005;
case 1005:
	switch( (*( sm->p)) ) {
		case 0: goto tr1083;
		case 10: goto tr1083;
		case 13: goto tr1083;
	}
	goto tr1265;
tr1265:
#line 73 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st1006;
st1006:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1006;
case 1006:
#line 28215 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr1083;
		case 10: goto tr1083;
		case 13: goto tr1083;
		case 34: goto tr1267;
	}
	goto st1006;
tr1267:
#line 74 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
	goto st1007;
st1007:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1007;
case 1007:
#line 28231 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto tr1268;
		case 32: goto tr1268;
		case 62: goto tr1269;
	}
	goto tr1083;
st1008:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1008;
case 1008:
	switch( (*( sm->p)) ) {
		case 0: goto tr1083;
		case 10: goto tr1083;
		case 13: goto tr1083;
	}
	goto tr1270;
tr1270:
#line 73 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st1009;
st1009:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1009;
case 1009:
#line 28256 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr1083;
		case 10: goto tr1083;
		case 13: goto tr1083;
		case 39: goto tr1267;
	}
	goto st1009;
tr1264:
#line 73 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st1010;
st1010:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1010;
case 1010:
#line 28272 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto tr1272;
		case 32: goto tr1272;
		case 62: goto tr1274;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st1010;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st1010;
	} else
		goto st1010;
	goto tr1083;
tr1888:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
	goto st1417;
st1417:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1417;
case 1417:
#line 28295 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 47: goto st1011;
		case 67: goto st1034;
		case 84: goto st1062;
		case 99: goto st1034;
		case 116: goto st1062;
	}
	goto tr1889;
st1011:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1011;
case 1011:
	switch( (*( sm->p)) ) {
		case 67: goto st1012;
		case 84: goto st1020;
		case 99: goto st1012;
		case 116: goto st1020;
	}
	goto tr1083;
st1012:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1012;
case 1012:
	switch( (*( sm->p)) ) {
		case 79: goto st1013;
		case 111: goto st1013;
	}
	goto tr1083;
st1013:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1013;
case 1013:
	switch( (*( sm->p)) ) {
		case 76: goto st1014;
		case 108: goto st1014;
	}
	goto tr1083;
st1014:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1014;
case 1014:
	switch( (*( sm->p)) ) {
		case 71: goto st1015;
		case 103: goto st1015;
	}
	goto tr1083;
st1015:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1015;
case 1015:
	switch( (*( sm->p)) ) {
		case 82: goto st1016;
		case 114: goto st1016;
	}
	goto tr1083;
st1016:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1016;
case 1016:
	switch( (*( sm->p)) ) {
		case 79: goto st1017;
		case 111: goto st1017;
	}
	goto tr1083;
st1017:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1017;
case 1017:
	switch( (*( sm->p)) ) {
		case 85: goto st1018;
		case 117: goto st1018;
	}
	goto tr1083;
st1018:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1018;
case 1018:
	switch( (*( sm->p)) ) {
		case 80: goto st1019;
		case 112: goto st1019;
	}
	goto tr1083;
st1019:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1019;
case 1019:
	if ( (*( sm->p)) == 93 )
		goto tr1093;
	goto tr1083;
st1020:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1020;
case 1020:
	switch( (*( sm->p)) ) {
		case 65: goto st1021;
		case 66: goto st1025;
		case 72: goto st1029;
		case 82: goto st1033;
		case 97: goto st1021;
		case 98: goto st1025;
		case 104: goto st1029;
		case 114: goto st1033;
	}
	goto tr1083;
st1021:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1021;
case 1021:
	switch( (*( sm->p)) ) {
		case 66: goto st1022;
		case 98: goto st1022;
	}
	goto tr1083;
st1022:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1022;
case 1022:
	switch( (*( sm->p)) ) {
		case 76: goto st1023;
		case 108: goto st1023;
	}
	goto tr1083;
st1023:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1023;
case 1023:
	switch( (*( sm->p)) ) {
		case 69: goto st1024;
		case 101: goto st1024;
	}
	goto tr1083;
st1024:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1024;
case 1024:
	if ( (*( sm->p)) == 93 )
		goto tr1101;
	goto tr1083;
st1025:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1025;
case 1025:
	switch( (*( sm->p)) ) {
		case 79: goto st1026;
		case 111: goto st1026;
	}
	goto tr1083;
st1026:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1026;
case 1026:
	switch( (*( sm->p)) ) {
		case 68: goto st1027;
		case 100: goto st1027;
	}
	goto tr1083;
st1027:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1027;
case 1027:
	switch( (*( sm->p)) ) {
		case 89: goto st1028;
		case 121: goto st1028;
	}
	goto tr1083;
st1028:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1028;
case 1028:
	if ( (*( sm->p)) == 93 )
		goto tr1105;
	goto tr1083;
st1029:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1029;
case 1029:
	switch( (*( sm->p)) ) {
		case 69: goto st1030;
		case 101: goto st1030;
	}
	goto tr1083;
st1030:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1030;
case 1030:
	switch( (*( sm->p)) ) {
		case 65: goto st1031;
		case 97: goto st1031;
	}
	goto tr1083;
st1031:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1031;
case 1031:
	switch( (*( sm->p)) ) {
		case 68: goto st1032;
		case 100: goto st1032;
	}
	goto tr1083;
st1032:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1032;
case 1032:
	if ( (*( sm->p)) == 93 )
		goto tr1109;
	goto tr1083;
st1033:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1033;
case 1033:
	if ( (*( sm->p)) == 93 )
		goto tr1110;
	goto tr1083;
st1034:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1034;
case 1034:
	switch( (*( sm->p)) ) {
		case 79: goto st1035;
		case 111: goto st1035;
	}
	goto tr1083;
st1035:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1035;
case 1035:
	switch( (*( sm->p)) ) {
		case 76: goto st1036;
		case 108: goto st1036;
	}
	goto tr1083;
st1036:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1036;
case 1036:
	switch( (*( sm->p)) ) {
		case 9: goto st1037;
		case 32: goto st1037;
		case 71: goto st1047;
		case 93: goto tr1114;
		case 103: goto st1047;
	}
	goto tr1083;
tr1313:
#line 86 "ext/dtext/dtext.cpp.rl"
	{ save_tag_attribute(sm, { sm->a1, sm->a2 }, { sm->b1, sm->b2 }); }
	goto st1037;
tr1316:
#line 74 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
#line 86 "ext/dtext/dtext.cpp.rl"
	{ save_tag_attribute(sm, { sm->a1, sm->a2 }, { sm->b1, sm->b2 }); }
	goto st1037;
st1037:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1037;
case 1037:
#line 28553 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto st1037;
		case 32: goto st1037;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1301;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1301;
	} else
		goto tr1301;
	goto tr1083;
tr1301:
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st1038;
st1038:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1038;
case 1038:
#line 28575 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto tr1302;
		case 32: goto tr1302;
		case 61: goto tr1304;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st1038;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st1038;
	} else
		goto st1038;
	goto tr1083;
tr1302:
#line 72 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
	goto st1039;
st1039:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1039;
case 1039:
#line 28598 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto st1039;
		case 32: goto st1039;
		case 61: goto st1040;
	}
	goto tr1083;
tr1304:
#line 72 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
	goto st1040;
st1040:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1040;
case 1040:
#line 28613 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto st1040;
		case 32: goto st1040;
		case 34: goto st1041;
		case 39: goto st1044;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1309;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1309;
	} else
		goto tr1309;
	goto tr1083;
st1041:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1041;
case 1041:
	switch( (*( sm->p)) ) {
		case 0: goto tr1083;
		case 10: goto tr1083;
		case 13: goto tr1083;
	}
	goto tr1310;
tr1310:
#line 73 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st1042;
st1042:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1042;
case 1042:
#line 28647 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr1083;
		case 10: goto tr1083;
		case 13: goto tr1083;
		case 34: goto tr1312;
	}
	goto st1042;
tr1312:
#line 74 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
	goto st1043;
st1043:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1043;
case 1043:
#line 28663 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto tr1313;
		case 32: goto tr1313;
		case 93: goto tr1129;
	}
	goto tr1083;
st1044:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1044;
case 1044:
	switch( (*( sm->p)) ) {
		case 0: goto tr1083;
		case 10: goto tr1083;
		case 13: goto tr1083;
	}
	goto tr1314;
tr1314:
#line 73 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st1045;
st1045:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1045;
case 1045:
#line 28688 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr1083;
		case 10: goto tr1083;
		case 13: goto tr1083;
		case 39: goto tr1312;
	}
	goto st1045;
tr1309:
#line 73 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st1046;
st1046:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1046;
case 1046:
#line 28704 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto tr1316;
		case 32: goto tr1316;
		case 93: goto tr1134;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st1046;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st1046;
	} else
		goto st1046;
	goto tr1083;
st1047:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1047;
case 1047:
	switch( (*( sm->p)) ) {
		case 82: goto st1048;
		case 114: goto st1048;
	}
	goto tr1083;
st1048:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1048;
case 1048:
	switch( (*( sm->p)) ) {
		case 79: goto st1049;
		case 111: goto st1049;
	}
	goto tr1083;
st1049:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1049;
case 1049:
	switch( (*( sm->p)) ) {
		case 85: goto st1050;
		case 117: goto st1050;
	}
	goto tr1083;
st1050:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1050;
case 1050:
	switch( (*( sm->p)) ) {
		case 80: goto st1051;
		case 112: goto st1051;
	}
	goto tr1083;
st1051:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1051;
case 1051:
	switch( (*( sm->p)) ) {
		case 9: goto st1052;
		case 32: goto st1052;
		case 93: goto tr1140;
	}
	goto tr1083;
tr1335:
#line 86 "ext/dtext/dtext.cpp.rl"
	{ save_tag_attribute(sm, { sm->a1, sm->a2 }, { sm->b1, sm->b2 }); }
	goto st1052;
tr1338:
#line 74 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
#line 86 "ext/dtext/dtext.cpp.rl"
	{ save_tag_attribute(sm, { sm->a1, sm->a2 }, { sm->b1, sm->b2 }); }
	goto st1052;
st1052:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1052;
case 1052:
#line 28779 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto st1052;
		case 32: goto st1052;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1323;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1323;
	} else
		goto tr1323;
	goto tr1083;
tr1323:
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st1053;
st1053:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1053;
case 1053:
#line 28801 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto tr1324;
		case 32: goto tr1324;
		case 61: goto tr1326;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st1053;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st1053;
	} else
		goto st1053;
	goto tr1083;
tr1324:
#line 72 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
	goto st1054;
st1054:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1054;
case 1054:
#line 28824 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto st1054;
		case 32: goto st1054;
		case 61: goto st1055;
	}
	goto tr1083;
tr1326:
#line 72 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
	goto st1055;
st1055:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1055;
case 1055:
#line 28839 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto st1055;
		case 32: goto st1055;
		case 34: goto st1056;
		case 39: goto st1059;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1331;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1331;
	} else
		goto tr1331;
	goto tr1083;
st1056:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1056;
case 1056:
	switch( (*( sm->p)) ) {
		case 0: goto tr1083;
		case 10: goto tr1083;
		case 13: goto tr1083;
	}
	goto tr1332;
tr1332:
#line 73 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st1057;
st1057:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1057;
case 1057:
#line 28873 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr1083;
		case 10: goto tr1083;
		case 13: goto tr1083;
		case 34: goto tr1334;
	}
	goto st1057;
tr1334:
#line 74 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
	goto st1058;
st1058:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1058;
case 1058:
#line 28889 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto tr1335;
		case 32: goto tr1335;
		case 93: goto tr1154;
	}
	goto tr1083;
st1059:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1059;
case 1059:
	switch( (*( sm->p)) ) {
		case 0: goto tr1083;
		case 10: goto tr1083;
		case 13: goto tr1083;
	}
	goto tr1336;
tr1336:
#line 73 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st1060;
st1060:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1060;
case 1060:
#line 28914 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr1083;
		case 10: goto tr1083;
		case 13: goto tr1083;
		case 39: goto tr1334;
	}
	goto st1060;
tr1331:
#line 73 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st1061;
st1061:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1061;
case 1061:
#line 28930 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto tr1338;
		case 32: goto tr1338;
		case 93: goto tr1159;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st1061;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st1061;
	} else
		goto st1061;
	goto tr1083;
st1062:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1062;
case 1062:
	switch( (*( sm->p)) ) {
		case 66: goto st1063;
		case 68: goto st1077;
		case 72: goto st1088;
		case 82: goto st1112;
		case 98: goto st1063;
		case 100: goto st1077;
		case 104: goto st1088;
		case 114: goto st1112;
	}
	goto tr1083;
st1063:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1063;
case 1063:
	switch( (*( sm->p)) ) {
		case 79: goto st1064;
		case 111: goto st1064;
	}
	goto tr1083;
st1064:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1064;
case 1064:
	switch( (*( sm->p)) ) {
		case 68: goto st1065;
		case 100: goto st1065;
	}
	goto tr1083;
st1065:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1065;
case 1065:
	switch( (*( sm->p)) ) {
		case 89: goto st1066;
		case 121: goto st1066;
	}
	goto tr1083;
st1066:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1066;
case 1066:
	switch( (*( sm->p)) ) {
		case 9: goto st1067;
		case 32: goto st1067;
		case 93: goto tr1168;
	}
	goto tr1083;
tr1360:
#line 86 "ext/dtext/dtext.cpp.rl"
	{ save_tag_attribute(sm, { sm->a1, sm->a2 }, { sm->b1, sm->b2 }); }
	goto st1067;
tr1363:
#line 74 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
#line 86 "ext/dtext/dtext.cpp.rl"
	{ save_tag_attribute(sm, { sm->a1, sm->a2 }, { sm->b1, sm->b2 }); }
	goto st1067;
st1067:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1067;
case 1067:
#line 29011 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto st1067;
		case 32: goto st1067;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1348;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1348;
	} else
		goto tr1348;
	goto tr1083;
tr1348:
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st1068;
st1068:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1068;
case 1068:
#line 29033 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto tr1349;
		case 32: goto tr1349;
		case 61: goto tr1351;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st1068;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st1068;
	} else
		goto st1068;
	goto tr1083;
tr1349:
#line 72 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
	goto st1069;
st1069:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1069;
case 1069:
#line 29056 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto st1069;
		case 32: goto st1069;
		case 61: goto st1070;
	}
	goto tr1083;
tr1351:
#line 72 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
	goto st1070;
st1070:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1070;
case 1070:
#line 29071 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto st1070;
		case 32: goto st1070;
		case 34: goto st1071;
		case 39: goto st1074;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1356;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1356;
	} else
		goto tr1356;
	goto tr1083;
st1071:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1071;
case 1071:
	switch( (*( sm->p)) ) {
		case 0: goto tr1083;
		case 10: goto tr1083;
		case 13: goto tr1083;
	}
	goto tr1357;
tr1357:
#line 73 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st1072;
st1072:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1072;
case 1072:
#line 29105 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr1083;
		case 10: goto tr1083;
		case 13: goto tr1083;
		case 34: goto tr1359;
	}
	goto st1072;
tr1359:
#line 74 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
	goto st1073;
st1073:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1073;
case 1073:
#line 29121 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto tr1360;
		case 32: goto tr1360;
		case 93: goto tr1182;
	}
	goto tr1083;
st1074:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1074;
case 1074:
	switch( (*( sm->p)) ) {
		case 0: goto tr1083;
		case 10: goto tr1083;
		case 13: goto tr1083;
	}
	goto tr1361;
tr1361:
#line 73 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st1075;
st1075:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1075;
case 1075:
#line 29146 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr1083;
		case 10: goto tr1083;
		case 13: goto tr1083;
		case 39: goto tr1359;
	}
	goto st1075;
tr1356:
#line 73 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st1076;
st1076:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1076;
case 1076:
#line 29162 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto tr1363;
		case 32: goto tr1363;
		case 93: goto tr1187;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st1076;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st1076;
	} else
		goto st1076;
	goto tr1083;
st1077:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1077;
case 1077:
	switch( (*( sm->p)) ) {
		case 9: goto st1078;
		case 32: goto st1078;
		case 93: goto tr1189;
	}
	goto tr1083;
tr1378:
#line 86 "ext/dtext/dtext.cpp.rl"
	{ save_tag_attribute(sm, { sm->a1, sm->a2 }, { sm->b1, sm->b2 }); }
	goto st1078;
tr1381:
#line 74 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
#line 86 "ext/dtext/dtext.cpp.rl"
	{ save_tag_attribute(sm, { sm->a1, sm->a2 }, { sm->b1, sm->b2 }); }
	goto st1078;
st1078:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1078;
case 1078:
#line 29201 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto st1078;
		case 32: goto st1078;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1366;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1366;
	} else
		goto tr1366;
	goto tr1083;
tr1366:
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st1079;
st1079:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1079;
case 1079:
#line 29223 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto tr1367;
		case 32: goto tr1367;
		case 61: goto tr1369;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st1079;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st1079;
	} else
		goto st1079;
	goto tr1083;
tr1367:
#line 72 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
	goto st1080;
st1080:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1080;
case 1080:
#line 29246 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto st1080;
		case 32: goto st1080;
		case 61: goto st1081;
	}
	goto tr1083;
tr1369:
#line 72 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
	goto st1081;
st1081:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1081;
case 1081:
#line 29261 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto st1081;
		case 32: goto st1081;
		case 34: goto st1082;
		case 39: goto st1085;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1374;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1374;
	} else
		goto tr1374;
	goto tr1083;
st1082:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1082;
case 1082:
	switch( (*( sm->p)) ) {
		case 0: goto tr1083;
		case 10: goto tr1083;
		case 13: goto tr1083;
	}
	goto tr1375;
tr1375:
#line 73 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st1083;
st1083:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1083;
case 1083:
#line 29295 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr1083;
		case 10: goto tr1083;
		case 13: goto tr1083;
		case 34: goto tr1377;
	}
	goto st1083;
tr1377:
#line 74 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
	goto st1084;
st1084:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1084;
case 1084:
#line 29311 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto tr1378;
		case 32: goto tr1378;
		case 93: goto tr1203;
	}
	goto tr1083;
st1085:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1085;
case 1085:
	switch( (*( sm->p)) ) {
		case 0: goto tr1083;
		case 10: goto tr1083;
		case 13: goto tr1083;
	}
	goto tr1379;
tr1379:
#line 73 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st1086;
st1086:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1086;
case 1086:
#line 29336 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr1083;
		case 10: goto tr1083;
		case 13: goto tr1083;
		case 39: goto tr1377;
	}
	goto st1086;
tr1374:
#line 73 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st1087;
st1087:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1087;
case 1087:
#line 29352 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto tr1381;
		case 32: goto tr1381;
		case 93: goto tr1208;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st1087;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st1087;
	} else
		goto st1087;
	goto tr1083;
st1088:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1088;
case 1088:
	switch( (*( sm->p)) ) {
		case 9: goto st1089;
		case 32: goto st1089;
		case 69: goto st1099;
		case 93: goto tr1210;
		case 101: goto st1099;
	}
	goto tr1083;
tr1397:
#line 86 "ext/dtext/dtext.cpp.rl"
	{ save_tag_attribute(sm, { sm->a1, sm->a2 }, { sm->b1, sm->b2 }); }
	goto st1089;
tr1400:
#line 74 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
#line 86 "ext/dtext/dtext.cpp.rl"
	{ save_tag_attribute(sm, { sm->a1, sm->a2 }, { sm->b1, sm->b2 }); }
	goto st1089;
st1089:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1089;
case 1089:
#line 29393 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto st1089;
		case 32: goto st1089;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1385;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1385;
	} else
		goto tr1385;
	goto tr1083;
tr1385:
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st1090;
st1090:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1090;
case 1090:
#line 29415 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto tr1386;
		case 32: goto tr1386;
		case 61: goto tr1388;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st1090;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st1090;
	} else
		goto st1090;
	goto tr1083;
tr1386:
#line 72 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
	goto st1091;
st1091:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1091;
case 1091:
#line 29438 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto st1091;
		case 32: goto st1091;
		case 61: goto st1092;
	}
	goto tr1083;
tr1388:
#line 72 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
	goto st1092;
st1092:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1092;
case 1092:
#line 29453 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto st1092;
		case 32: goto st1092;
		case 34: goto st1093;
		case 39: goto st1096;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1393;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1393;
	} else
		goto tr1393;
	goto tr1083;
st1093:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1093;
case 1093:
	switch( (*( sm->p)) ) {
		case 0: goto tr1083;
		case 10: goto tr1083;
		case 13: goto tr1083;
	}
	goto tr1394;
tr1394:
#line 73 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st1094;
st1094:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1094;
case 1094:
#line 29487 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr1083;
		case 10: goto tr1083;
		case 13: goto tr1083;
		case 34: goto tr1396;
	}
	goto st1094;
tr1396:
#line 74 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
	goto st1095;
st1095:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1095;
case 1095:
#line 29503 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto tr1397;
		case 32: goto tr1397;
		case 93: goto tr1225;
	}
	goto tr1083;
st1096:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1096;
case 1096:
	switch( (*( sm->p)) ) {
		case 0: goto tr1083;
		case 10: goto tr1083;
		case 13: goto tr1083;
	}
	goto tr1398;
tr1398:
#line 73 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st1097;
st1097:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1097;
case 1097:
#line 29528 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr1083;
		case 10: goto tr1083;
		case 13: goto tr1083;
		case 39: goto tr1396;
	}
	goto st1097;
tr1393:
#line 73 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st1098;
st1098:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1098;
case 1098:
#line 29544 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto tr1400;
		case 32: goto tr1400;
		case 93: goto tr1230;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st1098;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st1098;
	} else
		goto st1098;
	goto tr1083;
st1099:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1099;
case 1099:
	switch( (*( sm->p)) ) {
		case 65: goto st1100;
		case 97: goto st1100;
	}
	goto tr1083;
st1100:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1100;
case 1100:
	switch( (*( sm->p)) ) {
		case 68: goto st1101;
		case 100: goto st1101;
	}
	goto tr1083;
st1101:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1101;
case 1101:
	switch( (*( sm->p)) ) {
		case 9: goto st1102;
		case 32: goto st1102;
		case 93: goto tr1234;
	}
	goto tr1083;
tr1417:
#line 86 "ext/dtext/dtext.cpp.rl"
	{ save_tag_attribute(sm, { sm->a1, sm->a2 }, { sm->b1, sm->b2 }); }
	goto st1102;
tr1420:
#line 74 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
#line 86 "ext/dtext/dtext.cpp.rl"
	{ save_tag_attribute(sm, { sm->a1, sm->a2 }, { sm->b1, sm->b2 }); }
	goto st1102;
st1102:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1102;
case 1102:
#line 29601 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto st1102;
		case 32: goto st1102;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1405;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1405;
	} else
		goto tr1405;
	goto tr1083;
tr1405:
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st1103;
st1103:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1103;
case 1103:
#line 29623 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto tr1406;
		case 32: goto tr1406;
		case 61: goto tr1408;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st1103;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st1103;
	} else
		goto st1103;
	goto tr1083;
tr1406:
#line 72 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
	goto st1104;
st1104:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1104;
case 1104:
#line 29646 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto st1104;
		case 32: goto st1104;
		case 61: goto st1105;
	}
	goto tr1083;
tr1408:
#line 72 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
	goto st1105;
st1105:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1105;
case 1105:
#line 29661 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto st1105;
		case 32: goto st1105;
		case 34: goto st1106;
		case 39: goto st1109;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1413;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1413;
	} else
		goto tr1413;
	goto tr1083;
st1106:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1106;
case 1106:
	switch( (*( sm->p)) ) {
		case 0: goto tr1083;
		case 10: goto tr1083;
		case 13: goto tr1083;
	}
	goto tr1414;
tr1414:
#line 73 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st1107;
st1107:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1107;
case 1107:
#line 29695 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr1083;
		case 10: goto tr1083;
		case 13: goto tr1083;
		case 34: goto tr1416;
	}
	goto st1107;
tr1416:
#line 74 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
	goto st1108;
st1108:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1108;
case 1108:
#line 29711 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto tr1417;
		case 32: goto tr1417;
		case 93: goto tr1248;
	}
	goto tr1083;
st1109:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1109;
case 1109:
	switch( (*( sm->p)) ) {
		case 0: goto tr1083;
		case 10: goto tr1083;
		case 13: goto tr1083;
	}
	goto tr1418;
tr1418:
#line 73 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st1110;
st1110:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1110;
case 1110:
#line 29736 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr1083;
		case 10: goto tr1083;
		case 13: goto tr1083;
		case 39: goto tr1416;
	}
	goto st1110;
tr1413:
#line 73 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st1111;
st1111:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1111;
case 1111:
#line 29752 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto tr1420;
		case 32: goto tr1420;
		case 93: goto tr1253;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st1111;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st1111;
	} else
		goto st1111;
	goto tr1083;
st1112:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1112;
case 1112:
	switch( (*( sm->p)) ) {
		case 9: goto st1113;
		case 32: goto st1113;
		case 93: goto tr1255;
	}
	goto tr1083;
tr1435:
#line 86 "ext/dtext/dtext.cpp.rl"
	{ save_tag_attribute(sm, { sm->a1, sm->a2 }, { sm->b1, sm->b2 }); }
	goto st1113;
tr1438:
#line 74 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
#line 86 "ext/dtext/dtext.cpp.rl"
	{ save_tag_attribute(sm, { sm->a1, sm->a2 }, { sm->b1, sm->b2 }); }
	goto st1113;
st1113:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1113;
case 1113:
#line 29791 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto st1113;
		case 32: goto st1113;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1423;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1423;
	} else
		goto tr1423;
	goto tr1083;
tr1423:
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st1114;
st1114:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1114;
case 1114:
#line 29813 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto tr1424;
		case 32: goto tr1424;
		case 61: goto tr1426;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st1114;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st1114;
	} else
		goto st1114;
	goto tr1083;
tr1424:
#line 72 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
	goto st1115;
st1115:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1115;
case 1115:
#line 29836 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto st1115;
		case 32: goto st1115;
		case 61: goto st1116;
	}
	goto tr1083;
tr1426:
#line 72 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
	goto st1116;
st1116:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1116;
case 1116:
#line 29851 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto st1116;
		case 32: goto st1116;
		case 34: goto st1117;
		case 39: goto st1120;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1431;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1431;
	} else
		goto tr1431;
	goto tr1083;
st1117:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1117;
case 1117:
	switch( (*( sm->p)) ) {
		case 0: goto tr1083;
		case 10: goto tr1083;
		case 13: goto tr1083;
	}
	goto tr1432;
tr1432:
#line 73 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st1118;
st1118:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1118;
case 1118:
#line 29885 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr1083;
		case 10: goto tr1083;
		case 13: goto tr1083;
		case 34: goto tr1434;
	}
	goto st1118;
tr1434:
#line 74 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
	goto st1119;
st1119:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1119;
case 1119:
#line 29901 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto tr1435;
		case 32: goto tr1435;
		case 93: goto tr1269;
	}
	goto tr1083;
st1120:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1120;
case 1120:
	switch( (*( sm->p)) ) {
		case 0: goto tr1083;
		case 10: goto tr1083;
		case 13: goto tr1083;
	}
	goto tr1436;
tr1436:
#line 73 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st1121;
st1121:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1121;
case 1121:
#line 29926 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr1083;
		case 10: goto tr1083;
		case 13: goto tr1083;
		case 39: goto tr1434;
	}
	goto st1121;
tr1431:
#line 73 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st1122;
st1122:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1122;
case 1122:
#line 29942 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto tr1438;
		case 32: goto tr1438;
		case 93: goto tr1274;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st1122;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st1122;
	} else
		goto st1122;
	goto tr1083;
	}
	_test_eof1123:  sm->cs = 1123; goto _test_eof; 
	_test_eof1124:  sm->cs = 1124; goto _test_eof; 
	_test_eof1:  sm->cs = 1; goto _test_eof; 
	_test_eof2:  sm->cs = 2; goto _test_eof; 
	_test_eof1125:  sm->cs = 1125; goto _test_eof; 
	_test_eof3:  sm->cs = 3; goto _test_eof; 
	_test_eof4:  sm->cs = 4; goto _test_eof; 
	_test_eof5:  sm->cs = 5; goto _test_eof; 
	_test_eof6:  sm->cs = 6; goto _test_eof; 
	_test_eof7:  sm->cs = 7; goto _test_eof; 
	_test_eof8:  sm->cs = 8; goto _test_eof; 
	_test_eof1126:  sm->cs = 1126; goto _test_eof; 
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
	_test_eof1127:  sm->cs = 1127; goto _test_eof; 
	_test_eof1128:  sm->cs = 1128; goto _test_eof; 
	_test_eof23:  sm->cs = 23; goto _test_eof; 
	_test_eof1129:  sm->cs = 1129; goto _test_eof; 
	_test_eof1130:  sm->cs = 1130; goto _test_eof; 
	_test_eof24:  sm->cs = 24; goto _test_eof; 
	_test_eof1131:  sm->cs = 1131; goto _test_eof; 
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
	_test_eof1132:  sm->cs = 1132; goto _test_eof; 
	_test_eof35:  sm->cs = 35; goto _test_eof; 
	_test_eof36:  sm->cs = 36; goto _test_eof; 
	_test_eof37:  sm->cs = 37; goto _test_eof; 
	_test_eof38:  sm->cs = 38; goto _test_eof; 
	_test_eof39:  sm->cs = 39; goto _test_eof; 
	_test_eof40:  sm->cs = 40; goto _test_eof; 
	_test_eof41:  sm->cs = 41; goto _test_eof; 
	_test_eof1133:  sm->cs = 1133; goto _test_eof; 
	_test_eof42:  sm->cs = 42; goto _test_eof; 
	_test_eof43:  sm->cs = 43; goto _test_eof; 
	_test_eof1134:  sm->cs = 1134; goto _test_eof; 
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
	_test_eof1135:  sm->cs = 1135; goto _test_eof; 
	_test_eof54:  sm->cs = 54; goto _test_eof; 
	_test_eof1136:  sm->cs = 1136; goto _test_eof; 
	_test_eof55:  sm->cs = 55; goto _test_eof; 
	_test_eof56:  sm->cs = 56; goto _test_eof; 
	_test_eof57:  sm->cs = 57; goto _test_eof; 
	_test_eof58:  sm->cs = 58; goto _test_eof; 
	_test_eof59:  sm->cs = 59; goto _test_eof; 
	_test_eof60:  sm->cs = 60; goto _test_eof; 
	_test_eof61:  sm->cs = 61; goto _test_eof; 
	_test_eof1137:  sm->cs = 1137; goto _test_eof; 
	_test_eof62:  sm->cs = 62; goto _test_eof; 
	_test_eof63:  sm->cs = 63; goto _test_eof; 
	_test_eof64:  sm->cs = 64; goto _test_eof; 
	_test_eof65:  sm->cs = 65; goto _test_eof; 
	_test_eof66:  sm->cs = 66; goto _test_eof; 
	_test_eof67:  sm->cs = 67; goto _test_eof; 
	_test_eof68:  sm->cs = 68; goto _test_eof; 
	_test_eof69:  sm->cs = 69; goto _test_eof; 
	_test_eof70:  sm->cs = 70; goto _test_eof; 
	_test_eof1138:  sm->cs = 1138; goto _test_eof; 
	_test_eof71:  sm->cs = 71; goto _test_eof; 
	_test_eof72:  sm->cs = 72; goto _test_eof; 
	_test_eof73:  sm->cs = 73; goto _test_eof; 
	_test_eof1139:  sm->cs = 1139; goto _test_eof; 
	_test_eof74:  sm->cs = 74; goto _test_eof; 
	_test_eof75:  sm->cs = 75; goto _test_eof; 
	_test_eof76:  sm->cs = 76; goto _test_eof; 
	_test_eof1140:  sm->cs = 1140; goto _test_eof; 
	_test_eof1141:  sm->cs = 1141; goto _test_eof; 
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
	_test_eof1142:  sm->cs = 1142; goto _test_eof; 
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
	_test_eof1143:  sm->cs = 1143; goto _test_eof; 
	_test_eof1144:  sm->cs = 1144; goto _test_eof; 
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
	_test_eof1145:  sm->cs = 1145; goto _test_eof; 
	_test_eof146:  sm->cs = 146; goto _test_eof; 
	_test_eof147:  sm->cs = 147; goto _test_eof; 
	_test_eof148:  sm->cs = 148; goto _test_eof; 
	_test_eof149:  sm->cs = 149; goto _test_eof; 
	_test_eof150:  sm->cs = 150; goto _test_eof; 
	_test_eof151:  sm->cs = 151; goto _test_eof; 
	_test_eof152:  sm->cs = 152; goto _test_eof; 
	_test_eof153:  sm->cs = 153; goto _test_eof; 
	_test_eof154:  sm->cs = 154; goto _test_eof; 
	_test_eof1146:  sm->cs = 1146; goto _test_eof; 
	_test_eof1147:  sm->cs = 1147; goto _test_eof; 
	_test_eof1148:  sm->cs = 1148; goto _test_eof; 
	_test_eof155:  sm->cs = 155; goto _test_eof; 
	_test_eof156:  sm->cs = 156; goto _test_eof; 
	_test_eof157:  sm->cs = 157; goto _test_eof; 
	_test_eof1149:  sm->cs = 1149; goto _test_eof; 
	_test_eof1150:  sm->cs = 1150; goto _test_eof; 
	_test_eof1151:  sm->cs = 1151; goto _test_eof; 
	_test_eof158:  sm->cs = 158; goto _test_eof; 
	_test_eof159:  sm->cs = 159; goto _test_eof; 
	_test_eof1152:  sm->cs = 1152; goto _test_eof; 
	_test_eof160:  sm->cs = 160; goto _test_eof; 
	_test_eof161:  sm->cs = 161; goto _test_eof; 
	_test_eof1153:  sm->cs = 1153; goto _test_eof; 
	_test_eof162:  sm->cs = 162; goto _test_eof; 
	_test_eof163:  sm->cs = 163; goto _test_eof; 
	_test_eof164:  sm->cs = 164; goto _test_eof; 
	_test_eof165:  sm->cs = 165; goto _test_eof; 
	_test_eof166:  sm->cs = 166; goto _test_eof; 
	_test_eof1154:  sm->cs = 1154; goto _test_eof; 
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
	_test_eof1155:  sm->cs = 1155; goto _test_eof; 
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
	_test_eof1156:  sm->cs = 1156; goto _test_eof; 
	_test_eof1157:  sm->cs = 1157; goto _test_eof; 
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
	_test_eof1158:  sm->cs = 1158; goto _test_eof; 
	_test_eof226:  sm->cs = 226; goto _test_eof; 
	_test_eof227:  sm->cs = 227; goto _test_eof; 
	_test_eof228:  sm->cs = 228; goto _test_eof; 
	_test_eof229:  sm->cs = 229; goto _test_eof; 
	_test_eof230:  sm->cs = 230; goto _test_eof; 
	_test_eof231:  sm->cs = 231; goto _test_eof; 
	_test_eof1159:  sm->cs = 1159; goto _test_eof; 
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
	_test_eof1160:  sm->cs = 1160; goto _test_eof; 
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
	_test_eof1161:  sm->cs = 1161; goto _test_eof; 
	_test_eof1162:  sm->cs = 1162; goto _test_eof; 
	_test_eof306:  sm->cs = 306; goto _test_eof; 
	_test_eof307:  sm->cs = 307; goto _test_eof; 
	_test_eof308:  sm->cs = 308; goto _test_eof; 
	_test_eof1163:  sm->cs = 1163; goto _test_eof; 
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
	_test_eof1164:  sm->cs = 1164; goto _test_eof; 
	_test_eof320:  sm->cs = 320; goto _test_eof; 
	_test_eof321:  sm->cs = 321; goto _test_eof; 
	_test_eof322:  sm->cs = 322; goto _test_eof; 
	_test_eof323:  sm->cs = 323; goto _test_eof; 
	_test_eof324:  sm->cs = 324; goto _test_eof; 
	_test_eof325:  sm->cs = 325; goto _test_eof; 
	_test_eof326:  sm->cs = 326; goto _test_eof; 
	_test_eof327:  sm->cs = 327; goto _test_eof; 
	_test_eof328:  sm->cs = 328; goto _test_eof; 
	_test_eof329:  sm->cs = 329; goto _test_eof; 
	_test_eof330:  sm->cs = 330; goto _test_eof; 
	_test_eof331:  sm->cs = 331; goto _test_eof; 
	_test_eof332:  sm->cs = 332; goto _test_eof; 
	_test_eof1165:  sm->cs = 1165; goto _test_eof; 
	_test_eof333:  sm->cs = 333; goto _test_eof; 
	_test_eof334:  sm->cs = 334; goto _test_eof; 
	_test_eof335:  sm->cs = 335; goto _test_eof; 
	_test_eof336:  sm->cs = 336; goto _test_eof; 
	_test_eof337:  sm->cs = 337; goto _test_eof; 
	_test_eof338:  sm->cs = 338; goto _test_eof; 
	_test_eof339:  sm->cs = 339; goto _test_eof; 
	_test_eof340:  sm->cs = 340; goto _test_eof; 
	_test_eof341:  sm->cs = 341; goto _test_eof; 
	_test_eof342:  sm->cs = 342; goto _test_eof; 
	_test_eof343:  sm->cs = 343; goto _test_eof; 
	_test_eof344:  sm->cs = 344; goto _test_eof; 
	_test_eof345:  sm->cs = 345; goto _test_eof; 
	_test_eof346:  sm->cs = 346; goto _test_eof; 
	_test_eof347:  sm->cs = 347; goto _test_eof; 
	_test_eof348:  sm->cs = 348; goto _test_eof; 
	_test_eof349:  sm->cs = 349; goto _test_eof; 
	_test_eof350:  sm->cs = 350; goto _test_eof; 
	_test_eof351:  sm->cs = 351; goto _test_eof; 
	_test_eof352:  sm->cs = 352; goto _test_eof; 
	_test_eof353:  sm->cs = 353; goto _test_eof; 
	_test_eof354:  sm->cs = 354; goto _test_eof; 
	_test_eof1166:  sm->cs = 1166; goto _test_eof; 
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
	_test_eof1167:  sm->cs = 1167; goto _test_eof; 
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
	_test_eof1168:  sm->cs = 1168; goto _test_eof; 
	_test_eof377:  sm->cs = 377; goto _test_eof; 
	_test_eof378:  sm->cs = 378; goto _test_eof; 
	_test_eof379:  sm->cs = 379; goto _test_eof; 
	_test_eof380:  sm->cs = 380; goto _test_eof; 
	_test_eof381:  sm->cs = 381; goto _test_eof; 
	_test_eof382:  sm->cs = 382; goto _test_eof; 
	_test_eof383:  sm->cs = 383; goto _test_eof; 
	_test_eof384:  sm->cs = 384; goto _test_eof; 
	_test_eof385:  sm->cs = 385; goto _test_eof; 
	_test_eof1169:  sm->cs = 1169; goto _test_eof; 
	_test_eof1170:  sm->cs = 1170; goto _test_eof; 
	_test_eof386:  sm->cs = 386; goto _test_eof; 
	_test_eof387:  sm->cs = 387; goto _test_eof; 
	_test_eof388:  sm->cs = 388; goto _test_eof; 
	_test_eof389:  sm->cs = 389; goto _test_eof; 
	_test_eof1171:  sm->cs = 1171; goto _test_eof; 
	_test_eof1172:  sm->cs = 1172; goto _test_eof; 
	_test_eof390:  sm->cs = 390; goto _test_eof; 
	_test_eof391:  sm->cs = 391; goto _test_eof; 
	_test_eof392:  sm->cs = 392; goto _test_eof; 
	_test_eof393:  sm->cs = 393; goto _test_eof; 
	_test_eof394:  sm->cs = 394; goto _test_eof; 
	_test_eof395:  sm->cs = 395; goto _test_eof; 
	_test_eof396:  sm->cs = 396; goto _test_eof; 
	_test_eof397:  sm->cs = 397; goto _test_eof; 
	_test_eof398:  sm->cs = 398; goto _test_eof; 
	_test_eof1173:  sm->cs = 1173; goto _test_eof; 
	_test_eof1174:  sm->cs = 1174; goto _test_eof; 
	_test_eof399:  sm->cs = 399; goto _test_eof; 
	_test_eof400:  sm->cs = 400; goto _test_eof; 
	_test_eof401:  sm->cs = 401; goto _test_eof; 
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
	_test_eof420:  sm->cs = 420; goto _test_eof; 
	_test_eof421:  sm->cs = 421; goto _test_eof; 
	_test_eof422:  sm->cs = 422; goto _test_eof; 
	_test_eof423:  sm->cs = 423; goto _test_eof; 
	_test_eof424:  sm->cs = 424; goto _test_eof; 
	_test_eof425:  sm->cs = 425; goto _test_eof; 
	_test_eof426:  sm->cs = 426; goto _test_eof; 
	_test_eof427:  sm->cs = 427; goto _test_eof; 
	_test_eof428:  sm->cs = 428; goto _test_eof; 
	_test_eof429:  sm->cs = 429; goto _test_eof; 
	_test_eof430:  sm->cs = 430; goto _test_eof; 
	_test_eof431:  sm->cs = 431; goto _test_eof; 
	_test_eof432:  sm->cs = 432; goto _test_eof; 
	_test_eof433:  sm->cs = 433; goto _test_eof; 
	_test_eof434:  sm->cs = 434; goto _test_eof; 
	_test_eof435:  sm->cs = 435; goto _test_eof; 
	_test_eof436:  sm->cs = 436; goto _test_eof; 
	_test_eof437:  sm->cs = 437; goto _test_eof; 
	_test_eof438:  sm->cs = 438; goto _test_eof; 
	_test_eof439:  sm->cs = 439; goto _test_eof; 
	_test_eof440:  sm->cs = 440; goto _test_eof; 
	_test_eof441:  sm->cs = 441; goto _test_eof; 
	_test_eof1175:  sm->cs = 1175; goto _test_eof; 
	_test_eof1176:  sm->cs = 1176; goto _test_eof; 
	_test_eof442:  sm->cs = 442; goto _test_eof; 
	_test_eof1177:  sm->cs = 1177; goto _test_eof; 
	_test_eof1178:  sm->cs = 1178; goto _test_eof; 
	_test_eof443:  sm->cs = 443; goto _test_eof; 
	_test_eof444:  sm->cs = 444; goto _test_eof; 
	_test_eof445:  sm->cs = 445; goto _test_eof; 
	_test_eof446:  sm->cs = 446; goto _test_eof; 
	_test_eof447:  sm->cs = 447; goto _test_eof; 
	_test_eof448:  sm->cs = 448; goto _test_eof; 
	_test_eof449:  sm->cs = 449; goto _test_eof; 
	_test_eof450:  sm->cs = 450; goto _test_eof; 
	_test_eof1179:  sm->cs = 1179; goto _test_eof; 
	_test_eof1180:  sm->cs = 1180; goto _test_eof; 
	_test_eof451:  sm->cs = 451; goto _test_eof; 
	_test_eof1181:  sm->cs = 1181; goto _test_eof; 
	_test_eof452:  sm->cs = 452; goto _test_eof; 
	_test_eof453:  sm->cs = 453; goto _test_eof; 
	_test_eof454:  sm->cs = 454; goto _test_eof; 
	_test_eof455:  sm->cs = 455; goto _test_eof; 
	_test_eof456:  sm->cs = 456; goto _test_eof; 
	_test_eof457:  sm->cs = 457; goto _test_eof; 
	_test_eof458:  sm->cs = 458; goto _test_eof; 
	_test_eof459:  sm->cs = 459; goto _test_eof; 
	_test_eof460:  sm->cs = 460; goto _test_eof; 
	_test_eof461:  sm->cs = 461; goto _test_eof; 
	_test_eof462:  sm->cs = 462; goto _test_eof; 
	_test_eof463:  sm->cs = 463; goto _test_eof; 
	_test_eof464:  sm->cs = 464; goto _test_eof; 
	_test_eof465:  sm->cs = 465; goto _test_eof; 
	_test_eof466:  sm->cs = 466; goto _test_eof; 
	_test_eof467:  sm->cs = 467; goto _test_eof; 
	_test_eof468:  sm->cs = 468; goto _test_eof; 
	_test_eof469:  sm->cs = 469; goto _test_eof; 
	_test_eof1182:  sm->cs = 1182; goto _test_eof; 
	_test_eof470:  sm->cs = 470; goto _test_eof; 
	_test_eof471:  sm->cs = 471; goto _test_eof; 
	_test_eof472:  sm->cs = 472; goto _test_eof; 
	_test_eof473:  sm->cs = 473; goto _test_eof; 
	_test_eof474:  sm->cs = 474; goto _test_eof; 
	_test_eof475:  sm->cs = 475; goto _test_eof; 
	_test_eof476:  sm->cs = 476; goto _test_eof; 
	_test_eof477:  sm->cs = 477; goto _test_eof; 
	_test_eof478:  sm->cs = 478; goto _test_eof; 
	_test_eof1183:  sm->cs = 1183; goto _test_eof; 
	_test_eof1184:  sm->cs = 1184; goto _test_eof; 
	_test_eof1185:  sm->cs = 1185; goto _test_eof; 
	_test_eof1186:  sm->cs = 1186; goto _test_eof; 
	_test_eof1187:  sm->cs = 1187; goto _test_eof; 
	_test_eof479:  sm->cs = 479; goto _test_eof; 
	_test_eof480:  sm->cs = 480; goto _test_eof; 
	_test_eof1188:  sm->cs = 1188; goto _test_eof; 
	_test_eof1189:  sm->cs = 1189; goto _test_eof; 
	_test_eof1190:  sm->cs = 1190; goto _test_eof; 
	_test_eof1191:  sm->cs = 1191; goto _test_eof; 
	_test_eof1192:  sm->cs = 1192; goto _test_eof; 
	_test_eof1193:  sm->cs = 1193; goto _test_eof; 
	_test_eof481:  sm->cs = 481; goto _test_eof; 
	_test_eof482:  sm->cs = 482; goto _test_eof; 
	_test_eof1194:  sm->cs = 1194; goto _test_eof; 
	_test_eof1195:  sm->cs = 1195; goto _test_eof; 
	_test_eof1196:  sm->cs = 1196; goto _test_eof; 
	_test_eof1197:  sm->cs = 1197; goto _test_eof; 
	_test_eof1198:  sm->cs = 1198; goto _test_eof; 
	_test_eof1199:  sm->cs = 1199; goto _test_eof; 
	_test_eof483:  sm->cs = 483; goto _test_eof; 
	_test_eof484:  sm->cs = 484; goto _test_eof; 
	_test_eof1200:  sm->cs = 1200; goto _test_eof; 
	_test_eof1201:  sm->cs = 1201; goto _test_eof; 
	_test_eof1202:  sm->cs = 1202; goto _test_eof; 
	_test_eof1203:  sm->cs = 1203; goto _test_eof; 
	_test_eof1204:  sm->cs = 1204; goto _test_eof; 
	_test_eof1205:  sm->cs = 1205; goto _test_eof; 
	_test_eof1206:  sm->cs = 1206; goto _test_eof; 
	_test_eof1207:  sm->cs = 1207; goto _test_eof; 
	_test_eof485:  sm->cs = 485; goto _test_eof; 
	_test_eof486:  sm->cs = 486; goto _test_eof; 
	_test_eof1208:  sm->cs = 1208; goto _test_eof; 
	_test_eof1209:  sm->cs = 1209; goto _test_eof; 
	_test_eof1210:  sm->cs = 1210; goto _test_eof; 
	_test_eof1211:  sm->cs = 1211; goto _test_eof; 
	_test_eof487:  sm->cs = 487; goto _test_eof; 
	_test_eof488:  sm->cs = 488; goto _test_eof; 
	_test_eof1212:  sm->cs = 1212; goto _test_eof; 
	_test_eof1213:  sm->cs = 1213; goto _test_eof; 
	_test_eof1214:  sm->cs = 1214; goto _test_eof; 
	_test_eof489:  sm->cs = 489; goto _test_eof; 
	_test_eof490:  sm->cs = 490; goto _test_eof; 
	_test_eof1215:  sm->cs = 1215; goto _test_eof; 
	_test_eof1216:  sm->cs = 1216; goto _test_eof; 
	_test_eof1217:  sm->cs = 1217; goto _test_eof; 
	_test_eof1218:  sm->cs = 1218; goto _test_eof; 
	_test_eof1219:  sm->cs = 1219; goto _test_eof; 
	_test_eof1220:  sm->cs = 1220; goto _test_eof; 
	_test_eof1221:  sm->cs = 1221; goto _test_eof; 
	_test_eof1222:  sm->cs = 1222; goto _test_eof; 
	_test_eof491:  sm->cs = 491; goto _test_eof; 
	_test_eof492:  sm->cs = 492; goto _test_eof; 
	_test_eof1223:  sm->cs = 1223; goto _test_eof; 
	_test_eof1224:  sm->cs = 1224; goto _test_eof; 
	_test_eof1225:  sm->cs = 1225; goto _test_eof; 
	_test_eof493:  sm->cs = 493; goto _test_eof; 
	_test_eof494:  sm->cs = 494; goto _test_eof; 
	_test_eof1226:  sm->cs = 1226; goto _test_eof; 
	_test_eof1227:  sm->cs = 1227; goto _test_eof; 
	_test_eof1228:  sm->cs = 1228; goto _test_eof; 
	_test_eof1229:  sm->cs = 1229; goto _test_eof; 
	_test_eof1230:  sm->cs = 1230; goto _test_eof; 
	_test_eof1231:  sm->cs = 1231; goto _test_eof; 
	_test_eof1232:  sm->cs = 1232; goto _test_eof; 
	_test_eof1233:  sm->cs = 1233; goto _test_eof; 
	_test_eof1234:  sm->cs = 1234; goto _test_eof; 
	_test_eof1235:  sm->cs = 1235; goto _test_eof; 
	_test_eof1236:  sm->cs = 1236; goto _test_eof; 
	_test_eof495:  sm->cs = 495; goto _test_eof; 
	_test_eof496:  sm->cs = 496; goto _test_eof; 
	_test_eof1237:  sm->cs = 1237; goto _test_eof; 
	_test_eof1238:  sm->cs = 1238; goto _test_eof; 
	_test_eof1239:  sm->cs = 1239; goto _test_eof; 
	_test_eof1240:  sm->cs = 1240; goto _test_eof; 
	_test_eof1241:  sm->cs = 1241; goto _test_eof; 
	_test_eof497:  sm->cs = 497; goto _test_eof; 
	_test_eof498:  sm->cs = 498; goto _test_eof; 
	_test_eof1242:  sm->cs = 1242; goto _test_eof; 
	_test_eof499:  sm->cs = 499; goto _test_eof; 
	_test_eof1243:  sm->cs = 1243; goto _test_eof; 
	_test_eof1244:  sm->cs = 1244; goto _test_eof; 
	_test_eof1245:  sm->cs = 1245; goto _test_eof; 
	_test_eof1246:  sm->cs = 1246; goto _test_eof; 
	_test_eof1247:  sm->cs = 1247; goto _test_eof; 
	_test_eof1248:  sm->cs = 1248; goto _test_eof; 
	_test_eof1249:  sm->cs = 1249; goto _test_eof; 
	_test_eof1250:  sm->cs = 1250; goto _test_eof; 
	_test_eof1251:  sm->cs = 1251; goto _test_eof; 
	_test_eof500:  sm->cs = 500; goto _test_eof; 
	_test_eof501:  sm->cs = 501; goto _test_eof; 
	_test_eof1252:  sm->cs = 1252; goto _test_eof; 
	_test_eof1253:  sm->cs = 1253; goto _test_eof; 
	_test_eof1254:  sm->cs = 1254; goto _test_eof; 
	_test_eof1255:  sm->cs = 1255; goto _test_eof; 
	_test_eof1256:  sm->cs = 1256; goto _test_eof; 
	_test_eof1257:  sm->cs = 1257; goto _test_eof; 
	_test_eof1258:  sm->cs = 1258; goto _test_eof; 
	_test_eof1259:  sm->cs = 1259; goto _test_eof; 
	_test_eof502:  sm->cs = 502; goto _test_eof; 
	_test_eof503:  sm->cs = 503; goto _test_eof; 
	_test_eof1260:  sm->cs = 1260; goto _test_eof; 
	_test_eof1261:  sm->cs = 1261; goto _test_eof; 
	_test_eof1262:  sm->cs = 1262; goto _test_eof; 
	_test_eof1263:  sm->cs = 1263; goto _test_eof; 
	_test_eof504:  sm->cs = 504; goto _test_eof; 
	_test_eof505:  sm->cs = 505; goto _test_eof; 
	_test_eof1264:  sm->cs = 1264; goto _test_eof; 
	_test_eof1265:  sm->cs = 1265; goto _test_eof; 
	_test_eof1266:  sm->cs = 1266; goto _test_eof; 
	_test_eof1267:  sm->cs = 1267; goto _test_eof; 
	_test_eof1268:  sm->cs = 1268; goto _test_eof; 
	_test_eof506:  sm->cs = 506; goto _test_eof; 
	_test_eof507:  sm->cs = 507; goto _test_eof; 
	_test_eof1269:  sm->cs = 1269; goto _test_eof; 
	_test_eof1270:  sm->cs = 1270; goto _test_eof; 
	_test_eof1271:  sm->cs = 1271; goto _test_eof; 
	_test_eof1272:  sm->cs = 1272; goto _test_eof; 
	_test_eof1273:  sm->cs = 1273; goto _test_eof; 
	_test_eof1274:  sm->cs = 1274; goto _test_eof; 
	_test_eof1275:  sm->cs = 1275; goto _test_eof; 
	_test_eof1276:  sm->cs = 1276; goto _test_eof; 
	_test_eof1277:  sm->cs = 1277; goto _test_eof; 
	_test_eof508:  sm->cs = 508; goto _test_eof; 
	_test_eof509:  sm->cs = 509; goto _test_eof; 
	_test_eof1278:  sm->cs = 1278; goto _test_eof; 
	_test_eof1279:  sm->cs = 1279; goto _test_eof; 
	_test_eof1280:  sm->cs = 1280; goto _test_eof; 
	_test_eof1281:  sm->cs = 1281; goto _test_eof; 
	_test_eof1282:  sm->cs = 1282; goto _test_eof; 
	_test_eof510:  sm->cs = 510; goto _test_eof; 
	_test_eof511:  sm->cs = 511; goto _test_eof; 
	_test_eof512:  sm->cs = 512; goto _test_eof; 
	_test_eof513:  sm->cs = 513; goto _test_eof; 
	_test_eof514:  sm->cs = 514; goto _test_eof; 
	_test_eof515:  sm->cs = 515; goto _test_eof; 
	_test_eof516:  sm->cs = 516; goto _test_eof; 
	_test_eof517:  sm->cs = 517; goto _test_eof; 
	_test_eof518:  sm->cs = 518; goto _test_eof; 
	_test_eof1283:  sm->cs = 1283; goto _test_eof; 
	_test_eof519:  sm->cs = 519; goto _test_eof; 
	_test_eof520:  sm->cs = 520; goto _test_eof; 
	_test_eof521:  sm->cs = 521; goto _test_eof; 
	_test_eof522:  sm->cs = 522; goto _test_eof; 
	_test_eof523:  sm->cs = 523; goto _test_eof; 
	_test_eof524:  sm->cs = 524; goto _test_eof; 
	_test_eof525:  sm->cs = 525; goto _test_eof; 
	_test_eof526:  sm->cs = 526; goto _test_eof; 
	_test_eof527:  sm->cs = 527; goto _test_eof; 
	_test_eof528:  sm->cs = 528; goto _test_eof; 
	_test_eof1284:  sm->cs = 1284; goto _test_eof; 
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
	_test_eof1285:  sm->cs = 1285; goto _test_eof; 
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
	_test_eof1286:  sm->cs = 1286; goto _test_eof; 
	_test_eof553:  sm->cs = 553; goto _test_eof; 
	_test_eof554:  sm->cs = 554; goto _test_eof; 
	_test_eof555:  sm->cs = 555; goto _test_eof; 
	_test_eof556:  sm->cs = 556; goto _test_eof; 
	_test_eof557:  sm->cs = 557; goto _test_eof; 
	_test_eof558:  sm->cs = 558; goto _test_eof; 
	_test_eof559:  sm->cs = 559; goto _test_eof; 
	_test_eof560:  sm->cs = 560; goto _test_eof; 
	_test_eof561:  sm->cs = 561; goto _test_eof; 
	_test_eof562:  sm->cs = 562; goto _test_eof; 
	_test_eof1287:  sm->cs = 1287; goto _test_eof; 
	_test_eof1288:  sm->cs = 1288; goto _test_eof; 
	_test_eof1289:  sm->cs = 1289; goto _test_eof; 
	_test_eof1290:  sm->cs = 1290; goto _test_eof; 
	_test_eof1291:  sm->cs = 1291; goto _test_eof; 
	_test_eof1292:  sm->cs = 1292; goto _test_eof; 
	_test_eof1293:  sm->cs = 1293; goto _test_eof; 
	_test_eof1294:  sm->cs = 1294; goto _test_eof; 
	_test_eof1295:  sm->cs = 1295; goto _test_eof; 
	_test_eof1296:  sm->cs = 1296; goto _test_eof; 
	_test_eof1297:  sm->cs = 1297; goto _test_eof; 
	_test_eof1298:  sm->cs = 1298; goto _test_eof; 
	_test_eof1299:  sm->cs = 1299; goto _test_eof; 
	_test_eof563:  sm->cs = 563; goto _test_eof; 
	_test_eof564:  sm->cs = 564; goto _test_eof; 
	_test_eof1300:  sm->cs = 1300; goto _test_eof; 
	_test_eof1301:  sm->cs = 1301; goto _test_eof; 
	_test_eof1302:  sm->cs = 1302; goto _test_eof; 
	_test_eof1303:  sm->cs = 1303; goto _test_eof; 
	_test_eof1304:  sm->cs = 1304; goto _test_eof; 
	_test_eof565:  sm->cs = 565; goto _test_eof; 
	_test_eof566:  sm->cs = 566; goto _test_eof; 
	_test_eof1305:  sm->cs = 1305; goto _test_eof; 
	_test_eof1306:  sm->cs = 1306; goto _test_eof; 
	_test_eof1307:  sm->cs = 1307; goto _test_eof; 
	_test_eof1308:  sm->cs = 1308; goto _test_eof; 
	_test_eof567:  sm->cs = 567; goto _test_eof; 
	_test_eof568:  sm->cs = 568; goto _test_eof; 
	_test_eof569:  sm->cs = 569; goto _test_eof; 
	_test_eof570:  sm->cs = 570; goto _test_eof; 
	_test_eof571:  sm->cs = 571; goto _test_eof; 
	_test_eof572:  sm->cs = 572; goto _test_eof; 
	_test_eof573:  sm->cs = 573; goto _test_eof; 
	_test_eof574:  sm->cs = 574; goto _test_eof; 
	_test_eof575:  sm->cs = 575; goto _test_eof; 
	_test_eof1309:  sm->cs = 1309; goto _test_eof; 
	_test_eof1310:  sm->cs = 1310; goto _test_eof; 
	_test_eof1311:  sm->cs = 1311; goto _test_eof; 
	_test_eof1312:  sm->cs = 1312; goto _test_eof; 
	_test_eof1313:  sm->cs = 1313; goto _test_eof; 
	_test_eof1314:  sm->cs = 1314; goto _test_eof; 
	_test_eof1315:  sm->cs = 1315; goto _test_eof; 
	_test_eof576:  sm->cs = 576; goto _test_eof; 
	_test_eof577:  sm->cs = 577; goto _test_eof; 
	_test_eof1316:  sm->cs = 1316; goto _test_eof; 
	_test_eof1317:  sm->cs = 1317; goto _test_eof; 
	_test_eof1318:  sm->cs = 1318; goto _test_eof; 
	_test_eof1319:  sm->cs = 1319; goto _test_eof; 
	_test_eof1320:  sm->cs = 1320; goto _test_eof; 
	_test_eof1321:  sm->cs = 1321; goto _test_eof; 
	_test_eof578:  sm->cs = 578; goto _test_eof; 
	_test_eof579:  sm->cs = 579; goto _test_eof; 
	_test_eof1322:  sm->cs = 1322; goto _test_eof; 
	_test_eof1323:  sm->cs = 1323; goto _test_eof; 
	_test_eof1324:  sm->cs = 1324; goto _test_eof; 
	_test_eof1325:  sm->cs = 1325; goto _test_eof; 
	_test_eof580:  sm->cs = 580; goto _test_eof; 
	_test_eof581:  sm->cs = 581; goto _test_eof; 
	_test_eof1326:  sm->cs = 1326; goto _test_eof; 
	_test_eof1327:  sm->cs = 1327; goto _test_eof; 
	_test_eof1328:  sm->cs = 1328; goto _test_eof; 
	_test_eof1329:  sm->cs = 1329; goto _test_eof; 
	_test_eof1330:  sm->cs = 1330; goto _test_eof; 
	_test_eof1331:  sm->cs = 1331; goto _test_eof; 
	_test_eof582:  sm->cs = 582; goto _test_eof; 
	_test_eof583:  sm->cs = 583; goto _test_eof; 
	_test_eof1332:  sm->cs = 1332; goto _test_eof; 
	_test_eof1333:  sm->cs = 1333; goto _test_eof; 
	_test_eof1334:  sm->cs = 1334; goto _test_eof; 
	_test_eof1335:  sm->cs = 1335; goto _test_eof; 
	_test_eof1336:  sm->cs = 1336; goto _test_eof; 
	_test_eof584:  sm->cs = 584; goto _test_eof; 
	_test_eof585:  sm->cs = 585; goto _test_eof; 
	_test_eof1337:  sm->cs = 1337; goto _test_eof; 
	_test_eof586:  sm->cs = 586; goto _test_eof; 
	_test_eof587:  sm->cs = 587; goto _test_eof; 
	_test_eof1338:  sm->cs = 1338; goto _test_eof; 
	_test_eof1339:  sm->cs = 1339; goto _test_eof; 
	_test_eof1340:  sm->cs = 1340; goto _test_eof; 
	_test_eof1341:  sm->cs = 1341; goto _test_eof; 
	_test_eof588:  sm->cs = 588; goto _test_eof; 
	_test_eof589:  sm->cs = 589; goto _test_eof; 
	_test_eof1342:  sm->cs = 1342; goto _test_eof; 
	_test_eof1343:  sm->cs = 1343; goto _test_eof; 
	_test_eof1344:  sm->cs = 1344; goto _test_eof; 
	_test_eof590:  sm->cs = 590; goto _test_eof; 
	_test_eof591:  sm->cs = 591; goto _test_eof; 
	_test_eof1345:  sm->cs = 1345; goto _test_eof; 
	_test_eof1346:  sm->cs = 1346; goto _test_eof; 
	_test_eof1347:  sm->cs = 1347; goto _test_eof; 
	_test_eof1348:  sm->cs = 1348; goto _test_eof; 
	_test_eof592:  sm->cs = 592; goto _test_eof; 
	_test_eof593:  sm->cs = 593; goto _test_eof; 
	_test_eof1349:  sm->cs = 1349; goto _test_eof; 
	_test_eof1350:  sm->cs = 1350; goto _test_eof; 
	_test_eof1351:  sm->cs = 1351; goto _test_eof; 
	_test_eof1352:  sm->cs = 1352; goto _test_eof; 
	_test_eof1353:  sm->cs = 1353; goto _test_eof; 
	_test_eof1354:  sm->cs = 1354; goto _test_eof; 
	_test_eof1355:  sm->cs = 1355; goto _test_eof; 
	_test_eof1356:  sm->cs = 1356; goto _test_eof; 
	_test_eof594:  sm->cs = 594; goto _test_eof; 
	_test_eof595:  sm->cs = 595; goto _test_eof; 
	_test_eof1357:  sm->cs = 1357; goto _test_eof; 
	_test_eof1358:  sm->cs = 1358; goto _test_eof; 
	_test_eof1359:  sm->cs = 1359; goto _test_eof; 
	_test_eof1360:  sm->cs = 1360; goto _test_eof; 
	_test_eof1361:  sm->cs = 1361; goto _test_eof; 
	_test_eof596:  sm->cs = 596; goto _test_eof; 
	_test_eof597:  sm->cs = 597; goto _test_eof; 
	_test_eof1362:  sm->cs = 1362; goto _test_eof; 
	_test_eof1363:  sm->cs = 1363; goto _test_eof; 
	_test_eof1364:  sm->cs = 1364; goto _test_eof; 
	_test_eof1365:  sm->cs = 1365; goto _test_eof; 
	_test_eof1366:  sm->cs = 1366; goto _test_eof; 
	_test_eof1367:  sm->cs = 1367; goto _test_eof; 
	_test_eof598:  sm->cs = 598; goto _test_eof; 
	_test_eof599:  sm->cs = 599; goto _test_eof; 
	_test_eof1368:  sm->cs = 1368; goto _test_eof; 
	_test_eof600:  sm->cs = 600; goto _test_eof; 
	_test_eof601:  sm->cs = 601; goto _test_eof; 
	_test_eof1369:  sm->cs = 1369; goto _test_eof; 
	_test_eof1370:  sm->cs = 1370; goto _test_eof; 
	_test_eof1371:  sm->cs = 1371; goto _test_eof; 
	_test_eof1372:  sm->cs = 1372; goto _test_eof; 
	_test_eof1373:  sm->cs = 1373; goto _test_eof; 
	_test_eof1374:  sm->cs = 1374; goto _test_eof; 
	_test_eof1375:  sm->cs = 1375; goto _test_eof; 
	_test_eof602:  sm->cs = 602; goto _test_eof; 
	_test_eof603:  sm->cs = 603; goto _test_eof; 
	_test_eof1376:  sm->cs = 1376; goto _test_eof; 
	_test_eof1377:  sm->cs = 1377; goto _test_eof; 
	_test_eof1378:  sm->cs = 1378; goto _test_eof; 
	_test_eof1379:  sm->cs = 1379; goto _test_eof; 
	_test_eof1380:  sm->cs = 1380; goto _test_eof; 
	_test_eof604:  sm->cs = 604; goto _test_eof; 
	_test_eof605:  sm->cs = 605; goto _test_eof; 
	_test_eof1381:  sm->cs = 1381; goto _test_eof; 
	_test_eof1382:  sm->cs = 1382; goto _test_eof; 
	_test_eof1383:  sm->cs = 1383; goto _test_eof; 
	_test_eof1384:  sm->cs = 1384; goto _test_eof; 
	_test_eof1385:  sm->cs = 1385; goto _test_eof; 
	_test_eof606:  sm->cs = 606; goto _test_eof; 
	_test_eof607:  sm->cs = 607; goto _test_eof; 
	_test_eof1386:  sm->cs = 1386; goto _test_eof; 
	_test_eof1387:  sm->cs = 1387; goto _test_eof; 
	_test_eof1388:  sm->cs = 1388; goto _test_eof; 
	_test_eof1389:  sm->cs = 1389; goto _test_eof; 
	_test_eof1390:  sm->cs = 1390; goto _test_eof; 
	_test_eof1391:  sm->cs = 1391; goto _test_eof; 
	_test_eof1392:  sm->cs = 1392; goto _test_eof; 
	_test_eof1393:  sm->cs = 1393; goto _test_eof; 
	_test_eof608:  sm->cs = 608; goto _test_eof; 
	_test_eof609:  sm->cs = 609; goto _test_eof; 
	_test_eof1394:  sm->cs = 1394; goto _test_eof; 
	_test_eof1395:  sm->cs = 1395; goto _test_eof; 
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
	_test_eof1396:  sm->cs = 1396; goto _test_eof; 
	_test_eof623:  sm->cs = 623; goto _test_eof; 
	_test_eof624:  sm->cs = 624; goto _test_eof; 
	_test_eof1397:  sm->cs = 1397; goto _test_eof; 
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
	_test_eof1398:  sm->cs = 1398; goto _test_eof; 
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
	_test_eof667:  sm->cs = 667; goto _test_eof; 
	_test_eof668:  sm->cs = 668; goto _test_eof; 
	_test_eof669:  sm->cs = 669; goto _test_eof; 
	_test_eof670:  sm->cs = 670; goto _test_eof; 
	_test_eof671:  sm->cs = 671; goto _test_eof; 
	_test_eof672:  sm->cs = 672; goto _test_eof; 
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
	_test_eof715:  sm->cs = 715; goto _test_eof; 
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
	_test_eof734:  sm->cs = 734; goto _test_eof; 
	_test_eof735:  sm->cs = 735; goto _test_eof; 
	_test_eof736:  sm->cs = 736; goto _test_eof; 
	_test_eof737:  sm->cs = 737; goto _test_eof; 
	_test_eof1399:  sm->cs = 1399; goto _test_eof; 
	_test_eof1400:  sm->cs = 1400; goto _test_eof; 
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
	_test_eof1401:  sm->cs = 1401; goto _test_eof; 
	_test_eof831:  sm->cs = 831; goto _test_eof; 
	_test_eof832:  sm->cs = 832; goto _test_eof; 
	_test_eof1402:  sm->cs = 1402; goto _test_eof; 
	_test_eof833:  sm->cs = 833; goto _test_eof; 
	_test_eof834:  sm->cs = 834; goto _test_eof; 
	_test_eof835:  sm->cs = 835; goto _test_eof; 
	_test_eof836:  sm->cs = 836; goto _test_eof; 
	_test_eof1403:  sm->cs = 1403; goto _test_eof; 
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
	_test_eof1404:  sm->cs = 1404; goto _test_eof; 
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
	_test_eof1405:  sm->cs = 1405; goto _test_eof; 
	_test_eof1406:  sm->cs = 1406; goto _test_eof; 
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
	_test_eof1407:  sm->cs = 1407; goto _test_eof; 
	_test_eof879:  sm->cs = 879; goto _test_eof; 
	_test_eof1408:  sm->cs = 1408; goto _test_eof; 
	_test_eof1409:  sm->cs = 1409; goto _test_eof; 
	_test_eof1410:  sm->cs = 1410; goto _test_eof; 
	_test_eof1411:  sm->cs = 1411; goto _test_eof; 
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
	_test_eof1412:  sm->cs = 1412; goto _test_eof; 
	_test_eof898:  sm->cs = 898; goto _test_eof; 
	_test_eof1413:  sm->cs = 1413; goto _test_eof; 
	_test_eof1414:  sm->cs = 1414; goto _test_eof; 
	_test_eof1415:  sm->cs = 1415; goto _test_eof; 
	_test_eof1416:  sm->cs = 1416; goto _test_eof; 
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
	_test_eof959:  sm->cs = 959; goto _test_eof; 
	_test_eof960:  sm->cs = 960; goto _test_eof; 
	_test_eof961:  sm->cs = 961; goto _test_eof; 
	_test_eof962:  sm->cs = 962; goto _test_eof; 
	_test_eof963:  sm->cs = 963; goto _test_eof; 
	_test_eof964:  sm->cs = 964; goto _test_eof; 
	_test_eof965:  sm->cs = 965; goto _test_eof; 
	_test_eof966:  sm->cs = 966; goto _test_eof; 
	_test_eof967:  sm->cs = 967; goto _test_eof; 
	_test_eof968:  sm->cs = 968; goto _test_eof; 
	_test_eof969:  sm->cs = 969; goto _test_eof; 
	_test_eof970:  sm->cs = 970; goto _test_eof; 
	_test_eof971:  sm->cs = 971; goto _test_eof; 
	_test_eof972:  sm->cs = 972; goto _test_eof; 
	_test_eof973:  sm->cs = 973; goto _test_eof; 
	_test_eof974:  sm->cs = 974; goto _test_eof; 
	_test_eof975:  sm->cs = 975; goto _test_eof; 
	_test_eof976:  sm->cs = 976; goto _test_eof; 
	_test_eof977:  sm->cs = 977; goto _test_eof; 
	_test_eof978:  sm->cs = 978; goto _test_eof; 
	_test_eof979:  sm->cs = 979; goto _test_eof; 
	_test_eof980:  sm->cs = 980; goto _test_eof; 
	_test_eof981:  sm->cs = 981; goto _test_eof; 
	_test_eof982:  sm->cs = 982; goto _test_eof; 
	_test_eof983:  sm->cs = 983; goto _test_eof; 
	_test_eof984:  sm->cs = 984; goto _test_eof; 
	_test_eof985:  sm->cs = 985; goto _test_eof; 
	_test_eof986:  sm->cs = 986; goto _test_eof; 
	_test_eof987:  sm->cs = 987; goto _test_eof; 
	_test_eof988:  sm->cs = 988; goto _test_eof; 
	_test_eof989:  sm->cs = 989; goto _test_eof; 
	_test_eof990:  sm->cs = 990; goto _test_eof; 
	_test_eof991:  sm->cs = 991; goto _test_eof; 
	_test_eof992:  sm->cs = 992; goto _test_eof; 
	_test_eof993:  sm->cs = 993; goto _test_eof; 
	_test_eof994:  sm->cs = 994; goto _test_eof; 
	_test_eof995:  sm->cs = 995; goto _test_eof; 
	_test_eof996:  sm->cs = 996; goto _test_eof; 
	_test_eof997:  sm->cs = 997; goto _test_eof; 
	_test_eof998:  sm->cs = 998; goto _test_eof; 
	_test_eof999:  sm->cs = 999; goto _test_eof; 
	_test_eof1000:  sm->cs = 1000; goto _test_eof; 
	_test_eof1001:  sm->cs = 1001; goto _test_eof; 
	_test_eof1002:  sm->cs = 1002; goto _test_eof; 
	_test_eof1003:  sm->cs = 1003; goto _test_eof; 
	_test_eof1004:  sm->cs = 1004; goto _test_eof; 
	_test_eof1005:  sm->cs = 1005; goto _test_eof; 
	_test_eof1006:  sm->cs = 1006; goto _test_eof; 
	_test_eof1007:  sm->cs = 1007; goto _test_eof; 
	_test_eof1008:  sm->cs = 1008; goto _test_eof; 
	_test_eof1009:  sm->cs = 1009; goto _test_eof; 
	_test_eof1010:  sm->cs = 1010; goto _test_eof; 
	_test_eof1417:  sm->cs = 1417; goto _test_eof; 
	_test_eof1011:  sm->cs = 1011; goto _test_eof; 
	_test_eof1012:  sm->cs = 1012; goto _test_eof; 
	_test_eof1013:  sm->cs = 1013; goto _test_eof; 
	_test_eof1014:  sm->cs = 1014; goto _test_eof; 
	_test_eof1015:  sm->cs = 1015; goto _test_eof; 
	_test_eof1016:  sm->cs = 1016; goto _test_eof; 
	_test_eof1017:  sm->cs = 1017; goto _test_eof; 
	_test_eof1018:  sm->cs = 1018; goto _test_eof; 
	_test_eof1019:  sm->cs = 1019; goto _test_eof; 
	_test_eof1020:  sm->cs = 1020; goto _test_eof; 
	_test_eof1021:  sm->cs = 1021; goto _test_eof; 
	_test_eof1022:  sm->cs = 1022; goto _test_eof; 
	_test_eof1023:  sm->cs = 1023; goto _test_eof; 
	_test_eof1024:  sm->cs = 1024; goto _test_eof; 
	_test_eof1025:  sm->cs = 1025; goto _test_eof; 
	_test_eof1026:  sm->cs = 1026; goto _test_eof; 
	_test_eof1027:  sm->cs = 1027; goto _test_eof; 
	_test_eof1028:  sm->cs = 1028; goto _test_eof; 
	_test_eof1029:  sm->cs = 1029; goto _test_eof; 
	_test_eof1030:  sm->cs = 1030; goto _test_eof; 
	_test_eof1031:  sm->cs = 1031; goto _test_eof; 
	_test_eof1032:  sm->cs = 1032; goto _test_eof; 
	_test_eof1033:  sm->cs = 1033; goto _test_eof; 
	_test_eof1034:  sm->cs = 1034; goto _test_eof; 
	_test_eof1035:  sm->cs = 1035; goto _test_eof; 
	_test_eof1036:  sm->cs = 1036; goto _test_eof; 
	_test_eof1037:  sm->cs = 1037; goto _test_eof; 
	_test_eof1038:  sm->cs = 1038; goto _test_eof; 
	_test_eof1039:  sm->cs = 1039; goto _test_eof; 
	_test_eof1040:  sm->cs = 1040; goto _test_eof; 
	_test_eof1041:  sm->cs = 1041; goto _test_eof; 
	_test_eof1042:  sm->cs = 1042; goto _test_eof; 
	_test_eof1043:  sm->cs = 1043; goto _test_eof; 
	_test_eof1044:  sm->cs = 1044; goto _test_eof; 
	_test_eof1045:  sm->cs = 1045; goto _test_eof; 
	_test_eof1046:  sm->cs = 1046; goto _test_eof; 
	_test_eof1047:  sm->cs = 1047; goto _test_eof; 
	_test_eof1048:  sm->cs = 1048; goto _test_eof; 
	_test_eof1049:  sm->cs = 1049; goto _test_eof; 
	_test_eof1050:  sm->cs = 1050; goto _test_eof; 
	_test_eof1051:  sm->cs = 1051; goto _test_eof; 
	_test_eof1052:  sm->cs = 1052; goto _test_eof; 
	_test_eof1053:  sm->cs = 1053; goto _test_eof; 
	_test_eof1054:  sm->cs = 1054; goto _test_eof; 
	_test_eof1055:  sm->cs = 1055; goto _test_eof; 
	_test_eof1056:  sm->cs = 1056; goto _test_eof; 
	_test_eof1057:  sm->cs = 1057; goto _test_eof; 
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
	_test_eof1069:  sm->cs = 1069; goto _test_eof; 
	_test_eof1070:  sm->cs = 1070; goto _test_eof; 
	_test_eof1071:  sm->cs = 1071; goto _test_eof; 
	_test_eof1072:  sm->cs = 1072; goto _test_eof; 
	_test_eof1073:  sm->cs = 1073; goto _test_eof; 
	_test_eof1074:  sm->cs = 1074; goto _test_eof; 
	_test_eof1075:  sm->cs = 1075; goto _test_eof; 
	_test_eof1076:  sm->cs = 1076; goto _test_eof; 
	_test_eof1077:  sm->cs = 1077; goto _test_eof; 
	_test_eof1078:  sm->cs = 1078; goto _test_eof; 
	_test_eof1079:  sm->cs = 1079; goto _test_eof; 
	_test_eof1080:  sm->cs = 1080; goto _test_eof; 
	_test_eof1081:  sm->cs = 1081; goto _test_eof; 
	_test_eof1082:  sm->cs = 1082; goto _test_eof; 
	_test_eof1083:  sm->cs = 1083; goto _test_eof; 
	_test_eof1084:  sm->cs = 1084; goto _test_eof; 
	_test_eof1085:  sm->cs = 1085; goto _test_eof; 
	_test_eof1086:  sm->cs = 1086; goto _test_eof; 
	_test_eof1087:  sm->cs = 1087; goto _test_eof; 
	_test_eof1088:  sm->cs = 1088; goto _test_eof; 
	_test_eof1089:  sm->cs = 1089; goto _test_eof; 
	_test_eof1090:  sm->cs = 1090; goto _test_eof; 
	_test_eof1091:  sm->cs = 1091; goto _test_eof; 
	_test_eof1092:  sm->cs = 1092; goto _test_eof; 
	_test_eof1093:  sm->cs = 1093; goto _test_eof; 
	_test_eof1094:  sm->cs = 1094; goto _test_eof; 
	_test_eof1095:  sm->cs = 1095; goto _test_eof; 
	_test_eof1096:  sm->cs = 1096; goto _test_eof; 
	_test_eof1097:  sm->cs = 1097; goto _test_eof; 
	_test_eof1098:  sm->cs = 1098; goto _test_eof; 
	_test_eof1099:  sm->cs = 1099; goto _test_eof; 
	_test_eof1100:  sm->cs = 1100; goto _test_eof; 
	_test_eof1101:  sm->cs = 1101; goto _test_eof; 
	_test_eof1102:  sm->cs = 1102; goto _test_eof; 
	_test_eof1103:  sm->cs = 1103; goto _test_eof; 
	_test_eof1104:  sm->cs = 1104; goto _test_eof; 
	_test_eof1105:  sm->cs = 1105; goto _test_eof; 
	_test_eof1106:  sm->cs = 1106; goto _test_eof; 
	_test_eof1107:  sm->cs = 1107; goto _test_eof; 
	_test_eof1108:  sm->cs = 1108; goto _test_eof; 
	_test_eof1109:  sm->cs = 1109; goto _test_eof; 
	_test_eof1110:  sm->cs = 1110; goto _test_eof; 
	_test_eof1111:  sm->cs = 1111; goto _test_eof; 
	_test_eof1112:  sm->cs = 1112; goto _test_eof; 
	_test_eof1113:  sm->cs = 1113; goto _test_eof; 
	_test_eof1114:  sm->cs = 1114; goto _test_eof; 
	_test_eof1115:  sm->cs = 1115; goto _test_eof; 
	_test_eof1116:  sm->cs = 1116; goto _test_eof; 
	_test_eof1117:  sm->cs = 1117; goto _test_eof; 
	_test_eof1118:  sm->cs = 1118; goto _test_eof; 
	_test_eof1119:  sm->cs = 1119; goto _test_eof; 
	_test_eof1120:  sm->cs = 1120; goto _test_eof; 
	_test_eof1121:  sm->cs = 1121; goto _test_eof; 
	_test_eof1122:  sm->cs = 1122; goto _test_eof; 

	_test_eof: {}
	if ( ( sm->p) == ( sm->eof) )
	{
	switch (  sm->cs ) {
	case 1124: goto tr0;
	case 1: goto tr0;
	case 2: goto tr0;
	case 1125: goto tr1450;
	case 3: goto tr4;
	case 4: goto tr4;
	case 5: goto tr4;
	case 6: goto tr4;
	case 7: goto tr4;
	case 8: goto tr4;
	case 1126: goto tr1451;
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
	case 1127: goto tr1450;
	case 1128: goto tr1450;
	case 23: goto tr4;
	case 1129: goto tr1452;
	case 1130: goto tr1452;
	case 24: goto tr4;
	case 1131: goto tr1450;
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
	case 1132: goto tr1460;
	case 35: goto tr4;
	case 36: goto tr4;
	case 37: goto tr4;
	case 38: goto tr4;
	case 39: goto tr4;
	case 40: goto tr4;
	case 41: goto tr4;
	case 1133: goto tr1461;
	case 42: goto tr50;
	case 43: goto tr50;
	case 1134: goto tr1462;
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
	case 1135: goto tr1463;
	case 54: goto tr4;
	case 1136: goto tr1465;
	case 55: goto tr4;
	case 56: goto tr4;
	case 57: goto tr4;
	case 58: goto tr4;
	case 59: goto tr4;
	case 60: goto tr4;
	case 61: goto tr4;
	case 1137: goto tr1466;
	case 62: goto tr79;
	case 63: goto tr79;
	case 64: goto tr4;
	case 65: goto tr4;
	case 66: goto tr4;
	case 67: goto tr4;
	case 68: goto tr4;
	case 69: goto tr4;
	case 70: goto tr4;
	case 1138: goto tr1467;
	case 71: goto tr4;
	case 72: goto tr4;
	case 73: goto tr4;
	case 1139: goto tr1450;
	case 74: goto tr4;
	case 75: goto tr4;
	case 76: goto tr4;
	case 1140: goto tr1469;
	case 1141: goto tr1450;
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
	case 1142: goto tr1450;
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
	case 1144: goto tr1482;
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
	case 1145: goto tr1482;
	case 146: goto tr157;
	case 147: goto tr157;
	case 148: goto tr157;
	case 149: goto tr157;
	case 150: goto tr157;
	case 151: goto tr157;
	case 152: goto tr157;
	case 153: goto tr157;
	case 154: goto tr157;
	case 1147: goto tr1524;
	case 1148: goto tr1525;
	case 155: goto tr185;
	case 156: goto tr185;
	case 157: goto tr188;
	case 1149: goto tr1524;
	case 1150: goto tr1524;
	case 1151: goto tr185;
	case 158: goto tr185;
	case 159: goto tr185;
	case 1152: goto tr1524;
	case 160: goto tr193;
	case 161: goto tr193;
	case 1153: goto tr1527;
	case 162: goto tr196;
	case 163: goto tr196;
	case 164: goto tr196;
	case 165: goto tr196;
	case 166: goto tr196;
	case 1154: goto tr1534;
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
	case 1155: goto tr1535;
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
	case 1156: goto tr1538;
	case 1157: goto tr1538;
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
	case 1158: goto tr1540;
	case 226: goto tr196;
	case 227: goto tr185;
	case 228: goto tr185;
	case 229: goto tr185;
	case 230: goto tr185;
	case 231: goto tr185;
	case 1159: goto tr1541;
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
	case 1160: goto tr1542;
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
	case 1161: goto tr1544;
	case 1162: goto tr1524;
	case 306: goto tr193;
	case 307: goto tr193;
	case 308: goto tr193;
	case 1163: goto tr1546;
	case 309: goto tr373;
	case 310: goto tr373;
	case 311: goto tr373;
	case 312: goto tr373;
	case 313: goto tr373;
	case 314: goto tr373;
	case 315: goto tr373;
	case 316: goto tr373;
	case 317: goto tr373;
	case 318: goto tr373;
	case 319: goto tr373;
	case 1164: goto tr1546;
	case 320: goto tr373;
	case 321: goto tr373;
	case 322: goto tr373;
	case 323: goto tr373;
	case 324: goto tr373;
	case 325: goto tr373;
	case 326: goto tr373;
	case 327: goto tr373;
	case 328: goto tr373;
	case 329: goto tr373;
	case 330: goto tr373;
	case 331: goto tr185;
	case 332: goto tr185;
	case 1165: goto tr1546;
	case 333: goto tr185;
	case 334: goto tr185;
	case 335: goto tr185;
	case 336: goto tr185;
	case 337: goto tr185;
	case 338: goto tr185;
	case 339: goto tr185;
	case 340: goto tr185;
	case 341: goto tr185;
	case 342: goto tr193;
	case 343: goto tr193;
	case 344: goto tr193;
	case 345: goto tr193;
	case 346: goto tr193;
	case 347: goto tr193;
	case 348: goto tr193;
	case 349: goto tr193;
	case 350: goto tr193;
	case 351: goto tr193;
	case 352: goto tr193;
	case 353: goto tr185;
	case 354: goto tr185;
	case 1166: goto tr1546;
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
	case 1167: goto tr1546;
	case 366: goto tr193;
	case 367: goto tr193;
	case 368: goto tr193;
	case 369: goto tr193;
	case 370: goto tr193;
	case 371: goto tr193;
	case 372: goto tr193;
	case 373: goto tr193;
	case 374: goto tr193;
	case 375: goto tr193;
	case 376: goto tr193;
	case 1168: goto tr1525;
	case 377: goto tr188;
	case 378: goto tr185;
	case 379: goto tr185;
	case 380: goto tr185;
	case 381: goto tr185;
	case 382: goto tr185;
	case 383: goto tr185;
	case 384: goto tr185;
	case 385: goto tr185;
	case 1169: goto tr1550;
	case 1170: goto tr1552;
	case 386: goto tr185;
	case 387: goto tr185;
	case 388: goto tr185;
	case 389: goto tr185;
	case 1171: goto tr1554;
	case 1172: goto tr1556;
	case 390: goto tr185;
	case 391: goto tr185;
	case 392: goto tr185;
	case 393: goto tr185;
	case 394: goto tr185;
	case 395: goto tr185;
	case 396: goto tr185;
	case 397: goto tr185;
	case 398: goto tr185;
	case 1173: goto tr1550;
	case 1174: goto tr1552;
	case 399: goto tr185;
	case 400: goto tr185;
	case 401: goto tr185;
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
	case 420: goto tr185;
	case 421: goto tr185;
	case 422: goto tr185;
	case 423: goto tr185;
	case 424: goto tr185;
	case 425: goto tr185;
	case 426: goto tr185;
	case 427: goto tr185;
	case 428: goto tr185;
	case 429: goto tr185;
	case 430: goto tr188;
	case 431: goto tr185;
	case 432: goto tr185;
	case 433: goto tr185;
	case 434: goto tr185;
	case 435: goto tr185;
	case 436: goto tr185;
	case 437: goto tr185;
	case 438: goto tr185;
	case 439: goto tr185;
	case 440: goto tr185;
	case 441: goto tr185;
	case 1175: goto tr1560;
	case 1176: goto tr1562;
	case 442: goto tr185;
	case 1177: goto tr1564;
	case 1178: goto tr1566;
	case 443: goto tr185;
	case 444: goto tr185;
	case 445: goto tr185;
	case 446: goto tr185;
	case 447: goto tr185;
	case 448: goto tr185;
	case 449: goto tr185;
	case 450: goto tr185;
	case 1179: goto tr1564;
	case 1180: goto tr1566;
	case 451: goto tr185;
	case 1181: goto tr1564;
	case 452: goto tr185;
	case 453: goto tr185;
	case 454: goto tr185;
	case 455: goto tr185;
	case 456: goto tr185;
	case 457: goto tr185;
	case 458: goto tr185;
	case 459: goto tr185;
	case 460: goto tr185;
	case 461: goto tr185;
	case 462: goto tr185;
	case 463: goto tr185;
	case 464: goto tr185;
	case 465: goto tr185;
	case 466: goto tr185;
	case 467: goto tr185;
	case 468: goto tr185;
	case 469: goto tr185;
	case 1182: goto tr1564;
	case 470: goto tr185;
	case 471: goto tr185;
	case 472: goto tr185;
	case 473: goto tr185;
	case 474: goto tr185;
	case 475: goto tr185;
	case 476: goto tr185;
	case 477: goto tr185;
	case 478: goto tr185;
	case 1183: goto tr1525;
	case 1184: goto tr1525;
	case 1185: goto tr1525;
	case 1186: goto tr1525;
	case 1187: goto tr1525;
	case 479: goto tr188;
	case 480: goto tr188;
	case 1188: goto tr1578;
	case 1189: goto tr1525;
	case 1190: goto tr1525;
	case 1191: goto tr1525;
	case 1192: goto tr1525;
	case 1193: goto tr1525;
	case 481: goto tr188;
	case 482: goto tr188;
	case 1194: goto tr1585;
	case 1195: goto tr1525;
	case 1196: goto tr1525;
	case 1197: goto tr1525;
	case 1198: goto tr1525;
	case 1199: goto tr1525;
	case 483: goto tr188;
	case 484: goto tr188;
	case 1200: goto tr1593;
	case 1201: goto tr1525;
	case 1202: goto tr1525;
	case 1203: goto tr1525;
	case 1204: goto tr1525;
	case 1205: goto tr1525;
	case 1206: goto tr1525;
	case 1207: goto tr1525;
	case 485: goto tr188;
	case 486: goto tr188;
	case 1208: goto tr1602;
	case 1209: goto tr1525;
	case 1210: goto tr1525;
	case 1211: goto tr1525;
	case 487: goto tr188;
	case 488: goto tr188;
	case 1212: goto tr1608;
	case 1213: goto tr1525;
	case 1214: goto tr1525;
	case 489: goto tr188;
	case 490: goto tr188;
	case 1215: goto tr1612;
	case 1216: goto tr1525;
	case 1217: goto tr1525;
	case 1218: goto tr1525;
	case 1219: goto tr1525;
	case 1220: goto tr1525;
	case 1221: goto tr1525;
	case 1222: goto tr1525;
	case 491: goto tr188;
	case 492: goto tr188;
	case 1223: goto tr1622;
	case 1224: goto tr1525;
	case 1225: goto tr1525;
	case 493: goto tr188;
	case 494: goto tr188;
	case 1226: goto tr1626;
	case 1227: goto tr1525;
	case 1228: goto tr1525;
	case 1229: goto tr1525;
	case 1230: goto tr1525;
	case 1231: goto tr1525;
	case 1232: goto tr1525;
	case 1233: goto tr1525;
	case 1234: goto tr1525;
	case 1235: goto tr1525;
	case 1236: goto tr1525;
	case 495: goto tr188;
	case 496: goto tr188;
	case 1237: goto tr1639;
	case 1238: goto tr1525;
	case 1239: goto tr1525;
	case 1240: goto tr1525;
	case 1241: goto tr1525;
	case 497: goto tr188;
	case 498: goto tr188;
	case 1242: goto tr1645;
	case 499: goto tr643;
	case 1243: goto tr1648;
	case 1244: goto tr1525;
	case 1245: goto tr1525;
	case 1246: goto tr1525;
	case 1247: goto tr1525;
	case 1248: goto tr1525;
	case 1249: goto tr1525;
	case 1250: goto tr1525;
	case 1251: goto tr1525;
	case 500: goto tr188;
	case 501: goto tr188;
	case 1252: goto tr1661;
	case 1253: goto tr1525;
	case 1254: goto tr1525;
	case 1255: goto tr1525;
	case 1256: goto tr1525;
	case 1257: goto tr1525;
	case 1258: goto tr1525;
	case 1259: goto tr1525;
	case 502: goto tr188;
	case 503: goto tr188;
	case 1260: goto tr1670;
	case 1261: goto tr1525;
	case 1262: goto tr1525;
	case 1263: goto tr1525;
	case 504: goto tr188;
	case 505: goto tr188;
	case 1264: goto tr1675;
	case 1265: goto tr1525;
	case 1266: goto tr1525;
	case 1267: goto tr1525;
	case 1268: goto tr1525;
	case 506: goto tr188;
	case 507: goto tr188;
	case 1269: goto tr1681;
	case 1270: goto tr1525;
	case 1271: goto tr1525;
	case 1272: goto tr1525;
	case 1273: goto tr1525;
	case 1274: goto tr1525;
	case 1275: goto tr1525;
	case 1276: goto tr1525;
	case 1277: goto tr1525;
	case 508: goto tr188;
	case 509: goto tr188;
	case 1278: goto tr1691;
	case 1279: goto tr1525;
	case 1280: goto tr1525;
	case 1281: goto tr1525;
	case 1282: goto tr1525;
	case 510: goto tr188;
	case 511: goto tr188;
	case 512: goto tr188;
	case 513: goto tr188;
	case 514: goto tr188;
	case 515: goto tr188;
	case 516: goto tr188;
	case 517: goto tr185;
	case 518: goto tr185;
	case 1283: goto tr1698;
	case 519: goto tr185;
	case 520: goto tr185;
	case 521: goto tr185;
	case 522: goto tr185;
	case 523: goto tr185;
	case 524: goto tr185;
	case 525: goto tr185;
	case 526: goto tr185;
	case 527: goto tr185;
	case 528: goto tr185;
	case 1284: goto tr1698;
	case 529: goto tr678;
	case 530: goto tr678;
	case 531: goto tr678;
	case 532: goto tr678;
	case 533: goto tr678;
	case 534: goto tr678;
	case 535: goto tr678;
	case 536: goto tr678;
	case 537: goto tr678;
	case 538: goto tr678;
	case 539: goto tr678;
	case 1285: goto tr1698;
	case 540: goto tr678;
	case 541: goto tr678;
	case 542: goto tr678;
	case 543: goto tr678;
	case 544: goto tr678;
	case 545: goto tr678;
	case 546: goto tr678;
	case 547: goto tr678;
	case 548: goto tr678;
	case 549: goto tr678;
	case 550: goto tr678;
	case 551: goto tr185;
	case 552: goto tr185;
	case 1286: goto tr1698;
	case 553: goto tr185;
	case 554: goto tr185;
	case 555: goto tr185;
	case 556: goto tr185;
	case 557: goto tr185;
	case 558: goto tr185;
	case 559: goto tr185;
	case 560: goto tr185;
	case 561: goto tr185;
	case 562: goto tr185;
	case 1287: goto tr1698;
	case 1288: goto tr1525;
	case 1289: goto tr1525;
	case 1290: goto tr1525;
	case 1291: goto tr1525;
	case 1292: goto tr1525;
	case 1293: goto tr1525;
	case 1294: goto tr1525;
	case 1295: goto tr1525;
	case 1296: goto tr1525;
	case 1297: goto tr1525;
	case 1298: goto tr1525;
	case 1299: goto tr1525;
	case 563: goto tr188;
	case 564: goto tr188;
	case 1300: goto tr1711;
	case 1301: goto tr1525;
	case 1302: goto tr1525;
	case 1303: goto tr1525;
	case 1304: goto tr1525;
	case 565: goto tr188;
	case 566: goto tr188;
	case 1305: goto tr1717;
	case 1306: goto tr1525;
	case 1307: goto tr1525;
	case 1308: goto tr1525;
	case 567: goto tr188;
	case 568: goto tr188;
	case 569: goto tr188;
	case 570: goto tr188;
	case 571: goto tr188;
	case 572: goto tr188;
	case 573: goto tr188;
	case 574: goto tr188;
	case 575: goto tr188;
	case 1309: goto tr1723;
	case 1310: goto tr1525;
	case 1311: goto tr1525;
	case 1312: goto tr1525;
	case 1313: goto tr1525;
	case 1314: goto tr1525;
	case 1315: goto tr1525;
	case 576: goto tr188;
	case 577: goto tr188;
	case 1316: goto tr1731;
	case 1317: goto tr1525;
	case 1318: goto tr1525;
	case 1319: goto tr1525;
	case 1320: goto tr1525;
	case 1321: goto tr1525;
	case 578: goto tr188;
	case 579: goto tr188;
	case 1322: goto tr1739;
	case 1323: goto tr1525;
	case 1324: goto tr1525;
	case 1325: goto tr1525;
	case 580: goto tr188;
	case 581: goto tr188;
	case 1326: goto tr1744;
	case 1327: goto tr1525;
	case 1328: goto tr1525;
	case 1329: goto tr1525;
	case 1330: goto tr1525;
	case 1331: goto tr1525;
	case 582: goto tr188;
	case 583: goto tr188;
	case 1332: goto tr1754;
	case 1333: goto tr1525;
	case 1334: goto tr1525;
	case 1335: goto tr1525;
	case 1336: goto tr1525;
	case 584: goto tr188;
	case 585: goto tr188;
	case 1337: goto tr1760;
	case 586: goto tr736;
	case 587: goto tr736;
	case 1338: goto tr1763;
	case 1339: goto tr1525;
	case 1340: goto tr1525;
	case 1341: goto tr1525;
	case 588: goto tr188;
	case 589: goto tr188;
	case 1342: goto tr1769;
	case 1343: goto tr1525;
	case 1344: goto tr1525;
	case 590: goto tr188;
	case 591: goto tr188;
	case 1345: goto tr1773;
	case 1346: goto tr1525;
	case 1347: goto tr1525;
	case 1348: goto tr1525;
	case 592: goto tr188;
	case 593: goto tr188;
	case 1349: goto tr1778;
	case 1350: goto tr1525;
	case 1351: goto tr1525;
	case 1352: goto tr1525;
	case 1353: goto tr1525;
	case 1354: goto tr1525;
	case 1355: goto tr1525;
	case 1356: goto tr1525;
	case 594: goto tr188;
	case 595: goto tr188;
	case 1357: goto tr1788;
	case 1358: goto tr1525;
	case 1359: goto tr1525;
	case 1360: goto tr1525;
	case 1361: goto tr1525;
	case 596: goto tr188;
	case 597: goto tr188;
	case 1362: goto tr1794;
	case 1363: goto tr1525;
	case 1364: goto tr1525;
	case 1365: goto tr1525;
	case 1366: goto tr1525;
	case 1367: goto tr1525;
	case 598: goto tr188;
	case 599: goto tr188;
	case 1368: goto tr1802;
	case 600: goto tr751;
	case 601: goto tr751;
	case 1369: goto tr1805;
	case 1370: goto tr1525;
	case 1371: goto tr1525;
	case 1372: goto tr1525;
	case 1373: goto tr1525;
	case 1374: goto tr1525;
	case 1375: goto tr1525;
	case 602: goto tr188;
	case 603: goto tr188;
	case 1376: goto tr1813;
	case 1377: goto tr1525;
	case 1378: goto tr1525;
	case 1379: goto tr1525;
	case 1380: goto tr1525;
	case 604: goto tr188;
	case 605: goto tr188;
	case 1381: goto tr1819;
	case 1382: goto tr1525;
	case 1383: goto tr1525;
	case 1384: goto tr1525;
	case 1385: goto tr1525;
	case 606: goto tr188;
	case 607: goto tr188;
	case 1386: goto tr1825;
	case 1387: goto tr1525;
	case 1388: goto tr1525;
	case 1389: goto tr1525;
	case 1390: goto tr1525;
	case 1391: goto tr1525;
	case 1392: goto tr1525;
	case 1393: goto tr1525;
	case 608: goto tr188;
	case 609: goto tr188;
	case 1394: goto tr1834;
	case 1395: goto tr1524;
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
	case 1396: goto tr1847;
	case 623: goto tr780;
	case 624: goto tr780;
	case 1397: goto tr1848;
	case 625: goto tr784;
	case 626: goto tr784;
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
	case 1398: goto tr1849;
	case 656: goto tr823;
	case 657: goto tr823;
	case 658: goto tr193;
	case 659: goto tr193;
	case 660: goto tr193;
	case 661: goto tr193;
	case 662: goto tr193;
	case 663: goto tr193;
	case 664: goto tr193;
	case 665: goto tr193;
	case 666: goto tr193;
	case 667: goto tr193;
	case 668: goto tr193;
	case 669: goto tr193;
	case 670: goto tr193;
	case 671: goto tr193;
	case 672: goto tr193;
	case 673: goto tr193;
	case 674: goto tr193;
	case 675: goto tr193;
	case 676: goto tr193;
	case 677: goto tr193;
	case 678: goto tr193;
	case 679: goto tr193;
	case 680: goto tr193;
	case 681: goto tr193;
	case 682: goto tr193;
	case 683: goto tr193;
	case 684: goto tr193;
	case 685: goto tr193;
	case 686: goto tr193;
	case 687: goto tr193;
	case 688: goto tr193;
	case 689: goto tr193;
	case 690: goto tr193;
	case 691: goto tr193;
	case 692: goto tr193;
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
	case 703: goto tr193;
	case 704: goto tr193;
	case 705: goto tr193;
	case 706: goto tr193;
	case 707: goto tr193;
	case 708: goto tr193;
	case 709: goto tr193;
	case 710: goto tr193;
	case 711: goto tr193;
	case 712: goto tr193;
	case 713: goto tr193;
	case 714: goto tr193;
	case 715: goto tr193;
	case 716: goto tr193;
	case 717: goto tr193;
	case 718: goto tr193;
	case 719: goto tr193;
	case 720: goto tr193;
	case 721: goto tr193;
	case 722: goto tr193;
	case 723: goto tr193;
	case 724: goto tr193;
	case 725: goto tr193;
	case 726: goto tr193;
	case 727: goto tr193;
	case 728: goto tr193;
	case 729: goto tr193;
	case 730: goto tr193;
	case 731: goto tr193;
	case 732: goto tr193;
	case 733: goto tr193;
	case 734: goto tr193;
	case 735: goto tr193;
	case 736: goto tr193;
	case 737: goto tr193;
	case 1399: goto tr1524;
	case 1400: goto tr1524;
	case 738: goto tr193;
	case 739: goto tr193;
	case 740: goto tr193;
	case 741: goto tr193;
	case 742: goto tr193;
	case 743: goto tr193;
	case 744: goto tr193;
	case 745: goto tr193;
	case 746: goto tr193;
	case 747: goto tr193;
	case 748: goto tr193;
	case 749: goto tr193;
	case 750: goto tr193;
	case 751: goto tr193;
	case 752: goto tr193;
	case 753: goto tr193;
	case 754: goto tr193;
	case 755: goto tr193;
	case 756: goto tr193;
	case 757: goto tr193;
	case 758: goto tr193;
	case 759: goto tr193;
	case 760: goto tr193;
	case 761: goto tr193;
	case 762: goto tr193;
	case 763: goto tr193;
	case 764: goto tr193;
	case 765: goto tr193;
	case 766: goto tr193;
	case 767: goto tr193;
	case 768: goto tr193;
	case 769: goto tr193;
	case 770: goto tr193;
	case 771: goto tr193;
	case 772: goto tr193;
	case 773: goto tr193;
	case 774: goto tr193;
	case 775: goto tr193;
	case 776: goto tr193;
	case 777: goto tr193;
	case 778: goto tr193;
	case 779: goto tr193;
	case 780: goto tr193;
	case 781: goto tr193;
	case 782: goto tr193;
	case 783: goto tr193;
	case 784: goto tr193;
	case 785: goto tr193;
	case 786: goto tr193;
	case 787: goto tr193;
	case 788: goto tr193;
	case 789: goto tr193;
	case 790: goto tr193;
	case 791: goto tr193;
	case 792: goto tr193;
	case 793: goto tr193;
	case 794: goto tr193;
	case 795: goto tr193;
	case 796: goto tr193;
	case 797: goto tr193;
	case 798: goto tr193;
	case 799: goto tr193;
	case 800: goto tr193;
	case 801: goto tr193;
	case 802: goto tr193;
	case 803: goto tr193;
	case 804: goto tr193;
	case 805: goto tr193;
	case 806: goto tr193;
	case 807: goto tr193;
	case 808: goto tr193;
	case 809: goto tr193;
	case 810: goto tr193;
	case 811: goto tr193;
	case 812: goto tr193;
	case 813: goto tr193;
	case 814: goto tr193;
	case 815: goto tr193;
	case 816: goto tr193;
	case 817: goto tr193;
	case 818: goto tr193;
	case 819: goto tr193;
	case 820: goto tr193;
	case 821: goto tr193;
	case 822: goto tr193;
	case 823: goto tr193;
	case 824: goto tr193;
	case 825: goto tr193;
	case 826: goto tr193;
	case 827: goto tr193;
	case 828: goto tr193;
	case 829: goto tr193;
	case 830: goto tr193;
	case 1401: goto tr1524;
	case 831: goto tr193;
	case 832: goto tr193;
	case 1402: goto tr1524;
	case 833: goto tr193;
	case 834: goto tr185;
	case 835: goto tr185;
	case 836: goto tr185;
	case 1403: goto tr1869;
	case 837: goto tr185;
	case 838: goto tr185;
	case 839: goto tr185;
	case 840: goto tr185;
	case 841: goto tr185;
	case 842: goto tr185;
	case 843: goto tr185;
	case 844: goto tr185;
	case 845: goto tr185;
	case 846: goto tr185;
	case 1404: goto tr1869;
	case 847: goto tr185;
	case 848: goto tr185;
	case 849: goto tr185;
	case 850: goto tr185;
	case 851: goto tr185;
	case 852: goto tr185;
	case 853: goto tr185;
	case 854: goto tr185;
	case 855: goto tr185;
	case 856: goto tr185;
	case 857: goto tr193;
	case 858: goto tr193;
	case 859: goto tr193;
	case 860: goto tr193;
	case 861: goto tr193;
	case 862: goto tr193;
	case 863: goto tr193;
	case 864: goto tr193;
	case 865: goto tr193;
	case 866: goto tr193;
	case 1406: goto tr1876;
	case 867: goto tr1049;
	case 868: goto tr1049;
	case 869: goto tr1049;
	case 870: goto tr1049;
	case 871: goto tr1049;
	case 872: goto tr1049;
	case 873: goto tr1049;
	case 874: goto tr1049;
	case 875: goto tr1049;
	case 876: goto tr1049;
	case 877: goto tr1049;
	case 878: goto tr1049;
	case 1407: goto tr1876;
	case 879: goto tr1049;
	case 1408: goto tr1876;
	case 1409: goto tr1876;
	case 1411: goto tr1884;
	case 880: goto tr1063;
	case 881: goto tr1063;
	case 882: goto tr1063;
	case 883: goto tr1063;
	case 884: goto tr1063;
	case 885: goto tr1063;
	case 886: goto tr1063;
	case 887: goto tr1063;
	case 888: goto tr1063;
	case 889: goto tr1063;
	case 890: goto tr1063;
	case 891: goto tr1063;
	case 892: goto tr1063;
	case 893: goto tr1063;
	case 894: goto tr1063;
	case 895: goto tr1063;
	case 896: goto tr1063;
	case 897: goto tr1063;
	case 1412: goto tr1884;
	case 898: goto tr1063;
	case 1413: goto tr1884;
	case 1414: goto tr1884;
	case 1416: goto tr1889;
	case 899: goto tr1083;
	case 900: goto tr1083;
	case 901: goto tr1083;
	case 902: goto tr1083;
	case 903: goto tr1083;
	case 904: goto tr1083;
	case 905: goto tr1083;
	case 906: goto tr1083;
	case 907: goto tr1083;
	case 908: goto tr1083;
	case 909: goto tr1083;
	case 910: goto tr1083;
	case 911: goto tr1083;
	case 912: goto tr1083;
	case 913: goto tr1083;
	case 914: goto tr1083;
	case 915: goto tr1083;
	case 916: goto tr1083;
	case 917: goto tr1083;
	case 918: goto tr1083;
	case 919: goto tr1083;
	case 920: goto tr1083;
	case 921: goto tr1083;
	case 922: goto tr1083;
	case 923: goto tr1083;
	case 924: goto tr1083;
	case 925: goto tr1083;
	case 926: goto tr1083;
	case 927: goto tr1083;
	case 928: goto tr1083;
	case 929: goto tr1083;
	case 930: goto tr1083;
	case 931: goto tr1083;
	case 932: goto tr1083;
	case 933: goto tr1083;
	case 934: goto tr1083;
	case 935: goto tr1083;
	case 936: goto tr1083;
	case 937: goto tr1083;
	case 938: goto tr1083;
	case 939: goto tr1083;
	case 940: goto tr1083;
	case 941: goto tr1083;
	case 942: goto tr1083;
	case 943: goto tr1083;
	case 944: goto tr1083;
	case 945: goto tr1083;
	case 946: goto tr1083;
	case 947: goto tr1083;
	case 948: goto tr1083;
	case 949: goto tr1083;
	case 950: goto tr1083;
	case 951: goto tr1083;
	case 952: goto tr1083;
	case 953: goto tr1083;
	case 954: goto tr1083;
	case 955: goto tr1083;
	case 956: goto tr1083;
	case 957: goto tr1083;
	case 958: goto tr1083;
	case 959: goto tr1083;
	case 960: goto tr1083;
	case 961: goto tr1083;
	case 962: goto tr1083;
	case 963: goto tr1083;
	case 964: goto tr1083;
	case 965: goto tr1083;
	case 966: goto tr1083;
	case 967: goto tr1083;
	case 968: goto tr1083;
	case 969: goto tr1083;
	case 970: goto tr1083;
	case 971: goto tr1083;
	case 972: goto tr1083;
	case 973: goto tr1083;
	case 974: goto tr1083;
	case 975: goto tr1083;
	case 976: goto tr1083;
	case 977: goto tr1083;
	case 978: goto tr1083;
	case 979: goto tr1083;
	case 980: goto tr1083;
	case 981: goto tr1083;
	case 982: goto tr1083;
	case 983: goto tr1083;
	case 984: goto tr1083;
	case 985: goto tr1083;
	case 986: goto tr1083;
	case 987: goto tr1083;
	case 988: goto tr1083;
	case 989: goto tr1083;
	case 990: goto tr1083;
	case 991: goto tr1083;
	case 992: goto tr1083;
	case 993: goto tr1083;
	case 994: goto tr1083;
	case 995: goto tr1083;
	case 996: goto tr1083;
	case 997: goto tr1083;
	case 998: goto tr1083;
	case 999: goto tr1083;
	case 1000: goto tr1083;
	case 1001: goto tr1083;
	case 1002: goto tr1083;
	case 1003: goto tr1083;
	case 1004: goto tr1083;
	case 1005: goto tr1083;
	case 1006: goto tr1083;
	case 1007: goto tr1083;
	case 1008: goto tr1083;
	case 1009: goto tr1083;
	case 1010: goto tr1083;
	case 1417: goto tr1889;
	case 1011: goto tr1083;
	case 1012: goto tr1083;
	case 1013: goto tr1083;
	case 1014: goto tr1083;
	case 1015: goto tr1083;
	case 1016: goto tr1083;
	case 1017: goto tr1083;
	case 1018: goto tr1083;
	case 1019: goto tr1083;
	case 1020: goto tr1083;
	case 1021: goto tr1083;
	case 1022: goto tr1083;
	case 1023: goto tr1083;
	case 1024: goto tr1083;
	case 1025: goto tr1083;
	case 1026: goto tr1083;
	case 1027: goto tr1083;
	case 1028: goto tr1083;
	case 1029: goto tr1083;
	case 1030: goto tr1083;
	case 1031: goto tr1083;
	case 1032: goto tr1083;
	case 1033: goto tr1083;
	case 1034: goto tr1083;
	case 1035: goto tr1083;
	case 1036: goto tr1083;
	case 1037: goto tr1083;
	case 1038: goto tr1083;
	case 1039: goto tr1083;
	case 1040: goto tr1083;
	case 1041: goto tr1083;
	case 1042: goto tr1083;
	case 1043: goto tr1083;
	case 1044: goto tr1083;
	case 1045: goto tr1083;
	case 1046: goto tr1083;
	case 1047: goto tr1083;
	case 1048: goto tr1083;
	case 1049: goto tr1083;
	case 1050: goto tr1083;
	case 1051: goto tr1083;
	case 1052: goto tr1083;
	case 1053: goto tr1083;
	case 1054: goto tr1083;
	case 1055: goto tr1083;
	case 1056: goto tr1083;
	case 1057: goto tr1083;
	case 1058: goto tr1083;
	case 1059: goto tr1083;
	case 1060: goto tr1083;
	case 1061: goto tr1083;
	case 1062: goto tr1083;
	case 1063: goto tr1083;
	case 1064: goto tr1083;
	case 1065: goto tr1083;
	case 1066: goto tr1083;
	case 1067: goto tr1083;
	case 1068: goto tr1083;
	case 1069: goto tr1083;
	case 1070: goto tr1083;
	case 1071: goto tr1083;
	case 1072: goto tr1083;
	case 1073: goto tr1083;
	case 1074: goto tr1083;
	case 1075: goto tr1083;
	case 1076: goto tr1083;
	case 1077: goto tr1083;
	case 1078: goto tr1083;
	case 1079: goto tr1083;
	case 1080: goto tr1083;
	case 1081: goto tr1083;
	case 1082: goto tr1083;
	case 1083: goto tr1083;
	case 1084: goto tr1083;
	case 1085: goto tr1083;
	case 1086: goto tr1083;
	case 1087: goto tr1083;
	case 1088: goto tr1083;
	case 1089: goto tr1083;
	case 1090: goto tr1083;
	case 1091: goto tr1083;
	case 1092: goto tr1083;
	case 1093: goto tr1083;
	case 1094: goto tr1083;
	case 1095: goto tr1083;
	case 1096: goto tr1083;
	case 1097: goto tr1083;
	case 1098: goto tr1083;
	case 1099: goto tr1083;
	case 1100: goto tr1083;
	case 1101: goto tr1083;
	case 1102: goto tr1083;
	case 1103: goto tr1083;
	case 1104: goto tr1083;
	case 1105: goto tr1083;
	case 1106: goto tr1083;
	case 1107: goto tr1083;
	case 1108: goto tr1083;
	case 1109: goto tr1083;
	case 1110: goto tr1083;
	case 1111: goto tr1083;
	case 1112: goto tr1083;
	case 1113: goto tr1083;
	case 1114: goto tr1083;
	case 1115: goto tr1083;
	case 1116: goto tr1083;
	case 1117: goto tr1083;
	case 1118: goto tr1083;
	case 1119: goto tr1083;
	case 1120: goto tr1083;
	case 1121: goto tr1083;
	case 1122: goto tr1083;
	}
	}

	_out: {}
	}

#line 1441 "ext/dtext/dtext.cpp.rl"

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
