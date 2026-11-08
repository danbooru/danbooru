#ifndef DTEXT_URL_H
#define DTEXT_URL_H

#include <string>
#include <algorithm>
#include <vector>

namespace DText {

class URL {
 public:
  const std::string_view url;
  std::string_view scheme;
  std::string_view domain;
  std::string_view path;
  std::string_view query;
  std::string_view fragment;

  URL(std::string_view url) : url(url) {
    parse();
  }

  const std::vector<std::string_view> path_components() const {
    std::vector<std::string_view> output;

    for (size_t previous = 0, current = 0; current != std::string_view::npos; previous = current + 1) {
      current = path.find_first_of('/', previous);

      if (current > previous) {
        output.push_back(path.substr(previous, current - previous));
      }
    }

    return output;
  }

 private:

  // Parse a URL like `https://danbooru.donmai.us:443/posts/1234?q=touhou#comment-1234`. This is done by hand instead
  // of with std::regex because std::regex recurses once per character and overflows the stack on long URLs.
  void parse() {
    auto rest = url;

    // `https:`
    auto scheme_end = rest.find(':');
    if (scheme_end == 0 || scheme_end == std::string_view::npos || !std::all_of(rest.begin(), rest.begin() + scheme_end, [](unsigned char c) { return (c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z'); })) {
      return;
    }
    auto parsed_scheme = rest.substr(0, scheme_end);
    rest.remove_prefix(scheme_end + 1);

    // `//`
    if (rest.starts_with("//")) {
      rest.remove_prefix(2);
    }

    // `danbooru.donmai.us`
    auto domain_end = std::min(rest.find_first_of("/\\?#:"), rest.size());
    if (domain_end == 0) {
      return;
    }
    auto parsed_domain = rest.substr(0, domain_end);
    rest.remove_prefix(domain_end);

    // `:443`
    if (rest.starts_with(':')) {
      auto port_end = std::min(rest.find_first_not_of("0123456789", 1), rest.size());
      if (port_end == 1) {
        return;
      }
      rest.remove_prefix(port_end);
    }

    // `/posts/1234`
    std::string_view parsed_path;
    if (rest.starts_with('/')) {
      auto path_end = std::min(rest.find_first_of("?#"), rest.size());
      parsed_path = rest.substr(1, path_end - 1);
      rest.remove_prefix(path_end);
    }

    // `?q=touhou`
    std::string_view parsed_query;
    if (rest.starts_with('?')) {
      auto query_end = std::min(rest.find('#'), rest.size());
      parsed_query = rest.substr(1, query_end - 1);
      rest.remove_prefix(query_end);
    }

    // `#comment-1234` (can't contain line breaks, like `.` in a regex)
    std::string_view parsed_fragment;
    if (rest.starts_with('#')) {
      parsed_fragment = rest.substr(1);
      if (parsed_fragment.find_first_of("\r\n") != std::string_view::npos) {
        return;
      }
      rest = {};
    }

    // Anything left over (e.g. `:443x`) means the URL is invalid.
    if (!rest.empty()) {
      return;
    }

    scheme = parsed_scheme;
    domain = parsed_domain;
    path = parsed_path;
    query = parsed_query;
    fragment = parsed_fragment;
  }
};

}

#endif
