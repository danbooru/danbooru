#ifndef DTEXT_H
#define DTEXT_H

#include "url.h"

#include <map>
#include <stdexcept>
#include <string>
#include <unordered_set>
#include <vector>

typedef enum element_t {
  DSTACK_EMPTY = 0,
  BLOCK_P,
  BLOCK_TN,
  BLOCK_QUOTE,
  BLOCK_EXPAND,
  BLOCK_SPOILER,
  BLOCK_NODTEXT,
  BLOCK_CODE,
  BLOCK_TABLE,
  BLOCK_COLGROUP,
  BLOCK_COL,
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
  INLINE,
  INLINE_B,
  INLINE_I,
  INLINE_U,
  INLINE_S,
  INLINE_TN,
  INLINE_CODE,
  INLINE_SPOILER,
  INLINE_NODTEXT,
} element_t;

static const char* element_names[] = {
  "DSTACK_EMPTY",
  "BLOCK_P",
  "BLOCK_TN",
  "BLOCK_QUOTE",
  "BLOCK_EXPAND",
  "BLOCK_SPOILER",
  "BLOCK_NODTEXT",
  "BLOCK_CODE",
  "BLOCK_TABLE",
  "BLOCK_COLGROUP",
  "BLOCK_COL",
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
  "INLINE",
  "INLINE_B",
  "INLINE_I",
  "INLINE_U",
  "INLINE_S",
  "INLINE_TN",
  "INLINE_CODE",
  "INLINE_SPOILER",
  "INLINE_NODTEXT",
};

class DTextError : public std::runtime_error {
  using std::runtime_error::runtime_error;
};

struct DTextOptions {
  // If false, strip block-level elements (used for displaying DText in small spaces).
  bool f_inline = false;

  // If false, ignore @-mentions (used for artist commentaries).
  bool f_mentions = true;

  // If set, convert relative URLs to absolute URLs (used for sending dmails).
  std::string base_url;

  // Links to this domain are considered internal URLs, rather than external URLs (used so links to https://danbooru.donmai.us don't get marked as external).
  std::string domain;

  // Links to these domains are converted to shortlinks (used so links to https://danbooru.donmai.us/posts/1234 are converted to post #1234).
  std::unordered_set<std::string> internal_domains;
};

class StateMachine {
public:
  using TagAttributes = std::map<std::string_view, std::string_view>;

  const DTextOptions options;

  size_t top = 0;
  int cs;
  int act = 0;
  const char * p = NULL;
  const char * pb = NULL;
  const char * pe = NULL;
  const char * eof = NULL;
  const char * ts = NULL;
  const char * te = NULL;
  const char * a1 = NULL;
  const char * a2 = NULL;
  const char * b1 = NULL;
  const char * b2 = NULL;
  const char * c1 = NULL;
  const char * c2 = NULL;
  const char * d1 = NULL;
  const char * d2 = NULL;
  const char * e1 = NULL;
  const char * e2 = NULL;
  const char * f1 = NULL;
  const char * f2 = NULL;
  const char * g1 = NULL;
  const char * g2 = NULL;
  bool header_mode = false;
  TagAttributes tag_attributes;

  std::string input;
  std::string output;
  std::vector<int> stack;
  std::vector<element_t> dstack;
  std::unordered_set<std::string> wiki_pages;

  using ParseResult = std::tuple<std::string, decltype(wiki_pages)>;
  static ParseResult parse_dtext(const std::string_view dtext, const DTextOptions options);

  std::string parse_inline(const std::string_view dtext);
  std::string parse_basic_inline(const std::string_view dtext);

  void dstack_push(element_t element);
  element_t dstack_pop();
  void dstack_rewind();
  bool dstack_check(element_t expected_element);
  element_t dstack_peek();
  bool dstack_is_open(element_t element);
  void dstack_close_until(element_t element);
  void dstack_close_all();
  int dstack_count(element_t element);
  void dstack_open_element(element_t type, const char *html);
  void dstack_open_element_attributes(element_t type, std::string_view tag_name);
  void dstack_open_list(int depth);
  void dstack_close_list();
  bool dstack_close_element(element_t type, const std::string_view tag_name);
  void dstack_close_leaf_blocks();

  void append(const auto c);
  void append(const std::string_view string);
  void append_html_escaped(char s);
  void append_html_escaped(const std::string_view string);
  void append_uri_escaped(const std::string_view string);
  void append_relative_url(const auto url);
  void append_block(const auto s);
  void append_block_html_escaped(const std::string_view string);

  void append_header(char header, const std::string_view id);
  void append_mention(const std::string_view name);
  void append_id_link(const char *title, const char *id_name, const char *url, const std::string_view id);
  void append_bare_unnamed_url(const std::string_view url);
  void append_unnamed_url(const std::string_view url);
  void append_internal_url(const DText::URL &url);
  void append_named_url(const std::string_view url, const std::string_view title);
  void append_bare_named_url(const std::string_view url, std::string_view title);
  void append_absolute_link(const std::string_view url, const std::string_view title, bool internal_url = false, bool escape_title = true);
  void append_post_search_link(const std::string_view prefix, const std::string_view search, const std::string_view title, const std::string_view suffix);
  void append_wiki_link(const std::string_view prefix, const std::string_view tag, const std::string_view anchor, const std::string_view title, const std::string_view suffix);
  void append_paged_link(const char *title, const std::string_view id, const char *tag, const char *href, const char *param, const std::string_view page);
  void append_dmail_key_link(const std::string_view dmail_id, const std::string_view dmail_key);
  void append_code_fence(const std::string_view code, const std::string_view language);
  void append_inline_code(const std::string_view language = {});
  void append_block_code(const std::string_view language = {});

  void clear_matches();

  bool is_internal_url(const std::string_view url);
  std::tuple<std::string_view, std::string_view> trim_url(const std::string_view url);

private:
  StateMachine(const auto string, int initial_state, const DTextOptions = {});
  std::string parse();
};

#endif
