#ifndef DTEXT_H
#define DTEXT_H

#include <string>
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

typedef struct StateMachine {
  bool f_inline;
  bool f_mentions;
  std::string base_url;
  std::string domain;

  size_t top;
  int cs;
  int act;
  const char * p;
  const char * pb;
  const char * pe;
  const char * eof;
  const char * ts;
  const char * te;
  const char * a1;
  const char * a2;
  const char * b1;
  const char * b2;
  const char * c1;
  const char * c2;
  const char * d1;
  const char * d2;
  bool header_mode;
  int list_nest;

  std::string input;
  std::string output;
  std::vector<int> stack;
  std::vector<element_t> dstack;
  std::string error;
} StateMachine;

StateMachine init_machine(const char * src, size_t len);

bool parse_helper(StateMachine* sm);
std::string parse_basic_inline(const char* dtext, const ssize_t length);

#endif
