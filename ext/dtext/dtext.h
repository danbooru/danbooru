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

private:
  StateMachine(const auto string, int initial_state, const DTextOptions = {});
  std::string parse();
};

static std::tuple<std::string_view, std::string_view> trim_url(const std::string_view url);
static std::tuple<std::string_view, std::string_view, std::string_view, std::string_view> parse_url(const std::string_view url);
static std::vector<std::string_view> split_string(const std::string_view input, char delim = '/');
static void dstack_rewind(StateMachine * sm);
static void dstack_open_inline(StateMachine * sm, element_t type, const char * html);
static void dstack_open_element(StateMachine * sm, element_t type, const char * html);
static void dstack_open_element(StateMachine * sm, element_t type, std::string_view tag_name, const StateMachine::TagAttributes& tag_attributes);
static bool dstack_close_element(StateMachine * sm, element_t type);
static void dstack_close_leaf_blocks(StateMachine * sm);
static void append_block(StateMachine * sm, const auto s);
static void append_block_html_escaped(StateMachine * sm, const std::string_view string);
static void append_relative_url(StateMachine * sm, const auto url);
static void append_absolute_link(StateMachine * sm, const std::string_view url, const std::string_view title, bool internal_url = false, bool escape_title = true);
static void append_internal_url(StateMachine * sm, const DText::URL& url);
static void append_unnamed_url(StateMachine * sm, const std::string_view url);
static void append_wiki_link(StateMachine * sm, const std::string_view prefix, const std::string_view tag, const std::string_view anchor, const std::string_view title, const std::string_view suffix);
static void save_tag_attribute(StateMachine * sm, const std::string_view name, const std::string_view value);
static void clear_tag_attributes(StateMachine * sm);
static void clear_matches(StateMachine * sm);

#endif
