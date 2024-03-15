
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


#line 757 "ext/dtext/dtext.cpp.rl"



#line 47 "ext/dtext/dtext.cpp"
static const int dtext_start = 1306;
static const int dtext_first_final = 1306;
static const int dtext_error = 0;

static const int dtext_en_basic_inline = 1325;
static const int dtext_en_inline = 1328;
static const int dtext_en_code = 1605;
static const int dtext_en_nodtext = 1609;
static const int dtext_en_table = 1613;
static const int dtext_en_main = 1306;


#line 760 "ext/dtext/dtext.cpp.rl"

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
    append_block(sm, "<pre class=\"language-");
    append_html_escaped(sm, language);
    append_block(sm, "\">");
    append_html_escaped(sm, code);
    append_block(sm, "</pre>");
  }
}

static void append_inline_code(StateMachine * sm, const std::string_view language = {}) {
  if (language.empty()) {
    dstack_open_element(sm, INLINE_CODE, "<code>");
  } else {
    dstack_open_element(sm, INLINE_CODE, "<code class=\"language-");
    append_html_escaped(sm, language);
    append(sm, "\">");
  }
}

static void append_block_code(StateMachine * sm, const std::string_view language = {}) {
  dstack_close_leaf_blocks(sm);

  if (language.empty()) {
    dstack_open_element(sm, BLOCK_CODE, "<pre>");
  } else {
    dstack_open_element(sm, BLOCK_CODE, "<pre class=\"language-");
    append_html_escaped(sm, language);
    append(sm, "\">");
  }
}

static void append_header(StateMachine * sm, char header, const std::string_view id) {
  static element_t blocks[] = { BLOCK_H1, BLOCK_H2, BLOCK_H3, BLOCK_H4, BLOCK_H5, BLOCK_H6 };
  element_t block = blocks[header - '1'];

  if (id.empty()) {
    dstack_open_element(sm, block, "<h");
    append_block(sm, header);
    append_block(sm, ">");
  } else {
    auto normalized_id = std::string(id);
    std::transform(id.begin(), id.end(), normalized_id.begin(), [](char c) { return isalnum(c) ? tolower(c) : '-'; });

    dstack_open_element(sm, block, "<h");
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

static void dstack_open_element(StateMachine * sm, element_t type, const char * html) {
  g_debug("opening %s", html);

  dstack_push(sm, type);

  if (type >= INLINE) {
    append(sm, html);
  } else {
    append_block(sm, html);
  }
}

static void dstack_open_element(StateMachine * sm, element_t type, std::string_view tag_name, const StateMachine::TagAttributes& tag_attributes) {
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

static bool dstack_close_element(StateMachine * sm, element_t type) {
  if (dstack_check(sm, type)) {
    dstack_rewind(sm);
    return true;
  } else if (type >= INLINE && dstack_peek(sm) >= INLINE) {
    g_debug("out-of-order close %s; closing %s instead", element_names[type], element_names[dstack_peek(sm)]);
    dstack_rewind(sm);
    return true;
  } else if (type >= INLINE) {
    g_debug("out-of-order closing %s", element_names[type]);
    append_html_escaped(sm, { sm->ts, sm->te });
    return false;
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
    case BLOCK_H6: append_block(sm, "</h6>"); sm->header_mode = false; break;
    case BLOCK_H5: append_block(sm, "</h5>"); sm->header_mode = false; break;
    case BLOCK_H4: append_block(sm, "</h4>"); sm->header_mode = false; break;
    case BLOCK_H3: append_block(sm, "</h3>"); sm->header_mode = false; break;
    case BLOCK_H2: append_block(sm, "</h2>"); sm->header_mode = false; break;
    case BLOCK_H1: append_block(sm, "</h1>"); sm->header_mode = false; break;

    // Should never happen.
    case INLINE: break;
    case DSTACK_EMPTY: break;
  } 
}

// container blocks: [spoiler], [quote], [expand], [tn]
// leaf blocks: [nodtext], [code], [table], [td]?, [th]?, <h1>, <p>, <li>, <ul>
static void dstack_close_leaf_blocks(StateMachine * sm) {
  g_debug("dstack close leaf blocks");

  while (!sm->dstack.empty() && !dstack_check(sm, BLOCK_QUOTE) && !dstack_check(sm, BLOCK_SPOILER) && !dstack_check(sm, BLOCK_EXPAND) && !dstack_check(sm, BLOCK_TN)) {
    dstack_rewind(sm);
  }
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
    dstack_open_element(sm, BLOCK_UL, "<ul>");
  }

  while (dstack_count(sm, BLOCK_UL) > depth) {
    dstack_close_until(sm, BLOCK_UL);
  }

  dstack_open_element(sm, BLOCK_LI, "<li>");
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
  sm->f1 = NULL;
  sm->f2 = NULL;
  sm->g1 = NULL;
  sm->g2 = NULL;
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
  StateMachine* sm = this;
  g_debug("parse '%.*s'", (int)(sm->input.size() - 2), sm->input.c_str() + 1);

  
#line 750 "ext/dtext/dtext.cpp"
	{
	( sm->top) = 0;
	( sm->ts) = 0;
	( sm->te) = 0;
	( sm->act) = 0;
	}

#line 1453 "ext/dtext/dtext.cpp.rl"
  
#line 756 "ext/dtext/dtext.cpp"
	{
	short _widec;
	if ( ( sm->p) == ( sm->pe) )
		goto _test_eof;
	goto _resume;

_again:
	switch (  sm->cs ) {
		case 1306: goto st1306;
		case 1307: goto st1307;
		case 1: goto st1;
		case 1308: goto st1308;
		case 2: goto st2;
		case 3: goto st3;
		case 4: goto st4;
		case 5: goto st5;
		case 6: goto st6;
		case 1309: goto st1309;
		case 7: goto st7;
		case 8: goto st8;
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
		case 1310: goto st1310;
		case 20: goto st20;
		case 1311: goto st1311;
		case 1312: goto st1312;
		case 21: goto st21;
		case 1313: goto st1313;
		case 22: goto st22;
		case 23: goto st23;
		case 24: goto st24;
		case 25: goto st25;
		case 26: goto st26;
		case 27: goto st27;
		case 28: goto st28;
		case 29: goto st29;
		case 30: goto st30;
		case 31: goto st31;
		case 1314: goto st1314;
		case 32: goto st32;
		case 33: goto st33;
		case 34: goto st34;
		case 35: goto st35;
		case 36: goto st36;
		case 37: goto st37;
		case 38: goto st38;
		case 1315: goto st1315;
		case 39: goto st39;
		case 1316: goto st1316;
		case 40: goto st40;
		case 41: goto st41;
		case 42: goto st42;
		case 43: goto st43;
		case 44: goto st44;
		case 45: goto st45;
		case 46: goto st46;
		case 47: goto st47;
		case 48: goto st48;
		case 1317: goto st1317;
		case 49: goto st49;
		case 1318: goto st1318;
		case 50: goto st50;
		case 51: goto st51;
		case 52: goto st52;
		case 53: goto st53;
		case 54: goto st54;
		case 55: goto st55;
		case 56: goto st56;
		case 1319: goto st1319;
		case 57: goto st57;
		case 58: goto st58;
		case 59: goto st59;
		case 60: goto st60;
		case 61: goto st61;
		case 62: goto st62;
		case 63: goto st63;
		case 64: goto st64;
		case 1320: goto st1320;
		case 65: goto st65;
		case 66: goto st66;
		case 67: goto st67;
		case 1321: goto st1321;
		case 68: goto st68;
		case 69: goto st69;
		case 70: goto st70;
		case 1322: goto st1322;
		case 1323: goto st1323;
		case 71: goto st71;
		case 72: goto st72;
		case 73: goto st73;
		case 74: goto st74;
		case 75: goto st75;
		case 76: goto st76;
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
		case 1324: goto st1324;
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
		case 1325: goto st1325;
		case 1326: goto st1326;
		case 119: goto st119;
		case 120: goto st120;
		case 121: goto st121;
		case 122: goto st122;
		case 123: goto st123;
		case 124: goto st124;
		case 125: goto st125;
		case 126: goto st126;
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
		case 1327: goto st1327;
		case 138: goto st138;
		case 139: goto st139;
		case 140: goto st140;
		case 141: goto st141;
		case 142: goto st142;
		case 143: goto st143;
		case 144: goto st144;
		case 145: goto st145;
		case 146: goto st146;
		case 1328: goto st1328;
		case 1329: goto st1329;
		case 1330: goto st1330;
		case 147: goto st147;
		case 148: goto st148;
		case 149: goto st149;
		case 1331: goto st1331;
		case 1332: goto st1332;
		case 1333: goto st1333;
		case 150: goto st150;
		case 1334: goto st1334;
		case 151: goto st151;
		case 1335: goto st1335;
		case 152: goto st152;
		case 153: goto st153;
		case 154: goto st154;
		case 155: goto st155;
		case 156: goto st156;
		case 1336: goto st1336;
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
		case 1337: goto st1337;
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
		case 199: goto st199;
		case 200: goto st200;
		case 1338: goto st1338;
		case 1339: goto st1339;
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
		case 1340: goto st1340;
		case 213: goto st213;
		case 214: goto st214;
		case 215: goto st215;
		case 216: goto st216;
		case 217: goto st217;
		case 218: goto st218;
		case 1341: goto st1341;
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
		case 242: goto st242;
		case 243: goto st243;
		case 244: goto st244;
		case 245: goto st245;
		case 246: goto st246;
		case 247: goto st247;
		case 248: goto st248;
		case 249: goto st249;
		case 1342: goto st1342;
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
		case 1343: goto st1343;
		case 291: goto st291;
		case 292: goto st292;
		case 293: goto st293;
		case 1344: goto st1344;
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
		case 1345: goto st1345;
		case 305: goto st305;
		case 306: goto st306;
		case 307: goto st307;
		case 308: goto st308;
		case 309: goto st309;
		case 310: goto st310;
		case 311: goto st311;
		case 312: goto st312;
		case 313: goto st313;
		case 314: goto st314;
		case 315: goto st315;
		case 316: goto st316;
		case 317: goto st317;
		case 1346: goto st1346;
		case 318: goto st318;
		case 319: goto st319;
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
		case 333: goto st333;
		case 334: goto st334;
		case 335: goto st335;
		case 336: goto st336;
		case 337: goto st337;
		case 338: goto st338;
		case 339: goto st339;
		case 1347: goto st1347;
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
		case 1348: goto st1348;
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
		case 1349: goto st1349;
		case 362: goto st362;
		case 363: goto st363;
		case 364: goto st364;
		case 365: goto st365;
		case 366: goto st366;
		case 367: goto st367;
		case 368: goto st368;
		case 369: goto st369;
		case 370: goto st370;
		case 1350: goto st1350;
		case 1351: goto st1351;
		case 371: goto st371;
		case 372: goto st372;
		case 373: goto st373;
		case 374: goto st374;
		case 1352: goto st1352;
		case 1353: goto st1353;
		case 375: goto st375;
		case 376: goto st376;
		case 377: goto st377;
		case 378: goto st378;
		case 379: goto st379;
		case 380: goto st380;
		case 381: goto st381;
		case 382: goto st382;
		case 383: goto st383;
		case 1354: goto st1354;
		case 1355: goto st1355;
		case 384: goto st384;
		case 385: goto st385;
		case 386: goto st386;
		case 387: goto st387;
		case 388: goto st388;
		case 389: goto st389;
		case 390: goto st390;
		case 391: goto st391;
		case 392: goto st392;
		case 393: goto st393;
		case 394: goto st394;
		case 395: goto st395;
		case 396: goto st396;
		case 397: goto st397;
		case 398: goto st398;
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
		case 1356: goto st1356;
		case 1357: goto st1357;
		case 427: goto st427;
		case 1358: goto st1358;
		case 1359: goto st1359;
		case 428: goto st428;
		case 429: goto st429;
		case 430: goto st430;
		case 431: goto st431;
		case 432: goto st432;
		case 433: goto st433;
		case 434: goto st434;
		case 435: goto st435;
		case 1360: goto st1360;
		case 1361: goto st1361;
		case 436: goto st436;
		case 1362: goto st1362;
		case 437: goto st437;
		case 438: goto st438;
		case 439: goto st439;
		case 440: goto st440;
		case 441: goto st441;
		case 442: goto st442;
		case 443: goto st443;
		case 444: goto st444;
		case 445: goto st445;
		case 446: goto st446;
		case 447: goto st447;
		case 448: goto st448;
		case 449: goto st449;
		case 450: goto st450;
		case 451: goto st451;
		case 452: goto st452;
		case 453: goto st453;
		case 454: goto st454;
		case 1363: goto st1363;
		case 455: goto st455;
		case 456: goto st456;
		case 457: goto st457;
		case 458: goto st458;
		case 459: goto st459;
		case 460: goto st460;
		case 461: goto st461;
		case 462: goto st462;
		case 463: goto st463;
		case 0: goto st0;
		case 1364: goto st1364;
		case 1365: goto st1365;
		case 1366: goto st1366;
		case 1367: goto st1367;
		case 1368: goto st1368;
		case 464: goto st464;
		case 465: goto st465;
		case 1369: goto st1369;
		case 1370: goto st1370;
		case 1371: goto st1371;
		case 1372: goto st1372;
		case 1373: goto st1373;
		case 1374: goto st1374;
		case 466: goto st466;
		case 467: goto st467;
		case 1375: goto st1375;
		case 1376: goto st1376;
		case 1377: goto st1377;
		case 1378: goto st1378;
		case 1379: goto st1379;
		case 1380: goto st1380;
		case 468: goto st468;
		case 469: goto st469;
		case 1381: goto st1381;
		case 1382: goto st1382;
		case 1383: goto st1383;
		case 1384: goto st1384;
		case 1385: goto st1385;
		case 1386: goto st1386;
		case 1387: goto st1387;
		case 1388: goto st1388;
		case 470: goto st470;
		case 471: goto st471;
		case 1389: goto st1389;
		case 1390: goto st1390;
		case 1391: goto st1391;
		case 1392: goto st1392;
		case 1393: goto st1393;
		case 472: goto st472;
		case 473: goto st473;
		case 1394: goto st1394;
		case 1395: goto st1395;
		case 1396: goto st1396;
		case 1397: goto st1397;
		case 474: goto st474;
		case 475: goto st475;
		case 1398: goto st1398;
		case 1399: goto st1399;
		case 1400: goto st1400;
		case 476: goto st476;
		case 477: goto st477;
		case 1401: goto st1401;
		case 1402: goto st1402;
		case 1403: goto st1403;
		case 1404: goto st1404;
		case 1405: goto st1405;
		case 1406: goto st1406;
		case 1407: goto st1407;
		case 1408: goto st1408;
		case 478: goto st478;
		case 479: goto st479;
		case 1409: goto st1409;
		case 1410: goto st1410;
		case 1411: goto st1411;
		case 480: goto st480;
		case 481: goto st481;
		case 1412: goto st1412;
		case 1413: goto st1413;
		case 1414: goto st1414;
		case 1415: goto st1415;
		case 1416: goto st1416;
		case 1417: goto st1417;
		case 1418: goto st1418;
		case 1419: goto st1419;
		case 1420: goto st1420;
		case 1421: goto st1421;
		case 1422: goto st1422;
		case 482: goto st482;
		case 483: goto st483;
		case 1423: goto st1423;
		case 1424: goto st1424;
		case 1425: goto st1425;
		case 1426: goto st1426;
		case 1427: goto st1427;
		case 484: goto st484;
		case 485: goto st485;
		case 1428: goto st1428;
		case 486: goto st486;
		case 1429: goto st1429;
		case 1430: goto st1430;
		case 1431: goto st1431;
		case 1432: goto st1432;
		case 1433: goto st1433;
		case 1434: goto st1434;
		case 1435: goto st1435;
		case 1436: goto st1436;
		case 1437: goto st1437;
		case 487: goto st487;
		case 488: goto st488;
		case 1438: goto st1438;
		case 1439: goto st1439;
		case 1440: goto st1440;
		case 1441: goto st1441;
		case 1442: goto st1442;
		case 1443: goto st1443;
		case 1444: goto st1444;
		case 1445: goto st1445;
		case 489: goto st489;
		case 490: goto st490;
		case 1446: goto st1446;
		case 1447: goto st1447;
		case 1448: goto st1448;
		case 1449: goto st1449;
		case 491: goto st491;
		case 492: goto st492;
		case 1450: goto st1450;
		case 1451: goto st1451;
		case 1452: goto st1452;
		case 1453: goto st1453;
		case 1454: goto st1454;
		case 493: goto st493;
		case 494: goto st494;
		case 1455: goto st1455;
		case 1456: goto st1456;
		case 1457: goto st1457;
		case 1458: goto st1458;
		case 1459: goto st1459;
		case 1460: goto st1460;
		case 1461: goto st1461;
		case 1462: goto st1462;
		case 1463: goto st1463;
		case 495: goto st495;
		case 496: goto st496;
		case 1464: goto st1464;
		case 1465: goto st1465;
		case 1466: goto st1466;
		case 1467: goto st1467;
		case 1468: goto st1468;
		case 497: goto st497;
		case 498: goto st498;
		case 499: goto st499;
		case 500: goto st500;
		case 501: goto st501;
		case 502: goto st502;
		case 503: goto st503;
		case 504: goto st504;
		case 505: goto st505;
		case 1469: goto st1469;
		case 506: goto st506;
		case 507: goto st507;
		case 508: goto st508;
		case 509: goto st509;
		case 510: goto st510;
		case 511: goto st511;
		case 512: goto st512;
		case 513: goto st513;
		case 514: goto st514;
		case 515: goto st515;
		case 1470: goto st1470;
		case 516: goto st516;
		case 517: goto st517;
		case 518: goto st518;
		case 519: goto st519;
		case 520: goto st520;
		case 521: goto st521;
		case 522: goto st522;
		case 523: goto st523;
		case 524: goto st524;
		case 525: goto st525;
		case 526: goto st526;
		case 1471: goto st1471;
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
		case 1472: goto st1472;
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
		case 1473: goto st1473;
		case 1474: goto st1474;
		case 1475: goto st1475;
		case 1476: goto st1476;
		case 1477: goto st1477;
		case 1478: goto st1478;
		case 1479: goto st1479;
		case 1480: goto st1480;
		case 1481: goto st1481;
		case 1482: goto st1482;
		case 1483: goto st1483;
		case 1484: goto st1484;
		case 1485: goto st1485;
		case 550: goto st550;
		case 551: goto st551;
		case 1486: goto st1486;
		case 1487: goto st1487;
		case 1488: goto st1488;
		case 1489: goto st1489;
		case 1490: goto st1490;
		case 552: goto st552;
		case 553: goto st553;
		case 1491: goto st1491;
		case 1492: goto st1492;
		case 1493: goto st1493;
		case 1494: goto st1494;
		case 1495: goto st1495;
		case 1496: goto st1496;
		case 554: goto st554;
		case 555: goto st555;
		case 556: goto st556;
		case 557: goto st557;
		case 558: goto st558;
		case 559: goto st559;
		case 560: goto st560;
		case 561: goto st561;
		case 1497: goto st1497;
		case 1498: goto st1498;
		case 1499: goto st1499;
		case 562: goto st562;
		case 563: goto st563;
		case 564: goto st564;
		case 565: goto st565;
		case 566: goto st566;
		case 567: goto st567;
		case 568: goto st568;
		case 569: goto st569;
		case 570: goto st570;
		case 1500: goto st1500;
		case 1501: goto st1501;
		case 1502: goto st1502;
		case 1503: goto st1503;
		case 1504: goto st1504;
		case 1505: goto st1505;
		case 1506: goto st1506;
		case 571: goto st571;
		case 572: goto st572;
		case 1507: goto st1507;
		case 1508: goto st1508;
		case 1509: goto st1509;
		case 1510: goto st1510;
		case 1511: goto st1511;
		case 1512: goto st1512;
		case 573: goto st573;
		case 574: goto st574;
		case 1513: goto st1513;
		case 1514: goto st1514;
		case 1515: goto st1515;
		case 1516: goto st1516;
		case 575: goto st575;
		case 576: goto st576;
		case 1517: goto st1517;
		case 1518: goto st1518;
		case 1519: goto st1519;
		case 1520: goto st1520;
		case 1521: goto st1521;
		case 1522: goto st1522;
		case 577: goto st577;
		case 578: goto st578;
		case 1523: goto st1523;
		case 1524: goto st1524;
		case 1525: goto st1525;
		case 1526: goto st1526;
		case 1527: goto st1527;
		case 579: goto st579;
		case 580: goto st580;
		case 1528: goto st1528;
		case 581: goto st581;
		case 582: goto st582;
		case 1529: goto st1529;
		case 1530: goto st1530;
		case 1531: goto st1531;
		case 1532: goto st1532;
		case 583: goto st583;
		case 584: goto st584;
		case 1533: goto st1533;
		case 1534: goto st1534;
		case 1535: goto st1535;
		case 585: goto st585;
		case 586: goto st586;
		case 1536: goto st1536;
		case 1537: goto st1537;
		case 1538: goto st1538;
		case 1539: goto st1539;
		case 587: goto st587;
		case 588: goto st588;
		case 1540: goto st1540;
		case 1541: goto st1541;
		case 1542: goto st1542;
		case 1543: goto st1543;
		case 1544: goto st1544;
		case 1545: goto st1545;
		case 1546: goto st1546;
		case 1547: goto st1547;
		case 589: goto st589;
		case 590: goto st590;
		case 1548: goto st1548;
		case 1549: goto st1549;
		case 1550: goto st1550;
		case 1551: goto st1551;
		case 1552: goto st1552;
		case 591: goto st591;
		case 592: goto st592;
		case 1553: goto st1553;
		case 1554: goto st1554;
		case 1555: goto st1555;
		case 1556: goto st1556;
		case 1557: goto st1557;
		case 1558: goto st1558;
		case 593: goto st593;
		case 594: goto st594;
		case 1559: goto st1559;
		case 595: goto st595;
		case 596: goto st596;
		case 1560: goto st1560;
		case 1561: goto st1561;
		case 1562: goto st1562;
		case 1563: goto st1563;
		case 1564: goto st1564;
		case 1565: goto st1565;
		case 1566: goto st1566;
		case 597: goto st597;
		case 598: goto st598;
		case 1567: goto st1567;
		case 1568: goto st1568;
		case 1569: goto st1569;
		case 1570: goto st1570;
		case 1571: goto st1571;
		case 599: goto st599;
		case 600: goto st600;
		case 1572: goto st1572;
		case 1573: goto st1573;
		case 1574: goto st1574;
		case 1575: goto st1575;
		case 1576: goto st1576;
		case 601: goto st601;
		case 602: goto st602;
		case 1577: goto st1577;
		case 1578: goto st1578;
		case 1579: goto st1579;
		case 1580: goto st1580;
		case 1581: goto st1581;
		case 1582: goto st1582;
		case 1583: goto st1583;
		case 1584: goto st1584;
		case 603: goto st603;
		case 604: goto st604;
		case 1585: goto st1585;
		case 1586: goto st1586;
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
		case 1587: goto st1587;
		case 677: goto st677;
		case 1588: goto st1588;
		case 678: goto st678;
		case 679: goto st679;
		case 680: goto st680;
		case 681: goto st681;
		case 682: goto st682;
		case 683: goto st683;
		case 684: goto st684;
		case 685: goto st685;
		case 686: goto st686;
		case 1589: goto st1589;
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
		case 1590: goto st1590;
		case 710: goto st710;
		case 711: goto st711;
		case 712: goto st712;
		case 713: goto st713;
		case 1591: goto st1591;
		case 714: goto st714;
		case 715: goto st715;
		case 1592: goto st1592;
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
		case 1593: goto st1593;
		case 733: goto st733;
		case 734: goto st734;
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
		case 1594: goto st1594;
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
		case 1595: goto st1595;
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
		case 1596: goto st1596;
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
		case 1597: goto st1597;
		case 840: goto st840;
		case 841: goto st841;
		case 842: goto st842;
		case 843: goto st843;
		case 844: goto st844;
		case 845: goto st845;
		case 846: goto st846;
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
		case 1598: goto st1598;
		case 1599: goto st1599;
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
		case 1600: goto st1600;
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
		case 1011: goto st1011;
		case 1012: goto st1012;
		case 1013: goto st1013;
		case 1014: goto st1014;
		case 1015: goto st1015;
		case 1601: goto st1601;
		case 1016: goto st1016;
		case 1017: goto st1017;
		case 1602: goto st1602;
		case 1018: goto st1018;
		case 1019: goto st1019;
		case 1020: goto st1020;
		case 1021: goto st1021;
		case 1603: goto st1603;
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
		case 1604: goto st1604;
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
		case 1605: goto st1605;
		case 1606: goto st1606;
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
		case 1607: goto st1607;
		case 1608: goto st1608;
		case 1609: goto st1609;
		case 1610: goto st1610;
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
		case 1611: goto st1611;
		case 1612: goto st1612;
		case 1613: goto st1613;
		case 1614: goto st1614;
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
		case 1123: goto st1123;
		case 1124: goto st1124;
		case 1125: goto st1125;
		case 1126: goto st1126;
		case 1127: goto st1127;
		case 1128: goto st1128;
		case 1129: goto st1129;
		case 1130: goto st1130;
		case 1131: goto st1131;
		case 1132: goto st1132;
		case 1133: goto st1133;
		case 1134: goto st1134;
		case 1135: goto st1135;
		case 1136: goto st1136;
		case 1137: goto st1137;
		case 1138: goto st1138;
		case 1139: goto st1139;
		case 1140: goto st1140;
		case 1141: goto st1141;
		case 1142: goto st1142;
		case 1143: goto st1143;
		case 1144: goto st1144;
		case 1145: goto st1145;
		case 1146: goto st1146;
		case 1147: goto st1147;
		case 1148: goto st1148;
		case 1149: goto st1149;
		case 1150: goto st1150;
		case 1151: goto st1151;
		case 1152: goto st1152;
		case 1153: goto st1153;
		case 1154: goto st1154;
		case 1155: goto st1155;
		case 1156: goto st1156;
		case 1157: goto st1157;
		case 1158: goto st1158;
		case 1159: goto st1159;
		case 1160: goto st1160;
		case 1161: goto st1161;
		case 1162: goto st1162;
		case 1163: goto st1163;
		case 1164: goto st1164;
		case 1165: goto st1165;
		case 1166: goto st1166;
		case 1167: goto st1167;
		case 1168: goto st1168;
		case 1169: goto st1169;
		case 1170: goto st1170;
		case 1171: goto st1171;
		case 1172: goto st1172;
		case 1173: goto st1173;
		case 1174: goto st1174;
		case 1175: goto st1175;
		case 1176: goto st1176;
		case 1177: goto st1177;
		case 1178: goto st1178;
		case 1179: goto st1179;
		case 1180: goto st1180;
		case 1181: goto st1181;
		case 1182: goto st1182;
		case 1183: goto st1183;
		case 1184: goto st1184;
		case 1185: goto st1185;
		case 1186: goto st1186;
		case 1187: goto st1187;
		case 1188: goto st1188;
		case 1189: goto st1189;
		case 1190: goto st1190;
		case 1191: goto st1191;
		case 1192: goto st1192;
		case 1193: goto st1193;
		case 1615: goto st1615;
		case 1194: goto st1194;
		case 1195: goto st1195;
		case 1196: goto st1196;
		case 1197: goto st1197;
		case 1198: goto st1198;
		case 1199: goto st1199;
		case 1200: goto st1200;
		case 1201: goto st1201;
		case 1202: goto st1202;
		case 1203: goto st1203;
		case 1204: goto st1204;
		case 1205: goto st1205;
		case 1206: goto st1206;
		case 1207: goto st1207;
		case 1208: goto st1208;
		case 1209: goto st1209;
		case 1210: goto st1210;
		case 1211: goto st1211;
		case 1212: goto st1212;
		case 1213: goto st1213;
		case 1214: goto st1214;
		case 1215: goto st1215;
		case 1216: goto st1216;
		case 1217: goto st1217;
		case 1218: goto st1218;
		case 1219: goto st1219;
		case 1220: goto st1220;
		case 1221: goto st1221;
		case 1222: goto st1222;
		case 1223: goto st1223;
		case 1224: goto st1224;
		case 1225: goto st1225;
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
		case 1237: goto st1237;
		case 1238: goto st1238;
		case 1239: goto st1239;
		case 1240: goto st1240;
		case 1241: goto st1241;
		case 1242: goto st1242;
		case 1243: goto st1243;
		case 1244: goto st1244;
		case 1245: goto st1245;
		case 1246: goto st1246;
		case 1247: goto st1247;
		case 1248: goto st1248;
		case 1249: goto st1249;
		case 1250: goto st1250;
		case 1251: goto st1251;
		case 1252: goto st1252;
		case 1253: goto st1253;
		case 1254: goto st1254;
		case 1255: goto st1255;
		case 1256: goto st1256;
		case 1257: goto st1257;
		case 1258: goto st1258;
		case 1259: goto st1259;
		case 1260: goto st1260;
		case 1261: goto st1261;
		case 1262: goto st1262;
		case 1263: goto st1263;
		case 1264: goto st1264;
		case 1265: goto st1265;
		case 1266: goto st1266;
		case 1267: goto st1267;
		case 1268: goto st1268;
		case 1269: goto st1269;
		case 1270: goto st1270;
		case 1271: goto st1271;
		case 1272: goto st1272;
		case 1273: goto st1273;
		case 1274: goto st1274;
		case 1275: goto st1275;
		case 1276: goto st1276;
		case 1277: goto st1277;
		case 1278: goto st1278;
		case 1279: goto st1279;
		case 1280: goto st1280;
		case 1281: goto st1281;
		case 1282: goto st1282;
		case 1283: goto st1283;
		case 1284: goto st1284;
		case 1285: goto st1285;
		case 1286: goto st1286;
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
		case 1300: goto st1300;
		case 1301: goto st1301;
		case 1302: goto st1302;
		case 1303: goto st1303;
		case 1304: goto st1304;
		case 1305: goto st1305;
	default: break;
	}

	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof;
_resume:
	switch (  sm->cs )
	{
tr0:
#line 741 "ext/dtext/dtext.cpp.rl"
	{{( sm->p) = ((( sm->te)))-1;}{
    g_debug("block blank line(s)");
  }}
	goto st1306;
tr3:
#line 745 "ext/dtext/dtext.cpp.rl"
	{{( sm->p) = ((( sm->te)))-1;}{
    g_debug("block char");
    ( sm->p)--;

    if (sm->dstack.empty() || dstack_check(sm, BLOCK_QUOTE) || dstack_check(sm, BLOCK_SPOILER) || dstack_check(sm, BLOCK_EXPAND)) {
      dstack_open_element(sm, BLOCK_P, "<p>");
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
{( (sm->stack.data()))[( sm->top)++] = 1306;goto st1328;}}
  }}
	goto st1306;
tr16:
#line 718 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_close_leaf_blocks(sm);
    dstack_open_element(sm, BLOCK_TABLE, "<table class=\"striped\">");
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
{( (sm->stack.data()))[( sm->top)++] = 1306;goto st1613;}}
  }}
	goto st1306;
tr47:
#line 688 "ext/dtext/dtext.cpp.rl"
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
{( (sm->stack.data()))[( sm->top)++] = 1306;goto st1605;}}
  }}
	goto st1306;
tr48:
#line 688 "ext/dtext/dtext.cpp.rl"
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
{( (sm->stack.data()))[( sm->top)++] = 1306;goto st1605;}}
  }}
	goto st1306;
tr50:
#line 683 "ext/dtext/dtext.cpp.rl"
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
{( (sm->stack.data()))[( sm->top)++] = 1306;goto st1605;}}
  }}
	goto st1306;
tr51:
#line 683 "ext/dtext/dtext.cpp.rl"
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
{( (sm->stack.data()))[( sm->top)++] = 1306;goto st1605;}}
  }}
	goto st1306;
tr74:
#line 712 "ext/dtext/dtext.cpp.rl"
	{{( sm->p) = ((( sm->te)))-1;}{
    dstack_close_leaf_blocks(sm);
    dstack_open_element(sm, BLOCK_NODTEXT, "<p>");
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
{( (sm->stack.data()))[( sm->top)++] = 1306;goto st1609;}}
  }}
	goto st1306;
tr75:
#line 712 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_close_leaf_blocks(sm);
    dstack_open_element(sm, BLOCK_NODTEXT, "<p>");
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
{( (sm->stack.data()))[( sm->top)++] = 1306;goto st1609;}}
  }}
	goto st1306;
tr86:
#line 724 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_open_element(sm, BLOCK_TN, "<p class=\"tn\">");
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
{( (sm->stack.data()))[( sm->top)++] = 1306;goto st1328;}}
  }}
	goto st1306;
tr139:
#line 693 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{
    append_code_fence(sm, { sm->b1, sm->b2 }, { sm->a1, sm->a2 });
  }}
	goto st1306;
tr1677:
#line 745 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{
    g_debug("block char");
    ( sm->p)--;

    if (sm->dstack.empty() || dstack_check(sm, BLOCK_QUOTE) || dstack_check(sm, BLOCK_SPOILER) || dstack_check(sm, BLOCK_EXPAND)) {
      dstack_open_element(sm, BLOCK_P, "<p>");
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
{( (sm->stack.data()))[( sm->top)++] = 1306;goto st1328;}}
  }}
	goto st1306;
tr1684:
#line 741 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    g_debug("block blank line(s)");
  }}
	goto st1306;
tr1685:
#line 745 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    g_debug("block char");
    ( sm->p)--;

    if (sm->dstack.empty() || dstack_check(sm, BLOCK_QUOTE) || dstack_check(sm, BLOCK_SPOILER) || dstack_check(sm, BLOCK_EXPAND)) {
      dstack_open_element(sm, BLOCK_P, "<p>");
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
{( (sm->stack.data()))[( sm->top)++] = 1306;goto st1328;}}
  }}
	goto st1306;
tr1686:
#line 729 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    g_debug("write '<hr>' (pos: %ld)", sm->ts - sm->pb);
    append_block(sm, "<hr>");
  }}
	goto st1306;
tr1687:
#line 74 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
#line 734 "ext/dtext/dtext.cpp.rl"
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
{( (sm->stack.data()))[( sm->top)++] = 1306;goto st1328;}}
  }}
	goto st1306;
tr1695:
#line 673 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    dstack_close_leaf_blocks(sm);
    dstack_open_element(sm, BLOCK_QUOTE, "<blockquote>");
  }}
	goto st1306;
tr1696:
#line 688 "ext/dtext/dtext.cpp.rl"
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
{( (sm->stack.data()))[( sm->top)++] = 1306;goto st1605;}}
  }}
	goto st1306;
tr1697:
#line 683 "ext/dtext/dtext.cpp.rl"
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
{( (sm->stack.data()))[( sm->top)++] = 1306;goto st1605;}}
  }}
	goto st1306;
tr1698:
#line 703 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    g_debug("block [expand=]");
    dstack_close_leaf_blocks(sm);
    dstack_open_element(sm, BLOCK_EXPAND, "<details>");
    append_block(sm, "<summary>");
    append_block_html_escaped(sm, { sm->a1, sm->a2 });
    append_block(sm, "</summary><div>");
  }}
	goto st1306;
tr1700:
#line 697 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    dstack_close_leaf_blocks(sm);
    dstack_open_element(sm, BLOCK_EXPAND, "<details>");
    append_block(sm, "<summary>Show</summary><div>");
  }}
	goto st1306;
tr1701:
#line 712 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    dstack_close_leaf_blocks(sm);
    dstack_open_element(sm, BLOCK_NODTEXT, "<p>");
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
{( (sm->stack.data()))[( sm->top)++] = 1306;goto st1609;}}
  }}
	goto st1306;
tr1702:
#line 678 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    dstack_close_leaf_blocks(sm);
    dstack_open_element(sm, BLOCK_SPOILER, "<div class=\"spoiler\">");
  }}
	goto st1306;
tr1704:
#line 668 "ext/dtext/dtext.cpp.rl"
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
{( (sm->stack.data()))[( sm->top)++] = 1306;goto st1328;}}
  }}
	goto st1306;
st1306:
#line 1 "NONE"
	{( sm->ts) = 0;}
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1306;
case 1306:
#line 1 "NONE"
	{( sm->ts) = ( sm->p);}
#line 2757 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr1;
		case 9: goto tr1678;
		case 10: goto tr1;
		case 32: goto tr1678;
		case 42: goto tr1679;
		case 60: goto tr1680;
		case 72: goto tr1681;
		case 91: goto tr1682;
		case 96: goto tr1683;
		case 104: goto tr1681;
	}
	goto tr1677;
tr1:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
	goto st1307;
st1307:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1307;
case 1307:
#line 2777 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr1;
		case 9: goto st1;
		case 10: goto tr1;
		case 32: goto st1;
	}
	goto tr1684;
st1:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1;
case 1:
	switch( (*( sm->p)) ) {
		case 0: goto tr1;
		case 9: goto st1;
		case 10: goto tr1;
		case 32: goto st1;
	}
	goto tr0;
tr1678:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
	goto st1308;
st1308:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1308;
case 1308:
#line 2802 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr1;
		case 9: goto st2;
		case 10: goto tr1;
		case 32: goto st2;
		case 60: goto st3;
		case 91: goto st12;
	}
	goto tr1685;
st2:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof2;
case 2:
	switch( (*( sm->p)) ) {
		case 0: goto tr1;
		case 9: goto st2;
		case 10: goto tr1;
		case 32: goto st2;
		case 60: goto st3;
		case 91: goto st12;
	}
	goto tr3;
st3:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof3;
case 3:
	switch( (*( sm->p)) ) {
		case 72: goto st4;
		case 84: goto st7;
		case 104: goto st4;
		case 116: goto st7;
	}
	goto tr3;
st4:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof4;
case 4:
	switch( (*( sm->p)) ) {
		case 82: goto st5;
		case 114: goto st5;
	}
	goto tr3;
st5:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof5;
case 5:
	if ( (*( sm->p)) == 62 )
		goto st6;
	goto tr3;
st6:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof6;
case 6:
	switch( (*( sm->p)) ) {
		case 0: goto st1309;
		case 9: goto st6;
		case 10: goto st1309;
		case 32: goto st6;
	}
	goto tr3;
st1309:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1309;
case 1309:
	switch( (*( sm->p)) ) {
		case 0: goto st1309;
		case 10: goto st1309;
	}
	goto tr1686;
st7:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof7;
case 7:
	switch( (*( sm->p)) ) {
		case 65: goto st8;
		case 97: goto st8;
	}
	goto tr3;
st8:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof8;
case 8:
	switch( (*( sm->p)) ) {
		case 66: goto st9;
		case 98: goto st9;
	}
	goto tr3;
st9:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof9;
case 9:
	switch( (*( sm->p)) ) {
		case 76: goto st10;
		case 108: goto st10;
	}
	goto tr3;
st10:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof10;
case 10:
	switch( (*( sm->p)) ) {
		case 69: goto st11;
		case 101: goto st11;
	}
	goto tr3;
st11:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof11;
case 11:
	if ( (*( sm->p)) == 62 )
		goto tr16;
	goto tr3;
st12:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof12;
case 12:
	switch( (*( sm->p)) ) {
		case 72: goto st13;
		case 84: goto st15;
		case 104: goto st13;
		case 116: goto st15;
	}
	goto tr3;
st13:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof13;
case 13:
	switch( (*( sm->p)) ) {
		case 82: goto st14;
		case 114: goto st14;
	}
	goto tr3;
st14:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof14;
case 14:
	if ( (*( sm->p)) == 93 )
		goto st6;
	goto tr3;
st15:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof15;
case 15:
	switch( (*( sm->p)) ) {
		case 65: goto st16;
		case 97: goto st16;
	}
	goto tr3;
st16:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof16;
case 16:
	switch( (*( sm->p)) ) {
		case 66: goto st17;
		case 98: goto st17;
	}
	goto tr3;
st17:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof17;
case 17:
	switch( (*( sm->p)) ) {
		case 76: goto st18;
		case 108: goto st18;
	}
	goto tr3;
st18:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof18;
case 18:
	switch( (*( sm->p)) ) {
		case 69: goto st19;
		case 101: goto st19;
	}
	goto tr3;
st19:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof19;
case 19:
	if ( (*( sm->p)) == 93 )
		goto tr16;
	goto tr3;
tr1679:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st1310;
st1310:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1310;
case 1310:
#line 2992 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto tr26;
		case 32: goto tr26;
		case 42: goto st21;
	}
	goto tr1685;
tr26:
#line 72 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
	goto st20;
st20:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof20;
case 20:
#line 3005 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr3;
		case 9: goto tr25;
		case 10: goto tr3;
		case 13: goto tr3;
		case 32: goto tr25;
	}
	goto tr24;
tr24:
#line 73 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st1311;
st1311:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1311;
case 1311:
#line 3020 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr1687;
		case 10: goto tr1687;
		case 13: goto tr1687;
	}
	goto st1311;
tr25:
#line 73 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st1312;
st1312:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1312;
case 1312:
#line 3033 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr1687;
		case 9: goto tr25;
		case 10: goto tr1687;
		case 13: goto tr1687;
		case 32: goto tr25;
	}
	goto tr24;
st21:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof21;
case 21:
	switch( (*( sm->p)) ) {
		case 9: goto tr26;
		case 32: goto tr26;
		case 42: goto st21;
	}
	goto tr3;
tr1680:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
	goto st1313;
st1313:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1313;
case 1313:
#line 3058 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 66: goto st22;
		case 67: goto st32;
		case 69: goto st41;
		case 72: goto st4;
		case 78: goto st50;
		case 81: goto st27;
		case 83: goto st58;
		case 84: goto st66;
		case 98: goto st22;
		case 99: goto st32;
		case 101: goto st41;
		case 104: goto st4;
		case 110: goto st50;
		case 113: goto st27;
		case 115: goto st58;
		case 116: goto st66;
	}
	goto tr1685;
st22:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof22;
case 22:
	switch( (*( sm->p)) ) {
		case 76: goto st23;
		case 108: goto st23;
	}
	goto tr3;
st23:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof23;
case 23:
	switch( (*( sm->p)) ) {
		case 79: goto st24;
		case 111: goto st24;
	}
	goto tr3;
st24:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof24;
case 24:
	switch( (*( sm->p)) ) {
		case 67: goto st25;
		case 99: goto st25;
	}
	goto tr3;
st25:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof25;
case 25:
	switch( (*( sm->p)) ) {
		case 75: goto st26;
		case 107: goto st26;
	}
	goto tr3;
st26:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof26;
case 26:
	switch( (*( sm->p)) ) {
		case 81: goto st27;
		case 113: goto st27;
	}
	goto tr3;
st27:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof27;
case 27:
	switch( (*( sm->p)) ) {
		case 85: goto st28;
		case 117: goto st28;
	}
	goto tr3;
st28:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof28;
case 28:
	switch( (*( sm->p)) ) {
		case 79: goto st29;
		case 111: goto st29;
	}
	goto tr3;
st29:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof29;
case 29:
	switch( (*( sm->p)) ) {
		case 84: goto st30;
		case 116: goto st30;
	}
	goto tr3;
st30:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof30;
case 30:
	switch( (*( sm->p)) ) {
		case 69: goto st31;
		case 101: goto st31;
	}
	goto tr3;
st31:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof31;
case 31:
	if ( (*( sm->p)) == 62 )
		goto st1314;
	goto tr3;
st1314:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1314;
case 1314:
	if ( (*( sm->p)) == 32 )
		goto st1314;
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto st1314;
	goto tr1695;
st32:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof32;
case 32:
	switch( (*( sm->p)) ) {
		case 79: goto st33;
		case 111: goto st33;
	}
	goto tr3;
st33:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof33;
case 33:
	switch( (*( sm->p)) ) {
		case 68: goto st34;
		case 100: goto st34;
	}
	goto tr3;
st34:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof34;
case 34:
	switch( (*( sm->p)) ) {
		case 69: goto st35;
		case 101: goto st35;
	}
	goto tr3;
st35:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof35;
case 35:
	switch( (*( sm->p)) ) {
		case 9: goto st36;
		case 32: goto st36;
		case 61: goto st37;
		case 62: goto tr43;
	}
	goto tr3;
st36:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof36;
case 36:
	switch( (*( sm->p)) ) {
		case 9: goto st36;
		case 32: goto st36;
		case 61: goto st37;
	}
	goto tr3;
st37:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof37;
case 37:
	switch( (*( sm->p)) ) {
		case 9: goto st37;
		case 32: goto st37;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr44;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr44;
	} else
		goto tr44;
	goto tr3;
tr44:
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st38;
st38:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof38;
case 38:
#line 3246 "ext/dtext/dtext.cpp"
	if ( (*( sm->p)) == 62 )
		goto tr46;
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st38;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st38;
	} else
		goto st38;
	goto tr3;
tr46:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 72 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
	goto st1315;
st1315:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1315;
case 1315:
#line 3265 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr48;
		case 9: goto st39;
		case 10: goto tr48;
		case 32: goto st39;
	}
	goto tr1696;
st39:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof39;
case 39:
	switch( (*( sm->p)) ) {
		case 0: goto tr48;
		case 9: goto st39;
		case 10: goto tr48;
		case 32: goto st39;
	}
	goto tr47;
tr43:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
	goto st1316;
st1316:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1316;
case 1316:
#line 3290 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr51;
		case 9: goto st40;
		case 10: goto tr51;
		case 32: goto st40;
	}
	goto tr1697;
st40:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof40;
case 40:
	switch( (*( sm->p)) ) {
		case 0: goto tr51;
		case 9: goto st40;
		case 10: goto tr51;
		case 32: goto st40;
	}
	goto tr50;
st41:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof41;
case 41:
	switch( (*( sm->p)) ) {
		case 88: goto st42;
		case 120: goto st42;
	}
	goto tr3;
st42:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof42;
case 42:
	switch( (*( sm->p)) ) {
		case 80: goto st43;
		case 112: goto st43;
	}
	goto tr3;
st43:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof43;
case 43:
	switch( (*( sm->p)) ) {
		case 65: goto st44;
		case 97: goto st44;
	}
	goto tr3;
st44:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof44;
case 44:
	switch( (*( sm->p)) ) {
		case 78: goto st45;
		case 110: goto st45;
	}
	goto tr3;
st45:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof45;
case 45:
	switch( (*( sm->p)) ) {
		case 68: goto st46;
		case 100: goto st46;
	}
	goto tr3;
st46:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof46;
case 46:
	switch( (*( sm->p)) ) {
		case 9: goto st47;
		case 32: goto st47;
		case 61: goto st49;
		case 62: goto st1318;
	}
	goto tr3;
tr62:
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st47;
st47:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof47;
case 47:
#line 3371 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr3;
		case 9: goto tr62;
		case 10: goto tr3;
		case 13: goto tr3;
		case 32: goto tr62;
		case 61: goto tr63;
		case 62: goto tr64;
	}
	goto tr61;
tr61:
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st48;
st48:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof48;
case 48:
#line 3388 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr3;
		case 10: goto tr3;
		case 13: goto tr3;
		case 62: goto tr66;
	}
	goto st48;
tr66:
#line 72 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
	goto st1317;
tr64:
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
#line 72 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
	goto st1317;
st1317:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1317;
case 1317:
#line 3406 "ext/dtext/dtext.cpp"
	if ( (*( sm->p)) == 32 )
		goto st1317;
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto st1317;
	goto tr1698;
tr63:
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st49;
st49:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof49;
case 49:
#line 3418 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr3;
		case 9: goto tr63;
		case 10: goto tr3;
		case 13: goto tr3;
		case 32: goto tr63;
		case 62: goto tr64;
	}
	goto tr61;
st1318:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1318;
case 1318:
	if ( (*( sm->p)) == 32 )
		goto st1318;
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto st1318;
	goto tr1700;
st50:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof50;
case 50:
	switch( (*( sm->p)) ) {
		case 79: goto st51;
		case 111: goto st51;
	}
	goto tr3;
st51:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof51;
case 51:
	switch( (*( sm->p)) ) {
		case 68: goto st52;
		case 100: goto st52;
	}
	goto tr3;
st52:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof52;
case 52:
	switch( (*( sm->p)) ) {
		case 84: goto st53;
		case 116: goto st53;
	}
	goto tr3;
st53:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof53;
case 53:
	switch( (*( sm->p)) ) {
		case 69: goto st54;
		case 101: goto st54;
	}
	goto tr3;
st54:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof54;
case 54:
	switch( (*( sm->p)) ) {
		case 88: goto st55;
		case 120: goto st55;
	}
	goto tr3;
st55:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof55;
case 55:
	switch( (*( sm->p)) ) {
		case 84: goto st56;
		case 116: goto st56;
	}
	goto tr3;
st56:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof56;
case 56:
	if ( (*( sm->p)) == 62 )
		goto tr73;
	goto tr3;
tr73:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
	goto st1319;
st1319:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1319;
case 1319:
#line 3504 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr75;
		case 9: goto st57;
		case 10: goto tr75;
		case 32: goto st57;
	}
	goto tr1701;
st57:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof57;
case 57:
	switch( (*( sm->p)) ) {
		case 0: goto tr75;
		case 9: goto st57;
		case 10: goto tr75;
		case 32: goto st57;
	}
	goto tr74;
st58:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof58;
case 58:
	switch( (*( sm->p)) ) {
		case 80: goto st59;
		case 112: goto st59;
	}
	goto tr3;
st59:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof59;
case 59:
	switch( (*( sm->p)) ) {
		case 79: goto st60;
		case 111: goto st60;
	}
	goto tr3;
st60:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof60;
case 60:
	switch( (*( sm->p)) ) {
		case 73: goto st61;
		case 105: goto st61;
	}
	goto tr3;
st61:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof61;
case 61:
	switch( (*( sm->p)) ) {
		case 76: goto st62;
		case 108: goto st62;
	}
	goto tr3;
st62:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof62;
case 62:
	switch( (*( sm->p)) ) {
		case 69: goto st63;
		case 101: goto st63;
	}
	goto tr3;
st63:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof63;
case 63:
	switch( (*( sm->p)) ) {
		case 82: goto st64;
		case 114: goto st64;
	}
	goto tr3;
st64:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof64;
case 64:
	switch( (*( sm->p)) ) {
		case 62: goto st1320;
		case 83: goto st65;
		case 115: goto st65;
	}
	goto tr3;
st1320:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1320;
case 1320:
	if ( (*( sm->p)) == 32 )
		goto st1320;
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto st1320;
	goto tr1702;
st65:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof65;
case 65:
	if ( (*( sm->p)) == 62 )
		goto st1320;
	goto tr3;
st66:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof66;
case 66:
	switch( (*( sm->p)) ) {
		case 65: goto st8;
		case 78: goto st67;
		case 97: goto st8;
		case 110: goto st67;
	}
	goto tr3;
st67:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof67;
case 67:
	if ( (*( sm->p)) == 62 )
		goto tr86;
	goto tr3;
tr1681:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
	goto st1321;
st1321:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1321;
case 1321:
#line 3627 "ext/dtext/dtext.cpp"
	if ( 49 <= (*( sm->p)) && (*( sm->p)) <= 54 )
		goto tr1703;
	goto tr1685;
tr1703:
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st68;
st68:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof68;
case 68:
#line 3637 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 35: goto tr87;
		case 46: goto tr88;
	}
	goto tr3;
tr87:
#line 72 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
	goto st69;
st69:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof69;
case 69:
#line 3649 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 33: goto tr89;
		case 35: goto tr89;
		case 38: goto tr89;
		case 45: goto tr89;
		case 95: goto tr89;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 47 <= (*( sm->p)) && (*( sm->p)) <= 58 )
			goto tr89;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr89;
	} else
		goto tr89;
	goto tr3;
tr89:
#line 73 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st70;
st70:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof70;
case 70:
#line 3672 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 33: goto st70;
		case 35: goto st70;
		case 38: goto st70;
		case 46: goto tr91;
		case 95: goto st70;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 45 <= (*( sm->p)) && (*( sm->p)) <= 58 )
			goto st70;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st70;
	} else
		goto st70;
	goto tr3;
tr88:
#line 72 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
#line 73 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
#line 74 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
	goto st1322;
tr91:
#line 74 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
	goto st1322;
st1322:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1322;
case 1322:
#line 3700 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto st1322;
		case 32: goto st1322;
	}
	goto tr1704;
tr1682:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
	goto st1323;
st1323:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1323;
case 1323:
#line 3712 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 67: goto st71;
		case 69: goto st78;
		case 72: goto st13;
		case 78: goto st87;
		case 81: goto st94;
		case 83: goto st99;
		case 84: goto st107;
		case 99: goto st71;
		case 101: goto st78;
		case 104: goto st13;
		case 110: goto st87;
		case 113: goto st94;
		case 115: goto st99;
		case 116: goto st107;
	}
	goto tr1685;
st71:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof71;
case 71:
	switch( (*( sm->p)) ) {
		case 79: goto st72;
		case 111: goto st72;
	}
	goto tr3;
st72:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof72;
case 72:
	switch( (*( sm->p)) ) {
		case 68: goto st73;
		case 100: goto st73;
	}
	goto tr3;
st73:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof73;
case 73:
	switch( (*( sm->p)) ) {
		case 69: goto st74;
		case 101: goto st74;
	}
	goto tr3;
st74:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof74;
case 74:
	switch( (*( sm->p)) ) {
		case 9: goto st75;
		case 32: goto st75;
		case 61: goto st76;
		case 93: goto tr43;
	}
	goto tr3;
st75:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof75;
case 75:
	switch( (*( sm->p)) ) {
		case 9: goto st75;
		case 32: goto st75;
		case 61: goto st76;
	}
	goto tr3;
st76:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof76;
case 76:
	switch( (*( sm->p)) ) {
		case 9: goto st76;
		case 32: goto st76;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr97;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr97;
	} else
		goto tr97;
	goto tr3;
tr97:
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st77;
st77:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof77;
case 77:
#line 3801 "ext/dtext/dtext.cpp"
	if ( (*( sm->p)) == 93 )
		goto tr46;
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st77;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st77;
	} else
		goto st77;
	goto tr3;
st78:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof78;
case 78:
	switch( (*( sm->p)) ) {
		case 88: goto st79;
		case 120: goto st79;
	}
	goto tr3;
st79:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof79;
case 79:
	switch( (*( sm->p)) ) {
		case 80: goto st80;
		case 112: goto st80;
	}
	goto tr3;
st80:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof80;
case 80:
	switch( (*( sm->p)) ) {
		case 65: goto st81;
		case 97: goto st81;
	}
	goto tr3;
st81:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof81;
case 81:
	switch( (*( sm->p)) ) {
		case 78: goto st82;
		case 110: goto st82;
	}
	goto tr3;
st82:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof82;
case 82:
	switch( (*( sm->p)) ) {
		case 68: goto st83;
		case 100: goto st83;
	}
	goto tr3;
st83:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof83;
case 83:
	switch( (*( sm->p)) ) {
		case 9: goto st84;
		case 32: goto st84;
		case 61: goto st86;
		case 93: goto st1318;
	}
	goto tr3;
tr107:
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st84;
st84:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof84;
case 84:
#line 3875 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr3;
		case 9: goto tr107;
		case 10: goto tr3;
		case 13: goto tr3;
		case 32: goto tr107;
		case 61: goto tr108;
		case 93: goto tr64;
	}
	goto tr106;
tr106:
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st85;
st85:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof85;
case 85:
#line 3892 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr3;
		case 10: goto tr3;
		case 13: goto tr3;
		case 93: goto tr66;
	}
	goto st85;
tr108:
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st86;
st86:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof86;
case 86:
#line 3906 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr3;
		case 9: goto tr108;
		case 10: goto tr3;
		case 13: goto tr3;
		case 32: goto tr108;
		case 93: goto tr64;
	}
	goto tr106;
st87:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof87;
case 87:
	switch( (*( sm->p)) ) {
		case 79: goto st88;
		case 111: goto st88;
	}
	goto tr3;
st88:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof88;
case 88:
	switch( (*( sm->p)) ) {
		case 68: goto st89;
		case 100: goto st89;
	}
	goto tr3;
st89:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof89;
case 89:
	switch( (*( sm->p)) ) {
		case 84: goto st90;
		case 116: goto st90;
	}
	goto tr3;
st90:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof90;
case 90:
	switch( (*( sm->p)) ) {
		case 69: goto st91;
		case 101: goto st91;
	}
	goto tr3;
st91:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof91;
case 91:
	switch( (*( sm->p)) ) {
		case 88: goto st92;
		case 120: goto st92;
	}
	goto tr3;
st92:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof92;
case 92:
	switch( (*( sm->p)) ) {
		case 84: goto st93;
		case 116: goto st93;
	}
	goto tr3;
st93:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof93;
case 93:
	if ( (*( sm->p)) == 93 )
		goto tr73;
	goto tr3;
st94:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof94;
case 94:
	switch( (*( sm->p)) ) {
		case 85: goto st95;
		case 117: goto st95;
	}
	goto tr3;
st95:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof95;
case 95:
	switch( (*( sm->p)) ) {
		case 79: goto st96;
		case 111: goto st96;
	}
	goto tr3;
st96:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof96;
case 96:
	switch( (*( sm->p)) ) {
		case 84: goto st97;
		case 116: goto st97;
	}
	goto tr3;
st97:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof97;
case 97:
	switch( (*( sm->p)) ) {
		case 69: goto st98;
		case 101: goto st98;
	}
	goto tr3;
st98:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof98;
case 98:
	if ( (*( sm->p)) == 93 )
		goto st1314;
	goto tr3;
st99:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof99;
case 99:
	switch( (*( sm->p)) ) {
		case 80: goto st100;
		case 112: goto st100;
	}
	goto tr3;
st100:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof100;
case 100:
	switch( (*( sm->p)) ) {
		case 79: goto st101;
		case 111: goto st101;
	}
	goto tr3;
st101:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof101;
case 101:
	switch( (*( sm->p)) ) {
		case 73: goto st102;
		case 105: goto st102;
	}
	goto tr3;
st102:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof102;
case 102:
	switch( (*( sm->p)) ) {
		case 76: goto st103;
		case 108: goto st103;
	}
	goto tr3;
st103:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof103;
case 103:
	switch( (*( sm->p)) ) {
		case 69: goto st104;
		case 101: goto st104;
	}
	goto tr3;
st104:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof104;
case 104:
	switch( (*( sm->p)) ) {
		case 82: goto st105;
		case 114: goto st105;
	}
	goto tr3;
st105:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof105;
case 105:
	switch( (*( sm->p)) ) {
		case 83: goto st106;
		case 93: goto st1320;
		case 115: goto st106;
	}
	goto tr3;
st106:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof106;
case 106:
	if ( (*( sm->p)) == 93 )
		goto st1320;
	goto tr3;
st107:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof107;
case 107:
	switch( (*( sm->p)) ) {
		case 65: goto st16;
		case 78: goto st108;
		case 97: goto st16;
		case 110: goto st108;
	}
	goto tr3;
st108:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof108;
case 108:
	if ( (*( sm->p)) == 93 )
		goto tr86;
	goto tr3;
tr1683:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
	goto st1324;
st1324:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1324;
case 1324:
#line 4115 "ext/dtext/dtext.cpp"
	if ( (*( sm->p)) == 96 )
		goto st109;
	goto tr1685;
st109:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof109;
case 109:
	if ( (*( sm->p)) == 96 )
		goto st110;
	goto tr3;
tr130:
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
#line 72 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
	goto st110;
st110:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof110;
case 110:
#line 4133 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr129;
		case 9: goto tr130;
		case 10: goto tr129;
		case 32: goto tr130;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr131;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr131;
	} else
		goto tr131;
	goto tr3;
tr140:
#line 72 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
	goto st111;
tr129:
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
#line 72 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
	goto st111;
st111:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof111;
case 111:
#line 4159 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr133;
		case 10: goto tr133;
	}
	goto tr132;
tr132:
#line 73 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st112;
st112:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof112;
case 112:
#line 4171 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr135;
		case 10: goto tr135;
	}
	goto st112;
tr135:
#line 74 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
	goto st113;
tr133:
#line 73 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
#line 74 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
	goto st113;
st113:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof113;
case 113:
#line 4187 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr135;
		case 10: goto tr135;
		case 96: goto st114;
	}
	goto st112;
st114:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof114;
case 114:
	switch( (*( sm->p)) ) {
		case 0: goto tr135;
		case 10: goto tr135;
		case 96: goto st115;
	}
	goto st112;
st115:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof115;
case 115:
	switch( (*( sm->p)) ) {
		case 0: goto tr135;
		case 10: goto tr135;
		case 96: goto st116;
	}
	goto st112;
st116:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof116;
case 116:
	switch( (*( sm->p)) ) {
		case 0: goto tr139;
		case 9: goto st116;
		case 10: goto tr139;
		case 32: goto st116;
	}
	goto st112;
tr131:
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st117;
st117:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof117;
case 117:
#line 4231 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr140;
		case 9: goto tr141;
		case 10: goto tr140;
		case 32: goto tr141;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st117;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st117;
	} else
		goto st117;
	goto tr3;
tr141:
#line 72 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
	goto st118;
st118:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof118;
case 118:
#line 4253 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto st111;
		case 9: goto st118;
		case 10: goto st111;
		case 32: goto st118;
	}
	goto tr3;
tr145:
#line 296 "ext/dtext/dtext.cpp.rl"
	{{( sm->p) = ((( sm->te)))-1;}{ append_html_escaped(sm, (*( sm->p))); }}
	goto st1325;
tr151:
#line 288 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{ dstack_close_element(sm, INLINE_B); }}
	goto st1325;
tr152:
#line 290 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{ dstack_close_element(sm, INLINE_I); }}
	goto st1325;
tr153:
#line 292 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{ dstack_close_element(sm, INLINE_S); }}
	goto st1325;
tr158:
#line 294 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{ dstack_close_element(sm, INLINE_U); }}
	goto st1325;
tr159:
#line 287 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{ dstack_open_element(sm,  INLINE_B, "<strong>"); }}
	goto st1325;
tr161:
#line 289 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{ dstack_open_element(sm,  INLINE_I, "<em>"); }}
	goto st1325;
tr162:
#line 291 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{ dstack_open_element(sm,  INLINE_S, "<s>"); }}
	goto st1325;
tr168:
#line 293 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{ dstack_open_element(sm,  INLINE_U, "<u>"); }}
	goto st1325;
tr1713:
#line 296 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{ append_html_escaped(sm, (*( sm->p))); }}
	goto st1325;
tr1714:
#line 295 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;}
	goto st1325;
tr1717:
#line 296 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{ append_html_escaped(sm, (*( sm->p))); }}
	goto st1325;
st1325:
#line 1 "NONE"
	{( sm->ts) = 0;}
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1325;
case 1325:
#line 1 "NONE"
	{( sm->ts) = ( sm->p);}
#line 4302 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr1714;
		case 60: goto tr1715;
		case 91: goto tr1716;
	}
	goto tr1713;
tr1715:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
	goto st1326;
st1326:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1326;
case 1326:
#line 4315 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 47: goto st119;
		case 66: goto st129;
		case 69: goto st130;
		case 73: goto st131;
		case 83: goto st132;
		case 85: goto st137;
		case 98: goto st129;
		case 101: goto st130;
		case 105: goto st131;
		case 115: goto st132;
		case 117: goto st137;
	}
	goto tr1717;
st119:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof119;
case 119:
	switch( (*( sm->p)) ) {
		case 66: goto st120;
		case 69: goto st121;
		case 73: goto st122;
		case 83: goto st123;
		case 85: goto st128;
		case 98: goto st120;
		case 101: goto st121;
		case 105: goto st122;
		case 115: goto st123;
		case 117: goto st128;
	}
	goto tr145;
st120:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof120;
case 120:
	if ( (*( sm->p)) == 62 )
		goto tr151;
	goto tr145;
st121:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof121;
case 121:
	switch( (*( sm->p)) ) {
		case 77: goto st122;
		case 109: goto st122;
	}
	goto tr145;
st122:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof122;
case 122:
	if ( (*( sm->p)) == 62 )
		goto tr152;
	goto tr145;
st123:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof123;
case 123:
	switch( (*( sm->p)) ) {
		case 62: goto tr153;
		case 84: goto st124;
		case 116: goto st124;
	}
	goto tr145;
st124:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof124;
case 124:
	switch( (*( sm->p)) ) {
		case 82: goto st125;
		case 114: goto st125;
	}
	goto tr145;
st125:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof125;
case 125:
	switch( (*( sm->p)) ) {
		case 79: goto st126;
		case 111: goto st126;
	}
	goto tr145;
st126:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof126;
case 126:
	switch( (*( sm->p)) ) {
		case 78: goto st127;
		case 110: goto st127;
	}
	goto tr145;
st127:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof127;
case 127:
	switch( (*( sm->p)) ) {
		case 71: goto st120;
		case 103: goto st120;
	}
	goto tr145;
st128:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof128;
case 128:
	if ( (*( sm->p)) == 62 )
		goto tr158;
	goto tr145;
st129:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof129;
case 129:
	if ( (*( sm->p)) == 62 )
		goto tr159;
	goto tr145;
st130:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof130;
case 130:
	switch( (*( sm->p)) ) {
		case 77: goto st131;
		case 109: goto st131;
	}
	goto tr145;
st131:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof131;
case 131:
	if ( (*( sm->p)) == 62 )
		goto tr161;
	goto tr145;
st132:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof132;
case 132:
	switch( (*( sm->p)) ) {
		case 62: goto tr162;
		case 84: goto st133;
		case 116: goto st133;
	}
	goto tr145;
st133:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof133;
case 133:
	switch( (*( sm->p)) ) {
		case 82: goto st134;
		case 114: goto st134;
	}
	goto tr145;
st134:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof134;
case 134:
	switch( (*( sm->p)) ) {
		case 79: goto st135;
		case 111: goto st135;
	}
	goto tr145;
st135:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof135;
case 135:
	switch( (*( sm->p)) ) {
		case 78: goto st136;
		case 110: goto st136;
	}
	goto tr145;
st136:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof136;
case 136:
	switch( (*( sm->p)) ) {
		case 71: goto st129;
		case 103: goto st129;
	}
	goto tr145;
st137:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof137;
case 137:
	if ( (*( sm->p)) == 62 )
		goto tr168;
	goto tr145;
tr1716:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
	goto st1327;
st1327:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1327;
case 1327:
#line 4505 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 47: goto st138;
		case 66: goto st143;
		case 73: goto st144;
		case 83: goto st145;
		case 85: goto st146;
		case 98: goto st143;
		case 105: goto st144;
		case 115: goto st145;
		case 117: goto st146;
	}
	goto tr1717;
st138:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof138;
case 138:
	switch( (*( sm->p)) ) {
		case 66: goto st139;
		case 73: goto st140;
		case 83: goto st141;
		case 85: goto st142;
		case 98: goto st139;
		case 105: goto st140;
		case 115: goto st141;
		case 117: goto st142;
	}
	goto tr145;
st139:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof139;
case 139:
	if ( (*( sm->p)) == 93 )
		goto tr151;
	goto tr145;
st140:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof140;
case 140:
	if ( (*( sm->p)) == 93 )
		goto tr152;
	goto tr145;
st141:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof141;
case 141:
	if ( (*( sm->p)) == 93 )
		goto tr153;
	goto tr145;
st142:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof142;
case 142:
	if ( (*( sm->p)) == 93 )
		goto tr158;
	goto tr145;
st143:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof143;
case 143:
	if ( (*( sm->p)) == 93 )
		goto tr159;
	goto tr145;
st144:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof144;
case 144:
	if ( (*( sm->p)) == 93 )
		goto tr161;
	goto tr145;
st145:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof145;
case 145:
	if ( (*( sm->p)) == 93 )
		goto tr162;
	goto tr145;
st146:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof146;
case 146:
	if ( (*( sm->p)) == 93 )
		goto tr168;
	goto tr145;
tr173:
#line 1 "NONE"
	{	switch( ( sm->act) ) {
	case 53:
	{{( sm->p) = ((( sm->te)))-1;}
    append_bare_named_url(sm, { sm->b1, sm->b2 + 1 }, { sm->a1, sm->a2 });
  }
	break;
	case 54:
	{{( sm->p) = ((( sm->te)))-1;}
    append_named_url(sm, { sm->b1, sm->b2 }, { sm->a1, sm->a2 });
  }
	break;
	case 55:
	{{( sm->p) = ((( sm->te)))-1;}
    append_named_url(sm, { sm->a1, sm->a2 }, { sm->b1, sm->b2 });
  }
	break;
	case 56:
	{{( sm->p) = ((( sm->te)))-1;}
    append_named_url(sm, { sm->g1, sm->g2 }, { sm->f1, sm->f2 });
  }
	break;
	case 57:
	{{( sm->p) = ((( sm->te)))-1;}
    append_bare_unnamed_url(sm, { sm->ts, sm->te });
  }
	break;
	case 59:
	{{( sm->p) = ((( sm->te)))-1;}
    append_mention(sm, { sm->a1, sm->a2 + 1 });
  }
	break;
	case 74:
	{{( sm->p) = ((( sm->te)))-1;}
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
{( (sm->stack.data()))[( sm->top)++] = 1328;goto st1605;}}
  }
	break;
	case 84:
	{{( sm->p) = ((( sm->te)))-1;}
    g_debug("inline [expand]");
    dstack_close_leaf_blocks(sm);
    {( sm->p) = (( sm->ts))-1;}
    { sm->cs = ( (sm->stack.data()))[--( sm->top)];goto _again;}
  }
	break;
	case 90:
	{{( sm->p) = ((( sm->te)))-1;}
    g_debug("inline newline2");

    if (dstack_check(sm, BLOCK_P)) {
      dstack_rewind(sm);
    } else if (sm->header_mode) {
      dstack_close_leaf_blocks(sm);
    } else {
      dstack_close_list(sm);
    }

    if (sm->options.f_inline) {
      append(sm, " ");
    }

    { sm->cs = ( (sm->stack.data()))[--( sm->top)];goto _again;}
  }
	break;
	case 91:
	{{( sm->p) = ((( sm->te)))-1;}
    g_debug("inline newline");

    if (sm->header_mode) {
      dstack_close_leaf_blocks(sm);
      { sm->cs = ( (sm->stack.data()))[--( sm->top)];goto _again;}
    } else if (dstack_is_open(sm, BLOCK_UL)) {
      dstack_close_list(sm);
      { sm->cs = ( (sm->stack.data()))[--( sm->top)];goto _again;}
    } else {
      append(sm, "<br>");
    }
  }
	break;
	case 94:
	{{( sm->p) = ((( sm->te)))-1;}
    append(sm, std::string_view { sm->ts, sm->te });
  }
	break;
	case 95:
	{{( sm->p) = ((( sm->te)))-1;}
    append_html_escaped(sm, (*( sm->p)));
  }
	break;
	default:
	{{( sm->p) = ((( sm->te)))-1;}}
	break;
	}
	}
	goto st1328;
tr176:
#line 575 "ext/dtext/dtext.cpp.rl"
	{{( sm->p) = ((( sm->te)))-1;}{
    append(sm, std::string_view { sm->ts, sm->te });
  }}
	goto st1328;
tr180:
#line 579 "ext/dtext/dtext.cpp.rl"
	{{( sm->p) = ((( sm->te)))-1;}{
    append_html_escaped(sm, (*( sm->p)));
  }}
	goto st1328;
tr182:
#line 555 "ext/dtext/dtext.cpp.rl"
	{{( sm->p) = ((( sm->te)))-1;}{
    g_debug("inline newline");

    if (sm->header_mode) {
      dstack_close_leaf_blocks(sm);
      { sm->cs = ( (sm->stack.data()))[--( sm->top)];goto _again;}
    } else if (dstack_is_open(sm, BLOCK_UL)) {
      dstack_close_list(sm);
      { sm->cs = ( (sm->stack.data()))[--( sm->top)];goto _again;}
    } else {
      append(sm, "<br>");
    }
  }}
	goto st1328;
tr200:
#line 445 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_close_leaf_blocks(sm);
    {( sm->p) = (( sm->ts))-1;}
    { sm->cs = ( (sm->stack.data()))[--( sm->top)];goto _again;}
  }}
	goto st1328;
tr205:
#line 512 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_close_leaf_blocks(sm);
    {( sm->p) = (( sm->ts))-1;}
    { sm->cs = ( (sm->stack.data()))[--( sm->top)];goto _again;}
  }}
	goto st1328;
tr221:
#line 537 "ext/dtext/dtext.cpp.rl"
	{{( sm->p) = ((( sm->te)))-1;}{
    g_debug("inline newline2");

    if (dstack_check(sm, BLOCK_P)) {
      dstack_rewind(sm);
    } else if (sm->header_mode) {
      dstack_close_leaf_blocks(sm);
    } else {
      dstack_close_list(sm);
    }

    if (sm->options.f_inline) {
      append(sm, " ");
    }

    { sm->cs = ( (sm->stack.data()))[--( sm->top)];goto _again;}
  }}
	goto st1328;
tr227:
#line 524 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{
    if (dstack_close_element(sm, BLOCK_TD)) {
      { sm->cs = ( (sm->stack.data()))[--( sm->top)];goto _again;}
    }
  }}
	goto st1328;
tr228:
#line 518 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{
    if (dstack_close_element(sm, BLOCK_TH)) {
      { sm->cs = ( (sm->stack.data()))[--( sm->top)];goto _again;}
    }
  }}
	goto st1328;
tr229:
#line 411 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{
    g_debug("inline [/tn]");

    if (dstack_check(sm, INLINE_TN)) {
      dstack_close_element(sm, INLINE_TN);
    } else if (dstack_close_element(sm, BLOCK_TN)) {
      { sm->cs = ( (sm->stack.data()))[--( sm->top)];goto _again;}
    }
  }}
	goto st1328;
tr272:
#line 455 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{
    if (dstack_is_open(sm, INLINE_SPOILER)) {
      dstack_close_element(sm, INLINE_SPOILER);
    } else if (dstack_is_open(sm, BLOCK_SPOILER)) {
      dstack_close_until(sm, BLOCK_SPOILER);
      { sm->cs = ( (sm->stack.data()))[--( sm->top)];goto _again;}
    } else {
      append_html_escaped(sm, { sm->ts, sm->te });
    }
  }}
	goto st1328;
tr279:
#line 474 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_close_leaf_blocks(sm);
    {( sm->p) = (( sm->ts))-1;}
    { sm->cs = ( (sm->stack.data()))[--( sm->top)];goto _again;}
  }}
	goto st1328;
tr282:
#line 72 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
#line 474 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_close_leaf_blocks(sm);
    {( sm->p) = (( sm->ts))-1;}
    { sm->cs = ( (sm->stack.data()))[--( sm->top)];goto _again;}
  }}
	goto st1328;
tr337:
#line 439 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_close_leaf_blocks(sm);
    {( sm->p) = (( sm->ts))-1;}
    { sm->cs = ( (sm->stack.data()))[--( sm->top)];goto _again;}
  }}
	goto st1328;
tr350:
#line 359 "ext/dtext/dtext.cpp.rl"
	{{( sm->p) = ((( sm->te)))-1;}{
    append_bare_named_url(sm, { sm->b1, sm->b2 + 1 }, { sm->a1, sm->a2 });
  }}
	goto st1328;
tr416:
#line 74 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
#line 363 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{
    append_named_url(sm, { sm->b1, sm->b2 }, { sm->a1, sm->a2 });
  }}
	goto st1328;
tr622:
#line 307 "ext/dtext/dtext.cpp.rl"
	{{( sm->p) = ((( sm->te)))-1;}{ append_id_link(sm, "dmail", "dmail", "/dmails/", { sm->a1, sm->a2 }); }}
	goto st1328;
tr657:
#line 375 "ext/dtext/dtext.cpp.rl"
	{{( sm->p) = ((( sm->te)))-1;}{
    append_bare_unnamed_url(sm, { sm->ts, sm->te });
  }}
	goto st1328;
tr723:
#line 330 "ext/dtext/dtext.cpp.rl"
	{{( sm->p) = ((( sm->te)))-1;}{ append_id_link(sm, "pixiv", "pixiv", "https://www.pixiv.net/artworks/", { sm->a1, sm->a2 }); }}
	goto st1328;
tr738:
#line 305 "ext/dtext/dtext.cpp.rl"
	{{( sm->p) = ((( sm->te)))-1;}{ append_id_link(sm, "topic", "forum-topic", "/forum_topics/", { sm->a1, sm->a2 }); }}
	goto st1328;
tr755:
#line 84 "ext/dtext/dtext.cpp.rl"
	{ sm->g2 = sm->p; }
#line 371 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{
    append_named_url(sm, { sm->g1, sm->g2 }, { sm->f1, sm->f2 });
  }}
	goto st1328;
tr774:
#line 399 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{ dstack_close_element(sm, INLINE_B); }}
	goto st1328;
tr787:
#line 401 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{ dstack_close_element(sm, INLINE_I); }}
	goto st1328;
tr798:
#line 403 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{ dstack_close_element(sm, INLINE_S); }}
	goto st1328;
tr816:
#line 405 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{ dstack_close_element(sm, INLINE_U); }}
	goto st1328;
tr818:
#line 398 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{ dstack_open_element(sm,  INLINE_B, "<strong>"); }}
	goto st1328;
tr819:
#line 421 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{
    if (sm->header_mode) {
      append_html_escaped(sm, "<br>");
    } else {
      append(sm, "<br>");
    };
  }}
	goto st1328;
tr829:
#line 434 "ext/dtext/dtext.cpp.rl"
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
{( (sm->stack.data()))[( sm->top)++] = 1328;goto st1605;}}
  }}
	goto st1328;
tr830:
#line 434 "ext/dtext/dtext.cpp.rl"
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
{( (sm->stack.data()))[( sm->top)++] = 1328;goto st1605;}}
  }}
	goto st1328;
tr832:
#line 429 "ext/dtext/dtext.cpp.rl"
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
{( (sm->stack.data()))[( sm->top)++] = 1328;goto st1605;}}
  }}
	goto st1328;
tr833:
#line 429 "ext/dtext/dtext.cpp.rl"
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
{( (sm->stack.data()))[( sm->top)++] = 1328;goto st1605;}}
  }}
	goto st1328;
tr842:
#line 499 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{
    g_debug("inline [expand]");
    dstack_close_leaf_blocks(sm);
    {( sm->p) = (( sm->ts))-1;}
    { sm->cs = ( (sm->stack.data()))[--( sm->top)];goto _again;}
  }}
	goto st1328;
tr865:
#line 74 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
#line 367 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{
    append_named_url(sm, { sm->a1, sm->a2 }, { sm->b1, sm->b2 });
  }}
	goto st1328;
tr869:
#line 74 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
#line 367 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{
    append_named_url(sm, { sm->a1, sm->a2 }, { sm->b1, sm->b2 });
  }}
#line 84 "ext/dtext/dtext.cpp.rl"
	{ sm->g2 = sm->p; }
	goto st1328;
tr894:
#line 400 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{ dstack_open_element(sm,  INLINE_I, "<em>"); }}
	goto st1328;
tr902:
#line 466 "ext/dtext/dtext.cpp.rl"
	{{( sm->p) = ((( sm->te)))-1;}{
    dstack_open_element(sm, INLINE_NODTEXT, "");
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
{( (sm->stack.data()))[( sm->top)++] = 1328;goto st1609;}}
  }}
	goto st1328;
tr903:
#line 466 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_open_element(sm, INLINE_NODTEXT, "");
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
{( (sm->stack.data()))[( sm->top)++] = 1328;goto st1609;}}
  }}
	goto st1328;
tr909:
#line 486 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{
    g_debug("inline [quote]");
    dstack_close_leaf_blocks(sm);
    {( sm->p) = (( sm->ts))-1;}
    { sm->cs = ( (sm->stack.data()))[--( sm->top)];goto _again;}
  }}
	goto st1328;
tr911:
#line 402 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{ dstack_open_element(sm,  INLINE_S, "<s>"); }}
	goto st1328;
tr918:
#line 451 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_open_element(sm, INLINE_SPOILER, "<span class=\"spoiler\">");
  }}
	goto st1328;
tr921:
#line 407 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_open_element(sm, INLINE_TN, "<span class=\"tn\">");
  }}
	goto st1328;
tr923:
#line 404 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{ dstack_open_element(sm,  INLINE_U, "<u>"); }}
	goto st1328;
tr951:
#line 363 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{
    append_named_url(sm, { sm->b1, sm->b2 }, { sm->a1, sm->a2 });
  }}
	goto st1328;
tr1056:
#line 379 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{
    append_unnamed_url(sm, { sm->a1, sm->a2 });
  }}
	goto st1328;
tr1184:
#line 367 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{
    append_named_url(sm, { sm->a1, sm->a2 }, { sm->b1, sm->b2 });
  }}
	goto st1328;
tr1221:
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
#line 72 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
#line 499 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{
    g_debug("inline [expand]");
    dstack_close_leaf_blocks(sm);
    {( sm->p) = (( sm->ts))-1;}
    { sm->cs = ( (sm->stack.data()))[--( sm->top)];goto _again;}
  }}
	goto st1328;
tr1223:
#line 72 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
#line 499 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{
    g_debug("inline [expand]");
    dstack_close_leaf_blocks(sm);
    {( sm->p) = (( sm->ts))-1;}
    { sm->cs = ( (sm->stack.data()))[--( sm->top)];goto _again;}
  }}
	goto st1328;
tr1232:
#line 72 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
#line 379 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{
    append_unnamed_url(sm, { sm->a1, sm->a2 });
  }}
	goto st1328;
tr1254:
#line 72 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
#line 387 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{
    g_debug("delimited mention: <@%.*s>", (int)(sm->a2 - sm->a1), sm->a1);
    append_mention(sm, { sm->a1, sm->a2 });
  }}
	goto st1328;
tr1727:
#line 579 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{
    append_html_escaped(sm, (*( sm->p)));
  }}
	goto st1328;
tr1734:
#line 569 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{
    append(sm, ' ');
  }}
	goto st1328;
tr1759:
#line 579 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append_html_escaped(sm, (*( sm->p)));
  }}
	goto st1328;
tr1760:
#line 575 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append(sm, std::string_view { sm->ts, sm->te });
  }}
	goto st1328;
tr1762:
#line 555 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    g_debug("inline newline");

    if (sm->header_mode) {
      dstack_close_leaf_blocks(sm);
      { sm->cs = ( (sm->stack.data()))[--( sm->top)];goto _again;}
    } else if (dstack_is_open(sm, BLOCK_UL)) {
      dstack_close_list(sm);
      { sm->cs = ( (sm->stack.data()))[--( sm->top)];goto _again;}
    } else {
      append(sm, "<br>");
    }
  }}
	goto st1328;
tr1769:
#line 530 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    g_debug("inline [hr] (pos: %ld)", sm->ts - sm->pb);
    dstack_close_leaf_blocks(sm);
    {( sm->p) = (( sm->ts))-1;}
    { sm->cs = ( (sm->stack.data()))[--( sm->top)];goto _again;}
  }}
	goto st1328;
tr1770:
#line 537 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    g_debug("inline newline2");

    if (dstack_check(sm, BLOCK_P)) {
      dstack_rewind(sm);
    } else if (sm->header_mode) {
      dstack_close_leaf_blocks(sm);
    } else {
      dstack_close_list(sm);
    }

    if (sm->options.f_inline) {
      append(sm, " ");
    }

    { sm->cs = ( (sm->stack.data()))[--( sm->top)];goto _again;}
  }}
	goto st1328;
tr1773:
#line 74 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
#line 392 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    g_debug("inline list");
    {( sm->p) = (( sm->ts + 1))-1;}
    { sm->cs = ( (sm->stack.data()))[--( sm->top)];goto _again;}
  }}
	goto st1328;
tr1775:
#line 493 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    g_debug("inline [/quote]");
    dstack_close_until(sm, BLOCK_QUOTE);
    { sm->cs = ( (sm->stack.data()))[--( sm->top)];goto _again;}
  }}
	goto st1328;
tr1776:
#line 506 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    g_debug("inline [/expand]");
    dstack_close_until(sm, BLOCK_EXPAND);
    { sm->cs = ( (sm->stack.data()))[--( sm->top)];goto _again;}
  }}
	goto st1328;
tr1777:
#line 480 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    dstack_close_leaf_blocks(sm);
    {( sm->p) = (( sm->ts))-1;}
    { sm->cs = ( (sm->stack.data()))[--( sm->top)];goto _again;}
  }}
	goto st1328;
tr1780:
#line 359 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append_bare_named_url(sm, { sm->b1, sm->b2 + 1 }, { sm->a1, sm->a2 });
  }}
	goto st1328;
tr1784:
#line 79 "ext/dtext/dtext.cpp.rl"
	{ sm->e1 = sm->p; }
#line 80 "ext/dtext/dtext.cpp.rl"
	{ sm->e2 = sm->p; }
#line 351 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append_wiki_link(sm, { sm->a1, sm->a2 }, { sm->b1, sm->b2 }, { sm->c1, sm->c2 }, { sm->b1, sm->b2 }, { sm->e1, sm->e2 });
  }}
	goto st1328;
tr1786:
#line 80 "ext/dtext/dtext.cpp.rl"
	{ sm->e2 = sm->p; }
#line 351 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append_wiki_link(sm, { sm->a1, sm->a2 }, { sm->b1, sm->b2 }, { sm->c1, sm->c2 }, { sm->b1, sm->b2 }, { sm->e1, sm->e2 });
  }}
	goto st1328;
tr1788:
#line 79 "ext/dtext/dtext.cpp.rl"
	{ sm->e1 = sm->p; }
#line 80 "ext/dtext/dtext.cpp.rl"
	{ sm->e2 = sm->p; }
#line 355 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append_wiki_link(sm, { sm->a1, sm->a2 }, { sm->b1, sm->b2 }, { sm->c1, sm->c2 }, { sm->d1, sm->d2 }, { sm->e1, sm->e2 });
  }}
	goto st1328;
tr1790:
#line 80 "ext/dtext/dtext.cpp.rl"
	{ sm->e2 = sm->p; }
#line 355 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append_wiki_link(sm, { sm->a1, sm->a2 }, { sm->b1, sm->b2 }, { sm->c1, sm->c2 }, { sm->d1, sm->d2 }, { sm->e1, sm->e2 });
  }}
	goto st1328;
tr1794:
#line 77 "ext/dtext/dtext.cpp.rl"
	{ sm->d1 = sm->p; }
#line 78 "ext/dtext/dtext.cpp.rl"
	{ sm->d2 = sm->p; }
#line 347 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append_post_search_link(sm, { sm->a1, sm->a2 }, { sm->b1, sm->b2 }, { sm->c1, sm->c2 }, { sm->d1, sm->d2 });
  }}
	goto st1328;
tr1796:
#line 78 "ext/dtext/dtext.cpp.rl"
	{ sm->d2 = sm->p; }
#line 347 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append_post_search_link(sm, { sm->a1, sm->a2 }, { sm->b1, sm->b2 }, { sm->c1, sm->c2 }, { sm->d1, sm->d2 });
  }}
	goto st1328;
tr1798:
#line 77 "ext/dtext/dtext.cpp.rl"
	{ sm->d1 = sm->p; }
#line 78 "ext/dtext/dtext.cpp.rl"
	{ sm->d2 = sm->p; }
#line 343 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append_post_search_link(sm, { sm->a1, sm->a2 }, { sm->b1, sm->b2 }, { sm->b1, sm->b2 }, { sm->d1, sm->d2 });
  }}
	goto st1328;
tr1800:
#line 78 "ext/dtext/dtext.cpp.rl"
	{ sm->d2 = sm->p; }
#line 343 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append_post_search_link(sm, { sm->a1, sm->a2 }, { sm->b1, sm->b2 }, { sm->b1, sm->b2 }, { sm->d1, sm->d2 });
  }}
	goto st1328;
tr1813:
#line 72 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
#line 313 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{ append_id_link(sm, "alias", "tag-alias", "/tag_aliases/", { sm->a1, sm->a2 }); }}
	goto st1328;
tr1820:
#line 72 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
#line 301 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{ append_id_link(sm, "appeal", "post-appeal", "/post_appeals/", { sm->a1, sm->a2 }); }}
	goto st1328;
tr1828:
#line 72 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
#line 310 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{ append_id_link(sm, "artist", "artist", "/artists/", { sm->a1, sm->a2 }); }}
	goto st1328;
tr1837:
#line 72 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
#line 326 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{ append_id_link(sm, "artstation", "artstation", "https://www.artstation.com/artwork/", { sm->a1, sm->a2 }); }}
	goto st1328;
tr1843:
#line 72 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
#line 320 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{ append_id_link(sm, "asset", "media-asset", "/media_assets/", { sm->a1, sm->a2 }); }}
	goto st1328;
tr1849:
#line 72 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
#line 311 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{ append_id_link(sm, "ban", "ban", "/bans/", { sm->a1, sm->a2 }); }}
	goto st1328;
tr1853:
#line 72 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
#line 312 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{ append_id_link(sm, "BUR", "bulk-update-request", "/bulk_update_requests/", { sm->a1, sm->a2 }); }}
	goto st1328;
tr1863:
#line 72 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
#line 306 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{ append_id_link(sm, "comment", "comment", "/comments/", { sm->a1, sm->a2 }); }}
	goto st1328;
tr1867:
#line 72 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
#line 325 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{ append_id_link(sm, "commit", "github-commit", "https://github.com/danbooru/danbooru/commit/", { sm->a1, sm->a2 }); }}
	goto st1328;
tr1880:
#line 72 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
#line 327 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{ append_id_link(sm, "deviantart", "deviantart", "https://www.deviantart.com/deviation/", { sm->a1, sm->a2 }); }}
	goto st1328;
tr1886:
#line 72 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
#line 307 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{ append_id_link(sm, "dmail", "dmail", "/dmails/", { sm->a1, sm->a2 }); }}
	goto st1328;
tr1889:
#line 74 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
#line 338 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{ append_dmail_key_link(sm); }}
	goto st1328;
tr1902:
#line 72 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
#line 315 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{ append_id_link(sm, "favgroup", "favorite-group", "/favorite_groups/", { sm->a1, sm->a2 }); }}
	goto st1328;
tr1911:
#line 72 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
#line 318 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{ append_id_link(sm, "feedback", "user-feedback", "/user_feedbacks/", { sm->a1, sm->a2 }); }}
	goto st1328;
tr1916:
#line 72 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
#line 302 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{ append_id_link(sm, "flag", "post-flag", "/post_flags/", { sm->a1, sm->a2 }); }}
	goto st1328;
tr1922:
#line 72 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
#line 304 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{ append_id_link(sm, "forum", "forum-post", "/forum_posts/", { sm->a1, sm->a2 }); }}
	goto st1328;
tr1932:
#line 72 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
#line 336 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{ append_id_link(sm, "gelbooru", "gelbooru", "https://gelbooru.com/index.php?page=post&s=view&id=", { sm->a1, sm->a2 }); }}
	goto st1328;
tr1939:
#line 375 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append_bare_unnamed_url(sm, { sm->ts, sm->te });
  }}
	goto st1328;
tr1952:
#line 72 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
#line 314 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{ append_id_link(sm, "implication", "tag-implication", "/tag_implications/", { sm->a1, sm->a2 }); }}
	goto st1328;
tr1958:
#line 72 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
#line 323 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{ append_id_link(sm, "issue", "github", "https://github.com/danbooru/danbooru/issues/", { sm->a1, sm->a2 }); }}
	goto st1328;
tr1966:
#line 72 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
#line 321 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{ append_id_link(sm, "asset", "media-asset", "/media_assets/", { sm->a1, sm->a2 }); }}
	goto st1328;
tr1971:
#line 72 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
#line 316 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{ append_id_link(sm, "mod action", "mod-action", "/mod_actions/", { sm->a1, sm->a2 }); }}
	goto st1328;
tr1979:
#line 72 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
#line 317 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{ append_id_link(sm, "modreport", "moderation-report", "/moderation_reports/", { sm->a1, sm->a2 }); }}
	goto st1328;
tr1987:
#line 72 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
#line 328 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{ append_id_link(sm, "nijie", "nijie", "https://nijie.info/view.php?id=", { sm->a1, sm->a2 }); }}
	goto st1328;
tr1992:
#line 72 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
#line 303 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{ append_id_link(sm, "note", "note", "/notes/", { sm->a1, sm->a2 }); }}
	goto st1328;
tr2002:
#line 72 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
#line 329 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{ append_id_link(sm, "pawoo", "pawoo", "https://pawoo.net/web/statuses/", { sm->a1, sm->a2 }); }}
	goto st1328;
tr2008:
#line 72 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
#line 330 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{ append_id_link(sm, "pixiv", "pixiv", "https://www.pixiv.net/artworks/", { sm->a1, sm->a2 }); }}
	goto st1328;
tr2011:
#line 74 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
#line 341 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{ append_paged_link(sm, "pixiv #", "<a rel=\"external nofollow noreferrer\" class=\"dtext-link dtext-id-link dtext-pixiv-id-link\" href=\"", "https://www.pixiv.net/artworks/", "#"); }}
	goto st1328;
tr2017:
#line 72 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
#line 308 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{ append_id_link(sm, "pool", "pool", "/pools/", { sm->a1, sm->a2 }); }}
	goto st1328;
tr2021:
#line 72 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
#line 300 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{ append_id_link(sm, "post", "post", "/posts/", { sm->a1, sm->a2 }); }}
	goto st1328;
tr2026:
#line 72 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
#line 324 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{ append_id_link(sm, "pull", "github-pull", "https://github.com/danbooru/danbooru/pull/", { sm->a1, sm->a2 }); }}
	goto st1328;
tr2036:
#line 72 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
#line 335 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{ append_id_link(sm, "sankaku", "sankaku", "https://chan.sankakucomplex.com/post/show/", { sm->a1, sm->a2 }); }}
	goto st1328;
tr2042:
#line 72 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
#line 331 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{ append_id_link(sm, "seiga", "seiga", "https://seiga.nicovideo.jp/seiga/im", { sm->a1, sm->a2 }); }}
	goto st1328;
tr2050:
#line 72 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
#line 305 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{ append_id_link(sm, "topic", "forum-topic", "/forum_topics/", { sm->a1, sm->a2 }); }}
	goto st1328;
tr2053:
#line 74 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
#line 340 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{ append_paged_link(sm, "topic #", "<a class=\"dtext-link dtext-id-link dtext-forum-topic-id-link\" href=\"", "/forum_topics/", "?page="); }}
	goto st1328;
tr2061:
#line 72 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
#line 332 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{ append_id_link(sm, "twitter", "twitter", "https://twitter.com/i/web/status/", { sm->a1, sm->a2 }); }}
	goto st1328;
tr2067:
#line 72 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
#line 309 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{ append_id_link(sm, "user", "user", "/users/", { sm->a1, sm->a2 }); }}
	goto st1328;
tr2073:
#line 72 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
#line 319 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{ append_id_link(sm, "wiki", "wiki-page", "/wiki_pages/", { sm->a1, sm->a2 }); }}
	goto st1328;
tr2082:
#line 72 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
#line 334 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{ append_id_link(sm, "yandere", "yandere", "https://yande.re/post/show/", { sm->a1, sm->a2 }); }}
	goto st1328;
tr2097:
#line 434 "ext/dtext/dtext.cpp.rl"
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
{( (sm->stack.data()))[( sm->top)++] = 1328;goto st1605;}}
  }}
	goto st1328;
tr2098:
#line 429 "ext/dtext/dtext.cpp.rl"
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
{( (sm->stack.data()))[( sm->top)++] = 1328;goto st1605;}}
  }}
	goto st1328;
tr2099:
#line 499 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    g_debug("inline [expand]");
    dstack_close_leaf_blocks(sm);
    {( sm->p) = (( sm->ts))-1;}
    { sm->cs = ( (sm->stack.data()))[--( sm->top)];goto _again;}
  }}
	goto st1328;
tr2100:
#line 371 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append_named_url(sm, { sm->g1, sm->g2 }, { sm->f1, sm->f2 });
  }}
	goto st1328;
tr2101:
#line 466 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    dstack_open_element(sm, INLINE_NODTEXT, "");
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
{( (sm->stack.data()))[( sm->top)++] = 1328;goto st1609;}}
  }}
	goto st1328;
tr2121:
#line 383 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append_mention(sm, { sm->a1, sm->a2 + 1 });
  }}
	goto st1328;
st1328:
#line 1 "NONE"
	{( sm->ts) = 0;}
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1328;
case 1328:
#line 1 "NONE"
	{( sm->ts) = ( sm->p);}
#line 5454 "ext/dtext/dtext.cpp"
	_widec = (*( sm->p));
	if ( (*( sm->p)) > 60 ) {
		if ( 64 <= (*( sm->p)) && (*( sm->p)) <= 64 ) {
			_widec = (short)(1152 + ((*( sm->p)) - -128));
			if ( 
#line 86 "ext/dtext/dtext.cpp.rl"
 is_mention_boundary(p[-1])  ) _widec += 256;
			if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 512;
		}
	} else if ( (*( sm->p)) >= 60 ) {
		_widec = (short)(640 + ((*( sm->p)) - -128));
		if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
	}
	switch( _widec ) {
		case 0: goto tr1731;
		case 9: goto tr1732;
		case 10: goto tr1733;
		case 13: goto tr1734;
		case 32: goto tr1732;
		case 34: goto tr1735;
		case 65: goto tr1738;
		case 66: goto tr1739;
		case 67: goto tr1740;
		case 68: goto tr1741;
		case 70: goto tr1742;
		case 71: goto tr1743;
		case 72: goto tr1744;
		case 73: goto tr1745;
		case 77: goto tr1746;
		case 78: goto tr1747;
		case 80: goto tr1748;
		case 83: goto tr1749;
		case 84: goto tr1750;
		case 85: goto tr1751;
		case 87: goto tr1752;
		case 89: goto tr1753;
		case 91: goto tr1754;
		case 97: goto tr1738;
		case 98: goto tr1739;
		case 99: goto tr1740;
		case 100: goto tr1741;
		case 102: goto tr1742;
		case 103: goto tr1743;
		case 104: goto tr1744;
		case 105: goto tr1745;
		case 109: goto tr1746;
		case 110: goto tr1747;
		case 112: goto tr1748;
		case 115: goto tr1749;
		case 116: goto tr1750;
		case 117: goto tr1751;
		case 119: goto tr1752;
		case 121: goto tr1753;
		case 123: goto tr1755;
		case 828: goto tr1756;
		case 1084: goto tr1757;
		case 1344: goto tr1727;
		case 1600: goto tr1727;
		case 1856: goto tr1727;
		case 2112: goto tr1758;
	}
	if ( _widec < 48 ) {
		if ( _widec < -32 ) {
			if ( _widec > -63 ) {
				if ( -62 <= _widec && _widec <= -33 )
					goto st1329;
			} else
				goto tr1727;
		} else if ( _widec > -17 ) {
			if ( _widec > -12 ) {
				if ( -11 <= _widec && _widec <= 47 )
					goto tr1727;
			} else if ( _widec >= -16 )
				goto tr1730;
		} else
			goto tr1729;
	} else if ( _widec > 57 ) {
		if ( _widec < 69 ) {
			if ( _widec > 59 ) {
				if ( 61 <= _widec && _widec <= 63 )
					goto tr1727;
			} else if ( _widec >= 58 )
				goto tr1727;
		} else if ( _widec > 90 ) {
			if ( _widec < 101 ) {
				if ( 92 <= _widec && _widec <= 96 )
					goto tr1727;
			} else if ( _widec > 122 ) {
				if ( 124 <= _widec )
					goto tr1727;
			} else
				goto tr1736;
		} else
			goto tr1736;
	} else
		goto tr1736;
	goto st0;
st1329:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1329;
case 1329:
	if ( (*( sm->p)) <= -65 )
		goto tr174;
	goto tr1759;
tr174:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 575 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 94;}
	goto st1330;
st1330:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1330;
case 1330:
#line 5567 "ext/dtext/dtext.cpp"
	if ( (*( sm->p)) < -32 ) {
		if ( -62 <= (*( sm->p)) && (*( sm->p)) <= -33 )
			goto st147;
	} else if ( (*( sm->p)) > -17 ) {
		if ( -16 <= (*( sm->p)) && (*( sm->p)) <= -12 )
			goto st149;
	} else
		goto st148;
	goto tr1760;
st147:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof147;
case 147:
	if ( (*( sm->p)) <= -65 )
		goto tr174;
	goto tr173;
st148:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof148;
case 148:
	if ( (*( sm->p)) <= -65 )
		goto st147;
	goto tr173;
st149:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof149;
case 149:
	if ( (*( sm->p)) <= -65 )
		goto st148;
	goto tr176;
tr1729:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 579 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 95;}
	goto st1331;
st1331:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1331;
case 1331:
#line 5605 "ext/dtext/dtext.cpp"
	if ( (*( sm->p)) <= -65 )
		goto st147;
	goto tr1759;
tr1730:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 579 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 95;}
	goto st1332;
st1332:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1332;
case 1332:
#line 5616 "ext/dtext/dtext.cpp"
	if ( (*( sm->p)) <= -65 )
		goto st148;
	goto tr1759;
tr178:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 537 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1333;
tr1731:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 573 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 93;}
	goto st1333;
st1333:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1333;
case 1333:
#line 5631 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr178;
		case 9: goto st150;
		case 10: goto tr178;
		case 32: goto st150;
	}
	goto tr173;
st150:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof150;
case 150:
	switch( (*( sm->p)) ) {
		case 0: goto tr178;
		case 9: goto st150;
		case 10: goto tr178;
		case 32: goto st150;
	}
	goto tr173;
tr1732:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 579 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 95;}
	goto st1334;
st1334:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1334;
case 1334:
#line 5657 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto st150;
		case 9: goto st151;
		case 10: goto st150;
		case 32: goto st151;
	}
	goto tr1759;
st151:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof151;
case 151:
	switch( (*( sm->p)) ) {
		case 0: goto st150;
		case 9: goto st151;
		case 10: goto st150;
		case 32: goto st151;
	}
	goto tr180;
tr1733:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 555 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 91;}
	goto st1335;
st1335:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1335;
case 1335:
#line 5683 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr178;
		case 9: goto st152;
		case 10: goto tr1763;
		case 32: goto st152;
		case 42: goto tr1764;
		case 60: goto st201;
		case 72: goto st246;
		case 91: goto st250;
		case 96: goto st280;
		case 104: goto st246;
	}
	goto tr1762;
st152:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof152;
case 152:
	switch( (*( sm->p)) ) {
		case 0: goto tr178;
		case 9: goto st152;
		case 10: goto tr178;
		case 32: goto st152;
		case 60: goto st153;
		case 91: goto st171;
	}
	goto tr182;
st153:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof153;
case 153:
	switch( (*( sm->p)) ) {
		case 72: goto st154;
		case 83: goto st157;
		case 84: goto st166;
		case 104: goto st154;
		case 115: goto st157;
		case 116: goto st166;
	}
	goto tr182;
st154:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof154;
case 154:
	switch( (*( sm->p)) ) {
		case 82: goto st155;
		case 114: goto st155;
	}
	goto tr182;
st155:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof155;
case 155:
	if ( (*( sm->p)) == 62 )
		goto st156;
	goto tr182;
st156:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof156;
case 156:
	switch( (*( sm->p)) ) {
		case 0: goto st1336;
		case 9: goto st156;
		case 10: goto st1336;
		case 32: goto st156;
	}
	goto tr182;
st1336:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1336;
case 1336:
	switch( (*( sm->p)) ) {
		case 0: goto st1336;
		case 10: goto st1336;
	}
	goto tr1769;
st157:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof157;
case 157:
	switch( (*( sm->p)) ) {
		case 80: goto st158;
		case 112: goto st158;
	}
	goto tr182;
st158:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof158;
case 158:
	switch( (*( sm->p)) ) {
		case 79: goto st159;
		case 111: goto st159;
	}
	goto tr182;
st159:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof159;
case 159:
	switch( (*( sm->p)) ) {
		case 73: goto st160;
		case 105: goto st160;
	}
	goto tr182;
st160:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof160;
case 160:
	switch( (*( sm->p)) ) {
		case 76: goto st161;
		case 108: goto st161;
	}
	goto tr182;
st161:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof161;
case 161:
	switch( (*( sm->p)) ) {
		case 69: goto st162;
		case 101: goto st162;
	}
	goto tr182;
st162:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof162;
case 162:
	switch( (*( sm->p)) ) {
		case 82: goto st163;
		case 114: goto st163;
	}
	goto tr182;
st163:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof163;
case 163:
	switch( (*( sm->p)) ) {
		case 62: goto st164;
		case 83: goto st165;
		case 115: goto st165;
	}
	goto tr182;
st164:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof164;
case 164:
	switch( (*( sm->p)) ) {
		case 0: goto tr200;
		case 9: goto st164;
		case 10: goto tr200;
		case 32: goto st164;
	}
	goto tr182;
st165:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof165;
case 165:
	if ( (*( sm->p)) == 62 )
		goto st164;
	goto tr182;
st166:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof166;
case 166:
	switch( (*( sm->p)) ) {
		case 65: goto st167;
		case 97: goto st167;
	}
	goto tr182;
st167:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof167;
case 167:
	switch( (*( sm->p)) ) {
		case 66: goto st168;
		case 98: goto st168;
	}
	goto tr182;
st168:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof168;
case 168:
	switch( (*( sm->p)) ) {
		case 76: goto st169;
		case 108: goto st169;
	}
	goto tr182;
st169:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof169;
case 169:
	switch( (*( sm->p)) ) {
		case 69: goto st170;
		case 101: goto st170;
	}
	goto tr182;
st170:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof170;
case 170:
	if ( (*( sm->p)) == 62 )
		goto tr205;
	goto tr182;
st171:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof171;
case 171:
	switch( (*( sm->p)) ) {
		case 72: goto st172;
		case 83: goto st174;
		case 84: goto st182;
		case 104: goto st172;
		case 115: goto st174;
		case 116: goto st182;
	}
	goto tr182;
st172:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof172;
case 172:
	switch( (*( sm->p)) ) {
		case 82: goto st173;
		case 114: goto st173;
	}
	goto tr182;
st173:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof173;
case 173:
	if ( (*( sm->p)) == 93 )
		goto st156;
	goto tr182;
st174:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof174;
case 174:
	switch( (*( sm->p)) ) {
		case 80: goto st175;
		case 112: goto st175;
	}
	goto tr182;
st175:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof175;
case 175:
	switch( (*( sm->p)) ) {
		case 79: goto st176;
		case 111: goto st176;
	}
	goto tr182;
st176:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof176;
case 176:
	switch( (*( sm->p)) ) {
		case 73: goto st177;
		case 105: goto st177;
	}
	goto tr182;
st177:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof177;
case 177:
	switch( (*( sm->p)) ) {
		case 76: goto st178;
		case 108: goto st178;
	}
	goto tr182;
st178:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof178;
case 178:
	switch( (*( sm->p)) ) {
		case 69: goto st179;
		case 101: goto st179;
	}
	goto tr182;
st179:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof179;
case 179:
	switch( (*( sm->p)) ) {
		case 82: goto st180;
		case 114: goto st180;
	}
	goto tr182;
st180:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof180;
case 180:
	switch( (*( sm->p)) ) {
		case 83: goto st181;
		case 93: goto st164;
		case 115: goto st181;
	}
	goto tr182;
st181:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof181;
case 181:
	if ( (*( sm->p)) == 93 )
		goto st164;
	goto tr182;
st182:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof182;
case 182:
	switch( (*( sm->p)) ) {
		case 65: goto st183;
		case 97: goto st183;
	}
	goto tr182;
st183:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof183;
case 183:
	switch( (*( sm->p)) ) {
		case 66: goto st184;
		case 98: goto st184;
	}
	goto tr182;
st184:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof184;
case 184:
	switch( (*( sm->p)) ) {
		case 76: goto st185;
		case 108: goto st185;
	}
	goto tr182;
st185:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof185;
case 185:
	switch( (*( sm->p)) ) {
		case 69: goto st186;
		case 101: goto st186;
	}
	goto tr182;
st186:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof186;
case 186:
	if ( (*( sm->p)) == 93 )
		goto tr205;
	goto tr182;
tr1763:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 537 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 90;}
	goto st1337;
st1337:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1337;
case 1337:
#line 6034 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr178;
		case 9: goto st150;
		case 10: goto tr1763;
		case 32: goto st150;
		case 60: goto st187;
		case 91: goto st193;
	}
	goto tr1770;
st187:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof187;
case 187:
	if ( (*( sm->p)) == 47 )
		goto st188;
	goto tr221;
st188:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof188;
case 188:
	switch( (*( sm->p)) ) {
		case 84: goto st189;
		case 116: goto st189;
	}
	goto tr221;
st189:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof189;
case 189:
	switch( (*( sm->p)) ) {
		case 68: goto st190;
		case 72: goto st191;
		case 78: goto st192;
		case 100: goto st190;
		case 104: goto st191;
		case 110: goto st192;
	}
	goto tr173;
st190:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof190;
case 190:
	if ( (*( sm->p)) == 62 )
		goto tr227;
	goto tr173;
st191:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof191;
case 191:
	if ( (*( sm->p)) == 62 )
		goto tr228;
	goto tr173;
st192:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof192;
case 192:
	if ( (*( sm->p)) == 62 )
		goto tr229;
	goto tr173;
st193:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof193;
case 193:
	if ( (*( sm->p)) == 47 )
		goto st194;
	goto tr221;
st194:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof194;
case 194:
	switch( (*( sm->p)) ) {
		case 84: goto st195;
		case 116: goto st195;
	}
	goto tr221;
st195:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof195;
case 195:
	switch( (*( sm->p)) ) {
		case 68: goto st196;
		case 72: goto st197;
		case 78: goto st198;
		case 100: goto st196;
		case 104: goto st197;
		case 110: goto st198;
	}
	goto tr173;
st196:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof196;
case 196:
	if ( (*( sm->p)) == 93 )
		goto tr227;
	goto tr173;
st197:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof197;
case 197:
	if ( (*( sm->p)) == 93 )
		goto tr228;
	goto tr173;
st198:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof198;
case 198:
	if ( (*( sm->p)) == 93 )
		goto tr229;
	goto tr173;
tr1764:
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st199;
st199:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof199;
case 199:
#line 6150 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto tr235;
		case 32: goto tr235;
		case 42: goto st199;
	}
	goto tr182;
tr235:
#line 72 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
	goto st200;
st200:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof200;
case 200:
#line 6163 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr182;
		case 9: goto tr238;
		case 10: goto tr182;
		case 13: goto tr182;
		case 32: goto tr238;
	}
	goto tr237;
tr237:
#line 73 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st1338;
st1338:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1338;
case 1338:
#line 6178 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr1773;
		case 10: goto tr1773;
		case 13: goto tr1773;
	}
	goto st1338;
tr238:
#line 73 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st1339;
st1339:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1339;
case 1339:
#line 6191 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr1773;
		case 9: goto tr238;
		case 10: goto tr1773;
		case 13: goto tr1773;
		case 32: goto tr238;
	}
	goto tr237;
st201:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof201;
case 201:
	switch( (*( sm->p)) ) {
		case 47: goto st202;
		case 67: goto st232;
		case 72: goto st154;
		case 78: goto st239;
		case 83: goto st157;
		case 84: goto st166;
		case 99: goto st232;
		case 104: goto st154;
		case 110: goto st239;
		case 115: goto st157;
		case 116: goto st166;
	}
	goto tr182;
st202:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof202;
case 202:
	switch( (*( sm->p)) ) {
		case 66: goto st203;
		case 69: goto st213;
		case 81: goto st219;
		case 83: goto st224;
		case 84: goto st189;
		case 98: goto st203;
		case 101: goto st213;
		case 113: goto st219;
		case 115: goto st224;
		case 116: goto st189;
	}
	goto tr182;
st203:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof203;
case 203:
	switch( (*( sm->p)) ) {
		case 76: goto st204;
		case 108: goto st204;
	}
	goto tr182;
st204:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof204;
case 204:
	switch( (*( sm->p)) ) {
		case 79: goto st205;
		case 111: goto st205;
	}
	goto tr173;
st205:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof205;
case 205:
	switch( (*( sm->p)) ) {
		case 67: goto st206;
		case 99: goto st206;
	}
	goto tr173;
st206:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof206;
case 206:
	switch( (*( sm->p)) ) {
		case 75: goto st207;
		case 107: goto st207;
	}
	goto tr173;
st207:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof207;
case 207:
	switch( (*( sm->p)) ) {
		case 81: goto st208;
		case 113: goto st208;
	}
	goto tr173;
st208:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof208;
case 208:
	switch( (*( sm->p)) ) {
		case 85: goto st209;
		case 117: goto st209;
	}
	goto tr173;
st209:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof209;
case 209:
	switch( (*( sm->p)) ) {
		case 79: goto st210;
		case 111: goto st210;
	}
	goto tr173;
st210:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof210;
case 210:
	switch( (*( sm->p)) ) {
		case 84: goto st211;
		case 116: goto st211;
	}
	goto tr173;
st211:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof211;
case 211:
	switch( (*( sm->p)) ) {
		case 69: goto st212;
		case 101: goto st212;
	}
	goto tr173;
st212:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof212;
case 212:
	_widec = (*( sm->p));
	if ( 93 <= (*( sm->p)) && (*( sm->p)) <= 93 ) {
		_widec = (short)(2176 + ((*( sm->p)) - -128));
		if ( 
#line 88 "ext/dtext/dtext.cpp.rl"
 dstack_is_open(sm, BLOCK_QUOTE)  ) _widec += 256;
	}
	if ( _widec == 2653 )
		goto st1340;
	goto tr173;
st1340:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1340;
case 1340:
	switch( (*( sm->p)) ) {
		case 9: goto st1340;
		case 32: goto st1340;
	}
	goto tr1775;
st213:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof213;
case 213:
	switch( (*( sm->p)) ) {
		case 88: goto st214;
		case 120: goto st214;
	}
	goto tr182;
st214:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof214;
case 214:
	switch( (*( sm->p)) ) {
		case 80: goto st215;
		case 112: goto st215;
	}
	goto tr173;
st215:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof215;
case 215:
	switch( (*( sm->p)) ) {
		case 65: goto st216;
		case 97: goto st216;
	}
	goto tr173;
st216:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof216;
case 216:
	switch( (*( sm->p)) ) {
		case 78: goto st217;
		case 110: goto st217;
	}
	goto tr173;
st217:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof217;
case 217:
	switch( (*( sm->p)) ) {
		case 68: goto st218;
		case 100: goto st218;
	}
	goto tr173;
st218:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof218;
case 218:
	_widec = (*( sm->p));
	if ( 62 <= (*( sm->p)) && (*( sm->p)) <= 62 ) {
		_widec = (short)(2688 + ((*( sm->p)) - -128));
		if ( 
#line 89 "ext/dtext/dtext.cpp.rl"
 dstack_is_open(sm, BLOCK_EXPAND)  ) _widec += 256;
	}
	if ( _widec == 3134 )
		goto st1341;
	goto tr173;
st1341:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1341;
case 1341:
	switch( (*( sm->p)) ) {
		case 9: goto st1341;
		case 32: goto st1341;
	}
	goto tr1776;
st219:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof219;
case 219:
	switch( (*( sm->p)) ) {
		case 85: goto st220;
		case 117: goto st220;
	}
	goto tr173;
st220:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof220;
case 220:
	switch( (*( sm->p)) ) {
		case 79: goto st221;
		case 111: goto st221;
	}
	goto tr173;
st221:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof221;
case 221:
	switch( (*( sm->p)) ) {
		case 84: goto st222;
		case 116: goto st222;
	}
	goto tr173;
st222:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof222;
case 222:
	switch( (*( sm->p)) ) {
		case 69: goto st223;
		case 101: goto st223;
	}
	goto tr173;
st223:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof223;
case 223:
	_widec = (*( sm->p));
	if ( 62 <= (*( sm->p)) && (*( sm->p)) <= 62 ) {
		_widec = (short)(2176 + ((*( sm->p)) - -128));
		if ( 
#line 88 "ext/dtext/dtext.cpp.rl"
 dstack_is_open(sm, BLOCK_QUOTE)  ) _widec += 256;
	}
	if ( _widec == 2622 )
		goto st1340;
	goto tr173;
st224:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof224;
case 224:
	switch( (*( sm->p)) ) {
		case 80: goto st225;
		case 112: goto st225;
	}
	goto tr182;
st225:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof225;
case 225:
	switch( (*( sm->p)) ) {
		case 79: goto st226;
		case 111: goto st226;
	}
	goto tr173;
st226:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof226;
case 226:
	switch( (*( sm->p)) ) {
		case 73: goto st227;
		case 105: goto st227;
	}
	goto tr173;
st227:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof227;
case 227:
	switch( (*( sm->p)) ) {
		case 76: goto st228;
		case 108: goto st228;
	}
	goto tr173;
st228:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof228;
case 228:
	switch( (*( sm->p)) ) {
		case 69: goto st229;
		case 101: goto st229;
	}
	goto tr173;
st229:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof229;
case 229:
	switch( (*( sm->p)) ) {
		case 82: goto st230;
		case 114: goto st230;
	}
	goto tr173;
st230:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof230;
case 230:
	switch( (*( sm->p)) ) {
		case 62: goto tr272;
		case 83: goto st231;
		case 115: goto st231;
	}
	goto tr173;
st231:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof231;
case 231:
	if ( (*( sm->p)) == 62 )
		goto tr272;
	goto tr173;
st232:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof232;
case 232:
	switch( (*( sm->p)) ) {
		case 79: goto st233;
		case 111: goto st233;
	}
	goto tr182;
st233:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof233;
case 233:
	switch( (*( sm->p)) ) {
		case 68: goto st234;
		case 100: goto st234;
	}
	goto tr182;
st234:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof234;
case 234:
	switch( (*( sm->p)) ) {
		case 69: goto st235;
		case 101: goto st235;
	}
	goto tr182;
st235:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof235;
case 235:
	switch( (*( sm->p)) ) {
		case 9: goto st236;
		case 32: goto st236;
		case 61: goto st237;
		case 62: goto tr279;
	}
	goto tr182;
st236:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof236;
case 236:
	switch( (*( sm->p)) ) {
		case 9: goto st236;
		case 32: goto st236;
		case 61: goto st237;
	}
	goto tr182;
st237:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof237;
case 237:
	switch( (*( sm->p)) ) {
		case 9: goto st237;
		case 32: goto st237;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr280;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr280;
	} else
		goto tr280;
	goto tr182;
tr280:
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st238;
st238:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof238;
case 238:
#line 6596 "ext/dtext/dtext.cpp"
	if ( (*( sm->p)) == 62 )
		goto tr282;
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st238;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st238;
	} else
		goto st238;
	goto tr182;
st239:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof239;
case 239:
	switch( (*( sm->p)) ) {
		case 79: goto st240;
		case 111: goto st240;
	}
	goto tr182;
st240:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof240;
case 240:
	switch( (*( sm->p)) ) {
		case 68: goto st241;
		case 100: goto st241;
	}
	goto tr182;
st241:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof241;
case 241:
	switch( (*( sm->p)) ) {
		case 84: goto st242;
		case 116: goto st242;
	}
	goto tr182;
st242:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof242;
case 242:
	switch( (*( sm->p)) ) {
		case 69: goto st243;
		case 101: goto st243;
	}
	goto tr182;
st243:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof243;
case 243:
	switch( (*( sm->p)) ) {
		case 88: goto st244;
		case 120: goto st244;
	}
	goto tr182;
st244:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof244;
case 244:
	switch( (*( sm->p)) ) {
		case 84: goto st245;
		case 116: goto st245;
	}
	goto tr182;
st245:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof245;
case 245:
	if ( (*( sm->p)) == 62 )
		goto tr279;
	goto tr182;
st246:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof246;
case 246:
	if ( 49 <= (*( sm->p)) && (*( sm->p)) <= 54 )
		goto tr289;
	goto tr182;
tr289:
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st247;
st247:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof247;
case 247:
#line 6682 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 35: goto tr290;
		case 46: goto tr291;
	}
	goto tr182;
tr290:
#line 72 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
	goto st248;
st248:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof248;
case 248:
#line 6694 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 33: goto tr292;
		case 35: goto tr292;
		case 38: goto tr292;
		case 45: goto tr292;
		case 95: goto tr292;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 47 <= (*( sm->p)) && (*( sm->p)) <= 58 )
			goto tr292;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr292;
	} else
		goto tr292;
	goto tr182;
tr292:
#line 73 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st249;
st249:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof249;
case 249:
#line 6717 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 33: goto st249;
		case 35: goto st249;
		case 38: goto st249;
		case 46: goto tr294;
		case 95: goto st249;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 45 <= (*( sm->p)) && (*( sm->p)) <= 58 )
			goto st249;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st249;
	} else
		goto st249;
	goto tr182;
tr291:
#line 72 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
#line 73 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
#line 74 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
	goto st1342;
tr294:
#line 74 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
	goto st1342;
st1342:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1342;
case 1342:
#line 6745 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto st1342;
		case 32: goto st1342;
	}
	goto tr1777;
st250:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof250;
case 250:
	switch( (*( sm->p)) ) {
		case 47: goto st251;
		case 67: goto st266;
		case 72: goto st172;
		case 78: goto st273;
		case 83: goto st174;
		case 84: goto st182;
		case 99: goto st266;
		case 104: goto st172;
		case 110: goto st273;
		case 115: goto st174;
		case 116: goto st182;
	}
	goto tr182;
st251:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof251;
case 251:
	switch( (*( sm->p)) ) {
		case 69: goto st252;
		case 81: goto st208;
		case 83: goto st258;
		case 84: goto st195;
		case 101: goto st252;
		case 113: goto st208;
		case 115: goto st258;
		case 116: goto st195;
	}
	goto tr182;
st252:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof252;
case 252:
	switch( (*( sm->p)) ) {
		case 88: goto st253;
		case 120: goto st253;
	}
	goto tr182;
st253:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof253;
case 253:
	switch( (*( sm->p)) ) {
		case 80: goto st254;
		case 112: goto st254;
	}
	goto tr182;
st254:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof254;
case 254:
	switch( (*( sm->p)) ) {
		case 65: goto st255;
		case 97: goto st255;
	}
	goto tr182;
st255:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof255;
case 255:
	switch( (*( sm->p)) ) {
		case 78: goto st256;
		case 110: goto st256;
	}
	goto tr182;
st256:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof256;
case 256:
	switch( (*( sm->p)) ) {
		case 68: goto st257;
		case 100: goto st257;
	}
	goto tr182;
st257:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof257;
case 257:
	_widec = (*( sm->p));
	if ( 93 <= (*( sm->p)) && (*( sm->p)) <= 93 ) {
		_widec = (short)(2688 + ((*( sm->p)) - -128));
		if ( 
#line 89 "ext/dtext/dtext.cpp.rl"
 dstack_is_open(sm, BLOCK_EXPAND)  ) _widec += 256;
	}
	if ( _widec == 3165 )
		goto st1341;
	goto tr182;
st258:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof258;
case 258:
	switch( (*( sm->p)) ) {
		case 80: goto st259;
		case 112: goto st259;
	}
	goto tr182;
st259:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof259;
case 259:
	switch( (*( sm->p)) ) {
		case 79: goto st260;
		case 111: goto st260;
	}
	goto tr182;
st260:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof260;
case 260:
	switch( (*( sm->p)) ) {
		case 73: goto st261;
		case 105: goto st261;
	}
	goto tr182;
st261:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof261;
case 261:
	switch( (*( sm->p)) ) {
		case 76: goto st262;
		case 108: goto st262;
	}
	goto tr182;
st262:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof262;
case 262:
	switch( (*( sm->p)) ) {
		case 69: goto st263;
		case 101: goto st263;
	}
	goto tr182;
st263:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof263;
case 263:
	switch( (*( sm->p)) ) {
		case 82: goto st264;
		case 114: goto st264;
	}
	goto tr182;
st264:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof264;
case 264:
	switch( (*( sm->p)) ) {
		case 83: goto st265;
		case 93: goto tr272;
		case 115: goto st265;
	}
	goto tr182;
st265:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof265;
case 265:
	if ( (*( sm->p)) == 93 )
		goto tr272;
	goto tr182;
st266:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof266;
case 266:
	switch( (*( sm->p)) ) {
		case 79: goto st267;
		case 111: goto st267;
	}
	goto tr182;
st267:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof267;
case 267:
	switch( (*( sm->p)) ) {
		case 68: goto st268;
		case 100: goto st268;
	}
	goto tr182;
st268:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof268;
case 268:
	switch( (*( sm->p)) ) {
		case 69: goto st269;
		case 101: goto st269;
	}
	goto tr182;
st269:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof269;
case 269:
	switch( (*( sm->p)) ) {
		case 9: goto st270;
		case 32: goto st270;
		case 61: goto st271;
		case 93: goto tr279;
	}
	goto tr182;
st270:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof270;
case 270:
	switch( (*( sm->p)) ) {
		case 9: goto st270;
		case 32: goto st270;
		case 61: goto st271;
	}
	goto tr182;
st271:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof271;
case 271:
	switch( (*( sm->p)) ) {
		case 9: goto st271;
		case 32: goto st271;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr317;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr317;
	} else
		goto tr317;
	goto tr182;
tr317:
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st272;
st272:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof272;
case 272:
#line 6984 "ext/dtext/dtext.cpp"
	if ( (*( sm->p)) == 93 )
		goto tr282;
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st272;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st272;
	} else
		goto st272;
	goto tr182;
st273:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof273;
case 273:
	switch( (*( sm->p)) ) {
		case 79: goto st274;
		case 111: goto st274;
	}
	goto tr182;
st274:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof274;
case 274:
	switch( (*( sm->p)) ) {
		case 68: goto st275;
		case 100: goto st275;
	}
	goto tr182;
st275:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof275;
case 275:
	switch( (*( sm->p)) ) {
		case 84: goto st276;
		case 116: goto st276;
	}
	goto tr182;
st276:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof276;
case 276:
	switch( (*( sm->p)) ) {
		case 69: goto st277;
		case 101: goto st277;
	}
	goto tr182;
st277:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof277;
case 277:
	switch( (*( sm->p)) ) {
		case 88: goto st278;
		case 120: goto st278;
	}
	goto tr182;
st278:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof278;
case 278:
	switch( (*( sm->p)) ) {
		case 84: goto st279;
		case 116: goto st279;
	}
	goto tr182;
st279:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof279;
case 279:
	if ( (*( sm->p)) == 93 )
		goto tr279;
	goto tr182;
st280:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof280;
case 280:
	if ( (*( sm->p)) == 96 )
		goto st281;
	goto tr182;
st281:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof281;
case 281:
	if ( (*( sm->p)) == 96 )
		goto st282;
	goto tr182;
tr328:
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
#line 72 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
	goto st282;
st282:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof282;
case 282:
#line 7078 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr327;
		case 9: goto tr328;
		case 10: goto tr327;
		case 32: goto tr328;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr329;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr329;
	} else
		goto tr329;
	goto tr182;
tr338:
#line 72 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
	goto st283;
tr327:
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
#line 72 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
	goto st283;
st283:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof283;
case 283:
#line 7104 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr331;
		case 10: goto tr331;
	}
	goto tr330;
tr330:
#line 73 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st284;
st284:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof284;
case 284:
#line 7116 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr333;
		case 10: goto tr333;
	}
	goto st284;
tr333:
#line 74 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
	goto st285;
tr331:
#line 73 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
#line 74 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
	goto st285;
st285:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof285;
case 285:
#line 7132 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr333;
		case 10: goto tr333;
		case 96: goto st286;
	}
	goto st284;
st286:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof286;
case 286:
	switch( (*( sm->p)) ) {
		case 0: goto tr333;
		case 10: goto tr333;
		case 96: goto st287;
	}
	goto st284;
st287:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof287;
case 287:
	switch( (*( sm->p)) ) {
		case 0: goto tr333;
		case 10: goto tr333;
		case 96: goto st288;
	}
	goto st284;
st288:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof288;
case 288:
	switch( (*( sm->p)) ) {
		case 0: goto tr337;
		case 9: goto st288;
		case 10: goto tr337;
		case 32: goto st288;
	}
	goto st284;
tr329:
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st289;
st289:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof289;
case 289:
#line 7176 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr338;
		case 9: goto tr339;
		case 10: goto tr338;
		case 32: goto tr339;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st289;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st289;
	} else
		goto st289;
	goto tr182;
tr339:
#line 72 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
	goto st290;
st290:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof290;
case 290:
#line 7198 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto st283;
		case 9: goto st290;
		case 10: goto st283;
		case 32: goto st290;
	}
	goto tr182;
tr1735:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 579 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 95;}
	goto st1343;
st1343:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1343;
case 1343:
#line 7213 "ext/dtext/dtext.cpp"
	if ( (*( sm->p)) == 34 )
		goto tr1759;
	goto tr1779;
tr1779:
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st291;
st291:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof291;
case 291:
#line 7223 "ext/dtext/dtext.cpp"
	if ( (*( sm->p)) == 34 )
		goto tr344;
	goto st291;
tr344:
#line 72 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
	goto st292;
st292:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof292;
case 292:
#line 7233 "ext/dtext/dtext.cpp"
	if ( (*( sm->p)) == 58 )
		goto st293;
	goto tr180;
st293:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof293;
case 293:
	switch( (*( sm->p)) ) {
		case 35: goto tr346;
		case 47: goto tr347;
		case 72: goto tr348;
		case 91: goto st352;
		case 104: goto tr348;
	}
	goto tr180;
tr346:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 73 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
#line 74 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
	goto st1344;
tr351:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 74 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
	goto st1344;
st1344:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1344;
case 1344:
#line 7261 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case -30: goto st296;
		case -29: goto st298;
		case -17: goto st300;
		case 32: goto tr1780;
		case 34: goto st304;
		case 35: goto tr1780;
		case 39: goto st304;
		case 44: goto st304;
		case 46: goto st304;
		case 60: goto tr1780;
		case 62: goto tr1780;
		case 63: goto st304;
		case 91: goto tr1780;
		case 93: goto tr1780;
	}
	if ( (*( sm->p)) < -16 ) {
		if ( (*( sm->p)) < -62 ) {
			if ( (*( sm->p)) <= -63 )
				goto tr1780;
		} else if ( (*( sm->p)) > -33 ) {
			if ( -32 <= (*( sm->p)) && (*( sm->p)) <= -18 )
				goto st295;
		} else
			goto st294;
	} else if ( (*( sm->p)) > -12 ) {
		if ( (*( sm->p)) < 9 ) {
			if ( -11 <= (*( sm->p)) && (*( sm->p)) <= 0 )
				goto tr1780;
		} else if ( (*( sm->p)) > 13 ) {
			if ( 58 <= (*( sm->p)) && (*( sm->p)) <= 59 )
				goto st304;
		} else
			goto tr1780;
	} else
		goto st303;
	goto tr351;
st294:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof294;
case 294:
	if ( (*( sm->p)) <= -65 )
		goto tr351;
	goto tr350;
st295:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof295;
case 295:
	if ( (*( sm->p)) <= -65 )
		goto st294;
	goto tr350;
st296:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof296;
case 296:
	if ( (*( sm->p)) == -99 )
		goto st297;
	if ( (*( sm->p)) <= -65 )
		goto st294;
	goto tr350;
st297:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof297;
case 297:
	if ( (*( sm->p)) > -84 ) {
		if ( -82 <= (*( sm->p)) && (*( sm->p)) <= -65 )
			goto tr351;
	} else
		goto tr351;
	goto tr350;
st298:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof298;
case 298:
	if ( (*( sm->p)) == -128 )
		goto st299;
	if ( -127 <= (*( sm->p)) && (*( sm->p)) <= -65 )
		goto st294;
	goto tr350;
st299:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof299;
case 299:
	if ( (*( sm->p)) < -110 ) {
		if ( -125 <= (*( sm->p)) && (*( sm->p)) <= -121 )
			goto tr351;
	} else if ( (*( sm->p)) > -109 ) {
		if ( -99 <= (*( sm->p)) && (*( sm->p)) <= -65 )
			goto tr351;
	} else
		goto tr351;
	goto tr350;
st300:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof300;
case 300:
	switch( (*( sm->p)) ) {
		case -68: goto st301;
		case -67: goto st302;
	}
	if ( (*( sm->p)) <= -65 )
		goto st294;
	goto tr350;
st301:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof301;
case 301:
	if ( (*( sm->p)) < -118 ) {
		if ( (*( sm->p)) <= -120 )
			goto tr351;
	} else if ( (*( sm->p)) > -68 ) {
		if ( -66 <= (*( sm->p)) && (*( sm->p)) <= -65 )
			goto tr351;
	} else
		goto tr351;
	goto tr350;
st302:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof302;
case 302:
	if ( (*( sm->p)) < -98 ) {
		if ( (*( sm->p)) <= -100 )
			goto tr351;
	} else if ( (*( sm->p)) > -97 ) {
		if ( (*( sm->p)) > -94 ) {
			if ( -92 <= (*( sm->p)) && (*( sm->p)) <= -65 )
				goto tr351;
		} else if ( (*( sm->p)) >= -95 )
			goto tr351;
	} else
		goto tr351;
	goto tr350;
st303:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof303;
case 303:
	if ( (*( sm->p)) <= -65 )
		goto st295;
	goto tr350;
st304:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof304;
case 304:
	switch( (*( sm->p)) ) {
		case -30: goto st296;
		case -29: goto st298;
		case -17: goto st300;
		case 32: goto tr350;
		case 34: goto st304;
		case 35: goto tr350;
		case 39: goto st304;
		case 44: goto st304;
		case 46: goto st304;
		case 60: goto tr350;
		case 62: goto tr350;
		case 63: goto st304;
		case 91: goto tr350;
		case 93: goto tr350;
	}
	if ( (*( sm->p)) < -16 ) {
		if ( (*( sm->p)) < -62 ) {
			if ( (*( sm->p)) <= -63 )
				goto tr350;
		} else if ( (*( sm->p)) > -33 ) {
			if ( -32 <= (*( sm->p)) && (*( sm->p)) <= -18 )
				goto st295;
		} else
			goto st294;
	} else if ( (*( sm->p)) > -12 ) {
		if ( (*( sm->p)) < 9 ) {
			if ( -11 <= (*( sm->p)) && (*( sm->p)) <= 0 )
				goto tr350;
		} else if ( (*( sm->p)) > 13 ) {
			if ( 58 <= (*( sm->p)) && (*( sm->p)) <= 59 )
				goto st304;
		} else
			goto tr350;
	} else
		goto st303;
	goto tr351;
tr347:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 73 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
#line 74 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
#line 359 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 53;}
	goto st1345;
tr363:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 74 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
#line 359 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 53;}
	goto st1345;
st1345:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1345;
case 1345:
#line 7456 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case -30: goto st307;
		case -29: goto st309;
		case -17: goto st311;
		case 32: goto tr1780;
		case 34: goto st315;
		case 35: goto tr351;
		case 39: goto st315;
		case 44: goto st315;
		case 46: goto st315;
		case 60: goto tr1780;
		case 62: goto tr1780;
		case 63: goto st316;
		case 91: goto tr1780;
		case 93: goto tr1780;
	}
	if ( (*( sm->p)) < -16 ) {
		if ( (*( sm->p)) < -62 ) {
			if ( (*( sm->p)) <= -63 )
				goto tr1780;
		} else if ( (*( sm->p)) > -33 ) {
			if ( -32 <= (*( sm->p)) && (*( sm->p)) <= -18 )
				goto st306;
		} else
			goto st305;
	} else if ( (*( sm->p)) > -12 ) {
		if ( (*( sm->p)) < 9 ) {
			if ( -11 <= (*( sm->p)) && (*( sm->p)) <= 0 )
				goto tr1780;
		} else if ( (*( sm->p)) > 13 ) {
			if ( 58 <= (*( sm->p)) && (*( sm->p)) <= 59 )
				goto st315;
		} else
			goto tr1780;
	} else
		goto st314;
	goto tr363;
st305:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof305;
case 305:
	if ( (*( sm->p)) <= -65 )
		goto tr363;
	goto tr350;
st306:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof306;
case 306:
	if ( (*( sm->p)) <= -65 )
		goto st305;
	goto tr350;
st307:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof307;
case 307:
	if ( (*( sm->p)) == -99 )
		goto st308;
	if ( (*( sm->p)) <= -65 )
		goto st305;
	goto tr350;
st308:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof308;
case 308:
	if ( (*( sm->p)) > -84 ) {
		if ( -82 <= (*( sm->p)) && (*( sm->p)) <= -65 )
			goto tr363;
	} else
		goto tr363;
	goto tr350;
st309:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof309;
case 309:
	if ( (*( sm->p)) == -128 )
		goto st310;
	if ( -127 <= (*( sm->p)) && (*( sm->p)) <= -65 )
		goto st305;
	goto tr350;
st310:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof310;
case 310:
	if ( (*( sm->p)) < -110 ) {
		if ( -125 <= (*( sm->p)) && (*( sm->p)) <= -121 )
			goto tr363;
	} else if ( (*( sm->p)) > -109 ) {
		if ( -99 <= (*( sm->p)) && (*( sm->p)) <= -65 )
			goto tr363;
	} else
		goto tr363;
	goto tr350;
st311:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof311;
case 311:
	switch( (*( sm->p)) ) {
		case -68: goto st312;
		case -67: goto st313;
	}
	if ( (*( sm->p)) <= -65 )
		goto st305;
	goto tr350;
st312:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof312;
case 312:
	if ( (*( sm->p)) < -118 ) {
		if ( (*( sm->p)) <= -120 )
			goto tr363;
	} else if ( (*( sm->p)) > -68 ) {
		if ( -66 <= (*( sm->p)) && (*( sm->p)) <= -65 )
			goto tr363;
	} else
		goto tr363;
	goto tr350;
st313:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof313;
case 313:
	if ( (*( sm->p)) < -98 ) {
		if ( (*( sm->p)) <= -100 )
			goto tr363;
	} else if ( (*( sm->p)) > -97 ) {
		if ( (*( sm->p)) > -94 ) {
			if ( -92 <= (*( sm->p)) && (*( sm->p)) <= -65 )
				goto tr363;
		} else if ( (*( sm->p)) >= -95 )
			goto tr363;
	} else
		goto tr363;
	goto tr350;
st314:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof314;
case 314:
	if ( (*( sm->p)) <= -65 )
		goto st306;
	goto tr350;
st315:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof315;
case 315:
	switch( (*( sm->p)) ) {
		case -30: goto st307;
		case -29: goto st309;
		case -17: goto st311;
		case 32: goto tr350;
		case 34: goto st315;
		case 35: goto tr351;
		case 39: goto st315;
		case 44: goto st315;
		case 46: goto st315;
		case 60: goto tr350;
		case 62: goto tr350;
		case 63: goto st316;
		case 91: goto tr350;
		case 93: goto tr350;
	}
	if ( (*( sm->p)) < -16 ) {
		if ( (*( sm->p)) < -62 ) {
			if ( (*( sm->p)) <= -63 )
				goto tr350;
		} else if ( (*( sm->p)) > -33 ) {
			if ( -32 <= (*( sm->p)) && (*( sm->p)) <= -18 )
				goto st306;
		} else
			goto st305;
	} else if ( (*( sm->p)) > -12 ) {
		if ( (*( sm->p)) < 9 ) {
			if ( -11 <= (*( sm->p)) && (*( sm->p)) <= 0 )
				goto tr350;
		} else if ( (*( sm->p)) > 13 ) {
			if ( 58 <= (*( sm->p)) && (*( sm->p)) <= 59 )
				goto st315;
		} else
			goto tr350;
	} else
		goto st314;
	goto tr363;
st316:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof316;
case 316:
	switch( (*( sm->p)) ) {
		case -30: goto st319;
		case -29: goto st321;
		case -17: goto st323;
		case 32: goto tr173;
		case 34: goto st316;
		case 35: goto tr351;
		case 39: goto st316;
		case 44: goto st316;
		case 46: goto st316;
		case 63: goto st316;
	}
	if ( (*( sm->p)) < -16 ) {
		if ( (*( sm->p)) < -62 ) {
			if ( (*( sm->p)) <= -63 )
				goto tr173;
		} else if ( (*( sm->p)) > -33 ) {
			if ( -32 <= (*( sm->p)) && (*( sm->p)) <= -18 )
				goto st318;
		} else
			goto st317;
	} else if ( (*( sm->p)) > -12 ) {
		if ( (*( sm->p)) < 9 ) {
			if ( -11 <= (*( sm->p)) && (*( sm->p)) <= 0 )
				goto tr173;
		} else if ( (*( sm->p)) > 13 ) {
			if ( 58 <= (*( sm->p)) && (*( sm->p)) <= 59 )
				goto st316;
		} else
			goto tr173;
	} else
		goto st326;
	goto tr382;
st317:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof317;
case 317:
	if ( (*( sm->p)) <= -65 )
		goto tr382;
	goto tr173;
tr382:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 74 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
#line 359 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 53;}
	goto st1346;
st1346:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1346;
case 1346:
#line 7689 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case -30: goto st319;
		case -29: goto st321;
		case -17: goto st323;
		case 32: goto tr1780;
		case 34: goto st316;
		case 35: goto tr351;
		case 39: goto st316;
		case 44: goto st316;
		case 46: goto st316;
		case 63: goto st316;
	}
	if ( (*( sm->p)) < -16 ) {
		if ( (*( sm->p)) < -62 ) {
			if ( (*( sm->p)) <= -63 )
				goto tr1780;
		} else if ( (*( sm->p)) > -33 ) {
			if ( -32 <= (*( sm->p)) && (*( sm->p)) <= -18 )
				goto st318;
		} else
			goto st317;
	} else if ( (*( sm->p)) > -12 ) {
		if ( (*( sm->p)) < 9 ) {
			if ( -11 <= (*( sm->p)) && (*( sm->p)) <= 0 )
				goto tr1780;
		} else if ( (*( sm->p)) > 13 ) {
			if ( 58 <= (*( sm->p)) && (*( sm->p)) <= 59 )
				goto st316;
		} else
			goto tr1780;
	} else
		goto st326;
	goto tr382;
st318:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof318;
case 318:
	if ( (*( sm->p)) <= -65 )
		goto st317;
	goto tr173;
st319:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof319;
case 319:
	if ( (*( sm->p)) == -99 )
		goto st320;
	if ( (*( sm->p)) <= -65 )
		goto st317;
	goto tr173;
st320:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof320;
case 320:
	if ( (*( sm->p)) > -84 ) {
		if ( -82 <= (*( sm->p)) && (*( sm->p)) <= -65 )
			goto tr382;
	} else
		goto tr382;
	goto tr173;
st321:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof321;
case 321:
	if ( (*( sm->p)) == -128 )
		goto st322;
	if ( -127 <= (*( sm->p)) && (*( sm->p)) <= -65 )
		goto st317;
	goto tr173;
st322:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof322;
case 322:
	if ( (*( sm->p)) < -110 ) {
		if ( -125 <= (*( sm->p)) && (*( sm->p)) <= -121 )
			goto tr382;
	} else if ( (*( sm->p)) > -109 ) {
		if ( -99 <= (*( sm->p)) && (*( sm->p)) <= -65 )
			goto tr382;
	} else
		goto tr382;
	goto tr173;
st323:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof323;
case 323:
	switch( (*( sm->p)) ) {
		case -68: goto st324;
		case -67: goto st325;
	}
	if ( (*( sm->p)) <= -65 )
		goto st317;
	goto tr173;
st324:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof324;
case 324:
	if ( (*( sm->p)) < -118 ) {
		if ( (*( sm->p)) <= -120 )
			goto tr382;
	} else if ( (*( sm->p)) > -68 ) {
		if ( -66 <= (*( sm->p)) && (*( sm->p)) <= -65 )
			goto tr382;
	} else
		goto tr382;
	goto tr173;
st325:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof325;
case 325:
	if ( (*( sm->p)) < -98 ) {
		if ( (*( sm->p)) <= -100 )
			goto tr382;
	} else if ( (*( sm->p)) > -97 ) {
		if ( (*( sm->p)) > -94 ) {
			if ( -92 <= (*( sm->p)) && (*( sm->p)) <= -65 )
				goto tr382;
		} else if ( (*( sm->p)) >= -95 )
			goto tr382;
	} else
		goto tr382;
	goto tr173;
st326:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof326;
case 326:
	if ( (*( sm->p)) <= -65 )
		goto st318;
	goto tr173;
tr348:
#line 73 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st327;
st327:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof327;
case 327:
#line 7824 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 84: goto st328;
		case 116: goto st328;
	}
	goto tr180;
st328:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof328;
case 328:
	switch( (*( sm->p)) ) {
		case 84: goto st329;
		case 116: goto st329;
	}
	goto tr180;
st329:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof329;
case 329:
	switch( (*( sm->p)) ) {
		case 80: goto st330;
		case 112: goto st330;
	}
	goto tr180;
st330:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof330;
case 330:
	switch( (*( sm->p)) ) {
		case 58: goto st331;
		case 83: goto st351;
		case 115: goto st351;
	}
	goto tr180;
st331:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof331;
case 331:
	if ( (*( sm->p)) == 47 )
		goto st332;
	goto tr180;
st332:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof332;
case 332:
	if ( (*( sm->p)) == 47 )
		goto st333;
	goto tr180;
st333:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof333;
case 333:
	switch( (*( sm->p)) ) {
		case 45: goto st335;
		case 95: goto st335;
	}
	if ( (*( sm->p)) < -16 ) {
		if ( (*( sm->p)) > -33 ) {
			if ( -32 <= (*( sm->p)) && (*( sm->p)) <= -17 )
				goto st336;
		} else if ( (*( sm->p)) >= -62 )
			goto st334;
	} else if ( (*( sm->p)) > -12 ) {
		if ( (*( sm->p)) < 65 ) {
			if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
				goto st335;
		} else if ( (*( sm->p)) > 90 ) {
			if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
				goto st335;
		} else
			goto st335;
	} else
		goto st337;
	goto tr180;
st334:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof334;
case 334:
	if ( (*( sm->p)) <= -65 )
		goto st335;
	goto tr180;
st335:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof335;
case 335:
	switch( (*( sm->p)) ) {
		case 45: goto st335;
		case 46: goto st338;
		case 95: goto st335;
	}
	if ( (*( sm->p)) < -16 ) {
		if ( (*( sm->p)) > -33 ) {
			if ( -32 <= (*( sm->p)) && (*( sm->p)) <= -17 )
				goto st336;
		} else if ( (*( sm->p)) >= -62 )
			goto st334;
	} else if ( (*( sm->p)) > -12 ) {
		if ( (*( sm->p)) < 65 ) {
			if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
				goto st335;
		} else if ( (*( sm->p)) > 90 ) {
			if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
				goto st335;
		} else
			goto st335;
	} else
		goto st337;
	goto tr180;
st336:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof336;
case 336:
	if ( (*( sm->p)) <= -65 )
		goto st334;
	goto tr180;
st337:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof337;
case 337:
	if ( (*( sm->p)) <= -65 )
		goto st336;
	goto tr180;
st338:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof338;
case 338:
	switch( (*( sm->p)) ) {
		case -30: goto st341;
		case -29: goto st344;
		case -17: goto st346;
		case 45: goto tr405;
		case 95: goto tr405;
	}
	if ( (*( sm->p)) < -16 ) {
		if ( (*( sm->p)) > -33 ) {
			if ( -32 <= (*( sm->p)) && (*( sm->p)) <= -18 )
				goto st340;
		} else if ( (*( sm->p)) >= -62 )
			goto st339;
	} else if ( (*( sm->p)) > -12 ) {
		if ( (*( sm->p)) < 65 ) {
			if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
				goto tr405;
		} else if ( (*( sm->p)) > 90 ) {
			if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
				goto tr405;
		} else
			goto tr405;
	} else
		goto st349;
	goto tr173;
st339:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof339;
case 339:
	if ( (*( sm->p)) <= -65 )
		goto tr405;
	goto tr173;
tr405:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 74 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
#line 359 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 53;}
	goto st1347;
st1347:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1347;
case 1347:
#line 7990 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case -30: goto st341;
		case -29: goto st344;
		case -17: goto st346;
		case 35: goto tr351;
		case 46: goto st338;
		case 47: goto tr363;
		case 58: goto st350;
		case 63: goto st316;
		case 95: goto tr405;
	}
	if ( (*( sm->p)) < -16 ) {
		if ( (*( sm->p)) > -33 ) {
			if ( -32 <= (*( sm->p)) && (*( sm->p)) <= -18 )
				goto st340;
		} else if ( (*( sm->p)) >= -62 )
			goto st339;
	} else if ( (*( sm->p)) > -12 ) {
		if ( (*( sm->p)) < 65 ) {
			if ( 45 <= (*( sm->p)) && (*( sm->p)) <= 57 )
				goto tr405;
		} else if ( (*( sm->p)) > 90 ) {
			if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
				goto tr405;
		} else
			goto tr405;
	} else
		goto st349;
	goto tr1780;
st340:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof340;
case 340:
	if ( (*( sm->p)) <= -65 )
		goto st339;
	goto tr173;
st341:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof341;
case 341:
	if ( (*( sm->p)) == -99 )
		goto st342;
	if ( (*( sm->p)) <= -65 )
		goto st339;
	goto tr173;
st342:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof342;
case 342:
	if ( (*( sm->p)) == -83 )
		goto st343;
	if ( (*( sm->p)) <= -65 )
		goto tr405;
	goto tr173;
st343:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof343;
case 343:
	switch( (*( sm->p)) ) {
		case -30: goto st341;
		case -29: goto st344;
		case -17: goto st346;
		case 35: goto tr351;
		case 46: goto st338;
		case 47: goto tr363;
		case 58: goto st350;
		case 63: goto st316;
		case 95: goto tr405;
	}
	if ( (*( sm->p)) < -16 ) {
		if ( (*( sm->p)) > -33 ) {
			if ( -32 <= (*( sm->p)) && (*( sm->p)) <= -18 )
				goto st340;
		} else if ( (*( sm->p)) >= -62 )
			goto st339;
	} else if ( (*( sm->p)) > -12 ) {
		if ( (*( sm->p)) < 65 ) {
			if ( 45 <= (*( sm->p)) && (*( sm->p)) <= 57 )
				goto tr405;
		} else if ( (*( sm->p)) > 90 ) {
			if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
				goto tr405;
		} else
			goto tr405;
	} else
		goto st349;
	goto tr173;
st344:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof344;
case 344:
	if ( (*( sm->p)) == -128 )
		goto st345;
	if ( -127 <= (*( sm->p)) && (*( sm->p)) <= -65 )
		goto st339;
	goto tr173;
st345:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof345;
case 345:
	if ( (*( sm->p)) < -120 ) {
		if ( (*( sm->p)) > -126 ) {
			if ( -125 <= (*( sm->p)) && (*( sm->p)) <= -121 )
				goto tr405;
		} else
			goto st343;
	} else if ( (*( sm->p)) > -111 ) {
		if ( (*( sm->p)) < -108 ) {
			if ( -110 <= (*( sm->p)) && (*( sm->p)) <= -109 )
				goto tr405;
		} else if ( (*( sm->p)) > -100 ) {
			if ( -99 <= (*( sm->p)) && (*( sm->p)) <= -65 )
				goto tr405;
		} else
			goto st343;
	} else
		goto st343;
	goto tr173;
st346:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof346;
case 346:
	switch( (*( sm->p)) ) {
		case -68: goto st347;
		case -67: goto st348;
	}
	if ( (*( sm->p)) <= -65 )
		goto st339;
	goto tr173;
st347:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof347;
case 347:
	switch( (*( sm->p)) ) {
		case -119: goto st343;
		case -67: goto st343;
	}
	if ( (*( sm->p)) <= -65 )
		goto tr405;
	goto tr173;
st348:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof348;
case 348:
	switch( (*( sm->p)) ) {
		case -99: goto st343;
		case -96: goto st343;
		case -93: goto st343;
	}
	if ( (*( sm->p)) <= -65 )
		goto tr405;
	goto tr173;
st349:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof349;
case 349:
	if ( (*( sm->p)) <= -65 )
		goto st340;
	goto tr173;
st350:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof350;
case 350:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr412;
	goto tr173;
tr412:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 74 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
#line 359 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 53;}
	goto st1348;
st1348:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1348;
case 1348:
#line 8165 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 35: goto tr351;
		case 47: goto tr363;
		case 63: goto st316;
	}
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr412;
	goto tr1780;
st351:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof351;
case 351:
	if ( (*( sm->p)) == 58 )
		goto st331;
	goto tr180;
st352:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof352;
case 352:
	switch( (*( sm->p)) ) {
		case 35: goto tr413;
		case 47: goto tr413;
		case 72: goto tr414;
		case 104: goto tr414;
	}
	goto tr180;
tr413:
#line 73 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st353;
st353:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof353;
case 353:
#line 8198 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 32: goto tr180;
		case 93: goto tr416;
	}
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr180;
	goto st353;
tr414:
#line 73 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st354;
st354:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof354;
case 354:
#line 8213 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 84: goto st355;
		case 116: goto st355;
	}
	goto tr180;
st355:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof355;
case 355:
	switch( (*( sm->p)) ) {
		case 84: goto st356;
		case 116: goto st356;
	}
	goto tr180;
st356:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof356;
case 356:
	switch( (*( sm->p)) ) {
		case 80: goto st357;
		case 112: goto st357;
	}
	goto tr180;
st357:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof357;
case 357:
	switch( (*( sm->p)) ) {
		case 58: goto st358;
		case 83: goto st361;
		case 115: goto st361;
	}
	goto tr180;
st358:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof358;
case 358:
	if ( (*( sm->p)) == 47 )
		goto st359;
	goto tr180;
st359:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof359;
case 359:
	if ( (*( sm->p)) == 47 )
		goto st360;
	goto tr180;
st360:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof360;
case 360:
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 32: goto tr180;
	}
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr180;
	goto st353;
st361:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof361;
case 361:
	if ( (*( sm->p)) == 58 )
		goto st358;
	goto tr180;
tr1781:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 575 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 94;}
	goto st1349;
tr1736:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
#line 575 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 94;}
	goto st1349;
st1349:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1349;
case 1349:
#line 8291 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 91: goto tr1782;
		case 123: goto tr1783;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1781;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1781;
	} else
		goto tr1781;
	goto tr1760;
tr1782:
#line 72 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
	goto st362;
st362:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof362;
case 362:
#line 8311 "ext/dtext/dtext.cpp"
	if ( (*( sm->p)) == 91 )
		goto st363;
	goto tr176;
tr426:
#line 73 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st363;
st363:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof363;
case 363:
#line 8321 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto tr426;
		case 32: goto tr426;
		case 58: goto tr428;
		case 60: goto tr429;
		case 62: goto tr430;
		case 92: goto tr431;
		case 93: goto tr176;
		case 124: goto tr432;
	}
	if ( 10 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr427;
	goto tr425;
tr425:
#line 73 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st364;
st364:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof364;
case 364:
#line 8341 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto tr434;
		case 32: goto tr434;
		case 35: goto tr436;
		case 93: goto tr437;
		case 124: goto tr438;
	}
	if ( 10 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto st366;
	goto st364;
tr434:
#line 74 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
	goto st365;
st365:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof365;
case 365:
#line 8358 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto st365;
		case 32: goto st365;
		case 35: goto st367;
		case 93: goto st370;
		case 124: goto st371;
	}
	if ( 10 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto st366;
	goto st364;
tr427:
#line 73 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st366;
st366:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof366;
case 366:
#line 8375 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 32: goto st366;
		case 93: goto tr173;
		case 124: goto tr173;
	}
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto st366;
	goto st364;
tr436:
#line 74 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
	goto st367;
st367:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof367;
case 367:
#line 8390 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto tr434;
		case 32: goto tr434;
		case 35: goto tr436;
		case 93: goto tr437;
		case 124: goto tr438;
	}
	if ( (*( sm->p)) > 13 ) {
		if ( 65 <= (*( sm->p)) && (*( sm->p)) <= 90 )
			goto tr443;
	} else if ( (*( sm->p)) >= 10 )
		goto st366;
	goto st364;
tr443:
#line 75 "ext/dtext/dtext.cpp.rl"
	{ sm->c1 = sm->p; }
	goto st368;
st368:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof368;
case 368:
#line 8410 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto tr444;
		case 32: goto tr445;
		case 45: goto st376;
		case 93: goto tr448;
		case 95: goto st376;
		case 124: goto tr449;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st368;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st368;
	} else
		goto st368;
	goto tr173;
tr444:
#line 76 "ext/dtext/dtext.cpp.rl"
	{ sm->c2 = sm->p; }
	goto st369;
st369:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof369;
case 369:
#line 8434 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto st369;
		case 32: goto st369;
		case 93: goto st370;
		case 124: goto st371;
	}
	goto tr173;
tr437:
#line 74 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
	goto st370;
tr448:
#line 76 "ext/dtext/dtext.cpp.rl"
	{ sm->c2 = sm->p; }
	goto st370;
st370:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof370;
case 370:
#line 8451 "ext/dtext/dtext.cpp"
	if ( (*( sm->p)) == 93 )
		goto st1350;
	goto tr173;
st1350:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1350;
case 1350:
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1785;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1785;
	} else
		goto tr1785;
	goto tr1784;
tr1785:
#line 79 "ext/dtext/dtext.cpp.rl"
	{ sm->e1 = sm->p; }
	goto st1351;
st1351:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1351;
case 1351:
#line 8474 "ext/dtext/dtext.cpp"
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st1351;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st1351;
	} else
		goto st1351;
	goto tr1786;
tr438:
#line 74 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
	goto st371;
tr449:
#line 76 "ext/dtext/dtext.cpp.rl"
	{ sm->c2 = sm->p; }
	goto st371;
tr453:
#line 77 "ext/dtext/dtext.cpp.rl"
	{ sm->d1 = sm->p; }
#line 78 "ext/dtext/dtext.cpp.rl"
	{ sm->d2 = sm->p; }
	goto st371;
st371:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof371;
case 371:
#line 8497 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto tr453;
		case 32: goto tr453;
		case 93: goto tr454;
		case 124: goto tr173;
	}
	if ( 10 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr173;
	goto tr452;
tr452:
#line 77 "ext/dtext/dtext.cpp.rl"
	{ sm->d1 = sm->p; }
	goto st372;
st372:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof372;
case 372:
#line 8513 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto tr456;
		case 32: goto tr456;
		case 93: goto tr457;
		case 124: goto tr173;
	}
	if ( 10 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr173;
	goto st372;
tr456:
#line 78 "ext/dtext/dtext.cpp.rl"
	{ sm->d2 = sm->p; }
	goto st373;
st373:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof373;
case 373:
#line 8529 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto st373;
		case 32: goto st373;
		case 93: goto st374;
		case 124: goto tr173;
	}
	if ( 10 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr173;
	goto st372;
tr454:
#line 77 "ext/dtext/dtext.cpp.rl"
	{ sm->d1 = sm->p; }
#line 78 "ext/dtext/dtext.cpp.rl"
	{ sm->d2 = sm->p; }
	goto st374;
tr457:
#line 78 "ext/dtext/dtext.cpp.rl"
	{ sm->d2 = sm->p; }
	goto st374;
st374:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof374;
case 374:
#line 8549 "ext/dtext/dtext.cpp"
	if ( (*( sm->p)) == 93 )
		goto st1352;
	goto tr173;
st1352:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1352;
case 1352:
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1789;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1789;
	} else
		goto tr1789;
	goto tr1788;
tr1789:
#line 79 "ext/dtext/dtext.cpp.rl"
	{ sm->e1 = sm->p; }
	goto st1353;
st1353:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1353;
case 1353:
#line 8572 "ext/dtext/dtext.cpp"
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st1353;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st1353;
	} else
		goto st1353;
	goto tr1790;
tr445:
#line 76 "ext/dtext/dtext.cpp.rl"
	{ sm->c2 = sm->p; }
	goto st375;
st375:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof375;
case 375:
#line 8588 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto st369;
		case 32: goto st375;
		case 45: goto st376;
		case 93: goto st370;
		case 95: goto st376;
		case 124: goto st371;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st368;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st368;
	} else
		goto st368;
	goto tr173;
st376:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof376;
case 376:
	switch( (*( sm->p)) ) {
		case 32: goto st376;
		case 45: goto st376;
		case 95: goto st376;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st368;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st368;
	} else
		goto st368;
	goto tr173;
tr428:
#line 73 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st377;
st377:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof377;
case 377:
#line 8630 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto tr434;
		case 32: goto tr434;
		case 35: goto tr436;
		case 93: goto tr437;
		case 124: goto tr462;
	}
	if ( 10 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto st366;
	goto st364;
tr462:
#line 74 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
	goto st378;
st378:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof378;
case 378:
#line 8647 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto tr463;
		case 32: goto tr463;
		case 35: goto tr464;
		case 93: goto tr465;
		case 124: goto tr176;
	}
	if ( 10 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr176;
	goto tr452;
tr466:
#line 77 "ext/dtext/dtext.cpp.rl"
	{ sm->d1 = sm->p; }
#line 78 "ext/dtext/dtext.cpp.rl"
	{ sm->d2 = sm->p; }
	goto st379;
tr463:
#line 74 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
#line 77 "ext/dtext/dtext.cpp.rl"
	{ sm->d1 = sm->p; }
#line 78 "ext/dtext/dtext.cpp.rl"
	{ sm->d2 = sm->p; }
	goto st379;
st379:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof379;
case 379:
#line 8670 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto tr466;
		case 32: goto tr466;
		case 35: goto tr467;
		case 93: goto tr468;
		case 124: goto tr176;
	}
	if ( 10 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr176;
	goto tr452;
tr502:
#line 74 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
	goto st380;
tr467:
#line 77 "ext/dtext/dtext.cpp.rl"
	{ sm->d1 = sm->p; }
	goto st380;
tr464:
#line 74 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
#line 77 "ext/dtext/dtext.cpp.rl"
	{ sm->d1 = sm->p; }
	goto st380;
st380:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof380;
case 380:
#line 8694 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto tr456;
		case 32: goto tr456;
		case 93: goto tr457;
		case 124: goto tr176;
	}
	if ( (*( sm->p)) > 13 ) {
		if ( 65 <= (*( sm->p)) && (*( sm->p)) <= 90 )
			goto tr469;
	} else if ( (*( sm->p)) >= 10 )
		goto tr176;
	goto st372;
tr469:
#line 75 "ext/dtext/dtext.cpp.rl"
	{ sm->c1 = sm->p; }
	goto st381;
st381:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof381;
case 381:
#line 8713 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto tr470;
		case 32: goto tr471;
		case 45: goto st385;
		case 93: goto tr474;
		case 95: goto st385;
		case 124: goto tr176;
	}
	if ( (*( sm->p)) < 48 ) {
		if ( 10 <= (*( sm->p)) && (*( sm->p)) <= 13 )
			goto tr176;
	} else if ( (*( sm->p)) > 57 ) {
		if ( (*( sm->p)) > 90 ) {
			if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
				goto st381;
		} else if ( (*( sm->p)) >= 65 )
			goto st381;
	} else
		goto st381;
	goto st372;
tr470:
#line 76 "ext/dtext/dtext.cpp.rl"
	{ sm->c2 = sm->p; }
#line 78 "ext/dtext/dtext.cpp.rl"
	{ sm->d2 = sm->p; }
	goto st382;
st382:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof382;
case 382:
#line 8741 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto st382;
		case 32: goto st382;
		case 93: goto st383;
		case 124: goto tr176;
	}
	if ( 10 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr176;
	goto st372;
tr468:
#line 77 "ext/dtext/dtext.cpp.rl"
	{ sm->d1 = sm->p; }
#line 78 "ext/dtext/dtext.cpp.rl"
	{ sm->d2 = sm->p; }
	goto st383;
tr465:
#line 74 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
#line 77 "ext/dtext/dtext.cpp.rl"
	{ sm->d1 = sm->p; }
#line 78 "ext/dtext/dtext.cpp.rl"
	{ sm->d2 = sm->p; }
	goto st383;
tr474:
#line 76 "ext/dtext/dtext.cpp.rl"
	{ sm->c2 = sm->p; }
#line 78 "ext/dtext/dtext.cpp.rl"
	{ sm->d2 = sm->p; }
	goto st383;
tr503:
#line 74 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
#line 78 "ext/dtext/dtext.cpp.rl"
	{ sm->d2 = sm->p; }
	goto st383;
st383:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof383;
case 383:
#line 8771 "ext/dtext/dtext.cpp"
	if ( (*( sm->p)) == 93 )
		goto st1354;
	goto tr176;
st1354:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1354;
case 1354:
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1792;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1792;
	} else
		goto tr1792;
	goto tr1784;
tr1792:
#line 79 "ext/dtext/dtext.cpp.rl"
	{ sm->e1 = sm->p; }
	goto st1355;
st1355:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1355;
case 1355:
#line 8794 "ext/dtext/dtext.cpp"
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st1355;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st1355;
	} else
		goto st1355;
	goto tr1786;
tr471:
#line 76 "ext/dtext/dtext.cpp.rl"
	{ sm->c2 = sm->p; }
#line 78 "ext/dtext/dtext.cpp.rl"
	{ sm->d2 = sm->p; }
	goto st384;
st384:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof384;
case 384:
#line 8811 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto st382;
		case 32: goto st384;
		case 45: goto st385;
		case 93: goto st383;
		case 95: goto st385;
		case 124: goto tr176;
	}
	if ( (*( sm->p)) < 48 ) {
		if ( 10 <= (*( sm->p)) && (*( sm->p)) <= 13 )
			goto tr176;
	} else if ( (*( sm->p)) > 57 ) {
		if ( (*( sm->p)) > 90 ) {
			if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
				goto st381;
		} else if ( (*( sm->p)) >= 65 )
			goto st381;
	} else
		goto st381;
	goto st372;
st385:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof385;
case 385:
	switch( (*( sm->p)) ) {
		case 9: goto tr456;
		case 32: goto tr479;
		case 45: goto st385;
		case 93: goto tr457;
		case 95: goto st385;
		case 124: goto tr176;
	}
	if ( (*( sm->p)) < 48 ) {
		if ( 10 <= (*( sm->p)) && (*( sm->p)) <= 13 )
			goto tr176;
	} else if ( (*( sm->p)) > 57 ) {
		if ( (*( sm->p)) > 90 ) {
			if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
				goto st381;
		} else if ( (*( sm->p)) >= 65 )
			goto st381;
	} else
		goto st381;
	goto st372;
tr479:
#line 78 "ext/dtext/dtext.cpp.rl"
	{ sm->d2 = sm->p; }
	goto st386;
st386:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof386;
case 386:
#line 8862 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto st373;
		case 32: goto st386;
		case 45: goto st385;
		case 93: goto st374;
		case 95: goto st385;
		case 124: goto tr176;
	}
	if ( (*( sm->p)) < 48 ) {
		if ( 10 <= (*( sm->p)) && (*( sm->p)) <= 13 )
			goto tr176;
	} else if ( (*( sm->p)) > 57 ) {
		if ( (*( sm->p)) > 90 ) {
			if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
				goto st381;
		} else if ( (*( sm->p)) >= 65 )
			goto st381;
	} else
		goto st381;
	goto st372;
tr429:
#line 73 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st387;
st387:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof387;
case 387:
#line 8889 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto tr434;
		case 32: goto tr434;
		case 35: goto tr436;
		case 93: goto tr437;
		case 124: goto tr481;
	}
	if ( 10 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto st366;
	goto st364;
tr481:
#line 74 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
	goto st388;
st388:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof388;
case 388:
#line 8906 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto tr453;
		case 32: goto tr453;
		case 62: goto tr482;
		case 93: goto tr454;
		case 124: goto tr176;
	}
	if ( 10 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr176;
	goto tr452;
tr482:
#line 77 "ext/dtext/dtext.cpp.rl"
	{ sm->d1 = sm->p; }
	goto st389;
st389:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof389;
case 389:
#line 8923 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto tr456;
		case 32: goto tr456;
		case 93: goto tr457;
		case 95: goto st390;
		case 124: goto tr176;
	}
	if ( 10 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr176;
	goto st372;
st390:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof390;
case 390:
	switch( (*( sm->p)) ) {
		case 9: goto tr456;
		case 32: goto tr456;
		case 60: goto st391;
		case 93: goto tr457;
		case 124: goto tr176;
	}
	if ( 10 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr176;
	goto st372;
st391:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof391;
case 391:
	switch( (*( sm->p)) ) {
		case 9: goto tr456;
		case 32: goto tr456;
		case 93: goto tr457;
		case 124: goto st392;
	}
	if ( 10 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr176;
	goto st372;
st392:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof392;
case 392:
	if ( (*( sm->p)) == 62 )
		goto st393;
	goto tr176;
st393:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof393;
case 393:
	switch( (*( sm->p)) ) {
		case 9: goto tr487;
		case 32: goto tr487;
		case 35: goto tr488;
		case 93: goto tr437;
	}
	goto tr176;
tr487:
#line 74 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
	goto st394;
st394:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof394;
case 394:
#line 8985 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto st394;
		case 32: goto st394;
		case 35: goto st395;
		case 93: goto st370;
	}
	goto tr176;
tr488:
#line 74 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
	goto st395;
st395:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof395;
case 395:
#line 8999 "ext/dtext/dtext.cpp"
	if ( 65 <= (*( sm->p)) && (*( sm->p)) <= 90 )
		goto tr491;
	goto tr176;
tr491:
#line 75 "ext/dtext/dtext.cpp.rl"
	{ sm->c1 = sm->p; }
	goto st396;
st396:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof396;
case 396:
#line 9009 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto tr492;
		case 32: goto tr493;
		case 45: goto st399;
		case 93: goto tr448;
		case 95: goto st399;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st396;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st396;
	} else
		goto st396;
	goto tr176;
tr492:
#line 76 "ext/dtext/dtext.cpp.rl"
	{ sm->c2 = sm->p; }
	goto st397;
st397:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof397;
case 397:
#line 9032 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto st397;
		case 32: goto st397;
		case 93: goto st370;
	}
	goto tr176;
tr493:
#line 76 "ext/dtext/dtext.cpp.rl"
	{ sm->c2 = sm->p; }
	goto st398;
st398:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof398;
case 398:
#line 9045 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto st397;
		case 32: goto st398;
		case 45: goto st399;
		case 93: goto st370;
		case 95: goto st399;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st396;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st396;
	} else
		goto st396;
	goto tr176;
st399:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof399;
case 399:
	switch( (*( sm->p)) ) {
		case 32: goto st399;
		case 45: goto st399;
		case 95: goto st399;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st396;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st396;
	} else
		goto st396;
	goto tr176;
tr430:
#line 73 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st400;
st400:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof400;
case 400:
#line 9086 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto tr434;
		case 32: goto tr434;
		case 35: goto tr436;
		case 58: goto st377;
		case 93: goto tr437;
		case 124: goto tr499;
	}
	if ( 10 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto st366;
	goto st364;
tr499:
#line 74 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
	goto st401;
st401:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof401;
case 401:
#line 9104 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto tr453;
		case 32: goto tr453;
		case 51: goto tr500;
		case 93: goto tr454;
		case 124: goto tr176;
	}
	if ( 10 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr176;
	goto tr452;
tr500:
#line 77 "ext/dtext/dtext.cpp.rl"
	{ sm->d1 = sm->p; }
	goto st402;
st402:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof402;
case 402:
#line 9121 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto tr501;
		case 32: goto tr501;
		case 35: goto tr502;
		case 93: goto tr503;
		case 124: goto tr176;
	}
	if ( 10 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr176;
	goto st372;
tr501:
#line 74 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
#line 78 "ext/dtext/dtext.cpp.rl"
	{ sm->d2 = sm->p; }
	goto st403;
st403:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof403;
case 403:
#line 9139 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto st403;
		case 32: goto st403;
		case 35: goto st380;
		case 93: goto st383;
		case 124: goto tr176;
	}
	if ( 10 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr176;
	goto st372;
tr431:
#line 73 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st404;
st404:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof404;
case 404:
#line 9156 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto tr434;
		case 32: goto tr434;
		case 35: goto tr436;
		case 93: goto tr437;
		case 124: goto tr506;
	}
	if ( 10 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto st366;
	goto st364;
tr506:
#line 74 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
	goto st405;
st405:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof405;
case 405:
#line 9173 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto tr453;
		case 32: goto tr453;
		case 93: goto tr454;
		case 124: goto st406;
	}
	if ( 10 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr176;
	goto tr452;
st406:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof406;
case 406:
	if ( (*( sm->p)) == 47 )
		goto st393;
	goto tr176;
tr432:
#line 73 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st407;
st407:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof407;
case 407:
#line 9196 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 95: goto st411;
		case 119: goto st412;
		case 124: goto st413;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st408;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st408;
	} else
		goto st408;
	goto tr176;
st408:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof408;
case 408:
	switch( (*( sm->p)) ) {
		case 9: goto tr512;
		case 32: goto tr512;
		case 35: goto tr513;
		case 93: goto tr437;
		case 124: goto tr438;
	}
	goto tr176;
tr512:
#line 74 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
	goto st409;
st409:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof409;
case 409:
#line 9229 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto st409;
		case 32: goto st409;
		case 35: goto st410;
		case 93: goto st370;
		case 124: goto st371;
	}
	goto tr176;
tr513:
#line 74 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
	goto st410;
st410:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof410;
case 410:
#line 9244 "ext/dtext/dtext.cpp"
	if ( 65 <= (*( sm->p)) && (*( sm->p)) <= 90 )
		goto tr443;
	goto tr176;
st411:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof411;
case 411:
	if ( (*( sm->p)) == 124 )
		goto st408;
	goto tr176;
st412:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof412;
case 412:
	switch( (*( sm->p)) ) {
		case 9: goto tr512;
		case 32: goto tr512;
		case 35: goto tr513;
		case 93: goto tr437;
		case 124: goto tr462;
	}
	goto tr176;
st413:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof413;
case 413:
	if ( (*( sm->p)) == 95 )
		goto st414;
	goto tr176;
st414:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof414;
case 414:
	if ( (*( sm->p)) == 124 )
		goto st411;
	goto tr176;
tr1783:
#line 72 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
	goto st415;
st415:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof415;
case 415:
#line 9287 "ext/dtext/dtext.cpp"
	if ( (*( sm->p)) == 123 )
		goto st416;
	goto tr176;
st416:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof416;
case 416:
	switch( (*( sm->p)) ) {
		case 0: goto tr173;
		case 9: goto st416;
		case 32: goto st416;
		case 45: goto tr519;
		case 58: goto tr520;
		case 60: goto tr521;
		case 62: goto tr522;
		case 92: goto tr523;
		case 124: goto tr524;
		case 126: goto tr519;
	}
	if ( (*( sm->p)) > 13 ) {
		if ( 123 <= (*( sm->p)) && (*( sm->p)) <= 125 )
			goto tr173;
	} else if ( (*( sm->p)) >= 10 )
		goto tr173;
	goto tr518;
tr518:
#line 73 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st417;
st417:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof417;
case 417:
#line 9319 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr173;
		case 9: goto tr526;
		case 32: goto tr526;
		case 123: goto tr173;
		case 124: goto tr527;
		case 125: goto tr528;
	}
	if ( 10 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr173;
	goto st417;
tr526:
#line 74 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
	goto st418;
st418:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof418;
case 418:
#line 9337 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr173;
		case 9: goto st418;
		case 32: goto st418;
		case 45: goto st419;
		case 58: goto st420;
		case 60: goto st455;
		case 62: goto st456;
		case 92: goto st458;
		case 123: goto tr173;
		case 124: goto st449;
		case 125: goto st427;
		case 126: goto st419;
	}
	if ( 10 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr173;
	goto st417;
tr519:
#line 73 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st419;
st419:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof419;
case 419:
#line 9361 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr173;
		case 9: goto tr526;
		case 32: goto tr526;
		case 58: goto st420;
		case 60: goto st455;
		case 62: goto st456;
		case 92: goto st458;
		case 123: goto tr173;
		case 124: goto tr537;
		case 125: goto tr528;
	}
	if ( 10 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr173;
	goto st417;
tr520:
#line 73 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st420;
st420:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof420;
case 420:
#line 9383 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr173;
		case 9: goto tr526;
		case 32: goto tr526;
		case 123: goto st421;
		case 124: goto tr539;
		case 125: goto tr540;
	}
	if ( 10 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr173;
	goto st417;
st421:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof421;
case 421:
	switch( (*( sm->p)) ) {
		case 9: goto tr526;
		case 32: goto tr526;
		case 124: goto tr527;
		case 125: goto tr528;
	}
	goto tr173;
tr527:
#line 74 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
	goto st422;
tr542:
#line 75 "ext/dtext/dtext.cpp.rl"
	{ sm->c1 = sm->p; }
#line 76 "ext/dtext/dtext.cpp.rl"
	{ sm->c2 = sm->p; }
	goto st422;
tr554:
#line 74 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
#line 75 "ext/dtext/dtext.cpp.rl"
	{ sm->c1 = sm->p; }
	goto st422;
st422:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof422;
case 422:
#line 9420 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr173;
		case 9: goto tr542;
		case 10: goto tr173;
		case 13: goto tr173;
		case 32: goto tr542;
		case 125: goto tr544;
	}
	if ( 11 <= (*( sm->p)) && (*( sm->p)) <= 12 )
		goto tr543;
	goto tr541;
tr541:
#line 75 "ext/dtext/dtext.cpp.rl"
	{ sm->c1 = sm->p; }
	goto st423;
st423:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof423;
case 423:
#line 9438 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr173;
		case 9: goto tr546;
		case 10: goto tr173;
		case 13: goto tr173;
		case 32: goto tr546;
		case 125: goto tr548;
	}
	if ( 11 <= (*( sm->p)) && (*( sm->p)) <= 12 )
		goto st425;
	goto st423;
tr546:
#line 76 "ext/dtext/dtext.cpp.rl"
	{ sm->c2 = sm->p; }
	goto st424;
st424:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof424;
case 424:
#line 9456 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr173;
		case 9: goto st424;
		case 10: goto tr173;
		case 13: goto tr173;
		case 32: goto st424;
		case 125: goto st426;
	}
	if ( 11 <= (*( sm->p)) && (*( sm->p)) <= 12 )
		goto st425;
	goto st423;
tr543:
#line 75 "ext/dtext/dtext.cpp.rl"
	{ sm->c1 = sm->p; }
	goto st425;
st425:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof425;
case 425:
#line 9474 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr173;
		case 10: goto tr173;
		case 13: goto tr173;
		case 32: goto st425;
		case 125: goto tr173;
	}
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 12 )
		goto st425;
	goto st423;
tr548:
#line 76 "ext/dtext/dtext.cpp.rl"
	{ sm->c2 = sm->p; }
	goto st426;
tr544:
#line 75 "ext/dtext/dtext.cpp.rl"
	{ sm->c1 = sm->p; }
#line 76 "ext/dtext/dtext.cpp.rl"
	{ sm->c2 = sm->p; }
	goto st426;
st426:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof426;
case 426:
#line 9495 "ext/dtext/dtext.cpp"
	if ( (*( sm->p)) == 125 )
		goto st1356;
	goto tr173;
st1356:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1356;
case 1356:
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1795;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1795;
	} else
		goto tr1795;
	goto tr1794;
tr1795:
#line 77 "ext/dtext/dtext.cpp.rl"
	{ sm->d1 = sm->p; }
	goto st1357;
st1357:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1357;
case 1357:
#line 9518 "ext/dtext/dtext.cpp"
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st1357;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st1357;
	} else
		goto st1357;
	goto tr1796;
tr528:
#line 74 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
	goto st427;
st427:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof427;
case 427:
#line 9534 "ext/dtext/dtext.cpp"
	if ( (*( sm->p)) == 125 )
		goto st1358;
	goto tr173;
tr1804:
#line 77 "ext/dtext/dtext.cpp.rl"
	{ sm->d1 = sm->p; }
#line 78 "ext/dtext/dtext.cpp.rl"
	{ sm->d2 = sm->p; }
	goto st1358;
st1358:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1358;
case 1358:
#line 9545 "ext/dtext/dtext.cpp"
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1799;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1799;
	} else
		goto tr1799;
	goto tr1798;
tr1799:
#line 77 "ext/dtext/dtext.cpp.rl"
	{ sm->d1 = sm->p; }
	goto st1359;
st1359:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1359;
case 1359:
#line 9561 "ext/dtext/dtext.cpp"
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st1359;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st1359;
	} else
		goto st1359;
	goto tr1800;
tr539:
#line 74 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
	goto st428;
st428:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof428;
case 428:
#line 9577 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr173;
		case 9: goto tr553;
		case 10: goto tr173;
		case 13: goto tr173;
		case 32: goto tr553;
		case 124: goto tr554;
		case 125: goto tr555;
	}
	if ( 11 <= (*( sm->p)) && (*( sm->p)) <= 12 )
		goto tr543;
	goto tr541;
tr557:
#line 75 "ext/dtext/dtext.cpp.rl"
	{ sm->c1 = sm->p; }
#line 76 "ext/dtext/dtext.cpp.rl"
	{ sm->c2 = sm->p; }
	goto st429;
tr553:
#line 74 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
#line 75 "ext/dtext/dtext.cpp.rl"
	{ sm->c1 = sm->p; }
#line 76 "ext/dtext/dtext.cpp.rl"
	{ sm->c2 = sm->p; }
	goto st429;
st429:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof429;
case 429:
#line 9602 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr173;
		case 9: goto tr557;
		case 10: goto tr173;
		case 13: goto tr173;
		case 32: goto tr557;
		case 45: goto tr558;
		case 58: goto tr559;
		case 60: goto tr560;
		case 62: goto tr561;
		case 92: goto tr562;
		case 123: goto tr541;
		case 124: goto tr563;
		case 125: goto tr564;
		case 126: goto tr558;
	}
	if ( 11 <= (*( sm->p)) && (*( sm->p)) <= 12 )
		goto tr543;
	goto tr556;
tr556:
#line 75 "ext/dtext/dtext.cpp.rl"
	{ sm->c1 = sm->p; }
	goto st430;
st430:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof430;
case 430:
#line 9628 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr173;
		case 9: goto tr566;
		case 10: goto tr173;
		case 13: goto tr173;
		case 32: goto tr566;
		case 123: goto st423;
		case 124: goto tr527;
		case 125: goto tr567;
	}
	if ( 11 <= (*( sm->p)) && (*( sm->p)) <= 12 )
		goto st425;
	goto st430;
tr566:
#line 74 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
#line 76 "ext/dtext/dtext.cpp.rl"
	{ sm->c2 = sm->p; }
	goto st431;
st431:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof431;
case 431:
#line 9649 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr173;
		case 9: goto st431;
		case 10: goto tr173;
		case 13: goto tr173;
		case 32: goto st431;
		case 45: goto st432;
		case 58: goto st433;
		case 60: goto st437;
		case 62: goto st443;
		case 92: goto st446;
		case 123: goto st423;
		case 124: goto st449;
		case 125: goto st435;
		case 126: goto st432;
	}
	if ( 11 <= (*( sm->p)) && (*( sm->p)) <= 12 )
		goto st425;
	goto st430;
tr558:
#line 75 "ext/dtext/dtext.cpp.rl"
	{ sm->c1 = sm->p; }
	goto st432;
st432:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof432;
case 432:
#line 9675 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr173;
		case 9: goto tr566;
		case 10: goto tr173;
		case 13: goto tr173;
		case 32: goto tr566;
		case 58: goto st433;
		case 60: goto st437;
		case 62: goto st443;
		case 92: goto st446;
		case 123: goto st423;
		case 124: goto tr537;
		case 125: goto tr567;
	}
	if ( 11 <= (*( sm->p)) && (*( sm->p)) <= 12 )
		goto st425;
	goto st430;
tr559:
#line 75 "ext/dtext/dtext.cpp.rl"
	{ sm->c1 = sm->p; }
	goto st433;
st433:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof433;
case 433:
#line 9699 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr173;
		case 9: goto tr566;
		case 10: goto tr173;
		case 13: goto tr173;
		case 32: goto tr566;
		case 123: goto st434;
		case 124: goto tr539;
		case 125: goto tr576;
	}
	if ( 11 <= (*( sm->p)) && (*( sm->p)) <= 12 )
		goto st425;
	goto st430;
tr586:
#line 75 "ext/dtext/dtext.cpp.rl"
	{ sm->c1 = sm->p; }
	goto st434;
st434:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof434;
case 434:
#line 9719 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr173;
		case 9: goto tr566;
		case 10: goto tr173;
		case 13: goto tr173;
		case 32: goto tr566;
		case 124: goto tr527;
		case 125: goto tr567;
	}
	if ( 11 <= (*( sm->p)) && (*( sm->p)) <= 12 )
		goto st425;
	goto st423;
tr564:
#line 75 "ext/dtext/dtext.cpp.rl"
	{ sm->c1 = sm->p; }
#line 76 "ext/dtext/dtext.cpp.rl"
	{ sm->c2 = sm->p; }
	goto st435;
tr555:
#line 74 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
#line 75 "ext/dtext/dtext.cpp.rl"
	{ sm->c1 = sm->p; }
#line 76 "ext/dtext/dtext.cpp.rl"
	{ sm->c2 = sm->p; }
	goto st435;
tr567:
#line 74 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
#line 76 "ext/dtext/dtext.cpp.rl"
	{ sm->c2 = sm->p; }
	goto st435;
st435:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof435;
case 435:
#line 9748 "ext/dtext/dtext.cpp"
	if ( (*( sm->p)) == 125 )
		goto st1360;
	goto tr173;
st1360:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1360;
case 1360:
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1802;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1802;
	} else
		goto tr1802;
	goto tr1798;
tr1802:
#line 77 "ext/dtext/dtext.cpp.rl"
	{ sm->d1 = sm->p; }
	goto st1361;
st1361:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1361;
case 1361:
#line 9771 "ext/dtext/dtext.cpp"
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st1361;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st1361;
	} else
		goto st1361;
	goto tr1800;
tr576:
#line 74 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
#line 76 "ext/dtext/dtext.cpp.rl"
	{ sm->c2 = sm->p; }
	goto st436;
st436:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof436;
case 436:
#line 9788 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto tr526;
		case 32: goto tr526;
		case 124: goto tr527;
		case 125: goto tr578;
	}
	goto tr173;
tr578:
#line 74 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
	goto st1362;
st1362:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1362;
case 1362:
#line 9802 "ext/dtext/dtext.cpp"
	if ( (*( sm->p)) == 125 )
		goto tr1804;
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1802;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1802;
	} else
		goto tr1802;
	goto tr1798;
tr560:
#line 75 "ext/dtext/dtext.cpp.rl"
	{ sm->c1 = sm->p; }
	goto st437;
st437:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof437;
case 437:
#line 9820 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr173;
		case 9: goto tr566;
		case 10: goto tr173;
		case 13: goto tr173;
		case 32: goto tr566;
		case 123: goto st423;
		case 124: goto tr579;
		case 125: goto tr567;
	}
	if ( 11 <= (*( sm->p)) && (*( sm->p)) <= 12 )
		goto st425;
	goto st430;
tr579:
#line 74 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
	goto st438;
st438:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof438;
case 438:
#line 9840 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr173;
		case 9: goto tr542;
		case 10: goto tr173;
		case 13: goto tr173;
		case 32: goto tr542;
		case 62: goto tr580;
		case 125: goto tr544;
	}
	if ( 11 <= (*( sm->p)) && (*( sm->p)) <= 12 )
		goto tr543;
	goto tr541;
tr580:
#line 75 "ext/dtext/dtext.cpp.rl"
	{ sm->c1 = sm->p; }
	goto st439;
st439:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof439;
case 439:
#line 9859 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr173;
		case 9: goto tr546;
		case 10: goto tr173;
		case 13: goto tr173;
		case 32: goto tr546;
		case 95: goto st440;
		case 125: goto tr548;
	}
	if ( 11 <= (*( sm->p)) && (*( sm->p)) <= 12 )
		goto st425;
	goto st423;
st440:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof440;
case 440:
	switch( (*( sm->p)) ) {
		case 0: goto tr173;
		case 9: goto tr546;
		case 10: goto tr173;
		case 13: goto tr173;
		case 32: goto tr546;
		case 60: goto st441;
		case 125: goto tr548;
	}
	if ( 11 <= (*( sm->p)) && (*( sm->p)) <= 12 )
		goto st425;
	goto st423;
st441:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof441;
case 441:
	switch( (*( sm->p)) ) {
		case 0: goto tr173;
		case 9: goto tr546;
		case 10: goto tr173;
		case 13: goto tr173;
		case 32: goto tr546;
		case 124: goto st442;
		case 125: goto tr548;
	}
	if ( 11 <= (*( sm->p)) && (*( sm->p)) <= 12 )
		goto st425;
	goto st423;
st442:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof442;
case 442:
	switch( (*( sm->p)) ) {
		case 0: goto tr173;
		case 9: goto tr546;
		case 10: goto tr173;
		case 13: goto tr173;
		case 32: goto tr546;
		case 62: goto st434;
		case 125: goto tr548;
	}
	if ( 11 <= (*( sm->p)) && (*( sm->p)) <= 12 )
		goto st425;
	goto st423;
tr561:
#line 75 "ext/dtext/dtext.cpp.rl"
	{ sm->c1 = sm->p; }
	goto st443;
st443:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof443;
case 443:
#line 9926 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr173;
		case 9: goto tr566;
		case 10: goto tr173;
		case 13: goto tr173;
		case 32: goto tr566;
		case 58: goto st444;
		case 123: goto st423;
		case 124: goto tr585;
		case 125: goto tr567;
	}
	if ( 11 <= (*( sm->p)) && (*( sm->p)) <= 12 )
		goto st425;
	goto st430;
st444:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof444;
case 444:
	switch( (*( sm->p)) ) {
		case 0: goto tr173;
		case 9: goto tr566;
		case 10: goto tr173;
		case 13: goto tr173;
		case 32: goto tr566;
		case 123: goto st423;
		case 124: goto tr539;
		case 125: goto tr567;
	}
	if ( 11 <= (*( sm->p)) && (*( sm->p)) <= 12 )
		goto st425;
	goto st430;
tr585:
#line 74 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
	goto st445;
st445:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof445;
case 445:
#line 9964 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr173;
		case 9: goto tr542;
		case 10: goto tr173;
		case 13: goto tr173;
		case 32: goto tr542;
		case 51: goto tr586;
		case 125: goto tr544;
	}
	if ( 11 <= (*( sm->p)) && (*( sm->p)) <= 12 )
		goto tr543;
	goto tr541;
tr562:
#line 75 "ext/dtext/dtext.cpp.rl"
	{ sm->c1 = sm->p; }
	goto st446;
st446:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof446;
case 446:
#line 9983 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr173;
		case 9: goto tr566;
		case 10: goto tr173;
		case 13: goto tr173;
		case 32: goto tr566;
		case 123: goto st423;
		case 124: goto tr587;
		case 125: goto tr567;
	}
	if ( 11 <= (*( sm->p)) && (*( sm->p)) <= 12 )
		goto st425;
	goto st430;
tr587:
#line 74 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
	goto st447;
st447:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof447;
case 447:
#line 10003 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr173;
		case 9: goto tr542;
		case 10: goto tr173;
		case 13: goto tr173;
		case 32: goto tr542;
		case 124: goto tr588;
		case 125: goto tr544;
	}
	if ( 11 <= (*( sm->p)) && (*( sm->p)) <= 12 )
		goto tr543;
	goto tr541;
tr588:
#line 75 "ext/dtext/dtext.cpp.rl"
	{ sm->c1 = sm->p; }
	goto st448;
st448:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof448;
case 448:
#line 10022 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr173;
		case 9: goto tr546;
		case 10: goto tr173;
		case 13: goto tr173;
		case 32: goto tr546;
		case 47: goto st434;
		case 125: goto tr548;
	}
	if ( 11 <= (*( sm->p)) && (*( sm->p)) <= 12 )
		goto st425;
	goto st423;
tr537:
#line 74 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
	goto st449;
tr563:
#line 75 "ext/dtext/dtext.cpp.rl"
	{ sm->c1 = sm->p; }
	goto st449;
st449:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof449;
case 449:
#line 10044 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr173;
		case 9: goto tr542;
		case 10: goto tr173;
		case 13: goto tr173;
		case 32: goto tr542;
		case 95: goto tr589;
		case 119: goto tr590;
		case 124: goto tr591;
		case 125: goto tr544;
	}
	if ( (*( sm->p)) < 48 ) {
		if ( 11 <= (*( sm->p)) && (*( sm->p)) <= 12 )
			goto tr543;
	} else if ( (*( sm->p)) > 57 ) {
		if ( (*( sm->p)) > 90 ) {
			if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
				goto tr586;
		} else if ( (*( sm->p)) >= 65 )
			goto tr586;
	} else
		goto tr586;
	goto tr541;
tr589:
#line 75 "ext/dtext/dtext.cpp.rl"
	{ sm->c1 = sm->p; }
	goto st450;
st450:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof450;
case 450:
#line 10074 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr173;
		case 9: goto tr546;
		case 10: goto tr173;
		case 13: goto tr173;
		case 32: goto tr546;
		case 124: goto st434;
		case 125: goto tr548;
	}
	if ( 11 <= (*( sm->p)) && (*( sm->p)) <= 12 )
		goto st425;
	goto st423;
tr590:
#line 75 "ext/dtext/dtext.cpp.rl"
	{ sm->c1 = sm->p; }
	goto st451;
st451:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof451;
case 451:
#line 10093 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr173;
		case 9: goto tr566;
		case 10: goto tr173;
		case 13: goto tr173;
		case 32: goto tr566;
		case 124: goto tr539;
		case 125: goto tr567;
	}
	if ( 11 <= (*( sm->p)) && (*( sm->p)) <= 12 )
		goto st425;
	goto st423;
tr591:
#line 75 "ext/dtext/dtext.cpp.rl"
	{ sm->c1 = sm->p; }
	goto st452;
st452:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof452;
case 452:
#line 10112 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr173;
		case 9: goto tr546;
		case 10: goto tr173;
		case 13: goto tr173;
		case 32: goto tr546;
		case 95: goto st453;
		case 125: goto tr548;
	}
	if ( 11 <= (*( sm->p)) && (*( sm->p)) <= 12 )
		goto st425;
	goto st423;
st453:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof453;
case 453:
	switch( (*( sm->p)) ) {
		case 0: goto tr173;
		case 9: goto tr546;
		case 10: goto tr173;
		case 13: goto tr173;
		case 32: goto tr546;
		case 124: goto st450;
		case 125: goto tr548;
	}
	if ( 11 <= (*( sm->p)) && (*( sm->p)) <= 12 )
		goto st425;
	goto st423;
tr540:
#line 74 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
	goto st454;
st454:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof454;
case 454:
#line 10147 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto tr526;
		case 32: goto tr526;
		case 124: goto tr527;
		case 125: goto tr594;
	}
	goto tr173;
tr594:
#line 74 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
	goto st1363;
st1363:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1363;
case 1363:
#line 10161 "ext/dtext/dtext.cpp"
	if ( (*( sm->p)) == 125 )
		goto st1358;
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1799;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1799;
	} else
		goto tr1799;
	goto tr1798;
tr521:
#line 73 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st455;
st455:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof455;
case 455:
#line 10179 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr173;
		case 9: goto tr526;
		case 32: goto tr526;
		case 123: goto tr173;
		case 124: goto tr579;
		case 125: goto tr528;
	}
	if ( 10 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr173;
	goto st417;
tr522:
#line 73 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st456;
st456:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof456;
case 456:
#line 10197 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr173;
		case 9: goto tr526;
		case 32: goto tr526;
		case 58: goto st457;
		case 123: goto tr173;
		case 124: goto tr585;
		case 125: goto tr528;
	}
	if ( 10 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr173;
	goto st417;
st457:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof457;
case 457:
	switch( (*( sm->p)) ) {
		case 0: goto tr173;
		case 9: goto tr526;
		case 32: goto tr526;
		case 123: goto tr173;
		case 124: goto tr539;
		case 125: goto tr528;
	}
	if ( 10 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr173;
	goto st417;
tr523:
#line 73 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st458;
st458:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof458;
case 458:
#line 10231 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr173;
		case 9: goto tr526;
		case 32: goto tr526;
		case 123: goto tr173;
		case 124: goto tr587;
		case 125: goto tr528;
	}
	if ( 10 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr173;
	goto st417;
tr524:
#line 73 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st459;
st459:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof459;
case 459:
#line 10249 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 95: goto st460;
		case 119: goto st461;
		case 124: goto st462;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st421;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st421;
	} else
		goto st421;
	goto tr173;
st460:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof460;
case 460:
	if ( (*( sm->p)) == 124 )
		goto st421;
	goto tr173;
st461:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof461;
case 461:
	switch( (*( sm->p)) ) {
		case 9: goto tr526;
		case 32: goto tr526;
		case 124: goto tr539;
		case 125: goto tr528;
	}
	goto tr173;
st462:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof462;
case 462:
	if ( (*( sm->p)) == 95 )
		goto st463;
	goto tr173;
st463:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof463;
case 463:
	if ( (*( sm->p)) == 124 )
		goto st460;
	goto tr173;
st0:
 sm->cs = 0;
	goto _out;
tr1738:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
#line 575 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 94;}
	goto st1364;
st1364:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1364;
case 1364:
#line 10307 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 76: goto tr1805;
		case 80: goto tr1806;
		case 82: goto tr1807;
		case 83: goto tr1808;
		case 91: goto tr1782;
		case 108: goto tr1805;
		case 112: goto tr1806;
		case 114: goto tr1807;
		case 115: goto tr1808;
		case 123: goto tr1783;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1781;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1781;
	} else
		goto tr1781;
	goto tr1760;
tr1805:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 575 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 94;}
	goto st1365;
st1365:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1365;
case 1365:
#line 10336 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 73: goto tr1809;
		case 91: goto tr1782;
		case 105: goto tr1809;
		case 123: goto tr1783;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1781;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1781;
	} else
		goto tr1781;
	goto tr1760;
tr1809:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 575 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 94;}
	goto st1366;
st1366:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1366;
case 1366:
#line 10359 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 65: goto tr1810;
		case 91: goto tr1782;
		case 97: goto tr1810;
		case 123: goto tr1783;
	}
	if ( (*( sm->p)) < 66 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1781;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 98 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1781;
	} else
		goto tr1781;
	goto tr1760;
tr1810:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 575 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 94;}
	goto st1367;
st1367:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1367;
case 1367:
#line 10382 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 83: goto tr1811;
		case 91: goto tr1782;
		case 115: goto tr1811;
		case 123: goto tr1783;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1781;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1781;
	} else
		goto tr1781;
	goto tr1760;
tr1811:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 575 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 94;}
	goto st1368;
st1368:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1368;
case 1368:
#line 10405 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 32: goto st464;
		case 91: goto tr1782;
		case 123: goto tr1783;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1781;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1781;
	} else
		goto tr1781;
	goto tr1760;
st464:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof464;
case 464:
	if ( (*( sm->p)) == 35 )
		goto st465;
	goto tr176;
st465:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof465;
case 465:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr601;
	goto tr176;
tr601:
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st1369;
st1369:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1369;
case 1369:
#line 10440 "ext/dtext/dtext.cpp"
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto st1369;
	goto tr1813;
tr1806:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 575 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 94;}
	goto st1370;
st1370:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1370;
case 1370:
#line 10451 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 80: goto tr1815;
		case 91: goto tr1782;
		case 112: goto tr1815;
		case 123: goto tr1783;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1781;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1781;
	} else
		goto tr1781;
	goto tr1760;
tr1815:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 575 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 94;}
	goto st1371;
st1371:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1371;
case 1371:
#line 10474 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 69: goto tr1816;
		case 91: goto tr1782;
		case 101: goto tr1816;
		case 123: goto tr1783;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1781;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1781;
	} else
		goto tr1781;
	goto tr1760;
tr1816:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 575 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 94;}
	goto st1372;
st1372:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1372;
case 1372:
#line 10497 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 65: goto tr1817;
		case 91: goto tr1782;
		case 97: goto tr1817;
		case 123: goto tr1783;
	}
	if ( (*( sm->p)) < 66 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1781;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 98 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1781;
	} else
		goto tr1781;
	goto tr1760;
tr1817:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 575 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 94;}
	goto st1373;
st1373:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1373;
case 1373:
#line 10520 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 76: goto tr1818;
		case 91: goto tr1782;
		case 108: goto tr1818;
		case 123: goto tr1783;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1781;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1781;
	} else
		goto tr1781;
	goto tr1760;
tr1818:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 575 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 94;}
	goto st1374;
st1374:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1374;
case 1374:
#line 10543 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 32: goto st466;
		case 91: goto tr1782;
		case 123: goto tr1783;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1781;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1781;
	} else
		goto tr1781;
	goto tr1760;
st466:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof466;
case 466:
	if ( (*( sm->p)) == 35 )
		goto st467;
	goto tr176;
st467:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof467;
case 467:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr603;
	goto tr176;
tr603:
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st1375;
st1375:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1375;
case 1375:
#line 10578 "ext/dtext/dtext.cpp"
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto st1375;
	goto tr1820;
tr1807:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 575 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 94;}
	goto st1376;
st1376:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1376;
case 1376:
#line 10589 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 84: goto tr1822;
		case 91: goto tr1782;
		case 116: goto tr1822;
		case 123: goto tr1783;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1781;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1781;
	} else
		goto tr1781;
	goto tr1760;
tr1822:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 575 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 94;}
	goto st1377;
st1377:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1377;
case 1377:
#line 10612 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 73: goto tr1823;
		case 83: goto tr1824;
		case 91: goto tr1782;
		case 105: goto tr1823;
		case 115: goto tr1824;
		case 123: goto tr1783;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1781;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1781;
	} else
		goto tr1781;
	goto tr1760;
tr1823:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 575 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 94;}
	goto st1378;
st1378:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1378;
case 1378:
#line 10637 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 83: goto tr1825;
		case 91: goto tr1782;
		case 115: goto tr1825;
		case 123: goto tr1783;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1781;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1781;
	} else
		goto tr1781;
	goto tr1760;
tr1825:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 575 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 94;}
	goto st1379;
st1379:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1379;
case 1379:
#line 10660 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 84: goto tr1826;
		case 91: goto tr1782;
		case 116: goto tr1826;
		case 123: goto tr1783;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1781;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1781;
	} else
		goto tr1781;
	goto tr1760;
tr1826:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 575 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 94;}
	goto st1380;
st1380:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1380;
case 1380:
#line 10683 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 32: goto st468;
		case 91: goto tr1782;
		case 123: goto tr1783;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1781;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1781;
	} else
		goto tr1781;
	goto tr1760;
st468:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof468;
case 468:
	if ( (*( sm->p)) == 35 )
		goto st469;
	goto tr176;
st469:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof469;
case 469:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr605;
	goto tr176;
tr605:
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st1381;
st1381:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1381;
case 1381:
#line 10718 "ext/dtext/dtext.cpp"
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto st1381;
	goto tr1828;
tr1824:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 575 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 94;}
	goto st1382;
st1382:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1382;
case 1382:
#line 10729 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 84: goto tr1830;
		case 91: goto tr1782;
		case 116: goto tr1830;
		case 123: goto tr1783;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1781;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1781;
	} else
		goto tr1781;
	goto tr1760;
tr1830:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 575 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 94;}
	goto st1383;
st1383:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1383;
case 1383:
#line 10752 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 65: goto tr1831;
		case 91: goto tr1782;
		case 97: goto tr1831;
		case 123: goto tr1783;
	}
	if ( (*( sm->p)) < 66 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1781;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 98 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1781;
	} else
		goto tr1781;
	goto tr1760;
tr1831:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 575 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 94;}
	goto st1384;
st1384:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1384;
case 1384:
#line 10775 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 84: goto tr1832;
		case 91: goto tr1782;
		case 116: goto tr1832;
		case 123: goto tr1783;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1781;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1781;
	} else
		goto tr1781;
	goto tr1760;
tr1832:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 575 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 94;}
	goto st1385;
st1385:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1385;
case 1385:
#line 10798 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 73: goto tr1833;
		case 91: goto tr1782;
		case 105: goto tr1833;
		case 123: goto tr1783;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1781;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1781;
	} else
		goto tr1781;
	goto tr1760;
tr1833:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 575 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 94;}
	goto st1386;
st1386:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1386;
case 1386:
#line 10821 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 79: goto tr1834;
		case 91: goto tr1782;
		case 111: goto tr1834;
		case 123: goto tr1783;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1781;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1781;
	} else
		goto tr1781;
	goto tr1760;
tr1834:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 575 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 94;}
	goto st1387;
st1387:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1387;
case 1387:
#line 10844 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 78: goto tr1835;
		case 91: goto tr1782;
		case 110: goto tr1835;
		case 123: goto tr1783;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1781;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1781;
	} else
		goto tr1781;
	goto tr1760;
tr1835:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 575 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 94;}
	goto st1388;
st1388:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1388;
case 1388:
#line 10867 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 32: goto st470;
		case 91: goto tr1782;
		case 123: goto tr1783;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1781;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1781;
	} else
		goto tr1781;
	goto tr1760;
st470:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof470;
case 470:
	if ( (*( sm->p)) == 35 )
		goto st471;
	goto tr176;
st471:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof471;
case 471:
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr607;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr607;
	} else
		goto tr607;
	goto tr176;
tr607:
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st1389;
st1389:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1389;
case 1389:
#line 10908 "ext/dtext/dtext.cpp"
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st1389;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st1389;
	} else
		goto st1389;
	goto tr1837;
tr1808:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 575 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 94;}
	goto st1390;
st1390:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1390;
case 1390:
#line 10925 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 83: goto tr1839;
		case 91: goto tr1782;
		case 115: goto tr1839;
		case 123: goto tr1783;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1781;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1781;
	} else
		goto tr1781;
	goto tr1760;
tr1839:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 575 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 94;}
	goto st1391;
st1391:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1391;
case 1391:
#line 10948 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 69: goto tr1840;
		case 91: goto tr1782;
		case 101: goto tr1840;
		case 123: goto tr1783;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1781;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1781;
	} else
		goto tr1781;
	goto tr1760;
tr1840:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 575 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 94;}
	goto st1392;
st1392:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1392;
case 1392:
#line 10971 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 84: goto tr1841;
		case 91: goto tr1782;
		case 116: goto tr1841;
		case 123: goto tr1783;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1781;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1781;
	} else
		goto tr1781;
	goto tr1760;
tr1841:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 575 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 94;}
	goto st1393;
st1393:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1393;
case 1393:
#line 10994 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 32: goto st472;
		case 91: goto tr1782;
		case 123: goto tr1783;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1781;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1781;
	} else
		goto tr1781;
	goto tr1760;
st472:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof472;
case 472:
	if ( (*( sm->p)) == 35 )
		goto st473;
	goto tr176;
st473:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof473;
case 473:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr609;
	goto tr176;
tr609:
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st1394;
st1394:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1394;
case 1394:
#line 11029 "ext/dtext/dtext.cpp"
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto st1394;
	goto tr1843;
tr1739:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
#line 575 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 94;}
	goto st1395;
st1395:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1395;
case 1395:
#line 11041 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 65: goto tr1845;
		case 85: goto tr1846;
		case 91: goto tr1782;
		case 97: goto tr1845;
		case 117: goto tr1846;
		case 123: goto tr1783;
	}
	if ( (*( sm->p)) < 66 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1781;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 98 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1781;
	} else
		goto tr1781;
	goto tr1760;
tr1845:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 575 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 94;}
	goto st1396;
st1396:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1396;
case 1396:
#line 11066 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 78: goto tr1847;
		case 91: goto tr1782;
		case 110: goto tr1847;
		case 123: goto tr1783;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1781;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1781;
	} else
		goto tr1781;
	goto tr1760;
tr1847:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 575 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 94;}
	goto st1397;
st1397:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1397;
case 1397:
#line 11089 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 32: goto st474;
		case 91: goto tr1782;
		case 123: goto tr1783;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1781;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1781;
	} else
		goto tr1781;
	goto tr1760;
st474:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof474;
case 474:
	if ( (*( sm->p)) == 35 )
		goto st475;
	goto tr176;
st475:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof475;
case 475:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr611;
	goto tr176;
tr611:
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st1398;
st1398:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1398;
case 1398:
#line 11124 "ext/dtext/dtext.cpp"
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto st1398;
	goto tr1849;
tr1846:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 575 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 94;}
	goto st1399;
st1399:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1399;
case 1399:
#line 11135 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 82: goto tr1851;
		case 91: goto tr1782;
		case 114: goto tr1851;
		case 123: goto tr1783;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1781;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1781;
	} else
		goto tr1781;
	goto tr1760;
tr1851:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 575 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 94;}
	goto st1400;
st1400:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1400;
case 1400:
#line 11158 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 32: goto st476;
		case 91: goto tr1782;
		case 123: goto tr1783;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1781;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1781;
	} else
		goto tr1781;
	goto tr1760;
st476:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof476;
case 476:
	if ( (*( sm->p)) == 35 )
		goto st477;
	goto tr176;
st477:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof477;
case 477:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr613;
	goto tr176;
tr613:
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st1401;
st1401:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1401;
case 1401:
#line 11193 "ext/dtext/dtext.cpp"
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto st1401;
	goto tr1853;
tr1740:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
#line 575 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 94;}
	goto st1402;
st1402:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1402;
case 1402:
#line 11205 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 79: goto tr1855;
		case 91: goto tr1782;
		case 111: goto tr1855;
		case 123: goto tr1783;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1781;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1781;
	} else
		goto tr1781;
	goto tr1760;
tr1855:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 575 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 94;}
	goto st1403;
st1403:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1403;
case 1403:
#line 11228 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 77: goto tr1856;
		case 91: goto tr1782;
		case 109: goto tr1856;
		case 123: goto tr1783;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1781;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1781;
	} else
		goto tr1781;
	goto tr1760;
tr1856:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 575 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 94;}
	goto st1404;
st1404:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1404;
case 1404:
#line 11251 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 77: goto tr1857;
		case 91: goto tr1782;
		case 109: goto tr1857;
		case 123: goto tr1783;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1781;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1781;
	} else
		goto tr1781;
	goto tr1760;
tr1857:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 575 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 94;}
	goto st1405;
st1405:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1405;
case 1405:
#line 11274 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 69: goto tr1858;
		case 73: goto tr1859;
		case 91: goto tr1782;
		case 101: goto tr1858;
		case 105: goto tr1859;
		case 123: goto tr1783;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1781;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1781;
	} else
		goto tr1781;
	goto tr1760;
tr1858:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 575 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 94;}
	goto st1406;
st1406:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1406;
case 1406:
#line 11299 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 78: goto tr1860;
		case 91: goto tr1782;
		case 110: goto tr1860;
		case 123: goto tr1783;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1781;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1781;
	} else
		goto tr1781;
	goto tr1760;
tr1860:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 575 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 94;}
	goto st1407;
st1407:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1407;
case 1407:
#line 11322 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 84: goto tr1861;
		case 91: goto tr1782;
		case 116: goto tr1861;
		case 123: goto tr1783;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1781;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1781;
	} else
		goto tr1781;
	goto tr1760;
tr1861:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 575 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 94;}
	goto st1408;
st1408:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1408;
case 1408:
#line 11345 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 32: goto st478;
		case 91: goto tr1782;
		case 123: goto tr1783;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1781;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1781;
	} else
		goto tr1781;
	goto tr1760;
st478:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof478;
case 478:
	if ( (*( sm->p)) == 35 )
		goto st479;
	goto tr176;
st479:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof479;
case 479:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr615;
	goto tr176;
tr615:
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st1409;
st1409:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1409;
case 1409:
#line 11380 "ext/dtext/dtext.cpp"
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto st1409;
	goto tr1863;
tr1859:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 575 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 94;}
	goto st1410;
st1410:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1410;
case 1410:
#line 11391 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 84: goto tr1865;
		case 91: goto tr1782;
		case 116: goto tr1865;
		case 123: goto tr1783;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1781;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1781;
	} else
		goto tr1781;
	goto tr1760;
tr1865:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 575 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 94;}
	goto st1411;
st1411:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1411;
case 1411:
#line 11414 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 32: goto st480;
		case 91: goto tr1782;
		case 123: goto tr1783;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1781;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1781;
	} else
		goto tr1781;
	goto tr1760;
st480:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof480;
case 480:
	if ( (*( sm->p)) == 35 )
		goto st481;
	goto tr176;
st481:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof481;
case 481:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr617;
	goto tr176;
tr617:
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st1412;
st1412:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1412;
case 1412:
#line 11449 "ext/dtext/dtext.cpp"
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto st1412;
	goto tr1867;
tr1741:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
#line 575 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 94;}
	goto st1413;
st1413:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1413;
case 1413:
#line 11461 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 69: goto tr1869;
		case 77: goto tr1870;
		case 91: goto tr1782;
		case 101: goto tr1869;
		case 109: goto tr1870;
		case 123: goto tr1783;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1781;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1781;
	} else
		goto tr1781;
	goto tr1760;
tr1869:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 575 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 94;}
	goto st1414;
st1414:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1414;
case 1414:
#line 11486 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 86: goto tr1871;
		case 91: goto tr1782;
		case 118: goto tr1871;
		case 123: goto tr1783;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1781;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1781;
	} else
		goto tr1781;
	goto tr1760;
tr1871:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 575 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 94;}
	goto st1415;
st1415:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1415;
case 1415:
#line 11509 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 73: goto tr1872;
		case 91: goto tr1782;
		case 105: goto tr1872;
		case 123: goto tr1783;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1781;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1781;
	} else
		goto tr1781;
	goto tr1760;
tr1872:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 575 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 94;}
	goto st1416;
st1416:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1416;
case 1416:
#line 11532 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 65: goto tr1873;
		case 91: goto tr1782;
		case 97: goto tr1873;
		case 123: goto tr1783;
	}
	if ( (*( sm->p)) < 66 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1781;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 98 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1781;
	} else
		goto tr1781;
	goto tr1760;
tr1873:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 575 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 94;}
	goto st1417;
st1417:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1417;
case 1417:
#line 11555 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 78: goto tr1874;
		case 91: goto tr1782;
		case 110: goto tr1874;
		case 123: goto tr1783;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1781;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1781;
	} else
		goto tr1781;
	goto tr1760;
tr1874:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 575 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 94;}
	goto st1418;
st1418:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1418;
case 1418:
#line 11578 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 84: goto tr1875;
		case 91: goto tr1782;
		case 116: goto tr1875;
		case 123: goto tr1783;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1781;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1781;
	} else
		goto tr1781;
	goto tr1760;
tr1875:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 575 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 94;}
	goto st1419;
st1419:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1419;
case 1419:
#line 11601 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 65: goto tr1876;
		case 91: goto tr1782;
		case 97: goto tr1876;
		case 123: goto tr1783;
	}
	if ( (*( sm->p)) < 66 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1781;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 98 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1781;
	} else
		goto tr1781;
	goto tr1760;
tr1876:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 575 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 94;}
	goto st1420;
st1420:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1420;
case 1420:
#line 11624 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 82: goto tr1877;
		case 91: goto tr1782;
		case 114: goto tr1877;
		case 123: goto tr1783;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1781;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1781;
	} else
		goto tr1781;
	goto tr1760;
tr1877:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 575 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 94;}
	goto st1421;
st1421:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1421;
case 1421:
#line 11647 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 84: goto tr1878;
		case 91: goto tr1782;
		case 116: goto tr1878;
		case 123: goto tr1783;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1781;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1781;
	} else
		goto tr1781;
	goto tr1760;
tr1878:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 575 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 94;}
	goto st1422;
st1422:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1422;
case 1422:
#line 11670 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 32: goto st482;
		case 91: goto tr1782;
		case 123: goto tr1783;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1781;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1781;
	} else
		goto tr1781;
	goto tr1760;
st482:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof482;
case 482:
	if ( (*( sm->p)) == 35 )
		goto st483;
	goto tr176;
st483:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof483;
case 483:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr619;
	goto tr176;
tr619:
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st1423;
st1423:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1423;
case 1423:
#line 11705 "ext/dtext/dtext.cpp"
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto st1423;
	goto tr1880;
tr1870:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 575 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 94;}
	goto st1424;
st1424:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1424;
case 1424:
#line 11716 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 65: goto tr1882;
		case 91: goto tr1782;
		case 97: goto tr1882;
		case 123: goto tr1783;
	}
	if ( (*( sm->p)) < 66 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1781;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 98 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1781;
	} else
		goto tr1781;
	goto tr1760;
tr1882:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 575 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 94;}
	goto st1425;
st1425:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1425;
case 1425:
#line 11739 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 73: goto tr1883;
		case 91: goto tr1782;
		case 105: goto tr1883;
		case 123: goto tr1783;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1781;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1781;
	} else
		goto tr1781;
	goto tr1760;
tr1883:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 575 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 94;}
	goto st1426;
st1426:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1426;
case 1426:
#line 11762 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 76: goto tr1884;
		case 91: goto tr1782;
		case 108: goto tr1884;
		case 123: goto tr1783;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1781;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1781;
	} else
		goto tr1781;
	goto tr1760;
tr1884:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 575 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 94;}
	goto st1427;
st1427:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1427;
case 1427:
#line 11785 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 32: goto st484;
		case 91: goto tr1782;
		case 123: goto tr1783;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1781;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1781;
	} else
		goto tr1781;
	goto tr1760;
st484:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof484;
case 484:
	if ( (*( sm->p)) == 35 )
		goto st485;
	goto tr176;
st485:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof485;
case 485:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr621;
	goto tr176;
tr1888:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
	goto st1428;
tr621:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st1428;
st1428:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1428;
case 1428:
#line 11824 "ext/dtext/dtext.cpp"
	if ( (*( sm->p)) == 47 )
		goto tr1887;
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr1888;
	goto tr1886;
tr1887:
#line 72 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
	goto st486;
st486:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof486;
case 486:
#line 11836 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 45: goto tr623;
		case 61: goto tr623;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr623;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr623;
	} else
		goto tr623;
	goto tr622;
tr623:
#line 73 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st1429;
st1429:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1429;
case 1429:
#line 11856 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 45: goto st1429;
		case 61: goto st1429;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st1429;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st1429;
	} else
		goto st1429;
	goto tr1889;
tr1742:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
#line 575 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 94;}
	goto st1430;
st1430:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1430;
case 1430:
#line 11878 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 65: goto tr1891;
		case 69: goto tr1892;
		case 76: goto tr1893;
		case 79: goto tr1894;
		case 91: goto tr1782;
		case 97: goto tr1891;
		case 101: goto tr1892;
		case 108: goto tr1893;
		case 111: goto tr1894;
		case 123: goto tr1783;
	}
	if ( (*( sm->p)) < 66 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1781;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 98 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1781;
	} else
		goto tr1781;
	goto tr1760;
tr1891:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 575 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 94;}
	goto st1431;
st1431:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1431;
case 1431:
#line 11907 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 86: goto tr1895;
		case 91: goto tr1782;
		case 118: goto tr1895;
		case 123: goto tr1783;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1781;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1781;
	} else
		goto tr1781;
	goto tr1760;
tr1895:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 575 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 94;}
	goto st1432;
st1432:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1432;
case 1432:
#line 11930 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 71: goto tr1896;
		case 91: goto tr1782;
		case 103: goto tr1896;
		case 123: goto tr1783;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1781;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1781;
	} else
		goto tr1781;
	goto tr1760;
tr1896:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 575 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 94;}
	goto st1433;
st1433:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1433;
case 1433:
#line 11953 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 82: goto tr1897;
		case 91: goto tr1782;
		case 114: goto tr1897;
		case 123: goto tr1783;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1781;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1781;
	} else
		goto tr1781;
	goto tr1760;
tr1897:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 575 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 94;}
	goto st1434;
st1434:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1434;
case 1434:
#line 11976 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 79: goto tr1898;
		case 91: goto tr1782;
		case 111: goto tr1898;
		case 123: goto tr1783;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1781;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1781;
	} else
		goto tr1781;
	goto tr1760;
tr1898:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 575 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 94;}
	goto st1435;
st1435:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1435;
case 1435:
#line 11999 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 85: goto tr1899;
		case 91: goto tr1782;
		case 117: goto tr1899;
		case 123: goto tr1783;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1781;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1781;
	} else
		goto tr1781;
	goto tr1760;
tr1899:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 575 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 94;}
	goto st1436;
st1436:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1436;
case 1436:
#line 12022 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 80: goto tr1900;
		case 91: goto tr1782;
		case 112: goto tr1900;
		case 123: goto tr1783;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1781;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1781;
	} else
		goto tr1781;
	goto tr1760;
tr1900:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 575 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 94;}
	goto st1437;
st1437:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1437;
case 1437:
#line 12045 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 32: goto st487;
		case 91: goto tr1782;
		case 123: goto tr1783;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1781;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1781;
	} else
		goto tr1781;
	goto tr1760;
st487:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof487;
case 487:
	if ( (*( sm->p)) == 35 )
		goto st488;
	goto tr176;
st488:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof488;
case 488:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr625;
	goto tr176;
tr625:
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st1438;
st1438:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1438;
case 1438:
#line 12080 "ext/dtext/dtext.cpp"
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto st1438;
	goto tr1902;
tr1892:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 575 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 94;}
	goto st1439;
st1439:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1439;
case 1439:
#line 12091 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 69: goto tr1904;
		case 91: goto tr1782;
		case 101: goto tr1904;
		case 123: goto tr1783;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1781;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1781;
	} else
		goto tr1781;
	goto tr1760;
tr1904:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 575 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 94;}
	goto st1440;
st1440:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1440;
case 1440:
#line 12114 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 68: goto tr1905;
		case 91: goto tr1782;
		case 100: goto tr1905;
		case 123: goto tr1783;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1781;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1781;
	} else
		goto tr1781;
	goto tr1760;
tr1905:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 575 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 94;}
	goto st1441;
st1441:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1441;
case 1441:
#line 12137 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 66: goto tr1906;
		case 91: goto tr1782;
		case 98: goto tr1906;
		case 123: goto tr1783;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1781;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1781;
	} else
		goto tr1781;
	goto tr1760;
tr1906:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 575 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 94;}
	goto st1442;
st1442:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1442;
case 1442:
#line 12160 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 65: goto tr1907;
		case 91: goto tr1782;
		case 97: goto tr1907;
		case 123: goto tr1783;
	}
	if ( (*( sm->p)) < 66 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1781;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 98 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1781;
	} else
		goto tr1781;
	goto tr1760;
tr1907:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 575 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 94;}
	goto st1443;
st1443:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1443;
case 1443:
#line 12183 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 67: goto tr1908;
		case 91: goto tr1782;
		case 99: goto tr1908;
		case 123: goto tr1783;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1781;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1781;
	} else
		goto tr1781;
	goto tr1760;
tr1908:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 575 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 94;}
	goto st1444;
st1444:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1444;
case 1444:
#line 12206 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 75: goto tr1909;
		case 91: goto tr1782;
		case 107: goto tr1909;
		case 123: goto tr1783;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1781;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1781;
	} else
		goto tr1781;
	goto tr1760;
tr1909:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 575 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 94;}
	goto st1445;
st1445:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1445;
case 1445:
#line 12229 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 32: goto st489;
		case 91: goto tr1782;
		case 123: goto tr1783;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1781;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1781;
	} else
		goto tr1781;
	goto tr1760;
st489:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof489;
case 489:
	if ( (*( sm->p)) == 35 )
		goto st490;
	goto tr176;
st490:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof490;
case 490:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr627;
	goto tr176;
tr627:
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st1446;
st1446:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1446;
case 1446:
#line 12264 "ext/dtext/dtext.cpp"
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto st1446;
	goto tr1911;
tr1893:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 575 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 94;}
	goto st1447;
st1447:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1447;
case 1447:
#line 12275 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 65: goto tr1913;
		case 91: goto tr1782;
		case 97: goto tr1913;
		case 123: goto tr1783;
	}
	if ( (*( sm->p)) < 66 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1781;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 98 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1781;
	} else
		goto tr1781;
	goto tr1760;
tr1913:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 575 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 94;}
	goto st1448;
st1448:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1448;
case 1448:
#line 12298 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 71: goto tr1914;
		case 91: goto tr1782;
		case 103: goto tr1914;
		case 123: goto tr1783;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1781;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1781;
	} else
		goto tr1781;
	goto tr1760;
tr1914:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 575 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 94;}
	goto st1449;
st1449:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1449;
case 1449:
#line 12321 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 32: goto st491;
		case 91: goto tr1782;
		case 123: goto tr1783;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1781;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1781;
	} else
		goto tr1781;
	goto tr1760;
st491:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof491;
case 491:
	if ( (*( sm->p)) == 35 )
		goto st492;
	goto tr176;
st492:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof492;
case 492:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr629;
	goto tr176;
tr629:
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st1450;
st1450:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1450;
case 1450:
#line 12356 "ext/dtext/dtext.cpp"
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto st1450;
	goto tr1916;
tr1894:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 575 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 94;}
	goto st1451;
st1451:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1451;
case 1451:
#line 12367 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 82: goto tr1918;
		case 91: goto tr1782;
		case 114: goto tr1918;
		case 123: goto tr1783;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1781;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1781;
	} else
		goto tr1781;
	goto tr1760;
tr1918:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 575 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 94;}
	goto st1452;
st1452:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1452;
case 1452:
#line 12390 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 85: goto tr1919;
		case 91: goto tr1782;
		case 117: goto tr1919;
		case 123: goto tr1783;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1781;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1781;
	} else
		goto tr1781;
	goto tr1760;
tr1919:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 575 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 94;}
	goto st1453;
st1453:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1453;
case 1453:
#line 12413 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 77: goto tr1920;
		case 91: goto tr1782;
		case 109: goto tr1920;
		case 123: goto tr1783;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1781;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1781;
	} else
		goto tr1781;
	goto tr1760;
tr1920:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 575 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 94;}
	goto st1454;
st1454:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1454;
case 1454:
#line 12436 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 32: goto st493;
		case 91: goto tr1782;
		case 123: goto tr1783;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1781;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1781;
	} else
		goto tr1781;
	goto tr1760;
st493:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof493;
case 493:
	if ( (*( sm->p)) == 35 )
		goto st494;
	goto tr176;
st494:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof494;
case 494:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr631;
	goto tr176;
tr631:
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st1455;
st1455:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1455;
case 1455:
#line 12471 "ext/dtext/dtext.cpp"
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto st1455;
	goto tr1922;
tr1743:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
#line 575 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 94;}
	goto st1456;
st1456:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1456;
case 1456:
#line 12483 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 69: goto tr1924;
		case 91: goto tr1782;
		case 101: goto tr1924;
		case 123: goto tr1783;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1781;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1781;
	} else
		goto tr1781;
	goto tr1760;
tr1924:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 575 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 94;}
	goto st1457;
st1457:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1457;
case 1457:
#line 12506 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 76: goto tr1925;
		case 91: goto tr1782;
		case 108: goto tr1925;
		case 123: goto tr1783;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1781;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1781;
	} else
		goto tr1781;
	goto tr1760;
tr1925:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 575 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 94;}
	goto st1458;
st1458:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1458;
case 1458:
#line 12529 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 66: goto tr1926;
		case 91: goto tr1782;
		case 98: goto tr1926;
		case 123: goto tr1783;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1781;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1781;
	} else
		goto tr1781;
	goto tr1760;
tr1926:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 575 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 94;}
	goto st1459;
st1459:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1459;
case 1459:
#line 12552 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 79: goto tr1927;
		case 91: goto tr1782;
		case 111: goto tr1927;
		case 123: goto tr1783;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1781;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1781;
	} else
		goto tr1781;
	goto tr1760;
tr1927:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 575 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 94;}
	goto st1460;
st1460:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1460;
case 1460:
#line 12575 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 79: goto tr1928;
		case 91: goto tr1782;
		case 111: goto tr1928;
		case 123: goto tr1783;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1781;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1781;
	} else
		goto tr1781;
	goto tr1760;
tr1928:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 575 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 94;}
	goto st1461;
st1461:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1461;
case 1461:
#line 12598 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 82: goto tr1929;
		case 91: goto tr1782;
		case 114: goto tr1929;
		case 123: goto tr1783;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1781;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1781;
	} else
		goto tr1781;
	goto tr1760;
tr1929:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 575 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 94;}
	goto st1462;
st1462:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1462;
case 1462:
#line 12621 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 85: goto tr1930;
		case 91: goto tr1782;
		case 117: goto tr1930;
		case 123: goto tr1783;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1781;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1781;
	} else
		goto tr1781;
	goto tr1760;
tr1930:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 575 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 94;}
	goto st1463;
st1463:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1463;
case 1463:
#line 12644 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 32: goto st495;
		case 91: goto tr1782;
		case 123: goto tr1783;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1781;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1781;
	} else
		goto tr1781;
	goto tr1760;
st495:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof495;
case 495:
	if ( (*( sm->p)) == 35 )
		goto st496;
	goto tr176;
st496:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof496;
case 496:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr633;
	goto tr176;
tr633:
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st1464;
st1464:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1464;
case 1464:
#line 12679 "ext/dtext/dtext.cpp"
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto st1464;
	goto tr1932;
tr1744:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
#line 575 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 94;}
	goto st1465;
st1465:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1465;
case 1465:
#line 12691 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 84: goto tr1934;
		case 91: goto tr1782;
		case 116: goto tr1934;
		case 123: goto tr1783;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1781;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1781;
	} else
		goto tr1781;
	goto tr1760;
tr1934:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 575 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 94;}
	goto st1466;
st1466:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1466;
case 1466:
#line 12714 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 84: goto tr1935;
		case 91: goto tr1782;
		case 116: goto tr1935;
		case 123: goto tr1783;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1781;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1781;
	} else
		goto tr1781;
	goto tr1760;
tr1935:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 575 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 94;}
	goto st1467;
st1467:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1467;
case 1467:
#line 12737 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 80: goto tr1936;
		case 91: goto tr1782;
		case 112: goto tr1936;
		case 123: goto tr1783;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1781;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1781;
	} else
		goto tr1781;
	goto tr1760;
tr1936:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 575 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 94;}
	goto st1468;
st1468:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1468;
case 1468:
#line 12760 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 58: goto st497;
		case 83: goto tr1938;
		case 91: goto tr1782;
		case 115: goto tr1938;
		case 123: goto tr1783;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1781;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1781;
	} else
		goto tr1781;
	goto tr1760;
st497:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof497;
case 497:
	if ( (*( sm->p)) == 47 )
		goto st498;
	goto tr176;
st498:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof498;
case 498:
	if ( (*( sm->p)) == 47 )
		goto st499;
	goto tr176;
st499:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof499;
case 499:
	switch( (*( sm->p)) ) {
		case 45: goto st501;
		case 95: goto st501;
	}
	if ( (*( sm->p)) < -16 ) {
		if ( (*( sm->p)) > -33 ) {
			if ( -32 <= (*( sm->p)) && (*( sm->p)) <= -17 )
				goto st502;
		} else if ( (*( sm->p)) >= -62 )
			goto st500;
	} else if ( (*( sm->p)) > -12 ) {
		if ( (*( sm->p)) < 65 ) {
			if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
				goto st501;
		} else if ( (*( sm->p)) > 90 ) {
			if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
				goto st501;
		} else
			goto st501;
	} else
		goto st503;
	goto tr176;
st500:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof500;
case 500:
	if ( (*( sm->p)) <= -65 )
		goto st501;
	goto tr176;
st501:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof501;
case 501:
	switch( (*( sm->p)) ) {
		case 45: goto st501;
		case 46: goto st504;
		case 95: goto st501;
	}
	if ( (*( sm->p)) < -16 ) {
		if ( (*( sm->p)) > -33 ) {
			if ( -32 <= (*( sm->p)) && (*( sm->p)) <= -17 )
				goto st502;
		} else if ( (*( sm->p)) >= -62 )
			goto st500;
	} else if ( (*( sm->p)) > -12 ) {
		if ( (*( sm->p)) < 65 ) {
			if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
				goto st501;
		} else if ( (*( sm->p)) > 90 ) {
			if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
				goto st501;
		} else
			goto st501;
	} else
		goto st503;
	goto tr176;
st502:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof502;
case 502:
	if ( (*( sm->p)) <= -65 )
		goto st500;
	goto tr176;
st503:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof503;
case 503:
	if ( (*( sm->p)) <= -65 )
		goto st502;
	goto tr176;
st504:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof504;
case 504:
	switch( (*( sm->p)) ) {
		case -30: goto st507;
		case -29: goto st510;
		case -17: goto st512;
		case 45: goto tr647;
		case 95: goto tr647;
	}
	if ( (*( sm->p)) < -16 ) {
		if ( (*( sm->p)) > -33 ) {
			if ( -32 <= (*( sm->p)) && (*( sm->p)) <= -18 )
				goto st506;
		} else if ( (*( sm->p)) >= -62 )
			goto st505;
	} else if ( (*( sm->p)) > -12 ) {
		if ( (*( sm->p)) < 65 ) {
			if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
				goto tr647;
		} else if ( (*( sm->p)) > 90 ) {
			if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
				goto tr647;
		} else
			goto tr647;
	} else
		goto st515;
	goto tr173;
st505:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof505;
case 505:
	if ( (*( sm->p)) <= -65 )
		goto tr647;
	goto tr173;
tr647:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 375 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 57;}
	goto st1469;
st1469:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1469;
case 1469:
#line 12908 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case -30: goto st507;
		case -29: goto st510;
		case -17: goto st512;
		case 35: goto tr650;
		case 46: goto st504;
		case 47: goto tr651;
		case 58: goto st549;
		case 63: goto st538;
		case 95: goto tr647;
	}
	if ( (*( sm->p)) < -16 ) {
		if ( (*( sm->p)) > -33 ) {
			if ( -32 <= (*( sm->p)) && (*( sm->p)) <= -18 )
				goto st506;
		} else if ( (*( sm->p)) >= -62 )
			goto st505;
	} else if ( (*( sm->p)) > -12 ) {
		if ( (*( sm->p)) < 65 ) {
			if ( 45 <= (*( sm->p)) && (*( sm->p)) <= 57 )
				goto tr647;
		} else if ( (*( sm->p)) > 90 ) {
			if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
				goto tr647;
		} else
			goto tr647;
	} else
		goto st515;
	goto tr1939;
st506:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof506;
case 506:
	if ( (*( sm->p)) <= -65 )
		goto st505;
	goto tr173;
st507:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof507;
case 507:
	if ( (*( sm->p)) == -99 )
		goto st508;
	if ( (*( sm->p)) <= -65 )
		goto st505;
	goto tr173;
st508:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof508;
case 508:
	if ( (*( sm->p)) == -83 )
		goto st509;
	if ( (*( sm->p)) <= -65 )
		goto tr647;
	goto tr173;
st509:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof509;
case 509:
	switch( (*( sm->p)) ) {
		case -30: goto st507;
		case -29: goto st510;
		case -17: goto st512;
		case 35: goto tr650;
		case 46: goto st504;
		case 47: goto tr651;
		case 58: goto st549;
		case 63: goto st538;
		case 95: goto tr647;
	}
	if ( (*( sm->p)) < -16 ) {
		if ( (*( sm->p)) > -33 ) {
			if ( -32 <= (*( sm->p)) && (*( sm->p)) <= -18 )
				goto st506;
		} else if ( (*( sm->p)) >= -62 )
			goto st505;
	} else if ( (*( sm->p)) > -12 ) {
		if ( (*( sm->p)) < 65 ) {
			if ( 45 <= (*( sm->p)) && (*( sm->p)) <= 57 )
				goto tr647;
		} else if ( (*( sm->p)) > 90 ) {
			if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
				goto tr647;
		} else
			goto tr647;
	} else
		goto st515;
	goto tr173;
st510:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof510;
case 510:
	if ( (*( sm->p)) == -128 )
		goto st511;
	if ( -127 <= (*( sm->p)) && (*( sm->p)) <= -65 )
		goto st505;
	goto tr173;
st511:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof511;
case 511:
	if ( (*( sm->p)) < -120 ) {
		if ( (*( sm->p)) > -126 ) {
			if ( -125 <= (*( sm->p)) && (*( sm->p)) <= -121 )
				goto tr647;
		} else
			goto st509;
	} else if ( (*( sm->p)) > -111 ) {
		if ( (*( sm->p)) < -108 ) {
			if ( -110 <= (*( sm->p)) && (*( sm->p)) <= -109 )
				goto tr647;
		} else if ( (*( sm->p)) > -100 ) {
			if ( -99 <= (*( sm->p)) && (*( sm->p)) <= -65 )
				goto tr647;
		} else
			goto st509;
	} else
		goto st509;
	goto tr173;
st512:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof512;
case 512:
	switch( (*( sm->p)) ) {
		case -68: goto st513;
		case -67: goto st514;
	}
	if ( (*( sm->p)) <= -65 )
		goto st505;
	goto tr173;
st513:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof513;
case 513:
	switch( (*( sm->p)) ) {
		case -119: goto st509;
		case -67: goto st509;
	}
	if ( (*( sm->p)) <= -65 )
		goto tr647;
	goto tr173;
st514:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof514;
case 514:
	switch( (*( sm->p)) ) {
		case -99: goto st509;
		case -96: goto st509;
		case -93: goto st509;
	}
	if ( (*( sm->p)) <= -65 )
		goto tr647;
	goto tr173;
st515:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof515;
case 515:
	if ( (*( sm->p)) <= -65 )
		goto st506;
	goto tr173;
tr650:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
	goto st1470;
st1470:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1470;
case 1470:
#line 13074 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case -30: goto st518;
		case -29: goto st520;
		case -17: goto st522;
		case 32: goto tr1939;
		case 34: goto st526;
		case 35: goto tr1939;
		case 39: goto st526;
		case 44: goto st526;
		case 46: goto st526;
		case 60: goto tr1939;
		case 62: goto tr1939;
		case 63: goto st526;
		case 91: goto tr1939;
		case 93: goto tr1939;
	}
	if ( (*( sm->p)) < -16 ) {
		if ( (*( sm->p)) < -62 ) {
			if ( (*( sm->p)) <= -63 )
				goto tr1939;
		} else if ( (*( sm->p)) > -33 ) {
			if ( -32 <= (*( sm->p)) && (*( sm->p)) <= -18 )
				goto st517;
		} else
			goto st516;
	} else if ( (*( sm->p)) > -12 ) {
		if ( (*( sm->p)) < 9 ) {
			if ( -11 <= (*( sm->p)) && (*( sm->p)) <= 0 )
				goto tr1939;
		} else if ( (*( sm->p)) > 13 ) {
			if ( 58 <= (*( sm->p)) && (*( sm->p)) <= 59 )
				goto st526;
		} else
			goto tr1939;
	} else
		goto st525;
	goto tr650;
st516:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof516;
case 516:
	if ( (*( sm->p)) <= -65 )
		goto tr650;
	goto tr657;
st517:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof517;
case 517:
	if ( (*( sm->p)) <= -65 )
		goto st516;
	goto tr657;
st518:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof518;
case 518:
	if ( (*( sm->p)) == -99 )
		goto st519;
	if ( (*( sm->p)) <= -65 )
		goto st516;
	goto tr657;
st519:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof519;
case 519:
	if ( (*( sm->p)) > -84 ) {
		if ( -82 <= (*( sm->p)) && (*( sm->p)) <= -65 )
			goto tr650;
	} else
		goto tr650;
	goto tr657;
st520:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof520;
case 520:
	if ( (*( sm->p)) == -128 )
		goto st521;
	if ( -127 <= (*( sm->p)) && (*( sm->p)) <= -65 )
		goto st516;
	goto tr657;
st521:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof521;
case 521:
	if ( (*( sm->p)) < -110 ) {
		if ( -125 <= (*( sm->p)) && (*( sm->p)) <= -121 )
			goto tr650;
	} else if ( (*( sm->p)) > -109 ) {
		if ( -99 <= (*( sm->p)) && (*( sm->p)) <= -65 )
			goto tr650;
	} else
		goto tr650;
	goto tr657;
st522:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof522;
case 522:
	switch( (*( sm->p)) ) {
		case -68: goto st523;
		case -67: goto st524;
	}
	if ( (*( sm->p)) <= -65 )
		goto st516;
	goto tr657;
st523:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof523;
case 523:
	if ( (*( sm->p)) < -118 ) {
		if ( (*( sm->p)) <= -120 )
			goto tr650;
	} else if ( (*( sm->p)) > -68 ) {
		if ( -66 <= (*( sm->p)) && (*( sm->p)) <= -65 )
			goto tr650;
	} else
		goto tr650;
	goto tr657;
st524:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof524;
case 524:
	if ( (*( sm->p)) < -98 ) {
		if ( (*( sm->p)) <= -100 )
			goto tr650;
	} else if ( (*( sm->p)) > -97 ) {
		if ( (*( sm->p)) > -94 ) {
			if ( -92 <= (*( sm->p)) && (*( sm->p)) <= -65 )
				goto tr650;
		} else if ( (*( sm->p)) >= -95 )
			goto tr650;
	} else
		goto tr650;
	goto tr657;
st525:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof525;
case 525:
	if ( (*( sm->p)) <= -65 )
		goto st517;
	goto tr657;
st526:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof526;
case 526:
	switch( (*( sm->p)) ) {
		case -30: goto st518;
		case -29: goto st520;
		case -17: goto st522;
		case 32: goto tr657;
		case 34: goto st526;
		case 35: goto tr657;
		case 39: goto st526;
		case 44: goto st526;
		case 46: goto st526;
		case 60: goto tr657;
		case 62: goto tr657;
		case 63: goto st526;
		case 91: goto tr657;
		case 93: goto tr657;
	}
	if ( (*( sm->p)) < -16 ) {
		if ( (*( sm->p)) < -62 ) {
			if ( (*( sm->p)) <= -63 )
				goto tr657;
		} else if ( (*( sm->p)) > -33 ) {
			if ( -32 <= (*( sm->p)) && (*( sm->p)) <= -18 )
				goto st517;
		} else
			goto st516;
	} else if ( (*( sm->p)) > -12 ) {
		if ( (*( sm->p)) < 9 ) {
			if ( -11 <= (*( sm->p)) && (*( sm->p)) <= 0 )
				goto tr657;
		} else if ( (*( sm->p)) > 13 ) {
			if ( 58 <= (*( sm->p)) && (*( sm->p)) <= 59 )
				goto st526;
		} else
			goto tr657;
	} else
		goto st525;
	goto tr650;
tr651:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 375 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 57;}
	goto st1471;
st1471:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1471;
case 1471:
#line 13262 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case -30: goto st529;
		case -29: goto st531;
		case -17: goto st533;
		case 32: goto tr1939;
		case 34: goto st537;
		case 35: goto tr650;
		case 39: goto st537;
		case 44: goto st537;
		case 46: goto st537;
		case 60: goto tr1939;
		case 62: goto tr1939;
		case 63: goto st538;
		case 91: goto tr1939;
		case 93: goto tr1939;
	}
	if ( (*( sm->p)) < -16 ) {
		if ( (*( sm->p)) < -62 ) {
			if ( (*( sm->p)) <= -63 )
				goto tr1939;
		} else if ( (*( sm->p)) > -33 ) {
			if ( -32 <= (*( sm->p)) && (*( sm->p)) <= -18 )
				goto st528;
		} else
			goto st527;
	} else if ( (*( sm->p)) > -12 ) {
		if ( (*( sm->p)) < 9 ) {
			if ( -11 <= (*( sm->p)) && (*( sm->p)) <= 0 )
				goto tr1939;
		} else if ( (*( sm->p)) > 13 ) {
			if ( 58 <= (*( sm->p)) && (*( sm->p)) <= 59 )
				goto st537;
		} else
			goto tr1939;
	} else
		goto st536;
	goto tr651;
st527:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof527;
case 527:
	if ( (*( sm->p)) <= -65 )
		goto tr651;
	goto tr657;
st528:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof528;
case 528:
	if ( (*( sm->p)) <= -65 )
		goto st527;
	goto tr657;
st529:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof529;
case 529:
	if ( (*( sm->p)) == -99 )
		goto st530;
	if ( (*( sm->p)) <= -65 )
		goto st527;
	goto tr657;
st530:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof530;
case 530:
	if ( (*( sm->p)) > -84 ) {
		if ( -82 <= (*( sm->p)) && (*( sm->p)) <= -65 )
			goto tr651;
	} else
		goto tr651;
	goto tr657;
st531:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof531;
case 531:
	if ( (*( sm->p)) == -128 )
		goto st532;
	if ( -127 <= (*( sm->p)) && (*( sm->p)) <= -65 )
		goto st527;
	goto tr657;
st532:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof532;
case 532:
	if ( (*( sm->p)) < -110 ) {
		if ( -125 <= (*( sm->p)) && (*( sm->p)) <= -121 )
			goto tr651;
	} else if ( (*( sm->p)) > -109 ) {
		if ( -99 <= (*( sm->p)) && (*( sm->p)) <= -65 )
			goto tr651;
	} else
		goto tr651;
	goto tr657;
st533:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof533;
case 533:
	switch( (*( sm->p)) ) {
		case -68: goto st534;
		case -67: goto st535;
	}
	if ( (*( sm->p)) <= -65 )
		goto st527;
	goto tr657;
st534:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof534;
case 534:
	if ( (*( sm->p)) < -118 ) {
		if ( (*( sm->p)) <= -120 )
			goto tr651;
	} else if ( (*( sm->p)) > -68 ) {
		if ( -66 <= (*( sm->p)) && (*( sm->p)) <= -65 )
			goto tr651;
	} else
		goto tr651;
	goto tr657;
st535:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof535;
case 535:
	if ( (*( sm->p)) < -98 ) {
		if ( (*( sm->p)) <= -100 )
			goto tr651;
	} else if ( (*( sm->p)) > -97 ) {
		if ( (*( sm->p)) > -94 ) {
			if ( -92 <= (*( sm->p)) && (*( sm->p)) <= -65 )
				goto tr651;
		} else if ( (*( sm->p)) >= -95 )
			goto tr651;
	} else
		goto tr651;
	goto tr657;
st536:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof536;
case 536:
	if ( (*( sm->p)) <= -65 )
		goto st528;
	goto tr657;
st537:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof537;
case 537:
	switch( (*( sm->p)) ) {
		case -30: goto st529;
		case -29: goto st531;
		case -17: goto st533;
		case 32: goto tr657;
		case 34: goto st537;
		case 35: goto tr650;
		case 39: goto st537;
		case 44: goto st537;
		case 46: goto st537;
		case 60: goto tr657;
		case 62: goto tr657;
		case 63: goto st538;
		case 91: goto tr657;
		case 93: goto tr657;
	}
	if ( (*( sm->p)) < -16 ) {
		if ( (*( sm->p)) < -62 ) {
			if ( (*( sm->p)) <= -63 )
				goto tr657;
		} else if ( (*( sm->p)) > -33 ) {
			if ( -32 <= (*( sm->p)) && (*( sm->p)) <= -18 )
				goto st528;
		} else
			goto st527;
	} else if ( (*( sm->p)) > -12 ) {
		if ( (*( sm->p)) < 9 ) {
			if ( -11 <= (*( sm->p)) && (*( sm->p)) <= 0 )
				goto tr657;
		} else if ( (*( sm->p)) > 13 ) {
			if ( 58 <= (*( sm->p)) && (*( sm->p)) <= 59 )
				goto st537;
		} else
			goto tr657;
	} else
		goto st536;
	goto tr651;
st538:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof538;
case 538:
	switch( (*( sm->p)) ) {
		case -30: goto st541;
		case -29: goto st543;
		case -17: goto st545;
		case 32: goto tr173;
		case 34: goto st538;
		case 35: goto tr650;
		case 39: goto st538;
		case 44: goto st538;
		case 46: goto st538;
		case 63: goto st538;
	}
	if ( (*( sm->p)) < -16 ) {
		if ( (*( sm->p)) < -62 ) {
			if ( (*( sm->p)) <= -63 )
				goto tr173;
		} else if ( (*( sm->p)) > -33 ) {
			if ( -32 <= (*( sm->p)) && (*( sm->p)) <= -18 )
				goto st540;
		} else
			goto st539;
	} else if ( (*( sm->p)) > -12 ) {
		if ( (*( sm->p)) < 9 ) {
			if ( -11 <= (*( sm->p)) && (*( sm->p)) <= 0 )
				goto tr173;
		} else if ( (*( sm->p)) > 13 ) {
			if ( 58 <= (*( sm->p)) && (*( sm->p)) <= 59 )
				goto st538;
		} else
			goto tr173;
	} else
		goto st548;
	goto tr686;
st539:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof539;
case 539:
	if ( (*( sm->p)) <= -65 )
		goto tr686;
	goto tr173;
tr686:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 375 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 57;}
	goto st1472;
st1472:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1472;
case 1472:
#line 13494 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case -30: goto st541;
		case -29: goto st543;
		case -17: goto st545;
		case 32: goto tr1939;
		case 34: goto st538;
		case 35: goto tr650;
		case 39: goto st538;
		case 44: goto st538;
		case 46: goto st538;
		case 63: goto st538;
	}
	if ( (*( sm->p)) < -16 ) {
		if ( (*( sm->p)) < -62 ) {
			if ( (*( sm->p)) <= -63 )
				goto tr1939;
		} else if ( (*( sm->p)) > -33 ) {
			if ( -32 <= (*( sm->p)) && (*( sm->p)) <= -18 )
				goto st540;
		} else
			goto st539;
	} else if ( (*( sm->p)) > -12 ) {
		if ( (*( sm->p)) < 9 ) {
			if ( -11 <= (*( sm->p)) && (*( sm->p)) <= 0 )
				goto tr1939;
		} else if ( (*( sm->p)) > 13 ) {
			if ( 58 <= (*( sm->p)) && (*( sm->p)) <= 59 )
				goto st538;
		} else
			goto tr1939;
	} else
		goto st548;
	goto tr686;
st540:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof540;
case 540:
	if ( (*( sm->p)) <= -65 )
		goto st539;
	goto tr173;
st541:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof541;
case 541:
	if ( (*( sm->p)) == -99 )
		goto st542;
	if ( (*( sm->p)) <= -65 )
		goto st539;
	goto tr173;
st542:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof542;
case 542:
	if ( (*( sm->p)) > -84 ) {
		if ( -82 <= (*( sm->p)) && (*( sm->p)) <= -65 )
			goto tr686;
	} else
		goto tr686;
	goto tr173;
st543:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof543;
case 543:
	if ( (*( sm->p)) == -128 )
		goto st544;
	if ( -127 <= (*( sm->p)) && (*( sm->p)) <= -65 )
		goto st539;
	goto tr173;
st544:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof544;
case 544:
	if ( (*( sm->p)) < -110 ) {
		if ( -125 <= (*( sm->p)) && (*( sm->p)) <= -121 )
			goto tr686;
	} else if ( (*( sm->p)) > -109 ) {
		if ( -99 <= (*( sm->p)) && (*( sm->p)) <= -65 )
			goto tr686;
	} else
		goto tr686;
	goto tr173;
st545:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof545;
case 545:
	switch( (*( sm->p)) ) {
		case -68: goto st546;
		case -67: goto st547;
	}
	if ( (*( sm->p)) <= -65 )
		goto st539;
	goto tr173;
st546:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof546;
case 546:
	if ( (*( sm->p)) < -118 ) {
		if ( (*( sm->p)) <= -120 )
			goto tr686;
	} else if ( (*( sm->p)) > -68 ) {
		if ( -66 <= (*( sm->p)) && (*( sm->p)) <= -65 )
			goto tr686;
	} else
		goto tr686;
	goto tr173;
st547:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof547;
case 547:
	if ( (*( sm->p)) < -98 ) {
		if ( (*( sm->p)) <= -100 )
			goto tr686;
	} else if ( (*( sm->p)) > -97 ) {
		if ( (*( sm->p)) > -94 ) {
			if ( -92 <= (*( sm->p)) && (*( sm->p)) <= -65 )
				goto tr686;
		} else if ( (*( sm->p)) >= -95 )
			goto tr686;
	} else
		goto tr686;
	goto tr173;
st548:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof548;
case 548:
	if ( (*( sm->p)) <= -65 )
		goto st540;
	goto tr173;
st549:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof549;
case 549:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr691;
	goto tr173;
tr691:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 375 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 57;}
	goto st1473;
st1473:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1473;
case 1473:
#line 13637 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 35: goto tr650;
		case 47: goto tr651;
		case 63: goto st538;
	}
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr691;
	goto tr1939;
tr1938:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 575 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 94;}
	goto st1474;
st1474:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1474;
case 1474:
#line 13653 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 58: goto st497;
		case 91: goto tr1782;
		case 123: goto tr1783;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1781;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1781;
	} else
		goto tr1781;
	goto tr1760;
tr1745:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
#line 575 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 94;}
	goto st1475;
st1475:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1475;
case 1475:
#line 13676 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 77: goto tr1940;
		case 83: goto tr1941;
		case 91: goto tr1782;
		case 109: goto tr1940;
		case 115: goto tr1941;
		case 123: goto tr1783;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1781;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1781;
	} else
		goto tr1781;
	goto tr1760;
tr1940:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 575 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 94;}
	goto st1476;
st1476:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1476;
case 1476:
#line 13701 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 80: goto tr1942;
		case 91: goto tr1782;
		case 112: goto tr1942;
		case 123: goto tr1783;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1781;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1781;
	} else
		goto tr1781;
	goto tr1760;
tr1942:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 575 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 94;}
	goto st1477;
st1477:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1477;
case 1477:
#line 13724 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 76: goto tr1943;
		case 91: goto tr1782;
		case 108: goto tr1943;
		case 123: goto tr1783;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1781;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1781;
	} else
		goto tr1781;
	goto tr1760;
tr1943:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 575 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 94;}
	goto st1478;
st1478:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1478;
case 1478:
#line 13747 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 73: goto tr1944;
		case 91: goto tr1782;
		case 105: goto tr1944;
		case 123: goto tr1783;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1781;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1781;
	} else
		goto tr1781;
	goto tr1760;
tr1944:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 575 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 94;}
	goto st1479;
st1479:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1479;
case 1479:
#line 13770 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 67: goto tr1945;
		case 91: goto tr1782;
		case 99: goto tr1945;
		case 123: goto tr1783;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1781;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1781;
	} else
		goto tr1781;
	goto tr1760;
tr1945:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 575 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 94;}
	goto st1480;
st1480:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1480;
case 1480:
#line 13793 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 65: goto tr1946;
		case 91: goto tr1782;
		case 97: goto tr1946;
		case 123: goto tr1783;
	}
	if ( (*( sm->p)) < 66 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1781;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 98 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1781;
	} else
		goto tr1781;
	goto tr1760;
tr1946:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 575 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 94;}
	goto st1481;
st1481:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1481;
case 1481:
#line 13816 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 84: goto tr1947;
		case 91: goto tr1782;
		case 116: goto tr1947;
		case 123: goto tr1783;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1781;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1781;
	} else
		goto tr1781;
	goto tr1760;
tr1947:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 575 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 94;}
	goto st1482;
st1482:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1482;
case 1482:
#line 13839 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 73: goto tr1948;
		case 91: goto tr1782;
		case 105: goto tr1948;
		case 123: goto tr1783;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1781;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1781;
	} else
		goto tr1781;
	goto tr1760;
tr1948:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 575 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 94;}
	goto st1483;
st1483:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1483;
case 1483:
#line 13862 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 79: goto tr1949;
		case 91: goto tr1782;
		case 111: goto tr1949;
		case 123: goto tr1783;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1781;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1781;
	} else
		goto tr1781;
	goto tr1760;
tr1949:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 575 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 94;}
	goto st1484;
st1484:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1484;
case 1484:
#line 13885 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 78: goto tr1950;
		case 91: goto tr1782;
		case 110: goto tr1950;
		case 123: goto tr1783;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1781;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1781;
	} else
		goto tr1781;
	goto tr1760;
tr1950:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 575 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 94;}
	goto st1485;
st1485:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1485;
case 1485:
#line 13908 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 32: goto st550;
		case 91: goto tr1782;
		case 123: goto tr1783;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1781;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1781;
	} else
		goto tr1781;
	goto tr1760;
st550:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof550;
case 550:
	if ( (*( sm->p)) == 35 )
		goto st551;
	goto tr176;
st551:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof551;
case 551:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr693;
	goto tr176;
tr693:
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st1486;
st1486:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1486;
case 1486:
#line 13943 "ext/dtext/dtext.cpp"
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto st1486;
	goto tr1952;
tr1941:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 575 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 94;}
	goto st1487;
st1487:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1487;
case 1487:
#line 13954 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 83: goto tr1954;
		case 91: goto tr1782;
		case 115: goto tr1954;
		case 123: goto tr1783;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1781;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1781;
	} else
		goto tr1781;
	goto tr1760;
tr1954:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 575 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 94;}
	goto st1488;
st1488:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1488;
case 1488:
#line 13977 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 85: goto tr1955;
		case 91: goto tr1782;
		case 117: goto tr1955;
		case 123: goto tr1783;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1781;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1781;
	} else
		goto tr1781;
	goto tr1760;
tr1955:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 575 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 94;}
	goto st1489;
st1489:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1489;
case 1489:
#line 14000 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 69: goto tr1956;
		case 91: goto tr1782;
		case 101: goto tr1956;
		case 123: goto tr1783;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1781;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1781;
	} else
		goto tr1781;
	goto tr1760;
tr1956:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 575 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 94;}
	goto st1490;
st1490:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1490;
case 1490:
#line 14023 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 32: goto st552;
		case 91: goto tr1782;
		case 123: goto tr1783;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1781;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1781;
	} else
		goto tr1781;
	goto tr1760;
st552:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof552;
case 552:
	if ( (*( sm->p)) == 35 )
		goto st553;
	goto tr176;
st553:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof553;
case 553:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr695;
	goto tr176;
tr695:
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st1491;
st1491:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1491;
case 1491:
#line 14058 "ext/dtext/dtext.cpp"
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto st1491;
	goto tr1958;
tr1746:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
#line 575 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 94;}
	goto st1492;
st1492:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1492;
case 1492:
#line 14070 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 69: goto tr1960;
		case 79: goto tr1961;
		case 91: goto tr1782;
		case 101: goto tr1960;
		case 111: goto tr1961;
		case 123: goto tr1783;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1781;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1781;
	} else
		goto tr1781;
	goto tr1760;
tr1960:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 575 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 94;}
	goto st1493;
st1493:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1493;
case 1493:
#line 14095 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 68: goto tr1962;
		case 91: goto tr1782;
		case 100: goto tr1962;
		case 123: goto tr1783;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1781;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1781;
	} else
		goto tr1781;
	goto tr1760;
tr1962:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 575 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 94;}
	goto st1494;
st1494:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1494;
case 1494:
#line 14118 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 73: goto tr1963;
		case 91: goto tr1782;
		case 105: goto tr1963;
		case 123: goto tr1783;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1781;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1781;
	} else
		goto tr1781;
	goto tr1760;
tr1963:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 575 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 94;}
	goto st1495;
st1495:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1495;
case 1495:
#line 14141 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 65: goto tr1964;
		case 91: goto tr1782;
		case 97: goto tr1964;
		case 123: goto tr1783;
	}
	if ( (*( sm->p)) < 66 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1781;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 98 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1781;
	} else
		goto tr1781;
	goto tr1760;
tr1964:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 575 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 94;}
	goto st1496;
st1496:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1496;
case 1496:
#line 14164 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 32: goto st554;
		case 91: goto tr1782;
		case 123: goto tr1783;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1781;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1781;
	} else
		goto tr1781;
	goto tr1760;
st554:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof554;
case 554:
	switch( (*( sm->p)) ) {
		case 65: goto st555;
		case 97: goto st555;
	}
	goto tr176;
st555:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof555;
case 555:
	switch( (*( sm->p)) ) {
		case 83: goto st556;
		case 115: goto st556;
	}
	goto tr176;
st556:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof556;
case 556:
	switch( (*( sm->p)) ) {
		case 83: goto st557;
		case 115: goto st557;
	}
	goto tr176;
st557:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof557;
case 557:
	switch( (*( sm->p)) ) {
		case 69: goto st558;
		case 101: goto st558;
	}
	goto tr176;
st558:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof558;
case 558:
	switch( (*( sm->p)) ) {
		case 84: goto st559;
		case 116: goto st559;
	}
	goto tr176;
st559:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof559;
case 559:
	if ( (*( sm->p)) == 32 )
		goto st560;
	goto tr176;
st560:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof560;
case 560:
	if ( (*( sm->p)) == 35 )
		goto st561;
	goto tr176;
st561:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof561;
case 561:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr703;
	goto tr176;
tr703:
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st1497;
st1497:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1497;
case 1497:
#line 14251 "ext/dtext/dtext.cpp"
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto st1497;
	goto tr1966;
tr1961:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 575 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 94;}
	goto st1498;
st1498:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1498;
case 1498:
#line 14262 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 68: goto tr1968;
		case 91: goto tr1782;
		case 100: goto tr1968;
		case 123: goto tr1783;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1781;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1781;
	} else
		goto tr1781;
	goto tr1760;
tr1968:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 575 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 94;}
	goto st1499;
st1499:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1499;
case 1499:
#line 14285 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 32: goto st562;
		case 82: goto tr1970;
		case 91: goto tr1782;
		case 114: goto tr1970;
		case 123: goto tr1783;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1781;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1781;
	} else
		goto tr1781;
	goto tr1760;
st562:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof562;
case 562:
	switch( (*( sm->p)) ) {
		case 65: goto st563;
		case 97: goto st563;
	}
	goto tr176;
st563:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof563;
case 563:
	switch( (*( sm->p)) ) {
		case 67: goto st564;
		case 99: goto st564;
	}
	goto tr176;
st564:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof564;
case 564:
	switch( (*( sm->p)) ) {
		case 84: goto st565;
		case 116: goto st565;
	}
	goto tr176;
st565:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof565;
case 565:
	switch( (*( sm->p)) ) {
		case 73: goto st566;
		case 105: goto st566;
	}
	goto tr176;
st566:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof566;
case 566:
	switch( (*( sm->p)) ) {
		case 79: goto st567;
		case 111: goto st567;
	}
	goto tr176;
st567:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof567;
case 567:
	switch( (*( sm->p)) ) {
		case 78: goto st568;
		case 110: goto st568;
	}
	goto tr176;
st568:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof568;
case 568:
	if ( (*( sm->p)) == 32 )
		goto st569;
	goto tr176;
st569:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof569;
case 569:
	if ( (*( sm->p)) == 35 )
		goto st570;
	goto tr176;
st570:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof570;
case 570:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr712;
	goto tr176;
tr712:
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st1500;
st1500:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1500;
case 1500:
#line 14383 "ext/dtext/dtext.cpp"
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto st1500;
	goto tr1971;
tr1970:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 575 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 94;}
	goto st1501;
st1501:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1501;
case 1501:
#line 14394 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 69: goto tr1973;
		case 91: goto tr1782;
		case 101: goto tr1973;
		case 123: goto tr1783;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1781;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1781;
	} else
		goto tr1781;
	goto tr1760;
tr1973:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 575 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 94;}
	goto st1502;
st1502:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1502;
case 1502:
#line 14417 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 80: goto tr1974;
		case 91: goto tr1782;
		case 112: goto tr1974;
		case 123: goto tr1783;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1781;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1781;
	} else
		goto tr1781;
	goto tr1760;
tr1974:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 575 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 94;}
	goto st1503;
st1503:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1503;
case 1503:
#line 14440 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 79: goto tr1975;
		case 91: goto tr1782;
		case 111: goto tr1975;
		case 123: goto tr1783;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1781;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1781;
	} else
		goto tr1781;
	goto tr1760;
tr1975:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 575 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 94;}
	goto st1504;
st1504:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1504;
case 1504:
#line 14463 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 82: goto tr1976;
		case 91: goto tr1782;
		case 114: goto tr1976;
		case 123: goto tr1783;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1781;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1781;
	} else
		goto tr1781;
	goto tr1760;
tr1976:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 575 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 94;}
	goto st1505;
st1505:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1505;
case 1505:
#line 14486 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 84: goto tr1977;
		case 91: goto tr1782;
		case 116: goto tr1977;
		case 123: goto tr1783;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1781;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1781;
	} else
		goto tr1781;
	goto tr1760;
tr1977:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 575 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 94;}
	goto st1506;
st1506:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1506;
case 1506:
#line 14509 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 32: goto st571;
		case 91: goto tr1782;
		case 123: goto tr1783;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1781;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1781;
	} else
		goto tr1781;
	goto tr1760;
st571:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof571;
case 571:
	if ( (*( sm->p)) == 35 )
		goto st572;
	goto tr176;
st572:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof572;
case 572:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr714;
	goto tr176;
tr714:
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st1507;
st1507:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1507;
case 1507:
#line 14544 "ext/dtext/dtext.cpp"
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto st1507;
	goto tr1979;
tr1747:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
#line 575 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 94;}
	goto st1508;
st1508:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1508;
case 1508:
#line 14556 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 73: goto tr1981;
		case 79: goto tr1982;
		case 91: goto tr1782;
		case 105: goto tr1981;
		case 111: goto tr1982;
		case 123: goto tr1783;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1781;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1781;
	} else
		goto tr1781;
	goto tr1760;
tr1981:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 575 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 94;}
	goto st1509;
st1509:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1509;
case 1509:
#line 14581 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 74: goto tr1983;
		case 91: goto tr1782;
		case 106: goto tr1983;
		case 123: goto tr1783;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1781;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1781;
	} else
		goto tr1781;
	goto tr1760;
tr1983:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 575 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 94;}
	goto st1510;
st1510:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1510;
case 1510:
#line 14604 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 73: goto tr1984;
		case 91: goto tr1782;
		case 105: goto tr1984;
		case 123: goto tr1783;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1781;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1781;
	} else
		goto tr1781;
	goto tr1760;
tr1984:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 575 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 94;}
	goto st1511;
st1511:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1511;
case 1511:
#line 14627 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 69: goto tr1985;
		case 91: goto tr1782;
		case 101: goto tr1985;
		case 123: goto tr1783;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1781;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1781;
	} else
		goto tr1781;
	goto tr1760;
tr1985:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 575 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 94;}
	goto st1512;
st1512:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1512;
case 1512:
#line 14650 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 32: goto st573;
		case 91: goto tr1782;
		case 123: goto tr1783;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1781;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1781;
	} else
		goto tr1781;
	goto tr1760;
st573:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof573;
case 573:
	if ( (*( sm->p)) == 35 )
		goto st574;
	goto tr176;
st574:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof574;
case 574:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr716;
	goto tr176;
tr716:
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st1513;
st1513:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1513;
case 1513:
#line 14685 "ext/dtext/dtext.cpp"
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto st1513;
	goto tr1987;
tr1982:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 575 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 94;}
	goto st1514;
st1514:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1514;
case 1514:
#line 14696 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 84: goto tr1989;
		case 91: goto tr1782;
		case 116: goto tr1989;
		case 123: goto tr1783;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1781;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1781;
	} else
		goto tr1781;
	goto tr1760;
tr1989:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 575 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 94;}
	goto st1515;
st1515:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1515;
case 1515:
#line 14719 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 69: goto tr1990;
		case 91: goto tr1782;
		case 101: goto tr1990;
		case 123: goto tr1783;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1781;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1781;
	} else
		goto tr1781;
	goto tr1760;
tr1990:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 575 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 94;}
	goto st1516;
st1516:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1516;
case 1516:
#line 14742 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 32: goto st575;
		case 91: goto tr1782;
		case 123: goto tr1783;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1781;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1781;
	} else
		goto tr1781;
	goto tr1760;
st575:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof575;
case 575:
	if ( (*( sm->p)) == 35 )
		goto st576;
	goto tr176;
st576:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof576;
case 576:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr718;
	goto tr176;
tr718:
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st1517;
st1517:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1517;
case 1517:
#line 14777 "ext/dtext/dtext.cpp"
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto st1517;
	goto tr1992;
tr1748:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
#line 575 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 94;}
	goto st1518;
st1518:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1518;
case 1518:
#line 14789 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 65: goto tr1994;
		case 73: goto tr1995;
		case 79: goto tr1996;
		case 85: goto tr1997;
		case 91: goto tr1782;
		case 97: goto tr1994;
		case 105: goto tr1995;
		case 111: goto tr1996;
		case 117: goto tr1997;
		case 123: goto tr1783;
	}
	if ( (*( sm->p)) < 66 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1781;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 98 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1781;
	} else
		goto tr1781;
	goto tr1760;
tr1994:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 575 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 94;}
	goto st1519;
st1519:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1519;
case 1519:
#line 14818 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 87: goto tr1998;
		case 91: goto tr1782;
		case 119: goto tr1998;
		case 123: goto tr1783;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1781;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1781;
	} else
		goto tr1781;
	goto tr1760;
tr1998:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 575 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 94;}
	goto st1520;
st1520:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1520;
case 1520:
#line 14841 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 79: goto tr1999;
		case 91: goto tr1782;
		case 111: goto tr1999;
		case 123: goto tr1783;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1781;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1781;
	} else
		goto tr1781;
	goto tr1760;
tr1999:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 575 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 94;}
	goto st1521;
st1521:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1521;
case 1521:
#line 14864 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 79: goto tr2000;
		case 91: goto tr1782;
		case 111: goto tr2000;
		case 123: goto tr1783;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1781;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1781;
	} else
		goto tr1781;
	goto tr1760;
tr2000:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 575 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 94;}
	goto st1522;
st1522:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1522;
case 1522:
#line 14887 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 32: goto st577;
		case 91: goto tr1782;
		case 123: goto tr1783;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1781;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1781;
	} else
		goto tr1781;
	goto tr1760;
st577:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof577;
case 577:
	if ( (*( sm->p)) == 35 )
		goto st578;
	goto tr176;
st578:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof578;
case 578:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr720;
	goto tr176;
tr720:
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st1523;
st1523:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1523;
case 1523:
#line 14922 "ext/dtext/dtext.cpp"
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto st1523;
	goto tr2002;
tr1995:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 575 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 94;}
	goto st1524;
st1524:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1524;
case 1524:
#line 14933 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 88: goto tr2004;
		case 91: goto tr1782;
		case 120: goto tr2004;
		case 123: goto tr1783;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1781;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1781;
	} else
		goto tr1781;
	goto tr1760;
tr2004:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 575 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 94;}
	goto st1525;
st1525:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1525;
case 1525:
#line 14956 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 73: goto tr2005;
		case 91: goto tr1782;
		case 105: goto tr2005;
		case 123: goto tr1783;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1781;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1781;
	} else
		goto tr1781;
	goto tr1760;
tr2005:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 575 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 94;}
	goto st1526;
st1526:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1526;
case 1526:
#line 14979 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 86: goto tr2006;
		case 91: goto tr1782;
		case 118: goto tr2006;
		case 123: goto tr1783;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1781;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1781;
	} else
		goto tr1781;
	goto tr1760;
tr2006:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 575 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 94;}
	goto st1527;
st1527:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1527;
case 1527:
#line 15002 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 32: goto st579;
		case 91: goto tr1782;
		case 123: goto tr1783;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1781;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1781;
	} else
		goto tr1781;
	goto tr1760;
st579:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof579;
case 579:
	if ( (*( sm->p)) == 35 )
		goto st580;
	goto tr176;
st580:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof580;
case 580:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr722;
	goto tr176;
tr2010:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
	goto st1528;
tr722:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st1528;
st1528:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1528;
case 1528:
#line 15041 "ext/dtext/dtext.cpp"
	if ( (*( sm->p)) == 47 )
		goto tr2009;
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr2010;
	goto tr2008;
tr2009:
#line 72 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
	goto st581;
st581:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof581;
case 581:
#line 15053 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 80: goto st582;
		case 112: goto st582;
	}
	goto tr723;
st582:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof582;
case 582:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr725;
	goto tr723;
tr725:
#line 73 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st1529;
st1529:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1529;
case 1529:
#line 15072 "ext/dtext/dtext.cpp"
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto st1529;
	goto tr2011;
tr1996:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 575 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 94;}
	goto st1530;
st1530:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1530;
case 1530:
#line 15083 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 79: goto tr2013;
		case 83: goto tr2014;
		case 91: goto tr1782;
		case 111: goto tr2013;
		case 115: goto tr2014;
		case 123: goto tr1783;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1781;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1781;
	} else
		goto tr1781;
	goto tr1760;
tr2013:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 575 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 94;}
	goto st1531;
st1531:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1531;
case 1531:
#line 15108 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 76: goto tr2015;
		case 91: goto tr1782;
		case 108: goto tr2015;
		case 123: goto tr1783;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1781;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1781;
	} else
		goto tr1781;
	goto tr1760;
tr2015:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 575 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 94;}
	goto st1532;
st1532:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1532;
case 1532:
#line 15131 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 32: goto st583;
		case 91: goto tr1782;
		case 123: goto tr1783;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1781;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1781;
	} else
		goto tr1781;
	goto tr1760;
st583:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof583;
case 583:
	if ( (*( sm->p)) == 35 )
		goto st584;
	goto tr176;
st584:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof584;
case 584:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr727;
	goto tr176;
tr727:
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st1533;
st1533:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1533;
case 1533:
#line 15166 "ext/dtext/dtext.cpp"
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto st1533;
	goto tr2017;
tr2014:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 575 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 94;}
	goto st1534;
st1534:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1534;
case 1534:
#line 15177 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 84: goto tr2019;
		case 91: goto tr1782;
		case 116: goto tr2019;
		case 123: goto tr1783;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1781;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1781;
	} else
		goto tr1781;
	goto tr1760;
tr2019:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 575 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 94;}
	goto st1535;
st1535:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1535;
case 1535:
#line 15200 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 32: goto st585;
		case 91: goto tr1782;
		case 123: goto tr1783;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1781;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1781;
	} else
		goto tr1781;
	goto tr1760;
st585:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof585;
case 585:
	if ( (*( sm->p)) == 35 )
		goto st586;
	goto tr176;
st586:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof586;
case 586:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr729;
	goto tr176;
tr729:
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st1536;
st1536:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1536;
case 1536:
#line 15235 "ext/dtext/dtext.cpp"
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto st1536;
	goto tr2021;
tr1997:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 575 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 94;}
	goto st1537;
st1537:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1537;
case 1537:
#line 15246 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 76: goto tr2023;
		case 91: goto tr1782;
		case 108: goto tr2023;
		case 123: goto tr1783;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1781;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1781;
	} else
		goto tr1781;
	goto tr1760;
tr2023:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 575 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 94;}
	goto st1538;
st1538:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1538;
case 1538:
#line 15269 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 76: goto tr2024;
		case 91: goto tr1782;
		case 108: goto tr2024;
		case 123: goto tr1783;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1781;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1781;
	} else
		goto tr1781;
	goto tr1760;
tr2024:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 575 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 94;}
	goto st1539;
st1539:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1539;
case 1539:
#line 15292 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 32: goto st587;
		case 91: goto tr1782;
		case 123: goto tr1783;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1781;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1781;
	} else
		goto tr1781;
	goto tr1760;
st587:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof587;
case 587:
	if ( (*( sm->p)) == 35 )
		goto st588;
	goto tr176;
st588:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof588;
case 588:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr731;
	goto tr176;
tr731:
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st1540;
st1540:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1540;
case 1540:
#line 15327 "ext/dtext/dtext.cpp"
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto st1540;
	goto tr2026;
tr1749:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
#line 575 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 94;}
	goto st1541;
st1541:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1541;
case 1541:
#line 15339 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 65: goto tr2028;
		case 69: goto tr2029;
		case 91: goto tr1782;
		case 97: goto tr2028;
		case 101: goto tr2029;
		case 123: goto tr1783;
	}
	if ( (*( sm->p)) < 66 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1781;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 98 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1781;
	} else
		goto tr1781;
	goto tr1760;
tr2028:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 575 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 94;}
	goto st1542;
st1542:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1542;
case 1542:
#line 15364 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 78: goto tr2030;
		case 91: goto tr1782;
		case 110: goto tr2030;
		case 123: goto tr1783;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1781;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1781;
	} else
		goto tr1781;
	goto tr1760;
tr2030:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 575 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 94;}
	goto st1543;
st1543:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1543;
case 1543:
#line 15387 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 75: goto tr2031;
		case 91: goto tr1782;
		case 107: goto tr2031;
		case 123: goto tr1783;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1781;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1781;
	} else
		goto tr1781;
	goto tr1760;
tr2031:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 575 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 94;}
	goto st1544;
st1544:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1544;
case 1544:
#line 15410 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 65: goto tr2032;
		case 91: goto tr1782;
		case 97: goto tr2032;
		case 123: goto tr1783;
	}
	if ( (*( sm->p)) < 66 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1781;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 98 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1781;
	} else
		goto tr1781;
	goto tr1760;
tr2032:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 575 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 94;}
	goto st1545;
st1545:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1545;
case 1545:
#line 15433 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 75: goto tr2033;
		case 91: goto tr1782;
		case 107: goto tr2033;
		case 123: goto tr1783;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1781;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1781;
	} else
		goto tr1781;
	goto tr1760;
tr2033:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 575 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 94;}
	goto st1546;
st1546:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1546;
case 1546:
#line 15456 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 85: goto tr2034;
		case 91: goto tr1782;
		case 117: goto tr2034;
		case 123: goto tr1783;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1781;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1781;
	} else
		goto tr1781;
	goto tr1760;
tr2034:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 575 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 94;}
	goto st1547;
st1547:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1547;
case 1547:
#line 15479 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 32: goto st589;
		case 91: goto tr1782;
		case 123: goto tr1783;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1781;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1781;
	} else
		goto tr1781;
	goto tr1760;
st589:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof589;
case 589:
	if ( (*( sm->p)) == 35 )
		goto st590;
	goto tr176;
st590:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof590;
case 590:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr733;
	goto tr176;
tr733:
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st1548;
st1548:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1548;
case 1548:
#line 15514 "ext/dtext/dtext.cpp"
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto st1548;
	goto tr2036;
tr2029:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 575 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 94;}
	goto st1549;
st1549:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1549;
case 1549:
#line 15525 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 73: goto tr2038;
		case 91: goto tr1782;
		case 105: goto tr2038;
		case 123: goto tr1783;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1781;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1781;
	} else
		goto tr1781;
	goto tr1760;
tr2038:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 575 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 94;}
	goto st1550;
st1550:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1550;
case 1550:
#line 15548 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 71: goto tr2039;
		case 91: goto tr1782;
		case 103: goto tr2039;
		case 123: goto tr1783;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1781;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1781;
	} else
		goto tr1781;
	goto tr1760;
tr2039:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 575 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 94;}
	goto st1551;
st1551:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1551;
case 1551:
#line 15571 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 65: goto tr2040;
		case 91: goto tr1782;
		case 97: goto tr2040;
		case 123: goto tr1783;
	}
	if ( (*( sm->p)) < 66 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1781;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 98 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1781;
	} else
		goto tr1781;
	goto tr1760;
tr2040:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 575 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 94;}
	goto st1552;
st1552:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1552;
case 1552:
#line 15594 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 32: goto st591;
		case 91: goto tr1782;
		case 123: goto tr1783;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1781;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1781;
	} else
		goto tr1781;
	goto tr1760;
st591:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof591;
case 591:
	if ( (*( sm->p)) == 35 )
		goto st592;
	goto tr176;
st592:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof592;
case 592:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr735;
	goto tr176;
tr735:
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st1553;
st1553:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1553;
case 1553:
#line 15629 "ext/dtext/dtext.cpp"
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto st1553;
	goto tr2042;
tr1750:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
#line 575 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 94;}
	goto st1554;
st1554:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1554;
case 1554:
#line 15641 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 79: goto tr2044;
		case 87: goto tr2045;
		case 91: goto tr1782;
		case 111: goto tr2044;
		case 119: goto tr2045;
		case 123: goto tr1783;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1781;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1781;
	} else
		goto tr1781;
	goto tr1760;
tr2044:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 575 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 94;}
	goto st1555;
st1555:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1555;
case 1555:
#line 15666 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 80: goto tr2046;
		case 91: goto tr1782;
		case 112: goto tr2046;
		case 123: goto tr1783;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1781;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1781;
	} else
		goto tr1781;
	goto tr1760;
tr2046:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 575 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 94;}
	goto st1556;
st1556:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1556;
case 1556:
#line 15689 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 73: goto tr2047;
		case 91: goto tr1782;
		case 105: goto tr2047;
		case 123: goto tr1783;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1781;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1781;
	} else
		goto tr1781;
	goto tr1760;
tr2047:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 575 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 94;}
	goto st1557;
st1557:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1557;
case 1557:
#line 15712 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 67: goto tr2048;
		case 91: goto tr1782;
		case 99: goto tr2048;
		case 123: goto tr1783;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1781;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1781;
	} else
		goto tr1781;
	goto tr1760;
tr2048:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 575 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 94;}
	goto st1558;
st1558:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1558;
case 1558:
#line 15735 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 32: goto st593;
		case 91: goto tr1782;
		case 123: goto tr1783;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1781;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1781;
	} else
		goto tr1781;
	goto tr1760;
st593:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof593;
case 593:
	if ( (*( sm->p)) == 35 )
		goto st594;
	goto tr176;
st594:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof594;
case 594:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr737;
	goto tr176;
tr2052:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
	goto st1559;
tr737:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st1559;
st1559:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1559;
case 1559:
#line 15774 "ext/dtext/dtext.cpp"
	if ( (*( sm->p)) == 47 )
		goto tr2051;
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr2052;
	goto tr2050;
tr2051:
#line 72 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
	goto st595;
st595:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof595;
case 595:
#line 15786 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 80: goto st596;
		case 112: goto st596;
	}
	goto tr738;
st596:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof596;
case 596:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr740;
	goto tr738;
tr740:
#line 73 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st1560;
st1560:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1560;
case 1560:
#line 15805 "ext/dtext/dtext.cpp"
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto st1560;
	goto tr2053;
tr2045:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 575 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 94;}
	goto st1561;
st1561:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1561;
case 1561:
#line 15816 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 73: goto tr2055;
		case 91: goto tr1782;
		case 105: goto tr2055;
		case 123: goto tr1783;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1781;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1781;
	} else
		goto tr1781;
	goto tr1760;
tr2055:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 575 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 94;}
	goto st1562;
st1562:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1562;
case 1562:
#line 15839 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 84: goto tr2056;
		case 91: goto tr1782;
		case 116: goto tr2056;
		case 123: goto tr1783;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1781;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1781;
	} else
		goto tr1781;
	goto tr1760;
tr2056:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 575 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 94;}
	goto st1563;
st1563:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1563;
case 1563:
#line 15862 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 84: goto tr2057;
		case 91: goto tr1782;
		case 116: goto tr2057;
		case 123: goto tr1783;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1781;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1781;
	} else
		goto tr1781;
	goto tr1760;
tr2057:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 575 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 94;}
	goto st1564;
st1564:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1564;
case 1564:
#line 15885 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 69: goto tr2058;
		case 91: goto tr1782;
		case 101: goto tr2058;
		case 123: goto tr1783;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1781;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1781;
	} else
		goto tr1781;
	goto tr1760;
tr2058:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 575 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 94;}
	goto st1565;
st1565:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1565;
case 1565:
#line 15908 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 82: goto tr2059;
		case 91: goto tr1782;
		case 114: goto tr2059;
		case 123: goto tr1783;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1781;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1781;
	} else
		goto tr1781;
	goto tr1760;
tr2059:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 575 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 94;}
	goto st1566;
st1566:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1566;
case 1566:
#line 15931 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 32: goto st597;
		case 91: goto tr1782;
		case 123: goto tr1783;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1781;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1781;
	} else
		goto tr1781;
	goto tr1760;
st597:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof597;
case 597:
	if ( (*( sm->p)) == 35 )
		goto st598;
	goto tr176;
st598:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof598;
case 598:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr742;
	goto tr176;
tr742:
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st1567;
st1567:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1567;
case 1567:
#line 15966 "ext/dtext/dtext.cpp"
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto st1567;
	goto tr2061;
tr1751:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
#line 575 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 94;}
	goto st1568;
st1568:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1568;
case 1568:
#line 15978 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 83: goto tr2063;
		case 91: goto tr1782;
		case 115: goto tr2063;
		case 123: goto tr1783;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1781;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1781;
	} else
		goto tr1781;
	goto tr1760;
tr2063:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 575 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 94;}
	goto st1569;
st1569:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1569;
case 1569:
#line 16001 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 69: goto tr2064;
		case 91: goto tr1782;
		case 101: goto tr2064;
		case 123: goto tr1783;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1781;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1781;
	} else
		goto tr1781;
	goto tr1760;
tr2064:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 575 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 94;}
	goto st1570;
st1570:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1570;
case 1570:
#line 16024 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 82: goto tr2065;
		case 91: goto tr1782;
		case 114: goto tr2065;
		case 123: goto tr1783;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1781;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1781;
	} else
		goto tr1781;
	goto tr1760;
tr2065:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 575 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 94;}
	goto st1571;
st1571:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1571;
case 1571:
#line 16047 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 32: goto st599;
		case 91: goto tr1782;
		case 123: goto tr1783;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1781;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1781;
	} else
		goto tr1781;
	goto tr1760;
st599:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof599;
case 599:
	if ( (*( sm->p)) == 35 )
		goto st600;
	goto tr176;
st600:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof600;
case 600:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr744;
	goto tr176;
tr744:
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st1572;
st1572:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1572;
case 1572:
#line 16082 "ext/dtext/dtext.cpp"
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto st1572;
	goto tr2067;
tr1752:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
#line 575 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 94;}
	goto st1573;
st1573:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1573;
case 1573:
#line 16094 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 73: goto tr2069;
		case 91: goto tr1782;
		case 105: goto tr2069;
		case 123: goto tr1783;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1781;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1781;
	} else
		goto tr1781;
	goto tr1760;
tr2069:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 575 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 94;}
	goto st1574;
st1574:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1574;
case 1574:
#line 16117 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 75: goto tr2070;
		case 91: goto tr1782;
		case 107: goto tr2070;
		case 123: goto tr1783;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1781;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1781;
	} else
		goto tr1781;
	goto tr1760;
tr2070:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 575 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 94;}
	goto st1575;
st1575:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1575;
case 1575:
#line 16140 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 73: goto tr2071;
		case 91: goto tr1782;
		case 105: goto tr2071;
		case 123: goto tr1783;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1781;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1781;
	} else
		goto tr1781;
	goto tr1760;
tr2071:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 575 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 94;}
	goto st1576;
st1576:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1576;
case 1576:
#line 16163 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 32: goto st601;
		case 91: goto tr1782;
		case 123: goto tr1783;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1781;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1781;
	} else
		goto tr1781;
	goto tr1760;
st601:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof601;
case 601:
	if ( (*( sm->p)) == 35 )
		goto st602;
	goto tr176;
st602:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof602;
case 602:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr746;
	goto tr176;
tr746:
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st1577;
st1577:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1577;
case 1577:
#line 16198 "ext/dtext/dtext.cpp"
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto st1577;
	goto tr2073;
tr1753:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
#line 575 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 94;}
	goto st1578;
st1578:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1578;
case 1578:
#line 16210 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 65: goto tr2075;
		case 91: goto tr1782;
		case 97: goto tr2075;
		case 123: goto tr1783;
	}
	if ( (*( sm->p)) < 66 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1781;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 98 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1781;
	} else
		goto tr1781;
	goto tr1760;
tr2075:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 575 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 94;}
	goto st1579;
st1579:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1579;
case 1579:
#line 16233 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 78: goto tr2076;
		case 91: goto tr1782;
		case 110: goto tr2076;
		case 123: goto tr1783;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1781;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1781;
	} else
		goto tr1781;
	goto tr1760;
tr2076:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 575 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 94;}
	goto st1580;
st1580:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1580;
case 1580:
#line 16256 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 68: goto tr2077;
		case 91: goto tr1782;
		case 100: goto tr2077;
		case 123: goto tr1783;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1781;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1781;
	} else
		goto tr1781;
	goto tr1760;
tr2077:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 575 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 94;}
	goto st1581;
st1581:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1581;
case 1581:
#line 16279 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 69: goto tr2078;
		case 91: goto tr1782;
		case 101: goto tr2078;
		case 123: goto tr1783;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1781;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1781;
	} else
		goto tr1781;
	goto tr1760;
tr2078:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 575 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 94;}
	goto st1582;
st1582:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1582;
case 1582:
#line 16302 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 82: goto tr2079;
		case 91: goto tr1782;
		case 114: goto tr2079;
		case 123: goto tr1783;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1781;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1781;
	} else
		goto tr1781;
	goto tr1760;
tr2079:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 575 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 94;}
	goto st1583;
st1583:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1583;
case 1583:
#line 16325 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 69: goto tr2080;
		case 91: goto tr1782;
		case 101: goto tr2080;
		case 123: goto tr1783;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1781;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1781;
	} else
		goto tr1781;
	goto tr1760;
tr2080:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 575 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 94;}
	goto st1584;
st1584:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1584;
case 1584:
#line 16348 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 32: goto st603;
		case 91: goto tr1782;
		case 123: goto tr1783;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1781;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1781;
	} else
		goto tr1781;
	goto tr1760;
st603:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof603;
case 603:
	if ( (*( sm->p)) == 35 )
		goto st604;
	goto tr176;
st604:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof604;
case 604:
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto tr748;
	goto tr176;
tr748:
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st1585;
st1585:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1585;
case 1585:
#line 16383 "ext/dtext/dtext.cpp"
	if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
		goto st1585;
	goto tr2082;
tr1754:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
#line 72 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
#line 579 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 95;}
	goto st1586;
st1586:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1586;
case 1586:
#line 16396 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr1759;
		case 10: goto tr1759;
		case 13: goto tr1759;
		case 47: goto tr2085;
		case 66: goto tr2086;
		case 67: goto tr2087;
		case 69: goto tr2088;
		case 72: goto tr2089;
		case 73: goto tr2090;
		case 78: goto tr2091;
		case 81: goto tr2092;
		case 83: goto tr2093;
		case 84: goto tr2094;
		case 85: goto tr2095;
		case 91: goto tr2096;
		case 98: goto tr2086;
		case 99: goto tr2087;
		case 101: goto tr2088;
		case 104: goto tr2089;
		case 105: goto tr2090;
		case 110: goto tr2091;
		case 113: goto tr2092;
		case 115: goto tr2093;
		case 116: goto tr2094;
		case 117: goto tr2095;
	}
	goto tr2084;
tr2084:
#line 81 "ext/dtext/dtext.cpp.rl"
	{ sm->f1 = sm->p; }
	goto st605;
st605:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof605;
case 605:
#line 16431 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 10: goto tr180;
		case 13: goto tr180;
		case 93: goto tr750;
	}
	goto st605;
tr750:
#line 82 "ext/dtext/dtext.cpp.rl"
	{ sm->f2 = sm->p; }
	goto st606;
st606:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof606;
case 606:
#line 16445 "ext/dtext/dtext.cpp"
	if ( (*( sm->p)) == 40 )
		goto st607;
	goto tr180;
st607:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof607;
case 607:
	switch( (*( sm->p)) ) {
		case 35: goto tr752;
		case 47: goto tr752;
		case 72: goto tr753;
		case 104: goto tr753;
	}
	goto tr173;
tr752:
#line 83 "ext/dtext/dtext.cpp.rl"
	{ sm->g1 = sm->p; }
	goto st608;
st608:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof608;
case 608:
#line 16466 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr173;
		case 32: goto tr173;
		case 41: goto tr755;
	}
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr173;
	goto st608;
tr753:
#line 83 "ext/dtext/dtext.cpp.rl"
	{ sm->g1 = sm->p; }
	goto st609;
st609:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof609;
case 609:
#line 16481 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 84: goto st610;
		case 116: goto st610;
	}
	goto tr173;
st610:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof610;
case 610:
	switch( (*( sm->p)) ) {
		case 84: goto st611;
		case 116: goto st611;
	}
	goto tr173;
st611:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof611;
case 611:
	switch( (*( sm->p)) ) {
		case 80: goto st612;
		case 112: goto st612;
	}
	goto tr173;
st612:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof612;
case 612:
	switch( (*( sm->p)) ) {
		case 58: goto st613;
		case 83: goto st616;
		case 115: goto st616;
	}
	goto tr173;
st613:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof613;
case 613:
	if ( (*( sm->p)) == 47 )
		goto st614;
	goto tr173;
st614:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof614;
case 614:
	if ( (*( sm->p)) == 47 )
		goto st615;
	goto tr173;
st615:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof615;
case 615:
	switch( (*( sm->p)) ) {
		case 0: goto tr173;
		case 32: goto tr173;
	}
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr173;
	goto st608;
st616:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof616;
case 616:
	if ( (*( sm->p)) == 58 )
		goto st613;
	goto tr173;
tr2085:
#line 81 "ext/dtext/dtext.cpp.rl"
	{ sm->f1 = sm->p; }
	goto st617;
st617:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof617;
case 617:
#line 16553 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 10: goto tr180;
		case 13: goto tr180;
		case 66: goto st618;
		case 67: goto st620;
		case 69: goto st628;
		case 72: goto st634;
		case 73: goto st635;
		case 78: goto st636;
		case 81: goto st642;
		case 83: goto st647;
		case 84: goto st655;
		case 85: goto st666;
		case 93: goto tr750;
		case 98: goto st618;
		case 99: goto st620;
		case 101: goto st628;
		case 104: goto st634;
		case 105: goto st635;
		case 110: goto st636;
		case 113: goto st642;
		case 115: goto st647;
		case 116: goto st655;
		case 117: goto st666;
	}
	goto st605;
st618:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof618;
case 618:
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 10: goto tr180;
		case 13: goto tr180;
		case 82: goto st619;
		case 93: goto tr774;
		case 114: goto st619;
	}
	goto st605;
st619:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof619;
case 619:
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 10: goto tr180;
		case 13: goto tr180;
		case 93: goto tr180;
	}
	goto st605;
st620:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof620;
case 620:
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 10: goto tr180;
		case 13: goto tr180;
		case 79: goto st621;
		case 93: goto tr750;
		case 111: goto st621;
	}
	goto st605;
st621:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof621;
case 621:
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 10: goto tr180;
		case 13: goto tr180;
		case 68: goto st622;
		case 76: goto st623;
		case 93: goto tr750;
		case 100: goto st622;
		case 108: goto st623;
	}
	goto st605;
st622:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof622;
case 622:
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 10: goto tr180;
		case 13: goto tr180;
		case 69: goto st619;
		case 93: goto tr750;
		case 101: goto st619;
	}
	goto st605;
st623:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof623;
case 623:
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 10: goto tr180;
		case 13: goto tr180;
		case 71: goto st624;
		case 93: goto tr180;
		case 103: goto st624;
	}
	goto st605;
st624:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof624;
case 624:
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 10: goto tr180;
		case 13: goto tr180;
		case 82: goto st625;
		case 93: goto tr750;
		case 114: goto st625;
	}
	goto st605;
st625:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof625;
case 625:
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 10: goto tr180;
		case 13: goto tr180;
		case 79: goto st626;
		case 93: goto tr750;
		case 111: goto st626;
	}
	goto st605;
st626:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof626;
case 626:
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 10: goto tr180;
		case 13: goto tr180;
		case 85: goto st627;
		case 93: goto tr750;
		case 117: goto st627;
	}
	goto st605;
st627:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof627;
case 627:
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 10: goto tr180;
		case 13: goto tr180;
		case 80: goto st619;
		case 93: goto tr750;
		case 112: goto st619;
	}
	goto st605;
st628:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof628;
case 628:
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 10: goto tr180;
		case 13: goto tr180;
		case 88: goto st629;
		case 93: goto tr750;
		case 120: goto st629;
	}
	goto st605;
st629:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof629;
case 629:
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 10: goto tr180;
		case 13: goto tr180;
		case 80: goto st630;
		case 93: goto tr750;
		case 112: goto st630;
	}
	goto st605;
st630:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof630;
case 630:
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 10: goto tr180;
		case 13: goto tr180;
		case 65: goto st631;
		case 93: goto tr750;
		case 97: goto st631;
	}
	goto st605;
st631:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof631;
case 631:
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 10: goto tr180;
		case 13: goto tr180;
		case 78: goto st632;
		case 93: goto tr750;
		case 110: goto st632;
	}
	goto st605;
st632:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof632;
case 632:
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 10: goto tr180;
		case 13: goto tr180;
		case 68: goto st633;
		case 93: goto tr750;
		case 100: goto st633;
	}
	goto st605;
st633:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof633;
case 633:
	_widec = (*( sm->p));
	if ( 93 <= (*( sm->p)) && (*( sm->p)) <= 93 ) {
		_widec = (short)(2688 + ((*( sm->p)) - -128));
		if ( 
#line 89 "ext/dtext/dtext.cpp.rl"
 dstack_is_open(sm, BLOCK_EXPAND)  ) _widec += 256;
	}
	if ( _widec == 3165 )
		goto st1341;
	if ( _widec < 11 ) {
		if ( _widec > -1 ) {
			if ( 1 <= _widec && _widec <= 9 )
				goto st605;
		} else
			goto st605;
	} else if ( _widec > 12 ) {
		if ( _widec > 92 ) {
			if ( 94 <= _widec )
				goto st605;
		} else if ( _widec >= 14 )
			goto st605;
	} else
		goto st605;
	goto tr180;
st634:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof634;
case 634:
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 10: goto tr180;
		case 13: goto tr180;
		case 82: goto st619;
		case 93: goto tr750;
		case 114: goto st619;
	}
	goto st605;
st635:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof635;
case 635:
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 10: goto tr180;
		case 13: goto tr180;
		case 93: goto tr787;
	}
	goto st605;
st636:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof636;
case 636:
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 10: goto tr180;
		case 13: goto tr180;
		case 79: goto st637;
		case 93: goto tr750;
		case 111: goto st637;
	}
	goto st605;
st637:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof637;
case 637:
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 10: goto tr180;
		case 13: goto tr180;
		case 68: goto st638;
		case 93: goto tr750;
		case 100: goto st638;
	}
	goto st605;
st638:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof638;
case 638:
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 10: goto tr180;
		case 13: goto tr180;
		case 84: goto st639;
		case 93: goto tr750;
		case 116: goto st639;
	}
	goto st605;
st639:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof639;
case 639:
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 10: goto tr180;
		case 13: goto tr180;
		case 69: goto st640;
		case 93: goto tr750;
		case 101: goto st640;
	}
	goto st605;
st640:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof640;
case 640:
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 10: goto tr180;
		case 13: goto tr180;
		case 88: goto st641;
		case 93: goto tr750;
		case 120: goto st641;
	}
	goto st605;
st641:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof641;
case 641:
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 10: goto tr180;
		case 13: goto tr180;
		case 84: goto st619;
		case 93: goto tr750;
		case 116: goto st619;
	}
	goto st605;
st642:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof642;
case 642:
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 10: goto tr180;
		case 13: goto tr180;
		case 85: goto st643;
		case 93: goto tr750;
		case 117: goto st643;
	}
	goto st605;
st643:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof643;
case 643:
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 10: goto tr180;
		case 13: goto tr180;
		case 79: goto st644;
		case 93: goto tr750;
		case 111: goto st644;
	}
	goto st605;
st644:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof644;
case 644:
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 10: goto tr180;
		case 13: goto tr180;
		case 84: goto st645;
		case 93: goto tr750;
		case 116: goto st645;
	}
	goto st605;
st645:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof645;
case 645:
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 10: goto tr180;
		case 13: goto tr180;
		case 69: goto st646;
		case 93: goto tr750;
		case 101: goto st646;
	}
	goto st605;
st646:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof646;
case 646:
	_widec = (*( sm->p));
	if ( 93 <= (*( sm->p)) && (*( sm->p)) <= 93 ) {
		_widec = (short)(2176 + ((*( sm->p)) - -128));
		if ( 
#line 88 "ext/dtext/dtext.cpp.rl"
 dstack_is_open(sm, BLOCK_QUOTE)  ) _widec += 256;
	}
	if ( _widec == 2653 )
		goto st1340;
	if ( _widec < 11 ) {
		if ( _widec > -1 ) {
			if ( 1 <= _widec && _widec <= 9 )
				goto st605;
		} else
			goto st605;
	} else if ( _widec > 12 ) {
		if ( _widec > 92 ) {
			if ( 94 <= _widec )
				goto st605;
		} else if ( _widec >= 14 )
			goto st605;
	} else
		goto st605;
	goto tr180;
st647:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof647;
case 647:
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 10: goto tr180;
		case 13: goto tr180;
		case 80: goto st648;
		case 93: goto tr798;
		case 112: goto st648;
	}
	goto st605;
st648:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof648;
case 648:
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 10: goto tr180;
		case 13: goto tr180;
		case 79: goto st649;
		case 93: goto tr750;
		case 111: goto st649;
	}
	goto st605;
st649:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof649;
case 649:
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 10: goto tr180;
		case 13: goto tr180;
		case 73: goto st650;
		case 93: goto tr750;
		case 105: goto st650;
	}
	goto st605;
st650:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof650;
case 650:
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 10: goto tr180;
		case 13: goto tr180;
		case 76: goto st651;
		case 93: goto tr750;
		case 108: goto st651;
	}
	goto st605;
st651:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof651;
case 651:
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 10: goto tr180;
		case 13: goto tr180;
		case 69: goto st652;
		case 93: goto tr750;
		case 101: goto st652;
	}
	goto st605;
st652:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof652;
case 652:
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 10: goto tr180;
		case 13: goto tr180;
		case 82: goto st653;
		case 93: goto tr750;
		case 114: goto st653;
	}
	goto st605;
st653:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof653;
case 653:
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 10: goto tr180;
		case 13: goto tr180;
		case 83: goto st654;
		case 93: goto tr272;
		case 115: goto st654;
	}
	goto st605;
st654:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof654;
case 654:
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 10: goto tr180;
		case 13: goto tr180;
		case 93: goto tr272;
	}
	goto st605;
st655:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof655;
case 655:
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 10: goto tr180;
		case 13: goto tr180;
		case 65: goto st656;
		case 66: goto st658;
		case 68: goto st661;
		case 72: goto st662;
		case 78: goto st665;
		case 82: goto st619;
		case 93: goto tr750;
		case 97: goto st656;
		case 98: goto st658;
		case 100: goto st661;
		case 104: goto st662;
		case 110: goto st665;
		case 114: goto st619;
	}
	goto st605;
st656:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof656;
case 656:
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 10: goto tr180;
		case 13: goto tr180;
		case 66: goto st657;
		case 93: goto tr750;
		case 98: goto st657;
	}
	goto st605;
st657:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof657;
case 657:
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 10: goto tr180;
		case 13: goto tr180;
		case 76: goto st622;
		case 93: goto tr750;
		case 108: goto st622;
	}
	goto st605;
st658:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof658;
case 658:
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 10: goto tr180;
		case 13: goto tr180;
		case 79: goto st659;
		case 93: goto tr750;
		case 111: goto st659;
	}
	goto st605;
st659:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof659;
case 659:
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 10: goto tr180;
		case 13: goto tr180;
		case 68: goto st660;
		case 93: goto tr750;
		case 100: goto st660;
	}
	goto st605;
st660:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof660;
case 660:
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 10: goto tr180;
		case 13: goto tr180;
		case 89: goto st619;
		case 93: goto tr750;
		case 121: goto st619;
	}
	goto st605;
st661:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof661;
case 661:
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 10: goto tr180;
		case 13: goto tr180;
		case 93: goto tr227;
	}
	goto st605;
st662:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof662;
case 662:
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 10: goto tr180;
		case 13: goto tr180;
		case 69: goto st663;
		case 93: goto tr228;
		case 101: goto st663;
	}
	goto st605;
st663:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof663;
case 663:
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 10: goto tr180;
		case 13: goto tr180;
		case 65: goto st664;
		case 93: goto tr750;
		case 97: goto st664;
	}
	goto st605;
st664:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof664;
case 664:
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 10: goto tr180;
		case 13: goto tr180;
		case 68: goto st619;
		case 93: goto tr750;
		case 100: goto st619;
	}
	goto st605;
st665:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof665;
case 665:
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 10: goto tr180;
		case 13: goto tr180;
		case 93: goto tr229;
	}
	goto st605;
st666:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof666;
case 666:
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 10: goto tr180;
		case 13: goto tr180;
		case 82: goto st667;
		case 93: goto tr816;
		case 114: goto st667;
	}
	goto st605;
st667:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof667;
case 667:
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 10: goto tr180;
		case 13: goto tr180;
		case 76: goto st619;
		case 93: goto tr750;
		case 108: goto st619;
	}
	goto st605;
tr2086:
#line 81 "ext/dtext/dtext.cpp.rl"
	{ sm->f1 = sm->p; }
	goto st668;
st668:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof668;
case 668:
#line 17267 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 10: goto tr180;
		case 13: goto tr180;
		case 82: goto st669;
		case 93: goto tr818;
		case 114: goto st669;
	}
	goto st605;
st669:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof669;
case 669:
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 10: goto tr180;
		case 13: goto tr180;
		case 93: goto tr819;
	}
	goto st605;
tr2087:
#line 81 "ext/dtext/dtext.cpp.rl"
	{ sm->f1 = sm->p; }
	goto st670;
st670:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof670;
case 670:
#line 17294 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 10: goto tr180;
		case 13: goto tr180;
		case 79: goto st671;
		case 93: goto tr750;
		case 111: goto st671;
	}
	goto st605;
st671:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof671;
case 671:
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 10: goto tr180;
		case 13: goto tr180;
		case 68: goto st672;
		case 76: goto st623;
		case 93: goto tr750;
		case 100: goto st672;
		case 108: goto st623;
	}
	goto st605;
st672:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof672;
case 672:
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 10: goto tr180;
		case 13: goto tr180;
		case 69: goto st673;
		case 93: goto tr750;
		case 101: goto st673;
	}
	goto st605;
st673:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof673;
case 673:
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 9: goto st674;
		case 10: goto tr180;
		case 13: goto tr180;
		case 32: goto st674;
		case 61: goto st675;
		case 93: goto tr825;
	}
	goto st605;
st674:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof674;
case 674:
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 9: goto st674;
		case 10: goto tr180;
		case 13: goto tr180;
		case 32: goto st674;
		case 61: goto st675;
		case 93: goto tr750;
	}
	goto st605;
st675:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof675;
case 675:
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 9: goto st675;
		case 10: goto tr180;
		case 13: goto tr180;
		case 32: goto st675;
		case 93: goto tr750;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr826;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr826;
	} else
		goto tr826;
	goto st605;
tr826:
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st676;
st676:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof676;
case 676:
#line 17387 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 10: goto tr180;
		case 13: goto tr180;
		case 93: goto tr828;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st676;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st676;
	} else
		goto st676;
	goto st605;
tr828:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 82 "ext/dtext/dtext.cpp.rl"
	{ sm->f2 = sm->p; }
#line 72 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
#line 434 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 74;}
	goto st1587;
st1587:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1587;
case 1587:
#line 17412 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr830;
		case 9: goto st677;
		case 10: goto tr830;
		case 32: goto st677;
		case 40: goto st607;
	}
	goto tr2097;
st677:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof677;
case 677:
	switch( (*( sm->p)) ) {
		case 0: goto tr830;
		case 9: goto st677;
		case 10: goto tr830;
		case 32: goto st677;
	}
	goto tr829;
tr825:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
	goto st1588;
st1588:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1588;
case 1588:
#line 17438 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr833;
		case 9: goto st678;
		case 10: goto tr833;
		case 32: goto st678;
	}
	goto tr2098;
st678:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof678;
case 678:
	switch( (*( sm->p)) ) {
		case 0: goto tr833;
		case 9: goto st678;
		case 10: goto tr833;
		case 32: goto st678;
	}
	goto tr832;
tr2088:
#line 81 "ext/dtext/dtext.cpp.rl"
	{ sm->f1 = sm->p; }
	goto st679;
st679:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof679;
case 679:
#line 17463 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 10: goto tr180;
		case 13: goto tr180;
		case 88: goto st680;
		case 93: goto tr750;
		case 120: goto st680;
	}
	goto st605;
st680:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof680;
case 680:
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 10: goto tr180;
		case 13: goto tr180;
		case 80: goto st681;
		case 93: goto tr750;
		case 112: goto st681;
	}
	goto st605;
st681:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof681;
case 681:
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 10: goto tr180;
		case 13: goto tr180;
		case 65: goto st682;
		case 93: goto tr750;
		case 97: goto st682;
	}
	goto st605;
st682:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof682;
case 682:
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 10: goto tr180;
		case 13: goto tr180;
		case 78: goto st683;
		case 93: goto tr750;
		case 110: goto st683;
	}
	goto st605;
st683:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof683;
case 683:
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 10: goto tr180;
		case 13: goto tr180;
		case 68: goto st684;
		case 93: goto tr750;
		case 100: goto st684;
	}
	goto st605;
st684:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof684;
case 684:
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 9: goto st685;
		case 10: goto tr180;
		case 13: goto tr180;
		case 32: goto st685;
		case 61: goto st687;
		case 93: goto tr842;
	}
	goto st605;
tr844:
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st685;
st685:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof685;
case 685:
#line 17545 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 9: goto tr844;
		case 10: goto tr180;
		case 13: goto tr180;
		case 32: goto tr844;
		case 61: goto tr845;
		case 93: goto tr846;
	}
	goto tr843;
tr843:
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st686;
st686:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof686;
case 686:
#line 17562 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 10: goto tr180;
		case 13: goto tr180;
		case 93: goto tr848;
	}
	goto st686;
tr846:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 82 "ext/dtext/dtext.cpp.rl"
	{ sm->f2 = sm->p; }
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
#line 72 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
#line 499 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 84;}
	goto st1589;
tr848:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 82 "ext/dtext/dtext.cpp.rl"
	{ sm->f2 = sm->p; }
#line 72 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
#line 499 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 84;}
	goto st1589;
st1589:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1589;
case 1589:
#line 17586 "ext/dtext/dtext.cpp"
	if ( (*( sm->p)) == 40 )
		goto st607;
	goto tr2099;
tr845:
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st687;
st687:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof687;
case 687:
#line 17596 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 9: goto tr845;
		case 10: goto tr180;
		case 13: goto tr180;
		case 32: goto tr845;
		case 93: goto tr846;
	}
	goto tr843;
tr2089:
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
#line 81 "ext/dtext/dtext.cpp.rl"
	{ sm->f1 = sm->p; }
	goto st688;
st688:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof688;
case 688:
#line 17613 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 10: goto tr180;
		case 13: goto tr180;
		case 82: goto st619;
		case 84: goto st689;
		case 93: goto tr750;
		case 114: goto st619;
		case 116: goto st689;
	}
	goto st605;
st689:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof689;
case 689:
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 10: goto tr180;
		case 13: goto tr180;
		case 84: goto st690;
		case 93: goto tr750;
		case 116: goto st690;
	}
	goto st605;
st690:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof690;
case 690:
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 10: goto tr180;
		case 13: goto tr180;
		case 80: goto st691;
		case 93: goto tr750;
		case 112: goto st691;
	}
	goto st605;
st691:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof691;
case 691:
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 10: goto tr180;
		case 13: goto tr180;
		case 58: goto st692;
		case 83: goto st724;
		case 93: goto tr750;
		case 115: goto st724;
	}
	goto st605;
st692:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof692;
case 692:
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 10: goto tr180;
		case 13: goto tr180;
		case 47: goto st693;
		case 93: goto tr750;
	}
	goto st605;
st693:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof693;
case 693:
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 10: goto tr180;
		case 13: goto tr180;
		case 47: goto st694;
		case 93: goto tr750;
	}
	goto st605;
st694:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof694;
case 694:
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 10: goto tr180;
		case 13: goto tr180;
		case 32: goto st605;
		case 93: goto tr857;
	}
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 12 )
		goto st605;
	goto st695;
st695:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof695;
case 695:
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 10: goto tr180;
		case 13: goto tr180;
		case 32: goto st605;
		case 93: goto tr858;
	}
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 12 )
		goto st605;
	goto st695;
tr858:
#line 72 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
#line 82 "ext/dtext/dtext.cpp.rl"
	{ sm->f2 = sm->p; }
	goto st696;
st696:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof696;
case 696:
#line 17724 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 32: goto tr180;
		case 40: goto st701;
		case 93: goto tr861;
	}
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr180;
	goto st697;
st697:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof697;
case 697:
	switch( (*( sm->p)) ) {
		case 0: goto tr173;
		case 32: goto tr173;
		case 93: goto tr861;
	}
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr173;
	goto st697;
tr861:
#line 72 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
	goto st698;
st698:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof698;
case 698:
#line 17752 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr173;
		case 32: goto tr173;
		case 40: goto st699;
		case 93: goto tr861;
	}
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr173;
	goto st697;
st699:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof699;
case 699:
	switch( (*( sm->p)) ) {
		case 0: goto tr173;
		case 10: goto tr173;
		case 13: goto tr173;
	}
	goto tr863;
tr863:
#line 73 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st700;
st700:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof700;
case 700:
#line 17778 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr173;
		case 10: goto tr173;
		case 13: goto tr173;
		case 41: goto tr865;
	}
	goto st700;
st701:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof701;
case 701:
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 10: goto tr180;
		case 13: goto tr180;
		case 35: goto tr866;
		case 47: goto tr866;
		case 72: goto tr867;
		case 104: goto tr867;
	}
	goto tr863;
tr885:
#line 73 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st702;
tr866:
#line 73 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
#line 83 "ext/dtext/dtext.cpp.rl"
	{ sm->g1 = sm->p; }
	goto st702;
st702:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof702;
case 702:
#line 17810 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 10: goto tr180;
		case 13: goto tr180;
		case 32: goto st700;
		case 41: goto tr869;
	}
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 12 )
		goto st700;
	goto st702;
tr867:
#line 73 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
#line 83 "ext/dtext/dtext.cpp.rl"
	{ sm->g1 = sm->p; }
	goto st703;
st703:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof703;
case 703:
#line 17828 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 10: goto tr180;
		case 13: goto tr180;
		case 41: goto tr865;
		case 84: goto st704;
		case 116: goto st704;
	}
	goto st700;
st704:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof704;
case 704:
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 10: goto tr180;
		case 13: goto tr180;
		case 41: goto tr865;
		case 84: goto st705;
		case 116: goto st705;
	}
	goto st700;
st705:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof705;
case 705:
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 10: goto tr180;
		case 13: goto tr180;
		case 41: goto tr865;
		case 80: goto st706;
		case 112: goto st706;
	}
	goto st700;
st706:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof706;
case 706:
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 10: goto tr180;
		case 13: goto tr180;
		case 41: goto tr865;
		case 58: goto st707;
		case 83: goto st710;
		case 115: goto st710;
	}
	goto st700;
st707:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof707;
case 707:
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 10: goto tr180;
		case 13: goto tr180;
		case 41: goto tr865;
		case 47: goto st708;
	}
	goto st700;
st708:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof708;
case 708:
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 10: goto tr180;
		case 13: goto tr180;
		case 41: goto tr865;
		case 47: goto st709;
	}
	goto st700;
st709:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof709;
case 709:
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 10: goto tr180;
		case 13: goto tr180;
		case 32: goto st700;
		case 41: goto tr877;
	}
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 12 )
		goto st700;
	goto st702;
tr877:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 74 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
#line 367 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 55;}
	goto st1590;
tr961:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 363 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 54;}
	goto st1590;
st1590:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1590;
case 1590:
#line 17928 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr173;
		case 32: goto tr173;
		case 41: goto tr755;
	}
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr173;
	goto st608;
st710:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof710;
case 710:
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 10: goto tr180;
		case 13: goto tr180;
		case 41: goto tr865;
		case 58: goto st707;
	}
	goto st700;
tr857:
#line 82 "ext/dtext/dtext.cpp.rl"
	{ sm->f2 = sm->p; }
	goto st711;
st711:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof711;
case 711:
#line 17955 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 32: goto tr180;
		case 40: goto st712;
		case 93: goto tr861;
	}
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr180;
	goto st697;
st712:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof712;
case 712:
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 32: goto tr180;
		case 35: goto tr879;
		case 47: goto tr879;
		case 72: goto tr880;
		case 93: goto tr861;
		case 104: goto tr880;
	}
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr180;
	goto st697;
tr879:
#line 83 "ext/dtext/dtext.cpp.rl"
	{ sm->g1 = sm->p; }
	goto st713;
st713:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof713;
case 713:
#line 17987 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 32: goto tr180;
		case 41: goto tr882;
		case 93: goto tr883;
	}
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr180;
	goto st713;
tr882:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 84 "ext/dtext/dtext.cpp.rl"
	{ sm->g2 = sm->p; }
#line 371 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 56;}
	goto st1591;
st1591:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1591;
case 1591:
#line 18005 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr2100;
		case 32: goto tr2100;
		case 93: goto tr861;
	}
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr2100;
	goto st697;
tr883:
#line 72 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
	goto st714;
st714:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof714;
case 714:
#line 18020 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 32: goto tr180;
		case 40: goto st715;
		case 41: goto tr882;
		case 93: goto tr883;
	}
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr180;
	goto st713;
st715:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof715;
case 715:
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 10: goto tr180;
		case 13: goto tr180;
		case 32: goto tr863;
		case 41: goto tr886;
	}
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 12 )
		goto tr863;
	goto tr885;
tr886:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 73 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
#line 84 "ext/dtext/dtext.cpp.rl"
	{ sm->g2 = sm->p; }
#line 371 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 56;}
	goto st1592;
st1592:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1592;
case 1592:
#line 18054 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr2100;
		case 10: goto tr2100;
		case 13: goto tr2100;
		case 41: goto tr865;
	}
	goto st700;
tr880:
#line 83 "ext/dtext/dtext.cpp.rl"
	{ sm->g1 = sm->p; }
	goto st716;
st716:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof716;
case 716:
#line 18068 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 32: goto tr180;
		case 84: goto st717;
		case 93: goto tr861;
		case 116: goto st717;
	}
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr180;
	goto st697;
st717:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof717;
case 717:
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 32: goto tr180;
		case 84: goto st718;
		case 93: goto tr861;
		case 116: goto st718;
	}
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr180;
	goto st697;
st718:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof718;
case 718:
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 32: goto tr180;
		case 80: goto st719;
		case 93: goto tr861;
		case 112: goto st719;
	}
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr180;
	goto st697;
st719:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof719;
case 719:
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 32: goto tr180;
		case 58: goto st720;
		case 83: goto st723;
		case 93: goto tr861;
		case 115: goto st723;
	}
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr180;
	goto st697;
st720:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof720;
case 720:
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 32: goto tr180;
		case 47: goto st721;
		case 93: goto tr861;
	}
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr180;
	goto st697;
st721:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof721;
case 721:
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 32: goto tr180;
		case 47: goto st722;
		case 93: goto tr861;
	}
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr180;
	goto st697;
st722:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof722;
case 722:
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 32: goto tr180;
		case 93: goto tr883;
	}
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr180;
	goto st713;
st723:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof723;
case 723:
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 32: goto tr180;
		case 58: goto st720;
		case 93: goto tr861;
	}
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr180;
	goto st697;
st724:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof724;
case 724:
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 10: goto tr180;
		case 13: goto tr180;
		case 58: goto st692;
		case 93: goto tr750;
	}
	goto st605;
tr2090:
#line 81 "ext/dtext/dtext.cpp.rl"
	{ sm->f1 = sm->p; }
	goto st725;
st725:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof725;
case 725:
#line 18191 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 10: goto tr180;
		case 13: goto tr180;
		case 93: goto tr894;
	}
	goto st605;
tr2091:
#line 81 "ext/dtext/dtext.cpp.rl"
	{ sm->f1 = sm->p; }
	goto st726;
st726:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof726;
case 726:
#line 18205 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 10: goto tr180;
		case 13: goto tr180;
		case 79: goto st727;
		case 93: goto tr750;
		case 111: goto st727;
	}
	goto st605;
st727:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof727;
case 727:
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 10: goto tr180;
		case 13: goto tr180;
		case 68: goto st728;
		case 93: goto tr750;
		case 100: goto st728;
	}
	goto st605;
st728:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof728;
case 728:
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 10: goto tr180;
		case 13: goto tr180;
		case 84: goto st729;
		case 93: goto tr750;
		case 116: goto st729;
	}
	goto st605;
st729:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof729;
case 729:
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 10: goto tr180;
		case 13: goto tr180;
		case 69: goto st730;
		case 93: goto tr750;
		case 101: goto st730;
	}
	goto st605;
st730:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof730;
case 730:
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 10: goto tr180;
		case 13: goto tr180;
		case 88: goto st731;
		case 93: goto tr750;
		case 120: goto st731;
	}
	goto st605;
st731:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof731;
case 731:
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 10: goto tr180;
		case 13: goto tr180;
		case 84: goto st732;
		case 93: goto tr750;
		case 116: goto st732;
	}
	goto st605;
st732:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof732;
case 732:
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 10: goto tr180;
		case 13: goto tr180;
		case 93: goto tr901;
	}
	goto st605;
tr901:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
	goto st1593;
st1593:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1593;
case 1593:
#line 18297 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr903;
		case 9: goto st733;
		case 10: goto tr903;
		case 32: goto st733;
	}
	goto tr2101;
st733:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof733;
case 733:
	switch( (*( sm->p)) ) {
		case 0: goto tr903;
		case 9: goto st733;
		case 10: goto tr903;
		case 32: goto st733;
	}
	goto tr902;
tr2092:
#line 81 "ext/dtext/dtext.cpp.rl"
	{ sm->f1 = sm->p; }
	goto st734;
st734:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof734;
case 734:
#line 18322 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 10: goto tr180;
		case 13: goto tr180;
		case 85: goto st735;
		case 93: goto tr750;
		case 117: goto st735;
	}
	goto st605;
st735:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof735;
case 735:
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 10: goto tr180;
		case 13: goto tr180;
		case 79: goto st736;
		case 93: goto tr750;
		case 111: goto st736;
	}
	goto st605;
st736:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof736;
case 736:
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 10: goto tr180;
		case 13: goto tr180;
		case 84: goto st737;
		case 93: goto tr750;
		case 116: goto st737;
	}
	goto st605;
st737:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof737;
case 737:
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 10: goto tr180;
		case 13: goto tr180;
		case 69: goto st738;
		case 93: goto tr750;
		case 101: goto st738;
	}
	goto st605;
st738:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof738;
case 738:
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 10: goto tr180;
		case 13: goto tr180;
		case 93: goto tr909;
	}
	goto st605;
tr2093:
#line 81 "ext/dtext/dtext.cpp.rl"
	{ sm->f1 = sm->p; }
	goto st739;
st739:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof739;
case 739:
#line 18388 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 10: goto tr180;
		case 13: goto tr180;
		case 80: goto st740;
		case 93: goto tr911;
		case 112: goto st740;
	}
	goto st605;
st740:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof740;
case 740:
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 10: goto tr180;
		case 13: goto tr180;
		case 79: goto st741;
		case 93: goto tr750;
		case 111: goto st741;
	}
	goto st605;
st741:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof741;
case 741:
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 10: goto tr180;
		case 13: goto tr180;
		case 73: goto st742;
		case 93: goto tr750;
		case 105: goto st742;
	}
	goto st605;
st742:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof742;
case 742:
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 10: goto tr180;
		case 13: goto tr180;
		case 76: goto st743;
		case 93: goto tr750;
		case 108: goto st743;
	}
	goto st605;
st743:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof743;
case 743:
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 10: goto tr180;
		case 13: goto tr180;
		case 69: goto st744;
		case 93: goto tr750;
		case 101: goto st744;
	}
	goto st605;
st744:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof744;
case 744:
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 10: goto tr180;
		case 13: goto tr180;
		case 82: goto st745;
		case 93: goto tr750;
		case 114: goto st745;
	}
	goto st605;
st745:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof745;
case 745:
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 10: goto tr180;
		case 13: goto tr180;
		case 83: goto st746;
		case 93: goto tr918;
		case 115: goto st746;
	}
	goto st605;
st746:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof746;
case 746:
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 10: goto tr180;
		case 13: goto tr180;
		case 93: goto tr918;
	}
	goto st605;
tr2094:
#line 81 "ext/dtext/dtext.cpp.rl"
	{ sm->f1 = sm->p; }
	goto st747;
st747:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof747;
case 747:
#line 18493 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 10: goto tr180;
		case 13: goto tr180;
		case 65: goto st656;
		case 66: goto st658;
		case 68: goto st619;
		case 72: goto st748;
		case 78: goto st749;
		case 82: goto st619;
		case 93: goto tr750;
		case 97: goto st656;
		case 98: goto st658;
		case 100: goto st619;
		case 104: goto st748;
		case 110: goto st749;
		case 114: goto st619;
	}
	goto st605;
st748:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof748;
case 748:
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 10: goto tr180;
		case 13: goto tr180;
		case 69: goto st663;
		case 93: goto tr180;
		case 101: goto st663;
	}
	goto st605;
st749:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof749;
case 749:
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 10: goto tr180;
		case 13: goto tr180;
		case 93: goto tr921;
	}
	goto st605;
tr2095:
#line 81 "ext/dtext/dtext.cpp.rl"
	{ sm->f1 = sm->p; }
	goto st750;
st750:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof750;
case 750:
#line 18543 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 10: goto tr180;
		case 13: goto tr180;
		case 82: goto st751;
		case 93: goto tr923;
		case 114: goto st751;
	}
	goto st605;
st751:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof751;
case 751:
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 10: goto tr180;
		case 13: goto tr180;
		case 76: goto st752;
		case 93: goto tr750;
		case 108: goto st752;
	}
	goto st605;
st752:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof752;
case 752:
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 9: goto st753;
		case 10: goto tr180;
		case 13: goto tr180;
		case 32: goto st753;
		case 61: goto st754;
		case 93: goto st849;
	}
	goto st605;
st753:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof753;
case 753:
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 9: goto st753;
		case 10: goto tr180;
		case 13: goto tr180;
		case 32: goto st753;
		case 61: goto st754;
		case 93: goto tr750;
	}
	goto st605;
st754:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof754;
case 754:
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 9: goto st754;
		case 10: goto tr180;
		case 13: goto tr180;
		case 32: goto st754;
		case 34: goto st755;
		case 35: goto tr929;
		case 39: goto st807;
		case 47: goto tr929;
		case 72: goto tr931;
		case 93: goto tr750;
		case 104: goto tr931;
	}
	goto st605;
st755:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof755;
case 755:
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 10: goto tr180;
		case 13: goto tr180;
		case 35: goto tr932;
		case 47: goto tr932;
		case 72: goto tr933;
		case 93: goto tr750;
		case 104: goto tr933;
	}
	goto st605;
tr932:
#line 73 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st756;
st756:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof756;
case 756:
#line 18634 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 10: goto tr180;
		case 13: goto tr180;
		case 32: goto st605;
		case 34: goto tr935;
		case 93: goto tr936;
	}
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 12 )
		goto st605;
	goto st756;
tr935:
#line 74 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
	goto st757;
st757:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof757;
case 757:
#line 18652 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 9: goto st757;
		case 10: goto tr180;
		case 13: goto tr180;
		case 32: goto st757;
		case 93: goto tr938;
	}
	goto st605;
tr938:
#line 82 "ext/dtext/dtext.cpp.rl"
	{ sm->f2 = sm->p; }
	goto st758;
tr997:
#line 74 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
#line 82 "ext/dtext/dtext.cpp.rl"
	{ sm->f2 = sm->p; }
	goto st758;
st758:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof758;
case 758:
#line 18672 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 9: goto tr940;
		case 10: goto tr180;
		case 13: goto tr180;
		case 32: goto tr940;
		case 40: goto tr941;
	}
	goto tr939;
tr939:
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st759;
st759:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof759;
case 759:
#line 18688 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr173;
		case 9: goto tr943;
		case 10: goto tr173;
		case 13: goto tr173;
		case 32: goto tr943;
		case 91: goto tr944;
	}
	goto st759;
tr943:
#line 72 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
	goto st760;
st760:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof760;
case 760:
#line 18704 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto st760;
		case 32: goto st760;
		case 91: goto st761;
	}
	goto tr173;
tr944:
#line 72 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
	goto st761;
st761:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof761;
case 761:
#line 18717 "ext/dtext/dtext.cpp"
	if ( (*( sm->p)) == 47 )
		goto st762;
	goto tr173;
st762:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof762;
case 762:
	switch( (*( sm->p)) ) {
		case 85: goto st763;
		case 117: goto st763;
	}
	goto tr173;
st763:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof763;
case 763:
	switch( (*( sm->p)) ) {
		case 82: goto st764;
		case 114: goto st764;
	}
	goto tr173;
st764:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof764;
case 764:
	switch( (*( sm->p)) ) {
		case 76: goto st765;
		case 108: goto st765;
	}
	goto tr173;
st765:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof765;
case 765:
	if ( (*( sm->p)) == 93 )
		goto tr951;
	goto tr173;
tr940:
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st766;
st766:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof766;
case 766:
#line 18761 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr173;
		case 9: goto tr943;
		case 10: goto tr173;
		case 13: goto tr173;
		case 32: goto tr943;
		case 91: goto tr944;
	}
	goto tr939;
tr941:
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st767;
st767:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof767;
case 767:
#line 18777 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 9: goto tr943;
		case 10: goto tr180;
		case 13: goto tr180;
		case 32: goto tr943;
		case 35: goto tr952;
		case 47: goto tr952;
		case 72: goto tr953;
		case 91: goto tr944;
		case 104: goto tr953;
	}
	goto st759;
tr980:
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st768;
tr952:
#line 83 "ext/dtext/dtext.cpp.rl"
	{ sm->g1 = sm->p; }
	goto st768;
st768:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof768;
case 768:
#line 18800 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 9: goto tr943;
		case 10: goto tr180;
		case 13: goto tr180;
		case 32: goto tr943;
		case 41: goto tr955;
		case 91: goto tr956;
	}
	if ( 11 <= (*( sm->p)) && (*( sm->p)) <= 12 )
		goto st759;
	goto st768;
tr955:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 84 "ext/dtext/dtext.cpp.rl"
	{ sm->g2 = sm->p; }
#line 371 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 56;}
	goto st1594;
tr981:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
#line 84 "ext/dtext/dtext.cpp.rl"
	{ sm->g2 = sm->p; }
#line 371 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 56;}
	goto st1594;
st1594:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1594;
case 1594:
#line 18827 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr2100;
		case 9: goto tr943;
		case 10: goto tr2100;
		case 13: goto tr2100;
		case 32: goto tr943;
		case 91: goto tr944;
	}
	goto st759;
tr956:
#line 72 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
	goto st769;
st769:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof769;
case 769:
#line 18843 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 32: goto tr180;
		case 41: goto tr755;
		case 47: goto st770;
	}
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr180;
	goto st608;
st770:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof770;
case 770:
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 32: goto tr180;
		case 41: goto tr755;
		case 85: goto st771;
		case 117: goto st771;
	}
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr180;
	goto st608;
st771:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof771;
case 771:
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 32: goto tr180;
		case 41: goto tr755;
		case 82: goto st772;
		case 114: goto st772;
	}
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr180;
	goto st608;
st772:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof772;
case 772:
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 32: goto tr180;
		case 41: goto tr755;
		case 76: goto st773;
		case 108: goto st773;
	}
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr180;
	goto st608;
st773:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof773;
case 773:
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 32: goto tr180;
		case 41: goto tr755;
		case 93: goto tr961;
	}
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr180;
	goto st608;
tr953:
#line 83 "ext/dtext/dtext.cpp.rl"
	{ sm->g1 = sm->p; }
	goto st774;
st774:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof774;
case 774:
#line 18914 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 9: goto tr943;
		case 10: goto tr180;
		case 13: goto tr180;
		case 32: goto tr943;
		case 84: goto st775;
		case 91: goto tr944;
		case 116: goto st775;
	}
	goto st759;
st775:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof775;
case 775:
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 9: goto tr943;
		case 10: goto tr180;
		case 13: goto tr180;
		case 32: goto tr943;
		case 84: goto st776;
		case 91: goto tr944;
		case 116: goto st776;
	}
	goto st759;
st776:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof776;
case 776:
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 9: goto tr943;
		case 10: goto tr180;
		case 13: goto tr180;
		case 32: goto tr943;
		case 80: goto st777;
		case 91: goto tr944;
		case 112: goto st777;
	}
	goto st759;
st777:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof777;
case 777:
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 9: goto tr943;
		case 10: goto tr180;
		case 13: goto tr180;
		case 32: goto tr943;
		case 58: goto st778;
		case 83: goto st781;
		case 91: goto tr944;
		case 115: goto st781;
	}
	goto st759;
st778:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof778;
case 778:
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 9: goto tr943;
		case 10: goto tr180;
		case 13: goto tr180;
		case 32: goto tr943;
		case 47: goto st779;
		case 91: goto tr944;
	}
	goto st759;
st779:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof779;
case 779:
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 9: goto tr943;
		case 10: goto tr180;
		case 13: goto tr180;
		case 32: goto tr943;
		case 47: goto st780;
		case 91: goto tr944;
	}
	goto st759;
st780:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof780;
case 780:
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 9: goto tr943;
		case 10: goto tr180;
		case 13: goto tr180;
		case 32: goto tr943;
		case 91: goto tr956;
	}
	if ( 11 <= (*( sm->p)) && (*( sm->p)) <= 12 )
		goto st759;
	goto st768;
st781:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof781;
case 781:
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 9: goto tr943;
		case 10: goto tr180;
		case 13: goto tr180;
		case 32: goto tr943;
		case 58: goto st778;
		case 91: goto tr944;
	}
	goto st759;
tr936:
#line 82 "ext/dtext/dtext.cpp.rl"
	{ sm->f2 = sm->p; }
	goto st782;
st782:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof782;
case 782:
#line 19035 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 32: goto tr180;
		case 34: goto tr970;
		case 40: goto st786;
	}
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr180;
	goto st783;
st783:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof783;
case 783:
	switch( (*( sm->p)) ) {
		case 0: goto tr173;
		case 32: goto tr173;
		case 34: goto tr970;
	}
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr173;
	goto st783;
tr970:
#line 74 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
	goto st784;
st784:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof784;
case 784:
#line 19063 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto st784;
		case 32: goto st784;
		case 93: goto st785;
	}
	goto tr173;
tr1032:
#line 74 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
	goto st785;
st785:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof785;
case 785:
#line 19076 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr173;
		case 9: goto tr940;
		case 10: goto tr173;
		case 13: goto tr173;
		case 32: goto tr940;
	}
	goto tr939;
st786:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof786;
case 786:
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 32: goto tr180;
		case 34: goto tr970;
		case 35: goto tr974;
		case 47: goto tr974;
		case 72: goto tr975;
		case 104: goto tr975;
	}
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr180;
	goto st783;
tr974:
#line 83 "ext/dtext/dtext.cpp.rl"
	{ sm->g1 = sm->p; }
	goto st787;
st787:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof787;
case 787:
#line 19107 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 32: goto tr180;
		case 34: goto tr977;
		case 41: goto tr978;
	}
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr180;
	goto st787;
tr977:
#line 74 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
	goto st788;
st788:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof788;
case 788:
#line 19123 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 9: goto st784;
		case 32: goto st784;
		case 41: goto tr755;
		case 93: goto st789;
	}
	if ( 10 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr180;
	goto st608;
tr1037:
#line 74 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
	goto st789;
st789:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof789;
case 789:
#line 19140 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 9: goto tr940;
		case 10: goto tr180;
		case 13: goto tr180;
		case 32: goto tr940;
		case 41: goto tr981;
	}
	if ( 11 <= (*( sm->p)) && (*( sm->p)) <= 12 )
		goto tr939;
	goto tr980;
tr978:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 84 "ext/dtext/dtext.cpp.rl"
	{ sm->g2 = sm->p; }
#line 371 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 56;}
	goto st1595;
st1595:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1595;
case 1595:
#line 19160 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr2100;
		case 32: goto tr2100;
		case 34: goto tr970;
	}
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr2100;
	goto st783;
tr975:
#line 83 "ext/dtext/dtext.cpp.rl"
	{ sm->g1 = sm->p; }
	goto st790;
st790:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof790;
case 790:
#line 19175 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 32: goto tr180;
		case 34: goto tr970;
		case 84: goto st791;
		case 116: goto st791;
	}
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr180;
	goto st783;
st791:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof791;
case 791:
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 32: goto tr180;
		case 34: goto tr970;
		case 84: goto st792;
		case 116: goto st792;
	}
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr180;
	goto st783;
st792:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof792;
case 792:
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 32: goto tr180;
		case 34: goto tr970;
		case 80: goto st793;
		case 112: goto st793;
	}
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr180;
	goto st783;
st793:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof793;
case 793:
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 32: goto tr180;
		case 34: goto tr970;
		case 58: goto st794;
		case 83: goto st797;
		case 115: goto st797;
	}
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr180;
	goto st783;
st794:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof794;
case 794:
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 32: goto tr180;
		case 34: goto tr970;
		case 47: goto st795;
	}
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr180;
	goto st783;
st795:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof795;
case 795:
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 32: goto tr180;
		case 34: goto tr970;
		case 47: goto st796;
	}
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr180;
	goto st783;
st796:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof796;
case 796:
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 32: goto tr180;
		case 34: goto tr977;
	}
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr180;
	goto st787;
st797:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof797;
case 797:
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 32: goto tr180;
		case 34: goto tr970;
		case 58: goto st794;
	}
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr180;
	goto st783;
tr933:
#line 73 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st798;
st798:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof798;
case 798:
#line 19286 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 10: goto tr180;
		case 13: goto tr180;
		case 84: goto st799;
		case 93: goto tr750;
		case 116: goto st799;
	}
	goto st605;
st799:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof799;
case 799:
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 10: goto tr180;
		case 13: goto tr180;
		case 84: goto st800;
		case 93: goto tr750;
		case 116: goto st800;
	}
	goto st605;
st800:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof800;
case 800:
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 10: goto tr180;
		case 13: goto tr180;
		case 80: goto st801;
		case 93: goto tr750;
		case 112: goto st801;
	}
	goto st605;
st801:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof801;
case 801:
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 10: goto tr180;
		case 13: goto tr180;
		case 58: goto st802;
		case 83: goto st805;
		case 93: goto tr750;
		case 115: goto st805;
	}
	goto st605;
st802:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof802;
case 802:
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 10: goto tr180;
		case 13: goto tr180;
		case 47: goto st803;
		case 93: goto tr750;
	}
	goto st605;
st803:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof803;
case 803:
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 10: goto tr180;
		case 13: goto tr180;
		case 47: goto st804;
		case 93: goto tr750;
	}
	goto st605;
st804:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof804;
case 804:
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 10: goto tr180;
		case 13: goto tr180;
		case 32: goto st605;
		case 93: goto tr936;
	}
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 12 )
		goto st605;
	goto st756;
st805:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof805;
case 805:
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 10: goto tr180;
		case 13: goto tr180;
		case 58: goto st802;
		case 93: goto tr750;
	}
	goto st605;
tr929:
#line 73 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st806;
st806:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof806;
case 806:
#line 19392 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 9: goto tr935;
		case 10: goto tr180;
		case 13: goto tr180;
		case 32: goto tr935;
		case 93: goto tr997;
	}
	if ( 11 <= (*( sm->p)) && (*( sm->p)) <= 12 )
		goto st605;
	goto st806;
st807:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof807;
case 807:
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 10: goto tr180;
		case 13: goto tr180;
		case 35: goto tr998;
		case 47: goto tr998;
		case 72: goto tr999;
		case 93: goto tr750;
		case 104: goto tr999;
	}
	goto st605;
tr998:
#line 73 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st808;
st808:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof808;
case 808:
#line 19425 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 10: goto tr180;
		case 13: goto tr180;
		case 32: goto st605;
		case 39: goto tr935;
		case 93: goto tr1001;
	}
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 12 )
		goto st605;
	goto st808;
tr1001:
#line 82 "ext/dtext/dtext.cpp.rl"
	{ sm->f2 = sm->p; }
	goto st809;
st809:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof809;
case 809:
#line 19443 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 32: goto tr180;
		case 39: goto tr970;
		case 40: goto st811;
	}
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr180;
	goto st810;
st810:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof810;
case 810:
	switch( (*( sm->p)) ) {
		case 0: goto tr173;
		case 32: goto tr173;
		case 39: goto tr970;
	}
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr173;
	goto st810;
st811:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof811;
case 811:
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 32: goto tr180;
		case 35: goto tr1004;
		case 39: goto tr970;
		case 47: goto tr1004;
		case 72: goto tr1005;
		case 104: goto tr1005;
	}
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr180;
	goto st810;
tr1004:
#line 83 "ext/dtext/dtext.cpp.rl"
	{ sm->g1 = sm->p; }
	goto st812;
st812:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof812;
case 812:
#line 19487 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 32: goto tr180;
		case 39: goto tr977;
		case 41: goto tr1007;
	}
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr180;
	goto st812;
tr1007:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 84 "ext/dtext/dtext.cpp.rl"
	{ sm->g2 = sm->p; }
#line 371 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 56;}
	goto st1596;
st1596:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1596;
case 1596:
#line 19505 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr2100;
		case 32: goto tr2100;
		case 39: goto tr970;
	}
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr2100;
	goto st810;
tr1005:
#line 83 "ext/dtext/dtext.cpp.rl"
	{ sm->g1 = sm->p; }
	goto st813;
st813:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof813;
case 813:
#line 19520 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 32: goto tr180;
		case 39: goto tr970;
		case 84: goto st814;
		case 116: goto st814;
	}
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr180;
	goto st810;
st814:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof814;
case 814:
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 32: goto tr180;
		case 39: goto tr970;
		case 84: goto st815;
		case 116: goto st815;
	}
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr180;
	goto st810;
st815:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof815;
case 815:
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 32: goto tr180;
		case 39: goto tr970;
		case 80: goto st816;
		case 112: goto st816;
	}
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr180;
	goto st810;
st816:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof816;
case 816:
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 32: goto tr180;
		case 39: goto tr970;
		case 58: goto st817;
		case 83: goto st820;
		case 115: goto st820;
	}
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr180;
	goto st810;
st817:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof817;
case 817:
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 32: goto tr180;
		case 39: goto tr970;
		case 47: goto st818;
	}
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr180;
	goto st810;
st818:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof818;
case 818:
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 32: goto tr180;
		case 39: goto tr970;
		case 47: goto st819;
	}
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr180;
	goto st810;
st819:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof819;
case 819:
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 32: goto tr180;
		case 39: goto tr977;
	}
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr180;
	goto st812;
st820:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof820;
case 820:
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 32: goto tr180;
		case 39: goto tr970;
		case 58: goto st817;
	}
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr180;
	goto st810;
tr999:
#line 73 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st821;
st821:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof821;
case 821:
#line 19631 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 10: goto tr180;
		case 13: goto tr180;
		case 84: goto st822;
		case 93: goto tr750;
		case 116: goto st822;
	}
	goto st605;
st822:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof822;
case 822:
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 10: goto tr180;
		case 13: goto tr180;
		case 84: goto st823;
		case 93: goto tr750;
		case 116: goto st823;
	}
	goto st605;
st823:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof823;
case 823:
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 10: goto tr180;
		case 13: goto tr180;
		case 80: goto st824;
		case 93: goto tr750;
		case 112: goto st824;
	}
	goto st605;
st824:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof824;
case 824:
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 10: goto tr180;
		case 13: goto tr180;
		case 58: goto st825;
		case 83: goto st828;
		case 93: goto tr750;
		case 115: goto st828;
	}
	goto st605;
st825:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof825;
case 825:
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 10: goto tr180;
		case 13: goto tr180;
		case 47: goto st826;
		case 93: goto tr750;
	}
	goto st605;
st826:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof826;
case 826:
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 10: goto tr180;
		case 13: goto tr180;
		case 47: goto st827;
		case 93: goto tr750;
	}
	goto st605;
st827:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof827;
case 827:
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 10: goto tr180;
		case 13: goto tr180;
		case 32: goto st605;
		case 93: goto tr1001;
	}
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 12 )
		goto st605;
	goto st808;
st828:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof828;
case 828:
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 10: goto tr180;
		case 13: goto tr180;
		case 58: goto st825;
		case 93: goto tr750;
	}
	goto st605;
tr931:
#line 73 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st829;
st829:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof829;
case 829:
#line 19737 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 10: goto tr180;
		case 13: goto tr180;
		case 84: goto st830;
		case 93: goto tr750;
		case 116: goto st830;
	}
	goto st605;
st830:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof830;
case 830:
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 10: goto tr180;
		case 13: goto tr180;
		case 84: goto st831;
		case 93: goto tr750;
		case 116: goto st831;
	}
	goto st605;
st831:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof831;
case 831:
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 10: goto tr180;
		case 13: goto tr180;
		case 80: goto st832;
		case 93: goto tr750;
		case 112: goto st832;
	}
	goto st605;
st832:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof832;
case 832:
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 10: goto tr180;
		case 13: goto tr180;
		case 58: goto st833;
		case 83: goto st848;
		case 93: goto tr750;
		case 115: goto st848;
	}
	goto st605;
st833:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof833;
case 833:
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 10: goto tr180;
		case 13: goto tr180;
		case 47: goto st834;
		case 93: goto tr750;
	}
	goto st605;
st834:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof834;
case 834:
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 10: goto tr180;
		case 13: goto tr180;
		case 47: goto st835;
		case 93: goto tr750;
	}
	goto st605;
st835:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof835;
case 835:
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 10: goto tr180;
		case 13: goto tr180;
		case 32: goto st605;
		case 93: goto tr1029;
	}
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 12 )
		goto st605;
	goto st806;
tr1029:
#line 82 "ext/dtext/dtext.cpp.rl"
	{ sm->f2 = sm->p; }
	goto st836;
st836:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof836;
case 836:
#line 19831 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 9: goto tr970;
		case 32: goto tr970;
		case 40: goto st838;
		case 93: goto tr1032;
	}
	if ( 10 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr180;
	goto st837;
st837:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof837;
case 837:
	switch( (*( sm->p)) ) {
		case 0: goto tr173;
		case 9: goto tr970;
		case 32: goto tr970;
		case 93: goto tr1032;
	}
	if ( 10 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr173;
	goto st837;
st838:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof838;
case 838:
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 9: goto tr970;
		case 32: goto tr970;
		case 35: goto tr1033;
		case 47: goto tr1033;
		case 72: goto tr1034;
		case 93: goto tr1032;
		case 104: goto tr1034;
	}
	if ( 10 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr180;
	goto st837;
tr1033:
#line 83 "ext/dtext/dtext.cpp.rl"
	{ sm->g1 = sm->p; }
	goto st839;
st839:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof839;
case 839:
#line 19878 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 9: goto tr970;
		case 32: goto tr970;
		case 41: goto tr1036;
		case 93: goto tr1037;
	}
	if ( 10 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr180;
	goto st839;
tr1036:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 84 "ext/dtext/dtext.cpp.rl"
	{ sm->g2 = sm->p; }
#line 371 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 56;}
	goto st1597;
st1597:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1597;
case 1597:
#line 19897 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr2100;
		case 9: goto tr970;
		case 32: goto tr970;
		case 93: goto tr1032;
	}
	if ( 10 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr2100;
	goto st837;
tr1034:
#line 83 "ext/dtext/dtext.cpp.rl"
	{ sm->g1 = sm->p; }
	goto st840;
st840:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof840;
case 840:
#line 19913 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 9: goto tr970;
		case 32: goto tr970;
		case 84: goto st841;
		case 93: goto tr1032;
		case 116: goto st841;
	}
	if ( 10 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr180;
	goto st837;
st841:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof841;
case 841:
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 9: goto tr970;
		case 32: goto tr970;
		case 84: goto st842;
		case 93: goto tr1032;
		case 116: goto st842;
	}
	if ( 10 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr180;
	goto st837;
st842:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof842;
case 842:
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 9: goto tr970;
		case 32: goto tr970;
		case 80: goto st843;
		case 93: goto tr1032;
		case 112: goto st843;
	}
	if ( 10 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr180;
	goto st837;
st843:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof843;
case 843:
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 9: goto tr970;
		case 32: goto tr970;
		case 58: goto st844;
		case 83: goto st847;
		case 93: goto tr1032;
		case 115: goto st847;
	}
	if ( 10 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr180;
	goto st837;
st844:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof844;
case 844:
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 9: goto tr970;
		case 32: goto tr970;
		case 47: goto st845;
		case 93: goto tr1032;
	}
	if ( 10 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr180;
	goto st837;
st845:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof845;
case 845:
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 9: goto tr970;
		case 32: goto tr970;
		case 47: goto st846;
		case 93: goto tr1032;
	}
	if ( 10 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr180;
	goto st837;
st846:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof846;
case 846:
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 9: goto tr970;
		case 32: goto tr970;
		case 93: goto tr1037;
	}
	if ( 10 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr180;
	goto st839;
st847:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof847;
case 847:
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 9: goto tr970;
		case 32: goto tr970;
		case 58: goto st844;
		case 93: goto tr1032;
	}
	if ( 10 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr180;
	goto st837;
st848:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof848;
case 848:
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 10: goto tr180;
		case 13: goto tr180;
		case 58: goto st833;
		case 93: goto tr750;
	}
	goto st605;
st849:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof849;
case 849:
	switch( (*( sm->p)) ) {
		case 9: goto st849;
		case 32: goto st849;
		case 35: goto tr1045;
		case 47: goto tr1045;
		case 72: goto tr1046;
		case 104: goto tr1046;
	}
	goto tr180;
tr1045:
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st850;
st850:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof850;
case 850:
#line 20057 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 9: goto tr1048;
		case 32: goto tr1048;
		case 91: goto tr1049;
	}
	if ( 10 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr180;
	goto st850;
tr1048:
#line 72 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
	goto st851;
st851:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof851;
case 851:
#line 20073 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto st851;
		case 32: goto st851;
		case 91: goto st852;
	}
	goto tr180;
st852:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof852;
case 852:
	if ( (*( sm->p)) == 47 )
		goto st853;
	goto tr180;
st853:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof853;
case 853:
	switch( (*( sm->p)) ) {
		case 85: goto st854;
		case 117: goto st854;
	}
	goto tr180;
st854:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof854;
case 854:
	switch( (*( sm->p)) ) {
		case 82: goto st855;
		case 114: goto st855;
	}
	goto tr180;
st855:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof855;
case 855:
	switch( (*( sm->p)) ) {
		case 76: goto st856;
		case 108: goto st856;
	}
	goto tr180;
st856:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof856;
case 856:
	if ( (*( sm->p)) == 93 )
		goto tr1056;
	goto tr180;
tr1049:
#line 72 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
	goto st857;
st857:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof857;
case 857:
#line 20127 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 9: goto tr1048;
		case 32: goto tr1048;
		case 47: goto st858;
		case 91: goto tr1049;
	}
	if ( 10 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr180;
	goto st850;
st858:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof858;
case 858:
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 9: goto tr1048;
		case 32: goto tr1048;
		case 85: goto st859;
		case 91: goto tr1049;
		case 117: goto st859;
	}
	if ( 10 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr180;
	goto st850;
st859:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof859;
case 859:
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 9: goto tr1048;
		case 32: goto tr1048;
		case 82: goto st860;
		case 91: goto tr1049;
		case 114: goto st860;
	}
	if ( 10 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr180;
	goto st850;
st860:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof860;
case 860:
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 9: goto tr1048;
		case 32: goto tr1048;
		case 76: goto st861;
		case 91: goto tr1049;
		case 108: goto st861;
	}
	if ( 10 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr180;
	goto st850;
st861:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof861;
case 861:
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 9: goto tr1048;
		case 32: goto tr1048;
		case 91: goto tr1049;
		case 93: goto tr1056;
	}
	if ( 10 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr180;
	goto st850;
tr1046:
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st862;
st862:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof862;
case 862:
#line 20203 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 84: goto st863;
		case 116: goto st863;
	}
	goto tr180;
st863:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof863;
case 863:
	switch( (*( sm->p)) ) {
		case 84: goto st864;
		case 116: goto st864;
	}
	goto tr180;
st864:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof864;
case 864:
	switch( (*( sm->p)) ) {
		case 80: goto st865;
		case 112: goto st865;
	}
	goto tr180;
st865:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof865;
case 865:
	switch( (*( sm->p)) ) {
		case 58: goto st866;
		case 83: goto st869;
		case 115: goto st869;
	}
	goto tr180;
st866:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof866;
case 866:
	if ( (*( sm->p)) == 47 )
		goto st867;
	goto tr180;
st867:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof867;
case 867:
	if ( (*( sm->p)) == 47 )
		goto st868;
	goto tr180;
st868:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof868;
case 868:
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 32: goto tr180;
	}
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr180;
	goto st850;
st869:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof869;
case 869:
	if ( (*( sm->p)) == 58 )
		goto st866;
	goto tr180;
tr1069:
#line 73 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st870;
tr2096:
#line 81 "ext/dtext/dtext.cpp.rl"
	{ sm->f1 = sm->p; }
	goto st870;
st870:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof870;
case 870:
#line 20278 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr425;
		case 9: goto tr1069;
		case 10: goto tr427;
		case 13: goto tr427;
		case 32: goto tr1069;
		case 58: goto tr1071;
		case 60: goto tr1072;
		case 62: goto tr1073;
		case 92: goto tr1074;
		case 93: goto tr750;
		case 124: goto tr1075;
	}
	if ( 11 <= (*( sm->p)) && (*( sm->p)) <= 12 )
		goto tr1070;
	goto tr1068;
tr1068:
#line 73 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st871;
st871:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof871;
case 871:
#line 20301 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto st364;
		case 9: goto tr1077;
		case 10: goto st366;
		case 13: goto st366;
		case 32: goto tr1077;
		case 35: goto tr1079;
		case 93: goto tr1080;
		case 124: goto tr1081;
	}
	if ( 11 <= (*( sm->p)) && (*( sm->p)) <= 12 )
		goto st873;
	goto st871;
tr1077:
#line 74 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
	goto st872;
st872:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof872;
case 872:
#line 20321 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto st364;
		case 9: goto st872;
		case 10: goto st366;
		case 13: goto st366;
		case 32: goto st872;
		case 35: goto st874;
		case 93: goto tr1084;
		case 124: goto st878;
	}
	if ( 11 <= (*( sm->p)) && (*( sm->p)) <= 12 )
		goto st873;
	goto st871;
tr1070:
#line 73 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st873;
st873:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof873;
case 873:
#line 20341 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto st364;
		case 10: goto st366;
		case 13: goto st366;
		case 32: goto st873;
		case 93: goto tr750;
		case 124: goto st605;
	}
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 12 )
		goto st873;
	goto st871;
tr1079:
#line 74 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
	goto st874;
st874:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof874;
case 874:
#line 20359 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto st364;
		case 9: goto tr1077;
		case 10: goto st366;
		case 13: goto st366;
		case 32: goto tr1077;
		case 35: goto tr1079;
		case 93: goto tr1080;
		case 124: goto tr1081;
	}
	if ( (*( sm->p)) > 12 ) {
		if ( 65 <= (*( sm->p)) && (*( sm->p)) <= 90 )
			goto tr1086;
	} else if ( (*( sm->p)) >= 11 )
		goto st873;
	goto st871;
tr1086:
#line 75 "ext/dtext/dtext.cpp.rl"
	{ sm->c1 = sm->p; }
	goto st875;
st875:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof875;
case 875:
#line 20382 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 9: goto tr1087;
		case 10: goto tr180;
		case 13: goto tr180;
		case 32: goto tr1088;
		case 45: goto st883;
		case 93: goto tr1091;
		case 95: goto st883;
		case 124: goto tr1092;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st875;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st875;
	} else
		goto st875;
	goto st605;
tr1087:
#line 76 "ext/dtext/dtext.cpp.rl"
	{ sm->c2 = sm->p; }
	goto st876;
st876:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof876;
case 876:
#line 20409 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 9: goto st876;
		case 10: goto tr180;
		case 13: goto tr180;
		case 32: goto st876;
		case 93: goto tr1084;
		case 124: goto st878;
	}
	goto st605;
tr1084:
#line 82 "ext/dtext/dtext.cpp.rl"
	{ sm->f2 = sm->p; }
	goto st877;
tr1080:
#line 74 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
#line 82 "ext/dtext/dtext.cpp.rl"
	{ sm->f2 = sm->p; }
	goto st877;
tr1091:
#line 76 "ext/dtext/dtext.cpp.rl"
	{ sm->c2 = sm->p; }
#line 82 "ext/dtext/dtext.cpp.rl"
	{ sm->f2 = sm->p; }
	goto st877;
st877:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof877;
case 877:
#line 20434 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 40: goto st607;
		case 93: goto st1350;
	}
	goto tr180;
tr1081:
#line 74 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
	goto st878;
tr1092:
#line 76 "ext/dtext/dtext.cpp.rl"
	{ sm->c2 = sm->p; }
	goto st878;
tr1095:
#line 77 "ext/dtext/dtext.cpp.rl"
	{ sm->d1 = sm->p; }
#line 78 "ext/dtext/dtext.cpp.rl"
	{ sm->d2 = sm->p; }
	goto st878;
st878:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof878;
case 878:
#line 20453 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr452;
		case 9: goto tr1095;
		case 10: goto tr180;
		case 13: goto tr180;
		case 32: goto tr1095;
		case 93: goto tr1096;
		case 124: goto st605;
	}
	if ( 11 <= (*( sm->p)) && (*( sm->p)) <= 12 )
		goto st605;
	goto tr1094;
tr1094:
#line 77 "ext/dtext/dtext.cpp.rl"
	{ sm->d1 = sm->p; }
	goto st879;
st879:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof879;
case 879:
#line 20472 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto st372;
		case 9: goto tr1098;
		case 10: goto tr180;
		case 13: goto tr180;
		case 32: goto tr1098;
		case 93: goto tr1099;
		case 124: goto st605;
	}
	if ( 11 <= (*( sm->p)) && (*( sm->p)) <= 12 )
		goto st605;
	goto st879;
tr1098:
#line 78 "ext/dtext/dtext.cpp.rl"
	{ sm->d2 = sm->p; }
	goto st880;
st880:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof880;
case 880:
#line 20491 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto st372;
		case 9: goto st880;
		case 10: goto tr180;
		case 13: goto tr180;
		case 32: goto st880;
		case 93: goto tr1101;
		case 124: goto st605;
	}
	if ( 11 <= (*( sm->p)) && (*( sm->p)) <= 12 )
		goto st605;
	goto st879;
tr1101:
#line 82 "ext/dtext/dtext.cpp.rl"
	{ sm->f2 = sm->p; }
	goto st881;
tr1096:
#line 77 "ext/dtext/dtext.cpp.rl"
	{ sm->d1 = sm->p; }
#line 78 "ext/dtext/dtext.cpp.rl"
	{ sm->d2 = sm->p; }
#line 82 "ext/dtext/dtext.cpp.rl"
	{ sm->f2 = sm->p; }
	goto st881;
tr1099:
#line 78 "ext/dtext/dtext.cpp.rl"
	{ sm->d2 = sm->p; }
#line 82 "ext/dtext/dtext.cpp.rl"
	{ sm->f2 = sm->p; }
	goto st881;
st881:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof881;
case 881:
#line 20519 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 40: goto st607;
		case 93: goto st1352;
	}
	goto tr180;
tr1088:
#line 76 "ext/dtext/dtext.cpp.rl"
	{ sm->c2 = sm->p; }
	goto st882;
st882:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof882;
case 882:
#line 20531 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 9: goto st876;
		case 10: goto tr180;
		case 13: goto tr180;
		case 32: goto st882;
		case 45: goto st883;
		case 93: goto tr1084;
		case 95: goto st883;
		case 124: goto st878;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st875;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st875;
	} else
		goto st875;
	goto st605;
st883:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof883;
case 883:
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 10: goto tr180;
		case 13: goto tr180;
		case 32: goto st883;
		case 45: goto st883;
		case 93: goto tr750;
		case 95: goto st883;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st875;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st875;
	} else
		goto st875;
	goto st605;
tr1071:
#line 73 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st884;
st884:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof884;
case 884:
#line 20580 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto st364;
		case 9: goto tr1077;
		case 10: goto st366;
		case 13: goto st366;
		case 32: goto tr1077;
		case 35: goto tr1079;
		case 93: goto tr1080;
		case 124: goto tr1103;
	}
	if ( 11 <= (*( sm->p)) && (*( sm->p)) <= 12 )
		goto st873;
	goto st871;
tr1103:
#line 74 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
	goto st885;
st885:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof885;
case 885:
#line 20600 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr452;
		case 9: goto tr1104;
		case 10: goto tr180;
		case 13: goto tr180;
		case 32: goto tr1104;
		case 35: goto tr1105;
		case 93: goto tr1106;
		case 124: goto st605;
	}
	if ( 11 <= (*( sm->p)) && (*( sm->p)) <= 12 )
		goto st605;
	goto tr1094;
tr1107:
#line 77 "ext/dtext/dtext.cpp.rl"
	{ sm->d1 = sm->p; }
#line 78 "ext/dtext/dtext.cpp.rl"
	{ sm->d2 = sm->p; }
	goto st886;
tr1104:
#line 74 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
#line 77 "ext/dtext/dtext.cpp.rl"
	{ sm->d1 = sm->p; }
#line 78 "ext/dtext/dtext.cpp.rl"
	{ sm->d2 = sm->p; }
	goto st886;
st886:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof886;
case 886:
#line 20626 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr452;
		case 9: goto tr1107;
		case 10: goto tr180;
		case 13: goto tr180;
		case 32: goto tr1107;
		case 35: goto tr1108;
		case 93: goto tr1109;
		case 124: goto st605;
	}
	if ( 11 <= (*( sm->p)) && (*( sm->p)) <= 12 )
		goto st605;
	goto tr1094;
tr1142:
#line 74 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
	goto st887;
tr1108:
#line 77 "ext/dtext/dtext.cpp.rl"
	{ sm->d1 = sm->p; }
	goto st887;
tr1105:
#line 74 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
#line 77 "ext/dtext/dtext.cpp.rl"
	{ sm->d1 = sm->p; }
	goto st887;
st887:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof887;
case 887:
#line 20653 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto st372;
		case 9: goto tr1098;
		case 10: goto tr180;
		case 13: goto tr180;
		case 32: goto tr1098;
		case 93: goto tr1099;
		case 124: goto st605;
	}
	if ( (*( sm->p)) > 12 ) {
		if ( 65 <= (*( sm->p)) && (*( sm->p)) <= 90 )
			goto tr1110;
	} else if ( (*( sm->p)) >= 11 )
		goto st605;
	goto st879;
tr1110:
#line 75 "ext/dtext/dtext.cpp.rl"
	{ sm->c1 = sm->p; }
	goto st888;
st888:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof888;
case 888:
#line 20675 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto st372;
		case 9: goto tr1111;
		case 10: goto tr180;
		case 13: goto tr180;
		case 32: goto tr1112;
		case 45: goto st892;
		case 93: goto tr1115;
		case 95: goto st892;
		case 124: goto st605;
	}
	if ( (*( sm->p)) < 48 ) {
		if ( 11 <= (*( sm->p)) && (*( sm->p)) <= 12 )
			goto st605;
	} else if ( (*( sm->p)) > 57 ) {
		if ( (*( sm->p)) > 90 ) {
			if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
				goto st888;
		} else if ( (*( sm->p)) >= 65 )
			goto st888;
	} else
		goto st888;
	goto st879;
tr1111:
#line 76 "ext/dtext/dtext.cpp.rl"
	{ sm->c2 = sm->p; }
#line 78 "ext/dtext/dtext.cpp.rl"
	{ sm->d2 = sm->p; }
	goto st889;
st889:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof889;
case 889:
#line 20706 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto st372;
		case 9: goto st889;
		case 10: goto tr180;
		case 13: goto tr180;
		case 32: goto st889;
		case 93: goto tr1117;
		case 124: goto st605;
	}
	if ( 11 <= (*( sm->p)) && (*( sm->p)) <= 12 )
		goto st605;
	goto st879;
tr1117:
#line 82 "ext/dtext/dtext.cpp.rl"
	{ sm->f2 = sm->p; }
	goto st890;
tr1109:
#line 77 "ext/dtext/dtext.cpp.rl"
	{ sm->d1 = sm->p; }
#line 78 "ext/dtext/dtext.cpp.rl"
	{ sm->d2 = sm->p; }
#line 82 "ext/dtext/dtext.cpp.rl"
	{ sm->f2 = sm->p; }
	goto st890;
tr1106:
#line 74 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
#line 77 "ext/dtext/dtext.cpp.rl"
	{ sm->d1 = sm->p; }
#line 78 "ext/dtext/dtext.cpp.rl"
	{ sm->d2 = sm->p; }
#line 82 "ext/dtext/dtext.cpp.rl"
	{ sm->f2 = sm->p; }
	goto st890;
tr1115:
#line 76 "ext/dtext/dtext.cpp.rl"
	{ sm->c2 = sm->p; }
#line 78 "ext/dtext/dtext.cpp.rl"
	{ sm->d2 = sm->p; }
#line 82 "ext/dtext/dtext.cpp.rl"
	{ sm->f2 = sm->p; }
	goto st890;
tr1143:
#line 74 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
#line 78 "ext/dtext/dtext.cpp.rl"
	{ sm->d2 = sm->p; }
#line 82 "ext/dtext/dtext.cpp.rl"
	{ sm->f2 = sm->p; }
	goto st890;
st890:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof890;
case 890:
#line 20746 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 40: goto st607;
		case 93: goto st1354;
	}
	goto tr180;
tr1112:
#line 76 "ext/dtext/dtext.cpp.rl"
	{ sm->c2 = sm->p; }
#line 78 "ext/dtext/dtext.cpp.rl"
	{ sm->d2 = sm->p; }
	goto st891;
st891:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof891;
case 891:
#line 20759 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto st372;
		case 9: goto st889;
		case 10: goto tr180;
		case 13: goto tr180;
		case 32: goto st891;
		case 45: goto st892;
		case 93: goto tr1117;
		case 95: goto st892;
		case 124: goto st605;
	}
	if ( (*( sm->p)) < 48 ) {
		if ( 11 <= (*( sm->p)) && (*( sm->p)) <= 12 )
			goto st605;
	} else if ( (*( sm->p)) > 57 ) {
		if ( (*( sm->p)) > 90 ) {
			if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
				goto st888;
		} else if ( (*( sm->p)) >= 65 )
			goto st888;
	} else
		goto st888;
	goto st879;
st892:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof892;
case 892:
	switch( (*( sm->p)) ) {
		case 0: goto st372;
		case 9: goto tr1098;
		case 10: goto tr180;
		case 13: goto tr180;
		case 32: goto tr1119;
		case 45: goto st892;
		case 93: goto tr1099;
		case 95: goto st892;
		case 124: goto st605;
	}
	if ( (*( sm->p)) < 48 ) {
		if ( 11 <= (*( sm->p)) && (*( sm->p)) <= 12 )
			goto st605;
	} else if ( (*( sm->p)) > 57 ) {
		if ( (*( sm->p)) > 90 ) {
			if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
				goto st888;
		} else if ( (*( sm->p)) >= 65 )
			goto st888;
	} else
		goto st888;
	goto st879;
tr1119:
#line 78 "ext/dtext/dtext.cpp.rl"
	{ sm->d2 = sm->p; }
	goto st893;
st893:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof893;
case 893:
#line 20816 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto st372;
		case 9: goto st880;
		case 10: goto tr180;
		case 13: goto tr180;
		case 32: goto st893;
		case 45: goto st892;
		case 93: goto tr1101;
		case 95: goto st892;
		case 124: goto st605;
	}
	if ( (*( sm->p)) < 48 ) {
		if ( 11 <= (*( sm->p)) && (*( sm->p)) <= 12 )
			goto st605;
	} else if ( (*( sm->p)) > 57 ) {
		if ( (*( sm->p)) > 90 ) {
			if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
				goto st888;
		} else if ( (*( sm->p)) >= 65 )
			goto st888;
	} else
		goto st888;
	goto st879;
tr1072:
#line 73 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st894;
st894:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof894;
case 894:
#line 20846 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto st364;
		case 9: goto tr1077;
		case 10: goto st366;
		case 13: goto st366;
		case 32: goto tr1077;
		case 35: goto tr1079;
		case 93: goto tr1080;
		case 124: goto tr1121;
	}
	if ( 11 <= (*( sm->p)) && (*( sm->p)) <= 12 )
		goto st873;
	goto st871;
tr1121:
#line 74 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
	goto st895;
st895:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof895;
case 895:
#line 20866 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr452;
		case 9: goto tr1095;
		case 10: goto tr180;
		case 13: goto tr180;
		case 32: goto tr1095;
		case 62: goto tr1122;
		case 93: goto tr1096;
		case 124: goto st605;
	}
	if ( 11 <= (*( sm->p)) && (*( sm->p)) <= 12 )
		goto st605;
	goto tr1094;
tr1122:
#line 77 "ext/dtext/dtext.cpp.rl"
	{ sm->d1 = sm->p; }
	goto st896;
st896:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof896;
case 896:
#line 20886 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto st372;
		case 9: goto tr1098;
		case 10: goto tr180;
		case 13: goto tr180;
		case 32: goto tr1098;
		case 93: goto tr1099;
		case 95: goto st897;
		case 124: goto st605;
	}
	if ( 11 <= (*( sm->p)) && (*( sm->p)) <= 12 )
		goto st605;
	goto st879;
st897:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof897;
case 897:
	switch( (*( sm->p)) ) {
		case 0: goto st372;
		case 9: goto tr1098;
		case 10: goto tr180;
		case 13: goto tr180;
		case 32: goto tr1098;
		case 60: goto st898;
		case 93: goto tr1099;
		case 124: goto st605;
	}
	if ( 11 <= (*( sm->p)) && (*( sm->p)) <= 12 )
		goto st605;
	goto st879;
st898:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof898;
case 898:
	switch( (*( sm->p)) ) {
		case 0: goto st372;
		case 9: goto tr1098;
		case 10: goto tr180;
		case 13: goto tr180;
		case 32: goto tr1098;
		case 93: goto tr1099;
		case 124: goto st899;
	}
	if ( 11 <= (*( sm->p)) && (*( sm->p)) <= 12 )
		goto st605;
	goto st879;
st899:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof899;
case 899:
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 10: goto tr180;
		case 13: goto tr180;
		case 62: goto st900;
		case 93: goto tr750;
	}
	goto st605;
st900:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof900;
case 900:
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 9: goto tr1127;
		case 10: goto tr180;
		case 13: goto tr180;
		case 32: goto tr1127;
		case 35: goto tr1128;
		case 93: goto tr1080;
	}
	goto st605;
tr1127:
#line 74 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
	goto st901;
st901:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof901;
case 901:
#line 20965 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 9: goto st901;
		case 10: goto tr180;
		case 13: goto tr180;
		case 32: goto st901;
		case 35: goto st902;
		case 93: goto tr1084;
	}
	goto st605;
tr1128:
#line 74 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
	goto st902;
st902:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof902;
case 902:
#line 20982 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 10: goto tr180;
		case 13: goto tr180;
		case 93: goto tr750;
	}
	if ( 65 <= (*( sm->p)) && (*( sm->p)) <= 90 )
		goto tr1131;
	goto st605;
tr1131:
#line 75 "ext/dtext/dtext.cpp.rl"
	{ sm->c1 = sm->p; }
	goto st903;
st903:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof903;
case 903:
#line 20998 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 9: goto tr1132;
		case 10: goto tr180;
		case 13: goto tr180;
		case 32: goto tr1133;
		case 45: goto st906;
		case 93: goto tr1091;
		case 95: goto st906;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st903;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st903;
	} else
		goto st903;
	goto st605;
tr1132:
#line 76 "ext/dtext/dtext.cpp.rl"
	{ sm->c2 = sm->p; }
	goto st904;
st904:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof904;
case 904:
#line 21024 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 9: goto st904;
		case 10: goto tr180;
		case 13: goto tr180;
		case 32: goto st904;
		case 93: goto tr1084;
	}
	goto st605;
tr1133:
#line 76 "ext/dtext/dtext.cpp.rl"
	{ sm->c2 = sm->p; }
	goto st905;
st905:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof905;
case 905:
#line 21040 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 9: goto st904;
		case 10: goto tr180;
		case 13: goto tr180;
		case 32: goto st905;
		case 45: goto st906;
		case 93: goto tr1084;
		case 95: goto st906;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st903;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st903;
	} else
		goto st903;
	goto st605;
st906:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof906;
case 906:
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 10: goto tr180;
		case 13: goto tr180;
		case 32: goto st906;
		case 45: goto st906;
		case 93: goto tr750;
		case 95: goto st906;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st903;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st903;
	} else
		goto st903;
	goto st605;
tr1073:
#line 73 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st907;
st907:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof907;
case 907:
#line 21088 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto st364;
		case 9: goto tr1077;
		case 10: goto st366;
		case 13: goto st366;
		case 32: goto tr1077;
		case 35: goto tr1079;
		case 58: goto st884;
		case 93: goto tr1080;
		case 124: goto tr1139;
	}
	if ( 11 <= (*( sm->p)) && (*( sm->p)) <= 12 )
		goto st873;
	goto st871;
tr1139:
#line 74 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
	goto st908;
st908:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof908;
case 908:
#line 21109 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr452;
		case 9: goto tr1095;
		case 10: goto tr180;
		case 13: goto tr180;
		case 32: goto tr1095;
		case 51: goto tr1140;
		case 93: goto tr1096;
		case 124: goto st605;
	}
	if ( 11 <= (*( sm->p)) && (*( sm->p)) <= 12 )
		goto st605;
	goto tr1094;
tr1140:
#line 77 "ext/dtext/dtext.cpp.rl"
	{ sm->d1 = sm->p; }
	goto st909;
st909:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof909;
case 909:
#line 21129 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto st372;
		case 9: goto tr1141;
		case 10: goto tr180;
		case 13: goto tr180;
		case 32: goto tr1141;
		case 35: goto tr1142;
		case 93: goto tr1143;
		case 124: goto st605;
	}
	if ( 11 <= (*( sm->p)) && (*( sm->p)) <= 12 )
		goto st605;
	goto st879;
tr1141:
#line 74 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
#line 78 "ext/dtext/dtext.cpp.rl"
	{ sm->d2 = sm->p; }
	goto st910;
st910:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof910;
case 910:
#line 21150 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto st372;
		case 9: goto st910;
		case 10: goto tr180;
		case 13: goto tr180;
		case 32: goto st910;
		case 35: goto st887;
		case 93: goto tr1117;
		case 124: goto st605;
	}
	if ( 11 <= (*( sm->p)) && (*( sm->p)) <= 12 )
		goto st605;
	goto st879;
tr1074:
#line 73 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st911;
st911:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof911;
case 911:
#line 21170 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto st364;
		case 9: goto tr1077;
		case 10: goto st366;
		case 13: goto st366;
		case 32: goto tr1077;
		case 35: goto tr1079;
		case 93: goto tr1080;
		case 124: goto tr1146;
	}
	if ( 11 <= (*( sm->p)) && (*( sm->p)) <= 12 )
		goto st873;
	goto st871;
tr1146:
#line 74 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
	goto st912;
st912:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof912;
case 912:
#line 21190 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr452;
		case 9: goto tr1095;
		case 10: goto tr180;
		case 13: goto tr180;
		case 32: goto tr1095;
		case 93: goto tr1096;
		case 124: goto st913;
	}
	if ( 11 <= (*( sm->p)) && (*( sm->p)) <= 12 )
		goto st605;
	goto tr1094;
st913:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof913;
case 913:
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 10: goto tr180;
		case 13: goto tr180;
		case 47: goto st900;
		case 93: goto tr750;
	}
	goto st605;
tr1075:
#line 73 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st914;
st914:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof914;
case 914:
#line 21221 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 10: goto tr180;
		case 13: goto tr180;
		case 93: goto tr750;
		case 95: goto st918;
		case 119: goto st919;
		case 124: goto st920;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st915;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st915;
	} else
		goto st915;
	goto st605;
st915:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof915;
case 915:
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 9: goto tr1152;
		case 10: goto tr180;
		case 13: goto tr180;
		case 32: goto tr1152;
		case 35: goto tr1153;
		case 93: goto tr1080;
		case 124: goto tr1081;
	}
	goto st605;
tr1152:
#line 74 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
	goto st916;
st916:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof916;
case 916:
#line 21261 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 9: goto st916;
		case 10: goto tr180;
		case 13: goto tr180;
		case 32: goto st916;
		case 35: goto st917;
		case 93: goto tr1084;
		case 124: goto st878;
	}
	goto st605;
tr1153:
#line 74 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
	goto st917;
st917:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof917;
case 917:
#line 21279 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 10: goto tr180;
		case 13: goto tr180;
		case 93: goto tr750;
	}
	if ( 65 <= (*( sm->p)) && (*( sm->p)) <= 90 )
		goto tr1086;
	goto st605;
st918:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof918;
case 918:
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 10: goto tr180;
		case 13: goto tr180;
		case 93: goto tr750;
		case 124: goto st915;
	}
	goto st605;
st919:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof919;
case 919:
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 9: goto tr1152;
		case 10: goto tr180;
		case 13: goto tr180;
		case 32: goto tr1152;
		case 35: goto tr1153;
		case 93: goto tr1080;
		case 124: goto tr1103;
	}
	goto st605;
st920:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof920;
case 920:
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 10: goto tr180;
		case 13: goto tr180;
		case 93: goto tr750;
		case 95: goto st921;
	}
	goto st605;
st921:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof921;
case 921:
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 10: goto tr180;
		case 13: goto tr180;
		case 93: goto tr750;
		case 124: goto st918;
	}
	goto st605;
tr1755:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
#line 72 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
#line 579 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 95;}
	goto st1598;
st1598:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1598;
case 1598:
#line 21349 "ext/dtext/dtext.cpp"
	if ( (*( sm->p)) == 123 )
		goto st416;
	goto tr1759;
tr1756:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 579 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 95;}
	goto st1599;
st1599:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1599;
case 1599:
#line 21360 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 47: goto st922;
		case 65: goto st933;
		case 66: goto st956;
		case 67: goto st967;
		case 69: goto st974;
		case 72: goto tr2107;
		case 73: goto st975;
		case 78: goto st993;
		case 81: goto st961;
		case 83: goto st1000;
		case 84: goto st1013;
		case 85: goto st1015;
		case 97: goto st933;
		case 98: goto st956;
		case 99: goto st967;
		case 101: goto st974;
		case 104: goto tr2107;
		case 105: goto st975;
		case 110: goto st993;
		case 113: goto st961;
		case 115: goto st1000;
		case 116: goto st1013;
		case 117: goto st1015;
	}
	goto tr1759;
st922:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof922;
case 922:
	switch( (*( sm->p)) ) {
		case 66: goto st923;
		case 69: goto st924;
		case 73: goto st925;
		case 81: goto st219;
		case 83: goto st926;
		case 84: goto st189;
		case 85: goto st932;
		case 98: goto st923;
		case 101: goto st924;
		case 105: goto st925;
		case 113: goto st219;
		case 115: goto st926;
		case 116: goto st189;
		case 117: goto st932;
	}
	goto tr180;
st923:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof923;
case 923:
	switch( (*( sm->p)) ) {
		case 62: goto tr774;
		case 76: goto st204;
		case 108: goto st204;
	}
	goto tr180;
st924:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof924;
case 924:
	switch( (*( sm->p)) ) {
		case 77: goto st925;
		case 88: goto st214;
		case 109: goto st925;
		case 120: goto st214;
	}
	goto tr180;
st925:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof925;
case 925:
	if ( (*( sm->p)) == 62 )
		goto tr787;
	goto tr180;
st926:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof926;
case 926:
	switch( (*( sm->p)) ) {
		case 62: goto tr798;
		case 80: goto st225;
		case 84: goto st927;
		case 112: goto st225;
		case 116: goto st927;
	}
	goto tr180;
st927:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof927;
case 927:
	switch( (*( sm->p)) ) {
		case 82: goto st928;
		case 114: goto st928;
	}
	goto tr180;
st928:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof928;
case 928:
	switch( (*( sm->p)) ) {
		case 79: goto st929;
		case 111: goto st929;
	}
	goto tr180;
st929:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof929;
case 929:
	switch( (*( sm->p)) ) {
		case 78: goto st930;
		case 110: goto st930;
	}
	goto tr180;
st930:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof930;
case 930:
	switch( (*( sm->p)) ) {
		case 71: goto st931;
		case 103: goto st931;
	}
	goto tr180;
st931:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof931;
case 931:
	if ( (*( sm->p)) == 62 )
		goto tr774;
	goto tr180;
st932:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof932;
case 932:
	if ( (*( sm->p)) == 62 )
		goto tr816;
	goto tr180;
st933:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof933;
case 933:
	switch( (*( sm->p)) ) {
		case 9: goto st934;
		case 32: goto st934;
	}
	goto tr180;
st934:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof934;
case 934:
	switch( (*( sm->p)) ) {
		case 9: goto st934;
		case 32: goto st934;
		case 72: goto st935;
		case 104: goto st935;
	}
	goto tr180;
st935:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof935;
case 935:
	switch( (*( sm->p)) ) {
		case 82: goto st936;
		case 114: goto st936;
	}
	goto tr180;
st936:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof936;
case 936:
	switch( (*( sm->p)) ) {
		case 69: goto st937;
		case 101: goto st937;
	}
	goto tr180;
st937:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof937;
case 937:
	switch( (*( sm->p)) ) {
		case 70: goto st938;
		case 102: goto st938;
	}
	goto tr180;
st938:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof938;
case 938:
	if ( (*( sm->p)) == 61 )
		goto st939;
	goto tr180;
st939:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof939;
case 939:
	if ( (*( sm->p)) == 34 )
		goto st940;
	goto tr180;
st940:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof940;
case 940:
	switch( (*( sm->p)) ) {
		case 35: goto tr1174;
		case 47: goto tr1174;
		case 72: goto tr1175;
		case 104: goto tr1175;
	}
	goto tr180;
tr1174:
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st941;
st941:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof941;
case 941:
#line 21576 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 32: goto tr180;
		case 34: goto tr1177;
	}
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr180;
	goto st941;
tr1177:
#line 72 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
	goto st942;
st942:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof942;
case 942:
#line 21591 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 32: goto tr180;
		case 34: goto tr1177;
		case 62: goto st943;
	}
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr180;
	goto st941;
st943:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof943;
case 943:
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 10: goto tr180;
		case 13: goto tr180;
	}
	goto tr1179;
tr1179:
#line 73 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st944;
st944:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof944;
case 944:
#line 21617 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 10: goto tr180;
		case 13: goto tr180;
		case 60: goto tr1181;
	}
	goto st944;
tr1181:
#line 74 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
	goto st945;
st945:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof945;
case 945:
#line 21631 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 10: goto tr180;
		case 13: goto tr180;
		case 47: goto st946;
		case 60: goto tr1181;
	}
	goto st944;
st946:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof946;
case 946:
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 10: goto tr180;
		case 13: goto tr180;
		case 60: goto tr1181;
		case 65: goto st947;
		case 97: goto st947;
	}
	goto st944;
st947:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof947;
case 947:
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 10: goto tr180;
		case 13: goto tr180;
		case 60: goto tr1181;
		case 62: goto tr1184;
	}
	goto st944;
tr1175:
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st948;
st948:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof948;
case 948:
#line 21671 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 84: goto st949;
		case 116: goto st949;
	}
	goto tr180;
st949:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof949;
case 949:
	switch( (*( sm->p)) ) {
		case 84: goto st950;
		case 116: goto st950;
	}
	goto tr180;
st950:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof950;
case 950:
	switch( (*( sm->p)) ) {
		case 80: goto st951;
		case 112: goto st951;
	}
	goto tr180;
st951:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof951;
case 951:
	switch( (*( sm->p)) ) {
		case 58: goto st952;
		case 83: goto st955;
		case 115: goto st955;
	}
	goto tr180;
st952:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof952;
case 952:
	if ( (*( sm->p)) == 47 )
		goto st953;
	goto tr180;
st953:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof953;
case 953:
	if ( (*( sm->p)) == 47 )
		goto st954;
	goto tr180;
st954:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof954;
case 954:
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 32: goto tr180;
	}
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr180;
	goto st941;
st955:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof955;
case 955:
	if ( (*( sm->p)) == 58 )
		goto st952;
	goto tr180;
st956:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof956;
case 956:
	switch( (*( sm->p)) ) {
		case 62: goto tr818;
		case 76: goto st957;
		case 82: goto st966;
		case 108: goto st957;
		case 114: goto st966;
	}
	goto tr180;
st957:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof957;
case 957:
	switch( (*( sm->p)) ) {
		case 79: goto st958;
		case 111: goto st958;
	}
	goto tr180;
st958:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof958;
case 958:
	switch( (*( sm->p)) ) {
		case 67: goto st959;
		case 99: goto st959;
	}
	goto tr180;
st959:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof959;
case 959:
	switch( (*( sm->p)) ) {
		case 75: goto st960;
		case 107: goto st960;
	}
	goto tr180;
st960:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof960;
case 960:
	switch( (*( sm->p)) ) {
		case 81: goto st961;
		case 113: goto st961;
	}
	goto tr180;
st961:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof961;
case 961:
	switch( (*( sm->p)) ) {
		case 85: goto st962;
		case 117: goto st962;
	}
	goto tr180;
st962:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof962;
case 962:
	switch( (*( sm->p)) ) {
		case 79: goto st963;
		case 111: goto st963;
	}
	goto tr180;
st963:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof963;
case 963:
	switch( (*( sm->p)) ) {
		case 84: goto st964;
		case 116: goto st964;
	}
	goto tr180;
st964:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof964;
case 964:
	switch( (*( sm->p)) ) {
		case 69: goto st965;
		case 101: goto st965;
	}
	goto tr180;
st965:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof965;
case 965:
	if ( (*( sm->p)) == 62 )
		goto tr909;
	goto tr180;
st966:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof966;
case 966:
	if ( (*( sm->p)) == 62 )
		goto tr819;
	goto tr180;
st967:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof967;
case 967:
	switch( (*( sm->p)) ) {
		case 79: goto st968;
		case 111: goto st968;
	}
	goto tr180;
st968:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof968;
case 968:
	switch( (*( sm->p)) ) {
		case 68: goto st969;
		case 100: goto st969;
	}
	goto tr180;
st969:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof969;
case 969:
	switch( (*( sm->p)) ) {
		case 69: goto st970;
		case 101: goto st970;
	}
	goto tr180;
st970:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof970;
case 970:
	switch( (*( sm->p)) ) {
		case 9: goto st971;
		case 32: goto st971;
		case 61: goto st972;
		case 62: goto tr825;
	}
	goto tr180;
st971:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof971;
case 971:
	switch( (*( sm->p)) ) {
		case 9: goto st971;
		case 32: goto st971;
		case 61: goto st972;
	}
	goto tr180;
st972:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof972;
case 972:
	switch( (*( sm->p)) ) {
		case 9: goto st972;
		case 32: goto st972;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1207;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1207;
	} else
		goto tr1207;
	goto tr180;
tr1207:
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st973;
st973:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof973;
case 973:
#line 21906 "ext/dtext/dtext.cpp"
	if ( (*( sm->p)) == 62 )
		goto tr1209;
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st973;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st973;
	} else
		goto st973;
	goto tr180;
tr1209:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 72 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
	goto st1600;
st1600:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1600;
case 1600:
#line 21925 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr830;
		case 9: goto st677;
		case 10: goto tr830;
		case 32: goto st677;
	}
	goto tr2097;
st974:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof974;
case 974:
	switch( (*( sm->p)) ) {
		case 77: goto st975;
		case 88: goto st976;
		case 109: goto st975;
		case 120: goto st976;
	}
	goto tr180;
st975:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof975;
case 975:
	if ( (*( sm->p)) == 62 )
		goto tr894;
	goto tr180;
st976:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof976;
case 976:
	switch( (*( sm->p)) ) {
		case 80: goto st977;
		case 112: goto st977;
	}
	goto tr180;
st977:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof977;
case 977:
	switch( (*( sm->p)) ) {
		case 65: goto st978;
		case 97: goto st978;
	}
	goto tr180;
st978:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof978;
case 978:
	switch( (*( sm->p)) ) {
		case 78: goto st979;
		case 110: goto st979;
	}
	goto tr180;
st979:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof979;
case 979:
	switch( (*( sm->p)) ) {
		case 68: goto st980;
		case 100: goto st980;
	}
	goto tr180;
st980:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof980;
case 980:
	switch( (*( sm->p)) ) {
		case 9: goto st981;
		case 32: goto st981;
		case 61: goto st983;
		case 62: goto tr842;
	}
	goto tr180;
tr1219:
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st981;
st981:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof981;
case 981:
#line 22004 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 9: goto tr1219;
		case 10: goto tr180;
		case 13: goto tr180;
		case 32: goto tr1219;
		case 61: goto tr1220;
		case 62: goto tr1221;
	}
	goto tr1218;
tr1218:
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st982;
st982:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof982;
case 982:
#line 22021 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 10: goto tr180;
		case 13: goto tr180;
		case 62: goto tr1223;
	}
	goto st982;
tr1220:
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st983;
st983:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof983;
case 983:
#line 22035 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 9: goto tr1220;
		case 10: goto tr180;
		case 13: goto tr180;
		case 32: goto tr1220;
		case 62: goto tr1221;
	}
	goto tr1218;
tr2107:
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st984;
st984:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof984;
case 984:
#line 22051 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 84: goto st985;
		case 116: goto st985;
	}
	goto tr180;
st985:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof985;
case 985:
	switch( (*( sm->p)) ) {
		case 84: goto st986;
		case 116: goto st986;
	}
	goto tr180;
st986:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof986;
case 986:
	switch( (*( sm->p)) ) {
		case 80: goto st987;
		case 112: goto st987;
	}
	goto tr180;
st987:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof987;
case 987:
	switch( (*( sm->p)) ) {
		case 58: goto st988;
		case 83: goto st992;
		case 115: goto st992;
	}
	goto tr180;
st988:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof988;
case 988:
	if ( (*( sm->p)) == 47 )
		goto st989;
	goto tr180;
st989:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof989;
case 989:
	if ( (*( sm->p)) == 47 )
		goto st990;
	goto tr180;
st990:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof990;
case 990:
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 32: goto tr180;
	}
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr180;
	goto st991;
st991:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof991;
case 991:
	switch( (*( sm->p)) ) {
		case 0: goto tr180;
		case 32: goto tr180;
		case 62: goto tr1232;
	}
	if ( 9 <= (*( sm->p)) && (*( sm->p)) <= 13 )
		goto tr180;
	goto st991;
st992:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof992;
case 992:
	if ( (*( sm->p)) == 58 )
		goto st988;
	goto tr180;
st993:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof993;
case 993:
	switch( (*( sm->p)) ) {
		case 79: goto st994;
		case 111: goto st994;
	}
	goto tr180;
st994:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof994;
case 994:
	switch( (*( sm->p)) ) {
		case 68: goto st995;
		case 100: goto st995;
	}
	goto tr180;
st995:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof995;
case 995:
	switch( (*( sm->p)) ) {
		case 84: goto st996;
		case 116: goto st996;
	}
	goto tr180;
st996:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof996;
case 996:
	switch( (*( sm->p)) ) {
		case 69: goto st997;
		case 101: goto st997;
	}
	goto tr180;
st997:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof997;
case 997:
	switch( (*( sm->p)) ) {
		case 88: goto st998;
		case 120: goto st998;
	}
	goto tr180;
st998:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof998;
case 998:
	switch( (*( sm->p)) ) {
		case 84: goto st999;
		case 116: goto st999;
	}
	goto tr180;
st999:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof999;
case 999:
	if ( (*( sm->p)) == 62 )
		goto tr901;
	goto tr180;
st1000:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1000;
case 1000:
	switch( (*( sm->p)) ) {
		case 62: goto tr911;
		case 80: goto st1001;
		case 84: goto st1008;
		case 112: goto st1001;
		case 116: goto st1008;
	}
	goto tr180;
st1001:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1001;
case 1001:
	switch( (*( sm->p)) ) {
		case 79: goto st1002;
		case 111: goto st1002;
	}
	goto tr180;
st1002:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1002;
case 1002:
	switch( (*( sm->p)) ) {
		case 73: goto st1003;
		case 105: goto st1003;
	}
	goto tr180;
st1003:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1003;
case 1003:
	switch( (*( sm->p)) ) {
		case 76: goto st1004;
		case 108: goto st1004;
	}
	goto tr180;
st1004:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1004;
case 1004:
	switch( (*( sm->p)) ) {
		case 69: goto st1005;
		case 101: goto st1005;
	}
	goto tr180;
st1005:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1005;
case 1005:
	switch( (*( sm->p)) ) {
		case 82: goto st1006;
		case 114: goto st1006;
	}
	goto tr180;
st1006:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1006;
case 1006:
	switch( (*( sm->p)) ) {
		case 62: goto tr918;
		case 83: goto st1007;
		case 115: goto st1007;
	}
	goto tr180;
st1007:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1007;
case 1007:
	if ( (*( sm->p)) == 62 )
		goto tr918;
	goto tr180;
st1008:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1008;
case 1008:
	switch( (*( sm->p)) ) {
		case 82: goto st1009;
		case 114: goto st1009;
	}
	goto tr180;
st1009:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1009;
case 1009:
	switch( (*( sm->p)) ) {
		case 79: goto st1010;
		case 111: goto st1010;
	}
	goto tr180;
st1010:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1010;
case 1010:
	switch( (*( sm->p)) ) {
		case 78: goto st1011;
		case 110: goto st1011;
	}
	goto tr180;
st1011:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1011;
case 1011:
	switch( (*( sm->p)) ) {
		case 71: goto st1012;
		case 103: goto st1012;
	}
	goto tr180;
st1012:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1012;
case 1012:
	if ( (*( sm->p)) == 62 )
		goto tr818;
	goto tr180;
st1013:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1013;
case 1013:
	switch( (*( sm->p)) ) {
		case 78: goto st1014;
		case 110: goto st1014;
	}
	goto tr180;
st1014:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1014;
case 1014:
	if ( (*( sm->p)) == 62 )
		goto tr921;
	goto tr180;
st1015:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1015;
case 1015:
	if ( (*( sm->p)) == 62 )
		goto tr923;
	goto tr180;
tr1757:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 579 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 95;}
	goto st1601;
st1601:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1601;
case 1601:
#line 22337 "ext/dtext/dtext.cpp"
	_widec = (*( sm->p));
	if ( 64 <= (*( sm->p)) && (*( sm->p)) <= 64 ) {
		_widec = (short)(640 + ((*( sm->p)) - -128));
		if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
	}
	switch( _widec ) {
		case 47: goto st922;
		case 65: goto st933;
		case 66: goto st956;
		case 67: goto st967;
		case 69: goto st974;
		case 72: goto tr2107;
		case 73: goto st975;
		case 78: goto st993;
		case 81: goto st961;
		case 83: goto st1000;
		case 84: goto st1013;
		case 85: goto st1015;
		case 97: goto st933;
		case 98: goto st956;
		case 99: goto st967;
		case 101: goto st974;
		case 104: goto tr2107;
		case 105: goto st975;
		case 110: goto st993;
		case 113: goto st961;
		case 115: goto st1000;
		case 116: goto st1013;
		case 117: goto st1015;
		case 1088: goto st1016;
	}
	goto tr1759;
st1016:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1016;
case 1016:
	_widec = (*( sm->p));
	if ( (*( sm->p)) < 1 ) {
		if ( (*( sm->p)) <= -1 ) {
			_widec = (short)(640 + ((*( sm->p)) - -128));
			if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
		}
	} else if ( (*( sm->p)) > 8 ) {
		if ( (*( sm->p)) > 31 ) {
			if ( 33 <= (*( sm->p)) )
 {				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else if ( (*( sm->p)) >= 14 ) {
			_widec = (short)(640 + ((*( sm->p)) - -128));
			if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
		}
	} else {
		_widec = (short)(640 + ((*( sm->p)) - -128));
		if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
	}
	if ( _widec < 1025 ) {
		if ( 896 <= _widec && _widec <= 1023 )
			goto tr1252;
	} else if ( _widec > 1032 ) {
		if ( _widec > 1055 ) {
			if ( 1057 <= _widec && _widec <= 1151 )
				goto tr1252;
		} else if ( _widec >= 1038 )
			goto tr1252;
	} else
		goto tr1252;
	goto tr180;
tr1252:
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st1017;
st1017:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1017;
case 1017:
#line 22417 "ext/dtext/dtext.cpp"
	_widec = (*( sm->p));
	if ( (*( sm->p)) < 11 ) {
		if ( (*( sm->p)) > -1 ) {
			if ( 1 <= (*( sm->p)) && (*( sm->p)) <= 9 ) {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else {
			_widec = (short)(640 + ((*( sm->p)) - -128));
			if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
		}
	} else if ( (*( sm->p)) > 12 ) {
		if ( (*( sm->p)) < 62 ) {
			if ( 14 <= (*( sm->p)) && (*( sm->p)) <= 61 ) {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else if ( (*( sm->p)) > 62 ) {
			if ( 63 <= (*( sm->p)) )
 {				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else {
			_widec = (short)(640 + ((*( sm->p)) - -128));
			if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
		}
	} else {
		_widec = (short)(640 + ((*( sm->p)) - -128));
		if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
	}
	if ( _widec == 1086 )
		goto tr1254;
	if ( _widec < 1025 ) {
		if ( 896 <= _widec && _widec <= 1023 )
			goto st1017;
	} else if ( _widec > 1033 ) {
		if ( _widec > 1036 ) {
			if ( 1038 <= _widec && _widec <= 1151 )
				goto st1017;
		} else if ( _widec >= 1035 )
			goto st1017;
	} else
		goto st1017;
	goto tr180;
tr1758:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 579 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 95;}
	goto st1602;
st1602:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1602;
case 1602:
#line 22475 "ext/dtext/dtext.cpp"
	_widec = (*( sm->p));
	if ( (*( sm->p)) < 1 ) {
		if ( (*( sm->p)) < -29 ) {
			if ( (*( sm->p)) < -32 ) {
				if ( -62 <= (*( sm->p)) && (*( sm->p)) <= -33 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > -31 ) {
				if ( -30 <= (*( sm->p)) && (*( sm->p)) <= -30 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else if ( (*( sm->p)) > -29 ) {
			if ( (*( sm->p)) < -17 ) {
				if ( -28 <= (*( sm->p)) && (*( sm->p)) <= -18 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > -17 ) {
				if ( -16 <= (*( sm->p)) && (*( sm->p)) <= -12 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else {
			_widec = (short)(640 + ((*( sm->p)) - -128));
			if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
		}
	} else if ( (*( sm->p)) > 8 ) {
		if ( (*( sm->p)) < 65 ) {
			if ( (*( sm->p)) < 46 ) {
				if ( 14 <= (*( sm->p)) && (*( sm->p)) <= 31 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > 46 ) {
				if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else if ( (*( sm->p)) > 90 ) {
			if ( (*( sm->p)) < 97 ) {
				if ( 95 <= (*( sm->p)) && (*( sm->p)) <= 95 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > 122 ) {
				if ( 127 <= (*( sm->p)) )
 {					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else {
			_widec = (short)(640 + ((*( sm->p)) - -128));
			if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
		}
	} else {
		_widec = (short)(640 + ((*( sm->p)) - -128));
		if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
	}
	switch( _widec ) {
		case 994: goto tr2115;
		case 995: goto tr2116;
		case 1007: goto tr2117;
		case 1070: goto tr2120;
		case 1119: goto tr2120;
		case 1151: goto tr2119;
	}
	if ( _widec < 1025 ) {
		if ( _widec < 992 ) {
			if ( 962 <= _widec && _widec <= 991 )
				goto tr2113;
		} else if ( _widec > 1006 ) {
			if ( 1008 <= _widec && _widec <= 1012 )
				goto tr2118;
		} else
			goto tr2114;
	} else if ( _widec > 1032 ) {
		if ( _widec < 1072 ) {
			if ( 1038 <= _widec && _widec <= 1055 )
				goto tr2119;
		} else if ( _widec > 1081 ) {
			if ( _widec > 1114 ) {
				if ( 1121 <= _widec && _widec <= 1146 )
					goto tr2119;
			} else if ( _widec >= 1089 )
				goto tr2119;
		} else
			goto tr2119;
	} else
		goto tr2119;
	goto tr1759;
tr2113:
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st1018;
st1018:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1018;
case 1018:
#line 22604 "ext/dtext/dtext.cpp"
	_widec = (*( sm->p));
	if ( (*( sm->p)) <= -65 ) {
		_widec = (short)(640 + ((*( sm->p)) - -128));
		if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
	}
	if ( 896 <= _widec && _widec <= 959 )
		goto st1019;
	goto tr180;
tr2119:
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st1019;
st1019:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1019;
case 1019:
#line 22620 "ext/dtext/dtext.cpp"
	_widec = (*( sm->p));
	if ( (*( sm->p)) < 1 ) {
		if ( (*( sm->p)) < -29 ) {
			if ( (*( sm->p)) < -62 ) {
				if ( (*( sm->p)) <= -63 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > -33 ) {
				if ( (*( sm->p)) > -31 ) {
					if ( -30 <= (*( sm->p)) && (*( sm->p)) <= -30 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= -32 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else if ( (*( sm->p)) > -29 ) {
			if ( (*( sm->p)) < -17 ) {
				if ( -28 <= (*( sm->p)) && (*( sm->p)) <= -18 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > -17 ) {
				if ( (*( sm->p)) > -12 ) {
					if ( -11 <= (*( sm->p)) && (*( sm->p)) <= -1 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= -16 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else {
			_widec = (short)(640 + ((*( sm->p)) - -128));
			if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
		}
	} else if ( (*( sm->p)) > 8 ) {
		if ( (*( sm->p)) < 45 ) {
			if ( (*( sm->p)) < 33 ) {
				if ( 14 <= (*( sm->p)) && (*( sm->p)) <= 31 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > 33 ) {
				if ( (*( sm->p)) > 39 ) {
					if ( 43 <= (*( sm->p)) && (*( sm->p)) <= 43 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= 39 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else if ( (*( sm->p)) > 47 ) {
			if ( (*( sm->p)) < 95 ) {
				if ( (*( sm->p)) > 57 ) {
					if ( 65 <= (*( sm->p)) && (*( sm->p)) <= 90 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= 48 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > 95 ) {
				if ( (*( sm->p)) > 122 ) {
					if ( 127 <= (*( sm->p)) )
 {						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= 97 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else {
			_widec = (short)(640 + ((*( sm->p)) - -128));
			if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
		}
	} else {
		_widec = (short)(640 + ((*( sm->p)) - -128));
		if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
	}
	switch( _widec ) {
		case 994: goto st1033;
		case 995: goto st1035;
		case 1007: goto st1037;
		case 1057: goto st1019;
		case 1063: goto st1041;
		case 1067: goto st1019;
		case 1119: goto st1019;
		case 1151: goto tr1263;
	}
	if ( _widec < 1025 ) {
		if ( _widec < 992 ) {
			if ( _widec > 961 ) {
				if ( 962 <= _widec && _widec <= 991 )
					goto st1031;
			} else if ( _widec >= 896 )
				goto st1020;
		} else if ( _widec > 1006 ) {
			if ( _widec > 1012 ) {
				if ( 1013 <= _widec && _widec <= 1023 )
					goto st1020;
			} else if ( _widec >= 1008 )
				goto st1040;
		} else
			goto st1032;
	} else if ( _widec > 1032 ) {
		if ( _widec < 1072 ) {
			if ( _widec > 1055 ) {
				if ( 1069 <= _widec && _widec <= 1071 )
					goto st1019;
			} else if ( _widec >= 1038 )
				goto tr1263;
		} else if ( _widec > 1081 ) {
			if ( _widec > 1114 ) {
				if ( 1121 <= _widec && _widec <= 1146 )
					goto tr1263;
			} else if ( _widec >= 1089 )
				goto tr1263;
		} else
			goto tr1263;
	} else
		goto tr1263;
	goto tr173;
st1020:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1020;
case 1020:
	_widec = (*( sm->p));
	if ( (*( sm->p)) < 1 ) {
		if ( (*( sm->p)) < -29 ) {
			if ( (*( sm->p)) < -62 ) {
				if ( (*( sm->p)) <= -63 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > -33 ) {
				if ( (*( sm->p)) > -31 ) {
					if ( -30 <= (*( sm->p)) && (*( sm->p)) <= -30 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= -32 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else if ( (*( sm->p)) > -29 ) {
			if ( (*( sm->p)) < -17 ) {
				if ( -28 <= (*( sm->p)) && (*( sm->p)) <= -18 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > -17 ) {
				if ( (*( sm->p)) > -12 ) {
					if ( -11 <= (*( sm->p)) && (*( sm->p)) <= -1 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= -16 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else {
			_widec = (short)(640 + ((*( sm->p)) - -128));
			if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
		}
	} else if ( (*( sm->p)) > 8 ) {
		if ( (*( sm->p)) < 45 ) {
			if ( (*( sm->p)) < 33 ) {
				if ( 14 <= (*( sm->p)) && (*( sm->p)) <= 31 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > 33 ) {
				if ( (*( sm->p)) > 39 ) {
					if ( 43 <= (*( sm->p)) && (*( sm->p)) <= 43 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= 39 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else if ( (*( sm->p)) > 47 ) {
			if ( (*( sm->p)) < 95 ) {
				if ( (*( sm->p)) > 57 ) {
					if ( 65 <= (*( sm->p)) && (*( sm->p)) <= 90 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= 48 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > 95 ) {
				if ( (*( sm->p)) > 122 ) {
					if ( 127 <= (*( sm->p)) )
 {						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= 97 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else {
			_widec = (short)(640 + ((*( sm->p)) - -128));
			if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
		}
	} else {
		_widec = (short)(640 + ((*( sm->p)) - -128));
		if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
	}
	switch( _widec ) {
		case 994: goto st1023;
		case 995: goto st1025;
		case 1007: goto st1027;
		case 1057: goto st1020;
		case 1063: goto st1020;
		case 1067: goto st1020;
		case 1119: goto st1020;
		case 1151: goto tr1271;
	}
	if ( _widec < 1025 ) {
		if ( _widec < 992 ) {
			if ( _widec > 961 ) {
				if ( 962 <= _widec && _widec <= 991 )
					goto st1021;
			} else if ( _widec >= 896 )
				goto st1020;
		} else if ( _widec > 1006 ) {
			if ( _widec > 1012 ) {
				if ( 1013 <= _widec && _widec <= 1023 )
					goto st1020;
			} else if ( _widec >= 1008 )
				goto st1029;
		} else
			goto st1022;
	} else if ( _widec > 1032 ) {
		if ( _widec < 1072 ) {
			if ( _widec > 1055 ) {
				if ( 1069 <= _widec && _widec <= 1071 )
					goto st1020;
			} else if ( _widec >= 1038 )
				goto tr1271;
		} else if ( _widec > 1081 ) {
			if ( _widec > 1114 ) {
				if ( 1121 <= _widec && _widec <= 1146 )
					goto tr1271;
			} else if ( _widec >= 1089 )
				goto tr1271;
		} else
			goto tr1271;
	} else
		goto tr1271;
	goto tr173;
st1021:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1021;
case 1021:
	_widec = (*( sm->p));
	if ( (*( sm->p)) < 1 ) {
		if ( (*( sm->p)) < -30 ) {
			if ( (*( sm->p)) < -64 ) {
				if ( (*( sm->p)) <= -65 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > -63 ) {
				if ( (*( sm->p)) > -33 ) {
					if ( -32 <= (*( sm->p)) && (*( sm->p)) <= -31 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= -62 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else if ( (*( sm->p)) > -30 ) {
			if ( (*( sm->p)) < -17 ) {
				if ( (*( sm->p)) > -29 ) {
					if ( -28 <= (*( sm->p)) && (*( sm->p)) <= -18 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= -29 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > -17 ) {
				if ( (*( sm->p)) > -12 ) {
					if ( -11 <= (*( sm->p)) && (*( sm->p)) <= -1 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= -16 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else {
			_widec = (short)(640 + ((*( sm->p)) - -128));
			if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
		}
	} else if ( (*( sm->p)) > 8 ) {
		if ( (*( sm->p)) < 45 ) {
			if ( (*( sm->p)) < 33 ) {
				if ( 14 <= (*( sm->p)) && (*( sm->p)) <= 31 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > 33 ) {
				if ( (*( sm->p)) > 39 ) {
					if ( 43 <= (*( sm->p)) && (*( sm->p)) <= 43 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= 39 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else if ( (*( sm->p)) > 47 ) {
			if ( (*( sm->p)) < 95 ) {
				if ( (*( sm->p)) > 57 ) {
					if ( 65 <= (*( sm->p)) && (*( sm->p)) <= 90 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= 48 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > 95 ) {
				if ( (*( sm->p)) > 122 ) {
					if ( 127 <= (*( sm->p)) )
 {						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= 97 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else {
			_widec = (short)(640 + ((*( sm->p)) - -128));
			if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
		}
	} else {
		_widec = (short)(640 + ((*( sm->p)) - -128));
		if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
	}
	switch( _widec ) {
		case 994: goto st1023;
		case 995: goto st1025;
		case 1007: goto st1027;
		case 1057: goto st1020;
		case 1063: goto st1020;
		case 1067: goto st1020;
		case 1119: goto st1020;
		case 1151: goto tr1271;
	}
	if ( _widec < 1013 ) {
		if ( _widec < 962 ) {
			if ( _widec > 959 ) {
				if ( 960 <= _widec && _widec <= 961 )
					goto st1020;
			} else if ( _widec >= 896 )
				goto tr1271;
		} else if ( _widec > 991 ) {
			if ( _widec > 1006 ) {
				if ( 1008 <= _widec && _widec <= 1012 )
					goto st1029;
			} else if ( _widec >= 992 )
				goto st1022;
		} else
			goto st1021;
	} else if ( _widec > 1023 ) {
		if ( _widec < 1069 ) {
			if ( _widec > 1032 ) {
				if ( 1038 <= _widec && _widec <= 1055 )
					goto tr1271;
			} else if ( _widec >= 1025 )
				goto tr1271;
		} else if ( _widec > 1071 ) {
			if ( _widec < 1089 ) {
				if ( 1072 <= _widec && _widec <= 1081 )
					goto tr1271;
			} else if ( _widec > 1114 ) {
				if ( 1121 <= _widec && _widec <= 1146 )
					goto tr1271;
			} else
				goto tr1271;
		} else
			goto st1020;
	} else
		goto st1020;
	goto tr173;
tr1271:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 72 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
#line 383 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 59;}
	goto st1603;
st1603:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1603;
case 1603:
#line 23135 "ext/dtext/dtext.cpp"
	_widec = (*( sm->p));
	if ( (*( sm->p)) < 1 ) {
		if ( (*( sm->p)) < -29 ) {
			if ( (*( sm->p)) < -62 ) {
				if ( (*( sm->p)) <= -63 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > -33 ) {
				if ( (*( sm->p)) > -31 ) {
					if ( -30 <= (*( sm->p)) && (*( sm->p)) <= -30 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= -32 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else if ( (*( sm->p)) > -29 ) {
			if ( (*( sm->p)) < -17 ) {
				if ( -28 <= (*( sm->p)) && (*( sm->p)) <= -18 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > -17 ) {
				if ( (*( sm->p)) > -12 ) {
					if ( -11 <= (*( sm->p)) && (*( sm->p)) <= -1 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= -16 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else {
			_widec = (short)(640 + ((*( sm->p)) - -128));
			if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
		}
	} else if ( (*( sm->p)) > 8 ) {
		if ( (*( sm->p)) < 45 ) {
			if ( (*( sm->p)) < 33 ) {
				if ( 14 <= (*( sm->p)) && (*( sm->p)) <= 31 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > 33 ) {
				if ( (*( sm->p)) > 39 ) {
					if ( 43 <= (*( sm->p)) && (*( sm->p)) <= 43 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= 39 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else if ( (*( sm->p)) > 47 ) {
			if ( (*( sm->p)) < 95 ) {
				if ( (*( sm->p)) > 57 ) {
					if ( 65 <= (*( sm->p)) && (*( sm->p)) <= 90 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= 48 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > 95 ) {
				if ( (*( sm->p)) > 122 ) {
					if ( 127 <= (*( sm->p)) )
 {						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= 97 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else {
			_widec = (short)(640 + ((*( sm->p)) - -128));
			if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
		}
	} else {
		_widec = (short)(640 + ((*( sm->p)) - -128));
		if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
	}
	switch( _widec ) {
		case 994: goto st1023;
		case 995: goto st1025;
		case 1007: goto st1027;
		case 1057: goto st1020;
		case 1063: goto st1020;
		case 1067: goto st1020;
		case 1119: goto st1020;
		case 1151: goto tr1271;
	}
	if ( _widec < 1025 ) {
		if ( _widec < 992 ) {
			if ( _widec > 961 ) {
				if ( 962 <= _widec && _widec <= 991 )
					goto st1021;
			} else if ( _widec >= 896 )
				goto st1020;
		} else if ( _widec > 1006 ) {
			if ( _widec > 1012 ) {
				if ( 1013 <= _widec && _widec <= 1023 )
					goto st1020;
			} else if ( _widec >= 1008 )
				goto st1029;
		} else
			goto st1022;
	} else if ( _widec > 1032 ) {
		if ( _widec < 1072 ) {
			if ( _widec > 1055 ) {
				if ( 1069 <= _widec && _widec <= 1071 )
					goto st1020;
			} else if ( _widec >= 1038 )
				goto tr1271;
		} else if ( _widec > 1081 ) {
			if ( _widec > 1114 ) {
				if ( 1121 <= _widec && _widec <= 1146 )
					goto tr1271;
			} else if ( _widec >= 1089 )
				goto tr1271;
		} else
			goto tr1271;
	} else
		goto tr1271;
	goto tr2121;
st1022:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1022;
case 1022:
	_widec = (*( sm->p));
	if ( (*( sm->p)) < 1 ) {
		if ( (*( sm->p)) < -30 ) {
			if ( (*( sm->p)) < -64 ) {
				if ( (*( sm->p)) <= -65 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > -63 ) {
				if ( (*( sm->p)) > -33 ) {
					if ( -32 <= (*( sm->p)) && (*( sm->p)) <= -31 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= -62 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else if ( (*( sm->p)) > -30 ) {
			if ( (*( sm->p)) < -17 ) {
				if ( (*( sm->p)) > -29 ) {
					if ( -28 <= (*( sm->p)) && (*( sm->p)) <= -18 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= -29 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > -17 ) {
				if ( (*( sm->p)) > -12 ) {
					if ( -11 <= (*( sm->p)) && (*( sm->p)) <= -1 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= -16 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else {
			_widec = (short)(640 + ((*( sm->p)) - -128));
			if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
		}
	} else if ( (*( sm->p)) > 8 ) {
		if ( (*( sm->p)) < 45 ) {
			if ( (*( sm->p)) < 33 ) {
				if ( 14 <= (*( sm->p)) && (*( sm->p)) <= 31 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > 33 ) {
				if ( (*( sm->p)) > 39 ) {
					if ( 43 <= (*( sm->p)) && (*( sm->p)) <= 43 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= 39 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else if ( (*( sm->p)) > 47 ) {
			if ( (*( sm->p)) < 95 ) {
				if ( (*( sm->p)) > 57 ) {
					if ( 65 <= (*( sm->p)) && (*( sm->p)) <= 90 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= 48 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > 95 ) {
				if ( (*( sm->p)) > 122 ) {
					if ( 127 <= (*( sm->p)) )
 {						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= 97 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else {
			_widec = (short)(640 + ((*( sm->p)) - -128));
			if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
		}
	} else {
		_widec = (short)(640 + ((*( sm->p)) - -128));
		if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
	}
	switch( _widec ) {
		case 994: goto st1023;
		case 995: goto st1025;
		case 1007: goto st1027;
		case 1057: goto st1020;
		case 1063: goto st1020;
		case 1067: goto st1020;
		case 1119: goto st1020;
		case 1151: goto tr1271;
	}
	if ( _widec < 1013 ) {
		if ( _widec < 962 ) {
			if ( _widec > 959 ) {
				if ( 960 <= _widec && _widec <= 961 )
					goto st1020;
			} else if ( _widec >= 896 )
				goto st1021;
		} else if ( _widec > 991 ) {
			if ( _widec > 1006 ) {
				if ( 1008 <= _widec && _widec <= 1012 )
					goto st1029;
			} else if ( _widec >= 992 )
				goto st1022;
		} else
			goto st1021;
	} else if ( _widec > 1023 ) {
		if ( _widec < 1069 ) {
			if ( _widec > 1032 ) {
				if ( 1038 <= _widec && _widec <= 1055 )
					goto tr1271;
			} else if ( _widec >= 1025 )
				goto tr1271;
		} else if ( _widec > 1071 ) {
			if ( _widec < 1089 ) {
				if ( 1072 <= _widec && _widec <= 1081 )
					goto tr1271;
			} else if ( _widec > 1114 ) {
				if ( 1121 <= _widec && _widec <= 1146 )
					goto tr1271;
			} else
				goto tr1271;
		} else
			goto st1020;
	} else
		goto st1020;
	goto tr173;
st1023:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1023;
case 1023:
	_widec = (*( sm->p));
	if ( (*( sm->p)) < -11 ) {
		if ( (*( sm->p)) < -32 ) {
			if ( (*( sm->p)) < -98 ) {
				if ( (*( sm->p)) > -100 ) {
					if ( -99 <= (*( sm->p)) && (*( sm->p)) <= -99 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > -65 ) {
				if ( (*( sm->p)) > -63 ) {
					if ( -62 <= (*( sm->p)) && (*( sm->p)) <= -33 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= -64 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else if ( (*( sm->p)) > -31 ) {
			if ( (*( sm->p)) < -28 ) {
				if ( (*( sm->p)) > -30 ) {
					if ( -29 <= (*( sm->p)) && (*( sm->p)) <= -29 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= -30 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > -18 ) {
				if ( (*( sm->p)) > -17 ) {
					if ( -16 <= (*( sm->p)) && (*( sm->p)) <= -12 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= -17 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else {
			_widec = (short)(640 + ((*( sm->p)) - -128));
			if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
		}
	} else if ( (*( sm->p)) > -1 ) {
		if ( (*( sm->p)) < 45 ) {
			if ( (*( sm->p)) < 33 ) {
				if ( (*( sm->p)) > 8 ) {
					if ( 14 <= (*( sm->p)) && (*( sm->p)) <= 31 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= 1 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > 33 ) {
				if ( (*( sm->p)) > 39 ) {
					if ( 43 <= (*( sm->p)) && (*( sm->p)) <= 43 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= 39 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else if ( (*( sm->p)) > 47 ) {
			if ( (*( sm->p)) < 95 ) {
				if ( (*( sm->p)) > 57 ) {
					if ( 65 <= (*( sm->p)) && (*( sm->p)) <= 90 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= 48 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > 95 ) {
				if ( (*( sm->p)) > 122 ) {
					if ( 127 <= (*( sm->p)) )
 {						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= 97 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else {
			_widec = (short)(640 + ((*( sm->p)) - -128));
			if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
		}
	} else {
		_widec = (short)(640 + ((*( sm->p)) - -128));
		if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
	}
	switch( _widec ) {
		case 925: goto st1024;
		case 994: goto st1023;
		case 995: goto st1025;
		case 1007: goto st1027;
		case 1057: goto st1020;
		case 1063: goto st1020;
		case 1067: goto st1020;
		case 1119: goto st1020;
		case 1151: goto tr1271;
	}
	if ( _widec < 1013 ) {
		if ( _widec < 962 ) {
			if ( _widec > 959 ) {
				if ( 960 <= _widec && _widec <= 961 )
					goto st1020;
			} else if ( _widec >= 896 )
				goto st1021;
		} else if ( _widec > 991 ) {
			if ( _widec > 1006 ) {
				if ( 1008 <= _widec && _widec <= 1012 )
					goto st1029;
			} else if ( _widec >= 992 )
				goto st1022;
		} else
			goto st1021;
	} else if ( _widec > 1023 ) {
		if ( _widec < 1069 ) {
			if ( _widec > 1032 ) {
				if ( 1038 <= _widec && _widec <= 1055 )
					goto tr1271;
			} else if ( _widec >= 1025 )
				goto tr1271;
		} else if ( _widec > 1071 ) {
			if ( _widec < 1089 ) {
				if ( 1072 <= _widec && _widec <= 1081 )
					goto tr1271;
			} else if ( _widec > 1114 ) {
				if ( 1121 <= _widec && _widec <= 1146 )
					goto tr1271;
			} else
				goto tr1271;
		} else
			goto st1020;
	} else
		goto st1020;
	goto tr173;
st1024:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1024;
case 1024:
	_widec = (*( sm->p));
	if ( (*( sm->p)) < -11 ) {
		if ( (*( sm->p)) < -32 ) {
			if ( (*( sm->p)) < -82 ) {
				if ( (*( sm->p)) > -84 ) {
					if ( -83 <= (*( sm->p)) && (*( sm->p)) <= -83 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > -65 ) {
				if ( (*( sm->p)) > -63 ) {
					if ( -62 <= (*( sm->p)) && (*( sm->p)) <= -33 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= -64 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else if ( (*( sm->p)) > -31 ) {
			if ( (*( sm->p)) < -28 ) {
				if ( (*( sm->p)) > -30 ) {
					if ( -29 <= (*( sm->p)) && (*( sm->p)) <= -29 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= -30 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > -18 ) {
				if ( (*( sm->p)) > -17 ) {
					if ( -16 <= (*( sm->p)) && (*( sm->p)) <= -12 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= -17 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else {
			_widec = (short)(640 + ((*( sm->p)) - -128));
			if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
		}
	} else if ( (*( sm->p)) > -1 ) {
		if ( (*( sm->p)) < 45 ) {
			if ( (*( sm->p)) < 33 ) {
				if ( (*( sm->p)) > 8 ) {
					if ( 14 <= (*( sm->p)) && (*( sm->p)) <= 31 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= 1 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > 33 ) {
				if ( (*( sm->p)) > 39 ) {
					if ( 43 <= (*( sm->p)) && (*( sm->p)) <= 43 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= 39 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else if ( (*( sm->p)) > 47 ) {
			if ( (*( sm->p)) < 95 ) {
				if ( (*( sm->p)) > 57 ) {
					if ( 65 <= (*( sm->p)) && (*( sm->p)) <= 90 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= 48 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > 95 ) {
				if ( (*( sm->p)) > 122 ) {
					if ( 127 <= (*( sm->p)) )
 {						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= 97 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else {
			_widec = (short)(640 + ((*( sm->p)) - -128));
			if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
		}
	} else {
		_widec = (short)(640 + ((*( sm->p)) - -128));
		if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
	}
	switch( _widec ) {
		case 941: goto st1020;
		case 994: goto st1023;
		case 995: goto st1025;
		case 1007: goto st1027;
		case 1057: goto st1020;
		case 1063: goto st1020;
		case 1067: goto st1020;
		case 1119: goto st1020;
		case 1151: goto tr1271;
	}
	if ( _widec < 1013 ) {
		if ( _widec < 962 ) {
			if ( _widec > 959 ) {
				if ( 960 <= _widec && _widec <= 961 )
					goto st1020;
			} else if ( _widec >= 896 )
				goto tr1271;
		} else if ( _widec > 991 ) {
			if ( _widec > 1006 ) {
				if ( 1008 <= _widec && _widec <= 1012 )
					goto st1029;
			} else if ( _widec >= 992 )
				goto st1022;
		} else
			goto st1021;
	} else if ( _widec > 1023 ) {
		if ( _widec < 1069 ) {
			if ( _widec > 1032 ) {
				if ( 1038 <= _widec && _widec <= 1055 )
					goto tr1271;
			} else if ( _widec >= 1025 )
				goto tr1271;
		} else if ( _widec > 1071 ) {
			if ( _widec < 1089 ) {
				if ( 1072 <= _widec && _widec <= 1081 )
					goto tr1271;
			} else if ( _widec > 1114 ) {
				if ( 1121 <= _widec && _widec <= 1146 )
					goto tr1271;
			} else
				goto tr1271;
		} else
			goto st1020;
	} else
		goto st1020;
	goto tr173;
st1025:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1025;
case 1025:
	_widec = (*( sm->p));
	if ( (*( sm->p)) < -11 ) {
		if ( (*( sm->p)) < -32 ) {
			if ( (*( sm->p)) < -127 ) {
				if ( (*( sm->p)) <= -128 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > -65 ) {
				if ( (*( sm->p)) > -63 ) {
					if ( -62 <= (*( sm->p)) && (*( sm->p)) <= -33 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= -64 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else if ( (*( sm->p)) > -31 ) {
			if ( (*( sm->p)) < -28 ) {
				if ( (*( sm->p)) > -30 ) {
					if ( -29 <= (*( sm->p)) && (*( sm->p)) <= -29 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= -30 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > -18 ) {
				if ( (*( sm->p)) > -17 ) {
					if ( -16 <= (*( sm->p)) && (*( sm->p)) <= -12 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= -17 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else {
			_widec = (short)(640 + ((*( sm->p)) - -128));
			if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
		}
	} else if ( (*( sm->p)) > -1 ) {
		if ( (*( sm->p)) < 45 ) {
			if ( (*( sm->p)) < 33 ) {
				if ( (*( sm->p)) > 8 ) {
					if ( 14 <= (*( sm->p)) && (*( sm->p)) <= 31 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= 1 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > 33 ) {
				if ( (*( sm->p)) > 39 ) {
					if ( 43 <= (*( sm->p)) && (*( sm->p)) <= 43 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= 39 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else if ( (*( sm->p)) > 47 ) {
			if ( (*( sm->p)) < 95 ) {
				if ( (*( sm->p)) > 57 ) {
					if ( 65 <= (*( sm->p)) && (*( sm->p)) <= 90 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= 48 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > 95 ) {
				if ( (*( sm->p)) > 122 ) {
					if ( 127 <= (*( sm->p)) )
 {						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= 97 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else {
			_widec = (short)(640 + ((*( sm->p)) - -128));
			if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
		}
	} else {
		_widec = (short)(640 + ((*( sm->p)) - -128));
		if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
	}
	switch( _widec ) {
		case 896: goto st1026;
		case 994: goto st1023;
		case 995: goto st1025;
		case 1007: goto st1027;
		case 1057: goto st1020;
		case 1063: goto st1020;
		case 1067: goto st1020;
		case 1119: goto st1020;
		case 1151: goto tr1271;
	}
	if ( _widec < 1013 ) {
		if ( _widec < 962 ) {
			if ( _widec > 959 ) {
				if ( 960 <= _widec && _widec <= 961 )
					goto st1020;
			} else if ( _widec >= 897 )
				goto st1021;
		} else if ( _widec > 991 ) {
			if ( _widec > 1006 ) {
				if ( 1008 <= _widec && _widec <= 1012 )
					goto st1029;
			} else if ( _widec >= 992 )
				goto st1022;
		} else
			goto st1021;
	} else if ( _widec > 1023 ) {
		if ( _widec < 1069 ) {
			if ( _widec > 1032 ) {
				if ( 1038 <= _widec && _widec <= 1055 )
					goto tr1271;
			} else if ( _widec >= 1025 )
				goto tr1271;
		} else if ( _widec > 1071 ) {
			if ( _widec < 1089 ) {
				if ( 1072 <= _widec && _widec <= 1081 )
					goto tr1271;
			} else if ( _widec > 1114 ) {
				if ( 1121 <= _widec && _widec <= 1146 )
					goto tr1271;
			} else
				goto tr1271;
		} else
			goto st1020;
	} else
		goto st1020;
	goto tr173;
st1026:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1026;
case 1026:
	_widec = (*( sm->p));
	if ( (*( sm->p)) < -17 ) {
		if ( (*( sm->p)) < -99 ) {
			if ( (*( sm->p)) < -120 ) {
				if ( (*( sm->p)) > -126 ) {
					if ( -125 <= (*( sm->p)) && (*( sm->p)) <= -121 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > -111 ) {
				if ( (*( sm->p)) > -109 ) {
					if ( -108 <= (*( sm->p)) && (*( sm->p)) <= -100 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= -110 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else if ( (*( sm->p)) > -65 ) {
			if ( (*( sm->p)) < -32 ) {
				if ( (*( sm->p)) > -63 ) {
					if ( -62 <= (*( sm->p)) && (*( sm->p)) <= -33 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= -64 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > -31 ) {
				if ( (*( sm->p)) < -29 ) {
					if ( -30 <= (*( sm->p)) && (*( sm->p)) <= -30 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) > -29 ) {
					if ( -28 <= (*( sm->p)) && (*( sm->p)) <= -18 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else {
			_widec = (short)(640 + ((*( sm->p)) - -128));
			if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
		}
	} else if ( (*( sm->p)) > -17 ) {
		if ( (*( sm->p)) < 43 ) {
			if ( (*( sm->p)) < 1 ) {
				if ( (*( sm->p)) > -12 ) {
					if ( -11 <= (*( sm->p)) && (*( sm->p)) <= -1 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= -16 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > 8 ) {
				if ( (*( sm->p)) < 33 ) {
					if ( 14 <= (*( sm->p)) && (*( sm->p)) <= 31 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) > 33 ) {
					if ( 39 <= (*( sm->p)) && (*( sm->p)) <= 39 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else if ( (*( sm->p)) > 43 ) {
			if ( (*( sm->p)) < 65 ) {
				if ( (*( sm->p)) > 47 ) {
					if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= 45 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > 90 ) {
				if ( (*( sm->p)) < 97 ) {
					if ( 95 <= (*( sm->p)) && (*( sm->p)) <= 95 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) > 122 ) {
					if ( 127 <= (*( sm->p)) )
 {						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else {
			_widec = (short)(640 + ((*( sm->p)) - -128));
			if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
		}
	} else {
		_widec = (short)(640 + ((*( sm->p)) - -128));
		if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
	}
	switch( _widec ) {
		case 994: goto st1023;
		case 995: goto st1025;
		case 1007: goto st1027;
		case 1057: goto st1020;
		case 1063: goto st1020;
		case 1067: goto st1020;
		case 1119: goto st1020;
		case 1151: goto tr1271;
	}
	if ( _widec < 992 ) {
		if ( _widec < 914 ) {
			if ( _widec < 899 ) {
				if ( 896 <= _widec && _widec <= 898 )
					goto st1020;
			} else if ( _widec > 903 ) {
				if ( 904 <= _widec && _widec <= 913 )
					goto st1020;
			} else
				goto tr1271;
		} else if ( _widec > 915 ) {
			if ( _widec < 925 ) {
				if ( 916 <= _widec && _widec <= 924 )
					goto st1020;
			} else if ( _widec > 959 ) {
				if ( _widec > 961 ) {
					if ( 962 <= _widec && _widec <= 991 )
						goto st1021;
				} else if ( _widec >= 960 )
					goto st1020;
			} else
				goto tr1271;
		} else
			goto tr1271;
	} else if ( _widec > 1006 ) {
		if ( _widec < 1038 ) {
			if ( _widec < 1013 ) {
				if ( 1008 <= _widec && _widec <= 1012 )
					goto st1029;
			} else if ( _widec > 1023 ) {
				if ( 1025 <= _widec && _widec <= 1032 )
					goto tr1271;
			} else
				goto st1020;
		} else if ( _widec > 1055 ) {
			if ( _widec < 1072 ) {
				if ( 1069 <= _widec && _widec <= 1071 )
					goto st1020;
			} else if ( _widec > 1081 ) {
				if ( _widec > 1114 ) {
					if ( 1121 <= _widec && _widec <= 1146 )
						goto tr1271;
				} else if ( _widec >= 1089 )
					goto tr1271;
			} else
				goto tr1271;
		} else
			goto tr1271;
	} else
		goto st1022;
	goto tr173;
st1027:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1027;
case 1027:
	_widec = (*( sm->p));
	if ( (*( sm->p)) < -16 ) {
		if ( (*( sm->p)) < -62 ) {
			if ( (*( sm->p)) < -67 ) {
				if ( (*( sm->p)) > -69 ) {
					if ( -68 <= (*( sm->p)) && (*( sm->p)) <= -68 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > -67 ) {
				if ( (*( sm->p)) > -65 ) {
					if ( -64 <= (*( sm->p)) && (*( sm->p)) <= -63 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= -66 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else if ( (*( sm->p)) > -33 ) {
			if ( (*( sm->p)) < -29 ) {
				if ( (*( sm->p)) > -31 ) {
					if ( -30 <= (*( sm->p)) && (*( sm->p)) <= -30 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= -32 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > -29 ) {
				if ( (*( sm->p)) > -18 ) {
					if ( -17 <= (*( sm->p)) && (*( sm->p)) <= -17 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= -28 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else {
			_widec = (short)(640 + ((*( sm->p)) - -128));
			if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
		}
	} else if ( (*( sm->p)) > -12 ) {
		if ( (*( sm->p)) < 43 ) {
			if ( (*( sm->p)) < 14 ) {
				if ( (*( sm->p)) > -1 ) {
					if ( 1 <= (*( sm->p)) && (*( sm->p)) <= 8 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= -11 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > 31 ) {
				if ( (*( sm->p)) > 33 ) {
					if ( 39 <= (*( sm->p)) && (*( sm->p)) <= 39 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= 33 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else if ( (*( sm->p)) > 43 ) {
			if ( (*( sm->p)) < 65 ) {
				if ( (*( sm->p)) > 47 ) {
					if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= 45 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > 90 ) {
				if ( (*( sm->p)) < 97 ) {
					if ( 95 <= (*( sm->p)) && (*( sm->p)) <= 95 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) > 122 ) {
					if ( 127 <= (*( sm->p)) )
 {						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else {
			_widec = (short)(640 + ((*( sm->p)) - -128));
			if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
		}
	} else {
		_widec = (short)(640 + ((*( sm->p)) - -128));
		if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
	}
	switch( _widec ) {
		case 956: goto st1028;
		case 957: goto st1030;
		case 994: goto st1023;
		case 995: goto st1025;
		case 1007: goto st1027;
		case 1057: goto st1020;
		case 1063: goto st1020;
		case 1067: goto st1020;
		case 1119: goto st1020;
		case 1151: goto tr1271;
	}
	if ( _widec < 1013 ) {
		if ( _widec < 962 ) {
			if ( _widec > 959 ) {
				if ( 960 <= _widec && _widec <= 961 )
					goto st1020;
			} else if ( _widec >= 896 )
				goto st1021;
		} else if ( _widec > 991 ) {
			if ( _widec > 1006 ) {
				if ( 1008 <= _widec && _widec <= 1012 )
					goto st1029;
			} else if ( _widec >= 992 )
				goto st1022;
		} else
			goto st1021;
	} else if ( _widec > 1023 ) {
		if ( _widec < 1069 ) {
			if ( _widec > 1032 ) {
				if ( 1038 <= _widec && _widec <= 1055 )
					goto tr1271;
			} else if ( _widec >= 1025 )
				goto tr1271;
		} else if ( _widec > 1071 ) {
			if ( _widec < 1089 ) {
				if ( 1072 <= _widec && _widec <= 1081 )
					goto tr1271;
			} else if ( _widec > 1114 ) {
				if ( 1121 <= _widec && _widec <= 1146 )
					goto tr1271;
			} else
				goto tr1271;
		} else
			goto st1020;
	} else
		goto st1020;
	goto tr173;
st1028:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1028;
case 1028:
	_widec = (*( sm->p));
	if ( (*( sm->p)) < -16 ) {
		if ( (*( sm->p)) < -64 ) {
			if ( (*( sm->p)) < -118 ) {
				if ( (*( sm->p)) > -120 ) {
					if ( -119 <= (*( sm->p)) && (*( sm->p)) <= -119 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > -68 ) {
				if ( (*( sm->p)) > -67 ) {
					if ( -66 <= (*( sm->p)) && (*( sm->p)) <= -65 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= -67 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else if ( (*( sm->p)) > -63 ) {
			if ( (*( sm->p)) < -30 ) {
				if ( (*( sm->p)) > -33 ) {
					if ( -32 <= (*( sm->p)) && (*( sm->p)) <= -31 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= -62 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > -30 ) {
				if ( (*( sm->p)) < -28 ) {
					if ( -29 <= (*( sm->p)) && (*( sm->p)) <= -29 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) > -18 ) {
					if ( -17 <= (*( sm->p)) && (*( sm->p)) <= -17 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else {
			_widec = (short)(640 + ((*( sm->p)) - -128));
			if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
		}
	} else if ( (*( sm->p)) > -12 ) {
		if ( (*( sm->p)) < 43 ) {
			if ( (*( sm->p)) < 14 ) {
				if ( (*( sm->p)) > -1 ) {
					if ( 1 <= (*( sm->p)) && (*( sm->p)) <= 8 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= -11 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > 31 ) {
				if ( (*( sm->p)) > 33 ) {
					if ( 39 <= (*( sm->p)) && (*( sm->p)) <= 39 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= 33 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else if ( (*( sm->p)) > 43 ) {
			if ( (*( sm->p)) < 65 ) {
				if ( (*( sm->p)) > 47 ) {
					if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= 45 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > 90 ) {
				if ( (*( sm->p)) < 97 ) {
					if ( 95 <= (*( sm->p)) && (*( sm->p)) <= 95 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) > 122 ) {
					if ( 127 <= (*( sm->p)) )
 {						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else {
			_widec = (short)(640 + ((*( sm->p)) - -128));
			if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
		}
	} else {
		_widec = (short)(640 + ((*( sm->p)) - -128));
		if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
	}
	switch( _widec ) {
		case 905: goto st1020;
		case 957: goto st1020;
		case 994: goto st1023;
		case 995: goto st1025;
		case 1007: goto st1027;
		case 1057: goto st1020;
		case 1063: goto st1020;
		case 1067: goto st1020;
		case 1119: goto st1020;
		case 1151: goto tr1271;
	}
	if ( _widec < 1013 ) {
		if ( _widec < 962 ) {
			if ( _widec > 959 ) {
				if ( 960 <= _widec && _widec <= 961 )
					goto st1020;
			} else if ( _widec >= 896 )
				goto tr1271;
		} else if ( _widec > 991 ) {
			if ( _widec > 1006 ) {
				if ( 1008 <= _widec && _widec <= 1012 )
					goto st1029;
			} else if ( _widec >= 992 )
				goto st1022;
		} else
			goto st1021;
	} else if ( _widec > 1023 ) {
		if ( _widec < 1069 ) {
			if ( _widec > 1032 ) {
				if ( 1038 <= _widec && _widec <= 1055 )
					goto tr1271;
			} else if ( _widec >= 1025 )
				goto tr1271;
		} else if ( _widec > 1071 ) {
			if ( _widec < 1089 ) {
				if ( 1072 <= _widec && _widec <= 1081 )
					goto tr1271;
			} else if ( _widec > 1114 ) {
				if ( 1121 <= _widec && _widec <= 1146 )
					goto tr1271;
			} else
				goto tr1271;
		} else
			goto st1020;
	} else
		goto st1020;
	goto tr173;
st1029:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1029;
case 1029:
	_widec = (*( sm->p));
	if ( (*( sm->p)) < 1 ) {
		if ( (*( sm->p)) < -30 ) {
			if ( (*( sm->p)) < -64 ) {
				if ( (*( sm->p)) <= -65 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > -63 ) {
				if ( (*( sm->p)) > -33 ) {
					if ( -32 <= (*( sm->p)) && (*( sm->p)) <= -31 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= -62 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else if ( (*( sm->p)) > -30 ) {
			if ( (*( sm->p)) < -17 ) {
				if ( (*( sm->p)) > -29 ) {
					if ( -28 <= (*( sm->p)) && (*( sm->p)) <= -18 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= -29 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > -17 ) {
				if ( (*( sm->p)) > -12 ) {
					if ( -11 <= (*( sm->p)) && (*( sm->p)) <= -1 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= -16 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else {
			_widec = (short)(640 + ((*( sm->p)) - -128));
			if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
		}
	} else if ( (*( sm->p)) > 8 ) {
		if ( (*( sm->p)) < 45 ) {
			if ( (*( sm->p)) < 33 ) {
				if ( 14 <= (*( sm->p)) && (*( sm->p)) <= 31 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > 33 ) {
				if ( (*( sm->p)) > 39 ) {
					if ( 43 <= (*( sm->p)) && (*( sm->p)) <= 43 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= 39 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else if ( (*( sm->p)) > 47 ) {
			if ( (*( sm->p)) < 95 ) {
				if ( (*( sm->p)) > 57 ) {
					if ( 65 <= (*( sm->p)) && (*( sm->p)) <= 90 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= 48 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > 95 ) {
				if ( (*( sm->p)) > 122 ) {
					if ( 127 <= (*( sm->p)) )
 {						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= 97 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else {
			_widec = (short)(640 + ((*( sm->p)) - -128));
			if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
		}
	} else {
		_widec = (short)(640 + ((*( sm->p)) - -128));
		if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
	}
	switch( _widec ) {
		case 994: goto st1023;
		case 995: goto st1025;
		case 1007: goto st1027;
		case 1057: goto st1020;
		case 1063: goto st1020;
		case 1067: goto st1020;
		case 1119: goto st1020;
		case 1151: goto tr1271;
	}
	if ( _widec < 1013 ) {
		if ( _widec < 962 ) {
			if ( _widec > 959 ) {
				if ( 960 <= _widec && _widec <= 961 )
					goto st1020;
			} else if ( _widec >= 896 )
				goto st1022;
		} else if ( _widec > 991 ) {
			if ( _widec > 1006 ) {
				if ( 1008 <= _widec && _widec <= 1012 )
					goto st1029;
			} else if ( _widec >= 992 )
				goto st1022;
		} else
			goto st1021;
	} else if ( _widec > 1023 ) {
		if ( _widec < 1069 ) {
			if ( _widec > 1032 ) {
				if ( 1038 <= _widec && _widec <= 1055 )
					goto tr1271;
			} else if ( _widec >= 1025 )
				goto tr1271;
		} else if ( _widec > 1071 ) {
			if ( _widec < 1089 ) {
				if ( 1072 <= _widec && _widec <= 1081 )
					goto tr1271;
			} else if ( _widec > 1114 ) {
				if ( 1121 <= _widec && _widec <= 1146 )
					goto tr1271;
			} else
				goto tr1271;
		} else
			goto st1020;
	} else
		goto st1020;
	goto tr173;
st1030:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1030;
case 1030:
	_widec = (*( sm->p));
	if ( (*( sm->p)) < -17 ) {
		if ( (*( sm->p)) < -92 ) {
			if ( (*( sm->p)) < -98 ) {
				if ( (*( sm->p)) > -100 ) {
					if ( -99 <= (*( sm->p)) && (*( sm->p)) <= -99 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > -97 ) {
				if ( (*( sm->p)) < -95 ) {
					if ( -96 <= (*( sm->p)) && (*( sm->p)) <= -96 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) > -94 ) {
					if ( -93 <= (*( sm->p)) && (*( sm->p)) <= -93 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else if ( (*( sm->p)) > -65 ) {
			if ( (*( sm->p)) < -32 ) {
				if ( (*( sm->p)) > -63 ) {
					if ( -62 <= (*( sm->p)) && (*( sm->p)) <= -33 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= -64 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > -31 ) {
				if ( (*( sm->p)) < -29 ) {
					if ( -30 <= (*( sm->p)) && (*( sm->p)) <= -30 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) > -29 ) {
					if ( -28 <= (*( sm->p)) && (*( sm->p)) <= -18 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else {
			_widec = (short)(640 + ((*( sm->p)) - -128));
			if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
		}
	} else if ( (*( sm->p)) > -17 ) {
		if ( (*( sm->p)) < 43 ) {
			if ( (*( sm->p)) < 1 ) {
				if ( (*( sm->p)) > -12 ) {
					if ( -11 <= (*( sm->p)) && (*( sm->p)) <= -1 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= -16 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > 8 ) {
				if ( (*( sm->p)) < 33 ) {
					if ( 14 <= (*( sm->p)) && (*( sm->p)) <= 31 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) > 33 ) {
					if ( 39 <= (*( sm->p)) && (*( sm->p)) <= 39 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else if ( (*( sm->p)) > 43 ) {
			if ( (*( sm->p)) < 65 ) {
				if ( (*( sm->p)) > 47 ) {
					if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= 45 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > 90 ) {
				if ( (*( sm->p)) < 97 ) {
					if ( 95 <= (*( sm->p)) && (*( sm->p)) <= 95 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) > 122 ) {
					if ( 127 <= (*( sm->p)) )
 {						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else {
			_widec = (short)(640 + ((*( sm->p)) - -128));
			if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
		}
	} else {
		_widec = (short)(640 + ((*( sm->p)) - -128));
		if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
	}
	switch( _widec ) {
		case 925: goto st1020;
		case 928: goto st1020;
		case 931: goto st1020;
		case 994: goto st1023;
		case 995: goto st1025;
		case 1007: goto st1027;
		case 1057: goto st1020;
		case 1063: goto st1020;
		case 1067: goto st1020;
		case 1119: goto st1020;
		case 1151: goto tr1271;
	}
	if ( _widec < 1013 ) {
		if ( _widec < 962 ) {
			if ( _widec > 959 ) {
				if ( 960 <= _widec && _widec <= 961 )
					goto st1020;
			} else if ( _widec >= 896 )
				goto tr1271;
		} else if ( _widec > 991 ) {
			if ( _widec > 1006 ) {
				if ( 1008 <= _widec && _widec <= 1012 )
					goto st1029;
			} else if ( _widec >= 992 )
				goto st1022;
		} else
			goto st1021;
	} else if ( _widec > 1023 ) {
		if ( _widec < 1069 ) {
			if ( _widec > 1032 ) {
				if ( 1038 <= _widec && _widec <= 1055 )
					goto tr1271;
			} else if ( _widec >= 1025 )
				goto tr1271;
		} else if ( _widec > 1071 ) {
			if ( _widec < 1089 ) {
				if ( 1072 <= _widec && _widec <= 1081 )
					goto tr1271;
			} else if ( _widec > 1114 ) {
				if ( 1121 <= _widec && _widec <= 1146 )
					goto tr1271;
			} else
				goto tr1271;
		} else
			goto st1020;
	} else
		goto st1020;
	goto tr173;
st1031:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1031;
case 1031:
	_widec = (*( sm->p));
	if ( (*( sm->p)) < 1 ) {
		if ( (*( sm->p)) < -30 ) {
			if ( (*( sm->p)) < -64 ) {
				if ( (*( sm->p)) <= -65 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > -63 ) {
				if ( (*( sm->p)) > -33 ) {
					if ( -32 <= (*( sm->p)) && (*( sm->p)) <= -31 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= -62 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else if ( (*( sm->p)) > -30 ) {
			if ( (*( sm->p)) < -17 ) {
				if ( (*( sm->p)) > -29 ) {
					if ( -28 <= (*( sm->p)) && (*( sm->p)) <= -18 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= -29 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > -17 ) {
				if ( (*( sm->p)) > -12 ) {
					if ( -11 <= (*( sm->p)) && (*( sm->p)) <= -1 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= -16 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else {
			_widec = (short)(640 + ((*( sm->p)) - -128));
			if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
		}
	} else if ( (*( sm->p)) > 8 ) {
		if ( (*( sm->p)) < 45 ) {
			if ( (*( sm->p)) < 33 ) {
				if ( 14 <= (*( sm->p)) && (*( sm->p)) <= 31 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > 33 ) {
				if ( (*( sm->p)) > 39 ) {
					if ( 43 <= (*( sm->p)) && (*( sm->p)) <= 43 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= 39 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else if ( (*( sm->p)) > 47 ) {
			if ( (*( sm->p)) < 95 ) {
				if ( (*( sm->p)) > 57 ) {
					if ( 65 <= (*( sm->p)) && (*( sm->p)) <= 90 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= 48 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > 95 ) {
				if ( (*( sm->p)) > 122 ) {
					if ( 127 <= (*( sm->p)) )
 {						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= 97 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else {
			_widec = (short)(640 + ((*( sm->p)) - -128));
			if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
		}
	} else {
		_widec = (short)(640 + ((*( sm->p)) - -128));
		if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
	}
	switch( _widec ) {
		case 994: goto st1023;
		case 995: goto st1025;
		case 1007: goto st1027;
		case 1057: goto st1020;
		case 1063: goto st1020;
		case 1067: goto st1020;
		case 1119: goto st1020;
		case 1151: goto tr1271;
	}
	if ( _widec < 1013 ) {
		if ( _widec < 962 ) {
			if ( _widec > 959 ) {
				if ( 960 <= _widec && _widec <= 961 )
					goto st1020;
			} else if ( _widec >= 896 )
				goto tr1263;
		} else if ( _widec > 991 ) {
			if ( _widec > 1006 ) {
				if ( 1008 <= _widec && _widec <= 1012 )
					goto st1029;
			} else if ( _widec >= 992 )
				goto st1022;
		} else
			goto st1021;
	} else if ( _widec > 1023 ) {
		if ( _widec < 1069 ) {
			if ( _widec > 1032 ) {
				if ( 1038 <= _widec && _widec <= 1055 )
					goto tr1271;
			} else if ( _widec >= 1025 )
				goto tr1271;
		} else if ( _widec > 1071 ) {
			if ( _widec < 1089 ) {
				if ( 1072 <= _widec && _widec <= 1081 )
					goto tr1271;
			} else if ( _widec > 1114 ) {
				if ( 1121 <= _widec && _widec <= 1146 )
					goto tr1271;
			} else
				goto tr1271;
		} else
			goto st1020;
	} else
		goto st1020;
	goto tr173;
tr1263:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
#line 72 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
#line 383 "ext/dtext/dtext.cpp.rl"
	{( sm->act) = 59;}
	goto st1604;
st1604:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1604;
case 1604:
#line 25230 "ext/dtext/dtext.cpp"
	_widec = (*( sm->p));
	if ( (*( sm->p)) < 1 ) {
		if ( (*( sm->p)) < -29 ) {
			if ( (*( sm->p)) < -62 ) {
				if ( (*( sm->p)) <= -63 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > -33 ) {
				if ( (*( sm->p)) > -31 ) {
					if ( -30 <= (*( sm->p)) && (*( sm->p)) <= -30 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= -32 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else if ( (*( sm->p)) > -29 ) {
			if ( (*( sm->p)) < -17 ) {
				if ( -28 <= (*( sm->p)) && (*( sm->p)) <= -18 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > -17 ) {
				if ( (*( sm->p)) > -12 ) {
					if ( -11 <= (*( sm->p)) && (*( sm->p)) <= -1 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= -16 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else {
			_widec = (short)(640 + ((*( sm->p)) - -128));
			if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
		}
	} else if ( (*( sm->p)) > 8 ) {
		if ( (*( sm->p)) < 45 ) {
			if ( (*( sm->p)) < 33 ) {
				if ( 14 <= (*( sm->p)) && (*( sm->p)) <= 31 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > 33 ) {
				if ( (*( sm->p)) > 39 ) {
					if ( 43 <= (*( sm->p)) && (*( sm->p)) <= 43 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= 39 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else if ( (*( sm->p)) > 47 ) {
			if ( (*( sm->p)) < 95 ) {
				if ( (*( sm->p)) > 57 ) {
					if ( 65 <= (*( sm->p)) && (*( sm->p)) <= 90 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= 48 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > 95 ) {
				if ( (*( sm->p)) > 122 ) {
					if ( 127 <= (*( sm->p)) )
 {						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= 97 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else {
			_widec = (short)(640 + ((*( sm->p)) - -128));
			if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
		}
	} else {
		_widec = (short)(640 + ((*( sm->p)) - -128));
		if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
	}
	switch( _widec ) {
		case 994: goto st1033;
		case 995: goto st1035;
		case 1007: goto st1037;
		case 1057: goto st1019;
		case 1063: goto st1041;
		case 1067: goto st1019;
		case 1119: goto st1019;
		case 1151: goto tr1263;
	}
	if ( _widec < 1025 ) {
		if ( _widec < 992 ) {
			if ( _widec > 961 ) {
				if ( 962 <= _widec && _widec <= 991 )
					goto st1031;
			} else if ( _widec >= 896 )
				goto st1020;
		} else if ( _widec > 1006 ) {
			if ( _widec > 1012 ) {
				if ( 1013 <= _widec && _widec <= 1023 )
					goto st1020;
			} else if ( _widec >= 1008 )
				goto st1040;
		} else
			goto st1032;
	} else if ( _widec > 1032 ) {
		if ( _widec < 1072 ) {
			if ( _widec > 1055 ) {
				if ( 1069 <= _widec && _widec <= 1071 )
					goto st1019;
			} else if ( _widec >= 1038 )
				goto tr1263;
		} else if ( _widec > 1081 ) {
			if ( _widec > 1114 ) {
				if ( 1121 <= _widec && _widec <= 1146 )
					goto tr1263;
			} else if ( _widec >= 1089 )
				goto tr1263;
		} else
			goto tr1263;
	} else
		goto tr1263;
	goto tr2121;
st1032:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1032;
case 1032:
	_widec = (*( sm->p));
	if ( (*( sm->p)) < 1 ) {
		if ( (*( sm->p)) < -30 ) {
			if ( (*( sm->p)) < -64 ) {
				if ( (*( sm->p)) <= -65 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > -63 ) {
				if ( (*( sm->p)) > -33 ) {
					if ( -32 <= (*( sm->p)) && (*( sm->p)) <= -31 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= -62 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else if ( (*( sm->p)) > -30 ) {
			if ( (*( sm->p)) < -17 ) {
				if ( (*( sm->p)) > -29 ) {
					if ( -28 <= (*( sm->p)) && (*( sm->p)) <= -18 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= -29 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > -17 ) {
				if ( (*( sm->p)) > -12 ) {
					if ( -11 <= (*( sm->p)) && (*( sm->p)) <= -1 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= -16 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else {
			_widec = (short)(640 + ((*( sm->p)) - -128));
			if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
		}
	} else if ( (*( sm->p)) > 8 ) {
		if ( (*( sm->p)) < 45 ) {
			if ( (*( sm->p)) < 33 ) {
				if ( 14 <= (*( sm->p)) && (*( sm->p)) <= 31 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > 33 ) {
				if ( (*( sm->p)) > 39 ) {
					if ( 43 <= (*( sm->p)) && (*( sm->p)) <= 43 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= 39 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else if ( (*( sm->p)) > 47 ) {
			if ( (*( sm->p)) < 95 ) {
				if ( (*( sm->p)) > 57 ) {
					if ( 65 <= (*( sm->p)) && (*( sm->p)) <= 90 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= 48 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > 95 ) {
				if ( (*( sm->p)) > 122 ) {
					if ( 127 <= (*( sm->p)) )
 {						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= 97 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else {
			_widec = (short)(640 + ((*( sm->p)) - -128));
			if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
		}
	} else {
		_widec = (short)(640 + ((*( sm->p)) - -128));
		if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
	}
	switch( _widec ) {
		case 994: goto st1023;
		case 995: goto st1025;
		case 1007: goto st1027;
		case 1057: goto st1020;
		case 1063: goto st1020;
		case 1067: goto st1020;
		case 1119: goto st1020;
		case 1151: goto tr1271;
	}
	if ( _widec < 1013 ) {
		if ( _widec < 962 ) {
			if ( _widec > 959 ) {
				if ( 960 <= _widec && _widec <= 961 )
					goto st1020;
			} else if ( _widec >= 896 )
				goto st1031;
		} else if ( _widec > 991 ) {
			if ( _widec > 1006 ) {
				if ( 1008 <= _widec && _widec <= 1012 )
					goto st1029;
			} else if ( _widec >= 992 )
				goto st1022;
		} else
			goto st1021;
	} else if ( _widec > 1023 ) {
		if ( _widec < 1069 ) {
			if ( _widec > 1032 ) {
				if ( 1038 <= _widec && _widec <= 1055 )
					goto tr1271;
			} else if ( _widec >= 1025 )
				goto tr1271;
		} else if ( _widec > 1071 ) {
			if ( _widec < 1089 ) {
				if ( 1072 <= _widec && _widec <= 1081 )
					goto tr1271;
			} else if ( _widec > 1114 ) {
				if ( 1121 <= _widec && _widec <= 1146 )
					goto tr1271;
			} else
				goto tr1271;
		} else
			goto st1020;
	} else
		goto st1020;
	goto tr173;
st1033:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1033;
case 1033:
	_widec = (*( sm->p));
	if ( (*( sm->p)) < -11 ) {
		if ( (*( sm->p)) < -32 ) {
			if ( (*( sm->p)) < -98 ) {
				if ( (*( sm->p)) > -100 ) {
					if ( -99 <= (*( sm->p)) && (*( sm->p)) <= -99 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > -65 ) {
				if ( (*( sm->p)) > -63 ) {
					if ( -62 <= (*( sm->p)) && (*( sm->p)) <= -33 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= -64 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else if ( (*( sm->p)) > -31 ) {
			if ( (*( sm->p)) < -28 ) {
				if ( (*( sm->p)) > -30 ) {
					if ( -29 <= (*( sm->p)) && (*( sm->p)) <= -29 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= -30 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > -18 ) {
				if ( (*( sm->p)) > -17 ) {
					if ( -16 <= (*( sm->p)) && (*( sm->p)) <= -12 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= -17 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else {
			_widec = (short)(640 + ((*( sm->p)) - -128));
			if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
		}
	} else if ( (*( sm->p)) > -1 ) {
		if ( (*( sm->p)) < 45 ) {
			if ( (*( sm->p)) < 33 ) {
				if ( (*( sm->p)) > 8 ) {
					if ( 14 <= (*( sm->p)) && (*( sm->p)) <= 31 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= 1 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > 33 ) {
				if ( (*( sm->p)) > 39 ) {
					if ( 43 <= (*( sm->p)) && (*( sm->p)) <= 43 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= 39 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else if ( (*( sm->p)) > 47 ) {
			if ( (*( sm->p)) < 95 ) {
				if ( (*( sm->p)) > 57 ) {
					if ( 65 <= (*( sm->p)) && (*( sm->p)) <= 90 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= 48 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > 95 ) {
				if ( (*( sm->p)) > 122 ) {
					if ( 127 <= (*( sm->p)) )
 {						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= 97 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else {
			_widec = (short)(640 + ((*( sm->p)) - -128));
			if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
		}
	} else {
		_widec = (short)(640 + ((*( sm->p)) - -128));
		if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
	}
	switch( _widec ) {
		case 925: goto st1034;
		case 994: goto st1023;
		case 995: goto st1025;
		case 1007: goto st1027;
		case 1057: goto st1020;
		case 1063: goto st1020;
		case 1067: goto st1020;
		case 1119: goto st1020;
		case 1151: goto tr1271;
	}
	if ( _widec < 1013 ) {
		if ( _widec < 962 ) {
			if ( _widec > 959 ) {
				if ( 960 <= _widec && _widec <= 961 )
					goto st1020;
			} else if ( _widec >= 896 )
				goto st1031;
		} else if ( _widec > 991 ) {
			if ( _widec > 1006 ) {
				if ( 1008 <= _widec && _widec <= 1012 )
					goto st1029;
			} else if ( _widec >= 992 )
				goto st1022;
		} else
			goto st1021;
	} else if ( _widec > 1023 ) {
		if ( _widec < 1069 ) {
			if ( _widec > 1032 ) {
				if ( 1038 <= _widec && _widec <= 1055 )
					goto tr1271;
			} else if ( _widec >= 1025 )
				goto tr1271;
		} else if ( _widec > 1071 ) {
			if ( _widec < 1089 ) {
				if ( 1072 <= _widec && _widec <= 1081 )
					goto tr1271;
			} else if ( _widec > 1114 ) {
				if ( 1121 <= _widec && _widec <= 1146 )
					goto tr1271;
			} else
				goto tr1271;
		} else
			goto st1020;
	} else
		goto st1020;
	goto tr173;
st1034:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1034;
case 1034:
	_widec = (*( sm->p));
	if ( (*( sm->p)) < -11 ) {
		if ( (*( sm->p)) < -32 ) {
			if ( (*( sm->p)) < -82 ) {
				if ( (*( sm->p)) > -84 ) {
					if ( -83 <= (*( sm->p)) && (*( sm->p)) <= -83 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > -65 ) {
				if ( (*( sm->p)) > -63 ) {
					if ( -62 <= (*( sm->p)) && (*( sm->p)) <= -33 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= -64 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else if ( (*( sm->p)) > -31 ) {
			if ( (*( sm->p)) < -28 ) {
				if ( (*( sm->p)) > -30 ) {
					if ( -29 <= (*( sm->p)) && (*( sm->p)) <= -29 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= -30 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > -18 ) {
				if ( (*( sm->p)) > -17 ) {
					if ( -16 <= (*( sm->p)) && (*( sm->p)) <= -12 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= -17 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else {
			_widec = (short)(640 + ((*( sm->p)) - -128));
			if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
		}
	} else if ( (*( sm->p)) > -1 ) {
		if ( (*( sm->p)) < 45 ) {
			if ( (*( sm->p)) < 33 ) {
				if ( (*( sm->p)) > 8 ) {
					if ( 14 <= (*( sm->p)) && (*( sm->p)) <= 31 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= 1 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > 33 ) {
				if ( (*( sm->p)) > 39 ) {
					if ( 43 <= (*( sm->p)) && (*( sm->p)) <= 43 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= 39 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else if ( (*( sm->p)) > 47 ) {
			if ( (*( sm->p)) < 95 ) {
				if ( (*( sm->p)) > 57 ) {
					if ( 65 <= (*( sm->p)) && (*( sm->p)) <= 90 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= 48 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > 95 ) {
				if ( (*( sm->p)) > 122 ) {
					if ( 127 <= (*( sm->p)) )
 {						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= 97 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else {
			_widec = (short)(640 + ((*( sm->p)) - -128));
			if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
		}
	} else {
		_widec = (short)(640 + ((*( sm->p)) - -128));
		if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
	}
	switch( _widec ) {
		case 941: goto st1019;
		case 994: goto st1023;
		case 995: goto st1025;
		case 1007: goto st1027;
		case 1057: goto st1020;
		case 1063: goto st1020;
		case 1067: goto st1020;
		case 1119: goto st1020;
		case 1151: goto tr1271;
	}
	if ( _widec < 1013 ) {
		if ( _widec < 962 ) {
			if ( _widec > 959 ) {
				if ( 960 <= _widec && _widec <= 961 )
					goto st1020;
			} else if ( _widec >= 896 )
				goto tr1263;
		} else if ( _widec > 991 ) {
			if ( _widec > 1006 ) {
				if ( 1008 <= _widec && _widec <= 1012 )
					goto st1029;
			} else if ( _widec >= 992 )
				goto st1022;
		} else
			goto st1021;
	} else if ( _widec > 1023 ) {
		if ( _widec < 1069 ) {
			if ( _widec > 1032 ) {
				if ( 1038 <= _widec && _widec <= 1055 )
					goto tr1271;
			} else if ( _widec >= 1025 )
				goto tr1271;
		} else if ( _widec > 1071 ) {
			if ( _widec < 1089 ) {
				if ( 1072 <= _widec && _widec <= 1081 )
					goto tr1271;
			} else if ( _widec > 1114 ) {
				if ( 1121 <= _widec && _widec <= 1146 )
					goto tr1271;
			} else
				goto tr1271;
		} else
			goto st1020;
	} else
		goto st1020;
	goto tr173;
st1035:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1035;
case 1035:
	_widec = (*( sm->p));
	if ( (*( sm->p)) < -11 ) {
		if ( (*( sm->p)) < -32 ) {
			if ( (*( sm->p)) < -127 ) {
				if ( (*( sm->p)) <= -128 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > -65 ) {
				if ( (*( sm->p)) > -63 ) {
					if ( -62 <= (*( sm->p)) && (*( sm->p)) <= -33 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= -64 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else if ( (*( sm->p)) > -31 ) {
			if ( (*( sm->p)) < -28 ) {
				if ( (*( sm->p)) > -30 ) {
					if ( -29 <= (*( sm->p)) && (*( sm->p)) <= -29 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= -30 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > -18 ) {
				if ( (*( sm->p)) > -17 ) {
					if ( -16 <= (*( sm->p)) && (*( sm->p)) <= -12 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= -17 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else {
			_widec = (short)(640 + ((*( sm->p)) - -128));
			if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
		}
	} else if ( (*( sm->p)) > -1 ) {
		if ( (*( sm->p)) < 45 ) {
			if ( (*( sm->p)) < 33 ) {
				if ( (*( sm->p)) > 8 ) {
					if ( 14 <= (*( sm->p)) && (*( sm->p)) <= 31 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= 1 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > 33 ) {
				if ( (*( sm->p)) > 39 ) {
					if ( 43 <= (*( sm->p)) && (*( sm->p)) <= 43 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= 39 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else if ( (*( sm->p)) > 47 ) {
			if ( (*( sm->p)) < 95 ) {
				if ( (*( sm->p)) > 57 ) {
					if ( 65 <= (*( sm->p)) && (*( sm->p)) <= 90 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= 48 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > 95 ) {
				if ( (*( sm->p)) > 122 ) {
					if ( 127 <= (*( sm->p)) )
 {						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= 97 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else {
			_widec = (short)(640 + ((*( sm->p)) - -128));
			if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
		}
	} else {
		_widec = (short)(640 + ((*( sm->p)) - -128));
		if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
	}
	switch( _widec ) {
		case 896: goto st1036;
		case 994: goto st1023;
		case 995: goto st1025;
		case 1007: goto st1027;
		case 1057: goto st1020;
		case 1063: goto st1020;
		case 1067: goto st1020;
		case 1119: goto st1020;
		case 1151: goto tr1271;
	}
	if ( _widec < 1013 ) {
		if ( _widec < 962 ) {
			if ( _widec > 959 ) {
				if ( 960 <= _widec && _widec <= 961 )
					goto st1020;
			} else if ( _widec >= 897 )
				goto st1031;
		} else if ( _widec > 991 ) {
			if ( _widec > 1006 ) {
				if ( 1008 <= _widec && _widec <= 1012 )
					goto st1029;
			} else if ( _widec >= 992 )
				goto st1022;
		} else
			goto st1021;
	} else if ( _widec > 1023 ) {
		if ( _widec < 1069 ) {
			if ( _widec > 1032 ) {
				if ( 1038 <= _widec && _widec <= 1055 )
					goto tr1271;
			} else if ( _widec >= 1025 )
				goto tr1271;
		} else if ( _widec > 1071 ) {
			if ( _widec < 1089 ) {
				if ( 1072 <= _widec && _widec <= 1081 )
					goto tr1271;
			} else if ( _widec > 1114 ) {
				if ( 1121 <= _widec && _widec <= 1146 )
					goto tr1271;
			} else
				goto tr1271;
		} else
			goto st1020;
	} else
		goto st1020;
	goto tr173;
st1036:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1036;
case 1036:
	_widec = (*( sm->p));
	if ( (*( sm->p)) < -17 ) {
		if ( (*( sm->p)) < -99 ) {
			if ( (*( sm->p)) < -120 ) {
				if ( (*( sm->p)) > -126 ) {
					if ( -125 <= (*( sm->p)) && (*( sm->p)) <= -121 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > -111 ) {
				if ( (*( sm->p)) > -109 ) {
					if ( -108 <= (*( sm->p)) && (*( sm->p)) <= -100 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= -110 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else if ( (*( sm->p)) > -65 ) {
			if ( (*( sm->p)) < -32 ) {
				if ( (*( sm->p)) > -63 ) {
					if ( -62 <= (*( sm->p)) && (*( sm->p)) <= -33 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= -64 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > -31 ) {
				if ( (*( sm->p)) < -29 ) {
					if ( -30 <= (*( sm->p)) && (*( sm->p)) <= -30 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) > -29 ) {
					if ( -28 <= (*( sm->p)) && (*( sm->p)) <= -18 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else {
			_widec = (short)(640 + ((*( sm->p)) - -128));
			if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
		}
	} else if ( (*( sm->p)) > -17 ) {
		if ( (*( sm->p)) < 43 ) {
			if ( (*( sm->p)) < 1 ) {
				if ( (*( sm->p)) > -12 ) {
					if ( -11 <= (*( sm->p)) && (*( sm->p)) <= -1 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= -16 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > 8 ) {
				if ( (*( sm->p)) < 33 ) {
					if ( 14 <= (*( sm->p)) && (*( sm->p)) <= 31 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) > 33 ) {
					if ( 39 <= (*( sm->p)) && (*( sm->p)) <= 39 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else if ( (*( sm->p)) > 43 ) {
			if ( (*( sm->p)) < 65 ) {
				if ( (*( sm->p)) > 47 ) {
					if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= 45 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > 90 ) {
				if ( (*( sm->p)) < 97 ) {
					if ( 95 <= (*( sm->p)) && (*( sm->p)) <= 95 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) > 122 ) {
					if ( 127 <= (*( sm->p)) )
 {						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else {
			_widec = (short)(640 + ((*( sm->p)) - -128));
			if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
		}
	} else {
		_widec = (short)(640 + ((*( sm->p)) - -128));
		if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
	}
	switch( _widec ) {
		case 994: goto st1023;
		case 995: goto st1025;
		case 1007: goto st1027;
		case 1057: goto st1020;
		case 1063: goto st1020;
		case 1067: goto st1020;
		case 1119: goto st1020;
		case 1151: goto tr1271;
	}
	if ( _widec < 992 ) {
		if ( _widec < 914 ) {
			if ( _widec < 899 ) {
				if ( 896 <= _widec && _widec <= 898 )
					goto st1019;
			} else if ( _widec > 903 ) {
				if ( 904 <= _widec && _widec <= 913 )
					goto st1019;
			} else
				goto tr1263;
		} else if ( _widec > 915 ) {
			if ( _widec < 925 ) {
				if ( 916 <= _widec && _widec <= 924 )
					goto st1019;
			} else if ( _widec > 959 ) {
				if ( _widec > 961 ) {
					if ( 962 <= _widec && _widec <= 991 )
						goto st1021;
				} else if ( _widec >= 960 )
					goto st1020;
			} else
				goto tr1263;
		} else
			goto tr1263;
	} else if ( _widec > 1006 ) {
		if ( _widec < 1038 ) {
			if ( _widec < 1013 ) {
				if ( 1008 <= _widec && _widec <= 1012 )
					goto st1029;
			} else if ( _widec > 1023 ) {
				if ( 1025 <= _widec && _widec <= 1032 )
					goto tr1271;
			} else
				goto st1020;
		} else if ( _widec > 1055 ) {
			if ( _widec < 1072 ) {
				if ( 1069 <= _widec && _widec <= 1071 )
					goto st1020;
			} else if ( _widec > 1081 ) {
				if ( _widec > 1114 ) {
					if ( 1121 <= _widec && _widec <= 1146 )
						goto tr1271;
				} else if ( _widec >= 1089 )
					goto tr1271;
			} else
				goto tr1271;
		} else
			goto tr1271;
	} else
		goto st1022;
	goto tr173;
st1037:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1037;
case 1037:
	_widec = (*( sm->p));
	if ( (*( sm->p)) < -16 ) {
		if ( (*( sm->p)) < -62 ) {
			if ( (*( sm->p)) < -67 ) {
				if ( (*( sm->p)) > -69 ) {
					if ( -68 <= (*( sm->p)) && (*( sm->p)) <= -68 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > -67 ) {
				if ( (*( sm->p)) > -65 ) {
					if ( -64 <= (*( sm->p)) && (*( sm->p)) <= -63 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= -66 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else if ( (*( sm->p)) > -33 ) {
			if ( (*( sm->p)) < -29 ) {
				if ( (*( sm->p)) > -31 ) {
					if ( -30 <= (*( sm->p)) && (*( sm->p)) <= -30 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= -32 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > -29 ) {
				if ( (*( sm->p)) > -18 ) {
					if ( -17 <= (*( sm->p)) && (*( sm->p)) <= -17 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= -28 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else {
			_widec = (short)(640 + ((*( sm->p)) - -128));
			if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
		}
	} else if ( (*( sm->p)) > -12 ) {
		if ( (*( sm->p)) < 43 ) {
			if ( (*( sm->p)) < 14 ) {
				if ( (*( sm->p)) > -1 ) {
					if ( 1 <= (*( sm->p)) && (*( sm->p)) <= 8 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= -11 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > 31 ) {
				if ( (*( sm->p)) > 33 ) {
					if ( 39 <= (*( sm->p)) && (*( sm->p)) <= 39 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= 33 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else if ( (*( sm->p)) > 43 ) {
			if ( (*( sm->p)) < 65 ) {
				if ( (*( sm->p)) > 47 ) {
					if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= 45 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > 90 ) {
				if ( (*( sm->p)) < 97 ) {
					if ( 95 <= (*( sm->p)) && (*( sm->p)) <= 95 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) > 122 ) {
					if ( 127 <= (*( sm->p)) )
 {						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else {
			_widec = (short)(640 + ((*( sm->p)) - -128));
			if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
		}
	} else {
		_widec = (short)(640 + ((*( sm->p)) - -128));
		if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
	}
	switch( _widec ) {
		case 956: goto st1038;
		case 957: goto st1039;
		case 994: goto st1023;
		case 995: goto st1025;
		case 1007: goto st1027;
		case 1057: goto st1020;
		case 1063: goto st1020;
		case 1067: goto st1020;
		case 1119: goto st1020;
		case 1151: goto tr1271;
	}
	if ( _widec < 1013 ) {
		if ( _widec < 962 ) {
			if ( _widec > 959 ) {
				if ( 960 <= _widec && _widec <= 961 )
					goto st1020;
			} else if ( _widec >= 896 )
				goto st1031;
		} else if ( _widec > 991 ) {
			if ( _widec > 1006 ) {
				if ( 1008 <= _widec && _widec <= 1012 )
					goto st1029;
			} else if ( _widec >= 992 )
				goto st1022;
		} else
			goto st1021;
	} else if ( _widec > 1023 ) {
		if ( _widec < 1069 ) {
			if ( _widec > 1032 ) {
				if ( 1038 <= _widec && _widec <= 1055 )
					goto tr1271;
			} else if ( _widec >= 1025 )
				goto tr1271;
		} else if ( _widec > 1071 ) {
			if ( _widec < 1089 ) {
				if ( 1072 <= _widec && _widec <= 1081 )
					goto tr1271;
			} else if ( _widec > 1114 ) {
				if ( 1121 <= _widec && _widec <= 1146 )
					goto tr1271;
			} else
				goto tr1271;
		} else
			goto st1020;
	} else
		goto st1020;
	goto tr173;
st1038:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1038;
case 1038:
	_widec = (*( sm->p));
	if ( (*( sm->p)) < -16 ) {
		if ( (*( sm->p)) < -64 ) {
			if ( (*( sm->p)) < -118 ) {
				if ( (*( sm->p)) > -120 ) {
					if ( -119 <= (*( sm->p)) && (*( sm->p)) <= -119 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > -68 ) {
				if ( (*( sm->p)) > -67 ) {
					if ( -66 <= (*( sm->p)) && (*( sm->p)) <= -65 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= -67 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else if ( (*( sm->p)) > -63 ) {
			if ( (*( sm->p)) < -30 ) {
				if ( (*( sm->p)) > -33 ) {
					if ( -32 <= (*( sm->p)) && (*( sm->p)) <= -31 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= -62 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > -30 ) {
				if ( (*( sm->p)) < -28 ) {
					if ( -29 <= (*( sm->p)) && (*( sm->p)) <= -29 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) > -18 ) {
					if ( -17 <= (*( sm->p)) && (*( sm->p)) <= -17 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else {
			_widec = (short)(640 + ((*( sm->p)) - -128));
			if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
		}
	} else if ( (*( sm->p)) > -12 ) {
		if ( (*( sm->p)) < 43 ) {
			if ( (*( sm->p)) < 14 ) {
				if ( (*( sm->p)) > -1 ) {
					if ( 1 <= (*( sm->p)) && (*( sm->p)) <= 8 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= -11 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > 31 ) {
				if ( (*( sm->p)) > 33 ) {
					if ( 39 <= (*( sm->p)) && (*( sm->p)) <= 39 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= 33 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else if ( (*( sm->p)) > 43 ) {
			if ( (*( sm->p)) < 65 ) {
				if ( (*( sm->p)) > 47 ) {
					if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= 45 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > 90 ) {
				if ( (*( sm->p)) < 97 ) {
					if ( 95 <= (*( sm->p)) && (*( sm->p)) <= 95 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) > 122 ) {
					if ( 127 <= (*( sm->p)) )
 {						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else {
			_widec = (short)(640 + ((*( sm->p)) - -128));
			if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
		}
	} else {
		_widec = (short)(640 + ((*( sm->p)) - -128));
		if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
	}
	switch( _widec ) {
		case 905: goto st1019;
		case 957: goto st1019;
		case 994: goto st1023;
		case 995: goto st1025;
		case 1007: goto st1027;
		case 1057: goto st1020;
		case 1063: goto st1020;
		case 1067: goto st1020;
		case 1119: goto st1020;
		case 1151: goto tr1271;
	}
	if ( _widec < 1013 ) {
		if ( _widec < 962 ) {
			if ( _widec > 959 ) {
				if ( 960 <= _widec && _widec <= 961 )
					goto st1020;
			} else if ( _widec >= 896 )
				goto tr1263;
		} else if ( _widec > 991 ) {
			if ( _widec > 1006 ) {
				if ( 1008 <= _widec && _widec <= 1012 )
					goto st1029;
			} else if ( _widec >= 992 )
				goto st1022;
		} else
			goto st1021;
	} else if ( _widec > 1023 ) {
		if ( _widec < 1069 ) {
			if ( _widec > 1032 ) {
				if ( 1038 <= _widec && _widec <= 1055 )
					goto tr1271;
			} else if ( _widec >= 1025 )
				goto tr1271;
		} else if ( _widec > 1071 ) {
			if ( _widec < 1089 ) {
				if ( 1072 <= _widec && _widec <= 1081 )
					goto tr1271;
			} else if ( _widec > 1114 ) {
				if ( 1121 <= _widec && _widec <= 1146 )
					goto tr1271;
			} else
				goto tr1271;
		} else
			goto st1020;
	} else
		goto st1020;
	goto tr173;
st1039:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1039;
case 1039:
	_widec = (*( sm->p));
	if ( (*( sm->p)) < -17 ) {
		if ( (*( sm->p)) < -92 ) {
			if ( (*( sm->p)) < -98 ) {
				if ( (*( sm->p)) > -100 ) {
					if ( -99 <= (*( sm->p)) && (*( sm->p)) <= -99 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > -97 ) {
				if ( (*( sm->p)) < -95 ) {
					if ( -96 <= (*( sm->p)) && (*( sm->p)) <= -96 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) > -94 ) {
					if ( -93 <= (*( sm->p)) && (*( sm->p)) <= -93 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else if ( (*( sm->p)) > -65 ) {
			if ( (*( sm->p)) < -32 ) {
				if ( (*( sm->p)) > -63 ) {
					if ( -62 <= (*( sm->p)) && (*( sm->p)) <= -33 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= -64 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > -31 ) {
				if ( (*( sm->p)) < -29 ) {
					if ( -30 <= (*( sm->p)) && (*( sm->p)) <= -30 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) > -29 ) {
					if ( -28 <= (*( sm->p)) && (*( sm->p)) <= -18 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else {
			_widec = (short)(640 + ((*( sm->p)) - -128));
			if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
		}
	} else if ( (*( sm->p)) > -17 ) {
		if ( (*( sm->p)) < 43 ) {
			if ( (*( sm->p)) < 1 ) {
				if ( (*( sm->p)) > -12 ) {
					if ( -11 <= (*( sm->p)) && (*( sm->p)) <= -1 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= -16 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > 8 ) {
				if ( (*( sm->p)) < 33 ) {
					if ( 14 <= (*( sm->p)) && (*( sm->p)) <= 31 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) > 33 ) {
					if ( 39 <= (*( sm->p)) && (*( sm->p)) <= 39 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else if ( (*( sm->p)) > 43 ) {
			if ( (*( sm->p)) < 65 ) {
				if ( (*( sm->p)) > 47 ) {
					if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= 45 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > 90 ) {
				if ( (*( sm->p)) < 97 ) {
					if ( 95 <= (*( sm->p)) && (*( sm->p)) <= 95 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) > 122 ) {
					if ( 127 <= (*( sm->p)) )
 {						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else {
			_widec = (short)(640 + ((*( sm->p)) - -128));
			if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
		}
	} else {
		_widec = (short)(640 + ((*( sm->p)) - -128));
		if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
	}
	switch( _widec ) {
		case 925: goto st1019;
		case 928: goto st1019;
		case 931: goto st1019;
		case 994: goto st1023;
		case 995: goto st1025;
		case 1007: goto st1027;
		case 1057: goto st1020;
		case 1063: goto st1020;
		case 1067: goto st1020;
		case 1119: goto st1020;
		case 1151: goto tr1271;
	}
	if ( _widec < 1013 ) {
		if ( _widec < 962 ) {
			if ( _widec > 959 ) {
				if ( 960 <= _widec && _widec <= 961 )
					goto st1020;
			} else if ( _widec >= 896 )
				goto tr1263;
		} else if ( _widec > 991 ) {
			if ( _widec > 1006 ) {
				if ( 1008 <= _widec && _widec <= 1012 )
					goto st1029;
			} else if ( _widec >= 992 )
				goto st1022;
		} else
			goto st1021;
	} else if ( _widec > 1023 ) {
		if ( _widec < 1069 ) {
			if ( _widec > 1032 ) {
				if ( 1038 <= _widec && _widec <= 1055 )
					goto tr1271;
			} else if ( _widec >= 1025 )
				goto tr1271;
		} else if ( _widec > 1071 ) {
			if ( _widec < 1089 ) {
				if ( 1072 <= _widec && _widec <= 1081 )
					goto tr1271;
			} else if ( _widec > 1114 ) {
				if ( 1121 <= _widec && _widec <= 1146 )
					goto tr1271;
			} else
				goto tr1271;
		} else
			goto st1020;
	} else
		goto st1020;
	goto tr173;
st1040:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1040;
case 1040:
	_widec = (*( sm->p));
	if ( (*( sm->p)) < 1 ) {
		if ( (*( sm->p)) < -30 ) {
			if ( (*( sm->p)) < -64 ) {
				if ( (*( sm->p)) <= -65 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > -63 ) {
				if ( (*( sm->p)) > -33 ) {
					if ( -32 <= (*( sm->p)) && (*( sm->p)) <= -31 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= -62 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else if ( (*( sm->p)) > -30 ) {
			if ( (*( sm->p)) < -17 ) {
				if ( (*( sm->p)) > -29 ) {
					if ( -28 <= (*( sm->p)) && (*( sm->p)) <= -18 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= -29 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > -17 ) {
				if ( (*( sm->p)) > -12 ) {
					if ( -11 <= (*( sm->p)) && (*( sm->p)) <= -1 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= -16 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else {
			_widec = (short)(640 + ((*( sm->p)) - -128));
			if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
		}
	} else if ( (*( sm->p)) > 8 ) {
		if ( (*( sm->p)) < 45 ) {
			if ( (*( sm->p)) < 33 ) {
				if ( 14 <= (*( sm->p)) && (*( sm->p)) <= 31 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > 33 ) {
				if ( (*( sm->p)) > 39 ) {
					if ( 43 <= (*( sm->p)) && (*( sm->p)) <= 43 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= 39 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else if ( (*( sm->p)) > 47 ) {
			if ( (*( sm->p)) < 95 ) {
				if ( (*( sm->p)) > 57 ) {
					if ( 65 <= (*( sm->p)) && (*( sm->p)) <= 90 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= 48 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > 95 ) {
				if ( (*( sm->p)) > 122 ) {
					if ( 127 <= (*( sm->p)) )
 {						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= 97 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else {
			_widec = (short)(640 + ((*( sm->p)) - -128));
			if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
		}
	} else {
		_widec = (short)(640 + ((*( sm->p)) - -128));
		if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
	}
	switch( _widec ) {
		case 994: goto st1023;
		case 995: goto st1025;
		case 1007: goto st1027;
		case 1057: goto st1020;
		case 1063: goto st1020;
		case 1067: goto st1020;
		case 1119: goto st1020;
		case 1151: goto tr1271;
	}
	if ( _widec < 1013 ) {
		if ( _widec < 962 ) {
			if ( _widec > 959 ) {
				if ( 960 <= _widec && _widec <= 961 )
					goto st1020;
			} else if ( _widec >= 896 )
				goto st1032;
		} else if ( _widec > 991 ) {
			if ( _widec > 1006 ) {
				if ( 1008 <= _widec && _widec <= 1012 )
					goto st1029;
			} else if ( _widec >= 992 )
				goto st1022;
		} else
			goto st1021;
	} else if ( _widec > 1023 ) {
		if ( _widec < 1069 ) {
			if ( _widec > 1032 ) {
				if ( 1038 <= _widec && _widec <= 1055 )
					goto tr1271;
			} else if ( _widec >= 1025 )
				goto tr1271;
		} else if ( _widec > 1071 ) {
			if ( _widec < 1089 ) {
				if ( 1072 <= _widec && _widec <= 1081 )
					goto tr1271;
			} else if ( _widec > 1114 ) {
				if ( 1121 <= _widec && _widec <= 1146 )
					goto tr1271;
			} else
				goto tr1271;
		} else
			goto st1020;
	} else
		goto st1020;
	goto tr173;
st1041:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1041;
case 1041:
	_widec = (*( sm->p));
	if ( (*( sm->p)) < 33 ) {
		if ( (*( sm->p)) < -28 ) {
			if ( (*( sm->p)) < -32 ) {
				if ( (*( sm->p)) > -63 ) {
					if ( -62 <= (*( sm->p)) && (*( sm->p)) <= -33 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > -31 ) {
				if ( (*( sm->p)) > -30 ) {
					if ( -29 <= (*( sm->p)) && (*( sm->p)) <= -29 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= -30 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else if ( (*( sm->p)) > -18 ) {
			if ( (*( sm->p)) < -11 ) {
				if ( (*( sm->p)) > -17 ) {
					if ( -16 <= (*( sm->p)) && (*( sm->p)) <= -12 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= -17 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > -1 ) {
				if ( (*( sm->p)) > 8 ) {
					if ( 14 <= (*( sm->p)) && (*( sm->p)) <= 31 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= 1 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else {
			_widec = (short)(640 + ((*( sm->p)) - -128));
			if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
		}
	} else if ( (*( sm->p)) > 33 ) {
		if ( (*( sm->p)) < 95 ) {
			if ( (*( sm->p)) < 45 ) {
				if ( (*( sm->p)) > 39 ) {
					if ( 43 <= (*( sm->p)) && (*( sm->p)) <= 43 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= 39 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > 47 ) {
				if ( (*( sm->p)) > 57 ) {
					if ( 65 <= (*( sm->p)) && (*( sm->p)) <= 90 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= 48 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else if ( (*( sm->p)) > 95 ) {
			if ( (*( sm->p)) < 101 ) {
				if ( (*( sm->p)) > 99 ) {
					if ( 100 <= (*( sm->p)) && (*( sm->p)) <= 100 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) >= 97 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > 114 ) {
				if ( (*( sm->p)) < 116 ) {
					if ( 115 <= (*( sm->p)) && (*( sm->p)) <= 115 ) {
						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else if ( (*( sm->p)) > 122 ) {
					if ( 127 <= (*( sm->p)) )
 {						_widec = (short)(640 + ((*( sm->p)) - -128));
						if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
					}
				} else {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else {
			_widec = (short)(640 + ((*( sm->p)) - -128));
			if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
		}
	} else {
		_widec = (short)(640 + ((*( sm->p)) - -128));
		if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
	}
	switch( _widec ) {
		case 994: goto st1033;
		case 995: goto st1035;
		case 1007: goto st1037;
		case 1057: goto st1019;
		case 1063: goto st1041;
		case 1067: goto st1019;
		case 1119: goto st1019;
		case 1124: goto st1019;
		case 1139: goto st1019;
		case 1151: goto tr1263;
	}
	if ( _widec < 1025 ) {
		if ( _widec < 992 ) {
			if ( _widec > 961 ) {
				if ( 962 <= _widec && _widec <= 991 )
					goto st1031;
			} else if ( _widec >= 896 )
				goto st1020;
		} else if ( _widec > 1006 ) {
			if ( _widec > 1012 ) {
				if ( 1013 <= _widec && _widec <= 1023 )
					goto st1020;
			} else if ( _widec >= 1008 )
				goto st1040;
		} else
			goto st1032;
	} else if ( _widec > 1032 ) {
		if ( _widec < 1072 ) {
			if ( _widec > 1055 ) {
				if ( 1069 <= _widec && _widec <= 1071 )
					goto st1019;
			} else if ( _widec >= 1038 )
				goto tr1263;
		} else if ( _widec > 1081 ) {
			if ( _widec > 1114 ) {
				if ( 1121 <= _widec && _widec <= 1146 )
					goto tr1263;
			} else if ( _widec >= 1089 )
				goto tr1263;
		} else
			goto tr1263;
	} else
		goto tr1263;
	goto tr173;
tr2114:
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st1042;
st1042:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1042;
case 1042:
#line 27340 "ext/dtext/dtext.cpp"
	_widec = (*( sm->p));
	if ( (*( sm->p)) <= -65 ) {
		_widec = (short)(640 + ((*( sm->p)) - -128));
		if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
	}
	if ( 896 <= _widec && _widec <= 959 )
		goto st1018;
	goto tr180;
tr2115:
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st1043;
st1043:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1043;
case 1043:
#line 27356 "ext/dtext/dtext.cpp"
	_widec = (*( sm->p));
	if ( (*( sm->p)) < -99 ) {
		if ( (*( sm->p)) <= -100 ) {
			_widec = (short)(640 + ((*( sm->p)) - -128));
			if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
		}
	} else if ( (*( sm->p)) > -99 ) {
		if ( -98 <= (*( sm->p)) && (*( sm->p)) <= -65 ) {
			_widec = (short)(640 + ((*( sm->p)) - -128));
			if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
		}
	} else {
		_widec = (short)(640 + ((*( sm->p)) - -128));
		if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
	}
	if ( _widec == 925 )
		goto st1044;
	if ( 896 <= _widec && _widec <= 959 )
		goto st1018;
	goto tr180;
st1044:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1044;
case 1044:
	_widec = (*( sm->p));
	if ( (*( sm->p)) > -84 ) {
		if ( -82 <= (*( sm->p)) && (*( sm->p)) <= -65 ) {
			_widec = (short)(640 + ((*( sm->p)) - -128));
			if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
		}
	} else {
		_widec = (short)(640 + ((*( sm->p)) - -128));
		if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
	}
	if ( _widec > 940 ) {
		if ( 942 <= _widec && _widec <= 959 )
			goto st1019;
	} else if ( _widec >= 896 )
		goto st1019;
	goto tr180;
tr2116:
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st1045;
st1045:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1045;
case 1045:
#line 27408 "ext/dtext/dtext.cpp"
	_widec = (*( sm->p));
	if ( (*( sm->p)) > -128 ) {
		if ( -127 <= (*( sm->p)) && (*( sm->p)) <= -65 ) {
			_widec = (short)(640 + ((*( sm->p)) - -128));
			if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
		}
	} else {
		_widec = (short)(640 + ((*( sm->p)) - -128));
		if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
	}
	if ( _widec == 896 )
		goto st1046;
	if ( 897 <= _widec && _widec <= 959 )
		goto st1018;
	goto tr180;
st1046:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1046;
case 1046:
	_widec = (*( sm->p));
	if ( (*( sm->p)) < -110 ) {
		if ( -125 <= (*( sm->p)) && (*( sm->p)) <= -121 ) {
			_widec = (short)(640 + ((*( sm->p)) - -128));
			if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
		}
	} else if ( (*( sm->p)) > -109 ) {
		if ( -99 <= (*( sm->p)) && (*( sm->p)) <= -65 ) {
			_widec = (short)(640 + ((*( sm->p)) - -128));
			if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
		}
	} else {
		_widec = (short)(640 + ((*( sm->p)) - -128));
		if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
	}
	if ( _widec < 914 ) {
		if ( 899 <= _widec && _widec <= 903 )
			goto st1019;
	} else if ( _widec > 915 ) {
		if ( 925 <= _widec && _widec <= 959 )
			goto st1019;
	} else
		goto st1019;
	goto tr180;
tr2117:
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st1047;
st1047:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1047;
case 1047:
#line 27463 "ext/dtext/dtext.cpp"
	_widec = (*( sm->p));
	if ( (*( sm->p)) < -68 ) {
		if ( (*( sm->p)) <= -69 ) {
			_widec = (short)(640 + ((*( sm->p)) - -128));
			if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
		}
	} else if ( (*( sm->p)) > -68 ) {
		if ( (*( sm->p)) > -67 ) {
			if ( -66 <= (*( sm->p)) && (*( sm->p)) <= -65 ) {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else if ( (*( sm->p)) >= -67 ) {
			_widec = (short)(640 + ((*( sm->p)) - -128));
			if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
		}
	} else {
		_widec = (short)(640 + ((*( sm->p)) - -128));
		if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
	}
	switch( _widec ) {
		case 956: goto st1048;
		case 957: goto st1049;
	}
	if ( 896 <= _widec && _widec <= 959 )
		goto st1018;
	goto tr180;
st1048:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1048;
case 1048:
	_widec = (*( sm->p));
	if ( (*( sm->p)) < -118 ) {
		if ( (*( sm->p)) <= -120 ) {
			_widec = (short)(640 + ((*( sm->p)) - -128));
			if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
		}
	} else if ( (*( sm->p)) > -68 ) {
		if ( -66 <= (*( sm->p)) && (*( sm->p)) <= -65 ) {
			_widec = (short)(640 + ((*( sm->p)) - -128));
			if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
		}
	} else {
		_widec = (short)(640 + ((*( sm->p)) - -128));
		if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
	}
	if ( _widec < 906 ) {
		if ( 896 <= _widec && _widec <= 904 )
			goto st1019;
	} else if ( _widec > 956 ) {
		if ( 958 <= _widec && _widec <= 959 )
			goto st1019;
	} else
		goto st1019;
	goto tr180;
st1049:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1049;
case 1049:
	_widec = (*( sm->p));
	if ( (*( sm->p)) < -98 ) {
		if ( (*( sm->p)) <= -100 ) {
			_widec = (short)(640 + ((*( sm->p)) - -128));
			if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
		}
	} else if ( (*( sm->p)) > -97 ) {
		if ( (*( sm->p)) > -94 ) {
			if ( -92 <= (*( sm->p)) && (*( sm->p)) <= -65 ) {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else if ( (*( sm->p)) >= -95 ) {
			_widec = (short)(640 + ((*( sm->p)) - -128));
			if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
		}
	} else {
		_widec = (short)(640 + ((*( sm->p)) - -128));
		if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
	}
	if ( _widec < 926 ) {
		if ( 896 <= _widec && _widec <= 924 )
			goto st1019;
	} else if ( _widec > 927 ) {
		if ( _widec > 930 ) {
			if ( 932 <= _widec && _widec <= 959 )
				goto st1019;
		} else if ( _widec >= 929 )
			goto st1019;
	} else
		goto st1019;
	goto tr180;
tr2118:
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st1050;
st1050:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1050;
case 1050:
#line 27572 "ext/dtext/dtext.cpp"
	_widec = (*( sm->p));
	if ( (*( sm->p)) <= -65 ) {
		_widec = (short)(640 + ((*( sm->p)) - -128));
		if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
	}
	if ( 896 <= _widec && _widec <= 959 )
		goto st1042;
	goto tr180;
tr2120:
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st1051;
st1051:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1051;
case 1051:
#line 27588 "ext/dtext/dtext.cpp"
	_widec = (*( sm->p));
	if ( (*( sm->p)) < -16 ) {
		if ( (*( sm->p)) < -30 ) {
			if ( (*( sm->p)) > -33 ) {
				if ( -32 <= (*( sm->p)) && (*( sm->p)) <= -31 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) >= -62 ) {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else if ( (*( sm->p)) > -30 ) {
			if ( (*( sm->p)) < -28 ) {
				if ( -29 <= (*( sm->p)) && (*( sm->p)) <= -29 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > -18 ) {
				if ( -17 <= (*( sm->p)) && (*( sm->p)) <= -17 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else {
			_widec = (short)(640 + ((*( sm->p)) - -128));
			if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
		}
	} else if ( (*( sm->p)) > -12 ) {
		if ( (*( sm->p)) < 48 ) {
			if ( (*( sm->p)) > 8 ) {
				if ( 14 <= (*( sm->p)) && (*( sm->p)) <= 31 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) >= 1 ) {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else if ( (*( sm->p)) > 57 ) {
			if ( (*( sm->p)) < 97 ) {
				if ( 65 <= (*( sm->p)) && (*( sm->p)) <= 90 ) {
					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else if ( (*( sm->p)) > 122 ) {
				if ( 127 <= (*( sm->p)) )
 {					_widec = (short)(640 + ((*( sm->p)) - -128));
					if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
				}
			} else {
				_widec = (short)(640 + ((*( sm->p)) - -128));
				if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
			}
		} else {
			_widec = (short)(640 + ((*( sm->p)) - -128));
			if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
		}
	} else {
		_widec = (short)(640 + ((*( sm->p)) - -128));
		if ( 
#line 87 "ext/dtext/dtext.cpp.rl"
 sm->options.f_mentions  ) _widec += 256;
	}
	switch( _widec ) {
		case 994: goto st1043;
		case 995: goto st1045;
		case 1007: goto st1047;
		case 1151: goto st1019;
	}
	if ( _widec < 1025 ) {
		if ( _widec < 992 ) {
			if ( 962 <= _widec && _widec <= 991 )
				goto st1018;
		} else if ( _widec > 1006 ) {
			if ( 1008 <= _widec && _widec <= 1012 )
				goto st1050;
		} else
			goto st1042;
	} else if ( _widec > 1032 ) {
		if ( _widec < 1072 ) {
			if ( 1038 <= _widec && _widec <= 1055 )
				goto st1019;
		} else if ( _widec > 1081 ) {
			if ( _widec > 1114 ) {
				if ( 1121 <= _widec && _widec <= 1146 )
					goto st1019;
			} else if ( _widec >= 1089 )
				goto st1019;
		} else
			goto st1019;
	} else
		goto st1019;
	goto tr180;
tr1290:
#line 592 "ext/dtext/dtext.cpp.rl"
	{{( sm->p) = ((( sm->te)))-1;}{
    append_html_escaped(sm, (*( sm->p)));
  }}
	goto st1605;
tr1296:
#line 585 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_rewind(sm);
    { sm->cs = ( (sm->stack.data()))[--( sm->top)];goto _again;}
  }}
	goto st1605;
tr2122:
#line 592 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{
    append_html_escaped(sm, (*( sm->p)));
  }}
	goto st1605;
tr2123:
#line 590 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;}
	goto st1605;
tr2127:
#line 592 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append_html_escaped(sm, (*( sm->p)));
  }}
	goto st1605;
st1605:
#line 1 "NONE"
	{( sm->ts) = 0;}
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1605;
case 1605:
#line 1 "NONE"
	{( sm->ts) = ( sm->p);}
#line 27726 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr2123;
		case 10: goto tr2124;
		case 60: goto tr2125;
		case 91: goto tr2126;
	}
	goto tr2122;
tr2124:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
	goto st1606;
st1606:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1606;
case 1606:
#line 27740 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 60: goto st1052;
		case 91: goto st1058;
	}
	goto tr2127;
st1052:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1052;
case 1052:
	if ( (*( sm->p)) == 47 )
		goto st1053;
	goto tr1290;
st1053:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1053;
case 1053:
	switch( (*( sm->p)) ) {
		case 67: goto st1054;
		case 99: goto st1054;
	}
	goto tr1290;
st1054:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1054;
case 1054:
	switch( (*( sm->p)) ) {
		case 79: goto st1055;
		case 111: goto st1055;
	}
	goto tr1290;
st1055:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1055;
case 1055:
	switch( (*( sm->p)) ) {
		case 68: goto st1056;
		case 100: goto st1056;
	}
	goto tr1290;
st1056:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1056;
case 1056:
	switch( (*( sm->p)) ) {
		case 69: goto st1057;
		case 101: goto st1057;
	}
	goto tr1290;
st1057:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1057;
case 1057:
	if ( (*( sm->p)) == 62 )
		goto tr1296;
	goto tr1290;
st1058:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1058;
case 1058:
	if ( (*( sm->p)) == 47 )
		goto st1059;
	goto tr1290;
st1059:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1059;
case 1059:
	switch( (*( sm->p)) ) {
		case 67: goto st1060;
		case 99: goto st1060;
	}
	goto tr1290;
st1060:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1060;
case 1060:
	switch( (*( sm->p)) ) {
		case 79: goto st1061;
		case 111: goto st1061;
	}
	goto tr1290;
st1061:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1061;
case 1061:
	switch( (*( sm->p)) ) {
		case 68: goto st1062;
		case 100: goto st1062;
	}
	goto tr1290;
st1062:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1062;
case 1062:
	switch( (*( sm->p)) ) {
		case 69: goto st1063;
		case 101: goto st1063;
	}
	goto tr1290;
st1063:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1063;
case 1063:
	if ( (*( sm->p)) == 93 )
		goto tr1296;
	goto tr1290;
tr2125:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
	goto st1607;
st1607:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1607;
case 1607:
#line 27852 "ext/dtext/dtext.cpp"
	if ( (*( sm->p)) == 47 )
		goto st1053;
	goto tr2127;
tr2126:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
	goto st1608;
st1608:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1608;
case 1608:
#line 27862 "ext/dtext/dtext.cpp"
	if ( (*( sm->p)) == 47 )
		goto st1059;
	goto tr2127;
tr1302:
#line 605 "ext/dtext/dtext.cpp.rl"
	{{( sm->p) = ((( sm->te)))-1;}{
    append_html_escaped(sm, (*( sm->p)));
  }}
	goto st1609;
tr1311:
#line 598 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_rewind(sm);
    { sm->cs = ( (sm->stack.data()))[--( sm->top)];goto _again;}
  }}
	goto st1609;
tr2130:
#line 605 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{
    append_html_escaped(sm, (*( sm->p)));
  }}
	goto st1609;
tr2131:
#line 603 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;}
	goto st1609;
tr2135:
#line 605 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;{
    append_html_escaped(sm, (*( sm->p)));
  }}
	goto st1609;
st1609:
#line 1 "NONE"
	{( sm->ts) = 0;}
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1609;
case 1609:
#line 1 "NONE"
	{( sm->ts) = ( sm->p);}
#line 27895 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr2131;
		case 10: goto tr2132;
		case 60: goto tr2133;
		case 91: goto tr2134;
	}
	goto tr2130;
tr2132:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
	goto st1610;
st1610:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1610;
case 1610:
#line 27909 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 60: goto st1064;
		case 91: goto st1073;
	}
	goto tr2135;
st1064:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1064;
case 1064:
	if ( (*( sm->p)) == 47 )
		goto st1065;
	goto tr1302;
st1065:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1065;
case 1065:
	switch( (*( sm->p)) ) {
		case 78: goto st1066;
		case 110: goto st1066;
	}
	goto tr1302;
st1066:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1066;
case 1066:
	switch( (*( sm->p)) ) {
		case 79: goto st1067;
		case 111: goto st1067;
	}
	goto tr1302;
st1067:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1067;
case 1067:
	switch( (*( sm->p)) ) {
		case 68: goto st1068;
		case 100: goto st1068;
	}
	goto tr1302;
st1068:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1068;
case 1068:
	switch( (*( sm->p)) ) {
		case 84: goto st1069;
		case 116: goto st1069;
	}
	goto tr1302;
st1069:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1069;
case 1069:
	switch( (*( sm->p)) ) {
		case 69: goto st1070;
		case 101: goto st1070;
	}
	goto tr1302;
st1070:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1070;
case 1070:
	switch( (*( sm->p)) ) {
		case 88: goto st1071;
		case 120: goto st1071;
	}
	goto tr1302;
st1071:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1071;
case 1071:
	switch( (*( sm->p)) ) {
		case 84: goto st1072;
		case 116: goto st1072;
	}
	goto tr1302;
st1072:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1072;
case 1072:
	if ( (*( sm->p)) == 62 )
		goto tr1311;
	goto tr1302;
st1073:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1073;
case 1073:
	if ( (*( sm->p)) == 47 )
		goto st1074;
	goto tr1302;
st1074:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1074;
case 1074:
	switch( (*( sm->p)) ) {
		case 78: goto st1075;
		case 110: goto st1075;
	}
	goto tr1302;
st1075:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1075;
case 1075:
	switch( (*( sm->p)) ) {
		case 79: goto st1076;
		case 111: goto st1076;
	}
	goto tr1302;
st1076:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1076;
case 1076:
	switch( (*( sm->p)) ) {
		case 68: goto st1077;
		case 100: goto st1077;
	}
	goto tr1302;
st1077:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1077;
case 1077:
	switch( (*( sm->p)) ) {
		case 84: goto st1078;
		case 116: goto st1078;
	}
	goto tr1302;
st1078:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1078;
case 1078:
	switch( (*( sm->p)) ) {
		case 69: goto st1079;
		case 101: goto st1079;
	}
	goto tr1302;
st1079:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1079;
case 1079:
	switch( (*( sm->p)) ) {
		case 88: goto st1080;
		case 120: goto st1080;
	}
	goto tr1302;
st1080:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1080;
case 1080:
	switch( (*( sm->p)) ) {
		case 84: goto st1081;
		case 116: goto st1081;
	}
	goto tr1302;
st1081:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1081;
case 1081:
	if ( (*( sm->p)) == 93 )
		goto tr1311;
	goto tr1302;
tr2133:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
	goto st1611;
st1611:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1611;
case 1611:
#line 28075 "ext/dtext/dtext.cpp"
	if ( (*( sm->p)) == 47 )
		goto st1065;
	goto tr2135;
tr2134:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
	goto st1612;
st1612:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1612;
case 1612:
#line 28085 "ext/dtext/dtext.cpp"
	if ( (*( sm->p)) == 47 )
		goto st1074;
	goto tr2135;
tr1320:
#line 664 "ext/dtext/dtext.cpp.rl"
	{{( sm->p) = ((( sm->te)))-1;}}
	goto st1613;
tr1330:
#line 615 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_close_element(sm, BLOCK_COLGROUP);
  }}
	goto st1613;
tr1338:
#line 658 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{
    if (dstack_close_element(sm, BLOCK_TABLE)) {
      { sm->cs = ( (sm->stack.data()))[--( sm->top)];goto _again;}
    }
  }}
	goto st1613;
tr1342:
#line 636 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_close_element(sm, BLOCK_TBODY);
  }}
	goto st1613;
tr1346:
#line 628 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_close_element(sm, BLOCK_THEAD);
  }}
	goto st1613;
tr1347:
#line 649 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_close_element(sm, BLOCK_TR);
  }}
	goto st1613;
tr1351:
#line 619 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_open_element(sm, BLOCK_COL, "col", sm->tag_attributes);
    dstack_pop(sm); // XXX [col] has no end tag
  }}
	goto st1613;
tr1366:
#line 90 "ext/dtext/dtext.cpp.rl"
	{ save_tag_attribute(sm, { sm->a1, sm->a2 }, { sm->b1, sm->b2 }); }
#line 619 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_open_element(sm, BLOCK_COL, "col", sm->tag_attributes);
    dstack_pop(sm); // XXX [col] has no end tag
  }}
	goto st1613;
tr1371:
#line 74 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
#line 90 "ext/dtext/dtext.cpp.rl"
	{ save_tag_attribute(sm, { sm->a1, sm->a2 }, { sm->b1, sm->b2 }); }
#line 619 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_open_element(sm, BLOCK_COL, "col", sm->tag_attributes);
    dstack_pop(sm); // XXX [col] has no end tag
  }}
	goto st1613;
tr1377:
#line 611 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_open_element(sm, BLOCK_COLGROUP, "colgroup", sm->tag_attributes);
  }}
	goto st1613;
tr1391:
#line 90 "ext/dtext/dtext.cpp.rl"
	{ save_tag_attribute(sm, { sm->a1, sm->a2 }, { sm->b1, sm->b2 }); }
#line 611 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_open_element(sm, BLOCK_COLGROUP, "colgroup", sm->tag_attributes);
  }}
	goto st1613;
tr1396:
#line 74 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
#line 90 "ext/dtext/dtext.cpp.rl"
	{ save_tag_attribute(sm, { sm->a1, sm->a2 }, { sm->b1, sm->b2 }); }
#line 611 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_open_element(sm, BLOCK_COLGROUP, "colgroup", sm->tag_attributes);
  }}
	goto st1613;
tr1405:
#line 632 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_open_element(sm, BLOCK_TBODY, "tbody", sm->tag_attributes);
  }}
	goto st1613;
tr1419:
#line 90 "ext/dtext/dtext.cpp.rl"
	{ save_tag_attribute(sm, { sm->a1, sm->a2 }, { sm->b1, sm->b2 }); }
#line 632 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_open_element(sm, BLOCK_TBODY, "tbody", sm->tag_attributes);
  }}
	goto st1613;
tr1424:
#line 74 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
#line 90 "ext/dtext/dtext.cpp.rl"
	{ save_tag_attribute(sm, { sm->a1, sm->a2 }, { sm->b1, sm->b2 }); }
#line 632 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_open_element(sm, BLOCK_TBODY, "tbody", sm->tag_attributes);
  }}
	goto st1613;
tr1426:
#line 653 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_open_element(sm, BLOCK_TD, "td", sm->tag_attributes);
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
{( (sm->stack.data()))[( sm->top)++] = 1613;goto st1328;}}
  }}
	goto st1613;
tr1440:
#line 90 "ext/dtext/dtext.cpp.rl"
	{ save_tag_attribute(sm, { sm->a1, sm->a2 }, { sm->b1, sm->b2 }); }
#line 653 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_open_element(sm, BLOCK_TD, "td", sm->tag_attributes);
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
{( (sm->stack.data()))[( sm->top)++] = 1613;goto st1328;}}
  }}
	goto st1613;
tr1445:
#line 74 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
#line 90 "ext/dtext/dtext.cpp.rl"
	{ save_tag_attribute(sm, { sm->a1, sm->a2 }, { sm->b1, sm->b2 }); }
#line 653 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_open_element(sm, BLOCK_TD, "td", sm->tag_attributes);
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
{( (sm->stack.data()))[( sm->top)++] = 1613;goto st1328;}}
  }}
	goto st1613;
tr1447:
#line 640 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_open_element(sm, BLOCK_TH, "th", sm->tag_attributes);
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
{( (sm->stack.data()))[( sm->top)++] = 1613;goto st1328;}}
  }}
	goto st1613;
tr1462:
#line 90 "ext/dtext/dtext.cpp.rl"
	{ save_tag_attribute(sm, { sm->a1, sm->a2 }, { sm->b1, sm->b2 }); }
#line 640 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_open_element(sm, BLOCK_TH, "th", sm->tag_attributes);
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
{( (sm->stack.data()))[( sm->top)++] = 1613;goto st1328;}}
  }}
	goto st1613;
tr1467:
#line 74 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
#line 90 "ext/dtext/dtext.cpp.rl"
	{ save_tag_attribute(sm, { sm->a1, sm->a2 }, { sm->b1, sm->b2 }); }
#line 640 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_open_element(sm, BLOCK_TH, "th", sm->tag_attributes);
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
{( (sm->stack.data()))[( sm->top)++] = 1613;goto st1328;}}
  }}
	goto st1613;
tr1471:
#line 624 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_open_element(sm, BLOCK_THEAD, "thead", sm->tag_attributes);
  }}
	goto st1613;
tr1485:
#line 90 "ext/dtext/dtext.cpp.rl"
	{ save_tag_attribute(sm, { sm->a1, sm->a2 }, { sm->b1, sm->b2 }); }
#line 624 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_open_element(sm, BLOCK_THEAD, "thead", sm->tag_attributes);
  }}
	goto st1613;
tr1490:
#line 74 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
#line 90 "ext/dtext/dtext.cpp.rl"
	{ save_tag_attribute(sm, { sm->a1, sm->a2 }, { sm->b1, sm->b2 }); }
#line 624 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_open_element(sm, BLOCK_THEAD, "thead", sm->tag_attributes);
  }}
	goto st1613;
tr1492:
#line 645 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_open_element(sm, BLOCK_TR, "tr", sm->tag_attributes);
  }}
	goto st1613;
tr1506:
#line 90 "ext/dtext/dtext.cpp.rl"
	{ save_tag_attribute(sm, { sm->a1, sm->a2 }, { sm->b1, sm->b2 }); }
#line 645 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_open_element(sm, BLOCK_TR, "tr", sm->tag_attributes);
  }}
	goto st1613;
tr1511:
#line 74 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
#line 90 "ext/dtext/dtext.cpp.rl"
	{ save_tag_attribute(sm, { sm->a1, sm->a2 }, { sm->b1, sm->b2 }); }
#line 645 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;{
    dstack_open_element(sm, BLOCK_TR, "tr", sm->tag_attributes);
  }}
	goto st1613;
tr2138:
#line 664 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p)+1;}
	goto st1613;
tr2141:
#line 664 "ext/dtext/dtext.cpp.rl"
	{( sm->te) = ( sm->p);( sm->p)--;}
	goto st1613;
st1613:
#line 1 "NONE"
	{( sm->ts) = 0;}
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1613;
case 1613:
#line 1 "NONE"
	{( sm->ts) = ( sm->p);}
#line 28337 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 60: goto tr2139;
		case 91: goto tr2140;
	}
	goto tr2138;
tr2139:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
	goto st1614;
st1614:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1614;
case 1614:
#line 28349 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 47: goto st1082;
		case 67: goto st1105;
		case 84: goto st1133;
		case 99: goto st1105;
		case 116: goto st1133;
	}
	goto tr2141;
st1082:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1082;
case 1082:
	switch( (*( sm->p)) ) {
		case 67: goto st1083;
		case 84: goto st1091;
		case 99: goto st1083;
		case 116: goto st1091;
	}
	goto tr1320;
st1083:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1083;
case 1083:
	switch( (*( sm->p)) ) {
		case 79: goto st1084;
		case 111: goto st1084;
	}
	goto tr1320;
st1084:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1084;
case 1084:
	switch( (*( sm->p)) ) {
		case 76: goto st1085;
		case 108: goto st1085;
	}
	goto tr1320;
st1085:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1085;
case 1085:
	switch( (*( sm->p)) ) {
		case 71: goto st1086;
		case 103: goto st1086;
	}
	goto tr1320;
st1086:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1086;
case 1086:
	switch( (*( sm->p)) ) {
		case 82: goto st1087;
		case 114: goto st1087;
	}
	goto tr1320;
st1087:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1087;
case 1087:
	switch( (*( sm->p)) ) {
		case 79: goto st1088;
		case 111: goto st1088;
	}
	goto tr1320;
st1088:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1088;
case 1088:
	switch( (*( sm->p)) ) {
		case 85: goto st1089;
		case 117: goto st1089;
	}
	goto tr1320;
st1089:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1089;
case 1089:
	switch( (*( sm->p)) ) {
		case 80: goto st1090;
		case 112: goto st1090;
	}
	goto tr1320;
st1090:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1090;
case 1090:
	if ( (*( sm->p)) == 62 )
		goto tr1330;
	goto tr1320;
st1091:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1091;
case 1091:
	switch( (*( sm->p)) ) {
		case 65: goto st1092;
		case 66: goto st1096;
		case 72: goto st1100;
		case 82: goto st1104;
		case 97: goto st1092;
		case 98: goto st1096;
		case 104: goto st1100;
		case 114: goto st1104;
	}
	goto tr1320;
st1092:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1092;
case 1092:
	switch( (*( sm->p)) ) {
		case 66: goto st1093;
		case 98: goto st1093;
	}
	goto tr1320;
st1093:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1093;
case 1093:
	switch( (*( sm->p)) ) {
		case 76: goto st1094;
		case 108: goto st1094;
	}
	goto tr1320;
st1094:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1094;
case 1094:
	switch( (*( sm->p)) ) {
		case 69: goto st1095;
		case 101: goto st1095;
	}
	goto tr1320;
st1095:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1095;
case 1095:
	if ( (*( sm->p)) == 62 )
		goto tr1338;
	goto tr1320;
st1096:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1096;
case 1096:
	switch( (*( sm->p)) ) {
		case 79: goto st1097;
		case 111: goto st1097;
	}
	goto tr1320;
st1097:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1097;
case 1097:
	switch( (*( sm->p)) ) {
		case 68: goto st1098;
		case 100: goto st1098;
	}
	goto tr1320;
st1098:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1098;
case 1098:
	switch( (*( sm->p)) ) {
		case 89: goto st1099;
		case 121: goto st1099;
	}
	goto tr1320;
st1099:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1099;
case 1099:
	if ( (*( sm->p)) == 62 )
		goto tr1342;
	goto tr1320;
st1100:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1100;
case 1100:
	switch( (*( sm->p)) ) {
		case 69: goto st1101;
		case 101: goto st1101;
	}
	goto tr1320;
st1101:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1101;
case 1101:
	switch( (*( sm->p)) ) {
		case 65: goto st1102;
		case 97: goto st1102;
	}
	goto tr1320;
st1102:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1102;
case 1102:
	switch( (*( sm->p)) ) {
		case 68: goto st1103;
		case 100: goto st1103;
	}
	goto tr1320;
st1103:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1103;
case 1103:
	if ( (*( sm->p)) == 62 )
		goto tr1346;
	goto tr1320;
st1104:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1104;
case 1104:
	if ( (*( sm->p)) == 62 )
		goto tr1347;
	goto tr1320;
st1105:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1105;
case 1105:
	switch( (*( sm->p)) ) {
		case 79: goto st1106;
		case 111: goto st1106;
	}
	goto tr1320;
st1106:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1106;
case 1106:
	switch( (*( sm->p)) ) {
		case 76: goto st1107;
		case 108: goto st1107;
	}
	goto tr1320;
st1107:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1107;
case 1107:
	switch( (*( sm->p)) ) {
		case 9: goto st1108;
		case 32: goto st1108;
		case 62: goto tr1351;
		case 71: goto st1118;
		case 103: goto st1118;
	}
	goto tr1320;
tr1365:
#line 90 "ext/dtext/dtext.cpp.rl"
	{ save_tag_attribute(sm, { sm->a1, sm->a2 }, { sm->b1, sm->b2 }); }
	goto st1108;
tr1369:
#line 74 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
#line 90 "ext/dtext/dtext.cpp.rl"
	{ save_tag_attribute(sm, { sm->a1, sm->a2 }, { sm->b1, sm->b2 }); }
	goto st1108;
st1108:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1108;
case 1108:
#line 28603 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto st1108;
		case 32: goto st1108;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1353;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1353;
	} else
		goto tr1353;
	goto tr1320;
tr1353:
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st1109;
st1109:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1109;
case 1109:
#line 28623 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto tr1354;
		case 32: goto tr1354;
		case 61: goto tr1356;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st1109;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st1109;
	} else
		goto st1109;
	goto tr1320;
tr1354:
#line 72 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
	goto st1110;
st1110:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1110;
case 1110:
#line 28644 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto st1110;
		case 32: goto st1110;
		case 61: goto st1111;
	}
	goto tr1320;
tr1356:
#line 72 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
	goto st1111;
st1111:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1111;
case 1111:
#line 28657 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto st1111;
		case 32: goto st1111;
		case 34: goto st1112;
		case 39: goto st1115;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1361;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1361;
	} else
		goto tr1361;
	goto tr1320;
st1112:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1112;
case 1112:
	switch( (*( sm->p)) ) {
		case 0: goto tr1320;
		case 10: goto tr1320;
		case 13: goto tr1320;
	}
	goto tr1362;
tr1362:
#line 73 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st1113;
st1113:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1113;
case 1113:
#line 28689 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr1320;
		case 10: goto tr1320;
		case 13: goto tr1320;
		case 34: goto tr1364;
	}
	goto st1113;
tr1364:
#line 74 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
	goto st1114;
st1114:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1114;
case 1114:
#line 28703 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto tr1365;
		case 32: goto tr1365;
		case 62: goto tr1366;
	}
	goto tr1320;
st1115:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1115;
case 1115:
	switch( (*( sm->p)) ) {
		case 0: goto tr1320;
		case 10: goto tr1320;
		case 13: goto tr1320;
	}
	goto tr1367;
tr1367:
#line 73 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st1116;
st1116:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1116;
case 1116:
#line 28726 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr1320;
		case 10: goto tr1320;
		case 13: goto tr1320;
		case 39: goto tr1364;
	}
	goto st1116;
tr1361:
#line 73 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st1117;
st1117:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1117;
case 1117:
#line 28740 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto tr1369;
		case 32: goto tr1369;
		case 62: goto tr1371;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st1117;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st1117;
	} else
		goto st1117;
	goto tr1320;
st1118:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1118;
case 1118:
	switch( (*( sm->p)) ) {
		case 82: goto st1119;
		case 114: goto st1119;
	}
	goto tr1320;
st1119:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1119;
case 1119:
	switch( (*( sm->p)) ) {
		case 79: goto st1120;
		case 111: goto st1120;
	}
	goto tr1320;
st1120:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1120;
case 1120:
	switch( (*( sm->p)) ) {
		case 85: goto st1121;
		case 117: goto st1121;
	}
	goto tr1320;
st1121:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1121;
case 1121:
	switch( (*( sm->p)) ) {
		case 80: goto st1122;
		case 112: goto st1122;
	}
	goto tr1320;
st1122:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1122;
case 1122:
	switch( (*( sm->p)) ) {
		case 9: goto st1123;
		case 32: goto st1123;
		case 62: goto tr1377;
	}
	goto tr1320;
tr1390:
#line 90 "ext/dtext/dtext.cpp.rl"
	{ save_tag_attribute(sm, { sm->a1, sm->a2 }, { sm->b1, sm->b2 }); }
	goto st1123;
tr1394:
#line 74 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
#line 90 "ext/dtext/dtext.cpp.rl"
	{ save_tag_attribute(sm, { sm->a1, sm->a2 }, { sm->b1, sm->b2 }); }
	goto st1123;
st1123:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1123;
case 1123:
#line 28811 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto st1123;
		case 32: goto st1123;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1378;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1378;
	} else
		goto tr1378;
	goto tr1320;
tr1378:
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st1124;
st1124:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1124;
case 1124:
#line 28831 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto tr1379;
		case 32: goto tr1379;
		case 61: goto tr1381;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st1124;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st1124;
	} else
		goto st1124;
	goto tr1320;
tr1379:
#line 72 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
	goto st1125;
st1125:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1125;
case 1125:
#line 28852 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto st1125;
		case 32: goto st1125;
		case 61: goto st1126;
	}
	goto tr1320;
tr1381:
#line 72 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
	goto st1126;
st1126:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1126;
case 1126:
#line 28865 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto st1126;
		case 32: goto st1126;
		case 34: goto st1127;
		case 39: goto st1130;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1386;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1386;
	} else
		goto tr1386;
	goto tr1320;
st1127:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1127;
case 1127:
	switch( (*( sm->p)) ) {
		case 0: goto tr1320;
		case 10: goto tr1320;
		case 13: goto tr1320;
	}
	goto tr1387;
tr1387:
#line 73 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st1128;
st1128:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1128;
case 1128:
#line 28897 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr1320;
		case 10: goto tr1320;
		case 13: goto tr1320;
		case 34: goto tr1389;
	}
	goto st1128;
tr1389:
#line 74 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
	goto st1129;
st1129:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1129;
case 1129:
#line 28911 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto tr1390;
		case 32: goto tr1390;
		case 62: goto tr1391;
	}
	goto tr1320;
st1130:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1130;
case 1130:
	switch( (*( sm->p)) ) {
		case 0: goto tr1320;
		case 10: goto tr1320;
		case 13: goto tr1320;
	}
	goto tr1392;
tr1392:
#line 73 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st1131;
st1131:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1131;
case 1131:
#line 28934 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr1320;
		case 10: goto tr1320;
		case 13: goto tr1320;
		case 39: goto tr1389;
	}
	goto st1131;
tr1386:
#line 73 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st1132;
st1132:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1132;
case 1132:
#line 28948 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto tr1394;
		case 32: goto tr1394;
		case 62: goto tr1396;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st1132;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st1132;
	} else
		goto st1132;
	goto tr1320;
st1133:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1133;
case 1133:
	switch( (*( sm->p)) ) {
		case 66: goto st1134;
		case 68: goto st1148;
		case 72: goto st1159;
		case 82: goto st1183;
		case 98: goto st1134;
		case 100: goto st1148;
		case 104: goto st1159;
		case 114: goto st1183;
	}
	goto tr1320;
st1134:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1134;
case 1134:
	switch( (*( sm->p)) ) {
		case 79: goto st1135;
		case 111: goto st1135;
	}
	goto tr1320;
st1135:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1135;
case 1135:
	switch( (*( sm->p)) ) {
		case 68: goto st1136;
		case 100: goto st1136;
	}
	goto tr1320;
st1136:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1136;
case 1136:
	switch( (*( sm->p)) ) {
		case 89: goto st1137;
		case 121: goto st1137;
	}
	goto tr1320;
st1137:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1137;
case 1137:
	switch( (*( sm->p)) ) {
		case 9: goto st1138;
		case 32: goto st1138;
		case 62: goto tr1405;
	}
	goto tr1320;
tr1418:
#line 90 "ext/dtext/dtext.cpp.rl"
	{ save_tag_attribute(sm, { sm->a1, sm->a2 }, { sm->b1, sm->b2 }); }
	goto st1138;
tr1422:
#line 74 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
#line 90 "ext/dtext/dtext.cpp.rl"
	{ save_tag_attribute(sm, { sm->a1, sm->a2 }, { sm->b1, sm->b2 }); }
	goto st1138;
st1138:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1138;
case 1138:
#line 29025 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto st1138;
		case 32: goto st1138;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1406;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1406;
	} else
		goto tr1406;
	goto tr1320;
tr1406:
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st1139;
st1139:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1139;
case 1139:
#line 29045 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto tr1407;
		case 32: goto tr1407;
		case 61: goto tr1409;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st1139;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st1139;
	} else
		goto st1139;
	goto tr1320;
tr1407:
#line 72 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
	goto st1140;
st1140:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1140;
case 1140:
#line 29066 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto st1140;
		case 32: goto st1140;
		case 61: goto st1141;
	}
	goto tr1320;
tr1409:
#line 72 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
	goto st1141;
st1141:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1141;
case 1141:
#line 29079 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto st1141;
		case 32: goto st1141;
		case 34: goto st1142;
		case 39: goto st1145;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1414;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1414;
	} else
		goto tr1414;
	goto tr1320;
st1142:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1142;
case 1142:
	switch( (*( sm->p)) ) {
		case 0: goto tr1320;
		case 10: goto tr1320;
		case 13: goto tr1320;
	}
	goto tr1415;
tr1415:
#line 73 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st1143;
st1143:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1143;
case 1143:
#line 29111 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr1320;
		case 10: goto tr1320;
		case 13: goto tr1320;
		case 34: goto tr1417;
	}
	goto st1143;
tr1417:
#line 74 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
	goto st1144;
st1144:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1144;
case 1144:
#line 29125 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto tr1418;
		case 32: goto tr1418;
		case 62: goto tr1419;
	}
	goto tr1320;
st1145:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1145;
case 1145:
	switch( (*( sm->p)) ) {
		case 0: goto tr1320;
		case 10: goto tr1320;
		case 13: goto tr1320;
	}
	goto tr1420;
tr1420:
#line 73 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st1146;
st1146:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1146;
case 1146:
#line 29148 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr1320;
		case 10: goto tr1320;
		case 13: goto tr1320;
		case 39: goto tr1417;
	}
	goto st1146;
tr1414:
#line 73 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st1147;
st1147:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1147;
case 1147:
#line 29162 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto tr1422;
		case 32: goto tr1422;
		case 62: goto tr1424;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st1147;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st1147;
	} else
		goto st1147;
	goto tr1320;
st1148:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1148;
case 1148:
	switch( (*( sm->p)) ) {
		case 9: goto st1149;
		case 32: goto st1149;
		case 62: goto tr1426;
	}
	goto tr1320;
tr1439:
#line 90 "ext/dtext/dtext.cpp.rl"
	{ save_tag_attribute(sm, { sm->a1, sm->a2 }, { sm->b1, sm->b2 }); }
	goto st1149;
tr1443:
#line 74 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
#line 90 "ext/dtext/dtext.cpp.rl"
	{ save_tag_attribute(sm, { sm->a1, sm->a2 }, { sm->b1, sm->b2 }); }
	goto st1149;
st1149:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1149;
case 1149:
#line 29197 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto st1149;
		case 32: goto st1149;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1427;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1427;
	} else
		goto tr1427;
	goto tr1320;
tr1427:
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st1150;
st1150:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1150;
case 1150:
#line 29217 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto tr1428;
		case 32: goto tr1428;
		case 61: goto tr1430;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st1150;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st1150;
	} else
		goto st1150;
	goto tr1320;
tr1428:
#line 72 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
	goto st1151;
st1151:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1151;
case 1151:
#line 29238 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto st1151;
		case 32: goto st1151;
		case 61: goto st1152;
	}
	goto tr1320;
tr1430:
#line 72 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
	goto st1152;
st1152:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1152;
case 1152:
#line 29251 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto st1152;
		case 32: goto st1152;
		case 34: goto st1153;
		case 39: goto st1156;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1435;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1435;
	} else
		goto tr1435;
	goto tr1320;
st1153:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1153;
case 1153:
	switch( (*( sm->p)) ) {
		case 0: goto tr1320;
		case 10: goto tr1320;
		case 13: goto tr1320;
	}
	goto tr1436;
tr1436:
#line 73 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st1154;
st1154:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1154;
case 1154:
#line 29283 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr1320;
		case 10: goto tr1320;
		case 13: goto tr1320;
		case 34: goto tr1438;
	}
	goto st1154;
tr1438:
#line 74 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
	goto st1155;
st1155:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1155;
case 1155:
#line 29297 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto tr1439;
		case 32: goto tr1439;
		case 62: goto tr1440;
	}
	goto tr1320;
st1156:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1156;
case 1156:
	switch( (*( sm->p)) ) {
		case 0: goto tr1320;
		case 10: goto tr1320;
		case 13: goto tr1320;
	}
	goto tr1441;
tr1441:
#line 73 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st1157;
st1157:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1157;
case 1157:
#line 29320 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr1320;
		case 10: goto tr1320;
		case 13: goto tr1320;
		case 39: goto tr1438;
	}
	goto st1157;
tr1435:
#line 73 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st1158;
st1158:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1158;
case 1158:
#line 29334 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto tr1443;
		case 32: goto tr1443;
		case 62: goto tr1445;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st1158;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st1158;
	} else
		goto st1158;
	goto tr1320;
st1159:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1159;
case 1159:
	switch( (*( sm->p)) ) {
		case 9: goto st1160;
		case 32: goto st1160;
		case 62: goto tr1447;
		case 69: goto st1170;
		case 101: goto st1170;
	}
	goto tr1320;
tr1461:
#line 90 "ext/dtext/dtext.cpp.rl"
	{ save_tag_attribute(sm, { sm->a1, sm->a2 }, { sm->b1, sm->b2 }); }
	goto st1160;
tr1465:
#line 74 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
#line 90 "ext/dtext/dtext.cpp.rl"
	{ save_tag_attribute(sm, { sm->a1, sm->a2 }, { sm->b1, sm->b2 }); }
	goto st1160;
st1160:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1160;
case 1160:
#line 29371 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto st1160;
		case 32: goto st1160;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1449;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1449;
	} else
		goto tr1449;
	goto tr1320;
tr1449:
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st1161;
st1161:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1161;
case 1161:
#line 29391 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto tr1450;
		case 32: goto tr1450;
		case 61: goto tr1452;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st1161;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st1161;
	} else
		goto st1161;
	goto tr1320;
tr1450:
#line 72 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
	goto st1162;
st1162:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1162;
case 1162:
#line 29412 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto st1162;
		case 32: goto st1162;
		case 61: goto st1163;
	}
	goto tr1320;
tr1452:
#line 72 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
	goto st1163;
st1163:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1163;
case 1163:
#line 29425 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto st1163;
		case 32: goto st1163;
		case 34: goto st1164;
		case 39: goto st1167;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1457;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1457;
	} else
		goto tr1457;
	goto tr1320;
st1164:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1164;
case 1164:
	switch( (*( sm->p)) ) {
		case 0: goto tr1320;
		case 10: goto tr1320;
		case 13: goto tr1320;
	}
	goto tr1458;
tr1458:
#line 73 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st1165;
st1165:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1165;
case 1165:
#line 29457 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr1320;
		case 10: goto tr1320;
		case 13: goto tr1320;
		case 34: goto tr1460;
	}
	goto st1165;
tr1460:
#line 74 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
	goto st1166;
st1166:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1166;
case 1166:
#line 29471 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto tr1461;
		case 32: goto tr1461;
		case 62: goto tr1462;
	}
	goto tr1320;
st1167:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1167;
case 1167:
	switch( (*( sm->p)) ) {
		case 0: goto tr1320;
		case 10: goto tr1320;
		case 13: goto tr1320;
	}
	goto tr1463;
tr1463:
#line 73 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st1168;
st1168:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1168;
case 1168:
#line 29494 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr1320;
		case 10: goto tr1320;
		case 13: goto tr1320;
		case 39: goto tr1460;
	}
	goto st1168;
tr1457:
#line 73 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st1169;
st1169:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1169;
case 1169:
#line 29508 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto tr1465;
		case 32: goto tr1465;
		case 62: goto tr1467;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st1169;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st1169;
	} else
		goto st1169;
	goto tr1320;
st1170:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1170;
case 1170:
	switch( (*( sm->p)) ) {
		case 65: goto st1171;
		case 97: goto st1171;
	}
	goto tr1320;
st1171:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1171;
case 1171:
	switch( (*( sm->p)) ) {
		case 68: goto st1172;
		case 100: goto st1172;
	}
	goto tr1320;
st1172:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1172;
case 1172:
	switch( (*( sm->p)) ) {
		case 9: goto st1173;
		case 32: goto st1173;
		case 62: goto tr1471;
	}
	goto tr1320;
tr1484:
#line 90 "ext/dtext/dtext.cpp.rl"
	{ save_tag_attribute(sm, { sm->a1, sm->a2 }, { sm->b1, sm->b2 }); }
	goto st1173;
tr1488:
#line 74 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
#line 90 "ext/dtext/dtext.cpp.rl"
	{ save_tag_attribute(sm, { sm->a1, sm->a2 }, { sm->b1, sm->b2 }); }
	goto st1173;
st1173:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1173;
case 1173:
#line 29561 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto st1173;
		case 32: goto st1173;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1472;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1472;
	} else
		goto tr1472;
	goto tr1320;
tr1472:
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st1174;
st1174:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1174;
case 1174:
#line 29581 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto tr1473;
		case 32: goto tr1473;
		case 61: goto tr1475;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st1174;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st1174;
	} else
		goto st1174;
	goto tr1320;
tr1473:
#line 72 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
	goto st1175;
st1175:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1175;
case 1175:
#line 29602 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto st1175;
		case 32: goto st1175;
		case 61: goto st1176;
	}
	goto tr1320;
tr1475:
#line 72 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
	goto st1176;
st1176:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1176;
case 1176:
#line 29615 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto st1176;
		case 32: goto st1176;
		case 34: goto st1177;
		case 39: goto st1180;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1480;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1480;
	} else
		goto tr1480;
	goto tr1320;
st1177:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1177;
case 1177:
	switch( (*( sm->p)) ) {
		case 0: goto tr1320;
		case 10: goto tr1320;
		case 13: goto tr1320;
	}
	goto tr1481;
tr1481:
#line 73 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st1178;
st1178:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1178;
case 1178:
#line 29647 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr1320;
		case 10: goto tr1320;
		case 13: goto tr1320;
		case 34: goto tr1483;
	}
	goto st1178;
tr1483:
#line 74 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
	goto st1179;
st1179:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1179;
case 1179:
#line 29661 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto tr1484;
		case 32: goto tr1484;
		case 62: goto tr1485;
	}
	goto tr1320;
st1180:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1180;
case 1180:
	switch( (*( sm->p)) ) {
		case 0: goto tr1320;
		case 10: goto tr1320;
		case 13: goto tr1320;
	}
	goto tr1486;
tr1486:
#line 73 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st1181;
st1181:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1181;
case 1181:
#line 29684 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr1320;
		case 10: goto tr1320;
		case 13: goto tr1320;
		case 39: goto tr1483;
	}
	goto st1181;
tr1480:
#line 73 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st1182;
st1182:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1182;
case 1182:
#line 29698 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto tr1488;
		case 32: goto tr1488;
		case 62: goto tr1490;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st1182;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st1182;
	} else
		goto st1182;
	goto tr1320;
st1183:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1183;
case 1183:
	switch( (*( sm->p)) ) {
		case 9: goto st1184;
		case 32: goto st1184;
		case 62: goto tr1492;
	}
	goto tr1320;
tr1505:
#line 90 "ext/dtext/dtext.cpp.rl"
	{ save_tag_attribute(sm, { sm->a1, sm->a2 }, { sm->b1, sm->b2 }); }
	goto st1184;
tr1509:
#line 74 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
#line 90 "ext/dtext/dtext.cpp.rl"
	{ save_tag_attribute(sm, { sm->a1, sm->a2 }, { sm->b1, sm->b2 }); }
	goto st1184;
st1184:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1184;
case 1184:
#line 29733 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto st1184;
		case 32: goto st1184;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1493;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1493;
	} else
		goto tr1493;
	goto tr1320;
tr1493:
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st1185;
st1185:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1185;
case 1185:
#line 29753 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto tr1494;
		case 32: goto tr1494;
		case 61: goto tr1496;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st1185;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st1185;
	} else
		goto st1185;
	goto tr1320;
tr1494:
#line 72 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
	goto st1186;
st1186:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1186;
case 1186:
#line 29774 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto st1186;
		case 32: goto st1186;
		case 61: goto st1187;
	}
	goto tr1320;
tr1496:
#line 72 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
	goto st1187;
st1187:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1187;
case 1187:
#line 29787 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto st1187;
		case 32: goto st1187;
		case 34: goto st1188;
		case 39: goto st1191;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1501;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1501;
	} else
		goto tr1501;
	goto tr1320;
st1188:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1188;
case 1188:
	switch( (*( sm->p)) ) {
		case 0: goto tr1320;
		case 10: goto tr1320;
		case 13: goto tr1320;
	}
	goto tr1502;
tr1502:
#line 73 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st1189;
st1189:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1189;
case 1189:
#line 29819 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr1320;
		case 10: goto tr1320;
		case 13: goto tr1320;
		case 34: goto tr1504;
	}
	goto st1189;
tr1504:
#line 74 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
	goto st1190;
st1190:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1190;
case 1190:
#line 29833 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto tr1505;
		case 32: goto tr1505;
		case 62: goto tr1506;
	}
	goto tr1320;
st1191:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1191;
case 1191:
	switch( (*( sm->p)) ) {
		case 0: goto tr1320;
		case 10: goto tr1320;
		case 13: goto tr1320;
	}
	goto tr1507;
tr1507:
#line 73 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st1192;
st1192:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1192;
case 1192:
#line 29856 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr1320;
		case 10: goto tr1320;
		case 13: goto tr1320;
		case 39: goto tr1504;
	}
	goto st1192;
tr1501:
#line 73 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st1193;
st1193:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1193;
case 1193:
#line 29870 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto tr1509;
		case 32: goto tr1509;
		case 62: goto tr1511;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st1193;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st1193;
	} else
		goto st1193;
	goto tr1320;
tr2140:
#line 1 "NONE"
	{( sm->te) = ( sm->p)+1;}
	goto st1615;
st1615:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1615;
case 1615:
#line 29891 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 47: goto st1194;
		case 67: goto st1217;
		case 84: goto st1245;
		case 99: goto st1217;
		case 116: goto st1245;
	}
	goto tr2141;
st1194:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1194;
case 1194:
	switch( (*( sm->p)) ) {
		case 67: goto st1195;
		case 84: goto st1203;
		case 99: goto st1195;
		case 116: goto st1203;
	}
	goto tr1320;
st1195:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1195;
case 1195:
	switch( (*( sm->p)) ) {
		case 79: goto st1196;
		case 111: goto st1196;
	}
	goto tr1320;
st1196:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1196;
case 1196:
	switch( (*( sm->p)) ) {
		case 76: goto st1197;
		case 108: goto st1197;
	}
	goto tr1320;
st1197:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1197;
case 1197:
	switch( (*( sm->p)) ) {
		case 71: goto st1198;
		case 103: goto st1198;
	}
	goto tr1320;
st1198:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1198;
case 1198:
	switch( (*( sm->p)) ) {
		case 82: goto st1199;
		case 114: goto st1199;
	}
	goto tr1320;
st1199:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1199;
case 1199:
	switch( (*( sm->p)) ) {
		case 79: goto st1200;
		case 111: goto st1200;
	}
	goto tr1320;
st1200:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1200;
case 1200:
	switch( (*( sm->p)) ) {
		case 85: goto st1201;
		case 117: goto st1201;
	}
	goto tr1320;
st1201:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1201;
case 1201:
	switch( (*( sm->p)) ) {
		case 80: goto st1202;
		case 112: goto st1202;
	}
	goto tr1320;
st1202:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1202;
case 1202:
	if ( (*( sm->p)) == 93 )
		goto tr1330;
	goto tr1320;
st1203:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1203;
case 1203:
	switch( (*( sm->p)) ) {
		case 65: goto st1204;
		case 66: goto st1208;
		case 72: goto st1212;
		case 82: goto st1216;
		case 97: goto st1204;
		case 98: goto st1208;
		case 104: goto st1212;
		case 114: goto st1216;
	}
	goto tr1320;
st1204:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1204;
case 1204:
	switch( (*( sm->p)) ) {
		case 66: goto st1205;
		case 98: goto st1205;
	}
	goto tr1320;
st1205:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1205;
case 1205:
	switch( (*( sm->p)) ) {
		case 76: goto st1206;
		case 108: goto st1206;
	}
	goto tr1320;
st1206:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1206;
case 1206:
	switch( (*( sm->p)) ) {
		case 69: goto st1207;
		case 101: goto st1207;
	}
	goto tr1320;
st1207:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1207;
case 1207:
	if ( (*( sm->p)) == 93 )
		goto tr1338;
	goto tr1320;
st1208:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1208;
case 1208:
	switch( (*( sm->p)) ) {
		case 79: goto st1209;
		case 111: goto st1209;
	}
	goto tr1320;
st1209:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1209;
case 1209:
	switch( (*( sm->p)) ) {
		case 68: goto st1210;
		case 100: goto st1210;
	}
	goto tr1320;
st1210:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1210;
case 1210:
	switch( (*( sm->p)) ) {
		case 89: goto st1211;
		case 121: goto st1211;
	}
	goto tr1320;
st1211:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1211;
case 1211:
	if ( (*( sm->p)) == 93 )
		goto tr1342;
	goto tr1320;
st1212:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1212;
case 1212:
	switch( (*( sm->p)) ) {
		case 69: goto st1213;
		case 101: goto st1213;
	}
	goto tr1320;
st1213:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1213;
case 1213:
	switch( (*( sm->p)) ) {
		case 65: goto st1214;
		case 97: goto st1214;
	}
	goto tr1320;
st1214:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1214;
case 1214:
	switch( (*( sm->p)) ) {
		case 68: goto st1215;
		case 100: goto st1215;
	}
	goto tr1320;
st1215:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1215;
case 1215:
	if ( (*( sm->p)) == 93 )
		goto tr1346;
	goto tr1320;
st1216:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1216;
case 1216:
	if ( (*( sm->p)) == 93 )
		goto tr1347;
	goto tr1320;
st1217:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1217;
case 1217:
	switch( (*( sm->p)) ) {
		case 79: goto st1218;
		case 111: goto st1218;
	}
	goto tr1320;
st1218:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1218;
case 1218:
	switch( (*( sm->p)) ) {
		case 76: goto st1219;
		case 108: goto st1219;
	}
	goto tr1320;
st1219:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1219;
case 1219:
	switch( (*( sm->p)) ) {
		case 9: goto st1220;
		case 32: goto st1220;
		case 71: goto st1230;
		case 93: goto tr1351;
		case 103: goto st1230;
	}
	goto tr1320;
tr1550:
#line 90 "ext/dtext/dtext.cpp.rl"
	{ save_tag_attribute(sm, { sm->a1, sm->a2 }, { sm->b1, sm->b2 }); }
	goto st1220;
tr1553:
#line 74 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
#line 90 "ext/dtext/dtext.cpp.rl"
	{ save_tag_attribute(sm, { sm->a1, sm->a2 }, { sm->b1, sm->b2 }); }
	goto st1220;
st1220:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1220;
case 1220:
#line 30145 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto st1220;
		case 32: goto st1220;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1538;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1538;
	} else
		goto tr1538;
	goto tr1320;
tr1538:
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st1221;
st1221:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1221;
case 1221:
#line 30165 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto tr1539;
		case 32: goto tr1539;
		case 61: goto tr1541;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st1221;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st1221;
	} else
		goto st1221;
	goto tr1320;
tr1539:
#line 72 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
	goto st1222;
st1222:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1222;
case 1222:
#line 30186 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto st1222;
		case 32: goto st1222;
		case 61: goto st1223;
	}
	goto tr1320;
tr1541:
#line 72 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
	goto st1223;
st1223:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1223;
case 1223:
#line 30199 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto st1223;
		case 32: goto st1223;
		case 34: goto st1224;
		case 39: goto st1227;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1546;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1546;
	} else
		goto tr1546;
	goto tr1320;
st1224:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1224;
case 1224:
	switch( (*( sm->p)) ) {
		case 0: goto tr1320;
		case 10: goto tr1320;
		case 13: goto tr1320;
	}
	goto tr1547;
tr1547:
#line 73 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st1225;
st1225:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1225;
case 1225:
#line 30231 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr1320;
		case 10: goto tr1320;
		case 13: goto tr1320;
		case 34: goto tr1549;
	}
	goto st1225;
tr1549:
#line 74 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
	goto st1226;
st1226:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1226;
case 1226:
#line 30245 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto tr1550;
		case 32: goto tr1550;
		case 93: goto tr1366;
	}
	goto tr1320;
st1227:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1227;
case 1227:
	switch( (*( sm->p)) ) {
		case 0: goto tr1320;
		case 10: goto tr1320;
		case 13: goto tr1320;
	}
	goto tr1551;
tr1551:
#line 73 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st1228;
st1228:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1228;
case 1228:
#line 30268 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr1320;
		case 10: goto tr1320;
		case 13: goto tr1320;
		case 39: goto tr1549;
	}
	goto st1228;
tr1546:
#line 73 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st1229;
st1229:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1229;
case 1229:
#line 30282 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto tr1553;
		case 32: goto tr1553;
		case 93: goto tr1371;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st1229;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st1229;
	} else
		goto st1229;
	goto tr1320;
st1230:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1230;
case 1230:
	switch( (*( sm->p)) ) {
		case 82: goto st1231;
		case 114: goto st1231;
	}
	goto tr1320;
st1231:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1231;
case 1231:
	switch( (*( sm->p)) ) {
		case 79: goto st1232;
		case 111: goto st1232;
	}
	goto tr1320;
st1232:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1232;
case 1232:
	switch( (*( sm->p)) ) {
		case 85: goto st1233;
		case 117: goto st1233;
	}
	goto tr1320;
st1233:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1233;
case 1233:
	switch( (*( sm->p)) ) {
		case 80: goto st1234;
		case 112: goto st1234;
	}
	goto tr1320;
st1234:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1234;
case 1234:
	switch( (*( sm->p)) ) {
		case 9: goto st1235;
		case 32: goto st1235;
		case 93: goto tr1377;
	}
	goto tr1320;
tr1572:
#line 90 "ext/dtext/dtext.cpp.rl"
	{ save_tag_attribute(sm, { sm->a1, sm->a2 }, { sm->b1, sm->b2 }); }
	goto st1235;
tr1575:
#line 74 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
#line 90 "ext/dtext/dtext.cpp.rl"
	{ save_tag_attribute(sm, { sm->a1, sm->a2 }, { sm->b1, sm->b2 }); }
	goto st1235;
st1235:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1235;
case 1235:
#line 30353 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto st1235;
		case 32: goto st1235;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1560;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1560;
	} else
		goto tr1560;
	goto tr1320;
tr1560:
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st1236;
st1236:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1236;
case 1236:
#line 30373 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto tr1561;
		case 32: goto tr1561;
		case 61: goto tr1563;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st1236;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st1236;
	} else
		goto st1236;
	goto tr1320;
tr1561:
#line 72 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
	goto st1237;
st1237:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1237;
case 1237:
#line 30394 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto st1237;
		case 32: goto st1237;
		case 61: goto st1238;
	}
	goto tr1320;
tr1563:
#line 72 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
	goto st1238;
st1238:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1238;
case 1238:
#line 30407 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto st1238;
		case 32: goto st1238;
		case 34: goto st1239;
		case 39: goto st1242;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1568;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1568;
	} else
		goto tr1568;
	goto tr1320;
st1239:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1239;
case 1239:
	switch( (*( sm->p)) ) {
		case 0: goto tr1320;
		case 10: goto tr1320;
		case 13: goto tr1320;
	}
	goto tr1569;
tr1569:
#line 73 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st1240;
st1240:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1240;
case 1240:
#line 30439 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr1320;
		case 10: goto tr1320;
		case 13: goto tr1320;
		case 34: goto tr1571;
	}
	goto st1240;
tr1571:
#line 74 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
	goto st1241;
st1241:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1241;
case 1241:
#line 30453 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto tr1572;
		case 32: goto tr1572;
		case 93: goto tr1391;
	}
	goto tr1320;
st1242:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1242;
case 1242:
	switch( (*( sm->p)) ) {
		case 0: goto tr1320;
		case 10: goto tr1320;
		case 13: goto tr1320;
	}
	goto tr1573;
tr1573:
#line 73 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st1243;
st1243:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1243;
case 1243:
#line 30476 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr1320;
		case 10: goto tr1320;
		case 13: goto tr1320;
		case 39: goto tr1571;
	}
	goto st1243;
tr1568:
#line 73 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st1244;
st1244:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1244;
case 1244:
#line 30490 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto tr1575;
		case 32: goto tr1575;
		case 93: goto tr1396;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st1244;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st1244;
	} else
		goto st1244;
	goto tr1320;
st1245:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1245;
case 1245:
	switch( (*( sm->p)) ) {
		case 66: goto st1246;
		case 68: goto st1260;
		case 72: goto st1271;
		case 82: goto st1295;
		case 98: goto st1246;
		case 100: goto st1260;
		case 104: goto st1271;
		case 114: goto st1295;
	}
	goto tr1320;
st1246:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1246;
case 1246:
	switch( (*( sm->p)) ) {
		case 79: goto st1247;
		case 111: goto st1247;
	}
	goto tr1320;
st1247:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1247;
case 1247:
	switch( (*( sm->p)) ) {
		case 68: goto st1248;
		case 100: goto st1248;
	}
	goto tr1320;
st1248:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1248;
case 1248:
	switch( (*( sm->p)) ) {
		case 89: goto st1249;
		case 121: goto st1249;
	}
	goto tr1320;
st1249:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1249;
case 1249:
	switch( (*( sm->p)) ) {
		case 9: goto st1250;
		case 32: goto st1250;
		case 93: goto tr1405;
	}
	goto tr1320;
tr1597:
#line 90 "ext/dtext/dtext.cpp.rl"
	{ save_tag_attribute(sm, { sm->a1, sm->a2 }, { sm->b1, sm->b2 }); }
	goto st1250;
tr1600:
#line 74 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
#line 90 "ext/dtext/dtext.cpp.rl"
	{ save_tag_attribute(sm, { sm->a1, sm->a2 }, { sm->b1, sm->b2 }); }
	goto st1250;
st1250:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1250;
case 1250:
#line 30567 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto st1250;
		case 32: goto st1250;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1585;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1585;
	} else
		goto tr1585;
	goto tr1320;
tr1585:
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st1251;
st1251:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1251;
case 1251:
#line 30587 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto tr1586;
		case 32: goto tr1586;
		case 61: goto tr1588;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st1251;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st1251;
	} else
		goto st1251;
	goto tr1320;
tr1586:
#line 72 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
	goto st1252;
st1252:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1252;
case 1252:
#line 30608 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto st1252;
		case 32: goto st1252;
		case 61: goto st1253;
	}
	goto tr1320;
tr1588:
#line 72 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
	goto st1253;
st1253:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1253;
case 1253:
#line 30621 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto st1253;
		case 32: goto st1253;
		case 34: goto st1254;
		case 39: goto st1257;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1593;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1593;
	} else
		goto tr1593;
	goto tr1320;
st1254:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1254;
case 1254:
	switch( (*( sm->p)) ) {
		case 0: goto tr1320;
		case 10: goto tr1320;
		case 13: goto tr1320;
	}
	goto tr1594;
tr1594:
#line 73 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st1255;
st1255:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1255;
case 1255:
#line 30653 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr1320;
		case 10: goto tr1320;
		case 13: goto tr1320;
		case 34: goto tr1596;
	}
	goto st1255;
tr1596:
#line 74 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
	goto st1256;
st1256:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1256;
case 1256:
#line 30667 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto tr1597;
		case 32: goto tr1597;
		case 93: goto tr1419;
	}
	goto tr1320;
st1257:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1257;
case 1257:
	switch( (*( sm->p)) ) {
		case 0: goto tr1320;
		case 10: goto tr1320;
		case 13: goto tr1320;
	}
	goto tr1598;
tr1598:
#line 73 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st1258;
st1258:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1258;
case 1258:
#line 30690 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr1320;
		case 10: goto tr1320;
		case 13: goto tr1320;
		case 39: goto tr1596;
	}
	goto st1258;
tr1593:
#line 73 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st1259;
st1259:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1259;
case 1259:
#line 30704 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto tr1600;
		case 32: goto tr1600;
		case 93: goto tr1424;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st1259;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st1259;
	} else
		goto st1259;
	goto tr1320;
st1260:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1260;
case 1260:
	switch( (*( sm->p)) ) {
		case 9: goto st1261;
		case 32: goto st1261;
		case 93: goto tr1426;
	}
	goto tr1320;
tr1615:
#line 90 "ext/dtext/dtext.cpp.rl"
	{ save_tag_attribute(sm, { sm->a1, sm->a2 }, { sm->b1, sm->b2 }); }
	goto st1261;
tr1618:
#line 74 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
#line 90 "ext/dtext/dtext.cpp.rl"
	{ save_tag_attribute(sm, { sm->a1, sm->a2 }, { sm->b1, sm->b2 }); }
	goto st1261;
st1261:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1261;
case 1261:
#line 30739 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto st1261;
		case 32: goto st1261;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1603;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1603;
	} else
		goto tr1603;
	goto tr1320;
tr1603:
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st1262;
st1262:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1262;
case 1262:
#line 30759 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto tr1604;
		case 32: goto tr1604;
		case 61: goto tr1606;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st1262;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st1262;
	} else
		goto st1262;
	goto tr1320;
tr1604:
#line 72 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
	goto st1263;
st1263:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1263;
case 1263:
#line 30780 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto st1263;
		case 32: goto st1263;
		case 61: goto st1264;
	}
	goto tr1320;
tr1606:
#line 72 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
	goto st1264;
st1264:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1264;
case 1264:
#line 30793 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto st1264;
		case 32: goto st1264;
		case 34: goto st1265;
		case 39: goto st1268;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1611;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1611;
	} else
		goto tr1611;
	goto tr1320;
st1265:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1265;
case 1265:
	switch( (*( sm->p)) ) {
		case 0: goto tr1320;
		case 10: goto tr1320;
		case 13: goto tr1320;
	}
	goto tr1612;
tr1612:
#line 73 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st1266;
st1266:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1266;
case 1266:
#line 30825 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr1320;
		case 10: goto tr1320;
		case 13: goto tr1320;
		case 34: goto tr1614;
	}
	goto st1266;
tr1614:
#line 74 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
	goto st1267;
st1267:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1267;
case 1267:
#line 30839 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto tr1615;
		case 32: goto tr1615;
		case 93: goto tr1440;
	}
	goto tr1320;
st1268:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1268;
case 1268:
	switch( (*( sm->p)) ) {
		case 0: goto tr1320;
		case 10: goto tr1320;
		case 13: goto tr1320;
	}
	goto tr1616;
tr1616:
#line 73 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st1269;
st1269:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1269;
case 1269:
#line 30862 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr1320;
		case 10: goto tr1320;
		case 13: goto tr1320;
		case 39: goto tr1614;
	}
	goto st1269;
tr1611:
#line 73 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st1270;
st1270:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1270;
case 1270:
#line 30876 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto tr1618;
		case 32: goto tr1618;
		case 93: goto tr1445;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st1270;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st1270;
	} else
		goto st1270;
	goto tr1320;
st1271:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1271;
case 1271:
	switch( (*( sm->p)) ) {
		case 9: goto st1272;
		case 32: goto st1272;
		case 69: goto st1282;
		case 93: goto tr1447;
		case 101: goto st1282;
	}
	goto tr1320;
tr1634:
#line 90 "ext/dtext/dtext.cpp.rl"
	{ save_tag_attribute(sm, { sm->a1, sm->a2 }, { sm->b1, sm->b2 }); }
	goto st1272;
tr1637:
#line 74 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
#line 90 "ext/dtext/dtext.cpp.rl"
	{ save_tag_attribute(sm, { sm->a1, sm->a2 }, { sm->b1, sm->b2 }); }
	goto st1272;
st1272:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1272;
case 1272:
#line 30913 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto st1272;
		case 32: goto st1272;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1622;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1622;
	} else
		goto tr1622;
	goto tr1320;
tr1622:
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st1273;
st1273:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1273;
case 1273:
#line 30933 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto tr1623;
		case 32: goto tr1623;
		case 61: goto tr1625;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st1273;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st1273;
	} else
		goto st1273;
	goto tr1320;
tr1623:
#line 72 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
	goto st1274;
st1274:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1274;
case 1274:
#line 30954 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto st1274;
		case 32: goto st1274;
		case 61: goto st1275;
	}
	goto tr1320;
tr1625:
#line 72 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
	goto st1275;
st1275:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1275;
case 1275:
#line 30967 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto st1275;
		case 32: goto st1275;
		case 34: goto st1276;
		case 39: goto st1279;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1630;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1630;
	} else
		goto tr1630;
	goto tr1320;
st1276:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1276;
case 1276:
	switch( (*( sm->p)) ) {
		case 0: goto tr1320;
		case 10: goto tr1320;
		case 13: goto tr1320;
	}
	goto tr1631;
tr1631:
#line 73 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st1277;
st1277:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1277;
case 1277:
#line 30999 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr1320;
		case 10: goto tr1320;
		case 13: goto tr1320;
		case 34: goto tr1633;
	}
	goto st1277;
tr1633:
#line 74 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
	goto st1278;
st1278:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1278;
case 1278:
#line 31013 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto tr1634;
		case 32: goto tr1634;
		case 93: goto tr1462;
	}
	goto tr1320;
st1279:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1279;
case 1279:
	switch( (*( sm->p)) ) {
		case 0: goto tr1320;
		case 10: goto tr1320;
		case 13: goto tr1320;
	}
	goto tr1635;
tr1635:
#line 73 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st1280;
st1280:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1280;
case 1280:
#line 31036 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr1320;
		case 10: goto tr1320;
		case 13: goto tr1320;
		case 39: goto tr1633;
	}
	goto st1280;
tr1630:
#line 73 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st1281;
st1281:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1281;
case 1281:
#line 31050 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto tr1637;
		case 32: goto tr1637;
		case 93: goto tr1467;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st1281;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st1281;
	} else
		goto st1281;
	goto tr1320;
st1282:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1282;
case 1282:
	switch( (*( sm->p)) ) {
		case 65: goto st1283;
		case 97: goto st1283;
	}
	goto tr1320;
st1283:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1283;
case 1283:
	switch( (*( sm->p)) ) {
		case 68: goto st1284;
		case 100: goto st1284;
	}
	goto tr1320;
st1284:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1284;
case 1284:
	switch( (*( sm->p)) ) {
		case 9: goto st1285;
		case 32: goto st1285;
		case 93: goto tr1471;
	}
	goto tr1320;
tr1654:
#line 90 "ext/dtext/dtext.cpp.rl"
	{ save_tag_attribute(sm, { sm->a1, sm->a2 }, { sm->b1, sm->b2 }); }
	goto st1285;
tr1657:
#line 74 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
#line 90 "ext/dtext/dtext.cpp.rl"
	{ save_tag_attribute(sm, { sm->a1, sm->a2 }, { sm->b1, sm->b2 }); }
	goto st1285;
st1285:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1285;
case 1285:
#line 31103 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto st1285;
		case 32: goto st1285;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1642;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1642;
	} else
		goto tr1642;
	goto tr1320;
tr1642:
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st1286;
st1286:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1286;
case 1286:
#line 31123 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto tr1643;
		case 32: goto tr1643;
		case 61: goto tr1645;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st1286;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st1286;
	} else
		goto st1286;
	goto tr1320;
tr1643:
#line 72 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
	goto st1287;
st1287:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1287;
case 1287:
#line 31144 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto st1287;
		case 32: goto st1287;
		case 61: goto st1288;
	}
	goto tr1320;
tr1645:
#line 72 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
	goto st1288;
st1288:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1288;
case 1288:
#line 31157 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto st1288;
		case 32: goto st1288;
		case 34: goto st1289;
		case 39: goto st1292;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1650;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1650;
	} else
		goto tr1650;
	goto tr1320;
st1289:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1289;
case 1289:
	switch( (*( sm->p)) ) {
		case 0: goto tr1320;
		case 10: goto tr1320;
		case 13: goto tr1320;
	}
	goto tr1651;
tr1651:
#line 73 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st1290;
st1290:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1290;
case 1290:
#line 31189 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr1320;
		case 10: goto tr1320;
		case 13: goto tr1320;
		case 34: goto tr1653;
	}
	goto st1290;
tr1653:
#line 74 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
	goto st1291;
st1291:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1291;
case 1291:
#line 31203 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto tr1654;
		case 32: goto tr1654;
		case 93: goto tr1485;
	}
	goto tr1320;
st1292:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1292;
case 1292:
	switch( (*( sm->p)) ) {
		case 0: goto tr1320;
		case 10: goto tr1320;
		case 13: goto tr1320;
	}
	goto tr1655;
tr1655:
#line 73 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st1293;
st1293:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1293;
case 1293:
#line 31226 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr1320;
		case 10: goto tr1320;
		case 13: goto tr1320;
		case 39: goto tr1653;
	}
	goto st1293;
tr1650:
#line 73 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st1294;
st1294:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1294;
case 1294:
#line 31240 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto tr1657;
		case 32: goto tr1657;
		case 93: goto tr1490;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st1294;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st1294;
	} else
		goto st1294;
	goto tr1320;
st1295:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1295;
case 1295:
	switch( (*( sm->p)) ) {
		case 9: goto st1296;
		case 32: goto st1296;
		case 93: goto tr1492;
	}
	goto tr1320;
tr1672:
#line 90 "ext/dtext/dtext.cpp.rl"
	{ save_tag_attribute(sm, { sm->a1, sm->a2 }, { sm->b1, sm->b2 }); }
	goto st1296;
tr1675:
#line 74 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
#line 90 "ext/dtext/dtext.cpp.rl"
	{ save_tag_attribute(sm, { sm->a1, sm->a2 }, { sm->b1, sm->b2 }); }
	goto st1296;
st1296:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1296;
case 1296:
#line 31275 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto st1296;
		case 32: goto st1296;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1660;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1660;
	} else
		goto tr1660;
	goto tr1320;
tr1660:
#line 71 "ext/dtext/dtext.cpp.rl"
	{ sm->a1 = sm->p; }
	goto st1297;
st1297:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1297;
case 1297:
#line 31295 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto tr1661;
		case 32: goto tr1661;
		case 61: goto tr1663;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st1297;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st1297;
	} else
		goto st1297;
	goto tr1320;
tr1661:
#line 72 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
	goto st1298;
st1298:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1298;
case 1298:
#line 31316 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto st1298;
		case 32: goto st1298;
		case 61: goto st1299;
	}
	goto tr1320;
tr1663:
#line 72 "ext/dtext/dtext.cpp.rl"
	{ sm->a2 = sm->p; }
	goto st1299;
st1299:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1299;
case 1299:
#line 31329 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto st1299;
		case 32: goto st1299;
		case 34: goto st1300;
		case 39: goto st1303;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto tr1668;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto tr1668;
	} else
		goto tr1668;
	goto tr1320;
st1300:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1300;
case 1300:
	switch( (*( sm->p)) ) {
		case 0: goto tr1320;
		case 10: goto tr1320;
		case 13: goto tr1320;
	}
	goto tr1669;
tr1669:
#line 73 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st1301;
st1301:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1301;
case 1301:
#line 31361 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr1320;
		case 10: goto tr1320;
		case 13: goto tr1320;
		case 34: goto tr1671;
	}
	goto st1301;
tr1671:
#line 74 "ext/dtext/dtext.cpp.rl"
	{ sm->b2 = sm->p; }
	goto st1302;
st1302:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1302;
case 1302:
#line 31375 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto tr1672;
		case 32: goto tr1672;
		case 93: goto tr1506;
	}
	goto tr1320;
st1303:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1303;
case 1303:
	switch( (*( sm->p)) ) {
		case 0: goto tr1320;
		case 10: goto tr1320;
		case 13: goto tr1320;
	}
	goto tr1673;
tr1673:
#line 73 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st1304;
st1304:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1304;
case 1304:
#line 31398 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 0: goto tr1320;
		case 10: goto tr1320;
		case 13: goto tr1320;
		case 39: goto tr1671;
	}
	goto st1304;
tr1668:
#line 73 "ext/dtext/dtext.cpp.rl"
	{ sm->b1 = sm->p; }
	goto st1305;
st1305:
	if ( ++( sm->p) == ( sm->pe) )
		goto _test_eof1305;
case 1305:
#line 31412 "ext/dtext/dtext.cpp"
	switch( (*( sm->p)) ) {
		case 9: goto tr1675;
		case 32: goto tr1675;
		case 93: goto tr1511;
	}
	if ( (*( sm->p)) < 65 ) {
		if ( 48 <= (*( sm->p)) && (*( sm->p)) <= 57 )
			goto st1305;
	} else if ( (*( sm->p)) > 90 ) {
		if ( 97 <= (*( sm->p)) && (*( sm->p)) <= 122 )
			goto st1305;
	} else
		goto st1305;
	goto tr1320;
	}
	_test_eof1306:  sm->cs = 1306; goto _test_eof; 
	_test_eof1307:  sm->cs = 1307; goto _test_eof; 
	_test_eof1:  sm->cs = 1; goto _test_eof; 
	_test_eof1308:  sm->cs = 1308; goto _test_eof; 
	_test_eof2:  sm->cs = 2; goto _test_eof; 
	_test_eof3:  sm->cs = 3; goto _test_eof; 
	_test_eof4:  sm->cs = 4; goto _test_eof; 
	_test_eof5:  sm->cs = 5; goto _test_eof; 
	_test_eof6:  sm->cs = 6; goto _test_eof; 
	_test_eof1309:  sm->cs = 1309; goto _test_eof; 
	_test_eof7:  sm->cs = 7; goto _test_eof; 
	_test_eof8:  sm->cs = 8; goto _test_eof; 
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
	_test_eof1310:  sm->cs = 1310; goto _test_eof; 
	_test_eof20:  sm->cs = 20; goto _test_eof; 
	_test_eof1311:  sm->cs = 1311; goto _test_eof; 
	_test_eof1312:  sm->cs = 1312; goto _test_eof; 
	_test_eof21:  sm->cs = 21; goto _test_eof; 
	_test_eof1313:  sm->cs = 1313; goto _test_eof; 
	_test_eof22:  sm->cs = 22; goto _test_eof; 
	_test_eof23:  sm->cs = 23; goto _test_eof; 
	_test_eof24:  sm->cs = 24; goto _test_eof; 
	_test_eof25:  sm->cs = 25; goto _test_eof; 
	_test_eof26:  sm->cs = 26; goto _test_eof; 
	_test_eof27:  sm->cs = 27; goto _test_eof; 
	_test_eof28:  sm->cs = 28; goto _test_eof; 
	_test_eof29:  sm->cs = 29; goto _test_eof; 
	_test_eof30:  sm->cs = 30; goto _test_eof; 
	_test_eof31:  sm->cs = 31; goto _test_eof; 
	_test_eof1314:  sm->cs = 1314; goto _test_eof; 
	_test_eof32:  sm->cs = 32; goto _test_eof; 
	_test_eof33:  sm->cs = 33; goto _test_eof; 
	_test_eof34:  sm->cs = 34; goto _test_eof; 
	_test_eof35:  sm->cs = 35; goto _test_eof; 
	_test_eof36:  sm->cs = 36; goto _test_eof; 
	_test_eof37:  sm->cs = 37; goto _test_eof; 
	_test_eof38:  sm->cs = 38; goto _test_eof; 
	_test_eof1315:  sm->cs = 1315; goto _test_eof; 
	_test_eof39:  sm->cs = 39; goto _test_eof; 
	_test_eof1316:  sm->cs = 1316; goto _test_eof; 
	_test_eof40:  sm->cs = 40; goto _test_eof; 
	_test_eof41:  sm->cs = 41; goto _test_eof; 
	_test_eof42:  sm->cs = 42; goto _test_eof; 
	_test_eof43:  sm->cs = 43; goto _test_eof; 
	_test_eof44:  sm->cs = 44; goto _test_eof; 
	_test_eof45:  sm->cs = 45; goto _test_eof; 
	_test_eof46:  sm->cs = 46; goto _test_eof; 
	_test_eof47:  sm->cs = 47; goto _test_eof; 
	_test_eof48:  sm->cs = 48; goto _test_eof; 
	_test_eof1317:  sm->cs = 1317; goto _test_eof; 
	_test_eof49:  sm->cs = 49; goto _test_eof; 
	_test_eof1318:  sm->cs = 1318; goto _test_eof; 
	_test_eof50:  sm->cs = 50; goto _test_eof; 
	_test_eof51:  sm->cs = 51; goto _test_eof; 
	_test_eof52:  sm->cs = 52; goto _test_eof; 
	_test_eof53:  sm->cs = 53; goto _test_eof; 
	_test_eof54:  sm->cs = 54; goto _test_eof; 
	_test_eof55:  sm->cs = 55; goto _test_eof; 
	_test_eof56:  sm->cs = 56; goto _test_eof; 
	_test_eof1319:  sm->cs = 1319; goto _test_eof; 
	_test_eof57:  sm->cs = 57; goto _test_eof; 
	_test_eof58:  sm->cs = 58; goto _test_eof; 
	_test_eof59:  sm->cs = 59; goto _test_eof; 
	_test_eof60:  sm->cs = 60; goto _test_eof; 
	_test_eof61:  sm->cs = 61; goto _test_eof; 
	_test_eof62:  sm->cs = 62; goto _test_eof; 
	_test_eof63:  sm->cs = 63; goto _test_eof; 
	_test_eof64:  sm->cs = 64; goto _test_eof; 
	_test_eof1320:  sm->cs = 1320; goto _test_eof; 
	_test_eof65:  sm->cs = 65; goto _test_eof; 
	_test_eof66:  sm->cs = 66; goto _test_eof; 
	_test_eof67:  sm->cs = 67; goto _test_eof; 
	_test_eof1321:  sm->cs = 1321; goto _test_eof; 
	_test_eof68:  sm->cs = 68; goto _test_eof; 
	_test_eof69:  sm->cs = 69; goto _test_eof; 
	_test_eof70:  sm->cs = 70; goto _test_eof; 
	_test_eof1322:  sm->cs = 1322; goto _test_eof; 
	_test_eof1323:  sm->cs = 1323; goto _test_eof; 
	_test_eof71:  sm->cs = 71; goto _test_eof; 
	_test_eof72:  sm->cs = 72; goto _test_eof; 
	_test_eof73:  sm->cs = 73; goto _test_eof; 
	_test_eof74:  sm->cs = 74; goto _test_eof; 
	_test_eof75:  sm->cs = 75; goto _test_eof; 
	_test_eof76:  sm->cs = 76; goto _test_eof; 
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
	_test_eof1324:  sm->cs = 1324; goto _test_eof; 
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
	_test_eof1325:  sm->cs = 1325; goto _test_eof; 
	_test_eof1326:  sm->cs = 1326; goto _test_eof; 
	_test_eof119:  sm->cs = 119; goto _test_eof; 
	_test_eof120:  sm->cs = 120; goto _test_eof; 
	_test_eof121:  sm->cs = 121; goto _test_eof; 
	_test_eof122:  sm->cs = 122; goto _test_eof; 
	_test_eof123:  sm->cs = 123; goto _test_eof; 
	_test_eof124:  sm->cs = 124; goto _test_eof; 
	_test_eof125:  sm->cs = 125; goto _test_eof; 
	_test_eof126:  sm->cs = 126; goto _test_eof; 
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
	_test_eof1327:  sm->cs = 1327; goto _test_eof; 
	_test_eof138:  sm->cs = 138; goto _test_eof; 
	_test_eof139:  sm->cs = 139; goto _test_eof; 
	_test_eof140:  sm->cs = 140; goto _test_eof; 
	_test_eof141:  sm->cs = 141; goto _test_eof; 
	_test_eof142:  sm->cs = 142; goto _test_eof; 
	_test_eof143:  sm->cs = 143; goto _test_eof; 
	_test_eof144:  sm->cs = 144; goto _test_eof; 
	_test_eof145:  sm->cs = 145; goto _test_eof; 
	_test_eof146:  sm->cs = 146; goto _test_eof; 
	_test_eof1328:  sm->cs = 1328; goto _test_eof; 
	_test_eof1329:  sm->cs = 1329; goto _test_eof; 
	_test_eof1330:  sm->cs = 1330; goto _test_eof; 
	_test_eof147:  sm->cs = 147; goto _test_eof; 
	_test_eof148:  sm->cs = 148; goto _test_eof; 
	_test_eof149:  sm->cs = 149; goto _test_eof; 
	_test_eof1331:  sm->cs = 1331; goto _test_eof; 
	_test_eof1332:  sm->cs = 1332; goto _test_eof; 
	_test_eof1333:  sm->cs = 1333; goto _test_eof; 
	_test_eof150:  sm->cs = 150; goto _test_eof; 
	_test_eof1334:  sm->cs = 1334; goto _test_eof; 
	_test_eof151:  sm->cs = 151; goto _test_eof; 
	_test_eof1335:  sm->cs = 1335; goto _test_eof; 
	_test_eof152:  sm->cs = 152; goto _test_eof; 
	_test_eof153:  sm->cs = 153; goto _test_eof; 
	_test_eof154:  sm->cs = 154; goto _test_eof; 
	_test_eof155:  sm->cs = 155; goto _test_eof; 
	_test_eof156:  sm->cs = 156; goto _test_eof; 
	_test_eof1336:  sm->cs = 1336; goto _test_eof; 
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
	_test_eof1337:  sm->cs = 1337; goto _test_eof; 
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
	_test_eof199:  sm->cs = 199; goto _test_eof; 
	_test_eof200:  sm->cs = 200; goto _test_eof; 
	_test_eof1338:  sm->cs = 1338; goto _test_eof; 
	_test_eof1339:  sm->cs = 1339; goto _test_eof; 
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
	_test_eof1340:  sm->cs = 1340; goto _test_eof; 
	_test_eof213:  sm->cs = 213; goto _test_eof; 
	_test_eof214:  sm->cs = 214; goto _test_eof; 
	_test_eof215:  sm->cs = 215; goto _test_eof; 
	_test_eof216:  sm->cs = 216; goto _test_eof; 
	_test_eof217:  sm->cs = 217; goto _test_eof; 
	_test_eof218:  sm->cs = 218; goto _test_eof; 
	_test_eof1341:  sm->cs = 1341; goto _test_eof; 
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
	_test_eof242:  sm->cs = 242; goto _test_eof; 
	_test_eof243:  sm->cs = 243; goto _test_eof; 
	_test_eof244:  sm->cs = 244; goto _test_eof; 
	_test_eof245:  sm->cs = 245; goto _test_eof; 
	_test_eof246:  sm->cs = 246; goto _test_eof; 
	_test_eof247:  sm->cs = 247; goto _test_eof; 
	_test_eof248:  sm->cs = 248; goto _test_eof; 
	_test_eof249:  sm->cs = 249; goto _test_eof; 
	_test_eof1342:  sm->cs = 1342; goto _test_eof; 
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
	_test_eof1343:  sm->cs = 1343; goto _test_eof; 
	_test_eof291:  sm->cs = 291; goto _test_eof; 
	_test_eof292:  sm->cs = 292; goto _test_eof; 
	_test_eof293:  sm->cs = 293; goto _test_eof; 
	_test_eof1344:  sm->cs = 1344; goto _test_eof; 
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
	_test_eof1345:  sm->cs = 1345; goto _test_eof; 
	_test_eof305:  sm->cs = 305; goto _test_eof; 
	_test_eof306:  sm->cs = 306; goto _test_eof; 
	_test_eof307:  sm->cs = 307; goto _test_eof; 
	_test_eof308:  sm->cs = 308; goto _test_eof; 
	_test_eof309:  sm->cs = 309; goto _test_eof; 
	_test_eof310:  sm->cs = 310; goto _test_eof; 
	_test_eof311:  sm->cs = 311; goto _test_eof; 
	_test_eof312:  sm->cs = 312; goto _test_eof; 
	_test_eof313:  sm->cs = 313; goto _test_eof; 
	_test_eof314:  sm->cs = 314; goto _test_eof; 
	_test_eof315:  sm->cs = 315; goto _test_eof; 
	_test_eof316:  sm->cs = 316; goto _test_eof; 
	_test_eof317:  sm->cs = 317; goto _test_eof; 
	_test_eof1346:  sm->cs = 1346; goto _test_eof; 
	_test_eof318:  sm->cs = 318; goto _test_eof; 
	_test_eof319:  sm->cs = 319; goto _test_eof; 
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
	_test_eof333:  sm->cs = 333; goto _test_eof; 
	_test_eof334:  sm->cs = 334; goto _test_eof; 
	_test_eof335:  sm->cs = 335; goto _test_eof; 
	_test_eof336:  sm->cs = 336; goto _test_eof; 
	_test_eof337:  sm->cs = 337; goto _test_eof; 
	_test_eof338:  sm->cs = 338; goto _test_eof; 
	_test_eof339:  sm->cs = 339; goto _test_eof; 
	_test_eof1347:  sm->cs = 1347; goto _test_eof; 
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
	_test_eof1348:  sm->cs = 1348; goto _test_eof; 
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
	_test_eof1349:  sm->cs = 1349; goto _test_eof; 
	_test_eof362:  sm->cs = 362; goto _test_eof; 
	_test_eof363:  sm->cs = 363; goto _test_eof; 
	_test_eof364:  sm->cs = 364; goto _test_eof; 
	_test_eof365:  sm->cs = 365; goto _test_eof; 
	_test_eof366:  sm->cs = 366; goto _test_eof; 
	_test_eof367:  sm->cs = 367; goto _test_eof; 
	_test_eof368:  sm->cs = 368; goto _test_eof; 
	_test_eof369:  sm->cs = 369; goto _test_eof; 
	_test_eof370:  sm->cs = 370; goto _test_eof; 
	_test_eof1350:  sm->cs = 1350; goto _test_eof; 
	_test_eof1351:  sm->cs = 1351; goto _test_eof; 
	_test_eof371:  sm->cs = 371; goto _test_eof; 
	_test_eof372:  sm->cs = 372; goto _test_eof; 
	_test_eof373:  sm->cs = 373; goto _test_eof; 
	_test_eof374:  sm->cs = 374; goto _test_eof; 
	_test_eof1352:  sm->cs = 1352; goto _test_eof; 
	_test_eof1353:  sm->cs = 1353; goto _test_eof; 
	_test_eof375:  sm->cs = 375; goto _test_eof; 
	_test_eof376:  sm->cs = 376; goto _test_eof; 
	_test_eof377:  sm->cs = 377; goto _test_eof; 
	_test_eof378:  sm->cs = 378; goto _test_eof; 
	_test_eof379:  sm->cs = 379; goto _test_eof; 
	_test_eof380:  sm->cs = 380; goto _test_eof; 
	_test_eof381:  sm->cs = 381; goto _test_eof; 
	_test_eof382:  sm->cs = 382; goto _test_eof; 
	_test_eof383:  sm->cs = 383; goto _test_eof; 
	_test_eof1354:  sm->cs = 1354; goto _test_eof; 
	_test_eof1355:  sm->cs = 1355; goto _test_eof; 
	_test_eof384:  sm->cs = 384; goto _test_eof; 
	_test_eof385:  sm->cs = 385; goto _test_eof; 
	_test_eof386:  sm->cs = 386; goto _test_eof; 
	_test_eof387:  sm->cs = 387; goto _test_eof; 
	_test_eof388:  sm->cs = 388; goto _test_eof; 
	_test_eof389:  sm->cs = 389; goto _test_eof; 
	_test_eof390:  sm->cs = 390; goto _test_eof; 
	_test_eof391:  sm->cs = 391; goto _test_eof; 
	_test_eof392:  sm->cs = 392; goto _test_eof; 
	_test_eof393:  sm->cs = 393; goto _test_eof; 
	_test_eof394:  sm->cs = 394; goto _test_eof; 
	_test_eof395:  sm->cs = 395; goto _test_eof; 
	_test_eof396:  sm->cs = 396; goto _test_eof; 
	_test_eof397:  sm->cs = 397; goto _test_eof; 
	_test_eof398:  sm->cs = 398; goto _test_eof; 
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
	_test_eof1356:  sm->cs = 1356; goto _test_eof; 
	_test_eof1357:  sm->cs = 1357; goto _test_eof; 
	_test_eof427:  sm->cs = 427; goto _test_eof; 
	_test_eof1358:  sm->cs = 1358; goto _test_eof; 
	_test_eof1359:  sm->cs = 1359; goto _test_eof; 
	_test_eof428:  sm->cs = 428; goto _test_eof; 
	_test_eof429:  sm->cs = 429; goto _test_eof; 
	_test_eof430:  sm->cs = 430; goto _test_eof; 
	_test_eof431:  sm->cs = 431; goto _test_eof; 
	_test_eof432:  sm->cs = 432; goto _test_eof; 
	_test_eof433:  sm->cs = 433; goto _test_eof; 
	_test_eof434:  sm->cs = 434; goto _test_eof; 
	_test_eof435:  sm->cs = 435; goto _test_eof; 
	_test_eof1360:  sm->cs = 1360; goto _test_eof; 
	_test_eof1361:  sm->cs = 1361; goto _test_eof; 
	_test_eof436:  sm->cs = 436; goto _test_eof; 
	_test_eof1362:  sm->cs = 1362; goto _test_eof; 
	_test_eof437:  sm->cs = 437; goto _test_eof; 
	_test_eof438:  sm->cs = 438; goto _test_eof; 
	_test_eof439:  sm->cs = 439; goto _test_eof; 
	_test_eof440:  sm->cs = 440; goto _test_eof; 
	_test_eof441:  sm->cs = 441; goto _test_eof; 
	_test_eof442:  sm->cs = 442; goto _test_eof; 
	_test_eof443:  sm->cs = 443; goto _test_eof; 
	_test_eof444:  sm->cs = 444; goto _test_eof; 
	_test_eof445:  sm->cs = 445; goto _test_eof; 
	_test_eof446:  sm->cs = 446; goto _test_eof; 
	_test_eof447:  sm->cs = 447; goto _test_eof; 
	_test_eof448:  sm->cs = 448; goto _test_eof; 
	_test_eof449:  sm->cs = 449; goto _test_eof; 
	_test_eof450:  sm->cs = 450; goto _test_eof; 
	_test_eof451:  sm->cs = 451; goto _test_eof; 
	_test_eof452:  sm->cs = 452; goto _test_eof; 
	_test_eof453:  sm->cs = 453; goto _test_eof; 
	_test_eof454:  sm->cs = 454; goto _test_eof; 
	_test_eof1363:  sm->cs = 1363; goto _test_eof; 
	_test_eof455:  sm->cs = 455; goto _test_eof; 
	_test_eof456:  sm->cs = 456; goto _test_eof; 
	_test_eof457:  sm->cs = 457; goto _test_eof; 
	_test_eof458:  sm->cs = 458; goto _test_eof; 
	_test_eof459:  sm->cs = 459; goto _test_eof; 
	_test_eof460:  sm->cs = 460; goto _test_eof; 
	_test_eof461:  sm->cs = 461; goto _test_eof; 
	_test_eof462:  sm->cs = 462; goto _test_eof; 
	_test_eof463:  sm->cs = 463; goto _test_eof; 
	_test_eof1364:  sm->cs = 1364; goto _test_eof; 
	_test_eof1365:  sm->cs = 1365; goto _test_eof; 
	_test_eof1366:  sm->cs = 1366; goto _test_eof; 
	_test_eof1367:  sm->cs = 1367; goto _test_eof; 
	_test_eof1368:  sm->cs = 1368; goto _test_eof; 
	_test_eof464:  sm->cs = 464; goto _test_eof; 
	_test_eof465:  sm->cs = 465; goto _test_eof; 
	_test_eof1369:  sm->cs = 1369; goto _test_eof; 
	_test_eof1370:  sm->cs = 1370; goto _test_eof; 
	_test_eof1371:  sm->cs = 1371; goto _test_eof; 
	_test_eof1372:  sm->cs = 1372; goto _test_eof; 
	_test_eof1373:  sm->cs = 1373; goto _test_eof; 
	_test_eof1374:  sm->cs = 1374; goto _test_eof; 
	_test_eof466:  sm->cs = 466; goto _test_eof; 
	_test_eof467:  sm->cs = 467; goto _test_eof; 
	_test_eof1375:  sm->cs = 1375; goto _test_eof; 
	_test_eof1376:  sm->cs = 1376; goto _test_eof; 
	_test_eof1377:  sm->cs = 1377; goto _test_eof; 
	_test_eof1378:  sm->cs = 1378; goto _test_eof; 
	_test_eof1379:  sm->cs = 1379; goto _test_eof; 
	_test_eof1380:  sm->cs = 1380; goto _test_eof; 
	_test_eof468:  sm->cs = 468; goto _test_eof; 
	_test_eof469:  sm->cs = 469; goto _test_eof; 
	_test_eof1381:  sm->cs = 1381; goto _test_eof; 
	_test_eof1382:  sm->cs = 1382; goto _test_eof; 
	_test_eof1383:  sm->cs = 1383; goto _test_eof; 
	_test_eof1384:  sm->cs = 1384; goto _test_eof; 
	_test_eof1385:  sm->cs = 1385; goto _test_eof; 
	_test_eof1386:  sm->cs = 1386; goto _test_eof; 
	_test_eof1387:  sm->cs = 1387; goto _test_eof; 
	_test_eof1388:  sm->cs = 1388; goto _test_eof; 
	_test_eof470:  sm->cs = 470; goto _test_eof; 
	_test_eof471:  sm->cs = 471; goto _test_eof; 
	_test_eof1389:  sm->cs = 1389; goto _test_eof; 
	_test_eof1390:  sm->cs = 1390; goto _test_eof; 
	_test_eof1391:  sm->cs = 1391; goto _test_eof; 
	_test_eof1392:  sm->cs = 1392; goto _test_eof; 
	_test_eof1393:  sm->cs = 1393; goto _test_eof; 
	_test_eof472:  sm->cs = 472; goto _test_eof; 
	_test_eof473:  sm->cs = 473; goto _test_eof; 
	_test_eof1394:  sm->cs = 1394; goto _test_eof; 
	_test_eof1395:  sm->cs = 1395; goto _test_eof; 
	_test_eof1396:  sm->cs = 1396; goto _test_eof; 
	_test_eof1397:  sm->cs = 1397; goto _test_eof; 
	_test_eof474:  sm->cs = 474; goto _test_eof; 
	_test_eof475:  sm->cs = 475; goto _test_eof; 
	_test_eof1398:  sm->cs = 1398; goto _test_eof; 
	_test_eof1399:  sm->cs = 1399; goto _test_eof; 
	_test_eof1400:  sm->cs = 1400; goto _test_eof; 
	_test_eof476:  sm->cs = 476; goto _test_eof; 
	_test_eof477:  sm->cs = 477; goto _test_eof; 
	_test_eof1401:  sm->cs = 1401; goto _test_eof; 
	_test_eof1402:  sm->cs = 1402; goto _test_eof; 
	_test_eof1403:  sm->cs = 1403; goto _test_eof; 
	_test_eof1404:  sm->cs = 1404; goto _test_eof; 
	_test_eof1405:  sm->cs = 1405; goto _test_eof; 
	_test_eof1406:  sm->cs = 1406; goto _test_eof; 
	_test_eof1407:  sm->cs = 1407; goto _test_eof; 
	_test_eof1408:  sm->cs = 1408; goto _test_eof; 
	_test_eof478:  sm->cs = 478; goto _test_eof; 
	_test_eof479:  sm->cs = 479; goto _test_eof; 
	_test_eof1409:  sm->cs = 1409; goto _test_eof; 
	_test_eof1410:  sm->cs = 1410; goto _test_eof; 
	_test_eof1411:  sm->cs = 1411; goto _test_eof; 
	_test_eof480:  sm->cs = 480; goto _test_eof; 
	_test_eof481:  sm->cs = 481; goto _test_eof; 
	_test_eof1412:  sm->cs = 1412; goto _test_eof; 
	_test_eof1413:  sm->cs = 1413; goto _test_eof; 
	_test_eof1414:  sm->cs = 1414; goto _test_eof; 
	_test_eof1415:  sm->cs = 1415; goto _test_eof; 
	_test_eof1416:  sm->cs = 1416; goto _test_eof; 
	_test_eof1417:  sm->cs = 1417; goto _test_eof; 
	_test_eof1418:  sm->cs = 1418; goto _test_eof; 
	_test_eof1419:  sm->cs = 1419; goto _test_eof; 
	_test_eof1420:  sm->cs = 1420; goto _test_eof; 
	_test_eof1421:  sm->cs = 1421; goto _test_eof; 
	_test_eof1422:  sm->cs = 1422; goto _test_eof; 
	_test_eof482:  sm->cs = 482; goto _test_eof; 
	_test_eof483:  sm->cs = 483; goto _test_eof; 
	_test_eof1423:  sm->cs = 1423; goto _test_eof; 
	_test_eof1424:  sm->cs = 1424; goto _test_eof; 
	_test_eof1425:  sm->cs = 1425; goto _test_eof; 
	_test_eof1426:  sm->cs = 1426; goto _test_eof; 
	_test_eof1427:  sm->cs = 1427; goto _test_eof; 
	_test_eof484:  sm->cs = 484; goto _test_eof; 
	_test_eof485:  sm->cs = 485; goto _test_eof; 
	_test_eof1428:  sm->cs = 1428; goto _test_eof; 
	_test_eof486:  sm->cs = 486; goto _test_eof; 
	_test_eof1429:  sm->cs = 1429; goto _test_eof; 
	_test_eof1430:  sm->cs = 1430; goto _test_eof; 
	_test_eof1431:  sm->cs = 1431; goto _test_eof; 
	_test_eof1432:  sm->cs = 1432; goto _test_eof; 
	_test_eof1433:  sm->cs = 1433; goto _test_eof; 
	_test_eof1434:  sm->cs = 1434; goto _test_eof; 
	_test_eof1435:  sm->cs = 1435; goto _test_eof; 
	_test_eof1436:  sm->cs = 1436; goto _test_eof; 
	_test_eof1437:  sm->cs = 1437; goto _test_eof; 
	_test_eof487:  sm->cs = 487; goto _test_eof; 
	_test_eof488:  sm->cs = 488; goto _test_eof; 
	_test_eof1438:  sm->cs = 1438; goto _test_eof; 
	_test_eof1439:  sm->cs = 1439; goto _test_eof; 
	_test_eof1440:  sm->cs = 1440; goto _test_eof; 
	_test_eof1441:  sm->cs = 1441; goto _test_eof; 
	_test_eof1442:  sm->cs = 1442; goto _test_eof; 
	_test_eof1443:  sm->cs = 1443; goto _test_eof; 
	_test_eof1444:  sm->cs = 1444; goto _test_eof; 
	_test_eof1445:  sm->cs = 1445; goto _test_eof; 
	_test_eof489:  sm->cs = 489; goto _test_eof; 
	_test_eof490:  sm->cs = 490; goto _test_eof; 
	_test_eof1446:  sm->cs = 1446; goto _test_eof; 
	_test_eof1447:  sm->cs = 1447; goto _test_eof; 
	_test_eof1448:  sm->cs = 1448; goto _test_eof; 
	_test_eof1449:  sm->cs = 1449; goto _test_eof; 
	_test_eof491:  sm->cs = 491; goto _test_eof; 
	_test_eof492:  sm->cs = 492; goto _test_eof; 
	_test_eof1450:  sm->cs = 1450; goto _test_eof; 
	_test_eof1451:  sm->cs = 1451; goto _test_eof; 
	_test_eof1452:  sm->cs = 1452; goto _test_eof; 
	_test_eof1453:  sm->cs = 1453; goto _test_eof; 
	_test_eof1454:  sm->cs = 1454; goto _test_eof; 
	_test_eof493:  sm->cs = 493; goto _test_eof; 
	_test_eof494:  sm->cs = 494; goto _test_eof; 
	_test_eof1455:  sm->cs = 1455; goto _test_eof; 
	_test_eof1456:  sm->cs = 1456; goto _test_eof; 
	_test_eof1457:  sm->cs = 1457; goto _test_eof; 
	_test_eof1458:  sm->cs = 1458; goto _test_eof; 
	_test_eof1459:  sm->cs = 1459; goto _test_eof; 
	_test_eof1460:  sm->cs = 1460; goto _test_eof; 
	_test_eof1461:  sm->cs = 1461; goto _test_eof; 
	_test_eof1462:  sm->cs = 1462; goto _test_eof; 
	_test_eof1463:  sm->cs = 1463; goto _test_eof; 
	_test_eof495:  sm->cs = 495; goto _test_eof; 
	_test_eof496:  sm->cs = 496; goto _test_eof; 
	_test_eof1464:  sm->cs = 1464; goto _test_eof; 
	_test_eof1465:  sm->cs = 1465; goto _test_eof; 
	_test_eof1466:  sm->cs = 1466; goto _test_eof; 
	_test_eof1467:  sm->cs = 1467; goto _test_eof; 
	_test_eof1468:  sm->cs = 1468; goto _test_eof; 
	_test_eof497:  sm->cs = 497; goto _test_eof; 
	_test_eof498:  sm->cs = 498; goto _test_eof; 
	_test_eof499:  sm->cs = 499; goto _test_eof; 
	_test_eof500:  sm->cs = 500; goto _test_eof; 
	_test_eof501:  sm->cs = 501; goto _test_eof; 
	_test_eof502:  sm->cs = 502; goto _test_eof; 
	_test_eof503:  sm->cs = 503; goto _test_eof; 
	_test_eof504:  sm->cs = 504; goto _test_eof; 
	_test_eof505:  sm->cs = 505; goto _test_eof; 
	_test_eof1469:  sm->cs = 1469; goto _test_eof; 
	_test_eof506:  sm->cs = 506; goto _test_eof; 
	_test_eof507:  sm->cs = 507; goto _test_eof; 
	_test_eof508:  sm->cs = 508; goto _test_eof; 
	_test_eof509:  sm->cs = 509; goto _test_eof; 
	_test_eof510:  sm->cs = 510; goto _test_eof; 
	_test_eof511:  sm->cs = 511; goto _test_eof; 
	_test_eof512:  sm->cs = 512; goto _test_eof; 
	_test_eof513:  sm->cs = 513; goto _test_eof; 
	_test_eof514:  sm->cs = 514; goto _test_eof; 
	_test_eof515:  sm->cs = 515; goto _test_eof; 
	_test_eof1470:  sm->cs = 1470; goto _test_eof; 
	_test_eof516:  sm->cs = 516; goto _test_eof; 
	_test_eof517:  sm->cs = 517; goto _test_eof; 
	_test_eof518:  sm->cs = 518; goto _test_eof; 
	_test_eof519:  sm->cs = 519; goto _test_eof; 
	_test_eof520:  sm->cs = 520; goto _test_eof; 
	_test_eof521:  sm->cs = 521; goto _test_eof; 
	_test_eof522:  sm->cs = 522; goto _test_eof; 
	_test_eof523:  sm->cs = 523; goto _test_eof; 
	_test_eof524:  sm->cs = 524; goto _test_eof; 
	_test_eof525:  sm->cs = 525; goto _test_eof; 
	_test_eof526:  sm->cs = 526; goto _test_eof; 
	_test_eof1471:  sm->cs = 1471; goto _test_eof; 
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
	_test_eof1472:  sm->cs = 1472; goto _test_eof; 
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
	_test_eof1473:  sm->cs = 1473; goto _test_eof; 
	_test_eof1474:  sm->cs = 1474; goto _test_eof; 
	_test_eof1475:  sm->cs = 1475; goto _test_eof; 
	_test_eof1476:  sm->cs = 1476; goto _test_eof; 
	_test_eof1477:  sm->cs = 1477; goto _test_eof; 
	_test_eof1478:  sm->cs = 1478; goto _test_eof; 
	_test_eof1479:  sm->cs = 1479; goto _test_eof; 
	_test_eof1480:  sm->cs = 1480; goto _test_eof; 
	_test_eof1481:  sm->cs = 1481; goto _test_eof; 
	_test_eof1482:  sm->cs = 1482; goto _test_eof; 
	_test_eof1483:  sm->cs = 1483; goto _test_eof; 
	_test_eof1484:  sm->cs = 1484; goto _test_eof; 
	_test_eof1485:  sm->cs = 1485; goto _test_eof; 
	_test_eof550:  sm->cs = 550; goto _test_eof; 
	_test_eof551:  sm->cs = 551; goto _test_eof; 
	_test_eof1486:  sm->cs = 1486; goto _test_eof; 
	_test_eof1487:  sm->cs = 1487; goto _test_eof; 
	_test_eof1488:  sm->cs = 1488; goto _test_eof; 
	_test_eof1489:  sm->cs = 1489; goto _test_eof; 
	_test_eof1490:  sm->cs = 1490; goto _test_eof; 
	_test_eof552:  sm->cs = 552; goto _test_eof; 
	_test_eof553:  sm->cs = 553; goto _test_eof; 
	_test_eof1491:  sm->cs = 1491; goto _test_eof; 
	_test_eof1492:  sm->cs = 1492; goto _test_eof; 
	_test_eof1493:  sm->cs = 1493; goto _test_eof; 
	_test_eof1494:  sm->cs = 1494; goto _test_eof; 
	_test_eof1495:  sm->cs = 1495; goto _test_eof; 
	_test_eof1496:  sm->cs = 1496; goto _test_eof; 
	_test_eof554:  sm->cs = 554; goto _test_eof; 
	_test_eof555:  sm->cs = 555; goto _test_eof; 
	_test_eof556:  sm->cs = 556; goto _test_eof; 
	_test_eof557:  sm->cs = 557; goto _test_eof; 
	_test_eof558:  sm->cs = 558; goto _test_eof; 
	_test_eof559:  sm->cs = 559; goto _test_eof; 
	_test_eof560:  sm->cs = 560; goto _test_eof; 
	_test_eof561:  sm->cs = 561; goto _test_eof; 
	_test_eof1497:  sm->cs = 1497; goto _test_eof; 
	_test_eof1498:  sm->cs = 1498; goto _test_eof; 
	_test_eof1499:  sm->cs = 1499; goto _test_eof; 
	_test_eof562:  sm->cs = 562; goto _test_eof; 
	_test_eof563:  sm->cs = 563; goto _test_eof; 
	_test_eof564:  sm->cs = 564; goto _test_eof; 
	_test_eof565:  sm->cs = 565; goto _test_eof; 
	_test_eof566:  sm->cs = 566; goto _test_eof; 
	_test_eof567:  sm->cs = 567; goto _test_eof; 
	_test_eof568:  sm->cs = 568; goto _test_eof; 
	_test_eof569:  sm->cs = 569; goto _test_eof; 
	_test_eof570:  sm->cs = 570; goto _test_eof; 
	_test_eof1500:  sm->cs = 1500; goto _test_eof; 
	_test_eof1501:  sm->cs = 1501; goto _test_eof; 
	_test_eof1502:  sm->cs = 1502; goto _test_eof; 
	_test_eof1503:  sm->cs = 1503; goto _test_eof; 
	_test_eof1504:  sm->cs = 1504; goto _test_eof; 
	_test_eof1505:  sm->cs = 1505; goto _test_eof; 
	_test_eof1506:  sm->cs = 1506; goto _test_eof; 
	_test_eof571:  sm->cs = 571; goto _test_eof; 
	_test_eof572:  sm->cs = 572; goto _test_eof; 
	_test_eof1507:  sm->cs = 1507; goto _test_eof; 
	_test_eof1508:  sm->cs = 1508; goto _test_eof; 
	_test_eof1509:  sm->cs = 1509; goto _test_eof; 
	_test_eof1510:  sm->cs = 1510; goto _test_eof; 
	_test_eof1511:  sm->cs = 1511; goto _test_eof; 
	_test_eof1512:  sm->cs = 1512; goto _test_eof; 
	_test_eof573:  sm->cs = 573; goto _test_eof; 
	_test_eof574:  sm->cs = 574; goto _test_eof; 
	_test_eof1513:  sm->cs = 1513; goto _test_eof; 
	_test_eof1514:  sm->cs = 1514; goto _test_eof; 
	_test_eof1515:  sm->cs = 1515; goto _test_eof; 
	_test_eof1516:  sm->cs = 1516; goto _test_eof; 
	_test_eof575:  sm->cs = 575; goto _test_eof; 
	_test_eof576:  sm->cs = 576; goto _test_eof; 
	_test_eof1517:  sm->cs = 1517; goto _test_eof; 
	_test_eof1518:  sm->cs = 1518; goto _test_eof; 
	_test_eof1519:  sm->cs = 1519; goto _test_eof; 
	_test_eof1520:  sm->cs = 1520; goto _test_eof; 
	_test_eof1521:  sm->cs = 1521; goto _test_eof; 
	_test_eof1522:  sm->cs = 1522; goto _test_eof; 
	_test_eof577:  sm->cs = 577; goto _test_eof; 
	_test_eof578:  sm->cs = 578; goto _test_eof; 
	_test_eof1523:  sm->cs = 1523; goto _test_eof; 
	_test_eof1524:  sm->cs = 1524; goto _test_eof; 
	_test_eof1525:  sm->cs = 1525; goto _test_eof; 
	_test_eof1526:  sm->cs = 1526; goto _test_eof; 
	_test_eof1527:  sm->cs = 1527; goto _test_eof; 
	_test_eof579:  sm->cs = 579; goto _test_eof; 
	_test_eof580:  sm->cs = 580; goto _test_eof; 
	_test_eof1528:  sm->cs = 1528; goto _test_eof; 
	_test_eof581:  sm->cs = 581; goto _test_eof; 
	_test_eof582:  sm->cs = 582; goto _test_eof; 
	_test_eof1529:  sm->cs = 1529; goto _test_eof; 
	_test_eof1530:  sm->cs = 1530; goto _test_eof; 
	_test_eof1531:  sm->cs = 1531; goto _test_eof; 
	_test_eof1532:  sm->cs = 1532; goto _test_eof; 
	_test_eof583:  sm->cs = 583; goto _test_eof; 
	_test_eof584:  sm->cs = 584; goto _test_eof; 
	_test_eof1533:  sm->cs = 1533; goto _test_eof; 
	_test_eof1534:  sm->cs = 1534; goto _test_eof; 
	_test_eof1535:  sm->cs = 1535; goto _test_eof; 
	_test_eof585:  sm->cs = 585; goto _test_eof; 
	_test_eof586:  sm->cs = 586; goto _test_eof; 
	_test_eof1536:  sm->cs = 1536; goto _test_eof; 
	_test_eof1537:  sm->cs = 1537; goto _test_eof; 
	_test_eof1538:  sm->cs = 1538; goto _test_eof; 
	_test_eof1539:  sm->cs = 1539; goto _test_eof; 
	_test_eof587:  sm->cs = 587; goto _test_eof; 
	_test_eof588:  sm->cs = 588; goto _test_eof; 
	_test_eof1540:  sm->cs = 1540; goto _test_eof; 
	_test_eof1541:  sm->cs = 1541; goto _test_eof; 
	_test_eof1542:  sm->cs = 1542; goto _test_eof; 
	_test_eof1543:  sm->cs = 1543; goto _test_eof; 
	_test_eof1544:  sm->cs = 1544; goto _test_eof; 
	_test_eof1545:  sm->cs = 1545; goto _test_eof; 
	_test_eof1546:  sm->cs = 1546; goto _test_eof; 
	_test_eof1547:  sm->cs = 1547; goto _test_eof; 
	_test_eof589:  sm->cs = 589; goto _test_eof; 
	_test_eof590:  sm->cs = 590; goto _test_eof; 
	_test_eof1548:  sm->cs = 1548; goto _test_eof; 
	_test_eof1549:  sm->cs = 1549; goto _test_eof; 
	_test_eof1550:  sm->cs = 1550; goto _test_eof; 
	_test_eof1551:  sm->cs = 1551; goto _test_eof; 
	_test_eof1552:  sm->cs = 1552; goto _test_eof; 
	_test_eof591:  sm->cs = 591; goto _test_eof; 
	_test_eof592:  sm->cs = 592; goto _test_eof; 
	_test_eof1553:  sm->cs = 1553; goto _test_eof; 
	_test_eof1554:  sm->cs = 1554; goto _test_eof; 
	_test_eof1555:  sm->cs = 1555; goto _test_eof; 
	_test_eof1556:  sm->cs = 1556; goto _test_eof; 
	_test_eof1557:  sm->cs = 1557; goto _test_eof; 
	_test_eof1558:  sm->cs = 1558; goto _test_eof; 
	_test_eof593:  sm->cs = 593; goto _test_eof; 
	_test_eof594:  sm->cs = 594; goto _test_eof; 
	_test_eof1559:  sm->cs = 1559; goto _test_eof; 
	_test_eof595:  sm->cs = 595; goto _test_eof; 
	_test_eof596:  sm->cs = 596; goto _test_eof; 
	_test_eof1560:  sm->cs = 1560; goto _test_eof; 
	_test_eof1561:  sm->cs = 1561; goto _test_eof; 
	_test_eof1562:  sm->cs = 1562; goto _test_eof; 
	_test_eof1563:  sm->cs = 1563; goto _test_eof; 
	_test_eof1564:  sm->cs = 1564; goto _test_eof; 
	_test_eof1565:  sm->cs = 1565; goto _test_eof; 
	_test_eof1566:  sm->cs = 1566; goto _test_eof; 
	_test_eof597:  sm->cs = 597; goto _test_eof; 
	_test_eof598:  sm->cs = 598; goto _test_eof; 
	_test_eof1567:  sm->cs = 1567; goto _test_eof; 
	_test_eof1568:  sm->cs = 1568; goto _test_eof; 
	_test_eof1569:  sm->cs = 1569; goto _test_eof; 
	_test_eof1570:  sm->cs = 1570; goto _test_eof; 
	_test_eof1571:  sm->cs = 1571; goto _test_eof; 
	_test_eof599:  sm->cs = 599; goto _test_eof; 
	_test_eof600:  sm->cs = 600; goto _test_eof; 
	_test_eof1572:  sm->cs = 1572; goto _test_eof; 
	_test_eof1573:  sm->cs = 1573; goto _test_eof; 
	_test_eof1574:  sm->cs = 1574; goto _test_eof; 
	_test_eof1575:  sm->cs = 1575; goto _test_eof; 
	_test_eof1576:  sm->cs = 1576; goto _test_eof; 
	_test_eof601:  sm->cs = 601; goto _test_eof; 
	_test_eof602:  sm->cs = 602; goto _test_eof; 
	_test_eof1577:  sm->cs = 1577; goto _test_eof; 
	_test_eof1578:  sm->cs = 1578; goto _test_eof; 
	_test_eof1579:  sm->cs = 1579; goto _test_eof; 
	_test_eof1580:  sm->cs = 1580; goto _test_eof; 
	_test_eof1581:  sm->cs = 1581; goto _test_eof; 
	_test_eof1582:  sm->cs = 1582; goto _test_eof; 
	_test_eof1583:  sm->cs = 1583; goto _test_eof; 
	_test_eof1584:  sm->cs = 1584; goto _test_eof; 
	_test_eof603:  sm->cs = 603; goto _test_eof; 
	_test_eof604:  sm->cs = 604; goto _test_eof; 
	_test_eof1585:  sm->cs = 1585; goto _test_eof; 
	_test_eof1586:  sm->cs = 1586; goto _test_eof; 
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
	_test_eof1587:  sm->cs = 1587; goto _test_eof; 
	_test_eof677:  sm->cs = 677; goto _test_eof; 
	_test_eof1588:  sm->cs = 1588; goto _test_eof; 
	_test_eof678:  sm->cs = 678; goto _test_eof; 
	_test_eof679:  sm->cs = 679; goto _test_eof; 
	_test_eof680:  sm->cs = 680; goto _test_eof; 
	_test_eof681:  sm->cs = 681; goto _test_eof; 
	_test_eof682:  sm->cs = 682; goto _test_eof; 
	_test_eof683:  sm->cs = 683; goto _test_eof; 
	_test_eof684:  sm->cs = 684; goto _test_eof; 
	_test_eof685:  sm->cs = 685; goto _test_eof; 
	_test_eof686:  sm->cs = 686; goto _test_eof; 
	_test_eof1589:  sm->cs = 1589; goto _test_eof; 
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
	_test_eof1590:  sm->cs = 1590; goto _test_eof; 
	_test_eof710:  sm->cs = 710; goto _test_eof; 
	_test_eof711:  sm->cs = 711; goto _test_eof; 
	_test_eof712:  sm->cs = 712; goto _test_eof; 
	_test_eof713:  sm->cs = 713; goto _test_eof; 
	_test_eof1591:  sm->cs = 1591; goto _test_eof; 
	_test_eof714:  sm->cs = 714; goto _test_eof; 
	_test_eof715:  sm->cs = 715; goto _test_eof; 
	_test_eof1592:  sm->cs = 1592; goto _test_eof; 
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
	_test_eof1593:  sm->cs = 1593; goto _test_eof; 
	_test_eof733:  sm->cs = 733; goto _test_eof; 
	_test_eof734:  sm->cs = 734; goto _test_eof; 
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
	_test_eof1594:  sm->cs = 1594; goto _test_eof; 
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
	_test_eof1595:  sm->cs = 1595; goto _test_eof; 
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
	_test_eof1596:  sm->cs = 1596; goto _test_eof; 
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
	_test_eof1597:  sm->cs = 1597; goto _test_eof; 
	_test_eof840:  sm->cs = 840; goto _test_eof; 
	_test_eof841:  sm->cs = 841; goto _test_eof; 
	_test_eof842:  sm->cs = 842; goto _test_eof; 
	_test_eof843:  sm->cs = 843; goto _test_eof; 
	_test_eof844:  sm->cs = 844; goto _test_eof; 
	_test_eof845:  sm->cs = 845; goto _test_eof; 
	_test_eof846:  sm->cs = 846; goto _test_eof; 
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
	_test_eof1598:  sm->cs = 1598; goto _test_eof; 
	_test_eof1599:  sm->cs = 1599; goto _test_eof; 
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
	_test_eof1600:  sm->cs = 1600; goto _test_eof; 
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
	_test_eof1011:  sm->cs = 1011; goto _test_eof; 
	_test_eof1012:  sm->cs = 1012; goto _test_eof; 
	_test_eof1013:  sm->cs = 1013; goto _test_eof; 
	_test_eof1014:  sm->cs = 1014; goto _test_eof; 
	_test_eof1015:  sm->cs = 1015; goto _test_eof; 
	_test_eof1601:  sm->cs = 1601; goto _test_eof; 
	_test_eof1016:  sm->cs = 1016; goto _test_eof; 
	_test_eof1017:  sm->cs = 1017; goto _test_eof; 
	_test_eof1602:  sm->cs = 1602; goto _test_eof; 
	_test_eof1018:  sm->cs = 1018; goto _test_eof; 
	_test_eof1019:  sm->cs = 1019; goto _test_eof; 
	_test_eof1020:  sm->cs = 1020; goto _test_eof; 
	_test_eof1021:  sm->cs = 1021; goto _test_eof; 
	_test_eof1603:  sm->cs = 1603; goto _test_eof; 
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
	_test_eof1604:  sm->cs = 1604; goto _test_eof; 
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
	_test_eof1605:  sm->cs = 1605; goto _test_eof; 
	_test_eof1606:  sm->cs = 1606; goto _test_eof; 
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
	_test_eof1607:  sm->cs = 1607; goto _test_eof; 
	_test_eof1608:  sm->cs = 1608; goto _test_eof; 
	_test_eof1609:  sm->cs = 1609; goto _test_eof; 
	_test_eof1610:  sm->cs = 1610; goto _test_eof; 
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
	_test_eof1611:  sm->cs = 1611; goto _test_eof; 
	_test_eof1612:  sm->cs = 1612; goto _test_eof; 
	_test_eof1613:  sm->cs = 1613; goto _test_eof; 
	_test_eof1614:  sm->cs = 1614; goto _test_eof; 
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
	_test_eof1123:  sm->cs = 1123; goto _test_eof; 
	_test_eof1124:  sm->cs = 1124; goto _test_eof; 
	_test_eof1125:  sm->cs = 1125; goto _test_eof; 
	_test_eof1126:  sm->cs = 1126; goto _test_eof; 
	_test_eof1127:  sm->cs = 1127; goto _test_eof; 
	_test_eof1128:  sm->cs = 1128; goto _test_eof; 
	_test_eof1129:  sm->cs = 1129; goto _test_eof; 
	_test_eof1130:  sm->cs = 1130; goto _test_eof; 
	_test_eof1131:  sm->cs = 1131; goto _test_eof; 
	_test_eof1132:  sm->cs = 1132; goto _test_eof; 
	_test_eof1133:  sm->cs = 1133; goto _test_eof; 
	_test_eof1134:  sm->cs = 1134; goto _test_eof; 
	_test_eof1135:  sm->cs = 1135; goto _test_eof; 
	_test_eof1136:  sm->cs = 1136; goto _test_eof; 
	_test_eof1137:  sm->cs = 1137; goto _test_eof; 
	_test_eof1138:  sm->cs = 1138; goto _test_eof; 
	_test_eof1139:  sm->cs = 1139; goto _test_eof; 
	_test_eof1140:  sm->cs = 1140; goto _test_eof; 
	_test_eof1141:  sm->cs = 1141; goto _test_eof; 
	_test_eof1142:  sm->cs = 1142; goto _test_eof; 
	_test_eof1143:  sm->cs = 1143; goto _test_eof; 
	_test_eof1144:  sm->cs = 1144; goto _test_eof; 
	_test_eof1145:  sm->cs = 1145; goto _test_eof; 
	_test_eof1146:  sm->cs = 1146; goto _test_eof; 
	_test_eof1147:  sm->cs = 1147; goto _test_eof; 
	_test_eof1148:  sm->cs = 1148; goto _test_eof; 
	_test_eof1149:  sm->cs = 1149; goto _test_eof; 
	_test_eof1150:  sm->cs = 1150; goto _test_eof; 
	_test_eof1151:  sm->cs = 1151; goto _test_eof; 
	_test_eof1152:  sm->cs = 1152; goto _test_eof; 
	_test_eof1153:  sm->cs = 1153; goto _test_eof; 
	_test_eof1154:  sm->cs = 1154; goto _test_eof; 
	_test_eof1155:  sm->cs = 1155; goto _test_eof; 
	_test_eof1156:  sm->cs = 1156; goto _test_eof; 
	_test_eof1157:  sm->cs = 1157; goto _test_eof; 
	_test_eof1158:  sm->cs = 1158; goto _test_eof; 
	_test_eof1159:  sm->cs = 1159; goto _test_eof; 
	_test_eof1160:  sm->cs = 1160; goto _test_eof; 
	_test_eof1161:  sm->cs = 1161; goto _test_eof; 
	_test_eof1162:  sm->cs = 1162; goto _test_eof; 
	_test_eof1163:  sm->cs = 1163; goto _test_eof; 
	_test_eof1164:  sm->cs = 1164; goto _test_eof; 
	_test_eof1165:  sm->cs = 1165; goto _test_eof; 
	_test_eof1166:  sm->cs = 1166; goto _test_eof; 
	_test_eof1167:  sm->cs = 1167; goto _test_eof; 
	_test_eof1168:  sm->cs = 1168; goto _test_eof; 
	_test_eof1169:  sm->cs = 1169; goto _test_eof; 
	_test_eof1170:  sm->cs = 1170; goto _test_eof; 
	_test_eof1171:  sm->cs = 1171; goto _test_eof; 
	_test_eof1172:  sm->cs = 1172; goto _test_eof; 
	_test_eof1173:  sm->cs = 1173; goto _test_eof; 
	_test_eof1174:  sm->cs = 1174; goto _test_eof; 
	_test_eof1175:  sm->cs = 1175; goto _test_eof; 
	_test_eof1176:  sm->cs = 1176; goto _test_eof; 
	_test_eof1177:  sm->cs = 1177; goto _test_eof; 
	_test_eof1178:  sm->cs = 1178; goto _test_eof; 
	_test_eof1179:  sm->cs = 1179; goto _test_eof; 
	_test_eof1180:  sm->cs = 1180; goto _test_eof; 
	_test_eof1181:  sm->cs = 1181; goto _test_eof; 
	_test_eof1182:  sm->cs = 1182; goto _test_eof; 
	_test_eof1183:  sm->cs = 1183; goto _test_eof; 
	_test_eof1184:  sm->cs = 1184; goto _test_eof; 
	_test_eof1185:  sm->cs = 1185; goto _test_eof; 
	_test_eof1186:  sm->cs = 1186; goto _test_eof; 
	_test_eof1187:  sm->cs = 1187; goto _test_eof; 
	_test_eof1188:  sm->cs = 1188; goto _test_eof; 
	_test_eof1189:  sm->cs = 1189; goto _test_eof; 
	_test_eof1190:  sm->cs = 1190; goto _test_eof; 
	_test_eof1191:  sm->cs = 1191; goto _test_eof; 
	_test_eof1192:  sm->cs = 1192; goto _test_eof; 
	_test_eof1193:  sm->cs = 1193; goto _test_eof; 
	_test_eof1615:  sm->cs = 1615; goto _test_eof; 
	_test_eof1194:  sm->cs = 1194; goto _test_eof; 
	_test_eof1195:  sm->cs = 1195; goto _test_eof; 
	_test_eof1196:  sm->cs = 1196; goto _test_eof; 
	_test_eof1197:  sm->cs = 1197; goto _test_eof; 
	_test_eof1198:  sm->cs = 1198; goto _test_eof; 
	_test_eof1199:  sm->cs = 1199; goto _test_eof; 
	_test_eof1200:  sm->cs = 1200; goto _test_eof; 
	_test_eof1201:  sm->cs = 1201; goto _test_eof; 
	_test_eof1202:  sm->cs = 1202; goto _test_eof; 
	_test_eof1203:  sm->cs = 1203; goto _test_eof; 
	_test_eof1204:  sm->cs = 1204; goto _test_eof; 
	_test_eof1205:  sm->cs = 1205; goto _test_eof; 
	_test_eof1206:  sm->cs = 1206; goto _test_eof; 
	_test_eof1207:  sm->cs = 1207; goto _test_eof; 
	_test_eof1208:  sm->cs = 1208; goto _test_eof; 
	_test_eof1209:  sm->cs = 1209; goto _test_eof; 
	_test_eof1210:  sm->cs = 1210; goto _test_eof; 
	_test_eof1211:  sm->cs = 1211; goto _test_eof; 
	_test_eof1212:  sm->cs = 1212; goto _test_eof; 
	_test_eof1213:  sm->cs = 1213; goto _test_eof; 
	_test_eof1214:  sm->cs = 1214; goto _test_eof; 
	_test_eof1215:  sm->cs = 1215; goto _test_eof; 
	_test_eof1216:  sm->cs = 1216; goto _test_eof; 
	_test_eof1217:  sm->cs = 1217; goto _test_eof; 
	_test_eof1218:  sm->cs = 1218; goto _test_eof; 
	_test_eof1219:  sm->cs = 1219; goto _test_eof; 
	_test_eof1220:  sm->cs = 1220; goto _test_eof; 
	_test_eof1221:  sm->cs = 1221; goto _test_eof; 
	_test_eof1222:  sm->cs = 1222; goto _test_eof; 
	_test_eof1223:  sm->cs = 1223; goto _test_eof; 
	_test_eof1224:  sm->cs = 1224; goto _test_eof; 
	_test_eof1225:  sm->cs = 1225; goto _test_eof; 
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
	_test_eof1237:  sm->cs = 1237; goto _test_eof; 
	_test_eof1238:  sm->cs = 1238; goto _test_eof; 
	_test_eof1239:  sm->cs = 1239; goto _test_eof; 
	_test_eof1240:  sm->cs = 1240; goto _test_eof; 
	_test_eof1241:  sm->cs = 1241; goto _test_eof; 
	_test_eof1242:  sm->cs = 1242; goto _test_eof; 
	_test_eof1243:  sm->cs = 1243; goto _test_eof; 
	_test_eof1244:  sm->cs = 1244; goto _test_eof; 
	_test_eof1245:  sm->cs = 1245; goto _test_eof; 
	_test_eof1246:  sm->cs = 1246; goto _test_eof; 
	_test_eof1247:  sm->cs = 1247; goto _test_eof; 
	_test_eof1248:  sm->cs = 1248; goto _test_eof; 
	_test_eof1249:  sm->cs = 1249; goto _test_eof; 
	_test_eof1250:  sm->cs = 1250; goto _test_eof; 
	_test_eof1251:  sm->cs = 1251; goto _test_eof; 
	_test_eof1252:  sm->cs = 1252; goto _test_eof; 
	_test_eof1253:  sm->cs = 1253; goto _test_eof; 
	_test_eof1254:  sm->cs = 1254; goto _test_eof; 
	_test_eof1255:  sm->cs = 1255; goto _test_eof; 
	_test_eof1256:  sm->cs = 1256; goto _test_eof; 
	_test_eof1257:  sm->cs = 1257; goto _test_eof; 
	_test_eof1258:  sm->cs = 1258; goto _test_eof; 
	_test_eof1259:  sm->cs = 1259; goto _test_eof; 
	_test_eof1260:  sm->cs = 1260; goto _test_eof; 
	_test_eof1261:  sm->cs = 1261; goto _test_eof; 
	_test_eof1262:  sm->cs = 1262; goto _test_eof; 
	_test_eof1263:  sm->cs = 1263; goto _test_eof; 
	_test_eof1264:  sm->cs = 1264; goto _test_eof; 
	_test_eof1265:  sm->cs = 1265; goto _test_eof; 
	_test_eof1266:  sm->cs = 1266; goto _test_eof; 
	_test_eof1267:  sm->cs = 1267; goto _test_eof; 
	_test_eof1268:  sm->cs = 1268; goto _test_eof; 
	_test_eof1269:  sm->cs = 1269; goto _test_eof; 
	_test_eof1270:  sm->cs = 1270; goto _test_eof; 
	_test_eof1271:  sm->cs = 1271; goto _test_eof; 
	_test_eof1272:  sm->cs = 1272; goto _test_eof; 
	_test_eof1273:  sm->cs = 1273; goto _test_eof; 
	_test_eof1274:  sm->cs = 1274; goto _test_eof; 
	_test_eof1275:  sm->cs = 1275; goto _test_eof; 
	_test_eof1276:  sm->cs = 1276; goto _test_eof; 
	_test_eof1277:  sm->cs = 1277; goto _test_eof; 
	_test_eof1278:  sm->cs = 1278; goto _test_eof; 
	_test_eof1279:  sm->cs = 1279; goto _test_eof; 
	_test_eof1280:  sm->cs = 1280; goto _test_eof; 
	_test_eof1281:  sm->cs = 1281; goto _test_eof; 
	_test_eof1282:  sm->cs = 1282; goto _test_eof; 
	_test_eof1283:  sm->cs = 1283; goto _test_eof; 
	_test_eof1284:  sm->cs = 1284; goto _test_eof; 
	_test_eof1285:  sm->cs = 1285; goto _test_eof; 
	_test_eof1286:  sm->cs = 1286; goto _test_eof; 
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
	_test_eof1300:  sm->cs = 1300; goto _test_eof; 
	_test_eof1301:  sm->cs = 1301; goto _test_eof; 
	_test_eof1302:  sm->cs = 1302; goto _test_eof; 
	_test_eof1303:  sm->cs = 1303; goto _test_eof; 
	_test_eof1304:  sm->cs = 1304; goto _test_eof; 
	_test_eof1305:  sm->cs = 1305; goto _test_eof; 

	_test_eof: {}
	if ( ( sm->p) == ( sm->eof) )
	{
	switch (  sm->cs ) {
	case 1307: goto tr1684;
	case 1: goto tr0;
	case 1308: goto tr1685;
	case 2: goto tr3;
	case 3: goto tr3;
	case 4: goto tr3;
	case 5: goto tr3;
	case 6: goto tr3;
	case 1309: goto tr1686;
	case 7: goto tr3;
	case 8: goto tr3;
	case 9: goto tr3;
	case 10: goto tr3;
	case 11: goto tr3;
	case 12: goto tr3;
	case 13: goto tr3;
	case 14: goto tr3;
	case 15: goto tr3;
	case 16: goto tr3;
	case 17: goto tr3;
	case 18: goto tr3;
	case 19: goto tr3;
	case 1310: goto tr1685;
	case 20: goto tr3;
	case 1311: goto tr1687;
	case 1312: goto tr1687;
	case 21: goto tr3;
	case 1313: goto tr1685;
	case 22: goto tr3;
	case 23: goto tr3;
	case 24: goto tr3;
	case 25: goto tr3;
	case 26: goto tr3;
	case 27: goto tr3;
	case 28: goto tr3;
	case 29: goto tr3;
	case 30: goto tr3;
	case 31: goto tr3;
	case 1314: goto tr1695;
	case 32: goto tr3;
	case 33: goto tr3;
	case 34: goto tr3;
	case 35: goto tr3;
	case 36: goto tr3;
	case 37: goto tr3;
	case 38: goto tr3;
	case 1315: goto tr1696;
	case 39: goto tr47;
	case 1316: goto tr1697;
	case 40: goto tr50;
	case 41: goto tr3;
	case 42: goto tr3;
	case 43: goto tr3;
	case 44: goto tr3;
	case 45: goto tr3;
	case 46: goto tr3;
	case 47: goto tr3;
	case 48: goto tr3;
	case 1317: goto tr1698;
	case 49: goto tr3;
	case 1318: goto tr1700;
	case 50: goto tr3;
	case 51: goto tr3;
	case 52: goto tr3;
	case 53: goto tr3;
	case 54: goto tr3;
	case 55: goto tr3;
	case 56: goto tr3;
	case 1319: goto tr1701;
	case 57: goto tr74;
	case 58: goto tr3;
	case 59: goto tr3;
	case 60: goto tr3;
	case 61: goto tr3;
	case 62: goto tr3;
	case 63: goto tr3;
	case 64: goto tr3;
	case 1320: goto tr1702;
	case 65: goto tr3;
	case 66: goto tr3;
	case 67: goto tr3;
	case 1321: goto tr1685;
	case 68: goto tr3;
	case 69: goto tr3;
	case 70: goto tr3;
	case 1322: goto tr1704;
	case 1323: goto tr1685;
	case 71: goto tr3;
	case 72: goto tr3;
	case 73: goto tr3;
	case 74: goto tr3;
	case 75: goto tr3;
	case 76: goto tr3;
	case 77: goto tr3;
	case 78: goto tr3;
	case 79: goto tr3;
	case 80: goto tr3;
	case 81: goto tr3;
	case 82: goto tr3;
	case 83: goto tr3;
	case 84: goto tr3;
	case 85: goto tr3;
	case 86: goto tr3;
	case 87: goto tr3;
	case 88: goto tr3;
	case 89: goto tr3;
	case 90: goto tr3;
	case 91: goto tr3;
	case 92: goto tr3;
	case 93: goto tr3;
	case 94: goto tr3;
	case 95: goto tr3;
	case 96: goto tr3;
	case 97: goto tr3;
	case 98: goto tr3;
	case 99: goto tr3;
	case 100: goto tr3;
	case 101: goto tr3;
	case 102: goto tr3;
	case 103: goto tr3;
	case 104: goto tr3;
	case 105: goto tr3;
	case 106: goto tr3;
	case 107: goto tr3;
	case 108: goto tr3;
	case 1324: goto tr1685;
	case 109: goto tr3;
	case 110: goto tr3;
	case 111: goto tr3;
	case 112: goto tr3;
	case 113: goto tr3;
	case 114: goto tr3;
	case 115: goto tr3;
	case 116: goto tr3;
	case 117: goto tr3;
	case 118: goto tr3;
	case 1326: goto tr1717;
	case 119: goto tr145;
	case 120: goto tr145;
	case 121: goto tr145;
	case 122: goto tr145;
	case 123: goto tr145;
	case 124: goto tr145;
	case 125: goto tr145;
	case 126: goto tr145;
	case 127: goto tr145;
	case 128: goto tr145;
	case 129: goto tr145;
	case 130: goto tr145;
	case 131: goto tr145;
	case 132: goto tr145;
	case 133: goto tr145;
	case 134: goto tr145;
	case 135: goto tr145;
	case 136: goto tr145;
	case 137: goto tr145;
	case 1327: goto tr1717;
	case 138: goto tr145;
	case 139: goto tr145;
	case 140: goto tr145;
	case 141: goto tr145;
	case 142: goto tr145;
	case 143: goto tr145;
	case 144: goto tr145;
	case 145: goto tr145;
	case 146: goto tr145;
	case 1329: goto tr1759;
	case 1330: goto tr1760;
	case 147: goto tr173;
	case 148: goto tr173;
	case 149: goto tr176;
	case 1331: goto tr1759;
	case 1332: goto tr1759;
	case 1333: goto tr173;
	case 150: goto tr173;
	case 1334: goto tr1759;
	case 151: goto tr180;
	case 1335: goto tr1762;
	case 152: goto tr182;
	case 153: goto tr182;
	case 154: goto tr182;
	case 155: goto tr182;
	case 156: goto tr182;
	case 1336: goto tr1769;
	case 157: goto tr182;
	case 158: goto tr182;
	case 159: goto tr182;
	case 160: goto tr182;
	case 161: goto tr182;
	case 162: goto tr182;
	case 163: goto tr182;
	case 164: goto tr182;
	case 165: goto tr182;
	case 166: goto tr182;
	case 167: goto tr182;
	case 168: goto tr182;
	case 169: goto tr182;
	case 170: goto tr182;
	case 171: goto tr182;
	case 172: goto tr182;
	case 173: goto tr182;
	case 174: goto tr182;
	case 175: goto tr182;
	case 176: goto tr182;
	case 177: goto tr182;
	case 178: goto tr182;
	case 179: goto tr182;
	case 180: goto tr182;
	case 181: goto tr182;
	case 182: goto tr182;
	case 183: goto tr182;
	case 184: goto tr182;
	case 185: goto tr182;
	case 186: goto tr182;
	case 1337: goto tr1770;
	case 187: goto tr221;
	case 188: goto tr221;
	case 189: goto tr173;
	case 190: goto tr173;
	case 191: goto tr173;
	case 192: goto tr173;
	case 193: goto tr221;
	case 194: goto tr221;
	case 195: goto tr173;
	case 196: goto tr173;
	case 197: goto tr173;
	case 198: goto tr173;
	case 199: goto tr182;
	case 200: goto tr182;
	case 1338: goto tr1773;
	case 1339: goto tr1773;
	case 201: goto tr182;
	case 202: goto tr182;
	case 203: goto tr182;
	case 204: goto tr173;
	case 205: goto tr173;
	case 206: goto tr173;
	case 207: goto tr173;
	case 208: goto tr173;
	case 209: goto tr173;
	case 210: goto tr173;
	case 211: goto tr173;
	case 212: goto tr173;
	case 1340: goto tr1775;
	case 213: goto tr182;
	case 214: goto tr173;
	case 215: goto tr173;
	case 216: goto tr173;
	case 217: goto tr173;
	case 218: goto tr173;
	case 1341: goto tr1776;
	case 219: goto tr173;
	case 220: goto tr173;
	case 221: goto tr173;
	case 222: goto tr173;
	case 223: goto tr173;
	case 224: goto tr182;
	case 225: goto tr173;
	case 226: goto tr173;
	case 227: goto tr173;
	case 228: goto tr173;
	case 229: goto tr173;
	case 230: goto tr173;
	case 231: goto tr173;
	case 232: goto tr182;
	case 233: goto tr182;
	case 234: goto tr182;
	case 235: goto tr182;
	case 236: goto tr182;
	case 237: goto tr182;
	case 238: goto tr182;
	case 239: goto tr182;
	case 240: goto tr182;
	case 241: goto tr182;
	case 242: goto tr182;
	case 243: goto tr182;
	case 244: goto tr182;
	case 245: goto tr182;
	case 246: goto tr182;
	case 247: goto tr182;
	case 248: goto tr182;
	case 249: goto tr182;
	case 1342: goto tr1777;
	case 250: goto tr182;
	case 251: goto tr182;
	case 252: goto tr182;
	case 253: goto tr182;
	case 254: goto tr182;
	case 255: goto tr182;
	case 256: goto tr182;
	case 257: goto tr182;
	case 258: goto tr182;
	case 259: goto tr182;
	case 260: goto tr182;
	case 261: goto tr182;
	case 262: goto tr182;
	case 263: goto tr182;
	case 264: goto tr182;
	case 265: goto tr182;
	case 266: goto tr182;
	case 267: goto tr182;
	case 268: goto tr182;
	case 269: goto tr182;
	case 270: goto tr182;
	case 271: goto tr182;
	case 272: goto tr182;
	case 273: goto tr182;
	case 274: goto tr182;
	case 275: goto tr182;
	case 276: goto tr182;
	case 277: goto tr182;
	case 278: goto tr182;
	case 279: goto tr182;
	case 280: goto tr182;
	case 281: goto tr182;
	case 282: goto tr182;
	case 283: goto tr182;
	case 284: goto tr182;
	case 285: goto tr182;
	case 286: goto tr182;
	case 287: goto tr182;
	case 288: goto tr182;
	case 289: goto tr182;
	case 290: goto tr182;
	case 1343: goto tr1759;
	case 291: goto tr180;
	case 292: goto tr180;
	case 293: goto tr180;
	case 1344: goto tr1780;
	case 294: goto tr350;
	case 295: goto tr350;
	case 296: goto tr350;
	case 297: goto tr350;
	case 298: goto tr350;
	case 299: goto tr350;
	case 300: goto tr350;
	case 301: goto tr350;
	case 302: goto tr350;
	case 303: goto tr350;
	case 304: goto tr350;
	case 1345: goto tr1780;
	case 305: goto tr350;
	case 306: goto tr350;
	case 307: goto tr350;
	case 308: goto tr350;
	case 309: goto tr350;
	case 310: goto tr350;
	case 311: goto tr350;
	case 312: goto tr350;
	case 313: goto tr350;
	case 314: goto tr350;
	case 315: goto tr350;
	case 316: goto tr173;
	case 317: goto tr173;
	case 1346: goto tr1780;
	case 318: goto tr173;
	case 319: goto tr173;
	case 320: goto tr173;
	case 321: goto tr173;
	case 322: goto tr173;
	case 323: goto tr173;
	case 324: goto tr173;
	case 325: goto tr173;
	case 326: goto tr173;
	case 327: goto tr180;
	case 328: goto tr180;
	case 329: goto tr180;
	case 330: goto tr180;
	case 331: goto tr180;
	case 332: goto tr180;
	case 333: goto tr180;
	case 334: goto tr180;
	case 335: goto tr180;
	case 336: goto tr180;
	case 337: goto tr180;
	case 338: goto tr173;
	case 339: goto tr173;
	case 1347: goto tr1780;
	case 340: goto tr173;
	case 341: goto tr173;
	case 342: goto tr173;
	case 343: goto tr173;
	case 344: goto tr173;
	case 345: goto tr173;
	case 346: goto tr173;
	case 347: goto tr173;
	case 348: goto tr173;
	case 349: goto tr173;
	case 350: goto tr173;
	case 1348: goto tr1780;
	case 351: goto tr180;
	case 352: goto tr180;
	case 353: goto tr180;
	case 354: goto tr180;
	case 355: goto tr180;
	case 356: goto tr180;
	case 357: goto tr180;
	case 358: goto tr180;
	case 359: goto tr180;
	case 360: goto tr180;
	case 361: goto tr180;
	case 1349: goto tr1760;
	case 362: goto tr176;
	case 363: goto tr176;
	case 364: goto tr173;
	case 365: goto tr173;
	case 366: goto tr173;
	case 367: goto tr173;
	case 368: goto tr173;
	case 369: goto tr173;
	case 370: goto tr173;
	case 1350: goto tr1784;
	case 1351: goto tr1786;
	case 371: goto tr173;
	case 372: goto tr173;
	case 373: goto tr173;
	case 374: goto tr173;
	case 1352: goto tr1788;
	case 1353: goto tr1790;
	case 375: goto tr173;
	case 376: goto tr173;
	case 377: goto tr176;
	case 378: goto tr176;
	case 379: goto tr176;
	case 380: goto tr176;
	case 381: goto tr176;
	case 382: goto tr176;
	case 383: goto tr176;
	case 1354: goto tr1784;
	case 1355: goto tr1786;
	case 384: goto tr176;
	case 385: goto tr176;
	case 386: goto tr176;
	case 387: goto tr176;
	case 388: goto tr176;
	case 389: goto tr176;
	case 390: goto tr176;
	case 391: goto tr176;
	case 392: goto tr176;
	case 393: goto tr176;
	case 394: goto tr176;
	case 395: goto tr176;
	case 396: goto tr176;
	case 397: goto tr176;
	case 398: goto tr176;
	case 399: goto tr176;
	case 400: goto tr176;
	case 401: goto tr176;
	case 402: goto tr176;
	case 403: goto tr176;
	case 404: goto tr176;
	case 405: goto tr176;
	case 406: goto tr176;
	case 407: goto tr176;
	case 408: goto tr176;
	case 409: goto tr176;
	case 410: goto tr176;
	case 411: goto tr176;
	case 412: goto tr176;
	case 413: goto tr176;
	case 414: goto tr176;
	case 415: goto tr176;
	case 416: goto tr173;
	case 417: goto tr173;
	case 418: goto tr173;
	case 419: goto tr173;
	case 420: goto tr173;
	case 421: goto tr173;
	case 422: goto tr173;
	case 423: goto tr173;
	case 424: goto tr173;
	case 425: goto tr173;
	case 426: goto tr173;
	case 1356: goto tr1794;
	case 1357: goto tr1796;
	case 427: goto tr173;
	case 1358: goto tr1798;
	case 1359: goto tr1800;
	case 428: goto tr173;
	case 429: goto tr173;
	case 430: goto tr173;
	case 431: goto tr173;
	case 432: goto tr173;
	case 433: goto tr173;
	case 434: goto tr173;
	case 435: goto tr173;
	case 1360: goto tr1798;
	case 1361: goto tr1800;
	case 436: goto tr173;
	case 1362: goto tr1798;
	case 437: goto tr173;
	case 438: goto tr173;
	case 439: goto tr173;
	case 440: goto tr173;
	case 441: goto tr173;
	case 442: goto tr173;
	case 443: goto tr173;
	case 444: goto tr173;
	case 445: goto tr173;
	case 446: goto tr173;
	case 447: goto tr173;
	case 448: goto tr173;
	case 449: goto tr173;
	case 450: goto tr173;
	case 451: goto tr173;
	case 452: goto tr173;
	case 453: goto tr173;
	case 454: goto tr173;
	case 1363: goto tr1798;
	case 455: goto tr173;
	case 456: goto tr173;
	case 457: goto tr173;
	case 458: goto tr173;
	case 459: goto tr173;
	case 460: goto tr173;
	case 461: goto tr173;
	case 462: goto tr173;
	case 463: goto tr173;
	case 1364: goto tr1760;
	case 1365: goto tr1760;
	case 1366: goto tr1760;
	case 1367: goto tr1760;
	case 1368: goto tr1760;
	case 464: goto tr176;
	case 465: goto tr176;
	case 1369: goto tr1813;
	case 1370: goto tr1760;
	case 1371: goto tr1760;
	case 1372: goto tr1760;
	case 1373: goto tr1760;
	case 1374: goto tr1760;
	case 466: goto tr176;
	case 467: goto tr176;
	case 1375: goto tr1820;
	case 1376: goto tr1760;
	case 1377: goto tr1760;
	case 1378: goto tr1760;
	case 1379: goto tr1760;
	case 1380: goto tr1760;
	case 468: goto tr176;
	case 469: goto tr176;
	case 1381: goto tr1828;
	case 1382: goto tr1760;
	case 1383: goto tr1760;
	case 1384: goto tr1760;
	case 1385: goto tr1760;
	case 1386: goto tr1760;
	case 1387: goto tr1760;
	case 1388: goto tr1760;
	case 470: goto tr176;
	case 471: goto tr176;
	case 1389: goto tr1837;
	case 1390: goto tr1760;
	case 1391: goto tr1760;
	case 1392: goto tr1760;
	case 1393: goto tr1760;
	case 472: goto tr176;
	case 473: goto tr176;
	case 1394: goto tr1843;
	case 1395: goto tr1760;
	case 1396: goto tr1760;
	case 1397: goto tr1760;
	case 474: goto tr176;
	case 475: goto tr176;
	case 1398: goto tr1849;
	case 1399: goto tr1760;
	case 1400: goto tr1760;
	case 476: goto tr176;
	case 477: goto tr176;
	case 1401: goto tr1853;
	case 1402: goto tr1760;
	case 1403: goto tr1760;
	case 1404: goto tr1760;
	case 1405: goto tr1760;
	case 1406: goto tr1760;
	case 1407: goto tr1760;
	case 1408: goto tr1760;
	case 478: goto tr176;
	case 479: goto tr176;
	case 1409: goto tr1863;
	case 1410: goto tr1760;
	case 1411: goto tr1760;
	case 480: goto tr176;
	case 481: goto tr176;
	case 1412: goto tr1867;
	case 1413: goto tr1760;
	case 1414: goto tr1760;
	case 1415: goto tr1760;
	case 1416: goto tr1760;
	case 1417: goto tr1760;
	case 1418: goto tr1760;
	case 1419: goto tr1760;
	case 1420: goto tr1760;
	case 1421: goto tr1760;
	case 1422: goto tr1760;
	case 482: goto tr176;
	case 483: goto tr176;
	case 1423: goto tr1880;
	case 1424: goto tr1760;
	case 1425: goto tr1760;
	case 1426: goto tr1760;
	case 1427: goto tr1760;
	case 484: goto tr176;
	case 485: goto tr176;
	case 1428: goto tr1886;
	case 486: goto tr622;
	case 1429: goto tr1889;
	case 1430: goto tr1760;
	case 1431: goto tr1760;
	case 1432: goto tr1760;
	case 1433: goto tr1760;
	case 1434: goto tr1760;
	case 1435: goto tr1760;
	case 1436: goto tr1760;
	case 1437: goto tr1760;
	case 487: goto tr176;
	case 488: goto tr176;
	case 1438: goto tr1902;
	case 1439: goto tr1760;
	case 1440: goto tr1760;
	case 1441: goto tr1760;
	case 1442: goto tr1760;
	case 1443: goto tr1760;
	case 1444: goto tr1760;
	case 1445: goto tr1760;
	case 489: goto tr176;
	case 490: goto tr176;
	case 1446: goto tr1911;
	case 1447: goto tr1760;
	case 1448: goto tr1760;
	case 1449: goto tr1760;
	case 491: goto tr176;
	case 492: goto tr176;
	case 1450: goto tr1916;
	case 1451: goto tr1760;
	case 1452: goto tr1760;
	case 1453: goto tr1760;
	case 1454: goto tr1760;
	case 493: goto tr176;
	case 494: goto tr176;
	case 1455: goto tr1922;
	case 1456: goto tr1760;
	case 1457: goto tr1760;
	case 1458: goto tr1760;
	case 1459: goto tr1760;
	case 1460: goto tr1760;
	case 1461: goto tr1760;
	case 1462: goto tr1760;
	case 1463: goto tr1760;
	case 495: goto tr176;
	case 496: goto tr176;
	case 1464: goto tr1932;
	case 1465: goto tr1760;
	case 1466: goto tr1760;
	case 1467: goto tr1760;
	case 1468: goto tr1760;
	case 497: goto tr176;
	case 498: goto tr176;
	case 499: goto tr176;
	case 500: goto tr176;
	case 501: goto tr176;
	case 502: goto tr176;
	case 503: goto tr176;
	case 504: goto tr173;
	case 505: goto tr173;
	case 1469: goto tr1939;
	case 506: goto tr173;
	case 507: goto tr173;
	case 508: goto tr173;
	case 509: goto tr173;
	case 510: goto tr173;
	case 511: goto tr173;
	case 512: goto tr173;
	case 513: goto tr173;
	case 514: goto tr173;
	case 515: goto tr173;
	case 1470: goto tr1939;
	case 516: goto tr657;
	case 517: goto tr657;
	case 518: goto tr657;
	case 519: goto tr657;
	case 520: goto tr657;
	case 521: goto tr657;
	case 522: goto tr657;
	case 523: goto tr657;
	case 524: goto tr657;
	case 525: goto tr657;
	case 526: goto tr657;
	case 1471: goto tr1939;
	case 527: goto tr657;
	case 528: goto tr657;
	case 529: goto tr657;
	case 530: goto tr657;
	case 531: goto tr657;
	case 532: goto tr657;
	case 533: goto tr657;
	case 534: goto tr657;
	case 535: goto tr657;
	case 536: goto tr657;
	case 537: goto tr657;
	case 538: goto tr173;
	case 539: goto tr173;
	case 1472: goto tr1939;
	case 540: goto tr173;
	case 541: goto tr173;
	case 542: goto tr173;
	case 543: goto tr173;
	case 544: goto tr173;
	case 545: goto tr173;
	case 546: goto tr173;
	case 547: goto tr173;
	case 548: goto tr173;
	case 549: goto tr173;
	case 1473: goto tr1939;
	case 1474: goto tr1760;
	case 1475: goto tr1760;
	case 1476: goto tr1760;
	case 1477: goto tr1760;
	case 1478: goto tr1760;
	case 1479: goto tr1760;
	case 1480: goto tr1760;
	case 1481: goto tr1760;
	case 1482: goto tr1760;
	case 1483: goto tr1760;
	case 1484: goto tr1760;
	case 1485: goto tr1760;
	case 550: goto tr176;
	case 551: goto tr176;
	case 1486: goto tr1952;
	case 1487: goto tr1760;
	case 1488: goto tr1760;
	case 1489: goto tr1760;
	case 1490: goto tr1760;
	case 552: goto tr176;
	case 553: goto tr176;
	case 1491: goto tr1958;
	case 1492: goto tr1760;
	case 1493: goto tr1760;
	case 1494: goto tr1760;
	case 1495: goto tr1760;
	case 1496: goto tr1760;
	case 554: goto tr176;
	case 555: goto tr176;
	case 556: goto tr176;
	case 557: goto tr176;
	case 558: goto tr176;
	case 559: goto tr176;
	case 560: goto tr176;
	case 561: goto tr176;
	case 1497: goto tr1966;
	case 1498: goto tr1760;
	case 1499: goto tr1760;
	case 562: goto tr176;
	case 563: goto tr176;
	case 564: goto tr176;
	case 565: goto tr176;
	case 566: goto tr176;
	case 567: goto tr176;
	case 568: goto tr176;
	case 569: goto tr176;
	case 570: goto tr176;
	case 1500: goto tr1971;
	case 1501: goto tr1760;
	case 1502: goto tr1760;
	case 1503: goto tr1760;
	case 1504: goto tr1760;
	case 1505: goto tr1760;
	case 1506: goto tr1760;
	case 571: goto tr176;
	case 572: goto tr176;
	case 1507: goto tr1979;
	case 1508: goto tr1760;
	case 1509: goto tr1760;
	case 1510: goto tr1760;
	case 1511: goto tr1760;
	case 1512: goto tr1760;
	case 573: goto tr176;
	case 574: goto tr176;
	case 1513: goto tr1987;
	case 1514: goto tr1760;
	case 1515: goto tr1760;
	case 1516: goto tr1760;
	case 575: goto tr176;
	case 576: goto tr176;
	case 1517: goto tr1992;
	case 1518: goto tr1760;
	case 1519: goto tr1760;
	case 1520: goto tr1760;
	case 1521: goto tr1760;
	case 1522: goto tr1760;
	case 577: goto tr176;
	case 578: goto tr176;
	case 1523: goto tr2002;
	case 1524: goto tr1760;
	case 1525: goto tr1760;
	case 1526: goto tr1760;
	case 1527: goto tr1760;
	case 579: goto tr176;
	case 580: goto tr176;
	case 1528: goto tr2008;
	case 581: goto tr723;
	case 582: goto tr723;
	case 1529: goto tr2011;
	case 1530: goto tr1760;
	case 1531: goto tr1760;
	case 1532: goto tr1760;
	case 583: goto tr176;
	case 584: goto tr176;
	case 1533: goto tr2017;
	case 1534: goto tr1760;
	case 1535: goto tr1760;
	case 585: goto tr176;
	case 586: goto tr176;
	case 1536: goto tr2021;
	case 1537: goto tr1760;
	case 1538: goto tr1760;
	case 1539: goto tr1760;
	case 587: goto tr176;
	case 588: goto tr176;
	case 1540: goto tr2026;
	case 1541: goto tr1760;
	case 1542: goto tr1760;
	case 1543: goto tr1760;
	case 1544: goto tr1760;
	case 1545: goto tr1760;
	case 1546: goto tr1760;
	case 1547: goto tr1760;
	case 589: goto tr176;
	case 590: goto tr176;
	case 1548: goto tr2036;
	case 1549: goto tr1760;
	case 1550: goto tr1760;
	case 1551: goto tr1760;
	case 1552: goto tr1760;
	case 591: goto tr176;
	case 592: goto tr176;
	case 1553: goto tr2042;
	case 1554: goto tr1760;
	case 1555: goto tr1760;
	case 1556: goto tr1760;
	case 1557: goto tr1760;
	case 1558: goto tr1760;
	case 593: goto tr176;
	case 594: goto tr176;
	case 1559: goto tr2050;
	case 595: goto tr738;
	case 596: goto tr738;
	case 1560: goto tr2053;
	case 1561: goto tr1760;
	case 1562: goto tr1760;
	case 1563: goto tr1760;
	case 1564: goto tr1760;
	case 1565: goto tr1760;
	case 1566: goto tr1760;
	case 597: goto tr176;
	case 598: goto tr176;
	case 1567: goto tr2061;
	case 1568: goto tr1760;
	case 1569: goto tr1760;
	case 1570: goto tr1760;
	case 1571: goto tr1760;
	case 599: goto tr176;
	case 600: goto tr176;
	case 1572: goto tr2067;
	case 1573: goto tr1760;
	case 1574: goto tr1760;
	case 1575: goto tr1760;
	case 1576: goto tr1760;
	case 601: goto tr176;
	case 602: goto tr176;
	case 1577: goto tr2073;
	case 1578: goto tr1760;
	case 1579: goto tr1760;
	case 1580: goto tr1760;
	case 1581: goto tr1760;
	case 1582: goto tr1760;
	case 1583: goto tr1760;
	case 1584: goto tr1760;
	case 603: goto tr176;
	case 604: goto tr176;
	case 1585: goto tr2082;
	case 1586: goto tr1759;
	case 605: goto tr180;
	case 606: goto tr180;
	case 607: goto tr173;
	case 608: goto tr173;
	case 609: goto tr173;
	case 610: goto tr173;
	case 611: goto tr173;
	case 612: goto tr173;
	case 613: goto tr173;
	case 614: goto tr173;
	case 615: goto tr173;
	case 616: goto tr173;
	case 617: goto tr180;
	case 618: goto tr180;
	case 619: goto tr180;
	case 620: goto tr180;
	case 621: goto tr180;
	case 622: goto tr180;
	case 623: goto tr180;
	case 624: goto tr180;
	case 625: goto tr180;
	case 626: goto tr180;
	case 627: goto tr180;
	case 628: goto tr180;
	case 629: goto tr180;
	case 630: goto tr180;
	case 631: goto tr180;
	case 632: goto tr180;
	case 633: goto tr180;
	case 634: goto tr180;
	case 635: goto tr180;
	case 636: goto tr180;
	case 637: goto tr180;
	case 638: goto tr180;
	case 639: goto tr180;
	case 640: goto tr180;
	case 641: goto tr180;
	case 642: goto tr180;
	case 643: goto tr180;
	case 644: goto tr180;
	case 645: goto tr180;
	case 646: goto tr180;
	case 647: goto tr180;
	case 648: goto tr180;
	case 649: goto tr180;
	case 650: goto tr180;
	case 651: goto tr180;
	case 652: goto tr180;
	case 653: goto tr180;
	case 654: goto tr180;
	case 655: goto tr180;
	case 656: goto tr180;
	case 657: goto tr180;
	case 658: goto tr180;
	case 659: goto tr180;
	case 660: goto tr180;
	case 661: goto tr180;
	case 662: goto tr180;
	case 663: goto tr180;
	case 664: goto tr180;
	case 665: goto tr180;
	case 666: goto tr180;
	case 667: goto tr180;
	case 668: goto tr180;
	case 669: goto tr180;
	case 670: goto tr180;
	case 671: goto tr180;
	case 672: goto tr180;
	case 673: goto tr180;
	case 674: goto tr180;
	case 675: goto tr180;
	case 676: goto tr180;
	case 1587: goto tr2097;
	case 677: goto tr829;
	case 1588: goto tr2098;
	case 678: goto tr832;
	case 679: goto tr180;
	case 680: goto tr180;
	case 681: goto tr180;
	case 682: goto tr180;
	case 683: goto tr180;
	case 684: goto tr180;
	case 685: goto tr180;
	case 686: goto tr180;
	case 1589: goto tr2099;
	case 687: goto tr180;
	case 688: goto tr180;
	case 689: goto tr180;
	case 690: goto tr180;
	case 691: goto tr180;
	case 692: goto tr180;
	case 693: goto tr180;
	case 694: goto tr180;
	case 695: goto tr180;
	case 696: goto tr180;
	case 697: goto tr173;
	case 698: goto tr173;
	case 699: goto tr173;
	case 700: goto tr173;
	case 701: goto tr180;
	case 702: goto tr180;
	case 703: goto tr180;
	case 704: goto tr180;
	case 705: goto tr180;
	case 706: goto tr180;
	case 707: goto tr180;
	case 708: goto tr180;
	case 709: goto tr180;
	case 1590: goto tr173;
	case 710: goto tr180;
	case 711: goto tr180;
	case 712: goto tr180;
	case 713: goto tr180;
	case 1591: goto tr2100;
	case 714: goto tr180;
	case 715: goto tr180;
	case 1592: goto tr2100;
	case 716: goto tr180;
	case 717: goto tr180;
	case 718: goto tr180;
	case 719: goto tr180;
	case 720: goto tr180;
	case 721: goto tr180;
	case 722: goto tr180;
	case 723: goto tr180;
	case 724: goto tr180;
	case 725: goto tr180;
	case 726: goto tr180;
	case 727: goto tr180;
	case 728: goto tr180;
	case 729: goto tr180;
	case 730: goto tr180;
	case 731: goto tr180;
	case 732: goto tr180;
	case 1593: goto tr2101;
	case 733: goto tr902;
	case 734: goto tr180;
	case 735: goto tr180;
	case 736: goto tr180;
	case 737: goto tr180;
	case 738: goto tr180;
	case 739: goto tr180;
	case 740: goto tr180;
	case 741: goto tr180;
	case 742: goto tr180;
	case 743: goto tr180;
	case 744: goto tr180;
	case 745: goto tr180;
	case 746: goto tr180;
	case 747: goto tr180;
	case 748: goto tr180;
	case 749: goto tr180;
	case 750: goto tr180;
	case 751: goto tr180;
	case 752: goto tr180;
	case 753: goto tr180;
	case 754: goto tr180;
	case 755: goto tr180;
	case 756: goto tr180;
	case 757: goto tr180;
	case 758: goto tr180;
	case 759: goto tr173;
	case 760: goto tr173;
	case 761: goto tr173;
	case 762: goto tr173;
	case 763: goto tr173;
	case 764: goto tr173;
	case 765: goto tr173;
	case 766: goto tr173;
	case 767: goto tr180;
	case 768: goto tr180;
	case 1594: goto tr2100;
	case 769: goto tr180;
	case 770: goto tr180;
	case 771: goto tr180;
	case 772: goto tr180;
	case 773: goto tr180;
	case 774: goto tr180;
	case 775: goto tr180;
	case 776: goto tr180;
	case 777: goto tr180;
	case 778: goto tr180;
	case 779: goto tr180;
	case 780: goto tr180;
	case 781: goto tr180;
	case 782: goto tr180;
	case 783: goto tr173;
	case 784: goto tr173;
	case 785: goto tr173;
	case 786: goto tr180;
	case 787: goto tr180;
	case 788: goto tr180;
	case 789: goto tr180;
	case 1595: goto tr2100;
	case 790: goto tr180;
	case 791: goto tr180;
	case 792: goto tr180;
	case 793: goto tr180;
	case 794: goto tr180;
	case 795: goto tr180;
	case 796: goto tr180;
	case 797: goto tr180;
	case 798: goto tr180;
	case 799: goto tr180;
	case 800: goto tr180;
	case 801: goto tr180;
	case 802: goto tr180;
	case 803: goto tr180;
	case 804: goto tr180;
	case 805: goto tr180;
	case 806: goto tr180;
	case 807: goto tr180;
	case 808: goto tr180;
	case 809: goto tr180;
	case 810: goto tr173;
	case 811: goto tr180;
	case 812: goto tr180;
	case 1596: goto tr2100;
	case 813: goto tr180;
	case 814: goto tr180;
	case 815: goto tr180;
	case 816: goto tr180;
	case 817: goto tr180;
	case 818: goto tr180;
	case 819: goto tr180;
	case 820: goto tr180;
	case 821: goto tr180;
	case 822: goto tr180;
	case 823: goto tr180;
	case 824: goto tr180;
	case 825: goto tr180;
	case 826: goto tr180;
	case 827: goto tr180;
	case 828: goto tr180;
	case 829: goto tr180;
	case 830: goto tr180;
	case 831: goto tr180;
	case 832: goto tr180;
	case 833: goto tr180;
	case 834: goto tr180;
	case 835: goto tr180;
	case 836: goto tr180;
	case 837: goto tr173;
	case 838: goto tr180;
	case 839: goto tr180;
	case 1597: goto tr2100;
	case 840: goto tr180;
	case 841: goto tr180;
	case 842: goto tr180;
	case 843: goto tr180;
	case 844: goto tr180;
	case 845: goto tr180;
	case 846: goto tr180;
	case 847: goto tr180;
	case 848: goto tr180;
	case 849: goto tr180;
	case 850: goto tr180;
	case 851: goto tr180;
	case 852: goto tr180;
	case 853: goto tr180;
	case 854: goto tr180;
	case 855: goto tr180;
	case 856: goto tr180;
	case 857: goto tr180;
	case 858: goto tr180;
	case 859: goto tr180;
	case 860: goto tr180;
	case 861: goto tr180;
	case 862: goto tr180;
	case 863: goto tr180;
	case 864: goto tr180;
	case 865: goto tr180;
	case 866: goto tr180;
	case 867: goto tr180;
	case 868: goto tr180;
	case 869: goto tr180;
	case 870: goto tr180;
	case 871: goto tr180;
	case 872: goto tr180;
	case 873: goto tr180;
	case 874: goto tr180;
	case 875: goto tr180;
	case 876: goto tr180;
	case 877: goto tr180;
	case 878: goto tr180;
	case 879: goto tr180;
	case 880: goto tr180;
	case 881: goto tr180;
	case 882: goto tr180;
	case 883: goto tr180;
	case 884: goto tr180;
	case 885: goto tr180;
	case 886: goto tr180;
	case 887: goto tr180;
	case 888: goto tr180;
	case 889: goto tr180;
	case 890: goto tr180;
	case 891: goto tr180;
	case 892: goto tr180;
	case 893: goto tr180;
	case 894: goto tr180;
	case 895: goto tr180;
	case 896: goto tr180;
	case 897: goto tr180;
	case 898: goto tr180;
	case 899: goto tr180;
	case 900: goto tr180;
	case 901: goto tr180;
	case 902: goto tr180;
	case 903: goto tr180;
	case 904: goto tr180;
	case 905: goto tr180;
	case 906: goto tr180;
	case 907: goto tr180;
	case 908: goto tr180;
	case 909: goto tr180;
	case 910: goto tr180;
	case 911: goto tr180;
	case 912: goto tr180;
	case 913: goto tr180;
	case 914: goto tr180;
	case 915: goto tr180;
	case 916: goto tr180;
	case 917: goto tr180;
	case 918: goto tr180;
	case 919: goto tr180;
	case 920: goto tr180;
	case 921: goto tr180;
	case 1598: goto tr1759;
	case 1599: goto tr1759;
	case 922: goto tr180;
	case 923: goto tr180;
	case 924: goto tr180;
	case 925: goto tr180;
	case 926: goto tr180;
	case 927: goto tr180;
	case 928: goto tr180;
	case 929: goto tr180;
	case 930: goto tr180;
	case 931: goto tr180;
	case 932: goto tr180;
	case 933: goto tr180;
	case 934: goto tr180;
	case 935: goto tr180;
	case 936: goto tr180;
	case 937: goto tr180;
	case 938: goto tr180;
	case 939: goto tr180;
	case 940: goto tr180;
	case 941: goto tr180;
	case 942: goto tr180;
	case 943: goto tr180;
	case 944: goto tr180;
	case 945: goto tr180;
	case 946: goto tr180;
	case 947: goto tr180;
	case 948: goto tr180;
	case 949: goto tr180;
	case 950: goto tr180;
	case 951: goto tr180;
	case 952: goto tr180;
	case 953: goto tr180;
	case 954: goto tr180;
	case 955: goto tr180;
	case 956: goto tr180;
	case 957: goto tr180;
	case 958: goto tr180;
	case 959: goto tr180;
	case 960: goto tr180;
	case 961: goto tr180;
	case 962: goto tr180;
	case 963: goto tr180;
	case 964: goto tr180;
	case 965: goto tr180;
	case 966: goto tr180;
	case 967: goto tr180;
	case 968: goto tr180;
	case 969: goto tr180;
	case 970: goto tr180;
	case 971: goto tr180;
	case 972: goto tr180;
	case 973: goto tr180;
	case 1600: goto tr2097;
	case 974: goto tr180;
	case 975: goto tr180;
	case 976: goto tr180;
	case 977: goto tr180;
	case 978: goto tr180;
	case 979: goto tr180;
	case 980: goto tr180;
	case 981: goto tr180;
	case 982: goto tr180;
	case 983: goto tr180;
	case 984: goto tr180;
	case 985: goto tr180;
	case 986: goto tr180;
	case 987: goto tr180;
	case 988: goto tr180;
	case 989: goto tr180;
	case 990: goto tr180;
	case 991: goto tr180;
	case 992: goto tr180;
	case 993: goto tr180;
	case 994: goto tr180;
	case 995: goto tr180;
	case 996: goto tr180;
	case 997: goto tr180;
	case 998: goto tr180;
	case 999: goto tr180;
	case 1000: goto tr180;
	case 1001: goto tr180;
	case 1002: goto tr180;
	case 1003: goto tr180;
	case 1004: goto tr180;
	case 1005: goto tr180;
	case 1006: goto tr180;
	case 1007: goto tr180;
	case 1008: goto tr180;
	case 1009: goto tr180;
	case 1010: goto tr180;
	case 1011: goto tr180;
	case 1012: goto tr180;
	case 1013: goto tr180;
	case 1014: goto tr180;
	case 1015: goto tr180;
	case 1601: goto tr1759;
	case 1016: goto tr180;
	case 1017: goto tr180;
	case 1602: goto tr1759;
	case 1018: goto tr180;
	case 1019: goto tr173;
	case 1020: goto tr173;
	case 1021: goto tr173;
	case 1603: goto tr2121;
	case 1022: goto tr173;
	case 1023: goto tr173;
	case 1024: goto tr173;
	case 1025: goto tr173;
	case 1026: goto tr173;
	case 1027: goto tr173;
	case 1028: goto tr173;
	case 1029: goto tr173;
	case 1030: goto tr173;
	case 1031: goto tr173;
	case 1604: goto tr2121;
	case 1032: goto tr173;
	case 1033: goto tr173;
	case 1034: goto tr173;
	case 1035: goto tr173;
	case 1036: goto tr173;
	case 1037: goto tr173;
	case 1038: goto tr173;
	case 1039: goto tr173;
	case 1040: goto tr173;
	case 1041: goto tr173;
	case 1042: goto tr180;
	case 1043: goto tr180;
	case 1044: goto tr180;
	case 1045: goto tr180;
	case 1046: goto tr180;
	case 1047: goto tr180;
	case 1048: goto tr180;
	case 1049: goto tr180;
	case 1050: goto tr180;
	case 1051: goto tr180;
	case 1606: goto tr2127;
	case 1052: goto tr1290;
	case 1053: goto tr1290;
	case 1054: goto tr1290;
	case 1055: goto tr1290;
	case 1056: goto tr1290;
	case 1057: goto tr1290;
	case 1058: goto tr1290;
	case 1059: goto tr1290;
	case 1060: goto tr1290;
	case 1061: goto tr1290;
	case 1062: goto tr1290;
	case 1063: goto tr1290;
	case 1607: goto tr2127;
	case 1608: goto tr2127;
	case 1610: goto tr2135;
	case 1064: goto tr1302;
	case 1065: goto tr1302;
	case 1066: goto tr1302;
	case 1067: goto tr1302;
	case 1068: goto tr1302;
	case 1069: goto tr1302;
	case 1070: goto tr1302;
	case 1071: goto tr1302;
	case 1072: goto tr1302;
	case 1073: goto tr1302;
	case 1074: goto tr1302;
	case 1075: goto tr1302;
	case 1076: goto tr1302;
	case 1077: goto tr1302;
	case 1078: goto tr1302;
	case 1079: goto tr1302;
	case 1080: goto tr1302;
	case 1081: goto tr1302;
	case 1611: goto tr2135;
	case 1612: goto tr2135;
	case 1614: goto tr2141;
	case 1082: goto tr1320;
	case 1083: goto tr1320;
	case 1084: goto tr1320;
	case 1085: goto tr1320;
	case 1086: goto tr1320;
	case 1087: goto tr1320;
	case 1088: goto tr1320;
	case 1089: goto tr1320;
	case 1090: goto tr1320;
	case 1091: goto tr1320;
	case 1092: goto tr1320;
	case 1093: goto tr1320;
	case 1094: goto tr1320;
	case 1095: goto tr1320;
	case 1096: goto tr1320;
	case 1097: goto tr1320;
	case 1098: goto tr1320;
	case 1099: goto tr1320;
	case 1100: goto tr1320;
	case 1101: goto tr1320;
	case 1102: goto tr1320;
	case 1103: goto tr1320;
	case 1104: goto tr1320;
	case 1105: goto tr1320;
	case 1106: goto tr1320;
	case 1107: goto tr1320;
	case 1108: goto tr1320;
	case 1109: goto tr1320;
	case 1110: goto tr1320;
	case 1111: goto tr1320;
	case 1112: goto tr1320;
	case 1113: goto tr1320;
	case 1114: goto tr1320;
	case 1115: goto tr1320;
	case 1116: goto tr1320;
	case 1117: goto tr1320;
	case 1118: goto tr1320;
	case 1119: goto tr1320;
	case 1120: goto tr1320;
	case 1121: goto tr1320;
	case 1122: goto tr1320;
	case 1123: goto tr1320;
	case 1124: goto tr1320;
	case 1125: goto tr1320;
	case 1126: goto tr1320;
	case 1127: goto tr1320;
	case 1128: goto tr1320;
	case 1129: goto tr1320;
	case 1130: goto tr1320;
	case 1131: goto tr1320;
	case 1132: goto tr1320;
	case 1133: goto tr1320;
	case 1134: goto tr1320;
	case 1135: goto tr1320;
	case 1136: goto tr1320;
	case 1137: goto tr1320;
	case 1138: goto tr1320;
	case 1139: goto tr1320;
	case 1140: goto tr1320;
	case 1141: goto tr1320;
	case 1142: goto tr1320;
	case 1143: goto tr1320;
	case 1144: goto tr1320;
	case 1145: goto tr1320;
	case 1146: goto tr1320;
	case 1147: goto tr1320;
	case 1148: goto tr1320;
	case 1149: goto tr1320;
	case 1150: goto tr1320;
	case 1151: goto tr1320;
	case 1152: goto tr1320;
	case 1153: goto tr1320;
	case 1154: goto tr1320;
	case 1155: goto tr1320;
	case 1156: goto tr1320;
	case 1157: goto tr1320;
	case 1158: goto tr1320;
	case 1159: goto tr1320;
	case 1160: goto tr1320;
	case 1161: goto tr1320;
	case 1162: goto tr1320;
	case 1163: goto tr1320;
	case 1164: goto tr1320;
	case 1165: goto tr1320;
	case 1166: goto tr1320;
	case 1167: goto tr1320;
	case 1168: goto tr1320;
	case 1169: goto tr1320;
	case 1170: goto tr1320;
	case 1171: goto tr1320;
	case 1172: goto tr1320;
	case 1173: goto tr1320;
	case 1174: goto tr1320;
	case 1175: goto tr1320;
	case 1176: goto tr1320;
	case 1177: goto tr1320;
	case 1178: goto tr1320;
	case 1179: goto tr1320;
	case 1180: goto tr1320;
	case 1181: goto tr1320;
	case 1182: goto tr1320;
	case 1183: goto tr1320;
	case 1184: goto tr1320;
	case 1185: goto tr1320;
	case 1186: goto tr1320;
	case 1187: goto tr1320;
	case 1188: goto tr1320;
	case 1189: goto tr1320;
	case 1190: goto tr1320;
	case 1191: goto tr1320;
	case 1192: goto tr1320;
	case 1193: goto tr1320;
	case 1615: goto tr2141;
	case 1194: goto tr1320;
	case 1195: goto tr1320;
	case 1196: goto tr1320;
	case 1197: goto tr1320;
	case 1198: goto tr1320;
	case 1199: goto tr1320;
	case 1200: goto tr1320;
	case 1201: goto tr1320;
	case 1202: goto tr1320;
	case 1203: goto tr1320;
	case 1204: goto tr1320;
	case 1205: goto tr1320;
	case 1206: goto tr1320;
	case 1207: goto tr1320;
	case 1208: goto tr1320;
	case 1209: goto tr1320;
	case 1210: goto tr1320;
	case 1211: goto tr1320;
	case 1212: goto tr1320;
	case 1213: goto tr1320;
	case 1214: goto tr1320;
	case 1215: goto tr1320;
	case 1216: goto tr1320;
	case 1217: goto tr1320;
	case 1218: goto tr1320;
	case 1219: goto tr1320;
	case 1220: goto tr1320;
	case 1221: goto tr1320;
	case 1222: goto tr1320;
	case 1223: goto tr1320;
	case 1224: goto tr1320;
	case 1225: goto tr1320;
	case 1226: goto tr1320;
	case 1227: goto tr1320;
	case 1228: goto tr1320;
	case 1229: goto tr1320;
	case 1230: goto tr1320;
	case 1231: goto tr1320;
	case 1232: goto tr1320;
	case 1233: goto tr1320;
	case 1234: goto tr1320;
	case 1235: goto tr1320;
	case 1236: goto tr1320;
	case 1237: goto tr1320;
	case 1238: goto tr1320;
	case 1239: goto tr1320;
	case 1240: goto tr1320;
	case 1241: goto tr1320;
	case 1242: goto tr1320;
	case 1243: goto tr1320;
	case 1244: goto tr1320;
	case 1245: goto tr1320;
	case 1246: goto tr1320;
	case 1247: goto tr1320;
	case 1248: goto tr1320;
	case 1249: goto tr1320;
	case 1250: goto tr1320;
	case 1251: goto tr1320;
	case 1252: goto tr1320;
	case 1253: goto tr1320;
	case 1254: goto tr1320;
	case 1255: goto tr1320;
	case 1256: goto tr1320;
	case 1257: goto tr1320;
	case 1258: goto tr1320;
	case 1259: goto tr1320;
	case 1260: goto tr1320;
	case 1261: goto tr1320;
	case 1262: goto tr1320;
	case 1263: goto tr1320;
	case 1264: goto tr1320;
	case 1265: goto tr1320;
	case 1266: goto tr1320;
	case 1267: goto tr1320;
	case 1268: goto tr1320;
	case 1269: goto tr1320;
	case 1270: goto tr1320;
	case 1271: goto tr1320;
	case 1272: goto tr1320;
	case 1273: goto tr1320;
	case 1274: goto tr1320;
	case 1275: goto tr1320;
	case 1276: goto tr1320;
	case 1277: goto tr1320;
	case 1278: goto tr1320;
	case 1279: goto tr1320;
	case 1280: goto tr1320;
	case 1281: goto tr1320;
	case 1282: goto tr1320;
	case 1283: goto tr1320;
	case 1284: goto tr1320;
	case 1285: goto tr1320;
	case 1286: goto tr1320;
	case 1287: goto tr1320;
	case 1288: goto tr1320;
	case 1289: goto tr1320;
	case 1290: goto tr1320;
	case 1291: goto tr1320;
	case 1292: goto tr1320;
	case 1293: goto tr1320;
	case 1294: goto tr1320;
	case 1295: goto tr1320;
	case 1296: goto tr1320;
	case 1297: goto tr1320;
	case 1298: goto tr1320;
	case 1299: goto tr1320;
	case 1300: goto tr1320;
	case 1301: goto tr1320;
	case 1302: goto tr1320;
	case 1303: goto tr1320;
	case 1304: goto tr1320;
	case 1305: goto tr1320;
	}
	}

	_out: {}
	}

#line 1454 "ext/dtext/dtext.cpp.rl"

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
